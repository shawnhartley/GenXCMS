<header id="header" class="">
	
   <div class="row show-for-small align-middle">
   	<cfoutput>
   		<div id="logo" class="small-12 medium-3 large-3 columns">
	   		<ul class='menu'><!--- this ul.menu keeps the logo in visual sync with the sidebar --->
	   			<li>
	   				<a href="#BuildURL(event='home')#">
	   					<svg width='100' height='100' alt="#settings.Var("siteTitle")#"><use xlink:href="##C3D_logo" /></svg>
	   				</a>
	   			</li>
	   		</ul>
   		</div>
   		<div class="small-3 medium-9 large-9 columns">
   			<ul id="mainnav" class="menu align-right show-for-medium">
   				<!--- TODO: completely redo this function, move into easily modifiable cfm  --->
   				#event.simpleNav(fullList = true, withChildren = 'never', reverseOrder = false)#
   			</ul><!--/mainnav-->
   		</div><!--/mainnavCont-->
   	</cfoutput>
   	
   	<button class="opener hamburger hide-for-medium" type="button" data-open="offCanvas"><span></span></button>
   	
   </div><!--/row-->
</header><!--/header-->