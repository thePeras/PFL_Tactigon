memberchk_list([], _, []) :- !.
memberchk_list([X|T], Y, R) :-
    memberchk(X, Y), !,
    memberchk_list(T, Y, R).
memberchk_list([X|T], Y, [X|R]) :-
    memberchk_list(T, Y, R).


% Helper function to replace an element at a specific position in a list
% replace_element(+List, +Column, +Value, -NewList)
replace_element([], _, _, []).
replace_element([_|T], 0, Value, [Value|T]):- !.
replace_element([H|T], Col, Value, [H|NewT]):-
    NewCol is Col - 1,
    replace_element(T, NewCol, Value, NewT). 

replace_board_value([], _, _, _, []).

% we reached row X, so replace the element at column Y
replace_board_value([Row|T], 0, Y, Value, [NewRow|T]):-
    !,
    replace_element(Row, Y, Value, NewRow).

% Recursive case: Keep traversing rows until we reach row X
replace_board_value([Row|T], X, Y, Value, [Row|NewT]):-
    NewX is X - 1,
    replace_board_value(T, NewX, Y, Value, NewT).



write_str_times(_, -1) :- !.
write_str_times(_, 0).
write_str_times(Str, N) :- 
    write(Str), 
    N1 is N - 1, 
    write_str_times(Str, N1).

write_str("").
write_str([Code | T]) :- char_code(Char, Code), write(Char), write_str(T).

write_lines([]).
write_lines([H|T]) :- write_str(H), nl, write_lines(T).

clear :- write_str("\e[2J").

read_number_until(Prompt, Condition, Out) :-
    repeat,
    write(Prompt),
    read_number(Out),
    call(Condition, Out), !.

read_number(X) :- read_number(0, X).
read_number(X, X) :- 
    peek_code(10), 
    get_code(10), !.
read_number(Curr, Out) :-
    get_code(C),
    C >= 48,
    C =< 57,
    NewCurr is Curr * 10 + (C - 48),
    read_number(NewCurr, Out).
