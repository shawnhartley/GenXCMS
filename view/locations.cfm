<!---
	:: IMPORTANT. READ THIS.
	
	The script used to build the googleMaps has been moved to a proper .js file named "locations.js" in the /js/ folder.
	The skel is set up to include this .JS file IF the event.section is EQ to 'locations', but this is easily alterable to include a listFind() of sections.
	
	ERRORS: 
	You will notice an error named "ERROR: Google is Not Defined", but that was pulling through before any alterations were made to any file regarding /locations.
		
	OPTIMIZATION:
	The code still functions normally, but the following portions have been parsed out into seperate files to avoid page paint slowing.
	
		Inline Styling: 
			instead of utilizing <style> tags mid-DOM construction please place the styling within _locations.scss and call that partial into main.scss
			use the body class to call against.
				ex: instead of `#copy { float: right; }` use `body.locations #copy { float: right; }`
			
		Mid-DOM Javascript: 
			the normal (non-coldfusion built) javascript has been moved to the bottom of the skel inside a conditional include. This ensures that the javascript
			will only be fired once the page is done building and will not trip up page building. The conditional include is to avoid irrelevant scripts from loading
			on pages that will never need the code inside of the javascript snippet.
 --->

<cfset myData = { active=1 }>
<cfset qLocations = application.DataMgr.getRecords("locations", myData)>

<cfset buildScript = '<script>var data = { "count": #qLocations.recordcount#,"locationstuff": ['>
<cfset nbs=Chr(10)>
<cfset abss=Chr(13)>

<cfoutput query="qLocations">
    <cfset buildScript = buildScript & '{"locaid": #qLocations.id#, "title": "#qLocations.locName#", "address": "#qLocations.address1# #qLocations.address2#", "city": "#qLocations.city#", "state": "#qLocations.state#", "zip": "#qLocations.zip#", "longitude": #qLocations.geoLongitude#, "latitude": #qLocations.geoLatitude#, "iconSpecial": #qLocations.iconSpecial#}'>
	<cfif recordcount neq currentRow>
		<cfset buildScript = buildScript & ','>
	</cfif>
</cfoutput>
    
<cfset buildScript = buildScript & ']}</script>'>

<cfoutput>#buildScript#</cfoutput>


<div id="map-container">
  <div id="map"></div>
</div>
    

