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
