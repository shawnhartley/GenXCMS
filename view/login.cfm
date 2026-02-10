<cfparam name="url.redirect" default="/home/">
<cfparam name="form.username" default="">
<cfparam name="validpwd" default="true">
<cfif form.username NEQ ''><!--- this is a login attempt --->
	<cfset validpwd = application.helpers.handleLoginAttempt(username = form.username, password = form.password)>
</cfif>
<cfscript>
	event.title = 'Login Required';
	event.seotitle = 'Login Required' & ' ' & settings.var('titleSuffix');
	StructDelete(event, "content");
	event.content.contentright = '';
</cfscript>

<h2>This page requires you to login.</h2>
<cfoutput>
	<form action="" method="post" data-abide>
		<div class="row">
			<div class="large-12 columns">
				<label for="loginusername">Username <span>*</span>
					<input id="username" type="text" name="username" value="#form.username#" title="Username" required />
				</label>
				<small class="error">Please enter your username</small>
			</div><!--/large12-->

			<div class="large-12 columns">
				<label for="loginpassword">Password <span>*</span>
					<input id="loginpassword" type="password" name="password" title="Password" required />
				</label>			
				<small class="error">Please enter your password</small>
			</div><!--/large12-->

			<div class="left large-6 columns">
				<input type="hidden" name="redirect" value="#url.redirect#">
				<button type="submit" class="expand">Login</button>
			</div><!--/large6-->

		</div><!--/row-->
	</form>
</cfoutput>