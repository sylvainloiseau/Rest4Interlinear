(:-
 : Rest4IGT
 :
 : Public domain
 : Sylvain Loiseau
 : <sylvain.loiseau@univ-paris13.fr>
 :)
xquery version "3.0";
module namespace concordance = 'http://basex.org/modules/concordance';

import module namespace variable = "configuration" at "variable.xqm";
import module namespace page = "http://basex.org/modules/web-page" at "site.xqm";
import module namespace interlinear = "http://basex.org/modules/interlinear" at "Interlinear.xqm";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Get a value according to a morph node
 : @return string
 :)
declare function concordance:get-group($group_by_morph_offset as xs:integer, $field as xs:string, $morph as element(morph)) as xs:string {
	let $right_morphs := $morph/following-sibling::morph
	let $left_morphs := $morph/preceding-sibling::morph
	return if ($group_by_morph_offset > count($right_morphs) or $group_by_morph_offset < count($left_morphs))
	       then "#"
	       else if ($group_by_morph_offset = 0)
		        then "(no grouping asked)"
		        else if ($group_by_morph_offset < 0)
			         then string($left_morphs[abs($group_by_morph_offset)]/item[@type=$field])
			         else string($right_morphs[$group_by_morph_offset]/item[@type=$field])
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Display a concordance
 : @return HTML table
 :)
declare
  %rest:path("/GroupConcordance")
  %output:method("xml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function concordance:group-concordance() as element(Q{http://www.w3.org/1999/xhtml}html) {
	<html:html xmlns:html="http://www.w3.org/1999/xhtml">
		<html:head>
		<html:link rel="stylesheet" type="text/css" href="{$variable:cssdir}/style.css"/>
		<html:title>Concordance:</html:title>
		    <html:script type="text/javascript" src="{$variable:jquery}" />
		    <html:script type="text/javascript" language="javascript" src="{$variable:jsdir}/ConcordanceGroup.js" />
		</html:head>
		<html:div id="toc">
            <html:h3>Table of Contents</html:h3>
        </html:div>
		<html:hr />
		{
		let $morphs := collection($variable:TextsDataBaseName)/document/interlinear-text/paragraphs/paragraph/phrases/word/words/word/morphemes/morph
		    [
				item[@type="cf"] = "-ne"
				and
                (not(item[@type="hn"]) or item[@type="hn"] = "1")
			]
		for $morph in $morphs
		(:
		let $morphs4group := fold-left($morphs, map {}, function($acc, $morph as element(morph)) {
			let $k := concordance:get-group(1, "cf", $morph) 
			return if (map:contains($acc, $k))
				   then map:put($acc, $k, array:append(map:get($acc, $k), $morph))
			       else map:put($acc, $k, [ $morph ])
        })
		let $groupsize := map:merge(
			for $k in map:keys($morphs4group)
			return map:entry($k, count(map:get($morphs4group, $k)))
		)
		:)
		group by $key := concordance:get-group(1, "cf", $morph) 
		let $count := count($morph)
        order by $count descending 
		return
			(:
			<html:ul> {
              for $key in map:keys($morphs4group)
			  let $count := map:get($groupsize, $key) 
      		  order by $count descending 
      		  return
      		    <li><a href="#{$key}">{$key} ({$count} occurrences)</a></li>
            } </html:ul>
		    ,
            <html:div> {
              for $key in map:keys($morphs4group)
			  let $count := map:get($groupsize, $key) 
      		  order by $count descending
        		return
			  :)
                  <html:div>
       			    <html:h3><html:a class="toc" />Group: {$key} ({$count} occurrences)</html:h3> {
      			      (:concordance:concordance-for-morphs(map:get($morphs4group, $key), 10, 10):)
      			      concordance:concordance-for-morphs($morph, 10, 10)
      		        } </html:div>
            (:} </html:div>:)
	}
	</html:html>
};

declare
 function concordance:concordance-for-morphs(
	$all_morphs as element(morph)*,
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
	</html:thead> {
                for $morphs in $all_morphs
	        	    let $parent_word := $morphs/parent::morphemes/parent::word
	        	    let $parent_phrase := $parent_word/parent::words/parent::word
	        	    let $phrase_reference := $parent_phrase/item[@type="segnum"]
	        	    let $free_translations := $parent_phrase/item[@type="gls"][text()]
	        	    let $notes := $parent_phrase/item[@type="note"][text()]
	        	    let $text := $parent_phrase/parent::phrases/parent::paragraph/parent::paragraphs/parent::interlinear-text
	        	    let $text_id := data($text/item[@type='title-abbreviation'])
	        	    let $text_title := data($text/item[@type="title"])
	        	    let $left_context := $parent_word/preceding-sibling::word
	        	    let $right_context := $parent_word/following-sibling::word
	        	    let $left_size := count($left_context)
	        	    let $right_size := count($right_context)
	            	return
	            	(
	            	<html:tr class="conc_line">
	            	    <html:td class="conc_ref">
	            		  <html:strong><html:a href="../ViewText/{$text_id}#{$phrase_reference}">{$text_id} § {$phrase_reference}</html:a></html:strong>
						  <html:br/>
						  ({$text_title})
	            		</html:td>
						<html:table class="conc_line_content">
						<html:tr>
                        <html:td class="conc_left"> {
								if ($left_context_size = -1)
								then interlinear:view-words(
                                  <words>
								  {$left_context}
                                  </words>
								) else
	            				interlinear:view-words(
									<words> {
	            			          for $index in (1 to $left_context_size)
	            			          let $revindex := $left_context_size + 1 - $index
	            		              where ($revindex <= $left_size)
	            			          return $left_context[$left_size + 1 - $revindex]
									} </words>
								)
	            		} </html:td>
                        <html:td class="conc_keyword"> {
	            		    interlinear:view-words(<words>{$parent_word}</words>)
	            	 	} </html:td>
                        <html:td class="conc_right"> {
								if ($right_context_size = -1)
								then interlinear:view-words(
                                  <words>
								  {$right_context}
                                  </words>
								) else
								interlinear:view-words(
									<words> {
	            		            for $i in (1 to $right_context_size)
             						where ($i <= count($right_size))
									return $right_context[$i]
									} </words>
								)
	            	    } </html:td>
						</html:tr>
						</html:table>
	            	</html:tr>
	            	,
	            	<html:tr>
                      <html:td>&#160;</html:td>
	            	<html:td>
	            	<html:table class="free_translations"> {
		            	for $free_translation in $free_translations
		            	return
		            	<html:tr class="free_translation">
		            	<html:td class="{$free_translation/@lang}">&#160;</html:td>
		            	<html:td class="{$free_translation/@lang}">{$free_translation/text()}</html:td>
		            	<html:td class="{$free_translation/@lang}">&#160;</html:td>
		            	</html:tr>
		            } </html:table>
		            </html:td>
		            </html:tr>
		            ,
		            <html:tr>
		            <html:td>&#160;</html:td>
		            <html:td>
		            <html:table class="notes"> {
		            	for $note in $notes
		            	return
		            	<html:tr class="note">
		            	<html:td >&#160;</html:td>
		            	<html:td >{$note/text()}</html:td>
		            	<html:td >&#160;</html:td>
		            	</html:tr>
	            	} </html:table>
	            	</html:td>
	            	</html:tr>
	            	)
	}
	</html:table>
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Display a concordance
 : @return HTML table
 :)
declare
  function concordance:view-concordance(
  	    $lexem as xs:string,
		$homonym_index as xs:string,
		$left_context_size as xs:integer,
		$right_context_size as xs:integer
  ) as element(Q{http://www.w3.org/1999/xhtml}table) {
	let $morphs := collection($variable:TextsDataBaseName)/document/interlinear-text/paragraphs/paragraph/phrases/word/words/word/morphemes/morph[
				item[@type="cf"] = $lexem and (not(item[@type="hn"]) or item[@type="hn"] = $homonym_index )
	]
	return concordance:concordance-for-morphs($morphs, $left_context_size, $right_context_size)
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Display a concordance
 : @return HTML table
 :)
declare
  function concordance:view-concordance-sentences(
  	    $lexem as xs:string,
		$homonym_index as xs:string
  ) as element(Q{http://www.w3.org/1999/xhtml}table) {
	let $morphs := collection($variable:TextsDataBaseName)/document/interlinear-text/paragraphs/paragraph/phrases/word/words/word/morphemes/morph[
				item[@type="cf"] = $lexem and (not(item[@type="hn"]) or item[@type="hn"] = $homonym_index )
	]
	return concordance:concordance-for-morphs($morphs, -1, -1)
};
