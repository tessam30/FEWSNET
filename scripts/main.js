//module config
require.config({
	baseUrl: "scripts/libs",
	paths: {
		app: "../app",
		data: "../../data"
	}
});

//global app object
var app = {};
//start the application
require(["app/ui", "app/mapping", "app/layers"], 
	function(ui, mapping, layers) {

	//global app
	app = app ? app : {};

	if (ui.title && ui.title != "") {
		$("#app-title").text(ui.title);
	}

	//bind data ready event to map
	var mapCont = $("#map");
	ui.mapContainer = mapCont;
	app.mapContainer = mapCont;
	app.mapContainer.on("app:data:ready", function(evt) {
		ui.displayInitialData(evt);
	});

	//initiate the map instance
	app.map = mapping.init();
	//build layers
	var heatmap = layers.getEQHeatlayer(),
		countries = layers.getCountries(),
		markets = layers.getMarkets(),
		commodities = layers.getCommodities();

	app.markets = markets;
	app.countries = countries;

	app.map.addLayer(countries);
	app.map.addLayer(markets);
	//app.map.addLayer(commodities);

	countries.getSource().on("change", function(evt) {
		var cExt = countries.getSource().getExtent();
		app.map.getView().fit(cExt, app.map.getSize());
		app.countries = countries
		app.markets = markets;
		//bind all ui events
		ui.bindEvents();

		setTimeout(function() {
 			//$("#ipc-month").trigger("change");
 		},2000);
	});

	var m = markets.getSource().on("change", function(evt) {
		//console.log("Markets Layer: ", evt);
		//unbind the change event
		app.map.unByKey(m);
		//get commodities data
		var mkts = evt.target.getFeatures();
		layers.getCommoditiesData(mkts);
	});

	var com = commodities.getSource().on("change", function(evt) {
		console.log("Commodities Layer: ", evt);
		app.map.unByKey(c);
	});

	//mouse move event
	app.map.on("pointermove", function(evt) {
		if (evt.dragging) {
			if (app.info) {
				app.info.tooltip("hide");
			}

			return;
		}

		var pos = app.map.getEventPixel(evt.originalEvent);

		ui.displayMarketInfo(pos);
	});
});

