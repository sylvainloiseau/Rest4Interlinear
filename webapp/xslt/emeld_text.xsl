<!--
	<xsl:choose>
	<xsl:when test="$textids = 'abc'">
	<xsl:variable name="textids_set" select="tokenize($textids, '\s+')" />
	<xsl:variable name="textsnumber" select="count($textids_set)" />
	<xsl:for-each select="$textids_set">
	<xsl:variable name="textid" select="." />
	<xsl:apply-templates select="/document/interlinear-text[./item[@type='title-abbreviation'] = $textid]" />
	</xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
	<xsl:variable name="textsnumber" select="count(/document/interlinear-text)" />
	<xsl:apply-templates />
	</xsl:otherwise>
	</xsl:choose>
-->
