<cfset application.helpers.checkLogin()>
<cfprocessingdirective suppresswhitespace="true">
<cfparam name="url.group" default="0" type="numeric">
<cfparam name="url.q" default="" type="string">

<!--- get all the logins in the database --->
<cfset getAllRecords = event.getlogins(argumentcollection=url) />
<cfset groups = event.getusergroupsList() />
<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(getAllRecords) />

<cfset pagination.setItemsPerPage(15) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<h1>Site User Administration</h1>
<cfoutput>
<form action="" method="get">
Search by Name/Email: <input type="search" name="q" value="#url.q#" />
Show Group: <select name="group">
	<option value="0">Any Group</option>
	<cfloop query="groups"><cfset selected = group_id EQ url.group ? ' selected' : ''>
	<option value="#group_id#"#selected#>#groupName#</option>
	</cfloop>
</select>
<button type="submit" style="float:right;">Filter</button>
</form>
</cfoutput>
<cfif event.can('add_user')><div class="adduser"><cfoutput><a href="#BuildURL(event='logins', action='edit', args='function=add')#" style="text-decoration: none;"></a></cfoutput></div></cfif>
<table id="users" border="0" cellspacing="0">
		<thead>
	       <tr>
	            <th>Username</th>
	            <th>Display Name</th>
	            <th>Group</th>
	            <th>Manager</th>
	            <th align="center">Edit</th>
	            <th align="center">Delete</th>
	      </tr>
		</thead>
		<tbody>
	      <cfoutput query="getAllRecords" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
		            <tr>
			        <td >#getAllRecords.username#</td>
	                <td >#getAllRecords.displayname#</td>
	                <td >#getAllRecords.groupName#</td>
	                <td >#helpers.activeIndicator(getAllRecords.manager)#</td>
	                <td align="center"><cfif event.can('edit_user')  AND group_id GTE session.usergroupid><a href="#BuildURL(event='logins', action='edit', id=id, args='function=edit')#">Edit</a></cfif></td>
	                <td align="center"><cfif event.can('delete_user') AND group_id GTE session.usergroupid><a href="#BuildURL(event='logins', action='edit', id=id, args='function=delete')#">Delete</a></cfif></td>
		            </tr>
	      </cfoutput>
		</tbody>
</table>
<cfoutput>#pagination.getRenderedHTML()#</cfoutput>

</cfprocessingdirective>


