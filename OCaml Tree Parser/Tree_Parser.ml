type ('nonterminal, 'terminal) parse_tree =
  | Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
  | Leaf of 'terminal

type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal;;

(* Converts hw1 style grammar to hw2 style grammar on demand *)
let convert_grammar gram1 =  
   (* Accumulator *)
    let rec accumulate_grammar a g h =
        match g with
            (* Expended possible rules, return accumulated grammar *)
            [] -> List.rev a 
          | hd::tl ->
                (* Check that desired rule for production function matches starter *)
                match (fst hd = h) with
                    (* if so, add to accumulator list *)
                    true -> accumulate_grammar ((snd hd) :: a) tl h
                    (* if not, pass in tail and ignore hd *)
                  | _ -> accumulate_grammar a tl h
    in (fst gram1, (accumulate_grammar [] (snd gram1)))

(* Parses tree to return list of all elements. In essence, un-does tree building *)
let rec parse_tree_leaves = 
    function
      (* If we've reached a leaf, return the leaf *)
      | Leaf terminal -> [terminal]
      (* If we've reached a node, recursively concatenate node branches *)
      | Node (nonterminal,(l::r)) -> (parse_tree_leaves l) @ (parse_tree_leaves (Node (nonterminal,r)))
      (* If we created empty node in second case, just return an empty list to do nothing *)
      | Node (_, []) -> []


(* given functions *)
let match_empty accept frag = accept frag

let match_nothing accept frag = None


(* define mutually recursive make_or_matcher and make_appended_matchers *)

let rec make_or_matcher prod_func rules accept frag = match rules with
  (* if we've reached the end of our current list of grammar rules, we ran out of options, match_nothing*)
  | [] -> match_nothing accept frag
  (* check each grammar rule *)
  | head::tail ->
      match (make_appended_matchers prod_func head accept frag) with
            (* if nested matchers could not match our frag with appropriate rules, fall into next list of rules *)
            | None -> make_or_matcher (prod_func) (tail) accept frag
            (* if nested matchers could match our frag with appropriate rules, return result *)
            | Some x -> Some x

and make_appended_matchers prod_func rule accept frag = match rule with
    (* if we've appended all the matchers for all the rules, pass frag into acceptor *)
    | [] -> accept frag
    (* if we have not yet appended all the matchers *)
    | head::tail -> match head with
        (* if our rule is a non-terminal rule *)
        | N nonterminal -> 
            (* continue to append matchers (nest them) via additional or call *)
            let append_matchers = fun smaller_frag -> (make_appended_matchers prod_func tail accept smaller_frag) in
            make_or_matcher prod_func (prod_func nonterminal) append_matchers frag
        (* if our rules is a terminal rule *)
        | T terminal -> 
            (* make sure our terminal rule matches with our fragment *)
            match frag with
                [] -> None
                (* if we did find a match, continue to make appended matches with the rest of the fragment, else 
                   return None for negative result *)
              | r::gr -> if r = terminal then make_appended_matchers prod_func tail accept gr else None    

(* feeder function to forward our grammar into our first make_or_matcher call *)
let make_matcher = function
  | (start, prod_func) -> fun accept frag -> make_or_matcher prod_func (prod_func start) accept frag
  

(* define mutually recursive make_or_parser and make_appended_parsers *)

let rec make_or_parser prod_func rule accept frag first_rule = match rule with
  (* if we've reached the end of our current list of grammar rules, we ran out of options, match_nothing*)  
  | [] -> match_nothing accept frag
  (* check each grammar rule *)
  | head::tail ->
      match (make_appended_parsers prod_func head accept frag first_rule []) with
            (* if nested matchers could not match our frag with appropriate rules, fall into next list of rules *)
            | None -> make_or_parser (prod_func) (tail) accept frag first_rule
            (* if nested matchers could match our frag with appropriate rules, return result *)
            | Some x -> Some x

and make_appended_parsers prod_func rule accept frag first_rule node = match rule with
    (* if we've appended all the matchers for all the rules, pass frag into acceptor and forward our root node *)
    | [] -> accept frag (Node(first_rule,node))
    (* if we have not yet appended all the matchers *)
    | head::tail -> match head with
        (* if our rule is a nonterminal rule *)
        | N nonterminal -> 
            (* continue to append matchers (nest them) via additional or call *)
            let append_parsers = fun smaller_frag next_node-> (make_appended_parsers prod_func tail accept smaller_frag first_rule (node @ [next_node])) in
            make_or_parser prod_func (prod_func nonterminal) append_parsers frag nonterminal
        (* if our rule is a terminal rule *)
        | T terminal -> 
            match frag with
                [] -> None
                  (* if we did find a match, continue to make appended matches with the rest of the fragment and create a 
                    leaf from the terminal, else return None for negative result *)
              | r::gr -> if r = terminal then make_appended_parsers prod_func tail accept gr first_rule (node @ [Leaf terminal]) else None  


(* new acceptor to forward our tree *)
let accept_complete_tree frag node = match frag with
   | [] -> Some node
   | _ -> None

(* feeder function to forward our grammar into our first make_or_parser call *)
let make_parser = function
  | (start, prod_func) -> fun frag -> make_or_parser prod_func (prod_func start) accept_complete_tree frag start


  