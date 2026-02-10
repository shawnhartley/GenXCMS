<cfcomponent displayname="Lists" output="false">

	<!--- Initialise variables for the page --->		
	<cffunction name="init" access="public" output="false" returntype="lists">
	
		<cfargument name="APIKey" required="true" type="string" default="" />
		
		<cfset variables.APIKey = arguments.APIKey>
		<cfset variables.APIURL = "http://api.createsend.com/">
		
		<cfreturn this />
	
	</cffunction>
	
	<!--- ListClientLists(ClientID) --->
	<cffunction name="ListClientLists" access="public" output="false" returntype="struct">
		
		<cfargument name="ClientID" type="string" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnQuery = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = variables.APIURL & "api/api.asmx/Client.GetLists?ApiKey=" & variables.APIKey & 
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
		if ( apiResult[1].xmlName eq "Code" and apiResult[2].xmlName eq "Message" ){
			returnStruct['blnSuccess'] = 0;
			returnStuct['errorCode'] = apiResult[1].xmlText;
			returnStruct['errorMessage'] = apiResult[2].xmlText;
		}
		// Success
		else {
			// Create Query
			returnQuery = QueryNew("ListName, ID", "VarChar, VarChar");
			for (i = 1; i lte intCount; i = i + 1){
				QueryAddRow(returnQuery, 1);
				QuerySetCell(returnQuery, "ListName", apiResult[i].xmlChildren[2].xmlText);
				QuerySetCell(returnQuery, "ID", apiResult[i].xmlChildren[1].xmlText);
			}
			// Add query to return structure
			returnStruct['blnSuccess'] = 1;
			returnStruct['returnQuery'] = returnQuery;
		}
		</cfscript>
		
		<cfreturn returnStruct />
	
	</cffunction>
	
	<!--- AddList(ClientID,Title,UnsubscribePage,ConfirmOptIn,ComfirmationSuccessPage) --->
 	<cffunction name="AddList" access="public" output="false" returntype="struct">
	
		<cfargument name="ClientID" type="string" required="yes" />
		<cfargument name="Title" type="string" required="yes" />
		<cfargument name="UnsubscribePage" type="string" required="no" default="" />
		<cfargument name="ConfirmOptIn" type="string" required="no" default="false" />
		<cfargument name="ConfirmationSuccessPage" type="string" required="no" default="" />
		
		<cfscript>
		var apiResult = "";
		var returnQuery = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = variables.APIURL & "api/api.asmx/List.Create?ApiKey=" & variables.APIKey & 
			"&ClientID=" & URLEncodedFormat(arguments.ClientID)	& 
			"&Title=" & URLEncodedFormat(arguments.Title) & 
			"&UnsubscribePage=" & URLEncodedFormat(arguments.UnsubscribePage) & 
			"&ConfirmOptIn=" & URLEncodedFormat(arguments.ConfirmOptIn) & 
			"&ConfirmationSuccessPage=" & URLEncodedFormat(arguments.ConfirmationSuccessPage);
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
	
	<!--- DeleteList(ListID) --->
	<cffunction name="DeleteList" access="public" output="false" returntype="struct">
		
		<cfargument name="ListID" type="string" required="yes" />
		
		<cfscript>
		var apiResult = "";
		var returnQuery = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = variables.APIURL & "api/api.asmx/List.Delete?ApiKey=" & variables.APIKey & 
			"&ListID=" & URLEncodedFormat(arguments.ListID);
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
	
	<!--- UpdateList(ListID,Title,UnsubscribePage,ConfirmOptIn,ConfirmationSuccessPage) --->
	<cffunction name="UpdateList" access="public" output="false" returntype="struct">
	
		<cfargument name="ListID" required="yes" />
		<cfargument name="Title" type="string" required="yes" />
		<cfargument name="UnsubscribePage" type="string" required="no" default="" />
		<cfargument name="ConfirmOptIn" type="string" required="no" default="false" />
		<cfargument name="ConfirmationSuccessPage" type="string" required="no" default="" />
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = variables.APIURL & "api/api.asmx/List.Update?ApiKey=" & variables.APIKey & 
			"&ListID=" & URLEncodedFormat(arguments.listID) & 
			"&Title=" & URLEncodedFormat(arguments.title) & 
			"&UnsubscribePage=" & URLEncodedFormat(arguments.unsubscribePage) & 
			"&ConfirmOptIn=" & URLEncodedFormat(arguments.confirmOptIn) & 
			"&ConfirmationSuccessPage=" & URLEncodedFormat(arguments.confirmationSuccessPage);
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
	
	<!--- GetList(ListID) --->
	<cffunction name="GetList" access="public" output="false" returntype="struct">
	
		<cfargument name="ListID" type="string" required="yes">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var detailStruct = StructNew();
		var szApiCall = variables.APIURL & "api/api.asmx/List.GetDetail?ApiKey=" & variables.APIKey & 
			"&ListID=" & URLEncodedFormat(arguments.ListID);
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
				detailStruct['ListID'] = apiResult[1].xmlText;
				detailStruct['Title'] = apiResult[2].xmlText;
				detailStruct['UnsubscribePage'] = apiResult[3].xmlText;
				detailStruct['ConfirmOptIn'] = apiResult[4].xmlText;
				detailStruct['ConfirmationSuccessPagetry'] = apiResult[5].xmlText;
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
	
	<!--- GetStats(ListID) --->
	<cffunction name="GetStats" access="public" output="false" returntype="struct">
	
		<cfargument name="ListID" type="string" required="yes">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var detailStruct = StructNew();
		var szApiCall = variables.APIURL & "api/api.asmx/List.GetStats?ApiKey=" & variables.APIKey & 
			"&ListID=" & URLEncodedFormat(arguments.ListID);
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
				detailStruct['TotalActiveSubscribers'] = apiResult[1].xmlText;
				detailStruct['NewActiveSubscribersToday'] = apiResult[2].xmlText;
				detailStruct['NewActiveSubscribersYesterday'] = apiResult[3].xmlText;
				detailStruct['NewActiveSubscribersThisWeek'] = apiResult[4].xmlText;
				detailStruct['NewActiveSubscribersThisMonth'] = apiResult[5].xmlText;
				detailStruct['NewActiveSubscribersThisYear'] = apiResult[6].xmlText;
				detailStruct['TotalUnsubscribes'] = apiResult[7].xmlText;
				detailStruct['UnsubscribesToday'] = apiResult[8].xmlText;
				detailStruct['UnsubscribesYesterday'] = apiResult[9].xmlText;
				detailStruct['UnsubscribesThisWeek'] = apiResult[10].xmlText;
				detailStruct['UnsubscribesThisMonth'] = apiResult[11].xmlText;
				detailStruct['UnsubscribesThisYear'] = apiResult[12].xmlText;
				detailStruct['TotalDeleted'] = apiResult[13].xmlText;
				detailStruct['DeletedToday'] = apiResult[14].xmlText;
				detailStruct['DeletedYesterday'] = apiResult[15].xmlText;
				detailStruct['DeletedThisWeek'] = apiResult[16].xmlText;
				detailStruct['DeletedThisMonth'] = apiResult[17].xmlText;
				detailStruct['DeletedThisYear'] = apiResult[18].xmlText;
				detailStruct['TotalBounced'] = apiResult[19].xmlText;
				detailStruct['BouncedToday'] = apiResult[20].xmlText;
				detailStruct['BouncedYesterday'] = apiResult[21].xmlText;
				detailStruct['BouncedThisWeek'] = apiResult[22].xmlText;
				detailStruct['BouncedThisMonth'] = apiResult[23].xmlText;
				detailStruct['BouncedThisYear'] = apiResult[24].xmlText;
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
	
	<!--- ListAddCustomField(ListID,FieldName,FieldType,FieldOptions) --->
	<cffunction name="ListAddCustomField" access="public" output="false" returntype="struct">
		
		<cfargument name="ListID" type="string" required="true">
		<cfargument name="FieldName" type="string" required="true">
		<cfargument name="FieldType" type="string" required="true">
		<cfargument name="FieldOptions" type="string" required="false" default="">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = variables.APIURL & "api/api.asmx/List.CreateCustomField?ApiKey=" & variables.APIKey & 
			"&ListID=" & URLEncodedFormat(arguments.listID) & 
			"&FieldName=" & URLEncodedFormat(arguments.FieldName) & 
			"&DataType=" & URLEncodedFormat(arguments.FieldType) & 
			"&Options=" & URLEncodedFormat(arguments.FieldOptions);
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
			returnStruct['errorMessage'] = "Failed to create custom field.";
		}
		</cfscript>
		
		<cfreturn returnStruct />
	
	</cffunction>
	
	<!--- ListCustomFields(ListID) --->
	<cffunction name="ListCustomFields" access="public" output="false" returntype="struct">
	
		<cfargument name="ListId" type="string" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var fieldStruct = StructNew();
		var intCount = "0";
		var optionCount = "0";
		var options = "";
		var szApiCall = variables.APIURL & "api/api.asmx/List.GetCustomFields?ApiKey=" & 
			variables.APIKey& "&ListID=" & URLEncodedFormat(arguments.ListID);
		</cfscript>
		
		<!--- Make HTTP call --->
		<cfhttp method="get" result="apiResult" url="#szApiCall#">
			<cfhttpparam type="header" name="accept-encoding" value="no-compression" />
		</cfhttp>
		
		<!--- <cfdump var="#xmlParse(apiResult.fileContent).anyType.xmlChildren[2].xmlChildren[4].xmlChildren#"><cfabort> --->
		
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
				for (i = 1; i lte intCount; i = i + 1){
					fieldStruct[i] = StructNew();
					fieldStruct[i]['FieldName'] =  apiResult[i].xmlChildren[1].xmltext;
					fieldStruct[i]['Key'] = apiResult[i].xmlChildren[2].xmltext;
					fieldStruct[i]['DataType'] = apiResult[i].xmlChildren[3].xmltext;
					fieldStruct[i]['Options'] = StructNew();
					options = apiResult[i].xmlChildren[4].xmlChildren;
					optionCount = ArrayLen(options);
					if (optionCount GT 0){
						for (iOption = 1; iOption lte optionCount; iOption = iOption + 1){
							fieldStruct[i]['Options'][iOption] = options[iOption].xmlText;
						}
					}
				}
				// Add query to return structure
				returnStruct['fields'] = fieldStruct;
				returnStruct['blnSuccess'] = 1;
			}
		}
		else {
			returnStruct['blnSuccess'] = 0;
			returnStruct['errorCode'] = 0;
			returnStruct['errorMessage'] = "No custom fields found.";
		}
		</cfscript>
		
		<cfreturn returnStruct />
	
	</cffunction>
	
	<!--- ListDeleteCustomField(ListID,FieldName) --->
	<cffunction name="ListDeleteCustomField" access="public" output="false" returntype="struct">
		
		<cfargument name="ListID" type="string" required="true">
		<cfargument name="Key" type="string" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = variables.APIURL & "api/api.asmx/List.DeleteCustomField?ApiKey=" & variables.APIKey & 
			"&ListID=" & URLEncodedFormat(arguments.ListID)	& 
			"&Key=" & URLEncodedFormat(arguments.Key);
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
			returnStruct['errorMessage'] = "Failed to create custom field.";
		}
		</cfscript>
		
		<cfreturn returnStruct />
		
	</cffunction>
	
</cfcomponent>