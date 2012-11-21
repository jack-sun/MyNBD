$(function(){
	
	var $autoDiv = $("#searchQueryBox");
	var $autoUl = $("#searchQueryList");
	var $autoInput = $("#searchWeibo");
	var $searchWeiboBtn = $("#searchWeiboBtn");
	var $searchType = $("#searchType");
	
	var _listOpt = {
		curIndex:0,
		listLength:0,
		
		//	manage creation or visible of list
		//---------------------------------------
		showList:function(keyword){
			var that = this;
			that.curIndex = 0;
			
			//	clear
			if(keyword.length>=8){
				keyword = keyword.slice(0,8) + "...";
			}
			$autoUl.find("strong").text(keyword);
			
			//	match keyword
			that.listLength = $autoUl.children().length;
			$autoUl.children().removeClass().eq(0).addClass("highlight");
			$autoDiv.show();
		},
		
		hideList:function(){
			$autoDiv.hide();
		},
		
		
		//	for keydown event
		//	keydown event can active default event
		//	so we must prohabit it at this step
		//---------------------------------------
		selectList:function(e){
			var keycode = e.keyCode;
			if($autoDiv.is(":visible") && (keycode == 38 || keycode == 40 || keycode == 13 )){
				_listOpt.selectIndex(keycode);
				return false;
			}
		},
		
		selectIndex:function(code){
			switch(code){
				case 38:	//up
					this.keyUpFunc();
					break;
				case 40:	//down
					this.keyDownFunc();
					break;
				case 13:	//enter
					this.confirm();
					break;
				default:
					break;
			}
		},
		
		keyUpFunc:function(){
			$autoUl.children("li").eq(this.curIndex).removeClass("highlight");
			this.curIndex--;
			if(this.curIndex < 0) this.curIndex = this.listLength-1;
			$autoUl.children("li").eq(this.curIndex).addClass("highlight");
		},

		keyDownFunc:function(){
			$autoUl.children("li").eq(this.curIndex).removeClass("highlight");
			this.curIndex++;
			if(this.curIndex > this.listLength-1) this.curIndex = 0;
			$autoUl.children("li").eq(this.curIndex).addClass("highlight");
		},

		confirm:function(){
			$autoInput.closest("form").submit();
		},
		
		//	mouse event
		//---------------------------------------
		mouseoverFunc:function(event){
			var target = event.target;
			if($(target).is("li")){
				$autoUl.children("li").eq(_listOpt.curIndex).removeClass("highlight");
				$(target).addClass("highlight");
				_listOpt.curIndex = $(target).index();
			}
		}
	};
	
	
	$autoDiv.hide();
	function inputEvent(e){
		var keycode = e.keyCode || 100;
		var keyword = $autoInput.val();
		if(keyword == ""){
			_listOpt.hideList();
		}else {
			if(keycode == 38 || keycode == 40 || keycode == 13 ){
				_listOpt.selectList(e);
			}else{
				_listOpt.showList(keyword);
			}
		}
		return false;
	};
	
	function getTypeValue(){
		if($autoUl.children("li.highlight").index() == 0){
			$searchType.val("weibo");
		}else {
			$searchType.val("user");
		}
		
	}
	$autoInput.closest("form").submit(function(){
		getTypeValue();
	});
	
	$autoInput.keyup(inputEvent);
	$autoDiv.mouseover(_listOpt.mouseoverFunc);
	$autoDiv.mousedown(_listOpt.confirm);
	
	$autoInput.focus(function(){
		inputEvent({});
	}).blur(function(){
		_listOpt.hideList();
	});
	
	$autoInput.closest("form").submit(function(){
		if($autoInput.val() === ""){
			return false;
		}
	});
});
