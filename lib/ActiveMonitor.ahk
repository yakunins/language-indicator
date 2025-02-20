#Requires AutoHotkey v2.0
#include Log.ahk
#include Jsons.ahk

class ActiveMonitor {
	static id := -1
	static monitorCount := 0
	static activeWindow := 0
	static monRect := { l: -1, t: -1, r: -1, b: -1 }
	static winRect := { l: -1, t: -1, r: -1, b: -1, cx: -1, cy: -1 }
	static winScaled := { l: -1, t: -1, r: -1, b: -1, cx: -1, cy: -1 }

	static init(&monL?, &monT?, &monR?, &monB?) {
		this.activeWindow := this.getActiveWinRect()
		this.id := this.getActiveMonitor()

		monL := this.monRect.l
		monT := this.monRect.t
		monR := this.monRect.r
		monB := this.monRect.b

		return this.id
	}

	static status() {
		s1 := "monitor id: " this.id "`n"
		s2 := "monitor count: " this.monitorCount "`n"
		s3 := "monitor rect: " Jsons.Dump(this.monRect) "`n"
		s4 := "active window: " this.activeWindow "`n"
		s5 := "active window rect: " Jsons.Dump(this.winRect) "`n"
		s5 := "active window scaled: " Jsons.Dump(this.winScaled) "`n"
		return s1 s2 s3 s4 s5
	}

	; obtains active window's position across all monitors
	static getActiveWinRect() {
		try {
			activeWindow := this.getActiveHWND()
			scale := this.getActiveWinScale()
			winW := -1, winH := -1 ;
			this.getActiveWinPosEx(&wl, &wt, &winW, &winH)
			wr := wl + winW
			wb := wt + winH
			this.winRect.l := wl
			this.winRect.t := wt
			this.winRect.r := wr
			this.winRect.b := wb
			this.winRect.cx := Round((this.winRect.r + this.winRect.l) / 2) ; win center x
			this.winRect.cy := Round((this.winRect.b + this.winRect.t) / 2)

			this.winScaled.l := wl
			this.winScaled.t := wt
			this.winScaled.r := Round(wl + winW * scale)
			this.winScaled.b := Round(wt + winH * scale)
			this.winScaled.cx := Round((this.winScaled.r + this.winScaled.l) / 2)
			this.winScaled.cy := Round((this.winScaled.b + this.winScaled.t) / 2)

			return activeWindow
		} catch as e {
			Log(e)
			return false
		}
	}

	; get monitor of active window
	static getActiveMonitor() {
		this.activeWindow := this.getActiveWinRect()

		if (this.activeWindow) {
			this.id := this.posToMonitor(this.winScaled.cx, this.winScaled.cy)
			return this.id
		}

		if (this.id > 0)
			return this.id ; last active monitor

		return 1 ; primary monitor
	}

	static posToMonitor(posX, posY) {
		this.monitorCount := SysGet(SM_CMONITORS := 80)
		monitor := 1

		while true {
			if (monitor > this.monitorCount) {
				; throw Error("Point (posX, posY) is outside of any monitor")
				break
			}
			MonitorGet(monitor, &ml, &mt, &mr, &mb)

			if (posX >= ml and posX < mr and posY >= mt and posY < mb) {
				this.id := monitor
				this.monRect.l := ml
				this.monRect.t := mt
				this.monRect.r := mr
				this.monRect.b := mb
				return this.id
			}
			monitor++
		}
		return this.id ; last active monitor
	}

	static getActiveHWND() {
		hwnd := -1
		try {
			hwnd := WinGetID("A") ; attempt to get HWND
		} catch as e {
			hwnd := 0
		}
		return hwnd
	}

	static getActiveWinScale() {
		hwnd := this.getActiveHWND()
		if winDpi := DllCall("GetDpiForWindow", "ptr", hwnd, "uint")
			return A_ScreenDPI / winDpi
		return 1
	}

	static getActiveWinPosEx(&X, &Y, &Width?, &Height?, &Offset_X?, &Offset_Y?) {
		hWindow := this.getActiveHWND()
		Static S_OK := 0x0,
			DWMWA_EXTENDED_FRAME_BOUNDS := 9

		RECTPlus := Buffer(24, 0)
		try {
			DWMRC := DllCall("dwmapi\DwmGetWindowAttribute",
				"Ptr", hWindow,                     ;-- hwnd
				"UInt", DWMWA_EXTENDED_FRAME_BOUNDS, ;-- dwAttribute
				"Ptr", RECTPlus,                    ;-- pvAttribute
				"UInt", 16,                          ;-- cbAttribute
				"UInt")
		} catch as e {
			return false
		}

		X := NumGet(RECTPlus, 0, "Int") ; left
		Y := NumGet(RECTPlus, 4, "Int") ; top
		R := NumGet(RECTPlus, 8, "Int") ; right
		B := NumGet(RECTPlus, 12, "Int") ; bottom

		Width := R - X
		Height := B - Y
		OffSet_X := 0
		OffSet_Y := 0

		RECT := Buffer(16, 0)
		DllCall("GetWindowRect", "Ptr", hWindow, "Ptr", RECT)

		GWR_Width := NumGet(RECT, 8, "Int") - NumGet(RECT, 0, "Int")
		GWR_Height := NumGet(RECT, 12, "Int") - NumGet(RECT, 4, "Int")

		NumPut("Int", Offset_X := (Width - GWR_Width) // 2, RECTPlus, 16)
		NumPut("Int", Offset_Y := (Height - GWR_Height) // 2, RECTPlus, 20)
		return RECTPlus
	}
}