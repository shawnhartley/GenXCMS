<cfcomponent output="no" extends="Event">
	<cffunction name="doFeed" access="public" returntype="void" output="yes">
		<cfsilent>
		<cfinvoke component="news" method="getAll" returnvariable="news">
		
		</cfsilent>
<cfcontent type="text/xml; charset=utf-8" reset="true"><cfoutput><?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
<channel>
<title>#HTMLEditFormat(application.settings.varStr('siteTitle'))# #HTMLEditFormat(application.settings.varStr('news.newstitle'))# Feed</title>
<link>http://#cgi.HTTP_HOST##application.slashroot#</link>
<atom:link href="http://#cgi.HTTP_HOST##application.slashroot##application.settings.varStr('newsrss.rssurl')#" rel="self" type="application/rss+xml" />
<description>#application.settings.varStr('defaultDescription')#</description>
<lastBuildDate>#DateFormat(DateConvert("local2Utc",NOW()), "ddd, dd mmm yyyy")# #TimeFormat(DateConvert("local2Utc",NOW()), "HH:mm:ss")# GMT</lastBuildDate>
<language>en-us</language>
<cfloop query="news">
<item>
<title>#ReReplace(headline, "<[^>]*>", "", "all")#</title>
<link>http://#cgi.HTTP_HOST##application.slashroot##application.settings.varStr('news.newsURL')#/#id#</link>
<guid>http://#cgi.HTTP_HOST##application.slashroot##application.settings.varStr('news.newsURL')#/#id#</guid>
<pubDate>#DateFormat(DateConvert("local2Utc",publishDate), "ddd, dd mmm yyyy")# #TimeFormat(DateConvert("local2Utc",publishDate), "HH:mm:ss")# GMT</pubDate>
<description><![CDATA[#summary#]]></description>
<category>#title#</category>
</item>
</cfloop>
</channel>
</rss></cfoutput>

	</cffunction>
</cfcomponent>