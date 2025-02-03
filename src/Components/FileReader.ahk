FileReader(App, xlFile, jsonFile) {
    xlsPath := signal(xlFile)

    handleFileSelect() {
        App.Opt("+OwnDialogs")
        selectFile := FileSelect(3, , "请选择 Schedule 文件")
        
        setPath(selectFile)
    }

    handleFileDrop(GuiObj, GuiCtrlObj, FileArray, X, Y, *) {
        if (FileArray.Length > 1) {
            FileArray.RemoveAt[1]
        }

        setPath(FileArray[1])
    }

    setPath(file) {
        SplitPath file,,, &ext
        if (ext != "xls" || ext != "xlsx") {
            MsgBox("请选择Excel文件")
            return 
        }
        
        xlsPath.set(file)
        config.write("schdPath", xlsPath.value)
        if (FileExist(jsonFile)) {
            FileDelete(jsonFile)            
        }
        FSR_ScheduleQuery.createSnapshotJson(file, jsonFile)
    }

    openXlFile() {
        if (FSR_ScheduleQuery.isSaving = true) {
            MsgBox("缓存生成中，请稍后再试。", popupTitle, "T2")
            return
        }

        Run(xlsPath.value)
    }

    return (
        ; add filedrop event
        App.OnEvent("DropFiles", handleFileDrop),
        ; ; main groupbox
        App.AddGroupBox("r4 w250 x10 y+10", " 1. 选择 Schedule 文件" ).SetFont("Bold"),
        App.AddText("x20 yp+25 ", "(直接拖动文件到此处即可)"),
        App.AddReactiveEdit("vschdPath ReadOnly h25 w230 x20 yp+20", "{1}", xlsPath),

        App.AddButton("h25 w110 y+10", "选择文件")
           .OnEvent("Click", (*) => handleFileSelect()),

        App.AddButton("h25 w110 x+10", "打开文件")
           .OnEvent("Click", (*) => openXlFile())
    )
}