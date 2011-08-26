<cfcomponent extends="algid.inc.resource.plugin.configure" output="false">
<cfscript>
	public void function onApplicationStart(required struct theApplication) {
		var openIDConsumer = '';
		
		openIDConsumer = createObject('java', 'org.openid4java.consumer.ConsumerManager', '/plugins/user-openid/inc/lib/openid4java.jar').init();
		
		arguments.theApplication.managers.singleton.setOpenIDConsumer(openIDConsumer);
	}
</cfscript>
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
		
		<!--- => 0.1.4 --->
		<cfif versions.compareVersions(arguments.installedVersion, '0.1.4') lt 0>
			<!--- Change the Database --->
			<cfswitch expression="#variables.datasource.type#">
				<cfcase value="PostgreSQL">
					<cfset postgreSQL0_1_4() />
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
	
	<!---
		Configures the database for v0.1.4
	--->
	<cffunction name="postgreSQL0_1_4" access="public" returntype="void" output="false">
		<!---
			TABLES
		--->
		
		<!--- Identifier Table --->
		<cfquery datasource="#variables.datasource.name#">
			CREATE TABLE "#variables.datasource.prefix#user".identifier
			(
				"identifierID" uuid NOT NULL,
				"userID" uuid NOT NULL,
				identifier character varying(500) NOT NULL,
				CONSTRAINT identifier_pkey PRIMARY KEY ("identifierID"),
				CONSTRAINT "identifier_userID_fkey" FOREIGN KEY ("userID")
					REFERENCES "#variables.datasource.prefix#user"."user" ("userID") MATCH SIMPLE
					ON UPDATE CASCADE ON DELETE CASCADE,
				CONSTRAINT identifier_identifier_key UNIQUE (identifier)
			)
			WITH (
				OIDS=FALSE
			);
		</cfquery>
		
		<cfquery datasource="#variables.datasource.name#">
			ALTER TABLE "#variables.datasource.prefix#user".identifier OWNER TO #variables.datasource.owner#;
		</cfquery>
		
		<cfquery datasource="#variables.datasource.name#">
			COMMENT ON TABLE "#variables.datasource.prefix#user"."identifier" IS 'User OpenID Identifiers';
		</cfquery>
		
		<!--- Remove original column --->
		<cfquery datasource="#variables.datasource.name#">
			ALTER TABLE "#variables.datasource.prefix#user"."user" DROP COLUMN identifier;
		</cfquery>
	</cffunction>
</cfcomponent>
