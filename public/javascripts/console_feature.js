$(function(){
	document.domain = _nbd.domain;
	var popWindowStatus = "width=700,height=700,top=100,left=" + (screen.availWidth - 700) / 2 + ",toolbar=1,status=1,scrollbars=1";
	var urls = _all_urls[1];

	// // urledit
	// var $urlInput = $("#feature_slug");
	// var $urlShow = $("#urlShow");

	// // banner
	// var $bannerTextarea = $("#bannerEidtBox textarea");
	// var preBannerValue;

	// // old theme
	// var $themeSelectList = $("#themeSelectList");

	// expand and edit advanced theme
	var btnExpandTheme = $("#expandAdvancedTheme");
	var boxAdvancedTheme  = $("#advancedThemeBox");
	var inputThemeBg = $("#theme_bg");
	var inputBgColor = $("#changeBgColor");
	var selTheme = $("#feature_theme");

	var inputBgImage = $("#changeBgImage");
	var bgPlaceHolder = $("#themeBgImg .imgPlaceholder");
	var btnDelBgImg = $("#delBgImageBtn");
	var imgBgThumb = $("#themeBgThumb");
	var inputRemoveBg = $("#feature_bg_image_attributes_remove_feature");

	// submit form
	var btnPublish = $("#publish_feature");
	var btnUpdate = $("#update_feature");
	var btnDraft = $("#draft_feature");
	var btnPreview = $("#preview_feature");
	var inputPreview  = $("#feature_preview");
	var inputStatus = $("#feature_status");
	var frmFeature = $('#feature_form');


	/*--------------------------------------------------------------------------
	 some init
	 --------------------------------------------------------------------------*/
	_layoutOpts.bindSortable();

	// $("#submitBtn").click(function(){
	// 	_layoutOpts.getLayoutData();
	// });
	
	
	// $(document.body).click(function(event){
	// 	if ($(event.target).closest("#themeSelectFlag").length == 0) {
	// 		$themeSelectList.hide();
	// 	} else {
	// 		$themeSelectList.animate({
	// 			opacity: 'toggle',
	// 			height: 'toggle'
	// 		}, 'fast');
	// 	}
	// });

	/*--------------------------------------------------------------------------
	 expand advanced theme
	 --------------------------------------------------------------------------*/
	btnExpandTheme.toggle(function(){
		$(this).text("收起");
		$(this).css("color", "#888");
		boxAdvancedTheme.toggle();
	}, function(){
		$(this).text("高级选项");
		$(this).css("color", "#3060BF");
		boxAdvancedTheme.toggle();
	});

	inputBgImage.change(function(){
		var arrayPath = $(this).val().split("\\");
		var name = arrayPath[arrayPath.length-1];
		imgBgThumb.hide();
		bgPlaceHolder.text(name).show();
		inputRemoveBg.val("");
		btnDelBgImg.show();
	});

	btnDelBgImg.click(function(){
		imgBgThumb.hide();
		bgPlaceHolder.text("null").show();
		inputBgImage.val("");
		inputRemoveBg.val("1");
		$(this).hide();
	});
	
	/*--------------------------------------------------------------------------
	 page operations
	 --------------------------------------------------------------------------*/
	function myTabs(that){
		var $newTab = that.find('ul li:last a');
		that.find('ul li a').live('click', function(e){
			var target = e.target;
			if ($(target).attr('href').indexOf('#tabs') == -1) 
				return;
			var id = $(target).attr('href').slice(1);
			$(target).closest("li").addClass('current').siblings().removeClass();
			$('#' + id).show().siblings().hide();
			urls = _all_urls[id.split("-")[1]];
			return false;
		});
		$newTab.click(function(){
			$.post(_all_urls["new_page_url"], function(){
				_layoutOpts.bindSortable();
				$(".deletePage").show();
			});
		});
	};
	
	function getLayoutResult(){
		$("div[id^=tabs]").each(function(index){
			layout_data = JSON.stringify(_layoutOpts.getLayoutData(index + 1));
			layout_str = "#feature_feature_pages_attributes_" + index + "_layout"
			$(layout_str).val(layout_data);
		});
	};
	
	myTabs($(".tabs"));
	$("#inputArea").find("div[id^='tabs']").hide().filter(':first').show();



	/*--------------------------------------------------------------------------
	 form submit
	 --------------------------------------------------------------------------*/
	btnPublish.click(function(){
    inputPreview.val(0);
		inputStatus.val(1);
		frmFeature.submit();
	});

	btnUpdate.click(function(){
    inputPreview.val(0);
		frmFeature.submit();
	});
	
	btnDraft.click(function(){
		inputStatus.val(0);
    inputPreview.val(0);
		frmFeature.submit();
	});

  btnPreview.click(function () {
    inputPreview.val(1);
    frmFeature.submit();
  });
	
	frmFeature.submit(function(){
		preSubmit();
		getLayoutResult();
		//return false;
	});
	
	function preSubmit(){
		var themeData = {};
		themeData.theme = selTheme.val();
		themeData.color = inputBgColor.val();
		inputThemeBg.val(JSON.stringify(themeData));
	}


	/*--------------------------------------------------------------------------
	 element and section operations
	 --------------------------------------------------------------------------*/
	function getColWidth(elem){
		_layoutOpts.currentColWidth = $(elem).closest("ul.sortable").attr("col_width");
	}

	$(".addElement").live("click", function(){
		window.open(urls.choose_element_url, "addElement", popWindowStatus);
		_layoutOpts.addElement = this;
		getColWidth(this);
	});
	
	$(".editElement a").live("click", function(){
		var elemID = $(this).closest("li").attr("id");
		window.open(urls.edit_element_url.replace("ELEMENT_ID", elemID), "editElement", popWindowStatus);
		getColWidth(this);
	});
	
	$(".addSection").live("click", function(){
		window.open(urls.choose_section_url, "addSection", popWindowStatus);
		_layoutOpts.addSection = this;
	});
	
	$(".section").live("mouseenter",function(){
		$(this).find(".editSection").show();
	}).live("mouseleave",function(e){
		$(this).find(".editSection").hide();
	});
	
	$(".editSection .actionUp").live("click",function(){
		var target = $(this).closest(".section");
		target.prev('.section').before(target);
		return false;
	});
	
	$(".editSection .actionDown").live("click",function(){
		var target = $(this).closest(".section");
		target.next('.section').after(target);
		return false;
	});
	
	$(".editSection .actionDelete").live("click",function(){
		if(!confirm("是否要删除本区块？")) return;
		var pagePos = $(".tabs .current").index() + 1;
		var ids = [], data;
		$(this).closest(".section").find(".element").each(function(index,elem){
			ids.push($(elem).attr("id"));
		});
		$(this).closest(".section").remove();
		data = {
			url:_all_urls[pagePos]["delete_section_url"],
			type:"POST",
			data:{
				layout:JSON.stringify(_layoutOpts.getLayoutData(pagePos)),
				del_element_ids:ids
			},
			success:function(){
			}
		};
		//console.log(data);
		$.ajax(data);
	});
	
	/*--------------------------------------------------------------------------
	 url operations
	 --------------------------------------------------------------------------*/
	// $urlShow.text($urlInput.val());
	// $("#urlEdit").click(function(){
	// 	toggleUrlBox();
	// 	$urlInput.val($urlShow.text());
	// });
	
	// $("#urlConfirm").click(function(){
	// 	$urlShow.text($urlInput.val());
	// 	toggleUrlBox();
	// });
	
	// $("#urlCancel").click(function(){
	// 	$urlInput.val($urlShow.text());
	// 	toggleUrlBox();
	// });

	// function toggleUrlBox(){
	// 	$("#urlShow").toggle();
	// 	$("#urlEdit").toggle();
	// 	$("#urlEditBox").toggle();
	// }

	/*--------------------------------------------------------------------------
	 banner operations
	 --------------------------------------------------------------------------*/	
	
	$("#bannerEdit").click(function(){
		window.open(_all_urls["edit_banner_url"], "editBanner", popWindowStatus);
	});
	
	//$("#bannerSave").click(function(){
		//toggleBannerBox();
	//});
	
	//$("#bannerCancel").click(function(){
		//$bannerTextarea.val(preBannerValue);
		//toggleBannerBox();
	//});
	
	//function toggleBannerBox(){
		//$("#bannerEidtBox").toggle();
		//$("#bannerEdit").toggle();
	//}
});

