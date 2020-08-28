% ===================================================================
% File 'parser_lexical.pl'
% Purpose: English to KIF conversions from SWI-Prolog
% This implementation is incomplete
% Maintainer: Douglas Miles
% Contact: $Author: dmiles $@users.sourceforge.net ;
% Version: 'parser_ProNTo.pl' 1.0.0
% Revision:  $Revision: 1.666 $
% Revised At:   $Date: 2002/06/06 15:43:15 $
% ===================================================================

:-module(parser_lexical, [ ]).

% ?- use_module(library(logicmoo_nlu/parser_lexical)).

:- use_module(library(make)), use_module(library(check)), redefine_system_predicate(check:list_undefined/1).
:- abolish(check:list_undefined/1).
:- assert(check:list_undefined(_)).

:- use_module(library(pfc_lib)).
:- use_module(nl_pipeline).


:- '$set_source_module'(baseKB).
:- module(baseKB).
:- use_module(library(pfc)).

:- share_mp(common_logic_kb_hooks:cyckb_t/1).
:- share_mp(common_logic_kb_hooks:cyckb_t/2).
:- share_mp(common_logic_kb_hooks:cyckb_t/3).
:- share_mp(common_logic_kb_hooks:cyckb_t/4).
:- share_mp(common_logic_kb_hooks:cyckb_t/5).
:- share_mp(common_logic_kb_hooks:cyckb_t/6).
:- share_mp(common_logic_kb_hooks:cyckb_t/7).
:- forall(between(1, 8, N), share_mp(common_logic_kb_hooks:cyckb_t/N)).

:- kb_global(baseKB:nlfw/4).
%:- share_mp(nlf:f/4).

connect_preds(HF, BF):-
 forall(between(1, 13, N),
 ( length(ARGS, N),
   H=..[HF|ARGS],
   B=..[BF|ARGS],
   asserta_new(H:- B))).

:- connect_preds(cyckb_t, cyckb_h).
:- connect_preds(cyckb_h, ac).

:- use_module(parser_lexical_gen).
:- use_module(library(http/http_client)).
%:- use_module(library(http/http_open)).
:- use_module(library(http/json_convert)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json)).

call_corenlp(English):- make, call_corenlp(English, _Options).

call_corenlp(English, Options):-
  call_corenlp(English, Options, OutF),!,
  maplist(print_reply_colored, OutF).

call_corenlp(English, OptionsIn, OutS):-
  % DefaultOpts = [tokenize, ssplit, pos, lemma, ner, coref, dcoref, depparse,  mwt, natlog ,relation, openie ],
  DefaultOpts = [ quote, tokenize, ssplit, pos, lemma, depparse, natlog, coref, dcoref,  ner, relation, udfeats ],
  % kbp,  % sentiment,
  ignore('.\nSome quick brown foxes jumped over the lazy dog after we sang a song. X is Y .  Pee implies Queue.'=English),
  ignore(OptionsIn=DefaultOpts), % depparse, lemma
  atomic_list_concat(['\n.\n',English,"\n.\n"], PostData),
  (OptionsIn==[]->Options=DefaultOpts;Options=OptionsIn),
  atomic_list_concat(Options, ',', OptionsStr),
  format(atom(For), '{"annotators":"~w", "outputFormat":"json"}', [OptionsStr]),
  % http_open([host(localhost), port(3090), post([PostData]), path(''), search([properties=For])], In, []),
  uri_encoded(query_value, For, Encoded), atom_concat('http://logicmoo.org:3090/?properties=', Encoded, URL),
  http_post(URL, [PostData], json(Reply), []),
  %maplist(print_reply_colored,Reply), print_reply_colored("==============================================================="),
  % maplist(wdmsg, Reply),
  must_or_rtrace(parse_reply([reply], Reply, Out)),
  flatten([Out], OutF),
  sort(OutF, OutR),
  reverse(OutR, OutS),
  !.

parse_reply(Ctx, List, Out):- is_list(List),!, maplist(parse_reply(Ctx),List, Out).
parse_reply(Ctx, InnerCtx=json(List), Out):- !,  parse_reply([InnerCtx|Ctx], List, Out).
parse_reply(Ctx, List, Out):- 
   sub_term(Sub, List), nonvar(Sub), 
   parse_reply_replace(Ctx, Sub, NewSub),
   % ignore((NewSub=='$',wdmsg(parse_reply_replace(_Ctx, Sub, NewSub)))),
   nonvar(NewSub), Sub\==NewSub,
   subst(List, Sub, NewSub, NewList), 
   List\==NewList, !, 
   parse_reply(Ctx, NewList, Out).
%parse_reply(Ctx, [], Ctx=[]):- !.
%parse_reply([reply], List, Out):- flatten([List], Out),!.
%parse_reply(Ctx, List, Ctx=j(Out)):- flatten([List], Out),!.
parse_reply(_Ctx, List, Out):- flatten([List], Out),!.

label_tokens(_Index, TokensLabeled, TokensLabeled):-!.
label_tokens(Index, json(Tokens), TokensLabeled):- !, label_tokens(Index, Tokens, TokensLabeled), !.
label_tokens(Index, Tokens, TokensLabeled):- append_term(Tokens, Index, TokensLabeled), !.

 
parse_reply_replace(_Ctx, Sub, Replace):- is_list(Sub), 
  subtract_eq(Sub, ['$'], Replace),
  Replace\==Sub.

parse_reply_replace(_Ctx, sentence(N,[tok(1,'.','.',".",[])],[]), '$'):- number(N).
parse_reply_replace(_Ctx, openie=W, W):-!, nonvar(W).
parse_reply_replace(_Ctx, sentences=W, W):-!, nonvar(W).
parse_reply_replace(_Ctx, corefs=W, W):- !,nonvar(W).
parse_reply_replace(_Ctx, Number=[Coref|More], [Coref|More]):- atom_number(Number,_), compound(Coref),functor(Coref,coref,_).
%parse_reply_replace(_Ctx, _=[Coref|More], [Coref|More]):- compound(Coref),functor(Coref,coref,_).

parse_reply_replace(_Ctx, Remove=Rest, '$'):- nonvar(Rest),
  member(Remove, [
   basicDependencies,
   enhancedDependencies,                                      
   enhancedPlusPlusDependencies,
   entitymentions,
   headIndex,
   position,
   parse, 
   characterOffsetBegin, characterOffsetEnd, before, after]).
parse_reply_replace(_Ctx, isRepresentativeMention=TF, TF).
parse_reply_replace(_Ctx, Sub, '$'):- ground(Sub), 
  member(Sub, [entitymentions=[], speaker='PER0', openie=[], ner='O']).

parse_reply_replace(_Ctx, Sub, Replace):- 
 members([index=Index, originalText=String, word=String, 
    lemma=Root, pos=Pos], Sub, Attributes), !,
 cvt_to_real_string(String,AString),
 Replace = tok(Index, Pos, Root, AString, Attributes).

parse_reply_replace(_Ctx, Sub, Replace):- 
  members([index=SentID, tokens=Tokens], Sub, Attributes), !,
  maplist(label_tokens(SentID), Tokens, TokensLabeled),
  parse_reply([sentence(SentID)],Attributes,NewAttributes),
  flatten(NewAttributes,NewAttributesF),
  Replace = sentence(SentID, TokensLabeled, NewAttributesF).

parse_reply_replace(_Ctx, Sub, Replace):- 
  members([relationSpan=[R1,R2],relation=Relation,subjectSpan=[S1,S2],subject=S,objectSpan=[O1,O2],object=O], Sub, Attributes), !,
  Replace = sro([rel(Relation,R1,R2),subj(S,S1,S2),obj(O,O1,O2)|Attributes]).

parse_reply_replace(_Ctx, Sub, Replace):- 
  members([relationSpan=RelationSpan,relation=Relation], Sub, Attributes), !,
  Replace = relation(RelationSpan,Relation,Attributes).

parse_reply_replace(_Ctx, Sub, Replace):- 
 members([id=Index, text=Text, type=Type, startIndex=SI, endIndex=EI, % headIndex=HI,
    sentNum=SentID, number=SINGULAR, gender=NEUTRAL, animacy=INANIMATE, isRepresentativeMention=TF], Sub, Attributes), !,
 into_text100_atoms(Text,Words),maplist(cvt_to_real_string,Words,WordStrings),
 SentIDMinus1 is SentID-1,
 SIm1 is SI-0,
 EIm1 is EI-1,
 Replace =  
  coref(SentIDMinus1, seg(SIm1-EIm1), '#'(Index), WordStrings,
    % headIndex(HI),   
    Type, SINGULAR, NEUTRAL, INANIMATE,[em=TF|Attributes]).
                                                                                
parse_reply_replace(_Ctx, sentence(_,TokList,_), '$'):- ground(TokList),  
   member(tok(_, 'SYM', '--------', _, _),TokList), !.

parse_reply_replace(_Ctx, json(Replace), Replace):- nonvar(Replace),!.
 
into_text100_atoms(Text,Words):- into_text80_atoms(Text,Words).

members([], List, List):-!.
members(EList, json(List), ListO):- !, members(EList, List, ListO).
members([E|EList], List, ListO):- select(E, List, ListM), !, members(EList, ListM, ListO).

sexpr_to_lexpr(SExpr, LExpr):-
  atomic_list_concat(S, '(. .)', SExpr), atomic_list_concat(S, '(. ".")', LSExpr), lisp_read(LSExpr, LExpr).

sentence_reply(Number, Toks, SExpr, In, Mid):- atomic(SExpr), sexpr_to_lexpr(SExpr, LExpr), !,
   sentence_reply(Number, Toks, LExpr, In, Mid).
sentence_reply(Number, Toks, SExpr, In, Out):- append(In, [sentence(Number)=Toks, SExpr], Out), !.
/*
sentence_reply(Number, Toks, SExpr, In, In):-
  print_reply_colored(Number=SExpr),
  print_reply_colored(Number=Toks), !.
*/


common_logic_kb_hooks:cyckb_t(A, B, C):- cyckb_p2(A, [B, C]).
common_logic_kb_hooks:cyckb_t(A, B, C, D):- cyckb_p2(A, [B, C, D]).
common_logic_kb_hooks:cyckb_t(A, B, C, D, E):- cyckb_p2(A, [B, C, D, E]).
common_logic_kb_hooks:cyckb_t(A, B, C, D, E, F):- cyckb_p2(A, [B, C, D, E, F]).

cyckb_p2(A, BC):- \+ is_list(BC), !, between(2, 10, N), length(BC, N), cyckb_p2(A, BC).
cyckb_p2(A, [B, C|D]):- atom(C), downcase_atom(C, C), cvt_to_real_string(C, S), cyckb_p3(A, B, [S|D]).
cyckb_p2(A, [B, B1, C|D]):- atom(C), downcase_atom(C, C), cvt_to_real_string(C, S), cyckb_p3(A, B, [B1, S|D]).
cyckb_p2(A, [B, C|D]):- string(C), into_text100_atoms(C, O), O\=[_], maplist(cvt_to_real_string, O, S), ST=..[s|S], cyckb_p3(A, B, [ST|D]).
cyckb_p2(A, [B, B1, C|D]):- string(C), into_text100_atoms(C, O), O\=[_], maplist(cvt_to_real_string, O, S), ST=..[s|S], cyckb_p3(A, B, [B1, ST|D]).
%cyckb_p2(A, [B, C|D]):- \+ ((arg(_, v(B, C), X), compound(X))), between(2, 10, N), functor(S, s, N), arg(_, cyckb_h(B, C), S), cyckb_p3(A, B, [C|D]).
%cyckb_p2(A, [B, C|D]):- cyckb_p3(A, B, [C|D]).

cyckb_p3(A, B, [H|T]):- apply(cyckb_h(A, B), [H|T]).

is_synset_id(X):- integer(X), X > 100001739.

synset_to_w(X, W1, SK):- wnframes:s(X, W1, SK, _, _, _)*->true;wnframes:sk(X, W1, SK).
synset_to_w(X, W1, SK):- wnframes:sk(X, W1, SK).

synset_to_words(X, W1, Name):-
   findall(SK, wnframes:s(X, W1, SK, _, _, _), List),
   must_or_rtrace(predsort(longer_names, List, _Set)),
   must(synset_to_w(X, W1, SK)),
   must(wnframes:g(X, G)),
   concat_missing(SK, [X, G|List], Name), !.

longer_names(R, C2, C1):- atom_length(C1, L1), atom_length(C2, L2), compare(R, L1, L2), R \== (=), !.
longer_names(R, C2, C1):- compare(R, C1, C2).

concat_missing(Named, [Name|More], Out):- atom_contains(Named, Name)
 -> concat_missing(Named, More, Out)
 ;(atomic_list_concat([Named, '-', Name], M), concat_missing(M, More, Out)).
concat_missing(Named, [], Out):- Named=Out.

%synset_to_words(X, S, Set):- findall(SK, ((nonvar(S)->true;member(S, [5, 4, 3, 2, 1])), wnframes:sk(X, S, SK)), List), list_to_set(List, Set), Set\==[], !.

english_some(X, Words):- is_synset_id(X), synset_to_words(X, _, Words), !.
english_some(X, Y):- \+ compound(X), !, Y=X.
english_some([fr, X1, M, X2|More], Y):- is_synset_id(X1), synset_to_words(X1, X2, SK), !, english_some([vnframe, M, SK|More], Y).
english_some([X1, X2|More], Y):- integer(X2), is_synset_id(X1), synset_to_words(X1, X2, SK), !, english_some([SK|More], Y).
english_some(H-T, HH-TT):- !, english_some(H, HH), =(T, TT).
english_some([H|T], [HH|TT]):- !, english_some(H, HH), english_some(T, TT).
english_some(X, Y):-
  compound_name_arguments(X, F, Args), F \== sk,
  english_some([F|Args], [_|ArgsO]), !,
  compound_name_arguments(Y, F, ArgsO).
english_some(X, X):- !.

lex_frivilous(senseExamples).
lex_frivilous(senseComments).
lex_frivilous(senseDefinition).
lex_frivilous(X):- lex_frivilous_maybe(X).

lex_frivilous_maybe(posForms).
lex_frivilous_maybe(posBaseForms).
lex_frivilous_maybe(subcatFrame).
lex_frivilous_maybe(s).
lex_frivilous_maybe(g).

lex_frivilous_col(xtLexicalWord).
lex_frivilous_col(xtEnglishWord).
lex_frivilous_col(tIndividual).

:- add_e2c("a red cat fastly jumped onto the table which is in the kitchen of the house").
:- add_e2c("After Slitscan, Laney heard about another job from Rydell, the night security man at the Chateau.").
:- add_e2c("Rydell was a big quiet Tennessean with a sad shy grin, cheap sunglasses, and a walkie-talkie screwed permanently into one ear.").
:- add_e2c("Concrete beams overhead had been hand-painted to vaguely resemble blond oak.").
:- add_e2c("The chairs, like the rest of the furniture in the Chateau s lobby, were oversized to the extent that whoever sat in them seemed built to a smaller scale.").
:- add_e2c("Rydell used his straw to stir the foam and ice remaining at the bottom of his tall plastic cup, as though he were hoping to find a secret prize.").
:- add_e2c("A little tribute to Gibson", noun_phrase).
:- add_e2c('"You look like the cat that swallowed the canary, " he said, giving her a puzzled look.', [quotes]).
:- add_e2c("The monkey heard about the very next ship which is yellow and green.").

%lex_mws(genTemplateConstrained).
%lex_mws(genTemplate).
lex_mws(headMedialString).
lex_mws(compoundString).

lex_mws(prepCollocation).
lex_mws(abbreviationForMultiWordString).
lex_mws(multiWordStringDenotesArgInReln).
lex_mws(compoundSemTrans).
lex_mws(multiWordSemTrans).
lex_mws(multiWordString).
lex_mws(mws).

%is_word(W):- atom(W), guess_arg_type(X, W), !, X==text(a).
%is_atom_word(W):- atom(W), guess_arg_type(X, W), !, X==text(a).

not_contains_overlap(A, W):- \+ contains_overlap(A, W).

contains_overlap(_Atoms, Was):- \+ (select(txt(_O1), Was, Was1), member(txt(_O2), Was1)), !.

contains_overlap(A, Was):- atomic(A), !, member(txt(A), Was), !.
contains_overlap(A;B, Was):- !, contains_overlap(A, Was);contains_overlap(B, Was).
contains_overlap(E, Was):- is_list(E), !, contains_overlap_list(E, Was), !.

contains_overlap(X, Was):- compound(X), arg(_, X, E), is_list(E), !, contains_overlap_list(E, Was), !.
contains_overlap(X, Was):- compound(X), atoms_of(X, E), contains_overlap(E, Was), !.

contains_overlap_list([], _).
contains_overlap_list([A|B], Was):- !, append(_Left, [txt(A)|Right], Was), contains_overlap_list(B, Right), !.

contains_overlap_list(Atoms, Was):- is_list(Atoms), !,
  list_to_set(Atoms, Atoms1),
  select(A1, Atoms1, Atoms2),
  member(A2, Atoms2),
  binds_with(A1, O1),
  binds_with(A2, O2),
  member(Find1, [txt(O1)]), member(Find2, [txt(O2)]),
  select(Find1, Was, Was1), member(Find2, Was1),
  nop(wdmsg(contains_overlap( A1+O1, A2+O2))), !.

to_atom_or_string(A, W):-  nonvar(W), !, to_atom_word(A, O), !, O==W.

to_atom_word(A, W):- nonvar(W), !, to_atom_word(A, O), !, O==W.
to_atom_word(A, W):- to_case_break_atoms(A, O), !, (O=[W]->true;(O=['"', W, '"']->true;O=[x, DC, 'The', 'Word'], downcase_atom(DC, W))).

filter_mmw(X, O):- A=val([]), filter_mmw(A, X, X), !, arg(1, A, O).

filter_mmw(_, _Was, X):- X == [], !.
filter_mmw(O, _Was, X):- var(X), !, append_o(var(X), O).
filter_mmw(O, Was, [H|T]):-!, filter_mmw(O, Was, H), filter_mmw(O, Was, T).
%filter_mmw(_, _Was, level(Kind, 1, _, _, _)):- !.
filter_mmw(O, Was, X):- select(X, Was, WasNt), !, filter_mmw(O, WasNt, X).
filter_mmw(O, Was, level(_, 0, _, X, _)):- !, filter_mmw(O, Was, X).
filter_mmw(_, Was, X):- compound(X), functor(X, flexicon, A), arg(A, X, E), not_contains_overlap(E, Was), !.
filter_mmw(_, Was, X):- compound(X), functor(X, MW, _), lex_mws(MW), not_contains_overlap(X, Was), !.
filter_mmw(_, _Was, X):- compound(X), functor(X, MW, _), lex_frivilous(MW), !.
filter_mmw(_, _Was, isa(_, MW)):- lex_frivilous_col(MW), !.
filter_mmw(O, _Was, X):- append_o(X, O).

append_o(X, O):- O=val([]), !, nb_setarg(1, O, [X]).
append_o(X, val(List)):- o_put(X, List).
o_put(F, List):- memberchk(F, List), !.
o_put(F, List):- List=[_|T], (T==[] -> nb_setarg(2, List, [F]) ; o_put(F, T)).

lex_print(X):- X == [], !, wdmsg(X), !.
lex_print(X):- is_list(X), !, maplist(lex_print0, X).
lex_print(X):- lex_print0(X), !.
lex_print0(level(_, 0, _, X, _)):- !, lex_print0(  X).
%lex_print0(level(_, 1, _, _, _)):- !.
lex_print0(isa(_, MW)):- lex_frivilous_col(MW), !.
%lex_print0(X):- english_some(X, Y), wdmsg(Y), !.
lex_print0(X):- english_some(X, Y), print_reply_colored(Y).

%cvt_to_qa_string(A, M):- atomic_list_concat(['"', A, '"'], M).
cvt_to_qa_string(A, M):- cvt_to_real_string(A, M).
cvt_to_atom(A, M):- atomic_list_concat([A], M).

cvt_to_real_string(NBA, M):- compound(NBA), NBA = nb(A), assertion(number(A)), !, cvt_to_real_string(A, M).
cvt_to_real_string(A, M):- atom_string(A, M).

% correct_dos(Todo, TodoS):- flatten([Todo], TodoF), (Todo\==TodoF -> my_l2s(TodoF, TodoS); TodoS=Todo), !.
correct_dos(Todo, TodoS):- flatten([Todo], TodoF), my_l2s(TodoF, TodoS), !.

add_do_more(More, Todo, NewDone, NewTodo):-
 flatten([More], MoreS),
 add_todo_list(MoreS, Todo, NewDone, NewTodo), !.

add_todo_list([], Todo, _Done, Todo):-!.
add_todo_list([M|MoreS], Todo, Done, NewTodo):- member_eq0(M, Done), !, add_todo_list(MoreS, Todo, Done, NewTodo).
add_todo_list([M|MoreS], Todo, Done, NewTodo):- add_if_new(Todo, [M], TodoM), !,
 add_todo_list(MoreS, TodoM, Done, NewTodo).

first_clause_only(Head):- Found=fnd(0), nth_clause(Head, Nth, Cl), Found==fnd(0),
   Nth\==1, clause(Head, Body, Cl), call(Body), nb_setarg(1, Found, Nth).


text_to_cycword(String, P, C, How):- !, first_clause_only(text_to_cycword(String, P, C, How)).
text_to_cycword(String, P, C, How):- \+ string(String), cvt_to_real_string(String, RealString), !, text_to_cycword(RealString, P, C, How).
text_to_cycword(String, P, C, cyckb_h(P, C, String)):- base_to_cycword(String, P, C).
text_to_cycword(String, P, C, How):- string_lower(String, DCString), DCString\==String, !, text_to_cycword(DCString, P, C, How).
text_to_cycword(String, Pos, C, (to_base_form(String, Pos, BaseWord), cyckb_h(Pred, C, BaseWord))):- fail,
  to_base_form(String, Pos, BaseWord), BaseWord\==String,
  base_to_cycword(BaseWord, Pred, C).

text_to_cycword(String, Pos, C, cyckb_h(Pred, C, BaseWord)):-
  to_base_form(String, Pos, BaseWord), BaseWord\==String,
  base_to_cycword(BaseWord, Pred, C).

to_base_form(String, Used, BaseWord):- \+ atom(String), string_to_atom(String, Atom), !, to_base_form(Atom, Used, BaseWord).
to_base_form(String, Used, BaseWord):- fail, call_lex_arg_type(text(a), text(base), String, BaseWord, Used).
to_base_form(String, 'xtAgentitiveNoun', BaseWord):- morph_stem(String, BaseWord, 'er').
to_base_form(String, 'xtAdverb', BaseWord):- morph_stem(String, BaseWord, 'ly').
to_base_form(String, 'xtUn', BaseWord):- morph_stem(String, 'un', BaseWord).

morph_stem(String, Base, Suffix):- atom_concat(Base, Suffix, String).
morph_stem(String, Base, Suffix):- morph_atoms(String, [[Base, -Suffix]]).

base_to_cycword(String, Pos, C):- ac(partOfSpeech, C, Pos, String).
base_to_cycword(String, P, C):-
  nonvar(String), cvt_to_real_string(String, QAString), cyckb_h(P, C, QAString),
  ok_speech_part_pred(P).

%morph_atoms(causer, [[W, -er]]). W = cause

string_to_info(String, P):- fail,
 catch(downcase_atom(String, Atom), _, fail),
 atom_length(Atom, Len), Len > 1,
 term_to_info(Atom, P). % , functor(P, F, _), guess_pred_pos(P, String, Pos).

% string_to_pos(String, Pos):- atom_ string(Atom, String), term_to_info(Atom, P), guess_pred_pos(P, String, Pos).

guess_pred_pos(P, _String, Pos):- arg(_, P, Pos), nonvar(Pos), member(Pos, [n, a, s, v, a, j, r, jj, adv, adj, nn, pp, prep]), !.
guess_pred_pos(P, String, Pos):- arg(_, P, Pos), nonvar(Pos), Pos \== String, !.
%guess_pred_pos(P, _, Pos):- functor(P, Pos, _).

ok_speech_part_pred(P):-
 P\==firstNameInitial, P\==middleNameInitial,
 (
 cyckb_h(isa, P, rtSpeechPartPredicate); \+ cyckb_h(isa, P, _)), !.

subtype_index(_, +(_), _, _Value, _CArg, _PreCall, _PostCall):- !, fail.
subtype_index(_, W, W, Value, CArg, PreCall, PostCall):- PreCall = (CArg = Value), PostCall = true.
subtype_index(_, W, W- _Pos, Value, CArg, PreCall, PostCall):- PreCall = (CArg = (Value-_)), PostCall = (true;true).
subtype_index(_, text(a), text(str), Value, CArg, PreCall, PostCall):-  PreCall = cvt_to_real_string(Value, CArg), PostCall = true.
%subtype_index(_, text(a), text(base), Value, CArg, PreCall, PostCall):- PreCall = (CArg = Value), PostCall = true.
                                               
%subtype_index(_, W, any(W), Value, CArg, PreCall, PostCall):- !, PreCall = freeze(CArg, sub_var(Value, CArg)), PostCall = true.
subtype_index(_, W, any(W), Value, CArg, PreCall, PostCall):-  PreCall = true, PostCall = sub_var(Value, CArg).
subtype_index(_, W, seq(W), Value, CArg, PreCall, PostCall):- /*atom(W), */ PreCall = (CArg = [_|_]), PostCall = sub_var(Value, CArg).
subtype_index(_, W, listof(W), Value, CArg, PreCall, PostCall):- PreCall = (CArg = [_|_]), PostCall = member(Value, CArg).

doable_type(_, DoType, Type):- nonvar(DoType),
  % DoType\==text(str),
  DoType\==data, DoType=Type, !.

matcher_to_data_args( Matcher1, Data, P):-
  matcher_to_data_args(setarg, Matcher1, Data, 1, P, P), !.

matcher_to_data_args(SetArg, Matcher1, Data, N, C, P):-
  % functor(C, F, A), functor(P, F, A),
  ignore((arg(N, C, Match),
  copy_term(Matcher1+Data+Match, Matcher1C+DataC+MatchC),
  ignore((once(call(Matcher1C, MatchC)), (DataC==unk -> true ; call(SetArg, N, P, DataC)))),
  N2 is N+1,
  matcher_to_data_args(SetArg, Matcher1, Data, N2, C, P))).

% matcher_to_data_args(_Matcher1, _Data, _N, _C, _P):-!.

copy_value_args(P, C):- functor(P, F, A), functor(C, F, A), P=..[_|PList], C=..[_|CList], maplist(copy_value_arg, PList, CList).
copy_value_arg(P, C):- ignore((compound(P), P = +(C))).


is_atom_word(W):- atom(W), guess_arg_type(X, W), !, X==text(a).
get_vv(X, Arg):- compound(Arg), Arg = +(X).


get_test_verbs(V):- wnframes:s(_, _, V, v, _, _).
baseKB:sanity_test:- forall(get_test_verbs(V), lex_info(V)).

:- export(lex_winfo/1).
lex_winfo(Value):- lex_tinfo(text(a), Value).

:- export(lex_tinfo/2).
lex_tinfo(Type, Value):-
 findall(Datum, get_info_about_type(_All, 0, Type, Value, Datum), DatumL),
   correct_dos(DatumL, DatumF),
   maplist(wdmsg, DatumF), !.



call_lex_arg_type(TypeIn, TypeOut, Value, Result, C):-
  find_lex_arg_type( _, _, M, P),
  arg(I, P, TypeIn), arg(O, P, TypeOut),
  I \== O, copy_value_args(P, C),
  arg(I, C, Value), arg(O, C, Result),
  call(M:C).

%converts_arg_type(system, =(X, X)).
converts_arg_type(system, atom_string(text(a), text(s))).
converts_arg_type(system, atom_string(text(base), text(s))).
converts_arg_type(system, atom_string(text(base), text(a))).

call_converter(TypeIn, TypeOut, Value, Result):-
  converts_arg_type(M, P),
  arg(I, P, TypeIn), arg(O, P, TypeOut),
  I \== O, copy_value_args(P, C),
  arg(I, C, Value), arg(O, C, Result),
  call(M:C).

find_lex_arg_type(Kind, Level, M, P):- lex_arg_type(Kind, Level, M, P), current_predicate(_, M:P).

get_info_about_type(Kind, Level, Type, Value, MoreF):-
  get_info_about_type0(Kind, Level, Type, Value, MoreF)
   *-> true
   ; get_info_about_type0(Kind, f(Level), Type, Value, MoreF).

get_info_about_type0(Kind, Level, Type, Value, MoreF):-
  (number(Level)-> Level2 is Level+1; Level2 = 1),
  find_lex_arg_type(Kind, Level, M, P),
  arg(N, P, Matcher),
  nonvar(Matcher),
  subtype_index(Level, Type, Matcher, Value, CArg, PreCall, PostCall),
  functor(P, F, A),
  functor(C, F, A),
  % \+ ((arg(N, P, PArg), PArg=text(base), arg(_, P, text(a)), \+ arg(_, P, pos))),
  copy_value_args(P, C),
  arg(N, C, CArg),
  call(PreCall),
   ignore(( (Level\==0, Level\==1 % ; PArg==text(base)
   ) , wdmsg(( P:Level -> (C, PostCall))))),
   matcher_to_data_args(=(Matcher), data, P),
  % wdmsg(M:get_info_about_type(Kind, Level, Type, Value, P->C, PostCall)),
  once((findall([level(Kind, Level, Type, C, Value)|Extra], ((call(M:C)), call(PostCall),
                         P=..[_|PRest], C=..[_|CRest],
                         make_new_todos(Kind, Type, Level2, CRest, PRest, [], Extra)), More1),
  flatten(More1, MoreF))).


make_new_todos(_Kind, _Was, _Level, [], [], InOut, InOut):- !.
make_new_todos(Kind, Was, Level, [C|CRest], [P|PRest], In, Out):-
 (var(C);var(P);
  C==[];
  (P = +(_));
  P==data;
  (P==text(base), Kind==syn);
  P == pos;
  (Was==P);
  (Was\==text(a), P==text(a));
  (P==text(str));
  (number(Level), Level>2);
  (Was==text(base), P==text(base))), !,
 make_new_todos(Kind, Was, Level, CRest, PRest, In, Out).


:- forall((clause(ac(_, xBadTheWord, _, _, TakingABath), true, R);clause(ac(_, xBadTheWord, _, _, _, TakingABath), true, R)),
  ignore((member(X, [actTakingABath, tGroupedSpa, tObjectHotTub]), sub_var(X, TakingABath),
   erase(R)))).


make_new_todos(Kind, Was, Level, [C|CRest], [P|PRest], In, Out):-
  (Was==text(a), P==text(base)),
  %Level0 is Level -1, !,
  make_new_todos(Kind, accept, Level, [C|CRest], [P|PRest], In, Out).

make_new_todos(Kind, Was, Level, [C|CRest], [P|PRest], In, Out):-
  fail,
  (Was==text(a), P==text(a)),
  Level0 is Level -1, !,
  make_new_todos(Kind, accept, Level0, [C|CRest], [P|PRest], In, Out).

make_new_todos(Kind, Was, Level, [C|CRest], [P|PRest], In, Out):-
 (P == pos),
 make_new_todos(Kind, Was, Level, CRest, PRest, In, Mid),
% wdmsg(data(Level, P, C)),
 add_if_new(Mid, data(Level, P, C), Out), !.

make_new_todos(Kind, Was, Level, [C|CRest], [P|PRest], In, Out):-
 make_new_todos(Kind, Was, Level, CRest, PRest, In, Mid),
 % wdmsg(adding_todo(Level, P, C)),
 add_if_new(Mid, todo(Level, P, C), Out), !.


add_if_new(Done, Doing, NewDone):-
  member_eq0(Doing, Done)
   -> NewDone = Done
   ; append(Done, [Doing], NewDone).

:- export(lexfw_info/1).
lexfw_info(String):-
 lexfw_info(_AllKind, String, Datum),
 lex_print(Datum).

:- kb_global(do_e2c_fwd/1).
:- kb_global(nl_pass1/1).
:- export(lexfw_info/3).
lexfw_info(_Kind, String, Out):-
 %mpred_retract(nl_pass1),
 forall(do_e2c_fwd(Was, _), mpred_retract(do_e2c_fwd(Was, _))),
 % forall(nlfw(M, N, Data, Ace), mpred_remove(nlfw(M, N, Data, Ace))),
 gensym(lexfw_info_, ID),
 into_text100_atoms(String, Words), % maplist(into_dm, Words, Todo),
 into_acetext(Words, Ace), cvt_to_real_string(Ace, SAce),
 ain(do_e2c_fwd(SAce, ID)), !,
 ain(nl_pass1),
 show_ace_id(ID),
 Out = [], !.

show_ace_id(ID):- forall((nlfw(N, M, Gaf, ID), \+ functor(Gaf, xclude, _)), wdmsg(nlfw(N, M, Gaf, ID))).

text_into_wall(String, ID, Ace, WalledWords, 0, N):-
 into_text100_atoms(String, Words),
 ignore(gensym(ace_, ID)),
 into_acetext(Words, AceA), cvt_to_real_string(AceA, Ace),
 maplist(cvt_to_real_string, Words, SWords),
 Left = ['L-WALL'|SWords],
 append(Left, ['R-WALL'], WalledWords), !,
 length(Left, N).

% :- prolog_load_context(source, File), format("~N~n?- ~q.~n", [(mpred_trace_exec, rtrace(mpred_remove_file_support(File)))]).
% :- break.


maybe_text(W, W):- atom_contains(W, '-WALL'), !.
maybe_text(W, txt(S)):- cvt_to_real_string(W, S).

% ((nl_pass1, nlfw(M, N, text80(WalledWords), Ace)/buffer_words(M, Ace, )


append_segment(N, M, Len, StringW, Ace):-
 segment(N, M, Len, StringW, Ace).

notInheritPos(xtSententialConstituent).
notInheritPos(xtWHAdverb).
notInheritPos(xtWHWord).
notInheritPos(xtNLWordForm).

segment(N, M, Len, StringW, Ace):-
  nlfw(SN, SM, text80(Words), Ace),
  between(0, SN, N),
  between(N, SM, M),
  between(1, SM, Len),
  Len is M-N+1,
  length(Left, N),
  length(StringW, Len),
  append(Left, StringW, Words).


% ((nlfw(N, N, cycpos(xtWHDeterminer, _, _), Ace)/M is N+1) ==>nlfw(M, M, xclude(xtWHDeterminer,
/*
:- (prolog_load_context(reloading, true)
      -> (prolog_load_context(source, File), mpred_remove_file_support(File))
     ; true).


((nlfw(_N, _M, text80(Words), Ace)/nth0(NM, Words, W), maybe_text(W, WW))==> nlfw(NM, NM, WW, Ace)).
((do_e2c_fwd(String, ID)/text_into_wall(String, ID, Ace, WalledWords, M, N)) ==> (nlfw(M, N, ace_text(Ace), ID), nlfw(M, N, text80(WalledWords), ID))).
:- ain((nlfw(M, N, cycpos(xtPreposition, C, W), Ace)==> nlfw(M, N, xclude(xtAdverb, C, W), Ace))).
:- ain((nlfw(M, N, cycpos(xtAdjectiveGradable, C, W), Ace)==> nlfw(M, N, xclude(xtClosedClassWord, C, W), Ace))).
:- ain((nlfw(M, N, cycpos(xtAdjectiveGradable, C, W), Ace)==> nlfw(M, N, xclude(xtNoun, C, W), Ace))).
:- ain((nlfw(M, N, cycpos(xtPronoun, C, W), Ace)==> nlfw(M, N, xclude(xtDeterminer, C, W), Ace))).
:- ain((nlfw(M, N, cycpos(xtDeterminer, C, W), Ace)==> nlfw(M, N, xclude(xtAdverb, C, W), Ace))).
:- ain((nlfw(M, N, cycpos(xtDeterminer, C, W), Ace)==> nlfw(M, N, xclude(xtAdjective, C, W), Ace))).


((later_on, nlfw(M, N, txt(W), Ace)/member(Pos, [xtNoun, xtVerb, xtAdjective, xtAdverb, xtPronoun, xtPreposition, xtDeterminer]))
  ==> nlfw(M, N, maybe_pos(Pos, W), Ace)).
((nlfw(M, N, txt(W), Ace)/text_to_cycword(W, P, C, _Why)) ==> nlfw(M, N, cycword(P, C, W), Ace)).
((nlfw(M, N, txt(W), Ace)/clex_word(P, W, C, T)) ==> nlfw(M, N, clex_word(P, clexFn(C), T, W), Ace)).
%((nlfw(M, N, cycword(P, C, W), Ace)/cycpred_to_cycpos(P, Pos) ==> nlfw(M, N, cycpos(Pos, C, W), Ace))).
((
   nlfw(M, N, cycpos(Pos, C, W), Ace),
   \+ nlfw(M, N, xclude(Pos, C, W), Ace),
 %  nlfw(M, N, cycword(_, C, W), Ace),
  {ac(denotation, C, Pos, _, Subj)})==> nlfw(M, N, value(Subj, C, W), Ace)).

:- ain((nlfw(M, N, cycword(PosL, C, W), Ace)/(pos_inherit(PosL, PosH), \+ notInheritPos(PosH)))==>nlfw(M, N, cycpos(PosH, C, W), Ace)).
:- ain((nlfw(M, N, cycpos(PosL, C, W), Ace)/(pos_inherit(PosL, PosH), \+ notInheritPos(PosH)))==>nlfw(M, N, cycpos(PosH, C, W), Ace)).
:- ain((nlfw(M, N, xclude(PosL, C, W), Ace)/(pos_inherit(PosH, PosL)))==>nlfw(M, N, xclude(PosH, C, W), Ace)).
:- ain((nlfw(M, N, xclude(Pos, C, W), Ace))==> \+ nlfw(M, N, cycpos(Pos, C, W), Ace)).
%:- ain((nlfw(M, N, xclude(Pos, C, W), Ace))==> \+ nlfw(M, N, cycword(Pos, C, W), Ace)).
%:- ain((nlfw(M, N, cycpos(Pos, C, W), Ace))==> \+ nlfw(M, N, xclude(Pos, C, W), Ace)).
*/

pos_inherit(PosL, PosH):- ac(genls, PosL, PosH).
pos_inherit(Pred, Pos):- ac(speechPartPreds, Pos, Pred).


:- export(lex_info/1).
lex_info(String):-
 lex_info(_AllKinds, String, Datum),
 lex_print(Datum).

:- export(lex_info/3).
lex_info(Kind, String, Out):-
 into_text100_atoms(String, Words), % maplist(into_dm, Words, Todo),
 into_acetext(Words, Ace), cvt_to_real_string(Ace, SAce),
 call_corenlp(SAce,[],Todo),
 maplist(print_reply_colored,Todo), print_reply_colored("==============================================================="),
 Level = 0,
 findall(sentence(N,WS,Info),member(sentence(N,WS,Info),Todo),Sents),
 maplist(remove_broken_corefs(Sents),Todo,NewTodo),
 lex_info(Kind, Level, NewTodo, [text80(Words)], Datum),
 % maplist(lex_winfo(Kind, Level, Words), Words, Datums),append(Datums, Datum),
 filter_mmw(Datum, Out), !.

lex_winfo(Kind, Level, Words, String, Datum):-
 cvt_to_atom(String, AString),
 lex_info(Kind, Level, txt(AString), [text80(Words)], Datum).

%into_dm(String, txt(AString)):- cvt_to_atom(String, AString).

didnt_do(Todo, skipped(Todo)).


remove_broken_corefs(Sents,coref(Sent,_, _, _,_,_,_,_,_),[]):- \+ member(sentence(Sent,_,_),Sents),!.
remove_broken_corefs(_Sents,sentence(N,Words,Info),sent(N,Words,Info)).
remove_broken_corefs(_Sents,A,A).

lex_info(_Kind, _Level, [], Done, Out):- !, Done = Out.
lex_info(Kind, Level, Todo, Done, Out):- correct_dos(Todo, TodoS), TodoS\==Todo, !, lex_info(Kind, Level, TodoS, Done, Out).
lex_info(Kind, Level, Todo, Done, Out):- correct_dos(Done, DoneS), DoneS\==Done, !, lex_info(Kind, Level, Todo, DoneS, Out).
lex_info(_Kind, Level, Todo, Done, Out) :- Level > 3, !, maplist(didnt_do, Todo, NotTodo), append(Done, NotTodo, Out).
lex_info(Kind, Level, Todo, Done, Out):- must(lex_info_loop(Kind, Level, Todo, Done, Out)).

lex_info_loop(Kind, Level, [M:Did|Todo], Done, Out):- atom(M), !, lex_info(Kind, Level, [Did|Todo], Done, Out).
lex_info_loop(Kind, Level, Todo, Done, Out):- lex_info_impl(Kind, Level, Todo, Done, Out), !.
lex_info_loop(Kind, Level, [Did|Todo], Done, Out):-
 Did =..[T, F|RestP],
 member(T, [acnl, cyckb_h, t, talk_db]),
 (T == acnl -> append(Rest, [_Ref], RestP) ; RestP= Rest),
% (T == t -> TAdd = Do ; TAdd = T),
 atom(F),
 Do =..[F|Rest],
 lex_info(Kind, Level, [Do|Todo], Done, Out).
lex_info_loop(Kind, Level, [Did|Todo], Done, Out):-
 compound(Did), functor(Did, F, A),
 findall(Arg, (arg(_, Did, Arg), nonvar(Arg), searches_arg(F, A, Arg)), List),
 List\==[],
 maplist(add_search_arg, List, DoNow),
 add_do_more(DoNow, Todo, Done, NewTodo),
 lex_info(Kind, Level, NewTodo, Done, Out).
lex_info_loop(Kind, Level, [Did|Todo], Done, Out):-
 add_if_new(Done, Did, NewDone),
 lex_info(Kind, Level, Todo, NewDone, Out).




lex_info_impl(Kind, Level, Todo, Done, Out):- 
   findall(sentence(N,Words,Info),member(sentence(N,Words,Info),Todo),Sents), Sents\==[],
   maplist(remove_broken_corefs(Sents),Todo,NewTodo), 
   NewTodo\==Todo, !, 
   lex_info(Kind, Level, NewTodo, Done, Out).


lex_info_impl(Kind, Level, [txt(String)|Todo], Done, Out):-
 cvt_to_atom(String, Atom),
 get_lex_info(Kind, text(a), Atom, Result),
 append(Done, Result, DoneResult), my_l2s(DoneResult, NewDone),
 lex_info(Kind, Level, Todo, NewDone, Out).

lex_info_impl(Kind, Level, [todo(Type, Value)| Todo], Done, Out):- !,
  lex_info(Kind, Level, [todo(Level, Type, Value)| Todo], Done, Out).

lex_info_impl(Kind, _Lev__, [todo(Level, DoType, Value)| Todo], Done, Out):-
 doable_type(Level, DoType, Type),
 Doing = todo(Level, Type, Value),
 add_if_new(Done, Doing, NewDone),
 findall(Info, get_info_about_type(Kind, Level, Type, Value, Info), More),
 add_do_more(More, Todo, NewDone, NewTodo),
 lex_info(Kind, Level, NewTodo, NewDone, Out), !.

lex_info_impl(Kind, Level, [cycWord(P, CycWord)|Todo], Done, Out):-
 findall(concept(Subj), cycword_to_cycconcept(P, CycWord, Subj), More1),
 findall(Info, term_to_infolist(CycWord, Info), More2),
 add_if_new(Done, cycWord(P, CycWord), NewDone),
 add_do_more([More1, More2], Todo, NewDone, NewTodo),
 lex_info(Kind, Level, NewTodo, NewDone, Out).

lex_info_impl(Kind, Level, [concept(C)|Todo], Done, Out):- fail,
 findall(Info, term_to_infolist(C, Info), More2),
 add_if_new(Done, concept(C), NewDone),
   add_do_more(More2, Todo, NewDone, NewTodo),
   lex_info(Kind, Level, NewTodo, NewDone, Out).


lex_info_impl(Kind, Level, [sent(N,Words,Info)|Todo], Done, Out):-
   append(Done,[sent(N,Words,Info)],NewDone),
   add_do_more(Words, Todo, NewDone, NewTodo),
   lex_info(Kind, Level, NewTodo, NewDone, Out).

lex_info_impl(Kind, Level, [TOK|Todo], Done, Out):- TOK = tok(_Index,PennPos,_Base,String, _Info),!,
  must((

   findall_set(MorePos,extend_brillPos(PennPos,MorePos),PosSet),
   nb_set_add(TOK,PosSet),
   % nop 
   AddTodo = [],
   %(AddTodo = txt(String)),
   
   %get_lex_info(Kind, text(a), AString, OutS),
   functor(TOK,_,A),
   arg(A,TOK,PosInfo),
   findall_set(How, (text_pos_cycword(String, [PennPos|PosInfo], How)), OutF),
   % filter_lex(OutS,[PennPos|MorePos],OutF),
   nb_set_add(TOK,OutF),
   append(Done,[TOK],NewDone),
   add_do_more(AddTodo, Todo, NewDone, NewTodo),
   lex_info(Kind, Level, NewTodo, NewDone, Out))).

findall_set(Temp,Goal,Set):-   
   findall(Temp,Goal,List),flatten(List,Flat),list_to_set(Flat,Set),!.

text_pos_cycword(String, MorePos, [cycWord(C)|Out]):- 
  cvt_to_atom(String,AString),text_to_cycword(AString, P, C, How), 
  (not_violate_pos(MorePos,[P,How])
    ->Out=[P]
     ;Out=[violate(P),violate(How)]). 

% :- forall(ac(mostSpeechPartPreds, B, C), retract(ac(speechPartPreds, B, C))).
cycpred_to_cycpos(Pred, Pos):- atom(Pred), pos_inherit(Pred, M),atom(M),atom_concat(xt,_,M),M\==xtNLWordForm,
  Pred\==M,(M=Pos;cycpred_to_cycpos(M, Pos)),atom(Pos).

cycpred_to_cycpos_1(Pred, Pos):- nonvar(Pred),
 ac(speechPartPreds, Pos, Pred), \+ ac(mostSpeechPartPreds, Pos, _), \+ ac(mostSpeechPartPreds, _, Pred).




filter_lex(OutS,[PennPos|MorePos],OutF):-
 include(not_violate_pos([PennPos|MorePos]),OutS,OutF).

%not_violate_pos(_,_):-!.
not_violate_pos(_MorePos,Var):- var(Var),!.
not_violate_pos(_MorePos,[]):-!.
not_violate_pos(MorePos,[H|T]):- !, not_violate_pos(MorePos,H),not_violate_pos(MorePos,T).
not_violate_pos(MorePos,OutS):- 
  violate_pos(MorePos,OutS),!,fail.
not_violate_pos(_MorePos,_OutS).

violate_pos(MorePos,OutS):- \+ compound(OutS), !, violate_pos1(MorePos,OutS).
violate_pos(MorePos,Did):- Did =..[T, F|Rest], member(T, [acnl, cyckb_h, t, talk_db]),
 atom(F), Do =..[F|Rest], !,
 violate_pos(MorePos,Do).
violate_pos(MorePos,OutS):- functor(OutS,F,_),violate_pos1(MorePos,F),!.
violate_pos(MorePos,OutS):- functor(OutS,F,_),pos_inherit(F, Pos),!,violate_pos(MorePos,Pos).
violate_pos(MorePos,OutS):- arg(_,OutS,E),violate_pos1(MorePos,E),!.
violate_pos(MorePos,OutS):- violate_pos1(MorePos,OutS).

pos_list([xtNoun,xtPronoun,xtCoordinatingConjunction,
  xtVerb,xtAdjective,xtAdverb,xtPreposition,xtPunctuationSP]).
pos_list([xtNoun,xtCoordinatingConjunction,
  xtVerb,xtAdjective,xtAdverb,xtDeterminer,xtPreposition,xtPunctuationSP]).

incompatible_pos(XtNoun,XtVerb):- pos_list(PosList),member(XtNoun,PosList),member(XtVerb,PosList),XtNoun\==XtVerb.

violate_pos1(MorePos,OutS):- incompatible_pos(XtNoun,XtVerb),member(XtNoun,MorePos),OutS==XtVerb.
violate_pos1(_,todo).
violate_pos1(_,txt).
violate_pos1(_,comment).
violate_pos1(_,flexicon).
violate_pos1(_,M):- atom(M),member(M,[mws,flexicon,fsr]).
%violate_pos(MorePos,OutS,OutF).

extend_brillPos(In,[Out]):- freeze(cvt_to_real_string(In,Str)),ac(pennTagString,Out,Str).
extend_brillPos('PRP$',['Possessive'|Rest]):- extend_brillPos('PRP',Rest).
extend_brillPos('PRP',['SpecialDeterminer','xtDeterminer','second']).
extend_brillPos(In,Out):- bposToCPos(In,Out).
extend_brillPos(In,form(Out)):- bposToCPosForm(In,Out).
extend_brillPos(In,Out):- brillPos([In|Out]) *-> true 
 ; (freeze(In,downcase_atom(In,DC)),freeze(DC,upcase_atom(DC,In)),In\==DC,brillPos([DC|Out])).


add_search_arg(Arg, concept(Arg)).

  % 202488488
searches_arg(_F, _A, _Arg):- !, fail.
searches_arg(_F, _A, Arg):- is_synset_id(Arg), !.
searches_arg(_F, _A, Arg):- \+ atom(Arg), !, fail.
searches_arg(_F, _A, Arg):- atom_length(Arg, Len), Len<4, !, fail.
% searches_arg(_F, _A, Arg):- atom_contains(Arg, '.'), !.
%searches_arg(_F, _A, Arg):- (atom_contains(Arg, '.');atom_contains(Arg, '-');atom_contains(Arg, '%')), !.

:- ensure_loaded(library('../ext/ProNTo/Schlachter/pronto_morph_engine.pl')).
%  morph_atoms(causer, [[W, -er]]).


:- dynamic(tmp:saved_denote_lex/3).
:- retractall(tmp:saved_denote_lex(_, _, _)).
%get_lex_info(Kind, text(a), String, Out):- catch(downcase_atom(String, DCAtom), _, fail), DCAtom\==String, !, get_lex_info(Kind, text(a), DCAtom, Out).
get_lex_info(_Kind, Type, DCAtom, Out):- tmp:saved_denote_lex(Type, DCAtom, Out), !.
get_lex_info(Kind, Type, DCAtom, Out):- do_lex_info(Kind, Type, DCAtom, Out), asserta(tmp:saved_denote_lex(Type, DCAtom, Out)), !.


do_lex_info(Kind, text(Type), AString, OutS):-
 findall([cycWord(P, C), Kind], text_to_cycword(AString, P, C, Kind), More1),
 NewDone = [txt(AString)],
 cvt_to_atom(AString, Atom),
 Level = 0,
 add_do_more([todo( Level, text(Type), Atom), More1], [], NewDone, NewTodo),
 lex_info(Kind, Level, NewTodo, NewDone, Out), !,
% =(Out, OutS).
 predsort(ignore_level, Out, OutS).

% my_l2s(List, Set) :- !, List=Set.
my_l2s(List, Set) :-
    must_be(list, List),
    lists:number_list(List, 1, Numbered),
    sort(1, @=<, Numbered, ONum),
    lists:remove_dup_keys(ONum, NumSet),
    sort(2, @=<, NumSet, ONumSet),
    pairs_keys(ONumSet, Set), !.

ignore_level( ( = ), level(Kind, _, _, C1, _), level(Kind, _, _, C2, _)):- compare(( = ), C1, C2), !.
ignore_level(R, C1, C2):- compare(R, C1, C2), !.



%term_to_info(C, P):- gen_preds_atomic(C, P).
%term_to_info(C, P):- between(2, 12, A), functor(P, cyckb_h, A), call(P), sub_term(X, P), X==C.
term_to_infolist(C, _Info):- number(C), \+ (C > 100001739 ; C < - 100000), !, fail.
term_to_infolist(C, Info):-
 findall(P, term_to_info(C, P), L),
 correct_dos(L, Info).

%term_to_info(Term, Info):- in_call(Term, Info, Template, cyckb_h('genTemplate', _, Template)).
%term_to_info(Term, Info):- in_call(Term, Info, Template, cyckb_h('genTemplateConstrained', _, _, Template)).
term_to_info(Term, Info):- Info=cyckb_h(_Pred, Cont), call(Info), sub_var(Term, Cont).
term_to_info(Term, Info):- Info=cyckb_h(_Pred, Term, S), call(Info), \+ string(S).
term_to_info(Term, Info):- Info=cyckb_h(_Pred, Term, _, S), call(Info), \+ string(S).
term_to_info(Term, Info):- between(5, 12, A), functor(Info, cyckb_h, A), arg(N, Info, Term), N>1, call(Info).

%term_to_info(C, P):- ac_nl_info_1(C, Results), member(P, Results).
%term_to_info(C, P):- between(3, 12, A), functor(P, acnl, A), arg(N, P, C), N<A, N>1, call(P).

in_call(C, P, Template, Call):- P=Call, call(P), once(sub_var(C, Template)).


cycword_to_cycconcept(Pred, C, Subj):- ac(speechPartPreds, Pos, Pred), ac(denotation, C, Pos, _, Subj).
% cycword_to_cycconcept(_P, C, Subj):- acnl(denotation, C, _, _, Subj, _).


:- dynamic(lex_arg_type/4).

lex_arg_type( _, _, M, P):- nonvar(P), skip_lex_arg_type(M, P), !.



lex_arg_type( syn, 0, parser_lexical, text_to_cycword(text(a), cycpred, cycword, data)).
%lex_arg_type( syn, _, parser_lexical, cycpred_to_cycpos(cycpred, cycpos)).
lex_arg_type( syn, _, parser_lexical, cycword_to_cycconcept(-cycpred, -cycword, value)).


lex_arg_type( syn, 0, clex, clex_word(pos, text(a), text(base), data)).

lex_arg_type( syn, 0, framenet, fnpattern(text(a), id(fn), concept(fn), data)).

lex_arg_type( sem, 0, framenet, frel(+(causative_of), concept(fn2), concept(fn2))).
lex_arg_type( sem, 0, framenet, frel(+(coreset), concept(fn2), concept(fn2))).
lex_arg_type( sem, 0, framenet, frel(+(excludes), concept(fn2), concept(fn2))).
lex_arg_type( sem, 0, framenet, frel(+(inchoative_of), concept(fn2), concept(fn2))).
lex_arg_type( sem, 0, framenet, frel(+(inheritance), data, concept(fn2))).
lex_arg_type( sem, 0, framenet, frel(+(perspective_on), concept(fn2), concept(fn2))).
lex_arg_type( sem, 0, framenet, frel(+(precedes), concept(fn2), concept(fn2))).
lex_arg_type( sem, 0, framenet, frel(+(reframing_mapping), concept(fn2), concept(fn2))).
lex_arg_type( sem, 0, framenet, frel(+(requires), concept(fn2), concept(fn2))).
lex_arg_type( sem, 0, framenet, frel(+(see_also), concept(fn2), concept(fn2))).
lex_arg_type( sem, 0, framenet, frel(+(subframe), concept(fn2), concept(fn2))).
lex_arg_type( sem, 0, framenet, frel(+(using), concept(fn2), /*concept(fn2)*/ data )).
lex_arg_type( sem, 0, framenet, frels(+(causative_of), concept(fn2), concept(fn2), data, data)).
lex_arg_type( sem, 0, framenet, frels(+(coreset), concept(fn2), concept(fn2), data, data)).
lex_arg_type( sem, 0, framenet, frels(+(excludes), concept(fn2), concept(fn2), data, data)).
lex_arg_type( sem, 0, framenet, frels(+(inchoative_of), concept(fn2), concept(fn2), data, data)).
lex_arg_type( sem, 0, framenet, frels(+(inheritance), data, concept(fn2), data, data)).
lex_arg_type( sem, 0, framenet, frels(+(perspective_on), concept(fn2), concept(fn2), data, data)).
lex_arg_type( sem, 0, framenet, frels(+(precedes), concept(fn2), concept(fn2), data, data)).
lex_arg_type( sem, 0, framenet, frels(+(reframing_mapping), concept(fn2), concept(fn2), data, data)).
lex_arg_type( sem, 0, framenet, frels(+(requires), concept(fn2), concept(fn2), data, data)).
lex_arg_type( sem, 0, framenet, frels(+(see_also), concept(fn2), concept(fn2), data, data)).
lex_arg_type( sem, 0, framenet, frels(+(subframe), concept(fn2), concept(fn2), data, data)).
lex_arg_type( sem, 0, framenet, frels(+(using), concept(fn2), data, /* concept(fn2), */ data, data)).

lex_arg_type( syn, 0, framenet, fsr(text(a)-pos, concept(fn), data)).
lex_arg_type( sem, 0, framenet, semtype(concept(fn), data, data)).
lex_arg_type( syn, 0, mu, thetaRole(text(a), data, concept(tt2), data, data, concept(tt2), text(str), text(str), data)).

lex_arg_type( sem, 0, tt0, ttholds(concept(tt), concept(tt))).
lex_arg_type( sem, 0, tt0, ttholds(text(a), concept(tt))).
lex_arg_type( sem, 0, tt0, ttholds(data, id(tt), pos)).
lex_arg_type( sem, 0, tt0, ttholds(data, id(tt), pos, data)).
lex_arg_type( sem, 0, tt0, ttholds(data, id(tt), pos, data, concept(tt))).
lex_arg_type( sem, 0, tt0, ttholds(data, concept(tt), data)).
lex_arg_type( sem, 0, tt0, ttholds(pos, id(tt), text(str))).

lex_arg_type( syn, f(0), nldata_BRN_WSJ_LEXICON, text_bpos(text(a), pos)).
lex_arg_type( syn, 0, nldata_dictionary_some01, explitVocab(text(a), pos)).
lex_arg_type( syn, f(0), nldata_freq_pdat, text_bpos(data, text(a), pos)).
lex_arg_type( sem, 0, nldata_colloc_pdat, mws(seq(text(a)), pos)).
lex_arg_type( sem, 0, nldata_dictionary_some01, dictionary(pos, seq(text(a)), seq(text(a)))).

lex_arg_type( sem, 0, parser_chat80, adj_sign_db(text(base), data)).
% lex_arg_type( sem, 0, parser_chat80, adjunction_lf(text(base), data, data)).
lex_arg_type( syn, 0, parser_chat80, adjunction_lf(any(text(a)), data, data, data)).
lex_arg_type( syn, 0, parser_chat80, aggr_adj_db(text(a), data, data, text(base))).
lex_arg_type( syn, 0, parser_chat80, aggr_noun_db(text(a), data, data, text(base))).
lex_arg_type( sem, 0, parser_chat80, borders(text(base), text(base))).
lex_arg_type( sem, 0, parser_chat80, city(text(base), text(base), data)).
lex_arg_type( sem, 0, parser_chat80, comparator_db(text(base), data, data, data, data)).
lex_arg_type( sem, 0, parser_chat80, contains(text(base), text(base))).
lex_arg_type( sem, 0, parser_chat80, contains0(text(base), text(base))).
lex_arg_type( sem, 0, parser_chat80, context_pron_db(text(base), data, data)).
% lex_arg_type( sem, 0, parser_chat80, adj_db(text(a), data)).
lex_arg_type( sem, 0, parser_chat80, country(text(base), text(base), data, data, data, data, text(base), text(base))).
lex_arg_type( sem, 0, parser_chat80, det_db(text(base), data, text(base), data)).
lex_arg_type( sem, 0, parser_chat80, in_continent(text(base), text(base))).
lex_arg_type( sem, 0, parser_chat80, int_art_db(text(a), data, data, data)).
lex_arg_type( sem, 0, parser_chat80, int_pron_db(text(a), data)).
lex_arg_type( sem, 0, parser_chat80, intrans_LF(text(base), data, data, data, data, data)).
%lex_arg_type( sem, 0, parser_chat80, inverse_db(text(a), data, text(a))).
lex_arg_type( sem, 0, parser_chat80, latitude80(text(base), data)).
lex_arg_type( sem, 0, parser_chat80, loc_pred_prep_db(text(a), data, data)).
lex_arg_type( sem, 0, parser_chat80, measure_op_db(text(a), data, data, data)).
lex_arg_type( sem, 0, parser_chat80, measure_unit_type_db(text(a), data, data, data)).
lex_arg_type( syn, 0, parser_chat80, meta_noun_db(text(a), data, data, data, data, data, data)).
%lex_arg_type( sem, 0, parser_chat80, name_db(seq(text(a)), text(base))).
lex_arg_type( syn, 0, parser_chat80, pers_pron_db(text(a), pos, data, pos, pos)).
lex_arg_type( syn, 0, parser_chat80, poss_pron_db(text(a), pos, data, pos)).
lex_arg_type( syn, 0, parser_chat80, pronoun_to_var(text(a), upcase(text(a)))).
%lex_arg_type( sem, 0, parser_chat80, punct_to_sent_type(text(base), data, pos)).
lex_arg_type( sem, 0, parser_chat80, quantifier_pron_db(text(a), text(base), data)).
lex_arg_type( sem, 0, parser_chat80, ratio_db(text(base), text(base), data, data)).
lex_arg_type( sem, 0, parser_chat80, rel_adj_db(text(a), text(base))).
lex_arg_type( sem, 0, parser_chat80, rel_pron_db(text(a), pos)).
lex_arg_type( sem, 0, parser_chat80, river_pathlist(text(base), any(text(base)))).
lex_arg_type( sem, 0, parser_chat80, sup_adj_db(text(a), text(base))).
lex_arg_type( sem, 0, parser_chat80, sup_op(text(a), data)).
lex_arg_type( syn, 0, parser_chat80, terminator_db(text(a), data)).
lex_arg_type( sem, 0, parser_chat80, tr_number(text(a), data)).
lex_arg_type( sem, 0, parser_chat80, trans_LF(text(a), data, data, data, data, data, data, data, data)).
lex_arg_type( sem, 0, parser_chat80, type_measured_by_pred_db(data, data, text(a))).
lex_arg_type( sem, 0, parser_chat80, units_db(text(a), data)).
lex_arg_type( sem, 0, parser_chat80, regular_past_db(text(a), text(base))).
lex_arg_type( sem, 0, parser_chat80, subj_obj_LF(data, text(a), data, data, data, data, data)).

lex_arg_type( sem, 0, parser_e2c, aux_lf(text(a), data, data, data)).
lex_arg_type( syn, 0, parser_e2c, char_type_sentence(text(a), pos)).
lex_arg_type( syn, 0, parser_e2c, comparative_number(seq(text(a)), data)).
lex_arg_type( syn, 0, parser_e2c, flexicon(pos, data, any(text(a)))).
lex_arg_type( syn, 0, parser_e2c, idiomatic_replace(seq(text(a)), seq(text(a)))).

lex_arg_type( syn, 0, parser_e2c, is_junct(text(a), data)).
lex_arg_type( syn, 0, parser_e2c, pn_dict_tiny(text(a), data)).
lex_arg_type( syn, 0, parser_e2c, reflexive_pronoun(text(base), text(a), data)).
lex_arg_type( syn, 0, parser_e2c, type_wrd_frm5(pos, text(a), data, data, data)).
lex_arg_type( syn, 0, parser_e2c, type_wrd_sem(pos, any(text(a)), data)).
lex_arg_type( syn, 0, parser_e2c, type_wrd_sem5(pos, text(a), data, data, data)).
lex_arg_type( syn, 0, parser_e2c, type_wrd_wrd_sem6(pos, text(a), text(base), data, data, data)).
lex_arg_type( syn, 0, parser_e2c, whpron_dict(text(a), data)).

lex_arg_type( syn, 0, talk_db, talk_db(pos, text(a))).
lex_arg_type( syn, 0, talk_db, talk_db(+(domain), text(base), data)).
lex_arg_type( syn, 0, talk_db, talk_db(+(noun1), text(base), text(a))).
lex_arg_type( syn, 0, talk_db, talk_db(+(superl), text(base), text(a))).
lex_arg_type( syn, 0, talk_db, talk_db(+(comp), text(base), text(a))).
lex_arg_type( syn, 0, talk_db, talk_db(pos, text(a), text(a), text(base))).
lex_arg_type( syn, 0, talk_db, talk_db(pos, text(base), text(a), text(a), text(a), text(a))).

lex_arg_type( sem, 0, vndata, verbnet_class(concept(vn), data, concept(vn), listof(concept(vn)))).
lex_arg_type( sem, 0, vndata, verbnet_example(concept(vn), data)).
lex_arg_type( sem, 0, vndata, verbnet_frame(data, verb(vn(concept(vn))), data, data, data, data, concept(vn))).
lex_arg_type( sem, 0, vndata, verbnet_frame_prop(concept(vn), data, data)).
lex_arg_type( sem, 0, vndata, verbnet_frame_vars(concept(vn), data, data)).
lex_arg_type( sem, 0, vndata, verbnet_initial_vars(concept(vn), data, data)).
lex_arg_type( sem, 0, vndata, verbnet_map_wn(text(a), listof(concept(wn)), concept(vn))).
lex_arg_type( sem, 0, vndata, verbnet_semantics(concept(vn), data)).
lex_arg_type( sem, 0, vndata, verbnet_syntax(concept(vn), data)).
lex_arg_type( sem, 0, vndata, verbnet_to_framenet(concept(vn), text(a), concept(fn))).
lex_arg_type( syn, 0, vndata, verbnet_word(text(a), concept(vn), data)).

lex_arg_type( syn, 0, wnframes, sk(id(wn), data, data)).
lex_arg_type( syn, 0, wnframes, s(id(wn), data, text(a), pos, data, data)).
lex_arg_type( sem, 0, wnframes, syntax(id(wn), data, pos)).
lex_arg_type( sem, 0, wnframes, ant(id(wn), data, id(wn), data)).
lex_arg_type( sem, 0, wnframes, at(id(wn), id(wn))).
lex_arg_type( sem, 0, wnframes, cls(id(wn), data, id(wn), data, t)).
lex_arg_type( sem, 0, wnframes, cs(id(wn), id(wn))).
lex_arg_type( sem, 0, wnframes, der(id(wn), data, id(wn), data)).
lex_arg_type( sem, 0, wnframes, ent(id(wn), id(wn))).
lex_arg_type( sem, 0, wnframes, fr(id(wn), data, data)).
% lex_arg_type( sem, 0, wnframes, g(id(wn), data)).
lex_arg_type( sem, 0, wnframes, hyp(id(wn), data)).
lex_arg_type( sem, 0, wnframes, ins(id(wn), id(wn))).
lex_arg_type( sem, 0, wnframes, mm(id(wn), id(wn))).
lex_arg_type( sem, 0, wnframes, mp(id(wn), id(wn))).
lex_arg_type( sem, 0, wnframes, ms(id(wn), id(wn))).
lex_arg_type( sem, 0, wnframes, opposite(pos, text(base), text(base), data)).
lex_arg_type( sem, 0, wnframes, per(id(wn), data, id(wn), data)).
lex_arg_type( sem, 0, wnframes, ppl(id(wn), data, id(wn), data)).
lex_arg_type( sem, 0, wnframes, sa(id(wn), data, id(wn), data)).
lex_arg_type( sem, 0, wnframes, sim(id(wn), id(wn))).
lex_arg_type( sem, 0, wnframes, vgp(id(wn), data, id(wn), data)).

binds_with(C, _Val):- \+ atomic(C), !, fail.
binds_with(C, Val):- var(Val), !, put_attr(Val, binds_atomic, C).
binds_with(C, Val):- compound(Val), !, sub_term(V, Val), atomic(V), same_atoms(C, V), !.
binds_with(C, Val):- same_atoms(C, Val).

same_atoms(A1, A2):- A1==A2->true;(A2\==[], A1\==[], downcase_atom(A1, V1), downcase_atom(A2, V2), !, V1==V2).


% binds_with(C, Val):- compound(Val), !, arg(_, Val, V), V==C.
% binds_with(C, Val):- var(C), !, freeze(C, binds_with(C, Val)).

binds_atomic:attr_unify_hook(C, Val):- binds_with(C, Val).


:- set_prolog_flag(debugger_write_options, [quoted(true), portray(true), max_depth(20), attributes(dots)]).
:- fixup_exports.
/* first_clause_only tests  */

fco_test(A):- !, first_clause_only(fco_test(A)).
fco_test(A):- member(A, [1, 2]).
fco_test(A):- member(A, [3, 4]).

/*
:- begin_tests(first_clause_only).

test(first_clause_only, all(X == [1, 2])) :-
        ( fco_test(X) ).

:- end_tests(first_clause_only).
*/

baseKB:sanity_test:- call_corenlp(
'There are 5 houses with five different owners.
 These five owners drink a certain type of beverage, smoke a certain brand of cigar and keep a certain pet.
 No owners have the same pet, smoke the same brand of cigar or drink the same beverage.
 The man who smokes Blends has a neighbor who drinks water.
 A red cat fastly jumped onto the table which is in the kitchen of the house.
 After Slitscan, Laney heard about another job from Rydell, the night security man at the Chateau.
 Rydell was a big quiet Tennessean with a sad shy grin, cheap sunglasses, and a walkie-talkie screwed permanently into one ear.
 Concrete beams overhead had been hand-painted to vaguely resemble blond oak.
 The chairs, like the rest of the furniture in the Chateau\'s lobby, were oversized to the extent that whoever sat in them seemed built to a smaller scale.
 Rydell used his straw to stir the foam and ice remaining at the bottom of his tall plastic cup, as though he were hoping to find a secret prize.
 A book called, "A little tribute to Gibson".
 "You look like the cat that swallowed the canary, " he said, giving her a puzzled look.').


call_corenlp:- call_corenlp(".\nThe Norwegian lives in the first house.\n.").
call_corenlp2:- call_corenlp("Rydell used his straw to stir the foam and ice remaining at the bottom of his tall plastic cup, as though he were hoping to find a secret prize.").
call_lex_info:- lex_info("Rydell used his straw to stir the foam and ice remaining at the bottom of his tall plastic cup, as though he were hoping to find a secret prize.").

baseKB:sanity_test:- call_corenlp(
".
The Brit lives in the red house.
The Swede keeps dogs as pets.
The Dane drinks tea.
The green house is on the immediate left of the white house.
The green house's owner drinks coffee.
The owner who smokes Pall Mall rears birds.
The owner of the yellow house smokes Dunhill.
The owner living in the center house drinks milk.
The Norwegian lives in the first house.
The owner who smokes Blends lives next to the one who keeps cats.
The owner who keeps the horse lives next to the one who smokes Dunhills.
The owner who smokes Bluemasters drinks beer.
The German smokes Prince.
The Norwegian lives next to the blue house.
The owner who smokes Blends lives next to the one who drinks water.").

