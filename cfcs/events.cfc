<cfcomponent extends="Event" output="no">

<cffunction name="init" output="no" access="public" returntype="struct">
	<cfargument name="toplimit" default="#application.settings.var('events.toplimit')#" type="numeric">
	<cfargument name="eventsid" default="">
	<cfargument name="category" default="0" type="numeric">
	<cfset SUPER.init()>
	<cfif structkeyExists(request, 'eventscategory')>
		<cfset arguments.category = request.eventscategory>
	</cfif>
	<cfset this.id = eventsid>
	<cfif toplimit EQ 0><cfset toplimit = -1></cfif>
	<cfset this.toplimit = toplimit>
	<cfif eventsid neq "" AND isNumeric(eventsid)>
		<cfset this.listing = getAll(id=arguments.eventsid, category=arguments.category)>
    <cfelseif eventsid eq "archive">
    	<cfset this.listing = getAll(archive=1,category=arguments.category)>
	<cfelse>
		<cfset this.listing = getAll(category=arguments.category)>
	</cfif>
	<cfset this.topevents = top(listing=this.listing,limit=this.toplimit, category=arguments.category)>
	
	<cfreturn this>
</cffunction>
<cffunction name="getAll" access="public" returntype="query" output="no">
	<cfargument name="id" default="" required="yes">
	<cfargument name="archive" default="0" type="boolean" required="yes">
	<cfargument name="category" default="0" type="numeric">
		<cfif StructKeyExists(request, "eventsCategory")>
			<cfset arguments.category = request.eventsCategory>
		</cfif>
		<cfquery name="getAllevents" datasource="#application.dsn#">
			SELECT events.* FROM events
				<cfif arguments.category>LEFT JOIN events2categories ON events.id = events2categories.eventId</cfif>
				WHERE 	approved 	= 1
					AND	active 		= 1
				<cfif id neq "">
					AND events.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#id#">
				<cfelseif NOT archive>
                    <cfif application.dstype eq "mysql">
						AND NOW() > publishDate
						AND NOW() <= eventDate
						AND ( endDate IS NULL OR NOW() < endDate )
                    <cfelse>
                    	AND getdate() => publishDate
						AND getdate() <= DateAdd(d, 1, eventDate)
						AND ( endDate IS NULL OR getdate() < endDate )
                    </cfif>
				<cfelseif archive>
					<cfif application.dstype EQ 'mysql'>
						AND NOW() > publishDate
						AND NOW() >= eventDate
						AND ( endDate IS NULL OR NOW() < endDate )
					<cfelse>
						AND getdate() > publishDate
						AND getdate() >= eventDate
						AND ( endDate IS NULL OR getdate() < endDate )
					</cfif>
				</cfif>
				<cfif arguments.category>
					AND events2categories.categoryid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.category#">
				</cfif>
				
				ORDER BY sortorder ASC, eventDate #arguments.archive ? 'DESC' : 'ASC' #, publishDate DESC, headline ASC
			</cfquery>
		<cfreturn getAllevents>
	</cffunction>

	<cffunction name="top" output="no" returntype="query" access="public">
		<cfargument name="listing" type="query" required="yes">
		<cfargument name="limit" required="yes" type="numeric">
		<cfargument name="category" default="0" type="numeric">
		
		<cfif StructKeyExists(request, "eventsCategory")>
			<cfset arguments.category = request.eventsCategory>
		</cfif>

		<cfquery name="q" datasource="#application.dsn#" maxrows="#limit#">
			SELECT events.* FROM events
				<cfif arguments.category>
				LEFT JOIN events2categories ON events.id = events2categories.eventId
				</cfif>
				WHERE 	approved 	= 1
					AND	active 		= 1
				<cfif arguments.category>
					AND events2categories.categoryid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.category#">
				</cfif>
				<cfif application.dstype eq "mysql">
					AND NOW() > publishDate
					AND NOW() >= eventDate
					AND ( endDate IS NULL OR NOW() < endDate )
				<cfelse>
					AND getdate() > publishDate
					AND getdate() < eventDate
					AND ( endDate IS NULL OR getdate() < endDate )
				</cfif>
				
				
				ORDER BY sortorder ASC, eventDate ASC, publishDate DESC, headline ASC
		</cfquery>
		<cfreturn q>
	</cffunction>


	<cffunction name="geteventsList">
		<cfargument name="active" default="">
		<cfargument name="approved" default="">
		<cfargument name="category" default="0">
		<cfif NOT can('read')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>
			<cfquery name="qGetevents" datasource="#application.dsn#">
			SELECT events.* FROM events
				<cfif arguments.category>LEFT JOIN events2categories ON events.id = events2categories.eventId</cfif>
				WHERE 1 = 1
					AND <cfif arguments.archive EQ 1> NOT </cfif>
					
				<cfif application.dstype eq "mysql">
					( endDate IS NULL OR NOW() < endDate )
				<cfelse>
					( endDate IS NULL OR getdate() < endDate )
				</cfif>
						
			<cfif arguments.category >
				AND events2categories.categoryid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.category#">
			</cfif>
			<cfif len(arguments.active)>
				AND active = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.active#">
			</cfif>
			<cfif len(arguments.approved)>
				AND approved = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.approved#">
			</cfif>
				ORDER BY  sortorder ASC, eventDate DESC, publishDate DESC, headline ASC
			</cfquery>
		<cfreturn qGetevents>
	</cffunction>

	<cffunction name="getevents">
		<cfargument name="id" default="0">
		<cfif NOT can('read')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>
			<cfquery name="qGetevents" datasource="#application.dsn#">
				SELECT     *
				FROM         events
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
		<cfreturn qGetevents>
	</cffunction>

	<cffunction name="deleteevents">
		<cfargument name="id" default="0">
		<cfif NOT can('delete')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this item."></cfif>
		<cfquery name="qIsPublished" datasource="#application.dsn#">
			SELECT id FROM events
				WHERE approved = 1
					AND id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfif qIsPublished.recordcount AND NOT can('delete_published')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this item."></cfif>
			<cfquery name="qDeleteevents" datasource="#application.dsn#">
				DELETE FROM events
				WHERE id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
			<cfset logger.info('User #session.userid# (#session.username#) deleted "#arguments.headline#" (#arguments.id#)')>
		<cfreturn true>
	</cffunction>

	<cffunction name="addevents">
		<cfargument name="headline" required="yes">
		<cfargument name="summary" default="">
		<cfargument name="content" defualt="">
		<cfargument name="metaDescription" default="">
		<cfargument name="metaKeywords" default="">
		<cfargument name="seotitle" default="">
		<cfargument name="eventDate" required="yes">
		<cfargument name="publishDate" default="#NOW()#">
		<cfargument name="endDate" default="">
		<cfargument name="active" default="false">
		<cfargument name="approved" default="false">
		<cfargument name="category" type="numeric" default="0">
		<cfargument name="sortorder" type="numeric" default="10">
        <cfargument name="fbTwitterImage" default="">
		
		<cfif NOT can('create')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create a events item."></cfif>
		<cfif NOT can('publish')><cfset arguments.approved = false></cfif>
		
		<cfif NOT DirectoryExists( expandPath('../uploads/social/') )>
            <cfdirectory action="create" directory="#expandPath('../uploads/social/')#">
        </cfif>
        <cfif Len ( Trim ( arguments.fbTwitterImage ) ) > 
            <cffile action="upload" accept="image/png, image/jpeg, image/jpg, image/bmp"
            filefield="fbTwitterImage"
            destination="#expandPath('../uploads/social/')#"
            nameconflict="makeunique">
            <cfset arguments.fbTwitterImage = (CFFILE.ServerFile) />
        </cfif> 		
        
		<cfset var myId = application.DataMgr.insertRecord('events', arguments)>
		<cfset application.DataMgr.saveRelationList("events2categories","eventId",myId,"categoryId",arguments.category)>
		<cfset logger.info('User #session.userid# (#session.username#) Added "#arguments.headline#" (#myId#)', {id=myId,Active=arguments.active,approved=arguments.approved})>
		<cfreturn myId>
	</cffunction>

	<cffunction name="updateevents">
		<cfargument name="id" required="yes" type="numeric">
		<cfargument name="headline" required="yes">
		<cfargument name="summary" default="">
		<cfargument name="content" defualt="">
		<cfargument name="metaDescription" default="">
		<cfargument name="metaKeywords" default="">
		<cfargument name="seotitle" default="">
		<cfargument name="eventDate" required="yes">
		<cfargument name="publishDate" default="#NOW()#">
		<cfargument name="endDate" default="">
		<cfargument name="active" default="false">
		<cfargument name="approved" default="false">
		<cfargument name="category" type="numeric" default="0">
		<cfargument name="sortorder" type="numeric" default="10">
        <cfargument name="fbTwitterImage" default="">
        <cfargument name="fbTwitterImageExisting" default="">
        <cfargument name="removefbTwitterImage" default="">          
        
		<cfif NOT can('edit')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this item."></cfif>
		<cfif NOT can('publish')><cfset approved = false></cfif>
		<cfquery name="qIsPublished" datasource="#application.dsn#">
			SELECT id FROM events
				WHERE  approved = 1
					AND id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfif qIsPublished.recordcount AND NOT can('edit_published')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this item."></cfif>

        	<!---Double check the image directory--->
			<cfif NOT DirectoryExists( expandPath('../uploads/social/') )>
                <cfdirectory action="create" directory="#expandPath('../uploads/social/')#">
            </cfif>
            <!---fb twitter image deleter--->
            <cfif isdefined("arguments.removefbTwitterImage") AND arguments.fbTwitterImageExisting eq 1>
            <cffile 
            action = "delete"
            file = "#expandPath('../uploads/social/')##trim(arguments.fbTwitterImageExisting)#">
            <cfset arguments.fbTwitterImageExisting = ''>
            </cfif>  
            <!---fb twitter image adder --->
        	<cfif Len ( Trim ( form.fbTwitterImage ) ) > 
            <cffile action="upload" accept="image/png, image/jpeg, image/jpg, image/bmp"
            filefield="fbTwitterImage"
            destination="#expandPath('../uploads/social/')#"
            nameconflict="makeunique">
                <cfset arguments.fbTwitterImage = (CFFILE.ServerFile) /> 
                <!---<cfdump var="#cffile#" abort>--->
            <cfelse>   
                <cfset arguments.fbTwitterImage = trim(arguments.fbTwitterImageExisting)> 
            </cfif>     		
		
		<cfset myId = application.DataMgr.saveRecord('events', arguments)>
		<cfset application.DataMgr.saveRelationList("events2categories","eventId",myId,"categoryId",arguments.category)>
			<cfset logger.info('User #session.userid# (#session.username#) Updated "#arguments.headline#"', {id=arguments.id,Active=arguments.active,approved=arguments.approved})>
		<cfreturn myId>
	</cffunction>

	<cffunction name="geteventsCategories">
		<cfargument name="id" default="0">
			<cfquery name="qGetevents_categories" datasource="#application.dsn#">
				SELECT     *
				FROM 	   events_categories
					WHERE 1 = 1
				<cfif id NEQ 0>
					AND id = <cfqueryparam cfsqltype="cf_sql_integer" value="#id#">
				</cfif>
				ORDER BY   title
			</cfquery>
		<cfreturn qGetevents_categories>
	</cffunction>

	
	<cffunction name="deleteCategory">
		<cfargument name="id" default="0">
		<cfif NOT can('delete_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this item."></cfif>
			<cfquery name="qDeleteevents_categories" datasource="#application.dsn#">
				DELETE FROM     events_categories
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
			<cfreturn true>
	</cffunction>

	<cffunction name="insertCategory" returntype="void">
		<cfargument name="title" required="yes">
		<cfif NOT can('create_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create this item."></cfif>
				<cfquery name="addevents_categories"  datasource="#application.dsn#">
					INSERT INTO events_categories
					 (
						title
					)
					VALUES
					(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">
					)
				</cfquery>
				
	</cffunction>

	<cffunction name="updateCategory">
		<cfargument name="id" required="yes" type="numeric">
		<cfargument name="title" required="yes">
		<cfif NOT can('edit_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this item."></cfif>
			<cfquery  name="updateevents_categories" datasource="#application.dsn#">
				UPDATE events_categories
				SET
				title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">
				WHERE id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
			<cfreturn true>
	</cffunction>
	<cffunction name="getMyCategories" output="no" returntype="query">
		<cfargument name="id" type="numeric" required="yes">
		<cfreturn application.DataMgr.getRecords('events2categories', {eventId=arguments.id})>
	</cffunction>

<!--- OUTPUT FUNCTIONS --->

	<cffunction name="printeventsList" output="no" returntype="string" access="public">
		<cfargument name="dateFormat" type="string" default="#application.settings.varStr('events.dateformat')#" hint="DateFormat() syntax. Leave blank to hide date">
		<cfargument name="limit" type="numeric" default="#application.settings.var('events.toplimit')#" hint="How many articles to display">
		<cfargument name="source" type="string" default="topevents" hint="Can be either 'topevents' or 'listing'"> 
		<cfargument name="datePosition" type="string" default="after" hint="Display date before or after the Headline. Pass an empty string to hide date.">
		<cfargument name="moreText" type="string" default="Read More" hint="Leave blank to hide link to full article">
		<cfargument name="headlineOnly" type="boolean" default="false" hint="Set true to hide summary in this list">
		<cfargument name="stripHTML" type="boolean" default="false" hint="Set true to strip html from the summary.">
		<cfargument name="linkHeadline" type="boolean" default="true" hint="make the headline a link to the full article">
		<cfargument name="truncateHeadline" type="numeric" default="0" hint="Set number of characters to limit headline length, 0 to output full headline.">
		<cfargument name="headlineWrap" type="string" default="" hint="Wrap headline in this tag. [beginTag , endTag]">
		<cfargument name="urlbase" type="string" default="" hint="Prepend urls with this string">
		<cfset var buildURL = application.helpers.buildURL>
		<cfset var qevents = this[arguments.source]>
		
		<cfsavecontent variable="eventsStr">
		<cfoutput query="qevents" maxrows="#arguments.limit#"><cfset liclass = ''><cfif structKeyExists(this, "id") AND this.id EQ qevents.id><cfset liclass = ' class="active"'></cfif>
			<li#liclass#><cfif datePosition EQ 'before' AND len(arguments.dateFormat)><span class="publishDate">#DateFormat(eventDate, arguments.dateformat)#</span></cfif>
				<cfif len(arguments.headlineWrap)>#ListGetAt(arguments.headlineWrap,1)#</cfif>
				<cfif arguments.linkHeadline>#eventsLink(id, headline, arguments.truncateHeadline, "eventsLink", arguments.urlbase)#<cfelse>#headline#</cfif>
				<cfif len(arguments.headlineWrap)>#ListGetAt(arguments.headlineWrap,2)#</cfif>
				<cfif datePosition EQ 'after' AND len(arguments.dateFormat)><span class="publishDate">#DateFormat(eventDate, arguments.dateformat)#</span></cfif>
				<cfif NOT headlineOnly><cfif arguments.stripHTML><p>#this.stripHTML(summary)#</p><cfelse>#summary#</cfif></cfif>
				
				<cfif len(moreText)>#eventsLink(id, arguments.moreText, 0, 'more', arguments.urlbase)#</cfif></li>
		</cfoutput>
		</cfsavecontent>
		
		<cfreturn eventsStr>
	</cffunction>
	<cffunction name="eventsLink" output="no" returntype="string" access="private">
		<cfargument name="id" required="yes" type="numeric">
		<cfargument name="text" required="yes" type="string">
		<cfargument name="truncate" type="numeric" default="0" hint="Set number of characters to limit link text length, 0 to output full text.">
		<cfargument name="class" type="string" default="more">
		<cfargument name="urlbase" type="string" default="">
		<cfscript>
			var buildURL = application.helpers.buildURL;
			var eventsurl = '';
			var retStr = '';
			if(len(arguments.urlbase)) {
				eventsurl =  arguments.urlbase & '/';
			} else {
				eventsurl = application.settings.varStr('events.url');
			}
			
			
			retStr = '<a class="#arguments.class#" href="' & buildURL(event = eventsurl & '/' & arguments.id, args=(structkeyExists(url, 'category') ? 'category=#url.category#' : '') ) & '">';
			if(arguments.truncate) {
				retStr = retStr & Left(this.stripHTML(arguments.text), truncate) & '&hellip;';
			} else {
				retStr = retStr & arguments.text;
			}
			retStr = retStr & '</a>';
		</cfscript>
		<cfreturn retStr>
	</cffunction>
	
	<cffunction name="isLive" returntype="boolean" access="public">
		<cfargument name="q" type="query">
		<cfargument name="row" type="numeric" default="#arguments.q.currentRow#">
		<cfset var ret = false>
		<cfset ret = (q.active[row] AND q.approved[row] AND NOW() GT q.publishDate[row] AND ( NOW() LT q.endDate[row] OR q.endDate[row] EQ '' ))>
		<cfreturn ret>
	</cffunction>
	
	<cffunction name="isTop" returntype="boolean" access="public">
		<cfargument name="q" type="query">
		<cfargument name="row" type="numeric" default="#arguments.q.currentRow#">
		<cfset var ret = ''>
		<cfparam name="request.topcount" default="0">
		<cfset ret = (url.start EQ 1 OR url.start EQ "")>
		<cfset ret = ret AND request.topcount LT application.settings.var('events.toplimit')>
		<cfif NOT ret><cfreturn false></cfif>
		<cfset ret = ret AND isLive(q)>
		<cfset ret = ret AND (application.settings.var('events.showCategories') AND url.category OR NOT application.settings.var('events.showCategories'))>
		<cfif ret><cfset request.topcount += 1></cfif>
		<cfreturn ret>
	</cffunction>

	<cffunction name="approved" access="public" returntype="void">
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
			UPDATE events SET approved = <cfqueryparam cfsqltype="cf_sql_integer" value="#active#">
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
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
			UPDATE events SET active = <cfqueryparam cfsqltype="cf_sql_integer" value="#active#">
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>   

</cfcomponent>