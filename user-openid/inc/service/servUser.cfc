<cfcomponent extends="plugins.user.inc.service.servUser" output="false">
	<cffunction name="discoverUser" access="public" returntype="string" output="false">
		<cfargument name="request" type="struct" required="true" />
		<cfargument name="returnUrl" type="string" required="true" />
		
		<cfset var authReq = '' />
		<cfset var discovered = '' />
		<cfset var discoveries = '' />
		<cfset var fetch = '' />
		<cfset var openIDConsumer = '' />
		
		<cfif not len(trim(arguments.request.identity))>
			<cfthrow type="validation" message="Missing OpenID Identifier" detail="The identifier provided was empty" />
		</cfif>
		
		<cfset openIDConsumer = variables.transport.theApplication.managers.singleton.getOpenIDConsumer() />
		
		<cfset discoveries = openIDConsumer.discover(arguments.request.identity) />
		
		<cfset discovered = openIDConsumer.associate(discoveries) />
		
		<!--- Store the discoved for validating the response --->
		<cfset variables.transport.theSession.managers.singleton.setOpenIDDiscovered(discovered) />
		
		<cfset authReq = openIDConsumer.authenticate(discovered, arguments.returnUrl) />
		
		<!--- Add fetch requests --->
		<cfset fetch = createObject('java', 'org.openid4java.message.ax.FetchRequest', '/plugins/user-openid/inc/lib/openid4java.jar').createFetchRequest() />
		
		<cfset fetch.addAttribute("FirstName", "http://axschema.org/namePerson/first", true) />
		<cfset fetch.addAttribute("LastName", "http://axschema.org/namePerson/last", true) />
		<cfset fetch.addAttribute("Email", "http://axschema.org/contact/email", true) />
		<cfset fetch.addAttribute("Language", "http://axschema.org/pref/language", true) />
		
		<cfset authReq.addExtension(fetch) />
		
		<cfreturn authReq.getDestinationUrl(true) />
	</cffunction>
	
	<cffunction name="getUser" access="public" returntype="component" output="false">
		<cfargument name="userID" type="string" required="true" />
		
		<cfset var modelSerial = '' />
		<cfset var results = '' />
		<cfset var user = '' />
		
		<cfquery name="results" datasource="#variables.datasource.name#">
			SELECT "userID", "identifier"
			FROM "#variables.datasource.prefix#user"."user" u
			JOIN "#variables.datasource.prefix#user"."identifier" i
				ON u."userID" = i."userID"
			WHERE "userID" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#" null="#arguments.userID eq ''#" />::uuid
		</cfquery>
		
		<cfset user = getModel('user', 'user') />
		
		<cfif results.recordCount>
			<cfset modelSerial = variables.transport.theApplication.factories.transient.getModelSerial(variables.transport) />
			
			<cfset modelSerial.deserialize(results, user) />
		</cfif>
		
		<cfreturn user />
	</cffunction>
	
	<cffunction name="getUsers" access="public" returntype="query" output="false">
		<cfargument name="filter" type="struct" default="#{}#" />
		
		<cfset var results = '' />
		<cfset var useFuzzySearch = variables.transport.theApplication.managers.singleton.getApplication().getUseFuzzySearch() />
		
		<cfquery name="results" datasource="#variables.datasource.name#">
			SELECT u."userID", u."fullname", i."identifier"
			FROM "#variables.datasource.prefix#user"."user" u
			JOIN "#variables.datasource.prefix#user"."identifier" i
				ON u."userID" = i."userID"
			WHERE 1=1
			
			<cfif structKeyExists(arguments.filter, 'search') and arguments.filter.search neq ''>
				AND (
					u."fullname" LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.filter.search#%" />
					OR i."identifier" LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.filter.search#%" />
					OR u."username" LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.filter.search#%" />
					
					<cfif useFuzzySearch>
						OR dmetaphone(u."fullname") = dmetaphone(<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filter.search#" />)
						OR dmetaphone_alt(u."fullname") = dmetaphone_alt(<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filter.search#" />)
					</cfif>
				)
			</cfif>
			
			<cfif structKeyExists(arguments.filter, 'identifier')>
				and i."identifier" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.filter.user)#" />
			</cfif>
			
			ORDER BY i."identifier" ASC
		</cfquery>
		
		<cfreturn results />
	</cffunction>
	
	<cffunction name="setUser" access="public" returntype="void" output="false">
		<cfargument name="user" type="component" required="true" />
		
		<cfset var eventLog = '' />
		<cfset var observer = '' />
		<cfset var results = '' />
		
		<!--- Get the event observer --->
		<cfset observer = getPluginObserver('user-openid', 'user') />
		
		<cfset validate__model(arguments.user) />
		
		<cfset observer.beforeSave(variables.transport, arguments.user) />
		
		<cfif arguments.user.getUserID() eq ''>
			<!--- Create the new ID --->
			<cfset arguments.user.setUserID( createUUID() ) />
			
			<cfset observer.beforeCreate(variables.transport, arguments.user) />
			
			<!--- TODO Save the openID identifiers --->
			
			<cfset observer.afterCreate(variables.transport, arguments.user) />
		<cfelse>
			<cfset observer.beforeUpdate(variables.transport, arguments.user) />
			
			<!--- TODO Sync the openID identifiers --->
			
			<cfset observer.afterUpdate(variables.transport, arguments.user) />
		</cfif>
		
		<cfset observer.afterSave(variables.transport, arguments.user) />
	</cffunction>
	
	<cffunction name="verifyUser" access="public" returntype="void" output="false">
		<cfargument name="user" type="component" required="true" />
		<cfargument name="responseUrl" type="string" required="true" />
		
		<cfset var authResp = '' />
		<cfset var axMessage = '' />
		<cfset var discovered = '' />
		<cfset var discoveries = '' />
		<cfset var eventLog = '' />
		<cfset var ext = '' />
		<cfset var fullName = '' />
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
		
		<cfset openIDResp = createObject('java', 'org.openid4java.message.ParameterList', '/plugins/user-openid/inc/lib/openid4java.jar').init(variables.transport.theURL) />
		
		<cfset verification = openIDConsumer.verify(arguments.responseUrl, openidResp, discovered) />
		
		<cfset verified = verification.getVerifiedId() />
		
		<cfif isNull(verified)>
			<!--- After Fail Event --->
			<cfset observer.afterFail(variables.transport, arguments.user, '', verification.getStatusMsg()) />
			
			<cfthrow type="validation" message="OpenID verification failed" detail="#verification.getStatusMsg()#" errorcode="notValidated">
		<cfelse>
			<!--- TODO Update the user object with the information from the provider and the database --->
			
			<cfquery name="results" datasource="#variables.datasource.name#">
				SELECT u."userID"
				FROM "#variables.datasource.prefix#user"."user" u
				JOIN "#variables.datasource.prefix#user"."identifier" i
					ON u."userID" = i."userID"
				WHERE i."identifier" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(verified)#" />
					AND u."archivedOn" IS NULL
			</cfquery>
			
			<cfif results.recordCount>
				<cfset arguments.user.setUserID(results.userID.toString()) />
				<cfset arguments.user.setIdentity(verified.toString()) />
				
				<cfset axMessage = createObject('java', 'org.openid4java.message.ax.AxMessage', '/plugins/user-openid/inc/lib/openid4java.jar') />
				
				<cfset authResp = verification.getAuthResponse() />
				
				<!--- Check the response for any extensions --->
				<cfif authResp.hasExtension(axMessage.OPENID_NS_AX)>
					<cfset ext = authResp.getExtension(axMessage.OPENID_NS_AX) />
					
					<cfset fullname = '' />
					
					<cfif ext.getCount('FirstName')>
						<cfset fullname = ext.getAttributeValue('FirstName') />
					</cfif>
					
					<cfif ext.getCount('LastName')>
						<cfset fullname = listAppend(fullname, ext.getAttributeValue('LastName'), ' ') />
					</cfif>
					
					<cfset arguments.user.setFullName(fullname) />
					
					
					<cfif ext.getCount('Email')>
						<cfset arguments.user.setEmail(ext.getAttributeValue('Email')) />
					</cfif>
					
					<cfif ext.getCount('Language')>
						<cfset local.locale = ext.getAttributeValue('Language') />
						
						<!--- If its not in the available locales use the default --->
						<cfif not listFindNoCase( arrayToList(variables.transport.theApplication.managers.singleton.getApplication().getI18n().locales), local.locale )>
							<cfset locale = variables.transport.theApplication.managers.singleton.getApplication().getI18n().default />
						</cfif>
						
						<!--- Store the locale --->
						<cfset arguments.user.setLanguage(local.locale) />
						<cfset variables.transport.theSession.managers.singleton.getSession().setLocale(local.locale) />
					</cfif>
				</cfif>
				
				<!--- After Success Event --->
				<cfset observer.afterSuccess(variables.transport, arguments.user) />
			<cfelse>
				<!--- After Fail Event --->
				<cfset observer.afterFail(variables.transport, arguments.user, verified, 'User does not exist in system') />
				
				<cfthrow type="validation" message="The OpenID identifier provided does not exist as a current user" detail="Could not find the #verified.toString()# identifier as a current user">
			</cfif>
		</cfif>
		
		<!--- After Verify Event --->
		<cfset observer.afterVerify(variables.transport, arguments.user) />
	</cffunction>
</cfcomponent>
