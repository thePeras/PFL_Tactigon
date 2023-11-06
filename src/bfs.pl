% neighboursOffSet(+OffSet)
% Simple list of tuples with the offset of the neighbours of each cell
neighboursOffSet([(0, -1), (0, 1), (-1, -1), (-1, 0), (1, 1), (1, 0)]).

% get_neighbours(+X, +Y, +Player-Piece, +Board, -Neighbours)
% Gets the neighbours of a given cell
get_neighbours(Xi, Yi, Player-Piece, Board, Neighbours) :-
    neighboursOffSet(OffSet),
    get_neighbours(Xi, Yi, Player-Piece, Board, OffSet, Neighbours).

get_neighbours(_,_,_,_,[],[]). % base case
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
% Filters the moves that are valid
filter_moves(_, [], _, []). % base case
filter_moves(Player-Piece, [(X, Y) | Rest], Board, [(X, Y) | FilteredMoves]) :- % valid move added to queue 
    get_piece(X, Y, Board, Value),
    combat(Player-Piece, Value, _),
    !,
    filter_moves(Player-Piece, Rest, Board, FilteredMoves).

% invalid move
filter_moves(Player-Piece, [(_,_) | Rest], Board, FilteredMoves):-
    filter_moves(Player-Piece, Rest, Board, FilteredMoves).


% add_distance(+Moves, +Distance, -MovesWithDistance)
% Adds the distance to the moves
add_distance([],_,[]).
add_distance([(X,Y)| Rest], Distance, [(X,Y,Distance) | RestDist]) :-
    add_distance(Rest, Distance, RestDist).

% empty_positions(+Board, +Moves, -EmptyPositions)
% Returns the empty positions of the given moves
empty_positions(_, [], []).
empty_positions(Board, [(X,Y) | Rest], [(X,Y) | OtherEmptyPositions]) :-
    get_piece(X, Y, Board, 0),
    !,
    empty_positions(Board, Rest, OtherEmptyPositions).
empty_positions(Board, [(_,_) | Rest], EmptyPositions) :-
    empty_positions(Board, Rest, EmptyPositions). 

% bfs(+Piece, +Player, +Board, +MaxMoves, +Queue, +Visited, -Moves)
% Breadth-first search algorithm

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

    empty_positions(Board, UnVisitedMoves, EmptyPositionsMoves),   % Get moves to empty spaces
    
    add_distance(EmptyPositionsMoves, NewDistance, EmptyPositionsMovesDist),

    append(UnVisitedMoves, RecursiveMoves, Moves),  
    append(UnVisitedMoves, Visited, UpdatedVisited),
    append(Rest, EmptyPositionsMovesDist, UpdatedRest),

    bfs(Piece, Player, Board, MaxMoves, UpdatedRest, UpdatedVisited, RecursiveMoves). % recursive call