<cfcomponent extends="Event" output="no">
	  <!--- get all records --->
	<cffunction name="getlogins" access="public" output="false" returntype="query" hint="Returns a query object containing all of the logins records">
		<cfargument name="id" default="0" type="numeric">
		<cfargument name="group" default="0" type="numeric">
		<cfargument name="q" default="" type="string">	
		<cfset var qGetAllRecords = 0 />
		<cfquery name="qGetAllRecords" datasource="#application.dsn#">
			SELECT logins.*, usergroups.manager,usergroups.groupName, usergroups.group_ID
			FROM logins
				LEFT JOIN logins2usergroups ON logins.id = logins2usergroups.loginId
				LEFT JOIN usergroups ON logins2usergroups.group_ID = usergroups.group_ID
			WHERE 1 = 1
			<cfif arguments.id>
				AND logins.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfif>
			<cfif arguments.group>
				AND logins2usergroups.group_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.group#">
			</cfif>
			<cfif len(arguments.q)>
				AND (
					logins.displayName LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.q#%">
					OR logins.username LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.q#%">
					)
			</cfif>
			<cfif NOT can('read')>
				AND 1 = 0
			</cfif>
		</cfquery>
			<cfset logger.info('User #session.userid# (#session.username#) viewed the logins list')>
		<cfreturn qGetAllRecords />
	</cffunction>
	
	<cffunction name="deletelogins">
		<cfargument name="id" default="0">
		<cfif NOT can('delete_user')>
			<cfthrow type="c3d.notPermitted" message="You do not have permission to delete this resource.">
		</cfif>
		<cfquery name="qDeletelogins" datasource="#application.dsn#">
				DELETE FROM logins WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">;
		</cfquery>
		<cfquery name="qDeletelogins" datasource="#application.dsn#">
				DELETE FROM logins2usergroups WHERE loginId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">;
		</cfquery>
		<cfquery name="qDeletelogins" datasource="#application.dsn#">
				DELETE FROM capabilities2logins WHERE loginId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">;
		</cfquery>
		<cfset logger.info('User #session.userid# (#session.username#) DELETED login "#arguments.displayName#" (#arguments.id#)', {group=arguments.groups})>
	
		<cfreturn true>
	</cffunction>
	
	<cffunction name="addlogins">
		<cfargument name="username" required="yes">
		<cfargument name="password" required="yes">
		<cfargument name="displayName" default="#arguments.username#">
		<cfargument name="groups" required="yes" type="numeric">
		<cfscript>
		var data = StructNew();
		var myID = 0;
		if( NOT can('add_user') ) {
			logger.warn('User #session.userid# (#session.username#) TRIED to add login "#arguments.displayName#" (#arguments.id#), but was not permitted', {group=arguments.groups});
			throw( type="c3d.notPermitted", message="You do not have permission to add users.");
		}
		if( arguments.groups LT session.usergroupid) {
			throw( type='c3d.notPermitted', message="You do not have permission to add a user in this group.");
		}
		data.salt = application.helpers.genSalt();
	
		if(NOT application.helpers.isValidNewUsername(arguments.username)) {
			throw(type='c3d.invalidUsername', message="This username has already been used.");
		}
		if(NOT Len(arguments.password)) {
			throw(type='c3d.invalidpassword', message="Passwords cannot be left blank.");
		}
		data.username = LCase(arguments.username);
		data.password = application.helpers.computeHash(arguments.password, data.salt);
		data.displayName = arguments.displayName;
		
		myId = application.DataMgr.saveRecord('logins', data);
		application.dataMgr.saveRelationList("logins2usergroups","loginID", myId,"group_ID",arguments.groups);
		logger.info('User #session.userid# (#session.username#) ADDED login "#arguments.displayName#" (#myId#)', {group=arguments.groups});
	
		return myId;
		</cfscript>
	</cffunction>
	
	<cffunction name="updatelogins">
		<cfargument name="id" required="yes" type="numeric">
		<cfargument name="username" required="yes">
		<cfargument name="password" default="">
		<cfargument name="displayName" required="no">
		<cfargument name="temporary" default="0" type="numeric">
		<cfargument name="groups" required="yes">
		<cfscript>
		var data = structNew();
		if( ( NOT can('edit_user')
					AND arguments.id NEQ session.userid )
			  OR ( NOT can('edit_user')
					AND arguments.groups NEQ session.usergroupid
					AND arguments.id EQ session.userid ) ) { // allow someone to update their own record, but not change their own group unless they have edit permissions
			logger.warn('User #session.userid# (#session.username#) TRIED to update login "#arguments.displayName#, but was not allowed" (#arguments.id#)', {group=arguments.groups});
			throw( type="c3d.notPermitted", message="You do not have permission to edit users.");
		}
		if( arguments.groups LT session.usergroupid) {
			throw( type='c3d.notPermitted', message="You do not have permission to edit a user in this group.");
		}
		if(NOT application.helpers.isValidChangedUsername(username, id)) {
			throw(type='c3d.invalidUsername', message="This username has already been used.");
		}
		data.id = arguments.id;
		data.username = LCase(arguments.username);
		data.temporary = arguments.temporary;
		if(len(arguments.password)) {
			data.salt = application.helpers.genSalt();
			data.password = application.helpers.computeHash(arguments.password, data.salt);
		}
		data.displayName = arguments.displayName;
		application.dataMgr.saveRelationList("logins2usergroups","loginId", arguments.id,"group_ID",arguments.groups);
		logger.info('User #session.userid# (#session.username#) UPDATED login "#arguments.displayName#" (#arguments.id#)', {group=arguments.groups});
		return application.DataMgr.saveRecord('logins', data);
		</cfscript>
	</cffunction>
	
	<cffunction name="getusergroupsList" output="no" access="public">
		<cfif NOT can('read')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>
		<cfreturn application.DataMgr.getRecords( tablename='usergroups', orderby='group_ID')>
	</cffunction>
	
	<cffunction name="getNonManagers">
		  <cfquery name="qlogins" datasource="#application.dsn#">
				SELECT logins.*, usergroups.manager,usergroups.groupName, usergroups.group_ID
			FROM logins
				LEFT JOIN logins2usergroups ON logins.id = logins2usergroups.loginId
				LEFT JOIN usergroups ON logins2usergroups.group_ID = usergroups.group_ID
		  </cfquery>
		  <cfreturn qlogins>
	</cffunction>
	
	<cffunction name="getNonManagerGroups">
		<cfquery name="qgroups" datasource="#application.dsn#">
			SELECT * FROM usergroups WHERE manager = 0
		</cfquery>
		<cfreturn qgroups>
	</cffunction>
	
	<cffunction name="sendTemporaryPassword" output="no" returntype="void">
		<cfargument name="emailAddress" required="yes">
		<cfscript>
		var password = generatePassword();
		var userinfo = application.DataMgr.getRecord('logins', {username=arguments.emailAddress});
		var data = structNew();
			data.salt = application.helpers.genSalt();
			data.password = application.helpers.computeHash(password, data.salt);
			data.temporary = INT(NOW() + 14);
			data.username = arguments.emailAddress;
	
		if(userinfo.recordCount NEQ 1) {
			return;
		}
		data.id = userinfo.id;
		
		application.DataMgr.updateRecord('logins', data);
		logger.info('Sent Temporary password to #arguments.emailaddress# (#userinfo.id#)', {ipaddress=cgi.REMOTE_HOST, expires=DateFormat(data.temporary, 'mmm dd, yyyy')});
		</cfscript>
		
		<cfmail to="#arguments.emailAddress#" from="forgottenpassword@#cgi.HTTP_HOST#" bcc="receipt@c3design.com" subject="#cgi.HTTP_HOST# Password Reset">
	You have requested to reset your password. Your temporary password appears below. It will expire on #DateFormat(data.temporary, 'mmm dd, yyyy')#.
	
		Temporary Password: #password#
		</cfmail>
	</cffunction>
	
	<cfscript>
	/**
	* Generates a password the length you specify.
	* v2 by James Moberg.
	*
	* @param numberOfCharacters      Lengh for the generated password. Defaults to 8. (Optional)
	* @param characterFilter      Characters filtered from result. Defaults to O,o,0,i,l,1,I,5,S (Optional)
	* @return Returns a string.
	* @author Tony Blackmon (fluid@sc.rr.com)
	* @version 2, February 8, 2010
	*/
	function generatePassword() {
	var placeCharacter = "";
	var currentPlace=0;
	var group=0;
	var subGroup=0;
	var numberofCharacters = 8;
	var characterFilter = 'O,o,0,i,l,1,I,5,S';
	var characterReplace = repeatString(",", listlen(characterFilter)-1);
	if(arrayLen(arguments) gte 1) numberofCharacters = val(arguments[1]);
	if(arrayLen(arguments) gte 2) {
	characterFilter = listsort(rereplace(arguments[2], "([[:alnum:]])", "\1,", "all"),"textnocase");
	characterReplace = repeatString(",", listlen(characterFilter)-1);
	}
	while (len(placeCharacter) LT numberofCharacters) {
	group = randRange(1,4, 'SHA1PRNG');
	switch(group) {
	case "1":
	subGroup = rand();
	switch(subGroup) {
	case "0":
	placeCharacter = placeCharacter & chr(randRange(33,46, 'SHA1PRNG'));
	break;
	case "1":
	placeCharacter = placeCharacter & chr(randRange(58,64, 'SHA1PRNG'));
	break;
	}
	case "2":
	placeCharacter = placeCharacter & chr(randRange(97,122, 'SHA1PRNG'));
	break;
	case "3":
	placeCharacter = placeCharacter & chr(randRange(65,90, 'SHA1PRNG'));
	break;
	case "4":
	placeCharacter = placeCharacter & chr(randRange(48,57, 'SHA1PRNG'));
	break;
	}
	if (listLen(characterFilter)) {
	placeCharacter = replacelist(placeCharacter, characterFilter, characterReplace);
	}
	}
	return placeCharacter;
	}
</cfscript>
</cfcomponent>