:- use_module(library(between)).
:- use_module(library(lists)).

:- consult('src/io').
:- consult('src/utils').
:- consult('src/menu').
:- consult('src/game').
:- consult('src/board').

play :- menu.