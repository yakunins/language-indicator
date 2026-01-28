#requires AutoHotkey v2.0

#include ..\lib\image-utils\UseBase64Image.ahk
#include TestFramework.ahk

class UseBase64ImageTests {
    static Run() {
        this.TestExactNameMatch()
        this.TestPartialNameMatch()
        this.TestEmptyName()
        this.TestNonExistentName()
    }

    static TestExactNameMatch() {
        T.StartSuite("UseBase64Image - Exact Name Match")

        ; Test exact match for arrow images
        result := UseBase64Image("arrow_white_12px")
        T.AssertEqual(result.name, "arrow_white_12px", "Returns correct name for arrow_white_12px")
        T.AssertNotEmpty(result.image, "Returns non-empty image for arrow_white_12px")

        result := UseBase64Image("arrow_red_12px")
        T.AssertEqual(result.name, "arrow_red_12px", "Returns correct name for arrow_red_12px")
        T.AssertNotEmpty(result.image, "Returns non-empty image for arrow_red_12px")

        ; Test exact match for circle images
        result := UseBase64Image("circle_red_12px")
        T.AssertEqual(result.name, "circle_red_12px", "Returns correct name for circle_red_12px")
        T.AssertNotEmpty(result.image, "Returns non-empty image for circle_red_12px")

        result := UseBase64Image("circle_green_12px")
        T.AssertEqual(result.name, "circle_green_12px", "Returns correct name for circle_green_12px")
        T.AssertNotEmpty(result.image, "Returns non-empty image for circle_green_12px")
    }

    static TestPartialNameMatch() {
        T.StartSuite("UseBase64Image - Partial Name Match")

        ; Test partial match (starts with)
        result := UseBase64Image("arrow_white")
        T.Assert(result.name ~= "^arrow_white", "Returns name starting with arrow_white")
        T.AssertNotEmpty(result.image, "Returns non-empty image for partial match")

        result := UseBase64Image("circle_red")
        T.Assert(result.name ~= "^circle_red", "Returns name starting with circle_red")
        T.AssertNotEmpty(result.image, "Returns non-empty image for partial match")
    }

    static TestEmptyName() {
        T.StartSuite("UseBase64Image - Empty Name")

        ; Test empty string
        result := UseBase64Image("")
        T.AssertEqual(result.name, "", "Returns empty name for empty input")
        T.AssertEmpty(result.image, "Returns empty image for empty input")

        ; Test no argument (default parameter)
        result := UseBase64Image()
        T.AssertEqual(result.name, "", "Returns empty name for no argument")
        T.AssertEmpty(result.image, "Returns empty image for no argument")
    }

    static TestNonExistentName() {
        T.StartSuite("UseBase64Image - Non-existent Name")

        ; Test non-existent image name (this was the bug - returned 0 instead of "")
        result := UseBase64Image("circle_undefined_12px")
        T.AssertEqual(result.name, "circle_undefined_12px", "Returns the requested name even if not found")
        T.AssertEmpty(result.image, "Returns empty string (not 0) for non-existent image")
        T.Assert(result.image == "", "Image is exactly empty string, not falsy 0")

        ; Test another non-existent name
        result := UseBase64Image("nonexistent_image")
        T.AssertEmpty(result.image, "Returns empty string for completely unknown name")

        ; Test that the return value is string type, not integer
        result := UseBase64Image("undefined_undefined_undefined")
        T.Assert(Type(result.image) == "String", "Image value is String type, not Integer")
    }
}
