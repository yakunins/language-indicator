#requires AutoHotkey v2.0
#include GetInputLocaleId.ahk
#include HasValue.ahk
#include constLocale.ahk
#include Locale.ahk

global localesArray := []
global langNamesArray := []
InitUserLang() {
	static init := False
	if init {
		return
	} else {
		init := True
	}
	if languageIndicator.lang_name.length == 0 { ; with no user input, start with one value of initial input language name
		localeId := GetInputLocaleId() ; docs.microsoft.com/en-us/windows/win32/intl/language-identifiers
		if !localeId {
			return
		}
		lang_id := localeId & 0xFFFF ; low word (≝2 byte = 4 hex chars) Language Identifier for the input language docs.microsoft.com/en-us/windows/win32/intl/language-identifiers
		lang_name := lyt.getLocaleInfo('en',lang_id) '-' lyt.getLocaleInfo('US',lang_id)
		langNamesArray.push(lang_name)
	} else { ; with user input, prefill the user defined order of languages
		for lng in languageIndicator.lang_name { ; fill language IDs, also error out on mistaken language
			langNamesArray.push(lng)
		}
	}
	for lng in langNamesArray {
		localesArray.push(win_langID[lng]) ; en-US → 0x0409
	}
}
InitUserLang()

; populates localesArray
GetInputLocaleIndex(&lang_id:=0) {
	global localesArray
	localeId := GetInputLocaleId() ; docs.microsoft.com/en-us/windows/win32/intl/language-identifiers

	if !localeId {
		return 0
	}

	lang_id := localeId & 0xFFFF ; low word (≝2 byte = 4 hex chars) Language Identifier for the input language docs.microsoft.com/en-us/windows/win32/intl/language-identifiers
	index := HasValue(localesArray, lang_id)

	; push lang_id into localesArray
	if !index {
		localesArray.Push(lang_id)
		index := localesArray.length
		lang_name := lyt.getLocaleInfo('en',lang_id) '-' lyt.getLocaleInfo('US',lang_id)
		langNamesArray.push(lang_name)
	}

	return index
}