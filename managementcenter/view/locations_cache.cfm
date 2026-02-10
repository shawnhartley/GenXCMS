<!--- Check login status --->
<cfset application.helpers.checkLogin()>

<CFPARAM NAME="result" DEFAULT="">
<CFIF isdefined('form.Action')>
	
	<cfif form.action eq "Update">
		<cfset result = event.saveToDisk(argumentcollection=form)>
	</CFIF>


</CFIF>



<cfoutput>
<h1>Update Location Cache</h1>
<cfif len(result)>
	<cfif result>
		<p class="success">Cache file updated.</p>
	<cfelse>
		<p class="error">File could not be updated at this time.</p>
	</cfif>
</cfif>

<div class="backbutton"><a href="#BuildURL(event=url.event)#">&lt; Back to List</a></div>
<FORM action="#BuildURL(event=url.event, action=url.action, args='function=#url.function#')#" method="post">
<p>The cache file was last updated on:<br /><cfset cachedate = event.getCacheDate()>
	<cfif cachedate NEQ NOW() or len(result)>#DateFormat(cachedate, "mmm dd, yyyy")# at #TimeFormat(cachedate, "hh:mm tt")#
	<cfelse>NEVER UPDATED
	</cfif>
	</p>
	 <cfswitch expression="#url.function#">
                        <cfcase value="update">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Update">
                              		<button class="submit" type="submit" tabindex="30">Update Cache File</button>
                        </cfcase>
                  </cfswitch>
	<br />


</FORM>
</cfoutput>