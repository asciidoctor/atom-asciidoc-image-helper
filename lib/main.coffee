{CompositeDisposable, File} = require 'atom'
clipboard = require 'clipboard'
path = require 'path'
imageFactory = require './image-factory'

module.exports =

  # Configuration Schema
  config:
    imagesFolder:
      description: '''
        The folder name that image files should be pasted into.

        The default is an `images` folder in the same folder as the asciidoc file.
        For subfolders, enter something like `assets/images` without the leading or trailing foreward slash.
        '''
      type: 'string'
      default: 'images'
      order: 1
    enableUrlSupport:
      description: '''
        Enabled clipboard tracking for image URL.

        Use with caution: any valid paths contains in the clipboard will be converted to links.
        Support: png,
        '''
      type: 'boolean'
      default: false
      order: 2
    imageExtensions:
      description: '''
        Related to clipboard tracking for file URL.

        Specify image file extensions to be converted to links.
        '''
      type: 'array'
      default: ['.png', '.jpg', '.jpeg', '.bmp']
      items:
        type: 'string'
      order: 3
    # customFilenames:
    #   description: 'Enable prompt for custom string to be added into the filename on paste action into document.'
    #   type: 'boolean'
    #   default: false

  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable()

    @subscriptions.add atom.commands.onWillDispatch (event) =>
      if event.type is "core:paste"

        activeEditor = atom.workspace.getActiveTextEditor()
        return unless activeEditor

        grammar = activeEditor.getGrammar()
        return unless grammar and grammar.scopeName is 'source.asciidoc'

        if @isImage clipboard
          event.stopImmediatePropagation()
          imageFactory.createImage activeEditor, clipboard
          false
        else if atom.config.get 'asciidoc-image-helper.enableUrlSupport'
          clipboardText = clipboard.readText().split("file:///").join("").replace /^\"|\"$/g, ""

          if @isImageUrl clipboardText
            event.stopImmediatePropagation()
            imageFactory.copyImage activeEditor, clipboardText
            false

  isImage: (clipboard) ->
    not clipboard.readImage().isEmpty()

  isImageUrl: (clipboardText) ->
    imageExtensions = atom.config.get 'asciidoc-image-helper.imageExtensions'
    clipboardText?.length? and path.extname(clipboardText) in imageExtensions and new File(clipboardText).existsSync()

  deactivate: ->
    @subscriptions?.dispose()

  serialize: ->
