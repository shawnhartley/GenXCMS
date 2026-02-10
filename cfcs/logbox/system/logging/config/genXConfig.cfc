<cfcomponent output="false" hint="A LogBox Configuration Data Object">
<cfscript>
	/**
	* Configure LogBox, that's it!
	
	Severity 	Integer Level
	OFF 	-1
	FATAL 	0 (Default LevelMin)
	ERROR 	1
	WARN 	2
	INFO 	3
	DEBUG 	4 (Default LevelMax) 
	*/
	function configure(){
		logBox = {
			// Define Appenders
			appenders = {
				CFAppender = { 
					class="logbox.system.logging.appenders.CFAppender",
					levelMax="ERROR",
					properties = {
						logtype = "application"
					}
				},
				EmailAppender = {
					class="logbox.system.logging.appenders.EmailAppender",
					levelMax="ERROR",
					properties = {
						subject = 'Report from #cgi.HTTP_HOST#',
						from	= 'errors@c3design.com',
						to		= 'errors@c3design.com',
						bcc		= 'receipt@c3design.com'
					}
				},
				DBAppender = {
					class="logbox.system.logging.appenders.DBAppender",
					properties = {
						dsn = application.dsn,
						table = 'audit_log',
						autocreate = true
					}
				}
			},
			
			// Root Logger
			root = { levelmax="INFO", levelMin=0, appenders="*" },
			
			// Categories
			categories = {
				"cfcs" = { levelMax="DEBUG", appenders="*" }
			},
			
			debug  = [ "coldbox.system", "model.system" ],
			info = [ "hello.model", "yes.wow.wow" ],
			warn = [ "hello.model", "yes.wow.wow" ],
			error = [ "hello.model", "yes.wow.wow" ],
			fatal = [ "hello.model" ],
			OFF = [ "hello.model", "yes.wow.wow" ] 
		};
	}
</cfscript>
</cfcomponent>
