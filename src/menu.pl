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
    "\e[1mTactigon\e[0m",
    "A fast-paced board game where strategy meets geometry",
    "",
    "\e[1mHow to win \e[0m",
    "There are 2 ways to win:",
    "- Capturing the opponent pentagon.",
    "- Occupy both gold tiles, the yellow spaces.",
    "",
    "\e[1mPieces and Movement \e[0m",
    "There are 4 types of pieces that can move in any direction:",
    " - Circles, can move 1 space.",
    " - Triangles, can move up to 3 spaces",
    " - Squares, can move up to 2 spaces.",
    " - Pentagons, can move up to 4 spaces.",
    "",
    "\e[1mCombat \e[0m",
    "TODO",
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
        "Choose bot difficulty:",
        "1: Easy",
        "2: Hard",
        "",
        "0: Go back to menu"
    ], [fail, Level = easy_bot, Level = hard_bot, !, !]).

pvp :- play_game(human-human).
pvc :- 
    choose_bot_algorithm(Level),
    play_game(human-Level).
cvc :- 
    choose_bot_algorithm(Bot1Level),
    choose_bot_algorithm(Bot2Level),
    play_game(Bot1Level-Bot2Level).