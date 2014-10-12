<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dyn="http://exslt.org/dynamic"
	xmlns:xalan="http://xml.apache.org/xalan"
	xmlns:InputXSLT="function.inputxslt.application"
	exclude-result-prefixes="dyn xalan InputXSLT"
>

<xsl:output
	method="xml"
	omit-xml-declaration="yes"
	encoding="UTF-8"
	indent="no"
/>

<xsl:include href="../utility/datasource.xsl"/>

<xsl:template name="traverse">
	<xsl:param name="source"/>
	<xsl:param name="target"/>
	<xsl:param name="path"/>
	<xsl:param name="node"/>

	<xsl:for-each select="$node/directory">
		<xsl:choose>
			<xsl:when test=".//file/@extension = '.xsl'">
				<xsl:call-template name="traverse">
					<xsl:with-param name="source" select="$source"/>
					<xsl:with-param name="target" select="$target"/>
					<xsl:with-param name="path"   select="concat($path, '/', @name)"/>
					<xsl:with-param name="node"   select="."/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<task type="link">
					<from>
						<xsl:value-of select="concat($target, '/', $path, '/', @name)"/>
					</from>
					<to>
						<xsl:value-of select="concat($source, '/', $path, '/', @name)"/>
					</to>
				</task>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>

	<xsl:for-each select="$node/file">
		<xsl:choose>
			<xsl:when test="@extension = '.xsl'">
				<task type="generate">
					<meta>
						<datasource_prefix>
							<xsl:value-of select="$target"/>
						</datasource_prefix>
					</meta>
					<source>
						<xsl:value-of select="concat($source, '/', $path, '/', @name, @extension)"/>
					</source>
					<target>
						<xsl:value-of select="concat($target, '/', $path)"/>
					</target>
				</task>
			</xsl:when>
			<xsl:when test="@extension = '.css'">
				<task type="link">
					<from>
						<xsl:value-of select="concat($target, '/', $path, '/', @name, @extension)"/>
					</from>
					<to>
						<xsl:value-of select="concat($source, '/', $path, '/', @name, @extension)"/>
					</to>
				</task>
			</xsl:when>
		</xsl:choose>
	</xsl:for-each>
</xsl:template>

<xsl:template match="datasource">
	<xsl:copy-of select="source"/>
	<xsl:copy-of select="meta"/>

	<tasks>
		<task type="clean">
			<path>
				<xsl:value-of select="meta/target"/>
			</path>
		</task>

		<xsl:call-template name="traverse">
			<xsl:with-param name="source" select="$root/meta/source"/>
			<xsl:with-param name="target" select="$root/meta/target"/>
			<xsl:with-param name="node"   select="source"/>
		</xsl:call-template>
	</tasks>
</xsl:template>

</xsl:stylesheet>
