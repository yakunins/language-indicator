#requires AutoHotkey v2.0

#include ..\lib\CaretIndicator.ahk
#include ..\lib\CursorIndicator.ahk
#include TestFramework.ahk

; Recreate the LanguageIndicator class for testing (without auto-run)
class LanguageIndicatorTestable {
    static Version := "0.5"

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

    MergeConfig(base, override) {
        for key, value in override.OwnProps() {
            base.%key% := value
        }
        return base
    }
}

class LanguageIndicatorTests {
    static Run() {
        this.TestDefaultInitialization()
        this.TestCustomConfig()
        this.TestUpdatePeriodPropagation()
    }

    static TestDefaultInitialization() {
        T.StartSuite("LanguageIndicator.DefaultInitialization")

        app := LanguageIndicatorTestable()

        ; Verify both indicators created
        T.Assert(app.caretIndicator != "", "caretIndicator was created")
        T.Assert(app.cursorIndicator != "", "cursorIndicator was created")

        ; Verify types
        T.Assert(app.caretIndicator is CaretIndicator, "caretIndicator is CaretIndicator instance")
        T.Assert(app.cursorIndicator is CursorIndicator, "cursorIndicator is CursorIndicator instance")

        ; Verify version
        T.AssertEqual(LanguageIndicatorTestable.Version, "0.5", "Version is 0.5")
    }

    static TestCustomConfig() {
        T.StartSuite("LanguageIndicator.CustomConfig")

        customCfg := {
            updatePeriod: 50,
            caret: "",
            cursor: ""
        }

        app := LanguageIndicatorTestable(customCfg)

        ; Verify custom updatePeriod propagated
        T.AssertEqual(app.caretIndicator.cfg.updatePeriod, 50, "Caret updatePeriod is 50")
        T.AssertEqual(app.cursorIndicator.cfg.updatePeriod, 50, "Cursor updatePeriod is 50")
    }

    static TestUpdatePeriodPropagation() {
        T.StartSuite("LanguageIndicator.UpdatePeriodPropagation")

        ; Test with different update periods
        app1 := LanguageIndicatorTestable({ updatePeriod: 5 })
        T.AssertEqual(app1.caretIndicator.cfg.updatePeriod, 5, "updatePeriod=5 propagates to caret")
        T.AssertEqual(app1.cursorIndicator.cfg.updatePeriod, 5, "updatePeriod=5 propagates to cursor")

        app2 := LanguageIndicatorTestable({ updatePeriod: 100 })
        T.AssertEqual(app2.caretIndicator.cfg.updatePeriod, 100, "updatePeriod=100 propagates to caret")
        T.AssertEqual(app2.cursorIndicator.cfg.updatePeriod, 100, "updatePeriod=100 propagates to cursor")
    }
}
