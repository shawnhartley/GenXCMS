<cfset application.helpers.checkLogin()>

<cfif structKeyExists(form, "categoryName")>
	<cfset newid = event.insertProjectCategory(categoryName=form.categoryName)>
	<cflocation addtoken="no" url="#BuildURL(event=url.event, action=url.action, encode=false)#">
</cfif>
<cfif structKeyExists(form, "update")>
	<!---<cfloop collection="#form#" item="cat">
	<cfif cat CONTAINS "categoryName">
		<cfset id = mid(cat, 13, len(cat))>
		<cfset event.updateProjectCategory(id=id, categoryName=form[cat], sortorder=form['sortorder' & id])>
	</cfif>
	</cfloop>--->
    
	<!---This is an iterin fix for 
	sort orders on product categories.  
	The 'sortorder' field is causing a
	conflict with dataMgr--->
    
    <cfloop collection="#form#" item="cat">
	<cfif cat CONTAINS "categoryName">
		<cfset id = mid(cat, 13, len(cat))>
        <cfoutput>
		id=#id#,<br />
        categoryName=#form[cat]#,<br /> 
        sortorder=#form['sortorder' & id]#<br /><br />
		</cfoutput>
        <cfquery name="updateedMe" datasource="#application.dsn#">
        	update portfolio_categories 
               set categoryName=<cfqueryparam cfsqltype="cf_sql_varchar" value="#form[cat]#">, 
                   sortorder=<cfqueryparam cfsqltype="cf_sql_numeric" value="#form['sortorder' & id]#"> 
             where id=<cfqueryparam cfsqltype="cf_sql_numeric" value="#id#"> 
        </cfquery>
	</cfif>
	</cfloop>
    
	<cflocation addtoken="no" url="#BuildURL(event=url.event, action=url.action, args='msg=1', encode=false)#">
</cfif>
<cfif structKeyExists(url, "function")>
	<cfif url.function EQ "delete">
		<cfset event.deleteProjectCategory(id=url.id)>
		<cflocation addtoken="no" url="#BuildURL(event=url.event, action=url.action, args='msg=1', encode=false)#">
	</cfif>
	
</cfif>
<cfprocessingdirective suppresswhitespace="true">

<cfset getAllRecords = event.getProjectCategories()>


<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(getAllRecords) />

<cfset pagination.setItemsPerPage(15) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<h1>Portfolio Categories</h1>



<div><form action="" method="post">Add Category: <input type="text" name="categoryName"> <input type="submit" value="Add"></form></div>

<form action="" method="post">
<table id="users" border="0" cellspacing="0">
		<thead>
	       <tr>
	            <th>Sort Order</th>
	           
	            <th>Category</th>
	            <th>Projects</th>
	            <th>Show</th>
			<cfif settings.var('portfolio.categoryDetail')>
				<th>Edit</th>
			</cfif>
	            <th align="center">Delete</th>
	      </tr>
		</thead>
		<tbody>
	      <cfoutput query="getAllRecords" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
		            <tr bgcolor="FFFFFF" onMouseOver="this.style.backgroundColor='FFDD99'" onMouseOut="this.style.backgroundColor='FFFFFF'">
	                <td ><input type="number" name="sortorder#id#" value="#getAllRecords.sortorder#" /></td>
	                <td ><input type="text" name="categoryName#id#" value="#getAllRecords.categoryName#" /></td>
					
					<td><a href="#BuildURL(event=url.event, args='inCat=#id#')#">#projectCount#</a></td>
	                <td><cfif showInNav><a href="#BuildURL(event=url.event, action='activate_category', id=getAllRecords.id, args='function=deactivate')#"><img src="#application.slashroot#managementcenter/images/main/active.gif"></a><cfelse>
						<a href="#BuildURL(event=url.event, action='activate_category', id=getAllRecords.id, args='function=activate')#"><img src="#application.slashroot#managementcenter/images/main/inactive.gif"></a></cfif></td>
			<cfif settings.var('portfolio.categoryDetail')>
					<td align="center"><a  href="#BuildURL(event=url.event, action='category_edit', id=getAllRecords.id, function='update')#">Edit</a></td>
			</cfif>
					<td align="center"><cfif projectCount><small>Remove<br />projects first<cfelse><a onclick="return confirm('Are you sure you want to delete this category?')" href="#BuildURL(event=url.event, action='categories', id=getAllRecords.id, args='function=delete')#">Delete</a></small></cfif></td>
		            </tr>
	      </cfoutput>
		</tbody>
</table>
<input type="submit" value="Update Categories" name="update">
</form>


<cfoutput>#pagination.getRenderedHTML()#</cfoutput>

</cfprocessingdirective>

