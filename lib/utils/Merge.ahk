; Merges properties from override object into base object
#requires AutoHotkey v2.0

merge(base, override) {
    for key, value in override.OwnProps() {
        base.%key% := value
    }
    return base
}
