{CompositeDisposable, File, Emitter} = require 'atom'
clipboard = require 'clipboard'
path = require 'path'
imageFactory = require './image-factory'
CustomNameView = require './custom-name-view'
filenameHelper = require './filename-helper'

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
    dynamicImageFolderName:
      title: 'Place images in folder that is the same as the filename (without the extension)'
      description: '''
        Place images in a folder named after the filename.
        This will offer a dynamic image folder name, and override the "Images Folder" setting.
        '''
      type: 'boolean'
      default: false
      order: 2
    appendImagesFolder:
      title: 'Append `imagesFolder` in generated links.'
      description: '''
        image::images/foo-bdb66.png[] # `true` (default)

        image::foo-bdb66.png[] # `false` (You are using the `:imagesdir:` attribute in your document.)
        '''
      type: 'boolean'
      default: true
      order: 3
    enableUrlSupport:
      description: '''
        Enabled clipboard tracking for image URL.

        Use with caution: any valid paths contains in the clipboard will be converted to links.
        Support: png.
        '''
      type: 'boolean'
      default: false
      order: 4
    imageExtensions:
      description: '''
        Related to clipboard tracking for file URL.

        Specify image file extensions to be converted to links.
        '''
      type: 'array'
      default: ['.png', '.jpg', '.jpeg', '.bmp', '.svg', '.gif']
      items:
        type: 'string'
      order: 5
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

        # Native image support
        if @isImage()
          @pasteNativeImage event, activeEditor
            .then successHandler
            .catch errorHandler

        # Image URL support
        else if atom.config.get 'asciidoc-image-helper.enableUrlSupport'
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
    imageExtensions = atom.config.get 'asciidoc-image-helper.imageExtensions'
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
