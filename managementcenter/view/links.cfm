<cfset application.helpers.checkLogin()>

<cfprocessingdirective suppresswhitespace="true">

<cfset getAllRecords = event.getLinksList()>

<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(getAllRecords) />

<cfif settings.var('prettyURLs')>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/links/')>
</cfif>

<cfset pagination.setItemsPerPage(25) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<h1>Links Administration</h1>
<cfoutput>
	      <div align="center"><h2></h2></div>
	      <cfif isDefined('url.success')>
		            <div align="center">
			                  <cfif url.success EQ false>ERROR: </cfif>#url.message#
		            </div>
	      </cfif>
</cfoutput>

<div><cfoutput><a href="#BuildURL(event=url.event, action='edit', args='function=add')#" >Add Link</a></cfoutput></div>
<table id="users" border="0" cellspacing="0">
		<thead>
	       <tr>
		   <cfif application.settings.var('links.showCategories')>
		   		<th>Category</th>
		   </cfif>
	            <th>Title</th>
	            <th>URL</th>
	            <th>Active</th>
	            <th align="center">Edit</th>
	            <th align="center">Delete</th>
	      </tr>
		</thead>
		<tbody>
	      <cfoutput query="getAllRecords" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
		            <tr bgcolor="FFFFFF" onmouseover="this.style.backgroundColor='FFDD99'" onmouseout="this.style.backgroundColor='FFFFFF'">
					<cfif application.settings.var('links.showCategories')>
					<td>#title#</td>
					</cfif>
			        <td >#linkTitle#</td>
	                <td ><a href="#linkURL#" target="_blank">#linkURL#</a></td>
	                <td>#helpers.activateToggle(active, id)#</td>
	                <td align="center"><a href="#BuildURL(event=url.event, action='edit', id=getAllRecords.id, args='function=update')#">Edit</a></td>
	                <td align="center"><a href="#BuildURL(event=url.event, action='edit', id=getAllRecords.id, args='function=delete')#">Delete</a></td>
		            </tr>
	      </cfoutput>
		</tbody>
</table>

<br/><br/>
<cfif len(pagination.getRenderedHTML())><cfoutput>#pagination.getRenderedHTML()#</cfoutput></cfif>
</cfprocessingdirective>


