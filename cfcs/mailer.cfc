<cfscript>
component {
	private function send(required string to, required string from, required string subject, required string body, required string secretID, required string name) {
		var email = new Mail();
		arguments.body = wrapInTemplate(arguments.to, arguments.subject, arguments.body, arguments.secretId, arguments.name);
		
		email.setTo(arguments.to); 
		email.setFrom(arguments.from); 
		email.setSubject(arguments.subject); 
		email.setType("html");
		email.send(body=arguments.body);

	}
	private function wrapInTemplate(required string to, required string subject, required string body, required string secretId, required string name) {
		var result = fileRead(ExpandPath('/email/template.inc.html'));
		
		result = replace(result,'{BODY}',		arguments.body, 'ALL'); // Do BODY first so we can use placeholders in the body.
		result = replace(result,'{OPTIONS}',	'<p align="center"><small>Don&rsquo;t want these messages any more? <strong><a href="{PREFERENCES}">Manage your preferences</a></strong> or <strong><a href="{UNSUBSCRIBE}">Unsubscribe</a></strong><br /></small></p>', 'ALL');
		result = replace(result,'{NAME}',		arguments.name, 'ALL');
		result = replace(result,'{EMAIL}',		arguments.to, 'ALL');
		result = replace(result,'{SUBJECT}',	arguments.subject, 'ALL');
		result = replace(result,'{TWITTER}',	application.settings.urls.twitter, 'ALL');
		result = replace(result,'{FACEBOOK}',	application.settings.urls.facebook, 'ALL');
		result = replace(result,'{UNSUBSCRIBE}',HTMLEditFormat('http://#cgi.HTTP_HOST#/signup/unsubscribe/?email=#URLEncodedFormat(arguments.to)#&#arguments.secretId#'),'ALL');
		result = replace(result,'{PREFERENCES}',HTMLEditFormat('http://#cgi.HTTP_HOST#/signup/preferences/?email=#URLEncodedFormat(arguments.to)#&#arguments.secretId#'),'ALL');
		result = replace(result,'{DATE}',		DateFormat(NOW(), 'mm.dd.yy'), 'ALL');
		result = replace(result,'{COPYRIGHT}',	DateFormat(NOW(), 'yyyy'), 'ALL');
		result = replace(result,'{CONTACT}',	'contact@#cgi.HTTP_HOST#');
		
		// Make sure images are domain-relative
		result = replace(result, 'src="/', 'src="http://#cgi.HTTP_HOST#/', 'ALL');
		return result;
	}
}
</cfscript>