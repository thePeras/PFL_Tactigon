display_menu(Lines, Actions) :-
    clear,
    write_lines(Lines),
    length(Actions, Len),
    MaxOption is Len - 1,
    read_number_until('Choose option: ', between(0, MaxOption), Choice),
    nth0(Choice, Actions, Action),
    call(Action).

menu :- repeat, display_menu([
    "Please select an option:",
    "1: Play",
    "2: How to play",
    "3: Exit"
], [!, play_menu, instructions_menu, !]).

instructions_menu :- display_menu([
    "Instructions",
    "",
    "Tactigon...",
    "",
    "0: Go back to menu"
], [fail]).

play_menu :- display_menu([
    "Choose game mode:",
    "1: Player vs Player",
    "2: Player vs Computer",
    "3: Computer vs Computer",
    "",
    "0: Go back to menu"
], [fail, pvp, pvc, cvc, !, !]).

pvp :- play(0, 0).
pvc :- play(0, 1).
cvc :- play(1, 1).