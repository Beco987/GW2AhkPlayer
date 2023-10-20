#SingleInstance Force
#NoEnv
;------------------------------- Controls ------------------------------;
F1::
	StopSong := false
	Gosub, ParseSong
return

F2::
	pause, toggle
return

F3::
	StopSong := true
	Gui, Show,,GW2AhkPlayer
	Gosub, RefreshPlayers
return

F4::
	ExitApp
return

F10::
	DefaultTempo += 0.05
return

F11::
	DefaultTempo -= 0.05
return