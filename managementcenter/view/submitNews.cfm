<!--- Check login status --->
<cfset application.helpers.checkLogin()>



<CFPARAM NAME="url.id" DEFAULT="-1">
<CFIF isdefined('form.Action')>
	<CFIF form.Action is "INSERT">
		<cfset result = event.submit(argumentcollection=form)>
	</cfif>
	<cfif result.post.statuscode EQ '202 Accepted' AND result.mailed>
		<p class="success">Your submission has been recorded. Thank you.</p>
		<p><a href="">Submit Another</a></p>
	<cfelseif result.post.statuscode NEQ '202 Accepted'>
		<p class="error">Your submission could not be saved.</p>
	<cfelseif NOT result.mailed>
		<p class="error">Your submission was recorded, but a notification mail was not sent.</p>
	<cfelse>
		<p class="error">Something went wrong - Errors follow</p>
		<cfdump var="#results.catch#">
	</cfif>
<cfelse>

<h1>Submit a News Article for Approval</h1>

<FORM action="<cfoutput>#BuildURL(event=url.event )#</cfoutput>" method="post" name="frmnews" id="frmnews">

			<ul>
            	<li><label for="title">Article Headline:</label><br />
				<input type="text" NAME="headline" VALUE=""  SIZE="200"></li>
			
				<li><label for="content">Article Content:</label><br />
				  <textarea name="content" class="ckeditor"></textarea></li>

				<li><label for="dateSelect">Publish On:</label> <small>(YYYY/MM/DD)</small><br />
				<input type="text" id="dateSelect" class="date-pick" required="required" data-invalid="Please enter a valid Publish Date" NAME="dateSelect"  SIZE="16"></li><br>
				
				<p class="success">This article must be approved by a moderator before it will appear on the live site.</p><input type="hidden" name="approved" id="approved" value="No">


				<li><table width="100%" cellspacing="0" cellpadding="0">
						<TR>
				<INPUT TYPE="hidden" NAME="id" value="<cfoutput>#id#</cfoutput>">
				
							  <INPUT TYPE="HIDDEN" NAME="Action" VALUE="INSERT">
                              <button class="submit" type="submit" tabindex="30">Submit Article</button>
                        
			</TD>
		</TR>
	</TABLE>
    </li>
    </ul>
</FORM>
</cfif>