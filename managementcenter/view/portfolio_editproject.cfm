<!--- Check login status --->
<cfset application.helpers.checkLogin()>


<CFPARAM NAME="url.id" DEFAULT="-1">
<cfparam name="form.featured" default="0">

<cfif structKeyExists(form, "action")>
	<cfset event.updateproject(argumentcollection=form)>
	<CFLOCATION url="#BuildURL(event=url.event, args='msg=1', encode=false)#" addtoken="no">
</CFIF>



<cfset project = event.getProjects(id=url.id)>

<cfset projectCategories = event.getProjectCategories(projectId = url.id)>



<h1>Edit Project</h1>
<p><cfoutput><a href="#BuildURL(event=url.event)#">Return To List</a></cfoutput></p>

<FORM action="<cfoutput>#BuildURL(event=url.event, action=url.action, id=url.id, args='function=#url.function#')#</cfoutput>" method="post" name="frmnews">

			<ul>
              

				<li><label for="title">Project Name:</label><br />
				<INPUT TYPE="TEXT" NAME="projectName" VALUE="<cfoutput>#project.projectName#</cfoutput>"  SIZE="200"></li>
				<cfif settings.Var('portfolio.teaser')>
				<li><label for="teaser">Project Teaser</label>
				  <textarea name="teaser" class="ckeditor"><cfoutput>#project.teaser#</cfoutput></textarea>
				</li>
				</cfif>
				<li><label for="description">Project Description:</label><br />
				  <textarea name="projectDescription" class="ckeditor"><cfoutput>#project.projectDescription#</cfoutput></textarea>
				  </li>
			<cfif settings.var('portfolio.geo')>
				<cfoutput>
				<fieldset<cfif url.id GT 0> class="collapse"</cfif>><legend>Address Info</legend>
				<label>Address:<br /><INPUT TYPE="TEXT" NAME="address1" VALUE="#project.address1#"  SIZE="50" /></label><br />
								<label><INPUT TYPE="TEXT" NAME="address2" VALUE="#project.address2#"  SIZE="50" /></label><br />
				<label>City:<br /><INPUT TYPE="TEXT" NAME="city" VALUE="#project.city#" /></label><br />
				<label>State:<br /><INPUT TYPE="TEXT" NAME="state" VALUE="#project.state#" /></label><br />
				<label>Zip:<br /><INPUT TYPE="TEXT" NAME="zip" VALUE="#project.zip#" /></label><br />
				<cfif settings.var('locations.showCountry')>
					<label>Country:<br /><INPUT TYPE="TEXT" NAME="countrycode" VALUE="#project.countrycode#" /></label><br />
				<cfelse>
					<input type="hidden" name="countrycode" value="#project.countrycode#" />
				</cfif>
				<cfif structKeyExists(url, "debug")>
				<li><cfdump var="#event.geo.geocode( address1=project.address1, address2=project.address2, city=project.city, state=project.state, postalCode=project.zip, countryCode=project.countrycode )#"></li>
				</cfif>
				<label>Email:<br /><INPUT TYPE="TEXT" NAME="emailAddress" VALUE="#project.emailAddress#" /></label><br />
				</fieldset>
				</cfoutput>
			</cfif>			

				<li><label for="sortorder">Sort Order</<br>
					<input type="number" name="sortorder" value="<cfoutput>#project.sortorder#</cfoutput>" /></label>

			<cfif event.can('publish')>
				<li><label for="status">Active:</label><br />
					<input type="radio" name="status" value="1" <cfif project.status> checked="checked"</cfif>> Active<br>
					<input type="radio" name="status" value="0" <cfif NOT project.status> checked="checked"</cfif>> Hidden<br>
				</li>
			<cfelse><input type="hidden" name="status" value="0">
			</cfif>

			<cfif settings.Var('portfolio.features')>
				<li><label><input type="checkbox" name="featured" value="1" <cfif project.featured> checked</cfif> /> Featured</label><br />
				</li>
			<cfelse>
				<input type="hidden" name="featured" value="#project.featured#" />
			</cfif>
				
				<li><label for="categories">Project Categories</label><br>
					<cfoutput>
					<select name="projectCategories" id="categories" size="12" multiple="multiple" style="width:250px;">
						<cfloop query="projectCategories">
							<option value="#projectCategories.id#" <cfif projectCategories.projectCount> selected="selected"</cfif>>#projectCategories.categoryName#</option>
						</cfloop>
					</select>
					</cfoutput>
					<br>
					Other: <small>(Comma Separated)</small>
					<input type="text" name="projectCategories" />
				<li>
				<INPUT TYPE="hidden" NAME="id" value="<cfoutput>#id#</cfoutput>">
				

				<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Update">
				<cfif event.can('edit_published') OR (event.can('edit') AND NOT project.status )>
				<button class="submit" type="submit" tabindex="30">Update Project</button>
				</cfif>
    </li>
    </ul>
</FORM>