{-# OPTIONS --safe #-}

open import Arch.General.Execution using (Execution; WellFormed)
open import Arch.LIMM using (LabelLIMM)
open import TransformFRAR using (FRAR-Restricted)


module Proof.Elimination.FRAR.Mapping
  (dst : Execution LabelLIMM)
  (dst-ok : FRAR-Restricted dst)
  where

-- Stdlib imports
import Relation.Binary.PropositionalEquality as Eq
open Eq using (_≡_; _≢_; refl)
open import Data.Product using (_×_; _,_; proj₁; proj₂; ∃-syntax)
open import Data.Empty using (⊥; ⊥-elim)
open import Relation.Nullary using (¬_; yes; no)
open import Relation.Unary using (Pred; _∈_)
-- Local imports: General
open import Helpers
-- Local imports: Architectures
open import Arch.General.Event
open import Arch.General.Execution as Ex
open import Arch.LIMM as LIMM
-- Local imports: Theorem Specification
open import TransformFRAR
-- Local imports: Proof Components
open import Proof.Elimination.FRAR.Execution dst dst-ok as FRAR-Ex
import Proof.Framework LabelLIMM dst dst-wf as Ψ
import Proof.Elimination.Framework dst dst-wf as Δ


-- General Proof Framework
open Ψ.Definitions ev[⇐]
-- Elimination Proof Framework
open Δ.Definitions δ
-- Other
open Ex.Execution
open Ex.WellFormed
open FRAR-Ex.Extra
open TransformFRAR.Extra dst-ok
open FRAR-Restricted dst-ok


events-preserved : ∀ {x : Event LabelLIMM} → x ≢ elim-ev → x ∈ events dst → x ∈ events src
events-preserved {event-init _ _ _}   ¬x-elimᵗ x∈dst = events[⇐] x∈dst
events-preserved x@{event-skip uid tid} ¬x-elimᵗ x∈dst with ℕ-dec uid elim-uid
... | yes refl    = ⊥-elim (¬x-elimᵗ (unique-ids dst-wf uid (has-uid-skip , x∈dst) (elim-has-uid , elim∈ex)))
... | no uid≢elim = _ , x∈dst , lemma
  where
  -- Unsure why this lemma is needed, as we're above already splitting on
  -- > ℕ-dec uid (elim-uid dst-ok)
  -- But without this lemma, it doesn't type-check
  lemma : x ≡ ev[⇐] x∈dst
  lemma with ℕ-dec uid elim-uid
  ... | yes refl = ⊥-elim (uid≢elim refl)
  ... | no _     = refl
events-preserved {event _ _ _} ¬x-elimᵗ x∈dst = events[⇐] x∈dst


src-elim-ev-def : src-elim-ev ≡ event elim-uid elim-tid (lab-r tmov elim-loc elim-val)
src-elim-ev-def with elim-ev-skip
-- this is strange, but necessary as it matches over the cases in `ev[⇐]`
src-elim-ev-def | ev-skip with ℕ-dec elim-uid elim-uid
src-elim-ev-def | ev-skip | yes refl = refl
src-elim-ev-def | ev-skip | no uid≢uid = ⊥-elim (uid≢uid refl)


src-mapping : FRARMapping src dst-ok
src-mapping =
  record
    { src-elim-ev      = src-elim-ev
    ; src-elim-ev-def  = src-elim-ev-def
    ; src-elim-ev∈src  = elim∈src
    ; events-preserved = events-preserved
    }
