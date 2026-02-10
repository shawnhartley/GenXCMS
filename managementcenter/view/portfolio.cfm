<cfset application.helpers.checkLogin()>
<cfparam name="url.inCat" default="0">
<cfparam name="url.active" default="">
<cfparam name="url.images" default="">
<cfif structKeyExists(form, "projectName")>
	<cfset newid = event.insertProject(projectName=form.projectName, featured = 0)>
	<cflocation addtoken="no" url="#BuildURL(event=url.event, action='editproject', id=newid, encode=false)#">
</cfif>
<cfif structKeyExists(form, "update")>
	<cfloop collection="#form#" item="proj">
	<cfif proj CONTAINS "projectName">
		<cfset id = mid(proj, 12, len(proj))>
		<cftry>
		<cfset event.updateProject(id=id, projectname=form[proj], sortorder=form['sortorder' & id], status= form['projectstatus' & id])>
		<cfcatch type="c3d.notPermitted">
			<cfoutput><p class="error">Some changes were not saved due to permissions. #form[proj]#</p></cfoutput>
		</cfcatch>
		</cftry>
	</cfif>
	</cfloop>
		<cflocation addtoken="no" url="#BuildURL(event=url.event, args='msg=1', encode=false)#">
</cfif>
<cfif structKeyExists(url, "function")>
	<cfif url.function EQ "delete">
		<cfset event.deleteproject(id=url.id)>
		<cflocation addtoken="no" url="#BuildURL(event=url.event, args='msg=1', encode=false)#">
	</cfif>
	
</cfif>
<cfprocessingdirective suppresswhitespace="true">

<cfset getAllRecords = event.getProjects(inCategory = url.inCat, active = url.active, images = url.images)>
<cfset categories = event.getProjectCategories()>


<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(getAllRecords) />

<cfif settings.var('prettyURLs')>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/portfolio/')>
	<cfif len(url.active) OR len(url.images) OR url.inCat NEQ 0>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/portfolio/?active=' & url.active & '&images=' & url.images & '&inCat=' & url.inCat)>
	</cfif>
</cfif>

<cfset pagination.setItemsPerPage(15) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<h1>Project Management</h1>



<div><form action="" method="post">Add New project: <input type="text" name="projectName" placeholder="Project Name"> <input type="submit" value="Add"></form></div>
<div><form action="" method="get">Show:
		<cfoutput>
		<select name="active">
		<cfif url.active EQ ''><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
		<option value="" #selected#>All projects</option>
		<cfif url.active EQ 1><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
		<option value="1" #selected#>Active Projects</option>
		<cfif url.active EQ 0><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
		<option value="0" #selected#>Inactive Projects</option>
		</select>
		<select name="images">
		<cfif url.images EQ ''><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
		<option value="" #selected#></option>
		<cfif url.images EQ 1><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
		<option value="1" #selected#>With Images</option>
		<cfif url.images EQ 0><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
		<option value="0" #selected#>Without Images</option>
		</select>
		</cfoutput>
		in <select name="inCat"><option value="0">All Categories</option>
							<cfoutput query="categories"><option value="#categories.id#" <cfif url.inCat EQ categories.id>selected="selected"</cfif>>#categories.categoryName# (#categories.projectCount#)</option></cfoutput>
		</select> <input type="submit" value="Filter"></form></div>
<form action="" method="post">
<table id="users" border="0" cellspacing="0">
		<thead>
	       <tr>
	            <th>Sort Order</th>
				<th>Link</th>
	            <th>Name</th>
	            <th>Images</th>
	            <th>Active</th>
	            <cfif settings.Var('portfolio.features')><th>Feat</th></cfif>
	            <th>Edit</th>
	            <th align="center">Delete</th>
	      </tr>
		</thead>
		<tbody>
	      <cfoutput query="getAllRecords" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
		            <tr bgcolor="FFFFFF" onMouseOver="this.style.backgroundColor='FFDD99'" onMouseOut="this.style.backgroundColor='FFFFFF'">
	                <td ><input type="number" name="sortorder#id#" value="#getAllRecords.sortorder#" /></td>
	                <td >#event.getLink(id,projectName)#</td>
	                <td ><input type="text" name="projectName#id#" value="#getAllRecords.projectName#" />
						<input type="hidden" name="projectstatus#id#" value="#getAllRecords.status#" /></td>
					<td><a href="#BuildURL(event=url.event, action='images', args='function=view&projectId=#id#')#"><cfif numImages EQ 0> Add<cfelse> #numImages#</cfif></a></td>
	                <td><cfif status><a href="#BuildURL(event=url.event, action='activate', id=getAllRecords.id, args='function=deactivate')#"><img src="#application.slashroot#managementcenter/images/main/active.gif"></a><cfelse>
						<a href="#BuildURL(event=url.event, action='activate', id=getAllRecords.id, args='function=activate')#"><img src="#application.slashroot#managementcenter/images/main/inactive.gif"></a></cfif></td>
				<cfif settings.Var('portfolio.features')>
					<td>#helpers.activeIndicator(featured)#</td>
				</cfif>
	                <td align="center"><a  href="#BuildURL(event=url.event, action='editproject', id=getAllRecords.id)#">Edit</a></td>
					<td align="center"><cfif status><small>Cannot delete<br />active project</small><cfelseif numImages ><small>Delete<br />images first</small><cfelse><a onclick="return confirm('Are you sure you want to delete this project?')" href="#BuildURL(event=url.event, args='function=delete&id=#getAllRecords.id#')#">Delete</a></cfif></td>
		            </tr>
	      </cfoutput>
		</tbody>
</table>
<input type="submit" value="Save Project Info" name="update">
</form>


<cfoutput>#pagination.getRenderedHTML()#</cfoutput>


</cfprocessingdirective>

