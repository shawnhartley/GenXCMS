<cfset application.helpers.checkLogin()>

<cfparam name="url.archive" default="0">
<cfparam name="url.approved" default="">
<cfparam name="url.active" default="">
<cfparam name="url.category" default="0">
<cfset getevents = event.geteventsList(argumentcollection=url)>
<cfset categories = event.geteventsCategories()>

<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(getevents) />
<cfif settings.var('prettyURLs')>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/events/')>
	<cfif len(url.approved) OR len(url.active) OR url.category>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/events/?approved=' & url.approved & '&active=' & url.active & '&category=' & url.category & '&archive=' & url.archive)>
    
    <cfelseif len(url.archive) and url.archive eq 1>
    <cfset pagination.setBaseLink(application.slashroot & 'managementcenter/events/?&archive=' & url.archive)>
	</cfif>
</cfif>

<cfset pagination.setItemsPerPage(15) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<h1><cfif url.archive eq 1>Archived </cfif><cfif len(application.settings.varStr('events.eventstitle'))><cfoutput>#application.settings.varStr('events.eventstitle')#</cfoutput><cfelse>Events</cfif> Management</h1>

<cfoutput>
<form action="" method="get">
<cfif NOT settings.var('prettyurls')>
	<input type="hidden" name="event" value="#url.event#" />
</cfif>
Show: 

	<select name="active"><option value="">All</option>
			<cfif url.active EQ 1><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="1" #selected#>Active articles</option>
			<cfif url.active EQ 0><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="0" #selected#>Inactive articles</option></select>
	<select name="approved"><option value="">All</option>
			<cfif url.approved EQ 1><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="1" #selected#>Approved articles</option>
			<cfif url.approved EQ 0><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="0" #selected#>Unapproved articles</option></select>
		<cfif settings.var('events.showCategories')>
			<select name="category">
				<option value="0">All Categories</option>
				<cfloop query="categories"><cfif url.category EQ categories.id><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
				<option value="#categories.id#" #selected#>#categories.title#</option>
				</cfloop>
			</select>
		</cfif>
			<button type="submit" style="float:right;">Filter</button>


</form>
</cfoutput>
<cfif url.archive eq 0>
<a class="addevent" href="<cfoutput>#BuildURL(event=url.event, action='edit', args='archive=#url.archive#&function=add')#</cfoutput>">Add <cfif len(application.settings.varStr('events.eventstitle'))><cfoutput>#application.settings.varStr('events.eventstitle')#</cfoutput><cfelse>Event</cfif></a>
<br><br>
</cfif>
<table id="quicklinks" border="0" cellspacing="0">
	<thead>
	<tr>
		<cfif application.settings.var('events.priority')><th>Pri&nbsp;</th></cfif>
		<th>Event Date</th>
		<th>Headline</th>
		<th>Publish</th>
		<th>Expire</th>
		<th>Active</th>
		<th>Approved</th>
		<th <cfif url.archive eq 1 OR settings.var('events.allowDelete')>colspan="2"</cfif>>Tasks</th>
	</tr>
	</thead>
	<tbody>
	<cfoutput query="getevents" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#"><cfset class = ""><cfif event.isTop(getevents)><cfset class = 'class="top"'></cfif>
		            <tr #class#>
				<cfif application.settings.var('events.priority')><td>#sortorder#</td></cfif>
				<td>#DateFormat(eventDate, 'mm/dd/yy')#</td>
				<td>#headline#</td>
				<td>#helpers.publishIndicator(publishDate)#</td>
				<td>#helpers.expireIndicator(endDate)#</td>
				<td>#helpers.activateToggle(active, id)#</td>
				<td>#helpers.approvedToggle(approved, id)#</td>
				<td class="editnews"><cfif event.can('edit_published') OR (event.can('edit') AND approved EQ "no")><a href="#BuildURL(event='events', action='edit', id=getevents.id, args='function=edit&archive=#url.archive#')#"></a></cfif></td>
				<cfif (url.archive eq 1 OR settings.var('events.allowDelete')) AND ( event.can('delete_published') ) OR (approved EQ 'no' AND event.can('delete') )><td class="deletenews"><a href="#BuildURL(event='events', action='edit', id=getevents.id, args='function=delete&archive=#url.archive#')#"></a></td></cfif>
			</tr>
	</cfoutput>
	</tbody>
</table>


<cfoutput>#pagination.getRenderedHTML()#</cfoutput>
