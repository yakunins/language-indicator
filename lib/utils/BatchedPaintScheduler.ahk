; Frame rate synchronization utilities for smooth visual updates
#requires AutoHotkey v2.0
#include UseCached.ahk
#include TickCount.ahk

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
    try {
        queryEnum := ComObjGet('winmgmts:').ExecQuery('Select * from Win32_VideoController')._NewEnum()
        q := queryEnum(&p)
        if q and p != "" {
            current := p.CurrentRefreshRate
            if (current > 10)
                return current
        }
    }
    return Floor(defaultFrameRate)
}

GetCachedFps := UseCached(GetFps, 5000) ; cache fn result for 5 seconds

/*
BatchedPaintScheduler - Coordinates multiple indicator paint operations

Purpose:
  When multiple indicators (caret + cursor) need to paint, this scheduler
  batches their paint calls together in a single frame-synced loop.
  This prevents visual glitches when two ImagePainter instances would
  otherwise interfere with each other.

Usage:
  1. Each indicator calls RegisterIndicator() in its constructor
  2. Each indicator calls QueuePaint(callback, id, duration) when ready to paint
  3. When all registered indicators have queued, FlushAll() runs them together

Flow:
  CaretIndicator  → QueuePaint(fn, "caret", 17)  ─┐
  CursorIndicator → QueuePaint(fn, "cursor", 17) ─┴→ FlushAll() runs both
*/
class BatchedPaintScheduler {
    static paintCallbacks := Map()
    static frameDurationMs := -1
    static expectedIndicatorCount := 0

    ; Called by each indicator in __New() to register itself
    static RegisterIndicator() {
        this.expectedIndicatorCount += 1
        return this
    }

    ; Called when an indicator no longer needs batched painting (e.g., using cursor files)
    static UnregisterIndicator() {
        if (this.expectedIndicatorCount > 0)
            this.expectedIndicatorCount -= 1
        return this
    }

    ; Queue a paint callback; flushes when all indicators have queued
    static QueuePaint(fn, id, durationMs) {
        this.paintCallbacks.Set(id, fn)
        this.frameDurationMs := MinT(this.frameDurationMs, durationMs)

        if (this.expectedIndicatorCount > this.paintCallbacks.Count)
            return ; wait for all indicators to queue

        this.FlushAll()
    }

    ; Execute all queued paint callbacks in a frame-synced loop
    static FlushAll() {
        if this.paintCallbacks.Count < 1
            return

        if this.frameDurationMs < 1
            return

        fps := GetCachedFps()
        framesCountLimit := Round((this.frameDurationMs / 1000) * fps) - 1
        sleepMs := Floor(1000 / fps) ; one frame duration
        minTimeResolution := 7
        end := TickCount() + this.frameDurationMs - sleepMs - 1
        framesCount := 0

        ; Enable precise timer resolution for accurate frame timing
        DllCall("Winmm\timeBeginPeriod", "UInt", minTimeResolution)
        while TickCount() < end and framesCount < framesCountLimit {
            DllCall("Sleep", "UInt", sleepMs)
            for id, fn in this.paintCallbacks
                fn.Call()
            framesCount += 1
        }
        DllCall("Winmm\timeEndPeriod", "UInt", minTimeResolution)

        this.paintCallbacks.Clear()
    }
}

MinT(t1, t2) {
    if t1 < 1
        return t2
    return Min(t1, t2)
}
