{CompositeDisposable, File} = require 'atom'
clipboard = require 'clipboard'
path = require 'path'
imageFactory = require './image-factory'

module.exports =

  # Configuration Schema
  config:
    # customFilenames:
    #   type: 'boolean'
    #   default: false
    #   description: 'Enable prompt for custom string to be added into the filename on paste action into document.'
    imagesFolder:
      type: 'string'
      default: 'images'
      description: 'The folder name that image files should be pasted into. The default is an "images" folder in the same folder as the asciidoc file. For subfolders, enter something like "assets/images" without the leading or trailing foreward slash.'

  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable()

    @subscriptions.add atom.commands.onWillDispatch (event) =>
      if event.type is "core:paste"

        activeEditor = atom.workspace.getActiveTextEditor()
        return unless activeEditor

        grammar = activeEditor.getGrammar()
        return unless grammar and grammar.scopeName is 'source.asciidoc'

        clipboardContent = clipboard.readImage()
        return if clipboardContent.isEmpty()

        event.stopImmediatePropagation()

        currentFile = new File activeEditor.getPath()

        @createImage(activeEditor, currentFile, clipboardContent)

        false

  createImage: (activeEditor, currentFile, clipboardContent) ->
    imgbuffer = clipboardContent.toPng()

    imageFileName = imageFactory.createImageName currentFile.getBaseName(), imgbuffer

    imagesFolder = atom.config.get 'asciidoc-image-helper.imagesFolder'

    imageFactory.createDirectory currentFile.getParent().getPath(), imagesFolder
      .then (imagesDirectoryPath) ->
        imageFactory.writeImage path.join(imagesDirectoryPath, imageFileName) , imgbuffer
      .then ->
        activeEditor.insertText "image::#{imageFileName}[]", activeEditor

  deactivate: ->
    @subscriptions?.dispose()

  serialize: ->
