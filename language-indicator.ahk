#requires AutoHotkey v2.0
#singleinstance force

; ProcessSetPriority("Realtime")

global languageIndicator := {
    updatePeriod: 100,
    version: "0.4",
  lang_name : [], ;['en-US','ru-RU'],
  ; full list of abbreviations in "Language tag" of "Language ID" table at learn.microsoft.com/en-us/openspecs/windows_protocols/ms-lcid/70feba9f-294e-491e-b6eb-56532684c37f
}

#include lib\LanguageIndicatorCaret.ahk
#include lib\LanguageIndicatorCursor.ahk

A_IconTip := "Language Indicator v" . languageIndicator.version
