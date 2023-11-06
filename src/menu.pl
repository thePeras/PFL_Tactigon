% display_menu(+Lines, +Actions)
% Displays a menu with the given lines and actions. Also validates the user input and calls the corresponding action.
display_menu(Lines, Actions) :-
    write_lines(Lines),
    length(Actions, Len),
    MaxOption is Len - 1,
    read_number_until('Choose option: ', between(0, MaxOption), Choice),
    nth0(Choice, Actions, Action),
    call(Action).

% menu/0
% Displays the main menu.
menu :- repeat, clear, display_logo, display_menu([
    "Please select an option:",
    "1: Play",
    "2: How to play",
    "3: Exit"
], [!, play_menu, instructions_menu, !]).

% instructions_menu/0
% Displays the instructions menu.
instructions_menu :- clear, display_logo, display_menu([
    "\e[1mTactigon\e[0m",
    "A fast-paced board game where strategy meets geometry",
    "",
    "\e[1mHow to win \e[0m",
    "There are 2 ways to win:",
    "- Capturing the opponent's pentagon.",
    "- Occupying both gold tiles - the yellow spaces.",
    "",
    "\e[1mPieces and Movement \e[0m",
    "There are 4 types of pieces that can move in any direction:",
    " - Circles, can move 1 space.",
    " - Triangles, can move up to 3 spaces",
    " - Squares, can move up to 4 spaces.",
    " - Pentagons, can move up to 5 spaces.",
    "",
    "\e[1mCombat \e[0m",
    "The result of the combat is defined in the table below:",
    "",
    "Defender |  Circle  | Triangle |  Square  | Pentagon |",
    "Atacker   |-------------------------------------------|",
    "Circle    | Result 1 | Result 1 | Result 1 | Result 1 |",
    "Triangle  | Result 2 | Result 1 | Result 1 | Result 1 |",
    "Square    | Result 3 | Result 2 | Result 1 | Result 1 |",
    "Pentagon  | Result 3 | Result 3 | Result 3 | Result 1 |",
    "",
    "  Result 1 - Defender is captured",
    "  Result 2 - Both pieces are captured",
    "  Result 3 - The attacker cannot atack this piece",
    "",
    "Have fun!",
    "",
    "0: Go back to menu"
], [fail]).

% play_menu/0
% Displays the play menu.
play_menu :- clear, display_logo, display_menu([
    "Choose game mode:",
    "1: Player vs Player",
    "2: Player vs Computer",
    "3: Computer vs Computer",
    "",
    "0: Go back to menu"
], [fail, pvp, pvc, cvc, !, !]).

% choose_bot_algorithm(-Level)
% Displays the bot difficulty menu and returns the chosen level.
choose_bot_algorithm(Level, BotPlayer) :- clear, display_logo,
    write('Select computer '), write(BotPlayer), write('\'s level: '), nl,
    display_menu([
        "1: Easy",
        "2: Hard",
        "",
        "0: Go back to menu"
    ], [fail, Level = easy_bot, Level = hard_bot, !, !]).


% pvp/0
% Starts a player vs player game.
pvp :- play_game(human-human).

% pvc/0
% Starts a player vs computer game and allows the player to choose the bot difficulty.
pvc :- 
    choose_bot_algorithm(Level),
    play_game(human-Level).

% cvc/0
% Starts a computer vs computer game and allows the user to choose the bots difficulties.
cvc :-
    choose_bot_algorithm(Bot1Level, '1'),
    choose_bot_algorithm(Bot2Level, '2'),
    play_game(Bot1Level-Bot2Level).


% display_logo/0
% Displays the game logo.
display_logo :- write_lines([
    "              \e[31m#######\e[0m",                                                                  
    "             \e[31m#########\e[0m",                                                                
    "            \e[31m###########\e[0m",                                                                
    "   \e[33m.......\e[0m  \e[31m###########\e[0m",                                                                
    "  \e[33m.........\e[0m  \e[31m#########\e[0m    \e[1m#@@@@@#   *@#     .@@@@    #@@@@@#  :@@   .@@@@     #@@@+   *@#  @@ \e[0m",  
    " \e[33m...........\e[0m  \e[31m#######\e[0m     \e[1m:-@@@-:   @@@.   *@@.-@@=  :-@@@-:  =@@  @@@.=@@-  @@+.@@#  @@@= @@ \e[0m",  
    " \e[33m...........\e[0m  \e[36m=======\e[0m     \e[1m  %@*    @@%@#   %@#         #@%    =@@  @@=       @@  *@@  @@@@ @@ \e[0m",  
    "  \e[33m.........\e[0m  \e[36m=========\e[0m    \e[1m  %@*   -@@ @@   %@#         #@%    =@@  @@= @@@=  @@  *@@  @@@@@@@ \e[0m",  
    "   \e[33m.......\e[0m  \e[36m===========\e[0m   \e[1m  %@*   @@@%@@%  %@#         #@%    =@@  @@=  @@=  @@  *@@  @@*#@@@ \e[0m",  
    "   \e[32m-------\e[0m  \e[36m===========\e[0m   \e[1m  %@*  .@@*+*@@  *@@ :@@=    #@%    =@@  @@@ -@@-  @@= @@#  @@* @@@ \e[0m",  
    "  \e[32m---------\e[0m  \e[36m=========\e[0m    \e[1m  #@=  #@#   #@*  -@@@@      +@*    :@@   -@@@@     @@@@+   #@=  @@ \e[0m",  
    " \e[32m-----------\e[0m  \e[36m=======\e[0m ",
    " \e[32m-----------\e[0m               \e[1m OUTWIT                      OUTFLANK                      OUTLAST \e[0m",
    "  \e[32m---------\e[0m",                                                                          
    "   \e[32m-------\e[0m",
    ""
]).

% choose_board(-Type)
% Displays the board type menu and returns the chosen type.
choose_board(Type):-
    display_logo,
    write(' Board Type: \n 1. Normal \n 2. Small \n 3. Extra Small \n\n Option: '),
    repeat,
    read_number(Type),
    member(Type, [1, 2, 3]), !.