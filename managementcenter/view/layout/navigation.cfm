 <!-- Begin Wrapper BG -->
    <div id="wrapper_bg">
        	<!-- Begin Header -->
            <div id="header">
            	<div id="logo"><cfoutput><a href="#BuildURL(event='manage')#"></a></cfoutput></div>
                <!-- Begin Navigation -->
                <ul id="navigation" style="position:relative">
				<cfif application.settings.var('modules') CONTAINS "MultiSite">
					<li style=" float:none; position:absolute; left:-250px;"><select id="siteID" name="siteID" style="">
						<cfoutput query="application.multisite.sites">
						<option value="#id#"<cfif session.siteID EQ id> selected="selected"</cfif>>#name#</option>
						</cfoutput>
					</select>
					</li>
				</cfif>
					<!---<li><a href="index.cfm?action=sitesettings" target="_blank">Site Settings</a></li>--->
                    <li id="livesite_but"><cfoutput><a href="#application.slashroot#" target="_blank">Go To Live Site</a></cfoutput></li>
                    <li id="logout_but"><cfoutput><a href="#BuildURL(event='logout')#">Log Out</a></cfoutput></li>
                </ul>
                <!-- End Navigation -->
				<!-- End Navigation -->
				<p id="welcome">You will be automatically logged out in <span id="clock"></span></p>
      </div>
            <!-- End Header -->


			<script type="text/javascript" language="javascript">
				window.setTimeout('CountDown()',100);
			</script>
			