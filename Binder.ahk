class Binder {
	Send() {
		Loop 60
			If ( A_ThisHotkey == Data[A_Index]["Hotkey"] ) {
				Index := A_Index
				break
			}
		Strings := Data[Index]["Strings"]
		Loop % Strings.Length() {
			;addchatmessage(Strings[A_Index]["Mode"] "`n"  Strings[A_Index]["Text"] " " Strings[A_Index]["Delay"])
			if ( Strings[A_Index]["Mode"] == "1" )
				SendChat( Binder.ModifyStr( Strings[A_Index]["Text"] ) )
			else if ( Strings[A_Index]["Mode"] == "2" )
				SendInput,% "{F6}" RegExReplace( Binder.ModifyStr( Strings[A_Index]["Text"] ), "([\!\+\^\#\{\}])","{$1}" ) "{enter}"
			else if ( Strings[A_Index]["Mode"] == "3" )
				KeyWait,% HKC.getCode(Strings[A_Index]["Text"]), D T60
			sleep,% Strings[A_Index]["Delay"]
		}
		
		Binder.Str  := "Hey, i'm $MyName [$MyID]. heeey. yep $MyName"
		Binder.ModifyStr(Binder.Str)
		msgbox % "FINISHED.`n" 		Binder.Str
	}
	ModifyStr( str ) {
		Binder.Variables := {"$MyID":getPlayerID(),"$MyName":getPlayerNameWithout_(),"$My_Name":getPlayerNameWith_(),"$ClosestID":getClosestPlayerID(),"$ClosestName":getClosestPlayerNameWithout_(),"$Closest_Name":getClosestPlayerNameWith_(),"$TargetID":getTargetPlayerID(),"$TargetName":getTargetPlayerNameWithout_(),"$Target_Name": getTargetPlayerNameWith_()}
		RegExMatch( Binder.Str, "i)\$(Closest_Name|ClosestID|ClosestName|My_Name|MyID|MyName|Target_Name|TargetID|TargetName)(?CBinder_ModifyCallout)")
	}
}
Binder_ModifyCallout(funcName) {
	Binder.Str := StrReplace( Binder.Str, funcName, Binder.Variables[funcName],,1  )
	return 1
}
