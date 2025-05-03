type input_data = char list
type 'a parse_result = Fail | Success of 'a * input_data
type 'a parser = input_data -> 'a parse_result

type logical_formula =
  | Variable of string
  | Negation of logical_formula
  | Conjunction of logical_formula * logical_formula
  | Disjunction of logical_formula * logical_formula
  | Implication of logical_formula * logical_formula
  | Equivalence of logical_formula * logical_formula

let ( >>= ) (p : 'a parser) (f : 'a -> 'b parser) : 'b parser =
fun input ->
  match p input with Fail -> Fail | Success (v, rest) -> (f v) rest

let ( *> ) (p : 'a parser) (q : 'b parser) : 'b parser = p >>= fun _ -> q

let ( <* ) (p : 'a parser) (q : 'b parser) : 'a parser =
  p >>= fun v ->
  q >>= fun _ -> fun rest -> Success (v, rest)

let ( <|> ) (p : 'a parser) (q : 'a parser) : 'a parser =
fun input ->
  match p input with Fail -> q input | Success (v, rest) -> Success (v, rest)

let char (c : 'a) : 'a parser = function
  | x :: xs when x = c -> Success (c, xs)
  | _ -> Fail

let string (s : input_data) : input_data parser =
  let rec helper s =
    match s with
    | [] -> fun input -> Success (s, input)
    | x :: xs -> char x *> helper xs
  in
  helper s

let variable_parser : logical_formula parser =
  let is_letter c = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') in
  let letter : char parser = function
    | c :: rest when is_letter c -> Success (c, rest)
    | _ -> Fail
  in
  let rec helper acc s =
    match letter s with
    | Fail -> if acc = "" then Fail else Success (Variable acc, s)
    | Success (c, rest) -> helper (acc ^ String.make 1 c) rest
  in
  helper ""

let rec atom input =
  (variable_parser
  <|> (char '~' *> atom >>= fun f -> fun rest -> Success (Negation f, rest))
  <|> (char '(' *> formula <* char ')'))
    input

and conjunction input =
  ( atom >>= fun left ->
    string [ '/'; '\\' ] *> atom
    >>= (fun right -> fun rest -> Success (Conjunction (left, right), rest))
    <|> ( string [ '\\'; '/' ] *> atom >>= fun right ->
          fun rest -> Success (Disjunction (left, right), rest) )
    <|> fun rest -> Success (left, rest) )
    input

and implication input =
  ( conjunction >>= fun left ->
    ( string [ '-'; '>' ] *> formula >>= fun right ->
      fun rest -> Success (Implication (left, right), rest) )
    <|> fun rest -> Success (left, rest) )
    input

and formula input =
  ( implication >>= fun left ->
    ( string [ '<'; '-'; '>' ] *> formula >>= fun right ->
      fun rest -> Success (Equivalence (left, right), rest) )
    <|> fun rest -> Success (left, rest) )
    input

let parse_logical_formula s = formula (List.of_seq (String.to_seq s))
