<cfset application.helpers.checkLogin()>

<CFPARAM NAME="url.id" DEFAULT="-1">
<CFIF isdefined('form.Action')>
	<CFIF form.Action is "INSERT">
		<cfset event.inserttct(argumentcollection=form)>
	</cfif>

	<cfif form.action eq "Update">
		<cfset event.update(argumentcollection=form)>
	</CFIF>

	<cfif form.action eq "delete">
		<cfset event.delete(argumentcollection=form)>
	</CFIF>

	<CFLOCATION url="#BuildURL(event='tct',args='msg=1')#" addtoken="no">

</CFIF>

<cfset gettct = event.gettctList(id=url.id)>
<cfoutput>
<cfif id IS NOT 0>
<h1>Edit TCT URL</h1>
<div class="backbutton"><a href="#BuildURL(event=url.event)#">&lt; Back to List</a></div>
<cfelse>
<h1>Add TCT URL</h1><br>
</cfif>

<FORM action="#BuildURL(event='tct', action='edit')#" method="post">
<INPUT TYPE="hidden" NAME="id" value="#url.id#">
<cfif NOT event.can('edit') OR (gettct.active GT 0 AND NOT event.can('edit_published'))>
<p class="error"><strong>Note:</strong> You may view this item, but cannot save any changes.</p>
</cfif>
<ul>
	<li><label>Local address:<br /><INPUT TYPE="TEXT" NAME="slug" VALUE="#gettct.slug#"  SIZE="50" /></label></li>
	<li><label>Redirect to:<br /><INPUT TYPE="TEXT" NAME="url" VALUE="#gettct.url#"  SIZE="50" /></label></li>
	<cfif event.can('publish')><li><label ><input type="checkbox" name="active" value="1" <cfif gettct.active GT 0> checked="checked"</cfif> /> Active<br /></label></li>
	<cfelse><input type="hidden" name="active" value="0" /></cfif>
	<li> <cfswitch expression="#url.function#">
                        <cfcase value="add">
                        	  <INPUT TYPE="HIDDEN" NAME="Action" VALUE="INSERT">
                              <button class="submit" type="submit" tabindex="30">Add URL</button>
                        </cfcase>
                        <cfcase value="update"><cfif event.can('edit_published') OR (event.can('edit') AND gettct.active EQ 0)>
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Update">
                              		<button class="submit" type="submit" tabindex="30">Update URL</button></cfif>
                        </cfcase>
                        <cfcase value="delete">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Delete">
                              		<button class="submit" type="submit" tabindex="30" onClick="return confirm('Are you sure you want to delete this record from the database?')">Delete URL</button>
                        </cfcase>
                  </cfswitch>
	</li>
</ul>

</FORM>
</cfoutput>