;(function($){
	var _tabLength;
	var _templateContent = "<div id='tabs-$(id)'><textarea name='artical_pages_attributes_$(id)_content'></textarea></div>";
	var _templateTab = "<li><a href='#tabs-$(id)'>第$(id)页</a></li>";
	
	function tabs(){
		var that = this;
		var $newTab = that.find('ul li:last a');
		// initilize
		_tabLength = that.find('ul li:not(:last) a').length;
		that.find("div[id^='tabs']").hide().filter(':first').show();
		// bind li event
		console.log(that);
		that.find('ul li a').live('click',function(e){
			console.log(111);
			var target = e.target;
			if($(target).attr('href').indexOf('#tabs') == -1) return;
			console.log($(target).attr('href').slice(1));
			var id = $(target).attr('href').slice(1);
			that.find('ul li').removeClass();
			$(target).closest("li").addClass('current');
			that.find("div[id^='tabs']").hide();
			$('#'+id).show();
			return false;
		});
		
		// add new tab
		$newTab.click(function(){
			_tabLength++;
			if(_tabLength == 9) $newTab.hide();
			var newDIV = $(_templateContent.replace(/\$\(id\)/g,_tabLength))
			var newLI = $(_templateTab.replace(/\$\(id\)/g,_tabLength))
			newDIV.appendTo(that).hide();
			$(this).parent().before(newLI);
		});
	}
	
	$.fn.extend({
		tabs:tabs
	});
})(jQuery);
