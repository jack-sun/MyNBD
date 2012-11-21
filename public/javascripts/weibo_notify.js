$(function(){
	window.setInterval(function(){
		check_status();
	 }, 60000);
	
	$("#weiboNotifyWrapper").click(function(e){
		var t = e.target;
		if($(t).is('a')){
			$(this).hide();
			$("#newWeiboLoading").show();
		}
	});

	var check_status = function(){
		$.get("/users/check_status", function(data){
			var str = "";
			$("#weiboNotify").html("<a data-remote='true' href='/weibos/fetch_new' >有新的微博，点击查看</a>");
			data = $.parseJSON(data);
			if (data.new_atme_weibos_count > 0) {
				str += "<a href='/" + data.nickname + "/atme'>有" + data.new_atme_weibos_count + "个新微博提到我</a><br>";
			};
			if (data.new_atme_comments_count > 0) {
				str += "<a href='/" + data.nickname + "/atme_comments'>有" + data.new_atme_comments_count + "个新评论提到我</a><br>";
			};
			if (data.new_comments_count > 0) {
				str += "<a href='/" + data.nickname + "/comments_to_me'>有" + data.new_comments_count + "个新评论</a><br>";
			};
			if (data.new_followers_count > 0) {
				str += "<a href='/" + data.nickname + "/fans'>有" + data.new_followers_count + "个新粉丝</a></br>";
			};
			if (data.new_weibos_count > 0) {
				$("#weiboNotifyWrapper").slideDown('fast');
			};
			if (str) {
				if ($("#notify").find("a").length == 0){
					$("#notify").fixedPosition({
						top: 2,
						right: 0,
						start:30,
						referenceObj: $(".innerCenter")
					});
				}
				$("#notify").html(str).show();
			}
		});
	};

});
