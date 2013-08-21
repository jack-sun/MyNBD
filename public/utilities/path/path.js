;if(!$.path)
(function($){
  function Path(href){
    if(typeof href == 'string'){
      this.href = href;
      //$todo
    }else {
      this.href = location.href;
      this.host = location.host;
      this.pathname = location.pathname;
    }
    var queryStr = this.href.split('?')[1];
    if(queryStr){
      this.url = this.href.split('?')[0];
      var cursor = queryStr.split('#')[1];
      if(cursor){
        this.query = queryStr.split('#')[0];
        this.cursor = cursor;
      }else {
        this.query = queryStr;
        this.cursor = '';
      }
      this.init();
    }else {
      this.url = this.href;
      this.query = '';
      this.cursor = '';
      this.data = {};
    }
  }

  Path.prototype.init = function(){
    var query = this.query;
    var params = query.split('&'), data = {};
    if(typeof params === 'object'){
      for(var i in params){
        var param = params[i].split('=')
        var key = param[0];
        var value = param[1];
        data[key] = value;
      }
    }
    this.data = data;
  }

  Path.prototype.get = function(key){
    if(!key) return this.data;
    else return this.data[key];
  }

  Path.prototype.set = function(arg1, arg2){
    if(arguments.length === 1 && typeof arg1 == 'object'){
      this.data = arg1;
    }else {
      this.data[arg1] = arg2;
    }
  }

  Path.prototype.del = function(key){
    delete this.data[key];
  }

  Path.prototype.getQueryStr = function(){
    var arr = [];
    for(var key in this.data){
      var value = this.data[key];
      var param = key + '=' + value;
      arr.push(param);
    }
    return arr.length === 0 ? '' : '?' + arr.join('&');
  }

  Path.prototype.getHref = function(){
    return this.url + this.getQueryStr();
  }

  $.path = Path
})(jQuery);