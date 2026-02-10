<cfscript>
component {
	variables.varMask = '(xxx) xxx-xxxx';
	logger = application.logbox.getRootLogger();

	public Event function init() {
		variables.componentname = getMetaData(this).fullname;
		variables.moduleList = application.settings.var('modules');
		logger = application.logbox.getLogger(this);
		return this;
	}
	
	public string function runContentFilters(required string content) {
		var i = 1;
		var fn = '';
		if(StructKeyExists(application, 'ContentFilters')) {
			for(i=1; i LTE ArrayLen(application.ContentFilters); i++) {
				fn = application.ContentFilters[i];
				arguments.content = fn(arguments.content);
			}
		}
		return arguments.content;
	}
	public string function stripDoubleLineBreaks( required string content ) {
		arguments.content = REReplace(arguments.content, '<br \/>(\s*)<br \/>', '</p><p>', 'ALL');
		return content;
	}
	public string function stripEmptyParas(required string content) {
		arguments.content = REReplace(arguments.content, '<p[^>]*>(\s|(&nbsp;))*<\/p>', '', 'ALL');
		return content;
	}
	
	
	/**
	* Strips HTML tags from a string
	*
	* @param instring (required)
	* @param truncate (Set to non-zero to truncate the result string)
	* @return Returns a string.
	*/
	public string function stripHTML(required string inString, numeric truncate = 0) {
		var outString = ReReplace(inString, "<[^>]*>", "", "all");
		if( arguments.truncate NEQ 0 AND len(outString) GT arguments.truncate) {
			return Left(outString, arguments.truncate) & '...';
		}
		return outString;
	}
	
	/**
	* Checks a capability string against a logged-in-user's permissions table
	*
	* @param capability (required)
	* @return Returns a boolean.
	* @author Lane Roberts
	* @version 1, Feb 8, 2011
	*/
	public boolean function can(required string capability) {
		var component = arraylen(arguments) GTE 2 ? arguments[2] : variables.componentname;
		if(NOT ListFindNoCase('usergroups', url.event) AND NOT ListFindNoCase(variables.moduleList, Replace(component, 'cfcs.', ''))) { return false; }
		if(session.usergroupid EQ 1) { return true; }
		if(StructKeyExists(session, 'permissions') AND (session.permissions['capability'].indexOf(component & '.' & capability) + 1)) {
			return true;
		}
		return false;
	}
	/**
	* Allows you to specify the mask you want added to your phone number.
	* v2 - code optimized by Ray Camden
	* v3.01
	* v3.02 added code for single digit phone numbers from John Whish
	*
	* @param varInput      Phone number to be formatted. (Required)
	* @param varMask      Mask to use for formatting. x represents a digit. (Required)
	* @return Returns a string.
	* @author Derrick Rapley (adrapley@rapleyzone.com)
	* @version 3, May 9, 2009
	*/
	public string function phoneFormat(required string varInput, string varMask = variables.varMask) {
		var curPosition = "";
		var i = "";
		var newFormat = trim(ReReplace(varInput, "[^[:digit:]]", "", "all"));
		var startpattern = ReReplace(ListFirst(varMask, "- "), "[^x]", "", "all");
		
		
		if (Len(newFormat) gte Len(startpattern)) {
			varInput = trim(varInput);
			newFormat = " " & reReplace(varInput,"[^[:digit:]]","","all");
			newFormat = reverse(newFormat);
			varmask = reverse(varmask);
			for (i=1; i lte len(trim(varmask)); i=i+1) {
				curPosition = mid(varMask,i,1);
				if(curPosition neq "x") newFormat = insert(curPosition,newFormat, i-1) & " ";
			}
			newFormat = reverse(newFormat);
			varmask = reverse(varmask);
		}
		return trim(newFormat);
	}
	
	/**
	* Title cases all elements in a list.
	*
	* @param list      List to modify. (Required)
	* @param delimiters      Delimiters to use. Defaults to a space. (Optional)
	* @return Returns a string.
	* @author Adrian Lynch (adrian.l@thoughtbubble.net)
	* @version 1, November 3, 2003
	*/
	public string function TitleCaseList( required string list, string delimiters = ' ' ) {
	
		var returnString = "";
		var isFirstLetter = true;
		// Loop through each character in list
		for ( i = 1; i LTE Len( list ); i = i + 1 ) {
			// Check if character is a delimiter
			if ( Find( Mid(list, i, 1 ), delimiters, 1 ) ) {
				//    Add character to variable returnString unchanged
				returnString = returnString & Mid(list, i, 1 );
				isFirstLetter = true;
			} else {
				if ( isFirstLetter ) {
					// Uppercase
					 returnString = returnString & UCase(Mid(list, i, 1 ) );
					isFirstLetter = false;
				} else {
					
					// Lowercase
					returnString = returnString & LCase(Mid(list, i, 1 ) );
				}
			}
		}
		return returnString;
	}
	
	/**
	* This function takes URLs in a text string and turns them into links.
	* Version 2 by Lucas Sherwood, lucas@thebitbucket.net.
	* Version 3 Updated to allow for ;
	*
	* @param string      Text to parse. (Required)
	* @param target      Optional target for links. Defaults to "". (Optional)
	* @param paragraph      Optionally add paragraphFormat to returned string. (Optional)
	* @return Returns a string.
	* @author Joel Mueller (lucas@thebitbucket.netjmueller@swiftk.com)
	* @version 3, August 11, 2004
	*/
	public string function ActivateURL(required string String, string target = '', boolean paragraph = false) {
		var nextMatch = 1;
		var objMatch = "";
		var outstring = "";
		var thisURL = "";
		var thisLink = "";
		//var    target = IIf(arrayLen(arguments) gte 2, "arguments[2]", DE(""));
		//var paragraph = IIf(arrayLen(arguments) gte 3, "arguments[3]", DE("false"));
		
		do {
			objMatch = REFindNoCase("(((https?:|ftp:|gopher:)\/\/)|(www\.|ftp\.))[-[:alnum:]\?%,\.\/&##!;@:=\+~_]+[A-Za-z0-9\/]", string, nextMatch, true);
			if (objMatch.pos[1] GT nextMatch OR objMatch.pos[1] EQ nextMatch) {
				outString = outString & Mid(String, nextMatch, objMatch.pos[1] - nextMatch);
			} else {
				outString = outString & Mid(String, nextMatch, Len(string));
			}
			nextMatch = objMatch.pos[1] + objMatch.len[1];
			if (ArrayLen(objMatch.pos) GT 1) {
				// If the preceding character is an @, assume this is an e-mail address
				// (for addresses like admin@ftp.cdrom.com)
				if (Compare(Mid(String, Max(objMatch.pos[1] - 1, 1), 1), "@") NEQ 0) {
					thisURL = Mid(String, objMatch.pos[1], objMatch.len[1]);
					thisLink = "<A HREF=""";
					switch (LCase(Mid(String, objMatch.pos[2], objMatch.len[2]))) {
						case "www.": {
							thisLink = thisLink & "http://";
							break;
						}
						case "ftp.": {
							thisLink = thisLink & "ftp://";
							break;
						}
					}
					thisLink = thisLink & thisURL & """";
					if (Len(Target) GT 0) {
						thisLink = thisLink & " TARGET=""" & Target & """";
					}
					thisLink = thisLink & ">" & thisURL & "</A>";
					outString = outString & thisLink;
					// String = Replace(String, thisURL, thisLink);
					// nextMatch = nextMatch + Len(thisURL);
				} else {
					outString = outString & Mid(String, objMatch.pos[1], objMatch.len[1]);
				}
			}
		} while (nextMatch GT 0);
			
		// Now turn e-mail addresses into mailto: links.
		outString = REReplace(outString, "([[:alnum:]_\.\-]+@([[:alnum:]_\.\-]+\.)+[[:alpha:]]{2,4})", "<A HREF=""mailto:\1"">\1</A>", "ALL");
			
		if (paragraph) {
			outString = ParagraphFormat(outString);
		}
		return outString;
	}
	
	/**
	* Convert a date in ISO 8601 format to an ODBC datetime.
	*
	* @param ISO8601dateString      The ISO8601 date string. (Required)
	* @param targetZoneOffset      The timezone offset. (Required)
	* @return Returns a datetime.
	* @author David Satz (david_satz@hyperion.com)
	* @version 1, September 28, 2004
	*/
	public string function DateConvertISO8601(required string ISO8601dateString, required numeric targetZoneOffset) {
		var rawDatetime = left(ISO8601dateString,10) & " " & mid(ISO8601dateString,12,8);
		
		// adjust offset based on offset given in date string
		if (uCase(mid(ISO8601dateString,20,1)) neq "Z")
			targetZoneOffset = targetZoneOffset - val(mid(ISO8601dateString,20,3)) ;
		
		return DateAdd("h", targetZoneOffset, CreateODBCDateTime(rawDatetime));
	
	}
	
	public string function getArg(string name) {
		if(structKeyExists(url, name)) {
			return url[name];
		}
		if(structKeyExists(form, name)) {
			return form[name];
		}
		return '';
	}
	
	public string function getslugfromtitle (string title="") {
		title = replaceNoCase(title,"&amp;","and","all"); //replace &amp;
		title = replaceNoCase(title, "&trade;", '','ALL'); // remove &trade;
		title = replaceNoCase(title,"&","and","all"); //replace &
		title = replaceNoCase(title,"'","","all"); //remove apostrophe
		title = reReplaceNoCase(trim(title),"[^a-zA-Z0-9]","-","ALL");
		title = reReplaceNoCase(title,"[\-\-]+","-","all"); // collapse double dashes
		//Remove trailing dashes
		if(right(title,1) eq "-") {
			title = left(title,len(title) - 1);
		}
		if(left(title,1) eq "-") {
			title = right(title,len(title) - 1);
		}    
		return lcase(title);
	}
}
</cfscript>