#requires AutoHotkey v2.0
#singleinstance force

#include lib\CaretIndicator.ahk
#include lib\CursorIndicator.ahk
#include lib\utils\Merge.ahk

class LanguageIndicator {
    static Version := "0.76"

    __New(cfg?) {
        defaultCfg := {
            caret: {
                inputCheckPeriod: 50,    ; polling rate of locale + capslock
                markRepaintPeriod: 6,   ; 16ms ≈ 60fps, mark follows to the mouse cursor
                markMargin: { x: 1, y: -1 }
            },
            cursor: {
                inputCheckPeriod: 50,    ; polling rate of locale + capslock 10×/sec
                markRepaintPeriod: 6,    ; 16ms ≈ 60fps, mark follows to the mouse cursor
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