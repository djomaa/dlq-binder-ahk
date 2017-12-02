class FeedBack {
	Class GUI {
		create() {
			Gui, Main: +Disabled
			Gui, FeedBack: New, -MinimizeBox +OwnerMain +LabelFeedBack_,% "DLQ Binder / Техподдержка" ;-MinimizeBox
			Gui, Font, Verdana	
			Gui, Add, Tab3, x-3 y-1, Список обращений | Написать
			
			Gui, Tab, 1
			Gui, Add, ListView, x-1 y20 h200 w310 h275 gFeedBack.Show, Обращение|Номер
			IL_ID := IL_Create(2), LV_SetImageList(IL_ID)
			IL_Add(IL_ID, "HICON:*" FeedBack.GUI.trueIcon), IL_Add(IL_ID, "HICON:*" FeedBack.GUI.falseIcon)
			FeedBack.RefreshList()
			LV_ModifyCol(1,350)
			Gui, Tab, 2
			Gui, Add, DropDownList, +HWNDtype x5 y23 w95 +AltSubmit, Баг|Предложение|Вопрос
			Gui, Add, Edit, +HWNDtheme yp x+2+wp w200 hp r1 +Limit35
			Gui, Add, Edit, +HWNDtext x5 y+2+hp wp+97 h200 -WantReturn
			Gui, Add, Button, xp-1 y+2+hp wp+2 gFeedBack.Send, Отправить
			Tools.SetCueBanner(theme,"Тема обращения"), Tools.SetCueBanner(text,"Текст обращения")	
	
			Gui Show, w307 h275
			exit
			FeedBack_Close:
			Gui, Main: -Disabled
			Gui, FeedBack: -OwnerMain
			Gui, FeedBack: Destroy
			Gui, Main: Default
			exit
		}
	}
	Show() {
			If (A_GuiEvent=="DoubleClick") {
				LV_GetText(Index,A_EventInfo,2)
				Gui, FeedBackDetails: Destroy
				Gui, FeedBackDetails: Destroy
				Gui, FeedBackDetails: New, +ToolWindow +OwnerFeedBack +LabelFeedBackDetails_,% "DLQ Binder / Техподдержка / Обращение #" Index
				Gui, Color, White, White
				Gui, Font,, Verdana
				Gui, Add, Button, x-50 y-50 Default gFeedBackDetails_Close
				Gui, Add, GroupBox, center x-1 y10 w502 h45,% FeedBack.List[Index]["Type"]
				Gui, Add, Edit, x5 yp+14 w490 ReadOnly center r1,% FeedBack.List[Index]["Theme"]
				Gui, Add, Text, x110 y47 ,% " Вопрос "
				Gui, Add, Edit, x5 yp+15 w240 h170 +readOnly,% FeedBack.List[Index]["Text"]
				Gui, Add, Text, x350 y47,% " Ответ "
				Gui, Add, Edit, x255 yp+15 w240 h170 ,% FeedBack.List[Index]["Response"]
				Gui, Add, GroupBox, x-5 y230 w600 h8
				Gui, Add, Text, x5 w490 yp+10 center,% FeedBack.List[Index]["Date"]
				Gui, Show, w500 h255
				Gui, FeedBack: Default
				exit
				FeedBackDetails_Close:
				Gui, FeedBackDetails: Destroy
				Gui, FeedBack: Default
				exit
				
			}
	}
	Send() {
		Gui, Feedback: +OwnDialogs 
		GuiControlGet, type, Feedback:, ComboBox1
		GuiControlGet, theme, Feedback:, Edit1
		GuiControlGet, text, Feedback:, Edit2
		if ( !type )
			error :=  "Выберите тип обращения.`nСписок находится слева от поля для ввода темы."
		else if ( !theme ) 
			error := "Придумайте короткую тему для вашего обращения"
		else if ( !text ) 
			error := "Опишите суть вашего обращения в самом большом поле"
		
		if ( error ) {
			MsgBox, 32,% "DLQ Binder / Техподдержка",% error
			exit
		}
		result:=Tools.Request("http://mozg.zzz.com.ua/Demy/DLQ%20Binder/Feedback/Add.php?serial=" getSerial() "&type=" type "&theme=" UriEncode(theme) "&text=" UriEncode(text))
		if ( result ) {
			FeedBack.RefreshList()
			GuiControl, FeedBack: Choose, SysTabControl321, 1
			MsgBox,,% "DLQ Binder / Техподдержка", Обращение успешно отправлено
			GuiControl, FeedBack:,Edit1,% ""
			GuiControl, FeedBack:,Edit2,% ""
			GuiControl, FeedBack: Choose, ComboBox1, 0
		} else MsgBox,,% "DLQ Binder / Техподдержка", Обращение успешно отправлено
			
	}
	refreshList() {
		Feedback.List := JSON.Load(Tools.Request("http://mozg.zzz.com.ua/Demy/DLQ Binder/Feedback/Give.php?serial=" getSerial()))
		GuiControl,FeedBack: -Redraw, SysListView321
		LV_Delete()
		Loop % FeedBack.List.Length()
			LV_Add("icon" . ( FeedBack.List[A_Index]["response"] ? "1" : "2" ),["Баг","Предложение","Вопрос"][FeedBack.List[A_Index]["type"]] ": " FeedBack.List[A_Index]["theme"],A_Index)
		GuiControl, FeedBack: +Redraw, SysListView321
	}
}


