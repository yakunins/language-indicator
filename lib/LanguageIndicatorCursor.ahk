; Set custom text select pointer or paint a mark nearby, depending on input language and capslock state.

; Script work in this way:
; 1. lookin into "./cursors/" folder for files "1.cur", "1-capslock.cur", "2.cur", etc.
; 2. in case there's no "./cursors/" folder exist, embedded images to be used to set mark near mouse cursor/pointer

#singleinstance force
#requires AutoHotkey v2.0

#include GetInputLocaleIndex.ahk ; https://www.autohotkey.com/boards/viewtopic.php?t=84140
#include GetCapslockState.ahk
#include GetMousePosPrediction.ahk
#include ImagePainter.ahk ; based on ImagePut.ahk
#include UseBase64Image.ahk
#include OnFrameRate.ahk
#include Log.ahk

if !IsSet(cfg)
	global cfg := {}

cfg.cursor := {
	debug: false,
	files: {
		capslockSuffix: "-capslock",
		folder: A_ScriptDir . "\cursors\",
		extensions: [".cur", ".ani", ".ico"],
	},
	markMargin: { x: 11, y: -11 },
	mousePositionPrediction: 0.5, ; reduce lagging: if 0, mark to be painted at previous's frame cursor position, thus
	target: {
		cursorId: 32513, ; To be replaced with DllCall("SetSystemCursor"...), IDC_ARROW := 32512, IDC_IBEAM := 32513, IDC_WAIT := 32514, ...
		cursorName: "IBeam", ; Exit fast if current cursor do not match, must be consistent with ↑
	},
	updatePeriod: 50,
}

if !IsSet(state)
	global state := {}
InitCursorState()

global cursorMark := ImagePainter()
cursorMark.margin := cfg.cursor.markMargin

RunCursor()
RunCursor() {
	SetTimer(CheckCursor, cfg.cursor.updatePeriod)
	OnExit(ExitFunc)
}

; Checks if cursor reflects current input locale and capslock state
CheckCursor() {
	global cfg, state

	state.prev := state.Clone() ; copying
	state.prev.DeleteProp("prev")

	if (A_Cursor != cfg.cursor.target.cursorName) {
		RevertCursors()
		cursorMark.HideImage()
		return
	}

	state.locale := GetInputLocaleIndex()
	state.capslock := GetCapslockState()

	; performance optimization?
	if (state.locale == state.prev.locale and
		state.capslock == state.prev.capslock) {
		if (state.cursorMarkName == "")
			return ; no changes detected
	}

	if !DirExist(cfg.cursor.files.folder) ; no folder, then UseBase64Image.ahk
		UseEmbeddedImage() ; use embedded base64 image to paint a mark near the cursor
	else
		UseCursorFile() ; use cursor from file system
}

UseEmbeddedImage() {
	state.cursorMarkName := GetMarkName()
	if (state.cursorMarkName == "") {
		cursorMark.RemoveImage()
		return
	}

	mark := UseBase64Image(state.cursorMarkName) ; { name: ..., image: ...}
	PaintCursorMark(mark) ; repaint mark every ~cfg.cursor.updatePeriod...
	OnFrameRate(() => PaintCursorMark(mark), cfg.cursor.updatePeriod) ; repaint mark on a few next frames
}

UseCursorFile() {
	state.cursorFile := GetCursorFile()
	if (state.cursorFile == "")
		RevertCursors()
	else
		SetCursorFromFile(state.cursorFile)
}

GetCursorFile() {
	for ext in cfg.cursor.files.extensions {
		if (GetCapslockState() == 1) {
			path := cfg.cursor.files.folder . state.locale . cfg.cursor.files.capslockSuffix . ext ; e.g. "cursors\1-capslock.cur"
			if (FileExist(path))
				return path ; capslock-suffixed file to be used
		}
		; fallback if no capslock file found
		path := cfg.cursor.files.folder . state.locale . ext ; e.g. "\cursors\1.cur"
		if (FileExist(path))
			return path
	}
	return ""
}

; (no capslock + initial language) → 0
; (capslock + initial language) → "arrow_white_9px"
; (no capslock + second language) → "circle_red_9px"
GetMarkName() {
	global state
	if (state.locale == 1 and state.capslock == 0)
		return "" ; use default cursor

	figures := Map("0", "circle", "1", "arrow")
	colors := Map("1", "white", "2", "red", "3", "green", 4, "blue")
	sizes := ["9px", "12px"]

	figure := figures.Get("" . state.capslock, "undefined")
	color := colors.Get("" . state.locale, "undefined")
	size := sizes[2]

	imageName := figure "_" color "_" size
	return imageName
}

; https://autohotkey.com/board/topic/32608-changing-the-system-cursor/
SetCursorFromFile(filePath := "") {
	global cfg, state
	if (!filePath or filePath == "") {
		; Log("LanguageIndicatorCursor.ahk: filename is not set (SetCursorFromFile)")
		return
	} else if FileExist(filePath) {
		SplitPath(filePath, , , &ext) ; auto-detect type
		if !(ext ~= "^(?i:cur|ani|ico)$") {
			; Log("LanguageIndicatorCursor.ahk: invalid file extension, only (ani|cur|ico) allowed")
			return
		}
	} else {
		; Log("LanguageIndicatorCursor.ahk: (" . filePath . ") was not found on disk")
		return
	}

	cursorHandle := DllCall("LoadCursorFromFile", "Str", filePath)
	DllCall("SetSystemCursor", "Uint", cursorHandle, "Int", cfg.cursor.target.cursorId) ; replaces cursor at cursorID with CursorHandle
	state.cursorFile := filePath
}

ResetCursors() {
	global state
	SPI_SETCURSORS := 0x57
	DllCall("SystemParametersInfo", "UInt", SPI_SETCURSORS, "UInt", 0, "UInt", 0, "UInt", 0)
	state.cursorFile := ""
}

; Restore cursors if they were modified
RevertCursors() {
	global state
	if (state.cursorFile != "")
		ResetCursors()
}

; markObj := { name: ..., image: ...}
PaintCursorMark(markObj, cursor := "IBeam") {
	global cfg, cursorMark

	if (cursor != 0 and cursor != A_Cursor) { ; cursor not matched
		cursorMark.HideImage()
		cursorMark.Clear()
		return
	}

	if (!markObj.image or 10 > StrLen(markObj.image)) { ; no image
		cursorMark.RemoveImage()
		cursorMark.Clear()
		return
	}

	pos := GetMousePos(cfg.cursor.mousePositionPrediction) ; use prediction

	if (pos.x == -1 or pos.x == -1) { ; wrong cursor position
		cursorMark.HideImage()
		cursorMark.Clear()
		return
	}

	cursorMark.StorePrev()
	cursorMark.img.name := markObj.name
	cursorMark.img.image := markObj.image
	cursorMark.img.x := pos.x
	cursorMark.img.y := pos.y

	cursorMark.Paint()
}

InitCursorState() {
	global state
	state.locale := GetInputLocaleIndex()
	state.capslock := GetCapslockState()
	state.cursorFile := ""
	state.cursorMarkName := ""
	state.prev := state
}

ExitFunc(ExitReason, ExitCode) {
	if !(ExitReason ~= "^(?i:Logoff|Shutdown)$") {
		ResetCursors()
		cursorMark.RemoveImage()
	}
}