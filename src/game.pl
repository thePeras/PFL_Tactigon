play_game(ChosenLevels) :-
    clear,
    initial_state(Board),
    display_game(Board), % I think we should display the board here
    game_cycle(r-Board, ChosenLevels).

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

% valid_moves(+Board, +Player, -Moves)
valid_moves(Board, Player, ListOfMoves) :-
    findall((Xi,Yi,Xf,Yf), (
        valid_piece(Xi, Yi, Board, Player-Piece),
        bfs((Xi,Yi), Piece, Player, Board, Moves),
        member((Xf,Yf), Moves)
    ), ListOfMoves).



move(Player, Board, (Xi, Yi, Xf, Yf), NewPlayer-NewBoard) :- 
    change_player(Player, NewPlayer),
    valid_piece(Xi, Yi, Board, Player-Attacker),
    bfs((Xi,Yi), Attacker, Player, Board, Moves),
    memberchk((Xf,Yf), Moves),
    get_piece(Xf, Yf, Board, Piece),
    combat(Player-Attacker, Piece, ResultingPiece),
    implement_move((Xi, Yi, Xf, Yf), Board, ResultingPiece, NewBoard).

implement_move((Xi, Yi, Xf, Yf), Board, NewPiece, NewBoard):-
    replace_board_value(Board, Xi, Yi, 0, AuxBoard),
    replace_board_value(AuxBoard, Xf, Yf, NewPiece, NewBoard).

% change_player(?Player, ?OtherPlayer)
change_player(r, b).
change_player(b, r).


captured(_, []).
captured(Piece, [Row | Rest]) :-
    \+ memberchk(Piece, Row),
    captured(Piece, Rest).

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
game_over(b-_, _) :- !, fail. % red player can't win by gold tiles in blue's turn
game_over(Player-Board, Winner) :-
    win_gold_tiles(Player-Board, Winner).

% combat(+Attacker, +Defender, -ResultingPiece)
combat(Player-_, Player-_, _) :- 
    !, fail.
combat(Attacker, 0, Attacker).
combat(Attacker-AttackerPiece, Defender-AttackedPiece, Attacker-AttackerPiece) :-
    AttackerPiece =< AttackedPiece,
    !.
combat(_-3, _-1, 0). % Attacker is a triangle and defender is a circle, both will be removed
combat(_-4, _-3, 0). % Attacker is a square and defender is a triangle, both will be removed

neighboursOffSet([(0, -1), (0, 1), (-1, -1), (-1, 0), (1, 1), (1, 0)]).
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
filter_moves(Player-Piece, [(X, Y) | Rest], Board, [(X, Y) | FilteredMoves]) :- % valid move added to queue 
    get_piece(X, Y, Board, Value),
    combat(Player-Piece, Value, _),
    !,
    filter_moves(Player-Piece, Rest, Board, FilteredMoves).

filter_moves(Player-Piece, [(_,_) | Rest], Board, FilteredMoves):-
    filter_moves(Player-Piece, Rest, Board, FilteredMoves).

% create tuple with position and distance
add_distance([],_,[]).
add_distance([(X,Y)| Rest], Distance, [(X,Y,Distance) | RestDist]) :-
    add_distance(Rest, Distance, RestDist).

% empty_positions(+Board, +Moves, -EmptyPositions)
empty_positions(_, [], []).
empty_positions(Board, [(X,Y) | Rest], [(X,Y) | OtherEmptyPositions]) :-
    get_piece(X, Y, Board, 0),
    !,
    empty_positions(Board, Rest, OtherEmptyPositions).
empty_positions(Board, [(_,_) | Rest], EmptyPositions) :-
    empty_positions(Board, Rest, EmptyPositions). 

bfs((Xi, Yi), Piece, Player, Board, Moves) :-  
    MaxMoves is Piece,
    bfs(Piece, Player, Board, MaxMoves, [(Xi, Yi, 0)], [(Xi,Yi)], Moves).

bfs(_,_,_,_,[],_,[]). % no more moves
bfs(_,_,_,MaxMoves, [(_,_,MaxMoves) | _], _, []) :- !. % max moves reached
bfs(Piece, Player, Board, MaxMoves, [(X,Y,Distance) | Rest], Visited, Moves) :- 
    Distance < MaxMoves,
    NewDistance is Distance + 1,
    get_neighbours(X, Y, Player-Piece, Board, AllMoves), % includes invalid moves
    filter_moves(Player-Piece, AllMoves, Board, ValidMoves),
    memberchk_list(ValidMoves, Visited, UnVisitedMoves),

    empty_positions(Board, UnVisitedMoves, EmptyPositionsMoves),   % get moves to empty spaces
    
    add_distance(EmptyPositionsMoves, NewDistance, EmptyPositionsMovesDist),  % X-Y to X-Y-NewDist

    append(UnVisitedMoves, RecursiveMoves, Moves),    % RestMoves is the recursive result
    append(UnVisitedMoves, Visited, UpdatedVisited),
    append(Rest, EmptyPositionsMovesDist, UpdatedRest),

    bfs(Piece, Player, Board, MaxMoves, UpdatedRest, UpdatedVisited, RecursiveMoves).


select_cell(Board, Player, X, Y,Value) :-
    write('Which piece do you wish to move? '), nl,
    get_cell(Board, X, Y, Value),
    valid_piece(X, Y, Board, Player-_),
    !.

select_cell(Board, Player, X, Y,Value) :-
    write('Invalid cell!'), nl,
    select_cell(Board, Player, X, Y,Value).
    
/* 
Asks the user for a cell number and returns the coordinates and value of the cell
get_cell(+Board, -X, -Y, -Value) */
get_cell(Board, X, Y, Value) :- 
    read_number(N),
    is_valid_cell(N, Board, Value, X, Y), 
    !.
get_cell(Board, X, Y, Value) :-
    write('Invalid!'), nl,
    get_cell(Board, X, Y, Value).

is_valid_cell(N, Board, Value, X, Y) :-
    nth0(0, Board, FirstLine),
    length(FirstLine, LineSize),
    X is N // LineSize,
    Y is N mod LineSize,
    nth0(X, Board, Line), 
    nth0(Y, Line, Value),
    Value \= -1.

display_winner(Winner):-
    write('Game Over!'), nl,
    player_label(Winner, WinnerLabel),    
    write(WinnerLabel), write(' player'), write(' won!'), nl,
    wait_for_enter.

game_cycle(Player-Board, _):-
    game_over(Player-Board, Winner), !,
    display_winner(Winner),
    menu.

game_cycle(Player-Board, ChosenLevels):-
    player_label(Player, PlayerLabel),
    write(PlayerLabel), write(' Player\'s'), write(' turn.'), nl,
    level(Player, ChosenLevels, Level),
    choose_move(Board, Player, Level, (Xi, Yi, Xf, Yf)),
    move(Player, Board, (Xi, Yi, Xf, Yf), NewPlayer-NewBoard),
    clear,
    display_game(NewBoard),
    write_move(Player, Xi, Yi, Xf, Yf, Board),
    !,
    game_cycle(NewPlayer-NewBoard, ChosenLevels).    

level(r, L-_, L).
level(b, _-L, L).
player_label(r, 'Red').
player_label(b, 'Blue').

write_move(Player, Xi, Yi, Xf, Yf, Board) :-
    get_piece(Xi, Yi, Board, Piece),
    get_cell_number(Xi, Yi, Board, From),
    get_cell_number(Xf, Yf, Board, To),
    player_label(Player, PlayerLabel),
    write('Player '), write(PlayerLabel), write(' moved '), display_cell_value(Piece), 
    write(' from '), write(From),
    write(' to '), write(To), nl.

get_cell_number(X, Y, Board, CellNumber) :-
    nth0(0, Board, FirstLine),
    length(FirstLine, LineSize),
    CellNumber is X * LineSize + Y.

choose_move(Board, Player, human, (Xi, Yi, Xf, Yf)) :-
    select_cell(Board, Player, Xi, Yi,_),
    write('Where do you want to move it?'), nl,
    get_cell(Board, Xf, Yf,_).
    
choose_move(Board, Player, human, Move):-
    write('Invalid move! Try again.'), nl,
    choose_move(Board, Player, human, Move).

% random bot
choose_move(Board, Player, easy_bot, (Xi, Yi, Xf, Yf)) :- 
    valid_moves(Board, Player, Moves),
    length(Moves, Length),
    random(0, Length, Index),
    nth0(Index, Moves, (Xi, Yi, Xf, Yf)).

% greedy bot using the evaluation function and the minimax algorithm
choose_move(Board, Player, hard_bot, (Xi, Yi, Xf, Yf)) :-
    valid_moves(Board, Player, Moves),
    evaluate_moves(Board, Player, Moves, EvaluatedMoves),
    minimax(EvaluatedMoves, (Xi, Yi, Xf, Yf), _).

evaluate_moves(_, _, [], []).
evaluate_moves(Board, Player, [(Xi, Yi, Xf, Yf) | Rest], [(Eval, (Xi, Yi, Xf, Yf)) | EvaluatedMoves]) :-
    move(Player, Board, (Xi, Yi, Xf, Yf), NewPlayer-NewBoard),
    evaluate_board(NewPlayer-NewBoard, Eval),
    evaluate_moves(Board, Player, Rest, EvaluatedMoves).

evaluate_board(Player-Board, Eval) :-
    %win_pentagon_captured(Board, Winner);
    %win_gold_tiles(Player-Board, Winner),
    game_over(_-Board, Player),
    !,
    Eval is 1000.

evaluate_board(Player-Board, Eval) :-
    change_player(Player, OtherPlayer),
    game_over(_-Board, OtherPlayer),
    !,
    Eval is -1000.

evaluate_board(Player-Board, Eval) :-
    valid_moves(Board, Player, Moves),
    length(Moves, Eval).

minimax([(Eval, Move)], Move, Eval).
minimax([(Eval, Move) | Rest], BestMove, BestEval) :-
    minimax(Rest, (Eval2, Move2), _),
    better_move((Eval, Move), (Eval2, Move2), (BestEval, BestMove)).

better_move((Eval1, Move1), (Eval2, Move2), (Eval1, Move1)) :-
    Eval1 > Eval2.
better_move((Eval1, Move1), (Eval2, Move2), (Eval2, Move2)) :-
    Eval1 =< Eval2.
