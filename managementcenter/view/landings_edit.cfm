<!--- Check login status --->
<cfset application.helpers.checkLogin()>
<cfparam name="url.id" default="0">
<cfif isdefined('form.Action')>

<!---<cfdump var="#form#" abort>--->

<cfif form.Action is "INSERT">
<cfset event.addLanding(argumentcollection=form)>
<cflocation url="#BuildURL(event=url.event, args='', encode=false)#" addtoken="no">
</cfif>

<cfif form.action eq "Update">
<!--- Check path existence --->
<cfset event.editLanding(argumentcollection=form)>
<cflocation url="#BuildURL(event=url.event, args='', encode=false)#" addtoken="no">
</cfif>

<cfif form.action eq "delete">
<cfset event.deleteLanding(form.landingName,form.idlandings)>
<cflocation url="#BuildURL(event=url.event, args='', encode=false)#" addtoken="no">
</cfif>
</cfif>

<cfset getlandings = event.getLandings(url.id)>

<h1><cfif url.function eq "Add">Add<cfelseif url.function eq "edit">Edit<cfelse>Delete</cfif> Landings</h1>
<p><cfoutput><a href="#BuildURL(event='landings', args='')#">Return To List</a></cfoutput></p>

<form enctype="multipart/form-data" action="<cfoutput>#BuildURL(event=url.event, action=url.action, id=url.id, args='function=#url.function#')#</cfoutput>" method="post" name="frmlandings" id="frmlandings">

	<ul>

				<li><label for="title">Name of this landing:</label><br />
				  <input type="text" name="landingName" VALUE="<cfoutput>#getlandings.landingName#</cfoutput>"  size="200"></li>
              
				<li>
                <label for="title">Landing Type:</label>
                <br />
				<select name="landingType" >
					<option value="0"> -- Select -- </option>
                    <option value="1" <cfif getlandings.landingType eq 1>selected</cfif>>Lead Generator Left</option>
                    <option value="2" <cfif getlandings.landingType eq 2>selected</cfif>>Lead Generator Center</option>
                    <option value="3" <cfif getlandings.landingType eq 3>selected</cfif>>Lead Generator Right</option>
				</select>
				</li>

                <li><label for="summary">Logo Image (optional):</label><br />
                Current Logo Name: <cfoutput>#getlandings.leadLogo#</cfoutput> <cfif getlandings.leadLogo neq ''><input type="checkbox"
                       name="removeLogo" 
                       value="1" />: Remove the logo image</cfif><br /><input type="file" name="leadLogo"> </li> 
                
                <input type="hidden" 
                       name="leadLogoExisting" 
                       value="<cfoutput>#getlandings.leadLogo#</cfoutput>">
                
                <li><label for="summary">Landing Image:</label><br />
                Current Image Name: <cfoutput>#getlandings.landingImage#</cfoutput> <cfif getlandings.landingImage neq ''><input type="checkbox"
                       name="removeImage" 
                       value="1" />: Remove this image</cfif><br />
                <input type="file" name="landingImage"></li> 
                
                <input type="hidden" 
                       name="landingImageExisting" 
                       value="<cfoutput>#getlandings.landingImage#</cfoutput>">

				<li>
				    <label for="title">Landing Page Headline:</label><br />
				  <input type="text" name="headline" VALUE="<cfoutput>#getlandings.headline#</cfoutput>"  size="200"></li>

				<!---<li><label for="title">Call to Action Button Title:</label><br />
				  <input type="text" name="calltoaction" VALUE="<cfoutput>#getlandings.calltoaction#</cfoutput>"  size="200"></li>--->

				<!---<li><label for="title">Super Quote:</label><br />
				  <input type="text" name="superquote" VALUE="<cfoutput>#getlandings.superquote#</cfoutput>"  size="200"></li>--->
				
				<li>
				    <label for="summary">Landing Page Content:</label><br />
				  <textarea name="subhead" class="ckeditor"><cfoutput>#getlandings.subhead#</cfoutput></textarea></li>
                 
				<br><br>
				<p><b>Callouts</b><br>
				The following three text boxes are used for callouts. These are placed within a grey box with three columns. Each text box represents one column in the box going left to right. If you wish to have only one column that stretches the full width of the box then only place content in the first box and be certain there is NOTHING in the center and right boxes.</p>
                <li><label for="content">Callout Left Column:</label><br />
				  <textarea name="toutLine1" class="ckeditor"><cfoutput>#getlandings.toutLine1#</cfoutput></textarea></li>
                
                <li><label for="content">Callout Center Column:</label><br />
				  <textarea name="toutLine2" class="ckeditor"><cfoutput>#getlandings.toutLine2#</cfoutput></textarea></li>
                
                <li><label for="content">Callout Right Column:</label><br />
				  <textarea name="toutLine3" class="ckeditor"><cfoutput>#getlandings.toutLine3#</cfoutput></textarea></li>                                    
				  
			     <li><label for="title">Activate:</label><br />
				<select name="active" size="1" >
					<option value="no"> -- Select -- </option>
					<option value="yes"<cfif getlandings.active eq "yes">selected</cfif>>Yes</option>
					<option value="no" <cfif getlandings.active eq "no">selected</cfif>>No</option>
				</select></li>
                <li><label for="landingThankyou">Thank you page URL:</label><br />
				  <input type="text" name="landingThankyou" value="<cfoutput>#getlandings.landingThankyou#</cfoutput>"></li>


				<li><table width="100%" cellspacing="0" cellpadding="0">
						<TR>
				<INPUT TYPE="hidden" NAME="idlandings" value="<cfoutput>#url.id#</cfoutput>">
				
				<cfswitch expression="#url.function#">
                        <cfcase value="add">
							  <INPUT TYPE="HIDDEN" NAME="Action" VALUE="insert">
                              <button class="submit" type="submit" tabindex="30">Add Landing</button>
                        </cfcase>
                        <cfcase value="edit">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="update">
                              		<button class="submit" type="submit" tabindex="30">Update Landing</button>
                        </cfcase>
                        <cfcase value="delete">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="delete">
                              		<button class="submit" type="submit" tabindex="30" onClick="return confirm('Are you sure you want to delete this record from the database?')">Delete Landing</button>
                        </cfcase>
                  </cfswitch>
			</TD>
		</TR>
	</TABLE>
    </li>
    </ul>
</form>