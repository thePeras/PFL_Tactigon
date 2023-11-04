
display :-
    init_board(Board),
    display_board(Board).

display_board(Board) :- 
    length(Board, Size),
    MediumLine is integer(Size/2), 
    display_board(Board, 0, MediumLine).
display_board([], _, _).
display_board([H|T], N, MediumLine) :- % Loop pelas linhas da board
    ((N =< MediumLine) -> (left_space(N), display_medium_line(top, H, '   ', ' ')); true),
    ((N =< MediumLine) -> (left_space(N), display_medium_line(top, H, ' ', '     ')); true),
    length(H, LineSize),
    left_space(N), display_cells_name_line(H, -1, N, 1, LineSize), nl,
    left_space(N), display_cells_values_line(H, -1), nl,
    ((N >= MediumLine) -> (left_space(N), display_medium_line(bottom, H, ' ', '     ')); true),
    ((N >= MediumLine) -> (left_space(N), display_medium_line(bottom, H, '   ', ' ')); true),
    NextLine is N + 1,
    display_board(T, NextLine).

left_space(N) :-
    N1 is 6-N,
    write_str_times('    ', N1).

display_medium_line(_, [], _, _) :- nl.
display_medium_line(Mode, [H|T], Margin, Padding) :-
    get_delimiters(Mode, A, B),
    ((H >= 0) -> C1 = A; C1 = ' '),
    ((H >= 0) -> C2 = B; C2 = ' '),
    write(Margin),
    write(C1),
    write(Padding),
    write(C2),
    sub_atom(Margin, 0, _, 1, New_Margin),
    write(New_Margin),
    display_medium_line(Mode, T, Margin, Padding).

get_delimiters(top, A, B) :- A = '/', B = '\\'.
get_delimiters(bottom, A, B) :- A = '\\', B = '/'.

display_cells_name_line([], PreviousValue, _,  _, _) :-
    ((PreviousValue >= 0) -> C = '|'; C = ' '),
    write(C).
display_cells_name_line([H|T], PreviousValue, N_Line, I_Cell, LineSize) :-
    ((PreviousValue >= 0; H >= 0) -> C = '|'; C = ' '),
    write(C),
    write('   '),
    display_cell_name(H, N_Line, I_Cell),
    write('  '),
    New_I_Cell is I_Cell + 1,
    display_cells_name_line(T, H, N_Line, New_I_Cell).

% name is a number that is 
display_cell_name(-1, _, _, _) :- write('  ').
display_cell_name(_, N_Line, I_Cell, LineSize) :-
    N is N_Line * LineSize + I_Cell, 
    write(N),
    (N > 9 -> write(''); write(' ')).

display_cells_values_line([], PreviousValue) :-
    ((PreviousValue >= 0) -> C = '|'; C = ' '),
    write(C).
display_cells_values_line([H|T], PreviousValue) :-
    ((PreviousValue >= 0; H >= 0) -> C = '|'; C = ' '),
    write(C),
    write('   '),
    display_cell_value(H),
    write('   '),
    display_cells_values_line(T, H).

% Map board values to characters
display_cell_value(-1) :- write(' ').
display_cell_value(0) :- write(' ').
display_cell_value(1) :- put_code(9711). %◯
display_cell_value(3) :- put_code(9651). %△
display_cell_value(4) :- put_code(9723). %◻
display_cell_value(5) :- put_code(11040). %⬠
display_cell_value(6) :- put_code(9679). %●
display_cell_value(8) :- put_code(9650). %▲
display_cell_value(9) :- put_code(9724). %◼
display_cell_value(10) :- put_code(11039). %⬟
