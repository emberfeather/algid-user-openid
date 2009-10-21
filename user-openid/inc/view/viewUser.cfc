<cfcomponent extends="algid.inc.resource.base.view" output="false">
	<cffunction name="login" access="public" returntype="string" output="false">
		<cfargument name="request" type="struct" default="#{}#" />
		
		<cfset var html = '' />
		<cfset var theURL = '' />
		
		<cfparam name="arguments.request.openID" default="" />
		
		<cfset theURL = variables.transport.requestSingletons.getUrl() />
		
		<!--- TODO use the form cfc --->
		<cfsavecontent variable="html">
			<cfoutput>
				<form action="#theURL.get()#" method="post">
					<input id="openid_identifier" type="text" name="openID" value="#arguments.request.openID#">
					<input type="submit" value="Login" />
				</form>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn html />
	</cffunction>
	
	<cffunction name="list" access="public" returntype="string" output="false">
		<cfargument name="data" type="any" required="true" />
		<cfargument name="options" type="struct" default="#{}#" />
		
		<cfset var datagrid = '' />
		<cfset var i18n = '' />
		
		<cfset i18n = variables.transport.applicationSingletons.getI18N() />
		<cfset datagrid = variables.transport.applicationTransients.getDatagrid(i18n, variables.transport.locale) />
		
		<!--- TODO Remove --->
		<cfdump var="#arguments.data#" />
		<cfabort />
		
		<cfset datagrid.addColumn({
				key = 'permission',
				label = 'Permission'
			}) />
		
		<cfreturn datagrid.toHTML( arguments.data, arguments.options ) />
	</cffunction>
</cfcomponent>