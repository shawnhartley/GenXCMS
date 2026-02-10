<cfif isdefined("form.submit")>
<cfset dupePage = createObject("component","#application.dotroot#cfcs.pageDuplication").init()>
<cfset dupePage.findparentSetNewParent(argumentCollection=form)>
<cflocation url="/managementcenter/index.cfm?event=pages" addtoken="no">
</cfif>

<cfprocessingdirective suppresswhitespace="true">
    <cfquery name="getOne" datasource="#application.dsn#">
        SELECT     *
        FROM page
            WHERE 1 = 1
              AND landingid = #url.id#
        ORDER BY sortorder, title
    </cfquery>
    
<!--- get all the pages in the database --->
    <cfquery name="getAll" datasource="#application.dsn#">
        SELECT     *
        FROM page
            WHERE 1 = 1
        ORDER BY sortorder, title
    </cfquery>

<cfoutput>
	<cfif isDefined('url.success')>
    <div align="center">
	    <cfif url.success EQ false>ERROR: </cfif>#url.message#
    </div>
    </cfif>
</cfoutput>
<form method="post" name="form1" action="" onsubmit="return validateForm();">
<table id="users" cellpadding="5" cellspacing="0">
<thead>
        <tr align="left">
            
                <th width="200">Do you want to duplicate?</th>
            <th width="50">&nbsp;</th><th width="30">&nbsp;</th>
            
        </tr>
</thead>
</table>  
<table cellpadding="5" cellspacing="0">
	<tbody>
        <tr>
        <td width="20"></td>    
                <td class="ss-item-required"><cfoutput><strong>#getOne.title#</strong> - rename to: <input type="text" name="parentName" value=""/></cfoutput></td>
             <td></td>
            
        </tr>
</tbody></table>

	<cfoutput>#doLoop(getAll,url.id)#</cfoutput>

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
<table cellpadding="5" cellspacing="0">
	<tbody>
    <tr>
      <td width="30"><cfif event.hasChildren(landingid)><a href="##" class="trigger">+</a></cfif></td>
      <td><a href="#BuildURL(event=prefix & q.url, args='', manage=false)#" target="_blank">#q.title#</a></td>
      <td></td>
	</tr>
</tbody></table>    

</cffunction>

<table cellpadding="5" cellspacing="0">	
<tr><td colspan="3"><input type="hidden" value="<cfoutput>#url.id#</cfoutput>" name="landingid" /><input type="submit" value="Duplicate Now" name="submit" /></td></tr>

<!---onclick="return confirm('Are you sure you want to duplicate this section?');"--->
</table>  

</form>

<script>
function validateForm()
{
var x=document.forms["form1"]["parentName"].value;
if (x==null || x=="")
  {
  alert("You must fill out the rename field.");
  return false;
  } else {
  return confirm('Are you sure you want to duplicate this section?');
  }
}
</script>
