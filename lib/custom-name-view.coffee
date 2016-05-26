{CompositeDisposable, Emitter} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'
path = require 'path'

class CustomNameView extends View

  @content: ({prompt} = {}) ->
    @div class: 'filename-dialog', =>
      @label prompt, 'Type the filename:' , outlet: 'promptText'
      @subview 'miniEditor', new TextEditorView mini: true
      @div class: 'error-message', outlet: 'errorMessage'

  initialize: ({initialImageName} = {}) ->
    @emitter = new Emitter
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add @element,
      'core:confirm': => @onConfirm @miniEditor.getText()
      'core:cancel': => @cancel()
    @miniEditor.on 'blur', => @close() if document.hasFocus()
    @miniEditor.getModel().onDidChange => @showError()
    @miniEditor.getModel().setText initialImageName

  attach: ->
    @panel = atom.workspace.addModalPanel item: this.element
    @miniEditor.focus()
    @miniEditor.getModel().selectAll()

  close: ->
    @subscriptions?.dispose()
    @emitter?.dispose()
    panelToDestroy = @panel
    @panel = null
    panelToDestroy?.destroy()
    atom.workspace.getActivePane().activate()

  onConfirm: (name) ->
    if not not name
      @emitter.emit 'did-confirm', imageName: name
      @close()
    else
      @showError 'Image\'s name must be defined.'

  onDidConfirm: (callback) ->
    @emitter.on 'did-confirm', callback

  cancel: ->
    @close()

  showError: (message = '') ->
    @errorMessage.text(message)
    @flashError() if message

module.exports = CustomNameView
