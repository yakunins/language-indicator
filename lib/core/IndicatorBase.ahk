; Abstract base class for language indicators with common mark painting logic
#requires AutoHotkey v2.0

#include MarkResolver.ahk
#include IndicatorState.ahk
#include ..\detection\InputState.ahk
#include ..\image-utils\ImagePainter.ahk
#include ..\image-utils\UseBase64Image.ahk
#include ..\utils\UseCached.ahk

class IndicatorBase {
    __New(cfg) {
        this.cfg := cfg
        this.state := IndicatorState()
        this.inputState := InputState()
        this.markPainter := ImagePainter()
        this.markPainter.margin := this.cfg.markMargin

        ; Create cached folder check function
        this.folderExistsCache := UseCached(
            () => DirExist(this.cfg.files.folder),
            this.cfg.files.folderExistCheckPeriod
        )
    }

    Run() {
        SetTimer(() => this.Check(), this.cfg.updatePeriod)
        OnExit((reason, code) => this.OnExit(reason, code))
    }

    Check() {
        this.inputState.Update()
        this.FolderExists()
            ? this.UseMarkFile()
            : this.UseMarkEmbedded()
    }

    FolderExists() {
        return this.folderExistsCache.Call()
    }

    UseMarkEmbedded() {
        markName := MarkResolver.GetMarkName(this.inputState.locale, this.inputState.capslock)
        if (markName == "") {
            this.markPainter.RemoveWindow()
            return
        }
        markObj := UseBase64Image(markName)
        this.PaintMark(markObj)
    }

    UseMarkFile() {
        markName := MarkResolver.GetMarkName(this.inputState.locale, this.inputState.capslock)
        if (markName == "") {
            this.markPainter.RemoveWindow()
            return
        }
        markFile := MarkResolver.GetMarkFile(this.cfg.files, this.inputState.locale, this.inputState.capslock)
        markObj := { name: markName, image: markFile }
        this.PaintMark(markObj)
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
        if !(reason ~= "^(?i:Logoff|Shutdown)$")
            this.markPainter.RemoveWindow()
    }
}