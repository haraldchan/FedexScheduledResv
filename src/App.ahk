#Include Utilities\FSR_ScheduleQuery.ahk
#Include Components\date-cal.ahk
#Include Components\schedule-reader.ahk
#Include Components\day-schedule.ahk

App(App) {
    bringForwardTime := signal(config.read("bringForwardTime"))
    effect(bringForwardTime, new => config.write("bringForwardTime", new))

    selectedDate := signal(config.read("lastSelectDate"))
    effect(selectedDate, new =>
        App["check-all"].Value := true
        config.write("lastSelectDate", new)
        flights.set(FSR_ScheduleQuery.loadSchdJSON(selectedDate.value))
    )

    flights := signal(FSR_ScheduleQuery.loadSchdJSON(selectedDate.value))

    render() {
        App.AddText("vguide x10", "
        (
            快捷键及对应功能：
            
            Enter:     开始录入
            F12:       强制停止脚本
        )"
        )
        ScheduleReader(App, flights, selectedDate)
        DateCal(App, selectedDate, bringForwardTime)
        DaySchedule(App, flights, selectedDate, bringForwardTime)
    }

    return render()
}