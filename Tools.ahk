class InputBox {
		; 0 - OK
		; 1 - CLOSED
		; 2 - UNKNOWN
		Static ownerGui, block, ErrorLevel
		New( title, text, ownerGui := "",block := false, options := "", button := "Принять") {
			InputBox.ErrorLevel := 2, InputBox.Result := ""
			InputBox.OwnerGui := ownerGui, InputBox.Block := block ; в Destroy'e используется
			if ( block )
				Gui, %ownerGui%: +Disabled
			Gui, InputBox: New,% "+ToolWindow +HWNDwinHWND +LabelInputBox_ " ( ownerGui ? "+Owner" ownerGui : "" )
			Gui, Add, Text, center,% text
			Gui, Add, Edit, xp y+1+hp wp %options% gInputBox.ToggleButton
			Gui, Add, Button, yp+22 xp-1 wp+2 gInputBox.Submit +Disabled,% button
			Gui, Show,,% Title
			WinWait,% "ahk_id " winHWND
			WinWaitClose,% "ahk_id " winHWND
			return ( ( ErrorLevel := InputBox.ErrorLevel ) ? " " : InputBox.Result )
		}
		Submit() {
			GuiControlGet, result, InputBox:, Edit1
			InputBox.Result := result, InputBox.ErrorLevel := 0
			InputBox.Destroy()
		}
		Close() {
			InputBox_Close:
			InputBox.ErrorLevel := "1"
			InputBox.Destroy()
			return
		}
		Destroy() {
			if ( InputBox.Block )
				Gui,% InputBox.OwnerGui ": -Disabled"
			Gui,% "InputBox: -Owner" InputBox.OwnerGui
			Gui, InputBox: Destroy
			Gui,% InputBox.OwnerGui ": Default"
		}
		ToggleButton() {
			GuiControlGet, result, InputBox:, Edit1
			if ( StrLen(result) == 0 )
				GuiControl, InputBox: Disable,  Button1
			else GuiControl, InputBox: Enable,  Button1
		}
	}
isNull(var) {
	return var == "" ? true : false
}
UriEncode(str, encoding := "UTF-8") {
	PrevFormat := A_FormatInteger
	SetFormat, IntegerFast, H
	VarSetCapacity(var, StrPut(str, encoding))
	StrPut(str, &var, encoding)
	While (code := NumGet(Var, A_Index - 1, "UChar")) {
		bool := (code > 0x7F || code < 0x30 || code = 0x3D)
		UrlStr .= bool ? "%" . SubStr("0" . SubStr(code, 3), -1) : Chr(code)
	}
	SetFormat, IntegerFast, % PrevFormat
	Return UrlStr
}
GetSerial() {
	Static fSerial
	If (fSerial=="") {
		DriveGet, Drives, List
		Loop, Parse, Drives
		{
			DriveGet, DiskType, Type,% A_LoopField ":\"
			If (DiskType=="Fixed") {
				Disk := A_LoopField
				break
			}
		}
		DriveGet, Serial, Serial,% Disk ":\"
		fSerial := Serial
	}
	return fSerial
}

Class Tools {

	BlockToggle(GuiName, Status = "") {
		Static Statuses := {}
		If ( Status == "Unblock" || ( !Status && Statuses[GuiName] ) )
			Gui, %GuiName%: -Disabled
		If ( Status == "Block" || ( !Status && Statuses[GuiName] ) )
			Gui, %GuiName%: +Disabled
		Statuses[GuiName] := !Statuses[GuiName]
	}
	Class Msg {
		Static OwnerWindow
		Create(Text, OwnerWindow) {
			This.OwnerWindow := OwnerWindow
			Gui, Msg: New
			Gui, Color, c3399FF
			Gui, Font, s10 w750 cWhite, Verdana
			Gui, +Owner%OwnerWindow% -Caption +Border
			Gui, %OwnerWindow%: +Disabled
			Gui, Add, Text,x10 Center,% Text
			Gui, Show
			return
		}
		Destroy() {
			OwnerWindow := This.OwnerWindow
			Gui, %OwnerWindow%: -Disabled
			Gui, -Owner%OwnerWindow%
			Gui, Msg: Destroy
		}
	}
	Class Crypt {
		Static Key := "Calradia"
		Encode(Text) {
			Loop, Parse, Text
			Out .= Substr("000" . asc(a_loopfield) ^ asc(substr(This.Key, mod(a_index, strlen(This.Key)), 1)), -3)
			return Out
		}
		Decode(Text) {
			Count := 1
			loop, % strlen(text) / 4
			{
			Chr := ltrim(substr(text, count, 4), 0)
			Out .= chr((chr ? chr : 0) ^ asc(substr(This.Key, mod(a_index, strlen(This.Key)), 1)))
			Count+=4
			}
			return Out
		}
	}
	IntToHex(int) {
		CurrentFormat := A_FormatInteger
		SetFormat, integer, hex
		int += 0
		SetFormat, integer,% CurrentFormat
		return int
	}
	CleanCode(Code) {
		return RegExReplace(Code,"\s*<!--.*$")
	}
	Request(URL, Referer="", TimeoutSec=-1, UserAgent="", Cookie="", Proxy="", ProxyBypassList="", EnableRedirects="", URLCodePage="", Charset="UTF-8") {
		WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		t := URLCodePage ? WebRequest.Option(2):=URLCodePage :
		t := (EnableRedirects <> "") ? WebRequest.Option(6):=EnableRedirects :
		t := Proxy ? WebRequest.SetProxy(2,Proxy,ProxyBypassList) :
		try WebRequest.Open("GET", URL, true)
		catch	Error {
			ErrorLevel := "Wrong URL format"
			return false
		}
		t := Cookie ? WebRequest.SetRequestHeader("Cookie", Cookie) :
		t := Referer ? WebRequest.SetRequestHeader("Referer", Referer) :
		t := UserAgent ? WebRequest.SetRequestHeader("User-Agent", UserAgent) :
		WebRequest.Send()
		t := A_TickCount
		try Suc:=WebRequest.WaitForResponse(TimeoutSec+0)
		catch	Error {
			OutputDebug % "Error WaitForResponse: " A_TickCount - t
			ErrorLevel := "No internet access / No existing domain"
			return false
		}
		OutputDebug % "Success WaitForResponse: " A_TickCount - t
		try HTTPStatusCode := WebRequest.Status
		catch	Error {
			ErrorLevel := "TimeOut"
			return false
		}
		if (SubStr(HTTPStatusCode, 1, 1) ~= "4|5") {
		ErrorLevel := "Error HTTP Status Code: " HTTPStatusCode
		return false
		}
		If (Charset="") {
			try ResponseText := WebRequest.ResponseText()
			catch	Error {
				ErrorLevel := "TimeOut"
				return false
			}
		} Else {
			ADO := ComObjCreate("adodb.stream")
			ADO.Type := 1
			ADO.Mode := 3
			ADO.Open()
			ADO.Write(WebRequest.ResponseBody())
			ADO.Position := 0
			ADO.Type := 2
			ADO.Charset := Charset
			ResponseText := ADO.ReadText()
		}
		return ResponseText
	}
	InternetFileGetSize(URL) {
		hMod := DllCall( "LoadLibrary", WStr, "wininet.dll" )
		hIO  := DllCall( "wininet\InternetOpenW", WStr, "Microsoft Internet Explorer", UInt, 4, Int,  0, Int, 0, UInt, 0 )
		hIU  := DllCall( "wininet\InternetOpenUrlW", UInt, hIO, WStr, URL, Int, 0, Int, 0, UInt, 0x84000000, UInt, 0 )
		If ( hIO & hIU )
			If ( SubStr( URL,1,4 ) = "ftp:" ) {
				varSetCapacity(huint,4)
				FileSize := DllCall( "wininet\FtpGetFileSize", UInt,hIU,UInt,&huint,UInt)
				FileSize := FileSize + (NumGet(huint)*(2**32))
			} else  DllCall( "wininet\HttpQueryInfoW", UInt, hIU, UInt,  0x20000005, UIntP, FileSize, UIntP,4, Int,0 )
		DllCall( "wininet\InternetCloseHandle", UInt, hIU )
		DllCall( "wininet\InternetCloseHandle", UInt, hIO )
		DllCall( "FreeLibrary", UInt, hMod )
		Return FileSize
	}
	SetCueBanner(HWND, STRING) { ; thaaanks tidbit ;
        static EM_SETCUEBANNER := 0x1501
        if (A_IsUnicode) ; thanks just_me! http://www.autohotkey.com/community/viewtopic.php?t=81973
			return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", EM_SETCUEBANNER, "Ptr", false, "WStr", STRING)
		else {
                if !(HWND + 0) {
                        GuiControlGet, CHWND, HWND, %HWND%
                        HWND := CHWND
                } VarSetCapacity(WSTRING, (StrLen(STRING) * 2) + 1)
                DllCall("MultiByteToWideChar", UInt, 0, UInt, 0, UInt, &STRING, Int, -1, UInt, &WSTRING, Int, StrLen(STRING) + 1)
                DllCall("SendMessageW", "UInt", HWND, "UInt", EM_SETCUEBANNER, "UInt", SHOWALWAYS, "UInt", &WSTRING)
                return
        }
	}
	AddToolTip(CtrlHwnd,text,Modify=0) {
        static TThwnd, GuiHwnd, Ptr
        if (!TThwnd) {
                Gui,+LastFound
                GuiHwnd:=WinExist()
                TThwnd:=DllCall("CreateWindowEx","Uint",0,"Str","TOOLTIPS_CLASS32","Uint",0,"Uint",2147483648 | 3,"Uint",-2147483648
        ,"Uint",-2147483648,"Uint",-2147483648,"Uint",-2147483648,"Uint",GuiHwnd,"Uint",0,"Uint",0,"Uint",0)
                Ptr:=(A_PtrSize ? "Ptr" : "UInt"), DllCall("uxtheme\SetWindowTheme","Uint",TThwnd,Ptr,0,"UintP",0)
        } Varsetcapacity(TInfo,44,0), Numput(44,TInfo), Numput(1|16,TInfo,4), Numput(GuiHwnd,TInfo,8), Numput(CtrlHwnd,TInfo,12), Numput(&text,TInfo,36)
        !Modify   ? (DllCall("SendMessage",Ptr,TThwnd,"Uint",1028,Ptr,0,Ptr,&TInfo,Ptr))
. (DllCall("SendMessage",Ptr,TThwnd,"Uint",1048,Ptr,0,Ptr,A_ScreenWidth))
        DllCall("SendMessage",Ptr,TThwnd,"UInt",(A_IsUnicode ? 0x439 : 0x40c),Ptr,0,Ptr,&TInfo,Ptr)
}
}