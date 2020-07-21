/*
% NomicMUD: A MUD server written in Prolog
% Maintainer: Douglas Miles
% Dec 13, 2035
%
% Bits and pieces:
%
% LogicMOO, Inform7, FROLOG, Guncho, PrologMUD and Marty's Prolog Adventure Prototype
% 
% Feb 20, 2020 - Douglas Miles
%
% Logicmoo Project changes:
%
%
*/

  

load_bt_file(File):-   
  asserta(is_bt_file(File)),
  reconsult(File).

:- dynamic(bt_data/1).
==>>(HH, BB):- !, bt_data(==>>(HH, BB)).
::=(HH, BB):-  bt_data(::=(HH, BB)).
::=(HH, BB):- clause(HH, BB).


:- op(1200, xfy, ('==>>')).
:- op(1200, xfy, ('::=')).

is_metasent_bt('==>>', c).
is_metasent_bt(':-', c).
is_metasent_bt('::=', c).
is_metasent_bt('-->', c).

add_bt_meta_processing(Ax):-
  locally(b_setval('$bt_context', Ax),
    must_maplist(bt_accept,
      [(((A, B)) ==>> !, (A, B)), 
       (((A;B)) ==>> !, (A; B)),
       (((A->B)) ==>> !, (A -> B)),
       (((true)) ==>> !),
       (((A*->B;C)) ==>> !, (A *-> B ; C)),
       (((A*->B)) ==>> !, (A *-> B))])).

is_wrap_bt(_, Var):- var(Var), !.
is_wrap_bt(_, !):- !, fail.
is_wrap_bt(_, Atom):- \+ compound(Atom), !.
is_wrap_bt(h, G):- is_bt_metacall(G).
is_bt_metacall(H):- compound(H), safe_functor(H, F, A), is_metacall_bt(F, A).
is_metacall_bt(F, _):- is_metacall_bt(F).
is_metacall_bt(',').
is_metacall_bt(';').
is_metacall_bt('\\+').
is_metacall_bt('not').
is_metacall_bt('*->').
is_metacall_bt('->').


:- nb_setval('$bt_context', []).
expand_bt(_, H, HH):- (\+ nb_current('$bt_context', _) ; nb_current('$bt_context', [])), !, H=HH.
expand_bt(C, H, HH):- nb_current('$bt_context', Was), expand_bt(C, Was, H, HH), !.

expand_bt(C, Was, H, HH):- is_wrap_bt(C, H), append_term(Was, H, HH), !. 
expand_bt(_, Was, H, HH):- compound(H), safe_functor(H, F, _), safe_functor(Was, WF, _), F==WF, !, H=HH.
expand_bt(C, Was, H, HH):- compound(H), is_bt_metacall(H), H=..[F|ArgsH],
   must_maplist(expand_bt(C, Was), ArgsH, ArgsHH),
   HH =.. [F|ArgsHH].
expand_bt(_, Was, HB, HHBB):- compound(HB), safe_functor(HB, F, _), is_metasent_bt(F, C),
   HB=..[F, H|ArgsB], 
   expand_bt(h, Was, H, HH),
   must_maplist(expand_bt(C, Was), ArgsB, ArgsBB),
   HHBB =.. [F, HH|ArgsBB].
expand_bt(c, Was, H, HH):- append_term(Was, H, HH), !.
expand_bt(_, _, H, H).

set_bt_context(Ax):- nb_setval('$bt_context', Ax), bt_accept_low(bt_meta(Ax)).


maybe_dcg(HH, BB, Out):-  
  discontiguous(HH), multifile(HH),
  dcg_translate_rule((HH-->BB), Out).

bt_accept_fwd(Assert):- dbug1('==>'(did_bt_accept_fwd(Assert))).
bt_accept_low(AssertO):- assert(bt_data(AssertO)), bt_accept_fwd(AssertO).
bt_accept(Assert):- expand_bt(h, Assert, AssertO), bt_accept_low(AssertO).

:- export(bt_term_expansion/3).
:- module_transparent(bt_term_expansion/3).
bt_term_expansion(_M, (H ==>> B), Out):- !, 
  must((expand_bt(h, H, HH), expand_bt(b, B, BB), bt_accept_low(HH ==>> BB),  
  maybe_dcg(HH, BB, Out))).
bt_term_expansion(_M, (H ::= B), Out):- !,
  must((expand_bt(h, H, HH), expand_bt(c, B, BB),
  expand_term((HH:-BB), Out),
  bt_accept_low(HH ::= BB))).


/*
:- multifile(system:term_expansion/2).
:- dynamic(system:term_expansion/2).
:- module_transparent(system:term_expansion/2).
*/
term_expansion(In, Out):-  
  notrace((compound(In), In \= (:-_),
  prolog_load_context(module, M0),
  strip_module(M0:In, M, _))),
  bt_term_expansion(M, In, Out).

