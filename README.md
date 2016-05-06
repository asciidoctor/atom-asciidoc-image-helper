# AsciiDoc Image Helper

[![Atom Package](https://img.shields.io/apm/v/asciidoc-image-helper.svg)](https://atom.io/packages/asciidoc-image-helper)
[![Atom Package Downloads](https://img.shields.io/apm/dm/asciidoc-image-helper.svg)](https://atom.io/packages/asciidoc-image-helper)
[![Build Status](https://travis-ci.org/bwklein/asciidoc-image-helper.svg?branch=master)](https://travis-ci.org/bwklein/asciidoc-image-helper)
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/bwklein/asciidoc-image-helper/blob/master/LICENSE.md)

An Atom plugin for AsciiDoc grammar.
Create an image file, in the specified folder, that is named after the AsciiDoc file it is pasted into, and insert an image reference to that file into the editor.

Originally forked from [markdown-image-helper](https://github.com/bigyuki/markdown-image-helper).

## Basic Usage

1. Take a screenshot or copy an image to the clipboard.
2. Paste it into Atom AsciiDoc editor.
3. See that the 'Images Folder' has a new png file, and an image reference was inserted into the editor with the correct filename.

**Note:** You should set the ```:imagesdir:``` parameter for your document to match the 'Images Folder' setting in this package.  This way the package will know where to place your image files.  The default setting is a folder named 'images' in the same folder as the document.

### Notes for Windows Users
#### To take a screenshot to the clipboard.
Use PrintScr to capture your entire desktop.  
Use Alt + PrintScr to capture the active window.  

#### When copying an existing file on your local system into the document.
1. Open Windows Explorer and find your file.
2. Press Shift and right-click with your mouse.
3. Your pop up menu will have several more options.
4. Select Copy as Path.
5. Paste into the editor

### Notes for Mac OS X Users
#### To take a screenshot to the clipboard.
Use Command-Shift-Control-4 to capture the image data to the clipboard.

#### When copying an existing file on your local system into the document.
1. Navigate to the file or folder you wish to copy the path for.
2. Right-click (or Control+Click, or a Two-Finger click on trackpads) on the file in the Mac Finder.
3. While in the right-click menu, hold down the OPTION key to reveal the "Copy (item name) as Pathname" option, it replaces the standard Copy option.
4. Once selected, the file or folders path is now in the clipboard, ready to be pasted into the document.  
**Note:** The copied pathname is always the complete path, it’s not relative.

## Install

Settings/Preferences > Install > Search for `asciidoc-image-helper`

Or

```bash
apm install asciidoc-image-helper
```

## Credits

Special thank you to [Ludovic Fernandez '_ldez_'](https://github.com/ldez) for turning this package into a legit project.  I am learning a lot from his pull requests.
