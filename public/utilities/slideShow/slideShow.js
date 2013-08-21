/*******************************************
 * slideShow
 * 
 * properties:
 * --slide-index-disable: true (此index不计入索引)
 * 档动画效果为slide时，container必须定宽定高。其它效果可以不用
 ******************************************/

;if(!$.nbdslide)
(function($){
	
	var defaults = {
		asyn:false,
		//图片信息的出现是否延迟
		optDOMs:[], //require
		indexDOM:"",
		prevDOM:"",
		nextDOM:"",
		ratioDOM:[],
		//DOM节点
		style:"fade",
		speed:"normal",
		//滚动方式：
		//	normal:普通; fade:淡入淡出; slide-x:横向滚动； slide-y：竖向滚动； switch:刷屏
		scrollSameTend:false,
		//一直向同一个方向滚动
		autoScroll:true,
		//是否自动播放
		interval:3000
		//自动播放时间间隔（ms毫秒)
	};

	var slide = {};

	slide.init = function(options){

		options = $.extend({}, defaults, options);

		var optDOMs = [];
		var partialObjs = [];
		var scrollSameTend = options.scrollSameTend;
		var $indexDOM = $(options.indexDOM);
		var $indexList = $indexDOM.children(":not([slide-index-disable=true])");
		var $prevDOM = $(options.prevDOM);
		var $nextDOM = $(options.nextDOM);
		var $ratioDOM_c, $ratioDOM_t;

		if(options.ratioDOM.length === 2){
			$ratioDOM_c = $(options.ratioDOM[0]);
			$ratioDOM_t = $(options.ratioDOM[1]);
		}


		if(typeof options.optDOMs[0] == "string"){
			$.each(options.optDOMs,function(index,optDOM){
				optDOMs.push({
					selector:optDOM,
					style:options.style
				});
			});
		}else {
			optDOMs = options.optDOMs;
		}

		$.each(optDOMs,function(i,optDOM){
			var partialObj = new PartialSlide(optDOM,options);
			partialObjs.push(partialObj);
		});

		$indexList.eq(0).addClass('current');

		$indexList.click(function(){
			portfolioObj.clickIndexEvent($(this).index());
		});
		$prevDOM.click(function(){
			portfolioObj.prevSlideEvent();
		});
		$nextDOM.click(function(){
			portfolioObj.nextSlideEvent();
		});

		//	return portfolioObj
		var portfolioObj = new Portfolio();
		portfolioObj.partialObjs = partialObjs;
		portfolioObj.indexDOM = $indexDOM;
		portfolioObj.indexList = $indexList;
		portfolioObj.prevDOM = $prevDOM;
		portfolioObj.nextDOM = $nextDOM;
		portfolioObj.ratioDOM_c = $ratioDOM_c;

		portfolioObj.interval = options.interval;
		portfolioObj.speed = options.speed;
		portfolioObj.autoScrollObj = null;
		portfolioObj.scrollSameTend = options.scrollSameTend;
		portfolioObj.moveIndex = 0;
		portfolioObj.maxTime = partialObjs[0].toSlideList.length;
		
		if(options.autoScroll) {
			portfolioObj.startAutoScroll();
		}

		if($ratioDOM_t){
			$ratioDOM_t.text(portfolioObj.maxTime);
		}
		
		if($ratioDOM_c){
			$ratioDOM_c.text(1);
		}
		
		return portfolioObj;
	}
	
	
	function Portfolio(){

	}
	
	$.extend(Portfolio.prototype, {
		startAutoScroll:function(){
			var that = this;
			function auto(){
				that.autoScrollObj = setTimeout(function(){
					that.nextSlideEvent(true);
					auto();
				}, that.interval);
			}
			auto(); // 用setTimeout，在chrome里，使用setInterval会有bug：只执行一次
		},
		stopAutoScroll:function(){
			this.autoScrollObj && clearInterval(this.autoScrollObj);
		},
		animation:function(index, speed){
			$.each(this.partialObjs, function(i,partialObj){
				partialObj.animation(index, speed);
			});
			if(this.ratioDOM_c){
				this.ratioDOM_c.text(index + 1);
			}
			this.indexList.removeClass('current').eq(index).addClass('current');
		},
		reiteractList:function(direction){
			$.each(this.partialObjs, function(i,partialObj){
				if(direction == "down"){
					partialObj.wrapper.children(":first").appendTo(partialObj.wrapper);
				}else {
					partialObj.wrapper.children(":last").prependTo(partialObj.wrapper);
				}
			});
		},
		//events
		clickIndexEvent:function(index){
			this.animation(index);
			this.stopAutoScroll();
		},
		prevSlideEvent:function(){
			if(this.scrollSameTend){
				this.reiteractList("up");
				this.animation(1,1);
				this.animation(0);
			}else {
				this.moveIndex--;
				if(this.moveIndex < 0){
					this.moveIndex = this.maxTime-1;
				}
				this.animation(this.moveIndex);
			}
			this.stopAutoScroll();
		},
		nextSlideEvent:function(isAuto){
			var that = this;
			if(this.scrollSameTend){
				this.animation(1);
				setTimeout(function(){
					that.reiteractList("down");
					that.animation(0,1);
				},this.speed-100);
			}else {

				this.moveIndex++;
				if(this.moveIndex == this.maxTime){
					this.moveIndex = 0;
				}
				this.animation(this.moveIndex);
			}
			if(!isAuto) this.stopAutoScroll();
		}
	});
	
	
	function PartialSlide(optDOM,options){
		this.wrapper = null;
		this.container = $(optDOM.selector);
		this.toSlideList = this.container.children();
		
		this.style = optDOM.style;
		this.speed = options.speed;
		this.animation = null;
		
		this.initilize();
	}
	
	$.extend(PartialSlide.prototype, {
		initilize:function(){
			this.animation = this.initilizeDOM(this.style);
		},
		initilizeDOM:function(){
			var that = this;
			
			that.container.css("overflow","hidden");
			if(that.container.css("position") == "static") that.container.css("position","relative");
			that.toSlideList.css({
				width:'100%',
				height:'100%',
				overflow:"hidden"
			});
			switch(that.style){
				case "normal":
					initNormalDOM();
					return animationForNormal;
				case "switch":
					initSwitchDOM();
					return animationForSwitch;
					break;
				case "slide-y":
					initSlideDOM("y");
					return animationForSlideY;
					break;
				case "slide-x":
					initSlideDOM("x");
					return animationForSlideX;
					break;
				case "fade":
					initNormalDOM();
					return animationForFade;
					break;
			}
			
			function initNormalDOM(){
				that.toSlideList.css("position", "absolute");
				that.toSlideList.hide().eq(0).show();
			}
			
			function initSwitchDOM(){
				that.toSlideList.css("display", "block");
				that.toSlideList.hide().eq(0).show();
			}
			
			function initSlideDOM(tend){
				// slide的时候，每个元素的宽高不能变，需要固定下来
				that.toSlideList.css({
					width:that.container.width(),
		      height:that.container.height()
				});

				// 用于滚动的包裹元素
				that.wrapper = $("<div></div>");
				that.wrapper.css("position","absolute");
				if(tend == "x"){
					that.toSlideList.css("float","left");
					that.wrapper.css({
						"width":that.toSlideList.eq(0).outerWidth()*that.toSlideList.length,
						"height":that.toSlideList.eq(0).outerHeight()
					});
				}else if(tend == "y") {
					that.toSlideList.css("display","block");
					that.wrapper.css({
						"width":that.toSlideList.eq(0).outerWidth(),
						"height":that.toSlideList.eq(0).outerHeight()*that.toSlideList.length
					});
				}
				that.wrapper.append(that.toSlideList).appendTo(that.container);
			}
			
			function animationForNormal(index){
				this.toSlideList.hide().eq(index).show();
			}
			
			function animationForSwitch(index,speed){
				this.container.children(":visible").stop(true,true).slideUp(speed || this.speed).end().children().eq(index).stop(true,true).slideDown(speed || this.speed);
			}
			
			function animationForFade(index,speed){
				this.toSlideList.hide().eq(index).fadeIn(speed || this.speed);
			}
			
			function animationForSlideX(index,speed){
				var pos = -index*this.container.width();
				this.wrapper.stop(true,true).animate({"left":pos},speed || this.speed);
			}
			
			function animationForSlideY(index,speed){
				var pos = -index*this.container.height();
				this.wrapper.stop(true,true).animate({"top":pos},speed || this.speed);
			}
		}
	});
	
	$.extend({
		nbdslide:slide
	});
	
})(jQuery);
