open Alcotest
open Proover.Parser

let equal_parse_result r1 r2 =
  match (r1, r2) with
  | Fail, Fail -> true
  | Success (Variable s1, r1), Success (Variable s2, r2) -> s1 = s2 && r1 = r2
  | Success (Negation f1, r1), Success (Negation f2, r2) -> f1 = f2 && r1 = r2
  | Success (Conjunction (f1, f2), r1), Success (Conjunction (f3, f4), r2) ->
      f1 = f3 && f2 = f4 && r1 = r2
  | Success (Disjunction (f1, f2), r1), Success (Disjunction (f3, f4), r2) ->
      f1 = f3 && f2 = f4 && r1 = r2
  | Success (Implication (f1, f2), r1), Success (Implication (f3, f4), r2) ->
      f1 = f3 && f2 = f4 && r1 = r2
  | Success (Equivalence (f1, f2), r1), Success (Equivalence (f3, f4), r2) ->
      f1 = f3 && f2 = f4 && r1 = r2
  | _ -> false

let rec pp_logical_formula ppf = function
  | Variable s -> Format.fprintf ppf "Variable %s" s
  | Negation f -> Format.fprintf ppf "Negation (%a)" pp_logical_formula f
  | Conjunction (f1, f2) ->
      Format.fprintf ppf "Conjunction (%a, %a)" pp_logical_formula f1 pp_logical_formula f2
  | Disjunction (f1, f2) ->
      Format.fprintf ppf "Disjunction (%a, %a)" pp_logical_formula f1 pp_logical_formula f2
  | Implication (f1, f2) ->
      Format.fprintf ppf "Implication (%a, %a)" pp_logical_formula f1 pp_logical_formula f2
  | Equivalence (f1, f2) ->
      Format.fprintf ppf "Equivalence (%a, %a)" pp_logical_formula f1 pp_logical_formula f2

let pp_parse_result ppf = function
  | Fail -> Format.fprintf ppf "Fail"
  | Success (v, rest) ->
      Format.fprintf ppf "Success (%a, [%s])" pp_logical_formula v
        (String.concat "; " (List.map (String.make 1) rest))

let parse_result = testable pp_parse_result equal_parse_result

let test_variable () =
  check parse_result "parse 'xyz'"
    (Success (Variable "xyz", [ ' '; 'd' ]))
    (variable_parser [ 'x'; 'y'; 'z'; ' '; 'd' ]);
  check parse_result "parse 'XY'"
    (Success (Variable "XY", []))
    (variable_parser [ 'X'; 'Y' ]);
  check parse_result "fail on no letters" Fail (variable_parser [ ' '; 'x' ])

let test_logical_formula () =
  check parse_result "parse variable 'x'"
    (Success (Variable "x", []))
    (parse_logical_formula "x");
  check parse_result "parse conjunction 'x/\\y'"
    (Success (Conjunction (Variable "x", Variable "y"), []))
    (parse_logical_formula "x/\\y");
  check parse_result "parse negation '~x'"
    (Success (Negation (Variable "x"), []))
    (parse_logical_formula "~x");
  check parse_result "parse complex '~(x/\\y)->z->w'"
    (Success
       (Implication (Negation (Conjunction (Variable "x", Variable "y")), Implication (Variable "z", Variable "w")), []))
    (parse_logical_formula "~(x/\\y)->z->w");
  check parse_result "parse complex with equiv 'x/\\y<->z->w'"
    (Success (Equivalence (Conjunction (Variable "x", Variable "y"), Implication (Variable "z", Variable "w")), []))
    (parse_logical_formula "x/\\y<->z->w");
  check parse_result "fail on invalid '~)'" Fail (parse_logical_formula "~)")

let () =
  run "Logical Formula Parser Tests"
    [
      ("variable", [ test_case "variable parser" `Quick test_variable ]);
      ("logical_formula", [ test_case "logical_formula parser" `Quick test_logical_formula ]);
    ]
