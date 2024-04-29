<img src="img/how-it-work.gif" width="608" />

# My beam

Custom text select cursor (mouse pointer) per each input language and capslock state.  
Some of cursors included:  
<img src="img/ibeam-default.jpg" alt="default i-beam cursor" />
<img src="img/ibeam-dot-green.jpg" alt="i-beam cursor with dot" />
<img src="img/ibeam-circle-red.jpg" alt="i-beam cursor with circle" />
<img src="img/ibeam-arrow-up-blue.jpg" alt="i-beam cursor with arrow up" />
<img src="img/ibeam-g.jpg" alt="i-beam cursor with letter g" />

## Features

-   reliable; work everywhere, including consoles and universal windows apps (aka metro apps)
-   easy setup; add/change/delete `./cursors/2-capslock.cur` to customize cursor for secondary input language with capslock on
-   compatible with Windows 10, 11

## Installation

1. clone the repo
2. (optional) customize cursors in `./cursors/` folder
3. create shortcut for `my-beam.exe`, a AHKv2-64 compiled version of script
4. put shortcut to startup folder; for Windows 10 it should be `%appdata%\Microsoft\Windows\Start Menu\Programs\Startup`

## Troubleshooting

Written for [AHK v2](https://www.autohotkey.com/docs/v2/).
Cursor file formats supported: `cur`, `ani`, `ico`.

Cheers!
