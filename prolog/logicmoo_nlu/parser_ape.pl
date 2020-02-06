% ===================================================================
% File 'parser_ape.pl'
% Purpose: Attempto Controlled English to CycL conversions from SWI-Prolog  
% This implementation is an incomplete proxy for CycNL and likely will not work as well
% Maintainer: Douglas Miles
% Contact: $Author: dmiles $@users.sourceforge.net ;
% Version: 'parser_ape.pl' 1.0.0
% Revision:  $Revision: 1.3 $
% Revised At:   $Date: 2002/06/06 15:43:15 $
% ===================================================================

% :-module(parser_ape,[]).


% ==============================================================================
:- reexport(parser_sharing).
:- shared_parser_data(talkdb:talk_db/3).

:- absolute_file_name(logicmoo_nlu_ext('ape/'),Dir,[file_type(directory)]),
   assertz(user:file_search_path(ape,Dir)).

  

:- reexport(ape(parser/ace_to_drs)).
:- reexport(ape(get_ape_results)).
:- reexport(ape(utils/drs_to_drslist)).
:- reexport(ape(utils/drs_to_sdrs)).
:- reexport(ape('parser/grammar_plp.pl')).
:- reexport(ape('parser/grammar_words'),[reset_progress_record/1]).
:- reexport(ape(parser/ape_utils)).
:- reexport(ape(parser/tokenizer)).
:- reexport(ape(utils/morphgen), [
	acesentencelist_pp/2
	]).
:- reexport(ape(utils/is_wellformed), [
	is_wellformed/1
	]).
:- reexport(ape(utils/drs_to_ascii)).
:- reexport(ape(utils/trees_to_ascii)).
:- reexport(ape(utils/drs_to_ace), [
	drs_to_ace/2
	]).
:- reexport(ape(logger/error_logger), [
	clear_messages/0,
	get_messages/1,
	is_error_message/4
	]).

:- set_prolog_flag(float_format, '%.11g' ).

% Import the lexicons
:- style_check(-(singleton)).
:- style_check(-(discontiguous)).
:- reexport(ape(lexicon/clex)).
:- reexport(ape(lexicon/ulex)).
:- style_check(+discontiguous).
:- style_check(+singleton).

:- reexport(ape('utils/morphgen')).

:- reexport(ape('utils/ace_niceace')).

:- reexport(ape('utils/drs_to_xml')).
:- reexport(ape('utils/drs_to_fol_to_prenex')).
:- reexport(ape('utils/drs_to_ascii')).
:- reexport(ape('utils/drs_to_ace')).
:- reexport(ape('utils/drs_to_coreace')).
:- reexport(ape('utils/drs_to_npace')).
:- reexport(ape('utils/drs_to_html')).
:- reexport(ape('utils/drs_to_ruleml')).
:- reexport(ape('utils/tree_utils')).
:- reexport(ape('utils/trees_to_ascii')).
:- reexport(ape('utils/drs_to_tptp')).
:- reexport(ape('lexicon/clex')).
:- reexport(ape('lexicon/ulex')).
:- reexport(ape('parser/ace_to_drs')).
:- reexport(ape('logger/error_logger')).

:- reexport(ape('utils/xmlterm_to_xmlatom')).

:- reexport(ape('utils/serialize_term')).

%:- reexport(ape('utils/owlswrl/get_owl_output')).
