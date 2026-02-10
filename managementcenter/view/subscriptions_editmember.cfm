<!--- Check login status --->
<cfset application.helpers.checkLogin()>

<CFPARAM NAME="url.id" DEFAULT="0">

<CFIF isdefined('form.Action')>

<CFIF form.Action is "INSERT">
<cfset event.addmailinglistmembers(argumentcollection=form)>
<CFLOCATION url="#buildURL(event="subscriptions",args='msg=0')#" addtoken="false">
</cfif>

<cfif form.action eq "Update">
<cfset event.updatemailinglistmembers(argumentcollection=form)>
<CFLOCATION url="#buildURL(event="subscriptions",args='msg=1')#" addtoken="false">
</CFIF>

<cfif form.action eq "delete">
<cfset event.deletemailinglistmembers(argumentcollection=form)>
<CFLOCATION url="#buildURL(event="subscriptions",args='msg=1')#" addtoken="false">
</CFIF>
</cfif>

<cfset lists = event.getmailinglistList()>
<!--- get all the mailinglistmembers in the database --->
<cfset getmailinglistmembers = event.getmailinglistmembers(memberID = url.id) />
<cfset mylists = event.getMyLists(url.id)>
<h1><cfif url.function eq "Add">Add<cfelseif url.function eq "edit">Edit<cfelse>Delete</cfif> Mailing List Member</h1>
<cfoutput>
<FORM action="" method="post" name="frmmailinglistmembers">
	<INPUT TYPE="hidden" NAME="memberID" value="#url.id#">

		<ul>
			<li><label for="email">Email Address</label><br>
			<INPUT TYPE="TEXT" NAME="email" VALUE="#getmailinglistmembers.email#"  SIZE="100"></li>

			<li><label for="firstName">First Name</label><br>
			<INPUT TYPE="TEXT" NAME="firstName" VALUE="#getmailinglistmembers.firstName#"  SIZE="50"></li>
			<li><label for="lastName">Last Name</label><br>
			<INPUT TYPE="TEXT" NAME="lastName" VALUE="#getmailinglistmembers.lastName#"  SIZE="50"></li>

			
			<li><label for="isVerified">Is Member Verified?</label><br>
			    <select name="isVerified" size="1" >
					<option value="0"> -- Select -- </option>
			        <option value="1" <cfif getmailinglistmembers.isVerified eq "1">selected</cfif>>Yes</option>
			        <option value="0" <cfif getmailinglistmembers.isVerified eq "0">selected</cfif>>No</option>
			    </select></li>

			<li><label for="memberof">Member Is Subscribed to</label><br>
				<cfloop query="lists">
		<input type="checkbox" name="memberof" value="#lists.listID#" <cfif mylists['listID'].indexOf(lists.listID) + 1>checked</cfif>> #lists.listName# <br/>
		</cfloop>
</li>

		<cfswitch expression="#url.function#">
                        <cfcase value="add">
                        	  <INPUT TYPE="HIDDEN" NAME="Action" VALUE="INSERT">
                              <button class="submit" type="submit" tabindex="30">Add Member</button>
                        </cfcase>
                        <cfcase value="edit">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Update">
                              		<button class="submit" type="submit" tabindex="30">Update Member</button>
                        </cfcase>
                        <cfcase value="delete">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Delete">
                              		<button class="submit" type="submit" tabindex="30" onClick="return confirm('Are you sure you want to delete this record from the database?')">Delete Member</button>
                        </cfcase>
                  </cfswitch>
		</ul>
</FORM>
</cfoutput>