<!---Parameters--->
<cfparam name="url.orderby" default="name">
<cfparam name="url.contactEmail" default="0">
<cfparam name="url.contacts" default="0">
<!--- Check login status --->
<cfset application.helpers.checkLogin()>
<!--- get all the mailinglists in the database --->
<cfset getcrm_contacts = application.DataMgr.getrecords(tablename="crm_contacts",orderby=url.orderby)>

<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(getcrm_contacts) />
<cfif settings.var('prettyURLs')>
    <cfset pagination.setBaseLink(application.slashroot & 'managementcenter/crm/?contacts=1&orderby=' & url.orderby)>
<cfelse>
    <cfset pagination.setBaseLink(application.slashroot & 'managementcenter/index.cfm?event=crm&contacts=1&orderby=' & url.orderby)>
</cfif>

<cfset pagination.setItemsPerPage(5) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<h2>Customer Relationship Management Contacts</h2>
<cfif event.can('edit')><p>[ <a href="<cfoutput>#BuildURL(event=url.event, action='edit', args='function=add')#</cfoutput>">Add a contact</a> ]</p></cfif>
<cfif application.settings.Var('subscriptions.listexport') AND event.can('export_members')>
<cfoutput>
<a href="#BuildURL(event=url.event, action='exportlist')#">Export Member List</a>
</cfoutput>
</cfif>

<cfoutput>[ <a href="#BuildURL(event=url.event, args='orderby=name')#">order by individuals</a> | <a href="#BuildURL(event=url.event, args='orderby=company')#">order by company</a> ]</cfoutput>

<table id="users" border="0" cellspacing="0">
	<thead>
	<tr>
		<th>Name</th>
		<th>Company</th>
		<th>Email</th>
		<th>Phone</th>
		<th colspan="3">Tasks</th>
	</tr>
	</thead>
	<tbody>
	
		<cfoutput query="getcrm_contacts" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
			<tr bgcolor="##FFFFFF" onmouseover="this.style.backgroundColor='##FFDD99'" onmouseout="this.style.backgroundColor='##FFFFFF'">
				<td>#name#</td>
				<td>#company#</td>
				<td>#email#</td>
				<td>#phone#</td>
                <td><cfif event.can('edit')><a href="#BuildURL(event=url.event,action='edit',id=id,args='function=view')#">View</a></cfif></td>
				<td><cfif event.can('edit')><a href="#BuildURL(event=url.event,action='edit',id=id,args='function=edit')#">Edit</a></cfif></td>
				<td><cfif event.can('delete')><a href="#BuildURL(event=url.event,action='edit',id=id,args='function=delete')#">Delete</a></cfif></td>
			</tr>
		</cfoutput>
	</tbody>
</table>
<cfoutput>#pagination.getRenderedHTML()#</cfoutput>
<br />

<!--- get all the mailinglistmembers in the database --->
<cfset getcrm_emails = application.DataMgr.getrecords("crm_emails")>

<cfset paginationB = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset paginationB.setQueryToPaginate(getcrm_emails) />
<cfif settings.var('prettyURLs')>
    <cfset paginationB.setBaseLink(application.slashroot & 'managementcenter/crm/?contactEmail=1')>
<cfelse>
    <cfset paginationB.setBaseLink(application.slashroot & 'managementcenter/index.cfm?event=crm&contactEmail=1')>
</cfif>

<cfset paginationB.setItemsPerPage(5) />
<cfset paginationB.setUrlPageIndicator("startB") />
<cfset paginationB.setShowNumericLinks(true) />

<h2>Customer Relationship Management Emails</h2>

<table id="users" border="0" cellspacing="0">
	<thead>
	<tr>
		<th>Email Type</th>
		<th>Sent To</th>
        <th>Date Sent</th>
		<th colspan="2">Tasks</th>
	</tr>
	</thead>
	<tbody>
	
		<cfoutput query="getcrm_emails" startrow="#paginationB.getStartRow()#" maxrows="#paginationB.getMaxRows()#">
			<tr>
                <td>#crmType#</td>
				<td>#crmSendTo#</td>
				<td>#datecreated#</td>
				<td><cfif event.can('edit_member')><a href="#BuildURL(event=url.event, action='emailView', id=id, args='function=edit')#">View Communication</a></cfif></td>
				<td><!---<cfif event.can('delete_member')><a href="#BuildURL(event=url.event, action='editmember', id=id, args='function=delete')#">Delete</a></cfif>---></td>
			</tr>
		</cfoutput>
	
	</tbody>
</table>

<cfoutput>#paginationB.getRenderedHTML()#</cfoutput>