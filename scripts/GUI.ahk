#SingleInstance Force
#NoEnv
Gui, Margin, 0, 0
Gui, Font,, Verdana
Gui, Font, c000000
;Gui,Add,Picture,x0 y0 w400 h490,Images\bg.png

;------------------------------- Main GUI ------------------------------;
WinSet, TransColor, ffffff

Gui,Add,Picture,x0 y0 w400 h75,Images\Title.png
Gui,Add,Button,x380 y0 w20 h20 gSettingsButton,⚙
Gui Add, ListView, x10 y75 w290 h305 +LV0x4000 gMyListView HwndHLV -Multi AltSubmit, Name                               |Plays|Date
LV_ModifyCol(3,58)
Gui, Add, Picture, x310 y85 w80 h80 gNewButton, Images\Page.png
Gui Add, Text, x310 y165 w80 h15 Center, New Song
Gui, Add, Picture, x310 y185 w80 h80 gDeleteSongButton, Images\Salvage Kit.png
Gui Add, Text, x310 y265 w80 h15 Center, Delete Song
Gui, Add, Picture, x310 y285 w80 h80 gOpenEditorButton, Images\Tool Kit.png
Gui Add, Text, x324 y365 w72 h15, Edit Song
Gui, Add, Button, x300 y365 w20 h20 gRefreshButton, ↻

Gui, Add, Picture, x10 y390 w80 h80 gTogglePlay, Images\Fa.png
Gui Add, Text, x10 y470 w80 h15 Center, Play
Gui, Add, Picture, x120 y400 w60 h60 gToggleStop, Images\Stop.png
Gui Add, Text, x110 y470 w80 h15 Center, Stop
Gui, Add,Picture, x210 y390 w80 h80 gDiscordLinkButton, Images\Discord.png
Gui Add, Text, x210 y470 w80 h15 Center, Discord
Gui, Add, Picture, x310 y390 w80 h80 gControlsButton, Images\Return.png
Gui Add, Text, x310 y470 w80 h15 Center, Controls
if (OnTopEnabled)
    Gui, +AlwaysOnTop
Gui, Show,,GW2AhkPlayer
;Window Transparency
if (TransparentEnabled)
    WinSet, Transparent, 150, GW2AhkPlayer

;------------------------------- Settings GUI ------------------------------;
Gui,SettingsGui:Add,Text,x0 y3 w80 h20, Octave Delay :
Gui,SettingsGui:Add,Button,x170 y0 w20 h20 gOctaveDelayExplanation,?
Gui,SettingsGui:Add,Edit,x100 y0 w50 h20 vOctaveDelay,%Delay%
Gui,SettingsGui:Add,CheckBox, x0 y30 w170 h20 vClicksSetting Checked%ClicksEnabled%, Enable Mouse Playing Mode?
Gui,SettingsGui:Add,Button,x170 y30 w20 h20 gMouseModeExplanation,?
Gui,SettingsGui:Add,Button, x0 y55 w100 h40 gCalibrateMouseButton, Calibrate Mouse Mode
Gui,SettingsGui:Add,CheckBox, x0 y100 w170 h20 vAlwaysOnTop Checked%OnTopEnabled%, Enable Always On Top?
Gui,SettingsGui:Add,Button,x170 y100 w20 h20 gAlwaysOnTopExplanation,?
Gui,SettingsGui:Add,CheckBox, x0 y120 w170 h20 vIsTransparent Checked%TransparentEnabled%, Enable Transparency?
Gui,SettingsGui:Add,Button, x170 y120 w20 h20 gTransparencyExplanation,?
Gui SettingsGui:Add,Button, x0 y160 w200 h40 gSettingsSaveButton, Save

;---------------------- Mouse Calibration Tutorial GUI ---------------------;
Gui, MouseCalibrationGui:Font, s11
Gui, MouseCalibrationGui:Add, Text, x0 y0, During the mouse calibration you'll be asked to click each note and octave swap key one by one.
Gui, MouseCalibrationGui:Add, Picture, x0 y30, Images/Mouse Calibration.png
Gui, MouseCalibrationGui:Add, Text, x0 y150, ToolTips will appear telling you which note to click on. This information will be stored in the Mouse Calibration.txt file.
Gui, MouseCalibrationGui:Add, Picture, x0 y180, Images/Mouse Calibration Tooltip.png
Gui, MouseCalibrationGui:Add, Text, x0 y250, Continue to follow the ToolTips until a message box pops up that says "Done!".
Gui, MouseCalibrationGui:Add, Text, x0 y265, Every time you resize your Guild Wars 2 window you'll need to redo this calibration.
Gui, MouseCalibrationGui:Add, Picture, x0 y280, Images/Mouse Calibration Done.png
Gui, MouseCalibrationGui:Add,Button, x310 y450 w100 h50 gCalibrateMouseOkButton, Ok


;------------------------------- New Song GUI ------------------------------;
;Adds to list view in the following format -> NewSongTitle | NumberPlayers | TempoModifier | SongDescription
Gui,NewSong:Add,Text,x0 y3 w50 h20,Title :
Gui,NewSong:Add,Edit,x50 y0 w325 h20 vNewSongTitle,
Gui,NewSong:Add,Text,x0 y20 w100 h20,Tempo Modifier :
Gui,NewSong:Add,DropDownList,x100 y20 w100 h100 vTempoModifier, -10|-9|-8|-7|-6|-5|-4|-3|-2|-1|0||1|2|3|4|5|6|7|8|9|10
Gui,NewSong:Add,Button,x80 y20 w20 h20 gTempoExplanation,?
Gui,NewSong:Add,CheckBox,x210 y23 w170 h20 vEnableDelayCounter, Enable Octave Swap Delays
Gui,NewSong:Add,Button,x380 y20 w20 h20 gOctaveDelayExplanation,?
Gui,NewSong:Add,Text,x0 y43 w400 h20 Center,Paste Abc/Ahk Code Below :
Gui,NewSong:Add,Edit,x0 y60 w400 h377 vSongCode,
Gui,NewSong:Add,Text,x0 y445 w400 h20 Center, Ahk Files can also be copied/pasted into the Songs folder to import them.
Gui,NewSong:Add,Button,x100 y460 w200 h40 gNewSongOkButton Center,Add song

;------------------------------- Edit AHK GUI ------------------------------;
Gui,EditAhk:Add,Text,x0 y3 w50 h20,Title :
Gui,EditAhk:Add,Edit,x30 y0 w150 h20 vNewSongTitle,
Gui,EditAhk:Add,Text,x200 y2 w100 h20,Tempo Modifier :
Gui,EditAhk:Add,DropDownList,x290 y0 w100 h100 vTempoModifier, -10|-9|-8|-7|-6|-5|-4|-3|-2|-1|0||1|2|3|4|5|6|7|8|9|10
Gui,EditAhk:Add,CheckBox,x130 y23 w400 h20 vEnableDelayCounter, Enable Octave Swap Delays?
Gui,EditAhk:Add,Text,x0 y50 w400 h20 Center,Song Code
Gui,EditAhk:Add,Edit,x0 y70 w400 h390 vEditSongCode,
Gui,EditAhk:Add,Button,x0 y470 w200 h30 gEditAhkOk,Ok
Gui,EditAhk:Add,Button,x200 y470 w200 h30 gEditAhkCancel,Cancel

;------ Tempo Explanation GUI ------;
Gui,TempoExplanation:Add,Text,x0 y0 w200 h150, Midis don't always import with the correct tempo, so with this you can change the tempo that the song will start with. Each -1/-+1 will decrease/increase the tempo by 5 percent. For example, -4 will slow the song down by 20 percent, while +4 will speed up the song by 20 percent. You can always change this value with the data editor.

;------ Description Explanation GUI ------;
Gui,DescriptionExplanation:Add,Text,x0 y0 w200 h100, This is where you can type out a helpful description of the song. For example, you might want to write down which instruments are used in it as well as their order.

;------ Octave Explanation GUI ------;
Gui,OctaveDelayExplanation:Add,Text,x0 y0 w200 h150, Enabling this adds a forced delay between octave swaps that are too close together and will trigger the octave bug. This can always be changed later using the edit button in the main menu.

;------ Controls Explanation GUI ------;
Gui,ControlsExplanation:Add,Text,x0 y0 w200 h150, F1 - Plays the selected song`nF2 - Pause/Play the song`nF3 - Stops the song`nF4 - Exits the application`nF10 - Reduces tempo by 5 percent`nF11 - Increases tempo by 5 percent

;------ Octave Explanation GUI ------;
Gui,OctaveDelayExplanation:Add,Text,x0 y0 w200 h150, Sets a delay between octave swaps to avoid triggering the octave bug. Usually this should be set to around 2x your average in-game ping.

;------ Mouse Mode Explanation GUI ------;
Gui,MouseModeExplanation:Add,Text,x0 y0 w200 h150, Enables you to use the Clicks for notes instead of the keyboard. Enable if you'd like to be able to type while playing a song. THIS WILL TAKE CONTROL OF YOUR MOUSE WHILE PLAYING A SONG

;------ AlwaysOnTop Explanation GUI ------;
Gui,AlwaysOnTopExplanation:Add,Text,x0 y0 w200 h150, Sets the application to always be visible. This is useful if you want to play Guild Wars 2 in Fullscreen.

;------ Transparency Explanation GUI ------;
Gui,TransparencyExplanation:Add,Text,x0 y0 w200 h150, Sets the application to be transparent. You may like this if you play Guild Wars 2 in Fullscreen.

Winset, Region, w300 h500

