# Language Indicator

<img src="img/how-it-work.gif" width="507" alt="language indicator for text caret and mouse cursor" />

## Per-Language Styling of Text Caret and Mouse Cursor

Keeps track of your current language (or input method, keyboard layout) and changes [caret](https://en.wikipedia.org/wiki/Caret_navigation) and [text selection mouse cursor](<https://en.wikipedia.org/wiki/Cursor_(user_interface)#I-beam_pointer>).  
It works in most envs, including consoles and Universal Windows Apps (aka Metro apps).  
Exceptions are Adobe Indesign and some .NET MAUI apps.  
Written for [AHK v2](https://www.autohotkey.com/docs/v2/)

## Installation

1. Download [`language-indicator.exe`](language-indicator.exe), a compiled version (AHKv2-64) of the script
2. Download and run [`install.cmd`](install.cmd) to create shortcut at startup folder

## Customization

1. Download or create [`carets`](./carets) or [`cursors`](./cursors) folders
2. Remove unwanted or add your own carets or mouse cursors within [`carets`](./carets) or [`cursors`](./cursors) folders
3. Use the following naming convention:

| Input                 | Mouse Cursor               | Text Caret Mark           |
| :-------------------- | :------------------------- | :------------------------ |
| language 2            | `./cursors/2.cur`          | `./carets/2.png`          |
| language 1 + capslock | `./cursors/1-capslock.cur` | `./carets/1-capslock.png` |
| language 2 + capslock | `./cursors/2-capslock.cur` | `./carets/2-capslock.png` |

Tips:

-   See variants included: [`cursor/variants/`](./cursor/variants/), [`carets/variants`](./carets/variants)
-   Supported caret mark formats: PNG, GIF
-   Supported cursor file formats: CUR, ANI, ICO
-   Create your own cursor with [Sib Cursor Editor](http://www.sibcode.com/cursor-editor/)

## Cursor Variants Included

<img align="left" src="img/ibeam-default.jpg" alt="default i-beam cursor" />
<img align="left" src="img/ibeam-dot-green.jpg" alt="i-beam cursor with dot" />
<img align="left" src="img/ibeam-circle-red.jpg" alt="i-beam cursor with circle" />
<img align="left" src="img/ibeam-arrow-up-blue.jpg" alt="i-beam cursor with arrow up" />
<img src="img/ibeam-g.jpg" alt="i-beam cursor with letter g" />

Enjoy! → [🍩 Donut](https://www.paypal.com/donate/?business=KXM47EKBXFV4S&no_recurring=0&item_name=funding+of+github.com%2Fyakunins&currency_code=USD)
