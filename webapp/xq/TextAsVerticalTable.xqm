(:-
 : Rest4IGT
 :
 : Public domain
 : Sylvain Loiseau
 : <sylvain.loiseau@univ-paris13.fr>
 :)

module namespace vert-page = 'http://basex.org/modules/web-page-vertical';

import module namespace page = "http://basex.org/modules/web-page" at "site.xqm";
import module namespace variable = "configuration" at "variable.xqm";

declare
%rest:path("ViewTextAsTable/{$id}")
%output:method("xml")
%output:omit-xml-declaration("no")
%output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
%output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
function vert-page:view-text-as-table(
    $id as xs:string
    )
as element(Q{http://www.w3.org/1999/xhtml}html)
{
  <html:html xmlns:html="http://www.w3.org/1999/xhtml">
          <html:head>


    <script type="text/javascript" language="javascript" src="{$variable:jsdir}/DataTables/datatables.js"> </script>
    <script type="text/javascript" language="javascript" src="{$variable:jsdir}/yadcf-0.9.2/jquery.dataTables.yadcf.js"> </script>

    <link rel="stylesheet" type="text/css" href="{$variable:cssdir}/jquery.dataTables.min.css"/>
    <link rel="stylesheet" type="text/css" href="{$variable:cssdir}/style.css"/>
    <link rel="stylesheet" type="text/css" href="//cdn.datatables.net/1.10.11/css/jquery.dataTables.min.css"/>
          <script type="text/javascript" language="javascript" src="{$variable:jsdir}/SentenceTable.js" />


          <html:title>Text</html:title>
          <html:link rel="stylesheet" type="text/css" href="{$variable:cssdir}/style.css"/>
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
		  let $text := collection($variable:TextsDataBaseName)/document/interlinear-text[item[@type = 'title-abbreviation'] = $id]
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
                 return vert-page:view-word-as-table($word)
                 }
                 </tbody>
                 </table>
          }
         </html:div>

          }

        </html:body>
  </html:html>
};




declare function vert-page:view-word-as-table
($word as element(words))
as element(Q{http://www.w3.org/1999/xhtml}tr)
{
			if ($word/morphemes) then vert-page:view-morphemes-as-table2($word/morphemes, fn:false())
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
declare function vert-page:view-morphemes-as-table2($morphemes as element(morphemes), $edit as xs:boolean)
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

