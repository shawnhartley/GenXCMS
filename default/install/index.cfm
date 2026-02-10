<!---
$Rev:: 1094          $:  Revision of last commit
$Author:: shawn     $:  Author of last commit
$Date:: 2016-08-31 #$:  Date of last commit
--->

<cfapplication name="test" sessionManagement="true">
<cfparam name="session.step" default="1">
<cfparam name="message" default="">
<cffunction name="keepSingleQuotes" returntype="string" output="false">
	<cfargument name="str">
	<cfreturn preserveSingleQuotes(arguments.str)>
</cffunction>

<!---
Copies a directory.

@param source      Source directory. (Required)
@param destination      Destination directory. (Required)
@param nameConflict      What to do when a conflict occurs (skip, overwrite, makeunique). Defaults to overwrite. (Optional)
@return Returns nothing.
@author Joe Rinehart (joe.rinehart@gmail.com)
@version 2, February 4, 2010
--->
<cffunction name="directoryCopying" output="true">
	<cfargument name="source" required="true" type="string">
	<cfargument name="destination" required="true" type="string">
	<cfargument name="nameconflict" required="true" default="overwrite">
	<cfset var contents = "" />
	<cfif not(directoryExists(arguments.destination))>
		<cfdirectory action="create" directory="#arguments.destination#" mode="777">
	</cfif>
	<cfdirectory action="list" directory="#arguments.source#" name="contents">
	<cfloop query="contents">
		<cfif contents.type eq "file">
			<cffile action="copy" source="#arguments.source#/#name#" destination="#arguments.destination#/#name#" nameconflict="#arguments.nameConflict#" mode="666">
			<cfelseif contents.type eq "dir">
			<cfset directoryCopying(arguments.source & dirDelim & name, arguments.destination & dirDelim & name) />
		</cfif>
	</cfloop>
</cffunction>
<cfset iniFile = expandPath("../config.ini.cfm")>
<cfif structKeyExists(url, 'startOver')>
	<cflock scope="session" type="exclusive" timeout="20">
		<cfset session.step = 1>
		<cfset structClear(form)>
	</cflock>
</cfif>
<cfif structKeyExists(form, 'skipStep')>
	<cflock scope="session" type="exclusive" timeout="20">
		<cfset session.step = session.step + 1>
		<cfset structClear(form)>
	</cflock>
</cfif>
<cfif StructKeyExists(form, 'copyFiles')>
	<cftry>
		<cftry>
		<cfif structKeyExists(form, 'usehtaccess')>
			<cffile action="copy" source="#ExpandPath('../.htaccess.orig')#" destination="#ExpandPath('../../.htaccess')#" nameconflict="overwrite" mode="666">
		</cfif>
		<cfcatch></cfcatch>
		</cftry>
		<cftry>
			<cffile action="move" source="#ExpandPath('../../web.config')#" destination="#ExpandPath('../../web.config.bak')#" nameconflict="makeunique" mode="666">
			<cfcatch></cfcatch>
		</cftry>
		<cffile action="copy" source="#ExpandPath('../web.config.orig')#" destination="#ExpandPath('../../web.config')#" nameconflict="overwrite" mode="666">
		<cffile action="copy" source="#ExpandPath('../index.cfm')#" destination="#ExpandPath('../../index.cfm')#" nameconflict="overwrite" mode="666">
		<cffile action="copy" source="#ExpandPath('../robots.txt')#" destination="#ExpandPath('../../robots.txt')#" nameconflict="overwrite" mode="666">
		<cffile action="copy" source="#ExpandPath('../README.md')#" destination="#ExpandPath('../../README.md')#" nameconflict="overwrite" mode="666">
		<cffile action="copy" source="#ExpandPath('../README.txt')#" destination="#ExpandPath('../../README.txt')#" nameconflict="overwrite" mode="666">
		<cffile action="copy" source="#ExpandPath('../config.codekit')#" destination="#ExpandPath('../../config.codekit')#" nameconflict="overwrite" mode="666">


		<!---<cfset directoryCopying(source=ExpandPath('../css'), destination=ExpandPath('../../css'))>
		<cfset directoryCopying(source=ExpandPath('../view'), destination=ExpandPath('../../view'))>
--->

		<cfdirectory action="create" directory="#ExpandPath('../../_cfcache')#" mode="666">
		<cflock scope="session" type="exclusive" timeout="20">
			<cfset session.step = session.step + 1>
			<cfset structClear(form)>
		</cflock>
		<cfcatch>
			<cfset message = "Files Could not be copied.">
			<cfset myErr = cfcatch>
		</cfcatch>
	</cftry>
</cfif>
<cfif StructKeyExists(form, 'updateINI')>
	<cfif StructKeyExists(form, "cfidepassword") AND len(form.cfidepassword)>
		<cftry>
		<cfif server.ColdFusion.ProductName CONTAINS "Railo">
		<cfinclude template="railo-dsn.cfm">

		<cfelse>
		<cfscript>

		//Check for proper admin password, Boolean returned
		adminobj = createObject("component", "CFIDE.adminapi.administrator").login(form.cfidepassword);
		if(NOT adminobj) //Unsuccessful login
		{
			WriteOutput("<h2>You did not login correctly, please recheck the password</h2>");
		}
		else //Successful login
		{


    // Instantiate the data source object.
    	myObj = createObject("component","cfide.adminapi.datasource");

    // Create a DSN. this example is for mysql all empty parameters are required.
   		myObj.setMySQL5(driver="MySQL5",
        name=form.dsn,
        host = form.dbhost,
        port = form.dbport,
        database = form.dbname,
        username = form.dbuser,
        password = form.dbpassword,
        login_timeout = "29",
        timeout = "23",
        interval = 6,
        buffer = "64000",
        blob_buffer = "64000",
        setStringParameterAsUnicode = "false",
        description = "",
        pooling = true,
        maxpooledstatements = 999,
        enableMaxConnections = "true",
        maxConnections = "299",
        enable_clob = true,
        enable_blob = true,
        disable = false,
        storedProc = true,
        alter = true,
        grant = true,
        select = true,
        update = true,
        create = true,
        delete = true,
        drop = false,
        revoke = false,
		args = 'allowMultiQueries=true');

			//Create custom tag paths
			//obj = createObject("component","cfide.adminapi.extensions");
			//obj.setCustomTagPath("path/to/customtag");

		}
	</cfscript>
		</cfif>
		<cfcatch>
		<cfset message = 'Datasource could not be created.'>
		<cfset myErr = cfcatch>
		</cfcatch>
		</cftry>
	</cfif>


	<cftry>
		<cfscript>
		setProfileString(inifile, 'default', 'dsn', form.dsn);
		setProfileString(inifile, 'default', 'slashroot', form.slashroot);
		setProfileString(inifile, 'default', 'dotroot', form.dotroot);

		</cfscript>

		<cffile action="copy" source="#ExpandPath('../config.ini.cfm')#" destination="#ExpandPath('../../config.ini.cfm')#" mode="666">
		<cffile action="copy" source="#ExpandPath('../Application.orig.cfc')#" destination="#ExpandPath('../../Application.cfc')#" nameconflict="overwrite" mode="666">
		<cflock scope="session" type="exclusive" timeout="20">
			<cfset session.step = session.step + 1>
			<cfset structClear(form)>
		</cflock>
			<cfcatch>
			<cfset message='Config file could not be saved.'>
			<cfset myErr = cfcatch>
		</cfcatch>
	</cftry>
</cfif>

<cfif structKeyExists(form, 'reload')>
	<cflock scope="session" type="exclusive" timeout="20">
		<cfset session.step = session.step + 1>
		<cfset structClear(form)>
	</cflock>
</cfif>

<cfif StructKeyExists(form, "updateSettings")>

	<cfset settings = createObject("component", "cfcs.settings").init()>

	<cfif structKeyExists(form, 'updateSettings')>
	<cftry>
		<cfset settings.updatesitesettings(argumentcollection=form)>
		<cflock scope="session" type="exclusive" timeout="20">
			<cfset session.step = session.step + 1>
			<cfset structClear(form)>
		</cflock>
	<cfcatch>
		<cfset message = 'Settings could not be saved'>
		<cfset myErr = cfcatch>
	</cfcatch>
	</cftry>

	</cfif>
</cfif>
<cfif structKeyExists(form, "deleteInstaller")>
	<cftry>
		<cfdirectory action="delete" directory="#ExpandPath('../../default')#" recurse="yes">
		<cflock scope="session" type="exclusive" timeout="20">
			<cfset session.step = session.step + 1>
			<cfset structClear(form)>
		</cflock>
	<cfcatch>
		<cfset message = 'Files could not be deleted.'>
		<cfset myErr = cfcatch>
	</cfcatch>
	</cftry>

</cfif>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>GenX Installer</title>
<link href="../../managementcenter/css/mainstyle.css" rel="stylesheet" />
</head>
<body>
<!-- Begin Wrapper BG -->
<div id="wrapper_bg">
	<!-- Begin Header -->
	<div id="header">
		<div id="logo"><a href="index.cfm?event=manage"></a></div>
		<!-- Begin Navigation -->
		<ul id="navigation" style="position:relative">
		</ul>
		<!-- End Navigation -->
	</div>
	<!-- End Header -->
	<!-- Begin Content Wrapper -->
	<div id="content_wrapper">
		<!-- Begin repeating vertical line -->
		<div id="verticalline">
			<ul id="sidebar">
				<li class="active"><a href="#">Step <cfoutput>#session.step#</cfoutput> of 5</a></li>
				<li><a href="index.cfm?startover">Start Over</a></li>
			</ul>
			<!-- Begin Content -->
			<div id="content">
				<h1>Install GenX</h1>
				<cfif len(message)>
					<p class="error"><cfoutput>#message#</cfoutput> </p>
					<cfdump var="#myErr#">
				</cfif>
				<form action="index.cfm" method="post">
					<cfswitch expression="#session.step#">
						<cfcase value="2">
						<h2>Copy Files</h2>
						<p>Ensure the web server has write permissions to the site directory.</p>
						<p class="error">This will OVERWRITE any changes you may have made.</p>
						<p><input type="checkbox" checked="checked" name="usehtaccess" value="1" /> Copy .htaccess file (causes problems on some windows hosts)</p>
						<button type="submit" name="copyFiles" value="true">Copy Default Files</button>
						<br />
						<button type="submit" name="skipStep" value="true">Skip this Step</button>
						</cfcase>


						<cfcase value="1">
						<cfoutput>
							<h2>Set up Datasource and Paths</h2>
							<fieldset><legend>Create Datasource (optional)</legend>
							<p>
								<label for="site">Coldfusion Admin Password - Make Sure you know which server you are on.</label>
								<br />
								<input type="password" name="cfidePassword"  />
							</p>
							<p>
								<label for="site">DB Type</label>
								<br />
								<select name="dbtype">
									<option>MySql</option>
								</select>
							</p>
							<p>
								<label for="site">Host (usually: localhost)</label>
								<br />
								<input type="text" name="dbhost" />
							</p>
							<p>
								<label for="site">Port (usually: 3306)</label>
								<br />
								<input type="text" name="dbport" />
							</p>
							<p>
								<label for="site">DB User</label>
								<br />
								<input type="text" name="dbuser" />
							</p>
							<p>
								<label for="site">DB Password</label>
								<br />
								<input type="text" name="dbpassword" />
							</p>
							<p>
								<label for="site">Database Name</label>
								<br />
								<input type="text" name="dbname" />
							</p>
							</fieldset>
							<p>
								<label for="site">Datasource Name</label>
								<br />
								<input type="text" name="dsn" value="#getProfileString(iniFile, "default", "dsn")#" placeholder="Enter The Datasource Name" />
							</p>
							<p>
								<label for="site">Webroot</label>
								(leading and trailing slash)<br />
								<input type="text" name="slashroot" value="#getProfileString(iniFile, "default", "slashroot")#" placeholder="Slash Root" />
							</p>
							<p>
								<label for="site">Component Webroot</label>
								(dot delimited)<br />
								<input type="text" name="dotroot" value="#getProfileString(iniFile, "default", "dotroot")#" placeholder="Dot Root" />
							</p>
						</cfoutput>
						<button type="submit" name="updateINI" value="true">Save Settings</button>
						</cfcase>

						<cfcase value="3">

						<button type="submit" name="reload" value="1">Set up Support Objects</button>
						</cfcase>


						<cfcase value="4">
						<h2>Finished!</h2>
						<p class="error">
							Please delete this install folder for security.</p>
						</p>
						<p><button type="submit" name="deleteInstaller">Delete Files</button><br />
						<button type="submit" name="skipStep" value="true">Skip This Step</button></p>

						</cfcase>

						<cfcase value="5">
						<h2>Finished!</h2>
						<p class="error">Files were successfully deleted.</p>
						<p>
						<a href="../../managementcenter/?reload=1">Manage Your Site</a>
						</p>

						</cfcase>

					</cfswitch>
				</form>
			</div>
			<!-- End Content -->
			<div class="clear"></div>
		</div>
		<!-- End repeating vertical line -->
	</div>
	<!-- End Content Wrapper -->
</div>
<!-- End Wrapper BG -->
<!-- Begin Footer -->
<div id="footer">
	<div id="corporate3design"><a href="http://www.corporate3design.com" title="Corporate 3 Design" target="_blank"></a></div>
</div>
<!-- End Footer -->
<cfif isDefined("url.debug")>
	<cfdump var="#application#">
	<cfdump var="#session#">
	<cfdump var="#variables#">
	<cfdump var="#cgi#">
</cfif>
</body>
</html>