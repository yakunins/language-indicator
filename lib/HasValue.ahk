#requires AutoHotkey v2.0

HasValue(haystack, val) {
	for index, value in haystack
		if (value = val)
			return index
	if !IsObject(haystack)
		; throw Exception("Bad haystack!", -1, haystack) ; ahk v1
		throw ValueError("haystack id not an object", -1, haystack) ; ahk v2
	return 0
}