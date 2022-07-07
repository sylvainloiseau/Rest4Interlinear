
module namespace lexicon = 'http://basex.org/modules/lexicon';

import module namespace variable = "configuration" at "variable.xqm";
import module namespace page = "http://basex.org/modules/web-page" at "site.xqm";
import module namespace concordance = "http://basex.org/modules/concordance" at "Concordance.xqm";
import module namespace interlinear = "http://basex.org/modules/interlinear" at "Interlinear.xqm";

declare variable $lexicon:lexiconId2FormOrder := map:merge(
	for $entry in collection($variable:tuwariLexicon)/lift/entry
	return map:entry(
		data($entry/@id),
		[$entry/lexical-unit/form/text, data($entry/@order)]
		)
	);

declare variable $lexicon:lexiconFormOrder2id := map:merge(
	for $entry in collection($variable:tuwariLexicon)/lift/entry
	let $order := if (data($entry/@order)) then data($entry/@order) else "0"
	return
	map:entry(
		concat($entry/lexical-unit/form/text, $order),
		data($entry/@id)
		)
	);

	(:TODO : pas très élégant pour gérer la présence ou l'absence de @order :)
(:
declare variable $page:entry2frequency := map:merge(
	for $entry in collection($variable:tuwariLexicon)/lift/entry
	let $form := $entry/lexical-unit/form/text/text()
	let $order := if (data($entry/@order)) then data($entry/@order) else "0"
 	return map:entry (
		concat($form, $order),
		if (data($entry/@order)) then
		count(collection($variable:tuwariTexts)//morph[
			item[@type="cf"] = $form and item[@type="hn"] = $order
		])
		else count(collection($variable:tuwariTexts)//morph[
			item[@type="cf"] = $form
		])
	)
);
:)

(:============================================================================:)
(: Lexicon type :)
(:============================================================================:)

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : A lexicon type
 : @param entryid : the FLEX internal id for the word
 : @return HTML page
 :)
declare
  %rest:path("/ViewLexiconEntryDetail/{$entryid}")
  %rest:GET
  %output:method("xml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function lexicon:view-lexicon-entry-detail(
    $entryid as xs:string)
    as element(Q{http://www.w3.org/1999/xhtml}html)
	 {
		<html:html xmlns:html="http://www.w3.org/1999/xhtml">
		<html:head>
		<html:link rel="stylesheet" type="text/css" href="{$variable:cssdir}/style.css"/>
		<html:title>Lexicon entry: {collection($variable:tuwariLexicon)/lift/entry[@id = $entryid]/lexical-unit/form/text/text()}</html:title>
		</html:head>
		{
			let $entry := collection($variable:tuwariLexicon)/lift/entry[@id = $entryid]
			let $form := $entry/lexical-unit/form/text/text()
			let $order := if ($entry/@order) then data($entry/@order) else "0"
			let $mt := data($entry/trait[@name="morph-type"]/@value)
			return
			<html:body>
			{
				page:make-header()
			}
				<html:h2>
				{
					page:display-form($form, $order)
				}
				({$mt})</html:h2>

				<html:h3>Senses</html:h3>

				<html:div>
				<html:ol>
				{
					for $sense in $entry/sense
					return
					<html:li>
					{
						for $gloss in $sense/gloss
						return <html:p>{data($gloss/@lang)}: '{$gloss/text}'</html:p>
					}
					<html:p>({data($sense/grammatical-info/@value)})</html:p>
					<html:p>{data($sense/trait/@value)}</html:p>
					</html:li>
				}
				</html:ol>
				</html:div>
				
				<html:h3>Allomorphs</html:h3>
				
				<html:ul>
				{
					for $variant in $entry/variant
					return <li>{$variant/form/text} ({data($variant/trait/@value)})</li>
				}
				</html:ul>

				<html:h3>Frequency</html:h3>

				{
				(:map:get($page:entry2frequency, concat($entry/lexical-unit/form/text, data($entry/@order))):)

				if (data($entry/@order)) then
				count(collection($variable:tuwariTexts)//morph[item[@type=cf] = $form and item[@type="hn"] = $order ])
				else count(collection($variable:tuwariTexts)//morph[item[@type="cf"] = $form ])				

				}

				<html:h3>Lexical relation</html:h3>
				
				<p>
				TODO
				</p>

				<!--				{map:get($page:entry2frequency, [$entry/lexical-unit/form/text, data($entry/@order)])}-->

				<html:h3>Concordance</html:h3>
				<html:p>
				  	<html:a href="/concordance2pdf/{$entryid}">PDF</html:a>
				  	<html:a href="/concordance2tex/{$entryid}">Tex</html:a>
				</html:p>
				{
					concordance:view-concordance($form, $order, 5, 5)
				}

			</html:body>
		}
		</html:html>
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : List of the lexical types
 : @return HTML page
 :)
declare
  %rest:path("ViewLexiconTable")
  %output:method("html")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function lexicon:view-lexicon-table()
  as element(html)
{
  <html>

	<head>
	<title>Lexicon</title>

	<script type="text/javascript" src="{$variable:jquery}"/>
    <script type="text/javascript" src="{$variable:datatable}" />
    <script type="text/javascript" src="{$variable:yadcf}" />
	<link rel="stylesheet" type="text/css" href="{$variable:jquerycss}" />
    <script type="text/javascript" language="javascript" src="{$variable:jsdir}/LexiconList.js" />
	<html:link rel="stylesheet" type="text/css" href="{$variable:cssdir}/style.css"/>

<style>
	.label &#123;
		padding: 0px 10px 0px 10px;
		border: 1px solid #ccc;
		-moz-border-radius: 1em; /* for mozilla-based browsers */
		-webkit-border-radius: 1em; /* for webkit-based browsers */
		border-radius: 1em; /* theoretically for *all* browsers*/
	&#125;

	.label.lightblue &#123;
		background-color: #99CCFF;
	&#125;	
</style>

</head>

	 <body>

	 	<div xmlns:html="http://www.w3.org/1999/xhtml">
	 	<a href="http://localhost:8984/Tuwari">Home</a>
	 	<hr />
	 	</div>	 

	<h3>Tuwari lexicon</h3>

	<p>
		{
			count(collection($variable:tuwariLexicon)/lift/entry)
		}
		entries found
	</p>

	<div>
	 <table id="table" class="display">
	   <thead border="1">
			<tr>
				<th>Form</th>
				<th>Morph type</th>
				<th>gloss en.</th>
				<th>gloss tpi.</th>
				<th>POS (Sense 1)</th>
				<th>Semantic category</th>
				<!--
				<th># senses</th>
				<th># allomorphes</th>
				<th>Frequency</th>-->
			</tr>
		</thead>
	   <tfoot border="1">
			<tr>
				<th>Form</th>
				<th>Morph type</th>
				<th>gloss en.</th>
				<th>gloss tpi.</th>
				<th>POS (Sense 1)</th>
				<th>Semantic category</th>
				<!--<th># senses</th>
				<th># allomorphes</th>
				<th>Frequency</th>-->
			</tr>
		</tfoot>
		<tbody>
		{
		for $entry in collection($variable:tuwariLexicon)/lift/entry
			let $form := $entry/lexical-unit/form/text
			let $order := if (data($entry/@order)) then data($entry/@order) else "0"
			let $morphtype := data($entry/trait/@value)
			let $sensen := $entry/sense/gloss[@lang="en"]/text
			let $senstpi := $entry/sense/gloss[@lang="tpi"]/text
			let $pos := data($entry/sense[1]/grammatical-info/@value)
			let $semcats := $entry/sense[1]/trait[@name="semantic-domain-ddp4"]
			let $numsens := count($entry/sense)
			let $numvariant := count($entry/variant)
			(:where map:get($page:entry2frequency, concat($form, $order)) > 0:)
			order by $form, $order
		return
		<tr>
			<td><a href="ViewLexiconEntryDetail/{data($entry/@id)}"><strong>{$form}{if ($order != "0") then <sub>{$order}</sub> else ()}</strong></a></td>
			<td>{$morphtype}</td>
			<td>{concat("'", string-join($sensen, "', '"), "'")}</td>
			<td>{concat("'", string-join($senstpi, "', '"), "'")}</td>
			<td>{$pos}</td>
			<td>{for $semcat in $semcats return <span class="label lightblue">{data($semcat/@value)}</span>}</td>
		</tr>
		}
		</tbody>
	 </table>
	 </div>
    </body>
  </html>
};
