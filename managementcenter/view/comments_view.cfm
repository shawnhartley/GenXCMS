<cfset application.helpers.checkLogin() >
<cfif structKeyExists(form, 'content')>
	<cfset event.update(id=url.id, content=form.content)>

</cfif>

<cfset getcomment = event.getAllComments(id=url.id)>

<cfif getcomment.recordcount>
	<cfset getRef = event.getMeta(id=getcomment.refID, table=getcomment.commentOn)>
</cfif>


<h1>View Comment </h1>
<p><cfoutput><a href="#BuildURL(event=url.event)#">Return To List</a></cfoutput></p>


<cfoutput query="getcomment">
<table border="0" cellspacing="0" cellpadding="0" id="users" class="lefttable">
<tr>
	<td>Status: </td>
	<td><cfif approved>Approved<cfif event.can('moderate')> [<a href="#BuildURL(event=url.event, action='approve', id=getcomment.id, args='function=unapprove')#">Unapprove</a>]</cfif>
		<cfelse>Held for Moderation<cfif event.can('moderate')> [<a href="#BuildURL(event=url.event, action='approve', id=getcomment.id, args='function=approve')#">Approve</a>]</cfif></cfif><br />
		<cfif event.can('delete')>[<a href="#BuildURL(event=url.event, action='delete', id=getcomment.id, args='function=delete')#" onclick="return confirm('Are you sure you want to DELETE this comment?')">Delete</a>]</cfif></td>
</tr>
<cfswitch expression="#getcomment.commentOn#">
	<cfcase value="news">
		<tr>
			<td>Comment on News Article:</td>
			<td>#getRef.headline#</td>
		</tr>
	</cfcase>
</cfswitch>
<tr>
	<td>Author:</td>
	<td>#author#</td>
</tr>
<tr>
	<td>Email:</td>
	<td><a href="mailto:#authorEmail#">#authorEmail#</a></td>
</tr>
<tr>
	<td>Website:</td>
	<td><a href="#authorURL#">#authorURL#</a></td>
</tr>
<tr>
	<td>Comment:</td>
	<td>
		<cfif settings.var('comments.allowEdit') AND event.can('edit')>
			<form action="" method="post">
			<textarea rows="5" cols="25" name="content">#Replace(content, chr(13) & chr(10), "<br />", "ALL")#</textarea>
			<input type="submit" value="Save Changes" />
			</form>
		<cfelse>
			#Replace(content, chr(13) & chr(10), "<br />", "ALL")#
		</cfif>
		</td>
</tr>
</table>
</cfoutput>