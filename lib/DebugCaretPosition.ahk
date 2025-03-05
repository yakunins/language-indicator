#Requires AutoHotkey v2.0

#include ActiveMonitor.ahk
#include Log.ahk

DebugCaretPosition(&l, &t, &r, &b, &detectMethod) {
	win := ActiveMonitor.getActiveWinRect()
	winRect := ActiveMonitor.winRect
	posData := ""

	if (win) {
		winCenterX := Round((winRect.r + winRect.l) / 2)
		winCenterY := Round((winRect.b + winRect.t) / 2)
		isCaretOutside := false
		if (l < winRect.l or r > winRect.r or t < winRect.t or b > winRect.b)
			isCaretOutside := true

		if (isCaretOutside) {
			; set caret to the center of window
			posData .= "(outside of window!) "
		}
	}
	method := 'detection method:  ' detectMethod "`n"
	monitorID := ActiveMonitor.init(&monL, &monT, &monR, &monB)
	posData .= "caret:  l=" l "  t=" t "  W=" r - l "  H=" b - t "`n"
	scale := ActiveMonitor.getActiveWinScale()
	monitorData := "active monitor:  id=" monitorID "  scale=" scale "  l=" monL "  t=" monT "  r=" monR "  b=" monB "`n"
	windowData := "window:  l=" winRect.l "  t=" winRect.t "  r=" winRect.r "  b=" winRect.b "`n"
	virtualScreen := _virtualScreenData() "`n"
	Log(method posData monitorData windowData virtualScreen)
}

_virtualScreenData() {
	; Get the bounding rectangle of all monitors
	monsX := SysGet(76)  ; SM_XVIRTUALSCREEN - left boundary of all monitors
	monsY := SysGet(77)  ; SM_YVIRTUALSCREEN - top boundary of all monitors
	monsW := SysGet(78)  ; SM_CXVIRTUALSCREEN - width of all monitors
	monsH := SysGet(79)  ; SM_CYVIRTUALSCREEN - height of all monitors
	mons := "virtual screen:  x=" monsX "  y=" monsY "  w=" monsW "  h=" monsH "`n"
	return mons
}