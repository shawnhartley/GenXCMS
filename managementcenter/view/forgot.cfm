<!DOCTYPE html>
<html>
<head>

<title>Management Center</title>
<!-- Meta data start -->
<meta name="author" content="Corporate 3 Design" />
<meta name="description" content="Corporate 3 Design Management Center" />
<meta name="keywords" content="Corporate 3 Design" />
<!-- Meta data end -->

<cfoutput>
<!-- Load CSS -->
<link href="#application.slashroot#managementcenter/css/login.css" rel="stylesheet" type="text/css" />

<!-- Load Javascript -->
<script src="#application.slashroot#managementcenter/js/jquery.tools.min.js" type="text/javascript"></script>

</cfoutput>


</head>

<body>

<cfoutput>
    <!-- Begin Wrapper BG -->
    <div id="wrapper_bg">
    		<div id="wrapper">
            	<div id="logo"><a href="#BuildURL(event='login')#"></a></div>
                <cfif structKeyExists(form, 'username')>
				
				<cfset event.sendTemporaryPassword(form.username)>
				<p>An email has been sent with your temporary password.</p>
				<p><a href="#BuildURL(event='manage')#">Login Now</a></p>
				<cfelse>
				<p class="">Forget your password?</p>
                <form action="#BuildURL(event='forgot')#" class="forgetpasswordinfo"><p>Enter your email address to reset your password:<br>
					<input type="text" name="username" /><br>
					<input type="submit" value="Reset Password">
				</p></form>
				</cfif>
			</div>
            <!-- End Content Wrapper -->
    </div>
    <!-- End Wrapper BG -->

</cfoutput>