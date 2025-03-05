#requires AutoHotkey v2.0
#singleinstance force

; ProcessSetPriority("Realtime")

global languageIndicator := {
    updatePeriod: 100,
    version: "0.4"
}

#include lib\LanguageIndicatorCaret.ahk
#include lib\LanguageIndicatorCursor.ahk

A_IconTip := "Language Indicator v" . languageIndicator.version