play(FirstPlayer, SecondPlayer) :-
    init_state(State, Board), %this initializes the state and the board
    play(FirstPlayer, SecondPlayer, State, Board).

init_state(State, Board) :-
    init_board(Board), %TODO: to implement
    State = init_round.

play(FirstPlayer, SecondPlayer, State, Board) :-
    display_game(Board),
    winning_condition(State, Board, Winner),
    !,
    display_winner(Winner),
    menu.

winning_condition(State, Board, Winner) :-
    State \= init_round,
    winning_condition(Board, Winner).

winning_condition(init_round, _, _) :- fail.

play(FirstPlayer, SecondPlayer, State, Board) :-
    display_player(State), %player turn
    display_game(Board),
    get_move(State, Move), %get the piece to be played and the cell to be played
    move(State, Move, NewState),
    play(FirstPlayer, SecondPlayer, NewState, Board).

display_player(init_round) :-
    write('Red Player turn').
display_player(half_round) :-
    write('Blue Player turn').

display_game(Board) :-
    clear,
    write('Board printed!').