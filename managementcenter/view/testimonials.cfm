<cfset application.helpers.checkLogin()>

<cfif structKeyExists(url, "function")>
	<cfif url.function EQ "delete">
        <cfset application.datamgr.deleteRecord('testimonials',url)>
        <cflocation addtoken="no" url="#BuildURL(event='testimonials')#">
	</cfif>
	
</cfif>
<cfprocessingdirective suppresswhitespace="true">

<cfset getAllRecords = event.getItems()>


<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(getAllRecords) />
<cfif settings.var('prettyURLs')>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/testimonials/')>
</cfif>

<cfset pagination.setItemsPerPage(15) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<h1><cfoutput>Testimonials Content</cfoutput></h1>

<cfif NOT settings.var('testimonials.locked')><cfoutput>[<a href="#BuildURL(event=url.event, action='edit', args='function=add')#">New Testimonials Item</a>]</cfoutput>
</cfif>
<table id="users" border="0" cellspacing="0">
		<thead>
	       <tr>
	            <th>Sort Order</th>
	            <th>Title</th>
                <th>Testimonial</th>
				<th>Edit</th>
	            <th align="center">Delete</th>
	      </tr>
		</thead>
		<tbody>
	      <cfoutput query="getAllRecords" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
		            <tr bgcolor="FFFFFF" onMouseOver="this.style.backgroundColor='FFDD99'" onMouseOut="this.style.backgroundColor='FFFFFF'">
	                <td >#getAllRecords.sortOrder#</td>
	                <td >#getAllRecords.title#</td>
                    <td >#getAllRecords.testimonial#</td>
					<td ><a href="#BuildURL(event=url.event, action='edit', id=getAllrecords.id, args='function=update')#">Edit</a></td>
	                <td align="center"><a onclick="return confirm('Are you sure?')" href="#BuildURL(event=url.event, args='id=#getAllRecords.id#&function=delete')#">Delete</a></td>
		            </tr>
	      </cfoutput>
		</tbody>
</table>


<cfoutput>#pagination.getRenderedHTML()#</cfoutput>

</cfprocessingdirective>


