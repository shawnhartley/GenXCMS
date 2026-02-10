<!---
      TEMPLATE: dsp_mcadmin.cfm
      AUTHOR: Pat Whitlock
      DATE: 10/21/08
      CHANGE HISTORY:
            * 10/21/2008: template created
--->

<cfset application.helpers.checkLogin()>

<cfset groupsGateway = CreateObject("component", "#application.siteprefix#managementcenter." & "cfcs." & "dataobjects.security") />
<cfset groups = groupsGateway.getusergroupsList() />

<cfset loginsGateway = CreateObject("component", "#application.siteprefix#managementcenter." & "cfcs." & "dataobjects.security") />
<cfset roles = loginsGateway.getsecurity_rolesList() />

<h2>User Groups</h2>
<div class="addusergroup"><a href="index.cfm?event=editusergroups&function=add"></a></div>

<table id="users" border="0" cellspacing="0">
<tr>
<th>Current Groups</th>
<th>Edit</th>
<th>Delete</th>
</tr>

<CFOUTPUT query="groups">
<tr>
<td align="center">#groupName#</td>
<td class="editusergroups"><a href="index.cfm?event=editusergroups&groupid=#group_id#&function=edit"></a></td>
<td class="deleteusergroups"><a href="index.cfm?event=editusergroups&groupid=#group_id#&function=delete"></a></td>
</tr>

</CFOUTPUT>
</table>
<h2>Security Roles</h2>
<div class="addsecurityrole"><a href="index.cfm?event=editpermissions&function=add"></a></div>
<table id="users" border="0" cellspacing="0">
<tr>
<th>Id</th>
<th>Role</th>
<th>Delete</th>

</tr>
<CFOUTPUT>
<CFLOOP query="roles">
<tr>
<td>#roleID#
<td>#display_name# </td>
<!---<TD><A href="security_roles_frmaddedit.cfm?roleID=#roleID#">Edit</A></td>--->
<td class="deleteusergroups"><a href="index.cfm?event=editpermissions&roleID=#roleID#&function=delete"></a></td>
</tr>
</CFLOOP>
</CFOUTPUT> </table>