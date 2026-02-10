<cfcomponent displayname="Templates" output="false">

	<!--- Initialise variables for the page --->		
	<cffunction name="init" access="public" output="false" returntype="templates">
	
		<cfargument name="APIKey" required="true" type="string" default="" />
		
		<cfset variables.APIKey = arguments.APIKey>
		<cfset variables.APIURL = "http://api.createsend.com/">
		
		<cfreturn this />
	
	</cffunction>
	
	<!--- ListClientTemplates(clientID) --->
	<cffunction name="ListClientTemplates" access="public" output="false" returntype="struct">
		
		<cfargument name="clientID" type="string" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnQuery = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = variables.APIURL & "api/api.asmx/Client.GetTemplates?ApiKey=" & variables.APIKey & 
			"&ClientID=" & URLEncodedFormat(arguments.clientID);
		</cfscript>
		
		<!--- Make HTTP call --->
		<cfhttp method="get" result="apiResult" url="#szApiCall#">
			<cfhttpparam type="header" name="accept-encoding" value="no-compression" />
		</cfhttp>
		
		<!--- Handle returned data --->
		<cfscript>
		// Parse returned XML	
		apiResult = xmlParse(apiResult.fileContent);
		apiResult = apiResult.anyType.xmlChildren;
		intCount = ArrayLen(apiResult);
		// Error handling
		if (intCount gt 0){
			if ( apiResult[1].xmlName eq "Code" and apiResult[2].xmlName eq "Message" ){
				returnStruct['blnSuccess'] = 0;
				returnStruct['errorCode'] = apiResult[1].xmlText;
				returnStruct['errorMessage'] = apiResult[2].xmlText;
			}
			// Success
			else {
				// Create Query
				returnQuery = QueryNew("ID, Name, ScreenshotURL, PreviewURL", "VarChar, VarChar, VarChar, VarChar");
				for (i = 1; i lte intCount; i = i + 1){
					QueryAddRow(returnQuery, 1);
					QuerySetCell(returnQuery, "ID", apiResult[i].xmlChildren[1].xmlText);
					QuerySetCell(returnQuery, "Name", apiResult[i].xmlChildren[2].xmlText);
					QuerySetCell(returnQuery, "ScreenshotURL", apiResult[i].xmlChildren[3].xmlText);
					QuerySetCell(returnQuery, "PreviewURL", apiResult[i].xmlChildren[4].xmlText);
				}
				// Add query to return structure
				returnStruct['blnSuccess'] = 1;
				returnStruct['returnQuery'] = returnQuery;
			}
		} else {
			returnStruct['blnSuccess'] = 0;
			returnStruct['errorCode'] = 0;
			returnStruct['errorMessage'] = "No results found";
		}
		</cfscript>
		
		<cfreturn returnStruct />
	
	</cffunction>
	
	<!--- GetTemplate(TemplateID) --->
	<cffunction name="GetTemplate" access="public" output="false" returntype="struct">
	
		<cfargument name="TemplateID" type="string" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var detailStruct = StructNew();
		var szApiCall = variables.APIURL & "api/api.asmx/Template.GetDetail?ApiKey=" & variables.APIKey & 
			"&TemplateID=" & URLEncodedFormat(arguments.TemplateID);
		</cfscript>
		
		<!--- Make HTTP call --->
		<cfhttp method="get" result="apiResult" url="#szApiCall#">
			<cfhttpparam type="header" name="accept-encoding" value="no-compression" />
		</cfhttp>
		
		<cfscript>
		apiResult = xmlParse(apiResult.fileContent);
		apiResult = apiResult.anyType.xmlChildren;
		intCount = ArrayLen(apiResult);
		// Error handling
		if (intCount gt 0){
			if ( apiResult[1].xmlName eq "Code" and apiResult[2].xmlName eq "Message" ){
				returnStruct['blnSuccess'] = 0;
				returnStruct['errorCode'] = apiResult[1].xmlText;
				returnStruct['errorMessage'] = apiResult[2].xmlText;
			}
			// Success
			else {
				// Detail Struct
				detailStruct['TemplateID'] = apiResult[1].xmlText;
				detailStruct['Name'] = apiResult[2].xmlText;
				detailStruct['PreviewURL'] = apiResult[3].xmlText;
				detailStruct['ScreenshotURL'] = apiResult[4].xmlText;
				// Return Struct
				returnStruct['blnSuccess'] = 1;
				returnStruct['details'] = detailStruct;
			}
		} else {
			returnStruct['blnSuccess'] = 0;
			returnStruct['errorCode'] = 0;
			returnStruct['errorMessage'] = "No results found";
		}
		</cfscript>
		
		<cfreturn returnStruct />
		
	</cffunction>
	
	<!--- DeleteTemplate(TemplateID) --->
	<cffunction name="DeleteTemplate" access="public" output="false" type="struct">
	
		<cfargument name="TemplateID" type="string" required="yes">
		
		<cfscript>
		var apiResult = "";
		var returnQuery = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = variables.APIURL & "api/api.asmx/Template.Delete?ApiKey=" & variables.APIKey & 
			"&TemplateID=" & URLEncodedFormat(arguments.TemplateID);
		</cfscript>
		
		<!--- Make HTTP call --->
		<cfhttp method="get" result="apiResult" url="#szApiCall#">
			<cfhttpparam type="header" name="accept-encoding" value="no-compression" />
		</cfhttp>
		
		<!--- Handle returned data --->
		<cfscript>
		// Parse returned XML	
		apiResult = xmlParse(apiResult.fileContent);
		apiResult = apiResult.Result.xmlChildren;
		intCount = ArrayLen(apiResult);
		// Error handling
		if (intCount gt 0){
			if ( apiResult[1].xmlName eq "Code" and apiResult[2].xmlName eq "Message" ){
				returnStruct['errorCode'] = apiResult[1].xmlText;
				returnStruct['errorMessage'] = apiResult[2].xmlText;
				if (returnStruct.errorCode eq 0){
					returnStruct['blnSuccess'] = 1;
				} else {
					returnStruct['blnSuccess'] = 0;
				}
			}
		} else {
			returnStruct['blnSuccess'] = 0;
			returnStruct['errorCode'] = 0;
			returnStruct['errorMessage'] = "No results found";
		}
		</cfscript>
		
		<cfreturn returnStruct />
		
	</cffunction>
	
	<!--- AddTemplate(ClientID,TemplateName,HTMLPageURL,ZipFileURL,ScreenshotURL) --->
	<cffunction name="AddTemplate" access="public" output="false" returntype="struct">
		
		<cfargument name="ClientID" type="string" required="true">
		<cfargument name="TemplateName" type="string" required="true">
		<cfargument name="HTMLPageURL" type="string" required="true">
		<cfargument name="ZipFileURL" type="string" required="false" default="">
		<cfargument name="ScreenshotURL" type="string" required="false" default="">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var szApiCall = variables.APIURL & "api/api.asmx/Template.Create?ApiKey=" & variables.APIKey & 
			"&ClientID=" & URLEncodedFormat(arguments.ClientID) & 
			"&TemplateName=" & URLEncodedFormat(arguments.TemplateName) & 
			"&HTMLPageURL=" & URLEncodedFormat(arguments.HTMLPageURL) & 
			"&ZipFileURL=" & URLEncodedFormat(arguments.ZipFileURL) & 
			"&ScreenshotURL=" & URLEncodedFormat(arguments.ScreenshotURL);
		</cfscript>
		
		<!--- Make HTTP call --->
		<cfhttp method="get" result="apiResult" url="#szApiCall#">
			<cfhttpparam type="header" name="accept-encoding" value="no-compression" />
		</cfhttp>
		
		<cfscript>
		// Parse returned XML
		apiResult = xmlParse(apiResult.fileContent);
		try {intCount = ArrayLen(apiResult.anyType.XMLChildren);}
		catch(Any e){intCount = 0;}
		if (intCount gt 0){apiResult = apiResult.anyType.xmlChildren;}
		// Error handling
		if ( apiResult[1].xmlName eq "Code" and apiResult[2].xmlName eq "Message" ){
			returnStruct['blnSuccess'] = 0;
			returnStruct['errorCode'] = apiResult[1].xmlText;
			returnStruct['errorMessage'] = apiResult[2].xmlText;
		}
		// Success
		else {
			// Return str
			returnStruct['blnSuccess'] = 1;
			returnStruct['returnString'] = apiResult.anyType.xmlText;
		}		
		</cfscript>
		
		<cfreturn returnStruct />
		
	</cffunction>
	
	<!--- UpdateTemplate(TemplateID,TemplateName,HTMLPageURL,ZipFileURL,ScreenshotURL) --->
	<cffunction name="UpdateTemplate" access="public" output="false" returntype="struct">
		
		<cfargument name="TemplateID" type="string" required="true">
		<cfargument name="TemplateName" type="string" required="true">
		<cfargument name="HTMLPageURL" type="string" required="true">
		<cfargument name="ZipFileURL" type="string" required="false" default="">
		<cfargument name="ScreenshotURL" type="string" required="false" default="">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var szApiCall = variables.APIURL & "api/api.asmx/Template.Update?ApiKey=" & variables.APIKey & 
			"&TemplateID=" & URLEncodedFormat(arguments.TemplateID) & 
			"&TemplateName=" & URLEncodedFormat(arguments.TemplateName) & 
			"&HTMLPageURL=" & URLEncodedFormat(arguments.HTMLPageURL) & 
			"&ZipFileURL=" & URLEncodedFormat(arguments.ZipFileURL) & 
			"&ScreenshotURL=" & URLEncodedFormat(arguments.ScreenshotURL);
		</cfscript>
		
		<!--- Make HTTP call --->
		<cfhttp method="get" result="apiResult" url="#szApiCall#">
			<cfhttpparam type="header" name="accept-encoding" value="no-compression" />
		</cfhttp>
		
		<cfscript>
		// Parse returned XML	
		apiResult = xmlParse(apiResult.fileContent);
		apiResult = apiResult.Result.xmlChildren;
		intCount = ArrayLen(apiResult);
		// Error handling
		if (intCount gt 0){
			if ( apiResult[1].xmlName eq "Code" and apiResult[2].xmlName eq "Message" ){
				returnStruct['errorCode'] = apiResult[1].xmlText;
				returnStruct['errorMessage'] = apiResult[2].xmlText;
				if (returnStruct.errorCode eq 0){
					returnStruct['blnSuccess'] = 1;
				} else {
					returnStruct['blnSuccess'] = 0;
				}
			}
		} else {
			returnStruct['blnSuccess'] = 0;
			returnStruct['errorCode'] = 0;
			returnStruct['errorMessage'] = "No results found";
		}
		</cfscript>
		
		<cfreturn returnStruct />
		
	</cffunction>
		
</cfcomponent>