<cfcomponent extends="Event" output="no">
	<cffunction name="init">
		<cfargument name="sortby" default="priority" type="string">
		<cfargument name="category" default="0" type="numeric">
		<cfargument name="query" default="false" type="boolean">
		<cfargument name="userid" default="0" type="numeric">
		<cfargument name="groupid" default="0" type="numeric">
		<cfset Super.init()>
		<cfif request.manage>
		
		<cfelse>
			<cfif arguments.query>
				<cfset this.myresources = getresources(userid=arguments.userid, groupid=arguments.groupid, sortby=arguments.sortby, category=arguments.category)>
			</cfif>
		</cfif>
		
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getresources" returntype="query">
		<cfargument name="userid" default="0" type="numeric">
		<cfargument name="group_id" default="0" type="numeric">
		<cfargument name="id" default="0" type="numeric">
		<cfargument name="active" default="">
		<cfargument name="sortby" default="priority">
		<cfargument name="searchfor" default="">
		<cfargument name="category" default="0">
		<cfargument name="limit" default="0" type="numeric">
		<cfif request.manage AND NOT can('read')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>
		<cfquery name="qresources" datasource="#application.dsn#">
			SELECT 
				<cfif arguments.limit AND application.dstype EQ 'mssql'>TOP(#limit#)</cfif>
				f.*, (Select count(*) from user_resources_map_logins WHERE resourceId = f.id) AS usercount,
					 (Select count(*) from user_resources_map_usergroups WHERE resourceId = f.id) AS groupcount
			  FROM user_resources f
				
				<cfif arguments.category NEQ 0>
					INNER JOIN user_resources_map_categories c ON c.resourceId = f.id
				</cfif>
			  WHERE 1 = 1
			  
			<cfif arguments.userid AND arguments.group_id>
				AND ( EXISTS (SELECT 1 FROM user_resources_map_logins l WHERE l.loginId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#"> AND l.resourceId = f.id)
						OR
					  EXISTS ( SELECT 1 FROM user_resources_map_usergroups u WHERE u.group_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.group_id#"> AND u.resourceId = f.id)
					  )
			<cfelse>
				<cfif userid NEQ 0 AND NOT (NOT request.manage AND session.manager)>
					AND EXISTS (SELECT 1 FROM user_resources_map_logins l WHERE l.loginId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#"> AND l.resourceId = f.id)
				</cfif>
				<cfif group_id NEQ 0 AND NOT (NOT request.manage AND session.manager)>
					AND EXISTS ( SELECT 1 FROM user_resources_map_usergroups u WHERE u.group_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.group_id#"> AND u.resourceId = f.id)
				</cfif>
			</cfif>
				<cfif arguments.category NEQ 0>
					AND c.categoryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.category#">
				</cfif>
				<cfif id NEQ 0>
					AND f.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
				</cfif>
				<cfif len(arguments.searchfor)>
					AND ( f.title LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchfor#%">
							OR f.resourcename LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchfor#%">
						)
				</cfif>
				<cfif application.settings.var('resources.publishexpire') AND NOT request.manage>
					<cfif application.dstype EQ 'mysql'>
					AND ( publishDate IS NULL OR NOW() > publishDate )
					AND ( endDate 	  IS NULL OR NOW() < endDate     ) 
					<cfelse>
					AND ( publishDate IS NULL OR getdate() > publishDate )
					AND ( endDate 	  IS NULL OR getdate() < endDate     ) 
					</cfif>
				</cfif>
				<cfif arguments.active NEQ "">
					AND active = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.active#">
				<cfelseif NOT request.manage>
					AND active = 1
				</cfif>
			ORDER BY <cfswitch expression="#arguments.sortby#">
					 	<cfcase value="title">
							title ASC
						</cfcase>
					 	<cfcase value="updated">
							dateUpdated DESC
						</cfcase>
						<cfcase value="published">
							publishDate DESC, dateUpdated DESC, id
						</cfcase>
					 	<cfcase value="filename">
							filename ASC
						</cfcase>
					 	<!---<cfcase value="priority">
							sortorder ASC, publishDate DESC, title ASC
						</cfcase>--->
						<cfdefaultcase>
							id DESC
						</cfdefaultcase>
					 </cfswitch>
			<cfif arguments.limit AND application.dstype EQ 'mysql'>LIMIT #limit#</cfif>
		</cfquery>
		<cfreturn qresources>
	</cffunction>
	
	<cffunction name="getresourceusers">
		<cfargument name="id" required="yes" type="numeric">
		<cfquery name="qusers" datasource="#application.dsn#">
			SELECT loginId FROM user_resources_map_logins
					WHERE resourceId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfreturn qusers>
	</cffunction>
	
	<cffunction name="insertresource">
		<cfargument name="active" default="false" type="boolean">
		<cfargument name="sortorder" default="10" type="numeric">
        <cfargument name="groupaccess" default="5" type="numeric">
        <!---<cfdump var="#arguments#" abort>--->
		<cfset var results = {success = false, fileName = '', resourceId = 0}>
		<cfif NOT can('create')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create User Resources."></cfif>
		<cfif NOT can('publish')><cfset arguments.active = false></cfif>
		<cfif NOT DirectoryExists( ExpandPath( application.settings.var('resources.path') ) )>
			<cfdirectory action="create" directory="#ExpandPath( application.settings.var('resources.path') )#" mode="775">
		</cfif>
		<!--- Ensure each resource is a link or a file, not both, default to the file --->
		<cfif len(arguments.uploadfile) AND len(arguments.linkURL)>
			<cfset arguments.linkURL = ''>
		</cfif>
		
		<cftry>
			<cfif len(arguments.uploadfile)>
			<cffile action="upload" filefield="uploadfile" destination="#ExpandPath(application.settings.var('resources.path'))#" nameconflict="makeunique" result="uploadresult">
			<cfset results.filename = uploadresult.serverfile>
			</cfif>
			<cfset arguments.filename = results.filename>
			<cfset arguments.uploadedBy = session.user>
			<cfset results.resourceId = application.DataMgr.insertRecord('user_resources', arguments)>
			
			<cfset updateResourceCategories(resourceId = results.resourceId, categorylist = arguments.category)>
			<cfset updatePermissions(resourceId = results.resourceId, userlist = arguments.userAccess, grouplist = arguments.groupAccess)>
			<cfset results.success = true>
			<cfset logger.info('User #session.userid# (#session.username#) created "#arguments.title#" (#results.resourceid#)', {id=results.resourceid,linkurl=arguments.linkurl, filename=results.filename,users=arguments.userAccess,groups=arguments.groupAccess})>
		<cfcatch>
			<cfset results.cfcatch = cfcatch>
			<cfset logger.fatal('Error on Insert Resource', {id=results.resourceid, title=arguments.title, linkurl=arguments.linkurl, filename=results.filename, exception=cfcatch, user=session.username})>
		</cfcatch>
		</cftry>
		<cfreturn results>
	</cffunction>
	
	<cffunction name="updatePermissions" access="private">
		<cfargument name="userlist" required="yes">
		<cfargument name="grouplist" required="yes">
		<cfargument name="resourceId" required="yes">
		
		<cfset Application.DataMgr.SaveRelationList("user_resources_map_logins"		,"resourceId",arguments.resourceid,"loginid",arguments.userlist)>
		<cfset Application.DataMgr.SaveRelationList("user_resources_map_usergroups"	,"resourceId",arguments.resourceid,"group_ID",arguments.grouplist)>
	</cffunction>
	
	<cffunction name="deletePermissions" access="private">
		<cfargument name="resourceId" required="yes" type="numeric">
		<cfquery datasource="#application.dsn#" name="delPerms">
			DELETE FROM user_resources_map_logins WHERE resourceId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.resourceId#">;
			DELETE FROM user_resources_map_usergroups WHERE resourceId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.resourceId#">;
		</cfquery>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="updateresource">
		<cfargument name="id" required="yes" type="numeric">
		<cfargument name="active" default="false" type="boolean">
		<cfargument name="uploadfile" default="" type="string">
		<cfargument name="sortorder" default="10" type="numeric">
		<cfargument name="groupAccess" default="">
		<cfargument name="userAccess" default="">
		<cfset var results = {success = false, filename = '', resourceId = arguments.id}>
		<cfset var qIsPublished = ''>
		<cfif NOT can('edit')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this resource."></cfif>
		<cfquery name="qIsPublished" datasource="#application.dsn#">
			SELECT id FROM user_resources
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
				AND active = 1
		</cfquery>
		<cfif qIsPublished.recordcount AND NOT can('edit_published')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this resource."></cfif>
		<cfif NOT can('publish')><cfset arguments.active = false></cfif>
		<cftry>
			<cfif NOT DirectoryExists( ExpandPath( application.settings.var('resources.path') ) )>
				<cfdirectory action="create" directory="#ExpandPath( application.settings.var('resources.path') )#" mode="775">
			</cfif>

			<cfif len(arguments.uploadfile)>
				<cffile action="upload" filefield="uploadfile" destination="#ExpandPath(application.settings.var('resources.path'))#" nameconflict="makeunique" result="uploadresult">
				<cfset results.filename = uploadresult.serverfile>
			<cfelse>
				<cfset results.filename = arguments.origfile>
			</cfif>
			<cfquery name="qIns" datasource="#application.dsn#">
				UPDATE user_resources 	SET
								  title =	 	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">
								 ,filename =	<cfqueryparam cfsqltype="cf_sql_varchar" value="#results.filename#">
								 ,linkURL = 	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.linkURL#">
								 ,description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.description#">
								 ,active = 		<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.active#">
								 ,publishDate = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.publishDate#" null="#(arguments.publishDate EQ '')#">
								 ,endDate = 	<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.endDate#" null="#(arguments.endDate EQ '')#">
								 ,sortorder = 	<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sortorder#">
								 <!---,private = 	<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.private#">
								 ,cat = 	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.cat#">--->
                                 
						WHERE
							id = <cfqueryparam cfsqltype="cf_sql_integer" value="#results.resourceId#">
			</cfquery>
			<cfset updateResourceCategories(resourceId = results.resourceId, categorylist = arguments.category)>
			<cfset updatePermissions(resourceId = results.resourceId, userlist = arguments.userAccess, grouplist=arguments.groupAccess)>
			<cfset results.success = true>
			<cfset logger.info('User #session.userid# (#session.username#) updated "#arguments.title#" (#arguments.id#)', {id=arguments.id,linkurl=arguments.linkurl, filename=results.filename,users=arguments.userAccess,groups=arguments.groupAccess})>
		<cfcatch>
			<cfset results.cfcatch = cfcatch>
			<cfset logger.fatal('Error on Update Resource', {id=results.resourceid, exception=cfcatch, user=session.username})>
		</cfcatch>
		</cftry>
		<cfreturn results>
	</cffunction>
	
	<cffunction name="deleteResource">
		<cfargument name="id" required="yes" type="numeric">
		<cfset var results = {success=true}>
		<cfset var qIsPublished = false>
		<cfif NOT can('delete')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this resource."></cfif>
		<cfquery name="qIsPublished" datasource="#application.dsn#">
			SELECT id FROM user_resources
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfif qIsPublished.recordcount AND NOT can('delete_published')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this resource."></cfif>
		<cfquery datasource="#application.dsn#" name="delR">
			DELETE FROM user_resources WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		
		<cfset deletePermissions(resourceId = arguments.id)>
		<cfset deleteCategoryMappings(resourceId = arguments.id)>
			<cfset logger.info('User #session.userid# (#session.username#) deleted "#arguments.title#" (#arguments.id#)')>
		<cfreturn results>
	</cffunction>
	
	<cffunction name="activate" access="public" returntype="void">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="function" type="string" required="yes">
		<cfif NOT can('publish')><cfthrow type="c3d.notPermitted" message="You do not have permessions to publish this resource."></cfif>
		<cfset var active = 0>
		<cfif function EQ "activate">
			<cfset active = 1>
		</cfif>
		<cfif function EQ "deactivate">
			<cfset active = 0>
		</cfif>
		<cfquery datasource="#application.dsn#" name="ins">
			UPDATE user_resources  SET active = <cfqueryparam cfsqltype="cf_sql_integer" value="#active#">
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>

	
	<!---   ========================================
			Resource Categories
			======================================== --->
	<cffunction name="getCategories" access="public">
		<cfquery name="qCats" datasource="#application.dsn#">
			SELECT * FROM user_resources_categories
				WHERE 1 = 1
				<cfif NOT request.manage>
					AND active = 1
				</cfif>
			ORDER BY sortorder ASC, categoryName ASC
		</cfquery>
		<cfreturn qCats>
	</cffunction>
	
	<cffunction name="getResourceCategories">
		<cfargument name="id" hint="ResourceId" required="yes" type="numeric">
		<cfquery datasource="#application.dsn#" name="qCats">
			SELECT * FROM user_resources_map_categories WHERE resourceId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfreturn qCats>
	</cffunction>
	
	<cffunction name="insertCategory" access="public">
		<cfif NOT can('create_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create a resource category."></cfif>
		<cfquery name="insCat" datasource="#application.dsn#">
			INSERT INTO user_resources_categories (categoryName) VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.categoryName#">)
		</cfquery>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="activateCategory" access="public" returntype="void">
		<cfargument name="action" default="none">
		<cfargument name="id" default="0">
		<cfset var active = 0>
		<cfif NOT can('edit_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this resource category."></cfif>
		<cfif action EQ "activate">
			<cfset active = 1>
		</cfif>
		<cfquery name="q" datasource="#application.dsn#">
			UPDATE user_resources_categories SET active = #active#
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	
	<cffunction name="updateCategory" access="public" returntype="void">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="categoryName" type="string" required="yes">
		<cfif NOT can('edit_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this resource category."></cfif>
		<cfquery datasource="#application.dsn#" name="u">
			UPDATE user_resources_categories SET categoryName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.categoryName#">
					WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#id#">
		</cfquery>
	
	</cffunction>
	
	<cffunction name="updateResourceCategories" access="private" hint="update mappings">
		<cfargument name="resourceId" required="yes" type="numeric">
		<cfargument name="categorylist" required="yes" type="string">
		
		<!--- delete old mappings --->
		<cfquery datasource="#application.dsn#" name="delMap">
			DELETE FROM user_resources_map_categories WHERE resourceId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.resourceId#">
		</cfquery>
		<cfif len(arguments.categorylist)>
			<cfquery datasource="#application.dsn#" name="insMap">
				INSERT INTO user_resources_map_categories (resourceId, categoryId) 
						VALUES
						(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.resourceid#">,0)
						<cfloop list="#arguments.categorylist#" index="x">
						,(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.resourceid#">, <cfqueryparam cfsqltype="cf_sql_integer" value="#x#">)
						</cfloop>
			</cfquery>
		</cfif>
	</cffunction>

	<cffunction name="deleteCategory" access="public" returntype="void">
		<cfargument name="id" required="yes" type="numeric">
		<cfif NOT can('delete_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this resource category."></cfif>
		<cfquery datasource="#application.dsn#" name="d">
		DELETE FROM user_resources_categories WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfquery datasource="#application.dsn#" name="d">
		DELETE FROM user_resources_map_categories WHERE categoryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	
	<cffunction name="deleteCategoryMappings" access="private">
		<cfargument name="resourceId" required="yes" type="numeric">
		<cfquery name="delMapp" datasource="#application.dsn#">
			DELETE FROM user_resources_map_categories WHERE resourceId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.resourceId#">
		</cfquery>
		<cfreturn true>
	</cffunction>
	
	<!--- ================================================  --->
	<!---		OUTPUT FUNCTIONS							--->
	<!--- ================================================  --->
	
	<cffunction name="printResourceList" output="no" returntype="string">
		<cfargument name="titleOnly" default="false" type="boolean">
		<cfargument name="secureDownload" default="true" type="boolean" hint="TODO: non-secure linking">
		<cfargument name="query" default="#this.myresources#" type="query">
		<cfargument name="customURL" default="resources" type="string">
		<cfset var retstr = ''>
		<cfset var link = ''>
		<cfset var desc = ''>
		<cfsavecontent variable="retstr">
			<cfoutput query="arguments.query"><cfsilent>
			<cfset desc = ''>
			<cfif NOT arguments.titleOnly><cfset desc = arguments.query.description></cfif>
			<cfset link = getDownloadLink(title,linkURL,filename,id,customURL)>
			</cfsilent>
			<li><a href="#link#" title="#stripHTML(arguments.query.description, 85)#">#title#</a> #desc#</li>
			</cfoutput>
		</cfsavecontent>
		<cfreturn retstr>
	</cffunction>
	
	<cffunction name="getDownloadLink" output="no">
		<cfargument name="title" required="yes" type="string">
		<cfargument name="linkURL" default="" type="string">
		<cfargument name="filename" default="" type="string">
		<cfargument name="id" required="yes" type="numeric">
		<cfargument name="customURL" default="resources" type="string">
			<cfif len(arguments.linkURL)>
				<cfreturn arguments.linkURL>
			<cfelse>
				<cfif arguments.filename NEQ "">
					<cfreturn application.helpers.BuildURL(event=arguments.customurl, args='action=download&id=' & arguments.id, manage=false)>
				</cfif>
			</cfif>
		<cfreturn ''>
	</cffunction>
	
	<cffunction name="isLive" returntype="boolean" access="public">
		<cfargument name="q" type="query">
		<cfargument name="row" type="numeric" default="#arguments.q.currentRow#">
		<cfset var ret = false>
		<cfset ret = (q.active[row] AND (q.publishDate EQ '' OR NOW() GT q.publishDate[row] ) AND ( NOW() LT q.endDate[row] OR q.endDate EQ '' ))>
		<cfreturn ret>
	</cffunction>
	
	<cffunction name="isTop" returntype="boolean" access="public">
		<cfargument name="q" type="query">
		<cfargument name="row" type="numeric" default="#arguments.q.currentRow#">
		<cfset var ret = ''>
		<cfparam name="request.topcount" default="0">

		<cfset ret = (url.start EQ 1 OR url.start EQ "")>										<!--- make sure we're on the first page --->
		<cfset ret = ret AND request.topcount LTE application.settings.var('resources.toplimit')>
		<cfif NOT ret><cfreturn false></cfif>														<!--- abort if we're already false --->
		<cfset ret = ret AND isLive(q)>
		<cfset ret = ret AND (application.settings.var('resources.useCategories') AND url.category OR NOT application.settings.var('resources.useCategories'))>
		<cfset ret = ret AND (application.settings.var('resources.uselogins') AND url.userid OR NOT application.settings.var('resources.uselogins'))>
		<cfif ret><cfset request.topcount += 1></cfif>
		<cfreturn ret>
	</cffunction>
	<cfscript>
	public query function getAvailableUsers() {
		return application.DataMgr.getRecords(tablename='logins',data={manager=false}, orderby='displayName');
	}
	public query function getAvailableGroups() {
		return application.DataMgr.getRecords(tablename='usergroups', data={manager=false}, orderby='groupName');
	}
	public query function getResourceGroups(required numeric id) {
		return application.DataMgr.getRecords('user_resources_map_usergroups', {resourceId=arguments.id});
	}
	
	public string function getUsersGroup(required numeric loginid) {
		if(NOT (structKeyExists(variables, 'allusers2groups') AND isQuery(variables.allusers2groups))) {
			variables.allusers2groups = application.DataMgr.getRecords('logins2usergroups');
		}
		local.myGroupId = variables.allusers2groups.group_id[variables.allusers2groups['loginId'].indexOf(arguments.loginId)+1];
		return application.DataMgr.getRecord('usergroups',{group_ID=local.myGroupId}).groupName[1];
	}
	</cfscript>
	
</cfcomponent>