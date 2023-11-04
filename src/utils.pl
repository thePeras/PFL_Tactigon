get_piece(X, Y, Board, Piece) :-
    nth0(X, Board, Row),
    nth0(Y, Row, Piece).

valid_position(X, Y, Board, Piece) :-
    get_piece(X,Y, Board, Piece),
    Piece \= -1.

valid_piece(X, Y, Board, rb-Piece) :-
    valid_position(X, Y, Board, rb-Piece),
    nth0(X, Board, Row),
    nth0(Y, Row, rb-Piece).