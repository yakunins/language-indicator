#requires AutoHotkey v2.0

#include ..\lib\core\IndicatorState.ahk
#include TestFramework.ahk

class IndicatorStateTests {
    static Run() {
        this.TestInitialization()
        this.TestStorePrev()
        this.TestHasMarkChanged()
        this.TestClear()
    }

    static TestInitialization() {
        T.StartSuite("IndicatorState.Initialization")

        state := IndicatorState()

        ; Test initial values
        T.AssertEmpty(state.markName, "Initial markName is empty")
        T.AssertEmpty(state.markImage, "Initial markImage is empty")
        T.AssertEmpty(state.markFile, "Initial markFile is empty")

        ; Test prev object exists
        T.Assert(state.HasOwnProp("prev"), "prev property exists")
        T.AssertEmpty(state.prev.markName, "Initial prev.markName is empty")
        T.AssertEmpty(state.prev.markImage, "Initial prev.markImage is empty")
        T.AssertEmpty(state.prev.markFile, "Initial prev.markFile is empty")
    }

    static TestStorePrev() {
        T.StartSuite("IndicatorState.StorePrev")

        state := IndicatorState()

        ; Set current values
        state.markName := "test_name"
        state.markImage := "test_image"
        state.markFile := "test_file"

        ; Store to prev
        state.StorePrev()

        ; Verify prev values
        T.AssertEqual(state.prev.markName, "test_name", "prev.markName stored correctly")
        T.AssertEqual(state.prev.markImage, "test_image", "prev.markImage stored correctly")
        T.AssertEqual(state.prev.markFile, "test_file", "prev.markFile stored correctly")

        ; Change current values
        state.markName := "new_name"
        state.markImage := "new_image"
        state.markFile := "new_file"

        ; Verify prev still has old values
        T.AssertEqual(state.prev.markName, "test_name", "prev.markName unchanged after current update")
        T.AssertEqual(state.prev.markImage, "test_image", "prev.markImage unchanged after current update")
    }

    static TestHasMarkChanged() {
        T.StartSuite("IndicatorState.HasMarkChanged")

        state := IndicatorState()

        ; Initially no change (both empty)
        T.AssertFalse(state.HasMarkChanged(), "No change when both current and prev are empty")

        ; Change markName
        state.markName := "changed"
        T.AssertTrue(state.HasMarkChanged(), "Change detected when markName differs")

        ; Store prev and reset
        state.StorePrev()
        T.AssertFalse(state.HasMarkChanged(), "No change after StorePrev")

        ; Change markImage
        state.markImage := "changed_image"
        T.AssertTrue(state.HasMarkChanged(), "Change detected when markImage differs")

        ; Store prev and reset
        state.StorePrev()

        ; Change markFile
        state.markFile := "changed_file"
        T.AssertTrue(state.HasMarkChanged(), "Change detected when markFile differs")
    }

    static TestClear() {
        T.StartSuite("IndicatorState.Clear")

        state := IndicatorState()

        ; Set values
        state.markName := "test_name"
        state.markImage := "test_image"
        state.markFile := "test_file"

        ; Clear
        state.Clear()

        ; Verify cleared
        T.AssertEmpty(state.markName, "markName cleared")
        T.AssertEmpty(state.markImage, "markImage cleared")
        T.AssertEmpty(state.markFile, "markFile cleared")
    }
}
