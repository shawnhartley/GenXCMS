<cfsilent>
<!--- Check login status --->
<cfset application.helpers.checkLogin()>

<!--- get all the mailinglistmembers in the database --->
<cfset mailinglistmembersGateway = CreateObject("component", application.dotroot & "cfcs.subscriptions").init() />
<cfset getAllmembers = mailinglistmembersGateway.getmailinglistmembersList() />

<cfcontent type="application/msexcel">
<cfheader name="Content-Disposition" value="filename=MailingList#DateFormat(NOW(),'yyyymmdd')#.xls">

</cfsilent>
<table>
<tr><td>Name</td><td>Email</td><td>Verified</td></tr>
<cfoutput query="getAllMembers">
<tr><td>#firstName# #lastName#</td><td>#email#</td><td>#isVerified#</td></tr>
</cfoutput>
</table><cfabort>