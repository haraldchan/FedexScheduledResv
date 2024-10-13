DateCal(App, selectDate, bringForwardTime) {
    timeMap := Map(
        "09:00", 9,
        "10:00", 10,
        "11:00", 11,
        "12:00", 12,
        "13:00", 13,
    )

    bftChosen() {
        bft := timeMap.values()
        for t in bft {
            if (t = bringForwardTime.value) {
                return A_Index
            }
        }

        return 2
    }

    return (
        App.AddGroupBox("h250 w250 x10", " 2. 选择指定日期及预留时间 ").SetFont("Bold"),
        ; Bring forward time
        App.AddDropDownList("vtoNextDropdown w80 x20 yp+30 Choose" . bftChosen(), timeMap.keys())
           .OnEvent("Change", (ctrl, _) => bringForwardTime.set(timeMap[ctrl.Text])),
        App.AddText("x+5 h25 0x200", "点前到达将提前一天留房。"),
        ; Date
        App.AddMonthCal("8 x20 y+10", selectDate.Value)
           .OnEvent("Change", (ctrl, _) => selectDate.set(ctrl.Value))
    )
}
