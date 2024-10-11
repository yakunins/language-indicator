; Set custom text select pointer (mouse cursor) depending on input language and capslock state.
; Script is lookin into "./cursors/" folder for files "1.cur", "1-capslock.cur", "2.cur", etc.

; https://www.autohotkey.com/boards/viewtopic.php?t=84140
#SingleInstance Force
#Requires AutoHotkey v2.0

#include GetInputLocaleIndex.ahk
#include GetCapslockState.ahk
;#include Log.ahk
;#include Jsons.ahk

; https://learn.microsoft.com/en-us/windows/win32/menurc/about-cursors
global cursorID := 32513 ; To be replaced with DllCall("SetSystemCursor"...), IDC_ARROW := 32512, IDC_IBEAM := 32513, IDC_WAIT := 32514, ... 
global cursorName := "IBeam" ; Exit fast if current cursor do not match, must be consistent with ↑
global capslockSuffix := "-capslock"
global cur := Object() ; global storage of script state

cur.folder := A_ScriptDir . "\cursors\"
cur.extensions := [".cur", ".ani", ".ico"]
cur.cursorPath := -1 ; init, later should be smth like "\cursors\ibeam-1-capslock"
cur.localeIndex := -1 ; init, later 1, 2, 3...
cur.capslockState := -1 ; init, later 0 or 1
cur.modified := 0 
cur.prev := { localeIndex : cur.localeIndex, capslockState : cur.capslockState }

RunCursor()
RunCursor() {
	SetTimer CheckCursor, 50 ; main routine, to be executed every 50 milliseconds
	OnExit ExitFunc
}

; Checks if cursor reflect current input locale or capslock state
CheckCursor() {
	global
	if (A_Cursor != cursorName) {
		RevertCursors()
		return ; exit fast, current cursor do not match targeted one
	}

	cur.prev.localeIndex := cur.localeIndex
	cur.prev.capslockState := cur.capslockState
	cur.localeIndex := GetInputLocaleIndex()
	cur.capslockState := GetCapslockState()

	if (cur.localeIndex == cur.prev.localeIndex) and (cur.capslockState == cur.prev.capslockState) {
		if (cur.modified == 1) {
			return ; nor input locale, neither capslock has been switched
		}
	}

	cursorPath := GetCursorPath()

	if (cursorPath == -1) or (cursorPath == 0) {
		RevertCursors()
		return
	}

	SetCursor(cursorPath)
}

GetCursorPath() {
	for Ext in cur.extensions {
		if (GetCapslockState() == 1) {
			path := cur.folder . cur.localeIndex . capslockSuffix . Ext ; e.g. "cursors\1-capslock.cur"
			if (FileExist(path))
				return path ; capslock-suffixed file to be used
		}
		; fallback if no capslock-suffixed file found
		path := cur.folder . cur.localeIndex . Ext ; e.g. "\cursors\1.cur"
		if (FileExist(path)) 
			return path
	}
	return -1
}

ExitFunc(ExitReason, ExitCode) {
	if !(ExitReason ~= "^(?i:Logoff|Shutdown)$")
		RestoreCursors()
}

; https://autohotkey.com/board/topic/32608-changing-the-system-cursor/
SetCursor( CursorFile := 0 ) {
	global
	if (!CursorFile or CursorFile == 0) {
		MsgBox("my-beam.ahk error: cursor filename is not set")
		return
	} else if FileExist( CursorFile ) {
		SplitPath(CursorFile, , , &Ext) ; auto-detect type
		if !(Ext ~= "^(?i:cur|ani|ico)$") {
			MsgBox('my-beam.ahk error: invalid file extension "' . Ext . '", only (ani|cur|ico) allowed')
			return
		}	   
	} else {
		MsgBox('my-beam.ahk error: "' . CursorFile . '" not found on disk')
		return
	}

	cur.modified := 1 
	CursorHandle := DllCall("LoadCursorFromFile", "Str",CursorFile)
	DllCall("SetSystemCursor", "Uint",CursorHandle, "Int",cursorID) ; replaces cursor at cursorID with CursorHandle
}

RestoreCursors() {
	SPI_SETCURSORS := 0x57
	DllCall("SystemParametersInfo", "UInt",SPI_SETCURSORS, "UInt",0, "UInt",0, "UInt",0)
}

; Restores cursors if they were altered
RevertCursors() {
	global
	if (cur.modified == 1) {
		RestoreCursors() 
		cur.modified := 0
	}
}
