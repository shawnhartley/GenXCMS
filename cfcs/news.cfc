<cfcomponent extends="Event" output="no">

<cffunction name="init" output="no" access="public" returntype="struct">
	<cfargument name="toplimit" default="#application.settings.var('news.toplimit')#" type="numeric">
	<cfargument name="newsid" default="">
	<cfargument name="category" default="0" type="numeric">
	<cfset SUPER.init()>
	<cfif structkeyExists(request, 'newscategory')>
		<cfset arguments.category = request.newscategory>
	</cfif>
	<cfset this.id = newsid>
	<cfif toplimit EQ 0><cfset toplimit = -1></cfif>
	<cfset this.toplimit = toplimit>
	<cfif newsid neq "" AND isNumeric(newsid)>
		<cfset this.listing = getAll(id=arguments.newsid, category=arguments.category)>
    <cfelseif newsid eq "archive">
    	<cfset this.listing = getAll(archive=1,category=arguments.category)>
	<cfelse>
		<cfset this.listing = getAll(category=arguments.category)>
	</cfif>
	<cfset this.topnews = top(listing=this.listing,limit=this.toplimit, category=arguments.category)>
	<!--- Comments --->
	<cfif application.settings.var('modules') CONTAINS "Comments" AND isNumeric(newsID) AND newsID GT 0>
		<cfset this.comments = createObject("component","comments").getComments(commentOn="news",refID=#newsid#)>
	<cfelse>
		<cfset this.comments = QueryNew("id")>
	</cfif>
	<cfreturn this>
</cffunction>
<cffunction name="getAll" access="public" returntype="query" output="no">
	<cfargument name="id" default="" required="yes">
	<cfargument name="archive" default="0" type="boolean" required="yes">
	<cfargument name="category" default="0" type="numeric">
		<cfif StructKeyExists(request, "newsCategory")>
			<cfset arguments.category = request.newsCategory>
		</cfif>
		<cfquery name="getAllNews" datasource="#application.dsn#">
			SELECT * FROM news  LEFT JOIN news_categories ON news.category = news_categories.id
				WHERE 	approved 	= 1
					AND	active 		= 1
				<cfif id neq "">
					AND news.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#id#">
				<cfelseif NOT archive>
                    <cfif application.dstype eq "mysql">
						AND NOW() > publishDate
						AND ( endDate IS NULL OR NOW() < endDate )
                    <cfelse>
                    	AND getdate() > publishDate
						AND ( endDate IS NULL OR getdate() < endDate )
                    </cfif>
				<cfelseif archive>
					<cfif application.dstype eq "mysql">
						AND NOW() > publishDate
						AND ( endDate IS NOT NULL AND NOW() >= endDate )
                    <cfelse>
                    	AND getdate() > publishDate
						AND ( endDate IS NOT NULL AND getdate() >= endDate )
                    </cfif>
				</cfif>
				<cfif arguments.category>
					AND (
							news.category = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.category#">
						<cfif application.settings.var('news.multipleCategories')>
						OR	news.category LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.category#,%">
						OR	news.category LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%,#arguments.category#">
						OR	news.category LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%,#arguments.category#,%">
						</cfif>
						)
				</cfif>
				
				ORDER BY sortorder ASC, publishDate DESC, headline ASC
			</cfquery>
		<cfreturn getAllNews>
	</cffunction>
	<cffunction name="top" output="no" returntype="query" access="public">
		<cfargument name="listing" type="query" required="yes">
		<cfargument name="limit" required="yes" type="numeric">
		<cfargument name="category" default="0" type="numeric">
		
		<cfif StructKeyExists(request, "newsCategory")>
			<cfset arguments.category = request.newsCategory>
		</cfif>

		<cfquery name="q" datasource="#application.dsn#" maxrows="#limit#">
			SELECT * FROM news  LEFT JOIN news_categories ON news.category = news_categories.id
				WHERE 	approved 	= 1
					AND	active 		= 1
				<cfif arguments.category>
					AND (
							news.category = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.category#">
						<cfif application.settings.var('news.multipleCategories')>
						OR	news.category LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.category#,%">
						OR	news.category LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%,#arguments.category#">
						OR	news.category LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%,#arguments.category#,%">
						</cfif>
						)
				</cfif>
				<cfif application.dstype eq "mysql">
					AND NOW() > publishDate
					AND ( endDate IS NULL OR NOW() < endDate )
				<cfelse>
					AND getdate() > publishDate
					AND ( endDate IS NULL OR getdate() < endDate )
				</cfif>
				
				ORDER BY sortorder ASC, publishDate DESC, headline ASC
		</cfquery>
		<cfreturn q>
	</cffunction>

	<cffunction name="getnewsList">
		<cfargument name="active" default="">
		<cfargument name="approved" default="">
		<cfargument name="category" default="0">
		<cfargument name="headline" default="">
		<cfif NOT can('read')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>
			<cfquery name="qGetnews" datasource="#application.dsn#">
				SELECT     *
				FROM news LEFT JOIN news_categories ON news.category = news_categories.id
				WHERE 1 = 1
					AND <cfif arguments.archive EQ 1> NOT </cfif>
					
				<cfif application.dstype eq "mysql">
					( endDate IS NULL OR NOW() < endDate )
				<cfelse>
					( endDate IS NULL OR getdate() < endDate )
				</cfif>
						
			<cfif arguments.category >
				AND (
							news.category = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.category#">
						<cfif application.settings.var('news.multipleCategories')>
						OR	news.category LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.category#,%">
						OR	news.category LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%,#arguments.category#">
						OR	news.category LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%,#arguments.category#,%">
						</cfif>
						)
			</cfif>
			<cfif len(arguments.active)>
				AND active = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.active#">
			</cfif>
			<cfif len(arguments.approved)>
				AND approved = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.approved#">
			</cfif>
			<cfif len(arguments.headline)>
				AND news.headline LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.headline#%">
			</cfif> 
				ORDER BY  sortorder ASC, publishDate DESC, headline ASC
			</cfquery>
		<cfreturn qGetnews>
	</cffunction>

	<cffunction name="getnews">
		<cfargument name="id" default="0">
		<cfif NOT can('read')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>
			<cfquery name="qGetnews" datasource="#application.dsn#">
				SELECT     *
				FROM         news
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
		<cfreturn qGetnews>
	</cffunction>

	<cffunction name="deletenews">
		<cfargument name="id" default="0">
        <cfargument name="headline" default="">
		<cfif NOT can('delete')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this item."></cfif>
		<cfquery name="qIsPublished" datasource="#application.dsn#">
			SELECT id FROM news
				WHERE approved = 1
					AND id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfif qIsPublished.recordcount AND NOT can('delete_published')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this item."></cfif>
		<cftry>
			<cfquery name="qDeletenews" datasource="#application.dsn#">
				DELETE FROM news
				WHERE id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
			<cfset logger.info('User #session.userid# (#session.username#) deleted "#arguments.headline#" (#arguments.id#)')>
			<cfcatch>
				<cfset logger.fatal('Database error on Delete Article', {id=arguments.id, headline=arguments.headline, exception=cfcatch})>
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn true>
	</cffunction>

	<cffunction name="addnews">
		<cfargument name="headline" required="yes">
		<cfargument name="summary" default="">
		<cfargument name="content" defualt="">
		<cfargument name="metaDescription" default="">
		<cfargument name="metaKeywords" default="">
		<cfargument name="seotitle" default="">
		<cfargument name="publishDate" default="#now()#">
        <cfargument name="createDate" default="#now()#">
		<cfargument name="endDate" default="">
		<cfargument name="active" default="false">
		<cfargument name="approved" default="false">
		<cfargument name="category" type="numeric" default="0">
		<cfargument name="sortorder" type="numeric" default="10">
        <cfargument name="fbTwitterImage" default="">
                
		<cfset var myId = 0>
        <cfif isdefined("session.username")>
        	<cfset arguments.author = session.username>
        </cfif>
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
        
		<cfif NOT can('create')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create a news item."></cfif>
		<cfif NOT can('publish')><cfset arguments.approved = false></cfif>
		<cftry>
			<cfset myId = application.DataMgr.insertRecord('news', arguments)>
			<cfset logger.info('User #session.userid# (#session.username#) Added "#arguments.headline#" (#myId#)', {id=myId,Active=arguments.active,approved=arguments.approved})>
			<cfcatch>
				<cfset logger.fatal('Error on article add', {id=myId, headline=arguments.headline, exception=cfcatch})>
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn myId>
	</cffunction>

	<cffunction name="updatenews">
		<cfargument name="id" required="yes" type="numeric">
		<cfargument name="headline" required="yes">
		<cfargument name="summary" default="">
		<cfargument name="content" defualt="">
		<cfargument name="metaDescription" default="">
		<cfargument name="metaKeywords" default="">
		<cfargument name="seotitle" default="">
		<cfargument name="publishDate" default="#NOW()#">
		<cfargument name="endDate" default="">
		<cfargument name="active" default="false">
		<cfargument name="approved" default="false">
		<cfargument name="category" type="numeric" default="0">
        <cfargument name="fbTwitterImage" default="">
        <cfargument name="fbTwitterImageExisting" default="">
        <cfargument name="removefbTwitterImage" default="">        

		<cfif NOT can('edit')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this item."></cfif>
		<cfif NOT can('publish')><cfset approved = false></cfif>
        
		<cfquery name="qIsPublished" datasource="#application.dsn#">
			SELECT id FROM news
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
        
		<cftry>
			<cfset application.DataMgr.saveRecord('news', arguments)>
			<cfset logger.info('User #session.userid# (#session.username#) Updated "#arguments.headline#"', {id=arguments.id,Active=arguments.active,approved=arguments.approved})>
			<cfcatch>
			<cfset logger.fatal('Error on article update', {id=arguments.id, title=headline.headline, exception=cfcatch})>
			<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn arguments.id>
	</cffunction>

	<cffunction name="getnewsCategories">
		<cfargument name="id" default="0">
			<cfquery name="qGetnews_categories" datasource="#application.dsn#">
				SELECT     *
				FROM 	   news_categories
					WHERE 1 = 1
				<cfif id NEQ 0>
					AND id = <cfqueryparam cfsqltype="cf_sql_integer" value="#id#">
				</cfif>
				ORDER BY   title
			</cfquery>
		<cfreturn qGetnews_categories>
	</cffunction>

	
	<cffunction name="deleteCategory">
		<cfargument name="id" default="0">
		<cfif NOT can('delete_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this item."></cfif>
			<cfquery name="qDeletenews_categories" datasource="#application.dsn#">
				DELETE FROM     news_categories
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
			<cfreturn true>
	</cffunction>

	<cffunction name="insertCategory" returntype="void">
		<cfargument name="title" required="yes">
		<cfif NOT can('create_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create this item."></cfif>
				<cfquery name="addnews_categories"  datasource="#application.dsn#">
					INSERT INTO news_categories
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
			<cfquery  name="updatenews_categories" datasource="#application.dsn#">
				UPDATE news_categories
				SET
				title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">
				WHERE id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
			<cfreturn true>
	</cffunction>


<!--- OUTPUT FUNCTIONS --->

	<cffunction name="printNewsList" output="no" returntype="string" access="public">
		<cfargument name="dateFormat" type="string" default="#application.settings.varStr('news.dateformat')#" hint="DateFormat() syntax. Leave blank to hide date">
		<cfargument name="limit" type="numeric" default="#application.settings.var('news.toplimit')#" hint="How many articles to display">
		<cfargument name="source" type="string" default="topnews" hint="Can be either 'topnews' or 'listing'"> 
		<cfargument name="datePosition" type="string" default="after" hint="Display date before or after the Headline. Pass an empty string to hide date.">
		<cfargument name="moreText" type="string" default="Read More" hint="Leave blank to hide link to full article">
		<cfargument name="headlineOnly" type="boolean" default="false" hint="Set true to hide summary in this list">
		<cfargument name="stripHTML" type="boolean" default="false" hint="Set true to strip html from the summary.">
		<cfargument name="linkHeadline" type="boolean" default="true" hint="make the headline a link to the full article">
		<cfargument name="truncateHeadline" type="numeric" default="0" hint="Set number of characters to limit headline length, 0 to output full headline.">
		<cfargument name="headlineWrap" type="string" default="" hint="Wrap headline in this tag. [beginTag , endTag]">
		<cfargument name="urlbase" type="string" default="" hint="Prepend urls with this string">
		<cfset var buildURL = application.helpers.buildURL>
		<cfset var qnews = this[arguments.source]>
		
		<cfsavecontent variable="newsStr">
		<cfoutput query="qnews" maxrows="#arguments.limit#"><cfset liclass = ''><cfif structKeyExists(this, "id") AND this.id EQ qnews.id><cfset liclass = ' class="active"'></cfif>
			<li#liclass#><cfif datePosition EQ 'before' AND len(arguments.dateFormat)><span class="publishDate">#DateFormat(publishDate, arguments.dateformat)#</span></cfif>
				<cfif len(arguments.headlineWrap)>#ListGetAt(arguments.headlineWrap,1)#</cfif>
				<cfif arguments.linkHeadline>#newsLink(id, headline, arguments.truncateHeadline, "newsLink", arguments.urlbase)#<cfelse>#headline#</cfif>
				<cfif len(arguments.headlineWrap)>#ListGetAt(arguments.headlineWrap,2)#</cfif>
				<cfif datePosition EQ 'after' AND len(arguments.dateFormat)><span class="publishDate">#DateFormat(publishDate, arguments.dateformat)#</span></cfif>
				<cfif NOT headlineOnly><cfif arguments.stripHTML><p>#this.stripHTML(summary)#</p><cfelse>#summary#</cfif></cfif>
				
				<cfif len(moreText)>#newsLink(id, arguments.moreText, 0, 'more', arguments.urlbase)#</cfif></li>
		</cfoutput>
		</cfsavecontent>
		
		<cfreturn newsStr>
	</cffunction>
	<cffunction name="newsLink" output="no" returntype="string" access="private">
		<cfargument name="id" required="yes" type="numeric">
		<cfargument name="text" required="yes" type="string">
		<cfargument name="truncate" type="numeric" default="0" hint="Set number of characters to limit link text length, 0 to output full text.">
		<cfargument name="class" type="string" default="more">
		<cfargument name="urlbase" type="string" default="">
		<cfscript>
			var buildURL = application.helpers.buildURL;
			var newsurl = '';
			var retStr = '';
			if(len(arguments.urlbase)) {
				newsurl =  arguments.urlbase & '/';
			} else {
				newsurl = application.settings.varStr('news.newsurl');
			}
			
			
			retStr = '<a class="#arguments.class#" href="' & buildURL(event = newsurl & '/' & arguments.id) & '" title="' & HTMLEditFormat(stripHTML(text)) & '">';
			if(arguments.truncate) {
				retStr = retStr & Left(this.stripHTML(arguments.text), truncate) & (len(arguments.text) GT truncate ? '&hellip;' : '');
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
		<cfset ret = ret AND request.topcount LT application.settings.var('news.toplimit')>
		<cfif NOT ret><cfreturn false></cfif>
		<cfset ret = ret AND isLive(q)>
		<cfset ret = ret AND (application.settings.var('news.showCategories') AND url.category OR NOT application.settings.var('news.showCategories'))>
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
			UPDATE news SET approved = <cfqueryparam cfsqltype="cf_sql_integer" value="#active#">
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
			UPDATE news SET active = <cfqueryparam cfsqltype="cf_sql_integer" value="#active#">
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>    

</cfcomponent>