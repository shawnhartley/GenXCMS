<cfcomponent extends="Event" output="no">
	<cffunction name="dotct" access="public" returntype="boolean">
		<cfargument name="slug" type="string" default="">
		<cfif NOT len(slug)>
			<cfreturn false>
		</cfif>
			<cfquery datasource="#application.dsn#" name="qtct">
				SELECT id, url FROM tct WHERE slug = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.slug#">
								AND active = 1
							<cfif application.settings.var('modules') CONTAINS "multisite">
								AND siteID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.siteID#">
							</cfif>
			</cfquery>
			<cfif qtct.recordcount EQ 1>
				<cfquery datasource="#application.dsn#" name="updateVisits">
					UPDATE tct SET 
							visits = visits + 1
							,lastVisitAt = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#NOW()#">
						WHERE slug = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.slug#">
				</cfquery>
				<cftry>
					<cfset clientInfo = getClientInfo()>
					<cfset application.DataMgr.insertRecord( 'tct_history',
															{   tct_id = qtct.id,
																slug = arguments.slug,
																url = qtct.url,
																browserString = clientInfo.browserString,
																browserParsed = clientInfo.browserParsed,
																ipaddress = clientinfo.ipaddress,
																referrer = clientInfo.referrer,
																cftoken = clientInfo.cftoken,
																stamp = '#now()#'
																
																})>
					<cfcatch>
						<cfdump var="#cfcatch#" abort="yes">
					</cfcatch>
				</cftry>
				<cflocation addtoken="no" url="#qtct.url#">
				<cfreturn true>
			</cfif>
		<cfreturn false>
	</cffunction>
	
	<cffunction name="getClientInfo" access="private" returntype="struct">
		<cfset var info = StructNew()>
		
		<cfset info.browserString 	= cgi.HTTP_USER_AGENT>
		<cfset info.browserParsed	= browserDetect(info.browserString)>
		<cfset info.ipaddress 		= cgi.REMOTE_ADDR>
		<cfset info.referrer		= cgi.HTTP_REFERER>
		<cfset info.cftoken			= session.URLtoken>
		<cfreturn info>
	</cffunction>
	
	<cffunction name="browserDetect" access="private" returntype="string">
		<cfargument name="UserAgent" default="#cgi.HTTP_USER_AGENT#" type="string">
		
		<cfscript>
			/**
			* Detects 130+ browsers.
			* v2 by Daniel Harvey, adds Flock/Chrome and Safari fix.
			*
			* @param UserAgent      User agent string to parse. Defaults to cgi.http_user_agent. (Optional)
			* @return Returns a string.
			* @author John Bartlett (jbartlett@strangejourney.net)
			* @version 4, June 28, 2009
			
			
			* Modified May 10, 2010 Lane Roberts
			* Integrated with GenX
			
			*/
			
			
			
			// Regex to parse out version numbers
			var VerNo="/?v?_? ?v?[\(?]?([A-Z0-9]*\.){0,9}[A-Z0-9\-.]*(?=[^A-Z0-9])";
			
			// List of browser names
			var BrowserList="";
			
			// Identified browser info
			var BrowserName="";
			var BrowserVer="";
			
			// Working variables
			var Browser="";
			var tmp="";
			var tmp2="";
			var x=0;
			
			
			// If a value was passed to the function, use it as the User Agent
			if (ArrayLen(Arguments) EQ 1) UserAgent=Arguments[1];
			
			// Allow regex to match on EOL and instring
			UserAgent=UserAgent & " ";
			
			// Browser List (Allows regex - see BlackBerry for example)
			BrowserList="1X|Amaya|Ubuntu APT-HTTP|AmigaVoyager|Android|Arachne|Amiga-AWeb|Arora|Bison|Bluefish|Browsex|Camino|Check&Get|Chimera|Chrome|Contiki|cURL|Democracy|" &
						"Dillo|DocZilla|edbrowse|ELinks|Emacs-W3|Epiphany|Galeon|Minefield|Firebird|Phoenix|Flock|IceApe|IceWeasel|IceCat|Gnuzilla|" &
						"Google|Google-Sitemaps|HTTPClient|HP Web PrintSmart|IBrowse|iCab|ICE Browser|Kazehakase|KKman|K-Meleon|Konqueror|Links|Lobo|Lynx|Mosaic|SeaMonkey|" &
						"muCommander|NetPositive|Navigator|NetSurf|OmniWeb|Acorn Browse|Oregano|Prism|retawq|Shiira Safari|Shiretoko|Sleipnir|Songbird|Strata|Sylera|" &
						"ThunderBrowse|W3CLineMode|WebCapture|WebTV|w3m|Wget|Xenu_Link_Sleuth|Oregano|xChaos_Arachne|WDG_Validator|W3C_Validator|" &
						"Jigsaw|PLAYSTATION 3|PlayStation Portable|IPD|" &
						"AvantGo|DoCoMo|UP.Browser|Vodafone|J-PHONE|PDXGW|ASTEL|EudoraWeb|Minimo|PLink|NetFront|Xiino|";
					// Mobile strings
						BrowserList=BrowserList & "iPhone|Vodafone|J-PHONE|DDIPocket|EudoraWeb|Minimo|PLink|Plucker|NetFront|PIE|Xiino|" &
						"Opera Mini|IEMobile|portalmmm|OpVer|MobileExplorer|Blazer|MobileExplorer|Opera Mobi|BlackBerry\d*[A-Za-z]?|" &
						"PPC|PalmOS|Smartphone|Netscape|Opera|Safari|Firefox|MSIE|HP iPAQ|LGE|MOT-[A-Z0-9\-]*|Nokia|";
			
					// No browser version given
						BrowserList=BrowserList & "AlphaServer|Charon|Fetch|Hv3|IIgs|Mothra|Netmath|OffByOne|pango-text|Avant Browser|midori|Smart Bro|Swiftfox";
			
						// Identify browser and version
			Browser=REMatchNoCase("(#BrowserList#)/?#VerNo#",UserAgent);
			
			if (ArrayLen(Browser) GT 0) {
			
				if (ArrayLen(Browser) GT 1) {
			
					// If multiple browsers detected, delete the common "spoofed" browsers
					if (Browser[1] EQ "MSIE 6.0" AND Browser[2] EQ "MSIE 7.0") ArrayDeleteAt(Browser,1);
					if (Browser[1] EQ "MSIE 7.0" AND Browser[2] EQ "MSIE 6.0") ArrayDeleteAt(Browser,2);
					tmp2=Browser[ArrayLen(Browser)];
			
					for (x=ArrayLen(Browser); x GTE 1; x=x-1) {
						tmp=Rematchnocase("[A-Za-z0-9.]*",Browser[x]);
						if (ListFindNoCase("Navigator,Netscape,Opera,Safari,Firefox,MSIE,PalmOS,PPC",tmp[1]) GT 0) ArrayDeleteAt(Browser,x);
					}
			
					if (ArrayLen(Browser) EQ 0) Browser[1]=tmp2;
				}
			
				// Seperate out browser name and version number
				tmp=Rematchnocase("[A-Za-z0-9. _\-&]*",Browser[1]);
			
				Browser=tmp[1];
			
				if (ArrayLen(tmp) EQ 2) BrowserVer=tmp[2];
			
				// Handle "Version" in browser string
				tmp=REMatchNoCase("Version/?#VerNo#",UserAgent);
			
				if (ArrayLen(tmp) EQ 1) {
					tmp=Rematchnocase("[A-Za-z0-9.]*",tmp[1]);
					BrowserVer=tmp[2];
				}
			
				// Handle multiple BlackBerry browser strings
				if (Left(Browser,10) EQ "BlackBerry") Browser="BlackBerry";
			
				// Return result
				return Browser & " " & BrowserVer;
			
			}
			
			// Unable to identify browser
			return "Unknown";
			
			</cfscript>

	</cffunction>
	
	<cffunction name="gettctlist" access="public" returntype="query">
		<cfargument name="id" type="numeric" default="0">
		<cfif NOT can('read')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>
		<cfquery datasource="#application.dsn#" name="qtct">
			SELECT * FROM tct
				WHERE 1 = 1
			<cfif id NEQ 0>
				AND id = <cfqueryparam cfsqltype="cf_sql_integer" value="#id#">
			</cfif>
			ORDER BY slug
		</cfquery>
		<cfreturn qtct>
	</cffunction>
	<cffunction name="inserttct" access="public" returntype="numeric">
		<cfargument name="slug" type="string" required="yes">
		<cfargument name="url" type="string" required="yes">
		<cfargument name="active" type="boolean" default="0">
		<cfif NOT can('create')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create this item."></cfif>
		<cfif NOT can('publish')><cfset arguments.active = false></cfif>
		<cfreturn application.DataMgr.insertRecord('tct', arguments)>
	</cffunction>
	<cffunction name="update" access="public" returntype="numeric">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="slug" type="string" required="yes">
		<cfargument name="url" type="string" required="yes">
		<cfargument name="active" type="boolean" default="0">
		<cfif NOT can('edit')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this item."></cfif>
		<cfif NOT can('publish')><cfset arguments.active = false></cfif>
		<cfquery name="qIsPublished" datasource="#application.dsn#">
			SELECT id FROM tct
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfif qIsPublished.recordcount AND NOT can('edit_published')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this item."></cfif>
		<cfreturn application.DataMgr.saveRecord('tct', arguments)>
	</cffunction>
	<cffunction name="activate" access="public" returntype="void">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="function" type="string" required="yes">
		<cfif NOT can('publish')><cfthrow type="c3d.notPermitted" message="You do not have permissions to #arguments.function# this item."></cfif>
		<cfif function EQ "activate">
			<cfset active = 1>
		</cfif>
		<cfif function EQ "deactivate">
			<cfset active = 0>
		</cfif>
		<cfquery datasource="#application.dsn#" name="ins">
			UPDATE tct  SET active = <cfqueryparam cfsqltype="cf_sql_integer" value="#active#">
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	<cffunction name="delete" access="public" returntype="void">
		<cfargument name="id" type="string" required="yes">
		<cfquery datasource="#application.dsn#" name="ins">
			DELETE FROM tct WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	
	
	<cffunction name="getstats">
		<cfargument name="id" type="numeric" required="yes">
		<!---<cfset this.history = gethistory(arguments.id)>--->
		<cfset this.visitsByDate = gethistoryByDate(arguments.id)>
		<cfset this.visitsByBrowser = gethistoryByBrowser(arguments.id)>
		
		
	</cffunction>
	
	<cffunction name="gethistory" access="public" returntype="query">
		<cfargument name="id" type="numeric" required="yes">
		<cfquery datasource="#application.dsn#" name="qhistory">		
			SELECT * FROM tct_history
				WHERE tct_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfreturn qhistory>
	</cffunction>
	
	<cffunction name="gethistoryByDate">
		<cfargument name="id" type="numeric" required="yes">
		<cfquery datasource="#application.dsn#" name="qbydate">
			SELECT count(*) AS numVisits, DATE_FORMAT(stamp, '%Y/%m/%d') AS myDate
				FROM tct_history
				WHERE tct_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
				AND stamp > (NOW() - INTERVAL 30 DAY)
				GROUP BY myDate
		</cfquery>
		<cfreturn qbydate>
	</cffunction>
	<cffunction name="gethistoryByBrowser">
		<cfargument name="id" type="numeric" required="yes">
		<cfquery datasource="#application.dsn#" name="qbybrowser">
			SELECT count(*) AS numVisits, browserParsed
				FROM tct_history
				WHERE tct_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
				GROUP BY browserParsed
		</cfquery>
		<cfreturn qbybrowser>
	</cffunction>
</cfcomponent>
