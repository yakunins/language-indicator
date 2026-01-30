#requires AutoHotkey v2.0
#singleinstance force

#include TestFramework.ahk
#include MarkResolver.test.ahk
#include UseBase64Image.test.ahk
#include InputState.test.ahk
#include Indicators.test.ahk
#include LanguageIndicator.test.ahk

; Run all tests
RunAllTests() {
    T.Reset()
    T.Log("Starting Language Indicator Test Suite")
    T.Log("=" . StrReplace(Format("{:50}", ""), " ", "="))
    T.Log("")

    ; Run unit tests
    MarkResolverTests.Run()
    T.Log("")

    UseBase64ImageTests.Run()
    T.Log("")

    InputStateTests.Run()
    T.Log("")

    ; Run integration tests
    CaretIndicatorTests.Run()
    T.Log("")

    CursorIndicatorTests.Run()
    T.Log("")

    LanguageIndicatorTests.Run()
    T.Log("")

    ; Show summary
    allPassed := T.Summary()

    ; Show results in a message box
    resultsText := T.GetResultsText()
    MsgBox(resultsText, "Test Results", allPassed ? "Iconi" : "Iconx")

    return allPassed
}

; Run tests on startup
RunAllTests()
