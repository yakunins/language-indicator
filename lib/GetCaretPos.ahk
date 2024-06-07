#Requires AutoHotkey v2.0

; https://www.reddit.com/r/AutoHotkey/comments/ysuawq/get_the_caret_location_in_any_program/
GetCaretPos(&left, &top, &right?, &bottom?, &detectMethod?) {
	detectMethod := "failure"
	initCaretW := 1
	initCaretH := 20

	; caret ops detection priority: CaretGetPos > AccessibleObj > UIA
	savedCaret := A_CoordModeCaret
	CoordMode "Caret", "Screen"
	CaretGetPos(&X, &Y) ; default caret
	CoordMode "Caret", savedCaret
	if IsInteger(X) && (X | Y) != 0 {
		left := X
		right := X + initCaretW
		top := Y
		bottom := Y + initCaretH
		detectMethod := "caret"
		return
	}

	; accessible object caret
	try {
		static _ := DllCall("LoadLibrary", "Str","oleacc", "Ptr")
		idObject := 0xFFFFFFF8 ; OBJID_CARET
		if DllCall("oleacc\AccessibleObjectFromWindow", "ptr", WinExist("A"), "uint",idObject &= 0xFFFFFFFF
			, "ptr",-16 + NumPut("int64", idObject == 0xFFFFFFF0 ? 0x46000000000000C0 : 0x719B3800AA000C81, NumPut("int64", idObject == 0xFFFFFFF0 ? 0x0000000000020400 : 0x11CF3C3D618736E0, IID := Buffer(16)))
			, "ptr*", oAcc := ComValue(9,0)) = 0 {
			x := Buffer(4), y:=Buffer(4), w:=Buffer(4), h:=Buffer(4)
			oAcc.accLocation(ComValue(0x4003, x.ptr, 1), ComValue(0x4003, y.ptr, 1), ComValue(0x4003, w.ptr, 1), ComValue(0x4003, h.ptr, 1), 0)
			X := NumGet(x,0,"int"), Y:=NumGet(y,0,"int"), W:=NumGet(w,0,"int"), H:=NumGet(h,0,"int")
			if (X | Y) != 0 {
				X := X - 1 ; should be 1px less

				left := X
				right := X + W
				top := Y
				bottom := Y + H

				detectMethod := "accessible"
				return
			}
		}
	}

	; uia/wpf
	try {
		uia := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
		ComCall(8, uia, "ptr*", focusedEle := ComValue(13, 0)) ; uia->GetFocusedElement(&focusedEle);
		if !focusedEle.Ptr {
			throw
		}

		ComCall(20, uia, "ptr*", cacheRequest := ComValue(13, 0)) ; uia->CreateCacheRequest(&cacheRequest);
		if !cacheRequest.Ptr {
			throw
		}

		ComCall(17, uia, "ptr*", rawViewCondition := ComValue(13, 0)) ; uia->get_RawViewCondition(&rawViewCondition);
		if !rawViewCondition.Ptr {
			throw
		}

		ComCall(9, cacheRequest, "ptr", rawViewCondition) ; cacheRequest->put_TreeFilter(rawViewCondition);
		ComCall(3, cacheRequest, "int", 30001) ; cacheRequest->AddProperty(UIA_BoundingRectanglePropertyId);

		var := Buffer(24, 0)
		ref := ComValue(0x400C, var.Ptr)
		ref[] := ComValue(8, "WpfCaret")
		ComCall(23, uia, "int", 30012, "ptr", var, "ptr*", condition := ComValue(13, 0)) ; uia->CreatePropertyCondition(UIA_ClassNamePropertyId, CComVariant(L"WpfCaret"), &classNameCondition);
		if !condition.Ptr {
			throw
		}

		ComCall(7, focusedEle, "int", 4, "ptr", condition, "ptr", cacheRequest, "ptr*", wpfCaret := ComValue(13, 0)) ; focusedEle->FindFirstBuildCache(TreeScope_Descendants, condition, cacheRequest, &wpfCaret);
		if !wpfCaret.Ptr {
			throw
		}

		ComCall(75, wpfCaret, "ptr", rect := Buffer(16)) ; wpfCaret->get_CachedBoundingRectangle(&rect);
		getRect(rect, &left, &top, &right, &bottom)
		detectMethod := "wpf"
		return
	}

	; UIA caret (aka metro app)
	; https://www.reddit.com/r/AutoHotkey/comments/ysuawq/get_the_caret_location_in_any_program/
	try {
		IUIA := ComObject("{e22ad333-b25f-460c-83d0-0581107395c9}", "{34723aff-0c9d-49d0-9896-7ab52df8cd8a}")
		ComCall(8, IUIA, "ptr*", &FocusedEl:=0) ; GetFocusedElement
		; Implementation uses only TextPattern GetSelections and not TextPattern2 GetCaretRange.
		ComCall(16, FocusedEl, "int", 10014, "ptr*", &patternObject:=0), ObjRelease(FocusedEl) ; GetCurrentPattern. TextPattern = 10014
		if patternObject {
			ComCall(5, patternObject, "ptr*", &selectionRanges:=0), ObjRelease(patternObject) ; GetSelections
			ComCall(4, selectionRanges, "int", 0, "ptr*", &selectionRange:=0) ; GetElement
			ComCall(10, selectionRange, "ptr*", &boundingRects:=0), ObjRelease(selectionRange), ObjRelease(selectionRanges) ; GetBoundingRectangles
			if (Rect := ComValue(0x2005, boundingRects)).MaxIndex() = 3 { ; VT_ARRAY | VT_R8
				X := Round(Rect[0])
				Y := Round(Rect[1])
				W := Round(Rect[2])
				H := Round(Rect[3])

				left := X
				right := X + W
				top := Y
				bottom := Y + H

				detectMethod := "uia"
				return
			}
		}
	}

	static getRect(buf, &left, &top, &right, &bottom) {
		left := NumGet(buf, 0, "int")
		top := NumGet(buf, 4, "int")
		right := NumGet(buf, 8, "int")
		bottom := NumGet(buf, 12, "int")
	}
}
