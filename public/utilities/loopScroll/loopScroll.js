;
(function(){
	var defaults = {
		speed:50
	};
	
	function loopScroll(options){
		options = options || {};
		var settings = $.extend({}, defaults, options);
		
		var $scrollTopic = $(this);
		if(!$scrollTopic.is("ul")){
			return $(this);
		}
		var maxlength = 0;
		$scrollTopic.children("li").each(function(i,v){
			maxlength += $(v).outerWidth(true);
		});
		$scrollTopic.width(maxlength);
		function autoScroll(){
			var startPos = $scrollTopic.css("left");
			var fwidth = $scrollTopic.children(":first").outerWidth(true);
			$scrollTopic.animate({
				"left":-fwidth
			},(fwidth+parseInt(startPos))*settings.speed,"linear",function(){
				$scrollTopic.children(":first").appendTo($scrollTopic);
				$scrollTopic.css("left",0);
				autoScroll();
			});
		}
		if($scrollTopic.parent().outerWidth()<maxlength){
			autoScroll();
			$scrollTopic.mouseenter(function(){
				$scrollTopic.stop();
			}).mouseleave(function(){
				autoScroll();;
			});
		}
		return $(this);
	}
	$.fn.loopScroll = loopScroll;
})();
