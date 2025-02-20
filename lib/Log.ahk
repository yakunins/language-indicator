#Requires AutoHotkey v2.0
#include Jsons.ahk

Log(val, x := 500, y := 500, t := -500) {
	if (Type(val) == "String") {
		ToolTip(val, x, y)
	} else {
		ToolTip(Jsons.Dump(val), x, y)
	}
	SetTimer () => ToolTip(), t
}