#SingleInstance Force
#NoEnv
global Keys := []
global nextIndex := 0

;------------------------------- Functions ------------------------------;
;------- Mouse Calibration --------;
CalibrateMouse:
	FileDelete, Mouse Calibration.txt
	MouseCalibration := []
	ToolTip, Click into Guild Wars 2.
	KeyWait, LButton, down
	KeyWait, LButton, up
	Loop 8
	{
		ToolTip, Left Click where Note %A_Index% is in game.
		KeyWait, LButton, down
		KeyWait, LButton, up
		MouseGetPos, MouseX, MouseY
		MouseCalibration.Push(MouseX,MouseY)
	}	
	ToolTip, Left Click where octave swap down is in game.
	KeyWait, LButton, down
	KeyWait, LButton, up
	MouseGetPos, MouseX, MouseY
	MouseCalibration.Push(MouseX,MouseY)
	ToolTip, Left Click where octave swap up is in game.
	KeyWait, LButton, down
	KeyWait, LButton, up
	MouseGetPos, MouseX, MouseY
	MouseCalibration.Push(MouseX,MouseY)
	msgbox, Done!
	ToolTip

	;Append Mouse Calibration info into Mouse Calibration.txt
	DataLen := MouseCalibration.Length() / 2
	ToAppend := []
	index := 1
	Loop %DataLen%
		{
			entry := MouseCalibration[index]","MouseCalibration[index+1]"`n"
			index += 2
			FileAppend, %entry%, Mouse Calibration.txt
		}
	Gui, MouseCalibrationGui:Destroy
return
;------- Refresh List View Contents ------;
ReloadSongs:
	; This cross references file names in the csv folder with file names in the data file
	; With get the file date from the csv folder and the number of players from the data file
	;ColorLV := New LV_Colors(HLV)
	GuiControl, Show, GW2AhkPlayer
	Gui, 1:Default
	LV_Delete()
	Data := []
	Loop, read, Data.csv
	{
		Loop, parse, A_LoopReadLine, `,
		{
			Data.Push(A_LoopField)
		}
	}

	;Add any songs that aren't in Data.csv into it
	Loop, Songs\*.*
	{
		isInCsv := false
		NoExt := StrReplace(A_LoopFileName, ".ahk" , "")
		DataLen := Data.Length()
		Loop %DataLen%
		{
			if (Data[A_Index] == NoExt)
			{
				isInCsv := true
			}
		}
		if (isInCsv = false)
		{
			newEntry := "`n" NoExt ",0,0,1"
			FileAppend, %newEntry%, Data.csv
			Gui, Font, c000000
			FormatTime, FileDate, %A_LoopFileTimeCreated%, MM-dd-yy
			LV_Add("", NoExt,0,FileDate)
		}
	}


	Loop, Songs\*.*
	{
		NoExt := StrReplace(A_LoopFileName, ".ahk" , "")
		DataLen := Data.Length()
		Loop %DataLen%
		{
			if (Data[A_Index] == NoExt)
			{
				Gui, Font, c000000
				FormatTime, FileDate, %A_LoopFileTimeCreated%, MM-dd-yy
				LV_Add("", NoExt,Data[A_Index+2],FileDate)
			}
		}
	}
return

;------- Remake New Song GUI ------;
NewNewSongGUI:
	Gui,NewSong:Add,Text,x0 y3 w50 h20,Title :
	Gui,NewSong:Add,Edit,x50 y0 w325 h20 vNewSongTitle,
	Gui,NewSong:Add,Text,x0 y20 w100 h20,Tempo Modifier :
	Gui,NewSong:Add,DropDownList,x100 y20 w100 h100 vTempoModifier, -10|-9|-8|-7|-6|-5|-4|-3|-2|-1|0||1|2|3|4|5|6|7|8|9|10
	Gui,NewSong:Add,Button,x80 y20 w20 h20 gTempoExplanation,?
	Gui,NewSong:Add,CheckBox,x220 y23 w200 h20 vEnableDelayCounter, Enable Octave Swap Delays?
	Gui,NewSong:Add,Text,x0 y43 w400 h20 Center,Paste Abc/Ahk Code Below :
	Gui,NewSong:Add,Edit,x0 y60 w400 h400 vSongCode,
	Gui,NewSong:Add,Button,x325 y460 w75 h40 gNewSongOkButton Center,Add song
return

;------- Manage List Click Events ------;
MyListView:
Critical
	if A_GuiEvent = I
	{
		LV_GetText(RowText, A_EventInfo) ; Get the text from the row's first field.
		HighlightedSong := RowText
	}
return

RefreshPlayers:
	Sleep, 150
	ControlSend,, {9}, Guild Wars 2
	Sleep, 150
	ControlSend,, {9}, Guild Wars 2
	Sleep, 150
	ControlSend,, {0}, Guild Wars 2
return

;------- Parse Config to get info on the selected song ------;
ParseSong:
	Gui, Submit, Nohide
	ConfigCsv := []
	Mouse1x := "", Mouse1y := "", Mouse2x := "", Mouse2y := "", Mouse3x := "", Mouse3y := "", Mouse4x := "", Mouse4y := "", Mouse5x := "", Mouse5y := "", Mouse6x := "", Mouse6y := "", Mouse7x := "", Mouse7y := "", Mouse8x := "", Mouse8y := "", Mouse9x := "", Mouse9y := "", Mouse10x := "", Mouse10y := ""
	Loop, read, Config.txt
		{
			Loop, parse, A_LoopReadLine, `,
				{
					ConfigCsv.Push(A_LoopField)
				}
		}
	ConfigLen := ConfigCsv.Length()
	Loop %ConfigLen%
		{
			If (ConfigCsv[A_Index] == "EnableClicks")
			{
				EnableClicks := ConfigCsv[A_Index+1]
			}
		}
	if (EnableClicks)
		{
			Loop, read, Mouse Calibration.txt
				{
					index := A_Index
					item := 0
					Loop, parse, A_LoopReadLine, `,
						{
							if (item = 0)
									Mouse%index%x := A_LoopField
							else
									Mouse%index%y := A_LoopField
							item += 1
						}
				}
		}
	;Read data.csv to find whether or not Octave Delays are enabled for the song
	Data := []
	Loop, read, Data.csv
	{
		Loop, parse, A_LoopReadLine, `,
		{
			Data.Push(A_LoopField)
		}
	}
	DataLen := Data.Length()
	Loop %DataLen%
		{
			if (HighlightedSong == Data[A_Index])
				{
					EnableDelays := Data[A_Index+3]
					AddPlays := Data[A_Index+2]+1
					DefaultTempo := 1+((Data[A_Index+1] * 0.05)*-1)
					TempoModifier := Data[A_Index+1]
				}
		}

	Gosub, AhkPlayer
	
	Gosub, RefreshPlayers
return

;------- Main Song Player ------;
AhkPlayer:
	counter := new SecondCounter()
	Keys := []
	Delays := []
	nkey = 0
	global notif := false
	nchord := ""

	global Delay2 := Ceil(Delay / 10)
	global isSleep := false

	Data := []
	ToWrite := ""
	Loop, read, Data.csv
	{
		Loop, parse, A_LoopReadLine, `,
		{
			if (A_LoopField != HighlightedSong)
				{
					if (A_LoopField != "")
						ToWrite .= A_LoopReadLine . "`n"
				}
			break
		}
	}

	newEntry := HighlightedSong "," TempoModifier ","  AddPlays "," EnableDelays
	toWrite .= newEntry
	FileDelete, Data.csv
	FileAppend, %toWrite%, Data.csv
	Gosub, ReloadSongs

	nchord := ""
	Loop, read, Songs\%HighlightedSong%.ahk
	{
		var := A_LoopReadLine
		StringReplace, var, var, Numpad1 down, Numpad1 down, UseErrorLevel
   		one := ErrorLevel
		StringReplace, var, var, Numpad2 down, Numpad2 down, UseErrorLevel
   		two := ErrorLevel
		StringReplace, var, var, Numpad3 down, Numpad3 down, UseErrorLevel
   		three := ErrorLevel
		StringReplace, var, var, Numpad4 down, Numpad4 down, UseErrorLevel
   		four := ErrorLevel
		StringReplace, var, var, Numpad5 down, Numpad5 down, UseErrorLevel
   		five := ErrorLevel
		StringReplace, var, var, Numpad6 down, Numpad6 down, UseErrorLevel
   		six := ErrorLevel
		StringReplace, var, var, Numpad7 down, Numpad7 down, UseErrorLevel
   		seven := ErrorLevel
		StringReplace, var, var, Numpad8 down, Numpad8 down, UseErrorLevel
   		eight := ErrorLevel
		StringReplace, var, var, Numpad9, Numpad9, UseErrorLevel
   		zero := ErrorLevel
		StringReplace, var, var, Numpad0, Numpad0, UseErrorLevel
   		nine := ErrorLevel
		str := "Sleep, "
		StringReplace, var, var, %str%, %str%, UseErrorLevel
   		isSleep := ErrorLevel

		if (one > 0)
			nchord .= "1"
		else if (two > 0)
			nchord .= "2"
		else if (three > 0)
			nchord .= "3"
		else if (four > 0)
			nchord .= "4"
		else if (five > 0)
			nchord .= "5"
		else if (six > 0)
			nchord .= "6"
		else if (seven > 0)
			nchord .= "7"
		else if (eight > 0)
			nchord .= "8"
		else if (nine > 0)
			nchord .= "9"
		else if (zero > 0)
			nchord .= "0"
		else if (isSleep > 0)
			{
				toSleep := StrReplace(var, "Sleep, ")
				Keys.Push(nchord)
				Delays.Push(toSleep)
				nchord := ""
			}

	}
	klen := Keys.Length()
	slen := Delays.Length()

	Loop %klen%
	{
		if (StopSong = true)
			{
				break
			}
		SleepDelay := Delays[A_Index]
		toPlay := Keys[A_Index]
		nextIndex := A_Index + 1
		counter.Stop()
		Loop, parse, toPlay
		{
			var := A_LoopField
			
			if ((var = 9) || (var = 0))
			{
				if (EnableDelays == 1)
				{
					;DLLCall Sleeps For More Accuracy
					DllCall("QueryPerformanceFrequency", "Int64*", 1)
					DllCall("QueryPerformanceCounter", "Int64*", startTime)
					dif := Floor((startTime - endTime)/10000)
					
					if (dif < Delay)
						{
							dif := Delay - dif
							Sleep, %dif%
						}
					DllCall("QueryPerformanceCounter", "Int64*", endTime)
				}	
			}
			if (EnableClicks)
			{
				if (var = 1)
				{
					ControlClick,, Guild Wars 2, , Left, 1, x%Mouse1x% y%Mouse1y%
				}
				else if (var = 2)
				{
					ControlClick,, Guild Wars 2, , Left, 1, x%Mouse2x% y%Mouse2y%
				}
				else if (var = 3)
				{
					ControlClick,, Guild Wars 2, , Left, 1, x%Mouse3x% y%Mouse3y%
				}
				else if (var = 4)
				{
					ControlClick,, Guild Wars 2, , Left, 1, x%Mouse4x% y%Mouse4y%
				}
				else if (var = 5)
				{
					ControlClick,, Guild Wars 2, , Left, 1, x%Mouse5x% y%Mouse5y%
				}
				else if (var = 6)
				{
					ControlClick,, Guild Wars 2, , Left, 1, x%Mouse6x% y%Mouse6y%
				}
				else if (var = 7)
				{
					ControlClick,, Guild Wars 2, , Left, 1, x%Mouse7x% y%Mouse7y%
				}
				else if (var = 8)
				{
					ControlClick,, Guild Wars 2, , Left, 1, x%Mouse8x% y%Mouse8y%
				}
				else if (var = 9)
				{
					ControlClick,, Guild Wars 2, , Left, 1, x%Mouse9x% y%Mouse9y%
				}
				else if (var = 0)
				{
					ControlClick,, Guild Wars 2, , Left, 1, x%Mouse10x% y%Mouse10y%
				}
			}
			else
			{
				ControlSend,, %var%, Guild Wars 2
			}
		}
		counter.Start()
		SleepDelay *= %DefaultTempo%
		Sleep, %SleepDelay%
	}
return

class SecondCounter {
    __New() {
        this.interval := 1
        this.count := 1
        ; Tick() has an implicit parameter "this" which is a reference to
        ; the object, so we need to create a function which encapsulates
        ; "this" and the method to call:
        this.timer := ObjBindMethod(this, "Tick")
    }
    Start() {
        ; Known limitation: SetTimer requires a plain variable reference.
        timer := this.timer
		this.count := 0
        SetTimer % timer, % this.interval
        ;ToolTip % "Counter started"
    }
    Stop() {
        ; To turn off the timer, we must pass the same object as before:
        timer := this.timer
		this.count := 0
        SetTimer % timer, Off
        ;ToolTip % "Counter stopped at " this.count
    }
    ; In this example, the timer calls this method:
    Tick() {
		this.count++
		if (this.count >= Delay2){
			first := SubStr(Keys[NextIndex], 1, 1)
			if ((first = 0) || (first = 9))
			{
				ControlSend,, {%first%}, Guild Wars 2
				DllCall("QueryPerformanceCounter", "Int64*", endTime)
				newStr := SubStr(Keys[NextIndex], 2)
				Keys[NextIndex] := newStr
			}
			this.Stop()
			this.count := 0
		}
    }
}
