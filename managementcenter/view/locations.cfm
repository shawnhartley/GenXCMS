<cfset application.helpers.checkLogin()>

<cfparam name="url.geocoded" default="">
<cfparam name="url.searchfor" default="">
<cfparam name="url.active" default="">
<cfprocessingdirective suppresswhitespace="true">

<cflock scope="session" type="exclusive" timeout="10">
<cfset session.locationspage = cgi.SCRIPT_NAME & '?' & cgi.QUERY_STRING>
</cflock>

<cfset getAllRecords = event.getLocationsList(argumentcollection=url)>

<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(getAllRecords) />

<cfif settings.var('prettyURLs')>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/locations/')>
	<cfif len(url.geocoded) OR len(url.searchfor) OR len(url.active)>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/locations/?geocoded=' & url.geocoded & '&searchfor=' & url.searchfor & '&active=' & url.active)>
	</cfif>
</cfif>

<cfset pagination.setItemsPerPage(25) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<h1>Locations Management</h1>
<cfoutput>
	      <div align="center"><h2></h2></div>
	      <cfif isDefined('url.success')>
		            <div align="center">
			                  <cfif url.success EQ false>ERROR: </cfif>#url.message#
		            </div>
	      </cfif>
</cfoutput>
<cfif getAllrecords.recordcount GTE 750>
<p class="error">There are too many locations to show at once. Please use the search form below to find the location you are looking for. <br />
<small>(<cfoutput>#NumberFormat(event.numactivelocations)# active out of #NumberFormat(event.numlocations)# total locations</cfoutput>)</small></p>
</cfif>
<div><cfoutput>
<form action="#BuildURL(event=url.event)#" method="get">
Show: 
	
	<select name="active"><option value="">All locations</option>
			<cfif url.active EQ 1><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="1" #selected#>Active Locations</option>
			<cfif url.active EQ 0><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="0" #selected#>Inactive Locations</option></select>

	<select name="geocoded"><option value=""></option>
			<cfif url.geocoded EQ 1><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="1" #selected#>With precise geocode</option>
			<cfif url.geocoded EQ 'approx'><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="approx" #selected#>Approximated geocode</option>
			<cfif url.geocoded EQ 0><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="0" #selected#>Missing geocode</option></select>
			
			Search for: <input type="search" name="searchfor" value="#url.searchfor#" />
			<button type="submit" style="float:right;">Filter</button>

</form></cfoutput>
</div>
<br />
<div><cfoutput>[<a href="#BuildURL(event=url.event, action='edit', args='function=add')#" >Add Location</a>]<cfif settings.var('locations.useCache')> &nbsp; [<a href="#BuildURL(event=url.event, action='cache', args='function=update')#" >Update Live Site</a>]</cfif></cfoutput></div>

<table id="users" border="0" cellspacing="0">
		<thead>
	       <tr>
	            <th>Loc Name</th>
	            <th>Address</th>
	            <th>GeoCoded</th>
	            <th>Active</th>
	            <th align="center">Edit</th>
	            <th align="center">Delete</th>
	      </tr>
		</thead>
		<tbody>
	      <cfoutput query="getAllRecords" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
		            <tr bgcolor="FFFFFF" onMouseOver="this.style.backgroundColor='FFDD99'" onMouseOut="this.style.backgroundColor='FFFFFF'">
			        <td >#locName#</td>
	                <td >#address1#</td>
	                <td >#helpers.activeIndicator((attempts LT 5 AND attempts GT 0))#</td>
	                <td >#helpers.activateToggle(active, id)#</td>
	                <td align="center"><a href="#BuildURL(event=url.event, action='edit', id=getAllRecords.id, args='function=update')#">Edit</a></td>
	                <td align="center"><a href="#BuildURL(event=url.event, action='edit', id=getAllRecords.id, args='function=delete')#">Delete</a></td>
		            </tr>
	      </cfoutput>
		</tbody>
</table>

<br/><br/>
<cfif len(pagination.getRenderedHTML())><cfoutput>#pagination.getRenderedHTML()#</cfoutput></cfif>
</cfprocessingdirective>