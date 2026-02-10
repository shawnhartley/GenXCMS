<!--- Check login status --->
<cfset helpers.checkLogin()>


<CFPARAM NAME="url.id" DEFAULT="0">
<CFIF structKeyExists(form, 'Action')>
<CFIF form.Action is "INSERT">
<cfset event.addemails(argumentcollection=form)>
<CFLOCATION url="#buildURL(event="subscriptions")#" addtoken="no">
</cfif>

<cfif form.action eq "Update">
<cfset event.updateemails(argumentcollection=form)>
<CFLOCATION url="#buildURL(event="subscriptions")#" addtoken="no">
</CFIF>

<cfif form.action eq "delete">
<cfset event.deleteemails(argumentcollection=form)>
<CFLOCATION url="#buildURL(event="subscriptions")#" addtoken="no">
</CFIF>
</CFIF>

<cfset getemails = event.getemails(url.id)>

<cfset lists = event.getmailinglistList()>

<h1><cfif url.function eq "Add">Add<cfelseif url.function eq "edit">Edit<cfelse>Delete</cfif> Email</h1>

<cfoutput>
<FORM action="" method="post" name="frmemails">
	<INPUT TYPE="hidden" NAME="emailID" value="#url.id#">

	<table width="100%" cellspacing="0" cellpadding="0">
		<TR>
			<TD>Message Subject</TD>
			<TD><INPUT TYPE="TEXT" NAME="Subject" VALUE="#getemails.Subject#"  SIZE="255"></TD>
		</TR>
		<TR>
			<TD>Body Text</TD>
			<TD><textarea name="BodyText" cols="40" rows="5">#getemails.BodyText#</textarea></TD>
		</TR>
		<TR>
			<TD>Body HTML</TD>
			<TD>
				  <textarea name="BodyHTML" class="ckeditor">#getemails.bodyHtml#</textarea>
				  <br><br></TD>
		</TR>
		
		 <TR>
			<TD>Delivery Date</TD>
			<TD><INPUT TYPE="TEXT" NAME="DeliveryDate" class="date-pick" VALUE="#dateFormat(getemails.DeliveryDate, "mm/dd/yyyy")#"  SIZE="10"></TD>
		</TR>
		<TR>
			<TD>Deliver To:</TD>
			<TD> <cfloop query="lists">
					<input type="checkbox" name="GroupList" value="#lists.Listname#" <cfif getemails.grouplist eq "#lists.Listname#">checked</cfif>> #lists.Listname# <br/>
				</cfloop>
				  <br><br>
			</TD>
		</TR>
		<TR>
			<TD>Last Update By</TD>
			<TD>#getemails.lastupdatedBy#</TD>
		</TR>
		<TR>
			<TD>Reply To</TD>
			<TD><INPUT TYPE="TEXT" NAME="ReplyTo" VALUE="#getemails.ReplyTo#"  SIZE="50"></TD>
		</TR>
		<TR>
			<TD>Message Format</TD>
			<TD><INPUT TYPE="TEXT" NAME="format" VALUE="#getemails.format#"  SIZE="50"></TD>
		</TR>
		<TR>
			<TD>From Label</TD>
			<TD><INPUT TYPE="TEXT" NAME="fromLabel" VALUE="#getemails.fromLabel#"  SIZE="50"></TD>
		</TR>
		
		<TR>
			<TD>Approved for Delivery</TD>
			<TD><select name="status" size="1" >
					<option value="0"> -- Select -- </option>
			        <option value="1" <cfif getemails.status eq "1">selected</cfif>>Yes</option>
			        <option value="0" <cfif getemails.status eq "0">selected</cfif>>No</option>
			    </select></TD>
		</TR>
		
		<TR>
			<TD colspan=2>
				<cfswitch expression="#url.function#">
                        <cfcase value="add">
                        	  <INPUT TYPE="HIDDEN" NAME="Action" VALUE="INSERT">
                              <button class="submit" type="submit" tabindex="30">Add Email</button>
                        </cfcase>
                        <cfcase value="edit">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Update">
                              		<button class="submit" type="submit" tabindex="30">Update Email</button>
                        </cfcase>
                        <cfcase value="delete">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Delete">
                              		<button class="submit" type="submit" tabindex="30" onClick="return confirm('Are you sure you want to delete this record from the database?')">Delete Email</button>
                        </cfcase>
                  </cfswitch>
			</TD>
		</TR>
	</TABLE>
</FORM>
</cfoutput>