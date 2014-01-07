##
# Extracts documentation for a function
#
##

esprima = require 'esprima'

doc = (fn) ->
  """Extracts the docstring and named params for a function if applicable

    The docstring is determined by looking at .__doc__ and if that is 
    set, using that. If that 
    In a function definition, if the first token inside the function
    body is a string literal, then that is the docstring; if the first
    token is anything else, then the function is not considered to have
    a docstring

    """
  
  # We need to wrap the function definition in parens so that the parser
  # treats it as an expression rather than a named function def
  parseTree = esprima.parse "(#{ fn.toString() })"

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
    docString = null
    if functionBodyParseTree.length
      first = functionBodyParseTree[0]
      if first.type == "ExpressionStatement" and first.expression.type == "Literal"
        docString = first.expression.value

  { params: params, doc: docString, name: fn.name }

module.exports = doc
