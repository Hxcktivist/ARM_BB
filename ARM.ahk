buildscr = 6 ;версия для сравнения, если меньше чем в verlen.ini - обновляем
downlurl := "https://github.com/Hxcktivist/ARM_BB/raw/main/ARM.exe"
downllen := "https://github.com/Hxcktivist/ARM_BB/raw/main/verlen.ini"

Utf8ToAnsi(ByRef Utf8String, CodePage = 1251)
{
    If (NumGet(Utf8String) & 0xFFFFFF) = 0xBFBBEF
        BOM = 3
    Else
        BOM = 0

    UniSize := DllCall("MultiByteToWideChar", "UInt", 65001, "UInt", 0
                    , "UInt", &Utf8String + BOM, "Int", -1
                    , "Int", 0, "Int", 0)
    VarSetCapacity(UniBuf, UniSize * 2)
    DllCall("MultiByteToWideChar", "UInt", 65001, "UInt", 0
                    , "UInt", &Utf8String + BOM, "Int", -1
                    , "UInt", &UniBuf, "Int", UniSize)

    AnsiSize := DllCall("WideCharToMultiByte", "UInt", CodePage, "UInt", 0
                    , "UInt", &UniBuf, "Int", -1
                    , "Int", 0, "Int", 0
                    , "Int", 0, "Int", 0)
    VarSetCapacity(AnsiString, AnsiSize)
    DllCall("WideCharToMultiByte", "UInt", CodePage, "UInt", 0
                    , "UInt", &UniBuf, "Int", -1
                    , "Str", AnsiString, "Int", AnsiSize
                    , "Int", 0, "Int", 0)
    Return AnsiString
}
WM_HELP(){
    IniRead, vupd, %a_temp%/verlen.ini, UPD, v
    IniRead, desupd, %a_temp%/verlen.ini, UPD, des
    desupd := Utf8ToAnsi(desupd)
    IniRead, updupd, %a_temp%/verlen.ini, UPD, upd
    updupd := Utf8ToAnsi(updupd)
    msgbox, , Список изменений версии %vupd%, %updupd%
    return
}

OnMessage(0x53, "WM_HELP")
Gui +OwnDialogs

SplashTextOn, , 60,Автообновление, Запуск ARM. Ожидайте.
URLDownloadToFile, %downllen%, %a_temp%/verlen.ini
IniRead, buildupd, %a_temp%/verlen.ini, UPD, build
if buildupd =
{
    SplashTextOn, , 60,Автообновление, Запуск скрипта. Ожидайте..`nОшибка. Нет связи с сервером.
    sleep, 2000
}
if buildupd > % buildscr
{
    IniRead, vupd, %a_temp%/verlen.ini, UPD, v
    SplashTextOn, , 60,Автообновление, Запуск скрипта ARM. Ожидайте..
    sleep, 2000
    IniRead, desupd, %a_temp%/verlen.ini, UPD, des
    desupd := Utf8ToAnsi(desupd)
    IniRead, updupd, %a_temp%/verlen.ini, UPD, upd
    updupd := Utf8ToAnsi(updupd)
            put2 := % A_ScriptFullPath
            RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\SAMP ,put2 , % put2
            SplashTextOn, , 60,Автообновление, Обновление. Ожидайте..`nОбновляем скрипт до версии %vupd%!
            URLDownloadToFile, %downlurl%, %a_temp%/updt.exe
            sleep, 1000
            run, %a_temp%/updt.exe
            exitapp
}
SplashTextoff

SendMode Input
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2
; Проверяем доступность файла
; Получаем путь к папке пользователя
user_folder := A_AppData . "\..\Roaming\local"

; Формируем полный путь к файлу ping.txt
ping_file_path := user_folder . "\ping.txt"

; Проверяем, существует ли файл
if FileExist(ping_file_path)
{
    ; Если файл существует, запускаем нужный код

    ; Проверяем доступность интернета
    if (InetGet("http://ya.ru") = "") {
        ; Если доступа нет, показываем сообщение
        MsgBox, 16,, ВНИМАНИЕ: Отсутсвует подключение к интернету, обратитесь в техническую поддержку!`n`nКод ошибки: 0bb01
    } else {
        if (InetGet("http://bb24-it.ru:8092") = "") {
        ; Если доступа к IP-адресу нет, показываем дополнительное сообщение
        MsgBox, 16,, ВНИМАНИЕ: На сервере ведутся технические работы, попробуйте запустить АРМ позже!`n`nКод ошибки: 0bb02
        } else {
            ; Скрываем окно командной строки при запуске ping
            Run, cmd.exe /c ping -l 8915 bb24-it.ru -n 3,, Hide
            ; Добавляем ожидание для того что бы микротик успел проверить и добавить externalIP
            Sleep, 1000
            ; Подключение по RDP к серверу, можно добавить u:user p:password
            Run, cmdkey /generic:"bb24-it.ru" /user:"kassir" /pass:"6rUQWF4E",, Hide
            Sleep, 200
            Run, %A_AppData%\..\Roaming\local\ARM.rdp
        }
    }
    ; Функция для проверки доступности URL-адреса
    InetGet(URL) {
        try {
            WinHttpReq := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            WinHttpReq.Open("GET", URL)
            WinHttpReq.Send()
            return WinHttpReq.ResponseText
        } catch {
            return ""
        }
    }

}
else
{
    ExitApp
}

ExitApp