//  ---------------------------------------------
//	:: External Link Tracking through RegX
//	---------------------------------------------
	$(document).ready(function() {
		var filetypes = /\.(zip|exe|dmg|pdf|doc.*|xls.*|ppt.*|mp3|txt|rar|wma|mov|avi|wmv|flv|wav)$/i;
		var baseHref = '';
		if (jQuery('base').attr('href') != undefined) baseHref = jQuery('base').attr('href');
		var hrefRedirect = '';
	
	    $('body a').click(function(event){
	    	var el = $(this);
		    var track = true;
		    var href = (typeof(el.attr('href')) != 'undefined' ) ? el.attr('href') : '';
		    var isThisDomain = href.match(document.domain.split('.').reverse()[1] + '.' + document.domain.split('.').reverse()[0]);
		    if (!href.match(/^javascript:/i)) {
		        var elEv = []; elEv.value=0, elEv.non_i=false;
		        // Track Mail Clicks
		        if (href.match(/^mailto\:/i)) {
		            elEv.category = 'email';
		            elEv.action = 'click';
		            elEv.label = href.replace(/^mailto\:/i, '');
		            elEv.loc = href;
		        }
		        // Check File Downloads
		        else if (href.match(filetypes)) {
		            var extension = (/[.]/.exec(href)) ? /[^.]+$/.exec(href) : undefined;
		            elEv.category = 'download';
		            elEv.action = 'click-' + extension[0];
		            elEv.label = href.replace(/ /g,'-');
		            elEv.loc = baseHref + href;
		        }
		        // Check External Link Clicks
		        else if (href.match(/^https?\:/i) && !isThisDomain) {
		            elEv.category = 'external';
		            elEv.action = 'click';
		            elEv.label = href.replace(/^https?\:\/\//i, '');
		            elEv.non_i = true;
		            elEv.loc = href;
		        }
		        // Check Telephone Clicks
		        else if (href.match(/^tel\:/i)) {
		            elEv.category = 'telephone';
		            elEv.action = 'click';
		            elEv.label = href.replace(/^tel\:/i, '');
		            elEv.loc = href;
		        }
		        else track = false;
	
		        if (track) {
		            var ret = true;
		            if((elEv.category == 'external' || elEv.category == 'download') && (el.attr('target') == undefined || el.attr('target').toLowerCase() != '_blank') ) {
		                hrefRedirect = elEv.loc;
		                ga('send','event', elEv.category.toLowerCase(),elEv.action.toLowerCase(),elEv.label.toLowerCase(),elEv.value,{
		                    'nonInteraction': elEv.non_i ,
		                    //'hitCallback':gaHitCallbackHandler
		                    'hitCallback': function() {
								window.location.href = hrefRedirect;
							}
		                });
		                ret = false;
		            }
		            else {
		                ga('send','event', elEv.category.toLowerCase(),elEv.action.toLowerCase(),elEv.label.toLowerCase(),elEv.value,{
		                    'nonInteraction': elEv.non_i
		                });
		            }
		            return ret;
		        }
		    }
	    });
	});


//  ---------------------------------------------
//	:: Firefox Debugging
//	---------------------------------------------
	// (Possibly archaic) Firebox code from before Dylan started working here
	if (!window.console || !console.firebug){
	    var names = ["log", "debug", "info", "warn", "error", "assert", "dir", "dirxml",
	    "group", "groupEnd", "time", "timeEnd", "count", "trace", "profile", "profileEnd"];
	    window.console = {};
	    for (var i = 0; i < names.length; ++i)
	        window.console[names[i]] = function() {}
	}