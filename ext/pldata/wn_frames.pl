
%:- ensure_loaded(wn30_iface).
:- module(wnframes, [der_stem/2,      
            wn_s/6,			% basic Wordnet relations
	    wn_g/2,
	    wn_hyp/2,
	    wn_ins/2,
	    wn_ent/2,
	    wn_sim/2,
	    wn_mm/2,
	    wn_ms/2,
	    wn_mp/2,
	    wn_der/4,
	    wn_cls/5,
	    wn_cs/2,
	    wn_vgp/4,
	    wn_at/2,
	    wn_ant/4,
	    wn_sa/4,
	    wn_sk/3,
	    wn_syntax/3,
	    wn_ppl/4,
	    wn_per/4,
	    wn_fr/3,

	    wn_cat/3,			% +SynSet, -SyntacticCategory, -Offset
	    ss_type/2			% +Code, -Type
	  ]).

/** <module> Wordnet lexical and semantic database

This module discloses the Wordnet  Prolog   files  is  a more SWI-Prolog
friendly manner. It exploits SWI-Prolog   demand-loading  and SWI-Prolog
Quick Load Files to load `just-in-time' and as quickly as possible.

The system creates Quick Load Files for  each wordnet file needed if the
.qlf file doesn't exist and  the   wordnet  directory  is writeable. For
shared installations it is adviced to   run  load_wordnet/0 as user with
sufficient privileges to create the Quick Load Files.

This library defines a portray/1 rule to explain synset ids.

Some more remarks:

 - SynSet identifiers are large numbers. Such numbers require
   significant more space on the stacks but not in clauses and
   therefore it is not considered worthwhile to strip the
   type info represented in the most significant digit.

 - On wordnet 2.0, the syntactic category deduced from the
   synset id is consistent with the 4th argument of s/6, though
   both adjective and adjective_satellite are represented as
   3XXXXXXXX

@author Originally by Jan Wielemaker. Partly documented by Samer
Abdallah. Current comments copied from prologdb.5WN.html file from the
sources.
@see Wordnet is a lexical database for the English language.
See http://www.cogsci.princeton.edu/~wn/
*/


		 /*******************************
		 *          FIND WORDNET	*
		 *******************************/


%!  wn_op(PredSpec) is nondet.
%
%   Definition of wordnet operator types.

wn_op(ant(synset_id, w_num, synset_id, w_num)).
wn_op(at(synset_id, synset_id)).
wn_op(cls(synset_id, w_num, synset_id, wn_num, class_type)).
wn_op(cs(synset_id, synset_id)).
wn_op(der(synset_id, w_num, synset_id, wn_num)).
wn_op(ent(synset_id, synset_id)).
wn_op(fr(synset_id, w_num, f_num)).
wn_op(g(synset_id, '(gloss)')).
wn_op(hyp(synset_id, synset_id)).
wn_op(ins(synset_id, synset_id)).
wn_op(mm(synset_id, synset_id)).
wn_op(mp(synset_id, synset_id)).
wn_op(ms(synset_id, synset_id)).
wn_op(per(synset_id, w_num, synset_id, w_num)).
wn_op(ppl(synset_id, w_num, synset_id, w_num)).
wn_op(s(synset_id, w_num, 'word', ss_type, sense_number, tag_count)).
wn_op(sa(synset_id, w_num, synset_id, w_num)).
wn_op(sim(synset_id, synset_id)).
wn_op(sk(synset_id, w_num, sense_key)).
wn_op(syntax(synset_id, w_num, syntax)).
wn_op(vgp(synset_id, w_num, synset_id, w_num)).

		 /*******************************
		 *    WORDNET BASIC RELATIONS   *
		 *******************************/

%!  wn_ant(?Antonym1, ?Wnum1, ?Antonym2, ?WNum2) is nondet.
%
%   The ant operator specifies antonymous  word   s.  This  is a lexical
%   relation  that  holds  for  all    syntactic  categories.  For  each
%   antonymous pair, both relations are listed (ie. each synset_id,w_num
%   pair is both a source and target word.)

wn_ant(Antonym1, Wnum1, Antonym2, WNum2) :- ant(Antonym1, Wnum1, Antonym2, WNum2).

%!  wn_at(?Noun, ?Adjective) is nondet.
%
%   The at operator defines the  attribute   relation  between  noun and
%   adjective synset pairs in which the  adjective   is  a  value of the
%   noun. For each pair, both relations   are listed (ie. each synset_id
%   is both a source and target).

wn_at(Noun, Adjective) :- at(Noun, Adjective).

%!  wn_cls(?SynSet, ?W1, ?Class, ?W2, ?ClassType) is nondet.
%
%   The cls operator specifies that the first synset has been classified
%   as a member of the class represented by the second synset. Either of
%   the w_num's can be 0, reflecting that the pointer is semantic in the
%   original WordNet database.

wn_cls(SynSet, W1, Class, W2, ClassType) :-
    cls(SynSet, W1, Class, W2, ClassType).

%!  wn_cs(?SynSet, ?Causes) is nondet.
%
%   First kind of event is caused by second.
%
%   The cs operator specifies that the second   synset is a cause of the
%   first synset. This relation only holds for verbs.

wn_cs(SynSet, Causes) :-
    cs(SynSet, Causes).

%!  wn_der(?SynSet1, ?W1, ?SynSet2, ?W2) is nondet.
%
%   The der operator specifies that  there   exists  a reflexive lexical
%   morphosemantic relation between the first   and  second synset terms
%   representing derivational morphology.

wn_der(SynSet1, W1, SynSet2, W2) :-
    der(SynSet1, W1, SynSet2, W2).

%!  wn_ent(?SynSet, ?Entailment) is nondet.
%
%   The ent operator specifies that the   second synset is an entailment
%   of first synset. This relation only holds for verbs.

wn_ent(SynSet, Entailment) :-
    ent(SynSet, Entailment).

%!  wn_fr(?Synset, ?Wnum, ?Fnum) is nondet.
%
%   fr operator specifies a generic sentence frame  for one or all words
%   in a synset. The operator is defined only for verbs.

wn_fr(Synset, Wnum, Fnum) :-
    fr(Synset, Wnum, Fnum).

%!  wn_g(?SynSet, ?Gloss) is nondet.
%
%   The g operator specifies the gloss for a synset.

wn_g(SynSet, Gloss) :-
    g(SynSet, Gloss).

%!  wn_hyp(?Hyponym, ?HyperNym) is nondet.
%
%   The hyp operator specifies that the second   synset is a hypernym of
%   the first synset. This  relation  holds   for  nouns  and verbs. The
%   reflexive operator, hyponym, implies that  the   first  synset  is a
%   hyponym of the second synset.

wn_hyp(Hyponym, HyperNym) :-
    hyp(Hyponym, HyperNym).

%!  wn_ins(?A,?B) is nondet.
%
%   The ins operator specifies that the first   synset is an instance of
%   the second synset. This relation  holds   for  nouns.  The reflexive
%   operator,  has_instance,  implies  that  the  second  synset  is  an
%   instance of the first synset.

wn_ins(A,B) :- ins(A,B).

%!  wn_mm(?SynSet, ?MemberMeronym) is nondet.
%
%   The mm operator specifies that the second synset is a member meronym
%   of the first  synset.  This  relation   only  holds  for  nouns. The
%   reflexive operator, member holonym, can be implied.

wn_mm(SynSet, MemberMeronym) :-
    mm(SynSet, MemberMeronym).

%!  wn_mp(?SynSet, ?PartMeronym) is nondet.
%
%   The mp opeQrator specifies that the second synset is a part meronym
%   of the first synset. This relation only holds for nouns. The
%   reflexive operator, part holonym, can be implied.

wn_mp(SynSet, PartMeronym) :-
    ms(SynSet, PartMeronym).

%!  wn_ms(?SynSet, ?SubstanceMeronym) is nondet.
%
%   The ms operator specifies that  the   second  synset  is a substance
%   meronym of the first synset. This relation only holds for nouns. The
%   reflexive operator, substance holonym, can be implied.

wn_ms(SynSet, SubstanceMeronym) :-
    ms(SynSet, SubstanceMeronym).

%!  wn_per(?Synset1, ?WNum1, ?Synset2, ?WNum2) is nondet.
%
%   The per operator specifies two  different   relations  based  on the
%   parts of speech involved. If  the  first   word  is  in an adjective
%   synset, that word pertains to either   the  noun or adjective second
%   word. If the first word is in an adverb synset, that word is derived
%   from the adjective second word.

wn_per(Synset1, WNum1, Synset2, WNum2) :-
    per(Synset1, WNum1, Synset2, WNum2).

%!  wn_ppl(?Synset1, ?WNum1, ?Synset2, ?WNum2) is nondet.
%
%   ppl operator specifies that the adjective first word is a participle
%   of the verb second word. The reflexive operator can be implied.

wn_ppl(Synset1, WNum1, Synset2, WNum2) :-
    ppl(Synset1, WNum1, Synset2, WNum2).

%!  wn_s(?SynSet, ?WNum, ?Word, ?SynSetType, ?Sense, ?Tag) is nondet.
%
%   A s operator is present for every word sense in WordNet. In wn_s.pl,
%   w_num specifies the word number for word in the synset.

wn_s(SynSet, WNum, Word, SynSetType, Sense, Tag) :-
    s(SynSet, WNum, Word, SynSetType, Sense, Tag).

%!  wn_sa(?Synset1, ?WNum1, ?Synset2, ?WNum2) is nondet.
%
%   The sa operator specifies  that   additional  information  about the
%   first word can be obtained by seeing  the second word. This operator
%   is only defined for verbs  and   adjectives.  There  is no reflexive
%   relation (ie. it cannot be inferred  that the additional information
%   about the second word can be obtained from the first word).

wn_sa(Synset1, WNum1, Synset2, WNum2) :-
    sa(Synset1, WNum1, Synset2, WNum2).

%!  wn_sim(?SynSet, ?Similar) is nondet.
%
%   The sim operator specifies that  the   second  synset  is similar in
%   meaning to the first synset. This means  that the second synset is a
%   satellite the first synset, which is the cluster head. This relation
%   only holds for adjective synsets contained in adjective clusters.

wn_sim(SynSet, Similar) :-
    sim(SynSet, Similar).

%!  wn_sk(?A,?B,?C) is nondet.
%
%   A sk operator is present for every word sense in WordNet. This gives
%   the WordNet sense key for each word sense.

wn_sk(A,B,C) :-
    sk(A,B,C).

%!  wn_syntax(?A,?B,?C) is nondet.
%
%   The syntax operator specifies the syntactic  marker for a given word
%   sense if one is specified.

wn_syntax(A,B,C) :-
    syntax(A,B,C).

%!  wn_vgp(?Verb, ?W1, ?Similar, ?W2) is nondet.
%
%   vgp operator specifies verb synsets that  are similar in meaning and
%   should be grouped together when displayed   in response to a grouped
%   synset search.

wn_vgp(Verb, W1, Similar, W2) :-
    vgp(Verb, W1, Similar, W2).


		 /*******************************
		 *	   CODE MAPPINGS	*
		 *******************************/

%!	wn_cat(+SynSet, -SyntacticCategory, -Offset) is det.
%
%	Break the synset id into its   syntactic  category and offset as
%	defined in the manpage prologdb.5

wn_cat(SynSet, Category, Small) :-
	Small is SynSet mod 100000000,
	CatNum is SynSet // 100000000,
	wn_cat(CatNum, Category).

wn_cat(1, noun).
wn_cat(2, verb).
wn_cat(3, adjective).
wn_cat(4, adverb).

%!	ss_type(+Code, -Type) is det.
%!	ss_type(-Code, -Type) is nondet.
%
%	Mapping between readable syntactic category and code.

ss_type(n, noun).
ss_type(v, verb).
ss_type(a, adjective).
ss_type(s, adjective_satellite).
ss_type(r, adverb).



word_overlap(W1,W2):- atom_contains(W1,W2);atom_contains(W2,W1).
longer(W1,W2):- atom_length(W1,L1),atom_length(W2,L2),(L1==L2->W1@>W2;L1<L2).
slonger(W1,W2,(=)):-W1==W2,!.
slonger(W1,W2,(>)):-longer(W1,W2),!.
slonger(_W1,_W2,(<)).
maybe_stem(W1,W2):- word_overlap(W1,W2),!. 
maybe_stem(W1,W2):- first_half(W1,L1),first_half(W2,L2), word_overlap(L1,L2).
first_half(S,S2):- atom_length(S,L),L2 is div(L,2), L2>3, sub_atom(S,L2,_,_,S2),!.
first_half(S,S).
% imports der/4 and s/6 from wordnet db
candidate_creation(W1,W2):- wn_der(ID1,SN1,ID2,SN2),wn_s(ID1,SN1,W1,_POS1,_X1,_Y1),wn_s(ID2,SN2,W2,_POS2,_X2,_Y2).
der_stem(O1,O2):- candidate_creation(W1,W2),maybe_stem(W1,W2),W1\==W2,
  (longer(W1,W2)->(O1:O2=W1:W2);(O2:O1=W1:W2)).

tellstems:- tell(tellstems),forall(no_repeats(der_stem(O1,O2)),format('~N~q.~n',[my_stems(O1,O2)])),told.


:-style_check(-singleton).
:-style_check(- (discontiguous)).

:- include('WNprolog-3.0/prolog/wn_ant.pl').
:- include('WNprolog-3.0/prolog/wn_at.pl').
:- include('WNprolog-3.0/prolog/wn_cls.pl').
:- include('WNprolog-3.0/prolog/wn_cs.pl').
:- include('WNprolog-3.0/prolog/wn_der.pl').
:- include('WNprolog-3.0/prolog/wn_ent.pl').
:- include('WNprolog-3.0/prolog/wn_fr.pl').
:- include('WNprolog-3.0/prolog/wn_g.pl').
:- include('WNprolog-3.0/prolog/wn_hyp.pl').
:- include('WNprolog-3.0/prolog/wn_ins.pl').
:- include('WNprolog-3.0/prolog/wn_mm.pl').
:- include('WNprolog-3.0/prolog/wn_mp.pl').
:- include('WNprolog-3.0/prolog/wn_ms.pl').
:- include('WNprolog-3.0/prolog/wn_per.pl').
:- include('WNprolog-3.0/prolog/wn_ppl.pl').
:- include('WNprolog-3.0/prolog/wn_s.pl').
:- include('WNprolog-3.0/prolog/wn_sa.pl').
:- include('WNprolog-3.0/prolog/wn_sim.pl').
:- include('WNprolog-3.0/prolog/wn_sk.pl').
:- include('WNprolog-3.0/prolog/wn_syntax.pl').
:- include('WNprolog-3.0/prolog/wn_vgp.pl').

/*

my_stems('civil liberty','civil-libertarian').
my_stems('co-occurrent','co-occurrence').
my_stems('hair style',hairstylist).
my_stems('left-handed','left-handedness').
my_stems('Modern',modernness).
my_stems('right-handed','right-handedness').
my_stems('three-dimensional','three-dimensionality').
my_stems('two-dimensional','two-dimensionality').
my_stems('up-to-date','up-to-dateness').
my_stems(abound,abundance).
my_stems(abrupt,abruptness).
my_stems(abstemious,abstemiousness).
my_stems(abundant,abundance).
my_stems(accelerate,acceleration).
my_stems(adjacent,adjacency).
my_stems(admit,admittance).
my_stems(adnexa,adnexal).
my_stems(advantage,advantageous).
my_stems(advantageous,advantageousness).
my_stems(advantageous,profitableness).
my_stems(advisable,advisability).
my_stems(affirmative,affirmativeness).
my_stems(aimless,aimlessness).
my_stems(airy,airiness).
my_stems(align,alignment).
my_stems(altitude,altitudinal).
my_stems(altitude,altitudinous).
my_stems(ambidextrous,ambidexterity).
my_stems(ambidextrous,ambidextrousness).
my_stems(ample,ampleness).
my_stems(ampulla,ampullar).
my_stems(ampulla,ampullary).
my_stems(analytic,analyticity).
my_stems(anastomotic,anastomosis).
my_stems(anatomy,anatomic).
my_stems(anatomy,anatomical).
my_stems(anatomy,anatomist).
my_stems(angular,angularity).
my_stems(antecede,antecedence).
my_stems(antecede,antecedency).
my_stems(antecedent,antecedence).
my_stems(antecedent,antecedency).
my_stems(anterior,anteriority).
my_stems(area,areal).
my_stems(arrange,arrangement).
my_stems(arthromere,arthromeric).
my_stems(assailable,assailability).
my_stems(assertive,assertiveness).
my_stems(assess,assessment).
my_stems(astringent,astringency).
my_stems(asymmetry,asymmetric).
my_stems(asymmetry,asymmetrical).
my_stems(attenuate,attenuation).
my_stems(attitude,attitudinise).
my_stems(auspicious,auspiciousness).
my_stems(authorise,authorisation).
my_stems(authorize,authorization).
my_stems(awkward,awkwardness).
my_stems(bad,badness).
my_stems(barren,barrenness).
my_stems(beam,beamy).
my_stems(benefit,beneficial).
my_stems(big,bigness).
my_stems(bilateral,bilaterality).
my_stems(boring,boringness).
my_stems(bottomless,bottomlessness).
my_stems(bounded,boundedness).
my_stems(boundless,boundlessness).
my_stems(bountiful,bountifulness).
my_stems(brachycephaly,brachycephalic).
my_stems(breakable,breakability).
my_stems(bregma,bregmatic).
my_stems(brief,briefness).
my_stems(broad,broadness).
my_stems(bulb,bulbous).
my_stems(bulgy,bulginess).
my_stems(bulk,bulky).
my_stems(bulky,bulkiness).
my_stems(bumptious,bumptiousness).
my_stems(cadaver,cadaveric).
my_stems(cadaver,cadaverous).
my_stems(caliber,calibrate).
my_stems(canal,canalize).
my_stems(canaliculus,canalicular).
my_stems(capable,capability).
my_stems(capable,capableness).
my_stems(capacious,capaciousness).
my_stems(capacity,capacitate).
my_stems(catch,catchy).
my_stems(cauda,caudal).
my_stems(ceaseless,ceaselessness).
my_stems(central,centrality).
my_stems(changeless,changelessness).
my_stems(channel,channelize).
my_stems(cheap,cheapness).
my_stems(chiasm,chiasmal).
my_stems(chiasm,chiasmatic).
my_stems(chiasm,chiasmic).
my_stems(circular,circularity).
my_stems(clear,clearance).
my_stems(close,closeness).
my_stems(cocky,cockiness).
my_stems(coif,coiffure).
my_stems(coincide,coincidence).
my_stems(coincident,coincidence).
my_stems(comical,comicality).
my_stems(commodious,commodiousness).
my_stems(competent,competence).
my_stems(competent,competency).
my_stems(complement,complemental).
my_stems(complement,complementary).
my_stems(concave,concaveness).
my_stems(concave,concavity).
my_stems(concentrate,concentration).
my_stems(concentric,concentricity).
my_stems(concomitant,concomitance).
my_stems(concur,concurrence).
my_stems(concurrent,concurrence).
my_stems(consequence,consequential).
my_stems(constructive,constructiveness).
my_stems(contemporaneous,contemporaneity).
my_stems(contemporaneous,contemporaneousness).
my_stems(contiguous,contiguity).
my_stems(contiguous,contiguousness).
my_stems(continue,continuation).
my_stems(continuous,continuity).
my_stems(continuous,continuousness).
my_stems(contractile,contractility).
my_stems(contrast,contrasty).
my_stems(convex,convexity).
my_stems(convex,convexness).
my_stems(copious,copiousness).
my_stems(cost,costly).
my_stems(costly,costliness).
my_stems(countless,countlessness).
my_stems(cover,coverage).
my_stems(crooked,crookedness).
my_stems(cubic,cubicity).
my_stems(curl,curly).
my_stems(curly,curliness).
my_stems(current,currency).
my_stems(current,currentness).
my_stems(curtail,curtailment).
my_stems(curve,curvature).
my_stems(curve,curvey).
my_stems(cutis,cutaneal).
my_stems(cylindrical,cylindricality).
my_stems(cylindrical,cylindricalness).
my_stems(dead,deadness).
my_stems(dear,dearness).
my_stems(decelerate,deceleration).
my_stems(decussate,decussation).
my_stems(deep,deepness).
my_stems(defenceless,defencelessness).
my_stems(defenseless,defenselessness).
my_stems(defensible,defensibility).
my_stems(deficient,deficiency).
my_stems(deliberate,deliberateness).
my_stems(dense,denseness).
my_stems(desirable,desirability).
my_stems(desirable,desirableness).
my_stems(destructible,destructibility).
my_stems(destructive,destructiveness).
my_stems(deterge,detergence).
my_stems(deterge,detergency).
my_stems(detergent,detergence).
my_stems(detergent,detergency).
my_stems(dextral,dextrality).
my_stems(diameter,diametral).
my_stems(diameter,diametric).
my_stems(diameter,diametrical).
my_stems(diffuse,diffuseness).
my_stems(dimensional,dimensionality).
my_stems(diminutive,diminutiveness).
my_stems(directional,directionality).
my_stems(directive,directiveness).
my_stems(directive,directivity).
my_stems(disadvantage,disadvantageous).
my_stems(discretion,discretionary).
my_stems(dispensable,dispensability).
my_stems(dispensable,dispensableness).
my_stems(disseminate,dissemination).
my_stems(distant,distance).
my_stems(domestic,domesticity).
my_stems(dominate,dominance).
my_stems(down,downy).
my_stems(dreary,dreariness).
my_stems(dull,dullness).
my_stems(durable,durability).
my_stems(dwarfish,dwarfishness).
my_stems(early,earliness).
my_stems(eccentric,eccentricity).
my_stems(effective,effectiveness).
my_stems(effective,effectivity).
my_stems(effectual,effectuality).
my_stems(effectual,effectualness).
my_stems(efficacious,efficaciousness).
my_stems(efficacy,efficacious).
my_stems(elevate,elevation).
my_stems(elliptic,ellipticity).
my_stems(elongate,elongation).
my_stems(empty,emptiness).
my_stems(endless,endlessness).
my_stems(endothelium,endothelial).
my_stems(enduring,enduringness).
my_stems(enervate,enervation).
my_stems(enfranchise,enfranchisement).
my_stems(enjoy,enjoyment).
my_stems(enormous,enormity).
my_stems(enormous,enormousness).
my_stems(entitle,entitlement).
my_stems(ephemeral,ephemerality).
my_stems(ephemeral,ephemeralness).
my_stems(epidermis,epidermal).
my_stems(epidermis,epidermic).
my_stems(epithelium,epithelial).
my_stems(erect,erectness).
my_stems(essential,essentiality).
my_stems(essential,essentialness).
my_stems(everlasting,everlastingness).
my_stems(evert,eversion).
my_stems(exceed,exceedance).
my_stems(excessive,excessiveness).
my_stems(executable,executability).
my_stems(exiguous,exiguity).
my_stems(exorbitant,exorbitance).
my_stems(expedient,expedience).
my_stems(expedient,expediency).
my_stems(expedition,expeditious).
my_stems(expeditious,expeditiousness).
my_stems(expensive,expensiveness).
my_stems(expose,exposure).
my_stems(extensive,extensiveness).
my_stems(external,externality).
my_stems(extravagant,extravagance).
my_stems(far,farawayness).
my_stems(far,farness).
my_stems(fast,fastness).
my_stems(favorable,favorableness).
my_stems(favourable,favourableness).
my_stems(feasible,feasibility).
my_stems(feasible,feasibleness).
my_stems(feckless,fecklessness).
my_stems(fertile,fertility).
my_stems(few,fewness).
my_stems(fine,fineness).
my_stems(finite,finiteness).
my_stems(fit,fitness).
my_stems(flat,flatness).
my_stems(fleet,fleetness).
my_stems(fleeting,fleetingness).
my_stems(flimsy,flimsiness).
my_stems(forward,forwardness).
my_stems(fragile,fragility).
my_stems(frangible,frangibility).
my_stems(frangible,frangibleness).
my_stems(frigid,frigidity).
my_stems(frigid,frigidness).
my_stems(fruitful,fruitfulness).
my_stems(fruitless,fruitlessness).
my_stems(fugacious,fugaciousness).
my_stems(fugacity,fugacious).
my_stems(full,fullness).
my_stems(functional,functionality).
my_stems(futile,futility).
my_stems(future,futurity).
my_stems(fuzz,fuzzy).
my_stems(gentle,gentleness).
my_stems(germ,germinate).
my_stems(glabella,glabellar).
my_stems(glib,glibness).
my_stems(globose,globosity).
my_stems(globular,globularness).
my_stems(glomerulus,glomerular).
my_stems(good,goodness).
my_stems(gradual,graduality).
my_stems(gradual,gradualness).
my_stems(grand,grandness).
my_stems(great,greatness).
my_stems(hair,hairy).
my_stems(handed,handedness).
my_stems(harmful,harmfulness).
my_stems(hasty,hastiness).
my_stems(heavy,heaviness).
my_stems(helpful,helpfulness).
my_stems(helpless,helplessness).
my_stems(high,highness).
my_stems(historical,historicalness).
my_stems(horizontal,horizontality).
my_stems(humor,humorist).
my_stems(humor,humorous).
my_stems(humour,humourist).
my_stems(humour,humourous).
my_stems(hurried,hurriedness).
my_stems(hydrophobic,hydrophobicity).
my_stems(idealist,idealism).
my_stems(idle,idleness).
my_stems(illustrious,illustriousness).
my_stems(immediate,immediateness).
my_stems(immense,immenseness).
my_stems(immense,immensity).
my_stems(immoderate,immoderateness).
my_stems(immortal,immortality).
my_stems(imperishable,imperishability).
my_stems(impermanent,impermanence).
my_stems(impermanent,impermanency).
my_stems(important,importance).
my_stems(impotent,impotence).
my_stems(impotent,impotency).
my_stems(impracticable,impracticability).
my_stems(impracticable,impracticableness).
my_stems(impractical,impracticality).
my_stems(impuissant,impuissance).
my_stems(inadvisable,inadvisability).
my_stems(inauspicious,inauspiciousness).
my_stems(incapable,incapability).
my_stems(incessant,incessancy).
my_stems(incessant,incessantness).
my_stems(incisive,incisiveness).
my_stems(incline,inclination).
my_stems(incompetent,incompetence).
my_stems(incompetent,incompetency).
my_stems(inconsequent,inconsequence).
my_stems(increment,incremental).
my_stems(indestructible,indestructibility).
my_stems(indispensable,indispensability).
my_stems(indispensable,indispensableness).
my_stems(ineffective,ineffectiveness).
my_stems(ineffectual,ineffectuality).
my_stems(ineffectual,ineffectualness).
my_stems(inefficacious,inefficaciousness).
my_stems(inessential,inessentiality).
my_stems(inexpedient,inexpedience).
my_stems(inexpedient,inexpediency).
my_stems(inexpensive,inexpensiveness).
my_stems(infeasible,infeasibility).
my_stems(infinite,infiniteness).
my_stems(influence,influential).
my_stems(infrequent,infrequency).
my_stems(injurious,injuriousness).
my_stems(innervate,innervation).
my_stems(innumerable,innumerableness).
my_stems(inordinate,inordinateness).
my_stems(inosculate,inosculation).
my_stems(insidious,insidiousness).
my_stems(insignificant,insignificance).
my_stems(insipid,insipidness).
my_stems(insoluble,insolubility).
my_stems(instant,instancy).
my_stems(instantaneous,instantaneousness).
my_stems(instrumental,instrumentality).
my_stems(insubstantial,insubstantiality).
my_stems(insufficient,insufficiency).
my_stems(integument,integumental).
my_stems(integument,integumentary).
my_stems(interesting,interestingness).
my_stems(international,internationality).
my_stems(internationalism,internationalistic).
my_stems(interoperable,interoperability).
my_stems(interstice,interstitial).
my_stems(inutile,inutility).
my_stems(invaluable,invaluableness).
my_stems(inward,inwardness).
my_stems(irregular,irregularity).
my_stems(irresistible,irresistibility).
my_stems(irresistible,irresistibleness).
my_stems(isometry,isometric).
my_stems(jejune,jejuneness).
my_stems(jejune,jejunity).
my_stems(large,extensiveness).
my_stems(large,largeness).
my_stems(lasting,lastingness).
my_stems(late,lateness).
my_stems(latitude,latitudinarian).
my_stems(lavish,lavishness).
my_stems(lean,leanness).
my_stems(leisurely,leisureliness).
my_stems(length,lengthy).
my_stems(lengthy,lengthiness).
my_stems(lentigo,lentiginous).
my_stems(liable,liability).
my_stems(limit,limitation).
my_stems(limitless,limitlessness).
my_stems(linear,linearity).
my_stems(little,littleness).
my_stems(lobular,lobularity).
my_stems(lofty,loftiness).
my_stems(long,longness).
my_stems(lopsided,lopsidedness).
my_stems(lord,lordship).
my_stems(low,lowness).
my_stems(lush,lushness).
my_stems(luxuriant,luxuriance).
my_stems(luxury,luxuriate).
my_stems(luxury,luxurious).
my_stems(macula,maculate).
my_stems(magnify,magnitude).
my_stems(major,majority).
my_stems(marginal,marginality).
my_stems(massive,massiveness).
my_stems(maximum,maximise).
my_stems(maximum,maximize).
my_stems(meager,meagerness).
my_stems(meagre,meagreness).
my_stems(meaningful,meaningfulness).
my_stems(measurable,measurability).
my_stems(mindless,mindlessness).
my_stems(minor,minority).
my_stems(minute,minuteness).
my_stems(misalign,misalignment).
my_stems(misplace,misplacement).
my_stems(moderate,moderateness).
my_stems(moderate,moderation).
my_stems(modern,modernity).
my_stems(modern,modernness).
my_stems(modernism,modernistic).
my_stems(modest,modestness).
my_stems(moment,momentous).
my_stems(momentous,momentousness).
my_stems(mortal,mortality).
my_stems(much,muchness).
my_stems(multiple,multiplicity).
my_stems(multitudinous,multitudinousness).
my_stems(narrow,narrowing).
my_stems(narrow,narrowness).
my_stems(near,nearness).
my_stems(negative,negativeness).
my_stems(negative,negativity).
my_stems(negativist,negativism).
my_stems(newsworthy,newsworthiness).
my_stems(northern,northernness).
my_stems(numerous,numerosity).
my_stems(numerous,numerousness).
my_stems(oblate,oblateness).
my_stems(oblique,obliqueness).
my_stems(oblong,oblongness).
my_stems(open,opening).
my_stems(open,openness).
my_stems(optimism,optimistic).
my_stems(optimist,optimism).
my_stems(optimum,optimise).
my_stems(optimum,optimize).
my_stems(orientalist,orientalism).
my_stems(orthogonal,orthogonality).
my_stems(outrageous,outrageousness).
my_stems(overabundant,overabundance).
my_stems(overmuch,overmuchness).
my_stems(paltry,paltriness).
my_stems(past,pastness).
my_stems(pelt,pelting).
my_stems(penetrate,penetration).
my_stems(perdurable,perdurability).
my_stems(permanent,permanence).
my_stems(permanent,permanency).
my_stems(perpendicular,perpendicularity).
my_stems(perpetual,perpetuity).
my_stems(persistent,persistence).
my_stems(person,personify).
my_stems(persuasive,persuasiveness).
my_stems(pessimism,pessimistic).
my_stems(pessimist,pessimism).
my_stems(petite,petiteness).
my_stems(petty,pettiness).
my_stems(place,placement).
my_stems(plane,planeness).
my_stems(plenteous,plenteousness).
my_stems(plentiful,plentifulness).
my_stems(plenty,plenteous).
my_stems(plethora,plethoric).
my_stems(poignant,poignancy).
my_stems(pointed,pointedness).
my_stems(pointless,pointlessness).
my_stems(poison,poisonous).
my_stems(ponderous,ponderousness).
my_stems(poor,poorness).
my_stems(pore,poriferous).
my_stems(positive,positiveness).
my_stems(positive,positivity).
my_stems(posterior,posteriority).
my_stems(posture,postural).
my_stems(powerful,powerfulness).
my_stems(powerless,powerlessness).
my_stems(practicable,practicability).
my_stems(practicable,practicableness).
my_stems(practical,practicality).
my_stems(pragmatic,pragmatism).
my_stems(pragmatism,pragmatical).
my_stems(pragmatist,pragmatism).
my_stems(precede,precedence).
my_stems(precede,precedency).
my_stems(precedent,precedence).
my_stems(precious,preciousness).
my_stems(precipitant,precipitance).
my_stems(precipitant,precipitancy).
my_stems(precipitate,precipitateness).
my_stems(precipitate,precipitation).
my_stems(precipitous,precipitousness).
my_stems(preempt,preemption).
my_stems(preponderant,preponderance).
my_stems(preponderate,preponderance).
my_stems(present,presentness).
my_stems(press,pressure).
my_stems(prevail,prevalence).
my_stems(price,pricey).
my_stems(priceless,pricelessness).
my_stems(prior,priority).
my_stems(priority,prioritize).
my_stems(probability,probabilistic).
my_stems(probable,probability).
my_stems(procrastinate,procrastination).
my_stems(productive,productiveness).
my_stems(productive,productivity).
my_stems(proficient,proficiency).
my_stems(profitable,profitability).
my_stems(profitable,profitableness).
my_stems(profound,profoundness).
my_stems(profound,profundity).
my_stems(profuse,profuseness).
my_stems(prolong,prolongation).
my_stems(prominent,prominence).
my_stems(prompt,promptness).
my_stems(propitious,propitiousness).
my_stems(protract,protraction).
my_stems(proximal,proximity).
my_stems(puissant,puissance).
my_stems(punctual,punctuality).
my_stems(puny,puniness).
my_stems(purposeful,purposefulness).
my_stems(purposeless,aimlessness).
my_stems(purposeless,purposelessness).
my_stems(pushy,pushiness).
my_stems(quantifiable,quantifiability).
my_stems(quick,quickness).
my_stems(ramify,ramification).
my_stems(rank,rankness).
my_stems(rapid,rapidity).
my_stems(rapid,rapidness).
my_stems(rare,rareness).
my_stems(reasonable,reasonableness).
my_stems(recent,recentness).
my_stems(rectangular,rectangularity).
my_stems(redundant,redundance).
my_stems(redundant,redundancy).
my_stems(regular,regularity).
my_stems(relative,relativity).
my_stems(relativity,relativistic).
my_stems(remote,remoteness).
my_stems(resistant,resistance).
my_stems(resourceful,resourcefulness).
my_stems(responsive,responsiveness).
my_stems(retard,retardation).
my_stems(rich,richness).
my_stems(romantic,romanticism).
my_stems(romanticist,romanticism).
my_stems(roomy,roominess).
my_stems(rotate,rotation).
my_stems(rotund,rotundity).
my_stems(rotund,rotundness).
my_stems(round,roundness).
my_stems(rounded,roundedness).
my_stems(runty,runtiness).
my_stems(scalable,scalability).
my_stems(scant,scantness).
my_stems(scanty,scantiness).
my_stems(scarce,scarceness).
my_stems(scarce,scarcity).
my_stems(sciolism,sciolistic).
my_stems(sciolist,sciolism).
my_stems(seasonable,seasonableness).
my_stems(selective,selectivity).
my_stems(senseless,senselessness).
my_stems(sensible,sensibleness).
my_stems(sequence,sequential).
my_stems(serviceable,serviceability).
my_stems(serviceable,serviceableness).
my_stems(shallow,shallowness).
my_stems(shit,shitty).
my_stems(shoddy,shoddiness).
my_stems(short,shortness).
my_stems(shrill,shrillness).
my_stems(significant,significance).
my_stems(simultaneous,simultaneity).
my_stems(simultaneous,simultaneousness).
my_stems(sinistral,sinistrality).
my_stems(sizeable,sizeableness).
my_stems(skew,skewness).
my_stems(skin,skinny).
my_stems(slender,slenderness).
my_stems(slick,slickness).
my_stems(slight,slightness).
my_stems(slim,slimness).
my_stems(slow,slowing).
my_stems(slow,slowness).
my_stems(sluggish,sluggishness).
my_stems(small,smallness).
my_stems(solarise,solarisation).
my_stems(solarize,solarization).
my_stems(soluble,solubility).
my_stems(solvable,solvability).
my_stems(sorry,sorriness).
my_stems(sound,sounding).
my_stems(sound,soundness).
my_stems(southern,southernness).
my_stems(spacious,spaciousness).
my_stems(spare,spareness).
my_stems(sparse,sparseness).
my_stems(sparse,sparsity).
my_stems(spatial,spatiality).
my_stems(special,speciality).
my_stems(spectrum,spectral).
my_stems(speed,speedy).
my_stems(speedy,speediness).
my_stems(spheric,sphericity).
my_stems(spherical,sphericalness).
my_stems(sprawl,sprawling).
my_stems(sprawl,sprawly).
my_stems(square,squareness).
my_stems(squat,squatness).
my_stems(stark,starkness).
my_stems(steep,steepness).
my_stems(stoma,stomatal).
my_stems(stoma,stomatous).
my_stems(straight,straightness).
my_stems(stubby,stubbiness).
my_stems(stuffy,stuffiness).
my_stems(stunted,stuntedness).
my_stems(subsequent,subsequence).
my_stems(subsequent,subsequentness).
my_stems(succeed,succession).
my_stems(successive,successiveness).
my_stems(sudden,suddenness).
my_stems(suffice,sufficiency).
my_stems(sufficient,sufficiency).
my_stems(suffrage,suffragette).
my_stems(suffrage,suffragist).
my_stems(sumptuous,sumptuosity).
my_stems(sumptuous,sumptuousness).
my_stems(superabundant,superabundance).
my_stems(superficial,superficiality).
my_stems(superfluous,superfluity).
my_stems(superior,superiority).
my_stems(supplement,supplemental).
my_stems(supplement,supplementary).
my_stems(supplement,supplementation).
my_stems(swift,swiftness).
my_stems(symmetrical,symmetricalness).
my_stems(symmetry,symmetric).
my_stems(symmetry,symmetrise).
my_stems(symmetry,symmetrize).
my_stems(tall,tallness).
my_stems(tame,tameness).
my_stems(tardy,tardiness).
my_stems(tedious,tediousness).
my_stems(teeming,teemingness).
my_stems(temporary,temporariness).
my_stems(tentacle,tentacular).
my_stems(thick,thickness).
my_stems(thin,thinness).
my_stems(tight,tightness).
my_stems(timely,timeliness).
my_stems(tiny,tininess).
my_stems(tiresome,tiresomeness).
my_stems(title,titulary).
my_stems(topography,topographic).
my_stems(topography,topographical).
my_stems(totipotent,totipotence).
my_stems(totipotent,totipotency).
my_stems(transient,transience).
my_stems(transient,transiency).
my_stems(transitory,transitoriness).
my_stems(trashy,trashiness).
my_stems(trenchant,trenchancy).
my_stems(triangular,triangularity).
my_stems(trivial,triviality).
my_stems(turnover,'turn over').
my_stems(unbounded,unboundedness).
my_stems(undesirable,undesirability).
my_stems(unfavorable,unfavorableness).
my_stems(unfavourable,unfavourableness).
my_stems(unfeasible,unfeasibility).
my_stems(unfit,unfitness).
my_stems(unhurried,unhurriedness).
my_stems(unimportant,unimportance).
my_stems(uninteresting,uninterestingness).
my_stems(unpersuasive,unpersuasiveness).
my_stems(unpointed,unpointedness).
my_stems(unproductive,unproductiveness).
my_stems(unprofitable,unprofitability).
my_stems(unprofitable,unprofitableness).
my_stems(unpropitious,unpropitiousness).
my_stems(unprotected,unprotectedness).
my_stems(unresponsive,unresponsiveness).
my_stems(unseasonable,unseasonableness).
my_stems(unsound,unsoundness).
my_stems(untimely,untimeliness).
my_stems(upright,uprightness).
my_stems(usable,usableness).
my_stems(useable,useableness).
my_stems(useableness,serviceable).
my_stems(useful,usefulness).
my_stems(useless,uselessness).
my_stems(usufruct,usufructuary).
my_stems(utility,utilitarian).
my_stems(valuable,valuableness).
my_stems(value,evaluate).
my_stems(valueless,valuelessness).
my_stems(vapid,vapidity).
my_stems(vapid,vapidness).
my_stems(vascular,vascularity).
my_stems(vast,vastness).
my_stems(verdant,verdancy).
my_stems(vertical,verticality).
my_stems(vertical,verticalness).
my_stems(viable,viability).
my_stems(virulent,virulence).
my_stems(virulent,virulency).
my_stems(vital,vitalness).
my_stems(vitalness,indispensable).
my_stems(vivid,vividness).
my_stems(voiceless,voicelessness).
my_stems(volume,voluminous).
my_stems(voluminous,voluminosity).
my_stems(voluminous,voluminousness).
my_stems(voluptuous,voluptuousness).
my_stems(vulnerable,vulnerability).
my_stems(watery,wateriness).
my_stems(wavy,waviness).
my_stems(waxy,waxiness).
my_stems(weak,weakness).
my_stems(wee,weeness).
my_stems(weight,weighty).
my_stems(weighty,weightiness).
my_stems(wide,wideness).
my_stems(wise,wiseness).
my_stems(woodsy,woodsiness).
my_stems(woody,woodiness).
my_stems(worth,worthy).
my_stems(worthless,worthlessness).
my_stems(worthwhile,worthwhileness).
*/

s_id(ID1,SN,W1,POS1):- s(ID1,SN,W1,POS1,_X1,_Y1).
s_id(ID1,W1,POS1):- s(ID1,1,W1,POS1,_X1,_Y1).

wdl1(W1,POS1,W2,POS2,ant):- ant(ID1,SN1,ID2,SN2),s_id(ID1,SN1,W1,POS1),s_id(ID2,SN2,W2,POS2).

wdl2(W1,POS1,W2,POS2,How):- wdl1(W1,POS1,W2,POS2,How).
wdl2(W1,POS1,W2,POS2,hyp):- hyp(ID2,ID1),s_id(ID1,W1,POS1),s_id(ID2,W2,POS2).
wdl2(W1,POS1,W2,POS2,Hypr):- (hypr==Hypr;nonvar(W2)),hyp(ID1,ID2),s_id(ID1,W1,POS1),s_id(ID2,W2,POS2).
wdl2(W1,POS1,W2,POS2,der):- der(ID1,SN1,ID2,SN2),s_id(ID1,SN1,W1,POS1),s_id(ID2,SN2,W2,POS2).

t1(W1,W2,POS,HOW):- no_repeats(W2,wdl(W1:v,W2:POS,[ant|HOW])),(atom_contains(W1,W2);atom_contains(W2,W1)).


t2(W1,W2,POS):- (var(W1),nonvar(W2)),!,t2(W2,W1,POS).
t2(W1,W2,POS1:POS2):- (var(W1),var(W2)),!,no_repeats(W2,wdl(W1:POS1,W2:POS2,[ant])),longer(W1,W2).
t2(W1,W2,POS):- t3(W1,W2,POS)*->true;(t4(W1,W3,POS),W3=W2).

t3(W1,W2,POS):- (nonvar(W1),nonvar(W2)),!,t2(W2,WM,_),t2(W1,WM,POS).
t3(W1,W2,POS1:POS2):- no_repeats(W2,wdl(W1:POS1,W2:POS2,[ant])),nop(word_overlap(W1,W2)).

t4(W1,W2,POS):- (nonvar(W1),nonvar(W2)),!,t2(W2,WM,_),t3(W1,WM,POS).
% t4(W1,W2,POS):- nonvar(W1),!,t3(W22,WM,_),t3(W1,WM,POS),W2=W22.
t4(W1,W2,POS1:POS2):- no_repeats(W2,wdl(W1:POS1,W2:POS2,_)),nop(word_overlap(W1,W2)).


wdl(W1:POS1,W2:POS2,[HOW1,HOW2]):- 
  dif(W1,W2),wdl2(W1,POS1,WM,POSM,HOW1),
  (HOW1==der->HOW2=ant;((HOW1==ant->dif(HOW2,ant);(HOW1==hyp->dif(HOW2,hyp);true)))),
  wdl2(WM,POSM,W2,POS2,HOW2).
wdl(W1:POS1,W2:POS2,[HOW]):- wdl2(W1,POS1,W2,POS2,HOW).
%wdl(W1:POS1,W2:POS2,[HOW1,HOW2]):- wdl1(W1,POS1,WM,POSM,HOW1),wdl1(WM,POSM,W2,POS2,HOW2).
%wdl(W1,POS1,W2,POS2,[HOW1,HOW2]):- wdl2(W1,POS1,WM,POSM,HOW),wdl1(WM,POSM,W2,POS2,HOW).
/*
ant,ant
der,ant
ant,hyp
*/
wn_face(vgp/4).
wn_face(syntax/3).
wn_face(sk/3).
wn_face(sim/2).
wn_face(sa/4).
wn_face(s/6).
wn_face(ppl/4).
wn_face(per/4).
wn_face(ms/2).
wn_face(mp/2).
wn_face(mm/2).
wn_face(ins/2).
wn_face(hyp/2).
wn_face(g/2).
wn_face(fr/3).
wn_face(ent/2).
wn_face(der/4).
wn_face(cs/2).
wn_face(cls/5).
wn_face(at/2).
wn_face(ant/4).

xl(ID1):- xlisting(ID1),forall(s_id(ID1,SN,W1,POS1),dmsg(s_id(ID1,SN,W1,POS1))),forall(g(ID1,Info),dmsg(g(ID1,Info))).


opposite(n,artifact,'natural object',_80064).
opposite(n,overachievement,underachievement,_80064).
opposite(n,appearance,disappearance,_80064).
opposite(n,retreat,advance,_80064).
opposite(n,embarkation,disembarkation,_80064).
opposite(n,passing,failing,_80064).
opposite(n,'put option','call option',_80064).
opposite(n,best,worst,_80064).
opposite(n,'foul ball','fair ball',_80064).
opposite(n,loosening,tightening,_80064).
opposite(n,monetization,demonetization,_80064).
opposite(n,'split ticket','straight ticket',_80064).
opposite(n,'earned run','unearned run',_80064).
opposite(n,demotion,promotion,_80064).
opposite(n,stillbirth,'live birth',_80064).
opposite(n,start,finish,_80064).
opposite(n,activation,deactivation,_80064).
opposite(n,contamination,decontamination,_80064).
opposite(n,'rising trot','sitting trot',_80064).
opposite(n,'domestic flight','international flight',_80064).
opposite(n,deceleration,acceleration,_80064).
opposite(n,opening,closing,_80064).
opposite(n,pronation,supination,_80064).
opposite(n,minimization,maximization,_80064).
opposite(n,compression,decompression,_80064).
opposite(n,weakening,strengthening,_80064).
opposite(n,dilution,concentration,_80064).
opposite(n,increase,decrease,_80064).
opposite(n,addition,subtraction,_80064).
opposite(n,depreciation,appreciation,_80064).
opposite(n,expansion,contraction,_80064).
opposite(n,inflation,deflation,_80064).
opposite(n,union,disunion,_80064).
opposite(n,tribalization,detribalization,_80064).
opposite(n,tribalisation,detribalisation,_80064).
opposite(n,flexion,extension,_80064).
opposite(n,widening,narrowing,_80064).
opposite(n,activity,inactivity,_80064).
opposite(n,'day game','night game',_80064).
opposite(n,'home game','away game',_80064).
opposite(n,softball,hardball,_80064).
opposite(n,volley,'ground stroke',_80064).
opposite(n,'minor surgery','major surgery',_80064).
opposite(n,allopathy,homeopathy,_80064).
opposite(n,loading,unloading,_80064).
opposite(n,'actual sin','original sin',_80064).
opposite(n,'venial sin','mortal sin',_80064).
opposite(n,'petit larceny','grand larceny',_80064).
opposite(n,hypopnea,hyperpnea,_80064).
opposite(n,'assortative mating','disassortative mating',_80064).
opposite(n,assembly,disassembly,_80064).
opposite(n,continuance,discontinuance,_80064).
opposite(n,continuation,discontinuation,_80064).
opposite(n,uptick,downtick,_80064).
opposite(n,retail,wholesale,_80064).
opposite(n,payment,nonpayment,_80064).
opposite(n,criminalization,decriminalization,_80064).
opposite(n,criminalisation,decriminalisation,_80064).
opposite(n,enfranchisement,disenfranchisement,_20).
opposite(n,classification,declassification,_20).
opposite(n,nationalization,denationalization,_20).
opposite(n,mobilization,demobilization,_20).
opposite(n,arming,disarming,_20).
opposite(n,armament,disarmament,_20).
opposite(n,stabilization,destabilization,_20).
opposite(n,stabilisation,destabilisation,_20).
opposite(n,obedience,disobedience,_20).
opposite(n,reversal,affirmation,_20).
opposite(n,'judgment in rem','judgment in personam',_20).
opposite(n,'special verdict','general verdict',_20).
opposite(n,acquittal,conviction,_20).
opposite(n,defense,prosecution,_20).
opposite(n,segregation,integration,_20).
opposite(n,cooperation,competition,_20).
opposite(n,conformity,nonconformity,_20).
opposite(n,compliance,noncompliance,_20).
opposite(n,observance,nonobservance,_20).
opposite(n,service,disservice,_20).
opposite(n,approval,disapproval,_20).
opposite(n,attendance,nonattendance,_20).
opposite(n,absence,presence,_20).
opposite(n,centralization,decentralization,_20).
opposite(n,engagement,'non-engagement',_20).
opposite(n,participation,nonparticipation,_20).
opposite(n,involvement,'non-involvement',_20).
opposite(n,male,female,_20).
opposite(n,host,parasite,_20).
opposite(n,eukaryote,prokaryote,_20).
opposite(n,'soft-finned fish','spiny-finned fish',_20).
opposite(n,ratite,carinate,_20).
opposite(n,diapsid,anapsid,_20).
opposite(n,'diving duck','dabbling duck',_20).
opposite(n,'zygodactyl foot','heterodactyl foot',_20).
opposite(n,'odd-toed ungulate','even-toed ungulate',_20).
opposite(n,'homocercal fin','heterocercal fin',_20).
opposite(n,'plantigrade mammal','digitigrade mammal',_20).
opposite(n,anode,cathode,_20).
opposite(n,infield,outfield,_20).
opposite(n,'low relief','high relief',_20).
opposite(n,'dedicated file server','non-dedicated file server',_20).
opposite(n,'dumb bomb','smart bomb',_20).
opposite(n,'fast reactor','thermal reactor',_20).
opposite(n,'generic drug','brand-name drug',_20).
opposite(n,'hand mower','power mower',_20).
opposite(n,import,export,_20).
opposite(n,'in-basket','out-basket',_20).
opposite(n,larboard,starboard,_20).
opposite(n,local,express,_20).
opposite(n,mobile,stabile,_20).
opposite(n,'open circuit','closed circuit',_20).
opposite(n,overgarment,undergarment,_20).
opposite(n,'prescription drug','over-the-counter drug',_20).
opposite(n,'prescription medicine','over-the-counter medicine',_20).
opposite(n,'ready-made','custom-made',_20).
opposite(n,rear,front,_20).
opposite(n,reverse,obverse,_20).
opposite(n,rotor,stator,_20).
opposite(n,'slow lane','fast lane',_20).
opposite(n,'soft drug','hard drug',_20).
opposite(n,studio,location,_20).
opposite(n,submersible,'surface ship',_20).
opposite(n,synergist,antagonist,_20).
opposite(n,tail,head,_20).
opposite(n,'taper file','blunt file',_20).
opposite(n,'volatile storage','non-volatile storage',_20).
opposite(n,'volatile storage','nonvolatile storage',_20).
opposite(n,'voltaic cell','electrolytic cell',_20).
opposite(n,'wet-bulb thermometer','dry-bulb thermometer',_20).
opposite(n,'wet fly','dry fly',_20).
opposite(n,white,black,_20).
opposite(n,inwardness,outwardness,_20).
opposite(n,worldliness,otherworldliness,_20).
opposite(n,introversion,extraversion,_20).
opposite(n,emotionality,unemotionality,_20).
opposite(n,cheerfulness,uncheerfulness,_20).
opposite(n,activeness,inactiveness,_20).
opposite(n,permissiveness,unpermissiveness,_20).
opposite(n,patience,impatience,_20).
opposite(n,agreeableness,disagreeableness,_20).
opposite(n,'ill nature','good nature',_20).
opposite(n,willingness,unwillingness,_20).
opposite(n,frivolity,seriousness,_20).
opposite(n,communicativeness,uncommunicativeness,_20).
opposite(n,sociability,unsociability,_20).
opposite(n,openness,closeness,_20).
opposite(n,friendliness,unfriendliness,_20).
opposite(n,approachability,unapproachability,_20).
opposite(n,congeniality,uncongeniality,_20).
opposite(n,neighborliness,unneighborliness,_20).
opposite(n,hospitableness,inhospitableness,_20).
opposite(n,adaptability,unadaptability,_20).
opposite(n,flexibility,inflexibility,_20).
opposite(n,thoughtfulness,unthoughtfulness,_20).
opposite(n,attentiveness,inattentiveness,_20).
opposite(n,carefulness,carelessness,_20).
opposite(n,mindfulness,unmindfulness,_20).
opposite(n,heedfulness,heedlessness,_20).
opposite(n,caution,incaution,_20).
opposite(n,wariness,unwariness,_20).
opposite(n,femininity,masculinity,_20).
opposite(n,trustworthiness,untrustworthiness,_20).
opposite(n,trustiness,untrustiness,_20).
opposite(n,responsibility,irresponsibility,_20).
opposite(n,responsibleness,irresponsibleness,_20).
opposite(n,dependability,undependability,_20).
opposite(n,dependableness,undependableness,_20).
opposite(n,reliability,unreliability,_20).
opposite(n,reliableness,unreliableness,_20).
opposite(n,conscientiousness,unconscientiousness,_20).
opposite(n,hairiness,hairlessness,_20).
opposite(n,beauty,ugliness,_20).
opposite(n,pleasingness,unpleasingness,_20).
opposite(n,attractiveness,unattractiveness,_20).
opposite(n,distinctness,indistinctness,_20).
opposite(n,opacity,clarity,_20).
opposite(n,softness,sharpness,_20).
opposite(n,acuteness,obtuseness,_20).
opposite(n,conspicuousness,inconspicuousness,_20).
opposite(n,obtrusiveness,unobtrusiveness,_20).
opposite(n,ease,difficulty,_20).
opposite(n,effortfulness,effortlessness,_20).
opposite(n,compatibility,incompatibility,_20).
opposite(n,congruity,incongruity,_20).
opposite(n,congruousness,incongruousness,_20).
opposite(n,suitability,unsuitability,_20).
opposite(n,suitableness,unsuitableness,_20).
opposite(n,appropriateness,inappropriateness,_20).
opposite(n,felicity,infelicity,_20).
opposite(n,aptness,inaptness,_20).
opposite(n,appositeness,inappositeness,_20).
opposite(n,fitness,unfitness,_20).
opposite(n,eligibility,ineligibility,_20).
opposite(n,insurability,uninsurability,_20).
opposite(n,convenience,inconvenience,_20).
opposite(n,opportuneness,inopportuneness,_20).
opposite(n,accessibility,inaccessibility,_20).
opposite(n,availability,unavailability,_20).
opposite(n,superiority,inferiority,_20).
opposite(n,'low quality','high quality',_20).
opposite(n,reversibility,irreversibility,_20).
opposite(n,variability,invariability,_20).
opposite(n,variableness,invariableness,_20).
opposite(n,variedness,unvariedness,_20).
opposite(n,exchangeability,unexchangeability,_20).
opposite(n,convertibility,inconvertibility,_20).
opposite(n,changelessness,changeableness,_20).
opposite(n,constancy,inconstancy,_20).
opposite(n,mutability,immutability,_20).
opposite(n,mutableness,immutableness,_20).
opposite(n,alterability,unalterability,_20).
opposite(n,sameness,difference,_20).
opposite(n,similarity,dissimilarity,_20).
opposite(n,likeness,unlikeness,_20).
opposite(n,similitude,dissimilitude,_20).
opposite(n,uniformity,nonuniformity,_20).
opposite(n,homogeneity,heterogeneity,_20).
opposite(n,consistency,inconsistency,_20).
opposite(n,equality,inequality,_20).
opposite(n,equivalence,nonequivalence,_20).
opposite(n,evenness,unevenness,_20).
opposite(n,certainty,uncertainty,_20).
opposite(n,conclusiveness,inconclusiveness,_20).
opposite(n,predictability,unpredictability,_20).
opposite(n,probability,improbability,_20).
opposite(n,likelihood,unlikelihood,_20).
opposite(n,likeliness,unlikeliness,_20).
opposite(n,factuality,counterfactuality,_20).
opposite(n,concreteness,abstractness,_20).
opposite(n,tangibility,intangibility,_20).
opposite(n,palpability,impalpability,_20).
opposite(n,materiality,immateriality,_20).
opposite(n,corporeality,incorporeality,_20).
opposite(n,substantiality,insubstantiality,_20).
opposite(n,reality,unreality,_20).
opposite(n,generality,particularity,_20).
opposite(n,commonality,individuality,_20).
opposite(n,simplicity,complexity,_20).
opposite(n,regularity,irregularity,_20).
opposite(n,steadiness,unsteadiness,_20).
opposite(n,mobility,immobility,_20).
opposite(n,motility,immotility,_20).
opposite(n,movability,immovability,_20).
opposite(n,movableness,immovableness,_20).
opposite(n,tightness,looseness,_20).
opposite(n,looseness,fixedness,_20).
opposite(n,stability,instability,_20).
opposite(n,stableness,unstableness,_20).
opposite(n,pleasantness,unpleasantness,_20).
opposite(n,niceness,nastiness,_20).
opposite(n,credibility,incredibility,_20).
opposite(n,plausibility,implausibility,_20).
opposite(n,logicality,illogicality,_20).
opposite(n,logicalness,illogicalness,_20).
opposite(n,naturalness,unnaturalness,_20).
opposite(n,affectedness,unaffectedness,_20).
opposite(n,pretentiousness,unpretentiousness,_20).
opposite(n,wholesomeness,unwholesomeness,_20).
opposite(n,healthfulness,unhealthfulness,_20).
opposite(n,salubrity,insalubrity,_20).
opposite(n,salubriousness,insalubriousness,_20).
opposite(n,satisfactoriness,unsatisfactoriness,_20).
opposite(n,adequacy,inadequacy,_20).
opposite(n,acceptability,unacceptability,_20).
opposite(n,admissibility,inadmissibility,_20).
opposite(n,permissibility,impermissibility,_20).
opposite(n,ordinariness,extraordinariness,_20).
opposite(n,expectedness,unexpectedness,_20).
opposite(n,commonness,uncommonness,_20).
opposite(n,usualness,unusualness,_20).
opposite(n,familiarity,unfamiliarity,_20).
opposite(n,nativeness,foreignness,_20).
opposite(n,originality,unoriginality,_20).
opposite(n,orthodoxy,unorthodoxy,_20).
opposite(n,conventionality,unconventionality,_20).
opposite(n,correctness,incorrectness,_20).
opposite(n,wrongness,rightness,_20).
opposite(n,accuracy,inaccuracy,_20).
opposite(n,exactness,inexactness,_20).
opposite(n,preciseness,impreciseness,_20).
opposite(n,precision,imprecision,_20).
opposite(n,errancy,inerrancy,_20).
opposite(n,fallibility,infallibility,_20).
opposite(n,worthiness,unworthiness,_20).
opposite(n,popularity,unpopularity,_20).
opposite(n,legality,illegality,_20).
opposite(n,lawfulness,unlawfulness,_20).
opposite(n,legitimacy,illegitimacy,_20).
opposite(n,licitness,illicitness,_20).
opposite(n,elegance,inelegance,_20).
opposite(n,tastefulness,tastelessness,_20).
opposite(n,urbanity,rusticity,_20).
opposite(n,comprehensibility,incomprehensibility,_20).
opposite(n,legibility,illegibility,_20).
opposite(n,intelligibility,unintelligibility,_20).
opposite(n,clarity,obscurity,_20).
opposite(n,clearness,unclearness,_20).
opposite(n,explicitness,inexplicitness,_20).
opposite(n,ambiguity,unambiguity,_20).
opposite(n,equivocalness,unequivocalness,_20).
opposite(n,polysemy,monosemy,_20).
opposite(n,righteousness,unrighteousness,_20).
opposite(n,piety,impiety,_20).
opposite(n,godliness,ungodliness,_20).
opposite(n,humaneness,inhumaneness,_20).
opposite(n,mercifulness,mercilessness,_20).
opposite(n,liberality,illiberality,_20).
opposite(n,stinginess,generosity,_20).
opposite(n,selfishness,unselfishness,_20).
opposite(n,egoism,altruism,_20).
opposite(n,fairness,unfairness,_20).
opposite(n,equity,inequity,_20).
opposite(n,kindness,unkindness,_20).
opposite(n,consideration,inconsideration,_20).
opposite(n,thoughtfulness,thoughtlessness,_20).
opposite(n,tactfulness,tactlessness,_20).
opposite(n,malignity,benignity,_20).
opposite(n,malignancy,benignancy,_20).
opposite(n,sensitivity,insensitivity,_20).
opposite(n,sensitiveness,insensitiveness,_20).
opposite(n,perceptiveness,unperceptiveness,_20).
opposite(n,maleficence,beneficence,_20).
opposite(n,morality,immorality,_20).
opposite(n,good,evil,_20).
opposite(n,goodness,evilness,_20).
opposite(n,justice,injustice,_20).
opposite(n,corruptibility,incorruptibility,_20).
opposite(n,corruptness,incorruptness,_20).
opposite(n,wrong,right,_20).
opposite(n,wrongfulness,rightfulness,_20).
opposite(n,holiness,unholiness,_20).
opposite(n,safeness,dangerousness,_20).
opposite(n,curability,incurability,_20).
opposite(n,curableness,incurableness,_20).
opposite(n,courage,cowardice,_20).
opposite(n,stoutheartedness,faintheartedness,_20).
opposite(n,gutsiness,gutlessness,_20).
opposite(n,fearfulness,fearlessness,_20).
opposite(n,timidity,boldness,_20).
opposite(n,resoluteness,irresoluteness,_20).
opposite(n,decisiveness,indecisiveness,_20).
opposite(n,decision,indecision,_20).
opposite(n,sincerity,insincerity,_20).
opposite(n,honorableness,dishonorableness,_20).
opposite(n,honor,dishonor,_20).
opposite(n,scrupulousness,unscrupulousness,_20).
opposite(n,respectability,unrespectability,_20).
opposite(n,reputability,disreputability,_20).
opposite(n,honesty,dishonesty,_20).
opposite(n,truthfulness,untruthfulness,_20).
opposite(n,veracity,mendacity,_20).
opposite(n,ingenuousness,disingenuousness,_20).
opposite(n,artfulness,artlessness,_20).
opposite(n,fidelity,infidelity,_20).
opposite(n,faithfulness,unfaithfulness,_20).
opposite(n,loyalty,disloyalty,_20).
opposite(n,naivete,sophistication,_20).
opposite(n,discipline,indiscipline,_20).
opposite(n,restraint,unrestraint,_20).
opposite(n,temperance,intemperance,_20).
opposite(n,conceit,humility,_20).
opposite(n,folly,wisdom,_20).
opposite(n,prudence,imprudence,_20).
opposite(n,providence,improvidence,_20).
opposite(n,trust,distrust,_20).
opposite(n,cleanliness,uncleanliness,_20).
opposite(n,tidiness,untidiness,_20).
opposite(n,propriety,impropriety,_20).
opposite(n,properness,improperness,_20).
opposite(n,decorum,indecorum,_20).
opposite(n,decorousness,indecorousness,_20).
opposite(n,'political correctness','political incorrectness',_20).
opposite(n,seemliness,unseemliness,_20).
opposite(n,becomingness,unbecomingness,_20).
opposite(n,decency,indecency,_20).
opposite(n,modesty,immodesty,_20).
opposite(n,composure,discomposure,_20).
opposite(n,tractability,intractability,_20).
opposite(n,subordination,insubordination,_20).
opposite(n,wildness,tameness,_20).
opposite(n,formality,informality,_20).
opposite(n,ceremoniousness,unceremoniousness,_20).
opposite(n,courtesy,discourtesy,_20).
opposite(n,politeness,impoliteness,_20).
opposite(n,graciousness,ungraciousness,_20).
opposite(n,civility,incivility,_20).
opposite(n,isotropy,anisotropy,_20).
opposite(n,directness,indirectness,_20).
opposite(n,mediacy,immediacy,_20).
opposite(n,oldness,newness,_20).
opposite(n,oldness,youngness,_20).
opposite(n,staleness,freshness,_20).
opposite(n,'reduced instruction set computing','complex instruction set computing',_20).
opposite(n,'reduced instruction set computer','complex instruction set computer',_20).
opposite(n,'RISC','CISC',_20).
opposite(n,thinness,thickness,_20).
opposite(n,softness,hardness,_20).
opposite(n,compressibility,incompressibility,_20).
opposite(n,breakableness,unbreakableness,_20).
opposite(n,permeability,impermeability,_20).
opposite(n,penetrability,impenetrability,_20).
opposite(n,perviousness,imperviousness,_20).
opposite(n,absorbency,nonabsorbency,_20).
opposite(n,solidity,porosity,_20).
opposite(n,roughness,smoothness,_20).
opposite(n,dullness,brightness,_20).
opposite(n,color,colorlessness,_20).
opposite(n,'chromatic color','achromatic color',_20).
opposite(n,pigmentation,depigmentation,_20).
opposite(n,darkness,lightness,_20).
opposite(n,sound,silence,_20).
opposite(n,harmony,dissonance,_20).
opposite(n,'low pitch','high pitch',_20).
opposite(n,softness,loudness,_20).
opposite(n,palatability,unpalatability,_20).
opposite(n,appetizingness,unappetizingness,_20).
opposite(n,digestibility,indigestibility,_20).
opposite(n,fatness,leanness,_20).
opposite(n,tallness,shortness,_20).
opposite(n,awkwardness,gracefulness,_20).
opposite(n,animateness,inanimateness,_20).
opposite(n,sentience,insentience,_20).
opposite(n,maleness,femaleness,_20).
opposite(n,hotness,coldness,_20).
opposite(n,perceptibility,imperceptibility,_20).
opposite(n,visibility,invisibility,_20).
opposite(n,audibility,inaudibility,_20).
opposite(n,elasticity,inelasticity,_20).
opposite(n,malleability,unmalleability,_20).
opposite(n,lightness,heaviness,_20).
opposite(n,soundness,unsoundness,_20).
opposite(n,acidity,alkalinity,_20).
opposite(n,weakness,strength,_20).
opposite(n,'weak part','good part',_20).
opposite(n,vulnerability,invulnerability,_20).
opposite(n,destructibility,indestructibility,_20).
opposite(n,lateness,earliness,_20).
opposite(n,priority,posteriority,_20).
opposite(n,tardiness,punctuality,_20).
opposite(n,seasonableness,unseasonableness,_20).
opposite(n,timeliness,untimeliness,_20).
opposite(n,pastness,presentness,_20).
opposite(n,pastness,futurity,_20).
opposite(n,permanence,impermanence,_20).
opposite(n,mortality,immortality,_20).
opposite(n,symmetry,asymmetry,_20).
opposite(n,'radial symmetry','radial asymmetry',_20).
opposite(n,abruptness,gradualness,_20).
opposite(n,pointedness,unpointedness,_20).
opposite(n,roundness,angularity,_20).
opposite(n,eccentricity,concentricity,_20).
opposite(n,crookedness,straightness,_20).
opposite(n,centrality,marginality,_20).
opposite(n,southernness,northernness,_20).
opposite(n,farness,nearness,_20).
opposite(n,profundity,superficiality,_20).
opposite(n,low,high,_20).
opposite(n,bigness,littleness,_20).
opposite(n,smallness,largeness,_20).
opposite(n,positivity,negativity,_20).
opposite(n,positiveness,negativeness,_20).
opposite(n,sufficiency,insufficiency,_20).
opposite(n,scarcity,abundance,_20).
opposite(n,moderation,immoderation,_20).
opposite(n,minority,majority,_20).
opposite(n,deepness,shallowness,_20).
opposite(n,wideness,narrowness,_20).
opposite(n,lowness,highness,_20).
opposite(n,worth,worthlessness,_20).
opposite(n,merit,demerit,_20).
opposite(n,desirability,undesirability,_20).
opposite(n,reward,penalty,_20).
opposite(n,expensiveness,inexpensiveness,_20).
opposite(n,fruitfulness,fruitlessness,_20).
opposite(n,productiveness,unproductiveness,_20).
opposite(n,utility,inutility,_20).
opposite(n,usefulness,uselessness,_20).
opposite(n,practicality,impracticality,_20).
opposite(n,practicability,impracticability,_20).
opposite(n,practicableness,impracticableness,_20).
opposite(n,feasibility,infeasibility,_20).
opposite(n,competence,incompetence,_20).
opposite(n,asset,liability,_20).
opposite(n,advantage,disadvantage,_20).
opposite(n,profitableness,unprofitableness,_20).
opposite(n,profitability,unprofitability,_20).
opposite(n,expedience,inexpedience,_20).
opposite(n,expediency,inexpediency,_20).
opposite(n,'weak point','strong point',_20).
opposite(n,advisability,inadvisability,_20).
opposite(n,favorableness,unfavorableness,_20).
opposite(n,auspiciousness,inauspiciousness,_20).
opposite(n,propitiousness,unpropitiousness,_20).
opposite(n,destructiveness,constructiveness,_20).
opposite(n,importance,unimportance,_20).
opposite(n,significance,insignificance,_20).
opposite(n,meaningfulness,meaninglessness,_20).
opposite(n,purposefulness,purposelessness,_20).
opposite(n,consequence,inconsequence,_20).
opposite(n,essentiality,inessentiality,_20).
opposite(n,dispensability,indispensability,_20).
opposite(n,dispensableness,indispensableness,_20).
opposite(n,power,powerlessness,_20).
opposite(n,persuasiveness,unpersuasiveness,_20).
opposite(n,interestingness,uninterestingness,_20).
opposite(n,effectiveness,ineffectiveness,_20).
opposite(n,efficacy,inefficacy,_20).
opposite(n,ability,inability,_20).
opposite(n,capability,incapability,_20).
opposite(n,capableness,incapableness,_20).
opposite(n,capacity,incapacity,_20).
opposite(n,finiteness,infiniteness,_20).
opposite(n,solubility,insolubility,_20).
opposite(n,optimism,pessimism,_20).
opposite(n,responsiveness,unresponsiveness,_20).
opposite(n,solvability,unsolvability,_20).
opposite(n,flexor,extensor,_20).
opposite(n,receptor,effector,_20).
opposite(n,cortex,medulla,_20).
opposite(n,judiciousness,injudiciousness,_20).
opposite(n,aptitude,inaptitude,_20).
opposite(n,perfectibility,imperfectibility,_20).
opposite(n,creativeness,uncreativeness,_20).
opposite(n,'Hell','Heaven',_20).
opposite(n,literacy,illiteracy,_20).
opposite(n,skillfulness,unskillfulness,_20).
opposite(n,coordination,incoordination,_20).
opposite(n,fluency,disfluency,_20).
opposite(n,efficiency,inefficiency,_20).
opposite(n,stupidity,intelligence,_20).
opposite(n,kinesthesia,kinanesthesia,_20).
opposite(n,'merit system','spoils system',_20).
opposite(n,consciousness,unconsciousness,_20).
opposite(n,cognizance,incognizance,_20).
opposite(n,'self-consciousness',unselfconsciousness,_20).
opposite(n,sensibility,insensibility,_20).
opposite(n,waking,sleeping,_20).
opposite(n,attention,inattention,_20).
opposite(n,experience,inexperience,_20).
opposite(n,analysis,synthesis,_20).
opposite(n,'divergent thinking','convergent thinking',_20).
opposite(n,comprehension,incomprehension,_20).
opposite(n,general,particular,_20).
opposite(n,general,specific,_20).
opposite(n,conception,misconception,_20).
opposite(n,type,antitype,_20).
opposite(n,divergence,convergence,_20).
opposite(n,divergency,convergency,_20).
opposite(n,middle,beginning,_20).
opposite(n,'reality principle','pleasure principle',_20).
opposite(n,yin,yang,_20).
opposite(n,ground,figure,_20).
opposite(n,belief,unbelief,_20).
opposite(n,apophatism,cataphatism,_20).
opposite(n,apophatism,'doctrine of analogy',_20).
opposite(n,imitation,formalism,_20).
opposite(n,monism,pluralism,_20).
opposite(n,nationalism,multiculturalism,_20).
opposite(n,nationalism,internationalism,_20).
opposite(n,hereditarianism,environmentalism,_20).
opposite(n,enlightenment,unenlightenment,_20).
opposite(n,'open interval','closed interval',_20).
opposite(n,eugenics,dysgenics,_20).
opposite(n,holism,atomism,_20).
opposite(n,'wave theory','corpuscular theory',_20).
opposite(n,'wave theory of light','corpuscular theory of light',_20).
opposite(n,classicism,'Romanticism',_20).
opposite(n,'descriptive linguistics','prescriptive linguistics',_20).
opposite(n,'Arianism','Athanasianism',_20).
opposite(n,partiality,impartiality,_20).
opposite(n,tolerance,intolerance,_20).
opposite(n,'broad-mindedness','narrow-mindedness',_20).
opposite(n,respect,disrespect,_20).
opposite(n,reverence,irreverence,_20).
opposite(n,conformism,nonconformism,_20).
opposite(n,dovishness,hawkishness,_20).
opposite(n,theism,atheism,_20).
opposite(n,polytheism,monotheism,_20).
opposite(n,verso,recto,_20).
opposite(n,'snail mail','electronic mail',_20).
opposite(n,plural,singular,_20).
opposite(n,synonym,antonym,_20).
opposite(n,oblique,nominative,_20).
opposite(n,construction,misconstruction,_20).
opposite(n,'proper noun','common noun',_20).
opposite(n,flashback,'flash-forward',_20).
opposite(n,'text edition','trade edition',_20).
opposite(n,software,hardware,_20).
opposite(n,'source program','object program',_20).
opposite(n,euphemism,dysphemism,_20).
opposite(n,'air mail','surface mail',_20).
opposite(n,hospitality,inhospitality,_20).
opposite(n,pro,con,_20).
opposite(n,intervention,nonintervention,_20).
opposite(n,interference,noninterference,_20).
opposite(n,approbation,disapprobation,_20).
opposite(n,encouragement,discouragement,_20).
opposite(n,truth,falsehood,_20).
opposite(n,'direct evidence','circumstantial evidence',_20).
opposite(n,'universal proposition','particular proposition',_20).
opposite(n,categorem,syncategorem,_20).
opposite(n,categoreme,syncategoreme,_20).
opposite(n,overstatement,understatement,_20).
opposite(n,indication,contraindication,_20).
opposite(n,'Roman numeral','Arabic numeral',_20).
opposite(n,subscript,superscript,_20).
opposite(n,uppercase,lowercase,_20).
opposite(n,'fixed-width font','proportional font',_20).
opposite(n,modern,'old style',_20).
opposite(n,tonality,atonality,_20).
opposite(n,'one-dimensional language','multidimensional language',_20).
opposite(n,'stratified language','unstratified language',_20).
opposite(n,'natural language','artificial language',_20).
opposite(n,comedy,tragedy,_20).
opposite(n,polyphony,monophony,_20).
opposite(n,'polyphonic music','monophonic music',_20).
opposite(n,resolution,preparation,_20).
opposite(n,diminution,augmentation,_20).
opposite(n,terseness,verboseness,_20).
opposite(n,vowel,consonant,_20).
opposite(n,'stop consonant','continuant consonant',_20).
opposite(n,'direct discourse','indirect discourse',_20).
opposite(n,agreement,disagreement,_20).
opposite(n,answer,question,_20).
opposite(n,yea,nay,_20).
opposite(n,negative,affirmative,_20).
opposite(n,no,yes,_20).
opposite(n,persuasion,dissuasion,_20).
opposite(n,embarrassment,disembarrassment,_20).
opposite(n,success,failure,_20).
opposite(n,egress,ingress,_20).
opposite(n,emersion,immersion,_20).
opposite(n,rise,fall,_20).
opposite(n,death,birth,_20).
opposite(n,levitation,gravitation,_20).
opposite(n,'low tide','high tide',_20).
opposite(n,ebbtide,'flood tide',_20).
opposite(n,'neap tide',springtide,_20).
opposite(n,waxing,waning,_20).
opposite(n,'self-fertilization','cross-fertilization',_20).
opposite(n,autogamy,allogamy,_20).
opposite(n,'self-pollination','cross-pollination',_20).
opposite(n,levorotation,dextrorotation,_20).
opposite(n,defeat,victory,_20).
opposite(n,aphrodisia,anaphrodisia,_20).
opposite(n,pain,pleasure,_20).
opposite(n,liking,dislike,_20).
opposite(n,inclination,disinclination,_20).
opposite(n,'Anglophobia','Anglophilia',_20).
opposite(n,gratitude,ingratitude,_20).
opposite(n,concern,unconcern,_20).
opposite(n,levity,gravity,_20).
opposite(n,calmness,agitation,_20).
opposite(n,diffidence,confidence,_20).
opposite(n,joy,sorrow,_20).
opposite(n,euphoria,dysphoria,_20).
opposite(n,cheerfulness,cheerlessness,_20).
opposite(n,contentment,discontentment,_20).
opposite(n,satisfaction,dissatisfaction,_20).
opposite(n,sadness,happiness,_20).
opposite(n,hope,despair,_20).
opposite(n,hopefulness,hopelessness,_20).
opposite(n,love,hate,_20).
opposite(n,misogyny,philogyny,_20).
opposite(n,malevolence,benevolence,_20).
opposite(n,'ill humor','good humor',_20).
opposite(n,'eating apple','cooking apple',_20).
opposite(n,'skim milk','whole milk',_20).
opposite(n,generic,varietal,_20).
opposite(n,'generic wine','varietal wine',_20).
opposite(n,aged,young,_20).
opposite(n,timid,brave,_20).
opposite(n,dead,living,_20).
opposite(n,initiate,uninitiate,_20).
opposite(n,offence,defence,_20).
opposite(n,laity,clergy,_20).
opposite(n,'rich people','poor people',_20).
opposite(n,rich,poor,_20).
opposite(n,'singular matrix','nonsingular matrix',_20).
opposite(n,alignment,nonalignment,_20).
opposite(n,'market economy','non-market economy',_20).
opposite(n,socialism,capitalism,_20).
opposite(n,hostile,friendly,_20).
opposite(n,'day school','boarding school',_20).
opposite(n,'day school','night school',_20).
opposite(n,flora,fauna,_20).
opposite(n,'civil law','international law',_20).
opposite(n,here,there,_20).
opposite(n,apex,antapex,_20).
opposite(n,apogee,perigee,_20).
opposite(n,apoapsis,periapsis,_20).
opposite(n,'point of apoapsis','point of periapsis',_20).
opposite(n,aphelion,perihelion,_20).
opposite(n,apojove,perijove,_20).
opposite(n,aposelene,periselene,_20).
opposite(n,apolune,perilune,_20).
opposite(n,'ascending node','descending node',_20).
opposite(n,node,antinode,_20).
opposite(n,inside,outside,_20).
opposite(n,leeward,windward,_20).
opposite(n,minimum,maximum,_20).
opposite(n,nadir,zenith,_20).
opposite(n,head,foot,_20).
opposite(n,'urban area','rural area',_20).
opposite(n,'free state','slave state',_20).
opposite(n,incentive,disincentive,_20).
opposite(n,adience,abience,_20).
opposite(n,ascent,descent,_20).
opposite(n,tributary,distributary,_20).
opposite(n,'high sea','territorial waters',_20).
opposite(n,lowland,highland,_20).
opposite(n,'natural elevation','natural depression',_20).
opposite(n,essential,inessential,_20).
opposite(n,'open chain','closed chain',_20).
opposite(n,'territorial waters','international waters',_20).
opposite(n,eudemon,cacodemon,_20).
opposite(n,adult,juvenile,_20).
opposite(n,captor,liberator,_20).
opposite(n,leader,follower,_20).
opposite(n,'religious person','nonreligious person',_20).
opposite(n,worker,nonworker,_20).
opposite(n,amateur,professional,_20).
opposite(n,ancestor,descendant,_20).
opposite(n,aunt,uncle,_20).
opposite(n,'bad egg','good egg',_20).
opposite(n,'bad guy','good guy',_20).
opposite(n,'bad person','good person',_20).
opposite(n,bull,bear,_20).
opposite(n,child,parent,_20).
opposite(n,citizen,noncitizen,_20).
opposite(n,civilian,serviceman,_20).
opposite(n,classicist,romanticist,_20).
opposite(n,conformist,nonconformist,_20).
opposite(n,'Anglican','Nonconformist',_20).
opposite(n,debtor,creditor,_20).
opposite(n,draftee,volunteer,_20).
opposite(n,drinker,nondrinker,_20).
opposite(n,driver,nondriver,_20).
opposite(n,elitist,egalitarian,_20).
opposite(n,'emotional person','unemotional person',_20).
opposite(n,employer,employee,_20).
opposite(n,'male parent','female parent',_20).
opposite(n,'fat person','thin person',_20).
opposite(n,foe,friend,_20).
opposite(n,granter,withholder,_20).
opposite(n,hawk,dove,_20).
opposite(n,'heir apparent','heir presumptive',_20).
opposite(n,inpatient,outpatient,_20).
opposite(n,introvert,extrovert,_20).
opposite(n,king,queen,_20).
opposite(n,'male monarch','female monarch',_20).
opposite(n,layman,clergyman,_20).
opposite(n,'lay witness','expert witness',_20).
opposite(n,lender,borrower,_20).
opposite(n,liar,'square shooter',_20).
opposite(n,liberal,conservative,_20).
opposite(n,libertarian,necessitarian,_20).
opposite(n,'liveborn infant','stillborn infant',_20).
opposite(n,'Lord','Lady',_20).
opposite(n,nobleman,noblewoman,_20).
opposite(n,loser,winner,_20).
opposite(n,loser,achiever,_20).
opposite(n,lumper,splitter,_20).
opposite(n,'male aristocrat','female aristocrat',_20).
opposite(n,'male child','female child',_20).
opposite(n,boy,girl,_20).
opposite(n,'male offspring','female offspring',_20).
opposite(n,'male sibling','female sibling',_20).
opposite(n,man,woman,_20).
opposite(n,member,nonmember,_20).
opposite(n,mother,father,_20).
opposite(n,niece,nephew,_20).
opposite(n,optimist,pessimist,_20).
opposite(n,partisan,nonpartisan,_20).
opposite(n,plaintiff,defendant,_20).
opposite(n,eremite,cenobite,_20).
opposite(n,resident,nonresident,_20).
opposite(n,sadist,masochist,_20).
opposite(n,sister,brother,_20).
opposite(n,sitter,stander,_20).
opposite(n,smoker,nonsmoker,_20).
opposite(n,son,daughter,_20).
opposite(n,'special agent','general agent',_20).
opposite(n,specialist,generalist,_20).
opposite(n,stranger,acquaintance,_20).
opposite(n,superior,inferior,_20).
opposite(n,technophobe,technophile,_20).
opposite(n,wife,husband,_20).
opposite(n,repulsion,attraction,_20).
opposite(n,'centripetal force','centrifugal force',_20).
opposite(n,'positive charge','negative charge',_20).
opposite(n,'direct current','alternating current',_20).
opposite(n,opacity,transparency,_20).
opposite(n,acrocarp,pleurocarp,_20).
opposite(n,'Cryptogamia','Phanerogamae',_20).
opposite(n,mushroom,toadstool,_20).
opposite(n,weed,'cultivated plant',_20).
opposite(n,'evergreen plant','deciduous plant',_20).
opposite(n,'easy money','tight money',_20).
opposite(n,'paper loss','paper profit',_20).
opposite(n,outgo,income,_20).
opposite(n,loss,gain,_20).
opposite(n,losings,winnings,_20).
opposite(n,'secured bond','unsecured bond',_20).
opposite(n,'cash account','margin account',_20).
opposite(n,'active trust','passive trust',_20).
opposite(n,cash,credit,_20).
opposite(n,'cash basis','accrual basis',_20).
opposite(n,'listed security','unlisted security',_20).
opposite(n,activation,inactivation,_20).
opposite(n,anabolism,catabolism,_20).
opposite(n,anamorphism,katamorphism,_20).
opposite(n,anastalsis,peristalsis,_20).
opposite(n,cenogenesis,palingenesis,_20).
opposite(n,deflation,disinflation,_20).
opposite(n,evolution,devolution,_20).
opposite(n,development,nondevelopment,_20).
opposite(n,increment,decrement,_20).
opposite(n,'inflationary spiral','deflationary spiral',_20).
opposite(n,inflow,outflow,_20).
opposite(n,influx,efflux,_20).
opposite(n,ovulation,anovulation,_20).
opposite(n,proliferation,nonproliferation,_20).
opposite(n,proliferation,'non-proliferation',_20).
opposite(n,'reversible process','irreversible process',_20).
opposite(n,'serial operation','parallel operation',_20).
opposite(n,sink,source,_20).
opposite(n,supply,demand,_20).
opposite(n,'synchronous operation','asynchronous operation',_20).
opposite(n,lead,deficit,_20).
opposite(n,aliquot,aliquant,_20).
opposite(n,connectedness,unconnectedness,_20).
opposite(n,relevance,irrelevance,_20).
opposite(n,applicability,inapplicability,_20).
opposite(n,relatedness,unrelatedness,_20).
opposite(n,transitivity,intransitivity,_20).
opposite(n,'active voice','passive voice',_20).
opposite(n,affinity,consanguinity,_20).
opposite(n,synchronism,asynchronism,_20).
opposite(n,synchronization,desynchronization,_20).
opposite(n,synchronizing,desynchronizing,_20).
opposite(n,latter,former,_20).
opposite(n,'convex polygon','concave polygon',_20).
opposite(n,curve,'straight line',_20).
opposite(n,'right triangle','oblique triangle',_20).
opposite(n,trapezium,parallelogram,_20).
opposite(n,'salient angle','reentrant angle',_20).
opposite(n,'right angle','oblique angle',_20).
opposite(n,proportion,disproportion,_20).
opposite(n,utopia,dystopia,_20).
opposite(n,equilibrium,disequilibrium,_20).
opposite(n,inclusion,exclusion,_20).
opposite(n,rejection,acceptance,_20).
opposite(n,stigmatism,astigmatism,_20).
opposite(n,'back burner','front burner',_20).
opposite(n,'low status','high status',_20).
opposite(n,being,nonbeing,_20).
opposite(n,existence,nonexistence,_20).
opposite(n,genuineness,spuriousness,_20).
opposite(n,truth,falsity,_20).
opposite(n,hereness,thereness,_20).
opposite(n,sympatry,allopatry,_20).
opposite(n,exogamy,endogamy,_20).
opposite(n,employment,unemployment,_20).
opposite(n,order,disorder,_20).
opposite(n,immunodeficiency,immunocompetence,_20).
opposite(n,war,peace,_20).
opposite(n,'hot war','cold war',_20).
opposite(n,dark,light,_20).
opposite(n,happiness,unhappiness,_20).
opposite(n,guilt,innocence,_20).
opposite(n,balance,imbalance,_20).
opposite(n,motion,motionlessness,_20).
opposite(n,action,inaction,_20).
opposite(n,soberness,drunkenness,_20).
opposite(n,insomnia,hypersomnia,_20).
opposite(n,sleepiness,wakefulness,_20).
opposite(n,estrus,anestrus,_20).
opposite(n,hypocapnia,hypercapnia,_20).
opposite(n,hypothermia,hyperthermia,_20).
opposite(n,fertility,infertility,_20).
opposite(n,potency,impotency,_20).
opposite(n,potence,impotence,_20).
opposite(n,'ill health','good health',_20).
opposite(n,'organic disorder','functional disorder',_20).
opposite(n,illness,wellness,_20).
opposite(n,hypoparathyroidism,hyperparathyroidism,_20).
opposite(n,hypotension,hypertension,_20).
opposite(n,hypothyroidism,hyperthyroidism,_20).
opposite(n,hypovolemia,hypervolemia,_20).
opposite(n,hypocalcemia,hypercalcemia,_20).
opposite(n,hypokalemia,hyperkalemia,_20).
opposite(n,hyponatremia,hypernatremia,_20).
opposite(n,hypopigmentation,hyperpigmentation,_20).
opposite(n,hypoglycemia,hyperglycemia,_20).
opposite(n,'mental health','mental illness',_20).
opposite(n,sanity,insanity,_20).
opposite(n,'neurotic depression','psychotic depression',_20).
opposite(n,elation,depression,_20).
opposite(n,high,'low spirits',_20).
opposite(n,union,separation,_20).
opposite(n,connectedness,disconnectedness,_20).
opposite(n,coherence,incoherence,_20).
opposite(n,association,disassociation,_20).
opposite(n,continuity,discontinuity,_20).
opposite(n,decline,improvement,_20).
opposite(n,maturity,immaturity,_20).
opposite(n,ripeness,greenness,_20).
opposite(n,obscurity,prominence,_20).
opposite(n,fame,infamy,_20).
opposite(n,esteem,disesteem,_20).
opposite(n,repute,disrepute,_20).
opposite(n,comfort,discomfort,_20).
opposite(n,wellness,unwellness,_20).
opposite(n,'ill-being','well-being',_20).
opposite(n,fullness,emptiness,_20).
opposite(n,solidity,hollowness,_20).
opposite(n,perfection,imperfection,_20).
opposite(n,completeness,incompleteness,_20).
opposite(n,varus,valgus,_20).
opposite(n,misfortune,'good fortune',_20).
opposite(n,'bad luck','good luck',_20).
opposite(n,solvency,insolvency,_20).
opposite(n,possibility,impossibility,_20).
opposite(n,purity,impurity,_20).
opposite(n,wealth,poverty,_20).
opposite(n,sanitariness,unsanitariness,_20).
opposite(n,orderliness,disorderliness,_20).
opposite(n,dirtiness,cleanness,_20).
opposite(n,normality,abnormality,_20).
opposite(n,typicality,atypicality,_20).
opposite(n,'biodegradable pollution','nonbiodegradable pollution',_20).
opposite(n,cyclone,anticyclone,_20).
opposite(n,'bad weather','good weather',_20).
opposite(n,susceptibility,unsusceptibility,_20).
opposite(n,wetness,dryness,_20).
opposite(n,safety,danger,_20).
opposite(n,security,insecurity,_20).
opposite(n,secureness,insecureness,_20).
opposite(n,tonicity,atonicity,_20).
opposite(n,myopia,hyperopia,_20).
opposite(n,homozygosity,heterozygosity,_20).
opposite(n,hypotonia,hypertonia,_20).
opposite(n,hypotonus,hypertonus,_20).
opposite(n,hypotonicity,hypertonicity,_20).
opposite(n,'leaded gasoline','unleaded gasoline',_20).
opposite(n,catalyst,anticatalyst,_20).
opposite(n,inhibitor,activator,_20).
opposite(n,insulator,conductor,_20).
opposite(n,exon,intron,_20).
opposite(n,'low explosive','high explosive',_20).
opposite(n,saltwater,'fresh water',_20).
opposite(n,exotoxin,endotoxin,_20).
opposite(n,'soft water','hard water',_20).
opposite(n,uptime,downtime,_20).
opposite(n,'time off','work time',_20).
opposite(n,past,future,_20).
opposite(n,workday,'rest day',_20).
opposite(n,day,night,_20).
opposite(n,sunset,sunrise,_20).
opposite(n,'winter solstice','summer solstice',_20).
opposite(n,'vernal equinox','autumnal equinox',_20).
opposite(n,overtime,'regulation time',_20).
opposite(n,'off-season','high season',_20).
opposite(n,'dry season','rainy season',_20).
opposite(n,top,bottom,_20).
opposite(v,inhale,exhale,_20).
opposite(v,rest,'be active',_20).
opposite(v,hibernate,aestivate,_20).
opposite(v,estivate,hibernate,_20).
opposite(v,'turn in','turn out',_20).
opposite(v,'get up','go to bed',_20).
opposite(v,'wake up','fall asleep',_20).
opposite(v,awaken,'cause to sleep',_20).
opposite(v,wake,sleep,_20).
opposite(v,'bring to',anesthetize,_20).
opposite(v,sedate,stimulate,_20).
opposite(v,energize,'de-energize',_20).
opposite(v,energise,'de-energise',_20).
opposite(v,tense,relax,_20).
opposite(v,strain,unstrain,_20).
opposite(v,overdress,underdress,_20).
opposite(v,'dress up','dress down',_20).
opposite(v,gain,reduce,_20).
opposite(v,dress,undress,_20).
opposite(v,'slip on','slip off',_20).
opposite(v,miscarry,'carry to term',_20).
opposite(v,soothe,irritate,_20).
opposite(v,suffer,'be well',_20).
opposite(v,cry,laugh,_20).
opposite(v,tire,refresh,_20).
opposite(v,vomit,'keep down',_20).
opposite(v,infect,disinfect,_20).
opposite(v,recuperate,deteriorate,_20).
opposite(v,stay,change,_20).
opposite(v,differentiate,dedifferentiate,_20).
opposite(v,mythologize,demythologize,_20).
opposite(v,assimilate,dissimilate,_20).
opposite(v,vitalize,devitalize,_20).
opposite(v,enrich,deprive,_20).
opposite(v,clutter,unclutter,_20).
opposite(v,add,'take away',_20).
opposite(v,activate,inactivate,_20).
opposite(v,deaden,enliven,_20).
opposite(v,falsify,correct,_20).
opposite(v,worsen,better,_20).
opposite(v,hydrate,dehydrate,_20).
opposite(v,wet,dry,_20).
opposite(v,humidify,dehumidify,_20).
opposite(v,lock,unlock,_20).
opposite(v,engage,disengage,_20).
opposite(v,weaken,strengthen,_20).
opposite(v,oxidize,deoxidize,_20).
opposite(v,oxidise,deoxidise,_20).
opposite(v,reduce,'blow up',_20).
opposite(v,shrink,stretch,_20).
opposite(v,regress,progress,_20).
opposite(v,age,rejuvenate,_20).
opposite(v,soften,harden,_20).
opposite(v,inflate,deflate,_20).
opposite(v,acidify,alkalize,_20).
opposite(v,'get well','get worse',_20).
opposite(v,freeze,unfreeze,_20).
opposite(v,block,unblock,_20).
opposite(v,stabilize,destabilize,_20).
opposite(v,stabilise,destabilise,_20).
opposite(v,sensitize,desensitize,_20).
opposite(v,predate,postdate,_20).
opposite(v,whiten,blacken,_20).
opposite(v,color,discolor,_20).
opposite(v,escalate,'de-escalate',_20).
opposite(v,uglify,beautify,_20).
opposite(v,tune,untune,_20).
opposite(v,qualify,disqualify,_20).
opposite(v,widen,narrow,_20).
opposite(v,'take in','let out',_20).
opposite(v,implode,explode,_20).
opposite(v,hydrogenate,dehydrogenate,_20).
opposite(v,blur,focus,_20).
opposite(v,darken,brighten,_20).
opposite(v,darken,lighten,_20).
opposite(v,depreciate,appreciate,_20).
opposite(v,shorten,lengthen,_20).
opposite(v,materialize,dematerialize,_20).
opposite(v,materialise,dematerialise,_20).
opposite(v,end,begin,_20).
opposite(v,die,'be born',_20).
opposite(v,unify,disunify,_20).
opposite(v,heat,cool,_20).
opposite(v,personalize,depersonalize,_20).
opposite(v,personalise,depersonalise,_20).
opposite(v,sharpen,flatten,_20).
opposite(v,synchronize,desynchronize,_20).
opposite(v,synchronise,desynchronise,_20).
opposite(v,magnetize,demagnetize,_20).
opposite(v,magnetise,demagnetise,_20).
opposite(v,simplify,complicate,_20).
opposite(v,pressurize,depressurize,_20).
opposite(v,pressurise,depressurise,_20).
opposite(v,centralize,decentralize,_20).
opposite(v,centralise,decentralise,_20).
opposite(v,concentrate,deconcentrate,_20).
opposite(v,winterize,summerize,_20).
opposite(v,nationalize,denationalize,_20).
opposite(v,nationalise,denationalise,_20).
opposite(v,naturalize,denaturalize,_20).
opposite(v,emigrate,immigrate,_20).
opposite(v,loosen,stiffen,_20).
opposite(v,transitivize,detransitivize,_20).
opposite(v,appear,disappear,_20).
opposite(v,minimize,maximize,_20).
opposite(v,minimise,maximise,_20).
opposite(v,'scale up','scale down',_20).
opposite(v,thin,thicken,_20).
opposite(v,wax,wane,_20).
opposite(v,unfurl,'roll up',_20).
opposite(v,diversify,specialize,_20).
opposite(v,diversify,specialise,_20).
opposite(v,decelerate,accelerate,_20).
opposite(v,validate,invalidate,_20).
opposite(v,fill,empty,_20).
opposite(v,curdle,homogenize,_20).
opposite(v,curdle,homogenise,_20).
opposite(v,rush,delay,_20).
opposite(v,louden,quieten,_20).
opposite(v,skew,align,_20).
opposite(v,integrate,disintegrate,_20).
opposite(v,contaminate,decontaminate,_20).
opposite(v,calcify,decalcify,_20).
opposite(v,emulsify,demulsify,_20).
opposite(v,nazify,denazify,_20).
opposite(v,nitrify,denitrify,_20).
opposite(v,enable,disable,_20).
opposite(v,foreground,background,_20).
opposite(v,'play up','play down',_20).
opposite(v,mystify,demystify,_20).
opposite(v,iodinate,'de-iodinate',_20).
opposite(v,ionate,'de-ionate',_20).
opposite(v,orientalize,occidentalize,_20).
opposite(v,orientalise,occidentalise,_20).
opposite(v,salinate,desalinate,_20).
opposite(v,scramble,unscramble,_20).
opposite(v,crescendo,decrescendo,_20).
opposite(v,stalinize,destalinize,_20).
opposite(v,know,ignore,_20).
opposite(v,'lose track','keep track',_20).
opposite(v,forget,remember,_20).
opposite(v,neglect,'attend to',_20).
opposite(v,literalize,spiritualize,_20).
opposite(v,add,subtract,_20).
opposite(v,divide,multiply,_20).
opposite(v,analyze,synthesize,_20).
opposite(v,upgrade,downgrade,_20).
opposite(v,prove,disprove,_20).
opposite(v,negate,affirm,_20).
opposite(v,overestimate,underestimate,_20).
opposite(v,approve,disapprove,_20).
opposite(v,dispose,indispose,_20).
opposite(v,believe,disbelieve,_20).
opposite(v,include,exclude,_20).
opposite(v,reject,accept,_20).
opposite(v,reprobate,approbate,_20).
opposite(v,trust,mistrust,_20).
opposite(v,overvalue,undervalue,_20).
opposite(v,associate,dissociate,_20).
opposite(v,claim,disclaim,_20).
opposite(v,persuade,dissuade,_20).
opposite(v,'talk into','talk out of',_20).
opposite(v,'contract in','contract out',_20).
opposite(v,permit,forbid,_20).
opposite(v,allow,disallow,_20).
opposite(v,assent,dissent,_20).
opposite(v,agree,disagree,_20).
opposite(v,avoid,confront,_20).
opposite(v,deny,admit,_20).
opposite(v,avow,disavow,_20).
opposite(v,overstate,understate,_20).
opposite(v,blame,absolve,_20).
opposite(v,deceive,undeceive,_20).
opposite(v,praise,criticize,_20).
opposite(v,cheer,complain,_20).
opposite(v,boo,applaud,_20).
opposite(v,curse,bless,_20).
opposite(v,desecrate,consecrate,_20).
opposite(v,flatter,disparage,_20).
opposite(v,oblige,disoblige,_20).
opposite(v,welcome,'say farewell',_20).
opposite(v,acquit,convict,_20).
opposite(v,shout,whisper,_20).
opposite(v,indicate,contraindicate,_20).
opposite(v,talk,'keep quiet',_20).
opposite(v,clarify,obfuscate,_20).
opposite(v,voice,devoice,_20).
opposite(v,expand,contract,_20).
opposite(v,'check in','check out',_20).
opposite(v,'clock in','clock out',_20).
opposite(v,'punch in','punch out',_20).
opposite(v,encode,decode,_20).
opposite(v,erase,record,_20).
opposite(v,specify,generalize,_20).
opposite(v,communicate,excommunicate,_20).
opposite(v,'open up','close up',_20).
opposite(v,spell,unspell,_20).
opposite(v,enter,'drop out',_20).
opposite(v,arm,disarm,_20).
opposite(v,mobilize,demobilize,_20).
opposite(v,mobilise,demobilise,_20).
opposite(v,war,'make peace',_20).
opposite(v,enlist,discharge,_20).
opposite(v,militarize,demilitarize,_20).
opposite(v,militarise,demilitarise,_20).
opposite(v,win,lose,_20).
opposite(v,gain,'fall back',_20).
opposite(v,resist,surrender,_20).
opposite(v,defend,attack,_20).
opposite(v,overshoot,undershoot,_20).
opposite(v,fuse,defuse,_20).
opposite(v,consume,abstain,_20).
opposite(v,'eat in','eat out',_20).
opposite(v,'live in','live out',_20).
opposite(v,feed,starve,_20).
opposite(v,breastfeed,bottlefeed,_20).
opposite(v,starve,'be full',_20).
opposite(v,clasp,unclasp,_20).
opposite(v,hold,'let go of',_20).
opposite(v,twist,untwist,_20).
opposite(v,hit,miss,_20).
opposite(v,smooth,roughen,_20).
opposite(v,fold,unfold,_20).
opposite(v,bend,unbend,_20).
opposite(v,wrap,unwrap,_20).
opposite(v,tie,untie,_20).
opposite(v,chain,unchain,_20).
opposite(v,strap,unstrap,_20).
opposite(v,join,disjoin,_20).
opposite(v,couple,uncouple,_20).
opposite(v,suffix,prefix,_20).
opposite(v,detach,attach,_20).
opposite(v,bridle,unbridle,_20).
opposite(v,bind,unbind,_20).
opposite(v,lash,unlash,_20).
opposite(v,dock,undock,_20).
opposite(v,degrade,aggrade,_20).
opposite(v,hitch,unhitch,_20).
opposite(v,cover,uncover,_20).
opposite(v,fasten,unfasten,_20).
opposite(v,unzip,'zip up',_20).
opposite(v,bar,unbar,_20).
opposite(v,open,close,_20).
opposite(v,bolt,unbolt,_20).
opposite(v,screw,unscrew,_20).
opposite(v,seal,unseal,_20).
opposite(v,connect,disconnect,_20).
opposite(v,mask,unmask,_20).
opposite(v,string,unstring,_20).
opposite(v,hook,unhook,_20).
opposite(v,belt,unbelt,_20).
opposite(v,staple,unstaple,_20).
opposite(v,clip,unclip,_20).
opposite(v,button,unbutton,_20).
opposite(v,pin,unpin,_20).
opposite(v,break,repair,_20).
opposite(v,spread,gather,_20).
opposite(v,compress,decompress,_20).
opposite(v,unplug,'plug in',_20).
opposite(v,cork,uncork,_20).
opposite(v,adduct,abduct,_20).
opposite(v,entangle,disentangle,_20).
opposite(v,snarl,unsnarl,_20).
opposite(v,arrange,disarrange,_20).
opposite(v,free,obstruct,_20).
opposite(v,clog,unclog,_20).
opposite(v,stuff,unstuff,_20).
opposite(v,pack,unpack,_20).
opposite(v,veil,unveil,_20).
opposite(v,box,unbox,_20).
opposite(v,crate,uncrate,_20).
opposite(v,burden,unburden,_20).
opposite(v,yoke,unyoke,_20).
opposite(v,inspan,outspan,_20).
opposite(v,harness,unharness,_20).
opposite(v,saddle,unsaddle,_20).
opposite(v,repel,attract,_20).
opposite(v,'switch on','switch off',_20).
opposite(v,twine,untwine,_20).
opposite(v,weave,unweave,_20).
opposite(v,braid,unbraid,_20).
opposite(v,ravel,unravel,_20).
opposite(v,knot,unknot,_20).
opposite(v,wind,unwind,_20).
opposite(v,coil,uncoil,_20).
opposite(v,function,malfunction,_20).
opposite(v,run,idle,_20).
opposite(v,'go on','go off',_20).
opposite(v,lodge,dislodge,_20).
opposite(v,dirty,clean,_20).
opposite(v,handwash,'machine wash',_20).
opposite(v,sit,stand,_20).
opposite(v,sit,lie,_20).
opposite(v,buckle,unbuckle,_20).
opposite(v,sheathe,unsheathe,_20).
opposite(v,wire,unwire,_20).
opposite(v,make,unmake,_20).
opposite(v,'phase in','phase out',_20).
opposite(v,incarnate,disincarnate,_20).
opposite(v,assemble,disassemble,_20).
opposite(v,raise,level,_20).
opposite(v,'cast on','cast off',_20).
opposite(v,overact,underact,_20).
opposite(v,calm,agitate,_20).
opposite(v,worry,reassure,_20).
opposite(v,humanize,dehumanize,_20).
opposite(v,elate,depress,_20).
opposite(v,sadden,gladden,_20).
opposite(v,lighten,'weigh down',_20).
opposite(v,please,displease,_20).
opposite(v,satisfy,dissatisfy,_20).
opposite(v,content,discontent,_20).
opposite(v,enchant,disenchant,_20).
opposite(v,hearten,dishearten,_20).
opposite(v,encourage,discourage,_20).
opposite(v,bore,interest,_20).
opposite(v,wish,begrudge,_20).
opposite(v,admire,'look down on',_20).
opposite(v,move,'stand still',_20).
opposite(v,travel,'stay in place',_20).
opposite(v,go,come,_20).
opposite(v,'move in','move out',_20).
opposite(v,push,pull,_20).
opposite(v,ebb,tide,_20).
opposite(v,walk,ride,_20).
opposite(v,cross,uncross,_20).
opposite(v,'file in','file out',_20).
opposite(v,'pop in','pop out',_20).
opposite(v,'hop on','hop out',_20).
opposite(v,ascend,descend,_20).
opposite(v,raise,lower,_20).
opposite(v,embark,disembark,_20).
opposite(v,arise,'sit down',_20).
opposite(v,arise,'lie down',_20).
opposite(v,glycerolize,deglycerolize,_20).
opposite(v,sink,float,_20).
opposite(v,follow,precede,_20).
opposite(v,'top out','bottom out',_20).
opposite(v,stay,depart,_20).
opposite(v,leave,arrive,_20).
opposite(v,'pull in','pull out',_20).
opposite(v,'get on','get off',_20).
opposite(v,diverge,converge,_20).
opposite(v,bend,straighten,_20).
opposite(v,rush,linger,_20).
opposite(v,overexpose,underexpose,_20).
opposite(v,sensitise,desensitise,_20).
opposite(v,odorize,deodorize,_20).
opposite(v,odourise,deodourise,_20).
opposite(v,show,hide,_20).
opposite(v,orient,disorient,_20).
opposite(v,sour,sweeten,_20).
opposite(v,take,give,_20).
opposite(v,buy,sell,_20).
opposite(v,bequeath,disinherit,_20).
opposite(v,upload,download,_20).
opposite(v,'log in','log out',_20).
opposite(v,overpay,underpay,_20).
opposite(v,'pay up',default,_20).
opposite(v,overspend,underspend,_20).
opposite(v,waste,conserve,_20).
opposite(v,invest,divest,_20).
opposite(v,claim,forfeit,_20).
opposite(v,requisition,derequisition,_20).
opposite(v,profit,'break even',_20).
opposite(v,lose,find,_20).
opposite(v,lose,keep,_20).
opposite(v,clear,bounce,_20).
opposite(v,overbid,underbid,_20).
opposite(v,deposit,withdraw,_20).
opposite(v,charge,'pay cash',_20).
opposite(v,enrich,impoverish,_20).
opposite(v,overcharge,undercharge,_20).
opposite(v,'mark up','mark down',_20).
opposite(v,overstock,understock,_20).
opposite(v,lend,borrow,_20).
opposite(v,muzzle,unmuzzle,_20).
opposite(v,act,refrain,_20).
opposite(v,'take office','leave office',_20).
opposite(v,enthrone,dethrone,_20).
opposite(v,demote,promote,_20).
opposite(v,hire,fire,_20).
opposite(v,free,confine,_20).
opposite(v,let,prevent,_20).
opposite(v,abolish,establish,_20).
opposite(v,organize,disorganize,_20).
opposite(v,organise,disorganise,_20).
opposite(v,certify,decertify,_20).
opposite(v,boycott,patronize,_20).
opposite(v,boycott,patronise,_20).
opposite(v,enfranchise,disenfranchise,_20).
opposite(v,issue,recall,_20).
opposite(v,outlaw,legalize,_20).
opposite(v,criminalize,decriminalize,_20).
opposite(v,criminalise,decriminalise,_20).
opposite(v,segregate,desegregate,_20).
opposite(v,repatriate,expatriate,_20).
opposite(v,classify,declassify,_20).
opposite(v,restrict,derestrict,_20).
opposite(v,regulate,deregulate,_20).
opposite(v,behave,misbehave,_20).
opposite(v,obey,disobey,_20).
opposite(v,exempt,enforce,_20).
opposite(v,purge,rehabilitate,_20).
opposite(v,defend,prosecute,_20).
opposite(v,colonize,decolonize,_20).
opposite(v,colonise,decolonise,_20).
opposite(v,fail,manage,_20).
opposite(v,miss,attend,_20).
opposite(v,survive,succumb,_20).
opposite(v,obviate,necessitate,_20).
opposite(v,miss,have,_20).
opposite(v,deviate,conform,_20).
opposite(v,equal,differ,_20).
opposite(v,'go out','come in',_20).
opposite(v,violate,'conform to',_20).
opposite(v,satisfy,'fall short of',_20).
opposite(v,balance,unbalance,_20).
opposite(v,continue,discontinue,_20).
opposite(v,defy,'lend oneself',_20).
opposite(v,ignite,extinguish,_20).
opposite(v,emit,absorb,_20).
opposite(v,overcast,'clear up',_20).
opposite(a,able,unable,_20).
opposite(a,adaxial,abaxial,_20).
opposite(a,basiscopic,acroscopic,_20).
opposite(a,adducent,abducent,_20).
opposite(a,dying,nascent,_20).
opposite(a,abridged,unabridged,_20).
opposite(a,relative,absolute,_20).
opposite(a,absorbent,nonabsorbent,_20).
opposite(a,adsorbent,nonadsorbent,_20).
opposite(a,adsorbable,absorbable,_20).
opposite(a,gluttonous,abstemious,_20).
opposite(a,concrete,abstract,_20).
opposite(a,scarce,abundant,_20).
opposite(a,abused,unabused,_20).
opposite(a,acceptable,unacceptable,_20).
opposite(a,accessible,inaccessible,_20).
opposite(a,accommodating,unaccommodating,_20).
opposite(a,accurate,inaccurate,_20).
opposite(a,accustomed,unaccustomed,_20).
opposite(a,acidic,alkaline,_20).
opposite(a,acidic,amphoteric,_20).
opposite(a,'acid-loving','alkaline-loving',_20).
opposite(a,acknowledged,unacknowledged,_20).
opposite(a,acquisitive,unacquisitive,_20).
opposite(a,basipetal,acropetal,_20).
opposite(a,active,inactive,_20).
opposite(a,active,passive,_20).
opposite(a,active,dormant,_20).
opposite(a,active,extinct,_20).
opposite(a,active,stative,_20).
opposite(a,actual,potential,_20).
opposite(a,acute,chronic,_20).
opposite(a,virulent,avirulent,_20).
opposite(a,adaptive,maladaptive,_20).
opposite(a,addicted,unaddicted,_20).
opposite(a,addictive,nonaddictive,_20).
opposite(a,additive,subtractive,_20).
opposite(a,addressed,unaddressed,_20).
opposite(a,adequate,inadequate,_20).
opposite(a,adhesive,nonadhesive,_20).
opposite(a,adjective,substantive,_20).
opposite(a,adoptable,unadoptable,_20).
opposite(a,adorned,unadorned,_20).
opposite(a,cholinergic,anticholinergic,_20).
opposite(a,adroit,maladroit,_20).
opposite(a,advantageous,disadvantageous,_20).
opposite(a,adventurous,unadventurous,_20).
opposite(a,advisable,inadvisable,_20).
opposite(a,'ill-advised','well-advised',_20).
opposite(a,aerobic,anaerobic,_20).
opposite(a,aesthetic,inaesthetic,_20).
opposite(a,affected,unaffected,_20).
opposite(a,rejective,acceptive,_20).
opposite(a,afloat,aground,_20).
opposite(a,afraid,unafraid,_20).
opposite(a,aggressive,unaggressive,_20).
opposite(a,agitated,unagitated,_20).
opposite(a,agreeable,disagreeable,_20).
opposite(a,'air-to-air','air-to-surface',_20).
opposite(a,alert,unalert,_20).
opposite(a,heuristic,algorithmic,_20).
opposite(a,alienable,inalienable,_20).
opposite(a,dead,alive,_20).
opposite(a,eccrine,apocrine,_20).
opposite(a,artesian,subartesian,_20).
opposite(a,alphabetic,analphabetic,_20).
opposite(a,precocial,altricial,_20).
opposite(a,egoistic,altruistic,_20).
opposite(a,ambiguous,unambiguous,_20).
opposite(a,ambitious,unambitious,_20).
opposite(a,ametropic,emmetropic,_20).
opposite(a,ample,meager,_20).
opposite(a,anabolic,catabolic,_20).
opposite(a,anaclinal,cataclinal,_20).
opposite(a,astigmatic,anastigmatic,_20).
opposite(a,synclinal,anticlinal,_20).
opposite(a,anadromous,catadromous,_20).
opposite(a,anabatic,katabatic,_20).
opposite(a,oral,anal,_20).
opposite(a,digital,analogue,_20).
opposite(a,analytic,synthetic,_20).
opposite(a,inflectional,derivational,_20).
opposite(a,syncarpous,apocarpous,_20).
opposite(a,angry,unangry,_20).
opposite(a,resentful,unresentful,_20).
opposite(a,sentient,insentient,_20).
opposite(a,animate,inanimate,_20).
opposite(a,animated,unanimated,_20).
opposite(a,enlivened,unenlivened,_20).
opposite(a,onymous,anonymous,_20).
opposite(a,postmortem,antemortem,_20).
opposite(a,subsequent,antecedent,_20).
opposite(a,retrorse,antrorse,_20).
opposite(a,aquatic,terrestrial,_20).
opposite(a,aquatic,amphibious,_20).
opposite(a,preceding,succeeding,_20).
opposite(a,precedented,unprecedented,_20).
opposite(a,prehensile,nonprehensile,_20).
opposite(a,prenatal,perinatal,_20).
opposite(a,prenatal,postnatal,_20).
opposite(a,preprandial,postprandial,_20).
opposite(a,prewar,postwar,_20).
opposite(a,retrograde,anterograde,_20).
opposite(a,postmeridian,antemeridian,_20).
opposite(a,anterior,posterior,_20).
opposite(a,dorsal,ventral,_20).
opposite(a,appealable,unappealable,_20).
opposite(a,appendaged,unappendaged,_20).
opposite(a,appetizing,unappetizing,_20).
opposite(a,approachable,unapproachable,_20).
opposite(a,appropriate,inappropriate,_20).
opposite(a,due,undue,_20).
opposite(a,apropos,malapropos,_20).
opposite(a,'a priori','a posteriori',_20).
opposite(a,apteral,peripteral,_20).
opposite(a,arbitrable,nonarbitrable,_20).
opposite(a,columned,noncolumned,_20).
opposite(a,arboreal,nonarboreal,_20).
opposite(a,arenaceous,argillaceous,_20).
opposite(a,armed,unarmed,_20).
opposite(a,armored,unarmored,_20).
opposite(a,armed,armless,_20).
opposite(a,artful,artless,_20).
opposite(a,articulate,inarticulate,_20).
opposite(a,speaking,nonspeaking,_20).
opposite(a,articulated,unarticulated,_20).
opposite(a,ashamed,unashamed,_20).
opposite(a,assertive,unassertive,_20).
opposite(a,associative,nonassociative,_20).
opposite(a,attached,unattached,_20).
opposite(a,affixed,unaffixed,_20).
opposite(a,sessile,pedunculate,_20).
opposite(a,stuck,unstuck,_20).
opposite(a,detachable,attachable,_20).
opposite(a,wary,unwary,_20).
opposite(a,attentive,inattentive,_20).
opposite(a,attractive,unattractive,_20).
opposite(a,appealing,unappealing,_20).
opposite(a,attributable,unattributable,_20).
opposite(a,predicative,attributive,_20).
opposite(a,pregnant,nonpregnant,_20).
opposite(a,audible,inaudible,_20).
opposite(a,sonic,subsonic,_20).
opposite(a,sonic,supersonic,_20).
opposite(a,auspicious,inauspicious,_20).
opposite(a,propitious,unpropitious,_20).
opposite(a,authorized,unauthorized,_20).
opposite(a,constitutional,unconstitutional,_20).
opposite(a,autochthonous,allochthonous,_20).
opposite(a,autoecious,heteroecious,_20).
opposite(a,autogenous,heterogenous,_20).
opposite(a,manual,automatic,_20).
opposite(a,available,unavailable,_20).
opposite(a,awake,asleep,_20).
opposite(a,astringent,nonastringent,_20).
opposite(a,aware,unaware,_20).
opposite(a,witting,unwitting,_20).
opposite(a,alarming,unalarming,_20).
opposite(a,anemophilous,entomophilous,_20).
opposite(a,reassuring,unreassuring,_20).
opposite(a,leading,following,_20).
opposite(a,backed,backless,_20).
opposite(a,forward,backward,_20).
opposite(a,balconied,unbalconied,_20).
opposite(a,barreled,unbarreled,_20).
opposite(a,beaked,beakless,_20).
opposite(a,bedded,bedless,_20).
opposite(a,beneficed,unbeneficed,_20).
opposite(a,stratified,unstratified,_20).
opposite(a,ferned,fernless,_20).
opposite(a,grassy,grassless,_20).
opposite(a,gusseted,ungusseted,_20).
opposite(a,hairy,hairless,_20).
opposite(a,awned,awnless,_20).
opposite(a,bearing,nonbearing,_20).
opposite(a,ugly,beautiful,_20).
opposite(a,bellied,bellyless,_20).
opposite(a,banded,unbanded,_20).
opposite(a,belted,unbelted,_20).
opposite(a,maleficent,beneficent,_20).
opposite(a,malicious,unmalicious,_20).
opposite(a,malign,benign,_20).
opposite(a,worsening,bettering,_20).
opposite(a,bicameral,unicameral,_20).
opposite(a,bidirectional,unidirectional,_20).
opposite(a,faced,faceless,_20).
opposite(a,bibbed,bibless,_20).
opposite(a,unilateral,multilateral,_20).
opposite(a,bimodal,unimodal,_20).
opposite(a,monaural,binaural,_20).
opposite(a,binucleate,trinucleate,_20).
opposite(a,binucleate,mononuclear,_20).
opposite(a,bipedal,quadrupedal,_20).
opposite(a,biped,quadruped,_20).
opposite(a,blond,brunet,_20).
opposite(a,blemished,unblemished,_20).
opposite(a,bloody,bloodless,_20).
opposite(a,bound,unbound,_20).
opposite(a,laced,unlaced,_20).
opposite(a,tied,untied,_20).
opposite(a,tangled,untangled,_20).
opposite(a,bordered,unbordered,_20).
opposite(a,lotic,lentic,_20).
opposite(a,'lower-class','middle-class',_20).
opposite(a,brachycephalic,dolichocephalic,_20).
opposite(a,brave,cowardly,_20).
opposite(a,gutsy,gutless,_20).
opposite(a,'breast-fed','bottle-fed',_20).
opposite(a,breathing,breathless,_20).
opposite(a,crystalline,noncrystalline,_20).
opposite(a,landed,landless,_20).
opposite(a,shaded,unshaded,_20).
opposite(a,moonlit,moonless,_20).
opposite(a,bridgeable,unbridgeable,_20).
opposite(a,dull,bright,_20).
opposite(a,dimmed,undimmed,_20).
opposite(a,prejudiced,unprejudiced,_20).
opposite(a,'broad-minded','narrow-minded',_20).
opposite(a,reconstructed,unreconstructed,_20).
opposite(a,broken,unbroken,_20).
opposite(a,sisterly,brotherly,_20).
opposite(a,exergonic,endergonic,_20).
opposite(a,identical,fraternal,_20).
opposite(a,buried,unburied,_20).
opposite(a,idle,busy,_20).
opposite(a,bony,boneless,_20).
opposite(a,buttoned,unbuttoned,_20).
opposite(a,socialistic,capitalistic,_20).
opposite(a,euphonious,cacophonous,_20).
opposite(a,calculable,incalculable,_20).
opposite(a,calm,stormy,_20).
opposite(a,camphorated,uncamphorated,_20).
opposite(a,capable,incapable,_20).
opposite(a,'cared-for','uncared-for',_20).
opposite(a,careful,careless,_20).
opposite(a,carnivorous,insectivorous,_20).
opposite(a,herbivorous,carnivorous,_20).
opposite(a,holozoic,holophytic,_20).
opposite(a,carpellate,acarpelous,_20).
opposite(a,carpeted,uncarpeted,_20).
opposite(a,'carvel-built','clinker-built',_20).
opposite(a,carved,uncarved,_20).
opposite(a,acatalectic,hypercatalectic,_20).
opposite(a,catalectic,acatalectic,_20).
opposite(a,radical,cauline,_20).
opposite(a,censored,uncensored,_20).
opposite(a,caudate,acaudate,_20).
opposite(a,caulescent,acaulescent,_20).
opposite(a,causative,noncausative,_20).
opposite(a,cautious,incautious,_20).
opposite(a,cellular,noncellular,_20).
opposite(a,coherent,incoherent,_20).
opposite(a,compartmented,uncompartmented,_20).
opposite(a,porous,nonporous,_20).
opposite(a,central,peripheral,_20).
opposite(a,centripetal,centrifugal,_20).
opposite(a,efferent,afferent,_20).
opposite(a,centralizing,decentralizing,_20).
opposite(a,certain,uncertain,_20).
opposite(a,sure,unsure,_20).
opposite(a,convinced,unconvinced,_20).
opposite(a,diffident,confident,_20).
opposite(a,certified,uncertified,_20).
opposite(a,evitable,inevitable,_20).
opposite(a,preventable,unpreventable,_20).
opposite(a,changeable,unchangeable,_20).
opposite(a,commutable,incommutable,_20).
opposite(a,alterable,unalterable,_20).
opposite(a,modifiable,unmodifiable,_20).
opposite(a,adjusted,unadjusted,_20).
opposite(a,adjusted,maladjusted,_20).
opposite(a,altered,unaltered,_20).
opposite(a,amended,unamended,_20).
opposite(a,changed,unchanged,_20).
opposite(a,isotonic,isometric,_20).
opposite(a,ionized,nonionized,_20).
opposite(a,mutable,immutable,_20).
opposite(a,characteristic,uncharacteristic,_20).
opposite(a,charged,uncharged,_20).
opposite(a,charitable,uncharitable,_20).
opposite(a,chartered,unchartered,_20).
opposite(a,owned,unowned,_20).
opposite(a,chaste,unchaste,_20).
opposite(a,cheerful,depressing,_20).
opposite(a,chlamydeous,achlamydeous,_20).
opposite(a,chondritic,achondritic,_20).
opposite(a,triclinic,monoclinic,_20).
opposite(a,polychromatic,monochromatic,_20).
opposite(a,chromatic,achromatic,_20).
opposite(a,saturated,unsaturated,_20).
opposite(a,color,'black-and-white',_20).
opposite(a,colored,uncolored,_20).
opposite(a,stained,unstained,_20).
opposite(a,colorful,colorless,_20).
opposite(a,colourful,colourless,_20).
opposite(a,tramontane,cismontane,_20).
opposite(a,christian,unchristian,_20).
opposite(a,civilized,noncivilized,_20).
opposite(a,classical,nonclassical,_20).
opposite(a,classified,unclassified,_20).
opposite(a,analyzed,unanalyzed,_20).
opposite(a,radioactive,nonradioactive,_20).
opposite(a,clean,unclean,_20).
opposite(a,clear,unclear,_20).
opposite(a,clear,opaque,_20).
opposite(a,radiopaque,radiolucent,_20).
opposite(a,confused,clearheaded,_20).
opposite(a,clement,inclement,_20).
opposite(a,smart,stupid,_20).
opposite(a,clockwise,counterclockwise,_20).
opposite(a,far,near,_20).
opposite(a,close,distant,_20).
opposite(a,cousinly,uncousinly,_20).
opposite(a,clothed,unclothed,_20).
opposite(a,saddled,unsaddled,_20).
opposite(a,clear,cloudy,_20).
opposite(a,inland,coastal,_20).
opposite(a,inshore,offshore,_20).
opposite(a,collapsible,noncollapsible,_20).
opposite(a,crannied,uncrannied,_20).
opposite(a,collective,distributive,_20).
opposite(a,suppressed,publicized,_20).
opposite(a,published,unpublished,_20).
opposite(a,publishable,unpublishable,_20).
opposite(a,reported,unreported,_20).
opposite(a,reportable,unreportable,_20).
opposite(a,combinative,noncombinative,_20).
opposite(a,combustible,noncombustible,_20).
opposite(a,explosive,nonexplosive,_20).
opposite(a,lighted,unlighted,_20).
opposite(a,commodious,incommodious,_20).
opposite(a,comfortable,uncomfortable,_20).
opposite(a,commensurate,incommensurate,_20).
opposite(a,proportionate,disproportionate,_20).
opposite(a,commercial,noncommercial,_20).
opposite(a,residential,nonresidential,_20).
opposite(a,commissioned,noncommissioned,_20).
opposite(a,common,uncommon,_20).
opposite(a,usual,unusual,_20).
opposite(a,hydrophobic,hydrophilic,_20).
opposite(a,oleophobic,oleophilic,_20).
opposite(a,common,individual,_20).
opposite(a,communicative,uncommunicative,_20).
opposite(a,loose,compact,_20).
opposite(a,comparable,incomparable,_20).
opposite(a,compassionate,uncompassionate,_20).
opposite(a,compatible,incompatible,_20).
opposite(a,miscible,immiscible,_20).
opposite(a,competent,incompetent,_20).
opposite(a,competitive,noncompetitive,_20).
opposite(a,complaining,uncomplaining,_20).
opposite(a,compressible,incompressible,_20).
opposite(a,whole,fractional,_20).
opposite(a,committed,uncommitted,_20).
opposite(a,dedicated,undedicated,_20).
opposite(a,complete,incomplete,_20).
opposite(a,comprehensive,noncomprehensive,_20).
opposite(a,composed,discomposed,_20).
opposite(a,comprehensible,incomprehensible,_20).
opposite(a,convex,concave,_20).
opposite(a,distributed,concentrated,_20).
opposite(a,eccentric,concentric,_20).
opposite(a,concerned,unconcerned,_20).
opposite(a,prolix,concise,_20).
opposite(a,conclusive,inconclusive,_20).
opposite(a,consummated,unconsummated,_20).
opposite(a,coordinating,subordinating,_20).
opposite(a,accordant,discordant,_20).
opposite(a,expanded,contracted,_20).
opposite(a,atrophied,hypertrophied,_20).
opposite(a,conditional,unconditional,_20).
opposite(a,enforceable,unenforceable,_20).
opposite(a,enforced,unenforced,_20).
opposite(a,conductive,nonconductive,_20).
opposite(a,confined,unconfined,_20).
opposite(a,crowded,uncrowded,_20).
opposite(a,congenial,uncongenial,_20).
opposite(a,congruent,incongruent,_20).
opposite(a,congruous,incongruous,_20).
opposite(a,disjunctive,conjunctive,_20).
opposite(a,disjunct,conjunct,_20).
opposite(a,connected,unconnected,_20).
opposite(a,conquerable,unconquerable,_20).
opposite(a,conscious,unconscious,_20).
opposite(a,desecrated,consecrated,_20).
opposite(a,priestly,unpriestly,_20).
opposite(a,consistent,inconsistent,_20).
opposite(a,conspicuous,inconspicuous,_20).
opposite(a,discernible,indiscernible,_20).
opposite(a,distinguishable,indistinguishable,_20).
opposite(a,constant,inconstant,_20).
opposite(a,destructive,constructive,_20).
opposite(a,contented,discontented,_20).
opposite(a,contestable,incontestable,_20).
opposite(a,continent,incontinent,_20).
opposite(a,sporadic,continual,_20).
opposite(a,continuous,discontinuous,_20).
opposite(a,continued,discontinued,_20).
opposite(a,controlled,uncontrolled,_20).
opposite(a,controversial,uncontroversial,_20).
opposite(a,argumentative,unargumentative,_20).
opposite(a,convenient,inconvenient,_20).
opposite(a,conventional,unconventional,_20).
opposite(a,traditional,nontraditional,_20).
opposite(a,divergent,convergent,_20).
opposite(a,branchy,branchless,_20).
opposite(a,convincing,unconvincing,_20).
opposite(a,raw,cooked,_20).
opposite(a,cooperative,uncooperative,_20).
opposite(a,corrupt,incorrupt,_20).
opposite(a,synergistic,antagonistic,_20).
opposite(a,considerable,inconsiderable,_20).
opposite(a,substantial,insubstantial,_20).
opposite(a,material,immaterial,_20).
opposite(a,bodied,unbodied,_20).
opposite(a,brainwashed,unbrainwashed,_20).
opposite(a,corporeal,incorporeal,_20).
opposite(a,correct,incorrect,_20).
opposite(a,corrected,uncorrected,_20).
opposite(a,corrigible,incorrigible,_20).
opposite(a,provincial,cosmopolitan,_20).
opposite(a,costive,laxative,_20).
opposite(a,constipated,unconstipated,_20).
opposite(a,considerate,inconsiderate,_20).
opposite(a,courteous,discourteous,_20).
opposite(a,polite,impolite,_20).
opposite(a,civil,uncivil,_20).
opposite(a,civil,sidereal,_20).
opposite(a,creative,uncreative,_20).
opposite(a,credible,incredible,_20).
opposite(a,credulous,incredulous,_20).
opposite(a,critical,uncritical,_20).
opposite(a,judgmental,nonjudgmental,_20).
opposite(a,critical,noncritical,_20).
opposite(a,crossed,uncrossed,_20).
opposite(a,walleyed,'cross-eyed',_20).
opposite(a,crowned,uncrowned,_20).
opposite(a,crucial,noncrucial,_20).
opposite(a,crystallized,uncrystallized,_20).
opposite(a,cubic,linear,_20).
opposite(a,cubic,planar,_20).
opposite(a,unidimensional,multidimensional,_20).
opposite(a,cut,uncut,_20).
opposite(a,curious,incurious,_20).
opposite(a,current,noncurrent,_20).
opposite(a,cursed,blessed,_20).
opposite(a,endowed,unendowed,_20).
opposite(a,curtained,curtainless,_20).
opposite(a,handmade,'machine-made',_20).
opposite(a,homemade,'factory-made',_20).
opposite(a,cyclic,noncyclic,_20).
opposite(a,cyclic,acyclic,_20).
opposite(a,annual,biennial,_20).
opposite(a,annual,perennial,_20).
opposite(a,diurnal,nocturnal,_20).
opposite(a,damaged,undamaged,_20).
opposite(a,datable,undatable,_20).
opposite(a,deaf,hearing,_20).
opposite(a,decent,indecent,_20).
opposite(a,decisive,indecisive,_20).
opposite(a,declarative,interrogative,_20).
opposite(a,declaratory,interrogatory,_20).
opposite(a,declared,undeclared,_20).
opposite(a,decorous,indecorous,_20).
opposite(a,deductible,nondeductible,_20).
opposite(a,deep,shallow,_20).
opposite(a,'de jure','de facto',_20).
opposite(a,defeasible,indefeasible,_20).
opposite(a,defeated,undefeated,_20).
opposite(a,defiant,compliant,_20).
opposite(a,defined,undefined,_20).
opposite(a,'ill-defined','well-defined',_20).
opposite(a,derived,underived,_20).
opposite(a,inflected,uninflected,_20).
opposite(a,definite,indefinite,_20).
opposite(a,dehiscent,indehiscent,_20).
opposite(a,elated,dejected,_20).
opposite(a,rugged,delicate,_20).
opposite(a,breakable,unbreakable,_20).
opposite(a,demanding,undemanding,_20).
opposite(a,imperative,beseeching,_20).
opposite(a,democratic,undemocratic,_20).
opposite(a,arbitrary,nonarbitrary,_20).
opposite(a,demonstrative,undemonstrative,_20).
opposite(a,deniable,undeniable,_20).
opposite(a,denotative,connotative,_20).
opposite(a,reliable,unreliable,_20).
opposite(a,dependable,undependable,_20).
opposite(a,dependent,independent,_20).
opposite(a,aligned,nonaligned,_20).
opposite(a,descriptive,prescriptive,_20).
opposite(a,descriptive,undescriptive,_20).
opposite(a,desirable,undesirable,_20).
opposite(a,preserved,destroyed,_20).
opposite(a,destructible,indestructible,_20).
opposite(a,determinable,indeterminable,_20).
opposite(a,determinate,indeterminate,_20).
opposite(a,developed,undeveloped,_20).
opposite(a,dextral,sinistral,_20).
opposite(a,diabatic,adiabatic,_20).
opposite(a,differentiated,undifferentiated,_20).
opposite(a,easy,difficult,_20).
opposite(a,plantigrade,digitigrade,_20).
opposite(a,dignified,undignified,_20).
opposite(a,statesmanlike,unstatesmanlike,_20).
opposite(a,presidential,unpresidential,_20).
opposite(a,dicotyledonous,monocotyledonous,_20).
opposite(a,diligent,negligent,_20).
opposite(a,diluted,undiluted,_20).
opposite(a,diplomatic,undiplomatic,_20).
opposite(a,direct,indirect,_20).
opposite(a,direct,alternating,_20).
opposite(a,direct,inverse,_20).
opposite(a,mediate,immediate,_20).
opposite(a,discerning,undiscerning,_20).
opposite(a,discreet,indiscreet,_20).
opposite(a,discriminate,indiscriminate,_20).
opposite(a,discriminating,undiscriminating,_20).
opposite(a,disposable,nondisposable,_20).
opposite(a,returnable,nonreturnable,_20).
opposite(a,distal,proximal,_20).
opposite(a,distinct,indistinct,_20).
opposite(a,focused,unfocused,_20).
opposite(a,diversified,undiversified,_20).
opposite(a,divisible,indivisible,_20).
opposite(a,documented,undocumented,_20).
opposite(a,submissive,domineering,_20).
opposite(a,servile,unservile,_20).
opposite(a,dominant,subordinate,_20).
opposite(a,dominant,recessive,_20).
opposite(a,'single-barreled','double-barreled',_20).
opposite(a,'single-breasted','double-breasted',_20).
opposite(a,dramatic,undramatic,_20).
opposite(a,actable,unactable,_20).
opposite(a,theatrical,untheatrical,_20).
opposite(a,drinkable,undrinkable,_20).
opposite(a,sober,intoxicated,_20).
opposite(a,dull,sharp,_20).
opposite(a,eventful,uneventful,_20).
opposite(a,dull,lively,_20).
opposite(a,dynamic,undynamic,_20).
opposite(a,eager,uneager,_20).
opposite(a,eared,earless,_20).
opposite(a,earned,unearned,_20).
opposite(a,easy,uneasy,_20).
opposite(a,west,east,_20).
opposite(a,western,eastern,_20).
opposite(a,endomorphic,ectomorphic,_20).
opposite(a,edible,inedible,_20).
opposite(a,educated,uneducated,_20).
opposite(a,numerate,innumerate,_20).
opposite(a,operative,inoperative,_20).
opposite(a,effective,ineffective,_20).
opposite(a,effortful,effortless,_20).
opposite(a,efficacious,inefficacious,_20).
opposite(a,efficient,inefficient,_20).
opposite(a,forceful,forceless,_20).
opposite(a,elastic,inelastic,_20).
opposite(a,elective,appointive,_20).
opposite(a,assigned,unassigned,_20).
opposite(a,optional,obligatory,_20).
opposite(a,elegant,inelegant,_20).
opposite(a,eligible,ineligible,_20).
opposite(a,emotional,unemotional,_20).
opposite(a,empirical,theoretical,_20).
opposite(a,salaried,freelance,_20).
opposite(a,employed,unemployed,_20).
opposite(a,employable,unemployable,_20).
opposite(a,enchanted,disenchanted,_20).
opposite(a,encouraging,discouraging,_20).
opposite(a,encumbered,unencumbered,_20).
opposite(a,burdened,unburdened,_20).
opposite(a,exocentric,endocentric,_20).
opposite(a,exogamous,endogamous,_20).
opposite(a,endogamous,autogamous,_20).
opposite(a,exoergic,endoergic,_20).
opposite(a,exothermic,endothermic,_20).
opposite(a,exogenous,endogenous,_20).
opposite(a,exogenic,endogenic,_20).
opposite(a,'run-on','end-stopped',_20).
opposite(a,lethargic,energetic,_20).
opposite(a,enfranchised,disenfranchised,_20).
opposite(a,exportable,unexportable,_20).
opposite(a,exploratory,nonexploratory,_20).
opposite(a,inquiring,uninquiring,_20).
opposite(a,increased,decreased,_20).
opposite(a,reducible,irreducible,_20).
opposite(a,enlightened,unenlightened,_20).
opposite(a,enterprising,unenterprising,_20).
opposite(a,enthusiastic,unenthusiastic,_20).
opposite(a,desirous,undesirous,_20).
opposite(a,epizoic,entozoic,_20).
opposite(a,equal,unequal,_20).
opposite(a,balanced,unbalanced,_20).
opposite(a,isotonic,hypertonic,_20).
opposite(a,isotonic,hypotonic,_20).
opposite(a,equivocal,unequivocal,_20).
opposite(a,eradicable,ineradicable,_20).
opposite(a,exoteric,esoteric,_20).
opposite(a,dispensable,indispensable,_20).
opposite(a,estimable,contemptible,_20).
opposite(a,ethical,unethical,_20).
opposite(a,complimentary,uncomplimentary,_20).
opposite(a,flattering,unflattering,_20).
opposite(a,euphemistic,dysphemistic,_20).
opposite(a,euphoric,dysphoric,_20).
opposite(a,even,uneven,_20).
opposite(a,evergreen,deciduous,_20).
opposite(a,exact,inexact,_20).
opposite(a,convertible,inconvertible,_20).
opposite(a,exchangeable,unexchangeable,_20).
opposite(a,excitable,unexcitable,_20).
opposite(a,excited,unexcited,_20).
opposite(a,exciting,unexciting,_20).
opposite(a,inculpatory,exculpatory,_20).
opposite(a,exhaustible,inexhaustible,_20).
opposite(a,exhausted,unexhausted,_20).
opposite(a,existent,nonexistent,_20).
opposite(a,expected,unexpected,_20).
opposite(a,expedient,inexpedient,_20).
opposite(a,expendable,unexpendable,_20).
opposite(a,cheap,expensive,_20).
opposite(a,experienced,inexperienced,_20).
opposite(a,expired,unexpired,_20).
opposite(a,explicable,inexplicable,_20).
opposite(a,implicit,explicit,_20).
opposite(a,exploited,unexploited,_20).
opposite(a,expressible,inexpressible,_20).
opposite(a,extensile,nonextensile,_20).
opposite(a,extricable,inextricable,_20).
opposite(a,bowed,plucked,_20).
opposite(a,fingered,fingerless,_20).
opposite(a,expansive,unexpansive,_20).
opposite(a,extinguishable,inextinguishable,_20).
opposite(a,internal,external,_20).
opposite(a,outer,inner,_20).
opposite(a,inward,outward,_20).
opposite(a,interior,exterior,_20).
opposite(a,eyed,eyeless,_20).
opposite(a,playable,unplayable,_20).
opposite(a,foul,fair,_20).
opposite(a,fair,unfair,_20).
opposite(a,equitable,inequitable,_20).
opposite(a,faithful,unfaithful,_20).
opposite(a,loyal,disloyal,_20).
opposite(a,fallible,infallible,_20).
opposite(a,familiar,unfamiliar,_20).
opposite(a,fashionable,unfashionable,_20).
opposite(a,stylish,styleless,_20).
opposite(a,slow,fast,_20).
opposite(a,fastidious,unfastidious,_20).
opposite(a,fatty,nonfat,_20).
opposite(a,fatal,nonfatal,_20).
opposite(a,curable,incurable,_20).
opposite(a,fathomable,unfathomable,_20).
opposite(a,favorable,unfavorable,_20).
opposite(a,feathered,unfeathered,_20).
opposite(a,felicitous,infelicitous,_20).
opposite(a,sterile,fertile,_20).
opposite(a,finished,unfinished,_20).
opposite(a,finite,infinite,_20).
opposite(a,last,first,_20).
opposite(a,terminal,intermediate,_20).
opposite(a,first,second,_20).
opposite(a,fissile,nonfissile,_20).
opposite(a,fissionable,nonfissionable,_20).
opposite(a,fit,unfit,_20).
opposite(a,flat,contrasty,_20).
opposite(a,flexible,inflexible,_20).
opposite(a,compromising,uncompromising,_20).
opposite(a,rigid,nonrigid,_20).
opposite(a,adaptable,unadaptable,_20).
opposite(a,orthotropous,campylotropous,_20).
opposite(a,anatropous,amphitropous,_20).
opposite(a,curly,straight,_20).
opposite(a,footed,footless,_20).
opposite(a,toed,toeless,_20).
opposite(a,splayfooted,'pigeon-toed',_20).
opposite(a,aft,fore,_20).
opposite(a,forehand,backhand,_20).
opposite(a,native,adopted,_20).
opposite(a,native,foreign,_20).
opposite(a,native,nonnative,_20).
opposite(a,foreign,domestic,_20).
opposite(a,domestic,undomestic,_20).
opposite(a,forgettable,unforgettable,_20).
opposite(a,forgiving,unforgiving,_20).
opposite(a,formal,informal,_20).
opposite(a,fortunate,unfortunate,_20).
opposite(a,fragrant,malodorous,_20).
opposite(a,odorous,odorless,_20).
opposite(a,scented,scentless,_20).
opposite(a,fixed,unfixed,_20).
opposite(a,free,unfree,_20).
opposite(a,frequent,infrequent,_20).
opposite(a,stale,fresh,_20).
opposite(a,friendly,unfriendly,_20).
opposite(a,frozen,unfrozen,_20).
opposite(a,fruitful,unfruitful,_20).
opposite(a,drained,undrained,_20).
opposite(a,'part-time','full-time',_20).
opposite(a,functional,nonfunctional,_20).
opposite(a,functioning,malfunctioning,_20).
opposite(a,rigged,unrigged,_20).
opposite(a,equipped,unequipped,_20).
opposite(a,fledged,unfledged,_20).
opposite(a,framed,unframed,_20).
opposite(a,furnished,unfurnished,_20).
opposite(a,funded,unfunded,_20).
opposite(a,fueled,unfueled,_20).
opposite(a,specified,unspecified,_20).
opposite(a,geared,ungeared,_20).
opposite(a,specific,nonspecific,_20).
opposite(a,local,national,_20).
opposite(a,branchiate,abranchiate,_20).
opposite(a,unitary,federal,_20).
opposite(a,centralized,decentralized,_20).
opposite(a,technical,nontechnical,_20).
opposite(a,proprietary,nonproprietary,_20).
opposite(a,stingy,generous,_20).
opposite(a,generous,ungenerous,_20).
opposite(a,genuine,counterfeit,_20).
opposite(a,geocentric,heliocentric,_20).
opposite(a,talented,untalented,_20).
opposite(a,glazed,unglazed,_20).
opposite(a,glorious,inglorious,_20).
opposite(a,go,'no-go',_20).
opposite(a,'ill-natured','good-natured',_20).
opposite(a,awkward,graceful,_20).
opposite(a,gracious,ungracious,_20).
opposite(a,sudden,gradual,_20).
opposite(a,grammatical,ungrammatical,_20).
opposite(a,grateful,ungrateful,_20).
opposite(a,haploid,diploid,_20).
opposite(a,haploid,polyploid,_20).
opposite(a,happy,unhappy,_20).
opposite(a,regretful,unregretful,_20).
opposite(a,soft,hard,_20).
opposite(a,softhearted,hardhearted,_20).
opposite(a,alcoholic,nonalcoholic,_20).
opposite(a,harmful,harmless,_20).
opposite(a,harmonious,inharmonious,_20).
opposite(a,healthful,unhealthful,_20).
opposite(a,medical,surgical,_20).
opposite(a,operable,inoperable,_20).
opposite(a,pyretic,antipyretic,_20).
opposite(a,healthy,unhealthy,_20).
opposite(a,dry,phlegmy,_20).
opposite(a,earthly,heavenly,_20).
opposite(a,digestible,indigestible,_20).
opposite(a,headed,headless,_20).
opposite(a,headed,unheaded,_20).
opposite(a,light,heavy,_20).
opposite(a,weighty,weightless,_20).
opposite(a,'light-duty','heavy-duty',_20).
opposite(a,'light-footed','heavy-footed',_20).
opposite(a,heedful,heedless,_20).
opposite(a,enabling,disabling,_20).
opposite(a,helpful,unhelpful,_20).
opposite(a,zygodactyl,heterodactyl,_20).
opposite(a,homogeneous,heterogeneous,_20).
opposite(a,homozygous,heterozygous,_20).
opposite(a,homosexual,heterosexual,_20).
opposite(a,hierarchical,nonhierarchical,_20).
opposite(a,raised,lowered,_20).
opposite(a,'low-tech','high-tech',_20).
opposite(a,necked,neckless,_20).
opposite(a,floored,ceilinged,_20).
opposite(a,'low-sudsing','high-sudsing',_20).
opposite(a,'low-interest','high-interest',_20).
opposite(a,imitative,nonimitative,_20).
opposite(a,echoic,nonechoic,_20).
opposite(a,'low-resolution','high-resolution',_20).
opposite(a,'low-rise','high-rise',_20).
opposite(a,home,away,_20).
opposite(a,homologous,heterologous,_20).
opposite(a,homologous,autologous,_20).
opposite(a,hipped,gabled,_20).
opposite(a,hipped,hipless,_20).
opposite(a,honest,dishonest,_20).
opposite(a,truthful,untruthful,_20).
opposite(a,honorable,dishonorable,_20).
opposite(a,hopeful,hopeless,_20).
opposite(a,institutionalized,noninstitutionalized,_20).
opposite(a,institutional,noninstitutional,_20).
opposite(a,iodinating,'de-iodinating',_20).
opposite(a,consolable,inconsolable,_20).
opposite(a,vertical,horizontal,_20).
opposite(a,erect,unerect,_20).
opposite(a,seated,standing,_20).
opposite(a,hospitable,inhospitable,_20).
opposite(a,hostile,amicable,_20).
opposite(a,hot,cold,_20).
opposite(a,vernal,summery,_20).
opposite(a,vernal,autumnal,_20).
opposite(a,human,nonhuman,_20).
opposite(a,subhuman,superhuman,_20).
opposite(a,humane,inhumane,_20).
opposite(a,humorous,humorless,_20).
opposite(a,hungry,thirsty,_20).
opposite(a,hurried,unhurried,_20).
opposite(a,identifiable,unidentifiable,_20).
opposite(a,immanent,transeunt,_20).
opposite(a,impaired,unimpaired,_20).
opposite(a,important,unimportant,_20).
opposite(a,impressive,unimpressive,_20).
opposite(a,noticeable,unnoticeable,_20).
opposite(a,improved,unimproved,_20).
opposite(a,cleared,uncleared,_20).
opposite(a,inaugural,exaugural,_20).
opposite(a,inboard,outboard,_20).
opposite(a,inbred,outbred,_20).
opposite(a,inclined,disinclined,_20).
opposite(a,outgoing,incoming,_20).
opposite(a,inductive,deductive,_20).
opposite(a,indulgent,nonindulgent,_20).
opposite(a,industrial,nonindustrial,_20).
opposite(a,infectious,noninfectious,_20).
opposite(a,supernal,infernal,_20).
opposite(a,informative,uninformative,_20).
opposite(a,gnostic,agnostic,_20).
opposite(a,informed,uninformed,_20).
opposite(a,ingenuous,disingenuous,_20).
opposite(a,inhabited,uninhabited,_20).
opposite(a,inheritable,noninheritable,_20).
opposite(a,inhibited,uninhibited,_20).
opposite(a,injectable,uninjectable,_20).
opposite(a,injured,uninjured,_20).
opposite(a,guilty,innocent,_20).
opposite(a,inspiring,uninspiring,_20).
opposite(a,instructive,uninstructive,_20).
opposite(a,edifying,unedifying,_20).
opposite(a,enlightening,unenlightening,_20).
opposite(a,segregated,integrated,_20).
opposite(a,integrated,nonintegrated,_20).
opposite(a,blended,unblended,_20).
opposite(a,combined,uncombined,_20).
opposite(a,integrative,disintegrative,_20).
opposite(a,intellectual,nonintellectual,_20).
opposite(a,intelligent,unintelligent,_20).
opposite(a,intelligible,unintelligible,_20).
opposite(a,intended,unintended,_20).
opposite(a,designed,undesigned,_20).
opposite(a,moderating,intensifying,_20).
opposite(a,intraspecies,interspecies,_20).
opposite(a,interested,uninterested,_20).
opposite(a,interesting,uninteresting,_20).
opposite(a,intramural,extramural,_20).
opposite(a,'ultra vires','intra vires',_20).
opposite(a,intrinsic,extrinsic,_20).
opposite(a,introspective,extrospective,_20).
opposite(a,introversive,extroversive,_20).
opposite(a,intrusive,unintrusive,_20).
opposite(a,intrusive,protrusive,_20).
opposite(a,igneous,aqueous,_20).
opposite(a,intrusive,extrusive,_20).
opposite(a,invasive,noninvasive,_20).
opposite(a,invigorating,debilitating,_20).
opposite(a,inviting,uninviting,_20).
opposite(a,'in vivo','in vitro',_20).
opposite(a,ironed,unironed,_20).
opposite(a,wrinkled,unwrinkled,_20).
opposite(a,isotropic,anisotropic,_20).
opposite(a,sad,glad,_20).
opposite(a,joyful,sorrowful,_20).
opposite(a,joyous,joyless,_20).
opposite(a,juicy,juiceless,_20).
opposite(a,just,unjust,_20).
opposite(a,merited,unmerited,_20).
opposite(a,keyed,keyless,_20).
opposite(a,kind,unkind,_20).
opposite(a,knowable,unknowable,_20).
opposite(a,known,unknown,_20).
opposite(a,understood,ununderstood,_20).
opposite(a,labeled,unlabeled,_20).
opposite(a,lamented,unlamented,_20).
opposite(a,laureled,unlaureled,_20).
opposite(a,big,little,_20).
opposite(a,small,large,_20).
opposite(a,lesser,greater,_20).
opposite(a,lawful,unlawful,_20).
opposite(a,leaded,unleaded,_20).
opposite(a,tight,leaky,_20).
opposite(a,caulked,uncaulked,_20).
opposite(a,leavened,unleavened,_20).
opposite(a,legal,illegal,_20).
opposite(a,legible,illegible,_20).
opposite(a,deciphered,undeciphered,_20).
opposite(a,adoptive,biological,_20).
opposite(a,legitimate,illegitimate,_20).
opposite(a,catarrhine,leptorrhine,_20).
opposite(a,eusporangiate,leptosporangiate,_20).
opposite(a,like,unlike,_20).
opposite(a,alike,unalike,_20).
opposite(a,likely,unlikely,_20).
opposite(a,probable,improbable,_20).
opposite(a,limbed,limbless,_20).
opposite(a,limited,unlimited,_20).
opposite(a,lineal,collateral,_20).
opposite(a,linear,nonlinear,_20).
opposite(a,lined,unlined,_20).
opposite(a,listed,unlisted,_20).
opposite(a,literal,figurative,_20).
opposite(a,literate,illiterate,_20).
opposite(a,live,recorded,_20).
opposite(a,livable,unlivable,_20).
opposite(a,liveried,unliveried,_20).
opposite(a,loaded,unloaded,_20).
opposite(a,loamy,loamless,_20).
opposite(a,ecdemic,epidemic,_20).
opposite(a,gloved,gloveless,_20).
opposite(a,hatted,hatless,_20).
opposite(a,guided,unguided,_20).
opposite(a,legged,legless,_20).
opposite(a,logical,illogical,_20).
opposite(a,extended,unextended,_20).
opposite(a,mini,midi,_20).
opposite(a,mini,maxi,_20).
opposite(a,lossy,lossless,_20).
opposite(a,long,short,_20).
opposite(a,crosswise,lengthwise,_20).
opposite(a,lidded,lidless,_20).
opposite(a,constricted,unconstricted,_20).
opposite(a,lost,found,_20).
opposite(a,lost,saved,_20).
opposite(a,soft,loud,_20).
opposite(a,piano,forte,_20).
opposite(a,soft,hardened,_20).
opposite(a,lovable,hateful,_20).
opposite(a,liked,disliked,_20).
opposite(a,loved,unloved,_20).
opposite(a,loving,unloving,_20).
opposite(a,lucky,unlucky,_20).
opposite(a,made,unmade,_20).
opposite(a,magnetic,antimagnetic,_20).
opposite(a,magnetic,geographic,_20).
opposite(a,magnetic,nonmagnetic,_20).
opposite(a,minor,major,_20).
opposite(a,minuscule,majuscule,_20).
opposite(a,manageable,unmanageable,_20).
opposite(a,manly,unmanly,_20).
opposite(a,male,androgynous,_20).
opposite(a,manned,unmanned,_20).
opposite(a,marked,unmarked,_20).
opposite(a,branded,unbranded,_20).
opposite(a,married,unmarried,_20).
opposite(a,mated,unmated,_20).
opposite(a,feminine,masculine,_20).
opposite(a,womanly,unwomanly,_20).
opposite(a,matched,mismatched,_20).
opposite(a,mature,immature,_20).
opposite(a,ripe,green,_20).
opposite(a,seasonal,'year-round',_20).
opposite(a,seasonable,unseasonable,_20).
opposite(a,seasoned,unseasoned,_20).
opposite(a,premature,'full-term',_20).
opposite(a,minimal,maximal,_20).
opposite(a,meaningful,meaningless,_20).
opposite(a,measurable,immeasurable,_20).
opposite(a,meaty,meatless,_20).
opposite(a,mechanical,nonmechanical,_20).
opposite(a,melodious,unmelodious,_20).
opposite(a,tuneful,tuneless,_20).
opposite(a,membered,memberless,_20).
opposite(a,mined,unmined,_20).
opposite(a,musical,unmusical,_20).
opposite(a,melted,unmelted,_20).
opposite(a,merciful,merciless,_20).
opposite(a,metabolic,ametabolic,_20).
opposite(a,mild,intense,_20).
opposite(a,intensive,extensive,_20).
opposite(a,involved,uninvolved,_20).
opposite(a,military,unmilitary,_20).
opposite(a,mitigated,unmitigated,_20).
opposite(a,tempered,untempered,_20).
opposite(a,mobile,immobile,_20).
opposite(a,portable,unportable,_20).
opposite(a,removable,irremovable,_20).
opposite(a,metallic,nonmetallic,_20).
opposite(a,metamorphic,nonmetamorphic,_20).
opposite(a,moderate,immoderate,_20).
opposite(a,modern,nonmodern,_20).
opposite(a,modest,immodest,_20).
opposite(a,modified,unmodified,_20).
opposite(a,modulated,unmodulated,_20).
opposite(a,molar,molecular,_20).
opposite(a,diclinous,monoclinous,_20).
opposite(a,dioecious,monoecious,_20).
opposite(a,polyphonic,monophonic,_20).
opposite(a,polygamous,monogamous,_20).
opposite(a,monolingual,multilingual,_20).
opposite(a,polyvalent,monovalent,_20).
opposite(a,univalent,multivalent,_20).
opposite(a,bivalent,univalent,_20).
opposite(a,monotonic,nonmonotonic,_20).
opposite(a,moral,immoral,_20).
opposite(a,licit,illicit,_20).
opposite(a,principled,unprincipled,_20).
opposite(a,few,many,_20).
opposite(a,more,less,_20).
opposite(a,most,least,_20).
opposite(a,more,fewer,_20).
opposite(a,most,fewest,_20).
opposite(a,mortal,immortal,_20).
opposite(a,motivated,unmotivated,_20).
opposite(a,motorized,unmotorized,_20).
opposite(a,moved,unmoved,_20).
opposite(a,moving,unmoving,_20).
opposite(a,moving,nonmoving,_20).
opposite(a,mown,unmown,_20).
opposite(a,seamanlike,unseamanlike,_20).
opposite(a,continental,intercontinental,_20).
opposite(a,national,international,_20).
opposite(a,intrastate,interstate,_20).
opposite(a,natural,unnatural,_20).
opposite(a,natural,artificial,_20).
opposite(a,natural,supernatural,_20).
opposite(a,ultimate,proximate,_20).
opposite(a,necessary,unnecessary,_20).
opposite(a,net,gross,_20).
opposite(a,neurotic,unneurotic,_20).
opposite(a,nice,nasty,_20).
opposite(a,nidifugous,nidicolous,_20).
opposite(a,noble,ignoble,_20).
opposite(a,noble,lowborn,_20).
opposite(a,normal,abnormal,_20).
opposite(a,hypotensive,hypertensive,_20).
opposite(a,normal,paranormal,_20).
opposite(a,south,north,_20).
opposite(a,southern,northern,_20).
opposite(a,nosed,noseless,_20).
opposite(a,noticed,unnoticed,_20).
opposite(a,detected,undetected,_20).
opposite(a,determined,undetermined,_20).
opposite(a,noxious,innocuous,_20).
opposite(a,obedient,disobedient,_20).
opposite(a,obtrusive,unobtrusive,_20).
opposite(a,objective,subjective,_20).
opposite(a,obligated,unobligated,_20).
opposite(a,obligate,facultative,_20).
opposite(a,obvious,unobvious,_20).
opposite(a,obstructed,unobstructed,_20).
opposite(a,occupied,unoccupied,_20).
opposite(a,offensive,inoffensive,_20).
opposite(a,savory,unsavory,_20).
opposite(a,offensive,defensive,_20).
opposite(a,offending,unoffending,_20).
opposite(a,apologetic,unapologetic,_20).
opposite(a,official,unofficial,_20).
opposite(a,confirmed,unconfirmed,_20).
opposite(a,established,unestablished,_20).
opposite(a,conditioned,unconditioned,_20).
opposite(a,'on-site','off-site',_20).
opposite(a,onstage,offstage,_20).
opposite(a,'on-street','off-street',_20).
opposite(a,old,new,_20).
opposite(a,'one-piece','three-piece',_20).
opposite(a,'two-piece','one-piece',_20).
opposite(a,'on-line','off-line',_20).
opposite(a,on,off,_20).
opposite(a,onside,offside,_20).
opposite(a,open,closed,_20).
opposite(a,spaced,unspaced,_20).
opposite(a,enclosed,unenclosed,_20).
opposite(a,tanned,untanned,_20).
opposite(a,tapped,untapped,_20).
opposite(a,operational,nonoperational,_20).
opposite(a,opportune,inopportune,_20).
opposite(a,opposable,unopposable,_20).
opposite(a,opposed,unopposed,_20).
opposite(a,opposite,alternate,_20).
opposite(a,optimistic,pessimistic,_20).
opposite(a,oral,aboral,_20).
opposite(a,actinal,abactinal,_20).
opposite(a,orderly,disorderly,_20).
opposite(a,ordered,disordered,_20).
opposite(a,organized,disorganized,_20).
opposite(a,organized,unorganized,_20).
opposite(a,structured,unstructured,_20).
opposite(a,ordinary,extraordinary,_20).
opposite(a,organic,inorganic,_20).
opposite(a,holistic,atomistic,_20).
opposite(a,arranged,disarranged,_20).
opposite(a,oriented,unoriented,_20).
opposite(a,orienting,disorienting,_20).
opposite(a,original,unoriginal,_20).
opposite(a,orthodox,unorthodox,_20).
opposite(a,indoor,outdoor,_20).
opposite(a,bare,covered,_20).
opposite(a,coated,uncoated,_20).
opposite(a,roofed,roofless,_20).
opposite(a,leafy,leafless,_20).
opposite(a,lipped,lipless,_20).
opposite(a,overt,covert,_20).
opposite(a,paid,unpaid,_20).
opposite(a,painful,painless,_20).
opposite(a,painted,unpainted,_20).
opposite(a,delineated,undelineated,_20).
opposite(a,paintable,unpaintable,_20).
opposite(a,palatable,unpalatable,_20).
opposite(a,palpable,impalpable,_20).
opposite(a,parallel,perpendicular,_20).
opposite(a,oblique,parallel,_20).
opposite(a,pardonable,unpardonable,_20).
opposite(a,excusable,inexcusable,_20).
opposite(a,filial,parental,_20).
opposite(a,partial,impartial,_20).
opposite(a,particulate,nonparticulate,_20).
opposite(a,passable,impassable,_20).
opposite(a,passionate,passionless,_20).
opposite(a,past,present,_20).
opposite(a,born,unborn,_20).
opposite(a,parented,unparented,_20).
opposite(a,paternal,maternal,_20).
opposite(a,wifely,husbandly,_20).
opposite(a,patient,impatient,_20).
opposite(a,patriarchal,matriarchal,_20).
opposite(a,patronized,unpatronized,_20).
opposite(a,packaged,unpackaged,_20).
opposite(a,paved,unpaved,_20).
opposite(a,patriotic,unpatriotic,_20).
opposite(a,peaceful,unpeaceful,_20).
opposite(a,penitent,impenitent,_20).
opposite(a,repentant,unrepentant,_20).
opposite(a,perceptive,unperceptive,_20).
opposite(a,perceptible,imperceptible,_20).
opposite(a,perfect,imperfect,_20).
opposite(a,perishable,imperishable,_20).
opposite(a,permanent,impermanent,_20).
opposite(a,caducous,persistent,_20).
opposite(a,reversible,irreversible,_20).
opposite(a,reversible,nonreversible,_20).
opposite(a,revocable,irrevocable,_20).
opposite(a,permissible,impermissible,_20).
opposite(a,admissible,inadmissible,_20).
opposite(a,permissive,unpermissive,_20).
opposite(a,perplexed,unperplexed,_20).
opposite(a,personal,impersonal,_20).
opposite(a,persuasive,dissuasive,_20).
opposite(a,penetrable,impenetrable,_20).
opposite(a,permeable,impermeable,_20).
opposite(a,pervious,impervious,_20).
opposite(a,petalous,apetalous,_20).
opposite(a,puncturable,punctureless,_20).
opposite(a,psychoactive,nonpsychoactive,_20).
opposite(a,mental,physical,_20).
opposite(a,polytheistic,monotheistic,_20).
opposite(a,pious,impious,_20).
opposite(a,secular,religious,_20).
opposite(a,religious,irreligious,_20).
opposite(a,placable,implacable,_20).
opposite(a,plain,patterned,_20).
opposite(a,plain,fancy,_20).
opposite(a,planned,unplanned,_20).
opposite(a,studied,unstudied,_20).
opposite(a,plausible,implausible,_20).
opposite(a,pleasant,unpleasant,_20).
opposite(a,pleased,displeased,_20).
opposite(a,pleasing,displeasing,_20).
opposite(a,pointed,pointless,_20).
opposite(a,acute,obtuse,_20).
opposite(a,polished,unpolished,_20).
opposite(a,politic,impolitic,_20).
opposite(a,political,nonpolitical,_20).
opposite(a,ponderable,imponderable,_20).
opposite(a,popular,unpopular,_20).
opposite(a,pro,anti,_20).
opposite(a,plus,minus,_20).
opposite(a,possible,impossible,_20).
opposite(a,potent,impotent,_20).
opposite(a,powerful,powerless,_20).
opposite(a,powered,unpowered,_20).
opposite(a,'low-tension','high-tension',_20).
opposite(a,influential,uninfluential,_20).
opposite(a,placental,aplacental,_20).
opposite(a,planted,unplanted,_20).
opposite(a,plowed,unplowed,_20).
opposite(a,cultivated,uncultivated,_20).
opposite(a,potted,unpotted,_20).
opposite(a,practical,impractical,_20).
opposite(a,precise,imprecise,_20).
opposite(a,retarded,precocious,_20).
opposite(a,predictable,unpredictable,_20).
opposite(a,premeditated,unpremeditated,_20).
opposite(a,prepared,unprepared,_20).
opposite(a,prescription,nonprescription,_20).
opposite(a,ostentatious,unostentatious,_20).
opposite(a,pretentious,unpretentious,_20).
opposite(a,primary,secondary,_20).
opposite(a,basic,incidental,_20).
opposite(a,public,private,_20).
opposite(a,inclusive,exclusive,_20).
opposite(a,privileged,underprivileged,_20).
opposite(a,productive,unproductive,_20).
opposite(a,generative,consumptive,_20).
opposite(a,reproducible,unreproducible,_20).
opposite(a,professional,nonprofessional,_20).
opposite(a,professional,unprofessional,_20).
opposite(a,profitable,unprofitable,_20).
opposite(a,profound,superficial,_20).
opposite(a,prognathous,opisthognathous,_20).
opposite(a,regressive,progressive,_20).
opposite(a,pronounceable,unpronounceable,_20).
opposite(a,proper,improper,_20).
opposite(a,prophetic,unprophetic,_20).
opposite(a,prospective,retrospective,_20).
opposite(a,protected,unprotected,_20).
opposite(a,protective,unprotective,_20).
opposite(a,proud,humble,_20).
opposite(a,proved,unproved,_20).
opposite(a,provident,improvident,_20).
opposite(a,provocative,unprovocative,_20).
opposite(a,prudent,imprudent,_20).
opposite(a,punctual,unpunctual,_20).
opposite(a,punished,unpunished,_20).
opposite(a,punitive,rehabilitative,_20).
opposite(a,purebred,crossbred,_20).
opposite(a,pure,impure,_20).
opposite(a,contaminated,uncontaminated,_20).
opposite(a,purposeful,purposeless,_20).
opposite(a,qualified,unqualified,_20).
opposite(a,trained,untrained,_20).
opposite(a,qualitative,quantitative,_20).
opposite(a,questionable,unquestionable,_20).
opposite(a,quiet,noisy,_20).
opposite(a,restful,restless,_20).
opposite(a,quiet,unquiet,_20).
opposite(a,random,nonrandom,_20).
opposite(a,rational,irrational,_20).
opposite(a,racial,nonracial,_20).
opposite(a,reactive,unreactive,_20).
opposite(a,ready,unready,_20).
opposite(a,real,unreal,_20).
opposite(a,real,nominal,_20).
opposite(a,realistic,unrealistic,_20).
opposite(a,reasonable,unreasonable,_20).
opposite(a,reciprocal,nonreciprocal,_20).
opposite(a,refined,unrefined,_20).
opposite(a,processed,unprocessed,_20).
opposite(a,treated,untreated,_20).
opposite(a,oiled,unoiled,_20).
opposite(a,recoverable,unrecoverable,_20).
opposite(a,regenerate,unregenerate,_20).
opposite(a,registered,unregistered,_20).
opposite(a,regular,irregular,_20).
opposite(a,regulated,unregulated,_20).
opposite(a,remediable,irremediable,_20).
opposite(a,renewable,unrenewable,_20).
opposite(a,rentable,unrentable,_20).
opposite(a,reparable,irreparable,_20).
opposite(a,repeatable,unrepeatable,_20).
opposite(a,quotable,unquotable,_20).
opposite(a,repetitive,nonrepetitive,_20).
opposite(a,printable,unprintable,_20).
opposite(a,requested,unrequested,_20).
opposite(a,rhymed,unrhymed,_20).
opposite(a,uniform,multiform,_20).
opposite(a,periodic,aperiodic,_20).
opposite(a,related,unrelated,_20).
opposite(a,relevant,irrelevant,_20).
opposite(a,mindful,unmindful,_20).
opposite(a,replaceable,irreplaceable,_20).
opposite(a,representational,nonrepresentational,_20).
opposite(a,representative,nonrepresentative,_20).
opposite(a,reputable,disreputable,_20).
opposite(a,receptive,unreceptive,_20).
opposite(a,reconcilable,irreconcilable,_20).
opposite(a,reserved,unreserved,_20).
opposite(a,resistible,irresistible,_20).
opposite(a,resolute,irresolute,_20).
opposite(a,respectable,unrespectable,_20).
opposite(a,respectful,disrespectful,_20).
opposite(a,responsible,irresponsible,_20).
opposite(a,responsive,unresponsive,_20).
opposite(a,restrained,unrestrained,_20).
opposite(a,restricted,unrestricted,_20).
opposite(a,restrictive,unrestrictive,_20).
opposite(a,retentive,unretentive,_20).
opposite(a,reticulate,nonreticulate,_20).
opposite(a,retractile,nonretractile,_20).
opposite(a,reflective,nonreflective,_20).
opposite(a,reflected,unreflected,_20).
opposite(a,reverberant,unreverberant,_20).
opposite(a,reverent,irreverent,_20).
opposite(a,revived,unrevived,_20).
opposite(a,awakened,unawakened,_20).
opposite(a,awed,unawed,_20).
opposite(a,revolutionary,counterrevolutionary,_20).
opposite(a,rewarding,unrewarding,_20).
opposite(a,rhetorical,unrhetorical,_20).
opposite(a,rhythmical,unrhythmical,_20).
opposite(a,ribbed,ribless,_20).
opposite(a,moneyed,moneyless,_20).
opposite(a,solvent,insolvent,_20).
opposite(a,rich,lean,_20).
opposite(a,rimmed,rimless,_20).
opposite(a,handed,handless,_20).
opposite(a,handled,handleless,_20).
opposite(a,'right-handed',ambidextrous,_20).
opposite(a,'left-handed','right-handed',_20).
opposite(a,right,center,_20).
opposite(a,horned,hornless,_20).
opposite(a,righteous,unrighteous,_20).
opposite(a,frail,robust,_20).
opposite(a,round,square,_20).
opposite(a,rounded,angular,_20).
opposite(a,oblate,prolate,_20).
opposite(a,urban,rural,_20).
opposite(a,rusted,rustless,_20).
opposite(a,holy,unholy,_20).
opposite(a,sacred,profane,_20).
opposite(a,sadistic,masochistic,_20).
opposite(a,safe,dangerous,_20).
opposite(a,salable,unsalable,_20).
opposite(a,same,different,_20).
opposite(a,same,other,_20).
opposite(a,similar,dissimilar,_20).
opposite(a,sane,insane,_20).
opposite(a,satiate,insatiate,_20).
opposite(a,sarcastic,unsarcastic,_20).
opposite(a,satisfactory,unsatisfactory,_20).
opposite(a,scalable,unscalable,_20).
opposite(a,scholarly,unscholarly,_20).
opposite(a,scientific,unscientific,_20).
opposite(a,scrupulous,unscrupulous,_20).
opposite(a,conscientious,unconscientious,_20).
opposite(a,sealed,unsealed,_20).
opposite(a,wrapped,unwrapped,_20).
opposite(a,seaworthy,unseaworthy,_20).
opposite(a,airworthy,unairworthy,_20).
opposite(a,concealed,unconcealed,_20).
opposite(a,revealing,concealing,_20).
opposite(a,sectarian,nonsectarian,_20).
opposite(a,secure,insecure,_20).
opposite(a,fastened,unfastened,_20).
opposite(a,insured,uninsured,_20).
opposite(a,seductive,unseductive,_20).
opposite(a,selfish,unselfish,_20).
opposite(a,senior,junior,_20).
opposite(a,sensational,unsensational,_20).
opposite(a,sensible,insensible,_20).
opposite(a,sensitive,insensitive,_20).
opposite(a,sensitizing,desensitizing,_20).
opposite(a,sensory,extrasensory,_20).
opposite(a,sent,unsent,_20).
opposite(a,joint,separate,_20).
opposite(a,sanitary,unsanitary,_20).
opposite(a,septic,antiseptic,_20).
opposite(a,germy,germfree,_20).
opposite(a,purifying,adulterating,_20).
opposite(a,serious,frivolous,_20).
opposite(a,playful,unplayful,_20).
opposite(a,selected,unselected,_20).
opposite(a,serviceable,unserviceable,_20).
opposite(a,settled,unsettled,_20).
opposite(a,migratory,nonmigratory,_20).
opposite(a,sexy,unsexy,_20).
opposite(a,sexual,asexual,_20).
opposite(a,castrated,uncastrated,_20).
opposite(a,aphrodisiac,anaphrodisiac,_20).
opposite(a,estrous,anestrous,_20).
opposite(a,shapely,unshapely,_20).
opposite(a,breasted,breastless,_20).
opposite(a,formed,unformed,_20).
opposite(a,shared,unshared,_20).
opposite(a,shaven,unshaven,_20).
opposite(a,sheared,unsheared,_20).
opposite(a,sheathed,unsheathed,_20).
opposite(a,shockable,unshockable,_20).
opposite(a,shod,unshod,_20).
opposite(a,calced,discalced,_20).
opposite(a,farsighted,nearsighted,_20).
opposite(a,shrinkable,unshrinkable,_20).
opposite(a,blind,sighted,_20).
opposite(a,signed,unsigned,_20).
opposite(a,significant,insignificant,_20).
opposite(a,significant,nonsignificant,_20).
opposite(a,silenced,unsilenced,_20).
opposite(a,simple,compound,_20).
opposite(a,simple,complex,_20).
opposite(a,sincere,insincere,_20).
opposite(a,ordinal,cardinal,_20).
opposite(a,scripted,unscripted,_20).
opposite(a,sinkable,unsinkable,_20).
opposite(a,single,multiple,_20).
opposite(a,single,double,_20).
opposite(a,'true-false','multiple-choice',_20).
opposite(a,multilane,'single-lane',_20).
opposite(a,sized,unsized,_20).
opposite(a,skilled,unskilled,_20).
opposite(a,verbal,numerical,_20).
opposite(a,fine,coarse,_20).
opposite(a,smoky,smokeless,_20).
opposite(a,slippery,nonslippery,_20).
opposite(a,lubricated,unlubricated,_20).
opposite(a,furrowed,unfurrowed,_20).
opposite(a,rifled,unrifled,_20).
opposite(a,social,unsocial,_20).
opposite(a,accompanied,unaccompanied,_20).
opposite(a,gregarious,ungregarious,_20).
opposite(a,seamed,seamless,_20).
opposite(a,seeded,unseeded,_20).
opposite(a,seedy,seedless,_20).
opposite(a,shuttered,unshuttered,_20).
opposite(a,sleeved,sleeveless,_20).
opposite(a,sociable,unsociable,_20).
opposite(a,sold,unsold,_20).
opposite(a,soled,soleless,_20).
opposite(a,solid,liquid,_20).
opposite(a,solid,gaseous,_20).
opposite(a,solid,hollow,_20).
opposite(a,soluble,insoluble,_20).
opposite(a,solved,unsolved,_20).
opposite(a,no,some,_20).
opposite(a,naive,sophisticated,_20).
opposite(a,sound,unsound,_20).
opposite(a,effervescent,noneffervescent,_20).
opposite(a,still,sparkling,_20).
opposite(a,specialized,unspecialized,_20).
opposite(a,spinous,spineless,_20).
opposite(a,spirited,spiritless,_20).
opposite(a,induced,spontaneous,_20).
opposite(a,spoken,written,_20).
opposite(a,voiced,unvoiced,_20).
opposite(a,written,unwritten,_20).
opposite(a,vocalic,consonantal,_20).
opposite(a,stoppable,unstoppable,_20).
opposite(a,syllabic,nonsyllabic,_20).
opposite(a,syllabic,accentual,_20).
opposite(a,stable,unstable,_20).
opposite(a,legato,staccato,_20).
opposite(a,staged,unstaged,_20).
opposite(a,standard,nonstandard,_20).
opposite(a,starchy,starchless,_20).
opposite(a,starry,starless,_20).
opposite(a,nourished,malnourished,_20).
opposite(a,steady,unsteady,_20).
opposite(a,stemmed,stemless,_20).
opposite(a,stimulating,unstimulating,_20).
opposite(a,depressant,stimulative,_20).
opposite(a,stomatous,astomatous,_20).
opposite(a,coiled,uncoiled,_20).
opposite(a,stressed,unstressed,_20).
opposite(a,tonic,atonic,_20).
opposite(a,weak,strong,_20).
opposite(a,docile,stubborn,_20).
opposite(a,subordinate,insubordinate,_20).
opposite(a,successful,unsuccessful,_20).
opposite(a,sufficient,insufficient,_20).
opposite(a,sugary,sugarless,_20).
opposite(a,subjacent,superjacent,_20).
opposite(a,supervised,unsupervised,_20).
opposite(a,supported,unsupported,_20).
opposite(a,assisted,unassisted,_20).
opposite(a,supportive,unsupportive,_20).
opposite(a,surmountable,insurmountable,_20).
opposite(a,surprised,unsurprised,_20).
opposite(a,surprising,unsurprising,_20).
opposite(a,susceptible,unsusceptible,_20).
opposite(a,impressionable,unimpressionable,_20).
opposite(a,exempt,nonexempt,_20).
opposite(a,scheduled,unscheduled,_20).
opposite(a,dry,sweet,_20).
opposite(a,soured,unsoured,_20).
opposite(a,suspected,unsuspected,_20).
opposite(a,swept,unswept,_20).
opposite(a,sworn,unsworn,_20).
opposite(a,symmetrical,asymmetrical,_20).
opposite(a,zygomorphic,actinomorphic,_20).
opposite(a,sympathetic,unsympathetic,_20).
opposite(a,sympatric,allopatric,_20).
opposite(a,synchronic,diachronic,_20).
opposite(a,synchronous,asynchronous,_20).
opposite(a,syndetic,asyndetic,_20).
opposite(a,synonymous,antonymous,_20).
opposite(a,systematic,unsystematic,_20).
opposite(a,voluble,taciturn,_20).
opposite(a,tactful,tactless,_20).
opposite(a,wild,tame,_20).
opposite(a,tangible,intangible,_20).
opposite(a,tasteful,tasteless,_20).
opposite(a,taxable,nontaxable,_20).
opposite(a,temperate,intemperate,_20).
opposite(a,tense,relaxed,_20).
opposite(a,territorial,extraterritorial,_20).
opposite(a,territorial,nonterritorial,_20).
opposite(a,thermosetting,thermoplastic,_20).
opposite(a,thin,thick,_20).
opposite(a,thinkable,unthinkable,_20).
opposite(a,thoughtful,thoughtless,_20).
opposite(a,thrifty,wasteful,_20).
opposite(a,tidy,untidy,_20).
opposite(a,groomed,ungroomed,_20).
opposite(a,combed,uncombed,_20).
opposite(a,timbered,untimbered,_20).
opposite(a,toned,toneless,_20).
opposite(a,tongued,tongueless,_20).
opposite(a,tipped,untipped,_20).
opposite(a,tired,rested,_20).
opposite(a,tolerable,intolerable,_20).
opposite(a,tolerant,intolerant,_20).
opposite(a,tonal,atonal,_20).
opposite(a,toothed,toothless,_20).
opposite(a,top,side,_20).
opposite(a,topped,topless,_20).
opposite(a,bottomed,bottomless,_20).
opposite(a,'top-down','bottom-up',_20).
opposite(a,polar,equatorial,_20).
opposite(a,testate,intestate,_20).
opposite(a,touched,untouched,_20).
opposite(a,tough,tender,_20).
opposite(a,toxic,nontoxic,_20).
opposite(a,tractable,intractable,_20).
opposite(a,'a la carte','table d\'hote',_20).
opposite(a,traceable,untraceable,_20).
opposite(a,tracked,trackless,_20).
opposite(a,traveled,untraveled,_20).
opposite(a,trimmed,untrimmed,_20).
opposite(a,troubled,untroubled,_20).
opposite(a,true,false,_20).
opposite(a,trustful,distrustful,_20).
opposite(a,trustworthy,untrustworthy,_20).
opposite(a,tubed,tubeless,_20).
opposite(a,tucked,untucked,_20).
opposite(a,turned,unturned,_20).
opposite(a,typical,atypical,_20).
opposite(a,overhand,underhand,_20).
opposite(a,surface,subsurface,_20).
opposite(a,surface,overhead,_20).
opposite(a,submersible,nonsubmersible,_20).
opposite(a,tearful,tearless,_20).
opposite(a,union,nonunion,_20).
opposite(a,uniparous,multiparous,_20).
opposite(a,bipolar,unipolar,_20).
opposite(a,united,divided,_20).
opposite(a,adnate,connate,_20).
opposite(a,bivalve,univalve,_20).
opposite(a,ascending,descending,_20).
opposite(a,rising,falling,_20).
opposite(a,climactic,anticlimactic,_20).
opposite(a,upmarket,downmarket,_20).
opposite(a,transitive,intransitive,_20).
opposite(a,translatable,untranslatable,_20).
opposite(a,ungulate,unguiculate,_20).
opposite(a,up,down,_20).
opposite(a,upstage,downstage,_20).
opposite(a,upstairs,downstairs,_20).
opposite(a,upstream,downstream,_20).
opposite(a,uptown,downtown,_20).
opposite(a,used,misused,_20).
opposite(a,useful,useless,_20).
opposite(a,utopian,dystopian,_20).
opposite(a,valid,invalid,_20).
opposite(a,valuable,worthless,_20).
opposite(a,variable,invariable,_20).
opposite(a,varied,unvaried,_20).
opposite(a,veiled,unveiled,_20).
opposite(a,ventilated,unventilated,_20).
opposite(a,vertebrate,invertebrate,_20).
opposite(a,violable,inviolable,_20).
opposite(a,violent,nonviolent,_20).
opposite(a,wicked,virtuous,_20).
opposite(a,visible,invisible,_20).
opposite(a,viviparous,ovoviviparous,_20).
opposite(a,oviparous,viviparous,_20).
opposite(a,volatile,nonvolatile,_20).
opposite(a,voluntary,involuntary,_20).
opposite(a,vulnerable,invulnerable,_20).
opposite(a,wanted,unwanted,_20).
opposite(a,'warm-blooded','cold-blooded',_20).
opposite(a,warmhearted,coldhearted,_20).
opposite(a,washable,nonwashable,_20).
opposite(a,waxed,unwaxed,_20).
opposite(a,increasing,decreasing,_20).
opposite(a,inflationary,deflationary,_20).
opposite(a,weaned,unweaned,_20).
opposite(a,wearable,unwearable,_20).
opposite(a,weedy,weedless,_20).
opposite(a,welcome,unwelcome,_20).
opposite(a,ill,well,_20).
opposite(a,hydrous,anhydrous,_20).
opposite(a,wheeled,wheelless,_20).
opposite(a,'blue-collar','white-collar',_20).
opposite(a,wholesome,unwholesome,_20).
opposite(a,wieldy,unwieldy,_20).
opposite(a,wigged,wigless,_20).
opposite(a,willing,unwilling,_20).
opposite(a,winged,wingless,_20).
opposite(a,wired,wireless,_20).
opposite(a,wise,foolish,_20).
opposite(a,wooded,unwooded,_20).
opposite(a,woody,nonwoody,_20).
opposite(a,worldly,unworldly,_20).
opposite(a,woven,unwoven,_20).
opposite(a,new,worn,_20).
opposite(a,worthy,unworthy,_20).
opposite(a,xeric,hydric,_20).
opposite(a,xeric,mesic,_20).
opposite(a,zonal,azonal,_20).
opposite(a,acrocarpous,pleurocarpous,_20).
opposite(a,fossorial,cursorial,_20).
opposite(a,homocercal,heterocercal,_20).
opposite(a,webbed,unwebbed,_20).
opposite(a,faceted,unfaceted,_20).
opposite(a,ipsilateral,contralateral,_20).
opposite(a,salient,'re-entrant',_20).
opposite(a,proactive,retroactive,_20).
opposite(a,'rh-positive','rh-negative',_20).
opposite(a,categorematic,syncategorematic,_20).
opposite(a,nomothetic,idiographic,_20).
opposite(a,'pro-life','pro-choice',_20).
opposite(a,baptized,unbaptized,_20).
opposite(a,benign,malignant,_20).
opposite(a,calcifugous,calcicolous,_20).
opposite(a,invertible,'non-invertible',_20).
opposite(a,immunodeficient,immunocompetent,_20).
opposite(a,xenogeneic,allogeneic,_20).
opposite(a,'long-spurred','short-spurred',_20).
opposite(a,shelled,unshelled,_20).
opposite(a,jawed,jawless,_20).
opposite(a,skinned,skinless,_20).
opposite(a,flowering,flowerless,_20).
opposite(a,adient,abient,_20).
opposite(a,anodic,cathodic,_20).
opposite(a,autotrophic,heterotrophic,_20).
opposite(a,bracteate,ebracteate,_20).
opposite(a,intracellular,extracellular,_20).
opposite(a,eremitic,cenobitic,_20).
opposite(a,cenogenetic,palingenetic,_20).
opposite(a,chromatinic,achromatinic,_20).
opposite(a,directional,omnidirectional,_20).
opposite(a,eugenic,dysgenic,_20).
opposite(a,febrile,afebrile,_20).
opposite(a,fictional,nonfictional,_20).
opposite(a,fretted,unfretted,_20).
opposite(a,harmonic,nonharmonic,_20).
opposite(a,ionic,nonionic,_20).
opposite(a,myelinated,unmyelinated,_20).
opposite(a,passerine,nonpasserine,_20).
opposite(a,photosynthetic,nonphotosynthetic,_20).
opposite(a,ruminant,nonruminant,_20).
opposite(a,spherical,nonspherical,_20).
opposite(a,steroidal,nonsteroidal,_20).
opposite(a,suppurative,nonsuppurative,_20).
opposite(a,syntagmatic,paradigmatic,_20).
opposite(a,thematic,unthematic,_20).
opposite(a,thermal,nonthermal,_20).
opposite(a,vocal,instrumental,_20).
opposite(a,hydrostatic,hydrokinetic,_20).
opposite(a,spatial,nonspatial,_20).
opposite(a,linguistic,nonlinguistic,_20).
opposite(a,caudal,cephalic,_20).
opposite(a,financial,nonfinancial,_20).
opposite(a,eukaryotic,prokaryotic,_20).
opposite(a,eucaryotic,procaryotic,_20).
opposite(a,vascular,avascular,_20).
opposite(a,uninucleate,multinucleate,_20).
opposite(a,surgical,nonsurgical,_20).
opposite(a,exocrine,endocrine,_20).
opposite(a,historical,ahistorical,_20).
opposite(a,'pro-American','anti-American',_20).
opposite(a,anionic,cationic,_20).
opposite(a,accusatorial,inquisitorial,_20).
opposite(a,prenuptial,postnuptial,_20).
opposite(a,intradepartmental,interdepartmental,_20).
opposite(a,allopathic,homeopathic,_20).
opposite(a,translational,nontranslational,_20).
opposite(a,avenged,unavenged,_20).
opposite(a,collected,uncollected,_20).
opposite(a,gathered,ungathered,_20).
opposite(a,contested,uncontested,_20).
opposite(a,filled,unfilled,_20).
opposite(a,malted,unmalted,_20).
opposite(a,posed,unposed,_20).
opposite(a,saponified,unsaponified,_20).
opposite(r,kindly,unkindly,_20).
opposite(r,significantly,insignificantly,_20).
opposite(r,wholly,partly,_20).
opposite(r,perfectly,imperfectly,_20).
opposite(r,well,badly,_20).
opposite(r,advantageously,disadvantageously,_20).
opposite(r,satisfactorily,unsatisfactorily,_20).
opposite(r,ever,never,_20).
opposite(r,conventionally,unconventionally,_20).
opposite(r,still,'no longer',_20).
opposite(r,frequently,infrequently,_20).
opposite(r,often,rarely,_20).
opposite(r,reasonably,unreasonably,_20).
opposite(r,moderately,immoderately,_20).
opposite(r,naturally,unnaturally,_20).
opposite(r,generally,specifically,_20).
opposite(r,fortunately,unfortunately,_20).
opposite(r,luckily,unluckily,_20).
opposite(r,sadly,happily,_20).
opposite(r,happily,unhappily,_20).
opposite(r,'by hand','by machine',_20).
opposite(r,acceptably,unacceptably,_20).
opposite(r,tolerably,intolerably,_20).
opposite(r,adroitly,maladroitly,_20).
opposite(r,'by no means','by all means',_20).
opposite(r,directly,indirectly,_20).
opposite(r,intentionally,unintentionally,_20).
opposite(r,deliberately,accidentally,_20).
opposite(r,softly,loudly,_20).
opposite(r,back,ahead,_20).
opposite(r,overtly,covertly,_20).
opposite(r,actively,passively,_20).
opposite(r,below,above,_20).
opposite(r,sanely,insanely,_20).
opposite(r,empirically,theoretically,_20).
opposite(r,permissibly,impermissibly,_20).
opposite(r,temporarily,permanently,_20).
opposite(r,conclusively,inconclusively,_20).
opposite(r,upwind,downwind,_20).
opposite(r,upwards,downwards,_20).
opposite(r,upward,downward,_20).
opposite(r,upwardly,downwardly,_20).
opposite(r,upriver,downriver,_20).
opposite(r,'at most','at least',_20).
opposite(r,'at the most','at the least',_20).
opposite(r,'at best','at worst',_20).
opposite(r,responsibly,irresponsibly,_20).
opposite(r,remarkably,unremarkably,_20).
opposite(r,indoors,outdoors,_20).
opposite(r,organically,inorganically,_20).
opposite(r,officially,unofficially,_20).
opposite(r,centrally,peripherally,_20).
opposite(r,'on the one hand','on the other hand',_20).
opposite(r,successfully,unsuccessfully,_20).
opposite(r,systematically,unsystematically,_20).
opposite(r,consistently,inconsistently,_20).
opposite(r,constitutionally,unconstitutionally,_20).
opposite(r,democratically,undemocratically,_20).
opposite(r,typically,atypically,_20).
opposite(r,linearly,geometrically,_20).
opposite(r,primarily,secondarily,_20).
opposite(r,dramatically,undramatically,_20).
opposite(r,appropriately,inappropriately,_20).
opposite(r,suitably,unsuitably,_20).
opposite(r,naturally,artificially,_20).
opposite(r,acutely,chronically,_20).
opposite(r,sufficiently,insufficiently,_20).
opposite(r,hesitantly,unhesitatingly,_20).
opposite(r,'in hand','out of hand',_20).
opposite(r,mindfully,unmindfully,_20).
opposite(r,advertently,inadvertently,_20).
opposite(r,comfortably,uncomfortably,_20).
opposite(r,slowly,quickly,_20).
opposite(r,publicly,privately,_20).
opposite(r,orad,aborad,_20).
opposite(r,patiently,impatiently,_20).
opposite(r,steadily,unsteadily,_20).
opposite(r,symmetrically,asymmetrically,_20).
opposite(r,lightly,heavily,_20).
opposite(r,weakly,strongly,_20).
opposite(r,amply,meagerly,_20).
opposite(r,gracefully,gracelessly,_20).
opposite(r,considerately,inconsiderately,_20).
opposite(r,helpfully,unhelpfully,_20).
opposite(r,rationally,irrationally,_20).
opposite(r,critically,uncritically,_20).
opposite(r,competently,incompetently,_20).
opposite(r,emotionally,unemotionally,_20).
opposite(r,formally,informally,_20).
opposite(r,enthusiastically,unenthusiastically,_20).
opposite(r,finely,coarsely,_20).
opposite(r,sympathetically,unsympathetically,_20).
opposite(r,convincingly,unconvincingly,_20).
opposite(r,graciously,ungraciously,_20).
opposite(r,gracefully,ungracefully,_20).
opposite(r,regularly,irregularly,_20).
opposite(r,properly,improperly,_20).
opposite(r,conveniently,inconveniently,_20).
opposite(r,concretely,abstractly,_20).
opposite(r,fearfully,fearlessly,_20).
opposite(r,hopefully,hopelessly,_20).
opposite(r,wisely,foolishly,_20).
opposite(r,intelligently,unintelligently,_20).
opposite(r,intelligibly,unintelligibly,_20).
opposite(r,diplomatically,undiplomatically,_20).
opposite(r,correctly,incorrectly,_20).
opposite(r,right,wrongly,_20).
opposite(r,accurately,inaccurately,_20).
opposite(r,justly,unjustly,_20).
opposite(r,hurriedly,unhurriedly,_20).
opposite(r,monaurally,binaurally,_20).
opposite(r,imaginatively,unimaginatively,_20).
opposite(r,impressively,unimpressively,_20).
opposite(r,productively,unproductively,_20).
opposite(r,fruitfully,fruitlessly,_20).
opposite(r,profitably,unprofitably,_20).
opposite(r,expertly,amateurishly,_20).
opposite(r,interestingly,uninterestingly,_20).
opposite(r,realistically,unrealistically,_20).
opposite(r,thoughtfully,thoughtlessly,_20).
opposite(r,auspiciously,inauspiciously,_20).
opposite(r,propitiously,unpropitiously,_20).
opposite(r,politely,impolitely,_20).
opposite(r,courteously,discourteously,_20).
opposite(r,pleasantly,unpleasantly,_20).
opposite(r,agreeably,disagreeably,_20).
opposite(r,ambiguously,unambiguously,_20).
opposite(r,ceremoniously,unceremoniously,_20).
opposite(r,broadly,narrowly,_20).
opposite(r,faithfully,unfaithfully,_20).
opposite(r,dependably,undependably,_20).
opposite(r,reliably,unreliably,_20).
opposite(r,violently,nonviolently,_20).
opposite(r,finitely,infinitely,_20).
opposite(r,warily,unwarily,_20).
opposite(r,quietly,noisily,_20).
opposite(r,quietly,unquietly,_20).
opposite(r,inwardly,outwardly,_20).
opposite(r,favorably,unfavorably,_20).
opposite(r,cheerfully,cheerlessly,_20).
opposite(r,voluntarily,involuntarily,_20).
opposite(r,efficiently,inefficiently,_20).
opposite(r,wittingly,unwittingly,_20).
opposite(r,knowingly,unknowingly,_20).
opposite(r,justifiably,unjustifiably,_20).
opposite(r,modestly,immodestly,_20).
opposite(r,resolutely,irresolutely,_20).
opposite(r,attractively,unattractively,_20).
opposite(r,consciously,unconsciously,_20).
opposite(r,competitively,noncompetitively,_20).
opposite(r,believably,unbelievably,_20).
opposite(r,decently,indecently,_20).
opposite(r,characteristically,uncharacteristically,_20).
opposite(r,internally,externally,_20).
opposite(r,lawfully,unlawfully,_20).
opposite(r,unilaterally,multilaterally,_20).
opposite(r,appealingly,unappealingly,_20).
opposite(r,approvingly,disapprovingly,_20).
opposite(r,ambitiously,unambitiously,_20).
opposite(r,ashamedly,unashamedly,_20).
opposite(r,assertively,unassertively,_20).
opposite(r,articulately,inarticulately,_20).
opposite(r,audibly,inaudibly,_20).
opposite(r,bloodily,bloodlessly,_20).
opposite(r,appreciatively,unappreciatively,_20).
opposite(r,gratefully,ungratefully,_20).
opposite(r,seasonably,unseasonably,_20).
opposite(r,cautiously,incautiously,_20).
opposite(r,carefully,carelessly,_20).
opposite(r,chivalrously,unchivalrously,_20).
opposite(r,fairly,unfairly,_20).
opposite(r,coherently,incoherently,_20).
opposite(r,compatibly,incompatibly,_20).
opposite(r,complainingly,uncomplainingly,_20).
opposite(r,comprehensively,noncomprehensively,_20).
opposite(r,conditionally,unconditionally,_20).
opposite(r,consequentially,inconsequentially,_20).
opposite(r,credibly,incredibly,_20).
opposite(r,credulously,incredulously,_20).
opposite(r,believingly,unbelievingly,_20).
opposite(r,decisively,indecisively,_20).
opposite(r,possibly,impossibly,_20).
opposite(r,deservedly,undeservedly,_20).
opposite(r,controversially,uncontroversially,_20).
opposite(r,decorously,indecorously,_20).
opposite(r,willingly,unwillingly,_20).
opposite(r,offensively,defensively,_20).
opposite(r,offensively,inoffensively,_20).
opposite(r,harmfully,harmlessly,_20).
opposite(r,honestly,dishonestly,_20).
opposite(r,honorably,dishonorably,_20).
opposite(r,loyally,disloyally,_20).
opposite(r,obediently,disobediently,_20).
opposite(r,proportionately,disproportionately,_20).
opposite(r,reputably,disreputably,_20).
opposite(r,respectfully,disrespectfully,_20).
opposite(r,trustfully,distrustfully,_20).
opposite(r,westerly,easterly,_20).
opposite(r,effectually,ineffectually,_20).
opposite(r,efficaciously,inefficaciously,_20).
opposite(r,effectively,ineffectively,_20).
opposite(r,selfishly,unselfishly,_20).
opposite(r,elegantly,inelegantly,_20).
opposite(r,eloquently,ineloquently,_20).
opposite(r,encouragingly,discouragingly,_20).
opposite(r,equitably,inequitably,_20).
opposite(r,ethically,unethically,_20).
opposite(r,evenly,unevenly,_20).
opposite(r,equally,unequally,_20).
opposite(r,excitingly,unexcitingly,_20).
opposite(r,excusably,inexcusably,_20).
opposite(r,forgivably,unforgivably,_20).
opposite(r,pardonably,unpardonably,_20).
opposite(r,expediently,inexpediently,_20).
opposite(r,cheaply,expensively,_20).
opposite(r,expressively,inexpressively,_20).
opposite(r,fashionably,unfashionably,_20).
opposite(r,civilly,uncivilly,_20).
opposite(r,feelingly,unfeelingly,_20).
opposite(r,felicitously,infelicitously,_20).
opposite(r,literally,figuratively,_20).
opposite(r,flexibly,inflexibly,_20).
opposite(r,forgivingly,unforgivingly,_20).
opposite(r,pianissimo,fortissimo,_20).
opposite(r,joyfully,joylessly,_20).
opposite(r,grudgingly,ungrudgingly,_20).
opposite(r,hospitably,inhospitably,_20).
opposite(r,humanely,inhumanely,_20).
opposite(r,humorously,humorlessly,_20).
opposite(r,hygienically,unhygienically,_20).
opposite(r,legibly,illegibly,_20).
opposite(r,legitimately,illegitimately,_20).
opposite(r,lawfully,lawlessly,_20).
opposite(r,licitly,illicitly,_20).
opposite(r,logically,illogically,_20).
opposite(r,morally,immorally,_20).
opposite(r,penitently,impenitently,_20).
opposite(r,repentantly,unrepentantly,_20).
opposite(r,perceptibly,imperceptibly,_20).
opposite(r,personally,impersonally,_20).
opposite(r,implicitly,explicitly,_20).
opposite(r,precisely,imprecisely,_20).
opposite(r,exactly,inexactly,_20).
opposite(r,providently,improvidently,_20).
opposite(r,prudently,imprudently,_20).
opposite(r,adequately,inadequately,_20).
opposite(r,comparably,incomparably,_20).
opposite(r,conspicuously,inconspicuously,_20).
opposite(r,discreetly,indiscreetly,_20).
opposite(r,informatively,uninformatively,_20).
opposite(r,instructively,uninstructively,_20).
opposite(r,opportunely,inopportunely,_20).
opposite(r,securely,insecurely,_20).
opposite(r,sensitively,insensitively,_20).
opposite(r,sincerely,insincerely,_20).
opposite(r,tolerantly,intolerantly,_20).
opposite(r,transitively,intransitively,_20).
opposite(r,visibly,invisibly,_20).
opposite(r,maturely,immaturely,_20).
opposite(r,judiciously,injudiciously,_20).
opposite(r,manageably,unmanageably,_20).
opposite(r,manfully,unmanfully,_20).
opposite(r,malevolently,benevolently,_20).
opposite(r,minimally,maximally,_20).
opposite(r,measurably,immeasurably,_20).
opposite(r,melodiously,unmelodiously,_20).
opposite(r,memorably,unmemorably,_20).
opposite(r,truthfully,untruthfully,_20).
opposite(r,musically,unmusically,_20).
opposite(r,'broad-mindedly','narrow-mindedly',_20).
opposite(r,necessarily,unnecessarily,_20).
opposite(r,objectively,subjectively,_20).
opposite(r,obtrusively,unobtrusively,_20).
opposite(r,optimistically,pessimistically,_20).
opposite(r,optionally,obligatorily,_20).
opposite(r,palatably,unpalatably,_20).
opposite(r,patriotically,unpatriotically,_20).
opposite(r,recognizably,unrecognizably,_20).
opposite(r,pretentiously,unpretentiously,_20).
opposite(r,relevantly,irrelevantly,_20).
opposite(r,reverently,irreverently,_20).
opposite(r,righteously,unrighteously,_20).
opposite(r,'self-consciously',unselfconsciously,_20).
opposite(r,sentimentally,unsentimentally,_20).
opposite(r,separably,inseparably,_20).
opposite(r,smilingly,unsmilingly,_20).
opposite(r,sociably,unsociably,_20).
opposite(r,sportingly,unsportingly,_20).
opposite(r,romantically,unromantically,_20).
opposite(r,tactfully,tactlessly,_20).
opposite(r,tastefully,tastelessly,_20).
opposite(r,thinly,thickly,_20).
opposite(r,grammatically,ungrammatically,_20).
opposite(r,precedentedly,unprecedentedly,_20).
opposite(r,usefully,uselessly,_20).
opposite(r,convexly,concavely,_20).
opposite(r,painfully,painlessly,_20).
opposite(r,adaxially,abaxially,_20).


end_of_file.


vgp(201346978,0,201345109,0).
vgp(201345109,0,201346978,0).
sim(302096382,302096213).
sim(302096213,302096382).
sa(201348174,1,201348452,1).
sa(201348174,1,201347678,7).
sa(201345109,2,201587062,4).
sa(201345109,2,201347678,5).
s(302096382,5,'unsecured',s,1,0).
s(302096382,4,'unlocked',s,1,2).
s(302096382,3,'unlatched',s,1,0).
s(302096382,2,'unbolted',s,1,0).
s(302096382,1,'unbarred',s,1,0).
s(201348705,1,'unlock',v,1,4).
s(201348174,1,'lock',v,1,8).
s(201346978,2,'shut',v,2,2).
s(201346978,1,'close',v,2,20).
s(201346003,2,'open up',v,1,2).
s(201346003,1,'open',v,1,66).
s(201345109,2,'shut',v,1,10).
s(201345109,1,'close',v,1,32).
s(103683606,1,'locker',n,2,0).
s(103682487,1,'lock',n,1,6).
mp(104497005,103682487).
mp(103682487,103661340).
mp(103682487,103427296).
mp(103682487,103233905).
mp(103682487,103221720).
mp(103614782,103682487).
mp(102865931,103682487).
hyp(201603885,201346003).
hyp(201593614,201346003).
hyp(201593254,201346003).
hyp(201423793,201346003).
hyp(201354006,201345109).
hyp(201353873,201346003).
hyp(201348987,201346003).
hyp(201348838,201348174).
hyp(201348705,201346003).
hyp(201348174,201340439).
hyp(201346978,200146138).
hyp(201346693,201346003).
hyp(201346548,201346003).
hyp(201346430,201346003).
hyp(201345769,201345109).
hyp(201345589,201345109).
hyp(201343079,201346003).
hyp(201342012,201348174).
hyp(201243148,201345109).
hyp(201242996,201345109).
hyp(201242832,201345109).
hyp(201220528,201345109).
hyp(200355670,201345109).
hyp(104136800,103682487).
hyp(103874599,103682487).
hyp(103683606,103323703).
hyp(103682487,103323703).
hyp(103659950,103682487).
hyp(103645011,103682487).
hyp(103223162,103682487).
hyp(103156767,103682487).
hyp(103075370,103682487).
g(302096382,'not firmly fastened or secured; "an unbarred door"; "went through the unlatched gate into the street"; "an unlocked room"').
g(201348705,'open the lock of; "unlock the door"').
g(201348174,'fasten with a lock; "lock the bike to the fence"').
g(201346978,'become closed; "The windows closed with a loud bang"').
g(201346003,'cause to open or to become open; "Mary opened the car door"').
g(201345109,'move so that an opening or passage is obstructed; make shut; "Close the door"; "shut the window"').
g(103683606,'a fastener that locks or closes').
g(103682487,'a fastener fitted to a door or drawer to keep it firmly closed').
fr(201348705,0,8).
fr(201348705,0,21).
fr(201348705,0,11).
fr(201348174,0,8).
fr(201348174,0,21).
fr(201348174,0,20).
fr(201348174,0,11).
fr(201346978,0,1).
fr(201346003,0,8).
fr(201346003,0,11).
fr(201345109,0,8).
fr(201345109,0,11).
der(201348174,1,103683606,1).
der(201348174,1,103682487,1).
der(201346978,2,104211528,1).
der(201346978,1,100344040,2).
der(201346003,1,110737431,2).
der(201346003,1,103848348,1).
der(201346003,1,100383390,1).
der(201346003,1,100338641,1).
der(201345109,2,104211528,1).
der(201345109,2,104211356,1).
der(201345109,2,100344040,1).
der(201345109,1,101074694,2).
der(201345109,1,100344040,2).
der(110737431,2,201346003,1).
der(104211528,1,201346978,2).
der(104211528,1,201345109,2).
der(104211356,1,201345109,2).
der(103848348,1,201346003,1).
der(103683606,1,201348174,1).
der(103682487,1,201348174,1).
der(101074694,2,201345109,1).
der(100383390,1,201346003,1).
der(100344040,2,201346978,1).
der(100344040,2,201345109,1).
der(100344040,1,201345109,2).
der(100338641,1,201346003,1).
cs(201346003,201346804).
cs(201345109,201346978).
ant(201348705,1,201348174,1).
ant(201348174,1,201348705,1).
ant(201348174,1,200219963,1).
ant(201346978,1,201346804,1).
ant(201346804,1,201346978,1).
ant(201346003,1,201345109,1).
ant(201345109,1,201346003,1).
ant(200219963,1,201348174,1).

WNprolog-3.0/prolog/wn_sk.pl:sk(201983771,1,'change_posture%2:38:00::').
WNprolog-3.0/prolog/wn_s.pl:s(201983771,1,'change posture',v,1,0).
WNprolog-3.0/prolog/wn_hyp.pl:hyp(202098680,201983771).
WNprolog-3.0/prolog/wn_hyp.pl:hyp(202063486,201983771).
WNprolog-3.0/prolog/wn_hyp.pl:hyp(202040273,201983771).
WNprolog-3.0/prolog/wn_hyp.pl:hyp(202035781,201983771).
WNprolog-3.0/prolog/wn_hyp.pl:hyp(202035559,201983771).
WNprolog-3.0/prolog/wn_hyp.pl:hyp(201985923,201983771).
WNprolog-3.0/prolog/wn_hyp.pl:hyp(201985029,201983771).
WNprolog-3.0/prolog/wn_hyp.pl:hyp(201984902,201983771).
WNprolog-3.0/prolog/wn_hyp.pl:hyp(201984574,201983771).
WNprolog-3.0/prolog/wn_hyp.pl:hyp(201984317,201983771).
WNprolog-3.0/prolog/wn_hyp.pl:hyp(201984119,201983771).
WNprolog-3.0/prolog/wn_hyp.pl:hyp(201983771,200109660).
WNprolog-3.0/prolog/wn_hyp.pl:hyp(201983264,201983771).
WNprolog-3.0/prolog/wn_hyp.pl:hyp(201982044,201983771).
WNprolog-3.0/prolog/wn_g.pl:g(201983771,'undergo a change in bodily posture').
WNprolog-3.0/prolog/wn_fr.pl:fr(201983771,0,2).
WNprolog-3.0/prolog/wn_fr.pl:fr(201983771,0,1).
WNprolog-3.0/prolog/wn_ent.pl:ent(202062632,201983771).
wn_frames.pl:WNprolog-3.0/prolog/wn_sk.pl:sk(201983771,1,'change_posture%2:38:00::').
wn_frames.pl:WNprolog-3.0/prolog/wn_s.pl:s(201983771,1,'change posture',v,1,0).
wn_frames.pl:learningbyreading/resources/wn30-id:01983771-v change_posture-v#1-v
wn_frames.pl:learningbyreading/resources/wn30-id.sorted:01983771-v change_posture-v#1-v
wn_frames.pl:learningbyreading/resources/wn30-16-id:01983771-v 01351846-v change_posture-v#1-v
wn_frames.pl:learningbyreading/ext/ukb/lkb_sources/30/wnet30_dict.txt:change_posture 01983771-v:0
wn_frames.pl:boxer_lex/wnet30_dict.txt:change_posture 01983771-v:0
wn_frames.pl:+0 ## Change_posture - stoop.v - v#2062632
wn_frames.pl:+0 ## Change_posture - stand.v - v#1546111
wn_frames.pl:+0 ## Change_posture - stand up.v - v#1546768
wn_frames.pl:+0 ## Change_posture - squat.v - v#1545314
wn_frames.pl:+0 ## Change_posture - sprawl.v - v#1543426
wn_frames.pl:+0 ## Change_posture - slouch.v - v#1989720
wn_frames.pl:+0 ## Change_posture - sit.v - v#1543123
wn_frames.pl:+0 ## Change_posture - sit up.v - v#2098680
wn_frames.pl:+0 ## Change_posture - sit down.v - v#1543123
wn_frames.pl:+0 ## Change_posture - rise.v - v#1968569
wn_frames.pl:+0 ## Change_posture - lie.v - v#2690708
wn_frames.pl:+0 ## Change_posture - lie down.v - v#1985029
wn_frames.pl:+0 ## Change_posture - lean.v - v#2038357
wn_frames.pl:+0 ## Change_posture - kneel.v - v#1545649
wn_frames.pl:+0 ## Change_posture - hunch.v - v#2035559
wn_frames.pl:+0 ## Change_posture - huddle.v - v#2063988
wn_frames.pl:+0 ## Change_posture - drop.v - v#1977701
wn_frames.pl:+0 ## Change_posture - crouch.v - v#2062632
wn_frames.pl:+0 ## Change_posture - bend.v - v#2035919
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='9.4' vnmember='drop' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='9.2-1' vnmember='stand' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='9.2-1' vnmember='sit' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='51.3.1' vnmember='drop' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='51.1' vnmember='rise' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='50' vnmember='stoop' fnframe='Change_posture' fnlexent='9363' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='50' vnmember='stand' fnframe='Change_posture' fnlexent='9364' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='50' vnmember='squat' fnframe='Change_posture' fnlexent='9383' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='50' vnmember='sprawl' fnframe='Change_posture' fnlexent='9386' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='50' vnmember='slouch' fnframe='Change_posture' fnlexent='9404' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='50' vnmember='sit' fnframe='Change_posture' fnlexent='9380' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='50' vnmember='rise' fnframe='Change_posture' fnlexent='9723' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='50' vnmember='lie' fnframe='Change_posture' fnlexent='9370' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='50' vnmember='lean' fnframe='Change_posture' fnlexent='9385' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='50' vnmember='kneel' fnframe='Change_posture' fnlexent='9367' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='50' vnmember='crouch' fnframe='Change_posture' fnlexent='9390' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='50' vnmember='bend' fnframe='Change_posture' fnlexent='9361' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='47.6' vnmember='stoop' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='47.6' vnmember='stand' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='47.6' vnmember='squat' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='47.6' vnmember='sit' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='47.6' vnmember='lie' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='47.6' vnmember='lean' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='45.6-1' vnmember='drop' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VNC-FNF.s:   <vncls class='10.10' vnmember='drop' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
nlp-server/scase-wp3-nlp-parser/semlink/vn-fn/VN-FNRoleMapping.txt:  <vncls class='50' fnframe='Change_posture'>
learningbyreading/resources/WordFrameNet:Frame: Change_posture
learningbyreading/resources/wnid-bn:change+posture-v#1-v s00084786v
learningbyreading/resources/wnid-16:change_posture-v#1-v 01351846-v
learningbyreading/resources/wn31mapping.rdf:<binding name='x'><uri>http://wordnet-rdf.princeton.edu/wn31/change+posture-v#1-v</uri></binding>
learningbyreading/resources/wn31.map:change+posture-v#1-v 201987785-v
learningbyreading/resources/wn31-30.sorted:01987785-v 01983771-v
learningbyreading/resources/wn30map31.txt:v     01983771        01987785
learningbyreading/resources/wn30-id:01983771-v change_posture-v#1-v
learningbyreading/resources/wn30-id.sorted:01983771-v change_posture-v#1-v
learningbyreading/resources/wn30-31:01983771-v 01987785-v
learningbyreading/resources/wn30-31.sorted:01983771-v 01987785-v
learningbyreading/resources/wn30-16.sorted:01983771-v 01351846-v
learningbyreading/resources/wn30-16-id:01983771-v 01351846-v change_posture-v#1-v
learningbyreading/resources/wn30-16-31:01983771-v 01351846-v 01987785-v
learningbyreading/resources/wn16-30:01351846-v 01983771-v
learningbyreading/resources/wn16-30.sorted:01351846-v 01983771-v
learningbyreading/resources/VN-FNRoleMapping.txt:  <vncls class='50' fnframe='Change_posture'>
learningbyreading/resources/mappings-upc-2007/mapping-16-30/wn16-30.verb:01351846 01983771 1
learningbyreading/resources/mapping_frame_synsets.txt:Change_posture    v#01410999
learningbyreading/resources/mapping_frame_synsets.txt:Change_posture    v#01391162
learningbyreading/resources/mapping_frame_synsets.txt:Change_posture    v#01356367
learningbyreading/resources/mapping_frame_synsets.txt:Change_posture    v#01063788
learningbyreading/resources/mapping_frame_synsets.txt:Change_posture    v#01062160
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - stoop.v - v#2062632
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - stand.v - v#1546111
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - stand up.v - v#1546768
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - squat.v - v#1545314
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - sprawl.v - v#1543426
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - slouch.v - v#1989720
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - sit.v - v#1543123
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - sit up.v - v#2098680
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - sit down.v - v#1543123
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - rise.v - v#1968569
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - lie.v - v#2690708
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - lie down.v - v#1985029
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - lean.v - v#2038357
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - kneel.v - v#1545649
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - hunch.v - v#2035559
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - huddle.v - v#2063988
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - drop.v - v#1977701
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - crouch.v - v#2062632
learningbyreading/resources/framenet-wordnet-map.txt:+0 ## Change_posture - bend.v - v#2035919
learningbyreading/resources/fn2bnFrameBase.ttl:frame:Change_posture  skos:closeMatch  bn:s00090321v , bn:s00091683v , bn:s00083405v , bn:s00086086v , bn:s00087364v , bn:s00090326v , bn:s00085926v , bn:s00093906v , bn:s00090123v , bn:s00094275v , bn:s00093776v , bn:s00089517v , bn:s00093790v , bn:s00094182v , bn:s00082761v , bn:s00082613v , bn:s00083402v .
learningbyreading/resources/fn-bn:Change_posture s00094275v
learningbyreading/resources/fn-bn:Change_posture s00094182v
learningbyreading/resources/fn-bn:Change_posture s00093906v
learningbyreading/resources/fn-bn:Change_posture s00093790v
learningbyreading/resources/fn-bn:Change_posture s00093776v
learningbyreading/resources/fn-bn:Change_posture s00091683v
learningbyreading/resources/fn-bn:Change_posture s00090326v
learningbyreading/resources/fn-bn:Change_posture s00090321v
learningbyreading/resources/fn-bn:Change_posture s00090123v
learningbyreading/resources/fn-bn:Change_posture s00089517v
learningbyreading/resources/fn-bn:Change_posture s00087364v
learningbyreading/resources/fn-bn:Change_posture s00086086v
learningbyreading/resources/fn-bn:Change_posture s00085926v
learningbyreading/resources/fn-bn:Change_posture s00083405v
learningbyreading/resources/fn-bn:Change_posture s00083402v
learningbyreading/resources/fn-bn:Change_posture s00082761v
learningbyreading/resources/fn-bn:Change_posture s00082613v
learningbyreading/resources/eXtendedWFN:Frame: Change_posture
learningbyreading/resources/bn35-wn31.map:s00084786v change+posture-v#1-v 201987785-v
learningbyreading/resources/bn-dbpedia2:s01983771n Minuscule_643
learningbyreading/ext/ukb/lkb_sources/30/wnet30g_rels.txt:u:01983771-v v:07296428-n s:30g d:0
learningbyreading/ext/ukb/lkb_sources/30/wnet30g_rels.txt:u:01983771-v v:05079866-n s:30g d:0
learningbyreading/ext/ukb/lkb_sources/30/wnet30g_rels.txt:u:01983771-v v:02667275-a s:30g d:0
learningbyreading/ext/ukb/lkb_sources/30/wnet30_rels.txt:u:02098680-v v:01983771-v s:30 d:0
learningbyreading/ext/ukb/lkb_sources/30/wnet30_rels.txt:u:02063486-v v:01983771-v s:30 d:0
learningbyreading/ext/ukb/lkb_sources/30/wnet30_rels.txt:u:02062632-v v:01983771-v s:30 d:0
learningbyreading/ext/ukb/lkb_sources/30/wnet30_rels.txt:u:02040273-v v:01983771-v s:30 d:0
learningbyreading/ext/ukb/lkb_sources/30/wnet30_rels.txt:u:02035781-v v:01983771-v s:30 d:0
learningbyreading/ext/ukb/lkb_sources/30/wnet30_rels.txt:u:02035559-v v:01983771-v s:30 d:0
learningbyreading/ext/ukb/lkb_sources/30/wnet30_rels.txt:u:01985923-v v:01983771-v s:30 d:0
learningbyreading/ext/ukb/lkb_sources/30/wnet30_rels.txt:u:01985029-v v:01983771-v s:30 d:0
learningbyreading/ext/ukb/lkb_sources/30/wnet30_rels.txt:u:01984902-v v:01983771-v s:30 d:0
learningbyreading/ext/ukb/lkb_sources/30/wnet30_rels.txt:u:01984574-v v:01983771-v s:30 d:0
learningbyreading/ext/ukb/lkb_sources/30/wnet30_rels.txt:u:01984317-v v:01983771-v s:30 d:0
learningbyreading/ext/ukb/lkb_sources/30/wnet30_rels.txt:u:01984119-v v:01983771-v s:30 d:0
learningbyreading/ext/ukb/lkb_sources/30/wnet30_rels.txt:u:01983771-v v:00109660-v s:30 d:0
learningbyreading/ext/ukb/lkb_sources/30/wnet30_rels.txt:u:01983264-v v:01983771-v s:30 d:0
learningbyreading/ext/ukb/lkb_sources/30/wnet30_rels.txt:u:01982044-v v:01983771-v s:30 d:0
learningbyreading/ext/ukb/lkb_sources/30/wnet30_dict.txt:change_posture 01983771-v:0
learningbyreading/ext/ukb/lkb_sources/17/wnet17_dict.txt:change_posture 01474515-v:0
boxer_lex/wnet30_dict.txt:change_posture 01983771-v:0
boxer_lex/VNC-FNF.s:   <vncls class='9.4' vnmember='drop' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='9.2-1' vnmember='stand' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='9.2-1' vnmember='sit' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='51.3.1' vnmember='drop' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='51.1' vnmember='rise' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='50' vnmember='stoop' fnframe='Change_posture' fnlexent='9363' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='50' vnmember='stand' fnframe='Change_posture' fnlexent='9364' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='50' vnmember='squat' fnframe='Change_posture' fnlexent='9383' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='50' vnmember='sprawl' fnframe='Change_posture' fnlexent='9386' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='50' vnmember='slouch' fnframe='Change_posture' fnlexent='9404' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='50' vnmember='sit' fnframe='Change_posture' fnlexent='9380' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='50' vnmember='rise' fnframe='Change_posture' fnlexent='9723' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='50' vnmember='lie' fnframe='Change_posture' fnlexent='9370' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='50' vnmember='lean' fnframe='Change_posture' fnlexent='9385' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='50' vnmember='kneel' fnframe='Change_posture' fnlexent='9367' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='50' vnmember='crouch' fnframe='Change_posture' fnlexent='9390' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='50' vnmember='bend' fnframe='Change_posture' fnlexent='9361' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='47.6' vnmember='stoop' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='47.6' vnmember='stand' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='47.6' vnmember='squat' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='47.6' vnmember='sit' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='47.6' vnmember='lie' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='47.6' vnmember='lean' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='45.6-1' vnmember='drop' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
boxer_lex/VNC-FNF.s:   <vncls class='10.10' vnmember='drop' fnframe='Change_posture' fnlexent='' versionID='vn3.2' />
boxer_lex/VN-FNRoleMapping.txt:  <vncls class='50' fnframe='Change_posture'>
boxer_lex/framenet.pl:fnpattern(stoop, 50000000, 'Change_posture', ['Agent': 'Protagonist']).
boxer_lex/framenet.pl:fnpattern(stand, 50000000, 'Change_posture', ['Agent': 'Protagonist']).
boxer_lex/framenet.pl:fnpattern(squat, 50000000, 'Change_posture', ['Agent': 'Protagonist']).
boxer_lex/framenet.pl:fnpattern(sprawl, 50000000, 'Change_posture', ['Agent': 'Protagonist']).
boxer_lex/framenet.pl:fnpattern(slouch, 50000000, 'Change_posture', ['Agent': 'Protagonist']).
boxer_lex/framenet.pl:fnpattern(sit, 50000000, 'Change_posture', ['Agent': 'Protagonist']).
boxer_lex/framenet.pl:fnpattern(rise, 50000000, 'Change_posture', ['Agent': 'Protagonist']).
boxer_lex/framenet.pl:fnpattern(lie, 50000000, 'Change_posture', ['Agent': 'Protagonist']).
boxer_lex/framenet.pl:fnpattern(lean, 50000000, 'Change_posture', ['Agent': 'Protagonist']).
boxer_lex/framenet.pl:fnpattern(kneel, 50000000, 'Change_posture', ['Agent': 'Protagonist']).
boxer_lex/framenet.pl:fnpattern(crouch, 50000000, 'Change_posture', ['Agent': 'Protagonist']).
boxer_lex/framenet.pl:fnpattern(bend, 50000000, 'Change_posture', ['Agent': 'Protagonist']).




+0 ## Supply - provision.v - v#2338975
+0 ## Supply - provision.n - n#1057200
+0 ## Supply - equipment.n - n#3294048
+0 ## Supply - supplier.n - n#10677271
+0 ## Supply - provide.v - v#2327200
+0 ## Supply - supply.n - n#1057200
+0 ## Supply - fuel.v - v#2338386
+0 ## Supply - supply.v - v#2327200
+0 ## Supply - issue.v - v#2479323
+0 ## Supply - fix up.v - v#1203369
+0 ## Supply - outfit.v - v#2339413
+0 ## Supply - equip.v - v#2339413
+0 ## Supply - furnish.v - v#2327200
+0 ## Continued_state_of_affairs - as yet.adv - r#27918
+0 ## Continued_state_of_affairs - still.adv - r#31304
+0 ## Continued_state_of_affairs - to date.adv - r#172151
+0 ## Continued_state_of_affairs - so far.adv - r#27918
+0 ## Commutative_process - add.v - v#182406
+0 ## Commutative_process - multiply.v - v#641672
+0 ## Commutative_process - multiplication.n - n#849982
+0 ## Commutative_process - addition.n - n#2679415
+0 ## Make_agreement_on_action - deal.n - n#6771159
+0 ## Make_agreement_on_action - agree.v - v#805376
+0 ## Make_agreement_on_action - treaty.n - n#6773434
+0 ## Make_agreement_on_action - agreement.n - n#5795044
+0 ## Dunking - dip.v - v#1577093
+0 ## Dunking - dunk.v - v#1577093
+0 ## Manipulate_into_doing - con.v - v#2572119
+0 ## Manipulate_into_doing - trick.v - v#2575723
+0 ## Manipulate_into_doing - deceive.v - v#2575082
+0 ## Manipulate_into_doing - harass.v - v#1789514
+0 ## Manipulate_into_doing - dupe.v - v#854904
+0 ## Manipulate_into_doing - bully.v - v#1035199
+0 ## Manipulate_into_doing - defraud.v - v#2572119
+0 ## Manipulate_into_doing - flatter.v - v#880227
+0 ## Manipulate_into_doing - manipulate.v - v#2536329
+0 ## Manipulate_into_doing - fool.v - v#854904
+0 ## Manipulate_into_doing - badger.v - v#1803380
+0 ## Manipulate_into_doing - lure.v - v#782527
+0 ## Manipulate_into_doing - cheat.v - v#2573275
+0 ## Manipulate_into_doing - cajole.v - v#768778
+0 ## Manipulate_into_doing - blackmail.v - v#2581073
+0 ## Tolerating - tolerate.v - v#668099
+0 ## Tolerating - tolerant.a - a#2435383
+0 ## Tolerating - endure.v - v#668099
+0 ## Tolerating - toleration.n - n#4638175
+0 ## Tolerating - stand.v - v#1546111
+0 ## Tolerating - bear.v - v#668099
+0 ## Increment - further.a - a#443988
+0 ## Increment - other.a - a#2069355
+0 ## Increment - another.a - a#2070188
+0 ## Increment - additional.a - a#48858
+0 ## Increment - more.a - a#1555133
+0 ## Increment - more.n - n#11190183
+0 ## Planting - sow.v - v#1500873
+0 ## Planting - plant.v - v#1567275
+0 ## Change_event_time - move up.v - v#1968569
+0 ## Change_event_time - hold over.v - v#2642814
+0 ## Change_event_time - move back.v - v#1994442
+0 ## Change_event_time - advance.v - v#1992503
+0 ## Change_event_time - postpone.v - v#2642814
+0 ## Change_event_time - delay.n - n#15272029
+0 ## Change_event_time - defer.v - v#2642814
+0 ## Change_event_time - put off.v - v#2642814
+0 ## Change_event_time - delay.v - v#2641957
+0 ## Change_event_time - put over.v - v#2642814
+0 ## Source_of_getting - source.n - n#6675122
+0 ## Hospitality - red carpet.n - n#4066270
+0 ## Hospitality - hospitable.a - a#1243825
+0 ## Hospitality - hospitality.n - n#6631506
+0 ## Be_translation_equivalent - translate.v - v#959827
+0 ## Simple_naming - call.v - v#1028748
+0 ## Simple_naming - term.v - v#1029642
+0 ## Finish_game - win.v - v#1100145
+0 ## Finish_game - lose.v - v#2287789
+0 ## Relative_time - latest.a - a#668366
+0 ## Relative_time - ahead.adv - r#67045
+0 ## Relative_time - sooner.adv - r#115554
+0 ## Relative_time - punctual.a - a#1900349
+0 ## Relative_time - behind.adv - r#221985
+0 ## Relative_time - as.adv - r#22131
+0 ## Relative_time - erstwhile.a - a#1729566
+0 ## Relative_time - predate.v - v#2712443
+0 ## Relative_time - follow.v - v#2712772
+0 ## Relative_time - prior.a - a#122128
+0 ## Relative_time - previous.a - a#127137
+0 ## Relative_time - precede.v - v#2712443
+0 ## Relative_time - late.a - a#1901186
+0 ## Relative_time - antecedent.a - a#121865
+0 ## Relative_time - next.a - a#127948
+0 ## Relative_time - past.a - a#1727926
+0 ## Relative_time - simultaneous.a - a#2378496
+0 ## Relative_time - last.a - a#1730329
+0 ## Relative_time - simultaneously.adv - r#120095
+0 ## Relative_time - recent.a - a#1730444
+0 ## Relative_time - subsequent.a - a#122626
+0 ## Relative_time - belated.a - a#1901186
+0 ## Relative_time - punctually.adv - r#64691
+0 ## Relative_time - subsequently.adv - r#61203
+0 ## Relative_time - later.adv - r#61203
+0 ## Relative_time - preceding.a - a#125711
+0 ## Relative_time - premature.a - a#815227
+0 ## Relative_time - early.a - a#812952
+0 ## Relative_time - on time.adv - r#171457
+0 ## Relative_time - overdue.a - a#137120
+0 ## Relative_time - punctuality.n - n#5047778
+0 ## Relative_time - tardy.a - a#1901186
+0 ## Relative_time - following.a - a#127948
+0 ## Inchoative_change_of_temperature - heat.v - v#371264
+0 ## Inchoative_change_of_temperature - cool off.v - v#370126
+0 ## Inchoative_change_of_temperature - warm.v - v#372958
+0 ## Inchoative_change_of_temperature - refrigerate.v - v#371955
+0 ## Inchoative_change_of_temperature - reheat.v - v#544280
+0 ## Inchoative_change_of_temperature - cool.v - v#370412
+0 ## Inchoative_change_of_temperature - chill.v - v#370412
+0 ## Become_silent - quiet.v - v#2190188
+0 ## Become_silent - quieten.v - v#461493
+0 ## Become_silent - quiet.n - n#4982207
+0 ## Become_silent - shush.v - v#390741
+0 ## Become_silent - hush_up.v - v#461493
+0 ## Become_silent - quiet_down.v - v#2190188
+0 ## Become_silent - hush.v - v#461493
+0 ## Become_silent - pipe_down.v - v#2190188
+0 ## Become_silent - silence.v - v#461493
+0 ## Resurrection - return.v - v#2004874
+0 ## Resurrection - resurrection.n - n#1048059
+0 ## Resurrection - rise.v - v#98770
+0 ## Resurrection - come_back.v - v#548153
+0 ## Resurrection - resurrect.v - v#98770
+0 ## Sign - usher in.v - v#349592
+0 ## Sign - mark.v - v#921738
+0 ## Sign - indicate.v - v#921300
+0 ## Sign - symptomatic.a - a#357254
+0 ## Sign - sign.n - n#6646243
+0 ## Sign - signify.v - v#1039854
+0 ## Sign - symptom.n - n#6798187
+0 ## Sign - indicative.a - a#3094520
+0 ## Sign - indication.n - n#6797169
+0 ## Kinship - forebear.n - n#10102369
+0 ## Kinship - offspring.n - n#10373998
+0 ## Kinship - nephew.n - n#10353355
+0 ## Kinship - stepmother.n - n#10654827
+0 ## Kinship - daughter.n - n#9992837
+0 ## Kinship - family.n - n#7970406
+0 ## Kinship - stepbrother.n - n#10654321
+0 ## Kinship - kid.n - n#9918248
+0 ## Kinship - relative.n - n#10235549
+0 ## Kinship - kinswoman.n - n#10237069
+0 ## Kinship - parental.a - a#1722529
+0 ## Kinship - stepson.n - n#10655075
+0 ## Kinship - grandfather.n - n#10142391
+0 ## Kinship - son-in-law.n - n#10624915
+0 ## Kinship - dad.n - n#9988063
+0 ## Kinship - sibling.n - n#10595164
+0 ## Kinship - filial.a - a#1722699
+0 ## Kinship - forefather.n - n#10102800
+0 ## Kinship - grandson.n - n#10143299
+0 ## Kinship - kinsfolk.n - n#7970721
+0 ## Kinship - ancestral.a - a#2604913
+0 ## Kinship - kinsman.n - n#10236946
+0 ## Kinship - niece.n - n#10357613
+0 ## Kinship - grandmother.n - n#10142747
+0 ## Kinship - mother.n - n#10332385
+0 ## Kinship - kin.n - n#10236304
+0 ## Kinship - granddaughter.n - n#10141732
+0 ## Kinship - sister.n - n#10602985
+0 ## Kinship - auntie.n - n#9823502
+0 ## Kinship - parent.n - n#10399491
+0 ## Kinship - in-law.n - n#10207169
+0 ## Kinship - maternal.a - a#1722529
+0 ## Kinship - clan.n - n#7969695
+0 ## Kinship - father-in-law.n - n#10082043
+0 ## Kinship - daddy.n - n#9988063
+0 ## Kinship - mum.n - n#10278128
+0 ## Kinship - brother.n - n#9876454
+0 ## Kinship - father.n - n#10080869
+0 ## Kinship - child.n - n#9918248
+0 ## Kinship - uncle.n - n#10736091
+0 ## Kinship - paternal.a - a#1722529
+0 ## Kinship - stepfather.n - n#10654701
+0 ## Kinship - stepsister.n - n#10603242
+0 ## Kinship - ancestor.n - n#9792555
+0 ## Kinship - cousin.n - n#9972010
+0 ## Kinship - mother-in-law.n - n#10333317
+0 ## Kinship - scion.n - n#10561222
+0 ## Kinship - son.n - n#10624074
+0 ## Kinship - stepdaughter.n - n#10654596
+0 ## Kinship - mom.n - n#10278128
+0 ## Kinship - aunt.n - n#9823502
+0 ## Kinship - descendant.n - n#10006511
+0 ## Kinship - daughter-in-law.n - n#9993040
+0 ## Kinship - brother-in-law.n - n#9877288
+0 ## Kinship - sister-in-law.n - n#10603766
+0 ## Dispersal - sprinkle.v - v#1376245
+0 ## Dispersal - disseminate.v - v#968211
+0 ## Dispersal - dispersion.n - n#5087297
+0 ## Dispersal - disperse.v - v#968211
+0 ## Dispersal - strew.v - v#1378123
+0 ## Dispersal - scatter.v - v#1376245
+0 ## Dispersal - pass on.v - v#2043190
+0 ## Dispersal - dissolution.n - n#13468094
+0 ## Dispersal - dispersal.n - n#368592
+0 ## Dispersal - distribute.v - v#968211
+0 ## Dispersal - distribution.n - n#5087297
+0 ## Dispersal - dissolve.v - v#446329
+0 ## Dispersal - spread.v - v#969873
+0 ## Reading - read.v - v#625119
+0 ## Reading - scan.v - v#2152278
+0 ## Reading - devour.v - v#1565360
+0 ## Reading - peruse.v - v#2152812
+0 ## Reading - skim.v - v#2152278
+0 ## Reading - pore.v - v#722232
+0 ## Reading - reader.n - n#10508862
+0 ## Being_employed - clerk.v - v#2411802
+0 ## Being_employed - work.n - n#575741
+0 ## Being_employed - employed.a - a#863946
+0 ## Being_employed - unemployed.a - a#864693
+0 ## Being_employed - job.n - n#582388
+0 ## Being_employed - employ.n - n#13968092
+0 ## Being_employed - work.v - v#2410855
+0 ## Being_employed - employment.n - n#584367
+0 ## Being_employed - subcontract.v - v#2461063
+0 ## Being_employed - workplace.n - n#4602044
+0 ## Being_employed - unemployment.n - n#13968308
+0 ## Being_employed - farm_(out).v - v#2420232
+0 ## Being_employed - jobless.a - a#865007
+0 ## Being_employed - stint.n - n#720431
+0 ## Practice - drill.n - n#894552
+0 ## Practice - practice.v - v#1723224
+0 ## Practice - exercise.n - n#894552
+0 ## Practice - run-through.n - n#897506
+0 ## Practice - rehearsal.n - n#897026
+0 ## Practice - rehearse.v - v#1723224
+0 ## Practice - practice.n - n#894552
+0 ## Practice - mock.a - a#1117823
+0 ## Practice - run_through.v - v#1926311
+0 ## Practice - dry run.n - n#897026
+0 ## Similarity - similarity_((mass)).n - n#4743605
+0 ## Similarity - take after.v - v#2665937
+0 ## Similarity - like.a - a#1409581
+0 ## Similarity - distinct.a - a#2067063
+0 ## Similarity - similar.a - a#2071420
+0 ## Similarity - distinction.n - n#5748285
+0 ## Similarity - resemble.v - v#2665282
+0 ## Similarity - dissimilarity_((mass)).n - n#4750164
+0 ## Similarity - like.n - n#5845419
+0 ## Similarity - disparity.n - n#4752530
+0 ## Similarity - resemblance.n - n#4747445
+0 ## Similarity - dissimilar.a - a#1410363
+0 ## Similarity - discrepant.a - a#578523
+0 ## Similarity - ringer.n - n#10531557
+0 ## Similarity - differ.v - v#2666239
+0 ## Similarity - alike.a - a#1410606
+0 ## Similarity - difference_((count)).n - n#4748836
+0 ## Similarity - image.n - n#10027246
+0 ## Similarity - unlike.a - a#1410363
+0 ## Similarity - spitting image.n - n#4747616
+0 ## Similarity - different.a - a#2064745
+0 ## Similarity - parallel.n - n#4746430
+0 ## Similarity - dissimilarity.n - n#4750164
+0 ## Similarity - variant.n - n#7366627
+0 ## Similarity - disparate.a - a#2066836
+0 ## Similarity - vary.v - v#2661252
+0 ## Similarity - similarity_((count)).n - n#4743605
+0 ## Similarity - difference.n - n#4748836
+0 ## Similarity - discrepancy.n - n#7366627
+0 ## Being_in_operation - operate.v - v#1525666
+0 ## Being_in_operation - operational.a - a#833018
+0 ## Undergoing - casualty.n - n#9899671
+0 ## Undergoing - victim.n - n#10752093
+0 ## Undergoing - undergo.v - v#2108377
+0 ## Deny_permission - prohibit.v - v#795863
+0 ## Deny_permission - outlaw.v - v#2480923
+0 ## Deny_permission - forbid.v - v#795863
+0 ## Setting_fire - kindle.v - v#2761372
+0 ## Setting_fire - combust.v - v#2762468
+0 ## Setting_fire - light.v - v#2759614
+0 ## Setting_fire - spark.v - v#1643657
+0 ## Setting_fire - on fire.a - a#475308
+0 ## Setting_fire - alight.a - a#475308
+0 ## Setting_fire - ignite.v - v#2759614
+0 ## Setting_fire - ablaze.a - a#475308
+0 ## Setting_fire - torch.v - v#379280
+0 ## Losing_track_of_theme - lose.v - v#2287789
+0 ## Shaped_part - rind.n - n#7670731
+0 ## Shaped_part - arm.n - n#5563770
+0 ## Shaped_part - brim.n - n#2902250
+0 ## Shaped_part - leg.n - n#5560787
+0 ## Shaped_part - mouth.n - n#5302499
+0 ## Shaped_part - handle.n - n#3485997
+0 ## Bearing_arms - pack.v - v#1451176
+0 ## Bearing_arms - unarmed.a - a#142917
+0 ## Bearing_arms - gunman.n - n#10152083
+0 ## Bearing_arms - weaponless.a - a#143516
+0 ## Bearing_arms - draw.v - v#1995211
+0 ## Bearing_arms - carry.v - v#1449974
+0 ## Bearing_arms - nuclear.a - a#610532
+0 ## Bearing_arms - armed.a - a#142407
+0 ## Evading - elude.v - v#2074377
+0 ## Evading - flee.v - v#2075462
+0 ## Evading - evasion.n - n#59127
+0 ## Evading - evade.v - v#809654
+0 ## Evading - elusive.a - a#149262
+0 ## Evading - evasive.a - a#1888284
+0 ## Evading - get away.v - v#2074677
+0 ## Importance - significant.a - a#2161432
+0 ## Importance - landmark.n - n#8624891
+0 ## Importance - fundamental.a - a#1277097
+0 ## Importance - crucial.a - a#655779
+0 ## Importance - vital.a - a#903894
+0 ## Importance - serious.a - a#1279611
+0 ## Importance - instrumental.a - a#1196775
+0 ## Importance - seriously.adv - r#15953
+0 ## Importance - considerable.a - a#624026
+0 ## Importance - critical.a - a#650577
+0 ## Importance - key.a - a#1277097
+0 ## Importance - count.v - v#2645839
+0 ## Importance - acute.a - a#650900
+0 ## Importance - important.a - a#1275562
+0 ## Importance - pivotal.a - a#656507
+0 ## Importance - import.n - n#6601327
+0 ## Importance - epic.a - a#1386010
+0 ## Importance - decisive.a - a#656132
+0 ## Importance - importance.n - n#5168261
+0 ## Importance - major.a - a#1472628
+0 ## Importance - significance.n - n#5169813
+0 ## Importance - main.a - a#1277426
+0 ## Get_a_job - sign on.v - v#2409941
+0 ## Beyond_compare - incomparable.a - a#504592
+0 ## Beyond_compare - unmatched.a - a#505410
+0 ## Beyond_compare - peerless.a - a#505410
+0 ## Beyond_compare - matchless.a - a#505410
+0 ## Beyond_compare - unrivalled.a - a#505410
+0 ## Beyond_compare - unequalled.a - a#505853
+0 ## Beyond_compare - nonpareil.a - a#505410
+0 ## Emotions_by_stimulus - glad.a - a#1361414
+0 ## Emotions_by_stimulus - joyful.a - a#1367211
+0 ## Emotions_by_stimulus - jubilant.a - a#1367211
+0 ## Wealthiness - rich.a - a#2021905
+0 ## Wealthiness - broke.a - a#2023287
+0 ## Wealthiness - affluent.a - a#2022167
+0 ## Wealthiness - underprivileged.a - a#1864471
+0 ## Wealthiness - bankrupt.a - a#2026629
+0 ## Wealthiness - poor.a - a#2022953
+0 ## Wealthiness - needy.a - a#2023430
+0 ## Wealthiness - privileged.a - a#1864123
+0 ## Wealthiness - well-off.a - a#2022556
+0 ## Wealthiness - impoverished.a - a#2023430
+0 ## Wealthiness - prosperous.a - a#2022556
+0 ## Wealthiness - wealthy.a - a#2022167
+0 ## Wealthiness - poverty.n - n#14493145
+0 ## Experience_bodily_harm - break.v - v#334186
+0 ## Experience_bodily_harm - sprain.v - v#91124
+0 ## Experience_bodily_harm - injure.v - v#69879
+0 ## Experience_bodily_harm - strain.v - v#1572728
+0 ## Experience_bodily_harm - twist.v - v#91124
+0 ## Experience_bodily_harm - jam.v - v#1492944
+0 ## Experience_bodily_harm - hurt.v - v#1793177
+0 ## Experience_bodily_harm - bruise.v - v#1492725
+0 ## Experience_bodily_harm - pull.v - v#71803
+0 ## Experience_bodily_harm - scrape.v - v#1309478
+0 ## Experience_bodily_harm - sunburn.v - v#104299
+0 ## Experience_bodily_harm - graze.v - v#1608508
+0 ## Experience_bodily_harm - smack.v - v#1414916
+0 ## Experience_bodily_harm - stub.v - v#102420
+0 ## Experience_bodily_harm - hit.v - v#1400044
+0 ## Experience_bodily_harm - cut.v - v#1756277
+0 ## Experience_bodily_harm - burn.v - v#378664
+0 ## Experience_bodily_harm - abrade.v - v#1254013
+0 ## Experience_bodily_harm - tear.v - v#1573515
+0 ## Range - earshot.n - n#8560785
+0 ## Range - range.n - n#8628921
+0 ## Range - reach.n - n#8628921
+0 ## Range - sight.n - n#5623818
+0 ## Range - view.n - n#6208751
+0 ## Range - distance.n - n#5084201
+0 ## Range - intercontinental.a - a#1567500
+0 ## Range - strike.n - n#977301
+0 ## Processing_materials - treat.v - v#515154
+0 ## Processing_materials - enrich.v - v#171586
+0 ## Processing_materials - reprocess.v - v#1162425
+0 ## Processing_materials - enrichment.n - n#13271498
+0 ## Processing_materials - stain.v - v#286008
+0 ## Processing_materials - dye.v - v#283090
+0 ## Processing_materials - etch.v - v#1750421
+0 ## Processing_materials - weaponize.v - v#584954
+0 ## Processing_materials - process.v - v#638837
+0 ## Processing_materials - galvanize.v - v#1266895
+0 ## Processing_materials - spin.v - v#1518772
+0 ## Response - meet.v - v#2023107
+0 ## Response - react.v - v#717358
+0 ## Response - reaction.n - n#859001
+0 ## Response - response.n - n#11416988
+0 ## Response - respond.v - v#717358
+0 ## Locale - region.n - n#8630039
+0 ## Locale - area.n - n#8497294
+0 ## Locale - grounds.n - n#5823932
+0 ## Locale - pocket.n - n#11423028
+0 ## Locale - spot.n - n#8664443
+0 ## Locale - locale.n - n#8677628
+0 ## Locale - location.n - n#27167
+0 ## Locale - zone.n - n#8509442
+0 ## Locale - point.n - n#8620061
+0 ## Locale - place.n - n#8664443
+0 ## Locale - regional.a - a#2871858
+0 ## Locale - site.n - n#8651247
+0 ## Locale - earth.n - n#14842992
+0 ## Rotting - decay.n - n#14560612
+0 ## Rotting - decay.v - v#552815
+0 ## Rotting - decompose.v - v#209837
+0 ## Rotting - putrefy.v - v#399553
+0 ## Rotting - fester.v - v#96766
+0 ## Rotting - moulder.v - v#209837
+0 ## Rotting - perish.v - v#358431
+0 ## Rotting - spoil.v - v#210259
+0 ## Rotting - rot.n - n#13458019
+0 ## Rotting - rot.v - v#209837
+0 ## Receiving - receive.v - v#2210119
+0 ## Receiving - receipt.n - n#90253
+0 ## Receiving - accept.v - v#2236124
+0 ## Eventive_cognizer_affecting - convince.v - v#769553
+0 ## Eventive_cognizer_affecting - decide.v - v#697589
+0 ## Change_event_duration - cut short.v - v#292877
+0 ## Change_event_duration - shorten.v - v#243900
+0 ## Change_event_duration - drag_out.v - v#341757
+0 ## Change_event_duration - prolong.v - v#317888
+0 ## Change_event_duration - protract.v - v#317888
+0 ## Change_event_duration - extend.v - v#317888
+0 ## Change_event_duration - abbreviate.v - v#243900
+0 ## Degree - far.adv - r#101323
+0 ## Degree - totally.adv - r#8007
+0 ## Degree - so.adv - r#146594
+0 ## Degree - somewhat.adv - r#36291
+0 ## Degree - very.adv - r#31899
+0 ## Degree - heavily.adv - r#176383
+0 ## Degree - a little.adv - r#33663
+0 ## Degree - fully.adv - r#10466
+0 ## Atonement - expiatory.a - a#2940509
+0 ## Atonement - expiation.n - n#95121
+0 ## Atonement - expiate.v - v#2520509
+0 ## Atonement - atone.v - v#2520509
+0 ## Atonement - atonement.n - n#95121
+0 ## Altered_phase - thawed.a - a#1506661
+0 ## Altered_phase - frozen.a - a#1078302
+0 ## Altered_phase - liquefied.a - a#1506526
+0 ## Altered_phase - melted.a - a#1505991
+0 ## Altered_phase - solidified.a - a#2260382
+0 ## Process_resume - resume.v - v#350104
+0 ## Time_period_of_action - window.n - n#15299783
+0 ## Influence_of_event_on_cognizer - influential.a - a#1830134
+0 ## Influence_of_event_on_cognizer - influence((mass)).n - n#5692910
+0 ## Influence_of_event_on_cognizer - influence.n - n#5692910
+0 ## Influence_of_event_on_cognizer - influence.v - v#2536557
+0 ## Influence_of_event_on_cognizer - guide.v - v#1931768
+0 ## Economy - economy.n - n#8366753
+0 ## Economy - economic.a - a#2716739
+0 ## Locale_by_use - rural.a - a#2790726
+0 ## Locale_by_use - depot.n - n#4329190
+0 ## Locale_by_use - work.n - n#4602044
+0 ## Locale_by_use - base.n - n#2798290
+0 ## Locale_by_use - university.n - n#4511002
+0 ## Locale_by_use - shop.n - n#4202417
+0 ## Locale_by_use - canal.n - n#2947212
+0 ## Locale_by_use - headquarters.n - n#3504723
+0 ## Locale_by_use - urban.a - a#2821071
+0 ## Locale_by_use - country.n - n#8497294
+0 ## Locale_by_use - factory.n - n#3316406
+0 ## Locale_by_use - airfield.n - n#2687992
+0 ## Locale_by_use - institute.n - n#8407330
+0 ## Locale_by_use - restaurant.n - n#4081281
+0 ## Locale_by_use - school.n - n#8276720
+0 ## Locale_by_use - courtyard.n - n#3120198
+0 ## Locale_by_use - campus.n - n#8518374
+0 ## Locale_by_use - installation.n - n#3315023
+0 ## Locale_by_use - center.n - n#3965456
+0 ## Locale_by_use - harbor.n - n#8639058
+0 ## Locale_by_use - reactor.n - n#3834040
+0 ## Locale_by_use - village.n - n#8672738
+0 ## Locale_by_use - field.n - n#2687992
+0 ## Locale_by_use - ranch.n - n#4052442
+0 ## Locale_by_use - laboratory.n - n#3629986
+0 ## Locale_by_use - lab.n - n#3629986
+0 ## Locale_by_use - downtown.n - n#8539072
+0 ## Locale_by_use - museum.n - n#3800563
+0 ## Locale_by_use - gallery.n - n#3412058
+0 ## Locale_by_use - farm.n - n#3322099
+0 ## Locale_by_use - zoo.n - n#3745146
+0 ## Locale_by_use - facility.n - n#3315023
+0 ## Locale_by_use - city.n - n#8524735
+0 ## Locale_by_use - hedge.n - n#3511175
+0 ## Locale_by_use - theater.n - n#4417809
+0 ## Locale_by_use - site.n - n#8651247
+0 ## Locale_by_use - college.n - n#3069752
+0 ## Locale_by_use - parking lot.n - n#8615638
+0 ## Locale_by_use - garden.n - n#3417345
+0 ## Locale_by_use - mine.n - n#3768346
+0 ## Locale_by_use - cemetery.n - n#8521623
+0 ## Locale_by_use - square.n - n#13878634
+0 ## Locale_by_use - plant.n - n#3956922
+0 ## Locale_by_use - court.n - n#8329453
+0 ## Locale_by_use - complex.n - n#2914991
+0 ## Locale_by_use - green.n - n#8615374
+0 ## Locale_by_use - park((2)).n - n#8615374
+0 ## Locale_by_use - countryside.n - n#8645033
+0 ## Locale_by_use - settlement.n - n#8226699
+0 ## Locale_by_use - pub.n - n#4018399
+0 ## Locale_by_use - silo.n - n#4220344
+0 ## Locale_by_use - post office.n - n#8145277
+0 ## Locale_by_use - port.n - n#8633957
+0 ## Locale_by_use - park.n - n#8615374
+0 ## Justifying - justification.n - n#1241767
+0 ## Justifying - justify.v - v#894738
+0 ## Justifying - defend.v - v#895304
+0 ## Justifying - account.v - v#867644
+0 ## Justifying - rationalize.v - v#894738
+0 ## Justifying - defence.n - n#6740644
+0 ## Justifying - explain.v - v#893435
+0 ## Cause_to_make_noise - toot.v - v#2183175
+0 ## Cause_to_make_noise - play.v - v#1726172
+0 ## Cause_to_make_noise - tinkle.v - v#2186506
+0 ## Cause_to_make_noise - ring.v - v#2181538
+0 ## Cause_to_make_noise - blast.v - v#2182479
+0 ## Cause_to_make_noise - honk.v - v#2183175
+0 ## Cause_to_make_noise - creak.v - v#2171664
+0 ## Cause_to_make_noise - ringer.n - n#10714851
+0 ## Cause_to_make_noise - blare.v - v#2183175
+0 ## Cause_to_make_noise - peep.v - v#1052301
+0 ## Cause_to_make_noise - clang.v - v#2174115
+0 ## Motion_directional - plummet.v - v#1978199
+0 ## Motion_directional - plunge.v - v#1967373
+0 ## Motion_directional - topple.v - v#1976488
+0 ## Motion_directional - fall.v - v#1970826
+0 ## Motion_directional - drop.v - v#1976841
+0 ## Motion_directional - angle.v - v#2038357
+0 ## Motion_directional - dip.v - v#2038145
+0 ## Motion_directional - descend.v - v#1970826
+0 ## Motion_directional - slant.v - v#2038357
+0 ## Motion_directional - rise.v - v#1968569
+0 ## Relational_natural_features - peak.n - n#8617963
+0 ## Relational_natural_features - seaboard.n - n#9428628
+0 ## Relational_natural_features - estuary.n - n#9274500
+0 ## Relational_natural_features - coast.n - n#9428293
+0 ## Relational_natural_features - shore.n - n#9433442
+0 ## Relational_natural_features - source.n - n#8507558
+0 ## Relational_natural_features - mouth.n - n#5302499
+0 ## Relational_natural_features - bank.n - n#9213565
+0 ## Relational_natural_features - delta.n - n#9264803
+0 ## Relational_natural_features - shoreline.n - n#9433839
+0 ## Relational_natural_features - summit.n - n#8617963
+0 ## Relational_natural_features - foothill.n - n#9283405
+0 ## Text_creation - type.v - v#1004692
+0 ## Text_creation - dash off.v - v#1700655
+0 ## Text_creation - compose.v - v#1698271
+0 ## Text_creation - write.v - v#1698271
+0 ## Text_creation - get down.v - v#1020356
+0 ## Text_creation - utter.v - v#940384
+0 ## Text_creation - chronicle.v - v#1001136
+0 ## Text_creation - draft.v - v#1701634
+0 ## Text_creation - pen.v - v#1698271
+0 ## Text_creation - jot down.v - v#1006056
+0 ## Text_creation - sign.v - v#996485
+0 ## Text_creation - jot.v - v#1006056
+0 ## Text_creation - print.v - v#1747945
+0 ## Text_creation - author.v - v#1704452
+0 ## Text_creation - speak.v - v#941990
+0 ## Text_creation - say.v - v#1009240
+0 ## Destiny - kismet.n - n#7330560
+0 ## Destiny - predestined.a - a#341017
+0 ## Destiny - doom.n - n#7334206
+0 ## Destiny - fortune.n - n#14473222
+0 ## Destiny - lot.n - n#14473222
+0 ## Destiny - fated.a - a#340827
+0 ## Destiny - destined.a - a#340626
+0 ## Destiny - doomed.a - a#340827
+0 ## Destiny - destiny.n - n#7330007
+0 ## Destiny - fate.n - n#7330007
+0 ## Toxic_substance - toxin.n - n#15034074
+0 ## Toxic_substance - venomous.a - a#2449952
+0 ## Toxic_substance - poison.n - n#15032376
+0 ## Toxic_substance - poisonous.a - a#2450512
+0 ## Toxic_substance - toxic.a - a#2449430
+0 ## Toxic_substance - venom.n - n#15036916
+0 ## Submitting_documents - submit.v - v#878636
+0 ## Submitting_documents - turn in.v - v#2293321
+0 ## Submitting_documents - submission.n - n#7167578
+0 ## Submitting_documents - file.v - v#1001857
+0 ## Coincidence - chance.v - v#2594102
+0 ## Coincidence - chance.a - a#1798162
+0 ## Coincidence - happen.v - v#339934
+0 ## Coincidence - happenstance.n - n#7316999
+0 ## Coincidence - chance.n - n#11418138
+0 ## Coincidence - coincidence.n - n#7316999
+0 ## Coincidence - random.a - a#1924316
+0 ## Coincidence - accident.n - n#7300960
+0 ## Coincidence - randomly.adv - r#70765
+0 ## Cause_to_start - engender.v - v#54628
+0 ## Cause_to_start - actuate.v - v#1649999
+0 ## Cause_to_start - provoke.v - v#1759326
+0 ## Cause_to_start - spark.v - v#2766687
+0 ## Cause_to_start - stimulate.v - v#1761706
+0 ## Cause_to_start - elicit.v - v#1759326
+0 ## Cause_to_start - set off.v - v#851239
+0 ## Cause_to_start - stir up.v - v#851239
+0 ## Cause_to_start - call forth.v - v#1629958
+0 ## Cause_to_start - generate.v - v#1629000
+0 ## Cause_to_start - instigate.v - v#851239
+0 ## Cause_to_start - bring about.v - v#1752884
+0 ## Cause_to_start - produce.v - v#1752884
+0 ## Cause_to_start - kindle.v - v#1759326
+0 ## Cause_to_start - create.v - v#1617192
+0 ## Cause_to_start - motivate.v - v#1649999
+0 ## Cause_to_start - incite.v - v#851239
+0 ## Cause_to_start - arouse.v - v#1759326
+0 ## Cause_to_start - prompt.v - v#771961
+0 ## Getting_up - rise.v - v#18158
+0 ## Getting_up - get up.v - v#18158
+0 ## Temporary_stay - lodge.v - v#2651424
+0 ## Temporary_stay - sleep over.v - v#2652729
+0 ## Temporary_stay - stay.v - v#117985
+0 ## Temporary_stay - room.v - v#2656763
+0 ## Temporary_stay - quarter.v - v#2653159
+0 ## Temporary_stay - board.v - v#2656763
+0 ## Temporary_stay - stay over.v - v#2652729
+0 ## Temporary_stay - stay.n - n#1053617
+0 ## Medical_instruments - laparoscope.n - n#3642144
+0 ## Medical_instruments - stethoscope.n - n#4317175
+0 ## Medical_instruments - catheter.n - n#2984469
+0 ## Medical_instruments - otoscope.n - n#3858183
+0 ## Medical_instruments - sigmoidoscope.n - n#4217387
+0 ## Medical_instruments - forceps.n - n#3381231
+0 ## Medical_instruments - fluoroscope.n - n#3370646
+0 ## Medical_instruments - syringe.n - n#4376876
+0 ## Medical_instruments - scalpel.n - n#4142434
+0 ## Medical_instruments - endoscope.n - n#3286572
+0 ## Medical_instruments - needle.n - n#13157595
+0 ## Medical_instruments - gastroscope.n - n#3426462
+0 ## Medical_instruments - colonoscope.n - n#3071288
+0 ## Medical_instruments - ophthalmoscope.n - n#3850613
+0 ## Medical_instruments - oscilloscope.n - n#3857828
+0 ## Medical_instruments - bronchoscope.n - n#2905886
+0 ## Medical_instruments - speculum.n - n#4273433
+0 ## Clarity_of_resolution - decisiveness.n - n#4863969
+0 ## Clarity_of_resolution - narrow.a - a#2561888
+0 ## Clarity_of_resolution - narrowly.adv - r#221429
+0 ## Clarity_of_resolution - close.a - a#446921
+0 ## Clarity_of_resolution - decisive.a - a#684480
+0 ## Take_place_of - take place.v - v#339934
+0 ## Take_place_of - replace.v - v#2405390
+0 ## Take_place_of - succeed.v - v#2406585
+0 ## Take_place_of - substitute.v - v#2257767
+0 ## Take_place_of - replacement.n - n#10680153
+0 ## Manipulation - kiss.v - v#1431230
+0 ## Manipulation - paw.v - v#1211098
+0 ## Manipulation - diddle.v - v#1586278
+0 ## Manipulation - clasp.v - v#1222328
+0 ## Manipulation - tweak.v - v#1592669
+0 ## Manipulation - grope.v - v#1211263
+0 ## Manipulation - stroke.n - n#144632
+0 ## Manipulation - pull.n - n#114431
+0 ## Manipulation - pinch.v - v#1456771
+0 ## Manipulation - tickle.v - v#1431987
+0 ## Manipulation - rub.v - v#1249724
+0 ## Manipulation - nudge.v - v#1231252
+0 ## Manipulation - tug.v - v#1452918
+0 ## Manipulation - nip.v - v#1456771
+0 ## Manipulation - wring.v - v#2241107
+0 ## Manipulation - caress.v - v#1226215
+0 ## Manipulation - pull.v - v#1448100
+0 ## Manipulation - claw.v - v#1213504
+0 ## Manipulation - seize.v - v#1212572
+0 ## Manipulation - grip.v - v#1224001
+0 ## Manipulation - knead.v - v#1232738
+0 ## Manipulation - clutch.v - v#1212572
+0 ## Manipulation - fumble.v - v#1314738
+0 ## Manipulation - push.v - v#1871979
+0 ## Manipulation - yank.v - v#1592072
+0 ## Manipulation - lick.v - v#1432176
+0 ## Manipulation - massage.v - v#1232738
+0 ## Manipulation - grasp.v - v#1216004
+0 ## Manipulation - handle.v - v#1210737
+0 ## Manipulation - grab.v - v#1439190
+0 ## Manipulation - squeeze.v - v#1456771
+0 ## Manipulation - touch.v - v#1206218
+0 ## Manipulation - caress.n - n#144778
+0 ## Manipulation - stroke.v - v#1225970
+0 ## Manipulation - hold.v - v#1216670
+0 ## Manipulation - finger.v - v#1209953
+0 ## Cause_to_rot - putrefy.v - v#399553
+0 ## Cause_to_rot - rot.v - v#209837
+0 ## Judicial_body - tribunal.n - n#8329453
+0 ## Judicial_body - judiciary.n - n#8166318
+0 ## Judicial_body - court.n - n#8329453
+0 ## Judicial_body - judicial.a - a#1400961
+0 ## Quarreling - bickering.n - n#7184735
+0 ## Quarreling - tiff.n - n#7184735
+0 ## Quarreling - squabble.v - v#774056
+0 ## Quarreling - disputation.n - n#7183151
+0 ## Quarreling - bicker.v - v#774056
+0 ## Quarreling - dispute.n - n#7181935
+0 ## Quarreling - spat.n - n#7184735
+0 ## Quarreling - disagreement.n - n#7180787
+0 ## Quarreling - argument.n - n#7183151
+0 ## Quarreling - quarrel.n - n#7184149
+0 ## Quarreling - fight.n - n#7184391
+0 ## Quarreling - row.v - v#1946996
+0 ## Quarreling - row.n - n#7184149
+0 ## Quarreling - quarrel.v - v#775156
+0 ## Quarreling - altercation.n - n#7184545
+0 ## Quarreling - argue.v - v#773432
+0 ## Quarreling - wrangling.n - n#7150138
+0 ## Quarreling - quibble.v - v#774056
+0 ## Quarreling - squabble.n - n#7184735
+0 ## Quarreling - fight.v - v#1090335
+0 ## Quarreling - wrangle.v - v#774344
+0 ## Quarreling - wrangle.n - n#7184149
+0 ## Passing_off - pass off.v - v#2052965
+0 ## Passing_off - palm off.v - v#2244426
+0 ## Containing - contain.v - v#2629535
+0 ## Containing - hold.v - v#2732798
+0 ## Containing - house.v - v#2701828
+0 ## Representing - symbolize.v - v#836236
+0 ## Hear - hear.v - v#2169702
+0 ## Hear - read.v - v#625119
+0 ## Artifact - technology.n - n#6125041
+0 ## Artifact - artifact.n - n#21939
+0 ## Artifact - wheel.n - n#4574999
+0 ## Artifact - biotechnology.n - n#6126523
+0 ## Trying_out - try.v - v#2530167
+0 ## Trying_out - try_out.v - v#2531625
+0 ## Guest_and_host - host.n - n#10187130
+0 ## Guest_and_host - guest.n - n#10150940
+0 ## Pattern - pattern.n - n#5930736
+0 ## Pattern - formation.n - n#8426461
+0 ## Emotion_heat - smoulder.v - v#1772699
+0 ## Emotion_heat - chafe.v - v#2119659
+0 ## Emotion_heat - burn.v - v#377002
+0 ## Emotion_heat - boil.v - v#328128
+0 ## Emotion_heat - fume.v - v#1795333
+0 ## Emotion_heat - simmer.v - v#324231
+0 ## Emotion_heat - stew.v - v#1805384
+0 ## Emotion_heat - seethe.v - v#1767612
+0 ## Imposing_obligation - require.v - v#2627934
+0 ## Imposing_obligation - charge.v - v#2347637
+0 ## Imposing_obligation - commit.v - v#2349212
+0 ## Imposing_obligation - obligate.v - v#885217
+0 ## Imposing_obligation - pledge.v - v#884946
+0 ## Imposing_obligation - charge.n - n#9909760
+0 ## Imposing_obligation - bind.v - v#885217
+0 ## Achieving_first - discover.v - v#1637982
+0 ## Achieving_first - originator.n - n#10383816
+0 ## Achieving_first - pioneer.n - n#10434725
+0 ## Achieving_first - invent.v - v#1632411
+0 ## Achieving_first - pioneer.v - v#1645421
+0 ## Achieving_first - discoverer.n - n#10214637
+0 ## Achieving_first - invention.n - n#940412
+0 ## Achieving_first - originate.v - v#1628449
+0 ## Achieving_first - coin.v - v#1697986
+0 ## Achieving_first - coinage.n - n#940560
+0 ## Achieving_first - discovery.n - n#43195
+0 ## Achieving_first - inventor.n - n#10214637
+0 ## Store - supply.n - n#13777344
+0 ## Store - reserve.n - n#13368052
+0 ## Store - stockpile.n - n#13368052
+0 ## Store - inventory.n - n#4321534
+0 ## Store - cargo.n - n#2964389
+0 ## Store - stock.n - n#13367070
+0 ## Store - store.n - n#13367070
+0 ## Aging - aging.a - a#1644709
+0 ## Aging - age.v - v#248026
+0 ## Aging - mature.v - v#248026
+0 ## Traversing - cross.v - v#1912159
+0 ## Traversing - leap.v - v#1963942
+0 ## Traversing - circle.v - v#1911339
+0 ## Traversing - traverse.v - v#1912159
+0 ## Traversing - skirt.v - v#2052090
+0 ## Traversing - pass.v - v#2050132
+0 ## Traversing - mount.v - v#433232
+0 ## Traversing - descend.v - v#1970826
+0 ## Traversing - ascend.v - v#2105657
+0 ## Traversing - descent.n - n#326440
+0 ## Traversing - crisscross.v - v#1913237
+0 ## Traversing - hop.v - v#1966861
+0 ## Traversing - jump.v - v#1963942
+0 ## Traversing - ascent.n - n#324384
+0 ## Used_up - spent.a - a#926141
+0 ## Used_up - exhausted.a - a#2433451
+0 ## Used_up - through.a - a#1003536
+0 ## Used_up - depleted.a - a#2336759
+0 ## Used_up - worn out.a - a#2433451
+0 ## Subjective_influence - drive.v - v#1506157
+0 ## Subjective_influence - influential.a - a#1830134
+0 ## Subjective_influence - impact.v - v#137313
+0 ## Subjective_influence - impact.n - n#11414411
+0 ## Subjective_influence - inspiration.n - n#5834567
+0 ## Subjective_influence - influence.n - n#157081
+0 ## Subjective_influence - inspire.v - v#1646682
+0 ## Subjective_influence - motivate.v - v#1649999
+0 ## Subjective_influence - effect.n - n#11410625
+0 ## Subjective_influence - galvanize.v - v#1821634
+0 ## Subjective_influence - influence.v - v#2536557
+0 ## Subjective_influence - push.v - v#1871979
+0 ## Court_examination - cross-examination.n - n#7194950
+0 ## Court_examination - examination.n - n#7193958
+0 ## Court_examination - cross.n - n#3135532
+0 ## Court_examination - examine.v - v#788564
+0 ## Reassuring - reassurance.n - n#1215719
+0 ## Reassuring - reassure.v - v#1766407
+0 ## Verdict - acquit.v - v#904046
+0 ## Verdict - not_guilty.a - a#1320474
+0 ## Verdict - convict.v - v#906367
+0 ## Verdict - pronounce.v - v#971650
+0 ## Verdict - verdict.n - n#1192150
+0 ## Verdict - conviction.n - n#5942888
+0 ## Verdict - find.v - v#2248465
+0 ## Verdict - ruling.n - n#1191158
+0 ## Verdict - acquittal.n - n#1193886
+0 ## Verdict - finding.n - n#151497
+0 ## Verdict - clear.v - v#904046
+0 ## Verdict - guilty.a - a#1320988
+0 ## Locative_relation - elsewhere.adv - r#85002
+0 ## Locative_relation - touch.v - v#1205696
+0 ## Locative_relation - mainland.n - n#9346120
+0 ## Locative_relation - contact.v - v#1205696
+0 ## Locative_relation - abut.v - v#1466978
+0 ## Locative_relation - neighboring.a - a#566342
+0 ## Locative_relation - surrounding.a - a#449332
+0 ## Locative_relation - inland.a - a#463784
+0 ## Locative_relation - neighbor.v - v#2608004
+0 ## Locative_relation - there.adv - r#109151
+0 ## Locative_relation - offshore.a - a#464399
+0 ## Locative_relation - outlying.a - a#444399
+0 ## Locative_relation - bracket.v - v#1218791
+0 ## Locative_relation - ubiquitous.a - a#1847515
+0 ## Locative_relation - underground.adv - r#486917
+0 ## Locative_relation - adjoin.v - v#1466978
+0 ## Locative_relation - underground.a - a#2471984
+0 ## Locative_relation - border.v - v#1466978
+0 ## Locative_relation - meet.v - v#1205696
+0 ## Locative_relation - adjacent.a - a#566342
+0 ## Locative_relation - here.adv - r#108479
+0 ## Locative_relation - everywhere.adv - r#25728
+0 ## Locative_relation - distant.a - a#443075
+0 ## Departing - set out.v - v#2014165
+0 ## Departing - exodus.n - n#60414
+0 ## Departing - leave.v - v#2009433
+0 ## Departing - decamp.v - v#2010698
+0 ## Departing - disappearance.n - n#53609
+0 ## Departing - exit.n - n#58519
+0 ## Departing - escape.v - v#2074677
+0 ## Departing - vamoose.v - v#2010698
+0 ## Departing - depart.v - v#1848718
+0 ## Departing - exit.v - v#2015598
+0 ## Departing - set off.v - v#2014165
+0 ## Departing - disappear.v - v#426958
+0 ## Departing - departure.n - n#42757
+0 ## Departing - vanish.v - v#426958
+0 ## Departing - skedaddle.v - v#2075764
+0 ## Departing - emerge.v - v#528990
+0 ## Departing - escape.n - n#58743
+0 ## Commerce_collect - bill.v - v#2320374
+0 ## Commerce_collect - charge.v - v#2320374
+0 ## Commerce_collect - collect.v - v#2218173
+0 ## People_by_morality - villain.n - n#10753546
+0 ## People_by_morality - malefactor.n - n#9977660
+0 ## People_by_morality - reprobate.n - n#10522324
+0 ## People_by_morality - evildoer.n - n#10601078
+0 ## People_by_morality - saint.n - n#10547145
+0 ## People_by_morality - miscreant.n - n#10522324
+0 ## People_by_morality - sinner.n - n#10601078
+0 ## People_by_morality - delinquent.n - n#10000945
+0 ## People_by_morality - fink.n - n#10091012
+0 ## People_by_morality - degenerate.n - n#10419047
+0 ## People_by_morality - wrongdoer.n - n#9633969
+0 ## Labeling - brand.v - v#2508245
+0 ## Labeling - call.v - v#1028748
+0 ## Labeling - term.v - v#1029642
+0 ## Labeling - label.v - v#1029852
+0 ## Terrorism - terror.n - n#759500
+0 ## Terrorism - ecoterrorism.n - n#764031
+0 ## Terrorism - ecoterrorism.n - n#764031
+0 ## Terrorism - terrorism.n - n#759694
+0 ## Terrorism - bioterrorism.n - n#763132
+0 ## Terrorism - terrorist.n - n#10702781
+0 ## Delivery - deliver.v - v#1438304
+0 ## Delivery - delivery.n - n#317207
+0 ## Commerce_pay - disbursement.n - n#1122149
+0 ## Commerce_pay - shell_out.v - v#2294436
+0 ## Commerce_pay - payment.n - n#1120448
+0 ## Commerce_pay - disburse.v - v#2301502
+0 ## Commerce_pay - pay.v - v#2251743
+0 ## Fining - damages.n - n#13290676
+0 ## Fining - mulct.v - v#2307412
+0 ## Fining - ticket.n - n#6558678
+0 ## Fining - ticket.v - v#2498716
+0 ## Fining - fine.n - n#13301328
+0 ## Fining - fine.v - v#2498716
+0 ## Fining - amerce.v - v#2498987
+0 ## Being_obligated - obligated.a - a#1616474
+0 ## Being_obligated - assignment.n - n#730247
+0 ## Being_obligated - bound.a - a#1064806
+0 ## Being_obligated - task.n - n#719705
+0 ## Being_obligated - mission.n - n#731222
+0 ## Being_obligated - obligation.n - n#1129920
+0 ## Being_obligated - commission.n - n#731222
+0 ## Being_obligated - duty.n - n#719494
+0 ## Being_obligated - job.n - n#584769
+0 ## Being_obligated - responsibility.n - n#1129920
+0 ## Being_obligated - contract.n - n#6520944
+0 ## Subversion - sabotage.v - v#2543607
+0 ## Subversion - undermine.v - v#2543607
+0 ## Subversion - subversion.n - n#215838
+0 ## Subversion - subvert.v - v#2543607
+0 ## Subversion - undercut.v - v#2351467
+0 ## Be_in_agreement_on_action - convention.n - n#6774316
+0 ## Be_in_agreement_on_action - agreement.n - n#6770275
+0 ## Be_in_agreement_on_action - accord.n - n#6773434
+0 ## Be_in_agreement_on_action - deal.n - n#6771159
+0 ## Be_in_agreement_on_action - treaty.n - n#6773434
+0 ## Location_in_time - date.n - n#15160579
+0 ## Location_in_time - time.n - n#7309599
+0 ## Means - course_of_action.n - n#38262
+0 ## Means - mechanism.n - n#13512506
+0 ## Means - procedure.n - n#1023820
+0 ## Means - technique.n - n#5665146
+0 ## Means - means.n - n#172710
+0 ## Means - recipe_((cooking)).n - n#6788785
+0 ## Means - method.n - n#5660268
+0 ## Means - tactic.n - n#5905152
+0 ## Means - nuts_and_bolts.n - n#6642518
+0 ## Means - modus_operandi.n - n#1026482
+0 ## Means - way.n - n#4928903
+0 ## Means - approach.n - n#941140
+0 ## Means - process.n - n#1023820
+0 ## Board_vehicle - embarkment.n - n#58337
+0 ## Board_vehicle - entrain.v - v#1979624
+0 ## Board_vehicle - mount.v - v#1921964
+0 ## Board_vehicle - embarkation.n - n#58337
+0 ## Board_vehicle - get.v - v#2210855
+0 ## Board_vehicle - emplane.v - v#2018265
+0 ## Board_vehicle - hop.v - v#1966861
+0 ## Board_vehicle - embark.v - v#1979462
+0 ## Board_vehicle - board.v - v#2018049
+0 ## Avoiding - desist.v - v#1196037
+0 ## Avoiding - duck.v - v#809654
+0 ## Avoiding - evasion.n - n#59127
+0 ## Avoiding - keep_away.v - v#2451113
+0 ## Avoiding - escape.v - v#2074677
+0 ## Avoiding - forgo.v - v#2534062
+0 ## Avoiding - dodge.v - v#809654
+0 ## Avoiding - sidestep.n - n#286360
+0 ## Avoiding - sidestep.v - v#809654
+0 ## Avoiding - evade.v - v#809654
+0 ## Avoiding - shirk.v - v#2463704
+0 ## Avoiding - stay away.v - v#2655698
+0 ## Avoiding - avoid.v - v#811375
+0 ## Avoiding - shrink_from.v - v#2463704
+0 ## Avoiding - avoidance.n - n#203753
+0 ## Avoiding - eschew.v - v#812149
+0 ## Avoiding - shun.v - v#812149
+0 ## Avoiding - skirt.v - v#809654
+0 ## Contrition - rueful.a - a#1743506
+0 ## Contrition - repentance.n - n#7536870
+0 ## Contrition - unrepentant.a - a#1957712
+0 ## Contrition - repentant.a - a#1743217
+0 ## Contrition - penitent.a - a#1743217
+0 ## Contrition - repent.v - v#1796582
+0 ## Contrition - remorseless.a - a#1508086
+0 ## Contrition - sorry.a - a#1150475
+0 ## Contrition - contrite.a - a#1743506
+0 ## Contrition - rue.v - v#1796582
+0 ## Contrition - guilty.a - a#154583
+0 ## Contrition - remorse.n - n#7536074
+0 ## Contrition - remorseful.a - a#1743506
+0 ## Contrition - contrition.n - n#7534700
+0 ## Contrition - penitence.n - n#7536870
+0 ## Contrition - guilt.n - n#7536245
+0 ## Cause_to_perceive - present.v - v#2148788
+0 ## Cause_to_perceive - demonstrate.v - v#2148788
+0 ## Cause_to_perceive - show.v - v#2148788
+0 ## Cause_to_perceive - point.v - v#923793
+0 ## Cause_to_perceive - represent.v - v#1686132
+0 ## Cause_to_perceive - exhibit.v - v#2148788
+0 ## Cause_to_perceive - depict.v - v#1686956
+0 ## Building - construction.n - n#911048
+0 ## Building - glue.v - v#1332205
+0 ## Building - assembly.n - n#912001
+0 ## Building - raise.v - v#1661243
+0 ## Building - build.v - v#1654628
+0 ## Building - make.v - v#1617192
+0 ## Building - construct.v - v#1654628
+0 ## Building - fashion.v - v#1658188
+0 ## Building - weld.v - v#1595830
+0 ## Building - assemble.v - v#1656788
+0 ## Building - erect.v - v#1661243
+0 ## Name_conferral - baptize.v - v#1028079
+0 ## Name_conferral - name.v - v#1028748
+0 ## Name_conferral - christen.v - v#1028079
+0 ## Name_conferral - dub.v - v#1028640
+0 ## Name_conferral - entitle.v - v#1029500
+0 ## Name_conferral - rename.v - v#1029212
+0 ## Name_conferral - nickname.v - v#1028640
+0 ## Amounting_to - tally.n - n#189565
+0 ## Amounting_to - total.v - v#2645007
+0 ## Amounting_to - amount.v - v#2645007
+0 ## Amounting_to - total.n - n#5861067
+0 ## Amounting_to - total.a - a#515380
+0 ## Amounting_to - number.v - v#948071
+0 ## Measure_area - hectare.n - n#13613985
+0 ## Measure_area - acre.n - n#13613742
+0 ## Appeal - plead.v - v#759501
+0 ## Appeal - appellant.n - n#9800469
+0 ## Appeal - appeal.v - v#755447
+0 ## Appeal - appeal.n - n#1185611
+0 ## Appeal - appellate.a - a#3044083
+0 ## Locale_by_event - battlefield.n - n#8506641
+0 ## Locale_by_event - site.n - n#8651247
+0 ## Locale_by_event - scene.n - n#8645963
+0 ## Locale_by_event - theater_((of_war)).n - n#8551628
+0 ## Locale_by_event - field.n - n#8506641
+0 ## Locale_by_event - venue.n - n#8677628
+0 ## Trust - faith.n - n#5943066
+0 ## Trust - gullible.a - a#2272485
+0 ## Trust - credence.n - n#6193727
+0 ## Trust - trustworthy.a - a#2464693
+0 ## Trust - reliable.a - a#724081
+0 ## Trust - believe.v - v#683280
+0 ## Trust - trust.n - n#5943066
+0 ## Trust - trust.v - v#688377
+0 ## Trust - credulous.a - a#646413
+0 ## Trust - reliability.n - n#4670022
+0 ## Measure_mass - gram.n - n#13723712
+0 ## Measure_mass - ton.n - n#13721529
+0 ## Measure_mass - kilogram.n - n#13724582
+0 ## Measure_mass - kilo.n - n#13724582
+0 ## Measure_mass - metric ton.n - n#13725588
+0 ## Measure_mass - pound.n - n#13720096
+0 ## Measure_mass - milligram.n - n#13723061
+0 ## Measure_mass - ounce.n - n#13719922
+0 ## Forgiveness - excuse.v - v#905852
+0 ## Forgiveness - condone.v - v#893167
+0 ## Forgiveness - forgive.v - v#903385
+0 ## Forgiveness - forgiveness.n - n#1227190
+0 ## Forgiveness - pardon.v - v#905852
+0 ## Active_substance - irritant.n - n#5831784
+0 ## Active_substance - agent.n - n#9190918
+0 ## Active_substance - active.a - a#42457
+0 ## Extradition - extradite.v - v#2503365
+0 ## Extradition - extradition.n - n#213482
+0 ## Body_description_part - blonde.n - n#9860506
+0 ## Body_description_part - bearded.a - a#2153965
+0 ## Body_description_part - albino.n - n#9781650
+0 ## Body_description_part - knock-kneed.a - a#1019587
+0 ## Body_description_part - cross-eyed.a - a#653514
+0 ## Body_description_part - redhead.n - n#10513823
+0 ## Body_description_part - brunette.n - n#9877856
+0 ## Body_description_part - fair.a - a#244054
+0 ## Body_description_part - black-haired.a - a#245319
+0 ## Body_description_part - flat-footed.a - a#1031405
+0 ## Body_description_part - grey-haired.a - a#1645678
+0 ## Body_description_part - blue-eyed.a - a#953814
+0 ## Posing_as - masquerade.v - v#837617
+0 ## Posing_as - pose.v - v#837288
+0 ## Posing_as - impostor.n - n#10201535
+0 ## Posing_as - impersonation.n - n#6780069
+0 ## Posing_as - impersonate.v - v#837288
+0 ## Emotions_of_mental_activity - delight.n - n#5829782
+0 ## Emotions_of_mental_activity - groove.v - v#1457489
+0 ## Emotions_of_mental_activity - enjoy.v - v#1820302
+0 ## Emotions_of_mental_activity - delight (in).v - v#1190948
+0 ## Emotions_of_mental_activity - drudgery.n - n#621476
+0 ## Emotions_of_mental_activity - pleasure.n - n#7490713
+0 ## Emotions_of_mental_activity - enjoyment.n - n#7491708
+0 ## Emotions_of_mental_activity - relish.v - v#1820302
+0 ## Emotions_of_mental_activity - luxuriate.v - v#1191645
+0 ## Emotions_of_mental_activity - savour.v - v#1820302
+0 ## Fastener - seal.n - n#4159058
+0 ## Fastener - button.n - n#2928608
+0 ## Fastener - zipper.n - n#4238321
+0 ## Fastener - buckle.n - n#2910353
+0 ## Point_of_dispute - question.n - n#6783768
+0 ## Point_of_dispute - issue.n - n#5814650
+0 ## Point_of_dispute - concern.n - n#5670710
+0 ## Light_movement - scintillation.n - n#4952944
+0 ## Light_movement - glint.n - n#7412310
+0 ## Light_movement - gleam.n - n#4954534
+0 ## Light_movement - sheen.n - n#4954683
+0 ## Light_movement - glimmer.n - n#7412478
+0 ## Light_movement - glistening.a - a#281657
+0 ## Light_movement - glister.n - n#4952944
+0 ## Light_movement - glisten.v - v#2162947
+0 ## Light_movement - flash.v - v#2159890
+0 ## Light_movement - flare.v - v#2762981
+0 ## Light_movement - glitter.v - v#2162947
+0 ## Light_movement - glow.v - v#2161530
+0 ## Light_movement - glow.n - n#4954534
+0 ## Light_movement - coruscation.n - n#7412668
+0 ## Light_movement - glint.v - v#2162947
+0 ## Light_movement - shine.v - v#2763740
+0 ## Light_movement - glitter.n - n#4952944
+0 ## Light_movement - coruscate.v - v#2766390
+0 ## Light_movement - gleam.v - v#2162947
+0 ## Light_movement - twinkle.v - v#2159890
+0 ## Light_movement - shimmer.v - v#2706478
+0 ## Light_movement - shine.n - n#4953954
+0 ## Light_movement - twinkle.n - n#7411645
+0 ## Light_movement - glimmer.v - v#2160779
+0 ## Light_movement - scintillate.v - v#2764765
+0 ## Light_movement - flicker.v - v#2160177
+0 ## Light_movement - sparkle.v - v#2766390
+0 ## Light_movement - flicker.n - n#7412310
+0 ## Light_movement - flash.n - n#7412092
+0 ## Light_movement - flame.v - v#2762981
+0 ## Light_movement - refulgence.n - n#4953954
+0 ## Offenses - battery.n - n#768203
+0 ## Offenses - copyright infringement.n - n#770834
+0 ## Offenses - child abuse.n - n#420218
+0 ## Offenses - manslaughter.n - n#220409
+0 ## Offenses - assault.n - n#767826
+0 ## Offenses - sexual harassment.n - n#425781
+0 ## Offenses - homicide.n - n#220023
+0 ## Offenses - possession.n - n#809465
+0 ## Offenses - negligence.n - n#739270
+0 ## Offenses - murder.n - n#220522
+0 ## Offenses - robbery.n - n#781685
+0 ## Offenses - arson.n - n#378296
+0 ## Offenses - hijacking.n - n#783199
+0 ## Offenses - sabotage.n - n#1244895
+0 ## Offenses - sexual assault.n - n#774107
+0 ## Offenses - burglary.n - n#785045
+0 ## Offenses - felony.n - n#768701
+0 ## Offenses - theft.n - n#780889
+0 ## Offenses - larceny.n - n#780889
+0 ## Offenses - treason.n - n#782072
+0 ## Offenses - kidnapping.n - n#775702
+0 ## Offenses - conspiracy.n - n#8251303
+0 ## Offenses - statutory rape.n - n#846961
+0 ## Offenses - fraud.n - n#769092
+0 ## Offenses - rape.n - n#773402
+0 ## Color - green.n - n#4967191
+0 ## Color - purple.a - a#380312
+0 ## Color - azure.a - a#370267
+0 ## Color - crimson.a - a#381097
+0 ## Color - maroon.a - a#377702
+0 ## Color - puce.n - n#4974145
+0 ## Color - vermilion.a - a#385188
+0 ## Color - pink.a - a#379595
+0 ## Color - black.a - a#392812
+0 ## Color - gray.a - a#389310
+0 ## Color - scarlet.a - a#381097
+0 ## Color - indigo.n - n#4970398
+0 ## Color - beige.a - a#370501
+0 ## Color - color.n - n#4956594
+0 ## Color - violet.a - a#380312
+0 ## Color - red.a - a#381097
+0 ## Color - ebony.a - a#389231
+0 ## Color - orange.a - a#378892
+0 ## Color - mauve.a - a#377890
+0 ## Color - tan.a - a#384533
+0 ## Color - buff.a - a#372476
+0 ## Color - white.a - a#393105
+0 ## Color - blue.a - a#370869
+0 ## Color - yellow.a - a#385756
+0 ## Color - brown.a - a#372111
+0 ## Exercising - exercise.v - v#100551
+0 ## Exercising - exercise.n - n#624738
+0 ## Exercising - work out.v - v#99721
+0 ## Successfully_communicate_message - get across.v - v#744904
+0 ## Successfully_communicate_message - get through.v - v#2021921
+0 ## Successfully_communicate_message - convey.v - v#928630
+0 ## Dominate_situation - predominate.v - v#2644234
+0 ## Dominate_situation - dominate.v - v#2644234
+0 ## Dominate_situation - dominant.a - a#791227
+0 ## Dominate_situation - domination.n - n#1128390
+0 ## Exertive_force - strong.a - a#2321009
+0 ## Exertive_force - weak.a - a#2324397
+0 ## Exertive_force - mighty.a - a#1826575
+0 ## Talking_into - influence.v - v#776523
+0 ## Talking_into - induce.v - v#770437
+0 ## Talking_into - lead.v - v#771632
+0 ## Talking_into - incite.v - v#851239
+0 ## Talking_into - inspire.v - v#771961
+0 ## Talking_into - talk.v - v#962447
+0 ## Physical_artworks - photo.n - n#3925226
+0 ## Physical_artworks - statuette.n - n#3336459
+0 ## Physical_artworks - statue.n - n#4306847
+0 ## Physical_artworks - picture.n - n#3925226
+0 ## Physical_artworks - sculpture.n - n#4157320
+0 ## Physical_artworks - bronze.n - n#2906175
+0 ## Physical_artworks - drawing.n - n#935940
+0 ## Physical_artworks - painting.n - n#936620
+0 ## Physical_artworks - photograph.n - n#3925226
+0 ## Physical_artworks - image.n - n#5928118
+0 ## Physical_artworks - diagram.n - n#3186399
+0 ## Physical_artworks - poster.n - n#9854510
+0 ## Cooking_creation - cook up.v - v#1666131
+0 ## Cooking_creation - bake.v - v#319886
+0 ## Cooking_creation - prepare.v - v#1664172
+0 ## Cooking_creation - cook.v - v#1664172
+0 ## Cooking_creation - whip_up.v - v#1666002
+0 ## Cooking_creation - concoct.v - v#1666131
+0 ## Cooking_creation - make.v - v#2560585
+0 ## Travel - traveler.n - n#9629752
+0 ## Travel - travel.v - v#1843055
+0 ## Travel - voyage.v - v#1846320
+0 ## Travel - expedition.n - n#311809
+0 ## Travel - pilgrimage.n - n#311687
+0 ## Travel - jaunt.n - n#311809
+0 ## Travel - getaway.n - n#5061003
+0 ## Travel - tour.v - v#1845229
+0 ## Travel - voyage.n - n#312784
+0 ## Travel - safari.n - n#309906
+0 ## Travel - commute.v - v#2061846
+0 ## Travel - excursion.n - n#311809
+0 ## Travel - junket.n - n#311809
+0 ## Travel - journey.v - v#1845720
+0 ## Travel - trip.n - n#308370
+0 ## Travel - odyssey.n - n#308279
+0 ## Travel - journey.n - n#306426
+0 ## Travel - tour.n - n#310666
+0 ## Travel - travel.n - n#295701
+0 ## Travel - peregrination.n - n#296478
+0 ## Ingredients - component.n - n#5868954
+0 ## Ingredients - ingredient.n - n#3570709
+0 ## Ingredients - element.n - n#5868954
+0 ## Ingredients - material.n - n#14580897
+0 ## Ingredients - precursor.n - n#14583066
+0 ## Cardinal_numbers - five hundred.num - n#13750712
+0 ## Cardinal_numbers - two.num - n#13743269
+0 ## Cardinal_numbers - one.num - n#13742573
+0 ## Cardinal_numbers - thirty.num - n#13749407
+0 ## Cardinal_numbers - fifty.num - n#13749644
+0 ## Cardinal_numbers - forty.num - n#13749527
+0 ## Cardinal_numbers - fifteen.num - n#13747469
+0 ## Cardinal_numbers - pair.n - n#13743605
+0 ## Cardinal_numbers - fourteen.n - n#13747348
+0 ## Cardinal_numbers - million.num - n#13776432
+0 ## Cardinal_numbers - dual.a - a#2217452
+0 ## Cardinal_numbers - score.n - n#8272652
+0 ## Cardinal_numbers - ten.num - n#13746512
+0 ## Cardinal_numbers - five.num - n#13744521
+0 ## Cardinal_numbers - eight.num - n#13745086
+0 ## Cardinal_numbers - twenty.num - n#13748128
+0 ## Cardinal_numbers - zero.num - n#13742358
+0 ## Cardinal_numbers - three.num - n#13744044
+0 ## Cardinal_numbers - ninety.num - n#13750297
+0 ## Cardinal_numbers - twelve.num - n#13746785
+0 ## Cardinal_numbers - hundred.num - n#13750415
+0 ## Cardinal_numbers - couple.n - n#13743605
+0 ## Cardinal_numbers - 1000.num - n#13750844
+0 ## Cardinal_numbers - seventy.num - n#13749894
+0 ## Cardinal_numbers - billion.num - n#13776432
+0 ## Cardinal_numbers - four.num - n#13744304
+0 ## Cardinal_numbers - seven.num - n#13744916
+0 ## Cardinal_numbers - brace.n - n#13743605
+0 ## Cardinal_numbers - twenty-one.num - n#13748246
+0 ## Cardinal_numbers - six.num - n#13744722
+0 ## Cardinal_numbers - twenty-five.num - n#13748763
+0 ## Cardinal_numbers - sixty.num - n#13749778
+0 ## Suspiciousness - dubious.a - a#1916979
+0 ## Suspiciousness - fishy.a - a#1917594
+0 ## Suspiciousness - questionable.a - a#1916229
+0 ## Suspiciousness - suspect.a - a#1917594
+0 ## Suspiciousness - suspicious.a - a#1917594
+0 ## Abandonment - abandon.v - v#2076676
+0 ## Abandonment - abandoned.a - a#1313004
+0 ## Abandonment - abandonment.n - n#204439
+0 ## Abandonment - forget.v - v#610167
+0 ## Abandonment - leave.v - v#2009433
+0 ## Defend - defender.n - n#9614684
+0 ## Defend - biodefense.n - n#961594
+0 ## Defend - defend.v - v#1127795
+0 ## Defend - hold.v - v#2681795
+0 ## Defend - defense.n - n#954311
+0 ## Defend - defensive.a - a#1630117
+0 ## Food - cereal.n - n#7702796
+0 ## Food - lettuce.n - n#13385216
+0 ## Food - berry.n - n#13137409
+0 ## Food - pasta.n - n#7698915
+0 ## Food - herb.n - n#12205694
+0 ## Food - pastry.n - n#7623136
+0 ## Food - tuna.n - n#2626762
+0 ## Food - biscuit.n - n#7635155
+0 ## Food - roll.n - n#7680932
+0 ## Food - cabbage.n - n#13385216
+0 ## Food - water.n - n#14845743
+0 ## Food - apple.n - n#7739125
+0 ## Food - tea.n - n#7932841
+0 ## Food - soup.n - n#7583197
+0 ## Food - potato.n - n#7710616
+0 ## Food - banana.n - n#12352287
+0 ## Food - fish.n - n#7775375
+0 ## Food - food.n - n#7555863
+0 ## Food - egg.n - n#7840804
+0 ## Food - spice.n - n#7812184
+0 ## Food - cake.n - n#7628870
+0 ## Food - coffee.n - n#7929519
+0 ## Food - chocolate.n - n#7601999
+0 ## Food - vinaigrette.n - n#7833816
+0 ## Food - basil.n - n#12860365
+0 ## Food - sweet.n - n#7596684
+0 ## Food - milk.n - n#7844042
+0 ## Food - carrot.n - n#12937388
+0 ## Food - beef.n - n#7663592
+0 ## Food - pea.n - n#7725376
+0 ## Food - sugar.n - n#13385216
+0 ## Food - poultry.n - n#7644706
+0 ## Food - nut.n - n#5524615
+0 ## Food - cheese.n - n#7850329
+0 ## Food - pepper.n - n#7815588
+0 ## Food - noodle.n - n#7699584
+0 ## Food - cookie.n - n#7635155
+0 ## Food - peanut.n - n#11748501
+0 ## Food - veal.n - n#7665308
+0 ## Food - stew.n - n#7588947
+0 ## Food - ketchup.n - n#7822197
+0 ## Food - honey.n - n#7858978
+0 ## Food - cheesecake.n - n#7630089
+0 ## Food - lasagne.n - n#7870167
+0 ## Food - lamb.n - n#7667151
+0 ## Food - shrimp.n - n#7794159
+0 ## Food - butter.n - n#7848338
+0 ## Food - cracker.n - n#7681926
+0 ## Food - lobster.n - n#7792725
+0 ## Food - sauce.n - n#7829412
+0 ## Food - almond.n - n#12645174
+0 ## Food - chicken.n - n#1791625
+0 ## Food - croissant.n - n#7691650
+0 ## Food - vinegar.n - n#7828987
+0 ## Food - juice.n - n#7923748
+0 ## Food - sweetener.n - n#7858595
+0 ## Food - dressing.n - n#7832902
+0 ## Food - vegetable.n - n#12212361
+0 ## Food - pancake.n - n#7640203
+0 ## Food - turkey.n - n#1794158
+0 ## Food - meat.n - n#7649854
+0 ## Food - shellfish.n - n#7783210
+0 ## Food - beer.n - n#7886849
+0 ## Food - fat.n - n#14864360
+0 ## Food - fruit.n - n#13134947
+0 ## Food - mayonnaise.n - n#7834507
+0 ## Food - bread.n - n#7679356
+0 ## Food - oil.n - n#7673397
+0 ## Food - date.n - n#7765073
+0 ## Food - salmon.n - n#2534734
+0 ## Sociability - loner.n - n#10270628
+0 ## Sociability - introverted.a - a#1350674
+0 ## Sociability - sociable.a - a#2257141
+0 ## Sociability - timid.a - a#339941
+0 ## Sociability - extrovert.n - n#10074841
+0 ## Sociability - friendly.a - a#1074650
+0 ## Sociability - shy.a - a#339941
+0 ## Sociability - gregarious.a - a#2248984
+0 ## Sociability - recluse.n - n#10172448
+0 ## Sociability - outgoing.a - a#2258249
+0 ## Sociability - companionable.a - a#2257856
+0 ## Compliance - circumvent.v - v#1127411
+0 ## Compliance - disobey.v - v#2543181
+0 ## Compliance - violate.v - v#2566528
+0 ## Compliance - flout.v - v#801782
+0 ## Compliance - contrary.a - a#2065958
+0 ## Compliance - compliance.n - n#1203676
+0 ## Compliance - observe.v - v#2578872
+0 ## Compliance - (in/out) line.n - n#1204294
+0 ## Compliance - keep.v - v#2681795
+0 ## Compliance - honor.v - v#2457233
+0 ## Compliance - break.v - v#2566528
+0 ## Compliance - compliant.a - a#696518
+0 ## Compliance - lawless.a - a#600192
+0 ## Compliance - observant.a - a#1395821
+0 ## Compliance - obedient.a - a#1612053
+0 ## Compliance - comply.v - v#2542280
+0 ## Compliance - adhere.v - v#2638845
+0 ## Compliance - conform.v - v#150287
+0 ## Compliance - breach.n - n#7313814
+0 ## Compliance - obey.v - v#2542795
+0 ## Compliance - observance.n - n#1204419
+0 ## Compliance - submit.v - v#2589013
+0 ## Compliance - contravention.n - n#1170813
+0 ## Compliance - abide_((by)).v - v#2637202
+0 ## Compliance - violation.n - n#770543
+0 ## Compliance - follow.v - v#2542280
+0 ## Compliance - transgression.n - n#745005
+0 ## Compliance - conformity.n - n#1203676
+0 ## Compliance - noncompliance.n - n#1179707
+0 ## Compliance - adherence.n - n#1212882
+0 ## Compliance - breach.v - v#2566528
+0 ## Compliance - transgress.v - v#2566528
+0 ## Compliance - contravene.v - v#2567147
+0 ## Halt - stop.v - v#1860795
+0 ## Halt - halt.v - v#1860795
+0 ## State_continue - remain.v - v#117985
+0 ## State_continue - rest.v - v#117985
+0 ## State_continue - stay.v - v#117985
+0 ## Awareness - know.v - v#594621
+0 ## Awareness - reckon.v - v#631737
+0 ## Awareness - cognizant.a - a#190115
+0 ## Awareness - ignorance.n - n#5988282
+0 ## Awareness - comprehend.v - v#588221
+0 ## Awareness - consciousness.n - n#5675905
+0 ## Awareness - awareness.n - n#5675905
+0 ## Awareness - believe.v - v#689344
+0 ## Awareness - presume.v - v#632236
+0 ## Awareness - aware.a - a#190115
+0 ## Awareness - unknown.a - a#1376894
+0 ## Awareness - understand.v - v#588888
+0 ## Awareness - knowledge.n - n#23271
+0 ## Awareness - suspect.v - v#924873
+0 ## Awareness - hunch.n - n#5919034
+0 ## Awareness - presumption.n - n#1225562
+0 ## Awareness - suspicion.n - n#5919034
+0 ## Awareness - imagine.v - v#1636397
+0 ## Awareness - think.v - v#689344
+0 ## Awareness - comprehension.n - n#5805902
+0 ## Awareness - supposition.n - n#5892096
+0 ## Awareness - understanding.n - n#5805475
+0 ## Awareness - conceive.v - v#689344
+0 ## Awareness - conception.n - n#5835747
+0 ## Awareness - thought.n - n#5833840
+0 ## Awareness - conscious.a - a#570590
+0 ## Becoming_separated - divide.v - v#2467662
+0 ## Becoming_separated - split.v - v#2467662
+0 ## Becoming_separated - separate.v - v#2467662
+0 ## Law - code.n - n#6667317
+0 ## Law - regime.n - n#8050678
+0 ## Law - protocol.n - n#6665108
+0 ## Law - regulation.n - n#806902
+0 ## Law - law.n - n#8441203
+0 ## Law - statute.n - n#6564387
+0 ## Law - act.n - n#6532095
+0 ## Law - policy.n - n#5901508
+0 ## Judgment_direct_address - chide.v - v#824767
+0 ## Judgment_direct_address - tongue-lashing.n - n#6712833
+0 ## Judgment_direct_address - compliment.n - n#6695227
+0 ## Judgment_direct_address - castigation.n - n#6713187
+0 ## Judgment_direct_address - thanks.n - n#7228971
+0 ## Judgment_direct_address - tell off.v - v#825648
+0 ## Judgment_direct_address - admonishment.n - n#6714420
+0 ## Judgment_direct_address - reproach.v - v#825975
+0 ## Judgment_direct_address - berate.v - v#824767
+0 ## Judgment_direct_address - jeer.n - n#6716234
+0 ## Judgment_direct_address - take to task.v - v#824767
+0 ## Judgment_direct_address - admonition.n - n#6714420
+0 ## Judgment_direct_address - reprove.v - v#824066
+0 ## Judgment_direct_address - chastise.v - v#824292
+0 ## Judgment_direct_address - admonish.v - v#824066
+0 ## Judgment_direct_address - chastisement.n - n#6714288
+0 ## Judgment_direct_address - reprimand.v - v#824767
+0 ## Judgment_direct_address - thank.v - v#892315
+0 ## Judgment_direct_address - rebuke.v - v#824767
+0 ## Judgment_direct_address - reprimand.n - n#6711855
+0 ## Judgment_direct_address - reproof.n - n#6711855
+0 ## Judgment_direct_address - compliment.v - v#881661
+0 ## Judgment_direct_address - upbraid.v - v#825975
+0 ## Judgment_direct_address - harangue.v - v#990249
+0 ## Judgment_direct_address - jeer.v - v#850192
+0 ## Judgment_direct_address - scold.v - v#824767
+0 ## Judgment_direct_address - rebuke.n - n#6711855
+0 ## Temperature - temperature.n - n#5011790
+0 ## Temperature - tepid.a - a#2529581
+0 ## Temperature - cool.a - a#2529945
+0 ## Temperature - hot.a - a#1247240
+0 ## Temperature - frigid.a - a#1466775
+0 ## Temperature - warm.a - a#2529264
+0 ## Temperature - lukewarm.a - a#2529581
+0 ## Temperature - cold.a - a#1251128
+0 ## Rewards_and_punishments - reward.v - v#2344381
+0 ## Rewards_and_punishments - punitive.a - a#1902468
+0 ## Rewards_and_punishments - penalty.n - n#1160342
+0 ## Rewards_and_punishments - disciplinary.a - a#3061455
+0 ## Rewards_and_punishments - reward.n - n#7295629
+0 ## Rewards_and_punishments - discipline.v - v#2553428
+0 ## Rewards_and_punishments - punish.v - v#2499629
+0 ## Rewards_and_punishments - recompense.v - v#2250625
+0 ## Cause_change_of_position_on_a_scale - push.v - v#1871979
+0 ## Cause_change_of_position_on_a_scale - cut.n - n#352331
+0 ## Cause_change_of_position_on_a_scale - diminish.v - v#151689
+0 ## Cause_change_of_position_on_a_scale - add.v - v#182406
+0 ## Cause_change_of_position_on_a_scale - promote.v - v#2554922
+0 ## Cause_change_of_position_on_a_scale - push.n - n#112312
+0 ## Cause_change_of_position_on_a_scale - swell.v - v#555084
+0 ## Cause_change_of_position_on_a_scale - move.v - v#1835496
+0 ## Cause_change_of_position_on_a_scale - decrease.v - v#441445
+0 ## Cause_change_of_position_on_a_scale - raise.v - v#158503
+0 ## Cause_change_of_position_on_a_scale - enhance.v - v#229605
+0 ## Cause_change_of_position_on_a_scale - reduction.n - n#351638
+0 ## Cause_change_of_position_on_a_scale - reduce.v - v#429060
+0 ## Cause_change_of_position_on_a_scale - curtail.v - v#292877
+0 ## Cause_change_of_position_on_a_scale - growth.n - n#13489037
+0 ## Cause_change_of_position_on_a_scale - knock down.v - v#1239862
+0 ## Cause_change_of_position_on_a_scale - lower.v - v#267855
+0 ## Cause_change_of_position_on_a_scale - increase.v - v#153263
+0 ## Cause_change_of_position_on_a_scale - step up.v - v#290302
+0 ## Cause_change_of_position_on_a_scale - cut.v - v#429060
+0 ## Hostile_encounter - skirmish.n - n#959376
+0 ## Hostile_encounter - stalemate.n - n#14015361
+0 ## Hostile_encounter - brawl.n - n#1176431
+0 ## Hostile_encounter - battle.n - n#958896
+0 ## Hostile_encounter - brawl.v - v#774344
+0 ## Hostile_encounter - war.n - n#1236296
+0 ## Hostile_encounter - conflict.n - n#958896
+0 ## Hostile_encounter - clash.n - n#959376
+0 ## Hostile_encounter - battle.v - v#1092366
+0 ## Hostile_encounter - standoff.n - n#7353716
+0 ## Hostile_encounter - scuffle.v - v#1504480
+0 ## Hostile_encounter - bw.n - n#967780
+0 ## Hostile_encounter - shootout.n - n#124617
+0 ## Hostile_encounter - skirmish.v - v#1123765
+0 ## Hostile_encounter - scuffle.n - n#1172441
+0 ## Hostile_encounter - clash.v - v#2667698
+0 ## Hostile_encounter - strife.n - n#1167710
+0 ## Hostile_encounter - altercation.n - n#7184545
+0 ## Hostile_encounter - spat.n - n#7184735
+0 ## Hostile_encounter - showdown.n - n#7181043
+0 ## Hostile_encounter - warfare.n - n#1236296
+0 ## Hostile_encounter - war.v - v#1093172
+0 ## Hostile_encounter - combat.n - n#1170962
+0 ## Hostile_encounter - tiff.n - n#7184735
+0 ## Hostile_encounter - gunfight.n - n#124617
+0 ## Hostile_encounter - confront.v - v#1078783
+0 ## Hostile_encounter - squabble.n - n#7184735
+0 ## Hostile_encounter - fighting.n - n#1170962
+0 ## Hostile_encounter - fistfight.n - n#1173826
+0 ## Hostile_encounter - struggle.n - n#958896
+0 ## Hostile_encounter - duel.n - n#1172784
+0 ## Hostile_encounter - duel.v - v#1121948
+0 ## Hostile_encounter - tussle.n - n#1172441
+0 ## Hostile_encounter - fight.n - n#1170962
+0 ## Hostile_encounter - struggle.v - v#1090335
+0 ## Hostile_encounter - wrangling.n - n#7150138
+0 ## Hostile_encounter - row.n - n#7184149
+0 ## Hostile_encounter - fight.v - v#1090335
+0 ## Hostile_encounter - confrontation.n - n#1169744
+0 ## Hostile_encounter - bout.n - n#7456906
+0 ## Hostile_encounter - hostility.n - n#13980288
+0 ## Version_sequence - draft.n - n#6390962
+0 ## Version_sequence - initial.a - a#1011973
+0 ## Version_sequence - rough.a - a#1813183
+0 ## Version_sequence - final.a - a#1010271
+0 ## Version_sequence - preliminary.a - a#878086
+0 ## Version_sequence - working.a - a#1758194
+0 ## Calendric_unit - eve.n - n#15166462
+0 ## Calendric_unit - January.n - n#15210045
+0 ## Calendric_unit - millennium.n - n#15141213
+0 ## Calendric_unit - July.n - n#15212167
+0 ## Calendric_unit - daybreak.n - n#15168790
+0 ## Calendric_unit - April.n - n#15211189
+0 ## Calendric_unit - quarter.n - n#15226046
+0 ## Calendric_unit - dusk.n - n#15169421
+0 ## Calendric_unit - Wednesday.n - n#15164233
+0 ## Calendric_unit - March.n - n#15210870
+0 ## Calendric_unit - October.n - n#15213115
+0 ## Calendric_unit - yesterday.n - n#15156187
+0 ## Calendric_unit - November.n - n#15213406
+0 ## Calendric_unit - evening.n - n#15166462
+0 ## Calendric_unit - summer.n - n#15237250
+0 ## Calendric_unit - day.n - n#15155220
+0 ## Calendric_unit - week.n - n#15169873
+0 ## Calendric_unit - decade.n - n#15204983
+0 ## Calendric_unit - year.n - n#15203791
+0 ## Calendric_unit - midday.n - n#15165490
+0 ## Calendric_unit - calendar year.n - n#15202634
+0 ## Calendric_unit - dawn.n - n#15168790
+0 ## Calendric_unit - today.n - n#15156001
+0 ## Calendric_unit - weekend.n - n#15170504
+0 ## Calendric_unit - June.n - n#15211806
+0 ## Calendric_unit - rush hour.n - n#15229144
+0 ## Calendric_unit - May.n - n#15211484
+0 ## Calendric_unit - weeknight.n - n#15167675
+0 ## Calendric_unit - Sunday.n - n#15163797
+0 ## Calendric_unit - Thursday.n - n#15164354
+0 ## Calendric_unit - weekday.n - n#15163157
+0 ## Calendric_unit - tomorrow.n - n#15155891
+0 ## Calendric_unit - century.n - n#15205532
+0 ## Calendric_unit - September.n - n#15212739
+0 ## Calendric_unit - autumn.n - n#15236859
+0 ## Calendric_unit - morning.n - n#15165289
+0 ## Calendric_unit - Monday.n - n#15163979
+0 ## Calendric_unit - February.n - n#15210486
+0 ## Calendric_unit - month.n - n#15209413
+0 ## Calendric_unit - Tuesday.n - n#15164105
+0 ## Calendric_unit - second.n - n#15235126
+0 ## Calendric_unit - Friday.n - n#15164463
+0 ## Calendric_unit - midnight.n - n#15168185
+0 ## Calendric_unit - hour.n - n#15228378
+0 ## Calendric_unit - August.n - n#15212455
+0 ## Calendric_unit - fortnight.n - n#15170331
+0 ## Calendric_unit - December.n - n#15213774
+0 ## Calendric_unit - noon.n - n#15165490
+0 ## Calendric_unit - tonight.n - n#15263045
+0 ## Calendric_unit - age.n - n#15254028
+0 ## Calendric_unit - winter.n - n#15237782
+0 ## Calendric_unit - morn.n - n#15165289
+0 ## Calendric_unit - era.n - n#15248564
+0 ## Calendric_unit - Saturday.n - n#15164570
+0 ## Calendric_unit - twilight.n - n#15169421
+0 ## Calendric_unit - spring.n - n#15237044
+0 ## Calendric_unit - afternoon.n - n#15166191
+0 ## Calendric_unit - night.n - n#15167027
+0 ## Calendric_unit - minute.n - n#15234764
+0 ## Cause_change_of_strength - weaken.v - v#224901
+0 ## Cause_change_of_strength - strengthen.v - v#220869
+0 ## Cause_change_of_strength - reinforce.v - v#222472
+0 ## Cause_change_of_strength - fortify.v - v#220869
+0 ## Intentionally_affect - do.v - v#2560585
+0 ## Objective_influence - effect.n - n#11410625
+0 ## Objective_influence - impact.v - v#137313
+0 ## Objective_influence - affect.v - v#137313
+0 ## Objective_influence - influence.v - v#2536557
+0 ## Objective_influence - impact.n - n#11414411
+0 ## Objective_influence - influence.n - n#5194151
+0 ## Attempt_means - try.v - v#2530167
+0 ## Ride_vehicle - coast.v - v#1886728
+0 ## Ride_vehicle - take.v - v#1842690
+0 ## Ride_vehicle - cruise.v - v#1844653
+0 ## Ride_vehicle - cruise.n - n#312932
+0 ## Ride_vehicle - bus.v - v#1949110
+0 ## Ride_vehicle - jet.v - v#1942234
+0 ## Ride_vehicle - fly.v - v#1940403
+0 ## Ride_vehicle - ride.n - n#307631
+0 ## Ride_vehicle - hitchhike.v - v#1956955
+0 ## Ride_vehicle - ride.v - v#1955984
+0 ## Ride_vehicle - taxi.v - v#1949007
+0 ## Ride_vehicle - flight.n - n#302394
+0 ## Ride_vehicle - sail.v - v#1945516
+0 ## Carry_goods - carry.v - v#1449974
+0 ## Carry_goods - stock.v - v#2285392
+0 ## Giving_in - yield.v - v#2703289
+0 ## Giving_in - cave in.v - v#1989053
+0 ## Giving_in - give in.v - v#878348
+0 ## Giving_in - capitulate.v - v#1117812
+0 ## Giving_in - give way.v - v#1848465
+0 ## Giving_in - acquiesce.v - v#804139
+0 ## Giving_in - relent.v - v#2703289
+0 ## Aesthetics - lovely.a - a#219809
+0 ## Aesthetics - tasty.a - a#2395115
+0 ## Aesthetics - fair.a - a#218440
+0 ## Aesthetics - handsome.a - a#218950
+0 ## Aesthetics - elegant.a - a#849357
+0 ## Aesthetics - smart.a - a#438707
+0 ## Aesthetics - beautiful.a - a#217728
+0 ## Aesthetics - ugly.a - a#220956
+0 ## Sound_movement - echo.v - v#2183787
+0 ## Sound_movement - blast.v - v#2182479
+0 ## Sound_movement - reverberate.v - v#2183787
+0 ## Sound_movement - roll.v - v#2198014
+0 ## Sound_movement - resound.v - v#2183787
+0 ## Differentiation - distinguishable.a - a#582314
+0 ## Differentiation - separate.v - v#650353
+0 ## Differentiation - sort.v - v#654625
+0 ## Differentiation - distinguish.v - v#650353
+0 ## Differentiation - differentiate.v - v#650353
+0 ## Differentiation - tell_apart.v - v#650353
+0 ## Differentiation - discriminate.v - v#650016
+0 ## Differentiation - know.v - v#594621
+0 ## Differentiation - discrimination.n - n#5748054
+0 ## Locating - find.v - v#2248465
+0 ## Locating - locate.v - v#2286204
+0 ## Volubility - gushing.a - a#720524
+0 ## Volubility - mum.a - a#501820
+0 ## Volubility - reserved.a - a#1987341
+0 ## Volubility - mute.a - a#151855
+0 ## Volubility - taciturn.a - a#2383380
+0 ## Volubility - chatty.a - a#2384077
+0 ## Volubility - uncommunicative.a - a#500569
+0 ## Volubility - laconic.a - a#547641
+0 ## Volubility - silent.a - a#501820
+0 ## Volubility - reticent.a - a#2383709
+0 ## Volubility - talkative.a - a#2384077
+0 ## Volubility - curt.a - a#547641
+0 ## Volubility - terse.a - a#547641
+0 ## Volubility - chatterbox.n - n#12062781
+0 ## Volubility - reticence.n - n#4652438
+0 ## Volubility - gushy.a - a#720524
+0 ## Volubility - voluble.a - a#2383831
+0 ## Volubility - garrulous.a - a#2384077
+0 ## Volubility - loquacious.a - a#2384077
+0 ## Volubility - expansive.a - a#496938
+0 ## Volubility - effusive.a - a#720524
+0 ## Volubility - brusque.a - a#640660
+0 ## Volubility - loudmouth.n - n#10274318
+0 ## Volubility - loquacity.n - n#4651382
+0 ## Volubility - quiet.a - a#1918984
+0 ## Volubility - glib.a - a#1874716
+0 ## Have_as_translation_equivalent - translate.v - v#961947
+0 ## Remembering_experience - recall.v - v#607780
+0 ## Remembering_experience - remember.v - v#607780
+0 ## Remembering_experience - forget.v - v#610167
+0 ## Remembering_experience - reminisce.v - v#611055
+0 ## Remembering_experience - memory.n - n#5760202
+0 ## Remembering_experience - look back.v - v#2132099
+0 ## Medical_professionals - shaman.n - n#10626194
+0 ## Medical_professionals - neurologist.n - n#10354265
+0 ## Medical_professionals - nurse.n - n#10366966
+0 ## Medical_professionals - midwife.n - n#10314836
+0 ## Medical_professionals - immunologist.n - n#10199902
+0 ## Medical_professionals - therapist.n - n#10707233
+0 ## Medical_professionals - psychologist.n - n#10488865
+0 ## Medical_professionals - radiologist.n - n#10504206
+0 ## Medical_professionals - urologist.n - n#10741493
+0 ## Medical_professionals - orthopaedist.n - n#10385159
+0 ## Medical_professionals - physician.n - n#10020890
+0 ## Medical_professionals - proctologist.n - n#10478827
+0 ## Medical_professionals - pediatrician.n - n#9828760
+0 ## Medical_professionals - cardiologist.n - n#9894445
+0 ## Medical_professionals - ophthalmologist.n - n#10379073
+0 ## Medical_professionals - allergist.n - n#9784306
+0 ## Medical_professionals - psychoanalyst.n - n#9790278
+0 ## Medical_professionals - doctor.n - n#10020890
+0 ## Medical_professionals - gastroenterologist.n - n#10121800
+0 ## Medical_professionals - gerontologist.n - n#10128381
+0 ## Medical_professionals - speech_therapist.n - n#10634464
+0 ## Medical_professionals - gynaecologist.n - n#10154013
+0 ## Medical_professionals - dermatologist.n - n#10006177
+0 ## Medical_professionals - surgeon.n - n#10679174
+0 ## Medical_professionals - rheumatologist.n - n#10528023
+0 ## Medical_professionals - psychotherapist.n - n#10489944
+0 ## Medical_professionals - endocrinologist.n - n#10056914
+0 ## Medical_professionals - obstetrician.n - n#10369699
+0 ## Medical_professionals - anesthesiologist.n - n#9793495
+0 ## Medical_professionals - oncologist.n - n#10377633
+0 ## Medical_professionals - chiropractor.n - n#9919200
+0 ## Medical_professionals - psychiatrist.n - n#10488016
+0 ## Part_inner_outer - inner.a - a#950272
+0 ## Part_inner_outer - centre.n - n#8523483
+0 ## Part_inner_outer - outer.a - a#949548
+0 ## Part_inner_outer - interior.a - a#952867
+0 ## Part_inner_outer - outside.a - a#1692222
+0 ## Part_inner_outer - inside.n - n#8588152
+0 ## Part_inner_outer - central.a - a#329831
+0 ## Part_inner_outer - perimeter.n - n#13903387
+0 ## Part_inner_outer - surface.n - n#8660339
+0 ## Part_inner_outer - lining.n - n#3673767
+0 ## Part_inner_outer - shell.n - n#1903756
+0 ## Part_inner_outer - middle.n - n#8523483
+0 ## Part_inner_outer - skin.n - n#7738353
+0 ## Part_inner_outer - exterior.n - n#8613472
+0 ## Part_inner_outer - inside.a - a#953213
+0 ## Part_inner_outer - outside.n - n#8613472
+0 ## Part_inner_outer - interior.n - n#8588294
+0 ## Part_inner_outer - exterior.a - a#952395
+0 ## Event - development.n - n#7423560
+0 ## Event - event.n - n#29378
+0 ## Event - go_on.v - v#339934
+0 ## Event - take place.v - v#339934
+0 ## Event - happen.v - v#339934
+0 ## Event - transpire.v - v#341040
+0 ## Event - occur.v - v#339934
+0 ## Heat_potential - warm.a - a#2529264
+0 ## Activity_pause - suspend.v - v#363493
+0 ## Activity_pause - moratorium.n - n#14013751
+0 ## Activity_pause - freeze.n - n#1063697
+0 ## Activity_pause - freeze.v - v#363493
+0 ## Activity_pause - pause.n - n#1062817
+0 ## Part_edge - edge.n - n#3264542
+0 ## Custom - ritualistic.a - a#3111832
+0 ## Custom - convention.n - n#5667613
+0 ## Custom - customary.a - a#606079
+0 ## Custom - ritual.n - n#1027859
+0 ## Custom - practice.n - n#5667196
+0 ## Custom - tradition.n - n#5667404
+0 ## Custom - traditionally.adv - r#476807
+0 ## Custom - traditional.a - a#611047
+0 ## Custom - habitual.a - a#489491
+0 ## Custom - habit.n - n#5669034
+0 ## Custom - custom.n - n#413239
+0 ## Enforcing - enforcement.n - n#1127019
+0 ## Enforcing - enforce.v - v#2560164
+0 ## Activity_finish - finish.v - v#484166
+0 ## Activity_finish - completion.n - n#211110
+0 ## Activity_finish - tie up.v - v#1286038
+0 ## Activity_finish - complete.v - v#484166
+0 ## Activity_finish - conclude.v - v#715074
+0 ## Event_instance - twice.adv - r#65294
+0 ## Event_instance - time.n - n#7309599
+0 ## Event_instance - once.adv - r#118869
+0 ## Arrest - arrest.n - n#88725
+0 ## Arrest - cop.v - v#1215137
+0 ## Arrest - apprehend.v - v#1215137
+0 ## Arrest - bust.v - v#1369758
+0 ## Arrest - arrest.v - v#1215137
+0 ## Arrest - collar.v - v#1215137
+0 ## Arrest - apprehension.n - n#88725
+0 ## Arrest - bust.n - n#7365024
+0 ## Arrest - nab.v - v#1215137
+0 ## Arrest - summons.v - v#791134
+0 ## Arrest - book.v - v#678777
+0 ## Cutting - mince.v - v#1560583
+0 ## Cutting - carve.v - v#1255967
+0 ## Cutting - pare.v - v#1262564
+0 ## Cutting - dice.v - v#1256867
+0 ## Cutting - cube.v - v#1256867
+0 ## Cutting - cut.v - v#1552519
+0 ## Cutting - slice.v - v#1559055
+0 ## Cutting - chop.v - v#1258091
+0 ## Cutting - fillet.v - v#1249294
+0 ## Mention - mention.v - v#1024190
+0 ## Network - web.n - n#8434259
+0 ## Network - network.n - n#8434259
+0 ## Fleeing - run away.v - v#2075049
+0 ## Fleeing - bolt.v - v#2073714
+0 ## Fleeing - flee.v - v#2075462
+0 ## Process_end - finale.n - n#15267536
+0 ## Process_end - conclude.v - v#715074
+0 ## Process_end - end.v - v#2609764
+0 ## Process_end - final.a - a#1010271
+0 ## Process_end - end_final-subevent.n - n#15266911
+0 ## Process_end - end.n - n#15266911
+0 ## Process_end - pass.v - v#2685951
+0 ## Process_end - end_cessation.n - n#15266911
+0 ## Documents - confirmation.n - n#7179943
+0 ## Documents - will.n - n#6544142
+0 ## Documents - opinion.n - n#1191158
+0 ## Documents - permit.n - n#6549661
+0 ## Documents - testament.n - n#6544142
+0 ## Documents - contract.n - n#6520944
+0 ## Documents - title.n - n#6545137
+0 ## Documents - diploma.n - n#6478582
+0 ## Documents - contractual.a - a#2702656
+0 ## Documents - brief.n - n#6543781
+0 ## Documents - testimony.n - n#6734467
+0 ## Documents - deed.n - n#6545137
+0 ## Documents - certificate.n - n#6471345
+0 ## Documents - writ.n - n#6552984
+0 ## Documents - subpoena.n - n#6557047
+0 ## Documents - passport.n - n#6500937
+0 ## Documents - agreement.n - n#13971065
+0 ## Documents - visa.n - n#6687883
+0 ## Documents - ruling.n - n#1191158
+0 ## Documents - document.n - n#6470073
+0 ## Documents - charter.n - n#6471737
+0 ## Documents - authorization.n - n#1138670
+0 ## Documents - deposition.n - n#13462191
+0 ## Documents - warrant.n - n#6547059
+0 ## Documents - licence.n - n#6549661
+0 ## Documents - treaty.n - n#6773434
+0 ## Documents - affidavit.n - n#6736529
+0 ## Documents - papers.n - n#6470073
+0 ## Documents - finding.n - n#151497
+0 ## Documents - summons.n - n#6556692
+0 ## Documents - accord.n - n#13971065
+0 ## Documents - lease.n - n#15274863
+0 ## Bail_decision - fix.v - v#947077
+0 ## Bail_decision - order.v - v#735571
+0 ## Bail_decision - bail.n - n#13350976
+0 ## Bail_decision - bond.n - n#13417410
+0 ## Bail_decision - set.v - v#699815
+0 ## Passing - pass.v - v#2230772
+0 ## Arriving - entrance.n - n#49003
+0 ## Arriving - arrive.v - v#2005948
+0 ## Arriving - crest.v - v#2693168
+0 ## Arriving - influx.n - n#13499782
+0 ## Arriving - reach.v - v#2006834
+0 ## Arriving - return.n - n#51192
+0 ## Arriving - get.v - v#2210855
+0 ## Arriving - descend_(on).v - v#2737187
+0 ## Arriving - make.v - v#2560585
+0 ## Arriving - approach.n - n#2671062
+0 ## Arriving - approach.v - v#2053941
+0 ## Arriving - return.v - v#2004874
+0 ## Arriving - make it.v - v#2585860
+0 ## Arriving - entry.n - n#49003
+0 ## Arriving - arrival.n - n#48374
+0 ## Arriving - visit.v - v#2493030
+0 ## Arriving - come.v - v#1849221
+0 ## Arriving - enter.v - v#2016523
+0 ## Arriving - visit.n - n#1233156
+0 ## Body_description_holistic - hefty.a - a#2321809
+0 ## Body_description_holistic - wiry.a - a#991584
+0 ## Body_description_holistic - rangy.a - a#2385492
+0 ## Body_description_holistic - short.a - a#2386612
+0 ## Body_description_holistic - slim.a - a#990855
+0 ## Body_description_holistic - squat.a - a#2386962
+0 ## Body_description_holistic - dumpy.a - a#2386962
+0 ## Body_description_holistic - stocky.a - a#2387413
+0 ## Body_description_holistic - chubby.a - a#986766
+0 ## Body_description_holistic - stubby.a - a#1437349
+0 ## Body_description_holistic - lithe.a - a#1140290
+0 ## Body_description_holistic - obese.a - a#987180
+0 ## Body_description_holistic - spindly.a - a#989647
+0 ## Body_description_holistic - portly.a - a#988077
+0 ## Body_description_holistic - fat.a - a#986027
+0 ## Body_description_holistic - lanky.a - a#2385492
+0 ## Body_description_holistic - angular.a - a#2930616
+0 ## Body_description_holistic - gaunt.a - a#988988
+0 ## Body_description_holistic - puny.a - a#2326342
+0 ## Body_description_holistic - tall.a - a#2385102
+0 ## Body_description_holistic - corpulent.a - a#987180
+0 ## Body_description_holistic - bony.a - a#988988
+0 ## Body_description_holistic - pudgy.a - a#987510
+0 ## Body_description_holistic - thickset.a - a#2387413
+0 ## Body_description_holistic - thin.a - a#988232
+0 ## Body_description_holistic - stout.a - a#988077
+0 ## Body_description_holistic - big-boned.a - a#2038421
+0 ## Body_description_holistic - flabby.a - a#1019713
+0 ## Body_description_holistic - svelte.a - a#990855
+0 ## Body_description_holistic - paunchy.a - a#986457
+0 ## Body_description_holistic - slender.a - a#990855
+0 ## Body_description_holistic - beefy.a - a#2038126
+0 ## Body_description_holistic - scrawny.a - a#990192
+0 ## Body_description_holistic - plump.a - a#986766
+0 ## Body_description_holistic - muscular.a - a#2321809
+0 ## Body_description_holistic - skinny.a - a#990192
+0 ## Body_description_holistic - brawny.a - a#2321809
+0 ## Body_description_holistic - lean.a - a#988232
+0 ## Institutionalization - commitment.n - n#1165692
+0 ## Institutionalization - hospitalize.v - v#2348927
+0 ## Institutionalization - commit.v - v#2348568
+0 ## Institutionalization - institutionalize.v - v#2348568
+0 ## Institutionalization - hospitalization.n - n#658627
+0 ## Type - breed.n - n#8101410
+0 ## Type - ilk.n - n#5845419
+0 ## Type - brand.n - n#5845140
+0 ## Type - type.n - n#5840188
+0 ## Type - form.n - n#5839024
+0 ## Type - class.n - n#7997703
+0 ## Type - kind.n - n#5839024
+0 ## Type - shade.n - n#4959230
+0 ## Type - sort.n - n#5839024
+0 ## Type - variety.n - n#5839024
+0 ## Type - version.n - n#5840650
+0 ## Type - race.n - n#8110648
+0 ## Type - make.n - n#5845140
+0 ## Type - strain.n - n#8101410
+0 ## Dressing - dress up.v - v#44149
+0 ## Dressing - slip on.v - v#51170
+0 ## Dressing - get on.v - v#2458566
+0 ## Dressing - dress.v - v#46534
+0 ## Dressing - don.v - v#50652
+0 ## Dressing - put on.v - v#50652
+0 ## Mental_stimulus_stimulus_focus - enthralling.a - a#166753
+0 ## Mental_stimulus_stimulus_focus - engrossing.a - a#1344171
+0 ## Mental_stimulus_stimulus_focus - absorbing.a - a#1344171
+0 ## Mental_stimulus_stimulus_focus - fascinating.a - a#1344171
+0 ## Mental_stimulus_stimulus_focus - captivating.a - a#166753
+0 ## Mental_stimulus_stimulus_focus - interesting.a - a#1343918
+0 ## Setting_out - set off.v - v#349785
+0 ## Setting_out - set out.v - v#345761
+0 ## Setting_out - decamp.v - v#2076857
+0 ## Possibilities - chance.n - n#14483917
+0 ## Possibilities - way.n - n#4928903
+0 ## Possibilities - use.n - n#947128
+0 ## Possibilities - future.n - n#15121625
+0 ## Possibilities - alternative.n - n#5790944
+0 ## Possibilities - option.n - n#5790944
+0 ## Possibilities - choice.n - n#5790944
+0 ## Possibilities - possibility.n - n#5792010
+0 ## Losing_someone - lose.v - v#2287789
+0 ## Activity_ongoing - keep up.v - v#2679530
+0 ## Activity_ongoing - keep on.v - v#2410175
+0 ## Activity_ongoing - continue.v - v#2684924
+0 ## Activity_ongoing - maintain.v - v#2681795
+0 ## Activity_ongoing - keep.v - v#2681795
+0 ## Activity_ongoing - proceed.v - v#781000
+0 ## Activity_ongoing - maintenance.n - n#13366311
+0 ## Activity_ongoing - carry on.v - v#2679899
+0 ## Preventing - obviate.v - v#2453321
+0 ## Preventing - pre-emption.n - n#5957238
+0 ## Preventing - prevention.n - n#1077350
+0 ## Preventing - stave off.v - v#2453321
+0 ## Preventing - upset.v - v#521296
+0 ## Preventing - prohibit.v - v#795863
+0 ## Preventing - prevent.v - v#2452885
+0 ## Preventing - check.v - v#1861403
+0 ## Preventing - frustrate.v - v#2558172
+0 ## Preventing - stop.v - v#1860795
+0 ## Preventing - stopping.n - n#101809
+0 ## Preventing - avert.v - v#2453321
+0 ## Preventing - avoid.v - v#2453321
+0 ## Installing - installation.n - n#240938
+0 ## Installing - install.v - v#1569566
+0 ## Activity_prepare - gear_up.v - v#406243
+0 ## Activity_prepare - fix.v - v#1664172
+0 ## Activity_prepare - ready.v - v#1664172
+0 ## Activity_prepare - preparation.n - n#14031108
+0 ## Activity_prepare - prepare.v - v#406243
+0 ## Activity_prepare - rally.v - v#1381549
+0 ## Soaking - marinate.v - v#213544
+0 ## Soaking - soak.v - v#1578513
+0 ## Luck - fortunate.a - a#1047874
+0 ## Luck - luckily.adv - r#42254
+0 ## Luck - fortune.n - n#11418138
+0 ## Luck - lucky.a - a#1049210
+0 ## Luck - fortunately.adv - r#42254
+0 ## Luck - happy.a - a#1048406
+0 ## Luck - fortuitous.a - a#1339203
+0 ## Luck - luck.n - n#14473222
+0 ## Noise_makers - alarm.n - n#6803157
+0 ## Noise_makers - saxophone.n - n#4141076
+0 ## Noise_makers - rattle.n - n#4056289
+0 ## Noise_makers - piano.n - n#3928116
+0 ## Noise_makers - guitar.n - n#3467517
+0 ## Noise_makers - bell.n - n#2824448
+0 ## Noise_makers - drum.n - n#3249569
+0 ## Noise_makers - siren.n - n#4224395
+0 ## Noise_makers - xylophone.n - n#3721384
+0 ## Noise_makers - cello.n - n#2992211
+0 ## Silencing - silence.v - v#461493
+0 ## Silencing - quiet.v - v#2190188
+0 ## Silencing - hush.v - v#461493
+0 ## Silencing - shush.v - v#390741
+0 ## Silencing - quiet_down.v - v#2190188
+0 ## Silencing - hush_up.v - v#461493
+0 ## Renting_out - lease.v - v#2208903
+0 ## Renting_out - rent.v - v#2460199
+0 ## Competition - rival.n - n#10533013
+0 ## Competition - challenge.n - n#13932948
+0 ## Competition - player.n - n#10439851
+0 ## Competition - competitive.a - a#512487
+0 ## Competition - compete.v - v#1072262
+0 ## Competition - competitor.n - n#10533013
+0 ## Competition - rivalry.n - n#1168569
+0 ## Competition - play.v - v#1072949
+0 ## Competition - competition.n - n#10533013
+0 ## Ranked_expectation - mere.a - a#1099707
+0 ## Ranked_expectation - whole.a - a#514884
+0 ## Ranked_expectation - entire.a - a#515380
+0 ## Change_of_consistency - indurate.v - v#443384
+0 ## Change_of_consistency - thicken.v - v#431327
+0 ## Change_of_consistency - harden.v - v#443116
+0 ## Change_of_consistency - clot.v - v#457998
+0 ## Change_of_consistency - soften.v - v#2190632
+0 ## Change_of_consistency - set.v - v#442669
+0 ## Change_of_consistency - curdle.v - v#442847
+0 ## Change_of_consistency - coagulate.v - v#457998
+0 ## Change_of_consistency - coagulation.n - n#13454479
+0 ## Change_of_consistency - jell.v - v#442669
+0 ## Change_of_consistency - congeal.v - v#442669
+0 ## Concessive - nevertheless.adv - r#27384
+0 ## Concessive - however.adv - r#27384
+0 ## Impact - knock.v - v#1239619
+0 ## Impact - thud.v - v#1238204
+0 ## Impact - collide.v - v#1561143
+0 ## Impact - clatter.v - v#2172127
+0 ## Impact - tinkle.v - v#2186506
+0 ## Impact - bang.v - v#1242391
+0 ## Impact - rattle.v - v#2175057
+0 ## Impact - clang.v - v#2174115
+0 ## Impact - clink.v - v#2186690
+0 ## Impact - patter.v - v#2185187
+0 ## Impact - clunk.v - v#2184965
+0 ## Impact - strike.v - v#1236164
+0 ## Impact - brush.v - v#1240720
+0 ## Impact - impact.v - v#137313
+0 ## Impact - run.v - v#1926311
+0 ## Impact - crash.n - n#126236
+0 ## Impact - impact.n - n#7338552
+0 ## Impact - smash.v - v#1561408
+0 ## Impact - bump.v - v#1239619
+0 ## Impact - touch.v - v#1206218
+0 ## Impact - plash.v - v#1374020
+0 ## Impact - hit.v - v#1236164
+0 ## Impact - slap.v - v#1416871
+0 ## Impact - graze.v - v#1240514
+0 ## Impact - rap.v - v#1414288
+0 ## Impact - thump.v - v#1414626
+0 ## Impact - smack.v - v#1414916
+0 ## Impact - crash.v - v#1561819
+0 ## Impact - slam.v - v#1242391
+0 ## Impact - crunch.v - v#1058224
+0 ## Impact - hiss.v - v#1053771
+0 ## Impact - clash.v - v#1561143
+0 ## Impact - plop.v - v#1977266
+0 ## Impact - hit.n - n#125629
+0 ## Impact - plunk.v - v#2184965
+0 ## Impact - plough.v - v#2096853
+0 ## Impact - click.v - v#2185861
+0 ## Impact - chatter.v - v#2185861
+0 ## Impact - collision.n - n#7301543
+0 ## Foreign_or_domestic_country - domestic.a - a#1038102
+0 ## Foreign_or_domestic_country - home.n - n#8559508
+0 ## Foreign_or_domestic_country - international.a - a#1568375
+0 ## Foreign_or_domestic_country - homeland.n - n#8510169
+0 ## Foreign_or_domestic_country - foreign.a - a#1037540
+0 ## Detaching - unfasten.v - v#1344293
+0 ## Detaching - unhitch.v - v#1328340
+0 ## Detaching - detach.v - v#1298668
+0 ## Detaching - unchain.v - v#1288808
+0 ## Detaching - untie.v - v#1284461
+0 ## Detaching - unhook.v - v#1366321
+0 ## Precipitation - sprinkle.v - v#1374767
+0 ## Precipitation - torrent.n - n#11502102
+0 ## Precipitation - snow.n - n#11508382
+0 ## Precipitation - torrential.a - a#2817796
+0 ## Precipitation - precipitation.n - n#11494638
+0 ## Precipitation - sleet.n - n#11507951
+0 ## Precipitation - hail.v - v#2759115
+0 ## Precipitation - drizzle.v - v#2757475
+0 ## Precipitation - hail.n - n#11465530
+0 ## Precipitation - snow.v - v#2758977
+0 ## Precipitation - snowfall.n - n#11508382
+0 ## Precipitation - downpour.n - n#11502102
+0 ## Precipitation - rain_event.n - n#11501381
+0 ## Precipitation - shower.v - v#2757651
+0 ## Precipitation - precipitation_event.n - n#11494638
+0 ## Precipitation - rainfall.n - n#11501381
+0 ## Precipitation - shower.n - n#11502497
+0 ## Precipitation - sleet.v - v#2759254
+0 ## Precipitation - drizzle.n - n#11502322
+0 ## Precipitation - rain.n - n#11501381
+0 ## Precipitation - rain.v - v#2756558
+0 ## Ammunition - round.n - n#4113641
+0 ## Ammunition - ordnance.n - n#3799610
+0 ## Ammunition - ammunition.n - n#2703275
+0 ## Ammunition - bullet.n - n#2916350
+0 ## Ammunition - ammo.n - n#2703275
+0 ## Change_tool - switch.v - v#2259005
+0 ## Change_tool - change.v - v#2257370
+0 ## Change_tool - transfer.v - v#1435380
+0 ## Change_tool - trade.v - v#2259005
+0 ## Change_tool - swap.v - v#2259005
+0 ## Attaching - adhere.v - v#1220885
+0 ## Attaching - truss.v - v#1287797
+0 ## Attaching - tack.v - v#1357429
+0 ## Attaching - yoke.v - v#1492052
+0 ## Attaching - join.v - v#1291069
+0 ## Attaching - shackle.v - v#1288052
+0 ## Attaching - link.v - v#1354673
+0 ## Attaching - untie.v - v#1284461
+0 ## Attaching - mount.v - v#1343204
+0 ## Attaching - paste.v - v#1332205
+0 ## Attaching - cement.v - v#1366653
+0 ## Attaching - bond.v - v#1356750
+0 ## Attaching - glue.v - v#1332205
+0 ## Attaching - pin.v - v#1368264
+0 ## Attaching - bind.v - v#1285440
+0 ## Attaching - tying.n - n#149084
+0 ## Attaching - lash.v - v#1303707
+0 ## Attaching - manacle.v - v#1288201
+0 ## Attaching - strap.v - v#83523
+0 ## Attaching - cinch.v - v#1302982
+0 ## Attaching - attach.v - v#1296462
+0 ## Attaching - fetter.v - v#1288052
+0 ## Attaching - staple.v - v#1367069
+0 ## Attaching - weld.v - v#1595830
+0 ## Attaching - tape.v - v#1331818
+0 ## Attaching - chain.v - v#1288636
+0 ## Attaching - fix.v - v#1340439
+0 ## Attaching - stick.v - v#1356750
+0 ## Attaching - handcuff.v - v#1288201
+0 ## Attaching - hitch.v - v#1614774
+0 ## Attaching - fasten.v - v#1340439
+0 ## Attaching - secure.v - v#1340439
+0 ## Attaching - tie.v - v#1285440
+0 ## Attaching - gum.v - v#1364019
+0 ## Attaching - attachment_act.n - n#2755352
+0 ## Attaching - bracket.v - v#1218791
+0 ## Attaching - moor.v - v#1305099
+0 ## Attaching - detach.v - v#1298668
+0 ## Attaching - hook.v - v#1365549
+0 ## Attaching - plaster.v - v#1612818
+0 ## Attaching - tether.v - v#1290009
+0 ## Attaching - solder.v - v#1595260
+0 ## Attaching - wire.v - v#1599052
+0 ## Attaching - nail.v - v#1357831
+0 ## Attaching - append.v - v#1328513
+0 ## Attaching - sew.v - v#1329239
+0 ## Attaching - tack_on.v - v#1328513
+0 ## Attaching - connect.v - v#1354673
+0 ## Attaching - anchor.v - v#1304944
+0 ## Attaching - concatenate.v - v#190180
+0 ## Attaching - agglutinate.v - v#1221684
+0 ## Attaching - rivet.v - v#1367266
+0 ## Attaching - affix.v - v#1356370
+0 ## Attaching - fuse.v - v#394813
+0 ## Attaching - attachment_item.n - n#2755352
+0 ## Difficulty - trivial.a - a#1280908
+0 ## Difficulty - tough.a - a#748058
+0 ## Difficulty - arduous.a - a#745858
+0 ## Difficulty - challenging.a - a#745642
+0 ## Difficulty - difficult.a - a#744916
+0 ## Difficulty - easy.a - a#749230
+0 ## Difficulty - tricky.a - a#746819
+0 ## Difficulty - challenge.n - n#13932948
+0 ## Difficulty - hard.a - a#744916
+0 ## Difficulty - impossible.a - a#1823092
+0 ## Indicating - name.v - v#1026095
+0 ## Ingest_substance - pull.v - v#1448100
+0 ## Ingest_substance - snort.v - v#1200245
+0 ## Ingest_substance - do.v - v#2560585
+0 ## Ingest_substance - use.v - v#1158872
+0 ## Ingest_substance - smoke.v - v#1198101
+0 ## Ingest_substance - drag.n - n#837675
+0 ## Ingest_substance - pop.v - v#1199487
+0 ## Ingest_substance - puff.v - v#1199009
+0 ## Ingest_substance - take.v - v#1156834
+0 ## Ingest_substance - drag.v - v#1199009
+0 ## Ingest_substance - toke.n - n#837965
+0 ## Ingest_substance - shoot.v - v#1002740
+0 ## Ingest_substance - sniff.v - v#2125032
+0 ## Ingest_substance - inject.v - v#1585523
+0 ## Accomplishment - accomplishment.n - n#35189
+0 ## Accomplishment - achievement.n - n#35189
+0 ## Accomplishment - achieve.v - v#2526085
+0 ## Accomplishment - accomplish.v - v#1640855
+0 ## Accomplishment - bring about.v - v#2090679
+0 ## Process_start - eruption.n - n#14321469
+0 ## Process_start - commence.v - v#345761
+0 ## Process_start - begin.v - v#345761
+0 ## Process_start - commencement.n - n#15265518
+0 ## Process_start - start.v - v#345761
+0 ## Process_start - incipient.a - a#818829
+0 ## Process_start - break out.v - v#345508
+0 ## Process_start - onset.n - n#7325990
+0 ## Process_start - erupt.v - v#345508
+0 ## Process_start - nascent.a - a#3356
+0 ## Try_defendant - try.v - v#2530167
+0 ## Placing - station.v - v#1088923
+0 ## Placing - stick.v - v#1528069
+0 ## Placing - park.v - v#1493380
+0 ## Placing - inject.v - v#1585523
+0 ## Placing - enclose.v - v#187526
+0 ## Placing - garage.v - v#2282946
+0 ## Placing - hang.v - v#1481819
+0 ## Placing - insert.v - v#187526
+0 ## Placing - implant.v - v#1528821
+0 ## Placing - set.v - v#1494310
+0 ## Placing - pot.v - v#1529491
+0 ## Placing - shoulder.v - v#1239359
+0 ## Placing - pocket.v - v#2292432
+0 ## Placing - plunge.v - v#1577635
+0 ## Placing - shower.v - v#2264601
+0 ## Placing - cage.v - v#2496036
+0 ## Placing - smear.v - v#1233387
+0 ## Placing - shelve.v - v#1497750
+0 ## Placing - drizzle.v - v#2757475
+0 ## Placing - emplace.v - v#1496630
+0 ## Placing - lay.v - v#1494310
+0 ## Placing - stuff.v - v#1524871
+0 ## Placing - stable.v - v#2459915
+0 ## Placing - put.v - v#1494310
+0 ## Placing - stow.v - v#1493234
+0 ## Placing - stash.v - v#2305856
+0 ## Placing - dust.v - v#1252216
+0 ## Placing - sheathe.v - v#1581362
+0 ## Placing - brush.v - v#1243809
+0 ## Placing - plant.v - v#1567275
+0 ## Placing - stand.v - v#1546768
+0 ## Placing - wrap.v - v#1580467
+0 ## Placing - bottle.v - v#1502279
+0 ## Placing - rub.v - v#1249724
+0 ## Placing - rest.v - v#1610101
+0 ## Placing - package.v - v#1485158
+0 ## Placing - cram.v - v#1612295
+0 ## Placing - tuck.v - v#1389776
+0 ## Placing - crate.v - v#1486678
+0 ## Placing - warehouse.v - v#2282365
+0 ## Placing - heap.v - v#1503404
+0 ## Placing - billet.v - v#2653159
+0 ## Placing - load.v - v#1612084
+0 ## Placing - box.v - v#1485158
+0 ## Placing - jam.v - v#2064131
+0 ## Placing - bestow.v - v#2263346
+0 ## Placing - drape.v - v#1542525
+0 ## Placing - embed.v - v#1528821
+0 ## Placing - bag.v - v#1485839
+0 ## Placing - archive.v - v#1384638
+0 ## Placing - sit.v - v#1543998
+0 ## Placing - lean.v - v#1606574
+0 ## Placing - placement.n - n#1051331
+0 ## Placing - situate.v - v#1575675
+0 ## Placing - position.v - v#1494310
+0 ## Placing - perch.v - v#1611240
+0 ## Placing - deposit.v - v#1575675
+0 ## Placing - daub.v - v#1233387
+0 ## Placing - pack.v - v#1482449
+0 ## Placing - arrange.v - v#1463963
+0 ## Placing - place.v - v#1494310
+0 ## Placing - insertion.n - n#6722186
+0 ## Placing - bin.v - v#1493142
+0 ## Placing - immerse.v - v#1577635
+0 ## Placing - file.v - v#1001857
+0 ## Placing - sow.v - v#1500873
+0 ## Placing - pile.v - v#1434822
+0 ## Placing - dab.v - v#1233194
+0 ## Placing - lodge.v - v#1528069
+0 ## Health_response - allergic.a - a#2360944
+0 ## Health_response - sensitive.a - a#2103481
+0 ## Health_response - allergy.n - n#14532816
+0 ## Health_response - susceptibility.n - n#14530061
+0 ## Health_response - sensitivity.n - n#5019661
+0 ## Health_response - susceptible.a - a#2360448
+0 ## Colonization - settlement_((entity)).n - n#8374049
+0 ## Colonization - settle.v - v#413876
+0 ## Colonization - colony.n - n#8374049
+0 ## Colonization - colonist.n - n#10583387
+0 ## Colonization - people.v - v#2650840
+0 ## Colonization - settlement_((act)).n - n#8374049
+0 ## Colonization - colonize.v - v#414174
+0 ## Colonization - settler.n - n#10583387
+0 ## Colonization - populate.v - v#2649830
+0 ## Expected_location_of_person - home.n - n#8559508
+0 ## Adopt_selection - embrace.v - v#601822
+0 ## Adopt_selection - assume.v - v#632236
+0 ## Adopt_selection - adopt.v - v#2346895
+0 ## Deciding - decision.n - n#5838176
+0 ## Deciding - decide.v - v#697589
+0 ## Frequency - seldom.adv - r#35385
+0 ## Frequency - rare.a - a#1067538
+0 ## Frequency - biennial.a - a#1969477
+0 ## Frequency - annual.a - a#1969150
+0 ## Frequency - infrequently.adv - r#374520
+0 ## Frequency - recurrent.a - a#592880
+0 ## Frequency - period.n - n#15113229
+0 ## Frequency - weekly.a - a#1968503
+0 ## Frequency - never.adv - r#20759
+0 ## Frequency - repeated.a - a#592880
+0 ## Frequency - infrequent.a - a#1067193
+0 ## Frequency - regularly.adv - r#195024
+0 ## Frequency - daily.a - a#1968165
+0 ## Frequency - once in a while.adv - r#21212
+0 ## Frequency - frequently.adv - r#35058
+0 ## Frequency - frequent.a - a#1066542
+0 ## Frequency - daily.adv - r#81486
+0 ## Frequency - frequency.n - n#15278281
+0 ## Frequency - often.adv - r#35058
+0 ## Frequency - at times.adv - r#21212
+0 ## Frequency - fortnightly.a - a#1969038
+0 ## Frequency - periodic.a - a#1967240
+0 ## Frequency - sometime.a - a#1729566
+0 ## Frequency - interval.n - n#15269513
+0 ## Frequency - constantly.adv - r#20476
+0 ## Frequency - yearly.a - a#1969150
+0 ## Frequency - always.adv - r#19339
+0 ## Frequency - occasional.a - a#1067415
+0 ## Frequency - sometimes.adv - r#21878
+0 ## Frequency - rate.n - n#15286249
+0 ## Frequency - monthly.a - a#1969707
+0 ## Frequency - intermittent.a - a#593836
+0 ## Frequency - recurring.a - a#593276
+0 ## Frequency - occasionally.adv - r#21212
+0 ## Frequency - sporadic.a - a#593374
+0 ## Frequency - nightly.a - a#1968352
+0 ## Domain - culturally.adv - r#135796
+0 ## Domain - geographically.adv - r#232172
+0 ## Domain - financially.adv - r#207127
+0 ## Domain - psychologically.adv - r#434921
+0 ## Domain - socially.adv - r#126527
+0 ## Domain - historically.adv - r#109687
+0 ## Domain - emotionally.adv - r#185567
+0 ## Domain - economically.adv - r#123229
+0 ## Domain - legally.adv - r#251820
+0 ## Daring - hazard.v - v#2545272
+0 ## Daring - dare.v - v#2374924
+0 ## Daring - risk.n - n#802238
+0 ## Daring - risk.v - v#2545578
+0 ## Daring - chance.v - v#2544348
+0 ## Daring - chance.n - n#14483917
+0 ## Daring - venture.v - v#2545272
+0 ## Cotheme - chase.v - v#2001858
+0 ## Cotheme - guide.v - v#1999798
+0 ## Cotheme - pursue.v - v#2000868
+0 ## Cotheme - pursuer.n - n#10494935
+0 ## Cotheme - shadow.v - v#2001461
+0 ## Cotheme - escort.v - v#2025829
+0 ## Cotheme - follow.v - v#2000868
+0 ## Cotheme - guided.a - a#1428972
+0 ## Cotheme - trail.v - v#2001858
+0 ## Cotheme - track.v - v#2001858
+0 ## Cotheme - conduct.v - v#1999798
+0 ## Cotheme - hound.v - v#2003601
+0 ## Cotheme - show.v - v#2000547
+0 ## Cotheme - dog.v - v#2001858
+0 ## Cotheme - tail.v - v#2001858
+0 ## Cotheme - usher.v - v#2000547
+0 ## Cotheme - lead.v - v#1999798
+0 ## Cotheme - stalk.v - v#2004009
+0 ## Cotheme - pursuit.n - n#319939
+0 ## Cotheme - walk.v - v#1904930
+0 ## Cotheme - accompany.v - v#2025550
+0 ## Cotheme - tag along.v - v#2027030
+0 ## Cotheme - shepherd.v - v#2550168
+0 ## Win_prize - win.v - v#1100145
+0 ## Public_services - service.n - n#577525
+0 ## Public_services - public service.n - n#1210281
+0 ## Grasp - see.v - v#2129289
+0 ## Grasp - fathom.v - v#728954
+0 ## Grasp - grasp.n - n#5806623
+0 ## Grasp - graspable.a - a#533452
+0 ## Grasp - grasp.v - v#588221
+0 ## Grasp - get.v - v#2210855
+0 ## Grasp - comprehend.v - v#588221
+0 ## Grasp - comprehensible.a - a#532892
+0 ## Grasp - apprehend.v - v#588221
+0 ## Grasp - unintelligible.a - a#535293
+0 ## Grasp - understand.v - v#588888
+0 ## Grasp - incomprehensible.a - a#533851
+0 ## Grasp - intelligible.a - a#533452
+0 ## Redirecting - detour.v - v#2066203
+0 ## Redirecting - redirect.v - v#1953334
+0 ## Redirecting - divert.v - v#2064887
+0 ## Participation - involvement.n - n#1239064
+0 ## Participation - party.n - n#10402824
+0 ## Participation - entanglement.n - n#4568557
+0 ## Participation - involved.a - a#1514827
+0 ## Participation - participate.v - v#1082606
+0 ## Participation - player.n - n#10439851
+0 ## Participation - participation.n - n#1239064
+0 ## Participation - embroiled.a - a#1516014
+0 ## Participation - entangled.a - a#1516014
+0 ## Participation - take part.v - v#2450256
+0 ## Participation - participant.n - n#10401829
+0 ## Craft - science.n - n#5999797
+0 ## Craft - art.n - n#2743547
+0 ## Craft - craft.n - n#5638063
+0 ## Communication_means - radio.v - v#1007495
+0 ## Communication_means - telephone.v - v#789448
+0 ## Communication_means - phone.v - v#789448
+0 ## Communication_means - telegraph.v - v#1007222
+0 ## Communication_means - wire.v - v#1007222
+0 ## Communication_means - cable.v - v#1007222
+0 ## Communication_means - fax.v - v#1007676
+0 ## Communication_means - telex.v - v#790965
+0 ## Communication_means - semaphore.v - v#1040278
+0 ## Being_active - inactive.a - a#1929802
+0 ## Being_active - active.a - a#1515280
+0 ## Respond_to_proposal - acceptance.n - n#6193727
+0 ## Respond_to_proposal - rebuff.n - n#7208000
+0 ## Respond_to_proposal - turn down.v - v#2237338
+0 ## Respond_to_proposal - rejection.n - n#7207273
+0 ## Respond_to_proposal - accept.v - v#2236124
+0 ## Respond_to_proposal - reject.v - v#2237338
+0 ## Respond_to_proposal - rebuff.v - v#798539
+0 ## Respond_to_proposal - refuse.v - v#2237338
+0 ## Obviousness - clarity.n - n#4820258
+0 ## Obviousness - clear.a - a#428404
+0 ## Obviousness - manifest.a - a#1618376
+0 ## Obviousness - unclear.a - a#430191
+0 ## Obviousness - evident.a - a#1618376
+0 ## Obviousness - clearly_((clarity)).adv - r#39058
+0 ## Obviousness - obviously.adv - r#39318
+0 ## Obviousness - audible.a - a#173764
+0 ## Obviousness - obvious.a - a#1618053
+0 ## Obviousness - clearly.adv - r#39058
+0 ## Obviousness - show.v - v#2148788
+0 ## Obviousness - visible.a - a#2515341
+0 ## Obviousness - show up.v - v#2139544
+0 ## Residence - bivouac.n - n#2944826
+0 ## Residence - reside.v - v#2648639
+0 ## Residence - squat.v - v#2649712
+0 ## Residence - camp.n - n#2944826
+0 ## Residence - occupant.n - n#10523519
+0 ## Residence - dwell.v - v#2649830
+0 ## Residence - live.v - v#2649830
+0 ## Residence - inhabitant.n - n#9620078
+0 ## Residence - occupy.v - v#2648639
+0 ## Residence - dweller.n - n#9620078
+0 ## Residence - camp.v - v#2653996
+0 ## Residence - camper.n - n#9889941
+0 ## Residence - stay.v - v#2637202
+0 ## Residence - room.v - v#2656763
+0 ## Residence - bivouac.v - v#2653996
+0 ## Residence - shack up.v - v#2651193
+0 ## Residence - squatter.n - n#10643218
+0 ## Residence - resident.n - n#10523519
+0 ## Residence - lodge.v - v#2652494
+0 ## Residence - inhabit.v - v#2649830
+0 ## Imitating - copy.v - v#1742886
+0 ## Imitating - imitate.v - v#1742886
+0 ## Imitating - mimic.v - v#1743531
+0 ## Imitating - ape.v - v#2675067
+0 ## Relating_concepts - relate.v - v#713167
+0 ## Relating_concepts - tie.v - v#1354673
+0 ## Relating_concepts - link.v - v#713167
+0 ## Relating_concepts - associate.v - v#713167
+0 ## Relating_concepts - connect.v - v#713167
+0 ## Finish_competition - victor.n - n#10782940
+0 ## Finish_competition - tie.n - n#7353716
+0 ## Finish_competition - winner.n - n#10782940
+0 ## Finish_competition - tie.v - v#1115190
+0 ## Finish_competition - loss.n - n#67526
+0 ## Finish_competition - lose.v - v#2287789
+0 ## Finish_competition - show.v - v#2148788
+0 ## Finish_competition - draw.n - n#7353716
+0 ## Finish_competition - win.n - n#7354731
+0 ## Finish_competition - victorious.a - a#2333314
+0 ## Finish_competition - win.v - v#1100145
+0 ## Finish_competition - victory.n - n#7473441
+0 ## Direction - south.adv - r#243938
+0 ## Direction - south.n - n#13835899
+0 ## Direction - right.adv - r#205052
+0 ## Direction - left.adv - r#387666
+0 ## Direction - west.n - n#13836136
+0 ## Direction - east.n - n#13835664
+0 ## Direction - up.adv - r#96333
+0 ## Direction - north.adv - r#244043
+0 ## Direction - forward.adv - r#74641
+0 ## Direction - down.adv - r#95320
+0 ## Direction - outward.adv - r#258677
+0 ## Direction - east.adv - r#323786
+0 ## Have_as_requirement - need.v - v#2627934
+0 ## Have_as_requirement - require.v - v#2627934
+0 ## Have_as_requirement - take.v - v#2627934
+0 ## Have_as_requirement - demand.v - v#2627934
+0 ## Control - control.v - v#662589
+0 ## Control - determine.v - v#918872
+0 ## Simultaneity - simultaneity.n - n#5048123
+0 ## Simultaneity - concurrent.a - a#2378496
+0 ## Simultaneity - coincide.v - v#2660442
+0 ## Simultaneity - co-occur.v - v#2660442
+0 ## Simultaneity - simultaneous.a - a#2378496
+0 ## Simultaneity - simultaneously.adv - r#120095
+0 ## Simultaneity - conjunction.n - n#5048301
+0 ## Simultaneity - co-occurrence.n - n#5048301
+0 ## Simultaneity - concurrency.n - n#7176682
+0 ## Kidnapping - abduction.n - n#775460
+0 ## Kidnapping - snatch.v - v#1471043
+0 ## Kidnapping - abductor.n - n#10230801
+0 ## Kidnapping - kidnapping.n - n#775702
+0 ## Kidnapping - nab.v - v#1600759
+0 ## Kidnapping - kidnap.v - v#1471043
+0 ## Kidnapping - snatcher.n - n#10230801
+0 ## Kidnapping - abduct.v - v#1471043
+0 ## Kidnapping - kidnapper.n - n#10230801
+0 ## Kidnapping - shanghai.v - v#1471547
+0 ## Military - armed forces.n - n#8199025
+0 ## Military - military.n - n#8199025
+0 ## Military - naval.a - a#2767701
+0 ## Military - military.a - a#1518386
+0 ## Military - air force.n - n#8196024
+0 ## Military - force.n - n#8208016
+0 ## Military - navy.n - n#8191701
+0 ## Military - army.n - n#8191230
+0 ## Scope - scope.n - n#5125377
+0 ## Impression - image.n - n#4675777
+0 ## Impression - persona.n - n#4677716
+0 ## Food_gathering - pick.v - v#1382083
+0 ## Food_gathering - gather.v - v#1380638
+0 ## Food_gathering - bring in.v - v#2078591
+0 ## Food_gathering - harvest.v - v#1320009
+0 ## Money - capital.n - n#13353607
+0 ## Money - money.n - n#13384557
+0 ## Money - sterling.n - n#13385080
+0 ## Money - funds.n - n#13356112
+0 ## Money - cash.n - n#13386614
+0 ## Money - dinero.n - n#13385216
+0 ## Money - dough.n - n#13385216
+0 ## Personal_relationship - amigo.n - n#9788521
+0 ## Personal_relationship - suitor.n - n#10674130
+0 ## Personal_relationship - sleep_(with).v - v#14742
+0 ## Personal_relationship - estranged.a - a#1463326
+0 ## Personal_relationship - significant other.n - n#10024362
+0 ## Personal_relationship - buddy.n - n#9877951
+0 ## Personal_relationship - divorcee.n - n#10020366
+0 ## Personal_relationship - friendship.n - n#13931145
+0 ## Personal_relationship - mistress.n - n#10323752
+0 ## Personal_relationship - mate.n - n#10640620
+0 ## Personal_relationship - cohabit.v - v#2651193
+0 ## Personal_relationship - familiar.a - a#453053
+0 ## Personal_relationship - spinster.n - n#10636488
+0 ## Personal_relationship - betrothed.a - a#158110
+0 ## Personal_relationship - cohabitation.n - n#1054876
+0 ## Personal_relationship - pal.n - n#9877951
+0 ## Personal_relationship - wife.n - n#10780632
+0 ## Personal_relationship - beau.n - n#9871364
+0 ## Personal_relationship - court.v - v#2534492
+0 ## Personal_relationship - spouse.n - n#10640620
+0 ## Personal_relationship - bachelor.n - n#9829923
+0 ## Personal_relationship - husband.n - n#10193967
+0 ## Personal_relationship - partner.n - n#10640620
+0 ## Personal_relationship - divorced.a - a#1482551
+0 ## Personal_relationship - lover.n - n#9622302
+0 ## Personal_relationship - sugar_daddy.n - n#10673296
+0 ## Personal_relationship - widower.n - n#10780506
+0 ## Personal_relationship - paramour.n - n#9952393
+0 ## Personal_relationship - inamorata.n - n#10202085
+0 ## Personal_relationship - affair.n - n#5671325
+0 ## Personal_relationship - romance.n - n#13931436
+0 ## Personal_relationship - couple.n - n#7985628
+0 ## Personal_relationship - marital.a - a#2852920
+0 ## Personal_relationship - married.a - a#2852920
+0 ## Personal_relationship - crush.n - n#7544351
+0 ## Personal_relationship - companion.n - n#9945905
+0 ## Personal_relationship - chum.n - n#9877951
+0 ## Personal_relationship - cobber.n - n#9933020
+0 ## Personal_relationship - adultery.n - n#848466
+0 ## Personal_relationship - boyfriend.n - n#9871364
+0 ## Personal_relationship - date.v - v#2486232
+0 ## Personal_relationship - single.a - a#1482228
+0 ## Personal_relationship - marriage.n - n#13963970
+0 ## Personal_relationship - widowed.a - a#1482865
+0 ## Personal_relationship - engaged.a - a#293611
+0 ## Personal_relationship - spousal.a - a#2843495
+0 ## Personal_relationship - engagement.n - n#8385009
+0 ## Personal_relationship - befriend.v - v#2588677
+0 ## Personal_relationship - friend.n - n#10112591
+0 ## Personal_relationship - betrothed.n - n#9851575
+0 ## Personal_relationship - widow.n - n#10780284
+0 ## Personal_relationship - widow.v - v#360337
+0 ## Personal_relationship - girlfriend.n - n#10130877
+0 ## Personal_relationship - moll.n - n#10327475
+0 ## State_of_entity - condition.n - n#13920835
+0 ## State_of_entity - state.n - n#8654360
+0 ## Exchange_currency - exchange.v - v#161225
+0 ## Exchange_currency - change.v - v#126264
+0 ## Exchange_currency - convert.v - v#161225
+0 ## Capacity - sleep.v - v#14742
+0 ## Capacity - serve.v - v#1180351
+0 ## Capacity - fit.v - v#2702830
+0 ## Capacity - take.v - v#1156834
+0 ## Capacity - seat.v - v#2701962
+0 ## Capacity - feed.v - v#1182021
+0 ## Summarizing - sum up.v - v#1007924
+0 ## Summarizing - summarize.v - v#1007924
+0 ## Summarizing - synopsis.n - n#6468951
+0 ## Summarizing - boil down.v - v#237704
+0 ## Summarizing - outline.v - v#1006421
+0 ## People_by_religion - baptist.n - n#9838701
+0 ## People_by_religion - muslim.n - n#9682291
+0 ## People_by_religion - mormon.n - n#11191475
+0 ## People_by_religion - faithful.n - n#8223475
+0 ## People_by_religion - buddhist.n - n#9683757
+0 ## People_by_religion - jew.n - n#9681351
+0 ## People_by_religion - christian.n - n#9678009
+0 ## People_by_religion - pagan.n - n#10390902
+0 ## People_by_religion - zealot.n - n#10402086
+0 ## People_by_religion - infidel.n - n#10166394
+0 ## Be_in_control - control.n - n#5196375
+0 ## Breathing - sigh.v - v#4032
+0 ## Breathing - breath.n - n#14841770
+0 ## Breathing - suspire.v - v#1740
+0 ## Breathing - pant.v - v#5526
+0 ## Breathing - blow.v - v#7012
+0 ## Breathing - exhale.v - v#4227
+0 ## Breathing - inhalation_breath.n - n#836788
+0 ## Breathing - sigh.n - n#7129602
+0 ## Breathing - huff.v - v#1200245
+0 ## Breathing - respire.v - v#1740
+0 ## Breathing - inspire.v - v#5041
+0 ## Breathing - expire.v - v#4227
+0 ## Breathing - inhale.v - v#5041
+0 ## Breathing - exhalation_act.n - n#835267
+0 ## Breathing - gasp.v - v#5526
+0 ## Breathing - inhalation.n - n#836788
+0 ## Breathing - exhalation.n - n#835267
+0 ## Breathing - insufflate.v - v#79629
+0 ## Breathing - puff.v - v#5526
+0 ## Breathing - breathe.v - v#1740
+0 ## Occupy_rank - top.a - a#2439949
+0 ## Occupy_rank - rank.v - v#660102
+0 ## Occupy_rank - stand.v - v#1546111
+0 ## Indigenous_origin - local.n - n#3680942
+0 ## Indigenous_origin - indigenous.a - a#1036383
+0 ## Indigenous_origin - autochthonous.a - a#1036383
+0 ## Indigenous_origin - native.a - a#1036083
+0 ## Indigenous_origin - stranger.n - n#10661216
+0 ## Surviving - ride_out.v - v#2619122
+0 ## Surviving - survive.v - v#2618149
+0 ## Surviving - survival.n - n#13962166
+0 ## Surviving - weather.v - v#2707251
+0 ## Seeking_to_achieve - seek.v - v#1315613
+0 ## Seeking_to_achieve - pursue.v - v#1317533
+0 ## Seeking_to_achieve - pursuit.n - n#319939
+0 ## Inclination - penchant.n - n#7498210
+0 ## Inclination - predisposition.n - n#6200178
+0 ## Inclination - proclivity.n - n#6199561
+0 ## Inclination - propensity.n - n#6199561
+0 ## Inclination - inclined.a - a#1292128
+0 ## Inclination - predisposed.a - a#2362348
+0 ## Inclination - prone.a - a#1292884
+0 ## Inclination - tendency.n - n#6196584
+0 ## Prohibiting - ban.n - n#6542047
+0 ## Prohibiting - forbid.v - v#795863
+0 ## Prohibiting - proscribe.v - v#795863
+0 ## Prohibiting - prohibit.v - v#795863
+0 ## Prohibiting - control.n - n#830448
+0 ## Prohibiting - bar.v - v#796588
+0 ## Prohibiting - prohibition.n - n#201923
+0 ## Prohibiting - ban.v - v#796392
+0 ## Prohibiting - outlaw.v - v#2480923
+0 ## Motion_noise - purr.v - v#2188587
+0 ## Motion_noise - clink.v - v#2186690
+0 ## Motion_noise - chug.v - v#2179372
+0 ## Motion_noise - rustle.v - v#2182662
+0 ## Motion_noise - splash.v - v#1921591
+0 ## Motion_noise - whine.v - v#2171664
+0 ## Motion_noise - bang.v - v#2100176
+0 ## Motion_noise - clump.v - v#2184965
+0 ## Motion_noise - roar.v - v#1046059
+0 ## Motion_noise - howl.v - v#1046059
+0 ## Motion_noise - wheeze.v - v#6697
+0 ## Motion_noise - clunk.v - v#2184965
+0 ## Motion_noise - rumble.v - v#2187320
+0 ## Motion_noise - swish.v - v#2188198
+0 ## Motion_noise - clang.v - v#2174115
+0 ## Motion_noise - thunder.v - v#1046587
+0 ## Motion_noise - buzz.v - v#2182109
+0 ## Motion_noise - squelch.v - v#1921591
+0 ## Motion_noise - fizz.v - v#519363
+0 ## Motion_noise - thump.v - v#2184610
+0 ## Motion_noise - click.v - v#1054849
+0 ## Motion_noise - creak.v - v#2171664
+0 ## Motion_noise - clatter.v - v#2172127
+0 ## Motion_noise - gurgle.v - v#2177976
+0 ## Motion_noise - clank.v - v#2174311
+0 ## Motion_noise - crackle.v - v#1058224
+0 ## Motion_noise - hiss.v - v#1053771
+0 ## Motion_noise - splutter.v - v#986897
+0 ## Motion_noise - crash.v - v#2088627
+0 ## Motion_noise - ping.v - v#2178709
+0 ## Motion_noise - thud.v - v#2184797
+0 ## Motion_noise - putter.v - v#1473176
+0 ## Motion_noise - clack.v - v#2172127
+0 ## Motion_noise - whir.v - v#2188587
+0 ## Motion_noise - patter.v - v#2185187
+0 ## Motion_noise - crunch.v - v#1058224
+0 ## Motion_noise - screech.v - v#2171664
+0 ## Catastrophe - casualty.n - n#9899671
+0 ## Catastrophe - suffer.v - v#2109190
+0 ## Catastrophe - mischance.n - n#7314427
+0 ## Catastrophe - tragedy.n - n#7314838
+0 ## Catastrophe - incident.n - n#7307477
+0 ## Catastrophe - catastrophic.a - a#1161635
+0 ## Catastrophe - cataclysm.n - n#7314838
+0 ## Catastrophe - mishap.n - n#7314427
+0 ## Catastrophe - calamitous.a - a#1050088
+0 ## Catastrophe - apocalypse.n - n#7315631
+0 ## Catastrophe - betide.v - v#345000
+0 ## Catastrophe - catastrophe.n - n#7314838
+0 ## Catastrophe - befall.v - v#345000
+0 ## Catastrophe - disaster.n - n#7314838
+0 ## Catastrophe - misfortune.n - n#7304852
+0 ## Catastrophe - debacle.n - n#7365432
+0 ## Catastrophe - crisis.n - n#13933560
+0 ## Catastrophe - disastrous.a - a#1050088
+0 ## Catastrophe - calamity.n - n#7314838
+0 ## Medical_conditions - pyelonephritis.n - n#14566308
+0 ## Medical_conditions - unwell.a - a#2542325
+0 ## Medical_conditions - shock.n - n#14067076
+0 ## Medical_conditions - stress.n - n#14376188
+0 ## Medical_conditions - diverticulosis.n - n#14032480
+0 ## Medical_conditions - cataract.n - n#14254570
+0 ## Medical_conditions - illness.n - n#14061805
+0 ## Medical_conditions - ulcer.n - n#14211609
+0 ## Medical_conditions - diphtheria.n - n#14123510
+0 ## Medical_conditions - cold.n - n#14145501
+0 ## Medical_conditions - health.n - n#14447908
+0 ## Medical_conditions - conjunctivitis.n - n#14341432
+0 ## Medical_conditions - tumor.n - n#14235200
+0 ## Medical_conditions - polio.n - n#14140176
+0 ## Medical_conditions - depression.n - n#14404160
+0 ## Medical_conditions - infection.n - n#14174549
+0 ## Medical_conditions - cancer.n - n#14239918
+0 ## Medical_conditions - Alzheimer's.n - n#14396096
+0 ## Medical_conditions - hypoglycaemia.n - n#14319454
+0 ## Medical_conditions - hepatitis.n - n#14130354
+0 ## Medical_conditions - AIDS.n - n#14127782
+0 ## Medical_conditions - paraplegic.a - a#2546116
+0 ## Medical_conditions - cholera.n - n#14129579
+0 ## Medical_conditions - jaundice.n - n#14319684
+0 ## Medical_conditions - cholangitis.n - n#14340734
+0 ## Medical_conditions - hernia.n - n#14295389
+0 ## Medical_conditions - plague.n - n#14138691
+0 ## Medical_conditions - syndrome.n - n#14304060
+0 ## Medical_conditions - cholecystitis.n - n#14340822
+0 ## Medical_conditions - syphilis.n - n#14133985
+0 ## Medical_conditions - colitis.n - n#14341091
+0 ## Medical_conditions - sciatica.n - n#14330727
+0 ## Medical_conditions - malnourishment.n - n#14040490
+0 ## Medical_conditions - disease.n - n#14070360
+0 ## Medical_conditions - arthritis.n - n#14186541
+0 ## Medical_conditions - meningitis.n - n#14137829
+0 ## Medical_conditions - dermatitis.n - n#14224757
+0 ## Medical_conditions - wound.n - n#14298815
+0 ## Medical_conditions - amnesia.n - n#5672391
+0 ## Medical_conditions - ill.a - a#2541302
+0 ## Medical_conditions - rubella.n - n#14123259
+0 ## Medical_conditions - menorrhagia.n - n#13513540
+0 ## Medical_conditions - cirrhosis.n - n#14116482
+0 ## Medical_conditions - candida.n - n#13079419
+0 ## Medical_conditions - leukemia.n - n#14242922
+0 ## Medical_conditions - hypertension.n - n#14103510
+0 ## Medical_conditions - ailment.n - n#14055408
+0 ## Medical_conditions - acromegaly.n - n#14368483
+0 ## Medical_conditions - sickness.n - n#14061805
+0 ## Medical_conditions - sick.a - a#2541302
+0 ## Medical_conditions - mumps.n - n#14138178
+0 ## Medical_conditions - leprosy.n - n#14136187
+0 ## Medical_conditions - anorexia.n - n#14055796
+0 ## Medical_conditions - stenosis.n - n#14107374
+0 ## Medical_conditions - condition.n - n#13923440
+0 ## Medical_conditions - measles.n - n#14123044
+0 ## Medical_conditions - influenza.n - n#14122497
+0 ## Medical_conditions - healthy.a - a#1170243
+0 ## Medical_conditions - asphyxia.n - n#14042423
+0 ## Medical_conditions - affliction.n - n#14213199
+0 ## Medical_conditions - malaria.n - n#14077830
+0 ## Medical_conditions - malnutrition.n - n#14199700
+0 ## Medical_conditions - diarrhea.n - n#14371913
+0 ## Medical_conditions - tetanus.n - n#14185803
+0 ## Medical_conditions - German measles.n - n#14123259
+0 ## Medical_conditions - bronchitis.n - n#14146273
+0 ## Medical_conditions - rosacea.n - n#14222352
+0 ## Medical_conditions - psoriasis.n - n#14231794
+0 ## Medical_conditions - schizophrenia.n - n#14398523
+0 ## Medical_conditions - disorder.n - n#14052403
+0 ## Medical_conditions - eczema.n - n#14226056
+0 ## Medical_conditions - flu.n - n#14122497
+0 ## Medical_conditions - tuberculosis.n - n#14143415
+0 ## Medical_conditions - asthma.n - n#14145911
+0 ## Medical_conditions - diabetes.n - n#14117805
+0 ## Rejuvenation - resuscitation.n - n#1048210
+0 ## Rejuvenation - revitalization.n - n#1047338
+0 ## Rejuvenation - reawaken.v - v#19182
+0 ## Rejuvenation - restore.v - v#168588
+0 ## Rejuvenation - reinvigorate.v - v#28362
+0 ## Rejuvenation - rejuvenation.n - n#401639
+0 ## Rejuvenation - renew.v - v#1631072
+0 ## Rejuvenation - revitalize.v - v#97621
+0 ## Rejuvenation - revival.n - n#1047338
+0 ## Rejuvenation - resuscitate.v - v#98083
+0 ## Rejuvenation - invigorate.v - v#442063
+0 ## Rejuvenation - rejuvenate.v - v#168588
+0 ## Rejuvenation - refresh.v - v#164444
+0 ## Excreting - piss.v - v#72012
+0 ## Excreting - evacuate.v - v#73343
+0 ## Excreting - retch.v - v#76400
+0 ## Excreting - puke.v - v#76400
+0 ## Excreting - defecate.v - v#74038
+0 ## Excreting - pee.v - v#72012
+0 ## Excreting - burp.v - v#3431
+0 ## Excreting - void.v - v#73343
+0 ## Excreting - belch.v - v#3431
+0 ## Excreting - regurgitate.v - v#76400
+0 ## Excreting - spew.v - v#76400
+0 ## Excreting - sweat.n - n#5405751
+0 ## Excreting - perspire.v - v#67545
+0 ## Excreting - perspiration.n - n#5405751
+0 ## Excreting - throw up.v - v#76400
+0 ## Excreting - shit.v - v#74038
+0 ## Excreting - spit up.v - v#6238
+0 ## Excreting - sweat.v - v#67545
+0 ## Excreting - urinate.v - v#72012
+0 ## Excreting - fart.v - v#101629
+0 ## Excreting - vomit.v - v#76400
+0 ## Duration_attribute - short.a - a#1442186
+0 ## Duration_attribute - abiding.a - a#1754873
+0 ## Duration_attribute - brief.a - a#1442826
+0 ## Duration_attribute - momentary.a - a#1443097
+0 ## Duration_attribute - chronic.a - a#1438963
+0 ## Duration_attribute - interim.a - a#1757483
+0 ## Duration_attribute - lengthy.a - a#1439155
+0 ## Duration_attribute - lasting.a - a#1754421
+0 ## Duration_attribute - enduring.a - a#1754873
+0 ## Duration_attribute - ephemeral.a - a#1756292
+0 ## Duration_attribute - eternal.a - a#1755024
+0 ## Duration_attribute - long.a - a#1437963
+0 ## Duration_attribute - extended.a - a#1439155
+0 ## Duration_attribute - persistent.a - a#1758339
+0 ## Duration_attribute - perpetual.a - a#1755024
+0 ## Vehicle - tank car.n - n#4389521
+0 ## Vehicle - lorry.n - n#3690473
+0 ## Vehicle - submarine.n - n#4347754
+0 ## Vehicle - vessel.n - n#4530566
+0 ## Vehicle - tricycle.n - n#4482393
+0 ## Vehicle - buggy.n - n#2912557
+0 ## Vehicle - limousine.n - n#3670208
+0 ## Vehicle - liner.n - n#3673027
+0 ## Vehicle - kayak.n - n#3609235
+0 ## Vehicle - convertible.n - n#3100240
+0 ## Vehicle - cab.n - n#2930766
+0 ## Vehicle - tank.n - n#4389033
+0 ## Vehicle - coach.n - n#3895866
+0 ## Vehicle - vehicle.n - n#4524313
+0 ## Vehicle - helicopter.n - n#3512147
+0 ## Vehicle - automobile.n - n#2958343
+0 ## Vehicle - van.n - n#4520480
+0 ## Vehicle - ship.n - n#4194289
+0 ## Vehicle - boat.n - n#2858304
+0 ## Vehicle - taxi.n - n#2930766
+0 ## Vehicle - yacht.n - n#4610013
+0 ## Vehicle - tram.n - n#4335435
+0 ## Vehicle - bike.n - n#2834778
+0 ## Vehicle - schooner.n - n#4147183
+0 ## Vehicle - canoe.n - n#2951358
+0 ## Vehicle - car.n - n#2958343
+0 ## Vehicle - cart.n - n#3484083
+0 ## Vehicle - train.n - n#4468005
+0 ## Vehicle - ferry.n - n#3329663
+0 ## Vehicle - truck.n - n#4490091
+0 ## Vehicle - scooter.n - n#3556811
+0 ## Vehicle - warplane.n - n#4552348
+0 ## Vehicle - bicycle.n - n#2834778
+0 ## Vehicle - toboggan.n - n#4443433
+0 ## Vehicle - plane.n - n#2691156
+0 ## Vehicle - sedan.n - n#4166281
+0 ## Vehicle - carriage.n - n#2968473
+0 ## Vehicle - bus.n - n#2924116
+0 ## Vehicle - aeroplane.n - n#2691156
+0 ## Required_event - better.v - v#1106864
+0 ## Required_event - best.v - v#1109259
+0 ## Required_event - need.v - v#1188725
+0 ## Ceasing_to_be - vanish.v - v#426958
+0 ## Ceasing_to_be - disappear.v - v#426958
+0 ## Ceasing_to_be - dissipation.n - n#7332148
+0 ## Ceasing_to_be - fade.v - v#421917
+0 ## Ceasing_to_be - disappearance.n - n#230172
+0 ## Ceasing_to_be - dissolve.v - v#447771
+0 ## Ceasing_to_be - go away.v - v#426958
+0 ## Ceasing_to_be - dissipate.v - v#2030424
+0 ## Earnings_and_losses - result.n - n#11410625
+0 ## Earnings_and_losses - loss.n - n#5162985
+0 ## Earnings_and_losses - profit.n - n#13258362
+0 ## Earnings_and_losses - net.n - n#13258362
+0 ## Earnings_and_losses - lose.v - v#2288828
+0 ## Earnings_and_losses - make.v - v#2560585
+0 ## Earnings_and_losses - earnings.n - n#13258362
+0 ## Earnings_and_losses - earn.v - v#2289295
+0 ## Earnings_and_losses - net.v - v#2291258
+0 ## Earnings_and_losses - income.n - n#13255145
+0 ## Earnings_and_losses - revenue.n - n#13256691
+0 ## Earnings_and_losses - pull.v - v#2582615
+0 ## Being_obligatory - compulsory.a - a#848466
+0 ## Being_obligatory - behoove.v - v#2668378
+0 ## Being_obligatory - incumbent.a - a#1580601
+0 ## Being_obligatory - obligatory.a - a#848074
+0 ## Being_obligatory - binding.a - a#2499036
+0 ## Being_obligatory - mandatory.a - a#848466
+0 ## Making_faces - smirk.v - v#29336
+0 ## Making_faces - grimace.v - v#34288
+0 ## Making_faces - scowl.v - v#33852
+0 ## Making_faces - grin.v - v#29025
+0 ## Making_faces - smile.v - v#28565
+0 ## Making_faces - frown.v - v#32981
+0 ## Making_faces - pout.v - v#34758
+0 ## Storing - keep.v - v#2681795
+0 ## Storing - storage.n - n#4329190
+0 ## Storing - stock.v - v#2285392
+0 ## Storing - cache.v - v#2305856
+0 ## Storing - store.v - v#2282506
+0 ## Storing - warehouse.v - v#2282365
+0 ## Hit_target - shoot.v - v#1134781
+0 ## Hit_target - pick off.v - v#2484875
+0 ## Hit_target - hit.v - v#1123887
+0 ## Expertise - conversant.a - a#1307067
+0 ## Expertise - adeptness.n - n#5642175
+0 ## Expertise - inexpert.a - a#1870636
+0 ## Expertise - proficiency.n - n#5154114
+0 ## Expertise - master.n - n#10280130
+0 ## Expertise - inept.a - a#511526
+0 ## Expertise - incredible.a - a#645493
+0 ## Expertise - ace.n - n#9762509
+0 ## Expertise - amateur.n - n#9786585
+0 ## Expertise - so-so.a - a#1674604
+0 ## Expertise - adept.a - a#2226162
+0 ## Expertise - proficient.a - a#2226162
+0 ## Expertise - incompetence.n - n#5154241
+0 ## Expertise - specialist.n - n#10631941
+0 ## Expertise - outstanding.a - a#1278818
+0 ## Expertise - competent.a - a#510050
+0 ## Expertise - skilled.a - a#2225510
+0 ## Expertise - expertise.n - n#5640729
+0 ## Expertise - familiar.a - a#1307067
+0 ## Expertise - whiz.n - n#9762509
+0 ## Expertise - expert.a - a#2226162
+0 ## Expertise - adept.n - n#9762509
+0 ## Expertise - experienced.a - a#935500
+0 ## Expertise - incompetent.a - a#511214
+0 ## Expertise - virtuoso.n - n#9762509
+0 ## Expertise - mediocre.a - a#1128253
+0 ## Expertise - amateur.a - a#1870636
+0 ## Expertise - awful.a - a#1126291
+0 ## Expertise - skilful.a - a#2226162
+0 ## Expertise - ineptness.n - n#5648459
+0 ## Expertise - connoisseur.n - n#9956387
+0 ## Expertise - wizard.n - n#9762509
+0 ## Expertise - tremendous.a - a#1676517
+0 ## Expertise - novice.n - n#10364198
+0 ## Expertise - skill.n - n#5636887
+0 ## Expertise - ace.a - a#2341864
+0 ## Expertise - experience.n - n#5758059
+0 ## Expertise - know-how.n - n#5616786
+0 ## Expertise - ineptitude.n - n#5648459
+0 ## Expertise - maven.n - n#9762509
+0 ## Expertise - great.a - a#1386883
+0 ## Expertise - expert.n - n#9617867
+0 ## Expertise - splendid.a - a#2343110
+0 ## Expertise - stupendous.a - a#1384730
+0 ## Expertise - prowess.n - n#5638987
+0 ## Expertise - superlative.a - a#2343517
+0 ## Expertise - wonderful.a - a#1676517
+0 ## Expertise - pro.n - n#10480583
+0 ## Expertise - competence.n - n#5153520
+0 ## Expertise - terrific.a - a#1676517
+0 ## Expertise - conversance.n - n#5817145
+0 ## Expertise - mastery.n - n#1128655
+0 ## Expertise - buff.n - n#10077593
+0 ## Expertise - guru.n - n#10152616
+0 ## Expertise - terrible.a - a#1126291
+0 ## Expertise - dreadful.a - a#1126291
+0 ## Expertise - virtuosity.n - n#5637222
+0 ## Expertise - crack.a - a#2341864
+0 ## Expertise - inexperienced.a - a#936740
+0 ## Expertise - good.a - a#1123148
+0 ## Expertise - excellent.a - a#2343110
+0 ## Expertise - versed.a - a#936038
+0 ## Expertise - new_(to).a - a#1640850
+0 ## Expertise - superb.a - a#1125154
+0 ## Expertise - bad.a - a#1125429
+0 ## Expertise - master.a - a#1277426
+0 ## Expertise - excel.v - v#2673965
+0 ## Expertise - fantastic.a - a#1676517
+0 ## Building_subparts - family room.n - n#3319745
+0 ## Building_subparts - pantry.n - n#3885535
+0 ## Building_subparts - cellar.n - n#2800497
+0 ## Building_subparts - loft.n - n#3686130
+0 ## Building_subparts - lavatory.n - n#4446276
+0 ## Building_subparts - workroom.n - n#4602762
+0 ## Building_subparts - checkroom.n - n#3011892
+0 ## Building_subparts - antechamber.n - n#2715513
+0 ## Building_subparts - anteroom.n - n#2715513
+0 ## Building_subparts - cell.n - n#2991555
+0 ## Building_subparts - kitchen.n - n#3619890
+0 ## Building_subparts - atelier.n - n#2746841
+0 ## Building_subparts - larder.n - n#3885535
+0 ## Building_subparts - master bedroom.n - n#3727465
+0 ## Building_subparts - garret.n - n#3686130
+0 ## Building_subparts - scullery.n - n#4157099
+0 ## Building_subparts - chapel.n - n#3007130
+0 ## Building_subparts - vestibule.n - n#2715513
+0 ## Building_subparts - buttery.n - n#3885535
+0 ## Building_subparts - chamber.n - n#2821627
+0 ## Building_subparts - basement.n - n#2800497
+0 ## Building_subparts - living room.n - n#3679712
+0 ## Building_subparts - wing.n - n#2713594
+0 ## Building_subparts - foyer.n - n#2715513
+0 ## Building_subparts - rumpus room.n - n#4119478
+0 ## Building_subparts - ben.n - n#9218641
+0 ## Building_subparts - workshop.n - n#4603081
+0 ## Building_subparts - tower.n - n#4460130
+0 ## Building_subparts - elevator.n - n#3281145
+0 ## Building_subparts - powder room.n - n#3632963
+0 ## Building_subparts - laundry.n - n#3648066
+0 ## Building_subparts - corridor.n - n#3112099
+0 ## Building_subparts - boudoir.n - n#2878534
+0 ## Building_subparts - office.n - n#3841666
+0 ## Building_subparts - bathroom.n - n#4446276
+0 ## Building_subparts - kitchenette.n - n#3620353
+0 ## Building_subparts - dining room.n - n#3200701
+0 ## Building_subparts - lobby.n - n#2715513
+0 ## Building_subparts - lift.n - n#3281145
+0 ## Building_subparts - solarium.n - n#4356925
+0 ## Building_subparts - belfry.n - n#2824319
+0 ## Building_subparts - repository.n - n#3177349
+0 ## Building_subparts - den.n - n#3175081
+0 ## Building_subparts - playroom.n - n#4119478
+0 ## Building_subparts - salon.n - n#4131015
+0 ## Building_subparts - refectory.n - n#4067818
+0 ## Building_subparts - storeroom.n - n#4329477
+0 ## Building_subparts - bedroom.n - n#2821627
+0 ## Building_subparts - porch.n - n#3984381
+0 ## Building_subparts - sacristy.n - n#4532504
+0 ## Building_subparts - ballroom.n - n#2783324
+0 ## Building_subparts - cloakroom.n - n#3045800
+0 ## Building_subparts - dressing room.n - n#3238131
+0 ## Building_subparts - apartment.n - n#2726305
+0 ## Building_subparts - studio.n - n#4344544
+0 ## Building_subparts - TV room.n - n#4406239
+0 ## Building_subparts - wine cellar.n - n#2991847
+0 ## Building_subparts - catacomb.n - n#2981024
+0 ## Building_subparts - sitting room.n - n#3679712
+0 ## Building_subparts - study.n - n#5755883
+0 ## Building_subparts - attic.n - n#3686130
+0 ## Building_subparts - altar.n - n#2699629
+0 ## Building_subparts - room.n - n#4105893
+0 ## Building_subparts - stoop.n - n#4327204
+0 ## Building_subparts - flat.n - n#2726305
+0 ## Building_subparts - parlor.n - n#3679712
+0 ## Building_subparts - hallway.n - n#3479952
+0 ## Building_subparts - nursery.n - n#3836062
+0 ## Building_subparts - ward.n - n#4549919
+0 ## Building_subparts - closet.n - n#4558478
+0 ## Building_subparts - veranda.n - n#4527648
+0 ## Building_subparts - chancellery.n - n#3005033
+0 ## Cause_change_of_consistency - harden.v - v#443116
+0 ## Cause_change_of_consistency - thin.v - v#430999
+0 ## Cause_change_of_consistency - set.v - v#442669
+0 ## Cause_change_of_consistency - congeal.v - v#442669
+0 ## Cause_change_of_consistency - curdle.v - v#442847
+0 ## Cause_change_of_consistency - jell.v - v#442669
+0 ## Cause_change_of_consistency - inspissate.v - v#431610
+0 ## Cause_change_of_consistency - indurate.v - v#443384
+0 ## Cause_change_of_consistency - clot.v - v#457998
+0 ## Cause_change_of_consistency - soften.v - v#2190632
+0 ## Cause_change_of_consistency - thicken.v - v#431327
+0 ## Cause_change_of_consistency - coagulate.v - v#457998
+0 ## Knot_creation - tie.v - v#141632
+0 ## Sentencing - condemn.v - v#906735
+0 ## Sentencing - sentence.n - n#1189282
+0 ## Sentencing - order.v - v#746718
+0 ## Sentencing - sentence.v - v#906735
+0 ## Age - maturity.n - n#15152817
+0 ## Age - new.a - a#1640850
+0 ## Age - age.n - n#4924103
+0 ## Age - oldish.a - a#1646366
+0 ## Age - old.a - a#1643620
+0 ## Age - fresh.a - a#1067694
+0 ## Age - ancient.a - a#1644847
+0 ## Age - youngish.a - a#1649651
+0 ## Age - young.a - a#1646941
+0 ## Accuracy - inaccurately.adv - r#204643
+0 ## Accuracy - inaccurate.a - a#23383
+0 ## Accuracy - accurately.adv - r#204523
+0 ## Accuracy - accuracy.n - n#4802907
+0 ## Accuracy - precision.n - n#4803880
+0 ## Accuracy - inaccuracy.n - n#4804451
+0 ## Accuracy - exact.a - a#914421
+0 ## Accuracy - accurate.a - a#21766
+0 ## Accuracy - precise.a - a#631798
+0 ## Forgoing - forego.v - v#2712443
+0 ## Forgoing - abstention.n - n#4882622
+0 ## Forgoing - abstain.v - v#2463426
+0 ## Forgoing - abstinence.n - n#4882622
+0 ## Forgoing - forbearance.n - n#1066689
+0 ## Forgoing - forbear.v - v#2725714
+0 ## Forgoing - forbearing.a - a#1736571
+0 ## Forgoing - skip.v - v#2613860
+0 ## Forgoing - refrain.v - v#2725714
+0 ## Manipulate_into_shape - wind.v - v#1522276
+0 ## Manipulate_into_shape - coil.v - v#1523986
+0 ## Manipulate_into_shape - twist.v - v#1222645
+0 ## Manipulate_into_shape - loop.v - v#1523986
+0 ## Manipulate_into_shape - curl.v - v#1523986
+0 ## Fall_asleep - nod off.v - v#17282
+0 ## Fall_asleep - doze off.v - v#17282
+0 ## Fall_asleep - drift off.v - v#17282
+0 ## Fall_asleep - zonk out.v - v#16855
+0 ## Fall_asleep - faint.v - v#23646
+0 ## Fall_asleep - black out.v - v#23868
+0 ## Fall_asleep - pass out.v - v#23868
+0 ## Sent_items - post.n - n#8463063
+0 ## Sent_items - shipment.n - n#2964389
+0 ## Sent_items - mail.n - n#8463063
+0 ## Repel - repel.v - v#1506157
+0 ## Repel - resist.v - v#1115916
+0 ## Killing - liquidator.n - n#10338707
+0 ## Killing - slaughterer.n - n#9884133
+0 ## Killing - immolation.n - n#227969
+0 ## Killing - regicide.n - n#225070
+0 ## Killing - lethal.a - a#993885
+0 ## Killing - murder.n - n#220522
+0 ## Killing - exterminate.v - v#1327582
+0 ## Killing - genocide.n - n#1245159
+0 ## Killing - assassination.n - n#221056
+0 ## Killing - slaughter.v - v#1322854
+0 ## Killing - slayer.n - n#10231087
+0 ## Killing - annihilate.v - v#470701
+0 ## Killing - matricide.n - n#10302816
+0 ## Killing - infanticide.n - n#10204833
+0 ## Killing - slaying.n - n#220522
+0 ## Killing - decapitation.n - n#228181
+0 ## Killing - massacre.v - v#479176
+0 ## Killing - carnage.n - n#223983
+0 ## Killing - annihilation.n - n#7330828
+0 ## Killing - suicide.n - n#10673669
+0 ## Killing - homicide.n - n#220023
+0 ## Killing - fatality.n - n#7332956
+0 ## Killing - lynch.v - v#2484397
+0 ## Killing - garrotte.v - v#1571744
+0 ## Killing - terminate.v - v#352826
+0 ## Killing - massacre.n - n#223983
+0 ## Killing - crucify.v - v#2484049
+0 ## Killing - holocaust.n - n#1245318
+0 ## Killing - assassinate.v - v#2483000
+0 ## Killing - liquidation.n - n#223720
+0 ## Killing - dispatch.v - v#2482425
+0 ## Killing - fatal.a - a#993529
+0 ## Killing - shooting.n - n#225150
+0 ## Killing - slaughter.n - n#223983
+0 ## Killing - butcher.v - v#1322854
+0 ## Killing - kill.v - v#1323958
+0 ## Killing - smother.v - v#1569181
+0 ## Killing - beheading.n - n#228181
+0 ## Killing - deadly.a - a#993885
+0 ## Killing - extermination.n - n#1245061
+0 ## Killing - slay.v - v#2482425
+0 ## Killing - destroy.v - v#1619929
+0 ## Killing - euthanasia.n - n#219856
+0 ## Killing - behead.v - v#1571354
+0 ## Killing - liquidate.v - v#1327301
+0 ## Killing - crucifixion.n - n#1165337
+0 ## Killing - asphyxiate.v - v#1569181
+0 ## Killing - drown.v - v#472532
+0 ## Killing - pogrom.n - n#421210
+0 ## Killing - starve.v - v#1187740
+0 ## Killing - killer.n - n#10231087
+0 ## Killing - murderer.n - n#10338707
+0 ## Killing - decapitate.v - v#1571354
+0 ## Killing - butchery.n - n#223983
+0 ## Killing - assassin.n - n#9813696
+0 ## Killing - suffocation.n - n#225593
+0 ## Killing - murder.v - v#2482425
+0 ## Killing - silence.v - v#461493
+0 ## Killing - suffocate.v - v#359511
+0 ## Killing - patricide.n - n#10407221
+0 ## Killing - eliminate.v - v#471711
+0 ## Killing - fratricide.n - n#10109342
+0 ## Sole_instance - one and only.a - a#505410
+0 ## Sole_instance - sole.a - a#2214736
+0 ## Sole_instance - lone.a - a#2214736
+0 ## Sole_instance - single.a - a#2213947
+0 ## Sole_instance - only.a - a#2214736
+0 ## Cause_to_be_dry - dry_up.v - v#211108
+0 ## Cause_to_be_dry - dehydrate.v - v#211108
+0 ## Cause_to_be_dry - dry_out.v - v#218475
+0 ## Cause_to_be_dry - desiccate.v - v#211396
+0 ## Cause_to_be_dry - dehumidify.v - v#216057
+0 ## Cause_to_be_dry - desiccation.n - n#13460568
+0 ## Cause_to_be_dry - dry.v - v#218475
+0 ## Make_acquaintance - meet.v - v#2023107
+0 ## Intoxicants - heroin.n - n#3516011
+0 ## Intoxicants - tranquillizer.n - n#4470232
+0 ## Intoxicants - downer.n - n#4166553
+0 ## Intoxicants - pot.n - n#3990834
+0 ## Intoxicants - inhalant.n - n#14919156
+0 ## Intoxicants - cannabis.n - n#2949691
+0 ## Intoxicants - tobacco.n - n#4442831
+0 ## Intoxicants - morphine.n - n#3786417
+0 ## Intoxicants - peyote.n - n#3750912
+0 ## Intoxicants - dope.n - n#3990834
+0 ## Intoxicants - speed.n - n#2704153
+0 ## Intoxicants - codeine.n - n#3062461
+0 ## Intoxicants - sedative.n - n#4166553
+0 ## Intoxicants - ecstasy.n - n#13986372
+0 ## Intoxicants - ketamine.n - n#3611590
+0 ## Intoxicants - crack.n - n#3125184
+0 ## Intoxicants - amphetamine.n - n#2704153
+0 ## Intoxicants - methamphetamine.n - n#3754295
+0 ## Intoxicants - weed.n - n#3990834
+0 ## Intoxicants - snuff.n - n#4252939
+0 ## Intoxicants - hashish.n - n#3497182
+0 ## Intoxicants - cocaine.n - n#3060294
+0 ## Intoxicants - opium.n - n#3850966
+0 ## Intoxicants - drug.n - n#3247620
+0 ## Intoxicants - coke.n - n#3066743
+0 ## Intoxicants - marijuana.n - n#2949691
+0 ## Intoxicants - barbiturate.n - n#2792049
+0 ## Intoxicants - nicotine.n - n#14714817
+0 ## Intoxicants - hallucinogen.n - n#3479647
+0 ## Intoxicants - mescaline.n - n#3750912
+0 ## Intoxicants - upper.n - n#2704153
+0 ## Intoxicants - alcohol.n - n#7884567
+0 ## Intoxicants - LSD.n - n#3699396
+0 ## Intoxicants - acid.n - n#14607521
+0 ## Intoxicants - grass.n - n#3990834
+0 ## Execute_plan - force_((into_force)).n - n#5194578
+0 ## Execute_plan - institute.v - v#1647229
+0 ## Execute_plan - implement.v - v#2408965
+0 ## Execute_plan - effect_((into_effect)).n - n#11410625
+0 ## Execute_plan - implementation.n - n#44150
+0 ## Scouring - sweep.v - v#2685390
+0 ## Scouring - rifle.v - v#2344568
+0 ## Scouring - sift.v - v#1460594
+0 ## Scouring - scour.v - v#1317276
+0 ## Scouring - ransack.v - v#1319193
+0 ## Scouring - comb.v - v#1319193
+0 ## Scouring - rummage.v - v#1319049
+0 ## Scouring - sweep.n - n#5127959
+0 ## Cause_harm - boil.v - v#375021
+0 ## Cause_harm - pummel.v - v#1416020
+0 ## Cause_harm - poison.v - v#88339
+0 ## Cause_harm - impale.v - v#1444326
+0 ## Cause_harm - hurt.v - v#1793177
+0 ## Cause_harm - beat up.v - v#1397210
+0 ## Cause_harm - electrocution.n - n#228078
+0 ## Cause_harm - break.v - v#334186
+0 ## Cause_harm - beat.v - v#1397210
+0 ## Cause_harm - knife.v - v#1231652
+0 ## Cause_harm - bash.v - v#1397088
+0 ## Cause_harm - hammer.v - v#1416539
+0 ## Cause_harm - electrocute.v - v#2485135
+0 ## Cause_harm - strike.v - v#1410223
+0 ## Cause_harm - cudgel.v - v#1424106
+0 ## Cause_harm - biff.v - v#1416020
+0 ## Cause_harm - lash.v - v#1411085
+0 ## Cause_harm - smash.v - v#335923
+0 ## Cause_harm - cane.v - v#1412204
+0 ## Cause_harm - torture.v - v#71178
+0 ## Cause_harm - burn.v - v#2120451
+0 ## Cause_harm - poisoning.n - n#14509712
+0 ## Cause_harm - gash.v - v#1322509
+0 ## Cause_harm - swipe.v - v#1394200
+0 ## Cause_harm - chop.v - v#1124535
+0 ## Cause_harm - stone.v - v#1323518
+0 ## Cause_harm - squash.v - v#1593937
+0 ## Cause_harm - butt.v - v#1235769
+0 ## Cause_harm - clout.v - v#1412759
+0 ## Cause_harm - belt.v - v#1415162
+0 ## Cause_harm - kick.v - v#1370561
+0 ## Cause_harm - bruise.v - v#1793177
+0 ## Cause_harm - bludgeon.v - v#1423929
+0 ## Cause_harm - spear.v - v#1444887
+0 ## Cause_harm - cut.v - v#1552519
+0 ## Cause_harm - claw.v - v#1306654
+0 ## Cause_harm - injure.v - v#69879
+0 ## Cause_harm - sting.v - v#1793742
+0 ## Cause_harm - wound.v - v#69879
+0 ## Cause_harm - slap.v - v#1416871
+0 ## Cause_harm - flog.v - v#1411085
+0 ## Cause_harm - crack.v - v#336260
+0 ## Cause_harm - maul.v - v#1232098
+0 ## Cause_harm - club.v - v#1423929
+0 ## Cause_harm - pelt.v - v#1507914
+0 ## Cause_harm - cuff.v - v#1417162
+0 ## Cause_harm - bayonet.v - v#1231980
+0 ## Cause_harm - hit.v - v#1400044
+0 ## Cause_harm - crush.v - v#1101913
+0 ## Cause_harm - buffet.v - v#1417578
+0 ## Cause_harm - thwack.v - v#1414916
+0 ## Cause_harm - mutilate.v - v#90708
+0 ## Cause_harm - whip.v - v#1411085
+0 ## Cause_harm - smack.v - v#1414916
+0 ## Cause_harm - welt.v - v#1411085
+0 ## Cause_harm - maim.v - v#90888
+0 ## Cause_harm - transfix.v - v#1444326
+0 ## Cause_harm - fracture.v - v#107739
+0 ## Cause_harm - slice.v - v#1124389
+0 ## Cause_harm - flagellate.v - v#1398443
+0 ## Cause_harm - stab.v - v#1231652
+0 ## Cause_harm - batter.v - v#1417705
+0 ## Cause_harm - jab.v - v#1229976
+0 ## Cause_harm - knock.v - v#1239619
+0 ## Cause_harm - horsewhip.v - v#1398772
+0 ## Cause_harm - elbow.v - v#1873942
+0 ## Cause_harm - punch.v - v#1415285
+0 ## Weapon - firearm.n - n#3343853
+0 ## Weapon - gat.n - n#3427202
+0 ## Weapon - BW.n - n#967780
+0 ## Weapon - WMD.n - n#4565963
+0 ## Weapon - revolver.n - n#4086273
+0 ## Weapon - garrotte.n - n#3420935
+0 ## Weapon - shooter.n - n#10593115
+0 ## Weapon - biological weapon.n - n#2842303
+0 ## Weapon - dynamite.n - n#3260293
+0 ## Weapon - handgun.n - n#3948459
+0 ## Weapon - gun.n - n#3467984
+0 ## Weapon - six-shooter.n - n#4086273
+0 ## Weapon - plastic explosive.n - n#3958448
+0 ## Weapon - nuclear weapon.n - n#3834604
+0 ## Weapon - nerve gas.n - n#14960721
+0 ## Weapon - cannon.n - n#2950256
+0 ## Weapon - chemical weapon.n - n#3013162
+0 ## Weapon - twenty-two.n - n#4502851
+0 ## Weapon - rifle.n - n#4090263
+0 ## Weapon - chemical.a - a#2692624
+0 ## Weapon - biological.a - a#1405904
+0 ## Weapon - shell.n - n#4190464
+0 ## Weapon - mustard gas.n - n#14957270
+0 ## Weapon - arsenal.n - n#2743207
+0 ## Weapon - club.n - n#3053474
+0 ## Weapon - ordnance.n - n#2746365
+0 ## Weapon - weapon.n - n#4565375
+0 ## Weapon - ballistic missile.n - n#2781338
+0 ## Weapon - icbm.n - n#3578251
+0 ## Weapon - crossbow.n - n#3136369
+0 ## Weapon - explosive.n - n#3304730
+0 ## Weapon - warhead.n - n#4551375
+0 ## Weapon - mine.n - n#3768132
+0 ## Weapon - pistol.n - n#3948459
+0 ## Weapon - weaponry.n - n#4566257
+0 ## Weapon - atomic weapon.n - n#3834604
+0 ## Weapon - shotgun.n - n#4206356
+0 ## Weapon - bomb.n - n#2866578
+0 ## Weapon - knife.n - n#3623556
+0 ## Weapon - grenade.n - n#3458271
+0 ## Weapon - arms.n - n#4566257
+0 ## Weapon - missile.n - n#3773504
+0 ## Weapon - nuclear.a - a#610532
+0 ## Weapon - artillery.n - n#2746365
+0 ## Weapon - spear.n - n#4270891
+0 ## Weapon - bow.n - n#2879718
+0 ## Weapon - atomic bomb.n - n#2753044
+0 ## Weapon - weapon of mass destruction.n - n#4565963
+0 ## Weapon - explosive.a - a#474620
+0 ## Weapon - sword.n - n#4373894
+0 ## Weapon - strategic.a - a#2950711
+0 ## Cause_change - variation.n - n#7337390
+0 ## Cause_change - conversion.n - n#7355194
+0 ## Cause_change - transformation.n - n#7359599
+0 ## Cause_change - convert.v - v#381013
+0 ## Cause_change - vary.v - v#123170
+0 ## Cause_change - change.v - v#126264
+0 ## Cause_change - alter.v - v#126264
+0 ## Cause_change - modification.n - n#7296428
+0 ## Cause_change - transform.v - v#544011
+0 ## Cause_change - modify.v - v#126264
+0 ## Cause_change - make.v - v#120316
+0 ## Cause_change - reshape.v - v#1660870
+0 ## Cause_change - turn.v - v#1907258
+0 ## Cause_change - alteration.n - n#7296428
+0 ## Gathering_up - amass.v - v#158804
+0 ## Gathering_up - collect.v - v#2304982
+0 ## Gathering_up - herd.v - v#2028722
+0 ## Gathering_up - convene.v - v#2024508
+0 ## Gathering_up - assemble.v - v#2428924
+0 ## Gathering_up - gather.v - v#2428924
+0 ## People - man.n - n#10287213
+0 ## People - gentleman.n - n#10127273
+0 ## People - woman.n - n#10787470
+0 ## People - lady.n - n#10243137
+0 ## People - fellow.n - n#9908025
+0 ## People - individual.n - n#7846
+0 ## People - human_being.n - n#2472293
+0 ## People - girl.n - n#10129825
+0 ## People - guy.n - n#10153414
+0 ## People - chap.n - n#9908025
+0 ## People - dude.n - n#10083358
+0 ## People - folks.n - n#7947255
+0 ## People - human.n - n#2472293
+0 ## People - people.n - n#7942152
+0 ## People - person.n - n#7846
+0 ## Word_relations - contrary.n - n#13858604
+0 ## Word_relations - homonym.n - n#6292649
+0 ## Word_relations - antonym.n - n#6288024
+0 ## Word_relations - hyponym.n - n#6292973
+0 ## Word_relations - collocate.v - v#2612610
+0 ## Word_relations - synonymous.a - a#2381302
+0 ## Word_relations - meronym.n - n#6293746
+0 ## Word_relations - holonym.n - n#6292478
+0 ## Word_relations - homograph.n - n#7131022
+0 ## Word_relations - synonym.n - n#6303682
+0 ## Word_relations - homophonous.a - a#2993853
+0 ## Word_relations - hypernym.n - n#6292836
+0 ## Word_relations - homophone.n - n#7131169
+0 ## Intoxication - intoxicated.a - a#797299
+0 ## Intoxication - sober.a - a#799517
+0 ## Intoxication - high.a - a#799224
+0 ## Intoxication - wasted.a - a#2503305
+0 ## Intoxication - stoned.a - a#799401
+0 ## Intoxication - pissed.a - a#798103
+0 ## Intoxication - inebriated.a - a#797299
+0 ## Intoxication - drunk.a - a#797299
+0 ## Intoxication - blasted.a - a#669942
+0 ## Intoxication - sloshed.a - a#798103
+0 ## Intoxication - tipsy.a - a#798384
+0 ## Intoxication - blotto.a - a#798103
+0 ## Intoxication - trip.n - n#14378311
+0 ## Out_of_existence - toast.n - n#7686873
+0 ## Out_of_existence - history.n - n#15121406
+0 ## Out_of_existence - gone.a - a#1728919
+0 ## Quitting_a_place - vamoose.v - v#2010698
+0 ## Quitting_a_place - desert.v - v#614057
+0 ## Quitting_a_place - emigrant.n - n#10051975
+0 ## Quitting_a_place - retreat.v - v#1994442
+0 ## Quitting_a_place - skedaddle.v - v#2075764
+0 ## Quitting_a_place - emigrate.v - v#416135
+0 ## Quitting_a_place - emigre.n - n#10051975
+0 ## Quitting_a_place - bolt.v - v#2073714
+0 ## Quitting_a_place - split.v - v#2467662
+0 ## Quitting_a_place - vacate.v - v#2367032
+0 ## Quitting_a_place - withdrawal.n - n#53913
+0 ## Quitting_a_place - escapee.n - n#10062905
+0 ## Quitting_a_place - defection.n - n#55315
+0 ## Quitting_a_place - quit.v - v#2382367
+0 ## Quitting_a_place - emigration.n - n#56087
+0 ## Quitting_a_place - desertion.n - n#55315
+0 ## Quitting_a_place - withdraw.v - v#1994442
+0 ## Quitting_a_place - retreat.n - n#56912
+0 ## Quitting_a_place - abandon.v - v#2076676
+0 ## Quitting_a_place - defect.v - v#2584097
+0 ## Assistance - help.n - n#1207609
+0 ## Assistance - assistance.n - n#1207609
+0 ## Assistance - succor.v - v#2548710
+0 ## Assistance - help.v - v#2547586
+0 ## Assistance - help out.v - v#2548422
+0 ## Assistance - serve.v - v#2540670
+0 ## Assistance - abet.v - v#2549211
+0 ## Assistance - helpful.a - a#1195536
+0 ## Assistance - aid.v - v#2547586
+0 ## Assistance - aid_((entity)).n - n#1207609
+0 ## Assistance - aid_((act)).n - n#1207609
+0 ## Assistance - cater.v - v#1182709
+0 ## Assistance - assist.v - v#2547586
+0 ## Reforming_a_system - overhaul.n - n#265119
+0 ## Reforming_a_system - overhaul.v - v#262076
+0 ## Reforming_a_system - reform.n - n#260622
+0 ## Reforming_a_system - restructure.v - v#404401
+0 ## Reforming_a_system - reform.v - v#265386
+0 ## Ineffability - je ne sais quoi.n - n#3595179
+0 ## Ineffability - ineffable.a - a#944111
+0 ## Ineffability - magic.a - a#1576071
+0 ## Ineffability - magical.a - a#1576071
+0 ## Ineffability - magic.n - n#5967977
+0 ## Dying - dying.a - a#3939
+0 ## Dying - moribund.a - a#4171
+0 ## Perception_active - gawk.v - v#2164531
+0 ## Perception_active - goggle.v - v#2164531
+0 ## Perception_active - look.n - n#877127
+0 ## Perception_active - stare.v - v#2132745
+0 ## Perception_active - attend.v - v#2612762
+0 ## Perception_active - eye.v - v#2167052
+0 ## Perception_active - gaze.n - n#878648
+0 ## Perception_active - eavesdrop.v - v#2189714
+0 ## Perception_active - sniff.n - n#883139
+0 ## Perception_active - stare.n - n#878456
+0 ## Perception_active - admire.v - v#2164694
+0 ## Perception_active - look.v - v#2130524
+0 ## Perception_active - listen.v - v#2169891
+0 ## Perception_active - gape.v - v#2164531
+0 ## Perception_active - squint.v - v#8799
+0 ## Perception_active - savour.v - v#2194286
+0 ## Perception_active - sniff.v - v#2125032
+0 ## Perception_active - observe.v - v#2154508
+0 ## Perception_active - spy.v - v#2163746
+0 ## Perception_active - smell.v - v#2124748
+0 ## Perception_active - watch.v - v#2150510
+0 ## Perception_active - peek.n - n#878221
+0 ## Perception_active - gaze.v - v#2132745
+0 ## Perception_active - peep.v - v#2165146
+0 ## Perception_active - taste.n - n#5715283
+0 ## Perception_active - view.v - v#2150948
+0 ## Perception_active - palpate.v - v#1210352
+0 ## Perception_active - peer.v - v#2168965
+0 ## Perception_active - feel.v - v#1771535
+0 ## Perception_active - peek.v - v#2165304
+0 ## Perception_active - taste.v - v#2194286
+0 ## Perception_active - glance.n - n#877625
+0 ## Perception_active - glance.v - v#2165304
+0 ## Perception_active - observation.n - n#879759
+0 ## Amalgamation - merger.n - n#1238424
+0 ## Amalgamation - unite.v - v#243124
+0 ## Amalgamation - combine.v - v#394813
+0 ## Amalgamation - commingle.v - v#394813
+0 ## Amalgamation - meld.v - v#395841
+0 ## Amalgamation - unify.v - v#1462005
+0 ## Amalgamation - intermix.v - v#1462468
+0 ## Amalgamation - merge.v - v#394813
+0 ## Amalgamation - blend.v - v#394813
+0 ## Amalgamation - band_together.v - v#2470685
+0 ## Amalgamation - fuse.v - v#394813
+0 ## Amalgamation - amalgamate.v - v#1462005
+0 ## Hiding_objects - conceal.v - v#2144835
+0 ## Hiding_objects - shroud.v - v#1582200
+0 ## Hiding_objects - camouflage.v - v#2158896
+0 ## Hiding_objects - mask.v - v#2158587
+0 ## Hiding_objects - hide.v - v#2144835
+0 ## Verification - make sure.v - v#2595234
+0 ## Verification - certify.v - v#820976
+0 ## Verification - confirm.v - v#665886
+0 ## Verification - confirmation.n - n#6650070
+0 ## Verification - verify.v - v#664483
+0 ## Verification - substantiate.v - v#665886
+0 ## Verification - verifiable.a - a#1615785
+0 ## Verification - identify.v - v#618878
+0 ## Verification - verification.n - n#5825245
+0 ## Employing - employer.n - n#10054657
+0 ## Employing - employee.n - n#10053808
+0 ## Employing - commission.v - v#2480803
+0 ## Employing - employment.n - n#13968092
+0 ## Employing - worker.n - n#9632518
+0 ## Employing - personnel.n - n#8208016
+0 ## Employing - staff.n - n#8439955
+0 ## Employing - employ.v - v#1158872
+0 ## Feigning - pretend.v - v#838043
+0 ## Feigning - simulate.v - v#1721754
+0 ## Feigning - counterfeit.v - v#1654271
+0 ## Feigning - stage.v - v#1711445
+0 ## Feigning - fake.v - v#839526
+0 ## Feigning - affect.v - v#838043
+0 ## Feigning - feign.v - v#838043
+0 ## Activity_stop - halt.v - v#1859586
+0 ## Activity_stop - cease.v - v#2680814
+0 ## Activity_stop - terminate.v - v#352826
+0 ## Activity_stop - stop.v - v#2680814
+0 ## Activity_stop - quit.v - v#2680814
+0 ## Activity_stop - abandon.v - v#2227741
+0 ## Activity_stop - discontinue.v - v#2680814
+0 ## Weather - stormy.a - a#303727
+0 ## Weather - thunderstorm.n - n#11519253
+0 ## Weather - rainstorm.n - n#11501737
+0 ## Weather - hailstorm.n - n#11465688
+0 ## Weather - climate.n - n#14519366
+0 ## Weather - blizzard.n - n#11509570
+0 ## Weather - storm.v - v#2723016
+0 ## Weather - snowy.a - a#1698231
+0 ## Weather - weather.n - n#11524662
+0 ## Weather - snowstorm.n - n#11509570
+0 ## Weather - sunshine.n - n#11485367
+0 ## Weather - storm.n - n#11462526
+0 ## Weather - fair.a - a#956131
+0 ## Contacting - call in.v - v#790135
+0 ## Contacting - call.n - n#6272803
+0 ## Contacting - contact.v - v#743344
+0 ## Contacting - cable.v - v#1007222
+0 ## Contacting - page.v - v#754560
+0 ## Contacting - ring.v - v#789448
+0 ## Contacting - ring up.v - v#1000058
+0 ## Contacting - e-mail.v - v#1032451
+0 ## Contacting - call up.v - v#789448
+0 ## Contacting - reach.v - v#2020590
+0 ## Contacting - get in touch.v - v#2389346
+0 ## Contacting - fax.v - v#1007676
+0 ## Contacting - contact.n - n#14419510
+0 ## Contacting - write.v - v#1698271
+0 ## Contacting - phone.v - v#789448
+0 ## Contacting - radio.v - v#1007495
+0 ## Contacting - mail.v - v#1437888
+0 ## Contacting - call.v - v#1062739
+0 ## Contacting - telephone.v - v#789448
+0 ## Contacting - telegraph.v - v#1007222
+0 ## Contacting - telex.v - v#790965
+0 ## Perception_experience - detect.v - v#2154508
+0 ## Perception_experience - perceive.v - v#2106506
+0 ## Perception_experience - hear.v - v#2169702
+0 ## Perception_experience - witness.v - v#2128873
+0 ## Perception_experience - feel.v - v#1771535
+0 ## Perception_experience - sense.v - v#589469
+0 ## Perception_experience - see.v - v#2129289
+0 ## Perception_experience - taste.v - v#2191546
+0 ## Perception_experience - smell.v - v#2124748
+0 ## Perception_experience - overhear.v - v#2189168
+0 ## Perception_experience - perception.n - n#876874
+0 ## Perception_experience - experience.n - n#7285403
+0 ## Surpassing - pale.v - v#103619
+0 ## Surpassing - exceed.v - v#1105639
+0 ## Surpassing - outstrip.v - v#1105639
+0 ## Surpassing - better.v - v#1106864
+0 ## Surpassing - surpass.v - v#1105639
+0 ## Surpassing - eclipse.v - v#2744280
+0 ## Surpassing - outshine.v - v#1107254
+0 ## Surpassing - outdo.v - v#1105639
+0 ## Location_of_light - glisten.v - v#2162947
+0 ## Location_of_light - flash.n - n#7412092
+0 ## Location_of_light - lambency.n - n#4954534
+0 ## Location_of_light - sparkle.v - v#2766390
+0 ## Location_of_light - glittering.a - a#279618
+0 ## Location_of_light - gleaming.a - a#279092
+0 ## Location_of_light - gleam.v - v#2162947
+0 ## Location_of_light - coruscation.n - n#7412668
+0 ## Location_of_light - glitter.n - n#4952944
+0 ## Location_of_light - refulgence.n - n#4953954
+0 ## Location_of_light - lambent.a - a#279332
+0 ## Location_of_light - scintillation.n - n#4952944
+0 ## Location_of_light - flash.v - v#2159890
+0 ## Location_of_light - brilliant.a - a#281173
+0 ## Location_of_light - coruscate.v - v#2766390
+0 ## Location_of_light - sheen.n - n#4954683
+0 ## Location_of_light - bright.a - a#278551
+0 ## Location_of_light - gleam.n - n#4954534
+0 ## Location_of_light - glossy.a - a#281657
+0 ## Location_of_light - twinkle.n - n#4953380
+0 ## Location_of_light - glow.n - n#4954534
+0 ## Location_of_light - glow.v - v#2161530
+0 ## Location_of_light - twinkle.v - v#2159890
+0 ## Location_of_light - flare.v - v#2762981
+0 ## Location_of_light - shine.v - v#2763740
+0 ## Location_of_light - shimmer.v - v#2706478
+0 ## Location_of_light - refulgent.a - a#280463
+0 ## Location_of_light - glimmer.v - v#2160779
+0 ## Location_of_light - shining.a - a#281657
+0 ## Location_of_light - shine.n - n#4953954
+0 ## Location_of_light - glistening.a - a#281657
+0 ## Location_of_light - shiny.a - a#281657
+0 ## Location_of_light - glister.n - n#4952944
+0 ## Location_of_light - scintillate.v - v#2764765
+0 ## Location_of_light - light.n - n#11473954
+0 ## Location_of_light - glint.n - n#7412310
+0 ## Location_of_light - glint.v - v#2162947
+0 ## Location_of_light - flame.v - v#2762981
+0 ## Location_of_light - glimmer.n - n#7412478
+0 ## Location_of_light - lustre.n - n#4954683
+0 ## Location_of_light - flicker.v - v#2160177
+0 ## Location_of_light - glitter.v - v#2162947
+0 ## Location_of_light - flicker.n - n#7412310
+0 ## Exporting - export_((entity)).n - n#3306207
+0 ## Exporting - export.v - v#2346409
+0 ## Exporting - exportation.n - n#3306207
+0 ## Exporting - export_((act)).n - n#3306207
+0 ## Popularity - in.a - a#2332204
+0 ## Popularity - popular.a - a#716370
+0 ## Popularity - cool.a - a#2529945
+0 ## Distinctiveness - aspect.n - n#5850624
+0 ## Distinctiveness - characterize.v - v#956687
+0 ## Distinctiveness - characteristic.n - n#4731497
+0 ## Distinctiveness - characteristic.a - a#356926
+0 ## Distinctiveness - signature.n - n#7029088
+0 ## Distinctiveness - trademark.n - n#4732543
+0 ## Distinctiveness - distinct.a - a#2067063
+0 ## Distinctiveness - distinctive.a - a#357556
+0 ## Forging - forgery_((entity)).n - n#3562262
+0 ## Forging - counterfeit.v - v#1654271
+0 ## Forging - fake.n - n#3318438
+0 ## Forging - forge.v - v#1654271
+0 ## Forging - forgery_((act)).n - n#3562262
+0 ## Forging - fake.v - v#1654271
+0 ## Forging - falsify.v - v#2576921
+0 ## Institutions - institutional.a - a#2749778
+0 ## Institutions - institution.n - n#8053576
+0 ## Self_motion - hurry.v - v#2055649
+0 ## Self_motion - straggle.v - v#2066304
+0 ## Self_motion - stagger.v - v#1924882
+0 ## Self_motion - swim.v - v#1960911
+0 ## Self_motion - wander.v - v#2102840
+0 ## Self_motion - wade.v - v#1916214
+0 ## Self_motion - trudge.v - v#1921204
+0 ## Self_motion - stroll.n - n#284101
+0 ## Self_motion - mince.v - v#1929927
+0 ## Self_motion - slouch.v - v#1929824
+0 ## Self_motion - skip.v - v#1966861
+0 ## Self_motion - cruise.v - v#1844653
+0 ## Self_motion - dart.v - v#2061495
+0 ## Self_motion - edge.v - v#2072501
+0 ## Self_motion - hike.n - n#288970
+0 ## Self_motion - back.v - v#1997119
+0 ## Self_motion - file.v - v#1920048
+0 ## Self_motion - trek.v - v#1847220
+0 ## Self_motion - bound.v - v#1963942
+0 ## Self_motion - sail.v - v#1945516
+0 ## Self_motion - spring.v - v#1963942
+0 ## Self_motion - stride.v - v#1919711
+0 ## Self_motion - bustle.v - v#2058191
+0 ## Self_motion - repair.v - v#1843497
+0 ## Self_motion - slog.v - v#1921204
+0 ## Self_motion - stroll.v - v#1917980
+0 ## Self_motion - lurch.v - v#1924882
+0 ## Self_motion - slosh.v - v#1921591
+0 ## Self_motion - scurry.v - v#1902405
+0 ## Self_motion - way.n - n#4928903
+0 ## Self_motion - swagger.v - v#1916634
+0 ## Self_motion - limp.v - v#1917244
+0 ## Self_motion - tiptoe.v - v#1924023
+0 ## Self_motion - slither.v - v#1886488
+0 ## Self_motion - step.v - v#2091410
+0 ## Self_motion - drive.v - v#1930117
+0 ## Self_motion - flit.v - v#1899891
+0 ## Self_motion - sidle.v - v#1869196
+0 ## Self_motion - hike.v - v#1920932
+0 ## Self_motion - tread.v - v#2091410
+0 ## Self_motion - dash.v - v#2061495
+0 ## Self_motion - shuffle.v - v#1917549
+0 ## Self_motion - waddle.v - v#1918803
+0 ## Self_motion - slip.v - v#1888295
+0 ## Self_motion - roam.v - v#1881180
+0 ## Self_motion - strut.v - v#1916634
+0 ## Self_motion - creep.v - v#1885845
+0 ## Self_motion - prance.v - v#1916634
+0 ## Self_motion - slink.v - v#1917123
+0 ## Self_motion - march.n - n#290579
+0 ## Self_motion - hop.v - v#1966861
+0 ## Self_motion - coast.v - v#1886728
+0 ## Self_motion - walk.n - n#284798
+0 ## Self_motion - meander.v - v#1882814
+0 ## Self_motion - hobble.v - v#1917244
+0 ## Self_motion - caper.v - v#1967104
+0 ## Self_motion - trip.v - v#1843055
+0 ## Self_motion - leap.v - v#1963942
+0 ## Self_motion - frolic.v - v#1883716
+0 ## Self_motion - steal.v - v#2321757
+0 ## Self_motion - burrow.v - v#2042067
+0 ## Self_motion - gallivant.v - v#1882689
+0 ## Self_motion - romp.v - v#1883716
+0 ## Self_motion - clamber.v - v#1921772
+0 ## Self_motion - scoot.v - v#2061495
+0 ## Self_motion - crawl.n - n#294868
+0 ## Self_motion - saunter.v - v#1917980
+0 ## Self_motion - scramble.v - v#1921772
+0 ## Self_motion - taxi.v - v#1948872
+0 ## Self_motion - stumble.v - v#1900408
+0 ## Self_motion - clomp.v - v#1930033
+0 ## Self_motion - rip.v - v#2098041
+0 ## Self_motion - make.v - v#2560585
+0 ## Self_motion - vault.v - v#1966168
+0 ## Self_motion - rove.v - v#1881180
+0 ## Self_motion - bop.v - v#1895263
+0 ## Self_motion - pounce.v - v#2064358
+0 ## Self_motion - parade.v - v#1924505
+0 ## Self_motion - march.v - v#1996735
+0 ## Self_motion - swing.v - v#1877620
+0 ## Self_motion - skim.v - v#1515924
+0 ## Self_motion - dash.n - n#555983
+0 ## Self_motion - walk.v - v#1904930
+0 ## Self_motion - waltz.v - v#1895612
+0 ## Self_motion - lunge.v - v#2062212
+0 ## Self_motion - totter.v - v#1918803
+0 ## Self_motion - dance.v - v#1708676
+0 ## Self_motion - tack.v - v#1946408
+0 ## Self_motion - sprint.v - v#1928579
+0 ## Self_motion - slop.v - v#1921591
+0 ## Self_motion - trundle.v - v#1868139
+0 ## Self_motion - step.n - n#285557
+0 ## Self_motion - skulk.v - v#1918521
+0 ## Self_motion - hasten.v - v#2058994
+0 ## Self_motion - amble.v - v#1918183
+0 ## Self_motion - mosey.v - v#1918183
+0 ## Self_motion - head.v - v#1935233
+0 ## Self_motion - hitchhike.v - v#1956955
+0 ## Self_motion - traipse.v - v#1910873
+0 ## Self_motion - shoulder.v - v#1238907
+0 ## Self_motion - storm.v - v#2723016
+0 ## Self_motion - tramp.v - v#1921204
+0 ## Self_motion - proceed.v - v#1995549
+0 ## Self_motion - gambol.v - v#1883716
+0 ## Self_motion - scuttle.v - v#1902405
+0 ## Self_motion - climb.v - v#1923909
+0 ## Self_motion - lope.v - v#1928730
+0 ## Self_motion - sneak.v - v#1911888
+0 ## Self_motion - promenade.v - v#1924505
+0 ## Self_motion - stalk.v - v#1924148
+0 ## Self_motion - crawl.v - v#1885845
+0 ## Self_motion - slalom.v - v#1939037
+0 ## Self_motion - pace.v - v#2091165
+0 ## Self_motion - scramble.n - n#556142
+0 ## Self_motion - jump.v - v#1963942
+0 ## Self_motion - plod.v - v#1921204
+0 ## Self_motion - toddle.v - v#1918803
+0 ## Self_motion - rush.v - v#2058994
+0 ## Self_motion - wriggle.v - v#1868370
+0 ## Self_motion - lumber.v - v#1925548
+0 ## Self_motion - barge.v - v#1996574
+0 ## Self_motion - swim.n - n#442115
+0 ## Self_motion - prowl.v - v#1918304
+0 ## Self_motion - advance.v - v#1992503
+0 ## Self_motion - venture.v - v#2373336
+0 ## Self_motion - scamper.v - v#1902405
+0 ## Self_motion - stomp.v - v#1925338
+0 ## Self_motion - troop.v - v#1924505
+0 ## Self_motion - shuffle.n - n#340463
+0 ## Self_motion - jog.v - v#1901447
+0 ## Self_motion - run.v - v#1926311
+0 ## Self_motion - fly.v - v#1940403
+0 ## Self_motion - trot.v - v#1901447
+0 ## Self_motion - canter.v - v#1959669
+0 ## Self_motion - pad.v - v#1921204
+0 ## Self_motion - sashay.v - v#1916634
+0 ## Self_motion - sleepwalk.v - v#1916960
+0 ## Self_motion - sprint.n - n#294452
+0 ## Self_motion - jaunt.n - n#311809
+0 ## Self_motion - flounce.v - v#1924405
+0 ## Regard - think.v - v#689344
+0 ## Regard - regard.v - v#690614
+0 ## Regard - appreciate.v - v#2256109
+0 ## Regard - esteem.n - n#14437552
+0 ## Regard - impression.n - n#5916739
+0 ## Regard - appreciative.a - a#1146732
+0 ## Regard - opinion.n - n#5916739
+0 ## Regard - regard.n - n#14437552
+0 ## Getting_vehicle_underway - launch.v - v#2427103
+0 ## Getting_vehicle_underway - pull_(out).v - v#1995211
+0 ## Getting_vehicle_underway - lift_(off).v - v#178652
+0 ## Getting_vehicle_underway - weigh anchor.v - v#1456199
+0 ## Getting_vehicle_underway - cast off.v - v#1513430
+0 ## Getting_vehicle_underway - take_(off).v - v#173338
+0 ## People_by_vocation - scholar.n - n#10557854
+0 ## People_by_vocation - soldier.n - n#10622053
+0 ## People_by_vocation - engineer.n - n#9615807
+0 ## People_by_vocation - carpenter.n - n#9896685
+0 ## People_by_vocation - lawyer.n - n#10249950
+0 ## People_by_vocation - toxicologist.n - n#10719807
+0 ## People_by_vocation - trader.n - n#10720453
+0 ## People_by_vocation - police_officer.n - n#10448983
+0 ## People_by_vocation - clerk.n - n#9928451
+0 ## People_by_vocation - manager.n - n#10014939
+0 ## People_by_vocation - receptionist.n - n#10511069
+0 ## People_by_vocation - double agent.n - n#10027476
+0 ## People_by_vocation - scientist.n - n#10560637
+0 ## People_by_vocation - officer.n - n#10317007
+0 ## People_by_vocation - mechanic.n - n#9825750
+0 ## People_by_vocation - professional.a - a#1868724
+0 ## People_by_vocation - architect.n - n#9805475
+0 ## People_by_vocation - speculator.n - n#10634316
+0 ## People_by_vocation - researcher.n - n#10523076
+0 ## People_by_vocation - oilman.n - n#10374652
+0 ## People_by_vocation - salesman.n - n#10548537
+0 ## People_by_vocation - judge.n - n#10225219
+0 ## People_by_vocation - guerrilla.n - n#10150556
+0 ## People_by_vocation - waitress.n - n#10763620
+0 ## People_by_vocation - reporter.n - n#10521662
+0 ## People_by_vocation - journalist.n - n#10224578
+0 ## People_by_vocation - private eye.n - n#10476671
+0 ## People_by_vocation - businessperson.n - n#9882007
+0 ## People_by_vocation - spy.n - n#10641755
+0 ## People_by_vocation - mole.n - n#9970192
+0 ## People_by_vocation - technician.n - n#10696251
+0 ## People_by_vocation - veterinarian.n - n#10749715
+0 ## People_by_vocation - archaeologist.n - n#9804806
+0 ## People_by_vocation - politician.n - n#10450303
+0 ## People_by_vocation - maid.n - n#10282672
+0 ## People_by_vocation - farmer.n - n#10078806
+0 ## People_by_vocation - agent.n - n#9777353
+0 ## People_by_vocation - attendant.n - n#9608002
+0 ## People_by_vocation - consultant.n - n#9774266
+0 ## People_by_vocation - magistrate.n - n#10280945
+0 ## People_by_vocation - servant.n - n#10582154
+0 ## People_by_vocation - professor.n - n#10480730
+0 ## People_by_vocation - waiter.n - n#10763383
+0 ## People_by_vocation - gardener.n - n#10120671
+0 ## People_by_vocation - actress.n - n#9767700
+0 ## Disgraceful_situation - shameful.a - a#1227546
+0 ## Disgraceful_situation - disgraceful.a - a#1549964
+0 ## Success_or_failure - failing.n - n#66901
+0 ## Success_or_failure - success.n - n#7319103
+0 ## Success_or_failure - succeed.v - v#2524171
+0 ## Success_or_failure - unsuccessful.a - a#2333453
+0 ## Success_or_failure - manage.v - v#2522864
+0 ## Success_or_failure - pull off.v - v#2522864
+0 ## Success_or_failure - successful.a - a#2331262
+0 ## Success_or_failure - miss.v - v#2613672
+0 ## Success_or_failure - fail.v - v#2529284
+0 ## Success_or_failure - failure.n - n#66636
+0 ## Clemency - clemency.n - n#1071411
+0 ## Attributed_information - source.n - n#10205985
+0 ## Attributed_information - viewpoint.n - n#6210363
+0 ## Facial_expression - sneer.n - n#6716483
+0 ## Facial_expression - frown.n - n#6877849
+0 ## Facial_expression - pout.n - n#6877742
+0 ## Facial_expression - face.n - n#5600637
+0 ## Facial_expression - smile.n - n#6878071
+0 ## Facial_expression - expression.n - n#4679738
+0 ## Facial_expression - rictus.n - n#6877509
+0 ## Facial_expression - smirk.n - n#6878580
+0 ## Facial_expression - look.n - n#4679738
+0 ## Facial_expression - scowl.n - n#6877849
+0 ## Facial_expression - snarl.n - n#7129758
+0 ## Facial_expression - grin.n - n#6878071
+0 ## Facial_expression - grimace.n - n#6877578
+0 ## Execution - execution.n - n#1163779
+0 ## Execution - put to death.v - v#2483267
+0 ## Execution - hangman.n - n#10159615
+0 ## Execution - headsman.n - n#10164997
+0 ## Execution - executioner.n - n#10069427
+0 ## Execution - firing squad.n - n#8424769
+0 ## Execution - execute.v - v#1640855
+0 ## Execution - guillotine.v - v#1571538
+0 ## Execution - hanging.n - n#1164874
+0 ## Execution - hang.v - v#2485451
+0 ## Holding_off_on - wait.v - v#2637938
+0 ## Holding_off_on - hold off.v - v#2641463
+0 ## Rape - rape.n - n#773402
+0 ## Rape - rape.v - v#2567519
+0 ## Rape - raped.a - a#735709
+0 ## Rape - rapist.n - n#10507230
+0 ## Duplication - reduplicate.v - v#1734502
+0 ## Duplication - replica.n - n#4076533
+0 ## Duplication - copy.n - n#3104594
+0 ## Duplication - clone.n - n#3626925
+0 ## Duplication - duplicate.v - v#1734502
+0 ## Duplication - reproduce.v - v#1736822
+0 ## Duplication - photocopy.n - n#3924811
+0 ## Duplication - duplication.n - n#3257343
+0 ## Duplication - run off.v - v#1736299
+0 ## Duplication - replicate.v - v#1734502
+0 ## Duplication - copy.v - v#1734929
+0 ## Duplication - duplicate.n - n#3257343
+0 ## Duplication - photocopy.v - v#1736299
+0 ## Being_rotted - decayed.a - a#2275892
+0 ## Being_rotted - rotted.a - a#2275892
+0 ## Being_rotted - putrid.a - a#2786315
+0 ## Being_rotted - rancid.a - a#1070321
+0 ## Being_rotted - rotten.a - a#2275892
+0 ## Being_rotted - mouldy.a - a#1070088
+0 ## Hiring - sign on.v - v#2409941
+0 ## Hiring - take on.v - v#524682
+0 ## Hiring - contract.v - v#888786
+0 ## Hiring - hire.n - n#809074
+0 ## Hiring - retain.v - v#2701628
+0 ## Hiring - subcontract.v - v#2461063
+0 ## Hiring - hire.v - v#2409412
+0 ## Hiring - sign up.v - v#2409941
+0 ## Hiring - commission.n - n#1140471
+0 ## Hiring - commission.v - v#2480803
+0 ## Hiring - sign.v - v#2409941
+0 ## People_by_residence - housemate.n - n#10188957
+0 ## People_by_residence - neighbor.n - n#10352299
+0 ## People_by_residence - roommate.n - n#10538518
+0 ## Cause_to_make_progress - develop.v - v#171852
+0 ## Cause_to_make_progress - modernization.n - n#264913
+0 ## Cause_to_make_progress - improved.a - a#1290174
+0 ## Cause_to_make_progress - perfect.v - v#473572
+0 ## Cause_to_make_progress - improve.v - v#205885
+0 ## Cause_to_make_progress - mature.v - v#250181
+0 ## Cause_to_make_progress - development.n - n#250259
+0 ## Openness - open.a - a#1652902
+0 ## Openness - closed.a - a#1653538
+0 ## Adjusting - calibration.n - n#999245
+0 ## Adjusting - adjustment.n - n#999787
+0 ## Adjusting - tweak.v - v#302763
+0 ## Adjusting - tweak.n - n#357275
+0 ## Adjusting - adjust.v - v#296178
+0 ## Adjusting - calibrate.v - v#295697
+0 ## Just_found_out - shocked.a - a#78576
+0 ## Just_found_out - surprise.n - n#7298154
+0 ## Just_found_out - shock.n - n#7298982
+0 ## Just_found_out - surprised.a - a#2357479
+0 ## Operating_a_system - operate.v - v#2443849
+0 ## Operating_a_system - run.v - v#1926311
+0 ## Operating_a_system - manage.v - v#2522864
+0 ## Be_subset_of - subset.n - n#8001209
+0 ## Be_subset_of - number.v - v#2731632
+0 ## Be_subset_of - count.v - v#2731632
+0 ## Examination - assessment.n - n#5733583
+0 ## Examination - examination.n - n#7197021
+0 ## Examination - examine.v - v#786816
+0 ## Examination - test.n - n#7197021
+0 ## Examination - test.v - v#2531625
+0 ## Examination - exam.n - n#7197021
+0 ## Fields - artistic.a - a#2991122
+0 ## Fields - literature.n - n#6364641
+0 ## Fields - theater.n - n#7006119
+0 ## Fields - art.n - n#933420
+0 ## Fields - industry.n - n#8065234
+0 ## Fields - industrial.a - a#2748635
+0 ## Fields - literary.a - a#1045518
+0 ## Fields - field.n - n#5996646
+0 ## Fields - sector.n - n#7966719
+0 ## Fields - mathematics.n - n#6000644
+0 ## Fields - area.n - n#8497294
+0 ## Fields - history.n - n#15121406
+0 ## Predicting - forecast.v - v#926472
+0 ## Predicting - vaticinate.v - v#926702
+0 ## Predicting - prophecy.n - n#5775407
+0 ## Predicting - foretell.v - v#917772
+0 ## Predicting - prognosticate.v - v#917772
+0 ## Predicting - prophesy.v - v#926702
+0 ## Predicting - claim.v - v#756338
+0 ## Predicting - prediction.n - n#5775081
+0 ## Predicting - predict.v - v#917772
+0 ## Natural_features - isle.n - n#9319456
+0 ## Natural_features - gully.n - n#9300306
+0 ## Natural_features - seamount.n - n#9427752
+0 ## Natural_features - continental.a - a#1566916
+0 ## Natural_features - wash.n - n#9474895
+0 ## Natural_features - knoll.n - n#9326662
+0 ## Natural_features - spring.n - n#8508361
+0 ## Natural_features - ocean.n - n#9376198
+0 ## Natural_features - cove.n - n#9257843
+0 ## Natural_features - strait.n - n#9446115
+0 ## Natural_features - watershed.n - n#8679369
+0 ## Natural_features - pool.n - n#9397391
+0 ## Natural_features - tor.n - n#9459979
+0 ## Natural_features - crag.n - n#9259025
+0 ## Natural_features - land.n - n#9334396
+0 ## Natural_features - mount.n - n#9359803
+0 ## Natural_features - dell.n - n#9264599
+0 ## Natural_features - rugged.a - a#2243806
+0 ## Natural_features - range.n - n#9403734
+0 ## Natural_features - ravine.n - n#9405787
+0 ## Natural_features - cataract.n - n#9237918
+0 ## Natural_features - islet.n - n#9319456
+0 ## Natural_features - cascade.n - n#9236957
+0 ## Natural_features - hollow.n - n#9305031
+0 ## Natural_features - atoll.n - n#9210862
+0 ## Natural_features - gulch.n - n#9295946
+0 ## Natural_features - crater.n - n#9259219
+0 ## Natural_features - bayou.n - n#9217086
+0 ## Natural_features - mountain.n - n#9359803
+0 ## Natural_features - channel.n - n#9241247
+0 ## Natural_features - strand.n - n#9447666
+0 ## Natural_features - hill.n - n#9303008
+0 ## Natural_features - shoal.n - n#9433312
+0 ## Natural_features - moraine.n - n#9358907
+0 ## Natural_features - water.n - n#9225146
+0 ## Natural_features - beck.n - n#6877008
+0 ## Natural_features - key.n - n#9325395
+0 ## Natural_features - burn.n - n#14325437
+0 ## Natural_features - height.n - n#13940456
+0 ## Natural_features - falls.n - n#9475292
+0 ## Natural_features - creek.n - n#9229409
+0 ## Natural_features - dale.n - n#9262690
+0 ## Natural_features - hillock.n - n#9326662
+0 ## Natural_features - lagoon.n - n#9328746
+0 ## Natural_features - mesa.n - n#9351905
+0 ## Natural_features - massif.n - n#9348460
+0 ## Natural_features - cliff.n - n#9246464
+0 ## Natural_features - sound.n - n#9446115
+0 ## Natural_features - defile.n - n#9263912
+0 ## Natural_features - butte.n - n#9230202
+0 ## Natural_features - glen.n - n#9289596
+0 ## Natural_features - continent.n - n#9254614
+0 ## Natural_features - ridge.n - n#9409512
+0 ## Natural_features - cavern.n - n#9239302
+0 ## Natural_features - declivity.n - n#9265620
+0 ## Natural_features - pond.n - n#9397391
+0 ## Natural_features - loch.n - n#9341987
+0 ## Natural_features - guyot.n - n#9300559
+0 ## Natural_features - berg.n - n#9308572
+0 ## Natural_features - coastal.a - a#462909
+0 ## Natural_features - glacier.n - n#9289331
+0 ## Natural_features - river.n - n#9411430
+0 ## Natural_features - sandbar.n - n#9421951
+0 ## Natural_features - reef.n - n#9406793
+0 ## Natural_features - tarn.n - n#9454642
+0 ## Natural_features - volcano.n - n#9470550
+0 ## Natural_features - cay.n - n#9325395
+0 ## Natural_features - beach.n - n#9217230
+0 ## Natural_features - crevasse.n - n#9259677
+0 ## Natural_features - vale.n - n#9468604
+0 ## Natural_features - hummock.n - n#9326662
+0 ## Natural_features - pass.n - n#9386842
+0 ## Natural_features - inlet.n - n#9313716
+0 ## Natural_features - canyon.n - n#9233446
+0 ## Natural_features - archipelago.n - n#9203827
+0 ## Natural_features - depression.n - n#9366017
+0 ## Natural_features - sandbank.n - n#9421799
+0 ## Natural_features - iceberg.n - n#9308572
+0 ## Natural_features - dune.n - n#9270735
+0 ## Natural_features - floe.n - n#9309168
+0 ## Natural_features - waterfall.n - n#9475292
+0 ## Natural_features - dingle.n - n#9264599
+0 ## Natural_features - plateau.n - n#9453008
+0 ## Natural_features - shelf.n - n#9337253
+0 ## Natural_features - cave.n - n#9238926
+0 ## Natural_features - outcrop.n - n#9381242
+0 ## Natural_features - slough.n - n#9438212
+0 ## Natural_features - bay.n - n#9215664
+0 ## Natural_features - stream.n - n#9448361
+0 ## Natural_features - gap.n - n#9249034
+0 ## Natural_features - peak.n - n#8617963
+0 ## Natural_features - island.n - n#9316454
+0 ## Natural_features - fjord.n - n#9281104
+0 ## Natural_features - sea.n - n#9426788
+0 ## Natural_features - fell.n - n#14759275
+0 ## Natural_features - peninsula.n - n#9388848
+0 ## Natural_features - corrie.n - n#9245515
+0 ## Natural_features - brook.n - n#9229409
+0 ## Natural_features - rill.n - n#9415938
+0 ## Natural_features - valley.n - n#9468604
+0 ## Natural_features - gulf.n - n#9296121
+0 ## Natural_features - bar.n - n#9214060
+0 ## Natural_features - cirque.n - n#9245515
+0 ## Natural_features - isthmus.n - n#9319604
+0 ## Natural_features - lake.n - n#9328904
+0 ## Natural_features - headland.n - n#9399592
+0 ## Wearing - bareheaded.a - a#458664
+0 ## Wearing - hatted.a - a#1428581
+0 ## Wearing - nakedness.n - n#14456138
+0 ## Wearing - barelegged.a - a#458810
+0 ## Wearing - dolled up.a - a#455824
+0 ## Wearing - masked.a - a#1707230
+0 ## Wearing - gloveless.a - a#1428509
+0 ## Wearing - barefooted.a - a#2156686
+0 ## Wearing - unshod.a - a#2156579
+0 ## Wearing - wear.v - v#52374
+0 ## Wearing - shoeless.a - a#2156686
+0 ## Wearing - bare.v - v#1340028
+0 ## Wearing - unclothed.a - a#457598
+0 ## Wearing - nudity.n - n#14456138
+0 ## Wearing - sport.v - v#2631659
+0 ## Wearing - clothed.a - a#453726
+0 ## Wearing - have on.v - v#52374
+0 ## Wearing - attired.a - a#454440
+0 ## Wearing - bare-breasted.a - a#458488
+0 ## Wearing - costumed.a - a#455485
+0 ## Wearing - dressed.a - a#454440
+0 ## Wearing - braless.a - a#458488
+0 ## Wearing - unclad.a - a#460157
+0 ## Wearing - clad.a - a#453726
+0 ## Wearing - undressed.a - a#460157
+0 ## Wearing - barefoot.a - a#2156686
+0 ## Wearing - nude.a - a#457998
+0 ## Wearing - topless.a - a#458488
+0 ## Wearing - robed.a - a#454440
+0 ## Wearing - naked.a - a#457998
+0 ## Wearing - garbed.a - a#454440
+0 ## Wearing - undress.n - n#14456752
+0 ## Wearing - hatless.a - a#1428838
+0 ## Wearing - bare.a - a#457998
+0 ## Wearing - gloved.a - a#1428282
+0 ## Cause_temperature_change - reheat.v - v#544280
+0 ## Cause_temperature_change - warm.v - v#372958
+0 ## Cause_temperature_change - refrigerate.v - v#371955
+0 ## Cause_temperature_change - warm up.v - v#2444397
+0 ## Cause_temperature_change - heat.v - v#371264
+0 ## Cause_temperature_change - overheat.v - v#370263
+0 ## Cause_temperature_change - heat up.v - v#371264
+0 ## Cause_temperature_change - cool down.v - v#370412
+0 ## Cause_temperature_change - chill.v - v#370412
+0 ## Cause_temperature_change - cool.v - v#370412
+0 ## Conquering - conquer.v - v#2272549
+0 ## Conquering - take.v - v#2267989
+0 ## Conquering - fall.v - v#1972298
+0 ## Conquering - capture.v - v#2272549
+0 ## Intentionally_create - synthesise.v - v#644066
+0 ## Intentionally_create - produce.v - v#1621555
+0 ## Intentionally_create - generate.v - v#1629000
+0 ## Intentionally_create - creation.n - n#908492
+0 ## Intentionally_create - synthesis.n - n#13565379
+0 ## Intentionally_create - create.v - v#1617192
+0 ## Intentionally_create - found.v - v#2427103
+0 ## Intentionally_create - establishment.n - n#13476267
+0 ## Intentionally_create - set up.v - v#2427103
+0 ## Intentionally_create - production.n - n#4007894
+0 ## Intentionally_create - make.v - v#2560585
+0 ## Intentionally_create - generation.n - n#849982
+0 ## Intentionally_create - establish.v - v#665476
+0 ## Judgment - reprehensible.a - a#2035765
+0 ## Judgment - applaud.v - v#861929
+0 ## Judgment - reproachful.a - a#996864
+0 ## Judgment - scorn.v - v#796976
+0 ## Judgment - appreciative.a - a#1146732
+0 ## Judgment - disapproval.n - n#874621
+0 ## Judgment - appreciation.n - n#1218593
+0 ## Judgment - reverence.n - n#7521039
+0 ## Judgment - critical.a - a#647542
+0 ## Judgment - mock.v - v#849080
+0 ## Judgment - stigma.n - n#6794666
+0 ## Judgment - derisive.a - a#1995596
+0 ## Judgment - disrespect.n - n#6714976
+0 ## Judgment - accuse.v - v#843468
+0 ## Judgment - respect.n - n#6206800
+0 ## Judgment - blame.n - n#6713752
+0 ## Judgment - contemptuous.a - a#1995288
+0 ## Judgment - scorn.n - n#7502980
+0 ## Judgment - disapprove.v - v#674340
+0 ## Judgment - fault.n - n#9278537
+0 ## Judgment - respect.v - v#694068
+0 ## Judgment - contempt.n - n#7502980
+0 ## Judgment - disdainful.a - a#1995288
+0 ## Judgment - mockery.n - n#6716234
+0 ## Judgment - approving.a - a#996089
+0 ## Judgment - esteem.v - v#694068
+0 ## Judgment - approbation.n - n#7500612
+0 ## Judgment - deplore.v - v#826333
+0 ## Judgment - blame.v - v#842538
+0 ## Judgment - disdain.v - v#796976
+0 ## Judgment - accolade.n - n#6696483
+0 ## Judgment - disdain.n - n#7502980
+0 ## Judgment - disapproving.a - a#997298
+0 ## Judgment - fault.v - v#842538
+0 ## Judgment - reproach.n - n#6713512
+0 ## Judgment - vilification.n - n#6715223
+0 ## Judgment - admire.v - v#1827858
+0 ## Judgment - boo.v - v#862225
+0 ## Judgment - scornful.a - a#1995288
+0 ## Judgment - uncritical.a - a#650351
+0 ## Judgment - admiration.n - n#1218593
+0 ## Judgment - exaltation.n - n#13986372
+0 ## Judgment - appreciate.v - v#2256109
+0 ## Judgment - exalt.v - v#544936
+0 ## Judgment - damnation.n - n#14458593
+0 ## Judgment - stigmatize.v - v#2508245
+0 ## Judgment - stricture.n - n#14107374
+0 ## Judgment - revere.v - v#1778568
+0 ## Judgment - esteem.n - n#6206800
+0 ## Judgment - prize.v - v#694068
+0 ## Judgment - value.v - v#694068
+0 ## Judgment - deify.v - v#545140
+0 ## Feeling - feel.v - v#1771535
+0 ## Feeling - emotion.n - n#7480068
+0 ## Feeling - experience.v - v#2110220
+0 ## Feeling - feelings.n - n#7513035
+0 ## Feeling - full.a - a#1083157
+0 ## Rope_manipulation - tie.v - v#141632
+0 ## Rope_manipulation - braid.v - v#1519569
+0 ## Rope_manipulation - tangle.v - v#1462928
+0 ## Rope_manipulation - knot.v - v#1300144
+0 ## Prominence - flashy.a - a#2393791
+0 ## Prominence - salient.a - a#580805
+0 ## Prominence - quiet.a - a#1922763
+0 ## Prominence - eye-catching.a - a#579498
+0 ## Prominence - blatant.a - a#2090567
+0 ## Prominence - conspicuous.a - a#579084
+0 ## Prominence - prominent.a - a#580805
+0 ## Translating - translation.n - n#13568983
+0 ## Translating - translate.v - v#959827
+0 ## Coming_to_be - develop.v - v#2624263
+0 ## Coming_to_be - appear.v - v#2133435
+0 ## Coming_to_be - coalesce.v - v#394813
+0 ## Coming_to_be - take shape.v - v#2623906
+0 ## Coming_to_be - emerge.v - v#2625016
+0 ## Coming_to_be - arise.v - v#2624263
+0 ## Coming_to_be - form.v - v#2623906
+0 ## Coming_to_be - materialize.v - v#344174
+0 ## Coming_to_be - evolve.v - v#1738597
+0 ## Coming_to_be - spring up.v - v#2624263
+0 ## Possibility - can.v - v#213794
+0 ## Change_position_on_a_scale - fluctuation.n - n#7346057
+0 ## Change_position_on_a_scale - tumble.n - n#76884
+0 ## Change_position_on_a_scale - balloon.v - v#1948659
+0 ## Change_position_on_a_scale - mushroom.v - v#231445
+0 ## Change_position_on_a_scale - increase.n - n#5108947
+0 ## Change_position_on_a_scale - increasingly.adv - r#59854
+0 ## Change_position_on_a_scale - decrease.v - v#151689
+0 ## Change_position_on_a_scale - swing.v - v#1877620
+0 ## Change_position_on_a_scale - grow.v - v#230746
+0 ## Change_position_on_a_scale - soar.v - v#155406
+0 ## Change_position_on_a_scale - increase.v - v#156601
+0 ## Change_position_on_a_scale - shift.n - n#7359599
+0 ## Change_position_on_a_scale - edge.v - v#2072501
+0 ## Change_position_on_a_scale - move.v - v#1835496
+0 ## Change_position_on_a_scale - dwindle.v - v#267681
+0 ## Change_position_on_a_scale - gain.v - v#158222
+0 ## Change_position_on_a_scale - advance.v - v#158222
+0 ## Change_position_on_a_scale - triple.v - v#246746
+0 ## Change_position_on_a_scale - tumble.v - v#2047857
+0 ## Change_position_on_a_scale - hike.n - n#5110408
+0 ## Change_position_on_a_scale - jump.v - v#155727
+0 ## Change_position_on_a_scale - shift.v - v#1883344
+0 ## Change_position_on_a_scale - skyrocket.v - v#1944086
+0 ## Change_position_on_a_scale - rise.n - n#324384
+0 ## Change_position_on_a_scale - rocket.v - v#1944086
+0 ## Change_position_on_a_scale - fluctuate.v - v#1876907
+0 ## Change_position_on_a_scale - gain.n - n#13754293
+0 ## Change_position_on_a_scale - fall.v - v#1970826
+0 ## Change_position_on_a_scale - explode.v - v#157623
+0 ## Change_position_on_a_scale - escalation.n - n#366846
+0 ## Change_position_on_a_scale - double.v - v#246217
+0 ## Change_position_on_a_scale - plummet.v - v#1978199
+0 ## Change_position_on_a_scale - growing.a - a#3070879
+0 ## Change_position_on_a_scale - decline.n - n#13457378
+0 ## Change_position_on_a_scale - decrease.n - n#5109808
+0 ## Change_position_on_a_scale - fall.n - n#5111835
+0 ## Change_position_on_a_scale - swell.v - v#2626405
+0 ## Change_position_on_a_scale - drop.v - v#1976841
+0 ## Change_position_on_a_scale - rise.v - v#1968569
+0 ## Change_position_on_a_scale - dip.v - v#2039679
+0 ## Change_position_on_a_scale - diminish.v - v#151689
+0 ## Change_position_on_a_scale - slide.v - v#1886488
+0 ## Change_position_on_a_scale - climb.v - v#433232
+0 ## Change_position_on_a_scale - reach.v - v#2020590
+0 ## Change_position_on_a_scale - explosion.n - n#572706
+0 ## Change_position_on_a_scale - growth.n - n#13489037
+0 ## Change_position_on_a_scale - decline.v - v#431826
+0 ## Invading - overrun.v - v#2020413
+0 ## Invading - invader.n - n#10214062
+0 ## Invading - invasion.n - n#976531
+0 ## Invading - invade.v - v#1126360
+0 ## Rank - rank.n - n#14429985
+0 ## Rank - degree.n - n#5093890
+0 ## Rank - level.n - n#5093890
+0 ## Bringing - transport.n - n#315986
+0 ## Bringing - haul.v - v#1452255
+0 ## Bringing - schlep.v - v#1453718
+0 ## Bringing - bike.v - v#1935476
+0 ## Bringing - fly.v - v#1451842
+0 ## Bringing - bear.v - v#1432601
+0 ## Bringing - row.v - v#1946996
+0 ## Bringing - lug.v - v#1454246
+0 ## Bringing - transport.v - v#1449974
+0 ## Bringing - shuttle.v - v#2062081
+0 ## Bringing - bus.v - v#1950128
+0 ## Bringing - truck.v - v#1954341
+0 ## Bringing - paddle.v - v#1947887
+0 ## Bringing - portable.a - a#1525776
+0 ## Bringing - tote.v - v#1454246
+0 ## Bringing - ferry.v - v#1949674
+0 ## Bringing - mobile.a - a#1522376
+0 ## Bringing - trundle.v - v#1868139
+0 ## Bringing - bring.v - v#2077656
+0 ## Bringing - drive.v - v#1930874
+0 ## Bringing - hump.v - v#1426397
+0 ## Bringing - wheel.v - v#2046441
+0 ## Bringing - get.v - v#2210855
+0 ## Bringing - fetch.v - v#1433294
+0 ## Bringing - jet.v - v#1942234
+0 ## Bringing - carry.v - v#1449974
+0 ## Bringing - take.v - v#2077656
+0 ## Bringing - convey.v - v#2077656
+0 ## Bringing - motor.v - v#1930117
+0 ## Bringing - cart.v - v#1451502
+0 ## Becoming_a_member - enter.v - v#2471327
+0 ## Becoming_a_member - join.v - v#2434976
+0 ## Becoming_a_member - enlist.v - v#1097500
+0 ## Becoming_a_member - sign up.v - v#1097309
+0 ## Becoming_a_member - enroll.v - v#2471327
+0 ## Categorization - construe.v - v#623151
+0 ## Categorization - identify.v - v#691944
+0 ## Categorization - categorize.v - v#657260
+0 ## Categorization - typecast.v - v#618682
+0 ## Categorization - classify.v - v#654625
+0 ## Categorization - pigeonhole.v - v#656292
+0 ## Categorization - consider.v - v#690614
+0 ## Categorization - regard.v - v#690614
+0 ## Categorization - view.v - v#690614
+0 ## Categorization - peg.v - v#2524897
+0 ## Categorization - class.v - v#654625
+0 ## Categorization - render.v - v#959827
+0 ## Categorization - conceive.v - v#689344
+0 ## Categorization - see.v - v#2129289
+0 ## Categorization - understand.v - v#588888
+0 ## Categorization - count.v - v#2731632
+0 ## Categorization - interpret.v - v#623151
+0 ## Categorization - read.v - v#625119
+0 ## Categorization - categorization.n - n#1012712
+0 ## Categorization - deem.v - v#693780
+0 ## Categorization - translate.v - v#593852
+0 ## Categorization - perceive.v - v#591519
+0 ## Categorization - classification.n - n#1012712
+0 ## Categorization - interpretation.n - n#7170753
+0 ## Categorization - stereotype.v - v#656292
+0 ## Categorization - define.v - v#2698319
+0 ## Categorization - bracket.v - v#656916
+0 ## Organization - organization.n - n#8008335
+0 ## Organization - league.n - n#8305114
+0 ## Organization - intelligence.n - n#8339454
+0 ## Organization - agency.n - n#8337324
+0 ## Organization - union.n - n#8304895
+0 ## Organization - government.n - n#8050678
+0 ## Organization - committee.n - n#8324514
+0 ## Organization - brotherhood.n - n#8233056
+0 ## Organization - association.n - n#8049401
+0 ## Organization - delegation.n - n#8402442
+0 ## Organization - club.n - n#8227214
+0 ## Organization - cartel.n - n#8236621
+0 ## Organization - group.n - n#31264
+0 ## Manufacturing - fabricate.v - v#1653442
+0 ## Manufacturing - producer.n - n#10292316
+0 ## Manufacturing - manufacture.n - n#924825
+0 ## Manufacturing - produce.v - v#1752495
+0 ## Manufacturing - maker.n - n#10284064
+0 ## Manufacturing - manufacturing.n - n#924825
+0 ## Manufacturing - production.n - n#912960
+0 ## Manufacturing - make.v - v#2560585
+0 ## Manufacturing - manufacture.v - v#1653442
+0 ## Manufacturing - fabrication.n - n#924825
+0 ## Manufacturing - manufacturer.n - n#10292316
+0 ## Manufacturing - industrial.a - a#2748635
+0 ## Extreme_value - low.n - n#5097706
+0 ## Extreme_value - minimum.a - a#1496021
+0 ## Extreme_value - maximum.a - a#1495725
+0 ## Extreme_value - minimum.n - n#13763384
+0 ## Extreme_value - acme.n - n#13940456
+0 ## Extreme_value - high.n - n#5097536
+0 ## Extreme_value - maximum.n - n#13776137
+0 ## Releasing - let go.v - v#1474550
+0 ## Releasing - set free.v - v#2497062
+0 ## Releasing - release.n - n#13549672
+0 ## Releasing - release.v - v#2421374
+0 ## Elusive_goal - escape.v - v#2074677
+0 ## Elusive_goal - evade.v - v#2074377
+0 ## Elusive_goal - elude.v - v#2074377
+0 ## Activity_start - commence.v - v#345761
+0 ## Activity_start - initiate.v - v#1628449
+0 ## Activity_start - neophyte.n - n#10355449
+0 ## Activity_start - take_up.v - v#2379528
+0 ## Activity_start - enter.v - v#348252
+0 ## Activity_start - beginner.n - n#10363913
+0 ## Activity_start - begin.v - v#345761
+0 ## Activity_start - start.v - v#345761
+0 ## Activity_start - swing_(into).v - v#1152040
+0 ## Activity_start - launch_(into).v - v#347918
+0 ## Hair_configuration - hairstyle.n - n#5256862
+0 ## Hair_configuration - golden.a - a#369941
+0 ## Hair_configuration - hairdo.n - n#5256862
+0 ## Hair_configuration - plait.n - n#5259512
+0 ## Hair_configuration - cut.n - n#5750948
+0 ## Hair_configuration - cut.a - a#2454750
+0 ## Hair_configuration - tress.n - n#5259512
+0 ## Hair_configuration - hair.n - n#5254795
+0 ## Hair_configuration - pigtail.n - n#5259914
+0 ## Hair_configuration - lock.n - n#5257737
+0 ## Hair_configuration - wave.n - n#5259240
+0 ## Hair_configuration - curly.a - a#1030022
+0 ## Hair_configuration - braid.n - n#5259512
+0 ## Hair_configuration - cropped.a - a#1831679
+0 ## Hair_configuration - blonde.a - a#243606
+0 ## Hair_configuration - wavy.a - a#1030691
+0 ## Hair_configuration - topknot.n - n#1326198
+0 ## Hair_configuration - ponytail.n - n#5260380
+0 ## Hair_configuration - curl.v - v#1223616
+0 ## Hair_configuration - blond.a - a#243606
+0 ## Hair_configuration - flaxen.a - a#244199
+0 ## Hair_configuration - curl.n - n#5257737
+0 ## Hair_configuration - braided.a - a#2579760
+0 ## Hair_configuration - haircut.n - n#5257593
+0 ## Scarcity - scarce.a - a#16756
+0 ## Scarcity - scarcity.n - n#5116953
+0 ## Scarcity - scarceness.n - n#5116953
+0 ## Scarcity - plentifulness.n - n#5115568
+0 ## Scarcity - plentiful.a - a#15854
+0 ## Conduct - misbehavior.n - n#735936
+0 ## Conduct - misbehave.v - v#2517202
+0 ## Conduct - maturity.n - n#15152817
+0 ## Conduct - act up.v - v#2517655
+0 ## Conduct - act.v - v#10435
+0 ## Conduct - manner.n - n#4910135
+0 ## Conduct - conduct.n - n#4897762
+0 ## Conduct - behave.v - v#10435
+0 ## Conduct - comportment.n - n#4910377
+0 ## Conduct - bearing.n - n#4910377
+0 ## Conduct - deportment.n - n#4897762
+0 ## Conduct - conduct.v - v#2518161
+0 ## Conduct - demeanor.n - n#4897762
+0 ## Conduct - behavior.n - n#4897762
+0 ## Importing - import.v - v#2346136
+0 ## Importing - import_((act)).n - n#3564667
+0 ## Importing - importation.n - n#3564667
+0 ## Importing - import_((entity)).n - n#3564667
+0 ## Opinion - suppose.v - v#631737
+0 ## Opinion - belief.n - n#5941423
+0 ## Opinion - expect.v - v#719734
+0 ## Opinion - take.n - n#13260190
+0 ## Opinion - view.n - n#6782019
+0 ## Opinion - hunch.n - n#5919034
+0 ## Opinion - hold.v - v#1733477
+0 ## Opinion - feel.v - v#1771535
+0 ## Opinion - opinion.n - n#6782019
+0 ## Opinion - believe.v - v#689344
+0 ## Opinion - think.v - v#689344
+0 ## Opinion - figure.v - v#712135
+0 ## Unemployment_rate - employment.n - n#13968092
+0 ## Unemployment_rate - unemployment.n - n#13968308
+0 ## Being_necessary - required.a - a#1580775
+0 ## Being_necessary - requirement.n - n#9367203
+0 ## Being_necessary - indispensable.a - a#1580306
+0 ## Being_necessary - necessity.n - n#9367203
+0 ## Being_necessary - necessary.a - a#1580050
+0 ## Being_necessary - needed.a - a#1580775
+0 ## Being_necessary - essential.a - a#1580306
+0 ## Being_necessary - basic.a - a#1855764
+0 ## Relational_political_locales - capital.n - n#8518505
+0 ## Relational_political_locales - see.n - n#8586825
+0 ## Relational_political_locales - county seat.n - n#8547143
+0 ## Dodging - dodge.v - v#809654
+0 ## Dodging - sidestep.v - v#809654
+0 ## Dodging - sidestep.n - n#286360
+0 ## Dodging - dodge.n - n#5905802
+0 ## Change_of_leadership - revolt.n - n#962129
+0 ## Change_of_leadership - install.v - v#2384041
+0 ## Change_of_leadership - insurrection.n - n#962129
+0 ## Change_of_leadership - overthrow.n - n#215683
+0 ## Change_of_leadership - appoint.v - v#2475922
+0 ## Change_of_leadership - take over.v - v#2274482
+0 ## Change_of_leadership - enthrone.v - v#2386388
+0 ## Change_of_leadership - revolution.n - n#962722
+0 ## Change_of_leadership - revolutionary.n - n#10527334
+0 ## Change_of_leadership - uprising.n - n#962129
+0 ## Change_of_leadership - rebellion.n - n#962129
+0 ## Change_of_leadership - oust.v - v#2401809
+0 ## Change_of_leadership - topple.v - v#1976488
+0 ## Change_of_leadership - coronate.v - v#2390949
+0 ## Change_of_leadership - independence.n - n#13994148
+0 ## Change_of_leadership - crown.v - v#2390949
+0 ## Change_of_leadership - throne.v - v#2391193
+0 ## Change_of_leadership - elect.v - v#2400760
+0 ## Change_of_leadership - depose.v - v#2405252
+0 ## Change_of_leadership - overthrow.v - v#2402409
+0 ## Change_of_leadership - revolt.v - v#2583780
+0 ## Change_of_leadership - mutiny.v - v#2583958
+0 ## Change_of_leadership - dethrone.v - v#2391453
+0 ## Change_of_leadership - vest.v - v#2386388
+0 ## Change_of_leadership - election.n - n#181781
+0 ## Change_of_leadership - coup.n - n#1145015
+0 ## Change_of_leadership - mutiny.n - n#963896
+0 ## Ingestion - gobble.v - v#1173933
+0 ## Ingestion - ingest.v - v#1156834
+0 ## Ingestion - guzzle.v - v#1170824
+0 ## Ingestion - swig.v - v#1202068
+0 ## Ingestion - have.v - v#2203362
+0 ## Ingestion - consume.v - v#1156834
+0 ## Ingestion - drink.v - v#1170052
+0 ## Ingestion - quaff.v - v#1202068
+0 ## Ingestion - feast.v - v#1185981
+0 ## Ingestion - munch.v - v#1201693
+0 ## Ingestion - gulp.v - v#1202068
+0 ## Ingestion - slurp.v - v#1169328
+0 ## Ingestion - lap.v - v#1170983
+0 ## Ingestion - imbibe.v - v#1170052
+0 ## Ingestion - swig.n - n#840189
+0 ## Ingestion - feed.v - v#1178565
+0 ## Ingestion - snack.v - v#1173405
+0 ## Ingestion - tuck.v - v#1389776
+0 ## Ingestion - nurse.v - v#1186428
+0 ## Ingestion - gulp.n - n#840189
+0 ## Ingestion - lunch.v - v#1185304
+0 ## Ingestion - devour.v - v#1197014
+0 ## Ingestion - sip.n - n#843494
+0 ## Ingestion - nibble.v - v#1174294
+0 ## Ingestion - sup.v - v#1205459
+0 ## Ingestion - nosh.v - v#1173405
+0 ## Ingestion - put away.v - v#1173208
+0 ## Ingestion - dine.v - v#1167981
+0 ## Ingestion - eat.v - v#1168468
+0 ## Ingestion - swill.v - v#1169433
+0 ## Ingestion - breakfast.v - v#1185740
+0 ## Ingestion - put back.v - v#1308381
+0 ## Ingestion - sip.v - v#1170687
+0 ## Ingestion - down.v - v#1197014
+0 ## Social_event_collective - date.n - n#8385009
+0 ## Idiosyncrasy - certain.a - a#700884
+0 ## Idiosyncrasy - idiosyncratic.a - a#493820
+0 ## Idiosyncrasy - unique.a - a#505853
+0 ## Idiosyncrasy - peculiarity.n - n#4763925
+0 ## Idiosyncrasy - idiosyncrasy.n - n#4764242
+0 ## Idiosyncrasy - peculiar.a - a#1104026
+0 ## Idiosyncrasy - weird.a - a#1575424
+0 ## Idiosyncrasy - particular.a - a#1104026
+0 ## Idiosyncrasy - oddity.n - n#3149951
+0 ## Idiosyncrasy - uncanny.a - a#1575424
+0 ## Cure - remedy.v - v#82563
+0 ## Cure - treat.v - v#78760
+0 ## Cure - rehabilitate.v - v#2552163
+0 ## Cure - rehabilitative.a - a#1903412
+0 ## Cure - cure.n - n#4074482
+0 ## Cure - cure.v - v#81725
+0 ## Cure - alleviation.n - n#354884
+0 ## Cure - curable.a - a#994410
+0 ## Cure - ease.v - v#82308
+0 ## Cure - alleviate.v - v#64095
+0 ## Cure - incurable.a - a#994567
+0 ## Cure - rehabilitation.n - n#700260
+0 ## Cure - nurse.v - v#80705
+0 ## Cure - palliative.a - a#1341153
+0 ## Cure - therapy.n - n#661091
+0 ## Cure - remedy.n - n#4074482
+0 ## Cure - therapeutic.a - a#1165943
+0 ## Cure - curative.n - n#4074482
+0 ## Cure - heal.v - v#81725
+0 ## Cure - therapist.n - n#10707233
+0 ## Cure - palliative.n - n#3879854
+0 ## Cure - palliation.n - n#355547
+0 ## Cure - treatment.n - n#658082
+0 ## Cure - resuscitate.v - v#98083
+0 ## Cure - healer.n - n#10707233
+0 ## Cure - palliate.v - v#64095
+0 ## Cure - curative.a - a#1165943
+0 ## Certainty - confident.a - a#337172
+0 ## Certainty - uncertainty.n - n#5698247
+0 ## Certainty - positive.a - a#337172
+0 ## Certainty - unsure.a - a#337404
+0 ## Certainty - doubtful.a - a#338013
+0 ## Certainty - skepticism.n - n#5698982
+0 ## Certainty - doubt.n - n#5698247
+0 ## Certainty - trust.v - v#688377
+0 ## Certainty - skeptic.n - n#10604634
+0 ## Certainty - know.v - v#594621
+0 ## Certainty - dubious.a - a#338013
+0 ## Certainty - convinced.a - a#337172
+0 ## Certainty - skeptical.a - a#2463847
+0 ## Certainty - believe.v - v#683280
+0 ## Certainty - doubt.v - v#687523
+0 ## Certainty - certain.a - a#336831
+0 ## Certainty - confidence.n - n#5697363
+0 ## Certainty - uncertain.a - a#337404
+0 ## Certainty - sure.a - a#336831
+0 ## Certainty - certainty.n - n#5697135
+0 ## People_by_origin - Irish.n - n#9732778
+0 ## People_by_origin - American_(N_and_S_Am).n - n#9738708
+0 ## People_by_origin - german.n - n#9747722
+0 ## People_by_origin - Greek.n - n#9710164
+0 ## People_by_origin - foreigner.n - n#10103485
+0 ## People_by_origin - Frenchwoman.n - n#9708405
+0 ## People_by_origin - Kraut.n - n#9748239
+0 ## People_by_origin - Brit.n - n#9700964
+0 ## People_by_origin - Iranian.n - n#9714429
+0 ## People_by_origin - Turk.n - n#9734885
+0 ## People_by_origin - Dubliner.n - n#9715427
+0 ## People_by_origin - Mexican.n - n#9722658
+0 ## People_by_origin - ottoman.n - n#9735113
+0 ## People_by_origin - Californian.n - n#9741612
+0 ## People_by_origin - Persian.n - n#6974127
+0 ## People_by_origin - Frenchman.n - n#9708405
+0 ## People_by_origin - American.n - n#9738708
+0 ## People_by_origin - English.n - n#6947032
+0 ## People_by_origin - italian.n - n#9716047
+0 ## People_by_origin - New Yorker.n - n#9744679
+0 ## Intercepting - interception.n - n#1078279
+0 ## Intercepting - intercept.v - v#1440378
+0 ## Cause_to_be_wet - hydrate.v - v#214020
+0 ## Cause_to_be_wet - drench.v - v#216216
+0 ## Cause_to_be_wet - dampen.v - v#217956
+0 ## Cause_to_be_wet - moisten.v - v#217956
+0 ## Cause_to_be_wet - douse.v - v#216216
+0 ## Cause_to_be_wet - wet.v - v#214951
+0 ## Cause_to_be_wet - soak.v - v#216216
+0 ## Cause_to_be_wet - sop.v - v#216216
+0 ## Cause_to_be_wet - saturate.v - v#497705
+0 ## Cause_to_be_wet - moisturize.v - v#215800
+0 ## Cause_to_be_wet - humidify.v - v#215800
+0 ## Cause_to_be_wet - souse.v - v#216216
+0 ## Waver_between_options - vacillate.v - v#2706046
+0 ## Waver_between_options - waffle.v - v#2640440
+0 ## Waver_between_options - dither.v - v#1820189
+0 ## Waver_between_options - flip-flop.v - v#121678
+0 ## Waver_between_options - waver.v - v#2640440
+0 ## Willingness - unwilling.a - a#2566015
+0 ## Willingness - willing.a - a#2564986
+0 ## Willingness - down.a - a#2491961
+0 ## Willingness - grudging.a - a#2566299
+0 ## Willingness - prepared.a - a#2565425
+0 ## Willingness - willingness.n - n#4644512
+0 ## Willingness - unwillingness.n - n#4645599
+0 ## Willingness - loath.a - a#2566453
+0 ## Willingness - reluctant.a - a#2566453
+0 ## Attention - attend.v - v#2612762
+0 ## Attention - attention.n - n#5702275
+0 ## Attention - alert.a - a#91311
+0 ## Attention - close.a - a#309945
+0 ## Attention - closely.adv - r#505226
+0 ## Attention - attentive.a - a#163592
+0 ## Stage_of_progress - generation.n - n#15290930
+0 ## Stage_of_progress - old-fashioned.a - a#974159
+0 ## Stage_of_progress - advanced.a - a#1208738
+0 ## Stage_of_progress - developed.a - a#741867
+0 ## Stage_of_progress - mature.a - a#742316
+0 ## Stage_of_progress - low-tech.a - a#1208919
+0 ## Stage_of_progress - high-tech.a - a#1208571
+0 ## Stage_of_progress - modern.a - a#1535709
+0 ## Stage_of_progress - cutting-edge.a - a#972642
+0 ## Stage_of_progress - state-of-the-art.a - a#1876780
+0 ## Stage_of_progress - sophisticated.a - a#1208738
+0 ## Sidereal_appearance - come up.v - v#1970348
+0 ## Sidereal_appearance - rise.v - v#2624263
+0 ## Sidereal_appearance - rise.n - n#324384
+0 ## Set_of_interrelated_entities - system.n - n#8435388
+0 ## Education_teaching - train.v - v#603298
+0 ## Education_teaching - learn.v - v#829107
+0 ## Education_teaching - master.v - v#597385
+0 ## Education_teaching - training.n - n#893955
+0 ## Education_teaching - cram.v - v#605783
+0 ## Education_teaching - graduate.n - n#9786338
+0 ## Education_teaching - tutor.n - n#9931418
+0 ## Education_teaching - tutor.v - v#830188
+0 ## Education_teaching - educational.a - a#2946221
+0 ## Education_teaching - lecturer.n - n#10252547
+0 ## Education_teaching - study.v - v#599992
+0 ## Education_teaching - instruction.n - n#883297
+0 ## Education_teaching - schoolteacher.n - n#10560352
+0 ## Education_teaching - educate.v - v#603298
+0 ## Education_teaching - school.v - v#2388403
+0 ## Education_teaching - teach.v - v#829107
+0 ## Education_teaching - education.n - n#883297
+0 ## Education_teaching - student.n - n#10557854
+0 ## Education_teaching - protege.n - n#10485989
+0 ## Education_teaching - schoolmaster.n - n#10164233
+0 ## Education_teaching - professor.n - n#10480730
+0 ## Education_teaching - tutee.n - n#10733820
+0 ## Education_teaching - coach.v - v#833702
+0 ## Education_teaching - instruct.v - v#829107
+0 ## Education_teaching - schoolmistress.n - n#10559840
+0 ## Education_teaching - teacher.n - n#10694258
+0 ## Education_teaching - pupil.n - n#10559288
+0 ## Instance - example.n - n#5820620
+0 ## Instance - specimen.n - n#5822239
+0 ## Instance - case.n - n#7308889
+0 ## Instance - instance.n - n#7308889
+0 ## Subordinates_and_superiors - superior.n - n#10752930
+0 ## Subordinates_and_superiors - subordinate.n - n#10669991
+0 ## Subordinates_and_superiors - underling.n - n#10669991
+0 ## Subordinates_and_superiors - stooge.n - n#10098092
+0 ## Subordinates_and_superiors - assistant.n - n#9815790
+0 ## Subordinates_and_superiors - lackey.n - n#10242573
+0 ## Subordinates_and_superiors - minion.n - n#10320612
+0 ## Subordinates_and_superiors - goon.n - n#10274639
+0 ## Subordinates_and_superiors - henchman.n - n#9953483
+0 ## Subordinates_and_superiors - junior.a - a#2100709
+0 ## Subordinates_and_superiors - master.n - n#10752930
+0 ## Subordinates_and_superiors - senior.a - a#2099774
+0 ## Subordinates_and_superiors - hireling.n - n#10176913
+0 ## Subordinates_and_superiors - servant.n - n#10582154
+0 ## Arson - arsonist.n - n#9810707
+0 ## Arson - arson.n - n#378296
+0 ## Waking_up - get up.v - v#96648
+0 ## Waking_up - revive.v - v#24047
+0 ## Waking_up - wake up.v - v#18526
+0 ## Waking_up - come to.v - v#24047
+0 ## Waking_up - awake.v - v#18526
+0 ## Waking_up - wake.v - v#18526
+0 ## Social_interaction_evaluation - uncivil.a - a#642725
+0 ## Social_interaction_evaluation - polite.a - a#641158
+0 ## Social_interaction_evaluation - good-humored.a - a#1134232
+0 ## Social_interaction_evaluation - insensitive.a - a#2105375
+0 ## Social_interaction_evaluation - nice.a - a#641460
+0 ## Social_interaction_evaluation - diplomatic.a - a#758459
+0 ## Social_interaction_evaluation - inconsiderate.a - a#639356
+0 ## Social_interaction_evaluation - rude.a - a#641944
+0 ## Social_interaction_evaluation - compassionate.a - a#506299
+0 ## Social_interaction_evaluation - gracious.a - a#641460
+0 ## Social_interaction_evaluation - ill-mannered.a - a#641944
+0 ## Social_interaction_evaluation - chummy.a - a#1075524
+0 ## Social_interaction_evaluation - thoughtless.a - a#2420530
+0 ## Social_interaction_evaluation - thoughtful.a - a#2418872
+0 ## Social_interaction_evaluation - churlish.a - a#1142595
+0 ## Social_interaction_evaluation - barbaric.a - a#412788
+0 ## Social_interaction_evaluation - tactful.a - a#759169
+0 ## Social_interaction_evaluation - discourteous.a - a#642152
+0 ## Social_interaction_evaluation - horrible.a - a#193480
+0 ## Social_interaction_evaluation - good-natured.a - a#1133876
+0 ## Social_interaction_evaluation - smart.a - a#205295
+0 ## Social_interaction_evaluation - sweet.a - a#2368336
+0 ## Social_interaction_evaluation - cruel.a - a#1263013
+0 ## Social_interaction_evaluation - respectful.a - a#1993940
+0 ## Social_interaction_evaluation - unfriendly.a - a#1078178
+0 ## Social_interaction_evaluation - good.a - a#1123148
+0 ## Social_interaction_evaluation - sociable.a - a#2257141
+0 ## Social_interaction_evaluation - cordial.a - a#1075178
+0 ## Social_interaction_evaluation - civil.a - a#642379
+0 ## Social_interaction_evaluation - disrespectful.a - a#1994602
+0 ## Social_interaction_evaluation - warm.a - a#2530861
+0 ## Social_interaction_evaluation - impertinent.a - a#205295
+0 ## Social_interaction_evaluation - friendly.a - a#1074650
+0 ## Social_interaction_evaluation - amiable.a - a#1075178
+0 ## Social_interaction_evaluation - impolite.a - a#641640
+0 ## Social_interaction_evaluation - considerate.a - a#638981
+0 ## Social_interaction_evaluation - kind.a - a#1372049
+0 ## Social_interaction_evaluation - unkind.a - a#1373728
+0 ## Social_interaction_evaluation - ungracious.a - a#642152
+0 ## Social_interaction_evaluation - pleasant.a - a#1800349
+0 ## Social_interaction_evaluation - spiteful.a - a#225099
+0 ## Social_interaction_evaluation - boorish.a - a#1949859
+0 ## Social_interaction_evaluation - mean.a - a#1594146
+0 ## Social_interaction_evaluation - genial.a - a#1075178
+0 ## Social_interaction_evaluation - impudent.a - a#205295
+0 ## Social_interaction_evaluation - affable.a - a#1075178
+0 ## Social_interaction_evaluation - courteous.a - a#641460
+0 ## Escaping - get out.v - v#810729
+0 ## Escaping - escape.v - v#2074677
+0 ## Escaping - fly the coop.v - v#2075049
+0 ## Escaping - scarper.v - v#2075049
+0 ## Escaping - evacuate.v - v#1856450
+0 ## Cause_bodily_experience - chafe.v - v#1250908
+0 ## Cause_bodily_experience - rub.v - v#1250908
+0 ## Cause_bodily_experience - tickle.v - v#2120140
+0 ## Cause_bodily_experience - itch.v - v#2119874
+0 ## Cause_bodily_experience - scratch.v - v#2119874
+0 ## Cause_bodily_experience - massage.v - v#1232738
+0 ## Becoming - get.v - v#149583
+0 ## Becoming - end up.v - v#352558
+0 ## Becoming - go.v - v#1835496
+0 ## Becoming - grow.v - v#125841
+0 ## Becoming - become.v - v#149583
+0 ## Becoming - turn.v - v#146138
+0 ## Becoming - form.v - v#2623906
+0 ## Diversity - scope.n - n#5125377
+0 ## Diversity - variability.n - n#4771890
+0 ## Diversity - mixed bag.n - n#8398773
+0 ## Diversity - broad.a - a#2560548
+0 ## Diversity - assorted.a - a#1199083
+0 ## Diversity - assortment.n - n#8398773
+0 ## Diversity - uniformity.n - n#4745370
+0 ## Diversity - uniform.a - a#1200095
+0 ## Diversity - heterogeneity.n - n#4751098
+0 ## Diversity - heterogeneous.a - a#1198737
+0 ## Diversity - homogeneity.n - n#4769234
+0 ## Diversity - multifariousness.n - n#4751305
+0 ## Diversity - range.n - n#8399586
+0 ## Diversity - variety.n - n#4751305
+0 ## Diversity - array.n - n#6888174
+0 ## Diversity - medley.n - n#7047505
+0 ## Diversity - varied.a - a#2506555
+0 ## Diversity - multifarious.a - a#2506922
+0 ## Diversity - homogeneous.a - a#1199751
+0 ## Diversity - various.a - a#2065665
+0 ## Diversity - multiplicity.n - n#5121908
+0 ## Diversity - breadth.n - n#5618293
+0 ## Diversity - manifold.a - a#2218314
+0 ## Diversity - miscellany.n - n#8398773
+0 ## Diversity - diverse.a - a#2067491
+0 ## Diversity - diversity.n - n#4751305
+0 ## Diversity - diverseness.n - n#4751305
+0 ## Presence - presence.n - n#13957601
+0 ## Presence - present.a - a#1846413
+0 ## Exhaust_resource - devour.v - v#1565360
+0 ## Exhaust_resource - exhaust.v - v#1157517
+0 ## Exhaust_resource - expend.v - v#1158572
+0 ## Exhaust_resource - use up.v - v#2267989
+0 ## Relation - relation.n - n#10235549
+0 ## Growing_food - raise.v - v#1739814
+0 ## Growing_food - grow.v - v#230746
+0 ## Delimitation_of_diversity - range.v - v#2727039
+0 ## Detaining - intern.v - v#2495387
+0 ## Detaining - hold.v - v#2681795
+0 ## Detaining - internment.n - n#1146768
+0 ## Detaining - custody.n - n#1147347
+0 ## Detaining - detain.v - v#2495038
+0 ## Detaining - at large.a - a#1062114
+0 ## Reporting - fink.v - v#2412939
+0 ## Reporting - squeal.n - n#7395777
+0 ## Reporting - report.v - v#965035
+0 ## Reporting - informer.n - n#10206173
+0 ## Reporting - nark.n - n#10345659
+0 ## Reporting - inform.v - v#831651
+0 ## Reporting - rat.v - v#841986
+0 ## Reporting - snitch.v - v#841986
+0 ## Reporting - snitch.n - n#10091012
+0 ## Reporting - tell_((on)).v - v#952524
+0 ## Reporting - peach.v - v#937208
+0 ## Reporting - fink.n - n#10091012
+0 ## Reporting - finger.v - v#1209953
+0 ## Performing_arts - music.n - n#7020895
+0 ## Performing_arts - performance.n - n#6891493
+0 ## Performing_arts - play.n - n#7007945
+0 ## Abusing - maltreat.v - v#2516594
+0 ## Abusing - abuse.v - v#2516594
+0 ## Abusing - maltreatment.n - n#419908
+0 ## Abusing - domestic violence.n - n#965718
+0 ## Abusing - batter.v - v#1417705
+0 ## Abusing - abusive.a - a#1160584
+0 ## Abusing - abuse.n - n#419908
+0 ## Reveal_secret - leak.v - v#937023
+0 ## Reveal_secret - reveal.v - v#933821
+0 ## Reveal_secret - disclosure.n - n#7213395
+0 ## Reveal_secret - come forward.v - v#2089174
+0 ## Reveal_secret - disclose.v - v#933821
+0 ## Reveal_secret - divulgence.n - n#7214267
+0 ## Reveal_secret - revelation.n - n#7213395
+0 ## Reveal_secret - confession.n - n#1039307
+0 ## Reveal_secret - confide.v - v#936465
+0 ## Reveal_secret - fess up.v - v#817909
+0 ## Reveal_secret - divulge.v - v#933821
+0 ## Reveal_secret - admit.v - v#817311
+0 ## Reveal_secret - expose.v - v#933821
+0 ## Reveal_secret - confess.v - v#818553
+0 ## Using - operational.a - a#833018
+0 ## Using - utilise.v - v#1158872
+0 ## Using - employ.v - v#1158872
+0 ## Using - utilisation.n - n#947128
+0 ## Using - operation.n - n#13525549
+0 ## Using - use.v - v#1158872
+0 ## Using - application.n - n#949134
+0 ## Using - apply.v - v#1158872
+0 ## Using - operate.v - v#2443849
+0 ## Using - use.n - n#947128
+0 ## Using - employment.n - n#947128
+0 ## Degree_of_processing - raw.a - a#1952643
+0 ## Degree_of_processing - processed.a - a#1953297
+0 ## Degree_of_processing - unprocessed.a - a#1952405
+0 ## Boundary - boundary.n - n#13903079
+0 ## Boundary - edge.n - n#13903079
+0 ## Boundary - border.n - n#13903387
+0 ## Boundary - line.n - n#13863771
+0 ## Shapes - ellipse.n - n#13878306
+0 ## Shapes - shape.n - n#27807
+0 ## Shapes - strip.n - n#9449510
+0 ## Shapes - wedge.n - n#13919547
+0 ## Shapes - row.n - n#8431437
+0 ## Shapes - circular.a - a#2040652
+0 ## Shapes - sheet.n - n#13861050
+0 ## Shapes - triangle.n - n#13879320
+0 ## Shapes - length.n - n#5129565
+0 ## Shapes - round.a - a#2040652
+0 ## Shapes - expanse.n - n#9277538
+0 ## Shapes - ball.n - n#13899404
+0 ## Shapes - square.n - n#4291511
+0 ## Shapes - stretch.n - n#9448945
+0 ## Shapes - coil.n - n#13875970
+0 ## Shapes - curve.n - n#5072663
+0 ## Shapes - cube.n - n#13914608
+0 ## Shapes - stick.n - n#4318131
+0 ## Shapes - ribbon.n - n#4088058
+0 ## Shapes - circle.n - n#13873502
+0 ## Shapes - oval.n - n#13878306
+0 ## Shapes - v.n - n#6833436
+0 ## Shapes - line.n - n#13863771
+0 ## Body_movement - cock.v - v#1884868
+0 ## Body_movement - arch.v - v#2034986
+0 ## Body_movement - shrug.v - v#33955
+0 ## Body_movement - bat.v - v#8195
+0 ## Body_movement - curtsy.n - n#7274890
+0 ## Body_movement - bend.v - v#2035919
+0 ## Body_movement - stamp.v - v#1594362
+0 ## Body_movement - waggle.v - v#1898592
+0 ## Body_movement - duck.v - v#1865203
+0 ## Body_movement - wag.v - v#1898592
+0 ## Body_movement - twiddle.v - v#2048891
+0 ## Body_movement - grind.v - v#1394464
+0 ## Body_movement - shudder.v - v#1888946
+0 ## Body_movement - close.v - v#1345109
+0 ## Body_movement - blink.v - v#7739
+0 ## Body_movement - swing.v - v#2087745
+0 ## Body_movement - shut.v - v#1345109
+0 ## Body_movement - pucker.v - v#1278817
+0 ## Body_movement - stretch.v - v#27268
+0 ## Body_movement - crane.v - v#28167
+0 ## Body_movement - wink.v - v#7739
+0 ## Body_movement - scrunch.v - v#1278427
+0 ## Body_movement - smack.v - v#1197208
+0 ## Body_movement - flutter.v - v#8195
+0 ## Body_movement - kneel.v - v#1545649
+0 ## Body_movement - move.v - v#1831531
+0 ## Body_movement - flap.v - v#1901783
+0 ## Body_movement - pout.v - v#34758
+0 ## Body_movement - cross.v - v#1912159
+0 ## Body_movement - shake.v - v#1889610
+0 ## Body_movement - twitch.v - v#1893601
+0 ## Body_movement - crumple.v - v#1278817
+0 ## Body_movement - jiggle.v - v#1898282
+0 ## Body_movement - gnash.v - v#78578
+0 ## Body_movement - hang.v - v#1977962
+0 ## Body_movement - wriggle.v - v#1868370
+0 ## Body_movement - twist.v - v#1868370
+0 ## Body_movement - yawn.v - v#7328
+0 ## Body_movement - jerk.v - v#1891817
+0 ## Body_movement - wave.v - v#1901783
+0 ## Body_movement - drop.v - v#1977701
+0 ## Body_movement - curtsy.v - v#899352
+0 ## Body_movement - wrinkle.v - v#1278427
+0 ## Body_movement - open.v - v#1346003
+0 ## Body_movement - bob.v - v#899352
+0 ## Body_movement - roll.v - v#1901783
+0 ## Body_movement - shiver.v - v#14201
+0 ## Body_movement - throw.v - v#1508368
+0 ## Body_movement - writhe.v - v#1868370
+0 ## Body_movement - nod.v - v#16702
+0 ## Body_movement - lift.v - v#1974062
+0 ## Body_movement - fling.v - v#1512465
+0 ## Body_movement - crinkle.v - v#1278427
+0 ## Body_movement - crease.v - v#1278427
+0 ## Body_movement - flex.v - v#1280488
+0 ## Body_movement - purse.v - v#1279305
+0 ## Body_movement - wiggle.v - v#1898282
+0 ## Body_movement - shuffle.v - v#2012973
+0 ## Body_movement - clap.v - v#2094299
+0 ## Body_movement - toss.v - v#1512625
+0 ## Body_movement - fidget.v - v#2058448
+0 ## Attending - attendance.n - n#1233397
+0 ## Attending - attend.v - v#2612762
+0 ## Attending - go_(to).v - v#1835496
+0 ## Turning_out - prove.v - v#2633881
+0 ## Turning_out - turn out.v - v#2634133
+0 ## Turning_out - end up.v - v#352558
+0 ## Going_back_on_a_commitment - back out.v - v#799383
+0 ## Going_back_on_a_commitment - go back.v - v#2723951
+0 ## Going_back_on_a_commitment - renege.v - v#800242
+0 ## Becoming_dry - exsiccate.v - v#211108
+0 ## Becoming_dry - dry up.v - v#211108
+0 ## Becoming_dry - dehydrate.v - v#211108
+0 ## Becoming_dry - dry.v - v#218475
+0 ## Beat_opponent - defeat.v - v#1108148
+0 ## Beat_opponent - rout.v - v#1104248
+0 ## Beat_opponent - trounce.v - v#1101913
+0 ## Beat_opponent - prevail.v - v#2644234
+0 ## Beat_opponent - defeat.n - n#7475364
+0 ## Beat_opponent - upend.v - v#1909679
+0 ## Beat_opponent - rout.n - n#7476404
+0 ## Beat_opponent - demolish.v - v#1083373
+0 ## Beat_opponent - beat.v - v#1101913
+0 ## Inspecting - check.v - v#661824
+0 ## Inspecting - frisk.v - v#1318223
+0 ## Inspecting - double-check.v - v#663549
+0 ## Inspecting - inspect.v - v#2165543
+0 ## Inspecting - examine.v - v#644583
+0 ## Inspecting - reconnoitre.v - v#2167571
+0 ## Inspecting - inspection.n - n#879271
+0 ## Inspecting - examination.n - n#635850
+0 ## Withdraw_from_participation - beg off.v - v#894221
+0 ## Withdraw_from_participation - pull out.v - v#1995211
+0 ## Withdraw_from_participation - withdraw.v - v#799383
+0 ## Withdraw_from_participation - withdrawal.n - n#53913
+0 ## Intentionally_act - action.n - n#37396
+0 ## Intentionally_act - act.v - v#2367363
+0 ## Intentionally_act - do.v - v#2560585
+0 ## Intentionally_act - activity.n - n#407535
+0 ## Intentionally_act - act.n - n#30358
+0 ## Intentionally_act - agent.n - n#9777353
+0 ## Intentionally_act - carry out.v - v#1640855
+0 ## Intentionally_act - execute.v - v#1640855
+0 ## Intentionally_act - engage.v - v#2375131
+0 ## Intentionally_act - step.n - n#174412
+0 ## Intentionally_act - perform.v - v#1712704
+0 ## Intentionally_act - actor.n - n#9767197
+0 ## Intentionally_act - move.n - n#165942
+0 ## Intentionally_act - conduct.v - v#1732921
+0 ## Stimulus_focus - tiring.a - a#837249
+0 ## Stimulus_focus - humorous.a - a#1264336
+0 ## Stimulus_focus - exhilarating.a - a#1357342
+0 ## Stimulus_focus - disappointing.a - a#2082611
+0 ## Stimulus_focus - alienating.a - a#760783
+0 ## Stimulus_focus - dreadful.a - a#193799
+0 ## Stimulus_focus - terrifying.a - a#196449
+0 ## Stimulus_focus - pitiful.a - a#1126841
+0 ## Stimulus_focus - frightening.a - a#193799
+0 ## Stimulus_focus - embarrassing.a - a#1803335
+0 ## Stimulus_focus - unpleasing.a - a#1142666
+0 ## Stimulus_focus - encouraging.a - a#866471
+0 ## Stimulus_focus - thrilling.a - a#921866
+0 ## Stimulus_focus - disconcerting.a - a#1809019
+0 ## Stimulus_focus - aggravation.n - n#7518878
+0 ## Stimulus_focus - invigorating.a - a#1356683
+0 ## Stimulus_focus - exasperating.a - a#1809245
+0 ## Stimulus_focus - dull.a - a#1345307
+0 ## Stimulus_focus - astounding.a - a#1283155
+0 ## Stimulus_focus - confusing.a - a#430756
+0 ## Stimulus_focus - sobering.a - a#2120150
+0 ## Stimulus_focus - astonishing.a - a#1283155
+0 ## Stimulus_focus - annoyance.n - n#7518261
+0 ## Stimulus_focus - engrossing.a - a#1344171
+0 ## Stimulus_focus - empty.a - a#1086545
+0 ## Stimulus_focus - mystifying.a - a#939444
+0 ## Stimulus_focus - agreeable.a - a#89051
+0 ## Stimulus_focus - infuriating.a - a#1809245
+0 ## Stimulus_focus - fascinating.a - a#1344171
+0 ## Stimulus_focus - troubling.a - a#1189386
+0 ## Stimulus_focus - striking.a - a#1284212
+0 ## Stimulus_focus - heartening.a - a#866894
+0 ## Stimulus_focus - color.n - n#5193338
+0 ## Stimulus_focus - stressful.a - a#90408
+0 ## Stimulus_focus - galling.a - a#89550
+0 ## Stimulus_focus - charm_((count)).n - n#4687333
+0 ## Stimulus_focus - amusing.a - a#1265308
+0 ## Stimulus_focus - disagreeable.a - a#89355
+0 ## Stimulus_focus - funny.a - a#1265308
+0 ## Stimulus_focus - displeasing.a - a#1808822
+0 ## Stimulus_focus - breathtaking.a - a#921369
+0 ## Stimulus_focus - amazing.a - a#2359789
+0 ## Stimulus_focus - distressing.a - a#1189386
+0 ## Stimulus_focus - heartbreaking.a - a#1365544
+0 ## Stimulus_focus - traumatic.a - a#2944872
+0 ## Stimulus_focus - solemn.a - a#2119213
+0 ## Stimulus_focus - upsetting.a - a#1809019
+0 ## Stimulus_focus - insulting.a - a#1995288
+0 ## Stimulus_focus - poignant.a - a#1560821
+0 ## Stimulus_focus - intimidating.a - a#867520
+0 ## Stimulus_focus - perplexing.a - a#430756
+0 ## Stimulus_focus - unnerving.a - a#195383
+0 ## Stimulus_focus - agonizing.a - a#1711724
+0 ## Stimulus_focus - interesting.a - a#1343918
+0 ## Stimulus_focus - irritating.a - a#89550
+0 ## Stimulus_focus - tedious.a - a#1345307
+0 ## Stimulus_focus - charming.a - a#1807799
+0 ## Stimulus_focus - stinging.a - a#1374004
+0 ## Stimulus_focus - intriguing.a - a#1344684
+0 ## Stimulus_focus - captivating.a - a#166753
+0 ## Stimulus_focus - disheartening.a - a#867615
+0 ## Stimulus_focus - consoling.a - a#197319
+0 ## Stimulus_focus - rest.n - n#1064148
+0 ## Stimulus_focus - worrisome.a - a#1189386
+0 ## Stimulus_focus - satisfying.a - a#2081563
+0 ## Stimulus_focus - irksome.a - a#1345307
+0 ## Stimulus_focus - relaxation.n - n#1064148
+0 ## Stimulus_focus - chilling.a - a#194924
+0 ## Stimulus_focus - discouraging.a - a#867213
+0 ## Stimulus_focus - entertaining.a - a#1344344
+0 ## Stimulus_focus - absorbing.a - a#1344171
+0 ## Stimulus_focus - pleasing.a - a#1807219
+0 ## Stimulus_focus - rousing.a - a#2307026
+0 ## Stimulus_focus - tiresome.a - a#1345307
+0 ## Stimulus_focus - unexciting.a - a#2307367
+0 ## Stimulus_focus - sad.a - a#1126841
+0 ## Stimulus_focus - beguiling.a - a#2097480
+0 ## Stimulus_focus - stirring.a - a#2307026
+0 ## Stimulus_focus - harrowing.a - a#1711724
+0 ## Stimulus_focus - relaxing.a - a#1922227
+0 ## Stimulus_focus - full.a - a#1456710
+0 ## Stimulus_focus - nice.a - a#1586342
+0 ## Stimulus_focus - mind-boggling.a - a#1285938
+0 ## Stimulus_focus - unfunny.a - a#1268937
+0 ## Stimulus_focus - gratifying.a - a#1801029
+0 ## Stimulus_focus - scary.a - a#194924
+0 ## Stimulus_focus - unpleasant.a - a#1801600
+0 ## Stimulus_focus - offensive.a - a#1624633
+0 ## Stimulus_focus - delightful.a - a#1807964
+0 ## Stimulus_focus - hair-raising.a - a#194817
+0 ## Stimulus_focus - startling.a - a#2359958
+0 ## Stimulus_focus - stupefying.a - a#1283155
+0 ## Stimulus_focus - charm_((mass)).n - n#4687333
+0 ## Stimulus_focus - comical.a - a#1265308
+0 ## Stimulus_focus - sickening.a - a#2560035
+0 ## Stimulus_focus - annoying.a - a#89550
+0 ## Stimulus_focus - revolting.a - a#1625893
+0 ## Stimulus_focus - stimulating.a - a#2306288
+0 ## Stimulus_focus - baffling.a - a#746451
+0 ## Stimulus_focus - disturbing.a - a#1189386
+0 ## Stimulus_focus - vexation.n - n#7518261
+0 ## Stimulus_focus - droll.a - a#1265938
+0 ## Stimulus_focus - boring.a - a#1345307
+0 ## Stimulus_focus - cool.a - a#2532200
+0 ## Stimulus_focus - abominable.a - a#1126291
+0 ## Stimulus_focus - maddening.a - a#1809245
+0 ## Stimulus_focus - distasteful.a - a#1625893
+0 ## Stimulus_focus - appalling.a - a#193367
+0 ## Stimulus_focus - soothing.a - a#197151
+0 ## Stimulus_focus - bothersome.a - a#89550
+0 ## Stimulus_focus - troublesome.a - a#748795
+0 ## Stimulus_focus - enchanting.a - a#166753
+0 ## Stimulus_focus - vexatious.a - a#89550
+0 ## Stimulus_focus - pathetic.a - a#1050890
+0 ## Stimulus_focus - comforting.a - a#197319
+0 ## Stimulus_focus - electrifying.a - a#921866
+0 ## Stimulus_focus - pleasant.a - a#1800349
+0 ## Stimulus_focus - enjoyable.a - a#1801029
+0 ## Stimulus_focus - mortifying.a - a#1803335
+0 ## Stimulus_focus - reassuring.a - a#196934
+0 ## Stimulus_focus - surprising.a - a#2359464
+0 ## Stimulus_focus - disgusting.a - a#1625893
+0 ## Stimulus_focus - vexing.a - a#89550
+0 ## Stimulus_focus - formidable.a - a#195383
+0 ## Stimulus_focus - touching.a - a#1560821
+0 ## Stimulus_focus - worrying.a - a#1189386
+0 ## Stimulus_focus - exciting.a - a#921014
+0 ## Stimulus_focus - placating.a - a#759826
+0 ## Stimulus_focus - shocking.a - a#2101757
+0 ## Stimulus_focus - bewitching.a - a#166753
+0 ## Stimulus_focus - thorny.a - a#748674
+0 ## Stimulus_focus - enthralling.a - a#166753
+0 ## Stimulus_focus - rich.a - a#1457369
+0 ## Stimulus_focus - impressive.a - a#1282014
+0 ## Stimulus_focus - cheering.a - a#2081563
+0 ## Stimulus_focus - ghastly.a - a#195684
+0 ## Stimulus_focus - gripping.a - a#1344171
+0 ## Stimulus_focus - dismaying.a - a#193367
+0 ## Stimulus_focus - recreation.n - n#401783
+0 ## Stimulus_focus - suspenseful.a - a#2405805
+0 ## Stimulus_focus - aggravating.a - a#1340422
+0 ## Stimulus_focus - repellent.a - a#1625893
+0 ## Stimulus_focus - delight.n - n#5829782
+0 ## Stimulus_focus - devastating.a - a#1995047
+0 ## Stimulus_focus - depressing.a - a#364479
+0 ## Stimulus_focus - disillusioning.a - a#615343
+0 ## Stimulus_focus - hilarious.a - a#1266841
+0 ## Stimulus_focus - pleasurable.a - a#1801029
+0 ## Stimulus_focus - jolly.a - a#1367651
+0 ## Stimulus_focus - nerve-racking.a - a#90408
+0 ## Stimulus_focus - alarming.a - a#193015
+0 ## Frugality - sparing.a - a#2421364
+0 ## Frugality - penny-wise.a - a#2421833
+0 ## Frugality - spendthrift.n - n#10635460
+0 ## Frugality - thrift.n - n#4893525
+0 ## Frugality - austere.a - a#9618
+0 ## Frugality - extravagant.a - a#2422242
+0 ## Frugality - spartan.a - a#9618
+0 ## Frugality - parsimonious.a - a#1114116
+0 ## Frugality - thrifty.a - a#2421158
+0 ## Frugality - parsimony.n - n#4893525
+0 ## Frugality - wasteful.a - a#2422068
+0 ## Frugality - economical.a - a#2421364
+0 ## Frugality - squander.v - v#2268351
+0 ## Frugality - profligacy.n - n#4894807
+0 ## Frugality - profligate.a - a#2422242
+0 ## Frugality - economy.n - n#4893787
+0 ## Frugality - waste.v - v#2268351
+0 ## Frugality - austerity.n - n#4881998
+0 ## Frugality - husband.v - v#2269143
+0 ## Frugality - frugality.n - n#4893358
+0 ## Frugality - frugal.a - a#2421364
+0 ## Frugality - scrimp.v - v#2345498
+0 ## Reparation - make up.v - v#2620587
+0 ## Reparation - restitution.n - n#270275
+0 ## Reparation - reparation.n - n#95329
+0 ## Reparation - amends.n - n#95329
+0 ## Ground_up - granulated.a - a#2231886
+0 ## Ground_up - pulverized.a - a#2233390
+0 ## Ground_up - crushed.a - a#2240668
+0 ## Ground_up - shredded.a - a#661640
+0 ## Ground_up - milled.a - a#1952153
+0 ## Ground_up - powdered.a - a#2233390
+0 ## Piracy - carjack.v - v#1472417
+0 ## Piracy - piracy.n - n#783527
+0 ## Piracy - hijacking.n - n#783199
+0 ## Piracy - carjacking.n - n#227484
+0 ## Piracy - hijacker.n - n#10175507
+0 ## Piracy - pirate.v - v#1471825
+0 ## Piracy - hijack.v - v#1471825
+0 ## Prison - joint.n - n#5595083
+0 ## Prison - pen.n - n#3911513
+0 ## Prison - correctional institution.n - n#3111690
+0 ## Prison - stockade.n - n#4322531
+0 ## Prison - penitentiary.n - n#3911513
+0 ## Prison - jail.n - n#3592245
+0 ## Prison - slammer.n - n#3592245
+0 ## Prison - brig.n - n#2901259
+0 ## Prison - jailhouse.n - n#3592245
+0 ## Prison - prison.n - n#4005630
+0 ## Sharpness - blunt.a - a#800464
+0 ## Sharpness - dull.a - a#800248
+0 ## Sharpness - sharp.a - a#800826
+0 ## Damaging - scratch.v - v#1309143
+0 ## Damaging - rend.v - v#1573276
+0 ## Damaging - tear.v - v#1573515
+0 ## Damaging - damage.v - v#258857
+0 ## Damaging - deface.v - v#1549905
+0 ## Damaging - score.v - v#1111816
+0 ## Damaging - vandalism.n - n#1249816
+0 ## Damaging - key.v - v#1520655
+0 ## Damaging - damage.n - n#403092
+0 ## Damaging - vandalise.v - v#1520454
+0 ## Damaging - chip.v - v#1259005
+0 ## Damaging - mar.v - v#477941
+0 ## Damaging - rip.v - v#1573276
+0 ## Damaging - scrape.v - v#1309143
+0 ## Damaging - nick.v - v#1259005
+0 ## Damaging - sabotage.v - v#2543607
+0 ## Damaging - dent.v - v#1279631
+0 ## Taking_time - swift.a - a#978199
+0 ## Taking_time - take.v - v#2267989
+0 ## Taking_time - rapid.a - a#979862
+0 ## Taking_time - slowly.adv - r#161630
+0 ## Taking_time - fast.a - a#976508
+0 ## Taking_time - gradually.adv - r#107987
+0 ## Taking_time - slow.a - a#980527
+0 ## Taking_time - quick.a - a#979366
+0 ## Taking_time - speedy.a - a#979862
+0 ## Performers - actress.n - n#9767700
+0 ## Performers - player.n - n#9765278
+0 ## Performers - musician.n - n#10340312
+0 ## Performers - actor.n - n#9765278
+0 ## Being_operational - busted.a - a#680156
+0 ## Being_operational - functional.a - a#2124253
+0 ## Being_operational - broken.a - a#680156
+0 ## Being_operational - work.v - v#1525666
+0 ## Being_operational - operational.a - a#2124253
+0 ## Being_operational - down.a - a#833737
+0 ## Being_operational - working.a - a#1091728
+0 ## Purpose - purpose.n - n#5982152
+0 ## Purpose - intend.v - v#708538
+0 ## Purpose - use.n - n#947128
+0 ## Purpose - target.n - n#5981230
+0 ## Purpose - aim.v - v#708980
+0 ## Purpose - mean.v - v#708538
+0 ## Purpose - intention.n - n#5982152
+0 ## Purpose - plan.n - n#5898568
+0 ## Purpose - aim.n - n#5982152
+0 ## Purpose - application.n - n#949134
+0 ## Purpose - plan.v - v#705227
+0 ## Purpose - determined.a - a#1990373
+0 ## Purpose - bent.a - a#1990172
+0 ## Purpose - object.n - n#5981230
+0 ## Purpose - objective.n - n#5981230
+0 ## Purpose - intent.a - a#163948
+0 ## Purpose - goal.n - n#5980875
+0 ## Prevent_from_having - deny.v - v#816556
+0 ## Prevent_from_having - starve.v - v#1187740
+0 ## Prevent_from_having - deprive.v - v#2313250
+0 ## Exclude_member - excommunicate.v - v#2402112
+0 ## Exclude_member - excommunication.n - n#14413993
+0 ## Exclude_member - expel.v - v#2501738
+0 ## Exclude_member - expulsion.n - n#116687
+0 ## Separating - partition.v - v#1563724
+0 ## Separating - bisect.v - v#1550817
+0 ## Separating - part.v - v#1557774
+0 ## Separating - section.v - v#1563005
+0 ## Separating - sever.v - v#1560984
+0 ## Separating - segment.v - v#1558440
+0 ## Separating - partition.n - n#3894379
+0 ## Separating - segregate.v - v#1558218
+0 ## Separating - separate.v - v#1557774
+0 ## Separating - divide.v - v#1557774
+0 ## Separating - split.v - v#2467662
+0 ## Fear - terror.n - n#7520612
+0 ## Fear - dread.n - n#7521674
+0 ## Fear - nervous.a - a#2456157
+0 ## Fear - fear.n - n#7519253
+0 ## Fear - frightened.a - a#80357
+0 ## Fear - terrified.a - a#80357
+0 ## Fear - afraid.a - a#77645
+0 ## Fear - scared.a - a#79629
+0 ## Fear - apprehension.n - n#7521674
+0 ## Becoming_detached - decouple.v - v#1297813
+0 ## Becoming_detached - unhook.v - v#1366321
+0 ## Becoming_detached - detach.v - v#1298668
+0 ## Becoming_detached - unhinge.v - v#179852
+0 ## Severity_of_offense - actionable.a - a#1370864
+0 ## Severity_of_offense - indictable.a - a#1322044
+0 ## Severity_of_offense - capital.a - a#2342778
+0 ## Severity_of_offense - felonious.a - a#1402763
+0 ## Dominate_competitor - dominant.a - a#791227
+0 ## Dominate_competitor - strongman.n - n#10665006
+0 ## Dominate_competitor - domination.n - n#1128390
+0 ## Dominate_competitor - dominate.v - v#2646931
+0 ## Substance - glass.n - n#14881303
+0 ## Substance - chemical.n - n#14806838
+0 ## Substance - petroleum.n - n#14980579
+0 ## Substance - solid.n - n#14480772
+0 ## Substance - liquid.n - n#14940386
+0 ## Substance - yellowcake.n - n#15106529
+0 ## Substance - aluminum.n - n#14627820
+0 ## Substance - plutonium.n - n#14649775
+0 ## Substance - material.n - n#14580897
+0 ## Substance - uranium.n - n#14660443
+0 ## Substance - gas.n - n#14877585
+0 ## Substance - ore.n - n#14688500
+0 ## Substance - oil.n - n#14966667
+0 ## Substance - atropine.n - n#2754756
+0 ## Substance - metal.n - n#14625458
+0 ## Substance - iron.n - n#14642417
+0 ## Substance - juice.n - n#7923748
+0 ## Substance - water.n - n#14845743
+0 ## Substance - sand.n - n#15019030
+0 ## Substance - methane.n - n#14951229
+0 ## Likelihood - likely.adv - r#138611
+0 ## Likelihood - likelihood.n - n#4756635
+0 ## Likelihood - impossible.a - a#1823092
+0 ## Likelihood - bound.a - a#340626
+0 ## Likelihood - certainly.adv - r#144722
+0 ## Likelihood - assured.a - a#2094203
+0 ## Likelihood - sure.a - a#336831
+0 ## Likelihood - prone.a - a#1292884
+0 ## Likelihood - probable.a - a#1413247
+0 ## Likelihood - possible.a - a#1821266
+0 ## Likelihood - can.v - v#213794
+0 ## Likelihood - unlikely.a - a#1412415
+0 ## Likelihood - certainty.n - n#5697135
+0 ## Likelihood - liable.a - a#1411919
+0 ## Likelihood - certain.a - a#700884
+0 ## Likelihood - possibility.n - n#14481929
+0 ## Likelihood - probability.n - n#5091770
+0 ## Likelihood - chance.n - n#14483917
+0 ## Likelihood - long.a - a#1437963
+0 ## Likelihood - likely.a - a#1411451
+0 ## Likelihood - probably.adv - r#138611
+0 ## Likelihood - improbability.n - n#4758452
+0 ## Likelihood - tend.v - v#2719399
+0 ## Likelihood - possibly.adv - r#300247
+0 ## Grinding - grind.v - v#331082
+0 ## Grinding - flake.v - v#1585276
+0 ## Grinding - mastication.n - n#278810
+0 ## Grinding - masticate.v - v#1201089
+0 ## Grinding - crush.v - v#1593937
+0 ## Grinding - grate.v - v#1394464
+0 ## Grinding - pulverize.v - v#332154
+0 ## Grinding - mill.v - v#332017
+0 ## Grinding - chew.v - v#1201089
+0 ## Grinding - crumble.v - v#2041877
+0 ## Grinding - crunch.v - v#1201693
+0 ## Grinding - shred.v - v#1573891
+0 ## Remainder - remains.n - n#9407346
+0 ## Remainder - remnant.n - n#13811184
+0 ## Remainder - left.a - a#926505
+0 ## Remainder - remain.v - v#117985
+0 ## Attack - offensive.a - a#1628946
+0 ## Attack - invade.v - v#1126360
+0 ## Attack - attacker.n - n#9821253
+0 ## Attack - offensive.n - n#980038
+0 ## Attack - ambush.v - v#1138204
+0 ## Attack - strike.v - v#1123887
+0 ## Attack - ambush.n - n#1246926
+0 ## Attack - invader.n - n#10214062
+0 ## Attack - assault.n - n#974444
+0 ## Attack - bomb.v - v#1131902
+0 ## Attack - fall_(upon).v - v#1970826
+0 ## Attack - set_(upon).v - v#1115006
+0 ## Attack - onset.n - n#972621
+0 ## Attack - bombing.n - n#978413
+0 ## Attack - jump.v - v#1121178
+0 ## Attack - onslaught.n - n#972621
+0 ## Attack - assail.v - v#1119169
+0 ## Attack - storm.v - v#1126051
+0 ## Attack - attack.v - v#1119169
+0 ## Attack - infiltration.n - n#976698
+0 ## Attack - raid.v - v#2494850
+0 ## Attack - incursion.n - n#975452
+0 ## Attack - attack.n - n#972621
+0 ## Attack - assault.v - v#1120069
+0 ## Attack - lay_(into).v - v#1494310
+0 ## Attack - infiltrate.v - v#1913363
+0 ## Attack - charge.v - v#1121719
+0 ## Attack - raid.n - n#976953
+0 ## Attack - charge.n - n#974762
+0 ## Attack - strike.n - n#977301
+0 ## First_rank - foremost.a - a#228294
+0 ## First_rank - leading.a - a#1472790
+0 ## First_rank - chief.a - a#1277426
+0 ## First_rank - principal.a - a#1277426
+0 ## First_rank - main.a - a#1277426
+0 ## First_rank - leader.n - n#9623038
+0 ## First_rank - lead.n - n#1256743
+0 ## First_rank - primary.a - a#1277426
+0 ## Giving - pass.v - v#2230772
+0 ## Giving - hand_out.v - v#2201644
+0 ## Giving - gift.n - n#1086081
+0 ## Giving - contribute.v - v#2308741
+0 ## Giving - contribution.n - n#1089778
+0 ## Giving - treat.v - v#2261642
+0 ## Giving - advance.v - v#1992503
+0 ## Giving - leave.v - v#2229055
+0 ## Giving - give.v - v#2200686
+0 ## Giving - foist.v - v#749092
+0 ## Giving - will.v - v#2229055
+0 ## Giving - charity.n - n#1089635
+0 ## Giving - volunteer.v - v#880102
+0 ## Giving - bequeath.v - v#2229055
+0 ## Giving - donate.v - v#2263027
+0 ## Giving - hand.v - v#2230772
+0 ## Giving - fob_off.v - v#2244426
+0 ## Giving - donation.n - n#1089778
+0 ## Giving - donor.n - n#10025730
+0 ## Giving - endow.v - v#2201268
+0 ## Giving - hand_over.v - v#2293321
+0 ## Giving - give_out.v - v#2201644
+0 ## Giving - gift.v - v#2200686
+0 ## Giving - pass_out.v - v#2201644
+0 ## Mass_motion - hail.v - v#2759115
+0 ## Mass_motion - flock.v - v#2025353
+0 ## Mass_motion - stream.v - v#2028366
+0 ## Mass_motion - pelt.v - v#2758033
+0 ## Mass_motion - teem.v - v#2028366
+0 ## Mass_motion - throng.v - v#2064131
+0 ## Mass_motion - parade.v - v#1924505
+0 ## Mass_motion - flood.v - v#452220
+0 ## Mass_motion - swarm.v - v#2028366
+0 ## Mass_motion - troop.v - v#1924505
+0 ## Mass_motion - crowd.v - v#2027612
+0 ## Mass_motion - rain.v - v#2756558
+0 ## Mass_motion - shower.v - v#2757651
+0 ## Mass_motion - roll.v - v#1887020
+0 ## Mass_motion - pour.v - v#2028366
+0 ## Desirability - magnificent.a - a#1285376
+0 ## Desirability - cool.a - a#2529945
+0 ## Desirability - idyllic.a - a#1751465
+0 ## Desirability - awful.a - a#1126291
+0 ## Desirability - shitty.a - a#1127782
+0 ## Desirability - fantastic.a - a#1676517
+0 ## Desirability - top-notch.a - a#2341864
+0 ## Desirability - pitiful.a - a#1050890
+0 ## Desirability - outstanding.a - a#1278818
+0 ## Desirability - tremendous.a - a#1676517
+0 ## Desirability - terrific.a - a#1676517
+0 ## Desirability - astonishing.a - a#2359789
+0 ## Desirability - mediocre.a - a#2347564
+0 ## Desirability - desirable.a - a#732960
+0 ## Desirability - super.a - a#2341864
+0 ## Desirability - inferior.a - a#2345272
+0 ## Desirability - crappy.a - a#1127782
+0 ## Desirability - lame.a - a#2325304
+0 ## Desirability - fine.a - a#2081114
+0 ## Desirability - marvellous.a - a#1676517
+0 ## Desirability - popular.a - a#716370
+0 ## Desirability - bad.a - a#1125429
+0 ## Desirability - miserable.a - a#1050890
+0 ## Desirability - unfortunate.a - a#1049462
+0 ## Desirability - stupendous.a - a#1384730
+0 ## Desirability - execrable.a - a#2347086
+0 ## Desirability - fair.a - a#1673061
+0 ## Desirability - sensational.a - a#2101580
+0 ## Desirability - uncool.a - a#1129533
+0 ## Desirability - nasty.a - a#1587077
+0 ## Desirability - average.a - a#1673061
+0 ## Desirability - suck.v - v#1169704
+0 ## Desirability - amazing.a - a#2359789
+0 ## Desirability - extraordinary.a - a#1675190
+0 ## Desirability - excellence.n - n#4728786
+0 ## Desirability - appalling.a - a#193367
+0 ## Desirability - first-rate.a - a#2341864
+0 ## Desirability - horrible.a - a#193480
+0 ## Desirability - okay.a - a#2081114
+0 ## Desirability - rock.v - v#1875295
+0 ## Desirability - splendid.a - a#2343110
+0 ## Desirability - decent.a - a#1538311
+0 ## Desirability - superb.a - a#1125154
+0 ## Desirability - tolerable.a - a#2080937
+0 ## Desirability - third-rate.a - a#2348285
+0 ## Desirability - superlative.a - a#2343517
+0 ## Desirability - fabulous.a - a#645982
+0 ## Desirability - good.a - a#1123148
+0 ## Desirability - great.a - a#1386883
+0 ## Desirability - terrible.a - a#1126291
+0 ## Desirability - excellent.a - a#2343110
+0 ## Desirability - second-rate.a - a#2347564
+0 ## Desirability - sweet.a - a#2368336
+0 ## Desirability - rotten.a - a#1127782
+0 ## Desirability - wonderful.a - a#1676517
+0 ## Desirability - dreadful.a - a#1126291
+0 ## Desirability - so-so.a - a#1674604
+0 ## Desirability - astounding.a - a#645856
+0 ## Desirability - incredible.a - a#645493
+0 ## Desirability - substandard.a - a#2297409
+0 ## Desirability - pathetic.a - a#1050890
+0 ## Offering - proffer.v - v#2297142
+0 ## Offering - extend.v - v#2297948
+0 ## Offering - offer.v - v#2297142
+0 ## Reshaping - launch.v - v#1253363
+0 ## Reshaping - pulp.v - v#331713
+0 ## Reshaping - mold.v - v#1662771
+0 ## Reshaping - scrunch.v - v#1278427
+0 ## Reshaping - deform.v - v#140967
+0 ## Reshaping - dent.v - v#1279631
+0 ## Reshaping - curl.v - v#2098458
+0 ## Reshaping - mash.v - v#1593937
+0 ## Reshaping - bend.v - v#2035919
+0 ## Reshaping - crumple.v - v#1278817
+0 ## Reshaping - flatten.v - v#463778
+0 ## Reshaping - squash.v - v#1593937
+0 ## Reshaping - roll.v - v#143204
+0 ## Reshaping - fold.v - v#1277974
+0 ## Reshaping - shape.v - v#142191
+0 ## Reshaping - deformation.n - n#7433973
+0 ## Reshaping - squish.v - v#1921591
+0 ## Reshaping - warp.v - v#356954
+0 ## Reshaping - form.v - v#142191
+0 ## Reshaping - crush.v - v#1593937
+0 ## Satisfying - satisfy.v - v#2671880
+0 ## Strictness - tolerant.a - a#286837
+0 ## Strictness - liberal.a - a#286837
+0 ## Strictness - lenient.a - a#1763159
+0 ## Strictness - indulgent.a - a#1763159
+0 ## Strictness - authoritarian.a - a#787357
+0 ## Strictness - strict.a - a#2506267
+0 ## Compatibility - jibe.v - v#2657219
+0 ## Compatibility - accord.v - v#2700104
+0 ## Compatibility - agree.v - v#2657219
+0 ## Compatibility - square.v - v#2659541
+0 ## Compatibility - incompatibility.n - n#4714440
+0 ## Compatibility - conflicting.a - a#1662912
+0 ## Compatibility - consistent.a - a#576680
+0 ## Compatibility - dovetail.v - v#2660290
+0 ## Compatibility - consonant.a - a#577122
+0 ## Compatibility - rhyme.v - v#2750432
+0 ## Compatibility - cohere.v - v#1220885
+0 ## Compatibility - comport.v - v#2519666
+0 ## Compatibility - congruous.a - a#562116
+0 ## Compatibility - compatible.a - a#507464
+0 ## Compatibility - incompatible.a - a#508192
+0 ## Compatibility - go.v - v#1835496
+0 ## Compatibility - compatibility.n - n#4712735
+0 ## Compatibility - match.v - v#2657219
+0 ## Compatibility - harmonize.v - v#2700104
+0 ## Compatibility - congruent.a - a#562116
+0 ## Compatibility - clash.v - v#2667698
+0 ## Compatibility - harmony.n - n#13969243
+0 ## Compatibility - conflict.v - v#2667228
+0 ## Being_up_to_it - equal.a - a#51045
+0 ## Being_up_to_it - sufficient.a - a#2335828
+0 ## Temporal_collocation - current.a - a#666058
+0 ## Temporal_collocation - early.a - a#812952
+0 ## Temporal_collocation - now.adv - r#48475
+0 ## Temporal_collocation - at present.adv - r#49220
+0 ## Temporal_collocation - newly.adv - r#112601
+0 ## Temporal_collocation - ancient.a - a#1728614
+0 ## Temporal_collocation - prehistoric.a - a#1730909
+0 ## Temporal_collocation - nowadays.n - n#15119536
+0 ## Temporal_collocation - currently.adv - r#48268
+0 ## Temporal_collocation - ultimately.adv - r#47903
+0 ## Temporal_collocation - recently.adv - r#107416
+0 ## Temporal_collocation - today.n - n#15262921
+0 ## Temporal_collocation - then.adv - r#117620
+0 ## Temporal_collocation - modern.a - a#1535709
+0 ## Temporal_collocation - future.a - a#1732270
+0 ## Make_possible_to_do - allow.v - v#2423183
+0 ## Make_possible_to_do - permit.v - v#802318
+0 ## Make_possible_to_do - let.v - v#2423183
+0 ## Trial - trial.n - n#1195867
+0 ## Trial - case.n - n#1182654
+0 ## Praiseworthiness - meritorious.a - a#2586747
+0 ## Praiseworthiness - pitiable.a - a#905181
+0 ## Praiseworthiness - dishonorable.a - a#1227137
+0 ## Praiseworthiness - commendable.a - a#2585545
+0 ## Praiseworthiness - praiseworthy.a - a#2585545
+0 ## Praiseworthiness - lamentable.a - a#1126841
+0 ## Praiseworthiness - honorable.a - a#1983162
+0 ## Praiseworthiness - laudable.a - a#2585545
+0 ## Praiseworthiness - deplorable.a - a#1126841
+0 ## Praiseworthiness - execrable.a - a#1460679
+0 ## Praiseworthiness - reprehensible.a - a#2035765
+0 ## Praiseworthiness - detestable.a - a#1460679
+0 ## Praiseworthiness - creditable.a - a#2585919
+0 ## Praiseworthiness - admirable.a - a#904290
+0 ## Praiseworthiness - estimable.a - a#904163
+0 ## Praiseworthiness - abominable.a - a#1460679
+0 ## Praiseworthiness - blameworthy.a - a#1321529
+0 ## Praiseworthiness - despicable.a - a#1133017
+0 ## Extreme_point - high-water mark.n - n#8679167
+0 ## Extreme_point - zenith.n - n#8684769
+0 ## Extreme_point - nadir.n - n#8600760
+0 ## Extreme_point - high point.n - n#5868779
+0 ## Legality - wrong.a - a#2035337
+0 ## Legality - licit.a - a#1401224
+0 ## Legality - wrongful.a - a#1408421
+0 ## Legality - wrongly.adv - r#204125
+0 ## Legality - legal.a - a#1400562
+0 ## Legality - illegal.a - a#1401854
+0 ## Legality - prohibited.a - a#1402498
+0 ## Legality - permissible.a - a#1760944
+0 ## Legality - unlawful.a - a#1396047
+0 ## Legality - fair.a - a#956131
+0 ## Legality - illicit.a - a#1403760
+0 ## Legality - lawful.a - a#1401224
+0 ## Legality - legitimate.a - a#1401224
+0 ## Preliminaries - groundwork.n - n#5793554
+0 ## Preliminaries - preliminary.n - n#7457599
+0 ## Preliminaries - preparatory.a - a#126830
+0 ## Preliminaries - prefatory.a - a#126339
+0 ## Preliminaries - exploratory.a - a#877345
+0 ## Preliminaries - preliminary.a - a#878086
+0 ## Front_for - blind.n - n#2851384
+0 ## Front_for - front.v - v#2693319
+0 ## Front_for - front.n - n#10113583
+0 ## Probability - likelihood.n - n#4756635
+0 ## Probability - odds.n - n#4756504
+0 ## Probability - significance.n - n#5169813
+0 ## Probability - probability.n - n#5091770
+0 ## Probability - chance.n - n#5091770
+0 ## Suasion - persuade.v - v#2586121
+0 ## Suasion - dissuade.v - v#770141
+0 ## Suasion - sway.v - v#2586121
+0 ## Suasion - motivate.v - v#1649999
+0 ## Suasion - convince.v - v#769553
+0 ## Fighting_activity - free-for-all.n - n#1176431
+0 ## Fighting_activity - affray.n - n#1176335
+0 ## Fighting_activity - melee.n - n#554200
+0 ## Fighting_activity - fray.n - n#1176335
+0 ## Fighting_activity - fracas.n - n#7184545
+0 ## Bragging - vaunt.v - v#883226
+0 ## Bragging - preen.v - v#883847
+0 ## Bragging - boastful.a - a#1890752
+0 ## Bragging - boast.v - v#883226
+0 ## Bragging - braggart.n - n#9872066
+0 ## Bragging - gripe.v - v#910973
+0 ## Bragging - boast.n - n#7229530
+0 ## Bragging - brag.v - v#883226
+0 ## Bragging - rodomontade.n - n#7230089
+0 ## Theft - purloin.v - v#2276866
+0 ## Theft - misappropriate.v - v#2292535
+0 ## Theft - filch.v - v#2276866
+0 ## Theft - cop.v - v#2322230
+0 ## Theft - peculation.n - n#776732
+0 ## Theft - swipe.v - v#2276866
+0 ## Theft - snatch.v - v#1471043
+0 ## Theft - steal.v - v#2321757
+0 ## Theft - pilferage.n - n#781355
+0 ## Theft - pinch.v - v#2276866
+0 ## Theft - pilfer.v - v#2276866
+0 ## Theft - nick.v - v#1259141
+0 ## Theft - thieving.n - n#780889
+0 ## Theft - abstract.v - v#2276866
+0 ## Theft - flog.v - v#1411085
+0 ## Theft - snatch.n - n#775702
+0 ## Theft - embezzlement.n - n#776732
+0 ## Theft - rustle.v - v#2277138
+0 ## Theft - stealing.n - n#780889
+0 ## Theft - larceny.n - n#780889
+0 ## Theft - light-fingered.a - a#62740
+0 ## Theft - shoplifter.n - n#9866661
+0 ## Theft - shoplift.v - v#2277303
+0 ## Theft - cutpurse.n - n#10431907
+0 ## Theft - stealer.n - n#10707804
+0 ## Theft - lift.v - v#2276866
+0 ## Theft - embezzle.v - v#2292535
+0 ## Theft - pilferer.n - n#10616204
+0 ## Theft - theft.n - n#780889
+0 ## Theft - snitch.v - v#2322230
+0 ## Theft - heist.n - n#783063
+0 ## Theft - snatcher.n - n#10615929
+0 ## Theft - thieving.a - a#1225294
+0 ## Theft - shoplifting.n - n#781480
+0 ## Theft - embezzler.n - n#10051337
+0 ## Theft - kleptomaniac.n - n#10237799
+0 ## Theft - pickpocket.n - n#10431907
+0 ## Theft - thief.n - n#10707804
+0 ## Theft - misappropriation.n - n#776732
+0 ## Theft - thieve.v - v#2322230
+0 ## Left_to_do - remain.v - v#117985
+0 ## Left_to_do - left.a - a#926505
+0 ## Left_to_do - remainder.n - n#13733663
+0 ## Aiming - target.v - v#1150559
+0 ## Aiming - aim.v - v#1151110
+0 ## Aiming - target.n - n#10470460
+0 ## Aiming - aim.n - n#5981230
+0 ## Aiming - direct.v - v#1150559
+0 ## Revenge - sanction.n - n#6687358
+0 ## Revenge - retribution.n - n#1235463
+0 ## Revenge - payback.n - n#1235463
+0 ## Revenge - get_back_((at)).v - v#1153762
+0 ## Revenge - revenge.n - n#1235258
+0 ## Revenge - retaliation.n - n#1235258
+0 ## Revenge - get_even.v - v#1153762
+0 ## Revenge - vengeful.a - a#1041634
+0 ## Revenge - vengeance.n - n#1235463
+0 ## Revenge - vindictive.a - a#1041634
+0 ## Revenge - retributory.a - a#1903160
+0 ## Revenge - retaliate.v - v#1153486
+0 ## Revenge - avenger.n - n#9826074
+0 ## Revenge - revengeful.a - a#1041634
+0 ## Revenge - retributive.a - a#1903160
+0 ## Revenge - avenge.v - v#1153486
+0 ## Revenge - revenge.v - v#1153486
+0 ## Perception_body - ail.v - v#70816
+0 ## Perception_body - pain.v - v#70816
+0 ## Perception_body - prickle.v - v#2122983
+0 ## Perception_body - goosebump.n - n#866606
+0 ## Perception_body - tingle.v - v#2122983
+0 ## Perception_body - itch.v - v#2121188
+0 ## Perception_body - burn.v - v#2120451
+0 ## Perception_body - ache.v - v#2122164
+0 ## Perception_body - smart.v - v#2122164
+0 ## Perception_body - pain.n - n#14322699
+0 ## Perception_body - tickle.v - v#2120140
+0 ## Perception_body - spin.v - v#2046755
+0 ## Perception_body - sting.v - v#2120451
+0 ## Perception_body - hum.v - v#2706605
+0 ## Perception_body - hurt.v - v#2122164
+0 ## Namesake - namesake.n - n#10344922
+0 ## Namesake - eponymous.a - a#3036595
+0 ## Sequence - sequence.n - n#8459252
+0 ## Sequence - succession.n - n#1010458
+0 ## Sequence - successive.a - a#1667729
+0 ## Sequence - sequential.a - a#1667729
+0 ## Sequence - series.n - n#8457976
+0 ## Sequence - order.n - n#1009871
+0 ## Being_detached - unattached.a - a#160288
+0 ## Being_detached - detached.a - a#546155
+0 ## Being_detached - loose.a - a#503321
+0 ## Being_detached - disconnected.a - a#2293856
+0 ## Biological_urge - thirsty.a - a#888200
+0 ## Biological_urge - drowsiness.n - n#14030435
+0 ## Biological_urge - aroused.a - a#2131668
+0 ## Biological_urge - bilious.a - a#2543149
+0 ## Biological_urge - queasy.a - a#2545689
+0 ## Biological_urge - beat.a - a#2432154
+0 ## Biological_urge - parched.a - a#2551946
+0 ## Biological_urge - tired.a - a#2431728
+0 ## Biological_urge - nausea.n - n#14359952
+0 ## Biological_urge - amorous.a - a#1465061
+0 ## Biological_urge - somnolent.a - a#189253
+0 ## Biological_urge - drowsy.a - a#188436
+0 ## Biological_urge - fatigued.a - a#2433451
+0 ## Biological_urge - horny.a - a#2131668
+0 ## Biological_urge - somnolence.n - n#14030435
+0 ## Biological_urge - knackered.a - a#2434115
+0 ## Biological_urge - peckish.a - a#1269819
+0 ## Biological_urge - turned on.a - a#2131668
+0 ## Biological_urge - weariness.n - n#14016361
+0 ## Biological_urge - randy.a - a#2131668
+0 ## Biological_urge - weary.a - a#2432428
+0 ## Biological_urge - bushed.a - a#2432154
+0 ## Biological_urge - worn out.a - a#2433451
+0 ## Biological_urge - soporific.a - a#2309187
+0 ## Biological_urge - sick.a - a#2545689
+0 ## Biological_urge - sleepy.a - a#189017
+0 ## Biological_urge - queasiness.n - n#14360320
+0 ## Biological_urge - hungry.a - a#1269073
+0 ## Biological_urge - nauseous.a - a#2545689
+0 ## Biological_urge - hunger.n - n#4945254
+0 ## Biological_urge - exhausted.a - a#2433451
+0 ## Biological_urge - dog-tired.a - a#2433451
+0 ## Biological_urge - ravenous.a - a#1269506
+0 ## Biological_urge - arousal.n - n#14023997
+0 ## Biological_urge - fatigue.n - n#14016361
+0 ## Biological_urge - exhaustion.n - n#14017206
+0 ## Biological_urge - famished.a - a#1269506
+0 ## Biological_urge - sleepiness.n - n#14030435
+0 ## Biological_urge - tiredness.n - n#14016361
+0 ## Biological_urge - thirst.n - n#4945254
+0 ## Biological_urge - nauseated.a - a#2545689
+0 ## Biological_urge - enervated.a - a#2324944
+0 ## Operational_testing - testing.n - n#639975
+0 ## Operational_testing - test.n - n#1006675
+0 ## Operational_testing - test.v - v#2531625
+0 ## Gesture - signal.v - v#1039330
+0 ## Gesture - motion.v - v#992041
+0 ## Gesture - wave.v - v#1041415
+0 ## Gesture - beckon.v - v#1041415
+0 ## Gesture - signal.n - n#6791372
+0 ## Gesture - nod.v - v#898434
+0 ## Gesture - gesticulate.v - v#992041
+0 ## Gesture - gesture.v - v#992041
+0 ## Experiencer_focus - scared.a - a#79629
+0 ## Experiencer_focus - calm.a - a#529657
+0 ## Experiencer_focus - nervous.a - a#2406908
+0 ## Experiencer_focus - pleasure.n - n#7490713
+0 ## Experiencer_focus - fulfillment.n - n#7532112
+0 ## Experiencer_focus - mourn.v - v#1797051
+0 ## Experiencer_focus - rue.v - v#1796582
+0 ## Experiencer_focus - adore.v - v#1777817
+0 ## Experiencer_focus - hate.v - v#1774136
+0 ## Experiencer_focus - intimidated.a - a#252733
+0 ## Experiencer_focus - irritated.a - a#1806106
+0 ## Experiencer_focus - worked up.a - a#85630
+0 ## Experiencer_focus - comfort.n - n#7492516
+0 ## Experiencer_focus - grief-stricken.a - a#1364817
+0 ## Experiencer_focus - fulfilled.a - a#552089
+0 ## Experiencer_focus - interested.a - a#1342237
+0 ## Experiencer_focus - fear.v - v#1780202
+0 ## Experiencer_focus - abhor.v - v#1774426
+0 ## Experiencer_focus - luxuriate.v - v#1191645
+0 ## Experiencer_focus - cool.a - a#2531422
+0 ## Experiencer_focus - empathetic.a - a#2375639
+0 ## Experiencer_focus - pity.n - n#4829550
+0 ## Experiencer_focus - nettled.a - a#1806106
+0 ## Experiencer_focus - dislike.n - n#7501545
+0 ## Experiencer_focus - taken.a - a#1378671
+0 ## Experiencer_focus - worried.a - a#2457167
+0 ## Experiencer_focus - terrified.a - a#80357
+0 ## Experiencer_focus - detest.v - v#1774136
+0 ## Experiencer_focus - happily.adv - r#50297
+0 ## Experiencer_focus - agape.a - a#1654582
+0 ## Experiencer_focus - afraid.a - a#77645
+0 ## Experiencer_focus - compassion.n - n#4829550
+0 ## Experiencer_focus - apprehensive.a - a#79069
+0 ## Experiencer_focus - loathe.v - v#1774426
+0 ## Experiencer_focus - dread.v - v#1780202
+0 ## Experiencer_focus - fazed.a - a#532147
+0 ## Experiencer_focus - fed up.a - a#1806677
+0 ## Experiencer_focus - like.v - v#1777210
+0 ## Experiencer_focus - dissatisfied.a - a#590163
+0 ## Experiencer_focus - empathy.n - n#7554856
+0 ## Experiencer_focus - loathing.n - n#7503430
+0 ## Experiencer_focus - abominate.v - v#1774426
+0 ## Experiencer_focus - savour.v - v#1820302
+0 ## Experiencer_focus - adoration.n - n#7501420
+0 ## Experiencer_focus - pity.v - v#1821996
+0 ## Experiencer_focus - delight.v - v#1815628
+0 ## Experiencer_focus - enjoy.v - v#1820302
+0 ## Experiencer_focus - love.v - v#1828736
+0 ## Experiencer_focus - dread.n - n#7521674
+0 ## Experiencer_focus - satisfaction.n - n#7531255
+0 ## Experiencer_focus - fond.a - a#1464700
+0 ## Experiencer_focus - abhorrence.n - n#7503430
+0 ## Experiencer_focus - resent.v - v#1773346
+0 ## Experiencer_focus - grieve.v - v#1797347
+0 ## Experiencer_focus - empathize.v - v#594058
+0 ## Experiencer_focus - feverish.a - a#86210
+0 ## Experiencer_focus - hatred.n - n#7546465
+0 ## Experiencer_focus - antipathy.n - n#7502669
+0 ## Experiencer_focus - regret.v - v#1796582
+0 ## Experiencer_focus - envy.n - n#7549716
+0 ## Experiencer_focus - envy.v - v#1827619
+0 ## Experiencer_focus - feverishly.adv - r#141485
+0 ## Experiencer_focus - desperation.n - n#14486274
+0 ## Experiencer_focus - relish.v - v#1820302
+0 ## Experiencer_focus - dislike.v - v#1776727
+0 ## Experiencer_focus - enjoyment.n - n#7491708
+0 ## Experiencer_focus - despair.v - v#1810933
+0 ## Experiencer_focus - satisfied.a - a#589344
+0 ## Experiencer_focus - relish.n - n#7491981
+0 ## Experiencer_focus - resentment.n - n#7548978
+0 ## Experiencer_focus - despise.v - v#1774799
+0 ## Experiencer_focus - regret.n - n#7535670
+0 ## Experiencer_focus - upset.a - a#2457167
+0 ## Experiencer_focus - rueful.a - a#1743506
+0 ## Experiencer_focus - solace.n - n#7492655
+0 ## Experiencer_focus - detestation.n - n#7503430
+0 ## Inchoative_attaching - stick.v - v#1220885
+0 ## Inchoative_attaching - bind.v - v#1356750
+0 ## Inchoative_attaching - attach.v - v#1290422
+0 ## Inchoative_attaching - fasten.v - v#1340439
+0 ## Inchoative_attaching - take hold.v - v#1216670
+0 ## Inchoative_attaching - moor.v - v#1305099
+0 ## Inchoative_attaching - agglutinate.v - v#1222016
+0 ## Buildings - maisonette.n - n#3713254
+0 ## Buildings - lodge.n - n#3685640
+0 ## Buildings - lighthouse.n - n#2814860
+0 ## Buildings - condominium.n - n#3088389
+0 ## Buildings - shed.n - n#4187547
+0 ## Buildings - cottage.n - n#2919792
+0 ## Buildings - dacha.n - n#3158186
+0 ## Buildings - tepee.n - n#4412416
+0 ## Buildings - fortress.n - n#3386011
+0 ## Buildings - wigwam.n - n#4584373
+0 ## Buildings - kennel.n - n#3610524
+0 ## Buildings - rotunda.n - n#4112654
+0 ## Buildings - synagogue.n - n#4374735
+0 ## Buildings - chateau.n - n#3010915
+0 ## Buildings - kiosk.n - n#2873839
+0 ## Buildings - disco.n - n#3206282
+0 ## Buildings - temple.n - n#4374735
+0 ## Buildings - citadel.n - n#2806088
+0 ## Buildings - hippodrome.n - n#3522003
+0 ## Buildings - library.n - n#3661043
+0 ## Buildings - cabin.n - n#2932400
+0 ## Buildings - inn.n - n#3541696
+0 ## Buildings - igloo.n - n#3560430
+0 ## Buildings - bunker.n - n#2920658
+0 ## Buildings - greenhouse.n - n#3457902
+0 ## Buildings - hovel.n - n#3547054
+0 ## Buildings - outbuilding.n - n#3859280
+0 ## Buildings - manor.n - n#3718458
+0 ## Buildings - caravanserai.n - n#2961035
+0 ## Buildings - hall.n - n#3719053
+0 ## Buildings - building.n - n#2913152
+0 ## Buildings - supermarket.n - n#4358707
+0 ## Buildings - castle.n - n#3878066
+0 ## Buildings - gazebo.n - n#3430418
+0 ## Buildings - pub.n - n#4018399
+0 ## Buildings - basilica.n - n#2801184
+0 ## Buildings - manse.n - n#3719053
+0 ## Buildings - skyscraper.n - n#4233124
+0 ## Buildings - fort.n - n#3386011
+0 ## Buildings - villa.n - n#4535370
+0 ## Buildings - chalet.n - n#3002816
+0 ## Buildings - monastery.n - n#3781244
+0 ## Buildings - discotheque.n - n#3206282
+0 ## Buildings - pueblo.n - n#8673273
+0 ## Buildings - tavern.n - n#4395875
+0 ## Buildings - house.n - n#3544360
+0 ## Buildings - hangar.n - n#2687821
+0 ## Buildings - warehouse.n - n#4551055
+0 ## Buildings - auditorium.n - n#2758134
+0 ## Buildings - tenement.n - n#4409384
+0 ## Buildings - pagoda.n - n#3874965
+0 ## Buildings - structure.n - n#4341686
+0 ## Buildings - residence.n - n#3719053
+0 ## Buildings - outhouse.n - n#3860404
+0 ## Buildings - tower.n - n#4460130
+0 ## Buildings - hostel.n - n#3541696
+0 ## Buildings - shanty.n - n#3547054
+0 ## Buildings - bungalow.n - n#2919792
+0 ## Buildings - fortification.n - n#3385557
+0 ## Buildings - church.n - n#3028079
+0 ## Buildings - tabernacle.n - n#4374735
+0 ## Buildings - campanile.n - n#2946127
+0 ## Buildings - pavilion.n - n#3900979
+0 ## Buildings - shelter.n - n#4191595
+0 ## Buildings - housing.n - n#3546340
+0 ## Buildings - pyramid.n - n#4029125
+0 ## Buildings - terminal.n - n#4412901
+0 ## Buildings - mall.n - n#3965456
+0 ## Buildings - theatre.n - n#4417809
+0 ## Buildings - hotel.n - n#3542333
+0 ## Buildings - palace.n - n#3878066
+0 ## Buildings - homestead.n - n#3529629
+0 ## Buildings - shack.n - n#3547054
+0 ## Buildings - dwelling.n - n#3259505
+0 ## Buildings - mosque.n - n#3788195
+0 ## Buildings - houseboat.n - n#3545470
+0 ## Buildings - farmhouse.n - n#3322836
+0 ## Buildings - airport.n - n#2692232
+0 ## Buildings - dormitory.n - n#3224893
+0 ## Buildings - bar.n - n#2796995
+0 ## Buildings - hospital.n - n#3540595
+0 ## Buildings - tent.n - n#4411264
+0 ## Buildings - blockhouse.n - n#2854378
+0 ## Buildings - acropolis.n - n#2676938
+0 ## Buildings - home.n - n#3259505
+0 ## Buildings - city hall.n - n#3036022
+0 ## Buildings - stadium.n - n#4295881
+0 ## Buildings - caravan.n - n#4520382
+0 ## Buildings - stable.n - n#4294879
+0 ## Buildings - arena.n - n#4295881
+0 ## Buildings - pension.n - n#13384164
+0 ## Buildings - mansion.n - n#3719053
+0 ## Buildings - garage.n - n#3416489
+0 ## Buildings - motel.n - n#3788498
+0 ## Buildings - conservatory.n - n#3092166
+0 ## Buildings - hacienda.n - n#3474352
+0 ## Buildings - penthouse.n - n#3912821
+0 ## Buildings - barn.n - n#2793495
+0 ## Buildings - shebang.n - n#8436452
+0 ## Sufficiency - adequate.a - a#2336109
+0 ## Sufficiency - insufficiently.adv - r#145854
+0 ## Sufficiency - suffice.v - v#2669789
+0 ## Sufficiency - insufficiency.n - n#14463471
+0 ## Sufficiency - enough.adv - r#145713
+0 ## Sufficiency - too.adv - r#47392
+0 ## Sufficiency - inadequately.adv - r#369869
+0 ## Sufficiency - enough.n - n#13580415
+0 ## Sufficiency - inadequate.a - a#51696
+0 ## Sufficiency - so.adv - r#146594
+0 ## Sufficiency - sufficiently.adv - r#145571
+0 ## Sufficiency - adequacy.n - n#4792357
+0 ## Sufficiency - plenty.adv - r#145713
+0 ## Sufficiency - enough.a - a#2336109
+0 ## Sufficiency - plenty.n - n#13774404
+0 ## Sufficiency - insufficient.a - a#2336449
+0 ## Sufficiency - inadequacy.n - n#5113133
+0 ## Sufficiency - sufficient.a - a#2335828
+0 ## Sufficiency - ample.a - a#105746
+0 ## Sufficiency - adequately.adv - r#369718
+0 ## Grant_permission - restrict.v - v#236592
+0 ## Grant_permission - authorize.v - v#803325
+0 ## Grant_permission - permission.n - n#6689297
+0 ## Grant_permission - accept.v - v#797697
+0 ## Grant_permission - clear.v - v#803325
+0 ## Grant_permission - okay.v - v#806502
+0 ## Grant_permission - mandate.n - n#6556481
+0 ## Grant_permission - let.v - v#802318
+0 ## Grant_permission - allow.v - v#802318
+0 ## Grant_permission - leave.n - n#6690114
+0 ## Grant_permission - permit.v - v#802318
+0 ## Grant_permission - sanction.v - v#806502
+0 ## Grant_permission - approval.n - n#6686736
+0 ## Grant_permission - suffer.v - v#668099
+0 ## Grant_permission - approve.v - v#806502
+0 ## Entity - item.n - n#3588414
+0 ## Entity - entity.n - n#1740
+0 ## Criminal_investigation - lead.n - n#5826914
+0 ## Criminal_investigation - investigate.v - v#785962
+0 ## Criminal_investigation - probe.n - n#5800611
+0 ## Criminal_investigation - probe.v - v#788564
+0 ## Criminal_investigation - inquire.v - v#785962
+0 ## Criminal_investigation - inquiry.n - n#5797597
+0 ## Criminal_investigation - investigation.n - n#633864
+0 ## Criminal_investigation - clue.n - n#6643763
+0 ## Cause_impact - smack.v - v#1414916
+0 ## Cause_impact - crash.v - v#1561819
+0 ## Cause_impact - thump.v - v#1414626
+0 ## Cause_impact - plough.v - v#2096853
+0 ## Cause_impact - thud.v - v#1238204
+0 ## Cause_impact - clink.v - v#2186690
+0 ## Cause_impact - strike.v - v#1410223
+0 ## Cause_impact - graze.v - v#1576165
+0 ## Cause_impact - clash.v - v#1561143
+0 ## Cause_impact - click.v - v#1893771
+0 ## Cause_impact - slam.v - v#1242391
+0 ## Cause_impact - bang.v - v#1242391
+0 ## Cause_impact - collide.v - v#1561143
+0 ## Cause_impact - clatter.v - v#2172127
+0 ## Cause_impact - jab.v - v#1230555
+0 ## Cause_impact - run.v - v#1926311
+0 ## Cause_impact - clang.v - v#2174115
+0 ## Cause_impact - slap.v - v#1416871
+0 ## Cause_impact - rustle.v - v#2182662
+0 ## Cause_impact - rap.v - v#1414288
+0 ## Cause_impact - ram.v - v#1561819
+0 ## Cause_impact - rattle.v - v#2175057
+0 ## Cause_impact - hit.v - v#1400044
+0 ## Encoding - wording.n - n#7081739
+0 ## Encoding - phrasing.n - n#7081739
+0 ## Encoding - frame.v - v#981276
+0 ## Encoding - phrase.v - v#980453
+0 ## Encoding - word.v - v#980453
+0 ## Encoding - formulate.v - v#980453
+0 ## Encoding - express.v - v#943837
+0 ## Encoding - cast.v - v#981276
+0 ## Encoding - expression.n - n#7069948
+0 ## Encoding - put.v - v#981276
+0 ## Encoding - formulation.n - n#7069948
+0 ## Encoding - couch.v - v#981276
+0 ## Creating - generate.v - v#1629000
+0 ## Creating - production.n - n#4007894
+0 ## Creating - formation.n - n#237078
+0 ## Creating - yield.v - v#1629000
+0 ## Creating - assemble.v - v#1656788
+0 ## Creating - create.v - v#1617192
+0 ## Creating - issuance.n - n#1060234
+0 ## Creating - issue.v - v#1064799
+0 ## Creating - form.v - v#2448185
+0 ## Creating - produce.v - v#1621555
+0 ## Evoking - evocative.a - a#1977669
+0 ## Evoking - conjure.v - v#1629958
+0 ## Evoking - evoke.v - v#1629958
+0 ## Evoking - evocation.n - n#5978623
+0 ## Evoking - remind.v - v#610538
+0 ## Evoking - recall.v - v#607780
+0 ## Evoking - reminder.n - n#6506757
+0 ## Measure_duration - minute.n - n#15234764
+0 ## Measure_duration - millennium.n - n#15141213
+0 ## Measure_duration - second.n - n#15235126
+0 ## Measure_duration - time.n - n#15122231
+0 ## Measure_duration - hour.n - n#15227846
+0 ## Measure_duration - fortnight.n - n#15170331
+0 ## Measure_duration - month.n - n#15206296
+0 ## Measure_duration - decade.n - n#15204983
+0 ## Measure_duration - year.n - n#15203791
+0 ## Measure_duration - day.n - n#15155220
+0 ## Measure_duration - week.n - n#15169873
+0 ## Measure_duration - nanosecond.n - n#15236015
+0 ## Measure_duration - century.n - n#15205532
+0 ## Rising_to_a_challenge - rise.v - v#1155545
+0 ## Completeness - incomplete.a - a#523978
+0 ## Completeness - completeness.n - n#14460974
+0 ## Completeness - full.a - a#522885
+0 ## Completeness - complete.a - a#520214
+0 ## Completeness - total.a - a#522885
+0 ## Measure_volume - carload.n - n#13775523
+0 ## Measure_volume - boatload.n - n#13775523
+0 ## Measure_volume - bottle.n - n#2876657
+0 ## Measure_volume - platter.n - n#3963198
+0 ## Measure_volume - tankful.n - n#13770529
+0 ## Measure_volume - bowl.n - n#2881193
+0 ## Measure_volume - bag.n - n#2773037
+0 ## Measure_volume - pint.n - n#13621850
+0 ## Measure_volume - scoopful.n - n#13769317
+0 ## Measure_volume - pack.n - n#13775093
+0 ## Measure_volume - glass.n - n#3438257
+0 ## Measure_volume - cup.n - n#7930864
+0 ## Measure_volume - can.n - n#2946921
+0 ## Measure_volume - teaspoon.n - n#13770729
+0 ## Measure_volume - spoon.n - n#4284002
+0 ## Measure_volume - gallon.n - n#13619764
+0 ## Measure_volume - bushel.n - n#13622591
+0 ## Measure_volume - scoop.n - n#13769317
+0 ## Measure_volume - mug.n - n#3797390
+0 ## Measure_volume - busload.n - n#13765866
+0 ## Measure_volume - trainload.n - n#13772876
+0 ## Measure_volume - box.n - n#2883344
+0 ## Measure_volume - bucketful.n - n#13765749
+0 ## Measure_volume - quart.n - n#13622035
+0 ## Measure_volume - roomful.n - n#13769123
+0 ## Measure_volume - spoonful.n - n#13770169
+0 ## Measure_volume - litre.n - n#13624190
+0 ## Measure_volume - sackful.n - n#13769206
+0 ## Measure_volume - bagful.n - n#13764639
+0 ## Measure_volume - barrel.n - n#13619920
+0 ## Measure_volume - jug.n - n#3603722
+0 ## Measure_volume - boxful.n - n#13765624
+0 ## Measure_volume - tray.n - n#4476259
+0 ## Measure_volume - tablespoon.n - n#4381073
+0 ## Measure_volume - teaspoonful.n - n#13770729
+0 ## Measure_volume - packet.n - n#8008017
+0 ## Studying - study.v - v#644583
+0 ## Dough_rising - rise.v - v#1983134
+0 ## Dough_rising - prove.v - v#1983134
+0 ## Preserving - preservation.n - n#7419599
+0 ## Preserving - salt.v - v#213353
+0 ## Preserving - pickle.v - v#213223
+0 ## Preserving - embalm.v - v#2226981
+0 ## Preserving - mummification.n - n#820583
+0 ## Preserving - dry.v - v#218475
+0 ## Preserving - preserve.v - v#212414
+0 ## Preserving - can.v - v#213794
+0 ## Preserving - mummify.v - v#2227127
+0 ## Preserving - cure.v - v#527572
+0 ## Arraignment - arraign.v - v#2497992
+0 ## Arraignment - arraignment.n - n#7235936
+0 ## Annoyance - annoyed.a - a#1806106
+0 ## Annoyance - irritated.a - a#1806106
+0 ## Annoyance - frustrated.a - a#2333976
+0 ## Change_of_quantity_of_possession - gain.v - v#157462
+0 ## Change_of_quantity_of_possession - lose.v - v#2287789
+0 ## Ambient_temperature - warm.a - a#2529264
+0 ## Ambient_temperature - hot.a - a#1247240
+0 ## Ambient_temperature - cold.n - n#5015117
+0 ## Ambient_temperature - temperature.n - n#5011790
+0 ## Ambient_temperature - scorcher.n - n#11466834
+0 ## Ambient_temperature - cold.a - a#1251128
+0 ## Ambient_temperature - chilly.a - a#1252566
+0 ## Ambient_temperature - cool.a - a#2529945
+0 ## Grooming - manicure.n - n#660783
+0 ## Grooming - pedicure.n - n#660957
+0 ## Grooming - soap.v - v#36932
+0 ## Grooming - lave.v - v#36362
+0 ## Grooming - moisturize.v - v#215800
+0 ## Grooming - comb.v - v#38365
+0 ## Grooming - floss.v - v#41866
+0 ## Grooming - groom.v - v#40353
+0 ## Grooming - wax.v - v#1268726
+0 ## Grooming - pluck.v - v#1592456
+0 ## Grooming - bathe.v - v#35603
+0 ## Grooming - shave.v - v#37298
+0 ## Grooming - ablution.n - n#255450
+0 ## Grooming - brush_((teeth)).v - v#1243809
+0 ## Grooming - shower.v - v#35259
+0 ## Grooming - plait.v - v#1674717
+0 ## Grooming - wash.v - v#36362
+0 ## Grooming - file.v - v#1001857
+0 ## Grooming - shampoo.v - v#42017
+0 ## Grooming - manicure.v - v#42479
+0 ## Grooming - cleanse.v - v#35758
+0 ## Grooming - brush_((hair)).v - v#1243809
+0 ## Grooming - facial.n - n#665781
+0 ## History - history.n - n#6514093
+0 ## Make_cognitive_connection - link.v - v#713167
+0 ## Make_cognitive_connection - linked.a - a#567161
+0 ## Make_cognitive_connection - connection.n - n#14419164
+0 ## Make_cognitive_connection - link.n - n#3673971
+0 ## Make_cognitive_connection - tie.n - n#3673971
+0 ## Make_cognitive_connection - connect.v - v#713167
+0 ## Make_cognitive_connection - tie.v - v#1354673
+0 ## Losing_track_of_perceiver - lose.v - v#2287789
+0 ## Opportunity - opportunity.n - n#14483917
+0 ## Opportunity - break.n - n#7367812
+0 ## Opportunity - chance.n - n#14483917
+0 ## Opportunity - opportune.a - a#1660994
+0 ## Timespan - time.n - n#7309599
+0 ## Timespan - day.n - n#15155220
+0 ## Rest - complement.n - n#14736201
+0 ## Rest - rest.n - n#13810818
+0 ## Rest - complement.v - v#455919
+0 ## Sounds - clatter.n - n#7380473
+0 ## Sounds - hoot.n - n#7123870
+0 ## Sounds - chatter.n - n#7378952
+0 ## Sounds - click.n - n#7379223
+0 ## Sounds - whistle.n - n#7400156
+0 ## Sounds - caw.n - n#7378682
+0 ## Sounds - buzz.n - n#7378234
+0 ## Sounds - yap.n - n#5302307
+0 ## Sounds - blast.n - n#7376257
+0 ## Sounds - toll.n - n#7377244
+0 ## Sounds - squawk.n - n#7395446
+0 ## Sounds - bark.n - n#7376621
+0 ## Sounds - snort.n - n#7123870
+0 ## Sounds - sound.n - n#7371293
+0 ## Sounds - plash.n - n#7395104
+0 ## Sounds - slap.n - n#133668
+0 ## Sounds - sizzle.n - n#7393919
+0 ## Sounds - hiss.n - n#7123870
+0 ## Sounds - snigger.n - n#7128060
+0 ## Sounds - screech.n - n#7393161
+0 ## Sounds - rap.n - n#7388987
+0 ## Sounds - neigh.n - n#7387316
+0 ## Sounds - clang.n - n#7380144
+0 ## Sounds - grunt.n - n#7384614
+0 ## Sounds - boom.n - n#7377682
+0 ## Sounds - gasp.n - n#837098
+0 ## Sounds - whine.n - n#7211752
+0 ## Sounds - babble.n - n#6610143
+0 ## Sounds - tinkle.n - n#7398097
+0 ## Sounds - patter.n - n#7389170
+0 ## Sounds - yodel.n - n#7123710
+0 ## Sounds - mew.n - n#7386614
+0 ## Sounds - clink.n - n#7379223
+0 ## Sounds - plunk.n - n#7390307
+0 ## Sounds - squeak.n - n#7395623
+0 ## Sounds - sob.n - n#868669
+0 ## Sounds - cackle.n - n#7136940
+0 ## Sounds - whinny.n - n#7387316
+0 ## Sounds - chuckle.n - n#7127563
+0 ## Sounds - bleat.n - n#7377931
+0 ## Sounds - plop.n - n#7390049
+0 ## Sounds - drone.n - n#2207179
+0 ## Sounds - rustle.n - n#7392783
+0 ## Sounds - wail.n - n#7211950
+0 ## Sounds - gurgle.n - n#7384741
+0 ## Sounds - cough.n - n#14359174
+0 ## Sounds - twitter.n - n#7379577
+0 ## Sounds - yelp.n - n#7400552
+0 ## Sounds - crunch.n - n#7382414
+0 ## Sounds - coo.n - n#7381329
+0 ## Sounds - titter.n - n#7128225
+0 ## Sounds - thump.n - n#7396945
+0 ## Sounds - growl.n - n#7384473
+0 ## Sounds - clack.n - n#7379963
+0 ## Sounds - moan.n - n#7126383
+0 ## Sounds - roar.n - n#7377682
+0 ## Sounds - rasp.n - n#7130774
+0 ## Sounds - howl.n - n#7385367
+0 ## Sounds - smack.n - n#7410745
+0 ## Sounds - hum.n - n#7385803
+0 ## Sounds - bray.n - n#7378059
+0 ## Sounds - peep.n - n#7379094
+0 ## Sounds - noise.n - n#7387509
+0 ## Sounds - scrape.n - n#7392982
+0 ## Sounds - cheep.n - n#7379094
+0 ## Sounds - quack.n - n#7390762
+0 ## Sounds - snore.n - n#835976
+0 ## Sounds - thunder.n - n#7397355
+0 ## Sounds - purr.n - n#7390645
+0 ## Sounds - chirp.n - n#7379409
+0 ## Sounds - beep.n - n#7377082
+0 ## Sounds - giggle.n - n#7127693
+0 ## Sounds - creak.n - n#7381864
+0 ## Sounds - squeal.n - n#7395777
+0 ## Sounds - scrunch.n - n#7393500
+0 ## Sounds - blare.n - n#7377473
+0 ## Sounds - trumpet.n - n#3110669
+0 ## Sounds - guffaw.n - n#7127790
+0 ## Sounds - whimper.n - n#7211752
+0 ## Sounds - peal.n - n#7389330
+0 ## Sounds - snarl.n - n#7129758
+0 ## Sounds - clash.n - n#7380144
+0 ## Sounds - yowl.n - n#7121361
+0 ## Sounds - tweet.n - n#7399027
+0 ## Sounds - bellow.n - n#7121361
+0 ## Sounds - bang.n - n#7376257
+0 ## Change_resistance - bulwark.v - v#1128071
+0 ## Change_resistance - brace.v - v#1219993
+0 ## Change_resistance - buttress.v - v#222728
+0 ## Smuggling - smuggler.n - n#10615334
+0 ## Smuggling - contraband.a - a#1402580
+0 ## Smuggling - smuggle.v - v#2345856
+0 ## Smuggling - smuggling.n - n#1112132
+0 ## Smuggling - contraband.n - n#3096273
+0 ## Non-commutative_process - subtract.v - v#641252
+0 ## Non-commutative_process - take away.v - v#1434278
+0 ## Non-commutative_process - division.n - n#385791
+0 ## Non-commutative_process - divide.v - v#642098
+0 ## Non-commutative_process - subtraction.n - n#871862
+0 ## Abounding_with - throng.v - v#2064131
+0 ## Abounding_with - brimming.a - a#1084091
+0 ## Abounding_with - jammed.a - a#560100
+0 ## Abounding_with - teeming.a - a#16350
+0 ## Abounding_with - teem.v - v#2714974
+0 ## Abounding_with - coated.a - a#1699095
+0 ## Abounding_with - brushed.a - a#2445207
+0 ## Abounding_with - chock-full.a - a#1084297
+0 ## Abounding_with - crawl.v - v#2716048
+0 ## Abounding_with - blanketed.a - a#1695269
+0 ## Abounding_with - thronged.a - a#560284
+0 ## Abounding_with - swarm.v - v#2028366
+0 ## Abounding_with - decorated.a - a#56002
+0 ## Abounding_with - dotted.a - a#1788445
+0 ## Abounding_with - filled.a - a#1084644
+0 ## Abounding_with - studded.a - a#59782
+0 ## Abounding_with - cloaked.a - a#1695505
+0 ## Abounding_with - plastered.a - a#1697129
+0 ## Abounding_with - rife.a - a#1066787
+0 ## Abounding_with - draped.a - a#1695505
+0 ## Abounding_with - replete.a - a#2300501
+0 ## Abounding_with - covered.a - a#1694223
+0 ## Abounding_with - varnished.a - a#1713713
+0 ## Abounding_with - splattered.a - a#1695891
+0 ## Abounding_with - adorned.a - a#56002
+0 ## Abounding_with - gilded.a - a#1528730
+0 ## Abounding_with - crowded.a - a#559690
+0 ## Abounding_with - painted.a - a#1713373
+0 ## Abounding_with - glazed.a - a#1699652
+0 ## Abounding_with - full.a - a#1083157
+0 ## Abounding_with - paved.a - a#1739693
+0 ## Abounding_with - spattered.a - a#1695891
+0 ## Abounding_with - tiled.a - a#1698103
+0 ## Abounding_with - stuffed.a - a#1086118
+0 ## Abounding_with - lined.a - a#258797
+0 ## Suitability - suited.a - a#1020885
+0 ## Suitability - unsuitable.a - a#1021607
+0 ## Suitability - fit.a - a#1020393
+0 ## Suitability - correct.a - a#631391
+0 ## Suitability - right.a - a#631391
+0 ## Suitability - suitable.a - a#1020885
+0 ## Suitability - suitability.n - n#4715487
+0 ## Suitability - fit.v - v#456740
+0 ## Suitability - unsuitability.n - n#4721058
+0 ## Suitability - suitableness.n - n#4715487
+0 ## Suitability - unsuitableness.n - n#4721058
+0 ## Suitability - suit.v - v#2702830
+0 ## Suitability - proper.a - a#1878466
+0 ## Suitability - fitting.a - a#1879667
+0 ## Path_shape - windy.a - a#305225
+0 ## Path_shape - crest.v - v#2693168
+0 ## Path_shape - pass.v - v#2050132
+0 ## Path_shape - cross.v - v#1912159
+0 ## Path_shape - round.v - v#1858910
+0 ## Path_shape - twisty.a - a#2313784
+0 ## Path_shape - veer.v - v#2033295
+0 ## Path_shape - zigzag.v - v#1991744
+0 ## Path_shape - emerge.v - v#1990694
+0 ## Path_shape - emergence.n - n#50693
+0 ## Path_shape - bend.v - v#2035919
+0 ## Path_shape - slant.v - v#2038357
+0 ## Path_shape - reach.v - v#2020590
+0 ## Path_shape - twist.v - v#2738701
+0 ## Path_shape - snake.v - v#1883210
+0 ## Path_shape - descend.v - v#1970826
+0 ## Path_shape - rise.v - v#1990281
+0 ## Path_shape - leave.v - v#2009433
+0 ## Path_shape - descent.n - n#326440
+0 ## Path_shape - swing.v - v#1877620
+0 ## Path_shape - twisting.a - a#2313784
+0 ## Path_shape - swerve.v - v#2033295
+0 ## Path_shape - enter.v - v#2016523
+0 ## Path_shape - skirt.v - v#2052090
+0 ## Path_shape - wind.v - v#1882814
+0 ## Path_shape - winding.a - a#2313784
+0 ## Path_shape - ford.v - v#1913849
+0 ## Path_shape - weave.v - v#1882814
+0 ## Path_shape - dive.v - v#1967373
+0 ## Path_shape - ascend.v - v#1969216
+0 ## Path_shape - crisscross.v - v#1913237
+0 ## Path_shape - bear.v - v#56930
+0 ## Path_shape - ascent.n - n#9206985
+0 ## Path_shape - exit.v - v#2015598
+0 ## Path_shape - drop.v - v#1976841
+0 ## Path_shape - traverse.v - v#1912159
+0 ## Path_shape - angle.v - v#2038357
+0 ## Path_shape - edge.v - v#2072501
+0 ## Path_shape - undulate.v - v#1901783
+0 ## Path_shape - meander.v - v#1882814
+0 ## Path_shape - dip.v - v#2038145
+0 ## First_experience - first.adv - r#103554
+0 ## Social_connection - tie.n - n#3673971
+0 ## Social_connection - linked.a - a#567161
+0 ## Social_connection - intimate.a - a#453308
+0 ## Social_connection - close.a - a#451510
+0 ## Social_connection - closeness.n - n#7530124
+0 ## Social_connection - connection.n - n#13791389
+0 ## Social_connection - bond.n - n#11436283
+0 ## Social_connection - intimate_((setting)).a - a#453308
+0 ## Social_connection - connected.a - a#566099
+0 ## Recording - register.v - v#2471690
+0 ## Recording - chronicle.v - v#1001136
+0 ## Recording - document.v - v#1002297
+0 ## Recording - record.v - v#1000214
+0 ## Recovery - recovery.n - n#13452347
+0 ## Recovery - recover.v - v#92690
+0 ## Recovery - convalescence.n - n#13452347
+0 ## Recovery - convalesce.v - v#92690
+0 ## Recovery - recuperate.v - v#92690
+0 ## Recovery - recuperation.n - n#13452347
+0 ## Recovery - perk up.v - v#23473
+0 ## Recovery - heal.v - v#81725
+0 ## Supporting - buttress.v - v#222728
+0 ## Supporting - support.v - v#1217043
+0 ## Supporting - bolster.v - v#223374
+0 ## Evidence - disprove.v - v#667424
+0 ## Evidence - verify.v - v#664483
+0 ## Evidence - confirm.v - v#665886
+0 ## Evidence - imply.v - v#930599
+0 ## Evidence - credence_((lend)).n - n#6193727
+0 ## Evidence - evidence.v - v#820976
+0 ## Evidence - attest.v - v#820976
+0 ## Evidence - substantiate.v - v#665886
+0 ## Evidence - tell.v - v#952524
+0 ## Evidence - argue.v - v#772189
+0 ## Evidence - mean.v - v#2635189
+0 ## Evidence - proof.n - n#5824739
+0 ## Evidence - illustrate.v - v#1687401
+0 ## Evidence - contradict.v - v#666886
+0 ## Evidence - support.v - v#665886
+0 ## Evidence - demonstrate.v - v#664788
+0 ## Evidence - show.v - v#664788
+0 ## Evidence - evidence.n - n#5823932
+0 ## Evidence - suggest.v - v#930368
+0 ## Evidence - testify.v - v#1015244
+0 ## Evidence - evince.v - v#943837
+0 ## Evidence - corroborate.v - v#665886
+0 ## Evidence - argument.n - n#6648724
+0 ## Evidence - reveal.v - v#933821
+0 ## Evidence - prove.v - v#664788
+0 ## Evidence - indicate.v - v#921300
+0 ## Cause_emotion - offense.n - n#1224031
+0 ## Cause_emotion - affront.n - n#1225027
+0 ## Cause_emotion - concern.v - v#2676054
+0 ## Cause_emotion - insult.n - n#1225027
+0 ## Cause_emotion - offensive.a - a#1631386
+0 ## Cause_emotion - affront.v - v#848420
+0 ## Cause_emotion - insult.v - v#848420
+0 ## Cause_emotion - offend.v - v#1793177
+0 ## Launch_process - launch.v - v#347918
+0 ## Taking - seize.v - v#1212572
+0 ## Taking - take.v - v#2599636
+0 ## Taking - grab.v - v#2304648
+0 ## Taking - seizure.n - n#14081941
+0 ## Candidness - frank.a - a#764484
+0 ## Candidness - secretive.a - a#501004
+0 ## Candidness - outspoken.a - a#764484
+0 ## Candidness - straight.a - a#2318464
+0 ## Candidness - honest.a - a#1222360
+0 ## Candidness - sincere.a - a#2179279
+0 ## Candidness - evasive.a - a#1888284
+0 ## Candidness - straightforward.a - a#766102
+0 ## Candidness - devious.a - a#2466382
+0 ## Candidness - dishonest.a - a#1222884
+0 ## Candidness - candid.a - a#764484
+0 ## Candidness - candour.n - n#4871720
+0 ## Candidness - forthrightness.n - n#4871720
+0 ## Candidness - honesty.n - n#4871374
+0 ## Candidness - open.a - a#1310273
+0 ## Candidness - truthful.a - a#1225398
+0 ## Candidness - explicit.a - a#940437
+0 ## Candidness - bluntness.n - n#4846383
+0 ## Candidness - blunt.a - a#764484
+0 ## Candidness - forthright.a - a#764484
+0 ## Candidness - earnest.a - a#2118840
+0 ## Candidness - discreet.a - a#1898490
+0 ## Candidness - earnestness.n - n#7512315
+0 ## Candidness - disingenuous.a - a#1310685
+0 ## Candidness - coy.a - a#1538118
+0 ## Candidness - circumspect.a - a#1898490
+0 ## Candidness - forthcoming.a - a#2258249
+0 ## Candidness - ingenuous.a - a#1309991
+0 ## Communication - communication_((entity)).n - n#6252138
+0 ## Communication - say.v - v#1009240
+0 ## Communication - convey.v - v#928630
+0 ## Communication - communicate.v - v#740577
+0 ## Communication - contact.n - n#7279285
+0 ## Communication - communication_((act)).n - n#6252138
+0 ## Communication - password.n - n#6674188
+0 ## Communication - signal.v - v#1039330
+0 ## Communication - speech.n - n#5650820
+0 ## Communication - indicate.v - v#921300
+0 ## Rite - prayer.n - n#1041968
+0 ## Rite - rite.n - n#1029406
+0 ## Rite - baptize.v - v#1028079
+0 ## Rite - service.n - n#1032040
+0 ## Rite - initiate.v - v#2390470
+0 ## Rite - initiation.n - n#7453195
+0 ## Rite - bar mitzvah.n - n#7453924
+0 ## Rite - ordination.n - n#165298
+0 ## Rite - christen.v - v#1028079
+0 ## Rite - sacrifice.v - v#2343595
+0 ## Rite - sacrament.n - n#1034925
+0 ## Rite - communion.n - n#1036333
+0 ## Rite - unction.n - n#1041674
+0 ## Rite - vigil.n - n#1029671
+0 ## Rite - evensong.n - n#6456759
+0 ## Rite - anoint.v - v#85626
+0 ## Rite - confirm.v - v#2474603
+0 ## Rite - circumcise.v - v#1274341
+0 ## Rite - exercise.n - n#7454452
+0 ## Rite - baptism.n - n#1037819
+0 ## Rite - order.v - v#2386012
+0 ## Rite - christening.n - n#1038375
+0 ## Rite - confirmation.n - n#1038761
+0 ## Rite - pray.v - v#759944
+0 ## Rite - rite of passage.n - n#1037294
+0 ## Rite - confession.n - n#1039307
+0 ## Rite - bless.v - v#866702
+0 ## Rite - consecration.n - n#1041111
+0 ## Rite - mass.n - n#1042242
+0 ## Rite - ordain.v - v#2386012
+0 ## Rite - consecrate.v - v#866702
+0 ## Rite - blessing.n - n#1043693
+0 ## Rite - ritual.n - n#1030820
+0 ## Rite - circumcision.n - n#1031194
+0 ## Rite - worship.n - n#1028655
+0 ## Rite - sacrifice.n - n#227595
+0 ## Rite - eucharist.n - n#1035853
+0 ## Rite - vesper.n - n#1034571
+0 ## Fullness - fullness.n - n#14451911
+0 ## Fullness - empty.a - a#1086545
+0 ## Fullness - emptiness.n - n#14455206
+0 ## Fullness - full.a - a#1083157
+0 ## Non-commutative_statement - quotient.n - n#13824815
+0 ## Non-commutative_statement - difference.n - n#13729236
+0 ## Import_export - importation.n - n#3564667
+0 ## Import_export - import.v - v#2346136
+0 ## Import_export - transship.v - v#2013163
+0 ## Import_export - export.v - v#2346409
+0 ## Import_export - import_((act)).n - n#3564667
+0 ## Import_export - importer.n - n#10201366
+0 ## Import_export - export_((act)).n - n#3306207
+0 ## Import_export - export_((entity)).n - n#3306207
+0 ## Import_export - exporter.n - n#10073634
+0 ## Import_export - import_((entity)).n - n#3564667
+0 ## Spelling_and_pronouncing - pronounce.v - v#978549
+0 ## Spelling_and_pronouncing - spell.v - v#1699896
+0 ## Spelling_and_pronouncing - misspell.v - v#938146
+0 ## Spelling_and_pronouncing - say.v - v#1009240
+0 ## Spelling_and_pronouncing - mispronounce.v - v#951601
+0 ## Spelling_and_pronouncing - write.v - v#1698271
+0 ## Being_named - pseudonym.n - n#6338278
+0 ## Being_named - known.a - a#1375174
+0 ## Being_named - surname.n - n#6336904
+0 ## Being_named - Christian name.n - n#6337458
+0 ## Being_named - pet_name.n - n#6339244
+0 ## Being_named - metronymic.n - n#6336149
+0 ## Being_named - stage name.n - n#6338571
+0 ## Being_named - patronymic.n - n#6335832
+0 ## Being_named - nee.a - a#1315339
+0 ## Being_named - misnomer.n - n#6338485
+0 ## Being_named - last name.n - n#6336904
+0 ## Being_named - nom de guerre.n - n#6338278
+0 ## Being_named - first name.n - n#6337307
+0 ## Being_named - praenomen.n - n#6337594
+0 ## Being_named - pen name.n - n#6338653
+0 ## Being_named - name.n - n#6333653
+0 ## Being_named - given name.n - n#6337307
+0 ## Being_named - eponym.n - n#6334778
+0 ## Being_named - forename.n - n#6337307
+0 ## Being_named - nickname.n - n#6337693
+0 ## Being_named - go.v - v#1835496
+0 ## Being_named - alias.n - n#6338158
+0 ## Being_named - brand_name.n - n#6845599
+0 ## Being_named - so-called.a - a#1916555
+0 ## Being_named - family name.n - n#6336904
+0 ## Being_named - agnomen.n - n#6334377
+0 ## Being_named - maiden name.n - n#6337111
+0 ## Being_named - nameless.a - a#120784
+0 ## Being_named - moniker.n - n#6337693
+0 ## Being_named - soubriquet.n - n#6337693
+0 ## Being_named - entitled.a - a#852425
+0 ## Being_named - call.v - v#1028748
+0 ## Being_named - cognomen.n - n#6337693
+0 ## Being_named - nom de plume.n - n#6338653
+0 ## Being_named - middle name.n - n#6337202
+0 ## Wagering - wager.n - n#506658
+0 ## Wagering - wager.v - v#1155687
+0 ## Connecting_architecture - lift.n - n#3281145
+0 ## Connecting_architecture - elevator.n - n#3281145
+0 ## Connecting_architecture - corridor.n - n#3112099
+0 ## Connecting_architecture - stairs.n - n#4298171
+0 ## Connecting_architecture - hallway.n - n#3479952
+0 ## Connecting_architecture - staircase.n - n#4298308
+0 ## Connecting_architecture - step.n - n#6645039
+0 ## Connecting_architecture - window.n - n#4587648
+0 ## Connecting_architecture - escalator.n - n#3295773
+0 ## Connecting_architecture - door.n - n#3221720
+0 ## Aggregate - pack.n - n#8240633
+0 ## Aggregate - assemblage.n - n#7951464
+0 ## Aggregate - covey.n - n#8310309
+0 ## Aggregate - variety.n - n#8398773
+0 ## Aggregate - band.n - n#8240169
+0 ## Aggregate - school.n - n#8276720
+0 ## Aggregate - gaggle.n - n#7992116
+0 ## Aggregate - army.n - n#8191230
+0 ## Aggregate - crew.n - n#8273843
+0 ## Aggregate - brood.n - n#7990824
+0 ## Aggregate - stand.n - n#8438384
+0 ## Aggregate - tribe.n - n#7969695
+0 ## Aggregate - huddle.n - n#8184439
+0 ## Aggregate - gang.n - n#8273843
+0 ## Aggregate - squad.n - n#8208560
+0 ## Aggregate - community.n - n#8223802
+0 ## Aggregate - horde.n - n#8182962
+0 ## Aggregate - repertoire.n - n#8336627
+0 ## Aggregate - flock.n - n#13774404
+0 ## Aggregate - assortment.n - n#8398773
+0 ## Aggregate - multiplicity.n - n#5121908
+0 ## Aggregate - repertory.n - n#8336844
+0 ## Aggregate - batch.n - n#13774404
+0 ## Aggregate - quartet.n - n#7988089
+0 ## Aggregate - colony.n - n#7995856
+0 ## Aggregate - trio.n - n#7986198
+0 ## Aggregate - throng.n - n#8182716
+0 ## Aggregate - passel.n - n#13774404
+0 ## Aggregate - bunch.n - n#8273843
+0 ## Aggregate - claque.n - n#8223137
+0 ## Aggregate - quintet.n - n#7988229
+0 ## Aggregate - party.n - n#8264897
+0 ## Aggregate - circle.n - n#8240169
+0 ## Aggregate - class.n - n#7997703
+0 ## Aggregate - clump.n - n#7959943
+0 ## Aggregate - collection.n - n#7951464
+0 ## Aggregate - corps.n - n#8213079
+0 ## Aggregate - coterie.n - n#8240633
+0 ## Aggregate - shoal.n - n#7995453
+0 ## Aggregate - population.n - n#13779804
+0 ## Aggregate - team.n - n#8208560
+0 ## Aggregate - posse.n - n#8405490
+0 ## Aggregate - bevy.n - n#8415774
+0 ## Aggregate - slew.n - n#13774404
+0 ## Aggregate - harem.n - n#3494105
+0 ## Aggregate - clutch.n - n#8400452
+0 ## Aggregate - herd.n - n#8183046
+0 ## Aggregate - crowd.n - n#8182379
+0 ## Aggregate - body.n - n#7965085
+0 ## Aggregate - legion.n - n#8182962
+0 ## Aggregate - package.n - n#8008017
+0 ## Aggregate - mob.n - n#8184600
+0 ## Aggregate - cohort.n - n#8251104
+0 ## Aggregate - crop.n - n#7955566
+0 ## Aggregate - family.n - n#7997703
+0 ## Aggregate - clique.n - n#8240633
+0 ## Aggregate - multitude.n - n#8182716
+0 ## Aggregate - swarm.n - n#8184217
+0 ## Aggregate - assembly.n - n#8163792
+0 ## Aggregate - host.n - n#8182962
+0 ## Aggregate - flotilla.n - n#3367740
+0 ## Aggregate - set.n - n#7996689
+0 ## Aggregate - sextet.n - n#7988369
+0 ## Aggregate - group.n - n#31264
+0 ## Aggregate - heap.n - n#13774404
+0 ## Aggregate - cluster.n - n#7959943
+0 ## Vocalizations - howl.n - n#7385548
+0 ## Vocalizations - cry.n - n#7120524
+0 ## Vocalizations - hiss.n - n#7123870
+0 ## Vocalizations - squeak.n - n#7395623
+0 ## Taking_sides - endorse.v - v#2556817
+0 ## Taking_sides - pro.adv - r#289204
+0 ## Taking_sides - opposition_((act)).n - n#10055847
+0 ## Taking_sides - back.v - v#2556817
+0 ## Taking_sides - opposition_((entity)).n - n#10055847
+0 ## Taking_sides - side.n - n#8408709
+0 ## Taking_sides - oppose.v - v#775831
+0 ## Taking_sides - backing.n - n#13365698
+0 ## Taking_sides - support.v - v#2453889
+0 ## Taking_sides - believe_(in).v - v#683280
+0 ## Taking_sides - supporter.n - n#10677713
+0 ## Taking_sides - side.v - v#1148961
+0 ## Taking_sides - supportive.a - a#2354537
+0 ## Taking_sides - opponent.n - n#10379620
+0 ## Simple_name - term.n - n#6303888
+0 ## Simple_name - word.n - n#6286395
+0 ## Assemble - assemble.v - v#2428924
+0 ## Assemble - meet.v - v#2428924
+0 ## Assemble - convene.v - v#2024508
+0 ## Hunting_success_or_failure - bag.v - v#1479874
+0 ## Hunting_success_or_failure - catch.v - v#1480149
+0 ## Commercial_transaction - transaction.n - n#1106808
+0 ## Being_attached - plastered.a - a#2427718
+0 ## Being_attached - adhere.v - v#1220885
+0 ## Being_attached - pasted.a - a#159106
+0 ## Being_attached - sewn.a - a#2254172
+0 ## Being_attached - taped.a - a#1060570
+0 ## Being_attached - fastened.a - a#254746
+0 ## Being_attached - stuck.a - a#161065
+0 ## Being_attached - fused.a - a#2476637
+0 ## Being_attached - linked.a - a#567161
+0 ## Being_attached - affixed.a - a#158701
+0 ## Being_attached - glued.a - a#159106
+0 ## Being_attached - adhesion.n - n#4935528
+0 ## Being_attached - attached.a - a#1973311
+0 ## Being_attached - chained.a - a#253196
+0 ## Being_attached - tethered.a - a#253757
+0 ## Being_attached - tied.a - a#254746
+0 ## Being_attached - stick.v - v#1356750
+0 ## Being_attached - connected.a - a#566099
+0 ## Being_attached - bound.a - a#252954
+0 ## Being_attached - shackled.a - a#253361
+0 ## Meet_specifications - fulfill.v - v#2671880
+0 ## Meet_specifications - meet.v - v#2667900
+0 ## Touring - do.v - v#2560585
+0 ## Touring - see.v - v#2129289
+0 ## Touring - sights.n - n#4216963
+0 ## Touring - tour.v - v#1845229
+0 ## Touring - tourism.n - n#298161
+0 ## Touring - tour.n - n#310666
+0 ## Touring - tourist.n - n#10718131
+0 ## Capability - capable.a - a#306314
+0 ## Capability - potential.a - a#44353
+0 ## Capability - potential.n - n#14482620
+0 ## Capability - unable.a - a#2098
+0 ## Capability - ability.n - n#5200169
+0 ## Capability - can.v - v#213794
+0 ## Capability - capacity.n - n#5622956
+0 ## Capability - able.a - a#306663
+0 ## Capability - capability.n - n#5202497
+0 ## Time_vector - finally.adv - r#48138
+0 ## Time_vector - already.adv - r#31798
+0 ## Time_vector - thereafter.adv - r#146281
+0 ## Time_vector - afterward.adv - r#61203
+0 ## Time_vector - later.adv - r#61203
+0 ## Time_vector - right away.adv - r#48739
+0 ## Time_vector - formerly.adv - r#118965
+0 ## Time_vector - afterwards.adv - r#61203
+0 ## Time_vector - beforehand.adv - r#67045
+0 ## Time_vector - previous.a - a#127137
+0 ## Time_vector - eventually.adv - r#48138
+0 ## Time_vector - previously.adv - r#60632
+0 ## Time_vector - then.a - a#1731108
+0 ## Time_vector - former.a - a#1729566
+0 ## Inclusion - exclude.v - v#615774
+0 ## Inclusion - incorporate.v - v#2629535
+0 ## Inclusion - include.v - v#2632940
+0 ## Inclusion - have.v - v#2203362
+0 ## Inclusion - contain.v - v#2629535
+0 ## Inclusion - inclusive.a - a#1863680
+0 ## Inclusion - integrated.a - a#2477557
+0 ## Agree_or_refuse_to_act - agree.v - v#764222
+0 ## Agree_or_refuse_to_act - decline.v - v#2237338
+0 ## Agree_or_refuse_to_act - refusal.n - n#6634095
+0 ## Agree_or_refuse_to_act - refuse.v - v#2237338
+0 ## Agriculture - cultivate.v - v#1742726
+0 ## Agriculture - farming.n - n#916464
+0 ## Agriculture - farm.v - v#1739814
+0 ## Measure_by_action - bite.n - n#838816
+0 ## Measure_by_action - pinch.n - n#842281
+0 ## Measure_by_action - splash.n - n#717748
+0 ## Part_ordered_segments - act.n - n#7009640
+0 ## Part_ordered_segments - book.n - n#6410904
+0 ## Part_ordered_segments - inning.n - n#15255804
+0 ## Part_ordered_segments - chapter.n - n#6396142
+0 ## Being_awake - conscious.a - a#570590
+0 ## Being_awake - watch.v - v#2150510
+0 ## Being_awake - awake.a - a#186616
+0 ## Being_awake - wakeful.a - a#187590
+0 ## Predicament - bind.n - n#5689801
+0 ## Predicament - problem.n - n#14410605
+0 ## Predicament - mess.n - n#14409489
+0 ## Predicament - pinch.n - n#14409371
+0 ## Predicament - scrape.n - n#7392982
+0 ## Predicament - predicament.n - n#14408646
+0 ## Predicament - fix.n - n#14409489
+0 ## Predicament - trouble.n - n#5687338
+0 ## Predicament - misfortune.n - n#7304852
+0 ## Predicament - plight.n - n#14408646
+0 ## Predicament - jam.n - n#14409489
+0 ## Predicament - pickle.n - n#14409489
+0 ## Others_situation_as_stimulus - feel_(for).v - v#1771535
+0 ## Others_situation_as_stimulus - empathize.v - v#594058
+0 ## Others_situation_as_stimulus - pity.v - v#1821996
+0 ## Others_situation_as_stimulus - sympathize.v - v#1822724
+0 ## Others_situation_as_stimulus - compassion.n - n#4829550
+0 ## Sensation - scene.n - n#13937075
+0 ## Sensation - taste.n - n#5715283
+0 ## Sensation - feel.n - n#14526182
+0 ## Sensation - scent.n - n#5714466
+0 ## Sensation - perception.n - n#876874
+0 ## Sensation - reek.n - n#5714894
+0 ## Sensation - incense.n - n#5714745
+0 ## Sensation - sense.n - n#5651971
+0 ## Sensation - feeling.n - n#14526182
+0 ## Sensation - perfume.n - n#5714466
+0 ## Sensation - sound.n - n#5718254
+0 ## Sensation - stink.n - n#5714894
+0 ## Sensation - sensation.n - n#5712076
+0 ## Sensation - aroma.n - n#5714466
+0 ## Sensation - savour.n - n#5715864
+0 ## Sensation - fragrance.n - n#5714466
+0 ## Sensation - sight.n - n#5933054
+0 ## Sensation - flavour.n - n#14526182
+0 ## Sensation - odor.n - n#5713737
+0 ## Sensation - bouquet.n - n#4980463
+0 ## Sensation - smell.n - n#5713737
+0 ## Sensation - noise.n - n#7387509
+0 ## Sensation - image.n - n#3931044
+0 ## Sensation - whiff.n - n#11497888
+0 ## Social_event - festival.n - n#517728
+0 ## Social_event - bash.n - n#7448038
+0 ## Social_event - social.n - n#8256369
+0 ## Social_event - celebration.n - n#428000
+0 ## Social_event - soiree.n - n#8255231
+0 ## Social_event - shindig.n - n#8253045
+0 ## Social_event - rave.n - n#7449676
+0 ## Social_event - party.n - n#8252602
+0 ## Social_event - host.v - v#1194418
+0 ## Social_event - banquet.n - n#8253640
+0 ## Social_event - barbecue.n - n#7576781
+0 ## Social_event - fete.n - n#7449862
+0 ## Social_event - fair.n - n#8408557
+0 ## Social_event - jollification.n - n#509846
+0 ## Social_event - dinner.n - n#8253815
+0 ## Social_event - picnic.n - n#7576438
+0 ## Social_event - reception.n - n#8254331
+0 ## Social_event - ball.n - n#8253268
+0 ## Social_event - dance.n - n#7448717
+0 ## Social_event - meeting.n - n#1230965
+0 ## Social_event - feast.n - n#8253640
+0 ## Social_event - gala.n - n#518669
+0 ## Cause_to_wake - rouse.v - v#18813
+0 ## Cause_to_wake - wake_up.v - v#18813
+0 ## Cause_to_wake - awaken.v - v#18526
+0 ## Cause_to_wake - wake.v - v#18526
+0 ## Cause_to_wake - get_up.v - v#18158
+0 ## Expensiveness - expensive.a - a#933154
+0 ## Expensiveness - inexpensive.a - a#934199
+0 ## Expensiveness - expense.n - n#13275495
+0 ## Expensiveness - low-cost.a - a#935103
+0 ## Expensiveness - low-priced.a - a#935103
+0 ## Expensiveness - overpriced.a - a#934082
+0 ## Expensiveness - costly.a - a#933599
+0 ## Expensiveness - cheap.a - a#934199
+0 ## Expensiveness - exorbitant.a - a#1534282
+0 ## Expensiveness - cost.v - v#2628961
+0 ## Expensiveness - affordable.a - a#935103
+0 ## Expensiveness - cost.n - n#13275847
+0 ## Expensiveness - free.a - a#1710260
+0 ## Expensiveness - pricey.a - a#933599
+0 ## Visiting - visit.v - v#2487573
+0 ## Visiting - visitor.n - n#10757193
+0 ## Visiting - call.n - n#1055954
+0 ## Visiting - visit.n - n#1233156
+0 ## Visiting - revisit.v - v#1844319
+0 ## Part_whole - section.n - n#5867413
+0 ## Part_whole - portion.n - n#3892891
+0 ## Part_whole - eighth.n - n#13738140
+0 ## Part_whole - hundredth.n - n#13739051
+0 ## Part_whole - quarter.n - n#15258450
+0 ## Part_whole - segment.n - n#4164989
+0 ## Part_whole - fifth.n - n#13737830
+0 ## Part_whole - half.n - n#15257829
+0 ## Part_whole - fragment.n - n#9285254
+0 ## Part_whole - tenth.n - n#13738327
+0 ## Part_whole - third.n - n#13737190
+0 ## Part_whole - part.n - n#3892891
+0 ## Go_into_shape - coil.v - v#1523986
+0 ## Go_into_shape - curl.v - v#1223616
+0 ## Go_into_shape - twist.v - v#1222645
+0 ## Exemplar - epitome.n - n#5937524
+0 ## Exemplar - prototype.n - n#5937524
+0 ## Exemplar - image.n - n#5937524
+0 ## Exemplar - exemplar.n - n#5925366
+0 ## Exemplar - model.n - n#5937112
+0 ## Commerce_buy - buy.v - v#2207206
+0 ## Commerce_buy - purchase_((act)).n - n#13253612
+0 ## Commerce_buy - purchase.v - v#2207206
+0 ## Memorization - learn.v - v#604576
+0 ## Memorization - memorization.n - n#5755156
+0 ## Memorization - memorise.v - v#604576
+0 ## Sending - dispatch.v - v#1955127
+0 ## Sending - forward.v - v#1955508
+0 ## Sending - route.v - v#1955364
+0 ## Sending - ship.v - v#1950798
+0 ## Sending - shipment_((items)).n - n#61290
+0 ## Sending - mail.v - v#1031256
+0 ## Sending - fax.v - v#1007676
+0 ## Sending - wire.v - v#1007222
+0 ## Sending - shipment_((act)).n - n#61290
+0 ## Sending - barge.v - v#1950502
+0 ## Sending - send.v - v#1950798
+0 ## Sending - express.v - v#1031756
+0 ## Sending - export.v - v#2346409
+0 ## Sending - post.v - v#1031256
+0 ## Sending - telex.v - v#790965
+0 ## Reference_text - see.v - v#2129289
+0 ## Make_noise - giggle.v - v#30142
+0 ## Make_noise - clang.v - v#2174115
+0 ## Make_noise - whine.v - v#2171664
+0 ## Make_noise - crepitate.v - v#2175384
+0 ## Make_noise - bleat.v - v#1048330
+0 ## Make_noise - rasp.v - v#1386906
+0 ## Make_noise - sound.v - v#2176268
+0 ## Make_noise - creak.v - v#2171664
+0 ## Make_noise - whisper.v - v#915830
+0 ## Make_noise - gurgle.v - v#2177976
+0 ## Make_noise - babble.v - v#2187922
+0 ## Make_noise - snarl.v - v#916520
+0 ## Make_noise - sizzle.v - v#862591
+0 ## Make_noise - ululate.v - v#1046932
+0 ## Make_noise - moo.v - v#1055018
+0 ## Make_noise - growl.v - v#1045719
+0 ## Make_noise - screech.v - v#2171664
+0 ## Make_noise - plash.v - v#1374020
+0 ## Make_noise - scrunch.v - v#2184797
+0 ## Make_noise - whinny.v - v#1059743
+0 ## Make_noise - hum.v - v#1055829
+0 ## Make_noise - bark.v - v#1047745
+0 ## Make_noise - mew.v - v#1052782
+0 ## Make_noise - chuckle.v - v#31663
+0 ## Make_noise - fizzle.v - v#2683671
+0 ## Make_noise - chatter.v - v#2185861
+0 ## Make_noise - hoot.v - v#1053221
+0 ## Make_noise - mewl.v - v#66025
+0 ## Make_noise - cry.v - v#913065
+0 ## Make_noise - snore.v - v#17031
+0 ## Make_noise - drone.v - v#2188442
+0 ## Make_noise - squeak.v - v#2171664
+0 ## Make_noise - blare.v - v#2183175
+0 ## Make_noise - rustle.v - v#2182662
+0 ## Make_noise - scream.v - v#913065
+0 ## Make_noise - snort.v - v#6523
+0 ## Make_noise - purr.v - v#2188587
+0 ## Make_noise - gasp.v - v#5526
+0 ## Make_noise - laugh.v - v#31820
+0 ## Make_noise - yap.v - v#1048171
+0 ## Make_noise - whimper.v - v#66025
+0 ## Make_noise - yammer.v - v#1047381
+0 ## Make_noise - snicker.v - v#30010
+0 ## Make_noise - peep.v - v#1052301
+0 ## Make_noise - cough.v - v#5815
+0 ## Make_noise - wail.v - v#1046932
+0 ## Make_noise - sob.v - v#67129
+0 ## Make_noise - toll.v - v#2181973
+0 ## Make_noise - beep.v - v#2183175
+0 ## Make_noise - boom.v - v#2187510
+0 ## Make_noise - neigh.v - v#1059743
+0 ## Make_noise - thunder.v - v#1046587
+0 ## Make_noise - sough.v - v#1046815
+0 ## Make_noise - yodel.v - v#1050651
+0 ## Make_noise - moan.v - v#1045419
+0 ## Make_noise - clatter.v - v#2172127
+0 ## Make_noise - guffaw.v - v#31540
+0 ## Make_noise - yelp.v - v#1048171
+0 ## Make_noise - hem and haw.v - v#1061881
+0 ## Make_noise - trumpet.v - v#857784
+0 ## Make_noise - ring.v - v#2181538
+0 ## Make_noise - burble.v - v#2187922
+0 ## Make_noise - croon.v - v#1049470
+0 ## Make_noise - howl.v - v#1046932
+0 ## Make_noise - hiss.v - v#1053771
+0 ## Make_noise - croak.v - v#1064401
+0 ## Make_noise - bray.v - v#1054553
+0 ## Make_noise - gobble.v - v#1173933
+0 ## Make_noise - coo.v - v#909896
+0 ## Make_noise - chirp.v - v#1052301
+0 ## Make_noise - tweet.v - v#2177661
+0 ## Make_noise - keen.v - v#1802219
+0 ## Make_noise - plonk.v - v#1500572
+0 ## Make_noise - tinkle.v - v#2186506
+0 ## Make_noise - quack.v - v#1053098
+0 ## Make_noise - titter.v - v#30142
+0 ## Make_noise - rattle.v - v#2175057
+0 ## Make_noise - caw.v - v#1060065
+0 ## Make_noise - squeal.v - v#1054694
+0 ## Make_noise - hawk.v - v#35089
+0 ## Make_noise - blast.v - v#2182479
+0 ## Make_noise - whistle.v - v#2183626
+0 ## Make_noise - click.v - v#1054849
+0 ## Make_noise - bellow.v - v#1048718
+0 ## Make_noise - plop.v - v#1977266
+0 ## Make_noise - yowl.v - v#1047381
+0 ## Make_noise - thump.v - v#1880113
+0 ## Make_noise - clack.v - v#2172127
+0 ## Make_noise - grunt.v - v#1043231
+0 ## Make_noise - twitter.v - v#1053623
+0 ## Make_noise - clash.v - v#1561143
+0 ## Make_noise - scrape.v - v#1308160
+0 ## Make_noise - caterwaul.v - v#914634
+0 ## Make_noise - peal.v - v#2180898
+0 ## Make_noise - snigger.v - v#30010
+0 ## Make_noise - roar.v - v#1046932
+0 ## Make_noise - crunch.v - v#1058224
+0 ## Make_noise - cackle.v - v#1056369
+0 ## Make_noise - cheep.v - v#1052301
+0 ## Make_noise - squawk.v - v#1048939
+0 ## Make_noise - patter.v - v#2185187
+0 ## Body_mark - rash.n - n#14321953
+0 ## Body_mark - freckle.n - n#5245192
+0 ## Body_mark - scar.n - n#14363483
+0 ## Body_mark - blister.n - n#5517837
+0 ## Body_mark - bedsore.n - n#14212126
+0 ## Body_mark - cold sore.n - n#14132375
+0 ## Body_mark - liver spot.n - n#5245387
+0 ## Body_mark - acne.n - n#14222112
+0 ## Body_mark - mole.n - n#4693804
+0 ## Body_mark - callus.n - n#14363785
+0 ## Body_mark - blackhead.n - n#5245775
+0 ## Body_mark - birthmark.n - n#4692638
+0 ## Body_mark - zit.n - n#14334306
+0 ## Body_mark - blotch.n - n#4694809
+0 ## Body_mark - pimple.n - n#14334306
+0 ## Body_mark - boil.n - n#14183210
+0 ## Body_mark - sore.n - n#14183065
+0 ## Body_mark - love bite.n - n#14226862
+0 ## Body_mark - wart.n - n#4696432
+0 ## Body_mark - blemish.n - n#4692157
+0 ## Body_mark - pustule.n - n#14334122
+0 ## Coming_up_with - invention_artifact.n - n#5633385
+0 ## Coming_up_with - invent.v - v#1632411
+0 ## Coming_up_with - conceive.v - v#1633343
+0 ## Coming_up_with - devise.v - v#1632411
+0 ## Coming_up_with - hatch.v - v#1634142
+0 ## Coming_up_with - design.v - v#1638368
+0 ## Coming_up_with - formulate.v - v#1632411
+0 ## Coming_up_with - cook_up.v - v#1634424
+0 ## Coming_up_with - design.n - n#5633385
+0 ## Coming_up_with - concoct.v - v#1634142
+0 ## Coming_up_with - create.v - v#1617192
+0 ## Coming_up_with - coin.v - v#1697986
+0 ## Coming_up_with - contrivance.n - n#5634457
+0 ## Coming_up_with - contrive.v - v#1632411
+0 ## Coming_up_with - concoction.n - n#5634219
+0 ## Coming_up_with - invention_process.n - n#5633385
+0 ## Coming_up_with - improvise.v - v#1728840
+0 ## Birth - bear.v - v#56930
+0 ## Birth - whelp.v - v#58516
+0 ## Birth - birth.v - v#56930
+0 ## Birth - calving.n - n#13442639
+0 ## Birth - kid.v - v#851100
+0 ## Birth - beget.v - v#54628
+0 ## Birth - spawn.v - v#56683
+0 ## Birth - birth.n - n#15142167
+0 ## Birth - father.v - v#54628
+0 ## Birth - lay.v - v#1545079
+0 ## Birth - generate.v - v#54628
+0 ## Birth - bring_forth.v - v#54628
+0 ## Birth - mother.v - v#54628
+0 ## Birth - get.v - v#2210855
+0 ## Birth - have.v - v#2203362
+0 ## Birth - calve.v - v#58897
+0 ## Birth - propagate.v - v#968211
+0 ## Birth - sire.v - v#54628
+0 ## Birth - drop.v - v#57764
+0 ## Birth - carry_to_term.v - v#59559
+0 ## Hit_or_miss - hit.v - v#1123887
+0 ## Hit_or_miss - hit.n - n#125629
+0 ## Hit_or_miss - wide.adv - r#495858
+0 ## Hit_or_miss - miss.v - v#2022659
+0 ## Speed - rapidly.adv - r#85811
+0 ## Speed - rapid.a - a#979862
+0 ## Speed - pace.n - n#5058580
+0 ## Speed - speedy.a - a#979862
+0 ## Speed - quick.a - a#979366
+0 ## Speed - rate.n - n#15286249
+0 ## Speed - breakneck.a - a#2059280
+0 ## Speed - fast.a - a#976508
+0 ## Speed - quickly.adv - r#85811
+0 ## Speed - smart.a - a#980144
+0 ## Speed - speedily.adv - r#85811
+0 ## Speed - speed.n - n#5058140
+0 ## Repayment - pay back.v - v#2344381
+0 ## Repayment - repay.v - v#2344060
+0 ## Repayment - repayment.n - n#1121690
+0 ## Explaining_the_facts - account.v - v#2607432
+0 ## Explaining_the_facts - explain.v - v#939277
+0 ## Explaining_the_facts - explanation.n - n#6738281
+0 ## Sleep - doze.n - n#858849
+0 ## Sleep - catnap.v - v#15498
+0 ## Sleep - hibernation.n - n#14014849
+0 ## Sleep - slumber.n - n#14024882
+0 ## Sleep - sleep_event.n - n#14024882
+0 ## Sleep - nap.n - n#858377
+0 ## Sleep - slumber.v - v#14742
+0 ## Sleep - sleep.v - v#14742
+0 ## Sleep - sleep_((quantity)).n - n#15273626
+0 ## Sleep - out.a - a#572714
+0 ## Sleep - drowse.v - v#15303
+0 ## Sleep - nap.v - v#15498
+0 ## Sleep - snooze.v - v#15303
+0 ## Sleep - forty_winks.n - n#858377
+0 ## Sleep - hibernate.v - v#15946
+0 ## Sleep - kip.v - v#14742
+0 ## Sleep - unconscious.a - a#571643
+0 ## Sleep - catnap.n - n#858377
+0 ## Sleep - drowse.n - n#858849
+0 ## Sleep - doze.v - v#15303
+0 ## Sleep - asleep.a - a#187736
+0 ## Sleep - snooze.n - n#858377
+0 ## Sleep - kip.n - n#15273955
+0 ## Possession - possession.n - n#32613
+0 ## Possession - owner.n - n#10389398
+0 ## Possession - wanting.a - a#927832
+0 ## Possession - want.n - n#14449405
+0 ## Possession - effects.n - n#13246079
+0 ## Possession - lack.v - v#2632353
+0 ## Possession - possessor.n - n#10389398
+0 ## Possession - ownership.n - n#13240514
+0 ## Possession - custody.n - n#818678
+0 ## Possession - belongings.n - n#13244109
+0 ## Possession - definite_possession.n - n#32613
+0 ## Possession - lacking.a - a#52012
+0 ## Possession - assets.n - n#13329641
+0 ## Possession - have got.v - v#2203362
+0 ## Possession - want.v - v#1825237
+0 ## Possession - possess.v - v#2204692
+0 ## Possession - have.v - v#2203362
+0 ## Possession - property.n - n#13244109
+0 ## Possession - own.v - v#2204692
+0 ## Possession - belong.v - v#2301680
+0 ## Possession - lack.n - n#14449405
+0 ## Possession - possession_of_goods.n - n#32613
+0 ## Ruling_legally - rule.v - v#971999
+0 ## Preference - prefer.v - v#679389
+0 ## Preference - favor.v - v#2400037
+0 ## Adducing - point (to).v - v#923793
+0 ## Adducing - adduce.v - v#1015866
+0 ## Adducing - name.v - v#1024190
+0 ## Adducing - cite.v - v#1024190
+0 ## Cause_motion - scoot.v - v#2061495
+0 ## Cause_motion - press.v - v#1447257
+0 ## Cause_motion - knock.v - v#1238640
+0 ## Cause_motion - draw.v - v#1448100
+0 ## Cause_motion - force.v - v#1448100
+0 ## Cause_motion - yank.v - v#1592072
+0 ## Cause_motion - drag.v - v#1454810
+0 ## Cause_motion - attract.v - v#1505254
+0 ## Cause_motion - shove.v - v#2094569
+0 ## Cause_motion - pull.v - v#1448100
+0 ## Cause_motion - roll.v - v#1866192
+0 ## Cause_motion - propel.v - v#1511706
+0 ## Cause_motion - hurl.v - v#1507143
+0 ## Cause_motion - nudge.v - v#1231252
+0 ## Cause_motion - push.v - v#1871979
+0 ## Cause_motion - slide.v - v#2090990
+0 ## Cause_motion - stick.v - v#748084
+0 ## Cause_motion - toss.v - v#1512625
+0 ## Cause_motion - run.v - v#1926311
+0 ## Cause_motion - tug.v - v#1452918
+0 ## Cause_motion - pitch.v - v#1512625
+0 ## Cause_motion - cast.v - v#1507143
+0 ## Cause_motion - jerk.v - v#1592072
+0 ## Cause_motion - catapult.v - v#1514348
+0 ## Cause_motion - fling.v - v#1512465
+0 ## Cause_motion - drive.v - v#2057656
+0 ## Cause_motion - thrust.v - v#2094569
+0 ## Cause_motion - move.v - v#1850315
+0 ## Cause_motion - haul.v - v#1454810
+0 ## Cause_motion - throw.v - v#1508368
+0 ## Cause_motion - chuck.v - v#1514525
+0 ## Cause_motion - punt.v - v#1372189
+0 ## Cause_motion - launch.v - v#1514655
+0 ## Change_direction - cut.v - v#2033295
+0 ## Change_direction - veer.v - v#2033295
+0 ## Change_direction - left.n - n#351168
+0 ## Change_direction - swing.v - v#1877620
+0 ## Change_direction - turn.n - n#350030
+0 ## Change_direction - turn.v - v#1907258
+0 ## Change_direction - right.n - n#351000
+0 ## Change_direction - bear.v - v#2630871
+0 ## Architectural_part - landing.n - n#3638511
+0 ## Architectural_part - floor.n - n#3365592
+0 ## Architectural_part - ceiling.n - n#6657646
+0 ## Architectural_part - foundation.n - n#3387016
+0 ## Architectural_part - counter.n - n#3116530
+0 ## Architectural_part - rail.n - n#4047401
+0 ## Architectural_part - facade.n - n#3313333
+0 ## Architectural_part - mantel.n - n#3719343
+0 ## Architectural_part - fireplace.n - n#3346455
+0 ## Architectural_part - roof.n - n#4105068
+0 ## Architectural_part - wall.n - n#4546855
+0 ## Architectural_part - flight.n - n#3363059
+0 ## Activity_resume - restart.v - v#350104
+0 ## Activity_resume - renew.v - v#1631072
+0 ## Activity_resume - resume.v - v#350104
+0 ## Membership - member.n - n#10307234
+0 ## Membership - membership.n - n#8400965
+0 ## Membership - membership_(status).n - n#13931627
+0 ## Membership - part.n - n#13809207
+0 ## Membership - belong.v - v#2756359
+0 ## Temporal_subregion - later.a - a#819235
+0 ## Temporal_subregion - end.n - n#5868477
+0 ## Temporal_subregion - earlier.a - a#814611
+0 ## Temporal_subregion - early.a - a#812952
+0 ## Temporal_subregion - mid.a - a#816324
+0 ## Temporal_subregion - outset.n - n#15265518
+0 ## Temporal_subregion - turn.n - n#457382
+0 ## Temporal_subregion - late.a - a#819235
+0 ## Temporal_subregion - beginning.n - n#15265518
+0 ## Temporal_subregion - middle.n - n#15266685
+0 ## Temporal_subregion - middle.a - a#815941
+0 ## Temporal_subregion - start.n - n#15265518
+0 ## Temporal_subregion - dawning.n - n#15168790
+0 ## Measure_linear_extent - mile.n - n#13651218
+0 ## Measure_linear_extent - kilometer.n - n#13659760
+0 ## Measure_linear_extent - meter.n - n#13659162
+0 ## Measure_linear_extent - foot.n - n#13650045
+0 ## Measure_linear_extent - furlong.n - n#13651072
+0 ## Measure_linear_extent - inch.n - n#13649791
+0 ## Measure_linear_extent - centimeter.n - n#13658828
+0 ## Measure_linear_extent - millimeter.n - n#13658657
+0 ## Measure_linear_extent - block.n - n#8642145
+0 ## Measure_linear_extent - light-year.n - n#13656520
+0 ## Measure_linear_extent - yard.n - n#13650447
+0 ## Stinginess - ungenerous.a - a#1112573
+0 ## Stinginess - niggardliness.n - n#4833687
+0 ## Stinginess - miser.n - n#10322084
+0 ## Stinginess - miserliness.n - n#4834228
+0 ## Stinginess - stingy.a - a#1112573
+0 ## Stinginess - niggardly.a - a#1113636
+0 ## Stinginess - miserly.a - a#1113807
+0 ## Stinginess - mean.a - a#1113807
+0 ## Stinginess - hoard.v - v#2305856
+0 ## Stinginess - lavish.v - v#2264601
+0 ## Stinginess - lavish.a - a#1111965
+0 ## Stinginess - generous.a - a#1111016
+0 ## Commemorative - Christmas Day.n - n#15196186
+0 ## Commemorative - birthday.n - n#15250178
+0 ## Commemorative - Labor Day.n - n#15190520
+0 ## Commemorative - Boxing Day.n - n#15196746
+0 ## Referring_by_name - designation.n - n#6338908
+0 ## Referring_by_name - name.n - n#6333653
+0 ## Referring_by_name - address.v - v#2601456
+0 ## Referring_by_name - refer.v - v#1028294
+0 ## Referring_by_name - call.v - v#1028748
+0 ## Locale_by_ownership - property.n - n#13244109
+0 ## Locale_by_ownership - estate.n - n#13246662
+0 ## Locale_by_ownership - land.n - n#13246662
+0 ## Process - process.n - n#29677
+0 ## Cause_to_fragment - rend.v - v#1573276
+0 ## Cause_to_fragment - split.v - v#1556572
+0 ## Cause_to_fragment - dissect.v - v#1550220
+0 ## Cause_to_fragment - smash.v - v#335923
+0 ## Cause_to_fragment - tear.v - v#1573515
+0 ## Cause_to_fragment - break.v - v#334186
+0 ## Cause_to_fragment - fragment.v - v#338071
+0 ## Cause_to_fragment - tear_up.v - v#1573891
+0 ## Cause_to_fragment - chip.v - v#1259691
+0 ## Cause_to_fragment - break_apart.v - v#368662
+0 ## Cause_to_fragment - fracture.v - v#335366
+0 ## Cause_to_fragment - take_apart.v - v#643473
+0 ## Cause_to_fragment - sliver.v - v#337903
+0 ## Cause_to_fragment - rive.v - v#1573276
+0 ## Cause_to_fragment - dissolve.v - v#1784592
+0 ## Cause_to_fragment - break_down.v - v#1784295
+0 ## Cause_to_fragment - shatter.v - v#333758
+0 ## Cause_to_fragment - splinter.v - v#337903
+0 ## Cause_to_fragment - shred.v - v#1573891
+0 ## Cause_to_fragment - rip.v - v#1573276
+0 ## Cause_to_fragment - snap.v - v#1573515
+0 ## Cause_to_fragment - break_up.v - v#338071
+0 ## Cause_to_fragment - cleave.v - v#1556572
+0 ## Cause_to_fragment - rip_up.v - v#1573891
+0 ## Cause_to_fragment - shiver.v - v#1888946
+0 ## Intentional_traversing - ascend.v - v#1969216
+0 ## Intentional_traversing - ford.v - v#1913849
+0 ## Intentional_traversing - climb.v - v#1921964
+0 ## Intentional_traversing - traverse.v - v#1912159
+0 ## Intentional_traversing - cut.v - v#1552519
+0 ## Needing - require.v - v#2627934
+0 ## Needing - need.v - v#2627934
+0 ## Needing - need.n - n#14449126
+0 ## Research - investigate.v - v#789138
+0 ## Research - research.n - n#636921
+0 ## Research - research.v - v#877327
+0 ## Ratification - ratify.v - v#2464866
+0 ## Ratification - ratification.n - n#7179943
+0 ## Corroding - rust.v - v#273963
+0 ## Corroding - corrode.v - v#274283
+0 ## Correctness - correct.a - a#631391
+0 ## Correctness - wrong.a - a#632438
+0 ## Correctness - incorrect.a - a#632438
+0 ## Correctness - accurate.a - a#21766
+0 ## Correctness - exact.a - a#631798
+0 ## Correctness - right.a - a#631391
+0 ## Correctness - correctness.n - n#4802198
+0 ## Size - enormous.a - a#1385255
+0 ## Size - tiny.a - a#1392249
+0 ## Size - big.a - a#1382086
+0 ## Size - small.a - a#1391351
+0 ## Size - huge.a - a#1387319
+0 ## Size - large.a - a#1382086
+0 ## Size - little.a - a#1391351
+0 ## Cause_to_be_included - include.v - v#2632940
+0 ## Cause_to_be_included - add.v - v#182406
+0 ## Permitting - sanction.v - v#806502
+0 ## Permitting - permit.n - n#6549661
+0 ## Permitting - allow.v - v#802318
+0 ## Permitting - permit.v - v#802318
+0 ## Permitting - entitle.v - v#2447370
+0 ## Permitting - accept.v - v#797697
+0 ## Emotions_success_or_failure - dissatisfied.a - a#590163
+0 ## Emotions_success_or_failure - satisfied.a - a#589344
+0 ## Emotions_success_or_failure - unfulfilled.a - a#2335393
+0 ## Emotions_success_or_failure - fulfilled.a - a#552089
+0 ## Endangering - jeopardise.v - v#2697120
+0 ## Endangering - imperil.v - v#2697120
+0 ## Endangering - endangerment.n - n#14541852
+0 ## Endangering - endanger.v - v#2697120
+0 ## Communication_response - retort.n - n#7199922
+0 ## Communication_response - reply.n - n#7199565
+0 ## Communication_response - riposte.n - n#7199922
+0 ## Communication_response - rejoin.v - v#816353
+0 ## Communication_response - rejoinder.n - n#7199922
+0 ## Communication_response - answer.n - n#6746005
+0 ## Communication_response - response.n - n#7199565
+0 ## Communication_response - come back.v - v#816353
+0 ## Communication_response - reaction.n - n#859001
+0 ## Communication_response - comeback.n - n#7199922
+0 ## Communication_response - counter.v - v#815379
+0 ## Communication_response - reply.v - v#815686
+0 ## Communication_response - respond.v - v#815686
+0 ## Communication_response - retort.v - v#816353
+0 ## Communication_response - answer.v - v#815686
+0 ## Commutative_statement - times.n - n#871576
+0 ## Commutative_statement - product.n - n#3748886
+0 ## Commutative_statement - sum.n - n#5861067
+0 ## Arranging - format.v - v#1745141
+0 ## Arranging - deploy.v - v#1149327
+0 ## Arranging - array.v - v#1474209
+0 ## Arranging - set up.v - v#1463963
+0 ## Arranging - deployment.n - n#1143409
+0 ## Arranging - arrangement.n - n#7938773
+0 ## Arranging - arrange.v - v#1463963
+0 ## Arranging - order.v - v#735571
+0 ## Arranging - justify.v - v#489699
+0 ## Political_locales - parish.n - n#8615001
+0 ## Political_locales - viscountcy.n - n#14433232
+0 ## Political_locales - global.a - a#1568684
+0 ## Political_locales - town.n - n#8665504
+0 ## Political_locales - jurisdiction.n - n#8590369
+0 ## Political_locales - land.n - n#8556491
+0 ## Political_locales - world.n - n#7965937
+0 ## Political_locales - commonwealth.n - n#8168978
+0 ## Political_locales - territory.n - n#8493064
+0 ## Political_locales - fiefdom.n - n#8557754
+0 ## Political_locales - kingdom.n - n#8558155
+0 ## Political_locales - national.a - a#2988060
+0 ## Political_locales - locality.n - n#8641113
+0 ## Political_locales - federal.a - a#1106129
+0 ## Political_locales - international.a - a#1568375
+0 ## Political_locales - village.n - n#8226699
+0 ## Political_locales - megalopolis.n - n#8537708
+0 ## Political_locales - nation.n - n#8168978
+0 ## Political_locales - municipality.n - n#8626283
+0 ## Political_locales - barony.n - n#13251906
+0 ## Political_locales - county.n - n#8546870
+0 ## Political_locales - province.n - n#8654360
+0 ## Political_locales - state.n - n#8168978
+0 ## Political_locales - duchy.n - n#8557131
+0 ## Political_locales - principality.n - n#8558488
+0 ## Political_locales - local.a - a#1106405
+0 ## Political_locales - district.n - n#8552138
+0 ## Political_locales - empire.n - n#8557482
+0 ## Political_locales - metropolis.n - n#8524735
+0 ## Political_locales - internationally.adv - r#112279
+0 ## Political_locales - city.n - n#8524735
+0 ## Political_locales - city-state.n - n#8177958
+0 ## Political_locales - country.n - n#8168978
+0 ## Political_locales - borough.n - n#8540016
+0 ## Political_locales - diocese.n - n#8550966
+0 ## Political_locales - realm.n - n#14514805
+0 ## Political_locales - municipal.a - a#2697452
+0 ## Political_locales - multinational.a - a#1569166
+0 ## Collaboration - affiliated.a - a#1973311
+0 ## Collaboration - cooperate.v - v#2416278
+0 ## Collaboration - collaborator.n - n#9935434
+0 ## Collaboration - together.adv - r#116588
+0 ## Collaboration - conspiracy.n - n#6524935
+0 ## Collaboration - collude.v - v#707624
+0 ## Collaboration - in league.a - a#2477691
+0 ## Collaboration - collaborate.v - v#2416278
+0 ## Collaboration - associate.n - n#9816771
+0 ## Collaboration - confederate.n - n#9953483
+0 ## Collaboration - collaboration.n - n#1205156
+0 ## Collaboration - jointly.adv - r#197710
+0 ## Collaboration - partner.v - v#2332086
+0 ## Collaboration - conspire.v - v#707624
+0 ## Collaboration - team_up.v - v#1089285
+0 ## Collaboration - partner.n - n#9935434
+0 ## Collaboration - collusion.n - n#5795244
+0 ## Collaboration - cooperation.n - n#1202904
+0 ## Actually_occurring_entity - actual.a - a#43765
+0 ## Behind_the_scenes - film.v - v#1002740
+0 ## Behind_the_scenes - produce.v - v#1752495
+0 ## Behind_the_scenes - score.n - n#6815714
+0 ## Behind_the_scenes - compose.v - v#1705494
+0 ## Behind_the_scenes - cast.v - v#1632897
+0 ## Behind_the_scenes - soundtrack.n - n#4262969
+0 ## Behind_the_scenes - shoot.v - v#1002740
+0 ## Behind_the_scenes - producer.n - n#10480018
+0 ## Behind_the_scenes - direct.v - v#1710317
+0 ## Behind_the_scenes - director.n - n#10088200
+0 ## Behind_the_scenes - stage.v - v#1711445
+0 ## Emanating - exude.v - v#67999
+0 ## Emanating - issue.v - v#528990
+0 ## Emanating - emanate.v - v#546192
+0 ## Emanating - radiate.v - v#529582
+0 ## Path_traveled - orbit.n - n#8612049
+0 ## Path_traveled - path.n - n#8616311
+0 ## Path_traveled - circuit.n - n#8616985
+0 ## Path_traveled - course.n - n#9387222
+0 ## Attention_getting - sir.n - n#10601451
+0 ## Attention_getting - dude.n - n#10083358
+0 ## Attention_getting - miss.n - n#10129825
+0 ## Attention_getting - kid.n - n#9917593
+0 ## Attention_getting - ma'am.n - n#9989290
+0 ## Attention_getting - guy.n - n#10153414
+0 ## Attention_getting - officer.n - n#10317007
+0 ## Attention_getting - pal.n - n#9877951
+0 ## Attention_getting - boy.n - n#10285313
+0 ## Attention_getting - buddy.n - n#9877951
+0 ## Motion - roll.v - v#1881180
+0 ## Motion - fly.v - v#1940403
+0 ## Motion - spiral.v - v#2049190
+0 ## Motion - move.v - v#1835496
+0 ## Motion - zigzag.v - v#1991744
+0 ## Motion - meander.v - v#1882814
+0 ## Motion - soar.v - v#1942959
+0 ## Motion - go.v - v#1835496
+0 ## Motion - travel.v - v#1835496
+0 ## Motion - circle.v - v#1911339
+0 ## Motion - wind.v - v#1882814
+0 ## Motion - coast.v - v#1886728
+0 ## Motion - drift.v - v#1902783
+0 ## Motion - swerve.v - v#2033295
+0 ## Motion - snake.v - v#1883210
+0 ## Motion - undulate.v - v#1901783
+0 ## Motion - swing.v - v#1877620
+0 ## Motion - weave.v - v#1882814
+0 ## Motion - glide.v - v#1887576
+0 ## Motion - float.v - v#1902783
+0 ## Motion - blow.v - v#1902783
+0 ## Motion - slide.v - v#1886488
+0 ## Estimated_value - estimate.n - n#5803379
+0 ## Estimated_value - estimation.n - n#5803379
+0 ## Activity_done_state - through.a - a#1003536
+0 ## Activity_done_state - done.a - a#1003536
+0 ## Activity_done_state - finished.a - a#1003050
+0 ## Hindering - hurdle.n - n#5691241
+0 ## Hindering - inhibit.v - v#2451679
+0 ## Hindering - interfere.v - v#2451912
+0 ## Hindering - interference.n - n#3520811
+0 ## Hindering - obstruction_entity.n - n#3839993
+0 ## Hindering - constrain.v - v#1301051
+0 ## Hindering - encumber.v - v#1301051
+0 ## Hindering - hinder.v - v#2451370
+0 ## Hindering - impede.v - v#2451370
+0 ## Hindering - obstructive.a - a#1764351
+0 ## Hindering - handicap.v - v#1085474
+0 ## Hindering - delay.v - v#459776
+0 ## Hindering - encumbrance.n - n#3520811
+0 ## Hindering - impediment.n - n#5689249
+0 ## Hindering - hamper.v - v#1085474
+0 ## Hindering - obstruct.v - v#1476483
+0 ## Hindering - retard.v - v#440286
+0 ## Hindering - hardship.n - n#4710127
+0 ## Hindering - trammel.v - v#233335
+0 ## Hindering - obstruction_act.n - n#3839993
+0 ## Hindering - hindrance.n - n#3520811
+0 ## Breaking_off - break.v - v#334186
+0 ## Breaking_off - chip.v - v#1259691
+0 ## Breaking_off - snap.v - v#337065
+0 ## Run_risk - risk.n - n#14541852
+0 ## Run_risk - risk.v - v#2545578
+0 ## Run_risk - peril.n - n#14541852
+0 ## Run_risk - endangered.a - a#2524192
+0 ## Run_risk - wager.v - v#1155687
+0 ## Roadways - avenue.n - n#2763472
+0 ## Roadways - pathway.n - n#3899533
+0 ## Roadways - expressway.n - n#3306610
+0 ## Roadways - railway.n - n#4048568
+0 ## Roadways - driveway.n - n#3244388
+0 ## Roadways - route.n - n#4096066
+0 ## Roadways - tunnel.n - n#9230041
+0 ## Roadways - overpass.n - n#3865557
+0 ## Roadways - path.n - n#3899328
+0 ## Roadways - rail.n - n#4463679
+0 ## Roadways - thoroughfare.n - n#4426618
+0 ## Roadways - byway.n - n#2930645
+0 ## Roadways - pavement.n - n#4215402
+0 ## Roadways - way.n - n#8679972
+0 ## Roadways - railroad.n - n#4048075
+0 ## Roadways - crosswalk.n - n#3137228
+0 ## Roadways - underpass.n - n#4508804
+0 ## Roadways - street.n - n#4334599
+0 ## Roadways - track.n - n#9387222
+0 ## Roadways - autobahn.n - n#2758863
+0 ## Roadways - artery.n - n#2744532
+0 ## Roadways - bridge.n - n#2898711
+0 ## Roadways - bypass.n - n#2828648
+0 ## Roadways - highway.n - n#3519981
+0 ## Roadways - road.n - n#4096066
+0 ## Roadways - runway.n - n#4463679
+0 ## Roadways - course.n - n#9387222
+0 ## Roadways - motorway.n - n#3306610
+0 ## Roadways - trail.n - n#9460312
+0 ## Roadways - freeway.n - n#3306610
+0 ## Roadways - lane.n - n#3640660
+0 ## Roadways - flyover.n - n#3865557
+0 ## Roadways - roadway.n - n#4097622
+0 ## Roadways - boulevard.n - n#2763472
+0 ## Roadways - sidewalk.n - n#4215402
+0 ## Roadways - parkway.n - n#3242713
+0 ## Roadways - line.n - n#8593262
+0 ## Encounter - encounter.v - v#2023107
+0 ## Encounter - stumble.v - v#2206462
+0 ## Desiring - hunger.v - v#1188485
+0 ## Desiring - yen.v - v#1805684
+0 ## Desiring - yearn.v - v#1828405
+0 ## Desiring - will.n - n#5652593
+0 ## Desiring - thirst.n - n#4945254
+0 ## Desiring - hankering.n - n#7486922
+0 ## Desiring - hunger.n - n#4945254
+0 ## Desiring - wish.n - n#7486229
+0 ## Desiring - thirst.v - v#1188485
+0 ## Desiring - lust.v - v#1188485
+0 ## Desiring - raring.a - a#811536
+0 ## Desiring - covetous.a - a#888765
+0 ## Desiring - hope.n - n#7541053
+0 ## Desiring - yearning.n - n#7486628
+0 ## Desiring - crave.v - v#1188485
+0 ## Desiring - itch.v - v#1825761
+0 ## Desiring - desirous.a - a#887719
+0 ## Desiring - long.v - v#1828405
+0 ## Desiring - ambition.n - n#7484547
+0 ## Desiring - aspire.v - v#705517
+0 ## Desiring - reluctant.a - a#2566453
+0 ## Desiring - desire.v - v#1825237
+0 ## Desiring - feel_like.v - v#1826184
+0 ## Desiring - want.v - v#1825237
+0 ## Desiring - hanker.v - v#1828405
+0 ## Desiring - will.v - v#698398
+0 ## Desiring - pine.v - v#1805684
+0 ## Desiring - wish.v - v#1824339
+0 ## Desiring - lust.n - n#7489714
+0 ## Desiring - thirsty.a - a#888200
+0 ## Desiring - hungry.a - a#1269073
+0 ## Desiring - dying.a - a#811248
+0 ## Desiring - loath.a - a#2566453
+0 ## Desiring - urge.n - n#7490451
+0 ## Desiring - desire.n - n#7484265
+0 ## Desiring - yen.n - n#7486922
+0 ## Desiring - hope.v - v#1826723
+0 ## Desiring - longing.n - n#7486628
+0 ## Desiring - craving.n - n#7485475
+0 ## Desiring - wish (that).v - v#1824339
+0 ## Desiring - aspiration.n - n#7484547
+0 ## Desiring - desired.a - a#2527220
+0 ## Desiring - covet.v - v#1827232
+0 ## Desiring - fancy.v - v#1776468
+0 ## Desiring - ache.v - v#1805684
+0 ## Desiring - interested.a - a#1342237
+0 ## Desiring - eager.a - a#810916
+0 ## Create_physical_artwork - sculpt.v - v#1684337
+0 ## Create_physical_artwork - cast.v - v#1513430
+0 ## Create_physical_artwork - artist.n - n#9812338
+0 ## Create_physical_artwork - take_((picture)).v - v#173338
+0 ## Create_physical_artwork - draw.v - v#1582645
+0 ## Create_physical_artwork - paint.v - v#1362736
+0 ## Come_together - congregate.v - v#2023600
+0 ## Come_together - meet.v - v#2428924
+0 ## Come_together - band together.v - v#2470685
+0 ## Come_together - gather.v - v#2428924
+0 ## Come_together - amass.v - v#158804
+0 ## Come_together - throng.v - v#2064131
+0 ## Reason - why.n - n#9179606
+0 ## Reason - motive.n - n#23773
+0 ## Reason - basis.n - n#5793554
+0 ## Reason - reason.n - n#9178999
+0 ## Reason - motivation.n - n#23773
+0 ## Shopping - shopping.n - n#81836
+0 ## Shopping - shop.v - v#2325968
+0 ## Thriving - prosperity.n - n#14474052
+0 ## Thriving - flourish.v - v#310386
+0 ## Thriving - do.v - v#2560585
+0 ## Thriving - prosper.v - v#2342800
+0 ## Thriving - slump.n - n#13556509
+0 ## Thriving - languish.v - v#389992
+0 ## Thriving - fare.v - v#2617567
+0 ## Thriving - thrive.v - v#2342800
+0 ## Measurable_attributes - heavy.a - a#1192786
+0 ## Measurable_attributes - tall.a - a#2385102
+0 ## Measurable_attributes - thick.a - a#2410393
+0 ## Measurable_attributes - long.a - a#1433493
+0 ## Measurable_attributes - deep.a - a#692762
+0 ## Measurable_attributes - high.a - a#1210854
+0 ## People_by_jurisdiction - citizen.n - n#9923673
+0 ## People_by_jurisdiction - subject.n - n#9625401
+0 ## People_by_jurisdiction - parishioner.n - n#10400108
+0 ## People_by_jurisdiction - citizenry.n - n#8160276
+0 ## People_by_jurisdiction - national.n - n#9625401
+0 ## Process_completed_state - complete.a - a#1003277
+0 ## Process_completed_state - over.a - a#1003277
+0 ## Process_completed_state - finished.a - a#1003050
+0 ## Process_completed_state - done.a - a#1003536
+0 ## Progress - advancement.n - n#282050
+0 ## Progress - advance.v - v#248659
+0 ## Progress - mature.v - v#250181
+0 ## Progress - maturation.n - n#13489037
+0 ## Progress - advance.n - n#7357388
+0 ## Progress - development.n - n#250259
+0 ## Progress - progress.v - v#248659
+0 ## Progress - progress.n - n#249501
+0 ## Progress - develop.v - v#252019
+0 ## Progress - burgeon.v - v#357854
+0 ## Labor_product - work.n - n#4599396
+0 ## Commerce_sell - auction.v - v#2244773
+0 ## Commerce_sell - vend.v - v#2302817
+0 ## Commerce_sell - retailer.n - n#10525436
+0 ## Commerce_sell - retail.v - v#2728570
+0 ## Commerce_sell - sale.n - n#1117541
+0 ## Commerce_sell - vendor.n - n#10577284
+0 ## Commerce_sell - auction.n - n#92366
+0 ## Commerce_sell - sell.v - v#2242464
+0 ## Individual_history - past.n - n#15120823
+0 ## Individual_history - history.n - n#15121406
+0 ## Disembarking - deplane.v - v#2016298
+0 ## Disembarking - dismount.v - v#1958452
+0 ## Disembarking - detrain.v - v#2016220
+0 ## Disembarking - debark.v - v#1979241
+0 ## Disembarking - disembarkation.n - n#58002
+0 ## Disembarking - disembark.v - v#1979241
+0 ## Disembarking - alight.v - v#1978576
+0 ## Disembarking - get.v - v#2210855
+0 ## Biological_area - veld.n - n#8677424
+0 ## Biological_area - prairie.n - n#8619524
+0 ## Biological_area - oasis.n - n#8506496
+0 ## Biological_area - grassland.n - n#8598301
+0 ## Biological_area - savanna.n - n#8645847
+0 ## Biological_area - marsh.n - n#9347779
+0 ## Biological_area - wold.n - n#8645318
+0 ## Biological_area - wood.n - n#8438533
+0 ## Biological_area - rainforest.n - n#8439126
+0 ## Biological_area - rainforest.n - n#8439126
+0 ## Biological_area - lea.n - n#8616050
+0 ## Biological_area - glade.n - n#8541288
+0 ## Biological_area - tundra.n - n#9463226
+0 ## Biological_area - bush.n - n#8438223
+0 ## Biological_area - woodland.n - n#9284015
+0 ## Biological_area - mead.n - n#7890750
+0 ## Biological_area - plain.n - n#9393605
+0 ## Biological_area - spinney.n - n#8437968
+0 ## Biological_area - thicket.n - n#8437515
+0 ## Biological_area - heathland.n - n#8504851
+0 ## Biological_area - fen.n - n#9347779
+0 ## Biological_area - swamp.n - n#9452395
+0 ## Biological_area - forest.n - n#8438533
+0 ## Biological_area - bog.n - n#9225943
+0 ## Biological_area - desert.n - n#8505573
+0 ## Biological_area - moor.n - n#9358751
+0 ## Biological_area - copse.n - n#8437515
+0 ## Biological_area - jungle.n - n#8439022
+0 ## Biological_area - mire.n - n#9355850
+0 ## Biological_area - swampland.n - n#9452395
+0 ## Biological_area - marshland.n - n#9347779
+0 ## Biological_area - greenwood.n - n#9294599
+0 ## Biological_area - scrub.n - n#8438223
+0 ## Hunting - seal.v - v#1143498
+0 ## Hunting - fish.v - v#1319346
+0 ## Hunting - hunt.v - v#1143838
+0 ## Leadership - satrap.n - n#10553140
+0 ## Leadership - tsarina.n - n#9987573
+0 ## Leadership - senate.n - n#8161477
+0 ## Leadership - queen.n - n#10235024
+0 ## Leadership - president_(political).n - n#10468962
+0 ## Leadership - power_((govt)).n - n#5190804
+0 ## Leadership - CEO.n - n#9916348
+0 ## Leadership - rule.v - v#2586619
+0 ## Leadership - official.n - n#10372373
+0 ## Leadership - preside.v - v#2443609
+0 ## Leadership - viceroy.n - n#10751785
+0 ## Leadership - bishop.n - n#9857200
+0 ## Leadership - command.v - v#2441022
+0 ## Leadership - head.n - n#10162991
+0 ## Leadership - administer.v - v#2431971
+0 ## Leadership - diplomat.n - n#10013927
+0 ## Leadership - command.n - n#5197797
+0 ## Leadership - rule.n - n#14442933
+0 ## Leadership - leader.n - n#9623038
+0 ## Leadership - rector.n - n#9983572
+0 ## Leadership - prime minister.n - n#9907196
+0 ## Leadership - minister.n - n#585810
+0 ## Leadership - monarch.n - n#10628644
+0 ## Leadership - run.v - v#1926311
+0 ## Leadership - officer.n - n#10317007
+0 ## Leadership - chieftain.n - n#10164025
+0 ## Leadership - captain.n - n#9892831
+0 ## Leadership - governor.n - n#10140314
+0 ## Leadership - charge.n - n#7169480
+0 ## Leadership - khan.n - n#10230097
+0 ## Leadership - head.v - v#2440244
+0 ## Leadership - administration.n - n#1124794
+0 ## Leadership - general.n - n#10125561
+0 ## Leadership - caliph.n - n#9887496
+0 ## Leadership - premier.n - n#9907196
+0 ## Leadership - mogul.n - n#9840217
+0 ## Leadership - legislature.n - n#8163273
+0 ## Leadership - principal.n - n#10474645
+0 ## Leadership - power_((rule)).n - n#9840217
+0 ## Leadership - boss.n - n#10104209
+0 ## Leadership - chief executive officer.n - n#9916348
+0 ## Leadership - ruler.n - n#10541229
+0 ## Leadership - lead.v - v#2440244
+0 ## Leadership - crown prince.n - n#9981092
+0 ## Leadership - executive.n - n#9770472
+0 ## Leadership - imam.n - n#10199251
+0 ## Leadership - doyen.n - n#9997068
+0 ## Leadership - emperor.n - n#10053004
+0 ## Leadership - congressman.n - n#9955781
+0 ## Leadership - secretary.n - n#10570019
+0 ## Leadership - govern.v - v#2586619
+0 ## Leadership - khedive.n - n#10230216
+0 ## Leadership - tsar.n - n#9987239
+0 ## Leadership - chief.n - n#10162991
+0 ## Leadership - legislator.n - n#10253995
+0 ## Leadership - chairperson.n - n#10468962
+0 ## Leadership - kaiser.n - n#10229338
+0 ## Leadership - suzerain.n - n#8170535
+0 ## Leadership - maharaja.n - n#10281637
+0 ## Leadership - sultan.n - n#10674315
+0 ## Leadership - director.n - n#9952539
+0 ## Leadership - dictator.n - n#10011902
+0 ## Leadership - vizier.n - n#10758445
+0 ## Leadership - pasha.n - n#10403768
+0 ## Leadership - presidential.a - a#2984104
+0 ## Leadership - sovereign.n - n#10628644
+0 ## Leadership - headmaster.n - n#10164233
+0 ## Leadership - drug lord.n - n#10036135
+0 ## Leadership - lawmaker.n - n#10249270
+0 ## Leadership - king.n - n#10231515
+0 ## Leadership - overlord.n - n#10388440
+0 ## Leadership - government.n - n#8050678
+0 ## Leadership - representative.n - n#9955781
+0 ## Leadership - doyenne.n - n#10028541
+0 ## Leadership - authority.n - n#5196582
+0 ## Leadership - spearhead.v - v#2440608
+0 ## Leadership - shah.n - n#10585496
+0 ## Leadership - regime.n - n#8050678
+0 ## Leadership - mayor.n - n#10303814
+0 ## Leadership - commandant.n - n#9941964
+0 ## Leadership - reign.v - v#2587375
+0 ## Leadership - baron.n - n#9840217
+0 ## Leadership - duchess.n - n#10038409
+0 ## Leadership - prince.n - n#10472799
+0 ## Leadership - empress.n - n#10053439
+0 ## Leadership - leadership.n - n#5617310
+0 ## Leadership - high-priest.n - n#10175248
+0 ## Leadership - sheik.n - n#10588357
+0 ## Leadership - commander.n - n#9941964
+0 ## Leadership - chairman.n - n#10468962
+0 ## Rashness - patient.a - a#1735736
+0 ## Rashness - precipitous.a - a#1270868
+0 ## Rashness - precipitate.a - a#1270868
+0 ## Rashness - impetuous.a - a#326608
+0 ## Rashness - rash.a - a#1900188
+0 ## Rashness - impatient.a - a#1737241
+0 ## Observable_body_parts - forehead.n - n#5602548
+0 ## Observable_body_parts - chest.n - n#5553288
+0 ## Observable_body_parts - bill.n - n#1758308
+0 ## Observable_body_parts - rump.n - n#5559256
+0 ## Observable_body_parts - crown.n - n#5308141
+0 ## Observable_body_parts - elbow.n - n#5579944
+0 ## Observable_body_parts - forearm.n - n#5564323
+0 ## Observable_body_parts - antler.n - n#1325658
+0 ## Observable_body_parts - breast.n - n#5553288
+0 ## Observable_body_parts - ankle.n - n#5578442
+0 ## Observable_body_parts - finger.n - n#5566504
+0 ## Observable_body_parts - heel.n - n#5578095
+0 ## Observable_body_parts - nape.n - n#5547396
+0 ## Observable_body_parts - claw.n - n#2156140
+0 ## Observable_body_parts - tentacle.n - n#2584643
+0 ## Observable_body_parts - thorax.n - n#2665543
+0 ## Observable_body_parts - maw.n - n#5302307
+0 ## Observable_body_parts - leg.n - n#5560787
+0 ## Observable_body_parts - toenail.n - n#5584486
+0 ## Observable_body_parts - face.n - n#5600637
+0 ## Observable_body_parts - flesh.n - n#5217168
+0 ## Observable_body_parts - whisker.n - n#1901828
+0 ## Observable_body_parts - forefinger.n - n#5567381
+0 ## Observable_body_parts - fingernail.n - n#5584265
+0 ## Observable_body_parts - fluke.n - n#2158619
+0 ## Observable_body_parts - hoof.n - n#2153959
+0 ## Observable_body_parts - snout.n - n#2452637
+0 ## Observable_body_parts - incisor.n - n#5307641
+0 ## Observable_body_parts - mane.n - n#1899746
+0 ## Observable_body_parts - eyelid.n - n#5313822
+0 ## Observable_body_parts - muzzle.n - n#2452464
+0 ## Observable_body_parts - body.n - n#5549830
+0 ## Observable_body_parts - eye.n - n#5311054
+0 ## Observable_body_parts - limb.n - n#5560244
+0 ## Observable_body_parts - tongue.n - n#5301072
+0 ## Observable_body_parts - beard.n - n#5261566
+0 ## Observable_body_parts - head.n - n#5538625
+0 ## Observable_body_parts - appendage.n - n#5559908
+0 ## Observable_body_parts - mouth.n - n#5301908
+0 ## Observable_body_parts - forefoot.n - n#2439728
+0 ## Observable_body_parts - tooth.n - n#5282746
+0 ## Observable_body_parts - hindlimb.n - n#2464461
+0 ## Observable_body_parts - fin.n - n#2466132
+0 ## Observable_body_parts - arm.n - n#5563770
+0 ## Observable_body_parts - jaw.n - n#5546040
+0 ## Observable_body_parts - tail.n - n#2157557
+0 ## Observable_body_parts - trunk.n - n#5549830
+0 ## Observable_body_parts - nose.n - n#5598147
+0 ## Observable_body_parts - wing.n - n#2151625
+0 ## Observable_body_parts - thigh.n - n#5562249
+0 ## Observable_body_parts - back.n - n#5558717
+0 ## Observable_body_parts - pelt.n - n#1895735
+0 ## Observable_body_parts - knee.n - n#5573602
+0 ## Observable_body_parts - hair.n - n#5254795
+0 ## Observable_body_parts - lip.n - n#5305806
+0 ## Observable_body_parts - neck.n - n#5546540
+0 ## Observable_body_parts - midriff.n - n#5555473
+0 ## Observable_body_parts - flipper.n - n#2465084
+0 ## Observable_body_parts - navel.n - n#5556595
+0 ## Observable_body_parts - thumb.n - n#5567217
+0 ## Observable_body_parts - member.n - n#5559908
+0 ## Observable_body_parts - toe.n - n#5577410
+0 ## Observable_body_parts - forelimb.n - n#2464785
+0 ## Observable_body_parts - temple.n - n#5602683
+0 ## Observable_body_parts - shoulder.n - n#5548840
+0 ## Observable_body_parts - nostril.n - n#5600109
+0 ## Observable_body_parts - antenna.n - n#2584915
+0 ## Observable_body_parts - brow.n - n#5602548
+0 ## Observable_body_parts - foot.n - n#5563266
+0 ## Observable_body_parts - fang.n - n#1785234
+0 ## Observable_body_parts - earlobe.n - n#5323588
+0 ## Observable_body_parts - feeler.n - n#2584915
+0 ## Observable_body_parts - belly.n - n#5556943
+0 ## Observable_body_parts - buttocks.n - n#5559256
+0 ## Observable_body_parts - forepaw.n - n#2440121
+0 ## Observable_body_parts - beak.n - n#1758308
+0 ## Observable_body_parts - cheek.n - n#5602835
+0 ## Observable_body_parts - fingertip.n - n#5567117
+0 ## Observable_body_parts - horn.n - n#1325417
+0 ## Observable_body_parts - foreleg.n - n#2464965
+0 ## Observable_body_parts - talon.n - n#2156413
+0 ## Observable_body_parts - mustache.n - n#5262185
+0 ## Observable_body_parts - ear.n - n#5320899
+0 ## Observable_body_parts - hindquarters.n - n#5559256
+0 ## Observable_body_parts - chin.n - n#5599617
+0 ## Observable_body_parts - hand.n - n#5564590
+0 ## Observable_body_parts - anus.n - n#5538016
+0 ## Observable_body_parts - skin.n - n#1895735
+0 ## Observable_body_parts - sole.n - n#5577190
+0 ## Observable_body_parts - groin.n - n#5597734
+0 ## Observable_body_parts - paw.n - n#2439929
+0 ## Obscurity - unsung.a - a#1122595
+0 ## Obscurity - obscure.a - a#1122595
+0 ## Obscurity - recondite.a - a#899226
+0 ## Chatting - conversation.n - n#7133701
+0 ## Chatting - joke.v - v#853633
+0 ## Chatting - yak.v - v#741573
+0 ## Chatting - talk.v - v#962447
+0 ## Chatting - colloquy.n - n#7143044
+0 ## Chatting - badinage.n - n#6777961
+0 ## Chatting - converse.v - v#964694
+0 ## Chatting - shoot the breeze.v - v#1038666
+0 ## Chatting - gossip.v - v#1038666
+0 ## Chatting - banter.n - n#6777794
+0 ## Chatting - chat.n - n#7134850
+0 ## Chatting - gab.v - v#741573
+0 ## Chatting - gossip.n - n#7135080
+0 ## Chatting - chat.v - v#1038666
+0 ## Chatting - chit-chat.n - n#7135080
+0 ## Chatting - speak.v - v#962447
+0 ## Typicality - odd.a - a#968010
+0 ## Typicality - curious.a - a#968010
+0 ## Typicality - commonplace.a - a#1673946
+0 ## Typicality - ordinary.a - a#1672607
+0 ## Typicality - average.a - a#1594146
+0 ## Typicality - unusual.a - a#967129
+0 ## Typicality - normal.a - a#1593649
+0 ## Typicality - vanilla.a - a#2823018
+0 ## Surrendering - surrender.v - v#2235229
+0 ## Surrendering - give up.v - v#2235229
+0 ## Surrendering - surrender.n - n#7542433
+0 ## Surrendering - turn in.v - v#2293321
+0 ## Confronting_problem - face.v - v#812298
+0 ## Confronting_problem - confront.v - v#812298
+0 ## Communication_manner - rave.v - v#1051956
+0 ## Communication_manner - lisp.v - v#982178
+0 ## Communication_manner - stammer.v - v#981544
+0 ## Communication_manner - natter.v - v#1038666
+0 ## Communication_manner - jabber.v - v#1051956
+0 ## Communication_manner - mutter.v - v#1044533
+0 ## Communication_manner - prattle.v - v#1036804
+0 ## Communication_manner - mouth.v - v#941990
+0 ## Communication_manner - gabble.v - v#1036804
+0 ## Communication_manner - slur.v - v#1044811
+0 ## Communication_manner - chant.v - v#1066775
+0 ## Communication_manner - gibber.v - v#1036804
+0 ## Communication_manner - shout.v - v#912473
+0 ## Communication_manner - bluster.v - v#2770362
+0 ## Communication_manner - rant.v - v#1051956
+0 ## Communication_manner - stutter.v - v#981544
+0 ## Communication_manner - mumble.v - v#1044533
+0 ## Communication_manner - babble.v - v#1037650
+0 ## Communication_manner - whisper.v - v#915830
+0 ## Communication_manner - chatter.v - v#1036804
+0 ## Communication_manner - sing.v - v#1729431
+0 ## Communication_manner - simper.v - v#29336
+0 ## Communication_manner - drawl.v - v#980176
+0 ## Place_weight_on - focus.v - v#722232
+0 ## Place_weight_on - stress.v - v#1013367
+0 ## Place_weight_on - oriented.a - a#1682229
+0 ## Place_weight_on - focused.a - a#782856
+0 ## Place_weight_on - prioritize.v - v#660381
+0 ## Place_weight_on - emphasize.v - v#1014609
+0 ## Place_weight_on - emphasis.n - n#14434866
+0 ## Place_weight_on - centered.a - a#330644
+0 ## Use_firearm - shoot.v - v#1134781
+0 ## Use_firearm - fire.v - v#1133825
+0 ## Use_firearm - discharge.v - v#1133825
+0 ## Project - program.n - n#5898568
+0 ## Project - plan.n - n#5898568
+0 ## Project - project.n - n#5910453
+0 ## Project - scheme.n - n#5891572
+0 ## Corporal_punishment - scourge.v - v#1398443
+0 ## Corporal_punishment - paddle.v - v#1420928
+0 ## Corporal_punishment - spank.v - v#1420928
+0 ## Corporal_punishment - caning.n - n#4582205
+0 ## Corporal_punishment - cane.v - v#1412204
+0 ## Corporal_punishment - lash.n - n#134574
+0 ## Corporal_punishment - flog.v - v#1411085
+0 ## Corporal_punishment - flogging.n - n#1163047
+0 ## Clothing_parts - hem.n - n#3513627
+0 ## Clothing_parts - zipper.n - n#4238321
+0 ## Clothing_parts - placket.n - n#3953901
+0 ## Clothing_parts - lace.n - n#3631445
+0 ## Clothing_parts - buckle.n - n#2910353
+0 ## Clothing_parts - fringe.n - n#3397762
+0 ## Clothing_parts - monogram.n - n#6824041
+0 ## Clothing_parts - seam.n - n#4160372
+0 ## Clothing_parts - neck.n - n#5546540
+0 ## Clothing_parts - skirt.n - n#4231272
+0 ## Clothing_parts - thong.n - n#3643907
+0 ## Clothing_parts - bootlace.n - n#2874537
+0 ## Clothing_parts - waist.n - n#5555688
+0 ## Clothing_parts - shoelace.n - n#4200637
+0 ## Clothing_parts - waistband.n - n#3438071
+0 ## Clothing_parts - snap.n - n#5020358
+0 ## Clothing_parts - cowl.n - n#3530910
+0 ## Clothing_parts - waistline.n - n#5555688
+0 ## Clothing_parts - clasp.n - n#3038281
+0 ## Clothing_parts - strap.n - n#4333129
+0 ## Clothing_parts - cuff.n - n#3145843
+0 ## Clothing_parts - collar.n - n#3068181
+0 ## Clothing_parts - seat.n - n#4162433
+0 ## Clothing_parts - tassel.n - n#4395201
+0 ## Clothing_parts - sash.n - n#3438071
+0 ## Clothing_parts - insole.n - n#3573848
+0 ## Clothing_parts - sleeve.n - n#4236377
+0 ## Clothing_parts - pocket.n - n#3972524
+0 ## Clothing_parts - button.n - n#2928608
+0 ## Clothing_parts - leg.n - n#5560787
+0 ## Clothing_parts - neckband.n - n#3068181
+0 ## Clothing_parts - breastplate.n - n#2895154
+0 ## Clothing_parts - brim.n - n#2902250
+0 ## Clothing_parts - braid.n - n#5259512
+0 ## Clothing_parts - zip.n - n#4238321
+0 ## Clothing_parts - sole.n - n#4258982
+0 ## Clothing_parts - decolletage.n - n#3169176
+0 ## Clothing_parts - hood.n - n#3531281
+0 ## Discussion - parley.v - v#763009
+0 ## Discussion - negotiate.v - v#761713
+0 ## Discussion - dialogue.n - n#7148192
+0 ## Discussion - interlocutor.n - n#10210911
+0 ## Discussion - discussion.n - n#7140659
+0 ## Discussion - debate.v - v#813044
+0 ## Discussion - discussant.n - n#9615336
+0 ## Discussion - consultation.n - n#7143624
+0 ## Discussion - negotiation.n - n#7148192
+0 ## Discussion - meeting.n - n#1230965
+0 ## Discussion - communicate.v - v#740577
+0 ## Discussion - conference.n - n#8308497
+0 ## Discussion - communication.n - n#6252138
+0 ## Discussion - debate.n - n#7140978
+0 ## Discussion - parley.n - n#7141437
+0 ## Discussion - exchange.n - n#7134706
+0 ## Discussion - discuss.v - v#813978
+0 ## Discussion - confer.v - v#876665
+0 ## Discussion - talk.n - n#7135734
+0 ## Thwarting - prevent.v - v#2452885
+0 ## Thwarting - hamstring.v - v#1799629
+0 ## Thwarting - stop.v - v#2559752
+0 ## Thwarting - derail.v - v#2012043
+0 ## Thwarting - foil.v - v#2558172
+0 ## Thwarting - stymie.v - v#2557199
+0 ## Thwarting - frustrate.v - v#2558172
+0 ## Thwarting - preclude.v - v#2452885
+0 ## Thwarting - thwart.v - v#2558172
+0 ## Thwarting - forestall.v - v#2452885
+0 ## Thwarting - counter.v - v#2565491
+0 ## Meet_with_response - meet.v - v#2739480
+0 ## Interrupt_process - interrupt.v - v#778275
+0 ## Interrupt_process - interruption.n - n#383952
+0 ## Interrupt_process - uninterrupted.a - a#594413
+0 ## Being_in_category - constitute.v - v#2620587
+0 ## Being_in_category - count.v - v#948071
+0 ## Being_in_category - tantamount.a - a#890351
+0 ## Being_in_category - amount.v - v#2664992
+0 ## Trendiness - fashion.n - n#4928903
+0 ## Trendiness - fashionable.a - a#971075
+0 ## Trendiness - hip.a - a#1307571
+0 ## Trendiness - cool.a - a#971660
+0 ## Trendiness - chic.a - a#975487
+0 ## Trendiness - style.n - n#4928903
+0 ## Trendiness - big.a - a#1382086
+0 ## Trendiness - trendy.a - a#973677
+0 ## Risky_situation - risk.n - n#14541852
+0 ## Risky_situation - safe.a - a#2057829
+0 ## Risky_situation - dangerous.a - a#2058794
+0 ## Risky_situation - threat.n - n#14543231
+0 ## Risky_situation - warm.a - a#479192
+0 ## Risky_situation - riskily.adv - r#444198
+0 ## Risky_situation - safely.adv - r#154213
+0 ## Risky_situation - unsafe.a - a#2058794
+0 ## Risky_situation - danger.n - n#14541044
+0 ## Risky_situation - risky.a - a#2059811
+0 ## Connectors - thread.n - n#4426788
+0 ## Connectors - glue.n - n#14702875
+0 ## Connectors - tape.n - n#3708036
+0 ## Connectors - tack.n - n#4188368
+0 ## Connectors - cord.n - n#3106110
+0 ## Connectors - tie.n - n#4433185
+0 ## Connectors - link.n - n#3673971
+0 ## Connectors - bond.n - n#4181228
+0 ## Connectors - chain.n - n#2999410
+0 ## Connectors - bolt.n - n#2865665
+0 ## Connectors - connector.n - n#3091374
+0 ## Connectors - wire.n - n#4594218
+0 ## Connectors - nail.n - n#3804744
+0 ## Connectors - shoelace.n - n#4200637
+0 ## Connectors - lace.n - n#3631445
+0 ## Connectors - withy.n - n#13164403
+0 ## Connectors - strap.n - n#4333129
+0 ## Connectors - screw.n - n#4153751
+0 ## Connectors - ribbon.n - n#9409203
+0 ## Connectors - staple.n - n#4303258
+0 ## Connectors - peg.n - n#7271791
+0 ## Connectors - adhesive.n - n#14702416
+0 ## Connectors - string.n - n#3235560
+0 ## Connectors - rope.n - n#4108268
+0 ## Connectors - nut.n - n#3836191
+0 ## Surrendering_possession - relinquish.v - v#2316304
+0 ## Surrendering_possession - yield.v - v#2316649
+0 ## Surrendering_possession - surrender.v - v#1115585
+0 ## Surrendering_possession - give up.v - v#2235229
+0 ## Duration_relation - persist.v - v#2647497
+0 ## Duration_relation - last.v - v#2704928
+0 ## Eventive_affecting - happen.v - v#339934
+0 ## Eventive_affecting - strike.v - v#2611976
+0 ## Scrutiny - sweep.v - v#2685390
+0 ## Scrutiny - scrutiny.n - n#635850
+0 ## Scrutiny - search.n - n#945401
+0 ## Scrutiny - frisk.v - v#1318223
+0 ## Scrutiny - ransack.v - v#1319193
+0 ## Scrutiny - scour.v - v#1317276
+0 ## Scrutiny - investigation.n - n#633864
+0 ## Scrutiny - look.v - v#2130524
+0 ## Scrutiny - perusal.n - n#6598445
+0 ## Scrutiny - check.v - v#661824
+0 ## Scrutiny - sift.v - v#1460594
+0 ## Scrutiny - investigate.v - v#789138
+0 ## Scrutiny - sweep.n - n#5127959
+0 ## Scrutiny - peruse.v - v#2152812
+0 ## Scrutiny - rummage.v - v#1319049
+0 ## Scrutiny - surveillance_((entity)).n - n#652466
+0 ## Scrutiny - scout.v - v#2167571
+0 ## Scrutiny - once-over.n - n#143626
+0 ## Scrutiny - survey.v - v#646542
+0 ## Scrutiny - scrutinize.v - v#697062
+0 ## Scrutiny - assay.v - v#694974
+0 ## Scrutiny - survey.n - n#644503
+0 ## Scrutiny - examination.n - n#635850
+0 ## Scrutiny - surveillance.n - n#652466
+0 ## Scrutiny - comb.v - v#1319193
+0 ## Scrutiny - eyeball.v - v#2167052
+0 ## Scrutiny - monitoring.n - n#880046
+0 ## Scrutiny - search.v - v#1317723
+0 ## Scrutiny - double-check.v - v#663549
+0 ## Scrutiny - analytic.a - a#112231
+0 ## Scrutiny - inspector.n - n#10067968
+0 ## Scrutiny - go_((through)).v - v#1835496
+0 ## Scrutiny - surveyor.n - n#10680609
+0 ## Scrutiny - monitor.v - v#2163301
+0 ## Scrutiny - scan.v - v#2152278
+0 ## Scrutiny - analyst.n - n#9791530
+0 ## Scrutiny - reconnoitre.v - v#2167571
+0 ## Scrutiny - probe.v - v#788564
+0 ## Scrutiny - analysis.n - n#634276
+0 ## Scrutiny - rifle.v - v#1318849
+0 ## Scrutiny - examine.v - v#644583
+0 ## Scrutiny - study.n - n#644503
+0 ## Scrutiny - analyse.v - v#644583
+0 ## Scrutiny - skim.v - v#2152278
+0 ## Scrutiny - study.v - v#644583
+0 ## Scrutiny - pry.v - v#2169119
+0 ## Scrutiny - explore.v - v#648224
+0 ## Morality_evaluation - depravity.n - n#4850996
+0 ## Morality_evaluation - vile.a - a#1133017
+0 ## Morality_evaluation - good.a - a#1129977
+0 ## Morality_evaluation - nefarious.a - a#2515001
+0 ## Morality_evaluation - degenerate.a - a#1549568
+0 ## Morality_evaluation - moral.a - a#1548193
+0 ## Morality_evaluation - sinful.a - a#2514543
+0 ## Morality_evaluation - depraved.a - a#621524
+0 ## Morality_evaluation - righteous.a - a#2036578
+0 ## Morality_evaluation - stand-up.a - a#1237534
+0 ## Morality_evaluation - villainous.a - a#2515001
+0 ## Morality_evaluation - right.a - a#2034828
+0 ## Morality_evaluation - evil.a - a#1131043
+0 ## Morality_evaluation - virtuous.a - a#2513269
+0 ## Morality_evaluation - corrupt.a - a#620731
+0 ## Morality_evaluation - unscrupulous.a - a#2085898
+0 ## Morality_evaluation - bad.a - a#1125429
+0 ## Morality_evaluation - wicked.a - a#2513740
+0 ## Morality_evaluation - foul.a - a#1625893
+0 ## Morality_evaluation - reprobate.a - a#621524
+0 ## Morality_evaluation - immoral.a - a#1549291
+0 ## Morality_evaluation - base.a - a#2036077
+0 ## Morality_evaluation - insidious.a - a#2097884
+0 ## Morality_evaluation - honorable.a - a#2035086
+0 ## Morality_evaluation - ethical.a - a#2035086
+0 ## Morality_evaluation - low.a - a#1212469
+0 ## Morality_evaluation - upstanding.a - a#1993693
+0 ## Morality_evaluation - high-minded.a - a#1588619
+0 ## Morality_evaluation - iniquitous.a - a#2514543
+0 ## Morality_evaluation - decent.a - a#682932
+0 ## Morality_evaluation - heinous.a - a#2514380
+0 ## Morality_evaluation - dishonorable.a - a#1222884
+0 ## Morality_evaluation - felonious.a - a#1402763
+0 ## Morality_evaluation - wrong.a - a#2035337
+0 ## Morality_evaluation - unethical.a - a#905728
+0 ## Morality_evaluation - improper.a - a#1880531
+0 ## Death - asphyxiate.v - v#359511
+0 ## Death - mortality.n - n#15277118
+0 ## Death - suffocation.n - n#225593
+0 ## Death - perish.v - v#358431
+0 ## Death - expire.v - v#358431
+0 ## Death - decease.v - v#358431
+0 ## Death - demise.n - n#15143477
+0 ## Death - suffocate.v - v#359511
+0 ## Death - drown.v - v#360501
+0 ## Death - pass away.v - v#358431
+0 ## Death - die.v - v#358431
+0 ## Death - terminator.n - n#10074339
+0 ## Death - kick the bucket.v - v#358431
+0 ## Death - starvation.n - n#14040310
+0 ## Death - croak.v - v#358431
+0 ## Death - death.n - n#7355491
+0 ## Death - starve.v - v#1187537
+0 ## Communicate_categorization - portray.v - v#1688256
+0 ## Communicate_categorization - representation.n - n#5926676
+0 ## Communicate_categorization - depiction.n - n#7201804
+0 ## Communicate_categorization - redefinition.n - n#6745628
+0 ## Communicate_categorization - cast.v - v#1632897
+0 ## Communicate_categorization - paint.v - v#1684663
+0 ## Communicate_categorization - characterization.n - n#7201804
+0 ## Communicate_categorization - characterize.v - v#956687
+0 ## Communicate_categorization - definition.n - n#6744396
+0 ## Communicate_categorization - treat.v - v#651145
+0 ## Communicate_categorization - describe.v - v#987071
+0 ## Communicate_categorization - represent.v - v#1686132
+0 ## Communicate_categorization - depict.v - v#987071
+0 ## Communicate_categorization - description.n - n#6724763
+0 ## Communicate_categorization - define.v - v#957378
+0 ## Communicate_categorization - redefine.v - v#2611827
+0 ## Becoming_aware - come_(upon).v - v#1849221
+0 ## Becoming_aware - fall_(on).v - v#2729963
+0 ## Becoming_aware - chance_(on).v - v#2248465
+0 ## Becoming_aware - come_(across).v - v#1849221
+0 ## Becoming_aware - learn.v - v#598954
+0 ## Becoming_aware - tell.v - v#1009240
+0 ## Becoming_aware - detect.v - v#2154508
+0 ## Becoming_aware - happen_(on).v - v#339934
+0 ## Becoming_aware - find_out.v - v#731574
+0 ## Becoming_aware - pick up.v - v#598954
+0 ## Becoming_aware - discovery.n - n#43195
+0 ## Becoming_aware - discern.v - v#2193194
+0 ## Becoming_aware - register.v - v#2471690
+0 ## Becoming_aware - perceive.v - v#2106506
+0 ## Becoming_aware - recognize.v - v#2193194
+0 ## Becoming_aware - discover.v - v#2154508
+0 ## Becoming_aware - observe.v - v#2154508
+0 ## Becoming_aware - notice.v - v#2154508
+0 ## Becoming_aware - descry.v - v#2154312
+0 ## Becoming_aware - chance_(across).v - v#2248465
+0 ## Becoming_aware - encounter.v - v#2248465
+0 ## Becoming_aware - note.v - v#1020005
+0 ## Becoming_aware - espy.v - v#2154312
+0 ## Becoming_aware - spot.v - v#2193194
+0 ## Becoming_aware - locate.v - v#2286204
+0 ## Becoming_aware - find.v - v#2154508
+0 ## Being_strong - strong.a - a#2526124
+0 ## Being_strong - impregnable.a - a#2526124
+0 ## Cognitive_connection - connected.a - a#1973311
+0 ## Cognitive_connection - relationship.n - n#13780719
+0 ## Cognitive_connection - related.a - a#1972820
+0 ## Cognitive_connection - tied.a - a#253869
+0 ## Cognitive_connection - linked.a - a#567161
+0 ## Exemplariness - prototypical.a - a#1011392
+0 ## Exemplariness - exemplary.a - a#2586446
+0 ## Historic_event - historic.a - a#1279028
+0 ## Historic_event - historic_((entity)).a - a#1279028
+0 ## Reliance_on_expectation - bank (on).v - v#688377
+0 ## Reliance_on_expectation - count (on).v - v#712708
+0 ## Cause_to_continue - keep.v - v#2681795
+0 ## Punctual_perception - glimpse.v - v#2119470
+0 ## Punctual_perception - glimpse.n - n#877625
+0 ## Change_of_phase - freeze.v - v#445711
+0 ## Change_of_phase - evaporate.v - v#366858
+0 ## Change_of_phase - solidification.n - n#13491060
+0 ## Change_of_phase - evaporation.n - n#13572436
+0 ## Change_of_phase - vaporize.v - v#442267
+0 ## Change_of_phase - defrost.v - v#376807
+0 ## Change_of_phase - sublimation.n - n#7360293
+0 ## Change_of_phase - solidify.v - v#445169
+0 ## Change_of_phase - condense.v - v#366275
+0 ## Change_of_phase - liquefy.v - v#443984
+0 ## Change_of_phase - thaw.v - v#376106
+0 ## Change_of_phase - sublime.v - v#366020
+0 ## Change_of_phase - melt.v - v#376106
+0 ## Change_of_phase - condensation.n - n#13451348
+0 ## Topic - subject.n - n#6599788
+0 ## Topic - regard.n - n#5820170
+0 ## Topic - theme.n - n#6599788
+0 ## Topic - treat.v - v#1033527
+0 ## Topic - regard.v - v#2677097
+0 ## Topic - discuss.v - v#1034312
+0 ## Topic - dwell_(on).v - v#704249
+0 ## Topic - topic.n - n#6599788
+0 ## Topic - concern.v - v#2676054
+0 ## Topic - address.v - v#1033527
+0 ## Topic - cover.v - v#1033527
+0 ## Losing_it - go ballistic.v - v#1795428
+0 ## Losing_it - flip out.v - v#717921
+0 ## Losing_it - freak out.v - v#1784148
+0 ## Losing_it - lose it.v - v#1784295
+0 ## Addiction - fiend.n - n#10329945
+0 ## Addiction - junkie.n - n#9769076
+0 ## Addiction - hooked.a - a#47406
+0 ## Addiction - alcoholic.n - n#9782167
+0 ## Addiction - addiction.n - n#14062725
+0 ## Addiction - habit.n - n#5669034
+0 ## Addiction - addict.n - n#9769076
+0 ## Addiction - alcoholism.n - n#14064644
+0 ## Addiction - compulsive.a - a#1583659
+0 ## Addiction - addicted.a - a#47029
+0 ## Being_located - sit.v - v#1543123
+0 ## Being_located - located.a - a#2126430
+0 ## Being_located - lie.v - v#2690708
+0 ## Being_located - situated.a - a#2126430
+0 ## Being_located - stand.v - v#1546111
+0 ## Process_continue - proceed.v - v#1995549
+0 ## Process_continue - go on.v - v#2684924
+0 ## Process_continue - continue.v - v#2684924
+0 ## Process_continue - persistence.n - n#1021579
+0 ## Process_continue - persistent.a - a#1040544
+0 ## Process_continue - underway.a - a#666784
+0 ## Process_continue - drag on.v - v#341757
+0 ## Process_continue - persist.v - v#2647497
+0 ## Process_continue - on-going.a - a#667822
+0 ## Questioning - question.v - v#785008
+0 ## Questioning - inquiry.n - n#7193596
+0 ## Questioning - questioning.n - n#7193184
+0 ## Questioning - quiz.v - v#786458
+0 ## Questioning - grill.v - v#326773
+0 ## Questioning - question.n - n#7193596
+0 ## Questioning - query.v - v#785008
+0 ## Questioning - interrogate.v - v#788184
+0 ## Questioning - interrogation.n - n#7193596
+0 ## Questioning - ask.v - v#784342
+0 ## Questioning - query.n - n#7193596
+0 ## Questioning - inquire.v - v#729378
+0 ## Closure - unfasten.v - v#1344293
+0 ## Closure - uncork.v - v#1423793
+0 ## Closure - lace.v - v#1521603
+0 ## Closure - button.v - v#1367862
+0 ## Closure - unzip.v - v#1342224
+0 ## Closure - open.v - v#1346003
+0 ## Closure - buckle.v - v#1548290
+0 ## Closure - close.v - v#1345109
+0 ## Closure - cap.v - v#2693168
+0 ## Closure - fasten.v - v#1340439
+0 ## Closure - seal.v - v#1354006
+0 ## Closure - zip.v - v#1353670
+0 ## Closure - tie.v - v#1285440
+0 ## Closure - unbuckle.v - v#1548447
+0 ## Closure - unscrew.v - v#1352680
+0 ## Renting - charter.v - v#2460619
+0 ## Renting - rent.v - v#2208537
+0 ## Renting - lease.v - v#2460619
+0 ## Renting - hire.v - v#2460619
+0 ## Performers_and_roles - feature.v - v#2630189
+0 ## Performers_and_roles - star.v - v#2631349
+0 ## Performers_and_roles - co-star_(in).v - v#2631537
+0 ## Performers_and_roles - act.v - v#1719302
+0 ## Performers_and_roles - be.v - v#2604760
+0 ## Performers_and_roles - star.n - n#10648696
+0 ## Performers_and_roles - star_(in).v - v#2631349
+0 ## Performers_and_roles - play.v - v#1719302
+0 ## Performers_and_roles - co-star.n - n#9967967
+0 ## Performers_and_roles - character.n - n#5929008
+0 ## Performers_and_roles - part.n - n#5929008
+0 ## Performers_and_roles - role.n - n#5929008
+0 ## Performers_and_roles - lead.n - n#10648696
+0 ## Performers_and_roles - co-star.v - v#2631537
+0 ## Seeking - palpate.v - v#1210352
+0 ## Seeking - search.v - v#2153709
+0 ## Seeking - seek.v - v#1315613
+0 ## Seeking - watch.v - v#2150510
+0 ## Seeking - nose.v - v#2169119
+0 ## Seeking - feel.v - v#2127613
+0 ## Seeking - pan.v - v#1536508
+0 ## Seeking - sniff.v - v#2125032
+0 ## Seeking - fumble.v - v#1314738
+0 ## Seeking - listen.v - v#2171039
+0 ## Seeking - grope.v - v#1314738
+0 ## Seeking - hunt.v - v#1316401
+0 ## Seeking - forage.v - v#2269894
+0 ## Seeking - look.v - v#2130524
+0 ## Seeking - rummage.v - v#1319049
+0 ## Seeking - probe.v - v#788564
+0 ## Clothing - waistcoat.n - n#4531873
+0 ## Clothing - stole.n - n#4325704
+0 ## Clothing - jumper.n - n#4370048
+0 ## Clothing - cummerbund.n - n#3147397
+0 ## Clothing - cowl.n - n#3124474
+0 ## Clothing - poncho.n - n#3980874
+0 ## Clothing - smock.n - n#3258730
+0 ## Clothing - overall.n - n#3863262
+0 ## Clothing - abaya.n - n#2667093
+0 ## Clothing - slipper.n - n#4241394
+0 ## Clothing - kimono.n - n#3617480
+0 ## Clothing - chasuble.n - n#3010795
+0 ## Clothing - pants.n - n#2854739
+0 ## Clothing - underclothing.n - n#4508949
+0 ## Clothing - fishnet.n - n#3352628
+0 ## Clothing - pullover.n - n#4021028
+0 ## Clothing - sweatshirt.n - n#4370456
+0 ## Clothing - underwear.n - n#4508949
+0 ## Clothing - dress.n - n#3236735
+0 ## Clothing - glove.n - n#3441112
+0 ## Clothing - jumpsuit.n - n#3605598
+0 ## Clothing - sarong.n - n#4136333
+0 ## Clothing - sweater.n - n#4370048
+0 ## Clothing - shawl.n - n#4186455
+0 ## Clothing - stocking.n - n#4323819
+0 ## Clothing - raincoat.n - n#4049405
+0 ## Clothing - coverall.n - n#3121897
+0 ## Clothing - brassiere.n - n#2892767
+0 ## Clothing - clothes.n - n#2728440
+0 ## Clothing - galosh.n - n#2735538
+0 ## Clothing - vestment.n - n#4532106
+0 ## Clothing - nightgown.n - n#3824381
+0 ## Clothing - tutu.n - n#2780815
+0 ## Clothing - bow-tie.n - n#2883205
+0 ## Clothing - silks.n - n#4219580
+0 ## Clothing - doublet.n - n#3228254
+0 ## Clothing - stiletto.n - n#4318892
+0 ## Clothing - motley.n - n#3789794
+0 ## Clothing - tunic.n - n#4497570
+0 ## Clothing - apron.n - n#2730930
+0 ## Clothing - sari.n - n#4136161
+0 ## Clothing - bodice.n - n#2861387
+0 ## Clothing - greatcoat.n - n#3456665
+0 ## Clothing - kaftan.n - n#2936570
+0 ## Clothing - cardigan.n - n#2963159
+0 ## Clothing - raiment.n - n#2742322
+0 ## Clothing - pallium.n - n#3880129
+0 ## Clothing - tights.n - n#4434932
+0 ## Clothing - undergarment.n - n#4508163
+0 ## Clothing - gown.n - n#3824381
+0 ## Clothing - windbreaker.n - n#3891051
+0 ## Clothing - overcoat.n - n#3456665
+0 ## Clothing - bathrobe.n - n#2807616
+0 ## Clothing - finery.n - n#3340923
+0 ## Clothing - polo-neck.n - n#4502197
+0 ## Clothing - boot.n - n#2872752
+0 ## Clothing - slip.n - n#3013580
+0 ## Clothing - ensemble.n - n#3289985
+0 ## Clothing - sundress.n - n#4355511
+0 ## Clothing - garb.n - n#2756098
+0 ## Clothing - undies.n - n#4509171
+0 ## Clothing - windcheater.n - n#3891051
+0 ## Clothing - pinafore.n - n#3604400
+0 ## Clothing - sweatpants.n - n#4370288
+0 ## Clothing - clog.n - n#3047690
+0 ## Clothing - shift.n - n#3013580
+0 ## Clothing - tie.n - n#3815615
+0 ## Clothing - skirt.n - n#4230808
+0 ## Clothing - gauntlet.n - n#3429771
+0 ## Clothing - tippet.n - n#4440597
+0 ## Clothing - sneaker.n - n#3472535
+0 ## Clothing - knickers.n - n#2896442
+0 ## Clothing - regalia.n - n#2742322
+0 ## Clothing - cravat.n - n#3128085
+0 ## Clothing - wellington.n - n#3516844
+0 ## Clothing - shoe.n - n#4199027
+0 ## Clothing - nightie.n - n#3824381
+0 ## Clothing - garter.n - n#3421117
+0 ## Clothing - shirt.n - n#4197391
+0 ## Clothing - robe.n - n#4097866
+0 ## Clothing - briefs.n - n#2901114
+0 ## Clothing - parka.n - n#3891051
+0 ## Clothing - jacket.n - n#3589791
+0 ## Clothing - apparel.n - n#2728440
+0 ## Clothing - footwear.n - n#3380867
+0 ## Clothing - surplice.n - n#4364994
+0 ## Clothing - hosiery.n - n#3540267
+0 ## Clothing - clothing.n - n#3051540
+0 ## Clothing - camisole.n - n#2944146
+0 ## Clothing - cope.n - n#3103904
+0 ## Clothing - bra.n - n#2892767
+0 ## Clothing - swimsuit.n - n#4371563
+0 ## Clothing - teddy.n - n#3013580
+0 ## Clothing - alb.n - n#2694966
+0 ## Clothing - armour.n - n#2739668
+0 ## Clothing - muff.n - n#3796974
+0 ## Clothing - crinoline.n - n#3132776
+0 ## Clothing - neckwear.n - n#3816005
+0 ## Clothing - nightwear.n - n#3825080
+0 ## Clothing - buskin.n - n#2925666
+0 ## Clothing - blouse.n - n#2854926
+0 ## Clothing - jodhpurs.n - n#3600285
+0 ## Clothing - two-piece.n - n#4504141
+0 ## Clothing - garment.n - n#3419014
+0 ## Clothing - blazer.n - n#2850358
+0 ## Clothing - g-string.n - n#3464053
+0 ## Clothing - hose.n - n#3540267
+0 ## Clothing - chemise.n - n#3013580
+0 ## Clothing - frock.n - n#3236735
+0 ## Clothing - underclothes.n - n#4508949
+0 ## Clothing - cloak.n - n#3045337
+0 ## Clothing - mitt.n - n#2800213
+0 ## Clothing - outfit.n - n#3859958
+0 ## Clothing - uniform.n - n#4509592
+0 ## Clothing - sandal.n - n#4133789
+0 ## Clothing - cape.n - n#2955767
+0 ## Clothing - pantyhose.n - n#3885904
+0 ## Clothing - sock.n - n#4254777
+0 ## Clothing - t-shirt.n - n#3595614
+0 ## Clothing - scarf.n - n#4143897
+0 ## Clothing - vest.n - n#4531873
+0 ## Clothing - necktie.n - n#3815615
+0 ## Clothing - togs.n - n#4446162
+0 ## Clothing - kilt.n - n#3617312
+0 ## Clothing - jerkin.n - n#3595264
+0 ## Clothing - livery.n - n#3679174
+0 ## Clothing - lingerie.n - n#3673450
+0 ## Clothing - shorts.n - n#4205318
+0 ## Clothing - bikini.n - n#2837789
+0 ## Clothing - neckerchief.n - n#3814817
+0 ## Clothing - wrap.n - n#4605446
+0 ## Clothing - mitten.n - n#3775071
+0 ## Clothing - nightdress.n - n#3824381
+0 ## Clothing - costume.n - n#3114041
+0 ## Clothing - breeches.n - n#2896442
+0 ## Clothing - miniskirt.n - n#3770439
+0 ## Clothing - petticoat.n - n#3920737
+0 ## Clothing - pyjama.n - n#3877472
+0 ## Clothing - coat.n - n#3057021
+0 ## Clothing - attire.n - n#2756098
+0 ## Clothing - suit.n - n#4350905
+0 ## Clothing - corset.n - n#3112869
+0 ## Information - info.n - n#6634376
+0 ## Information - information.n - n#6634376
+0 ## Information - skinny.n - n#7218853
+0 ## Information - scoop.n - n#6683183
+0 ## Information - data.n - n#8462320
+0 ## Information - intelligence.n - n#6642672
+0 ## Information - dirt.n - n#14844693
+0 ## Information - details.n - n#6635944
+0 ## Information - dope.n - n#6636113
+0 ## Fluidic_motion - leak.v - v#529759
+0 ## Fluidic_motion - bubble.v - v#2187922
+0 ## Fluidic_motion - soak.v - v#1578513
+0 ## Fluidic_motion - flow.v - v#2066939
+0 ## Fluidic_motion - spill.v - v#2069888
+0 ## Fluidic_motion - rush.v - v#2059770
+0 ## Fluidic_motion - percolate.v - v#2071627
+0 ## Fluidic_motion - ooze.v - v#2071974
+0 ## Fluidic_motion - trickle.v - v#2070874
+0 ## Fluidic_motion - spew.v - v#77071
+0 ## Fluidic_motion - splash.v - v#1374767
+0 ## Fluidic_motion - stream.v - v#2070466
+0 ## Fluidic_motion - squirt.v - v#1313411
+0 ## Fluidic_motion - hiss.v - v#2069014
+0 ## Fluidic_motion - drip.v - v#2071142
+0 ## Fluidic_motion - run.v - v#2066939
+0 ## Fluidic_motion - jet.v - v#1516290
+0 ## Fluidic_motion - seep.v - v#2071974
+0 ## Fluidic_motion - course.v - v#2066939
+0 ## Fluidic_motion - spurt.v - v#2068413
+0 ## Fluidic_motion - spout.v - v#2068413
+0 ## Fluidic_motion - cascade.v - v#2071316
+0 ## Fluidic_motion - gush.v - v#1516290
+0 ## Fluidic_motion - dribble.v - v#2070874
+0 ## Fluidic_motion - purl.v - v#2047650
+0 ## Inhibit_movement - detain.v - v#2495038
+0 ## Inhibit_movement - hold.v - v#2681795
+0 ## Inhibit_movement - confinement.n - n#13998576
+0 ## Inhibit_movement - tie.v - v#234217
+0 ## Inhibit_movement - confine.v - v#233335
+0 ## Inhibit_movement - immure.v - v#2494356
+0 ## Inhibit_movement - restrict.v - v#233335
+0 ## Inhibit_movement - lock.v - v#1606736
+0 ## Inhibit_movement - imprison.v - v#2494356
+0 ## Shoot_projectiles - fire.v - v#1133825
+0 ## Shoot_projectiles - launch.v - v#2427103
+0 ## Shoot_projectiles - launch.n - n#103140
+0 ## Shoot_projectiles - shoot.v - v#1134781
+0 ## Remembering_to_do - forget.v - v#610167
+0 ## Remembering_to_do - remember.v - v#607780
+0 ## Position_on_a_scale - lacking.a - a#52012
+0 ## Position_on_a_scale - rich.a - a#2021905
+0 ## Position_on_a_scale - low.a - a#1212469
+0 ## Position_on_a_scale - high.a - a#1210854
+0 ## Position_on_a_scale - deficient.a - a#52012
+0 ## Position_on_a_scale - advanced.a - a#1211296
+0 ## Position_on_a_scale - medium.a - a#1531957
+0 ## Being_in_effect - effect.n - n#11410625
+0 ## Being_in_effect - effective.a - a#832784
+0 ## Being_in_effect - binding.a - a#2499036
+0 ## Being_in_effect - valid.a - a#2498708
+0 ## Being_in_effect - void.a - a#2500590
+0 ## Being_in_effect - force.n - n#5194578
+0 ## Being_in_effect - null.a - a#2500590
+0 ## Commitment - vow.v - v#886759
+0 ## Commitment - covenant.n - n#6525588
+0 ## Commitment - promise.n - n#7226545
+0 ## Commitment - commit.v - v#887463
+0 ## Commitment - volunteer.v - v#2425112
+0 ## Commitment - promise.v - v#884011
+0 ## Commitment - oath.n - n#7226841
+0 ## Commitment - commitment.n - n#6684383
+0 ## Commitment - vow.n - n#7228751
+0 ## Commitment - undertaking.n - n#795720
+0 ## Commitment - swear.v - v#889947
+0 ## Commitment - threaten.v - v#2697120
+0 ## Commitment - covenant.v - v#1030832
+0 ## Commitment - pledge.n - n#7227772
+0 ## Commitment - threat.n - n#6733476
+0 ## Commitment - undertake.v - v#889555
+0 ## Commitment - consent.v - v#797697
+0 ## Commitment - pledge.v - v#884540
+0 ## Quitting - resignation.n - n#6511560
+0 ## Quitting - resign.v - v#2382367
+0 ## Quitting - retirement.n - n#13954118
+0 ## Quitting - retire.v - v#2379753
+0 ## Quitting - step down.v - v#2382367
+0 ## Quitting - give notice.v - v#2402825
+0 ## Quitting - quit.v - v#2382367
+0 ## Quitting - leave.v - v#2009433
+0 ## Claim_ownership - dibs.n - n#6730241
+0 ## Claim_ownership - claim.n - n#6729864
+0 ## Claim_ownership - call.v - v#1028748
+0 ## Claim_ownership - claim.v - v#756338
+0 ## Undressing - doff.v - v#1590658
+0 ## Undressing - remove.v - v#173338
+0 ## Undressing - pull off.v - v#1592774
+0 ## Undressing - take off.v - v#179060
+0 ## Undressing - shed.v - v#1513430
+0 ## Undressing - peel off.v - v#9492
+0 ## Undressing - throw off.v - v#1513430
+0 ## Undressing - slip.v - v#1888295
+0 ## Undressing - kick off.v - v#2395782
+0 ## Undressing - undress.v - v#177243
+0 ## Suspicion - suspect.v - v#687926
+0 ## Suspicion - suspect.n - n#10681383
+0 ## Subjective_temperature - burn up.v - v#2762806
+0 ## Subjective_temperature - cold.a - a#1251128
+0 ## Subjective_temperature - cool.a - a#2529945
+0 ## Subjective_temperature - hot.a - a#1247240
+0 ## Subjective_temperature - warm.a - a#2529264
+0 ## Change_operational_state - cut off.v - v#778275
+0 ## Change_operational_state - activate.v - v#190682
+0 ## Change_operational_state - deactivate.v - v#191517
+0 ## Change_operational_state - turn on.v - v#1510399
+0 ## Change_operational_state - turn off.v - v#1510576
+0 ## Change_operational_state - cut.v - v#1552519
+0 ## Change_operational_state - boot.v - v#98346
+0 ## Guilt_or_innocence - guilty.a - a#154583
+0 ## Guilt_or_innocence - guilt.n - n#13990675
+0 ## Guilt_or_innocence - innocence.n - n#13989627
+0 ## Guilt_or_innocence - innocent.a - a#1319874
+0 ## Memory - remember.v - v#607780
+0 ## Memory - recall.v - v#607780
+0 ## Memory - memory.n - n#5760202
+0 ## Memory - recollect.v - v#607780
+0 ## Memory - recollection.n - n#5761559
+0 ## Memory - retain.v - v#610010
+0 ## Create_representation - carve.v - v#1256157
+0 ## Create_representation - sketch.v - v#1697628
+0 ## Create_representation - draw.v - v#1690294
+0 ## Create_representation - photograph.v - v#1003249
+0 ## Create_representation - paint.v - v#1684899
+0 ## Create_representation - cast.v - v#1078050
+0 ## Cause_to_be_sharp - blunt.v - v#2115273
+0 ## Cause_to_be_sharp - dull.v - v#2115273
+0 ## Cause_to_be_sharp - sharpen.v - v#1246601
+0 ## Evaluative_comparison - stack up.v - v#1504298
+0 ## Evaluative_comparison - equal.v - v#2672187
+0 ## Evaluative_comparison - comparable.a - a#503982
+0 ## Evaluative_comparison - match.n - n#9626238
+0 ## Evaluative_comparison - measure up.v - v#2679012
+0 ## Evaluative_comparison - compare.v - v#652900
+0 ## Evaluative_comparison - match.v - v#2672187
+0 ## Evaluative_comparison - rival.v - v#2672187
+0 ## Pardon - pardon.n - n#1227190
+0 ## Pardon - pardon.v - v#905852
+0 ## Robbery - hold_up.v - v#2277448
+0 ## Robbery - rob.v - v#2321391
+0 ## Robbery - mug.v - v#2277663
+0 ## Robbery - mugger.n - n#10337300
+0 ## Robbery - rifle.v - v#2344568
+0 ## Robbery - mugging.n - n#774009
+0 ## Robbery - robber.n - n#10534586
+0 ## Robbery - ransack.v - v#2344568
+0 ## Robbery - robbery.n - n#781685
+0 ## Robbery - stick up.v - v#2277448
+0 ## Estimating - estimate.v - v#672433
+0 ## Estimating - estimation.n - n#5803379
+0 ## Estimating - guess.v - v#631737
+0 ## Optical_image - image.n - n#10027246
+0 ## Optical_image - shadow.n - n#8646306
+0 ## Optical_image - silhouette.n - n#8613345
+0 ## Dead_or_alive - living.a - a#1941274
+0 ## Dead_or_alive - alive.a - a#94448
+0 ## Dead_or_alive - dead.a - a#95280
+0 ## Dead_or_alive - lifeless.a - a#97768
+0 ## Dead_or_alive - living.n - n#13961642
+0 ## Dead_or_alive - nonliving.a - a#118238
+0 ## Dead_or_alive - dead.n - n#7945657
+0 ## Dead_or_alive - deceased.a - a#95873
+0 ## Corroding_caused - oxidize.v - v#238867
+0 ## Corroding_caused - corrode.v - v#274283
+0 ## Corroding_caused - tarnish.v - v#1537409
+0 ## Communication_noise - drone.v - v#2188442
+0 ## Communication_noise - yelp.v - v#1048171
+0 ## Communication_noise - croon.v - v#1049470
+0 ## Communication_noise - rasp.v - v#1386906
+0 ## Communication_noise - chirrup.v - v#1052301
+0 ## Communication_noise - yell.v - v#913065
+0 ## Communication_noise - thunder.v - v#1046587
+0 ## Communication_noise - growl.v - v#1045719
+0 ## Communication_noise - bawl.v - v#1048569
+0 ## Communication_noise - howl.v - v#1046932
+0 ## Communication_noise - cackle.v - v#1056554
+0 ## Communication_noise - chuckle.v - v#31663
+0 ## Communication_noise - hiss.v - v#1053771
+0 ## Communication_noise - whine.v - v#2171664
+0 ## Communication_noise - rap.v - v#1414288
+0 ## Communication_noise - trill.v - v#1050896
+0 ## Communication_noise - coo.v - v#910000
+0 ## Communication_noise - bark.v - v#1047745
+0 ## Communication_noise - groan.v - v#1045419
+0 ## Communication_noise - purr.v - v#1052936
+0 ## Communication_noise - wail.v - v#1046932
+0 ## Communication_noise - moan.v - v#1045419
+0 ## Communication_noise - shrill.v - v#914420
+0 ## Communication_noise - wheeze.v - v#6697
+0 ## Communication_noise - whimper.v - v#66025
+0 ## Communication_noise - titter.v - v#30142
+0 ## Communication_noise - squeak.v - v#2171664
+0 ## Communication_noise - whoop.v - v#914215
+0 ## Communication_noise - hoot.v - v#1042725
+0 ## Communication_noise - gasp.v - v#5526
+0 ## Communication_noise - trumpet.v - v#977871
+0 ## Communication_noise - grate.v - v#1394464
+0 ## Communication_noise - snarl.v - v#916274
+0 ## Communication_noise - scream.v - v#913065
+0 ## Communication_noise - cry.v - v#913065
+0 ## Communication_noise - roar.v - v#1046932
+0 ## Communication_noise - squeal.v - v#1054694
+0 ## Communication_noise - grunt.v - v#1043231
+0 ## Communication_noise - burble.v - v#2187922
+0 ## Communication_noise - chirp.v - v#1052301
+0 ## Communication_noise - rumble.v - v#2187320
+0 ## Communication_noise - screech.v - v#1048939
+0 ## Communication_noise - croak.v - v#909219
+0 ## Communication_noise - warble.v - v#1050896
+0 ## Communication_noise - squawk.v - v#1048939
+0 ## Communication_noise - murmur.v - v#1044114
+0 ## Communication_noise - shriek.v - v#914420
+0 ## Communication_noise - sputter.v - v#986897
+0 ## Communication_noise - crow.v - v#883635
+0 ## Communication_noise - rattle.v - v#2175057
+0 ## Communication_noise - splutter.v - v#986897
+0 ## Communication_noise - bellow.v - v#1048718
+0 ## Communication_noise - bleat.v - v#1048492
+0 ## Communication_noise - bray.v - v#1054553
+0 ## Communication_noise - cluck.v - v#1054849
+0 ## Communication_noise - gurgle.v - v#2177976
+0 ## Communication_noise - babble.n - n#6610143
+0 ## Communication_noise - snort.v - v#6523
+0 ## Communication_noise - twitter.v - v#1053623
+0 ## Omen - promising.a - a#176387
+0 ## Omen - betoken.v - v#871942
+0 ## Omen - presage.v - v#871942
+0 ## Omen - bode.v - v#871942
+0 ## Omen - omen.n - n#7286368
+0 ## Omen - harbinger.n - n#6802571
+0 ## Omen - foreshadow.v - v#871942
+0 ## Omen - presage.n - n#7286368
+0 ## Omen - forebode.v - v#917772
+0 ## Omen - foretell.v - v#871942
+0 ## Omen - prefigure.v - v#871942
+0 ## Omen - herald.v - v#974173
+0 ## Omen - threaten.v - v#871781
+0 ## Omen - announce.v - v#974173
+0 ## Omen - foreshadowing.n - n#5776015
+0 ## Omen - augur.v - v#871942
+0 ## Omen - promise.v - v#917772
+0 ## Omen - portend.v - v#871942
+0 ## Omen - promise.n - n#7226545
+0 ## Omen - ominous.a - a#194357
+0 ## Omen - portent.n - n#7286368
+0 ## Omen - foretoken.n - n#7286014
+0 ## Ordinal_numbers - ninth.a - a#2203249
+0 ## Ordinal_numbers - third.a - a#2202307
+0 ## Ordinal_numbers - seventeenth.a - a#2204237
+0 ## Ordinal_numbers - fifth.a - a#2202712
+0 ## Ordinal_numbers - fourth.a - a#2202443
+0 ## Ordinal_numbers - second.a - a#2202146
+0 ## Ordinal_numbers - first.a - a#1010862
+0 ## Ordinal_numbers - thirteenth.a - a#2203763
+0 ## Ordinal_numbers - nineteenth.a - a#2204472
+0 ## Ordinal_numbers - sixteenth.a - a#2204131
+0 ## Ordinal_numbers - final.a - a#1010271
+0 ## Ordinal_numbers - last.a - a#1730329
+0 ## Ordinal_numbers - eighth.a - a#2203123
+0 ## Ordinal_numbers - tenth.a - a#2203373
+0 ## Apply_heat - singe.v - v#378521
+0 ## Apply_heat - broil.v - v#2755565
+0 ## Apply_heat - plank.v - v#1180701
+0 ## Apply_heat - stew.v - v#323856
+0 ## Apply_heat - microwave.v - v#321936
+0 ## Apply_heat - fry.v - v#325328
+0 ## Apply_heat - scald.v - v#371717
+0 ## Apply_heat - char.v - v#379440
+0 ## Apply_heat - barbecue.v - v#324806
+0 ## Apply_heat - bake.v - v#2755565
+0 ## Apply_heat - blanch.v - v#322559
+0 ## Apply_heat - sear.v - v#379440
+0 ## Apply_heat - coddle.v - v#320410
+0 ## Apply_heat - grill.v - v#326773
+0 ## Apply_heat - parboil.v - v#322559
+0 ## Apply_heat - braise.v - v#325208
+0 ## Apply_heat - steep.v - v#327362
+0 ## Apply_heat - saute.v - v#326619
+0 ## Apply_heat - simmer.v - v#324231
+0 ## Apply_heat - boil.v - v#328128
+0 ## Apply_heat - poach.v - v#544404
+0 ## Apply_heat - toast.v - v#322151
+0 ## Apply_heat - cook.v - v#322847
+0 ## Apply_heat - roast.v - v#324560
+0 ## Apply_heat - steam.v - v#327145
+0 ## Apply_heat - brown.v - v#320246
+0 ## Amassing - hoard.v - v#2304982
+0 ## Amassing - stockpile.v - v#2285392
+0 ## Amassing - amass.v - v#2304982
+0 ## Amassing - accumulate.v - v#2304982
+0 ## Drop_in_on - pop in.v - v#1920330
+0 ## Drop_in_on - drop in.v - v#2488641
+0 ## Being_wet - sodden.a - a#2549032
+0 ## Being_wet - waterlogged.a - a#2548066
+0 ## Being_wet - clammy.a - a#2548619
+0 ## Being_wet - saturated.a - a#757923
+0 ## Being_wet - soaked.a - a#798103
+0 ## Being_wet - soggy.a - a#2548066
+0 ## Being_wet - humid.a - a#2549393
+0 ## Being_wet - dewy.a - a#2547862
+0 ## Being_wet - wet.a - a#2547317
+0 ## Being_wet - drenched.a - a#1696165
+0 ## Being_wet - damp.a - a#2548820
+0 ## Being_wet - moist.a - a#2548820
+0 ## Breaking_apart - break down.v - v#1784295
+0 ## Breaking_apart - break_apart.v - v#368662
+0 ## Breaking_apart - shatter.v - v#333758
+0 ## Breaking_apart - break.v - v#334186
+0 ## Breaking_apart - snap.v - v#337065
+0 ## Breaking_apart - splinter.v - v#337903
+0 ## Breaking_apart - fragment.v - v#338071
+0 ## Unattributed_information - rumor.n - n#7223450
+0 ## Unattributed_information - ostensibly.adv - r#39941
+0 ## Unattributed_information - ostensible.a - a#1873985
+0 ## Unattributed_information - proverbial.a - a#2990304
+0 ## Unattributed_information - allegedly.adv - r#154307
+0 ## Unattributed_information - purportedly.adv - r#154449
+0 ## Unattributed_information - reportedly.adv - r#200927
+0 ## Unattributed_information - supposedly.adv - r#154449
+0 ## Unattributed_information - rumor.v - v#1042228
+0 ## Unattributed_information - alleged.a - a#687614
+0 ## Containers - handbag.n - n#2774152
+0 ## Containers - beaker.n - n#2815834
+0 ## Containers - carafe.n - n#2960903
+0 ## Containers - tank.n - n#4388743
+0 ## Containers - snifter.n - n#4249882
+0 ## Containers - creamer.n - n#3129001
+0 ## Containers - pot_cooking.n - n#3990474
+0 ## Containers - valise.n - n#4518764
+0 ## Containers - dish.n - n#3206908
+0 ## Containers - tun.n - n#4497442
+0 ## Containers - case.n - n#2974697
+0 ## Containers - pack.n - n#13775093
+0 ## Containers - tin.n - n#4438897
+0 ## Containers - can.n - n#2946921
+0 ## Containers - canister.n - n#2949542
+0 ## Containers - bin.n - n#2839910
+0 ## Containers - dispenser.n - n#3210683
+0 ## Containers - flagon.n - n#3355768
+0 ## Containers - etui.n - n#3301291
+0 ## Containers - magnum.n - n#3709363
+0 ## Containers - flask.n - n#3359566
+0 ## Containers - goblet.n - n#3002948
+0 ## Containers - chest.n - n#3014705
+0 ## Containers - jigger.n - n#4206225
+0 ## Containers - cauldron.n - n#2939185
+0 ## Containers - cask.n - n#2795169
+0 ## Containers - jug.n - n#3603722
+0 ## Containers - backpack.n - n#2769748
+0 ## Containers - punch bowl.n - n#4023695
+0 ## Containers - decanter.n - n#2960903
+0 ## Containers - glass.n - n#3438257
+0 ## Containers - bag.n - n#2773037
+0 ## Containers - hopper.n - n#3535284
+0 ## Containers - vial.n - n#3923379
+0 ## Containers - cylinder.n - n#13899804
+0 ## Containers - bowl.n - n#2881397
+0 ## Containers - vat.n - n#4493381
+0 ## Containers - teaspoon.n - n#4398688
+0 ## Containers - goldfish bowl.n - n#1443537
+0 ## Containers - carton.n - n#2971356
+0 ## Containers - chalice.n - n#3002948
+0 ## Containers - cartridge.n - n#2972182
+0 ## Containers - jeroboam.n - n#3595409
+0 ## Containers - bottle.n - n#2876657
+0 ## Containers - basin.n - n#2801525
+0 ## Containers - container.n - n#3094503
+0 ## Containers - cart.n - n#3484083
+0 ## Containers - grail.n - n#3451909
+0 ## Containers - spittoon.n - n#4281260
+0 ## Containers - envelope.n - n#3291819
+0 ## Containers - cooler.n - n#3102771
+0 ## Containers - duffel bag.n - n#3253886
+0 ## Containers - cruet.n - n#3140431
+0 ## Containers - wallet.n - n#4548362
+0 ## Containers - drawer.n - n#3233905
+0 ## Containers - tumbler.n - n#4496872
+0 ## Containers - spoon.n - n#4284002
+0 ## Containers - salver.n - n#4131929
+0 ## Containers - coffin.n - n#3064758
+0 ## Containers - crucible.n - n#3140126
+0 ## Containers - tureen.n - n#4499062
+0 ## Containers - pipette.n - n#3947111
+0 ## Containers - locker.n - n#2933462
+0 ## Containers - cuspidor.n - n#4281260
+0 ## Containers - haversack.n - n#2769748
+0 ## Containers - basket.n - n#2801938
+0 ## Containers - purse.n - n#2774152
+0 ## Containers - thermos.n - n#4422727
+0 ## Containers - vivarium.n - n#4539203
+0 ## Containers - reservoir.n - n#4078574
+0 ## Containers - suitcase.n - n#2773838
+0 ## Containers - censer.n - n#2993368
+0 ## Containers - planter.n - n#3957315
+0 ## Containers - samovar.n - n#4132985
+0 ## Containers - amphora.n - n#2705429
+0 ## Containers - folder.n - n#6413889
+0 ## Containers - jar.n - n#3593526
+0 ## Containers - casket.n - n#3064758
+0 ## Containers - sack.n - n#4122825
+0 ## Containers - canteen.n - n#2952374
+0 ## Containers - drum.n - n#13901211
+0 ## Containers - mug.n - n#3797390
+0 ## Containers - urn.n - n#4516214
+0 ## Containers - pot.n - n#3990474
+0 ## Containers - satchel.n - n#4137217
+0 ## Containers - keg.n - n#3610418
+0 ## Containers - briefcase.n - n#2900705
+0 ## Containers - pannier.n - n#3883524
+0 ## Containers - mailer.n - n#3710528
+0 ## Containers - ramekin.n - n#4050933
+0 ## Containers - hamper.n - n#3482405
+0 ## Containers - crock.n - n#3133415
+0 ## Containers - coffer.n - n#3064350
+0 ## Containers - casserole.n - n#7580359
+0 ## Containers - pouch.n - n#3993180
+0 ## Containers - carryall.n - n#2970408
+0 ## Containers - overnighter.n - n#3865371
+0 ## Containers - stein.n - n#2824058
+0 ## Containers - crate.n - n#3127925
+0 ## Containers - sarcophagus.n - n#4136045
+0 ## Containers - pail.n - n#2909870
+0 ## Containers - knapsack.n - n#2769748
+0 ## Containers - rucksack.n - n#2769748
+0 ## Containers - safe.n - n#4125021
+0 ## Containers - reticule.n - n#4083309
+0 ## Containers - ampule.n - n#3923379
+0 ## Containers - box.n - n#2883344
+0 ## Containers - ladle.n - n#3633091
+0 ## Containers - vase.n - n#4522168
+0 ## Containers - empty.n - n#3284308
+0 ## Containers - capsule.n - n#2957755
+0 ## Containers - bucket.n - n#2909870
+0 ## Containers - cup.n - n#3147509
+0 ## Containers - barrel.n - n#2795169
+0 ## Working_on - plug away.v - v#2415573
+0 ## Working_on - work.v - v#2413480
+0 ## Working_on - work.n - n#4599396
+0 ## Working_on - peg away.v - v#2415573
+0 ## Relational_quantity - nearly.adv - r#73033
+0 ## Relational_quantity - minimum.n - n#13763384
+0 ## Relational_quantity - close (to).a - a#451510
+0 ## Relational_quantity - at least.adv - r#104661
+0 ## Relational_quantity - precisely.adv - r#158309
+0 ## Relational_quantity - at most.adv - r#104528
+0 ## Relational_quantity - or so.adv - r#7015
+0 ## Relational_quantity - thereabouts.adv - r#467810
+0 ## Relational_quantity - odd.a - a#913454
+0 ## Relational_quantity - barely.adv - r#2621
+0 ## Relational_quantity - roughly.adv - r#7015
+0 ## Relational_quantity - exactly.adv - r#158309
+0 ## Relational_quantity - approximately.adv - r#7015
+0 ## Statement - allegation.n - n#6731186
+0 ## Statement - proposal.n - n#7162194
+0 ## Statement - say.v - v#1009240
+0 ## Statement - exclaim.v - v#977336
+0 ## Statement - refute.v - v#814850
+0 ## Statement - tell.v - v#1009240
+0 ## Statement - write.v - v#1698271
+0 ## Statement - note.v - v#1020005
+0 ## Statement - contention.n - n#6731378
+0 ## Statement - reaffirm.v - v#1011923
+0 ## Statement - claim.v - v#756338
+0 ## Statement - contend.v - v#756898
+0 ## Statement - statement.n - n#6722453
+0 ## Statement - report.n - n#7218470
+0 ## Statement - avow.v - v#1011031
+0 ## Statement - address.v - v#897564
+0 ## Statement - message.n - n#6598915
+0 ## Statement - promulgation.n - n#6726939
+0 ## Statement - affirmation.n - n#7203126
+0 ## Statement - report.v - v#965035
+0 ## Statement - assert.v - v#1016778
+0 ## Statement - announce.v - v#965871
+0 ## Statement - avowal.n - n#6732350
+0 ## Statement - talk.v - v#962447
+0 ## Statement - suggest.v - v#875394
+0 ## Statement - pronouncement.n - n#6727616
+0 ## Statement - profess.v - v#818553
+0 ## Statement - deny.v - v#816556
+0 ## Statement - exclamation.n - n#7125523
+0 ## Statement - aver.v - v#1011031
+0 ## Statement - add.v - v#1027174
+0 ## Statement - observe.v - v#1020005
+0 ## Statement - preach.v - v#828003
+0 ## Statement - allege.v - v#1016002
+0 ## Statement - insist.v - v#818974
+0 ## Statement - proposition.n - n#6750804
+0 ## Statement - admit.v - v#817311
+0 ## Statement - confirm.v - v#1012073
+0 ## Statement - gloat.v - v#883635
+0 ## Statement - remark.n - n#6765044
+0 ## Statement - insistence.n - n#14451349
+0 ## Statement - state.v - v#1009240
+0 ## Statement - attest.v - v#820352
+0 ## Statement - smirk.v - v#29336
+0 ## Statement - announcement.n - n#6726158
+0 ## Statement - proclaim.v - v#977336
+0 ## Statement - denial.n - n#7204240
+0 ## Statement - concede.v - v#818553
+0 ## Statement - caution.v - v#871195
+0 ## Statement - admission.n - n#7215948
+0 ## Statement - relate.v - v#953058
+0 ## Statement - mention.n - n#6766190
+0 ## Statement - propose.v - v#875394
+0 ## Statement - describe.v - v#965035
+0 ## Statement - venture.v - v#2545272
+0 ## Statement - comment.n - n#6765044
+0 ## Statement - reiterate.v - v#958334
+0 ## Statement - explanation.n - n#6738281
+0 ## Statement - remark.v - v#1020005
+0 ## Statement - conjecture.v - v#633443
+0 ## Statement - acknowledgment.n - n#6628861
+0 ## Statement - hazard.v - v#916909
+0 ## Statement - detail.v - v#956250
+0 ## Statement - proclamation.n - n#6726158
+0 ## Statement - speak.v - v#941990
+0 ## Statement - concession.n - n#7176243
+0 ## Statement - recount.v - v#953216
+0 ## Statement - conjecture.n - n#6782680
+0 ## Statement - acknowledge.v - v#817311
+0 ## Statement - mention.v - v#1020005
+0 ## Statement - allow.v - v#802318
+0 ## Statement - explain.v - v#939277
+0 ## Statement - declaration.n - n#6725877
+0 ## Statement - claim.n - n#6730563
+0 ## Statement - pout.v - v#34758
+0 ## Statement - affirm.v - v#1011031
+0 ## Statement - assertion.n - n#6729499
+0 ## Statement - maintain.v - v#1016778
+0 ## Statement - declare.v - v#1010118
+0 ## Statement - comment.v - v#1058574
+0 ## Religious_belief - subscribe.v - v#2299110
+0 ## Religious_belief - believe.v - v#683280
+0 ## Religious_belief - subscriber.n - n#10670668
+0 ## Expressing_publicly - give voice.v - v#980453
+0 ## Expressing_publicly - articulate.v - v#980453
+0 ## Expressing_publicly - voice.v - v#933403
+0 ## Expressing_publicly - express.v - v#943837
+0 ## Expressing_publicly - vent.v - v#944548
+0 ## Expressing_publicly - expression.n - n#4679738
+0 ## Expressing_publicly - air.v - v#488770
+0 ## Electricity - electricity.n - n#11449907
+0 ## Electricity - electric.a - a#2826877
+0 ## Electricity - hydroelectric.a - a#2827950
+0 ## Electricity - electrical.a - a#2826877
+0 ## Electricity - photoelectric.a - a#2827790
+0 ## Electricity - photoelectricity.n - n#11491194
+0 ## Electricity - electric power.n - n#11449419
+0 ## Electricity - juice.n - n#14050434
+0 ## Electricity - electrical power.n - n#11449419
+0 ## Electricity - power.n - n#5190804
+0 ## Electricity - energy.n - n#11452218
+0 ## Electricity - current.n - n#11443532
+0 ## Electricity - hydroelectricity.n - n#11467202
+0 ## Coming_to_believe - deduction.n - n#5780885
+0 ## Coming_to_believe - ascertain.v - v#920336
+0 ## Coming_to_believe - surmise.v - v#689205
+0 ## Coming_to_believe - infer.v - v#636574
+0 ## Coming_to_believe - learn.v - v#597915
+0 ## Coming_to_believe - realization.n - n#61917
+0 ## Coming_to_believe - find out.v - v#918872
+0 ## Coming_to_believe - conclusion.n - n#5838176
+0 ## Coming_to_believe - figure out.v - v#634906
+0 ## Coming_to_believe - speculate.v - v#927049
+0 ## Coming_to_believe - deduce.v - v#636574
+0 ## Coming_to_believe - realize.v - v#591115
+0 ## Coming_to_believe - puzzle out.v - v#634906
+0 ## Coming_to_believe - inference.n - n#5774614
+0 ## Coming_to_believe - conclude.v - v#634472
+0 ## Coming_to_believe - work out.v - v#634906
+0 ## Coming_to_believe - guess.n - n#6782680
+0 ## Coming_to_believe - find.v - v#2154508
+0 ## Coming_to_believe - determine.v - v#918872
+0 ## Coming_to_believe - guess.v - v#631737
+0 ## Alliance - alliance.n - n#14418822
+0 ## Alliance - coalition.n - n#8293982
+0 ## Convey_importance - emphasize.v - v#1013367
+0 ## Convey_importance - underscore.v - v#1014609
+0 ## Convey_importance - underline.v - v#1014609
+0 ## Convey_importance - stress.v - v#1013367
+0 ## Forming_relationships - woo.v - v#2534936
+0 ## Forming_relationships - marriage_(into).n - n#7989373
+0 ## Forming_relationships - divorce.v - v#2490634
+0 ## Forming_relationships - wedding.n - n#1036996
+0 ## Forming_relationships - leave.v - v#2009433
+0 ## Forming_relationships - betrothal.n - n#7228211
+0 ## Forming_relationships - betroth.v - v#886602
+0 ## Forming_relationships - marriage.n - n#13963970
+0 ## Forming_relationships - wed.v - v#2488834
+0 ## Forming_relationships - befriend.v - v#2588677
+0 ## Forming_relationships - separate.v - v#2431320
+0 ## Forming_relationships - divorce.n - n#1201271
+0 ## Forming_relationships - marry.v - v#2488834
+0 ## Forming_relationships - separation.n - n#1201021
+0 ## Forming_relationships - engagement.n - n#7228211
+0 ## Forming_relationships - marry_(into).v - v#2488834
+0 ## Artificiality - false.a - a#1573238
+0 ## Artificiality - artificial.a - a#1571363
+0 ## Artificiality - pseudo.a - a#1118232
+0 ## Artificiality - fake.a - a#1117477
+0 ## Artificiality - genuine.a - a#1115349
+0 ## Artificiality - phoney.a - a#1117477
+0 ## Artificiality - ersatz.a - a#1572974
+0 ## Artificiality - bogus.a - a#1117477
+0 ## Artificiality - phoney.n - n#10195593
+0 ## Artificiality - counterfeit.a - a#1116380
+0 ## Losing - lose.v - v#2287789
+0 ## Losing - misplace.v - v#1503101
+0 ## Commutation - commutation.n - n#315700
+0 ## Commutation - commute.v - v#553407
+0 ## System - system.n - n#4377057
+0 ## System - cascade.n - n#8460152
+0 ## System - complex.n - n#5870365
+0 ## Having_or_lacking_access - blocked.a - a#1653857
+0 ## Having_or_lacking_access - accessible.a - a#19131
+0 ## Having_or_lacking_access - access.n - n#5176188
+0 ## People_by_age - spring chicken.n - n#10804406
+0 ## People_by_age - neonate.n - n#10353016
+0 ## People_by_age - infant.n - n#9827683
+0 ## People_by_age - elderly.n - n#7943870
+0 ## People_by_age - child.n - n#9918248
+0 ## People_by_age - youth.n - n#10804406
+0 ## People_by_age - coot.n - n#2018027
+0 ## People_by_age - teenager.n - n#9772029
+0 ## People_by_age - baby.n - n#9827683
+0 ## People_by_age - newborn.n - n#10353016
+0 ## People_by_age - adult.n - n#9605289
+0 ## People_by_age - kid.n - n#9917593
+0 ## People_by_age - youngster.n - n#9917593
+0 ## People_by_age - geezer.n - n#10123711
+0 ## People_by_age - adolescent.n - n#9772029
+0 ## People_by_age - boy.n - n#10285313
+0 ## Businesses - business.n - n#8061042
+0 ## Businesses - shop.n - n#4202417
+0 ## Businesses - corporation.n - n#8059412
+0 ## Businesses - company.n - n#8058098
+0 ## Businesses - mill.n - n#3316406
+0 ## Businesses - establishment.n - n#8053576
+0 ## Businesses - practice.n - n#410247
+0 ## Businesses - operation.n - n#1095966
+0 ## Businesses - chain.n - n#8057816
+0 ## Businesses - firm.n - n#8059870
+0 ## Color_qualities - light.a - a#408660
+0 ## Color_qualities - dull.a - a#283703
+0 ## Color_qualities - vivid.a - a#1941026
+0 ## Color_qualities - warm.a - a#2529264
+0 ## Color_qualities - pale.a - a#2325984
+0 ## Isolated_places - godforsaken.a - a#1243102
+0 ## Isolated_places - backwater.n - n#8502507
+0 ## Isolated_places - backwoods.n - n#8502672
+0 ## Isolated_places - back_of_beyond.n - n#8499680
+0 ## Isolated_places - outback.n - n#8505110
+0 ## Isolated_places - out-of-the-way.a - a#490979
+0 ## Isolated_places - boondocks.n - n#8502672
+0 ## Cause_to_experience - terrorize.v - v#1780941
+0 ## Cause_to_experience - divert.v - v#2492362
+0 ## Cause_to_experience - torment.v - v#1803003
+0 ## Cause_to_experience - amuse.v - v#2492362
+0 ## Cause_to_experience - entertain.v - v#2492198
+0 ## Telling - assurance.n - n#7227406
+0 ## Telling - notify.v - v#873682
+0 ## Telling - assure.v - v#1019643
+0 ## Telling - advise.v - v#873682
+0 ## Telling - notification.n - n#7212424
+0 ## Telling - apprise.v - v#873682
+0 ## Telling - confide.v - v#936465
+0 ## Telling - tell.v - v#952524
+0 ## Telling - inform.v - v#831651
+0 ## Accoutrements - fez.n - n#3331077
+0 ## Accoutrements - pendant.n - n#3908831
+0 ## Accoutrements - medallion.n - n#6706676
+0 ## Accoutrements - regalia.n - n#4071263
+0 ## Accoutrements - wig.n - n#4584207
+0 ## Accoutrements - hauberk.n - n#3499468
+0 ## Accoutrements - ribbon.n - n#6706676
+0 ## Accoutrements - accoutrement.n - n#2671780
+0 ## Accoutrements - greaves.n - n#14677485
+0 ## Accoutrements - medal.n - n#6706676
+0 ## Accoutrements - cap.n - n#2954340
+0 ## Accoutrements - coif.n - n#3065243
+0 ## Accoutrements - sporran.n - n#4284572
+0 ## Accoutrements - choker.n - n#3024882
+0 ## Accoutrements - beret.n - n#2831237
+0 ## Accoutrements - biretta.n - n#2843909
+0 ## Accoutrements - anklet.n - n#2713097
+0 ## Accoutrements - mask.n - n#3724870
+0 ## Accoutrements - sombrero.n - n#4259630
+0 ## Accoutrements - ring.n - n#4092609
+0 ## Accoutrements - circlet.n - n#3033267
+0 ## Accoutrements - locket.n - n#3683995
+0 ## Accoutrements - bracelet.n - n#2887970
+0 ## Accoutrements - gorget.n - n#3448590
+0 ## Accoutrements - helmet.n - n#3513137
+0 ## Accoutrements - bonnet.n - n#2869837
+0 ## Accoutrements - armband.n - n#7262942
+0 ## Accoutrements - balaclava.n - n#2776825
+0 ## Accoutrements - sash.n - n#3438071
+0 ## Accoutrements - hat.n - n#3497657
+0 ## Accoutrements - boater.n - n#2859184
+0 ## Accoutrements - chain.n - n#2999410
+0 ## Accoutrements - hairgrip.n - n#2860640
+0 ## Accoutrements - headdress.n - n#3502509
+0 ## Accoutrements - armlet.n - n#2739427
+0 ## Accoutrements - snood.n - n#4250692
+0 ## Accoutrements - jewellery.n - n#3597469
+0 ## Accoutrements - headband.n - n#3502042
+0 ## Accoutrements - coronet.n - n#3111564
+0 ## Accoutrements - tiara.n - n#4432203
+0 ## Accoutrements - trinket.n - n#2787435
+0 ## Accoutrements - helm.n - n#3512911
+0 ## Accoutrements - badge.n - n#6882561
+0 ## Accoutrements - watch.n - n#4555897
+0 ## Accoutrements - mitre.n - n#3773970
+0 ## Accoutrements - hairpin.n - n#3476313
+0 ## Accoutrements - brooch.n - n#2906438
+0 ## Accoutrements - bowler.n - n#2881757
+0 ## Accoutrements - goggles.n - n#3443912
+0 ## Accoutrements - turban.n - n#4498389
+0 ## Accoutrements - hairnet.n - n#3475961
+0 ## Accoutrements - nightcap.n - n#3824284
+0 ## Accoutrements - veil.n - n#3502331
+0 ## Accoutrements - cufflink.n - n#3146075
+0 ## Accoutrements - toupee.n - n#4459018
+0 ## Accoutrements - bangle.n - n#2887970
+0 ## Accoutrements - spectacles.n - n#4272054
+0 ## Accoutrements - glasses.n - n#4272054
+0 ## Accoutrements - shako.n - n#2817516
+0 ## Accoutrements - panama.n - n#2859184
+0 ## Accoutrements - trilby.n - n#3325941
+0 ## Accoutrements - belt.n - n#2827606
+0 ## Accoutrements - hairpiece.n - n#3476083
+0 ## Accoutrements - bandanna.n - n#2786198
+0 ## Accoutrements - crown.n - n#3138669
+0 ## Accoutrements - headpiece.n - n#3504205
+0 ## Accoutrements - necklace.n - n#3814906
+0 ## Accoutrements - mantle.n - n#6883956
+0 ## Accoutrements - skullcap.n - n#4232153
+0 ## Accoutrements - diadem.n - n#3138669
+0 ## Accoutrements - earring.n - n#3262349
+0 ## Cause_to_move_in_place - spin.v - v#2048051
+0 ## Cause_to_move_in_place - seesaw.v - v#1992375
+0 ## Cause_to_move_in_place - swing.v - v#1877355
+0 ## Cause_to_move_in_place - rotate.v - v#2045043
+0 ## Cause_to_move_in_place - turn.v - v#1907258
+0 ## Cause_to_move_in_place - squeeze.v - v#1593937
+0 ## Cause_to_move_in_place - swirl.v - v#2048891
+0 ## Cause_to_move_in_place - shake.v - v#1889610
+0 ## Cause_to_move_in_place - vibrate.v - v#1891249
+0 ## Cause_to_move_in_place - twirl.v - v#2048891
+0 ## Appellations - captain.n - n#9893191
+0 ## Appellations - officer.n - n#10448983
+0 ## Appellations - general.n - n#10123844
+0 ## Sound_level - quiet.a - a#1922763
+0 ## Sound_level - loud.a - a#1452593
+0 ## Protecting - insulate.v - v#495038
+0 ## Protecting - bulwark.n - n#4051825
+0 ## Protecting - shield.n - n#4192858
+0 ## Protecting - safeguard.n - n#822970
+0 ## Protecting - shield.v - v#1130169
+0 ## Protecting - protection_((event)).n - n#4014297
+0 ## Protecting - protect.v - v#1128193
+0 ## Protecting - guard.v - v#1129337
+0 ## Protecting - protection_((entity)).n - n#4014297
+0 ## Protecting - secure.v - v#2238770
+0 ## Protecting - safeguard.v - v#1138102
+0 ## Deserving - grounds.n - n#5823932
+0 ## Deserving - merit.v - v#2646378
+0 ## Deserving - warrant.v - v#896803
+0 ## Deserving - deserve.v - v#2646378
+0 ## Deserving - worth.a - a#2586206
+0 ## Deserving - warrant.n - n#6547059
+0 ## Deserving - call.v - v#1028748
+0 ## Deserving - justify.v - v#896803
+0 ## Abundance - galore.a - a#14358
+0 ## Abundance - teem.v - v#2714974
+0 ## Abundance - abundant.a - a#13887
+0 ## Abundance - abound.v - v#2715279
+0 ## Chemical-sense_description - spicy.a - a#2398378
+0 ## Chemical-sense_description - aroma.n - n#4980008
+0 ## Chemical-sense_description - odor.n - n#5713737
+0 ## Chemical-sense_description - sour.a - a#2368787
+0 ## Chemical-sense_description - bland.a - a#2399595
+0 ## Chemical-sense_description - palatable.a - a#1716227
+0 ## Chemical-sense_description - flavourful.a - a#2396911
+0 ## Chemical-sense_description - malodorous.a - a#1053144
+0 ## Chemical-sense_description - aromatic.a - a#1052428
+0 ## Chemical-sense_description - flavoursome.a - a#2396911
+0 ## Chemical-sense_description - sapid.a - a#2396911
+0 ## Chemical-sense_description - sweet.a - a#2368336
+0 ## Chemical-sense_description - delicious.a - a#2396720
+0 ## Chemical-sense_description - stench.n - n#5714894
+0 ## Chemical-sense_description - tart.a - a#2369460
+0 ## Chemical-sense_description - flavourless.a - a#2399595
+0 ## Chemical-sense_description - tasty.a - a#2395115
+0 ## Chemical-sense_description - insipid.a - a#2399595
+0 ## Chemical-sense_description - smell.v - v#2124748
+0 ## Chemical-sense_description - reek.v - v#2124106
+0 ## Chemical-sense_description - bitter.a - a#2396098
+0 ## Chemical-sense_description - stink.v - v#2124106
+0 ## Chemical-sense_description - delectable.a - a#2396720
+0 ## Chemical-sense_description - fragrance.n - n#4980463
+0 ## Chemical-sense_description - salty.a - a#1073822
+0 ## Chemical-sense_description - scent.n - n#4980008
+0 ## Chemical-sense_description - piquant.a - a#2398378
+0 ## Chemical-sense_description - tasteless.a - a#2399399
+0 ## Chemical-sense_description - bouquet.n - n#4980463
+0 ## Chemical-sense_description - toothsome.a - a#2396720
+0 ## Chemical-sense_description - smelly.a - a#1053634
+0 ## Chemical-sense_description - stink.n - n#5714894
+0 ## Chemical-sense_description - fragrant.a - a#1052248
+0 ## Chemical-sense_description - scrumptious.a - a#2396720
+0 ## Chemical-sense_description - pungent.a - a#2398608
+0 ## Chemical-sense_description - reek.n - n#5714894
+0 ## Chemical-sense_description - unpalatable.a - a#1716491
+0 ## Chemical-sense_description - hot.a - a#2397732
+0 ## Chemical-sense_description - ambrosial.a - a#2395910
+0 ## Chemical-sense_description - yummy.a - a#2396720
+0 ## Getting - procure.v - v#2238770
+0 ## Getting - procurement_((act)).n - n#83729
+0 ## Getting - acquire.v - v#2210855
+0 ## Getting - obtain.v - v#2238085
+0 ## Getting - score.v - v#1111816
+0 ## Getting - acquisition_((entity)).n - n#77419
+0 ## Getting - get.v - v#2210855
+0 ## Getting - acquisition_((act)).n - n#77419
+0 ## Getting - gain.v - v#2288295
+0 ## Getting - secure.v - v#2238770
+0 ## Getting - win.v - v#2288295
+0 ## Origin - national.a - a#2988060
+0 ## Origin - chinese.a - a#2964782
+0 ## Origin - greek.a - a#3016202
+0 ## Origin - turkish.a - a#3023852
+0 ## Origin - japanese.a - a#2965043
+0 ## Origin - jamaican.a - a#3076432
+0 ## Origin - iranian.a - a#3075191
+0 ## Origin - finnish.a - a#2959553
+0 ## Origin - portuguese.a - a#2959007
+0 ## Origin - national.n - n#9625401
+0 ## Origin - syrian.a - a#3016519
+0 ## Origin - egyptian.a - a#2971469
+0 ## Origin - russian.a - a#2957276
+0 ## Origin - canadian.a - a#2982473
+0 ## Origin - saudi.a - a#3114139
+0 ## Origin - cuban.a - a#2969591
+0 ## Origin - french.a - a#2958392
+0 ## Origin - dutch.a - a#2960686
+0 ## Origin - jordanian.a - a#3077235
+0 ## Origin - irish.a - a#3003744
+0 ## Origin - originate.v - v#2624263
+0 ## Origin - indian.a - a#2928347
+0 ## Origin - origin.n - n#8507558
+0 ## Origin - vietnamese.a - a#3129222
+0 ## Origin - swiss.a - a#2960975
+0 ## Origin - colombian.a - a#2967618
+0 ## Origin - ottoman.a - a#2970241
+0 ## Origin - italian.a - a#2957066
+0 ## Origin - roman.a - a#2921569
+0 ## Origin - iraqi.a - a#3075470
+0 ## Origin - american.a - a#2927512
+0 ## Origin - european.a - a#2968325
+0 ## Part_piece - clod.n - n#7961016
+0 ## Part_piece - scrap.n - n#9222051
+0 ## Part_piece - shred.n - n#13773725
+0 ## Part_piece - fragment.n - n#9285254
+0 ## Part_piece - piece.n - n#9385911
+0 ## Part_piece - chunk.n - n#7961016
+0 ## Part_piece - clump.n - n#7961016
+0 ## Part_piece - flake.n - n#9222051
+0 ## Part_piece - chip.n - n#9222051
+0 ## Part_piece - lump.n - n#7961016
+0 ## Part_piece - snippet.n - n#4250026
+0 ## Part_piece - slice.n - n#7654667
+0 ## Part_piece - shard.n - n#4184701
+0 ## Part_piece - sliver.n - n#9442838
+0 ## Part_piece - smidgen.n - n#13773725
+0 ## Part_piece - morsel.n - n#7579076
+0 ## Part_piece - hunk.n - n#9307300
+0 ## Be_in_agreement_on_assessment - agreement.n - n#7175241
+0 ## Be_in_agreement_on_assessment - see eye to eye.v - v#805910
+0 ## Be_in_agreement_on_assessment - agree.v - v#805376
+0 ## Be_in_agreement_on_assessment - concur.v - v#805376
+0 ## Cause_to_amalgamate - join.v - v#2434976
+0 ## Cause_to_amalgamate - consolidate.v - v#242747
+0 ## Cause_to_amalgamate - commingle.v - v#394813
+0 ## Cause_to_amalgamate - amalgamate.v - v#1462005
+0 ## Cause_to_amalgamate - combine.v - v#394813
+0 ## Cause_to_amalgamate - mix.v - v#394813
+0 ## Cause_to_amalgamate - unify.v - v#1462005
+0 ## Cause_to_amalgamate - unite.v - v#243124
+0 ## Cause_to_amalgamate - conflate.v - v#394813
+0 ## Cause_to_amalgamate - fuse.v - v#394813
+0 ## Cause_to_amalgamate - blend.v - v#394813
+0 ## Cause_to_amalgamate - throw_together.v - v#1472807
+0 ## Cause_to_amalgamate - lump.v - v#1385920
+0 ## Cause_to_amalgamate - compound.v - v#1461328
+0 ## Cause_to_amalgamate - meld.v - v#394813
+0 ## Cause_to_amalgamate - jumble.v - v#2739861
+0 ## Cause_to_amalgamate - flux.v - v#394813
+0 ## Cause_to_amalgamate - pair.v - v#2490430
+0 ## Cause_to_amalgamate - coalesce.v - v#394813
+0 ## Cause_to_amalgamate - merge.v - v#394813
+0 ## Cause_to_amalgamate - intermix.v - v#1462468
+0 ## Cause_to_amalgamate - admix.v - v#396703
+0 ## Mental_stimulus_exp_focus - absorbed.a - a#163948
+0 ## Mental_stimulus_exp_focus - interested.a - a#1342237
+0 ## Mental_stimulus_exp_focus - lost_(in).a - a#2419159
+0 ## Mental_stimulus_exp_focus - curious.a - a#1342572
+0 ## Mental_stimulus_exp_focus - engrossed.a - a#163948
+0 ## Mental_stimulus_exp_focus - captivated.a - a#865620
+0 ## Mental_stimulus_exp_focus - smitten.a - a#1465668
+0 ## Mental_stimulus_exp_focus - infatuated.a - a#1465668
+0 ## Mental_stimulus_exp_focus - wrapped up_(in).a - a#518405
+0 ## Mental_stimulus_exp_focus - fascinated.a - a#865848
+0 ## Mental_stimulus_exp_focus - enthralled.a - a#865620
+0 ## Mental_stimulus_exp_focus - suspicious.a - a#2464277
+0 ## Identicality - identical.a - a#2064127
+0 ## Identicality - same.a - a#2068476
+0 ## Identicality - different.a - a#2064745
+0 ## Identicality - identity.n - n#5763412
+0 ## Identicality - distinct.a - a#2067063
+0 ## Emotion_active - agonize.v - v#1794523
+0 ## Emotion_active - fret.v - v#1793933
+0 ## Emotion_active - worry.v - v#1767163
+0 ## Emotion_active - obsession.n - n#9183255
+0 ## Emotion_active - obsess.v - v#1831143
+0 ## Emotion_active - fuss.v - v#1793933
+0 ## Tasting - taste.v - v#1195299
+0 ## Tasting - try.v - v#2530167
+0 ## Lively_place - hum.v - v#2706605
+0 ## Lively_place - buzz.v - v#2706605
+0 ## Lively_place - busy.a - a#35978
+0 ## Lively_place - lively.a - a#804695
+0 ## Lively_place - hectic.a - a#86210
+0 ## Lively_place - bustle.v - v#2058191
+0 ## Lively_place - abuzz.a - a#1920697
+0 ## Lively_place - frenetic.a - a#86341
+0 ## Medical_specialties - obstetrics.n - n#6053439
+0 ## Medical_specialties - homeopathy.n - n#710889
+0 ## Medical_specialties - psychoanalysis.n - n#704305
+0 ## Medical_specialties - gynaecology.n - n#6050901
+0 ## Medical_specialties - neonatology.n - n#6061917
+0 ## Medical_specialties - gastroenterology.n - n#6050490
+0 ## Medical_specialties - medicine.n - n#6043075
+0 ## Medical_specialties - paediatrics.n - n#6061631
+0 ## Medical_specialties - immunology.n - n#6051542
+0 ## Medical_specialties - psychotherapy.n - n#700652
+0 ## Medical_specialties - neurology.n - n#6052864
+0 ## Medical_specialties - midwifery.n - n#6053439
+0 ## Medical_specialties - endocrinology.n - n#6049850
+0 ## Medical_specialties - epidemiology.n - n#6050024
+0 ## Medical_specialties - podiatry.n - n#6062076
+0 ## Medical_specialties - therapy.n - n#661091
+0 ## Medical_specialties - rheumatology.n - n#6062655
+0 ## Medical_specialties - radiology.n - n#6062407
+0 ## Medical_specialties - allopathy.n - n#710692
+0 ## Medical_specialties - chiropractic.n - n#707967
+0 ## Medical_specialties - nephrology.n - n#6052521
+0 ## Medical_specialties - haematology.n - n#6051134
+0 ## Medical_specialties - cardiology.n - n#6047275
+0 ## Medical_specialties - orthopaedics.n - n#6064106
+0 ## Medical_specialties - oncology.n - n#6054266
+0 ## Medical_specialties - histology.n - n#6077413
+0 ## Medical_specialties - dermatology.n - n#6049500
+0 ## Medical_specialties - dentistry.n - n#6047430
+0 ## Expectation - unexpected.a - a#930290
+0 ## Expectation - prediction.n - n#5775081
+0 ## Expectation - unforeseeable.a - a#1842643
+0 ## Expectation - expect.v - v#719734
+0 ## Expectation - foresee.v - v#720808
+0 ## Expectation - premonition.n - n#7522128
+0 ## Expectation - predict.v - v#917772
+0 ## Expectation - anticipate.v - v#719734
+0 ## Expectation - predictable.a - a#1841544
+0 ## Expectation - unpredictable.a - a#1842001
+0 ## Expectation - foreseeable.a - a#1841699
+0 ## Expectation - expectation.n - n#5944958
+0 ## Expectation - await.v - v#720063
+0 ## Process_stop - stop.v - v#2680814
+0 ## Process_stop - discontinue.v - v#2680814
+0 ## Process_stop - quit.v - v#2680814
+0 ## Process_stop - halt.n - n#7365849
+0 ## Process_stop - cessation.n - n#7362075
+0 ## Process_stop - cease.v - v#2680814
+0 ## Process_stop - desist.v - v#1196037
+0 ## Process_stop - discontinuation.n - n#1022483
+0 ## Waiting - wait.v - v#2637938
+0 ## Choosing - elect.v - v#2400760
+0 ## Choosing - select.v - v#674607
+0 ## Choosing - opt.v - v#679389
+0 ## Choosing - selection.n - n#161243
+0 ## Choosing - choice.n - n#5790242
+0 ## Choosing - pick.n - n#161243
+0 ## Choosing - choose.v - v#674607
+0 ## Choosing - decide.v - v#697589
+0 ## Choosing - settle on.v - v#486703
+0 ## Choosing - pick.v - v#676450
+0 ## Linguistic_meaning - meaning.n - n#6601327
+0 ## Linguistic_meaning - designate.v - v#1030132
+0 ## Linguistic_meaning - polysemous.a - a#103447
+0 ## Linguistic_meaning - vague.a - a#697389
+0 ## Linguistic_meaning - extension.n - n#5922949
+0 ## Linguistic_meaning - denotation.n - n#5922949
+0 ## Linguistic_meaning - referential.a - a#723015
+0 ## Linguistic_meaning - intension.n - n#6602935
+0 ## Linguistic_meaning - ambiguous.a - a#102201
+0 ## Linguistic_meaning - monosemous.a - a#103953
+0 ## Linguistic_meaning - mean.v - v#955148
+0 ## Linguistic_meaning - reading.n - n#5928513
+0 ## Linguistic_meaning - sense.n - n#6602472
+0 ## Linguistic_meaning - denote.v - v#931467
+0 ## Entering_of_plea - plead.v - v#760576
+0 ## Entering_of_plea - plea.n - n#6561138
+0 ## Prevarication - deceive.v - v#854420
+0 ## Prevarication - joke.v - v#853633
+0 ## Prevarication - fool.v - v#854904
+0 ## Prevarication - dissemble.v - v#838043
+0 ## Prevarication - hoodwink.v - v#839194
+0 ## Prevarication - shit.v - v#841986
+0 ## Prevarication - fib.n - n#6757057
+0 ## Prevarication - mislead.v - v#834009
+0 ## Prevarication - lie.n - n#6756831
+0 ## Prevarication - equivocation.n - n#6761099
+0 ## Prevarication - misrepresentation.n - n#751145
+0 ## Prevarication - prevaricate.v - v#835506
+0 ## Prevarication - lie.v - v#834259
+0 ## Prevarication - deception.n - n#6758225
+0 ## Prevarication - kid.v - v#851100
+0 ## Prevarication - equivocate.v - v#835506
+0 ## Prevarication - deceptive.a - a#1224253
+0 ## Prevarication - bullshit.v - v#839526
+0 ## Prevarication - dissembler.n - n#10195593
+0 ## Prevarication - prevarication.n - n#6756831
+0 ## Prevarication - misrepresent.v - v#836705
+0 ## Prevarication - fib.v - v#835294
+0 ## Prevarication - tell.v - v#1009240
+0 ## Existence - remain.v - v#117985
+0 ## Existence - existence.n - n#13954253
+0 ## Existence - real.a - a#1932973
+0 ## Existence - exist.v - v#2603699
+0 ## Jury_deliberation - deliberation.n - n#7142365
+0 ## Jury_deliberation - deliberate.v - v#813044
+0 ## Moving_in_place - swing.v - v#1877355
+0 ## Moving_in_place - shake.v - v#1889610
+0 ## Moving_in_place - wave.v - v#1901783
+0 ## Moving_in_place - turn.v - v#1907258
+0 ## Moving_in_place - rock.v - v#1875295
+0 ## Moving_in_place - twirl.v - v#2048891
+0 ## Moving_in_place - roll.v - v#1866192
+0 ## Moving_in_place - temblor.n - n#7428954
+0 ## Moving_in_place - earthquake.n - n#7428954
+0 ## Moving_in_place - vibrate.v - v#1891249
+0 ## Moving_in_place - swing.n - n#327824
+0 ## Moving_in_place - quiver.n - n#345926
+0 ## Moving_in_place - judder.v - v#1891638
+0 ## Moving_in_place - flop.v - v#1972849
+0 ## Moving_in_place - rotate.v - v#2045043
+0 ## Moving_in_place - quiver.v - v#1889129
+0 ## Moving_in_place - quake.n - n#7428954
+0 ## Moving_in_place - spin.v - v#2048051
+0 ## Remembering_information - forget.v - v#610167
+0 ## Remembering_information - remember.v - v#607780
+0 ## Bond_maturation - endow.v - v#2474239
+0 ## Bond_maturation - maturity.n - n#14424780
+0 ## Bond_maturation - mature.v - v#250181
+0 ## Speak_on_topic - address.v - v#1033527
+0 ## Speak_on_topic - address.n - n#7238694
+0 ## Speak_on_topic - ramble.v - v#2684453
+0 ## Speak_on_topic - lecture.n - n#7240549
+0 ## Speak_on_topic - expound.v - v#955601
+0 ## Speak_on_topic - deal.v - v#1033527
+0 ## Speak_on_topic - lecture.v - v#830761
+0 ## Speak_on_topic - discuss.v - v#1034312
+0 ## Speak_on_topic - go on.v - v#781000
+0 ## Speak_on_topic - tell.v - v#1009240
+0 ## Speak_on_topic - sermonize.v - v#828374
+0 ## Speak_on_topic - preach.v - v#828003
+0 ## Speak_on_topic - hold forth.v - v#814621
+0 ## Speak_on_topic - pontificate.v - v#2432395
+0 ## Speak_on_topic - expatiate.v - v#955601
+0 ## Cause_to_end - end.v - v#352826
+0 ## Cause_to_end - lift.v - v#354195
+0 ## Cause_to_end - arrest.v - v#1131473
+0 ## Reliance - dependence.n - n#14001348
+0 ## Reliance - depend.v - v#712708
+0 ## Reliance - count.v - v#712708
+0 ## Reliance - rely.v - v#688377
+0 ## Reliance - reliance.n - n#14001728
+0 ## Reliance - dependency.n - n#14001348
+0 ## Fairness_evaluation - unfairly.adv - r#285266
+0 ## Fairness_evaluation - inequitable.a - a#958712
+0 ## Fairness_evaluation - unfair.a - a#957176
+0 ## Fairness_evaluation - unjust.a - a#957176
+0 ## Fairness_evaluation - unjustly.adv - r#205561
+0 ## Fairness_evaluation - fairly.adv - r#106759
+0 ## Fairness_evaluation - fair.a - a#956131
+0 ## Filling - flood.v - v#1524523
+0 ## Filling - plaster.v - v#1360899
+0 ## Filling - douse.v - v#1577093
+0 ## Filling - spatter.v - v#1374020
+0 ## Filling - smear.v - v#1233387
+0 ## Filling - yoke.v - v#1492283
+0 ## Filling - fill.v - v#452512
+0 ## Filling - wash.v - v#1269844
+0 ## Filling - stuff.v - v#1524871
+0 ## Filling - load.v - v#1489989
+0 ## Filling - anoint.v - v#675412
+0 ## Filling - heap.v - v#1503404
+0 ## Filling - cover.v - v#1332730
+0 ## Filling - shower.v - v#1372994
+0 ## Filling - spread.v - v#2082690
+0 ## Filling - coat.v - v#1264283
+0 ## Filling - dust.v - v#1376245
+0 ## Filling - pile.v - v#2064131
+0 ## Filling - varnish.v - v#1269008
+0 ## Filling - pack.v - v#2064131
+0 ## Filling - sprinkle.v - v#1376245
+0 ## Filling - surface.v - v#1264283
+0 ## Filling - dab.v - v#1233194
+0 ## Filling - embellish.v - v#1675963
+0 ## Filling - gild.v - v#1683101
+0 ## Filling - crowd.v - v#2027612
+0 ## Filling - drizzle.v - v#1376082
+0 ## Filling - asphalt.v - v#1267866
+0 ## Filling - tile.v - v#1338663
+0 ## Filling - cram.v - v#1524298
+0 ## Filling - daub.v - v#1233387
+0 ## Filling - plant.v - v#1567275
+0 ## Filling - butter.v - v#1267998
+0 ## Filling - splatter.v - v#1374020
+0 ## Filling - plank.v - v#1336159
+0 ## Filling - scatter.v - v#1376245
+0 ## Filling - drape.v - v#1612487
+0 ## Filling - paint.v - v#1362736
+0 ## Filling - pave.v - v#1267098
+0 ## Filling - sow.v - v#1500873
+0 ## Filling - pump.v - v#1225684
+0 ## Filling - hang.v - v#1677716
+0 ## Filling - squirt.v - v#1313411
+0 ## Filling - wallpaper.v - v#1268112
+0 ## Filling - panel.v - v#1678519
+0 ## Filling - wax.v - v#1268726
+0 ## Filling - seed.v - v#1500873
+0 ## Filling - strew.v - v#1378123
+0 ## Filling - glaze.v - v#1269521
+0 ## Filling - splash.v - v#1374020
+0 ## Filling - inject.v - v#187268
+0 ## Filling - suffuse.v - v#454251
+0 ## Filling - wrap.v - v#1283208
+0 ## Filling - adorn.v - v#1675963
+0 ## Filling - jam.v - v#2064131
+0 ## Filling - dress.v - v#1679433
+0 ## Filling - spray.v - v#1372682
+0 ## Filling - brush.v - v#1373718
+0 ## Part_orientational - base.n - n#2798574
+0 ## Part_orientational - bottom.a - a#2440691
+0 ## Part_orientational - eastern.a - a#823971
+0 ## Part_orientational - peak.n - n#8617963
+0 ## Part_orientational - bottom.n - n#8511241
+0 ## Part_orientational - north.a - a#1600333
+0 ## Part_orientational - rear.a - a#197891
+0 ## Part_orientational - back.n - n#4059701
+0 ## Part_orientational - underside.n - n#8511241
+0 ## Part_orientational - heart.n - n#13865904
+0 ## Part_orientational - right.n - n#8625073
+0 ## Part_orientational - northernmost.a - a#1601462
+0 ## Part_orientational - westernmost.a - a#824876
+0 ## Part_orientational - tip.n - n#8617963
+0 ## Part_orientational - left.a - a#2032953
+0 ## Part_orientational - rear.n - n#8629508
+0 ## Part_orientational - western.a - a#824631
+0 ## Part_orientational - summit.n - n#8617963
+0 ## Part_orientational - top.n - n#8617963
+0 ## Part_orientational - crest.n - n#8617963
+0 ## Part_orientational - southern.a - a#1603179
+0 ## Part_orientational - right.a - a#2031986
+0 ## Part_orientational - northern.a - a#1601297
+0 ## Part_orientational - back.a - a#197576
+0 ## Part_orientational - west.a - a#824321
+0 ## Part_orientational - apex.n - n#8677801
+0 ## Part_orientational - side.n - n#8510666
+0 ## Part_orientational - east.n - n#8561351
+0 ## Part_orientational - southernmost.a - a#1603354
+0 ## Part_orientational - east.a - a#823350
+0 ## Part_orientational - south.n - n#8561583
+0 ## Part_orientational - top.a - a#2439949
+0 ## Part_orientational - foot.n - n#5563266
+0 ## Part_orientational - face.n - n#8510666
+0 ## Part_orientational - northwest.n - n#8561946
+0 ## Part_orientational - left.n - n#8625462
+0 ## Part_orientational - front.n - n#8573472
+0 ## Part_orientational - easternmost.a - a#824094
+0 ## Part_orientational - hind.a - a#131692
+0 ## Part_orientational - west.n - n#8682575
+0 ## Part_orientational - underbelly.n - n#8511473
+0 ## Part_orientational - north.n - n#8561081
+0 ## Provide_lodging - house.v - v#2459173
+0 ## Provide_lodging - put up.v - v#2459173
+0 ## Provide_lodging - host.v - v#1194418
+0 ## Provide_lodging - lodge.v - v#2651424
+0 ## Being_dry - desiccated.a - a#1072382
+0 ## Being_dry - parched.a - a#2551946
+0 ## Being_dry - dehydrated.a - a#1072382
+0 ## Being_dry - dry.a - a#2551380
+0 ## Being_dry - waterless.a - a#2552415
+0 ## Request - request.v - v#752764
+0 ## Request - suggestion.n - n#5916155
+0 ## Request - appeal.n - n#7186828
+0 ## Request - command.n - n#7168131
+0 ## Request - beseech.v - v#759657
+0 ## Request - ask.v - v#752493
+0 ## Request - order.n - n#7279687
+0 ## Request - plead.v - v#759501
+0 ## Request - invite.v - v#2384686
+0 ## Request - order.v - v#746718
+0 ## Request - command.v - v#751567
+0 ## Request - request.n - n#7185325
+0 ## Request - plea.n - n#7187638
+0 ## Request - beg.v - v#759269
+0 ## Request - entreaty.n - n#7186828
+0 ## Request - petition.n - n#6513366
+0 ## Request - summon.v - v#791134
+0 ## Request - demand.n - n#7191279
+0 ## Request - entreat.v - v#759657
+0 ## Request - call.v - v#792471
+0 ## Request - tell.v - v#746718
+0 ## Request - implore.v - v#759269
+0 ## Request - call.n - n#7192129
+0 ## Request - demand.v - v#754942
+0 ## Request - urge.v - v#858781
+0 ## Familiarity - ken.n - n#5623818
+0 ## Familiarity - unfamiliar.a - a#966477
+0 ## Familiarity - intimate.a - a#453053
+0 ## Familiarity - new.a - a#1640850
+0 ## Familiarity - know.v - v#594621
+0 ## Familiarity - familiar.a - a#965606
+0 ## Familiarity - acquainted.a - a#965894
+0 ## Proper_reference - proper.a - a#1878466
+0 ## Proper_reference - self.n - n#9604981
+0 ## Infrastructure - base.n - n#13597794
+0 ## Infrastructure - infrastructure.n - n#3569964
+0 ## Exchange - swap.n - n#1109687
+0 ## Exchange - exchange.n - n#1093085
+0 ## Exchange - exchange.v - v#2257370
+0 ## Exchange - switch.v - v#2259005
+0 ## Exchange - trade.v - v#2259005
+0 ## Exchange - swap.v - v#2259005
+0 ## Exchange - trade.n - n#1109687
+0 ## Exchange - change.v - v#2257370
+0 ## Judgment_communication - scathing.a - a#648614
+0 ## Judgment_communication - commend.v - v#882395
+0 ## Judgment_communication - castigate.v - v#824292
+0 ## Judgment_communication - condemn.v - v#864159
+0 ## Judgment_communication - laud.v - v#860620
+0 ## Judgment_communication - tout.v - v#971460
+0 ## Judgment_communication - censure.n - n#6709998
+0 ## Judgment_communication - ridicule.v - v#851933
+0 ## Judgment_communication - mocking.a - a#1995596
+0 ## Judgment_communication - accuse.v - v#843468
+0 ## Judgment_communication - acclaim.v - v#861725
+0 ## Judgment_communication - deprecation.n - n#1220152
+0 ## Judgment_communication - condemnation.n - n#7233634
+0 ## Judgment_communication - disparagement.n - n#1219893
+0 ## Judgment_communication - commendation.n - n#6686736
+0 ## Judgment_communication - denigrate.v - v#864475
+0 ## Judgment_communication - blast.v - v#823827
+0 ## Judgment_communication - rave.v - v#882220
+0 ## Judgment_communication - censure.v - v#823669
+0 ## Judgment_communication - accusation.n - n#7234230
+0 ## Judgment_communication - cite.v - v#1024190
+0 ## Judgment_communication - decry.v - v#864159
+0 ## Judgment_communication - dump.v - v#2225204
+0 ## Judgment_communication - commendable.a - a#2585545
+0 ## Judgment_communication - acclaim.n - n#6691684
+0 ## Judgment_communication - blame.v - v#842538
+0 ## Judgment_communication - critique.v - v#855512
+0 ## Judgment_communication - harangue.n - n#7242912
+0 ## Judgment_communication - kudos.n - n#6693198
+0 ## Judgment_communication - denunciative.a - a#924635
+0 ## Judgment_communication - disparaging.a - a#907032
+0 ## Judgment_communication - deprecative.a - a#906655
+0 ## Judgment_communication - excoriation.n - n#7233214
+0 ## Judgment_communication - damn.v - v#865958
+0 ## Judgment_communication - critique.n - n#6410391
+0 ## Judgment_communication - critic.n - n#9979589
+0 ## Judgment_communication - ridicule.n - n#1224517
+0 ## Judgment_communication - denouncement.n - n#7232988
+0 ## Judgment_communication - excoriate.v - v#864159
+0 ## Judgment_communication - praise.n - n#6693198
+0 ## Judgment_communication - execration.n - n#7233634
+0 ## Judgment_communication - denigrative.a - a#1161233
+0 ## Judgment_communication - pin.v - v#1368264
+0 ## Judgment_communication - denunciatory.a - a#924635
+0 ## Judgment_communication - remonstrate.v - v#824767
+0 ## Judgment_communication - extol.v - v#860620
+0 ## Judgment_communication - deprecate.v - v#855933
+0 ## Judgment_communication - execrate.v - v#1774426
+0 ## Judgment_communication - denunciation.n - n#7232988
+0 ## Judgment_communication - deprecatory.a - a#906655
+0 ## Judgment_communication - hail.v - v#861725
+0 ## Judgment_communication - critical.a - a#2830645
+0 ## Judgment_communication - laudable.a - a#2585545
+0 ## Judgment_communication - disparage.v - v#845909
+0 ## Judgment_communication - belittling.n - n#6718434
+0 ## Judgment_communication - criticism.n - n#6710546
+0 ## Judgment_communication - belittle.v - v#845909
+0 ## Judgment_communication - mock.v - v#849080
+0 ## Judgment_communication - recriminate.v - v#844553
+0 ## Judgment_communication - recrimination.n - n#7234657
+0 ## Judgment_communication - rip.v - v#2098041
+0 ## Judgment_communication - scoff.v - v#850192
+0 ## Judgment_communication - denigration.n - n#1220152
+0 ## Judgment_communication - praise.v - v#856824
+0 ## Judgment_communication - deride.v - v#852922
+0 ## Judgment_communication - slam.v - v#1242832
+0 ## Judgment_communication - gibe.v - v#850192
+0 ## Judgment_communication - malediction.n - n#7233996
+0 ## Judgment_communication - criticize.v - v#826509
+0 ## Judgment_communication - harangue.v - v#990249
+0 ## Judgment_communication - charge.v - v#843468
+0 ## Judgment_communication - derision.n - n#1224517
+0 ## Judgment_communication - reprehend.v - v#826201
+0 ## Judgment_communication - charge.n - n#6561942
+0 ## Judgment_communication - denounce.v - v#841580
+0 ## Judgment_communication - reprehension.n - n#6711855
+0 ## Judgment_communication - remonstrance.n - n#7246742
+0 ## Judgment_communication - laudatory.a - a#906312
+0 ## Render_nonfunctional - hose.v - v#228521
+0 ## Render_nonfunctional - break.v - v#933821
+0 ## Render_nonfunctional - incapacitate.v - v#512186
+0 ## Render_nonfunctional - disable.v - v#512186
+0 ## Render_nonfunctional - knock out.v - v#180602
+0 ## Render_nonfunctional - total.v - v#2645007
+0 ## Race_descriptor - white.a - a#393105
+0 ## Race_descriptor - hispanic.a - a#3072158
+0 ## Race_descriptor - black.a - a#392812
+0 ## Race_descriptor - color.n - n#4956594
+0 ## Race_descriptor - asian.a - a#2968525
+0 ## Race_descriptor - yellow.a - a#385756
+0 ## Cause_proliferation_in_number - proliferation.n - n#13542114
+0 ## Cause_proliferation_in_number - multiplication.n - n#849982
+0 ## Have_associated - have got.v - v#2203362
+0 ## Have_associated - have.v - v#2203362
+0 ## Assessing - evaluate.v - v#670261
+0 ## Assessing - value.v - v#681429
+0 ## Assessing - reappraise.v - v#682592
+0 ## Assessing - rank.v - v#658052
+0 ## Assessing - weigh.v - v#2704617
+0 ## Assessing - grade.v - v#657728
+0 ## Assessing - judge.v - v#670261
+0 ## Assessing - appraise.v - v#681429
+0 ## Assessing - appraisal.n - n#5733583
+0 ## Assessing - assessment.n - n#5733583
+0 ## Assessing - assess.v - v#681429
+0 ## Assessing - evaluation.n - n#5736149
+0 ## Assessing - reappraisal.n - n#5747582
+0 ## Assessing - rate.v - v#658052
+0 ## Terms_of_agreement - parameter.n - n#7328305
+0 ## Terms_of_agreement - condition.n - n#13920835
+0 ## Terms_of_agreement - provision.n - n#6755947
+0 ## Terms_of_agreement - term.n - n#6770875
+0 ## Terms_of_agreement - clause.n - n#6392935
+0 ## Terms_of_agreement - stipulation.n - n#6755568
+0 ## Attempt_suasion - urge.v - v#765649
+0 ## Attempt_suasion - encourage.v - v#1818235
+0 ## Attempt_suasion - beg.v - v#782057
+0 ## Attempt_suasion - exhort.v - v#765649
+0 ## Attempt_suasion - entice.v - v#782527
+0 ## Attempt_suasion - advise.v - v#872886
+0 ## Attempt_suasion - admonish.v - v#870577
+0 ## Attempt_suasion - badger.v - v#1803380
+0 ## Attempt_suasion - wheedle.v - v#768778
+0 ## Attempt_suasion - hustle.v - v#767019
+0 ## Attempt_suasion - pressure.v - v#2504562
+0 ## Attempt_suasion - advocate.v - v#875141
+0 ## Attempt_suasion - cajole.v - v#768778
+0 ## Attempt_suasion - pressure.n - n#11495041
+0 ## Attempt_suasion - tempt.v - v#782527
+0 ## Attempt_suasion - press.v - v#765649
+0 ## Attempt_suasion - lobby.v - v#2458943
+0 ## Attempt_suasion - prevail.v - v#777793
+0 ## Attempt_suasion - coax.v - v#768778
+0 ## Attempt_suasion - spur.v - v#1818835
+0 ## Attempt_suasion - press.v - v#765649
+0 ## Attempt_suasion - discourage.v - v#870577
+0 ## Emotion_directed - disorientation.n - n#5898430
+0 ## Emotion_directed - grief.n - n#7535010
+0 ## Emotion_directed - sorrow.n - n#7534430
+0 ## Emotion_directed - sadness.n - n#13989051
+0 ## Emotion_directed - discomfited.a - a#2333976
+0 ## Emotion_directed - annoyance.n - n#7518261
+0 ## Emotion_directed - elated.a - a#704609
+0 ## Emotion_directed - rattled.a - a#532560
+0 ## Emotion_directed - mortified.a - a#154270
+0 ## Emotion_directed - anguish.n - n#7496755
+0 ## Emotion_directed - peeved.a - a#1806106
+0 ## Emotion_directed - cross.a - a#1445917
+0 ## Emotion_directed - furious.a - a#114454
+0 ## Emotion_directed - mad.a - a#115193
+0 ## Emotion_directed - excitement.n - n#7528212
+0 ## Emotion_directed - indignant.a - a#115494
+0 ## Emotion_directed - mourning.n - n#13989280
+0 ## Emotion_directed - discouragement.n - n#7542675
+0 ## Emotion_directed - perplexed.a - a#1765643
+0 ## Emotion_directed - worried.a - a#2457167
+0 ## Emotion_directed - disgruntled.a - a#590163
+0 ## Emotion_directed - covetous.a - a#888765
+0 ## Emotion_directed - crushed.a - a#1893303
+0 ## Emotion_directed - frightened.a - a#79629
+0 ## Emotion_directed - perplexity.n - n#5685363
+0 ## Emotion_directed - gleeful.a - a#1367211
+0 ## Emotion_directed - irritated.a - a#1806106
+0 ## Emotion_directed - appalled.a - a#78576
+0 ## Emotion_directed - bored.a - a#2432682
+0 ## Emotion_directed - humiliated.a - a#154270
+0 ## Emotion_directed - stunned.a - a#2357810
+0 ## Emotion_directed - inconsolable.a - a#1232298
+0 ## Emotion_directed - despair.n - n#7541923
+0 ## Emotion_directed - dismay.n - n#7542675
+0 ## Emotion_directed - astonished.a - a#2357810
+0 ## Emotion_directed - anguished.a - a#1364585
+0 ## Emotion_directed - overwrought.a - a#85870
+0 ## Emotion_directed - sympathize.v - v#1822248
+0 ## Emotion_directed - disheartened.a - a#1664880
+0 ## Emotion_directed - perturbed.a - a#532560
+0 ## Emotion_directed - agitation.n - n#14403107
+0 ## Emotion_directed - abashed.a - a#531628
+0 ## Emotion_directed - vexed.a - a#2455845
+0 ## Emotion_directed - heartbroken.a - a#1365103
+0 ## Emotion_directed - disquiet.n - n#7524760
+0 ## Emotion_directed - dejection.n - n#14486533
+0 ## Emotion_directed - disquieted.a - a#2457167
+0 ## Emotion_directed - chagrined.a - a#531628
+0 ## Emotion_directed - elation.n - n#14405225
+0 ## Emotion_directed - demolished.a - a#735608
+0 ## Emotion_directed - unsympathetic.a - a#1374461
+0 ## Emotion_directed - bewildered.a - a#1766133
+0 ## Emotion_directed - bafflement.n - n#5685030
+0 ## Emotion_directed - terror-stricken.a - a#80981
+0 ## Emotion_directed - excited.a - a#919542
+0 ## Emotion_directed - wretched.a - a#2347086
+0 ## Emotion_directed - disconcertion.n - n#7508232
+0 ## Emotion_directed - concerned.a - a#543603
+0 ## Emotion_directed - ashamed.a - a#153898
+0 ## Emotion_directed - vexation.n - n#7518261
+0 ## Emotion_directed - mortification.n - n#7507742
+0 ## Emotion_directed - blue.a - a#703615
+0 ## Emotion_directed - offended.a - a#1807075
+0 ## Emotion_directed - anger.n - n#7516354
+0 ## Emotion_directed - displeased.a - a#1805889
+0 ## Emotion_directed - horror.n - n#7503987
+0 ## Emotion_directed - agonized.a - a#1711614
+0 ## Emotion_directed - dejected.a - a#703109
+0 ## Emotion_directed - befuddled.a - a#1766133
+0 ## Emotion_directed - lugubrious.a - a#1366062
+0 ## Emotion_directed - disappointed.a - a#2333976
+0 ## Emotion_directed - miserable.a - a#1150205
+0 ## Emotion_directed - miffed.a - a#1806106
+0 ## Emotion_directed - disgruntlement.n - n#7539259
+0 ## Emotion_directed - gratification.n - n#13986679
+0 ## Emotion_directed - sore.a - a#115193
+0 ## Emotion_directed - delighted.a - a#865620
+0 ## Emotion_directed - crestfallen.a - a#703454
+0 ## Emotion_directed - glumness.n - n#14525365
+0 ## Emotion_directed - sympathy.n - n#7553301
+0 ## Emotion_directed - angry.a - a#113818
+0 ## Emotion_directed - infuriated.a - a#114454
+0 ## Emotion_directed - fascinated.a - a#865848
+0 ## Emotion_directed - embarrassment.n - n#7507098
+0 ## Emotion_directed - disoriented.a - a#1684133
+0 ## Emotion_directed - depressed.a - a#703615
+0 ## Emotion_directed - stupefied.a - a#2358277
+0 ## Emotion_directed - astonishment.n - n#7509572
+0 ## Emotion_directed - nonplussed.a - a#1765926
+0 ## Emotion_directed - contented.a - a#588797
+0 ## Emotion_directed - stressed.a - a#2458497
+0 ## Emotion_directed - exhilaration.n - n#7528212
+0 ## Emotion_directed - exasperated.a - a#1806483
+0 ## Emotion_directed - happy.a - a#1148283
+0 ## Emotion_directed - bewilderment.n - n#5685030
+0 ## Emotion_directed - downhearted.a - a#703615
+0 ## Emotion_directed - displeasure.n - n#7540424
+0 ## Emotion_directed - baffled.a - a#1766133
+0 ## Emotion_directed - fury.n - n#7516997
+0 ## Emotion_directed - low-spirited.a - a#703615
+0 ## Emotion_directed - disconsolate.a - a#1232298
+0 ## Emotion_directed - boredom.n - n#7539790
+0 ## Emotion_directed - irate.a - a#115777
+0 ## Emotion_directed - upset.a - a#2457167
+0 ## Emotion_directed - embarrassed.a - a#154270
+0 ## Emotion_directed - grief-stricken.a - a#1364817
+0 ## Emotion_directed - gratified.a - a#1805801
+0 ## Emotion_directed - amusement.n - n#7491476
+0 ## Emotion_directed - resentful.a - a#116529
+0 ## Emotion_directed - agony.n - n#7495551
+0 ## Emotion_directed - nervous.a - a#2456157
+0 ## Emotion_directed - anxious.a - a#2456157
+0 ## Emotion_directed - outrage.n - n#7517737
+0 ## Emotion_directed - incensed.a - a#115494
+0 ## Emotion_directed - disconcerted.a - a#532288
+0 ## Emotion_directed - enraged.a - a#114454
+0 ## Emotion_directed - unsettled.a - a#2130514
+0 ## Emotion_directed - thrilled.a - a#920704
+0 ## Emotion_directed - revulsion.n - n#7503987
+0 ## Emotion_directed - chagrin.n - n#7507742
+0 ## Emotion_directed - alarmed.a - a#78851
+0 ## Emotion_directed - overjoyed.a - a#1363936
+0 ## Emotion_directed - sorrowful.a - a#1364008
+0 ## Emotion_directed - delight.n - n#7491038
+0 ## Emotion_directed - shocked.a - a#78576
+0 ## Emotion_directed - harried.a - a#2455845
+0 ## Emotion_directed - tormented.a - a#1364585
+0 ## Emotion_directed - astounded.a - a#2357810
+0 ## Emotion_directed - exasperation.n - n#425451
+0 ## Emotion_directed - jubilant.a - a#1367211
+0 ## Emotion_directed - discomfiture.n - n#7508232
+0 ## Emotion_directed - ruffled.a - a#88157
+0 ## Emotion_directed - interest.n - n#5682950
+0 ## Emotion_directed - startled.a - a#2359051
+0 ## Emotion_directed - downcast.a - a#703615
+0 ## Emotion_directed - pleased.a - a#1805157
+0 ## Emotion_directed - fed up.a - a#1806677
+0 ## Emotion_directed - disappointment.n - n#7540602
+0 ## Emotion_directed - livid.a - a#115906
+0 ## Emotion_directed - riled.a - a#1806106
+0 ## Emotion_directed - discouraged.a - a#1664880
+0 ## Emotion_directed - sympathetic.a - a#2374914
+0 ## Emotion_directed - exhilarated.a - a#705336
+0 ## Emotion_directed - sad.a - a#1361863
+0 ## Emotion_directed - glum.a - a#704270
+0 ## Emotion_directed - relaxed.a - a#2407603
+0 ## Emotion_directed - mournful.a - a#1366157
+0 ## Emotion_directed - horrified.a - a#79786
+0 ## Emotion_directed - woebegone.a - a#1366525
+0 ## Emotion_directed - heartbreak.n - n#7535010
+0 ## Emotion_directed - desolate.a - a#1232507
+0 ## Emotion_directed - amused.a - a#1805355
+0 ## Emotion_directed - mystification.n - n#5685030
+0 ## Emotion_directed - mystified.a - a#1766550
+0 ## Emotion_directed - despondent.a - a#1230153
+0 ## Emotion_directed - nettled.a - a#1806106
+0 ## Emotion_directed - distressed.a - a#2457167
+0 ## Emotion_directed - flabbergasted.a - a#2358277
+0 ## Emotion_directed - agitated.a - a#85264
+0 ## Emotion_directed - despondency.n - n#7538395
+0 ## Emotion_directed - annoyed.a - a#1806106
+0 ## Emotion_directed - stupefaction.n - n#7510495
+0 ## Emotion_directed - puzzlement.n - n#5685030
+0 ## Emotion_directed - glee.n - n#7529377
+0 ## Emotion_directed - flustered.a - a#532560
+0 ## Emotion_directed - ecstatic.a - a#1367008
+0 ## Emotion_directed - dismayed.a - a#78576
+0 ## Emotion_directed - distress.n - n#7496463
+0 ## Emotion_directed - concern.n - n#5832264
+0 ## Proliferating_in_number - proliferate.v - v#247830
+0 ## Proliferating_in_number - proliferation.n - n#13542114
+0 ## Proliferating_in_number - non-proliferation.n - n#1078572
+0 ## Proliferating_in_number - multiply.v - v#247390
+0 ## Proliferating_in_number - dwindle.v - v#267681
+0 ## Successful_action - come off.v - v#1299758
+0 ## Successful_action - unsuccessful.a - a#2333453
+0 ## Successful_action - success.n - n#14474894
+0 ## Successful_action - manage.v - v#2522864
+0 ## Successful_action - succeed.v - v#2524171
+0 ## Successful_action - fail.v - v#2529284
+0 ## Successful_action - successful.a - a#2331262
+0 ## Successful_action - do it.v - v#1426397
+0 ## Successful_action - go wrong.v - v#2528380
+0 ## Attempt - quest.n - n#5770391
+0 ## Attempt - endeavor.v - v#2531199
+0 ## Attempt - attempt.v - v#2530167
+0 ## Attempt - try.n - n#786195
+0 ## Attempt - go.n - n#787061
+0 ## Attempt - try.v - v#2530167
+0 ## Attempt - endeavor.n - n#786195
+0 ## Attempt - attempt.n - n#786195
+0 ## Attempt - shot.n - n#788473
+0 ## Attempt - effort.n - n#786195
+0 ## Attempt - stab.n - n#788473
+0 ## Attempt - undertake.v - v#1651293
+0 ## Undergo_change - changeable.a - a#356339
+0 ## Undergo_change - transition.n - n#7415730
+0 ## Undergo_change - turn.v - v#1907258
+0 ## Undergo_change - plummet.v - v#1978199
+0 ## Undergo_change - change.v - v#109660
+0 ## Undergo_change - metamorphosis.n - n#402128
+0 ## Undergo_change - transformation.n - n#398704
+0 ## Undergo_change - shift.v - v#380159
+0 ## Undergo_change - shift.n - n#7359599
+0 ## Undergo_change - swing.v - v#1877620
+0 ## Undergo_change - veer.v - v#2033295
+0 ## Undergo_change - change.n - n#7296428
+0 ## Bungling - screw up.v - v#2527651
+0 ## Bungling - bollix.v - v#2527651
+0 ## Bungling - fiasco.n - n#7365432
+0 ## Bungling - flounder.v - v#1925170
+0 ## Bungling - bollix up.v - v#2527651
+0 ## Bungling - blow.v - v#2527651
+0 ## Bungling - fluff.v - v#2527651
+0 ## Bungling - founder.v - v#1900648
+0 ## Bungling - bumbling.a - a#63563
+0 ## Bungling - muff.v - v#2527651
+0 ## Bungling - louse up.v - v#2527651
+0 ## Bungling - fumble.v - v#2527651
+0 ## Bungling - stumble.v - v#618057
+0 ## Bungling - fumble.n - n#75912
+0 ## Bungling - botch.v - v#2527651
+0 ## Bungling - bungling.a - a#63563
+0 ## Bungling - bungler.n - n#9879744
+0 ## Bungling - bungle.v - v#2527651
+0 ## Bungling - muck up.v - v#2527651
+0 ## Bungling - botch up.v - v#2527651
+0 ## Bungling - bumble.v - v#2527651
+0 ## Bungling - mess up.v - v#2527651
+0 ## Bungling - flub.v - v#2527651
+0 ## Bungling - ball up.v - v#2527651
+0 ## Bungling - fuck up.v - v#2527651
+0 ## Bungling - foul up.v - v#2527651
+0 ## Bungling - ruin.v - v#1564144
+0 ## Bungling - mess-up.n - n#75618
+0 ## Gizmo - centrifuge.n - n#2995998
+0 ## Gizmo - core.n - n#3107904
+0 ## Gizmo - system.n - n#4377057
+0 ## Gizmo - mechanical.a - a#1499686
+0 ## Gizmo - implement.n - n#3563967
+0 ## Gizmo - device.n - n#3183080
+0 ## Gizmo - instrument.n - n#3574816
+0 ## Gizmo - gadget.n - n#2729965
+0 ## Gizmo - gear.n - n#3430959
+0 ## Gizmo - tool.n - n#4451818
+0 ## Gizmo - equipment.n - n#3294048
+0 ## Gizmo - player.n - n#10340312
+0 ## Gizmo - technology.n - n#949619
+0 ## Gizmo - contraption.n - n#2729965
+0 ## Gizmo - apparatus.n - n#2727825
+0 ## Gizmo - utensil.n - n#4516672
+0 ## Gizmo - machine.n - n#3699975
+0 ## Gizmo - appliance.n - n#2729965
+0 ## Cause_expansion - widen.v - v#540235
+0 ## Cause_expansion - dilate.v - v#955601
+0 ## Cause_expansion - enlargement.n - n#365709
+0 ## Cause_expansion - contraction.n - n#365471
+0 ## Cause_expansion - inflate.v - v#264034
+0 ## Cause_expansion - grow.v - v#230746
+0 ## Cause_expansion - growth.n - n#13489037
+0 ## Cause_expansion - shrink.v - v#241038
+0 ## Cause_expansion - magnify.v - v#240293
+0 ## Cause_expansion - blow up.v - v#240293
+0 ## Cause_expansion - expansion.n - n#365709
+0 ## Cause_expansion - magnification.n - n#367427
+0 ## Cause_expansion - expand.v - v#257269
+0 ## Cause_expansion - lengthen.v - v#317700
+0 ## Cause_expansion - enlarge.v - v#240293
+0 ## Cause_expansion - narrow.v - v#305109
+0 ## Cause_expansion - swell.v - v#256507
+0 ## Cause_expansion - aggrandizement.n - n#373544
+0 ## Cause_expansion - stretch.v - v#240810
+0 ## Cause_expansion - reduction.n - n#351638
+0 ## Cause_expansion - augmentation.n - n#365231
+0 ## Immobilization - tie up.v - v#1286038
+0 ## Immobilization - handcuff.v - v#1288201
+0 ## Immobilization - shackle.v - v#1288052
+0 ## Long_or_short_selling - sell short.v - v#2243186
+0 ## Eclipse - hidden.a - a#2517817
+0 ## Eclipse - occultation.n - n#7368646
+0 ## Eclipse - befog.v - v#2157731
+0 ## Eclipse - eclipse.n - n#7368646
+0 ## Eclipse - blot_out.v - v#313987
+0 ## Eclipse - cloak.v - v#2147603
+0 ## Eclipse - concealed.a - a#2088404
+0 ## Eclipse - screen.v - v#1477538
+0 ## Eclipse - mask.v - v#2158587
+0 ## Eclipse - befogged.a - a#436385
+0 ## Eclipse - conceal.v - v#2144835
+0 ## Eclipse - masked.a - a#1707230
+0 ## Eclipse - enshroud.v - v#1582200
+0 ## Eclipse - obstruct.v - v#1476483
+0 ## Eclipse - occlude.v - v#1476483
+0 ## Eclipse - eclipse.v - v#2744280
+0 ## Eclipse - occlusion.n - n#2853449
+0 ## Eclipse - cover.v - v#1582200
+0 ## Eclipse - covered.a - a#1694223
+0 ## Eclipse - veiled.a - a#2508104
+0 ## Eclipse - becloud.v - v#2157731
+0 ## Eclipse - veil.v - v#1483247
+0 ## Eclipse - hide.v - v#2144835
+0 ## Eclipse - block.v - v#2145543
+0 ## Eclipse - obscure.v - v#2157731
+0 ## Eclipse - cloaked.a - a#1707230
+0 ## Eclipse - shroud.v - v#1582200
+0 ## Temporal_pattern - rhythmic.a - a#2019021
+0 ## Temporal_pattern - time.n - n#7309599
+0 ## Temporal_pattern - rhythmically.adv - r#401581
+0 ## Temporal_pattern - beat.n - n#7086518
+0 ## Temporal_pattern - rhythm.n - n#7086518
+0 ## Body_decoration - eyeshadow.n - n#3309687
+0 ## Body_decoration - mascara.n - n#3724066
+0 ## Body_decoration - kohl.n - n#3628071
+0 ## Body_decoration - lipstick.n - n#3676483
+0 ## Body_decoration - eyeliner.n - n#3309110
+0 ## Body_decoration - tattoo.n - n#4395651
+0 ## Body_decoration - blusher.n - n#4112752
+0 ## Body_decoration - foundation.n - n#3387016
+0 ## Body_decoration - rouge.n - n#4112752
+0 ## Body_decoration - make-up.n - n#3714235
+0 ## Causation - force.v - v#1650425
+0 ## Causation - give rise.v - v#1752884
+0 ## Causation - precipitate.v - v#1644339
+0 ## Causation - see.v - v#2129289
+0 ## Causation - bring.v - v#767334
+0 ## Causation - raise.v - v#1629958
+0 ## Causation - leave.v - v#2729414
+0 ## Causation - induce.v - v#770437
+0 ## Causation - put.v - v#1494310
+0 ## Causation - make.v - v#120316
+0 ## Causation - result.n - n#11410625
+0 ## Causation - cause.n - n#7347
+0 ## Causation - lead_(to).v - v#771632
+0 ## Causation - send.v - v#1951480
+0 ## Causation - wreak.v - v#1629589
+0 ## Causation - cause.v - v#1645601
+0 ## Causation - render.v - v#1629000
+0 ## Causation - bring on.v - v#1644050
+0 ## Causation - reason.n - n#6740402
+0 ## Causation - result_(in).v - v#2635659
+0 ## Causation - mean.v - v#2635189
+0 ## Causation - causative.a - a#322457
+0 ## Causation - bring_about.v - v#1752884
+0 ## Being_at_risk - security.n - n#14539268
+0 ## Being_at_risk - vulnerability.n - n#14543931
+0 ## Being_at_risk - safety.n - n#14538472
+0 ## Being_at_risk - risk.n - n#14541852
+0 ## Being_at_risk - safe.a - a#2057829
+0 ## Being_at_risk - secure.a - a#2093888
+0 ## Being_at_risk - danger.n - n#14540765
+0 ## Being_at_risk - vulnerable.a - a#2523275
+0 ## Being_at_risk - insecure.a - a#2094755
+0 ## Being_at_risk - unsafe.a - a#2094755
+0 ## Usefulness - wonderful.a - a#1676517
+0 ## Usefulness - utility.n - n#5148699
+0 ## Usefulness - fine.a - a#2081114
+0 ## Usefulness - work.v - v#1525666
+0 ## Usefulness - excellent.a - a#2343110
+0 ## Usefulness - useful.a - a#2495922
+0 ## Usefulness - good.a - a#1123148
+0 ## Usefulness - super.a - a#2341864
+0 ## Usefulness - tremendous.a - a#1676517
+0 ## Usefulness - great.a - a#1278818
+0 ## Usefulness - value.n - n#5856388
+0 ## Usefulness - perfect.a - a#1749320
+0 ## Usefulness - terrific.a - a#1676517
+0 ## Usefulness - ideal.a - a#1751201
+0 ## Usefulness - superb.a - a#1125154
+0 ## Usefulness - effective.a - a#834198
+0 ## Usefulness - ineffective.a - a#835609
+0 ## Usefulness - splendid.a - a#2343110
+0 ## Usefulness - valuable.a - a#2500884
+0 ## Usefulness - outstanding.a - a#1278818
+0 ## Usefulness - marvellous.a - a#1676517
+0 ## Usefulness - fantastic.a - a#1676517
+0 ## People_along_political_spectrum - conservative.n - n#9957156
+0 ## People_along_political_spectrum - leftist.n - n#10619176
+0 ## People_along_political_spectrum - left.n - n#8625462
+0 ## Emptying - delouse.v - v#531163
+0 ## Emptying - stone.v - v#179567
+0 ## Emptying - core.v - v#1590523
+0 ## Emptying - void.v - v#73343
+0 ## Emptying - bone.v - v#197423
+0 ## Emptying - strip.v - v#1263479
+0 ## Emptying - skin.v - v#1262936
+0 ## Emptying - disarmament.n - n#1157557
+0 ## Emptying - peel.v - v#1262936
+0 ## Emptying - expunge.v - v#1549420
+0 ## Emptying - weed.v - v#313171
+0 ## Emptying - disembowel.v - v#197590
+0 ## Emptying - clear.v - v#195342
+0 ## Emptying - degrease.v - v#2364668
+0 ## Emptying - descale.v - v#1264148
+0 ## Emptying - divest.v - v#2314275
+0 ## Emptying - rid.v - v#2350175
+0 ## Emptying - debug.v - v#200242
+0 ## Emptying - stalk.v - v#1924148
+0 ## Emptying - devein.v - v#2365481
+0 ## Emptying - disarm.v - v#1088005
+0 ## Emptying - purge.v - v#73813
+0 ## Emptying - scalp.v - v#198477
+0 ## Emptying - denude.v - v#194912
+0 ## Emptying - seed.v - v#179718
+0 ## Emptying - decontaminate.v - v#493052
+0 ## Emptying - expurgate.v - v#201034
+0 ## Emptying - evacuate.v - v#73343
+0 ## Emptying - debone.v - v#197423
+0 ## Emptying - gut.v - v#1591012
+0 ## Emptying - drain.v - v#451648
+0 ## Emptying - emptying.n - n#395797
+0 ## Emptying - pit.v - v#179567
+0 ## Emptying - cleanse.v - v#501896
+0 ## Emptying - empty.v - v#449692
+0 ## Emptying - defrost.v - v#376807
+0 ## Emptying - eviscerate.v - v#450168
+0 ## Emptying - deforest.v - v#196024
+0 ## Emptying - unload.v - v#1488123
+0 ## Emptying - flush.v - v#455529
+0 ## Emptying - decontamination.n - n#394485
+0 ## Complaining - gripe.n - n#7209965
+0 ## Complaining - grouse.v - v#910973
+0 ## Complaining - lament.v - v#911350
+0 ## Complaining - complaint.n - n#7208708
+0 ## Complaining - whine.v - v#907930
+0 ## Complaining - complain.v - v#907147
+0 ## Complaining - bitch.v - v#910973
+0 ## Complaining - gripe.v - v#910973
+0 ## Complaining - moan.v - v#1045419
+0 ## Complaining - grumble.v - v#909573
+0 ## Cogitation - ruminate.v - v#630380
+0 ## Cogitation - ponder.v - v#630380
+0 ## Cogitation - thought.n - n#5833840
+0 ## Cogitation - reflect.v - v#630380
+0 ## Cogitation - consider.v - v#2166460
+0 ## Cogitation - muse.v - v#630380
+0 ## Cogitation - reflection.n - n#5785508
+0 ## Cogitation - deliberation.n - n#5785067
+0 ## Cogitation - contemplate.v - v#630380
+0 ## Cogitation - think.v - v#628491
+0 ## Cogitation - consideration.n - n#5784831
+0 ## Cogitation - deliberate.v - v#813044
+0 ## Cogitation - meditation.n - n#5785885
+0 ## Cogitation - mull_over.v - v#630380
+0 ## Cogitation - contemplation.n - n#5785508
+0 ## Cogitation - meditate.v - v#630380
+0 ## Cogitation - wonder.v - v#925110
+0 ## Cogitation - brood.v - v#704249
+0 ## Cogitation - dwell.v - v#704249
+0 ## Appearance - stink.v - v#2124106
+0 ## Appearance - sound.v - v#2134927
+0 ## Appearance - smell.v - v#2124332
+0 ## Appearance - taste.v - v#2194286
+0 ## Appearance - seem.v - v#2133435
+0 ## Appearance - feel.v - v#1771535
+0 ## Appearance - reek.v - v#2124106
+0 ## Appearance - look.v - v#2133435
+0 ## Appearance - appear.v - v#2133435
+0 ## Activity_ready_state - prepared.a - a#1843380
+0 ## Activity_ready_state - set.a - a#1931203
+0 ## Activity_ready_state - ready.a - a#1930512
+0 ## Destroying - devastate.v - v#388635
+0 ## Destroying - unmake.v - v#1619231
+0 ## Destroying - dismantlement.n - n#912274
+0 ## Destroying - demolish.v - v#1656458
+0 ## Destroying - raze.v - v#1661804
+0 ## Destroying - level.v - v#1661804
+0 ## Destroying - dismantle.v - v#1661804
+0 ## Destroying - obliteration.n - n#218208
+0 ## Destroying - devastation.n - n#217014
+0 ## Destroying - annihilate.v - v#470701
+0 ## Destroying - destruction.n - n#7334490
+0 ## Destroying - destructive.a - a#586183
+0 ## Destroying - vaporize.v - v#442267
+0 ## Destroying - blow up.v - v#240293
+0 ## Destroying - obliterate.v - v#478830
+0 ## Destroying - annihilation.n - n#218208
+0 ## Destroying - demolition.n - n#7334490
+0 ## Destroying - destroy.v - v#1619929
+0 ## Adding_up - tally.v - v#949288
+0 ## Adding_up - total.v - v#949288
+0 ## Adding_up - add up.v - v#949288
+0 ## Experiencer_obj - harass.v - v#1789514
+0 ## Experiencer_obj - sadden.v - v#1813053
+0 ## Experiencer_obj - petrify.v - v#192471
+0 ## Experiencer_obj - madden.v - v#1787709
+0 ## Experiencer_obj - flummox.v - v#622384
+0 ## Experiencer_obj - arouse.v - v#1759326
+0 ## Experiencer_obj - fulfill.v - v#2671880
+0 ## Experiencer_obj - humiliate.v - v#1799794
+0 ## Experiencer_obj - shame.v - v#1792287
+0 ## Experiencer_obj - frustrate.v - v#1803003
+0 ## Experiencer_obj - frighten.v - v#1779165
+0 ## Experiencer_obj - stun.v - v#268968
+0 ## Experiencer_obj - console.v - v#1814815
+0 ## Experiencer_obj - embarrass.v - v#1792097
+0 ## Experiencer_obj - mystify.v - v#622384
+0 ## Experiencer_obj - intrigue.v - v#2678839
+0 ## Experiencer_obj - bewitch.v - v#1806505
+0 ## Experiencer_obj - startle.v - v#1821634
+0 ## Experiencer_obj - rattle.v - v#1890626
+0 ## Experiencer_obj - comfort.v - v#1814815
+0 ## Experiencer_obj - thrill.v - v#1796346
+0 ## Experiencer_obj - enrage.v - v#1795888
+0 ## Experiencer_obj - tickle.v - v#1796346
+0 ## Experiencer_obj - abash.v - v#1792097
+0 ## Experiencer_obj - wound.v - v#1793177
+0 ## Experiencer_obj - wow.v - v#1770252
+0 ## Experiencer_obj - embitter.v - v#1773535
+0 ## Experiencer_obj - gall.v - v#1786760
+0 ## Experiencer_obj - irk.v - v#1786760
+0 ## Experiencer_obj - sting.v - v#1793742
+0 ## Experiencer_obj - conciliate.v - v#1765392
+0 ## Experiencer_obj - torment.v - v#1803003
+0 ## Experiencer_obj - pacify.v - v#1765392
+0 ## Experiencer_obj - disturb.v - v#1770501
+0 ## Experiencer_obj - terrify.v - v#1780941
+0 ## Experiencer_obj - impress.v - v#1767949
+0 ## Experiencer_obj - displease.v - v#1817130
+0 ## Experiencer_obj - anger.v - v#1785971
+0 ## Experiencer_obj - devastate.v - v#388635
+0 ## Experiencer_obj - boggle.v - v#726153
+0 ## Experiencer_obj - worry.v - v#1765908
+0 ## Experiencer_obj - sober.v - v#149469
+0 ## Experiencer_obj - grate.v - v#1773825
+0 ## Experiencer_obj - bewilder.v - v#622384
+0 ## Experiencer_obj - puzzle.v - v#622384
+0 ## Experiencer_obj - hearten.v - v#1817938
+0 ## Experiencer_obj - soothe.v - v#1814815
+0 ## Experiencer_obj - surprise.v - v#725274
+0 ## Experiencer_obj - exhilarate.v - v#1812324
+0 ## Experiencer_obj - rile.v - v#1787955
+0 ## Experiencer_obj - stimulate.v - v#1761706
+0 ## Experiencer_obj - faze.v - v#1783881
+0 ## Experiencer_obj - incense.v - v#1786906
+0 ## Experiencer_obj - amaze.v - v#622384
+0 ## Experiencer_obj - perplex.v - v#622384
+0 ## Experiencer_obj - outrage.v - v#1810447
+0 ## Experiencer_obj - shock.v - v#1810447
+0 ## Experiencer_obj - entertain.v - v#2492198
+0 ## Experiencer_obj - enchant.v - v#1806505
+0 ## Experiencer_obj - destroy.v - v#1564144
+0 ## Experiencer_obj - stir.v - v#1761706
+0 ## Experiencer_obj - vex.v - v#622384
+0 ## Experiencer_obj - satisfy.v - v#1816431
+0 ## Experiencer_obj - intimidate.v - v#1781180
+0 ## Experiencer_obj - floor.v - v#1809064
+0 ## Experiencer_obj - aggrieve.v - v#1797582
+0 ## Experiencer_obj - delight.v - v#1815628
+0 ## Experiencer_obj - baffle.v - v#622384
+0 ## Experiencer_obj - solace.v - v#1814815
+0 ## Experiencer_obj - crush.v - v#1800195
+0 ## Experiencer_obj - astound.v - v#724832
+0 ## Experiencer_obj - annoy.v - v#1787955
+0 ## Experiencer_obj - upset.v - v#1790020
+0 ## Experiencer_obj - excite.v - v#1761706
+0 ## Experiencer_obj - nonplus.v - v#622384
+0 ## Experiencer_obj - captivate.v - v#1806505
+0 ## Experiencer_obj - nettle.v - v#1787955
+0 ## Experiencer_obj - antagonize.v - v#1807314
+0 ## Experiencer_obj - perturb.v - v#1764171
+0 ## Experiencer_obj - stupefy.v - v#622384
+0 ## Experiencer_obj - charm.v - v#1806505
+0 ## Experiencer_obj - placate.v - v#1765392
+0 ## Experiencer_obj - please.v - v#1815628
+0 ## Experiencer_obj - unsettle.v - v#1783881
+0 ## Experiencer_obj - traumatize.v - v#90186
+0 ## Experiencer_obj - rankle.v - v#1773825
+0 ## Experiencer_obj - unnerve.v - v#1783881
+0 ## Experiencer_obj - stagger.v - v#1810126
+0 ## Experiencer_obj - dishearten.v - v#1819387
+0 ## Experiencer_obj - appeal.v - v#1807882
+0 ## Experiencer_obj - trouble.v - v#1770501
+0 ## Experiencer_obj - revolt.v - v#2194913
+0 ## Experiencer_obj - reassure.v - v#1766407
+0 ## Experiencer_obj - irritate.v - v#1787955
+0 ## Experiencer_obj - gratify.v - v#1816431
+0 ## Experiencer_obj - mollify.v - v#1765392
+0 ## Experiencer_obj - gladden.v - v#1813499
+0 ## Experiencer_obj - scare.v - v#1779165
+0 ## Experiencer_obj - engage.v - v#600370
+0 ## Experiencer_obj - surprise.n - n#7298154
+0 ## Experiencer_obj - encourage.v - v#1818235
+0 ## Experiencer_obj - mortify.v - v#1799794
+0 ## Experiencer_obj - distress.v - v#1798100
+0 ## Experiencer_obj - discourage.v - v#1819147
+0 ## Experiencer_obj - demolish.v - v#1800195
+0 ## Experiencer_obj - interest.v - v#1821423
+0 ## Experiencer_obj - beguile.v - v#1806505
+0 ## Experiencer_obj - repel.v - v#2194913
+0 ## Experiencer_obj - aggravate.v - v#1820901
+0 ## Experiencer_obj - disappoint.v - v#1798936
+0 ## Experiencer_obj - shocker.n - n#10590977
+0 ## Experiencer_obj - flabbergast.v - v#726153
+0 ## Experiencer_obj - trouble.n - n#7289014
+0 ## Experiencer_obj - depress.v - v#1814396
+0 ## Experiencer_obj - vexation.n - n#7518261
+0 ## Experiencer_obj - infuriate.v - v#1786906
+0 ## Experiencer_obj - fascinate.v - v#1806505
+0 ## Experiencer_obj - alarm.v - v#1782650
+0 ## Experiencer_obj - sicken.v - v#1808374
+0 ## Experiencer_obj - dazzle.v - v#725046
+0 ## Experiencer_obj - calm.v - v#1764800
+0 ## Experiencer_obj - astonish.v - v#724832
+0 ## Experiencer_obj - agonize.v - v#1794523
+0 ## Experiencer_obj - fluster.v - v#1790383
+0 ## Experiencer_obj - cheer.v - v#1817938
+0 ## Experiencer_obj - discomfit.v - v#1790020
+0 ## Experiencer_obj - disconcert.v - v#1790020
+0 ## Experiencer_obj - offend.v - v#1793177
+0 ## Experiencer_obj - exasperate.v - v#1786906
+0 ## Experiencer_obj - bore.v - v#1821884
+0 ## Experiencer_obj - spook.v - v#1830965
+0 ## Experiencer_obj - confuse.v - v#621734
+0 ## Experiencer_obj - shake.v - v#1761706
+0 ## Experiencer_obj - enthrall.v - v#1817314
+0 ## Fame - reputation.n - n#14438125
+0 ## Fame - legendary.a - a#1376355
+0 ## Fame - notoriety.n - n#14439149
+0 ## Fame - fame.n - n#14437386
+0 ## Fame - epic.a - a#3015589
+0 ## Fame - renown.n - n#14437386
+0 ## Fame - infamous.a - a#1984411
+0 ## Fame - famous.a - a#1375831
+0 ## Fame - renowned.a - a#1375831
+0 ## Fame - notorious.a - a#1984411
+0 ## Fame - stature.n - n#14437976
+0 ## Transfer - transfer.v - v#2232190
+0 ## Transfer - transfer.n - n#315986
+0 ## Getting_underway - get going.v - v#348541
+0 ## Reading_aloud - read.v - v#625119
+0 ## Misdeed - transgress.v - v#2566528
+0 ## Misdeed - peccadillo.n - n#738785
+0 ## Misdeed - sin.n - n#757080
+0 ## Misdeed - misdeed.n - n#735936
+0 ## Misdeed - transgression.n - n#745005
+0 ## Misdeed - sin.v - v#2565687
+0 ## Cause_change_of_phase - boil.v - v#374668
+0 ## Cause_change_of_phase - flux.v - v#443984
+0 ## Cause_change_of_phase - solidify.v - v#445169
+0 ## Cause_change_of_phase - freeze.v - v#374135
+0 ## Cause_change_of_phase - unfreeze.v - v#376106
+0 ## Cause_change_of_phase - evaporate.v - v#223928
+0 ## Cause_change_of_phase - thaw.v - v#376106
+0 ## Cause_change_of_phase - liquefy.v - v#443984
+0 ## Cause_change_of_phase - defrost.v - v#376807
+0 ## Cause_change_of_phase - melt.v - v#376106
+0 ## Posture - position.n - n#8621598
+0 ## Posture - sit.v - v#1543123
+0 ## Posture - hunch.v - v#2035559
+0 ## Posture - hunched.a - a#1239199
+0 ## Posture - bent.a - a#1238343
+0 ## Posture - lie.v - v#2690708
+0 ## Posture - squat.v - v#1545314
+0 ## Posture - seated.a - a#1240029
+0 ## Posture - stance.n - n#6196284
+0 ## Posture - sprawl.v - v#1543426
+0 ## Posture - slouch.v - v#1989720
+0 ## Posture - huddled.a - a#559930
+0 ## Posture - stand.v - v#1546111
+0 ## Posture - huddle.v - v#2063988
+0 ## Posture - posture.n - n#5079866
+0 ## Posture - kneel.v - v#1545649
+0 ## Posture - stoop.v - v#2062632
+0 ## Posture - bend.v - v#2035919
+0 ## Posture - lean.v - v#2038357
+0 ## Posture - crouch.v - v#2062632
+0 ## Cause_fluidic_motion - squirt.v - v#1375637
+0 ## Cause_fluidic_motion - drip.v - v#2071142
+0 ## Cause_fluidic_motion - sprinkle.v - v#1376245
+0 ## Cause_fluidic_motion - pump.v - v#1225684
+0 ## Cause_fluidic_motion - splatter.v - v#1374020
+0 ## Cause_fluidic_motion - spatter.v - v#1374020
+0 ## Cause_fluidic_motion - splash.v - v#1374020
+0 ## Cause_fluidic_motion - spray.v - v#1373844
+0 ## Partiality - prefer.v - v#679389
+0 ## Partiality - favor.v - v#2400037
+0 ## Partiality - bias.v - v#1085677
+0 ## Partiality - prejudice.n - n#6201908
+0 ## Partiality - neutrality.n - n#1240850
+0 ## Partiality - biased.a - a#1723091
+0 ## Partiality - partial.a - a#1722965
+0 ## Partiality - impartial.a - a#1723308
+0 ## Partiality - prejudiced.a - a#1616244
+0 ## Partiality - prejudge.v - v#681281
+0 ## Partiality - bias.n - n#6201908
+0 ## Partiality - partiality.n - n#6201136
+0 ## Partiality - impartiality.n - n#6202686
+0 ## Partiality - neutral.a - a#732160
+0 ## Emitting - radiate.v - v#2767116
+0 ## Emitting - give off.v - v#2767308
+0 ## Emitting - secrete.v - v#69295
+0 ## Emitting - void.v - v#73343
+0 ## Emitting - emit.v - v#2767308
+0 ## Emitting - excrete.v - v#72989
+0 ## Emitting - discharge.v - v#104868
+0 ## Emitting - exude.v - v#67999
+0 ## Emitting - exhale.v - v#4605
+0 ## Sign_agreement - sign.v - v#996485
+0 ## Sign_agreement - signatory.n - n#10597234
+0 ## Sign_agreement - accede.v - v#804139
+0 ## Sign_agreement - signature.n - n#6404582
+0 ## Absorb_heat - scorch.v - v#379440
+0 ## Absorb_heat - boil.v - v#328128
+0 ## Absorb_heat - simmer.v - v#324231
+0 ## Absorb_heat - bake.v - v#319886
+0 ## Absorb_heat - fry.v - v#325328
+0 ## Absorb_heat - sear.v - v#379440
+0 ## Absorb_heat - sizzle.v - v#377906
+0 ## Absorb_heat - cook.v - v#322847
+0 ## Absorb_heat - singe.v - v#582743
+0 ## Absorb_heat - stew.v - v#323856
+0 ## Appointing - accredit.v - v#2475772
+0 ## Appointing - appoint.v - v#2475922
+0 ## Appointing - finger.v - v#924431
+0 ## Appointing - designate.v - v#2391803
+0 ## Appointing - tap.v - v#2185373
+0 ## Appointing - name.v - v#2396716
+0 ## Appointing - accredited.a - a#178811
+0 ## Expansion - contraction.n - n#7313241
+0 ## Expansion - lengthen.v - v#317700
+0 ## Expansion - explosive.a - a#474620
+0 ## Expansion - swell.v - v#256507
+0 ## Expansion - enlarge.v - v#955601
+0 ## Expansion - dilate.v - v#955601
+0 ## Expansion - contract.v - v#240571
+0 ## Expansion - grow.v - v#230746
+0 ## Expansion - inflate.v - v#264034
+0 ## Expansion - enlargement.n - n#365709
+0 ## Expansion - expansion.n - n#365709
+0 ## Expansion - expand.v - v#257269
+0 ## Expansion - shrink.v - v#241038
+0 ## Expansion - stretch.v - v#318816
+0 ## Imprisonment - incarcerate.v - v#2494356
+0 ## Imprisonment - jail.v - v#2494356
+0 ## Imprisonment - put away.v - v#2494356
+0 ## Imprisonment - imprisonment.n - n#13999206
+0 ## Imprisonment - incarceration.n - n#13999206
+0 ## Imprisonment - imprison.v - v#2494356
+0 ## Operate_vehicle - tack.v - v#1946408
+0 ## Operate_vehicle - punt.v - v#1372408
+0 ## Operate_vehicle - paddle.v - v#1947887
+0 ## Operate_vehicle - ride.v - v#1955984
+0 ## Operate_vehicle - raft.v - v#1949966
+0 ## Operate_vehicle - balloon.v - v#1948659
+0 ## Operate_vehicle - sail.v - v#1945516
+0 ## Operate_vehicle - drive.v - v#1930874
+0 ## Operate_vehicle - toboggan.v - v#1940034
+0 ## Operate_vehicle - taxi.v - v#1949007
+0 ## Operate_vehicle - sledge.v - v#1846099
+0 ## Operate_vehicle - motor.v - v#1930117
+0 ## Operate_vehicle - fly.v - v#1941093
+0 ## Operate_vehicle - bicycle.v - v#1935476
+0 ## Operate_vehicle - skate.v - v#1936753
+0 ## Operate_vehicle - canoe.v - v#1947543
+0 ## Operate_vehicle - caravan.v - v#1949333
+0 ## Operate_vehicle - boat.v - v#1944692
+0 ## Operate_vehicle - parachute.v - v#1968275
+0 ## Operate_vehicle - cycle.v - v#1935476
+0 ## Operate_vehicle - cruise.v - v#1844653
+0 ## Operate_vehicle - row.v - v#1946996
+0 ## Operate_vehicle - bike.v - v#1935476
+0 ## Operate_vehicle - pedal.v - v#1935476
+0 ## Cause_to_resume - restart.v - v#1858686
+0 ## Cause_to_resume - revive.v - v#98083
+0 ## Cause_to_resume - reinstate.v - v#2553262
+0 ## Change_posture - bend.v - v#2035919
+0 ## Change_posture - lie down.v - v#1985029
+0 ## Change_posture - rise.v - v#1968569
+0 ## Change_posture - huddle.v - v#2063988
+0 ## Change_posture - slouch.v - v#1989720
+0 ## Change_posture - hunch.v - v#2035559
+0 ## Change_posture - stoop.v - v#2062632
+0 ## Change_posture - stand up.v - v#1546768
+0 ## Change_posture - sit down.v - v#1543123
+0 ## Change_posture - drop.v - v#1977701
+0 ## Change_posture - lie.v - v#2690708
+0 ## Change_posture - sit.v - v#1543123
+0 ## Change_posture - stand.v - v#1546111
+0 ## Change_posture - sprawl.v - v#1543426
+0 ## Change_posture - lean.v - v#2038357
+0 ## Change_posture - crouch.v - v#2062632
+0 ## Change_posture - squat.v - v#1545314
+0 ## Change_posture - kneel.v - v#1545649
+0 ## Change_posture - sit up.v - v#2098680
+0 ## Replacing - switch.v - v#2259005
+0 ## Replacing - replacement.n - n#197772
+0 ## Replacing - exchange.v - v#2257370
+0 ## Replacing - substitute.v - v#2257767
+0 ## Replacing - replace.v - v#2257767
+0 ## Replacing - substitution.n - n#196485
+0 ## Replacing - change.v - v#126264
+0 ## Adorning - film.v - v#1002740
+0 ## Adorning - festoon.v - v#1680267
+0 ## Adorning - encrust.v - v#1517355
+0 ## Adorning - dot.v - v#2689882
+0 ## Adorning - envelop.v - v#1580467
+0 ## Adorning - decorate.v - v#1675963
+0 ## Adorning - deck.v - v#2748927
+0 ## Adorning - garnish.v - v#1679433
+0 ## Adorning - cover.v - v#1332730
+0 ## Adorning - cloak.v - v#1617034
+0 ## Adorning - stud.v - v#2689882
+0 ## Adorning - adorn.v - v#1675963
+0 ## Adorning - blanket.v - v#1359007
+0 ## Adorning - line.v - v#1270784
+0 ## Adorning - pave.v - v#1267098
+0 ## Adorning - fill.v - v#452512
+0 ## Adorning - coat.v - v#1264283
+0 ## Adorning - encircle.v - v#1522716
+0 ## Adorning - wreathe.v - v#1517055
+0 ## Besieging - investment.n - n#1099436
+0 ## Besieging - besiege.v - v#1127411
+0 ## Besieging - siege.n - n#1075117
+0 ## Besieging - invest.v - v#2271137
+0 ## Besieging - beleaguer.v - v#1127411
+0 ## Notification_of_charges - indictment.n - n#7235335
+0 ## Notification_of_charges - indict.v - v#2521284
+0 ## Notification_of_charges - charge.n - n#6561942
+0 ## Notification_of_charges - charge.v - v#843468
+0 ## Notification_of_charges - accuse.v - v#843468
+0 ## Renunciation - renunciation.n - n#205079
+0 ## Renunciation - renounce.v - v#2379198
+0 ## Nuclear_process - thermonuclear.a - a#610734
+0 ## Nuclear_process - fusion.n - n#380568
+0 ## Nuclear_process - fuse.v - v#394813
+0 ## Nuclear_process - fission.n - n#13481408
+0 ## Nuclear_process - decay.v - v#399074
+0 ## Nuclear_process - radioactivity.n - n#13545184
+0 ## Nuclear_process - decay.n - n#13456715
+0 ## Nuclear_process - fissile.a - a#1016874
+0 ## Nuclear_process - radioactive.a - a#426907
+0 ## Nuclear_process - nuclear.a - a#610532
+0 ## Quantity - mite.n - n#13774115
+0 ## Quantity - few.a - a#1552885
+0 ## Quantity - measure.n - n#33615
+0 ## Quantity - number.n - n#5121418
+0 ## Quantity - several.a - a#2268268
+0 ## Quantity - dose.n - n#3225238
+0 ## Quantity - numerous.a - a#1552419
+0 ## Quantity - no.a - a#2268485
+0 ## Quantity - flood.n - n#13775706
+0 ## Quantity - stream.n - n#7406765
+0 ## Quantity - ounce.n - n#13722522
+0 ## Quantity - fair.a - a#956131
+0 ## Quantity - touch.n - n#13774115
+0 ## Quantity - pinch.n - n#13774115
+0 ## Quantity - amount.n - n#5107765
+0 ## Quantity - mountain.n - n#13774404
+0 ## Quantity - few.n - n#8388074
+0 ## Quantity - trickle.n - n#7432559
+0 ## Quantity - raft.n - n#13774404
+0 ## Quantity - many.a - a#1551633
+0 ## Quantity - plethora.n - n#5120116
+0 ## Quantity - deluge.n - n#13775706
+0 ## Quantity - dozens.n - n#13777509
+0 ## Quantity - smattering.n - n#13771154
+0 ## Quantity - quantity.n - n#33615
+0 ## Quantity - both.a - a#2268133
+0 ## Quantity - multiple.a - a#2215977
+0 ## Quantity - modicum.n - n#13761801
+0 ## Quantity - torrent.n - n#13775706
+0 ## Quantity - myriad.n - n#13776726
+0 ## Quantity - billions.n - n#13752172
+0 ## Quantity - wave.n - n#346095
+0 ## Quantity - mass.n - n#13774404
+0 ## Quantity - heap.n - n#13774404
+0 ## Quantity - scores.n - n#13777509
+0 ## Quantity - all.a - a#2269286
+0 ## Quantity - load.n - n#13772468
+0 ## Quantity - any.a - a#2267686
+0 ## Quantity - oodles.n - n#13777509
+0 ## Quantity - avalanche.n - n#7405137
+0 ## Quantity - handful.n - n#13771154
+0 ## Quantity - degree.n - n#5093890
+0 ## Quantity - ton.n - n#13721529
+0 ## Quantity - scads.n - n#13777509
+0 ## Quantity - pile.n - n#13774404
+0 ## Quantity - abundance.n - n#5115040
+0 ## Firing - fire.v - v#2402825
+0 ## Firing - terminate.v - v#2402825
+0 ## Firing - let go.v - v#1474550
+0 ## Firing - lay off.v - v#2403537
+0 ## Firing - dismiss.v - v#2402825
+0 ## Firing - can.v - v#2402825
+0 ## Firing - firing.n - n#216174
+0 ## Firing - dismissal.n - n#216174
+0 ## Firing - termination.n - n#209943
+0 ## Firing - sack.v - v#2402825
+0 ## Firing - downsize.v - v#586682
+0 ## Secrecy_status - unclassified.a - a#416415
+0 ## Secrecy_status - publicly.adv - r#161932
+0 ## Secrecy_status - concealed.a - a#2088404
+0 ## Secrecy_status - confidential.a - a#1859571
+0 ## Secrecy_status - covert.a - a#1705655
+0 ## Secrecy_status - open.a - a#1861910
+0 ## Secrecy_status - secret.a - a#1706465
+0 ## Secrecy_status - shadowy.a - a#276862
+0 ## Secrecy_status - clandestine.a - a#1706465
+0 ## Secrecy_status - secretly.adv - r#166608
+0 ## Secrecy_status - surreptitious.a - a#1706465
+0 ## Secrecy_status - public.a - a#1861205
+0 ## Resolve_problem - fix.v - v#2603299
+0 ## Resolve_problem - address.v - v#1033527
+0 ## Resolve_problem - clear up.v - v#939857
+0 ## Resolve_problem - resolve.v - v#733044
+0 ## Resolve_problem - solve.v - v#634906
+0 ## Resolve_problem - handle.v - v#2436349
+0 ## Resolve_problem - work through.v - v#1161947
+0 ## Resolve_problem - deal.v - v#1033527
+0 ## Dimension - around.adv - r#71165
+0 ## Dimension - heavy.a - a#1184932
+0 ## Dimension - small.a - a#1391351
+0 ## Dimension - long.a - a#1437963
+0 ## Dimension - width.n - n#5136150
+0 ## Dimension - thick.a - a#2410393
+0 ## Dimension - measure.v - v#489837
+0 ## Dimension - narrow.a - a#2561888
+0 ## Dimension - length.n - n#5129201
+0 ## Dimension - wide.a - a#2560548
+0 ## Dimension - light((weight)).a - a#2337329
+0 ## Dimension - short.a - a#1442186
+0 ## Dimension - thin.a - a#2412164
+0 ## Dimension - big.a - a#1382086
+0 ## Dimension - across.adv - r#272951
+0 ## Dimension - work.n - n#4599396
+0 ## Dimension - deep.a - a#2561391
+0 ## Dimension - large.a - a#1382086
+0 ## Dimension - area.n - n#8497294
+0 ## Dimension - massive.a - a#1389170
+0 ## Dimension - grand.a - a#1387149
+0 ## Dimension - broad.a - a#2560548
+0 ## Dimension - tall.a - a#2385102
+0 ## Dimension - light((illumination)).a - a#2337329
+0 ## Dimension - weigh.v - v#2704818
+0 ## Dimension - high.a - a#1210854
+0 ## Dimension - dark.a - a#273082
+0 ## Dimension - height.n - n#5002352
+0 ## Dimension - depth.n - n#5134547
+0 ## Dimension - breadth.n - n#5136150
+0 ## Dimension - weight.n - n#5026843
+0 ## Dimension - circumference.n - n#5101675
+0 ## Removing - wash.v - v#557686
+0 ## Removing - rinse.v - v#1536168
+0 ## Removing - weed.v - v#313171
+0 ## Removing - evacuate.v - v#73343
+0 ## Removing - dust.v - v#1244351
+0 ## Removing - confiscate.v - v#2273293
+0 ## Removing - strip.v - v#1263479
+0 ## Removing - removal.n - n#391599
+0 ## Removing - evacuation.n - n#395797
+0 ## Removing - extract.v - v#1351170
+0 ## Removing - pluck.v - v#1384275
+0 ## Removing - disgorge.v - v#76400
+0 ## Removing - expunge.v - v#1549420
+0 ## Removing - flush.v - v#455529
+0 ## Removing - rip.v - v#1573276
+0 ## Removing - eviction.n - n#1194904
+0 ## Removing - prise.v - v#1593254
+0 ## Removing - eliminate.v - v#72989
+0 ## Removing - elimination.n - n#13473097
+0 ## Removing - empty.v - v#449692
+0 ## Removing - tear.v - v#1384275
+0 ## Removing - purge.v - v#76400
+0 ## Removing - file.v - v#1001857
+0 ## Removing - swipe.v - v#2276866
+0 ## Removing - snatch.v - v#1471043
+0 ## Removing - oust.v - v#2401809
+0 ## Removing - evict.v - v#1468327
+0 ## Removing - expurgate.v - v#201034
+0 ## Removing - withdrawal.n - n#53913
+0 ## Removing - expel.v - v#2401809
+0 ## Removing - eject.v - v#1468576
+0 ## Removing - expulsion.n - n#116687
+0 ## Removing - scrape.v - v#1309143
+0 ## Removing - withdraw.v - v#173338
+0 ## Removing - extraction.n - n#392950
+0 ## Removing - dislodge.v - v#1528522
+0 ## Removing - skim.v - v#1261018
+0 ## Removing - cut.v - v#1552519
+0 ## Removing - shave.v - v#37298
+0 ## Removing - discard.v - v#2222318
+0 ## Removing - excise.v - v#1549420
+0 ## Removing - unload.v - v#1488123
+0 ## Removing - purge.n - n#216834
+0 ## Removing - take.v - v#173338
+0 ## Removing - remove.v - v#173338
+0 ## Removing - clear.v - v#195342
+0 ## Removing - ejection.n - n#116687
+0 ## Removing - drain.v - v#451648
+0 ## Text - eulogy.n - n#6694359
+0 ## Text - meditation.n - n#5785885
+0 ## Text - poetry.n - n#7092592
+0 ## Text - issue.n - n#6596978
+0 ## Text - manuscript.n - n#6407221
+0 ## Text - epistle.n - n#6626183
+0 ## Text - newspaper.n - n#6267145
+0 ## Text - tragedy.n - n#7016948
+0 ## Text - tome.n - n#6413579
+0 ## Text - mag.n - n#6595351
+0 ## Text - bulletin.n - n#6682290
+0 ## Text - script.n - n#7009946
+0 ## Text - handbook.n - n#6421301
+0 ## Text - list.n - n#6481320
+0 ## Text - periodical.n - n#6593296
+0 ## Text - elegy.n - n#6379568
+0 ## Text - memoir.n - n#6516495
+0 ## Text - poem.n - n#6377442
+0 ## Text - letter.n - n#6624161
+0 ## Text - writings.n - n#6453324
+0 ## Text - booklet.n - n#6413889
+0 ## Text - speech.n - n#7238694
+0 ## Text - epigram.n - n#7153727
+0 ## Text - lyric.n - n#6380726
+0 ## Text - history.n - n#6514093
+0 ## Text - report.n - n#6681551
+0 ## Text - paper (article).n - n#6409752
+0 ## Text - fiction.n - n#6757891
+0 ## Text - account.n - n#6514093
+0 ## Text - autobiography.n - n#6516087
+0 ## Text - missive.n - n#6624161
+0 ## Text - benediction.n - n#1043693
+0 ## Text - epic.n - n#6379721
+0 ## Text - saga.n - n#6370522
+0 ## Text - drama.n - n#6376154
+0 ## Text - manual.n - n#6421685
+0 ## Text - limerick.n - n#6380603
+0 ## Text - magazine.n - n#6595351
+0 ## Text - essay.n - n#6409562
+0 ## Text - edition.n - n#6590446
+0 ## Text - novel.n - n#6367879
+0 ## Text - hardback.n - n#3492391
+0 ## Text - literature.n - n#6364641
+0 ## Text - lay.n - n#7049713
+0 ## Text - treatise.n - n#6408651
+0 ## Text - thriller.n - n#6370403
+0 ## Text - brochure.n - n#6413889
+0 ## Text - volume.n - n#2870092
+0 ## Text - chronicle.n - n#6514093
+0 ## Text - haiku.n - n#6380495
+0 ## Text - paper (newspaper).n - n#6267145
+0 ## Text - pamphlet.n - n#6413889
+0 ## Text - song.n - n#7048000
+0 ## Text - imprecation.n - n#7233996
+0 ## Text - mystery.n - n#6370792
+0 ## Text - hagiography.n - n#6516242
+0 ## Text - article.n - n#6268096
+0 ## Text - novella.n - n#6368962
+0 ## Text - obituary.n - n#6748133
+0 ## Text - biography.n - n#6515827
+0 ## Text - ode.n - n#6383659
+0 ## Text - editorial.n - n#6268567
+0 ## Text - trilogy.n - n#7985825
+0 ## Text - epilogue.n - n#6398963
+0 ## Text - sonnet.n - n#6381372
+0 ## Text - journal.n - n#3602562
+0 ## Text - whodunit.n - n#6370792
+0 ## Text - material.n - n#14580897
+0 ## Text - tetralogy.n - n#6622252
+0 ## Text - tract.n - n#6409290
+0 ## Text - fable.n - n#6372095
+0 ## Text - epic.a - a#3015589
+0 ## Text - monograph.n - n#6409448
+0 ## Text - sermon.n - n#7243837
+0 ## Text - ballad.n - n#7049713
+0 ## Text - grimoire.n - n#6422032
+0 ## Text - paperback.n - n#3886432
+0 ## Text - screenplay.n - n#7012279
+0 ## Text - diary.n - n#6402031
+0 ## Text - novelette.n - n#6368962
+0 ## Text - rhyme.n - n#6381869
+0 ## Text - festschrift.n - n#6406865
+0 ## Text - comedy.n - n#7015510
+0 ## Text - book.n - n#6410904
+0 ## Reasoning - prove.v - v#664788
+0 ## Reasoning - polemic.n - n#7183660
+0 ## Reasoning - show.v - v#2148788
+0 ## Reasoning - reason.v - v#772189
+0 ## Reasoning - case.n - n#6649426
+0 ## Reasoning - argue.v - v#772189
+0 ## Reasoning - argument.n - n#6648724
+0 ## Reasoning - demonstrate.v - v#664788
+0 ## Reasoning - demonstration.n - n#6648046
+0 ## Reasoning - disprove.v - v#667424
+0 ## Want_suspect - wanted.a - a#2526925
+0 ## Friction - rasp.v - v#1386906
+0 ## Friction - squeal.v - v#1054694
+0 ## Friction - grate.v - v#1394464
+0 ## Friction - scrape.v - v#1308160
+0 ## Friction - scrunch.v - v#2184797
+0 ## Friction - screech.v - v#2171664
+0 ## Soaking_up - absorb.v - v#1539063
+0 ## Soaking_up - soak up.v - v#1539063
+0 ## Soaking_up - sponge.v - v#1393611
+0 ## Mental_property - cynical.a - a#2463582
+0 ## Mental_property - insightful.a - a#1745296
+0 ## Mental_property - broad-minded.a - a#2155771
+0 ## Mental_property - idiotic.a - a#2570643
+0 ## Mental_property - stupid.a - a#439588
+0 ## Mental_property - sensible.a - a#1943406
+0 ## Mental_property - shrewd.a - a#438909
+0 ## Mental_property - carefully.adv - r#153568
+0 ## Mental_property - ludicrous.a - a#2570643
+0 ## Mental_property - diligent.a - a#1736122
+0 ## Mental_property - astuteness.n - n#5621439
+0 ## Mental_property - foolish.a - a#2570282
+0 ## Mental_property - perceptive.a - a#1744111
+0 ## Mental_property - stupidly.adv - r#175344
+0 ## Mental_property - wit.n - n#5618056
+0 ## Mental_property - wise.a - a#2569130
+0 ## Mental_property - inattentive.a - a#164863
+0 ## Mental_property - crafty.a - a#148078
+0 ## Mental_property - crackers.a - a#2074929
+0 ## Mental_property - narrow-minded.a - a#287640
+0 ## Mental_property - dim.a - a#440579
+0 ## Mental_property - unreasonable.a - a#1944660
+0 ## Mental_property - acquisitive.a - a#29343
+0 ## Mental_property - enlightened.a - a#884007
+0 ## Mental_property - irrational.a - a#1926376
+0 ## Mental_property - brilliance.n - n#4952570
+0 ## Mental_property - dim-witted.a - a#1841390
+0 ## Mental_property - absurdity.n - n#4891683
+0 ## Mental_property - ill-advised.a - a#68278
+0 ## Mental_property - astute.a - a#438909
+0 ## Mental_property - foolishness.n - n#4891333
+0 ## Mental_property - forgetful.a - a#165943
+0 ## Mental_property - smart.a - a#438707
+0 ## Mental_property - intelligent.a - a#1334398
+0 ## Mental_property - suspicious.a - a#2464277
+0 ## Mental_property - foxy.a - a#148078
+0 ## Mental_property - nonsensical.a - a#2570643
+0 ## Mental_property - carelessly.adv - r#164150
+0 ## Mental_property - narrow-mindedly.adv - r#406638
+0 ## Mental_property - careless.a - a#311663
+0 ## Mental_property - discerning.a - a#1745027
+0 ## Mental_property - daft.a - a#2074929
+0 ## Mental_property - carelessness.n - n#4664964
+0 ## Mental_property - cunning.a - a#148078
+0 ## Mental_property - absurd.a - a#2570643
+0 ## Mental_property - discernment.n - n#5805475
+0 ## Mental_property - curious.a - a#664449
+0 ## Mental_property - inane.a - a#2571277
+0 ## Mental_property - reasonable.a - a#1943406
+0 ## Mental_property - sage.a - a#2570183
+0 ## Mental_property - ridiculous.a - a#2570643
+0 ## Mental_property - perceptively.adv - r#419795
+0 ## Mental_property - crazy.a - a#2075321
+0 ## Mental_property - moronic.a - a#1841054
+0 ## Mental_property - enlightenment.n - n#5986395
+0 ## Mental_property - ingenious.a - a#61885
+0 ## Mental_property - brainless.a - a#1336837
+0 ## Mental_property - sagacious.a - a#2569558
+0 ## Mental_property - naive.a - a#2271544
+0 ## Mental_property - brilliant.a - a#1335156
+0 ## Mental_property - canny.a - a#439252
+0 ## Heralding - herald.v - v#974173
+0 ## Commerce_scenario - buyer.n - n#9885145
+0 ## Commerce_scenario - commerce.n - n#1090446
+0 ## Commerce_scenario - purchaser.n - n#9885145
+0 ## Commerce_scenario - retailer.n - n#10525436
+0 ## Commerce_scenario - trafficker.n - n#10577284
+0 ## Commerce_scenario - seller.n - n#10577284
+0 ## Commerce_scenario - vendor.n - n#10577284
+0 ## Commerce_scenario - price.n - n#5145118
+0 ## Contingency - independence.n - n#13994148
+0 ## Contingency - independent.a - a#727564
+0 ## Contingency - determine.v - v#918872
+0 ## Contingency - depend.v - v#2664234
+0 ## Contingency - hinge.v - v#1297174
+0 ## Contingency - turn.v - v#1907258
+0 ## Contingency - dependent.a - a#725772
+0 ## Contingency - function.n - n#13783816
+0 ## Contingency - factor.n - n#7327805
+0 ## Contingency - dependence.n - n#14001348
+0 ## Contingency - variable.n - n#9468959
+0 ## Contingency - hang_((on)).v - v#1481819
+0 ## Committing_crime - commission.n - n#773235
+0 ## Committing_crime - crime.n - n#766234
+0 ## Committing_crime - perpetrate.v - v#2582615
+0 ## Committing_crime - commit.v - v#2582615

