; Shows language indicator next to text caret in active text fields

/*
How it works:
1. Check() runs every inputCheckPeriod (default 100ms)
   - Updates input state (keyboard locale and capslock)
   - Decides which mark (embedded or file) should be shown
   - Stores the chosen mark on this.currentMarkObj and paints once
2. Repaint() runs every markRepaintPeriod (default 100ms)
   - Re-paints the current mark at the latest caret position
   - ImagePainter.Paint() short-circuits when position + image are unchanged,
     so idle ticks are cheap (no GDI work)
3. MarkResolver returns appropriate mark name based on locale/capslock
4. GetCaretRect() detects caret position using multiple methods:
   - GUI thread info, UIA, WPF caret, MSAA, or shell hook injection
5. If locale is default (first) and capslock is off, no indicator is shown
*/

#requires AutoHotkey v2.0

#include core\IndicatorBase.ahk
#include core\MarkResolver.ahk
#include detection\GetCaretRect.ahk
#include utils\DebugCaretPosition.ahk

class CaretIndicator extends IndicatorBase {
    static DefaultConfig := {
        debug: false,
        debugCaretPosition: false,
        files: {
            capslockSuffix: "-capslock",
            folderExistCheckPeriod: 1000,
            folder: A_ScriptDir . "\carets\",
            extensions: [".png", ".gif"]
        },
        markMargin: { x: 1, y: -1 },
        inputCheckPeriod: 100,    ; polling rate of locale + capslock
        markRepaintPeriod: 16,   ; 16ms ≈ 60fps, caret mark follows the caret
    }

    __New(cfg?) {
        if !IsSet(cfg)
            cfg := CaretIndicator.DefaultConfig
        super.__New(cfg)
    }

    UseMarkFile() {
        markFile := MarkResolver.GetMarkFile(this.cfg.files, this.inputState.locale, this.inputState.capslock)
        if (markFile == "") {
            this.currentMarkObj := ""
            this.markPainter.RemoveWindow()
            return
        }
        SplitPath(markFile, &markName)
        this.currentMarkObj := { name: markName, image: markFile }
        this.PaintMark(this.currentMarkObj)
    }

    GetPosition() {
        left := -1, top := -1, bottom := -1, right := -1
        detectMethod := ""
        GetCaretRect(&left, &top, &right, &bottom, &detectMethod)
        w := right - left
        h := bottom - top
        return { left: left, top: top, right: right, bottom: bottom, w: w, h: h, detectMethod: detectMethod }
    }

    PaintMark(markObj) {
        if (!markObj.image or 2 > StrLen(markObj.image)) {
            this.markPainter.RemoveWindow()
            this.markPainter.Clear()
            return
        }

        pos := this.GetPosition()

        if this.cfg.debugCaretPosition
            DebugCaretPosition(pos.left, pos.top, pos.right, pos.bottom, pos.detectMethod)

        if (InStr(pos.detectMethod, "failure") or (pos.w < 1 and pos.h < 1)) {
            this.markPainter.HideWindow()
            return
        }

        this.markPainter.StorePrev()
        this.markPainter.current.name := markObj.name
        this.markPainter.current.image := markObj.image
        this.markPainter.current.x := pos.left
        this.markPainter.current.y := pos.top

        this.markPainter.Paint()
    }
}