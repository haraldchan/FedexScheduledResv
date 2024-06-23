DaySchedule(App, flights, selectDate, bringForwardTime) {
    isCheckedAll := signal(true)
    effect(isCheckedAll, new => 
        App.getCtrlByName("checkAllBtn").value := new
    )

    columnDetails := {
        keys: [
            "tripNum",
            "roomQty",
            "inbound",
            "ibDate",
            "ETA",
            "stayHours",
            "obDate",
            "ETD",
            "outbound",
        ],
        titles: [
            "Trip No.  ",
            "Qty",
            "Arr. Flight",
            "Arr. Date",
            "Arr. Time",
            "Stay Hours",
            "Dep. Date",
            "Dep. Time",
            "Dep. Flight",
        ],
    }

    options := {
        lvOptions: "Checked Grid xp+5 yp+25 w640 h380",
        itemOptions: "Check"
    }

    handleCheckAll(ctrl, _) {
        isCheckedAll.set(ctrl.value)
        LV := App.getCtrlByType("ListView")

        LV.Modify(0, isCheckedAll.value = true ? "Check" : "-Check")
    }

    handleItemCheck(LV, item, isChecked) {
        isCheckedAll.set(LV.getCheckedRowNumbers().Length = LV.GetCount())
    }

    handleEntry() {
        selectedFlights := []
        checkedRows := App.getCtrlByType("ListView").getCheckedRowNumbers()

        for row in checkedRows {
            selectedFlights.Push(flights.value[row])
        }

        if (!WinExist("ahk_class SunAwtFrame")) {
            Msgbox("Opera 未启动...", popupTitle, "T5")
            return
        }
        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        WinMaximize "ahk_class SunAwtFrame"
        WinActivate "ahk_class SunAwtFrame"
        BlockInput true

        for line in selectedFlights {
            loop line["roomQty"] {
                FSR_Entry.USE(line, bringForwardTime.value)
            }
        }

        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
        BlockInput false
        MsgBox("已完成FedEx 预订录入，请抽检以确保准确！", "FedexScheduledReservations")
    }

    return (
        App.AddGroupBox("x270 yp-265 h450 w670"),
        App.AddReactiveText("xp+10 yp-1 h25 w250", "  Scheduled Flights on {1} ", selectDate).setFont("Bold"),
        App.AddReactiveListView(options, columnDetails, flights,,["ItemCheck", handleItemCheck]),
        App.AddCheckbox("vcheckAllBtn Checked h25 y+10", "全选")
           .OnEvent("Click", handleCheckAll),
        App.AddButton("x+10 Default", "开始录入").OnEvent("Click", (*) => handleEntry())
    )
}