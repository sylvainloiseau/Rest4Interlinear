module namespace interlinear = 'http://basex.org/modules/interlinear';

import module namespace variable = "configuration" at "variable.xqm";
import module namespace page = "http://basex.org/modules/web-page" at "site.xqm";

(:============================================================================:)
(: Interlinear :)
(:============================================================================:)

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : view-paragraphs -- draw a cell for each paragraphs of a text
 :
 : @param the paragraphs element (containing the paragraph elements)
 :
 : @return Q{http://www.w3.org/1999/xhtml}table
 :)
declare function interlinear:view-paragraphs
($paragraphs as element(paragraphs))
as element(Q{http://www.w3.org/1999/xhtml}div)
{
	<html:div xmlns:html="http://www.w3.org/1999/xhtml" class="paragraphs">
	{
		for $paragraph in $paragraphs/paragraph
		return
		<html:div class="paragraph">
		{
		    if ($paragraph/phrases)
			then interlinear:view-phrases($paragraph/phrases)
			else ()
		}
		</html:div>
	}
	</html:div>
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : view-phrases -- draw a cell for each sentence of a paragraph
 :
 : @param the phrases element (containing the phrase elements)
 : @return Q{http://www.w3.org/1999/xhtml}table
 :)
declare function interlinear:view-phrases
($phrases as element(phrases))
as element(Q{http://www.w3.org/1999/xhtml}div)
{
	<html:div xmlns:html="http://www.w3.org/1999/xhtml" class="phrases">
	{
		for $phrase in $phrases/word
		return
	<html:div class="phrase">
	<html:hr />

	<html:a name="{$phrase/item[@type='segnum']}" />
	
	<html:h3>
	{
		$phrase/item[@type='segnum']
	}
	</html:h3>

	<html:form method="post" action="EditSentence">
	<html:input type="hidden" name="sentenceId" value="{data($phrase/@guid)}" />
	<html:input type="submit" value="Éditer"/>
	</html:form>

	<html:a href="/sentence2tex/{$phrase/../../../../item[@type='title-abbreviation']}/{$phrase/item[@type = 'segnum']}">tex</html:a>
	<html:a href="/sentence2plaintext/{$phrase/../../../../item[@type='title-abbreviation']}/{$phrase/item[@type = 'segnum']}">plain text</html:a>
	<html:table >
		<!--{
		interlinear:view-sentence-text($phrase)
		}-->
		<html:tr>
		<html:td>
			{
				interlinear:view-words($phrase/words)
			}
		</html:td>
		</html:tr>
		{
			for $gloss in $phrase/item[@type='gls']
			where $gloss/text()
			return
				<html:tr>
				<html:td>
				{ data($gloss/@lang) }
				:
				{ $gloss/text() }
				</html:td>
				</html:tr>
		}
	</html:table>
	</html:div>
	}
	</html:div>
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : view-words -- call each morphems
 :
 : @param the words element (containing the word elements)
 :
 : @return Q{http://www.w3.org/1999/xhtml}table
 :)
declare function interlinear:view-words
($words as element(words))
as element(Q{http://www.w3.org/1999/xhtml}table)
{
	<html:table class="words" xmlns:html="http://www.w3.org/1999/xhtml">	
	<html:tr>
	{
		for $word in $words/word
		let $form := $word/item[@type='txt' and @lang='tww']/text()
		let $form_checked :=	if (empty($form)) then "&#160;" else $form
		let $gloss := $word/item[@type='gls' and @lang='en']/text()
		let $gloss_checked := if (empty($gloss)) then "&#160;" else $gloss
		let $pos := $word/item[@type='pos' and @lang='en']/text()
		let $pos_checked := if (empty($pos)) then "&#160;" else $pos
		return
		<html:td class="word">
		{
			if ($word/morphemes) then interlinear:view-morphemes($word/morphemes, fn:false())
			else if ($word[item[@type="punct"]]) then $word/item[@type="punct"]/text()
			else "unknown situation"
		}
		</html:td>
	}
    </html:tr>
    </html:table>
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : view-morphemes -- draw a cell for each morphems of a word
 :
 : @param a table element
 : @return Q{http://www.w3.org/1999/xhtml}tr
 :)
declare function interlinear:view-morphemes($morphemes as element(morphemes), $edit as xs:boolean)
as element(Q{http://www.w3.org/1999/xhtml}table)
{
	<html:table border="1" xmlns:html="http://www.w3.org/1999/xhtml" class="morphemes">
	<html:tr>
	<html:td class="morph_txt">
	{
		let $forms := $morphemes/morph/item[@type='txt' and @lang='tww']/text()
		return string-join($forms, "")
	}
	</html:td>
	</html:tr>
	<html:tr>
	<html:td class="morph_citation">
	{
		for $morph in $morphemes/morph
		let $form := $morph/item[@type='txt' and @lang='tww']/text()
		(:TODO : la forme canonique ici doit être mise:)
		let $cf := $morph/item[@type='cf' and @lang='tww']/text() 
		let $cf_or_form := if ($cf) then $cf else $form
		let $order := if ($morph/item[@type="hn"]/text()) then $morph/item[@type="hn"]/text() else "0"
		return page:display-form($cf_or_form, $order)
	}
	</html:td>
	</html:tr>
	<html:tr>
	<html:td class="morph_gloss">
	{
		let $glosses := $morphemes/morph/item[@type='gls' and @lang='en']/text()
		for $gloss in $glosses
		return (
		   if (matches($gloss, '^[-A-Z0-9_\.\?]+$')) then <span class="gram">{lower-case(data($gloss))}</span> else <span class="lex">{$gloss}</span>
		)
		(:return string-join($glosses, "&#160;"):)
	}

	</html:td>
	</html:tr>

<!--		<html:td style="vertical-align:top">
		<html:table class="morph">
			<html:tr><html:td>{page:display-form($form, $order)}</html:td></html:tr>
			<html:tr><html:td>{$morph/item[@type='gls' and @lang='en']/text()}</html:td></html:tr>
			<html:tr><html:td><html:b>{$morph/item[@type='msa' and @lang='en']/text()}</html:b></html:td></html:tr>
		</html:table>
		</html:td>
-->

	</html:table>
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : view-morphemes-as-table -- draw a cell for each morphem of a word
 :
 : @param a table element
 : @return Q{http://www.w3.org/1999/xhtml}tr
 :)
declare function interlinear:view-morphemes-as-table
($morphemes as element(morphemes), $edit as xs:boolean)
as element(Q{http://www.w3.org/1999/xhtml}table)
{
	<html:table xmlns:html="http://www.w3.org/1999/xhtml" class="morphemes">
	<html:tr>
	{
		for $morph in $morphemes/morph
		let $form := $morph/item[@type='txt' and @lang='tww']/text() 
		let $order := if ($morph/item[@type="hn"]/text()) then $morph/item[@type="hn"]/text() else "0"
		return
		<html:td style="vertical-align:top">
		<html:table class="morph">
			<html:tr><html:td>{page:display-form($form, $order)}</html:td></html:tr>
			<html:tr><html:td>{$morph/item[@type='gls' and @lang='en']/text()}</html:td></html:tr>
			<html:tr><html:td><html:b>{$morph/item[@type='msa' and @lang='en']/text()}</html:b></html:td></html:tr>
		</html:table>
		</html:td>
	}
	</html:tr>
	</html:table>
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Display the text of a sentence as a string (containing the words concatenated)
 :
 : @param a phrase element
 : @return Q{http://www.w3.org/1999/xhtml}tr
 :)
declare function interlinear:view-sentence-text
($phrase as element(word))
as element(Q{http://www.w3.org/1999/xhtml}tr)
{
<html:tr xmlns:html="http://www.w3.org/1999/xhtml" class="sentence-text">
<html:td>
<html:i>
{
	for $word in $phrase/words/word
	return ($word/item[@type='txt' and @lang='tww']/text(), " ")
}
</html:i>
</html:td>
</html:tr>
};