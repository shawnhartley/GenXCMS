<cfcomponent extends="Event">
	<cffunction name="init">
		<cfset Super.init()>
		<cfreturn this>
	</cffunction>

    <cffunction name="addCRMContact">  
        <cfset var results = application.DataMgr.insertRecord('crm_contacts', form)> 
        <cfscript>
            logger.info('User #session.userid# (#session.username#) ADDED CRM contact entry "#arguments.Name#" (#results#)');
        </cfscript>
    </cffunction>

    <cffunction name="editCRMContact">
    <cfargument name="id" required="yes">
            <cfset application.DataMgr.updateRecord('crm_contacts', form)>
            <cfscript>
                logger.info('User #session.userid# (#session.username#) EDITED CRM contact entry #arguments.id#name "#arguments.Name#"');
            </cfscript>
    </cffunction>    

    <cffunction name="deleteCRMContact">
    <cfargument name="id" required="yes">
    <cfargument name="name" required="yes">
        <cfset application.DataMgr.deleteRecord('crm_contacts', form)>
		<cfscript>
        	logger.info('User #session.userid# (#session.username#) DELETED CRM contact entry #arguments.id#name "#arguments.Name#"');
        </cfscript>
    </cffunction>

	<cffunction name="getCRMContact" access="public" returntype="any">
    <cfargument name="id" type="numeric" required="no" default="-1">
		<cfquery name="qCRMContact" datasource="#application.dsn#">
			SELECT * FROM crm_contacts <cfif arguments.id neq -1> where id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.id#"></cfif>
        </cfquery>     
		<cfreturn qCRMContact>
	</cffunction>

	<cffunction name="getCRMEmail" access="public" returntype="any">
    <cfargument name="id" type="numeric" required="no" default="-1">
		<cfquery name="qCRMEmail" datasource="#application.dsn#">
			SELECT * FROM crm_emails <cfif arguments.id neq -1> where id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.id#"></cfif>
        </cfquery>     
		<cfreturn qCRMEmail>
	</cffunction>    
</cfcomponent>