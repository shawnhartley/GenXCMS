<cfcomponent output="no">
	<cffunction name="init" returntype="settingsSingleton" output="no">
		<cfset var cache = "">
		<cfquery datasource="#application.dsn#" name="cache">
			SELECT UPPER(setting) AS setting, value FROM appsettings
		</cfquery>
		<cfset this.cachedSettings = cache>
		<cfset this.prettyurls = Var('prettyUrls')>
		<cfset this.modules = Var('modules')>
		<cfset this.cachetime = isNumeric(var('app.cachetime')) ? createTimeSpan(0, 0, var('app.cachetime'), 0) : createTimeSpan(0,0,0,2)> 
		<cfreturn this>
	</cffunction>
	
	<cffunction name="Var" returntype="any" output="no">
		<cfargument name="setting" required="yes" type="string">
		<cfargument name="value" required="no" type="any">
		<cfset var set = ''>
		<cfset var idx = -1>
		<cfif StructKeyExists(arguments, "value")>
			<cfif application.dstype EQ "mysql">
			<cfquery name="set" datasource="#application.dsn#">
				REPLACE INTO `appsettings`
								SET `setting` = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.setting#">
								, `value` = <cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_varchar" >
				
			</cfquery>
			
			
			<cfelse> <!--- mssql --->
			<cfquery name="set" datasource="#application.dsn#">
				IF NOT EXISTS (SELECT [setting] FROM appsettings WHERE UPPER([setting]) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.setting#"> )
				BEGIN
					INSERT INTO appSettings ([setting],[value]) VALUES
								(
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.setting#">
								,<cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_varchar" >
								)
				END
				ELSE
				BEGIN
					UPDATE appSettings 
					SET  [value] = <cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_varchar" >
					WHERE UPPER([setting]) = UPPER(<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.setting#">)
				END
			</cfquery>
			</cfif>
		<cfelse>
			<cfset idx = this.cachedsettings['setting'].indexOf(ucase(arguments.setting)) + 1>
			<cfif idx>
				<cfreturn this.cachedsettings['value'][idx]>
			<cfelse>
				<cfreturn false>
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="varStr" returntype="string" access="public" output="no">
		<cfargument name="setting" required="yes" type="string">
		<cfset var retval = Var(setting)>
		<cfif len(retval) AND retval NEQ false>
			<cfreturn retval>
		</cfif>
		<cfreturn "">
	</cffunction>
	
</cfcomponent>