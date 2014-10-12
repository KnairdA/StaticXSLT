# StaticXSLT

…is a [BuildXSLT](https://github.com/KnairdA/BuildXSLT) module implementing a static site generator in XSLT using [InputXSLT](https://github.com/KnairdA/InputXSLT).

The prime example of how this framework may be used to generate a static website is the implementation of my [personal blog](https://github.com/KnairdA/blog.kummerlaender.eu/).

## Overview:

The `src/steps` directory contains a chain of transformations which are processed by the build system as specified in `StaticXSLT.xml`.

The first of these transformations `list.xsl` traverses and lists a `source` directory containing various _levels_ depicting the different stages of the actual static site generation process as a base for all further processing.

Based on the results of the `list.xsl` transformation the next transformation `plan.xsl` schedules a number of different tasks to be processed by `process.xsl`. Examples for these tasks are cleaning a `target` directory, linking files and folders and of course generating transformation stylesheets contained within the various levels of the `source` tree.

After the various tasks are processed by `process.xsl` the results of all tasks are summarized by `summarize.xsl` to provide the user with a easy to read plain-text output.

## Usage:

The `StaticXSLT.xml` file defines a [BuildXSLT](https://github.com/KnairdA/BuildXSLT) module which may be called by _StaticXSLT_ based applications as follows:

```
<task type="module">
	<input mode="embedded">
		<datasource>
			<meta>
				<source>source</source>
				<target>target</target>
			</meta>
		</datasource>
	</input>
	<definition mode="file">[StaticXSLT.xml]</definition>
</task>
```

In this example the input tree defines both the `source` and `target` directories relative to the working directory of the `ixslt` executable which is required to make use of the external functions provided by [InputXSLT](https://github.com/KnairdA/InputXSLT). The square brackets around the `StaticXSLT.xml` filename are instructing the custom include entity resolver to resolve the given path against the include path array provided to `ixslt`. This means that _StaticXSLT_ based websites may be generated as follows:

```
ixslt --input make.xml --transformation ../BuildXSLT/build.xsl --include ../StaticXSLT
```

## Levels:

A _level_ is simply a folder within a given `source` directory which may in turn contain a arbitrary number of transformations and source documents inside subfolders. All transformations within these _levels_ are processed by the _StaticXSLT_ transformation chain which handles datasource dependency resolution and preserves the correct result path context. _Levels_ are processed according to their alphabetic order. Subfolders of _level_ directories that do not contain any XSLT stylesheets and non-stylesheet files are automatically symlinked to their appropriate target directory.

## Data Source and target resolution:

Every transformation contained in one of the levels contains a `meta` variable defining the required data sources and target paths. This information is read during task processing by the `process.xsl` transformation and used to provide each transformation with the data sources it requires and write the output to the path it desires. This definition of requirements and targets directly inside each transformation is an essential part of how this static site generation concept works.

The system currently provides a couple of different data source reading modes such as `full` for reading a complete XML file as input, `iterate` for iterating the second-level elements of a given XML source and `expression` for evaluating a arbitrary XPath expression against a given XML file. Target modes include `plain` for writing a the result into a given file at the appropriate target level and `xpath` for evaluating a XPath expression to generate the target path. This XPath evaluation functionality in combination with the `iterate` data source mode is especially helpful in situations where one wants to generate multiple output files from a single transformation such as when generating article pages or the pages of the article stream.
