#requires AutoHotkey v2.0

#include ..\lib\core\MarkResolver.ahk
#include TestFramework.ahk

class MarkResolverTests {
    static Run() {
        this.TestGetMarkName()
        this.TestGetMarkFile()
    }

    static TestGetMarkName() {
        T.StartSuite("MarkResolver.GetMarkName")

        ; Test default state (locale=1, capslock=0) returns empty
        result := MarkResolver.GetMarkName(1, 0)
        T.AssertEmpty(result, "Default state (locale=1, capslock=0) returns empty")

        ; Test capslock on with first locale
        result := MarkResolver.GetMarkName(1, 1)
        T.AssertEqual(result, "arrow_white_12px", "Capslock=1, locale=1 returns arrow_white_12px")

        ; Test second locale without capslock
        result := MarkResolver.GetMarkName(2, 0)
        T.AssertEqual(result, "circle_red_12px", "Locale=2, capslock=0 returns circle_red_12px")

        ; Test second locale with capslock
        result := MarkResolver.GetMarkName(2, 1)
        T.AssertEqual(result, "arrow_red_12px", "Locale=2, capslock=1 returns arrow_red_12px")

        ; Test third locale
        result := MarkResolver.GetMarkName(3, 0)
        T.AssertEqual(result, "circle_green_12px", "Locale=3, capslock=0 returns circle_green_12px")

        ; Test fourth locale
        result := MarkResolver.GetMarkName(4, 0)
        T.AssertEqual(result, "circle_blue_12px", "Locale=4, capslock=0 returns circle_blue_12px")

        ; Test unknown locale (fallback to undefined)
        result := MarkResolver.GetMarkName(99, 0)
        T.AssertEqual(result, "circle_undefined_12px", "Unknown locale returns circle_undefined_12px")

        ; Test capslock values other than 0/1
        result := MarkResolver.GetMarkName(2, 2)
        T.AssertEqual(result, "undefined_red_12px", "Unknown capslock value returns undefined figure")
    }

    static TestGetMarkFile() {
        T.StartSuite("MarkResolver.GetMarkFile")

        ; Create test config
        testFolder := A_ScriptDir . "\test_files\"
        filesCfg := {
            folder: testFolder,
            extensions: [".png", ".gif"],
            capslockSuffix: "-capslock"
        }

        ; Setup: create test directory and files
        if !DirExist(testFolder)
            DirCreate(testFolder)

        ; Create test files
        FileAppend("", testFolder . "1.png")
        FileAppend("", testFolder . "2.png")
        FileAppend("", testFolder . "2-capslock.png")

        ; Test finding a basic file
        result := MarkResolver.GetMarkFile(filesCfg, 1, 0)
        T.AssertEqual(result, testFolder . "1.png", "Finds 1.png for locale=1")

        ; Test finding file for locale 2
        result := MarkResolver.GetMarkFile(filesCfg, 2, 0)
        T.AssertEqual(result, testFolder . "2.png", "Finds 2.png for locale=2")

        ; Test finding capslock-specific file
        result := MarkResolver.GetMarkFile(filesCfg, 2, 1)
        T.AssertEqual(result, testFolder . "2-capslock.png", "Finds 2-capslock.png for locale=2, capslock=1")

        ; Test fallback when capslock file doesn't exist
        result := MarkResolver.GetMarkFile(filesCfg, 1, 1)
        T.AssertEqual(result, testFolder . "1.png", "Falls back to 1.png when 1-capslock.png doesn't exist")

        ; Test non-existent locale
        result := MarkResolver.GetMarkFile(filesCfg, 99, 0)
        T.AssertEmpty(result, "Returns empty for non-existent locale file")

        ; Cleanup: remove test files and directory
        FileDelete(testFolder . "1.png")
        FileDelete(testFolder . "2.png")
        FileDelete(testFolder . "2-capslock.png")
        DirDelete(testFolder)
    }
}
