<cfcomponent displayname="Subscribers" output="false">

	<!--- Initialise variables for the page --->		
	<cffunction name="init" access="public" output="false" returntype="subscribers">
	
		<cfargument name="APIKey" required="true" type="string" default="" />
		
		<cfset variables.APIKey = arguments.APIKey>
		<cfset variables.APIURL = "http://api.createsend.com/">
		
		<cfreturn this />
	
	</cffunction>
	
	<!--- AddSubscriber(ListID,Email,Name) --->
	<cffunction name="AddSubscriber" access="remote" output="false" returntype="struct">
		
		<cfargument name="ListID" type="string" required="true">
		<cfargument name="Email" type="string" required="true">
		<cfargument name="Name" type="string" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var szApiCall = variables.APIURL & "api/api.asmx/Subscriber.Add?ApiKey=" & variables.APIKey & 
			"&ListID=" & URLEncodedFormat(arguments.ListID) & 
			"&Email=" & URLEncodedFormat(arguments.Email) & 
			"&Name=" & URLEncodedFormat(arguments.Name);
		</cfscript>
		
		<!--- Make HTTP call --->
		<cfhttp method="get" result="apiResult" url="#szApiCall#">
			<cfhttpparam type="header" name="accept-encoding" value="no-compression" />
		</cfhttp>
		
		<cfscript>
		// Parse returned XML
		apiResult = xmlParse(apiResult.fileContent);
		try {intCount = ArrayLen(apiResult.Result.XMLChildren);}
		catch(Any e){intCount = 0;}
		if (intCount gt 0){apiResult = apiResult.Result.xmlChildren;}
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
			returnStruct['returnString'] = apiResult.Result.xmlText;
		}		
		</cfscript>
		
		<cfreturn returnStruct />
	
	</cffunction>	
	
	<!--- AddResubscribeSubscriber(ListID,Email,Name) --->
	<cffunction name="AddResubscribeSubscriber" access="remote" output="false" returntype="struct">
		
		<cfargument name="ListID" type="string" required="true">
		<cfargument name="Email" type="string" required="true">
		<cfargument name="Name" type="string" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var szApiCall = variables.APIURL & "api/api.asmx/Subscriber.AddAndResubscribe?ApiKey=" & variables.APIKey & 
			"&ListID=" & URLEncodedFormat(arguments.ListID) & 
			"&Email=" & URLEncodedFormat(arguments.Email) & 
			"&Name=" & URLEncodedFormat(arguments.Name);
		</cfscript>
		
		<!--- Make HTTP call --->
		<cfhttp method="get" result="apiResult" url="#szApiCall#">
			<cfhttpparam type="header" name="accept-encoding" value="no-compression" />
		</cfhttp>
		
		<cfscript>
		// Parse returned XML
		apiResult = xmlParse(apiResult.fileContent);
		try {intCount = ArrayLen(apiResult.Result.XMLChildren);}
		catch(Any e){intCount = 0;}
		if (intCount gt 0){apiResult = apiResult.Result.xmlChildren;}
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
			returnStruct['returnString'] = apiResult.Result.xmlText;
		}		
		</cfscript>
		
		<cfreturn returnStruct />
	
	</cffunction>
	
	<!--- Unsubscribe(ListID,Email) --->
	<cffunction name="Unsubscribe" access="remote" output="false" returntype="struct">
		
		<cfargument name="ListID" type="string" required="true">
		<cfargument name="Email" type="string" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var szApiCall = variables.APIURL & "api/api.asmx/Subscriber.Unsubscribe?ApiKey=" & variables.APIKey & 
			"&ListID=" & URLEncodedFormat(arguments.ListID) & 
			"&Email=" & URLEncodedFormat(arguments.Email);
		</cfscript>
		
		<!--- Make HTTP call --->
		<cfhttp method="get" result="apiResult" url="#szApiCall#">
			<cfhttpparam type="header" name="accept-encoding" value="no-compression" />
		</cfhttp>
		
		<cfscript>
		// Parse returned XML
		apiResult = xmlParse(apiResult.fileContent);
		try {intCount = ArrayLen(apiResult.Result.XMLChildren);}
		catch(Any e){intCount = 0;}
		if (intCount gt 0){apiResult = apiResult.Result.xmlChildren;}
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
			returnStruct['returnString'] = apiResult.Result.xmlText;
		}		
		</cfscript>
		
		<cfreturn returnStruct />
	
	</cffunction>
	
	<!--- GetSubscriber(ListID,EmailAddress) --->
	<cffunction name="GetSubscriber" access="public" output="false" returntype="struct">
	
		<cfargument name="ListID" type="string" required="yes">
		<cfargument name="EmailAddress" type="string" required="yes">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var detailStruct = StructNew();
		var szApiCall = variables.APIURL & "api/api.asmx/Subscribers.GetSingleSubscriber?ApiKey=" & variables.APIKey & 
			"&ListID=" & URLEncodedFormat(arguments.ListID) & 
			"&EmailAddress=" & URLEncodedFormat(arguments.EmailAddress);
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
				detailStruct['EmailAddress'] = apiResult[1].xmlText;
				detailStruct['Name'] = apiResult[2].xmlText;
				detailStruct['Date'] = apiResult[3].xmlText;
				detailStruct['State'] = apiResult[4].xmlText;
				detailStruct['CustomFields'] = StructNew();
				try {
					customFields = apiResult[5].xmlChildren;
					for (i = 1; i lte ArrayLen(customFields); i = i + 1){
						detailStruct['customFields'][customFields[i].xmlChildren[1].xmlText] = customFields[i].xmlChildren[2].XmlText;
					}
				} catch(Any e){
					detailStruct['customFields'] = 'None';
				}
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
	
	<!--- ListSubscribers(ListID,Date) --->
	<cffunction name="ListSubscribers" access="remote" output="false" returntype="struct">
		
		<cfargument name="ListID" type="string" required="true">
		<cfargument name="Date" type="string" required="false" default="2000-01-01 00:00:01" hint="Format: YYYY-MM-DD HH:MM:SS">
		
		<cfscript>
		var customFields = "";
		var apiResult = "";
		var subscriberStruct = StructNew();
		var subscriber = StructNew();
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = variables.APIURL & "api/api.asmx/Subscribers.GetActive?ApiKey=" & variables.APIKey & 
			"&ListID=" & URLEncodedFormat(arguments.ListID) & 
			"&Date=" & URLEncodedFormat(arguments.Date);
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
			for (i = 1; i lte intCount; i = i + 1){
				subscriber['EmailAddress'] = apiResult[i].xmlChildren[1].xmlText;
				subscriber['Name'] = apiResult[i].xmlChildren[2].xmlText;
				subscriber['Date'] = apiResult[i].xmlChildren[3].xmlText;
				subscriber['State'] = apiResult[i].xmlChildren[4].xmlText;
				subscriber['CustomFields'] = StructNew();
			
				try {
					customFields = apiResult[i].xmlChildren[5].xmlChildren;
					for (s = 1; s lte ArrayLen(customFields); s = s + 1){
						subscriber['CustomFields'][customFields[s].xmlChildren[1].XmlText] = customFields[s].xmlChildren[2].XmlText;
					}
				}
				catch(Any e){}
				subscriberStruct[i] = subscriber;
			}
			// Add query to return structure
			returnStruct['blnSuccess'] = 1;
			returnStruct['subcriberStruct'] = subscriberStruct;
		}
		</cfscript>
		
		<cfreturn returnStruct />
		
	</cffunction>
	
	<!--- ListUnsubscribers(ListID,Date) --->
	<cffunction name="ListUnsubscribers" access="remote" output="false" returntype="struct">
		
		<cfargument name="ListID" type="string" required="true">
		<cfargument name="Date" type="string" required="false" default="2000-01-01 00:00:01" hint="Format: YYYY-MM-DD HH:MM:SS">
		
		<cfscript>
		var customFields = "";
		var apiResult = "";
		var unsubscriberStruct = StructNew();
		var unsubscriber = StructNew();
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = variables.APIURL & "api/api.asmx/Subscribers.GetUnsubscribed?ApiKey=" & variables.APIKey & 
			"&ListID=" & URLEncodedFormat(arguments.ListID) & 
			"&Date=" & URLEncodedFormat(arguments.Date);
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
			for (i = 1; i lte intCount; i = i + 1){
				unsubscriber['EmailAddress'] = apiResult[i].xmlChildren[1].xmlText;
				unsubscriber['Name'] = apiResult[i].xmlChildren[2].xmlText;
				unsubscriber['Date'] = apiResult[i].xmlChildren[3].xmlText;
				unsubscriber['State'] = apiResult[i].xmlChildren[4].xmlText;
				unsubscriber['CustomFields'] = StructNew();
				try {
					customFields = apiResult[i].xmlChildren[5].xmlChildren;
					for (s = 1; s lte ArrayLen(customFields); s = s + 1){
						unsubscriber['CustomFields'][customFields[s].xmlChildren[1].XmlText] = customFields[s].xmlChildren[2].XmlText;
					}
				}
				catch(Any e){}
				unsubscriberStruct[i] = unsubscriber;
			}
			// Add query to return structure
			returnStruct['blnSuccess'] = 1;
			returnStruct['unsubcriberStruct'] = unsubscriberStruct;
		}
		</cfscript>
		
		<cfreturn returnStruct />
		
	</cffunction>
	
	<!--- CheckIsSubscribed(ListID,Email) --->
	<cffunction name="CheckIsSubscribed" access="public" output="false" returntype="struct">
		
		<cfargument name="ListID" type="string" required="true">
		<cfargument name="Email" type="string" required="true">
		
		<cfscript>
		var apiResult = "";
		var intCount = "0";
		var returnString = "";
		var returnStruct = StructNew();
		var szApiCall = variables.APIURL & "api/api.asmx/Subscribers.GetIsSubscribed?ApiKey=" & variables.APIKey  & 
			"&ListID=" & URLEncodedFormat(arguments.ListID) & 
			"&Email=" & URLEncodedFormat(arguments.Email);
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
	
	<!--- AddSubscriberCustomFields() --->
	<cffunction name="AddSubscriberCustomFields" access="public" output="false" returntype="struct">
	
		<cfargument name="ListID" type="string" required="true">
		<cfargument name="EmailAddress" type="string" required="true">
		<cfargument name="Name" type="string" required="false" default="">
		<cfargument name="arrCustomFields" type="Array" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szSoapPacket = "";
		</cfscript>
		
		<cfsavecontent variable="szSoapPacket"><cfoutput>
		<?xml version="1.0" encoding="utf-8"?>
		<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
		  xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
		  <soap:Body>
		    <Subscriber.AddWithCustomFields xmlns="http://api.createsend.com/api/">
		      <ApiKey>#variables.APIkey#</ApiKey>
		      <ListID>#arguments.ListID#</ListID>
		      <Email>#arguments.EmailAddress#</Email>
		      <Name>#arguments.Name#</Name>
		      <CustomFields>
		      	<cfloop array="#arguments.arrCustomFields#" index="customfield">
		        <SubscriberCustomField>
		          <Key>#customField[1]#</Key>
		          <Value>#customField[2]#</Value>
		        </SubscriberCustomField>
		        </cfloop>
		      </CustomFields>
		    </Subscriber.AddWithCustomFields>
		  </soap:Body>
		</soap:Envelope>
		</cfoutput></cfsavecontent>
		
		<cfhttp url="http://api.createsend.com/api/api.asmx" method="post" result="apiResult">
			<cfhttpparam type="header" name="SOAPAction" value="http://api.createsend.com/api/Subscriber.AddWithCustomFields" />
			<cfhttpparam type="header" name="accept-encoding" value="no-compression" />
			<cfhttpparam type="xml" value="#trim(szSoapPacket)#" />
		</cfhttp>
		
		<cfif find("200",apiResult.statusCode)>
			<cfscript>
			apiResult = xmlParse(apiResult.fileContent);
			apiResult = xmlSearch(apiResult,"//*[local-name()='Subscriber.AddWithCustomFieldsResult']");
			returnStruct['errorCode'] = apiResult[1].Code.xmlText;
			returnStruct['errorMessage'] = apiResult[1].Message.xmlText;
			if (returnStruct.errorCode EQ 0){
				returnStruct['blnSuccess'] = 1;
			} else {
				returnStruct['blnSuccess'] = 0;
			}
			</cfscript>
		<cfelse>
			<cfscript>
			returnStruct['blnSuccess'] = 0;
			returnStruct['errorMessage'] = 'SOAP call failed.';
			</cfscript>
		</cfif>
		
		<cfreturn returnStruct />
	
	</cffunction>
	
	<!--- AddResubscribeSubscriberCustomFields() --->
	<cffunction name="AddResubscribeSubscriberCustomFields" access="public" output="false" returntype="struct">
		
		<cfargument name="ListID" type="string" required="true">
		<cfargument name="EmailAddress" type="string" required="true">
		<cfargument name="Name" type="string" required="false" default="">
		<cfargument name="arrCustomFields" type="Array" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szSoapPacket = "";
		</cfscript>
		
		<cfsavecontent variable="szSoapPacket"><cfoutput>
		<?xml version="1.0" encoding="utf-8"?>
		<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
		  xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
		  <soap:Body>
		    <Subscriber.AddAndResubscribeWithCustomFields xmlns="http://api.createsend.com/api/">
		      <ApiKey>#variables.APIkey#</ApiKey>
		      <ListID>#arguments.ListID#</ListID>
		      <Email>#arguments.EmailAddress#</Email>
		      <Name>#arguments.Name#</Name>
		      <CustomFields>
		      	<cfloop array="#arguments.arrCustomFields#" index="customfield">
		        <SubscriberCustomField>
		          <Key>#customField[1]#</Key>
		          <Value>#customField[2]#</Value>
		        </SubscriberCustomField>
		        </cfloop>
		      </CustomFields>
		    </Subscriber.AddAndResubscribeWithCustomFields>
		  </soap:Body>
		</soap:Envelope>
		</cfoutput></cfsavecontent>
		
		<cfhttp url="http://api.createsend.com/api/api.asmx" method="post" result="apiResult">
			<cfhttpparam type="header" name="SOAPAction" value="http://api.createsend.com/api/Subscriber.AddAndResubscribeWithCustomFields" />
			<cfhttpparam type="header" name="accept-encoding" value="no-compression" />
			<cfhttpparam type="xml" value="#trim(szSoapPacket)#" />
		</cfhttp>
		
		<cfif find("200",apiResult.statusCode)>
			<cfscript>
			apiResult = xmlParse(apiResult.fileContent);
			apiResult = xmlSearch(apiResult,"//*[local-name()='Subscriber.AddAndResubscribeWithCustomFieldsResult']");
			returnStruct['errorCode'] = apiResult[1].Code.xmlText;
			returnStruct['errorMessage'] = apiResult[1].Message.xmlText;
			if (returnStruct.errorCode EQ 0){
				returnStruct['blnSuccess'] = 1;
			} else {
				returnStruct['blnSuccess'] = 0;
			}
			</cfscript>
		<cfelse>
			<cfscript>
			returnStruct['blnSuccess'] = 0;
			returnStruct['errorMessage'] = 'SOAP call failed.';
			</cfscript>
		</cfif>
		
		<cfreturn returnStruct />
		
	</cffunction>
	
</cfcomponent>