# ColorSense for Xcode

## Overview

ColorSense is an Xcode plugin that makes working with `UIColor` (and `NSColor`) more visual.

There are [many](http://www.colorchooserapp.com) [tools](http://iconfactory.com/software/xscope) that allow you to insert a `UIColor`/`NSColor` from a color picker or by picking a color from the screen. But once you've inserted it, it can be hard to remember which color you're actually looking at in your code because you basically just have a series of numbers.

This is where ColorSense comes in: When you put the caret on one of your colors, it automatically shows the actual color as an overlay, and you can even adjust it on-the-fly with the standard Mac OS X color picker.

The plugin also adds some items to the _Edit_ menu to insert colors and to disable color highlighting temporarily. These menu items have no keyboard shortcuts by default, but you can set them via the system's keyboard preferences (Xcode's own preferences won't show them).

**[Watch Demo Video (YouTube)](http://www.youtube.com/watch?v=eblRfDQM0Go)**

I'm [@olemoritz](http://twitter.com/olemoritz) on Twitter.

<a href="http://flattr.com/thing/879121/omzColorSense-for-Xcode-on-GitHub" target="_blank">
<img src="http://api.flattr.com/button/flattr-badge-large.png" alt="Flattr this" title="Flattr this" border="0" /></a>

## Installation

Simply build the Xcode project and restart Xcode. The plugin will automatically be installed in `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins`. To uninstall, just remove the plugin from there (and restart Xcode).

If you get a "Permission Denied" error while building, please see [this issue](https://github.com/omz/ColorSense-for-Xcode/issues/1).

This is tested on OS X 10.8 with Xcode 4.4.1 and 4.5.

## Limitations

* It only works for constant colors, something like `[UIColor colorWithWhite:foo * bar + 1 alpha:baz]` won't work.

* Only RGB (`colorWithRed:green:blue:alpha:`), grayscale (`colorWithWhite:alpha:`), and named colors (`redColor`...) are supported at the moment (no HSB or CMYK).

## License

    Copyright (c) 2012, Ole Zorn
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this
      list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
    FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
    OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.