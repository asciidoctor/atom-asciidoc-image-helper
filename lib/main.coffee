{CompositeDisposable, File, Directory} = require 'atom'
path = require 'path'
fs = require 'fs'
clipboard = require 'clipboard'
crypto = require 'crypto'

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

        imgbuffer = clipboardContent.toPng()

        md5 = crypto.createHash 'md5'
        md5.update imgbuffer
        imageFileNameHash = md5.digest('hex').slice(0, 5)

        # Prompt for custom filename.

        currentFile = new File activeEditor.getPath()
        baseImageFileName = currentFile.getBaseName().replace(/\.\w+$/, '').replace(/\s+/g, '')
        imageFileName = "#{baseImageFileName}-#{imageFileNameHash}.png"

        imagesDirectoryPath = path.join currentFile.getParent().getPath(), atom.config.get 'asciidoc-image-helper.imagesFolder'

        @createDirectory imagesDirectoryPath
          .then =>
            @writePng path.join(imagesDirectoryPath, imageFileName), imgbuffer
          .then ->
            activeEditor.insertText "image::#{imageFileName}[]", activeEditor

        false

  createDirectory: (dirPath) ->
    imagesDirectory = new Directory dirPath
    imagesDirectory.exists()
      .then (existed) ->
        if not existed
          imagesDirectory.create()

  writePng: (imagePath, buffer) ->
    new Promise (resolve, reject) ->
      fs.writeFile imagePath, buffer, 'binary', (error) ->
        console.log 'Saved Clipboard Image'
        if error? then reject error else resolve 'Saved'

  deactivate: ->
    @subscriptions?.dispose()

  serialize: ->
