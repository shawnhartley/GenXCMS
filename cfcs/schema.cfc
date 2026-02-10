<cfscript>
component extends="Event" {
	mgr = application.DataMgr;
	public function pull() {
		if(NOT can('read')) { throw(type='c3d.notPermitted', message="You do not have permissions to access this module."); }
		var ret = {};
		var tableList = mgr.getDatabaseTables();
		for(i=1; i LTE ListLen(tableList); i++) {
			mgr.loadTable(ListGetAt(tableList, i));
		}
		ret = mgr.getXML(indexes=true);
		return ret;
	}
	public function push() {
		if(NOT can('update')) { throw(type='c3d.notPermitted', message="You do not have permissions to perform a Push action."); }
		mgr.deleteRecord('appsettings', {setting='APP.SCHEMAVERSION'});
		mgr.deleteRecord('appsettings', {setting='APP.SCHEMADATE'});
		mgr.loadXML(fileRead( expandPath( application.schemaPath)), true, true);
		try {
			application.settings.init();
		}
		catch(Any e) {
			// do nothing
			writeOutput('nothing');
		}
		return 'success';
	}
}
</cfscript>