<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:InputXSLT="function.inputxslt.application"
	exclude-result-prefixes="InputXSLT"
>

<xsl:output
	method="xml"
	omit-xml-declaration="yes"
	encoding="UTF-8"
	indent="no"
/>

<xsl:include href="../utility/datasource.xsl"/>

<xsl:template match="entry[@type != 'directory']">
	<file name="{./name}" extension="{./extension}">
		<xsl:copy-of select="full"/>
	</file>
</xsl:template>

<xsl:template match="entry[@type  = 'directory']">
	<directory name="{./name}">
		<xsl:apply-templates select="InputXSLT:read-directory(./full)"/>
	</directory>
</xsl:template>

<xsl:template match="datasource">
	<xsl:copy-of select="meta"/>

	<source>
		<xsl:apply-templates select="InputXSLT:read-directory(meta/source)/entry"/>
	</source>
</xsl:template>

</xsl:stylesheet>
