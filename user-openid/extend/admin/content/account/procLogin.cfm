<cfset servUser = services.get('user', 'user') />

<!--- Include minified files for production --->
<cfset midfix = (transport.theApplication.managers.singleton.getApplication().isProduction() ? '-min' : '') />

<cfset template.addStyles(transport.theRequest.webRoot & 'plugins/user-openid/style/styles#midfix#.css') />

<!--- Construct URL from settings --->
<cfset urlBase = 'http#(transport.theCgi.https eq 'on' ? 's' : '')#://#transport.theCgi.http_host##transport.theApplication.managers.singleton.getApplication().getPath()##transport.theApplication.managers.plugin.getAdmin().getPath()#?' />

<!--- Check for form submission --->
<cfif transport.theCgi.request_method eq 'POST'>
	<cfset returnUrl = urlBase & '_base=/account/login' />
	
	<cflocation url="#servUser.discoverUser(form, returnUrl)#" addtoken="false">
<cfelseif theUrl.search('openid.ns') neq ''>
	<cfset responseUrl = urlBase & cgi.query_string />
	
	<cfset servUser.verifyUser(transport.theSession.managers.singleton.getUser(), responseUrl) />
	
	<cfif structKeyExists(transport.theSession, 'redirect')>
		<cflocation url="#transport.theSession.redirect#" addtoken="false" />
	</cfif>
	
	<!--- If no saved redirect, send to main page --->
	<cfset theUrl.cleanRedirect() />
	<cfset theUrl.setRedirect('_base', '/index') />
	
	<cfset theUrl.redirectRedirect() />
</cfif>
