#SingleInstance Force
#NoEnv
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
Keys := []
noteOrSleep := []
KeysToPlay := []
SleepNext := []
nkey = 0
global notif := false
nchord := ""

global Delay2 := Delay / 10
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

Loop, read, Songs\%HighlightedSong%.ahk
	{
   		Loop, parse, A_LoopReadLine, %A_Space%
    		{
			var = %A_Loopfield%
			if (isSleep = true){
				if(notif = true){
					nChord := ""
				}
				if (nChord > ""){
					Keys.Push(nChord)
					NoteOrSleep.Push(1)
					nChord := ""
				}
				Keys.Push(var)
				NoteOrSleep.Push(0)
				isSleep := false
				notif := false
			}else if (notif = true){
				if (nChord > ""){
					Keys.Push(nChord)
					NoteOrSleep.Push(1)
					nChord := ""
				}
				notif := false
			}else{
			if (var = "{Numpad1"){
				nkey = 1
			}
			if (var = "{Numpad2"){
				nkey = 2
			}
			if (var = "{Numpad3"){
				nkey = 3
			}
			if (var = "{Numpad4"){
				nkey = 4
			}
			if (var = "{Numpad5"){
				nkey = 5
			}
			if (var = "{Numpad6"){
				nkey = 6
			}
			if (var = "{Numpad7"){
				nkey = 7
			}
			if (var = "{Numpad8"){
				nkey = 8
			}
			if (var = "{Numpad9}"){
				nkey = 0
				nchord := nchord . nKey
				notif := true
			}
			if (var = "{Numpad0}"){
				nkey = 9
				nchord := nchord . nKey
				notif := true
			}
			if (var = "down}"){
				nchord := nchord . nKey
			}
			if (var = "up}"){
				notif := true
			}
			}
			if (var = "Sleep,"){
				isSleep := true
			}
    		}
	}
	
	klen := Keys.Length()
	toLoop = 1
	Loop %klen%
	{
		isNote := NoteOrSleep[toLoop]
		toPlay := Keys[toLoop]
		isNextNote := NoteOrSleep[toLoop + 1]
		toPlayNext := Keys[toLoop + 1]
		if (isNote = 0){
			if ((toPlayNext = 0) || (toPlayNext = 9))
			{
				toSleep := toPlay - Delay
				if (toSleep > 0)
				{
					KeysToPlay.Push(Delay)
					SleepNext.Push(0)
					KeysToPlay.Push(toPlayNext)
					SleepNext.Push(1)
					KeysToPlay.Push(toSleep)
					SleepNext.Push(0)
					toLoop++
				}else{
					KeysToPlay.Push(toPlay)
					SleepNext.Push(0)
				}
			}else{
					KeysToPlay.Push(toPlay)
					SleepNext.Push(0)
				
				}
		}else{
			KeysToPlay.Push(toPlay)
			SleepNext.Push(1)
		}
		toLoop++
	}
	klen := KeysToPlay.Length()
	
	Loop %klen%
	{
		if (StopSong = true)
			{
				break
			}
		isNote := SleepNext[A_Index]
		toPlay := KeysToPlay[A_Index]
		if (isNote = 1){
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
		}else{
			SleepDelay = %toPlay%
			SleepDelay *= %DefaultTempo%
			Sleep, %SleepDelay%
		}
	}
return