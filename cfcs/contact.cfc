<cfcomponent extends="Event" output="no">
	<cffunction name="insertContact" access="public" output="true">
			<cfargument name="name" type="string" required="no">
			<cfargument name="lastName" type="string" required="no">
			<cfargument name="companyName" type="string" required="no">
			<cfargument name="title" type="string" required="no">
			<cfargument name="email" type="string" required="no">
			<cfargument name="message" type="string" required="no">
			<cfargument name="date" type="string" required="no">
			<cfargument name="formType" type="string" default="">
                        <cfargument name="howDidYouHear" type="string" default="">
			
			<cfargument name="emailNotifyTo" default="#application.settings.VarStr('contact.emailNotifyTo')#">
			<cfargument name="emailNotifyFrom" default="#application.settings.VarStr('contact.emailNotifyFrom')#">
			<cfargument name="emailNotifyBCC" default="#application.settings.VarStr('contact.emailNotifyBCC')#">
			<cfargument name="emailNotifySubject" default="#application.settings.VarStr('contact.emailNotifySubject')#">
			
			<cfargument name="formfields"	default="#application.settings.VarStr('contact.formFields')#">
			<cfargument name="labelFields" 	default="#application.settings.VarStr('contact.labelFields')#">
			<cfargument name="listFields" 	default="#application.settings.VarStr('contact.listFields')# ">
			
			<cfwddx action="cfml2wddx" input="#arguments#" output="arguments.formPacket">
		   <cfset results.success = true>
		   <cfset results.message = "">
		   <cfset results.cfcatch = StructNew()>
		   
		<cftry>
			<cfif form.nameFirst NEQ "">
            <cfset results.success = false>
            <cfset results.message = "We believe you are a Robot. Please turn on your CSS and try again.">
            <cfset results.cfcatch = structNew()>
            <cfreturn results>
            </cfif>
           <cfif arguments.name EQ "">
		   		<cfset results.success = false>
				<cfset results.message = "You must provide your Name">
				<cfset results.cfcatch = structNew()>
				<cfreturn results>
		   </cfif>
           <cfif arguments.email EQ "">
		   		<cfset results.success = false>
				<cfset results.message = "You must provide your Email Address">
				<cfset results.cfcatch = structNew()>
				<cfreturn results>
		   </cfif>
           <cfif arguments.phone EQ "">
		   		<cfset results.success = false>
				<cfset results.message = "You must provide your Phone Number">
				<cfset results.cfcatch = structNew()>
				<cfreturn results>
		   </cfif>
           <cfif arguments.message EQ "">
		   		<cfset results.success = false>
				<cfset results.message = "You must provide a Message">
				<cfset results.cfcatch = structNew()>
				<cfreturn results>
		   </cfif>			   
		   
		   	<cfset application.DataMgr.insertRecord('contacts', arguments)>
		<cfcatch>
			<cfset results.success = false>
			<cfset results.cfcatch = cfcatch>
			<cfset results.message  = "Your message could not be saved at this time.">
			<cfreturn results>
		</cfcatch>
		</cftry>
		<cftry>
		<cfif application.settings.Var('contact.emailNotify')>
			<cfmail to="#arguments.emailNotifyTo#" from="#arguments.emailNotifyFrom#" bcc="#arguments.emailNotifyBCC#" subject="#arguments.emailNotifySubject#" type="text/html">
			<p>A new contact form has been received. The information entered is listed below:</p>
			<cfset i = 1>
			<cfloop index="x" list="#arguments.formfields#">
			<cfset x = trim(x)>
			<cfparam name="form.#x#" default="">
			  #ListGetAt(arguments.labelFields,i)#: <cfif listfind(arguments.listFields,x)><br />
					<cfloop list="#form[x]#" index="y">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#y#<br />
					</cfloop>
				<cfelse>
					#Replace(form[x], chr(10) & chr(13), "<br />",'ALL')#
				</cfif><br />
			<cfset i = i + 1>
			</cfloop>
			</cfmail>
		</cfif>
		<cfcatch>
			<cfset results.success = false>
			<cfset results.cfcatch = cfcatch>
			<cfset results.message = "Your message has been recorded, but a notification mail could not be sent.">
		</cfcatch>
		</cftry>
		<cfreturn results>
	</cffunction>

	
	<cffunction name="getContacts" access="public" returntype="query">
		<cfargument name="formType" default="" type="string">
		<cfargument name="id" default="0" type="numeric">
		<cfargument name="archive" default="false" type="boolean">
		<cfif NOT can('read')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>
		<cfquery datasource="#application.dsn#" name="qContacts">
			SELECT *
			FROM contacts
			WHERE 1 = 1
		<cfif arguments.id>
			AND id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfif>
		<cfif len(arguments.formType)>
			AND formType = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formType#">
		</cfif>
		<cfif NOT arguments.id>
			AND archived = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.archive#">
		</cfif>
			order by dateCreated DESC
		</cfquery>
		<cfreturn qContacts>
	</cffunction>
	
	<cffunction name="delete" access="public" returntype="void">
		<cfargument name="id" required="yes" type="numeric">
		<cfif NOT application.settings.Var('contact.allowDelete')><cfthrow type="c3d.forbiddenAction" message="Deletion of contact forms has been disabled."></cfif>
		<cfif NOT can('delete')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete forms."></cfif>
		<cfquery datasource="#application.dsn#" name="delContact">
			DELETE FROM contacts
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	
	<cffunction name="archive" access="public" returntype="void">
		<cfargument name="id" required="yes" type="numeric">
		<cfif NOT application.settings.Var('contact.allowArchive')>
			<cfthrow type="c3d.forbiddenAction" message="Archiving contact forms has been disabled.">
		</cfif>
		<cfif NOT can('archive')><cfthrow type="c3d.notPermitted" message="You do not have permissions to archive forms."></cfif>
		<cfquery datasource="#application.dsn#" name="delContact">
			UPDATE contacts
				SET archived = 1
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	
	<cffunction name="unarchive" access="public" returntype="void">
		<cfargument name="id" required="yes" type="numeric">
		<cfif NOT application.settings.Var('contact.allowArchive')>
			<cfthrow type="c3d.forbiddenAction" message="Archiving contact forms has been disabled.">
		</cfif>
		<cfif NOT can('archive')><cfthrow type="c3d.notPermitted" message="You do not have permissions to archive forms."></cfif>
		<cfquery datasource="#application.dsn#" name="delContact">
			UPDATE contacts
				SET archived = 0
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	
	
	<cffunction name="getFormTypes" output="no" returntype="query">
		<cfquery datasource="#application.dsn#" name="qtypes">
			SELECT DISTINCT formType FROM contacts ORDER BY formType ASC
		</cfquery>
		<cfreturn qtypes>
	</cffunction>

</cfcomponent>