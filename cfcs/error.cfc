<cfcomponent output="no">
	<cffunction name="init" access="public" returntype="error" output="no">
		<cfargument name="cfcatch" required="yes">
			<cfset this.cfcatch = cfcatch>
		<cfreturn this>
	</cffunction>
</cfcomponent>