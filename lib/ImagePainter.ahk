#requires AutoHotkey v2.0
#include ImagePut.ahk

class ImagePainter {
    zero := { image: "", name: "", x: "", y: "", time: -1 }
    window := -1
    margin := { x: 0, y: 0 } ; margin from the cursor's center
    img := {} ; script' state

    __New() {
        this.ClearAll()
    }

    Clear() {
        this.img := this.zero
    }

    ClearAll() {
        this.img := this.zero
        this.img.prev := this.zero
    }

    StorePrev() {
        this.img.prev := this.img.Clone()
        this.img.prev.DeleteProp("prev")
    }

    Paint() {
        if (this.img.x == "" or this.img.y == "" or this.img.image == "") {
            this.Clear()
            return
        }

        if (this.window != -1) { ; already painted
            if (this.img.x == this.img.prev.x and
                this.img.y == this.img.prev.y and
                this.img.name == this.img.prev.name) {
                return ; skip repaint if same image and pos
            }

            if (this.img.name != this.img.prev.name or
                this.img.image != this.img.prev.image) {
                this.RemoveWindow() ; different image, init required
            }
        }

        ; this.img.image must be <filePath | base64>, see https://github.com/iseahound/ImagePut/wiki/Input-Types-&-Output-Functions#input-types
        this.img.w := ImageWidth(this.img.image)
        this.img.h := ImageHeight(this.img.image)

        if (this.window == -1) {
            this.InitWindow()
        }

        halfHeight := Floor(this.img.h / 2)
        showOptions := "X" this.img.x + this.margin.x " Y" this.img.y - halfHeight + this.margin.y " AutoSize NA"
        this.window.Show(showOptions) ; real paint
    }

    ; create or recreate transparent window for a caret mark's image
    InitWindow() {
        if (this.window != -1)
            this.window.Destroy()

        bgColor := "ffffff"
        minSize := " +MinSize" this.img.w "x" this.img.h
        maxSize := " +MaxSize" this.img.w "x" this.img.h

        ; GUI to be transparent and not affected by DPI scaling
        this.window := Gui("+LastFound -Caption +AlwaysOnTop +ToolWindow -Border -DPIScale -Resize" minSize maxSize)
        this.window.MarginX := 0
        this.window.MarginY := 0
        this.window.Title := ""
        this.window.BackColor := bgColor
        WinSetTransColor(bgColor, this.window)

        display := this.window.Add("Text", "xm+0") ; create a dummy control to repurpose for ImagePut's functionality
        display.move(, , this.img.w, this.img.h) ; must resize the viewable area of the control
        ; use ImagePut to create a child window, and set the parent as the text control
        image_hwnd := ImageShow(this.img.image, , [0, 0], 0x40000000 | 0x10000000 | 0x8000000, , display.hwnd)
    }

    RemoveWindow() {
        if this.window != -1 {
            this.window.Destroy()
            this.window := -1
        }
    }

    HideWindow() {
        if this.window != -1 {
            this.window.Hide()
        }
    }
}