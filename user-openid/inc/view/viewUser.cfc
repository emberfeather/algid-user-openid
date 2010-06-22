<cfcomponent extends="algid.inc.resource.base.view" output="false">
	<cffunction name="login" access="public" returntype="string" output="false">
		<cfargument name="request" type="struct" default="#{}#" />
		
		<cfset var html = '' />
		<cfset var i18n = '' />
		<cfset var theForm = '' />
		<cfset var theURL = '' />
		
		<cfset i18n = variables.transport.theApplication.managers.singleton.getI18N() />
		<cfset theURL = variables.transport.theRequest.managers.singleton.getUrl() />
		<cfset theForm = variables.transport.theApplication.factories.transient.getFormStandard('login', i18n) />
		
		<cfset theUrl.cleanLogin() />
		<cfset theUrl.setLogin('_base', '/account/login') />
		
		<!--- Add the resource bundle for the view --->
		<cfset theForm.addBundle('plugins/user-openid/i18n/inc/view', 'viewUser') />
		
		<!--- Identifier --->
		<cfset theForm.addElement('text', {
				id = "identity",
				name = "identity",
				label = "identity",
				value = ( structKeyExists(arguments.request, 'identity') ? arguments.request.identity : '' )
			}) />
		
		<cfreturn theForm.toHTML(theURL.getLogin()) />
	</cffunction>
	
	<cffunction name="datagrid" access="public" returntype="string" output="false">
		<cfargument name="data" type="any" required="true" />
		<cfargument name="options" type="struct" default="#{}#" />
		
		<cfset var datagrid = '' />
		<cfset var i18n = '' />
		
		<cfset i18n = variables.transport.theApplication.managers.singleton.getI18N() />
		<cfset datagrid = variables.transport.theApplication.factories.transient.getDatagrid(i18n, variables.transport.theSession.managers.singleton.getSession().getLocale()) />
		
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
