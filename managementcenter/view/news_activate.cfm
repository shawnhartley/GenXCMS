<!--- Check login status --->
<cfset application.helpers.checkLogin()>


<CFPARAM NAME="id" DEFAULT="0">
<CFPARAM NAME="url.function" DEFAULT="none">

<cfset event.activate(argumentcollection=url)>
<cflocation addtoken="no" url="#cgi.HTTP_REFERER#">