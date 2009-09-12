<cfcomponent output="false">
	<cfset this.name = 'plugin-user-openid' />
	<cfset this.applicationTimeout = createTimeSpan(1, 0, 0, 0) />
	<cfset this.clientManagement = false />
	<cfset this.sessionManagement = false />
	
	<!--- Set the mappings --->
	<cfset variables.mappingBase = getDirectoryFromPath( getCurrentTemplatePath() ) />
	
	<cfset this.mappings['/algid'] = variables.mappingBase & 'algid' />
	<cfset this.mappings['/cf-compendium'] = variables.mappingBase & 'cf-compendium' />
	<cfset this.mappings['/mxunit'] = variables.mappingBase & 'mxunit' />
	<cfset this.mappings['/plugins'] = variables.mappingBase />
	<cfset this.mappings['/test'] = variables.mappingBase & 'test' />
	<cfset this.mappings['/varscoper'] = variables.mappingBase & 'varscoper' />
</cfcomponent>