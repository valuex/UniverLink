# UniverLink
**Function** get active file full path or web browser's url or file explorer's current directory  
# Support List
- **Office**
  - Word: get by COM
  - Excel: get by COM
  - PowerPoint: get by COM
- **PDF Reader**
  - Adobe Reader: get by winmgmts
  - Foxit Reader: get by Everything.dll or get the open file list and match title with file name.
- **Text Editor**
  - Notepad: get by winmgmts
  - Visual Studio Code: get from window title, full path should be set on windwow title.
- **File Manager**
  - Windows Explorer: Looping window, and match Hwnd
- **Web Brower**
  - Mordern: Chrome
  - Legacy: IE, Opera
