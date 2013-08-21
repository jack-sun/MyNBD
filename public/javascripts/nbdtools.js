/**
 * NBD公共js文件
 * 
 * 主要放置一些常量和比较常用到的函数,添加了一个全局对象_nbd
 */


var _nbd = (function(){
  
  var tools = {};

  /**
   * 一些常量
   */
  tools.domain = (location.href.indexOf("nbd.com.cn") != -1) ? "nbd.com.cn" : "nbd.cn" ;

  // IE
  tools.ie = /*@cc_on!@*/ !1;
  tools.ie6 = tools.ie && /msie 6.0/i.test(navigator.userAgent) && !/msie 7.0/i.test(navigator.userAgent);
  tools.ie7 = tools.ie && !/msie 6.0/i.test(navigator.userAgent) && /msie 7.0/i.test(navigator.userAgent);
  
  /**
   * cursorText {Object}
   * 文本域的相关操作（涉及光标、选择范围等）
   */
  tools.cursorText = {
    
    getCursorPos: function(t){
      if (document.selection) {
        t.focus();
        var ds = document.selection;
        var range = null;
        range = ds.createRange();
        var stored_range = range.duplicate();
        stored_range.moveToElementText(t);
        stored_range.setEndPoint("EndToEnd", range);
        t.selectionStart = stored_range.text.length - range.text.length;
        t.selectionEnd = t.selectionStart + range.text.length;
        return t.selectionStart;
      }
      else 
        return t.selectionStart;
    },
    
    addTxt: function(t, txt){
      var val = t.value;
      var wrap = wrap || '';
      if (document.selection) {
        document.selection.createRange().text = txt;
      }
      else {
        var cp = t.selectionStart;
        var ubbLength = t.value.length;
        t.value = t.value.slice(0, t.selectionStart) + txt + t.value.slice(t.selectionStart, ubbLength);
        this.setCursorPosition(t, cp + txt.length);
      };
    },
    
    setCursorPosition: function(t, p){
      var n = p == 'end' ? t.value.length : p;
      if (document.selection) {
        var range = t.createTextRange();
        range.moveEnd('character', -t.value.length);
        range.moveEnd('character', n);
        range.moveStart('character', n);
        range.select();
      }
      else {
        t.setSelectionRange(n, n);
        t.focus();
      }
    },
    
    selectPart: function(t, s, e){
      if (document.selection) {
        var rng = t.createTextRange();
        rng.moveEnd('character', -t.value.length);
        rng.moveEnd("character",e); 
        rng.moveStart("character",s); 
        rng.select(); 
      }else {
        t.setSelectionRange(s, e);
      }
    },
    
    del: function(t, n){
      var p = this.getCursorPos(t);
      var s = t.scrollTop;
      t.value = t.value.slice(0, p - n) + t.value.slice(p);
      this.setCursorPosition(t, p - n);
    }
  }

  /**
   * restCharNum
   * 计算剩余字数
   * @param tDOM {Node} 待侦测的input
   * @param num {Number} 限制字数
   * @param rDOM {Node} 显示在哪个dom node上
   */
  tools.restCharNum = function(tDOM,num,rDOM){
    var ie = /*@cc_on!@*/ !1;
    var $t = $('#'+tDOM);
    var $r = $('#'+rDOM);
    interact();
    //$t.keyup(interact);
    //(typeof $t[0].oninput == 'object') && ($t[0].oninput = interact);
    if(ie){
      $t[0].attachEvent("onpropertychange",interact); 
    }else {
      $t[0].oninput = interact;
    }
    function interact(){
      var length = $t.val().length;
      if(length > num ) {
        $r.html("已超出<strong class='red'>"+(length-num)+'</strong>个字');
      }else {
        $r.html("还可以输入<strong>"+(num-length)+'</strong>个字');
      }
    }
  }
  
  /**
   * imageReady
   * 获取图片尺寸
   * @param source {Node|String} 可以是image的str或者dom node，必选
   * @param ready {Function} 已获取图片尺寸的回调
   * @param load {Function} 
   * @param error {Function} 获取图片失败的回调
   */
  tools.imageReady = (function () {
    var list = [], intervalId = null,
  
    // 用来执行队列
    tick = function () {
      var i = 0;
      for (; i < list.length; i++) {
        list[i].end ? list.splice(i--, 1) : list[i]();
      };
      !list.length && stop();
    },
  
    // 停止所有定时器队列
    stop = function () {
      clearInterval(intervalId);
      intervalId = null;
    };
  
    return function (source, ready, load, error) {
      var onready, width, height, newWidth, newHeight, img;
      
      if(typeof source == "string"){
        img = new Image();
        img.src = source;
        
      }else if(typeof source == "object") {
        img = source;
      }
      
      // 如果图片被缓存，则直接返回缓存数据
      if (img.complete) {
        ready.call(img);
        load && load.call(img);
        return;
      };
      
      // 经测试，ie浏览器下，在这里也有可能已经得到头部数据了，从判断complete到第一次取宽高值，用了大概6ms。
      // 有可能会导致后面的逻辑判断失误（$todo）
      // 而chrome大概只用了1ms不到.
      width = img.width;
      height = img.height;
  
      // 加载错误后的事件
      img.onerror = function () {
        error && error.call(img);
        onready.end = true;
        img = img.onload = img.onerror = null;
      };
  
      // 图片尺寸就绪
      onready = function () {
        newWidth = img.width;
        newHeight = img.height;
        if (newWidth !== width || newHeight !== height ||
          // 如果图片已经在其他地方加载可使用面积检测
          newWidth * newHeight > 1024
        ) {
          ready.call(img);
          onready.end = true;
        };
      };
      onready();
  
      // 完全加载完毕的事件
      img.onload = function () {
        // onload在定时器时间差范围内可能比onready快
        // 这里进行检查并保证onready优先执行
        !onready.end && onready();
  
        load && load.call(img);
  
        // IE gif动画会循环执行onload，置空onload即可
        img = img.onload = img.onerror = null;
      };
  
      // 加入队列中定期执行
      if (!onready.end) {
        list.push(onready);
        // 无论何时只允许出现一个定时器，减少浏览器性能损耗
        if (intervalId === null) intervalId = setInterval(tick, 40);
      };
    };
  })();
  
  /**
   * parseUrl
   * 解析当前页面的URL，获取参数
   * @return {Object} 参数JSON
   */
  tools.parseUrl = function(){
    var obj = {};
    var url = window.location.href;
    var paramStr = url.split('?')[1];
    if(!paramStr) return obj;
    
    var paramArray = paramStr.split("&");
    
    for(var i = 0;i<paramArray.length;i++){
      var key = paramArray[i].split("=")[0];
      var val = paramArray[i].split("=")[1];
      obj[key] = val;
    }
    return obj;
  }
  
  /**
   * random
   * 获取一定范围内的随机数
   * @param max|min,max {Number} 如果只有一位：0~max;有两位参数：min~max
   * @return {Number} 一个随机数
   */
  tools.random = function(){
    var args = arguments;
    var randomNum;
    if(args.length == 1){
      randomNum = parseInt( Math.random()*(args[0]+1) );
    }else {
      randomNum = parseInt( Math.random()*(args[0]-args[1]-1) ) + args[1];
    }
    return randomNum;
  }

  /**
   * setPlaceholder
   * 设置value占位符
   * @param dom {jqueryArray} 
   */
  tools.setPlaceholder = function(dom, placeholder){
    var grayColor = "#888"
    $(dom).each(function(i, v){
      $(v).data("textColor", $(v).css("color"));
      if($(v).val() == ""){
        $(v).val(placeholder);
        $(v).css("color", grayColor);
      }
    });

    $(dom).focus(function(){
      var input = $(this);
      if(input.val() == placeholder){
        input.val("");
        input.css("color", input.data("textColor"));
      }
    }).blur(function(){
      var input = $(this);
      if(input.val() == ""){
        input.val(placeholder);
        input.css("color", grayColor);
      }
    })
  }

  /**
   * arrayUniq
   * 删除数组中重复的项 对仅包含number和string类型项的数组有效
   * @param arr {Array} 
   * @return {Array}
   */
  tools.arrayUniq = function(arr){
    var len = arr.length;
    var obj = {};
    var a = [];

    if(len < 2){
      return arr;
    }

    for(i = 0;i < len;i++){
      var v = arr[i];
      var cv = 0 + v;
      if(obj[cv] !== 1){
        a.push(v);
        obj[cv] = 1;
      }
    }

    return a;
  }

  /**
   * closeWindow
   * 关闭当前页面(兼容ie、chrome)
   */
  function closeWindow(){
    var browserName=navigator.appName;
    if (browserName=="Netscape"){
      window.open('', '_self', '');
      window.close();
    }
    if (browserName=="Microsoft Internet Explorer") { 
      window.parent.opener = "whocares"; 
      window.parent.close(); 
    }
  }
  tools.closeWindow = closeWindow;
  
  /**
   * banCopy
   * 禁止所有可复制的操作
   */
  function banCopy(){
    function iEsc(){ return false; }
    function iRec(){ return true; }
    function DisableKeys() {
      if(event.ctrlKey || event.shiftKey || event.altKey)  {
        window.event.returnValue=false;
        return iEsc();
      }
    }

    document.ondragstart=iEsc;
    document.onkeydown=DisableKeys;
    document.oncontextmenu=iEsc;
    if (typeof document.onselectstart !="undefined")
      document.onselectstart=iEsc;
    else{
      document.onmousedown=iEsc;
      document.onmouseup=iRec;
    }
    // function DisableRightClick(www_qsyz_net){
    //     if (window.Event){
    //     if (www_qsyz_net.which == 2 || www_qsyz_net.which == 3)
    //     iEsc();}
    //     else
    //     if (event.button == 2 || event.button == 3){
    //     event.cancelBubble = true
    //     event.returnValue = false;
    //     iEsc();}
    // }
  }
  tools.banCopy = banCopy;

  return tools;
})();