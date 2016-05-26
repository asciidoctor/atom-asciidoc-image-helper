path = require 'path'
crypto = require 'crypto'

class FilenameHelper

  createImageName: (currentFileName, imgbuffer, customImageName) ->
    if customImageName?
      "#{customImageName}.png"
    else
      @generateImageName currentFileName, imgbuffer

  generateImageName: (currentFileName, imgbuffer) ->
    md5 = crypto.createHash 'md5'
    md5.update imgbuffer
    imageFileNameHash = md5.digest('hex').slice(0, 5)
    baseImageFileName = @cleanImageFilename path.basename currentFileName, path.extname(currentFileName)

    "#{baseImageFileName}-#{imageFileNameHash}.png"

  cleanImageFilename: (imageFileName) ->
    imageFileName.replace(/\s+/g, '_')

module.exports = new FilenameHelper
