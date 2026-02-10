<cfset application.helpers.checkLogin()>

<cfif structKeyExists(form, "photo")>
	<cfset event.uploadImage(imageField = "photo", galleryId = url.galleryId)>
	<cflocation addtoken="no" url="#BuildURL(event=url.event,action=url.action, args='function=view&galleryId=' & url.galleryId, encode = false)#">
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
		<cflocation addtoken="no" url="#BuildURL(event=url.event, action=url.action, args='function=view&galleryId=#url.galleryId#&msg=1', encode=false)#">
	</cfif>
	
</cfif>
<cfprocessingdirective suppresswhitespace="true">
<cfset getGalleryDetails = event.getGalleries(id = url.galleryId)>
<cfset getAllRecords = event.getGalleryImages(galleryId=url.galleryId)>


<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(getAllRecords) />
<cfif settings.var('prettyURLs')>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/gallery/images/?function=view&galleryId=' & url.galleryId)>
</cfif>

<cfset pagination.setItemsPerPage(15) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<h1><cfoutput>#getGalleryDetails.galleryName# Images</cfoutput></h1>



<div><form action="" method="post" enctype="multipart/form-data">Add Photo: <input type="file" name="photo"> <input type="submit" value="Upload"></form></div>
<br />
<form action="" method="post">
<table id="users" border="0" cellspacing="0">
		<thead>
	       <tr>
	            <th>Sort Order</th>
	            <th>Preview</th>
	            <th>Caption</th>
	            <th>Active</th>
	            <th align="center">Delete</th>
	      </tr>
		</thead>
		<tbody>
	      <cfoutput query="getAllRecords" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
		            <tr>
	                <td ><input type="number" name="sortorder#id#" value="#getAllRecords.sortOrder#" /></td>
	                <td ><a href="#settings.Var('images.path')#medium/#getAllRecords.fileName#" target="_blank"><img src="#settings.Var('images.path')#tiny/#getAllRecords.fileName#" height="25" /></a></td>
	                <td ><input type="text" name="caption#id#" value="#getAllRecords.imageDescription#" /></td>
	                <td><cfif status><a href="#BuildURL(event=url.event, action='image_activate', id=getAllRecords.id, args='function=deactivate')#"><img src="#application.slashroot#managementcenter/images/main/active.gif"></a><cfelse>
						<a href="#BuildURL(event=url.event, action='image_activate', id=getAllRecords.id, args='function=activate')#"><img src="#application.slashroot#managementcenter/images/main/inactive.gif"></a></cfif></td>
	                <td align="center"><cfif status><small>Cannot delete<br />active image</small><cfelse><a href="#BuildURL(event=url.event, action=url.action, id=getAllRecords.id, args='function=delete&filename=#getallrecords.fileName#&galleryId=#url.galleryId#')#">Delete</a></cfif></td>
		            </tr>
	      </cfoutput>
		</tbody>
</table>
<input type="submit" value="Save Changes" name="update">
</form>


<cfoutput>#pagination.getRenderedHTML()#</cfoutput>

</cfprocessingdirective>


