; Returns the current mouse cursor position in screen coordinates
#requires AutoHotkey v2.0
#include ..\utils\Log.ahk

GetMousePos() {
	CoordMode "Mouse", "Screen"
	MouseGetPos(&mx, &my)

	return {
		x: mx,
		y: my
	}
}