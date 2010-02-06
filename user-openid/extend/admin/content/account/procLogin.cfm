<cfset servUser = transport.theApplication.factories.transient.getServUserForUser(transport.theApplication.managers.singleton.getApplication().getDSUpdate(), transport) />

<!--- Check for form submission --->
<cfif cgi.request_method eq 'POST'>
	<!--- Retrieve the user object --->
	<cfset user = transport.theSession.managers.singleton.getUser() />
	
	<!--- TODO Discover openID provider --->
	<cfset servUser.discoverUser( form ) />
	
	<!--- TODO Verify valid login --->
	<cfset servUser.verifyUser( user ) />
	
	<cflocation url="#transport.theSession.redirect#" addtoken="false" />
</cfif>

<!--- Include minified files for production --->
<cfset midfix = (transport.theApplication.managers.singleton.getApplication().isProduction() ? '-min' : '') />

<cfset template.addStyles('../plugins/user-openid/style/styles#midfix#.css') />

<!--- TODO Remove this when user login works --->
<cfset user = transport.theSession.managers.singleton.getUser() />
<cfset user.setIdentity('web.monkey.ef') />
<cfset servUser.verifyUser( user ) />

<cflocation url="#transport.theSession.redirect#" addtoken="false" />