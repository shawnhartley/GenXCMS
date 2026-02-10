<cfcomponent displayname="Clients" output="false">

	<!--- Init(APIKey) --->		
	<cffunction name="init" access="public" output="false" returntype="clients">

		<cfargument name="APIKey" required="true" type="string" default="" />
		
		<cfset variables.APIKey = arguments.APIKey>
		<cfset variables.APIURL = "http://api.createsend.com/">
		
		<cfreturn this />
	
	</cffunction>
	
	<!--- ListClients() --->
	<cffunction name="ListClients" access="public" output="false" returntype="struct">
		
		<cfscript>
		var apiResult = "";
		var returnQuery = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = variables.APIURL & "api/api.asmx/User.GetClients?ApiKey=" & variables.APIKey;
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
				returnQuery = QueryNew("Name, ID", "VarChar, VarChar");
				for (i = 1; i lte intCount; i = i + 1){
					QueryAddRow(returnQuery, 1);
					QuerySetCell(returnQuery, "Name", apiResult[i].xmlChildren[2].xmlText);
					QuerySetCell(returnQuery, "ID", apiResult[i].xmlChildren[1].xmlText);
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

	<!--- GetClient(clientID) --->
	<cffunction name="GetClient" access="public" output="false" returntype="struct">
		
		<cfargument name="ClientID" type="string" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var detailStruct = StructNew();
		var billingStruct = StructNew();
		var szApiCall = variables.APIURL & "api/api.asmx/Client.GetDetail?ApiKey=" & variables.APIKey & 
			"&ClientID=" & URLEncodedFormat(arguments.clientID);
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
				detailStruct['ClientID'] = apiResult[1].xmlChildren[1].xmlText;
				detailStruct['CompanyName'] = apiResult[1].xmlChildren[2].xmlText;
				detailStruct['ContactName'] = apiResult[1].xmlChildren[3].xmlText;
				detailStruct['EmailAddress'] = apiResult[1].xmlChildren[4].xmlText;
				detailStruct['Country'] = apiResult[1].xmlChildren[5].xmlText;
				detailStruct['TimeZone'] = apiResult[1].xmlChildren[6].xmlText;
				// Billing Struct
				billingStruct['Username'] = apiResult[2].xmlChildren[1].xmlText;
				billingStruct['Password'] = apiResult[2].xmlChildren[2].xmlText;
				billingStruct['BillingType'] = apiResult[2].xmlChildren[3].xmlText;
				billingStruct['Currency'] = apiResult[2].xmlChildren[4].xmlText;
				billingStruct['DeliveryFee'] = apiResult[2].xmlChildren[5].xmlText;
				billingStruct['CostPerRecipient'] = apiResult[2].xmlChildren[6].xmlText;
				billingStruct['DesignAndSpamTestFee'] = apiResult[2].xmlChildren[7].xmlText;
				billingStruct['AccessLevel'] = apiResult[2].xmlChildren[8].xmlText;
				// Return Struct
				returnStruct['blnSuccess'] = 1;
				returnStruct['details'] = detailStruct;
				returnStruct['billing'] = billingStruct;
			}
		} else {
			returnStruct['blnSuccess'] = 0;
			returnStruct['errorCode'] = 0;
			returnStruct['errorMessage'] = "No results found";
		}
		</cfscript>
		
		<cfreturn returnStruct />
		
	</cffunction>
	
	<!--- AddClient(CompanyName,ContactName,EmailAddress,Country,TimeZone) --->
	<cffunction name="AddClient" access="public" output="false" returntype="struct">
		
		<cfargument name="CompanyName" type="string" required="true">
		<cfargument name="ContactName" type="string" required="true">
		<cfargument name="EmailAddress" type="string" required="true">
		<cfargument name="Country" type="string" required="true">
		<cfargument name="TimeZone" type="string" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var szApiCall = 
			variables.APIURL & "api/api.asmx/Client.Create?ApiKey=" & variables.APIKey &
			"&CompanyName=" & URLEncodedFormat(arguments.CompanyName) & 
			"&ContactName=" & URLEncodedFormat(arguments.ContactName) & 
			"&EmailAddress=" & URLEncodedFormat(arguments.EmailAddress) & 
			"&Country=" & URLEncodedFormat(arguments.Country) & 
			"&TimeZone=" & URLEncodedFormat(arguments.TimeZone);
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
	
	<!--- UpdateClient(ClientID,CompanyName,ContactName,EmailAddress,Country,TimeZone) --->
	<cffunction name="UpdateClient" access="public" output="false" returntype="struct">
		
		<cfargument name="ClientID" type="string" required="yes">
		<cfargument name="CompanyName" type="string" required="yes">
		<cfargument name="ContactName" type="string" required="yes">
		<cfargument name="EmailAddress" type="string" required="yes">
		<cfargument name="Country" type="string" required="yes">
		<cfargument name="TimeZone" type="string" required="yes">
		
		<cfscript>
		var apiResult = "";
		var returnQuery = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = variables.APIURL & "api/api.asmx/Client.UpdateBasics?ApiKey=" & variables.APIKey & 
			"&ClientID=" & URLEncodedFormat(arguments.ClientID) & 
			"&CompanyName=" & URLEncodedFormat(arguments.CompanyName) & 
			"&ContactName=" & URLEncodedFormat(arguments.ContactName) & 
			"&EmailAddress=" & URLEncodedFormat(arguments.EmailAddress) & 
			"&Country=" & URLEncodedFormat(arguments.Country) & 
			"&TimeZone=" & URLEncodedFormat(arguments.TimeZone);
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
	
	<!--- UpdateClientBillingAccess(ClientID,AccessLevel,Username,Password,BillingType,Currency,DeliveryFee,CostPerRecipient,DesignAndSpamTestFee) --->
	<cffunction name="UpdateClientBillingAccess" access="public" output="false" returntype="struct">
	
		<cfargument name="ClientID" type="string" required="yes">
		<cfargument name="AccessLevel" type="numeric" required="yes">
		<cfargument name="Username" type="string" required="no">
		<cfargument name="Password" type="string" required="no">
		<cfargument name="BillingType" type="string" required="no">
		<cfargument name="Currency" type="string" required="no">
		<cfargument name="DeliveryFee" type="string" required="no">
		<cfargument name="CostPerRecipient" type="string" required="no">
		<cfargument name="DesignAndSpamTestFee" type="string" required="no">
		
		<cfscript>
		var apiResult = "";
		var returnQuery = "";
		var returnStruct = StructNew();
		var intCount = "0";
		// Create API Call string
		var szApiCall = variables.APIURL & "api/api.asmx/Client.UpdateAccessAndBilling?ApiKey=" & variables.APIKey & 
			"&ClientID=" & URLEncodedFormat(arguments.ClientID) & 
			"&AccessLevel=" & URLEncodedFormat(arguments.AccessLevel) & 
			"&Username=" & URLEncodedFormat(arguments.Username) & 
			"&Password=" & URLEncodedFormat(arguments.Password) & 
			"&BillingType=" & URLEncodedFormat(arguments.BillingType) & 
			"&Currency=" & URLEncodedFormat(arguments.Currency) & 
			"&DeliveryFee=" & URLEncodedFormat(arguments.DeliveryFee) & 
			"&CostPerRecipient=" & URLEncodedFormat(arguments.CostPerRecipient) & 
			"&DesignAndSpamTestFee=" & URLEncodedFormat(arguments.DesignAndSpamTestFee);
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
	
	<!--- DeleteClient(ClientID) --->
	<cffunction name="DeleteClient" access="public" output="false" type="struct">
	
		<cfargument name="ClientID" type="string" required="yes">
		
		<cfscript>
		var apiResult = "";
		var returnQuery = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = variables.APIURL & "api/api.asmx/Client.Delete?ApiKey=" & variables.APIKey & 
			"&ClientID=" & URLEncodedFormat(arguments.ClientID);
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
	
</cfcomponent>