;if(!$.cookie)
(function($){
	
	var cookie = {};
	
	cookie.set= function(name, value, options){
		options = options || {};
		var expires, domain, path, secure;
		
		if(options.expires && typeof options.expires == "number" || options.expires.toGMTString){
			var date;
			if(typeof options.expires == "number"){
				date = new Date();
				date.setTime(date.getTime() + options.expires * 24 * 60 * 60 * 1000);
			}else {
				date = options.expires;
			}
			expires = ";expires=" + date.toGMTString();
		}
		domain = options.domain ? ";domain="+options.domain : "";
		path = options.path ? ";path="+options.path : "";
		secure = options.secure ? ";secure="+options.secure : "";
		//console.log([name + "=" + encodeURIComponent(value),expires,domain,path,secure].join(""));
		document.cookie = [name + "=" + encodeURIComponent(value),expires,domain,path,secure].join("");
	};
	
	cookie.get = function(name){
		var arr = document.cookie.match(new RegExp("(^| )"+name+"=([^;]*)(;|$)"));
		if(arr != null) return unescape(arr[2]); return null;
	}
	
	cookie.del = function(name){
		var exp = new Date();
		exp.setTime(exp.getTime() - 1);
		var cval=this.get(name);
		if(cval!=null) document.cookie= name + "="+cval+";expires="+exp.toGMTString();
	}

	$.extend({cookie:cookie});

})(jQuery);