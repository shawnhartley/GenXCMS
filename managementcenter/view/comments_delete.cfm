<!--- Check login status --->
<cfset application.helpers.checkLogin() >


<cfset event.delete(argumentcollection=url)>
<cflocation addtoken="no" url="#BuildURL(event='comments',encode=false)#">