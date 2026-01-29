; Tracks indicator mark state with change detection for efficient repainting
#requires AutoHotkey v2.0

class IndicatorState {
    __New() {
        this.markName := ""
        this.markImage := ""
        this.markFile := ""

        this.prev := {
            markName: "",
            markImage: "",
            markFile: ""
        }
    }

    StorePrev() {
        this.prev.markName := this.markName
        this.prev.markImage := this.markImage
        this.prev.markFile := this.markFile
    }

    HasMarkChanged() {
        return this.markName != this.prev.markName
            or this.markImage != this.prev.markImage
            or this.markFile != this.prev.markFile
    }

    Clear() {
        this.markName := ""
        this.markImage := ""
        this.markFile := ""
    }
}