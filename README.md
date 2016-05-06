# AsciiDoc Image Helper

[![Atom Package](https://img.shields.io/apm/v/asciidoc-image-helper.svg)](https://atom.io/packages/asciidoc-image-helper)
[![Atom Package Downloads](https://img.shields.io/apm/dm/asciidoc-image-helper.svg)](https://atom.io/packages/asciidoc-image-helper)
[![Build Status](https://travis-ci.org/bwklein/asciidoc-image-helper.svg?branch=master)](https://travis-ci.org/bwklein/asciidoc-image-helper)
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/bwklein/asciidoc-image-helper/blob/master/LICENSE.md)

An Atom plugin for AsciiDoc grammar.
Create image file relative to the asciidoc file and insert a relative url to that file.

Conversion of [markdown-image-helper](https://github.com/bigyuki/markdown-image-helper)，instead uploading the image, copying to the filesystem into a relative path is better.

## Usage

1. Take a screenshot or copy any image to the clipboard.
2. Paste it into Atom AsciiDoc editor.
3. See that an directory name `images` was created, the directory has a png file, and a url was inserted.


## Install

Settings/Preferences > Install > Search for `asciidoc-image-helper`

Or

```bash
apm install asciidoc-image-helper
```

## Credits

Special thank you to [Ludovic Fernandez _ldez_](https://github.com/ldez) for turning this package into a legit project.  I am learning alot from his pull requests.
