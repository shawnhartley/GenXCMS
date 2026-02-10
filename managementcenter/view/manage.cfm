
<cfset application.helpers.checkLogin()>

<h1>Management Center: <small><cfoutput><cfif application.settings.var('modules') CONTAINS "MultiSite">#session.siteURL#</cfif></cfoutput></small></h1>
<cfif FileExists( ExpandPath('../default/install/index.cfm') )>
<p class="error"><strong>WARNING:</strong> The Installer is still present on the server. This file should be removed as soon as possible.</p>
</cfif>

<p>
	Welcome back <strong><cfoutput>#session.userName#</cfoutput></strong>.

</p>

<cfif ListContains(Session.userPermissions, "5")>
<div class="pageApprovals">

<cfset pages = event.getPageApprovals()>
<cfif pages.RecordCount GT 0>
	<h3>Page Drafts for Your Review</h3>
	<cfoutput>
	<ul>
	<cfloop query="pages">
	<li><a href="#BuildURL(event='pages',action='edit', id=pages.landingid, args='function=edit')#">#pages.title#</a></li>
	</cfloop>
	</ul>
	</cfoutput>
</cfif>
</div>

<div class="pageApprovals">

<cfset news = event.getNewsApprovals() >
<cfif news.RecordCount GT 0>
	<cfoutput>
	<h3><cfif len(application.settings.varStr('news.newstitle'))>#application.settings.varStr('news.newstitle')#<cfelse>News Article/Event</cfif> Drafts for Your Review</h3>
	<ul>
	<cfloop query="news">
	<li><a href="#BuildURL(event='news', action='edit', id=news.id, args='function=edit')#">#news.headline#</a></li>
	</cfloop>
	</ul>
	</cfoutput>
</cfif>
</div>
</cfif><!---End Check for Administrator Permissions --->

