<cfcomponent extends="Event" output="no">
	<cffunction name="getlinkslist" access="public" returntype="query">
		<cfargument name="id" type="numeric" default="0">
		<cfif request.manage AND NOT can('read')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>
		<cfquery datasource="#application.dsn#" name="qlinks">
			SELECT * FROM links LEFT JOIN link_categories ON links.category = link_categories.id
				WHERE 1 = 1
			<cfif id NEQ 0>
				AND links.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#id#">
			</cfif>
			<cfif NOT request.manage>
				AND active = 1
			</cfif>
			ORDER BY category, sortorder, linkTitle
		</cfquery>
		<cfreturn qlinks>
	</cffunction>
	<cffunction name="insertLink" access="public" returntype="void">
		<cfargument name="linkTitle" type="string" required="yes">
		<cfargument name="linkURL" type="string" required="yes">
		<cfargument name="active" type="boolean" default="0">
		<cfargument name="sortorder" default="10">
		<cfargument name="category" default="0">
		<cfif NOT can('create')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create a link."></cfif>
		<cfif NOT isNumeric(sortorder)>
			<cfset sortorder = 10>
		</cfif>
		<cfquery datasource="#application.dsn#" name="ins">
			INSERT INTO links (linkTitle, linkURL, sortorder, category, active, dateCreated)
						VALUES
					(
					  <cfqueryparam cfsqltype="cf_sql_varchar" value="#linkTitle#">
					, <cfqueryparam cfsqltype="cf_sql_varchar" value="#linkURL#">
					, <cfqueryparam cfsqltype="cf_sql_integer" value="#sortorder#">
					, <cfqueryparam cfsqltype="cf_sql_integer" value="#category#">
					, <cfqueryparam cfsqltype="cf_sql_integer" value="#active#">
					, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#NOW()#">
					)
		</cfquery>
	</cffunction>
	<cffunction name="update" access="public" returntype="void">
		<cfargument name="linkTitle" type="string" required="yes">
		<cfargument name="linkURL" type="string" required="yes">
		<cfargument name="active" type="boolean" default="0">
		<cfargument name="sortorder" default="10">
		<cfargument name="category" default="0">
		<cfif NOT can('edit')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this link."></cfif>
		<cfif NOT can('publish')><cfset arguments.active = 0></cfif>
		<cfquery name="qIsPublished" datasource="#application.dsn#">
			SELECT id FROM links
				WHERE active = 1
					AND id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfif qIsPublished.recordcount AND NOT can('edit_published')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this link."></cfif>
		<cfquery datasource="#application.dsn#" name="ins">
			UPDATE links  SET linkTitle = <cfqueryparam cfsqltype="cf_sql_varchar" value="#linkTitle#">
							,linkURL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.linkURL#">
							,active = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.active#">
							,sortorder = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sortorder#">
							,category = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.category#">
							
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	<cffunction name="activate" access="public" returntype="void">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="function" type="string" required="yes">
		<cfif NOT can('publish')><cfthrow type="c3d.notPermitted" message="You do not have permissions to publish this link."></cfif>
		<cfif function EQ "activate">
			<cfset active = 1>
		</cfif>
		<cfif function EQ "deactivate">
			<cfset active = 0>
		</cfif>
		<cfquery datasource="#application.dsn#" name="ins">
			UPDATE links  SET active = <cfqueryparam cfsqltype="cf_sql_integer" value="#active#">
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	
	<cffunction name="delete" access="public" returntype="void">
		<cfargument name="id" type="numeric" required="yes">
		<cfif NOT can('delete')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this link."></cfif>
		<cfquery name="qIsPublished" datasource="#application.dsn#">
			SELECT id FROM links
				WHERE active = 1
					AND id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfif qIsPublished.recordcount AND NOT can('delete_published')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this link."></cfif>
		<cfquery datasource="#application.dsn#" name="delete">
			DELETE FROM links WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	
	
	
	<cffunction name="getlinksCategories" access="public" returntype="query">
		<cfargument name="id" default="0">
		<cfquery datasource="#application.dsn#" name="qCategories">
			SELECT * FROM link_categories
				WHERE 1 = 1
			<cfif id NEQ 0>
				AND id = <cfqueryparam cfsqltype="cf_sql_integer" value="#id#">
			</cfif>
		</cfquery>
		<cfreturn qCategories>
	</cffunction>
	
	<cffunction name="insertCategory" access="public" returntype="void">
		<cfargument name="title" type="string" required="yes">
		<cfargument name="showOnSite" type="boolean" default="1">
		<cfif NOT can('create_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create a link category."></cfif>
		
		<cfquery datasource="#application.dsn#" name="insCat">
			INSERT INTO link_categories (title, showOnSite)
								VALUES
					(
					  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">
					, <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.showOnSite#">
					)
		</cfquery>
	</cffunction>
	<cffunction name="updateCategory" access="public" returntype="void">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="title" type="string" required="yes">
		<cfif NOT can('edit_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this link category."></cfif>
		<cfquery datasource="#application.dsn#" name="u">
			UPDATE link_categories SET title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">
					WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#id#">
		</cfquery>
	
	</cffunction>
	<cffunction name="deleteCategory" access="public" returntype="void">
		<cfargument name="id" required="yes" type="numeric">
		<cfif NOT can('delete_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this link category."></cfif>
		<cfquery datasource="#application.dsn#" name="d">
		DELETE FROM link_categories WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	<cffunction name="activateCategory" access="public" returntype="void">
		<cfargument name="action" default="none">
		<cfargument name="id" default="0">
		<cfif NOT can('edit_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this link category."></cfif>
		<cfset active = 0>
		<cfif action EQ "activate">
			<cfset active = 1>
		</cfif>
		<cfquery name="q" datasource="#application.dsn#">
			UPDATE link_categories SET showOnSite = #active#
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>

</cfcomponent>