<cfsilent>
<cfparam name="url.event" default="home">
<cfparam name="request.event" default="#url.event#">
<cfparam name="request.manage" default="false" type="boolean">
<cfset helpers = application.helpers>
<cfset buildurl = application.helpers.buildurl>
<cfset settings = application.settings>
<cfset formhelper = new cfcs.formHelper()>
<cfif url.event EQ "logout" OR url.event EQ 'logout/'>
	<cflock scope="Session" type="Exclusive" timeout="10">
		<cfset StructClear(Session)>
	</cflock>
	<cflocation addtoken="no" url="#BuildURL(event='home',manage=false)#">
</cfif>
</cfsilent>
<cfif request.manage>
	<cftry>
		<cfset event = createObject("component", "#application.dotroot#cfcs." & url.event).init(argumentcollection=url)>
		<cfcatch type="application">
			<cfset myError = cfcatch>
			<cfset event = createObject("component", "#application.dotroot#cfcs.event").init(argumentcollection=url)>
			<cfheader statuscode="404" statustext="NOT FOUND">
			<cfset request.event = "404">
		</cfcatch>
	</cftry>
	<cfif request.event EQ "login">
		<cfinclude template="#application.slashroot#managementcenter/view/login.cfm">
		<cfinclude template="#application.slashroot#managementcenter/view/layout/footer.cfm">
	<cfelseif request.event EQ 'forgot'>
		<cfinclude template="#application.slashroot#managementcenter/view/forgot.cfm">
		<cfinclude template="#application.slashroot#managementcenter/view/layout/footer.cfm">
	<cfelse>
		<!--- Check login status --->
		<cfset application.helpers.checkLogin()>
		

		<cfinclude template="#application.slashroot#managementcenter/view/layout/head.cfm">
		<cfinclude template="#application.slashroot#managementcenter/view/layout/navigation.cfm">
		<!-- Begin Content Wrapper -->
					<div id="content_wrapper">
						<!-- Begin repeating vertical line -->
						<div id="verticalline">
							<cfinclude template="#application.slashroot#managementcenter/view/layout/sidebar.cfm">
							<!-- Begin Content -->
							<div id="content">
			<cftry>								
				<cfif structKeyExists(url, "action")>
							<cfinclude template="#application.slashroot#managementcenter/view/#request.event#_#url.action#.cfm">
				<cfelse>
							<cfinclude template="#application.slashroot#managementcenter/view/#request.event#.cfm">
				</cfif>
				<cfcatch type="missinginclude">
					<cfset myError = cfcatch>
					<h3>View template not found</h3>
					<cfinclude template="#application.slashroot#managementcenter/view/404.cfm">
				</cfcatch>
				<cfcatch type="c3d.notPermitted">
					<cfset myError = cfcatch>
					<cfset logger = application.logbox.getLogger('cfcs.'& url.event)>
					<cfset logger.warn('User #session.userid# (#session.username#) triggered permission restrictions', {type=cfcatch.Type, message=cfcatch.Message, location=cfcatch.tagContext[1].raw_Trace})>
					<cfinclude template="#application.slashroot#managementcenter/view/403.cfm">
				</cfcatch>
				<cfcatch type="c3d.todo">
					<cfset myError = cfcatch>
					<cfset logger = application.logbox.getLogger('cfcs.'& url.event)>
					<cfset logger.ERROR('Feature Not Implemented', {type=cfcatch.Type, message=cfcatch.Message, location=cfcatch.tagContext[1].raw_Trace})>
					<cfrethrow>
				</cfcatch>
			</cftry>
						  </div>
							<!-- End Content -->
							<div class="clear"></div>
						</div>
						<!-- End repeating vertical line -->
					</div>
					<!-- End Content Wrapper -->
			</div>
			<!-- End Wrapper BG -->
		<cfinclude template="#application.slashroot#managementcenter/view/layout/footer.cfm">

	</cfif>
<!--- Non-management page, load the page handler --->
<cfelse>
	<cftry>
		<cfset event = createObject("component", "#application.dotroot#cfcs.pages").init()>
		<cfif NOT event.found >
			<cfthrow type="c3d.notfound">
		</cfif>
		<cfif NOT event.grantAccess >
			<cfthrow type="c3d.forbidden">
		</cfif>
		<cfsavecontent variable="completePage">
			<cfif application.settings.cacheTime AND NOT structKeyExists(url, 'debug') AND NOT structKeyExists(url, 'cachebuster') AND NOT structKeyExists(url, 'clearCache')>
				<cfcache action="servercache" usequerystring="true" timespan="#application.settings.cachetime#" stripWhiteSpace="true">
			</cfif>
            <cfif cgi.QUERY_STRING CONTAINS 'landings'>
            <cfinclude template="#application.slashroot#view/landings.cfm">
            <cfelse>
			<cfinclude template="#application.slashroot#view/skel.cfm">
            </cfif>
		</cfsavecontent>
		<cfoutput>#completePage#</cfoutput>
		
		<cfcatch type="c3d.notfound">
			<cfheader statuscode="404" statustext="NOT FOUND">
			<cfinclude template="#application.slashroot#view/404.cfm">
		</cfcatch>
		<cfcatch type="c3d.forbidden">
			<cfheader statuscode="403" statustext="FORBIDDEN">
			<cfinclude template="#application.slashroot#view/403.cfm">
		</cfcatch>
		<cfcatch type="any">
			<cfheader statuscode="500" statustext="INTERNAL SERVER ERROR">
			<cfif structKeyExists(url,'debug') OR cgi.REMOTE_ADDR EQ '72.214.233.126'>
				<cfrethrow>
			<cfelse>
				<cfset application.logbox.getRootLogger().error('An error occured on #application.name#', {location=cgi.HTTP_HOST & cgi.SCRIPT_NAME & '?' & cgi.QUERY_STRING, message=cfcatch.Message, type=cfcatch.Type, detail=cfcatch.Detail, context=cfcatch.tagContext[1], browser=cgi.HTTP_USER_AGENT, referer=cgi.HTTP_REFERER})>
			</cfif>
		</cfcatch>
	</cftry>
	
</cfif>