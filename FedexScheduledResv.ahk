#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "./lib/LibIndex.ahk"
#Include "./src/App.ahk"
CoordMode "Mouse", "Screen"
TraySetIcon A_ScriptDir . "\src\Assets\FSRTray.ico"

; Initializing configuration
appName := "Fedex Scheduled Reservations"
version := "4.0.0"
popupTitle := appName . " " . version
winGroup := ["ahk_class SunAwtFrame"]
config := useConfigJSON(
	"./fsr.config.json",
	"fsr.config.json",
)

; Gui
FSR := Gui(, popupTitle)
FSR.SetFont(, "微软雅黑")
FSR.OnEvent("Close", (*) => utils.quitApp(appName, popupTitle, winGroup))

App(FSR)

FSR.Show()

; hotkeys setup
F12:: utils.cleanReload(winGroup)