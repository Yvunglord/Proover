open Parser

type proof_context = {
  target : logical_formula;
  assumptions : logical_formula list;
  remaining_targets : logical_formula list;
}

type tactic =
  | EquivIntro
  | Intros
  | NotIntros
  | Axiom
  | Apply
  | AndElim
  | Contradiction
  | Qed

let rec formula_equal f1 f2 =
  match (f1, f2) with
  | Variable s1, Variable s2 -> s1 = s2
  | Negation f1', Negation f2' -> formula_equal f1' f2'
  | Conjunction (a1, b1), Conjunction (a2, b2)
  | Disjunction (a1, b1), Disjunction (a2, b2)
  | Implication (a1, b1), Implication (a2, b2)
  | Equivalence (a1, b1), Equivalence (a2, b2) ->
      formula_equal a1 a2 && formula_equal b1 b2
  | _ -> false

let apply_tactic state tactic =
  match (state.target, tactic) with
  | Equivalence (f1, f2), EquivIntro ->
      let new_state =
        {
          state with
          remaining_targets = Implication (f2, f1) :: state.remaining_targets;
          target = Implication (f1, f2);
        }
      in
      Ok new_state
  | Implication (f1, f2), Intros ->
      let new_state = { state with assumptions = f1 :: state.assumptions; target = f2 } in
      Ok new_state
  | Negation f, NotIntros ->
      Ok { state with target = Variable "False"; assumptions = f :: state.assumptions }
  | f, NotIntros ->
      Ok { state with target = Variable "False"; assumptions = Negation f :: state.assumptions }
  | _, AndElim ->
      let new_context =
        List.fold_left
          (fun acc f ->
            match f with Conjunction (a, b) -> a :: b :: acc | _ -> f :: acc)
          [] state.assumptions
      in
      Ok { state with assumptions = new_context }
  | _, Apply ->
      let new_context =
        List.fold_left
          (fun acc f ->
            match f with
            | Implication (a, b) when List.mem a state.assumptions -> b :: acc
            | _ -> f :: acc)
          [] state.assumptions
      in
      Ok { state with assumptions = new_context }
  | target, Axiom -> (
      let has_axiom =
        List.exists (fun f -> formula_equal f target) state.assumptions
      in
      match (state.remaining_targets, has_axiom) with
      | _, false -> Error "target is not in assumptions"
      | [], true -> Ok { state with target = Variable "proved" }
      | new_target :: tl, true ->
          Ok { state with target = new_target; remaining_targets = tl })
  | _, Contradiction -> (
      let has_contradiction =
        List.exists
          (fun f ->
            List.exists (fun g -> formula_equal f (Negation g)) state.assumptions)
          state.assumptions
      in
      match (state.remaining_targets, has_contradiction) with
      | _, false -> Error "no contradiction in assumptions"
      | [], true -> Ok { state with target = Variable "proved" }
      | new_target :: tl, true ->
          Ok { state with target = new_target; remaining_targets = tl })
  | target, Qed ->
      if formula_equal target (Variable "proved") && state.remaining_targets = [] then
        Ok state
      else Error "proof incomplete"
  | _ -> Error "tactic not applicable to current target"
