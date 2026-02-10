<cfcomponent extends="Event">
	<cffunction name="init" access="public">
		<cfargument name="q" default="">
		<cfargument name="siteSearch" default="0">
		<cfargument name="filter" default="1">
		<cfargument name="start" default="0">
		<cfset Super.init()>
		<cfset this.key = ''>
		<cfset this.engine = application.settings.varStr('search.engine')>
		<cfset this.q = arguments.q>
		<cfif NOT len(this.engine)>
			<cfthrow type="c3d.search.engine" message="You must set a Search engine to use.">
		</cfif>
		<cfset this.numresults = 10>
		<cfif isNumeric(application.settings.var('search.numresults'))>
			<cfset this.numresults = application.settings.var('search.numresults')>
		</cfif>
		<cftry>
			<cfswitch expression="#this.engine#">
				<cfcase value="google">
					<cfset initGoogle(argumentcollection=arguments)>
				</cfcase>
			</cfswitch>
			<cfcatch type="c3d.search.nokey">
				<cfset this.content = cfcatch.Message>
				<cfset this.error = cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn this>
	</cffunction>
	<cffunction name="initGoogle" access="private">
		<cfif NOT len(application.settings.varStr('search.googlekey'))>
			<cfthrow type="c3d.search.noKey" message="You must set an API key for search">
		</cfif>
		<cfset this.key = application.settings.varStr('search.googlekey')>
		<cfset this.url = "http://google.com/cse">
		<cfset extraParams = ''>
		<cfif arguments.sitesearch><cfset extraParams &= '&as_sitesearch=' & cgi.HTTP_HOST></cfif>
		<cftry>
			<cfhttp url="#this.url#?cx=#URLEncodedFormat(this.key)#&client=google-csbe&output=xml_no_dtd&hl=en&q=#URLEncodedFormat(arguments.q)#&start=#(arguments.start)#&filter=#URLEncodedFormat(arguments.filter)##extraParams#"
					result="googleHTTP" throwonerror="yes"></cfhttp>
			<!---<cfhttp url="#this.url#" result="googleHTTP" throwonerror="yes">
				<cfhttpparam type="url" name="cx" value="#this.key#"> <!--- cfhttpparam encodes the url string, so we don't need to --->
				<cfhttpparam type="url" name="client" value="google-csbe">
				<cfhttpparam type="url" name="output" value="xml_no_dtd">
				<cfhttpparam type="url" name="hl" value="en">
				<cfhttpparam type="url" name="num" value="#this.numresults#">
				
				<cfhttpparam type="url" name="q" value="#arguments.q#">
				<cfhttpparam type="url" name="start" value="#arguments.start#">
				<cfhttpparam type="url" name="filter" value="#arguments.filter#">
			</cfhttp>--->
			<cfset this.http = googleHTTP>
			<cffile action="read" file="#ExpandPath('/view/search.xsl')#" variable="xslDoc">
			<cfset transformedXML = XmlTransform(googleHTTP.FileContent, xslDoc)>
			<cfset this.content = transformedXML>
			<cfcatch>
				<cfset this.content = cfcatch.Message>
				<cfset this.error = cfcatch>
			</cfcatch>
		</cftry>
		
	</cffunction>
</cfcomponent>