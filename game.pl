initial(InitialState).

final(State):- winning_condition(State).

move(OldState, NewState):- valid_move(OldState, NewState).

play :- 
    initial(Init), 
    play(Init, [Init], States),
    reverse(States, Path), write(Path).

play(Curr, Path, Path):- final(Curr), !.
play(Curr, Path, States):-
    move(Curr, Next),
    not( member(Next, Path) ),
    play(Next, [Next|Path], States).