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

choose_bot_algorithm(Level) :-
    display_menu([
        "Choose bot algorithm:",
        "1: Random",
        "2: Greedy",
        "",
        "0: Go back to menu"
    ], [fail, Level = random_bot, Level = smart_bot, !]).

pvp :- play_game(human-human).
pvc :- 
    choose_bot_algorithm(Level),
    play_game(human-Level).
cvc :- 
    choose_bot_algorithm(Bot1Level),
    choose_bot_algorithm(Bot2Level),
    play_game(Bot1Level-Bot2Level).