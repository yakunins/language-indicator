#SingleInstance Force

; https://www.autohotkey.com/boards/viewtopic.php?t=84140
#Requires AutoHotkey v2.0
#DllLoad "Imm32" ; for consoles; docs.microsoft.com/en-us/windows/win32/api/imm/

global cursor := A_ScriptDir . "\cursors\ibeam-circle-red.cur"
global imm := DllCall("GetModuleHandle", "Str","Imm32", "Ptr") ; better performance; lexikos.github.io/v2/docs/commands/DllCall.htm
global immGetDefaultIMEWnd := DllCall("GetProcAddress", "Ptr",imm, "AStr","ImmGetDefaultIMEWnd", "Ptr") ; docs.microsoft.com/en-us/windows/win32/api/imm/nf-imm-immgetdefaultimewnd
global localeArr := []
global currentLocaleIndex := GetInputLocaleIndex() ; set currentLocale=1 at script start

GetInputLocaleID() {
	foregroundWin := DllCall("GetForegroundWindow") ; docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getforegroundwindow

	isConsole := WinActive("ahk_class ConsoleWindowClass") ; CMD, Powershell
	isVgui := WinActive("ahk_class vguiPopupWindow") ; Popups
	isUWP := WinActive("ahk_class ApplicationFrameWindow") ; Steam, UWP apps: autohotkey.com/boards/viewtopic.php?f=76&t=69414

	if isConsole {
		IMEWnd := DllCall(immGetDefaultIMEWnd, "Ptr",foregroundWin) ; DllCall("Imm32.dll\ImmGetDefaultIMEWnd", "Ptr",fgWin)
		if (IMEWnd == 0) {
			return
		} else {
			foregroundWin := IMEWnd
		}
	} else if isVgui or isUWP { 
		Focused	:= ControlGetFocus("A")
		if (Focused == 0) {
			return
		} else {
			ctrlId := ControlGetHwnd(Focused, "A")
			foregroundWin := ctrlId
		}
	}
	threadId := DllCall("GetWindowThreadProcessId", "Ptr",foregroundWin , "Ptr",0) ; docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowthreadprocessid
	inputLocaleId := DllCall("GetKeyboardLayout", "UInt",threadId) ; precise '0xfffffffff0c00409' value

	return inputLocaleId
}

GetInputLocaleIndex() {
	global
	localeId := GetInputLocaleID()

	if !localeId {
		return 0
	}

	; docs.microsoft.com/en-us/windows/win32/intl/language-identifiers
	hWord := localeId >> 16 ; SubLanguage ID
	lWord := localeId & 0xFFFF ; Primary Language ID 

	localeIndex := HasVal(localeArr, localeId)
	if !localeIndex {
		localeArr.Push localeId
		localeIndex := localeArr.length
	}

	return localeIndex
}

; for debug purposes
Log() {
	inputLocale := GetInputLocaleIndex()
	if !inputLocale {
		ToolTip("something wrong, inputLocale is undefined")
		Sleep(2000)
		ToolTip	
		return
	}

	ToolTip("inputLocale=" inputLocale)
	Sleep(2000)
	ToolTip	
	return
}

HasVal(haystack, val) {
	global
	for index, value in haystack
		if (value = val)
			return index
	if !IsObject(haystack)
		; throw Exception("Bad haystack!", -1, haystack) ; ahk v1
		throw ValueError("haystack id not an object", -1, haystack) ; ahk v2

	return 0
}

CheckInputLocale() {
	global	
	if (A_Cursor != "IBeam") {
		return ; not a text select cursor
	}

	nextLocaleIndex := GetInputLocaleIndex()

	if (currentLocaleIndex = nextLocaleIndex) {
		return ; input locale wasn't changed
	}

	currentLocaleIndex := nextLocaleIndex

	if (currentLocaleIndex = 1) {
		RestoreCursors()
		return
	}

	SetTextSelectCursor( cursor )
	return
}

ExitFunc(ExitReason, ExitCode) {
	if !(ExitReason ~= "^(?i:Logoff|Shutdown)$")
		RestoreCursors()
}

RestoreCursors() {
	SPI_SETCURSORS := 0x57
	DllCall("SystemParametersInfo", "UInt", SPI_SETCURSORS, "UInt", 0, "UInt", 0, "UInt", 0)
}

; https://autohotkey.com/board/topic/32608-changing-the-system-cursor/
SetTextSelectCursor( CursorFile := 0 ) {
	if (!CursorFile or CursorFile = 0) {
		MsgBox("Error: cursor filename is not set")
		return
	} else if FileExist( CursorFile ) {
		SplitPath(CursorFile, , , &Ext) ; auto-detect type
		if !(Ext ~= "^(?i:cur|ani|ico)$") {
			MsgBox("Error: invalid  file extension, should be .ani, .cur or .ico")
			return
		}	   
	} else {
		MsgBox("Error: cursorFile not found on disk")
		return
	}

	CursorHandle := DllCall("LoadCursorFromFile", "Str", CursorFile)
	DllCall("SetSystemCursor", "Uint", CursorHandle, "Int", 32513) ; cursor to replace = 32513IDC_IBEAM
}
 
SetTimer CheckInputLocale, 100 ; main routine 
OnExit ExitFunc ; OnExit("ExitFunc")
