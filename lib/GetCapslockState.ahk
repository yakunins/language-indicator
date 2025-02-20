#requires AutoHotkey v2.0

GetCapslockState() {
	return GetKeyState("Capslock", "T")
}