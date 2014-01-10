##
# Extracts documentation for a function
#
##

esprima = require 'esprima'
objects = require 'lodash-node/modern/objects'

endsWith = (str, suffix) ->
  """Checks whether a given string ends with `suffix`"""
  str.indexOf(suffix, str.length - suffix.length) isnt -1


doc = (fn) ->
  """Extracts the docstring and named params for a function if applicable

    The docstring is determined by looking at .__doc__ and if that is 
    set, using that. If that 
    In a function definition, if the first token inside the function
    body is a string literal, then that is the docstring; if the first
    token is anything else, then the function is not considered to have
    a docstring

    """
  
  if objects.isUndefined fn
    return { type: "undefined" }
  if objects.isNull fn
    return { type: "null" }

  isNative = false

  #if typeof fn is 'function'
  if objects.isFunction fn
    # We need to wrap the function definition in parens so that the parser
    # treats it as an expression rather than a named function def
    s = fn.toString()
    if endsWith s, ") { [native code] }"
      isNative = true
      docString = "[native code]"
      s = s.replace "[native code]", ""

    parseTree = esprima.parse "(#{ s })"

    # Extract the list of named parameters
    params = (x.name for x in parseTree.body[0].expression.params)

    functionBodyParseTree = parseTree.body[0].expression.body.body

    # If __doc__ is explicitly defined, use that, else infer it from the
    # function's definition
    if fn.__doc__?
      docString = fn.__doc__.toString() # Ensure that we have a string
    else
      # Otherwise, use the first expression in the function body iff it is
      # a string literal; or else, there is no doc string for this function
      docString ?= null
      if functionBodyParseTree.length
        first = functionBodyParseTree[0]
        if first.type == "ExpressionStatement" and first.expression.type == "Literal"
          docString = first.expression.value
  else
    if fn.__doc__?
      docString = fn.__doc__.toString()
    else
      docString = null

  if fn.__name__?
    name = fn.__name__
  else
    name = fn.name

  ty = typeof fn
  if objects.isArray fn
    ty = "Array"
  else

  info = { params: params, doc: docString, name: name, type: ty }
  if isNative
    info.nativeCode = isNative

  if objects.isFunction fn
    info.code = fn.toString()

  info

module.exports = doc
