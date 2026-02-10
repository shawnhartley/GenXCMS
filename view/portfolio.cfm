<!--- Initial Portfolio page ---->
<!--- We output the phone's navigation for the page here since the off-canvas menu
	  would require the portfolio.cfc to be accessible from all pages (which it isn't). 
	  Intead we have the off-canvas menu link to this initial /portfolio page then output
	  the phone's nav here, which we only display for small/tablet devices. Large screens
	  receive the side-nav as a navigation option.
--->
<ul id="phonePortfolioNav" class="show-for-small">
	<cfif event.slug EQ settings.Var('portfolio.portfoliourl')>
		<cfoutput>#event.portfolio.printCategoryList()#</cfoutput>
	<cfelse>
		<cfoutput>#event.portfolio.printCategoryList(withProjects=true)#</cfoutput>
	</cfif>
</ul>


<!--- The Category Landing Page (oly be accessable if the MC settings are set to allow it) --->
<cfif structKeyExists(event.portfolio, "categoryname") AND event.portfolio.categoryname EQ event.slug>
	<cfoutput query="event.portfolio.categories">
		<cfif event.portfolio.categories.id eq event.portfolio.categoryid>
			<h1>#event.portfolio.categories.categoryname#</h1>
			#event.portfolio.categories.caption#
		</cfif>
	</cfoutput>
</cfif>


<!--- The Actual Project Pages --->
<cfif structKeyExists(event.portfolio, "project")>
	<cfoutput>
		<h1>#event.portfolio.project.projectName#</h1>
		#event.portfolio.project.projectDescription#
	</cfoutput>
	
	<cfif structKeyExists(event.portfolio, "images") AND event.portfolio.images.recordcount>
		<cfoutput query="event.portfolio.images">
						
			<!--- note that #settings.varStr('images.path')# has both a leading
				  and trailing slash so don't add one to it during output --->
			<div class="projectItem">
				<img src="#settings.varStr('images.path')#original/#fileName#"<cfif settings.var('portfolio.showCaptions')> title="#caption#" alt="#caption#"<cfelse> alt=""</cfif> />
			</div>

			<!--- Include captions if they're turned on and not empty --->
			<cfif settings.Var('portfolio.showcaptions') AND event.portfolio.images.caption NEQ ''>
				<p class="caption">#event.portfolio.images.caption#</p>
			</cfif>
			
		</cfoutput>
	</cfif>
	
</cfif>
