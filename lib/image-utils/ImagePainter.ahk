; Displays images in transparent always-on-top windows for visual indicators
#requires AutoHotkey v2.0
#include ImagePut.ahk

class ImagePainter {
    ; Window style constants
    static WS_CHILD := 0x40000000
    static WS_VISIBLE := 0x10000000
    static WS_EX_LAYERED := 0x8000000

    ; Configuration
    bgColor := "ffffff"
    margin := { x: 0, y: 0 }

    ; Window state
    window := ""
    windowVisible := false

    ; Image state
    current := { image: "", name: "", x: "", y: "", w: 0, h: 0 }
    prev := { image: "", name: "", x: "", y: "", w: 0, h: 0 }

    __New(bgColor?) {
        if IsSet(bgColor)
            this.bgColor := bgColor
    }

    Clear() {
        this.current := { image: "", name: "", x: "", y: "", w: 0, h: 0 }
    }

    ClearAll() {
        this.Clear()
        this.prev := { image: "", name: "", x: "", y: "", w: 0, h: 0 }
    }

    StorePrev() {
        this.prev := this.current.Clone()
    }

    Paint() {
        if !this._hasValidState()
            return

        imageChanged := this._hasImageChanged()

        if this._canSkipRepaint(imageChanged)
            return

        if (this.window != "" and imageChanged)
            this.RemoveWindow()

        if !this._loadDimensions(imageChanged)
            return

        if !this._ensureWindow()
            return

        this._showAtPosition()
    }

    RemoveWindow() {
        if this.window != "" {
            this.window.Destroy()
            this.window := ""
            this.windowVisible := false
        }
    }

    HideWindow() {
        if this.window != "" {
            this.window.Hide()
            this.windowVisible := false
        }
    }

    ; Private methods

    _hasValidState() {
        if (this.current.image == "" or !this.current.image)
            return false
        if (this.current.x == "" or this.current.y == "")
            return false
        return true
    }

    _hasImageChanged() {
        return (this.current.name != this.prev.name or this.current.image != this.prev.image)
    }

    _canSkipRepaint(imageChanged) {
        if (this.window == "" or !this.windowVisible)
            return false
        return (this.current.x == this.prev.x and
                this.current.y == this.prev.y and
                !imageChanged)
    }

    _loadDimensions(imageChanged) {
        if (!imageChanged and this.current.w > 0 and this.current.h > 0)
            return true

        try {
            this.current.w := ImageWidth(this.current.image)
            this.current.h := ImageHeight(this.current.image)
            return true
        } catch {
            this.Clear()
            return false
        }
    }

    _ensureWindow() {
        if this.window != ""
            return true

        try {
            this._initWindow()
            return true
        } catch {
            this.window := ""
            this.Clear()
            return false
        }
    }

    _initWindow() {
        if (this.window != "")
            this.window.Destroy()

        sizeConstraints := " +MinSize" this.current.w "x" this.current.h
                        .  " +MaxSize" this.current.w "x" this.current.h

        ; GUI: transparent, always-on-top, no DPI scaling
        this.window := Gui("+LastFound -Caption +AlwaysOnTop +ToolWindow -Border -DPIScale -Resize" sizeConstraints)
        this.window.MarginX := 0
        this.window.MarginY := 0
        this.window.Title := ""
        this.window.BackColor := this.bgColor
        WinSetTransColor(this.bgColor, this.window)

        ; Create dummy control for ImagePut
        display := this.window.Add("Text", "xm+0")
        display.move(, , this.current.w, this.current.h)

        ; ImagePut child window styles: WS_CHILD | WS_VISIBLE | WS_EX_LAYERED
        windowStyles := ImagePainter.WS_CHILD | ImagePainter.WS_VISIBLE | ImagePainter.WS_EX_LAYERED
        ImageShow(this.current.image, , [0, 0], windowStyles, , display.hwnd)
    }

    _showAtPosition() {
        halfHeight := Floor(this.current.h / 2)
        posX := this.current.x + this.margin.x
        posY := this.current.y - halfHeight + this.margin.y
        this.window.Show("X" posX " Y" posY " AutoSize NA")
        this.windowVisible := true
    }
}
