$(document).ready(function(){
	_popRegisterBox = _popRegisterBox || function(){return false};
	//点击“评论”后触发，获取微博的评论列表
	var getReplyRequset = true;
	$("a.weiboComment").live('click',function(){
		if(_popRegisterBox()) return false;
		if(!getReplyRequset) return;
		var weibo_id = this.id.substr(15);
		var comments = $(this).closest(".itemBottom").siblings(".subComments");
		if (comments.length == 0) {
			var bottom = $(this).parents(".itemBottom"),
				loading = bottom.siblings(".loading");
				
			if(loading.length == 0){
				loading = $("<div class='loading'><span>正在加载，请稍后</span></div>");
				loading.insertAfter(bottom).show();
			}else {
				loading.show();
			}
			$.get("/weibos/" + weibo_id + "/comments","",function(){
				loading.hide();
				setTimeout(function(){getReplyRequset = true;},100); //setTimeout for ie6,避免回调函数执行过快导致getReplyRequset永久为false
			});
			getReplyRequset = false;
		} else {
			comments.remove();
		}
		return false;
	});
	
	//点击“转发”后触发
	$(".weiboRetweet").click(function(){
		return !_popRegisterBox();
	});
	
	//点击“回复”后触发
	$('.replyThisWeibo').live('click',function(){
		var value;
		var reg = /^回复\@.*\: /;
		var comments; // 评论列表ul
		var commentTextarea; // 评论输入框
		
		var commentEditBox = $("#newCommentInWeiboPage"); // 微博详情页面的编辑Box，通过此元素判断所在页面
		
		comments = commentEditBox.length == 0 ? $(this).closest('.subComments') : commentEditBox;
		comments.find("#comment_parent_comment_id").attr("value", $(this).closest("li").attr("id").split("_")[2]);
		commentTextarea = comments.find("textarea");
		value = commentTextarea.val();
		
		if(reg.test(value)){
			value = value.replace(reg,'回复@'+$(this).closest('li').find('.nickname').text()+" : ");
		}else {
			value = '回复@'+$(this).closest('li').find('.nickname').text()+" : "+value;
		}
		
		commentTextarea.focus();
		commentTextarea.val(value);
		return false;
	});
	
	//点击“+加关注”后触发
	$(".followManaBtn").click(function(){
		return !_popRegisterBox();
	});
	
	//转发窗口的操作
	$("body").delegate(".expandText","click",function(){
		var content = $(".rtOriginText .content"),
			html = content.data("content");
		$(this).hide();
		content.html(html);
	});
});

