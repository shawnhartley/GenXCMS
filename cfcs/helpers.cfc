<cfcomponent output="no">
	<cffunction name="init" returntype="helpers">
		<cfreturn this>
	</cffunction>
	<cffunction name="BuildURL" access="public" returntype="string" output="no">
		<cfargument name="event" type="string" required="yes">
		<cfargument name="action" type="string" default="">
		<cfargument name="id" type="numeric" default="0">
		<cfargument name="args" type="string" default="">
		<cfargument name="encode" type="boolean" default="yes">
		<cfargument name="manage" type="boolean" default="#request.manage#">
		<cfset var myURL = application.slashroot>
		<cfif arguments.manage>
			<cfset myURL = application.slashroot & "managementcenter/">
		</cfif>
		
		<cfif application.settings.prettyURLs>
			<cfset myURL = myURL & arguments.event & "/">
			<cfif len(arguments.action)>
				<cfset myURL = myURL & arguments.action & "/">
				<cfif arguments.id>
					<cfset myURL = myURL & arguments.id & "/">
					
				</cfif>
			</cfif>
			<cfif len(arguments.args)>
				<cfset myURL = myURL & "?" & arguments.args> 
			</cfif>
		<cfelse>
			<cfset myURL = myURL & "index.cfm?event=" & arguments.event>
			<cfif len(arguments.action)>
				<cfset myURL = myURL & "&action=" & arguments.action>
				<cfif arguments.id>
					<cfset myURL = myURL & "&id=" & arguments.id>
				</cfif>
			</cfif>
			<cfif len(arguments.args)>
				<cfset myURL = myURL & "&" & arguments.args> 
			</cfif>
		</cfif>
		<cfset myURL = Replace(myURL, "//", "/", "ALL")>
		<cfif arguments.encode>
			<cfreturn HTMLEditFormat(myURL)>
		<cfelse>
			<cfreturn myURL>
		</cfif>
	</cffunction>
	
	<cffunction name="buildRedirect" access="private" returntype="string" output="no">
		<cfset var coll = structNew()>
		<cfset var arglist = ''>
		<cfset coll.encode = false>
		<cfset coll.event = 'manage'><!--- default --->
		<cfloop collection="#arguments#" item="item">
			<cfswitch expression="#item#">
				<cfcase value="event">
					<cfset coll.event = arguments.event>
				</cfcase>
				<cfcase value="action">
					<cfset coll.action = arguments.action>
				</cfcase>
				<cfcase value="id">
					<cfset coll.id = arguments.id>
				</cfcase>
				<cfcase value="reload">
					<!--- ignore --->
				</cfcase>
				<cfdefaultcase>
					<cfset arglist = arglist & ',' & item & '=' & arguments[item]>
				</cfdefaultcase>
			</cfswitch>
			
		</cfloop>
		
		<cfset coll.args = ListChangeDelims(arglist, "&")>
		<cfreturn URLEncodedFormat(BuildURL(argumentcollection=coll))>
	</cffunction>
	
	<cffunction name="userIsLoggedIn" access="public" output="no" returntype="boolean">
		<cfreturn StructKeyExists(session, "status") AND Session.status EQ "login">
	</cffunction>
	
	<cffunction name="handleLoginAttempt" access="public" output="no">
		<cfargument name="username" required="yes" type="string">
		<cfargument name="password" required="yes" type="string">
		<cfargument name="redirect" default="" type="string">
		<cfset var validpwd = false>
		<cfset var getPermissions = ''>
		<cfset var salt = ''>
		<cfset var logger = application.logbox.getLogger('cfcs.logins.loginAttempt')>
		<cfset arguments.username = LCase(arguments.username)>
		<cfquery name="getSalt" datasource="#application.dsn#">
			SELECT salt FROM logins
				WHERE username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.username#">
		</cfquery>
		<cfif getSalt.recordCount NEQ 1>
			<cfreturn false>
		</cfif>
		<cfset salt = getSalt.salt>
		<cfquery name="getpermissions" datasource="#application.dsn#">
		SELECT
		*
		FROM
		logins 
			INNER JOIN logins2usergroups 
				ON logins.id = logins2usergroups.loginId
			INNER JOIN usergroups
				ON logins2usergroups.group_ID = usergroups.group_ID
		WHERE username = <cfqueryparam cfsqltype="cf_sql_varchar" value='#arguments.username#'>
			AND password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#computeHash(arguments.password, salt)#">
			AND ( temporary = 0 OR temporary > <cfqueryparam cfsqltype="cf_sql_integer" value="#ROUND(NOW())#">)
		</cfquery>
		<cfif getpermissions.recordcount NEQ 1>
			<cfset logger.warn('FAILED login attempt: #arguments.username# / #arguments.password#')>
			<cfreturn false>		<!--- Reject invalid authentication attempt --->
		</cfif>
		<!--- Login was successful. Log it, set up the session, and redirect if necessary --->
		<cfset logger.info('Successful login attempt: #getpermissions.displayName# - #arguments.username# (#getpermissions.id#)', {redirect=arguments.redirect,ipAddress=cgi.REMOTE_HOST, browser=cgi.HTTP_USER_AGENT})>
		<cflock scope="Session" Type="Exclusive" timeout="30">
				<cfset Session.User 		= getpermissions.username>
				<cfset Session.UserID 		= getpermissions.id>
				<cfset Session.UserName 	= getpermissions.displayName>
				<cfset Session.email 		= getpermissions.username>
				<cfset Session.UserLevel 	= getpermissions.groupName>
				<cfset session.usergroupid 	= getpermissions.group_id>
				<cfset Session.UserPermissions = 0>
				<cfset Session.permissions	= getEffectivePermissions(userid=session.userid, usergroupid=session.usergroupid)>
				<cfset Session.manager 		= getpermissions.manager>
				<cfset Session.status 		= "login">
				<cfif getpermissions.temporary GT 0>
					<cfset session.temporary = true>
				</cfif>
			</cflock>
	
			<!--- Write filemanager cookie for managers --->
			<cfif session.manager>
				<cfcookie name="ufmanid" value="#hash(session.URLToken)#"><!--- session length cookie --->
			</cfif>
			
			
			<cfif len(arguments.redirect)>
				<cflocation URL="#arguments.redirect#" addtoken="No">
			<cfelseif request.manage>
				<cflocation addtoken="no" url="#BuildURL(event='manage')#">
			<cfelse>
				<cflocation addtoken="no" url="/">
			</cfif>
		
		
		<cfreturn validPwd>
	</cffunction>
	
	<cffunction name="getEffectivePermissions" output="no" returntype="query">
		<cfargument name="userid" required="yes" type="numeric">
		<cfargument name="usergroupid" required="yes" type="numeric">
		<cfquery name="permissions" datasource="#application.dsn#" cachedwithin="#CreateTimespan(0,0,0,0)#"><!--- Not cached --->
		<cfif APPLICATION.dsType EQ 'mysql'>
		SELECT CONCAT(capabilities.component, ".", capabilities.name) AS capability
			FROM capabilities
				JOIN capabilities2logins
					ON capabilities2logins.capabilityId = capabilities.id
						AND capabilities2logins.loginId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
		UNION 

		SELECT CONCAT(capabilities.component, ".", capabilities.name) AS capability
			FROM capabilities
				JOIN capabilities2usergroups
					ON capabilities2usergroups.capabilityId = capabilities.id
						AND capabilities2usergroups.group_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.usergroupid#">
		<cfelse> <!--- MS SQL --->
		SELECT capabilities.component + '.' + capabilities.name AS capability
			FROM capabilities
				JOIN capabilities2logins
					ON capabilities2logins.capabilityId = capabilities.id
						AND capabilities2logins.loginId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
		UNION 

		SELECT capabilities.component + '.' + capabilities.name AS capability
			FROM capabilities
				JOIN capabilities2usergroups
					ON capabilities2usergroups.capabilityId = capabilities.id
						AND capabilities2usergroups.group_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.usergroupid#">
		</cfif>
		</cfquery>
		<cfreturn permissions>
	</cffunction>
	
	<cffunction name="isValidNewUsername" output="no" access="public" returntype="boolean">
		<cfargument name="username" required="yes" type="string">
		<cfset var myData = { username = arguments.username }>
		<cfset qLogins = application.DataMgr.getRecords("logins", myData)>
		<cfreturn NOT qlogins.recordCount>
	</cffunction>
	
	<cffunction name="isValidChangedUsername" output="no" access="public" returntype="boolean">
		<cfargument name="username" required="yes" type="string">
		<cfargument name="userid" required="yes" type="numeric" default="#session.userid#">
		<cfquery name="qlogins" datasource="#application.dsn#">
			SELECT Count(*) as number FROM logins
				WHERE username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.username#">
					AND id <> <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
		</cfquery>
		<cfreturn qlogins.number EQ 0>
	</cffunction>


	
<cfscript>
public void function checkLogin() {
	if(NOT userIsLoggedIn()) {
		location(BuildURL(event='login',args='redirect=#buildRedirect(argumentcollection=url)#', encode=false), false);
	}
	if(request.manage AND structKeyExists(session, 'manager') AND NOT session.manager) {
		location(BuildURL(event='home',manage=false));
	}
	if(structKeyExists(session, 'temporary') AND url.event NEQ 'password') {
		location(BuildURL(event='password', args='temporary', encode=false), false);
	}
}


/*
<!--- ============================================== --->
<!--- CRYPTO FUNCTIONS								 --->
<!--- via https://github.com/virtix/cfcrypto		 --->
<!--- ============================================== --->
*/
public string function computeHash(required string password, required string salt, numeric iterations = 1024, string algorithm = 'SHA-512') {
    var hashed = '';
    var i = 1;
    hashed = hash( password & salt, arguments.algorithm, 'UTF-8' );
    for (i = 1; i <= iterations; i++) {
      hashed = hash( hashed & salt , arguments.algorithm, 'UTF-8' );
    }
    return hashed;
}

public string function computeJavaHash(required string password, required string salt, numeric iterations = 1024, string algorithm = 'SHA512') {
    var digest = '';
    var i = 1;
    var input = '';
    digest = createObject("java", "java.security.MessageDigest");
    digest  = digest.getInstance(arguments.algorithm);
    digest.reset();
    digest.update(salt.getBytes());
    input = digest.digest(password.getBytes("UTF-8"));
    for (i = 1; i <= iterations; i++) {
      digest.reset();
      input = digest.digest(input);
    }
    return toBase64(input);
}


public function genSalt(numeric size = 16, string type = 'base64') {
	// size: How many bytes should be used to generate the salt
	// type: Should be either binary or base64
	switch(arguments.type){
       case 'binary':
        return genBinarySalt(size);
       break;
       case 'bin':
        return genBinarySalt(size);
       break;
       default :
         return genBase64Salt(size);
       break;
     }
}

private string function genBase64Salt(required numeric size) {
	     return toBase64( genBinarySalt(size) );
}

/* <!---
Thanks to Christian Cantrell!!
http://weblogs.macromedia.com/cantrell/archives/2004/01/byte_arrays_and_1.html
--->
*/
private binary function genBinarySalt(required numeric size) {
	 var byteType = createObject('java', 'java.lang.Byte').TYPE;
     var bytes = createObject('java','java.lang.reflect.Array').newInstance( byteType , size);
     var rand = createObject('java', 'java.security.SecureRandom').nextBytes(bytes);
     return bytes;
}

// <!--- END CRYPTO FUNCTIONS --->
public string function approvedToggle(required boolean currentState, required numeric id) {
	if(currentState) {
		return '<a href="' & BuildURL(event=url.event, action='approved', id=arguments.id, args='function=deactivate') & '"><img src="' &
				application.slashroot & 'managementcenter/images/main/active.gif"></a>';
	}
		return '<a href="' & BuildURL(event=url.event, action='approved', id=arguments.id, args='function=activate')   & '"><img src="' &
				application.slashroot & 'managementcenter/images/main/inactive.gif"></a>';
}

public string function activateToggle(required boolean currentState, required numeric id) {
	if(currentState) {
		return '<a href="' & BuildURL(event=url.event, action='activate', id=arguments.id, args='function=deactivate') & '"><img src="' &
				application.slashroot & 'managementcenter/images/main/active.gif"></a>';
	}
		return '<a href="' & BuildURL(event=url.event, action='activate', id=arguments.id, args='function=activate')   & '"><img src="' &
				application.slashroot & 'managementcenter/images/main/inactive.gif"></a>';
}

public string function isDraftToggle(required boolean currentState, required numeric id) {
	if(currentState) {
		return '<a href="' & BuildURL(event=url.event, action='isDraft', id=arguments.id, args='function=activate')   & '"><img src="' &
				application.slashroot & 'managementcenter/images/main/inactive.gif"></a>';
	}
		return '<a href="' & BuildURL(event=url.event, action='isDraft', id=arguments.id, args='function=deactivate') & '"><img src="' &
				application.slashroot & 'managementcenter/images/main/active.gif"></a>';
}

public string function showNavToggle(required boolean currentState, required numeric id) {
	if(currentState) {
		return '<a href="' & BuildURL(event=url.event, action='showNav', id=arguments.id, args='function=deactivate') & '"><img src="' &
				application.slashroot & 'managementcenter/images/main/active.gif"></a>';
	}
		return '<a href="' & BuildURL(event=url.event, action='showNav', id=arguments.id, args='function=activate')   & '"><img src="' &
				application.slashroot & 'managementcenter/images/main/inactive.gif"></a>';
}

public string function activeIndicator(required boolean currentState) {
	if(arguments.currentState) {
		return '<img src="#application.slashroot#managementcenter/images/main/check.png" width="16" height="15">';
	}
		return '<img src="#application.slashroot#managementcenter/images/main/x.png" width="16" height="15">';
	
}
public string function publishIndicator(required publishDate) {
	if( arguments.publishDate EQ "" ) {
		return '<img src="#application.slashroot#managementcenter/images/main/approved_icon.gif" title="Always">';
	}
	if( isDate(arguments.publishDate) ) {
		switch(DateCompare(NOW(), arguments.publishDate)) {
			case -1: // <!--- now() is earlier than publishDate --->
				return DateFormat(arguments.publishDate, 'mm/dd/yy');
				break;
			default:
				return '<small style="color:##090;">#DateFormat(publishDate, "mm/dd/yy")#</small>';
		}
		// <!--- <img src="#application.slashroot#managementcenter/images/main/approved_icon.gif" title="#DateFormat(publishDate, "mm/dd/yy")#"><br /> --->
	}
	return '';
}


public string function expireIndicator(required endDate) {
	if( arguments.endDate EQ "" ) {
		return '<small>Never</small>';
	}
	if( isDate(arguments.endDate) ) {
		switch(DateCompare(NOW(),arguments.endDate)) {
			case 1:		// <!--- NOW() is later than endDate, we are expired --->
				return '<img src="#application.slashroot#managementcenter/images/main/needsapproval_icon.gif" title="#DateFormat(arguments.endDate, "mm/dd/yy")#">';
				break;
			default:
				return DateFormat(arguments.endDate, 'mm/dd/yy');
		}
	}
	return '';
}

public string function cssfiles() {
	var files = Replace(Replace(application.settings.var("app.cssfiles"), chr(13) & chr(10), "", "ALL"), " ", "", "ALL");
	var i = 0;
	var retstr = '';
	if(ListFindNoCase(application.settings.var('modules'), "Combine") ) {
			return '<link type="text/css" rel="stylesheet" href="/cfcs/combine.cfm?type=css&amp;files=#files#" />';
	} else {
		files = listToArray(files);
		for(i = 1; i LTE ArrayLen(files); i++) {
			retstr = retstr & '<link type="text/css" rel="stylesheet" href="' & files[i] & '" />' & chr(13) & chr(10);
		}
		return retstr;
	}
	return '';
}

public string function jsfiles() {
	var files = Replace(Replace(application.settings.var("app.jsfiles"), chr(13) & chr(10), "", "ALL"), " ", "", "ALL");
	var i = 0;
	var retstr = '';
	if(ListFindNoCase(application.settings.var('modules'), "Combine") ) {
			return "<script type='text/javascript' src='/cfcs/combine.cfm?type=js&amp;files=#files#'></script>";
	} else {
		files = listToArray(files);
		for(i = 1; i LTE ArrayLen(files); i++) {
			retstr = retstr & '<script type="text/javascript" src="#files[i]#"></script>' & chr(13) & chr(10);
		}
		return retstr;
	}
	return '';
}

public string function googleAnalytics() {
	var ID = application.settings.varStr('app.googleAnalyticsID');
	if(len(ID)) {
		return "<script>
				  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
				  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
				  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
				  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

				  ga('create', '#ID#', 'auto');
				  ga('send', 'pageview');
				  ga('create', 'UA-36993212-18', 'auto', {'name': 'C3DTracker'});
				  ga('C3DTracker.send', 'pageview');

				</script>";
	}
	return '';
}

public string function tracking_code() {
	var code = application.settings.varStr('app.tracking_code');
	if(len(code)) {
		return '<script type="text/javascript">
	// <![CDATA[
	#code#
	// ]]>
	</script>';
	}
	return '';
}

/**
* Convert the query into a CSV format using Java StringBuffer Class.
*
* @param query      The query to convert. (Required)
* @param headers      A list of headers to use for the first row of the CSV string. Defaults to all the columns. (Optional)
* @param cols      The columns from the query to transform. Defaults to all the columns. (Optional)
* @return Returns a string.
* @author Qasim Rasheed (qasimrasheed@hotmail.com)
* @version 1, March 23, 2005
*/
function QueryToCSV2(query){
	var csv = createobject( 'java', 'java.lang.StringBuffer');
	var i = 1;
	var j = 1;
	var cols = "";
	var headers = "";
	var endOfLine = chr(13) & chr(10);
	if (arraylen(arguments) gte 2) headers = arguments[2];
	if (arraylen(arguments) gte 3) cols = arguments[3];
	if (not len( trim( cols ) ) ) cols = query.columnlist;
	if (not len( trim( headers ) ) ) headers = cols;
	headers = listtoarray( headers );
	cols = listtoarray( cols );
	
	for (i = 1; i lte arraylen( headers ); i = i + 1)
		csv.append( '"' & headers[i] & '",' );
	csv.append( endOfLine );
	
	for (i = 1; i lte query.recordcount; i= i + 1){
		for (j = 1; j lte arraylen( cols ); j=j + 1){
			if (isNumeric( query[cols[j]][i] ) )
				csv.append( query[cols[j]][i] );
			else
				csv.append( '"' & Replace(query[cols[j]][i], '"', '""', 'ALL') & '"' );
			
			if (j lt arraylen( cols) )
				csv.append(",");
			
		}
		csv.append( endOfLine );
	}
	return csv.toString();
}
/**
* Converts a query to excel-ready format.
* Version 2 by Andrew Tyrone. It now returns a string instead of directly outputting.
*
* @param query      The query to use. (Required)
* @param headers      A list of headers. Defaults to col. (Optional)
* @param cols      The columns of the query. Defaults to all columns. (Optional)
* @param alternateColor      The color to use for every other row. Defaults to white. (Optional)
* @return Returns a string.
* @author Jesse Monson (jesse@ixstudios.com)
* @version 2, February 23, 2005
*/
function Query2Excel(query) {
    var InputColumnList = query.columnList;
    var Headers = query.columnList;

    var AlternateColor = "FFFFFF";
    var header = "";
    var headerLen = 0;
    var col = "";
    var colValue = "";
    var colLen = 0;
    var i = 1;
    var j = 1;
    var k = 1;
    
    var HTMLData = "";
    
    if (arrayLen(arguments) gte 2) {
        Headers = arguments[2];
    }
    if (arrayLen(arguments) gte 3) {
        InputColumnList = arguments[3];
    }

    if (arrayLen(arguments) gte 4) {
        AlternateColor = arguments[4];
    }
    if (listLen(InputColumnList) neq listLen(Headers)) {
        return "Input Column list and Header list are not of equal length";
    }
    
    HTMLData = HTMLData & "<table border=1><tr bgcolor=""C0C0C0"">";
    for (i=1;i lte ListLen(Headers);i=i+1){
        header=listGetAt(Headers,i);
        headerLen=Len(header)*10;
        HTMLData = HTMLData & "<th width=""#headerLen#""><b>#header#</b></th>";
    }
    HTMLData = HTMLData & "</tr>";
    for (j=1;j lte query.recordcount;j=j+1){
        if (j mod 2) {
            HTMLData = HTMLData & "<tr bgcolor=""FFFFFF"">";
        } else {
            HTMLData = HTMLData & "<tr bgcolor=""#alternatecolor#"">";
        }
        for (k=1;k lte ListLen(InputColumnList);k=k+1) {
            col=ListGetAt(InputColumnList,k);
            colValue=query[trim(col)][j];
            colLength=Len(colValue)*10;
            if (NOT Len(colValue)) {
                colValue="&nbsp;";
            }
            if (isNumeric(colValue) and Len(colValue) gt 10) {
                colValue="'#colValue#";
            }
            HTMLData = HTMLData & "<td width=""#colLength#"">#colValue#</td>";
        }
    HTMLData = HTMLData & "</tr>";
    }
    HTMLData = HTMLData & "</table>";
    
    return HTMLData;
}
</cfscript>

</cfcomponent>