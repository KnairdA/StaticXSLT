<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

<xsl:output
	method="text"
	omit-xml-declaration="yes"
	encoding="UTF-8"
	indent="no"
/>

<xsl:template match="task[@result = 'error']">
	<xsl:text>&#xa;Error #</xsl:text>
	<xsl:value-of select="position()"/>
	<xsl:text>: </xsl:text>

	<xsl:choose>
		<xsl:when test="@type = 'generate'">
			<xsl:for-each select="subtask[@result = 'error']">
				<xsl:text>Generation of "</xsl:text>
				<xsl:value-of select="target"/>
				<xsl:text>" failed.</xsl:text>

				<xsl:for-each select="log/error">
					<xsl:text>&#xa;</xsl:text>
					<xsl:value-of select="."/>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:when>
		<xsl:when test="@type = 'link'">
			<xsl:text>Link from "</xsl:text>
			<xsl:value-of select="from"/>
			<xsl:text>" to "</xsl:text>
			<xsl:value-of select="to"/>
			<xsl:text>" failed.</xsl:text>
		</xsl:when>
		<xsl:when test="@type = 'clean'">
			<xsl:text>Cleaning of "</xsl:text>
			<xsl:value-of select="path"/>
			<xsl:text>" failed.</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="."/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="datasource">
	<xsl:variable name="total_count"   select="count(task)"/>
	<xsl:variable name="success_count" select="count(task[@result = 'success'])"/>

	<xsl:text>Tasks processed:  </xsl:text>
	<xsl:value-of select="$total_count"/>
	<xsl:text>&#xa;</xsl:text>
	<xsl:text>Tasks successful: </xsl:text>
	<xsl:value-of select="$success_count"/>
	<xsl:text>&#xa;</xsl:text>

	<xsl:text>▶ Generation </xsl:text>
	<xsl:choose>
		<xsl:when test="$total_count = $success_count">
			<xsl:text>successful</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>failed</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:text>.&#xa;</xsl:text>

	<xsl:apply-templates select="task[@result = 'error']"/>
</xsl:template>

</xsl:stylesheet>
