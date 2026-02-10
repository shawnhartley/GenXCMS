<cfscript>// tag is just for dreamweaver syntax highlighting
component extends="Event" output="false" {
	public query function getusergroups(numeric group_ID="0") {
		if(NOT can('read')) { throw(type='c3d.notPermitted', message="You do not have permissions to access this module."); }
		return application.DataMgr.getRecords('usergroups', arguments.group_ID EQ 0 ? {} : arguments);
	}
	
	public query function getcapabilityList() {
		if(NOT can('read')) { throw(type='c3d.notPermitted', message="You do not have permissions to access this module."); }
		return application.DataMgr.getRecords(tablename='capabilities', orderby='component,name');
	}
	
	public query function getCurrentCapabilities(required numeric group_ID) {
		if(NOT can('read')) { throw(type='c3d.notPermitted', message="You do not have permissions to access this module."); }
		if(NOT arguments.group_ID){
		return application.DataMgr.getRecords(tablename="capabilities2usergroups", data = {group_ID = 2});	
			}else{ 
		return application.DataMgr.getRecords(tablename="capabilities2usergroups", data = {group_ID = arguments.group_ID});
			}
		//return application.DataMgr.getRecords(tablename="capabilities2usergroups");
	}
	
	public numeric function addUserGroup(string capabilities = '') {
		var myId = 0;
		arguments.group_id = -1;
		if(NOT can('create')) { throw(type='c3d.notPermitted', message="You do not have permissions to create this record."); }
		if(arguments.group_id LTE session.usergroupid AND session.usergroupid NEQ 1) { throw(type='c3d.notPermitted', message="You do not have permissions to create this record."); }
		if(arguments.group_id LTE 0) {
			StructDelete(arguments, 'group_id');
		}
		myId = application.DataMgr.InsertRecord('usergroups', arguments);
		application.DataMgr.saveRelationList("capabilities2usergroups","group_id",myId,"capabilityId",arguments.capabilities);
		return myId;
	}
	public numeric function saveUserGroup(required numeric group_ID, string capabilities='') {
		var myId = 0;
		if(NOT can('edit')) { throw(type='c3d.notPermitted', message="You do not have permissions to edit this record."); }
		if(arguments.group_id LTE session.usergroupid AND session.usergroupid NEQ 1) { throw(type='c3d.notPermitted', message="You do not have permissions to edit this record."); }
		if(arguments.group_id LTE 0) {
			StructDelete(arguments, 'group_id');
		}
		myId = application.DataMgr.saveRecord('usergroups', arguments);
		application.DataMgr.saveRelationList("capabilities2usergroups","group_id",myId,"capabilityId",arguments.capabilities);
		return myId;
	}
	public query function deleteUserGroup(required numeric group_ID) {
		
		userGroupCheck = application.DataMgr.getRecord("logins2usergroups",{group_ID=arguments.group_ID});
		
		if (userGroupCheck.recordCount NEQ 1){
			Application.DataMgr.deleteRecord("usergroups",{group_ID=arguments.group_ID});
		}else{
			//throw(type='c3d.todo', message = 'There are users associated with this usergroup (remove them or reassign them).');
			session.usergroupDeleteFail = 'There are users associated with this usergroup (remove them or reassign them).';
		} 
		
		return application.DataMgr.getRecords('usergroups');
		
	}
}
</cfscript>