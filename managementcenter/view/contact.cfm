<!--- Check login status --->
<cfset application.helpers.checkLogin()>
<cfparam name="url.formType" default="">
<!---<cfparam name="url.archive" default="">--->
<cfset contacts = event.getContacts(argumentcollection=url)>

<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(contacts) />
<cfif settings.var('prettyURLs')>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/contact/')>
	<cfif len(url.formType)>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/contact/?formType=' & url.formType)>
	</cfif>
	<cfif len(url.archive)>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/contact/?archive=' & url.archive)>
	</cfif>    
</cfif>
<cfset pagination.setItemsPerPage(15) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<h1>Contacts Management</h1>
<br />
<cfif application.settings.var('contact.allowDownload')>
<cfoutput>
<a href="#application.slashroot#managementcenter/view/contact_export.cfm">Export Contacts List</a>
</cfoutput>
</cfif>

<cfif url.archive neq 1>
	<cfif settings.var('contact.formtypes')><form action="" method="get">
        <cfif NOT settings.var('prettyurls')>
            <input type="hidden" name="event" value="#url.event#" />
        </cfif>
    <!------>
    <cfset types = event.getFormTypes()> View: 
        <select name="formType">
        <option value="">All Forms</option>
        <cfoutput query="types"><cfset selected = ''><cfif types.formType EQ url.formType><cfset selected = 'selected="selected"'></cfif>
            <option #selected#>#formType#</option>
        </cfoutput>
        </select>
        <button style="float:right;" type="submit">Filter</button>
        </form><br />
    <!------>
    </cfif>
</cfif>

<table id="quicklinks" border="0" cellspacing="0">
	<thead>
	<tr>
		<cfif settings.var('contact.formTypes')><th>Form Type</th></cfif>
		<th>Name</th>
		<th>Company Name</th>
		<th>Email</th>
		<th>Date</th>
		<th>Message</th>
		<th colspan="2">Tasks</th>
	</tr>
	</thead>
	<tbody>
	<cfoutput query="contacts" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
			<tr>
				<cfif settings.var('contact.formtypes')><td>#formType#</td></cfif>
				<td>#name#</td>
				<td>#companyName#</td>
				<td>#email#</td>	
				<td>#dateformat(dateCreated, 'mm/dd/yy')#</td>
				<td>#Left(message,57)#...</td>
				<td class="view"><a href="#BuildURL(event=url.event, action='view', id=id, args='function=view')#">View</a></td>
				<cfif settings.var('contact.allowdelete') AND event.can('delete')><td class="deletenews"><a href="#BuildURL(event=url.event,action='view', id=id, args='function=delete')#"></a></td></cfif>
			</tr>
	</cfoutput>
	</tbody>
</table>

<cfoutput>#pagination.getRenderedHTML()#</cfoutput>