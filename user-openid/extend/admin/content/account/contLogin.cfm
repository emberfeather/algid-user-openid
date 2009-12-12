<cfset viewUser = transport.theApplication.factories.transient.getViewUserForUser( transport ) />

<cfoutput>#viewUser.login( form )#</cfoutput>