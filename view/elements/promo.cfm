<cfset allSliders = new cfcs.splash().getItems()>
<!--- Note: could not use cfparam here for some reason --->
<cfquery dbtype='query' name='visibleSliders'>
	SELECT * FROM allSliders WHERE SiteSection=#event.id#
</cfquery>
<cfset activeSlide = 0>

<div id='promo'>

	<cfif visibleSliders.RecordCount GT 0>
		
		<!--- Legacy flexslider in case it's needed --->
		<!---
		<div class="row">
			<div id="homePromo">
				<div class="flexslider">
					<ul class="slides">
						<li><img src="http://www.placehold.it/800x300" /></li>
						<li><img src="http://www.placehold.it/800x300" /></li>
						<li><img src="http://www.placehold.it/800x300" /></li>
						<li><img src="http://www.placehold.it/800x300" /></li>
					</ul><!--/slides-->
				</div><!--flexslider-->
			</div><!--/homepromo-->
		</div><!--/row-->
		--->
		
		<div class="orbit" role="region" aria-label="Promo-Images" data-orbit>
			<ul class="orbit-container">
				<cfif visibleSLiders.RecordCount GT 1>
				<!--- Slider Direction Nav --->
					<button class="orbit-previous"><span class="show-for-sr">Previous Slide</span><svg width='40' height='73'><use xlink:href="#left-arrow" /></svg></button>
					<button class="orbit-next"><span class="show-for-sr">Next Slide</span><svg width='40' height='73'><use xlink:href="#right-arrow" /></svg></button>
				</cfif>
				<cfset slideIndex = 1>
				<cfloop query='visibleSliders' >
					<cfoutput>
						<li class="<cfif slideIndex EQ activeSlide>is-active </cfif>orbit-slide">
							<cfif linkurl NEQ "">
								<a href="#linkurl#">
									<img class="orbit-image" src="/uploads/sliders/#image#" alt="Space">
								</a>
							<cfelse>
								<img class="orbit-image" src="/uploads/sliders/#image#" alt="Space">
							</cfif>
						</li>
					</cfoutput>
					<cfset slideIndex += 1>
				</cfloop>
			</ul>
			<cfif visibleSLiders.RecordCount GT 1>
				<!--- Slider Bullet Nav --->
				<nav class="orbit-bullets">
					<cfloop index='index' from='0' to='#visibleSliders.RecordCount - 1#'>
						<cfoutput>
							<button class="<cfif index EQ activeSlide>is-active</cfif>" data-slide="#index#"><span class="show-for-sr">Slide #index +1#</span><cfif index EQ activeSlide><span class="show-for-sr">Current Slide.</span></cfif></button>
					   </cfoutput>
					</cfloop>
				</nav>
			</cfif>
		</div>
	
	</cfif>

</div>