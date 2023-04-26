(:-
 : Rest4IGT
 :
 : Public domain
 : Sylvain Loiseau
 : <sylvain.loiseau@univ-paris13.fr>
 :)

module namespace common = 'configuration';

(: Declare here the name of the two databases in your BaseX installation 

- LexiconDataBaseName should be a dictionary encoded with the LIFT XML vocabulary
- TextsDataBaseName should be a dictionary encoded with the Emeld XML vocabulary

:)
declare variable $common:LexiconDataBaseName := 'TuwariLexicon20220613';
declare variable $common:TextsDataBaseName := 'TuwariInterlinear20220613';
declare variable $common:title := 'Corpus and lexicon';





declare variable $common:jquery := 'https://code.jquery.com/jquery-3.6.1.min.js';

declare variable $common:datatable := 'https://cdn.datatables.net/1.10.22/js/jquery.dataTables.js';
declare variable $common:yadcf := 'https://cdnjs.cloudflare.com/ajax/libs/yadcf/0.9.4/jquery.dataTables.yadcf.min.js';
declare variable $common:jsdir := '../static/js';
declare variable $common:cssdir := '../static/css';

declare variable $common:jquerycss := 'https://cdn.datatables.net/1.10.22/css/jquery.dataTables.css';

declare variable $common:text_properties := distinct-values(collection($common:TextsDataBaseName)/document/interlinear-text/item/@type);
declare variable $common:paragraph_properties := distinct-values(collection($common:TextsDataBaseName)/document/interlinear-text/paragraphs/paragraph/item/@type);
declare variable $common:sentence_properties := distinct-values(collection($common:TextsDataBaseName)/document/interlinear-text/paragraphs/paragraph/phrases/phrase/item/@type);
declare variable $common:word_properties := distinct-values(collection($common:TextsDataBaseName)/document/interlinear-text/paragraphs/paragraph/phrases/phrase/words/word/item/@type);
declare variable $common:morph_properties := distinct-values(collection($common:TextsDataBaseName)/document/interlinear-text/paragraphs/paragraph/phrases/phrase/words/word/morphemes/morph/item/@type);

(:
map:merge(
	for $entry in collection($variable:TextsDataBaseName)/document/interlinear-text
 	return map:entry (
		data($entry/@guid),
		count($entry//morph)
	)
);
:)
