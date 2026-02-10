<!---
      TEMPLATE: usergroupsForm.cfm
      AUTHOR: Pat Whitlock
      DATE: 10/21/08
      CHANGE HISTORY:
            * 10/21/2008: template created
--->

<cfset application.helpers.checkLogin()>

<CFPARAM NAME="groupid" DEFAULT="0">
<CFPARAM NAME="form.securityroles" DEFAULT="">

<CFIF isdefined('form.Action')>
<CFIF form.Action is "INSERT">
<cfinvoke component="#application.siteprefix#managementcenter.cfcs.dataobjects.security" method="addusergroups" argumentcollection="#form#">
<CFLOCATION url="index.cfm?event=admin&msg=0">
</cfif>

<cfif form.action eq "Update">
<cfinvoke component="#application.siteprefix#managementcenter.cfcs.dataobjects.security" method="updateusergroups" groupid="#groupid#" argumentcollection="#form#">
<CFLOCATION url="index.cfm?event=admin&msg=1" addtoken="no">
</CFIF>

<cfif form.action eq "delete">
<cfinvoke component="#application.siteprefix#managementcenter.cfcs.dataobjects.security" method="deleteusergroups" groupid="#groupid#">
<CFLOCATION url="index.cfm?event=admin&msg=1">
</cfif>
</cfif>

<cfset groupsGateway = CreateObject("component", "#application.siteprefix#managementcenter." & "cfcs." & "dataobjects.security") />
<cfset getusergroups = groupsGateway.getusergroups(#groupid#) />
<cfset grouplist = groupsGateway.getusergroupsList() />
<cfset roleslist = groupsGateway.getsecurity_rolesList() />

<cfif groupid IS NOT 0>
<h1>Edit User Group</h1>
<div class="backbutton"><a href="index.cfm?event=admin">&lt; Back to List</a></div>
<cfelse>
<h1>Add User Group</h1><br>
</cfif>

<FORM action="index.cfm?event=editusergroups" method="post" name="frmusergroups">

<ul>
	<li><label for="groupName">Group Name:<br /><input type="text" id="groupName" name="groupName" value="<cfoutput>#getusergroups.groupName#</cfoutput>" /></label></li>
	<li>
		<label for="security_roles">Security Roles:<br /></label>

		<cfoutput query="roleslist">
		<input type="checkbox" name="securityroles" value="#HTMLEditFormat(roleslist.ROLEID)#" <cfif ListContains(getusergroups.security_roles, "#roleslist.roleid#")>checked</cfif>> &nbsp; #roleslist.roleid#:#roleslist.display_name#<br/>
		</cfoutput>
	</li>
<!--- insert hidden fields and determine/create submit button action --->
                        <li>
                              <INPUT TYPE="hidden" NAME="groupid" value="<cfoutput>#groupid#</cfoutput>">
 <cfswitch expression="#url.function#">
                        <cfcase value="add">
                        	  <INPUT TYPE="HIDDEN" NAME="Action" VALUE="INSERT">
                              <button class="submit" type="submit" tabindex="30">Add Group</button>
                        </cfcase>
                        <cfcase value="edit">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Update">
                              		<button class="submit" type="submit" tabindex="30">Update Group</button>
                        </cfcase>
                        <cfcase value="delete">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Delete">
                              		<button class="submit" type="submit" tabindex="30" onClick="return confirm('Are you sure you want to delete this record from the database?')">Delete Group</button>
                        </cfcase>
                  </cfswitch>

<!--- end hidden field and submit button creation --->

</li>
</ul>
</FORM>