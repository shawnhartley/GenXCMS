<div id="content">
	
	<cfif listFind('',event.section)>
		
		<!--- If you need complete control over content layout for a section, add the section to the above list, and create a cfm file with whatever content needed. --->
		<cfif event.include>
			<cfinclude template="/view/#event.includefile#">
		</cfif>
		
	<cfelseif listFind('home,contact',event.section)>
	
		<!--- If you don't want a sidebar, add the section to the above list. --->
		
		<div class="row">
			<div id="copy" class="large-12 columns">
				<cfif helpers.userIsLoggedIn() AND event.can('edit_published') AND event.id GT 0>
					<cfoutput><a class="edit button" href="#BuildURL(manage=true,event='pages',action='edit',id=event.id, args='function=edit')#">Edit this Page</a></cfoutput>
				</cfif>
				
				<div class="McContent">
					<cfoutput> #event.content.contentleft# </cfoutput>
				</div><!--/McContent-->
				
				<cfif event.include>
					<cfinclude template="/view/#event.includefile#">
				</cfif>
				
			</div><!--/#copy-->
		</div><!--/row-->
		
	<cfelse>
	
		<!--- Else: include the default structure, with sidebar. --->
		<div class="row">
			
			<!--- Sidebar has been partialed out into its own file --->
			<cfinclude template="/view/elements/sidebar.cfm">

			<div id="copy" class="small-12 medium-9 large-9 columns">
				<cfif helpers.userIsLoggedIn() AND event.can('edit_published') AND event.id GT 0>
					<cfoutput>
						<a class="edit button" href="#BuildURL(manage=true,event='pages',action='edit',id=event.id, args='function=edit')#">Edit this Page</a>
					</cfoutput>
				</cfif>
				
				<cfif event.content.contentleft NEQ "">
					<div class="McContent">
						<cfoutput>#event.content.contentleft#</cfoutput>
					</div><!--/McContent-->
				</cfif>

				<cfif event.include>
					<cfinclude template="/view/#event.includefile#">
				</cfif>
				
				<!--- this shouldn't be needed, but include is having issues --->
				<cfif event.section EQ settings.Var('portfolio.portfoliourl')>
					<cfinclude template="portfolio.cfm">
				</cfif>
				
			</div><!-- /copy -->
		
		</div><!-- /row -->
		
	</cfif><!--- /IfNotHome--->
</div><!-- /content -->