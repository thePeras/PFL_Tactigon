:- use_module(library(between)).
:- use_module(library(lists)).

:- consult('src/io').
:- consult('src/menu').
:- consult('src/game').

play :- menu.