global functions := {"$MyID":"getPlayerID","$MyName":"getPlayerName_","$My_Name":"getPlayerName","$ClosestID":"getClosestPlayerID","$ClosestName":"getClosestPlayerName_","$Closest_Name":"getClosestPlayerName","$TargetID":"getTargetPlayerID","$TargetName":"getTargetPlayerName","$Target_Name": "getTargetPlayerName_"}
pattern := "(Closest_Name|ClosestID|ClosestName|My_Name|MyID|MyName|Target_Name|TargetID|TargetName)"
global text := "Привет. I'm $MyID. tralala $MyName. one more $MyID"

fu := ObjBindMethod(test,"Callout")
foo := Func(test, "Callout").Name
msgbox %  foo
;
;pcre_callout = %fu%

RegExMatch(Text, "C)\$" pattern "(?C" %fu% ")" )
msgbox % text
exit

class test {
	static var
	Callout(fuName) {
		msgbox COUT
		text := StrReplace(text,fuName,functions[fuName],,1)
		return 1
	}
}
F1::Reload
F2::Pause Toggle
getPlayerId(){
return 11
}
getPlayerName_() {
return test_player
}