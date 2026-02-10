<cfcomponent extends="Event" output="no">
	<cffunction name="uploadAndResize" access="public" returntype="struct">
		<cfargument name="imageField" required="yes">
		<cfset var results = {success = false, fileName = ''}>

			<!--- Check path existence --->
			<cfif NOT DirectoryExists( ExpandPath( '/images/' ) )>
				<cfdirectory action="create" directory="#ExpandPath( '/images' )#">
			</cfif>
			<cfif NOT DirectoryExists( ExpandPath( application.settings.var('images.path') ) )>
				<cfdirectory action="create" directory="#ExpandPath( application.settings.var('images.path') )#" mode="775">
			</cfif>
			<cfif NOT DirectoryExists( ExpandPath( application.settings.var('images.path') & 'original/' ) )>
				<cfdirectory action="create" directory="#ExpandPath( application.settings.var('images.path')  & 'original' )#" mode="775">
			</cfif>
			<cfif NOT DirectoryExists( ExpandPath( application.settings.var('images.path') & 'medium/' ) )>
				<cfdirectory action="create" directory="#ExpandPath( application.settings.var('images.path')  & 'medium' )#" mode="775">
			</cfif>
			<cfif NOT DirectoryExists( ExpandPath( application.settings.var('images.path')  & 'thumb/' ) )>
				<cfdirectory action="create" directory="#ExpandPath( application.settings.var('images.path')  & 'thumb' )#" mode="775">
			</cfif>
			<cfif NOT DirectoryExists( ExpandPath( application.settings.var('images.path')  & 'tiny/' ) )>
				<cfdirectory action="create" directory="#ExpandPath( application.settings.var('images.path')  & 'tiny' )#" mode="775">
			</cfif>
			
			<cffile action="upload" filefield="#arguments.imageField#" destination="#ExpandPath(application.settings.var('images.path') & 'original/')#" nameconflict="makeunique" result="uploadresult">
			<cfset results.fileName = uploadresult.serverFile>
			<cfimage action="read" name="myImage" source="#ExpandPath( application.settings.var('images.path') & 'original/' & results.fileName )#">

			<!--- Medium Creation --->
			<cfset resize( myimage = myimage
						  	, destination = application.settings.var('images.path') & 'medium/' & results.fileName
							, maxwidth = application.settings.var('images.resizewidth')
							, maxheight = application.settings.var('images.resizeheight')
						) >
			<!--- Thumb Creation --->
			<cfset resize( myimage = myimage
						  	, destination = application.settings.var('images.path') & 'thumb/' & results.fileName
							, maxwidth = application.settings.var('images.thumbwidth')
							, maxheight = application.settings.var('images.thumbheight')
						) >
			<!--- Tiny Creation --->
			<cfset resize( myimage = myimage
						  	, destination = application.settings.var('images.path') & 'tiny/' & results.fileName
							, maxwidth = 35
							, maxheight = 35
						) >
			<cfif application.settings.var('images.deleteOriginals')>
				<cfif FileExists(ExpandPath( application.settings.var('images.path') & 'original/' & results.filename ))>
					<cffile action="delete" file="#ExpandPath( application.settings.var('images.path') & 'original/' & results.filename )#">
				</cfif>
			</cfif>
			<cfset results.success = true>
		<cfreturn results>
	</cffunction>
	
	<cffunction name="resize" output="no">
		<cfargument name="myimage" required="yes" hint="cfimage object">
		<cfargument name="destination" required="yes" hint="Destination: relative to web root with filename">
		<cfargument name="maxwidth" default="0">
		<cfargument name="maxheight" default="0">
		<cfif NOT (maxwidth OR maxheight)>
			<cfthrow type="c3d.image.resize" message="You must provide either a max width, height, or both.">
		</cfif>
		
		<cfimage action = "info" source = "#myimage#" structname = "info">
		<cfset widthPCT = 100>
		<cfset heightPCT = 100>
		<cfset pct = 100>
		<cfif info.width LTE maxwidth AND info.height LTE maxheight> <!--- Don't resize, just copy the image out --->
			<cfimage action="write" source="#arguments.myImage#" destination="#ExpandPath(arguments.destination)#" overwrite="true" quality=".93">
			<cfreturn>
		</cfif>
		
		<cfif maxwidth LT info.width>
			<cfset widthPCT = (maxwidth / info.width) * 100>
		</cfif>
		
		<cfif maxheight LT info.height>
			<cfset heightPCT = (maxheight / info.height) * 100>
		</cfif>
		
		<cfif widthPCT GTE heightPCT>
			<cfset pct = heightPCT>
		<cfelse>
			<cfset pct = widthPCT>
		</cfif>
		
		<cfimage
			action = "resize"
			height = "#pct#%"
			width = "#pct#%"
			source = "#arguments.myimage#"
			destination = "#ExpandPath(arguments.destination)#"
			>

		
	</cffunction>
	<cffunction name="delete">
		<cfargument name="filename" required="yes">
		<cfif FileExists(ExpandPath( application.settings.var('images.path') & 'original/' & arguments.filename ))>
		<cffile action="delete" file="#ExpandPath( application.settings.var('images.path') & 'original/' & arguments.filename )#">
		</cfif>
		<cfif FileExists(ExpandPath( application.settings.var('images.path') & 'medium/' & arguments.filename ))>
		<cffile action="delete" file="#ExpandPath( application.settings.var('images.path') & 'medium/' & arguments.filename )#">
		</cfif>
		<cfif FileExists(ExpandPath( application.settings.var('images.path') & 'thumb/' & arguments.filename ))>
		<cffile action="delete" file="#ExpandPath( application.settings.var('images.path') & 'thumb/' & arguments.filename )#">
		</cfif>
		<cfif FileExists(ExpandPath( application.settings.var('images.path') & 'tiny/' & arguments.filename ))>
		<cffile action="delete" file="#ExpandPath( application.settings.var('images.path') & 'tiny/' & arguments.filename )#">
		</cfif>

	</cffunction>
</cfcomponent>