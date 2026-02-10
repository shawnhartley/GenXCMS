<cfcomponent extends="Event" output="no">
	<cffunction name="getmailinglistList"> 
		<cfif NOT can('read')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif> 
		<cfreturn application.DataMgr.getRecords('mailinglist')> 
	</cffunction> 
	
	<cffunction name="getmailinglist"> 
		<cfargument name="listId" default="0">
		<cfif NOT can('read')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>
		<cfreturn application.DataMgr.getRecord('mailinglist', arguments)>
	</cffunction> 
	
	<cffunction name="deletemailinglist"> 
		<cfargument name="listId" default="0"> 
		<cfif NOT can('delete_list')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this item."></cfif>
			<!--- delete the mailinglist --->
			<cftry>
				  <cfquery name="qDeletemailinglist" datasource="#application.dsn#">
							DELETE FROM mailinglist                         
							WHERE listId = <cfqueryparam value="#arguments.listId#" cfsqltype="cf_sql_char" />
				  </cfquery>
				  <cfcatch type="database">
							<cfset results.success = false />
							<cfset results.message = "Deleting the record failed.  The error details if available are as follows: " & CFCATCH.Detail />
				  </cfcatch>
			</cftry>
			<cfreturn true> 
	</cffunction> 
	
	      <!--- CREATE: inserts a new mailinglist into the database --->
	<cffunction name="createMailingList" access="public" output="no" returntype="numeric"> 
		<cfargument name="listName" required="no">
		<cfargument name="listDesc" required="no">
		<cfargument name="lastUpdate" required="no">
		<cfargument name="isActive" required="no">
		<cfargument name="isPublic" required="no">
		<cfif NOT can('create_list')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create this item."></cfif>
			<!--- insert the mailinglist --->
		<cftry> 
		<cfreturn application.DataMgr.insertRecord('mailinglist', arguments)>
		  <cfcatch type="database">
					<cfset results.success = false />
					<cfset results.message = "Inserting the record failed.  The error details if available are as follows: " & CFCATCH.Detail />
		  </cfcatch>
		</cftry>	
	
	</cffunction> 
	
	<!--- UPDATE: updates a mailinglist in the database --->
	<cffunction name="updateMailingList" access="public"> 
		<cfargument name="listId" required="yes"> 
		<cfargument name="listName" required="no">
		<cfargument name="listDesc" required="no">
		<cfargument name="lastUpdate" required="no">
		<cfargument name="isActive" required="no">
		<cfargument name="isPublic" required="no">
		<cfif NOT can('edit_list')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this item."></cfif>
		<cfreturn application.DataMgr.updateRecord('mailinglist', arguments)>
	</cffunction> 
	
	<cffunction name="getmailinglistmembersList">
		<cfargument name="FilterSearchString" default="">
		<cfargument name="Orderby" default="LastName" required="no" type="string">
		<cfargument name="Sort" default="Desc" required="no" type="string">
		<cfquery name="qGetmailinglistmembers" datasource="#application.dsn#">
			SELECT     *
			FROM mailinglistmembers
			ORDER BY
			<cfswitch expression="arguments.orderby">
			<cfcase value="LastName">
			LastName
			</cfcase>
			<cfdefaultcase>
			memberID
			</cfdefaultcase>
			</cfswitch>
			<cfif arguments.sort EQ 'DESC'>
			DESC
			<cfelse>
			ASC
			</cfif>
		</cfquery>
		<cfreturn qGetmailinglistmembers>
	</cffunction>

	<cffunction name="getmailinglistmembers">
		<cfargument name="memberID" default="0">
		<cfreturn application.DataMgr.getRecord('mailinglistmembers', arguments)>
	</cffunction>

	<cffunction name="deletemailinglistmembers">
		<cfargument name="memberID" default="0">
		<cfif NOT can('delete_member')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create this item."></cfif>
		<cfquery name="qDeletemailinglistmembers" datasource="#application.dsn#">
				delete from mailinglistmembers
				WHERE memberID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.memberID#">
			</cfquery>
		<cfset application.DataMgr.saveRelationList("members2mailinglist","memberId",arguments.memberId,"listID","")><!--- save an empty list to clear orphans --->
		<cfreturn true>
	</cffunction>

	<cffunction name="addmailinglistmembers">
		<cfargument name="email" required="yes">
		<cfargument name="Name" default="">
		<cfargument name="firstname" default="">
		<cfargument name="lastname" default="">
		<cfargument name="isVerified"  default="1">
		<cfargument name="memberof" default="">
		<cfset var results = StructNew()>
		<cfset var myId = 0>
		<cfset results.success = true>
		<cfset results.message = "">
		
		<cfif request.manage AND NOT can('add_member')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create this item."></cfif>
		<cfif len(Name) AND NOT len(arguments.firstName) AND NOT len(arguments.lastName)><!--- try to split name --->
			<cfif ListLen(Name, " ") GT 1>
				<cfset firstName = listFirst(Name, " ")>
				<cfset lastName = listRest(Name, " ")>
			<cfelse>
				<cfset lastName = Name>
				<cfset firstName = "">
			</cfif>
		</cfif>
			<!--- insert the mailinglistmembers --->
		<cftry>
		<cfset myId = application.DataMgr.insertRecord('mailinglistmembers', arguments)>
		<cfset application.DataMgr.saveRelationList("members2mailinglist","memberId",myid,"listID",arguments.memberof)>
		<cfcatch type="database">
				<cfset results.success = false />
				<cfset results.message = "Inserting the record failed.  The error details if available are as follows: " & CFCATCH.Detail />
				<cfset logger.fatal(results.message,  {type=cfcatch.Type, message=cfcatch.Message})>
				<cfrethrow>
		</cfcatch>
		</cftry>
		<cfreturn results>
	</cffunction>

	<cffunction name="updatemailinglistmembers" output="no" returntype="numeric">
		<cfargument name="memberID" required="yes" type="numeric">
		<cfargument name="email" required="yes">
		<cfargument name="Name" defualt="">
		<cfargument name="memberof" default="">
		<cfargument name="isverified" required="no">
		<cfif NOT can('edit_member')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this item."></cfif>
		<cfset application.DataMgr.saveRelationList("members2mailinglist","memberId",arguments.memberID,"listID",arguments.memberof)>
		<cfreturn application.DataMgr.updateRecord('mailinglistmembers', arguments)>
	</cffunction>
	
	<cffunction name="getMyLists" output="no" returntype="query">
		<cfargument name="memberId" required="yes">
		<cfreturn application.DataMgr.getRecords('members2mailinglist', arguments)>
	</cffunction>
	
	<cffunction name="getemailsList">
		<cfargument name="FilterSearchString" default="">
		<cfargument name="Orderby" default="emailID" required="no" type="string">
		<cfargument name="Sort" default="Desc" required="no" type="string">
		<cfquery name="qGetemails" datasource="#application.dsn#">
			SELECT     *
			FROM emails
			ORDER BY
			<cfswitch expression="arguments.orderby">
				<cfcase value="Subject">
				Subject
				</cfcase>
				<cfdefaultcase>
				emailID
				</cfdefaultcase>
			</cfswitch>
			<cfif arguments.sort EQ 'DESC'>
			DESC
			<cfelse>
			ASC
			</cfif>
		</cfquery>

		<cfreturn qGetemails>

	</cffunction>
	<cffunction name="getemails">
		<cfargument name="emailID" default="0">
		<cfreturn application.DataMgr.getRecord('emails', arguments)>
	</cffunction>

	<cffunction name="deleteemails">
		<cfargument name="emailID" default="0">
		<cfif NOT can('delete_mail')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this item."></cfif>
		<cfquery name="qDeleteemails" datasource="#application.dsn#">
			DELETE FROM emails
			WHERE emailID = <cfqueryparam value="#arguments.emailID#" cfsqltype="cf_sql_integer" />
		</cfquery>

		<cfreturn true>

	</cffunction>

	<cffunction name="addemails" output="no" returntype="numeric">
		<cfargument name="Subject" required="no">
		<cfargument name="BodyText" required="no">
		<cfargument name="BodyHTML" required="no">
		<cfargument name="DeliveryDate" required="no">
		<cfargument name="status" required="no">
		<cfargument name="GroupList" required="no">
		<cfargument name="LastUpdateBy" default="#Session.username#">
		<cfargument name="NumberSent" default="0">
		<cfargument name="ReplyTo" required="no">
		<cfargument name="format" required="no">
		<cfargument name="fromLabel" required="no">
		<cfargument name="isDeleted" default="no">
		<cfif NOT can('create_mail')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create this item."></cfif>
		<cfreturn application.DataMgr.insertRecord('emails', arguments)>
	</cffunction>

	<cffunction name="updateemails" output="no" returntype="numeric">
		<cfargument name="emailID" required="yes" type="numeric">
		<cfargument name="Subject" required="no">
		<cfargument name="BodyText" required="no">
		<cfargument name="BodyHTML" required="no">
		<cfargument name="CreatedDate" required="no">
		<cfargument name="DeliveryDate" required="no">
		<cfargument name="GroupList" required="no">
		<cfargument name="LastUpdateBy" default="#session.username#">
		<cfargument name="ReplyTo" required="no">
		<cfargument name="format" required="no">
		<cfargument name="fromLabel" required="no">
		<cfargument name="isDeleted" default="no">
		<cfif NOT can('edit_mail')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this item."></cfif>
		<cfreturn application.DataMgr.updateRecord('emails', arguments)>
	</cffunction>


	<cffunction name="sendemails">
		<cfargument name="emailID" required="yes" type="numeric">
		
		<cfif NOT can('send_mail')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this item."></cfif>
		<cfquery name="getemail" datasource="#application.dsn#">
		SELECT * FROM emails WHERE emailID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.emailID#">
		</cfquery>
		<cfif getemail.recordcount NEQ 1><cfthrow type="c3d.subscriptions.invalidEmailId" message="Invalid Email ID (cfc)."></cfif>
		<cfif NOT getemail.status><cfthrow type="c3d.subscriptions.sendNotAllowed" message="This Email is not approved for Sending."></cfif>
		<cfquery name="GetList" datasource="#application.dsn#">
		SELECT *
		FROM mailinglistmembers
			JOIN members2mailinglist ON mailinglistmembers.memberID = members2mailinglist.memberID
		WHERE
		1 = 1 AND
		( <cfloop list="#getemail.GroupList#" index="x">
		members2mailinglist.groupid =  <cfqueryparam cfsqltype="cf_sql_integer" value="#x#">
		<cfif x NEQ ListLast(getemail.GroupList)>
		OR
		</cfif>
		</cfloop>
		)
		</cfquery>
		<cfmail query="GetList" from="#getemail.fromLabel#" to="#GetList.email#" subject="#getemail.subject#" Replyto="#getemail.replyto#">
		<cfmailpart type="text" wraptext="74">
		<cfset format = 'text'><cfinclude template="../view/email_template.cfm">
		</cfmailpart>>
		<cfmailpart type="html">
		<cfset format = 'html'><cfinclude template="../view/email_template.cfm">
		</cfmailpart>
		</cfmail>
		
	</cffunction>

</cfcomponent>