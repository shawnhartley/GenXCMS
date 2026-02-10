<!--- Check login status --->
<cfset application.helpers.checkLogin()>
<cfparam name="url.appType" default="">
<cfset careers = event.getApplications(argumentcollection=url)>

<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(careers) />
<cfif settings.var('prettyURLs')>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/careers/')>
	<cfif len(url.appType)>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/careers/?appType=' & url.appType)>
	</cfif>
</cfif>
<cfset pagination.setItemsPerPage(15) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />


<h1>Career Applications Management</h1>
<br />
<cfif application.settings.var('careers.allowDownload') AND event.can('export_applications')><cfoutput><a href="#application.slashroot#managementcenter/view/careers_export.cfm">Export careers List</a></cfoutput></cfif>

<form action="" method="get">
<cfif NOT settings.var('prettyurls')>
	<input type="hidden" name="event" value="#url.event#" />
</cfif>

<cfset types = event.getappTypes()> View: 
	<select name="appType">
	<option value="">All Applications</option>
	<cfoutput query="types"><cfset selected = ''><cfif types.jobTitle EQ url.appType><cfset selected = 'selected="selected"'></cfif>
		<option #selected#>#jobTitle#</option>
	</cfoutput>
	</select>
	<button style="float:right;" type="submit">Filter</button>
	</form><br />
<TABLE id="quicklinks" border="0" cellspacing="0">
	<thead>
	<TR>
		<TH>Position</TH>
		<TH>Location</TH>
		<TH>Name</TH>
		<TH>Email</TH>
		<TH>Date</TH>
		<TH></TH>
		<TH colspan="2">Tasks</TH>
	</TR>
	</thead>
	<tbody>
	<CFOUTPUT query="careers" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
		            <tr bgcolor="##FFFFFF" onMouseOver="this.style.backgroundColor='##99CCFF'" onMouseOut="this.style.backgroundColor='##FFFFFF'">
				<TD>#jobTitle#</TD>
				<TD><small>#location#</small></TD>
				<TD>#fname# #lname#</TD>
				<TD><a href="mailto:#emailAddress#">#emailAddress#</a></TD>
				<TD>#dateformat(dateSubmitted, 'mm/dd/yy')#</TD>
				<TD></TD>
				<TD class="view"><A href="#BuildURL(event=url.event, action='view', id=id, args='function=view')#">View</A></td>
				<td class="deletenews"><cfif event.can('delete_application')><A href="#BuildURL(event=url.event,action='view', id=id, args='function=delete')#"></A></cfif></TD>
			</TR>
	</CFOUTPUT>
	</tbody>
</TABLE>

<cfoutput>#pagination.getRenderedHTML()#</cfoutput>