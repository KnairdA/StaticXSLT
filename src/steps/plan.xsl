<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xalan="http://xml.apache.org/xalan"
	xmlns:InputXSLT="function.inputxslt.application"
	exclude-result-prefixes="xalan InputXSLT"
>

<xsl:output
	method="xml"
	omit-xml-declaration="yes"
	encoding="UTF-8"
	indent="no"
/>

<xsl:include href="../utility/datasource.xsl"/>

<xsl:variable name="source" select="$root/meta/source"/>
<xsl:variable name="target" select="$root/meta/target"/>

<xsl:template name="construct_level">
	<xsl:param name="node"/>
	<xsl:param name="path"/>

	<level>
		<node>
			<xsl:copy-of select="$node"/>
		</node>
		<path>
			<xsl:value-of select="$path"/>
		</path>
	</level>
</xsl:template>

<xsl:template match="node/file[@extension = '.xsl']">
	<xsl:variable name="base_path" select="../../path"/>

	<task type="generate">
		<meta>
			<datasource_prefix>
				<xsl:value-of select="$target"/>
			</datasource_prefix>
		</meta>
		<source>
			<xsl:value-of select="concat($source, '/', $base_path, '/', @name, @extension)"/>
		</source>
		<target>
			<xsl:value-of select="concat($target, '/', $base_path)"/>
		</target>
	</task>
</xsl:template>

<xsl:template match="node/file[@extension != '.xsl']">
	<xsl:variable name="base_path" select="../../path"/>

	<task type="link">
		<from>
			<xsl:value-of select="concat($target, '/', $base_path, '/', @name, @extension)"/>
		</from>
		<to>
			<xsl:value-of select="concat($source, '/', $base_path, '/', @name, @extension)"/>
		</to>
	</task>
</xsl:template>

<xsl:template match="node/directory">
	<xsl:variable name="base_path" select="../../path"/>

	<task type="link">
		<from>
			<xsl:value-of select="concat($target, '/', $base_path, '/', @name)"/>
		</from>
		<to>
			<xsl:value-of select="concat($source, '/', $base_path, '/', @name)"/>
		</to>
	</task>
</xsl:template>

<xsl:template match="node/directory[.//file/@extension = '.xsl']">
	<xsl:variable name="base_path" select="../../path"/>

	<xsl:variable name="new_level">
		<xsl:call-template name="construct_level">
			<xsl:with-param name="path" select="concat($base_path, '/', @name)"/>
			<xsl:with-param name="node" select="./node()"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:apply-templates select="xalan:nodeset($new_level)/level"/>
</xsl:template>

<xsl:template match="level[count(node/file | node/directory) &gt; 0]">
	<task type="directory">
		<path>
			<xsl:value-of select="concat($target, '/', path)"/>
		</path>
	</task>

	<xsl:apply-templates select="node/file | node/directory"/>
</xsl:template>

<xsl:template match="datasource">
	<xsl:copy-of select="source"/>
	<xsl:copy-of select="meta"/>

	<xsl:variable name="new_level">
		<xsl:call-template name="construct_level">
			<xsl:with-param name="node" select="source/node()"/>
		</xsl:call-template>
	</xsl:variable>

	<tasks>
		<task type="clean">
			<path>
				<xsl:value-of select="meta/target"/>
			</path>
		</task>

		<xsl:apply-templates select="xalan:nodeset($new_level)/level"/>
	</tasks>
</xsl:template>

</xsl:stylesheet>
