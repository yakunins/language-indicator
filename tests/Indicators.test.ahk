#requires AutoHotkey v2.0

#include ..\lib\CaretIndicator.ahk
#include ..\lib\CursorIndicator.ahk
#include TestFramework.ahk

class CaretIndicatorTests {
    static Run() {
        this.TestDefaultConfig()
        this.TestInitialization()
        this.TestGetPosition()
    }

    static TestDefaultConfig() {
        T.StartSuite("CaretIndicator.DefaultConfig")

        cfg := CaretIndicator.DefaultConfig

        ; Verify default config structure
        T.Assert(cfg.HasOwnProp("debug"), "Config has debug property")
        T.Assert(cfg.HasOwnProp("files"), "Config has files property")
        T.Assert(cfg.HasOwnProp("markMargin"), "Config has markMargin property")
        T.Assert(cfg.HasOwnProp("updatePeriod"), "Config has updatePeriod property")

        ; Verify files config
        T.Assert(cfg.files.HasOwnProp("folder"), "files has folder property")
        T.Assert(cfg.files.HasOwnProp("extensions"), "files has extensions property")
        T.Assert(cfg.files.HasOwnProp("capslockSuffix"), "files has capslockSuffix property")

        ; Verify default values
        T.AssertEqual(cfg.files.capslockSuffix, "-capslock", "Default capslock suffix is -capslock")
        T.Assert(cfg.files.extensions.Length == 2, "Default extensions has 2 items")
        T.AssertEqual(cfg.updatePeriod, 100, "Default updatePeriod is 100")
    }

    static TestInitialization() {
        T.StartSuite("CaretIndicator.Initialization")

        indicator := CaretIndicator()

        ; Verify indicator was created with components
        T.Assert(indicator.HasOwnProp("cfg"), "Indicator has cfg")
        T.Assert(indicator.HasOwnProp("state"), "Indicator has state")
        T.Assert(indicator.HasOwnProp("inputState"), "Indicator has inputState")
        T.Assert(indicator.HasOwnProp("mark"), "Indicator has mark (ImagePainter)")
        T.Assert(indicator.HasOwnProp("onFrame"), "Indicator has onFrame scheduler")

        ; Verify types
        T.Assert(indicator.state is IndicatorState, "state is IndicatorState instance")
        T.Assert(indicator.inputState is InputState, "inputState is InputState instance")
        T.Assert(indicator.mark is ImagePainter, "mark is ImagePainter instance")
    }

    static TestGetPosition() {
        T.StartSuite("CaretIndicator.GetPosition")

        indicator := CaretIndicator()

        ; GetPosition returns an object with position info
        pos := indicator.GetPosition()

        T.Assert(pos.HasOwnProp("left"), "Position has left property")
        T.Assert(pos.HasOwnProp("top"), "Position has top property")
        T.Assert(pos.HasOwnProp("right"), "Position has right property")
        T.Assert(pos.HasOwnProp("bottom"), "Position has bottom property")
        T.Assert(pos.HasOwnProp("w"), "Position has w (width) property")
        T.Assert(pos.HasOwnProp("h"), "Position has h (height) property")
        T.Assert(pos.HasOwnProp("detectMethod"), "Position has detectMethod property")
    }
}

class CursorIndicatorTests {
    static Run() {
        this.TestDefaultConfig()
        this.TestInitialization()
        this.TestGetPosition()
        this.TestRevertCursors()
    }

    static TestDefaultConfig() {
        T.StartSuite("CursorIndicator.DefaultConfig")

        cfg := CursorIndicator.DefaultConfig

        ; Verify default config structure
        T.Assert(cfg.HasOwnProp("debug"), "Config has debug property")
        T.Assert(cfg.HasOwnProp("files"), "Config has files property")
        T.Assert(cfg.HasOwnProp("markMargin"), "Config has markMargin property")
        T.Assert(cfg.HasOwnProp("updatePeriod"), "Config has updatePeriod property")
        T.Assert(cfg.HasOwnProp("target"), "Config has target property")
        T.Assert(cfg.HasOwnProp("mousePositionPrediction"), "Config has mousePositionPrediction property")

        ; Verify target config
        T.Assert(cfg.target.HasOwnProp("cursorId"), "target has cursorId property")
        T.Assert(cfg.target.HasOwnProp("cursorName"), "target has cursorName property")
        T.AssertEqual(cfg.target.cursorId, 32513, "Default cursorId is 32513 (IDC_IBEAM)")
        T.AssertEqual(cfg.target.cursorName, "IBeam", "Default cursorName is IBeam")

        ; Verify cursor file extensions
        T.Assert(cfg.files.extensions.Length == 3, "Cursor extensions has 3 items (cur, ani, ico)")
    }

    static TestInitialization() {
        T.StartSuite("CursorIndicator.Initialization")

        indicator := CursorIndicator()

        ; Verify indicator was created with components
        T.Assert(indicator.HasOwnProp("cfg"), "Indicator has cfg")
        T.Assert(indicator.HasOwnProp("state"), "Indicator has state")
        T.Assert(indicator.HasOwnProp("inputState"), "Indicator has inputState")
        T.Assert(indicator.HasOwnProp("mark"), "Indicator has mark (ImagePainter)")
        T.Assert(indicator.HasOwnProp("modifiedCursorsCount"), "Indicator has modifiedCursorsCount")

        ; Verify initial cursor state
        T.AssertEqual(indicator.modifiedCursorsCount, 0, "Initial modifiedCursorsCount is 0")
    }

    static TestGetPosition() {
        T.StartSuite("CursorIndicator.GetPosition")

        indicator := CursorIndicator()

        ; GetPosition returns mouse position with prediction
        pos := indicator.GetPosition()

        T.Assert(pos.HasOwnProp("x"), "Position has x property")
        T.Assert(pos.HasOwnProp("y"), "Position has y property")
    }

    static TestRevertCursors() {
        T.StartSuite("CursorIndicator.RevertCursors")

        indicator := CursorIndicator()

        ; RevertCursors should not error when no cursors modified
        indicator.modifiedCursorsCount := 0
        indicator.RevertCursors()
        T.AssertEqual(indicator.modifiedCursorsCount, 0, "RevertCursors does nothing when count is 0")

        ; Simulate modified cursor count
        indicator.modifiedCursorsCount := 5
        indicator.RevertCursors()
        T.AssertEqual(indicator.modifiedCursorsCount, 0, "RevertCursors resets count to 0")
    }
}
