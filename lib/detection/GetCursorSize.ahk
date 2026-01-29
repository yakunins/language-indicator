; Detects the current mouse cursor dimensions
#requires AutoHotkey v2.0

GetCursorSize(&w, &h) {
    w := 32, h := 32  ; defaults

    ; Get cursor handle via GetCursorInfo
    cursorInfo := Buffer(16 + A_PtrSize, 0)
    NumPut("uint", cursorInfo.Size, cursorInfo, 0)
    if !DllCall("GetCursorInfo", "ptr", cursorInfo)
        return false

    hCursor := NumGet(cursorInfo, 8, "ptr")
    if !hCursor
        return false

    ; Get icon/cursor bitmap info
    iconInfo := Buffer(8 + A_PtrSize * 3, 0)
    if !DllCall("GetIconInfo", "ptr", hCursor, "ptr", iconInfo)
        return false

    hbmMask := NumGet(iconInfo, 8 + A_PtrSize, "ptr")
    hbmColor := NumGet(iconInfo, 8 + A_PtrSize * 2, "ptr")

    ; Get bitmap dimensions
    bmp := Buffer(24, 0)
    hBitmap := hbmColor ? hbmColor : hbmMask
    if DllCall("GetObject", "ptr", hBitmap, "int", 24, "ptr", bmp) {
        w := NumGet(bmp, 4, "int")
        h := NumGet(bmp, 8, "int")
    }

    ; Cleanup GDI objects
    if hbmMask
        DllCall("DeleteObject", "ptr", hbmMask)
    if hbmColor
        DllCall("DeleteObject", "ptr", hbmColor)

    return true
}

GetDefaultCursorSize(&w, &h) {
    w := SysGet(13)  ; SM_CXCURSOR
    h := SysGet(14)  ; SM_CYCURSOR
}

GetCursorScale() {
    try {
        ; Windows 10/11 cursor size setting (1-15, default is 1)
        size := RegRead("HKCU\Control Panel\Cursors", "CursorBaseSize")
        return size / 32  ; Returns scale factor (1.0 = normal)
    } catch {
        return 1
    }
}

GetScaledCursorSize(&w, &h) {
    GetDefaultCursorSize(&baseW, &baseH)
    scale := GetCursorScale()
    w := Round(baseW * scale)
    h := Round(baseH * scale)
}
