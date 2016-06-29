/*
 * Mapping module
 **/

 define(["app/layers", "app/ui", "app/styles"], function(layers, ui, styles) {
 	return {
 		init: function(container) {
 			var mdiv = "map",
 				map = null,
 				blayer1 = new ol.layer.Tile({
		        	source: new ol.source.MapQuest({
		        		layer: 'sat'
		        	})
		        }),
		        blayer2 = new ol.layer.Tile({
		        	source: new ol.source.TileJSON({
			        	url: "http://api.tiles.mapbox.com/v3/mapbox.natural-earth-hypso-bathy.jsonp",
			        	//url: 'http://api.tiles.mapbox.com/v3/mapbox.world-black.jsonp',
			        	//url: 'http://api.tiles.mapbox.com/v3/mapbox.world-glass.jsonp',
			        	crossOrigin: "anonymous"
			        })
		        });
 				

 			if (container && typeof(container) == 'string') {
 				mdiv = container;
 			}
 			//emplty map content
 			$('#' + mdiv).html("");
 			//create map instance
 			map = new ol.Map({
		        layers: [blayer2],
		        renderer: 'canvas',
		        target: mdiv,
		        view: new ol.View({
		            center: [0, 0],
		            minZoom: 3,
		            maxzoom: 18,
		            zoom: 3
		            //zoomFactor: 1,
		            //extent: ol.proj.transform([-180, -90, 180, 90], 'EPSG:4326', 'EPSG:3857')
		        })
		    });

 			//bind click event for heatmap update
		    map.on("singleclick", function(evt) {
		    	var feat = map.forEachFeatureAtPixel(evt.pixel, function(feature, layer) {
		    		
		    	});

		    	if (feat) {
		    		ui.updateHeatmap(feat[0], feat[1]);
		    	}
		    });

		    //bind zoom event for label update
		    map.getView().on("propertychange", function(evt) {
		    	if ( evt.key == "resolution") {
		    		var res = evt.target.getResolution();

		    		if ( res > 300) {
		    			//styles.updateIpcStyle();
		    		}
		    	}
		    });

		    return map;
 		}
 	};
 });