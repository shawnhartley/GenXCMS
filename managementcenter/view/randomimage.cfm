<!--- Check login status --->
<cflock scope="Session" type="ReadOnly" timeout="60">
	<cfif NOT IsDefined("Session.status") OR Session.status NEQ "login">
		<cflocation URL="#application.slashroot#managementcenter/index.cfm?action=login" addtoken="No">
	</cfif>
</cflock>
<cfset list = event.getfilelist()>

<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(list) />

<cfset pagination.setItemsPerPage(15) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<h1>Random Image Pool</h1>
<cfoutput><a class="addnewsarticle" href="#BuildURL(event=url.event, action='edit', args='function=upload')#">Upload Image</a></cfoutput>
<br><br>
<TABLE id="quicklinks" border="0" cellspacing="0">
	<thead>
	<TR>
		<TH>Filename</TH>
		
		<TH>Delete</TH>
	</TR>
    </thead>
	<tbody>
    <cfoutput query="list" maxrows="#pagination.getmaxrows()#" startrow="#pagination.getstartrow()#">
	        <tr bgcolor="##FFFFFF" onMouseOver="this.style.backgroundColor='##99CCFF'" onMouseOut="this.style.backgroundColor='##FFFFFF'">
				<TD><a href="#application.settings.var('randomimage.imagepool')##name#" target="_blank">#name#</a></TD>
				<TD class="delete"><A href="#BuildURL(event=url.event, action='edit', args='function=delete&id=#name#')#">Delete</A></td>
			</TR>
	</cfoutput>
	</tbody>
</TABLE>


<cfoutput>#pagination.getRenderedHTML()#</cfoutput>
