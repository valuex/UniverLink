; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=46571
GetAdobeReaderFilePath()
{
    WinGet, vPID, PID, ahk_class AcrobatSDIWindow
    oWMI := ComObjGet("winmgmts:")
    oQueryEnum := oWMI.ExecQuery("Select * from Win32_Process where ProcessId=" vPID)._NewEnum()
    if oQueryEnum[oProcess]
        vCmdLn := oProcess.CommandLine
    oWMI := oQueryEnum := oProcess := ""
    return,vCmdLn
}
