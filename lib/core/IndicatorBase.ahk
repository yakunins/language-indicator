; Abstract base class for language indicators with common mark painting logic
#requires AutoHotkey v2.0

#include MarkResolver.ahk
#include ..\detection\InputState.ahk
#include ..\image-utils\ImagePainter.ahk
#include ..\image-utils\UseBase64Image.ahk
#include ..\utils\UseCached.ahk

class IndicatorBase {
    static SHUTDOWN_REASONS := "^(?i:Logoff|Shutdown)$"

    __New(cfg) {
        this.cfg := cfg
        this.inputState := InputState()
        this.markPainter := ImagePainter()
        this.markPainter.margin := this.cfg.markMargin
        this.currentMarkObj := ""

        ; Create cached folder check function
        this.folderExistsCache := UseCached(
            () => DirExist(this.cfg.files.folder),
            this.cfg.files.folderExistCheckPeriod
        )
    }

    Run() {
        ; inputCheckPeriod  — how often we poll keyboard locale + capslock and decide which mark to use
        ; markRepaintPeriod — how often we refresh the mark at the current caret/cursor position
        ;                     (ImagePainter.Paint() short-circuits when position+image are unchanged)
        SetTimer(() => this.Check(), this.cfg.inputCheckPeriod)
        SetTimer(() => this.Repaint(), this.cfg.markRepaintPeriod)
        OnExit((reason, code) => this.OnExit(reason, code))
    }

    Check() {
        this.inputState.Update()
        this.FolderExists()
            ? this.UseMarkFile()
            : this.UseMarkEmbedded()
    }

    Repaint() {
        if (this.currentMarkObj == "")
            return
        this.PaintMark(this.currentMarkObj)
    }

    FolderExists() {
        return this.folderExistsCache.Call()
    }

    UseMarkEmbedded() {
        markName := MarkResolver.GetMarkName(this.inputState.locale, this.inputState.capslock)
        if (markName == "") {
            this.currentMarkObj := ""
            this.markPainter.RemoveWindow()
            return
        }
        this.currentMarkObj := UseBase64Image(markName)
        this.PaintMark(this.currentMarkObj)
    }

    UseMarkFile() {
        markName := MarkResolver.GetMarkName(this.inputState.locale, this.inputState.capslock)
        if (markName == "") {
            this.currentMarkObj := ""
            this.markPainter.RemoveWindow()
            return
        }
        markFile := MarkResolver.GetMarkFile(this.cfg.files, this.inputState.locale, this.inputState.capslock)
        this.currentMarkObj := { name: markName, image: markFile }
        this.PaintMark(this.currentMarkObj)
    }

    ; Abstract method - subclasses must implement
    PaintMark(markObj) {
        throw Error("PaintMark must be implemented by subclass")
    }

    ; Abstract method - subclasses must implement
    GetPosition() {
        throw Error("GetPosition must be implemented by subclass")
    }

    OnExit(reason, code) {
        if !(reason ~= IndicatorBase.SHUTDOWN_REASONS)
            this.markPainter.RemoveWindow()
    }
}
