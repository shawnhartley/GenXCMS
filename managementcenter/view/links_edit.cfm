<!--- Check login status --->
<cfset application.helpers.checkLogin()>

<CFPARAM NAME="url.id" DEFAULT="-1">
<CFIF isdefined('form.Action')>
	<CFIF form.Action is "INSERT">
		<cfset event.insertLink(argumentcollection=form)>
	</cfif>

	<cfif form.action eq "Update">
		<cfset event.update(argumentcollection=form)>
	</CFIF>

	<cfif form.action eq "delete">
		<cfset event.delete(argumentcollection=form)>
	</CFIF>

	<CFLOCATION url="#BuildURL(event=url.event, encode=false)#" addtoken="no">

</CFIF>


<cfset getlinks = event.getlinksList(id=url.id)>
<cfset getlinksCategories = event.getlinksCategories()>

<cfif url.id IS NOT 0>
<h1>Edit Link</h1>
<cfelse>
<h1>Add Link</h1><br>
</cfif>
<cfoutput>
<div class="backbutton"><a href="#BuildURL(event=url.event)#">&lt; Back to List</a></div>

<FORM action="#BuildURL(event=url.event, action=url.action, id=url.id)#" method="post">
<INPUT TYPE="hidden" NAME="id" value="<cfoutput>#url.id#</cfoutput>">
<ul>
	<cfif application.settings.var('links.showCategories')>
		<select name="category">
			<option value="">Select a Category</option>
		<cfloop query="getlinksCategories">
			<option value="#getlinksCategories.id#"<cfif getlinks.category EQ getlinksCategories.id> selected="selected" </cfif>>#getlinksCategories.title#</option>
		</cfloop>
		</select>
	</cfif>
	<li><label>Link Title:<br /><INPUT TYPE="TEXT" NAME="linkTitle" VALUE="<cfoutput>#getlinks.linkTitle#</cfoutput>"  SIZE="50" /></label></li>
	<li><label>Link URL:<br /><INPUT TYPE="TEXT" NAME="linkURL" VALUE="<cfoutput>#getlinks.linkURL#</cfoutput>"  SIZE="50" /></label></li>
	<li><label>Sort Order:<br /><INPUT TYPE="TEXT" NAME="sortorder" VALUE="<cfoutput>#getlinks.sortorder#</cfoutput>"  SIZE="4" /></label></li>
	<li><label ><input type="checkbox" name="active" value="1" <cfif getlinks.active GT 0> checked="checked"</cfif> /> Active<br /></label></li>
	<li> <cfswitch expression="#url.function#">
                        <cfcase value="add">
                        	  <INPUT TYPE="HIDDEN" NAME="Action" VALUE="INSERT">
                              <button class="submit" type="submit" tabindex="30">Add Link</button>
                        </cfcase>
                        <cfcase value="update">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Update">
                              		<button class="submit" type="submit" tabindex="30">Update Link</button>
                        </cfcase>
                        <cfcase value="delete">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Delete">
                              		<button class="submit" type="submit" tabindex="30" onClick="return confirm('Are you sure you want to delete this record from the database?')">Delete Link</button>
                        </cfcase>
                  </cfswitch>
	</li>
</ul>

</FORM>
</cfoutput>