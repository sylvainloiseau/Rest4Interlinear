
(: TODO 
- map for pos abreviation
- complex form
- lexical relation
- allomorph and variant
- slot
:)

(:-
 :
 : This XQuery module display XML interlinear glossed texts in EMELD XML 
 : format and associated dictionary in LIFT XML format.
 :
 : Public domain
 : Sylvain Loiseau
 : <sylvain.loiseau@univ-paris13.fr>
 :
 :)

module namespace page = 'http://basex.org/modules/web-page';

import module namespace common = "configuration" at "variable.xqm";

(:
declare variable $common:tuwariLexicon := 'Tuwari20200114Lexicon';
declare variable $common:tuwariTexts := 'Tuwari20200114Interlinear';
:)

declare variable $page:lexiconId2FormOrder := map:merge(
	for $entry in collection($common:tuwariLexicon)/lift/entry
	return map:entry(
		data($entry/@id),
		[$entry/lexical-unit/form/text, data($entry/@order)]
		)
	);

declare variable $page:lexiconFormOrder2id := map:merge(
	for $entry in collection($common:tuwariLexicon)/lift/entry
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
	for $entry in collection($common:tuwariLexicon)/lift/entry
	let $form := $entry/lexical-unit/form/text/text()
	let $order := if (data($entry/@order)) then data($entry/@order) else "0"
 	return map:entry (
		concat($form, $order),
		if (data($entry/@order)) then
		count(collection($common:tuwariTexts)//morph[
			item[@type="cf"] = $form and item[@type="hn"] = $order
		])
		else count(collection($common:tuwariTexts)//morph[
			item[@type="cf"] = $form
		])
	)
);
:)

declare variable $page:text2size := map:merge(
	for $entry in collection($common:tuwariTexts)/document/interlinear-text
 	return map:entry (
		data($entry/@guid),
		count($entry//morph)
	)
);

declare variable $page:pos := distinct-values(collection($common:tuwariLexicon)/lift/entry/sense/grammatical-info/@value);

(:============================================================================:)
(: Home page :)
(:============================================================================:)

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Home page.
 : @return HTML page
 :)
declare
  %rest:path("Tuwari")
  %output:method("xml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:start()
  as element(Q{http://www.w3.org/1999/xhtml}html)
{
  <html:html xmlns:html="http://www.w3.org/1999/xhtml">
    <html:head>
      <html:title>Lexicon</html:title>
      <html:link rel="stylesheet" type="text/css" href="static/style.css"/>
    </html:head>
    <html:body>
	{
		page:make-header()
	}
	<html:h1>Tuwari language (tww) corpus and lexicon</html:h1>
	<html:ul>
      <html:li>
		<html:h3>Corpus</html:h3>
		<html:ul>
		<html:li><html:a href="ViewTextsTable">Texts</html:a></html:li>
		<html:li><html:a href="Words">Analyses by words</html:a></html:li>
		<html:li><html:a href="Tags">Tags</html:a></html:li>
		</html:ul>
		</html:li>
      <html:li>
      <html:h3>Lexicon</html:h3>
		<html:ul>
		<html:li><html:a href="ViewLexiconTable">Whole lexicon list</html:a></html:li>
		<html:li><html:a href="AllomorphByWord">Allomorph by word</html:a></html:li>
		<html:li><html:a href="NounsByClasses">Nouns by classes</html:a></html:li>
      <html:li><html:a href="ViewLexiconEntrySearchEmpty">Search for a lexicon entry</html:a></html:li>
      <html:li><html:a href="ViewAllomorphie">View allomorphs</html:a></html:li>
      <html:li><html:a href="ViewSynonymie">View synonymie</html:a></html:li>
      <html:li><html:a href="ViewPolysemy">View polysemy and homophony</html:a></html:li>
      <html:li><html:a href="Statistics">Statistics</html:a></html:li>
      <html:li><html:a href="PrintableDictionary">Printable dictionary</html:a></html:li>
		</html:ul>
		</html:li>
		</html:ul>
    </html:body>
  </html:html>
};

(:============================================================================:)
(: Lists :)
(:============================================================================:)

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : List of the Tags of the corpus.
 : @return HTML page
 :)
declare
  %rest:path("Tags")
  %output:method("html")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:view-tags()
  as element(html)
{
  <html>
	{page:make-datatable-header("Tags")}
  {
	let $alltags := collection($common:tuwariTexts)/document/interlinear-text/paragraphs/paragraph/phrases/word/item[@type="note"]
	return 
    <body>
	 { page:make-header-html() }
	 <h3>Tags</h3>

  	 <table id="table" class="display">
	 <thead>
	 <tr>
	 	<th>Tag</th>
	 	<th># occurrences</th>
	 </tr>
	 </thead>
	 <tfoot>
	 <tr>
	 	<th>Tag</th>
	 	<th># occurrences</th>
	 </tr>
	 </tfoot>
	 <tbody>
	 {
			for $tags in $alltags
			group by $tag := $tags/text()
			order by $tag
		 	return <tr>
		 		<td><strong>{data($tag)}</strong></td>
				<td>{count($tags)}</td>
			</tr>
	 }
	 </tbody>
	 </table>
    </body>
 }
  </html>
};

			(:
			<a href="{concat('ViewText/', data($tag/../../../../../item[@type='title-abbreviation']))}">

			</a>
			:)

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : List of the Words of the corpus.
 : @return HTML page
 :)
declare
  %rest:path("Words")
  %output:method("html")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:view-words()
  as element(html)
{
  <html>
	{page:make-datatable-header("Words")}
  {
	let $allwords := collection($common:tuwariTexts)/document/interlinear-text/paragraphs/paragraph/phrases/word/words/word
	let $nallwords := count($allwords)
	let $nwordforms := count(fn:distinct-values($allwords ! concat(./item[@type='txt' and  @lang='tww']/text(), ./item[@type='pos' and @lang='en']/text())))
	return 
    <body>
	 { page:make-header-html() }
	 <h3>Words ({$nallwords} occ., {$nwordforms} word forms)</h3>

  	 <table id="table" class="display">
	 <thead>
	 <tr>
	 	<th>form</th>
	 	<th>POS</th>
	 	<th>#occurrences</th>
	 	<th>#analyses</th>
	 </tr>
	 </thead>
	 <tfoot>
	 <tr>
	 	<th>form</th>
	 	<th>POS</th>
	 	<th>#occurrences</th>
	 	<th>#analyses</th>
	 </tr>
	 </tfoot>
	 <tbody>
	 {
			for $words in $allwords
			group by $form := $words/item[@type='txt' and  @lang='tww']/text(), $pos := $words/item[@type='pos' and @lang='en']/text()
			order by $form, $pos
		 	return <tr>
		 		<td><strong><a href="ViewWordDetail/{$form}-{$pos}">{$form}</a></strong></td>
				<td>{$pos}</td>
				<td>{count($words)}</td>
				<td>{count(page:distinct-deep($words))}</td>
			</tr>
	 }
	 </tbody>
	 </table>
    </body>
 }
  </html>
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : List of the texts of the corpus.
 : @return HTML page
 :)
declare
  %rest:path("ViewTextsTable")
  %output:method("html")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:view-texts-table()
  as element(html)
{
  <html>
	<head>
	<title>Lexicon</title>

    <script type="text/javascript" language="javascript" src="js/DataTables/datatables.js"> </script>
    <script type="text/javascript" language="javascript" src="js/yadcf-0.9.2/jquery.dataTables.yadcf.js"> </script>
    <!--
    <link rel="stylesheet" type="text/css" href="static/jquery.dataTables.min.css"/>
    <link rel="stylesheet" type="text/css" href="//cdn.datatables.net/1.10.11/css/jquery.dataTables.min.css"/>

    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.22/js/jquery.dataTables.js" />
	<script src="https://code.jquery.com/jquery-1.12.4.min.js" integrity="sha256-ZosEbRLbNQzLpnKIkEdrPv7lOy9C27hHQ+Xp8a4MxAQ=" crossorigin="anonymous"/>
	-->

    <script type="text/javascript" language="javascript" src="js/TextTable.js" />

	<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.22/css/jquery.dataTables.css" />
    <link rel="stylesheet" type="text/css" href="../css/style.css"/>
	<link rel="shortcut icon" href="#"/>

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

	<!--{page:make-datatable-header("Texts")}-->



    <body>
	 { page:make-header-html() }
	 <h3>Texts</h3>
	 <p>{count(collection($common:tuwariTexts)/document/interlinear-text)} texts found</p>

	 <table class="display" id="table">
	   <thead>
		<tr>
			<th>Title</th>
			<th>Abbreviation</th>
			<th># tokens</th>
		</tr>
	    </thead>
		<tfoot>
		<tr>
			<th>Title</th>
			<th>Abbreviation</th>
			<th># tokens</th>
		</tr>
		</tfoot>
		<tbody>
		{
		for $text in collection($common:tuwariTexts)/document/interlinear-text
		return
		<tr>
		<td>
 			<a href="{concat('ViewText/', data($text/item[@type='title-abbreviation' and @lang='en']))}">{$text/item[@type='title']}</a>
		</td>
		<td>
			<a href="{concat('ViewText/', data($text/item[@type='title-abbreviation' and @lang='en']))}">{$text/item[@type='title-abbreviation']}</a>
		</td>
		<td>
		{
			map:get($page:text2size, data($text/@guid))
		}
		</td>
		</tr>
	 }
	</tbody>
	 </table>
    </body>
  </html>
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
  function page:view-lexicon-table()
  as element(html)
{
  <html>

	<head>
	<title>Lexicon</title>

    <script type="text/javascript" language="javascript" src="static/DataTables/datatables.js"> </script>
    <script type="text/javascript" language="javascript" src="static/yadcf-0.9.2/jquery.dataTables.yadcf.js"> </script>

    <link rel="stylesheet" type="text/css" href="static/jquery.dataTables.min.css"/>
    <link rel="stylesheet" type="text/css" href="static/style.css"/>
    <link rel="stylesheet" type="text/css" href="//cdn.datatables.net/1.10.11/css/jquery.dataTables.min.css"/>

    <script type="text/javascript" language="javascript" src="static/LexiconList.js" />

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
			count(collection($common:tuwariLexicon)/lift/entry)
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
		for $entry in collection($common:tuwariLexicon)/lift/entry
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

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Allomporph by nouns
 : @return HTML page
 :)
declare
  %rest:path("AllomorphByWord")
  %output:method("html")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:allomorph-by-word()
  as element(html)
{
  <html>

	<head>
	<title>Nouns by classes</title>
    <script type="text/javascript" language="javascript" src="static/DataTables/datatables.js"> </script>
    <script type="text/javascript" language="javascript" src="static/yadcf-0.9.2/jquery.dataTables.yadcf.js"> </script>

    <link rel="stylesheet" type="text/css" href="static/jquery.dataTables.min.css"/>
    <link rel="stylesheet" type="text/css" href="static/style.css"/>
    <link rel="stylesheet" type="text/css" href="//cdn.datatables.net/1.10.11/css/jquery.dataTables.min.css"/>

    <script type="text/javascript" language="javascript" src="static/AllomorphList.js" />
</head>

	 <body>

	 	<div xmlns:html="http://www.w3.org/1999/xhtml">
	 	<a href="http://localhost:8984/Tuwari">Home</a>
	 	<hr />
	 	</div>
		<ul>
		<li>Total number of forms: {count(collection($common:tuwariLexicon)/lift/entry)}</li>
		<li>Total number of forms having allomorph: {count(collection($common:tuwariLexicon)/lift/entry[variant])}</li>
		<li>Total number of allomorph: {count(collection($common:tuwariLexicon)/lift/entry/variant)}</li>
		</ul>
		<div>
			 <table id="table" class="display">
	   <thead border="1">
			<tr>
				<th>Form</th>
				<th>Sense</th>
				<th>Type</th>
				<th>POS</th>
				<th>allomorph</th>
			</tr>
		</thead>
		<tbody>
		{
	for $word in collection($common:tuwariLexicon)/lift/entry[variant]
    let $form := $word/lexical-unit/form/text/text()
	let $order := if (data($word/@order)) then data($word/@order) else "0"
	order by $word/lexical-unit/form/text/text()
	return
	<tr>
	<td><a href="ViewLexiconEntryDetail/{data($word/@id)}"><strong>{$form}{if ($order != "0") then <sub>{$order}</sub> else ()}</strong></a></td>
	<td>{("'", string-join($word/sense/gloss, "',  '"),"'")}</td>
	<td>{data($word/trait/@value)}</td>
	<td>{data($word/sense[1]/grammatical-info/@value)}</td>
	<td>
	{
	for $variant in $word/variant
	return string($variant/form/text)
	}
	</td>
	</tr>

		}
		</tbody>
	 </table>

		
	</div>
	
    </body>
  </html>
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Nouns by classes
 : @return HTML page
 :)
declare
  %rest:path("NounsByClasses")
  %output:method("html")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:nouns-by-classes()
  as element(html)
{
  <html>

	<head>
	<title>Nouns by classes</title>
    <script type="text/javascript" language="javascript" src="static/DataTables/datatables.js"> </script>
    <script type="text/javascript" language="javascript" src="static/yadcf-0.9.2/jquery.dataTables.yadcf.js"> </script>
    <link rel="stylesheet" type="text/css" href="static/jquery.dataTables.min.css"/>
    <link rel="stylesheet" type="text/css" href="static/style.css"/>
    <link rel="stylesheet" type="text/css" href="//cdn.datatables.net/1.10.11/css/jquery.dataTables.min.css"/>

</head>

	 <body>

	 	<div xmlns:html="http://www.w3.org/1999/xhtml">
	 	<a href="http://localhost:8984/Tuwari">Home</a>
	 	<hr />
	 	</div>
		<div>
		{		
	let $classes := distinct-values(data(collection($common:tuwariLexicon)/lift/entry/sense[grammatical-info/@value = 'Noun' and grammatical-info/trait/@name = "Noun-infl-class"]/grammatical-info/trait[@name = "Noun-infl-class"]/@value))
	return
	<div>
	<p>Number of classes: {count($classes)}</p>
	{
		for $class in $classes
		let $nouns := collection($common:tuwariLexicon)/lift/entry[sense/grammatical-info/@value = 'Noun' and data(sense/grammatical-info/trait[@name = "Noun-infl-class"]/@value) = $class]
		order by $class
	return 
	<div>
		 	<hr />
		<h3>{$class}</h3>
		
			 <table id="table" class="display">
	   <thead border="1">
			<tr>
				<th>Form</th>
				<th>gloss en. (sense 1)</th>
				<th>gloss tpi. (Sense 1)</th>
				<th>Semantic category</th>
				<!--
				<th># senses</th>
				<th># allomorphes</th>
				<th>Frequency</th>-->
			</tr>
		</thead>
		<tbody>
		{

		for $entry in $nouns
			let $form := $entry/lexical-unit/form/text/text()
			let $order := if (data($entry/@order)) then data($entry/@order) else "0"
			let $sens1en := $entry/sense[1]/gloss[@lang="en"]/text
			let $sens1tpi := $entry/sense[1]/gloss[@lang="tpi"]/text
			let $semcats := $entry/sense[1]/trait[@name="semantic-domain-ddp4"]
			let $numsens := count($entry/sense)
			let $numvariant := count($entry/variant)
			order by $form, $order
		return
		<tr>
			<td><a href="ViewLexiconEntryDetail/{data($entry/@id)}"><strong>{$form}{if ($order != "0") then <sub>{$order}</sub> else ()}</strong></a></td>
			<td>{$sens1en}</td>
			<td>{$sens1tpi}</td>
			<td>{for $semcat in $semcats return <span class="label lightblue">{data($semcat/@value)}</span>}</td>
		</tr>
		
		}
		</tbody>
	 </table>

		
	</div>
	
	
		}
		</div>
}
</div>
    </body>
  </html>
};

(:
			<td>{$numsens}</td>
			<td>{$numvariant}</td>
			<td>{map:get($page:entry2frequency, concat($form, $order))}</td>
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
  function page:view-lexicon-entry-detail(
    $entryid as xs:string)
    as element(Q{http://www.w3.org/1999/xhtml}html)
	 {
		<html:html xmlns:html="http://www.w3.org/1999/xhtml">
		<html:head>
		<html:link rel="stylesheet" type="text/css" href="../static/style.css"/>
		</html:head>
		{
			let $entry := collection($common:tuwariLexicon)/lift/entry[@id = $entryid]
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
				count(collection($common:tuwariTexts)//morph[item[@type=cf] = $form and item[@type="hn"] = $order ])
				else count(collection($common:tuwariTexts)//morph[item[@type="cf"] = $form ])				

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
					page:view-concordance($form, $order, 5, 5)
				}

			</html:body>
		}
		</html:html>
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : View allomorphie
 : @return HTML page
 :)
declare
  %rest:path("/ViewAllomorphie")
  %output:method("xml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:view-allomorphie()
    as element(Q{http://www.w3.org/1999/xhtml}html)
{
	<html:html xmlns:html="http://www.w3.org/1999/xhtml">
	<html:head>
	  <html:title>Allomorphy</html:title>
   <html:link rel="stylesheet" type="text/css" href="static/style.css"/>
	</html:head>
	<html:body>
	{
			page:make-header()
	}
	{
		let $entries := collection($common:tuwariLexicon)/lift/entry
		for $entry in $entries
		let $form := $entry/lexical-unit/form/text/text()
		where $entry/variant
		order by $form
		return
		(
		<html:h2>
			{<html:i>{$form}</html:i>, ($entry/sense/gloss[@lang="en"]/text/text()) ! (" '", ., "'")}
		</html:h2>
		,
		if ($entry/variant)
		then <html:p>( {$entry/variant/form[@lang="tww"]/text ! (" ", <html:i>{./text()}</html:i>)})</html:p>
		else ()
		)
	}
	</html:body>
	</html:html>
};


(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : View synonymie
 : @return HTML page
 :)
declare
  %rest:path("/ViewSynonymie")
  %output:method("xml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:view-synonymie()
    as element(Q{http://www.w3.org/1999/xhtml}html)
{
	<html:html xmlns:html="http://www.w3.org/1999/xhtml">
	<html:head>
   <html:link rel="stylesheet" type="text/css" href="static/style.css"/>
	  <html:title>Synonymy</html:title>
	</html:head>
	<html:body>
	{
			page:make-header()
	}
	{
			for $senses in collection($common:tuwariLexicon)/lift/entry/sense
			group by $gloss := $senses/gloss[@lang="en"]/text/text()
			let $group_size := count(collection($common:tuwariLexicon)/lift/entry/sense/gloss[@lang="en" and text/text() = $gloss])
			order by $group_size descending
			where $group_size > 1
			return
			<html:div>
			<html:h2>'{$gloss}'</html:h2>
			<html:ul>
			{
				for $sense in $senses
				return <html:li><html:i> {$sense/../lexical-unit/form/text/text()} </html:i></html:li>
			}
			</html:ul>
			</html:div>
	}
	</html:body>
	</html:html>
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : View synonymie
 : @return HTML page
 :)
declare
  %rest:path("/ViewPolysemy")
  %output:method("xml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:view-polysemy()
    as element(Q{http://www.w3.org/1999/xhtml}html)
{
	<html:html xmlns:html="http://www.w3.org/1999/xhtml">
	<html:head>
	  <html:title>Polysemy and homophony</html:title>
      <html:link rel="stylesheet" type="text/css" href="static/style.css"/>
	</html:head>
	<html:body>
	{
			page:make-header()
	}
	<html:div>		
	{
	
    let $homophoneous := map:merge(
    for $entry in collection($common:tuwariLexicon)/lift/entry
    let $form := $entry/lexical-unit/form/text/text()
      return map:entry(
        if ($form) then $form else "(Missing)",
        $entry
      ),
      map { 'duplicates': 'combine' }
    )

	let $homo2sensecount := 
	map:merge(
	  map:for-each(
	    $homophoneous,
	    function($key, $value) { map:entry($key, for $e in $value return count($e/sense)) }
	  ),
      map { 'duplicates': 'combine' }
    )
    
  let $homo2totalcount := 
	map:merge(
	  map:for-each(
	    $homo2sensecount,
	    function($key, $value) { map:entry($key, sum($value)) }
	  ),
      map { 'duplicates': 'combine' }
    )
  
  for $entry in map:keys($homo2totalcount)
  order by $homo2totalcount($entry) descending
  where $homo2totalcount($entry) > 1
  return (
			<html:h2>{$entry}</html:h2>,
			<html:ul>
			{
			    for $lexem in $homophoneous($entry)
				return
                  <html:li>
				  {
				  (:$lexem/lexical-unit/form/text/text():)
				  if ($entry != "(Missing)")
				  then page:display-form($lexem/lexical-unit/form/text/text(), if ($lexem/@order) then data($lexem/@order) else "0" )
				  else $entry
				  (: x :)
				  }
				  <html:ul>
				   {
				    for $sense in $lexem/sense
				    return <html:li><html:i>
					{
				      
					  $sense/gloss[@lang="en"]/text,
				      " (",
					  data($sense/grammatical-info/@value),
				      ")"
				      
					}
					</html:i></html:li>
				  }
				  </html:ul>
                  </html:li>

			}
			</html:ul>
)

					  (:
					  ,
				      ":",
					  $sense/grammatical-info/@value,
				      ")"
					  :)

(:  <p>{($entry, ":", $homo2totalcount($entry))}</p> :)

(:
  <sense id="a713cf5f-bb55-498a-a1f1-cb67c95ba339">
    <grammatical-info value="Verb">
      <trait name="type" value="inflAffix"/>
      <trait name="Verb-slot" value="GenderNumber"/>
    </grammatical-info>
    <gloss lang="en">
      <text>-M.SG</text>
    </gloss>
  </sense>
:)


(:string-join(, ""):)

(:
for $entry in map:keys($homophoneous)
where count($homophoneous($entry)) > 1 or $homophoneous($entry)/sense > 1
return
<p>{$entry}</p>
:)

(:for $e in $homophoneous2freq($entry) return data($e):)

(:	let $homophoneous2freq := map:merge(
	  for $entry in distinct-values(collection($common:tuwariLexicon)/lift/entry/lexical-unit/form/text/text())
	  return map:entry(
	  	  $entry,
		  count(collection($common:tuwariLexicon)/lift/entry[lexical-unit/form/text/text() = $entry])
	  )
    )
:)
(:
			for $entry in collection($common:tuwariLexicon)/lift/entry
            let $map := map { 'foo': 42, 'bar': 'baz', 123: 456 }
			let $form := $entry/lexical-unit/form/text/text()
			let $nsense := count($entry/sense)
			order by $nsense descending
			where $nsense > 1
			return
			<html:div>
			<html:h2>'{$form}'</html:h2>
			<html:ul>
			{
				for $sense in $entry/sense
				return <html:li><html:i> {$sense/gloss/text} </html:i></html:li>
			}
			</html:ul>
			</html:div>

:)

	}
	</html:div>
	</html:body>
	</html:html>
};


(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Statistics
 : @return HTML page
 :)
declare
  %rest:path("/Statistics")
  %output:method("xml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:view-statistics()
    as element(Q{http://www.w3.org/1999/xhtml}html)
{
	<html:html xmlns:html="http://www.w3.org/1999/xhtml">
	<html:head>
	  <html:title>Statistics</html:title>
   <html:link rel="stylesheet" type="text/css" href="static/style.css"/>
	</html:head>
	<html:body>
	{
			page:make-header()
	}
	{
	    let $ntexts := count(collection($common:tuwariTexts)/document/interlinear-text)
	    let $nmorphems := count(collection($common:tuwariTexts)/document/interlinear-text/paragraphs/paragraph/phrases/word/words/word/morphemes/morph)
		let $nwords := count(collection($common:tuwariTexts)/document/interlinear-text/paragraphs/paragraph/phrases/word/words/word)
		let $nlexem := count(collection($common:tuwariLexicon)/lift/entry)
		let $nstem := count(collection($common:tuwariLexicon)/lift/entry[trait[@name="morph-type"]/@value = "stem"])
		let $nsuffix := count(collection($common:tuwariLexicon)/lift/entry[trait[@name="morph-type"]/@value = "suffix"])
		let $nprefix := count(collection($common:tuwariLexicon)/lift/entry[trait[@name="morph-type"]/@value = "prefix"])
		return
<html:div>
    <html:h2>Tuwari documentation: statistics</html:h2>
    <html:h3>Corpus</html:h3>
	<html:ul>
	  <html:li>{$ntexts} texts</html:li>
	  <html:li>{$nmorphems} morphems tokens</html:li>
	  <html:li>{$nwords} lexems tokens</html:li>
	</html:ul>
    <html:h3>Lexicon</html:h3>
	<html:ul>
	  <html:li>{$nlexem} morphems</html:li>
	</html:ul>

	  <html:h4>Morphem types:</html:h4>
	<html:table>
	{
	for $morphtype in collection($common:tuwariLexicon)/lift/entry/trait[@name="morph-type"]/@value
	let $distinct := $morphtype
	group by $distinct
	order by count($morphtype) descending
	return <html:tr><html:td>{$distinct}</html:td><html:td>{count($morphtype)}</html:td></html:tr>
	}
	</html:table>
<html:p> </html:p>
	  <html:h4>POS:</html:h4>
	<html:table>
	{
	for $pos in collection($common:tuwariLexicon)/lift/entry/sense[1]/grammatical-info/@value
	let $distinct := $pos
	group by $distinct
	order by count($pos) descending
	return <html:tr><html:td>{$distinct}</html:td><html:td>{count($pos)}</html:td></html:tr>
	}
	</html:table>


</html:div>
}
	</html:body>
	</html:html>
};

(:============================================================================:)
(: Display text, concordance :)
(:============================================================================:)

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Display a concordance
 : @return HTML page
 :)
declare
  function page:view-concordance(
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
		for $parent_word in collection($common:tuwariTexts)/document/interlinear-text/paragraphs/paragraph/phrases/word/words/word[morphemes/morph[item[@type="cf"] = $lexem]]
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
					else page:view-words(<words>{$left_context[$left_size + 1 - $revindex]}</words>)
				}
				</html:td>
				}
			    <html:td class="concordance_node">
			    {
			    page:view-words(<words>{$parent_word}</words>)
		 	    }
			    </html:td>
				{
			    for $i in (1 to $right_context_size)
			    return
			    <html:td>
			    {
 				if ($i > count($right_size)) then "&#160;"
				else page:view-words(<words>{$right_context[$i]}</words>)
				
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

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Dislpay a text
 : @return HTML page
 :)
declare
  %rest:path("ViewText/{$id}")
  %output:method("xml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:view-text(
  	    $id as xs:string
  )
  as element(Q{http://www.w3.org/1999/xhtml}html)
{
	<html:html xmlns:html="http://www.w3.org/1999/xhtml">
		{
		let $text := 
collection($common:tuwariTexts)/document/interlinear-text[item[@type = 'title-abbreviation'] = $id]
		return (
			<html:head>
			<html:title>Text</html:title>
			<html:link rel="stylesheet" type="text/css" href="../static/style.css"/>
			<html:style>
			table &#123;
				table-layout:fixed;
			&#125;
			td &#123;
				overflow:hidden;
				white-space:nowrap;
			&#125;
			</html:style>
			</html:head>,
			<html:body>
			{
				page:make-header()
			}
			
			<html:h2>{$text/item[@type='title']/text()}</html:h2>
			<html:a href="/text2pdf/{$id}">pdf</html:a>
			<html:a href="/text2tex/{$id}">tex</html:a>
			
			{	
				page:view-paragraphs($text/paragraphs)
				}
				</html:body>
				)
			}
	</html:html>
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Detail of a word analyses
 : @return HTML page
 :)
declare
  %rest:path("/ViewWordDetail/{$formpos}")
  %rest:GET
  %output:method("xml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:view-word-detail(
    $formpos as xs:string)
    as element(Q{http://www.w3.org/1999/xhtml}html)
	 {
		<html:html xmlns:html="http://www.w3.org/1999/xhtml">
		<html:head>
		<html:link rel="stylesheet" type="text/css" href="../static/style.css"/>
		</html:head>
		{
			let $form := fn:tokenize($formpos, "-")[1]
			let $pos := fn:tokenize($formpos, "-")[2]
			return 
			<html:body>
			{
				page:make-header()
			}
			<html:h2>Word form: <html:i>{$form}</html:i> ({$pos})</html:h2>
			<html:hr />
			{
				for $analyse in page:distinct-deep(collection($common:tuwariTexts)/document/interlinear-text/paragraphs/paragraph/phrases/word/words/word
							[
							item[@type='txt' and  @lang='tww']/text() = $form
							and
							item[@type='pos' and @lang='en']/text() = $pos
							]
				)
				count $n
				return <html:div>
				<html:h2>{$n}</html:h2>
				{
					page:view-words(<words>{$analyse}</words>)
				}
				<html:hr />
				</html:div>
				
			}
			</html:body>
		}
		</html:html>
};

(:============================================================================:)
(:Search :)
(:============================================================================:)

declare function page:lexicon-entry-search-form
($entry as xs:string)
as element(Q{http://www.w3.org/1999/xhtml}div)
{
<html:div  xmlns:html="http://www.w3.org/1999/xhtml">  
	<html:div xmlns:html="http://www.w3.org/1999/xhtml">

		<html:p>Search form</html:p>

	<html:form method="post" action="ViewLexiconEntrySearch" >
	<br />
	<html:p>
<!--
	<fieldset>
	<legend>Search for:</legend>
	<label for="baseline">Baseline</label>
	<input type="radio" name="field" value="baseline" id="baseline" checked='checked'/>
	<label for="morph">Morph</label>
	<input type="radio" name="field" value="morph" id="morph" />
	<label for="gloss">Gloss</label>
	<input type="radio" name="field" value="gloss" id="gloss" />
	</fieldset>
-->
	<input type="text" name="entry" size="50" value="{$entry}">
	</input>
	<input type="submit" value="Submit">
	</input>
	<!--<form action="/action_page.php" />-->
	</html:p>
	</html:form>
	</html:div>

	<html:div xmlns:html="http://www.w3.org/1999/xhtml">
		<html:p>Search baseline text</html:p>
	<html:form method="post" action="ViewBaselineTextSearch" >
	<br />
	<html:p>

	<fieldset>
	<legend>Search for:</legend>
	<label for="baseline">Baseline</label>
	<input type="radio" name="field" value="baseline" id="baseline" checked='checked'/>
	<br />
	<label for="morph">Morph</label>
	<input type="radio" name="field" value="morph" id="morph" />
	<br />
	<label for="gloss">Gloss</label>
	<input type="radio" name="field" value="gloss" id="gloss" />
	</fieldset>

	<input type="text" name="searchedstring" size="50" value="{$entry}">
	</input>
	<input type="submit" value="Submit">
	</input>
	<!--<form action="/action_page.php" />-->
	</html:p>
	</html:form>
	</html:div>
</html:div> 
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Search for a lexical type
 : @return HTML page
 :)
declare
  %rest:path("/ViewBaselineTextSearch")
  %rest:POST
  %rest:form-param("entry","{$entry}", "(no message)")
  %output:method("xml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:view-baseline-text-search(
    $entry as xs:string)
    as element(Q{http://www.w3.org/1999/xhtml}html)
{
	<html:html xmlns:html="http://www.w3.org/1999/xhtml">
	<html:head>
   <html:link rel="stylesheet" type="text/css" href="static/style.css"/>
	</html:head>
	{ page:make-header() }
	{ page:lexicon-entry-search-form($entry) }
	<html:div>
	 {
		let $results := collection($common:tuwariLexicon)/lift/entry[lexical-unit/form/text = $entry]
		let $nmatch := count($results)
		return
		if ($nmatch = 0)
		then <html:p>No entry found</html:p>
		else <html:div> <html:p>{$nmatch} entry(ies) found</html:p> {
			for $result in $results
			let $id := data($result/@id)
			let $form := $result/lexical-unit/form/text
			order by $result/@order
			return
			<html:div style="border:solid 1px black; display: block; color:#0000FF; width:300px">
					<html:input type="hidden" name="entryid" value="{data($result/@id)}" />
					<html:h3><html:a href="ViewLexiconEntryDetail/{$id}">{ $result/lexical-unit/form/text }<sub>{data($result/@order)}</sub></html:a></html:h3>
					<html:ul>{
						for $sense in $result/sense
						return
					   <html:li>
				   	({data($sense/grammatical-info/@value)})
						{ for $gloss in $sense/gloss
							return
							<html:p>{data($gloss/@lang)}.: <html:i>{$gloss/text}</html:i></html:p>
						}
						
						</html:li>
						}</html:ul>
			<html:br />
			</html:div>
		}
		</html:div>
	}
	</html:div>
	</html:html>
};


(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Search for a lexical type
 : @return HTML page
 :)
declare
  %rest:path("/ViewLexiconEntrySearch")
  %rest:POST
  %rest:form-param("entry","{$entry}", "(no message)")
  %output:method("xml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:view-lexicon-entry-search(
    $entry as xs:string)
    as element(Q{http://www.w3.org/1999/xhtml}html)
{
	<html:html xmlns:html="http://www.w3.org/1999/xhtml">
	<html:head>
   <html:link rel="stylesheet" type="text/css" href="static/style.css"/>
	</html:head>
	{ page:make-header() }
	{ page:lexicon-entry-search-form($entry) }
	<html:div>
	 {
		let $results := collection($common:tuwariLexicon)/lift/entry[lexical-unit/form/text = $entry]
		let $nmatch := count($results)
		return
		if ($nmatch = 0)
		then <html:p>No entry found</html:p>
		else <html:div> <html:p>{$nmatch} entry(ies) found</html:p> {
			for $result in $results
			let $id := data($result/@id)
			let $form := $result/lexical-unit/form/text
			order by $result/@order
			return
			<html:div style="border:solid 1px black; display: block; color:#0000FF; width:300px">
					<html:input type="hidden" name="entryid" value="{data($result/@id)}" />
					<html:h3><html:a href="ViewLexiconEntryDetail/{$id}">{ $result/lexical-unit/form/text }<sub>{data($result/@order)}</sub></html:a></html:h3>
					<html:ul>{
						for $sense in $result/sense
						return
					   <html:li>
				   	({data($sense/grammatical-info/@value)})
						{ for $gloss in $sense/gloss
							return
							<html:p>{data($gloss/@lang)}.: <html:i>{$gloss/text}</html:i></html:p>
						}
						
						</html:li>
						}</html:ul>
			<html:br />
			</html:div>
		}
		</html:div>
	}
	</html:div>
	</html:html>
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Search for a lexical type (when empty)
 : @return HTML page
 :)
declare
  %rest:path("/ViewLexiconEntrySearchEmpty")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:view-lexicon-entry-search-empty()
    as element(Q{http://www.w3.org/1999/xhtml}html)
{
	<html:html xmlns:html="http://www.w3.org/1999/xhtml">
	<html:head>
   <html:link rel="stylesheet" type="text/css" href="static/style.css"/>
	</html:head>
	{ page:make-header() }
	{ page:lexicon-entry-search-form("") }
	</html:html>
};


(:============================================================================:)
(: EDIT :)
(:============================================================================:)

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Edit a sentence
 : @param a string : the sentence id
 : @return HTML page
 :)
declare
		  %rest:path("/ViewText/EditSentence")
		  %rest:POST
		  %rest:form-param("sentenceId","{$sentenceId}", "(no message)")
		  function page:editSentence(
		    $sentenceId as xs:string)
  as element(Q{http://www.w3.org/1999/xhtml}html)
{
	<html:html xmlns:html="http://www.w3.org/1999/xhtml">
	</html:html>
};

(:============================================================================:)
(: Varia :)
(:============================================================================:)

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Select unique nodes (the descendance of the nodes are considered for assessing identity)
 :
 : Fonctions empruntées à http://www.functx.com
 :
 : @param nodes a node set
 : @return node*
 :)
declare function page:distinct-deep
($nodes as node()*)
as node()* {
	for $seq in (1 to count($nodes))
	return $nodes[$seq][not(page:is-node-in-sequence-deep-equal(
		.,$nodes[position() < $seq]))]
};

declare function page:is-node-in-sequence-deep-equal 
($node as node()?, $seq as node()*)
as xs:boolean {
	some $nodeInSeq in $seq satisfies deep-equal($nodeInSeq,$node)
};

(:============================================================================:)

declare function page:make-header-html () as element(div) {
	<div>
	<a href="http://localhost:8984/Tuwari">Home</a>
	<hr />
	</div>
};

declare function page:make-header () as element(Q{http://www.w3.org/1999/xhtml}div) {
	<html:div xmlns:html="http://www.w3.org/1999/xhtml">
	<html:a href="http://localhost:8984/Tuwari">Home</html:a>
	<html:hr />
	</html:div>
};

declare function page:make-datatable-header ($title as xs:string) as element(head) {
	<head>
	<title>{$title}</title>
    <script type="text/javascript" language="javascript" src="static/DataTables/datatables.js"> </script>
    <link rel="stylesheet" type="text/css" href="static/jquery.dataTables.min.css"/>
    <link rel="stylesheet" type="text/css" href="static/style.css"/>
    <link rel="stylesheet" type="text/css" href="//cdn.datatables.net/1.10.11/css/jquery.dataTables.min.css"/>
    <script type="text/javascript" language="javascript">
	$(document).ready( function () &#123;

	/* Individual column searching (text inputs) */
		$('#table tfoot th').each( function () &#123;
			var title = $(this).text();
			$(this).html( '<input type="text" placeholder="Search '+title+'" />' );
		&#125; );

	    var table = $('#table').DataTable( &#123;
			 /*"dom" : '&lt;lf&lt;t>ip>',*/
			 "pagingType": "full_numbers",
			 "lengthMenu": [[-1, 10, 25, 50], ["All", 10, 25, 50]],
          /*"scrollY": "400px",*/
          /*"paging": false,*/

			 /* Individual column searching (select inputs) */
			 /*
          initComplete: function () &#123;
              this.api().columns().every( function () &#123;
                  var column = this;
                  var select = $('<select><option value=""></option></select>')
                      .appendTo( $(column.footer()).empty() )
                      .on( 'change', function () &#123;
                          var val = $.fn.dataTable.util.escapeRegex(
                              $(this).val()
                          );
                          column
                              .search( val ? '^'+val+'$' : '', true, false )
                              .draw();
                      &#125; );
                  column.data().unique().sort().each( function ( d, j ) &#123;
                      select.append( '<option value="'+d+'">'+d+'</option>' )
                  &#125; );
              &#125; );
          &#125;
			 */

			 /* Child rows (show extra / detailed information) */

			 /* Index columns */

			 /* Using API in callbacks */
			 /*
          "initComplete": function () &#123;
              var api = this.api();
              api.$('td').click( function () &#123;
                  api.search( this.innerHTML ).draw();
              &#125; );
          &#125;
			 */

			 &#125;);

		 	/* Individual column searching (text inputs) */
		    table.columns().every( function () &#123;
		        var that = this;
 
		        $( 'input', this.footer() ).on( 'keyup change', function () &#123;
		            if ( that.search() !== this.value ) &#123;
		                that
		                    .search( this.value )
		                    .draw();
		            &#125;
		        &#125; );
		    &#125; );

			 /* Show / hide columns dynamically */
			 /*
		    $('a.toggle-vis').on( 'click', function (e) &#123;
		        e.preventDefault();

		        // Get the column API object
		        var column = table.column( $(this).attr('data-column') );
 
		        // Toggle the visibility
		        column.visible( ! column.visible() );
		    &#125; );
			 */

	&#125; );
</script>
</head>
};

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
declare function page:view-paragraphs
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
			then page:view-phrases($paragraph/phrases)
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
declare function page:view-phrases
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
		page:view-sentence-text($phrase)
		}-->
		<html:tr>
		<html:td>
			{
				page:view-words($phrase/words)
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
declare function page:view-words
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
			if ($word/morphemes) then page:view-morphemes($word/morphemes, fn:false())
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
declare function page:view-morphemes($morphemes as element(morphemes), $edit as xs:boolean)
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
declare function page:view-morphemes-as-table
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
declare function page:view-sentence-text
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

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Standard display of a form (with disambiguation index in subscript)
 :
 : @param a string : @param a string
 : @return Q{http://www.w3.org/1999/xhtml}a 
 :)
declare function page:display-form ($form as xs:string, $order as xs:string)
as element(Q{http://www.w3.org/1999/xhtml}a)
{
<html:a xmlns:html="http://www.w3.org/1999/xhtml"
        href="/ViewLexiconEntryDetail/{map:get($page:lexiconFormOrder2id, concat($form, $order)) }">{
	$form,
	if ($order != "0") then <html:sub>{$order}</html:sub> else ()
}</html:a>
};

































declare
%rest:path("ViewTextAsTable/{$id}")
%output:method("xml")
%output:omit-xml-declaration("no")
%output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
%output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
function page:view-text-as-table(
    $id as xs:string
    )
as element(Q{http://www.w3.org/1999/xhtml}html)
{
  <html:html xmlns:html="http://www.w3.org/1999/xhtml">
          <html:head>

          <script type="text/javascript" language="javascript" src="static/DataTables/datatables.js"> </script>
          <script type="text/javascript" language="javascript" src="static/yadcf-0.9.2/jquery.dataTables.yadcf.js"> </script>

          <link rel="stylesheet" type="text/css" href="static/jquery.dataTables.min.css"/>
          <link rel="stylesheet" type="text/css" href="static/style.css"/>
          <link rel="stylesheet" type="text/css" href="//cdn.datatables.net/1.10.11/css/jquery.dataTables.min.css"/>

          <script type="text/javascript" language="javascript" src="static/SentenceTable.js" />

          <html:title>Text</html:title>
          <html:link rel="stylesheet" type="text/css" href="../static/style.css"/>
          <html:style>
          table &#123;
          table-layout:fixed;
          &#125;
          td &#123;
overflow:hidden;
white-space:nowrap;
&#125;

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
        </html:style>
          </html:head>
          <html:body>
          {
		  page:make-header(),
		  let $text := collection($common:tuwariTexts)/document/interlinear-text[item[@type = 'title-abbreviation'] = $id]
		  return 
		  <html:div>

		  
        <html:h2>{$text/item[@type='title']/text()}</html:h2>
          <html:a href="/text2pdf/{$id}">pdf</html:a>
          <html:a href="/text2tex/{$id}">tex</html:a>
          {
            for $phrase in $text/paragraphs/paragraph/phrases/word
              return
                <table class="display" id="">
                 <thead>
                 <tr>
                 <th>Form</th>
                 <th>Type</th>
                 <th>POS</th>
                 <th>Gloss</th>
                 </tr>
                 </thead>
                 <tfoot>
                 <tr>
                 <th>Form</th>
                 <th>Type</th>
                 <th>POS</th>
                 <th>Gloss</th>
                 </tr>
                 </tfoot>
                 <tbody>
                 {
                 for $word in $phrase/words/word
                 return (
                     page:view-word-as-table($word)
					 )
                 }
                 </tbody>
                 </table>
          }
		  </html:div>
          }
        </html:body>
  </html:html>
};




declare function page:view-word-as-table
($word as element(word))
as element(Q{http://www.w3.org/1999/xhtml}tr)
{
			if ($word/morphemes) then page:view-morphemes-as-table2($word/morphemes, fn:false())
			else if ($word[item[@type="punct"]]) then 
			<html:tr>$word/item[@type="punct"]/text()</html:tr>
			else "unknown situation"
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : view-morphemes -- draw a cell for each morphems of a word
 :
 : @param a table element
 : @return Q{http://www.w3.org/1999/xhtml}tr
 :)
declare function page:view-morphemes-as-table2($morphemes as element(morphemes), $edit as xs:boolean)
as element(Q{http://www.w3.org/1999/xhtml}tr)
{
		for $morph in $morphemes/morph
		let $form := $morph/item[@type='txt' and @lang='tww']/text()
		let $cf := $morph/item[@type='cf' and @lang='tww']/text() 
		let $cf_or_form := if ($cf) then $cf else $form
		let $order := if ($morph/item[@type="hn"]/text()) then $morph/item[@type="hn"]/text() else "0"
		return 
		   <html:tr>
		       <html:td>{page:display-form($cf_or_form, $order)}</html:td>
		       <html:td></html:td>
		       <html:td></html:td>
		       <html:td></html:td>
		   </html:tr>

};

