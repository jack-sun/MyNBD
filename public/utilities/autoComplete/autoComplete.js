/*
* jQuery.autoComplete
* 
* REQUIRE : adjustElement
* 
* author:vgche
* update:2011-11-9
* 
***************************
* API:
* var autoObjForLog = $(".logSpeak textarea").autoComplete(['a','b']);
* 
* DOM attribute:
* autoComplete-disable: Boolean (optional, default is false)
******************************************************/

;if(!$("").autoComplete)
(function($, undefined){
	var DATA = [];
	var TEST_DATA = ["测试姓名12","squall最终幻想","测试姓名","squall最终122幻想","测xsa试姓名","squall最终幻想","测试sdw姓名","squall最终wq幻想"]
	var hiddenDivHTML = '<div style="z-index:-2000;visibility:hidden;position:absolute;top:0px;left:0px;word-wrap:break-word;overflow-x:hidden;overflow-y:auto;"><span class="beforeText"></span><span class="placeholder">1</span><span class="afterText"></span></div>';
	var autoDivHTML = '<div class="autoDiv"><h6>你想@谁?</h6><ul></ul></div>';
	var _autoDiv, _autoUl, _hiddenDiv, _target;
	var _oldElem;
	
	/*---------------------------------------------
		operation of cursor in a textarea
	---------------------------------------------*/
	var _cursor = {
		
		getCursorPos:function(t){
			if (document.selection) {
				t.focus();
				var ds = document.selection;
				var range = null;
				range = ds.createRange();
				var stored_range = range.duplicate();
				stored_range.moveToElementText(t);
				stored_range.setEndPoint("EndToEnd", range);
				var text = stored_range.text.replace(/\r/g,'');	//ie中的textarea中打回车会生成\r \n两个字符
				t.selectionStart = text.length - range.text.length;
				t.selectionEnd = t.selectionStart + range.text.length;
				return t.selectionStart;
			} else return t.selectionStart;
		},
		
		addTxt:function (t, txt){
			var val = t.value;
			var wrap = wrap || '' ;
			if(document.selection){
				document.selection.createRange().text = txt;  
			} else {
				var cp = t.selectionStart;
				var ubbLength = t.value.length;
				t.value = t.value.slice(0,t.selectionStart) + txt + t.value.slice(t.selectionStart, ubbLength);
				this.setCursorPosition(t, cp + txt.length); 
			};
		},
		
		setCursorPosition:function(t, p){
			var n = p == 'end' ? t.value.length : p;
			$t = $(t);
			if(document.selection){
				var range = t.createTextRange();
				range.moveEnd('character', -$t.val().length);         
				range.moveEnd('character', n);
				range.moveStart('character', n);
				range.select();
			}else{
				t.setSelectionRange(n,n);
				t.focus();
			}
		},
		
		del:function(t, n){
			$t = $(t);
			var p = this.getCursorPos(t);
			$t.val($t.val().slice(0,p - n) + $t.val().slice(p));
			this.setCursorPosition(t ,p - n);
		}

	};
	
	/*---------------------------------------------
		operation of autotips's list
	---------------------------------------------*/
	var _listOpt = {
		
		curIndex:0,
		listLength:0,
		
		//	manage creation or visible of list
		//---------------------------------------
		showList:function(mode,keyword){
			var that = this;
			
			//	clean list
			that.curIndex = 0;
			_autoUl.children().remove();
			
			//	bind event
			_target.unbind("keydown");	// for jquery which version > 1.3.2
			_target.keydown(that.selectList);
			
			//	match keyword
			$.each(DATA, function(i,v){
				if(v.indexOf(keyword) != -1){
					var itemHTML = v.replace(keyword, "<strong>"+keyword+"</strong>");
					var listItem = $('<li><a href="javascript:void(0)">'+itemHTML+'</a></li>');
					listItem.data("result",v);
					listItem.data("keyword",keyword);
					_autoUl.append(listItem);
				}
			});
			that.listLength = _autoUl.children().length;
			if(that.listLength == 0){
				var tempItem = $("<li><a href='javascript:void(0)'><strong>"+ (keyword.length <= 10 ? keyword : keyword.slice(0,10)+"..") +"</strong></a></li>");
				tempItem.data("result",keyword);
				tempItem.data("keyword",keyword);
				_autoUl.append(tempItem);
				that.listLength++;
			}
			_autoUl.children(":first").addClass("highlight");
			_autoDiv.show();
		},
		
		hideList:function(){
			_target.unbind("keydown");
			_autoDiv.hide();
		},
		
		vertifyKey:function(keycode){
			return (keycode == 38 || keycode == 40 || keycode == 13 || keycode == 9) && _autoDiv.is(":visible");
		},
		
		//	for keydown event
		//	keydown event can active default event
		//	so we must prohabit it at this step
		//---------------------------------------
		selectList:function(e){
			var keycode = e.keyCode;
			if(_listOpt.vertifyKey(keycode)){
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
				case 9:		//tab
					this.confirm();
					break;
				default:
					break;
			}
		},
		
		keyUpFunc:function(){
			_autoUl.children("li").eq(this.curIndex).removeClass("highlight");
			this.curIndex--;
			if(this.curIndex < 0) this.curIndex = this.listLength-1;
			_autoUl.children("li").eq(this.curIndex).addClass("highlight");
		},

		keyDownFunc:function(){
			_autoUl.children("li").eq(this.curIndex).removeClass("highlight");
			this.curIndex++;
			if(this.curIndex > this.listLength-1) this.curIndex = 0;
			_autoUl.children("li").eq(this.curIndex).addClass("highlight");
		},

		confirm:function(){
			var currentItem = _autoUl.find("li").eq(_listOpt.curIndex),
				value = currentItem.data("result"),
				keyword = currentItem.data("keyword");

			_cursor.del(_target[0], keyword.length);
			_cursor.addTxt(_target[0], value+" ");
			_listOpt.hideList();
			
			//_target will active blur event because of mouseup
			setTimeout(function(){
				_target[0].focus();
			},300);
		},
		
		//	mouse event
		//---------------------------------------
		mouseoverFunc:function(event){
			var target = event.target;
			if($(target).is("a")){
				var currentLi = $(target).closest('li');
				_autoUl.children("li").eq(_listOpt.curIndex).removeClass("highlight");
				currentLi.addClass("highlight");
				_listOpt.curIndex = currentLi.index();
			}
		}
	};
	
	function autoComplete(data){
		if(this.length == 0) return this;
		if(data) DATA = data;
		
		this.css('font-family',"宋体,serif");
		this.each(function(i,area){
			//console.log(!$(area).data("atAutoComplete"));
			if(!$(area).data("atAutoComplete") && !$(this).attr("autoComplete-disable")){
				new AutoOperation($(area));
			}
		});
		
		_target = this.eq(0);
		
		return this;
	}
	
	function AutoOperation(elem){
		var that = this;
		elem = elem.eq(0);
		this.elem = elem;
		this.oldCompare = null;
		
		elem.keyup(function(e){
			if(_listOpt.vertifyKey(e.keyCode)) return false;
			that.refresh();	
		});
		
		elem.click(function(){
			that.refresh();
		});
		
		elem.focus(function(){
			that.initHiddenDIV();
			_target = elem;
		});
		
		elem.blur(function(){
			_listOpt.hideList();
		});
		
		elem.data("atAutoComplete",true);
	}
	
	AutoOperation.init = function(){
		//	hiddenDiv
		_hiddenDiv = $(hiddenDivHTML);
		$(document.body).append(_hiddenDiv);
		_hiddenDiv.css('font-family',"宋体,serif");
		
		//	autoDiv
		_autoDiv = $(autoDivHTML);
		$(document.body).append(_autoDiv);
		
		//	autoUl
		_autoUl = _autoDiv.find("ul");
		_autoUl.bind("mousedown", _listOpt.confirm);
		_autoUl.bind("mouseover", _listOpt.mouseoverFunc);
	}
	$(function(){
		AutoOperation.init();
	});
	
	$.extend(AutoOperation.prototype, {
		
		//	called when focus different input field
		//-------------------------------------------
		initHiddenDIV:function(){
			var elem = this.elem,
				divpos = elem.offset();
				
			_hiddenDiv.css({
				'top':(divpos.top+2),
				'left':divpos.left,
				'width':elem.width(),
				'height':elem.height(),
				'padding':elem.css('paddingTop'),
				'border':elem.css('borderBottomWidth'),
				'font-size':elem.css('fontSize'),
				'line-height':elem.css('lineHeight')
			});
		},
		
		//	called when trigger focus or keyup 
		//	keycode will show up after keyup event
		//-------------------------------------------
		refresh:function(){
			var elem = this.elem,
				keyword, 
				mode,
				val = elem.val(),
				newCompare;
				
			var regObj = /([@\$])([\u4e00-\u9fa5\w]+)$/g,
				cursorVal = val.slice(0,_cursor.getCursorPos(elem[0])),
				matchResult = regObj.exec(cursorVal),
				beforeText,
				afterText;
			
			//elem.focus();
			if(matchResult && matchResult[2]){
				newCompare = regObj.lastIndex-matchResult[0].length;
				mode = matchResult[1];
				keyword = matchResult[2];
				if(newCompare != this.oldCompare || elem[0] != _oldElem){
					
					beforeText = cursorVal.slice(0,-keyword.length?-keyword.length:undefined);
					afterText = val.slice(_cursor.getCursorPos(elem[0])-keyword.length);
					
					formatText2Html(_hiddenDiv.find("span.beforeText"), beforeText);
					formatText2Html(_hiddenDiv.find("span.afterText"), afterText);
					
					_hiddenDiv[0].scrollTop = elem[0].scrollTop;
					_autoDiv.adjustElement(_hiddenDiv.find("span.placeholder"));
					
				}
				this.oldCompare = newCompare;
				_oldElem = elem[0];
				_listOpt.showList(mode,keyword);
			}else {
				_listOpt.hideList();
			}
			
			function formatText2Html(elem,text){
				var htmlTxt = text.replace(/[\r\n]/g,"<br/>").replace(/ /g,"<span class='space'> </span>");
				elem.html(htmlTxt).find("span.space").text(" ");
				return elem;
			}
			
		}
	});
		
	$.fn.extend({
		autoComplete:autoComplete
	});
	
})(jQuery);