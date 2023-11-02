play(FirstPlayer, SecondPlayer) :-
    init_state(State, Board),
    play(FirstPlayer, SecondPlayer, State, Board).

init_state(State, Board) :-
    init_board(Board),
    State = init_round.

init_board(Board) :-
    Board = [
        [-1,-1,-1, 0, 0,-1,-1,-1,-1,-1,-1],
        [ 1, 0, 1, 0, 0, 0, 6, 0, 6,-1,-1],
        [ 0, 4, 3, 0, 0, 0, 0, 8, 9, 0,-1],
        [ 1, 3, 5, 4, 1, 0, 6, 9,10, 8, 6],
        [-1, 0, 4, 3, 0, 0, 0, 0, 8,10, 0],
        [-1,-1, 1, 0, 1, 0, 0, 0, 6, 0, 6],
        [-1,-1,-1,-1,-1,-1, 0, 0,-1,-1,-1]
    ].

play(FirstPlayer, SecondPlayer, State, Board) :-
    clear,
    display_game(Board),
    winning_condition(State, Board, Winner),
    !,
    display_winner(Winner),
    menu.

winning_condition(init_round, _, _) :- fail.
winning_condition(red_turn, _, _) :- fail.
winning_condition(State, Board, Winner) :-
    State \= init_round, State \= blue_turn,
    winning_condition(Board, Winner).

winning_condition(Board, Winner) :- 
    write('Checking winning condition!'), nl,
    fail. %Not implemented

play(FirstPlayer, SecondPlayer, State, Board) :-
    display_player_turn(State), %player turn
    get_move(State, Move, Board), %get the piece to be played and the cell to be played
    move(State, Move, NewState),
    play(FirstPlayer, SecondPlayer, NewState, Board).

display_winner(Winner) :-
    write('The winner is: '),
    write(Winner), nl.

display_player_turn(blue_turn) :-
    write('Blue Player turn'), nl.
display_player_turn(State) :-
    write('Red Player turn'), nl.

display_game(Board) :-
    write('Board printed!'), nl.

get_move(State, Move, Board) :-
    get_piece_to_move(State, Board, X, Y, Piece),
    write('You select: '),
    write(Piece), nl,
    get_valid_move(State, Board, X, Y, Piece, Move).
    % Do something with the move
    write('Moved!'), nl.

% This gets the piece to move, validates and verifies if it is from the player
get_piece_to_move(State, Board, X, Y, Piece) :-
    repeat,
    write('Piece to Move:'), nl,
    get_coords(X, Y),
    nth0(X, Board, Row),
    nth0(Y, Row, Piece),
    is_piece_from_player(State, Piece), !.

% This gets the slot to move, validates and verifies if it is valid
get_valid_move(State, Board, X, Y, Piece, Move) :-
    repeat,
    write('Move to:'), nl,
    get_coords(NEXT_X, NEXT_Y),
    nth0(NEXT_X, Board, NEXT_Row),
    nth0(NEXT_Y, NEXT_Row, NEXT_Piece),
    NEXT_Piece >= 0,
    validate_move(X, Y, NEXT_X, NEXT_Y, Board, Piece),
    Move = [X, Y, NEXT_X, NEXT_Y], !.

% Make this
validate_move(X, Y, NEXT_X, NEXT_Y, Board, Counter),
    write('Validating move!'), nl,
    is_occuppied(NEXT_X, NEXT_Y, Board), %break here, change for is not_occuppied
    nth0(X, Board, Row),
    nth0(Y, Row, Piece),
    Counter1 is Counter - 1,
    validate_move(X, Y, NEXT_X, NEXT_Y, Board, Counter1),

is_occuppied(X, Y, Board) :-
    nth0(X, Board, Row),
    nth0(Y, Row, Piece),
    Piece \= 0.

is_piece_from_player(blue_turn, Piece) :-
    Piece > 5,
    Piece < 11.
is_piece_from_player(State, Piece) :-
    Piece > 0,
    Piece < 6.

get_coords(X, Y) :- 
    read_number_until('X: ', is_valid_x_coord, X),
    read_number_until('Y: ', is_valid_y_coord, Y).

is_valid_x_coord(X) :-
    X >= 0,
    X < 7.

is_valid_y_coord(Y) :-
    Y >= 0,
    Y < 11.

move(blue_turn, Move, red_turn) :-
    write('blue moving'), nl.
move(State, Move, blue_turn) :-
    write('red moving'), nl.
