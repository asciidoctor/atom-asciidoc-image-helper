{Directory, File} = require 'atom'
fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
filenameHelper = require './filename-helper'

class ImageFactory

  # Copy image from an URL in the clipboard
  #
  copyImage: (activeEditor, srcImagePath, imageFileName) ->
    currentFile = new File activeEditor.getPath()

    imagesFolderName = @makeImagesFolderName currentFile
    currentDirectory = currentFile.getParent().getPath()

    @createDirectory currentDirectory, imagesFolderName
      .then (imagesDirectoryPath) =>
        destinationFilePath = path.join imagesDirectoryPath, imageFileName
        @copyFile srcImagePath, destinationFilePath
      .then =>
        @insertImage activeEditor, imagesFolderName, imageFileName

  # Create an image from an image in the clipboard (ex: screenshot)
  #
  createImage: (activeEditor, currentFile, imgbuffer, imageFileName) ->
    imagesFolderName = @makeImagesFolderName currentFile

    @createDirectory currentFile.getParent().getPath(), imagesFolderName
      .then (imagesDirectoryPath) =>
        @writeImage path.join(imagesDirectoryPath, imageFileName), imgbuffer
      .then =>
        @insertImage activeEditor, imagesFolderName, imageFileName

  copyFile: (sourcePath, targetPath) ->
    new Promise (resolve, reject) ->
      fs.readFile sourcePath, (error, content) ->
        if error? then reject error
        fs.writeFile targetPath, content, (error) ->
          if error? then reject error else resolve targetPath

  createDirectory: (baseDirectory, imagesFolderName) ->
    imagesDirectoryPath = path.join baseDirectory, imagesFolderName
    imagesDirectory = new Directory imagesDirectoryPath
    imagesDirectory.create().then (created) -> imagesDirectoryPath

  writeImage: (imagePath, buffer) ->
    new Promise (resolve, reject) ->
      fs.writeFile imagePath, buffer, 'binary', (error) ->
        if error? then reject error else resolve imagePath

  insertImage: (activeEditor, imagesFolderName, imageFileName) ->
    appendImagesFolder = atom.config.get 'asciidoc-image-helper.imageFolder.append'
    imagePath = if appendImagesFolder then path.join imagesFolderName, imageFileName else imageFileName
    imageMarkup = "image::#{imagePath}[]"
    activeEditor.insertText imageMarkup, activeEditor
    imageMarkup

  makeImagesFolderName: (currentFile) ->
    if atom.config.get 'asciidoc-image-helper.imageFolder.dynamicName'
      filePath = currentFile.getPath()
      path.basename filePath, path.extname filePath
    else
      atom.config.get 'asciidoc-image-helper.imageFolder.name'


module.exports = new ImageFactory
