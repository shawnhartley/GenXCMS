<cfset application.helpers.checkLogin()>

<cfparam name="form.submit" default="">
<cfparam name="form.phoneNumber" default="">
<cfparam name="form.createDate" default="#now()#">
<cfparam name="url.uid" default="SMS">

<cfscript>
	// The attempt to intansiate
	twilioLib = createObject("component","cfcs.lib.TwilioLib").init();
	
	requestObj = TwilioLib.newRequest("Accounts/{AccountSid}/OutgoingCallerIds", "GET");
</cfscript>	


<cfif isdefined("url.active")> 	
<cfset twilioNosUpdate = application.datamgr.updaterecord("twilionos", url)>
</cfif>

<cfif form.submit neq '' and isValid("telephone", form.phoneNumber)>
<cfset req = application.datamgr.insertrecord("twilioNos", form)>
</cfif>

<cfset getNumbers = application.datamgr.getrecords("twilionos")>


<cfif isdefined("form.message") and form.message neq ''> 	
<cfquery name="twilio" datasource="#application.dsn#">
insert into twiliomessages (message) value (<cfqueryparam value="#form.message#" cfsqltype="cf_sql_varchar">)
</cfquery>
<cfoutput query="getNumbers">
<cfif active eq 1>
<cfset requestObj = TwilioLib.newRequest("Accounts/{AccountSid}/SMS/Messages", "POST", {From = "#application.settings.varStr('TWILIO.SMSNUMBER')#", To = "#getNumbers.phoneNumber#", Body = "#form.message#"}) />
</cfif>
</cfoutput>


</cfif>


<cfset getMessages = application.datamgr.getrecords(tablename='twiliomessages',orderby='id desc')>
<div>
<div style="float:left; width:48%; height:500px; overflow:auto;">
<cfoutput>
<h2>Quick Phone SMS add:</h2>
<form action="" method="post" name="tedted">
Add phone number:<br />
<input name="phoneNumber" type="text" data-required="true" ><br>
A unique name (identifier):<br />
<input name="PhoneName" type="text" data-required="true" ><br>
<input name="UID" type="hidden" value="#url.uid#">
<input type="submit" name="submit" value="submit"><br><br>
</form>

<hr width="95%">
<br />
<h2>Number of Phone Numbers: #getnumbers.recordcount#</h2>
<br />
<cfloop query="getnumbers">
#getNumbers.PhoneName# #getNumbers.phoneNumber# (
<cfif getNumbers.active eq 1>
<a href="#BuildURL(event='twilio', args='active=0&id=#getnumbers.id#', encode=false)#">deactivate</a>
<cfelse>
<a href="#BuildURL(event='twilio', args='active=1&id=#getnumbers.id#', encode=false)#">activate</a>
</cfif>)
<br />
</cfloop>
</cfoutput>
</div>
<div style="float:right; width:48%; height:500px; overflow:auto;">
<h2>Quick SMS message:</h2><br />
<form method="post" action="">
<textarea name="message" rows="5"></textarea><br />
<input type="submit" value="submit" name="submit" />
</form>
<br />
<cfoutput query="getMessages">
#id# - #message#<br /><br />
</cfoutput>
</div>
</div>