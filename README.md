# Language Indicator

<img src="img/how-it-work.gif" width="608" />

## Enables Per-Language Text Caret and Mouse Cursor Styling

This script keeps track of your current language (in fact any input method) and changes caret and mouse cursor based on files inside folders `./carets/` and `./cursors/`.
The caret and cursor might also be altered depending on capslock state, e.g. create `./carets/2-capslock.png` for _secondary language with capslock on_.

**Reliable**: Works everywhere, including consoles and Universal Windows Apps (aka Metro apps).

**Customizable**: Add, change, or delete cursors in `./cursors/` to personalize the look for different input languages and Caps Lock state. For example `2.cur` to be used if _secondary_ input method is turned on.

## Installation

1. Download `language-indicator.exe` (the compiled AHKv2-64 script)
2. Download `./carets/` + `./cursors/` folders.
3. (Optional) Remove unwanted, or add your own carets or cursors in corresponding folder.
4. Create shortcut for `language-indicator.exe`.
5. Move shortcut to the startup folder. For Windows 10, this is typically `%appdata%\Microsoft\Windows\Start Menu\Programs\Startup`

## Customization

-   Written for [AHK v2](https://www.autohotkey.com/docs/v2/).
-   Supported cursor file formats: CUR, ANI, ICO.
-   Create your own cursor with [Sib Cursor Editor](http://www.sibcode.com/cursor-editor/).
-   Currently, the script only affects the text selection cursor (`ibeam`). This can be changed within the script.

## Custom Cursors Included

<img align="left" src="img/ibeam-default.jpg" alt="default i-beam cursor" />
<img align="left" src="img/ibeam-dot-green.jpg" alt="i-beam cursor with dot" />
<img align="left" src="img/ibeam-circle-red.jpg" alt="i-beam cursor with circle" />
<img align="left" src="img/ibeam-arrow-up-blue.jpg" alt="i-beam cursor with arrow up" />
<img src="img/ibeam-g.jpg" alt="i-beam cursor with letter g" />

Cheers!

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/I-BeamCrossSection.svg/220px-I-BeamCrossSection.svg.png" alt="ibeam" />
