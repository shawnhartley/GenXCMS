<cfcomponent displayname="Campaigns" output="false">

	<!--- Initialise variables for the page --->		
	<cffunction name="init" access="public" output="false" returntype="campaigns">
	
		<cfargument name="APIKey" required="true" type="string" default="" />
		
		<cfset variables.APIKey = arguments.APIKey>
		<cfset variables.APIURL = "http://api.createsend.com/">
		
		<cfreturn this />
	
	</cffunction>
	
	<!--- ListClientCampaigns(ClientID) --->
	<cffunction name="ListClientCampaigns" access="public" output="false" returntype="struct">
		
		<cfargument name="ClientID" type="string" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnQuery = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = 
			variables.APIURL & "api/api.asmx/Client.GetCampaigns?ApiKey=" & variables.APIKey
			& "&ClientID=" & URLEncodedFormat(arguments.ClientID);
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
				returnQuery = QueryNew("ID, Name, Subject, SentDate, TotalRecipients", "VarChar, VarChar, VarChar, VarChar, VarChar");
				for (i = 1; i lte intCount; i = i + 1){
					QueryAddRow(returnQuery, 1);
					QuerySetCell(returnQuery, "ID", apiResult[i].xmlChildren[1].xmlText);
					QuerySetCell(returnQuery, "Name", apiResult[i].xmlChildren[2].xmlText);
					QuerySetCell(returnQuery, "Subject", apiResult[i].xmlChildren[3].xmlText);
					QuerySetCell(returnQuery, "SentDate", apiResult[i].xmlChildren[4].xmlText);
					QuerySetCell(returnQuery, "TotalRecipients", apiResult[i].xmlChildren[5].xmlText);
				}
				// Add query to return structure
				returnStruct['blnSuccess'] = 1;
				returnStruct['returnQuery'] = returnQuery;
			}
		}
		else {
			returnStruct['blnSuccess'] = 0;
			returnStruct['errorCode'] = 0;
			returnStruct['errorMessage'] = "No results found";
		}
		</cfscript>
		
		<cfreturn returnStruct />
	
	</cffunction>
	
	<!--- CreateCampaign(ClientID,CampaignName,CampaignSubject,FromName,FromEmail,ReplyTo,HtmlUrl,TextUrl,SubscriberListIDs,ListSegments) --->
	<cffunction name="CreateCampaign" access="public" output="false" returntype="struct">
	
		<cfargument name="ClientID" type="string" required="true">
		<cfargument name="CampaignName" type="string" required="true">
		<cfargument name="CampaignSubject" type="string" required="true">
		<cfargument name="FromName" type="string" required="true">
		<cfargument name="FromEmail" type="string" required="true">
		<cfargument name="ReplyTo" type="string" required="true">
		<cfargument name="HtmlUrl" type="string" required="true">
		<cfargument name="TextUrl" type="string" required="true">
		<!---
			Only one must be specified:
			SubscriberListIds format: listID,listID,listID
			ListSegments format: listID|name,listID|name,listID|name
		--->
		<cfargument name="SubscriberListIDs" type="string" required="false" default="">
		<cfargument name="ListSegments" type="string" required="false" default="">
		
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
				<Campaign.Create xmlns="http://api.createsend.com/api/">
					<ApiKey>#variables.APIKey#</ApiKey>
					<ClientID>#arguments.ClientID#</ClientID>
					<CampaignName>#arguments.CampaignName#</CampaignName>
					<CampaignSubject>#arguments.CampaignSubject#</CampaignSubject>
					<FromName>#arguments.FromName#</FromName>
					<FromEmail>#arguments.FromEmail#</FromEmail>
					<ReplyTo>#arguments.ReplyTo#</ReplyTo>
					<HtmlUrl>#arguments.HtmlUrl#</HtmlUrl>
					<TextUrl>#arguments.TextUrl#</TextUrl>
					<cfif ListLen(arguments.SubscriberListIDs) gt 0>
					<SubscriberListIDs>
						<cfloop list="#arguments.SubscriberListIDs#" index="listID">
						<string>#listID#</string>
						</cfloop>
					</SubscriberListIDs>
					</cfif>
					<cfif ListLen(arguments.ListSegments) gt 0>
					<ListSegments>
						<cfloop list="#arguments.ListSegments#" index="segment">
						<List>
							<ListID>#ListFirst(segment, '|')#</ListID>
							<Name>#ListLast(segment, '|')#</Name>
						</List>
						</cfloop>
					</ListSegments>
					</cfif>
				</Campaign.Create>
			</soap:Body>
		</soap:Envelope>
		</cfoutput></cfsavecontent>
		
		<cfhttp url="http://api.createsend.com/api/api.asmx" method="post" result="apiResult">
			<cfhttpparam type="header" name="SOAPAction" value="http://api.createsend.com/api/Campaign.Create" />
			<cfhttpparam type="header" name="accept-encoding" value="no-compression" />
			<cfhttpparam type="xml" value="#trim(szSoapPacket)#" />
		</cfhttp>
		
		<cfif find("200",apiResult.statusCode)>
			<cfscript>
			apiResult = xmlParse(apiResult.fileContent);
			apiResult = xmlSearch(apiResult,"//*[local-name()='Campaign.CreateResult']");
			returnStruct['CampaignID'] = apiResult[1].xmlText;
			if (returnStruct.CampaignID eq ''){
				returnStruct['errorCode'] = apiResult[1].Code.xmlText;
				returnStruct['errorMessage'] = apiResult[1].Message.xmlText;
				if (returnStruct.errorCode EQ 0){
					returnStruct['blnSuccess'] = 1;
				} else {
					returnStruct['blnSuccess'] = 0;
				}
			} else {
				returnStruct['blnSuccess'] = 1;
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
	
	<!--- DeleteCampaign(CampaignID) --->
	<cffunction name="DeleteCampaign" access="public" output="false" returntype="struct">
		
		<cfargument name="CampaignID" type="string" required="yes">
		
		<cfscript>
		var apiResult = "";
		var returnQuery = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = variables.APIURL & "api/api.asmx/Campaign.Delete?ApiKey=" & variables.APIKey
		& "&CampaignID=" & URLEncodedFormat(arguments.CampaignID);
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
	
	<!--- GetCampaignBounces(CampaignID) --->
	<cffunction name="GetCampaignBounces" access="public" output="false" returntype="struct">
	
		<cfargument name="CampaignID" type="string" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnQuery = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = 
			variables.APIURL & "api/api.asmx/Campaign.GetBounces?ApiKey=" & variables.APIKey
			& "&CampaignID=" & URLEncodedFormat(arguments.CampaignID);
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
				returnQuery = QueryNew("ListID, EmailAddress, BounceType", "VarChar, VarChar, VarChar");
				for (i = 1; i lte intCount; i = i + 1){
					QueryAddRow(returnQuery, 1);
					QuerySetCell(returnQuery, "ListID", apiResult[i].xmlChildren[2].xmlText);
					QuerySetCell(returnQuery, "EmailAddress", apiResult[i].xmlChildren[1].xmlText);
					QuerySetCell(returnQuery, "BounceType", apiResult[i].xmlChildren[3].xmlText);
				}
				// Add query to return structure
				returnStruct['blnSuccess'] = 1;
				returnStruct['returnQuery'] = returnQuery;
			}
		}
		else {
			returnStruct['blnSuccess'] = 0;
			returnStruct['errorCode'] = 0;
			returnStruct['errorMessage'] = "No results found";
		}
		</cfscript>
		
		<cfreturn returnStruct />
		
	</cffunction>
	
	<!--- GetCampaignSummary(CampaignID) --->
	<cffunction name="GetCampaignSummary" access="public" output="false" returntype="struct">
	
		<cfargument name="CampaignID" type="string" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var detailStruct = StructNew();
		var szApiCall = 
			variables.APIURL & "api/api.asmx/Campaign.GetSummary?ApiKey=" & variables.APIKey
			& "&CampaignID=" & URLEncodedFormat(arguments.CampaignID);
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
				detailStruct['Recipients'] = apiResult[1].xmlText;
				detailStruct['TotalOpened'] = apiResult[2].xmlText;
				detailStruct['UniqueOpened'] = apiResult[3].xmlText;
				detailStruct['Clicks'] = apiResult[4].xmlText;
				detailStruct['Unsubscribed'] = apiResult[5].xmlText;
				detailStruct['Bounced'] = apiResult[6].xmlText;
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
	
	<!--- GetCampaignLists(CampaignID) --->	
	<cffunction name="GetCampaignLists" access="public" output="false" returntype="struct">
		
		<cfargument name="CampaignID" type="string" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnQuery = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = 
			variables.APIURL & "api/api.asmx/Campaign.GetLists?ApiKey=" & variables.APIKey
			& "&CampaignID=" & URLEncodedFormat(arguments.CampaignID);
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
				returnQuery = QueryNew("ListID, ListName", "VarChar, VarChar");
				for (i = 1; i lte intCount; i = i + 1){
					QueryAddRow(returnQuery, 1);
					QuerySetCell(returnQuery, "ListID", apiResult[i].xmlChildren[1].xmlText);
					QuerySetCell(returnQuery, "ListName", apiResult[i].xmlChildren[2].xmlText);
				}
				// Add query to return structure
				returnStruct['blnSuccess'] = 1;
				returnStruct['returnQuery'] = returnQuery;
			}
		}
		else {
			returnStruct['blnSuccess'] = 0;
			returnStruct['errorCode'] = 0;
			returnStruct['errorMessage'] = "No results found";
		}
		</cfscript>
		
		<cfreturn returnStruct />
		
	</cffunction>
	
	<!--- GetCampaignOpens(CampaignID) --->
	<cffunction name="GetCampaignOpens" access="public" output="false" returntype="struct">
	
		<cfargument name="CampaignID" type="string" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnQuery = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = 
			variables.APIURL & "api/api.asmx/Campaign.GetOpens?ApiKey=" & variables.APIKey
			& "&CampaignID=" & URLEncodedFormat(arguments.CampaignID);
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
				returnQuery = QueryNew("ListID, EmailAddress, NumberOfOpens", "VarChar, VarChar, VarChar");
				for (i = 1; i lte intCount; i = i + 1){
					QueryAddRow(returnQuery, 1);
					QuerySetCell(returnQuery, "ListID", apiResult[i].xmlChildren[2].xmlText);
					QuerySetCell(returnQuery, "EmailAddress", apiResult[i].xmlChildren[1].xmlText);
					QuerySetCell(returnQuery, "NumberOfOpens", apiResult[i].xmlChildren[3].xmlText);
				}
				// Add query to return structure
				returnStruct['blnSuccess'] = 1;
				returnStruct['returnQuery'] = returnQuery;
			}
		}
		else {
			returnStruct['blnSuccess'] = 0;
			returnStruct['errorCode'] = 0;
			returnStruct['errorMessage'] = "No results found";
		}
		</cfscript>
		
		<cfreturn returnStruct />	
	
	</cffunction>
	
	<!--- GetCampaignSubscriberClicks(CampaignID) --->
	<cffunction name="GetCampaignSubscriberClicks" access="public" output="false" returntype="struct">
	
		<cfargument name="CampaignID" type="string" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var subscribersStruct = StructNew();
		var intCount = "0";
		var linkCount = "0";
		var links = "";
		var szApiCall = 
			variables.APIURL & "api/api.asmx/Campaign.GetSubscriberClicks?ApiKey=" & variables.APIKey
			& "&CampaignID=" & URLEncodedFormat(arguments.CampaignID);
		</cfscript>
		
		<!--- Make HTTP call --->
		<cfhttp method="get" result="apiResult" url="#szApiCall#">
			<cfhttpparam type="header" name="accept-encoding" value="no-compression" />
		</cfhttp>
		
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
					subscribersStruct[i] = StructNew();
					subscribersStruct[i]['EmailAddress'] =  apiResult[1].xmlChildren[1].xmltext;
					subscribersStruct[i]['ListID'] = apiResult[1].xmlChildren[2].xmltext;
					subscribersStruct[i]['Clicks'] = StructNew();
					links = apiResult[i].xmlChildren[3].xmlChildren;
					linkCount = ArrayLen(links);
					for (iLink = 1; iLink lte linkCount; iLink = iLink + 1){
						subscribersStruct[i]['Clicks'][iLink] = StructNew();
						subscribersStruct[i]['Clicks'][iLink]['link'] = links[iLink].xmlChildren[1].xmlText;
						subscribersStruct[i]['Clicks'][iLink]['totalClicks'] = links[iLink].xmlChildren[2].xmlText;
					}
				}
				// Add query to return structure
				returnStruct['subscribers'] = subscribersStruct;
				returnStruct['blnSuccess'] = 1;
			}
		}
		else {
			returnStruct['blnSuccess'] = 0;
			returnStruct['errorCode'] = 0;
			returnStruct['errorMessage'] = "No results found";
		}
		</cfscript>
		
		<cfreturn returnStruct />
	
	</cffunction>
	
	<!--- GetCampaignUnsubscribers(CampaignID) --->
	<cffunction name="GetCampaignUnsubscribers" access="public" output="false" returntype="struct">
		
		<cfargument name="CampaignID" type="string" required="true">
		
		<cfscript>
		var apiResult = "";
		var returnQuery = "";
		var returnStruct = StructNew();
		var intCount = "0";
		var szApiCall = 
			variables.APIURL & "api/api.asmx/Campaign.GetUnsubscribes?ApiKey=" & variables.APIKey
			& "&CampaignID=" & URLEncodedFormat(arguments.CampaignID);
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
				returnQuery = QueryNew("EmailAddress, ListID", "VarChar, VarChar");
				for (i = 1; i lte intCount; i = i + 1){
					QueryAddRow(returnQuery, 1);
					QuerySetCell(returnQuery, "EmailAddress", apiResult[i].xmlChildren[1].xmlText);
					QuerySetCell(returnQuery, "ListID", apiResult[i].xmlChildren[2].xmlText);
				}
				// Add query to return structure
				returnStruct['blnSuccess'] = 1;
				returnStruct['returnQuery'] = returnQuery;
			}
		}
		else {
			returnStruct['blnSuccess'] = 0;
			returnStruct['errorCode'] = 0;
			returnStruct['errorMessage'] = "No results found";
		}
		</cfscript>
		
		<cfreturn returnStruct />
	
	</cffunction>
	
	<!--- SendCampaign(CampaignID,ConfirmationEmail,SendDate) --->
	<cffunction name="SendCampaign" access="public" output="false" returntype="struct">
		
		<cfargument name="CampaignID" type="string" required="true">
		<cfargument name="ConfirmationEmail" type="string" required="true">
		<cfargument name="SendDate" type="string" required="false" default="Immediately">
		
		<cfscript>
		var apiResult = "";
		var returnStruct = StructNew();
		var szApiCall = 
			variables.APIURL & "api/api.asmx/Campaign.Send?ApiKey=" & variables.APIKey & 
			"&CampaignID=" & URLEncodedFormat(arguments.CampaignID) & 
			"&ConfirmationEmail=" & URLEncodedFormat(arguments.ConfirmationEmail)	& 
			"&SendDate=" & URLEncodedFormat(arguments.SendDate);
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
	
</cfcomponent>