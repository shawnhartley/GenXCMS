<cfcomponent extends="Event" output="no">
	<cffunction name="init">
		<cfargument name="sortby" default="priority" type="string">
		<cfargument name="category" default="0" type="numeric">
		<cfargument name="query" default="false" type="boolean">
		<cfset Super.init()>
		
		
		<cfif request.manage>
		
		<cfelse>
			<cfif arguments.query>
				<cfset this.myfaqs = getfaqs(userid=session.userid, sortby=arguments.sortby, category=arguments.category)>
			</cfif>
		</cfif>
		
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getfaqs" returntype="query">
		<cfargument name="id" default="0" type="numeric">
		<cfargument name="active" default="">
		<cfargument name="sortby" default="priority">
		<cfargument name="searchfor" default="">
		<cfargument name="category" default="0">
		<cfargument name="limit" default="0" type="numeric">
		<cfif request.manage AND NOT can('read')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>
		<cfquery name="qfaqs" datasource="#application.dsn#">
			SELECT 
				<cfif arguments.limit AND application.dstype EQ 'mssql'>TOP(#limit#)</cfif>
				f.* FROM faqs f
				
				<cfif arguments.category NEQ 0>
					INNER JOIN faqs_map_categories c ON c.faqId = f.id
				</cfif>
			  WHERE 1 = 1
				<cfif arguments.category NEQ 0>
					AND c.categoryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.category#">
				</cfif>
				<cfif id NEQ 0>
					AND f.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
				</cfif>
				<cfif len(arguments.searchfor)>
					AND ( f.question LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchfor#%">
							OR f.answer LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchfor#%">
						)
				</cfif>
				<cfif arguments.active NEQ "">
					AND active = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.active#">
				<cfelseif NOT request.manage>
					AND active = 1
				</cfif>
			ORDER BY <cfswitch expression="#arguments.sortby#">
					 	<cfcase value="question">
							question ASC
						</cfcase>
					 	<cfcase value="updated">
							dateUpdated DESC
						</cfcase>
					 	<cfcase value="filename">
							filename ASC
						</cfcase>
					 	<cfcase value="priority">
							sortorder ASC, question ASC
						</cfcase>
						<cfdefaultcase>
							id DESC
						</cfdefaultcase>
					 </cfswitch>
			<cfif arguments.limit AND application.dstype EQ 'mysql'>LIMIT #limit#</cfif>
		</cfquery>
		<cfreturn qfaqs>
	</cffunction>
	
	
	<cffunction name="insertfaq">
		<cfargument name="active" default="false" type="boolean">
		<cfargument name="sortorder" default="10" type="numeric">
		<cfset var results = {success = false,  faqId = 0}>
		<cfif NOT can('create')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create an FAQ item."></cfif>
		<cfif NOT can('publish')><cfset arguments.active = false></cfif>
		<cfset arguments.createdBy = session.user>
		<cftry>
			<cfset results.faqId = application.DataMgr.insertRecord('faqs', arguments)>
			<cfset updatefaqCategories(faqId = results.faqId, categorylist = arguments.category)>
			<cfset results.success = true>
		<cfcatch>
			<cfset results.cfcatch = cfcatch>
		</cfcatch>
		</cftry>
		<cfreturn results>
	</cffunction>
	
	
	<cffunction name="updatefaq">
		<cfargument name="id" required="yes" type="numeric">
		<cfargument name="active" default="false" type="boolean">
		<cfargument name="sortorder" default="10" type="numeric">
		<cfset var results = {success = false, faqId = arguments.id}>
		<cfset var qIsPublished = application.DataMgr.getRecord('faqs', {id=arguments.id, active=true})>
		<cfif NOT can('edit')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this FAQ item."></cfif>
		<cfif qIsPublished.recordcount AND NOT can('edit_published')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this item."></cfif>
		<cfif NOT can('publish')><cfset arguments.active = false></cfif>
		<cftry>
			<cfset application.DataMgr.updateRecord('faqs', arguments)>
			<cfset updatefaqCategories(faqId = results.faqId, categorylist = arguments.category)>
			<cfset results.success = true>
		<cfcatch>
			<cfset results.cfcatch = cfcatch>
		</cfcatch>
		</cftry>
		<cfreturn results>
	</cffunction>
	
	<cffunction name="deletefaq">
		<cfargument name="id" required="yes" type="numeric">
		
		<cfset var results = {success=true}>
		<cfset var qIsPublished = application.DataMgr.getRecord('faqs', {id=arguments.id, active=true})>
		<cfif NOT can('delete')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this FAQ item."></cfif>
		<cfif qIsPublished.recordcount AND NOT can('delete_published')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this item."></cfif>
		<cfquery datasource="#application.dsn#" name="delR">
			DELETE FROM faqs WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		
		<cfset deleteCategoryMappings(faqId = arguments.id)>
		<cfreturn results>
	</cffunction>
	
	<cffunction name="activate" access="public" returntype="void">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="function" type="string" required="yes">
		<cfif NOT can('publish')><cfthrow type="c3d.notPermitted" message="You do not have permissions to publish FAQs."></cfif>
		<cfif function EQ "activate">
			<cfset active = 1>
		</cfif>
		<cfif function EQ "deactivate">
			<cfset active = 0>
		</cfif>
		<cfquery datasource="#application.dsn#" name="ins">
			UPDATE faqs  SET active = <cfqueryparam cfsqltype="cf_sql_integer" value="#active#">
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>

	
	<!---   ========================================
			faq Categories
			======================================== --->
	<cffunction name="getCategories" access="public">
		<cfquery name="qCats" datasource="#application.dsn#">
			SELECT * FROM faqs_categories ORDER BY sortorder ASC, categoryName ASC
		</cfquery>
		<cfreturn qCats>
	</cffunction>
	
	<cffunction name="getfaqCategories">
		<cfargument name="id" hint="faqId" required="yes" type="numeric">
		<cfquery datasource="#application.dsn#" name="qCats">
			SELECT * FROM faqs_map_categories WHERE faqId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfreturn qCats>
	</cffunction>
	
	<cffunction name="insertCategory" access="public">
		<cfif NOT can('create_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create FAQ categories."></cfif>
		<cfquery name="insCat" datasource="#application.dsn#">
			INSERT INTO faqs_categories (categoryName) VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.categoryName#">)
		</cfquery>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="activateCategory" access="public" returntype="void">
		<cfargument name="action" default="none">
		<cfargument name="id" default="0">
		<cfset var active = 0>
		<cfif NOT can('edit_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this category."></cfif>
		<cfif action EQ "activate">
			<cfset active = 1>
		</cfif>
		<cfquery name="q" datasource="#application.dsn#">
			UPDATE faqs_categories SET active = #active#
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	
	<cffunction name="updateCategory" access="public" returntype="void">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="categoryName" type="string" required="yes">
		<cfif NOT can('edit_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this category."></cfif>
		<cfquery datasource="#application.dsn#" name="u">
			UPDATE faqs_categories SET categoryName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.categoryName#">
					WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#id#">
		</cfquery>
	
	</cffunction>
	
	<cffunction name="updatefaqCategories" access="private" hint="update mappings">
		<cfargument name="faqId" required="yes" type="numeric">
		<cfargument name="categorylist" required="yes" type="string">
		
		<!--- delete old mappings --->
		<cfquery datasource="#application.dsn#" name="delMap">
			DELETE FROM faqs_map_categories WHERE faqId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.faqId#">
		</cfquery>
		<cfif len(arguments.categorylist)>
			<cfquery datasource="#application.dsn#" name="insMap">
				INSERT INTO faqs_map_categories (faqId, categoryId) 
						VALUES
						(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.faqid#">,0)
						<cfloop list="#arguments.categorylist#" index="x">
						,(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.faqid#">, <cfqueryparam cfsqltype="cf_sql_integer" value="#x#">)
						</cfloop>
			</cfquery>
		</cfif>
	</cffunction>

	<cffunction name="deleteCategory" access="public" returntype="void">
		<cfargument name="id" required="yes" type="numeric">
		<cfif NOT can('delete_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this category."></cfif>
		<cfquery datasource="#application.dsn#" name="d">
		DELETE FROM faqs_categories WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfquery datasource="#application.dsn#" name="d">
		DELETE FROM faqs_map_categories WHERE categoryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	
	<cffunction name="deleteCategoryMappings" access="private">
		<cfargument name="faqId" required="yes" type="numeric">
		<cfquery name="delMapp" datasource="#application.dsn#">
			DELETE FROM faqs_map_categories WHERE faqId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.faqId#">
		</cfquery>
		<cfreturn true>
	</cffunction>
	
	<!--- ================================================  --->
	<!---		OUTPUT FUNCTIONS							--->
	<!--- ================================================  --->
	
	<cffunction name="printfaqList" output="no" returntype="string">
		<cfargument name="questionOnly" default="false" type="boolean">
		<cfargument name="query" default="#this.myfaqs#" type="query">
		<cfset var retstr = ''>
		<cfset var link = ''>
		<cfset var desc = ''>
		<cfsavecontent variable="retstr">
			<cfoutput query="arguments.query"><cfsilent>
			<cfset desc = ''>
			<cfset link = application.helpers.buildURL(event=application.settings.varStr('faqs.url') & '/' & id)>
			</cfsilent>
			<dt><a class="question" href="#link#">#arguments.query.question#</a></dt>
			<cfif NOT arguments.questionOnly><dd>#arguments.query.answer#</dd></cfif>
			</cfoutput>
		</cfsavecontent>
		<cfreturn retstr>
	</cffunction>
	
	
	<cffunction name="isLive" returntype="boolean" access="public">
		<cfargument name="q" type="query">
		<cfargument name="row" type="numeric" default="#arguments.q.currentRow#">
		<cfset var ret = false>
		<cfset ret = (q.active[row])>
		<cfreturn ret>
	</cffunction>
	
	<cffunction name="isTop" returntype="boolean" access="public">
		<cfargument name="q" type="query">
		<cfargument name="row" type="numeric" default="#arguments.q.currentRow#">
		<cfset var ret = ''>
		<cfparam name="request.topcount" default="0">

		<cfset ret = (url.start EQ 1 OR url.start EQ "")>										<!--- make sure we're on the first page --->
		<cfset ret = ret AND request.topcount LTE application.settings.var('faqs.toplimit')>
		<cfif NOT ret><cfreturn false></cfif>														<!--- abort if we're already false --->
		<cfset ret = ret AND isLive(q)>
		<cfset ret = ret AND (application.settings.var('faqs.useCategories') AND url.category OR NOT application.settings.var('faqs.useCategories'))>
		<cfif ret><cfset request.topcount += 1></cfif>
		<cfreturn ret>
	</cffunction>
	
</cfcomponent>