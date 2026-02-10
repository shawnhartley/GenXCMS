<h1 style="margin-bottom: 0.5em;" class="error">Forbidden</h1>
<cfoutput><p class="error">#myError.message#</p></cfoutput>
<cfif structkeyexists(url, "debug")>
	<cfdump var="#myError#">
</cfif>