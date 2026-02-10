<cfcomponent extends="logins" output="no">
	<cffunction name="saveNewPassword">
		<cfargument name="oldpassword" required="yes">
		<cfargument name="newpassword" required="yes">
		<cfargument name="confirmpassword" required="yes">
		<cfscript>
		var getSalt = application.DataMgr.getRecords('logins', {username=session.user});
		var salt = getSalt.salt;
		var testOldPassword = application.DataMgr.getRecords('logins', {username=session.user, password=application.helpers.computeHash(arguments.oldpassword, salt)});
		
		if(NOT len(arguments.oldpassword)) {
			throw(type='c3d.password', message="You must enter your current password.");
		}
		if(testOldPassword.recordcount NEQ 1) {
			throw(type='c3d.password', message="Please enter your current password.");
		}
		if(arguments.newpassword NEQ arguments.confirmpassword) {
			throw(type='c3d.password', message='Passwords do not match. Please try again.')
		}
		try {
			updateLogins(id=session.userid, username=session.user, password = arguments.newpassword, displayName=session.username, temporary = 0, groups=session.usergroupid);
			lock scope="session" type="exclusive" timeout="10" {
				StructDelete(session, 'temporary');
			}
		} catch (Any e) {
			rethrow;
		}
		</cfscript>
	</cffunction>
</cfcomponent>