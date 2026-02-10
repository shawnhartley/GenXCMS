<cfscript>
if (NOT StructKeyExists(form, 'submitNews') ) {
	getpagecontext().getresponse().setstatus(405, 'Method Not Allowed');
}
try {
	result = new cfcs.submittedNews().store(argumentcollection = form);
} catch (Any e) {
	result = false;
	WriteDump(var = e, abort = true);
}
if(result) {
	getpagecontext().getresponse().setstatus(202, 'Accepted');
} else {
	getpagecontext().getresponse().setstatus(405, 'Bad Request');
}
</cfscript>