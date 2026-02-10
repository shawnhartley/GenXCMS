<cfcomponent extends="Event" output="no">
	<cfproperty name="path" hint="List created from {url.event}.">
	<cfproperty name="slug" hint="Current page name, the last element of {this.path}.">
	<cfproperty name="section" hint="Site section, the first element of {this.path}.">
	<cfproperty name="sectionid" hint="[landingid] of {this.section}.">
	<cfproperty name="parent" hint="This page's parent's slug. Empty string indicates this page is at the root level.">
	<cfproperty name="parentid" hint="Parent's [landingid]. 0 at the root level.">
	<cfproperty name="content" hint="Query object of page content and metadata.">
	<cfproperty name="dynamic" hint="Was this page found in the database?">
	<cfproperty name="include" hint="Was this page found in the view folder?">
	<cfproperty name="description" hint="meta description holder">
	<cfproperty name="keywords" hint="meta keywords holder">
	<cfproperty name="title" hint="page headline">
	<cfproperty name="seotitle" hint="page name for use in [title] tag">
    <cfproperty name="fbTwitterImage" hint="fbTwitterImage for use in fbTwitterImage tag">
    <cfproperty name="fbDescription" hint="special FB description just for FB linking">
    <cfproperty name="fbTitle" hint="special FB title">
    <cfproperty name="twitterTitle" hint="special twitter title">
    <cfproperty name="additionalInfo" hint="string of data used in Work, About sections of this site">
    <cfproperty name="whatsThis" hint="Is this a page? an event? news?">
    
	<cfset variables.cachedwithin = createTimeSpan(0,0,5,0)>

	<cffunction name="init" access="public" output="no">
		<cfset Super.init()>
		<cfset this.id = 0>
		<cfset this.seotitle =  application.settings.var('defaultTitle')>
		<cfif structKeyExists(url,'clearCache') OR structKeyExists(url,'cachebuster')>
			<cfset variables.cachedwithin = createTimeSpan(0,0,0,0)>
		</cfif>
		<cfif NOT request.manage>
			<cfset this.found = page_setup()>
		<cfelse>
			<cfset variables.cachedwithin = createTimeSpan(0,0,0,2)>
			<cfif structKeyExists(url, "id")>
				<cfset this.id = url.id>
			</cfif>
		</cfif>
		<cfset this.cachedCustomFields = getCustomFields(pageId = this.id)>
		<cfset this.pagePermissions = getPermissions(pageId = this.id)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getIdFromPath" output="no" returntype="numeric">
		<cfargument name="path" required="yes">
		<cfargument name="parentid" default="0">

		<cfif ListLen(arguments.path) EQ 1>
			<cfreturn getIdBySlug(ListFirst(arguments.path), arguments.parentId)>
		</cfif>
		<cfreturn getIdFromPath(ListRest(path), getIdBySlug(ListFirst(path), arguments.parentid))>
	</cffunction>
	
	<cffunction name="page_setup" output="no" returntype="boolean">
		<cfparam name="url.event" default="home">
		<cfset this.path = listChangeDelims(url.event, ",", "/")>
		<cfset this.slug = listlast(this.path)>
		<cfset this.section = listfirst(this.path)>
		<cfset this.sectionid = getIdBySlug(this.section, 0)>
		<cfset this.sectiontitle = getTitleBySlug(this.section, 0)>
		<cfset this.id = getidFromPath(this.path)>
		<cfset this.title = application.settings.varStr('siteTitle')>
		<cfset this.seotitle = application.settings.varStr('siteTitle')>
        <cfset this.grantAccess = true>
		<cfset this.description = application.settings.varStr('defaultDescription')>
		<cfset this.keywords = application.settings.varStr('defaultKeywords')>
        <cfset this.fbTwitterImage = "">
        <cfset this.fbDescription = "">
        <cfset this.fbTitle = "">
		<cfset this.twitterTitle = "">
        <cfset this.whatsThis = "">
        
		<cfif listlen(this.path) GT 1>
			<cfset this.parent = listGetAt(this.path, listlen(this.path) - 1)>
		<cfset this.parentid = getidFromPath(ListDeleteAt(this.path, ListLen(this.path)))>
		<cfelse>
			<cfset this.parent = "">
			<cfset this.parentid = 0>
		</cfif>
		<cfset this.content = pageContent(slug = this.slug, parentid = this.parentid)>
			
		<cfset this.dynamic = pageIsDynamic(slug = this.slug, parent = this.parentid)>
		<cfset this.include = false>
		<cfset this.description = application.settings.var("defaultDescription")>
		<cfset this.keywords = application.settings.var("defaultKeywords")>
		
		<cfif this.dynamic>
        <cfset this.id = this.content.landingId>
        <cfset this.whatsThis = "Pages">
        <!--- Check Permissions --->
        <cfif application.settings.modules CONTAINS 'PrivateContent'>
            <cfset this.pagePermissions = getPermissions(pageId = this.id)>
            <cfset this.grantAccess = checkPermissions()>
        </cfif>
        <cfif this.content.redirect >
        
            <cfif len(this.content.redirecturl) or this.content.redirecturl NEQ ''>
                <cflocation addtoken="no" url="#this.content.redirecturl#">
            <cfelse>
                <cfthrow type="c3d.notfound" message="This page is set to redirect, but no URL has been set.">
            </cfif>
        </cfif>
        <cfif this.content.title NEQ "">
            <cfset this.title = this.content.title >
            <cfset this.seotitle = this.content.title & " " & application.settings.var("titleSuffix")>
        </cfif>
        <cfif this.content.seotitle NEQ "">
        	<cfset this.seotitle = this.content.seotitle & " " & application.settings.var("titleSuffix")>
        </cfif>
        <cfif this.content.metaDescription NEQ "">
        	<cfset this.description = this.content.metaDescription>
        </cfif>
        <cfif this.content.metaKeywords NEQ "">
        	<cfset this.keywords = this.content.metaKeywords>
        </cfif>
        <cfif this.content.fbTwitterImage NEQ "">
        	<cfset this.fbTwitterImage = 'https://#cgi.server_name#/uploads/social/#this.content.fbTwitterImage#'>
        </cfif>
        <cfif this.content.fbDescription NEQ "">
        	<cfset this.fbDescription = this.content.fbDescription>
        </cfif> 
        <cfif this.content.fbTitle  NEQ ""> 
        	<cfset this.fbTitle = this.content.fbTitle >
        </cfif>
        <cfif this.content.twitterTitle NEQ "">
        	<cfset this.twitterTitle = this.content.twitterTitle>
        </cfif>                  
        </cfif>
			
		<!--- END PAGE HANDLING --->
		
		<!--- BEGIN LINKS HANDLING --->
		<cfif application.settings.modules CONTAINS "Links">
			<cfset this.links = createObject("component", "links")>
		</cfif>
		<!--- END LINKS HANDLING --->
		
		
		<!--- BEGIN RESOURCES PROVISIONING --->
		<cfif application.settings.modules CONTAINS 'resources'>
			<cfif application.settings.var('resources.api') OR this.path CONTAINS "resources" OR ListChangeDelims(this.path, '/') EQ application.settings.var('resources.customurl')>
				<cfset this.resources = createObject("component", 'resources').init(argumentcollection=url)>
				
				<!--- Download handling --->
				<cfif structKeyExists(url, "action") AND url.action EQ "download">
					<cftry>
					<cfif fileExists(ExpandPath('/view/downloadHandler.cfm'))>
						<cfinclude template="/view/downloadHandler.cfm">
						<cfreturn true>
					<cfelse>
						<cfset file = this.resources.getresources(userid = session.userid, groupid = session.usergroupid, id = url.id)>
						<cfif file.recordcount NEQ 1>
							<cfreturn false>
						<cfelse>
							<cfheader name="Content-Disposition" value="attachment; filename=""#file.id#_#file.filename#""">
							<cfcontent file="#ExpandPath(application.settings.varStr('resources.path'))##file.filename#" deletefile="no">
						</cfif>
					</cfif>
						<cfcatch type="any">
							<cfset this.cfcatch = cfcatch>
							<cfreturn false>
						 </cfcatch>
					</cftry>
				</cfif>
			</cfif>
			
		</cfif>
		
		<!--- END RESOURCES PROVISIONING --->
		
		<!--- BEGIN RSS HANDLING --->
		<cfif application.settings.modules CONTAINS "newsRSS" AND this.section EQ application.settings.var('newsRSS.rssURL')>
			<cfset this.rss = createObject("component","rss").init()>
			<cfset this.rss.doFeed(argumentcollection=url)>
			<cfabort>
		</cfif>
		<!--- END RSS HANDLING --->
		
		<!--- BEGIN RANDOM IMAGE --->
		<cfif application.settings.modules CONTAINS "RandomImage">
			<cfif application.settings.VarStr('randomimage.imagepool') neq "">
				<cfset this.sideimage = createObject("component", "randomimage").getImage>
			</cfif>
		</cfif>
		<!--- END RANDOM IMAGE --->
		
		
		<!--- BEGIN SITE SEARCH --->
		<cfif application.settings.modules CONTAINS 'Search' AND this.section EQ application.settings.var('search.url')>
			<cfparam name="url.q" default="">
			<cfset this.search = createObject("component","search").init(argumentcollection=url)>
			<cfset this.dynamic = true>
			<cfset this.title = "Search Results: " & url.q>
			<cfset this.seotitle = this.title & " " & application.settings.var("titleSuffix")>
		</cfif>
		<!--- END SITE SEARCH --->

		<!--- BEGIN Testimonials --->
		<cfif application.settings.modules CONTAINS 'Testimonials' AND this.section EQ application.settings.var('Testimonials.url')>
			<cfparam name="url.q" default="">
			<cfset this.landings = createObject("component","Testimonials").init(argumentcollection=url)>
			<cfset this.dynamic = true>
			<cfset this.title = "Testimonials: " & url.q>
			<cfset this.seotitle = this.title & " " & application.settings.var("titleSuffix")>
		</cfif>
		<!--- END Testimonials --->	

		<!--- BEGIN CRM --->
		<cfif application.settings.modules CONTAINS 'crm' AND this.section EQ application.settings.var('crm.url')>
			<cfset this.landings = createObject("component","crm").init()>
		</cfif>
		<!--- END Testimonials --->	

		<!--- BEGIN LANDINGS --->
		<cfif application.settings.modules CONTAINS 'landings' AND this.section EQ application.settings.var('landings.url')>
			<cfparam name="url.q" default="">
			<cfset this.landings = createObject("component","landings").init(argumentcollection=url)>
			<cfset this.dynamic = true>
			<cfset this.title = "Landings Result: " & url.q>
			<cfset this.seotitle = this.title & " " & application.settings.var("titleSuffix")>
		</cfif>
		<!--- END LANDINGS --->		
		
		<!--- BEGIN NEWS HANDLING --->
		<cfif application.settings.modules CONTAINS "news">
			<cfif this.section EQ application.settings.varStr("news.newsURL") OR this.section EQ 'home' OR application.settings.var('news.onAllPages') >
				<cfset this.news = createObject("component","news").init(newsid=this.slug)>
			</cfif>
		<cfif this.section EQ application.settings.var("news.newsURL")>
			<cfset this.title = application.settings.var("news.newsTitle")>
			<!--- 404 Handling --->
			<cfif this.section NEQ this.slug AND NOT isNumeric(this.slug) AND this.slug NEQ "archive" OR (this.news.listing.recordCount eq 0 AND NOT ListFind('archive,' & application.settings.var("news.newsurl"), this.slug))>
				<cfreturn false OR this.dynamic>
			<cfelse>
				<cfset this.dynamic = true>
			</cfif>
			
			<cfif isNumeric(this.slug)> <!--- Only update seotitle if we are viewing a single article --->
            <cfset this.whatsThis = "News">
				<cfif this.news.listing.seotitle NEQ "">
					<cfset this.seotitle = this.news.listing.seotitle & ' ' & application.settings.var("titleSuffix")>
					<cfelse>
					<cfset this.seotitle = this.news.listing.headline & ' ' & application.settings.var("titleSuffix")>
				</cfif>
				<cfif this.news.listing.metadescription NEQ "">
					<cfset this.description = this.news.listing.metadescription>
				</cfif>
				<cfif this.news.listing.metakeywords NEQ "">
					<cfset this.keywords = this.news.listing.metakeywords>
				</cfif>

			<cfelseif this.slug EQ "archive">
				<cfset this.title = application.settings.var("news.newsTitle") & " Archive">
				<cfset this.seotitle = this.title & " " & application.settings.var("titleSuffix")>
			</cfif>

		</cfif>
        <cfif this.section NEQ 'home' AND (this.parent eq 'news' OR this.slug eq 'news')>
			<cfif isdefined('this.news.listing.fbTwitterImage') AND this.news.listing.fbTwitterImage NEQ ''>
                <cfset this.fbTwitterImage = 'https://#cgi.server_name#/uploads/social/#this.news.listing.fbTwitterImage#'>
            <cfelse>
                <cfset this.fbTwitterImage = ''>            
            </cfif>
			<cfif isdefined('this.news.listing.fbDescription') AND this.news.listing.fbDescription NEQ ''>
                <cfset this.fbDescription = this.news.listing.fbDescription>
            <cfelse>
                <cfset this.fbDescription = ''>        
            </cfif>
			<cfif isdefined('this.news.listing.fbTitle') AND this.news.listing.fbTitle  NEQ ""> 
                <cfset this.fbTitle = this.news.listing.fbTitle>
            <cfelse>
                <cfset this.fbTitle = ''>        
            </cfif>
			<cfif isdefined('this.news.listing.twitterTitle') AND this.news.listing.twitterTitle  NEQ ""> 
                <cfset this.twitterTitle = this.news.listing.twitterTitle>
            <cfelse>
                <cfset this.twitterTitle = ''>        
            </cfif>                          
        </cfif> 
		</cfif>
		<!--- END NEWS HANDLING --->
		
		
		
		<!--- BEGIN blog HANDLING --->
		<cfif application.settings.modules CONTAINS "blog">
			<cfif this.section EQ application.settings.varStr("blog.blogURL") OR this.section EQ 'home' OR application.settings.var('blog.onAllPages') >
				<cfset this.blog = createObject("component","blog").init(blogid=this.slug)>
			</cfif>
		<cfif this.section EQ application.settings.var("blog.blogURL")>
			<cfset this.title = application.settings.var("blog.blogTitle")>
			<!--- 404 Handling --->
			<cfif this.section NEQ this.slug AND NOT isNumeric(this.slug) AND this.slug NEQ "archive" OR (this.blog.listing.recordCount eq 0 AND NOT ListFind('archive,' & application.settings.var("blog.blogurl"), this.slug))>
				<cfreturn false OR this.dynamic>
			<cfelse>
				<cfset this.dynamic = true>
			</cfif>
			
			<cfif isNumeric(this.slug)> <!--- Only update seotitle if we are viewing a single article --->
            <cfset this.whatsThis = "blog">
				<cfif this.blog.listing.seotitle NEQ "">
					<cfset this.seotitle = this.blog.listing.seotitle & ' ' & application.settings.var("titleSuffix")>
					<cfelse>
					<cfset this.seotitle = this.blog.listing.headline & ' ' & application.settings.var("titleSuffix")>
				</cfif>
				<cfif this.blog.listing.metadescription NEQ "">
					<cfset this.description = this.blog.listing.metadescription>
				</cfif>
				<cfif this.blog.listing.metakeywords NEQ "">
					<cfset this.keywords = this.blog.listing.metakeywords>
				</cfif>

			<cfelseif this.slug EQ "archive">
				<cfset this.title = application.settings.var("blog.blogTitle") & " Archive">
				<cfset this.seotitle = this.title & " " & application.settings.var("titleSuffix")>
			</cfif>

		</cfif>
        <cfif this.section NEQ 'home' AND (this.parent eq 'blog' OR this.slug eq 'blog')>
			<cfif isdefined('this.blog.listing.fbTwitterImage') AND this.blog.listing.fbTwitterImage NEQ ''>
                <cfset this.fbTwitterImage = 'https://#cgi.server_name#/uploads/social/#this.blog.listing.fbTwitterImage#'>
            <cfelse>
                <cfset this.fbTwitterImage = ''>            
            </cfif>
			<cfif isdefined('this.blog.listing.fbDescription') AND this.blog.listing.fbDescription NEQ ''>
                <cfset this.fbDescription = this.blog.listing.fbDescription>
            <cfelse>
                <cfset this.fbDescription = ''>        
            </cfif>
			<cfif isdefined('this.blog.listing.fbTitle') AND this.blog.listing.fbTitle  NEQ ""> 
                <cfset this.fbTitle = this.blog.listing.fbTitle>
            <cfelse>
                <cfset this.fbTitle = ''>        
            </cfif>
			<cfif isdefined('this.blog.listing.twitterTitle') AND this.blog.listing.twitterTitle  NEQ ""> 
                <cfset this.twitterTitle = this.blog.listing.twitterTitle>
            <cfelse>
                <cfset this.twitterTitle = ''>        
            </cfif>                          
        </cfif> 
		</cfif>
		<!--- END blog HANDLING --->
		
		
		<!--- BEGIN EVENT HANDLING --->
		<cfif application.settings.modules CONTAINS "events">
			<cfif this.section EQ application.settings.varStr("events.url") OR this.section EQ 'home' >
				<!---<cfset this.events = createObject("component","events").init(eventsid=this.slug, category = request.category)>--->
                <cfset this.events = createObject("component","events").init(eventsid=this.slug)>
			</cfif>
		<cfif this.section EQ application.settings.var("events.url")>
			<cfset this.title = application.settings.var("events.title")>
			<!--- 404 Handling --->
			<cfif this.section NEQ this.slug AND NOT isNumeric(this.slug) AND this.slug NEQ "archive" OR (this.events.listing.recordCount eq 0 AND NOT ListFind('archive,' & application.settings.var("events.url"), this.slug) )>
				<cfreturn false OR this.dynamic>
			<cfelse>
				<cfset this.dynamic = true>
			</cfif>
			
			<cfif isNumeric(this.slug)> <!--- Only update seotitle if we are viewing a single article --->
            <cfset this.whatsThis = "Events">
				<cfif this.events.listing.seotitle NEQ "">
					<cfset this.seotitle = this.events.listing.seotitle & ' ' & application.settings.var("titleSuffix")>
					<cfelse>
					<cfset this.seotitle = this.events.listing.headline & ' ' & application.settings.var("titleSuffix")>
				</cfif>
				<cfif this.events.listing.metadescription NEQ "">
					<cfset this.description = this.events.listing.metadescription>
				</cfif>
				<cfif this.events.listing.metakeywords NEQ "">
					<cfset this.keywords = this.events.listing.metakeywords>
				</cfif>
			<cfelseif this.slug EQ "archive">
				<cfset this.title = application.settings.var("events.title") & " Archive">
				<cfset this.seotitle = this.title & " " & application.settings.var("titleSuffix")>
			</cfif>
		</cfif>
        <cfif this.section NEQ 'home' AND (this.parent eq 'events' OR this.slug eq 'events')>
			<cfif isdefined('this.events.listing.fbTwitterImage') AND this.events.listing.fbTwitterImage NEQ ''>
                <cfset this.fbTwitterImage = 'https://#cgi.server_name#/uploads/social/#this.events.listing.fbTwitterImage#'>
            <cfelse>
                <cfset this.fbTwitterImage = ''>            
            </cfif>
			<cfif isdefined('this.events.listing.fbDescription') AND this.events.listing.fbDescription NEQ ''>
                <cfset this.fbDescription = this.events.listing.fbDescription>
            <cfelse>
                <cfset this.fbDescription = ''>        
            </cfif>
			<cfif isdefined('this.events.listing.fbTitle') AND this.events.listing.fbTitle  NEQ ""> 
                <cfset this.fbTitle = this.events.listing.fbTitle>
            <cfelse>
                <cfset this.fbTitle = ''>        
            </cfif>
			<cfif isdefined('this.events.listing.twitterTitle') AND this.events.listing.twitterTitle  NEQ ""> 
                <cfset this.twitterTitle = this.events.listing.twitterTitle>
            <cfelse>
                <cfset this.twitterTitle = ''>        
            </cfif>                          
        </cfif>         
		</cfif>
		<!--- END EVENT HANDLING --->
		
		
		
		<!--- Begin PORTFOLIO --->
		<cfif application.settings.modules CONTAINS "Portfolio">
			<cfif this.section EQ application.settings.var("portfolio.portfolioURL")>
				<cfset this.portfolio = createObject("component", "portfolio").init(path=listRest(this.path))>
				<cfif this.portfolio.title NEQ "">
					<cfset this.title = this.portfolio.title>
				</cfif>
				<!--- Handle 404 --->
				<cfif NOT this.portfolio.found>
					<cfset this.dynamic = false>
					<cfreturn false>
				<cfelse>
					<cfset this.dynamic = true>
					<cfif structKeyExists(this.portfolio, "project")><cfset this.seotitle = this.portfolio.project.projectName & ' ' & application.settings.var("titleSuffix")></cfif>
					<cfreturn true>
				</cfif>
			</cfif>
		</cfif>
		<!--- END PORTFOLIO --->
		
		<!--- BEGIN LOCATIONS --->
		<cfif application.settings.modules CONTAINS 'Locations' AND this.section EQ application.settings.var('locations.url')>
			<cfif len(application.settings.varStr('locations.title'))>
				<cfset this.seotitle = application.settings.varStr('locations.title') & ' ' & application.settings.var("titleSuffix")>
			</cfif>
		</cfif>
		<!--- END LOCATIONS --->
		
		<!--- BEGIN COMMENT HANDLING --->
		
		<cfif application.settings.modules CONTAINS "Comments" >
			<cfset this.comments = createObject("component","comments").init()>
			<cfif structKeyExists(form, "commentOn")>
				<cftry>
					<cfset this.comments.insertComment(argumentcollection=form)>
					<cfcatch>
						<cfset this.commentError = cfcatch>
					</cfcatch>
				</cftry>
			</cfif>
		</cfif>
		<!--- END COMMENT HANDLING --->
		
		<!--- 404 HANDLING --->
		<!--- Check to see if this is an included content page --->
		<cfif listlen(this.path) GT 1>
			<cfset this.includefile = ListChangeDelims(this.path, '_') & '.cfm'>
		<cfelse>
			<cfset this.includefile = this.section & '.cfm'>
		</cfif>
		<cfif FileExists(ExpandPath("#application.slashroot#view/#this.includefile#"))>
				<cfset this.include = true>
			<cfelseif FileExists(ExpandPath("#application.slashroot#view/#this.section#.cfm"))>
				<cfset this.include = true>
				<cfset this.includefile = this.section & '.cfm'>
			<cfelseif NOT this.dynamic OR this.content.recordcount EQ 0>
				<!--- Begin TCT Handling --->
					<!--- Check to see if this is a redirect before throwing a 404 --->
				<cfif application.settings.modules CONTAINS "TCT" AND listlen(this.path) EQ 1> <!--- only allow TCT redirects on single-segment paths --->
					<cfset createObject("component", "tct").doTCT(this.section)> <!--- this.section will be the slug to look up --->
				</cfif>
				<!--- END MRT --->
				<cfreturn false>
		</cfif>
		
		<!--- END 404 HANDLING --->

		<cfreturn true>
	
	</cffunction>





	<cffunction name="pageIsDynamic" access="public" returntype="boolean" output="no">
		<cfargument name="slug" type="string" required="yes">
		<cfargument name="parent" type="numeric" required="yes">
		<cfset var test = ''>
		<cfquery name="test" datasource="#application.dsn#" cachedwithin="#variables.cachedwithin#">
			SELECT Count(*) AS returncount from page
					WHERE 	url = <cfqueryparam cfsqltype="cf_sql_varchar" value="#slug#">
						AND parent = <cfqueryparam cfsqltype="cf_sql_varchar" value="#parent#">
						AND approved = 1
						AND isDraft = 0
		</cfquery>
		<cfreturn (test.returncount GT 0)>
	</cffunction>
	<cffunction name="pageContent" access="public" returntype="query" output="no">
		<cfargument name="slug" type="string" required="yes">
		<cfargument name="parentid" type="numeric" default="-1">
		<cfset var pageContent = ''>
		<cfquery name="pageContent" datasource="#application.dsn#" cachedwithin="#variables.cachedwithin#">
			SELECT * from page
					WHERE 	url = <cfqueryparam cfsqltype="cf_sql_varchar" value="#slug#">
						AND approved = 1
						AND isDraft = 0
					<cfif arguments.parentid GTE 0>
						AND parent = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.parentid#">
					</cfif>
		</cfquery>
		<cfreturn pageContent>
	</cffunction>
	
	 
	<cffunction name="getSidebar" access="public" output="no">
		<cfargument name="parent" type="numeric" required="yes">
		<cfargument name="includeOnly" default="" type="string" hint="comma separated numeric list">
		<cfargument name="exclude" default="" type="string" hint="comma separated numeric list">
		<cfargument name="reverseOrder" default="false" type="boolean" hint="used to reverse sort">
		<cfscript>
			var pages = '';
		</cfscript>
		<cfquery name="pages" datasource="#application.dsn#" cachedwithin="#variables.cachedwithin#">
			SELECT landingId, title, parent, url, sortorder FROM page
				WHERE	approved = 1
						AND isDraft = 0
                        AND showNav = 1
						AND parent = <cfqueryparam cfsqltype="cf_sql_varchar" value="#parent#">
				<cfif len(arguments.exclude)>
					AND landingId NOT IN (#arguments.exclude#)
				</cfif>
				<cfif len(arguments.includeOnly)>
					AND landingId IN (#arguments.includeOnly#)
				</cfif>
			ORDER BY sortorder <cfif reverseOrder>DESC, title DESC<cfelse>ASC, title ASC</cfif>			
		</cfquery>
		
		<cfreturn pages>
	</cffunction>
	
	<cffunction name="getSomePages" access="public" output="no">
		<cfargument name="parent" type="numeric" required="yes">
		<cfargument name="includeOnly" default="" type="string" hint="comma separated numeric list">
		<cfargument name="exclude" default="" type="string"     hint="comma separated numeric list">
		<cfargument name="useSortOrder" default="true" type="boolean" hint="set false to use alphabetical only">
		<cfargument name="limitEntriesTo" default="0" type="boolean" hint="zero for no limit">
		<cfset var pages = '' />
		<cfquery name="pages" datasource="#application.dsn#" cachedwithin="#variables.cachedwithin#">
			SELECT landingId, title, parent, fbTwitterImage, url FROM page
				WHERE	approved = 1
						AND isDraft = 0
						AND parent = <cfqueryparam cfsqltype="cf_sql_varchar" value="#parent#">
				<cfif len(arguments.exclude)>
					AND landingId NOT IN (#arguments.exclude#)
				</cfif>
				<cfif len(arguments.includeOnly)>
					AND landingId IN (#arguments.includeOnly#)
				</cfif>
			<cfif useSortOrder>
				ORDER BY sortorder ASC, title ASC
			<cfelse>
				ORDER BY title ASC
			</cfif>
			<cfif limitEntriesTo GT 0>
				LIMIT #limitEntriesTo#
			</cfif>	
		</cfquery>
		
		<cfreturn pages>
	</cffunction>
	
	<cffunction name="getNextSibling">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="siblings" type="query" required="yes">
		<cfset nextSibling = getpage( id = 0 ) >
		<cfset counter = 1 >
		<cfloop query = "siblings">
			<cfif landingID EQ id AND counter NEQ siblings.recordCount>
				<cfset nextSiblingId = siblings.landingID[counter + 1]>
				<cfset nextSibling = getpage( id = nextSiblingId )>
			</cfif>
			<cfset counter += 1 >
		</cfloop>
		<cfreturn nextSibling>
	</cffunction>
	
	<cffunction name="getPreviousSibling">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="siblings" type="query" required="yes">
		<cfset prevSibling = getpage( id = 0 ) >
		<cfset counter = 1 >
		<cfloop query = "siblings">
			<cfif landingID EQ id AND counter NEQ 1>
				<cfset prevSiblingId = siblings.landingID[counter - 1]>
				<cfset prevSibling = getpage( id = prevSiblingId )>
			</cfif>
			<cfset counter += 1 >
		</cfloop>
		<cfreturn prevSibling>
	</cffunction>
	
	<cffunction name="getNextSiblingLoop">
		<cfargument name="id" type="numeric" required="yes">
		<cfset parentId = getParentById( id = id )>
		<cfset siblings = getSomePages( parent = parentId )>
		<cfset nextsibling = getNextSibling( id = id, siblings = siblings)>
		<cfif nextsibling.recordCount LTE 0>
			<cfset nextsibling = getpage( id = siblings.landingID[1] )>
		</cfif>
		<cfreturn nextsibling>
	</cffunction>
	
	<cffunction name="getPreviousSiblingLoop">
		<cfargument name="id" type="numeric" required="yes">
		<cfset parentId = getParentById( id = id )>
		<cfset siblings = getSomePages( parent = parentId )>
		<cfset prevsibling = getPreviousSibling( id = id, siblings = siblings)>
		<cfif prevsibling.recordCount LTE 0>
			<cfset prevsibling = getpage( id = siblings.landingID[siblings.recordCount] )>
		</cfif>
		<cfreturn prevsibling>
	</cffunction>
	
	<cffunction name="getNextCousinLoop">
		<cfargument name="id" type="numeric" required="yes">
		<cfset parentId = getParentById( id = id )>
		<cfset siblings = getSomePages( parent = parentId )>
		<cfset nextCousin = getNextSibling( id = id, siblings = siblings)>
		<cfif nextCousin.recordCount LTE 0>
			<cfset grandparentId = getParentById( id = parentId )>
			<cfset parents = getSomePages( parent = grandparentId )>
			<cfset nextCousin = getpage( id = 0 )>
			<cfloop condition = "nextCousin.recordCount LTE 0">
				<cfset nextParentId = getNextSiblingLoop( id = parentId, siblings = parents ).landingID[1]>
				<cfset parentId = nextParentId >
				<cfset nextCousin = getSomePages( parent = parentId ) >
			</cfloop>
		</cfif>
		<cfreturn nextCousin>
	</cffunction>
	
	<cffunction name="getPreviousCousinLoop">
		<cfargument name="id" type="numeric" required="yes">
		<cfset parentId = getParentById( id = id )>
		<cfset siblings = getSomePages( parent = parentId )>
		<cfset prevCousin = getPreviousSibling( id = id, siblings = siblings)>
		<cfif prevCousin.recordCount LTE 0>
			<cfset grandparentId = getParentById( id = parentId )>
			<cfset parents = getSomePages( parent = grandparentId )>
			<cfset prevCousin = getpage( id = 0 )>
			<cfloop condition = "prevCousin.recordCount LTE 0">
				<cfset prevParentId = getPreviousSiblingLoop( id = parentId, siblings = parents ).landingID[1]>
				<cfset parentId = prevParentId >
				<cfset prevCousin = getSomePages( parent = parentId ) >
			</cfloop>
		</cfif>
		<cfreturn prevCousin>
	</cffunction>
	
	<cffunction name="getParentById" access="public" output="no">
		<cfargument name="id" type="string" required="yes">
		<cfquery name="pages" datasource="#application.dsn#" cachedwithin="#variables.cachedwithin#">
			SELECT parent FROM page
				WHERE	landingId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
		</cfquery>
		<cfif pages.recordcount EQ 0>
			<cfreturn -1>
		</cfif>
		<cfreturn pages.parent>
	</cffunction>
	
	<cffunction name="getidBySlug" access="public" output="no">
		<cfargument name="slug" type="string" required="yes">
		<cfargument name="parentid" type="numeric" default="-1">
		<cfset var pages = '' />
		<cfquery name="pages" datasource="#application.dsn#" cachedwithin="#variables.cachedwithin#">
			SELECT landingId FROM page
				WHERE	approved = 1
						AND isDraft = 0
						AND url = <cfqueryparam cfsqltype="cf_sql_varchar" value="#slug#">
					<cfif arguments.parentid GTE 0>
						AND parent = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.parentid#">
					</cfif>
		</cfquery>
		<cfif pages.recordcount EQ 0>
			<cfreturn -1>
		</cfif>
		<cfreturn pages.landingId>
	</cffunction>
	
	<cffunction name="getTitleBySlug" access="public" output="no">
		<cfargument name="slug" type="string" required="yes">
		<cfargument name="parentid" type="numeric" default="-1">
		<cfset var pages = '' />
		<cfquery name="pages" datasource="#application.dsn#" cachedwithin="#variables.cachedwithin#">
			SELECT title FROM page
				WHERE	approved = 1
						AND isDraft = 0
						AND url = <cfqueryparam cfsqltype="cf_sql_varchar" value="#slug#">
					<cfif arguments.parentid GTE 0>
						AND parent = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.parentid#">
					</cfif>
		</cfquery>
		<cfif pages.recordcount EQ 0>
			<cfreturn ''>
		</cfif>
		<cfreturn pages.title>
	</cffunction>
	
	<cffunction name="hasChildren" access="public" output="no">
		<cfargument name="parentid" type="numeric" required="yes">
		<cfset var test = '' />
		<cfquery name="test" datasource="#application.dsn#" cachedwithin="#CreateTimeSpan(0,0,0,5)#"><!--- only five seconds because this is used in the managementcenter as well --->
			SELECT Count(*) AS childCount FROM page
				WHERE	1 = 1
					<cfif NOT request.manage>
						AND approved = 1
						AND isDraft = 0
                        AND showNav = 1
					</cfif>
						AND parent = <cfqueryparam cfsqltype="cf_sql_varchar" value="#parentid#">
		</cfquery>
		<cfreturn test.childCount>
	</cffunction>
	
	<!---Deprecated Legacy function, use simpleNav --->
	<cffunction name="printNavList" access="public" output="no" returntype="string">
		<cfargument name="path" default="#this.path#" type="string">
		<cfargument name="urlbase" default="#Listfirst(path)#" type="string">
		<cfargument name="fullList" default="no" type="boolean">
		<cfargument name="withChildren" default="false" type="boolean" hint="Set true to show children on all pages, not just active page">
		<cfargument name="appendActiveHTML" default="">
		<cfargument name="appendTo" default="li">
		<cfargument name="parentid" default="#this.sectionid#">
		<cfargument name="includeOnly" default="" type="string" hint="comma separated numeric list">
		<cfargument name="exclude" default="" type="string"     hint="comma separated numeric list">
		<cfargument name="skipLevels" default="0" type="numeric" hint="skip this many parent levels, not rational when passed with withChildren=true">
		<cfargument name="maxDepth" default="0" type="numeric" hint="set to number of levels to return, 0 returns all">
		<cfargument name="parentIsActive" default="true" hint="let recursion know whether it is coming from an active page or not.">
		<cfscript>
			var sb = createObject("java", "java.lang.StringBuilder").init();
			var slug = ListLast(path);
			var parent = ListFirst(path);
			var pagelist = '';
			var liclass = '';
			var i = 0;
			if(fullList) {
				parentid = 0;
				urlbase = "";
				path = "c3dx," & path;
			} else {
				if(parentid EQ 0 OR parentid EQ '') {
					parentid = this.sectionid;
				}
			}
			pagelist = getSidebar(parent = parentid, includeOnly = includeOnly, exclude = exclude);
		</cfscript>
		
		<cfloop query="pagelist">
			<cfscript>
			if (ListFirst(ListRest(arguments.path)) EQ pagelist.url AND arguments.parentIsActive) { liclass = 'active'; } else { liclass = ''; }
			
			if(hasChildren(pagelist.landingid)) { liclass &= ' parent'; }
			if( (NOT (liclass CONTAINS 'active' AND liclass CONTAINS 'parent')) AND arguments.skipLevels GT 0) {
				continue;
			}
			sb.append('<li class="').append(pagelist.url).append(' ').append(liclass).append('"><a href="').append(application.helpers.buildURL(event='#urlbase#/#pagelist.url#')).append('">#(pagelist.title)#');
			if(len(appendActiveHTML) AND liclass CONTAINS 'active' AND appendTo EQ 'a') {
				liString = liString & arguments.appendActiveHTML;
			}
			sb.append('</a>');
			if( liclass CONTAINS 'parent' AND arguments.maxDepth NEQ 1 AND ( liclass CONTAINS 'active' OR withChildren ) ) {
				sb.append('<ul class="vertical menu">');
				if( arguments.skipLevels GT 0 ) {
					return printNavList(path = listRest(path), urlbase =  "#urlbase#/#pagelist.url#", parentid = pagelist.landingid, skipLevels = arguments.skipLevels - 1, maxDepth = arguments.maxDepth - 1, parentisActive=(liclass CONTAINS 'active'));
				}
				sb.append(printNavList(path = listRest(path), urlbase =  "#urlbase#/#pagelist.url#", parentid = pagelist.landingid, maxDepth = arguments.maxDepth - 1, parentisActive=(liclass CONTAINS 'active')));
				
				sb.append('</ul>');
			}
			if(len(appendActiveHTML) AND liclass CONTAINS 'active' AND appendTo EQ 'li') {
				sb.append(arguments.appendActiveHTML);
			}
			sb.append('</li>');
			</cfscript>
		</cfloop>
		
		<cfreturn sb.toString()>
	</cffunction>
	
	<!---Deprecated Legacy function, use simpleNav --->
	<cffunction name="printMobileNavList" access="public" output="no" returntype="string">
		<cfargument name="path" default="#this.path#" type="string">
		<cfargument name="urlbase" default="#Listfirst(path)#" type="string">
		<cfargument name="fullList" default="no" type="boolean">
		<cfargument name="withChildren" default="true" type="boolean" hint="Set true to show children on all pages, not just active page">
		<cfargument name="appendActiveHTML" default="">
		<cfargument name="appendTo" default="li">
		<cfargument name="parentid" default="#this.sectionid#">
		<cfargument name="includeOnly" default="" type="string" hint="comma separated numeric list">
		<cfargument name="exclude" default="" type="string"     hint="comma separated numeric list">
		<cfargument name="skipLevels" default="0" type="numeric" hint="skip this many parent levels, not rational when passed with withChildren=true">
		<cfargument name="maxDepth" default="0" type="numeric" hint="set to number of levels to return, 0 returns all">
		<cfargument name="parentIsActive" default="true" hint="let recursion know whether it is coming from an active page or not.">
		<cfscript>
			var sb = createObject("java", "java.lang.StringBuilder").init();
			var slug = ListLast(path);
			var parent = ListFirst(path);
			var pagelist = '';
			var liclass = '';
			var submenu = false;
			var i = 0;
			if(fullList) {
				parentid = 0;
				urlbase = "";
				path = "c3dx," & path;
			} else {
				if(parentid EQ 0 OR parentid EQ '') {
					parentid = this.sectionid;
				}
			}
			pagelist = getSidebar(parent = parentid, includeOnly = includeOnly, exclude = exclude);
		</cfscript>
		
		<cfloop query="pagelist">
			<cfscript>
				// Set class to active if initial page = built link
				if (ListFirst(ListRest(arguments.path)) EQ pagelist.url AND arguments.parentIsActive) { liclass = 'active'; } else { liclass = ''; }
				
				// If it has a dropdown attatch the class
				if(hasChildren(pagelist.landingid)) { liclass &= ' has-submenu'; }
				
				// If the current page doesn't have children ignore and move forward
				if( (NOT (false)) AND arguments.skipLevels GT 0) {
					continue;	
				}
				
				// Build the list item and link for the top-level navigation
				sb.append('<li class="').append(pagelist.url).append(' ').append(liclass).append('"><a href="').append(application.helpers.buildURL(event='#urlbase#/#pagelist.url#')).append('">#(pagelist.title)#');
				if(len(appendActiveHTML) AND liclass CONTAINS 'active' AND appendTo EQ 'a') {
					liString = liString & arguments.appendActiveHTML;
				}
				sb.append('</a>');
				
				// If the list item being built has children then intterupt and place a <ul> full of children before the closing </li>
				if( liclass CONTAINS 'has-submenu' AND arguments.maxDepth NEQ 1 AND ( liclass CONTAINS 'active' OR withChildren ) ) {
					sb.append('<ul class="vertical menu">');
						
						// Always add a nested back button with a # href for Off-Canvas sliding menus		
						sb.append('<li class="back"><a href="##">Back</a></li>');
												
						// Re-output the parent link at the top of the list since you cannot
						// click the parent link initially (it slides to the subnav!)
						// be sure not to re-attach the parent property or else it'll create a loop
						sb.append('<li><a href="').append(application.helpers.buildURL(event='#urlbase#/#pagelist.url#')).append('">#(pagelist.title)#</a>');
						
						if( arguments.skipLevels GT 0 ) {
							return printNavList(path = listRest(path), urlbase =  "#urlbase#/#pagelist.url#", parentid = pagelist.landingid, skipLevels = arguments.skipLevels - 1, maxDepth = arguments.maxDepth - 1, parentisActive=(liclass CONTAINS 'active'));
						}
						
						sb.append(printNavList(path = listRest(path), urlbase =  "#urlbase#/#pagelist.url#", parentid = pagelist.landingid, maxDepth = arguments.maxDepth - 1, parentisActive=(liclass CONTAINS 'active')));
					
					sb.append('</ul>');
				}
				if(len(appendActiveHTML) AND liclass CONTAINS 'active' AND appendTo EQ 'li') {
					sb.append(arguments.appendActiveHTML);
				}
				sb.append('</li>');
			</cfscript>
		</cfloop>
		
		<cfreturn sb.toString()>
	</cffunction>
	
	<!--- This function was made to unify printNavList and printMobileNavList, and to be inline with Foundation 6 features. --->
	<!--- Some functionality of printNavList has been deprecated, so legacy functions remain. --->
	<cffunction name='simpleNav' access="public" output="no" returntype="string">
		<cfargument name="path" default="#this.path#" type="string">
		<cfargument name="urlbase" default="#Listfirst(path)#" type="string">
		<cfargument name="fullList" default="false" type="boolean">
		<cfargument name="withChildren" default="never" type="string" hint="determines whether subnav is shown. set to 'active','always', or 'never'">
		<cfargument name="reverseOrder" default="false" type="boolean" hint="Use to reverse nav sortorder, IE: main nav">
		<cfargument name="parentid" default="#this.sectionid#">
		<cfargument name="exclude" default="" type="string" hint="comma separated numeric list">
		<cfscript>
			if(fullList) {
				parentid = 0;
				urlbase = "";
				path = "c3dx," & path;
			} else {
				if(parentid EQ 0 OR parentid EQ '') {
					parentid = this.sectionid;
				}
			}
			
			var navstring = '';
			if (reverseOrder) {
				var pagelist = getSidebar(parent = parentid, reverseOrder = true, exclude = exclude);
			} else {
				var pagelist = getSidebar(parent = parentid, exclude= exclude);
			}
			
			navstring &= simpleNavLoop(path = path, urlbase = urlbase, withChildren = withChildren, parentid = parentid, reverseOrder = reverseOrder, exclude = exclude);
		</cfscript>
		
		<cfreturn navstring>
	</cffunction>
	
	<cffunction name='simpleNavLoop' access="private" returntype="string">
		<cfargument name="path" required='true' type="string">
		<cfargument name="urlbase" required='true' type="string">
		<cfargument name="withChildren" default="never" type="string" hint="determines whether subnav is shown. set to 'active','always', or 'never'">
		<cfargument name="parentid" required='true'>
		<!--- Not sure reverse order will ever be needed here, but hey --->
		<cfargument name="reverseOrder" default="false" type="boolean" hint="Use to reverse nav sortorder">
		<cfargument name="exclude" default="" type="string" hint="comma separated numeric list">
		<cfscript>
			if (reverseOrder) {
				var pagelist = getSidebar(parent = parentid, reverseOrder = true, exclude = exclude);
			} else {
				var pagelist = getSidebar(parent = parentid, exclude= exclude);
			}
			var slug = ListLast(path);
			var parent = ListFirst(path);
			
			var partial_navstring = '';
		</cfscript>
		<cfloop query="pagelist">
			<cfscript>
				var liclass = '';
				
				//Check if this li is the active or the parent section, make active
				if (listFind(path,pagelist.url) AND (parentid EQ pagelist.parent)){
					liclass = 'active';
				} 
				// anchor tag
				var aelement = '<a href="'& application.helpers.buildURL(event='#urlbase#/#pagelist.url#') &'">' & pagelist.title & '</a>';
				// open li tag, add anchor
				var lielement = '<li class="'& pagelist.url & ' ' & liclass & '">'& aelement ;
				
					// if there are children to show AND link is active and show children on active links OR always show children 
					if ((((liclass EQ 'active') AND (withChildren EQ 'active' )) OR (withChildren EQ 'always' )) AND (hasChildren(pagelist.landingid) GT 0)){
						var sub_path = path & ',' & pagelist.url;
						var sub_urlbase = urlbase & '/' & pagelist.url;
						var sub_parentid = pagelist.landingid;
						var innerlielements = simpleNavLoop(path = sub_path, urlbase = sub_urlbase, withChildren = withChildren, parentid = sub_parentid);
						
						// open ul tag, add li elements, close
						var ulelement = '<ul class="vertical menu">' & innerlielements & '</ul>';
						lielement &= ulelement;
					}
				// close li tag
				lielement &= '</li>';
				
				partial_navstring &= lielement;
			</cfscript>
		</cfloop>
		<cfreturn partial_navstring>
	</cffunction>
	

	<cffunction name="printParentSelect" output="no" returntype="string">
		<cfargument name="current" default="0" type="numeric">
		<cfargument name="parent" default="0" type="numeric">
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
		SELECT landingId,parent,title
			FROM page
			WHERE parent = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.parent#">
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
			if(IsDefined("arguments.self") && arguments.self NEQ 0 && ( arguments.self EQ pages.landingId[i] || arguments.self EQ pages.parent[i]) ) { selected = 'disabled="disabled"'; }
			
			ret &= '<option value="#pages.landingId[i]#"#selected#>#prefix# #pages.title[i]#</option>' & chr (10);
			ret &= printParentSelect(current=arguments.current, parent=pages.landingId[i], prefix='&nbsp;' & arguments.prefix & '&bull;');
		}
		
		if( parent EQ 0) {
			return '<select name="parent" tabindex="#arguments.tabindex#"><option value="0">No Parent Section</option>' & chr(10) & ret & '</select>';
		}
		return ret;
	</cfscript>
	</cffunction>

	<cffunction name="getpagesList">
		<cfargument name="FilterSearchString" default="">
		<cfargument name="Orderby" default="landingid" required="no" type="string">
		<cfargument name="Sort" default="asc" required="no" type="string">
		<cfset var qGetpages = '' />
		<cfif NOT can('read')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>
		<cfquery name="qGetpages" datasource="#application.dsn#">
			SELECT     *
			FROM page
				WHERE 1 = 1
			ORDER BY  #arguments.Orderby# #arguments.Sort#
		</cfquery>
		<cfreturn qGetpages>
	</cffunction>

	<cffunction name="getpage" returntype="query">
		<cfargument name="id" required="yes">
		<cfset var getpage = '' />
		<cfquery datasource="#application.dsn#" name="getpage">
			SELECT *
			FROM page
			WHERE landingId=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfreturn getpage>
	</cffunction>

		
	<cffunction name="deletepages">
		<cfargument name="id" required="yes">
		<cfset var qDeletepages = '' />
		<cfset var qDeleteFields = '' />
		<cfset var qIsPublished = '' />
		<cfquery name="qIsPublished" datasource="#application.dsn#">
			SELECT landingId FROM page
				WHERE landingId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
					AND isDraft = 0
					AND approved = 1
		</cfquery>
		<cfif NOT can('delete')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this page."></cfif>
		<cfif qIsPublished.recordcount AND NOT can('delete_published')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this page."></cfif>
		<cftry>
		<cfquery name="qDeletepages" datasource="#application.dsn#">
			DELETE FROM page
			WHERE landingId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfquery datasource="#application.dsn#" name="qDeleteFields">
				DELETE FROM page_customfields
					WHERE pageId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">;
		</cfquery>
		<cfquery name="qDeletePerms" datasource="#application.dsn#">
				DELETE FROM page_permissions
					WHERE pageId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">;
		</cfquery>
		<cfset logger.info('User #session.userid# (#session.username#) deleted "#arguments.title#" (#arguments.id#)', {parent=arguments.parent,id=arguments.id,url=arguments.url})>
		<cfcatch>
			<cfset logger.fatal('Database error on Delete Page', {id=arguments.id, title=arguments.title, url=arguments.url, exception=cfcatch})>
			<cfrethrow>
		</cfcatch>
		</cftry>
		<cfcache action="flush">
		<cfreturn true>
	</cffunction>
	
	<cffunction name="addpages">
		<cfargument name="title" required="no" default="">
		<cfargument name="contentleft" required="no" default="">
		<cfargument name="contentright" required="no" default="">
		<cfargument name="notes" required="no" default="">
		<cfargument name="metaDescription" required="no" default="">
		<cfargument name="metaKeywords" required="no" default="">
		<cfargument name="url" required="no" default="">
		<cfargument name="redirect" required="no" default="0">
		<cfargument name="redirecturl" required="no" default="">
		<cfargument name="approved" required="no" default="0">
		<cfargument name="isDraft" required="no" default="0">
		<cfargument name="author" required="no" default="#session.userid# #session.username#">
		<cfargument name="showNav" required="no" default="0">
		<cfargument name="parent" required="no" default="">
		<cfargument name="seotitle" required="no" default="">
		<cfargument name="sortorder" required="no" default="">
		<cfargument name="customfield" required="no" default="">
        <cfargument name="createDate" default="#NOW()#">
		<cfargument name="rw" required="no" default="">
		<cfargument name="additionalInfo" required="no" default="">
        <cfargument name="fbTwitterImage" default="">       

		<cfset var addpages = '' />
		<cfset var myId = 0 />
		<cfif NOT can('create')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create a page."></cfif>
		<cfif NOT can('publish')><cfset arguments.approved = false></cfif>
		<cfif arguments.url EQ ''><cfset arguments.url = getSlugFromTitle(left(arguments.title,50))></cfif>

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
		
		<cftry>
		<cftransaction>
			<cfset myId = application.DataMgr.insertRecord('page', arguments)>
			<cfset this.id = myId>
			<cfif len(arguments.customfield)>
				<cfset updateCustomFields(customfieldlist = arguments.customfield, customvaluelist = arguments.customvalue)>
			</cfif>
			<cfif len(arguments.rw) AND len(arguments.limitMethod)>
				<cfset updatePermissions(rw = arguments.rw, limitMethods = arguments.limitMethod, limitArgs=arguments.limitArg)>
			</cfif>
		</cftransaction>
		<cfset logger.info('User #session.userid# (#session.username#) Added "#arguments.title#" (#myId#)', {id=myId,Draft=arguments.isDraft,approved=arguments.approved, url=arguments.url, nav=arguments.showNav,parent=arguments.parent})>
		<cfcatch>
			<cfset logger.fatal('Error on page add', {id=myId, title=arguments.title, url=arguments.url, exception=cfcatch})>
			<cfrethrow>
		</cfcatch>
		</cftry>
		<cfcache action="flush">
		<cfreturn myId>
	</cffunction>

	<cffunction name="updatepages">
		<cfargument name="id" required="yes" type="numeric">
		<cfargument name="title" required="no">
		<cfargument name="contentleft" required="no">
		<cfargument name="contentright" required="no">
		<cfargument name="notes" required="no">
		<cfargument name="metaDescription" required="no">
		<cfargument name="metaKeywords" required="no">
		<cfargument name="url" required="no">
		<cfargument name="pagetype" required="no">
		<cfargument name="isDraft" required="no">
		<cfargument name="approved" required="no">
		<cfargument name="showNav" required="no">
		<cfargument name="parent" required="no">
		<cfargument name="seotitle" required="no">
		<cfargument name="sortorder" required="no">
		<cfargument name="customfield" default="">
		<cfargument name="rw" default="">
		<cfargument name="redirect" default="0">
		<cfargument name="redirecturl" default="">
		<cfargument name="limitMethod" default="">
        <cfargument name="fbTwitterImage" default="">
        <cfargument name="fbTwitterImageExisting" default="">
        <cfargument name="removefbTwitterImage" default="">
        <cfargument name="additionalInfo" required="no" default="">

		<cfset var updatepage = '' />
		<cfset var addpages = '' />
		<cfset var qIsPublished = ''>
		<cfset arguments.landingId = arguments.id>
		<cfif NOT can('edit')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this page."></cfif>
		<cfquery name="qIsPublished" datasource="#application.dsn#">
			SELECT landingId FROM page
				WHERE landingId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
					AND isDraft = 0
					AND approved = 1
		</cfquery>
		<cfif qIsPublished.recordcount AND NOT can('edit_published')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this page."></cfif>
		<cfif NOT can('publish')><cfset arguments.approved = false></cfif>
		<cfif parent EQ ""><cfset arguments.parent = 0></cfif>
		<cfif arguments.url EQ ''><cfset arguments.url = getSlugFromTitle(left(arguments.title,50))></cfif>
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
		<cftransaction>
		<cfset application.DataMgr.updateRecord('page', arguments)>

		<cfif len(arguments.customfield)>
			<cfset updateCustomFields(customfieldlist = arguments.customfield, customvaluelist = arguments.customvalue)>
		</cfif>
		<cfif len(arguments.rw) AND len(arguments.limitMethod)>
			<cfset updatePermissions(rw = arguments.rw, limitMethods = arguments.limitMethod, limitArgs=arguments.limitArg)>
		</cfif>
		</cftransaction>
		<cfset logger.info('User #session.userid# (#session.username#) Updated "#arguments.title#" (#arguments.id#)', {id=arguments.id,Draft=arguments.isDraft,approved=arguments.approved, url=arguments.url, nav=arguments.showNav,parent=arguments.parent})>
		
		<cfcatch>
			<cfset logger.fatal('Error on page add', {id=arguments.id, title=arguments.title, url=arguments.url, exception=cfcatch})>
			<cfrethrow>
		</cfcatch>
		</cftry>
		<cfcache action="flush">
		<cfreturn arguments.id>
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
			UPDATE page SET approved = <cfqueryparam cfsqltype="cf_sql_integer" value="#active#">
				WHERE landingid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>

	<cffunction name="isDraft" access="public" returntype="void">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="function" type="string" required="yes">
		<cfif NOT can('publish')><cfthrow type="c3d.notPermitted" message="You do not have permessions to publish this resource."></cfif>
		<cfset var active = 0>
		<cfif function EQ "activate">
			<cfset active = 0>
		</cfif>
		<cfif function EQ "deactivate">
			<cfset active = 1>
		</cfif>
		<cfquery datasource="#application.dsn#" name="ins">
			UPDATE page SET isDraft = <cfqueryparam cfsqltype="cf_sql_integer" value="#active#">
				WHERE landingid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>

	<cffunction name="showNav" access="public" returntype="void">
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
			UPDATE page SET showNav = <cfqueryparam cfsqltype="cf_sql_integer" value="#active#">
				WHERE landingid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>

	<cffunction name="customfield" returntype="any" output="no">
		<cfargument name="field" required="yes" type="string">
		<cfargument name="value" required="no" type="any">
		<cfset var set = '' />
		<cfset var result = '' />
		
		<cfif NOT this.id> <!--- evaluates to IF 0 or unset, THEN give up --->
			<cfreturn false>
		</cfif>
		<cfif isDefined("value")>
			<!---<cfthrow type="c3d.todo" message="customfields need to be updated to support capability based permissions">--->
			<cfif application.dstype EQ "mysql">
				<cfquery name="set" datasource="#application.dsn#">
					REPLACE INTO `page_customfields`
					SET `pageId` = <cfqueryparam cfsqltype="cf_sql_integer" value="#this.id#">,
					`field` = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.field#">, 
					`value` = <cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_varchar" >
				</cfquery>			
			<cfelse> <!--- mssql --->
				<cfquery name="set" datasource="#application.dsn#">
					IF NOT EXISTS (
						SELECT [field] FROM page_customfields
						WHERE UPPER([field]) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.field#">
						AND pageId = <cfqueryparam cfsqltype="cf_sql_integer" value="#this.id#">
					)
					BEGIN
						INSERT INTO page_customfields ([pageId],[field],[value]) VALUES (
							<cfqueryparam cfsqltype="cf_sql_integer" value="#this.id#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.field#">,
							<cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_varchar" >
						)
					END
					ELSE
					BEGIN
						UPDATE page_customfields 
						SET  [value] = <cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_varchar" >
						WHERE UPPER([field]) = UPPER(<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.field#">)
						AND [pageId] = <cfqueryparam cfsqltype="cf_sql_integer" value="#this.id#">
					END
				</cfquery>
			</cfif>
		<cfelse>
			<cfquery name="result" dbtype="query">
				SELECT [value] FROM this.cachedCustomFields WHERE UPPER([field]) = UPPER(<cfqueryparam cfsqltype="cf_sql_varchar" value="#field#">)
			</cfquery>
			<cfif result.recordcount>
				<cfreturn result.value>
			<cfelse>
				<cfreturn false>
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="customfieldStr" output="no">
	<cfargument name="field" required="yes" type="string">
		<cfset var retval = customfield(field)>
		<cfif len(retval) AND retval NEQ false>
			<cfreturn retval>
		</cfif>
		<cfreturn "">
	</cffunction>
	
	<cffunction name="getCustomFields" output="no">
		<cfargument name="pageId" required="yes" type="numeric">
		<cfset var qCustom = '' />
		<cfquery datasource="#application.dsn#" name="qCustom">
			SELECT * FROM page_customfields
				WHERE pageId = <cfqueryparam cfsqltype="cf_sql_integer" value="#this.id#">
		</cfquery>
		<cfreturn qCustom>
	</cffunction>
	
	<cffunction name="updateCustomFields" output="no">
		<cfargument name="customfieldlist" required="yes">
		<cfargument name="customvaluelist" required="yes">
		<cfset var i = '' />
		<cfset var qDeleteFields = '' />
		
		<!---<cfthrow type="c3d.todo" message="customfields need to be updated to support capability based permissions">--->
		<cfif ListLen(customfieldlist) NEQ ListLen(customvaluelist)>
			<cfthrow type="c3d.invalidCustomFieldList" message="You must provide a value for every custom field.">
		</cfif>
		<cftransaction>
			<cfquery datasource="#application.dsn#" name="qDeleteFields">
				DELETE FROM page_customfields
					WHERE pageId = <cfqueryparam cfsqltype="cf_sql_integer" value="#this.id#">
			</cfquery>
			<cfloop from="1" to="#ListLen(customfieldlist)#" index="i">
					<cfset customfield( field = ListGetAt(customfieldlist, i), value = ListGetAt(customvaluelist, i))>
			</cfloop>
		</cftransaction>
	</cffunction>
	
	<!--- PERMISSIONS --->
	
	<cffunction name="getPermissions">
		<cfargument name="pageId" default="#this.id#" type="numeric">
		<cfset var qperms = ''>
		<cfquery name="qperms" datasource="#application.dsn#">
			SELECT * from page_permissions 
					WHERE pageId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageId#">
		</cfquery>
		<cfreturn qperms>
	</cffunction>
	
	<cffunction name="updatePermissions" output="no" access="private">
		<cfargument name="rw" required="yes">
		<cfargument name="limitMethods" required="yes">
		<cfargument name="limitArgs" required="no">
		<cfset var i = '' />
		<cfset var qDeleteFields = '' />
		<cfif ListLen(rw) NEQ ListLen(limitMethods)>
			<cfthrow type="c3d.invalidPermissionFieldList" message="You must provide a value for every permission field.">
		</cfif>
		<cftransaction>
			<cfquery datasource="#application.dsn#" name="qDeleteFields">
				DELETE FROM page_permissions
					WHERE pageId = <cfqueryparam cfsqltype="cf_sql_integer" value="#this.id#">
			</cfquery>
			<cfloop from="1" to="#ListLen(rw)#" index="i">
					<cfset myArg = ''>
					<cfif ListGetAt(limitMethod, i) EQ 'require-group' OR ListGetAt(limitMethod, i) EQ 'require-user'>
						<cfset myArg = ListFirst(arguments.limitArgs)>
						<cfset arguments.limitArgs = ListRest(arguments.limitArgs)>
					</cfif>
					<cfset setpermission( rw = ListGetAt(rw, i), method = ListGetAt(limitMethod, i), arg = myArg)>
			</cfloop>
		</cftransaction>
	</cffunction>
	<cffunction name="setPermission" access="private">
		<cfargument name="rw" required="yes">
		<cfargument name="method" required="yes">
		<cfargument name="arg" required="no" default="">
		<cfif application.dstype EQ "mysql">
			<cfquery name="set" datasource="#application.dsn#">
				REPLACE INTO `page_permissions`
								SET `pageId` = <cfqueryparam cfsqltype="cf_sql_integer" value="#this.id#">
								, `rw` = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.rw#">
								, `method` = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.method#">
								, `argument` = <cfqueryparam value="#arguments.arg#" cfsqltype="cf_sql_varchar" >
				
			</cfquery>
			
			
			<cfelse> <!--- mssql --->
			<cfquery name="set" datasource="#application.dsn#">
					INSERT INTO page_permissions ([pageId],[rw],[method],[argument]) VALUES
								(
								<cfqueryparam cfsqltype="cf_sql_integer" value="#this.id#">
								,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.rw#">
								,<cfqueryparam value="#arguments.method#" cfsqltype="cf_sql_varchar" >
								,<cfqueryparam value="#arguments.arg#" cfsqltype="cf_sql_varchar" >
								)
				
			</cfquery>
		</cfif>

	</cffunction>
	
	<cffunction name="checkPermissions" access="private" returntype="boolean">
		<!--- First, do we need to limit access? --->
		<cfif this.pagePermissions.recordcount EQ 0>
			<cfreturn true>
		</cfif>
		
		<!--- we have limits to process,
		make sure user is logged in --->
		<cfset application.helpers.checkLogin()>  <!--- redirects to /login on failure --->
		
		<!--- we are logged in, make sure we are either a manager or we match the set access limits --->
		<cflock scope="session" type="readonly" timeout="10">
			<cfif session.manager EQ 1>
				<cfreturn true>
			</cfif>
		</cflock>
		<cfloop query="this.pagePermissions">
			<cfswitch expression="#method#">
				<cfcase value="require-group">
					<cfif session.Userlevel EQ argument>
						<cfreturn true>
					</cfif>
				</cfcase>
				<cfcase value="require-user">
					<cfif session.user EQ argument>
						<cfreturn true>
					</cfif>
				</cfcase>
				<cfcase value="require-valid-user">
						<cfreturn true> <!--- only requires that we are logged in, which is checked above --->
				</cfcase>
			</cfswitch>
		</cfloop>
		
		<!--- We are logged in, but have not matched. Throw a 403 Forbidden --->
		<cfreturn false>
	</cffunction>
    
	<cffunction name="printParentSimple" output="no" returntype="string">
		<cfargument name="current" default="0" type="numeric">
		<cfargument name="parent" default="0" type="numeric">
		<cfargument name="prefix" default="" type="string">
		<cfargument name="parentSela" type="string" required="no">
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
			WHERE parent = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.parent#">
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
			
			aList = ListContains(arguments.parentSela, pages.landingId[i]);
			
			if(aList neq 0) {
				selected = ' selected="selected"';
			} else {
				selected = '';
			}
			//if(arguments.self 	 EQ pages.landingId[i]) { selected = 'disabled="disabled"'; }
			
			ret &= '<option id="parentsel" value="#pages.landingId[i]#"#selected#>#prefix# #pages.title[i]#</option>' & chr (10);
			ret &= printParentSimple(parentSela=arguments.parentSela, current=arguments.current, parent=pages.landingId[i], prefix='&nbsp;' & arguments.prefix & '&bull;');
		}
		
		if( parent EQ 0) {
			return '<select multiple="multiple" id="parentsel" name="parentsel" tabindex="#arguments.tabindex#"><option id="parentsel" value="">No Parent Section</option><option id="parentsel" value="-1">Home Page Slider</option>' & chr(10) & ret & '</select>';
		}
		return ret;
	</cfscript>
	</cffunction>    
	

	
	
	

	
	<cffunction name="printSliderImages" access="public" output="no" returntype="string">
		<cfargument name="orderProjectsBy" default="" type="string">
		<cfscript>
			var listring = '';
		</cfscript>
		<cfloop query="this.cachedCustomFields">
			<cfscript>
				liString = liString & '<li><img src="#value#" alt="Subpage Promo for" /></li>';
			</cfscript>
		</cfloop>
		
		<cfreturn liString>
	</cffunction>
	
</cfcomponent>