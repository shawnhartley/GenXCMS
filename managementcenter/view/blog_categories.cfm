<cfset application.helpers.checkLogin()>


<cfif structKeyExists(form, "categoryName")>
	<cfset event.insertCategory(title=form.categoryName)>
</cfif>
<cfif structKeyExists(form, "update")>
	<cfloop collection="#form#" item="cat">
	<cfif cat CONTAINS "category">
		<cfset id = mid(cat, 9, len(cat))>
		<cfset event.updateCategory(id=id,title=form[cat])>
	</cfif>
	</cfloop>

</cfif>
<cfif structKeyExists(url, "function")>
	<cfif url.function EQ "delete">
		<cfset event.deleteCategory(id=url.id)>
		<cflocation addtoken="no" url="#BuildURL(event=url.event, action=url.action, args='msg=1', encode=false)#">
	</cfif>
</cfif>
<cfprocessingdirective suppresswhitespace="true">

<cfset getAllRecords = event.getblogCategories()>

<cfset perpage = 25>

<h1>blog Categories</h1>
<cfoutput>
	      <div align="center"><h2></h2></div>
	      <cfif isDefined('url.success')>
		            <div align="center">
			                  <cfif url.success EQ false>ERROR: </cfif>#url.message#
		            </div>
	      </cfif>
</cfoutput>

<div><form action="" method="post">Add Category: <input type="text" name="categoryName"> <input type="submit" value="Add"></form></div>

<form action="" method="post">
<table id="users" border="0" cellspacing="0">
	       <tr>
	            <th>ID</th>
	            <th>Title</th>
	            <th align="center">Delete</th>
	      </tr>
		  
	      <cfoutput query="getAllRecords">
		            <tr bgcolor="FFFFFF" onMouseOver="this.style.backgroundColor='FFDD99'" onMouseOut="this.style.backgroundColor='FFFFFF'">
			        <td >#id#</td>
	                <td ><input type="text" name="category#id#" value="#getAllRecords.title#" /></td>
	                <td align="center"><a href="#BuildURL(event=url.event, action=url.action, id=getAllRecords.id, args='function=delete')#">Delete</a></td>
		            </tr>
	      </cfoutput>
</table>
<input type="submit" value="Update Categories" name="update">
</form>
<br/><br/>

</cfprocessingdirective>


