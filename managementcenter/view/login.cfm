<cfparam name="url.redirect" default="">
<cfif IsDefined("Form.submit")>
	<cfset validpwd = application.helpers.handleLoginAttempt(username=form.username, password = form.password, redirect=form.redirect)>

<cfelse>
	<cfset validpwd = True>
</cfif>

<cfcookie name="mclogin" value="" expires="now" />

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



<script type="text/javascript">
$(document).ready(function(){

	//hide forget forgetpassword div
	$(".forgetpasswordinfo").hide();

	//toggle show/hide forgetpassword div
	$(".forgetpassword").click(function(){
		$(".forgetpasswordinfo").slideToggle("fast");
	});

});
</script>

</head>

<body>


    <!-- Begin Wrapper BG -->
    <div id="wrapper_bg">
    		<div id="wrapper">
            	<div id="corporate3design"><br><br><br><br><br><br><br><br><br><br><br>
                <cfif NOT validpwd><div class="error">Incorrect user ID or password</div></cfif>
				<cfif structKeyExists(url, 'msg') AND url.msg EQ 'timeout'>
					<div class="error">You have been logged out due to inactivity. Please login again.</div>
				</cfif>
                <form name="loginform" id="loginform" action="<cfoutput>#BuildURL(event='login')#</cfoutput>" method="post">
                <p>
                    <label>Username:<br />
                    <input type="text" name="username" id="user_login" class="input" autofocus value="<cfif structKeyExists(cookie, "mclogin")><cfoutput>#Cookie.mclogin#</cfoutput></cfif>" size="20" tabindex="10" /></label>
                </p>
                <p>
                    <label>Password:<br />
                    <input type="password" name="password" id="user_pass" class="input" value="" size="20" tabindex="20" /></label>
                </p>
                <p class="submit"><cfoutput><input type="hidden" name="redirect" value="#url.redirect#" /></cfoutput>
                    <button type="submit" name="submit" tabindex="100" title="Login" value="Login">Login</button>
                </p>
				</form>
				<p class="forgetpassword">Forget your password?</p>
                <cfoutput><form action="#BuildURL(event='forgot')#" class="forgetpasswordinfo" method="post"><p>Enter your email address to reset your password:<br>
					<input type="text" name="username" /><br>
					<input type="submit" name="submit" value="Reset Password">
				</p></form></cfoutput>

            

            </div>
            <!-- End Content Wrapper -->
    </div>
    <!-- End Wrapper BG -->

