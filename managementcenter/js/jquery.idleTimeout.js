/*
 * jQuery idleTimer plugin
 * version 0.8.092209
 * by Paul Irish. 
 *   http://github.com/paulirish/yui-misc/tree/
 * MIT license
 
 * adapted from YUI idle timer by nzakas:
 *   http://github.com/nzakas/yui-misc/
 
 
 * Copyright (c) 2009 Nicholas C. Zakas
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

(function($){

$.idleTimer = function f(newTimeout){

    //$.idleTimer.tId = -1     //timeout ID

    var idle    = false,        //indicates if the user is idle
        enabled = true,        //indicates if the idle timer is enabled
        timeout = 30000,        //the amount of time (ms) before the user is considered idle
        events  = 'mousemove keydown DOMMouseScroll mousewheel mousedown', // activity is one of these events
      //f.olddate = undefined, // olddate used for getElapsedTime. stored on the function
        
    /* (intentionally not documented)
     * Toggles the idle state and fires an appropriate event.
     * @return {void}
     */
    toggleIdleState = function(){
    
        //toggle the state
        idle = !idle;
        
        // reset timeout counter
        f.olddate = +new Date;
        
        //fire appropriate event
        $(document).trigger(  $.data(document,'idleTimer', idle ? "idle" : "active" )  + '.idleTimer');            
    },

    /**
     * Stops the idle timer. This removes appropriate event handlers
     * and cancels any pending timeouts.
     * @return {void}
     * @method stop
     * @static
     */         
    stop = function(){
    
        //set to disabled
        enabled = false;
        
        //clear any pending timeouts
        clearTimeout($.idleTimer.tId);
        
        //detach the event handlers
        $(document).unbind('.idleTimer');
    },
    
    
    /* (intentionally not documented)
     * Handles a user event indicating that the user isn't idle.
     * @param {Event} event A DOM2-normalized event object.
     * @return {void}
     */
    handleUserEvent = function(){
    
        //clear any existing timeout
        clearTimeout($.idleTimer.tId);
        
        
        
        //if the idle timer is enabled
        if (enabled){
        
          
            //if it's idle, that means the user is no longer idle
            if (idle){
                toggleIdleState();           
            } 
        
            //set a new timeout
            $.idleTimer.tId = setTimeout(toggleIdleState, timeout);
            
        }    
     };
    
      
    /**
     * Starts the idle timer. This adds appropriate event handlers
     * and starts the first timeout.
     * @param {int} newTimeout (Optional) A new value for the timeout period in ms.
     * @return {void}
     * @method $.idleTimer
     * @static
     */ 
    
    
    f.olddate = f.olddate || +new Date;
    
    //assign a new timeout if necessary
    if (typeof newTimeout == "number"){
        timeout = newTimeout;
    } else if (newTimeout === 'destroy') {
        stop();
        return this;  
    } else if (newTimeout === 'getElapsedTime'){
        return (+new Date) - f.olddate;
    }
    
    //assign appropriate event handlers
    $(document).bind($.trim((events+' ').split(' ').join('.idleTimer ')),handleUserEvent);
    
    
    //set a timeout to toggle state
    $.idleTimer.tId = setTimeout(toggleIdleState, timeout);
    
    // assume the user is active for the first x seconds.
    $.data(document,'idleTimer',"active");
      
    

    
}; // end of $.idleTimer()

    

})(jQuery);


(function($){
	
	$.idleTimeout = function(element, resume, options){
		
		// overwrite $.idleTimeout.options with the results of $.extend.  Allows you to write and a callback then call it from 
		// from a jQuery UI button or something
		options = $.idleTimeout.options = $.extend({}, $.idleTimeout.options, options);
		
		var IdleTimeout = {
			init: function(){
				var self = this;
				
				this.warning = $(element);
				this.resume = $(resume);
				this.countdownOpen = false;
				this.failedRequests = options.failedRequests;
				this._startTimer();
				
				// start the idle timer
				$.idleTimer(options.idleAfter * 1000);
				
				// once the user becomes idle
				$(document).bind("idle.idleTimer", function(){
					
					// if the user is idle and a countdown isn't already running
					if( $.data(document, 'idleTimer') === 'idle' && !self.countdownOpen ){
						self._stopTimer();
						self.countdownOpen = true;
						self._idle();
					}
				});
				
				// bind continue link
				this.resume.bind("click", function(e){
					e.preventDefault();
					
					window.clearInterval(self.countdown); // stop the countdown
					self.countdownOpen = false; // stop countdown
					self._startTimer(); // start up the timer again
					options.onResume.call( self.warning ); // call the resume callback
				});
			},
			
			_idle: function(){
				var self = this,
					warning = this.warning[0],
					counter = options.warningLength;
				
				// fire the onIdle function
				options.onIdle.call(warning);
				
				// set inital value in the countdown placeholder
				options.onCountdown.call(warning, counter);
				
				// create a timer that runs every second
				this.countdown = window.setInterval(function(){
					counter -= 1;
					
					if(counter === 0){
						window.clearInterval(self.countdown);
						options.onTimeout.call(warning);
					} else {
						options.onCountdown.call(warning, counter);
					}
					
				}, 1000);
			},
			
			_startTimer: function(){
				var self = this;
				
				this.timer = window.setInterval(function(){
					self._keepAlive();
				}, options.pollingInterval * 1000);
			},
				
			_stopTimer: function(){
				// reset the failed requests counter
				this.failedRequests = options.failedRequests;
				
				// stop the timer
				window.clearInterval(this.timer);
			},
			
			_keepAlive: function(){
				var self = this;
				
				// if too many requests failed, abort
				if(!this.failedRequests){
					this._stopTimer();
					options.onAbort.call( this.element );
					return;
				}
				
				$.ajax({
					timeout: options.AJAXTimeout,
					url: options.keepAliveURL,
					error: function(){
						self.failedRequests--;
					},
					success: function(response){
					
						// the response from the server must equal OK
						if($.trim(response) !== options.serverResponseEquals){
							self.failedRequests--;
						}
					}
				});
			}
		};
		
		// run this thang
		IdleTimeout.init();
	};
	
	$.idleTimeout.options = {
		// number of seconds after user is idle to show the warning
		warningLength: 30,
		
		// url to call to keep the session alive while the user is active
		keepAliveURL: "",
		
		// the response from keepAliveURL must equal this text:
		serverResponseEquals: "OK",
		
		// user is considered idle after this many seconds.  10 minutes default
		idleAfter: 600,
		
		// a polling request will be sent to the server every X seconds
		pollingInterval: 60,
		
		// number of failed polling requests until we abort this script
		failedRequests: 5,
		
		// the $.ajax timeout in MILLISECONDS! 
		AJAXTimeout: 250,
		
		/*
			Callbacks
			"this" refers to the #idletimthis.failedRequests = options.failedRequests;eout element.
		*/
		// callback to fire when the session times out
		onTimeout: function(){},
		
		// fires when the user becomes idle
		onIdle: function(){},
		
		// fires during each second of warningLength
		onCountdown: function(){},
		
		// fires when the user resumes the session
		onResume: function(){},
		
		// callback to fire when the script is aborted due to too many failed requests
		onAbort: function(){}
	};
	
})(jQuery);
