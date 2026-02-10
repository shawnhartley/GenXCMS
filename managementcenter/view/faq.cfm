<!--- Check login status --->
<cfset application.helpers.checkLogin()>
<cfparam name="url.sortby" default="priority">
<cfparam name="url.searchfor" default="">
<cfparam name="url.active" default="">
<cfparam name="url.category" default="0">

<cfset FAQs = event.getFAQs(argumentcollection=url)>
<cfset categories = event.getCategories()>


<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(FAQs) />
<cfif settings.var('prettyURLs')>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/FAQs/')>
	<cfif len(url.sortby) OR len(searchfor) OR len(url.active)>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/FAQs/?searchfor=' & url.searchfor & '&active=' & url.active & '&sortby=' & url.sortby)>
	</cfif>
</cfif>
<cfset pagination.setItemsPerPage(15) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />


<h1>FAQ Management</h1>
<br />
<div><cfoutput>
<form action="" method="get">
<cfif NOT settings.var('prettyurls')>
	<input type="hidden" name="event" value="#url.event#" />
</cfif>
Show: 
	
	<select name="active"><option value="">All</option>
			<cfif url.active EQ 1><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="1" #selected#>Active FAQs</option>
			<cfif url.active EQ 0><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="0" #selected#>Inactive FAQs</option></select>

	<select name="sortby">
			<cfif settings.var('FAQs.usepriority')>
			<cfif url.sortby EQ 'priority'><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="priority" #selected#>Sort by Priority</option>
			</cfif>
			<cfif url.sortby EQ 'title'><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="title" #selected#>Sort by Title</option>
			<cfif url.sortby EQ 'filename'><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="filename" #selected#>Sort by Filename</option>
			<cfif url.sortby EQ 'updated'><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="updated" #selected#>Sort by Date Updated</option>
			<cfif settings.var('FAQs.publishexpire')>
			<cfif url.sortby EQ 'published'><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="published" #selected#>Sort by Publish Date</option>
			</cfif>
			</select>
	
		<cfif settings.var('FAQs.useCategories')>
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
<div><cfoutput>[<a href="#BuildURL(event=url.event, action='edit', args='function=add')#" >Add FAQ</a>]</cfoutput></div>
<br />
<TABLE id="quicklinks" border="0" cellspacing="0">
	<thead>
	<TR>
		<cfif settings.var('FAQs.usepriority')>
		<th title="Priority Sort Order">Pri</th>
		</cfif>
		<TH>Active</TH>
		<TH>Title</TH>
		<TH>File</TH>
		<cfif url.sortby EQ 'updated'><TH>Updated</TH></cfif>
		<TH colspan="2">Tasks</TH>
	</TR>
	</thead>
	<tbody>
	<CFOUTPUT query="FAQs" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#"><cfset class = ""><cfif event.isTop(FAQs)><cfset class = 'class="top"'></cfif>
		            <tr #class#>
					<cfif settings.var('FAQs.usepriority')>
					<td>#FAQs.sortorder#</td>
					</cfif>
				<TD>#helpers.activateToggle(FAQs.active, FAQs.id)#</TD>
				<TD title="#event.stripHTML(question)#">#Left(event.stripHTML(question),85)#</TD>
				<cfif url.sortby EQ 'updated'><TD>#dateformat(dateUpdated, 'mm/dd/yy')#</TD></cfif>
				<TD class="view"><A href="#BuildURL(event=url.event, action='edit', id=id, args='function=update')#">View/Edit</A></td>
				<td class="deletenews"><A href="#BuildURL(event=url.event,action='edit', id=id, args='function=delete')#"></A></TD>
			</TR>
	</CFOUTPUT>
	</tbody>
</TABLE>

<cfoutput>#pagination.getRenderedHTML()#</cfoutput>