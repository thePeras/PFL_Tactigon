display :-
    initial_state(Board),
    display_game(Board).

display_game(Board) :- 
    length(Board, Size),
    MediumLine is integer(Size/2), 
    display_game(Board, 0, MediumLine).
display_game([], _, _).
display_game([H|T], N, MediumLine) :- % Loop pelas linhas da board
    ((N =< MediumLine) -> (left_space(N), display_medium_line(top, H, '   ', ' ')); true),
    ((N =< MediumLine) -> (left_space(N), display_medium_line(top, H, ' ', '     ')); true),
    length(H, LineSize),
    left_space(N), display_cells_name_line(H, -1, N, 1, LineSize), nl,
    left_space(N), display_cells_values_line(H, -1), nl,
    ((N >= MediumLine) -> (left_space(N), display_medium_line(bottom, H, ' ', '     ')); true),
    ((N >= MediumLine) -> (left_space(N), display_medium_line(bottom, H, '   ', ' ')); true),
    NextLine is N + 1,
    display_game(T, NextLine, MediumLine).

left_space(N) :-
    N1 is 6-N,
    write_str_times('    ', N1).

display_medium_line(_, [], _, _) :- nl.
display_medium_line(Mode, [H|T], Margin, Padding) :-
    get_delimiters(Mode, A, B),
    (valid_cell(H) -> C1 = A; C1 = ' '),
    (valid_cell(H) -> C2 = B; C2 = ' '),
    write(Margin),
    write(C1),
    write(Padding),
    write(C2),
    sub_atom(Margin, 0, _, 1, New_Margin),
    write(New_Margin),
    display_medium_line(Mode, T, Margin, Padding).

valid_cell(_-Value) :-
    Value =\= -1.
valid_cell(Value) :-
    Value =\= -1.

get_delimiters(top, A, B) :- A = '/', B = '\\'.
get_delimiters(bottom, A, B) :- A = '\\', B = '/'.

display_cells_name_line([], PreviousValue, _,  _, _) :-
    (valid_cell(PreviousValue) -> C = '|'; C = ' '),
    write(C).
display_cells_name_line([H|T], PreviousValue, N_Line, I_Cell, LineSize) :-
    ((valid_cell(PreviousValue); valid_cell(H)) -> C = '|'; C = ' '),
    write(C),
    write('   '),
    display_cell_name(H, N_Line, I_Cell, LineSize),
    write('  '),
    New_I_Cell is I_Cell + 1,
    display_cells_name_line(T, H, N_Line, New_I_Cell, LineSize).

% name is a number that is 
display_cell_name(-1, _, _, _) :- write('  ').
display_cell_name(_, N_Line, I_Cell, LineSize) :-
    N is N_Line * LineSize + I_Cell - 1, 
    write(N),
    (N > 9 -> write(''); write(' ')).

display_cells_values_line([], PreviousValue) :-
    (valid_cell(PreviousValue) -> C = '|'; C = ' '),
    write(C).
display_cells_values_line([H|T], PreviousValue) :-
    ((valid_cell(PreviousValue); valid_cell(H)) -> C = '|'; C = ' '),
    write(C),
    write('   '),
    display_cell_value(H),
    write('   '),
    display_cells_values_line(T, H).

% Map board values to characters
display_cell_value(-1) :- write(' ').
display_cell_value(0) :- write(' ').
display_cell_value(r-1) :- put_code(9711). %◯
display_cell_value(r-3) :- put_code(9651). %△
display_cell_value(r-4) :- put_code(9723). %◻
display_cell_value(r-5) :- put_code(11040). %⬠
display_cell_value(b-1) :- put_code(9679). %●
display_cell_value(b-3) :- put_code(9650). %▲
display_cell_value(b-4) :- put_code(9724). %◼
display_cell_value(b-5) :- put_code(11039). %⬟
