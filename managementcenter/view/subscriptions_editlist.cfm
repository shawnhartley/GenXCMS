<!--- Check login status --->
<cfset helpers.checkLogin()>

<CFPARAM NAME="url.id" DEFAULT="0"> 

<CFIF StructKeyExists(form, 'Action')> 
	<CFIF form.Action is "INSERT"> 
	<cfset event.createMailingList(argumentcollection=form)>
	<CFLOCATION url="#buildURL(event=url.event)#" addtoken="false">
	</cfif>
	
	<cfif form.action eq "Update">
	<cfset event.updateMailingList(argumentcollection=form)>
	<CFLOCATION url="#buildURL(event=url.event)#" addtoken="false">
	</CFIF>
	
	<cfif form.action eq "delete">
	<cfset event.deletemailinglist(argumentcollection=form)>
	<CFLOCATION url="#buildURL(event=url.event)#" addtoken="false">
	</CFIF>
</CFIF> 
<cfset getmailinglist = event.getmailinglist(url.id)>

<!--- begin form here --->
<h1><cfif url.function eq "Add">Add<cfelseif url.function eq "edit">Edit<cfelse>Delete</cfif> Mailing List</h1>
<cfoutput>
<p><a href="#buildURL(event=url.event)#">Return To List</a></p>
<cfif url.id AND NOT event.can('edit_list')><p class="error">You may view this list, but your changes will not be saved due to permissions.</p></cfif>
<cfif NOT url.id AND NOT event.can('create_list')><cfthrow type="c3d.notPermitted" message="You do not have permissions to create a mailing list."></cfif>
<FORM action="" method="post" name="frmmailinglist"> 
	<INPUT TYPE="hidden" NAME="listId" value="#getmailinglist.listId#"> 
	<ul>
		<li><label for="listname">List Name</label><br>
		<INPUT TYPE="TEXT" NAME="listName" VALUE="#getmailinglist.listName#"  SIZE="50"></li> 
	
		<li><label for="listDesc">List Description</label><br> 
		<textarea  name="listDesc" cols="40" rows="6">#getmailinglist.listDesc#</textarea></li>  
		
		<li><label for="isActive">Is List Active?</label><br> 
		<select name="isActive" size="1" >
				<option value=""> -- Select -- </option>
				<option value="1" <cfif getmailinglist.isActive eq "1">selected</cfif>>Yes</option>
				<option value="0" <cfif getmailinglist.isActive eq "0">selected</cfif>>No</option>
			</select>
		</li>  
		<li><label for="isPublic">Is List Public?</label><br> 
		<select name="isPublic" size="1" >
				<option value=""> -- Select -- </option>
				<option value="1" <cfif getmailinglist.isPublic eq "1">selected</cfif>>Yes</option>
				<option value="0" <cfif getmailinglist.isPublic eq "0">selected</cfif>>No</option>
		   </select>
		</li>  
	
<cfswitch expression="#url.function#">
	<cfcase value="add">
		<INPUT TYPE="HIDDEN" NAME="Action" VALUE="INSERT">
		<button class="submit" type="submit" tabindex="30">Add List</button>
	</cfcase>
	<cfcase value="edit">
		<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Update">
		<button class="submit" type="submit" tabindex="30">Update List</button>
	</cfcase>
	<cfcase value="delete">
		<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Delete">
		<button class="submit" type="submit" tabindex="30" onClick="return confirm('Are you sure you want to delete this record from the database?')">Delete List</button>
	</cfcase>
</cfswitch>
		</ul>
</FORM>
</cfoutput>