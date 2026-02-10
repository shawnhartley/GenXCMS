<!---
      TEMPLATE: dsp_mcadminpermissions.cfm
      AUTHOR: Pat Whitlock
      DATE: 10/21/08
      CHANGE HISTORY:
            * 10/21/2008: template created
--->

<cfset application.helpers.checkLogin()>

<CFPARAM NAME="roleID" DEFAULT="0">
<CFIF isdefined('form.Action')>

<CFIF form.Action is "INSERT">
	<CFQUERY name="addsecurity_roles" datasource="#application.dsn#">
	INSERT INTO security_roles (
								display_name
								)
	VALUES
								(
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#HTMLEditFormat(FORM.display_name)#">
								)
	</CFQUERY>
<CFLOCATION url="index.cfm?event=admin&msg=0" addtoken="no">
<CFELSE>

<CFQUERY name="deletesecurity_roles" datasource="#application.dsn#">
DELETE FROM security_roles
WHERE roleID=#roleID#
</CFQUERY>
<CFLOCATION url="index.cfm?event=admin&msg=1" addtoken="no">
</CFIF>
</CFIF>
<cfquery datasource="#application.dsn#" name="getsecurity_roles">
SELECT *
 FROM security_roles
 WHERE roleID=#roleID#
 </cfquery>

 <FORM action="index.cfm?event=editpermissions" method="post" name="frmsecurity_roles">
 <ul>
 	<li><label for="display_name">Security Role Title:<br /><input type="text" id="display_name" name="display_name" value="<cfoutput>#getsecurity_roles.display_name#</cfoutput>" /></label></li>
	<li>

  <!--- insert hidden fields and determine/create submit button action --->
                        <li>
                              <INPUT TYPE="hidden" NAME="roleID" value="<cfoutput>#roleID#</cfoutput>">
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