/*
;;;; AHK v2 - https://github.com/TheArkive/JXON_ahk2
;MIT License
;Copyright (c) 2021 TheArkive
;Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
;The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
;THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;
; Example ===================================================================================
; ===========================================================================================

Serialize

var := Jsons.Dump(obj, indent:=0)

Convert to obj

obj := Jsons.Load(&text)

; ===========================================================================================
; End Example ; =============================================================================
; ===========================================================================================

; originally posted by user coco on AutoHotkey.com
; https://github.com/cocobelgica/AutoHotkey-JSON
*/
class Jsons {

    static Load(&src, args*) {
        key := "", is_key := false
        stack := [tree := []]
        next := '"{[01234567890-tfn'
        pos := 0

        while ((ch := SubStr(src, ++pos, 1)) != "") {
            if InStr(" `t`n`r", ch)
                continue
            if !InStr(next, ch, true) {
                testArr := StrSplit(SubStr(src, 1, pos), "`n")

                ln := testArr.Length
                col := pos - InStr(src, "`n", , -(StrLen(src) - pos + 1))

                msg := Format("{}: line {} col {} (char {})"
                    , (next == "") ? ["Extra data", ch := SubStr(src, pos)][1]
                    : (next == "'") ? "Unterminated string starting at"
                        : (next == "\") ? "Invalid \escape"
                            : (next == ":") ? "Expecting ':' delimiter"
                                : (next == '"') ? "Expecting object key enclosed in double quotes"
                                    : (next == '"}') ? "Expecting object key enclosed in double quotes or object closing '}'"
                                        : (next == ",}") ? "Expecting ',' delimiter or object closing '}'"
                                            : (next == ",]") ? "Expecting ',' delimiter or array closing ']'"
                                                : ["Expecting JSON value(string, number, [true, false, null], object or array)"
                                                , ch := SubStr(src, pos, (SubStr(src, pos) ~= "[\]\},\s]|$") - 1)][1]
                                                , ln, col, pos)

                throw Error(msg, -1, ch)
            }

            obj := stack[1]
            is_array := (obj is Array)

            if i := InStr("{[", ch) { ; start new object / map?
                val := (i = 1) ? Map() : Array()	; ahk v2

                is_array ? obj.Push(val) : obj[key] := val
                stack.InsertAt(1, val)

                next := '"' ((is_key := (ch == "{")) ? "}" : "{[]0123456789-tfn")
            } else if InStr("}]", ch) {
                stack.RemoveAt(1)
                next := (stack[1] == tree) ? "" : (stack[1] is Array) ? ",]" : ",}"
            } else if InStr(",:", ch) {
                is_key := (!is_array && ch == ",")
                next := is_key ? '"' : '"{[0123456789-tfn'
            } else { ; string | number | true | false | null
                if (ch == '"') { ; string
                    i := pos
                    while i := InStr(src, '"', , i + 1) {
                        val := StrReplace(SubStr(src, pos + 1, i - pos - 1), "\\", "\u005C")
                        if (SubStr(val, -1) != "\")
                            break
                    }
                    if !i ? (pos--, next := "'") : 0
                        continue

                    pos := i ; update pos

                    val := StrReplace(val, "\/", "/")
                    val := StrReplace(val, '\"', '"')
                        , val := StrReplace(val, "\b", "`b")
                        , val := StrReplace(val, "\f", "`f")
                        , val := StrReplace(val, "\n", "`n")
                        , val := StrReplace(val, "\r", "`r")
                        , val := StrReplace(val, "\t", "`t")

                    i := 0
                    while i := InStr(val, "\", , i + 1) {
                        if (SubStr(val, i + 1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
                            continue 2

                        xxxx := Abs("0x" . SubStr(val, i + 2, 4)) ; \uXXXX - JSON unicode escape sequence
                        if (xxxx < 0x100)
                            val := SubStr(val, 1, i - 1) . Chr(xxxx) . SubStr(val, i + 6)
                    }

                    if is_key {
                        key := val, next := ":"
                        continue
                    }
                } else { ; number | true | false | null
                    val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$", , pos) - pos)

                    if IsInteger(val)
                        val += 0
                    else if IsFloat(val)
                        val += 0
                    else if (val == "true" || val == "false")
                        val := (val == "true")
                    else if (val == "null")
                        val := ""
                    else if is_key {
                        pos--, next := "#"
                        continue
                    }

                    pos += i - 1
                }

                is_array ? obj.Push(val) : obj[key] := val
                next := obj == tree ? "" : is_array ? ",]" : ",}"
            }
        }

        return tree[1]
    }
    static Dump(obj, indent := "", lvl := 1) {
        if IsObject(obj) {
            if obj.__Class = "Object" {
                obj := Jsons.ConvertObjectToMap(obj)
            } else if not (obj is Array || obj is Map || obj is String || obj is Number) && obj.__Class != "BoundaryFunc"  {
                obj := Jsons.ConvertObjectToMap(obj)
            }
            If !(obj is Array || obj is Map || obj is String || obj is Number)
                throw Error("Object type not supported.", -1, Format("<Object at 0x{:p}>", ObjPtr(obj)))

            if IsInteger(indent)
            {
                if (indent < 0)
                    throw Error("Indent parameter must be a postive integer.", -1, indent)
                spaces := indent, indent := ""

                Loop spaces ; ===> changed
                    indent .= " "
            }
            indt := ""

            Loop indent ? lvl : 0
                indt .= indent

            is_array := (obj is Array)

            lvl += 1, out := "" ; Make #Warn happy
            for k, v in obj {
                ; if IsObject(k) || (k == "")
                    ;  throw Error("Invalid object key.", -1, k ? Format("<Object at 0x{:p}>", ObjPtr(obj)) : "<blank>")

                if !is_array  ;// key ; ObjGetCapacity([k], 1)
                    out .= (ObjGetCapacity([k]) ? Jsons.Dump(k) : escape_str(k)) (indent ? ": " : ":") ; token + padding

                out .= Jsons.Dump(v, indent, lvl) ; value
                    . (indent ? ",`n" . indt : ",") ; token + indent
            }

            if (out != "") {
                out := Trim(out, ",`n" . indent)
                if (indent != "")
                    out := "`n" . indt . out . "`n" . SubStr(indt, StrLen(indent) + 1)
            }

            return is_array ? "[" . out . "]" : "{" . out . "}"

        } Else If (obj is Number)
            return obj
        Else ; String
            return escape_str(obj)

        escape_str(obj) {
            obj := StrReplace(obj, "\", "\\")
            obj := StrReplace(obj, "`t", "\t")
            obj := StrReplace(obj, "`r", "\r")
            obj := StrReplace(obj, "`n", "\n")
            obj := StrReplace(obj, "`b", "\b")
            obj := StrReplace(obj, "`f", "\f")
            obj := StrReplace(obj, "/", "\/")
            obj := StrReplace(obj, '"', '\"')

            return '"' obj '"'
        }
    }
    static ConvertObjectToMap(InputObject) {
        if IsObject(InputObject) {
            if InputObject.__Class = "Map" {
                return InputObject
            }
            else {
                return Jsons.convertObj(InputObject)
            }
        }
        else {
            return InputObject
        }
    }
    static convertObj(obj) {
        convertedObject := Map()
        for k, v in obj.OwnProps() {
            if v.base.__Class != "BoundFunc" {
            convertedObject.Set(k, v)
        }
        }
        return convertedObject
    }
}
