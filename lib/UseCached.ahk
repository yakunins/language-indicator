#requires AutoHotkey v2.0

/*
f1:: {
    MsgBox("now: " GetTime() "`n3 sec: " GetTime3000() "`n10 sec: " GetTime10000() "`n`n`n")
}
global counter := 0
GetTimeBase() {
    global counter
    counter += 1
    return FormatTime(A_Now, 'mm:ss') " (" counter ")"
}

GetTime := useCached(GetTimeBase)
GetTime3000 := useCached(GetTime, 3000)
GetTime10000 := useCached(GetTime, 10000)
*/

UseCached(fn, timeout := 100) {
    if (timeout < 1)
        return fn
    cache := ""
    lastCallTime := 0

    ; returns a closure capturing cache and lastCallTime
    return () => (
        currentTime := A_TickCount,
        (cache == "" || (currentTime - lastCallTime) > timeout)
            ? (cache := fn(), lastCallTime := currentTime, cache)
        : cache
    )
}