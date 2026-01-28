#requires AutoHotkey v2.0
#singleinstance force

#include TestFramework.ahk
#include MarkResolver.test.ahk
#include UseBase64Image.test.ahk
#include IndicatorState.test.ahk
#include InputState.test.ahk
#include Indicators.test.ahk
#include LanguageIndicator.test.ahk

; Run all tests and output to file
RunAllTests() {
    outputFile := A_ScriptDir . "\test-results.txt"
    try FileDelete(outputFile)

    try {
        T.Reset()
        T.Log("Starting Language Indicator Test Suite")
        T.Log("=" . StrReplace(Format("{:50}", ""), " ", "="))
        T.Log("")

        ; Run unit tests
        MarkResolverTests.Run()
        T.Log("")

        UseBase64ImageTests.Run()
        T.Log("")

        IndicatorStateTests.Run()
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

        ; Write results to file
        resultsText := T.GetResultsText()
        FileAppend(resultsText, outputFile)

        ; Exit with appropriate code
        ExitApp(allPassed ? 0 : 1)
    } catch as e {
        errorMsg := "ERROR: " . e.Message . "`nFile: " . e.File . "`nLine: " . e.Line . "`n"
        FileAppend(errorMsg, outputFile)
        ExitApp(2)
    }
}

; Run tests on startup
RunAllTests()
