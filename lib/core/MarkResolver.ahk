; Resolves indicator mark names and file paths based on locale and capslock state
#requires AutoHotkey v2.0

class MarkResolver {
    ; Get mark name based on locale and capslock state
    ; Returns empty string for default state (locale=1, capslock=0)
    static GetMarkName(locale, capslock) {
        if (locale == 1 and capslock == 0)
            return ""

        ; see UseBase64Image.ahk for available embedded images
        figures := Map("0", "circle", "1", "arrow")
        colors := Map("1", "white", "2", "red", "3", "green", "4", "blue")
        sizes := ["9px", "12px"]

        figure := figures.Get("" . capslock, "undefined")
        color := colors.Get("" . locale, "undefined")
        size := sizes[2]

        return figure "_" color "_" size
    }

    ; Get mark file path from file system based on configuration
    ; filesCfg must have: folder, extensions, capslockSuffix
    static GetMarkFile(filesCfg, locale, capslock) {
        for ext in filesCfg.extensions {
            if capslock {
                path := filesCfg.folder . locale . filesCfg.capslockSuffix . ext
                if FileExist(path)
                    return path
            }
            path := filesCfg.folder . locale . ext
            if FileExist(path)
                return path
        }
        return ""
    }
}
