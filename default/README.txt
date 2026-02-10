===== Release History =====
==== 2.6.1 (r874) ====
  * Defaults
    * Display error details for C3 users, external users get generic error page
    * Display an Edit This Page link on the live site for logged-in users.
  * Event
    * move getslugfromtitle() from pages.cfc, so it inherits to all modules
    * ADD ContentFilter support
      * pass string to event.runContentFilters();
      * array of functions in application.ContentFilters[]
      * loops through and applies each function
      * default functions are stripDoupleBreaks() and stripEmptyParas()
  * FormHelper
    * bugfixes - select boxes and default/submitted values, add clearData()
  * Image
    * Improve quality of uploaded images that are already at the correct size - don't re-compress them.
  * JS
    * update cycle plugin to latest
  * Mailer
    * ADD
    * use to send emails w/ mail merge replacements in the body
  * MC
    * CKEditor upgrade to 3.5.3
  * Pages
    * Redirect to cgi.referer when updating a page - works w/ live site Edit link
  * Portfolio
    * Use getslugfromtitle() instead of nested Replace() to generate urls
  * RSSReader
    * Add cacheClear functionality
    * Use built in CF9 cache
  * Splash
    * Add capability checks
  * Submitted News
    * Add schema, settings, sidebar nav


==== 2.6.0 (r763) ====
  * Frontend
    * Add caching support
      * full-page in index.cfm when Settings has a non-zero time for Cache
      * Add cachebuster URL string to ignore caches
  * Defaults
    * Add commented generated time to skel.cfm to test caching
    * If an event.init() call fails instantiate a copy of event.cfc in its place, so permissions can still be checked.
    * Log permissions exceptions
    * Update to jquery 1.5.1
    * Add default web.config for IIS7
      * Remove default Powered By ASP.NET HTTP header
    * Add an error handler for all 500 errors - display no information to normal users, display full info to Corporate 3 IP address
    * Update default logins - remove Brian, re-add Pat
    * Installer - CF9 datasource creation, allow mysql multiple statements per cfquery
  * MC
    * Add a pretty catch page for permissions exceptions
    * clean up old files and folders
    * CKEditor
      * Override mainstyle.css to remove underlines on editor buttons
      * Upgrade to 3.5.2
    * Expand page width to 1000px
  * Modules
    * DROP ecommerce module & nav
    * Add capability-based permissions to all modules
    * Remove leftover remnants of MultiSite module
    * ADD standalone Events module
  * TableStructure (Schema)
    * many, many changes
      * capabilities and defaults
    * Add indexes
  * AUDIT
    * Add files for audit logging
    * Global application.logbox object
  * Event
    * Switch to cfscript-style component
      * clean up, formatting
    * Add .can() to support Usergroup capability-based permissions
    * Add .getArg() method for convenience (forms)
  * Events
    * Added
    * endDate removes event from site completely
    * eventDate acts like endDate in news.cfc
    * log CRUD by user
  * FormHelper
    * Switch to cfscript-style component
      * clean up, formatting
    * no longer extends Event.cfc
  * Contact
    * Add archive methods and permissions
    * Use DataMgr for inserts
  * FormHelpers
    * stateSelect - add support for Canada provinces
    * checkBoxLabel - if no value argument is passed in, use the label text as the value
    * add processUpload()
  * Helpers 
    * Move easy functions to cfscript style
  * Logins
    * Complete restructure
    * SHA-512 + salt hashed passwords
    * e-mail address is now username, must be unique
    * e-mail address is forced to lowercase
      * Early revisions included username in the password salt. don't do that.
    * Add Forgot Password process with temporary password that expires in 14 days
    * Logins and usergroups use foreign keys, normalized table structure
    * Add ChangePassword event, requires entry of current or temporary password
      * Also requires a temporary password to be changed
    * Add searching for logins
  * News
    * Change default display behavior
      * an article will show in current OR archive, but not both
    * Add title attribute to news links, better truncation
  * Pages
    * Only allow approval of pages for users with 'publish' capability
    * Use DataMgr for page inserts and updates
    * Check that urls are unique per parent section
      * With fancy exception handling
    * printNavList()
      * Use StringBuilder
      * add maxDepth argument
    * Queries are cached for 5 minutes
      * Add cachebuster URL string to ignore caches
    * BUGFIX: New friendlyURL function stripped numbers. Allow them in the RegEx.
    * hasChildren() now returns the count of children, not a boolean
    * Only cache queries for two seconds when in the managementcenter
  * Resources
    * Add ability to assign resources to particular groups, not just users
    * log CRUD by user
  * Settings
    * Split into 2 CFCs, Singleton and Manager
    * Move module list and prettyURL boolean into the property scope for faster lookups
    * Use Java .indexOf() to look up variables -- faster than query of queries
    * Use cfc filenames in the modulelist, makes lookups easier
  * Sitemap
    * Google Sitemap crawler, from http://googlesitemapxmlgenerator.riaforge.org/
  * Subscriptions
    * capabilities
    * clean up
    * normalize member/group schema
  * TCT
    * Use DataMgr for database interaction
  * Usergroups
    * Complete Restructure
    * Capability-Based permissions
    * SuperAdmin (usergroupID = 0) can do anything

==== 2.5.10 (r613) ====
  * MC
    * 
  * Defaults
    * New CSS resets, new defaults
    * trim down Modernizr with the 2.0Beta downloader
  * Pages
    * Fully recursive page list and parent selector
      * Link the page list to frontend pages
    * Add caching and clear cache to queries
    * New url/slug generation taken from cflib (friendlyURL)
  * News
    * Add author to News items

==== 2.5.9 (r590) ====
  * MC
    * Schema (tablestructure.xml) edits for cross platform compatibility, sane defaults
    * add autofocus param to login page username
  * JS
    * modernizr 1.6
    * jQuery Tools 1.2.5
  * Contact
    * Add site setting to allow/disallow contact form deletion
  * DataMgr
    * Update to 2.5 Beta 2
  * Event
    * add function to parse ISO 8601 dates (CF8)
  * FormHelper
    * add email input helpers
    * add blank option to select element helpers
    * add numericDaySelect() {1-31}
  * Helpers
    * cssfiles/jsfiles - remove all space characters from file lists going to combine.cfc
  * Pages
    * remove pagetype column
    * Add exclude and includeOnly params to printNavList() and getSidebar() (similar to wordpress functionality)
    * Change return values for page_setup() to allow subpages in special sections (news)
    * Ignore all references to page history, will be TODO
  * Portfolio
    * Add email address field to project details

==== 2.5.8 (r560) ====
  * MC
    * CKeditor replaces FCKeditor.
      * Add .vcf to allowed extensions
      * Using coreFive's FileManager plugin
      * Add security checks to File Manager (looks for session cookie)
  * Defaults
    * Update Modernizer.js to 1.6
  * Event
    * PhoneFormat()
    * activateURL() - looks for urls in a string and replaces with anchor tags
  * FormHelper
    * monthSelect(), setData()
    * getArg() is more robust in its selections
  * Settings
    * Add var scoping to getVar()
  * Splash
    * DeleteImage() 

==== 2.5.7 (r539) ====
  * App
    * Move to using DataMgr to maintain database table structure - object is available at application.DataMgr
    * Better error handling to ensure required objects are available on every request
    * More revisions to page_setup() support functions - make sure multiple pages with the same url slug are selected correctly (507,511)
  * Installer
    * Datasources need to have ALTER permissions for DataMgr to work correctly
    * Rework installer process, slim to file copies, datasource creation and DataMgr.init() 
  * MC
    * New styling
    * Add zebra striping to tables in modern browsers
  * Default
    * Add default print stylesheet
  * Combine
    * change mimetype to text/javascript
  * DataMgr
    * Update to latest SVN
  * FormHelper
    * new module - provides wrappers and pre-fill functions for basic HTML inputs
  * Helpers
    * Add isValidNewUserName()
    * Add toCSV() and toXLS() quick functions. For large datasets, we need to use POI instead.
  * News
    * add stripHTML option to printNews() method
    * add urlbase option - allows custom url prefixes
  * Pages
    * Add redirectURL functionality - a Page can be either content OR a redirect to another url. This is completely separate from TCT.
  * Portfolio
    * Add featured flag to portfolio projects
  * Schema
    * New module. Gives ability to force a DataMgr.loadXML() call OR pull loaded xml from the cached object.
  * Splash
    * add insertItem() method

==== 2.5.6 ====

  * App
    * Add jQuery.accord.js
    * common.js - add default console.* functions to prevent errors when debugging
    * Add DataMgr to codebase
    * Add a default try-catch block in onRequestStart() to make sure we have a helpers object and database
  * Splash Content Module
  * News
    * Strip html from news headline if it is being truncated
  * Pages
    * experiment with automatic query caching, but breaks on ACF, so reverted
  * Portfolio
    * Add support for category landing pages
    * Add "Featured" selection box
 
==== 2.5.5 ====
  * App
    * common.js - only run placeholder.js on inputs with a placeholder attribute
    * add jquery.accord.js plugin to default distro
  * ManagementCenter
    * default publishDate fields to Today
    * add logout/session timer display
  * RandomImage
    * use proper appsettings reference
    * new getImage() function
  * Resources
    * require publishDate
    * hide dateUpdated from listing
  * Contact
    * add css to apply line breaks to textarea submissions
    * Make form submissions self-contained. Include formFields, labelFields and listFields in formpacket
    * Notification mails: exchange textarea line breaks for hard breaks in the html mail
  * Locations
    * explicitly use a Decimal scale for queries - ACF by default rounds to a whole integer
  * News
    * Use NOW() in queries instead of CURDATE()
    * printNewsList(): support datePosition="after"
    * printNewsList(): add "active" class to nav list
    * bugfix: add news with priority disabled
  * Pages
    * Process Access Controls on page Add
    * init(): pull meta info from portfolio object
    * init(): add sectionTitle property
    * add getTitleByID()
  * Portfoliio
    * Add address and Teaser fields to projects
    * Add geocoding support
    * extra display options for printList() methods
    * bugfix: printCategoryList(): use continue, not break when a category has no methods
    * Support category landing pages
  * Security
    * Contributors cannot modify approved content
  * FQT (Frequent Question Tool)
    * Add FQT
  * cf_googleMap
    * default fitPointsToMap() function should pull out 1 extra click


==== 2.5.4-1 ====
  * Tag as of FQT addition

==== 2.5.4 ====


  * App
    * Default session timeout is now 2 hours
    * update to jQueryTools 1.2.3
    * Modernizr 1.5
    * Add support for including files at arbitrary path depths
    * Buffer response so that a 404 thrown from an included page is handled correctly
  * Helpers
    * Add cssfiles() and jsfiles() to output correctly formatted file links, compatible with Combine.cfc
  * ManagementCenter
    * css for cfdump readability
    * Add thead/tbody tags for site-wide hovers on tables
  * Careers
    * Add Careers module
  * News
    * Add support for absolute sort order/priority
    * MC - highlight top x news articles (those shown on frontpage)
    * Support a NULL endDate - evaluates to 'Never Expire'
  * Pages
    * Hide '+' triggers when a page has no children
  * Resources
    * Force download for file resources instead of letting the browser choose (attachment)


==== 2.5.3 ====

  * Event
    * Add stripHTML() method - inherited by all CFCs
  * Page Content
    * Initial support for Private Content
  * News
    * add options to printNewsList()
    * add ability to select multiple categories per news article
  * Contacts
    * contact export (was removed in the pruning)
    * allow overrides of email options on insertContact() call
  * Surveys Tool
    * Add table for surveys (modeled on Contact Submissions)
  * User Resources (started as userfiles)
    * resources.cfc
    * add userid and email to logged-in session scope
    * support for resources by-user
    * support for publishDate/ expire date
    * categories
  * User Logins
    * Add getNonManagers() and getNonManagerGroups()
  * Managementcenter
    * built-in support for Google Analytics account id
    * Change default session timeout to 2 hours
  * Frontend Defaults
    * Add default 403 page
    * Add default login form
    * Add logout trigger to default index.cfm
    * add snippet to iirf.ini for canonical domains
    * nivoSlider version 2.0
    * Add built-in support for Google Analytics account id
    * common.js - apply [open in new window] to https links as well
==== 2.5.2 ====
  * 2010-05-21
  * DB Schema Changes
  * Cleanup / prune old files, unnecessary files
  * News Module
    * dynamic title for MC sidebar
  * Locations Module [Add]
    * remote feedXML method
    * support caching of markerdata for large numbers of locations
  * Page Content
    * set default meta tags w/ site defaults
    * auto-truncate page slugs at 50 chars
    * remove double-dash from slugs (--)
  * News 
    * default dateformat setting
    * add printNewsList() method
    * add option to provide event.news api on all pages
    * pull topnews query directly from database - not QoQ of current news page
    * add form - set default for status and approved to "no"
  * Contacts
    * Extra error handling on email notification failure
    * Trim spaces from field lists
  * MRT is renamed to TCT
    * TCT-enhanced: add history and visit tracking
  * Helpers
    * Add activeIndicator()
    * Add activeToggle() for use in MC lists
  * Subscriptions
    * Pull -fixes from 2.5.1 (untested)
  * Managementcenter
    * collapsible fieldsets with class="collapse"
    * Logout on session timeout
    * option to hide version info
  * Frontend Defaults
    * add nivo slider to css/js
    * update to jquery 1.4.2
    * update to jquery-Tools 1.2.2


==== 2.5.1 ====

  * 2010-04-21 [Yes, the day after 2.5.0]
  * DB schema changes
  * Page Module
    * add indicator on list for [showNav]
    * wrap Delete button in permissions
  * Add Version counter in logged-in footer
  * portfolio bugfixes
  * Add initial support for **Security Overhaul**
    * DB schema change: Add [limitToMods] column to [usergroups] table
    * add checkAccessPermissions() to Helpers object
      * forbids access to modules based on [limitToMods] column
  * Comments approve/unapprove verbiage
=== -fixes ===

  * Add support for sending mail through the subscriptions module


==== 2.5.0 ====

  * 2010-04-20
  * New Installer script - needs work for sql server
  * Supporting sitewide super-admin settings
  * portfolio module - improved simple gallery module, image module
  * contact and news signup notifications controlled from MC
  * added Site Search module - only for google right now
  * added Comment module and new comment notification
  * added custom fields to Pages module
  * added support for Combine.cfc
=== Known Issues ===
  * sitewide settings needs styling, organization
  * portfolio module WILL NOT work on MSSQL
  * newsletter signup doesn't check for duplicates
  * newsletter signup will fail without error if no mail server is set.
  * contact form submit will fail without error if no mail server is set.
  * RSS module works for news stories only
  * Comment module works for news stories only
    * auto-approve function has not been tested.
  * there may still be some old-style security checks in the MC
  * Installer still has some permissions issues
  * new installs on a clean server will need to copy the two jar files in /cfcs/ to the CF-lib directory
