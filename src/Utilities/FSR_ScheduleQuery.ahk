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

	static loadSchedule(date, jsonFile, xlFile) {
		if (FileExist(jsonFile)) {
			return this.loadSnapshotJson(jsonFile, date)
		} else {
			SetTimer(() => this.createSnapshotJson(xlFile, jsonFile), -100)
			return this.loadXlFile(xlFile, date)
		}
	}

	static loadXlFile(xlFile, date) {
		Xl := ComObject("Excel.Application")
		try {
			schdBook := Xl.Workbooks.Open(xlFile)
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

	static createSnapshotJson(xlFile, jsonFile) {
		Xl := ComObject("Excel.Application")

		try {
			schdData := Xl.Workbooks.Open(xlFile)
		} catch Error as err {
			msgbox(err.Message)
			return []
		}

		schdSheetAmount := schdData.Sheets.Count
		sheet := 1
		schdRow := 4

		scheduleMonthly := []

		loop schdSheetAmount {
			sheetIndex := Format("Sheet{1}", sheet)
			schdData.Worksheets(sheetIndex).Activate
			ciDate := schdData.ActiveSheet.Cells(3, 1).Text
			lastRow := schdData.ActiveSheet.Cells(schdData.ActiveSheet.Rows.Count, "A").End(-4162).Row
			scheduledDaily := []

			if (ciDate = "") {
				schdData.Close()
				break
			}

			; fullDate => yyyyMMdd
			fullDate := StrSplit(ciDate, "/")[1] < A_MM
				? Format("{1}{2}", A_Year + 1, StrReplace(ciDate, "/", ""))
				: Format("{1}{2}", A_Year, StrReplace(ciDate, "/", ""))

			loop (lastRow - 3) {
				flight := Map()
				loop 11 {
					for item in this.flightInfoItems {
						flight[item] := schdData.Worksheets(sheetIndex).Cells(schdRow, A_Index).Text
					}
					scheduledDaily.Push(flight)
					schdRow++
				}

				scheduleMonthly.Push(Map(fullDate, scheduledDaily))

				sheet++
				schdRow := 4
			}
		}
		
		if (FileExist(jsonFile)) {
			FileDelete(jsonFile)
		}
		FileAppend(JSON.stringify(scheduleMonthly), jsonFile, "UTF-8")
		Xl.Quit()
	}

	static loadSnapshotJson(jsonFile, date) {
		snapshot := JSON.parse(FileRead(jsonFile))
		return snapshot[date]
	}

}