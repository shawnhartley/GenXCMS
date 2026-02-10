<cfset application.helpers.checkLogin()>

<cfif structKeyExists(form, "galleryName")>
	<cfset event.insertGallery(galleryName=form.galleryName)>
</cfif>
<cfif structKeyExists(form, "update")>
	<cfloop collection="#form#" item="cat">
	<cfif cat CONTAINS "galleryName">
		<cfset id = mid(cat, 12, len(cat))>
		<cftry>
		<cfset event.updateGallery(id=id, galleryname=form[cat], sortorder=form['sortorder' & id], galleryDescription=form['galleryDescription' & id])>
		<cfcatch type="c3d.notPermitted">
			<p class="error">Changes to active categories were ignored. You do not have permissions to edit them.</p>
		</cfcatch>
		</cftry>
	</cfif>
	</cfloop>

</cfif>
<cfif structKeyExists(url, "function")>
	<cfif url.function EQ "delete">
		<cfset event.deleteGallery(id=url.id)>
		<cflocation addtoken="no" url="#BuildURL(event=url.event, args='msg=1', encode=false)#">
	</cfif>
	
</cfif>
<cfprocessingdirective suppresswhitespace="true">

<cfset getAllRecords = event.getGalleries()>


<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(getAllRecords) />

<cfset pagination.setItemsPerPage(15) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<h1>Photo Gallery Management</h1>



<cfif settings.var('gallery.allowAddDelete')>
	<div><form action="" method="post">Add Gallery: <input type="text" name="galleryName"> <input type="submit" value="Add"></form></div>
</cfif>

<form action="" method="post">
<table id="users" border="0" cellspacing="0">
		<thead>
	       <tr>
	            <th>Sort Order</th>
	            <th>Name</th>
	            <cfif settings.Var('Gallery.showDescription')>
				<th>Description</th>
				</cfif>
	            <th>Images</th>
	            <th>Active</th>
	           <cfif settings.var('gallery.allowAddDelete')> <th align="center">Delete</th></cfif>
	      </tr>
		  </thead>
		  <tbody>
	      <cfoutput query="getAllRecords" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
		            <tr bgcolor="FFFFFF" onMouseOver="this.style.backgroundColor='FFDD99'" onMouseOut="this.style.backgroundColor='FFFFFF'">
	                <td ><input type="number" name="sortorder#id#" value="#getAllRecords.sortorder#" /></td>
	                <td ><input type="text" name="galleryName#id#" value="#getAllRecords.galleryName#" /></td>
					<cfif settings.Var('Gallery.showDescription')>
	                <td ><input type="text" name="galleryDescription#id#" value="#getAllRecords.galleryDescription#" /></td>
					<cfelse><input type="hidden" name="galleryDescription#id#" value="" /></cfif>
					<td><a href="#BuildURL(event=url.event, action='images', args='function=view&galleryId=#id#')#"><cfif numImages EQ 0> Add<cfelse> #numImages#</cfif></a></td>
	                <td>#helpers.activateToggle(status, id)#</td>
	                <cfif settings.var('gallery.allowAddDelete') AND event.can('delete')><td align="center"><cfif status><small>Cannot delete<br />active galleries</small><cfelse><a onclick="return confirm('Are you sure you want to delete this Gallery?')" href="#BuildURL(event=url.event, args='function=delete&id=#getAllRecords.id#')#">Delete</a></cfif></td></cfif>
		            </tr>
	      </cfoutput>
		  </tbody>
</table>
<cfif event.can('edit')>
	<input type="submit" value="Update Categories" name="update">
</cfif>
</form>


<cfoutput>#pagination.getRenderedHTML()#</cfoutput>

</cfprocessingdirective>


