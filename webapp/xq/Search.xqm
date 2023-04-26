(:-
 : Rest4IGT
 :
 : Public domain
 : Sylvain Loiseau
 : <sylvain.loiseau@univ-paris13.fr>
 :)

module namespace search = 'http://basex.org/modules/search';

import module namespace page = "http://basex.org/modules/web-page" at "site.xqm";
import module namespace variable = "configuration" at "variable.xqm";

(:============================================================================:)
(:Search :)
(:============================================================================:)

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Search for a lexical type
 : @return HTML page


 https://www.jqueryscript.net/form/json-form-converter-jform.html
 :)
declare
  %rest:path("/TextSearch")
  %rest:form-param("query", "{$query}", "")
  %rest:GET
  %output:method("html")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function search:text-search($query as xs:string)
  as element(html) {
<html >
  <head>
    <link rel="stylesheet" type="text/css" href="{$variable:cssdir}/style.css"/>
	  <!--<script type="text/javascript" src="{$variable:jquery}"/>-->
    <link rel="stylesheet" style="text/css" href="{$variable:jsdir}/jsonform-master/deps/opt/bootstrap.css" />
  </head>
  { page:make-header() }
  <div>
{
(:
let x := (
  for $type in $common:morph_properties
  return <option value="{$type}">{$type}</option>
)
:)
(:fn:serialize():)}

    <form ></form>
    <div xmlns="" id="res" class="alert"></div>
    <script xmlns="" type="text/javascript" src="{$variable:jsdir}/jsonform-master/deps/jquery.min.js"></script>
    <script xmlns="" type="text/javascript" src="{$variable:jsdir}/jsonform-master/deps/underscore.js"></script>
    <script xmlns="" type="text/javascript" src="{$variable:jsdir}/jsonform-master/deps/opt/jsv.js"></script>
    <script xmlns="" type="text/javascript" src="{$variable:jsdir}/jsonform-master/lib/jsonform.js"></script>
    <script xmlns="" type="text/javascript" language="javascript" src="{$variable:jsdir}/Search.js" />
	<p>
	</p>
  <hr/>
  <hr/>
  </div>
  <div>
<p>query: {$query}</p>
  </div>
</html>
};

