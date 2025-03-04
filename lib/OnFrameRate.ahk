#requires AutoHotkey v2.0
#include UseCached.ahk
#include TickCount.ahk
;#include Log.ahk

; run fn at (almost) monitor's fps rate for certain period of time
OnFrameRate(fn, timeLimit := 100) {
    timeEnd := TickCount() + timeLimit
    fps := GetCachedFps()
    framesLimit := Round((timeLimit / 1000) * fps) - 1
    sleepDuration := Floor(1000 / fps) ; one frame
    timePeriod := 7 ; 3
    framesCount := 0
    DllCall("Winmm\timeBeginPeriod", "UInt", timePeriod) ; https://www.autohotkey.com/docs/v2/lib/Sleep.htm#ExShorterSleep
    while TickCount() < timeEnd and framesCount < framesLimit {
        DllCall("Sleep", "UInt", sleepDuration) ; sleep precisely for one frame
        fn.Call() ; main
        framesCount += 1
    }
    DllCall("Winmm\timeEndPeriod", "UInt", timePeriod)
}

; https://www.autohotkey.com/boards/viewtopic.php?style=19&p=565832#p565832
GetFps(defaultFrameRate := 60) {
    ; time-consuming operation
    queryEnum := ComObjGet('winmgmts:').ExecQuery('Select * from Win32_VideoController')._NewEnum()
    if queryEnum(&p) {
        current := p.CurrentRefreshRate
        if (current > 10)
            return current
    }
    return Floor(defaultFrameRate)
}

GetCachedFps := UseCached(GetFps, 1000) ; cache fn result for 1 second
