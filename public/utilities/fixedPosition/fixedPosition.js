/**********************************************************************************************
 * fixed定位
 * options:
 * 	scrollFunc(obj, objTop, basic)
 * 		INFO:滚动时触发的事件
 * 		obj:jQuery Object 当前元素
 * 		status:Object 当前元素状态值 (top, left, right, bottom)
 * 		basic:Object 当前元素的基本值 (top, left, right, bottom)
 * 		[ps]:可以通过更改status的值来控制fixed元素的位置，目前只有isHaveContainer==false时的top,bottom有用(todo)
 * 		[ps]:basic对象是readonly的，用于记录元素的初始位置
 * 	readyFunc(obj)
 * 		INFO:初始化元素后触发的事件
 * 		obj:jQuery Object 当前元素
**********************************************************************************************/

;if(!$("").fixedPosition)
(function($){
	
	var ie6 = /*@cc_on!@*/!1 && /msie 6.0/i.test(navigator.userAgent) && !/msie 7.0/i.test(navigator.userAgent);
	
	var defaults = {
		"top":null,
		"bottom":null,
		"left":null,
		"right":null,
		
		"pageWidth":null,
		"z-index":1000,
		"referenceObj":null,
		
		"isScrollHide":false,
		"hideBefore":"",//在x像素之前隐藏元素
		
		"readyFunc":null,
		"scrollFunc":null,
		"clickFunc":null
	};
	
	function fixedPosition(options){
		var that = this;
		var pageW, bottom2Top, toShow2Ie6;
		var status = {};
		var basic = {};
		
		options = $.extend({},defaults,options);
		
		if(options.clickFunc instanceof Function){
			that.click(function(){
				options.clickFunc();
			}); 
		}
		
		initVariables();
		initPosition();
		scrollEvent();
		
		$(window).scroll(scrollEvent);
		
		$(window).resize(function(){
			refresh4WindowResize();
		});
		
		function refresh4WindowResize(){
			initVariables();
			that.css({
				"left":basic.left,
				"right":basic.right
			});
		}
		
		function scrollEvent(){
			var scrollTop = $(document).scrollTop();
			var basicCopy = $.extend({},basic);
			var dynamicTop, dynamicBottom, position;
			var bottomForIe6;
			
			if(options.scrollFunc) options.scrollFunc(that, status, basicCopy);
			
			if(scrollTop < options.hideBefore){
				that.hide();
				return false;
			}
			
			that.show();
			if(ie6 || options.isScrollHide){
				that.hide();
				if(toShow2Ie6) clearTimeout(toShow2Ie6);
				toShow2Ie6 = setTimeout(function(){
					that.show();
				},200);
			}
			
			if(ie6){
				if (options.bottom != null) {
					if(scrollTop+$(window).height() > options.end){
						dynamicTop = options.end - that.outerHeight();
					}else {
						bottomForIe6 = $(window).height() - (status.bottom + that.outerHeight());
						dynamicTop = bottomForIe6 + scrollTop;
					}
					position = "absolute";
				}else {
					if (scrollTop < options.start) {
						dynamicTop = options.start;
						position = basic.oPos;
					}else if (scrollTop > options.end) {
						dynamicTop = options.end - that.outerHeight();
						position = "absolute";
					}else {
						dynamicTop = status.top + scrollTop;
						position = "absolute";
					} 
				}
				that.css({
					"position": position,
					"top":dynamicTop,
					"left":status.left,
					"right":status.right
				});
			}else {
				if(options.bottom != null){
					// for bottom, options start can not work
					if(scrollTop + $(window).height() > options.end){
						dynamicTop = options.end - that.outerHeight();
						dynamicBottom = "auto";
						position = "absolute";
					}else {
						dynamicTop = "auto";
						dynamicBottom = status.bottom;
						position = "fixed";
					}
					that.css({
						"position":position,
						"top":dynamicTop,
						"bottom":dynamicBottom,
						"left":status.left,
						"right":status.right
					});
				}else {
					if(scrollTop < options.start){
						dynamicTop = options.start;
						position = basic.oPos;
					}else if(scrollTop > options.end - that.outerHeight()){
						dynamicTop = options.end - that.outerHeight();
						position = "absolute";
					}else {
						dynamicTop = status.top;
						position = "fixed";
					}
					that.css({
						"position":position,
						"top":dynamicTop,
						"left":status.left,
						"right":status.right
					});
				}
			}
		}
		
		function initVariables(){
			if(options.referenceObj){
				pageW = $(options.referenceObj).outerWidth();
			}else {
				pageW = options.pageWidth;
			}
			if(options.right != null) status.right = basic.right = (pageW ? ($(window).width()-pageW)/2 : 0) + options.right;
			if(options.left != null) status.left = basic.left = (pageW ? ($(window).width()-pageW)/2 : 0) + options.left;
			if(options.top != null) status.top = basic.top = options.top;
			if(options.bottom != null) {
				status.bottom = basic.bottom = options.bottom;
				if(ie6){
					bottom2Top = $(window).height() - (basic.bottom + that.outerHeight());
				}
			}
			basic.oPos = that.css("position");
		}
		
		function initPosition(){
			that.css({
				"top":bottom2Top?bottom2Top:basic.top,
				"bottom":ie6?null:basic.bottom,
				"left":basic.left,
				"right":basic.right,
				"z-index":options["z-index"]
			});		
			if(options.readyFunc instanceof Function){
				options.readyFunc(that);
			}
		}
	}
	
	$.fn.extend({
		fixedPosition:fixedPosition
	});
})(jQuery);
