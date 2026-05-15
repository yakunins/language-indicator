; Tracks whether any keyboard key or mouse button is currently pressed.
; The InputHook installs the keyboard hook as a side effect, which also makes
; A_TimeIdleKeyboard track physical keyboard input correctly.
;
; The hook + hotkeys are installed lazily on the first call to GetAnyKeyState().
;
; Example:
;   if GetAnyKeyState()
;       ; user is currently holding down a key or mouse button
#requires AutoHotkey v2.0

class AnyKeyState {
    static pressed := false
    static _initialized := false
    static _hook := ""

    static Init() {
        if this._initialized
            return
        this._initialized := true

        this._hook := InputHook("V")
        this._hook.KeyOpt("{All}", "N")
        this._hook.OnKeyDown := (*) => AnyKeyState.pressed := true
        this._hook.OnKeyUp   := (*) => AnyKeyState.pressed := false
        this._hook.Start()

        Hotkey "~*LButton",     (*) => AnyKeyState.pressed := true
        Hotkey "~*RButton",     (*) => AnyKeyState.pressed := true
        Hotkey "~*MButton",     (*) => AnyKeyState.pressed := true
        Hotkey "~*XButton1",    (*) => AnyKeyState.pressed := true
        Hotkey "~*XButton2",    (*) => AnyKeyState.pressed := true
        Hotkey "~*LButton Up",  (*) => AnyKeyState.pressed := false
        Hotkey "~*RButton Up",  (*) => AnyKeyState.pressed := false
        Hotkey "~*MButton Up",  (*) => AnyKeyState.pressed := false
        Hotkey "~*XButton1 Up", (*) => AnyKeyState.pressed := false
        Hotkey "~*XButton2 Up", (*) => AnyKeyState.pressed := false
    }
}

GetAnyKeyState() {
    AnyKeyState.Init()
    return AnyKeyState.pressed
}
