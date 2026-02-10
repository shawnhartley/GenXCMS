<button type="button" class="button" data-toggle="offCanvas">Open Menu</button>
<nav class="tab-bar show-for-small">
     <section class="right-small">
       	<a class="menu-icon" >
	       	<span></span>
	    </a>
	</section>
	
    <section class="middle tab-bar-section">
       	<h1 class="title"><a href="/home"><img id="logoSmall" src="http://www.placehold.it/120x36&text=Logo" /></a></h1>
	</section>
</nav><!--/tabBar-->
	
<aside class="off-canvas position-right" id='offCanvas' data-off-canvas data-position="right">
    <ul class="off-canvas-list">
	    <!--- Page Content active pages --->
    	<cfoutput>#event.printMobileNavList(fullList = true, withChildren = true)#</cfoutput>
  
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
