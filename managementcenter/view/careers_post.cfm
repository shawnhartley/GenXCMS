<!--- Check login status --->
<cfset application.helpers.checkLogin()>



<CFPARAM NAME="url.id" DEFAULT="-1">
<CFIF isdefined('form.Action')>
<CFIF form.Action is "INSERT">
	<cfset results = event.addcareer(argumentcollection=form)>
	<cfif results.success>
		<CFLOCATION url="#BuildURL(event=url.event, action='postings', args='archive=#url.archive#', encode=false)#" addtoken="no">
	</cfif>
</cfif>

<cfif form.action eq "Update">
	<cfset results =  event.updatecareer(argumentcollection=form)>
	<cfif results.success>
	<CFLOCATION url="#BuildURL(event=url.event, action='postings', args='archive=#url.archive#&msg=1', encode=false)#" addtoken="no">
	</cfif>
</CFIF>

<cfif form.action eq "delete">
<cfset event.deletecareer(id=url.id)>
<CFLOCATION url="#BuildURL(event=url.event, action='postings', args='archive=#url.archive#&msg=1', encode=false)#" addtoken="no">
</CFIF>
</CFIF>


<cfset getcareer = event.getPostings(id=url.id)>


<cfif structKeyExists(variables, 'results')>
	<cfdump var="#results#">
</cfif>
<cfoutput>
<h1><cfif url.function eq "Add">Add<cfelseif url.function eq "edit">Edit<cfelse>Delete</cfif> Job Posting</h1>
<p><a href="#BuildURL(event='career', action='postings')#">Return To List</a></p>

<FORM action="#BuildURL(event=url.event, action=url.action, id=url.id, args='function=#url.function#')#" method="post" name="frmcareer" id="frmcareer">

			<ul>

				<li><label for="title">Job Title:</label><br />
				<input type="text" NAME="jobTitle" VALUE="#getcareer.jobTitle#"  SIZE="200"></li>
				<li><label for="location">Location:</label><br />
				<input type="text" NAME="location" VALUE="#getcareer.location#"  SIZE="200"></li>
			
				<li><label for="description">Description:</label><br />
				  <textarea name="description" class="ckeditor">#getcareer.description#</textarea></li>
				  				

			<cfif settings.var('career.priority')>
				<li><label for="sortorder">Sort Order:</label><br />
				<input type="text" NAME="sortorder" VALUE="#getcareer.sortorder#" class="smalltext"></li>
			</cfif>

				<li><label for="publishDate">Publish On:</label> (YYYY/MM/DD) <small>(blank to publish immediately)</small><br />
				<input type="text" id="publishDate" class="date-pick" data-invalid="Please enter a valid Publish Date" NAME="publishDate" VALUE="#dateFormat(getcareer.publishDate, 'YYYY/MM/DD')#"  SIZE="16"></li><br>
				<li><label for="endDate">Expire On:</label> (YYYY/MM/DD) <small>(blank to never expire)</small><br />
				<input type="text" id="endDate" class="date-pick"  data-invalid="Please enter a valid End Date" NAME="endDate" VALUE="#dateFormat(getcareer.endDate, 'YYYY/MM/DD')#"  SIZE="16"></li><br>
			<cfif event.can('publish')>
				<li><label for="title">Display on Live Site:</label><br />
				<select name="active" size="1" >
					<option value="no"> -- Select -- </option>
					<option value="yes"<cfif getcareer.active eq "yes">selected</cfif>>Yes</option>
					<option value="no" <cfif getcareer.active eq "no">selected</cfif>>No</option>
				</select></li>
			<cfelse>
				<input type="hidden" name="active" value="no" />
			</cfif>

			
				<li>
				<INPUT TYPE="hidden" NAME="id" value="#id#">
				
				<cfswitch expression="#url.function#">
                        <cfcase value="add">
							  <INPUT TYPE="HIDDEN" NAME="Action" VALUE="INSERT">
                              <button class="submit" type="submit" tabindex="30">Add Posting</button>
                        </cfcase>
                        <cfcase value="edit">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Update">
                              		<button class="submit" type="submit" tabindex="30">Update Posting</button>
                        </cfcase>
                        <cfcase value="delete">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Delete">
                              		<button class="submit" type="submit" tabindex="30" onClick="return confirm('Are you sure you want to delete this record from the database?')">Delete Posting</button>
                        </cfcase>
                  </cfswitch>
			</li>
			</ul>
</FORM>
</cfoutput>