<cfset servUser = transport.theApplication.factories.transient.getServUserForUser(application.app.getDSUpdate(), transport) />

<!--- Check for form submission --->
<cfif CGI.REQUEST_METHOD EQ 'POST'>
	<!--- Retrieve the user object --->
	<cfset user = session.managers.singleton.getUser() />
	
	<!--- TODO Discover openID provider --->
	<cfset servUser.discoverUser( FORM ) />
	
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