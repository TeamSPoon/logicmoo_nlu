:-include(library('ec_planner/ec_test_incl')).
:-expects_dialect(pfc).

 /*  loading(always,
   	'examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e').
 */
%;
%; Copyright (c) 2005 IBM Corporation and others.
%; All rights reserved. This program and the accompanying materials
%; are made available under the terms of the Common Public License v1.0
%; which accompanies this distribution, and is available at
%; http://www.eclipse.org/legal/cpl-v10.html
%;
%; Contributors:
%; IBM - Initial implementation
%;
%; @book{Mueller:2006,
%;   author = "Erik T. Mueller",
%;   year = "2006",
%;   title = "Commonsense Reasoning",
%;   address = "San Francisco",
%;   publisher = "Morgan Kaufmann/Elsevier",
%; }
%;

% option encoding 3
:- set_ec_option(encoding, 3).

% option trajectory on
:- set_ec_option(trajectory, on).

% load foundations/Root.e

% load foundations/EC.e

% sort object
==> sort(object).

% sort agent
==> sort(agent).

% sort height: integer
==> subsort(height,integer).

% agent Nathan
==> t(agent,nathan).

% object Apple
==> t(object,apple).

% fluent Falling(object)
 %  fluent(falling(object)).
==> mpred_prop(falling(object),fluent).
==> meta_argtypes(falling(object)).

% fluent Height(object,height)
 %  fluent(height(object,height)).
==> mpred_prop(height(object,height),fluent).
==> meta_argtypes(height(object,height)).

% noninertial Height
==> noninertial(height).

% event Drop(agent,object)
 %  event(drop(agent,object)).
==> mpred_prop(drop(agent,object),event).
==> meta_argtypes(drop(agent,object)).

% event HitGround(object)
 %  event(hitGround(object)).
==> mpred_prop(hitGround(object),event).
==> meta_argtypes(hitGround(object)).


% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:39
%; Sigma
% [agent,object,time]
% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:42
% Initiates(Drop(agent,object),Falling(object),time).
axiom(initiates(drop(Agent, Object), falling(Object), Time),
    []).


% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:44
% [object,time]
% Terminates(HitGround(object),Falling(object),time).
% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:45
axiom(terminates(hitGround(Object), falling(Object), Time),
    []).


% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:47
%; Delta

% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:49
% Delta: 
next_axiom_uses(delta).
 


% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:49
% [object,time]
% HoldsAt(Falling(object),time) &
% HoldsAt(Height(object,0),time) ->
% Happens(HitGround(object),time).
% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:52
axiom(happens(hitGround(Object), Time),
   
    [ holds_at(falling(Object), Time),
      holds_at(height(Object, 0), Time)
    ]).

% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:54
% Delta: 
next_axiom_uses(delta).
 


% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:54
% Happens(Drop(Nathan,Apple),0).
axiom(happens(drop(nathan, apple), t),
    [is_time(0)]).


% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:56
%; Psi
% [object,height1,height2,time]
% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:59
% HoldsAt(Height(object,height1),time) &
% HoldsAt(Height(object,height2),time) ->
% height1=height2.
% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:61
axiom(Height1=Height2,
   
    [ holds_at(height(Object, Height1), Time),
      holds_at(height(Object, Height2), Time)
    ]).


% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:63
%; Pi
% [object,height1,height2,offset,time]
% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:66
% HoldsAt(Height(object,height1),time) &
% height2 = (height1 - offset) ->
% Trajectory(Falling(object),time,Height(object,height2),offset).
% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:68
axiom(trajectory(falling(Object), Time, height(Object, Height2), Offset),
   
    [ holds_at(height(Object, Height1), Time),
      equals(Height2, Height1-Offset)
    ]).


% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:70
% [object,height,offset,time]
% HoldsAt(Height(object,height),time) ->
% AntiTrajectory(Falling(object),time,Height(object,height),offset).
% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:72
axiom(antiTrajectory(falling(Object), Time, height(Object, Height), Offset),
    [holds_at(height(Object, Height), Time)]).


% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:74
%; Gamma


% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:76
% !HoldsAt(Falling(Apple),0).
 %  not(initially(falling(apple))).
axiom(not(initially(falling(apple))),
    []).


% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:77
% HoldsAt(Height(Apple,3),0).
axiom(initially(height(apple, 3)),
    []).

% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:79
% completion Delta Happens
% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:80
==> completion(delta).
==> completion(happens).

% range time 0 5
% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:82
==> range(time,0,5).

% range height 0 3
% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:83
==> range(height,0,3).

% range offset 1 3
% From /opt/logicmoo_workspace/packs_sys/small_adventure_games/prolog/ec_planner/examples/Mueller2006/Chapter7/FallingObjectWithAntiTrajectory.e:84
==> range(offset,1,3).
%; End of file.
