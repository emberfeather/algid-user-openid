<cfcomponent extends="algid.inc.resource.plugin.configure" output="false">
	<cffunction name="configureSession" access="public" returntype="void" output="false">
		<cfargument name="theApplication" type="struct" required="true" />
		<cfargument name="newSession" type="struct" required="true" />
		
		<cfset var temp = '' />
		
		<!--- Add the user singleton --->
		<cfset temp = arguments.newSession.factories.transient.getUser(arguments.theApplication.managers.singleton.getI18N()) />
		
		<cfset arguments.newSession.managers.singleton.setUser(temp) />
	</cffunction>
</cfcomponent>