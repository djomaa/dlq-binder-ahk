Class Change {
	Start(ControlHWND) {
		Gui, Main: +Disabled
		Change.Index := HWNDs["Main"][ControlHWND]
		Gui, Changing: New, +HWNDwindow +OwnerMain -SysMenu +LabelChanging_
		Gui, Font,, Verdana
		Gui, Color, White, White
		Gui, Add, Button, x-100 y-100 Default gChange.Edit.Try, Enter
		Gui, Add, GroupBox, x5 y5 w200 h41 Section, Название
		Gui, Add, Edit, xp+5 yp+15 w190 Limit25 +HWNDname,% Data[Change.Index]["Name"]
		Gui, Add, GroupBox, xs+203 ys w100 h41 Section , Активация:
		Gui, Add, Edit, xs+5 ys+15 w90 r1 +HWNDhotkey +BackGroundTrans +ReadOnly
		Gui, Add, GroupBox, xs+103 ys h41 w174 Section
		Gui, Add, Button, xs+4 ys+10 w166 h27 gChange.Help, Помощь
		Gui, Add, GroupBox, x5 y42 w480 h305 Section 
		Gui, Add, ListView, xs+7 ys+13 r14.5 w466 +HWNDtext -LV0x10 +ReadOnly +NoSortHdr +Grid +Count99 -Multi gChange.Edit.Try, #|M|Text|L|Delay|
		Gui, Font, Underline
		Gui, Add, Text, xs+150 ys+283 +BackGroundTrans gChange.Number, Добавить
		Gui, Font, Norm Bold
		Gui, Add, Text, x+%wp%+1 +BackGroundTrans,|
		Gui, Font, Norm Underline
		Gui, Add, Text, x+%wp%+1 yp +BackGroundTrans gChange.Number, Убрать
		;Gui, Add, Text, xs+320 yp, Простейший редактор
		Gui, Font, Norm, Verdana
		Gui, Add, Button, y350 x10 w130 gChange.Accept, Применить
		Gui, Add, Button, yp x+%wp% wp gChange.Cancel, Отмена
		Gui, Add, Button, yp x+%wp%+60 w126 gChange.Delete, Удалить
		LV_ModifyCol(1,25), LV_ModifyCol(2,25), LV_ModifyCol(3,285), LV_ModifyCol(4,35), LV_ModifyCol(5, 90)
		Gui, Show,,% "Изменение бинда #" Change.Index

		Text := Data[Change.Index]["Strings"]
		While ( A_Index <= Text.Length() )
			LV_Add("",A_Index,Text[A_Index]["Mode"],Text[A_Index]["Text"],StrLen(Text[A_Index]["Text"]),Text[A_Index]["Delay"])
		Gui, Add, Text, xs+10 ys+283 w200 +BackGroundTrans +HWNDnumber,% "Количество строк: " LV_GetCount()
		
		HWNDs["Changing"] := {"Main":window,"Name":name,"Hotkey":hotkey,"Number":number,"Text":text}
		HKC.Add(HWNDs["Changing"]["Hotkey"],Data[Change.Index]["Hotkey"])
		
	}
	Finish() {
		HKC.Delete(HWNDs["Changing"]["Hotkey"]), HWNDs["Changing"] := ""
		Gui, Main: -Disabled
		Gui,  -OwnerMain
		Gui, Destroy
		Gui, Main: Default
		GuiControl,Main:,% HWNDs["Main"]["Name" Change.Index],% Data[Change.Index]["Name"]
		GuiControl,Main:,% HWNDs["Main"]["Hotkey" Change.Index],% HKC.getName(Data[Change.Index]["Hotkey"])
	}
	Accept() {
		GuiControlGet, Name,,% HWNDs["Changing"]["Name"]
		Hotkey := HKC.Submit(HWNDs["Changing"]["Hotkey"])
		If ( !Hotkey || !Name || LV_GetCount() < 1 ) {
			MsgBox, 32, Ошибка, Заполните название`, назначьте клавишу и введите хотя бы одну строку
			exit
		}
		Loop 60
			if ( Data[A_Index]["Hotkey"] == Hotkey && A_Index != Change.Index) {
				MsgBox, 32, Ошибка,% "Данная клавиша уже занята биндом #" A_Index
				exit
			}
			
		Strings := []
		Loop % LV_GetCount() {
			LV_GetText(Mode,A_Index,2)
			LV_GetText(Text,A_Index,3)
			LV_GetText(Delay,A_Index,5)
			Strings[A_Index] := {"Mode":Mode,"Text":Text,"Delay":Delay}
			}
		Data[Change.Index] := {"Hotkey":Hotkey,"Name":Name,"Strings":Strings}
		Change.Finish()
	}
	Cancel() {
		MsgBox, 36, Отмена, Вы действительно хотите отменить изменение?
		IfMsgBox, Yes
			Change.Finish()	
	}
	Delete() {
		MsgBox, 36, Удаление, Вы действительно хотите удалить данный бинд? Восстановление невозможно.`n`nУдалить?
		IfMsgBox, Yes
		{
			Data[Change.Index] := {"Hotkey":"","Name":"","Strings":[]}
			Change.Finish()	
		}
	}
	Class Menu {
		Show() {
			Changing_ContextMenu:
			Static IsCreated := false
			If ( !IsCreated ) {
				Menu, ChangeMenu, Add, Изменить, Change.Menu.Edit
				Menu, ChangeMenu, Add, Переместить вверх, Change.Menu.MoveUp
				Menu, ChangeMenu, Add, Переместить вниз, Change.Menu.MoveDown
				Menu, ChangeMenu, Add, Удалить, Change.Menu.Delete
			}
			If ( A_EventInfo > 0 && A_EventInfo < 100 ) {
				Change.Menu.Row := A_EventInfo
				Menu, ChangeMenu, Show
				Gui, Changing: Default
			}
			return
		}
		Edit() {
			Gui, Changing: Default
			Change.Edit.Start(Change.Menu.Row)
		}
		Delete() {
			Gui, Changing: Default
			LV_Delete(Change.Menu.Row)
			GuiControl, -Redraw,% HWNDs["Changing"]["Text"]
			While ( A_Index <= LV_GetCount() )
				LV_Modify(A_Index,"",A_Index)
			GuiControl, +Redraw,% HWNDs["Changing"]["Text"]
			Change.Number()
		}
		MoveUp() {
			Gui, Changing: Default
			If ( Change.Menu.Row > 1 ) {
				Row := [[],[]]
				While ( A_Index <= 4 ) {
					LV_GetText(Content1,Change.Menu.Row-1,A_Index+1)
					LV_GetText(Content2,Change.Menu.Row,  A_Index+1)
					Row[1].Push(Content1), Row[2].Push(Content2)
				}
				GuiControl, -Redraw,% HWNDs["Changing"]["Text"]
				LV_Modify(Change.Menu.Row,"",,Row[1][1],Row[1][2],Row[1][3],Row[1][4])
				LV_Modify(Change.Menu.Row-1,"",,Row[2][1],Row[2][2],Row[2][3],Row[2][4])
				LV_Modify(Change.Menu.Row-1, "Focus Select")
				GuiControl, +Redraw,% HWNDs["Changing"]["Text"]
			}
		}
		MoveDown() {
			Gui, Changing: Default
			If ( Change.Menu.Row < LV_GetCount() && Change.Menu.Row < 99 ) {
				Row := [[],[]]
				While ( A_Index <= 4 ) {
					LV_GetText(Content1,Change.Menu.Row+1,A_Index+1)
					LV_GetText(Content2,Change.Menu.Row,  A_Index+1)
					Row[1].Push(Content1), Row[2].Push(Content2)
				}
				GuiControl, -Redraw,% HWNDs["Changing"]["Text"]
				LV_Modify(Change.Menu.Row,"",,Row[1][1],Row[1][2],Row[1][3],Row[1][4])
				LV_Modify(Change.Menu.Row+1,"",,Row[2][1],Row[2][2],Row[2][3],Row[2][4])
				GuiControl, +Redraw,% HWNDs["Changing"]["Text"]
				LV_Modify(Change.Menu.Row+1, "Focus Select")
			}
		}
	}
	Help() {
		Static isCreated
		If ( !isCreated ) {
			Gui, Changing_Help: New
			Gui, Color, White, White
			Gui, +ToolWindow
			Gui, Add, Edit, x-2 y-2 w450 h200 ReadOnly,Чтобы использовать переменную, просто вставьте ее название в нужном Вам месте бинда. Написание переменных должны совпадать по регистру!`n`nПеречень доступных переменных:`n$MyID - ID вашего персонажа`n$MyName - NickName вашего персонажа без знака подчеркивания`n$My_Name - NickName вашего персонажа со знаком подчеркивания`n$ClosestID - ID близжайшего к вам персонажа`n$ClosestName - NickName близжайшего персонажа без знака подчеркивания`n$Closest_Name - NickName близжайшего персонажа со знаком подчеркивания`n$TargetID - ID отмеченого ПКМ  персонажа`n$TargetName - NickName отмеченого ПКМ персонажа без знака подчеркивания`n$Target_Name - NickName отмеченого ПКМ персонажа со знаком подчеркивания
			Gui, Changing: Default
			isCreated := true
		}
		Gui, Changing_Help: Show, w450 h200, Помощь

	}
	Class Edit {
		Try() {
			LV_ModifyCol(1,25), LV_ModifyCol(2,25), LV_ModifyCol(3,285), LV_ModifyCol(4,35), LV_ModifyCol(5, 90)
			If ( A_GuiEvent == "DoubleClick" && A_EventInfo > 0 && A_EventInfo < 100)
				Change.Edit.Start(A_EventInfo)
			else {
				GuiControlGet, Control, Focus
				If ( Control == "SysListView321" && ( Index := LV_GetNext(0,"Focused") ) > 0 && Index < 100 )
						Change.Edit.Start(Index)
			}
		}
		Start(Row) {
			Change.Edit.Row := Row
			LV_GetText(Mode, Row, 2), LV_GetText(Text, Row, 3), LV_GetText(Delay, Row, 5)
			stringData := {"Mode":Mode,"Text":Text,"Delay":Delay}
			Gui, Changing: +Disabled
			Gui, Changing_Editing: New, +OwnerChanging +LabelChanging_Editing_ +ToolWindow,% "Изменение строки #" Change.Edit.Row
			Gui, Color, White
			Gui, Add, GroupBox, x5 y5 w287 h44 Section, Текст\Клавиша:
			Gui, Add, Edit, xs+5 wp-10 ys+15 limit150 +HWNDtext gChange.Edit.CharCounter,% stringData["Text"]
			Gui, Add, Text, xs+150 ys w50 Center +HWNDcharCounter,% StrLen(stringData["Text"]) "/150"
			Gui, Add, GroupBox, xs ys+45 h44 w155 Section, Режим:
			Gui, Add, Text, xp+100 ys gChange.Edit.Help, ?
			Gui, Add, DropDownList, xs+10 w140 ys+15 +HWNDmode gChange.Edit.ChangeMode, Стандартный|Старый|Ожидание клавиши
			Gui, Add, GroupBox, xs+157 ys h44 w75 Section, Задержка:
			Gui, Add, Edit, xs+5 ys+15 wp-10 +HWNDdelay +Number,% Delay
			Gui, Add, Button, xs+80 ys+5 w51 h39 gChange.Edit.Accept, OK
			HWNDs["Changing_Editing"] := {"Text":text,"CharCounter":charCounter,"Mode":mode,"Delay":delay}
			GuiControl, Choose,% HWNDs["Changing_Editing"]["Mode"],% "|" stringData["Mode"]
			
			Gui, Show, w300 h100
		}
		Help() {
			MsgBox,, О режимах, Стандартный - самый быстрый и надежный режим`nСтарый - сообщение отправится через чат`nОжидание клавиши - программа будет ждать нажатия клавиши
		}
		ChangeMode(IsFirstCall = 0) {
			Static IsHotkeyMode
			GuiControlGet, ModeName,,% HWNDs["Changing_Editing"]["Mode"]
			If ( ModeName == "Ожидание клавиши" ) {
				GuiControlGet, Key,,% HWNDs["Changing_Editing"]["Text"]
				HKC.Add(HWNDs["Changing_Editing"]["Text"],HKC.getCode(Key))
				GuiControl, Hide,% HWNDs["Changing_Editing"]["CharCounter"]
				IsHotkeyMode := true
			} else if ( IsHotkeyMode ) {
				HKC.Delete(HWNDs["Changing_Editing"]["Text"])
				GuiControl, Show,% HWNDs["Changing_Editing"]["CharCounter"]
				IsHotkeyMode := false
			}
			/*
			If ( ModeName == "C дописыванием" ) {
				GuiControl, Disable,% HWNDs["Changing_Editing"]["Delay"]
				GuiControl,,% HWNDs["Changing_Editing"]["Delay"],% "0"
				IsAppendingMode := true
			} else if ( IsAppendingMode ) {
				GuiControl, Enable,% HWNDs["Changing_Editing"]["Delay"]
				IsAppendingMode := false
			}
			*/
		}
		CharCounter() {
			GuiControlGet, Text,,% HWNDs["Changing_Editing"]["Text"]
			GuiControl,,% HWNDs["Changing_Editing"]["CharCounter"],% StrLen(Text) "/150"
		}
		Cancel() {
			Changing_Editing_Close:
			MsgBox, 36, Отмена, Закрытие отменит изменения. Закрыть это окно?
			IfMsgBox, Yes
				Change.Edit.Destroy()
			exit 
		}
		Accept() {
			GuiControlGet, Mode,,%  HWNDs["Changing_Editing"]["Mode"]
			GuiControlGet, Text,,%  HWNDs["Changing_Editing"]["Text"]
			GuiControlGet, Delay,,% HWNDs["Changing_Editing"]["Delay"]
			Change.Edit.Destroy()
			Mode := {"Стандартный":1,"Старый":2,"Ожидание клавиши":3}[Mode]
			LV_Modify(Change.Edit.Row,"Focused Selected",,Mode,Text,( Mode == 3 ? " - " : StrLen(Text) ), ( Delay == "" ? 0 : Delay ) )
			
		}
		Destroy() {
			Gui, Changing: -Disabled
			Gui, -OwnerChanging
			Gui, Destroy
			Gui, Changing: Default
			HKC.Delete(HWNDs["Changing_Editing"]["Text"]), HWNDs["Changing_Editing"] := ""
			return
		}
	}
	Number() {
		Number := LV_GetCount()
		If ( A_GuiControl == "Добавить" && Number < 100 )
			LV_Add("",LV_GetCount()+1,"1","","0","0")
		If ( A_GuiControl == "Убрать" && Number > 0 )
			LV_Delete(LV_GetCount())
		GuiControl,,% HWNDs["Changing"]["Number"],% "Количество строк: " LV_GetCount()
	}
}