/*
	jquery plugin 
	用于文章表格tr排序和配稿li排序
	for #sortableBox
*/

$(function(){
	// sortable
    var current_pos, article_id, target_id;
    var isInChildPage = $("#childArticalsWrapper").length === 1;
    var isInTZBPage = $("#body_tzb_form").length === 1;

	$("#sortableBox").sortable({
		axis:'y',
		opacity:'0.4',
		handle:'span.dragHandler',
		tolerance:'pointer',
		cursor:'move',
		placeholder:"dragPlaceHolder",
		create:function(event,ui){
			// 配稿页面
			if(isInChildPage){
				$('.dragHandler').parent().css('position','relative');

			// 文章表格页面
			}else {
				$('.dragHandler').parent().css('position','absolute');
			}
		},
		start:function(event,ui){
			var $placeholder = $(ui.placeholder);
			var $currentItem = $(ui.item);
			current_pos = $currentItem.index() + 1;
			$currentItem.width($placeholder.width());
			if($placeholder.is('tr')){
				var cols = $placeholder.closest('table')[0].rows[0].cells.length;
				$placeholder.append("<td style='background:#fff;border:none;' colspan='"+1+"'></td><td style='background:#fff;' colspan='"+(cols-1)+"'></td>");
			}
		},
		sort:function(event,ui){
		},
		update:function(event,ui){
            //alert("article_id: " + $(ui.item).attr("id").split("_")[1]);
            //alert("move to pos: " + ($(ui.item).index() + 1));
            article_id = $(ui.item).attr("id").split("_")[1];
            var position =  ($(ui.item).index() + 1);
            if(position > current_pos){
              position = position - 1;
            }else{
              position = position + 1;
            }
            if($(ui.item).is("li")){
              var s = "li:nth-child("+position + ")";
              target_id = ui.item.parent().find(s).attr("id").split("_")[1];
              $.get("/console/articles/" + _current_article_id + "/change_children_articles_pos", {moved_id:article_id, target_id:target_id})
            }else{
              var s = "tr:nth-child("+position + ")";
              target_id = ui.item.parent().find(s).attr("id").split("_")[1];
              if(isInTZBPage){
              	$.get("/console/premium/touzibaos/" + _touzibao_id + "/change_pos", {article_id:article_id, target_id:target_id})
              }else {
              	$.get("/console/columns/" + _current_column + "/change_pos", {article_id:article_id, target_id:target_id})
              }
            }
		}
		
	});
	
	$("#sortableBox>tr").mouseenter(function(e){
		$(this).find('span.dragHandler').stop(true,true).show();
	}).mouseleave(function(e){
		$(this).find('span.dragHandler').stop(true,true).hide();
	});

    $("#sortableBox .actionUp").live("click", function(e){
      var tr_id = $(this).closest("tr").attr("id");
      var s = "#" + tr_id;
      target_id = tr_id.split("_")[1];
      $.get("/console/columns/" + _current_column + "/change_pos_to_first", {article_id:target_id}, function(){
        if (window.location.search.length > 0) { 
          $(s).slideUp();
        }else{
          $(s).prependTo($("#sortableBox"));
        };
      })
    });

})
