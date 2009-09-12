<cfcomponent extends="plugins.user.inc.model.modUser" output="false">
	<cffunction name="init" access="public" returntype="component" output="false">
		<cfargument name="i18n" type="component" required="true" />
		<cfargument name="locale" type="string" default="en_US" />
		
		<cfset super.init(arguments.i18n, arguments.locale) />
		
		<!--- Identity --->
		<cfset addAttribute(argumentCollection = {
				attribute = 'identity'
			}) />
		
		<!--- Set the bundle information for translation --->
		<cfset setI18NBundle('plugins/user-openid/i18n/inc/model', 'modUser') />
		
		<cfreturn this />
	</cffunction>
</cfcomponent>