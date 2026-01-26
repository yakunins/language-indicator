#requires AutoHotkey v2.0

#include ..\lib\detection\InputState.ahk
#include TestFramework.ahk

class InputStateTests {
    static Run() {
        this.TestInitialization()
        this.TestUpdate()
        this.TestHasChanged()
        this.TestIsDefault()
    }

    static TestInitialization() {
        T.StartSuite("InputState.Initialization")

        state := InputState()

        ; Test initial values
        T.AssertEqual(state.locale, 1, "Initial locale is 1")
        T.AssertEqual(state.capslock, 0, "Initial capslock is 0")

        ; Test prev object exists and has initial values
        T.Assert(state.HasOwnProp("prev"), "prev property exists")
        T.AssertEqual(state.prev.locale, 1, "Initial prev.locale is 1")
        T.AssertEqual(state.prev.capslock, 0, "Initial prev.capslock is 0")
    }

    static TestUpdate() {
        T.StartSuite("InputState.Update")

        state := InputState()

        ; Initial state before update
        initialLocale := state.locale
        initialCapslock := state.capslock

        ; Call Update - this reads actual system state
        state.Update()

        ; Verify prev was set to initial values
        T.AssertEqual(state.prev.locale, initialLocale, "prev.locale set to previous value after Update")
        T.AssertEqual(state.prev.capslock, initialCapslock, "prev.capslock set to previous value after Update")

        ; Current values should now reflect system state (can't assert exact values)
        T.Assert(state.locale >= 0, "locale is a valid number after Update")
        T.Assert(state.capslock == 0 or state.capslock == 1, "capslock is 0 or 1 after Update")
    }

    static TestHasChanged() {
        T.StartSuite("InputState.HasChanged")

        state := InputState()

        ; Initially no change (both at defaults)
        T.AssertFalse(state.HasChanged(), "No change when locale and capslock match prev")

        ; Simulate locale change
        state.prev.locale := state.locale
        state.locale := state.locale + 1
        T.AssertTrue(state.HasChanged(), "Change detected when locale differs")

        ; Reset and test capslock change
        state.locale := state.prev.locale
        state.capslock := 1
        state.prev.capslock := 0
        T.AssertTrue(state.HasChanged(), "Change detected when capslock differs")

        ; Both match
        state.prev.capslock := state.capslock
        T.AssertFalse(state.HasChanged(), "No change when both match again")
    }

    static TestIsDefault() {
        T.StartSuite("InputState.IsDefault")

        state := InputState()

        ; Initial state should be default
        T.AssertTrue(state.IsDefault(), "Initial state (locale=1, capslock=0) is default")

        ; Change locale
        state.locale := 2
        T.AssertFalse(state.IsDefault(), "Not default when locale != 1")

        ; Reset locale, change capslock
        state.locale := 1
        state.capslock := 1
        T.AssertFalse(state.IsDefault(), "Not default when capslock != 0")

        ; Both non-default
        state.locale := 2
        state.capslock := 1
        T.AssertFalse(state.IsDefault(), "Not default when both locale and capslock differ")

        ; Back to default
        state.locale := 1
        state.capslock := 0
        T.AssertTrue(state.IsDefault(), "Default when locale=1 and capslock=0")
    }
}
