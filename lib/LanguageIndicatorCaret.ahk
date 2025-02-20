; Add extra mark to the text caret (aka blinking cursor) depending on input language and capslock state.
; Script is lookin into "./carets/" folder for files like "1-capslock.png", "2.png", etc.

#SingleInstance Force
#requires AutoHotkey v2.0

#include DebugCaret.ahk
#include GetCapslockState.ahk
#include GetCaretRect.ahk
#include GetInputLocaleIndex.ahk
#include ImagePut.ahk

global debug := false ; captain obvious
global capslockSuffix := "-capslock"
global marginX := 1 ; mark's margin from the caret itself
global marginY := -1
global crt := Object() ; global storage of script state

crt.folder := A_ScriptDir . "\carets\"
crt.extensions := [".png", ".gif"]
crt.markWindow := -1 ; GUI's window to render caret's mark
crt.markPath := -1
crt.isShown := 0
crt.localeIndex := -1 ; init, later 1, 2, 3...
crt.prev := { x: -1, y: -1, markPath: crt.markPath }

RunCaret()
RunCaret() {
	SetTimer CheckCaret, 50 ; main routine, to be executed every 50 milliseconds
}

; Checks if caret reflect current input locale or capslock state
CheckCaret() {
	global
	crt.markPath := GetImagePath() ; returns "\carets\2.png" is file exist and language=2, otherwise -1
	if (crt.markPath == -1) {
		HideMark()
		return
	}

	top := -1, left := -1, bottom := -1, right := -1
	w := 0, h := 0

	GetCaretRect(&left, &top, &right, &bottom, &detectMethod)
	w := right - left
	h := bottom - top

	if (debug)
		DebugCaret(&left, &top, &right, &bottom, &detectMethod)

	if (InStr(detectMethod, "failure") or w < 1) {
		HideMark()
		return
	}
	PaintMark(right, top)
}

PaintMark(x := -1, y := -1) {
	global
	if (x == -1 or y == -1 or crt.markPath == -1) {
		HideMark()
		return
	}

	if (crt.markWindow != -1) {
		if (crt.prev.x == x and crt.prev.y == y) {
			if (crt.prev.markPath == crt.markPath) {
				return ; same caret mark + at the same position = no repaint
			}
		}
	}

	w := ImageWidth(crt.markPath)
	h := ImageHeight(crt.markPath)
	halfMarkHeight := Floor(h / 2)

	if (crt.markWindow == -1 or crt.prev.markPath != crt.markPath) {
		crt.prev.markPath := crt.markPath
		InitMark()
	}

	showOptions := "X" x + marginX " Y" y - halfMarkHeight + marginY " AutoSize NA"
	crt.markWindow.Show(showOptions)
	crt.isShown := 1
	crt.prev.x := x
	crt.prev.y := y

	; create or recreate transparent window for a caret mark's image
	InitMark() {
		if (crt.markWindow != -1)
			crt.markWindow.Destroy()

		backgroundColor := "FFFFFF"
		minSize := " +MinSize" w "x" h
		maxSize := " +MaxSize" w "x" h

		; GUI to be transparent and not affected by DPI scaling
		crt.markWindow := Gui("+LastFound -Caption +AlwaysOnTop +ToolWindow -Border -DPIScale -Resize" minSize maxSize)
		crt.markWindow.MarginX := 0
		crt.markWindow.MarginY := 0
		crt.markWindow.Title := ""
		crt.markWindow.BackColor := backgroundColor
		WinSetTransColor(backgroundColor, crt.markWindow)

		; create a dummy control to repurpose for ImagePut's functionality
		display := crt.markWindow.Add("Text", "xm+0")
		display.Move(, , w, h) ; must resize the viewable area of the control
		; use ImagePut to create a child window, and set the parent as the text control
		image_hwnd := ImageShow(crt.markPath, , [0, 0], 0x40000000 | 0x10000000 | 0x8000000, , display.hwnd)
	}
}

HideMark() {
	global
	if (crt.markWindow == -1 or crt.isShown == 0) {
		return
	}
	crt.markWindow.Hide()
	crt.isShown := 0
	crt.markPath := -1
	crt.prev.markPath := crt.markPath
}

GetImagePath() {
	crt.localeIndex := GetInputLocaleIndex()

	for Ext in crt.extensions {
		if (GetCapslockState() == 1) {
			path := crt.folder . crt.localeIndex . capslockSuffix . Ext ; e.g. "\carets\1-capslock.png"
			if (FileExist(path))
				return path ; capslock-suffixed file to be used
		}
		; fallback if no capslock-suffixed file found
		path := crt.folder . crt.localeIndex . Ext ; e.g. "\carets\1.png"
		if (FileExist(path))
			return path
	}
	return -1
}