{View, TextEditorView} = require 'atom-space-pen-views'

class CustomFilenameView extends View
  @content: ->
    @div class: 'custom-filename', =>
      @subview 'filenameText', new TextEditorView(mini: true)
      @div class: 'prompt', "Type custom part of filename:"

  initialize: (serializeState) ->

  @customFilenameView = new CustomFilenameView()
  @modalPanel = atom.workspace.addModalPanel(item: @customFilenameView.element, visible: false)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  customFilename: ->
    console.log 'Custom Filename Box is Checked'
    # Open the Custom Filename View
    @open()
    #console.log 'Opened the Input View'
    # Validate and Return User Input
    atom.commands.onWillDispatch (event) =>
      if event.type is "core:confirm"
        userInput = @confirm()
    @close()
    # Set the customFileString variable to the user input.
    return customFileString = "-#{userInput}"

  open: ->
    #console.log 'Opening Input View'
    return if @modalPanel.isVisible()
    #console.log 'Input View is not Visible'
    @modalPanel.show()
    #console.log 'Show Input View'
    @modalPanel.filenameText.focus()
    #console.log 'Text Input has Focus'

  close: ->
    return unless @modalPanel.isVisible()
    @modalPanel.filenameText.setText('')
    @modalPanel.hide()

  confirm: ->
    #To-Do:
    # - Character or string cleaning/checks if necessary.
    return @modalPanel.filenameText.getText()

  # Tear down any state and detach
  destroy: ->
    @element.remove()

module.exports = new CustomFilenameView
