#Include "./Utilities/FSR_Entry.ahk"
#Include "./Utilities/FSR_ScheduleQuery.ahk"
#Include "./Components/DaySchedule.ahk"
#Include "./Components/FileReader.ahk"
#Include "./Components/DateCal.ahk"

App(App) {
    jsonFile := A_ScriptDir . "\src\Data\snapshot.json"

    loadingPlaceholder := Map(
        "tripNum", "Loading...",
        "roomQty", "Loading...",
        "inbound", "Loading...",
        "ibDate", "Loading...",
        "ETA", "Loading...",
        "stayHours", "Loading...",
        "obDate", "Loading...",
        "ETD", "Loading...",
        "outbound", "Loading...",
    )

    ; /** value @type {array} */
    flights := signal([loadingPlaceholder])

    ; /** value @type {number} */
    bringForwardTime := signal(config.read("bringForwardTime"))
    effect(bringForwardTime, new => config.write("bringForwardTime", new))

    ; /** value @type {Date} */
    selectedDate := signal(config.read("lastSelectDate"))
    effect(selectedDate, new =>
        config.write("lastSelectDate", new)
        flights.set([loadingPlaceholder])
        flights.set(
            FSR_ScheduleQuery.loadSchedule(
                selectedDate.value,
                jsonFile,
                config.read("schdPath")
            )
        )
    )

    onLoad() {
        flights.set(
            FSR_ScheduleQuery.loadXlFile(
                config.read("schdPath"),
                selectedDate.value
            )
        )
        App.getCtrlByType("ListView").ModifyCol(2, 40)
    }

    return (
        App.AddText(, "
            (
                快捷键及对应功能：

                Enter:     开始录入
                F12:       强制停止脚本
            )"
        ),
        FileReader(App, config.read("schdPath"), jsonFile),
        DateCal(App, selectedDate, bringForwardTime),
        DaySchedule(App, flights, selectedDate, bringForwardTime),
        onLoad()
    )
}