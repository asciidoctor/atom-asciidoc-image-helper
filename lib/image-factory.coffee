{Directory, File} = require 'atom'
fs = require 'fs'
path = require 'path'
crypto = require 'crypto'

class ImageFactory

  # Copy image from an URL in the clipboard
  #
  copyImage: (activeEditor, clipboardText) ->
    imagesFolder = atom.config.get 'asciidoc-image-helper.imagesFolder'
    currentDirectory = new File(activeEditor.getPath()).getParent().getPath()
    imageFileName = @cleanImageFilename path.basename clipboardText

    @createDirectory currentDirectory, imagesFolder
      .then (imagesDirectoryPath) =>
        destinationFilePath = path.join imagesDirectoryPath, imageFileName
        @copyFile clipboardText, destinationFilePath
      .then =>
        @insertImage activeEditor, imagesFolder, imageFileName

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
        @writeImage path.join(imagesDirectoryPath, imageFileName), imgbuffer
      .then =>
        @insertImage activeEditor, imagesFolder, imageFileName

  copyFile: (sourcePath, targetPath) ->
    new Promise (resolve, reject) ->
      fs.readFile sourcePath, (error, content) ->
        if error? then reject error
        fs.writeFile targetPath, content, (error) ->
          if error? then reject error else resolve targetPath

  createDirectory: (baseDirectory, imagesFolder) ->
    imagesDirectoryPath = path.join baseDirectory, imagesFolder
    imagesDirectory = new Directory imagesDirectoryPath
    imagesDirectory.create().then (created) -> imagesDirectoryPath

  writeImage: (imagePath, buffer) ->
    new Promise (resolve, reject) ->
      fs.writeFile imagePath, buffer, 'binary', (error) ->
        if error? then reject error else resolve imagePath

  createImageName: (currentFileName, imgbuffer) ->
    md5 = crypto.createHash 'md5'
    md5.update imgbuffer
    imageFileNameHash = md5.digest('hex').slice(0, 5)

    baseImageFileName = @cleanImageFilename path.basename currentFileName, path.extname(currentFileName)
    imageFileName = "#{baseImageFileName}-#{imageFileNameHash}.png"

  insertImage: (activeEditor, imagesFolder, imageFileName) ->
    appendImagesFolder = atom.config.get 'asciidoc-image-helper.appendImagesFolder'
    imagePath = if appendImagesFolder then path.join imagesFolder, imageFileName else imageFileName
    imageMarkup = "image::#{imagePath}[]"
    activeEditor.insertText imageMarkup, activeEditor
    imageMarkup

  cleanImageFilename: (imageFileName) ->
    imageFileName.replace(/\s+/g, '_')

module.exports = new ImageFactory
