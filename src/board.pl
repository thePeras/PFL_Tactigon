% display_game(+Board)
% Displays the board.
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

% left_space(+N)
% Writes N spaces to the left.
left_space(N) :-
    N1 is 6-N,
    write_str_times('    ', N1).

% display_medium_line(+Mode, +Line, +Margin, +Padding)
% Displays medium line of the board.
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

% valid_cell(+Value)
% Checks if a cell is valid.
valid_cell(_-Value) :-
    Value =\= -1.
valid_cell(Value) :-
    Value =\= -1.

% get_delimiters(+Mode, -A, -B)
% Gets the delimiters for the board.
get_delimiters(top, A, B) :- A = '/', B = '\\'.
get_delimiters(bottom, A, B) :- A = '\\', B = '/'.

% display_cells_name_line(+Line, +PreviousValue, +N_Line, +I_Cell, +LineSize)
% Displays the name of the cells.
display_cells_name_line([], PreviousValue, _,  _, _) :-
    (valid_cell(PreviousValue) -> C = '|'; C = ' '),
    write(C).
display_cells_name_line([H|T], PreviousValue, N_Line, I_Cell, LineSize) :-
    ((valid_cell(PreviousValue); valid_cell(H)) -> C = '|'; C = ' '),
    write(C),
    colored_golden_cell(N_Line, I_Cell, LineSize),
    write('   '),
    display_cell_name(H, N_Line, I_Cell, LineSize),
    write('  \e[0m'),
    New_I_Cell is I_Cell + 1,
    display_cells_name_line(T, H, N_Line, New_I_Cell, LineSize).

% display_cell_name(+Value, +N_Line, +I_Cell, +LineSize)
% Displays the name of a cell.
display_cell_name(-1, _, _, _) :- write('  ').
display_cell_name(_, N_Line, I_Cell, LineSize) :-
    N is N_Line * LineSize + I_Cell - 1, 
    write(N),
    (N > 9 -> write(''); write(' ')).

% display_cells_values_line(+Line, +PreviousValue)
% Displays the values of the cells.
display_cells_values_line([], PreviousValue) :-
    (valid_cell(PreviousValue) -> C = '|'; C = ' '),
    write(C).
display_cells_values_line([H|T], PreviousValue) :-
    ((valid_cell(PreviousValue); valid_cell(H)) -> C = '|'; C = ' '),
    write(C),
    write('   '),
    change_color(H),
    display_cell_value(H),
    reset_color,
    write('   '),
    display_cells_values_line(T, H).

% change_color(+Value)
% Changes the color of the output.
change_color(b-_) :- write('\e[34m').
change_color(r-_) :- write('\e[31m').
change_color(_) :- write('\e[0m').
reset_color :- write('\e[0m').

% display_cell_value(+Value)
% Maps the value of a cell to a character.
display_cell_value(-1) :- write(' ').
display_cell_value(0) :- write(' ').
display_cell_value(_-1) :- put_code(9679). %●
display_cell_value(_-3) :- put_code(9650). %▲
display_cell_value(_-4) :- put_code(9724). %◼
display_cell_value(_-5) :- put_code(11039). %⬟

% colored_golden_cell(+N_Line, +I_Cell, +LineSize)
% Colors the golden cells.
colored_golden_cell(N_Line, I_Cell, LineSize) :-
    (N_Line =\= 1, N_Line =\= 5) -> true;
    Medium is integer(LineSize/2),
    (N_Line =:= 5 -> Medium2 is Medium + 2; Medium2 is Medium),
    (I_Cell =:= Medium2 -> write('\e[33m'); write('\e[0m')).


% board(+BoardType, -Board)
board(1,[
        [-1,-1,-1,0,0,-1,-1,-1,-1,-1,-1],
        [r-1,0,r-1,0,0,0,b-1,0,b-1,-1,-1],
        [0,r-4,r-3,0,0,0,0,b-3,b-4,0,-1],
        [r-1,r-3,r-5,r-4,r-1,0,b-1,b-4,b-5,b-3,b-1],
        [-1,0,r-4,r-3,0,0,0,0,b-3,b-4,0],
        [-1,-1,r-1,0,r-1,0,0,0,b-1,0,b-1],
        [-1,-1,-1,-1,-1,-1,0,0,-1,-1,-1]
]).

board(2,[
        [-1,-1,-1,0,0,-1,-1,-1,-1,-1,-1],
        [-1,0,r-1,0,0,0,b-1,0,-1,-1,-1],
        [-1,r-4,r-3,0,0,0,0,b-3,b-4,-1,-1],
        [-1,r-3,r-5,r-4,r-1,0,b-1,b-4,b-5,b-3,-1],
        [-1,-1,r-4,r-3,0,0,0,0,b-3,b-4,-1],
        [-1,-1,-1,0,r-1,0,0,0,b-1,0,-1],
        [-1,-1,-1,-1,-1,-1,0,0,-1,-1,-1]
    ]).

board(3,[
        [-1,-1,-1,0,0,-1,-1,-1,-1,-1,-1],
        [-1,-1,-1,0,0,0,-1,-1,-1,-1,-1],
        [-1,-1,r-3,0,0,0,0,b-3,-1,-1,-1],
        [-1,-1,r-5,r-4,r-1,0,b-1,b-4,b-5,-1,-1],
        [-1,-1,-1,r-3,0,0,0,0,b-3,-1,-1],
        [-1,-1,-1,-1,-1,0,0,0,-1,-1,-1],
        [-1,-1,-1,-1,-1,-1,0,0,-1,-1,-1]
    ]).

% For testing purposes and also for the presentation
board(intermediary, [
        [-1,-1,-1,0,0,-1,-1,-1,-1,-1,-1],
        [r-1,0,r-1,0,0,0,b-1,0,b-1,-1,-1],
        [0,r-4,r-3,0,0,0,0,b-3,b-4,0,-1],
        [r-1,r-3,r-5,0,r-1,b-4,0,0,b-5,b-3,b-1],
        [-1,0,r-4,r-3,0,r-4,b-1,0,0,b-4,0],
        [-1,-1,r-1,0,r-1,0,b-3,0,b-1,0,b-1],
        [-1,-1,-1,-1,-1,-1,0,0,-1,-1,-1]
]).

board(final,[
        [-1,-1,-1,0,0,-1,-1,-1,-1,-1,-1],
        [r-1,0,r-1,0,r-3,0,b-1,0,b-1,-1,-1],
        [0,r-4,0,0,0,0,0,b-3,b-4,0,-1],
        [r-1,r-3,r-5,0,r-1,0,b-1,b-4,0,b-3,b-1],
        [-1,0,r-4,r-3,0,b-5,0,0,b-3,b-4,0],
        [-1,-1,r-1,0,r-1,r-4,0,0,b-1,0,b-1],
        [-1,-1,-1,-1,-1,-1,0,0,-1,-1,-1]
]).

