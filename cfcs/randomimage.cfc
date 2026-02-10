<cfcomponent output="no" extends="Event">
<cffunction name="init"><cfthrow type="c3d.todo" message="RandomImage needs to be updated to use capabilities and pull image processing into the cfc."></cffunction>
<cffunction name="getImage" access="public" returntype="string">
	<cfif application.imagepool EQ "">
		<cfreturn "">
	</cfif>
	<cfdirectory action="list" filter="*.JPG" directory="#ExpandPath(application.settings.Var('randomimage.imagepool'))#" name="imagelist">
    <cfif imagelist.recordcount GT 0>
		<cfset imagestart = randrange(1,imagelist.recordcount)>
        <cfloop query="imagelist" startrow="#imagestart#" endrow="#imagestart#" >
        <cfset sideImage = imagelist.name>
        </cfloop>
		<cfreturn sideImage>
    <cfelse>
    	<cfreturn "">
    </cfif>
</cffunction>

<cffunction name="getfileList" access="public" returntype="query" output="no">
	<cfdirectory action="list" name="list" directory="#ExpandPath(application.settings.Var('randomimage.imagepool'))#">

	<cfreturn list>
</cffunction>


<cffunction name="getRandom">
	<cfargument name="limit" type="numeric" default="1">
	<cfdirectory action="list" filter="*.JPG" directory="#ExpandPath(application.settings.Var('randomimage.imagepool'))#" name="imagelist">
	
	<cfquery dbtype="query" name="addrand">
		SELECT *, '' AS sorter FROM imagelist
	</cfquery>
	<cfloop query="addrand">
		<cfset querySetCell(addrand,"sorter",rand(),currentRow)>
	</cfloop>
	<cfquery dbtype="query" name="rand" maxrows="#arguments.limit#">
		SELECT * FROM addrand ORDER BY sorter
	</cfquery>
	<cfreturn rand>
</cffunction>
</cfcomponent>