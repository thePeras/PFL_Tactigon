:- use_module(library(between)).
:- use_module(library(lists)).
:- use_module(library(random)).

:- consult('src/utils').
:- consult('src/menu').
:- consult('src/game').
:- consult('src/board').

play :- menu.