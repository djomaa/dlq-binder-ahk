Class Profiles {
	Static Folder := Settings.Folder "Profiles\"
	Activate() {
		Loop % 60
			If ( Data[A_Index]["Hotkey"] )
				Hotkey, If, WinActive("GTA:SA:MP")
				Hotkey, Data[A_Index]["Hotkey"]
	}
	Change() {
		GuiControlGet, NewProfile,,% HWNDs["Main"]["Profiles"]
		If ( NewProfile != Settings.Profile ) {
			Settings.Profile := NewProfile,	Profiles.Load()
			msgbox % "1: " Settings.Profile
		}
	}
	List() {
		GuiControl, -Redraw,% HWNDs["Main"]["Profiles"]
		GuiControl,,% HWNDs["Main"]["Profiles"],|
		Loop,% Settings.Folder "Profiles\*.dlqb"
			GuiControl,,% HWNDs["Main"]["Profiles"],% SubStr(A_LoopFileName,1,StrLen(A_LoopFileName)-5)
		If ( Settings.Profile )
			GuiControl, ChooseString,% HWNDs["Main"]["Profiles"],% Settings.Profile
		GuiControl, +Redraw,% HWNDs["Main"]["Profiles"]
	}
	RefreshData() {
		Loop 60 {
			GuiControl,,% HWNDs["Main"]["Hotkey" A_Index],% HKC.getName(Data[A_Index]["Hotkey"])
			GuiControl,,% HWNDs["Main"]["Name" A_Index],% Data[A_Index]["Name"]		
		}
	}
	Load() {
		IsLoadable := True
		If ( Settings.Profile != "" ) {
			FileRead, Profile,% Profiles.Folder Settings.Profile ".dlqb"
			NewData := JSON.Load(Tools.Crypt.Decode(Profile))
			If ( NewData ) {
				Data := NewData
				IniWrite,% Settings.Profile,% Settings.OptionsFile,% "Main",% "profile"
				Profiles.RefreshData(), Programm.GUI.Enable(), Profiles._activate()
			} else IsLoadable := False
		} else Programm.GUI.Disable()
		If ( !IsLoadable ) {
			IniWrite,% "",% Settings.OptionsFile,% "Main",% "profile"
			Profile := Settings.Profile, Settings.Profile := "", Data := {}
			Profiles.List(), Profiles.RefreshData(), Programm.GUI.Disable()
			MsgBox, 48, Ошибка,% "Профиль '" Profile "' поврежден или удален.`nЗагрузка данных невозможна.`nСоздайте или выберите другой профиль."
			}
	}	
	_activate() {
		Static oldHotkeys := []
		Hotkey, If, WinActive("GTA:SA:MP")
		Loop % oldHotkeys.length()
			Hotkey, % oldHotKeys[A_Index], Off
		Function := ObjBindMethod(Execute,"Do"), oldHotkeys.Pop()
		Loop 60
			If ( Data[A_Index]["Hotkey"]  ) {
				Hotkey,% Data[A_Index]["Hotkey"],% Function, On
				oldHotkeys.Push(Data[A_Index]["Hotkey"])
			}
		Hotkey, If
	}
	Save() {
		Tools.BlockToggle("Main","Block"), Tools.Msg.Create("Сохранение...","Main")
		File := FileOpen(Profiles.Folder Settings.Profile ".dlqb","w")
		File.Write(Tools.Crypt.Encode(JSON.Dump(Data)))
		If ( ErrorLevel )
			MsgBox, 48, Ошибка,% "При сохранении возникла непредвиденная ошибка.`nПрофиль '" Settings.Profile "' не сохранен."
		sleep 1000
		Profiles._activate()
		Tools.BlockToggle("Main","Block"), Tools.Msg.Destroy("Сохранение...","Main")
	}
}