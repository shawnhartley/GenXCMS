<!--- Check login status --->
<cfset application.helpers.checkLogin()>
<cfparam name="url.id" default="0">
<cfset getCRMEmail = event.getCRMEmail(url.id)>
<cfoutput>
<div>
<a href="#BuildURL(event='crm')#">Return To List</a><br /><br />
<strong>Time and date</strong><br />
#timeFormat(getCRMEmail.datecreated, 'hh:mm:ss')# : #dateFormat(getCRMEmail.datecreated, 'YYYY/MM/DD')# <br />
<br />
<strong>CRM Communication Type</strong><br />
#getCRMEmail.crmType# <br />
<br />
<strong>From: </strong><br />
#getCRMEmail.crmFrom#<br />
<br />
<strong>To: </strong><br />
#getCRMEmail.crmSendTo#<br />
<br />
<strong>Subject: </strong><br />
#getCRMEmail.crmSubject#<br />
<br />
<strong>Body: </strong><br />
#getCRMEmail.crmBody#<br />
<br />
<strong>Your sig: </strong><br />
#getCRMEmail.crmSig#<br />
</div>
</cfoutput>