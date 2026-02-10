<cfparam name="url.event" default="manage">

<cfparam name="request.event" default="#url.event#">
<cfset request.manage = true>

<cfif url.event EQ "logout">
	<cfif structKeyExists(session, 'username')><cfset application.logbox.getLogger('cfcs.logins.logout').info('User #session.username# (#session.userid#) logged out')></cfif>
	<cflock scope="Session" type="Exclusive" timeout="10">
		<cfset StructClear(Session)>
	</cflock>
	<cfif StructKeyExists(url, 'msg')>
		<cfset args = 'msg=' & url.msg>
	<cfelse>
		<cfset args = ''>
	</cfif>
	<cflocation URL="#application.helpers.BuildURL(event='login', args=args, encode=false)#" addtoken="no">
</cfif>

<cfinclude template="#application.slashroot#index.cfm">