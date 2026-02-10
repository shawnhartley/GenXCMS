<cfparam name="session.landingThankyou" default="home">

<cfif not isnumeric(event.slug) OR event.parent neq "landings">
	<cflocation url="http://#cgi.SERVER_NAME#/home" addtoken="no">
</cfif>

<cfset landingAssets = application.datamgr.getRecords("landings", {IDLANDINGS=event.slug})>

<cfif not landingAssets.RecordCount>
	<cflocation url="http://#cgi.SERVER_NAME#/home" addtoken="no">
</cfif>

<cfif landingAssets.landingThankyou neq ''>
	<cfset session.landingThankyou = landingAssets.landingThankyou>
<cfelse>
	<cfset session.landingThankyou = 'home'>
</cfif>

<cfparam name="results.success" type="boolean" default="0">
<cfparam name="results.cfcatch" type="struct" default="#StructNew()#">
<cfparam name="form.name" default="">
<cfparam name="form.nameFirst" default="">
<cfparam name="form.email" default="">
<cfparam name="form.phone" default="">
<cfparam name="form.message" default="LP submission">
<cfparam name="form.date" default="#now()#">
<cfparam name="form.formType" default="LP">
<cfparam name="form.companyName" default="">
<cfparam name="form.title" default="">
<cfparam name="form.howDidYouHear" default="">
<cfparam name="form.personOrCompanyThatReferred" default="">
<cfparam name="form.dateCreated" default="#now()#">

<!doctype html>
<html class="no-js" lang="en">
<head>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0" />
	<cfoutput>
		<!--- General Meta Setup --->
		<title>#landingAssets.landingName# | #event.seotitle#</title>
		<meta name="description" content="#event.description#" />
		<meta name="keywords" content="#event.keywords#" />
	</cfoutput>	
	
	<!--- CMS Meta Data (page level) --->
	<cfinclude template="metaTags.cfm">
	
	<!--- CSS / Modernizr --->
	<link href="/css/main.css" rel="stylesheet" type="text/css" />
	<!--[if lt IE 9]><link type="text/css" rel="stylesheet" href="/css/ie8-and-less.css" /><![endif]-->
	<link rel="shortcut icon" type="image/x-icon" href="/favicon.ico">
	<script src="/js/modernizr.js"></script> 
	
</head>


<!---
	<cfif landingAssets.landingtype EQ 1>
		formLeft
	<cfelseif landingAssets.landingtype EQ 2>
		centered
	<cfelse>
		formRight
	</cfif>
--->

<body class="landings">
 	
 	
 	<div id="header">
    	<div class="row">
    		<div id="landingLogo" class="small-6 small-centered medium-4 medium-uncentered large-4 columns">
    			<cfif landingAssets.leadLogo NEQ ''>
    				<cfoutput><img src="/uploads/landings/#landingAssets.leadLogo#" alt="#event.seotitle#" /></cfoutput>
				<cfelse>
					<img src="http://www.placehold.it/150x60&text=Logo" alt="#settings.Var("siteTitle")#" />
				</cfif>
			</div><!--/landingLogo-->
        </div><!--/row-->
    </div><!--/header-->
    


	<div id="content">
		<div class="row">
        
	        <!--- Form Submission Settings --->
	        <cfif structKeyExists(form,"createContact")>
	            <cfset contact = createObject("component", application.dotroot & "cfcs.contact").init()>
	            <cfset results = contact.insertContact(argumentcollection= form)>
	            <cfif results.success >
	                <cflocation url="#session.landingThankyou#" addtoken="no">
	            </cfif>
	        </cfif>
	        
	        <cfif NOT results.success >
	            
	            <cfoutput>
	                <cfif structKeyExists(form,"createContact")>
	                	<div class="row">
		                    <p class="error">We're sorry, there were errors in your submission. Please try again.</p>
		                    <p class="warning">#results.message#</p>
	                	</div><!--/row-->
	                </cfif>
	                                               
	                              
					<div id="copy" class="<cfif landingAssets.landingtype EQ 1>medium-8 medium-push-4<cfelseif landingAssets.landingtype EQ 2>medium-12<cfelse>medium-8</cfif> columns">
						<h1 class="headline">#landingAssets.headline#</h1>
						
						<cfif landingAssets.landingImage NEQ ''>
							<img id="landingImage" src="/uploads/landings/#landingAssets.landingImage#" >
						</cfif>
						
						<div class="subhead">#landingAssets.subhead#</div>
						
						<div class="superquote">#landingAssets.superquote#</div>
						
						<div class="toutlineSection">
							<cfif landingAssets.toutline1 NEQ ''>
								<div class="tout1 <cfif landingAssets.toutline3 EQ '' AND landingAssets.toutline2 EQ ''>medium-12<cfelse>medium-4</cfif> columns">
									<div class="panel">#landingAssets.toutline1#</div>
								</div>
							</cfif>
							<cfif landingAssets.toutline2 NEQ ''>
								<div class="tout1 medium-4 columns">
									<div class="panel">#landingAssets.toutline2#</div>
								</div>
							</cfif>
							<cfif landingAssets.toutline3 NEQ ''>
								<div class="tout1 medium-4 columns">
									<div class="panel">#landingAssets.toutline3#</div>
								</div>
							</cfif>
						</div><!--/toutlineSection-->
					</div><!--/copy-->
	                
	                
					<div id="landingForm" class="<cfif landingAssets.landingtype EQ 1>medium-pull-8 medium-4<cfelseif landingAssets.landingtype EQ 2>medium-10 medium-centered<cfelse>rightForm medium-4</cfif> columns">
						<form action="" method="post" data-abide>
							<div class="row">
								<!-- BOTS ARE DUMB -->
									<div class="nameFirst">
										<label for="nameFirst">First Name
											<input id="nameFirst" type="input" name="nameFirst" class="nameFirst" value="#form.nameFirst#">
										</label>
									</div>
								<!-- /BOTS ARE DUMB -->
								<input name="formType" value="<cfoutput>LP - #landingAssets.landingName#</cfoutput>" type="hidden" /> 
								
								<div class="large-12 columns">
									<label for="name">Name <span>*</span>
										<input id="name" type="text" name="name" value="#form.name#" title="Please enter your name." required />
									</label>
									<small class="error">Name is required.</small>
								</div><!--/large12-->
							
								<div class="large-12 columns">
									<label for="company">Company <span>*</span> 
										<input id="company" type="text" name="companyName" value="#form.companyName#" title="Please enter your company." required />
									</label>
									<small class="error">Company Name is required.</small>
								</div><!--/large12-->
								
								<div class="large-12 columns">
									<label for="title">Title <span>*</span>
										<input id="title" type="text" name="title" value="#form.title#" title="Please enter your title." required />
										<small class="error">Your title is required.</small>
									</label>
								</div><!--/large12-->
								
								<div class="large-12 columns">
									<label for="email">Email <span>*</span>
										<input id="email" type="email" name="email" value="#form.email#"  title="Please enter your email address." required />
										<small class="error">Your email is required.</small>
									</label>
								</div><!--/large12-->
								
								<div class="large-12 columns">
									<label for="phone">Phone <span>*</span>
										<input id="phone" type="tel" name="phone" value="#form.phone#" title="Please enter your phone number." required />
										<small class="error">Your phone number is required.</small>
									</label>
								</div><!--/large12-->
								
								<div class="large-12 columns">
									<label for="howDidYouHear"> How did you hear about us:</label>
									<select name="howDidYouHear">
										<option value="">Pick one</option>
										<option value="Email">Email</option>
										<option value="Direct Mail">Direct Mail</option>
										<option value="Publication">Publication</option>
										<option value="Online">Online</option>
										<option value="Referral">Referral</option>
									</select>
								</div><!--/large12-->
								
								<div class="large-12 columns">
									<label for="personOrCompanyThatReferred"> Person or company that referred you?</label>
									<input id="personOrCompanyThatReferred" type="text" name="personOrCompanyThatReferred" value="#form.personOrCompanyThatReferred#" title="Person or company that referred.">
								</div><!--/large12-->
								
								<div class="large-12 columns">
									<label for="Message">Message</label>
									<textarea id="message" type="text" name="message" value="#form.message#" title="Comments"></textarea>
								</div><!--/large12-->
								
								<div class="<cfif landingAssets.landingtype EQ 2>medium-6 left<cfelse> medium-12</cfif> columns">
									<button type="submit" name="createContact" class="expand">Send Message</button>
								</div><!--/large12-->
								
							</div><!--/row-->
						</form><!--/form-->
					</div><!--/landingForm-->
	                
	                <div class="legal medium-12 columns" style="text-align:center">
	                	<hr>
	                    <p>privacy policy - terms and conditions</p>
	                </div>
	                
	            </cfoutput>
	        </cfif>
        </div><!--/row-->
    </div><!--/content-->


	<!--- For Outdated Browsers --->
	<cfinclude template="outdated-browser.cfm">

	<cfif isDefined("url.debug") OR settings.Var('debug_level') AND cgi.REMOTE_ADDR eq '72.214.233.126'>
        <cfdump var="#variables#" metainfo="yes" label="Variables" expand="no">
		<cfdump var="#session#" label="Session" expand="no">
		<cfdump var="#cgi#" label="CGI" expand="no">
		<cfdump var="#application#" label="Application" expand="no">
	</cfif>

	<!---
		=================== IMPORTANT FOUNDATION JAVASCRIPT NOTICE: ===================
		If you're wanting to add more tools or features from Foundation then please be
		sure to copy out the code from the corresponding .js file and past it into the
		bottom of the 'c3d-foundation-with-tools.js' file, by manually maintaining a
		single .js file we can cut down on HTTP calls and currate unused javascript
		from running on pages where it is unneeded.
	--->	
	<script src="/js/jquery.js"></script>
	<script src="/js/c3d-foundation-with-tools.js"></script>
	<script>$(document).foundation();</script>
	<script src="/js/common.js"></script>
	<cfoutput>
		#helpers.googleAnalytics()#
		#helpers.tracking_code()#
		<!-- generated at #NOW()# -->
	</cfoutput>	
	
</body>
</html>