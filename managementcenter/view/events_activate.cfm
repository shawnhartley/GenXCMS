<!--- Check login status --->
<cfset application.helpers.checkLogin()>


<cfparam name="id" default="0">
<cfparam name="url.function" default="none">

<cfset event.activate(argumentcollection=url)>
<cflocation addtoken="no" url="#cgi.HTTP_REFERER#">