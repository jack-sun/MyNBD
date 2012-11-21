var _txtaToInsert;

var _insertImage = function(data) {
		//var inst = $("#newTalkComment textarea").focus().tinymce();
		var inst = _txtaToInsert.focus().tinymce();
		inst.execCommand('mceInsertContent', false, data);
	}

$(function() {
	var circleRequest; // setInterval object
	var askTextarea;
	var askPreFix;
	var popWinForAsk;

	// DOM
	var elemTalksTip = $("#getNewTalksTip");
	var elemNewTalk = $("#newTalkComment");
	var txtaNewTalk = elemNewTalk.find("textarea");
	var elemTalksLoading = $("#newTalksLoading");

	var listGuest = $("#atGuestList")
	var itemsGuest = listGuest.find("li");

	var btnAskPopWin = $("#showLivePopWinBtn");

	var elemLiveTip = $("div.tabs ul li:first .newTip");
	var elemTalkTip = $("div.tabs ul li:last .newTip");


	function openPopwin4Image() {
		var newWindowStatus = "width=700,height=700,top=200,left=" + ($(window).width() - 500) / 2 + ",toolbar=1,status=1,scrollbars=1";
		var newWindowUrl = location.href.indexOf("nbd.com.cn") == -1 ? "http://www.nbd.cn/console/images/upload_images" : "http://www.nbd.com.cn/console/images/upload_images";
		var newWindowUrl = "http://www." + _nbd.domain + "/console/images/upload_images";
		window.open(newWindowUrl, "imagesSelect", newWindowStatus);
		return false;
	}

	var tinymceConfigs = {
		// General options
		theme: "advanced",
		skin: "default",
		plugins: "media",
		media_strict: false,
		language: "zh-cn",
		relative_urls: false,
		convert_urls: false,
		plugins : "paste",
		// Theme options
		theme_advanced_buttons1: "",
		theme_advanced_buttons2: "",
		theme_advanced_buttons3: "",
		theme_advanced_toolbar_location: "top",
		theme_advanced_toolbar_align: "left",
		invalid_elements: "iframe,script",

		// forced_root_block: false,
		// remove_linebreaks : false,
		// force_br_newlines: true,
		// force_p_newlines : false,

		// save_callback: function(element_id, html, body){
		// 	var editHtml = html.replace(/\<\/?p\>/g, "");
		// 	return editHtml;
		// },

		oninit: function() {
			$(".mceToolbar").parent("tr").hide();
		},

		paste_preprocess : function(pl, o) {
		  // remove all tags => plain text
		  o.content = strip_tags( o.content,'<br><p><div><ul><ol><li>' );
		}

		// setup : function(ed) {
		//   ed.onPaste.add(function(ed, e) {
		//        console.debug('Pasted plain text');
		//   });
		// }

	}

	// Strips HTML and PHP tags from a string 
	// returns 1: 'Kevin <b>van</b> <i>Zonneveld</i>'
	// example 2: strip_tags('<p>Kevin <img src="someimage.png" onmouseover="someFunction()">van <i>Zonneveld</i></p>', '<p>');
	// returns 2: '<p>Kevin van Zonneveld</p>'
	// example 3: strip_tags("<a href='http://kevin.vanzonneveld.net'>Kevin van Zonneveld</a>", "<a>");
	// returns 3: '<a href='http://kevin.vanzonneveld.net'>Kevin van Zonneveld</a>'
	// example 4: strip_tags('1 < 5 5 > 1');
	// returns 4: '1 < 5 5 > 1'
	function strip_tags (str, allowed_tags)
	{

	    var key = '', allowed = false;
	    var matches = [];    var allowed_array = [];
	    var allowed_tag = '';
	    var i = 0;
	    var k = '';
	    var html = ''; 
	    var replacer = function (search, replace, str) {
	        return str.split(search).join(replace);
	    };
	    // Build allowes tags associative array
	    if (allowed_tags) {
	        allowed_array = allowed_tags.match(/([a-zA-Z0-9]+)/gi);
	    }
	    str += '';

	    // Match tags
	    matches = str.match(/(<\/?[\S][^>]*>)/gi);
	    // Go through all HTML tags
	    for (key in matches) {
	        if (isNaN(key)) {
	                // IE7 Hack
	            continue;
	        }

	        // Save HTML tag
	        html = matches[key].toString();
	        // Is tag not in allowed list? Remove from str!
	        allowed = false;

	        // Go through all allowed tags
	        for (k in allowed_array) {            // Init
	            allowed_tag = allowed_array[k];
	            i = -1;

	            if (i != 0) { i = html.toLowerCase().indexOf('<'+allowed_tag+'>');}
	            if (i != 0) { i = html.toLowerCase().indexOf('<'+allowed_tag+' ');}
	            if (i != 0) { i = html.toLowerCase().indexOf('</'+allowed_tag)   ;}

	            // Determine
	            if (i == 0) {                allowed = true;
	                break;
	            }
	        }
	        if (!allowed) {
	            str = replacer(html, "", str); // Custom replace. No regexing
	        }
	    }
	    return str;
	}


	$("body").delegate(".insertImgBtn", "click", function(){
		if( $(this).closest("#newTalkComment").length ){
			_txtaToInsert = $("#newTalkComment textarea");
		}else {
			_txtaToInsert = $(this).data("textarea");
		}
		openPopwin4Image();
		return false;
	});


	// $(".logSubmitBtn").click(function(){
	// 	tinyMCE.triggerSave();
	// });

	// edit operation
	// =================================================
	$("body").delegate(".answerBtn", "click", function() {
		$(this).closest("li").find(".answerWrapper").show().find("textarea").focus();
	});

	$("body").delegate(".editBtn", "click", function() {
		var itemTalk = $(this).closest("div.talkItem"),
			weiboId = itemTalk.attr("id").split("_")[1],
			itemContent = $(this).closest("div.itemContent"),
			backContent = itemContent.find(".itemText, .itemBottom"),
			content = itemContent.find(".weiboText").html();

		var newFormDiv = itemContent.find(".editWeiboDiv");

		if(newFormDiv.length){
			newFormDiv.show();
		}else {
			newFormDiv = getEditForm();
			var newTxta = newFormDiv.appendTo(itemContent).show().find("textarea");
			if(_nbd.ie){
				setTimeout(function(){
					newTxta.tinymce(tinymceConfigs);
				}, 10);
			}else {
				newTxta.tinymce(tinymceConfigs);
			}
			
		}

		backContent.hide();
		
		function getEditForm() {
			var div = $("div#editWeiboDiv").clone().attr("id", ""),
				form = div.find("form"),
				txta = form.find("textarea").attr("id", ""),
				btnInerst = form.find(".insertImgBtn");

			txta.val(content);
			btnInerst.data("textarea", txta);

			if (itemTalk.hasClass("comment")) {
				form.find("#talk_type").val("comment");
			} else {
				form.find("#talk_type").val("answer");
			}
			form.attr("action", form.attr("action") + "/" + weiboId);
			div.find("a.cancelEdit").click(function() {
				div.hide();
				backContent.show();
			});
			div.find("a.submitEdit").click(function() {
				form.submit();
				div.hide();
				backContent.show();
			});
			return div;
		}

	});

	// ajax get data
	// =================================================
	elemTalksTip.click(function(e) {
		if ($(e.target).is("a")) {
			$(this).hide();
			requestNewTalks();
			elemTalksLoading.show();
			$.ajax({
				method: "GET",
				url: "/lives/" + _liveData.liveID + "/fetch_new",
				data: {
					timeline: _liveData.last_update_at,
					type: _liveData.onlyQuestion
				}
			});
		}
	});

	if (_liveData.isContinue == "1") {
		requestNewTalks();
	}

	function requestNewTalks() {

		circleRequest = setInterval(function() {
			$.ajax({
				method: "GET",
				url: "/lives/" + _liveData.liveID + "/check_new",
				data: {
					talk_timeline: _liveData.last_talk_update_at,
					question_timeline: _liveData.last_question_update_at
				},
				success: function(data) {
					if (data.talk == -1) {
						clearInterval(circleRequest);
						btnAskPopWin.fadeOut("fast");
						$("#liveStatLabel .articleLabel").removeClass("yellow").addClass("gray").find("b").text("直播已结束");
						return;
					};
					if (data.talk == 1) {
						if (!_liveData.onlyQuestion) {
							elemTalksTip.slideDown();
						} else {
							elemLiveTip.show();
						};
					}
					if (data.question == 1) {
						if (_liveData.onlyQuestion) {
							elemTalksTip.slideDown();
						} else {
							elemTalkTip.show();
						};
					}
				}
			});
		}, 60000);
	}

	// initilize popwin
	// =================================================
	if (itemsGuest.length > 0) {
		popWinForAsk = $.popWin.init({
			title: "直播提问",
			width: 526
		});

		var elemAsk = elemNewTalk.clone().attr("id", "newTalkAsk")
			.find("form").attr("id", "askForm")
			.find("#live_talk_talk_type").val(_liveData.askType)
			.end().end().show();

		elemAsk.find(".speakActions").remove();

		$("<div id='askBox'></div>").appendTo(popWinForAsk.content).append("<p class='toWho'></p>").append(elemAsk);

		$("body").delegate("#askForm", "submit", function() {
			var form = $(this),
				textarea = form.find("textarea"),
				toWho = popWinForAsk.content.find(".toWho").text() + "\r\n",
				value = textarea.val();
			textarea.val(toWho + value);
		});

	}

	// init tinymce after create ask box
	txtaNewTalk.tinymce(tinymceConfigs);

	// select to ask
	// =================================================
	askTextarea = $("#askForm").find("textarea");

	if (itemsGuest.length == 1) {
		askPreFix = $("a", itemsGuest).text() + " : ";
		popWinForAsk.content.find(".toWho").text(askPreFix);
		btnAskPopWin.click(function() {
			popWinForAsk.show();
			_nbd.cursorText.setCursorPosition(askTextarea[0], "end");
		});
	} else if (itemsGuest.length > 0) {
		$("#selectAtGuest").hover(function() {
			listGuest.show();
		}, function() {
			listGuest.hide();
		});

		listGuest.delegate("li", "click", function(e) {
			askPreFix = $(this).find("a").text() + " : ";
			popWinForAsk.content.find(".toWho").text(askPreFix);
			popWinForAsk.show();
			_nbd.cursorText.setCursorPosition(askTextarea[0], "end");
		});
	} else {
		$("#selectAtGuest").hide();
	}

	if (_liveData.isCompere && !_liveData.only_question) elemNewTalk.show();
});