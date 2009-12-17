<cfset servUser = transport.theApplication.factories.transient.getServUserForUser(transport.theApplication.managers.singleton.getApplication().getDSUpdate(), transport) />

<!--- Check for form submission --->
<cfif cgi.request_method eq 'POST'>
	<!--- Retrieve the user object --->
	<cfset user = session.managers.singleton.getUser() />
	
	<!--- TODO Discover openID provider --->
	<cfset servUser.discoverUser( form ) />
	
	<!--- TODO Verify valid login --->
	<cfset servUser.verifyUser( user ) />
	
	<cflocation url="#session.redirect#" addtoken="false" />
</cfif>

<cfset template.addStyles('../plugins/user-openid/style/styles#midfix#.css') />

<!--- TODO Remove this when user login works --->
<cfset user = session.managers.singleton.getUser() />
<cfset user.setIdentity('web.monkey.ef') />
<cfset servUser.verifyUser( user ) />

<cflocation url="#session.redirect#" addtoken="false" />