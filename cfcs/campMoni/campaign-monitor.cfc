<cfcomponent displayname="General CM Functions" output="false">

	<!--- Initialise variables for the page --->		
	<cffunction name="init" access="public" output="false" returntype="campaign-monitor">
	
		<cfargument name="APIKey" required="true" type="string" default="" />
		
		<cfset variables.APIKey = arguments.APIKey>
		<cfset variables.APIURL = "http://api.createsend.com/">
		
		<cfreturn this />
	
	</cffunction>

	<!--- ListCountries() --->
	<cffunction name="ListCountries" access="public" output="false" returntype="struct">
		
		<cfscript>
		var apiResult = "";
		var returnQuery = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = variables.APIURL & "api/api.asmx/User.GetCountries?ApiKey=" & variables.APIKey;
		</cfscript>
		
		<!--- Make HTTP call --->
		<cfhttp method="get" result="apiResult" url="#szApiCall#">
			<cfhttpparam type="header" name="accept-encoding" value="no-compression" />
		</cfhttp>
		
		<!--- Handle returned data --->
		<cfscript>	
		// Parse returned XML
		apiResult = xmlParse(apiResult.fileContent);
		apiResult = apiResult.anyType.XMLChildren;
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
				returnQuery = QueryNew("CountryName", "VarChar");
				for (i = 1; i lte intCount; i = i + 1){
					QueryAddRow(returnQuery, 1);
					QuerySetCell(returnQuery, "CountryName", apiResult[i].xmlText);
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
	
	<!--- ListTimeZones() --->
	<cffunction name="ListTimeZones" access="public" output="false" returntype="struct">
		
		<cfscript>
		var apiResult = "";
		var returnQuery = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = variables.APIURL & "api/api.asmx/User.GetTimezones?ApiKey=" & variables.APIKey;
		</cfscript>
		
		<!--- Make HTTP call --->
		<cfhttp method="get" result="apiResult" url="#szApiCall#">
			<cfhttpparam type="header" name="accept-encoding" value="no-compression" />
		</cfhttp>
		
		<!--- Handle returned data --->
		<cfscript>	
		// Parse returned XML
		apiResult = xmlParse(apiResult.fileContent);
		apiResult = apiResult.anyType.XMLChildren;
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
				returnQuery = QueryNew("TimeZone", "VarChar");
				for (i = 1; i lte intCount; i = i + 1){
					QueryAddRow(returnQuery, 1);
					QuerySetCell(returnQuery, "TimeZone", apiResult[i].xmlText);
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
	
	<!--- GetSystemDate() --->
	<cffunction name="GetSystemDate" access="public" output="false" returntype="struct">
		
		<cfscript>
		var apiResult = "";
		var intCount = "0";
		var returnString = "";
		var returnStruct = StructNew();
		var szApiCall = variables.APIURL & "api/api.asmx/User.GetSystemDate?ApiKey=" & variables.APIKey;
		</cfscript>
		
		<!--- Make HTTP call --->
		<cfhttp method="get" result="apiResult" url="#szApiCall#">
			<cfhttpparam type="header" name="accept-encoding" value="no-compression" />
		</cfhttp>
		
		<!--- Create Query From XML --->
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
	
	<!--- ListCurrencies() --->
	<cffunction name="ListCurrencies" access="public" output="false" returntype="query">
	
		<cfscript>
		var qryCurrencies = QueryNew("Currency, CurrencyLong", "VarChar, VarChar");
		QueryAddRow(qryCurrencies, 1);
		QuerySetCell(qryCurrencies, "Currency", "USD");
		QuerySetCell(qryCurrencies, "CurrencyLong", "US Dollars");
		QueryAddRow(qryCurrencies, 1);
		QuerySetCell(qryCurrencies, "Currency", "GBP");
		QuerySetCell(qryCurrencies, "CurrencyLong", "Great British Pounds");
		QueryAddRow(qryCurrencies, 1);
		QuerySetCell(qryCurrencies, "Currency", "EUR");
		QuerySetCell(qryCurrencies, "CurrencyLong", "Euros");
		QueryAddRow(qryCurrencies, 1);
		QuerySetCell(qryCurrencies, "Currency", "CAD");
		QuerySetCell(qryCurrencies, "CurrencyLong", "Canadian Dollars");
		QueryAddRow(qryCurrencies, 1);
		QuerySetCell(qryCurrencies, "Currency", "AUD");
		QuerySetCell(qryCurrencies, "CurrencyLong", "Australian Dollars");
		QueryAddRow(qryCurrencies, 1);
		QuerySetCell(qryCurrencies, "Currency", "NZD");
		QuerySetCell(qryCurrencies, "CurrencyLong", "New Zealand Dollars");
		</cfscript>

		<cfreturn qryCurrencies />
	
	</cffunction>
	
	<!--- ListBillingTypes() --->
	<cffunction name="ListBillingTypes" access="public" output="false" returntype="query">
	
		<cfscript>
		var qryBillingTypes = QueryNew("BillingType", "VarChar");
		QueryAddRow(qryBillingTypes, 1);
		QuerySetCell(qryBillingTypes, "BillingType", "UserPaysOnClientsBehalf");
		QueryAddRow(qryBillingTypes, 1);
		QuerySetCell(qryBillingTypes, "BillingType", "ClientPaysAtStandardRate");
		QueryAddRow(qryBillingTypes, 1);
		QuerySetCell(qryBillingTypes, "BillingType", "ClientPaysWithMarkup");
		</cfscript>

		<cfreturn qryBillingTypes />
	
	</cffunction>
	
	<!--- ListAccessTypes() --->
	<cffunction name="ListAccessTypes" access="public" output="false" returntype="query">
		
		<cfscript>
		var lstAccessTypes = "0,1,2,3,5,7,13,15,18,19,23,31,37,39,45,47,55,63";
		var qryAccesTypes = listToQuery(lstAccessTypes,',','AccessID');
		</cfscript>
		
		<cfreturn qryAccessTypes />
	
	</cffunction>
	
	<!--- ListCustomFieldTypes() --->
	<cffunction name="ListCustomFieldTypes" access="public" output="false" returntype="query">
	
		<cfscript>
		var qryCustomFieldTypes = QueryNew("FieldType", "VarChar");
		QueryAddRow(qryCustomFieldTypes, 1);
		QuerySetCell(qryCustomFieldTypes, "FieldType", "Text");
		QueryAddRow(qryCustomFieldTypes, 1);
		QuerySetCell(qryCustomFieldTypes, "FieldType", "Number");
		QueryAddRow(qryCustomFieldTypes, 1);
		QuerySetCell(qryCustomFieldTypes, "FieldType", "MultiSelectOne");
		QueryAddRow(qryCustomFieldTypes, 1);
		QuerySetCell(qryCustomFieldTypes, "FieldType", "MultiSelectMany");
		QueryAddRow(qryCustomFieldTypes, 1);
		QuerySetCell(qryCustomFieldTypes, "FieldType", "Country");
		QueryAddRow(qryCustomFieldTypes, 1);
		QuerySetCell(qryCustomFieldTypes, "FieldType", "USState");
		QueryAddRow(qryCustomFieldTypes, 1);
		QuerySetCell(qryCustomFieldTypes, "FieldType", "Date");
		</cfscript>

		<cfreturn qryCustomFieldTypes />
	
	</cffunction>
	
	<!--- ListToQuery() - Russ Spivey - http://cflib.org/udf/listToQuery`	--->
	<cffunction name="listToQuery" access="public" output="false" returntype="query">
		
		<cfargument name="list" type="string" required="yes" hint="List to convert.">
		<cfargument name="delimiters" type="string" required="no" default="," hint="Things that separate list elements.">
		<cfargument name="column_name" type="string" required="no" default="column" hint="Name to give query column.">

		<cfset var query = queryNew(arguments.column_name)>
		<cfset var index = ''>

		<cfloop list="#arguments.list#" index="index" delimiters="#arguments.delimiters#">
			<cfset queryAddRow(query)>
			<cfset querySetCell(query,arguments.column_name,index)>
		</cfloop>

		<cfreturn query>
		
	</cffunction>
		
</cfcomponent>