<!--- Check login status --->
<cfset application.helpers.checkLogin()>
<cfparam name="url.id" default="-1">
<cfif isdefined('form.Action')>
    <cfif form.Action is "insert">
        <cfif NOT structKeyExists(form, "sortorder") OR NOT isNumeric(form.sortorder)>
            <cfset form.sortorder = 10>
        </cfif>
        <cfset event.addevents(argumentcollection=form)>
        <cflocation url="#BuildURL(event=url.event, args='archive=#url.archive#', encode=false)#" addtoken="no">
    </cfif>
    <cfif form.action eq "update">
        <cfset event.updateevents(argumentcollection=form)>
        <cflocation url="#BuildURL(event=url.event, args='archive=#url.archive#&msg=1', encode=false)#" addtoken="no">
    </cfif>
    <cfif form.action eq "delete">
        <cfset event.deleteevents(id=url.id)>
        <cflocation url="#BuildURL(event=url.event, args='archive=#url.archive#&msg=1', encode=false)#" addtoken="no">
    </cfif>
</cfif>
<cfset getevents = event.getevents(id=url.id)>
<cfset geteventsCategories = event.geteventsCategories()>
<cfset myCategories = event.getMyCategories(url.id)>
<div>

    <cfif url.function eq "Add">
        Add
        <cfelseif url.function eq "edit">
        Edit
        <cfelse>
        Delete
    </cfif>
    <cfif len(application.settings.varStr('events.title'))>
        <cfoutput>#application.settings.varStr('events.title')#</cfoutput>
        <cfelse>
        Event - 
    </cfif> 
<cfoutput><a href="#BuildURL(event='events', args='archive=#url.archive#')#">Return To List</a></cfoutput>
<br />
<form enctype="multipart/form-data" 
      action="<cfoutput>#BuildURL(event=url.event, action=url.action, id=url.id, args='function=#url.function#&archive=#url.archive#')#</cfoutput>" 
      method="post" 
      name="frmevents" 
      id="frmevents">
    <cfif application.settings.var('events.showCategories')>
        <cfoutput>
            <label>Site Section:</label>
            <br />
            <cfset multiple = ''>
            <cfif settings.var('events.multipleCategories') >
                <cfset multiple = ' multiple="multiple" size="5" style="width:300px;"'>
            </cfif>
            <select name="category" #multiple# >
                <option value="0"> -- Select -- </option>
                <cfloop query="geteventsCategories">
                    <option value="#id#" <cfif ( myCategories['categoryId'].indexOf(geteventscategories.id) + 1)>selected="selected"</cfif>>#title#</option>
                </cfloop>
            </select>
            <cfif settings.var('events.multipleCategories') >
                <br />
                <small>Ctrl-Click to select more than multiple items</small>
            </cfif>
        </cfoutput>
    </cfif>
    <br />
    
    <label>Event Title:</label>
    <br />
    <input type="text" name="headline" value="<cfoutput>#getevents.headline#</cfoutput>"  size="200" />
    <br />
    
    <label>Event Date:</label>
    <small>(YYYY/MM/DD)</small><br />
    <input type="text" id="eventDate" class="date-pick" required="required" data-invalid="Please enter a valid Publish Date" name="eventDate" value="<cfoutput>#dateFormat(getevents.eventDate, 'YYYY/MM/DD')#</cfoutput>"  size="16" />
    <br />
    
    <label>Event Summary:</label>
    <br />
    <textarea name="summary" class="ckeditor"><cfoutput>#getevents.summary#</cfoutput></textarea>
    <br />
    
    <label>Event Detail:</label>
    <br />
    <textarea name="content" class="ckeditor"><cfoutput>#getevents.content#</cfoutput></textarea>
    <br />
    <button class="openClose" type="button" name="">Seo Options</button>
    <div class="hideit" style="border-style:dashed; border-width:1px; padding:3px;">
    <label>Meta Description:</label>
    <br />
    <textarea name="metaDescription" cols="50" rows="5"><cfoutput>#getevents.metaDescription#</cfoutput></textarea>
    <br />
    
    <label>Meta Keywords:</label>
    <br />
    <textarea name="metaKeywords" cols="50" rows="5"><cfoutput>#getevents.metaKeywords#</cfoutput></textarea>
    <br />
    
    <label>SEO Title:</label>
    <br />
    <input type="text" name="seotitle" value="<cfoutput>#getevents.seotitle#</cfoutput>"  size="200" />
    <br />
    
    <label>Custom facebook description:</label>
    <br/>
    <input type="text" name="fbDescription" value="<cfoutput>#getevents.fbDescription#</cfoutput>" />
    <br />
    
    <label>Image file for Facebook and Twitter:<br />
        Current Facebook and Twitter Image: <cfoutput>#getevents.fbTwitterImage#</cfoutput></label>
    <br/>
    <cfif getevents.fbTwitterImage neq ''>
        <input type="checkbox" name="removefbTwitterImage" value="1" />
        : Delete Facebook and Twitter Image
    </cfif>
    <br />
    <input type="file" name="fbTwitterImage" />
    <input type="hidden" name="fbTwitterImageExisting" value="<cfoutput>#getevents.fbTwitterImage#</cfoutput>" />
    <br />
    <br />
    
    <label>Custom facebook title:</label>
    <br/>
    <input type="text" name="fbTitle" value="<cfoutput>#getevents.fbTitle#</cfoutput>" />
    <br />
    
    <label>Custom Twitter title:</label>
    <br/>
    <input type="text" name="twitterTitle" value="<cfoutput>#getevents.twitterTitle#</cfoutput>" />
    </div>
    
    <label>Publish On:</label>
    <small>(YYYY/MM/DD)</small><br />
    <input type="text" id="publishDate" class="date-pick" required="required" data-invalid="Please enter a valid Publish Date" name="publishDate" value="<cfoutput>#dateFormat(getevents.publishDate, 'YYYY/MM/DD')#</cfoutput>"  size="16" />
    <br />
    
    <label>Expire On:</label>
    <small>(YYYY/MM/DD) Leave blank to Never Expire</small><br />
    <input type="text" id="endDate" class="date-pick" data-invalid="Please enter a valid End Date" name="endDate" value="<cfoutput>#dateFormat(getevents.endDate, 'YYYY/MM/DD')#</cfoutput>"  size="16" />
    <br />
    
    <div style="position:relative;float:left;padding-right:15px;">
        <label>Display on Live Site:</label>
        <br />
        <input type="radio" name="active" value="0"  <cfif getevents.active neq "1">checked="checked"</cfif> />
        NOT Active <br />
        <input type="radio" name="active" value="1" <cfif getevents.active eq "1">checked="checked"</cfif> />
        Active<br />
        <br />
    </div>
    
    <cfif event.can('publish')>
        <div style="position:relative;float:left;padding-right:15px;">
            <label>Approve Article:</label>
            <br />
            <input type="radio" name="approved" value="0"  <cfif getevents.approved neq "1">checked="checked"</cfif> />
            Not Approved <br />
            <input type="radio" name="approved" value="1" <cfif getevents.approved eq "1">checked="checked"</cfif> />
            Approved<br />
            <br />
        </div>
        <cfelse>
        <br />
        <p class="success">This article must be approved by a moderator before it will appear on the live site.</p>
        <input type="hidden" name="approved" id="approved" value="No">
    </cfif>
    </div>
    
    <cfif settings.var('events.priority')>
        <div style="position:relative;float:left;padding-right:15px;">
            <label>Sort Order:</label>
            <br />
            <input type="text" name="sortorder" value="<cfoutput>#getevents.sortorder#</cfoutput>" class="smalltext" />
            <br />
        </div>
	</cfif>
    
    <div style="clear:both;"></div>
    
    <input type="hidden" name="id" value="<cfoutput>#id#</cfoutput>" />
    
    <cfswitch expression="#url.function#">
        <cfcase value="add">
        <input type ="hidden" value="<cfoutput>#session.username#</cfoutput>" name="author" />
        <input type="hidden" name="action" value="insert" />
        <button class="submit" type="submit" tabindex="30">Add Event</button>
        </cfcase>
        <cfcase value="edit">
        <input type="hidden" name="action" value="update" />
        <button class="submit" type="submit" tabindex="30">Update Event</button>
        </cfcase>
        <cfcase value="delete">
        <input type="hidden" name="action" value="delete" />
        <button class="submit" type="submit" tabindex="30" onclick="return confirm('Are you sure you want to delete this record from the database?')">Delete Event</button>
        </cfcase>
    </cfswitch>
</form>
</div>