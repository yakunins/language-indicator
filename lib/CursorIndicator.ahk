; Shows language indicator near mouse cursor when over text input areas

/*
How it works:
1. A timer runs Check() every updatePeriod (default 100ms)
2. Check() first verifies the cursor is IBeam (text input cursor)
   - If not IBeam, reverts any modified cursors and hides the mark
3. Updates input state (keyboard locale and capslock)
4. Determines whether to use cursor files or embedded images:
   - If cursor files folder exists: uses files from that folder
     - .cur/.ani/.ico files: replaces system IBeam cursor via SetSystemCursor
     - .png files: paints floating mark image that follows mouse position
   - If no folder: paints floating mark using embedded base64 images
5. Mouse position prediction reduces visual lag between cursor and mark
6. OnFrameRateScheduler provides smooth updates synchronized to display refresh
7. On script exit, restores original system cursors via SystemParametersInfo
8. If locale is default (first) and capslock is off, no indicator is shown
*/

#requires AutoHotkey v2.0

#include core\IndicatorBase.ahk
#include core\MarkResolver.ahk
#include detection\GetMousePosPrediction.ahk
#include utils\OnFrameRate.ahk

class CursorIndicator extends IndicatorBase {
    static DefaultConfig := {
        debug: false,
        files: {
            capslockSuffix: "-capslock",
            folderExistCheckPeriod: 1000,
            folder: A_ScriptDir . "\cursors\",
            extensions: [".cur", ".ani", ".ico", ".png"]
        },
        markMargin: { x: 11, y: -11 },
        mousePositionPrediction: 0.5,
        target: {
            cursorId: 32513,
            cursorName: "IBeam"
        },
        updatePeriod: 100
    }

    modifiedCursorsCount := 0
    onFrame := ""

    __New(cfg := "") {
        if (cfg == "")
            cfg := CursorIndicator.DefaultConfig
        super.__New(cfg)
        this.onFrame := OnFrameRateScheduler.Increase()

        ; Override folder exists cache to include Decrease() call on cache refresh
        this.folderExistsCache := UseCached(
            () => this.CheckFolderExistsWithDecrease(),
            this.cfg.files.folderExistCheckPeriod
        )
    }

    CheckFolderExistsWithDecrease() {
        exists := DirExist(this.cfg.files.folder)
        if exists
            OnFrameRateScheduler.Decrease()
        return exists
    }

    Check() {
        if (A_Cursor != this.cfg.target.cursorName) {
            this.RevertCursors()
            this.markPainter.HideWindow()
            return
        }
        this.inputState.Update()
        this.FolderExists()
            ? this.UseFile()
            : this.UseMarkEmbedded()
    }

    UseMarkEmbedded() {
        markName := MarkResolver.GetMarkName(this.inputState.locale, this.inputState.capslock)
        if (markName == "") {
            this.markPainter.RemoveWindow()
            return
        }
        markObj := UseBase64Image(markName)
        this.PaintMark(markObj)
        this.onFrame.ScheduleRun(() => this.PaintMark(markObj), "cursor", this.cfg.updatePeriod)
    }

    UseFile() {
        filePath := MarkResolver.GetMarkFile(this.cfg.files, this.inputState.locale, this.inputState.capslock)
        if (filePath == "") {
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
        markObj := { name: fileName, image: filePath }
        this.PaintMark(markObj)
        this.onFrame.ScheduleRun(() => this.PaintMark(markObj), "cursor", this.cfg.updatePeriod)
    }

    UseCursorFile(cursorFile := "") {
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
        this.markPainter.img.name := markObj.name
        this.markPainter.img.image := markObj.image
        this.markPainter.img.x := pos.x
        this.markPainter.img.y := pos.y

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
        if !(reason ~= "^(?i:Logoff|Shutdown)$") {
            this.RevertCursors()
            this.markPainter.RemoveWindow()
        }
    }
}