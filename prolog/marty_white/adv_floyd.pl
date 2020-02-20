/*
% NomicMUD: A MUD server written in Prolog
%
% Some parts used Inform7, Guncho, PrologMUD and Marty's Prolog Adventure Prototype
% 
% July 10,1996 - John Eikenberry 
% Copyright (C) 2004 Marty White under the GNU GPL
% 
% Dec 13, 2035 - Douglas Miles
%
%
% Logicmoo Project changes:
%
% Main file.
%
*/

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CODE FILE SECTION
%:- bugout1(ensure_loaded('adv_robot_floyd')).
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

random_noise(Agent, [cap(subj(Agent)), Msg]) :- fail, 
 random_member(Msg, [
 'hums quietly to themself.',
 'inspects their inspection cover.',
 'buffs their chestplate.',
 'fidgets uncomfortably.'
 ]).

:- dynamic(mu_global:agent_last_action/3).
 

do_autonomous_cycle(Agent):- time_since_last_action(Agent,When), When > 10, !.
do_autonomous_cycle(Agent):- 
 time_since_last_action(Other,When),
 Other \== Agent, When < 1, !, 
 retractall(mu_global:agent_last_action(Other,_,_)),
 nop(bugout1(time_since_last_action_for(Other,When,Agent))).


% If actions are queued, no further thinking required. 
maybe_autonomous_decide_goal_action(Agent, Mem0, Mem2):- 
  has_satisfied_goals(Agent, Mem0, Mem1), !,
  maybe_autonomous_decide_goal_action(Agent, Mem1, Mem2).
% Is powered down
maybe_autonomous_decide_goal_action(Agent, Mem0, Mem0) :- 
 get_advstate(State),getprop(Agent, (powered = f), State),!.
% is not yet time to do something
maybe_autonomous_decide_goal_action(Agent, Mem0, Mem0) :- 
 notrace( \+ do_autonomous_cycle(Agent)), !.
% try to run the auto(Agent) command
maybe_autonomous_decide_goal_action(Agent, Mem0, Mem1) :- 
 add_todo(auto(Agent), Mem0, Mem1).



% If actions are queued, no further thinking required. 
autonomous_decide_action(Agent, Mem0, Mem2):- 
  has_satisfied_goals(Agent, Mem0, Mem1), !,
  autonomous_decide_action(Agent, Mem1, Mem2).

% If actions are queued, no further thinking required. 
autonomous_decide_action(Agent, Mem0, Mem0) :- 
 thought(todo([Action|_]), Mem0),
 (declared_advstate(h(in, Agent, Here))->true;Here=somewhere),
 (trival_act(Action)->true;bugout3('~w @ ~w: already about todo: ~w~n', [Agent, Here, Action], autonomous)).

% notices bugs
autonomous_decide_action(Agent, Mem0, _) :-
 once((agent_thought_model(Agent,ModelData, Mem0),
 (\+ in_agent_model(Agent, h(_, Agent, _), ModelData) -> (pprint(Mem0, always),pprint(ModelData, always)) ; true),
 must_mw1(in_agent_model(Agent,h(_Prep, Agent, Here), ModelData)),
 nonvar(Here))), 
 fail.

% If goals exist, try to solve them.
autonomous_decide_action(Agent, Mem0, Mem1) :-
 thought(goals([_|_]), Mem0),
 action_handle_goals(Agent, Mem0, Mem1),!.
autonomous_decide_action(Agent, Mem0, Mem1) :- 
 once(autonomous_create_new_goal(Agent, Mem0, Mem1);
% If no actions or goals, but there's an unexplored exit here, go that way.
 autonomous_decide_unexplored_exit(Agent, Mem0, Mem1);
 autonomous_decide_unexplored_object(Agent, Mem0, Mem1);
 autonomous_decide_follow_player(Agent, Mem0, Mem1);
 autonomous_decide_silly_emoter_action(Agent, Mem0, Mem1)).
autonomous_decide_action(Agent, Mem0, Mem0) :-
 (declared_advstate(h(in, Agent, Here))->true;Here=somewhere),
 nop(bugout3('~w: Can\'t think of anything to do.~n', [Agent-Here], autonomous+verbose)).% trace.


autonomous_create_new_goal(_Agent, _Mem0, _Mem1) :- fail.

% An unexplored exit here, go that way.
autonomous_decide_unexplored_exit(Agent, Mem0, Mem2) :-
 agent_thought_model(Agent,ModelData, Mem0),
 in_agent_model(Agent,h(exit(Prev), There, '<mystery>'(exit,_,_)), ModelData),
 in_agent_model(Agent,h(exit(Dir), Here, There), ModelData),
 in_agent_model(Agent,h(in, Agent, Here), ModelData),
 add_todo( go_dir(Agent, walk, Dir), Mem0, Mem1),
 add_todo( go_dir(Agent, walk, Prev), Mem1, Mem2).
autonomous_decide_unexplored_exit(Agent, Mem0, Mem1) :-
 agent_thought_model(Agent,ModelData, Mem0),
 in_agent_model(Agent,h(in, Agent, Here), ModelData),
 in_agent_model(Agent,h(exit(Dir), Here, '<mystery>'(exit,_,_)), ModelData),
 add_todo( go_dir(Agent, walk, Dir), Mem0, Mem1).

% An unexplored object!
autonomous_decide_unexplored_object(Agent, Mem0, Mem2) :-
 agent_thought_model(Agent,ModelData, Mem0),
 in_agent_model(Agent,h(_, '<mystery>'(closed,_, _), Object), ModelData),
 in_agent_model(Agent,h(in, Object, Here), ModelData),
 in_agent_model(Agent,h(in, Agent, Here), ModelData),
 add_todo( open(Agent, Object), Mem0, Mem1),
 add_todo( examine(Agent, see, Object), Mem1, Mem2).

autonomous_decide_unexplored_object(Agent, Mem0, Mem1) :- fail,
 agent_thought_model(Agent,ModelData, Mem0),
 in_agent_model(Agent,h(_, '<mystery>'(closed,_, _), Object), ModelData),
 add_todo( make_true(Agent, ~(h(_, Object, '<mystery>'(closed,_, _)))), Mem0, Mem1).


% Follow Player to adjacent rooms.
autonomous_decide_follow_player(Agent, Mem0, Mem1) :- % 1 is random(2),
 must_mw1((
 agent_thought_model(Agent,ModelData, Mem0),
 in_agent_model(Agent,h(_, Agent, Here), ModelData))),
 dif(Agent, Player), current_agent(Player),
 in_agent_model(Agent,h(_, Player, There), ModelData),
 in_agent_model(Agent,h(exit(Dir), Here, There), ModelData),
 add_todo(go_dir(Agent, walk, Dir), Mem0, Mem1).

autonomous_decide_silly_emoter_action(Agent, Mem0, Mem1) :-
 0 is random(5),
 random_noise(Agent, Msg),
 add_todo(emote(Agent, act, *, Msg), Mem0, Mem1).


always_action(go_dir(_,_,_)).

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CODE FILE SECTION
:- nop(ensure_loaded('adv_agent_listen')).
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

consider_text(Speaker, _EmoteType, Agent, Words, Mem0, Mem1):-
 eng2log(Agent, Words, Action, Mem0) -> 
 consider_request(Speaker, Agent, Action, Mem0, Mem1).

% For now, agents will attempt to satisfy all commands.
consider_request(Requester, Agent, Action, _M0, _M1) :-
 bugout3('~w: considering request from: ~w.~n', [Requester, Agent, Action], autonomous),
 fail.

consider_request(Requester, Agent, Query, M0, M1) :-
 do_introspect(Agent,Query, Answer, M0),
 %add_todo(print_(Answer), M0, M1).
 add_todo(emote(Agent, say, Requester, Answer), M0, M1).

consider_request(_Speaker, Agent, forget(goals), M0, M2) :-
 bugout3('~w: forgetting goals.~n', [Agent], autonomous),
 forget_always(goals(_), M0, M1),
 memorize(goals([]), M1, M2).
% Bring object back to Speaker.
consider_request(Speaker, _Agent, fetch(Object), M0, M1) :- 
 add_goal(h(held_by, Object, Speaker), M0, M1).
consider_request(_Speaker, Agent, put(Agent, Thing, Relation, Where), M0, M) :-
 add_goal(h(Relation, Thing, Where), M0, M).
consider_request(_Speaker, Agent, take(Agent, Thing), M0, M) :-
 add_goal(h(held_by, Thing, Agent), M0, M).
consider_request(_Speaker, Agent, drop(Agent, Object), M0, M1) :-
 add_goal(~(h(held_by, Object, Agent)), M0, M1).

consider_request(_Speaker, _Agent, AlwaysAction, M0, M1) :-  
 always_action(AlwaysAction),
 bugout3('Queueing action ~w~n', AlwaysAction, autonomous),
 add_todo(AlwaysAction, M0, M1).

consider_request(_Speaker, Agent, Action, M0, M1) :-
 bugout3('Finding goals for action: ~w~n', [Action], autonomous),
 initial_operators(Agent, Operators),
 findall(Effects,
   member(oper(Agent, Action, _Conds, Effects), Operators),
   [UnambiguousGoals]),
 bugout3('Request: ~w --> goals ~w.~n', [Action, UnambiguousGoals], autonomous),
 add_goals(UnambiguousGoals, M0, M1).

consider_request(_Speaker, _Agent, Action, M0, M1) :-
 bugout3('Queueing action: ~w~n', [Action], autonomous),
 add_todo(Action, M0, M1).
consider_request(_Speaker, Agent, Action, M0, M0) :-
 bugout3('~w: did not understand request: ~w~n', [Agent, Action], autonomous).


