<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">

<xsl:output encoding="UTF-8" method="text" />

<xsl:param name="textids" select="''"/> <!-- 2014T2 2014T3-->
<xsl:param name="displayphraseIdAsSection" select="true()" as="xs:boolean"  />
<xsl:param name="displaywordstring" select="true()" as="xs:boolean" />
<xsl:param name="displaywordcat" select="true()" as="xs:boolean" />
<xsl:param name="displaywordgloss" select="true()" as="xs:boolean" />
<xsl:param name="displaypreamble" select="true()" as="xs:boolean" />
<xsl:param name="displayTextIdInPreamble" select="true()" as="xs:boolean"/>
<xsl:param name="latexsectionningfortext" select="'section'" />
<xsl:param name="latexsectionningforsentence" select="'subsection'"/>

<!--
A string two may inserted between two morphems of a word
that are not affixes (for instance in a compound),
in order to have the two morphems without space between them.
-->
<xsl:param name="lexem-separator" select="'{ }'"/>

<xsl:template match="/document">
	<xsl:call-template name="preamble" />
	<xsl:apply-templates select="/document/interlinear-text" mode="corpus"/>
	<xsl:call-template name="end_document" />
</xsl:template>

<xsl:template match="interlinear-text" mode="corpus">
	<xsl:call-template name="make_title">
		<xsl:with-param name="text" select="." />
	</xsl:call-template>
	<xsl:apply-templates select="." mode="text" />
</xsl:template>

<xsl:template match="interlinear-text" mode="text">
	<xsl:apply-templates select="paragraphs/paragraph/phrases/word" />
</xsl:template>

<xsl:template match="word[words]">
	<xsl:variable name="me" select="." />

	<xsl:if test="$displayphraseIdAsSection">
		<xsl:call-template name="make_command">
			<xsl:with-param name="command_name" select="$latexsectionningforsentence" />
			<xsl:with-param name="command_text" select="./item[@type='segnum']/text()" />
		</xsl:call-template>
		<xsl:text>&#10;</xsl:text>
	</xsl:if>

	<xsl:text>\ex&#10;\begingl&#10;</xsl:text>
        <xsl:if test="$displaypreamble">
          <xsl:text>\glpreamble </xsl:text>
          <xsl:text> \corpusreference{ </xsl:text>
          <xsl:value-of>
            <xsl:call-template name="escape_for_latex">
              <xsl:with-param
                name="string"
                select="./parent::word/parent::phrases/parent::paragraph/parent::paragraphs/parent::interlinear-text/item[@type='title-abbreviation' and @lang='en']"/>
            </xsl:call-template>
          </xsl:value-of>
          <xsl:text>}{</xsl:text>
          <xsl:value-of>
            <xsl:call-template name="escape_for_latex">
              <xsl:with-param
                name="string"
                select="./item[@type='segnum']/text()"/>
            </xsl:call-template>
          </xsl:value-of>
          <xsl:text>}//&#10;</xsl:text>
	</xsl:if>

	<xsl:call-template name="make_morphem_tier">
		<xsl:with-param name="phrase" select="$me"/>
		<xsl:with-param name="tiername" select="'gla'"/>
		<xsl:with-param name="attributevalue" select="'txt'"/>
	</xsl:call-template>
	
	<xsl:text>\glb </xsl:text>
	<xsl:for-each select="words/word">
		<xsl:choose>
		<xsl:when test="item[@type='punct']">
		<xsl:value-of select="item[@type='punct']/text()" />
		</xsl:when>
		<xsl:otherwise>
		<xsl:for-each select="morphemes/morph">
			    <xsl:if 
				test="
				preceding-sibling::morph
				and
				not(ends-with(preceding-sibling::morph[1]/item[@type='cf']/text(), '-'))
				and
				not(starts-with(item[@type='cf']/text(), '-'))
				">
				   <xsl:value-of select="$lexem-separator" />
			    </xsl:if>

		    <xsl:call-template name="escape_for_latex">
				<xsl:with-param
					name="string"
					select="item[@type='cf']/text()"/>
			</xsl:call-template>
			<xsl:if test="item[@type='hn']">
				<xsl:text>$_{</xsl:text>
				<xsl:value-of select="item[@type='hn']/text()"/>
				<xsl:text>}$</xsl:text>
			</xsl:if>
		</xsl:for-each>
				</xsl:otherwise>
</xsl:choose>
		<xsl:text> </xsl:text>
	</xsl:for-each>
	<xsl:text>//&#10;</xsl:text>

	<xsl:call-template name="make_morphem_tier">
		<xsl:with-param name="phrase" select="."/>
		<xsl:with-param name="tiername" select="'glc'"/>
		<xsl:with-param name="attributevalue" select="'gls'"/>
	</xsl:call-template>

	<!--
		<xsl:call-template name="make_morphem_tier">
		<xsl:with-param name="phrase" select="."/>
		<xsl:with-param name="tiername" select="'gld'"/>
		<xsl:with-param name="attributevalue" select="'msa'"/>
		</xsl:call-template>

		<xsl:if test="$displaywordstring">
		<xsl:call-template name="make_word_tier">
		<xsl:with-param name="tiername" select="'glwordtext'"/>
		<xsl:with-param name="attributevalue" select="'txt'"/>
		</xsl:call-template>
		</xsl:if>

		<xsl:if test="$displaywordcat">
		<xsl:call-template name="make_word_tier">
		<xsl:with-param name="tiername" select="'glwordcat'"/>
		<xsl:with-param name="attributevalue" select="'pos'"/>
		</xsl:call-template>
		</xsl:if>

		<xsl:if test="$displaywordgloss">
		<xsl:call-template name="make_word_tier">
		<xsl:with-param name="tiername" select="'glwordgloss'"/>
		<xsl:with-param name="attributevalue" select="'gls'"/>
		</xsl:call-template>
		</xsl:if>
	-->

		<xsl:choose>
			<xsl:when test="item[@type='gls' and @lang='en']/text()">
			<!-- Can take the first one only -->
			<xsl:for-each select="item[@type='gls' and @lang='en'][1]/text()">
				<xsl:text>\glft </xsl:text>	
				<xsl:value-of>
					<xsl:call-template name="escape_for_latex">
						<xsl:with-param
							name="string"
							select="."/>
					</xsl:call-template>
				</xsl:value-of>
				<xsl:text>//&#10;</xsl:text>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="item[@type='gls' and @lang='tpi']/text()">
			<!-- Can take the first one only -->
				<xsl:for-each select="item[@type='gls' and @lang='en'][1]/text()">
					<xsl:text>\glft </xsl:text>	
					<xsl:value-of>
						<xsl:call-template name="escape_for_latex">
							<xsl:with-param
								name="string"
								select="."/>
						</xsl:call-template>
					</xsl:value-of>
					<xsl:text>//&#10;</xsl:text>
				</xsl:for-each>
				</xsl:if>	
			</xsl:otherwise>
		</xsl:choose>

		<xsl:text>\endgl&#10;</xsl:text>
		<xsl:text>\xe&#10;</xsl:text>

	</xsl:template>

	<xsl:template name="make_morphem_tier">
		<xsl:param name="phrase" />
		<xsl:param name="tiername" />
		<xsl:param name="attributevalue" />
		<xsl:text>\</xsl:text>
		<xsl:value-of select="$tiername" />
		<xsl:text> </xsl:text>
		<xsl:for-each select="$phrase/words/word">
		<xsl:choose>
		<xsl:when test="item[@type='punct']">
		<xsl:value-of select="item[@type='punct']/text()" />
		</xsl:when>
		<xsl:otherwise>
		
			<xsl:for-each select="morphemes/morph">
			    <xsl:if 
				test="
				preceding-sibling::morph
				and
				not(ends-with(preceding-sibling::morph[1]/item[@type=$attributevalue]/text(), '-'))
				and
				not(starts-with(item[@type=$attributevalue]/text(), '-'))
				">
				   <xsl:value-of select="$lexem-separator" />
			    </xsl:if>
				<xsl:variable name="value">				
				<xsl:value-of>
					<xsl:call-template name="escape_for_latex">
						<xsl:with-param
							name="string"
							select="item[@type=$attributevalue]/text()"/>
					</xsl:call-template>
				</xsl:value-of>
				</xsl:variable>
				<xsl:value-of select="if (matches($value, 
				'^[-A-Z0-9_\.\?]+$')) then concat('\textsc{', 
				lower-case(data($value)), '}')  else $value" />
			</xsl:for-each>
		</xsl:otherwise>
		</xsl:choose>
			<xsl:text> </xsl:text>
		</xsl:for-each>
		<xsl:text>//&#10;</xsl:text>
	</xsl:template>

	<xsl:template name="make_word_tier">
		<xsl:param name="tiername" />
		<xsl:param name="attributevalue" />
		<xsl:text>\</xsl:text>
		<xsl:value-of select="$tiername" />
		<xsl:text> </xsl:text>
		<xsl:for-each select="words/word">
			<xsl:call-template name="escape_for_latex">
				<xsl:with-param
					name="string"
					select="item[@type=$attributevalue]/text()"/>
			</xsl:call-template>
			<xsl:text> </xsl:text>
		</xsl:for-each>
		<xsl:text>//&#10;</xsl:text>
	</xsl:template>

	<xsl:template name="escape_for_latex">
		<xsl:param name="string" />
		<xsl:call-template name="escape_for_latex2">
				<xsl:with-param
					name="string"
					select="replace($string, '_', '\\_')"/>
		</xsl:call-template>
		<!--
		 | <xsl:value-of select="replace($string, '_', '\\_')"/>    
		-->
	</xsl:template>

	<xsl:template name="escape_for_latex2">
		<xsl:param name="string" />
		<xsl:value-of select="replace($string, '\[', '\\lbrack ')"/>	
	</xsl:template>
	
				<!--
				 |     <xsl:value-of select="if (matches($value, 
				 | '^[-A-Z0-9_\.\?]+$')) then concat('\textsc{', 
				 | lower-case(data($value)), '}')  else $value" />
				-->

	
	<xsl:template name="make_title">
		<xsl:param name="text" />

		<xsl:variable name="title">
			<xsl:call-template name="escape_for_latex">
				<xsl:with-param
					name="string"
					select="$text/item[@type='title']"/>
			</xsl:call-template>
			<xsl:text> (</xsl:text>
			<xsl:call-template name="escape_for_latex">
				<xsl:with-param
					name="string"
					select="$text/item[@type='title-abbreviation']"/>
			</xsl:call-template>
			<xsl:text>)</xsl:text>	
		</xsl:variable>

		<xsl:call-template name="make_command">
			<xsl:with-param name="command_name" select="$latexsectionningfortext" />
			<xsl:with-param name="command_text" select="$title" />
		</xsl:call-template>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>

	<xsl:template name="make_command">
		<xsl:param name="command_name" />
		<xsl:param name="command_text" />
		<xsl:text>\</xsl:text>
		<xsl:value-of select="$command_name"/>
		<xsl:text>{</xsl:text>
		<xsl:value-of select="$command_text"/>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template name="preamble">
		<xsl:text>%&amp;xelatex
			\documentclass[12pt]{article}
			\usepackage{geometry}
			\geometry{a4paper, top=20mm, left=30mm, right=20mm, bottom=20mm, headsep=14mm, footskip=12mm}
			\usepackage{expex}
			\defineglwlevels{d,wordtext,wordcat,wordgloss} \lingset{everyglwordcat=\footnotesize,aboveglwordcatskip=-.5ex}
			\begin{document}
	</xsl:text>
</xsl:template>

<xsl:template name="end_document">
	<xsl:text>
		\end{document}
	</xsl:text>
</xsl:template>


</xsl:stylesheet>
