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
#include OnFrameRate.ahk
#include UseBase64Image.ahk
#include UseCached.ahk
#include Log.ahk

if !IsSet(cfg)
	global cfg := {}

cfg.cursor := {
	debug: false,
	files: {
		capslockSuffix: "-capslock",
		folderExistCheckPeriod: 1000, ; optimization?
		folder: A_ScriptDir . "\cursors\",
		extensions: [".cur", ".ani", ".ico"],
	},
	markMargin: { x: 11, y: -11 },
	mousePositionPrediction: 0.5, ; reduces lagging in case of embeddded image used as a mark, see GetMousePosPrediction.ahk
	target: {
		cursorId: 32513, ; IDC_ARROW := 32512, IDC_IBEAM := 32513, IDC_WAIT := 32514, ...
		cursorName: "IBeam", ; must be consistent with ↑
	},
	updatePeriod: 100,
}

if IsSet(languageIndicator)
	cfg.cursor.updatePeriod := languageIndicator.updatePeriod

if !IsSet(state)
	global state := {}
InitCursorState()

global cursorMark := ImagePainter()
cursorMark.margin := cfg.cursor.markMargin

RunCursor()
RunCursor() {
	SetTimer(CheckCursor, cfg.cursor.updatePeriod)
	OnExit(CursorExitFunc)
}

; cursor to reflect locale and capslock state
CheckCursor() {
	global cfg, cursorMark
	if (A_Cursor != cfg.cursor.target.cursorName) {
		RevertCursors()
		cursorMark.HideWindow()
		return
	}
	UpdateCursorState()
	CursorsFolderExist()
		? UseCursorFile() ; use cursor from file system
		: UseCursorMarkEmbedded() ; use embedded base64 image to paint a mark near the cursor
}

UseCursorMarkEmbedded() {
	if (state.cursorMarkName == "") {
		cursorMark.RemoveWindow()
		return
	}
	mark := UseBase64Image(state.cursorMarkName) ; { name: <str>, image: <0 | path | base64> }
	PaintCursorMark(mark) ; repaint mark every ~cfg.updatePeriod...
	onFrame.ScheduleRun(() => PaintCursorMark(mark), "cursor", cfg.cursor.updatePeriod) ; ...repaint mark on a few next frames
}
onFrame := OnFrameRateScheduler.Increase() ; must be removed if not used in the line above

UseCursorFile() {
	if (state.cursorFile == "") {
		RevertCursors()
		return
	}
	SetCursorFromFile(state.cursorFile)
}

; (no capslock + initial language) → 0
; (capslock + initial language) → "arrow_white_9px"
; (no capslock + second language) → "circle_red_9px"
GetCursorMarkName(locale := 1, capslock := 0) {
	global cfg
	if (locale == 1 and capslock == 0)
		return "" ; use default cursor

	; see UseBase64Image.ahk
	figures := Map("0", "circle", "1", "arrow")
	colors := Map("1", "white", "2", "red", "3", "green", 4, "blue")
	sizes := ["9px", "12px"]

	figure := figures.Get("" . capslock, "undefined")
	color := colors.Get("" . locale, "undefined")
	size := sizes[2]

	imageName := figure "_" color "_" size
	return imageName
}

GetCursorFile() {
	global cfg
	for ext in cfg.cursor.files.extensions {
		if state.capslock {
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

global modifiedCursorsCount := 0
; https://autohotkey.com/board/topic/32608-changing-the-system-cursor/
SetCursorFromFile(filePath := "") {
	global cfg, modifiedCursorsCount
	if (!filePath or filePath == "") {
		; Log("LanguageIndicatorCursor.ahk: cursor's filePath is not set")
		return
	} else if FileExist(filePath) {
		SplitPath(filePath, , , &ext)
		if !(ext ~= "^(?i:cur|ani|ico)$") {
			; Log("LanguageIndicatorCursor.ahk: invalid file extension, only (ani|cur|ico) allowed")
			return
		}
	} else {
		; Log("LanguageIndicatorCursor.ahk: (" . filePath . ") was not found on disk")
		return
	}
	cursorHandle := DllCall("LoadCursorFromFile", "Str", filePath)
	DllCall("SetSystemCursor", "Uint", cursorHandle, "Int", cfg.cursor.target.cursorId) ; set cursor
	modifiedCursorsCount += 1
}

RevertCursors() {
	global modifiedCursorsCount
	if modifiedCursorsCount == 0
		return

	SPI_SETCURSORS := 0x57
	DllCall("SystemParametersInfo", "UInt", SPI_SETCURSORS, "UInt", 0, "UInt", 0, "UInt", 0) ; reset cursors
	modifiedCursorsCount := 0
}

; markObj := { name: ..., image: ...}
PaintCursorMark(markObj, cursor := "IBeam") {
	global cfg, cursorMark

	if (cursor != 0 and cursor != A_Cursor) { ; cursor not matched
		cursorMark.HideWindow()
		cursorMark.Clear()
		return
	}

	if (!markObj.image or 10 > StrLen(markObj.image)) { ; no image
		cursorMark.RemoveWindow()
		cursorMark.Clear()
		return
	}

	pos := GetMousePos(cfg.cursor.mousePositionPrediction) ; use prediction

	if (pos.x == -1 or pos.x == -1) { ; wrong cursor position
		cursorMark.HideWindow()
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
	if !state.HasOwnProp("prev")
		state.prev := {}
	if !state.HasOwnProp("locale")
		state.locale := 1
	if !state.HasOwnProp("capslock")
		state.capslock := 0
	if !state.HasOwnProp("cursorFile")
		state.cursorFile := ""
	if !state.HasOwnProp("cursorMarkName")
		state.cursorMarkName := ""
}

UpdateCursorState() {
	global state
	state.prev.locale := state.locale
	state.locale := GetInputLocaleIndex()

	state.prev.capslock := state.capslock
	state.capslock := GetCapslockState()

	if CursorsFolderExist() {
		state.prev.cursorFile := state.cursorFile
		state.cursorFile := GetCursorFile()

		state.prev.cursorMarkName := state.cursorMarkName
		state.cursorMarkName := ""
	} else {
		state.prev.cursorMarkName := state.cursorMarkName
		state.cursorMarkName := GetCursorMarkName(state.locale, state.capslock)

		state.prev.cursorFile := state.cursorFile
		state.cursorFile := ""
	}
}

CursorsFolderExist := UseCached(CheckCursorsFolderExist, cfg.cursor.files.folderExistCheckPeriod)
CheckCursorsFolderExist() {
	exist := DirExist(cfg.cursor.files.folder)

	if exist
		OnFrameRateScheduler.Decrease() ; prevent flickering

	return exist
}

CursorExitFunc(ExitReason, ExitCode) {
	if !(ExitReason ~= "^(?i:Logoff|Shutdown)$") {
		RevertCursors()
		cursorMark.RemoveWindow()
	}
}

if cfg.cursor.debug
	Log(cfg)