fs = require 'fs'
path = require 'path'
temp = require('temp').track()
filenameHelper = require '../lib/filename-helper'

describe 'Filename helper', ->

  describe 'createImageName should', ->

    it 'create a random image name when current file have an extension', ->
      currentFileName = 'myfile.adoc'
      buffer = 'fake content'
      imageName = filenameHelper.createImageName currentFileName, buffer

      expect(imageName).toMatch /^myfile-\w+.png$/

    it 'create a random image name when current file does\'t have an extension', ->
      currentFileName = 'myfile'
      buffer = 'fake content'
      imageName = filenameHelper.createImageName currentFileName, buffer

      expect(imageName).toMatch /^myfile-\w+.png$/

    it 'create a clean image name when currrent filename contains spaces', ->
      currentFileName = 'my file is cool.adoc'
      buffer = 'fake content'
      imageName = filenameHelper.createImageName currentFileName, buffer

      expect(imageName).toMatch /^my_file_is_cool-\w+.png$/

    it 'create a simple image name when use custom name', ->
      currentFileName = 'myfile.adoc'
      buffer = 'fake content'
      customImageName = 'foobar-img'

      imageName = filenameHelper.createImageName currentFileName, buffer, customImageName

      expect(imageName).toMatch /^foobar-img.png$/
