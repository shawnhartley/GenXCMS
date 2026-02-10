
<cfset application.helpers.checkLogin()>

<h1>Management Center: <small><cfoutput><cfif application.settings.var('modules') CONTAINS "MultiSite">#session.siteURL#</cfif></cfoutput></small></h1>
<cfif FileExists( ExpandPath('../default/install/index.cfm') )>
<p class="error"><strong>WARNING:</strong> The Installer is still present on the server. This file should be removed as soon as possible.</p>
</cfif>

<p class="error">
	You do not have permission to visit that page.

</p>