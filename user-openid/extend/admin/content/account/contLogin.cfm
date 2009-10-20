<cfset viewUser = application.factories.transient.getViewUserForUser( transport ) />

<cfoutput>#viewUser.login( FORM )#</cfoutput>