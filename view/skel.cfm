<!doctype html>
<html class="no-js" lang="en">
<head>
	<meta charset="utf-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0" />
	<cfoutput>
		<!--- General Meta Setup ---> 
		<title>#event.seotitle#</title>
		<meta name="author" content="#event.seotitle#" />
		<meta name="web_author" content="Corporate 3 Design" />
		<meta name="description" content="#event.description#" />
		<meta name="keywords" content="#event.keywords#" />
	</cfoutput>	
	<!--- CMS Meta Data (page level) --->
	<cfinclude template="metaTags.cfm">
	
	<!--- CSS / Modernizr --->
	<link href="/css/app.css" rel="stylesheet" type="text/css" />
<!--- 	<link rel="stylesheet" href="https://cdn.jsdelivr.net/foundation/6.2.3/foundation.min.css"> --->
	<!--[if lt IE 9]><link type="text/css" rel="stylesheet" href="/css/ie8-and-less.css" /><![endif]-->
	<script src="/js/scripts/modernizr.js"></script> 
	<link rel="shortcut icon" type="image/x-icon" href="/favicon.ico">
</head>



<body class="<cfoutput>#event.section#</cfoutput>">
	
	<!-- SVG library -->
	<!--- Note that including these as part of the main page means both that they are sent as part of every page and are not cached. --->
	<!--- TODO: add JS caching --->
	<cfinclude template="/images/symbols.svg">
	
	<a id="top"></a>

	<div class="off-canvas-wrapper" data-offcanvas>
		<div class="off-canvas-wrapper-inner" data-off-canvas-wrapper>		
				 
	    	<!--- 100% of Website content including the footer --->				
		    <section class="off-canvas-content" data-off-canvas-content>
			    
			    <!--- 	Off-canvas section / Mobile Nav  --->
			    <cfinclude template="/view/elements/offcanvas.cfm">
			    
				<!--- 	Mobile and Tablet/Desktop Header  --->
				<cfinclude template="/view/elements/header.cfm">
			
				<!--- 	Slider/Hero above main section  --->
				<cfinclude template="/view/elements/promo.cfm">
				
				<!--- 	Main section, contains sidebar and Copy/Managed Content--->
				<cfinclude template="/view/elements/content.cfm">
				
				<!--- 	Footer  --->
				<cfinclude template="/view/elements/footer.cfm">
				
				<!--- For Outdated Browsers --->
				<cfinclude template="/view/outdated-browser.cfm">

		    </section><!-- /off-canvas-content -->
		</div><!--/off-canvas-wrapper-inner-->
	</div><!--/off-canvas-wrapper-->




	<cfif isDefined("url.debug") OR settings.Var('debug_level') AND cgi.REMOTE_ADDR eq '72.214.233.126'>
        <cfdump var="#variables#" metainfo="yes" label="Variables" expand="no">
		<cfdump var="#session#" label="Session" expand="no">
		<cfdump var="#cgi#" label="CGI" expand="no">
		<cfdump var="#application#" label="Application" expand="no">
		<cfdump var="#request#" label="request" expand="no">
	</cfif>
	
	<script src="/js/scripts/jquery.js"></script>
<!--- 	<script src="https://cdn.jsdelivr.net/foundation/6.2.3/foundation.min.js"></script> --->
	<script src="/js/min/foundation.min.js"></script>

	<script>$(document).foundation();</script>
	<script src="/js/scripts/common.js"></script>
	<cfoutput>
		#helpers.googleAnalytics()#
		#helpers.tracking_code()#
		<!-- generated at #NOW()# -->
	</cfoutput>	
	
	<cfif event.section EQ 'locations'>
		<script src="http://www.google.com/jsapi"></script>
		<script src="/js/locations.js"></script>
		<!--- <script src="/js/markerclusterer.js"></script> --->
	</cfif>
	
	<cfif event.section EQ 'home'>
	<!--- quick navigation to managementcenter --->
	<!--- Note that if user keyboard input is required on the home page, this should be removed --->
		<script>
			var user_keys = [],
			    super_secret_code = '77,67';
			document.onkeydown = function(e){
			  user_keys.push(e.keyCode)
			
			  if (user_keys.toString().indexOf(super_secret_code) >= 0) {
			    user_keys = [];
			    window.location = '/managementcenter/'
			  }
			}
		</script>
	</cfif>

	<!--- If you want Flexslider
	<script src="/js/jquery.flexslider.js"></script>
	<script>
		$(window).load(function(){
	    	$('.flexslider').flexslider({});
		});
	</script>
	--->

</body>
</html>