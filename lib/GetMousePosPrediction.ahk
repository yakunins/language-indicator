#requires AutoHotkey v2.0
#include TickCount.ahk
#include Log.ahk

zeroSpeed := { x: 0, y: 0, period: 100 }
zeroPos := { x: -1, y: -1, time: 0, speed: zeroSpeed }

; mouse postion storage
global mouseState := {
	maxPredictionDelay: 50 + 16, ; equal 20 fps + 16 ms, no speed prediction if less
	maxPredictionSpeed: 24, ; px per frame at 60hz
	curr: zeroPos, ; latest measurement
	prev: zeroPos, ; stored previous measurement
	hoveredWindow: 0,
}

; predict next mouse cursor position to reduce distance lag between cursor and mark
GetMousePos(predictionAmount := 0) {
	global mouseState

	GetMouseData()

	if predictionAmount <= 0 {
		return {
			x: mouseState.curr.x,
			y: mouseState.curr.y
		}
	}

	p0 := mouseState.curr
	p1 := mouseState.prev

	prediction := {
		x: p0.speed.x * 0.65 + p1.speed.x * 0.35,
		y: p0.speed.y * 0.65 + p1.speed.y * 0.35
	}

	factor := predictionAmount * 1.25

	return {
		x: p0.x + Flooor(prediction.x * factor),
		y: p0.y + Flooor(prediction.y * factor)
	}
}

GetMouseData() {
	global mouseState

	CoordMode "Mouse", "Screen"
	MouseGetPos(&mx, &my, &wnd)

	time := TickCount() ; milliseconds
	pos := { x: mx, y: my, time: time }
	speed := GetSpeed(pos, mouseState.curr)

	mouseState.prev := mouseState.curr ; copying
	mouseState.curr := { x: pos.x, y: pos.y, time: time, speed: speed, hoveredWindow: wnd } ; new data

	return mouseState.curr
}

GetSpeed(posCurr, posPrev) {
	period := posCurr.time - posPrev.time

	if (period < 1 or period > mouseState.maxPredictionDelay)
		return zeroSpeed

	x := posCurr.x - posPrev.x
	y := posCurr.y - posPrev.y

	maxSpeed := mouseState.maxPredictionSpeed

	; max positive
	if (x > maxSpeed)
		x := maxSpeed
	if (y > maxSpeed)
		y := maxSpeed

	; min negative
	if (x < maxSpeed * -1)
		x := maxSpeed * -1
	if (y < maxSpeed * -1)
		y := maxSpeed * -1

	return { x: x, y: y, period: period }
}

Flooor(n) {
	if n > 0
		return Floor(n)

	return -1 * Floor(Abs(n))
}