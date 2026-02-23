#requires AutoHotkey v2.0
#singleinstance force

#include lib\CaretIndicator.ahk
#include lib\CursorIndicator.ahk
#include lib\utils\Merge.ahk

class LanguageIndicator {
    static Version := "0.7"

    __New(cfg?) {
        defaultCfg := {
            caret: {
                updatePeriod: 17, ; ~60 fps, caret position updates are not much frequent
                markMargin: { x: 1, y: -1 }
            },
            cursor: {
                updatePeriod: 6, ; ~166 fps, for your monitor could be less frequent
                markMargin: { x: 2, y: -2, useCursorSize: true }
            }
        }

        this.cfg := IsSet(cfg) ? cfg : defaultCfg

        this.caretIndicator := CaretIndicator(merge(CaretIndicator.DefaultConfig, this.cfg.caret))
        this.cursorIndicator := CursorIndicator(merge(CursorIndicator.DefaultConfig, this.cfg.cursor))
    }

    Run() {
        this.caretIndicator.Run()
        this.cursorIndicator.Run()
    }
}

; Application entry point
global app := LanguageIndicator()
app.Run()

A_IconTip := "Language Indicator v" . LanguageIndicator.Version