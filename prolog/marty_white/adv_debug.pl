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
% Sept 20, 1999 - Douglas Miles
% July 10, 1996 - John Eikenberry
%
% Logicmoo Project changes:
%
% Main file.
%
*/

%:- system:use_module(library(console_input)).
%:- system:use_module(library(date)).
:- system:use_module(library(make)).
%:- system:use_module(library(qsave)).
:- system:use_module(library(prolog_autoload)).
%:- system:use_module(library(prolog_pack)).
:- system:use_module(library(lists)).
:- system:use_module(library(backcomp)).
%:- system:use_module(library(edit)).
%:- system:use_module(library(prolog_trace)).
%:- system:use_module(library(threadutil)).
:- system:use_module(library(debug)).

:- reexport(library(logicmoo_utils_all)).
ludef:- list_undefined([module_class([user, system, library, test, development])]).

:- export(simplify_dbug/2).

simply_debug_opts([len=5]).

get_zoption(Z, N, V, E):- member(N=V, Z)->true;V=E.

simplify_dbug(G, GG):- enotrace(simplify_dbug_3(G, GG)).
simplify_dbug(Z, G, GG):- enotrace(simplify_dbug_3(Z, G, GG)).

simplify_dbug_3(G, GG):- is_list(G), must_det(maplist(simplify_dbug_3, G, GG)), !.
simplify_dbug_3(G, GG):- simply_debug_opts(Z), simplify_dbug_3(Z, G, GG).

simplify_dbug_3(_, G, GG):- \+ compound(G), !, GG=G.
simplify_dbug_3(_, {O}, {O}):- !.

simplify_dbug_3(Z, List, O):-
 ( is_list(List) -> clip_cons(Z, List, '...'(Clipped), O) ;
 ( List = [_|_], append(LeftSide, Open, List),
  ((var(Open);Open \= [_|_])), !, assertion(is_list(LeftSide)),
 clip_cons(Z, LeftSide, '...'(Open), O))), debug_var('CO', Open), debug_var('OC', Clipped).

simplify_dbug_3(_, (X \= Y), (X \= Y)):- atom(X), debug_var(['Not', X], Y).
simplify_dbug_3(_, (X \= Y), (X \= Y)):- atom(Y), debug_var(['Not', X], Y).
simplify_dbug_3(Z, G, GG):- compound_name_arguments(G, F, GL), F\==percept_props, !,
 maplist(simplify_dbug_3(Z), GL, GGL), !, compound_name_arguments(GG, F, GGL).
simplify_dbug_3(_, G, G).


mwmsg(G):- enotrace(mwmsg_3(G)).
mwmsg_3(G):- compound(G), compound_name_arity(G,_,2),G=..[F, GG], !, dmsg(F:-GG).
mwmsg_3(G):- simplify_dbug(G, GG)->guess_pretty(GG)->dmsg(GG).

%:- system:import(simplify_dbug/2).
%:- listing(simplify_dbug/2).

get_structure_type(KB, Name):- \+ is_list(KB), !, Name=KB.
get_structure_type(KB, Name):- declared(structure_type(Name), KB), !.

get_structure_inst(KB, Type, Name):- declared(propOf(Type, Name), KB), !.
get_structure_inst(KB, Type, Name):- get_structure_type(KB, Type), declared(propOf(_, Name), KB).

get_structure_owner(KB, Name):- declared(propOf(_, Name), KB), !.

get_structure_label(KB, Name):- \+ is_list(KB), !, Name=KB.
get_structure_label(KB, Name):- sub_compound(structure_label(Name), KB), !.
get_structure_label(KB, inst(Name)):- sub_compound(inst(Name), KB), !.


is_state_list(_, G, _):- \+ compound(G), !, fail.
is_state_list(_, [G1|_], {GG, '...'}):- compound(G1), G1=structure_type(GG), !.
is_state_list(Z, [_|G], GG):- is_state_list(Z, G, GG).

clip_cons(Z, G, GG):- is_state_list(Z, G, GG), !.
clip_cons(Z, List, ClipTail, {Len, LeftS, ClipTail}):- fail,
 get_zoption(Z, len, MaxLen, 7),
 length(List, Len),
 Len>MaxLen,
 length(Left, MaxLen),
 append(Left, _, List), !,
 maplist(simplify_dbug(Z), Left, LeftS).
clip_cons(Z, Left, _, List):-maplist(simplify_dbug(Z), Left, List).


found_bug(S0, open_list(Open)) :- \+is_list(S0),
  get_open_segement(S0, Open).
found_bug(S0, duplicated_object(X, R, L)) :-
 append(Left, [prop(X, R)|_], S0),
 member(prop(X, L), Left).

get_open_segement(S0, Open):- append(Left, _, S0), is_list(Left), length(Left, N), N>2, !, append([_, _], S1, S0), get_open_segement(S1, Open).
get_open_segement(S0, S0).


check4bugs(Why, S0):- found_bug(S0, Bug), pprint(S0, always), pprint(check4bugs_found_bug(Why, Bug), always), throw(check4bugs_failed(Bug)).
 % TODO: emergency save of S0, either here or better yet, in a catch().
check4bugs(_, _).



:- meta_predicate reset_prolog_flag(0, *, *, *).
:- meta_predicate reset_prolog_flag(0, *, *).
:- meta_predicate system_default_debug(0).

reset_prolog_flag(YN, Name, SystemValue):-
  YN -> set_prolog_flag(Name, SystemValue) ; true.

reset_prolog_flag(YN, Name, SystemValue, OverrideValue):-
  YN -> set_prolog_flag(Name, SystemValue)
   ;  set_prolog_flag(Name, OverrideValue).

system_default_debug(YN):-
  reset_prolog_flag(YN, answer_format, '~p', '~q'),
  reset_prolog_flag(YN, answer_write_options, [quoted(true), portray(true), max_depth(10), spacing(next_argument)],
   [quoted(true), portray(true), max_depth(4), spacing(next_argument)]),
  reset_prolog_flag(YN, debugger_write_options, [quoted(true), portray(false), max_depth(10), attributes(portray), spacing(next_argument)],
   [quoted(true), portray(true), max_depth(4), attributes(portray), spacing(next_argument)]),
  reset_prolog_flag(YN, print_write_options, [portray(true), quoted(true), numbervars(true)],
   [portray(true), quoted(true), numbervars(true)]),

  reset_prolog_flag(YN, backtrace, true),
  reset_prolog_flag(YN, backtrace_depth, 20, 2000),
  reset_prolog_flag(YN, backtrace_goal_depth, 3, 4),
  reset_prolog_flag(YN, backtrace_show_lines, true),
  reset_prolog_flag(YN, debug, false, true),
  reset_prolog_flag(YN, debug_on_error, true),
  reset_prolog_flag(YN, debugger_show_context, false, true),

  reset_prolog_flag(YN, gc, true),

  reset_prolog_flag(YN, last_call_optimisation, true, false),
  reset_prolog_flag(YN, optimise, false),
  reset_prolog_flag(YN, optimise_debug, default),

  reset_prolog_flag(YN, prompt_alternatives_on, determinism),
  reset_prolog_flag(YN, toplevel_goal, default),
  reset_prolog_flag(YN, toplevel_mode, backtracking),
  reset_prolog_flag(YN, toplevel_residue_vars, false, true),
  reset_prolog_flag(YN, toplevel_print_anon, true),
  reset_prolog_flag(YN, toplevel_print_factorized, false, true),
  reset_prolog_flag(YN, write_attributes, ignore),

  reset_prolog_flag(YN, warn_override_implicit_import, true),
  reset_prolog_flag(YN, access_level, user),
  reset_prolog_flag(YN, sandboxed_load, false),
  reset_prolog_flag(YN, save_history, true),
  !.

:- system_default_debug(false).

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CODE FILE SECTION
% :- nop(ensure_loaded('adv_debug')).
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- module_transparent(must_mw/1).
:- module_transparent(must_mw1/1).
:- module_transparent(dmust_tracing/1).
:- module_transparent(if_tracing/1).
:- meta_predicate(if_tracing(*)).
if_tracing(G):- tracing -> enotrace(G) ; true.

:- export(must_mw1/1).
:- meta_predicate(must_mw(0)).
must_mw(G):- G*->true;(mwmsg(fail(must_mw):-G), fail).

:- export(must_mw1/1).
:- meta_predicate(must_mw1(*)).
must_mw1(G):- enotrace((assertion(callable(G)), fail)).
must_mw1((G1, G2)):- !, must_mw1(G1), must_mw1(G2).
must_mw1((G1;G2)):- !, (G1;must_mw1(G2)).
must_mw1(G):- G*->!;enotrace((mwmsg(fail(must_mw1):-G), dumpST, fail)).
% must_mw1(G):- G*->true;(mwmsg(fail(must_mw1):-G), rtrace(G), fail).

:- meta_predicate(must_mw1(*, +, -)).
must_mw1(Goal, S0, S2):- apply_state(must_mw1, Goal, S0, S2).

:- meta_predicate(dmust_tracing(*)).
dmust_tracing(G):- enotrace((tracing, cls)), !, must_mw1(G).
dmust_tracing(G):- G*->true;(mwmsg(fail(dmust_tracing):-G), fail).

:- meta_predicate(dmust_tracing(*, +, -)).
dmust_tracing(G, S, E):- apply_state(dmust_tracing, (G), S, E).



% '$hide'(Pred) :- '$set_predicate_attribute'(Pred, trace, false).
never_trace(_Spec):- prolog_load_context(reloading, true), !.
never_trace(Spec):- '$hide'(Spec), '$iso'(Spec), ignore(trace(Spec, -all)).
:- call(ensure_loaded, library(lists)).
:- never_trace(lists:append(_, _, _)).
:- never_trace(lists:list_to_set/2).
:- never_trace(lists:member_(_, _, _)).
/*
:- never_trace(prolog_debug:assertion(_)).
*/


%:- never_trace(lists:member(_, _)).
%:- never_trace(lists:append(_, _, _)).
:- module_transparent(dshow_call/1).
:- module_transparent(dshow_success/1).
:- module_transparent(dshow_failure/1).

:- meta_predicate(dshow_call(*)).
dshow_call((G1, G2)):- !, dshow_call(G1), dshow_call(G2).
dshow_call(G):- (G*->mwmsg(dshow_success(G));(mwmsg(dshow_failure(G)), !, fail)).
dshow_call(G, S, E):- dshow_call(apply_state(call, G, S, E)).

:- meta_predicate(dshow_success(*)).
dshow_success('\\+'(G1)):- !, \+ dshow_failure(G1).
dshow_success(G):- (G*->mwmsg(dshow_success(G));fail).
dshow_success(G, S, E):- dshow_success(apply_state(call, G, S, E)).

:- meta_predicate(dshow_failure(*)).
dshow_failure('\\+'(G1)):- !, \+ dshow_success(G1).
dshow_failure(G):- (G*->true;(mwmsg(dshow_failure(G)), !, fail)).
dshow_failure(G, S, E):- dshow_failure(apply_state(call, G, S, E)).



:- multifile(user:portray/1).
:- dynamic(user:portray/1).
:- discontiguous(user:portray/1).
% user:portray





%:- set_prolog_flag(verbose_load, full).
:- set_prolog_flag(verbose, normal).
%:- set_prolog_flag(verbose_autoload, true).




