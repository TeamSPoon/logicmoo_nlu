/*
% NomicMUD: A MUD server written in Prolog
% Maintainer: Douglas Miles
% Dec 13, 2035
%
% Bits and pieces:
%
% LogicMOO, Inform7, FROLOG, Guncho, PrologMUD and Marty's Prolog Adventure Prototype
% 
% Copyright (C) 2004 Marty White under the GNU GPL 
% Sept 20,1999 - Douglas Miles
% July 10,1996 - John Eikenberry 
%
% Logicmoo Project changes:
%
% Main file.
%
*/

:- dynamic(adv:cmd_help/2).
:- multifile(adv:cmd_help/2).

:- online_help:use_module(library(help)). %,[online_manual_stream/1, pager_stream/1,  show_ranges/3, user_index/2, write_ranges_to_file/2, prolog:show_help_hook/2]).
:- online_help:use_module(library(pldoc)).
:- online_help:use_module(library(pldoc/doc_man)).

call_oh(G):- call(call,online_help:G).

add_help(Cmd,HelpStr):-
 retractall(adv:cmd_help(Cmd,_)),
 assert(adv:cmd_help(Cmd,HelpStr)).

add_help_cmd_borked(Cmd):-
 with_output_to(string(HelpStr),help(Cmd)),
 add_help(Cmd,HelpStr).
            
add_help_cmd(Cmd):-
 redirect_error_to_string(help(Cmd),HelpStr),
 add_help(Cmd,HelpStr).


give_help(A/B) :- !,
  call_oh(predicate(A, B, _, C, D)), !,
  show_help(A/B, [C-D]).
give_help(A) :-
  call_oh(user_index(B, A)), !,
  call_oh(section(B, _, C, D)),
  show_help(A, [C-D]).
give_help(A) :-
  atom(A),
  atom_concat('PL_', _, A),
  call_oh(function(A, B, C)), !,
  show_help(A, [B-C]).
give_help(A) :-
  findall(B-C,
    call_oh(predicate(A, _, _, B, C)),
    D),
  D\==[], !,
  show_help(A, D).
give_help(A) :-
  format('No help available for ~w~n', [A]).

show_help(C, B) :-
 predicate_property(prolog:show_help_hook(_, _),
       number_of_clauses(A)),
  A>0,
  call_oh(write_ranges_to_file(B, D)),
  call(call,prolog:show_help_hook(C, D)).

show_help(_, A) :-
  current_prolog_flag(pipe, true), !,
  call_oh(online_manual_stream(B)),
  call_oh(pager_stream(C)),
  catch(call_oh(show_ranges(A, B, C)), _, true),
  close(B),
  catch(close(C), _, true).

show_help(_, A) :-
  call_oh(online_manual_stream(B)),
  call_oh(show_ranges(A, B, user_output)).


