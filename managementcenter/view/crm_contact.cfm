<cfif StructKeyExists(form,"submit")>
<cfset setEmailComm = application.datamgr.insertrecord("crm_emails",form)>
</cfif>

<cfset pullCRMMemory = application.datamgr.getrecords(tablename="crm_emails",data={crmUser=session.user})>

<!---<cfdump var="#pullCRMMemory#">--->

<!---<cfset application.helpers.checkLogin()>--->
<script>
$(document).ready(function(e) {
	
	$("#forma").hide();	
	$("#formb").hide();
	$("#formc").hide();	
	
	$( "#clickToShowa" ).click(function() {
		$("#forma").show("fast");
		$("#formb").hide();
		$("#formc").hide();	
	});
	$( "#clickToShowb" ).click(function() {
		$( "#formb" ).show( "fast" );
		$("#forma").hide();
		$("#formc").hide();		
	});
	$( "#clickToShowc" ).click(function() {
		$( "#formc" ).show( "fast" );
		$("#forma").hide();
		$("#formb").hide();		
	});
});
</script>

<h2>Use CRM to communicate to this contact.</h2>
Select an appropriate communication starter mailer:
<br><br> 
<style>
button#clickToShowa, 
button#clickToShowb, 
button#clickToShowc  
{ 
	display: block;
	float: left;
	margin: 0 auto;
}

#clear    { 
clear:both !important;height:auto !important;width:auto !important;float:none !important; 
}
</style>
<!---(len(arguments.text) ? 'show what was saved' : 'show default')--->
<button id="clickToShowa">Prospecting Email</button>&nbsp;<button id="clickToShowb">Checking In</button>&nbsp;<button id="clickToShowc">Recent Work</button>
<div id="clear"></div>
<cfoutput>
<div id="forma">
<br />
<form name="formaa" action="#BuildURL(event=url.event, action=url.action, id=url.id, args='function=#url.function#')#" method="post">
<input name="dateCreated" value="#now()#" type="hidden">
<input name="crmUser" value="#session.user#" type="hidden">
<input name="crmType" value="Prospecting Email" type="hidden">
From: <br />
<input name="crmFrom" value="#session.email#" type="text"><br />
To: <br />
<input name="crmSendTo" value="#getcontact.email#" type="text"><br />
Subject: <br />
<input type="text" name="crmSubject" value="Marketing for Healthcare organizations." placeholder="Prospecting Email" /><br />
Body:<br />
<textarea name="crmBody" cols="42" rows="20">
Hello, my name is Shawn Hartley and I'm the Vice President at Corporate 3 Design We're a midwest based design (print and technology) and development studio.

We work with several health systems helping them with website design, mobile marketing, social media, online advertising, search marketing, etc. You can see some of our healthcare work by going to at http://www.corporate3design.com/experience/healthcare/

We would love to use our experience to help you as you look at enhancing your interactions online as well as your marketing/advertising needs.

Thanks,
Shawn
</textarea>
<br />
Your sig:<br />
<textarea name="crmSig" cols="42" rows="20">
--
Shawn Hartley
Vice President
Corporate 3 Design
402.398.3333
1005 S. 76th Street, Suite 104
Omaha, NE 68114
http://www.corporate3design.com/{tct}
</textarea>
<button name="submit" type="submit">Send Email</button>
</form>
</div>

<div id="formb">
<br />
<form name="formbb" action="#BuildURL(event=url.event, action=url.action, id=url.id, args='function=#url.function#')#" method="post">
<input name="dateCreated" value="#now()#" type="hidden">
<input name="crmUser" value="#session.user#" type="hidden">
<input name="crmType" value="Checking In" type="hidden">
From: <br />
<input name="crmFrom" value="#session.email#" type="text"><br />
To: <br />
<input name="crmSendTo" value="#getcontact.email#" type="text"><br />
Subject: <br />
<input type="text" name="crmSubject" value="Checking In" placeholder="Checking In" /><br />
Body:<br />
<textarea name="crmBody" cols="42" rows="20">
{prospect} -

Just checking in with you about your {}

Let me know if there is anything Corporate 3 Design can you help you out with.

Thanks,
Shawn
</textarea>
<br />
Your sig:<br />
<textarea name="crmSig" cols="42" rows="20">
--
Shawn Hartley
Vice President
Corporate 3 Design
402.398.3333
1005 S. 76th Street, Suite 104
Omaha, NE 68114
http://www.corporate3design.com/{tct}
</textarea>
<button name="submit" type="submit">Send Email</button>
</form>
</div>

<div id="formc">
<br />
<form name="formcc" action="#BuildURL(event=url.event, action=url.action, id=url.id, args='function=#url.function#')#" method="post">
<input name="dateCreated" value="#now()#" type="hidden">
<input name="crmUser" value="#session.user#" type="hidden">
<input name="crmType" value="Recent Work" type="hidden">
From: <br />
<input name="crmFrom" value="#session.email#" type="text"><br />
To: <br />
<input name="crmSendTo" value="#getcontact.email#" type="text"><br />
Subject: <br />
<input type="text" name="crmSubject" value="Recent Work from C3D" placeholder="Recent Work" /><br />
Body:<br />
<textarea name="crmBody" cols="42" rows="20">
Hey {prospect}, how've you been? I wanted to show you some of our recent work that we are quite proud of:

Project 1 Graphic - short description

short description - Project 2 Graphic

Project 3 Graphic - short description

If there is anything happening in your space, Corporate 3 Design would love to be a part of it, shoot me an email or give me a call.

Thanks,
Shawn
</textarea>
<br />
Your sig:<br />
<textarea name="crmSig" cols="42" rows="20">
--
Shawn Hartley
Vice President
Corporate 3 Design
402.398.3333
1005 S. 76th Street, Suite 104
Omaha, NE 68114
</textarea>
<button name="submit" type="submit">Send Email</button>
</form>
</div>
</cfoutput>