# My Beam

Enables per-language cursor styling, aka language indicator.
Keep track of current language/input method, if changed, to set different mouse cursor based on list from `./cursors/` folder.
Cursor also might be altered if capslock is on.

<img src="img/how-it-work.gif" width="608" />

## Features

-   reliable; work everywhere, including consoles and universal windows apps (aka metro apps)
-   customizable; add/change/delete `./cursors/2-capslock.cur` to customize cursor for secondary input language with capslock turned on
-   compatible with Windows 10, 11

## Installation

1. clone the repo
2. (optional) set your own cursors in `./cursors/` folder
3. create shortcut for `my-beam.exe`, an AHKv2-64 compiled version of script
4. move shortcut to startup folder; for Windows 10 it should be `%appdata%\Microsoft\Windows\Start Menu\Programs\Startup`

## Custoimization

Written for [AHK v2](https://www.autohotkey.com/docs/v2/).  
Cursor file formats supported: `cur`, `ani`, `ico`.  
Create your ow cursor with [Sib Cursor Editor](http://www.sibcode.com/cursor-editor/).  
By default it changes only `text select` cursor, aka `ibeam`, but this could be changed within the script.  
Some of cursors included:  
<img src="img/ibeam-default.jpg" alt="default i-beam cursor" />
<img src="img/ibeam-dot-green.jpg" alt="i-beam cursor with dot" />
<img src="img/ibeam-circle-red.jpg" alt="i-beam cursor with circle" />
<img src="img/ibeam-arrow-up-blue.jpg" alt="i-beam cursor with arrow up" />
<img src="img/ibeam-g.jpg" alt="i-beam cursor with letter g" />

Cheers!

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/I-BeamCrossSection.svg/220px-I-BeamCrossSection.svg.png" alt="ibeam" />


