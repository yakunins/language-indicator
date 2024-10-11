#Requires AutoHotkey v2.0

defaultPosition := {
	x: A_ScreenWidth - 48,
	y: A_ScreenHeight - 48
}
defaultPeriod := 1000 ; 1 second

Log(val, x := defaultPosition.x, y := defaultPosition.y, t := defaultPeriod * -1) {
	CoordMode "ToolTip"
	ToolTip("`n" val, x, y)

	SetTimer Close, t > 0 ? t * -1 : t
}

Close() {
	ToolTip()
}

; tests
;Log("test1")
;Log("test2", 1000, 1000)
;Log("test3", , , 2000)