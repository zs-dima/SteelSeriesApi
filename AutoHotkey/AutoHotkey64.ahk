#Requires AutoHotkey v2.0
#Warn
#SingleInstance

InstallKeybdHook
InstallKeybdHook
ProcessSetPriority "R"
A_HotkeyInterval := 2000 ; This is the default value (milliseconds).
A_MaxHotkeysPerInterval := 200

SetTitleMatchMode 2


CapsLock:: {
    Send '{LWin Down}{Space Down}{Space Up}{LWin Up}'
    KeyboardLanguageColor()
}

Pause::SwitchKeysLocale() ; Break

KeyboardLanguageColor() {
    if !LangID := GetKeyboardLanguage(WinActive("A"))
    {
        MsgBox "GetKeyboardLayout function failed"
        return
    }
    if (LangID = 0x0409) {
        SetLngColor(false)
    }
    else if (LangID = 0x419) {
        SetLngColor(true)
    }
    return
}

SetLngColor(en) {
    if (en) {
        SetKeyColor(44, 0, 0, 0)
    }
    else {
        SetKeyColor(44, 0, 255, 255)
    }
}

SetKeyColor(key, red, green, blue) {
    url := "http://localhost:15137/api/steelseries/key_color"

    body := ' { "key": ' . key . ', "red": ' . red . ', "green": ' . green . ', "blue": ' . blue . ' } '

    xhr := ComObject("WinHttp.WinHttpRequest.5.1")
    xhr.Open("POST", url, false)

    xhr.SetRequestHeader("Content-Type", "application/json")
    xhr.Send(body)

    if (xhr.Status != 200) {
        MsgBox("Error: " . xhr.StatusText)
    }
}

GetKeyboardLanguage(_hWnd := 0)
{
    if !_hWnd
        ThreadId:=0
    else
        if !ThreadId := DllCall("user32.dll\GetWindowThreadProcessId", "Ptr", _hWnd, "UInt", 0, "UInt")
            return false

    if !KBLayout := DllCall("user32.dll\GetKeyboardLayout", "UInt", ThreadId, "UInt")
        return false

    return KBLayout & 0xFFFF
}

SwitchKeysLocale()
{
    Layout := ""
    TempClipboard := ""
    SelText := GetWord(&TempClipboard)
    A_Clipboard := ConvertText(SelText, &Layout)
    Send '+{Ins}' ; ("^{vk56}") ; Ctrl + V
    Sleep(50)
    SwitchLocale(Layout)
    Sleep(50)
    ;Send '{Ctrl up}'
    A_Clipboard := TempClipboard
    SetLngColor(Layout = "Lat")
}

GetWord(&TempClipboard)
{
    ; REMOVED:    SetBatchLines, -1
    SetKeyDelay(0)
    TempClipboard := ClipboardAll()
    A_Clipboard := ""
    SendInput("^{vk43}")
    Sleep(100)
    if (A_Clipboard != "")
        Return A_Clipboard
    While A_Index < 10
    {
        SendInput("^+{Left}^{vk43}")
        Errorlevel := !ClipWait(1)
        if ErrorLevel
            Return
        if RegExMatch(A_Clipboard, "([ \t])", &Found) && A_Index != 1
        {
            SendInput("^+{Right}")
            Return SubStr(A_Clipboard, (Found.Pos[1] + 1)<1 ? (Found.Pos[1] + 1)-1 : (Found.Pos[1] + 1))
        }
        PrevClipboard := A_Clipboard
        A_Clipboard := ""
        SendInput("+{Left}^{vk43}")
        Errorlevel := !ClipWait(1)
        if ErrorLevel
            Return
        if (StrLen(A_Clipboard) = StrLen(PrevClipboard))
        {
            A_Clipboard := ""
            SendInput("+{Left}^{vk43}")
            Errorlevel := !ClipWait(1)
            if ErrorLevel
                Return
            if (StrLen(A_Clipboard) = StrLen(PrevClipboard))
                Return A_Clipboard
            Else
            {
                SendInput("+{Right 2}")
                Return PrevClipboard
            }
        }
        SendInput("+{Right}")
        s := SubStr(A_Clipboard, 1, 1)
        if (s ~= "^(?i:" RegExReplace(RegExReplace(A_Space "," A_Tab ",`n,`r","[\\\.\*\?\+\[\{\|\(\)\^\$]","\$0"),"\s*,\s*","|") ")$")
        {
            A_Clipboard := ""
            SendInput("+{Left}^{vk43}")
            Errorlevel := !ClipWait(1)
            if ErrorLevel
                Return
            Return A_Clipboard
        }
        A_Clipboard := ""
    }
}

ConvertText(Text, &OppositeLayout)
{
    Static Cyr := "ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ/ёйцукенгшщзхъфывапролджэячсмитьбю,.`"№;?"
    Static Lat := "~QWERTYUIOP{}ASDFGHJKL:`"ZXCVBNM<>|``qwertyuiop[]asdfghjkl;'zxcvbnm,.?/@#$&"
    RegExReplace(Text, "i)[A-Z@#\$\^&\[\]'`\{}]", "", &LatCount)
    RegExReplace(Text, "i)[А-ЯЁ№]", "", &CyrCount)
    if (LatCount != CyrCount) {
        CurrentLayout := LatCount > CyrCount ? "Lat" : "Cyr"
        OppositeLayout := LatCount > CyrCount ? "Cyr" : "Lat"
    }
    else {
        threadId := DllCall("GetWindowThreadProcessId", "Ptr", WinExist("A"), "UInt", 0, "Ptr")
        landId := DllCall("GetKeyboardLayout", "Ptr", threadId, "Ptr") & 0xFFFF
        if (landId = 0x409)
            CurrentLayout := "Lat", OppositeLayout := "Cyr"
        else
            CurrentLayout := "Cyr", OppositeLayout := "Lat"
    }
    Loop Parse, Text
        NewText .= (found := InStr(%CurrentLayout%, A_LoopField, 1))
            ? SubStr(%OppositeLayout%, found, 1) : A_LoopField
    Return NewText
}

SwitchLocale(Layout)
{
    ;CtrlFocus := ControlGetClassNN(ControlGetFocus("A"))
    PostMessage(WM_INPUTLANGCHANGEREQUEST := 0x0050, 0, Layout = "Lat" ? 0x4090409 : 0x4190419, , "A") ; %CtrlFocus%
}
