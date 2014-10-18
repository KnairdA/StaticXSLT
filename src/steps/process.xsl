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

<xsl:variable name="source_tree" select="$root/source"/>

<xsl:template name="create_link">
	<xsl:param name="from"/>
	<xsl:param name="to"/>

	<xsl:value-of select="InputXSLT:external-command(
		concat('ln -sr ./', $to, ' ./', $from)
	)/self::command/@result"/>
</xsl:template>

<xsl:template name="create_directory">
	<xsl:param name="path"/>

	<xsl:value-of select="InputXSLT:external-command(
		concat('mkdir --parents ./', $path)
	)/self::command/@result"/>
</xsl:template>

<xsl:template name="clean">
	<xsl:param name="path"/>

	<xsl:value-of select="InputXSLT:external-command(
		concat('rm -r ./', $path, '; mkdir ./', $path)
	)/self::command/@result"/>
</xsl:template>

<xsl:template name="generate">
	<xsl:param name="input"/>
	<xsl:param name="transformation"/>
	<xsl:param name="target"/>

	<xsl:variable name="generation_result" select="InputXSLT:generate(
		$input,
		$transformation,
		$target
	)/self::generation"/>

	<subtask>
		<xsl:attribute name="result">
			<xsl:value-of select="$generation_result/@result"/>
		</xsl:attribute>
		<xsl:if test="$generation_result/@result = 'error'">
			<log>
				<xsl:copy-of select="$generation_result/error"/>
			</log>
		</xsl:if>

		<target>
			<xsl:value-of select="$target"/>
		</target>
	</subtask>
</xsl:template>

<xsl:template name="merge_datasource">
	<xsl:param name="main"/>
	<xsl:param name="support"/>

	<datasource>
		<xsl:copy-of select="$main"/>
		<xsl:copy-of select="$support"/>
	</datasource>
</xsl:template>

<xsl:template name="resolve_target">
	<xsl:param name="prefix"/>
	<xsl:param name="target"/>
	<xsl:param name="datasource"/>

	<xsl:choose>
		<xsl:when test="$target/@mode = 'plain'">
			<xsl:value-of select="concat($prefix, '/', $target/@value)"/>
		</xsl:when>
		<xsl:when test="$target/@mode = 'xpath'">
			<xsl:value-of select="concat($prefix, '/', dyn:evaluate($target/@value))"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:message terminate="yes">
				<xsl:text>Invalid target mode "</xsl:text>
				<xsl:value-of select="$target/@mode"/>
				<xsl:text>"</xsl:text>
			</xsl:message>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="resolve_datasource">
	<xsl:param name="prefix"/>
	<xsl:param name="datasource"/>

	<xsl:for-each select="$datasource">
		<xsl:element name="{@target}">
			<xsl:choose>
				<xsl:when test="@mode = 'full'">
					<xsl:copy-of select="InputXSLT:read-file(
						concat($prefix, '/', @source)
					)/self::file/*/*"/>
				</xsl:when>
				<xsl:when test="@mode = 'xpath'">
					<xsl:copy-of select="dyn:evaluate(@source)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="yes">
						<xsl:text>Invalid support datasource mode "</xsl:text>
						<xsl:value-of select="@mode"/>
						<xsl:text>"</xsl:text>
					</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:for-each>
</xsl:template>

<xsl:template name="compile">
	<xsl:param name="main"/>
	<xsl:param name="support"/>
	<xsl:param name="transformation"/>
	<xsl:param name="datasource_prefix"/>
	<xsl:param name="target_prefix"/>
	<xsl:param name="target"/>

	<xsl:variable name="datasource">
		<xsl:call-template name="merge_datasource">
			<xsl:with-param name="main" select="$main"/>
			<xsl:with-param name="support">
				<xsl:call-template name="resolve_datasource">
					<xsl:with-param name="prefix"     select="$datasource_prefix"/>
					<xsl:with-param name="datasource" select="$support"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="resolved_target">
		<xsl:call-template name="resolve_target">
			<xsl:with-param name="prefix"     select="$target_prefix"/>
			<xsl:with-param name="target"     select="$target"/>
			<xsl:with-param name="datasource" select="xalan:nodeset($datasource)/*[1]"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:call-template name="generate">
		<xsl:with-param name="input"          select="$datasource"/>
		<xsl:with-param name="transformation" select="$transformation"/>
		<xsl:with-param name="target"         select="$resolved_target"/>
	</xsl:call-template>
</xsl:template>

<xsl:template name="process">
	<xsl:param name="task"/>

	<xsl:variable name="transformation" select="InputXSLT:read-file($task/source)/self::file/node()"/>
	<xsl:variable name="meta"           select="$transformation/self::*[name() = 'xsl:stylesheet']/*[name() = 'xsl:variable' and @name = 'meta']"/>
	<xsl:variable name="main_source"    select="$meta/datasource[@type = 'main']"/>
	<xsl:variable name="support_source" select="$meta/datasource[@type = 'support']"/>

	<xsl:choose>
		<xsl:when test="$main_source/@mode = 'iterate'">
			<xsl:for-each select="InputXSLT:read-file(
				concat($task/meta/datasource_prefix, '/', $main_source/@source)
			)/self::file/*/entry">
				<xsl:call-template name="compile">
					<xsl:with-param name="main">
						<xsl:element name="{$main_source/@target}">
							<xsl:copy-of select="."/>
						</xsl:element>
					</xsl:with-param>
					<xsl:with-param name="support"           select="$support_source"/>
					<xsl:with-param name="transformation"    select="$transformation"/>
					<xsl:with-param name="datasource_prefix" select="$task/meta/datasource_prefix"/>
					<xsl:with-param name="target_prefix"     select="$task/target"/>
					<xsl:with-param name="target"            select="$meta/target"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="compile">
				<xsl:with-param name="main">
					<xsl:choose>
						<xsl:when test="$main_source/@mode = 'full'">
							<xsl:element name="{$main_source/@target}">
								<xsl:copy-of select="InputXSLT:read-file(
									concat($task/meta/datasource_prefix, '/', $main_source/@source)
								)/self::file/*/*"/>
							</xsl:element>
						</xsl:when>
						<xsl:when test="$main_source/@mode = 'xpath'">
							<xsl:element name="{$main_source/@target}">
								<xsl:copy-of select="dyn:evaluate($main_source/@source)"/>
							</xsl:element>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message terminate="yes">
								<xsl:text>Invalid main datasource mode "</xsl:text>
								<xsl:value-of select="$main_source/@mode"/>
								<xsl:text>"</xsl:text>
							</xsl:message>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="support"           select="$support_source"/>
				<xsl:with-param name="transformation"    select="$transformation"/>
				<xsl:with-param name="datasource_prefix" select="$task/meta/datasource_prefix"/>
				<xsl:with-param name="target_prefix"     select="$task/target"/>
				<xsl:with-param name="target"            select="$meta/target"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="task[@type = 'clean']">
	<xsl:copy>
		<xsl:attribute name="result">
			<xsl:call-template name="clean">
				<xsl:with-param name="path" select="path"/>
			</xsl:call-template>
		</xsl:attribute>
		<xsl:copy-of select="@* | node()"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="task[@type = 'generate']">
	<xsl:variable name="results">
		<xsl:call-template name="process">
			<xsl:with-param name="task" select="."/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="total_count"   select="count(xalan:nodeset($results)/subtask)"/>
	<xsl:variable name="success_count" select="count(xalan:nodeset($results)/subtask[@result = 'success'])"/>

	<xsl:copy>
		<xsl:attribute name="result">
			<xsl:choose>
				<xsl:when test="$success_count = $total_count">
					<xsl:text>success</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>error</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:copy-of select="@* | source"/>
		<xsl:copy-of select="$results"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="task[@type = 'link']">
	<xsl:copy>
		<xsl:attribute name="result">
			<xsl:call-template name="create_link">
				<xsl:with-param name="from" select="from"/>
				<xsl:with-param name="to"   select="to"/>
			</xsl:call-template>
		</xsl:attribute>
		<xsl:copy-of select="@* | node()"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="task[@type = 'directory']">
	<xsl:copy>
		<xsl:attribute name="result">
			<xsl:call-template name="create_directory">
				<xsl:with-param name="path" select="path"/>
			</xsl:call-template>
		</xsl:attribute>
		<xsl:copy-of select="@* | node()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
