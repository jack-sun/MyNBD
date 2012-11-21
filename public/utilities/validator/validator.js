(function($){
	
	function validator(){
		if(!$(this).is("form")) return;
		var $form = $(this).eq(0);
		var passed = true;
		$form.addClass("validForm");
		$form.find('input[datavalidtype]').each(function(){
			var type = $(this).attr('datavalidtype');
			var p = {};
			// map type
			if(type == "nickname"){
				p.errorTip = "4-20个字符，一个汉字为两个字符。";
				p.rightTip = "4-20个字符，一个汉字为两个字符。";
				p.vldFunc = function(){
					return (this.input.value.length >= 4 && this.input.value.length <= 20);
				};
			}
			if(type == "mail"){
				p.errorTip = "错误的邮箱。";
				p.rightTip = "";
				p.vldFunc = function(){
					var reg = /^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+((\.[a-zA-Z0-9_-]{2,3}){1,2})$/;
      				return reg.test(this.input.value);
				};
			}
			if(type == "password" || type == "rpassword"){
				p.errorTip = "6-16个字母加数字或字符的组合。";
				p.rightTip = "6-16个字母加数字或字符的组合。";
				p.vldFunc = function(){
					if(this.input.value.length >= 6 && this.input.value.length <= 16) return true;
				};
			}
			p.input = this;
			// bundle event
			//$(this).blur(valid);
			this.valid = valid;
			this.p = p;
		});
		function valid(){
			if(!(this.p.vldFunc && this.p.vldFunc())){
				$(this).addClass("red");
				$(this).siblings(".tip").addClass("redtip").text(this.p.errorTip);
				passed = false;
			}else {
				$(this).removeClass("red");
				$(this).siblings(".tip").removeClass("redtip").text(this.p.rightTip);
			}
		}
		$form.submit(function(){
			passed = true;
			$form.find('input[datavalidtype]').each(function(){
				this.valid();
			})
			//console.log(passed);
			return passed;
		});
	}
	
	$.fn.extend({
		validator:validator
	});
})(jQuery);