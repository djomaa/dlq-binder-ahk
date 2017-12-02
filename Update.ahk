var := "it's reworking now"
Class Update {
	Class Gui {
		Create(Current,Last) {
			Gui, Update: New, -SysMenu, Обновление
			Gui, Color, White, White
			Gui, Add, Text,, % "Данная версия программы устарела.`n`nВаша версия: " Current "`nПоследняя версия: " Last "`n"
			Gui, Add, Button,gUpdate.Install Default, Обновить
			Gui, Add, Button,yp x+%wp%+1 gUpdate.GUI.ChangeLog, Список изменений
			Gui, Add, Button,yp x+%wp%+1 gUpdate.GUI.Exit, Выход
			Gui, Show
			exit
		}
		Exit() {
			ExitApp
		}
		ChangeLog() {
			Gui, Update_ChangeLog: New
			Gui, +ToolWindow +OwnerUpdate
			Gui, Add, Edit, +ReadOnly x-2 y-2 w304 h304,% Tools.Request("http://mozg.zzz.com.ua/Demy/DLQ%20Binder/Updating/ChangeLog.txt")
			Gui, Show, w300 h300, Список изменений
			Gui, Update: Default
		}
	}
	Install() {
			Gui, Update: Destroy
			url := "http://mozg.zzz.com.ua/Demy/DLQ%20Binder/Updating/update"
			URLDownloadToFile,% url,% A_ScriptDir "\update"
			PID :=  DllCall("GetCurrentProcessId"), BatchPath := Settings.Folder "\updater.bat"
			Run, %BatchPath% "%A_ScriptName%" "%PID%",% A_ScriptDir, Hide
			ExitApp
	}
	Check() {
		lastVersion := JSON.Load(Tools.Request("http://mozg.zzz.com.ua/Demy/DLQ%20Binder/Information.txt"))["version"]
		If ( Settings.Version < lastVersion ) {
			Update.Gui.Create(Settings.Version, lastVersion)
		}
	}
}