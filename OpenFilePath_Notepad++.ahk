GetNotePadPPFilePath()
{
PostMessage, 0x111, 11001,,, A ;WM_COMMAND := 0x111 ;Windows...
WinWaitActive, Windows ahk_class #32770
hWnd2 := WinExist()
ControlGet, vText, List,, SysListView321, % "ahk_id " hWnd2
WinClose, % "ahk_id " hWnd2
vOutput := ""
Loop, Parse, vText, `n, `r
{
	oTemp := StrSplit(A_LoopField, "`t")
	vOutput .= oTemp.2 "\" oTemp.1 "`r`n"
}
Return, vOutput
}
