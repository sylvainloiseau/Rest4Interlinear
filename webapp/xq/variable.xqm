module namespace common = 'configuration';

(:
declare variable $common:tuwariLexicon := 'lift20200114';
declare variable $common:tuwariTexts := 'TuwariInterlinear20200114';

declare variable $common:tuwariLexicon := 'Tuwari20200114Lexicon';
declare variable $common:tuwariTexts := 'Tuwari20200114Interlinear';
:)

declare variable $common:tuwariLexicon := 'TuwariLexicon20220613';
declare variable $common:tuwariTexts := 'TuwariInterlinear20220613';


declare variable $common:jquery := 'https://code.jquery.com/jquery-1.12.4.min.js';
declare variable $common:datatable := 'https://cdn.datatables.net/1.10.22/js/jquery.dataTables.js';
declare variable $common:yadcf := 'https://cdnjs.cloudflare.com/ajax/libs/yadcf/0.9.4/jquery.dataTables.yadcf.min.js';
declare variable $common:jsdir := '../static/js';
declare variable $common:cssdir := '../static/css';

declare variable $common:jquerycss := 'https://cdn.datatables.net/1.10.22/css/jquery.dataTables.css';

declare variable $common:text_properties := distinct-values(collection($common:tuwariTexts)/document/interlinear-text/item/@type);
declare variable $common:paragraph_properties := distinct-values(collection($common:tuwariTexts)/document/interlinear-text/paragraphs/paragraph/item/@type);
declare variable $common:sentence_properties := distinct-values(collection($common:tuwariTexts)/document/interlinear-text/paragraphs/paragraph/phrases/phrase/item/@type);
declare variable $common:word_properties := distinct-values(collection($common:tuwariTexts)/document/interlinear-text/paragraphs/paragraph/phrases/phrase/words/word/item/@type);
declare variable $common:morph_properties := distinct-values(collection($common:tuwariTexts)/document/interlinear-text/paragraphs/paragraph/phrases/phrase/words/word/morphemes/morph/item/@type);

(:
map:merge(
	for $entry in collection($variable:tuwariTexts)/document/interlinear-text
 	return map:entry (
		data($entry/@guid),
		count($entry//morph)
	)
);
:)
