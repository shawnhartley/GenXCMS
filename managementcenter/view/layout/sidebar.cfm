<!---
COMPONENT: dsp_sidebar.cfm
AUTHOR: Pat Whitlock
DATE: 10/23/08
PURPOSE:
CHANGE HISTORY:
* 02/07/2011: remove ecommerce sections
* 10/23/2008: page completed
* 11/09/2008: added page region code
* 10/14/2009: added code for ecommmerce module
--->

<cfparam name="url.archive" default="0" >
<cfparam name="galleries" default="0">
<cfparam name="url.function" default="" >

<cfoutput> 
    <!-- Begin Sidebar -->
    <ul id="sidebar">
        <cfif event.can('read','cfcs.settings')>
            <li <cfif url.event contains "settings"> class="active"</cfif>> <a href="#BuildURL(event='settings')#">Sitewide Settings </a> </li>
        </cfif>
        <cfif event.can('read','cfcs.logins')>
            <li<cfif url.event contains "logins"> class="active"</cfif>> <a href="#BuildURL(event='logins')#">Users</a> </li>
        </cfif>
        <cfif event.can('read','cfcs.usergroups')>
            <li<cfif url.event contains "usergroups"> class="active"</cfif>> <a href="#BuildURL(event='usergroups')#">Groups</a> </li>
        </cfif>
        <cfif event.can('read','cfcs.schema')>
            <li<cfif url.event contains "schema"> class="active"</cfif>> <a href="#BuildURL(event='schema')#">DB Schema</a> </li>
        </cfif>
        <cfif event.can('read','cfcs.logs')>
            <li<cfif url.event contains "logs"> class="active"</cfif>> <a href="#BuildURL(event='logs')#">Error/Audit Logs</a> </li>
        </cfif>
        <cfif event.can('read','cfcs.pages')>
            <li<cfif url.event contains "pages"> class="active"</cfif>> <a href="#BuildURL(event='pages')#">Page Content</a> </li>
        </cfif>
        <cfif event.can('read','cfcs.news')>
            <li<cfif url.event is "news"> class="active"</cfif>> <a href="#BuildURL(event='news')#">
                <cfif len(application.settings.varStr('news.newstitle'))>
                    #HTMLEditFormat(application.settings.varStr('news.newstitle'))#
                    <cfelse>
                    News
                </cfif>
                </a>
                <cfif url.event contains "news">
                    <ul>
                        <li<cfif url.archive> class="active"</cfif>> <a href="#BuildURL(event='news', args='archive=1')#">
                            <cfif len(application.settings.varStr('news.newstitle'))>
                                #application.settings.varStr('news.newstitle')#
                                <cfelse>
                                News
                            </cfif>
                            Archive</a> </li>
                        <cfif application.settings.var('news.showCategories') AND event.can('read_category', 'cfcs.news')>
                            <li><a href="#BuildURL(event='news', action='categories')#">News Categories</a></li>
                        </cfif>
                    </ul>
                </cfif>
            </li>
        </cfif>
        
        
        <cfif event.can('read','cfcs.news')>
            <li<cfif url.event is "blog"> class="active"</cfif>> <a href="#BuildURL(event='blog')#">
                <cfif len(application.settings.varStr('blog.blogtitle'))>
                    #HTMLEditFormat(application.settings.varStr('blog.blogtitle'))#
                    <cfelse>
                    Blog
                </cfif>
                </a>
                <cfif url.event contains "blog">
                    <ul>
                        <li<cfif url.archive> class="active"</cfif>> <a href="#BuildURL(event='blog', args='archive=1')#">
                            <cfif len(application.settings.varStr('blog.blogtitle'))>
                                #application.settings.varStr('blog.blogtitle')#
                                <cfelse>
                                Blog
                            </cfif>
                            Archive</a> </li>
                        <cfif application.settings.var('blog.showCategories') AND event.can('read_category', 'cfcs.blog')>
                            <li><a href="#BuildURL(event='blog', action='categories')#">Blog Categories</a></li>
                        </cfif>
                    </ul>
                </cfif>
            </li>
        </cfif>
        
        
        <cfif event.can('read','cfcs.submitNews')>
            <li<cfif url.event is "submitNews"> class="active"</cfif>> <a href="#BuildURL(event='submitNews')#">Submit News Article</a> </li>
        </cfif>
        <cfif event.can('read','cfcs.submittedNews')>
            <li<cfif url.event IS "submittednews"> class="active"</cfif>> <a href="#BuildURL(event='submittednews')#">Submitted Stories</a>
                <cfif url.event IS "submittednews">
                    <ul>
                        <li><a href="#BuildURL(event='submittednews',args='archive=1')#">Archived Submissions</a></li>
                    </ul>
                </cfif>
            </li>
        </cfif>
        <cfif event.can('read','cfcs.events')>
            <li<cfif url.event contains "events"> class="active"</cfif>> <a href="#BuildURL(event='events')#">
                <cfif len(application.settings.varStr('events.title'))>
                    #HTMLEditFormat(application.settings.varStr('events.title'))#
                    <cfelse>
                    Events
                </cfif>
                </a>
                <cfif url.event contains "events">
                    <ul>
                        <li<cfif url.archive> class="active"</cfif>> <a href="#BuildURL(event='events', args='archive=1')#">Expired
                            <cfif len(application.settings.varStr('events.title'))>
                                #application.settings.varStr('events.title')#
                                <cfelse>
                                Events
                            </cfif>
                            </a> </li>
                        <cfif application.settings.var('events.showCategories') AND event.can('read_category', 'cfcs.events')>
                            <li><a href="#BuildURL(event='events', action='categories')#">Event Categories</a></li>
                        </cfif>
                    </ul>
                </cfif>
            </li>
        </cfif>
        <cfif event.can('read','cfcs.links')>
            <li<cfif url.event contains "links"> class="active"</cfif>> <a href="#BuildURL(event='links')#">Links</a>
                <cfif url.event contains "links" AND application.settings.var('links.showCategories') AND event.can('read_category', 'cfcs.links')>
                    <ul>
                        <li> <a href="#BuildURL(event='links', action='categories')#">Link Categories</a> </li>
                    </ul>
                </cfif>
            </li>
        </cfif>
        <cfif event.can('read','cfcs.comments')>
            <cfquery name="commCount" datasource="#application.dsn#">
			SELECT Count(*) as num FROM comments WHERE approved = '0'
			</cfquery>
            <li<cfif url.event contains "comment"> class="active"</cfif>> <a href="#BuildURL(event='comments')#">Comments
                <cfif commCount.num GT 0>
                    (#commCount.num#)
                </cfif>
                </a> </li>
        </cfif>
        <cfif event.can('read','cfcs.tct')>
            <li<cfif url.event contains "tct"> class="active"</cfif>> <a href="#BuildURL(event='tct')#">TCT URLs</a> </li>
        </cfif>
        <cfif event.can('read','cfcs.gallery')>
            <li<cfif url.event contains "gallery"> class="active"</cfif>> <a href="#BuildURL(event='gallery')#">Photo Gallery</a> </li>
        </cfif>
        <cfif event.can('read','cfcs.portfolio')>
            <li<cfif url.event contains "portfolio"> class="active"</cfif>> <a href="#BuildURL(event='portfolio')#">Portfolio Gallery</a>
                <cfif url.event contains "portfolio" AND event.can('read_category','cfcs.portfolio')>
                    <ul>
                        <li> <a href="#BuildURL(event='portfolio', action='categories')#">Portfolio Categories</a> </li>
                    </ul>
                </cfif>
            </li>
        </cfif>
        <cfif event.can('read','cfcs.subscriptions')>
            <li<cfif url.event contains "subscriptions"> class="active"</cfif>> <a href="#BuildURL(event='subscriptions')#">Email Subscriptions</a> </li>
        </cfif>
        <cfif event.can('read','cfcs.contact')>
            <li<cfif url.event contains "contact"> class="active"</cfif>> <a href="#BuildURL(event='contact')#">Contact Submissions</a>
                <cfif url.event contains "contact" AND application.settings.var('contact.allowArchive')>
                    <ul>
                        <li> <a href="#BuildURL(event='contact',args='archive=1')#">Archived Forms</a> </li>
                    </ul>
                </cfif>
            </li>
        </cfif>
        <cfif event.can('read','cfcs.randomimage')>
            <li<cfif url.event contains "randomimage"> class="active"</cfif>> <a href="#BuildURL(event='randomimage')#">Random Image Pool</a> </li>
        </cfif>
        <cfif event.can('read','cfcs.locations')>
            <li<cfif url.event contains "locations"> class="active"</cfif>> <a href="#BuildURL(event='locations')#">Locations Map</a> </li>
        </cfif>
        <cfif event.can('read','cfcs.crm')>
            <li<cfif url.event contains "crm"> class="active"</cfif>> <a href="#BuildURL(event='crm')#">CRM Tools</a> </li>
        </cfif>        
        <cfif event.can('read','cfcs.landings')>
            <li<cfif url.event contains "landings"> class="active"</cfif>> <a href="#BuildURL(event='landings')#">Landing Pages</a> </li>
        </cfif>
        <cfif event.can('read','cfcs.testimonials')>
            <li<cfif url.event contains "testimonials"> class="active"</cfif>> <a href="#BuildURL(event='testimonials')#">Testimonials</a> </li>
        </cfif>
        <cfif event.can('read','cfcs.resources')>
            <li<cfif url.event contains "resources"> class="active"</cfif>> <a href="#BuildURL(event='resources')#">User Resources</a>
                <cfif url.event EQ 'resources' AND application.settings.var('resources.useCategories') AND event.can('read_category', 'cfcs.resources')>
                    <ul>
                        <li> <a href="#BuildURL(event='resources', action='categories')#">Resource Categories</a> </li>
                    </ul>
                </cfif>
            </li>
        </cfif>
        <cfif event.can('read','cfcs.faq')>
            <li<cfif url.event contains "faq"> class="active"</cfif>> <a href="#BuildURL(event='faq')#">FAQs</a>
                <cfif url.event EQ 'faq' AND application.settings.var('faqs.useCategories') AND event.can('read_category','cfcs.faq')>
                    <ul>
                        <li> <a href="#BuildURL(event='faq', action='categories')#">FAQ Categories</a> </li>
                    </ul>
                </cfif>
            </li>
        </cfif>
        <cfif event.can('read','cfcs.careers')>
            <li<cfif url.event contains "careers"> class="active"</cfif>> <a href="#BuildURL(event='careers')#">Careers</a>
                <cfif url.event EQ 'careers'>
                    <ul>
                        <li> <a href="#BuildURL(event='careers', action='postings')#">Job Postings</a> </li>
                    </ul>
                </cfif>
            </li>
        </cfif>
        <cfif event.can('read','cfcs.splash')>
            <li<cfif url.event contains "splash"> class="active"</cfif>> <a href="#BuildURL(event='splash')#">Splash Content</a> </li>
        </cfif>
        <cfif event.can('edit','cfcs.twilio')>
            <li<cfif url.event contains "twilio"> class="active"</cfif>> <a href="#BuildURL(event='twilio')#">SMS Messaging</a> </li>
        </cfif>
        <li<cfif url.event contains "password"> class="active"</cfif>> <a href="#BuildURL(event='password')#">Change Password</a> </li>
    </ul>
</cfoutput> 
<!-- End Sidebar -->