//navigator
window.__ie = /*@cc_on!@*/ !1;
window.__ie6 = __ie && /msie 6.0/i.test(navigator.userAgent) && !/msie 7.0/i.test(navigator.userAgent);
window.__ie7 = __ie && !/msie 6.0/i.test(navigator.userAgent) && /msie 7.0/i.test(navigator.userAgent);

var _addUplodFile = function(){
  $("div#upload_files").append($("p.upload").first().clone());
  return false;
}

var _popWinForLoading;
function _initLoadingWindow(msg){
  if(!$.popWin) return;
  if(!_popWinForLoading){
    _popWinForLoading = $.popWin.init({
      follow:true,
      title:"请稍候",
      hideCloseBtn:true
    });
    var loading = $("<div class='loading'><span class='msg'>操作正在进行中</span></div>");
    loading.appendTo(_popWinForLoading.content).show();
  }
  if(msg) _popWinForLoading.content.find(".msg").text(msg);
  _popWinForLoading.show();
}

$(document).ready(function(){
  var $navSelectList = $("#navSelectList");
  var $navSelectFlag = $("#navSelectFlag");
  resizePage();
  $("body").show();
  $(window).resize(resizePage);
  $(document).click(function(e){
    if (!$(e.target).closest('#navSelectFlag').length) {
      $navSelectList.hide();
    }
  })


  switch($navSelectFlag.text().length){
    case 6:
      $navSelectFlag.css("fontSize", "15px");
      break;
    default:
      break;
  }
  
  $navSelectFlag.click(function(){
    if (!$navSelectList.is(":animated")) {
      $navSelectList.animate({
        opacity: 'toggle',
        height: 'toggle'
      }, 'fast');
    }
  });

  function resizePage(){
    var windowWidth = $(window).width();
    var wrapperWidth;
    if (windowWidth <= 1000) {
      wrapperWidth = 1000-141;
    } else if (windowWidth <= 1300) {
      wrapperWidth = windowWidth-6-141;
    } else {
      wrapperWidth = 1300-141;
    }
    $('#wrapper').css('width', wrapperWidth);
    $('.innerCenter').css('width', (wrapperWidth+141));
  }
  
  //------------------------------------------------------
  //  articles operations
  //------------------------------------------------------
  
  $(".columnSelector").change(addArticlesToColumn);
  $(".removeFromColumn").click(removeFromColumn);
  $(".deleteArticles").click(deleteArticles);
  $(".banArticles").click(banArticles);
  
  function removeFromColumn(){
    var ids = getSelected();
    if(ids.length == 0) return false;
    if(!confirm("你确定要从此栏目删除吗？")) return false;
    
    var url = "/console/columns/" + _current_column + "/remove_articles"
    $.post(url, {article_ids:ids});
    return false;
  }
  
  function addArticlesToColumn() {
    var ids = getSelected();
    if(ids.length == 0) return false;
    if(!confirm("你确定要添加到此栏目吗？")) return false;
    
    var column_id = $(this).val();
    var url = "/console/columns/" + column_id + "/add_articles"
    $.post(url, {article_ids:ids}, function(){
      window.location.reload();
    });
  }

  function banArticles() {
    var ids = getSelected();
    if(ids.length == 0) return false;
    if(!confirm("你确定要屏蔽这些文章吗？")) return false;
    
    var column_id = $(this).val();
    var url = "/console/articles/ban_by_ids"
    $.post(url, {ids:ids}, function(){
      window.location.reload();
    });
  }
  
  // 报纸管理页面删除文章
  function deleteArticles(){
    var ids = getSelected();
    if(ids.length == 0) return false;
    if(!confirm("你确定要删除选中的文章么？")) return false;
    
    var column_id = $(this).val();
    var url = " /console/articles/remove_articles";
    $.post(url, {article_ids:ids}, function(){
      window.location.reload();
    });
    _initLoadingWindow("正在删除中");
  }
  
  function getSelected(){
    return $("table .subSelect:checked").map(function(){
      return $(this).attr('value')
    }).toArray().join(",");
  }
  
  //------------------------------------------------------
  //  batch operations
  //------------------------------------------------------

    $(".lOpt .banTopics").click(function(){
      var ids = getSelected();
      if(ids.length == 0) return false;
      if(!confirm("确认要屏蔽话题？")) return false;
      var url = "/console/topics/ban_topics"
      $.post(url, {topic_ids:ids}, function(){
        window.location.reload();
      });
    });

    $(".lOpt .delTopics").click(function(){
      var ids = getSelected();
      if(ids.length == 0) return false;
      if(!confirm("确认要删除话题？")) return false;
      var url = "/console/topics/del_topics"
      $.post(url, {topic_ids:ids}, function(){
        window.location.reload();
      });
    });

    $(".lOpt .banComments").click(function(){
      var ids = getSelected();
      if(ids.length == 0) return false;
      if(!confirm("确认要屏蔽评论？")) return false;
      var url = "/console/comments/ban_comments"
      $.post(url, {comment_ids:ids}, function(){
        window.location.reload();
      });
    });

    $(".lOpt .delComments").click(function(){
      var ids = getSelected();
      if(ids.length == 0) return false;
      if(!confirm("确认要删除评论？")) return false;
      var url = "/console/comments/destroy_comments"
      $.post(url, {comment_ids:ids}, function(){
        window.location.reload();
      });
    });

    // $(".lOpt .tzbctReview").click(function(){
    //   console.log(123);
    //   var ids = getSelected();
    //   if(ids.length == 0) return false;
    //   if(!confirm("确认要审核所选任务？")) return false;
    //   var url = "/console/premium/card_tasks/batch_review"
    //   $.post(url, {card_tasks_ids:ids}, function(){
    //     window.location.reload();
    //   });
    //   _initLoadingWindow("正在审核中");
    // });

    // $(".lOpt .tzbctUnreview").click(function(){
    //   var ids = getSelected();
    //   if(ids.length == 0) return false;
    //   if(!confirm("确认要取消所选任务审核？")) return false;
    //   var url = "/console/premium/card_tasks/batch_unreview"
    //   $.post(url, {card_tasks_ids:ids}, function(){
    //     window.location.reload();
    //   });
    //   _initLoadingWindow("正在取消中");
    // });  

  //------------------------------------------------------
  //  table operations
  //------------------------------------------------------
  
    $("#articleTable .actionBanned").live("click", function(e){
      if(!confirm("确定要屏蔽此文章？")) return;
      var tr_id = $(this).closest("tr").attr("id");
      var target_id = tr_id.split("_")[1];
      var s = "#" + tr_id;
      $.post("/console/articles/" + target_id + "/change_status", {status:2});
      _initLoadingWindow("正在屏蔽中");
    });
  
    $("#articleTable .actionPublish").live("click", function(e){
      if(!confirm("确定要发布此文章？")) return;
      var tr_id = $(this).closest("tr").attr("id")
      var target_id = tr_id.split("_")[1];
      var s = "#" + tr_id;
      $.post("/console/articles/" + target_id + "/change_status", {status:1});
      _initLoadingWindow("正在发布中");
    });

    $("#weiboTable .actionBanned").live("click", function(e){
      if(!confirm("确定要屏蔽此weibo？")) return;
      var tr_id = $(this).closest("tr").attr("id");
      var target_id = tr_id.split("_")[1];
      var s = "#" + tr_id;
      $.post("/console/weibos/change_status", {status:2, id:target_id});
      _initLoadingWindow("正在屏蔽中");
    });
  
    $("#weiboTable .actionPublish").live("click", function(e){
      if(!confirm("确定要发布此weibo？")) return;
      var tr_id = $(this).closest("tr").attr("id")
      var target_id = tr_id.split("_")[1];
      var s = "#" + tr_id;
      $.post("/console/weibos/change_status", {status:1,id:target_id});
      _initLoadingWindow("正在发布中");
    });


    $("#KbbDetailTable .actionBanned").live("click", function(e){
      if(!confirm("确定要屏蔽此提名内容？")) return;
      var tr_id = $(this).closest("tr").attr("id");
      var target_id = tr_id.split("_")[1];
      var s = "#" + tr_id;
      $.post("/console/koubeibangs/change_status", {status:2, id:target_id});
      _initLoadingWindow("正在屏蔽中");
    });
  
    $("#KbbDetailTable .actionPublish").live("click", function(e){
      if(!confirm("确定要发布此提名内容？")) return;
      var tr_id = $(this).closest("tr").attr("id")
      var target_id = tr_id.split("_")[1];
      var s = "#" + tr_id;
      $.post("/console/koubeibangs/change_status", {status:1,id:target_id});
      _initLoadingWindow("正在发布中");
    });


    $(".lOpt .banWeibos").click(function (e) {
      if(!confirm("确定要屏蔽选中的微博？")) return;
      _initLoadingWindow("正在屏蔽中");
      $.post("/console/weibos/change_status", {status:2, id:getSelected()});
    
    });

    $(".lOpt .deleteWeibos").click(function (e) {
      if(!confirm("确定要删除选中的微博？")) return;
      _initLoadingWindow("正在删除中");
      $.post("/console/weibos/delete_weibos", {id:getSelected()});
    
    });
  
});
