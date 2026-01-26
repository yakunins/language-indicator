; Returns the current Caps Lock key toggle state
#requires AutoHotkey v2.0

GetCapslockState() {
	return GetKeyState("Capslock", "T")
}