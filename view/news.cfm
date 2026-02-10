<cfparam name="form.author" default="">
<cfparam name="form.authorEmail" default="">
<cfparam name="form.authorURL" default="">
<cfparam name="form.content" default="">


<cfset pagination = createObject("component", "#application.dotroot#cfcs.Pagination").init() />
<cfset pagination.setQueryToPaginate(event.news.listing) />
<cfset pagination.setBaseLink(BuildURL(event=url.event, encode=false)) />
<cfset pagination.setItemsPerPage(4) />
<cfset pagination.setUrlPageIndicator("start") />
<cfset pagination.setShowNumericLinks(true) />


<cfoutput query="event.news.listing" startrow="#pagination.getStartRow()#" maxrows="#pagination.getMaxRows()#">
	<cfif isNumeric(event.slug)>
		<cfif event.slug eq id>
		    <a href="/news/" class="button small">Back to News</a>
		    <h1>#headline#</h1>
		    #content#
		</cfif>
	<cfelse>
		<h2 class="newsHeadline"><a href="#BuildURL(event=settings.var('news.newsurl') & '/#id#')#">#headline#</a></h2>
		#summary#
		<hr />
	</cfif>
</cfoutput>

<cfif settings.var('modules') CONTAINS 'Comments' AND isNumeric(event.slug) AND event.news.listing.recordcount EQ 1>
	<cfset comments = event.comments.getComments(commentOn = 'news', refId = event.slug)>
	<h3 id="comments">Comments</h3>
	<cfif comments.recordcount>
	<ol class="comments">
		<cfoutput query="comments">
		<li id="comment#comments.id#"><p>#Replace(content, chr(13) & chr(10), "<br />", 'ALL')#</p>
		 <span class="meta"><span><a href="##comment#comments.id#" title="[permalink] #DateFormat(dateCreated,'mm/dd/yyyy')# #TimeFormat(dateCreated, 'hh:mm')#">#DateFormat(dateCreated,"m/dd")# #TimeFormat(dateCreated, "h:mm")#</a></span> <cfif len(AuthorURL)><a href="#AuthorURL#">#Author#</a><cfelse>#Author#</cfif></span>
		</li>
		</cfoutput>
	</ol>
	</cfif>

	<h4 class="clear" id="AddComment">Add Your Comment</h4>
	<cfif StructKeyExists(form, "commentOn")>
		<cfif structKeyExists(event,"commentError")>
			<cfdump var="event.commentError">
		<cfelse>
		<p>Thank you, Your comment has been recorded and will appear on the site when moderated.</p>
		</cfif>
	<cfelse>
		
		
		<form action="#AddComment" method="post" class="comment validate">
		<cfoutput>
		<b><label for="in_author">Name:</label> <input type="text" class="required" name="author" id="in_author" value="#form.author#" placeholder="Enter your Name" /></b>
		<b><label for="in_authorEmail">Email:</label> <input type="email" class="email required" name="authorEmail" id="in_authorEmail" value="#form.authorEmail#" placeholder="[Your Email will not be published]" /></b>
		<b><label for="in_authorURL">Website:</label> <input type="url" class="url" name="authorURL" id="in_authorURL" value="#form.authorURL#" placeholder="[Optional] Enter your Website Address"  /></b>
		<b><label for="in_content">Comment:</label> <textarea class="required" name="content" id="in_content" placeholder="Enter your Comments">#form.content#</textarea></b>
		<b><label for="day">Today's Date:</label> <input type="date" class="required" name="day" id="day" /></b>
		<b class="clear"><input type="hidden" name="commentOn" value="news" />
			<button class="comment" name="refId" value="#event.news.listing.id#" type="submit">Comment</button></b>
		</cfoutput>
		</form><br /><br />
	</cfif>

<cfelse>
	<cfif event.news.listing.recordcount>
		<cfoutput>#pagination.getRenderedHTML()#</cfoutput>
	</cfif>
	<cfif NOT event.news.listing.recordcount>
	<h3>Nothing found, please try again later.</h3>
	</cfif>
</cfif>



<!--- FOR SIDEBAR ---



<div id="newsList">
<ul><cfset allnews = event.news.getAll()>
<cfoutput query="allnews"><cfset liclass = ''><cfif event.slug EQ id><cfset liclass = 'class="active"'></cfif>
<li #liclass#><a href="#BuildURL(event=settings.var('news.newsurl') & '/#id#')#">#Left(headline, 30)#<cfif len(headline) GT 30>&hellip;</cfif></a></li>
</cfoutput>
<li><cfoutput><a href="#BuildURL(event=settings.var('news.newsurl'))#">View All</a></cfoutput></li>
</ul>
</div>


--->