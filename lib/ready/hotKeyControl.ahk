HKC.Activate()
Class HKC {
	Static Data := {}
	Add( ControlHWND, Key = "" ) {
		If ( HKC.Data[ControlHWND] )
			return 0
		else {
			MsgBox % controlHWND
			HKC.Data[ControlHWND] := true
			GuiControl, +ReadOnly,% ControlHWND
			GuiControl,,% ControlHWND,% ( Key == "" ? "" : HKC.getName(Key) )
		}
	}
	Delete( ControlHWND ) {
		GuiControl, -ReadOnly,% ControlHWND
		GuiControl,,% ControlHWND,% ""
		HKC.Data[ControlHWND] := 0
	}
	Submit( ControlHWND, Type = 1, Delete = 0 ) {
		If ( HKC.Data[ControlHWND] ) {
			GuiControlGet, Key,,% ControlHWND
			Code := HKC.getCode(Key)
			If ( Delete )
				HKC.Delete(ControlHWND)
			If ( Type == 1 )
				return Code
			If ( Type == 2 )
				return Key
		}
	}
	Change() {
		ControlGetFocus, FocusedControl, A
		ControlGet, FocusedControl, Hwnd,,% FocusedControl, A
		;msgbox % HKC.Data[FocusedControl]
		If ( HKC.Data[FocusedControl] ) {
			Static Modifiers := ["LAlt","RAlt","LCtrl","RCtrl","LShift","RShift","LWin","RWin"]
			Key := SubStr(A_ThisHotkey, 3)
			Loop % Modifiers.Length()
			If ( GetKeyState(Modifiers[A_Index]) )
				ActivatedModifiers .= Modifiers[A_Index] "+"
			GuiControl,,% FocusedControl,% ActivatedModifiers HKC.getList("NC")[Key]
		}

	}
	getCode(Key) {
		Static Modifiers := {"LAlt":"<!","RAlt":">!","LCtrl":"<^","RCtrl":">^","LShift":"<+","RShift":">+","LWin":"<#","RWin":">#"}
		List := StrSplit(Key,"+")
		Loop % List.Length() - 1
			Code .= Modifiers[List[A_Index]]
		Code .= HKC.getList("CN")[List[List.Length()]]
		return Code
	}
	getName(Code) {
		Static Modifiers := {"LAlt":"<!","RAlt":">!","LCtrl":"<^","RCtrl":">^","LShift":"<+","RShift":">+","LWin":"<#","RWin":">#"}
		mEnum := Modifiers._newEnum()
		While mEnum[mName,mCode] {
			mNames .= ( InStr(Code,mCode) ? mName "+" : "" )
			Code := StrReplace(Code,mCode,"")
		}
		If ( ( KeyName := HKC.getList("NC")[Code] ) == "" )
			return ""
		else return mNames KeyName
	}
	Activate() {
		Codes := HKC.getList("Codes"), Function := ObjBindMethod(HKC,"Change")
		Loop % Codes.Length()
			Hotkey,% "*~" Codes[A_Index],% Function
	}
	Deactivate() {
		Codes := HKC.GetList("Codes")
		Loop % Codes.Length()
			Hotkey,% Codes[A_Index],% Off
	}
	getList(ListName = 0) {
		Static Names := ["-","0","1","2","3","4","5","6","7","8","9","=","CapsLock","Delete","Down","End","F1","F10","F11","F12","F13","F14","F15","F16","F17","F18","F19","F2","F20","F21","F22","F23","F24","F3","F4","F5","F6","F7","F8","F9","Home","Insert","Left","Numpad *","Numpad +","Numpad -","Numpad . Off","Numpad . On","Numpad /","Numpad0 Off ","Numpad0 On","Numpad1 Off","Numpad1 On","Numpad2 Off","Numpad2 On","Numpad3 Off","Numpad3 On","Numpad4 Off","Numpad4 On","Numpad5 Off","Numpad5 On","Numpad6 Off","Numpad6 On","Numpad7 Off","Numpad7 On","Numpad8 Off","Numpad8 On","Numpad9 Off","Numpad9 On","NumpadEnter","PgDn","PgUp","Right","Up","ё","Пятая кнопка мыши","Средння кнопка мыши","Четвертая кнопка мыши","а","б","в","г","д","е","ж","з","и","й","к","л","м","н","о","п","р","с","т","у","ф","х","ц","ч","ш","щ","ъ","ы","ь","э","ю","я"]
		Static Codes := ["VKbd","VK30","VK31","VK32","VK33","VK34","VK35","VK36","VK37","VK38","VK39","VKbb","VK14","Delete","Down","End","VK70","VK79","VK7a","VK7b","VK7c","VK7d","VK7e","VK7f","VK80","VK81","VK82","VK71","VK83","VK84","VK85","VK86","VK87","VK72","VK73","VK74","VK75","VK76","VK77","VK78","Home","Insert","Left","VK6a","VK6b","VK6d","NumpadDel","VK6e","VK6f","NumpadIns","VK60","NumpadEnd","VK61","NumpadDown","VK62","NumpadPgDn","VK63","NumpadLeft","VK64","NumpadClear","VK65","NumpadRight","VK66","NumpadHome","VK67","NumpadUp","VK68","NumpadPgUp","VK69","NumpadEnter","PgDn","PgUp","VK27","Up","VKc0","VK6","VK4","VK5","VK46","VKbc","VK44","VK55","VK4c","VK54","VKba","VK50","VK42","VK51","VK52","VK4b","VK56","VK59","VK4a","VK47","VK48","VK43","VK4e","VK45","VK41","VKdb","VK57","VK58","VK49","VK4f","VKdd","VK53","VK4d","VKde","VKbe","VK5a","VKbd","VK30","VK31","VK32","VK33","VK34","VK35","VK36","VK37","VK38","VK39","VKbb","VK14","Delete","Down","End","VK70","VK79","VK7a","VK7b","VK7c","VK7d","VK7e","VK7f","VK80","VK81","VK82","VK71","VK83","VK84","VK85","VK86","VK87","VK72","VK73","VK74","VK75","VK76","VK77","VK78","Home","Insert","Left","VK6a","VK6b","VK6d","NumpadDel","VK6e","VK6f","NumpadIns","VK60","NumpadEnd","VK61","NumpadDown","VK62","NumpadPgDn","VK63","NumpadLeft","VK64","NumpadClear","VK65","NumpadRight","VK66","NumpadHome","VK67","NumpadUp","VK68","NumpadPgUp","VK69","NumpadEnter","PgDn","PgUp","VK27","Up","VKc0","VK6","VK4","VK5","VK46","VKbc","VK44","VK55","VK4c","VK54","VKba","VK50","VK42","VK51","VK52","VK4b","VK56","VK59","VK4a","VK47","VK48","VK43","VK4e","VK45","VK41","VKdb","VK57","VK58","VK49","VK4f","VKdd","VK53","VK4d","VKde","VKbe","VK5a"]
		Static ObjectNC := {}, ObjectCN := {}, IsCreated = false ;Name[Code] = Name, Code[Name]
		If ( !IsCreated ) {
			Loop % Names.Length() {
				ObjectCN[Names[A_Index]] := Codes[A_Index]
				ObjectNC[Codes[A_Index]] := Names[A_Index]
			}
			IsCreated := true
		}
		If ( ListName == "NC" || ListName == "CN")
			return ListName == "NC" ? ObjectNC : ObjectCN
		else return ListName ? ( ListName == "Names" ? Names : Codes ) : {"Names":Names,"Codes":Codes}
	}
}
