#SingleInstance Force
#NoEnv
;------------------------------------ Main Buttons ----------------------------------------;

SettingsButton:
	Gui,SettingsGui:Show,w200 h200, Settings
return

NewButton:
	Gui,NewSong:Show,w400 h500, New Song
return

DeleteSongButton:
	MsgBox, 4, Confirm action, Are you sure you wish to delete the following song: %HighlightedSong%? (This will delete all data related to this song),
	IfMsgBox Yes
	{
		SelectedFile := A_WorkingDir "\Songs\" HighlightedSong ".ahk"
		if FileExist(SelectedFile)
		{
			FileRecycle, %SelectedFile%
		}

		AdjustData := []
		Loop, read, Data.csv
		{
			AddEntry := true
			Loop, parse, A_LoopReadLine, `,
			{
				if (A_LoopField == HighlightedSong)
					AddEntry := false
			}
			if (AddEntry == true)
				AdjustData.Push(A_LoopReadLine)
		}
		datalen := AdjustData.Length()
		FileDelete, Data.csv
		FileContent =
		Loop %datalen%
			{
				if (A_Index != datalen)
					FileContent .= AdjustData[A_Index] . "`n"
				Else
					FileContent .= AdjustData[A_Index]
			}
		FileAppend, %FileContent%, Data.csv
		GoSub, ReloadSongs
	}
return

OpenEditorButton:
	Data := []
	Loop, read, Data.csv
	{
		Loop, parse, A_LoopReadLine, `,
		{
			Data.Push(A_LoopField)
		}
	}
	DataLen := Data.Length()
	Temp := 0
	Check := 0
	Loop %DataLen%
		{
			if (Data[A_Index] == HighlightedSong)
				{
					Temp := Data[A_Index+1]
					Temp := StrReplace(Temp, " ","")
					Plays := Data[A_Index+2]
					Check := Data[A_Index+3]
					break
				}	
		}
	if (HighlightedSong != "")
	{	
		Gui,EditAhk:Show,w400 h500,Edit Ahk
		SelectedFile := A_WorkingDir "\Songs\" HighlightedSong ".ahk"
		output := ""
		Loop, read, Songs\%HighlightedSong%.ahk
			output .= A_LoopReadLine . "`n"
		GuiControl,EditAhk:,EditSongCode, %output%
		GuiControl,EditAhk:,NewSongTitle, % HighlightedSong
		GuiControl,EditAhk:ChooseString,TempoModifier, % Temp
		GuiControl,EditAhk:,EnableDelayCounter, % Check
	}
return

EditAhkOk:
	Gui, Submit, Nohide
	if (NewSongTitle != HighlightedSong)
		{
			SelectedFile := A_WorkingDir "\Songs\" HighlightedSong ".ahk"
			if FileExist(SelectedFile)
			{
				NewPath := A_WorkingDir "\Songs\" NewSongTitle ".ahk"
				FileMove, %SelectedFile%, %NewPath%, 1
			}
		}
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

	newEntry := NewSongTitle "," TempoModifier ","  Plays "," EnableDelayCounter
	toWrite .= newEntry
	FileDelete, Data.csv
	FileAppend, %toWrite%, Data.csv
	SelectedFile := A_WorkingDir "\Songs\" NewSongTitle ".ahk"
	if FileExist(SelectedFile)
	{
		if (output != EditSongCode)
		{
			FileDelete, %SelectedFile%
			FileAppend, %EditSongCode%, %SelectedFile%
		}
	}
	GuiControl, EditAhk:, NewSongTitle,
	GuiControl, EditAhk:, EditSongCode,
	Gui, EditAhk:Hide
	Gosub, ReloadSongs
return

EditAhkCancel:
	GuiControl, EditAhk:, NewSongTitle,
	GuiControl, EditAhk:, EditSongCode,
	Gui, EditAhk:Hide
return

RefreshButton:
	Gosub, ReloadSongs
return

TogglePlay:
	StopSong := false
	WinActivate, Guild Wars 2
	Gosub, ParseSong
return

ToggleStop:
	StopSong := true
	Gui, Show,,GW2AhkPlayer
	Gosub, RefreshPlayers
return

ControlsButton:
	Gui,ControlsExplanation:Show,w200 h150,Controls
return

DiscordLinkButton:
	Run, https://discord.gg/CP2VFhnx7y
return

;------------------------------------ Settings buttons ----------------------------------------;
CalibrateMouseButton:
	Gui,MouseCalibrationGui:Show,w721 h500,Mouse Calibration
return

CalibrateMouseOKButton:
	Gosub, CalibrateMouse
return

SettingsSaveButton:
	Gui, Submit, Nohide
	Data := []
	Loop, read, Config.txt
		{
			Data.Push(A_LoopReadLine)
		}
	DataLen := Data.Length()
	FileDelete, Config.txt
	toAppend := ""
	Loop %DataLen%
		{
			entry := Data[A_Index]
			if (InStr(entry,"EnableClicks"))
			{
				newline := "EnableClicks," ClicksSetting "`n"
				toAppend .= newline
			}
			else if (InStr(entry,"OctaveDelay"))
			{
				newline := "OctaveDelay," OctaveDelay "`n"
				toAppend .= newline
			}
			else if (InStr(entry,"AlwaysOnTop"))
			{
				newline := "AlwaysOnTop," AlwaysOnTop "`n"
				toAppend .= newline
			}
			else if (InStr(entry,"IsTransparent"))
			{
				newline := "IsTransparent," IsTransparent "`n"
				toAppend .= newline
			}
			else
			{
				if (A_Index = DataLen)
					newline := entry
				else
					newline := entry "`n"
				toAppend .= newline
			}
		}
	ClicksEnabled := ClicksSetting
	Delay := OctaveDelay
	
	FileAppend, %toAppend%, Config.txt
	Reload
return

OctaveDelayVariableExplanation:
	Gui,OctaveDelayVariableExplanation:Show,w200 h150,Octave Delay Explanation
return

MouseModeExplanation:
	Gui,MouseModeExplanation:Show,w200 h150,Mouse Mode Explanation
return

AlwaysOnTopExplanation:
	Gui,AlwaysOnTopExplanation:Show,w200 h150,AlwaysOnTop Explanation
return

TransparencyExplanation:
	Gui,TransparencyExplanation:Show,w200 h150,Transparency Explanation
return

;------------------------------------ New Song Buttons ----------------------------------------;

TempoExplanation:
	Gui,TempoExplanation:Show,w200 h150,Tempo Explanation
return

Descriptionxplanation:
	Gui,DescriptionExplanation:Show,w200 h150,Description Explanation
return

OctaveDelayExplanation:
	Gui,OctaveDelayExplanation:Show,w200 h150,Octave Delay Explanation
return

NewSongOkButton:
	Gui, Submit, Nohide
	;remove newline and comma characters for the csv file
	NewSongTitle := StrReplace(NewSongTitle, "`n", " ")
	NewSongTitle := StrReplace(NewSongTitle, ",", " ")

	NewPath := A_WorkingDir "\Songs\" NewSongTitle ".ahk"
	FileAppend, %SongCode%, %NewPath%
	newEntry := "`n" NewSongTitle "," TempoModifier ",0," EnableDelayCounter
	FileAppend, %newEntry%, Data.csv

	;Refresh GUI
	Gui, NewSong:Submit
	Gui, NewSong:Destroy
	Gosub, NewNewSongGUI
	msgbox, Done!
	HasSelectedFile := false
	Gosub, ReloadSongs
return