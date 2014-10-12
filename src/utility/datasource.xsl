<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

<xsl:output
	method="xml"
	omit-xml-declaration="no"
	encoding="UTF-8"
	indent="no"
/>

<xsl:variable name="root" select="/datasource"/>

<xsl:template match="/">
	<datasource>
		<xsl:apply-templates />
	</datasource>
</xsl:template>

<xsl:template match="text()|@*"/>

</xsl:stylesheet>
