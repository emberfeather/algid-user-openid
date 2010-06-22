<cfcomponent extends="algid.inc.resource.plugin.configure" output="false">
<cfscript>
	/* required theApplication */
	public void function onApplicationStart(struct theApplication) {
		var openIDConsumer = '';
		
		openIDConsumer = createObject('java', 'org.openid4java.consumer.ConsumerManager', '/plugins/user-openid/inc/lib/openid4java.jar').init();
		
		arguments.theApplication.managers.singleton.setOpenIDConsumer(openIDConsumer);
	}
</cfscript>
	<cffunction name="onSessionStart" access="public" returntype="void" output="false">
		<cfargument name="theApplication" type="struct" required="true" />
		<cfargument name="theSession" type="struct" required="true" />
		
		<cfset var temp = '' />
		
		<!--- Add the user singleton --->
		<cfset temp = arguments.theApplication.factories.transient.getModUserForUser(arguments.theApplication.managers.singleton.getI18N()) />
		
		<cfset arguments.theSession.managers.singleton.setUser(temp) />
	</cffunction>

	<cffunction name="update" access="public" returntype="void" output="false">
		<cfargument name="plugin" type="struct" required="true" />
		<cfargument name="installedVersion" type="string" default="" />
		
		<cfset var versions = createObject('component', 'algid.inc.resource.utility.version').init() />
		
		<!--- fresh => 0.1.0 --->
		<cfif versions.compareVersions(arguments.installedVersion, '0.1.0') lt 0>
			<!--- Setup the Database --->
			<cfswitch expression="#variables.datasource.type#">
				<cfcase value="PostgreSQL">
					<cfset postgreSQL0_1_0() />
				</cfcase>
				<cfdefaultcase>
					<!--- TODO Remove this thow when a later version supports more database types  --->
					<cfthrow message="Database Type Not Supported" detail="The #variables.datasource.type# database type is not currently supported" />
				</cfdefaultcase>
			</cfswitch>
		</cfif>
	</cffunction>
	
	<!---
		Configures the database for v0.1.0
	--->
	<cffunction name="postgreSQL0_1_0" access="public" returntype="void" output="false">
		<!---
			TABLES
		--->
		
		<!--- User Table --->
		<cfquery datasource="#variables.datasource.name#">
			ALTER TABLE "#variables.datasource.prefix#user"."user" ADD COLUMN identifier character varying(500);
		</cfquery>
		
		<cfquery datasource="#variables.datasource.name#">
			ALTER TABLE "#variables.datasource.prefix#user"."user" ADD UNIQUE (identifier);
		</cfquery>
	</cffunction>
</cfcomponent>