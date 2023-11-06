% random_move(+Board, +Player, -Move)
% Chooses a random move from the valid moves of the given board and player.
random_move(Board, Player, (Xi, Yi, Xf, Yf)) :-
    valid_moves(Board, Player, Moves),
    random_member((Xi, Yi, Xf, Yf), Moves).

% greedy_move(+Board, +Player, -Move)
% Chooses the best move from the valid moves of the given board and player.
greedy_move(Board, Player, (Xi, Yi, Xf, Yf)) :-
    valid_moves(Board, Player, Moves),
    best_move(Board, Player, Moves, (Xi, Yi, Xf, Yf)).

% best_move(+Board, +Player, +Moves, -GreedyMove)
% Chooses the best move from the given list of moves.
best_move(Board, Player, Moves, GreedyMove) :-
    evaluate(Board, Player, Moves, Values),
    max_member(MaxValue, Values),
    findall((Xi, Yi, Xf, Yf), (
        nth0(X, Values, MaxValue),
        nth0(X, Moves, (Xi, Yi, Xf, Yf))
    ), BestMoves), 
    random_member(GreedyMove, BestMoves).

% evaluate(+Board, +Player, +Moves, -Values)
% Evaluates the given moves and returns a list of values.
evaluate(_, _, [], []). % base case
evaluate(Board, Player, [(Xi, Yi, Xf, Yf) | Rest], [Value | RestValues]) :-
    move(Player-Board, (Xi, Yi, Xf, Yf), _-NewBoard),
    evaluate_board(NewBoard, Player, Value),
    evaluate(Board, Player, Rest, RestValues).

% evaluate_board(+Board, +Player, -Value)
% Evaluates the given board and returns a value.
evaluate_board(Board, Player, Value) :-
    evaluate_board(Board, Player, 0, 0, 0, Value). % initial values

% evaluate_board(+Board, +Player, +RowIndex, +ColumnIndex, +AccValue, -Value)
evaluate_board([], _, _, _, Value, Value). % base case
evaluate_board([Row | Rest], Player, RowI, ColI, AccVal, Value) :-
    evaluate_row(Row, Player, RowI, ColI, RowVal),
    NewAccVal is RowVal + AccVal,
    NewRowI is RowI + 1,
    evaluate_board(Rest, Player, NewRowI, ColI, NewAccVal, Value).

% evaluate_row(+Row, +Player, +RowIndex, +ColumnIndex, -Value)
% Evaluates the given row and returns a value.
evaluate_row([],_,_,_,0). % base case
evaluate_row([Cell | Rest], Player, RowI, ColI, RowVal) :-
    evaluate_cell(Cell, Player, RowI, ColI, CellVal),
    NewColI is ColI + 1,
    evaluate_row(Rest, Player, RowI, NewColI, RecursiveValue),
    RowVal is CellVal + RecursiveValue.

% evaluate_cell(+Cell, +Player, +RowIndex, +ColumnIndex, -Value)
% Evaluates the given cell and returns a value.

evaluate_cell(-1,_,_,_,0) :- !. % not playable cell
evaluate_cell(0,_,_,_,0) :- !. % empty cell
evaluate_cell(P-Piece, Player, RowI, ColI, CellVal) :-
    P = Player,
    !,
    evaluate_piece(Piece, RowI, ColI, CellVal).

evaluate_cell(_-Piece,_, RowI, ColI, CellVal) :- 
    evaluate_piece(Piece, RowI, ColI, PieceVal),
    CellVal is -PieceVal.

% evaluate_piece(+Piece, +RowIndex, +ColumnIndex, -Value)
% Evaluates the given piece and returns a value.
evaluate_piece(5,_, _, 1000) :- !. % pentagon
evaluate_piece(_,1,Col,200) :-  % upper gold tile
    Col =:= 4, !.
evaluate_piece(_,5,Col,200) :-  % lower gold tile
    Col =:= 6, !.

evaluate_piece(Piece, RowI, ColI, PieceVal):-
    Dcol is abs(ColI - 5),
    Drow is abs(RowI - 3),
    Distance is Dcol + max(0, (Drow-Dcol)/2),
    Aux is 5 - Distance,
    PieceVal is Aux * Piece.
