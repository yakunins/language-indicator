#requires AutoHotkey v2.0
#include GetInputLocaleId.ahk
#include HasValue.ahk

global localesArray := [GetInputLocaleId()] ; start with one value of initial input locale ID

; populates localesArray
GetInputLocaleIndex(&lang_id:=0) {
	global localesArray
	localeId := GetInputLocaleId() ; docs.microsoft.com/en-us/windows/win32/intl/language-identifiers

	if !localeId {
		return 0
	}

	lang_id := localeId & 0xFFFF ; low word (≝2 byte = 4 hex chars) Language Identifier for the input language docs.microsoft.com/en-us/windows/win32/intl/language-identifiers
	index := HasValue(localesArray, localeId)

	; push localeId into localesArray
	if !index {
		localesArray.Push(localeId)
		index := localesArray.length
	}

	return index
}