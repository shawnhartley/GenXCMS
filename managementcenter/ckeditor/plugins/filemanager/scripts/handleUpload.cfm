<cfparam name="request.manage" default="true">
<cfset application.helpers.checkLogin()>
<cffile  action="upload" 
         destination="#expandPath(/uploads)" 
         nameconflict="overwrite"
         filefield="theFile" />
