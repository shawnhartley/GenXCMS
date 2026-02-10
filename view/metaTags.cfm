<cfoutput>
    <!--Site Validation keys-->
    <cfif #settings.Var("app.googlesiteverification")# NEQ ""><meta name="google-site-verification" content="#settings.Var("app.googlesiteverification")#" /></cfif>
    <cfif #settings.Var("app.msvalidate")# NEQ ""><meta name="msvalidate.01" content="#settings.Var("app.msvalidate")#" /></cfif>
    <cfif #settings.Var("app.yahookey")# NEQ ""><meta name="y_key" content="#settings.Var("app.yahookey")#" /></cfif>
    <cfif #settings.Var("app.googleplusprofile")# NEQ ""><link href="#settings.Var("app.googleplusprofile")#" rel="publisher" /></cfif>


   	<!-- Facebook Open Graph -->
    <cfif isdefined("event.fbTwitterImage") AND  event.fbTwitterImage neq ''>
    	<meta property="og:image" content="#event.fbTwitterImage#" />
	</cfif>
    <cfif isdefined("event.fbDescription") AND event.fbDescription neq ''>
    	<meta property="og:description" content="#event.fbDescription#" />
	</cfif>
    <cfif isdefined("event.fbTitle") AND  event.fbTitle neq ''>
    	<meta property="og:title" content="#event.fbTitle#" />
	</cfif>
	
	<meta property="og:type" content="article" /> 
	
	<cfif isdefined("event.section") AND event.fbTitle neq ''>
		<meta property="article:section" content="#event.section#">
	</cfif>
	
	<meta property="og:url"  content="http://#cgi.server_name#/#replacenocase(event.path,',','/','all')#" />
	<meta property="og:site_name" content="#settings.varStr('siteTitle')#" />
  
  
  
	<!--- Twitter Cards --->
	<meta name="twitter:card" content="Summary" />
	<meta name="twitter:url" content="http://#cgi.server_name#/#replacenocase(event.path,',','/','all')#" />
	
    <cfif isdefined("event.twitterTitle") AND  event.twitterTitle neq ''>
    	<meta name="twitter:title" content="#event.twitterTitle#" />
	</cfif>
    
    <meta name="twitter:description" content="Find this and more at http://#cgi.server_name#" />
    
    <cfif isdefined("event.fbTwitterImage") AND  event.fbTwitterImage neq ''>
    	<meta name="twitter:image" content="#event.fbTwitterImage#" />
	</cfif>
    
    <meta name="twitter:site" content="#settings.varStr('TwitterHandle')#" />
    
    
    
    <!--- General or Misc  --->
    <!--- Sets a custom color for Android: Lolipop when browsing tabs --->
	<meta name="theme-color" content="##41b6e6">
</cfoutput>
