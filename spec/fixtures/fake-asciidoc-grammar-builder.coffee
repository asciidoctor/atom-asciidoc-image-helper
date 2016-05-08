path = require 'path'

module.exports =

  createGrammar: ->
    new Promise (resolve, reject) ->
      grammarPath = path.join __dirname, 'asciidoc-fake-grammar.cson'
      atom.grammars.readGrammar grammarPath, (error, grammar) ->
        if error? then reject error else resolve grammar
