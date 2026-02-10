// Locations Javascript that builds the map


	google.load('maps', '3', {
		other_params: 'sensor=false'
	});
	
	google.setOnLoadCallback(initialize);
	
	var markerClusterer = null;
	var map = null;
	var imageUrl = 'http://chart.apis.google.com/chart?cht=mm&chs=24x32&' +
	'chco=FFFFFF,008CFF,000000&ext=.png';

    function initialize() {
	    var center = new google.maps.LatLng(41.45,-98.87);
	    var map = new google.maps.Map(document.getElementById('map'), {
	    	zoom: 3,
			center: center,
			mapTypeId: google.maps.MapTypeId.ROADMAP
	    });
	    var markers = [];
		    for (var i = 0; i < data.count; i++) {
		    spinnerUp(i);
	    }
	    function spinnerUp() {
	        var data_mapper = data.locationstuff[i];
	        var latLng = new google.maps.LatLng(data_mapper.latitude,data_mapper.longitude);
	        var boxText = "<div style='margin-top: 8px; padding: 5px;'>";
	            boxText += data_mapper.title + "<br>" + data_mapper.address + "<br>" + data_mapper.city + ", " + data_mapper.zip;
	            boxText += "</div>";
			
			switch (data_mapper.iconSpecial) {
				case 0: var iconColorSpecial = "http://www.google.com/intl/en_us/mapfiles/ms/micons/red-dot.png";
				break;
				case 1: var iconColorSpecial = "http://www.google.com/intl/en_us/mapfiles/ms/micons/blue-dot.png";
				break;	
			}
	        
	        var marker = new google.maps.Marker({position: latLng,icon:iconColorSpecial});
	        
			var infowindow = new google.maps.InfoWindow({
				content: boxText,
				disableAutoPan: false,
				maxWidth: 0,
				pixelOffset: new google.maps.Size(0, 0),
				zIndex: null,
				closeBoxMargin: "10px 2px 2px 2px",
				closeBoxURL: "http://www.google.com/intl/en_us/mapfiles/close.gif",
				infoBoxClearance: new google.maps.Size(1, 1),
				isHidden: false,
				pane: "floatPane",
				enableEventPropagation: false
			});
	      
	        google.maps.event.addListener(marker, 'click', function() {infowindow.open(map, this);});
	        markers.push(marker);		
	    }
	        
	    // var markerCluster = new MarkerClusterer(map, markers);
    }
	google.maps.event.addDomListener(window, 'load', initialize);