<cfcomponent extends="algid.inc.resource.base.view" output="false">
	<cffunction name="login" access="public" returntype="string" output="false">
		<cfargument name="request" type="struct" default="#{}#" />
		
		<cfset var html = '' />
		
		<cfparam name="arguments.request.openID" default="" />
		
		<!--- TODO use the form cfc --->
		<cfsavecontent variable="html">
			<cfoutput>
				<form action="#variables.theURL.get()#" method="post">
					<input id="openid_identifier" type="text" name="openID" value="#arguments.request.openID#">
					<input type="submit" value="Login" />
				</form>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn html />
	</cffunction>
	
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