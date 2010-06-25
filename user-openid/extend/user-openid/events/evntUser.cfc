<cfcomponent extends="algid.inc.resource.base.event" output="false">
<cfscript>
	/* required user */
	public void function afterFail( struct transport, component user, string message ) {
		var eventLog = '';
		
		// Get the event log from the transport
		eventLog = arguments.transport.theApplication.managers.singleton.getEventLog();
		
		// Log the failed login event
		eventLog.logEvent('user-openid', 'userFailed', 'The OpenID login failed for ''' & arguments.user.getIdentity() & ''' (' & message & ') on ' & arguments.transport.theCgi.server_name & '.', arguments.user.getUserID(), arguments.user.getUserID());
	}
	
	/* required user */
	public void function afterCreate( struct transport, component user ) {
		var eventLog = '';
		
		// Get the event log from the transport
		eventLog = arguments.transport.theApplication.managers.singleton.getEventLog();
		
		// Log the create event
		eventLog.logEvent('user-openid', 'userCreate', 'Created the ''' & arguments.user.getIdentifier() & ''' user.', arguments.currUser.getUserID(), arguments.user.getUserID());
	}
	
	/* required user */
	public void function afterSuccess( struct transport, component user ) {
		var eventLog = '';
		
		// Get the event log from the transport
		eventLog = arguments.transport.theApplication.managers.singleton.getEventLog();
		
		// Log the successful login event
		eventLog.logEvent('user-openid', 'userVerified', 'Verified the OpenID login for ''' & arguments.user.getFullname() & ''' on ' & arguments.transport.theCgi.server_name & '.', arguments.user.getUserID(), arguments.user.getUserID());
	}
	
	/* required user */
	public void function afterUpdate( struct transport, component user ) {
		var eventLog = '';
		
		// Get the event log from the transport
		eventLog = arguments.transport.theApplication.managers.singleton.getEventLog();
		
		// Log the create event
		eventLog.logEvent('user-openid', 'userCreate', 'Updated the ''' & arguments.user.getIdentifier() & ''' user.', arguments.currUser.getUserID(), arguments.user.getUserID());
	}
</cfscript>
</cfcomponent>
