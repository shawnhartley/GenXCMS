<cfparam name="results.success" type="boolean" default="0">
<cfparam name="results.cfcatch" type="struct" default="#StructNew()#">
<cfparam name="form.nameFirst" default=""> <!--- This is the honeypot --->
<cfparam name="form.name" default="">
<cfparam name="form.lastName" default="">
<cfparam name="form.email" default="">
<cfparam name="form.phone" default="">
<cfparam name="form.companyName" default="">
<cfparam name="form.message" default="">
<cfparam name="form.date" default="#now()#">
<cfparam name="form.personOrCompanyThatReferred" default="">
<cfparam name="form.formType" default="Contact Form">
<cfparam name="form.title" default="">
<cfparam name="form.howDidYouHear" default="">
<cfparam name="form.dateCreated" default="#now()#">

<cfif structKeyExists(form,"createContact")>
	<cfset contact = createObject("component", application.dotroot & "cfcs.contact").init()>
	<cfset results = contact.insertContact(argumentcollection= form)>
</cfif>

<cfif NOT results.success and event.slug NEQ 'thank-you'>
	<cfoutput>
		<cfif structKeyExists(form,"createContact")>
			<p class="error">We're sorry, there were errors in your submission. Please try again.</p>
			<p class="error">#results.message#</p>
		</cfif>
		
		<form action="" method="post" data-abide>
			<!-- BOTS ARE DUMB -->
			<div class="nameFirst">
				<label for="nameFirst">First Name
					<input id="nameFirst" type="input" name="nameFirst" class="nameFirst" value="#form.nameFirst#" title="Enter Your First Name">
				</label>
			</div>
			<!-- /BOTS ARE DUMB -->
			
			<div class="row">
				<div class="small-12 medium-4 columns">
					<label for="name">First Name <span>*</span>
						<input id="name" type="text" name="name" value="#form.name#" placeholder="First Name" title="First name." required />
					</label>
					<small class="error">First name is required.</small>
				</div><!--/medium4-->
				<div class="small-12 medium-4 columns">
					<label for="lastName">Last Name <span>*</span>
						<input id="lastName" type="text" name="lastName" value="#form.lastName#" placeholder="Last Name" title="Last name." required />
					</label>
					<small class="error">Last name is required.</small>
				</div><!--/medium4-->
				<div class="small-12 medium-4 columns">
					<label for="email">Email <span>*</span>
						<input id="email" type="email" name="email" value="#form.email#" placeholder="FirstLast@email.com" title="Your email address." required />
					</label>
					<small class="error">Don't forget your email!.</small>		
				</div><!--/medium4-->
			</div><!--/row-->
			
			<div class="row">
				<div class="small-12 medium-6 columns">
					<label for="phone">Phone <span>*</span>
						<input id="phone" type="tel" name="phone" value="#form.phone#" placeholder="Your phone number." title="Your phone number." required />
						<small class="error">Please include your phone number.</small>
					</label>
				</div><!--/medium6-->
				<div class="small-12 medium-6 columns">
					<label for="companyName"> Company Name:
						<input id="companyName" type="text" name="companyName" value="#form.companyName#" placeholder="Your company name." title="Your company name." />
					</label>
				</div><!--/medium6-->
			</div><!--/row-->
			
			<div class="row">
				<div class="medium-12 columns">
					<label for="message">Message:</label>
					<textarea id="message" name="message">#form.message#</textarea>
				</div><!--/medium12-->
			</div><!--/row-->
			
			<div class="row">
				<div class="medium-12 columns">
					<button type="submit" name="createContact" class="button">Send Message</button>
				</div><!--/medium12-->
			</div><!--/row-->
		</form>
	</cfoutput>
<cfelseif event.slug NEQ 'thank-you'>
	<cflocation url='/contact/thank-you/' addToken="no">
</cfif>
<!---<cfdump var="#results.cfcatch#">--->