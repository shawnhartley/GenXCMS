<!--- Check login status --->
<cfset application.helpers.checkLogin()>
<cfparam name="url.id" default="0">

<cfif isdefined('form.action')>

	<cfif form.Action is "insert">
    <cfset event.addCRMContact(argumentcollection=form)>
    <cflocation url="#BuildURL(event=url.event, args='', encode=false)#" addtoken="no">
    </cfif>
    
    <cfif form.action eq "update">
    <cfset event.editCRMContact(argumentcollection=form)>
    <cflocation url="#BuildURL(event=url.event, args='', encode=false)#" addtoken="no">
    </cfif>
    
    <cfif form.action eq "delete">
    <cfset event.deleteCRMContact(form.id,form.name)>
    <cflocation url="#BuildURL(event=url.event, args='', encode=false)#" addtoken="no">
    </cfif>

</cfif>

<cfset getContact = event.getCRMContact(url.id)>

<h1><cfif url.function eq "Add">Add<cfelseif url.function eq "edit">Edit<cfelse>Delete</cfif> CRM Contact</h1>
<p><cfoutput><a href="#BuildURL(event='crm', args='')#">Return To List</a></cfoutput></p>

<cfoutput>
<form action="<cfoutput>#BuildURL(event=url.event, action=url.action, id=url.id, args='function=#url.function#')#</cfoutput>" method="post" name="frmCRM" id="frmCRM">

Name<br />
<input type="text" name="name" value="#getContact.name#" /><br />
Company<br />
<input type="text" name="company" value="#getContact.company#" /><br />
Address<br />
<input type="text" name="address" value="#getContact.address#" /><br />
Address2<br />
<input type="text" name="address2" value="#getContact.address2#" /><br />
Suite<br />
<input type="text" name="ste" value="#getContact.ste#" /><br />
City<br />
<input type="text" name="city" value="#getContact.city#" /><br />
State<br />
<input type="text" name="state" value="#getContact.state#" /><br />
Zipcode<br />
<input type="text" name="zipcode" value="#getContact.zipcode#" /><br />
Phone<br />
<input type="text" name="phone" value="#getContact.phone#" /><br />
Alt Phone<br />
<input type="text" name="altPhone" value="#getContact.altPhone#" /><br />
Email<br />
<input type="text" name="email" value="#getContact.email#" /><br />

<input type="hidden" name="id" value="#url.id#" /> 
<cfswitch expression="#url.function#">
    <cfcase value="add">
    	<input type="hidden" name="action" value="insert">
        <input type="hidden" name="crmUser" value="#session.user#" />
    	<button class="submit" type="submit" tabindex="30">Add CRM Contact</button>
    </cfcase>
    <cfcase value="edit">
    	<input type="hidden" name="action" value="update">
    	<button class="submit" type="submit" tabindex="30">Update CRM Contact</button>
    </cfcase>
    <cfcase value="delete">
    	<input type="hidden" name="action" value="delete">
    	<button class="submit" type="submit" tabindex="30" onclick="return confirm('Are you sure you want to delete this record from the database?')">Delete CRM Contact</button>
    </cfcase>
</cfswitch>
</form>
</cfoutput> 
<cfif application.settings.modules CONTAINS "crm" AND NOT ListFind('add,edit,delete', url.function)>
<cfinclude template="crm_contact.cfm">
</cfif>