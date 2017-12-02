
;!r::reload
Class Settings {
	
	Static version := "3.1"
	Static folder := A_MyDocuments "\DLQ Binder\"
	Static optionsFile := A_MyDocuments "\DLQ Binder\options.ini" 
	CheckDir() {
		FileCreateDir,% Settings.Folder
		FileCreateDir,% Profiles.Folder
		FileInstall, E:\AutoHotKey\Проекты\DLQ Binder\4\Files\true.ico,% Settings.Folder "\iconTrue.ico", 1
		FileInstall, E:\AutoHotKey\Проекты\DLQ Binder\4\Files\false.ico,% Settings.Folder "\iconFalse.ico", 1
		FileInstall, E:\AutoHotKey\Проекты\DLQ Binder\4\Files\options.ini,% Settings.OptionsFile, 0
		FileInstall, E:\AutoHotKey\Проекты\DLQ Binder\4\Files\updater.bat,% Settings.Folder "\updater.bat", 1
	}
	Load() {
		IniRead, profile,% Settings.OptionsFile,% "Main",% "profile",% ""
		IniRead, autoStart,% Settings.OptionsFile,% "Main",% "autostart",% ""
		FeedBack.GUI.TrueIcon  := LoadPicture(Settings.Folder "\iconTrue.ico")
		FeedBack.GUI.FalseIcon := LoadPicture(Settings.Folder "\iconFalse.ico")
		Settings.Profile := profile, Settings.AutoStart.Status := ( autoStart ? true : false )
	}
	Class Gui {
		Create() {
			Gui, Main: +Disabled
			Gui, Settings: New
			Gui, Color, White
			Gui, Font,, Verdana
			Gui, -SysMenu +OwnerMain
			Gui, Add, Button,x5 y5 w100 h25  gSettings.Change,  Основное
			Gui, Add, Button,wp hp xp y+%hp% gSettings.Change, Профили
			Gui, Add, Button,wp hp xp y+%hp%+45 gSettings.Exit, Назад
			Gui, Add, GroupBox, x+%wp%+5 y-10 w2 h170 Section
			Gui, Add, Text, y15 xs+20 +HWNDitem_1_1, Язык:
			Gui, Add, DropDownList, yp-4 w100 x+%wp%+5 +HWNDitem_1_2 Choose1, русский
			Gui, Font, s7
			Gui, Add, CheckBox, y+%hp%+5 xs+20 +HWNDitem_1_3 gSettings.AutoStart.Toggle, Автозапуск программы
			GuiControl,,% item_1_3,% Settings.AutoStart.Status
			Gui, Font, s8
			Gui, Add, Text, y+%hp%+10 xs+20 +HWNDitem_1_4,% "Версия: " Settings.Version "     2017`n© Demy © Calradia`n© MoZg\I_Qwerty_I"
			Gui, Add, ListBox, y15 xs+10 r7 w150 +HWNDitem_2_1
			Gui, Font, cGray s8
			Gui, Add, Text, y+%hp% xp+15 +HWNDitem_2_2,% "Правая Кнопка Мыши"
			HWNDs["Settings"] := {"MenuSystem":[[item_1_1,item_1_2,item_1_3,item_1_4],[item_2_1,item_2_2]],"autoStart":item_1_3,"profiles":item_2_1}
			Settings.File.Refresh(), OnMessage(0x204, "Settings.Menu"), Settings.Change(1)
			Gui, Show, h130 W280, Настройки
		}
		Hide() {
			While (A_Index<=HWNDs["Settings"]["MenuSystem"].Length()) {
				Index := A_Index 
				Loop % HWNDs["Settings"]["MenuSystem"][Index].Length()
					GuiControl, Hide,% HWNDs["Settings"]["MenuSystem"][Index][A_Index]
			}
		}
		Show(Index) {
			Loop % HWNDs["Settings"]["MenuSystem"][Index].Length()
				GuiControl, Show,% HWNDs["Settings"]["MenuSystem"][Index][A_Index]
		}
		Destroy() {
			Gui, Main: -Disabled
			Gui, -OwnerMain
			Gui, Destroy
			Gui, Main: Default
		}
	}
	Change(Index=0) {
		Index := Index == "Normal" ? {"Основное":1,"Профили":2,"Приложения":3}[A_GuiControl] : Index
		Settings.Gui.Hide()
		Settings.Gui.Show(Index)
	}
	Exit() {
		Settings.Gui.Destroy()
		Setting.Menu.Status := Settings.Gui.HWNDs := ""
		exit
	}
	Class AutoStart {
			Check() {
				FileGetShortcut,% A_Startup "\DLQ Binder.lnk", path
				if ( Settings.AutoStart.Status && !FileExist(path) )
					Settings.AutoStart.Toggle(true)
			}
			Toggle(Status="") {
				if ( status == "Normal" )
					GuiControlGet, Status,,% HWNDs["Settings"]["autoStart"]
				IniWrite,% Status,% Settings.Folder "\Files\Setting.ini", Main, AutoStart
				If (Status)
				  	FileCreateShortcut,% A_ScriptFullPath,% A_Startup "\DLQ Binder.lnk",% A_WorkingDir,% "silent"
				else FileDelete,% A_Startup "\DLQ Binder.lnk"
			}
	}
	Menu(first, second, HWND) { ;C BYDLO
		Static isCreated
		If ( !isCreated ) {
			Menu, ProfilesMenu, Add, Создать, Settings.File.Create
			Menu, ProfilesMenu, Add
			Menu, ProfilesMenu, Add, Переименовать, Settings.File.Rename
			Menu, ProfilesMenu, Add, Удалить, Settings.File.Delete
			Menu, ProfilesMenu, Add
			Menu, ProfilesMenu, Add, Обновить список, Settings.File.Refresh
			isCreated := true
		}
		if ( !Settings.File._getName() ) {
			Menu, ProfilesMenu, Disable, Переименовать
			Menu, ProfilesMenu, Disable, Удалить
		} else {
			Menu, ProfilesMenu, Enable, Переименовать
			Menu, ProfilesMenu, Enable, Удалить
		}
		If ( HWNDs["Settings"]["MenuSystem"][2][1] == Tools.IntToHex(HWND) )
			Menu, ProfilesMenu, Show
	}
	Class File {
		Refresh() {
			GuiControl, -Redraw,% HWNDs["Settings"]["Profiles"]
			GuiControl,,% HWNDs["Settings"]["Profiles"],|
			Loop % Profiles.Folder "*.dlqb"
				GuiControl,,% HWNDs["Settings"]["Profiles"],% SubStr(A_LoopFileName,1,StrLen(A_LoopFileName)-5)
			GuiControl, +Redraw,% HWNDs["Settings"]["Profiles"]
		}
		Create() {
			NewName := Settings.File._newName(1)
			Settings.CheckDir()
			FileInstall, E:\AutoHotKey\Проекты\DLQ Binder\4\Files\Clear_Profile.dlqb,% Profiles.Folder NewName ".dlqb", 0
			if ( ErrorLevel )
				MsgBox, 64, DLQ Binder / Ошибка,% FileExist( Profiles.Folder NewName ".dlqb" ) ? "Профиль с таким именем уже существует" : "Произошла непредвиденная ошибка"
			Settings.File.Refresh(), Profiles.List()
		}
		Rename() {
			Name := Settings.File._getName(), NewName := Settings.File._NewName(2)
			if ( FileExist( Profiles.Folder NewName ".dlqb" ) )
				error := "Профиль с таким именем уже существует"
			if ( !FileExist( Profiles.Folder Name ".dlqb" ) )
				error := "Выбранный профиль не найден"
			if ( !error )
				FileMove,% Profiles.Folder Name ".dlqb",% Profiles.Folder NewName ".dlqb"
			if ( ErrorLevel || error ) {
				MsgBox, 64, DLQ Binder / Ошибка,% ErrorLevel ? "Произошла непревиденная ошибка" : error
				exit
			}
			If ( Name == Settings.Profile ) {
				Settings.Profile := NewName
				GuiControl, Main: ChooseString, ProfilesList,% Settings.Profile
				Settings.CheckDir()
				IniWrite,% Settings.Profile,% Settings.OptionsFile, Main,% "profile"
			}
			Settings.File.Refresh(), Profiles.List()
		}
		Delete() {
			Name := Settings.File._getName()
			MsgBox, 36, Удаление,% "Вы действительно хотите удалить профиль '" Name "'?"
			IfMsgBox, Yes
			{
				FileDelete,% Settings.Dir "\Profiles\" Name ".dlq"
				If (ErrorLevel)
					MsgBox,64, Ошибка, Произошла непредвиденая ошибка
				else {
					If (Name==Settings.Profile) {
						Settings.Profile := "", Gui.Buttons(0)
						IniWrite,% Settings.Profile,% Settings.Dir "\Files\Settings.ini", Main, Profile
					}
					Settings.File.Refresh(), Profiles.List("Settings",0)
				}
			}
		}
		_newName(mode) {
				;InputBox.New("Создание профиля","Введите имя для нового профиля`n","Settings",true)
				NewName := InputBox.New(["Создание профиля","Переименование профиля"][mode],"Введите имя для" ( [" нового",""][mode] ) " профиля","Settings",true)
				If ( ErrorLevel == 1)
					exit
				else if ( RegExMatch(NewName,"[\/:*?<>|]") ) {
					MsgBox, 64, Ошибка, Имя файла не должно содержать следующих знаков:`n\/:*?<>|
					exit
				} else return NewName
			}
		_getName() {
			GuiControlGet, Choosed,,% HWNDs["Settings"]["Profiles"]
			return Choosed
		}
	}	
}