 <!-- Begin Footer -->
    <div>
		<cfif isDefined("url.debug") OR settings.Var('debug_level')>
			<cfdump var="#variables#" expand="no" label="Variables">
			<cfdump var="#request#" expand="no" label="Request">
			<cfdump var="#session#" expand="no" label="Session">
			<cfdump var="#cgi#" expand="no" label="CGI">
			<cfdump var="#application#" expand="no" label="Application">
		</cfif>
       <!---<div id="corporate3design"><a href="http://www.corporate3design.com" title="Corporate 3 Design" target="_blank"></a></div>--->
	   <div>
	   <small><cfif FileExists(ExpandPath("#application.slashroot#managementcenter/VERSION.txt")) AND request.event NEQ "login" AND NOT settings.var('app.hideVersionInfo')>
	   Version <cfinclude template="#application.slashroot#managementcenter/VERSION.txt"> 
	   </cfif><br />
	   <cfif len(settings.varstr('app.schemaVersion')) AND request.event NEQ "login" AND NOT settings.var('app.hideVersionInfo')>Schema: <cfoutput>#settings.varStr('app.schemaVersion')#</cfoutput></cfif>
	   </small>
	   </div>
    </div>
    <!-- End Footer -->
	<cfif NOT ListFind('login,forgot', url.event)>
    <div id="timeoutDialog" title="Your session is about to expire!">
		<p>You will be logged off in <span id="dialog-countdown"></span> seconds.</p>
		<p>Do you want to continue your session?</p>
		<p> <br /><br />
        <button class="" style="float:left; margin:0 20px;"> Continue </button> 
        <button class=""> Logout </button> 
    	</p> 
	</div>
	</cfif>
</body>
</html>