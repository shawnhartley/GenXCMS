<!--- Check login status --->
<cfset application.helpers.checkLogin()>
<cfparam name="url.id" default="-1">
<cfif isdefined('form.Action')>
    <cfif form.Action is "insert">
        <cfif NOT structKeyExists(form, "sortorder") OR NOT isNumeric(form.sortorder)>
            <cfset form.sortorder = 10>
        </cfif>
        <cfset event.addblog(argumentcollection=form)>
        <cflocation url="#BuildURL(event=url.event, args='archive=#url.archive#', encode=false)#" addtoken="no">
    </cfif>
    <cfif form.action eq "update">
        <cfset event.updateblog(argumentcollection=form)>
        <cflocation url="#BuildURL(event=url.event, args='archive=#url.archive#&msg=1', encode=false)#" addtoken="no">
    </cfif>
    <cfif form.action eq "delete">
        <cfset event.deleteblog(id=url.id)>
        <cflocation url="#BuildURL(event=url.event, args='archive=#url.archive#&msg=1', encode=false)#" addtoken="no">
    </cfif>
</cfif>
<cfset getblog = event.getblog(id=url.id)>
<cfset getblogCategories = event.getblogCategories()>

<div>
    <cfif url.function eq "Add">
        Add
        <cfelseif url.function eq "edit">
        Edit
        <cfelse>
        Delete
    </cfif>
    <cfif len(application.settings.varStr('blog.blogtitle'))>
        <cfoutput>#application.settings.varStr('blog.blogtitle')#</cfoutput>
        <cfelse>
        Blog
    </cfif>
    Article -
<cfoutput><a href="#BuildURL(event='blog', args='archive=#url.archive#')#">Return To List</a></cfoutput>
<br />

<form enctype="multipart/form-data" 
action="<cfoutput>#BuildURL(event=url.event, action=url.action, id=url.id, args='function=#url.function#&archive=#url.archive#')#</cfoutput>" 
method="post" 
name="frmblog" 
id="frmblog">
    <cfif application.settings.var('blog.showCategories')>
        <cfoutput>
            <label>Site Section:</label>
            <br />
            <cfset multiple = ''>
            <cfif settings.var('blog.multipleCategories') >
                <cfset multiple = ' multiple="multiple" size="5" style="width:300px;"'>
            </cfif>
            <select name="category" #multiple# >
                <option value="0"> -- Select -- </option>
                <cfloop query="getblogCategories">
                    <option value="#id#" <cfif ListFind(getblog.category, id)>selected="selected"</cfif>>#title#</option>
                </cfloop>
            </select>
            <cfif settings.var('blog.multipleCategories') >
                <br />
                <small>Ctrl-Click to select more than multiple items</small>
            </cfif>
            <br />
        </cfoutput>
    </cfif>
    <label>Article Headline:</label>
    <br />
    <input type="text" name="headline" value="<cfoutput>#Replace(getblog.headline,'"','&quot;','All')#</cfoutput>"  size="200">
    <br />
    <label>Article Summary:</label>
    <br />
    <textarea name="summary" class="ckeditor"><cfoutput>#getblog.summary#</cfoutput></textarea>
    <br />
    <label>Article Content:</label>
    <br />
    <textarea name="content" class="ckeditor"><cfoutput>#getblog.content#</cfoutput></textarea>
    <br />
    <button class="openClose" type="button" name="">Seo Options</button>
    <div class="hideit" style="border-style:dashed; border-width:1px; padding:3px;">
        <label>Meta Description:</label>
        <br />
        <textarea name="metaDescription" cols="50" rows="5"><cfoutput>#Replace(getblog.metaDescription,'"','&quot;','All')#</cfoutput></textarea>
        <label>Meta Keywords:</label>
        <br />
        <textarea name="metaKeywords" cols="50" rows="5"><cfoutput>#getblog.metaKeywords#</cfoutput></textarea>
        <label>SEO Title:</label>
        <br />
        <input type="text" name="seotitle" value="<cfoutput>#getblog.seotitle#</cfoutput>"  size="200">
        <label>Custom facebook description:</label>
        <br/>
        <input type="text" name="FBdescription" value="<cfoutput>#Replace(getblog.FBdescription,'"','&quot;','All')#</cfoutput>">
        <label>Image file for Facebook and Twitter:<br />
            Current Facebook and Twitter Image: <cfoutput>#getblog.fbTwitterImage#</cfoutput></label>
        <br/>
        <cfif getblog.fbTwitterImage neq ''>
            <input type="checkbox" name="removefbTwitterImage" value="1" />
            : Delete Facebook and Twitter Image
        </cfif>
        <br />
        <input type="file" name="fbTwitterImage">
        <input type="hidden" name="fbTwitterImageExisting" value="<cfoutput>#getblog.fbTwitterImage#</cfoutput>">
        <br />
        <br />
        <label>Custom facebook title:</label>
        <br/>
        <input type="text" name="FBtitle" value="<cfoutput>#Replace(getblog.FBtitle,'"','&quot;','All')#</cfoutput>">
        <label>Custom Twitter title:</label>
        <br/>
        <input type="text" name="twitterTitle" value="<cfoutput>#Replace(getblog.twitterTitle,'"','&quot;','All')#</cfoutput>">
    </div>
    <cfif settings.var('blog.priority')>
        <label>Sort Order:</label>
        <br />
        <input type="text" name="sortorder" value="<cfoutput>#getblog.sortorder#</cfoutput>" class="smalltext">
    </cfif>
    <label>Publish On:</label>
    <small>(YYYY/MM/DD)</small><br />
    <input type="text" id="publishDate" class="date-pick" required="required" data-invalid="Please enter a valid Publish Date" name="publishDate" value="<cfoutput>#dateFormat(getblog.publishDate, 'YYYY/MM/DD')#</cfoutput>"  size="16">
    <br>
    <label>Push to Archive On:</label>
    <small>(YYYY/MM/DD) Leave blank to Never Expire</small><br />
    <input type="text" id="endDate" class="date-pick" data-invalid="Please enter a valid End Date" name="endDate" value="<cfoutput>#dateFormat(getblog.endDate, 'YYYY/MM/DD')#</cfoutput>"  size="16">
    <br>
    <div style="position:relative;float:left;padding-right:15px;">
        <label>Display on Live Site:</label>
        <br />
        <input type="radio" name="active" value="0"  <cfif getblog.active neq "1">checked="checked"</cfif> />
        NOT Active <br />
        <input type="radio" name="active" value="1" <cfif getblog.active eq "1">checked="checked"</cfif> />
        Active<br />
        <br />
    </div>
    <cfif event.can('publish')>
        <div style="position:relative;float:left;padding-right:15px;">
            <label>Approve Article:</label>
            <br />
            <input type="radio" name="approved" value="0"  <cfif getblog.approved neq "1">checked="checked"</cfif> />
            Not Approved <br />
            <input type="radio" name="approved" value="1" <cfif getblog.approved eq "1">checked="checked"</cfif> />
            Approved<br />
            <br />
        </div>
        <cfelse>
        <br />
        <p class="success">This article must be approved by a moderator before it will appear on the live site.</p>
        <input type="hidden" name="approved" id="approved" value="No">
    </cfif>
    </div>
    <div style="clear:both;"></div>
  
    <input type="hidden" name="id" value="<cfoutput>#id#</cfoutput>">
    <cfswitch expression="#url.function#">
        <cfcase value="add">
        <input type="hidden" name="action" value="insert">
        <button class="submit" type="submit" tabindex="30">Add Article</button>
        </cfcase>
        <cfcase value="edit">
        <input type="hidden" name="action" value="update">
        <button class="submit" type="submit" tabindex="30">Update Article</button>
        </cfcase>
        <cfcase value="delete">
        <input type="hidden" name="action" value="delete">
        <button class="submit" type="submit" tabindex="30" onclick="return confirm('Are you sure you want to delete this record from the database?')">Delete Article</button>
        </cfcase>
    </cfswitch>
</form>
</div>
