#requires AutoHotkey v2.0
#singleinstance force

#include lib\CaretIndicator.ahk
#include lib\CursorIndicator.ahk

class LanguageIndicator {
    static Version := "0.6"

    caretIndicator := ""
    cursorIndicator := ""
    cfg := {}

    __New(cfg := "") {
        defaultCfg := {
            updatePeriod: 10,
            caret: "",
            cursor: ""
        }

        this.cfg := cfg != "" ? cfg : defaultCfg

        ; Create caret indicator config
        caretCfg := CaretIndicator.DefaultConfig
        if (this.cfg.HasOwnProp("updatePeriod"))
            caretCfg.updatePeriod := this.cfg.updatePeriod
        if (this.cfg.HasOwnProp("caret") and this.cfg.caret != "")
            caretCfg := this.MergeConfig(caretCfg, this.cfg.caret)

        ; Create cursor indicator config
        cursorCfg := CursorIndicator.DefaultConfig
        if (this.cfg.HasOwnProp("updatePeriod"))
            cursorCfg.updatePeriod := this.cfg.updatePeriod
        if (this.cfg.HasOwnProp("cursor") and this.cfg.cursor != "")
            cursorCfg := this.MergeConfig(cursorCfg, this.cfg.cursor)

        this.caretIndicator := CaretIndicator(caretCfg)
        this.cursorIndicator := CursorIndicator(cursorCfg)
    }

    Run() {
        this.caretIndicator.Run()
        this.cursorIndicator.Run()
    }

    MergeConfig(base, override) {
        for key, value in override.OwnProps() {
            base.%key% := value
        }
        return base
    }
}

; Application entry point
global app := LanguageIndicator()
app.Run()

A_IconTip := "Language Indicator v" . LanguageIndicator.Version