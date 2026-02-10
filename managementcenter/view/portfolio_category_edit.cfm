<!--- Check login status --->
<cfset application.helpers.checkLogin()>


<CFPARAM NAME="url.id" DEFAULT="-1">


<cfif structKeyExists(form, "action")>
	<cfset event.updateprojectcategory(argumentcollection=form)>
	<CFLOCATION url="#BuildURL(event=url.event, action='categories', args='msg=1', encode=false)#" addtoken="no">
</CFIF>



<cfset category = event.getProjectCategories(categoryid=url.id)>


<h1>Edit Category Description</h1>
<p><cfoutput><a href="#BuildURL(event=url.event, action='categories')#">Return To List</a></cfoutput></p>

<FORM action="<cfoutput>#BuildURL(event=url.event, action=url.action, id=url.id, args='function=#url.function#')#</cfoutput>" method="post" name="frmnews">

			<ul>
              

				<li><label for="title">Category Name:</label><br />
				<INPUT TYPE="TEXT" NAME="categoryName" VALUE="<cfoutput>#category.categoryName#</cfoutput>"  SIZE="200"></li>
				<li><label for="caption">Project Description:</label><br />
				  <textarea name="caption" class="ckeditor"><cfoutput>#category.caption#</cfoutput></textarea></li>

				<li><label for="sortorder">Sort Order</<br>
					<input type="number" name="sortorder" value="<cfoutput>#category.sortorder#</cfoutput>" /></label>

				<li><label for="status">Active:</label><br />
					<input type="radio" name="showInNav" value="1" <cfif category.showInNav> checked="checked"</cfif>> Active<br>
					<input type="radio" name="showInNav" value="0" <cfif NOT category.showInNav> checked="checked"</cfif>> Hidden<br>
				</li>
				
				<li>
				<INPUT TYPE="hidden" NAME="id" value="<cfoutput>#id#</cfoutput>">
				

				<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Update">
				<button class="submit" type="submit" tabindex="30">Update Category</button>
	
    </li>
    </ul>
</FORM>