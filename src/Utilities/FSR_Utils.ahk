getDaysActual(hoursAtHotel) {
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

getBringForwardTime(timeString) {
    switch timeString {
        case "09:00":
            return 9
        case "10:00":
            return 10
        case "11:00":
            return 11
        case "12:00":
            return 12
        case "13:00":
            return 13
        default:
            return 10
    }
}