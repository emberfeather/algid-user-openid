<cfset viewUser = views.get('user', 'user') />

<cfoutput>#viewUser.login( form )#</cfoutput>
