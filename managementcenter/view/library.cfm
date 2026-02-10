<cfset application.helpers.checkLogin()>

<h1>File Library</h1>
<cfoutput>
<iframe src="#application.slashroot#managementcenter/editor/editor/filemanager/browser/default/browser.html?Connector=#HTMLEditFormat(application.slashroot)#managementcenter%2Feditor%2Feditor%2Ffilemanager%2Fconnectors%2Fcfm%2Fconnector.cfm" width="500" height="500" scrolling="auto"></iframe>
</cfoutput>