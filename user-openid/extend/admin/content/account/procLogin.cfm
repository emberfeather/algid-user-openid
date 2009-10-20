<cfset servUser = application.factories.transient.getServUserForUser(application.app.getDSUpdate(), transport) />

<!--- Create an empty user object if none exists --->
<cfif NOT SESSION.managers.singleton.hasUser()>
	<cfset SESSION.managers.singleton.setUser( application.factories.transient.getModUserForUser(i18n, SESSION.locale) ) />
</cfif>

<!--- Check for form submission --->
<cfif CGI.REQUEST_METHOD EQ 'POST'>
	<!--- TODO Trigger openID login --->
	
	<!--- TODO Verify valid login --->
</cfif>

<cfset template.addStyles('../plugins/user-openid/style/styles#midfix#.css') />

<!--- TODO Remove when login works --->
<cfset user = SESSION.managers.singleton.getUser() />
<cfset user.setUserID( 1 ) />

<cflocation url="#SESSION.redirect#" addtoken="false" />