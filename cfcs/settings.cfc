<cfcomponent output="no" extends="Event" hint="Manager for settings ONLY. Real settings object is settingsSingleton.cfc">
	<cffunction name="updatesitesettings">
		<cfargument name="fieldnames" required="yes">
		<cfif NOT can('update')><cfthrow type="c3d.notPermitted" message="You do not have permissions to update Site Settings."></cfif>
		<cfset logger.info('SITE SETTINGS updated by #session.username# (#session.userid#)')>
		<cflock scope="application" type="exclusive" timeout="20">
			<cfloop list="#fieldnames#" index="myfield">
				<cfif NOT isStruct(arguments[myfield])>
					<cfset application.settings.Var(myfield, arguments[myfield])>
				</cfif>
			</cfloop>
			<cfset application.settings.init()>
		</cflock>
	</cffunction>
</cfcomponent>