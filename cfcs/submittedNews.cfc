<cfscript>
component extends="Event" output="no" {
	
	public  function getStoryList(boolean archive = 0, string q = '') {
		if(NOT can('read')) throw(type='c3d.notPermitted', message='You do not have permission to view this resource.');
		var qu = new query(dataSource=application.dsn);
		qu.setSQL('SELECT * FROM newssubmissions WHERE archive = :arc '
				 	& (len(arguments.q) ?
						' AND (
							   source LIKE :search
							   OR contributor LIKE :search
							   OR content LIKE :search )'
						:'')
					& ' ORDER BY dateCreated DESC');
		qu.addParam(name="arc", cfsqltype='cf_sql_bit', value=arguments.archive);
		qu.addParam(name="search" , cfsqltype="cf_sql_varchar", value='%#arguments.q#%');
		return qu.execute().getResult();
	}
	public void function archive(required numeric id) {
		if(NOT can('archive')) throw(type='c3d.notPermitted', message='You do not have permission to edit this resource.');
		var qu = new query(dataSource=application.dsn);
		qu.setSQL('UPDATE newssubmissions SET archive = 1 - archive WHERE id = :id ' );
		qu.addParam(name="id", cfsqltype='cf_sql_integer', value=arguments.id);
		qu.execute();
	}
	public boolean function store(required string message,
								  required string source,
								  required string user
								  ) {
		arguments.contributor = arguments.user;
		arguments.content = arguments.message;
		return application.DataMgr.insertRecord('newssubmissions', arguments);
	}
}
</cfscript>
