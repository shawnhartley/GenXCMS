<cfset application.helpers.checkLogin()>

<cfprocessingdirective suppresswhitespace="true">

<cfset getAllRecords = application.multisite.sites />

<cfset perpage = 25>

<h1>Site Profile Administration</h1>
<cfoutput>
	      <div align="center"><h2></h2></div>
	      <cfif isDefined('url.success')>
		            <div align="center">
			                  <cfif url.success EQ false>ERROR: </cfif>#url.message#
		            </div>
	      </cfif>
</cfoutput>

<div><a href="index.cfm?event=edit_site&function=add" >Add Custom Site</a></div>
<table id="users" border="0" cellspacing="0">
	       <tr>
	            <th>Site ID</th>
	            <th>Name</th>
	            <th align="center">Edit</th>
	            <th align="center">Delete</th>
	      </tr>
	      <cfoutput query="getAllRecords">
		            <tr bgcolor="FFFFFF" onMouseOver="this.style.backgroundColor='FFDD99'" onMouseOut="this.style.backgroundColor='FFFFFF'">
			        <td valign="top">#id#</td>
	                <td valign="top">#name#</td>
	                <td align="center"><a href="index.cfm?event=edit_site&id=#id#&function=update">Edit</a></td>
	                <td align="center"><a href="index.cfm?event=edit_site&id=#id#&function=delete">Delete</a></td>
		            </tr>
	      </cfoutput>
</table>

<br/><br/>

</cfprocessingdirective>


