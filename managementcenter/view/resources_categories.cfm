<!--- Check login status --->
<cfset application.helpers.checkLogin()>

<cfprocessingdirective suppresswhitespace="true">

	<cfif url.function EQ "add">
		<cfset event.insertCategory(argumentcollection=form)>
	<cflocation addtoken="no" url="#BuildURL(event=url.event, action=url.action, encode=false)#">
	</cfif>
	
	<cfif url.function EQ "update">
		<cfloop collection="#form#" item="cat">
			<cfif cat CONTAINS "category">
				<cfset id = mid(cat, 9, len(cat))>
				<cfset event.updateCategory(id=id,categoryName=form[cat])>
			</cfif>
		</cfloop>
	<cflocation addtoken="no" url="#BuildURL(event=url.event, action=url.action, encode=false)#">
	</cfif>
	
	<cfif url.function EQ "delete">
		<cfset event.deleteCategory(id=url.id)>
	<cflocation addtoken="no" url="#BuildURL(event=url.event, action=url.action, encode=false)#">
	</cfif>
	<cfif url.function CONTAINS "activate">
		<cfset event.activateCategory(action=url.function, id = url.id)>
	<cflocation addtoken="no" url="#BuildURL(event=url.event, action=url.action, encode=false)#">
	</cfif>



<cfset getAllRecords = event.getCategories()>

<h1>resource Categories</h1>
<cfoutput>
	      <div align="center"><h2></h2></div>
	      <cfif isDefined('url.success')>
		            <div align="center">
			                  <cfif url.success EQ false>ERROR: </cfif>#url.message#
		            </div>
	      </cfif>


<div><form action="#BuildURL(event=url.event,action=url.action, args='function=add')#" method="post"><input type="text" name="categoryName" /><button type="submit">Add Category</button></form></div><br /><br />
<form action="#BuildURL(event=url.event, action=url.action, args='function=update')#" method="post">
<table id="users" border="0" cellspacing="0">
		<thead>
	       <tr>
	            <th>ID</th>
	            <th>Title</th>
	            <th>Show In List</th>
	            <th align="center">Delete</th>
	      </tr>
		</thead>
		<tbody>
	      <cfloop query="getAllRecords">
		            <tr bgcolor="FFFFFF" onMouseOver="this.style.backgroundColor='FFDD99'" onMouseOut="this.style.backgroundColor='FFFFFF'">
			        <td >#id#</td>
	                <td ><input type="text" name="category#id#" value="#getAllRecords.categoryName#" /></td>
	                <td><cfif active><a href="#BuildURL(event=url.event,action=url.action, id=id, args='function=deactivate')#"><img src="#application.slashroot#managementcenter/images/main/active.gif"></a><cfelse>
						<a href="#BuildURL(event=url.event, action=url.action, id=id, args='function=activate')#"><img src="#application.slashroot#managementcenter/images/main/inactive.gif"></a></cfif></td>
	                <td align="center"><a href="#BuildURL(event=url.event, action=url.action, id=getAllRecords.id, args='function=delete')#" onclick="return confirm('Are you sure you want to delete this category?')">Delete</a></td>
		            </tr>
	      </cfloop>
		</tbody>
</table>
<button type="submit">Update Categories</button>
</form>
</cfoutput>
<br/><br/>

</cfprocessingdirective>


