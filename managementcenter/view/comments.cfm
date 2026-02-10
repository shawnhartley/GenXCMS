<!--- Check login status --->
<cfset application.helpers.checkLogin()>

<cfset getComments = event.getAllComments()>
<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(getcomments) />

<cfset pagination.setItemsPerPage(15) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<h1>Comment Management</h1>
<TABLE id="quicklinks" border="0" cellspacing="0">
	<thead>
	<TR>
		<TH>Comment On</TH>
		<TH>Author</TH>
		<TH>Created</TH>
		<TH>Approved</TH>
		<TH colspan="2">Tasks</TH>
	</TR>
	</thead>
	<tbody>
	<CFOUTPUT query="getcomments" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
		            <tr bgcolor="##FFFFFF" onMouseOver="this.style.backgroundColor='##99CCFF'" onMouseOut="this.style.backgroundColor='##FFFFFF'" title="#Left(getcomments.content, 64)#">
				<TD>
				<cfswitch expression="#commentOn#">
					<cfcase value="news">
						<cfif settings.var('comments.displayTableRef')>#settings.var("news.newstitle")#: </cfif><a href="#application.slashroot#index.cfm?event=#settings.var('news.newsurl')#/#refID#" target="_blank">#headline#</a>
					</cfcase>
				</cfswitch>
				</TD>
				<TD>#author#</TD>
				<TD>#dateformat(dateCreated, 'mm/dd/yy')#</TD>
				<TD><cfif #approved# ><a href="#BuildURL(event=url.event, action='approve', id=getcomments.id, args='function=unapprove')#" title="#Left(getcomments.content, 64)#"><img src="#application.slashroot#managementcenter/images/main/active.gif"></a><cfelse>
					<a href="#BuildURL(event=url.event, action='approve', id=getcomments.id, args='function=approve')#" title="#Left(getcomments.content, 64)#"><img src="#application.slashroot#managementcenter/images/main/inactive.gif"></a></cfif></TD>
				<TD class=""><A href="#BuildURL(event=url.event, action='view', id=getcomments.id)#"><cfif settings.var('comments.allowEdit') AND event.can('edit')>Edit<cfelse>View</cfif></A></td>
				<td class="deletenews"><cfif event.can('delete')><A href="#BuildURL(event=url.event, action='delete', id=getcomments.id, args='function=delete')#" onClick="return confirm('Are you sure you want to DELETE this comment?')" title="#Left(getcomments.content, 64)#"></A></cfif></TD>
			</TR>
	</CFOUTPUT>
	</tbody>
</TABLE>


<cfoutput>#pagination.getRenderedHTML()#</cfoutput>
