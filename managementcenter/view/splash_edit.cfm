<!--- Check login status --->
<cfset application.helpers.checkLogin()>

<cfparam name="url.id" DEFAULT="-1">
<cfif isdefined('form.Action')>
	<cfif form.Action is "insert"><cfset event.insertitem(argumentcollection=form)></cfif>
	<cfif form.action eq "update"><cfset event.update(argumentcollection=form)></CFIF>
	<cfif form.action eq "delete"><cfset event.delete(argumentcollection=form)></CFIF>
	<CFLOCATION url="#BuildURL(event=url.event, encode=false)#" addtoken="no">
</cfif>


<cfset getitems = event.getitems(id=url.id)>

<cfif url.id IS NOT 0>
	<h1>Edit Image</h1>
<cfelse>
	<h1>Add Image</h1><br>
</cfif>

<cfoutput>
	<div class="backbutton"><a href="#BuildURL(event=url.event)#">Back to List</a></div>
	
	<form action="#BuildURL(event=url.event, action=url.action, id=url.id)#" method="post" enctype="multipart/form-data">

		<input type="hidden" name="id" value="<cfoutput>#url.id#</cfoutput>">
		<ul>
			<li>
				<label>Title:<br />
				<input type="text" name="linkTitle" <cfif settings.var('splash.locked')>readonly="readonly"</cfif> value="<cfoutput>#getitems.linkTitle#</cfoutput>" /></label>
			</li>
<!---
			<li>
				<label>Image Title:<br />
				<input type="text" name="imageTitle" <cfif settings.var('splash.locked')>readonly="readonly"</cfif> value="<cfoutput>#getitems.imageTitle#</cfoutput>" /></label>
			</li>
--->
				<label>URL:<br />
				<input type="text" name="linkURL" value="<cfoutput>#getitems.linkURL#</cfoutput>" /></label>
			</li>
			<li>
				<label>Site Section:<br />
<!--- 				to manually enter site section, uncomment this: --->
<!--- 				<input type="text" name="siteSection" value="<cfoutput>#getitems.siteSection#</cfoutput>" /></label> --->

<!--- otherwise, choose from the dropdown menu: --->
<!--- 			snippet taken from pages dropdown for pages parent section --->
				#event.printParentSelect()#
<!---                 <cfif settings.var('modules') CONTAINS 'PrivateContent'> --->
           	</li>
			<li>
				<label>Image:<br />
					<small>Currently: #getitems.image#<br></small>
					<input type="file" name="image" />
				</label>
				<br />
				<span class="error">#settings.varStr('splash.warning')#</span>
			</li>
			<li>
				<label>Sort Order:<br />
					<input type="text" name="sortorder" <cfif settings.var('splash.locked')>readonly="readonly"</cfif> value="<cfoutput>#getitems.sortorder#</cfoutput>"  SIZE="4" />
				</label>
			</li>
<!---
			<li>
				<label>Description: (Characters: <span class="charcount">#settings.var('splash.teaserlength')#</span>)</label><br />
				<textarea class="countdown" name="teaser" rows="3" cols="30">#getitems.teaser#</textarea>
			</li>
--->
			<li>
				<cfswitch expression="#url.function#">
					<cfcase value="add">
						<input type="hidden" name="Action" value="insert">
						<button class="submit" type="submit" tabindex="30">Add item</button>
					</cfcase>
					<cfcase value="update">
						<input type="hidden" name="Action" value="update">
						<button class="submit" type="submit" tabindex="30">update item</button>
					</cfcase>
					<cfcase value="delete">
						<input type="hidden" name="Action" value="Delete">
						<button class="submit" type="submit" tabindex="30" onClick="return confirm('Are you sure you want to delete it?')">Delete item</button>
					</cfcase>
				</cfswitch>
			</li>
		</ul>
	
	</form>
</cfoutput>

<script type="text/javascript">
var maxCount = $('.charcount').text()
,currentCount = $('.countdown').val().length;

$('.charcount').text(maxCount - currentCount);
$('.countdown').keyup(function(){
      if(this.value.length > maxCount) {
           //handle the over the limit part here
           $(this).addClass('error');
		   $('.charcount').addClass('error');
           
      } else {
          $(this).removeClass('error');
		  $('.charcount').removeClass('error');
      }
     $('.charcount').text(maxCount-this.value.length);
}); 
</script>