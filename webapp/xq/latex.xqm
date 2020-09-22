module namespace latex = 'http://basex.org/modules/web-page';

declare variable $latex:open-curly := '&#123;'; (: for { :)
declare variable $latex:closed-curly := '&#125;'; (: for } :)

(:
declare variable $latex:tuwariLexicon as xs:string+ external;
declare variable $latex:tuwariTexts as xs:string+ external;
:)
declare variable $latex:tuwariLexicon := 'Tuwari20200114Lexicon';
declare variable $latex:tuwariTexts := 'Tuwari20200114Interlinear';

(:============================================================================:)
(: Concordance :)
(:============================================================================:)
declare
  %rest:path("/concordance2pdf/{$entryid}")
  %rest:GET
  %output:method("html")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function latex:concordance2pdf($entryid as xs:string)
  as element(html) {
	 <html>
	 {
	  let $entry := collection($latex:tuwariLexicon)/lift/entry[@id = $entryid]
	  let $form := $entry/lexical-unit/form/text/text()
	 let $tex := latex:concordance2tex($entryid)
	 let $filename := concat("kwic_", $form, ".tex")
	 let $file := file:write-text($filename, $tex)
	 let $exe := proc:execute("pdflatex", $filename)
	 return
	 <text>Look for the text {$filename} in Basex running directory.</text>
	}
	</html>
};

declare
  %rest:path("/concordance2tex/{$entryid}")
  %rest:GET
  %output:method("text")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function latex:concordance2tex($entryid as xs:string)
  as item()+ {
			let $entry := collection($latex:tuwariLexicon)/lift/entry[@id = $entryid]
			let $form := $entry/lexical-unit/form/text/text()
			let $order := if ($entry/@order) then data($entry/@order) else "0"
			let $sentences := collection($latex:tuwariTexts)/document/interlinear-text/paragraphs/paragraph/phrases/word[words/word[morphemes/morph[item[@type="cf"] = $form]][(morphemes/morph[item[@type="cf"] = $form and not(item[@type="hn"])] or morphemes/morph[item[@type="cf"] = $form and item[@type="hn"] = $order])]]
			let $nsentences := count($sentences)
			return
  concat(
  
			latex:preamble(),
			"\title{",
			concat("Kwic: \textit{", latex:latex-escape($form), "} (", $nsentences, " occurrences)")
			,
			"}&#10;",
			"\begin{document}
			\maketitle
			%\tableofcontents
			",
			string-join( for $sentence in $sentences
			return string-join(latex:sentence2texInterlinearXSLT($sentence))
			),
			"\end{document}"
	)
};

(:============================================================================:)
(: Text :)
(:============================================================================:)

declare
  %rest:path("/text2tex/{$textid}")
  %rest:GET
  %output:method("text")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function latex:text2tex($textid as xs:string)
  as item()+ {

	 let $textnode := collection($latex:tuwariTexts)/document/interlinear-text[item[@type = 'title-abbreviation'] = $textid]
	 let $sentences := $textnode/paragraphs/paragraph/phrases/word
     let $nsentence := count($sentences)
	 return
  concat(
  
			latex:preamble(),
			"\title{",
			concat("Text: ", $textid)
			,
			"}&#10;",
			"\begin{document}
			\maketitle
			%\tableofcontents
			",
			string-join( for $sentence in $sentences
			return string-join(latex:sentence2texInterlinearXSLT($sentence))
			),
			"\end{document}"
	)
};

declare
  %rest:path("/text2pdf/{$textid}")
  %rest:GET
  %output:method("html")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function latex:text2pdf($textid as xs:string)
  as element(html) {
	 <html>
	 {
	 let $textnode := collection($latex:tuwariTexts)/document/interlinear-text[item[@type = 'title-abbreviation'] = $textid]
	 let $phrases := $textnode/paragraphs/paragraph/phrases/word
     let $nphrases := count($phrases)
	 let $tex := concat(
	   latex:preamble(),
	   "\title{",
	   latex:latex-escape($textnode/item[@type="title"]/text())
	   ,
	   "}&#10;",
	   "\begin{document}
\maketitle
%\tableofcontents
",
       string-join( for $sentence in $textnode/paragraphs/paragraph/phrases/word
		 return string-join(latex:sentence2texInterlinear($sentence))
	   ),
	   "\end{document}"
	)
	let $filename := concat($textid, ".tex")
	let $file := file:write-text($filename, $tex)
	let $exe := proc:execute("pdflatex", $filename)
	return
	  <text>Look for the text {$filename} in Basex running directory. Number of 
sentences: {$nphrases} ; number of text: {count($textnode)}</text>

	}
	</html>
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : @return 
 :)
declare
  %rest:path("TeX")
  %output:method("text")
  %output:omit-xml-declaration("yes")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function latex:convert-tex()
  as item()+
{
    (
	latex:preamble(),
	"\begin{document}
\textbf{Démonstratifs}
\tableofcontents",


	    for $occurrences in collection($latex:tuwariTexts)/document/interlinear-text/paragraphs/paragraph/phrases/word/words/word/morphemes/morph[starts-with(item[@type="gls"], "DEM") or starts-with(item[@type="gls"], "this") or item[@type="msa"] = "dem"]
		let $type := $occurrences/item[@type="cf" and @lang="tww"]/text()
	    let $order := if ($occurrences/item[@type="hn"]) then ($occurrences/item[@type="hn"]/text()) else ()
		group by $type, $order
		order by $type, $order
		return (
		  "&#10;\section{",
		  $type,
		  if ($order) then ("$_&#123;", $order, "&#125;$") else (),
		  " ; (",
		  count($occurrences),
		  " occ.)}&#10;",
		  for $occ in $occurrences
		  let $parent_phrase := $occ/parent::morphemes/parent::word/parent::words/parent::word
		  return 
		    latex:sentence2texInterlinear($parent_phrase)
		),
	"\end{document}"
	)
};

(:============================================================================:)
(: Sentence :)
(:============================================================================:)

(:
 : Convert a sentence in tex interlinear.
 : used for every sentence in the corpus.
 :)
declare
  %rest:path("/sentence2tex/{$textid}/{$phraseid}")
  %output:method("text")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function latex:sentence2tex(
      $textid as xs:string, $phraseid as xs:string
      )
      as element(Q{http://www.w3.org/1999/xhtml}html)
{
	 <html:html xmlns:html="http://www.w3.org/1999/xhtml">
{
	 let $phrasenode := collection($latex:tuwariTexts)/document/interlinear-text[item[@type='title-abbreviation'] = $textid]/paragraphs/paragraph/phrases/word[item[@type = 'segnum'] = $phraseid]
	 return latex:sentence2texInterlinearXSLT($phrasenode)
	 }
	</html:html>
};


(:
 : Convert a sentence in plain text.
 : used for every sentence in the corpus.
 :)
declare
  %rest:path("/sentence2plaintext/{$textid}/{$phraseid}")
  %output:method("html")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function latex:sentence2plaintext(
      $textid as xs:string, $phraseid as xs:string
      )
      as element(Q{http://www.w3.org/1999/xhtml}html)
{
<html:html xmlns:html="http://www.w3.org/1999/xhtml">
<pre>
{
    let $phrase := collection($latex:tuwariTexts)/document/interlinear-text[item[@type='title-abbreviation'] = $textid]/paragraphs/paragraph/phrases/word[item[@type = 'segnum'] = $phraseid]
    let $fields := ("txt", "cf", "hn", "gls")
    let $mysequence := <phrase>{
      for $field in $fields
      return element {$field} {
        for $word in $phrase/words/word
        return 
          <l>{string-length(string-join($word/morphemes/morph/item[@type=$field]/text(), "-"))}</l>
      }
    }
    </phrase>
    let $numberofword := count($mysequence/*[1]/l)
    let $maxlength := (
      for $i in (1 to $numberofword)
      return max (
        for $field in $fields return $mysequence/*[local-name()=$field]/l[$i]
      )
    )
    for $field in $fields
    return
	  concat(
	  string-join(
      for $i in (1 to $numberofword)
      let $form := string-join($phrase/words/word[$i]/morphemes/morph/item[@type=$field]/text(), "-")
      let $shortage := $maxlength[$i] - $mysequence/*[local-name()=$field]/l[$i]
      let $padding := string-join((for $i in 1 to xs:integer($shortage) return " "), '')
      let $formattedform := if ($shortage > 0) then concat($form, $padding) else $form
      return concat($formattedform, " ")
	  )
	  , "
"
	  )
	 }
</pre>
	</html:html>
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :)
(:Dictionary :)
(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :)

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : PrintableDictionary With XLST
 : @return HTML page
 :)
declare
  %rest:path("/PrintableDictionaryXLST")
  %output:method("xml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function latex:printable-dictionary-xslt()
    as element(Q{http://www.w3.org/1999/xhtml}html)
{
	<html:html xmlns:html="http://www.w3.org/1999/xhtml">
	<html:body>{

	let $tex := xslt:transform-text(collection($latex:tuwariLexicon)/lift, "file://../xslt/lift2latex.xsl")
	let $filename := concat($latex:tuwariLexicon, ".tex")
	let $file := file:write-text($filename, $tex)
	let $exe := proc:execute("xelatex ", $filename)
	return
		<text>Look for the text {$filename} in Basex running directory.</text>
    }
	</html:body>
	</html:html>
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 : PrintableDictionary
 : @return HTML page
 :)
declare
  %rest:path("/PrintableDictionary")
  %output:method("xml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function latex:printable-dictionary()
    as element(Q{http://www.w3.org/1999/xhtml}html)
{
	<html:html xmlns:html="http://www.w3.org/1999/xhtml">
	<html:body>{

	    let $pdf := string-join(
		    for $entry in collection($latex:tuwariLexicon)/lift/entry
			let $form := $entry/lexical-unit/form/text
			let $order := if (data($entry/@order)) then data($entry/@order) else "0"
			let $morphtype := data($entry/trait/@value)
			let $firstLetter := fn:substring($form, 1, 1)
			order by $form
			group by $firstLetter
			return 
			    string-join((
				    "\section*{",
				    $firstLetter,
				    "}&#10;",
				    "\begin{multicols}{2}&#10;",
				    for $e in $entry
				    return latex:make-latex-entry($e),
					"\end{multicols}&#10;"
				))
	    )
		(: sortie dans le répertoire BaseX :)
			let $filename := "TuwariDictionary.tex"
			let $file := file:write-text($filename, $pdf)
			return <html:a href="{$filename}">document</html:a>
    }
	</html:body>
	</html:html>
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 :)
declare function latex:make-latex-entry ($entry as node()) as xs:string
{
string-join((
    "\entry{",
	$entry/lexical-unit/form/text/text(),
	"}&#10;",
	"(",
	data($entry/trait[@name="morph-type"]/@value),
	")",
	"&#10;",
	for $sense in $entry/sense return latex:make-latex-sense($sense),
	"&#10;"
))
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 :)
declare function latex:make-latex-sense ($sense as node()) as xs:string
{
latex:latex-escape(string-join((
    count($sense/preceding-sibling::sense) + 1,
	"&#10;",
	if ($sense/grammatical-info) then concat(" (\graminfo{", data($sense/grammatical-info/@value),"})") else (),
	" \senseen{",
	$sense/gloss[@lang="en"],
	"}",
	"&#10;",
	if ($sense/gloss[@lang="tpi"]/text()) then concat(	"\sensetpi{", latex:latex-escape($sense/gloss[@lang="tpi"]/text()), "}") else (),
	if ($sense/trait[@name="semantic-domain-ddp4"]) then concat(" (", string-join(data($sense/trait[@name="semantic-domain-ddp4"]/@value)),")") else ()

)))
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :)
(:COMMON:)
(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :)


declare
  function latex:sentence2texInterlinearXSLT($sentence as element(word))
  as item()+
{
   let $tex := xslt:transform-text($sentence, "../xslt/emeld2latex.xsl", map {"displayphraseIdAsSection":false()})
(:, "displayTextIdInPreamble":true():)
   return(data($tex))
};

declare
  function latex:sentence2texInterlinear($sentence as element(word))
  as item()+
{
	(
	"&#10;",
	"\ex",
	"&#10;",
	"\begingl[glstyle=nlevel, everyglft=\it]", (:,everyglft=\bf:)
	"&#10;",
	"\glpreamble ",
	latex:latex-escape($sentence/parent::phrases/parent::paragraph/parent::paragraphs/parent::interlinear-text/item[@type="title-abbreviation" and @lang="en"]),
    "§",
	latex:latex-escape($sentence/item[@type="segnum"]/text()),
	" \endpreamble",
	"&#10;",
	for $word in $sentence/words/word
	return
	(
	for $morph in $word/morphemes/morph
	let $txt := $morph/item[@type="txt"]/text()
	return 
        replace($txt,'_', '\\_')
	,
	"["
	,
	for $morph in $word/morphemes/morph
	let $cf := $morph/item[@type="cf"]/text()
	let $hn := if ($morph/item[@type="hn"]) then ("$_&#123;", $morph/item[@type="hn"]/text(), "&#125;$") else ()
	return string-join(
	    (replace($cf, '_', '\\_'),
	    $hn
	    ), "")
	,
	"/"
	,
	for $morph in $word/morphemes/morph
	let $gls := $morph/item[@type="gls"]/text()
    let $glsSC := if (matches($gls, '^[-A-Z0-9_]+$')) then (concat("\textsc{", lower-case(data($gls)), "}")) else ($gls)
	return 
        replace($glsSC,'_', '\\_')
	,
	"]"
	,
	"&#10;"
	),
	if ($sentence/item[@type="gls" and @lang="en"]/text()) then("\glft ", $sentence/item[@type="gls" and @lang="en"]/text(), "&#10;") else (),
	if ($sentence/item[@type="gls" and @lang="tpi"]/text()) then("\glft tpi: ", $sentence/item[@type="gls" and @lang="tpi"]/text(), "&#10;") else (),
	"\endgl",
	"&#10;",
	"\xe",
	"&#10;"
	)
};

declare function latex:preamble() as xs:string {
"\documentclass[]{article}
\usepackage[a4paper,margin=1cm]{geometry}
\usepackage{expex}
\usepackage[T3,T1]{fontenc}
\usepackage[utf8]{inputenc}
\DeclareUnicodeCharacter{294}{?}
\DeclareUnicodeCharacter{200E}{ }
\usepackage{lmodern}
\usepackage{hyperref}

"
};

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :)
(:UTILS :)
(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :)


declare
  function latex:latex-escape($text as xs:string)
  as xs:string {
  replace(
    replace(
      replace($text, '_', '\\_'),
	  '&amp;', '\\&amp;'
    ),
	'#', '\\#'
  )
	(: replace($arg, '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1') :)
};



(:
declare
  function latex:latex-escape($text as xs:string)
  as xs:string {
  let escape := array {
  ('\\',    '\\textbackslash'),
  ('&amp;', '\\&amp;'),
  ('%',     '\\%'),
  ('$',     '\\$'),
  ('#',     '\\#'),
  ('_',     '\\_'),
  ('{',     '\\{'),
  ('}',     '\\}'),
  ('~',     '\\textasciitilde'),
  ('^',     '\\textasciicircum'),
  ('[',     '\lbrack'),
  ('[',     '\rbrack'
  }

  return latex:latex-escape-rec($text, $escape, 0)
}

declare latex:latex-escape-rec($text as xs:string, $escape as array, i as xs:integer) as xs:string {
  let $escaped := replace($text, $escape(i)(0), $escape(i)(1))
  if ($i + 1 < array:size($escape)
  then  return $escaped
  else return latex:latex-escape-rec($escaped, $escape, i + 1)
}

:)
