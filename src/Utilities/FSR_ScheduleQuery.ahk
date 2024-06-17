class FSR_ScheduleQuery {
	static flightInfoItems := [
		"tripNum",
		"roomQty",
		"flightIn1",
		"flightIn2",
		"ibDate",
		"ETA",
		"stayHours",
		"obDate",
		"ETD",
		"flightOut1",
		"flightOut2"
	]

	static getQueryDateFlights(schedule, date) {
		Xl := ComObject("Excel.Application")
		try {
			schdBook := Xl.Workbooks.Open(schedule)
		} catch Error as err {
			msgbox(err.Message)
			return []
		} 
		

		row := 4
		dateQuery := (FormatTime(date, "MM/dd"))
		sheetCount := schdBook.Worksheets.Count
		inboundFlights := []

		; find query sheet
		loop sheetCount {
			curSheet := schdBook.Worksheets(Format("Sheet{1}", A_Index))
			if (curSheet.Cells(3, 1).Text = dateQuery) {

				; push each inbound as a Map to inboundFlights(array)
				lastRow := curSheet.Cells(curSheet.Rows.Count, "A").End(-4162).Row
				loop (lastRow - 3) {
					flightInfoMap := Map()
					for item in this.flightInfoItems {
						flightInfoMap[item] := curSheet.Cells(row, A_Index).Text
					}
					flightInfoMap["inbound"] := flightInfoMap["flightIn1"] . flightInfoMap["flightIn2"]
					flightInfoMap["outbound"] := flightInfoMap["flightOut1"] . flightInfoMap["flightOut2"]

					inboundFlights.Push(flightInfoMap)
					row++
				}
			}
		}

		Xl.Quit()

		return inboundFlights
	}
}