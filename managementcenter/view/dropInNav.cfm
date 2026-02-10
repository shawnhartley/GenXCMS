	
    <cffunction name="printCatSelector2">
		<cfargument name="id" required="yes" type="numeric"><!---<cfabort showerror="gettttting here">--->
		<cfscript>
		var parents = getnewsCategories2();
		session.parentdebug = parents;
		var myCategories = getCategoriesForId2(arguments.id);
		var sb = createObject("java", "java.lang.StringBuilder").init();
		var splitAt = int(parents.recordcount / 2) + 2; // Split columns at this parents[index]
		var children = '';
		var ii = 1;
		var jj = 1;
		sb.append('<dl class="column">');
		for(ii = 1; ii LTE 2; ii++) {
			if(ii GTE splitAt) {
				sb.append('</dl><dl class="column">');
				splitAt = 3000;
			}
			children = getnewsCategories2(id=parents.landingID[ii]);
			sb.append('<dt>');
				if(children.recordcount) {
					sb.append('<a class="expand" >+</a>');
				} else {
					sb.append('<a class="expand spacer"></a>');
				}
				sb.append('<label>');
				if(parents.landingID[ii]) {
					sb.append('<input type="checkbox" name="category" value="#parents.landingID[ii]#" rel="parent:#parents.parent[ii]#"');
					sb.append( (myCategories['PAGESID'].indexOf(parents.landingID[ii]) + 1) ? ' checked="checked"' : ''); // this category already selected?
					sb.append(' /> ');
				}
				sb.append(parents.title[ii]);
				sb.append('</label>');
			if(children.recordcount) sb.append(' <a class="selector">Check All</a>');
			sb.append('</dt>');
			
			if(children.recordcount) {
				sb.append('<dd>');
				for(jj=1; jj LTE children.recordcount; jj++) {
					sb.append('<label>');
					//if(children.selectable[jj]) {
						sb.append('<input type="checkbox" name="category" value="#children.landingID[jj]#" rel="parent:#children.parent[jj]#"');
						sb.append( (myCategories['PAGESID'].indexOf(children.landingID[jj]) + 1) ? ' checked="checked"' : ''); // this category already selected?
						sb.append(' /> ');
					//}
					sb.append(children.title[jj]);
					sb.append('</label>');
				}
				sb.append('</dd>');
			}
		}
		sb.append('</dl>');
		return sb.toString();
		</cfscript>
	</cffunction>

	<cffunction name="getnewsCategories2">
		<cfargument name="id" default="0">
		<cfargument name="parent" default="-1">   
			<cfquery name="qGetnews_categories" datasource="#application.dsn#">
				SELECT *
				  FROM [nrccorp].[nrccorp].[page]
				 WHERE 1 = 1
					<cfif arguments.id eq 0>
                    and landingid in (1,11) 
                    or parent = 11
                    <cfelseif arguments.id eq 1>
                    and landingid = -1
                    <cfelseif arguments.id eq 11>
                    and parent = 11
                    </cfif>
                
				ORDER BY   parent, title
			</cfquery>

		<cfreturn qGetnews_categories>
	</cffunction>
	
	<cffunction name="getCategoriesForId2">
		<cfargument name="id" required="yes" type="numeric">
            <cfquery name="insertxRefArticlesToPages" datasource="#application.dsn#">
                Select pagesid
                      ,articlesid
                      ,articlesType
                      ,articlesSubType
                      ,corpAttach from [nrccorp].[dbo].[xRefArticlesToPages]
               where articlesid = #arguments.id# 
             </cfquery>       
		<cfreturn insertxRefArticlesToPages>
	</cffunction>
    
    
    <cffunction name="insertxRefArticlesToPages">
        
        <!---first delete the instances.--->
            <cfquery name="insertxRefArticlesToPages" datasource="#application.dsn#">
                delete from  [nrccorp].[dbo].[xRefArticlesToPages]
                 where articlesid = <cfqueryparam cfsqltype="cf_sql_numeric" value="#form.id#">
            </cfquery>
            <!---'set the records---> 
            <cfloop list="#form.category#" index="i"> 
 			<cfif isdefined("form.cat")>
			<cfset resourceCat = form.cat>
            <cfelse>
            <cfset resourceCat = 0>
            </cfif>            
			<cfif i eq 1>
			<cfset corpAttach = 1>
            </cfif>      
            <cfquery name="insertxRefArticlesToPages" datasource="#application.dsn#">
                INSERT INTO [nrccorp].[dbo].[xRefArticlesToPages]
                           (pagesid
                           ,articlesid
                           ,articlesType
                           ,articlesSubType
                           ,corpAttach)
                     VALUES
                           (<cfqueryparam cfsqltype="cf_sql_numeric" value="#i#">
                           ,<cfqueryparam cfsqltype="cf_sql_numeric" value="#form.id#">
                           ,<cfqueryparam cfsqltype="cf_sql_numeric" value="1">
                           ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#resourceCat#">
                           ,<cfqueryparam cfsqltype="cf_sql_numeric" value="#corpAttach#">)
            </cfquery>
            <cfset corpAttach =0>
            </cfloop>
		<cfreturn>
	</cffunction>
	
<!---	<cffunction name="updatexRefArticlesToPages">
		<cfargument name="pagesid" required="yes">
        <cfargument name="articlesid" required="yes">
        <cfargument name="articlesType" required="yes">
        <cfargument name="articlesSubType" required="yes">
        <cfargument name="corpAttach" required="yes">
            <cfquery name="updatexRefArticlesToPages" datasource="#application.dsn#">
                UPDATE [nrccorp].[dbo].[xRefArticlesToPages]
                   SET [pagesid] = pagesid
                      ,[articlesid] = articlesid
                      ,[articlesType] = articlesType
                      ,[articlesSubType] = articlesSubType
                      ,[corpAttach] = corpAttach
                 WHERE blah = 'blah'
            </cfquery>        
		<cfreturn application.DataMgr.getRecords('news2categories', {newsid = arguments.id})>
	</cffunction>--->
    