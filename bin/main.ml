open Proover.Parser
open Proover.Prover

let parse_tactic s =
  match String.sub (String.lowercase_ascii s) 0 2 with
  | "eq" -> EquivIntro
  | "in" -> Intros
  | "no" -> NotIntros
  | "ax" -> Axiom
  | "ap" -> Apply
  | "an" -> AndElim
  | "co" -> Contradiction
  | "qe" -> Qed
  | _ ->
      Printf.printf "unknown tactic: %s" s;
      exit 1

let init_proof_state s =
  match parse_logical_formula s with
  | Success (f, _) -> { target = f; assumptions = []; remaining_targets = [] }
  | Fail ->
      Printf.printf " failed to parse formula\n";
      exit 1

let rec string_of_logical_formula = function
  | Variable v -> v
  | Negation f -> "~" ^ string_of_logical_formula f
  | Conjunction (f1, f2) ->
      Printf.sprintf "(%s /\\ %s)" (string_of_logical_formula f1) (string_of_logical_formula f2)
  | Disjunction (f1, f2) ->
      Printf.sprintf "(%s \\/ %s)" (string_of_logical_formula f1) (string_of_logical_formula f2)
  | Implication (f1, f2) ->
      Printf.sprintf "(%s -> %s)" (string_of_logical_formula f1) (string_of_logical_formula f2)
  | Equivalence (f1, f2) ->
      Printf.sprintf "(%s <-> %s)" (string_of_logical_formula f1) (string_of_logical_formula f2)

let print_state state =
  Printf.printf "target: %s\n" (string_of_logical_formula state.target);
  Printf.printf "assumptions: %s\n"
    (String.concat "; " (List.map string_of_logical_formula state.assumptions));

  let remaining_targets_count = List.length state.remaining_targets in
  if remaining_targets_count > 0 then
    Printf.printf "n remaining targets: %d\n" remaining_targets_count;

  print_newline ()

let rec proof_loop state =
  print_state state;
  Printf.printf "> ";
  let input = read_line () in
  match String.trim input with
  | "" -> proof_loop state
  | tactic_str -> (
      let tactic = parse_tactic tactic_str in
      match apply_tactic state tactic with
      | Ok new_state -> (
          match tactic with
          | Contradiction | Axiom -> proof_loop new_state
          | Qed -> Printf.printf "proof completed\n"
          | _ -> proof_loop new_state)
      | Error message -> Printf.printf "error: %s\n\n" message)

let () = proof_loop (init_proof_state Sys.argv.(1))
