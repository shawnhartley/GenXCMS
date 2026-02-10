<!--- Check login status set params--->
<cfset application.helpers.checkLogin()>
<cfparam name="url.landingId" default="0">
<cfparam name="form.author" default="#session.username#">
<cfparam name="url.id" default="0">
<cfparam name="form.redirectpage" default="">
<cfset error = {message = ''}>
<cftry>
    <cfif isdefined('form.action')>
        <cfif form.Action is "insert">
            <cfset event.addpages(argumentcollection=form)>
        </cfif>
        <cfif form.action eq "update">
            <cfset event.updatepages(argumentcollection=form)>
        </cfif>
        <cfif form.action eq "delete">
            <cfset event.deletepages(argumentcollection=form)>
        </cfif>
        <cfif not isdefined("form.quicksave")>
            <cfif len(form.redirectpage)>
                <cflocation addtoken="no" url="#form.redirectpage#">
            </cfif>
        </cfif>
        <!---<cflocation url="#buildURL(event='pages', args='msg=1&marker=#form.id#', encode=false)#" addtoken="no">--->
    </cfif>
    <cfcatch>
        <cfset error = cfcatch>
    </cfcatch>
</cftry>

<cfset request.pagesquery = arrayNew(1)>
<cfset getpage = event.getPage(id=url.id)>

<cfif getpage.recordcount EQ 0 >
    <cfset page.sortorder = 10>
    <cfset page.parent = 0>
    <cfset page.approved = false>
    <cfelse>
    <cfset page.sortorder = getpage.sortorder>
    <cfset page.parent = getpage.parent>
    <cfset page.approved = getpage.approved>
</cfif>

<!---Starting the actual page--->

<cfoutput>
    <cfif len(error.message)>
        <p class="error"><strong>Error:</strong> #error.message#<br />
            <cfif error.detail CONTAINS 'Duplicate entry'>
                <em>This url has already been used in this section.</em>
                <cfelse>
                <em>#error.detail#</em>
            </cfif>
        <cfif structKeyExists(url, 'debug')>
            <pre>#error.ExtendedInfo#</pre>
        </cfif>
        </p>
        <cfelse>
<div>        
        <cfif url.function eq "Add">
            Add
            <cfelseif url.function eq "edit">
            Edit
            <cfelse>
            Delete
        </cfif>
        Page
        
         - <a href="#buildURL(event="pages")#">Return To List</a>
         <br />
        
        <cfif page.approved AND NOT event.can('edit_published')>
            <p class="error"><strong>Note:</strong> You are not able to edit this page.</p>
        </cfif>

            <form action="#buildURL(event="pages", action="edit", id=url.id, args="function=#url.function#")#" 
                  method="post" 
                  name="frmpage" 
                  enctype="multipart/form-data">
                <label>Page Title:</label>
                <br />
                <input type="text" name="title" value="#getpage.title#">
                <br />
                <label>Page Url:</label>
                <br />
                <input placeholder="Leave blank to use page title" type="text" name="url" value="#getpage.url#">
                <br />
                <cfif settings.Var('pages.redirect')>
                    <label>This page is a?</label>
                    <br />
                    <input type="radio" name="redirect" value="0" <cfif getpage.redirect NEQ 1> checked="checked"</cfif> />
                    Content Page <br />
                    <input type="radio" name="redirect" value="1" <cfif getpage.redirect EQ 1> checked="checked"</cfif> />
                    Link to a URL
                    <div class="redirectpage">
                        <label>Point to URL:</label>
                        <br />
                        <input type="text" name="redirecturl" value="#getpage.redirecturl#" />
                    </div>
                    <cfelseif url.id GT 0>
                    <input type="hidden" name="redirect" value="#getpage.redirect#" />
                    <cfelse>
                    <input type="hidden" name="redirect" value="0" />
                </cfif>
                <label>Page Content:</label>
                <br/>
                <textarea class="ckeditor" name="contentleft">#HTMLEditFormat(getpage.contentleft)#</textarea>
                <cfif application.settings.var('pages.dualContent')>
                    <label>Extra Sidebar Content:</label>
                    <br/>
                    <textarea name="contentright" class="ckeditor">#HTMLEditFormat(getpage.contentright)#</textarea>
                    <cfelse>
                    <input type="hidden" name="contentright" value="#getpage.contentright#">
                </cfif>
                <cfif url.function eq 'add' OR url.function eq 'edit'>
                    <br />
                    <button class="submit" type="submit" name="quickSave" value="1" tabindex="30">Quick Save</button>
                </cfif>
                <br />
                <button class="openClose" type="button" name="">Seo Options</button>
                <div class="hideit" style="border-style:dashed; border-width:1px; padding:3px;">
                    <label>Meta Description:</label>
                    <br/>
                    <textarea name="metaDescription" cols="50" rows="5">#getpage.metaDescription#</textarea>
                    <br />
                    <label>Meta Keywords:</label>
                    <br/>
                    <textarea name="metaKeywords" cols="50" rows="5">#getpage.metaKeywords#</textarea>
                    <br />
                    <label>SEO Page Title:</label>
                    <br/>
                    <input type="text" name="seotitle" value="#getpage.seotitle#">
                    <br />
                    <label>Custom facebook description:</label>
                    <br/>
                    <textarea name="fbDescription" cols="50" rows="5">#getpage.fbDescription#</textarea>
                    <br />
                    <label>Image file for Facebook and Twitter:</label>
                    <br />
                    Current Facebook and Twitter Image: <cfoutput>#getpage.fbTwitterImage#</cfoutput> <br/>
                    <cfif getpage.fbTwitterImage neq ''>
                        <input type="checkbox" name="removefbTwitterImage" value="1" />
                        : Delete Facebook and Twitter Image
                    </cfif>
                    <br />
                    <input type="file" name="fbTwitterImage">
                    <input type="hidden" name="fbTwitterImageExisting" value="<cfoutput>#getpage.fbTwitterImage#</cfoutput>">
                    <br />
                    <br />
                    <label>Custom facebook title:</label>
                    <br/>
                    <input type="text" name="fbTitle" value="#getpage.fbTitle#">
                    <br />
                    <label>Custom Twitter title:</label>
                    <br/>
                    <input type="text" name="twitterTitle" value="#getpage.twitterTitle#">
                </div>
                <br />
                <cfif ListContains(Session.UserPermissions, "5") or ListContains(Session.UserPermissions, "0")>
                    <div style="position:relative;float:left;padding-right:15px;">
                        <label>Publish</label>
                        <br />
                        <input type="radio" name="isDraft" value="1" <cfif getpage.isDraft neq 0> checked="checked"</cfif> />
                        Save as Draft Copy <br />
                        <input type="radio" name="isDraft" value="0" <cfif getpage.isDraft eq 0> checked="checked"</cfif> />
                        Publish<br/>
                        <br />
                    </div>
                </cfif>
                <cfif event.can('edit_published')>
                    <div style="position:relative;float:left;padding-right:15px;">
                        <label>Approve</label>
                        <br />
                        <input type="radio" name="approved" value="0"  <cfif getpage.approved neq "1">checked="checked"</cfif> />
                        NOT approved <br />
                        <input type="radio" name="approved" value="1" <cfif getpage.approved eq "1">checked="checked"</cfif> />
                        Approved<br />
                        <br />
                    </div>
                </cfif>
                <div style="position:relative;float:left;padding-right:15px;">
                    <label>Show in Site Navbar?</label>
                    <br/>
                    <input type="radio" name="showNav" value="1" <cfif getpage.showNav neq 0> checked="checked"</cfif> />
                    Yes<br />
                    <input type="radio" name="showNav" value="0" <cfif getpage.showNav eq 0> checked="checked"</cfif> />
                    No<br />
                </div>
                <div style="position:relative;float:left;padding-right:15px;">
                    <label>Sort Order:</label>
                    <br/>
                    <input type="text" name="sortorder" id="sortorder" value="#page.sortorder#" />
                    <br />
                </div>
                <br />
                <cfif not event.can('edit_published')>
                    <input type="hidden" name="approved" id="approved" value="0">
                </cfif>
                <div style="clear:both;"></div>
                <label>Place this page within:</label>
                <br />
                #event.printParentSelect(current=page.parent)#
                <cfif settings.var('modules') CONTAINS 'PrivateContent'>
                    <ul>
                        <li class="permissions">
                            <label>Access Control:</label>
                            <br />
                            <br />
                            <cfloop query="event.pagePermissions">
                                <div> #currentrow#:
                                    <select name="rw">
                                        <option value="r">To View this page:</option>
                                    </select>
                                    <select name="limitMethod">
                                        <option value="require-group"<cfif method EQ 'require-group'> selected="selected"</cfif>>Require User to be a member of this group:</option>
                                        <option value="require-user"<cfif method EQ 'require-user'> selected="selected"</cfif>>Require This Specific User:</option>
                                        <option value="require-valid-user"<cfif method EQ 'require-valid-user'> selected="selected"</cfif>>Require viewer to be logged in</option>
                                    </select>
                                    <input type="text" name="limitArg" value="#argument#">
                                    <a href="##" class="removePermissionField">Clear</a> </div>
                            </cfloop>
                        </li>
                        <li><a href="##" class="addPermissionField">Add Access Limit</a>
                            <input type="hidden" name="limitArg" value="" />
                            <input type="hidden" name="limitMethod" value="" />
                            <input type="hidden" name="rw" value="" />
                        </li>
                    </ul>
                </cfif>
                <!--- insert hidden fields and determine/create submit button action --->
                <cfif settings.var('content.showCustomFields')>
                    <p class="customfields">
                        <label>Custom Fields:</label>
                    <cfloop query="event.cachedCustomFields">
                        <div> #currentrow#:
                            <input type="text" name="customfield" value="#field#">
                            <input type="text" name="customvalue" value="#value#">
                            <a href="##" class="removeCustomField">Clear</a> </div>
                    </cfloop>
                    <div>#event.cachedCustomFields.recordCount + 1#:
                        <input type="text" name="customfield" value="">
                        <input type="text" name="customvalue" value="">
                        <a href="##" class="removeCustomField">Clear</a> </div>
                    <a href="##" class="addCustomField">Add Field</a>
                    <input type="hidden" name="customfield" value="" />
                    <input type="hidden" name="customvalue" value="" />
                    </p>
                </cfif>
                <br />
                <br />
                <button class="openCloseb" type="button" name="">Optional Notes</button>
                <div class="hideitb" style="border-style:dashed; border-width:1px; padding:3px;">
                    <label>To yourself or your team:</label>
                    <br/>
                    <textarea name="notes" cols="40" rows="6" tabindex="10">#getpage.notes#</textarea>
                    </li>
                </div>
                <input type="hidden" name="id" value="#url.id#">
                <cfswitch expression="#url.function#">
                    <cfcase value="add">
                    <input type="hidden" name="redirectpage" value="#buildURL(event='pages', args='marker=#url.id#', encode=false)#" />
                    <button class="submit" type="submit" tabindex="30">Add Page</button>
                    <input type="hidden" name="action" value="insert">
                    </cfcase>
                    <cfcase value="edit">
                    <cfif page.approved AND NOT event.can('edit_published')>
                        <p class="error"><strong>Note:</strong> You are not able to edit this page.</p>
                        <cfelse>
                        <input type="hidden" name="redirectpage" value="#buildURL(event='pages', args='marker=#url.id#', encode=false)#" />
                        <button class="submit" type="submit" tabindex="30">Update Page</button>
                        <input type="hidden" name="action" value="update">
                    </cfif>
                    </cfcase>
                    <cfcase value="delete">
                    <cfif page.approved AND NOT event.can('delete_published')>
                        <p class="error"><strong>Note:</strong> You are not able to delete this page.</p>
                        <cfelse>
                        <input type="hidden" name="redirectpage" value="#buildURL(event='pages', args='marker=#page.parent#', encode=false)#" />
                        <button class="submit" type="submit" tabindex="30" onclick="return confirm('Are you sure you want to delete this record from the database?')">Delete Page</button>
                        <input type="hidden" name="action" value="delete">
                    </cfif>
                    </cfcase>
                </cfswitch>
                <br />
                
                <!---<input type="hidden" name="redirectpage" value="#cgi.HTTP_REFERER#" />--->
            </form>
        </div>
    </cfif>
    <!--- END error if-else ---> 
</cfoutput> 

<!---get the depth query---><!---
<cfset depthQuery = pAdvanced()>


<cfoutput query="depthQuery" group="depth">
<select class="#pageName##landingID#" name="parentaltalt" size="15">
<option value="">--</option>
<cfoutput><option value="#landingID#" <cfif parent neq 0>class="#parent#"</cfif> <cfif page.parent eq 0 AND landingID eq 0>selected="selected"</cfif><cfif selectedMe eq 1>selected="selected"<cfelseif selectedMe eq 2>disabled="disabled"</cfif> onclick='$("##inputboxID").val(this.innerText)'>#pageName#</option>
</cfoutput>
</select>
</cfoutput>
<script>
$( document ).ready(function() { 
$("#inputsb").click(function() { $("#kerfuffle").val($(this).text()); });
});
</script>
<br />
<input name="kerfuffle" value="" type="text" id="inputboxID"/>
<cffunction name="pAdvanced" output="no" returntype="query">    
<cfscript>    
var depthQuery = queryNew('depth,landingID,pageName,parent,parentName,selectedMe');
var listArray = listtoarray(printSelectAdvanced(self=event.id,current=page.parent),'|');
var list = "";
for (item in listArray){
list = item;
queryAddRow(depthQuery);
querySetCell(depthQuery,"depth","#listGetAt(list,1,',')#");
querySetCell(depthQuery,"landingID","#listGetAt(list,2,',')#");
querySetCell(depthQuery,"pageName","#listGetAt(list,3,',')#");
querySetCell(depthQuery,"parent","#listGetAt(list,4,',')#");
querySetCell(depthQuery,"parentName","#listGetAt(list,5,',')#");
querySetCell(depthQuery,"selectedMe","#listGetAt(list,6,',')#");
}
/*return depthQuery;*/
</cfscript>
<cfquery dbtype="query" name="depthQuery">
SELECT * FROM depthQuery ORDER BY depth, pageName
</cfquery>
<cfreturn depthQuery>
</cffunction>

<cffunction name="printSelectAdvanced" output="yes" returntype="string">
<cfargument name="current" default="0" type="numeric">
<cfargument name="parent" default="0" type="numeric">
<cfargument name="self" default="#url.id#" type="numeric">
<cfargument name="BaseDepth" type="numeric" default="0">
<cfscript>
var ret = '';
var selected = '';
var pages = '';
var i = 0;
</cfscript>
<cfquery name="pages" datasource="#application.dsn#" cachedwithin="#createTimeSpan(0,0,0,20)#">
SELECT landingId,title,parent,(select title from page b where landingId = a.parent) as parentTitle 
FROM page a
WHERE parent = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.parent#">
</cfquery>
<cfscript>
if(pages.recordcount EQ 0) {
--arguments.BaseDepth;
return ret;
} else {
++arguments.BaseDepth;
}
for (i=1; i LTE pages.recordCount; i = i+1) {
if( arguments.current EQ pages.landingId[i] ) {
selected = '1';
} else {
selected = '0';
}
writeoutput(arguments.self);
writeoutput(pages.landingId[i]);
if(arguments.self EQ pages.landingId[i]) { selected = '2'; }
if (pages.parent eq 0){parentTitle = 'No-Parent-Section';} else {parentTitle=pages.parentTitle[i];}

ret &= "#arguments.BaseDepth#,#pages.landingId[i]#,#replaceNoCase(pages.title[i]," ","-","all")#,#arguments.parent#,#replaceNoCase(parentTitle," ","-","all")#,#selected#|";
ret &= printSelectAdvanced(current=arguments.current, parent=pages.landingId[i], BaseDepth=arguments.BaseDepth);
}
if( parent EQ 0) {
return "1,0,No-Parent-Section,#arguments.parent#,no,0|" & ret;
}
return ret;
</cfscript>
</cffunction>

<script src="/managementcenter/js/jquery.chained.js"></script>
<script>
$( document ).ready(function() { 
$(".series").each(function() {
$(this).chained($(".mark", $(this).parent()));
});
});
</script>
<form>
<select class="mark" name="mark">
<option value="">--</option>
<option value="bmw">BMW</option>
<option value="audi">Audi</option>
</select>

<select class="series" name="series">
<option value="">--</option>

<option value="series-1" class="bmw">1 series</option>
<option value="series-3" class="bmw">3 series</option>
<option value="series-5" class="bmw">5 series</option>
<option value="series-6" class="bmw">6 series</option>
<option value="series-7" class="bmw">7 series</option>

<option value="a1" class="audi">A1</option>
<option value="a3" class="audi">A3</option>
<option value="s3" class="audi">S3</option>
<option value="a4" class="audi">A4</option>
<option value="s4" class="audi">S4</option>
<option value="a5" class="audi">A5</option>
<option value="s5" class="audi">S5</option>
<option value="a6" class="audi">A6</option>
<option value="s6" class="audi">S6</option>
<option value="rs6" class="audi">RS6</option>
<option value="a8" class="audi">A8</option>
</select>
</form>---> 
