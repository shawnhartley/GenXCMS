<!--- Check login status --->
<cfset application.helpers.checkLogin()>

<CFPARAM NAME="url.id" DEFAULT="-1">
<CFIF isdefined('form.Action')>
	<CFIF form.Action is "INSERT">
		<cfset results = event.insertresource(argumentcollection=form)>
	</cfif>

	<cfif form.action eq "Update">
		<cfset results = event.updateresource(argumentcollection=form)>
	</CFIF>

	<cfif form.action eq "delete">
		<cfset results = event.deleteresource(argumentcollection=form)>
	</CFIF>
	<cfif results.success>
		<CFLOCATION url="#BuildURL(event=url.event, encode=false)#" addtoken="no">
	<cfelse>
		<cfdump var="#results.cfcatch#"><cfabort>
	</cfif>

</CFIF>


<cfset resource = event.getresources(id=url.id)>
<cfset ResourceCategories = event.getresourceCategories(id=url.id)>
<cfset categories = event.getCategories()>
<cfset users = event.getavailableusers()>
<cfset groups = event.getavailablegroups()>
<cfset resourceusers = event.getresourceusers(id=url.id)>
<cfset resourcegroups = event.getresourcegroups(url.id)>
<cfif url.id IS NOT 0>
<h1>Edit User Resource</h1>
<cfelse>
<h1>Add User Resource</h1><br>
</cfif>
<cfoutput>
<div class="backbutton"><a href="#BuildURL(event=url.event)#">&lt; Back to List</a></div>

<FORM action="#BuildURL(event=url.event, action=url.action, id=url.id)#" method="post" enctype="multipart/form-data" class="validate">
<INPUT TYPE="hidden" NAME="id" value="#url.id#">
<ul>
	<li><label>Title:<br /><INPUT TYPE="TEXT" NAME="title" VALUE="#resource.title#"  SIZE="50" /></label></li>
	
	<cfif settings.var('resources.allowlinks') AND NOT len(resource.filename)>
		<li><label>Link URL:<br /><INPUT TYPE="url" NAME="linkURL" value="#resource.linkURL#" /></label>
		<cfelse>
		<input type="hidden" name="linkURL" value="#resource.linkURL#" />
		</li>
		
	</cfif>
	<cfif url.id LTE 0><li><label>-- OR --</label></li></cfif>
	<cfif NOT len(resource.linkURL)><li><label>File: <cfif len(resource.filename)><small> Currently: <a href="#event.getDownloadLink(resource.title,'',resource.filename,resource.id)#">#resource.filename#</a></small></cfif><br /><INPUT TYPE="file" NAME="uploadfile" /></label>
	
	</cfif><input type="hidden" name="origfile" VALUE="<cfoutput>#resource.filename#</cfoutput>" />
	</li>
	<li><label>Description:</label><br />
				<textarea name="description" class="ckeditor">#resource.description#</textarea>
	</li>
	<input type="hidden" name="category" value="" />
	<cfif settings.var('resources.useCategories')>
	<li><label>Category:</label><br />
		<select name="category" class="required">
			<option value="">Please Select</option>
			<cfloop query="categories"><cfif resourceCategories['categoryId'].indexOf(categories.id) + 1><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="#categories.id#" #selected#>#categories.categoryName#</option>
			</cfloop>
		</select>	
	</li>
	</cfif>
	<cfif settings.var('resources.publishexpire')>
	<label>Publish On: </label><br />
	<input type="text" name="publishDate" value="#DateFormat(resource.publishDate, 'yyyy/mm/dd')#" class="date-pick required" /><br />
	<label>Expire On: <small>(Leave blank to never expire)</small></label><br />
	<input type="text" name="endDate" value="#DateFormat(resource.endDate, 'yyyy/mm/dd')#" class="date-pick" /><br />
	<cfelse>
	<input type="hidden" name="publishDate" value="#DateFormat(resource.publishDate, 'yyyy/mm/dd')#" />
	<input type="hidden" name="endDate" value="#DateFormat(resource.endDate, 'yyyy/mm/dd')#" />
	</cfif>
	<input type="hidden" name="userAccess" value="" />
	<cfif settings.var('resources.uselogins')>
	<li><br />
		<label>This resource can be viewed by:</label>
			<fieldset class="collapse"><legend>Per-User</legend><cfloop query="users"><cfset checked = ''><cfif resourceusers['loginid'].indexOf(users.id) + 1><cfset checked = 'checked="checked"'></cfif>
			<label><input type="checkbox" name="userAccess" value="#users.id#" #checked# /> #users.displayName# <small>(#users.username#, <em>#event.getUsersGroup(users.id)#</em>)</small></label><br />
		</cfloop>
		</fieldset>
		<fieldset class="collapse"><legend>Per-Group</legend>
		<cfloop query="groups"><cfset checked = ''><cfif resourcegroups['group_ID'].indexOf(groups.group_id) + 1><cfset checked = 'checked="checked"'></cfif>
			<label><input type="checkbox" name="groupAccess" value="#groups.group_id#" #checked# /> #groups.groupName#</label><br />
		</cfloop>
		</fieldset>
	</li>
	</cfif>
	<cfif settings.var('resources.usepriority')>
		<li><label>Sort Order (priority):<br /><INPUT TYPE="TEXT" NAME="sortorder" VALUE="#isNumeric(resource.sortorder) ? resource.sortorder : 10#"  SIZE="20" class="smalltext" /></label></li>
	<cfelse>
		<input type="hidden" name="sortorder" value="#isNumeric(resource.sortorder) ? resource.sortorder : 10#" />
	</cfif>
	<li><label ><input type="checkbox" name="active" value="1" <cfif resource.active GT 0> checked="checked"</cfif> /> Active<br /></label></li>
	<li> <cfswitch expression="#url.function#">
                        <cfcase value="add">
                        	  <INPUT TYPE="HIDDEN" NAME="Action" VALUE="INSERT">
                              <button class="submit" type="submit" tabindex="30">Add resource</button>
                        </cfcase>
                        <cfcase value="update">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Update">
                              		<button class="submit" type="submit" tabindex="30">Update resource</button>
                        </cfcase>
                        <cfcase value="delete">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Delete">
                              		<button class="submit" type="submit" tabindex="30" onClick="return confirm('Are you sure you want to delete this record from the database?')">Delete resource</button>
                        </cfcase>
                  </cfswitch>
	</li>
	<cfif url.id GT 0>
	<li>Created by #resource.uploadedBy#</li>
	</cfif>
</ul>

</FORM>
</cfoutput>