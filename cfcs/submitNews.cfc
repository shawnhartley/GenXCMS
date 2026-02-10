<cfscript>
component extends="event" output="no" {
	public struct function submit(
						 	required string headline,
							required string content,
							required string dateSelect,
							string sendTo=application.settings.VarStr('submitNews.sendTo'),
							string sendFrom=application.settings.VarStr('submitNews.sendFrom'),
							string sendSubject=application.settings.VarStr('submitNews.sendSubject'),
							string sendBcc=application.settings.VarStr('submitNews.sendBcc')
							) {
		var email = new Mail();
		var myBody = '';
		var sb = createObject("java", "java.lang.StringBuilder").init();
		var br = '<br />';
		var results = {};
		email.setTo(arguments.sendTo); 
		email.setFrom(arguments.sendFrom); 
		email.setSubject(arguments.sendSubject);
		email.setBcc(arguments.sendBcc);
		email.setReplyTo(session.email);
		email.setType("html");
		
		sb.append('<strong>News Submission from #session.username# at #cgi.HTTP_HOST#</strong>').append(br).append(br);
		sb.append('<b>Headline:</b> ')
			.append(arguments.headline)
			.append(br);
		sb.append('<b>Requested Publish Date:</b> ')
			.append(arguments.dateSelect)
			.append(br);
		sb.append('<b>User:</b> ')
			.append(session.username)
			.append(br);
		sb.append('<b>E-mail:</b> ')
			.append('<a href="mailto:').append(session.email).append('">')
			.append(session.email)
			.append('</a>')
			.append(br);
		sb.append('<b>Submitted:</b> ')
			.append(DateFormat(NOW(), 'yyyy/mm/dd') & ' at ' & TimeFormat(NOW(), 'HH:MM:ss TT'))
			.append(br);
		sb.append(br);
		sb.append('============== BEGIN CONTENT ====================').append(br);
		sb.append(br)
			.append(arguments.content)
			.append(br);
		sb.append('=================== END =========================').append(br);
		
		try {
			results.post = record(sb.toString());
			email.send(body=sb.toString());
			results.mailed = true;
		} catch (Any e) {
			results.catch = e;
			rethrow;
		}
		return results;
	}
	private function record(required string message) {
		var r = new http();
		var result = {};
		if( NOT Len(application.settings.VarStr('submitNews.recordURL'))) return;
		r.setURL(application.settings.VarStr('submitNews.recordURL'));
		r.setmethod('post');
		r.setThrowOnError(true);
		r.addParam(type="header", name="Accept-Encoding", value="deflate;q=0");
		r.addParam(type="formfield",name="message",value= arguments.message);
		r.addParam(type="formfield",name="submitNews",value= true);
		r.addParam(type="formfield",name="source",value=cgi.HTTP_HOST);
		r.addParam(type="formfield",name="user",value=session.username);
		return r.send().getPrefix();
	}
}
</cfscript>