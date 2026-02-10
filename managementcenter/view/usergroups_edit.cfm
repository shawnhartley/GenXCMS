<cfset application.helpers.checkLogin()>

<CFPARAM NAME="url.id" DEFAULT="0">
<CFPARAM NAME="form.securityroles" DEFAULT="">
<CFPARAM NAME="form.limitToMods" DEFAULT="">

<CFIF isdefined('form.Action')>
<CFIF form.Action is "INSERT">
<cfset event.addusergroup(argumentcollection=form)>
<CFLOCATION url="#BuildURL(event=url.event, encode=false)#" addtoken="no">
</cfif>

<cfif form.action eq "Update">
<cfset event.saveusergroup(argumentcollection=form)>
<CFLOCATION url="#BuildURL(event=url.event, args='msg=1', encode=false)#" addtoken="no">
</CFIF>

<cfif form.action eq "delete">
<cfset event.deleteusergroup(argumentcollection=form)>
<CFLOCATION url="#BuildURL(event=url.event, args='msg=1', encode=false)#" addtoken="no">
</cfif>
</cfif>

<cfset getusergroups = event.getusergroups(url.id) />
<cfset getcapabilitylist = event.getcapabilityList()>
<cfset getcurrentcapabilities = event.getcurrentcapabilities(url.id)>
<cfif url.id IS NOT 0>
<h1>Edit User Group</h1>
<div class="backbutton"><cfoutput><a href="#BuildURL(event='usergroups')#">&lt; Back to List</a></cfoutput></div>
<cfelse>
<h1>Add User Group</h1><br>
</cfif>
<cfif session.usergroupid EQ url.id><p class="error"><strong>Note:</strong> You can view the current capabilities of this group, but you will not be able to change them.</p></cfif>
<FORM action="<cfoutput>#BuildURL(event=url.event, action='edit', id=url.id)#</cfoutput>" method="post" name="frmusergroups">

<ul>
	<li><label for="groupName">Group Name:<br /><input type="text" id="groupName" name="groupName" value="<cfoutput>#getusergroups.groupName#</cfoutput>" /></label></li>
	<li><label>Members can access the management center?</label><br />
		<label><input type="radio" name="manager" value="1"<cfif getusergroups.manager EQ 1> checked="checked"</cfif> /> Yes</label><br />
		<label><input type="radio" name="manager" value="0"<cfif NOT getusergroups.manager EQ 1> checked="checked"</cfif> /> No</label><br />
	</li>
	<li>
		<h2>Capabilities:<br /></h2>
		<cfset heading = ''><cfset div = ''>
		<div  class="capfloat">
		<div>
		<cfoutput query="getcapabilitylist"><cfset checked = getcurrentcapabilities['capabilityID'].indexOf(getcapabilitylist.id) GTE 0 ? 'checked="checked"' : ''>
			<cfif event.can(name, component)><!--- only allow user to create a group with capabilities equal to or less than their own. --->
			<cfif getcapabilitylist.component NEQ heading>#div#
				<cfset heading = getcapabilitylist.component>
				<h3>#event.titleCaseList(replace(heading, 'cfcs.', ''), ' ')#</h3>
				<a href="##" class="select">Select All</a> / <a href="##" class="deselect">Deselect All</a><br /><cfset div = '<br /></div><div>'>
			</cfif>
			<label><input name="capabilities" type="checkbox" value="#getcapabilitylist.id#" #checked# /> #name#</label><br />
			</cfif>
		</cfoutput>
		</div>
		</div>
	</li>
	<li>
                              <INPUT TYPE="hidden" NAME="group_id" value="<cfoutput>#url.id#</cfoutput>">
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