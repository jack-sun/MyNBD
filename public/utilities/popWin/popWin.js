/**********************************************************************************************
 * 名称: 弹出窗口
 * 
 * API:
 * 		$.popWin.clean() 清除所有的弹出层
 * 
 *		arguments: follow default:false
 * 		var p = $.popWin.init(options) 初始化一个弹出层
 * 			options.title	标题 ("")
 * 			options.follow	是否随窗口移动 （false）
 * 		p.front() 将此层放到最前面
 * 		p.mask() 使用遮罩
 * 		p.mask(false) 去除遮罩
 * 		p.remove() 删除此层
 * 
 * 		p.div 最外层元素的jquery对象
 * 		p.show() 显示弹出窗口
 * 		p.hide() 隐藏弹出窗口
 *		
 */

;if(!$.popWin)
(function($, undef) {
	var ie6 = /*@cc_on!@*/!1 && /msie 6.0/i.test(navigator.userAgent) && !/msie 7.0/i.test(navigator.userAgent);
	
	var  EMPTY_$ = $('')
		,html_string = '<div class="win1-wrap"><div class="win1-title-wrap"><span class="win1-title">title</span><a class="win1-close" href="#"></a></div><div class="win1-content-wrap"><div class="win1-content"></div></div></div>'
		,popWin = {};
	
	var defaults = {
		follow:false,
		title:'',
		width:500,
		height:"auto",
		closeable:true,
		hideCloseBtn:false,

		// Event
		// closeCallback:if return === false, don't close the pop window
		closeCallback:null
	}
	
	popWin.divs = EMPTY_$;
	popWin.init = function(options){
		return new init(options);
	}
	popWin.clean = function(){
		$.popManager.clean();
	}

	function init(options){
		var  self = this
			,div = $(html_string);
		
		options = $.extend({}, defaults, options);
		
		//保存到全局
		popWin.divs = popWin.divs.add(div);

		//设置属性
		self.div = div;
		self.close = div.find('a.win1-close');
		self.title = div.find('span.win1-title');
		self.content = div.find('div.win1-content');
		self.close_able = options.closeable;
		self.follow = options.follow;

		self.manager = $.popManager.init();
		self.div.appendTo('body');
		self.manager.div.appendTo('body');
		self.div.css('z-index',self.manager.div.css('z-index')+1);
		self.div.width(options.width);
		self.content.height(options.height);
		self.title.text(options.title);

		self.closeCallback = options.closeCallback;
		
		if(self.follow && !ie6) self.div.css('position','fixed');
		if(options.hideCloseBtn) self.close.hide();
		
		div.data("popWin", self);

		//设置关闭按钮
		self.close.click(function(e){
			self.hide();
			e.preventDefault();
		});

		// //设置关闭按钮
		// self.div.click(function(e){
		// 	if($(e.target).is('.win1-btn-cancle')){
		// 		self.hide();
		// 	}
		// });

		//设置不能拖动的地方
		self.content.add(self.close).mousedown(function(e){
			e.stopPropagation();
		});
	}

	$.extend(init.prototype, {
		 front: function(){
			this.manager.front();
			return this;
		}
		,mask: function(use){
			this.manager.mask(use);
			return this;
		}
		,loading: function(str){
			if (str == false) {
				this.div.show();
				this.manager.loading(str);
			}else{
				this.div.hide();
				this.manager.loading(str);
			}
			return this;
		}
		,show: function(){
			this.div.show();
			this.manager.div.show();
			this.div.css({
				 //top: (document.documentElement.clientHeight-this.div.height())/3+$(document).scrollTop()
				 top: (document.documentElement.clientHeight-this.div.height())/3+(this.follow&&!ie6?0:$(document).scrollTop())
				,left:(document.documentElement.clientWidth-this.div.width())/2
			});
			this.div.find("input:visible,textarea:visible").eq(0).focus();
			return this;
		}
		,hide: function(empty){
			if(this.close_able){
				if( this.closeCallback && this.closeCallback() === false ){
					return ;
				}
				this.div.hide();
				this.manager.div.hide();
				if(empty) this.content.empty();	//temp
			}
			return this;
		}
		,remove: function(){
			this.div.remove();
			this.manager.div.remove();
			return this;
		}
	});

	$.extend({
		popWin: popWin
	});
})(jQuery);