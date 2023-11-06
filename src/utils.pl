memberchk_list([], _, []) :- !.
memberchk_list([X|T], Y, R) :-
    memberchk(X, Y), !,
    memberchk_list(T, Y, R).
memberchk_list([X|T], Y, [X|R]) :-
    subtract(T, Y, R).