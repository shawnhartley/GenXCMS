<cfset error = ''>
<cfif structKeyExists(form, 'newpassword')>
<cftry>
	<cfset event.saveNewPassword(argumentcollection=form)>
	<cflocation addtoken="no" url="#BuildURL(event='manage', encode=false)#">
	<cfcatch type="c3d.password">
		<cfset error = cfcatch.message>
	</cfcatch>
</cftry>
</cfif>
<h1>Change your password</h1>
<cfif StructKeyExists(url, 'temporary')><h2 class="success">Please reset your password before continuing</h2></cfif>
<cfif len(error)>
	<cfoutput><p class="error">#error#</p></cfoutput>
</cfif>
<form action="" method="post">
<label>Current Password:</label>
<br />
<input type="password" name="oldpassword" />
<br />
<label>New Password:</label>
<br />
<input type="password" name="newpassword" />
<br />
<label>Confirm New password:</label>
<br />
<input type="password" name="confirmpassword" />
<br />
<button type="submit">Change Password</button>

</form>