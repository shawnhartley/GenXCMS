<!--- Check login status --->
<cfset application.helpers.checkLogin()>

<CFPARAM NAME="url.id" DEFAULT="-1" type="numeric">
<cfparam name="form.noredirect" default="">
<cfparam name="form.redirect" default="">
<CFIF isdefined('form.Action')>
	<CFIF form.Action is "INSERT">
		<cfset newid = event.insertLocation(argumentcollection=form)>
		<CFLOCATION url="#BuildURL(event=url.event, action='edit', id=newid, args='function=update', encode=false)#" addtoken="no">
	</cfif>

	<cfif form.action eq "Update">
		<cfset event.updateLocation(argumentcollection=form)>
	</CFIF>

	<cfif form.action eq "delete">
		<cfset event.deleteLocation(argumentcollection=form)>
	</CFIF>
	
	<cfif len(form.noredirect)>
		<!---- NOOP ---->
	<cfelseif len(form.redirect)>
		<cflocation addtoken="no" url="#form.redirect#">
	<cfelse>
		<CFLOCATION url="#BuildURL(event=url.event, encode=false)#" addtoken="no">
	</cfif>

</CFIF>


<cfset event.setID(id=url.id)><!---- USE Getter to set up some variables in the cfc --->
<cfset getlocations = event.locations>


<cfoutput>
<cfif url.id GT 0>
<h1>Edit Location</h1>
<cfelse>
<h1>Add Location</h1><br>
</cfif>
<div class="backbutton"><a href="#session.locationspage#">&lt; Back to List</a></div>
<FORM action="#BuildURL(event=url.event, action=url.action, id=url.id, args='function=#url.function#')#" method="post">
<INPUT TYPE="hidden" NAME="id" value="#url.id#">
<input type="hidden" name="redirect" value="#session.locationspage#" />
	<label>Location Name:<br /><INPUT TYPE="TEXT" NAME="locName" VALUE="#getlocations.locName#"  SIZE="50" /></label><br />
	<fieldset<cfif url.id GT 0> class="collapse"</cfif>><legend>Address Info</legend>
	<label>Address:<br /><INPUT TYPE="TEXT" NAME="address1" VALUE="#getlocations.address1#"  SIZE="50" /></label><br />
					<label><INPUT TYPE="TEXT" NAME="address2" VALUE="#getlocations.address2#"  SIZE="50" /></label><br />
	<label>City:<br /><INPUT TYPE="TEXT" NAME="city" VALUE="#getlocations.city#" /></label><br />
	<label>State:<br /><INPUT TYPE="TEXT" NAME="state" VALUE="#getlocations.state#" /></label><br />
	<label>Zip:<br /><INPUT TYPE="TEXT" NAME="zip" VALUE="#getlocations.zip#" /></label><br />
	<cfif settings.var('locations.showCountry')>
		<label>Country:<br /><INPUT TYPE="TEXT" NAME="countrycode" VALUE="#getlocations.countrycode#" /></label><br />
	<cfelse>
		<input type="hidden" name="countrycode" value="#getlocations.countrycode#" />
	</cfif>
	<cfif url.id GT 0>
		<button name="noredirect" value="1">Save Address</button><br />
	</cfif>
</fieldset>
<cfif url.id GT 0>
	<fieldset><legend>Latitude/Longitude</legend>
	<p>Select a latitude/longitude to use, or enter a new one.</p>
	<table class="geocode">
	<cfif NOT ( event.currentMatchesGeo() OR event.currentMatchesOverride() )>
	<tr><td width="40"><input type="radio" name="useGeocode" value="current"<cfif event.hasCoordinates()> checked="checked"</cfif> /></td>
		<td>Current Location:<br />
			<cfif event.hasCoordinates()>
			Latitude: #getlocations.latitude#<br />
			Longitude: #getlocations.longitude#
			<cfelse>
				No Coordinates set
			</cfif>
	
		</td>
		<td>
		<cfif event.hasCoordinates()>
		<img src="http://maps.google.com/maps/api/staticmap?zoom=10&amp;size=200x200&amp;markers=color:blue|#getlocations.latitude#,#getlocations.longitude#&amp;sensor=false" />
		</cfif>
		</td>
	</tr>
	</cfif>
	<tr><td width="40"><input type="radio" name="useGeocode" value="auto" <cfif event.currentMatchesGeo() OR NOT event.hasCoordinates()>checked="checked"</cfif> /></td>
		<td>GeoCode Results: <cfif event.currentMatchesGeo()><small>(Current)</small></cfif><br />
			<cfif event.geo.results.hasGeocode>
			Latitude: #event.geo.results.latitude#<br />
			Longitude: #event.geo.results.longitude#<br />
			Interpreted as: <em>#event.geo.results.interpretedAddress#</em>
			<cfelse>
			No Match
			</cfif>
		</td>
		<td>
		<cfif isNumeric(event.geo.results.latitude) AND isNumeric(event.geo.results.longitude)>
			<img src="http://maps.google.com/maps/api/staticmap?zoom=10&amp;size=200x200&amp;markers=color:blue|#event.geo.results.latitude#,#event.geo.results.longitude#&amp;sensor=false" />
		</cfif>
		</td>
	</tr>
	<tr><td width="40"><input type="radio" name="useGeocode" value="override" <cfif event.currentMatchesOverride()>checked="checked"</cfif> /></td>
		<td>Override:<br />
<!--- 			<label>Latitude: <input type="text" name="overridelatitude" value="#getlocations.overridelatitude#" /></label><br /> --->
			<label>Url: <input type="text" name="overrideGeocode" value="#getlocations.overrideGeocode#" placeholder="Ex: https://www.google.com/maps/place/somebusiness/" /></label><br />	
	
		</td>
<!---
		<td>
		<cfif isNumeric(getlocations.overridelongitude) AND isNumeric(getlocations.overrideGeocode)>
		<img src="http://maps.google.com/maps/api/staticmap?zoom=10&amp;size=200x200&amp;markers=color:blue|#getlocations.overridelatitude#,#getlocations.overridelongitude#&amp;sensor=false" />
		</cfif>
		</td>
--->
	</tr>
	</table>
	</fieldset>

	
	<!---<label>Image:<br /><INPUT TYPE="file" NAME="image" ><input type="hidden" name="orig_image" value="#getlocations.image#" /></label><br />
				<label><input type="checkbox" name="removeImage" value="1" /> Remove Image</label><br />--->
	<label>Description:<br />
					<!---<cfscript>
						fckEditor = createObject( "component", "#application.dotroot#managementcenter.editor.fckeditor" ) ;
						fckEditor.instanceName	= "description" ;
						fckEditor.value			= '#getlocations.description#' ;
						fckEditor.height		= "250";
						fckEditor.basePath		= "#application.slashroot#managementcenter/editor/" ;
						fckEditor.Create() ; // create the editor.
			      </cfscript>--->
				  <textarea name="description" class="ckeditor">#getlocations.description#</textarea>
	</label><br />

</cfif>
	
	<label ><input type="checkbox" name="active" value="1" <cfif getlocations.active GT 0 > checked="checked"</cfif><cfif url.id LTE 0> disabled="disabled"</cfif> /> Active<br /></label><br />
	 <cfswitch expression="#url.function#">
                        <cfcase value="add">
                        	  <INPUT TYPE="HIDDEN" NAME="Action" VALUE="INSERT">
                              <button class="submit" type="submit" tabindex="30">Get Map Location</button>
                        </cfcase>
                        <cfcase value="update">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Update">
                              		<button class="submit" type="submit" tabindex="30">Update Location</button>
                        </cfcase>
                        <cfcase value="delete">
                        			<INPUT TYPE="HIDDEN" NAME="Action" VALUE="Delete">
                              		<button class="submit" type="submit" tabindex="30" onClick="return confirm('Are you sure you want to delete this record from the database?')">Delete Location</button>
                        </cfcase>
                  </cfswitch>
	<br />


</FORM>
</cfoutput>