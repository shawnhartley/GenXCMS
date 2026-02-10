<cfset application.helpers.checkLogin()>
<cfset result = structNew()>
<CFIF structKeyExists(form, 'Action')>
	<cfif NOT event.can('update')>
		<cfthrow type="c3d.notPermitted" message="You do not have permission to use this module.">
	</cfif>
	<cfif form.action eq "pull">
		<cfset result = event.pull()>
	</CFIF>
	<cfif form.action eq "push">
		<cfset result = event.push()>
	</CFIF>
</CFIF>

<h2>Database Schema</h2>
<cfif structKeyExists(form, 'Action')>
Result:<br />
<cfoutput><textarea>#result#</textarea></cfoutput>
</cfif>

<form action="" method="post">
<button type="submit" name="action" value="pull">Pull</button><br /><br />
<button type="submit" name="action" value="push">Push</button>
</form>

