<cfset application.helpers.checkLogin()>

<cfset groups = event.getusergroups() />

<h2>User Groups</h2>
<div class="addusergroup"><cfoutput><a href="#BuildURL(event='usergroups', action='edit', id=-1, args='function=add')#"></a></cfoutput></div>

<table id="users" border="0" cellspacing="0">
<thead>
<tr>
<th>Current Groups</th>
<th>Manager</th>
<th>Edit</th>
<th>Delete</th>
</tr>
</thead>
<tbody>
<CFOUTPUT query="groups">
<tr>
<td align="center">#groupName#</td>
<td align="center">#helpers.activeIndicator(manager)#</td>
<td class="editusergroups"><cfif event.can('edit') AND group_id GTE session.usergroupid><a href="#BuildURL(event='usergroups', action='edit', id=group_id, args='function=edit')#"></a></cfif></td>
<td class="deleteusergroups"><cfif event.can('delete') AND group_id GT session.usergroupid><a href="#BuildURL(event='usergroups', action='edit', id=group_id, args='function=delete')#"></a></cfif></td>
</tr>
</CFOUTPUT>
</tbody>
</table>