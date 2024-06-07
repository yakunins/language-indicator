#Requires AutoHotkey v2.0

; https://github.com/Tebayaki/AutoHotkeyScripts/blob/main/lib/GetCaretPosEx/GetCaretPosEx.ahk
GetCaretRect(&left?, &top?, &right?, &bottom?, &detectMethod?) {
	detectMethod := "failure" ; unable to detect
	if getCaretPosFromGui(&hwnd := 0)
		return true

	try {
		className := WinGetClass(hwnd)
	} catch {
		className := ""
	}

	if className ~= "^(?:Windows|Microsoft)\.UI\..+"
		funcs := [getCaretPosFromUIA, getCaretPosFromMSAA, getAccessObj]
	else if className ~= "^HwndWrapper\[PowerShell_ISE\.exe;;[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\]"
		funcs := [getCaretPosFromWpfCaret]
	else
		funcs := [getCaretPosFromMSAA, getAccessObj, getCaretPosFromUIA]
	for fn in funcs {
		if fn()
			return true
	}
	return false

	; get caret functions
	getCaretPosFromGui(&hwnd) {
		x64 := A_PtrSize == 8
		guiThreadInfo := Buffer(x64 ? 72 : 48)
		NumPut("uint", guiThreadInfo.Size, guiThreadInfo)
		if DllCall("GetGUIThreadInfo", "uint", 0, "ptr", guiThreadInfo) {
			if hwnd := NumGet(guiThreadInfo, x64 ? 48 : 28, "ptr") {
				getRect(guiThreadInfo.Ptr + (x64 ? 56 : 32), &left, &top, &right, &bottom)
				scaleRect(getWindowScale(hwnd), &left, &top, &right, &bottom)
				clientToScreenRect(hwnd, &left, &top, &right, &bottom)
				detectMethod := "getCaretPosFromGui"
				return true
			}
			hwnd := NumGet(guiThreadInfo, x64 ? 16 : 12, "ptr")
		}
		return false
	}

	getCaretPosFromMSAA() {
		if !hOleacc := DllCall("LoadLibraryW", "str", "oleacc.dll", "ptr") {
			return false
		}
		hOleacc := { Ptr: hOleacc, __Delete: (_) => DllCall("FreeLibrary", "ptr", _) }
		static IID_IAccessible := guidFromString("{618736e0-3c3d-11cf-810c-00aa00389b71}")
		if !DllCall("oleacc\AccessibleObjectFromWindow", "ptr", hwnd, "uint", 0xfffffff8, "ptr", IID_IAccessible, "ptr*", accCaret := ComValue(13, 0), "int") {
			if A_PtrSize == 8 {
				varChild := Buffer(24, 0)
				NumPut("ushort", 3, varChild)
				hr := ComCall(22, accCaret, "int*", &x := 0, "int*", &y := 0, "int*", &w := 0, "int*", &h := 0, "ptr", varChild, "int")
			} else {
				hr := ComCall(22, accCaret, "int*", &x := 0, "int*", &y := 0, "int*", &w := 0, "int*", &h := 0, "int64", 3, "int64", 0, "int")
			}
			if !hr {
				pt := x | y << 32
				DllCall("ScreenToClient", "ptr", hwnd, "int64*", &pt)
				left := pt & 0xffffffff
				top := pt >> 32
				right := left + w
				bottom := top + h
				scaleRect(getWindowScale(hwnd), &left, &top, &right, &bottom)
				clientToScreenRect(hwnd, &left, &top, &right, &bottom)
				detectMethod := "getCaretPosFromMSAA"
				return true
			}
		}
		return false
	}

	getAccessObj() {
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

				detectMethod := "getAccessObj"
				return true
			}
		}
		return false
	}

	getCaretPosFromUIA() {
		try {
			uia := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
			ComCall(20, uia, "ptr*", cacheRequest := ComValue(13, 0)) ; uia->CreateCacheRequest(&cacheRequest);
			if !cacheRequest.Ptr
				return false
			ComCall(4, cacheRequest, "ptr", 10014) ; cacheRequest->AddPattern(UIA_TextPatternId);
			ComCall(4, cacheRequest, "ptr", 10024) ; cacheRequest->AddPattern(UIA_TextPattern2Id);

			ComCall(12, uia, "ptr", cacheRequest, "ptr*", focusedEle := ComValue(13, 0)) ; uia->GetFocusedElementBuildCache(cacheRequest, &focusedEle);
			if !focusedEle.Ptr
				return false

			static IID_IUIAutomationTextPattern2 := guidFromString("{506a921a-fcc9-409f-b23b-37eb74106872}")
			range := ComValue(13, 0)
			ComCall(15, focusedEle, "int", 10024, "ptr", IID_IUIAutomationTextPattern2, "ptr*", textPattern := ComValue(13, 0)) ; focusedEle->GetCachedPatternAs(UIA_TextPattern2Id, IID_PPV_ARGS(&textPattern));
			if textPattern.Ptr {
				ComCall(10, textPattern, "int*", &isActive := 0, "ptr*", range) ; textPattern->GetCaretRange(&isActive, &range);
				if range.Ptr
					goto getRangeInfo
			}
			; If no caret range, get selection range.
			static IID_IUIAutomationTextPattern := guidFromString("{32eba289-3583-42c9-9c59-3b6d9a1e9b6a}")
			ComCall(15, focusedEle, "int", 10014, "ptr", IID_IUIAutomationTextPattern, "ptr*", textPattern) ; focusedEle->GetCachedPatternAs(UIA_TextPatternId, IID_PPV_ARGS(&textPattern));
			if textPattern.Ptr {
				ComCall(5, textPattern, "ptr*", ranges := ComValue(13, 0)) ; textPattern->GetSelection(&ranges);
				if ranges.Ptr {
					; Retrieve the last selection range.
					ComCall(3, ranges, "int*", &len := 0) ; ranges->get_Length(&len);
					if len > 0 {
						ComCall(4, ranges, "int", len - 1, "ptr*", range) ; ranges->GetElement(len - 1, &range);
						if range.Ptr {
							; Collapse the range.
							ComCall(15, range, "int", 0, "ptr", range, "int", 1) ; range->MoveEndpointByRange(TextPatternRangeEndpoint_Start, range, TextPatternRangeEndpoint_End);
							goto getRangeInfo
						}
					}
				}
			}
			return false
getRangeInfo:
			psa := 0
			; This is a degenerate text range, we have to expand it.
			ComCall(6, range, "int", 0) ; range->ExpandToEnclosingUnit(TextUnit_Character);
			ComCall(10, range, "ptr*", &psa) ; range->GetBoundingRectangles(&psa);
			if psa {
				rects := ComValue(0x2005, psa, 1) ; SafeArray<double>
				if rects.MaxIndex() >= 3 {
					rects[2] := 0
					goto end
				}
			}
			; ExpandToEnclosingUnit by character may be invalid in some control if the range is at the end of the document.
			; Assume that the range is at the end of the document and not in an empty line, try to expand it by line.
			ComCall(6, range, "int", 3) ; range->ExpandToEnclosingUnit(TextUnit_Line)
			ComCall(10, range, "ptr*", &psa) ; range->GetBoundingRectangles(&psa);
			if psa {
				rects := ComValue(0x2005, psa, 1) ; SafeArray<double>
				if rects.MaxIndex() >= 3 {
					; Here rects is {x, y, w, h}, we take the end endpoint as the caret position.
					rects[0] := rects[0] + rects[2]
					rects[2] := 0
					goto end
				}
			}
			return false
end:
			left := Round(rects[0])
			top := Round(rects[1])
			right := left + Round(rects[2])
			bottom := top + Round(rects[3])
			w := right - left
			if (w < 1 and w > -1)
				right := left + 1
			detectMethod := "getCaretPosFromUIA"
			return true
		}
		return false
	}

	getCaretPosFromWpfCaret() {
		try {
			uia := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
			ComCall(8, uia, "ptr*", focusedEle := ComValue(13, 0)) ; uia->GetFocusedElement(&focusedEle);
			if !focusedEle.Ptr
				return false

			ComCall(20, uia, "ptr*", cacheRequest := ComValue(13, 0)) ; uia->CreateCacheRequest(&cacheRequest);
			if !cacheRequest.Ptr
				return false

			ComCall(17, uia, "ptr*", rawViewCondition := ComValue(13, 0)) ; uia->get_RawViewCondition(&rawViewCondition);
			if !rawViewCondition.Ptr
				return false

			ComCall(9, cacheRequest, "ptr", rawViewCondition) ; cacheRequest->put_TreeFilter(rawViewCondition);
			ComCall(3, cacheRequest, "int", 30001) ; cacheRequest->AddProperty(UIA_BoundingRectanglePropertyId);

			var := Buffer(24, 0)
			ref := ComValue(0x400C, var.Ptr)
			ref[] := ComValue(8, "WpfCaret")
			ComCall(23, uia, "int", 30012, "ptr", var, "ptr*", condition := ComValue(13, 0)) ; uia->CreatePropertyCondition(UIA_ClassNamePropertyId, CComVariant(L"WpfCaret"), &classNameCondition);
			if !condition.Ptr
				return false

			ComCall(7, focusedEle, "int", 4, "ptr", condition, "ptr", cacheRequest, "ptr*", wpfCaret := ComValue(13, 0)) ; focusedEle->FindFirstBuildCache(TreeScope_Descendants, condition, cacheRequest, &wpfCaret);
			if !wpfCaret.Ptr
				return false

			ComCall(75, wpfCaret, "ptr", rect := Buffer(16)) ; wpfCaret->get_CachedBoundingRectangle(&rect);
			getRect(rect, &left, &top, &right, &bottom)
			detectMethod := "getCaretPosFromWpfCaret"
			return true
		}
		return false
	}

	static guidFromString(str) {
		DllCall("ole32\CLSIDFromString", "str", str, "ptr", buf := Buffer(16), "hresult")
		return buf
	}

	static getRect(buf, &left, &top, &right, &bottom) {
		left := NumGet(buf, 0, "int")
		top := NumGet(buf, 4, "int")
		right := NumGet(buf, 8, "int")
		bottom := NumGet(buf, 12, "int")
	}

	static getWindowScale(hwnd) {
		if winDpi := DllCall("GetDpiForWindow", "ptr", hwnd, "uint")
			return A_ScreenDPI / winDpi
		return 1
	}

	static scaleRect(scale, &left, &top, &right, &bottom) {
		left := Round(left * scale)
		top := Round(top * scale)
		right := Round(right * scale)
		bottom := Round(bottom * scale)
	}

	static clientToScreenRect(hwnd, &left, &top, &right, &bottom) {
		w := right - left
		h := bottom - top
		pt := left | top << 32
		DllCall("ClientToScreen", "ptr", hwnd, "int64*", &pt)
		left := pt & 0xffffffff
		top := pt >> 32
		right := left + w
		bottom := top + h
	}
}
