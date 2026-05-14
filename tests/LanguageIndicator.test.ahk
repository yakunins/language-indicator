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
            inputCheckPeriod: 10,
            markRepaintPeriod: 10,
            caret: "",
            cursor: ""
        }

        this.cfg := cfg != "" ? cfg : defaultCfg

        ; Create caret indicator config
        caretCfg := CaretIndicator.DefaultConfig
        if (this.cfg.HasOwnProp("inputCheckPeriod"))
            caretCfg.inputCheckPeriod := this.cfg.inputCheckPeriod
        if (this.cfg.HasOwnProp("markRepaintPeriod"))
            caretCfg.markRepaintPeriod := this.cfg.markRepaintPeriod
        if (this.cfg.HasOwnProp("caret") and this.cfg.caret != "")
            caretCfg := this.MergeConfig(caretCfg, this.cfg.caret)

        ; Create cursor indicator config
        cursorCfg := CursorIndicator.DefaultConfig
        if (this.cfg.HasOwnProp("inputCheckPeriod"))
            cursorCfg.inputCheckPeriod := this.cfg.inputCheckPeriod
        if (this.cfg.HasOwnProp("markRepaintPeriod"))
            cursorCfg.markRepaintPeriod := this.cfg.markRepaintPeriod
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
        this.TestPeriodPropagation()
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
            inputCheckPeriod: 50,
            markRepaintPeriod: 25,
            caret: "",
            cursor: ""
        }

        app := LanguageIndicatorTestable(customCfg)

        ; Verify custom periods propagated
        T.AssertEqual(app.caretIndicator.cfg.inputCheckPeriod, 50, "Caret inputCheckPeriod is 50")
        T.AssertEqual(app.cursorIndicator.cfg.inputCheckPeriod, 50, "Cursor inputCheckPeriod is 50")
        T.AssertEqual(app.caretIndicator.cfg.markRepaintPeriod, 25, "Caret markRepaintPeriod is 25")
        T.AssertEqual(app.cursorIndicator.cfg.markRepaintPeriod, 25, "Cursor markRepaintPeriod is 25")
    }

    static TestPeriodPropagation() {
        T.StartSuite("LanguageIndicator.PeriodPropagation")

        ; Test with different periods
        app1 := LanguageIndicatorTestable({ inputCheckPeriod: 5, markRepaintPeriod: 5 })
        T.AssertEqual(app1.caretIndicator.cfg.inputCheckPeriod, 5, "inputCheckPeriod=5 propagates to caret")
        T.AssertEqual(app1.cursorIndicator.cfg.inputCheckPeriod, 5, "inputCheckPeriod=5 propagates to cursor")
        T.AssertEqual(app1.caretIndicator.cfg.markRepaintPeriod, 5, "markRepaintPeriod=5 propagates to caret")
        T.AssertEqual(app1.cursorIndicator.cfg.markRepaintPeriod, 5, "markRepaintPeriod=5 propagates to cursor")

        app2 := LanguageIndicatorTestable({ inputCheckPeriod: 200, markRepaintPeriod: 33 })
        T.AssertEqual(app2.caretIndicator.cfg.inputCheckPeriod, 200, "inputCheckPeriod=200 propagates to caret")
        T.AssertEqual(app2.cursorIndicator.cfg.inputCheckPeriod, 200, "inputCheckPeriod=200 propagates to cursor")
        T.AssertEqual(app2.caretIndicator.cfg.markRepaintPeriod, 33, "markRepaintPeriod=33 propagates to caret")
        T.AssertEqual(app2.cursorIndicator.cfg.markRepaintPeriod, 33, "markRepaintPeriod=33 propagates to cursor")
    }
}
