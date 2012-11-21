function _enableSubmit (currentForm){
	var speak = currentForm.data("speak");
	if(speak.tip.length > 0){
		var popWin = currentForm.closest(".win1-wrap");
		if(popWin.length == 0){
			speak.tip.fadeIn().delay(1000).fadeOut(function(){
				restoreStat();
			});
		}else {
			speak.tip.fadeIn(1000, function(){
				$(this).hide();
				popWin.data("popWin").hide();
				restoreStat();
			});
		}
	}else {
		restoreStat();
	}
	
	function restoreStat(){
		speak.isDisableSubmit = false;
		speak.btn.removeClass("btnDisabled").find("span").text(speak.text);
		speak.textarea.removeClass("disabled");
		currentForm.data("speak",speak);
	}
}

$(function(){
	//评论、转发、发微博 的非空验证
	$("body").delegate(".speakBtn","click",submitEvent);
	$("body").delegate(".speakForm","submit",verifySpeakForm);
	$("body").delegate(".speakForm textarea","keypress",pressToSubmit);
	$("body").delegate(".speakForm textarea","focus",bindAutoComplete);
	$("body").delegate(".speakFlexibleTextarea","keyup",linefeed);
	
	function submitEvent(){
		$(this).parents('form').submit();
	}
	
	function verifySpeakForm(){
		if($(this).data("speak") && $(this).data("speak").isDisableSubmit) return false;
		var speakBtn = $(this).find(".speakBtn");
		var textarea = $(this).find("textarea");
		var value = textarea.val();
		var reg = /^回复\@.*\: /;

		if (!reg.test(value)) { 
			$(this).find("#comment_parent_comment_id").val("");
		};
		if ($.trim(textarea.val()) === "" && $(this).closest(".reTweetForm").length == 0) {
			textarea.stop(true,true).animate({backgroundColor:"#ffe4e4"},"fast").animate({backgroundColor:"auto"},"fast",function(){
				$(this).attr("style","");
			});
			return false;
		}else{
			var currentSpeak = $(this).data("speak") || {
				btn : speakBtn,
				text : speakBtn.find("span").text(),
				textarea : textarea,
				tip : $(this).find(".speakSuccessTip")
			}
			currentSpeak.isDisableSubmit = true;
			$(this).data("speak",currentSpeak);
			
			speakBtn.addClass("btnDisabled").find("span").text("发布中");
			textarea.addClass("disabled");
			return true;
		}
	}
	function pressToSubmit(e){
//		Ctrl + Enter: keyCode == 10 in chrome; keyCode == 13 in opera
//		Enter : keyCode == 13
//		event can work here

//		if(e.ctrlKey && ( e.keyCode==13 || e.keyCode == 10)){
		if( e.keyCode == 10 || (e.ctrlKey && e.keyCode == 13) ){
			$(this).closest("form").submit();
		}
	}
	
	function bindAutoComplete(){
		//$(this).autoComplete && $(this).autoComplete();
	}
	
	function linefeed(e){
		var autoHeight = $(this).height(0).get(0).scrollHeight;
		$(this).css({
			"height":autoHeight
		});
	}
	
});
