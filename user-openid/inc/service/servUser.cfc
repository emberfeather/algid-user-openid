<cfcomponent extends="plugins.user.inc.service.servUser" output="false">
	<cffunction name="createUser" access="public" returntype="void" output="false">
		<cfargument name="user" type="component" required="true" />
		
		<cfset var results = '' />
		
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
	</cffunction>
	
	<cffunction name="readUser" access="public" returntype="component" output="false">
		<cfargument name="userID" type="numeric" required="true" />
		
		<cfset var i18n = '' />
		<cfset var results = '' />
		<cfset var user = '' />
		
		<cfset i18n = variables.transport.applicationSingletons.getI18N() />
		
		<cfquery name="results" datasource="#variables.datasource.name#">
			SELECT "userID", "identifier"
			FROM "#variables.datasource.prefix#user"."user"
			WHERE "userID" = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#" />
		</cfquery>
		
		<cfset user = application.factories.transient.getModUserForUser(i18n, variables.transport.locale) />
		
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
				AND "identifier" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filter.user#" />
			</cfif>
			
			ORDER BY "identifier" ASC
		</cfquery>
		
		<cfreturn results />
	</cffunction>
</cfcomponent>