#Include ..\Utilities\FSR_Entry.ahk

/**
 * 
 * @param {Svaner} App 
 * @param {signal} flights 
 * @param {signal} selectDate 
 * @param {signal} bringForwardTime 
 */
DaySchedule(App, flights, selectDate, bringForwardTime) {
    flightCount := computed(flights, new => getFlightCount(new))
    getFlightCount(flights) {
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
            "Trip No.      ",
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

    handleEntry(*) {
        selectedFlights := []
        checkedRows := App["type:ListView"].getCheckedRowNumbers()

        for (row in checkedRows) {
            selectedFlights.Push(flights.value[row])
        }

        FSR_Entry.USE(selectedFlights, bringForwardTime.value)

        MsgBox("已完成FedEx 预订录入，请抽检以确保准确！", "FedexScheduledReservations")
    }

    render() {
        App.AddGroupBox("x270 @align[y]:guide h450 w670")
        App.AddText("xp+10 yp-1 h25 w280", "  Scheduled Flights on {1},  Total Resv: {2}", [selectDate, flightCount]).setFont("Bold")
        App.AddListView(options, columnDetails, flights)
        App.AddCheckbox("vcheck-all Checked h25 y+10", "全选")
        App.AddButton("x+10 Default", "开始录入").onClick(handleEntry)
        shareCheckStatus(App["check-all"], App["type:ListView"])
    }

    return render()
}