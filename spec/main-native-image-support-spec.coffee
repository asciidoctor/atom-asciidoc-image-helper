temp = require('temp').track()
path = require 'path'
fs = require 'fs'
remote = require 'remote'
nativeImage = remote.require 'native-image'
clipboard = remote.require 'clipboard'
asciiDocimageHelper = require '../lib/main'
fakeAsciiDocGrammarBuilder = require './fixtures/fake-asciidoc-grammar-builder'

describe 'Native image with AsciiDoc Image helper should', ->

  imageName = 'logo-atom.png'
  [directory, editor, workspaceElement] = []

  beforeEach ->
    directory = temp.mkdirSync()
    atom.project.setPaths([directory])
    workspaceElement = atom.views.getView(atom.workspace)
    filePath = path.join(directory, 'foobar.adoc')
    fs.writeFileSync(filePath, 'foobar')

    waitsForPromise ->
      atom.packages.activatePackage 'asciidoc-image-helper'

    waitsForPromise ->
      Promise.resolve()
        .then -> atom.workspace.open(filePath)
        .then (ed) -> editor = ed
        .then (ed) -> fakeAsciiDocGrammarBuilder.createGrammar()
        .then (grammar) ->  editor.setGrammar(grammar)

  afterEach ->
    clipboard.clear()
    editor?.destroy()
    temp.cleanupSync()

  it 'create a link and store the image in a directory when image folder append to link and use the default directory', ->
    called = false
    asciiDocimageHelper.onDidInsert -> called = true

    atom.config.set 'asciidoc-image-helper.appendImagesFolder', true # Default
    atom.config.set 'asciidoc-image-helper.enableUrlSupport', true

    editor = atom.workspace.getActiveTextEditor()
    expect(editor.getPath()).toMatch /^.*(\/|\\)foobar\.adoc$/

    editor.selectAll()
    expect(editor.getSelectedText()).toMatch /^foobar$/
    editor.delete()

    imageUrl = path.join __dirname, 'fixtures', imageName
    img = nativeImage.createFromPath imageUrl
    clipboard.writeImage img

    atom.commands.dispatch workspaceElement, 'core:paste'

    waitsFor 'markup insertion', -> called is true

    runs ->
      editor.selectAll()
      link = editor.getSelectedText()
      expect(link).toMatch /image::images(\/|\\)foobar-[\w]+\.png\[\]/
      imagesFolder = atom.config.get 'asciidoc-image-helper.imagesFolder'
      result = /image::images(\/|\\)(foobar[\w\-.]+)\[\]/ig.exec link
      stat = fs.statSync path.join directory, imagesFolder, result[2]
      expect(stat).toBeDefined()
      expect(stat.size).toBeGreaterThan 6256


  it 'create a link and store the image in a directory when image folder append to link and use custom directory', ->
    called = false
    asciiDocimageHelper.onDidInsert -> called = true

    atom.config.set 'asciidoc-image-helper.appendImagesFolder', true # Default
    atom.config.set 'asciidoc-image-helper.enableUrlSupport', true
    atom.config.set 'asciidoc-image-helper.imagesFolder', 'foo'

    editor = atom.workspace.getActiveTextEditor()
    expect(editor.getPath()).toMatch /^.*(\/|\\)foobar\.adoc$/

    editor.selectAll()
    expect(editor.getSelectedText()).toMatch /^foobar$/
    editor.delete()

    imageUrl = path.join __dirname, 'fixtures', imageName
    img = nativeImage.createFromPath imageUrl
    clipboard.writeImage img

    atom.commands.dispatch workspaceElement, 'core:paste'

    waitsFor 'markup insertion', -> called is true

    runs ->
      editor.selectAll()
      link = editor.getSelectedText()
      expect(link).toMatch /image::foo(\/|\\)foobar-[\w]+\.png\[\]/
      imagesFolder = atom.config.get 'asciidoc-image-helper.imagesFolder'
      result = /image::foo(\/|\\)(foobar[\w\-.]+)\[\]/ig.exec link
      stat = fs.statSync path.join directory, imagesFolder, result[2]
      expect(stat).toBeDefined()
      expect(stat.size).toBeGreaterThan 6256


  it 'create a link and store the image in a directory when image folder not append to link and use the default directory', ->
    called = false
    asciiDocimageHelper.onDidInsert -> called = true

    atom.config.set 'asciidoc-image-helper.appendImagesFolder', false
    atom.config.set 'asciidoc-image-helper.enableUrlSupport', true

    editor = atom.workspace.getActiveTextEditor()
    expect(editor.getPath()).toMatch /^.*(\/|\\)foobar\.adoc$/

    editor.selectAll()
    expect(editor.getSelectedText()).toMatch /^foobar$/
    editor.delete()

    imageUrl = path.join __dirname, 'fixtures', imageName
    img = nativeImage.createFromPath imageUrl
    clipboard.writeImage img

    atom.commands.dispatch workspaceElement, 'core:paste'

    waitsFor 'markup insertion', -> called is true

    runs ->
      editor.selectAll()
      link = editor.getSelectedText()
      expect(link).toMatch /image::foobar-[\w]+\.png\[\]/
      imagesFolder = atom.config.get 'asciidoc-image-helper.imagesFolder'
      result = /image::(foobar[\w\-.]+)\[\]/ig.exec link
      stat = fs.statSync path.join directory, imagesFolder, result[1]
      expect(stat).toBeDefined()
      expect(stat.size).toBeGreaterThan 6256


  it 'create a link and store the image in a directory when image folder not append to link and use custom directory', ->
    called = false
    asciiDocimageHelper.onDidInsert -> called = true

    atom.config.set 'asciidoc-image-helper.appendImagesFolder', false
    atom.config.set 'asciidoc-image-helper.enableUrlSupport', true
    atom.config.set 'asciidoc-image-helper.imagesFolder', 'bar'

    editor = atom.workspace.getActiveTextEditor()
    expect(editor.getPath()).toMatch /^.*(\/|\\)foobar\.adoc$/

    editor.selectAll()
    expect(editor.getSelectedText()).toMatch /^foobar$/
    editor.delete()

    imageUrl = path.join __dirname, 'fixtures', imageName
    img = nativeImage.createFromPath imageUrl
    clipboard.writeImage img

    atom.commands.dispatch workspaceElement, 'core:paste'

    waitsFor 'markup insertion', -> called is true

    runs ->
      editor.selectAll()
      link = editor.getSelectedText()
      expect(link).toMatch /image::foobar-[\w]+\.png\[\]/
      imagesFolder = atom.config.get 'asciidoc-image-helper.imagesFolder'
      result = /image::(foobar[\w\-.]+)\[\]/ig.exec link
      stat = fs.statSync path.join directory, imagesFolder, result[1]
      expect(stat).toBeDefined()
      expect(stat.size).toBeGreaterThan 6256
