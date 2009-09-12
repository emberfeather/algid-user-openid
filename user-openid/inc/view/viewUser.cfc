<cfcomponent extends="algid.inc.resource.base.view" output="false">
	<cffunction name="list" access="public" returntype="string" output="false">
		<cfargument name="items" type="query" required="true" />
		<cfargument name="filter" type="struct" required="true" />
		<cfargument name="options" type="struct" default="#{}#" />
		
		<cfset var html = '' />
		
		<!--- TODO Set default options for the datagrid --->
		<cfset html = super.list( argumentCollection = arguments ) />
		
		<cfreturn html />
	</cffunction>
</cfcomponent>