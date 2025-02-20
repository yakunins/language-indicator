#requires AutoHotkey v2.0
#DllLoad "Imm32" ; for consoles compatibility, see docs.microsoft.com/en-us/windows/win32/api/imm/

global imm := DllCall("GetModuleHandle", "Str", "Imm32", "Ptr") ; better performance; lexikos.github.io/v2/docs/commands/DllCall.htm
global immGetDefaultIMEWnd := DllCall("GetProcAddress", "Ptr", imm, "AStr", "ImmGetDefaultIMEWnd", "Ptr") ; docs.microsoft.com/en-us/windows/win32/api/imm/nf-imm-immgetdefaultimewnd

GetInputLocaleId() {
	foregroundWindow := DllCall("GetForegroundWindow") ; docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getforegroundwindow

	isConsole := WinActive("ahk_class ConsoleWindowClass") ; CMD, Powershell
	isVGUI := WinActive("ahk_class vguiPopupWindow") ; Popups
	isUWP := WinActive("ahk_class ApplicationFrameWindow") ; Steam, UWP apps: autohotkey.com/boards/viewtopic.php?f=76&t=69414

	if isConsole {
		IMEWnd := DllCall(immGetDefaultIMEWnd, "Ptr", foregroundWindow) ; DllCall("Imm32.dll\ImmGetDefaultIMEWnd", "Ptr",fgWin)
		if (IMEWnd = 0) {
			return
		} else {
			foregroundWindow := IMEWnd
		}
	} else if isVGUI or isUWP {
		Focused := ControlGetFocus("A")
		if (Focused = 0) {
			return
		} else {
			ctrlID := ControlGetHwnd(Focused, "A")
			foregroundWindow := ctrlID
		}
	}
	threadId := DllCall("GetWindowThreadProcessId", "Ptr", foregroundWindow, "Ptr", 0) ; docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowthreadprocessid
	inputLocaleId := DllCall("GetKeyboardLayout", "UInt", threadId) ; precise '0xfffffffff0c00409' value

	return inputLocaleId
}