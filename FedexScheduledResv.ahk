#Requires AutoHotkey v2.0
#SingleInstance Force
#Include lib/index.ahk
#Include src/App.ahk

; Initializing configuration
appName := "Fedex Scheduled Reservations"
APP_DATA_DIR := A_AppData . "\FSR"
CONFIG := useJsonConfig("./fsr.config.json", "fsr.config.json", APP_DATA_DIR)
VERSION := CONFIG.read("version")
POPUP_TITLE := appName . " " . version
WIN_GROUP := ["ahk_class SunAwtFrame"]
config := useJsonConfig(
	"./fsr.config.json",
	"fsr.config.json",
)

; initial config
CoordMode "Mouse", "Screen"
TraySetIcon A_ScriptDir "\Assets\FSRTray.ico"

; SvanerApp
FSR :=  Svaner({
	gui: {
		title: POPUP_TITLE
	},
	font: {
		name: "微软雅黑"
	},
	events: {
		close: (*) => utils.quitApp(appName, POPUP_TITLE, WIN_GROUP),
	},
	; devOpt: {
	; 	border: true
	; }
})

App(FSR)
FSR.Show()

; hotkeys setup
F12:: utils.cleanReload(WIN_GROUP)