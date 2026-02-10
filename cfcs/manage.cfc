<cfcomponent extends="Event">
	<cffunction name="getPageApprovals" access="public" returntype="query" output="no">
		<cfquery name="pageApprovals" datasource="#application.dsn#">
			SELECT *
			 FROM page
				WHERE isDraft = <cfqueryparam cfsqltype="cf_sql_bit" value="no">
                AND approved = <cfqueryparam cfsqltype="cf_sql_bit" value="no">
		</cfquery>
		<cfreturn pageApprovals>
	</cffunction>
	<cffunction name="getNewsApprovals" access="public" returntype="query" output="no">
		<cfquery name="newsApprovals" datasource="#application.dsn#">
			SELECT id, headline, publishDate
			from news
			WHERE active = <cfqueryparam cfsqltype="cf_sql_bit" value="yes">
			AND approved = <cfqueryparam cfsqltype="cf_sql_bit" value="no">
		</cfquery>
		<cfreturn newsApprovals>
	</cffunction>

</cfcomponent>