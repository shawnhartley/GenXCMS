<cfscript>
component extends="Event" {
	public function getlogs(string searchfor='', string severity='') {
		if(NOT can('read')) throw(type='c3d.notPermitted', message='You do not have permissions to access this module.');
		var q = new query();
		var queryBody = 'SELECT ';
		if(application.dstype EQ 'mssql') queryBody &= ' TOP 2000 ';
		queryBody &= ' * FROM audit_log WHERE 1 = 1 ';
		q.setDatasource(application.dsn);
		if(len(arguments.searchfor)) {
			queryBody &= ' AND (message LIKE :searchformessage OR extraInfo LIKE :searchforextraInfo OR category LIKE :searchforcategory ) ';
			q.addParam(name="searchformessage", value='%' & arguments.searchfor & '%',CFSQLTYPE="CF_SQL_VARCHAR");
			q.addParam(name="searchforextraInfo", value='%' & arguments.searchfor & '%',CFSQLTYPE="CF_SQL_VARCHAR");
			q.addParam(name="searchforcategory", value='%' & arguments.searchfor & '%',CFSQLTYPE="CF_SQL_VARCHAR");
		}
		if(len(arguments.severity)) {
			queryBody &= ' AND severity = :severity ';
			q.addParam(name="severity", value=arguments.severity, CFSQLTYPE="CF_SQL_VARCHAR");
		}
		queryBody &= ' ORDER BY logDate DESC';
		if(application.dstype EQ 'mysql') queryBody &= ' LIMIT 2000';
		q.setSQL(queryBody);
		return q.execute();
	}
}
</cfscript>