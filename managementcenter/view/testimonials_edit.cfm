<!--- Check login status --->
<cfset application.helpers.checkLogin()>

<CFPARAM NAME="url.id" DEFAULT="-1">
<CFIF isdefined('form.action')>
	<CFIF form.Action is "insert">
		<cfset event.insertitem(argumentcollection=form)>
	</cfif>
	<cfif form.action eq "update">
		<cfset event.updateitem(argumentcollection=form)>
	</CFIF>
	<cfif form.action eq "delete">
		<cfset event.deleteItem(argumentcollection=form)>
	</CFIF>
	<CFLOCATION url="#BuildURL(event=url.event, encode=false)#" addtoken="no">
</CFIF>


<cfset getitems = event.getitems(id=url.id)>

        <h1>Add/Edit Testimonial</h1>

<cfoutput>
<div class="backbutton"><a href="#BuildURL(event=url.event)#">&lt; Back to List</a></div>

    <FORM action="#BuildURL(event=url.event, action=url.action, id=url.id)#" 
          method="post">
    
    <INPUT type="hidden"
           name="id"
           value="<cfoutput>#url.id#</cfoutput>">
    <ul>
        <li>
        <label>Author:<br />
        <INPUT TYPE="TEXT" 
               SIZE="50"
               VALUE="<cfoutput>#getitems.title#</cfoutput>"
               NAME="title" <cfif settings.var('testimonials.locked')>readonly="readonly"</cfif>/>
               </label>
        </li>
        <li>
        <label>Sort Order:<br />
        <INPUT TYPE="TEXT" 
               VALUE="<cfoutput>#getitems.sortorder#</cfoutput>"  
               SIZE="4"
               NAME="sortorder" <cfif settings.var('testimonials.locked')>readonly="readonly"</cfif>/>
               </label>
        </li>
        <li><label>Testimonial: </label><br /><textarea class="countdown" name="testimonial" rows="3" cols="30">#getitems.testimonial#</textarea></li>
    
        <li> 
        <cfswitch expression="#url.function#">
        <cfcase value="add">
            <INPUT TYPE="HIDDEN" 
                   NAME="action" 
                   VALUE="insert">
            <button class="submit" 
                    type="submit" 
                    tabindex="30">Add item</button>
        </cfcase>
        <cfcase value="update">
            <INPUT TYPE="HIDDEN" 
                   NAME="action" 
                   VALUE="update">
            <button class="submit" 
                    type="submit" 
                    tabindex="30">Update item</button>
        </cfcase>
        <cfcase value="delete">
            <INPUT TYPE="HIDDEN"
                   NAME="action"
                   VALUE="delete">
            <button class="submit" 
                    type="submit"
                    tabindex="30" 
                    onClick="return confirm('Are you sure you want to delete this record from the database?')">Delete item</button>
        </cfcase>
        </cfswitch>
        </li>
    </ul>
    
    </FORM>
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