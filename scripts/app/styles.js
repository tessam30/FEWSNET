/*
 * Styles module
 *
 **/

define(["app/layers"], function(layers) {
 	return {
 		distritsFields: [],
 		ipcColors: {
 			"1": "#DEF7DE",
			"2": "#FFE718",
			"3": "#E77B00",
			"4": "#CE0000",
			"5": "#630000",
			"66": "blue",
			"88": "green",
			"99": "#888"
 		},
 		labelFields: ["OBJECTID", "LZCODE", "LZNAME", "Admin2_1"],
 		getIpcStyle: function(feat, res, field) {
 			var $this = this,
 				ipc = feat.get(field),
 				field = $this.labelFields[1],
 				label = feat.get(field),
 				dColor = "#888888";
				color = dColor;

			if (ipc) {
				color = this.ipcColors[ipc];
			} 

			label = "";

			return [
				new ol.style.Style({
					fill: new ol.style.Fill({
						color: color
					}),
					stroke: new ol.style.Stroke({
						color: "black",
						width: 1
					})
					,text: new ol.style.Text({
						font: "bold 12px Verdana",
						text: label
					})
				})
			];
 		},
 		updateIpcStyle: function(field) {
 			var $this = this;

 			if (!app.ipcLayer) {
 				return;
 			}
 				
 			var layer = app.ipcLayer,
 				lSource = layer.getSource();

 			if (!lSource) {
 				return;
 			}

 			var feats = lSource.getFeatures(),
 				ipcs = [],
 				dColor = "#888",
 				res = app.map.getView().getResolution();

 			$this.ipcField = field ? field : $this.ipcField;

 			//console.log("getResolution:", res);

 			$.each(feats, function(i, feat) {
 				var ipc = feat.get($this.ipcField),
 					fields = ["OBJECTID", "LZCODE", "LZNAME", "Admin2_1"],
 					label = feat.get(fields[1]),
 					color = ipc ? $this.ipcColors[ipc] : dColor,
 					style = feat.getStyle();

 				if (res > 300) {
 					label = "";
 				}

 				var	newStyle = new ol.style.Style({
					fill: new ol.style.Fill({
						color: color
					}),
					stroke: new ol.style.Stroke({
						color: "black",
						width: 1
					})
					,text: new ol.style.Text({
						font: "bold 12px Verdana",
						text: label
					})
				});

 				feat.setStyle(newStyle);

 				var v = ipc ? ipc : 99;
 				ipcs.push(v);
 			});

 			return ipcs;
 		},
 		getAllIpcsData: function(fields, admin) {
 			var $this = this,
 				layer = app.ipcLayer,
 				lSource = layer.getSource(),
 				feats = lSource.getFeatures(),
 				areaLabels = ["OBJECTID", "LZCODE", "LZNAME"],
 				area = admin && admin != "" ? admin : 1,
 				ipcsData = [];

 			$.each(feats, function(i, feat) {
 				var label = feat.get(areaLabels[1]);

 				if (label == area) {

	 				$.each(fields, function(j, field) {
	 					var ipc = feat.get(field),
	 						adm = feat.get("Admin2_1"),
	 						my = field.split("_"),
	 						data = {
	 							"month": my[0],
	 							"year": my[1],
	 							"name": adm ? adm : "Unknown",
	 							"ipc": ipc ? ipc : 99
	 						};

	 					ipcsData.push(data);
	 				});
	 			}
 			});

 			//console.log("IPCs:", feats.length, ipcsData.length);
 			return ipcsData;
 		},
 		updateMarketStyles: function(com, month, year) {
 			//console.log("Layers: ", layers);
 			//console.log("Styles: ", com, month, year);

 			var $this = this,
 				com = com,
 				month = month,
 				year = year,
 				clyrs = app.countries,
 				countries = clyrs.getSource().getFeatures(),
 				mlyrs = app.markets,
 				markets = mlyrs.getSource().getFeatures(),
 				col = "price_anomaly",
 				mcolor = "white",
 				mcolor_r = "#ff4d4d",
 				mcolor_r2 = 'rgb(255, 77, 77)',
 				mcolor_r3 = 'rgba(255, 77, 77, .6)',
 				mcolor_b = "#80aaff",
 				mcolor_b2 = 'rgb(128, 170, 255)',
 				mcolor_b3 = 'rgba(128, 170, 255, .6)',
 				mcolor_w = "#ffffff",
 				mcolor_w2 = 'rgb(255, 255, 255)',
 				mcolor_w3 = 'rgba(242, 242, 242, .6)',
 				mcolor_bk = "#000000",
 				mcolor_bk2 = 'rgb(0, 0, 0)',
 				mcolor_bk3 = 'rgba(0, 0, 0, .6)',
 				mcolor_bk = "#000000",
 				mcolor_bk2 = 'rgb(0, 0, 0)',
 				mcolor_bk3 = 'rgba(0, 0, 0, .6)',
 				mcolor_g = "#d9d9d9",
 				mcolor_g2 = 'rgb(217, 217, 217)',
 				mcolor_g3 = 'rgba(217, 217, 217, .7)',
 				mcolor_n = 'rgba(255, 255, 255, 0)'
 				dsize = 4;

 			/*var style = new ol.style.Style({
				image: new ol.style.Circle({
					radius: 4,
					fill: new ol.style.Fill({
						color: mcolor
					}),
					stroke: new ol.style.Stroke({
						color: "black",
						width: 1
					})
				})
			});*/

			//update market styles
			$.each(markets, function(j, m){
				var attr = m.getProperties(),
					mid = attr["mid"],
					name = attr["market_loc"],
					mdata = layers.marketsData[mid],
					mCmods = mdata["cmods"],
					nCmods = mCmods.length,
					size = dsize + nCmods;

				//get price anomaly
				var pa = null;

				if (!com || !month || !year) {
					com = app.currCmod;
					month = app.currMonth;
					year = app.currYear;
				}

				pa = layers.getCommoditiesAttr(mid, col, com, month, year);

				//console.log("Price anomaly: ", pa);

				if (pa) {

					size = pa;

					mcolor = mcolor_w3;

					if (size.toUpperCase() == "NA") {
						size = 4;
						mcolor = mcolor_n;
					}
					else if (pa == "none") {
						size = 0;
						mcolor = mcolor_n;
					}
					else if (size < 0) {
						size = size * -1;
						mcolor = mcolor_b3;

						if (size < 4) {
							size = 4;
						} 
						else if (size > 15) {
							size = 15;
						}
					}
					else if (size > 0) {
						mcolor = mcolor_r3;

						if (size < 4) {
							size = 4;
						}
						else if (size > 15) {
							size = 15;
						}
					} 
					else if (size == 0) {
						size = 4;
						mcolor = mcolor_w3;
					}
				}
				else {
					size = dsize;
					mcolor = mcolor_w3;

					//console.log("No price anomaly: ", name, pa, size, mcolor);
				}
				
				var style = new ol.style.Style({
					image: new ol.style.Circle({
						radius: size,
						fill: new ol.style.Fill({
							color: mcolor
						}),
						stroke: new ol.style.Stroke({
							color: mcolor_g3,
							width: 2
						})
					})
				});

				m.setStyle(style);
			});
 		}
 	};
});