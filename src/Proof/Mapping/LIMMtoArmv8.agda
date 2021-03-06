{-# OPTIONS --safe #-}

open import Arch.General.Execution
open import Arch.Armv8
open import MapLIMMtoArmv8


module Proof.Mapping.LIMMtoArmv8
  -- Given a target execution
  (dst : Execution LabelArmv8)
  -- which is wellformed
  (dst-wf : WellFormed dst)
  -- and generated by a program produced through the mapping
  (dst-ok : Armv8-LIMMRestricted dst)
  where

-- Stdlib imports
open import Data.Product using (_×_; _,_; ∃-syntax)
-- Library imports
open import Dodo.Binary
-- Local imports: Architectures
open import Arch.LIMM
-- Local imports: Proof Components
open import Proof.Mapping.LIMMtoArmv8.Execution dst dst-wf dst-ok
open import Proof.Mapping.LIMMtoArmv8.Consistent dst dst-wf dst-ok
open import Proof.Mapping.LIMMtoArmv8.Mapping dst dst-wf dst-ok
import Proof.Mapping.Framework LabelLIMM dst dst-wf as Δ


open Armv8-LIMMRestricted
open IsArmv8Consistent
open Δ.Definitions δ
open Δ.WellFormed δ
open Δ.Behavior δ


proof-LIMM⇒Armv8 :
  -- We produce a source execution
  ∃[ src ]
    ( -- which is wellformed,
      WellFormed src
    × -- consistent in the source architecture,
      IsLIMMConsistent src
    × -- related to the target by the mapping on instructions,
      LIMM⇒Armv8 src (a8 (consistent dst-ok))
    × -- and has identical behavior to the target
      behavior src ⇔₂ behavior dst
    )
proof-LIMM⇒Armv8 =
  ( src
  , src-wf
  , src-consistent
  , src-mapping
  , proof-behavior
  )
