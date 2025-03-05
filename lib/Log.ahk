#requires AutoHotkey v2.0
#include Jsons.ahk

; simple version
Log(val, x := 400, y := 200, t := -1000) {
	CoordMode("ToolTip", "Screen")
	if (Type(val) == "String") {
		ToolTip(val, x, y)
	} else {
		ToolTip(Jsons.Dump(val, 2), x, y)
	}
	SetTimer () => ToolTip(), t
}

; state of tooltips
if !IsSet(ttstt)
	global ttstt := { counter: 1 }

ttcfg := {
	initPos: { x: 200, y: 100 },
	shift: 40
}

Logg(val, x := "", y := "", t := -1000) {
	global ttstt

	pos := { x: x, y: y }
	if (x == "" and y == "") {
		pos.x := ttcfg.initPos.x
		pos.y := ttcfg.initPos.y + ttstt.counter * ttcfg.shift
	}

	if (Type(val) == "String") {
		ToolTip(val, pos.x, pos.y, ttstt.counter)
	} else {
		ToolTip(Jsons.Dump(val, 2), pos.x, pos.y, ttstt.counter)
	}

	cc := ttstt.counter ; save copy of counter's value
	ttstt.counter += 1
	if (ttstt.counter > 20)
		ttstt.counter := 1

	SetTimer(() => ToolTip(, , , cc), t) ; cleanup
}