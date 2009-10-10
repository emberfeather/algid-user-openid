<cfset viewUser = application.factories.transient.getViewUserForUser(theURL) />

<cfoutput>#viewUser.login( FORM )#</cfoutput>