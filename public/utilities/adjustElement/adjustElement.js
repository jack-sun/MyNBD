/**********************************************************************************************
 * 名称: jQuery元素对齐某元素
 * 时间: 2011-2-17 15:7:59
 * 版本: v2
 * 
 * 2011-7-12 15:3:54:
 *		元素设置data-offset="x, y", 默认[0, 0], 属性使对齐可以加一定的偏移
 *		元素设置data-adjust-type="force", 默认[view], 属性使强制左/右/上/下对齐[force]或者以显示完全为主要对齐[view](某些情况强制对齐一边浮动元素都不能显示全)
 *
 * API:
 *		$('').adjustElement(target);
 *		$('').adjustElement(target, callback);
 */

;if(!$("").adjustElement)
(function(undef) {
	var $ = jQuery;

	function adjustElement(target, callback){
		var elm = this.eq(0);
		target = $(target).eq(0);

		if(!target.length){
			alert("请指定一个对齐目标！");	//必须有个target
			return elm;
		}

		var  me_width = elm.outerWidth()
			,me_height = elm.outerHeight()
			,offset = [0, 0]
			,tmp

			,t_width = target.outerWidth()
			,t_height = target.outerHeight()
			,t_offset = target.offset()

			,p_width = $(document).width()
			,p_height = $(document).height()

		//得到偏移
		$.each((elm.attr('data-offset')+'').split(/[,\s]+/), function(i, v){
			v -= 0;
			if(!isNaN(v)){
				offset[i] = v;
			}
		});

		//强制左/右/上/下对齐
		if(elm.attr('data-adjust-type') == 'force'){
			//设置水平位置
			if(t_offset.left + offset[0] + me_width > p_width){
				elm.css('left', p_width - me_width - 5);//窗口右边线对齐
			}else{
				elm.css('left', t_offset.left + offset[0]);//target左对齐
			}

			//设置垂直位置
			if(me_height + offset[1] + t_offset.top + t_height > p_height){
				elm.css('top', t_offset.top - me_height -1);//target顶边对齐
			}else{
				elm.css('top', t_offset.top + offset[1] + t_height + 1);//target底边对齐
			}
		
		//以显示完全为主要
		}else{
			//设置水平位置
			if(me_width > p_width){
				elm.css('left', 0);//窗口左边线对齐
			}else if(t_offset.left + offset[0] + me_width > p_width){
				elm.css('left', p_width - me_width - 5);//窗口右边线对齐
			}else{
				elm.css('left', t_offset.left + offset[0]);//target左对齐
			}

			//设置垂直位置
			if(me_height > p_height){
				elm.css('top', 0);//窗口顶边线对齐
			}else if(me_height + offset[1] + t_offset.top + t_height > p_height){
				elm.css('top', p_height - me_height -1);//窗口底边线对齐
			}else{
				elm.css('top', t_offset.top + offset[1] + t_height + 1);//target底边对齐
			}
		}

		//有回调的回调
		$.isFunction(callback) && callback.call(elm);

		return elm;
	}

	//注册到jq原型上
	$.fn.extend({
		adjustElement: adjustElement
	});
	
})();
