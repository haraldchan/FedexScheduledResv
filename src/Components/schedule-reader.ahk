/**
 * @param {Svaner} App 
 * @param {signal} flights 
 * @param {signal} selectedDate
 */
ScheduleReader(App, flights, selectedDate) {
    schdPath := signal("")

    setPath(file) {
        if (!file.toLower().includes("pdf")) {
            MsgBox("请选择正确的 PDF 文件", POPUP_TITLE, "4096 T2 icon!")
            return
        }

        schdPath.set(file)
        success := FSR_ScheduleQuery.createFmtSchdJSON(file)
        if (success) {
            flights.set(FSR_ScheduleQuery.loadSchdJSON(selectedDate.value))
        }
    }

    handleFileSelect(*) {
        App.Opt("+OwnDialogs")
        selectFile := FileSelect(3, , "请选择 Schedule 文件")

        setPath(selectFile)
    }

    handleFileOpen(*) {
        Run(schdPath.value)
    }

    handleFileDrop(GuiObj, GuiCtrlObj, FileArray, X, Y, *) {
        if (FileArray.Length > 1) {
            FileArray.RemoveAt[1]
        }
        setPath(FileArray[1])
    }


    render() {
        StackBox(
            App, {
                font: { options: "bold" },
                groupbox: {
                    title: " 选择 Schedule 文件 ",
                    options: "x10 y+10 w250 h120 Section"
                }
            },
            () => [
                App.AddText("x20 yp+25", "(直接拖动文件到此处即可)"),
                App.AddEdit("x20 yp+20 h25 w230 ReadOnly", "{1}", schdPath),
                App.AddButton("yp+30 h25 w110", "选择文件").onClick(handleFileSelect),
                App.AddButton("x+10 h25 w110", "打开文件").onClick(handleFileOpen),
            ]
        )
    }

    onMount() {
        App.gui.OnEvent("DropFiles", handleFileDrop)
    }

    return (
        render(),
        onMount()
    )
}