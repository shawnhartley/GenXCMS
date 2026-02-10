<cfset application.helpers.checkLogin()>

<cfset getlandings = event.getLandings()>

<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(getlandings) />
<cfif settings.var('prettyURLs')>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/landings/')>
</cfif>

<cfset pagination.setItemsPerPage(15) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />

<h1>Landings</h1>


<a class="addnewsarticle"
   href="<cfoutput>#BuildURL(event=url.event, 
                             action='edit', 
                             args='function=add')#</cfoutput>">Add landing</a>
<br><br>

<table id="quicklinks"
       border="0" 
       cellspacing="0">
	<thead>
	<tr>
		<th>Landing Name</th>
		<th>Headline</th>
        <th>Images</th>
        <th>Active</th>
		<th>Edit</th>
        <th>Delete</th>
	</tr>
	</thead>
	<tbody>
	<cfoutput 
		query="getlandings" 
		startrow="#pagination.getStartrow()#" 
		maxrows="#pagination.getMaxRows()#">
		<cfset class = "">
		
			<tr #class#>
            	<td><a href="/landings/#idlandings#" target="_blank">#landingName#</a></td>
				<td>#headline#</td>
				<td><cfif landingImage NEQ ''><img src="/uploads/landings/#landingImage#" height="35px"></cfif></a></td>                
				<td><cfif active>
                	<img src="#application.slashroot#managementcenter/images/main/active.gif">
                    <cfelse>
                    <img src="#application.slashroot#managementcenter/images/main/inactive.gif">
                    </cfif>
                </td>
				<td class="editnews">
                    <A href="#BuildURL(event='landings',
                                       action='edit',
                                       id=getlandings.idlandings,
                                       args='function=edit')#"></a>
                </td>
                <td class="deletenews">
                <A href="#BuildURL(event='landings',
                                   action='edit',
                                   id=getlandings.idlandings,
                                   args='function=delete')#"></a>
                </td>
			</tr>
	</cfoutput>
	</tbody>
</TABLE>


<cfoutput>#pagination.getrenderedHTML()#</cfoutput>
