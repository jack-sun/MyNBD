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

;(function($){
	
	var ie6 = /*@cc_on!@*/!1 && /msie 6.0/i.test(navigator.userAgent) && !/msie 7.0/i.test(navigator.userAgent);
	
	var defaults = {
		"top":null,
		"bottom":null,
		"left":null,
		"right":null,
		
		"pageWidth":null,
		"z-index":1000,
		"referenceObj":null,
		
		"isHaveContainer":false,
		"isScrollHide":false,
		
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
		
		$(window).scroll(scrollEvent);
		
		$(window).resize(function(){
			refresh4WindowResize();
		});
		
		function refresh4WindowResize(){
			initVariables();
			if(options.isHaveContainer && that.css("position") == "absolute"){
			}else {
				that.css({
					"left":basic.left,
					"right":basic.right
				});
			}
		}
		
		function scrollEvent(){
			var scrollTop = $(document).scrollTop();
			var basicCopy = $.extend({},basic);
			
			if(ie6 || options.isScrollHide){
				that.hide();
				if(toShow2Ie6) clearTimeout(toShow2Ie6);
				toShow2Ie6 = setTimeout(function(){
					that.show();
				},100);
			}
		
			if(options.scrollFunc) options.scrollFunc(that, status, basicCopy);
			if(options.isHaveContainer){
				if(ie6){
					if(basic.top < scrollTop){
						that.css({
							"top":(scrollTop-status.top+10)
						});	
					}else {
						that.css({
							"top":options.top
						});
					}
				}else{
					if(basic.top<scrollTop){
						that.css({
							"position": "fixed",
							"top":10,
							"left":status.left
						});
					}else {
						that.css({
							"position": "absolute",
							"top":options.top,
							"left":options.left
						});
					}
				}
			}else{
				if(ie6){
					if(options.bottom != null){
						var bottomForIe6 = $(window).height() - (status.bottom + that.outerHeight());
						that.css("top",bottomForIe6 + scrollTop);
					}else {
						that.css("top",status.top + scrollTop);
					}
				}else {
					that.css({
						"top":status.top,
						"bottom":status.bottom
					});
				}
			}
		}
		
		function initVariables(){
			if(options.referenceObj){
				pageW = $(options.referenceObj).outerWidth();
			}
			if(options.isHaveContainer){
				var parent = that.parent();
				if(options.top != null) status.top = basic.top = options.top + parent.position().top;
				if(options.left != null) status.left = basic.left = options.left + parent.position().left
				if(options.right != null) status.right = basic.right = options.right + parent.position().right;
				//if(options.bottom != null) status.bottom = basic.bottom = options.bottom + parent.position().top + parent.height();
				that.css("width",parent.width());
				that.parent().css("position","relative");
			}else {
				if(options.right != null) status.right = basic.right = (pageW ? ($(window).width()-pageW)/2 : 0) + options.right;
				if(options.left != null) status.left = basic.left = (pageW ? ($(window).width()-pageW)/2 : 0) + options.left;
				if(options.top != null) status.top = basic.top = options.top;
				if(options.bottom != null) {
					status.bottom = basic.bottom = options.bottom;
					if(ie6){
						bottom2Top = $(window).height() - (basic.bottom + that.outerHeight());
					}
				}
			}
		}
		
		function initPosition(){
			that.css('z-index', options["z-index"]);
			if(options.isHaveContainer){
				that.css({
					"position":"absolute",
					"top":options.top,
					"left":options.left,
					"right":options.right
				});
			}else{
				that.css({
					"position":ie6?"absolute":"fixed",
					"top":bottom2Top?bottom2Top:basic.top,
					"bottom":ie6?null:basic.bottom,
					"left":basic.left,
					"right":basic.right
				});		
			}
			if(options.readyFunc instanceof Function){
				options.readyFunc(that);
			}
		}
	}
	
	$.fn.extend({
		fixedPosition:fixedPosition
	});
})(jQuery);
