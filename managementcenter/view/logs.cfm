<!--- Check login status --->
<cfset application.helpers.checkLogin()>
<cfparam name="url.severity" default="">
<cfparam name="url.searchfor" default="">

<cfset logsqueryObject = event.getlogs(argumentcollection=url)>
<cfset logs = logsqueryObject.getResult()>
<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(logs) />
<cfif settings.var('prettyURLs')>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/logs/')>
	<cfif len(url.searchfor) OR len(url.severity)>
	<cfset pagination.setBaseLink(application.slashroot & 'managementcenter/logs/?severity=' & url.severity & '&searchfor=' & url.searchfor)>
	</cfif>
</cfif>
<cfset pagination.setItemsPerPage(50) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />


<h1>Log Viewer</h1>
<br />
<div><cfoutput>
<form action="" method="get">
<cfif NOT settings.var('prettyurls')>
	<input type="hidden" name="event" value="#url.event#" />
</cfif>
Show: 
	
<!--
	Severity 	Integer Level
	OFF 	-1
	FATAL 	0 (Default LevelMin)
	ERROR 	1
	WARN 	2
	INFO 	3
	DEBUG 	4 (Default LevelMax) 
-->
	<select name="severity">
			<cfif url.severity EQ ''><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="" #selected#>All Levels</option>
			<cfif url.severity EQ 'FATAL'><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="FATAL" #selected#>FATAL</option>
			<cfif url.severity EQ 'ERROR'><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="ERROR" #selected#>ERROR</option>
			<cfif url.severity EQ 'WARN'><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="WARN" #selected#>WARN</option>
			<cfif url.severity EQ 'INFO'><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="INFO" #selected#>INFO</option>
			<cfif url.severity EQ 'DEBUG'><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="DEBUG" #selected#>DEBUG</option>
			</select>
	
			Search for: <input type="search" name="searchfor" value="#url.searchfor#" />
			
			Date: <input type="date" name="date" disabled="disabled" />
			<button type="submit" style="float:right;">Filter</button>

</form></cfoutput>
</div>
<br />
<TABLE id="users" class="logs" border="0" cellspacing="0">
	<thead>
	<TR>
		<TH>Date</TH>
		<TH>Component</TH>
		<TH>Message</TH>
		<th>Extra</th>
		<th>Severity</th>
	</TR>
	</thead>
	<tbody>
	<CFOUTPUT query="logs" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
	<tr>
		<td>#DateFormat(logs.logdate, 'yyyy-mm-dd')# #TimeFormat(logs.logdate, 'HH:MM:ss')#</td>
		<td>#logs.category#</td>
		<td>#logs.message#</td>
		<td><div><pre><cftry><cfset dumpVarList(deserializeJSON(logs.extraInfo))><cfcatch>#HTMLEditFormat(LEFT(logs.extraInfo, 255))#<cfif NOT len(logs.extraInfo)>No Extra Info</cfif></cfcatch></cftry></pre></div></td>
		<td>#logs.severity#</td>
	</tr>
	</CFOUTPUT>
	</tbody>
</TABLE>

<cfoutput>#pagination.getRenderedHTML()#</cfoutput>

<cfscript>
/**
* Dumps out variables/structs in simple text format.
* Original version used evaluate, so I modified it to require a real var passed in. (ray@camdenfamily.com)
*
* @param variable      Variable to dump. (Required)
* @return Returns nothing, but outputs directly to screen.
* @author Doug Gibson (ray@camdenfamily.comemail@dgibson.net)
* @version 2, August 22, 2007
*/
function dumpVarList(variable) {
    
    // ASSIGN THE delim
    var delim="#Chr(13)##Chr(10)#";
    var var2dump=arguments.variable;
    var label = "";
    var newdump="";
    var keyName="";
    var loopcount=0;
    
    if(arrayLen(arguments) gte 2) delim=arguments[2];
    if(arrayLen(arguments) gte 3) label=arguments[3];
    
    // THE VARIABLE IS A SIMPLE VALUE, SO OUTPUT IT
    if(isSimpleValue(var2dump)) {
        if(label neq "") writeOutput(uCase(label) & " = " & variable & delim);
        else writeOutput(variable & delim);
    } else if(isArray(var2dump)){
        if(label neq "") writeOutput(uCase(label) & " = [Array]" & delim);
        else writeOutput("[Array]" & delim);
        for(loopcount=1; loopcount lte arrayLen(var2dump); loopCount=loopcount+1) {
             if(isSimpleValue(var2dump[loopcount])) writeOutput("[" & loopcount & "] = " & var2dump[loopcount] & delim);
            else DumpVarList(var2dump[loopcount],delim,label);
        }
    }
        // THE VARIABLE IS A STRUCT, SO LOOP OVER IT AND OUTPUT ITS KEY VALUES
    else if(isStruct(var2dump)) {
        if(label neq "") writeOutput(uCase(label) & " = [Struct]" & delim);
//        else writeOutput("[Struct]" & delim);
        for(keyName in var2dump) {
            if(isSimpleValue(var2dump[keyName])) {
                if(label neq "") writeOutput(uCase(label) & "." & uCase(keyname) & " = " & var2dump[keyName] & delim);
                else writeOutput(uCase(keyname) & " = " & var2dump[keyName] & delim);
            }
            else dumpVarList(var2dump[keyName],delim,keyname);
        }
    }
        // THE VARIABLE EXISTS, BUT IS NOT A TYPE WE WISH TO DUMP OUT
    else {
        if(label neq "") writeOutput(uCase(label) & " = [Unsupported type]" & delim);
        else writeOutput("[Unsupported type]" & delim);
    }

    return;
}
</cfscript>