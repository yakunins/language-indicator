#SingleInstance Force
#Requires AutoHotkey v2.0

#include lib/GetInputLocaleIndex.ahk
#include lib/ImagePut.ahk
#include lib/GetCaretRect.ahk
#include lib/GetCapslockState.ahk
#include lib/Log.ahk

global capslockSuffix := "-capslock"
global caretMarkFolder := A_ScriptDir . "\carets\"
global caretMarkExtensions := [".png", ".gif"]
global caretMarkWnd := -1 ; GUI's window to render caret's mark
global caretMarkPath := -1
global isMarkPainted := 0 

global marginX := 2
global marginY := -1

global s2 := Object() ; global object for storing script' state
s2.localeIndex := -1 ; init, later 1, 2, 3...
s2.capslockState := -1 ; init, later 0 or 1
s2.prevCaretPos := { x : -1, y : -1 }


RunCaret()
RunCaret() {
	SetTimer CheckCaret, 50 ; main routine, to be executed every 50 milliseconds
}

; Check whether caret mark must be repainted
CheckCaret() {
	global
	s2.prevLocaleIndex := s2.localeIndex
	s2.prevCapslockState := s2.capslockState
	s2.localeIndex := GetInputLocaleIndex()
	s2.capslockState := GetCapslockState()

	if (s2.localeIndex == s2.prevLocaleIndex) and (s2.capslockState == s2.prevCapslockState) {
		if (isMarkPainted == 1) {
			RepaintCaretMark() ; caret position changed
 			return ; nor input locale, neither capslock has been switched
		}
	}

	caretMarkPath := GetImagePath()

	if (caretMarkPath == -1) or (caretMarkPath == 0) {
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
	if (s2.prevCaretPos.x == right and s2.prevCaretPos.y == top) {
		return ; caret at the same position, no repaint
	}
	s2.prevCaretPos := { x: right, y: top }
	PaintMark(right, top)
}

PaintMark(x := -1, y := -1) {
	global
	if (x == -1 or y == -1 or caretMarkPath == -1) {
		HideMark()
		return
	}

	w := ImageWidth(caretMarkPath)
	h := ImageHeight(caretMarkPath)
	halfHeight := Floor(h/2)

	if (caretMarkWnd == -1 or savedCaretMarkPath != caretMarkPath) {
		InitMark()
	}

	showOpts := "X" x + marginX " Y" y - halfHeight + marginY " AutoSize NA"
	caretMarkWnd.Show(showOpts)
	isMarkPainted := 1
	savedCaretMarkPath := caretMarkPath

	; clean and create transparent window for a caret mark's image
	InitMark() {
		if (caretMarkWnd != -1)
			caretMarkWnd.Destroy()
		backgroundColor := "FFFFFF"
	
		minSize := " +MinSize" w "x" h
		maxSize := " +MaxSize" w "x" h
	
		; GUI to be transparent and not affected by DPI scaling
		caretMarkWnd := Gui("+LastFound -Caption +AlwaysOnTop +ToolWindow -Border -DPIScale -Resize" minSize maxSize)
		caretMarkWnd.MarginX := 0
		caretMarkWnd.MarginY := 0
		caretMarkWnd.Title := ""
		caretMarkWnd.BackColor := backgroundColor
		WinSetTransColor(backgroundColor, caretMarkWnd)
		
		; Create a dummy control to repurpose for ImagePut's functionality
		display := caretMarkWnd.Add("Text", "xm+0")
		; Must resize the viewable area of the control
		display.move(,,w,h)
		; Use ImagePut to create a child window, and set the parent as the text control.
		image_hwnd := ImageShow(caretMarkPath,, [0, 0], 0x40000000 | 0x10000000 | 0x8000000,, display.hwnd)
	}
}

HideMark() {
	global
	if (caretMarkWnd == -1) {
		return
	}
	caretMarkWnd.Hide()
	isMarkPainted := 0
}

GetImagePath() {
	for Ext in caretMarkExtensions {
		if (GetCapslockState() = 1) {
			path := caretMarkFolder . s2.localeIndex . capslockSuffix . Ext ; e.g. "\carets\1-capslock.png"
			if (FileExist(path))
				return path ; capslock-suffixed file to be used
		}
		; fallback if no capslock-suffixed file found
		path := caretMarkFolder . s2.localeIndex . Ext ; e.g. "\carets\1.png"
		if (FileExist(path)) 
			return path
	}
	return -1
}
