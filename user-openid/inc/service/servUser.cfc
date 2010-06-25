<cfcomponent extends="plugins.user.inc.service.servUser" output="false">
	<cffunction name="discoverUser" access="public" returntype="string" output="false">
		<cfargument name="request" type="struct" required="true" />
		<cfargument name="returnUrl" type="string" required="true" />
		
		<cfset var authReq = '' />
		<cfset var discovered = '' />
		<cfset var discoveries = '' />
		<cfset var openIDConsumer = '' />
		
		<cfset openIDConsumer = variables.transport.theApplication.managers.singleton.getOpenIDConsumer() />
		
		<cfset discoveries = openIDConsumer.discover(arguments.request.identity) />
		
		<cfset discovered = openIDConsumer.associate(discoveries) />
		
		<!--- Store the discoved for validating the response --->
		<cfset variables.transport.theSession.managers.singleton.setOpenIDDiscovered(discovered) />
		
		<cfset authReq = openIDConsumer.authenticate(discovered, arguments.returnUrl) />
		
		<cfreturn authReq.getDestinationUrl(true) />
	</cffunction>
	
	<cffunction name="getUser" access="public" returntype="component" output="false">
		<cfargument name="userID" type="string" required="true" />
		
		<cfset var i18n = '' />
		<cfset var objectSerial = '' />
		<cfset var results = '' />
		<cfset var user = '' />
		
		<cfset i18n = variables.transport.theApplication.managers.singleton.getI18N() />
		
		<cfquery name="results" datasource="#variables.datasource.name#">
			SELECT "userID", "identifier"
			FROM "#variables.datasource.prefix#user"."user"
			WHERE "userID" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#" null="#arguments.userID eq ''#" />::uuid
		</cfquery>
		
		<cfset user = variables.transport.theApplication.factories.transient.getModUserForUser(i18n, variables.transport.theSession.managers.singleton.getSession().getLocale()) />
		
		<cfif results.recordCount>
			<cfset objectSerial = variables.transport.theApplication.managers.singleton.getObjectSerial() />
			
			<cfset objectSerial.deserialize(results, user) />
		</cfif>
		
		<cfreturn user />
	</cffunction>
	
	<cffunction name="getUsers" access="public" returntype="query" output="false">
		<cfargument name="filter" type="struct" default="#{}#" />
		
		<cfset var results = '' />
		
		<cfquery name="results" datasource="#variables.datasource.name#">
			SELECT "userID", "fullname", "identifier"
			FROM "#variables.datasource.prefix#user"."user"
			WHERE 1=1
			
			<cfif structKeyExists(arguments.filter, 'search') and arguments.filter.search neq ''>
				AND (
					"fullname" LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.filter.search#%" />
					OR "identifier" LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.filter.search#%" />
					OR "username" LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.filter.search#%" />
				)
			</cfif>
			
			<cfif structKeyExists(arguments.filter, 'identifier')>
				and "identifier" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filter.user#" />
			</cfif>
			
			ORDER BY "identifier" ASC
		</cfquery>
		
		<cfreturn results />
	</cffunction>
	
	<cffunction name="setUser" access="public" returntype="void" output="false">
		<cfargument name="currUser" type="component" required="true" />
		<cfargument name="user" type="component" required="true" />
		
		<cfset var eventLog = '' />
		<cfset var observer = '' />
		<cfset var results = '' />
		
		<!--- Get the event observer --->
		<cfset observer = getPluginObserver('user-openid', 'user') />
		
		<!--- TODO Check Permissions --->
		
		<!--- Before Save Event --->
		<cfset observer.beforeSave(variables.transport, arguments.currUser, arguments.content) />
		
		<cfif arguments.user.getUserID() eq ''>
			<!--- Create the new ID --->
			<cfset arguments.user.setUserID( createUUID() ) />
			
			<cfquery datasource="#variables.datasource.name#" result="results">
				INSERT INTO "#variables.datasource.prefix#user"."user"
				(
					"userID",
					"identifier"
				) VALUES (
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.user.getUserID()#" />::uuid,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.user.getIdentifier()#" />
				)
			</cfquery>
			
			<!--- After Create Event --->
			<cfset observer.afterCreate(variables.transport, arguments.currUser, arguments.content) />
		<cfelse>
			<!--- After Update Event --->
			<cfset observer.afterUpdate(variables.transport, arguments.currUser, arguments.content) />
		</cfif>
		
		<!--- After Save Event --->
		<cfset observer.afterSave(variables.transport, arguments.currUser, arguments.content) />
	</cffunction>
	
	<cffunction name="verifyUser" access="public" returntype="void" output="false">
		<cfargument name="user" type="component" required="true" />
		<cfargument name="responseUrl" type="string" required="true" />
		
		<cfset var authReq = '' />
		<cfset var discovered = '' />
		<cfset var discoveries = '' />
		<cfset var eventLog = '' />
		<cfset var observer = '' />
		<cfset var openIDConsumer = '' />
		<cfset var openIDResp = '' />
		<cfset var results = '' />
		<cfset var returnUrl = '' />
		<cfset var verified = '' />
		<cfset var verification = '' />
		
		<cfset openIDConsumer = variables.transport.theApplication.managers.singleton.getOpenIDConsumer() />
		<cfset discovered = variables.transport.theSession.managers.singleton.getOpenIDDiscovered() />
		
		<cfif not variables.transport.theSession.managers.singleton.hasOpenIDDiscovered()>
			<cfthrow message="Missing OpenID discovery information">
		</cfif>
		
		<cfset observer = getPluginObserver('user-openid', 'user') />
		<cfset observer.beforeVerify(variables.transport, arguments.user) />
		
		<cfset openIDResp = createObject('java', 'org.openid4java.message.ParameterList', '/plugins/user-openid/inc/lib/openid4java.jar').init(variables.transport.theURL)>
		
		<cfset verification = openIDConsumer.verify(arguments.responseUrl, openidResp, discovered)>
		
		<cfset verified = verification.getVerifiedId()>
		
		<cfif isNull(verified)>
			<!--- After Fail Event --->
			<cfset observer.afterFail(variables.transport, arguments.user, verification.getStatusMsg()) />
			
			<cfthrow type="validation" message="OpenID verification failed" detail="#verification.getStatusMsg()#">
		<cfelse>
			<!--- TODO Update the user object with the information from the provider and the database --->
			
			<cfquery name="results" datasource="#variables.datasource.name#">
				SELECT "userID"
				FROM "#variables.datasource.prefix#user"."user"
				WHERE "identifier" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#verified#" />
					AND "archivedOn" IS NULL
			</cfquery>
			
			<cfif results.recordCount>
				<cfset arguments.user.setUserID(results.userID) />
				<cfset arguments.user.setIdentity(verified) />
				
				<!--- After Success Event --->
				<cfset observer.afterSuccess(variables.transport, arguments.user) />
			<cfelse>
				<!--- After Fail Event --->
				<cfset observer.afterFail(variables.transport, arguments.user, 'User does not exist in system') />
				
				<cfthrow type="validation" message="The OpenID identifier provided does not exist as a current user" detail="Could not find the #verified# identifier as a current user">
			</cfif>
		</cfif>
		
		<!--- After Verify Event --->
		<cfset observer.afterVerify(variables.transport, arguments.user) />
	</cffunction>
</cfcomponent>
