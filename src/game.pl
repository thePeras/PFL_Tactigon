% play_game(+ChosenLevels)
% Starts the game with the chosen levels
play_game(ChosenLevels) :-
    clear,
    choose_board(Type),
    clear,
    initial_state(Type, Board),
    display_game(Board),
    game_cycle(r-Board, ChosenLevels).

% initial_state(+Type, -Board)
% Returns the initial state of the game
initial_state(Type, Board) :-
    board(Type, Board).

/*
** Auxiliary Functions
*/

% get_piece(+X, +Y, +Board, -Piece)
% Returns the piece at position (X, Y) in Board
get_piece(X, Y, Board, Piece) :-
    nth0(X, Board, Row),
    nth0(Y, Row, Piece).

% valid_position(+X, +Y, +Board, -Piece)
% Checks if the position (X, Y) is valid in Board and returns the piece in that position
valid_position(X, Y, Board, Piece) :-
    get_piece(X,Y, Board, Piece),
    Piece \= -1.

% valid_piece(+X, +Y, +Board, -Piece)
% Checks if the Piece at position (X, Y) is valid in Board
valid_piece(X, Y, Board, Player-Piece) :-
    valid_position(X, Y, Board, Player-Piece),
    nth0(X, Board, Row),
    nth0(Y, Row, Player-Piece).

% select_cell(+Board, +Player, -X, -Y, -Value)
% Asks the user for a cell number and returns the coordinates and value of the cell
select_cell(Board, Player, X, Y,Value) :-
    write('Which piece do you wish to move? '), nl,
    get_cell(Board, X, Y, Value),
    valid_piece(X, Y, Board, Player-_),
    !.
select_cell(Board, Player, X, Y,Value) :-
    write('Invalid cell!'), nl,
    select_cell(Board, Player, X, Y,Value).
    
% get_cell(+Board, -X, -Y, -Value)
% Asks the user for a cell number and returns the coordinates and value of the cell.
get_cell(Board, X, Y, Value) :- 
    read_number(N),
    is_valid_cell(N, Board, Value, X, Y), 
    !.
get_cell(Board, X, Y, Value) :-
    write('Invalid! Try again!'), nl,
    get_cell(Board, X, Y, Value).

% is_valid_cell(+N, +Board, -Value, -X, -Y)
% Checks if the cell number N is valid in Board and returns the value and coordinates of the cell piece
is_valid_cell(N, Board, Value, X, Y) :-
    nth0(0, Board, FirstLine),
    length(FirstLine, LineSize),
    X is N // LineSize,
    Y is N mod LineSize,
    nth0(X, Board, Line), 
    nth0(Y, Line, Value),
    Value \= -1.

% level(+Player, +ChosenLevels, -Level)
% Returns the level of the given player
level(r, L-_, L).
level(b, _-L, L).

% player_label(+Player, -Label)
% Returns the label of the given player
player_label(r, 'Red').
player_label(b, 'Blue').

% write_move(+Player, +Xi, +Yi, +Xf, +Yf, +Board)
% Writes to the screen the move made by the given player
write_move(Player, Xi, Yi, Xf, Yf, Board) :-
    get_piece(Xi, Yi, Board, Piece),
    get_cell_number(Xi, Yi, Board, From),
    get_cell_number(Xf, Yf, Board, To),
    player_label(Player, PlayerLabel),
    write('Player '), write(PlayerLabel), write(' moved '), display_cell_value(Piece), 
    write(' from '), write(From),
    write(' to '), write(To), nl.

% get_cell_number(+X, +Y, +Board, -CellNumber)
% Returns the cell number of the given coordinates in the given board
get_cell_number(X, Y, Board, CellNumber) :-
    nth0(0, Board, FirstLine),
    length(FirstLine, LineSize),
    CellNumber is X * LineSize + Y.

/*
** End Auxiliary Functions
*/


% valid_moves(+GameState, +Player, -Moves)
% Returns a list of valid moves for the given player in the given game state
valid_moves(Board, Player, ListOfMoves) :-
    findall((Xi,Yi,Xf,Yf), (
        valid_piece(Xi, Yi, Board, Player-Piece),
        bfs((Xi,Yi), Piece, Player, Board, Moves),
        member((Xf,Yf), Moves)
    ), ListOfMoves).

% move(+GameState, +Move, -NewGameState)
% Returns the new game state after applying the given move to the given game state
move(Player-Board, (Xi, Yi, Xf, Yf), NewPlayer-NewBoard) :- 
    change_player(Player, NewPlayer),
    valid_piece(Xi, Yi, Board, Player-Attacker),
    bfs((Xi,Yi), Attacker, Player, Board, Moves),
    memberchk((Xf,Yf), Moves),
    get_piece(Xf, Yf, Board, Piece),
    combat(Player-Attacker, Piece, ResultingPiece),
    implement_move((Xi, Yi, Xf, Yf), Board, ResultingPiece, NewBoard).

% implement_move(+Move, +Board, +ResultingPiece, -NewBoard)
% Implements the given move in the given board and returns the new board
implement_move((Xi, Yi, Xf, Yf), Board, NewPiece, NewBoard):-
    replace_board_value(Board, Xi, Yi, 0, AuxBoard),
    replace_board_value(AuxBoard, Xf, Yf, NewPiece, NewBoard).


/*
** Winning Condition
*/

% captured(+Piece, +Board)
% Checks if the given piece is captured in the given board
captured(_, []). % base case
captured(Piece, [Row | Rest]) :-
    \+ memberchk(Piece, Row),
    captured(Piece, Rest).

% win_pentagon_captured(+Board, -Winner)
% Checks if the pentagon of the given player is captured in the given board and returns the winner
win_pentagon_captured(Board, b) :-
    captured(r-5, Board).
win_pentagon_captured(Board, r) :-
    captured(b-5, Board).

% win_gold_tiles(+Board, -Winner)
% Checks if the given player has occupied the gold tiles in the given board and returns the winner
win_gold_tiles(b-Board, b) :-
    get_piece(1,4, Board, b-_),
    get_piece(5,6, Board, b-_).

win_gold_tiles(r-Board, r) :-
    get_piece(1,4, Board, r-_),
    get_piece(5,6, Board, r-_).

% game_over(+GameState, -Winner)
% Checks if the game is over and returns the winner
game_over(_-Board, Winner) :-
    win_pentagon_captured(Board, Winner).
game_over(Player-Board, Winner) :-
    win_gold_tiles(Player-Board, Winner).

% display_winner(+Winner)
% Displays the winner
display_winner(Winner):-
    write('Game Over!'), nl,
    player_label(Winner, WinnerLabel),    
    write(WinnerLabel), write(' player'), write(' won!'), nl,
    wait_for_enter.

/*
** End Winning Condition
*/



% combat(+Attacker, +Defender, -ResultingPiece)
% Returns the resulting piece after a combat between the attacker and the defender
combat(Player-_, Player-_, _) :- 
    !, fail.
combat(Attacker, 0, Attacker).
combat(Attacker-AttackerPiece, Defender-AttackedPiece, Attacker-AttackerPiece) :-
    AttackerPiece =< AttackedPiece,
    !.

combat(_-3, _-1, 0). % Attacker is a triangle and defender is a circle, both will be removed
combat(_-4, _-3, 0). % Attacker is a square and defender is a triangle, both will be removed



/*
** Game Cycle
*/

 % game_cycle(+GameState, +ChosenLevels)
 % Calculates one cycle of the game from the given game state and chosen levels
 
game_cycle(Player-Board, _):-
    game_over(Player-Board, Winner), !,
    display_winner(Winner),
    menu.

game_cycle(Player-Board, ChosenLevels):-
    player_label(Player, PlayerLabel),
    write(PlayerLabel), write(' Player\'s'), write(' turn.'), nl,
    level(Player, ChosenLevels, Level),
    choose_move(Board, Player, Level, (Xi, Yi, Xf, Yf)),
    move(Player-Board, (Xi, Yi, Xf, Yf), NewPlayer-NewBoard),
    clear,
    display_game(NewBoard),
    write_move(Player, Xi, Yi, Xf, Yf, Board),
    !,
    game_cycle(NewPlayer-NewBoard, ChosenLevels).    

% choose_move(+Board, +Player, +Level, -Move)
% Prompts a human player for a move.
choose_move(Board, Player, human, (Xi, Yi, Xf, Yf)) :-
    select_cell(Board, Player, Xi, Yi,_),
    write('Where do you want to move it?'), nl,
    get_cell(Board, Xf, Yf,_).

% If the move is invalid, prompts the user for another move.    
choose_move(Board, Player, human, Move):-
    write('Invalid move! Try again.'), nl,
    choose_move(Board, Player, human, Move).

% Chooses a new move for the easy bot to perform.
choose_move(Board, Player, easy_bot, (Xi, Yi, Xf, Yf)) :- 
    random_move(Board, Player, (Xi, Yi, Xf, Yf)),
    wait_for_enter.

% Chooses a new move for the hard AI to perform.
choose_move(Board, Player, hard_bot, (Xi, Yi, Xf, Yf)) :-
    greedy_move(Board, Player, (Xi, Yi, Xf, Yf)),
    wait_for_enter.

/*
** End Game Cycle
*/