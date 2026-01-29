; Shows language indicator next to text caret in active text fields

/*
How it works:
1. A timer runs Check() every updatePeriod (default 100ms)
2. Check() updates input state (keyboard locale and capslock)
3. Determines whether to use embedded base64 images or external files
4. MarkResolver returns appropriate mark name based on locale/capslock
5. GetCaretRect() detects caret position using multiple methods:
   - GUI thread info, UIA, WPF caret, MSAA, or shell hook injection
6. If caret found, paints indicator image at caret position
7. OnFrameRateScheduler provides smooth updates synchronized to display refresh
8. If locale is default (first) and capslock is off, no indicator is shown
*/

#requires AutoHotkey v2.0

#include core\IndicatorBase.ahk
#include core\MarkResolver.ahk
#include detection\GetCaretRect.ahk
#include utils\DebugCaretPosition.ahk
#include utils\OnFrameRate.ahk

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
        updatePeriod: 17, ; update rate ~60 fps
    }

    __New(cfg?) {
        if !IsSet(cfg)
            cfg := CaretIndicator.DefaultConfig
        super.__New(cfg)
        this.onFrame := OnFrameRateScheduler.Increase()
    }

    UseMarkEmbedded() {
        markName := MarkResolver.GetMarkName(this.inputState.locale, this.inputState.capslock)
        if (markName == "") {
            this.markPainter.RemoveWindow()
            return
        }
        markObj := UseBase64Image(markName)
        this.PaintMark(markObj)
        this.onFrame.ScheduleRun(() => this.PaintMark(markObj), "caret", this.cfg.updatePeriod)
    }

    UseMarkFile() {
        markFile := MarkResolver.GetMarkFile(this.cfg.files, this.inputState.locale, this.inputState.capslock)
        if (markFile == "") {
            this.markPainter.RemoveWindow()
            return
        }
        SplitPath(markFile, &markName)
        markObj := { name: markName, image: markFile }
        this.PaintMark(markObj)
        this.onFrame.ScheduleRun(() => this.PaintMark(markObj), "caret", this.cfg.updatePeriod)
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

        left := -1, top := -1, right := -1, bottom := -1
        detectMethod := ""
        GetCaretRect(&left, &top, &right, &bottom, &detectMethod)
        w := right - left
        h := bottom - top

        if this.cfg.debugCaretPosition
            DebugCaretPosition(&left, &top, &right, &bottom, &detectMethod)

        if (InStr(detectMethod, "failure") or (w < 1 and h < 1)) {
            this.markPainter.HideWindow()
            return
        }

        this.markPainter.StorePrev()
        this.markPainter.current.name := markObj.name
        this.markPainter.current.image := markObj.image
        this.markPainter.current.x := left
        this.markPainter.current.y := top

        this.markPainter.Paint()
    }
}