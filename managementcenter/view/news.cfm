<cfset application.helpers.checkLogin()>

<cfparam name="url.archive" default="0">
<cfparam name="url.approved" default="">
<cfparam name="url.active" default="">
<cfparam name="url.category" default="0">
<cfparam name="url.headline" default="">
<cfset getnews = event.getNewsList(argumentcollection=url)>
<cfset categories = event.getnewsCategories()>

<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(getnews) />
<cfif settings.var('prettyURLs')>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/news/')>
	<cfif len(url.approved) OR len(url.active) OR url.category>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/news/?approved=' & url.approved & '&active=' & url.active & '&category=' & url.category & '&archive=' & url.archive)>
    <cfelseif len(url.archive) and url.archive eq 1>
    <cfset pagination.setBaseLink(application.slashroot & 'managementcenter/news/?&archive=' & url.archive)>
	</cfif>
</cfif>

<cfset pagination.setItemsPerPage(15) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<h1><cfif url.archive eq 1>Archived </cfif><cfif len(application.settings.varStr('news.newstitle'))><cfoutput>#application.settings.varStr('news.newstitle')#</cfoutput><cfelse>News</cfif> Management</h1>

<cfoutput>
<form action="" method="get">
	<input class="smalltext" type="text" value="#url.headline#" name="headline" placeholder="Headline keywords" >
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
		<cfif settings.var('news.showCategories')>
			<select name="category">
				<option value="0">All Categories</option>
				<cfloop query="categories"><cfif url.category EQ categories.id><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
				<option value="#categories.id#" #selected#>#categories.title#</option>
				</cfloop>
			</select>
		</cfif>
			<!---Search for: <input type="search" name="searchfor" value="#url.searchfor#" />--->
			<button type="submit" style="float:right;">Filter</button>


</form>
</cfoutput>
<cfif url.archive eq 0>
<a class="addnewsarticle" href="<cfoutput>#BuildURL(event=url.event, action='edit', args='archive=#url.archive#&function=add')#</cfoutput>">Add <cfif len(application.settings.varStr('news.newstitle'))><cfoutput>#application.settings.varStr('news.newstitle')#</cfoutput><cfelse>News</cfif> Article</A>
<br><br>
</cfif>
<table id="quicklinks" border="0" cellspacing="0">
	<thead>
	<TR>
		<cfif application.settings.var('news.priority')><TH>Pri&nbsp;</TH></cfif>
		<cfif application.settings.var('news.showCategories')><TH>Category</TH></cfif>
		<TH>Headline</TH>
		<TH>Publish</TH>
		<TH>Archive</TH>
		<TH>Active</TH>
		<TH>Approved</TH>
		<TH <cfif url.archive eq 1 OR settings.var('news.allowDelete')>colspan="2"</cfif>>Tasks</TH>
	</TR>
	</thead>
	<tbody>
	<CFOUTPUT query="getnews" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#"><cfset class = ""><cfif event.isTop(getnews)><cfset class = 'class="top"'></cfif>
		            <tr #class#>
				<cfif application.settings.var('news.priority')><TD>#sortorder#</TD></cfif>
				<cfif application.settings.var('news.showCategories')><TD><cfif listLen(category) GT 1>Multiple<cfelse>#title#</cfif></TD></cfif>
				<TD>#headline#</TD>
				<td>#helpers.publishIndicator(publishDate)#</td>
				<td>#helpers.expireIndicator(endDate)#</td>
				<TD>#helpers.activateToggle(active, id)#</TD>
				<TD>#helpers.approvedToggle(approved, id)#</TD>
				<TD class="editnews"><cfif event.can('edit_published') OR (event.can('edit') AND approved EQ "no")><A href="#BuildURL(event='news', action='edit', id=getnews.id, args='function=edit&archive=#url.archive#')#"></A></cfif></td>
				<cfif (url.archive eq 1 OR settings.var('news.allowDelete')) AND ( event.can('delete_published') ) OR (approved EQ 'no' AND event.can('delete') )><td class="deletenews"><A href="#BuildURL(event='news', action='edit', id=getnews.id, args='function=delete&archive=#url.archive#')#"></A></TD></cfif>
			</TR>
	</CFOUTPUT>
	</tbody>
</TABLE>


<cfoutput>#pagination.getRenderedHTML()#</cfoutput>
