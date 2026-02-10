<cfcomponent extends="Event" output="no">
    <cffunction name="init" output="no">
            <cfset Super.init()>
        <cfreturn this>    
    </cffunction>
    
    <cffunction name="findparentSetNewParent">
    	<cfargument name="landingid" required="yes" type="numeric">    
        <cfargument name="parent" required="yes" type="numeric" default="0">
        <cfargument name="parentName" required="no" type="string"> 
        
        <!---Set the new parent--->    
        <cfset SetNew(argumentCollection=arguments)>
        <!---Call the child list creator and begin the spin through of duplication--->
        <cfset getKids(arguments.landingid,bringBackIds.newParent)>   
    </cffunction>
    
    <cffunction name="SetNew" returntype="any">
        <cfargument name="landingid" required="yes" type="numeric">  
        <cfargument name="parent" required="yes" type="numeric" default="0">
        <cfargument name="parentName" required="no" type="string">
        
            <cfset bringBackIds = structnew()>
            
            <cfif arguments.parent neq 0>
            <cfset settersoverride = structnew()>
            <cfset settersoverride.landingid = arguments.landingid>
            <cfset setNext = application.datamgr.getrecord("page",settersoverride)>
            <cfelse>
            <cfset setNext = application.datamgr.getrecord("page",arguments)>
            </cfif>
            
            <cfset arrStruct = QueryToStruct( setNext ) />  
            
            <cfquery datasource="#application.dsn#" name="maxi">
            Select max(landingid)+1 as masterID from page
            </cfquery>  

			<cfif isdefined("arguments.parentName")>       
                <cfset arrStruct[1].title = "#arguments.parentName#">
                <cfset arrStruct[1].URL = "#arguments.parentName#">     
            </cfif>
			
			<cfset arrStruct[1].landingid = maxi.masterID>
            
            <cfif arguments.parent neq 0>
            <cfset arrStruct[1].parent = arguments.parent>
            </cfif>
            <cftry> 
            <cfset markerNew = application.datamgr.insertRecord(tablename='page',data=arrStruct[1],OnExists='insert')>
            <cfcatch type="any">
            <cfoutput>#CFCATCH.Message#<br>meaning there is already a url with this title/URL address...go back and try again.</cfoutput>
            <cfabort>
            </cfcatch>
            </cftry>
			<cfset bringBackIds.newParent = markerNew>
            <cfset bringBackIds.oldParent = arguments.landingid>          
        <cfreturn bringBackIds>       
    </cffunction>
    
    <cffunction name="getKids" returntype="any">
        <cfargument name="parentID" required="yes" type="numeric" hint="this is the newly assigned parent id we are building a new tree from the top down.">
        <cfargument name="newParentID" required="yes" type="numeric" hint="this is the newly assigned parent id we are building a new tree from the top down.">
        <cfset var getKidsA = StructNew() />
                <!---get the children--->
                <cfquery name="getKidsA.children" datasource="#application.dsn#" >
                    SELECT landingid, parent 
                    FROM page 
                    WHERE 1=1
                    and parent = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.parentID#">
                </cfquery>
            
            <!---If the query is good it loops if not it ends right here--->
            <cfif getKidsA.children.recordcount>
            <cfloop query="getKidsA.children">
                <cfset SetNew(getKidsA.children.landingid,arguments.newParentID)>        
                <cfset getKids(parentID=getKidsA.children.landingid,newParentID=bringBackIds.newParent)>
            </cfloop>
            </cfif>
        <cfreturn>     
    </cffunction>
    
    <cffunction name="QueryToStruct" access="public" returntype="any" output="false"
        hint="Converts an entire query or the given record to a struct. This might return a structure (single record) or an array of structures.">
        <cfargument name="Query" type="query" required="true" />
        <cfargument name="Row" type="numeric" required="false" default="0" />
    
        <cfscript>
            var LOCAL = StructNew();
            if (ARGUMENTS.Row){
                LOCAL.FromIndex = ARGUMENTS.Row;
                LOCAL.ToIndex = ARGUMENTS.Row;
            } else {
                LOCAL.FromIndex = 1;
                LOCAL.ToIndex = ARGUMENTS.Query.RecordCount;
            }
            LOCAL.Columns = ListToArray( ARGUMENTS.Query.ColumnList );
            LOCAL.ColumnCount = ArrayLen( LOCAL.Columns );
            LOCAL.DataArray = ArrayNew( 1 );
            for (LOCAL.RowIndex = LOCAL.FromIndex ; LOCAL.RowIndex LTE LOCAL.ToIndex ; LOCAL.RowIndex = (LOCAL.RowIndex + 1)){
                ArrayAppend( LOCAL.DataArray, StructNew() );
                LOCAL.DataArrayIndex = ArrayLen( LOCAL.DataArray );
                for (LOCAL.ColumnIndex = 1 ; LOCAL.ColumnIndex LTE LOCAL.ColumnCount ; LOCAL.ColumnIndex = (LOCAL.ColumnIndex + 1)){
                    LOCAL.ColumnName = LOCAL.Columns[ LOCAL.ColumnIndex ];
                    LOCAL.DataArray[ LOCAL.DataArrayIndex ][ LOCAL.ColumnName ] = ARGUMENTS.Query[ LOCAL.ColumnName ][ LOCAL.RowIndex ];
                }
            }
            if (ARGUMENTS.Row){
                return( LOCAL.DataArray[ 1 ] );
            } else {
                return( LOCAL.DataArray );
            }
        </cfscript>
    </cffunction>
</cfcomponent>