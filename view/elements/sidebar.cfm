<div id="sidebar" class="small-12 medium-3 large-3 columns">
	<ul id="sidenav" class="show-for-medium vertical menu">
		<cfoutput>
			<!--- Page Content --->
			<cfif event.hasChildren(event.sectionid)>
				#event.simpleNav(withChildren = 'active')#
			</cfif>
			
			<!--- Portfolio --->
			<cfif event.section EQ settings.Var('portfolio.portfoliourl')>
				#event.portfolio.printCategoryList(withProjects=true)#
			</cfif>
			
			<!--- News / Blog --->
			<cfif event.section EQ settings.Var('news.newsurl') OR (settings.var('news.onAllPages') AND event.news.topnews.recordcount)>
				<h2>#settings.var('news.newsTitle')#</h2>
				<cfif settings.Var("news.showCategories")>
					#event.news.printCategoryList(headlineOnly="yes",withNews="yes",expand="no",category=( isnumeric(event.slug) AND listlen(event.path) eq 2 OR listlen(event.path) eq 3 ? listGetAt(event.path,2) : "0" ))#
				<cfelse>	
					#event.news.printNewsList(category=0, moreText='', headlineOnly=true)#
				</cfif>
				<cfif event.news.listing.recordcount AND event.slug EQ 'archive'>
					<li><a href="#BuildURL(event=settings.var('news.newsurl') & '/0/archive/')#">View Archives</a></li>	
				</cfif>
			</cfif>
		</cfoutput>
	</ul><!--/sidenav-->
	
	<cfif len(event.content.contentright)>
		<!--- If the 2nd content box has anything in it --->
		<div class="aside">
			<cfoutput>#event.content.contentright#</cfoutput>
		</div><!--/aside-->
	</cfif>
</div><!-- /sidebar -->