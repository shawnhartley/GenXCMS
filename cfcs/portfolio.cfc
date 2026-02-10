<cfcomponent extends="Event" output="no">
	<cffunction name="init" output="no">
		<cfargument name="path" default="">
		<cfset Super.init()>
		<cfif request.manage>
			<cfset this.image = createObject("component", "image").init()>
			<cfif application.settings.var('portfolio.geo')>
				<cfset this.geo = createObject("component", "geo")> <!--- no init --->
			</cfif>
		<cfelse>
			<cfset this.path = arguments.path>
			<cfset this.categories = getProjectCategories()>
			<cfset this.categoryid = 0>
			<cfset this.projectid = 0>
			<cfset this.found = true>
			<cfset this.title = "">
			<cfif listlen(path)><!--- path was passed in, make sure it is valid --->
				<cfset this.categoryid = ListFirst(path)>
				<cfif NOT validCategory(this.categoryid)>
					<cfset this.found = false>
				</cfif>
				<cfif isNumeric(ListFirst(ListRest(path)))><!--- request for a specific project passes through. --->
					<cfset this.projectid = ListFirst(ListRest(path))>
					<cfset this.project = getprojects(id=this.projectid)>
					<cfset this.title = this.project.projectName>
					<cfset this.categoryName = ListGetAt(path, 3)>
					<cfif NOT this.project.recordcount>
						<cfset this.found = false>
					<cfelse>
						<cfset this.images = getportfolioImages(projectId=this.projectid)>
					</cfif>
				<cfelseif NOT application.settings.Var('portfolio.categoryDetail')> <!---  request for blank project gets redirected to the first project in the category --->
					<!--- redirect --->
					<cfset projects = getprojects(inCategory = this.categoryid)>
					<cflocation url="#application.helpers.buildURL(event='#application.settings.var('portfolio.portfolioURL')#/#this.categoryid#/#projects.id#/#getslugfromtitle(ListRest(path))#/#getslugfromtitle(projects.projectName)#', encode=false)#" addtoken="no">
				<cfelse> <!--- This is a request for a Category Description/List page --->
					<cfset this.categoryName = ListRest(path)>
					<cfset this.title = this.categoryName>
					<cfset this.projects = getprojects(inCategory = this.categoryid, featuredOnly = application.settings.var('portfolio.features'))> <!--- default to select features only if they are turned on --->
				</cfif>
			</cfif>
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getprojects" output="no">
		<cfargument name="id" default="0" type="numeric">
		<cfargument name="inCategory" default="0" type="numeric">
		<cfargument name="images" default="" >
		<cfargument name="active" default="">
		<cfargument name="orderBy" default="">
		<cfargument name="featuredOnly" default="false" type="boolean">
		<cfif request.manage AND NOT can('read')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>
		<cfquery name="qprojects" datasource="#application.dsn#">
			SELECT portfolio.*, count(portfolio_images.id) AS numImages
  FROM portfolio LEFT JOIN portfolio_images ON portfolio.id = portfolio_images.projectId
			<cfif arguments.inCategory>
			JOIN portfolio_category_map ON portfolio.id = portfolio_category_map.projectId
			</cfif>
				WHERE 1 = 1
				<cfif arguments.id NEQ 0>
					AND portfolio.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
				</cfif>
				<cfif arguments.inCategory NEQ 0>
					AND portfolio.id = portfolio_category_map.projectId
					AND portfolio_category_map.categoryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.inCategory#">
				</cfif>
				<cfif NOT request.manage>
					AND portfolio.status = 1
				</cfif>
				<cfif len(arguments.active)>
					AND portfolio.status = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.active#">
				</cfif>
				<cfif arguments.featuredOnly>
					AND featured = 1
				</cfif>
				GROUP BY portfolio.id
				ORDER BY portfolio.sortorder <cfif ListFindNoCase("projectName,city,state,zip,countryCode",arguments.orderby)>, portfolio.#arguments.orderBy#</cfif>, portfolio.projectName
		</cfquery>
		<cfif arguments.images EQ 0>
			<cfquery dbtype="query" name="qfiltered">
			SELECT * FROM qprojects 
			WHERE numImages = 0
			</cfquery>
			<cfreturn qfiltered>
		</cfif>
		<cfif arguments.images EQ 1>
			<cfquery dbtype="query" name="qfiltered">
			SELECT * FROM qprojects 
			WHERE numImages > 0
			</cfquery>
			<cfreturn qfiltered>
		</cfif>
		<cfreturn qprojects>
	</cffunction>
	
	<cffunction name="deleteproject" output="no">
	    <cfargument name="id" default="0">
		<cfif NOT can('delete')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete projects."></cfif>
		<cfquery name="qIsPublished" datasource="#application.dsn#">
			SELECT id FROM portfolio
			WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
				AND status = 1
		</cfquery>
		<cfif qIsPublished.recordcount AND NOT can('delete_published')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this project."></cfif>
		<cfquery name="qDeleteproject" datasource="#application.dsn#">
			DELETE FROM     portfolio
			WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfreturn true>
	</cffunction>

	<cffunction name="insertproject">
		<cfargument name="projectName" required="yes" type="string">
		<cfargument name="sortorder" default="10" type="numeric">
		<cfargument name="projectDescription" default="" type="string">
		<cfargument name="teaser" default="" type="string">
		<cfargument name="featured" default="0" type="boolean">
		<cfargument name="status" default="0" type="boolean">
		<cfif NOT can('create')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create projects."></cfif>
		<cfif NOT can('publish')><cfset arguments.status = false></cfif>
		<cfreturn application.DataMgr.insertRecord('portfolio', arguments)>
	</cffunction>

	<cffunction name="updateproject">
		<cfargument name="id" required="yes" type="numeric">
		<cfargument name="projectName" required="yes">
		<cfargument name="status" default="0">
		<cfargument name="projectCategories" default="">
		<cfargument name="countryCode" default="USA">
		<cfset var qIsPublished = ''>
		<cfif NOT can('edit')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit projects."></cfif>
		<cfquery name="qIsPublished" datasource="#application.dsn#">
			SELECT id FROM portfolio
			WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
				AND status = 1
		</cfquery>
		<cfif qIsPublished.recordcount AND NOT can('edit_published')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this project."></cfif>
		<cfif NOT can('publish')><cfset arguments.status = false></cfif>
		
		<cfif application.settings.var('portfolio.geo') AND structKeyExists(arguments, "address1")>
			<!--- Update the geo stuff --->
			<cfset this.geo.results = 
							this.geo.geocode( address1=arguments.address1, address2=arguments.address2, city=arguments.city, state=arguments.state, postalCode=arguments.zip, countryCode=arguments.countrycode )>
				<cfset this.saveGeoResults(arguments.id)>
		</cfif>
		<!--- update the actual record --->
		<cfset arguments.id = application.DataMgr.updateRecord('portfolio',arguments)>
		<!--- modify category map --->
		<cfif len(projectCategories)>
			<cfquery datasource="#application.dsn#" name="updCategoryMap">
				DELETE FROM portfolio_category_map
						WHERE projectId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
				<cfloop list="#arguments.projectCategories#" index="cat">
					<cfif isNumeric(cat)>
						<cfquery datasource="#application.dsn#" name="updCategoryMap">
						INSERT INTO portfolio_category_map (categoryId, projectId) VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#cat#">, <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#"> )
						</cfquery>
					<cfelse>
						<!--- Check if category already exists --->
						<cfquery datasource="#application.dsn#" name="checkDupCat">
							SELECT id from portfolio_categories WHERE categoryName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(cat)#">
						</cfquery>
						<cfif checkDupCat.recordcount><!--- Exists, just map it --->
							<cfquery datasource="#application.dsn#" name="updCategoryMap">
								INSERT INTO portfolio_category_map (categoryId, projectId) VALUES ( <cfqueryparam cfsqltype="cf_sql_integer" value="#checkDupCat.id#">
																									,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#"> );
							</cfquery>
						<cfelse>
							<!--- New category, add then insert --->
							<cfquery datasource="#application.dsn#" name="updCategoryMap">
								INSERT INTO portfolio_categories (categoryName, showInNav, dateCreated) VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cat#">, '1', <cfqueryparam cfsqltype="cf_sql_timestamp" value="#NOW()#">);
								INSERT INTO portfolio_category_map (categoryId, projectId) VALUES ( (SELECT MAX(id) FROM portfolio_categories), <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#"> );
							</cfquery>
						</cfif><!--- end dupe check --->
					</cfif>
				
				</cfloop>
			</cfif>
				
			<cfreturn arguments.id>
	</cffunction>
	
	<cffunction name="saveGeoResults" access="private">
		<cfargument name="id" required="yes" type="numeric">
		<cfargument name="results" default="#this.geo.results#">
		<cfquery datasource="#application.dsn#" name="qsavegeoresults">
			UPDATE portfolio
				SET  hasGeoCode = <cfqueryparam cfsqltype="cf_sql_bit" value="#results.hasGeoCode#">
					,rawGeoResponse = <cfqueryparam cfsqltype="cf_sql_varchar" value="#results.rawResponse#">
					,attempts = <cfqueryparam cfsqltype="cf_sql_integer" value="#results.attempt#">
					,latitude = <cfqueryparam cfsqltype="cf_sql_decimal" value="#results.latitude#" scale="6">
					,longitude = <cfqueryparam cfsqltype="cf_sql_decimal" value="#results.longitude#" scale="6">
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>


	<cffunction name="activate" output="no">
		<cfargument name="function" default="none">
		<cfargument name="id" default="0">
		<cfset var active = 0>
		<cfif NOT can('publish')><cfthrow type="c3d.notPermitted" message="You do not have permissions to publish projects."></cfif>
		<cfif function EQ "activate">
			<cfset active = 1>
		</cfif>
		<cfquery datasource="#application.dsn#" name="ins">
			UPDATE portfolio  SET status = <cfqueryparam cfsqltype="cf_sql_integer" value="#active#">
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	
	<cffunction name="getProjectCategories" output="no">
		<cfargument name="projectId" default="0" type="numeric">
		<cfargument name="categoryId" default="0" type="numeric">
		<cfquery name="qCats" datasource="#application.dsn#">
			SELECT p.*, 
							(
								SELECT count(*) FROM portfolio_categories
														INNER JOIN portfolio_category_map ON portfolio_category_map.categoryId = portfolio_categories.id
														INNER JOIN portfolio ON portfolio_category_map.projectId = portfolio.id
										WHERE 1 = 1
											AND portfolio_categories.id = p.id
											<cfif arguments.projectId>
												AND portfolio_category_map.projectId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.projectId#">
											</cfif>
											<cfif NOT request.manage>
												AND status = '1'
											</cfif>
							 )  AS projectCount
				FROM portfolio_categories p
				WHERE 1 = 1
			<cfif arguments.categoryId>
				AND p.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.categoryId#">
			</cfif>
			<cfif NOT request.manage>
				AND p.showInNav = '1'
			</cfif>
			ORDER BY p.sortorder, p.categoryName
		</cfquery>
		
		<cfreturn qCats>
	</cffunction>
	
		<cffunction name="printCategoryList" access="public" output="no" returntype="string">
		<cfargument name="path" default="#this.path#" type="string">
		<cfargument name="urlbase" default="#application.settings.var('portfolio.portfolioURL')#" type="string">
		<cfargument name="withProjects" default="no" type="boolean">
		<cfargument name="expand" default="no" type="boolean">
		<cfargument name="withThumbnails" default="no" type="boolean">
		<cfargument name="thumbSize" default="thumb" type="string">
		<cfargument name="withTeasers" default="no" type="boolean">
		<cfargument name="orderProjectsBy" default="" type="string">
		<cfargument name="appendActiveHTML" default="">
		<cfargument name="appendTo" default="li">
		<cfargument name="featuredOnly" default="false" type="boolean">
		<cfscript>
			var liclass = '';
			var listring = '';
		</cfscript>
		<cfloop query="this.categories">
			<cfscript>
			if(!showInNav OR projectCount < 1) {continue;}
			if (this.categoryid EQ id) { liclass = 'active'; } else { liclass = ''; }
			
			liString = liString & '<li class="#liclass# parent"><a class="categorylink" href="#application.helpers.buildURL(event='#urlbase#/#id#/#getSlugFromTitle(CategoryName)#')#">#categoryName#';
			if(len(appendActiveHTML) AND liclass EQ 'active' AND appendTo EQ 'a') {
				liString = liString & arguments.appendActiveHTML;
			}
			liString = liString & '</a>';
			if( withProjects AND ( liclass EQ 'active' OR expand ) ) {
				liString = liString & '<ul>';
				liString = liString & printProjectList(categoryid = id, categoryName = CategoryName, withThumbnails=arguments.withThumbnails, thumbSize=arguments.thumbSize, withTeasers=arguments.withTeasers, orderProjectsBy=arguments.orderProjectsBy, featuredOnly=arguments.featuredOnly);
				liString = liString & '</ul>';
			}
			if(len(appendActiveHTML) AND liclass EQ 'active' AND appendTo EQ 'li') {
				liString = liString & arguments.appendActiveHTML;
			}
			liString = liString & '</li>';
			</cfscript>
		</cfloop>

		<cfreturn liString>
	</cffunction>


		<cffunction name="printProjectList" access="public" output="no" returntype="string">
		<cfargument name="categoryid" default="#this.categoryid#" type="numeric">
		<cfargument name="categoryname" default="#this.categoryname#" type="string">
		<cfargument name="urlbase" default="#application.settings.var('portfolio.portfolioURL')#" type="string">
		<cfargument name="withThumbnails" default="no" type="boolean">
		<cfargument name="thumbSize" default="thumb" type="string" hint="tiny, thumb, medium, original">
		<cfargument name="withTeasers" default="no" type="boolean">
		<cfargument name="orderProjectsBy" default="" type="string">
		<cfargument name="appendActiveHTML" default="">
		<cfargument name="appendHTML" default="">
		<cfargument name="appendTo" default="li">
		<cfargument name="featuredOnly" default="false" type="boolean">
		<cfscript>
			var liclass = '';
			var listring = '';
			var projects = '';
		</cfscript>
		<cfif  structKeyExists(this, 'projects')>
			<cfset projects = this.projects>
		<cfelse>
			<cfset projects = getProjects(inCategory=arguments.categoryid, orderBy=arguments.orderProjectsBy, featuredOnly=arguments.featuredOnly)>
		</cfif>
		<cfloop query="projects">
			<cfscript>
			if(!status) {break;}
			if (this.projectid EQ id) { liclass = 'active'; } else { liclass = ''; }
			
			liString &= '<li class="#liclass#">';
			if(arguments.withThumbnails and projects.numimages GT 0) {
				liString &= '<img class="coverImage" src="#application.settings.VarStr('images.path')##arguments.thumbSize#/#getCoverImage(id)#" />';
			}
			liString &= '<a class="projectlink" href="#application.helpers.buildURL(event='#urlbase#/#categoryid#/#id#/#getSlugFromTitle(categoryName)#/#getSlugFromTitle(projectName)#')#">#projectName#';
			if(len(appendActiveHTML) AND liclass EQ 'active' AND appendTo EQ 'a') {
				liString = liString & arguments.appendActiveHTML;
			}
			liString = liString & '</a>';
			if(arguments.withTeasers) {
				liString &= teaser;
			}
			if(len(appendHTML)) { liString &= appendHTML; }
			if(len(appendActiveHTML) AND liclass EQ 'active' AND appendTo EQ 'li') {
				liString = liString & arguments.appendActiveHTML;
			}
			liString = liString & '</li>';
			</cfscript>
		</cfloop>

		<cfreturn liString>
	</cffunction>

	<cffunction name="getLink" output="no">
		<cfargument name="id" required="yes" type="numeric">
		<cfargument name="projectName" required="yes" type="string">
		<cfargument name="urlbase" default="#application.settings.var('portfolio.portfolioURL')#" type="string">
		<cfset var retstr = ''>
		<cfquery name="getPrimaryCategory" datasource="#application.dsn#" maxrows="1">
			SELECT c.id, m.categoryId, c.categoryName FROM portfolio_categories c JOIN portfolio_category_map m
							ON c.id = m.categoryId
					WHERE m.projectId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
					Order BY c.sortorder, c.categoryName
		</cfquery>
		<cfif NOT getPrimaryCategory.Recordcount>
			<cfreturn ''>
		</cfif>
		<cfset retstr &= '<a href="'>
		<cfset retstr &= application.helpers.buildURL(event='#urlbase#/#getPrimaryCategory.categoryid#/#id#/#getSlugFromTitle(getPrimaryCategory.categoryName)#/#getSlugFromTitle(projectName)#', manage=false)>
		<cfset retstr &= '"><img src="/managementcenter/images/main/bullet.gif" width="7" height="9" /></a>'>
		<cfreturn retstr>
	</cffunction>


	<cffunction name="validCategory" access="private" output="no" returntype="boolean">
		<cfargument name="category" required="yes" type="numeric">
		<cfquery dbtype="query" name="isvalid">
			SELECT id FROM this.categories WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.category#">
				AND showInNav = 1
		</cfquery>
		<cfreturn (isvalid.recordcount)>
	</cffunction>

	<cffunction name="getCategoryDescription">
		<cfargument name="id" default="#this.categoryid#" type="numeric">
		<cfif arguments.id EQ 0><cfreturn ''></cfif>
		<cfquery name="qcat" datasource="#application.dsn#">
			SELECT caption FROM portfolio_categories
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfreturn qcat.caption>
	</cffunction>

	<cffunction name="deleteProjectCategory" output="no">
	<cfargument name="id" default="0">
	<cfif NOT can('delete_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete categories."></cfif>
	<cfquery name="qDeleteproject" datasource="#application.dsn#">
		DELETE FROM     portfolio_categories
		WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
	<cfreturn true>
	</cffunction>

	<cffunction name="insertprojectCategory" output="no" returntype="numeric">
		<cfargument name="categoryName" required="yes" type="string">
		<cfargument name="sortorder" default="10" type="numeric">
		<cfargument name="caption" default="" type="string">
		<cfargument name="status" default="0" type="boolean">
		<cfif NOT can('create_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to add categories."></cfif>
		<cfreturn application.DataMgr.insertRecord('portfolio_categories', arguments)>
	</cffunction>

	<cffunction name="updateprojectCategory" output="no" returntype="numeric">
		<cfargument name="id" required="yes" type="numeric">
		<cfargument name="categoryName" required="yes">
		<cfif NOT can('edit_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit categories."></cfif>
		<cfreturn application.DataMgr.updateRecord('portfolio_categories', arguments)>
	</cffunction>


	<cffunction name="activateCategory" output="no">
		<cfargument name="function" default="none">
		<cfargument name="id" default="0">
		<cfset var active = 0>
		<cfif NOT can('edit_category')><cfthrow type="c3d.notPermitted" message="You do not have permissions to publish categories."></cfif>
		<cfif function EQ "activate">
			<cfset active = 1>
		</cfif>
		<cfquery datasource="#application.dsn#" name="ins">
			UPDATE portfolio_categories  SET showInNav = <cfqueryparam cfsqltype="cf_sql_integer" value="#active#">
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
<!------------- IMAGES -------------------->

	<cffunction name="getportfolioImages" output="no">
		<cfargument name="projectId" required="yes" type="numeric">
		
		<cfquery datasource="#application.dsn#" name="qImages">
			SELECT * FROM portfolio_images
				WHERE projectId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.projectId#">
				<cfif NOT request.manage>
					AND status = '1'
				</cfif>
				ORDER BY sortorder
		
		</cfquery>
		<cfreturn qImages>
	</cffunction>


	<cffunction name="getCoverImage" output="no">
		<cfargument name="projectId" required="yes" type="numeric">
		
		<cfquery datasource="#application.dsn#" name="qImages">
			SELECT fileName FROM portfolio_images
				WHERE projectId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.projectId#">
					AND status = 1
				ORDER BY sortorder LIMIT 1
		
		</cfquery>
		<cfreturn qImages.fileName>
	</cffunction>

	<cffunction name="uploadImage" output="no">
		<cfargument name="imageField" required="yes">
		<cfargument name="projectId" required="yes">
		<cfif NOT can('upload_images')><cfthrow type="c3d.notPermitted" message="You do not have permissions to upload project images."></cfif>
		<cfset result = this.image.uploadAndResize(argumentcollection=arguments)>
		<cfset arguments.status = can('publish_images')>
		<cfif result.success>
			<cfreturn application.dataMgr.insertRecord('portfolio_images', {filename=result.filename, projectId=arguments.projectid})>
		</cfif>
		<cfthrow type="c3d.badRequest" extendedinfo="#result#">
	</cffunction>

	<cffunction name="updateImage">
		<cfargument name="caption" default="">
		<cfargument name="sortorder" default="10">
		<cfargument name="id" required="yes">
		<cfif NOT can('edit_images')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit project images."></cfif>
		<cfquery name="qIsPublished" datasource="#application.dsn#">
			SELECT id FROM portfolio_images
			WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
				AND status = 1
		</cfquery>
		<cfif qIsPublished.recordcount AND NOT can('edit_published_images')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this image."></cfif>
		<cfquery datasource="#application.dsn#" name="updImage">
			UPDATE portfolio_images SET
					caption = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.caption#">
					,sortorder = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sortorder#">
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	
	<cffunction name="imageActivate" output="no">
		<cfargument name="function" default="none">
		<cfargument name="id" default="0">
		<cfset var active = 0>
		<cfif NOT can('publish_images')><cfthrow type="c3d.notPermitted" message="You do not have permissions to publish project images."></cfif>
		<cfif function EQ "activate">
			<cfset active = 1>
		</cfif>
		<cfquery datasource="#application.dsn#" name="ins">
			UPDATE portfolio_images  SET status = <cfqueryparam cfsqltype="cf_sql_integer" value="#active#">
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	
	<cffunction name="deleteImage" output="no">
		<cfargument name="id" default="0">
		<cfargument name="filename" required="yes">
	
		<cfif NOT can('delete_images')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete project images."></cfif>
		<cfquery name="qIsPublished" datasource="#application.dsn#">
			SELECT id FROM portfolio_images
			WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
				AND status = 1
		</cfquery>
		<cfif qIsPublished.recordcount AND NOT can('delete_published_images')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this image."></cfif>
		<cfquery name="qDeleteGallery" datasource="#application.dsn#">
			DELETE FROM     portfolio_images
			WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		
		<!--- Delete image files --->
		<cfset this.image.delete(filename = arguments.filename)>
		<cfreturn true>
	</cffunction>


</cfcomponent>