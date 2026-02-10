<!--- Check login status --->
<cfset application.helpers.checkLogin()>

<CFPARAM NAME="url.id" DEFAULT="-1">
<CFIF isdefined('form.Action')>
	<cfif NOT isNumeric('form.sortorder')>
		<cfset form.sortorder = 10>
	</cfif>
	<CFIF form.Action is "INSERT">
		<cfset results = event.insertfaq(argumentcollection=form)>
	</cfif>

	<cfif form.action eq "Update">
		<cfset results = event.updatefaq(argumentcollection=form)>
	</CFIF>

	<cfif form.action eq "delete">
		<cfset results = event.deletefaq(argumentcollection=form)>
	</CFIF>
	<cfif results.success>
		<CFLOCATION url="#BuildURL(event=url.event, encode=false)#" addtoken="no">
	<cfelse>
		<cfdump var="#results.cfcatch#"><cfabort>
	</cfif>

</CFIF>


<cfset faq = event.getfaqs(id=url.id)>
<cfset faqCategories = event.getfaqCategories(id=url.id)>
<cfset faqCategoriesList = ValueList(faqCategories.categoryId)>
<cfset categories = event.getCategories()>

<cfif url.id IS NOT 0>
<h1>Edit Question/Answer</h1>
<cfelse>
<h1>Add Question/Answer</h1><br>
</cfif>
<cfoutput>
<div class="backbutton"><a href="#BuildURL(event=url.event)#">&lt; Back to List</a></div>

<FORM action="#BuildURL(event=url.event, action=url.action, id=url.id)#" method="post" enctype="multipart/form-data" class="validate">
<INPUT TYPE="hidden" NAME="id" value="#url.id#">
<ul>
	<li><label>Question:</label><br />
				<!---<cfscript>
						fckEditor = createObject( "component", "#application.dotroot#managementcenter.editor.fckeditor" ) ;
						fckEditor.instanceName	= "question" ;
						fckEditor.value			= '#faq.question#' ;
						fckEditor.height		= "200";
						fckEditor.basePath		= "#application.slashroot#managementcenter/editor/" ;
						fckEditor.Create() ; // create the editor.
			      </cfscript>--->
				  <textarea name="question" class="ckeditor"><cfoutput>#faq.question#</cfoutput></textarea>
	</li>
	<li><label>Answer:</label><br />
				<!---<cfscript>
						fckEditor = createObject( "component", "#application.dotroot#managementcenter.editor.fckeditor" ) ;
						fckEditor.instanceName	= "answer" ;
						fckEditor.value			= '#faq.answer#' ;
						fckEditor.height		= "400";
						fckEditor.basePath		= "#application.slashroot#managementcenter/editor/" ;
						fckEditor.Create() ; // create the editor.
			      </cfscript>--->
				  <textarea name="answer" class="ckeditor"><cfoutput>#faq.answer#</cfoutput></textarea>
	</li>
	<input type="hidden" name="category" value="" />
	<cfif settings.var('faqs.useCategories')>
	<li><label>Category:</label><br />
		<select name="category" class="required">
			<option value="">Please Select</option>
			<cfloop query="categories"><cfif ListFind(faqCategoriesList, categories.id)><cfset selected = 'selected="selected"'><cfelse><cfset selected = ''></cfif>
			<option value="#categories.id#" #selected#>#categories.categoryName#</option>
			</cfloop>
		</select>	
	</li>
	</cfif>
	<cfif settings.var('faqs.usepriority')>
		<li><label>Sort Order (priority):<br /><INPUT TYPE="TEXT" NAME="sortorder" VALUE="#faq.sortorder#"  SIZE="20" class="smalltext" /></label></li>
	<cfelse>
		<input type="hidden" name="sortorder" value="#faq.sortorder#" />
	</cfif>
	<li><label ><input type="checkbox" name="active" value="1" <cfif faq.active GT 0> checked="checked"</cfif> /> Active<br /></label></li>
	<li> <cfswitch expression="#url.function#">
                        <cfcase value="add">
                        	  <INPUT TYPE="HIDDEN" NAME="Action" VALUE="INSERT">
                              <button class="submit" type="submit" tabindex="30">Add faq</button>
                        </cfcase>
                        <cfcase value="update">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Update">
                              		<button class="submit" type="submit" tabindex="30">Update faq</button>
                        </cfcase>
                        <cfcase value="delete">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Delete">
                              		<button class="submit" type="submit" tabindex="30" onClick="return confirm('Are you sure you want to delete this record from the database?')">Delete faq</button>
                        </cfcase>
                  </cfswitch>
	</li>
	<cfif url.id GT 0>
	<li>Created by #faq.createdBy#</li>
	</cfif>
</ul>

</FORM>
</cfoutput>