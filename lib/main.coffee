{CompositeDisposable, File, Emitter} = require 'atom'
clipboard = require 'clipboard'
path = require 'path'
imageFactory = require './image-factory'
CustomNameView = require './custom-name-view'
filenameHelper = require './filename-helper'

module.exports =

  subscriptions: null
  emitter: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @emitter = new Emitter

    successHandler = (imageMarkup) =>
      atom.notifications.addSuccess 'Image inserted and stored.', detail: imageMarkup
      @emitter.emit 'did-image-insert', imageMarkup: imageMarkup

    errorHandler = (error) ->
      atom.notifications.addError error.toString(), detail: error.stack or '', dismissable: true
      console.error error

    @subscriptions.add atom.commands.onWillDispatch (event) =>
      if event.type is 'core:paste'
        activeEditor = atom.workspace.getActiveTextEditor()
        return unless activeEditor

        grammar = activeEditor.getGrammar()
        return unless grammar and grammar.scopeName is 'source.asciidoc'

        # Native image support
        if @isImage()
          @pasteNativeImage event, activeEditor
            .then successHandler
            .catch errorHandler

        # Image URL support
        else if atom.config.get 'asciidoc-image-helper.urlSupport.enable'
          clipboardText = @readClipboardText()

          if @isImageUrl clipboardText
            @pasteImageUrl event, activeEditor, clipboardText
              .then successHandler
              .catch errorHandler

  # Native image support
  pasteNativeImage: (event, activeEditor) ->
    event.stopImmediatePropagation()
    imgbuffer = clipboard.readImage().toPng()

    currentFile = new File activeEditor.getPath()
    imageFileName = filenameHelper.generateImageName path.basename(currentFile.getBaseName()), imgbuffer

    new Promise (resolve, rejet) ->
      if atom.config.get 'asciidoc-image-helper.customFilenames'
        dialog = new CustomNameView initialImageName: imageFileName
        dialog.attach()
        dialog.onDidConfirm (custom) ->
          resolve imageFactory.createImage activeEditor, currentFile, imgbuffer, custom.imageName
      else
        resolve imageFactory.createImage activeEditor, currentFile, imgbuffer, imageFileName

  # Image URL support
  pasteImageUrl: (event, activeEditor, clipboardText) ->
    event.stopImmediatePropagation()
    imageFileName = filenameHelper.cleanImageFilename path.basename clipboardText

    new Promise (resolve, rejet) ->
      if atom.config.get 'asciidoc-image-helper.customFilenames'
        dialog = new CustomNameView initialImageName: imageFileName
        dialog.attach()
        dialog.onDidConfirm (custom) ->
          resolve imageFactory.copyImage activeEditor, clipboardText, custom.imageName
      else
        resolve imageFactory.copyImage activeEditor, clipboardText, imageFileName

  isImage: ->
    not clipboard.readImage().isEmpty()

  isImageUrl: (clipboardText) ->
    imageExtensions = atom.config.get 'asciidoc-image-helper.urlSupport.imageExtensions'
    safeImageExtensions = imageExtensions.map (ext) -> ext.toLowerCase()
    clipboardText?.length? and path.extname(clipboardText)?.toLowerCase() in safeImageExtensions and new File(clipboardText).existsSync()

  readClipboardText: ->
    clipboardText = clipboard.readText()

    # windows specific
    windowsFilePattern = /^file:[\/]{2,3}(.*)$/
    if clipboardText.match windowsFilePattern
      clipboardText = windowsFilePattern.exec(clipboardText)[1]

    # windows specific
    windowsPathPattern = /^\"(.*)\"$/
    if clipboardText.match windowsPathPattern
      clipboardText = windowsPathPattern.exec(clipboardText)[1]

    clipboardText

  onDidInsert: (callback) ->
    @emitter.on 'did-image-insert', callback

  deactivate: ->
    @subscriptions?.dispose()
    @emitter?.dispose()

  serialize: ->
