if (!window.console || !console.firebug)
{
    var names = ["log", "debug", "info", "warn", "error", "assert", "dir", "dirxml",
    "group", "groupEnd", "time", "timeEnd", "count", "trace", "profile", "profileEnd"];

    window.console = {};
    for (var i = 0; i < names.length; ++i)
        window.console[names[i]] = function() {}
}

$(document).ready(function(){
	$('ul.pagelist ul ul ul ul').hide(0);
	$('ul.pagelist ul ul ul').hide(0);
	$('ul.pagelist ul ul').hide(0);
	$('ul.pagelist ul').hide(0);
	$('a.trigger').click(function(){
		var $this = $(this);
		$this.closest("table").siblings("ul").toggle();
		h = $this.html();
		if(h == '+') {
			$this.html('-');
		} else {
			$this.html("+");
		}
		return false;
	});
	$("select#siteID").change(function(){
		var v = $(this).val();
		window.location = "index.cfm?action=switch_site&id=" + v;
	});
	$('.customfields').bind('click', function(evt) {
			var $target = $(evt.target);
			if( $target.is("a.removeCustomField")) {
					evt.preventDefault();
					$target.closest("div").remove();
			}
											  });
	$('a.addCustomField').bind('click', function(evt) {
			evt.preventDefault();
			$('<div>' + ($('li.customfields div').length + 1) + ': <INPUT TYPE="TEXT" NAME="customfield" VALUE="">	<INPUT TYPE="TEXT" NAME="customvalue" VALUE=""> <a href="##" class="removeCustomField">Clear</a>							</div>')
				.appendTo('li.customfields');
											  });
	
	
	$('.permissions').bind('click', function(evt) {
			var $target = $(evt.target);
			if( $target.is("a.removePermissionField")) {
					evt.preventDefault();
					$target.closest("div").remove();
			}
											  });
	$('a.addPermissionField').bind('click', function(evt) {
			evt.preventDefault();
			$('<div>' + ($('li.permissions div').length + 1) + ': <select name="rw"><option value="r">To View this page:</option></select> <select name="limitMethod"><option value="require-group">Require User to be a member of this group:</option><option value="require-user">Require This Specific User:</option><option value="require-valid-user">Require viewer to be logged in</option></select> <input type="text" NAME="limitArg" > <a href="##" class="removeCustomField">Clear</a></div>')
				.appendTo('li.permissions');
											  });
	
	
	$('fieldset.collapse legend').click(function(){
		$(this).siblings().slideToggle();
		$(this).parent().toggleClass('open');
	}).siblings().hide();
// http://www.erichynds.com/jquery/a-new-and-improved-jquery-idle-timeout-plugin/
	timeoutOverlay = $("#timeoutDialog").overlay({ 
	 
		expose: { 
			color: '#002D4C', 
			loadSpeed: 200, 
			opacity: 0.5 
		}, 
		// disable this for modal dialog-type of overlays 
		closeOnClick: true, 
		api: true 
	});
	$('input[name=redirect]').change(function() {
		   if($(this).val() == '1') {
			   $('div.contentpage').hide();
			   $('div.redirectpage').show();
		   } else {
			   $('div.contentpage').show();
			   $('div.redirectpage').hide();
		   }
	}).filter(':checked').change();
	
	$.idleTimeout('#timeoutDialog', '#timeoutDialog button:first', {
		idleAfter: 115*60, // user is considered idle after 15 minutes of no movement
		pollingInterval: 10*60, // a request to keepalive.php (below) will be sent to the server every 10 minutes
		warningLength: 45,
		keepAliveURL: '/managementcenter/keepalive.cfm',
		serverResponseEquals: 'OK', // the response from keepalive.php must equal the text "OK"
		onTimeout: function(){
			// redirect the user when they timeout.
			window.location = "/managementcenter/index.cfm?event=logout&msg=timeout";
		},
		onIdle: function(){
			// show the dialog when the user idles
			timeoutOverlay.load();
		},
		onCountdown: function(counter){
	 
			// update the counter span inside the dialog during each second of the countdown
			$("#dialog-countdown").html(counter);
		},
		onResume: function(){
	 
			timeoutOverlay.close();
		}
	});
	$("#timeoutDialog button:eq(1)").click(function(){ $.idleTimeout.options.onTimeout.call(this); });
	$('#frmnews').validator({errorclass:'error',message:'<label />',position:'bottom center'});
	
	$('.date-pick').datePicker();
	$('.date-pick[name=publishDate]').each( function() {
													 if($(this).val() == "") $(this).val(new Date().asString());
													 });
	$('.capfloat a').click(function(evt) {
			evt.preventDefault();
			var $this = $(this);
			var checked = $this.hasClass('select');
			$this.parent().find('input').each(function(){
										this.checked = checked;
										   });
	});
	var trigger = $('<a href="#" class="expand">View</a>');
	$('.logs pre').hide().before(trigger);
	$('.logs').click(function(evt){
		var $tgt = $(evt.target);
		if($tgt.hasClass('expand')) {
			evt.preventDefault();
			$tgt.siblings('pre').slideToggle();
		}
		if($tgt.is('pre')) {
			$tgt.slideUp();
		}
	});
	
	$(document).ready(function(e) {
	$(".hideit").css("display","none");
	$(".hideitb").css("display","none");
		$(".openClose").click(function() {
			if ($(".hideit").css('display') == 'none') {
				$(".hideit").css("display","block"); 
			} else {
				$(".hideit").css("display","none"); 
			}
		});

		$(".openCloseb").click(function() {
			if ($(".hideitb").css('display') == 'none') {
				$(".hideitb").css("display","block"); 
			} else {
				$(".hideitb").css("display","none"); 
			}
		});					
	});
	
});

var timeoutOverlay;

function showtip(tip){
document.tool.tip.value=tip
}

function NewWindow(mypage, myname, w, h, scroll) {
var winl = (screen.width - w) / 2;
var wint = (screen.height - h) / 2;
winprops = 'height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars='+scroll+',resizable'
win = window.open(mypage, myname, winprops)
if (parseInt(navigator.appVersion) >= 4) { win.window.focus(); }
}



var start=new Date();
start=Date.parse(start)/1000;
var counts=7200;
function CountDown(){
	var now=new Date();
	now=Date.parse(now)/1000;
	var x=parseInt(counts-(now-start),10);
	var hours = Math.floor(x/3600); 
	var minutes = Math.floor((x-(hours*3600))/60); 
	var seconds = x-((hours*3600)+(minutes*60));
	minutes=(minutes <= 9)?'0' + minutes:minutes;
	seconds=(seconds <= 9)?'0' + seconds:seconds;
	
	if(document.getElementById('clock').innerHTML != undefined ){document.getElementById('clock').innerHTML = hours  + ':' + minutes + ':' + seconds ;}

	if(x>0){
		timerID=setTimeout("CountDown()", 100)
	}else{
	
		location.href="/managementcenter/index.cfm?event=logout&msg=timeout"
		
	}
}

if (top.location != self.location) {
top.location.replace(self.location)
}
//End -->

