<cfcomponent extends="algid.inc.resource.base.event" output="false">
<cfscript>
	public void function afterFail( required struct transport, required component user, required string provider, required string message ) {
		local.eventLog = arguments.transport.theApplication.managers.singleton.getEventLog();
		
		local.eventLog.logEvent('user-openid', 'userFailed', 'The OpenID login failed for ''' & arguments.provider & ''' (' & message & ') on ' & arguments.transport.theCgi.server_name & '.', arguments.user.getUserID(), arguments.user.getUserID());
	}
	
	public void function afterCreate( required struct transport, required component user ) {
		local.eventLog = arguments.transport.theApplication.managers.singleton.getEventLog();
		
		local.eventLog.logEvent('user-openid', 'userCreate', 'Created the ''' & arguments.user.getIdentifier() & ''' user.', arguments.transport.theSession.managers.singleton.getUser().getUserID(), arguments.user.getUserID());
	}
	
	public void function afterSuccess( required struct transport, required component user ) {
		local.eventLog = arguments.transport.theApplication.managers.singleton.getEventLog();
		
		local.eventLog.logEvent('user-openid', 'userVerified', 'Verified the OpenID login for ''' & arguments.user.getFullname() & ''' on ' & arguments.transport.theCgi.server_name & '.', arguments.user.getUserID(), arguments.user.getUserID());
	}
	
	public void function afterUpdate( required struct transport, required component user ) {
		local.eventLog = arguments.transport.theApplication.managers.singleton.getEventLog();
		
		local.eventLog.logEvent('user-openid', 'userCreate', 'Updated the ''' & arguments.user.getIdentifier() & ''' user.', arguments.transport.theSession.managers.singleton.getUser().getUserID(), arguments.user.getUserID());
	}
</cfscript>
</cfcomponent>
