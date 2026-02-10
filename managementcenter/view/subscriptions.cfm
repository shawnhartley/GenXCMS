<!--- Check login status --->
<cfset application.helpers.checkLogin()>
<!--- get all the mailinglists in the database --->
<cfset getAllRecords = event.getmailinglistList() />

<!--- get all the mailinglistmembers in the database --->
<cfset getAllmembers = event.getmailinglistmembersList() />

<!--- get all the emails in the database --->
<cfset getAllemails = event.getemailsList() />

<h1>Mailing List Management</h1>
<cfif event.can('create_list')><p>[<A href="<cfoutput>#BuildURL(event=url.event, action='editlist', args='function=add')#</cfoutput>">Add List</A>]</p></cfif>

<TABLE id="users" border="0" cellspacing="0">
	<thead>
	<TR>
		<TH>List Name</TH>
		<TH>Last Update</TH>
		<TH>Active</TH>
		<TH>Public</TH>
		<TH colspan="2">Tasks</TH>
	</TR>
	</thead>
	<tbody>
	<CFOUTPUT>
		<CFLOOP query="getAllRecords">
			<tr bgcolor="##FFFFFF" onMouseOver="this.style.backgroundColor='##FFDD99'" onMouseOut="this.style.backgroundColor='##FFFFFF'">
				<TD>#listName#</TD>
				<TD>#dateformat(lastUpdate, 'mm/dd/yy')#</TD>
				<TD><cfif #isActive#><img src="../images/main/check.png"><cfelse><img src="../images/main/x.png"></cfif></TD>
				<TD><cfif #isPublic#><img src="../images/main/check.png"><cfelse><img src="../images/main/x.png"></cfif></TD>
				<TD><cfif event.can('edit_list')><A href="#BuildURL(event=url.event, action='editlist',id=listid, args='function=edit')#">Edit</A></cfif></TD>
				<TD><cfif event.can('delete_list')><A href="#BuildURL(event=url.event, action='editlist', id=listid, args='function=delete')#">Delete</A></cfif></TD>
			</TR>
		</CFLOOP>
	</CFOUTPUT>
	</tbody>
</TABLE>



<h1>Mailing List Members</h1>
<cfif application.settings.Var('subscriptions.listexport') AND event.can('export_members')>
<A href="<cfoutput>#BuildURL(event=url.event, action='exportlist')#</cfoutput>">Export Member List</a>
</cfif>
<cfif event.can('add_member')><p>[<A href="<cfoutput>#BuildURL(event=url.event, action='editmember', args='function=add')#</cfoutput>">Add</A>]</p></cfif>

<TABLE id="users" border="0" cellspacing="0">
	<thead>
	<TR>
		<TH>Name</TH>
		<TH>Is Verified?</TH>
		<TH colspan="2">Tasks</TH>
	</TR>
	</thead>
	<tbody>
	<CFOUTPUT>
		<CFLOOP query="getAllmembers">
			<tr>
				<TD>#firstName# #lastName#<cfif NOT len(firstName) AND NOT len(lastName)>#email#</cfif></TD>
				<TD>#helpers.activeIndicator(isVerified)#</TD>
				<TD><cfif event.can('edit_member')><A href="#BuildURL(event=url.event, action='editmember', id = memberID, args='function=edit')#">Edit</A></cfif></TD>
				<TD><cfif event.can('delete_member')><A href="#BuildURL(event=url.event, action='editmember', id=memberID, args='function=delete')#">Delete</A></cfif></TD>
			</TR>
		</CFLOOP>
	</CFOUTPUT>
	</tbody>
</TABLE>
<cfif settings.Var('subscriptions.sendByMC') AND event.can('edit_mail')>
<h1>Email Manager</h1>
<cfif event.can('create_mail')><p>[<A href="<cfoutput>#BuildURL(event=url.event, action='editemail', args='function=add')#</cfoutput>">Add</A>]</p></cfif>
<TABLE id="users" border="0" cellspacing="0">
	<thead>
	<TR> 
		<TH>Subject</TH>
		<TH>Created Date</TH> 
		<TH>Delivery Date</TH> 
		<TH>Status</TH> 
		<TH colspan="2">Tasks</TH> 
	</TR> 
	</thead>
	<tbody>
	<CFOUTPUT> 
		<CFLOOP query="getAllemails"> 
			<tr>
				<TD>#Subject#</TD>
				<TD>#dateformat(CreatedDate, 'mm/dd/yy')#</TD> 
				<TD>#dateformat(DeliveryDate, 'mm/dd/yy')#</TD> 
				<TD>#helpers.activeIndicator(status)#</TD> 
				<TD><cfif event.can('edit_mail')><A href="#BuildURL(event=url.event, action='editemail',id=emailID, args='function=edit')#">Edit</A></cfif></TD>  
				<TD><cfif event.can('delete_mail')><A href="#BuildURL(event=url.event, action='editemail', id=emailID, args='function=delete')#">Delete</A></cfif></TD> 
			</TR> 
		</CFLOOP> 
	</CFOUTPUT> 
	</tbody>
</TABLE>
</cfif>