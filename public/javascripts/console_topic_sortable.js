$(function(){
	// sortable
    var current_pos,current_id;
	$( "#sortableBox" ).sortable({
		axis:'y',
		opacity:'0.4',
		handle:'span',
		tolerance:'pointer',
		cursor:'move',
		placeholder:"dragPlaceHolder",
		create:function(event,ui){
			$('.dragHandler').parent().css('position','relative');
		},
		start:function(event,ui){
			var $placeholder = $(ui.placeholder);
			var $currentItem = $(ui.item);
            current_pos = $currentItem.index() + 1;
			$currentItem.width($placeholder.width());
            current_id = $currentItem.attr("id").split("_")[1];
            //console.log(current_id);
			if($placeholder.is('tr')){
				var cols = $placeholder.closest('table')[0].rows[0].cells.length;
				$placeholder.append("<td style='background:#fff;border:none;' colspan='"+1+"'></td><td style='background:#fff;' colspan='"+(cols-1)+"'></td>");
			}
		},
		sort:function(event,ui){
		},
		update:function(event,ui){
            position =  ($(ui.item).index() + 1);
            if(position > current_pos){
              position = position - 1;
            }else{
              position = position + 1;
            }
            if($(ui.item).is("li")){
              s = "li:nth-child("+position + ")";
              target_id = ui.item.parent().find(s).attr("id").split("_")[1];
            $.get("/console/topics/" + current_id + "/change_topic_pos", {target_id:target_id})
            }else{
              s = "tr:nth-child("+position + ")";
              target_id = ui.item.parent().find(s).attr("id").split("_")[1];
            $.get("/console/topics/" + current_id + "/change_topic_pos", {target_id:target_id})
            }
		}
		
	});
	$( "#sortableBox>tr" ).mouseenter(function(e){
		$(this).find('span').stop(true,true).show();
	}).mouseleave(function(e){
		$(this).find('span').stop(true,true).hide();
	});

})
