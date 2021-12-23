%%%%
%
% finite domain kenken:
%
%%%%

% fd_prod_list is true when each H in a given list is constrained to produce 
% Prod
fd_prod_list([H],H).
fd_prod_list([H|T],Prod) :- fd_prod_list(T,Rest), Prod #= H * Rest.

% fd_prod_list is true when each H in a given list is constrained to add to Sum
fd_add_list([H],H).
fd_add_list([H|T],Sum) :- fd_add_list(T,Rest), Sum #= H + Rest.

% val_acc is true when a list of coordinates is exhausted and V is filled 
% with values in Og, the original matrix. 
val_acc([],_,A,A).
val_acc([ [H|Tl] | T ],Og,A,R) :- nth(H, Og, V), 
    nth(Tl,V,X),
    val_acc(T,Og,[X|A],R). 

% multiplication variant of fd_line_constraint; returns true when
% all elements of L2 are constrained to produce S.
fd_line_constraint(L1,*(S,L2)) :-
    val_acc(L2,L1,[],A),
    fd_prod_list(A, S).
    
% addition variant of fd_line_constraint; returns true when
% all elements of L2 are constrained to sum to S.
fd_line_constraint(L1,+(S,L2)) :-
    val_acc(L2,L1,[],A),
    fd_add_list(A, S).

% subtraction variant of fd_line_constraint; returns true when
% elements in L1 corresponding to (Hj,Tj) and (Hk, Tk) 
% are constrained to subtract to S.
fd_line_constraint(L1,-(D, [Hj | Tj], [Hk | Tk])) :-
    nth(Hj, L1, V), nth(Tj,V,X),
    nth(Hk, L1, W), nth(Tk,W,Y),
    (D #= X - Y; D #= Y - X).

% division variant of fd_line_constraint; returns true when
% elements in L1 corresponding to (Hj,Tj) and (Hk, Tk) 
% are constrained to equal each other when D is 1 or are constrained 
% to divide to D.
fd_line_constraint(L1,/(D, [Hj | Tj], [Hk | Tk])) :-
    nth(Hj, L1, V), nth(Tj,V,X),
    nth(Hk, L1, W), nth(Tk,W,Y),
    (((Y #= X), D is 1) ; ((D * X #= Y; D * Y #= X), D=\=1)).

% recurse_list2 returns true when it is passed an empty list or
% it has exhausted all elements of a list by placing constraints 
% on each.
recurse_list2([],_).
recurse_list2([H|T],N) :- 
    length(H,N),
    fd_domain(H,1,N),
    fd_all_different(H),
    recurse_list2(T,N).

% recurse_list1 returns true when it is passed an empty list or
% it has exhausted all elements of a list by realizing constrained variables
% within each.
recurse_list1([]).
recurse_list1([H|T]) :-
    fd_labeling(H),
    recurse_list1(T).



% taken from https://stackoverflow.com/questions/4280986/how-to-transpose-a-matrix-in-prolog
transpose([], []).
transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).
transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
        lists_firsts_rests(Ms, Ts, Ms1),
        transpose(Rs, Ms1, Tss).
lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
        lists_firsts_rests(Rest, Fs, Oss).

% kenken returns true when passed a list T with length N
% which abides by the constraints list C.
kenken(N,C,T) :- 
    length(T,N),
    recurse_list2(T,N),
    transpose(T, R),
    recurse_list2(R,N),
    maplist(fd_line_constraint(T), C),
    recurse_list1(T).


% Some testcases for kenken:
kenken_testcase(
  6,
  [
   +(11, [[1|1], [2|1]]),
   /(2, [1|2], [1|3]),
   *(20, [[1|4], [2|4]]),
   *(6, [[1|5], [1|6], [2|6], [3|6]]),
   -(3, [2|2], [2|3]),
   /(3, [2|5], [3|5]),
   *(240, [[3|1], [3|2], [4|1], [4|2]]),
   *(6, [[3|3], [3|4]]),
   *(6, [[4|3], [5|3]]),
   +(7, [[4|4], [5|4], [5|5]]),
   *(30, [[4|5], [4|6]]),
   *(6, [[5|1], [5|2]]),
   +(9, [[5|6], [6|6]]),
   +(8, [[6|1], [6|2], [6|3]]),
   /(2, [6|4], [6|5])
  ]
).

kenken_mincase(
  2,
  [
   -(1, [1|2], [2|2]),
   -(1, [1|1], [2|1])
  ]
).

kenken_divcase(
  2,
  [
   /(2, [1|1], [2|1]),
   /(2, [1|2], [2|2])
  ]
).

%%%%
%
% plain kenken:
%
%%%%

% prod_list is true when each H in a given list evaluates via
% production to Prod.
prod_list([H],H).
prod_list([H|T],Prod) :- prod_list(T,Rest), Prod is H * Rest.

% add_list is true when each H in a given list evaluates via
% summation to Sum.
add_list([H],H).
add_list([H|T],Sum) :- add_list(T,Rest), Sum is H + Rest.

% multiplication variant of line_constraint; returns true when
% all elements of L2 produce S.
line_constraint(L1,*(S,L2)) :-
    val_acc(L2,L1,[],A),
    prod_list(A, S).
    
% addition variant of line_constraint; returns true when
% all elements of L2 sum to S.
line_constraint(L1,+(S,L2)) :-
    val_acc(L2,L1,[],A),
    add_list(A, S).

% subtraction variant of line_constraint; returns true when
% elements in L1 corresponding to (Hj,Tj) and (Hk, Tk) 
% subtract to S.
line_constraint(L1,-(D, [Hj | Tj], [Hk | Tk])) :-
    nth(Hj, L1, V), nth(Tj,V,X),
    nth(Hk, L1, W), nth(Tk,W,Y),
    (D is X - Y; D is Y - X).

% division variant of line_constraint; returns true when
% elements in L1 corresponding to (Hj,Tj) and (Hk, Tk) 
% equal each other when D is 1 or divide to D.
line_constraint(L1,/(D, [Hj | Tj], [Hk | Tk])) :-
    nth(Hj, L1, V), nth(Tj,V,X),
    nth(Hk, L1, W), nth(Tk,W,Y),
    (((Y is X), D is 1) ; ((Y is D*X ; X is D*Y), D =\= 1)).


%taken from https://stackoverflow.com/questions/10202666/prolog-create-a-list
do_list(N,L) :- findall(Num,between(1,N,Num),L).

% plain_recurse_list returns true when it is passed an empty list or
% it has exhausted all elements of a list by permuting each and setting
% lenghts on each.
plain_recurse_list([],_).
plain_recurse_list([H|T],N) :- 
    length(H,N),
    do_list(N,L),
    permutation(L,H),
    plain_recurse_list(T,N).

% plain_kenken returns true when passed a list T with length N
% which abides by the constraints list C.
plain_kenken(N,C,T) :- 
    length(T,N),
    plain_recurse_list(T,N),
    transpose(T, R),
    plain_recurse_list(R,N),
    maplist(line_constraint(T), C),
    recurse_list1(T).

% Statistics:
%
%    ?- statistics(cpu_time,[Start|_]), kenken(4, [
%           +(6, [[1|1], [1|2], [2|1]]),
%           *(96, [[1|3], [1|4], [2|2], [2|3], [2|4]]),
%           -(1, [3|1], [3|2]),-(1, [4|1], [4|2]),
%           +(8, [[3|3], [4|3], [4|4]]),*(2, [[3|4]])],T), 
%           write(T), nl,     
%           statistics(cpu_time, [End|_]), 
%           Cputime is End-Start,write(Cputime),
%           fail.
%
%    This command was run twice in order to test the efficiency
%    of plain_kenken vs kenken (replacing kenken with plain_kenken
%    for the former). 
%    
%    The results for kenken were excellent, where my CPU was able to
%    complete the request for T in under 16 CPU cycles for the 6x6.
%    plain_kenken was unable to complete the 6x6 in under 30 seconds,
%    but the 4x4 testcases took an average of ~80 CPU cycles each, as
%    compared to under 16 for kenken. 


% no-op kenken API:
% first we define our testcase:

noop_kenken_testcase(
  5,
  [
   (2, [[1|1]]),
   (38, [[1|2], [1|3], [1|4], [2|2], [3|2], [3|3], [3|4], [4|4], [5|4], [5|3],[5|2]]),
   (24, [[1|5], [2|5],[2|4],2|3]),
   (9, [[3|5], [4|5], [5|5]]),
   (1, [4|3]),
   (6, [[1|2], [1|3]]),
   (6, [[4|1], [4|2]]),
   (4, [[1|5]])
  ]
).

% Template:
%
% noop_kenken(N,C,T,S)
%
% Description:
% noop_kenken succeeds if length(T,N) succeeds, and S unifies with an operation
% constraint list.
% N,C are defined by the testcase, where C is our no-operation constraints list.
%
% The GNU Prolog REPL will respond with a filled T, echoing your N and C,
% and S = Cn, where Cn is a new constraints list of the standard kenken format. 
%
% example call: | ?- fd_set_vector_max(255), 
%               |       noop_kenken_testcase(N,C), noop_kenken(N,C,T,S).

