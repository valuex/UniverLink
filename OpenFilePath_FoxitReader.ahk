GetActiveFilePath_FoxitReader()
{
WinGet, APID , PID, A
WinGet, AProcessName , ProcessName, A
if(InStr(AProcessName, "foixtreader.exe")>=0)
{ 
    WinTitleFileName:=GetFileNameFromWinTitleByLastHyphen()
    EverythingResults:=SearchTheOnlyOneWithEverything(WinTitleFileName)
    if EverythingResults
        OpenFileFullPath:=EverythingResults
    Else
        OpenFileFullPath:=GetOpenedPDFFile(APID)
}
Return, OpenFileFullPath
}

SearchTheOnlyOneWithEverything(KeyWords)
{
    KeyWords:= KeyWords . " !.lnk" ; exclude shortcut file
    resultlist = ; initialization not needed, just for clarity
    EverythingDll := "Everything" . (A_PtrSize == 8 ? "64" : "32") . ".dll"
    EverythingMod := DllCall("LoadLibrary", "Str", A_ScriptDir . "\" . EverythingDll, "Ptr")
    DllCall(EverythingDll . "\Everything_SetSearch", "Str", KeyWords) ; changed to searchvar "eingabe"
    DllCall(EverythingDll . "\Everything_Query", "Int", True)

    QueryItemNum:=DllCall(EverythingDll . "\Everything_GetNumResults", "UInt")
    MsgBox %QueryItemNum%
    If (QueryItemNum=1)
        {
            ;FolderPath:= DllCall(EverythingDll . "\Everything_GetResultFileName", "UInt", 0, "Str") 
            ;DllCall(EverythingDll .  "\Everything_GetResultFullPathName","UInt",0,"Str",bValue,"UInt",128)
            VarSetCapacity(FileFullName,128*2)
            a:=DllCall(EverythingDll . "\Everything_GetResultFullPathName", "UInt", 0, "Str",FileFullName,"UInt",128,"UInt") 
            
            resultlist:=FileFullName ;FolderPath . "\" . FileName
        }
    Else
        resultlist:= False

    DllCall(EverythingDll . "\Everything_Reset")
    DllCall("FreeLibrary", "Ptr", EverythingMod)

    Return, resultlist ; gives hit list, in the form delivered by your script (will try to adapt to my specific needs)
    ; or then, return, resultlist in order to process it further
} 


GetFileNameFromWinTitleByLastHyphen()
{
    WinGetActiveTitle, ATitle
    LastHphenPos := InStr(ATitle, "-" ,false,-1)-1
    OpenedFileName:=Trim(SubStr(ATitle, 1,LastHphenPos))
    Return,OpenedFileName
}
GetOpenedPDFFile(APID)
{
    OpenedFileName:=GetFileNameFromWinTitleByLastHyphen()
    ;MsgBox 2-%LastHphenPos%-%OpenedFileName%
    OpenFileFullPath:=GetOpenedFiles(APID)
    LinesArray := StrSplit(OpenFileFullPath, "`n")
    Loop % LinesArray.MaxIndex()
    {
        StrLine:=LinesArray[A_Index]
        ;MsgBox %StrLine%
        Ext:=SubStr(StrLine, -4)
        If(InStr(Ext, ".pdf"))
        {
            LastSlashPos := InStr(StrLine, "\" ,false,-1)+1
            LoopFileName:= SubStr(StrLine, LastSlashPos)
            FoundPos := InStr(LoopFileName, OpenedFileName, false, 1)
            if(FoundPos)
                Return, StrLine         
        } 
    }
    Return, 0
}
GetOpenedFiles(PID) {
   static PROCESS_DUP_HANDLE := 0x0040, SystemExtendedHandleInformation := 0x40, DUPLICATE_SAME_ACCESS := 0x2
        , structSize := A_PtrSize*3 + 16 ; size of SYSTEM_HANDLE_TABLE_ENTRY_INFO_EX
   hProcess := DllCall("OpenProcess", "UInt", PROCESS_DUP_HANDLE, "UInt", 0, "UInt", PID)
   arr := {}
   res := size := 1
   while res != 0 {
      VarSetCapacity(buff, size, 0) ; get SYSTEM_HANDLE_INFORMATION_EX and SYSTEM_HANDLE_TABLE_ENTRY_INFO_EX
                                    ; https://www.geoffchappell.com/studies/windows/km/ntoskrnl/api/ex/sysinfo/handle_ex.htm
                                    ; https://www.geoffchappell.com/studies/windows/km/ntoskrnl/api/ex/sysinfo/handle_table_entry_ex.htm
      res := DllCall("ntdll\NtQuerySystemInformation", "Int", SystemExtendedHandleInformation, "Ptr", &buff, "UInt", size, "UIntP", size, "UInt")
   }
   NumberOfHandles := NumGet(buff) ; get all opened handles count from SYSTEM_HANDLE_INFORMATION_EX
   VarSetCapacity(filePath, 512)
   Loop % NumberOfHandles {
      ; get UniqueProcessId from SYSTEM_HANDLE_TABLE_ENTRY_INFO_EX
      ProcessId := NumGet(buff, A_PtrSize*2 + structSize*(A_Index - 1) + A_PtrSize, "UInt")
      if (PID = ProcessId) {
         ; get HandleValue from SYSTEM_HANDLE_TABLE_ENTRY_INFO_EX
         HandleValue := NumGet(buff, A_PtrSize*2 + structSize*(A_Index - 1) + A_PtrSize*2)
         DllCall("DuplicateHandle", "Ptr", hProcess, "Ptr", HandleValue, "Ptr", DllCall("GetCurrentProcess")
                                  , "PtrP", lpTargetHandle, "UInt", 0, "UInt", 0, "UInt", DUPLICATE_SAME_ACCESS)
         ; get the file name from the duplicated handle
         if DllCall("GetFinalPathNameByHandle", "Ptr", lpTargetHandle, "Str", filePath, "UInt", 512, "UInt", 0)
            arr[ RegExReplace(filePath, "^\\\\\?\\") ] := ""
         DllCall("CloseHandle", "Ptr", lpTargetHandle)
      }
   }
   DllCall("CloseHandle", "Ptr", hProcess)
   for k in arr
      str .= (str = "" ? "" : "`n") . k
   Sort, str
   Return str
}