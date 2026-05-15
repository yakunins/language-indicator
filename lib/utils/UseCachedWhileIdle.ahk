; Memoization utility that invalidates the cache while the user is actively pressing
; any key or mouse button, and forces a periodic refresh after refreshAfter ms.
;
; Returns a callable object; invoke via getter.Call() or getter().
;
; Example:
;   getPos := UseCachedWhileIdle(() => ExpensiveCaretRect(), 100)
;   pos := getPos.Call()  ; cache miss → fn(); subsequent calls reuse the result
;                         ; until any key/button is held or 100ms elapse.
#requires AutoHotkey v2.0

#include GetAnyKeyState.ahk

class WhileIdleCache {
    __New(fn, refreshAfter) {
        this.fn := fn
        this.refreshAfter := refreshAfter
        this.cache := ""
        this.cachedAt := 0
    }

    Call() {
        if this._needsRefresh() {
            this.cache := (this.fn)()
            this.cachedAt := A_TickCount
        }
        return this.cache
    }

    _needsRefresh() {
        if this.cache == ""
            return true
        if GetAnyKeyState()
            return true
        return (A_TickCount - this.cachedAt) > this.refreshAfter
    }
}

UseCachedWhileIdle(fn, refreshAfter := 100) {
    return WhileIdleCache(fn, refreshAfter)
}
