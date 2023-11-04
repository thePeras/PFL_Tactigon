:- use_module(library(lists)).

play_game(RedPlayer-BluePlayer) :-
    clear,
    initial_state(Board),
    /*
    init_
    blue_turn
    */
    display_game(Board),
    game_cycle(RedPlayer-BluePlayer, State, Board).
    /*
        bot random
        bot greedy
    */

initial_state(Board) :-
    Board = [
        [-1,-1,-1,0,0,-1,-1,-1,-1,-1,-1],
        [r-1,0,r-1,0,0,0,b-1,0,b-1,-1,-1],
        [0,r-4,r-3,0,0,0,0,b-3,b-4,0,-1],
        [r-1,r-3,r-5,r-4,r-1,0,b-1,b-4,b-5,b-3,b-1],
        [-1,0,r-4,r-3,0,0,0,0,b-3,b-4,0],
        [-1,-1,r-1,0,r-1,0,0,0,b-1,0,b-1],
        [-1,-1,-1,-1,-1,-1,0,0,-1,-1,-1]
    ].

get_piece(X, Y, Board, Piece) :-
    nth0(X, Board, Row),
    nth0(Y, Row, Piece).

valid_position(X, Y, Board, Piece) :-
    get_piece(X,Y, Board, Piece),
    Piece \= -1.

valid_piece(X, Y, Board, Player-Piece) :-
    valid_position(X, Y, Board, Player-Piece),
    nth0(X, Board, Row),
    nth0(Y, Row, Player-Piece).

game_cycle(RedPlayer-BluePlayer, State, Board) :-
    game_over(GameState-Player, Winner),
    !,
    congratulate(Winner).

game_cycle(RedPlayer-BluePlayer, State, Board) :-
    choose_move(GameState, Player, Move),
    move(GameState, Move, NewGameState),
    next_player(Player, NextPlayer),
    display_game(NewGameState-NextPlayer),
    !,
    game_cycle(NewGameState-NextPlayer).


captured(_, []).
captured(Piece, [Row | Rest]) :-
    \+ memberchk(Piece, Row),
    eaten(Piece, Rest).

win_pentagon_captured(Board, b) :-
    captured(r-5, Board).
win_pentagon_captured(Board, r) :-
    captured(b-5, Board).

win_gold_tiles(b-Board, b) :-
    get_piece(1,4, Board, b-_),
    get_piece(5,6, Board, b-_).
win_gold_tiles(r-Board, r) :-
    get_piece(1,4, Board, r-_),
    get_piece(5,6, Board, r-_).


game_over(_-Board, Winner) :-
    win_pentagon_captured(Board, Winner).
game_over(Player-Board, Winner) :-
    win_gold_tiles(Player-Board, Winner).

combat(Player-_, Player-_, _) :-
    write('You can\'t attack your own pieces!'), nl,
    fail.
combat(Player, 0, Player) :-
    write('You can\'t attack an empty tile!'), nl,
    fail.

combat(Player1-AttackerPiece, Player2-AttackedPiece, Player1-AttackerPiece) :-
    AttackerPiece =< AttackedPiece,
    !.

combat(_-3, _-1, 0).
combat(_-4, _-3, 0).

neighboursOffSet([(0, -1), (0, 1), (-1, 1), (-1, 0), (1, 1), (1, 0)]).
get_neighbours(Xi, Yi, Player-Piece, Board, Neighbours) :-
    neighboursOffSet(OffSet),
    get_neighbours(Xi, Yi, Player-Piece, Board, OffSet, Neighbours).

get_neighbours(_,_,_,_,[],[]). % caso base
get_neighbours(Xi, Yi, Player-Piece, Board, [(Xs, Ys) | Rest], [(Xf, Yf) | OtherNeighbours]) :-
    Xf is Xi + Xs,
    Yf is Yi + Ys,
    valid_position(Xf, Yf, Board, _),
    !,
    get_neighbours(Xi, Yi, Player-Piece, Board, Rest, OtherNeighbours).

% if position not valid
get_neighbours(Xi, Yi, Player-Piece, Board, [(_, _) | Rest], OtherNeighbours) :-
    get_neighbours(Xi, Yi, Player-Piece, Board, Rest, OtherNeighbours).

% filter_moves(+AttackerPiece, +Moves, +Board, -PossibleMoves)
filter_moves(_, [], _, []).
filter_moves(Player-Piece, [(X, Y | Rest)], Board, [(X, Y) | FilteredMoves]) :- % valid move added to queue 
    get_piece(X, Y, Board, Value),
    combat(Player-Piece, Value, _),
    !,
    filter_moves(Player-Piece, Rest, Board, FilteredMoves).

filter_moves(Player-Piece, [(_,_) | Rest], Board, FilteredMoves):-
    filter_moves(Player-Piece, Rest, Board, FilteredMoves).

% create tuple with position and distance
add_distance([],_,[]).
add_distance(Moves, Distance, MovesWithDistance) :-
    add_distance([(X,Y) | Rest], Distance, [(X,Y,Distance) | RestDist]),
    add_distance(Rest, Distance, RestDist).


bfs_moves(_,_,_,_,[],_,[]). % no more moves
bfs_moves(_,_,_,MaxMoves, [(_,_,MaxMoves) | _], _, []) :- !. % max Moves reached
bfs_moves(Piece, Player, Board, MaxMoves, [(X,Y,Distance) | Rest], Visited, ListOfMoves) :- 
    Distance < MaxMoves,
    NewDistance is Distance + 1,
    get_neighbours(X, Y, Player-Piece, Board, AllMoves), % includes invalid moves
    filter_moves(Player-Piece, AllMoves, Board, ValidMoves),
    memberchk_list(ValidMoves, Visited, UnVisitedMoves),






/* 
Asks the user for a cell number and returns the coordinates and value of the cell
get_cell(+Board, -X, -Y, -Value) */
get_cell(Board, X, Y, Value) :- 
    repeat,
    write('Enter cell number: '),
    read_number(N),
    is_valid_cell(N, Board, Value, X, Y), !.

is_valid_cell(N, Board, Value, X, Y) :-
    nth0(0, Board, FirstLine),
    length(FirstLine, LineSize),
    X is N // LineSize,
    Y is N mod LineSize,
    nth0(X, Board, Line), 
    nth0(Y, Line, Value),
    Value \= -1.

/*
choose_move(GameState, human, Move) :-
    write('Choose a move: '), nl.

choose_move(GameState, computer-Level, Move) :-
    valid_moves(GameState, Moves),
    choose_move(Level, GameState, Moves, Move).

valid_moves(GameState, Moves) :-
    findall(Move, move(GameState, Move, NewState)), Moves).

choose_move(1, _GameState, Moves, Move) :-
    random_select(Move, Moves, _Rest).

choose_move(2, GameState, Moves, Move) :-
    setof(Value-Mv, NewState^(member(Mv, Moves), move(GameState, Mv, NewState), evaluate_board(NewState, Value)), [_V-Move | _]).*/


/*find_pentagon(Board, X, Y) :-
    get_piece(X, Y, Board, r-5),
    !.

find_pentagon(Board, X, Y) :-
    get_piece(X, Y, Board, b-5),
    !.



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
*/
