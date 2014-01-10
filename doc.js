// Generated by CoffeeScript 1.6.3
(function() {
  var doc, endsWith, esprima, objects;

  esprima = require('esprima');

  objects = require('lodash-node/modern/objects');

  endsWith = function(str, suffix) {
    "Checks whether a given string ends with `suffix`";
    return str.indexOf(suffix, str.length - suffix.length) !== -1;
  };

  doc = function(fn) {
    "Extracts the docstring and named params for a function if applicable\n\nThe docstring is determined by looking at .__doc__ and if that is \nset, using that. If that \nIn a function definition, if the first token inside the function\nbody is a string literal, then that is the docstring; if the first\ntoken is anything else, then the function is not considered to have\na docstring\n";
    var docString, first, functionBodyParseTree, info, isNative, name, params, parseTree, s, ty, x;
    if (objects.isUndefined(fn)) {
      return {
        type: "undefined"
      };
    }
    if (objects.isNull(fn)) {
      return {
        type: "null"
      };
    }
    isNative = false;
    if (objects.isFunction(fn)) {
      s = fn.toString();
      if (endsWith(s, ") { [native code] }")) {
        isNative = true;
        docString = "[native code]";
        s = s.replace("[native code]", "");
      }
      parseTree = esprima.parse("(" + s + ")");
      params = (function() {
        var _i, _len, _ref, _results;
        _ref = parseTree.body[0].expression.params;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          x = _ref[_i];
          _results.push(x.name);
        }
        return _results;
      })();
      functionBodyParseTree = parseTree.body[0].expression.body.body;
      if (fn.__doc__ != null) {
        docString = fn.__doc__.toString();
      } else {
        if (docString == null) {
          docString = null;
        }
        if (functionBodyParseTree.length) {
          first = functionBodyParseTree[0];
          if (first.type === "ExpressionStatement" && first.expression.type === "Literal") {
            docString = first.expression.value;
          }
        }
      }
    } else {
      if (fn.__doc__ != null) {
        docString = fn.__doc__.toString();
      } else {
        docString = null;
      }
    }
    if (fn.__name__ != null) {
      name = fn.__name__;
    } else {
      name = fn.name;
    }
    ty = typeof fn;
    if (objects.isArray(fn)) {
      ty = "Array";
    } else {

    }
    info = {
      params: params,
      doc: docString,
      name: name,
      type: ty
    };
    if (isNative) {
      info.nativeCode = isNative;
    }
    if (objects.isFunction(fn)) {
      info.code = fn.toString();
    }
    return info;
  };

  module.exports = doc;

}).call(this);
