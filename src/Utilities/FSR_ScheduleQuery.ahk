class FSR_ScheduleQuery {
	static createFmtSchdJSON(schdPDF) {
		pdfToText := A_ScriptDir "\vendor\pdftotext.exe"
		tempOutput := A_Temp "\schd_output.txt"

		RunWait('"' pdfToText '" -raw "' schdPDF '" "' tempOutput '"', , "Hide")

		schdTxt := FileRead(tempOutput, "utf-8")
		FileDelete(tempOutput)

		if (!schdTxt.includes("FEDERAL EXPRESS PILOT HOUSING SCHEDULE")) {
			return false
		}

		regex := "^\d+/\d+.*\d+/\d+$"

		res := ""
		loop parse schdTxt, "`n" {
			if (RegExMatch(A_LoopField, regex)) {
				res .= A_LoopField "`n"
			}
		}
		res := RTrim(res, "`n")

		rawSchd := res.split("`n")
		schd := []
		daySchd := Map()
		curDate := ""
		for (line in rawSchd) {
			splittedLine := line.split(" ")

			if (splittedLine.Length == 14) {
				if (daySchd.Capacity > 0) {
					schd.Push(daySchd)
				}

				ciDate := splittedLine[2]
				curDate := schdPDF.split("\")
				                  .at(-1)
				                  .toLower()
				                  .replaceThese([".pdf", "hotel-can-"], "")
				                  .split("-")[1] . ciDate.replace("/", "")
				daySchd := Map(curDate, [])
				splittedLine.RemoveAt(2, 2)
			}

			flightInfo := Map(
				"tripNum", splittedLine[1],
				"roomQty", splittedLine[2],
				"inbound", splittedLine[4] . splittedLine[5],
				"ibDate", ciDate,
				"ETA", splittedLine[6],
				"stayHours", splittedLine[7],
				"obDate", splittedLine[12],
				"ETD", splittedLine[8],
				"outbound", splittedLine[9] . splittedLine[10]
			)

			daySchd[curDate].Push(flightInfo)
		}

		schd.Push(daySchd)

		if (FileExist(APP_DATA_DIR "\fmt-schd.json")) {
			FileDelete(APP_DATA_DIR "\fmt-schd.json")
		}
		FileAppend(JSON.stringify(schd), APP_DATA_DIR "\fmt-schd.json", "utf-8")

		MsgBox("Schedule 已读取", POPUP_TITLE, "4096 T1 iconi")
		
		return true
	}

	static loadSchdJSON(date) {
		date := FormatTime(date, "yyyyMMdd")

		if (!FileExist(APP_DATA_DIR "\fmt-schd.json")) {
			MsgBox("Schedule 未找到，请先读入", POPUP_TITLE, "4096 T2 icon!")
			return []
		}

		schd := JSON.parse(FileRead(APP_DATA_DIR "\fmt-schd.json"))
		for (day in schd) {
			if (day.has(date)) {
				return day[date]
			}
		}

		Msgbox("超出 Schedule 文件日期范围，选中日期无数据。", POPUP_TITLE, "4096 T3 icon!")
		return []
	}
}
