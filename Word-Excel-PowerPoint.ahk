#Include, GetActiveURL_Browsers.ahk
#Include, OpenFilePath_FoxitReader.ahk
#1::
ModernBrowsers := "ApplicationFrameWindow,Chrome_WidgetWin_0,Chrome_WidgetWin_1,Maxthon3Cls_MainFrm,MozillaWindowClass,Slimjet_WidgetWin_1"
LegacyBrowsers := "IEFrame,OperaWindowClass"
WinGetClass, sClass, A

;https://www.autohotkey.com/boards/viewtopic.php?t=6561
If WinActive("ahk_exe WINWORD.EXE")	
	ActiveFileFullName:=ComObjActive("Word.Application").ActiveDocument.FullName
Else If WinActive("ahk_exe EXCEL.EXE")	
	ActiveFileFullName:= ComObjActive("Excel.Application").ActiveWorkbook.FullName
Else If WinActive("ahk_exe POWERPNT.EXE")
    ActiveFileFullName:=ComObjActive("PowerPoint.Application").ActivePresentation.FullName
Else If WinActive("ahk_class CabinetWClass")
{
	ActiveFileFullName:=GetActiveExplorerPath()
}
Else If WinActive("ahk_exe notepad.exe")
{
    ActiveFileFullName:=GetActiveFilePath_NotePad()	
}
Else If WinActive("ahk_exe FOXITREADER.EXE")
{
    ActiveFileFullName:=GetActiveFilePath_FoxitReader()	
}
Else If WinActive("ahk_exe Code.exe") ; Visual Studio Code
    ActiveFileFullName:=GetActiveFilePath_VisualStudioCode()
Else If sClass In % ModernBrowsers
	ActiveFileFullName:= GetBrowserURL_ACC(sClass)
Else If sClass In % LegacyBrowsers
	ActiveFileFullName:= GetBrowserURL_DDE(sClass)

MsgBox %ActiveFileFullName%
return


GetActiveFilePath_NotePad()
{
    WinGet pid, PID, A
	wmi := ComObjGet("winmgmts:")
	queryEnum := wmi.ExecQuery(""
	. "Select * from Win32_Process where ProcessId=" . pid)
	._NewEnum()
	if queryEnum[process]
	{		
        ActiveFileFullName:= StrSplit(process.CommandLine, """").3  ;"C:\Windows\system32\NOTEPAD.EXE" TextFileName.txt
	}
	else
		ActiveFileFullName:=False
	wmi := queryEnum := process := ""
    Return, ActiveFileFullName
}

GetActiveExplorerPath() {
    explorerHwnd := WinActive("ahk_class CabinetWClass")
    if (explorerHwnd)
    {
        for window in ComObjCreate("Shell.Application").Windows
        {
            if (window.hwnd==explorerHwnd)
                return window.Document.Folder.Self.Path
        }
    }
}
GetActiveFilePath_VisualStudioCode(){
    ; need to set full path to be displayed on window title
    ; https://www.autohotkey.com/boards/viewtopic.php?style=7&f=76&t=82544
    WinGetTitle, filepath, ahk_exe Code.exe
    RegExMatch(filepath, Chr(9679) . "? ?\K.*(?= - Visual Studio Code)", ActiveFileFullName)
    Return, ActiveFileFullName
}
F11::Reload

