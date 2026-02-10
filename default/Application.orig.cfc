<cfscript>
component {
	this.applicationTimeout = createTimeSpan(0,2,0,0);
	this.clientManagement = false;
	this.clientStorage = "registry";
	this.loginStorage = "session";
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan(0,2,0,0);
	this.setClientCookies = true;
	this.setDomainCookies = false;
	this.debuggingIPAddresses = "72.214.233.126";
	this.enablerobustexception = true;
	this.name = right(REReplace( ListLast(Replace(Replace(getDirectoryFromPath( getCurrentTemplatePath() ), "wwwroot", ""),"html",""), "\/") ,'[^A-Za-z0-9]','','all'),64);
	this.mappings = {};
	this.mappings["/logbox"] = GetDirectoryFromPath( GetCurrentTemplatePath() ) & "cfcs\logbox";

	boolean function onApplicationStart(){
	application.name = right(REReplace( ListLast(Replace(Replace(getDirectoryFromPath( getCurrentTemplatePath() ), "wwwroot", ""),"html",""), "\/") ,'[^A-Za-z0-9]','','all'),64);
		setupObjects();
		return true;
	}

	function setupObjects(){
		iniFile = getDirectoryFromPath( getCurrentTemplatePath() )&"config.ini.cfm";
		application.dsn = getProfileString(iniFile, "default", "dsn");
		application.schemaPath = getProfileString(iniFile, "default", "schemaPath");
		setupLogger();
		dbInf = new dbinfo(datasource=application.dsn).version();
		if (dbInf.driver_name CONTAINS "MySQL"){ application.dsType = "mysql"; }
		if (dbInf.driver_name CONTAINS "Oracle") { application.dsType = "ora"; }
		if (dbInf.driver_name CONTAINS "Microsoft SQL Server" OR
		    dbInf.driver_name CONTAINS "MS SQL Server" OR
			dbInf.driver_name EQ 'SQLServer') { application.dsType = "mssql"; }
		application.dotroot = getProfileString(iniFile, "default", "dotroot"); //dot notation path to root folder
		application.slashroot = getProfileString(iniFile, "default", "slashroot");    //slash notation path to root folder
		application.DataMgr = createObject("component", application.dotroot & "cfcs.DataMgr.DataMgr").init(application.dsn);
		application.DataMgr.loadXML(fileRead(getDirectoryFromPath( getCurrentTemplatePath() )&application.schemaPath), true, true);
		application.Settings = createObject("component", application.dotroot & "cfcs.settingsSingleton").init();
		application.Helpers = createObject("component", application.dotroot & "cfcs.helpers").init();
		application.contentFilters = ArrayNew(1);
		var eventProto = new cfcs.Event();
		ArrayAppend(application.contentFilters, eventProto.stripDoubleLineBreaks);
		ArrayAppend(application.contentFilters, eventProto.stripEmptyParas);
		cache="flush";
	}

	function setupLogger(){
		var data = createObject('component', 'logbox.system.logging.config.genXConfig');
		var config = createObject("component","logbox.system.logging.config.LogBoxConfig").init(CFCconfig=data);
		application.logBox = createObject("component","logbox.system.logging.LogBox").init(config);
	}

	function onApplicationEnd(required applicationScope) {}

	boolean function onRequestStart(required string thePage) {
		if (NOT StructKeyExists(application, 'settings') OR NOT StructKeyExists(application, 'helpers')){
			setupObjects();
		}

        if (structKeyExists(url, 'cacheBuster') AND url.cacheBuster EQ 1){
			application.DataMgr = createObject("component", application.dotroot & "cfcs.DataMgr.DataMgr").init(application.dsn);
			application.DataMgr.loadXML(fileRead(getDirectoryFromPath( getCurrentTemplatePath() )&application.schemaPath), true, true);
			cache="flush";
			application.cachedRss = {};
		}

		if (structkeyExists(url, 'resetHelpers') AND url.resetHelpers EQ 1){
			application.Helpers = createObject("component", application.dotroot & "cfcs.helpers").init();
		}

		if (structkeyExists(url, 'resetLogger') and url.resetLogger eq 1){
			var logger = '';
			setupLogger();
			logger = application.logBox.getLogger(this);
			logger.info("Logger reset with URL flag.", {site=cgi.HTTP_HOST});
		}
			param name="url.reload" default=0;
			if (isDefined('url.reload') and url.reload eq 1) {
				if (isDefined('application')){
					structClear(application);
					onApplicationStart();
				}
				if (isDefined('session')){
					structClear(session);
					onSessionStart();
				}
			}
		return true;
	}

	function onSessionStart(){}

	function onSessionEnd(required struct sessionScope, struct appScope){
		if (StructKeyExists(sessionScope, "status") AND Sessionscope.status EQ "login"){
		appScope.logbox.getLogger('cfcs.logins.sessionTimeout').info('User session timed out: #sessionscope.user# - #sessionscope.username# (#sessionscope.userid#)');
		}
	}
}
</cfscript>