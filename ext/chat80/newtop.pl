/*

 _________________________________________________________________________
|	Copyright (C) 1982						  |
|									  |
|	David Warren,							  |
|		SRI International, 333 Ravenswood Ave., Menlo Park,	  |
|		California 94025, USA;					  |
|									  |
|	Fernando Pereira,						  |
|		Dept. of Archi80tecture, University of Edinburgh,		  |
|		20 Chambers St., Edinburgh EH1 1JZ, Scotland		  |
|									  |
|	Thi80s program may be used, copied, altered or included in other	  |
|	programs only for academic purposes and provided that the	  |
|	authorshi80p of the initial program is aknowledged.		  |
|	Use for commercial purposes without the previous written 	  |
|	agreement of the authors is forbidden.				  |
|_________________________________________________________________________|

*/



% Chat-80 : A small subset of English for database querying.

/* Control loop */

:-share_mp(hi80/0).
hi80 :-
   hi80(user).

:-share_mp(hi80/1).
hi80(File):- hi80(report,File).

:-share_mp(hi80/2).
hi80(Callback,File):-
    absolute_file_name(File,FOpen),
    setup_call_cleanup((
     open(FOpen,read, Fd, [alias(FOpen)]),
      see(Fd)),
      (( repeat,
         ask80(Fd,P),
         control80(Callback,P), !)),
   end(FOpen)).

ask80(user,P) :- 
  setup_call_cleanup(see(user),
   (prompt(_,'Question: '),
   readin80:read_sent(P)),seen).

ask80(_F,P) :- readin80:read_sent(P), doing80(P,0),!.

doing80([],_) :- !,nl.
doing80([X|L],N0) :-
   out80(X),  
   advance80(X,N0,N),
   doing80(L,N),!.

out80(nb(X)) :- !,
   reply(X).
out80(A) :-
   reply(A).

advance80(X,N0,N) :-
   uses80(X,K),
   M is N0+K,
 ( M>72, !,
      nl,
      N is 0;
   N is M+1,
      put(" ")).

uses80(nb(X),N) :- !,
   chars80(X,N).
uses80(X,N) :-
   chars80(X,N).

chars80(X,N) :- atomic(X), !,
   name(X,L),
   length(L,N).
chars80(_,2).

end(user) :- !.
end(F) :- 
   told,seen,
   catch(close(F),_,seen),!.

number_to_nb(nb(N),nb(N)):-!.
number_to_nb(A,nb(N)):- atom(A),atom_number(A,N),!.
number_to_nb(N,nb(N)):- number(N),!.
number_to_nb(A,A).

:-share_mp(into_text80/2).
into_text80(I,O):- notrace((into_control80(I,M),!,maplist(number_to_nb,M,O))).
into_control80(NotList,Out):-  
  string(NotList),string_to_atom(NotList,Atom),!,
  into_control80(Atom,Out).
into_control80(NotList,Out):-  atom(NotList),
   on_x_fail(tokenizer:tokenize(NotList,Tokens)),!,
   into_control80(Tokens,Out).
into_control80(NotList,Out):-  
   \+ is_list(NotList), 
   convert_to_atoms_list(NotList,List), !,
   into_control80(List,Out).
into_control80([W|ListIn],Out):- 
   any_to_atom(W,AW),W\=@=AW,
   maplist(any_to_atom,ListIn,AList),!,
   into_control80([AW|AList],Out).
into_control80(ListIn,Out):- 
   append(Left,[Last],ListIn), 
 ( \+ atom_length(Last,1),
   char_type(P,period), % covers Q, ! , etc
   atom_concat(Word,P,Last)),
   append(Left,[Word,P],ListMid),!,
   into_control80(ListMid,Out).
into_control80(ListIn,Out):- 
   append(Left,[P],ListIn), 
 (\+ atom_length(P,1); \+ char_type(P,period)),!,
   append(ListIn,[('.')],ListMid),!,
   into_control80(ListMid,Out).
into_control80([W,'.'],Out):- 
   downcase_atom(W,D),W\==D,!,
   into_control80([D,'.'],Out).
into_control80([W,A,B|More],Out):- 
   downcase_atom(W,D),
   Out=[D,A,B|More],!.
into_control80(Out,Out):- !.



:-share_mp(control80/1).
% t_l:tracing80 ?
control80(U):-locally([],control80(report,U)).

:-share_mp(control80/2).
control80(_,O):- O==[],!.
control80(Callback,Was):- 
   (into_text80(Was,Out)-> Was\==Out), !,
   control80(Callback,Out).
control80(Callback,[bye,'.']) :- !,
   call(Callback,"Goodbye",'control80',!,call),
   reply('Cheerio.'),!,nl.

control80(Callback,[trace,'.']) :- !,
   assert(t_l:tracing80),
   call(Callback,assert(t_l:tracing80),'t_l:tracing80',true,boolean),
   reply('Tracing from now on!'), nl, fail.

control80(Callback,[do,not,trace,'.']) :-
   retract(t_l:tracing80), !,
   call(Callback,retract(t_l:tracing80),'t_l:tracing80',false,boolean),
   reply('No longer tracing.'), nl, fail.

control80(Callback,U) :- 
  locally(t_l:tracing80, 
     call_in_banner(U,(ignore(process_run(Callback,U,_List,_Time))))),fail.
   
:- share_mp(trace_chat80/1).
trace_chat80(U):-
 locally(t_l:tracing80,
           locally(t_l:chat80_interactive,
            locally_hide(t_l:useOnlyExternalDBs,
             locally_hide(thglobal:use_cyc_database,
              ignore(control80(U)))))).

:- share_mp(test_chat80/1).
test_chat80(U):-
 locally(t_l:tracing80_nop,
           locally(t_l:chat80_interactive_nop,
            locally_hide(t_l:useOnlyExternalDBs,
             locally_hide(thglobal:use_cyc_database,
              ignore(control80(U)))))).
   
:- baseKB:import(test_chat80/1).


get_prev_run_results(U,List,Time):-must_test_801(U,List,Time),!.
get_prev_run_results(U,List,Time):-must_test_80(U,List,Time),!.
get_prev_run_results(_,[],[]).

:- share_mp(call_in_banner/2).
call_in_banner(U,Call):- setup_call_cleanup(p2(begin:U),Call,p2(end:U)).


reportDif(_U,List,BList,_Time,_BTime):- forall(member(N=V,List),
  ignore((member(N=BV,BList), \+ (BV = V), dfmt('~n1) ~q = ~q ~~n2) ~q = ~q ~n',[N,V,N,BV])))).

:-share_mp(process_run_diff/4).
process_run_diff(Callback,U,BList,BTime):-
 call_in_banner(U,( process_run(Callback,U,List,Time),
   ignore((reportDif(U,List,BList,Time,BTime))))),!.
   

:-share_mp(process_run/4).   
process_run(Callback,U,List,Time):-
  runtime(StartParse),   
  process_run(Callback,StartParse,U,List,Time),!.

process_run(Callback,StartParse,U,List,Time):-    
    show_failure(process_run_real(Callback,StartParse,U,List,Time)) *-> true; 
      process_run_unreal(Callback,StartParse,U,List,Time).
    
   
process_run_unreal(Callback,Start,U,[sent=(U),parse=(E),sem=(error),qplan=(error),answers=(failed)],[time(WholeTime)]):-   
         runtime(Stop),WholeTime is Stop-Start,
         dumpST,
         reply(Callback - 'Failed after '-WholeTime-' to understand: '+ [sent=(U),parse=(E),sem=(error),qplan=(error),answers=(failed)] ), nl,
         sleep(2).

if_try(Cond,DoAll):- call(Cond) -> call(DoAll); sleep(0.5).

p3(BE):-dfmt('~n% ============================================~w=============================================================~n',[BE]).
p2(begin:Term):-!, p3('BEGIN'), p4(Term),p1.
p2(end:Term):-!, p1, p4(Term),p3('END'),dfmt('~n~n').
p2(Term):- p3(''), p4(Term), p3('').
p1:-dfmt('~n% ---------------------------------------------------------------------------------------------------~n',[]).
p4(Term):-dfmt('~n%                       ~q~n',[Term]).

words_to_w2(U,W2):- words_to_w22(U,W2),!.

words_to_w22(U,W2):-var(U),must(W2=U).
words_to_w22([],W2):- !, must(W2=[]).
words_to_w22([W|WL],[W2|W2L]):- !, w_to_w2(W,W2),words_to_w2(WL,W2L).
words_to_w22(U,W2):- convert_to_atoms_list(U,List),!,words_to_w2(List,W2).
%words_to_w2(U,W2):- compound(U),must(W2=U).


:-thread_local t_l:old_text/0.

t_l:old_text.
% TODO dont use open marker use []
use_open_marker.


w_to_w2(W,W):-t_l:old_text,!.
w_to_w2(Var,Var):-var(Var),!.
w_to_w2(w(Txt,Props),w(Txt,Props)):-!.
% w_to_w2([Prop,Txt],w(Txt,[Prop])):-!.
w_to_w2(w(X),w(X,[])):-!.
w_to_w2(S,w(A,open)):-use_open_marker,atomic(S),atom_string(A,S),!.
w_to_w2(S,w(S,open)):-use_open_marker,!.
w_to_w2(S,w(A,[])):-atomic(S),atom_string(A,S),!.
w_to_w2(U,w(U,[])):-compound(U),!.
w_to_w2(X,w(X,[])):-!.

w2_to_w(w(Txt,_),Txt):-!.
w2_to_w(Txt,Txt).

%theTextC(W1,CYCPOS,Y=W1)  ---> {t_l:old_text,!},[W1],{W1=Y}.
theTextC(A,_,F=A,B,C,D,E) :- t_l:old_text, !,terminal(A, B, C, D, E),A=F,is_sane_nv(A).
theTextC(A,_,F=A,B,C,D,E) :- !,terminal(w(A, _), B, C, D, E),A=F,is_sane_nv(A).
%theTextC(W1,CYCPOS,Y=W1)  ---> {!},[w(W1,_)],{W1=Y}.
%theTextC(W1,CYCPOS,WHY) ---> [W2],{memoize_pos_to_db(WHY,CYCPOS,W2,W1)}.
theTextC(H,F,E,A,B,C,D) :- fail, is_sane(C), terminal(G, A, B, C, D),memoize_pos_to_db(E, F, G, H),is_sane_nv(H).

/*
theTextC(W1,_CYCPOS,Y=W1) ---> {t_l:old_text,!},[W1],{W1=Y}.
%theTextC(W1,_CYCPOS,Y=W1) ---> {!},[w(W1,_)],{W1=Y}.
theTextC(A,_,F=A,B,C,D,E) :- !,terminal(w(A, _), B, C, D, E),A=F,is_sane_nv(A).
theTextC(W1,_CYCPOS,WHY) ---> {t_l:old_text,!},[W1],WHY.
% theTextC(W1,CYCPOS,WHY) ---> {trace_or_throw(memoize_pos_to_db(WHY,CYCPOS,W2,W1))},[W2],{memoize_pos_to_db(WHY,CYCPOS,W2,W1)}.
*/

term_depth(C,TD):-notrace(term_depth0(C,TD)).
term_depth0(C,1):-var(C),!.
term_depth0(C,0):-not(compound(C)),!.
term_depth0(C,TDO):-is_list(C),!,findall(D,(member(T,C),term_depth0(T,D)),DL), max_list([0|DL],TD),TDO is TD+1,!.
term_depth0(C,TDO):-C=..[_|LIST],findall(D,(member(T,LIST),term_depth0(T,D)),DL), max_list([0|DL],TD),TDO is TD+1,!.


is_sane(C):-must((term_depth(C,D),D<100)).
is_sane_nv(C):-must((nonvar(C),term_depth(C,D),D<100)).

sent_to_parsed(U,E):- deepen_pos(parser_chat80:sentence80(E,U,[],[],[])).

:- share_mp(deepen_pos/1).
:- export(deepen_pos/1).
:-meta_predicate(deepen_pos(0)).
deepen_pos(Call):- deepen_pos_0(Call) *->  true ; locally(t_l:useAltPOS,deepen_pos_0(Call)).
:- share_mp(deepen_pos_0/1).
:-meta_predicate(deepen_pos_0(0)).
deepen_pos_0(Call):-one_must(Call,locally(t_l:usePlTalk,Call)).


% any_to_string("How many countries are there?",X),splt_words(X,Y,Z),vars_to_ucase(Y,Z),maplist(call,Z)

:-share_mp(process_run_real/5).
process_run_real(Callback,StartParse,UIn,MUSTP,WTIME) :-
   must([sent=(U),parse=(E),sem=(S),qplan=(QP),answers=(Results)]=MUSTP),
   must([time(WholeTime)]=WTIME),
   flag(sentenceTrial,_,0),
   ignore((var(Callback),Callback=report)),
   must(words_to_w2(UIn,U)),!,
   call(Callback,U,'Sentence'(Callback),0,expr),
   ignore((var(StartParse),runtime(StartParse))),!,
   (if_try(nonvar(U),sent_to_parsed(U,E)) *-> ignore((U\==UIn,call(Callback,U,'POS Sentence'(Callback),0,expr))); (call(Callback,U,'Rewire Sentence'(Callback),0,expr),!,fail)),
   (flag(sentenceTrial,TZ,TZ), TZ>5 -> (!) ; true),
   once((
      runtime(StopParse),
      ParseTime is StopParse - StartParse,
      call(Callback,E,'Parse',ParseTime,portray),  
      (flag(sentenceTrial,TZ2,TZ2+1), TZ2>5 -> (!,fail) ; true),
      runtime(StartSem))),
   once((if_try(nonvar(E),deepen_pos(sent_to_prelogic(E,S))))),
   runtime(StopSem),
   SemTime is StopSem - StartSem,
   call(Callback,S,'Semantics',SemTime,expr),
   runtime(StartPlan),
   once(if_try(nonvar(S),deepen_pos(qplan(S,S1)))),
   copy_term80(S1,QP),
   runtime(StopPlan),
   TimePlan is StopPlan - StartPlan,
   if_try(S\=S1,call(Callback,S1,'Planning',TimePlan,expr)),
   runtime(StartAns),
   results80(S1,Results), Results\=[],!,
   runtime(StopAns),
   TimeAns is StopAns - StartAns,
   call(Callback,Results,'Reply',TimeAns,expr),
   WholeTime is ParseTime + SemTime + TimePlan + TimeAns,
   p1.

results80(S1,Results):- nonvar(S1),findall(Res,deepen_pos((answer802(S1,Res),Res\=[])),Results).


:-share_mp(test_quiet/4).
test_quiet(_,_,_,_).

:-share_mp(report/4).
report(Item,Label, Time, Mode) :- (\+ t_l:tracing80 ; Time==0), !,
   nop((nl, write(Label), write(':(report) '),ignore(safely_call_ro(report_item(Mode,Item))))),!.
report(Item,Label,Time,Mode) :- 
   nl, write(Label), write(':(report4) '), write(Time), write(' sec(s).'), nl,
   ignore(safely_call_ro(report_item(Mode,Item))),!.
report(_,_,_,_).


call_with_limits(Call):- call_with_limited_reason(Call,FailedWhy),(FailedWhy=success(_)-> true; throw(failed(FailedWhy,Call))).
call_with_limited_reason(Call,Result):-  
 catch(
  call_with_time_limit(7,
   ((Call,(deterministic(yes)->Result=success(det);Result=success(nondet)))
     *->true;Result=failed)),Result,true).

% call_with_limits0(Copy):-call_with_time_limit(10,call_with_depth_limit(call_with_inference_limit(Copy,10000,_),500,_)).

safely_call_ro(Call):-copy_term(Call,Copy),catchv(call_with_limits(Copy),E,(dmsg(error_safely_call(E,in,Copy)),!,fail)).
safely_call(Call):-copy_term(Call,Copy),catchv((Copy,Call=Copy),E,(dmsg(error_safely_call(E,in,Copy)),!,fail)).

report_item(none,_).
report_item(T,Var):-var(Var),!,write('FAILED: '+T),nl.
report_item(portray,Item) :-
   portray_clause((Item:-Item)), nl.
report_item(expr,Item) :-
   write_tree(Item), nl.
report_item(tree,Item) :-
   print_tree(Item), nl.

runtime(TimeSecs) :- statistics(runtime,[MSec,_]), TimeSecs is MSec/1000,!.


quote(A&R) :-
   atom(A), !,
   quote_amp(R).
quote(_-_).
quote('--'(_,_)).
quote(_+_).
quote(verb(_,_,_,_,_,_Kind)).
quote(wh(_)).
quote(nameOf(_)).
quote(prep(_)).
quote(det(_)).
quote(quant(_,_)).
quote(int_det(_)).

quote_amp(F):- compound(F), functor(F,'$VAR',1),!.
quote_amp(R) :-
   quote(R).


sent_to_prelogic(S0,S) :-
   i_sentence(S0,S1),
   clausify80(S1,S),!.

sent_to_prelogic(S0,S) :- 
  t_l:chat80_interactive,plt,!,
   must((
   i_sentence(S0,S1),
   clausify80(S1,S))),!.

simplify80(C,C0):-var(C),dmsg(var_simplify(C,C0)),!,fail.
simplify80(C,(P:-R)) :- !,
   unequalise(C,(P:-Q)),
   simplify80(Q,R,true).

simplify80(C,C0,C1):-var(C),dmsg(var_simplify(C,C0,C1)),fail.
simplify80(C,C,R):-var(C),!,R=C.
simplify80(setof(X,P0,S),R,R0) :- !,
   simplify80(P0,P,true),
   revand(R0,setof(X,P,S),R).
simplify80((P,Q),R,R0) :-
   simplify80(Q,R1,R0),
   simplify80(P,R,R1).
simplify80(true,R,R) :- !.
simplify80(X^P0,R,R0) :- !,
   simplify80(P0,P,true),
   revand(R0,X^P,R).
simplify80(numberof(X,P0,Y),R,R0) :- !,
   simplify80(P0,P,true),
   revand(R0,numberof(X,P,Y),R).
simplify80(\+P0,R,R0) :- !,
   simplify80(P0,P1,true),
   simplify_not(P1,P),
   revand(R0,P,R).
simplify80(P,R,R0) :-
   revand(R0,P,R).

simplify_not(\+P,P) :- !.
simplify_not(P,\+P).

revand(true,P,P) :- !.
revand(P,true,P) :- !.
revand(P,Q,(Q,P)).

unequalise(C0,C) :-
   numbervars80(C0,1,N),
   functor(V,v,N),
   functor(M,v,N),
   inv_map_enter(C0,V,M,C).

inv_map_enter(C0,V,M,C):- catch(inv_map(C0,V,M,C),too_deep(Why),(dmsg(Why),dtrace(inv_map(C0,V,M,C)))).

inv_map(Var,V,M,T) :- stack_depth(X), X> 400, throw(too_deep(inv_map(Var,V,M,T))).
inv_map(Var,V,M,T) :- stack_check(500), var(Var),dmsg(var_inv_map(Var,V,M,T)),!,Var==T.
inv_map('$VAR'(I),V,_,X) :- !,
   arg(I,V,X).
inv_map(A=B,V,M,T) :- !,
   drop_eq(A,B,V,M,T).
inv_map(X^P0,V,M,P) :- !,
   inv_map(P0,V,M,P1),
   exquant(X,V,M,P1,P).
inv_map(A,_,_,A) :- atomic(A), !.
inv_map(T,V,M,R) :-
   functor(T,F,K),
   functor(R,F,K),
   inv_map_list(K,T,V,M,R).

inv_map_list(0,_,_,_,_) :- !.
inv_map_list(K0,T,V,M,R) :-
   arg(K0,T,A),
   arg(K0,R,B),
   inv_map(A,V,M,B),
   K is K0-1,
   inv_map_list(K,T,V,M,R).

drop_eq('$VAR'(I),'$VAR'(J),V,M,true) :- !,
 ( I=\=J, !,
      irev(I,J,K,L), 
      arg(K,M,L),
      arg(K,V,X),
      arg(L,V,X);
   true).
drop_eq('$VAR'(I),T,V,M,true) :- !,
   arg(I,V,T),
   arg(I,M,0).
drop_eq(T,'$VAR'(I),V,M,true) :- !,
   arg(I,V,T),
   arg(I,M,0).
drop_eq(X,Y,_,_,X=Y).

exquant('$VAR'(I),V,M,P0,P) :-
   arg(I,M,U),
 ( var(U), !,
      arg(I,V,X),
       P=(X^P0);
   P=P0).

irev(I,J,I,J) :- I>J, !.
irev(I,J,J,I).
