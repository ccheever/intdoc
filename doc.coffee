##
# Extracts documentation for a function
#
##

esprima = require 'esprima'
objects = require 'lodash-node/modern/objects'

endsWith = (str, suffix) ->
  """Checks whether a given string ends with `suffix`"""
  str.indexOf(suffix, str.length - suffix.length) isnt -1


doc = (val) ->
  """Extracts as much documentation information from an object as possible

    The docstring is determined by looking at `.__doc__` and if that is 
    set, using that.
    If that is not found, then `.constructor.__doc__` is examined, and if 
    that is not found, then the 

    If none of those are set, then in a function definition, 
    if the first token inside the function body is a string literal,
    then that is the docstring; if the first token is anything else,
    then the function is not considered to have a docstring.

    """
  
  if objects.isUndefined val
    return { type: "undefined" }
  if objects.isNull val
    return { type: "null" }
  

  isNative = false
  isFibrous = false
  ty = typeof val
  if ty?
    ty = ty.charAt(0).toUpperCase() + ty.slice(1)

  docString = null
  if val.__doc__?
      docString = val.__doc__.toString()
    else
      if val.constructor? and val.constructor.__doc__?
        docString = val.constructor.__doc__.toString()

  #if typeof val is 'function'
  if objects.isFunction val
    # We need to wrap the function definition in parens so that the parser
    # treats it as an expression rather than a named function def
    if objects.isFunction val.__fibrousFn__
      ty = "fibrous Function"
      val = val.__fibrousFn__
      isFibrous = true

    s = val.toString()
    if endsWith s, ") { [native code] }"
      isNative = true
      docString = "[native code]"
      s = s.replace "[native code]", ""

    parseTree = esprima.parse "(#{ s })"

    # Extract the list of named parameters
    params = (x.name for x in parseTree.body[0].expression.params)

    functionBodyParseTree = parseTree.body[0].expression.body.body

    if not docString?
      # Use the first expression in the function body iff it is
      # a string literal; or else, there is no doc string for this function
      if functionBodyParseTree.length
        first = functionBodyParseTree[0]
        if first.type == "ExpressionStatement" and first.expression.type == "Literal"
          docString = first.expression.value
  else
     if val.__name__?
    name = val.__name__
  else
    name = val.name

  if objects.isArray val
    ty = "Array"
  else

  info = { params: params, doc: docString, name: name, type: ty }
  if isNative
    info.nativeCode = isNative

  if isFibrous
    info.isFibrous = isFibrous

  if objects.isFunction val
    info.code = val.toString()

  info

module.exports = doc
