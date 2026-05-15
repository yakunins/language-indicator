#requires AutoHotkey v2.0

#include ..\lib\utils\UseCachedWhileIdle.ahk
#include TestFramework.ahk

class UseCachedWhileIdleTests {
    static counter := 0

    static _incr() {
        UseCachedWhileIdleTests.counter += 1
        return UseCachedWhileIdleTests.counter
    }

    static Run() {
        this.TestFirstCallComputes()
        this.TestCacheReuseWhenIdle()
        this.TestRefreshAfterTtl()
        this.TestKeyPressInvalidatesCache()
        this.TestKeyReleaseRestoresCache()
    }

    static TestFirstCallComputes() {
        T.StartSuite("UseCachedWhileIdle.FirstCallComputes")
        UseCachedWhileIdleTests.counter := 0
        AnyKeyState.pressed := false
        getter := UseCachedWhileIdle(() => UseCachedWhileIdleTests._incr(), 10000)
        result := getter.Call()
        T.AssertEqual(result, 1, "First call returns 1")
        T.AssertEqual(UseCachedWhileIdleTests.counter, 1, "fn called exactly once")
    }

    static TestCacheReuseWhenIdle() {
        T.StartSuite("UseCachedWhileIdle.CacheReuseWhenIdle")
        UseCachedWhileIdleTests.counter := 0
        AnyKeyState.pressed := false
        getter := UseCachedWhileIdle(() => UseCachedWhileIdleTests._incr(), 10000)
        getter.Call()
        getter.Call()
        getter.Call()
        T.AssertEqual(UseCachedWhileIdleTests.counter, 1, "fn called only once across 3 rapid calls")
    }

    static TestRefreshAfterTtl() {
        T.StartSuite("UseCachedWhileIdle.RefreshAfterTtl")
        UseCachedWhileIdleTests.counter := 0
        AnyKeyState.pressed := false
        getter := UseCachedWhileIdle(() => UseCachedWhileIdleTests._incr(), 30)
        getter.Call()
        Sleep(50)
        getter.Call()
        T.AssertEqual(UseCachedWhileIdleTests.counter, 2, "fn called twice after refreshAfter elapses")
    }

    static TestKeyPressInvalidatesCache() {
        T.StartSuite("UseCachedWhileIdle.KeyPressInvalidatesCache")
        UseCachedWhileIdleTests.counter := 0
        AnyKeyState.pressed := false
        getter := UseCachedWhileIdle(() => UseCachedWhileIdleTests._incr(), 10000)
        getter.Call()                       ; cache populated
        AnyKeyState.pressed := true         ; simulate a key being held
        getter.Call()
        getter.Call()
        T.AssertEqual(UseCachedWhileIdleTests.counter, 3, "fn called on every call while a key is pressed")
    }

    static TestKeyReleaseRestoresCache() {
        T.StartSuite("UseCachedWhileIdle.KeyReleaseRestoresCache")
        UseCachedWhileIdleTests.counter := 0
        AnyKeyState.pressed := true
        getter := UseCachedWhileIdle(() => UseCachedWhileIdleTests._incr(), 10000)
        getter.Call()                       ; cache populated under "pressed" but key state cleared next
        AnyKeyState.pressed := false
        getter.Call()
        getter.Call()
        T.AssertEqual(UseCachedWhileIdleTests.counter, 1, "fn not re-called after key released (cache reused)")
    }
}
