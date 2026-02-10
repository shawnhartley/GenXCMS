<!--- Check login status --->
<cfset application.helpers.checkLogin()>

<cfprocessingdirective suppresswhitespace="true">


<!--- get all the pages in the database --->
<cfset getAll = event.getpagesList(orderby="sortorder, title") />
<cfset showHistory = settings.Var('content.showHistory')>
<cfset can = {
		edit = event.can('edit'),
		edit_published = event.can('edit_published'),
		delete = event.can('delete'),
		delete_published = event.can('delete_published')
	}>
<h1>Page Management</h1>
<cfoutput>
	      <div align="center"><h2></h2></div>
	      <cfif isDefined('url.success')>
		            <div align="center">
			                  <cfif url.success EQ false>ERROR: </cfif>#url.message#
		            </div>
	      </cfif>
</cfoutput>
<cfoutput><a class="createnewpage"  href="#BuildURL(event=url.event, action='edit', args='function=add')#"></a></cfoutput><br /><br /><br />
<cfif structKeyExists(url, 'msg')><p class="success">Changes may not appear on the live site for up to 5 minutes.</p></cfif>

<table id="users" border="0" cellspacing="0">
		<thead>
	      <tr align="left">
			            <th>Page Title</th>
			            <th width="40" title="Show In Navigation bars">Nav</th>
			            <th width="40">Publish</th>
			            <th width="60">Approved</th>
			            <th align="center" width="70">Edit</th>
			            <th align="center" width="70">Delete</th>
                <cfif settings.var('content.duplicate')><th width="110">Duplicate</th></cfif>
	      </tr>
		  </thead>
</table>
	<cfoutput>#doLoop(getAll)#</cfoutput>

<br/><br/>

</cfprocessingdirective>


<cffunction name="doLoop" output="yes">
	<cfargument name="getAll" type="query" required="yes">
	<cfargument name="parent" type="numeric" default="0">
	<cfargument name="prefix" type="string" default="">
	<cfset var sub = ''>
		<cfquery dbtype="query" name="sub">
			SELECT * FROM arguments.getAll WHERE parent = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.parent#">
		</cfquery>
		<cfif sub.recordcount EQ 0><cfreturn></cfif>
		
        <ul class="pagelist">
		<cfloop query="sub">
		<li><cfset disp(sub, arguments.prefix)>
		<cfset doLoop(arguments.getAll, sub.landingId, arguments.prefix & sub.url & '/')>
		</li>
		</cfloop> 
		</ul>
</cffunction>

<cffunction name="disp" output="yes" >
<cfargument name="q" type="query" required="yes">
<cfargument name="prefix" type="string" default="">
<table cellspacing="0"><tr>
      <td width="30"><span id="#landingid#"><cfif event.hasChildren(landingid)><a href="##" class="trigger">+</a></cfif></span></td>
      <td><a href="#BuildURL(event=prefix & q.url, args='', manage=false)#" target="_blank">#q.title#</a></td>
      <td width="40" align="center">#helpers.showNavToggle(q.showNav, q.landingid)#</td>
      <td width="40" align="center">#helpers.isDraftToggle(q.isDraft, q.landingid)#</td>
      <td width="60" align="center">#helpers.activateToggle(q.approved, q.landingid)#</td>
      <TD class="editpage" width="70"><cfif can.edit_published OR (can.edit AND q.approved EQ "no")><a href="#buildurl(event="pages",action="edit", id=landingid, args="function=edit")#"></a></cfif></td>
      <td class="deletepage" width="70"><cfif can.delete_published OR (can.delete AND q.approved EQ "no")><a href="#BuildURL(event='pages', action='edit', id=landingId, args='function=delete')#"></a></cfif></td>
    <cfquery datasource="#application.dsn#" name="suba">
            SELECT * FROM page 
             WHERE 1=1 
               and parent = 0 
               and landingid = <cfqueryparam cfsqltype="cf_sql_integer" value="#landingId#">
    </cfquery>

<cfif suba.recordcount NEQ 0>
	<cfif settings.var('content.duplicate')><td class="duplicatepages"><a href="#BuildURL(event='pages', action='duplicate', id=landingId, args='function=dupe')#"></a></td>
    </cfif>
<cfelse>
	<td class="duplicatepages"></td> 
</cfif>

</tr></table>
</cffunction>
<cfif isdefined("url.marker")>
<script>
$( document ).ready(function() { 
$("#<cfoutput>#url.marker#</cfoutput>").parents("ul.pagelist").attr("style","").closest("ul.pagelist").attr("style","").siblings().find("a.trigger").html("-");
/*$("#<cfoutput>#url.marker#</cfoutput> a.trigger").html("-");*/
$("#<cfoutput>#url.marker#</cfoutput>").get(0).scrollIntoView();
});
</script>
</cfif>