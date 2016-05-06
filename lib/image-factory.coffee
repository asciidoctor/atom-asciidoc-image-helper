{Directory, File} = require 'atom'
fs = require 'fs'
path = require 'path'
crypto = require 'crypto'

module.exports =

  # Copy image from an URL in the clipboard
  #
  copyImage: (activeEditor, clipboardText) ->
    imagesFolder = atom.config.get 'asciidoc-image-helper.imagesFolder'
    currentDirectory = new File(activeEditor.getPath()).getParent().getPath()
    imageFileName = path.basename clipboardText

    @createDirectory currentDirectory, imagesFolder
      .then (imagesDirectoryPath) =>
        destinationFilePath = path.join imagesDirectoryPath, imageFileName
        @copyFile clipboardText, destinationFilePath
      .then ->
        imagePath = path.join imagesFolder, imageFileName
        activeEditor.insertText "image::#{imagePath}[]", activeEditor

  # Create an image from an image in the clipboard (ex: screenshot)
  #
  createImage: (activeEditor, clipboard) ->
    clipboardContent = clipboard.readImage()
    imgbuffer = clipboardContent.toPng()

    imagesFolder = atom.config.get 'asciidoc-image-helper.imagesFolder'
    currentFile = new File activeEditor.getPath()
    imageFileName = @createImageName currentFile.getBaseName(), imgbuffer

    @createDirectory currentFile.getParent().getPath(), imagesFolder
      .then (imagesDirectoryPath) =>
        @writeImage path.join(imagesDirectoryPath, imageFileName) , imgbuffer
      .then ->
        imagePath = path.join imagesFolder, imageFileName
        activeEditor.insertText "image::#{imagePath}[]", activeEditor

  copyFile: (sourcePah, targetPath) ->
    new Promise (resolve, reject) ->
      fs.readFile sourcePah, (error, content) ->
        if error? then reject error
        fs.writeFile targetPath, content, (error) ->
          if error? then reject error
          resolve targetPath

  createDirectory: (baseDirectory, imagesFolder) ->
    imagesDirectoryPath = path.join baseDirectory, imagesFolder
    imagesDirectory = new Directory imagesDirectoryPath

    imagesDirectory.create()
      .then (created) ->
        if created then console.log 'New directory created'
        imagesDirectoryPath

  writeImage: (imagePath, buffer) ->
    new Promise (resolve, reject) ->
      fs.writeFile imagePath, buffer, 'binary', (error) ->
        console.log 'Saved Clipboard Image'
        if error? then reject error else resolve imagePath

  createImageName: (currentFileName, imgbuffer) ->
    md5 = crypto.createHash 'md5'
    md5.update imgbuffer
    imageFileNameHash = md5.digest('hex').slice(0, 5)

    baseImageFileName = currentFileName.replace(/\.\w+$/, '').replace(/\s+/g, '')
    imageFileName = "#{baseImageFileName}-#{imageFileNameHash}.png"
