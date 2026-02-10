<cfset application.helpers.checkLogin()>

<cfif structKeyExists(form, "image")>
	<cfset event.uploadImage(imageField = "image", galleryId = url.galleryId)>
	<cflocation addtoken="no" url="#BuildURL(event=url.event,action=url.action, encode = false)#">
</cfif>
<cfif structKeyExists(url, "function")>
	<cfif url.function EQ "delete">
		<cfset event.deleteImage(id=url.id,image=url.image)>
		<cflocation addtoken="no" url="#BuildURL(event=url.event, args='msg=1', encode=false)#">
	</cfif>
	
</cfif>
<cfprocessingdirective suppresswhitespace="true">
<cfset getAllRecords = event.getItems()>

<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(getAllRecords) />
<cfif settings.var('prettyURLs')>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/splash/')>
</cfif>

<cfset pagination.setItemsPerPage(15) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<h1><cfoutput>Splash Content</cfoutput></h1>

<cfif NOT settings.var('splash.locked')><cfoutput>[<a href="#BuildURL(event=url.event, action='edit', args='function=add')#">New Splash Item</a>]</cfoutput>
</cfif>
<table id="users" border="0" cellspacing="0">
		<thead>
	       <tr>
	            <th>Sort Order</th>
	            <th>Title</th>
	            <th>Preview</th>
	            <th>URL</th>
				<th>Site Section</th>
	            <!---<th>Active</th>--->
				<th>Edit</th>
	            <cfif NOT settings.Var('splash.locked')><th align="center">Delete</th></cfif>
	      </tr>
		</thead>
		<tbody>
	      <cfoutput query="getAllRecords" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
		            <tr bgcolor="FFFFFF" onMouseOver="this.style.backgroundColor='FFDD99'" onMouseOut="this.style.backgroundColor='FFFFFF'">
	                <td >#getAllRecords.sortOrder#</td>
	                <td >#getAllRecords.linkTitle#</td>
	                <td ><a href="#settings.Var('splash.path')##getAllRecords.image#" target="_blank"><img src="#settings.Var('splash.path')##getAllRecords.image#" height="25" /></a></td>
	                <td ><a href="#getAllRecords.linkURL#" target="_blank">#getAllRecords.linkURL#</a></td>
	                
<!--- 					<td >#getAllRecords.siteSection#</td> --->
<!--- 				to pull in page titles from pages DB, first create a queried object that stores the titles based on the site section in the 
	  				splash DB: --->
					<cfset getpageTitle = event.getpageTitle(id=#getAllRecords.siteSection#)>
<!--- 				Then, go ahead and call the relevate object attribute and set to a local variable that changes on each loop
					in this case, the page title: --->
					<cfset pageTitle = "#getpageTitle.title#">
<!--- 				Render the title in it's proper row in the table: --->
					<td>#pageTitle#</td>
<!--- 				original query showed only the site section (not useful info)	
					<td>#getAllRecords.siteSection#</td> --->

					<td ><a href="#BuildURL(event=url.event, action='edit', id=getAllrecords.id, args='function=update')#">Edit</a></td>
	                <!---<td><cfif status><a href="#BuildURL(event=url.event, action='activate', id=getAllRecords.id, args='function=deactivate')#"><img src="#application.slashroot#managementcenter/images/main/active.gif"></a><cfelse>
						<a href="#BuildURL(event=url.event, action='activate', id=getAllRecords.id, args='function=activate')#"><img src="#application.slashroot#managementcenter/images/main/inactive.gif"></a></cfif></td>--->
	                <cfif NOT settings.var('splash.locked')><td align="center"><a onclick="return confirm('Are you sure?')" href="#BuildURL(event=url.event, args='id=#getAllRecords.id#&function=delete&image=#getallrecords.image#')#">Delete</a></td></cfif>
		            </tr>
	      </cfoutput>
		</tbody>
</table>


<cfoutput>#pagination.getRenderedHTML()#</cfoutput>

</cfprocessingdirective>


