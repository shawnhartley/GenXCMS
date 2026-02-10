<cfcomponent extends="Event" output="no">
	<cffunction name="init">
		<cfset Super.init()>
		<cfreturn this>
	</cffunction>
	<!---<cffunction name="getLandings" access="public" returntype="string">
		<cfargument name="myArgument" type="string" required="yes">
		<cfset myResult="foo">
		<cfreturn myResult>
	</cffunction>--->

    <cffunction name="addLanding">
		<cfif NOT DirectoryExists( expandPath('../uploads/landings/') )>
            <cfdirectory action="create" directory="#expandPath('../uploads/landings/')#">
        </cfif>
        <cfif Len ( Trim ( form.landingImage ) ) > 
            <cffile action="upload" accept="image/png, image/jpeg, image/jpg, image/bmp"
            filefield="landingImage"
            destination="#expandPath('../uploads/landings/')#"
            nameconflict="makeunique">
            <cfset form.landingImage = (CFFILE.ServerFile) />
        </cfif>
        <cfif Len ( Trim ( form.leadLogo ) ) > 
            <cffile action="upload" accept="image/png, image/jpeg, image/jpg, image/bmp"
            filefield="leadLogo"
            destination="#expandPath('../uploads/landings/')#"
            nameconflict="makeunique">
            <cfset form.leadLogo = (CFFILE.ServerFile) />
        </cfif>    
        <cfset var results = application.DataMgr.insertRecord('landings', form)>
    
        <cfscript>
            logger.info('User #session.userid# (#session.username#) ADDED landing page "#arguments.landingName#" (#results#)');
        </cfscript>
    
    </cffunction>

    <cffunction name="editLanding">
    <cfargument name="landingName" required="yes">
    <cfargument name="idlandings" required="yes">
		<cfif NOT DirectoryExists( expandPath('../uploads/landings/') )>
            <cfdirectory action="create" directory="#expandPath('../uploads/landings/')#">
        </cfif>
            <!---Landing deleter--->
            <cfif isdefined("form.removeImage") AND form.removeImage eq 1>
            <cffile 
            action = "delete"
            file = "#expandPath('../uploads/landings/')##trim(form.landingImageExisting)#">
            <cfset form.landingImageExisting = ''>
            </cfif>
            <!---Landing deleter--->
            <!---Logo deleter--->
            <cfif isdefined("form.removeLogo") AND form.removeLogo eq 1>
            <cffile 
            action = "delete"
            file = "#expandPath('../uploads/landings/')##trim(form.leadLogoExisting)#">
            <cfset form.leadLogoExisting = ''>
            </cfif>
            <!---Logo deleter--->    
            <cfif Len ( Trim ( form.landingImage ) ) > 
                <cffile action="upload" accept="image/png, image/jpeg, image/jpg, image/bmp"
                filefield="landingImage"
                destination="#expandPath('../uploads/landings/')#"
                nameconflict="makeunique">
                <cfset form.landingImage = (CFFILE.ServerFile) />  
            <cfelse>   
                <cfset form.landingImage = trim(form.landingImageExisting)> 
            </cfif> 
            <cfif Len ( Trim ( form.leadLogo ) ) > 
                <cffile action="upload" accept="image/png, image/jpeg, image/jpg, image/bmp"
                filefield="leadLogo"
                destination="#expandPath('../uploads/landings/')#"
                nameconflict="makeunique">
                <cfset form.leadLogo = (CFFILE.ServerFile) />
            <cfelse>   
                <cfset form.leadLogo = trim(form.leadLogoExisting)> 
            </cfif>        
            <cfset application.DataMgr.updateRecord('landings', form)>
      
            <cfscript>
                logger.info('User #session.userid# (#session.username#) EDITED landing page "#arguments.landingName#" (#arguments.idlandings#)');
            </cfscript>
    </cffunction>    

    <cffunction name="deleteLanding">
    <cfargument name="landingName" required="yes">
    <cfargument name="id" required="yes">
        <cfset application.DataMgr.deleteRecord('landings', form)>
		<cfscript>
        	logger.info('User #session.userid# (#session.username#) DELETED landing page "#arguments.landingName#" (#arguments.id#)');
        </cfscript>
    </cffunction>

	<cffunction name="getLandings" access="public" returntype="any">
    <cfargument name="idlandings" type="numeric" required="no" default="-1">
		<cfquery name="qLandings" datasource="#application.dsn#">
			SELECT * FROM landings <cfif arguments.idlandings neq -1> where idlandings = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.idlandings#"></cfif>
        </cfquery>     
		<cfreturn qLandings>
	</cffunction>
    
</cfcomponent>