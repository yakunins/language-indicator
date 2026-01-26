; Tracks keyboard input state (locale and capslock) with change detection
#requires AutoHotkey v2.0

#include GetCapslockState.ahk
#include GetInputLocaleIndex.ahk

class InputState {
    locale := 1
    capslock := 0
    prev := {}

    __New() {
        this.prev := {
            locale: 1,
            capslock: 0
        }
    }

    Update() {
        this.prev.locale := this.locale
        this.prev.capslock := this.capslock

        this.locale := GetInputLocaleIndex()
        this.capslock := GetCapslockState()
    }

    HasChanged() {
        return this.locale != this.prev.locale
            or this.capslock != this.prev.capslock
    }

    IsDefault() {
        return this.locale == 1 and this.capslock == 0
    }
}
