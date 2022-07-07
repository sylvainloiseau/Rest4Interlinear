module namespace text = 'http://basex.org/modules/text';

import module namespace variable = "configuration" at "variable.xqm";
import module namespace page = "http://basex.org/modules/web-page" at "site.xqm";
import module namespace interlinear = "http://basex.org/modules/interlinear" at "Interlinear.xqm";

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
  function text:view-texts-table()
  as element(html)
{
  <html>
	<head>
	<title>List of texts</title>

	<script type="text/javascript" src="{$variable:jquery}"/>
    <script type="text/javascript" src="{$variable:datatable}" />
    <script type="text/javascript" src="{$variable:yadcf}" />
    <script type="text/javascript" language="javascript" src="{$variable:jsdir}/TextTable.js" />
	<link rel="stylesheet" type="text/css" href="{$variable:jquerycss}" />
    <link rel="stylesheet" type="text/css" href="{$variable:cssdir}/style.css"/>

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
	 <p>{count(collection($variable:tuwariTexts)/document/interlinear-text)} texts found</p>

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
		for $text in collection($variable:tuwariTexts)/document/interlinear-text
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
 : Dislpay a text
 : @return HTML page
 :)
declare
  %rest:path("ViewText/{$id}")
  %output:method("xml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function text:view-text(
  	    $id as xs:string
  )
  as element(Q{http://www.w3.org/1999/xhtml}html)
{
	<html:html xmlns:html="http://www.w3.org/1999/xhtml">
		{
		let $text := 
collection($variable:tuwariTexts)/document/interlinear-text[item[@type = 'title-abbreviation'] = $id]
		return (
			<html:head>
			<html:title>Text: {$id}, {$text/item[@type = 'title']}</html:title>
			<html:link rel="stylesheet" type="text/css" href="{$variable:cssdir}/style.css"/>
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
				interlinear:view-paragraphs($text/paragraphs)
				}
				</html:body>
				)
			}
	</html:html>
};
