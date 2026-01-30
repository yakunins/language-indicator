#requires AutoHotkey v2.0

#include ..\lib\detection\GetCursorSize.ahk
#include TestFramework.ahk

class GetCursorSizeTests {
    static Run() {
        this.TestGetDefaultCursorSize()
        this.OutputToFile()
    }

    static TestGetDefaultCursorSize() {
        T.StartSuite("GetCursorSize")

        GetDefaultCursorSize(&w, &h)

        T.Assert(w > 0, "Default width is positive: " w)
        T.Assert(h > 0, "Default height is positive: " h)
        T.AssertEqual(w, 32, "Default width is 32")
        T.AssertEqual(h, 32, "Default height is 32")
    }

    static OutputToFile() {
        outputFile := A_ScriptDir "\cursor-size.txt"

        GetCursorSize(&w, &h)
        GetDefaultCursorSize(&defaultW, &defaultH)
        GetScaledCursorSize(&scaledW, &scaledH)
        scale := GetCursorScale()

        output := "Cursor Size Test`n"
        output .= "================`n`n"
        output .= "Current cursor: " w "x" h "`n"
        output .= "System default: " defaultW "x" defaultH "`n"
        output .= "Scale factor: " scale "`n"
        output .= "Scaled size: " scaledW "x" scaledH "`n"
        output .= "Timestamp: " A_Now

        try FileDelete(outputFile)
        FileAppend(output, outputFile)
    }
}

; Run when executed directly
if (A_LineFile = A_ScriptFullPath) {
    GetCursorSizeTests.Run()
    ExitApp
}
