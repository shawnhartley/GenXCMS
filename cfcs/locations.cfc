<cfcomponent extends="Event" output="no">
	<cffunction name="init" output="no">
		<cfargument name="id" default="0" type="numeric">
		<cfargument name="manage" default="#request.manage#">
		<cfset this.manage = arguments.manage>
		<cfset this.id = arguments.id>
		<cfset Super.init()>
		<cfset this.engine = application.settings.varStr('locations.engine')>
		<cfset this.key = 'AIzaSyADwN7t80n4yJScTE_e7HrIJou6QYRKpio'>
				<!---<cfthrow type="c3d.todo" message="This component needs to be updated to use capability based permissions.">--->

		<cftry>
			<cfswitch expression="#this.engine#">
				<cfcase value="google">
					<cfset initGoogle(argumentcollection=arguments)>
				</cfcase>
				<cfdefaultcase>
					<cfthrow type="c3d.locations.noEngine" message="You must chose a map engine to use.">
				</cfdefaultcase>
			</cfswitch>
			<cfcatch type="c3d.locations.nokey">
				<cfset this.content = cfcatch.Message>
				<cfset this.error = cfcatch>
			</cfcatch>
		</cftry>
		<cfset this.numLocations = getTotalCount()>
		<cfset this.numActiveLocations = getActiveCount()>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="initGoogle" output="no">
		<cfif len(application.settings.varStr('locations.googlekey'))>
			<cfset this.key = application.settings.varStr('locations.googlekey')>
		<cfelse>
			<cfthrow type="c3d.locations.nokey" message="You must set a Google Maps API key before using this object.">
		</cfif>
	</cffunction>
	
	<cffunction name="getTotalCount" returntype="numeric" access="private">
		<cfquery name="qnum" datasource="#application.dsn#">
			SELECT COUNT(1) AS numrows FROM locations
		</cfquery>
		<cfreturn qnum.numrows>
	</cffunction>
	
	<cffunction name="getActiveCount" returntype="numeric" access="private">
		<cfquery name="qnum" datasource="#application.dsn#">
			SELECT COUNT(1) AS numrows FROM locations
				WHERE active = 1
					AND latitude <> 0
					AND longitude <> 0
		</cfquery>
		<cfreturn qnum.numrows>
	</cffunction>
	
	<cffunction name="setID" output="no" access="public">
		<cfargument name="id" default="0">
		<cfset this.id = arguments.id>
		<cfset getlocations(id=arguments.id)>
		<cfif request.manage>
			<cfset this.image = createObject("component", "image").init()>
			<cfset this.geo = createObject("component", "geo")>
			<cfif this.id GT 0>
				<cfset this.geo.results = 
							this.geo.geocode( address1=this.locations.address1, address2=this.locations.address2, city=this.locations.city, state=this.locations.state, postalCode=this.locations.zip, countryCode=this.locations.countrycode )>
				<cfset this.saveGeoResults()>
													
				
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="getlocations" output="no" access="private">
		<cfargument name="orderBy" default="locName">
		<cfargument name="orderDirection" default="ASC">
		<cfargument name="overrideGeocode">
		
		<cfquery datasource="#application.dsn#" name="qlist">
			SELECT * FROM locations
				WHERE 1=1
				<cfif NOT this.manage>
					AND active = '1'
					AND latitude <> 0
					AND longitude <> 0
				</cfif>
				<cfif this.id NEQ 0>
					AND locations.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#this.id#">
				</cfif>
				ORDER BY <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.orderBy#"> <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.orderDirection#">
		</cfquery>
		
		<cfset this.locations = qlist>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="getAllLocations" output="no" returntype="query">
		<cfset setID(0)>
		<cfset getlocations()>
		<cfreturn this.locations>
	</cffunction>
	
	<cffunction name="getActiveLocations" output="no" returntype="struct">
		<cfargument name="minLat" default="0" type="numeric">
		<cfargument name="minLon" default="0" type="numeric">
		<cfargument name="maxLat" default="0" type="numeric">
		<cfargument name="maxLon" default="0" type="numeric">
		<cfset var ret = StructNew()>
		
	<!--- filter out what is on the map --->
		<cfif arguments.minLat>
			<cfquery name="ret.locations" datasource="#application.dsn#">
			SELECT id, locName, description, address1, address2, city, state, zip, countryCode, latitude, longitude
			FROM locations
			WHERE
				latitude BETWEEN <cfqueryparam cfsqltype="cf_sql_float" value="#minLat#"> AND <cfqueryparam cfsqltype="cf_sql_float" value="#maxLat#">
					AND
				longitude BETWEEN <cfqueryparam cfsqltype="cf_sql_float" value="#minLon#"> AND <cfqueryparam cfsqltype="cf_sql_float" value="#maxLon#">
				
				AND latitude <> 0
				AND longitude <> 0
				AND active = '1'
				
				LIMIT 2000
			</cfquery>
			<cfset ret.type = "filter">
		<cfelse>
		
			<cfquery name="ret.locations" datasource="#application.dsn#">
			SELECT id, locName, description, address1, address2, city, state, zip, countryCode, latitude, longitude
			FROM locations
			WHERE
				1=1
				AND latitude <> 0
				AND longitude <> 0
				AND active = '1'
				
				LIMIT 2400
			</cfquery>
			<cfset ret.type = "initial">
		</cfif>
		<cfreturn ret>
	</cffunction>
	
	<cffunction name="getLocationsList" access="public" returntype="query">
		<cfargument name="orderBy" default="locName">
		<cfargument name="orderDirection" default="ASC">
		<cfargument name="active" default="">
		<cfargument name="searchfor" default="">
		<cfargument name="geocoded" default="">
	
		<cfquery datasource="#application.dsn#" name="qlist" >
			SELECT id, locName, address1, hasGeocode, active, attempts FROM locations
				WHERE 1=1
				<cfif len(arguments.searchfor)>
					AND (
							   locName 	LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchfor#%">
							OR address1 LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchfor#%">
							OR address2 LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchfor#%">
							OR city LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchfor#%">
						)
				</cfif>
				<cfif len(arguments.geocoded) AND arguments.geocoded NEQ 'approx'>
					AND hasGeocode = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.geocoded#">
				</cfif>
				<cfif arguments.geocoded EQ 1>
					AND attempts < 4
				</cfif>
				<cfif arguments.geocoded EQ 'approx'>
					AND <!---attempts > 3---> rawGeoResponse LIKE '%APPROXIMATE%'
					AND rawGeoResponse NOT LIKE '%intersection%'
					AND rawGeoResponse NOT LIKE '%establishment%'
					AND rawGeoResponse NOT LIKE '%subpremise%'
					AND rawGeoResponse NOT LIKE '%neighborhood%'
				</cfif>
				<cfif len(arguments.active)>
					AND active = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.active#">
				</cfif>
				ORDER BY locName ASC
				LIMIT 750
				
		</cfquery>
		<cfreturn qlist>
	</cffunction>
	
	<cffunction name="insertLocation" returntype="numeric">
		<cfargument name="locName" required="yes">
		<cfargument name="address1" required="yes">
		<cfargument name="address2" required="no" default="">
		<cfargument name="city" required="no" default="">
		<cfargument name="state" required="no" default="">
		<cfargument name="zip" required="no" default="">
		<cfargument name="countrycode" required="no" default="">
		<cfargument name="active" default="false" type="boolean">
		<cfif NOT len(arguments.countrycode)><cfset arguments.countrycode = application.settings.varStr('locations.defaultCountry')></cfif>
			<cfreturn application.DataMgr.insertRecord('locations', arguments)>
	</cffunction>
	
	<cffunction name="saveGeoResults">
		<cfargument name="results" default="#this.geo.results#">
		
		<cfquery datasource="#application.dsn#" name="qsavegeoresults">
			UPDATE locations
				SET  hasGeoCode = <cfqueryparam cfsqltype="cf_sql_bit" value="#results.hasGeoCode#">
					,rawGeoResponse = <cfqueryparam cfsqltype="cf_sql_varchar" value="#results.rawResponse#">
					,geolatitude = <cfqueryparam cfsqltype="cf_sql_varchar" value="#left(results.latitude,11)#">
					,geolongitude = <cfqueryparam cfsqltype="cf_sql_varchar" value="#left(results.longitude,10)#">
					,attempts = <cfqueryparam cfsqltype="cf_sql_integer" value="#results.attempt#">
			<cfif NOT hasCoordinates()>
					,latitude = <cfqueryparam cfsqltype="cf_sql_varchar" value="#left(results.latitude,11)#">
					,longitude = <cfqueryparam cfsqltype="cf_sql_varchar" value="#left(results.longitude,10)#">
			</cfif>
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#this.id#">
		</cfquery>
		<cfset getlocations()>
	</cffunction>
	<cffunction name="setActive" access="public">
		<cfargument name="active" type="boolean" required="yes">
		<cfquery name="qset" datasource="#application.dsn#">
			UPDATE locations
				SET active = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.active#">
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#this.id#">
		</cfquery>
		<cfreturn true>
	</cffunction>
	<cffunction name="updateLocation">
		<cfargument name="id" required="yes" type="numeric">
		<cfargument name="useGeocode" default="auto">
		<cfargument name="description" default="">
		<cfargument name="active" default="false" type="boolean">
<!--- 		set argument for url overrideGeocode to be passed in --->
		<cfargument name="overrideGeocode" default="false">

		
		<cfquery datasource="#application.dsn#" name="upd">
			UPDATE locations
				SET	 description	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.description#">
					,locName		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.locName#">
					,address1		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.address1#">
					,address2		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.address2#">
					,city			= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.city#">
					,state			= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.state#">
					,zip			= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.zip#">
					,countryCode	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.countrycode#">
					,active			= <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.active#">
<!--- DONT need these with the new overrideGeocode object:
					,overrideLatitude = <cfqueryparam cfsqltype="cf_sql_varchar"value="#arguments.overridelatitude#">
					,overrideLongitude = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.overrideLongitude#">
--->
					,overrideGeocode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.overrideGeocode#">
			<cfswitch expression="#arguments.useGeocode#">
				<cfcase value="auto">

					,latitude 		= geolatitude
					,longitude 		= geolongitude
				</cfcase>
				<cfcase value="override">

<!--- DONT need these with the new overrideGeocode object:
					,latitude = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.overridelatitude#">
					,longitude = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.overrideLongitude#">
--->

					,overrideGeocode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.overridegeocode#">
				</cfcase>
			</cfswitch>
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	
	
	<cffunction name="activate" access="public" returntype="void">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="function" type="string" required="yes">
		<cfif function EQ "activate">
			<cfset active = 1>
		</cfif>
		<cfif function EQ "deactivate">
			<cfset active = 0>
		</cfif>
		<cfquery datasource="#application.dsn#" name="ins">
			UPDATE locations  SET active = <cfqueryparam cfsqltype="cf_sql_integer" value="#active#">
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	<cffunction name="deletelocation" access="public" returntype="void">
		<cfargument name="id" type="string" required="yes">
		<cfquery datasource="#application.dsn#" name="ins">
			DELETE FROM locations WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>

	
	
	<!--- UTIL FUNCTIONS --->
	
	<cffunction name="hasCoordinates" returntype="boolean" output="no">
		<cfreturn this.locations.latitude AND this.locations.longitude>
	</cffunction>
	
	<cffunction name="currentMatchesGeo" returntype="boolean" output="no">
		<cfreturn  this.locations.latitude EQ this.locations.geolatitude AND this.locations.longitude EQ this.locations.geolongitude>
	</cffunction>
	
	<cffunction name="currentMatchesOverride" returntype="boolean" output="no">
		<cfreturn this.locations.latitude EQ this.locations.overridelatitude AND this.locations.longitude EQ this.locations.overridelongitude >
	</cffunction>
	
	<cffunction name="savetoDisk" access="public" returntype="boolean">
		<cfargument name="format" default="json">
		
		<!--- make sure cache dir exists --->
			<cfif NOT DirectoryExists( ExpandPath( application.slashroot & '_cfcache/' ) )>
				<cfdirectory action="create" directory="#ExpandPath( application.slashroot & '_cfcache/' )#">
			</cfif>
		
		<cfif arguments.format EQ 'json'>
			<cffile action="write" nameconflict="overwrite" file="#ExpandPath(application.slashroot & '_cfcache/locations.js')#" output="#feedJSON()#">
			<cfreturn true>
		</cfif>
		
		<cfthrow type="c3d.notImplemented" message="You've tried to save a file in a format we don't understand.">
	</cffunction>
	
	<cffunction name="getCacheDate" output="no" returntype="date">
		<cfargument name="format" default="json">
		
		<cfif arguments.format EQ 'json'>
			<cfif FileExists(ExpandPath(application.slashroot & '_cfcache/locations.js'))>
				<cfdirectory action="list" directory="#ExpandPath(application.slashroot & '_cfcache/')#"
						filter="locations.js" name="fileInfo">
						
						<cfreturn parseDateTime(fileInfo.dateLastModified)>

			<cfelse>
				<cfreturn NOW()>
			</cfif>
		</cfif>
		<cfthrow type="c3d.notImplemented" message="You've tried to check a file in a format we don't understand.">

	</cffunction>
	
	<!--- OUTPUT FUNCTIONS --->
	
	<cffunction name="feedXML" access="remote" output="no" returntype="string" returnformat="plain">
		<cfargument name="minLat" default="0" type="numeric">
		<cfargument name="minLon" default="0" type="numeric">
		<cfargument name="maxLat" default="0" type="numeric">
		<cfargument name="maxLon" default="0" type="numeric">
		
		<cfset data = getActiveLocations(argumentcollection=arguments)>

<cfoutput>
<cfsavecontent variable="XML">
<markers records="#data.locations.recordCount#" type="#data.type#">
<cfloop query="data.locations"><marker lon="#data.locations.longitude#" lat="#data.locations.latitude#" id="#data.locations.id#" d="#HTMLEditFormat('#data.locations.locName#<br />#data.locations.description#')#"<cfif len(application.settings.varStr('locations.iconname'))> iconname="#application.settings.varStr('locations.iconname')#"</cfif> />
</cfloop></markers>
</cfsavecontent>
</cfoutput>


<cfcontent type="application/xml">
<cfreturn XML>
	</cffunction>


	<cffunction name="feedJSON" access="remote" output="no" returntype="string" returnformat="plain">
		<cfargument name="minLat" default="0" type="numeric">
		<cfargument name="minLon" default="0" type="numeric">
		<cfargument name="maxLat" default="0" type="numeric">
		<cfargument name="maxLon" default="0" type="numeric">
		
		<cfset data = getActiveLocations(argumentcollection=arguments)>

<cfoutput>
<cfsavecontent variable="Json">
var data = { "count": #data.locations.recordCount#, "type": "#data.type#",
"markers": [<cfloop query="data.locations"><cfif currentRow NEQ 1>, 
</cfif>{"lon":#data.locations.longitude#, "lat": #data.locations.latitude#, "id":#data.locations.id#, "d":"#data.locations.locName#<br />#data.locations.city#, #data.locations.state# #data.locations.zip#<br />#data.locations.description#"<cfif len(application.settings.varStr('locations.iconname'))>, "iconname":"#application.settings.varStr('locations.iconname')#"</cfif>}</cfloop>]};
</cfsavecontent>
</cfoutput>


<cfif NOT application.settings.var('locations.useCache')><cfcontent type="application/javascript"></cfif>
<cfreturn Json>
	</cffunction>
	
	
</cfcomponent>