class FSR_Entry {
	static USE(inboundFlightLine, bringForwardTime) {
		; { date reformatting
		actualYear := (StrSplit(inboundFlightLine["ibDate"], "/")[1] < A_MM)
			? A_Year + 1
			: A_Year
		schdCiDate := Format("{1}{2}{3}", actualYear, StrSplit(inboundFlightLine["ibDate"], "/")[1], StrSplit(inboundFlightLine["ibDate"], "/")[2])
		schdCoDate := Format("{1}{2}{3}", actualYear, StrSplit(inboundFlightLine["obDate"], "/")[1], StrSplit(inboundFlightLine["obDate"], "/")[2])
		daysActual := this.getDaysActual(inboundFlightLine["stayHours"])

		pmsCiDate := (StrSplit(inboundFlightLine["ETA"], ":")[1]) < bringForwardTime
			? DateAdd(schdCiDate, -1, "days")
			: schdCiDate
		pmsCoDate := schdCoDate
		comment := Format("{Text}RM INCL 1BBF TO CO,Hours@Hotel: {1}={2}day(s), ActualStay: {3}-{4}",
			inboundFlightLine["stayHours"],
			daysActual,
			schdCiDate,
			schdCoDate
		)
		pmsNts := DateDiff(pmsCoDate, pmsCiDate, "days")
		; reformat to match pms date format
		schdCiDate := FormatTime(schdCiDate, "MMddyyyy")
		schdCoDate := FormatTime(schdCoDate, "MMddyyyy")
		pmsCiDate := FormatTime(pmsCiDate, "MMddyyyy")
		pmsCoDate := FormatTime(pmsCoDate, "MMddyyyy")
		; }
		this.openBooking()

		this.profileEntry(inboundFlightLine["inbound"], inboundFlightLine["tripNum"])

		this.dateTimeEntry(pmsCiDate, pmsCoDate, inboundFlightLine["ETA"], inboundFlightLine["ETD"])

		this.commentIbdTripEntry(comment, inboundFlightLine["inbound"], inboundFlightLine["tripNum"])

		this.moreFieldsEntry(schdCiDate, schdCoDate, inboundFlightLine["ETA"], inboundFlightLine["ETD"], inboundFlightLine["inbound"], inboundFlightLine["outbound"])

		if (daysActual < pmsNts) {
			this.dailyDetailsEntry(daysActual)
		}

		this.saveBooking()
	}

	static openBooking() {
		Sleep 1000
		utils.waitLoading()
		Send "!e"
		utils.waitLoading()
	}

	static saveBooking() {
		CoordMode "Pixel", "Screen"
		Send "!o"
		utils.waitLoading()
		loop {
			Sleep 250
			if (PixelGetColor(610, 330) = "0x99B4D1") {
				break
			}
			if (A_Index = 20) {
				WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
				BlockInput false
				MsgBox("已停止。")
				utils.waitLoading()
			}
		}
		Send "!o"
		utils.waitLoading()
		Send "{Down}"
		utils.waitLoading()
	}

	static profileEntry(flightIn, tripNumber, initX := 467, initY := 201) {
		MouseMove 467, 221
		utils.waitLoading()
		Click
		utils.waitLoading()
		MouseMove 442, 284
		utils.waitLoading()
		Click "Down"
		MouseMove 214, 289
		utils.waitLoading()
		Click "Up"
		utils.waitLoading()
		Send "{Backspace}"
		utils.waitLoading()
		Send Format("{Text}{1}  {2}", flightIn, tripNumber)
		utils.waitLoading()
		MouseMove 594, 414
		utils.waitLoading()
		Send "!o"
		utils.waitLoading()
		MouseMove 812, 507
		utils.waitLoading()
		Click
		utils.waitLoading()
	}

	static dateTimeEntry(checkin, checkout, ETA, ETD, initX := 323, initY := 506) {
		; fill-in checkin/checkout
		MouseMove 345, initY - 150 ; 332, 356
		utils.waitLoading()
		Click 1
		utils.waitLoading()
		Send "!c"
		utils.waitLoading()
		Send Format("{Text}{1}", checkin)
		utils.waitLoading()
		MouseMove initX + 2, initY - 108 ; 325, 398
		utils.waitLoading()
		Click
		utils.waitLoading()
		MouseMove initX + 338, initY + 37 ; 661, 543
		utils.waitLoading()
		Click
		MouseMove initX + 313, initY + 37 ; 636, 543
		utils.waitLoading()
		Click
		MouseMove initX + 312, initY + 37 ; 635, 543
		utils.waitLoading()
		Click
		utils.waitLoading()
		Click
		utils.waitLoading()
		MouseMove 345, initY - 101 ; 335, 405
		utils.waitLoading()
		Click 1
		utils.waitLoading()
		Send "!c"
		utils.waitLoading()
		Send Format("{Text}{1}", checkout)
		utils.waitLoading()
		Send "{Enter}"
		utils.waitLoading()
		loop 5 {
			Send "{Esc}"
			utils.waitLoading()
		}
		; fill in ETA & ETD
		MouseMove 320, 599
		utils.waitLoading()
		Click 3
		utils.waitLoading()
		Send Format("{Text}{1}", ETA)
		utils.waitLoading()
		Send "{Tab}"
		utils.waitLoading()
		MouseMove 454, 599
		utils.waitLoading()
		Click 3
		utils.waitLoading()
		Send Format("{Text}{1}", ETD)
		Send "{Tab}"
		utils.waitLoading()
	}

	static commentIbdTripEntry(comment, flightIn, tripNumber, initX := 622, initY := 589) {
		; select all and re-enter comment
		MouseMove initX, initY ; 622, 596
		utils.waitLoading()
		Click "Down"
		MouseMove initX + 518, initY + 36 ; 1140, 605
		utils.waitLoading()
		Click "Up"
		utils.waitLoading()
		Send "{Backspace}"
		utils.waitLoading()
		Send comment
		utils.waitLoading()
		; fill-in new flight and trip
		MouseMove initX + 307, initY - 35 ; 929, 554
		utils.waitLoading()
		Click 3
		utils.waitLoading()
		Send Format("{Text}{1}  {2}", flightIn, tripNumber)
		utils.waitLoading()
	}

	static moreFieldsEntry(sCheckin, sCheckout, ETA, ETD, flightIn, flightOut, initX := 236, initY := 333) {
		MouseMove initX, initY ; 236, 333
		utils.waitLoading()
		Click
		utils.waitLoading()
		MouseMove 680, 460
		utils.waitLoading()
		Click 2
		utils.waitLoading()
		Send Format("{Text}{1}", flightIn)
		utils.waitLoading()
		loop 2 {
			Send "{Tab}"
			utils.waitLoading()
		}
		Send Format("{Text}{1}", sCheckin)
		Sleep 100
		Send "{Tab}"
		utils.waitLoading()
		Send Format("{Text}{1}", ETA)
		utils.waitLoading()
		MouseMove 917, 465
		utils.waitLoading()
		Click 2
		utils.waitLoading()
		Send Format("{Text}{1}", flightOut)
		utils.waitLoading()
		loop 2 {
			Send "{Tab}"
			utils.waitLoading()
		}
		utils.waitLoading()
		Send Format("{Text}{1}", sCheckout)
		utils.waitLoading()
		Send "{Tab}"
		utils.waitLoading()
		Send Format("{Text}{1}", ETD)
		utils.waitLoading()
		MouseMove initX + 605, initY + 347 ; 841, 680
		utils.waitLoading()
		Click
		utils.waitLoading()
	}

	static dailyDetailsEntry(daysActual, initX := 372, initY := 524) {
		MouseMove initX, initY ; 372, 524
		utils.waitLoading()
		Click
		utils.waitLoading()
		Send "!d"
		utils.waitLoading()
		loop daysActual {
			Send "{Down}"
			utils.waitLoading()
		}
		Send "!e"
		utils.waitLoading()
		loop 4 {
			Send "{Tab}"
			utils.waitLoading()
		}
		Send "{Text}NRR"
		utils.waitLoading()
		Send "!o"
		loop 3 {
			Send "{Esc}"
			utils.waitLoading()
		}
		utils.waitLoading()
		Send "!o"
		utils.waitLoading()
		loop 5 {
			Send "{Esc}"
			utils.waitLoading()
		}
		utils.waitLoading()
	}

	static getDaysActual(hoursAtHotel) {
		h := StrSplit(hoursAtHotel, ":")[1]
		m := StrSplit(hoursAtHotel, ":")[2]
		if (h < 24) {
			return 1
		} else if (Mod(h, 24) = 0 && m = 0) {
			return Integer(h / 24)
		} else if (h >= 24 || m != 0) {
			return Integer(h / 24 + 1)
		}
	}
}