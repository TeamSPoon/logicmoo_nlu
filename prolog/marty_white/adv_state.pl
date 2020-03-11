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
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CODE FILE SECTION
:- nop(ensure_loaded('adv_main_states')).
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


:- multifile(extra_decl/2).
:- dynamic(extra_decl/2).
:- dynamic(undo/2).
%undo([u, u, u, u, u, u, u, u]).
:- dynamic(advstate_db/1).
advstate_db([]).

get_agent_memory(Agent, Mem):- 
   get_advstate(State),
   declared(props(Agent,Mem), State).

get_advstate_varname(Varname):- nb_current(advstate_var,Varname),Varname\==[],!.
get_advstate_varname(advstate).

get_advstate(State):- get_advstate_varname(Var),nb_current(Var,State).
set_advstate(State):- get_advstate_varname(Var),nb_setval(Var,State).

get_advstate_fork(StateC):- set_advstate(State),duplicate_term(State,StateC).

declared_advstate(Fact):- get_advstate(State),declared(Fact,State).

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CODE FILE SECTION
:- nop(ensure_loaded(adv_state)).
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% -----------------------------------------------------------------------------
% State may be implemented differently in the future (as a binary tree or
% hash table, etc.), but for now is a List. These (backtrackable) predicates
% hide the implementation:
% assert/record/declare/memorize/think/associate/know/retain/affirm/avow/
% insist/maintain/swear/posit/postulate/allege/assure/claim/proclaim
% retract/erase/forget/un-declare/unthink/repress/supress
% retrieve/remember/recall/ask/thought/think-of/reminisc/recognize/review/
% recollect/remind/look-up/research/establish/testify/sustain/attest/certify/
% verify/prove
% simulation: declare/undeclare/declared
% perception:
% memory: memorize/forget/thought

:- export(declare/3).
%:- defn_state_setter(declare(fact)).
select_from(Fact, State, NewState) :- notrace((assertion(var(NewState)),is_list(State))),!,notrace(select_from_list(Fact,State,NewState)).
select_from(Fact, inst(Object), inst(Object)):- !,
   get_advstate(State), 
   (declared(props(Object, PropList),State);PropList=[]),!, 
   select_from_list(Fact,PropList,NewPropList),
   select_always(props(Object,_),State,MidState),
   append([props(Object,NewPropList)], MidState, NewState),
   set_advstate(NewState).
select_from(Fact, type(Type), type(Type)):- !,
   get_advstate(State), 
   (declared(type_props(Type, PropList),State);PropList=[]),!, 
   select_from_list(Fact,PropList,NewPropList),
   select_always(type_props(Type,_),State,MidState),
   append([type_props(Type,NewPropList)], MidState, NewState),
   set_advstate(NewState).
select_from(Fact, Pred1Name, Pred1Name):- is_pred1_state(Pred1Name),append_term(Pred1Name,State,DBPred), (retract(DBPred);State=[]),!, select_from_list(Fact, State, NewState),DBPredNewState=..[Pred1Name,NewState], asserta(DBPredNewState).
select_from(Fact, VarName, VarName):- atom(VarName),nb_current(VarName,PropList), select_from_list(Fact,PropList,NewPropList),b_setval(VarName,NewPropList).
select_from(Fact, Object, Object):- callable(Fact),!, Fact=..[F|List], 
  Call=..[F, NewArg|List], 
  current_predicate(_,Call),!, 
  ignore( \+ \+ retract(Call)),
  NewArg=Object,
  asserta(Call).

select_from_list(Item, List, ListWithoutItem):- select(Item, List, ListWithoutItem).

% Like select_from, but always succeeds, for use in deleting.
select_always(Item, List, ListWithoutItem) :- select_from(Item, List, ListWithoutItem) -> true; ListWithoutItem=List.
 
% Like select_from, but with a default value if not found in List..
%select_default(Item, _DefaultItem, List, ListWithoutItem) :-
% select_from(Item, List, ListWithoutItem).
%select_default(DefaultItem, DefaultItem, ListWithoutItem, ListWithoutItem).

% Manipulate simulation state
%declare(Fact, State):- player_local(Fact, Player), !, declare(wishes(Player, Fact), State).
:- export(declare/3).
:- defn_state_setter(declare(fact)).
declare(Fact, State, NewState) :- notrace((assertion(var(NewState)),is_list(State))),!,notrace(declare_list(Fact,State,NewState)).
declare(Fact, inst(Object), inst(Object)):- !,
   get_advstate(State), 
   (declared(props(Object, PropList),State);PropList=[]),!, 
   declare_list(Fact,PropList,NewPropList),
   select_always(props(Object,_),State,MidState),
   append([props(Object,NewPropList)], MidState, NewState),
   set_advstate(NewState).
declare(Fact, type(Type), type(Type)):- !,
   get_advstate(State), 
   (declared(type_props(Type, PropList),State);PropList=[]),!, 
   declare_list(Fact,PropList,NewPropList),
   select_always(type_props(Type,_),State,MidState),
   append([type_props(Type,NewPropList)], MidState, NewState),
   set_advstate(NewState).
declare(Fact, Pred1Name, Pred1Name):- is_pred1_state(Pred1Name),append_term(Pred1Name,State,DBPred), (retract(DBPred);State=[]),!, declare_list(Fact, State, NewState),DBPredNewState=..[Pred1Name,NewState], asserta(DBPredNewState).
declare(Fact, VarName, VarName):- atom(VarName),nb_current(VarName,PropList), declare_list(Fact,PropList,NewPropList),b_setval(VarName,NewPropList).
declare(Fact, Object, Object):- callable(Fact),!, Fact=..[F|List], 
  Call=..[F, NewArg|List], 
  current_predicate(_,Call),!, 
  ignore( \+ \+ retract(Call)),
  NewArg=Object,
  asserta(Call).

is_pred1_state(istate).
is_pred1_state(statest).
is_pred1_state(parseFrame(_)).
is_pred1_state(advstate_db).

declare_list(Fact, State, NewState) :- assertion(compound(Fact)),assertion(var(NewState)), Fact==[], !, NewState = State.
declare_list((Fact1,Fact2), State, NewState) :- !,declare_list(Fact1, State, MidState),declare_list(Fact2, MidState, NewState).
declare_list([Fact1|Fact2], State, NewState) :- !,declare_list(Fact1, State, MidState),declare_list(Fact2, MidState, NewState).
declare_list(HasList, State, [NewFront|NewState]) :- 
  safe_functor(HasList,F,A), arg(A,HasList,PropList),is_list(PropList),
  safe_functor(Functor,F,A), \+ \+ type_functor(state,Functor),
  arg(1,HasList,Object), arg(1,Functor,Object),
  select_from(Functor,State,NewState),!,
  arg(A,Functor,OldPropList),assertion(is_list(OldPropList)),
  append(PropList,OldPropList,NewPropList),
  assertion(A=2;A=3), NewFront=..[F,Object,NewPropList]. 
declare_list(Fact, State, NewState) :- append([Fact],State,NewState).





%undeclare(Fact, State):- player_local(Fact, Player), !, undeclare(wishes(Player, Fact), State).
undeclare(Fact, State, NewState):- notrace(undeclare_(Fact, State, NewState)).
undeclare_(Fact, State, NewState) :- copy_term(State, Copy), select_from(Fact, State, NewState),
 assertion( \+ member(Copy , NewState)).

%undeclare_always(Fact, State):- player_local(Fact, Player), !, undeclare_always(wishes(Player, Fact), State).
undeclare_always(Fact, State, NewState) :- select_always(Fact, State, NewState).

%declared(Fact, State) :- player_local(Fact, Player), !, declared(wishes(Player, Fact), State).

:- export(declared/2).
:- defn_state_getter(declared(fact)).
declared(Fact, State) :-
  quietly(( is_list(State)->declared_list(Fact, State);declared_link(declared,Fact, State))).

declared_list(Fact, State) :- member(Fact, State).
declared_list(Fact, State) :- member(link(VarName), State), declared_link(declared, Fact, VarName).
declared_list(Fact, State) :- member(inst(Object), State), declared_link(declared, Fact, Object).

:- meta_predicate(declared_link(2,?,*)).
declared_link(Pred2, Fact, VarName):- strip_module(Pred2,_,Var), var(Var), !, declared_link(declared, Fact, VarName).
declared_link(Pred2, Fact, VarName):- atom(VarName), nb_current(VarName,PropList), call(Pred2, Fact, PropList).
declared_link(Pred2, Fact, inst(Obj)):- declared_advstate(props(Obj,PropList)), call(Pred2, Fact, PropList).
declared_link(Pred2, Fact, type(Type)):- declared_advstate(type_props(Type,PropList)), call(Pred2, Fact, PropList).
% declared_link(Pred2, Fact, inst_model(Obj,Type)):- declared_advstate(props(Type,PropList)), call(Pred2, Fact, PropList).
declared_link(Pred2, Fact, Object):- nonvar(Object), extra_decl(Object, PropList), call(Pred2, Fact, PropList).
declared_link(Pred2, Fact, Object):- get_advstate(State), direct_props(Object,PropList,State), call(Pred2, Fact, PropList).
declared_link(declared, Fact, Object):- callable(Fact), Fact=..[F|List], Call=..[F, Object|List], current_predicate(_,Call),!,call(Call).
declared_link(Pred2, Fact, Object):- var(Object), get_advstate(State),member(Prop, State),arg(1, Prop, Object), arg(2,Prop,PropList),
  call(Pred2, Fact, PropList).
  


% extra_decl(Object, PropList):- get_advstate(State), direct_props(Object,PropList,State).

% Entire state of simulation & agents is held in one list, so it can be easy
% to roll back. The state of the simulation consists of:
% object properties
% object relations
% percept queues for agents
% memories for agents (actually logically distinct from the simulation)
% Note that the simulation does not maintain any history.
% TODO: change state into a term:
% ss(Objects, Relationships, PerceptQueues, AgentMinds)
% TODO:
% store initial state as clauses which are collected up and put into a list,
% like the operators are, to provide proper prolog variable management.
:- defn_state_getter(get_object_props(agent,model)).
get_object_props(Obj, ObjectProps, M0):- var(M0), get_advstate(M0),!, get_object_props(Obj, ObjectProps, M0).
get_object_props(Obj, ObjectProps, M0):- \+ is_list(M0), !, declared_link(get_object_props(Obj), ObjectProps, M0).
get_object_props(Obj, ObjectProps, M0):- memberchk(propOf(_,Obj),M0), ObjectProps = M0, !.
get_object_props(Obj, ObjectProps, M0):- declared(props(Obj,ObjectProps),M0),!.


get_objects(Spec, Set, State):- 
 quietly((must_input_state(State), 
  get_objects_(Spec, List, State, im(State)), !, 
  list_to_set(List,Set))).
%get_objects(_Spec, [player1, floyd], _State):-!.

get_objects_(_Spec, [], [], im(_)) :- !.
get_objects_(Spec, OutList, [Store|StateList], im(S0)):- 
 (( stores_props(Store, Object, PropList) -> filter_spec(Spec, PropList))
 -> OutList = [Object|MidList]
 ; OutList = MidList), !,
 get_objects_(Spec, MidList, StateList, im(S0)).

stores_props(perceptq(Agent, PropList), Agent, PropList).
%stores_props(type_props(Agent, PropList), Agent, PropList).
stores_props(memories(Agent, PropList), Agent, PropList).
stores_props(props(Object, PropList), Object, PropList).




as_first_arg(Object, Prop, Element):-
  callable(Prop), Prop=..[Name| Value], Element =..[Name, Object| Value].


% get_all_props(Object, AllProps, S0):- findall(Prop,getprop(Object, Prop, S0),AllProps).
:- defn_state_getter(getprop(thing, nv)).
getprop(Object, Prop, S0) :- quietly((correct_prop(Prop,PropList),getprop0(Object, PropList, S0))).

getprop0(Object, Prop, S0):-  
  ((as_first_arg(Object, Prop, Element), declared(Element,S0)) 
     *-> true ; getprop1(Object, [], Object, Prop, S0)).

getprop1(Orig, AlreadyUsed, Object, Prop, S0) :- 
 direct_props(Object, PropList, S0),
 ( declared(Prop, PropList)*-> true ; 
 inherited_prop1(Orig, AlreadyUsed, Object, Prop, PropList, S0)).

inherited_prop1(Orig, AlreadyUsed, _Object, Prop, PropList, S0):- 
 member(inherit(Delegate,t), PropList),
 \+ member(inherit(Delegate, t), AlreadyUsed),
 \+ member(inherit(Delegate, f), PropList),
 \+ member(inherited(Delegate), AlreadyUsed),
 append(AlreadyUsed, PropList, AllPropList),
 \+ member(isnt(Delegate), AllPropList),
 getprop1(Orig, AllPropList, Delegate, Prop, S0).

inherited_prop1(_Orig, AlreadyUsed, _Object, Prop, PropList, _S0):- 
 member(link(Delegate), PropList),
 \+ member(link(Delegate), AlreadyUsed),
 nb_current(Delegate,NewProps),
 member(Prop,NewProps).


direct_props(Object, PropList, State):- 
 (var(State)->get_advstate(State); true),
 (declared(props(Object, PropList), State) 
 *-> true 
 ; ( declared(type_props(Object, PropList), State) 
 *-> true 
  ; extra_decl(Object, PropList))).

direct_props_or(Object,PropList, Default, S0) :-
 direct_props(Object, PropList, S0)*->true; PropList=Default.

object_props_or(Object,PropList, Default, S0) :-
 declared(props(Object,PropList),S0)*->true; PropList=Default.

 :- meta_predicate each_prop(3,?,?,?).
each_prop(_, [], S0, S0) :-!.
each_prop(Pred, [Prop|List], S0, S2) :- !,
  each_prop(Pred, Prop, S0, S1),
  each_prop(Pred, List, S1, S2).
each_prop(Pred, Prop, S0, S1):- assertion(compound(Prop)), call(Pred, Prop, S0, S1),!.


% Remove Prop.
:- defn_state_setter(delprop(thing, nv)).
delprop(Object, Prop, S0, S2) :- notrace(must_mw1((correct_props(Object,Prop,PropList), each_prop(delprop_(Object), PropList, S0, S2)))).
delprop_(Object, Prop, S0, S2) :- 
 undeclare(props(Object, PropList), S0, S1),
 select_from(Prop, PropList, NewPropList),
 declare(props(Object, NewPropList), S1, S2).

% Remove Prop Always.
:- defn_state_setter(delprop_always(thing, nv)).
delprop_always(Object, Prop, S0, S2) :- notrace(must_mw1((correct_props(Object,Prop,PropList), each_prop(delprop_always_(Object), PropList, S0, S2)))).
delprop_always_(Object, Prop, S0, S2) :-  delprop_(Object, Prop, S0, S2), !.
delprop_always_(_Object, _Prop, S0, S0).

% Replace or create Prop.
:- defn_state_setter(setprop(thing, nv)).
setprop(Object, Prop, S0, S2) :- notrace((correct_props(Object,Prop,PropList), each_prop(setprop_(Object), PropList, S0, S2))).

setprop_(Object, Prop, S0, S2) :-  
 direct_props_or(Object, PropList, [], S0),
 undeclare_always(props(Object, _), S0, S1),
 safe_functor(Prop,F,A),
 duplicate_term(Prop,Old),
 nb_setarg(A,Old,_),
 (select_from(Old, PropList, PropList2) ->
 (upmerge_prop(F,A,Old,Prop,Merged) ->
  ((Old==Merged,fail) -> S2=S0 ; 
  (append([Merged], PropList2, PropList3),declare(props(Object, PropList3), S1, S2)));
 append([Prop], PropList, PropList3),declare(props(Object, PropList3), S1, S2));
 (append([Prop], PropList, PropList3),declare(props(Object, PropList3), S1, S2))).

% Update or create Prop.
:- defn_state_setter(updateprop(thing, nv)).
updateprop(Object, Prop, S0, S2) :- notrace((correct_props(Object,Prop,PropList), each_prop(updateprop_(Object), PropList, S0, S2))).

updateprop_(Object, Prop, S0, S2) :- 
 assertion(compound(Prop)),
 direct_props_or(Object, PropList, [], S0),
 (member(Prop,PropList)
 -> S0=S2;
 (undeclare_always(props(Object, _), S0, S1),
 updateprop_1(Object, Prop, PropList, S1, S2))).

updateprop_1(Object, Prop, PropList, S0, S2) :-
 safe_functor(Prop,F,A),
 duplicate_term(Prop,Old),
 nb_setarg(A,Old,_),

 (select_from(Old, PropList, PropList2) ->
 (upmerge_prop(F,A,Old,Prop,Merged) ->
  ((Old==Merged,fail) -> declare(props(Object, PropList), S0, S2) ; % no update
  (append([Merged], PropList2, PropList3),declare(props(Object, PropList3), S0, S2)));
 append([Prop], PropList, PropList3),declare(props(Object, PropList3), S0, S2));
 (append([Prop], PropList, PropList3),declare(props(Object, PropList3), S0, S2))).

      
/*

setprop(Object, Prop, S0, S2) :-
 %must_mw1((
 %assertion(\+ atom(Prop)),
 undeclare(props(Object, PropList), S0, S1),
 select_always(Prop, PropList, PropList2),
 append([Prop], PropList2, PropList3),
 declare(props(Object, PropList3), S1, S2))
 ->true;
 declare(props(Object, [Prop]), S0, S2)).
*/

upmerge_prop(_,_,Before,After,Result):- Before==After,!, Result=Before.
upmerge_prop(F,N,Before,After,Result):- arg(N,Before,B),arg(N,After,A),!,
 merge_value(F,N,B,A,R),duplicate_term(After,Result),nb_setarg(N,Result,R).

merge_value(F,N,B,A,RO):- text_prop(F), \+ is_list(B),!,merge_value(F,N,[B],A,RO).
merge_value(F,N,B,A,RO):- text_prop(F), \+ is_list(A),!,merge_value(F,N,B,[A],RO).
merge_value(F,_,_,A,R):- single_valued_prop(F),!,A=R.

merge_value(=,2,_,V,R):- !, R = V.

merge_value(_,_,_,t,R):- !, R = t.
merge_value(_,_,_,f,R):- !, R = f.
merge_value(_,_,_,[],R):- !, R = [].
merge_value(_,_,_,A,R):- number(A),!,A=R.

merge_value(_F,1,B,A,R):- B == A, !, R = A.

merge_value(_F,1,B,A,RO):- (is_list(B);is_list(A)),flatten([A,B],R),!,list_to_set(R,RO).

merge_value(_, 1,_,A,R):- number(A),!,A=R.
merge_value(_,1,_,_,_):- !,fail.
merge_value(_F,_,_B,A,R):- R = A.

text_prop(nouns).
text_prop(adjs).
text_prop(desc).

single_valued_prop(name).
single_valued_prop(desc).
single_valued_prop(prefix).
single_valued_prop(mass).
single_valued_prop(volume).


:- export(is_state_info/1).

is_state_info(StateInfo):- \+ compound(StateInfo), !, fail.
is_state_info(StateInfo):- safe_functor(StateInfo, F, A),
   (functor_arity_state(F, A)->true; (A>2, functor_arity_state(F, 2))).


functor_arity_state(F, A):- is_type_functor(state, F, A).
functor_arity_state(type, 2).

is_spatial_rel(worn_by).
is_spatial_rel(held_by).
is_spatial_rel(in).
is_spatial_rel(on).
is_spatial_rel(exit).

update_running(StateInfo):- ignore((get_advstate(S0),!,declare(StateInfo,S0,S1),!,set_advstate(S1))),!.
% update_running(_StateInfo).

%push_to_state(State):- push_to_obj(world,State).


push_to_state(StateInfo):- end_of_list == StateInfo, !.  
push_to_state(StateInfo):- is_codelist(StateInfo),any_to_string(StateInfo,SStateInfo),!,push_to_state(SStateInfo).
push_to_state(StateInfo):- is_charlist(StateInfo),any_to_string(StateInfo,SStateInfo),!,push_to_state(SStateInfo).
push_to_state(StateInfo):- string(StateInfo), parse_kind(state,StateInfo,Logic), push_to_state(Logic).
push_to_state(StateInfo):- is_list(StateInfo), !, maplist(push_to_state, StateInfo).
push_to_state(StateInfo):- \+ compound(StateInfo),trace_or_throw(unknown_push_to_state(StateInfo)),!.
push_to_state(type(Type, Conj)):-  !, push_to_state(props(type(Type), Conj)).
push_to_state(props(type(Type), Conj)):- !, props_to_list(Conj, List), push_to_state(type_props(Type, List)).
push_to_state(props(Obj, Conj)):-  props_to_list(Conj, List) -> Conj\== List, !, push_to_state(props(Obj, List)).
push_to_state(type_props(Obj, Conj)):-  props_to_list(Conj, List) -> Conj\== List, !, push_to_state(type_props(Obj, List)).
push_to_state(StateInfo):- StateInfo=..[F, Obj, E1, E2|More], functor_arity_state(F, 2), !, StateInfoNew=..[F, Obj, [E1, E2|More]], !, push_to_state(StateInfoNew).
push_to_state(StateInfo):- props_to_list(StateInfo, StateInfo2)->StateInfo2\=[StateInfo], !, push_to_state(StateInfo2).

push_to_state(eng2log(Text)):- must(eng2log(istate, Text,Translation,[])), push_to_state(Translation).
push_to_state(eng2log(_Text,Translation)):- !, push_to_state(Translation).
push_to_state(assert_text(Text)):- must(eng2log(istate, Text,Translation,[])), push_to_state(Translation).
push_to_state(assert_text(Where,Text)):- !, must(eng2log(Where, Text,Translation,[])), push_to_state(Translation).

push_to_state(StateInfo):- is_state_info(StateInfo), !, declare(StateInfo, istate, _), update_running(StateInfo).
push_to_state(StateInfo):- forall(arg(_, StateInfo, Sub), push_to_state(Sub)).

correct_props(_Obj, PropsIn, PropsOut):- props_to_list(PropsIn, PropsOut), !.

check_atom(Atom):- assertion(atom(Atom)).

props_to_list(Nil, []):- assertion(\+ var(Nil)), Nil==[], !.
props_to_list(end_of_list, []):- !.
props_to_list(Before, [After]):- (correct_prop(Before, After) -> Before\==After), !.
props_to_list(NC, [nc(NC)]):- \+ compound(NC), !.
props_to_list(oper(_, _, _), []):- !.
props_to_list([A|B], ABL):- !,
   props_to_list(A, AL),
   props_to_list(B, BL),
   append(AL, BL, ABL).
props_to_list((A, B), ABL):- !,
   props_to_list(A, AL),
   props_to_list(B, BL),
   append(AL, BL, ABL).
props_to_list(Other, [Other]).

correct_prop(NC, NO):- var(NC), !, NC = NO.
correct_prop(        (Type), inherit(Type, t)):- atom(Type).
correct_prop(~inherit(Type), inherit(Type, f)):- atom(Type), !.
correct_prop( inherit(Type), inherit(Type, t)):- check_atom(Type), !.
correct_prop(     isa(Type), inherit(Type, t)):- check_atom(Type), !.
correct_prop(    isnt(Type), inherit(Type, f)):- check_atom(Type), !.
correct_prop(       ~(Type), inherit(Type, f)):- atom(Type), !.
correct_prop(NC, nc(NC)):- \+ compound(NC), !.

correct_prop(HPRED, h(FS, X, Y)):- HPRED=..[F, S, X, Y], is_spatial_rel(F), !, FS=..[F, S].
correct_prop(HPRED, h(F, X, Y)):- HPRED=..[F, X, Y], is_spatial_rel(F), !.
correct_prop(          SV, N=V):- SV=..[N, V], single_valued_prop(N), !.

correct_prop( (can(Verb)), can_be(Verb, t)):- nop(check_atom(Verb)).
correct_prop(~(can(Verb)), can_be(Verb, f)):- nop(check_atom(Verb)).
correct_prop( (can(Verb,TF)),    can_be(Verb, TF)):- nop(check_atom(Verb)).
correct_prop( (knows_verbs(Verb)), knows_verbs(Verb, t)):- nop(check_atom(Verb)).
correct_prop(~(knows_verbs(Verb)), knows_verbs(Verb, f)):- nop(check_atom(Verb)).
correct_prop( (has_rel(Verb)), has_rel(Verb, t)):- nop(check_atom(Verb)).
correct_prop(~(has_rel(Verb)), has_rel(Verb, f)):- nop(check_atom(Verb)).
correct_prop(  Other,Other).


% for  the "TheSims" bot AI which will make the bots do what TheSims characters do... (they dont use the planner they use a simple priority routine)  
