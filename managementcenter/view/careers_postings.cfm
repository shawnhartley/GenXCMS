<!--- Check login status --->
<cfset application.helpers.checkLogin()>
<cfset careers = event.getPostings(argumentcollection=url)>

<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(careers) />
<cfif settings.var('prettyURLs')>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/careers/postings')>
</cfif>
<cfset pagination.setItemsPerPage(15) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />


<h1>Career Postings Management</h1>
<br />
<cfoutput><cfif event.can('create')>[<a href="#BuildURL(event=url.event, action='post', args='function=add')#">Post New Job</a>]</cfif></cfoutput>
<form action="" method="get">
<cfif NOT settings.var('prettyurls')>
	<input type="hidden" name="event" value="#url.event#" />
	<input type="hidden" name="action" value="#url.action#" />
</cfif>
</form><br />
<TABLE id="quicklinks" border="0" cellspacing="0">
	<thead>
	<TR>
		<cfif settings.var('careers.priority')><TH>Pri</TH></cfif>
		<TH>Position</TH>
		<TH>Location</TH>
		<TH>Publish</TH>
		<TH>Expire</TH>
		<TH>Active</TH>
		<TH colspan="2">Tasks</TH>
	</TR>
	</thead>
	<tbody>
	<CFOUTPUT query="careers" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
		            <tr>
			<cfif settings.var('careers.priority')><td>#sortorder#</td></cfif>
				<TD>#jobTitle#</TD>
				<TD>#location#</TD>
				<TD>#helpers.publishIndicator(publishDate)#</TD>
				<TD>#helpers.expireIndicator(endDate)#</TD>
				<TD>#helpers.activeIndicator(active)#</TD>
				<TD class="editnews"><cfif event.can('edit_published') OR (NOT active AND event.can('edit'))><A href="#BuildURL(event=url.event, action='post', id=id, args='function=edit')#"></A></cfif></td>
				<td class="deletenews"><cfif event.can('delete_published') OR (NOT active AND event.can('delete'))><A href="#BuildURL(event=url.event,action='post', id=id, args='function=delete')#"></A></cfif></TD>
			</TR>
	</CFOUTPUT>
	</tbody>
</TABLE>

<cfoutput>#pagination.getRenderedHTML()#</cfoutput>