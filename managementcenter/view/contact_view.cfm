<!--- Check login status --->
<cfset application.helpers.checkLogin()>


<cfparam name="id" default="0">
<cfif isdefined('form.Action')>


<cfif form.action eq "delete">
<cfset event.delete(id=url.id)>
<cflocation addtoken="no" url="#BuildURL(event=url.event,encode=false)#">
</cfif>
<cfif form.action eq "archive">
<cfset event.archive(id=url.id)>
<cflocation addtoken="no" url="#BuildURL(event=url.event,encode=false)#">
</cfif>
<cfif form.action eq "Unarchive">
<cfset event.unarchive(id=url.id)>
<cflocation addtoken="no" url="#BuildURL(event=url.event,encode=false)#">
</cfif>
</cfif>


<cfset getContact = event.getContacts(id=url.id)>

<cfwddx action="wddx2cfml" input="#getContact.formPacket#" output="formpacket" >


<cfoutput>

<h1><cfif url.function eq "View">View<cfelse>Delete</cfif> Contact </h1>
<p><a href="#BuildURL(event=url.event)#">Return To List</a></p>


<form action="" method="post" name="frmnews">

<table border="0" cellspacing="0" cellpadding="0" id="users" class="lefttable">
					<cfset i = 1>
					<cfloop index="x" list="#formpacket.formFields#">
					<cfset x = trim(x)>
					<cfparam name="formpacket.#x#" default="">
					<tr>
					  <td>#ListGetAt(formpacket.labelFields,i)#:</td><td class="pre"> <cfif listfind(formpacket.listFields,x)><br /><cfloop list="#formpacket[x]#" index="y">#y#<br /></cfloop>
						<cfelse>#formpacket[x]#</cfif></td>
					<cfset i = i + 1>
					</tr>
					</cfloop></table>
<ul><li>
<input type="hidden" name="id" value="#url.id#">
<cfswitch expression="#url.function#">
    <cfcase value="delete">
        <input type="hidden" name="action" value="delete">
        <button class="submit" type="submit" onclick="return confirm('Are you sure you want to delete this record from the database?')">Delete Contact</button>
    </cfcase>
    <cfdefaultcase>
        <cfif application.settings.Var('contact.allowArchive')>
            <cfif getContact.archived>
                <input type="hidden" name="action" value="unarchive">
                <button class="submit" type="submit">UnArchive Contact</button>
            <cfelse>
                <input type="hidden" name="action" value="archive">
                <button class="submit" type="submit">Archive Contact</button>
            </cfif>
        </cfif>
	</cfdefaultcase>
</cfswitch>
</li></ul>
</form>
</cfoutput>

<cfif application.settings.modules CONTAINS "crm">
<cfinclude template="crm_contact.cfm">
</cfif>
	