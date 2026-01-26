#requires AutoHotkey v2.0

class TestFramework {
    static passed := 0
    static failed := 0
    static currentSuite := ""
    static results := []

    static StartSuite(name) {
        this.currentSuite := name
        this.Log("=== " . name . " ===")
    }

    static Assert(condition, message := "Assertion failed") {
        if (condition) {
            this.passed += 1
            this.Log("  PASS: " . message)
            return true
        } else {
            this.failed += 1
            this.Log("  FAIL: " . message)
            return false
        }
    }

    static AssertEqual(actual, expected, message := "") {
        if (message == "")
            message := "Expected '" . expected . "', got '" . actual . "'"
        return this.Assert(actual == expected, message)
    }

    static AssertNotEqual(actual, notExpected, message := "") {
        if (message == "")
            message := "Expected not '" . notExpected . "', but got it"
        return this.Assert(actual != notExpected, message)
    }

    static AssertTrue(value, message := "Expected true") {
        return this.Assert(value == true, message)
    }

    static AssertFalse(value, message := "Expected false") {
        return this.Assert(value == false, message)
    }

    static AssertEmpty(value, message := "Expected empty string") {
        return this.Assert(value == "", message)
    }

    static AssertNotEmpty(value, message := "Expected non-empty string") {
        return this.Assert(value != "", message)
    }

    static Log(text) {
        this.results.Push(text)
        OutputDebug(text . "`n")
    }

    static Summary() {
        total := this.passed + this.failed
        this.Log("")
        this.Log("=== SUMMARY ===")
        this.Log("Total: " . total . " | Passed: " . this.passed . " | Failed: " . this.failed)

        if (this.failed == 0)
            this.Log("All tests passed!")
        else
            this.Log("Some tests failed!")

        return this.failed == 0
    }

    static GetResultsText() {
        text := ""
        for result in this.results
            text .= result . "`n"
        return text
    }

    static Reset() {
        this.passed := 0
        this.failed := 0
        this.currentSuite := ""
        this.results := []
    }
}

; Alias for convenience
T := TestFramework
