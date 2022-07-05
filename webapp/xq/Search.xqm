module namespace search = 'http://basex.org/modules/search';

import module namespace page = "http://basex.org/modules/web-page" at "site.xqm";
import module namespace variable = "configuration" at "variable.xqm";

(:============================================================================:)
(:Search :)
(:============================================================================:)

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : Search for a lexical type
 : @return HTML page
 :)
declare
  %rest:path("/TextSearch")
  %rest:form-param("level", "{$level}", "")
  %rest:form-param("field", "{$field}", "")
  %rest:form-param("lang", "{$lang}", "")
  %rest:form-param("searchedstring", "{$searched}", "")
  %output:method("xml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function search:text-search(
    $level as xs:string,
    $field as xs:string,
    $lang as xs:string,
    $searched as xs:string)
  as element(Q{http://www.w3.org/1999/xhtml}html) {
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <link rel="stylesheet" type="text/css" href="static/style.css"/>
	<script type="text/javascript" src="{$variable:jquery}"/>
    <script type="text/javascript" language="javascript" src="../static/Search.js" />

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
	<p>
	  <form method="GET" action="TextSearch" >
	    <fieldset>
	      <legend>Search for:</legend>

	      <label for="level">Level</label>
	      <select name="level" id="level">
	        <option value="text">text</option>
	        <option value="paragraph">paragraph</option>
	        <option value="sentence">sentence</option>
	        <option value="word">word</option>
	        <option value="morph">morph</option>
	      </select>

          <label for="type">Type</label>
          <select name="field" id="field">
            <option value="txt">txt</option>
            <option value="paragraph">paragraph</option>
            <option value="sentence">sentence</option>
            <option value="word">word</option>
            <option value="morph">morph</option>
          </select>

          <label for="language">Language</label>
          <select name="language" id="lang">
            <option value="english">English</option>
          </select>

        </fieldset>
        <input type="search" name="searchedstring" size="50" value="{$searched}" />
        <input  id="myButton"  type="submit" value="Submit" />
	  </form>
	</p>
  </div>
</html>
};

