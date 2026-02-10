<cfset application.helpers.checkLogin()>

<CFPARAM NAME="url.id" DEFAULT="0">
<CFIF isdefined('form.Action')>
	<CFIF form.Action is "INSERT">
	<cfset event.addlogins(argumentcollection=form)>
	        <CFLOCATION url="#BuildURL(event='logins', encode=false)#" addtoken="no">
	</cfif>
	<CFIF form.Action is "capabilities">
	<cfset event.saveCapabilities(argumentcollection=form)>
	        <CFLOCATION url="#BuildURL(event='logins', encode=false)#" addtoken="no">
	</cfif>

	<cfif form.action eq "Update">
		<cfset event.updatelogins(argumentcollection=form)>
	        <CFLOCATION url="#BuildURL(event='logins', args='msg=1', encode=false)#" addtoken="no">
	</CFIF>

	<cfif form.action eq "delete">
		<cfset event.deletelogins(argumentcollection=form)>
	        <CFLOCATION url="#BuildURL(event='logins', args='msg=1', encode=false)#" addtoken="no">
	</CFIF>
</CFIF>

<!--- get all the logins in the database --->
<cfset getlogins = event.getlogins(id=url.id GT 0 ? url.id : -1)>
<cfset getusergroups = event.getusergroupsList()>


<cfif id IS NOT 0>
<h1>Edit User</h1>
<div class="backbutton"><cfoutput><a href="#BuildURL(event='logins')#">&lt; Back to List</a></cfoutput></div>
<cfelse>
<h1>Add User</h1><br>
</cfif>
<cfoutput>
<FORM action="#BuildURL(event='logins', action='edit')#" method="post" name="frmlogins">
<INPUT TYPE="hidden" NAME="id" value="#id#">
<ul>
    <li><label for="displayName">Display Name:<br /><INPUT TYPE="TEXT" NAME="displayName" VALUE="#HTMLEditFormat(getlogins.displayName)#" SIZE="80" /></label></li>
	<li><label for="username">Email Address:<br /><INPUT TYPE="TEXT" NAME="username" VALUE="#HTMLEditFormat(getlogins.username)#"  SIZE="50" /></label></li>
	<li><label for="password"><cfif url.id GT 0>Change </cfif>Password:<br /><INPUT TYPE="TEXT" NAME="password" VALUE=""  SIZE="50" /></label></li>
	<li><label for="groups">Group:<br />
		<select name="groups">
			<cfloop query="getusergroups">
			<cfif session.usergroupID LTE getusergroups.group_ID> <!--- Cannot give yourself a higher usergroup than you already have --->
			<option value="#getusergroups.group_ID#" <cfif getusergroups.group_ID eq getlogins.group_ID>selected</cfif>>#getusergroups.groupname#</option>
			</cfif>
			</cfloop>
		</select>
	</label></li>
	<li> <cfswitch expression="#url.function#">
                        <cfcase value="add">
                        	  <INPUT TYPE="HIDDEN" NAME="Action" VALUE="INSERT">
                              <button class="submit" type="submit" tabindex="30">Add User</button>
                        </cfcase>
                        <cfcase value="edit">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Update">
                              		<button class="submit" type="submit" tabindex="30">Update User</button>
                        </cfcase>
                        <cfcase value="delete">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Delete">
                              		<button class="submit" type="submit" tabindex="30" onClick="return confirm('Are you sure you want to delete this record from the database?')">Delete User</button>
                        </cfcase>
                  </cfswitch>
	</li>
</ul>

</FORM>
<cfif event.can('grant_capabilities')>
<h1>Override Capabilities</h1>
<p class="error">Use only if usergroups cannot be used.</p>
<h2>TODO</h2><!---
<form action="#BuildURL(event='logins', action='edit')#" method="post">
<fieldset class="collapse"><legend>Show</legend>
	<cfset heading = ''><cfset div = ''>
	<div  class="capfloat">
	<div>
	<cfoutput query="getcapabilitylist"><cfset checked = getcurrentcapabilities['capabilityID'].indexOf(getcapabilitylist.id) GTE 0 ? 'checked="checked"' : ''>
		<cfif getcapabilitylist.component NEQ heading>#div#
			<cfset heading = getcapabilitylist.component>
			<h3>#event.titleCaseList(replace(heading, 'cfcs.', ''), ' ')#</h3>
			<a href="##" class="select">Select All</a> / <a href="##" class="deselect">Deselect All</a><br /><cfset div = '<br /></div><div>'>
		</cfif>
		<label><input name="capabilities" type="checkbox" value="#getcapabilitylist.id#" #checked# /> #name#</label><br />
	</cfoutput>
	</div>
	</div>

</fieldset>
</form>--->
</cfif>
</cfoutput>