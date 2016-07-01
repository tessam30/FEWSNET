/*
 * Mapping module
 **/

 define([], function() {
 	return {
 		getEQHeatlayer: function() {

 			var eqVector = new ol.layer.Heatmap({
				source: new ol.source.Vector({
					//url: "data/kml/2012_Earthquakes_Mag5.kml"
					//url: "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_month.geojson"
					url: "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_week.geojson"
					,format: new ol.format.GeoJSON({
						defaultDataProjection: 'EPSG:4326'
					})
					/*,format: new ol.format.KML({
 						extractStyles: false,
 					})*/
				})
 				,radius: 5
 			});

 			eqVector.getSource().on('addfeature', function(evt) {
 				//console.log("evt:", evt);
 				var name = evt.feature.get('mag'),
 					mag = parseFloat(name);

 				evt.feature.set('weight', mag + 5);
 			});

 			var eqRaster = new ol.layer.Tile({
 				source: new ol.source.Stamen({
 					layer: 'toner'
 				})
 			});

 			return eqVector;
 		},
 		getCountries: function() {
 			var countries = new ol.layer.Vector({
 				source: new ol.source.Vector({
 					url: "data/africa.geojson"
 					,format: new ol.format.GeoJSON()
 				})
 				,style: function() {
 					return [
 						new ol.style.Style({
 							fill: new ol.style.Fill({
 								color: 'rgba(115, 115, 115, .5)'
 							}),
 							stroke: new ol.style.Stroke({
 								color: "white",
 								width: 1
 							})
 						})
 					];
 				}
 			});

 			return countries;
 		},
 		getMarkets: function() {
 			var markets = new ol.layer.Vector({
 				source: new ol.source.Vector({
 					url: "data/markets.geojson"
 					,format: new ol.format.GeoJSON()
 				})
 				,style: function() {
 					return [
 						new ol.style.Style({
 							image: new ol.style.Circle({
 								radius: 4,
	 							fill: new ol.style.Fill({
	 								color: 'white'
	 							}),
	 							stroke: new ol.style.Stroke({
	 								color: "black",
	 								width: 1
	 							})
 							})
 						})
 					];
 				}
 			});

 			return markets;
 		},
 		getCommodities: function() {
 			//var currField = ui.getHistoryField();
 			//console.log("IPC Field: ", currField);
 			var comms = new ol.layer.Vector({
 				source: new ol.source.Vector({
 					url: "data/commodities.geojson"
 					,format: new ol.format.GeoJSON()
 				})
 				/*,style: function(feat, res) {
 					
 				}*/
 			});

 			return comms;
 		},
 		commFeats: null,
		commFeatsAttrs: null,
		marketsData: null,
 		getCommoditiesData: function(markets) {
 			var $this = this,
 				marketsData = {};

 			if (!markets || (markets && !markets.length)) {
 				return;
 			}

 			$.each(markets, function(i, m) {
 				var p = m.getProperties(),
 					mid = p["mid"];

 				if (!marketsData[mid]) {
 					marketsData[mid] = p;
 					marketsData[mid]['cmods'] = [];
 					marketsData[mid]['sels'] = {};
 				}
 			});

 			//console.log("Markets: ", marketsData[0]);

 			//get commodities data
 			$.ajax({
 				url: "data/commodities.geojson",
 				type: "GET",
 				dataType: "json",
 				success: function(data, status, xhr) {
 					//console.log("Commodities data: ", data);
 					if(!data) return;

 					var feats = data.features,
 					uCommodities = [],
 					uMonths = [],
 					uYears = [],
					fAttrs = $.map(feats, function(feat, i) {
						var attr = feat.properties,
							mid = attr["mid"],
							cmod = attr["commodity"],
							month = attr["d_month"],
							year = attr["d_year"];


						if ($.inArray(cmod, uCommodities) == -1) {
							uCommodities.push(cmod);
						}

						if (marketsData[mid]["mid"] == mid && $.inArray(cmod, marketsData[mid]['cmods']) == -1) {
							marketsData[mid]['cmods'].push(cmod);
						}

						if ($.inArray(month, uMonths) == -1) {
							uMonths.push(month);
						}

						if ($.inArray(year, uYears) == -1) {
							uYears.push(year);
						}

						if (marketsData[mid] && !marketsData[mid]["cdata"]) {
							marketsData[mid]["cdata"] = [];
						} 

						marketsData[mid]["cdata"].push(attr);

						return attr;
					});

					//console.log("Commodities: ", uCommodities);
					//console.log("Months: ", uMonths);
					//console.log("Years: ", uYears);
					//console.log("marketsData: ", marketsData[1]);

					$this.commFeats = feats;
					$this.commFeatsAttrs = fAttrs;
					$this.commodities = uCommodities;
					$this.years = uYears;
					$this.months = uMonths;
					$this.marketsData = marketsData;

					//alert the app of the data availability
					app.mapContainer.trigger("app:data:ready");
 				},
 				error: function(xhr, status, error) {
 					console.log("Commodities error: ", arguments);
 				}
 			});
 		},
 		getCommoditiesAttr: function(mid, col, com, month, year) {
 			//console.log("Price anomalies: ", arguments);


 			var $this = this,
 				currSel = com + "" + month + "" + year,
 				value = null,
 				feat = $this.marketsData[mid],
 				lcmods = feat["cmods"],
 				cmods = feat["cdata"];

 			//console.log("Commodities: ", cmods);

 			$.each(cmods, function(i, cmod) {
 				var c = cmod["commodity"],
 					m = cmod["d_month"],
 					y = cmod["d_year"],
 					v = cmod[col];

 				if (com == c && m == month && y == year) {
 					//value = $.isNumeric(v) ? v : 0;
 					value = v;
 					$this.marketsData[mid]["sels"][currSel] = v;
 					//console.log("PA: ", mid, c, m, y, v);
 					return;
 				}
 			});

 			//make sure the market has the specified commodity
 			if (!value && $.inArray(com, lcmods) == -1) {
 				value = "none";
 			}
 			
 			return value;
 		}
 	};
 });