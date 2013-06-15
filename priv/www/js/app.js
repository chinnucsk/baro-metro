(function($) {
	var d = new Date();
	var sockjs = null;

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
		send("I");
	}
	function reconnect() {
		
	}
	function disconnect(e) {
	}
	function send(val) {
		if(sockjs && sockjs.readyState == SockJS.OPEN) 
			sockjs.send(val);
		else
			setTimeout(function() { send(val); }, 1000);
	}
	function message(m) {
		var p = $.parseJSON(m.data); 
	}

	/*
		UI
	*/

	function ui_init() {

	}

	/*
		Templates
	*/
	$.nano = function(template, data) {
    	return template.replace(/\{([\w\.]*)\}/g, function (str, key) {
      			var keys = key.split("."), value = data[keys.shift()];
     			$.each(keys, function () { value = value[this]; });
      			return (value === null || value === undefined) ? "" : value;
    		});
  	};

  	$.nano.strip = function(s) { 
    	s = s.replace(/&/gi, "&amp;");
    	s = s.replace(/\"/gi, "&quot;");
    	s = s.replace(/</gi, "&lt;");
    	s = s.replace(/>/gi, "&gt;");
		return s; 
	}


})(window.jQuery);
$(document).ready(function() { $.app.init(); });