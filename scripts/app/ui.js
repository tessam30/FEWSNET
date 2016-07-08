/*
 *	User Interface
 **/

 define(["app/layers", "app/styles"], function(layers, styles) {
 	return {
 		title: "Africa - Commodities Price Anomalies",
 		currCmod: "",
 		currMonth: "",
 		month: "",
 		months: [],
 		lmonths: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
 		includeMonths: true,
 		currYear: "",
 		year: "",
 		years: [],
 		includeYears: false,
 		hisSpeed: 1000,
 		bindEvents: function() {
 			var $this = this,
 				info = $("#map-info"),
 				pAbout = $("#page-about"),
 				pStats = $("#page-stats"),
 				pLegend = $("#page-legend"),
 				pOptions = $("#page-options"),
 				lCountries = $("#lyr-countries"),
 				lMarkets = $("#lyr-markets"),
 				hisSpeed = $("#his-speed"),
 				history = $("#his-update"),
 				hisBarHeader = $("#his-bar-header"),
 				hisBar = $("#his-bar");

 			$this.hisBarHeader = hisBarHeader;
 			$this.hisBar = hisBar;

 			//map tooltip
 			info.tooltip({
 				animation: false,
 				trigger: 'manual'
 				,html: true
 			});

 			$this.info = info;

 			hisSpeed.slider({
 				value: 0,
 				formater: function(value) {
 					var v = value + "x";
 					return v;
 				}
 			})
 			.on("slide", function(evt) {
 				var speed = $(evt.target).val(),
 					s = 1000 / speed;
 				
 				$this.hisSpeed = s;
 			});

 			/*history.slider({
 				value: 2005,
 				ticks: [2002, 2003, 2004, 2005],
 				ticks_labels: ['2002', '2003', '2004', '2005']
 				,ticks_snap_bound: 30
 				,tooltip: 'always'
 				,formater: function(value) {
 					var v = value;
 					return v;
 				}
 			})
 			.on("slide", function(evt) {
 				
 			});*/

 			/*history.ionRangeSlider({
 				type: "single"
 				//,values: ['2002', '2003', '2004', '2005']
			    ,min: 0
			    ,max: 4
			    ,from: 0
			    //,to: 3
			    ,grid: true
 			});*/

 			$this.history = history;

 			pStats.click(this.toggleGraphs);
 			pLegend.click(this.toggleLegend);
 			pOptions.click(this.togglePanel);

 			//layers change events
 			lCountries.change(function(evt) {
 				if (!app.countries) return;

 				var vis = $(evt.target).prop("checked");

 				if (vis) {
 					app.countries.setVisible(true);
 				} 
 				else {
 					app.countries.setVisible(false);
 				}
 			});

 			lMarkets.change(function(evt) {
 				if (!app.markets) return;

 				var vis = $(evt.target).prop("checked");

 				if (vis) {
 					app.markets.setVisible(true);
 				} 
 				else {
 					app.markets.setVisible(false);
 				}
 			});

 			//Change events for the cmod, month and year
 			var comms = $("#comms"),
 				month = $("#price-month"),
 				year = $("#price-year");

 			comms.on("change", function(evt) {
 				var v = $(evt.target).val(),
 					m = $this.currMonth,
 					y = $this.currYear;

 				if (v && v != "") {
 					$this.currCmod = v;
 					app.currCmod = $this.currCmod;
 					styles.updateMarketStyles(v, m, y);
 				}
 			});

 			month.on("change", function(evt) {
 				var v = $(evt.target).val(),
 					c = $this.currCmod,
 					y = $this.currYear;

 				if (v && v != "") {
 					$this.currMonth = v;
 					app.currMonth = $this.currMonth;
 					styles.updateMarketStyles(c, v, y);
 				}
 			});

 			year.on("change", function(evt) {
 				var v = $(evt.target).val(),
 					c = $this.currCmod,
 					m = $this.currMonth;

 				if (v && v != "") {
 					$this.currYear = v;
 					app.currYear = $this.currYear;
 					styles.updateMarketStyles(c, m, v);
 				}
 			});

 			$this.commsEl = comms;
 			$this.monthsEl = month;
 			$this.yearsEl = year;
 				
 			$this.month = month.val();
 			$this.months = $.map(month.find("option"), function(opt, i) {
 				return $(opt).val();
 			});

 			$this.year = year.val();
 			$this.years = $.map(year.find("option"), function(opt, i) {
 				return $(opt).val();
 			});

 			//history options
 			var months = $("#his-months"),
 				years = $("#his-years");

			$this.includeMonths = months.is(":checked");
			$this.includeYears = years.is(":checked");

 			//history options change
 			months.change(function(evt) {
 				$this.includeMonths = $(evt.target).is(":checked");
 				$this.updateHistorySlider();
 			});

 			years.change(function(evt) {
 				$this.includeYears = $(evt.target).is(":checked");
 				$this.updateHistorySlider();
 			});

 			//history animation
 			var hisPlay = $("#his-play"),
 				hisBack = $("#his-back"),
 				hisNext = $("#his-next");

 			$this.hisStatus = hisPlay.data("status");

 			//bind click events on history buttons
 			hisPlay.click(function(evt) {
 				var status = hisPlay.data('status');

 				if (status == "stop") {
 					$this.hisStatus = "play";
 					hisPlay.data('status', $this.hisStatus);
 					hisPlay.text("STOP");
 				}
 				else {
 					$this.hisStatus = "stop";
 					hisPlay.data('status', $this.hisStatus);
 					hisPlay.text("PLAY");
 					//clear timeout
	 				clearTimeout($this.play);
 					
 					return;
 				}

 				var currTime = $this.currMonth + "_" + $this.currYear,
 					m = $this.includeMonths,
 					y = $this.includeYears,
 					mPos = $this.months.indexOf(parseInt($this.currMonth)),
 					mLen = $this.months.length,
 					yPos = $this.years.indexOf(parseInt($this.currYear)),
 					yLen = $this.years.length,
 					hisTimes = [],
 					idx = 0;
 					len = 0;

 				var prevTime = "",
 					prevMonth = "",
 					prevMpos = mPos,
 					prevYear = "",
 					prevYpos = yPos;

 				var mths = layers.reorderList($this.currMonth, $this.months),
 					yrs = layers.reorderList($this.currYear, $this.years);

 				//create a combination of months and/or years
 				if (m && !y) {

 					$.each(mths, function(i, mth) {
 						var d = mth + "_" + $this.currYear;
 						hisTimes.push(d);
	 				});
 				}
 				else if (!m && y) {
 					$.each(yrs, function(j, yr) {
 						var d = $this.currMonth + "_" + yr;
 						hisTimes.push(d);
 					});
 				}
 				else if (m && y) {
	 				$.each(yrs, function(i, yr) {
	 					$.each(mths, function(j, mth) {
	 						var d = mth + "_" + yr;
	 						hisTimes.push(d);
	 					});
	 				});
	 			}
 				//get the length of history times
 				len = hisTimes.length;
 				console.log("History steps: ", len, hisTimes);
 				//Definne a playback functioin
 				var playHistory = function() {
					var f = hisTimes[idx],
						m = f.split("_")[0],
						y = f.split("_")[1];

					month.val(m);
	 				$this.currMonth = m;

	 				year.val(y);
	 				$this.currYear = y;

	 				month.trigger("change");
					
					idx++;

					$this.play = setTimeout(function() {

						if (idx <= len - 1 && $this.hisStatus == "play") {
							playHistory();

						} else {
	 						//idx = 0;
	 						$this.hisStatus = "stop";
	 						hisPlay.data('status', $this.hisStatus);
	 						hisPlay.text("PLAY");
	 						//clear timeout
	 						clearTimeout($this.play);
	 					}

					}, $this.hisSpeed);
 				}
 				//activate playback	
 				if ($this.hisStatus == "play") {
 					playHistory();
 				}
 			});
 			//move backward
 			hisBack.click(function(evt) {
 				var currTime = $this.currMonth + "_" + $this.currYear,
 					m = $this.includeMonths,
 					y = $this.includeYears,
 					mPos = $this.months.indexOf(parseInt($this.currMonth)),
 					mLen = $this.months.length,
 					yPos = $this.years.indexOf(parseInt($this.currYear)),
 					yLen = $this.years.length;

 				var prevTime = "",
 					prevMonth = "",
 					prevMpos = mPos,
 					prevYear = "",
 					prevYpos = yPos;

 				if( m && !y) {

	 				if (mPos == 0) {
	 					prevMpos = mLen - 1;
	 				} else {
	 					prevMpos = mPos - 1;
	 				}

	 				prevMonth = $this.months[prevMpos];
	 				month.val(prevMonth);
	 				$this.currMonth = prevMonth;

	 				month.trigger("change");
	 			}
	 			else if(!m && y) {

	 				if (yPos == 0) {
	 					prevYpos = yLen - 1;
	 				} else {
	 					prevYpos = yPos - 1;
	 				}

	 				prevYear = $this.years[prevYpos];
	 				year.val(prevYear);
	 				$this.currYear = prevYear;

	 				year.trigger("change");
	 			}
	 			else if (m && y) {

	 				if (mPos == 0) {
	 					prevMpos = mLen - 1;

	 					if (yPos == 0) {
	 						prevYpos = yLen - 1;
	 					} else {
	 						prevYpos = yPos - 1;
	 					}

	 				} else {
	 					prevMpos = mPos - 1;

	 					if (yPos == 0) {
	 						prevYpos = yLen - 1;
	 					}
	 				}
	 				//set previous month
	 				prevMonth = $this.months[prevMpos];
	 				month.val(prevMonth);
	 				$this.currMonth = prevMonth;
	 				//set previous year
	 				prevYear = $this.years[prevYpos];
	 				year.val(prevYear);
	 				$this.currYear = prevYear;
	 				//trigger change event
	 				month.trigger("change");
	 			}
 			});
 			// move forward
 			hisNext.click(function(evt) {
 				var currTime = $this.currMonth + "_" + $this.currYear,
 					m = $this.includeMonths,
 					y = $this.includeYears,
 					mPos = $this.months.indexOf(parseInt($this.currMonth)),
 					mLen = $this.months.length,
 					yPos = $this.years.indexOf(parseInt($this.currYear)),
 					yLen = $this.years.length;

 				var prevTime = "",
 					prevMonth = "",
 					prevMpos = mPos,
 					prevYear = "",
 					prevYpos = yPos;

 				if( m && !y) {
	 				if (mPos == mLen - 1) {
	 					prevMpos = 0;
	 				} else {
	 					prevMpos = mPos + 1;
	 				}

	 				prevMonth = $this.months[prevMpos];
	 				month.val(prevMonth);
	 				$this.currMonth = prevMonth;

	 				month.trigger("change");
	 			}
	 			else if(!m && y) {
	 				if (yPos == yLen - 1) {
	 					prevYpos = 0;
	 				} else {
	 					prevYpos = yPos + 1;
	 				}

	 				prevYear = $this.years[prevYpos];
	 				year.val(prevYear);
	 				$this.currYear = prevYear;

	 				year.trigger("change");
	 			}
	 			else if (m && y) {

	 				if (mPos == mLen - 1) {
	 					prevMpos = 0;

	 					if (yPos == yLen - 1) {
	 						prevYpos = 0;
	 					} else {
	 						prevYpos = yPos + 1;
	 					}

	 				} else {

	 					prevMpos = mPos + 1;
	 				}

	 				prevMonth = $this.months[prevMpos];
	 				month.val(prevMonth);
	 				$this.currMonth = prevMonth;

	 				prevYear = $this.years[prevYpos];
	 				year.val(prevYear);
	 				$this.currYear = prevYear;

	 				month.trigger("change");
	 			}
 			});
 		},
 		toggleGraphs: function() {
 			var map = $("#map"),
 				graphs = $("#graths-div");

 			graphs.toggle("show");
 		},
 		toggleLegend: function() {
 			var map = $("#map"),
 				legend = $("#legend-div");

 			legend.toggle("slow");
 		},
 		togglePanel: function() {
 			var map = $("#map"),
 				panel = $("#panel"),
 				pVis = panel.is(":visible");

 			panel.toggle("slow");
 		},
 		displayInitialData: function(evt) {
 			var $this = this;

 			$this.populateCommodities(layers.commodities);
 			$this.populateYears(layers.years);
 			$this.populateMonths(layers.months);

 			//update markets sytles
 			styles.updateMarketStyles();

 			$this.updateHistorySlider();
 		},
 		populateCommodities: function(cmods) {
 			$this = this;

 			$.each(cmods.sort(), function(i, cmod) {
 				if (cmod.toLowerCase() == "na") return;

 				var opt = $("<option/>", {
 					value: cmod,
 					text: cmod
 				});

 				$this.commsEl.append(opt);
 			});
 			//set default value
 			$this.currCmod = layers.commodities[0];
 			app.currCmod = $this.currCmod;
 			$this.commsEl.val($this.currCmod);
 		},
 		populateMonths: function(months) {
 			$this = this;

 			$this.monthsEl.html("");

 			$.each(months, function(i, month) {
 				if (!$.isNumeric(month)) return;

 				var opt = $("<option/>", {
 					value: month,
 					text: $this.lmonths[month - 1]
 				});
 				
 				$this.monthsEl.append(opt);
 			});
 			//set default value
 			$this.currMonth = layers.months[layers.months.length - 1];
 			//save all months
 			$this.months = months;
 			app.currMonth = $this.currMonth;
 			$this.monthsEl.val($this.currMonth);
 		},
 		populateYears: function(years) {
 			$this = this;

 			$this.yearsEl.html("");

 			$.each(years.sort(), function(i, year) {
 
 				var opt = $("<option/>", {
 					value: year,
 					text: year
 				});

 				$this.yearsEl.append(opt);
 			});
 			//set default value
 			$this.currYear = layers.years[layers.years.length - 1];
 			//save all years
 			$this.years = years;
 			app.currYear = $this.currYear;
 			$this.yearsEl.val($this.currYear);
 		},
 		updateHistorySlider: function() {
 			console.log("Updating slider ...");

 			var $this = this,
 				slider = $this.history.data("ionRangeSlider"),
 				m = $this.includeMonths,
 				cm = $this.currMonth,
 				mths = $this.months,
 				y = $this.includeYears,
 				cy = $this.currYear,
 				yrs = $this.years,
 				values = [],
 				cValue = "",
 				vLen = 0;

 			if (m && !y) {
 				values = $this.lmonths;
 				cValue = cm;
 			}
 			else if (!m && y) {
 				values = $this.years;
 				cValue = cy;
 			}
 			else if (m && y) {
 				$.each(yrs, function(i, yr) {
 					$.each(mths, function(j, mth) {
 						var d = mth + "/" + yr;
 						values.push(d);

 						if (cm == mth && cy == yr) {
 							cValue = d;
 						}
 					});
 				});
 			}
 			else {

 			}

 			vLen = values.length;

 			if (slider) {
 				slider.destroy();
 			}

 			console.log("Slider: ", cValue, vLen);

 			$this.history.ionRangeSlider({
 				type: "single"
 				,values: values
 				//,value: cValue
 				,min: 0
 				,max: vLen - 1
 				,from: cValue
 				//,to: values[len-1]
 				,grid: true
 				//,grid_num: 2
 				,prettify_separator: ""
 			});
 		},
 		getHistoryField: function() {
 			var m = $("#price-month").val(),
 				y = $("#price-year").val(),
 				field = m.toUpperCase() + "_" + y.toUpperCase();

 			if (field) {
 				return field;
 			} else {
 				return null;
 			}
 		},
 		setHistoryField: function(field) {
 			var my = field.split("_"),
 				m = my[0],
 				y = my[1];

 			this.monthsEl.val(m);
 			this.yearsEl.val(y);
 		},
 		updateDistrictIpcs: function() {
 			var field = this.getHistoryField(),
 				ipcs = styles.updateIpcStyle(field);

 			this.updateIpcStats(ipcs, field);
 		},
 		updateIpcStats: function(ipcs, season) {
 			var stats = {
 				"1": 0,
 				"2": 0,
 				"3": 0,
 				"4": 0,
 				"5": 0,
 				"66": 0,
 				"88": 0,
 				"99": 0
 			},
 			t = ipcs.length;

 			//get the ipcs status
 			$.each(ipcs, function(i, ipc) {
 				if (stats[ipc]) {
 					stats[ipc] += 1;
 				} else {
 					stats[ipc] = 1;
 				}
 			});

 			//update season
 			var header = season ? season.split("_") : ["XXX", "9999"];
 			header = header[0] + ", " + header[1];
 			$("#ipcs-stats-header").text(header);

 			//update ipc stats bars
 			for (ipc in stats) {
 				var bar = $(".ipc-" + ipc),
 					n = stats[ipc],
 					perc = Math.round(n / t * 100);

 				console.log("Perc:", ipc, n, t, perc);

 				if (bar.length) {
 					bar.css("width", perc + "%");

 					/*var txt = ipc;
 					txt += ": ";*/
 					var txt = perc;
 					txt += "%";
 					
 					bar.text(txt);
 				}
 			}
 		},
 		updateHeatmap: function(fName, title) {
 			//console.log("Updating heatmap ....");

 			var $this = this,
 				gDiv = $("#ipcs-his-graph"),
 				months = $this.months,
 				years = $this.years,
 				dFields = [],
 				rIpcs = [1,2,3,4,5,66,88,99],
 				data = [];

 			//clear the existing heatmap
 			gDiv.html("");

 			$.each(years, function(i, y) {
 				$.each(months, function(j, m) {
 					var field = m + "_" + y;
 					dFields.push(field);

 					var l=  rIpcs.length,
 					d = {
 						month: j + 1,
 						year: i + 1,
 						value: rIpcs[Math.floor(Math.random() * l)]
 					};

 					data.push(d);
 				});
 			});

 			//console.log("Fields:", dFields.length, dFields);
 			var name = fName ? fName : 0,
 				ipcsData = styles.getAllIpcsData(dFields, name);

 			//heatmap example
 			var margin = { top: 30, right: 0, bottom: 20, left: 50 },
 				w = gDiv.width(),
 				h = gDiv.height(),
				width = 500 - margin.left - margin.right,
				height = 150 - margin.top - margin.bottom,
				gridSize = Math.floor(width / years.length),
				gridH = Math.floor(height / months.length),
				legendElementWidth = gridSize*2,
				buckets = 6,
				//colors = ["#ffffd9","#edf8b1","#c7e9b4","#7fcdbb","#41b6c4","#1d91c0","#225ea8","#253494","#081d58"], // alternatively colorbrewer.YlGnBu[9]
				colors = ["#DEF7DE", "#FFE718", "#E77B00", "#CE0000", "#630000", "blue", "green", "#888888"],
				years = ["2008", "2009", "2010", "2011", "2012", "2013", "2014", "2015"],
				months = ["JAN", "APR", "JUL", "OCT"];
				dataset = $.map(ipcsData, function(d,i) {
					return {
						month: months.indexOf(d.month) + 1,
						year: years.indexOf(d.year) + 1,
						name: d.name,
						value: d.ipc
					};
				});

			//svg box
			var svg = d3.select("#ipcs-his-graph").append("svg")
				.attr("width", width + margin.left + margin.right)
				.attr("height", height + margin.top + margin.bottom)
				.append("g")
				.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

			//months labels
	      	var monthLabels = svg.selectAll(".monthLabel")
	          	.data(months)
	          	.enter().append("text")
	            .text(function (d) { return d; })
	            .attr("x", 0)
	            .attr("y", function (d, i) { 
	            	var y = i * gridH;
	            	return y; 
	            })
	            .style("text-anchor", "end")
	            .attr("transform", "translate(-6," + gridH / 1.5 + ")")
	            .attr("class", function (d, i) { return "mouthsLabel mono axis"; });

	        //years labels
	      	var yearLabels = svg.selectAll(".yearLabel")
	          	.data(years)
	          	.enter().append("text")
	            .text(function(d) { return d; })
	            .attr("x", function(d, i) { 
	            	var x = i * gridSize;
	            	return x; 
	            })
	            .attr("y", 0)
	            .style("text-anchor", "middle")
	            .attr("transform", "translate(" + gridSize / 2 + ", -6)")
	            .attr("class", function(d, i) { return "yearsLabel mono axis"; });

	        //heatmap
	        var colorScale = d3.scale.quantile()
	        	//.domain([0, buckets - 1, d3.max(data, function (d) { return d.value; })])
	        	.domain([0, buckets - 1, d3.max(dataset, function (d) { return d.value; })])
	        	.range(colors);

	        var seasons = svg.selectAll(".season")
	            //.data(data, function(d) {return d.year+':'+d.month;});
	            .data(dataset, function(d) {return d.year+':'+d.month;});

	        seasons.enter().append("title")
	        	.text(function(d) { 
	        		var title = "";

	        		if(!d) {
	        			return title;
	        		}

	        		title += $this.months[d.month] ? $this.months[d.month] : "XXX";
	        		title +=  ", ";
	        		title += $this.years[d.year] ? $this.years[d.year] : "9999";
	        		title += " (";
	        		title += d.value;
	        		title += ")";

	        		return title;
	        	});

	        //create season boxes
	        seasons.enter().append("rect")
	            .attr("x", function(d) { 
	            	var x = (d.year - 1) * gridSize; 
	            	return x;
	            })
	            .attr("y", function(d) { 
	            	var y = (d.month - 1) * gridH; 
	            	return y;
	            })
	            .attr("rx", 5)
	            .attr("ry", 5)
	            .attr("class", "season bordered")
	            .attr("width", gridSize - 2)
	            .attr("height", gridH - 2)
	            .style("fill", colors[0]);

	        //update season colors
	        seasons.transition().duration(1000)
            	.style("fill", function(d) { return colorScale(d.value); });

            //graph header
            if (fName && title) {
				$("#graph-header").css("padding-left", margin.left)
				.html("").text(title);
			}

			/*var t = d3.select("#graph-header").html("")
				.append("text")
				.attr("x", 0)
				.attr("y", 0)
				.text(fName);*/
	 	},
	 	displayMarketInfo: function(position) {
	 		//console.log("Position: ", position);

	 		var $this = this;

	 		//info window
	 		if (!$this.info) return;

	 		$this.info.css({
	 			left: position[0] + "px",
	 			top: (position[1] - 15) + "px"
	 		});

	 		var tFeat = app.map.forEachFeatureAtPixel(position, function(f, lyr){
	 			return f;
	 		});

	 		if (tFeat) {
	 			var attr = tFeat.getProperties(),
	 				cname = attr["NAME"],
	 				creg = attr["SUBREGION"];

	 			var mid = attr["mid"],
	 				mname = attr["name"],
	 				mloc = attr["market_loc"],
	 				mcmods = layers.marketsData && layers.marketsData[mid] ? layers.marketsData[mid]["cmods"].join(", ") : "";

	 			var txt = "";

	 			if (creg) {
	 				txt = cname + " - " + creg;
	 			}
	 			else {
	 				txt = mname != "NA" ? mname : "";
	 				txt += txt != "" ? " (" : "";
	 				
	 				txt += mloc != "NA" ? mloc : "";
	 				txt += txt.indexOf("(") > -1 ? ")" : "";

	 				txt = txt != "" ? txt : "No valid info";

	 				txt += "<br/>Commodities: ";
	 				txt += mcmods != "" ? mcmods : "None";

	 				//selected options
	 				var sel = "",
	 					sc = $this.currCmod,
	 					sm = $this.currMonth,
	 					sy = $this.currYear,
	 					csel = sc + "" + sm + "" + sy,
	 					pa = layers.marketsData[mid]["sels"][csel];

	 				if (pa && $.isNumeric(pa)) {
	 					pa = parseFloat(pa).toFixed(2);
	 				}
	 				else {
	 					pa = "NA";
	 				}

	 				if (sc != "") {

	 					sel += "<br/>";
	 					sel += "Selection: ";
	 					sel += sc;
	 					sel += " (";
	 					sel += pa;
	 					sel += ") - ";
	 					//sel += $this.lmonths[sm];
	 					sel += sm;
	 					sel += "/";
	 					sel += sy;

	 					txt += sel;
	 				}
	 			}

	 			$this.info.tooltip("hide")
 				.attr("data-original-title", txt)
 				.tooltip("fixTitle")
 				.tooltip("show");
	 		} 
	 		else {
	 			$this.info.tooltip("hide");
	 		}
	 	},
	 	updateMarketGraph: function(position) {

	 		var tFeat = app.map.forEachFeatureAtPixel(position, function(f, lyr){
	 			return f;
	 		});

	 		if (tFeat) {
	 			var attr = tFeat.getProperties(),
	 				cname = attr["NAME"],
	 				creg = attr["SUBREGION"];

	 			if (creg) return;

	 			var mid = attr["mid"],
	 				mname = attr["name"],
	 				mloc = attr["market_loc"],
	 				cdata = layers.marketsData && layers.marketsData[mid] ? layers.marketsData[mid]["cdata"] : [];

	 			if (!cdata.length) return;

	 			cdata = $.map(cdata, function(d, i) {
	 				if (!$.isNumeric(d.price_anomaly)) {
	 					//d.price_anomaly = 0;
	 				}

	 				d.price_anomaly = parseFloat(d.price_anomaly);
	 				d.date = d.d_month + "/" + d.d_year;

	 				return {
	 					id: d.id,
	 					date: d.date,
	 					price_anomaly: d.price_anomaly
	 				};
	 			});

	 			var formatDate = "testing"; //d3.time.format("%d-%b-%y");

	 			//console.log("Market Data: ", layers.marketsData[mid]);

	 			$this.hisBarHeader.text("Market: " + mloc + " (Price Anomaly)");
	 			$this.hisBar.html("");

	 			var margin = {top: 20, right: 20, bottom: 30, left: 50},
				    width = $this.hisBar.width() - margin.left - margin.right,
				    height = 300 - margin.top - margin.bottom;

				var x = d3.time.scale()
				    .range([0, width]);

				var y = d3.scale.linear()
				    .range([height, 0]);

				var xAxis = d3.svg.axis()
				    .scale(x)
				    .orient("bottom");

				var yAxis = d3.svg.axis()
				    .scale(y)
				    .orient("left");

				var line = d3.svg.line()
					//.defined(function(d) { return !isNaN(d.price_anomaly); })
				    .x(function(d) { 
				    	return x(d.id); 
				    })
				    .y(function(d) { 
				    	return y(d.price_anomaly);  
				    })
				    .interpolate("linear");

				var svg = d3.select("#his-bar").append("svg")
				    .attr("width", width + margin.left + margin.right)
				    .attr("height", height + margin.top + margin.bottom)
				  	.append("g")
				    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

				x.domain(d3.extent(cdata, function(d) { 
					return d.id; 
				}));
  				y.domain(d3.extent(cdata, function(d) { 
  					return d.price_anomaly; 
  				}));

  				svg.append("g")
					.attr("class", "x axis")
					.attr("transform", "translate(0," + height + ")")
					.call(xAxis);

				svg.append("g")
					.attr("class", "y axis")
					.call(yAxis);
					/*.append("text")
					.attr("transform", "rotate(-90)")
					.attr("y", 6)
					.attr("dy", ".71em")
					.style("text-anchor", "end")
					.text("Price variabilily");*/

				svg.append("path")
					.datum(cdata)
					.attr("class", "line")
					.attr("d", line);
	 			
	 		}
	 		else {

	 		}
	 	}
 	};
 });