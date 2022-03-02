{-# OPTIONS --safe #-}

open import Arch.General.Execution using (Execution)
open import Arch.LIMM using (LabelLIMM)
open import TransformWAW using (WAW-Restricted)


module Proof.Elimination.WAW.Behavior
  (dst : Execution LabelLIMM)
  (dst-ok : WAW-Restricted dst)
  where

-- Stdlib imports
import Relation.Binary.PropositionalEquality as Eq
open Eq using (refl; _≢_) renaming (sym to ≡-sym)
open import Data.Product using (_×_; _,_; proj₁; proj₂; ∃-syntax)
open import Relation.Nullary using (¬_; yes; no)
open import Function using (_∘_)
open import Data.Empty using (⊥-elim)
-- Library imports
open import Dodo.Unary
open import Dodo.Binary
-- Local imports: General
open import Helpers
-- Local imports: Architectures
open import Arch.General.Properties
open import Arch.General.Execution as Ex
open import Arch.General.DerivedWellformed
-- Local imports: Proof Components
open import Proof.Elimination.WAW.Execution dst dst-ok as WAW-Ex
open import Proof.Elimination.WAW.WellFormed dst dst-ok as WAW-Wf
import Proof.Framework LabelLIMM dst dst-wf as Ψ
import Proof.Elimination.Framework dst dst-wf as Δ


-- General Proof Frameworks
open Ψ.Definitions ev[⇐]
open Ψ.WellFormed ψ
-- Elimination Proof Framework
open Δ.Definitions δ
-- Other
open WAW-Ex.Extra
open Ex.Execution
open TransformWAW.Extra dst-ok
open WAW-Restricted dst-ok


private
  ¬pres-elim : src-preserved-ev ≢ src-elim-ev
  ¬pres-elim p≡e = po-irreflexive src-wf (≡-sym p≡e) (proj₁ src-transform-pair)


src-behavior : behavior src ⇔₂ behavior dst
src-behavior = ⇔: ⊆-proof ⊇-proof
  where
  ⊆-proof : behavior src ⊆₂' behavior dst
  ⊆-proof loc val (x , x∈src , x-w , x-val , x-loc , ¬∃z) =
    let ¬x-elim = λ{refl → ⊥-elim (¬∃z (src-preserved-ev , co-ep refl refl))}
    in
    ( ev[⇒] x∈src
    , events[⇒] x∈src
    , W[⇒] ¬x-elim x∈src x-w
    , val[⇒] ¬x-elim x∈src x-val
    , loc[⇒] ¬x-elim x∈src x-loc
    , ¬∃z'
    )
    where
    ¬∃z' : ¬ (∃[ z ] co dst (ev[⇒] x∈src) z)
    ¬∃z' (z , co[xz]) =
      let z∈src = events[⇐] (coʳ∈ex dst-wf co[xz])
      in ¬∃z (_ , co[⇐$] x∈src z∈src co[xz])

  ⊇-proof : behavior dst ⊆₂' behavior src
  ⊇-proof loc val (x , x∈dst , x-w , x-val , x-loc , ¬∃z) =
    ( ev[⇐] x∈dst
    , events[⇐] x∈dst
    , W[⇐] x∈dst x-w
    , val[⇐] x∈dst x-val
    , loc[⇐] x∈dst x-loc
    , ¬∃z'
    )
    where
    ¬∃z' : ¬ (∃[ z ] co src (ev[⇐] x∈dst) z)
    ¬∃z' (z , co[xz]) with ev-eq-dec z src-elim-ev
    ... | yes refl =
      let ¬x-elimᵗ = λ{refl → disjoint-w/skip _ (x-w , elim-ev-skip)}
          ¬x-elimˢ = ¬x-elimᵗ ∘ ev[$⇒]eq x∈dst elim∈ex
          co[xp] = coʳ-e⇒p co[xz]
      in ¬∃z (_ , co[⇒] ¬x-elimˢ ¬pres-elim (events[⇐] x∈dst) preserved∈src co[xp])
    ... | no ¬z-elim =
      let ¬x-elimᵗ = λ{refl → disjoint-w/skip _ (x-w , elim-ev-skip)}
          ¬x-elimˢ = ¬x-elimᵗ ∘ ev[$⇒]eq x∈dst elim∈ex
          z∈src = coʳ∈src co[xz]
      in ¬∃z (_ , co[⇒] ¬x-elimˢ ¬z-elim (events[⇐] x∈dst) z∈src co[xz])
