#Requires AutoHotkey v2.0

#include ImagePut.ahk
#include images/Base64Images.ahk
#include OnMouseMove.ahk

global marginX := 11 ; mark's margin from the caret itself
global marginY := -11
global img := {} ; script state
img.window := -1
img.name := "circle_red_5px"
img.name := "flag_am"
img.prev := {
    x: -1,
    y: -1,
}
global usePointerPrediction := true

^1:: TogglePrediction
TogglePrediction() {
    global
    usePointerPrediction := usePointerPrediction ? 0 : 1
}
^2:: ShowPos
ShowPos() {
    Log(Jsons.Dump(pstore, "  "), 100, 100)
}

PaintAtCursor() {
    pos := pstore[1].p
    predict := pstore[1].predict

    if usePointerPrediction {
        PaintImage(pos.x + predict.x, pos.y + predict.y)
    } else {
        PaintImage(pos.x, pos.y)
    }
}

OnPointerMoveOrChange(PaintAtCursor)

PaintImage(x := -1, y := -1) {
    if (x == -1 or y == -1 or A_Cursor != "IBeam") {
        HideImage()
        return
    }

    if (img.window != -1) {
        if (img.prev.x == x and img.prev.y == y) {
            return ; same mark + at the same position = no repaint
        }
    }
    image := UseBase64Image(img.name)
    w := ImageWidth(image)
    h := ImageHeight(image)
    halfHeight := Floor(h / 2)

    if (img.window == -1) {
        InitWindow()
    }

    showOptions := "X" x + marginX " Y" y - halfHeight + marginY " AutoSize NA"
    img.window.Show(showOptions)
    img.prev.x := x
    img.prev.y := y

    ; create or recreate transparent window for a caret mark's image
    InitWindow() {
        if (img.window != -1)
            img.window.Destroy()

        backgroundColor := "FFFFFF"
        minSize := " +MinSize" w "x" h
        maxSize := " +MaxSize" w "x" h

        ; GUI to be transparent and not affected by DPI scaling
        img.window := Gui("+LastFound -Caption +AlwaysOnTop +ToolWindow -Border -DPIScale -Resize" minSize maxSize)
        img.window.MarginX := 0
        img.window.MarginY := 0
        img.window.Title := ""
        img.window.BackColor := backgroundColor
        WinSetTransColor(backgroundColor, img.window)

        ; create a dummy control to repurpose for ImagePut's functionality
        display := img.window.Add("Text", "xm+0")
        display.move(, , w, h) ; must resize the viewable area of the control
        ; use ImagePut to create a child window, and set the parent as the text control
        image_hwnd := ImageShow(image, , [0, 0], 0x40000000 | 0x10000000 | 0x8000000, , display.hwnd)
    }
}

HideImage() {
    if img.window != -1 {
        img.window.Hide()
        img.prev.x := -1
        img.prev.y := -1
    }
}