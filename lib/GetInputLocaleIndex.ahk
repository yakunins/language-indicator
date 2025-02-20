#requires AutoHotkey v2.0
#include GetInputLocaleId.ahk
#include HasValue.ahk

global localesArray := [GetInputLocaleId()] ; init at script start with value of input locale ID
global localeIndex := -1 ; init, later 1, 2, ...

GetInputLocaleIndex() {
	global
	localeId := GetInputLocaleId() ; docs.microsoft.com/en-us/windows/win32/intl/language-identifiers

	if !localeId {
		return 0
	}

	index := HasValue(localesArray, localeId)

	; add localeId into localesArray
	if !index {
		localesArray.Push localeId
		index := localesArray.length
	}

	return index
}