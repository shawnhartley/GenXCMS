<footer id="footer">
	<cfoutput>
	<div class="row align-top">
		<div id='footer-logo' class='show-for-medium medium-3 large-3 columns'>
			<ul class='menu'><!--- this ul.menu keeps the logo in visual sync with the sidebar --->
	   			<li>
	   				<a href="#BuildURL(event='home')#">
	   					<svg width='75' height='75' alt="#settings.Var("siteTitle")#"><use xlink:href="##C3D_logo" /></svg>
	   				</a>
	   			</li>
	   		</ul>
		</div><!-- /show-for-medium -->
		<div class='small-12 medium-9 large-9 columns text-right'>
			<ul id="footernav" class="menu align-right show-for-medium">
   				<!--- TODO: completely redo this function, move into easily modifiable cfm  --->
   				#event.simpleNav(fullList = true, withChildren = 'never', reverseOrder = false)#
   			</ul><!--/mainnav-->
   			<ul id='socialnav' class='menu'>
	   			<li><a href=''>
		   			<svg width='30' height='30' alt="Facebook"><use xlink:href="##Facebook" /></svg>
	   			</a></li>
	   			<li><a href=''>
		   			<svg width='30' height='30' alt="Pinterest"><use xlink:href="##Pinterest" /></svg>
	   			</a></li>
	   			<li><a href=''>
		   			<svg width='30' height='30' alt="LinkedIn"><use xlink:href="##LinkedIn" /></svg>
	   			</a></li>
	   			<li><a href=''>
		   			<svg width='30' height='30' alt="LinkedIn"><use xlink:href="##GooglePlus" /></svg>
	   			</a></li>
   			</ul>
			<p class="copyright text-center medium-text-right">&copy; #year(now())# - Company Name</p>
		</div><!-- /small-12 -->
	</div><!-- /row -->
	</cfoutput>
</footer><!-- /footer -->