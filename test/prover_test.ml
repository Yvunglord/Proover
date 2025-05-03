open Alcotest
open Proover.Parser
open Proover.Prover

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

let apply_tactics state tactics =
  List.fold_left
    (fun state tactic ->
      match apply_tactic state tactic with
      | Ok new_state -> new_state
      | Error message -> failwith message)
    state tactics

let run_proof formula tactics =
  let ast =
    match parse_logical_formula formula with
    | Success (f, _) -> f
    | Fail -> failwith "Failed to parse formula"
  in
  let initial_state = { target = ast; assumptions = []; remaining_targets = [] } in
  let final_state = apply_tactics initial_state tactics in
  check bool "Proof should succeed" true
    (formula_equal final_state.target (Variable "proved")
    && final_state.remaining_targets = [])

(*let test_proof_implication_contrapositive () =
  let formula = "(p->q)<->(~q->~p)" in
  let tactics =
    [
      EquivIntro;
      Intros;
      Intros;
      NotIntros;
      Contradiction;
      Intros;
      Intros;
      NotIntros;
      Contradiction;
      Qed;
    ]
  in
  let _ = run_proof formula tactics in
  ()*)

let test_proof_equiv () =
  let formula = "(x->y->z)<->(x/\\y->z)" in
  let tactics =
    [
      EquivIntro;
      Intros;
      Intros;
      AndElim;
      Apply;
      Apply;
      Axiom;
      Intros;
      Intros;
      Intros;
      Axiom;
      Qed;
    ]
  in
  let _ = run_proof formula tactics in
  ()
  
let test_proof_contradiction () =
  let formula = "(X/\\~X)->Y" in
  let tactics = [ Intros; AndElim; Contradiction; Qed ] in
  let _ = run_proof formula tactics in
  ()

let test_proof_double_negation_intro () =
  let formula = "X->~~X" in
  let tactics = [ Intros; NotIntros; Contradiction; Qed ] in
  let _ = run_proof formula tactics in
  ()

let test_proof_excluded_middle () =
  let formula = "(X\\/~X)->(~~X->X)" in
  let tactics = [ Intros; Intros; NotIntros; Contradiction; Qed ] in
  let _ = run_proof formula tactics in
  ()

let suite =
  [
   (*("implication contrapositive: (p->q)<->(~q->~p)", `Quick, test_proof_implication_contrapositive);*) 
    ("equivalence: (X -> Y -> Z) <-> (X /\\ Y -> Z)", `Quick, test_proof_equiv);
    ("contradiction: (X /\\ ~X) -> Y", `Quick, test_proof_contradiction);
    ("double negation: X -> ~~X", `Quick, test_proof_double_negation_intro);
    ( "excluded middle: (X \\/ ~X) -> (~~X -> X)",
      `Quick,
      test_proof_excluded_middle );
  ]

let () = Alcotest.run "Prover Tests" [ ("Proofs", suite) ]
  