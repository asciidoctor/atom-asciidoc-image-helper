{CompositeDisposable, File, Emitter} = require 'atom'
clipboard = require 'clipboard'
path = require 'path'
imageFactory = require './image-factory'
customFilenameView = require './custom-filename-view'

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
    appendImagesFolder:
      title: 'Append `imagesFolder` in generated links.'
      description: '''
        image::images/foo-bdb66.png[] # `true` (default)

        image::foo-bdb66.png[] # `false` (You are using the `:imagesdir:` attribute in your document.)
        '''
      type: 'boolean'
      default: true
      order: 2
    enableUrlSupport:
      description: '''
        Enabled clipboard tracking for image URL.

        Use with caution: any valid paths contains in the clipboard will be converted to links.
        Support: png.
        '''
      type: 'boolean'
      default: false
      order: 3
    imageExtensions:
      description: '''
        Related to clipboard tracking for file URL.

        Specify image file extensions to be converted to links.
        '''
      type: 'array'
      default: ['.png', '.jpg', '.jpeg', '.bmp', '.svg', '.gif']
      items:
        type: 'string'
      order: 4
    customFilenames:
      description: 'Enable prompt for custom string to be added into the filename on paste action into document.'
      type: 'boolean'
      default: false

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

        if atom.config.get('asciidoc-image-helper.customFilenames')
          customFileString = customFilenameView.customFilename()
          console.log customFileString
        # To-Do: Pass 'customFileString' UserInput to imageFactories below to include in final filename.

        # Native image support
        if @isImage clipboard
          event.stopImmediatePropagation()
          imageFactory.createImage activeEditor, clipboard
            .then successHandler
            .catch errorHandler

        # Image URL support
        else if atom.config.get 'asciidoc-image-helper.enableUrlSupport'
          clipboardText = clipboard.readText().split(/file:[\/]{2,3}/).join('').replace /^\"|\"$/g, ''

          if @isImageUrl clipboardText
            event.stopImmediatePropagation()
            imageFactory.copyImage activeEditor, clipboardText
              .then successHandler
              .catch errorHandler

  isImage: (clipboard) ->
    not clipboard.readImage().isEmpty()

  isImageUrl: (clipboardText) ->
    imageExtensions = atom.config.get 'asciidoc-image-helper.imageExtensions'
    clipboardText?.length? and path.extname(clipboardText) in imageExtensions and new File(clipboardText).existsSync()

  onDidInsert: (callback) ->
    @emitter.on 'did-image-insert', callback

  deactivate: ->
    @subscriptions?.dispose()
    @emitter?.dispose()

  serialize: ->
