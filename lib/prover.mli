(** Copyright 2025-2025, Unwale *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

(** Type for proof context *)
type proof_context = {
  target : Parser.logical_formula;
  assumptions : Parser.logical_formula list;
  remaining_targets : Parser.logical_formula list;
}

(** Type for tactics *)
type tactic =
  | EquivIntro
  | Intros
  | NotIntros
  | Axiom
  | Apply
  | AndElim
  | Contradiction
  | Qed

(** Function to check if two formulas are equal *)
val formula_equal : Parser.logical_formula -> Parser.logical_formula -> bool

(** Function to apply a tactic to a proof state *)
val apply_tactic : proof_context -> tactic -> (proof_context, string) result
