<cfcomponent extends="Event">
	<cffunction name="getApplications" access="public" returntype="query">
		<cfargument name="id" default="0">
		<cfargument name="appType" default="">
		<cfif NOT can('read')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>
		<cfquery name="qapps" datasource="#application.dsn#">
			SELECT * FROM career_applications
				WHERE 1 = 1
			<cfif arguments.id NEQ 0>
				AND id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfif>
			<cfif len(arguments.appType)>
				AND jobTitle = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.appType#">
			</cfif>
				ORDER BY dateSubmitted DESC
		</cfquery>
		<cfreturn qapps>
	</cffunction>
	<cffunction name="getAppTypes" returntype="query">
		<cfquery name="qtypes" datasource="#application.dsn#">
			SELECT DISTINCT jobTitle FROM career_applications
				ORDER BY jobTitle
		</cfquery>
		<cfreturn qtypes>
	</cffunction>
	
	
	<cffunction name="insertApplication">
			<cfargument name="fname" type="string">
			<cfargument name="lname" type="string">
			<cfargument name="email" type="string">
			<cfargument name="jobTitle" type="string">
			<cfargument name="date" type="string" required="no">
			
			<cfargument name="emailNotifyTo" default="#application.settings.VarStr('careers.emailNotifyTo')#">
			<cfargument name="emailNotifyFrom" default="#application.settings.VarStr('careers.emailNotifyFrom')#">
			<cfargument name="emailNotifyBCC" default="#application.settings.VarStr('careers.emailNotifyBCC')#">
			<cfargument name="emailNotifySubject" default="#application.settings.VarStr('careers.emailNotifySubject')#">
			
		<cfif NOT DirectoryExists( ExpandPath( application.settings.var('careers.path') ) )>
			<cfdirectory action="create" directory="#ExpandPath( application.settings.var('careers.path') )#" mode="775">
		</cfif>
		
			<cfwddx action="cfml2wddx" input="#arguments#" output="formPacket">
			
		   <cfset results.success = true>
		   <cfset results.message = "">
		   <cfset results.cfcatch = StructNew()>
		   <cfset results.filename = ''>
		   <cfif NOT (isDate(arguments.date) AND  DateCompare(arguments.date, NOW(), "d") EQ 0 )>
		   		<cfset results.success = false>
				<cfset results.message = "You must provide today's Date">
				<cfset results.cfcatch = structNew()>
				<cfreturn results>
		   </cfif>
		   
		   <cftry><!--- FILE UPLOAD --->
				<cfif len(arguments.uploadfile)>
					
					<cffile action="upload" filefield="uploadfile" destination="#ExpandPath(application.settings.var('careers.path'))#" nameconflict="makeunique" result="uploadresult">
					<cfset results.filename = uploadresult.serverfile>
				</cfif>
				<cfcatch>
					<cfset results.success = false>
					<cfset results.message = 'Could not save the uploaded file.'>
					<cfset results.cfcatch = cfcatch>
				</cfcatch>
		   </cftry>
		   
		   <cftry>
		   <cfquery datasource="#application.dsn#" name="insertcareers">
				INSERT INTO career_applications	(fname, lname, emailAddress, jobTitle, location,filename,resumeTXT,formPacket,ipaddress)
										VALUES 
										(
										 <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fname#">
										,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.lname#">
										,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.email#">
										,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.jobTitle#">
										,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.location#">
										,<cfqueryparam cfsqltype="cf_sql_varchar" value="#results.filename#">
										,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.resumeTXT#">
										,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#formpacket#">
										,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">
										)
		</cfquery>
		<cfcatch>
			<cfset results.success = false>
			<cfset results.cfcatch = cfcatch>
			<cfset results.message  = "Your application could not be saved at this time. Please try again later.">
			<cfreturn results>
		</cfcatch>
		</cftry>
		<cftry>
		<cfif application.settings.Var('careers.emailNotify')>
			<cfmail to="#arguments.emailNotifyTo#" from="#arguments.emailNotifyFrom#" bcc="#arguments.emailNotifyBCC#" subject="#arguments.emailNotifySubject#" type="text/html">
			<p>A new careers form has been received. The information entered is listed below:</p>
			<cfset i = 1>
			<cfloop index="x" list="#application.settings.Var('careers.formFields')#">
			<cfset x = trim(x)>
			<cfparam name="form.#x#" default="">
			  #ListGetAt(application.settings.Var('careers.labelFields'),i)#: <cfif listfind(application.settings.Var('careers.listFields'),x)><br />
					<cfloop list="#form[x]#" index="y">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#y#<br />
					</cfloop>
				<cfelse>
					#form[x]#
				</cfif><br />
			<cfset i = i + 1>
			</cfloop>
			<cfif len(results.filename)>
			Uploaded Resume: <a href="#application.settings.varStr('careers.path')##results.filename#">#results.filename#</a>
			</cfif>
			</cfmail>
		</cfif>
		<cfcatch>
			<cfset results.success = false>
			<cfset results.cfcatch = cfcatch>
			<cfset results.message = "Your application has been recorded, but a notification mail could not be sent.">
		</cfcatch>
		</cftry>
		<cfreturn results>

	
	</cffunction>
	
	<cffunction name="deleteApplication">
		<cfargument name="id" type="numeric" required="yes">
		<cfset var results = structNew()>
		<cfset results.success = true>
		<cfif NOT can('delete_application')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this application."></cfif>
		<cftry>
			<cfquery name="del" datasource="#application.dsn#">
				DELETE FROM career_applications WHERE
					id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
		<cfcatch>
			<cfset results.success = false>
			<cfset results.cfcatch = cfcatch>
		</cfcatch>
		</cftry>
		<cfreturn results>
	</cffunction>
	
	<cffunction name="getPostings" returntype="query">
		<cfargument name="id" default="0">
		<cfquery name="qpostings" datasource="#application.dsn#">
			SELECT * FROM careers
				WHERE 1 = 1
			<cfif arguments.id>
				AND id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfif>
			<cfif NOT request.manage>
				AND active = 1
			</cfif>	
				ORDER BY sortorder, jobTitle
		</cfquery>
		<cfreturn qpostings>
	</cffunction>
	
	<cffunction name="addcareer">
		<cfargument name="jobTitle" required="yes" type="string">
		<cfargument name="active" type="boolean" default="false">
		<cfargument name="sortorder" type="numeric" default="10">
		<cfif NOT can('create')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create job postings."></cfif>
		<cfset var results = StructNew()>
		<cfset results.success = false>
		
		<cftry>
			<cfquery name="ins" datasource="#application.dsn#">
				INSERT INTO careers (jobTitle, location, description, active, publishDate, endDate, dateCreated,dateUpdated, sortorder) VALUES
				
							(
							  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.jobTitle#">
							 ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.location#">
							 ,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.description#">
							 ,<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.active#">
							 ,<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.publishDate#" null="#(arguments.publishDate EQ '')#">
							 ,<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.endDate#" null="#(arguments.endDate EQ '')#">
							 ,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#NOW()#">
							 ,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#NOW()#">
							 ,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sortorder#">
							)
			</cfquery>
			<cfset results.success = true>
			<cfcatch>
				<cfset results.cfcatch = cfcatch>
			</cfcatch>
		</cftry>
		<cfreturn results>
	</cffunction>
	
	<cffunction name="updatecareer">
		<cfargument name="jobTitle" required="yes" type="string">
		<cfargument name="active" type="boolean" default="false">
		<cfargument name="sortorder" type="numeric" default="10">
		<cfargument name="id" required="yes" type="numeric">
		
		<cfset var results = StructNew()>
		<cfset var qIsPublished = ''>
		<cfset results.success = false>
		<cfif NOT can('publish')><cfset arguments.active = false></cfif>
		<cfif NOT can('edit')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this posting."></cfif>
		<cfquery name="qIsPublished" datasource="#application.dsn#">
			SELECT id FROM careers
			WHERE active = 1
				AND id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfif qIsPublished.recordcount AND NOT can('edit_published')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this posting."></cfif>
		<cftry>
			<cfquery name="ins" datasource="#application.dsn#">
				UPDATE careers SET
							  jobTitle = 	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.jobTitle#">
							 ,location = 	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.location#">
							 ,description = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.description#">
							 ,active = 		<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.active#">
							 ,publishDate = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.publishDate#" null="#(arguments.publishDate EQ '')#">
							 ,endDate = 	<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.endDate#" null="#(arguments.endDate EQ '')#">
							 ,sortorder = 	<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sortorder#">
					WHERE	id = 	<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
							
			</cfquery>
			<cfset results.success = true>
			<cfcatch>
				<cfset results.cfcatch = cfcatch>
			</cfcatch>
		</cftry>
		<cfreturn results>
	</cffunction>
	
	<cffunction name="deleteCareer">
		<cfargument name="id" type="numeric" required="yes">
		<cfset results = StructNew()>
		<cfset results.success = true>
		<cfif NOT can('delete')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this posting"></cfif>
		<cfquery name="qIsPublished" datasource="#application.dsn#">
			SELECT id FROM careers WHERE active = 1 AND id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfif qIsPublished.recordcount AND NOT can('delete_published')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this posting."></cfif>
		<cftry>
			<cfquery name="del" datasource="#application.dsn#">
				DELETE FROM careers WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
		<cfcatch>
			<cfset results.success = false>
			<cfset results.cfcatch = cfcatch>
		</cfcatch>
		</cftry>
		<cfreturn results>
	</cffunction>
</cfcomponent>