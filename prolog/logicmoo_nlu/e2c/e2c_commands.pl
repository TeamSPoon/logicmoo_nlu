% =================================================================
% %%%%%%%%%%%%%%%%%%%%%%% DISPLAY %%%%%%%%%%%%%%%%%%%%%%%
% =================================================================
print_reply_colored(Reply):- notrace(((functor_result_color(Reply,Color), !, print_reply(Color, Reply)))).

functor_result_color(T,yellow):-var(T),!.
functor_result_color(error,red).
functor_result_color(failed,red).
functor_result_color(success,green).
functor_result_color(failed,red).
functor_result_color(_:T,Color):- !, functor_result_color(T,Color).
functor_result_color(T:-_,Color):- !, functor_result_color(T,Color).
functor_result_color(T,Color):- \+ structureless(T),functor(T,F,_),!,functor_result_color(F,Color).
functor_result_color(_,cyan).


call_print_reply(LF,Goal):- 
 catch(
  ((Goal,(e2c_clausify_and_reply(LF,R)->Reply=success(R);Reply=almost_lf(LF)))
  ->  print_reply_colored(  Reply )
   ;  print_reply_colored(  failed(Goal))),
   E, print_reply_colored(  E)).

print_reply(Other) :- quietly((portray_vars:pretty_numbervars(Other, O), parser_chat80:print_tree(O))),!.

print_reply(C,O):- notrace(((is_list(C)->CC=C;CC=[fg(C)]),ansi_format(CC,'~@',[print_reply(O)]))),!.

% =================================================================
% %%%%%%%%%%%%%%%%%%%%%%% IRC-REPLY %%%%%%%%%%%%%%%%%%%%%%%
% =================================================================


irc_cmd:irc_invoke_e2c(Channel,Agent,_Say,Args):- 
 irc_process(Channel,Agent,   
   e2c(Args)).

irc_cmd:irc_invoke_nlp(Channel,Agent,_Say,Args):- 
 irc_process(Channel,Agent,irc_e2c(Args)).

irc_e2c(Args):- e2c(Args, Out),print_reply(Out).



% =================================================================
% %%%%%%%%%%%%%%%%%%%%%%% GLEAN CMDS %%%%%%%%%%%%%%%%%%%%%%%
% =================================================================

% scan_is_dcg(M,F,A):- baseKB:mpred_props(M,F,A,prologDcg). 
scan_is_dcg(M,F,A):- current_predicate(M:F/A),A>=2,functor(H,F,A),
  predicate_property(M:H,number_of_clauses(_)),
  \+ predicate_property(M:H,imported_from(_)),
  \+ \+ (clause(M:H,B),is_dcg_clause(M,H,B)).

%is_dcg_clause(M,H,B):- H=..[F|Args],sub_term(Sub,B),\+ structureless(Sub), Sub=..[_|Args],!.
is_dcg_clause(M,_,B):- sub_term(Sub,B), \+ structureless(Sub),Sub\=[_|_],functor(Sub,F,A),A>=2,baseKB:mpred_props(M,F,A,prologDcg).

make_dcg_test_stub(_,_,A):- A < 3.
make_dcg_test_stub(M,F,_):- current_predicate(M:F/1),!. % no place for it
make_dcg_test_stub(_,F,_):- current_predicate(F/1),!. % still no place for it?
make_dcg_test_stub(M,F,A):-
   functor(PrologHead,F,A),
   PrologHead =.. [F|PrologHeadArgs],
   append(_,[Out,W,E],PrologHeadArgs),   
   TextHead =.. [F,S],
   (Assert = ( M:TextHead:- (make, to_wordlist_atoms(S,W),call_print_reply(Out,M:PrologHead),!,E=[]))),
   M:assert_if_new(Assert).


:- M = parser_e2c, forall(scan_is_dcg(M,F,A), decl_is_dcg(M,F,A)).
:- M = parser_e2c, forall(baseKB:mpred_props(M,F,A,prologDcg),must_or_rtrace(make_dcg_test_stub(M,F,A))).
