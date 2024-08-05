DaySchedule(App, flights, selectDate, bringForwardTime) {

    flightCount := computed(flights, new => getFlightCount(new))
    getFlightCount(flights){
        if (flights.Length = 0 || flights[1].values().every(val => val = "Loading...")) {
            return
        }

        flightCount := 0

        for flight in flights {
            flightCount += flight["roomQty"]
        }

        return flightCount
    }

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
        App.AddReactiveText("xp+10 yp-1 h25 w350", "  Scheduled Flights on {1},  Total Resv: {2}", [selectDate, flightCount]).setFont("Bold"),
        App.AddReactiveListView(options, columnDetails, flights),
        App.AddCheckbox("vcheckAllBtn Checked h25 y+10", "全选"),
        App.AddButton("x+10 Default", "开始录入").OnEvent("Click", (*) => handleEntry()),
        shareCheckStatus(
            App.getCtrlByName("checkAllBtn"),
            App.getCtrlByType("ListView")
        )
    )
}