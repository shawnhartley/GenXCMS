<!--- Check login status --->
<cflock scope="Session" type="ReadOnly" timeout="60">
	<cfif NOT IsDefined("Session.status") OR Session.status NEQ "login">
		<cflocation URL="#application.slashroot#managementcenter/index.cfm?action=login" addtoken="No">
	</cfif>
</cflock>
<cfparam name="form.submit" default="">
<cfif url.function EQ "upload">
	<cfif form.submit Eq "upload" >
    	<cffile action="upload" filefield="f" destination="#ExpandPath(application.settings.Var('randomimage.imagepool'))#" nameconflict="makeunique">
        <cfdump var="#cffile#">
        <cflocation addtoken="no" url="#BuildURL(event=url.event, encode=false)#">
    </cfif>
<h1>Add Image</h1>
<form action="" method="post" enctype="multipart/form-data">

<input type="file" name="f" /><br />
<input type="submit" name="submit" value="Upload" />
</form>

</cfif>


<cfif url.function eq "delete">
	<cfif form.submit eq "delete">
    	<cffile action="delete" file="#ExpandPath(application.settings.var('randomimage.imagepool') & url.id)#">
        <cfdump var="#cffile#">
        <cflocation addtoken="no" url="#BuildURL(event=url.event, args='msg=1', encode=false)#">
    </cfif>
<form action="" method="post" >
<cfoutput><img src="#application.settings.var('randomimage.imagepool')##url.id#" /></cfoutput><br />
<h2>Are you sure?</h2>
<input type="submit" name="submit" value="DELETE" />

</form>

</cfif>