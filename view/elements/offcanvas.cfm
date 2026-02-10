<!--- Off-canvas navigation --->

<cfset pagelist = event.getSidebar(parent = event.id)>
<cfset children = event.hasChildren(parentid = event.id)>

<aside class="off-canvas position-right" id='offCanvas' data-off-canvas data-position="right" data-close-on-click='true'>
    <ul class="vertical menu driller" data-drilldown data-parent-link='true'>
	    <!--- Page Content active pages --->
    	<cfoutput>#event.simpleNav(fullList = true, withChildren = 'always')#</cfoutput>
  
    	<!--- Output portfolio (if it's turned on) --->
    	<cfif settings.var('modules') CONTAINS 'Portfolio'>
	    	<cfset capitalPortName = ReReplace(settings.Var('portfolio.portfoliourl'),"\b(\w)","\u\1","ALL")>
	    	<cfoutput>
		    	<li class="#settings.Var('portfolio.portfoliourl')#">
		    		<a href="/#settings.Var('portfolio.portfoliourl')#">#capitalPortName#</a>
		    	</li>
		    </cfoutput>
    	</cfif>
	</ul><!--/offCanvasList-->
</aside>