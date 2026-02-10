<cfset application.helpers.checkLogin()>

<cfprocessingdirective suppresswhitespace="true">

<cfset getAllRecords = event.gettctList()>

<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(getAllRecords) />

<cfset pagination.setItemsPerPage(25) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<h1>Traffic Coordination Management</h1>
<cfoutput>
	      <div align="center"><h2></h2></div>
	      <cfif isDefined('url.success')>
		            <div align="center">
			                  <cfif url.success EQ false>ERROR: </cfif>#url.message#
		            </div>
	      </cfif>
</cfoutput>

<cfoutput><div><a href="#BuildURL(event='tct', action='edit', args='function=add')#" >Add Custom URL Redirect</a></div></cfoutput>
<table id="users" border="0" cellspacing="0">
		<thead>
	       <tr>
	            <th>Slug</th>
	            <th>URL</th>
	            <th>Visits</th>
	            <th>Active</th>
	            <th align="center">Edit</th>
	            <th align="center">Delete</th>
	      </tr>
		</thead>
		<tbody>
	      <cfoutput query="getAllRecords" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
		            <tr bgcolor="FFFFFF" onmouseover="this.style.backgroundColor='FFDD99'" onmouseout="this.style.backgroundColor='FFFFFF'">
			        <td >#slug#</td>
	                <td ><a href="#getAllRecords.url#" target="_blank">#getAllRecords.url#</a></td>
	                <td><cfif settings.var('tct.advancedStats')><a href="#BuildURL(event='tct', action='stats', id=getAllRecords.id)#">#visits#</a><cfelse>#visits#</cfif></td>
	                <td><cfif #active# eq 'yes'><a href="#BuildURL(event='tct', action='activate', id=getAllRecords.id, args='function=deactivate')#"><img src="#application.slashroot#managementcenter/images/main/active.gif"></a><cfelse>
					<a href="#BuildURL(event='tct', action='activate', id=getAllRecords.id, args='function=activate')#"><img src="#application.slashroot#managementcenter/images/main/inactive.gif"></a></cfif></td>
	                <td align="center"><a href="#BuildURL(event='tct', action='edit', id=getAllRecords.id, args='function=update')#">Edit</a></td>
	                <td align="center"><a href="#BuildURL(event='tct', action='edit', id=getAllRecords.id, args='function=delete')#">Delete</a></td>
		            </tr>
	      </cfoutput>
		</tbody>
</table>

<br/><br/>

</cfprocessingdirective>


<cfoutput>#pagination.getRenderedHTML()#</cfoutput>
