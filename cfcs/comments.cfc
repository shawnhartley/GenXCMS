<cfcomponent extends="Event">
	<cffunction name="getComments" access="public" returntype="query" output="no">
		<cfargument name="commentOn" type="string" required="yes">
		<cfargument name="refID" type="numeric" required="yes">
		<cfquery datasource="#application.dsn#" name="qComments">
			SELECT * FROM comments 
				WHERE 	commentOn = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.commentOn#">
					AND refID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.refID#">
					AND approved = '1'
					ORDER BY dateCreated ASC
		</cfquery>
		<cfreturn qComments>
	</cffunction>
	<cffunction name="insertComment" access="public" output="no" returntype="boolean">
		<cfargument name="commentOn" type="string" required="yes">
		<cfargument name="refID" type="numeric" required="yes">
		<cfif arguments.day EQ DateFormat(NOW(), "yyyy/mm/dd")>
			<cfquery name="qInsert" datasource="#application.dsn#">
				INSERT INTO comments (commentOn,refID,content, author, authorEmail, authorURL, approved,dateCreated)
					VALUES (
							 <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.commentOn#">
							,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.refID#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.content#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.author#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.authorEmail#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.authorURL#">
							<cfif application.settings.Var('comments.autoapprove')>
								, '1'
							<cfelse>
								, '0'
							</cfif>
							,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#NOW()#">
							)
			</cfquery>
			<cfif len(application.settings.varStr('comments.notifyTo')) AND NOT application.settings.Var('comments.autoapprove')>
			<cfmail bcc="receipt@c3design.com" subject="Comment held for moderation on #application.settings.varStr('siteTitle')#" from="#application.settings.varStr('comments.notifyTo')#" to="#application.settings.varStr('comments.notifyTo')#">
A new comment has been held for moderation. It will not appear on the live site until it is approved.

Author: #arguments.author# #arguments.authorEmail# #arguments.authorURL#
Comment: #arguments.content#

http://#cgi.HTTP_HOST##application.slashroot#managementcenter
			</cfmail>
			</cfif>
			
		<cfelse>
			<cfthrow type="c3d.commentDateError" message="You must enter today's Date.">
		</cfif>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="getAllComments" access="public" returntype="query">
		<cfargument name="commentOn" default="news">
		<cfif  NOT can('read')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>
		<CFQUERY datasource="#application.dsn#" name="qComments">
			SELECT comments.*, news.headline
			FROM comments LEFT JOIN news ON comments.commentOn = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.commentOn#"> AND comments.refID = news.id
			WHERE 1 = 1
		
		<cfif isDefined("arguments.id")>
			AND comments.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfif>
			ORDER BY approved, dateCreated DESC
		</CFQUERY>

		<cfreturn qComments>
	</cffunction>
	<cffunction name="approve" access="public" returntype="void">
		<cfif  NOT can('moderate')><cfthrow type="c3d.notPermitted" message="You do not have permissions to moderate comments."></cfif>
		<cfif (url.function EQ "approve" OR url.function EQ "unapprove") AND cgi.HTTP_REFERER NEQ "">
			<cfquery name="approveComment" datasource="#application.dsn#">
				UPDATE comments SET approved = <cfif url.function EQ "approve">'1'</cfif>  <cfif url.function EQ "unapprove"> '0'</cfif>
					WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.id#">
			</cfquery>
		</cfif>
	</cffunction>
	
	<cffunction name="delete" access="public" returntype="void">
		<cfif  NOT can('delete')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete comments."></cfif>
		<cfif url.function EQ "delete" AND cgi.HTTP_REFERER NEQ "">
			<cfquery name="deleteComment" datasource="#application.dsn#">
				DELETE FROM comments 
					WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.id#">
			</cfquery>
		</cfif>
	</cffunction>
	
	<cffunction name="getMeta" access="public" returntype="query">
		<cfargument name="table" required="yes">
		<cfargument name="id" required="yes">
		<cfquery name="qMeta" datasource="#application.dsn#">
			SELECT * FROM #arguments.table#
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfreturn qMeta>
	</cffunction>
	
	<cffunction name="update" access="public">
		<cfargument name="id" required="yes">
		<cfargument name="content" required="yes">
		<cfif  NOT can('edit')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit comments."></cfif>
		<cfquery datasource="#application.dsn#" name="upd">
			UPDATE comments SET 
				content = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.content#">
			WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
</cfcomponent>