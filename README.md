# AsciiDoc Image Helper

[![Atom Package](https://img.shields.io/apm/v/asciidoc-image-helper.svg)](https://atom.io/packages/asciidoc-image-helper)
[![Atom Package Downloads](https://img.shields.io/apm/dm/asciidoc-image-helper.svg)](https://atom.io/packages/asciidoc-image-helper)
[![Build Status](https://travis-ci.org/asciidoctor/atom-asciidoc-image-helper.svg?branch=master)](https://travis-ci.org/asciidoctor/atom-asciidoc-image-helper)
[![Build status](https://ci.appveyor.com/api/projects/status/m19s3t4vk3m487pf?svg=true)](https://ci.appveyor.com/project/asciidoctor/atom-asciidoc-image-helper/branch/master)
[![Gitter](https://badges.gitter.im/asciidoctor/atom-asciidoc-image-helper.svg)](https://gitter.im/asciidoctor/atom-asciidoc-image-helper?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/bwklein/asciidoc-image-helper/blob/master/LICENSE.md)

An Atom plugin to facilitate insertion of images in an AsciiDoc document.

Create an image file, in the specified folder, that is named after the AsciiDoc file it is pasted into, and insert an image reference to that file into the editor.

Originally forked from [markdown-image-helper](https://github.com/bigyuki/markdown-image-helper).

## Basic Usage

1. Take a screenshot or copy an image to the clipboard.
2. Paste it into Atom AsciiDoc editor.
3. See that the _'Images Folder'_ has a new png file, and an image reference was inserted into the editor with the correct filename.

The default setting is to place copied and created a folder named `images` in the same folder as the document.  
Another default setting is to expect that the `:imagesdir:` attribute is **not** set in the document (or through cli) and sets the _'Append Images Folder'_ setting to `true`. This setting will append the Images Folder path to the filename in the `image:[]` macro so that AsciiDoctor knows where to find the files.

**NOTE:** To increase flexibility for moving your images folder, and to also reduce the repetition of hard coded image folder strings in the document; it is recommended to set the `:imagesdir:` attribute for your document to match the _'Images Folder'_ setting in this package and to disable the _'Append Images Folder'_ option.  
This way, the package will know where to place your image files, and asciidoctor will know where to find them.

If you want to move your folder of images into a new directory called something like `assets` you would change the Folder Location string to `assets/images`, and set this same thing as the value of the `:imagesdir:` attribute in the document.  
Make sure the setting to _'Append Images Folder_' is not checked.  
Now everything should just work as expected in the new location, without requiring a Find/Replace operation over all of the documents that have hard coded the images folder into the image macros.

### Notes for Windows Users

#### To take a screenshot to the clipboard.

Use `PrintScr` to capture your entire desktop.  
Use `Alt + PrintScr` to capture the active window.  

#### When copying an existing file on your local system into the document.

1. Open Windows Explorer and find your file.
2. Press `Shift` and `right-click` with your mouse.
3. Your pop up menu will have several more options.
4. Select Copy as Path.
5. Paste into the editor.

### Notes for Mac OS X Users

#### To take a screenshot to the clipboard.

Use `Command-Shift-Control-4` to capture the image data to the clipboard.

#### When copying an existing file on your local system into the document.

1. Navigate to the file or folder you wish to copy the path for.
2. `Right-click` (or `Control+Click`, or a _Two-Finger click_ on trackpads) on the file in the Mac Finder.
3. While in the right-click menu, hold down the OPTION key to reveal the _"Copy (item name) as Pathname"_ option, it replaces the standard Copy option.
4. Once selected, the file or folders path is now in the clipboard, ready to be pasted into the document.  
**Note:** The copied pathname is always the complete path, it’s not relative.

## Install

Settings/Preferences > Install > Search for `asciidoc-image-helper`

or

```bash
apm install asciidoc-image-helper
```

## Credits

Special thank you to [Ludovic Fernandez '_ldez_'](https://github.com/ldez) for turning this package into a legit project. I am learning a lot from his pull requests.
