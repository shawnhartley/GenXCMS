<cfparam name="form.author" default="">
<cfparam name="form.authorEmail" default="">
<cfparam name="form.authorURL" default="">
<cfparam name="form.content" default="">
<cfparam name="url.category" default="0">

<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(event.events.listing) />
<cfset pagination.setBaseLink(BuildURL(event=url.event, encode=false)) />
<!---<cfset pagination.setBaseLink(BuildURL(event=url.event,args='category=#url.category#',encode=false)) />--->
<cfset pagination.setItemsPerPage(10) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<!--- Loop through and output each of the Events --->
<cfoutput query="event.events.listing" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
	<div class="row">
		<div class="large-12 columns">
			<cfif isNumeric(event.slug)>
		        #dateFormat(eventDate,"MM/DD/YYYY")#
				<h2>#headline#</h2>
				#content#
			<cfelse>
				#dateFormat(eventDate,"MM/DD/YYYY")#
				<h2><a href="#BuildURL(event=settings.var('events.url') & '/#id#')#"> <br />#headline#</a></h2>
				#summary#
			</cfif>
		</div><!--/large12-->
	</div><!--/row-->
</cfoutput>

<!--- Output Pagination if needed --->
<cfif event.events.listing.recordcount>
	<cfoutput>#pagination.getRenderedHTML()#</cfoutput>
</cfif>

<!--- If there's no events --->
<cfif NOT event.events.listing.recordcount>
	<div class="row">
		<div class="large-12 columns">
			<h3>Nothing found, please try again later.</h3>
		</div><!--/large12-->
	</div><!--/row-->
</cfif>
