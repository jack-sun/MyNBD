;if(!$.nbdtabs)
(function($){
	var defaults = {
		limitNum:9,
		//template
		addDOM:"",
		removeDOM:"",
		tabsDOM:null,
		contentDOM:null,
		templateContent:"请添加content模板",
		templateTab:"第$(id)页",
		symbolIndex:"tabs",
		//events
		readyEvent:null,
		beforeAddEvent:null,
		afterAddEvent:null,
		removeContentEvent:null,
		refreshContentEvent:null
	}
	
	function tabs(options){
		options = $.extend({}, defaults, options);
		var addable = $(options.addDOM).length > 0;
		var removeable = $(options.removeDOM).length > 0;
		
		var $tabs = $(options.tabsDOM);
		var $content = $(options.contentDOM);
		var $newTab = addable ? $(options.addDOM) : $("");
		var $removeTab = removeable ? $(options.removeDOM) : $("");
		
		var symbolIndex = options.symbolIndex;
		var tabLength = addable ? ($tabs.find('li a').length-1) : $tabs.find('li a').length;
		
		var templateContent = "<div id='"+symbolIndex+"-$(id)' style='dilplay:block'>"+options.templateContent+"</div>";
		var templateTab = "<li><a href='#"+symbolIndex+"-$(id)'>"+options.templateTab+"</a></li>";
		
		$content.children("[id^='"+symbolIndex+"']").hide().eq(0).show();
		$tabs.find('li').eq(0).addClass('current').siblings().removeClass('current');

		if (tabLength == 1 ) {
			$removeTab.hide();
		}
		
		if(options.readyEvent instanceof Function) options.readyEvent(tabLength);
		
		//click event of tabs' item
		$tabs.find('li a').live('click', function(e){
			var $target = $(e.target);
			if ($target.attr('href').indexOf('#'+symbolIndex) == -1) return;
			var id = $target.attr('href').slice(1);
			$target.closest("li").addClass('current').siblings().removeClass('current');
			$('#' + id).show().siblings("[id^='"+symbolIndex+"']").hide();
			return false;
		});
		
		// add new tab
		$newTab.click(function(){
			$removeTab.show();
			var templateContentStash;
			tabLength = $tabs.find("li").length ;
			if(tabLength === options.limitNum) $newTab.hide();
			
			if(options.beforeAddEvent instanceof Function) templateContentStash = options.beforeAddEvent(templateContent);
			var newDIV = $(templateContentStash.replace(/\$\(id\)/g, tabLength));
			var newLI = $(templateTab.replace(/\$\(id\)/g, tabLength));
			newDIV.appendTo($content).hide();
			$(this).parent().before(newLI);
			newLI.find("a").trigger("click");
			
			if(options.afterAddEvent instanceof Function) options.afterAddEvent(newDIV);
		});
		
		//delete tab
		$removeTab.click(function(){
			if (!confirm("确定要删除此项吗？")) return;
			if ($tabs.find('li').length == 3) {
				$removeTab.hide();
			}
			if ($newTab.is(':hidden')) $newTab.show();
			var $cdiv = $content.find("div[id^='"+symbolIndex+"']:visible");
			var $cli = $tabs.find('.current');
			var $toShowLi = $cli.prevAll('li:first').length ? $cli.prevAll('li:first'):$cli.nextAll('li:first');
			
			$toShowLi.find("a").trigger("click");
			$cli.remove();
			
			if (options.removeContentEvent instanceof Function) {
				options.removeContentEvent($cdiv);
			}else { 
				$cdiv.remove();
			}
			
			$tabs.find('li:not(:last-child) a').each(function(i){
				this.href = '#' + symbolIndex + '-' + (i + 1);
				$(this).text(options.templateTab.replace("$(id)",(i+1)));
			});
			
			$content.find("div[id^='"+symbolIndex+"']").each(function(i){
				//console.log(symbolIndex + '-' + (i + 1));
				this.id = symbolIndex + '-' + (i + 1);
				if (options.refreshContentEvent instanceof Function) {
					options.refreshContentEvent($(this),i);
				}
			});
			
			return false;
		});
	}
	
	// to dump
	$.fn.extend({
		nbdtabs: tabs
	});
	
	// recommend
	$.extend({
		nbdtabs: tabs
	});
	
})(jQuery);
