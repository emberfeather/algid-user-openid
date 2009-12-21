<cfcomponent extends="plugins.user.inc.service.servUser" output="false">
	<cffunction name="createUser" access="public" returntype="void" output="false">
		<cfargument name="currUser" type="component" required="true" />
		<cfargument name="user" type="component" required="true" />
		
		<cfset var eventLog = '' />
		<cfset var results = '' />
		
		<!--- Get the event log from the transport --->
		<cfset eventLog = variables.transport.theApplication.managers.singleton.getEventLog() />
		
		<!--- TODO Check Permissions --->
		
		<cfquery datasource="#variables.datasource.name#" result="results">
			INSERT INTO "#variables.datasource.prefix#user"."user"
			(
				"identifier"
			) VALUES (
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.user.getIdentifier()#" />
			)
		</cfquery>
		
		<!--- Query the userID --->
		<!--- TODO replace this with the new id from the insert results --->
		<cfquery name="results" datasource="#variables.datasource.name#">
			SELECT "userID"
			FROM "#variables.datasource.prefix#user"."user"
			WHERE "identifier" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.user.getIdentifier()#" />
		</cfquery>
		
		<cfset arguments.user.setUserID( results.userID ) />
		
		<!--- Log the create event --->
		<cfset eventLog.logEvent('user-openid', 'userCreate', 'Created the ''' & arguments.user.getIdentifier() & ''' user.', arguments.currUser.getUserID(), arguments.user.getUserID()) />
	</cffunction>
	
	<cffunction name="discoverUser" access="public" returntype="string" output="false">
		<cfargument name="request" type="struct" required="true" />
		
		<cfset var result = '' />
		
		<!--- TODO Discover the final identity for the openID provider --->
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="readUser" access="public" returntype="component" output="false">
		<cfargument name="userID" type="numeric" required="true" />
		
		<cfset var i18n = '' />
		<cfset var results = '' />
		<cfset var user = '' />
		
		<cfset i18n = variables.transport.theApplication.managers.singleton.getI18N() />
		
		<cfquery name="results" datasource="#variables.datasource.name#">
			SELECT "userID", "identifier"
			FROM "#variables.datasource.prefix#user"."user"
			WHERE "userID" = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#" />
		</cfquery>
		
		<cfset user = variables.transport.theApplication.factories.transient.getModUserForUser(i18n, variables.transport.theSession.managers.singleton.getSession().getLocale()) />
		
		<cfset user.deserialize(results) />
		
		<cfreturn user />
	</cffunction>
	
	<cffunction name="readUsers" access="public" returntype="query" output="false">
		<cfargument name="filter" type="struct" default="#{}#" />
		
		<cfset var results = '' />
		
		<cfquery name="results" datasource="#variables.datasource.name#">
			SELECT "userID", "identifier"
			FROM "#variables.datasource.prefix#user"."user"
			WHERE 1=1
			
			<cfif structKeyExists(arguments.filter, 'identifier')>
				and "identifier" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filter.user#" />
			</cfif>
			
			ORDER BY "identifier" ASC
		</cfquery>
		
		<cfreturn results />
	</cffunction>
	
	<cffunction name="verifyUser" access="public" returntype="void" output="false">
		<cfargument name="user" type="component" required="true" />
		
		<cfset var eventLog = '' />
		
		<!--- Get the event log from the transport --->
		<cfset eventLog = variables.transport.theApplication.managers.singleton.getEventLog() />
		
		<!--- TODO Check Permissions --->
		<cfif 1 eq 1>
			<!--- TODO Update the user object with the information from the provider and the database --->
			<cfset arguments.user.setUserID(1) />
			
			<!--- Log the successful login event --->
			<cfset eventLog.logEvent('user-openid', 'userVerified', 'Verified the OpenID login for ''' & arguments.user.getIdentity() & ''' on ' & variables.transport.theCgi.server_name & '.', arguments.user.getUserID(), arguments.user.getUserID()) />
		<cfelse>
			<!--- Log the failed login event --->
			<cfset eventLog.logEvent('user-openid', 'userFailed', 'The OpenID login failed for ''' & arguments.user.getIdentity() & ''' on ' & variables.transport.theCgi.server_name & '.', arguments.user.getUserID(), arguments.user.getUserID()) />
		</cfif>
	</cffunction>
</cfcomponent>