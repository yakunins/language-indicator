#SingleInstance Force
#Requires AutoHotkey v2.0

#include lib/GetInputLocaleIndex.ahk
#include lib/ImagePut.ahk
#include lib/GetCaretRect.ahk
#include lib/GetCapslockState.ahk
;#include lib/Log.ahk
;#include lib/Jsons.ahk ; Jsons.Dump + Jsons.Load

global capslockSuffix := "-capslock"
global caretMarkFolder := A_ScriptDir . "\carets\"
global caretMarkExtensions := [".png", ".gif"]

global marginX := 2
global marginY := -1

global crt := Object() ; global storage of script state
crt.markWnd := -1 ; GUI's window to render caret's mark
crt.markPath := -1
crt.isShown := 0
crt.localeIndex := -1 ; init, later 1, 2, 3...
crt.capslockState := -1 ; init, later 0 or 1
crt.prev := { x : -1, y : -1, markPath : crt.markPath }

RunCaret()
RunCaret() {
	SetTimer CheckCaret, 50 ; main routine, to be executed every 50 milliseconds
}

; Checks if caret reflect current input locale or capslock state
CheckCaret() {
	global
	crt.prev.localeIndex := crt.localeIndex
	crt.prev.capslockState := crt.capslockState
	crt.localeIndex := GetInputLocaleIndex()
	crt.capslockState := GetCapslockState()

	if (crt.localeIndex == crt.prev.localeIndex and crt.capslockState == crt.prev.capslockState) {
		if (crt.isShown == 1) {
			crt.prev.markPath := crt.markPath
			RepaintCaretMark() ; reflect caret position change
 			return ; nor input locale, neither capslock has been switched
		}
	}

	crt.prev.markPath := crt.markPath
	crt.markPath := GetImagePath()

	if (crt.markPath == -1 or crt.markPath == 0) {
		HideMark()
		return
	}

	RepaintCaretMark()
}

RepaintCaretMark() {
	left := -1
	top := -1
	GetCaretRect(&left?, &top?, &right?, &bottom?, &detectMethod)
	if (detectMethod == "failure" or (left < 0 or top < 0)) {
		HideMark()
		return
	}
	w := right - left
	h := bottom - top
	if (w < 1) {
		HideMark() ; invisible caret?
		return
	}
	if (crt.prev.x == right and crt.prev.y == top) {
		if (crt.prev.markPath == crt.markPath) {
			return ; same caret + at the same position = no repaint
		}
	}
	crt.prev.x := right
	crt.prev.y := top
	PaintMark(right, top)
}

PaintMark(x := -1, y := -1) {
	global
	if (x == -1 or y == -1 or crt.markPath == -1) {
		HideMark()
		return
	}

	w := ImageWidth(crt.markPath)
	h := ImageHeight(crt.markPath)
	halfHeight := Floor(h/2)

	if (crt.markWnd == -1 or crt.prev.markPath != crt.markPath) {
		InitMark()
	}

	showOpts := "X" x + marginX " Y" y - halfHeight + marginY " AutoSize NA"
	crt.markWnd.Show(showOpts)
	crt.isShown := 1

	; clean and create transparent window for a caret mark's image
	InitMark() {
		if (crt.markWnd != -1)
			crt.markWnd.Destroy()
		backgroundColor := "FFFFFF"
	
		minSize := " +MinSize" w "x" h
		maxSize := " +MaxSize" w "x" h
	
		; GUI to be transparent and not affected by DPI scaling
		crt.markWnd := Gui("+LastFound -Caption +AlwaysOnTop +ToolWindow -Border -DPIScale -Resize" minSize maxSize)
		crt.markWnd.MarginX := 0
		crt.markWnd.MarginY := 0
		crt.markWnd.Title := ""
		crt.markWnd.BackColor := backgroundColor
		WinSetTransColor(backgroundColor, crt.markWnd)
		
		; Create a dummy control to repurpose for ImagePut's functionality
		display := crt.markWnd.Add("Text", "xm+0")
		; Must resize the viewable area of the control
		display.move(,,w,h)
		; Use ImagePut to create a child window, and set the parent as the text control.
		image_hwnd := ImageShow(crt.markPath,, [0, 0], 0x40000000 | 0x10000000 | 0x8000000,, display.hwnd)
	}
}

HideMark() {
	global
	if (crt.markWnd == -1) {
		return
	}
	crt.markWnd.Hide()
	crt.isShown := 0
}

GetImagePath() {
	for Ext in caretMarkExtensions {
		if (GetCapslockState() == 1) {
			path := caretMarkFolder . crt.localeIndex . capslockSuffix . Ext ; e.g. "\carets\1-capslock.png"
			if (FileExist(path))
				return path ; capslock-suffixed file to be used
		}
		; fallback if no capslock-suffixed file found
		path := caretMarkFolder . crt.localeIndex . Ext ; e.g. "\carets\1.png"
		if (FileExist(path)) 
			return path
	}
	return -1
}
