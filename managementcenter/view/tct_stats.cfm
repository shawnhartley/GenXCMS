<cfset application.helpers.checkLogin()>

<CFPARAM NAME="url.id" DEFAULT="-1">

<cfset gettct = event.gettctList(id=url.id)>
<cfset event.getstats(id=url.id)>

<cfoutput>
<h1>Stats for TCT URL #gettct.slug#</h1>
<div class="backbutton"><a href="#BuildURL(event=url.event)#">&lt; Back to List</a></div>
</cfoutput>

<cfchart
 chartheight="200"
 chartwidth="660"
 yaxistitle="Visits"
 xaxistitle="Day"
 labelformat="number"
 sortxaxis="yes"
 title="Visits Per Day for the last Month" >
	<cfchartseries type="line" serieslabel="Visits Per Day" query="event.visitsbyDate" itemcolumn="myDate" valuecolumn="numVisits" seriescolor="012E4D" >
	</cfchartseries>
</cfchart>

<cfchart
 chartheight="200"
 chartwidth="660"
 yaxistitle="Visits"
 xaxistitle="Browser"
 labelformat="number"
 sortxaxis="yes"
 title="Visits Per Browser for the last Month" >
	<cfchartseries type="bar" serieslabel="Browsers" query="event.visitsbyBrowser" itemcolumn="browserParsed" valuecolumn="numVisits" seriescolor="012E4D" >
	</cfchartseries>
</cfchart>


