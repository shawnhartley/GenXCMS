<cfset application.helpers.checkLogin()>

<cfif isdefined('form.Action')>
<cfif form.action eq "Update">

<cfset event.updatesitesettings(argumentcollection=form)>
<cflocation url="#BuildURL(event=url.event, args='msg=1', encode=false)#" addtoken="no">
</cfif>
</cfif>

<cfif NOT event.can('read')><cfthrow type="c3d.notPermitted" message="You do not have permissions to access this module."></cfif>


			
<cfoutput>
<form method="post" id="site-form" action="#BuildURL(event=url.event)#">
	<h1>Sitewide Settings</h1>
	
	<cfif StructKeyExists(url, "msg") AND url.msg EQ 1>
	<p class="success">Settings Updated.</p>
	</cfif>

	<fieldset class="collapse"><legend>Site Modules</legend>
	<input type="hidden" name="modules" value="settings,schema,logs"  />
	<table>
	<tr>
		<td><label><input type="checkbox" name="modules" value="Security" checked="checked" disabled="disabled" /> <input type="hidden" name="modules" value="logins,usergroups" /> Security</label></td>
		<td> </td>
	</tr>
	<tr>
		<td><label><input type="checkbox" name="modules" value="pages" <cfif ListContains(settings.var("modules"), "pages")>checked</cfif>/> Page Content</label></td>
		<td><label><input type="checkbox" name="modules" value="news" <cfif ListContains(settings.var("modules"), "news")>checked</cfif>/> News</label></td>
	</tr>
	<tr>
		<td><label><input type="checkbox" name="modules" value="subscriptions" <cfif ListContains(settings.var("modules"), "subscriptions")>checked</cfif> /> Subscriptions</label></td>
		<td><label><input type="checkbox" name="modules" value="events" <cfif ListContains(settings.var("modules"), "events")>checked</cfif> /> Events</label></td>
	</tr>
	<tr>
		<td><label><input type="checkbox" name="modules" value="contact" <cfif ListContains(settings.var("modules"), "contact")>checked</cfif> /> Contacts</label></td>
		<td><label><input type="checkbox" name="modules" value="randomimage" <cfif ListContains(settings.var("modules"), "randomimage")>checked</cfif> /> Random Images</label></td>
	</tr>
	<tr>
		<td><label><input type="checkbox" name="modules" value="comments" <cfif ListContains(settings.var("modules"), "comments")>checked</cfif> /> Comments</label></td>
		<td><label><input type="checkbox" name="modules" value="newsRSS" <cfif ListContains(settings.var("modules"), "newsRSS")>checked</cfif> /> News RSS Feed</label></td>
	</tr>
	<tr>
		<td><label><input type="checkbox" name="modules" value="Bios" <cfif ListContains(settings.var("modules"), "Bios")>checked</cfif> /> Bios</label></td>
		<td><label><input type="checkbox" name="modules" value="Gallery" <cfif ListContains(settings.var("modules"), "Gallery")>checked</cfif> /> Simple Gallery</label></td>
	</tr>
	<tr>
		<td><label><input type="checkbox" name="modules" value="TCT" <cfif ListContains(settings.var("modules"), "TCT")>checked</cfif> /> TCT (Short URLs)</label></td>
		<td><label><input type="checkbox" name="modules" value="Links" <cfif ListContains(settings.var("modules"), "Links")>checked</cfif> /> Managed Links</label></td>
	</tr>
	<tr>
		<td><label><input type="checkbox" name="modules" value="Careers" <cfif ListContains(settings.var("modules"), "Careers")>checked</cfif> /> Careers</label></td>
		<td><label><input type="checkbox" name="modules" value="Portfolio" <cfif ListContains(settings.var("modules"), "Portfolio")>checked</cfif> /> Portfolio Gallery</label></td>
	</tr>
	<tr>
		<td><label><input type="checkbox" name="modules" value="Combine" <cfif ListContains(settings.var("modules"), "Combine")>checked</cfif> /> Combine JS/CSS</label></td>
		<td><label><input type="checkbox" name="modules" value="Search" <cfif ListContains(settings.var("modules"), "Search")>checked</cfif> /> Site Search </label></td>
	</tr>
	<tr>
		<td><label><input type="checkbox" name="modules" value="Locations" <cfif ListContains(settings.var("modules"), "Locations")>checked</cfif> /> Locations Map</label></td>
		<td><label><input type="checkbox" name="modules" value="crm" <cfif ListContains(settings.var("modules"), "crm")>checked</cfif> /> CRM Tools</label></td>
	</tr>
	<tr>
		<td><label><input type="checkbox" name="modules" value="PrivateContent" <cfif ListContains(settings.var("modules"), "PrivateContent")>checked</cfif> /> Private Content</label></td>
		<td><label><input type="checkbox" name="modules" value="resources" <cfif ListContains(settings.var("modules"), "resources")>checked</cfif> /> User Resources</label></td>
	</tr>
	<tr>
		<td><label><input type="checkbox" name="modules" value="FAQ" <cfif ListContains(settings.var("modules"), "FAQ")>checked</cfif> /> FAQ</label></td>
		<td><label><input type="checkbox" name="modules" value="Splash" <cfif ListContains(settings.var("modules"), "Splash")>checked</cfif> /> Managed Splash Content</label></td>
	</tr>
	<tr>
		<td><label><input type="checkbox" name="modules" value="submitNews" <cfif ListContains(settings.var("modules"), "submitNews")>checked</cfif> /> Submit News (Send)</label></td>
		<td><label><input type="checkbox" name="modules" value="submittedNews" <cfif ListContains(settings.var("modules"), "submittedNews")>checked</cfif> /> Submitted News (Recieve)</label></td>
	</tr>
	<tr>
		<td><label><input type="checkbox" name="modules" value="landings" <cfif ListContains(settings.var("modules"), "landings")>checked</cfif> /> Landings</label></td>
		<td><label><input type="checkbox" name="modules" value="testimonials" <cfif ListContains(settings.var("modules"), "testimonials")>checked</cfif> /> Testimonials</label></td>
	</tr>	
	<tr>
		<td><label><input type="checkbox" name="modules" value="blog" <cfif ListContains(settings.var("modules"), "blog")>checked</cfif>/> Blog</label></td>
		<!--
		<td><label><input type="checkbox" name="modules" value="twilio" <cfif ListContains(settings.var("modules"), "twilio")>checked</cfif> /> Twilio</label></td>
		-->
	</tr>	    
	</table>
</fieldset>

<fieldset class="collapse"><legend>The Basics</legend>
	<p><label for="site">Website Title</label><br />
	<input type="text" name="siteTitle" value="#settings.varStr('siteTitle')#" placeholder="Enter The Website Name" />	</p>
	<p><label for="site">SEO Suffix (appears at end of page titles)</label><br />
	<input type="text" name="titleSuffix" value="#settings.varStr('titleSuffix')#" placeholder="Enter The Title Suffix" />	</p>
	<p><label for="site">Facebook URL</label><br />
	<input type="text" name="FacebookURL" value="#settings.varStr('FacebookURL')#" placeholder="Facebook URL" />	</p>
	<p><label for="site">Twitter Handle</label><br />
	<input type="text" name="TwitterHandle" value="#settings.varStr('TwitterHandle')#" placeholder="Twitter Handle" />	</p>
	<p><label for="site">Google+ Page</label><br />
	<input type="text" name="GooglePlusPage" value="#settings.varStr('GooglePlusPage')#" placeholder="Google+ Page" />	</p>
	<p><label for="site">Pinterest Page</label><br />
	<input type="text" name="PinterestPage" value="#settings.varStr('PinterestPage')#" placeholder="Pinterest Page" />	</p>            
	<p><label for="site">YouTube Channel</label><br />
	<input type="text" name="YouTubeChannel" value="#settings.varStr('YouTubeChannel')#" placeholder="YouTube Channel" />	</p>      
	<p><label for="site">Vimeo Channel</label><br />
	<input type="text" name="VimeoChannel" value="#settings.varStr('VimeoChannel')#" placeholder="Vimeo Channel" />	</p>      
</fieldset>

<fieldset class="collapse"><legend>CSS/Javascript Includes</legend>
	<p><label>Javascript files <small>(comma separated, absolute paths)</small></label><br />
		<textarea name="app.jsfiles" cols="50" rows="2" />#settings.varStr('app.jsfiles')#</textarea></p>	
	<p><label>CSS files <small>(comma separated, absolute paths)</small></label><br />
		<textarea name="app.cssfiles" cols="50" rows="2" />#settings.varStr('app.cssfiles')#</textarea></p>	
</fieldset>

<cfif ListFind(settings.var('modules'), 'news')>	
	<fieldset class="collapse"><legend>News Settings</legend>
		<p>
		<label><input type="radio" name="news.showCategories" id="news.showCategories" value="true" <cfif settings.var('news.showCategories') >checked="checked"</cfif>  /> Show Categories In News Section</label><br />
		<label><input type="radio" name="news.showCategories" id="news.showCategories" value="false" <cfif NOT settings.var('news.showCategories') >checked="checked"</cfif>  /> Hide Categories</label>
		</p>	
	<cfif settings.var('news.showCategories') >
		<p>
		<label><input type="radio" name="news.multipleCategories" id="news.multipleCategories" value="true" <cfif settings.var('news.multipleCategories') >checked="checked"</cfif>  /> Allow Multiple Categories</label><br />
		<label><input type="radio" name="news.multipleCategories" id="news.multipleCategories" value="false" <cfif NOT settings.var('news.multipleCategories') >checked="checked"</cfif>  /> Single Category</label>
		</p>	
	</cfif>
		<p>
		<label><input type="radio" name="news.onAllPages" value="true" <cfif settings.var('news.onAllPages') >checked="checked"</cfif>  /> Make News API available on all pages</label><br />
		<label><input type="radio" name="news.onAllPages" value="false" <cfif NOT settings.var('news.onAllPages') >checked="checked"</cfif>  /> Show news only on Home and News pages</label>
		</p>
		<p>
		<label><input type="radio" name="news.allowDelete" value="true" <cfif settings.var('news.allowDelete') >checked="checked"</cfif>  /> Allow Current News items to be deleted</label><br />
		<label><input type="radio" name="news.allowDelete" value="false" <cfif NOT settings.var('news.allowDelete') >checked="checked"</cfif>  /> News must fall to archive before deletion</label>
		</p>	
		<p>
		<label><input type="radio" name="news.priority" value="true" <cfif settings.var('news.priority') >checked="checked"</cfif>  /> Use absolute priorities to sort news articles</label><br />
		<label><input type="radio" name="news.priority" value="false" <cfif NOT settings.var('news.priority') >checked="checked"</cfif>  /> Use date and title to sort news articles</label>
		</p>	
	
	<p>Number Of News Stories Shown On Lists<br />
	<input type="number" name="news.toplimit" min="0" max="10" step="1" value="#settings.var('news.toplimit')#"></p>
	
	<p>URL To News Page <br />
	<input type="text" name="news.newsurl" value="#settings.varStr('news.newsUrl')#" placeholder="Enter The News URL" />	
	<p>Default News Title<br />
	<input type="text" name="news.newstitle" value="#settings.varStr('news.newstitle')#" placeholder="Enter The News Title" />	
</p>
	<p>Date Format <small>(blank to hide dates)</small><br />
	<input type="text" name="news.dateformat" value="#settings.varStr('news.dateformat')#" placeholder="Enter The Default Date Format" />	
</p>
	<cfif settings.var('modules') CONTAINS 'newsRSS'>
	<p>URL To RSS Feed<br />
	<input type="text" name="newsRss.rssurl" value="#settings.varStr('newsRSS.rssurl')#" placeholder="Enter The RSS Feed URL" /></p>	
	</cfif>

</fieldset>
</cfif>






<cfif ListFind(settings.var('modules'), 'blog')>	
	<fieldset class="collapse"><legend>blog Settings</legend>
		<p>
		<label><input type="radio" name="blog.showCategories" id="blog.showCategories" value="true" <cfif settings.var('blog.showCategories') >checked="checked"</cfif>  /> Show Categories In blog Section</label><br />
		<label><input type="radio" name="blog.showCategories" id="blog.showCategories" value="false" <cfif NOT settings.var('blog.showCategories') >checked="checked"</cfif>  /> Hide Categories</label>
		</p>	
	<cfif settings.var('blog.showCategories') >
		<p>
		<label><input type="radio" name="blog.multipleCategories" id="blog.multipleCategories" value="true" <cfif settings.var('blog.multipleCategories') >checked="checked"</cfif>  /> Allow Multiple Categories</label><br />
		<label><input type="radio" name="blog.multipleCategories" id="blog.multipleCategories" value="false" <cfif NOT settings.var('blog.multipleCategories') >checked="checked"</cfif>  /> Single Category</label>
		</p>	
	</cfif>
		<p>
		<label><input type="radio" name="blog.onAllPages" value="true" <cfif settings.var('blog.onAllPages') >checked="checked"</cfif>  /> Make blog API available on all pages</label><br />
		<label><input type="radio" name="blog.onAllPages" value="false" <cfif NOT settings.var('blog.onAllPages') >checked="checked"</cfif>  /> Show blog only on Home and blog pages</label>
		</p>
		<p>
		<label><input type="radio" name="blog.allowDelete" value="true" <cfif settings.var('blog.allowDelete') >checked="checked"</cfif>  /> Allow Current blog items to be deleted</label><br />
		<label><input type="radio" name="blog.allowDelete" value="false" <cfif NOT settings.var('blog.allowDelete') >checked="checked"</cfif>  /> blog must fall to archive before deletion</label>
		</p>	
		<p>
		<label><input type="radio" name="blog.priority" value="true" <cfif settings.var('blog.priority') >checked="checked"</cfif>  /> Use absolute priorities to sort blog articles</label><br />
		<label><input type="radio" name="blog.priority" value="false" <cfif NOT settings.var('blog.priority') >checked="checked"</cfif>  /> Use date and title to sort blog articles</label>
		</p>	
	
	<p>Number Of blog Stories Shown On Lists<br />
	<input type="number" name="blog.toplimit" min="0" max="10" step="1" value="#settings.var('blog.toplimit')#"></p>
	
	<p>URL To blog Page <br />
	<input type="text" name="blog.blogurl" value="#settings.varStr('blog.blogUrl')#" placeholder="Enter The blog URL" />	
	<p>Default blog Title<br />
	<input type="text" name="blog.blogtitle" value="#settings.varStr('blog.blogtitle')#" placeholder="Enter The blog Title" />	
</p>
	<p>Date Format <small>(blank to hide dates)</small><br />
	<input type="text" name="blog.dateformat" value="#settings.varStr('blog.dateformat')#" placeholder="Enter The Default Date Format" />	
</p>

</fieldset>
</cfif>



<cfif settings.var('modules') CONTAINS 'events'>	
	<fieldset class="collapse"><legend>Events Settings</legend>
		<p>
		<label><input type="radio" name="events.showCategories" value="true" <cfif settings.var('events.showCategories') >checked="checked"</cfif>  /> Show Categories In Events Section</label><br />
		<label><input type="radio" name="events.showCategories" value="false" <cfif NOT settings.var('events.showCategories') >checked="checked"</cfif>  /> Hide Categories</label>
		</p>	
	<cfif settings.var('events.showCategories') >
		<p>
		<label><input type="radio" name="events.multipleCategories" value="true" <cfif settings.var('events.multipleCategories') >checked="checked"</cfif>  /> Allow Multiple Categories</label><br />
		<label><input type="radio" name="events.multipleCategories" value="false" <cfif NOT settings.var('events.multipleCategories') >checked="checked"</cfif>  /> Single Category</label>
		</p>	
	</cfif>
		<p>
		<label><input type="radio" name="events.allowDelete" value="true" <cfif settings.var('events.allowDelete') >checked="checked"</cfif>  /> Allow Current Events to be deleted</label><br />
		<label><input type="radio" name="events.allowDelete" value="false" <cfif NOT settings.var('events.allowDelete') >checked="checked"</cfif>  /> Events must fall to archive before deletion</label>
		</p>	
		<p>
		<label><input type="radio" name="events.priority" value="true" <cfif settings.var('events.priority') >checked="checked"</cfif>  /> Use absolute priorities to sort Events</label><br />
		<label><input type="radio" name="events.priority" value="false" <cfif NOT settings.var('events.priority') >checked="checked"</cfif>  /> Use date and title to sort Events</label>
		</p>	
	
	<p>Number Of Events Shown On Lists<br />
	<input type="number" name="events.toplimit" min="0" max="10" step="1" value="#settings.var('events.toplimit')#"></p>
	
	<p>URL To Events Page <br />
	<input type="text" name="events.url" value="#settings.varStr('events.url')#" placeholder="Enter The Events URL" />	
	<p>Default Events Title<br />
	<input type="text" name="events.title" value="#settings.varStr('events.title')#" placeholder="Enter The Events Title" />	
</p>
	<p>Date Format <small>(blank to hide dates)</small><br />
	<input type="text" name="events.dateformat" value="#settings.varStr('events.dateformat')#" placeholder="Enter The Default Date Format" />	
</p>

</fieldset>
</cfif>

<cfif settings.var('modules') CONTAINS 'comments'>	
	<fieldset class="collapse"><legend>Comments Settings</legend>
		<p>
		<label><input type="radio" name="comments.allowEdit" value="true" <cfif settings.var('comments.allowEdit') >checked="checked"</cfif>  /> Allow Administrators to Edit Comments</label><br />
		<label><input type="radio" name="comments.allowEdit" value="false" <cfif NOT settings.var('comments.allowEdit') >checked="checked"</cfif>  /> Disable Comment Editing</label>
		</p>
		<p>
		<label><input type="radio" name="comments.autoapprove" value="true" <cfif settings.var('comments.autoapprove') >checked="checked"</cfif>  /> Immediately publish comments</label><br />
		<label><input type="radio" name="comments.autoapprove" value="false" <cfif NOT settings.var('comments.autoapprove') >checked="checked"</cfif>  /> Moderate Comments</label>
		</p>	
		<p>Send Comment Notification To:<br />
		<input type="text" name="comments.notifyTo" id="commentNotifyTo" value="#settings.varStr('comments.notifyTo')#" /> <br />
		 (If multiple email addresses separate with a comma (,). Leave blank to disable.</p>
</p>
</fieldset>
</cfif>
<cfif settings.var('modules') CONTAINS 'randomimage'>
	<fieldset class="collapse"><legend>Random Images</legend>
	<p><label for="site">Image Pool Location</label><br />
		<input type="text" name="randomimage.imagepool" value="#settings.varStr('randomimage.imagepool')#" placeholder="Pool path (absolute)" />	</p>
		</fieldset>
</cfif>
<cfif settings.var('modules') CONTAINS 'subscriptions'>
	<fieldset class="collapse"><legend>Newsletter/Email Subscription Settings</legend>
	<p>
				<label>Send Email Through MC &nbsp;&nbsp;
				<select name="subscriptions.sendByMC" size="1" >
					<option value="0"> -- Select -- </option>
					<option value="1"<cfif settings.var('subscriptions.sendByMC') eq "1">selected</cfif>>Yes</option>
					<option value="0" <cfif settings.var('subscriptions.sendByMC') eq "0">selected</cfif>>No</option>
				</select></label><br />
				
				<label>Send Notification to Admin &nbsp;&nbsp;
				<select name="subscriptions.notifyAdmin" size="1" >
					<option value="0"> -- Select -- </option>
					<option value="1"<cfif settings.var('subscriptions.notifyAdmin') eq "1">selected</cfif>>Yes</option>
					<option value="0" <cfif settings.var('subscriptions.notifyAdmin') eq "0">selected</cfif>>No</option>
				</select></label><br />
				
				<label>Send Verification Email To New Subscribers &nbsp;&nbsp;<span class="error">NOT IMPLEMENTED</span>
				<select name="subscriptions.verifyAdds" size="1" >
					<option value="0"> -- Select -- </option>
					<option value="1"<cfif settings.var('subscriptions.verifyAdds') eq "1">selected</cfif>>Yes</option>
					<option value="0" <cfif settings.var('subscriptions.verifyAdds') eq "0">selected</cfif>>No</option>
				</select></label><br />
				
				<label>Allow Mailing List Export &nbsp;&nbsp;
				<select name="subscriptions.listexport" size="1" >
					<option value="0"> -- Select -- </option>
					<option value="1"<cfif settings.var('subscriptions.listexport') eq "1">selected</cfif>>Yes</option>
					<option value="0" <cfif settings.var('subscriptions.listexport') eq "0">selected</cfif>>No</option>
				</select></label><br />
				
		</p>	
		
		<p>Send Notification to<br />
		<input type="text" name="subscriptions.emailTo" id="emailTo" value="#settings.varStr('subscriptions.emailTo')#" /> <br />
		 (If multiple email addresses separate with a comma (,).</p>
		 
		 <p>Notifications Sent From Email Address<br />
		<input type="text" name="subscriptions.emailFrom" id="emailFrom" value="#settings.varStr('subscriptions.emailFrom')#" /> </p>		
	
		 <p>Notifications BCC Email Address<br />
		<input type="text" name="subscriptions.emailBCC" id="emailBCC" value="#settings.varStr('subscriptions.emailBCC')#" /> <br />
		 (If multiple email addresses separate with a comma (,).</p>
		 
		 <p>Notifications Email Subject<br />
		<input type="text" name="subscriptions.emailSubject" id="emailSubject" value="#settings.varStr('subscriptions.emailSubject')#" /></p>
		
	</fieldset>
</cfif>
<cfif settings.var('modules') CONTAINS 'contact'>
	<fieldset class="collapse"><legend>Contact Settings</legend>
	<p>
		<label><input type="radio" name="contact.formTypes" id="contact.formTypes" value="1" <cfif settings.var('contact.formTypes') >checked="checked"</cfif>  /> Display Form Type Field</label><br />
		<label><input type="radio" name="contact.formTypes" id="contact.formTypes" value="0" <cfif NOT settings.var('contact.formTypes') >checked="checked"</cfif>  /> Hide Form Type</label>
		</p>	
	<p>
		<label><input type="radio" name="contact.allowDownload" id="contact.allowDownload" value="1" <cfif settings.var('contact.allowDownload') >checked="checked"</cfif>  /> Allow XLS Export</label><br />
		<label><input type="radio" name="contact.allowDownload" id="contact.allowDownload" value="0" <cfif NOT settings.var('contact.allowDownload') >checked="checked"</cfif>  /> Disable XLS Export</label>
		</p>	
	<p>
		<label><input type="radio" name="contact.allowArchive" id="contact.allowArchive" value="1" <cfif settings.var('contact.allowArchive') >checked="checked"</cfif>  /> Allow Archive</label><br />
		<label><input type="radio" name="contact.allowArchive" id="contact.allowArchive" value="0" <cfif NOT settings.var('contact.allowArchive') >checked="checked"</cfif>  /> Disable Archive</label>
		</p>	
	<p>
		<label><input type="radio" name="contact.allowDelete" id="contact.allowDelete" value="1" <cfif settings.var('contact.allowDelete') >checked="checked"</cfif>  /> Allow Deletion</label><br />
		<label><input type="radio" name="contact.allowDelete" id="contact.allowDelete" value="0" <cfif NOT settings.var('contact.allowDelete') >checked="checked"</cfif>  /> Disable Deletion</label>
		</p>	
	<p>
		<label><input type="radio" name="contact.emailNotify" id="contact.emailNotify" value="1" <cfif settings.var('contact.emailNotify') >checked="checked"</cfif>  /> Send Email Notifications</label><br />
		<label><input type="radio" name="contact.emailNotify" id="contact.emailNotify" value="0" <cfif NOT settings.var('contact.emailNotify') >checked="checked"</cfif>  /> Do Not Notify</label>
		</p>	
		
		<p>Default Contact Email Address<br />
		<input type="text" name="contact.emailNotifyTo" id="emailNotifyTo" value="#settings.varStr('contact.emailNotifyTo')#" /> <br />
		 (If multiple email addresses separate with a comma (,).</p>
		 
		 <p>Notifications Sent From Email Address<br />
		<input type="text" name="contact.emailNotifyFrom" id="emailNotifyFrom" value="#settings.varStr('contact.emailNotifyFrom')#" /> </p>		
	
		 <p>Notifications BCC Email Address<br />
		<input type="text" name="contact.emailNotifyBCC" id="emailNotifyBCC" value="#settings.varStr('contact.emailNotifyBCC')#" /> <br />
		 (If multiple email addresses separate with a comma (,).</p>
		 
		 <p>Notifications Email Subject<br />
		<input type="text" name="contact.emailNotifySubject" id="emailNotifySubject" value="#settings.varStr('contact.emailNotifySubject')#" /></p>
		
		<p>Contact Form Fields<br />
		<input type="text" name="contact.formFields" id="formfields" value="#settings.varStr('contact.formfields')#" /><br />
		(Separate with a comma (,).)</p>
		<p>Contact Form Labels<br />
		<input type="text" name="contact.labelFields" id="labelFields" value="#settings.varStr('contact.labelFields')#" /><br />
		(Separate with a comma (,).)</p>
		<p>Contact Form List Fields<br />
		<input type="text" name="contact.listFields" id="labelFields" value="#settings.varStr('contact.listfields')#" /><br />
		(Separate with a comma (,).)</p>
	</fieldset>
</cfif>


<cfif settings.var('modules') CONTAINS 'submitNews'>
	<fieldset class="collapse"><legend>News Submission Settings</legend>
		<p>Send Notification To<br />
		<input type="text" name="submitNews.sendTo" value="#settings.varStr('submitNews.sendTo')#" /> <br />
		 (If multiple email addresses separate with a comma (,).</p>
		 
		 <p>Notifications Sent From Email Address<br />
		<input type="text" name="submitNews.sendFrom"value="#settings.varStr('submitNews.sendFrom')#" /> </p>		
	
		 <p>Notifications BCC Email Address<br />
		<input type="text" name="submitNews.sendBcc" value="#settings.varStr('submitNews.sendBcc')#" /> <br />
		 (If multiple email addresses separate with a comma (,).</p>
		 
		 <p>Notifications Email Subject<br />
		<input type="text" name="submitNews.sendSubject" value="#settings.varStr('submitNews.sendSubject')#" /></p>
		
		<p>POST to URL:<br />
		<input type="text" name="submitNews.recordURL" value="#settings.varStr('submitNews.recordURL')#" /><br />
	</p>
	</fieldset>
</cfif>


<cfif settings.var('modules') CONTAINS 'careers'>
	<fieldset class="collapse"><legend>Careers Settings</legend>
	
	<p>Resume Upload Path<br />
		<input type="text" name="careers.path" value="#settings.varStr('careers.path')#" />
	</p>

	<p>
		<label><input type="radio" name="careers.allowDownload" value="1" <cfif settings.var('careers.allowDownload') >checked="checked"</cfif>  /> Allow XLS Export</label><br />
		<label><input type="radio" name="careers.allowDownload" value="0" <cfif NOT settings.var('careers.allowDownload') >checked="checked"</cfif>  /> Disable XLS Export</label>
		</p>	
	<p>
		<label><input type="radio" name="careers.emailNotify" value="1" <cfif settings.var('careers.emailNotify') >checked="checked"</cfif>  /> Send Email Notifications</label><br />
		<label><input type="radio" name="careers.emailNotify" value="0" <cfif NOT settings.var('careers.emailNotify') >checked="checked"</cfif>  /> Do Not Notify</label>
		</p>	
		
		<p>Default Career App Notification Email Address<br />
		<input type="text" name="careers.emailNotifyTo" id="emailNotifyTo" value="#settings.varStr('careers.emailNotifyTo')#" /> <br />
		 (If multiple email addresses separate with a comma (,).</p>
		 
		 <p>Notifications Sent From Email Address<br />
		<input type="text" name="careers.emailNotifyFrom" id="emailNotifyFrom" value="#settings.varStr('careers.emailNotifyFrom')#" /> </p>		
	
		 <p>Notifications BCC Email Address<br />
		<input type="text" name="careers.emailNotifyBCC" id="emailNotifyBCC" value="#settings.varStr('careers.emailNotifyBCC')#" /> <br />
		 (If multiple email addresses separate with a comma (,).</p>
		 
		 <p>Notifications Email Subject<br />
		<input type="text" name="careers.emailNotifySubject" id="emailNotifySubject" value="#settings.varStr('careers.emailNotifySubject')#" /></p>
		
		<p>careers Form Fields<br />
		<input type="text" name="careers.formFields" id="formfields" value="#settings.varStr('careers.formfields')#" /><br />
		(Separate with a comma (,).)</p>
		<p>careers Form Labels<br />
		<input type="text" name="careers.labelFields" id="labelFields" value="#settings.varStr('careers.labelFields')#" /><br />
		(Separate with a comma (,).)</p>
		<p>Contact Form List Fields<br />
		<input type="text" name="careers.listFields" id="labelFields" value="#settings.varStr('careers.listfields')#" /><br />
		(Separate with a comma (,).)</p>
	</fieldset>
</cfif>

<cfif settings.var('modules') CONTAINS 'links'>
	<fieldset class="collapse"><legend>Managed Links Settings</legend>
	<p>
		<label><input type="radio" name="links.showCategories" id="links.showCategories" value="true" <cfif settings.var('links.showCategories') >checked="checked"</cfif>  /> Manage links by category</label><br />
		<label><input type="radio" name="links.showCategories" id="links.showCategories" value="false" <cfif NOT settings.var('links.showCategories') >checked="checked"</cfif>  /> Use a flat list</label>
		</p>
	</fieldset>
</cfif>

<cfif settings.var('modules') CONTAINS 'Gallery' OR settings.Var('modules') CONTAINS 'Portfolio'>
	<fieldset class="collapse"><legend>Image Upload Settings</legend>
	<p>
	<label for="imagesPath">Upload Path</label><br />
		<input type="text" name="images.path" id="imagesPath" value="#settings.varStr('images.path')#" /></p>
	<p>Thumbnail Max Width:<br />
	<input type="number" name="images.thumbWidth" min="10" max="250" step="1" value="#settings.var('images.thumbwidth')#"></p>
	<p>Thumbnail Max Height:<br />
	<input type="number" name="images.thumbHeight" min="10" max="250" step="1" value="#settings.var('images.thumbheight')#"></p>
	<p>Resized Max Width:<br />
	<input type="number" name="images.resizeWidth" min="150" max="800" step="1" value="#settings.var('images.resizewidth')#"></p>
	<p>Resized Max Height:<br />
	<input type="number" name="images.resizeHeight" min="150" max="1000" step="1" value="#settings.var('images.resizeheight')#"></p>
	
	<p><label>Delete Original Files</label><br />
		<input type="radio" name="images.deleteOriginals" id="deleteOriginals" value="true" <cfif settings.var('images.deleteOriginals')> checked="checked" </cfif> /> Delete uploaded images after resize<br />
		<input type="radio" name="images.deleteOriginals" id="deleteOriginals" value="false" <cfif NOT settings.var('images.deleteOriginals')> checked="checked" </cfif> /> Keep uploaded images after resize<br />
	</p>
	</fieldset>
</cfif>

<cfif settings.var('modules') CONTAINS 'Portfolio'>
	<fieldset class="collapse"><legend>Portfolio Gallery Settings</legend>
	<p>Portfolio Module URL <small>cannot contain slashes (top level only)</small><br />
	<input type="text" name="portfolio.portfolioURL" value="#settings.varStr('portfolio.portfolioURL')#" placeholder="Enter The URL to trigger Portfolio" />
</p>
	<p><label>Show Captions on Images</label><br />
		<input type="radio" name="portfolio.showCaptions" id="allowAddDelete" value="true" <cfif settings.var('portfolio.showCaptions')> checked="checked" </cfif> /> Show Captions<br />
		<input type="radio" name="portfolio.showCaptions" id="allowAddDelete" value="false" <cfif NOT settings.var('portfolio.showCaptions')> checked="checked" </cfif> /> Hide Captions<br />
	</p>
	<p><label>Use teaser field</label><br />
		<input type="radio" name="portfolio.teaser" value="true" <cfif settings.var('portfolio.teaser')> checked="checked" </cfif> /> Use teaser<br />
		<input type="radio" name="portfolio.teaser" value="false" <cfif NOT settings.var('portfolio.teaser')> checked="checked" </cfif> /> Hide teaser<br />
	</p>
	<p><label>Category Details</label><br />
		<input type="radio" name="portfolio.categoryDetail" value="true" <cfif settings.var('portfolio.categoryDetail')> checked="checked" </cfif> /> Use Category Landing Page (+ description)<br />
		<input type="radio" name="portfolio.categoryDetail" value="false" <cfif NOT settings.var('portfolio.categoryDetail')> checked="checked" </cfif> /> Redirect category URLs to the first project in that category.<br />
	</p>
	
	<p><label>Use 'Featured' Projects</label><br />
		<input type="radio" name="portfolio.features" value="true" <cfif settings.var('portfolio.features')> checked="checked" </cfif> /> Allow projects to be featured<br />
		<input type="radio" name="portfolio.features" value="false" <cfif NOT settings.var('portfolio.features')> checked="checked" </cfif> /> Hide 'Featured' checkbox (All projects default to NOT featured)<br />
	</p>
	
	<p><label>Use GEO module</label><br />
		<input type="radio" name="portfolio.geo" value="true" <cfif settings.var('portfolio.geo')> checked="checked" </cfif> /> Use Address and Geocode<br />
		<input type="radio" name="portfolio.geo" value="false" <cfif NOT settings.var('portfolio.geo')> checked="checked" </cfif> /> Hide Address and Geocode<br />
	</p>
	
	</fieldset>

</cfif>
<cfif settings.var('modules') CONTAINS 'Gallery'>
	<fieldset class="collapse"><legend>Simple Gallery Settings</legend>
	<p><label>Allow Addition/Deletion of Galleries</label><br />
		<input type="radio" name="gallery.allowAddDelete" id="allowAddDelete" value="true" <cfif settings.var('gallery.allowAddDelete')> checked="checked" </cfif> /> Allow Users to create any number of Galleries<br />
		<input type="radio" name="gallery.allowAddDelete" id="allowAddDelete" value="false" <cfif NOT settings.var('gallery.allowAddDelete')> checked="checked" </cfif> /> Limit Users to the galleries they are given.<br />
	</p>
	<p><label>Show Gallery Descriptions</label><br />
		<input type="radio" name="gallery.showDescriptions" id="showDescriptions" value="true" <cfif settings.var('gallery.showDescriptions')> checked="checked" </cfif> /> Show Gallery Descriptions<br />
		<input type="radio" name="gallery.showDescriptions" id="showDescriptions" value="false" <cfif NOT settings.var('gallery.showDescriptions')> checked="checked" </cfif> /> Hide Gallery Descriptions<br />
	</p>
	</fieldset>

</cfif>
<cfif settings.var('modules') CONTAINS 'Combine'>
	<fieldset class="collapse"><legend>JS/CSS Combine Library</legend>
	<p><label>Use component or built in tag? (tag not implemented)</label><br />
		<input type="radio" name="combine.library" value="true" <cfif settings.var('combine.library')> checked="checked" </cfif> /> Use &lt;cfjavascript&gt;.(not implemented)<br />
		<input type="radio" name="combine.library"  value="false" <cfif NOT settings.var('combine.library')> checked="checked" </cfif> /> Use <em>Combine.cfc</em>.<br />
	</p>
	</fieldset>
</cfif>

<cfif settings.var('modules') CONTAINS 'Search'>
	<fieldset class="collapse"><legend>Site Search</legend>
	<p>Site Search Module URL<br />
	<input type="text" name="search.url" value="#settings.varStr('search.url')#" placeholder="Enter The URL to trigger Search" />	
	</p>
	<p>Number of results to return:<br />
	<input type="text" name="search.numresults" value="#settings.varStr('search.numresults')#" placeholder="Enter The Number of results to return" />	
	</p>
	<p><label>Search Engine:</label><br />
		<input type="radio" name="search.engine" value="google" <cfif settings.varStr('search.engine') EQ 'google'> checked="checked" </cfif> /> Use Google Site Search<br />
		</p>
	<cfif settings.var('search.engine') EQ "google">
	<p>Google Search API Key<br />
	<input type="text" name="search.googlekey" value="#settings.varStr('search.googlekey')#" placeholder="Enter your Google Search API key" />	
	</p>
	</cfif>
	</fieldset>

</cfif>
	
<cfif settings.var('modules') CONTAINS 'TCT'>
	<fieldset class="collapse"><legend>TCT Settings</legend>
	<p><label>Collect Show Advanced Statistics:</label><br />
		<input type="radio" name="tct.advancedStats" value="1" <cfif settings.var('tct.advancedStats')> checked="checked" </cfif> /> Collect and Show Advanced Statistics<br />
		<input type="radio" name="tct.advancedStats" value="0" <cfif NOT settings.var('tct.advancedStats')> checked="checked" </cfif> /> Only Show Number of Visits
		</p>
	</fieldset>

</cfif>
	
<cfif settings.var('modules') CONTAINS 'resources'>
	<fieldset class="collapse"><legend>User Resources Settings</legend>
	<p>File Upload Path<br />
	<input type="text" name="resources.path" value="#settings.varStr('resources.path')#" placeholder="Enter the File Upload Path" />	
	</p>
	<p><label>Allow Links to be resources:</label><br />
		<input type="radio" name="resources.allowlinks" value="1" <cfif settings.var('resources.allowlinks')> checked="checked" </cfif> /> Use links and files<br />
		<input type="radio" name="resources.allowlinks" value="0" <cfif NOT settings.var('resources.allowlinks')> checked="checked" </cfif> /> Upload files ONLY.
		</p>
	<p><label>Limit file access by login: <small>(Requires Private Content Tool)</small></label><br />
		<input type="radio" name="resources.uselogins" value="1" <cfif settings.var('resources.uselogins')> checked="checked" </cfif> /> Organize Files by User logins<br />
		<input type="radio" name="resources.uselogins" value="0" <cfif NOT settings.var('resources.uselogins')> checked="checked" </cfif> /> Use a flat list of resources.
		</p>
	<p><label>Use Absolute Sort Order</label><br />
		<input type="radio" name="resources.usepriority" value="1" <cfif settings.var('resources.usepriority')> checked="checked" </cfif> /> Use absolute sort order<br />
		<input type="radio" name="resources.usepriority" value="0" <cfif NOT settings.var('resources.usepriority')> checked="checked" </cfif> /> Use date-based sort.
		</p>
	<p><label>Use Categories</label><br />
		<input type="radio" name="resources.usecategories" value="1" <cfif settings.var('resources.usecategories')> checked="checked" </cfif> /> Use Category organization<br />
		<input type="radio" name="resources.usecategories" value="0" <cfif NOT settings.var('resources.usecategories')> checked="checked" </cfif> /> Use a flat list of resources.
		</p>
	<p><label>Use Time-Based Publishing</label><br />
		<input type="radio" name="resources.publishexpire" value="1" <cfif settings.var('resources.publishexpire')> checked="checked" </cfif> /> Use Publish and Expiration dates<br />
		<input type="radio" name="resources.publishexpire" value="0" <cfif NOT settings.var('resources.publishexpire')> checked="checked" </cfif> /> Resources are always published.
		</p>
	<p><label>Provide event.resources API on every page</label><br />
		<input type="radio" name="resources.api" value="1" <cfif settings.var('resources.api')> checked="checked" </cfif> /> Provide API automatically<br />
		<input type="radio" name="resources.api" value="0" <cfif NOT settings.var('resources.api')> checked="checked" </cfif> /> Set up objects manually.
		</p>
	<p>Number Of Resources to show in "top" lists:<br />
	<input type="number" name="resources.toplimit" min="0" max="10" step="1" value="#settings.var('resources.toplimit')#"></p>
	<p>Custom URL:<br />
	<input type="text" name="resources.customurl" min="0" max="10" step="1" value="#settings.varstr('resources.customurl')#"></p>
	</fieldset>

</cfif>

<cfif settings.var('modules') CONTAINS 'FAQ'>
<fieldset class="collapse"><legend>FAQ Settings</legend>
	
	<p><label>Use Categories</label><br />
		<input type="radio" name="faqs.usecategories" value="1" <cfif settings.var('faqs.usecategories')> checked="checked" </cfif> /> Use Category organization<br />
		<input type="radio" name="faqs.usecategories" value="0" <cfif NOT settings.var('faqs.usecategories')> checked="checked" </cfif> /> Use a flat list of questions.
		</p>
	<p><label>Use Absolute Sort Order</label><br />
		<input type="radio" name="faqs.usepriority" value="1" <cfif settings.var('faqs.usepriority')> checked="checked" </cfif> /> Use absolute sort order<br />
		<input type="radio" name="faqs.usepriority" value="0" <cfif NOT settings.var('faqs.usepriority')> checked="checked" </cfif> /> Sort based on most recent update.
		</p>
	<p>FAQs URL<br />
	<input type="text" name="faqs.url" value="#settings.varStr('faqs.url')#" placeholder="Enter The URL to trigger FAQs" />	
	</p>
</fieldset>
</cfif>
	
<cfif settings.var('modules') CONTAINS 'Locations'>
	<fieldset class="collapse"><legend>Locations Map</legend>
	<p>Location Module URL<br />
	<input type="text" name="locations.url" value="#settings.varStr('locations.url')#" placeholder="Enter The URL to trigger Locations" />	
	</p>
	<p>Location Module Page Title <small>(overwrites Page title at the same url if set)</small><br />
	<input type="text" name="locations.title" value="#settings.varStr('locations.title')#" placeholder="Enter The page title" />	
	</p>
	<p>Default Country Code <small>USA, CAN, etc.</small><br />
	<input type="text" name="locations.defaultCountry" value="#settings.varStr('locations.defaultCountry')#" placeholder="Enter The Default Country" />	
	</p>
	<p><label>Show Country Field </label><br />
		<input type="radio" name="locations.showCountry"  value="true" <cfif settings.var('locations.showCountry')> checked="checked" </cfif> /> Show Country Field<br />
		<input type="radio" name="locations.showCountry"  value="false" <cfif NOT settings.var('locations.showCountry')> checked="checked" </cfif> /> Hide Country Field<br />
		</p>
	<p><label>Use Cache for marker data</label><br />
		<input type="radio" name="locations.useCache"  value="true" <cfif settings.var('locations.useCache')> checked="checked" </cfif> /> Use Cache<br />
		<input type="radio" name="locations.useCache"  value="false" <cfif NOT settings.var('locations.useCache')> checked="checked" </cfif> /> Turn off Caching<br />
		</p>
	<p><label>Map Engine:</label><br />
		<input type="radio" name="locations.engine" value="google" <cfif settings.varStr('locations.engine') EQ 'google'> checked="checked" </cfif> /> Use Google Maps<br />
		</p>
	<cfif settings.var('locations.engine') EQ "google">
	<p>Google Maps API Key<br />
	<input type="text" name="locations.googlekey" value="#settings.varStr('locations.googlekey')#" placeholder="Enter your Google Maps API key" />	
	</p>
	</cfif>
	</fieldset>

</cfif>


<cfif settings.var('modules') CONTAINS 'Splash'>
	<fieldset class="collapse"><legend>Splash Content</legend>
	<p>MC Warning text<br />
	<input type="text" name="splash.warning" value="#settings.varStr('splash.warning')#" placeholder="Disclaimer and Warnings" />	
	</p>
	<p>Max Teaser Length<br />
	<input type="text" name="splash.teaserLength" value="#settings.varStr('splash.teaserLength')#" placeholder="Limit the teaser to x characters" />	
	</p>
	<p>Max Splash Items<br />
	<input type="text" name="splash.toplimit" value="#settings.varStr('splash.toplimit')#" placeholder="Number of Splash Items" />	
	</p>
	<p><label>Lock Splash Items </label><br />
		<input type="radio" name="splash.locked"  value="true" <cfif settings.var('splash.locked')> checked="checked" </cfif> /> Edit Content only <br />
		<input type="radio" name="splash.locked"  value="false" <cfif NOT settings.var('splash.locked')> checked="checked" </cfif> /> Users can add and remove items<br />
	</p>
	<p>Image Upload Path<br />
	<input type="text" name="splash.path" value="#settings.varStr('splash.path')#" placeholder="trailing slash" />	
	</p>
	<p><label>Resize Images </label><br />
		<input type="radio" name="splash.autosize"  value="true" <cfif settings.var('splash.autosize')> checked="checked" </cfif> /> Auto Resize splash Images (Not implemented)<br />
		<input type="radio" name="splash.autosize"  value="false" <cfif NOT settings.var('splash.autosize')> checked="checked" </cfif> /> Use Images as-is<br />
	</p>
	</fieldset>

</cfif>
	
<cfif settings.var('modules') CONTAINS 'pages'>
	<fieldset class="collapse"><legend>Site Content Settings</legend>
	<p><label for="defaultDescription">Site Meta Description</label><br />
		<textarea name="defaultDescription" cols="50" rows="4" />#settings.varStr('defaultDescription')#</textarea></p>	
		
	<p><label for="defaultKeywords">Site Meta Keywords</label><br />
		<textarea name="defaultKeywords" cols="50" rows="4" />#settings.varStr('defaultKeywords')#</textarea></p>	
	
	
	<p><label for="dualContent">Show two (2) editable content areas </label><br />
		<input type="radio" name="pages.dualContent" id="dualContent" value="true" <cfif settings.var('pages.dualContent')> checked="checked" </cfif> /> Two Content Areas<br />
		<input type="radio" name="pages.dualContent" id="dualContent" value="false" <cfif NOT settings.var('pages.dualContent')> checked="checked" </cfif> /> Single Content Area<br />
		</p>
	
	<p><label for="redirect">Allow pages to redirect (Similar to TCT)</label><br />
		<input type="radio" name="pages.redirect" id="redirect" value="true" <cfif settings.var('pages.redirect')> checked="checked" </cfif> /> Allow redirects<br />
		<input type="radio" name="pages.redirect" id="redirect" value="false" <cfif NOT settings.var('pages.redirect')> checked="checked" </cfif> /> Pages are for Content ONLY<br />
		</p>
	
	<p><label for="showCustomFields">Show Custom Fields</label><br />
		<input type="radio" name="content.showCustomFields" value="true" <cfif settings.var('content.showCustomFields')> checked="checked" </cfif> /> Show Custom Fields<br />
		<input type="radio" name="content.showCustomFields" value="false" <cfif NOT settings.var('content.showCustomFields')> checked="checked" </cfif> /> Hide Custom Fields</p>
	
    <p><label for="showHistory">Show Duplicate Button</label><br />
    	<input type="radio" name="content.duplicate" id="content.duplicate" value="true" <cfif settings.var('content.duplicate') >checked="checked"</cfif>  /> Show Duplicate Button<br />
    	<input type="radio" name="content.duplicate" id="content.duplicate" value="false" <cfif NOT settings.var('content.duplicate') >checked="checked"</cfif>  /> Hide Duplicate Button</p>    
    
    </fieldset>
</cfif>
<fieldset class="collapse"><legend>Analytics/Tracking Includes</legend>
	<p>	<label >Google Analytics Property ID:<br /><input type="text" class="smalltext" name="app.googleAnalyticsID" value="#settings.varStr('app.googleAnalyticsID')#" /></label>
	<br />
	<label for="tracking">Custom Tracking/Analytics Code Add Javascript that will be inserted into the footer. Don't include script tags.</label><br />
		<textarea name="tracking_code" cols="50" rows="4">#settings.varStr('app.tracking_code')#</textarea><br />
    
    <label for="tracking">This is Google's site verification ID tag for webmaster Tools.<br /><input type="text" class="smalltext" name="app.googleSiteVerification" value="#settings.varStr('app.googleSiteVerification')#" /></label><br />
    
    <label for="tracking">This is Microsoft/Bing's site verification ID tag.<br /><input type="text" class="smalltext" name="app.msvalidate" value="#settings.varStr('app.msvalidate')#" /></label><br />
        	
    <label for="tracking">This is Yahoo's site explorer ID tag verification.<br /><input type="text" class="smalltext" name="app.yahooKey" value="#settings.varStr('app.yahooKey')#" /></label><br />
    
    <label for="tracking">Google+ profile URL<br /><input type="text" class="smalltext" name="app.googlePlusProfile" value="#settings.varStr('app.googlePlusProfile')#" /></label>        
		</p>
</fieldset>
<fieldset class="collapse"><legend>URL Structure</legend>
	<p><label for="prettyurls">SEO URLs</label><br />
		<input type="radio" name="prettyurls" id="prettyurls" value="true" <cfif settings.var('prettyurls')> checked="checked" </cfif> /> Enable Pretty URLs<br />
		<input type="radio" name="prettyurls" id="prettyurls" value="false" <cfif NOT settings.var('prettyurls')> checked="checked" </cfif> /> Use GET variable URLs<br />
		(Automatically translates your path-based URLs so that they don't include 'index.cfm')</p>
</fieldset>

<!--
<cfif settings.var('modules') CONTAINS 'twilio'>
	<fieldset class="collapse"><legend>Twilio Settings</legend>
    <p>
    <label>AccountSID
    <input type="text" name="twilio.AccountSID" id="twilio.AccountSID" value="#settings.varStr('twilio.AccountSID')#"  /></label>
    <br />
    <label>AuthToken
    <input type="text" name="twilio.AuthToken" id="twilio.AuthToken" value="#settings.varStr('twilio.AuthToken')#"  /></label>
    <br />
    <label>SMS Number: e.g. (402) 858-8120
    <input type="text" name="twilio.SMSNumber" id="twilio.SMSNumber" value="#settings.varStr('twilio.SMSNumber')#"  /></label>    
    </p>
	</fieldset>
</cfif>
-->


<fieldset class="collapse"><legend>Caching</legend>
	<p>
	Note: this affects the front-end only.<br />
	<label>Cache Pages for <em>n</em> minutes<br />
		<input type="text" name="app.cacheTime" value="#settings.varStr('app.cacheTime')#">
		</label><br />
	<small>Queries are usually cached for 5 minutes.</small>
	</p>
</fieldset>
<fieldset class="collapse"><legend>Debug Level</legend>
	<p>
	Note: this is a global setting. If enabled, all errors will be displayed to all visitors of the site.<br />
	<input type="radio" name="debug_level" value="false" <cfif NOT settings.var('debug_level')> checked="checked"</cfif> /> Production - Errors and database exceptions will be suppressed.<br />
	<input type="radio" name="debug_level" value="true" <cfif settings.var('debug_level')> checked="checked"</cfif> /> Development - Errors and database exceptions will be displayed.
	
	</p>
</fieldset>
<fieldset class="collapse"><legend>Version Info</legend>
	<p>
	Note: this applies only to the managementcenter.<br />
	<input type="radio" name="app.hideVersionInfo" value="false" <cfif NOT settings.var('app.hideVersionInfo')> checked="checked"</cfif> /> Show version information in the footer.<br />
	<input type="radio" name="app.hideVersionInfo" value="true" <cfif settings.var('app.hideVersionInfo')> checked="checked"</cfif> /> Hide version information.<br />
	<br />
	<small><cfif FileExists(ExpandPath("#application.slashroot#managementcenter/VERSION.txt"))>
	   Version <cfinclude template="#application.slashroot#managementcenter/VERSION.txt"> 
	   </cfif><br />
	   <cfif len(settings.varstr('app.schemaVersion'))>Schema: <cfoutput>#settings.varStr('app.schemaVersion')#<br />(#settings.varStr('app.schemadate')#)</cfoutput></cfif></small>
	
	</p>
</fieldset>
	<br />
    <input type="HIDDEN" name="Action" value="Update">
    <button class="submit" type="submit" tabindex="30">Update Settings</button>
                   
                      
	
	
</form>
</cfoutput>