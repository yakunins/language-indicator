#include constLocale.ahk

global bytes⁄char := 2

class Lyt { ; some methods from autohotkey.com/boards/viewtopic.php?f=6&t=28258
  static INPUTLANGCHANGE_FORWARD	:= 0x0002
   , INPUTLANGCHANGE_BACKWARD   	:= 0x0004
   , KLIDsREG_PATH              	:= "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layouts\"
  ; —————————— Locale Functions ——————————
  static locInf := localeInfo.m  ; Constants Used in the LCType Parameter of GetLocaleInfo, GetLocaleInfoEx, and SetLocaleInfo
  static getLocaleInfo(infoLCTs, LocaleID) { ; get info about a locale specified by ID
    ;infoLCT 	LCTYPE	locale information to retrieve, LCType @ learn.microsoft.com/en-us/windows/desktop/api/winnls/nf-winnls-getlocaleinfoex
    ;LocaleID	LCID  	learn.microsoft.com/en-us/windows/desktop/Intl/locale-identifiers
    ;→ found value or empty string on error
    static retNumber := 0x20000000   ; return number instead of string
    if (infoLCT := this.locInf.Get(infoLCTs,"")) = "" {
      throw ValueError("1st argument ‘infoLCTs’ doesn't match any known locate types",-1,infoLCT)
    }
    if LocaleID = "" {
      throw ValueError("2nd argument ‘LocaleID’ is empty" ,-1,LocaleID)
    }
    if (SubStr(infoLCTs,1,1) =        "I") or
       (SubStr(infoLCTs,1,8) = "LOCALE_I") {
      outVar := 0
      DllCall("GetLocaleInfo", "uint",LocaleID, "uint",infoLCT | retNumber, "uint*",&outVar, "int",4 // bytes⁄char)
      return outVar
    } else {
      ;↓ need to call twice, 1st to get variable size, 2nd time to fill the variable of the proper size
      charCount	:= DllCall("GetLocaleInfo", "uint",LocaleID, "uint",infoLCT , "str","", "int",0) ; cchData=0 → get buffer size
      VarSetStrCapacity(&outVar, charCount * bytes⁄char)
      DllCall("GetLocaleInfo", "uint",LocaleID, "uint",infoLCT ;→aint learn.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-getlocaleinfow
        , "str",outVar   	;→ opt LPWSTR	lpLCData	pointer to a buffer in which this function retrieves the requested locale information. This pointer is not used if cchData is set to 0
        ,"uint",charCount	;int         	cchData 	Size, in TCHAR values, of the data buffer indicated by lpLCData. 0: not use the lpLCData parameter and returns the required buffer size, including the terminating null character
        )
      return outVar
    }
  }
}

