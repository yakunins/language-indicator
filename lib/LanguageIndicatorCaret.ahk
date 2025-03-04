; Add extra mark to the text caret (aka blinking cursor) depending on input language and capslock state.
; Script is lookin into "./carets/" folder for files like "1-capslock.png", "2.png", etc.

#singleinstance force
#requires AutoHotkey v2.0

f1:: ExitApp

#include GetCapslockState.ahk
#include GetInputLocaleIndex.ahk
#include GetCaretRect.ahk
#include ImagePainter.ahk ; based on ImagePut.ahk
#include UseBase64Image.ahk
#include OnFrameRate.ahk
#include DebugCaretPosition.ahk
#include Log.ahk

if !IsSet(cfg)
	global cfg := {}

cfg.caret := {
	debug: false,
	files: {
		folder: A_ScriptDir . "\carets\",
		extensions: [".png", ".gif"]
	},
	markMargin: { x: 1, y: -1 },
	updatePeriod: 50,
}

if !IsSet(state)
	global state := {}
InitCaretState()

global caretMark := ImagePainter()
caretMark.margin := cfg.caret.markMargin

RunCaret()
RunCaret() {
	SetTimer(CheckCaret, cfg.caret.updatePeriod)
	OnExit(ExitFunc)
}

; Checks if caret reflect current input locale or capslock state
CheckCaret() {
	global cfg, state

	state.prev := state.Clone() ; copying
	state.prev.DeleteProp("prev")
	state.locale := GetInputLocaleIndex()
	state.capslock := GetCapslockState()

	; performance optimization?
	if (state.locale == state.prev.locale and
		state.capslock == state.prev.capslock) {
		if (state.caretMarkName == "")
			return ; no changes detected
	}

	if !DirExist(cfg.caret.files.folder) ; no folder, then UseBase64Image.ahk
		UseEmbeddedImage() ; use embedded base64 image
	else
		UseImageFromFile() ; use caret mark from file system
}

UseEmbeddedImage() {
	state.caretMarkName := GetMarkName()
	if (state.caretMarkName == "") {
		caretMark.RemoveImage()
		return
	}

	mark := UseBase64Image(state.caretMarkName) ; { name: <str>, image: <path | base64> }
	PaintCaretMark(mark) ; repaint mark every ~cfg.caret.updatePeriod...
	OnFrameRate(() => PaintCaretMark(mark), cfg.caret.updatePeriod) ; ...repaint mark on frames between
}

UseImageFromFile() {
	state.caretMarkName := GetMarkName()
	if (state.caretMarkName == "") {
		caretMark.RemoveImage()
		return
	}

	mark := { name: state.caretMarkName, image: GetCaretMarkFile() } ; { name: <str>, image: <path | base64> }
	PaintCaretMark(mark) ; repaint mark every ~cfg.caret.updatePeriod...
	OnFrameRate(() => PaintCaretMark(mark), cfg.caret.updatePeriod) ; ...repaint mark on frames between
}

; (no capslock + initial language) → 0
; (capslock + initial language) → "arrow_white_9px"
; (no capslock + second language) → "circle_red_9px"
GetMarkName() {
	global state
	if (state.locale == 1 and state.capslock == 0)
		return "" ; no mark

	figures := Map("0", "circle", "1", "arrow")
	colors := Map("1", "white", "2", "red", "3", "green", 4, "blue")
	sizes := ["9px", "12px"]

	figure := figures.Get("" . state.capslock, "undefined")
	color := colors.Get("" . state.locale, "undefined")
	size := sizes[2]

	imageName := figure "_" color "_" size
	return imageName
}


GetCaretMarkFile() {
	for ext in cfg.caret.files.extensions {
		if (GetCapslockState() == 1) {
			path := cfg.caret.files.folder . state.locale . cfg.caret.files.capslockSuffix . ext ; e.g. "carets\1-capslock.png"
			if (FileExist(path))
				return path ; capslock-suffixed file to be used
		}
		; fallback if no capslock file found
		path := cfg.caret.files.folder . state.locale . ext ; e.g. "\carets\1.png"
		if (FileExist(path))
			return path
	}
	return ""
}

; markObj := { name: ..., image: ...}
PaintCaretMark(markObj, cursor := "IBeam") {
	global cfg, caretMark

	if (!markObj.image or 2 > StrLen(markObj.image)) { ; no image
		caretMark.RemoveImage()
		caretMark.Clear()
		return
	}

	top := -1, left := -1, bottom := -1, right := -1
	w := 0, h := 0
	GetCaretRect(&left, &top, &right, &bottom, &detectMethod)
	w := right - left
	h := bottom - top

	if (cfg.caret.debug)
		DebugCaretPosition(&left, &top, &right, &bottom, &detectMethod)

	if (InStr(detectMethod, "failure") or (w < 1 and h < 1)) {
		caretMark.HideImage()
		return
	}

	caretMark.StorePrev()
	caretMark.img.name := markObj.name
	caretMark.img.image := markObj.image
	caretMark.img.x := left
	caretMark.img.y := top

	caretMark.Paint()
}

InitCaretState() {
	global state
	state.locale := GetInputLocaleIndex()
	state.capslock := GetCapslockState()
	state.caretMarkName := ""
	state.caretMarkImage := ""
	state.prev := state
}

ExitFunc(ExitReason, ExitCode) {
	if !(ExitReason ~= "^(?i:Logoff|Shutdown)$")
		caretMark.RemoveImage()
}