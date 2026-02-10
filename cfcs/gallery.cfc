<cfcomponent extends="Event" output="no">
    <cffunction name="init" output="no">
		<cfset Super.init()>
		<cfset this.image = createObject("component", "image").init()>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getGalleries" output="no">
		<cfargument name="id" default="0" type="numeric">
		<cfif request.manage AND NOT can('read')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>
		<cfquery name="qgalleries" datasource="#application.dsn#">
			SELECT galleries.*, count(gallery_images.id) AS numImages
  FROM galleries LEFT JOIN gallery_images ON galleries.id = gallery_images.galleryId

				WHERE 1 = 1
				<cfif arguments.id NEQ 0>
					AND galleries.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
				</cfif>
				GROUP BY galleries.id
				ORDER BY galleries.sortorder, galleries.galleryName
		</cfquery>
		<cfreturn qgalleries>
	</cffunction>
	<cffunction name="deleteGallery" output="no">
	     	<cfargument name="id" default="0">
			<cfif NOT can('delete')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this gallery."></cfif>
			<cfquery name="qIsPublished" datasource="#application.dsn#">
				SELECT id FROM galleries
					WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
					AND status = 1
			</cfquery>	
			<cfif qIsPublished.recordcount AND NOT can('delete_published')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this gallery."></cfif>
			<cfquery name="qDeleteGallery" datasource="#application.dsn#">
				DELETE FROM     galleries
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
			<cfreturn true>
	</cffunction>

	<cffunction name="insertGallery" output="no" returntype="numeric">
		<cfargument name="galleryName" required="yes" type="string">
		<cfargument name="sortorder" default="10" type="numeric">
		<cfargument name="galleryDescription" default="" type="string">
		<cfargument name="status" default="0" type="boolean">
			<cfif NOT can('create')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create a gallery."></cfif>
			<cfif NOT can('publish')><cfset arguments.status = false></cfif>
			
			<cfreturn application.DataMgr.insertRecord('galleries', arguments)>
	</cffunction>

	<cffunction name="updateGallery">
		<cfargument name="id" required="yes" type="numeric">
		<cfargument name="galleryName" required="yes">
		<cfargument name="galleryDescription" default="">
			<cfif NOT can('edit')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this gallery."></cfif>
			<cfquery name="qIsPublished" datasource="#application.dsn#">
				SELECT id FROM galleries
					WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
					AND status = 1
			</cfquery>	
			<cfif qIsPublished.recordcount AND NOT can('edit_published')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this gallery."></cfif>
			<cfreturn application.DataMgr.updateRecord('galleries', arguments)>
	</cffunction>
	
	<cffunction name="activate" output="no">
		<cfargument name="function" default="none">
		<cfargument name="id" default="0">
		<cfset var active = 0>
		<cfif NOT can('publish')><cfthrow type="c3d.notPermitted" message="You do not have permissions to publish this gallery."></cfif>
		<cfif function EQ "activate">
			<cfset active = 1>
		</cfif>
		<cfquery datasource="#application.dsn#" name="ins">
			UPDATE galleries  SET status = <cfqueryparam cfsqltype="cf_sql_integer" value="#active#">
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	
	<cffunction name="getGalleryImages" output="no">
		<cfargument name="galleryId" required="yes" type="numeric">
		<cfif request.manage AND NOT can('read_images')><cfthrow type="c3d.notPermitted" message="You do not have permissions to view gallery images."></cfif>
		<cfquery datasource="#application.dsn#" name="qImages">
			SELECT * FROM gallery_images 
				WHERE galleryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.galleryId#">
				ORDER BY sortOrder, dateCreated
		</cfquery>
		<cfreturn qImages>
	</cffunction>
	
	<cffunction name="uploadImage" output="no">
		<cfargument name="imageField" required="yes">
		<cfargument name="galleryId" required="yes">
		<cfif NOT can('uploadImages')><cfthrow type="c3d.notPermitted" message="You do not have permissions to upload images"></cfif>
		<cfset result = this.image.uploadAndResize(argumentcollection=arguments)>
		<cfif result.success>
			<cfset application.DataMgr.insertRecord('gallery_images', {fileName = result.fileName, galleryId = arguments.galleryId, status = can('publish_images')})>
		</cfif>
	</cffunction>
	
	<cffunction name="updateImage">
		<cfargument name="caption" default="">
		<cfargument name="sortorder" default="10">
		<cfargument name="id" required="yes">
		<cfif NOT can('edit_images')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this image."></cfif>
		<cfquery name="qIsPublished" datasource="#application.dsn#">
			SELECT id FROM gallery_images
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
				AND status = 1
		</cfquery>	
		<cfif qIsPublished.recordcount AND NOT can('edit_published_images')><cfthrow type="c3d.notPermitted" message="You do not have permissions to edit this image."></cfif>
		<cfquery datasource="#application.dsn#" name="updImage">
			UPDATE gallery_images SET
					imageDescription = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.caption#">
					,sortorder = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sortorder#">
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	
	<cffunction name="imageActivate" output="no">
		<cfargument name="function" default="none">
		<cfargument name="id" default="0">
		<cfset var active = 0>
		<cfif NOT can('publish_images')><cfthrow type="c3d.notPermitted" message="You do not have permissions to publish this image."></cfif>
		<cfif function EQ "activate">
			<cfset active = 1>
		</cfif>
		<cfquery datasource="#application.dsn#" name="ins">
			UPDATE gallery_images  SET status = <cfqueryparam cfsqltype="cf_sql_integer" value="#active#">
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>
	
	<cffunction name="deleteImage" output="no">
		<cfargument name="id" default="0">
		<cfargument name="filename" required="yes">
			<cfif NOT can('delete_images')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this image."></cfif>
			<cfquery name="qIsPublished" datasource="#application.dsn#">
				SELECT id FROM gallery_images
					WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
					AND status = 1
			</cfquery>	
			<cfif qIsPublished.recordcount AND NOT can('delete_published_images')><cfthrow type="c3d.notPermitted" message="You do not have permissions to delete this image."></cfif>

			<cfquery name="qDeleteGallery" datasource="#application.dsn#">
				DELETE FROM     gallery_images
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
			
			<!--- Delete image files --->
			<cfset this.image.delete(filename = arguments.filename)>
			<cfreturn true>
	</cffunction>



</cfcomponent>