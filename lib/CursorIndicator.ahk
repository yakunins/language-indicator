; Shows language indicator near mouse cursor when over text input areas

/*
How it works:
1. Check() runs every inputCheckPeriod (default 100ms)
   - Verifies the cursor is IBeam (text input cursor); if not, hides the mark
   - Updates input state (keyboard locale and capslock)
   - Determines whether to use cursor files or embedded images:
     * If cursor files folder exists: uses files from that folder
       - .cur/.ani/.ico files: replaces system IBeam cursor via SetSystemCursor
       - .png files: paints floating mark image that follows mouse position
     * If no folder: paints floating mark using embedded base64 images
   - Stores the chosen mark on this.currentMarkObj
2. Repaint() runs every markRepaintPeriod (default 16ms, ~60fps)
   - Re-paints the current mark at the latest mouse position so it tracks the moving cursor
   - ImagePainter.Paint() short-circuits when position + image are unchanged,
     so idle ticks are cheap (no GDI work)
3. Mouse position prediction reduces visual lag between cursor and mark
4. On script exit, restores original system cursors via SystemParametersInfo
5. If locale is default (first) and capslock is off, no indicator is shown
*/

#requires AutoHotkey v2.0

#include core\IndicatorBase.ahk
#include core\MarkResolver.ahk
#include detection\GetMousePosPrediction.ahk
#include detection\GetCursorSize.ahk

class CursorIndicator extends IndicatorBase {
    static DefaultConfig := {
        debug: false,
        files: {
            capslockSuffix: "-capslock",
            folderExistCheckPeriod: 1000,
            folder: A_ScriptDir . "\cursors\",
            extensions: [".cur", ".ani", ".ico", ".png"]
        },
        markMargin: { x: 10, y: -10, useCursorSize: true },
        mousePositionPrediction: 0.5, ; 1 frame delay compensation, 0.5 = 50% prediction, 0 = no prediction
        target: {
            cursorId: 32513,
            cursorName: "IBeam"
        },
        inputCheckPeriod: 100,    ; polling rate of locale + capslock
        markRepaintPeriod: 16,    ; 16ms ≈ 60fps, mark follows to the mouse cursor
    }


    __New(cfg?) {
        if !IsSet(cfg)
            cfg := CursorIndicator.DefaultConfig
        super.__New(cfg)

        this.modifiedCursorsCount := 0

        if (cfg.markMargin.useCursorSize)
            this.markPainter.margin := this.GetCursorSizeMargin()
    }

    Check() {
        if (A_Cursor != this.cfg.target.cursorName) {
            this.RevertCursors()
            this.currentMarkObj := ""
            this.markPainter.HideWindow()
            return
        }
        this.inputState.Update()
        this.FolderExists()
            ? this.UseFile()
            : this.UseMarkEmbedded()
    }

    Repaint() {
        if (this.currentMarkObj == "")
            return
        ; cheap re-check: don't paint over a non-text area between Check ticks
        if (A_Cursor != this.cfg.target.cursorName) {
            this.markPainter.HideWindow()
            return
        }
        this.PaintMark(this.currentMarkObj)
    }

    UseFile() {
        filePath := MarkResolver.GetMarkFile(this.cfg.files, this.inputState.locale, this.inputState.capslock)
        if (filePath == "") {
            this.currentMarkObj := ""
            this.RevertCursors()
            this.markPainter.HideWindow()
            return
        }
        SplitPath(filePath, , , &ext)
        if (ext = "png")
            this.UseMarkPngFile(filePath)
        else
            this.UseCursorFile(filePath)
    }

    UseMarkPngFile(filePath) {
        this.RevertCursors()
        SplitPath(filePath, &fileName)
        this.currentMarkObj := { name: fileName, image: filePath }
        this.PaintMark(this.currentMarkObj)
    }

    UseCursorFile(cursorFile := "") {
        ; system-cursor replacement; nothing to repaint
        this.currentMarkObj := ""
        if (cursorFile == "") {
            this.RevertCursors()
            return
        }
        this.markPainter.HideWindow()
        this.SetCursorFromFile(cursorFile)
    }

    GetPosition() {
        return GetMousePos(this.cfg.mousePositionPrediction)
    }

    GetCursorSizeMargin() {
        GetScaledCursorSize(&w, &h)
        marginX := Round(w / 6) + this.cfg.markMargin.x
        marginY := Round(h / 4) + this.cfg.markMargin.y
        return { x: marginX, y: -marginY }
    }

    PaintMark(markObj, cursor := "IBeam") {
        if (cursor != 0 and cursor != A_Cursor) {
            this.markPainter.HideWindow()
            this.markPainter.Clear()
            return
        }

        if (!markObj.image or 10 > StrLen(markObj.image)) {
            this.markPainter.RemoveWindow()
            this.markPainter.Clear()
            return
        }

        pos := this.GetPosition()

        if (pos.x == -1 or pos.y == -1) {
            this.markPainter.HideWindow()
            this.markPainter.Clear()
            return
        }

        this.markPainter.StorePrev()
        this.markPainter.current.name := markObj.name
        this.markPainter.current.image := markObj.image
        this.markPainter.current.x := pos.x
        this.markPainter.current.y := pos.y

        this.markPainter.Paint()
    }

    SetCursorFromFile(filePath := "") {
        if (!filePath or filePath == "")
            return

        if FileExist(filePath) {
            SplitPath(filePath, , , &ext)
            if !(ext = "cur" or ext = "ani" or ext = "ico")
                return
        } else {
            return
        }

        cursorHandle := DllCall("LoadCursorFromFile", "Str", filePath)
        DllCall("SetSystemCursor", "Uint", cursorHandle, "Int", this.cfg.target.cursorId)
        this.modifiedCursorsCount += 1
    }

    RevertCursors() {
        if this.modifiedCursorsCount == 0
            return

        SPI_SETCURSORS := 0x57
        DllCall("SystemParametersInfo", "UInt", SPI_SETCURSORS, "UInt", 0, "UInt", 0, "UInt", 0)
        this.modifiedCursorsCount := 0
    }

    OnExit(reason, code) {
        if !(reason ~= IndicatorBase.SHUTDOWN_REASONS)
            this.RevertCursors()
        super.OnExit(reason, code)
    }
}