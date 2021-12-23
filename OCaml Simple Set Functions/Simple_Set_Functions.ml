(*
    Function subset
    returns boolean to show if one set is a subset
    of another set

    arguments: a, a set
    b, another set
    returns: a boolean showing if a is a subset of b
*)
let subset a b =
    List.for_all (fun v -> List.exists (fun w -> v = w) b) a

(*
    Function equal_sets
    returns boolean corresponding to set equality

    arguments: a, a set
    b, another set
    returns: a boolean showing if a is an equal set to b
*)
let equal_sets a b =
    subset a b && subset b a

(*
    Function set_union
    returns the union of two sets with their intersection
    counted twice

    arguments: a, a set
    b, another set
    returns: a set corresponding to all elements of
    a and b, with duplicated intersection
*)

let set_union a b = 
    a @ b

(*
    Function set_symdiff
    returns the symmetric difference of two sets

    arguments: a, a set
    b, another set
    returns: a set corresponding to all elements of
    a and b that are not a part of their intersection
*)
let set_symdiff a b =
    List.filter (fun x -> not((List.exists (fun y -> x = y) a) && 
    (List.exists (fun z -> x = z) b))) (set_union a b) 

(*Russell's Paradox*)
(*
I believe this is impossible to program in OCaml:

Since OCaml has rigid type safety, the type of a structure containing
itself would need to be a tuple, but tuples are defined as int * list * string
or whatever types are in order. 
The problem arises in that the type of a set of ints containing itself would
ultimately be int * int * int * int ... and so on ad infinitum; making this
a useless tuple, in that it is just a collection of infinite types.
*)


(*
    Function computed_fixed_point
    returns the fixed point of a function

    arguments: eq, a predicate
    f, a function
    x, a value to test against f(x)
    returns: x, when eq (f (x)) evaluates to true
*)
let rec computed_fixed_point eq f x = 
    match (eq (f x) x) with
       true -> x
    |  false -> computed_fixed_point eq f ( f x )

type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

(*
    Function break_down_symbol
    returns a list containing a symbol

    arguments: x, a symbol
    returns: a list containing a nonterminal or
    an empty list if x is terminal
*)
let break_down_symbol x =
    match x with
      N nonterminal -> [nonterminal]
    | T terminal -> []

(*
    Function normalize_symbols
    returns a list containing only nonterminal symbols

    arguments: x, a list of terminals and nonterminals
    y, an empty list that is built out via recursive calls
    returns: a list containing only nonterminals
*)
let rec normalize_symbols x y =
    match x with
        [] -> y
       | _ -> normalize_symbols (List.tl x) ((set_union (break_down_symbol (List.hd x)) y))

(*
    Function add_reachables
    returns a list containing only reachable symbols

    arguments: g, the grammar list
    h, an empty list that is built out via recursive calls
    returns: a list containing only reachable nonterminals
*)
let rec add_reachables g h =  

    match g with
        [] -> h

       | _ -> 
        let first_in_g = List.hd g in
        let snd_in_g = List.tl g in

        match (subset [fst (first_in_g)] h) with

                true -> add_reachables (snd_in_g) 
                (set_union h ((normalize_symbols (snd (first_in_g)) [])))
                
               | _ -> add_reachables (snd_in_g) h

(*
    Function filter_grammar
    returns the filtered grammar based on reachability

    arguments: g, the grammar list
    x, the list of reachable rules
    returns: a filtered grammar list containing only 
    reachable rules
*)
let filter_grammar g x =
    List.filter (fun y -> List.mem (fst y) x) g

(*
    Function filter_reachable
    returns a starter symbol and filtered grammar

    arguments: g, a starter symbol and grammar list
    returns: the same starter symbol and filtered grammar list
*)
let filter_reachable g =
    let g_rule = fst g in
    let g_list = snd g in
    let good_rules = (computed_fixed_point (equal_sets) 
    (fun x -> (add_reachables g_list x)) ([g_rule])) in

    (g_rule, (filter_grammar g_list good_rules))
