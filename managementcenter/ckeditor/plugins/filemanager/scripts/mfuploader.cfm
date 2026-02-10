<cfparam name="request.manage" default="true">
<cfset application.helpers.checkLogin()>
<!---
Filename:      uploadForm.cfm
Created by:    Kris Korsmo
Organization:  kriskorsmo.com
Purpose:       Dispays a drag/drop file upload formLast Updated:  3/9/2013
--->
 
   <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
 
   <!--- 
         Link to the latest version of jQuery.  Obviously you can point this
         to your local version of jQuery if you prefer.  I like to keep this
         script in the document head, and the rest of the scripts at the 
         bottom of the page.
   --->
 
   <script src="http://code.jquery.com/jquery-latest.min.js"></script>
 
   <style>
      #dropArea {
         background-color: #efefef;
         border: 1px dotted #aeaeae;
         color: #aeaeae; 
         height: 200px; 
         line-height: 200px; 
         text-align: center;
         width: 300px; 
      }
   </style>
 
</head>
 
<body>
 
   <!---
         No form is requred.  Just create a blank div
         and style it so that it looks like a drop zone.
         I called my div dropArea.
   --->
 
   <div id="dropArea">
      Drop your files here
   </div>
 
   <!---
      The following alert messages will be hidden initially
      and depending on the state of the file upload we'll
      hide them and show them.
 
      As a side note, the names I gave the classes work with
      Twitter Bootstrap.  Although I didn't include Bootstrap
      in this demo, it looks really nice with this sort of UI.
   --->
 
   <div class="alert alert-info">
      Hang on!  Your file is uploading.
   </div>
 
   <div class="alert alert-error">
      Hey! Only JPG files are allowed.
   </div>
 
   <div class="alert alert-success">
      Sweet!  Your file was uploaded.
   </div>
 
   <script type="text/javascript">
 
      // hide all the divs with the class 'alert'
      $('.alert').hide();
 
      // create a JavaScript variable called target for our dropArea div
      var target = document.getElementById('dropArea');
 
      // add an event listener for the dragover event on our div
      target.addEventListener("dragover", function(event){
         event.preventDefault();
      }, false);
 
      // add an event listener for the drop event on our div
      // all the events below will happen when the drop event occurs
      target.addEventListener("drop", function(event){
         event.preventDefault();
 
         // set the variable 'files' to the dataTransfer object
         files = event.dataTransfer.files,
 
         // use the dataTranfer object to tell us how many files were
         // dropped onto our div
         numFiles = files.length;
 
         // loop over all the files
         var i=0;
         for (;i < numFiles; i++) {
 
            // we can simulate an old-fashioned form by using the formData object
            var uploadForm = new FormData();
 
            // you can use the dataTransfer object to gather information about the
            // files that were dropped.  That makes it easy to allow only certain
            // types of files to be uploaded. fType is our variable for the file type
            var fType = (files[i].type);
 
            // I'm only going to allow JPEG images to be uploaded. You can choose
            // whatever mime types you want to allow.  A good list of mime types can
            // be found at http://bit.ly/15EROqJ
            if (fType == 'image/jpeg'){
 
               // we'll append information to the form using the formData object
               uploadForm.append("theFile", files[i]);
               uploadForm.append("fileName", files[i].name);
 
               // create an instance of the XMLHttpRequest object (the AJAX magic)
               var xhr = new XMLHttpRequest();
 
               // create an event listener for our XMLHttpRequest
               // when the load event is complete it will fire the
               // transferComplete function
               xhr.addEventListener("load",transferComplete,true);
 
               // add a function called transferComplete that will be fired
               // when the file upload is complete
               function transferComplete(event){
                  // hide the div that says the file is uploading
                  $('.alert-info').hide();
                  // show the div that says the file was successfully uploaded
                  $('.alert-success').fadeIn().delay(2000).fadeOut('slow');
               }
 
               // show the div that says our ile is being uploaded
               $('.alert-info').fadeIn();
 
               // specify the name of the file which will handle the upload
               // (method, file, asynch)
               xhr.open("post", "handleUpload.cfm", true);
 
               // send the form
               xhr.send(uploadForm);
            }
 
            // if the file mime type is not 'image/jpg' we'll show an error
            else {
               $('.alert-error').fadeIn().delay(2000).fadeOut('slow');
            }
         }
      }, false);
 
</script>