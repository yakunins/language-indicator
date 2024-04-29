; Set custom text select pointer (mouse cursor) depending on input language and capslock state.
; Script is lookin into "./cursors/" folder for files "1.cur", "1-capslock.cur", "2.cur", etc.

#SingleInstance Force

; https://www.autohotkey.com/boards/viewtopic.php?t=84140
#Requires AutoHotkey v2.0
#DllLoad "Imm32" ; for consoles compatibility, see docs.microsoft.com/en-us/windows/win32/api/imm/

global imm := DllCall("GetModuleHandle", "Str","Imm32", "Ptr") ; better performance; lexikos.github.io/v2/docs/commands/DllCall.htm
global immGetDefaultIMEWnd := DllCall("GetProcAddress", "Ptr",imm, "AStr","ImmGetDefaultIMEWnd", "Ptr") ; docs.microsoft.com/en-us/windows/win32/api/imm/nf-imm-immgetdefaultimewnd

; https://learn.microsoft.com/en-us/windows/win32/menurc/about-cursors
global cursorID := 32513 ; Used in DllCall("SetSystemCursor"...), IDC_ARROW := 32512, IDC_IBEAM := 32513, IDC_WAIT := 32514, ... 
global cursorName := "IBeam" ; Exit fast if current cursor is different

global folder := A_ScriptDir . "\cursors\"
global capslockSuffix := "-capslock"
global extensions := [".cur", ".ani", ".ico"]
global cursorPath := -1 ; init, later should be smth like "\cursors\ibeam-1-capslock"

global localesArray := [GetInputLocaleID()] ; init at script start with value of input locale ID 
global localeIndex := -1 ; init, later 1, 2, ...
global capslockState := -1 ; init, later 0 or 1


SetTimer Check, 50 ; main routine, to be executed every 50 milliseconds
OnExit ExitFunc


; Check for change of input locale or capslock state
Check() {
	global
	if (A_Cursor != cursorName) {
		return ; exit fast, current cursor do not match targeted one
	}

	prevLocaleIndex := localeIndex
	prevCapslockState := capslockState
	localeIndex := GetInputLocaleIndex()
	capslockState := GetCapslockState()

	if (localeIndex = prevLocaleIndex) and (capslockState = prevCapslockState) {
		return ; nor input locale neither capslock has been switched
	}

	cursorPath := GetCursorPath()

	if (cursorPath = -1) or (cursorPath = 0) {
		RestoreCursors()
		return
	}

	SetCursor(cursorPath)
	return
}

GetCapslockState() {
	return GetKeyState("Capslock", "T")
} 

GetInputLocaleID() {
	foregroundWindow := DllCall("GetForegroundWindow") ; docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getforegroundwindow

	isConsole := WinActive("ahk_class ConsoleWindowClass") ; CMD, Powershell
	isVGUI := WinActive("ahk_class vguiPopupWindow") ; Popups
	isUWP := WinActive("ahk_class ApplicationFrameWindow") ; Steam, UWP apps: autohotkey.com/boards/viewtopic.php?f=76&t=69414

	if isConsole {
		IMEWnd := DllCall(immGetDefaultIMEWnd, "Ptr",foregroundWindow) ; DllCall("Imm32.dll\ImmGetDefaultIMEWnd", "Ptr",fgWin)
		if (IMEWnd == 0) {
			return
		} else {
			foregroundWindow := IMEWnd
		}
	} else if isVGUI or isUWP { 
		Focused	:= ControlGetFocus("A")
		if (Focused == 0) {
			return
		} else {
			ctrlID := ControlGetHwnd(Focused, "A")
			foregroundWindow := ctrlID
		}
	}
	threadId := DllCall("GetWindowThreadProcessId", "Ptr",foregroundWindow , "Ptr",0) ; docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowthreadprocessid
	inputLocaleId := DllCall("GetKeyboardLayout", "UInt",threadId) ; precise '0xfffffffff0c00409' value

	return inputLocaleId
}

GetInputLocaleIndex() {
	localeId := GetInputLocaleID()

	if !localeId {
		return 0
	}

	; docs.microsoft.com/en-us/windows/win32/intl/language-identifiers
	; lWord := localeId & 0xFFFF ; Primary Language ID 
	; hWord := localeId >> 16 ; SubLanguage ID

	index := HasVal(localesArray, localeId)

	; add localeId into localesArray
	if !index {
		localesArray.Push localeId
		index := localesArray.length
	}

	return index
}

GetCursorPath() {
	for Ext in extensions {
		if (GetCapslockState() = 1) {
			path := folder . localeIndex . capslockSuffix . Ext ; "\cursors\ibeam-1-capslock.cur"
			if (FileExist(path))
				return path ; capslock-suffixed file to be used
		}
		; fallback if no capslock-suffixed file found
		path := folder . localeIndex . Ext ; "\cursors\ibeam-1.cur", e.g. 
		if (FileExist(path)) 
			return path
	}
	return -1
}

HasVal(haystack, val) {
	for index, value in haystack
		if (value = val)
			return index
	if !IsObject(haystack)
		; throw Exception("Bad haystack!", -1, haystack) ; ahk v1
		throw ValueError("haystack id not an object", -1, haystack) ; ahk v2
	return 0
}

ExitFunc(ExitReason, ExitCode) {
	if !(ExitReason ~= "^(?i:Logoff|Shutdown)$")
		RestoreCursors()
}

RestoreCursors() {
	SPI_SETCURSORS := 0x57
	DllCall("SystemParametersInfo", "UInt",SPI_SETCURSORS, "UInt",0, "UInt",0, "UInt",0)
}

; https://autohotkey.com/board/topic/32608-changing-the-system-cursor/
SetCursor( CursorFile := 0 ) {
	if (!CursorFile or CursorFile = 0) {
		MsgBox("Error: cursor filename is not set")
		return
	} else if FileExist( CursorFile ) {
		SplitPath(CursorFile, , , &Ext) ; auto-detect type
		if !(Ext ~= "^(?i:cur|ani|ico)$") {
			MsgBox("Error: invalid file extension, only (ani|cur|ico) allowed")
			return
		}	   
	} else {
		MsgBox("Error: cursorFile not found on disk")
		return
	}

	CursorHandle := DllCall("LoadCursorFromFile", "Str",CursorFile)
	DllCall("SetSystemCursor", "Uint",CursorHandle, "Int",cursorID) ; replaces cursor at cursorID with CursorHandle
}
