{-# OPTIONS --safe #-}

open import Arch.General.Execution using (Execution; WellFormed)
open import Arch.LIMM using (LabelLIMM)
open import TransformFRAR using (FRAR-Restricted)


-- | Read-after-Read with fence elimination proof
module Proof.Elimination.FRAR
  -- Given a target execution
  (dst : Execution LabelLIMM)
  -- which is generated by a program produced through the mapping
  (dst-ok : FRAR-Restricted dst)
  where

-- Stdlib imports
open import Data.Product using (_×_; _,_; ∃-syntax)
-- Local imports: Architectures
open import Arch.General.Execution
open import Arch.LIMM
-- Local imports: Relations
open import Dodo.Binary
-- Local imports: Theorem Specification
open import TransformFRAR using (FRARMapping)
-- Local imports: Proof Components
open import Proof.Elimination.FRAR.Execution dst dst-ok
open import Proof.Elimination.FRAR.WellFormed dst dst-ok
open import Proof.Elimination.FRAR.Consistent dst dst-ok
open import Proof.Elimination.FRAR.Mapping dst dst-ok
open import Proof.Elimination.FRAR.Behavior dst dst-ok
import Proof.Elimination.Framework dst dst-wf as Δ


open Δ.Definitions δ
open Arch.General.Execution


proof-FRAR :
  -- We produce a source execution
  ∃[ src ]
    ( -- which is wellformed,
      WellFormed src
    × -- consistent in the source architecture,
      IsLIMMConsistent src
    × -- related to the target by the mapping on instructions,
      FRARMapping src dst-ok
    × -- and has identical behavior to the target
      behavior src ⇔₂ behavior dst
    )
proof-FRAR =
  ( src
  , src-wf
  , src-consistent
  , src-mapping
  , src-behavior
  )
