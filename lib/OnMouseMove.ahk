#Requires AutoHotkey v2.0

#include Log.ahk
#include Jsons.ahk

fps := GetRefreshRate()
frame := Floor(1000 / fps)
currentTime := TickCount()

global pstore := []
pstoreMaxLength := 3
init := GetCurrent()
Loop pstoreMaxLength
    pstore.Push(init)

OnPointerMoveOrChange(fn) {
    HandleFrame() {
        prev := pstore[1]
        curr := GetCurrent()

        curr.missprediction := vRound(vSub(curr.v, prev.predict))
        curr.predict := Predict() ; vRound(vAdd(Predict(), vMul(curr.missprediction, -1 / 2)))
        pstore.InsertAt(1, curr)
        if (pstore.Length > pstoreMaxLength)
            pstore.RemoveAt(pstore.Length)
        fn()
    }

    ; https://www.autohotkey.com/docs/v2/lib/Sleep.htm#ExShorterSleep
    SleepDuration := frame - 1
    TimePeriod := frame - 1
    DllCall("Winmm\timeBeginPeriod", "UInt", TimePeriod)
    loop {
        DllCall("Sleep", "UInt", SleepDuration)
        HandleFrame()
    }
    DllCall("Winmm\timeEndPeriod", "UInt", TimePeriod)
}

Predict() {
    speeds := aMap(pstore, GetSpeeds)
    period := pstore[1].period

    ; Log(Jsons.Dump(pstore, "  "))

    d := vMul(speeds[1], period) ; speed
    v := vAbs(d)
    if (v < 1)
        return vZero

    k := v / (v + 4)
    dd := vMul(vSub(speeds[2], speeds[1]), period * k * 0.5) ; acceleration
    ddd := vMul(vSub(speeds[3], speeds[2]), period * k * k * 0.25) ; speed of acceleration
    prediction := vAdd(vAdd(vMul(d, 1.2), dd), ddd)

    smooth := vAdd(vMul(prediction, 0.5), vMul(pstore[2].predict, 0.5))

    return vRound(smooth)
}


PredictOld() {
    curr := pstore[1]
    prev := pstore[2]
    t := curr.period
    tPrev := prev.period
    tSum := t + tprev
    s := vMul(curr.speed, 1 / t)
    sPrev := vMul(prev.speed, 1 / tPrev)
    a := {
        x: Acceleration(s.x, sPrev.x),
        y: Acceleration(s.y, sPrev.y),
    }
    vel := vAbs(s) * t
    acc := vAbs(a) * t
    velMult := 0.5 + vel / (vel + 1) ; 0.5...1...1.5
    accMult := 0.5 + acc / (acc + 1)
    prediction := vMul(vAdd(vMul(s, 0.5), vMul(a, 0.25)), t * velMult)
    smoothPrediction := vAdd(prediction, vMul(prev.predict, tPrev / (tSum * accMult)))
    ; Log("vel:" vel "`nt:" t "`nprediction:" Jsons.Dump(smoothPrediction, "  "))
    ; Log("velMult:" velMult)
    return smoothPrediction
}

GetCurrent() {
    result := {
        cursor: A_Cursor,
        time: TickCount(),
        p: GetMousePos(),
        predict: {
            x: 0,
            y: 0
        },
    }
    if pstore.Length > 0 {
        prev := pstore[1]
    } else {
        prev := {
            time: result.time - frame,
            p: { x: 0, y: 0 }
        }
    }
    result.v := vSub(result.p, prev.p)
    result.period := result.time - prev.time
    return result
}

Acceleration(v, vPrev) {
    if v == 0 and vPrev == 0
        return 0
    if v == 0
        return vPrev / 1.5
    if vPrev == 0
        return v / -1.5

    acc := v - vPrev
    sensitivity := 1.5
    if Abs(acc) > Abs(v * sensitivity) or Abs(acc) > Abs(vPrev * sensitivity) {
        ; Log('unexpectedly high acceleration')
        return 0
    }
    return acc
}

vAdd(o1, o2) {
    return {
        x: o1.x + o2.x,
        y: o1.y + o2.y
    }
}
vSub(o1, o2) {
    return {
        x: o1.x - o2.x,
        y: o1.y - o2.y
    }
}
vMul(o1, k) {
    return {
        x: o1.x * k,
        y: o1.y * k
    }
}
vAbs(o1) {
    return Sqrt(o1.x * o1.x + o1.y * o1.y)
}
vMax(o1) {
    return o1.x > o1.y ? Abs(o1.x) : Abs(o1.y)
}
vMin(o1) {
    return o1.x < o1.y ? Abs(o1.x) : Abs(o1.y)
}
vRound(o1) {
    return {
        x: Round(o1.x),
        y: Round(o1.y)
    }
}
vEq(o1, o2) {
    return o1.x == o2.x and o1.y == o2.y
}
vZero := {
    x: 0,
    y: 0
}

GetMousePos() {
    global
    CoordMode "Mouse", "Screen"
    MouseGetPos(&xPos, &yPos)
    return {
        x: xPos,
        y: yPos
    }
}

; https://www.autohotkey.com/boards/viewtopic.php?style=19&p=565832#p565832
GetRefreshRate() {
    queryEnum := ComObjGet('winmgmts:').ExecQuery('Select * from Win32_VideoController')._NewEnum()
    if queryEnum(&p) {
        current := p.CurrentRefreshRate
        if current > 10
            return current
        return 30 ; default
    }
}

TickCount() {
    DllCall("QueryPerformanceFrequency", "Int64*", &freq := 0)
    DllCall("QueryPerformanceCounter", "Int64*", &counter := 0)
    return Floor(counter / (freq / 1000))
}

aMap(arr, fn) {
    res := []
    Loop arr.Length
        res.Push(fn(arr[A_Index]))
    return res
}

GetSpeeds(item) {
    return vMul(item.v, 1 / item.period)
}