<!--- Check login status --->
<cfset application.helpers.checkLogin()>


<CFPARAM NAME="id" DEFAULT="0">
<CFIF isdefined('form.Action')>


<cfif form.action eq "delete">
	<cfset results = event.deleteApplication(id=url.id)>
	<cfif results.success>
		<cflocation addtoken="no" url="#BuildURL(event=url.event,encode=false)#">
	</cfif>
</CFIF>
</CFIF>


<cfset getapp = event.getapplications(id=url.id)>

<cfwddx action="wddx2cfml" input="#getapp.formPacket#" output="formpacket" >


<cfoutput>

<h1><cfif url.function eq "View">View<cfelse>Delete</cfif> careers </h1>
<p><a href="#BuildURL(event=url.event)#">Return To List</a></p>


<FORM action="" method="post" name="frmnews">

<table border="0" cellspacing="0" cellpadding="0" id="users" class="lefttable">
					<cfset i = 1>
					<cfloop index="x" list="#application.settings.Var('careers.formFields')#">
					<cfset x = trim(x)>
					<cfparam name="formpacket.#x#" default="">
					<tr>
					  <td>#ListGetAt(application.settings.Var('careers.labelFields'),i)#:</td><td> <cfif listfind(application.settings.Var('careers.listFields'),x)><br />
							<cfloop list="#formpacket[x]#" index="y">
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#y#<br />
							</cfloop>
						<cfelse>
							#formpacket[x]#
						</cfif></td>
					<cfset i = i + 1>
					</tr>
					</cfloop>
					<cfif len(getapp.filename)>
					<tr><td>Uploaded Resume:</td><td><a href="#settings.varStr('careers.path')##getapp.filename#">#getapp.filename#</a></td></tr>
					</cfif>
					</table>
		<ul>
                

							<li><table width="100%" cellspacing="0" cellpadding="0">
						<TR>
				<INPUT TYPE="hidden" NAME="id" value="#url.id#">
				<cfswitch expression="#url.function#">
                        <cfcase value="delete">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Delete">
                              		<button class="submit" type="submit" tabindex="30" onClick="return confirm('Are you sure you want to delete this record from the database?')">Delete Application</button>
                        </cfcase>
                  </cfswitch>
			</TD>
		</TR>
	</TABLE>
    </li>
    </ul>
</FORM>
</cfoutput>	