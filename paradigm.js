(function() {
  var $_call, $_callback, Model, _i, _len, _ref, anon_el, anon_els, anon_func, anon_funcs, routed_functions;
  var __slice = Array.prototype.slice, __hasProp = Object.prototype.hasOwnProperty;
  Model = function(_arg) {
    var options;
    this.id = _arg;
    this.url = ("$db/" + (this.collection) + "/" + (this.id));
    options = {
      url: this.url,
      headers: {
        'Content-Type': "application/json"
      },
      urlEncoded: false,
      emulation: false
    };
    this.request = new Request.JSON(options);
    return this;
  };
  Model.prototype.set = function(fields, callback) {
    this.request.onSuccess = callback;
    this.request.put(JSON.stringify(fields));
    return console.log(this.request);
  };
  Model.prototype.get = function(callback) {
    this.request.onSuccess = callback;
    return this.request.get();
  };
  $_call = function(function_name) {
    var args, kwargs, request;
    args = __slice.call(arguments, 1);
    request = new Request.JSON({
      url: '/$/' + function_name.slice(1),
      onSuccess: $_callback
    });
    if (args.length > 0) {
      kwargs = args.pop();
      if (typeof kwargs.callback === "function") {
        kwargs._callback = anon_func(kwargs.callback);
      } else if (typeof kwargs.callback === "string") {
        kwargs._callback = kwargs.callback;
      }
      delete kwargs.callback;
      if (typeof kwargs.where === "object") {
        kwargs._where = kwargs.where.id || anon_el(kwargs.where);
      } else if (typeof kwargs.where === "string") {
        kwargs._where = kwargs.where;
      }
      delete kwargs.where;
      if (args.length > 0) {
        kwargs._fargs = args;
      }
      return request.send(JSON.stringify(kwargs));
    } else {
      return request.get();
    }
    return request;
  };
  anon_funcs = {
    count: 0
  };
  anon_func = function(f) {
    var _i, _ref, fname, k;
    _ref = anon_funcs;
    for (fname in _ref) {
      if (!__hasProp.call(_ref, fname)) continue;
      _i = _ref[fname];
      if (anon_funcs[fname] === null || anon_funcs[fname] === f) {
        k = fname;
        break;
      }
    }
    if (!k) {
      k = ("_F" + ((anon_funcs.count += 1).toString(36)));
    }
    anon_funcs[k] = (window[k] = f);
    return k;
  };
  anon_els = 0;
  anon_el = function(el) {
    var k;
    k = ("_E" + ((e += 1).toString(36)));
    el.id = k;
    return k;
  };
  $_callback = function(obj, text) {
    if (obj._callback) {
      window[obj._callback].bind(obj)(obj._data);
      return obj._callback in anon_funcs ? (anon_funcs[obj._callback] = null) : null;
    }
  };
  routed_functions = ["$routed_functions", "$get_sessid", "$get_current_user", "$validate_user_email", "$save_new_user"];
  _ref = routed_functions;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    (function() {
      var f = _ref[_i];
      return (window[f] = function() {
        var args;
        args = __slice.call(arguments, 0);
        return $_call.apply(this, [("" + (f))].concat(args));
      });
    })();
  }
}).call(this);
