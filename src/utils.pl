% memberchk_list(+List1, +List2, -Result)
% Removes all elements from List1 that are not present in List2 and returns the result in Result.
memberchk_list([], _, []) :- !.
memberchk_list([X|T], Y, R) :-
    memberchk(X, Y), !,
    memberchk_list(T, Y, R).
memberchk_list([X|T], Y, [X|R]) :-
    memberchk_list(T, Y, R).

% replace_element(+List, +Column, +Value, -NewList)
% Replaces the element at column Column with Value in List and returns the result in NewList.
replace_element([], _, _, []).
replace_element([_|T], 0, Value, [Value|T]):- !.
replace_element([H|T], Col, Value, [H|NewT]):-
    NewCol is Col - 1,
    replace_element(T, NewCol, Value, NewT). 

% replace_board_value(+Board, +X, +Y, +Value, -NewBoard)
% Replaces the element at position (X, Y) with Value in Board and returns the result in NewBoard.
replace_board_value([], _, _, _, []). % base case

replace_board_value([Row|T], 0, Y, Value, [NewRow|T]):-
    !,
    replace_element(Row, Y, Value, NewRow).

% Recursive case: Keep traversing rows until we reach row X
replace_board_value([Row|T], X, Y, Value, [Row|NewT]):-
    NewX is X - 1,
    replace_board_value(T, NewX, Y, Value, NewT).

% write_str_times(+Str, +N)
% Writes a string N times.
write_str_times(_, -1) :- !.
write_str_times(_, 0).
write_str_times(Str, N) :- 
    write(Str), 
    N1 is N - 1, 
    write_str_times(Str, N1).

% write_str(+Str)
% Writes a string.
write_str("").
write_str([Code | T]) :- char_code(Char, Code), write(Char), write_str(T).

% write_lines(+ListOfStrings)
% Writes a list of strings.
write_lines([]).
write_lines([H|T]) :- write_str(H), nl, write_lines(T).

% clear\0
% Clears the screen.
clear :- write_str("\e[2J").

% read_number_until(+Prompt, +Condition, -Out)
% Reads a number from the user until the condition is met.
read_number_until(Prompt, Condition, Out) :-
    repeat,
    write(Prompt),
    read_number(Out),
    call(Condition, Out), !.

% read_number(+Out)
% Reads a number from the user.
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

read_number(_, _):-
    skip_line, !, fail.

% wait_for_enter\0
% Waits for the user to press enter.
wait_for_enter :-
    write('Press Enter to continue'), nl,
    get_char(_).

% change_player(?Player, ?OtherPlayer)
% Changes the player.
change_player(r, b).
change_player(b, r).