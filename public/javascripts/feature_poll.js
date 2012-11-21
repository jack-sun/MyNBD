Poll.polls = [];

function Poll(options){
	var that = this;
	// options
	this.pollID = options.pollID;
	this.voteUrl = options.voteUrl;
	this.maxChoiceCount = options.maxChoiceCount;
	this.repeatsVerifyType = options.repeatsVerifyType;
	this.isNeedLogin = options.isNeedLogin;
	this.isMandatory = options.isMandatory;
	
	// some prepare
	this.wrapper = $("#poll_"+this.pollID);
	this.resultBox = $(".pollResultContainer", this.wrapper);
	this.pollList = $(".pollList", this.wrapper);
	this.pollBtn = $(".submitPollBtn", this.wrapper);
	this.captchaInput = $("input.captchaInput", this.wrapper);
  this.authenticityToken = $("input[name='authenticity_token']", this.wrapper).val();
  this.pollForm = $(".captchaForm", this.wrapper);
  this.pollIdsInput = $("input[name='vote_option_ids']", this.wrapper);
	
	Poll.polls[this.pollID] = this;
	
	// events
	this.pollBtn.click(function(){
		that.pollForm.submit();
	});
	this.pollForm.submit($.proxy(this.submitEvent, this));
	this.pollList.delegate("label, :checkbox", "change", $.proxy(this.checkMaxNumber, this));

	// for initilize captcha
	this.captchaInput.one("focus", function(){
		$(".captchaImage", that.wrapper).html("<span style='display:inline;margin:0;' class='loading'><span>正在获取验证码</span></span>");
		$.get(options.captchaUrl);
	});
	
}

$.extend(Poll.prototype, {
	getChosenNum:function(){
		return $(":checked",this.pollList).length;
	},
	getChosenVal:function(){
		return $(":checked",this.pollList).map(function(){
			return $(this).val();
		}).get();
	},
	checkMaxNumber:function(e){
		var ckbox = $(e.currentTarget);
		if(ckbox.is(':radio')) return ;
		if(this.getChosenNum() > this.maxChoiceCount){
			alert("你最多只能投"+this.maxChoiceCount+"项");
			ckbox.attr("checked", false);
		}
	},
    getCapcha:function(id){
      var target = "#captcha_poll_" + id + " input.captchaInput";
      if($(target)){
        return $(target).val();
      }else{
        return "";
      }
    },
	submitEvent:function(){
		var that = this;
		if(this.isNeedLogin){
			if(!_popRegisterBox()){
				return submit();
			}
		}else {
			return submit();
		}
		
		function submit(){

			var ids = that.getChosenVal();
			if(ids.length == 0) {
        alert("请至少选择一项");
				return false;
			}

			if(that.isMandatory && ids.length < that.maxChoiceCount){
				alert("请选择"+ that.maxChoiceCount +"个投票选项");
				return false;
			}

      if ( that.captchaInput.length !== 0 && ( that.captchaInput.val() === "" || that.captchaInput.val() === "请输入验证码" ) ) { 
        alert("请填写验证码");
				return false;
      };

			that.pollIdsInput.val(ids.join(","));

			return true;
		}
	}
});

$(function(){

	$(".pollBox").delegate(".jumpToPollOpt", "click", function(){
		var pollBox = $(this).closest(".pollBox");
		var resultBox = $(".pollResultContainer", pollBox);
		var optBox = $(".pollOpt", pollBox);
		
		optBox.show();
		resultBox.html("");
	});

	$(".pollBox").delegate(".changeCaptchaBtn", "click", function(){
		$(this).closest(".captchaImage").html("<span style='display:inline;margin:0;' class='loading'><span>正在获取验证码</span></span>");
	});

	_nbd.setPlaceholder($("input.captchaInput"), "请输入验证码");

});

