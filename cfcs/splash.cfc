<cfcomponent extends="Event">
	<cffunction name="getItems" returntype="query">
		<cfargument name="id" default="0" type="numeric">

        <cfquery name="qitems" datasource="#application.dsn#">
			Select * FROM splash
				WHERE 1 = 1
				<cfif arguments.id>
					AND id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
				</cfif>			            
				ORDER BY sortorder, linkTitle
		</cfquery>
        
		<cfreturn qitems>
	</cffunction>
	
	<cffunction name="insertitem">
		<cfif not can('create')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>
        
		<cfif NOT isNumeric(arguments.sortorder)><cfset arguments.sortorder = 10></cfif>
		<cfif structKeyExists(arguments, 'image') AND len(image)>
			<cfset newimage = uploadImage()>
		<cfelse>
			<cfset newimage = ''>
		</cfif>
		<cfquery name="upd" datasource="#application.dsn#">
			INSERT INTO splash (linkTitle, linkURL, sortorder,image,siteSection) VALUES
						(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.linkTitle#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.linkURL#">
						,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sortorder#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#newimage#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteSection#">

<!--- 						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.teaser#"> --->
						
                        
						)
		</cfquery>
        
	</cffunction>

	<cffunction name="update">
		<cfargument name="id" type="numeric" required="yes">
		<cfif not can('edit')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>
		<cfif structKeyExists(arguments, 'image') AND len(image)>
			<cfset newimage = uploadImage()>
		<cfelse>
			<cfset newimage = ''>
		</cfif>
        <!---<cfdump var="#parentSel#" abort>--->
		<cfquery name="upd" datasource="#application.dsn#">
			UPDATE splash 
					SET linkTitle = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.linkTitle#">
						,linkURL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.linkURL#">
						,sortorder = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sortorder#">
						,siteSection = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteSection#">
<!--- 						,teaser = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.teaser#"> --->
					<cfif len(newimage)>
						,image = <cfqueryparam cfsqltype="cf_sql_varchar" value="#newimage#">
					</cfif>                    						
                    	,sortorder = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sortorder#">
<!--- 						,teaser = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.teaser#"> --->

					
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		
	</cffunction>

	<cffunction name="uploadImage">
			<cfif NOT DirectoryExists( ExpandPath( application.settings.var('splash.path') ) )>
				<cfdirectory action="create" directory="#ExpandPath( application.settings.var('splash.path') )#" mode="775">
			</cfif>
			
			<cffile action="upload" filefield="image" destination="#ExpandPath(application.settings.var('splash.path'))#" nameconflict="makeunique" result="uploadresult">
			<cfreturn uploadresult.serverFile>
	</cffunction>
	<cffunction name="deleteImage" output="no">
		<cfargument name="image" required="yes" type="string">
		<cfargument name="id" required="yes" type="numeric">
		<cftry>
			<cffile action="delete" file="#ExpandPath( application.settings.var('splash.path') & arguments.image)#">
			<cfcatch><cfset session.errorResponse = cfcatch></cfcatch>
		</cftry>
		<cfquery name="qdel" datasource="#application.dsn#">
			DELETE FROM splash WHERE 
					id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
				AND image = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.image#">
		</cfquery>
	</cffunction>
	
	<cffunction name="printParentSelect" output="no" returntype="string">
		<cfargument name="current" default="0" type="numeric">
		<cfargument name="siteSection" default="0" type="numeric">
		<cfargument name="prefix" default="" type="string">
		<cfargument name="self" default="#url.id#" type="numeric">
		<cfargument name="tabindex" default="0" type="numeric">
		<cfscript>
			var ret = '';
			var selected = '';
			var filter = structNew();
			var pages = '';
			var i = 0;
		</cfscript>
		<cfquery name="pages" datasource="#application.dsn#" cachedwithin="#createTimeSpan(0,0,0,20)#">
			SELECT landingId,title
				FROM page
				WHERE parent = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.siteSection#">
				ORDER BY sortorder,title
		</cfquery>
		<cfscript>
			// ArrayAppend(request.pagesquery, pages);
			if(pages.recordcount EQ 0) {
				// ArrayAppend(request.pagesquery, 'early return');
				return ret;
			}
			for (i=1; i LTE pages.recordCount; i = i+1) {
				// ArrayAppend(request.pagesquery, pages.title[i] & ":" & pages.landingId[i] & " > " & pages.recordcount);
				if( arguments.current EQ pages.landingId[i] ) {
					selected = ' selected="selected"';
				} else {
					selected = '';
				}
				if(arguments.self 	 EQ pages.landingId[i]) { selected = 'disabled="disabled"'; }
				
				ret &= '<option value="#pages.landingId[i]#"#selected#>#prefix# #pages.title[i]#</option>' & chr (10);
				ret &= printParentSelect(current=arguments.current, siteSection=pages.landingId[i], prefix='&nbsp;' & arguments.prefix & '&bull;');
			}
			
			if( siteSection EQ 0) {
				return '<select name="siteSection" tabindex="#arguments.tabindex#"><option value="0">No Parent Section</option>' & chr(10) & ret & '</select>';
			}
			return ret;
		</cfscript>
	</cffunction>
	
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- Function: getpageTitle --->
<!--- Purpose: pull titles from pages the splash slide will be associated with,
	  via the "site section" dropdown menu in splash section of M.C. --->
<!--- Mechanics: compares the respective splash.siteSection to the page.landingID in the DB.
				 when a match is found, the title is displayed --->
<!--- Updated: 7/12/16 --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
	<cffunction name="getpageTitle" returntype="query">
		<cfargument name="id" default="0" type="numeric">

        <cfquery name="qitems" datasource="#application.dsn#">
			Select title FROM page
				WHERE 1 = 1
				<cfif arguments.id>
					AND landingID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
				</cfif>			            
				ORDER BY sortorder
		</cfquery>
        
		<cfreturn qitems>
	</cffunction>
</cfcomponent>