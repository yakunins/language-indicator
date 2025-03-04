#requires AutoHotkey v2.0

; return milliseconds (ms)
TickCount() {
	DllCall("QueryPerformanceFrequency", "Int64*", &freq := 0)
	DllCall("QueryPerformanceCounter", "Int64*", &counter := 0)
	return Floor(counter / (freq / 1000))
}