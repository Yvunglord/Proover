open Proover.Parser
open Proover.Prover

let parse_tactic = function
  | "equiv_intro" | "ei" | "EquivIntro" -> EquivIntro
  | "intros" | "i" | "Intros" -> Intros
  | "not_intros" | "ni" | "NotIntros" -> NotIntros
  | "axiom" | "a" | "Axiom" -> Axiom
  | "apply" | "ap" | "Apply" -> Apply
  | "and_elim" | "ae" | "AndElim" -> AndElim
  | "contradiction" | "c" | "Contradiction" -> Contradiction
  | "qed" | "q" | "Qed" -> Qed
  | s -> failwith ("Unknown tactic: " ^ s)

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
  print_endline "=== Current state ===";
  print_endline "Assumptions:";
  List.iteri (fun i a -> Printf.printf "%d: %s\n" i (string_of_logical_formula a)) state.assumptions;
  print_endline "\nCurrent target:";
  print_endline (string_of_logical_formula state.target);
  if state.remaining_targets <> [] then
    Printf.printf "\nRemaining targets: %d\n" (List.length state.remaining_targets)

let run_interactive formula =
  let rec loop state =
    print_state state;
    print_string "> ";
    match read_line () with
    | exception End_of_file -> print_endline "Interrupted."; `Incomplete
    | cmd ->
        try
          let tactic = parse_tactic (String.trim cmd) in
          match apply_tactic state tactic with
          | Ok new_state -> 
              if formula_equal new_state.target (Variable "proved") && 
                 new_state.remaining_targets = [] then
                `Complete
              else
                loop new_state
          | Error msg -> 
              print_endline msg;
              loop state
        with Failure msg -> 
          print_endline msg;
          loop state
  in
  
  let initial_state = {
    target = formula;
    assumptions = [];
    remaining_targets = [];
  } in
  
  match loop initial_state with
  | `Complete -> print_endline "Proof completed!"; 0
  | `Incomplete -> print_endline "Proof incomplete."; 1

let run_from_file formula filename =
  let tactics = ref [] in
  let chan = open_in filename in
  try
    while true do
      let line = input_line chan in
      if line <> "" && line.[0] <> '#' then
        tactics := parse_tactic (String.trim line) :: !tactics
    done;
    0
  with
  | End_of_file -> 
      close_in chan;
      let tactics = List.rev !tactics in
      let rec apply_tactics state = function
        | [] -> state
        | tactic :: rest ->
            match apply_tactic state tactic with
            | Ok new_state -> apply_tactics new_state rest
            | Error msg -> 
                Printf.printf "Error applying tactic: %s\n" msg;
                state
      in
      
      let initial_state = {
        target = formula;
        assumptions = [];
        remaining_targets = [];
      } in
      
      let final_state = apply_tactics initial_state tactics in
      
      print_endline "=== Final state ===";
      print_state final_state;
      
      if formula_equal final_state.target (Variable "proved") && 
         final_state.remaining_targets = [] then
        (print_endline "Proof completed!"; 0)
      else
        (print_endline "Proof incomplete."; 1)
  | e -> 
      close_in chan;
      print_endline ("Error reading file: " ^ Printexc.to_string e);
      1

let () =
  if Array.length Sys.argv < 2 then
    (print_endline "Usage: ./prover <formula> [<tactics-file>]"; exit 1)
  else
    let formula = 
      match parse_logical_formula Sys.argv.(1) with
      | Success (f, _) -> f
      | Fail -> failwith "Failed to parse formula"
    in
    
    if Array.length Sys.argv = 2 then
      exit (run_interactive formula)
    else
      exit (run_from_file formula Sys.argv.(2))