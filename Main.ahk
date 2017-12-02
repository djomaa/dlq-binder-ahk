#NoEnv
#SingleInstance Force
#NoTrayIcon

Global Data
Global HWNDs := {}

#Include <JSON>
#Include <UDFr16>
#Include <HotKeyControl>

#Include Tools.ahk
#Include Settings.ahk
#Include Profiles.ahk
#Include Binder.ahk
#Include Change.ahk
#Include FeedBack.ahk
#include Update.ahk

#if WinActive("GTA:SA:MP")
#If !WinActive("GTA:SA:MP")
#if 
/* TODO

Переделать систему переменных +
Определение сервера для Serial

Проверка на запуск от имени админа

suggestion

Уведомление об ожидании нажатия ( и возможность отключения его в настройках )

#### То что снизу, то забито
запоминание ширины столбцов при изменении
Доделать простейший редактор
*/
Settings.CheckDir()
Update.Check()
If 1 = silent
	Programm.GUI.SilentMode := true
Programm.GUI.Create()
Programm.Menu.Create()
Settings.Load()
Settings.autoStart.Check()
Profiles.List()
Profiles.Load()
if ( !Programm.GUI.SilentMode )
	Programm.GUI.Show()
exit

F1::reload

Class Programm {
	Exit() {
		Main_Close:
		ExitApp
	}
	Class Menu {
		Create() {
			Menu, Tray, NoStandard
			Menu, Tray, Tip,% "DLQ Binder version " Settings.Version
			Menu, Tray, Click, ClickCount
			Menu, Tray, Add, Новости разработчиков, Programm.Menu.Calradia
			Menu, Tray, Add
			Menu, Tray, Add,% Programm.GUI.SilentMode ? "Открыть" : "Скрыть", Programm.GUI.Toggle
			Menu, Tray, Default, 3&
			Menu, Tray, Add, Выход, Programm.Exit
			Menu, Tray, Icon
		}
		Calradia() {
			Run, http://vk.com/calradia
		}
	}
	Class GUI {
		Toggle() {
			If (  WinExist("ahk_id" HWNDs["Main"]["Window"]) ) {
				Gui, Main: Hide
				Menu, Tray, Rename, 3&, Открыть
			} else {
				Gui, Main: Show, w600 h350
				Menu, Tray, Rename, 3&, Скрыть
			}
			return
			Main_Size:
			if ( A_EventInfo == 1 ) {
				Gui, Main: Hide
				Menu, Tray, Rename, 3&, Открыть
			}
			return
		}
		Enable() {
			Loop % HWNDs["Main"]["Buttons"].Length()
				GuiControl,  Enable, % HWNDs["Main"]["Buttons"][A_Index]
		}
		Disable() {
			Loop % HWNDs["Main"]["Buttons"].Length()
				GuiControl,  Disable, % HWNDs["Main"]["Buttons"][A_Index]
		}
		Hide() {
			Gui, Main: Hide
		}
		Show() {
			Gui, Main: Show, w600 h350
		}
		Create() {
			Gui, Main: New, +HWNDmain +LabelMain_ +HWNDwindow,% "DLQ Binder v" Settings.Version
			Gui, Font,, Verdana
			Gui, Color, White
			Gui, Add, Tab3, +Theme -BackGround x-3 y-3 w660 h310, 1|2|3|4|5|6|Приложения
			Index := 1, ChangeFunc := ObjBindMethod(Change, "Start")
			While ( A_Index <= 6 ) {
				Gui, Tab,% A_Index
				Gui, Add, Text, x20  y32 +BackGroundTrans, Клавиша
				Gui, Add, Text, x125 y32 +BackGroundTrans, Название
				Distance := 50
				While ( A_Index <= 10 ) {
					Gui, Add, Edit, ReadOnly x17  w100 y%Distance% +HWNDhotkey%Index%
					Gui, Add, Edit, ReadOnly x122 w200 yp +HWNDname%Index%
					Gui, Add, Button, x327 w260 yp hp +HWNDbutton%Index%, Изменить
					GuiControl +G,% button%index%,% ChangeFunc
					Index++, Distance += 25
				}
			}
			Gui, Tab
			Gui, Add, DropDownList, x10 y318 gProfiles.Change +HWNDprofilesList,1|2
			Gui, Add, Button, x+%wp%+10 y310 w100 h37 gProfiles.Save, Сохранить
			Gui, Add, Button, x+%wp%+3 yp wp hp gSettings.GUI.Create, Настройки
			Gui, Add, Button, x+%wp%+3 yp wp hp gFeedBack.GUI.Create, Техподдержка
			Gui, Add, Button, x+%wp%+45 yp wp hp gProgramm.Exit, Выход
			HWNDs["Main"] := {"Window":window,"Profiles":profilesList,"Buttons":[]}
			While ( A_Index <= 60 ) {
				HWNDs["Main"]["Hotkey" A_Index] := hotkey%A_Index%
				HWNDs["Main"]["Name" A_Index] := name%A_Index%
				HWNDs["Main"][button%A_Index%] := A_Index
				HWNDs["Main"]["Buttons"].Push(button%A_Index%)
			}
		}
	}
}
