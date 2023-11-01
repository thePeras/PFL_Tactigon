play(FirstPlayer, SecondPlayer) :-
    init_state(State, Board), %this initializes the state and the board
    play(FirstPlayer, SecondPlayer, State, Board).

init_state(State, Board) :-
    init_board(Board), %TODO: to implement
    State = init_round.

init_board(Board) :-
    write('Board initialized!'), nl.

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
    get_move(State, Move), %get the piece to be played and the cell to be played
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

get_move(State, Move) :-
    read(Term),
    write('Getting move!'), nl.

move(blue_turn, Move, red_turn) :-
    write('blue moving'), nl.
move(State, Move, blue_turn) :-
    write('red moving'), nl.
