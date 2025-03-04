#requires AutoHotkey v2.0
#include Log.ahk

GetMousePos() {
	CoordMode "Mouse", "Screen"
	MouseGetPos(&mx, &my)

	return {
		x: mx,
		y: my
	}
}