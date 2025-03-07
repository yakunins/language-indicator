#requires AutoHotkey v2.0
#include UseCached.ahk
#include TickCount.ahk
;#include Log.ahk

; run fn at (almost) every frame for certain period of time
OnFrameRate(fn, timeLimit := 100) {
    fps := GetCachedFps()
    framesCountLimit := Round((timeLimit / 1000) * fps) - 1
    sleep := Floor(1000 / fps) ; = one frame
    minTimeResolution := 7
    end := TickCount() + timeLimit - sleep - 1
    framesCount := 0

    DllCall("Winmm\timeBeginPeriod", "UInt", minTimeResolution) ; https://www.autohotkey.com/docs/v2/lib/Sleep.htm#ExShorterSleep
    while TickCount() < end and framesCount < framesCountLimit {
        DllCall("Sleep", "UInt", sleep) ; sleep precisely one frame
        fn.Call() ; main
        framesCount += 1
    }
    DllCall("Winmm\timeEndPeriod", "UInt", minTimeResolution)
}

; https://www.autohotkey.com/boards/viewtopic.php?style=19&p=565832#p565832
GetFps(defaultFrameRate := 60) {
    ; time-consuming operation
    queryEnum := ComObjGet('winmgmts:').ExecQuery('Select * from Win32_VideoController')._NewEnum()
    try {
        q := queryEnum(&p)
        if q and p != "" {
            current := p.CurrentRefreshRate
            if (current > 10)
                return current
        }
    }
    return Floor(defaultFrameRate)
}

GetCachedFps := UseCached(GetFps, 1000) ; cache fn result for 1 second

class OnFrameRateScheduler {
    static subscribers := Map()
    static timeLimit := -1 ; one for all, minimal
    static minSubscribersCount := 0

    static Increase() {
        this.minSubscribersCount += 1
        return this
    }
    static Decrease() {
        if (this.minSubscribersCount > 0)
            this.minSubscribersCount -= 1
        return this
    }

    static Subscribe(fn, fnid, timeLimit) {
        this.subscribers.Set(fnid, fn)
        this.timeLimit := Mint(this.timeLimit, timeLimit)
    }

    static Clear() {
        this.subscribers.Clear()
    }

    static ScheduleRun(fn, fnid, timelimit) {
        this.Subscribe(fn, fnid, timelimit)

        if (this.minSubscribersCount > this.subscribers.Count)
            return ; wait all subscribers to schedule their run

        this.RunAll() ; enought subscribers = time has come
    }

    static RunAll() {
        if this.subscribers.Count < 1
            return ; no subscribers

        if this.timeLimit < 1
            return ; no limit

        fps := GetCachedFps()
        framesCountLimit := Round((this.timeLimit / 1000) * fps) - 1
        sleep := Floor(1000 / fps) ; = one frame
        minTimeResolution := 7
        end := TickCount() + this.timeLimit - sleep - 1
        framesCount := 0

        DllCall("Winmm\timeBeginPeriod", "UInt", minTimeResolution) ; https://www.autohotkey.com/docs/v2/lib/Sleep.htm#ExShorterSleep
        while TickCount() < end and framesCount < framesCountLimit {
            DllCall("Sleep", "UInt", sleep)
            for id, fn in this.subscribers {
                fn.Call()
            }
            framesCount += 1
        }
        DllCall("Winmm\timeEndPeriod", "UInt", minTimeResolution)
        this.Clear()
    }
}

Mint(t1, t2) {
    if t1 < 1
        return t2
    return Min(t1, t2)
}