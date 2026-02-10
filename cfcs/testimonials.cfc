<cfcomponent extends="Event">
	<cffunction name="getItems" returntype="query">
		<cfargument name="id" default="0" type="numeric">
		<cfquery name="qitems" datasource="#application.dsn#">
			Select * FROM testimonials
				WHERE 1 = 1
				<cfif arguments.id>
					AND id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
				</cfif>
				ORDER BY sortorder, title
		</cfquery>
		<cfreturn qitems>
	</cffunction>
	
	<cffunction name="insertitem">
		<cfif NOT isNumeric(arguments.sortorder)><cfset arguments.sortorder = 10></cfif>
		<cfreturn application.Datamgr.insertRecord('testimonials', arguments)>
	</cffunction>

	<cffunction name="updateitem">
		
		<cfquery name="upd" datasource="#application.dsn#">
            UPDATE testimonials 
            SET title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">
            	,sortorder = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sortorder#">
            	,testimonial = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.testimonial#">
          WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
<!---	<cffunction name="deleteItem" output="no">
		<cfargument name="id" required="yes" type="numeric">
		<cfquery name="qdel" datasource="#application.dsn#">
			DELETE FROM testimonials WHERE 
					id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>  --->  
</cfcomponent>