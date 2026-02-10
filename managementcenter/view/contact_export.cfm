<cfsilent>
<cfparam name="request.manage" default="true" >
<cfset url.event = 'contact'>
<!--- Check login status --->
<cfset application.helpers.checkLogin()>
<cfset getcontact = new cfcs.contact().getcontacts() />

<cfcontent type="application/msexcel">
<cfheader name="Content-Disposition" value="filename=Contacts_#DateFormat(NOW(),'yyyymmdd')#.xls">

</cfsilent>
<table>
<tr><cfloop index="x" list="#application.settings.varStr('contact.labelFields')#">
		<cfoutput><th>#x#</th></cfoutput></cfloop>
</tr>
<cfset i = 1>
<cfoutput query="getContact">
<cfset myformpacket = "">
<tr>
<cfwddx action="wddx2cfml" input="#getContact.formPacket#" output="myformpacket" >
<cfloop index="x" list="#application.settings.varStr('contact.formFields')#"><td>
#myformpacket[x]#
</td>
</cfloop>
</tr>
</cfoutput>
</table>