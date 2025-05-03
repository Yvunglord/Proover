(** Type for input data *)
type input_data = char list

(** Type for parser results *)
type 'a parse_result =
  | Fail
  | Success of 'a * input_data

(** Type for parsers *)
type 'a parser = input_data -> 'a parse_result

(** Type for logical formulas *)
type logical_formula =
  | Variable of string
  | Negation of logical_formula
  | Conjunction of logical_formula * logical_formula
  | Disjunction of logical_formula * logical_formula
  | Implication of logical_formula * logical_formula
  | Equivalence of logical_formula * logical_formula

(** Parser combinators *)
val ( >>= ) : 'a parser -> ('a -> 'b parser) -> 'b parser
val ( *> ) : 'a parser -> 'b parser -> 'b parser
val ( <* ) : 'a parser -> 'b parser -> 'a parser
val ( <|> ) : 'a parser -> 'a parser -> 'a parser

(** Basic parsers *)
val char : char -> char parser
val string : input_data -> input_data parser

(** Parser for variables *)
val variable_parser : logical_formula parser

(** Parser for logical formulas *)
val parse_logical_formula : string -> logical_formula parse_result
