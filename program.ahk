;working dir
if ( !FileExist( A_MyDocuments "\DLQ Binder" ) )
  FileCreateDir,% A_MyDocuments "\DLQ Binder"
SetWorkingDir,% A_MyDocuments "\DLQ Binder"

;ready includes
#include lib\ready\json.ahk

;includes
#include lib\mainWindow.ahk
#include lib\profileSystem.ahk
#include lib\editingSystem.ahk

;vars
global version := "4.0"
global options := json.read("options.json")
global data := [{"name":"theFirst","hotkey":"vk27"},{"name":"theThird","hotkey":"<!vk48"}]
global profile := options["profile"]

;test area TODO DELETE
profiles._refreshList()
;code

mainWin.show()
;TODO DELETE
F1::reload

;TO DO LIST
;TODO
; 1) getKeyName func for key+modifier
