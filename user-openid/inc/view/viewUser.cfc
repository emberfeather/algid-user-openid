<cfcomponent extends="plugins.user.inc.view.viewUser" output="false">
	<cffunction name="login" access="public" returntype="string" output="false">
		<cfargument name="request" type="struct" default="#{}#" />
		
		<cfset var html = '' />
		<cfset var i18n = '' />
		<cfset var iconDir = '' />
		<cfset var iconSize = 32 />
		<cfset var theForm = '' />
		<cfset var theURL = '' />
		
		<cfset i18n = variables.transport.theApplication.managers.singleton.getI18N() />
		<cfset theURL = variables.transport.theRequest.managers.singleton.getUrl() />
		<cfset theForm = variables.transport.theApplication.factories.transient.getFormStandard('login', i18n) />
		
		<cfset theUrl.cleanLogin() />
		<cfset theUrl.setLogin('_base', '/account/login') />
		
		<!--- Add the resource bundle for the view --->
		<cfset theForm.addBundle('plugins/user-openid/i18n/inc/view', 'viewUser') />
		
		<cfset iconDir = variables.transport.theRequest.webRoot & 'plugins/user-openid/img/icon' />
		
		<cfsavecontent variable="html">
			<cfoutput>
				<div class="providers">
					<img src="#iconDir#/google_#iconSize#.png" title="Google" alt="Google" class="provider google" data-provider="google" />
					<img src="#iconDir#/yahoo_#iconSize#.png" title="Yahoo!" alt="Yahoo!" class="provider yahoo" data-provider="yahoo" />
					<img src="#iconDir#/openid_#iconSize#.png" title="OpenID" alt="OpenID" class="provider openid" data-provider="openID" />
					
					<div class="element identity">
						<input id="identity" type="text" name="identity" value="#( structKeyExists(arguments.request, 'identity') ? arguments.request.identity : '' )#">
					</div>
				</div>
			</cfoutput>
		</cfsavecontent>
		
		<!--- OpenID Providers --->
		<cfset theForm.addElement('custom', {
			name = "providers",
			label = "providers",
			value = html
		}) />
		
		<cfreturn theForm.toHTML(theURL.getLogin(), { submit: 'Login' }) />
	</cffunction>
	
	<cffunction name="datagrid" access="public" returntype="string" output="false">
		<cfargument name="data" type="any" required="true" />
		<cfargument name="options" type="struct" default="#{}#" />
		
		<cfset var datagrid = '' />
		<cfset var i18n = '' />
		
		<cfset arguments.options.theURL = variables.transport.theRequest.managers.singleton.getURL() />
		<cfset i18n = variables.transport.theApplication.managers.singleton.getI18N() />
		<cfset datagrid = variables.transport.theApplication.factories.transient.getDatagrid(i18n, variables.transport.theSession.managers.singleton.getSession().getLocale()) />
		
		<!--- Add the resource bundle for the view --->
		<cfset datagrid.addBundle('plugins/user/i18n/inc/view', 'viewUser') />
		<cfset datagrid.addBundle('plugins/user-openid/i18n/inc/view', 'viewUser') />
		
		<cfset datagrid.addColumn({
				key = 'fullname',
				label = 'fullname'
			}) />
		
		<cfset datagrid.addColumn({
				key = 'identifier',
				label = 'identity'
			}) />
		
		<cfset datagrid.addColumn({
				class = 'phantom align-right',
				value = [ 'delete', 'edit' ],
				link = [
					{
						'user' = 'userID',
						'_base' = '/admin/user/archive'
					},
					{
						'user' = 'userID',
						'_base' = '/admin/user/edit'
					}
				],
				linkClass = [ 'delete', '' ],
				title = 'fullname'
			}) />
		
		<cfreturn datagrid.toHTML( arguments.data, arguments.options ) />
	</cffunction>
</cfcomponent>
