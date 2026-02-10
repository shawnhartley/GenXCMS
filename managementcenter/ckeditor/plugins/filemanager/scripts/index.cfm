<cfparam name="request.manage" default="true">
<cfset application.helpers.checkLogin()>
<cfif isdefined("session.userlevel") and isdefined("session.username")>
<cfif isdefined("form.submit")>
<cfset imgabsolutePath = ExpandPath("../../../../..#form.filename#")>
<cfset imgName = GetFileFromPath(imgabsolutePath)>
<cfimage source="../../../../..#form.filename#" name="myImage">
<cfset info=ImageInfo(myImage)>
<cfset pathDirStuff = GetFileInfo(imgabsolutePath)>
<cfset ImageResize(myImage,form.imagewidth,form.imageheight,"lanczos")>
<cfset ImageCrop(myImage,form.cropx,form.cropy,form.cropwidth,form.cropheight)>
<cfimage source="#myImage#" action="write" destination="#pathdirStuff.parent#/#randrange(000,999)##imgName#" overwrite="no">
<script language="javascript">
	window.parent.document.getElementById('el').click();
</script>
<cfelse>
    
    <!-- jQuery -->
    <script type="text/javascript" src="http://code.jquery.com/jquery-1.6.2.js"></script>
    
    <!-- jQuery-Ui -->
    <link rel="stylesheet" type="text/css" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.7/themes/base/jquery-ui.css" />
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.7/jquery-ui.js"></script>
    
    <!-- SHJS - Syntax Highlighting for JavaScript -->
    <script type="text/javascript" src="http://shjs.sourceforge.net/sh_main.min.js"></script>
    <script type="text/javascript" src="http://shjs.sourceforge.net/lang/sh_javascript.min.js"></script>
    <link type="text/css" rel="stylesheet" href="http://shjs.sourceforge.net/sh_style.css" />
    <script type="text/javascript">$(document).ready(function(){sh_highlightDocument();});</script>
    
    <!-- jrac - jQuery Resize And Crop -->
    <link rel="stylesheet" type="text/css" href="jrac/style.jrac.css" />
    <script type="text/javascript" src="jrac/jquery.jrac.js"></script>

    <!-- This page business -->
	<style>
		/* clearfix */
		.clearfix:after {
		  content: ".";
		  display: block;
		  clear: both;
		  visibility: hidden;
		  line-height: 0;
		  height: 0;
		}
		
		.clearfix {
		  display: inline-block;
		}
		
		html[xmlns] .clearfix {
		  display: block;
		}
		
		* html .clearfix {
		  height: 1%;
		}
		
		body {
		  font-family: Georgia,Times,"Times New Roman",serif;
		  font-size: .9em;
		  margin: 1em auto;
		  width:900px;
		}
		
		/* The pane holding the image */
		.pane>*  {
		  float:left;
		}
		.pane>table {
		  margin:1em;
		}
		.pane>table td {
		  text-align: right;
		  padding-right: .5em;
		}
		pre.code {
		  padding:1em;
		  margin:0;
		  background-color: #eee;
		  border:1px dashed #ccc;
		}
		
		/* Override some jrac css */
		.jrac_viewport {
		  width:600px;
		  height:600px;
		}
    </style>
    <script type="text/javascript">
      <!--//--><![CDATA[//><!--
      $(document).ready(function(){
        // Apply jrac on some image.
        $('.pane img').jrac({
          'crop_width': 250,
          'crop_height': 170,
          'crop_x': 100,
          'crop_y': 100,
          'image_width': 400,
          'viewport_onload': function() {
            var $viewport = this;
            var inputs = $viewport.$container.parent('.pane').find('.coords input:text');
            var events = ['jrac_crop_x','jrac_crop_y','jrac_crop_width','jrac_crop_height','jrac_image_width','jrac_image_height'];
            for (var i = 0; i < events.length; i++) {
              var event_name = events[i];
              // Register an event with an element.
              $viewport.observator.register(event_name, inputs.eq(i));
              // Attach a handler to that event for the element.
              inputs.eq(i).bind(event_name, function(event, $viewport, value) {
                $(this).val(value);
              })
              // Attach a handler for the built-in jQuery change event, handler
              // which read user input and apply it to relevent viewport object.
              .change(event_name, function(event) {
                var event_name = event.data;
                $viewport.$image.scale_proportion_locked = $viewport.$container.parent('.pane').find('.coords input:checkbox').is(':checked');
                $viewport.observator.set_property(event_name,$(this).val());
              });
            }
            $viewport.$container.append('<div>Image natual size: '
              +$viewport.$image.originalWidth+' x '
              +$viewport.$image.originalHeight+'</div>')
          }
        })
        // React on all viewport events.
        .bind('jrac_events', function(event, $viewport) {
          var inputs = $(this).parents('.pane').find('.coords input');
          inputs.css('background-color',($viewport.observator.crop_consistent())?'chartreuse':'salmon');
        });
		var filenameAltA = fullUri.replace( /^.*?([^\/]+)\..+?$/, '$1' );
      });
      //--><!]]>
    </script>

    <p>Move the image or the crop with the pointer, resize the crop with the pointer, use the zoom bar to scale the image or set your values into the inputs.</p>
    <div class="pane clearfix">
      <img src="../../../../..<cfoutput>#url.filename#</cfoutput>"/>
      <form action="" method="post">
      <table class="coords">
        <tr><td>crop x</td><td><input type="text" name="cropx" /></td></tr>
        <tr><td>crop y</td><td><input type="text" name="cropy" /></td></tr>
        <tr><td>crop width</td><td><input type="text" name="cropwidth" /></td></tr>
        <tr><td>crop height</td><td><input type="text" name="cropheight" /></td></tr>
        <tr><td>image width</td><td><input type="text" name="imagewidth" /></td></tr>
        <tr><td>image height</td><td><input type="text" name="imageheight" /></td></tr>
        <tr><td>lock proportion</td><td><input type="checkbox" checked="checked" /></td></tr>
        <tr><td></td><td><input type="submit" value="Fix Picture" name="submit"/></td></tr>
      </table>
      <input type="hidden" value="<cfoutput>#url.filename#</cfoutput>" name="fileName">
      </form>
    </div>
</cfif>
</cfif>
<!---<cfdump var="#application#">
<cfdump var="#session#">
<cfdump var="#cgi#">
<cfdump var="#url#">--->