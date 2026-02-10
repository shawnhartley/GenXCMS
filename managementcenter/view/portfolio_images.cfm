<cfset application.helpers.checkLogin()>

<cfif structKeyExists(form, "photo")>
	<cfset event.uploadImage(imageField = "photo", projectid = url.projectid)>
	<cflocation addtoken="no" url="#BuildURL(event=url.event,action=url.action, args='function=view&projectid=' & url.projectid, encode = false)#">
</cfif>
<cfif structKeyExists(form, "update")>
	<cfloop collection="#form#" item="cat">
	<cfif cat CONTAINS "caption">
		<cfset id = mid(cat, 8, len(cat))>
		<cfset event.updateImage(id=id, caption=form[cat], sortorder=form['sortorder' & id] )>
	</cfif>
	</cfloop>

</cfif>
<cfif structKeyExists(url, "function")>
	<cfif url.function EQ "delete">
		<cfset event.deleteImage(id=url.id,filename=url.filename)>
		<cflocation addtoken="no" url="#BuildURL(event=url.event, action=url.action, args='function=view&projectId=#url.projectId#&msg=1', encode=false)#">
	</cfif>
	
</cfif>
<cfprocessingdirective suppresswhitespace="true">
<cfset getportfolioDetails = event.getProjects(id = url.projectid)>
<cfset getAllRecords = event.getportfolioImages(projectid=url.projectid)>

<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(getAllRecords) />

<cfif settings.var('prettyURLs')>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/portfolio/images/?function=view&projectId=' & url.projectid)>
</cfif>

<cfset pagination.setItemsPerPage(15) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<h1><cfoutput>#getportfolioDetails.projectName# Images</cfoutput></h1>

<div><cfoutput><a href="#BuildURL(event=url.event)#">Back to Project List</a></cfoutput><br />
<br />
</div>

<div><form action="" method="post" enctype="multipart/form-data">Add Photo: <input type="file" name="photo"> <input type="submit" value="Upload"></form></div>
<br />
<form action="" method="post">
<table id="users" border="0" cellspacing="0">
		<thead>
	       <tr>
	            <th>Sort Order</th>
	            <th>Preview</th>
	            <cfif settings.Var('portfolio.showcaptions')><th>Caption</th></cfif>
	            <th>Active</th>
	            <th align="center">Delete</th>
	      </tr>
		</thead>
		<tbody>
	      <cfoutput query="getAllRecords" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
		            <tr bgcolor="FFFFFF" onMouseOver="this.style.backgroundColor='FFDD99'" onMouseOut="this.style.backgroundColor='FFFFFF'">
	                <td ><input type="number" name="sortorder#id#" value="#getAllRecords.sortOrder#" /></td>
	                <td ><a href="#settings.Var('images.path')#medium/#getAllRecords.fileName#"><img src="#settings.Var('images.path')#tiny/#getAllRecords.fileName#" height="25" /></a></td>
	                <cfif settings.Var('portfolio.showcaptions')><td ><input type="text" name="caption#id#" value="#getAllRecords.caption#" /></td><cfelse><input type="hidden" name="caption#id#" value="#getAllRecords.caption#" /></cfif>
	                <td><cfif status><a href="#BuildURL(event=url.event, action='activate_image', id=getAllRecords.id, args='function=deactivate')#"><img src="#application.slashroot#managementcenter/images/main/active.gif"></a><cfelse>
						<a href="#BuildURL(event=url.event, action='activate_image', id=getAllRecords.id, args='function=activate')#"><img src="#application.slashroot#managementcenter/images/main/inactive.gif"></a></cfif></td>
	                <td align="center"><cfif status><small>Cannot delete<br />active image</small><cfelse><a onclick="return confirm('Are you sure you want to DELETE this image?')" href="#BuildURL(event=url.event, action=url.action, id=getAllRecords.id, args='function=delete&filename=#getallrecords.fileName#&projectId=#url.projectId#')#">Delete</a></cfif></td>
		            </tr>
	      </cfoutput>
		</tbody>
</table>
<input type="submit" value="Save Changes" name="update">
</form>


<cfoutput>#pagination.getRenderedHTML()#</cfoutput>

</cfprocessingdirective>


