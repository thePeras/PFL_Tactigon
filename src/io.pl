write_str("").
write_str([Code | T]) :- char_code(Char, Code), write(Char), write_str(T).

write_lines([]).
write_lines([H|T]) :- write_str(H), nl, write_lines(T).

clear :- write_str("\e[2J").

read_number(Number) :-
    catch(
        read(Term),
        error(syntax_error(_), _),
        (write('That is not a valid number. Please try again.'), nl, 
        write('Enter a number: '), 
        read_number(Number))
    ),
    (   number(Term) ->
        Number = Term
    ;   write('That is not a valid number. Please try again.'), nl,
        write('Enter a number:'),
        read_number(Number)
    ).

read_number_until(Prompt, Condition, Out) :-
    repeat,
    write(Prompt),
    read_number(Out),
    call(Condition, Out), !.