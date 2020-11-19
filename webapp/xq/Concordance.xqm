module namespace concordance = 'http://basex.org/modules/concordance';

import module namespace variable = "configuration" at "variable.xqm";
import module namespace page = "http://basex.org/modules/web-page" at "site.xqm";
import module namespace interlinear = "http://basex.org/modules/interlinear" at "Interlinear.xqm";

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Display a concordance
 : @return HTML page
 :)
declare
  function concordance:view-concordance(
  	    $lexem as xs:string,
		 $order as xs:string,
		 $left_context_size as xs:integer,
		 $right_context_size as xs:integer
  )
  as element(Q{http://www.w3.org/1999/xhtml}table)
{

	<html:table xmlns:html="http://www.w3.org/1999/xhtml" class="concordance">
	<html:col style="width:25%" />
	<html:col style="width:75%" />
   <html:thead class="concordance_head">
		<html:td class="concordance_head"><html:strong>Reference</html:strong></html:td>
		<html:td class="concordance_head"><html:strong>Line</html:strong></html:td>
<!--	<html:td class="concordance_head"><html:strong>Left context</html:strong></html:td>
		<html:td class="concordance_head"><html:strong>Keyword &amp; right context</html:strong></html:td>
-->
	</html:thead>
	{
		for $parent_word in collection($variable:tuwariTexts)/document/interlinear-text/paragraphs/paragraph/phrases/word/words/word[morphemes/morph[item[@type="cf"] = $lexem]]
		where ($parent_word/morphemes/morph[item[@type="cf"] = $lexem and not(item[@type="hn"])] or $parent_word/morphemes/morph[item[@type="cf"] = $lexem and item[@type="hn"] = $order])
		let $parent_phrase := $parent_word/parent::words/parent::word
		let $phrase_reference := $parent_phrase/item[@type="segnum"]
		let $free_translations := $parent_phrase/item[@type="gls"][text()]
		let $notes := $parent_phrase/item[@type="note"][text()]
		let $text := $parent_phrase/parent::phrases/parent::paragraph/parent::paragraphs/parent::interlinear-text
		let $text_id := data($text/item[@type='title-abbreviation'])
		let $text_title := $text/item[@type="title"]
		
		let $left_context := $parent_word/preceding-sibling::word
		let $right_context := $parent_word/following-sibling::word
		let $left_size := count($left_context)
		let $right_size := count($right_context)
		return
		(
		<html:tr class="concordance_line" border="1">
		    <html:td class="concordance_reference">
			  <html:strong><html:a href="../ViewText/{$text_id}#{$phrase_reference}">{$text_id} § {$phrase_reference}</html:a></html:strong>
			</html:td>
            <html:td class="concordance_all_context">
			  <html:table>
			  <html:tr>
				{
				for $index in (1 to $left_context_size)
				let $revindex := $left_context_size + 1 - $index
				return
				<html:td>
				{
					if ($revindex > $left_size) then "&#160;"
					else interlinear:view-words(<words>{$left_context[$left_size + 1 - $revindex]}</words>)
				}
				</html:td>
				}
			    <html:td class="concordance_node">
			    {
			    interlinear:view-words(<words>{$parent_word}</words>)
		 	    }
			    </html:td>
				{
			    for $i in (1 to $right_context_size)
			    return
			    <html:td>
			    {
 				if ($i > count($right_size)) then "&#160;"
				else interlinear:view-words(<words>{$right_context[$i]}</words>)
				
			    }
			    </html:td>
		        }			
		      </html:tr>
		      </html:table>
			</html:td>
		</html:tr>
		,
		<html:tr>
          <html:td>&#160;</html:td>
		<html:td>
		<html:table class="free_translations">
		{
		for $free_translation in $free_translations
		return
		<html:tr class="free_translation">
		<html:td class="{$free_translation/@lang}">&#160;</html:td>
		<html:td class="{$free_translation/@lang}">{$free_translation/text()}</html:td>
		<html:td class="{$free_translation/@lang}">&#160;</html:td>
		</html:tr>
		}
		</html:table>
		</html:td>
		</html:tr>
		,
		<html:tr>
		<html:td>&#160;</html:td>
		<html:td>
		<html:table class="notes">
		{
		for $note in $notes
		return
		<html:tr class="note">
		<html:td >&#160;</html:td>
		<html:td >{$note/text()}</html:td>
		<html:td >&#160;</html:td>
		</html:tr>
		}
		</html:table>
		</html:td>
		</html:tr>
		)
	}
	</html:table>
};
