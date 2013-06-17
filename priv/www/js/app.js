(function($) {
	var d = new Date();
	var sockjs = null;
	var tg = null;
	var pg = null;
	var tgr = null;
	var pgr = null;

	var p = [];
	
	$.app = {}
	$.app.init = function() {
		sockjs = new SockJS('http://' + window.location.hostname + ":" +  window.location.port + '/a');
		sockjs.onopen = connect;
		sockjs.onclose = disconnect;
		sockjs.onmessage = message;
	}

	/*
		SockJS ops
	*/
	function connect() {
		ui_init();
		send("I");
	}
	function reconnect() {
		setTimeout(function() { $.app.init(); }, 3000);
	}
	function disconnect(e) {
		reconnect();
	}
	function send(val) {
		if(sockjs && sockjs.readyState == SockJS.OPEN) 
			sockjs.send(val);
		else
			setTimeout(function() { send(val); }, 1000);
	}
	function message(m) {
		a = $.parseJSON(m.data); 
		if(a) {
			if(a.length > 1) {
				p = a;
				while(p.length > 50) p.shift();
				ui_reset();
			} else {
				p.push(a[0]);
				while(p.length > 50) p.shift();
				ui_update(a[0]);
			}
		}
	}

	/*
		UI
	*/
	function ui_init() {
		tg = tgauge();
		pg = pgauge();
		tgr = tgraph();
		pgr = pgraph();
	}

	function ui_reset() {
		tgr.option('dataSource', p);
		pgr.option('dataSource', p);
	}

	function ui_update(s) {
		tg.rangeBarValue(0, s.t);
		pg.markerValue(0, s.p);
		ui_reset();
	}

	function tgauge() {
		return $('#tgauge').dxLinearGauge({
				title: 'Temperature',
				geometry: { orientation: 'vertical' },
				scale: {
					startValue: -40,
					endValue: 40,
					majorTick: { tickInterval: 40 }
				},
				rangeContainer: {
					backgroundColor: 'none',
					ranges: [
						{ startValue: -40, endValue: 0, color: '#679ec5' },
						{ startValue: 0, endValue: 40 }
					]
				},
				rangeBars: [{ value: 10 , text: { indent: 20 } }]
			}).dxLinearGauge('instance');		
	}

	function pgauge() {
		return $('#pgauge').dxLinearGauge({
				title: 'Pressure',
				geometry: { orientation: 'vertical' },
				scale: {
					startValue: 800,
					endValue: 1200,
					majorTick: {
						showCalculatedTicks: false,
						customTickValues: [800, 900, 1020, 1200]
					}
				},
				rangeContainer: {
					backgroundColor: 'none',
					ranges: [
						{ startValue: 800, endValue: 1000, color: '#679ec5' },
						{ startValue: 900, endValue: 1020, color: '#a6c567' },
						{ startValue: 1020, endValue: 1200, color: '#e18e92' }
					]
				},
				markers: [{value: 900}]
			}).dxLinearGauge('instance');
	}

	function tgraph() {
		return $("#tgraph").dxChart({
				commonSeriesSettings: {
					type: 'area',
			        argumentField: 'tm'
			    },
			    series: [
			    	{ name: "t, °C", valueField: 't', color: '#679ec5' }
			    ],
			    title: 'Temperature',
				animation: { enabled: false }
		}).dxChart('instance');
	}

	function pgraph() {
		return $("#pgraph").dxChart({
				commonSeriesSettings: {
					type: 'area',
			        argumentField: 'tm'
			    },
			    series: [
			    	{ name: "P, mBar", valueField: 'p', color: '#a6c567' }
			    ],
			    title: 'Pressure',
			    animation: { enabled: false }	
		}).dxChart('instance');
	}


})(window.jQuery);
$(document).ready(function() { $.app.init(); });