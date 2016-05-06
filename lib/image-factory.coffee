{Directory} = require 'atom'
fs = require 'fs'
path = require 'path'
crypto = require 'crypto'

module.exports =

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
