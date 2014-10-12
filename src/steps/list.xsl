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

<xsl:template name="list">
	<xsl:param name="base"/>

	<xsl:for-each select="InputXSLT:read-directory($base)/entry">
		<xsl:choose>
			<xsl:when test="@type = 'directory'">
				<directory name="{./name}">
					<xsl:call-template name="list">
						<xsl:with-param name="base" select="./full"/>
					</xsl:call-template>
				</directory>
			</xsl:when>
			<xsl:otherwise>
				<file name="{./name}" extension="{./extension}">
					<xsl:copy-of select="full"/>
				</file>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:template>

<xsl:template match="datasource">
	<xsl:copy-of select="meta"/>

	<source>
		<xsl:call-template name="list">
			<xsl:with-param name="base" select="meta/source"/>
		</xsl:call-template>
	</source>
</xsl:template>

</xsl:stylesheet>
