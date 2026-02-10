<!--- Check login status --->
<cfset application.helpers.checkLogin()>
<cfparam name="url.userid" default="0" type="numeric">
<cfparam name="url.sortby" default="priority">
<cfparam name="url.searchfor" default="">
<cfparam name="url.active" default="">
<cfparam name="url.category" default="0">

<cfset resources = event.getresources(argumentcollection=url)>
<cfset users = createObject("component", application.dotroot & 'cfcs.logins').getNonManagers()>
<cfset categories = event.getCategories()>


<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(resources) />
<cfif settings.var('prettyURLs')>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/resources/')>
	<cfif url.userid GT 0 OR len(url.sortby) OR len(searchfor) OR len(url.active)>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/resources/?userid=' & url.userid & '&searchfor=' & url.searchfor & '&active=' & url.active & '&sortby=' & url.sortby)>
	</cfif>
</cfif>
<cfset pagination.setItemsPerPage(15) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />


<h1>User Resource Management</h1>
<br />
<div><cfoutput>
<form action="" method="get">
<cfif NOT settings.var('prettyurls')>
	<input type="hidden" name="event" value="#url.event#" />
</cfif>
Show: 
	
	<select name="active"><option value="">All</option>
			<cfif url.active EQ 1><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="1" #selected#>Active resources</option>
			<cfif url.active EQ 0><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="0" #selected#>Inactive resources</option></select>

	<select name="sortby">
			<cfif settings.var('resources.usepriority')>
			<cfif url.sortby EQ 'priority'><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="priority" #selected#>Sort by Priority</option>
			</cfif>
			<cfif url.sortby EQ 'title'><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="title" #selected#>Sort by Title</option>
			<cfif url.sortby EQ 'filename'><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="filename" #selected#>Sort by Filename</option>
			<cfif url.sortby EQ 'updated'><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="updated" #selected#>Sort by Date Updated</option>
			<cfif settings.var('resources.publishexpire')>
			<cfif url.sortby EQ 'published'><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="published" #selected#>Sort by Publish Date</option>
			</cfif>
			</select>
	
	<select name="userid"><option value="0">All Users</option>
			<cfloop query="users">
			<cfif url.userid EQ id><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="#id#" #selected#>#displayName#</option>
			</cfloop>
		</select>
		<cfif settings.var('resources.useCategories')>
			<select name="category">
				<option value="0">All Categories</option>
				<cfloop query="categories"><cfif url.category EQ categories.id><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
				<option value="#categories.id#" #selected#>#categories.categoryName#</option>
				</cfloop>
			</select>
		</cfif>
			<!---Search for: <input type="search" name="searchfor" value="#url.searchfor#" />--->
			<button type="submit" style="float:right;">Filter</button>

</form></cfoutput>
</div>
<br />
<div><cfoutput>[<a href="#BuildURL(event=url.event, action='edit', args='function=add')#" >Add Resource</a>]</cfoutput></div>
<br />
<TABLE id="quicklinks" border="0" cellspacing="0">
	<thead>
	<TR>
		<cfif settings.var('resources.usepriority')>
		<th title="Priority Sort Order">Pri</th>
		</cfif>
		<TH>Active</TH>
		<TH>Title</TH>
		<TH>File</TH>
		<cfif settings.var('resources.allowlinks')><TH>Link</TH></cfif>
		<cfif settings.var('resources.uselogins')><TH>Users</TH>
						<TH>Groups</TH></cfif>
		<cfif url.sortby EQ 'updated'><TH>Updated</TH></cfif>
		<cfif settings.var('resources.publishexpire')>
		<th>Publish</th>
		<th>Expires</th>
		</cfif>
		<TH colspan="2">Tasks</TH>
	</TR>
	</thead>
	<tbody>
	<CFOUTPUT query="resources" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#"><cfset class = ""><cfif event.isTop(resources)><cfset class = 'class="top"'></cfif>
		            <tr #class#>
					<cfif settings.var('resources.usepriority')>
					<td>#resources.sortorder#</td>
					</cfif>
				<TD>#helpers.activateToggle(resources.active, resources.id)#</TD>
				<TD>#title#</TD>
				<TD><cfif len(filename)><a target="_blank" href="#event.getDownloadLink(title,'',filename,id)#" title="#filename#"><img src="#application.slashroot#managementcenter/images/main/approved_icon.gif"></a></cfif></TD>
				<cfif settings.var('resources.allowlinks')><TD><cfif len(linkURL)><a target="_blank" href="#resources.linkURL#" title="#resources.linkURL#"><img src="#application.slashroot#managementcenter/images/main/approved_icon.gif"></a></cfif></TD></cfif>
				<cfif settings.var('resources.uselogins')><TD>#usercount#</TD><td>#groupcount#</td></cfif>
				<cfif url.sortby EQ 'updated'><TD>#dateformat(dateUpdated, 'mm/dd/yy')#</TD></cfif>
				<cfif settings.var('resources.publishexpire')>
				<td>#helpers.publishIndicator(publishDate)#</td>
				<td>#helpers.expireIndicator(endDate)#</td>
				</cfif>
				<TD class="view"><cfif event.can('edit_published') OR (NOT resources.active AND event.can('edit'))><A href="#BuildURL(event=url.event, action='edit', id=id, args='function=update')#">View/Edit</A></cfif></td>
				<td class="deletenews"><cfif event.can('delete_published') OR (NOT resources.active AND event.can('delete'))><A href="#BuildURL(event=url.event,action='edit', id=id, args='function=delete')#"></A></cfif></TD>
			</TR>
	</CFOUTPUT>
	</tbody>
</TABLE>

<cfoutput>#pagination.getRenderedHTML()#</cfoutput>