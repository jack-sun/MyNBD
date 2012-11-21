var _layoutOpts = {
	currentColWidth:null,
	addElement: null,
	addSection:null,
	elementDOM: "<li id='{elementId}' style='display:none' class='element {elementType}'><span class='editElement'><a href='javascript:void(0)'><b class='actionIcon edit'></b>编辑</a></span>{elementTitle}<div class='clear'></div></li>",
	
	//	layout
	//---------------------------------------------
	updateLayout: function(page_pos){
		$.ajax({
			url: _all_urls[page_pos].update_layout_url,
			type: "POST",
			data: {
				"layout": JSON.stringify(_layoutOpts.getLayoutData(page_pos))
			},
			dataType: "html",
			success: function(msg){
			}
		});
	},
	getLayoutData: function(page_pos){
		var data = [];
		var s = "#tabs-" + page_pos + " .section"
		$(s).each(function(index, elem){
			var section = {};
			section.section_code = $(elem).attr("section_id");
			section.elements = [];
			$(".sortable", elem).each(function(index, sort){
				var items = [];
				$(".element", sort).each(function(index, elem){
					items.push(parseInt($(elem).attr("id")));
				});
				section.elements.push(items);
			});
			data.push(section);
		});
		//console.log(data);
		return data;
	},
	bindSortable:function(){
		$(".sortable").sortable({
			//axis:'y',
			opacity: '0.4',
			tolerance: 'pointer',
			cursor: 'move',
			placeholder: "placeholder",
			connectWith: ".sortable",
			items: ".element",
			receive: function(event, ui){
			},
			sort: function(event, ui){ //在sort开始之后，修改options中的items是无效的。
				ui.placeholder.prev(".addElement").before(ui.placeholder);
			}
		});
	},
	
	//	callback from child window
	//---------------------------------------------
	addElementcallback: function(elementID, elementType, elementTitle, page_pos){
		$(_layoutOpts.elementDOM.replace("{elementId}", elementID).replace("{elementTitle}", elementTitle).replace("{elementType}", elementType)).insertBefore($(_layoutOpts.addElement)).slideDown("slow");
		_layoutOpts.updateLayout(page_pos);
	},
	updateElementcallback: function(elementID, elementTitle){
		var elementItem  = $("#" + elementID);
		var originColor = elementItem.css("backgroundColor");
		elementItem.animate({backgroundColor:'#67aaf0'},function(){$(this).animate({backgroundColor:originColor})}).find(".elementTitle").text(elementTitle);
	},
	removeElementcallback: function(elementID, page_pos){
		$("#" + elementID).animate({height:0,opacity:0},"slow",function(){
			$(this).remove();
			_layoutOpts.updateLayout(page_pos);
		})
	},
	addSectioncallback:function(section_code){
		$.ajax({
			url: _all_urls["featch_section_template_url"],
			type: "POST",
			data: {
				"section_code": section_code
			},
			dataType: "html",
			success: function(sectionTemplate){
				$(_layoutOpts.addSection).before(sectionTemplate);
				_layoutOpts.bindSortable();
			}
		});
	}
}
