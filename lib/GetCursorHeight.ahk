#requires AutoHotkey v2.0

global defaultCursorHeight := 32

GetSystemCursorHeight() {
    height := SysGet(14) ; SM_CYCURSOR, https://www.autohotkey.com/docs/v2/lib/SysGet.htm

    if height == 0 {
        error := "Failed to retrieve system cursor size"
        return defaultCursorHeight
    }

    return height
}