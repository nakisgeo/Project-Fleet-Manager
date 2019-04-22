// ReportTabForm_Methods.prg
#Using System.IO
#Using System.Data
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Collections


PARTIAL CLASS ReportTabForm INHERIT System.Windows.Forms.Form
	EXPORT cReportUID AS STRING
	EXPORT cReportName AS STRING
	EXPORT oDTItemCategories AS DataTable
	EXPORT oDTReportItems AS DataTable
	//PRIVATE aFocusControls AS ArrayList
	EXPORT lEnableControls AS LOGIC
	EXPORT lisInEditMode as LOGIC
	
	PRIVATE decimalSeparator AS STRING
	PRIVATE groupSeparator AS STRING
	PRIVATE aCalculatedItemUID AS ArrayList
	PRIVATE aUsedInCalculations AS ArrayList
	PRIVATE aFormula AS ArrayList

	PRIVATE cNumbers := "0123456789" AS STRING
	PRIVATE lGmtDiffControlsCreated AS LOGIC
	PRIVATE nConsecutiveNumber AS INT

	EXPORT oDTFMData AS DataTable
	
	PRIVATE cPreviousData := "" AS STRING
	PRIVATE cTempDocsDir as String
	PRIVATE oDTPreviousData as DataTable
	// Table
	PRIVATE lTableMode := false AS LOGIC
	PRIVATE iRowCount := 0, iColumnCount := 0 as INT
	PRIVATE oMyTable AS DoubleBufferedTableLayoutPanel
	
	PRIVATE DateTime_ItemUID := "" AS STRING
	PRIVATE Latitude_ItemUID := "" AS STRING
	PRIVATE Longitude_ItemUID := "" AS STRING

	Export cMyPackageUID := "" as String

METHOD ReportTabForm_OnLoad() AS VOID
	oSoftway:ReadFormSettings_DevExpress(SELF, NULL, oMainForm:alForms, oMainForm:alData)
	IF SELF:Size:Height < 50 .or. SELF:Size:Width < 100
		SELF:Size := System.Drawing.Size{950, 750}
	END
RETURN


METHOD ReportTabForm_OnShown() AS VOID
	//SELF:aFocusControls := ArrayList{}

	SELF:aCalculatedItemUID := ArrayList{}
	SELF:aUsedInCalculations := ArrayList{}
	SELF:aFormula := ArrayList{}
	SELF:oDTPreviousData := DataTable{}
	SELF:oDTPreviousData:Columns:Add("ItemUID")
	SELF:oDTPreviousData:Columns:Add("Data")
	SELF:decimalSeparator := numberFormatInfo:NumberDecimalSeparator
	SELF:groupSeparator := numberFormatInfo:NumberGroupSeparator
	
	SELF:cTempDocsDir := Application.StartupPath + "\TempDocs"
	SELF:CreateDirectory(SELF:cTempDocsDir)
	SELF:ClearDirectory(self:cTempDocsDir,0)

	IF SELF:CategoryExists("0")
		SELF:FillTab("0", "")
	ELSE
		SELF:tabControl_Report:TabPages:RemoveAt(0)
	ENDIF

	/*LOCAL cStatement AS STRING
	cStatement:="SELECT DISTINCT FMItemCategories.CATEGORY_UID, FMItemCategories.Description, FMItemCategories.SortOrder"+;
				" FROM FMItemCategories"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMReportItems ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
				" AND FMReportItems.REPORT_UID="+SELF:cReportUID+;
				" ORDER BY CATEGORY_UID"
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	FOREACH oRow AS DataRow IN oDT:Rows*/
	FOREACH oRow AS DataRow IN SELF:oDTItemCategories:Rows
		SELF:FillTab(oRow["CATEGORY_UID"]:ToString(), oRow["Description"]:ToString())
	NEXT
	//// Focus the 1st Control of the TabPage
	//SendKeys.Send("{TAB}")

	//LOCAL oControl AS Control
	//oControl := (Control)SELF:aFocusControls[0]
	//oControl:Focus()

	IF ! SELF:lEnableControls
		SELF:ReadOnlyControls(false)
		SELF:PutControlValues()
	ENDIF
	IF SELF:ReportMainMenu:Visible == TRUE
		SELF:ControlBox := false
	ENDIF
	
RETURN

METHOD createNewReportSave(cSubmit := "0" as String) AS VOID
TRY
	IF DateTime_ItemUID == ""
		MessageBox.Show("Can not create a report with no Date Time element.")
	ENDIF
	
	//LOCAL cVesselUID := oMainForm:GetVesselUID AS STRING
	//Get the DateTime
	//LOCAL cDateGMT := "" , cGmtDiff := "" AS STRING
	/*LOCAL cGmtDiff := "" AS STRING*/
	LOCAL oControlDatePickerGMT := SELF:GetControl("DatePickerGMT", SELF:DateTime_ItemUID) AS Control
	LOCAL oNumericTextBoxGMT := (TextBox)SELF:GetControl("NumericTextBoxGMT", SELF:DateTime_ItemUID) AS TextBox
	
	IF oControlDatePickerGMT == NULL .or. oNumericTextBoxGMT == null
			//cDateGMT :=((System.Windows.Forms.DateTimePicker)oControlDatePickerGMT):Value:ToString("yyyy-MM-dd HH:mm") 
			//cGmtDiff := oNumericTextBoxGMT:Text 
	//ELSE 
			MessageBox.Show("Can not create a report with no Date Time element.")
			RETURN
	ENDIF
	//LOCAL cTextBoxMultiline := SELF:GetAllMultilines() AS STRING


		// Insert FMDataPackages entry
		/*local cStatement:="INSERT INTO FMDataPackages (VESSEL_UNIQUEID, REPORT_UID, DateTimeGMT, GmtDiff, MSG_UNIQUEID, Memo, Matched, Username) VALUES"+;
					" ("+cVesselUID+", "+self:cReportUID+", '"+cDateGMT+"', "+cGmtDiff+","+;
					" 0, '"+oSoftway:ConvertWildcards(cTextBoxMultiline, FALSE)+"' , "+cSubmit+", '"+oUser:Username+"' )" as String
		IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			//ErrorBox("Cannot insert FMDataPackages entry for Vessel="+cVesselName)
			
			RETURN
		ENDIF*/
		//LOCAL cPackageUID := oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "FMDataPackages", "PACKAGE_UID") AS STRING
		SELF:saveNormalValues(SELF:cMyPackageUID)
		SELF:saveMultilineFields(SELF:cMyPackageUID) //added 23/12/15
		IF cSubmit:Equals("1")
			oMainForm:submitCaseToManager(SELF:cMyPackageUID)
		ENDIF
		oMainForm:Fill_TreeList_Reports()
		
		SELF:Close()
		
CATCH exc AS Exception
	
END TRY		

RETURN

METHOD ReadOnlyControls(isEditable as LOGIC) AS VOID
	LOCAL cName as STRING
	self:lisInEditMode := isEditable 
	FOREACH oTabPage AS System.Windows.Forms.TabPage IN SELF:tabControl_Report:TabPages
		FOREACH oControl AS Control IN oTabPage:Controls
			//IF ! oControl:Name:StartsWith("Label")
			//	oControl:Enabled := lEnable
			//ENDIF
		IF oControl:HasChildren
			FOREACH oSecControl AS Control IN oControl:Controls
			///////////////////////////////////////////////////////////////////////////////////
			cName := oSecControl:Name
			DO CASE
			CASE cName:StartsWith("Label")
				LOOP
			CASE cName:StartsWith("Table")
				LOOP
			CASE cName:StartsWith("File")
				LOOP
			CASE cName:StartsWith("DatePicker")
				((System.Windows.Forms.DateTimePicker)oSecControl):Enabled := isEditable

			////////////////////////////////////////////////////////////////////////////////
			//ADDED BY KIRIAKOS
			////////////////////////////////////////////////////////////////////////////////
			//CASE cName:StartsWith("DatePickerNull")
			//	((DateTimePickerNULL)oSecControl):Enabled := isEditable
			////////////////////////////////////////////////////////////////////////////////
			//ADDED BY KIRIAKOS
			////////////////////////////////////////////////////////////////////////////////

			CASE cName:StartsWith("TextBox")
				((System.Windows.Forms.TextBox)oSecControl):ReadOnly := !isEditable

			CASE cName:StartsWith("NumericTextBox")
				((System.Windows.Forms.TextBox)oSecControl):ReadOnly := !isEditable

			CASE cName:StartsWith("CheckBox")
				((System.Windows.Forms.CheckBox)oSecControl):Enabled := isEditable

			// Lat/Long:
			CASE cName:StartsWith("GeoDeg")
				((System.Windows.Forms.TextBox)oSecControl):ReadOnly := !isEditable

			CASE cName:StartsWith("GeoMin")
				((System.Windows.Forms.TextBox)oSecControl):ReadOnly := !isEditable

			CASE cName:StartsWith("GeoSec")
				((System.Windows.Forms.TextBox)oSecControl):ReadOnly := !isEditable

			CASE cName:StartsWith("GeoNSEW")
				((System.Windows.Forms.ComboBox)oSecControl):Enabled := isEditable
				
			CASE cName:StartsWith("ComboBox")
				((System.Windows.Forms.ComboBox)oSecControl):Enabled := isEditable
			ENDCASE
			////////////////////////////////////////////////////////////////////////////
			NEXT
		ELSE
///////////////////////////////////////////////////////////////////////////////////
			cName := oControl:Name
			DO CASE
			CASE cName:StartsWith("Label")
				LOOP
			CASE cName:StartsWith("Table")
				LOOP
			CASE cName:StartsWith("File")
				LOOP
				
			CASE cName:StartsWith("DatePicker")
				((System.Windows.Forms.DateTimePicker)oControl):Enabled := isEditable

			////////////////////////////////////////////////////////////////////////////////
			//ADDED BY KIRIAKOS
			////////////////////////////////////////////////////////////////////////////////
			//CASE cName:StartsWith("DatePickerNull")
			//	((DateTimePickerNULL)oControl):Enabled := isEditable
			////////////////////////////////////////////////////////////////////////////////
			//ADDED BY KIRIAKOS
			////////////////////////////////////////////////////////////////////////////////

			CASE cName:StartsWith("TextBox")
				((System.Windows.Forms.TextBox)oControl):ReadOnly := !isEditable

			CASE cName:StartsWith("NumericTextBox")
				((System.Windows.Forms.TextBox)oControl):ReadOnly := !isEditable

			CASE cName:StartsWith("CheckBox")
				((System.Windows.Forms.CheckBox)oControl):Enabled := isEditable

			// Lat/Long:
			CASE cName:StartsWith("GeoDeg")
				((System.Windows.Forms.TextBox)oControl):ReadOnly := !isEditable

			CASE cName:StartsWith("GeoMin")
				((System.Windows.Forms.TextBox)oControl):ReadOnly := !isEditable

			CASE cName:StartsWith("GeoSec")
				((System.Windows.Forms.TextBox)oControl):ReadOnly := !isEditable

			CASE cName:StartsWith("GeoNSEW")
				((System.Windows.Forms.ComboBox)oControl):Enabled := isEditable
				
			CASE cName:StartsWith("ComboBox")
				((System.Windows.Forms.ComboBox)oControl):Enabled := isEditable
			ENDCASE
			////////////////////////////////////////////////////////////////////////////
			endif
		NEXT
	NEXT
RETURN


METHOD CategoryExists(cCatUID AS STRING) AS LOGIC
	LOCAL oRows := SELF:oDTReportItems:Select("CATEGORY_UID="+cCatUID) AS DataRow[]
RETURN (oRows:Length > 0)


METHOD FillTab(cCatUID AS STRING, cDescription AS STRING) AS VOID
	LOCAL oTabPage AS System.Windows.Forms.TabPage
	//LOCAL nFirstControl := -1 AS INT

	IF cCatUID == "0"
		SELF:nConsecutiveNumber := 0
		// Get the 1st Tab
		oTabPage := SELF:tabPage_General
		oTabPage:Click += System.EventHandler{self,@Tab_must_focus()}
		oTabPage:Name := "0"
	ELSE
		// Add Tab
		oTabPage := System.Windows.Forms.TabPage{}
        //oTabPage:Location := System.Drawing.Point{4, 22}
        oTabPage:Name := cCatUID
        oTabPage:Text := cDescription
        oTabPage:Padding := System.Windows.Forms.Padding{3}
        oTabPage:AutoScroll := TRUE
        oTabPage:Size := System.Drawing.Size{776, 536}
        oTabPage:TabIndex := Convert.ToInt32(cCatUID)
		oTabPage:Click += System.EventHandler{self,@Tab_must_focus()}
        oTabPage:UseVisualStyleBackColor := TRUE

        SELF:tabControl_Report:Controls:Add(oTabPage)
	ENDIF
	oTabPage:Enter += System.EventHandler{ SELF, @TabPage_Enter() }

	// Get Category Items
	/*LOCAL cStatement AS STRING
	cStatement:="SELECT *"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" WHERE REPORT_UID="+SELF:cReportUID+;
				" AND CATEGORY_UID="+cCatUID+;
				" ORDER BY ITEM_UID"
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable*/
	LOCAL nX := 250, nY := 15 AS INT
	LOCAL nLabelX := 0 AS INT
	LOCAL TabIndex := 0 AS INT
	//FOREACH oRow AS DataRow IN oDT:Rows
	LOCAL oRows := SELF:oDTReportItems:Select("REPORT_UID="+SELF:cReportUID+" AND CATEGORY_UID="+cCatUID, "ItemNo") AS DataRow[]
	FOREACH oRow AS DataRow IN oRows
		SELF:AddTabControls(oTabPage, oRow, nX, nY, nLabelX, TabIndex)
		SELF:FillUsedInCalculationsArray(oRow)
	NEXT
	IF oMyTable <> NULL
			oMyTable:Visible := TRUE
			oMyTable := NULL
			iRowCount := 0 
			iColumnCount := 0 
			lTableMode := false 
	ENDIF
	
RETURN


METHOD FillUsedInCalculationsArray(oRow AS DataRow) AS VOID
	LOCAL cFormula, cItemID, c AS STRING

	cFormula := oRow["CalculatedField"]:ToString()
	IF cFormula == ""
		RETURN
	ENDIF
	LOCAL cFormulaSaved := cFormula AS STRING

	LOCAL oRows AS DataRow[]
	LOCAL n, nLen := cFormula:Length - 1, nPos AS INT
	nPos := cFormula:IndexOf("ID")
	cItemID := ""
	// (ID230 / ID 203 ) * 24
	WHILE nPos <> -1
		FOR n:=nPos + 2 UPTO nLen
			c := cFormula:Substring(n, 1)
			IF c == " "
				LOOP
			ENDIF
			IF ! SELF:cNumbers:Contains(c)
				EXIT
			ENDIF
			cItemID += c
		NEXT
		cItemID := cItemID:Trim()

		oRows := SELF:oDTReportItems:Select("REPORT_UID="+SELF:cReportUID+" AND ItemNo="+cItemID)
		IF oRows:Length == 1
			SELF:aCalculatedItemUID:Add(oRow["ITEM_UID"]:ToString())
			SELF:aUsedInCalculations:Add(oRows[1]:Item["ITEM_UID"]:ToString())
			SELF:aFormula:Add(cFormulaSaved)
			//wb("aCalculatedItemUID="+oRow["ITEM_UID"]:ToString()+CRLF+"aUsedInCalculations="+oRows[1]:Item["ITEM_UID"]:ToString()+CRLF+"aFormula="+cFormulaSaved, "")
		ELSE
			ErrorBox("Cannot Locate ItemID="+cItemID)
		ENDIF

		IF n <= nLen
			cFormula := cFormula:Substring(n + 1):Trim()
		ELSE
			cFormula := ""
		ENDIF
		//wb(cFormula, cItemID)
		cItemID := ""
		nPos := cFormula:IndexOf("ID")
		nLen := cFormula:Length - 1
	ENDDO
RETURN



METHOD addControlToTableLayout(oControl AS Control) AS logic
		///oMyTable:SuspendLayout()
		IF iRowCount == 0 .and. iColumnCount == 0 // Einai to prwto meta to header
			oMyTable:RowCount := 2
			LOCAL iPercent AS INT
			iPercent := Convert.ToInt32(100/oMyTable:RowCount)
			//MessageBox.Show(iPercent:ToString())
			oMyTable:RowStyles:Add(System.Windows.Forms.RowStyle{System.Windows.Forms.SizeType.Percent, ((Single) iPercent)})
			iRowCount++
			oMyTable:Controls:Add(oControl, iColumnCount, iRowCount)
			iColumnCount ++
			///oMyTable:ResumeLayout()
			RETURN true
		ELSEIF  iColumnCount < oMyTable:ColumnCount
			//LOCAL iPercent AS INT
			//iPercent := Convert.ToInt32(100/oMyTable:RowCount)
			//MessageBox.Show(iPercent:ToString())
			//oMyTable:RowStyles:Add(System.Windows.Forms.RowStyle{System.Windows.Forms.SizeType.Percent, ((Single) iPercent)})
			oMyTable:Controls:Add(oControl, iColumnCount, iRowCount)
			iColumnCount ++
			///oMyTable:ResumeLayout()
			RETURN false
		ELSEIF iColumnCount == oMyTable:ColumnCount
			oMyTable:RowCount := oMyTable:RowCount+1
			iRowCount++
			iColumnCount := 0
			//LOCAL iPercent AS INT
			//iPercent := Convert.ToInt32(100/oMyTable:RowCount)
			//MessageBox.Show(iPercent:ToString())
			//oMyTable:RowStyles:Add(System.Windows.Forms.RowStyle{System.Windows.Forms.SizeType.Percent, ((Single) iPercent)})
			oMyTable:Controls:Add(oControl, iColumnCount, iRowCount)
			iColumnCount ++
			///oMyTable:ResumeLayout()
			RETURN true
		ENDIF
		//oMyTable:Size := System.Drawing.Size{oMyTable:Width, oMyTable:Height+30}
RETURN true
	
METHOD amItheOnlyMultilineInThisLine(iAmInColumn as INT) AS LOGIC
	LOCAL /*iCountControlsAlreadyInLine,*/ iCount/*,iLocalCountRows*/ AS INT
	LOCAL oControl AS TextBox
	
		FOR iCount := 0 UPTO iColumnCount-1 STEP 1
			TRY
				/*IF iAmInColumn == oMyTable:ColumnCount
						iLocalCountRows := iRowCount+1
				ELSE
						iLocalCountRows := iRowCount
				ENDIF*/
				oControl := (TextBox)oMyTable:GetControlFromPosition(iCount,iRowCount)
				oControl:Multiline := TRUE
				//MessageBox.Show("Found another multiline at:("+iRowCount:ToString()+","+iCount:ToString()+")",iAmInColumn:ToString())
				RETURN false
			CATCH exException AS Exception
				
			END
		NEXT		
RETURN true

METHOD addControlToTable(oRow AS DataRow,  nY REF INT, nTabIndex REF INT) as Void
	//MessageBox.Show("Add Control To table.")
	LOCAL cItemUID := oRow["ITEM_UID"]:ToString() AS STRING
	LOCAL cItemType := oRow["ItemType"]:ToString() AS STRING
	LOCAL cItemTypeValues := oRow["ItemTypeValues"]:ToString() AS STRING
	LOCAL cCalculatedField := oRow["CalculatedField"]:ToString() AS STRING
	LOCAL cIsDD := oSoftway:LogicToString(oRow["IsDD"]) AS STRING
	//LOCAL cNotNumbered := oSoftway:LogicToString(oRow["NotNumbered"]) AS STRING
	LOCAL Mandatory := oSoftway:LogicToString(oRow["Mandatory"]) AS STRING
	//LOCAL iPrevCountRows := oMyTable:RowCount as INT
	
	DO CASE
		CASE cItemType == "X"
        LOCAL oComboBox := System.Windows.Forms.ComboBox{} AS System.Windows.Forms.ComboBox
        // 
        // ComboBox
        // 
        oComboBox:DropDownStyle := System.Windows.Forms.ComboBoxStyle.DropDownList
        oComboBox:FormattingEnabled := TRUE
        oComboBox:Location := System.Drawing.Point{1, 1}
        oComboBox:Name := "ComboBox" + cItemUID
        oComboBox:Size := System.Drawing.Size{80, 17}
		oComboBox:Dock := DockStyle.Fill
		oComboBox:TabIndex := TabIndex++
		oComboBox:Text := oRow["ItemName"]:ToString()
		//////////////////////////////////////////////////////////
		//	Adde By Kiriakos In order to Support the Week Control
		//////////////////////////////////////////////////////////
		IF cItemTypeValues:ToUpper() == "WEEK"
			cItemTypeValues := cWeekValues	
		ENDIF
		//////////////////////////////////////////////////////////
		//	Adde By Kiriakos In order to Support the Week Control
		//////////////////////////////////////////////////////////
		cItemTypeValues := cItemTypeValues:TrimEnd(';')
		LOCAL lFoundDefault := FALSE AS LOGIC
		LOCAL cDefaultItem := "" AS STRING
		LOCAL cItems := cItemTypeValues:Split(';') AS STRING[]
		FOREACH cItem AS STRING IN cItems
			IF cItem:Contains("<ID")
				cItem := cItem:Substring(0,cItem:indexOf("<ID"))
			ENDIF
			IF cItem:Contains("<D>")
				cItem := cItem:Replace("<D>","")
				cDefaultItem := cItem
				lFoundDefault := TRUE
			ENDIF
			
			oComboBox:Items:Add(cItem:Trim())
		NEXT
		IF lFoundDefault
			oComboBox:SelectedItem := cDefaultItem
		ENDIF
		lFoundDefault := FALSE
		cDefaultItem := "" 
        oComboBox:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
		if SELF:addControlToTableLayout(oComboBox)
			nY += 32
		ENDIF
	CASE cItemType == "D" .and. cIsDD == "1"
		LOCAL oButtonFile := System.Windows.Forms.Button{} AS System.Windows.Forms.Button
		//
		//	Due Date
		//
		oButtonFile:Location := System.Drawing.Point{1, 1}
        oButtonFile:Name := "DD" + cItemUID
        oButtonFile:Size := System.Drawing.Size{128, 20}
        oButtonFile:TabIndex := TabIndex++
		oButtonFile:Dock := DockStyle.Fill
        oButtonFile:Text := "Add Due Date"
        oButtonFile:UseVisualStyleBackColor := TRUE
        oButtonFile:Click += System.EventHandler{ SELF, @DueDate_Button_Clicked() }
		oButtonFile:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
		oButtonFile:Tag := Mandatory 
		if SELF:addControlToTableLayout(oButtonFile)
			nY += 32
		ENDIF
		
	CASE cItemType == "D" .and. cIsDD == "0"
		LOCAL oDatePicker := System.Windows.Forms.DateTimePicker{} AS System.Windows.Forms.DateTimePicker
        // 
        // DatePicker
        // 
		/////////////////////////////////////////////////
		//CHANGED BY KIRIAKOS
		/////////////////////////////////////////////////
        //oDatePicker:CustomFormat := "dd/MM/yyyy HH:mm"
        oDatePicker:CustomFormat := " "
        oDatePicker:Format := System.Windows.Forms.DateTimePickerFormat.Custom
        oDatePicker:Location := System.Drawing.Point{1, 1}
        oDatePicker:Name := "DatePicker" + cItemUID
        oDatePicker:Size := System.Drawing.Size{128, 20}
        oDatePicker:TabIndex := TabIndex++
		oDatePicker:Dock := DockStyle.Fill
		//oDatePicker:Value := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC)
		oDatePicker:Value := Datetime.Now
        oDatePicker:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
        oDatePicker:MouseDown += System.Windows.Forms.MouseEventHandler{ SELF, @Control_MouseDown() }
		oDatePicker:ValueChanged += System.EventHandler{ SELF, @Control_ValueChanged() }
		oDatePicker:Tag := Mandatory
        //oTabPage:Controls:Add(oDatePicker)
		if SELF:addControlToTableLayout(oDatePicker)
			nY += 32
		ENDIF
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//						ADDED BY KIRIAKOS		
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//CASE cItemType == "E" .and. cIsDD == "0"
	//	LOCAL oDatePickerNull := DateTimePickerNull{} AS DateTimePickerNull
 //       // 
 //       // DatePicker
 //       // 
 //       oDatePickerNull:CustomFormat := "dd/MM/yyyy HH:mm"
 //       oDatePickerNull:Format := System.Windows.Forms.DateTimePickerFormat.Custom
 //       oDatePickerNull:Location := System.Drawing.Point{1, 1}
 //       oDatePickerNull:Name := "DatePickerNull" + cItemUID
 //       oDatePickerNull:Size := System.Drawing.Size{128, 20}
 //       oDatePickerNull:TabIndex := TabIndex++
	//	oDatePickerNull:Dock := DockStyle.Fill
	//	//oDatePicker:Value := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC)
	//	oDatePickerNull:Value := Datetime.Now
 //       oDatePickerNull:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
	//	oDatePickerNull:Tag := Mandatory
 //       //oTabPage:Controls:Add(oDatePicker)
	//	IF SELF:addControlToTableLayout(oDatePickerNull)
	//		nY += 32
	//	ENDIF
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//						ADDED BY KIRIAKOS		
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	CASE cItemType == "N"
		LOCAL oNumericTextBox := System.Windows.Forms.TextBox{} AS System.Windows.Forms.TextBox
        // 
        // NumericTextBox
        // 
        oNumericTextBox:Location := System.Drawing.Point{1, 1}
        oNumericTextBox:Name := "NumericTextBox" + cItemUID
        oNumericTextBox:Size := System.Drawing.Size{56, 20}
		oNumericTextBox:Dock := DockStyle.Fill
        oNumericTextBox:TextAlign := System.Windows.Forms.HorizontalAlignment.Right
		IF cCalculatedField <> ""
			oNumericTextBox:ReadOnly := TRUE
	        oNumericTextBox:BackColor := System.Drawing.Color.FromArgb(((System.Int32)(((System.Byte)(255)))), ((System.Int32)(((System.Byte)(255)))), ((System.Int32)(((System.Byte)(192)))))
		ELSE
	        oNumericTextBox:TabIndex := TabIndex++
	        oNumericTextBox:BackColor := Color.White
		ENDIF
        oNumericTextBox:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
        oNumericTextBox:KeyDown += System.Windows.Forms.KeyEventHandler{ SELF, @NumericControl_KeyDown() }
        oNumericTextBox:Validating += System.ComponentModel.CancelEventHandler{ SELF, @NumericControl_Validating() }
        oNumericTextBox:Validated += System.EventHandler{ SELF, @NumericControl_Validated() }
		oNumericTextBox:Tag := Mandatory
        if SELF:addControlToTableLayout(oNumericTextBox)
			nY += 32
		ENDIF
	CASE cItemType == "T"
		LOCAL oTextBox := System.Windows.Forms.TextBox{} AS System.Windows.Forms.TextBox
        // 
        // TextBox
        // 
        oTextBox:Location := System.Drawing.Point{1, 1}
        oTextBox:MaxLength := 128
        oTextBox:Name := "TextBox" + cItemUID
        oTextBox:Size := System.Drawing.Size{120, 20}
		oTextBox:Dock := DockStyle.Fill
        oTextBox:TabIndex := TabIndex++
        oTextBox:BackColor := Color.White
        oTextBox:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
		oTextBox:Tag := Mandatory
        if SELF:addControlToTableLayout(oTextBox)
			nY += 32
		ENDIF
	Case cItemType == "F"
		LOCAL oButtonFile := System.Windows.Forms.Button{} AS System.Windows.Forms.Button
		//
		//	File Uploader
		//
		oButtonFile:Location := System.Drawing.Point{1, 1}
        oButtonFile:Name := "FileUploader" + cItemUID
        oButtonFile:Size := System.Drawing.Size{56, 22}
		oButtonFile:Dock := DockStyle.Fill
        oButtonFile:TabIndex := TabIndex++
        oButtonFile:Text := "Upload"
        oButtonFile:UseVisualStyleBackColor := TRUE
        oButtonFile:Click += System.EventHandler{ SELF, @File_Button_Clicked() }
		oButtonFile:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
		oButtonFile:Tag := Mandatory
        if SELF:addControlToTableLayout(oButtonFile)
			nY += 32
		ENDIF
	
	CASE cItemType == "L"
		LOCAL cItemName := oRow["ItemName"]:ToString():Trim() AS STRING
		local oLabel := System.Windows.Forms.Label{} as System.Windows.Forms.Label
        // 
        // label
        // 
        oLabel:Location := System.Drawing.Point{1, 1}
        oLabel:Name := "Label" + cItemUID
        //oLabel:AutoSize := TRUE
        oLabel:TabIndex := 0
	    oLabel:Size := System.Drawing.Size{400, 28}
		olabel:Dock := DockStyle.Fill
		oLabel:Text := cItemName
		oLabel:Font := System.Drawing.Font{"Microsoft Sans Serif", ((Single) 10), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(161))}
        //oLabel:TextAlign := System.Drawing.ContentAlignment.MiddleRight
		oLabel:TextAlign := System.Drawing.ContentAlignment.MiddleLeft
		
		LOCAL oToolTip := System.Windows.Forms.ToolTip{} AS ToolTip
		oToolTip:IsBalloon := TRUE
		oToolTip:ShowAlways := TRUE
		oToolTip:SetToolTip(oLabel,cItemName)
		
        if SELF:addControlToTableLayout(oLabel)
			nY += 32
		ENDIF
	CASE cItemType == "M"
		LOCAL oTextBoxMultiline := System.Windows.Forms.TextBox{} AS System.Windows.Forms.TextBox
        // 
        // TextBoxMultiline
        // 
        oTextBoxMultiline:Location := System.Drawing.Point{1, 1}
        oTextBoxMultiline:Multiline := TRUE
		oTextBoxMultiline:ScrollBars := ScrollBars.Vertical
        oTextBoxMultiline:MaxLength := 32767
        oTextBoxMultiline:AcceptsReturn := TRUE
        oTextBoxMultiline:Name := "TextBoxMultiline" + cItemUID
        oTextBoxMultiline:Size := System.Drawing.Size{60, 50}
		oTextBoxMultiline:Dock := DockStyle.Fill
        oTextBoxMultiline:TabIndex := TabIndex++
        oTextBoxMultiline:BackColor := Color.White
		oTextBoxMultiline:Enter += System.EventHandler{ SELF, @TML_GotFocus() }
		oTextBoxMultiline:Leave += System.EventHandler{ SELF, @TML_LostFocus() }
		oTextBoxMultiline:Font := System.Drawing.Font{"Tahoma", ((Single) 9.75), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(161))}
        
		oTextBoxMultiline:Tag := Mandatory
		LOCAL iIncrement AS INT
		//LOCAL lReturn as LOGIC
		//MessageBox.Show((SELF:amItheOnlyMultilineInThisLine(iColumnCount)):ToString(),iColumnCount:ToString())
		
		IF SELF:amItheOnlyMultilineInThisLine(iColumnCount)
			iIncrement := 28
		ELSE
			iIncrement := 0
		ENDIF
		
        IF SELF:addControlToTableLayout(oTextBoxMultiline)
			nY += 60
		ELSE
			//MessageBox.Show(iIncrement:ToString(),(nY+iIncrement):tostring())
			nY += iIncrement
		ENDIF
		//IF nFirstControl == 0
		//	SELF:aFocusControls:Add(oTextBoxMultiline)
		//ENDIF
		
	ENDCASE
RETURN

METHOD AddTabControls(oTabPage AS System.Windows.Forms.TabPage, oRow AS DataRow, nX REF INT, nY REF INT, nLabelX REF INT, TabIndex REF INT) AS VOID
	//LOCAL TabIndex := 0 AS INT
	LOCAL cItemUID := oRow["ITEM_UID"]:ToString() AS STRING
	LOCAL cItemType := oRow["ItemType"]:ToString() AS STRING
	LOCAL cItemTypeValues := oRow["ItemTypeValues"]:ToString() AS STRING
	LOCAL cCalculatedField := oRow["CalculatedField"]:ToString() AS STRING
	LOCAL cSLAA := oSoftway:LogicToString(oRow["SLAA"]) AS STRING
	LOCAL cIsDD := oSoftway:LogicToString(oRow["IsDD"]) AS STRING
	LOCAL cNotNumbered := oSoftway:LogicToString(oRow["NotNumbered"]) AS STRING
	LOCAL Mandatory := oSoftway:LogicToString(oRow["Mandatory"]) AS STRING
	STATIC LOCAL cPreviousLabel := "" AS STRING
	STATIC LOCAL nInstance := 0 AS INT
	STATIC LOCAL cPreviousItemType AS STRING
	STATIC LOCAL cPreviousLabelSize as int
	LOCAL lSameSerieItem AS LOGIC
	//wb(cItemType+CRLF+oRow["ItemName"]:ToString(), oTabPage:Name)
	LOCAL oLabel AS System.Windows.Forms.Label
	// Table
	IF lTableMode 
		IF cSLAA == "1"
			self:addControlToTable(oRow, nY, TabIndex)
			RETURN
		ELSE
			lTableMode := FALSE
			IF oMyTable <> NULL
			oMyTable:ResumeLayout()
			oMyTable:Visible := TRUE
			//oMyTable := NULL
			ENDIF
			iRowCount := 0
			iColumnCount := 0
		ENDIF
	ENDIF
	
	IF cItemType <> "B" .AND. cSLAA <> "1" .and. cItemType <> "L" .and. cItemType <> "A" //If not checkbox or Slaa or Label or Table
		LOCAL cItemName := oRow["ItemName"]:ToString():Trim() AS STRING
		cItemName := cItemName:Replace("&", "&&")
		//Edw vazei sthn idia grammh an einai to idio onoma ektos apo to teleutaio. mono gia numeric
		IF cItemType == "N" .and. cPreviousLabel <> ""
			// Numeric field having the same description (up to Length-1 character)
			//wb(cPreviousLabel)
			IF cItemName:StartsWith(cPreviousLabel)
				nInstance++
				IF nInstance == 1
					nLabelX += 250 + 60
				ELSE
					nLabelX += 80
				ENDIF
				nX += 80
				nY -= 30
				lSameSerieItem := TRUE
			ENDIF
		ENDIF
		IF ! lSameSerieItem
			nInstance := 0
			nLabelX := 0
			nX := 250
			// consecutive number
			//SELF:CreateLabelConsecutiveNumber(oTabPage, cItemUID, nLabelX, nY)
		ENDIF

		oLabel := System.Windows.Forms.Label{}
        // 
        // label
        // 
        oLabel:Location := System.Drawing.Point{nLabelX, nY + 3}
        oLabel:Name := "Label" + cItemUID
        //oLabel:AutoSize := TRUE
        oLabel:TabIndex := 0
		IF lSameSerieItem
	        oLabel:Size := System.Drawing.Size{10, 30}
			oLabel:Text := cItemName:Substring(cItemName:Length - 1)
		ELSE
	        oLabel:Size := System.Drawing.Size{250, 30}
			IF cNotNumbered=="0"
				SELF:nConsecutiveNumber++
				oLabel:Text := SELF:nConsecutiveNumber:ToString()+". "+cItemName
			ELSE
				oLabel:Text := cItemName
			ENDIF
		ENDIF
        //oLabel:TextAlign := System.Drawing.ContentAlignment.MiddleRight
		oLabel:TextAlign := System.Drawing.ContentAlignment.TopRight
        oTabPage:Controls:Add(oLabel)
		cPreviousLabelSize := oLabel:Size:Width
		cPreviousLabel := cItemName:Substring(0, cItemName:Length - 1)
	ELSEIF cSLAA == "1" //An prepei na to valw sthn idia seira me to prohgoumeno
		LOCAL cItemName := oRow["ItemName"]:ToString():Trim() AS STRING
		//WB(nX:ToString()+"/"+nLabelX:ToString())
		LOCAL isPermitted :=  TRUE AS LOGIC
		DO CASE
			CASE cPreviousItemType == "B" .or. cPreviousItemType == "X"
				nLabelX +=cPreviousLabelSize + 90
				nX +=  90
				nY -= 30
			CASE cPreviousItemType == "N" 
				nLabelX +=cPreviousLabelSize + 65
				nX +=  65
				nY -= 30
			CASE cPreviousItemType == "F" 
				nLabelX +=cPreviousLabelSize + 65
				nX +=  65
				nY -= 30
			CASE cPreviousItemType == "T" 
				nLabelX +=cPreviousLabelSize + 130
				nX +=  130
				nY -= 30
			CASE cPreviousItemType == "D" 
				nLabelX +=cPreviousLabelSize + 135
				nX +=  135
				nY -= 30
	/////////////////////////////////////////////////////////				
	//			ADDED BY KIRIAKOS
	/////////////////////////////////////////////////////////
			//CASE cPreviousItemType == "E" 
			//	nLabelX +=cPreviousLabelSize + 135
			//	nX +=  135
			//	nY -= 30
	/////////////////////////////////////////////////////////				
	//			ADDED BY KIRIAKOS
	/////////////////////////////////////////////////////////
			CASE cPreviousItemType == "M" 
				nLabelX +=cPreviousLabelSize + 470
				nX +=  470
				nY -= 130
			OTHERWISE
				isPermitted :=  FALSE
		ENDCASE
		IF isPermitted	
			// 
			// Label
			// 
			oLabel := System.Windows.Forms.Label{}
			IF cNotNumbered=="0"
				SELF:nConsecutiveNumber++
				oLabel:Text := SELF:nConsecutiveNumber:ToString()+". "+cItemName
			ELSE
				oLabel:Text := cItemName
			ENDIF
			//WB(nX:ToString()+"/"+nLabelX:ToString()+"/"+oLabel:Text)
			oLabel:Location := System.Drawing.Point{nLabelX, nY + 3}
			oLabel:Name := "Label" + cItemUID
			//oLabel:AutoSize := TRUE
			oLabel:TabIndex := 0
			//oLabel:Size := System.Drawing.Size{250, 30}
			oLabel:AutoSize := TRUE
			oLabel:TextAlign := System.Drawing.ContentAlignment.TopRight
			oTabPage:Controls:Add(oLabel)
			cPreviousLabel := cItemName:Substring(0, cItemName:Length - 1)
			cPreviousLabelSize := oLabel:Size:Width
			//wb(cPreviousLabelSize:ToString())
			nX +=  cPreviousLabelSize
		ENDIF
	ENDIF

	//nFirstControl++

	DO CASE
	CASE cItemType == "B"
        LOCAL oCheckBox := System.Windows.Forms.CheckBox{} AS System.Windows.Forms.CheckBox
        // 
        // CheckBox
        // 
        oCheckBox:AutoSize := TRUE
        oCheckBox:Location := System.Drawing.Point{nX, nY}
        oCheckBox:Name := "CheckBox" + cItemUID
        oCheckBox:Size := System.Drawing.Size{80, 17}
        oCheckBox:TabIndex := TabIndex++
		IF lSameSerieItem
			oCheckBox:Text := oRow["ItemName"]:ToString()
		ELSE
			IF cNotNumbered=="0"
				SELF:nConsecutiveNumber++
				oCheckBox:Text := SELF:nConsecutiveNumber:ToString()+". "+oRow["ItemName"]:ToString()
			ELSE
				oCheckBox:Text := oRow["ItemName"]:ToString()
			ENDIF
		ENDIF
        oCheckBox:UseVisualStyleBackColor := TRUE
//        oCheckBox:BackColor := Color.White
        oCheckBox:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
        oCheckBox:CheckedChanged += System.EventHandler{ SELF, @CheckBox_CheckedChanged() }

		oCheckBox:Tag := Mandatory
        oTabPage:Controls:Add(oCheckBox)
		nY += 30
		//IF nFirstControl == 0
		//	SELF:aFocusControls:Add(oCheckBox)
		//ENDIF

		LOCAL cCaption := oCheckBox:Text AS STRING
		DO CASE
		CASE cCaption:ToUpper():EndsWith("OFF/ON") .or. cCaption:ToUpper():EndsWith("ON/OFF")
			cCaption := cCaption:Substring(0, cCaption:Length - 6)+" (OFF)"
			oCheckBox:Text := cCaption

		CASE cCaption:ToUpper():EndsWith("YES/NO") .or. cCaption:ToUpper():EndsWith("NO/YES")
			cCaption := cCaption:Substring(0, cCaption:Length - 6)+" (NO)"
			oCheckBox:Text := cCaption
		ENDCASE

	CASE cItemType == "X"
        LOCAL oComboBox := System.Windows.Forms.ComboBox{} AS System.Windows.Forms.ComboBox
        // 
        // ComboBox
        // 
        oComboBox:DropDownStyle := System.Windows.Forms.ComboBoxStyle.DropDownList
        oComboBox:FormattingEnabled := TRUE
        oComboBox:Location := System.Drawing.Point{nX, nY}
        oComboBox:Name := "ComboBox" + cItemUID
        oComboBox:Size := System.Drawing.Size{80, 17}
		oComboBox:TabIndex := TabIndex++
		oComboBox:Text := oRow["ItemName"]:ToString()
		
       // oComboBox:UseVisualStyleBackColor := TRUE
//        oComboBox:BackColor := Color.White
	

		// Fill ComboBox Items
		//////////////////////////////////////////////////////////
		//	Adde By Kiriakos In order to Support the Week Control
		//////////////////////////////////////////////////////////
		IF cItemTypeValues:ToUpper() == "WEEK"
			cItemTypeValues := cWeekValues	
		ENDIF
		//////////////////////////////////////////////////////////
		//	Adde By Kiriakos In order to Support the Week Control
		//////////////////////////////////////////////////////////
		
		cItemTypeValues := cItemTypeValues:TrimEnd(';')
		LOCAL cItems := cItemTypeValues:Split(';') AS STRING[]
		//For Default Values.
		LOCAL lFoundDefault := false AS LOGIC
		LOCAL cDefaultItem := "" AS STRING
		
		FOREACH cItem AS STRING IN cItems
			IF cItem:Contains("<ID")
				cItem := cItem:Substring(0,cItem:indexOf("<ID"))
			ENDIF
			IF cItem:Contains("<D>")
				cItem := cItem:Replace("<D>","")
				cDefaultItem := cItem
				lFoundDefault := TRUE
			ENDIF
			oComboBox:Items:Add(cItem:Trim())
		NEXT
		IF lFoundDefault
			oComboBox:SelectedItem := cDefaultItem
		ENDIF
		lFoundDefault := FALSE
		cDefaultItem := "" 
		
		
        oComboBox:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
        //oComboBox:CheckedChanged += System.EventHandler{ SELF, @ComboBox_CheckedChanged() }

//		oComboBox:Tag := Mandatory
        oTabPage:Controls:Add(oComboBox)
		nY += 30

	CASE cItemType == "C"
		LOCAL oGeoDeg := System.Windows.Forms.TextBox{} AS System.Windows.Forms.TextBox
        // 
        // GeoDeg
        // 
        oGeoDeg:Location := System.Drawing.Point{nX, nY}
        oGeoDeg:Name := "GeoDeg" + cItemUID
        oGeoDeg:Size := System.Drawing.Size{25, 20}
        oGeoDeg:TextAlign := System.Windows.Forms.HorizontalAlignment.Right
        oGeoDeg:TabIndex := TabIndex++
		IF oLabel:Text:Contains("Latitude")
			// 0 - 90
	        oGeoDeg:MaxLength := 2
		ELSE
			// 0 - 180
	        oGeoDeg:MaxLength := 3
		ENDIF
        oGeoDeg:BackColor := Color.White
        oGeoDeg:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
        //oGeoDeg:Validating += System.ComponentModel.CancelEventHandler{ SELF, @GeoDeg_Validating() }

		oGeoDeg:Tag := Mandatory
        oTabPage:Controls:Add(oGeoDeg)
		SELF:AddGeoLabel(nX + 25-2, nY, "°", oTabPage)

		LOCAL oGeoMin := System.Windows.Forms.TextBox{} AS System.Windows.Forms.TextBox
        // 
        // GeoMin
        // 
        oGeoMin:Location := System.Drawing.Point{nX + 35, nY}
        oGeoMin:Name := "GeoMin" + cItemUID
        oGeoMin:Size := System.Drawing.Size{20, 20}
        oGeoMin:TextAlign := System.Windows.Forms.HorizontalAlignment.Right
        oGeoMin:TabIndex := TabIndex++
		// 0 - 59
        oGeoMin:MaxLength := 2
        oGeoMin:BackColor := Color.White
        oGeoMin:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
        //oGeoMin:Validating += System.ComponentModel.CancelEventHandler{ SELF, @GeoMin_Validating() }

		oGeoMin:Tag := Mandatory
        oTabPage:Controls:Add(oGeoMin)
		SELF:AddGeoLabel(nX + 35 + 20-2, nY, "'", oTabPage)

		LOCAL oGeoSec := System.Windows.Forms.TextBox{} AS System.Windows.Forms.TextBox
        // 
        // GeoSec
        // 
        oGeoSec:Location := System.Drawing.Point{nX + 35 + 27, nY}
        oGeoSec:Name := "GeoSec" + cItemUID
        oGeoSec:Size := System.Drawing.Size{45, 20}
        oGeoSec:TextAlign := System.Windows.Forms.HorizontalAlignment.Right
        oGeoSec:TabIndex := TabIndex++
		// 0.0000 - 59.9999
        oGeoSec:MaxLength := 7
        oGeoSec:BackColor := Color.White
        oGeoSec:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
        //oGeoSec:Validating += System.ComponentModel.CancelEventHandler{ SELF, @GeoSec_Validating() }
        //oGeoSec:KeyDown += System.Windows.Forms.KeyEventHandler{ SELF, @NumericControl_KeyDown() }
        //oGeoSec:Validated += System.EventHandler{ SELF, @NumericControl_Validated() }

		oGeoSec:Tag := Mandatory
        oTabPage:Controls:Add(oGeoSec)
		SELF:AddGeoLabel(nX + 35 + 27 + 45-2, nY, "''", oTabPage)

		LOCAL oGeoNSEW := System.Windows.Forms.ComboBox{} AS System.Windows.Forms.ComboBox
        // 
        // GeoNSEW
        // 
        oGeoNSEW:DropDownStyle := System.Windows.Forms.ComboBoxStyle.DropDownList
        oGeoNSEW:FormattingEnabled := TRUE
		IF oLabel:Text:Contains("Latitude")
	        oGeoNSEW:Items:AddRange(<System.Object>{ "N", "S" })
			IF SELF:Latitude_ItemUID == ""
				SELF:Latitude_ItemUID := cItemUID
			ENDIF
		ELSE
	        oGeoNSEW:Items:AddRange(<System.Object>{ "E", "W" })
			IF SELF:Longitude_ItemUID == ""
				SELF:Longitude_ItemUID := cItemUID
			ENDIF
		ENDIF
        oGeoNSEW:Location := System.Drawing.Point{nX + 35 + 27 + 45 + 10, nY}
        oGeoNSEW:Name := "GeoNSEW" + cItemUID
        oGeoNSEW:Size := System.Drawing.Size{35, 21}
        oGeoNSEW:TabIndex := TabIndex++
        //oGeoNSEW:BackColor := Color.White
		oGeoNSEW:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
        //oGeoNSEW:Validating += System.ComponentModel.CancelEventHandler{ SELF, @GeoNSEW_Validating() }

		oGeoNSEW:Tag := Mandatory
        oTabPage:Controls:Add(oGeoNSEW)

		//LOCAL oGeoNSEW := System.Windows.Forms.TextBox{} AS System.Windows.Forms.TextBox
  //      // 
  //      // GeoNSEW
  //      // 
  //      oGeoNSEW:Location := System.Drawing.Point{nX + 35 + 27 + 45 + 10, nY}
  //      oGeoNSEW:Name := "GeoNSEW" + cItemUID
  //      oGeoNSEW:Size := System.Drawing.Size{17, 20}
  //      oGeoNSEW:TextAlign := System.Windows.Forms.HorizontalAlignment.Center
  //      oGeoNSEW:TabIndex := TabIndex++
  //      oGeoNSEW:MaxLength := 1
  //      oGeoNSEW:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }

		//oGeoNSEW:Tag := Mandatory
  //      oTabPage:Controls:Add(oGeoNSEW)

		nY += 30

		/*LOCAL oGeoCoordinate := System.Windows.Forms.MaskedTextBox{} AS System.Windows.Forms.MaskedTextBox
        // 
        // GeoCoordinate
        // 
        oGeoCoordinate:Location := System.Drawing.Point{nX, nY}
        oGeoCoordinate:Mask := "000° 00' 00"+oMainForm:decimalSeparator+"0000''"
        oGeoCoordinate:Name := "GeoCoordinate" + cItemUID
        oGeoCoordinate:Size := System.Drawing.Size{85, 20}
        oGeoCoordinate:TabIndex := TabIndex++
        oGeoCoordinate:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }

		oGeoCoordinate:Tag := Mandatory
        oTabPage:Controls:Add(oGeoCoordinate)
		nY += 30*/
		//IF nFirstControl == 0
		//	SELF:aFocusControls:Add(oGeoCoordinate)
		//ENDIF

	CASE cItemType == "D" .and. cIsDD == "0"
		LOCAL oDatePicker := System.Windows.Forms.DateTimePicker{} AS System.Windows.Forms.DateTimePicker
        // 
        // DatePicker
        // 
		/////////////////////////////////////////////////
		//CHANGED BY KIRIAKOS
		/////////////////////////////////////////////////
        //oDatePicker:CustomFormat := "dd/MM/yyyy HH:mm"
        oDatePicker:CustomFormat := " "
        oDatePicker:Format := System.Windows.Forms.DateTimePickerFormat.Custom
        oDatePicker:Location := System.Drawing.Point{nX, nY}
        oDatePicker:Name := "DatePicker" + cItemUID
        oDatePicker:Size := System.Drawing.Size{128, 20}
        oDatePicker:TabIndex := TabIndex++
		//oDatePicker:Value := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC)
		oDatePicker:Value := Datetime.Now
        oDatePicker:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
        oDatePicker:MouseDown += System.Windows.Forms.MouseEventHandler{ SELF, @Control_MouseDown() }
		oDatePicker:ValueChanged += System.EventHandler{ SELF, @Control_ValueChanged() }

		oDatePicker:Tag := Mandatory
        oTabPage:Controls:Add(oDatePicker)

		IF SELF:DateTime_ItemUID == ""
			SELF:DateTime_ItemUID := cItemUID
		ENDIF

		IF ! SELF:lGmtDiffControlsCreated
	        oDatePicker:Validated += System.EventHandler{ SELF, @DatePicker_Validated() }
			LOCAL timeSpan := timeZone.CurrentTimeZone:GetUtcOffset(oDatePicker:Value) AS TimeSpan
			SELF:CreateGmtDiffControls(oTabPage, cItemUID, Mandatory, nX, nY, timeSpan)
			SELF:lGmtDiffControlsCreated := TRUE
		ENDIF

		nY += 30
		//IF nFirstControl == 0
		//	SELF:aFocusControls:Add(oDatePicker)
		//ENDIF
		
	/////////////////////////////////////////////////////////				
	//			ADDED BY KIRIAKOS
	/////////////////////////////////////////////////////////
	//CASE cItemType == "E" .and. cIsDD == "0"
	//	LOCAL oDatePickerNull := DateTimePickerNull{} AS DateTimePickerNull
 //       // 
 //       // DatePickerNull
 //       // 
 //       oDatePickerNull:CustomFormat := "dd/MM/yyyy HH:mm"
 //       oDatePickerNull:Format := System.Windows.Forms.DateTimePickerFormat.Custom
 //       oDatePickerNull:Location := System.Drawing.Point{nX, nY}
 //       oDatePickerNull:Name := "DatePickerNull" + cItemUID
 //       oDatePickerNull:Size := System.Drawing.Size{128, 20}
 //       oDatePickerNull:TabIndex := TabIndex++
	//	//oDatePickerNull:Value := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC)
	//	oDatePickerNull:Value := Datetime.Now
 //       oDatePickerNull:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }

	//	oDatePickerNull:Tag := Mandatory
 //       oTabPage:Controls:Add(oDatePickerNull)

	//	IF SELF:DateTime_ItemUID == ""
	//		SELF:DateTime_ItemUID := cItemUID
	//	ENDIF

	//	IF ! SELF:lGmtDiffControlsCreated
	//        oDatePickerNull:Validated += System.EventHandler{ SELF, @DatePickerNull_Validated() }
	//		LOCAL timeSpan := timeSpan{} AS TimeSpan
	//		IF oDatePickerNull:Text:Trim() <> ""
	//			timeSpan := timeZone.CurrentTimeZone:GetUtcOffset(DateTime.Parse(oDatePickerNull:Text))
	//		ENDIF
	//		SELF:CreateGmtDiffControls(oTabPage, cItemUID, Mandatory, nX, nY, timeSpan)
	//		SELF:lGmtDiffControlsCreated := TRUE
	//	ENDIF

	//	nY += 30
	/////////////////////////////////////////////////////////				
	//			ADDED BY KIRIAKOS
	/////////////////////////////////////////////////////////

	CASE cItemType == "D" .and. cIsDD == "1"
		LOCAL oButtonFile := System.Windows.Forms.Button{} AS System.Windows.Forms.Button
		//
		//	Due Date
		//
		oButtonFile:Location := System.Drawing.Point{nX, nY}
        oButtonFile:Name := "DD" + cItemUID
        oButtonFile:Size := System.Drawing.Size{128, 20}
        oButtonFile:TabIndex := TabIndex++
        oButtonFile:Text := "Add Due Date"
        oButtonFile:UseVisualStyleBackColor := TRUE
        oButtonFile:Click += System.EventHandler{ SELF, @DueDate_Button_Clicked() }
		oButtonFile:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
		oButtonFile:Tag := Mandatory
        oTabPage:Controls:Add(oButtonFile)
		nY += 30

	CASE cItemType == "N"
		//LOCAL oNumericTextBox := System.Windows.Forms.MaskedTextBox{} AS System.Windows.Forms.MaskedTextBox
		LOCAL oNumericTextBox := System.Windows.Forms.TextBox{} AS System.Windows.Forms.TextBox
        // 
        // NumericTextBox
        // 
        oNumericTextBox:Location := System.Drawing.Point{nX, nY}
        //oNumericTextBox:Mask := "00000"+oMainForm:decimalSeparator+"00"
        oNumericTextBox:Name := "NumericTextBox" + cItemUID
        oNumericTextBox:Size := System.Drawing.Size{56, 20}
        oNumericTextBox:TextAlign := System.Windows.Forms.HorizontalAlignment.Right
		IF cCalculatedField <> ""
			oNumericTextBox:ReadOnly := TRUE
	        //oNumericTextBox:TabStop := FALSE
	        oNumericTextBox:BackColor := System.Drawing.Color.FromArgb(((System.Int32)(((System.Byte)(255)))), ((System.Int32)(((System.Byte)(255)))), ((System.Int32)(((System.Byte)(192)))))
		ELSE
	        oNumericTextBox:TabIndex := TabIndex++
	        oNumericTextBox:BackColor := Color.White
		ENDIF
        oNumericTextBox:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
        oNumericTextBox:KeyDown += System.Windows.Forms.KeyEventHandler{ SELF, @NumericControl_KeyDown() }
        oNumericTextBox:Validating += System.ComponentModel.CancelEventHandler{ SELF, @NumericControl_Validating() }
        oNumericTextBox:Validated += System.EventHandler{ SELF, @NumericControl_Validated() }
		//oNumericTextBox:LostFocus += System.EventHandler{ SELF, @NumericControl_LostFocus() }
		//oNumericTextBox:GotFocus += System.EventHandler{ SELF, @NumericControl_GotFocus() }

		oNumericTextBox:Tag := Mandatory
        oTabPage:Controls:Add(oNumericTextBox)
		nY += 30
		//IF nFirstControl == 0
		//	SELF:aFocusControls:Add(oNumericTextBox)
		//ENDIF

	CASE cItemType == "T"
		LOCAL oTextBox := System.Windows.Forms.TextBox{} AS System.Windows.Forms.TextBox
        // 
        // TextBox
        // 
        oTextBox:Location := System.Drawing.Point{nX, nY}
        oTextBox:MaxLength := 128
        oTextBox:Name := "TextBox" + cItemUID
        oTextBox:Size := System.Drawing.Size{120, 20}
        oTextBox:TabIndex := TabIndex++
        oTextBox:BackColor := Color.White
        oTextBox:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }

		oTextBox:Tag := Mandatory
        oTabPage:Controls:Add(oTextBox)
		nY += 30
		//IF nFirstControl == 0
		//	SELF:aFocusControls:Add(oTextBox)
		//ENDIF
	Case cItemType == "F"
		LOCAL oButtonFile := System.Windows.Forms.Button{} AS System.Windows.Forms.Button
		//
		//	File Uploader
		//
		oButtonFile:Location := System.Drawing.Point{nX, nY}
        oButtonFile:Name := "FileUploader" + cItemUID
        oButtonFile:Size := System.Drawing.Size{56, 22}
        oButtonFile:TabIndex := TabIndex++
        oButtonFile:Text := "Upload"
        oButtonFile:UseVisualStyleBackColor := TRUE
        oButtonFile:Click += System.EventHandler{ SELF, @File_Button_Clicked() }
		oButtonFile:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
		oButtonFile:Tag := Mandatory
        oTabPage:Controls:Add(oButtonFile)
		nY += 30
	
	CASE cItemType == "L"
		LOCAL cItemName := oRow["ItemName"]:ToString():Trim() AS STRING
		oLabel := System.Windows.Forms.Label{}
        // 
        // label
        // 
		nX := 250
        oLabel:Location := System.Drawing.Point{nX, nY}
        oLabel:Name := "Label" + cItemUID
        //oLabel:AutoSize := TRUE
        oLabel:TabIndex := 0
	    oLabel:Size := System.Drawing.Size{400, 28}
		oLabel:Text := cItemName
		oLabel:Font := System.Drawing.Font{"Microsoft Sans Serif", ((Single) 10), System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(161))}
        //oLabel:TextAlign := System.Drawing.ContentAlignment.MiddleRight
		oLabel:TextAlign := System.Drawing.ContentAlignment.MiddleLeft		
        oTabPage:Controls:Add(oLabel)
		cPreviousLabelSize := oLabel:Size:Width
		cPreviousLabel := cItemName:Substring(0, cItemName:Length - 1)
		nY += 30

	CASE cItemType == "A"
		lTableMode := TRUE
		// 
        // Table
        // 
		nX := 20
		nY += 5
		LOCAL oTable := DoubleBufferedTableLayoutPanel{} AS DoubleBufferedTableLayoutPanel
		oTable:Visible := false
		oTable:SuspendLayout()
		LOCAL cItemName := oRow["ItemName"]:ToString():Trim() AS STRING
		
		cItemTypeValues := cItemTypeValues:TrimEnd(';')
		LOCAL cItems := cItemTypeValues:Split(';') AS STRING[]
		LOCAL iCountColumns := cItems:Length AS INT
		//MessageBox.Show(iCountColumns:ToString())
		oTable:ColumnCount := iCountColumns
		FOREACH cItem AS STRING IN cItems
			IF cItem == ""
				LOOP
			ENDIF
			LOCAL cItemsIn := cItem:Split(':') AS STRING[]
			LOCAL iPercent := int32.Parse(cItemsIn[2]) AS INT
			//MessageBox.Show(iPercent:ToString())
			oTable:ColumnStyles:Add(System.Windows.Forms.ColumnStyle{System.Windows.Forms.SizeType.Percent, ((Single) iPercent)})
		NEXT
        // 
        // Table
        // 
		oTable:CellBorderStyle := System.Windows.Forms.TableLayoutPanelCellBorderStyle.OutsetDouble
        oTable:Size := System.Drawing.Size{self:Width-60, 30}
		oTable:Location := System.Drawing.Point{nX, nY}
        oTable:Name := "Table"+ cItemUID
        oTable:RowCount := 1
        oTable:RowStyles:Add(System.Windows.Forms.RowStyle{System.Windows.Forms.SizeType.Percent, ((Single) 100)})
		//oTable:DoubleBuffered := true
        //oTable:RowStyles:Add(System.Windows.Forms.RowStyle{System.Windows.Forms.SizeType.Percent, ((Single) 50)})
        
        oTable:AutoSize := TRUE
		oTable:Anchor := ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) ;
                    | System.Windows.Forms.AnchorStyles.Right)))
		
		//
		oLabel := System.Windows.Forms.Label{}
		//nX := 10
        //oLabel:Location := System.Drawing.Point{nX, nY}
        oLabel:Name := "Label" + cItemUID
        //oLabel:AutoSize := TRUE
        oLabel:TabIndex := 0
	    oLabel:AutoSize := TRUE
		oLabel:Dock := System.Windows.Forms.DockStyle.Fill
		oLabel:Text := cItemName
		oLabel:Font := System.Drawing.Font{"Microsoft Sans Serif", ((Single) 10), System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(161))}
        oLabel:BackColor := System.Drawing.SystemColors.Info
		//oLabel:TextAlign := System.Drawing.ContentAlignment.MiddleRight
		oLabel:TextAlign := System.Drawing.ContentAlignment.MiddleCenter
        //oTabPage:Controls:Add(oLabel)
		oTable:Controls:Add(oLabel, 0, 0)
		oTable:SetColumnSpan(oLabel, iCountColumns)
        oLabel:Location := System.Drawing.Point{1, 1}
        oLabel:Margin := System.Windows.Forms.Padding{0}
		cPreviousLabelSize := oLabel:Size:Width
		cPreviousLabel := cItemName:Substring(0, cItemName:Length - 1)
		nY += 115
		nX := 250 
		oTable:ResumeLayout()
		
		oTabPage:Controls:Add(oTable)
		oMyTable := oTable
	CASE cItemType == "M"
		LOCAL oTextBoxMultiline := System.Windows.Forms.TextBox{} AS System.Windows.Forms.TextBox
        // 
        // TextBoxMultiline
        // 
        oTextBoxMultiline:Location := System.Drawing.Point{nX, nY}
        oTextBoxMultiline:Multiline := TRUE
		oTextBoxMultiline:ScrollBars := ScrollBars.Vertical
        oTextBoxMultiline:MaxLength := 32767
        oTextBoxMultiline:AcceptsReturn := TRUE
        oTextBoxMultiline:Name := "TextBoxMultiline" + cItemUID
        oTextBoxMultiline:Size := System.Drawing.Size{450, 120}
        oTextBoxMultiline:TabIndex := TabIndex++
        oTextBoxMultiline:BackColor := Color.White
		oTextBoxMultiline:Enter += System.EventHandler{ SELF, @TML_GotFocus() }
		oTextBoxMultiline:Leave += System.EventHandler{ SELF, @TML_LostFocus() }
		oTextBoxMultiline:Font := System.Drawing.Font{"Tahoma", ((Single) 9.75), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(161))}
       

		oTextBoxMultiline:Tag := Mandatory
        oTabPage:Controls:Add(oTextBoxMultiline)
		nY += 130
		//IF nFirstControl == 0
		//	SELF:aFocusControls:Add(oTextBoxMultiline)
		//ENDIF
	ENDCASE
	
	cPreviousItemType := oRow["ItemType"]:ToString()
RETURN

PRIVATE METHOD TML_GotFocus( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		LOCAL oTextBoxMultiline := (TextBox)sender AS System.Windows.Forms.TextBox
		oTextBoxMultiline:BackColor := Color.LightGreen		
RETURN

PRIVATE METHOD TML_LostFocus( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		LOCAL oTextBoxMultiline := (TextBox)sender AS System.Windows.Forms.TextBox
		oTextBoxMultiline:BackColor := Color.White		
RETURN

PRIVATE METHOD Tab_must_focus( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		LOCAL oTabPage := (System.Windows.Forms.TabPage)sender AS System.Windows.Forms.TabPage
		oTabPage:Focus()	
RETURN
//METHOD CreateLabelConsecutiveNumber(oTabPage AS System.Windows.Forms.TabPage, cItemUID AS STRING, nLabelX AS INT, nY AS INT) AS VOID
//	SELF:nConsecutiveNumber++

//	LOCAL oLabel := System.Windows.Forms.Label{} AS System.Windows.Forms.Label
//    // 
//    // label
//    // 
//    oLabel:Location := System.Drawing.Point{nLabelX - 30, nY + 3}
//    oLabel:Name := "LabelConsecutive" + cItemUID
//    //oLabel:AutoSize := TRUE
//    oLabel:TabIndex := 0
//	//IF lSameSerieItem
//	//    oLabel:Size := System.Drawing.Size{10, 30}
//	//	oLabel:Text := cItemName:Substring(cItemName:Length - 1)
//	//ELSE
//	//    oLabel:Size := System.Drawing.Size{250, 30}
//	//	oLabel:Text := cItemName
//	//ENDIF
//    oLabel:Size := System.Drawing.Size{10, 30}
//	oLabel:Text := SELF:nConsecutiveNumber:ToString()
//    //oLabel:TextAlign := System.Drawing.ContentAlignment.MiddleRight
//	oLabel:TextAlign := System.Drawing.ContentAlignment.TopRight
//    oTabPage:Controls:Add(oLabel)
//RETURN


METHOD CreateGmtDiffControls(oTabPage AS System.Windows.Forms.TabPage, cItemUID AS STRING, Mandatory AS STRING, nX AS INT, nY AS INT, timeSpan AS timeSpan) AS VOID
	STATIC LOCAL nLabel := 2000000 AS INT

	LOCAL oLabel := System.Windows.Forms.Label{} AS System.Windows.Forms.Label
	// 
	// label
	// 
	oLabel:AutoSize := TRUE
	oLabel:Location := System.Drawing.Point{nX + 135, nY + 3}
	oLabel:Name := "Label" + nLabel:ToString()
	nLabel++
	oLabel:Size := System.Drawing.Size{3, 20}
	oLabel:TabIndex := 0
	oLabel:Text := "Gmt Diff."
	oLabel:TextAlign := System.Drawing.ContentAlignment.MiddleLeft
	oTabPage:Controls:Add(oLabel)

	LOCAL oNumericTextBox := System.Windows.Forms.TextBox{} AS System.Windows.Forms.TextBox
    // 
    // NumericTextBox
    // 
    oNumericTextBox:Location := System.Drawing.Point{nX + 135 + 50, nY}
    //oNumericTextBox:Mask := "00000"+SELF:decimalSeparator+"00"
    oNumericTextBox:Name := "NumericTextBoxGMT" + cItemUID
    oNumericTextBox:Size := System.Drawing.Size{30, 20}
    oNumericTextBox:TextAlign := System.Windows.Forms.HorizontalAlignment.Right
	    oNumericTextBox:TabIndex := TabIndex++
	    oNumericTextBox:BackColor := Color.White
    oNumericTextBox:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
    oNumericTextBox:KeyDown += System.Windows.Forms.KeyEventHandler{ SELF, @NumericControl_KeyDown() }
    //oNumericTextBox:Validated += System.EventHandler{ SELF, @NumericControl_Validated() }
	oNumericTextBox:Validating += System.ComponentModel.CancelEventHandler{ SELF, @NumericTextBoxGMT_Validating() }
	oNumericTextBox:Validated += System.EventHandler{ SELF, @NumericTextBoxGMT_Validated() }

	oNumericTextBox:Tag := Mandatory
    oTabPage:Controls:Add(oNumericTextBox)


	LOCAL oLabelGMT := System.Windows.Forms.Label{} AS System.Windows.Forms.Label
	// 
	// label
	// 
	oLabelGMT:AutoSize := TRUE
	oLabelGMT:Location := System.Drawing.Point{nX + 135 + 50 + 40, nY + 3}
	oLabelGMT:Name := "Label" + nLabel:ToString()
	nLabel++
	oLabelGMT:Size := System.Drawing.Size{3, 20}
	oLabelGMT:TabIndex := 0
	oLabelGMT:Text := "GMT"
	oLabelGMT:TextAlign := System.Drawing.ContentAlignment.MiddleLeft
	oTabPage:Controls:Add(oLabelGMT)

	LOCAL oDatePicker := System.Windows.Forms.DateTimePicker{} AS System.Windows.Forms.DateTimePicker
    // 
    // DatePicker
    // 
	/////////////////////////////////////////////////
	//CHANGED BY KIRIAKOS
	/////////////////////////////////////////////////
    //oDatePicker:CustomFormat := "dd/MM/yyyy HH:mm"
    oDatePicker:CustomFormat := " "
    oDatePicker:Format := System.Windows.Forms.DateTimePickerFormat.Custom
    oDatePicker:Location := System.Drawing.Point{nX + 135 + 50 + 70, nY}
    oDatePicker:Name := "DatePickerGMT" + cItemUID
    oDatePicker:Size := System.Drawing.Size{128, 20}
    oDatePicker:TabIndex := TabIndex++
	oDatePicker:Value := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC)
    oDatePicker:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
    oDatePicker:MouseDown += System.Windows.Forms.MouseEventHandler{ SELF, @Control_MouseDown() }
	oDatePicker:ValueChanged += System.EventHandler{ SELF, @Control_ValueChanged() }

	oDatePicker:Tag := Mandatory
    oTabPage:Controls:Add(oDatePicker)

	oDatePicker:Enabled := FALSE

	//////////////////////////////////////////////////////////////////////////////////////////////////
	//			ADDED BY KIRIAKOS
	//////////////////////////////////////////////////////////////////////////////////////////////////
	//LOCAL oDatePickerNull := DateTimePickerNull{} AS DateTimePickerNull
 //   // 
 //   // DatePickerNull
 //   // 
 //   oDatePickerNull:CustomFormat := "dd/MM/yyyy HH:mm"
 //   oDatePickerNull:Format := System.Windows.Forms.DateTimePickerFormat.Custom
 //   oDatePickerNull:Location := System.Drawing.Point{nX + 135 + 50 + 70, nY}
 //   oDatePickerNull:Name := "DatePickerNullGMT" + cItemUID
 //   oDatePickerNull:Size := System.Drawing.Size{128, 20}
 //   oDatePickerNull:TabIndex := TabIndex++
	//oDatePickerNull:Value := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC)
 //   oDatePickerNull:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }

	//oDatePickerNull:Tag := Mandatory
 //   oTabPage:Controls:Add(oDatePickerNull)

	//oDatePickerNull:Enabled := FALSE
	//////////////////////////////////////////////////////////////////////////////////////////////////
	//			ADDED BY KIRIAKOS
	//////////////////////////////////////////////////////////////////////////////////////////////////


	IF SELF:lEnableControls
		LOCAL cGmtDiff AS STRING
		LOCAL nHours := timeSpan:Hours AS INT
		cGmtDiff := nHours:ToString()
		LOCAL nMinutes := timeSpan:Minutes AS INT
		IF nMinutes <> (Double)0
			nMinutes := (INT)(((Double)nMinutes * (Double)60) / (Double)3600)
			cGmtDiff += oMainForm:decimalSeparator + nMinutes:ToString()
		ENDIF
		oNumericTextBox:Text := cGmtDiff
	ENDIF
RETURN


METHOD AddGeoLabel(nX AS INT, nY AS INT, cCaption AS STRING, oTabPage AS System.Windows.Forms.TabPage) AS VOID
	STATIC LOCAL nLabel := 1000000 AS INT

	LOCAL oLabel := System.Windows.Forms.Label{} AS System.Windows.Forms.Label
	// 
	// label
	// 
	oLabel:AutoSize := TRUE
	oLabel:Location := System.Drawing.Point{nX, nY}
	oLabel:Name := "Label" + nLabel:ToString()
	nLabel++
	oLabel:Size := System.Drawing.Size{3, 20}
	oLabel:TabIndex := 0
	oLabel:Text := cCaption
	oLabel:TextAlign := System.Drawing.ContentAlignment.MiddleLeft

	oTabPage:Controls:Add(oLabel)
RETURN


PRIVATE METHOD NumericControl_KeyDown( sender AS System.Object, e AS System.Windows.Forms.KeyEventArgs ) AS System.Void
	//wb("KeyValue="+e:KeyValue:ToString()+CRLF+"KeyCode="+e:KeyCode:ToString(), "KeyData="+e:KeyData:ToString())
	//Keys.Decimal
	//Keys.OemPeriod
	//Keys.Oemcomma

	DO CASE
	CASE e:KeyCode == Keys.Left || e:KeyCode == Keys.Right || e:KeyCode == Keys.Delete || e:KeyCode == Keys.Back ;
		|| e:KeyCode == Keys.Enter || e:KeyCode == Keys.Return || e:KeyCode == Keys.Escape || e:KeyCode == Keys.Tab ;
		|| e:KeyCode == Keys.Home || e:KeyCode == Keys.End
		// Go on
		RETURN

	CASE  e:KeyData == Keys.OemMinus .or. e:KeyData == Keys.Subtract
		// Allow '-' on empty NumericTextBox
		LOCAL oControl := (TextBox)sender AS TextBox
		LOCAL cText := oControl:Text:Trim() AS STRING
		//IF cText:StartsWith("-") .and. cText:Length > 1
		IF cText <> ""
			e:SuppressKeyPress := TRUE
			e:Handled := TRUE
		ENDIF

	CASE e:KeyCode == Keys.Decimal || e:KeyCode == Keys.OemPeriod || e:KeyCode == Keys.Oemcomma
		e:SuppressKeyPress := TRUE
		e:Handled := TRUE
		LOCAL oTextBox := (System.Windows.Forms.TextBox)sender AS System.Windows.Forms.TextBox
		LOCAL cText := oTextBox:Text AS STRING
		IF ! cText:Contains(oMainForm:decimalSeparator)
			oTextBox:Text := cText + oMainForm:decimalSeparator
			oTextBox:SelectionStart := oTextBox:Text:Length
			oTextBox:SelectionLength := 0
		ENDIF
//Convert.ToDouble(oTextBox)

	CASE (e:KeyCode < Keys.D0 || e:KeyCode > Keys.D9) .AND. (e:KeyCode < Keys.NumPad0 || e:KeyCode > Keys.NumPad9) .AND. e:KeyCode <> Keys.Back
		e:SuppressKeyPress := TRUE
		e:Handled := TRUE
	ENDCASE
RETURN


PRIVATE METHOD NumericControl_Validated( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	LOCAL oTextBox := (System.Windows.Forms.TextBox)sender AS System.Windows.Forms.TextBox
	LOCAL cText := oTextBox:Text AS STRING

	IF cText:Contains(oMainForm:decimalSeparator)
		IF cText:StartsWith(oMainForm:decimalSeparator)
			cText := cText:Substring(1)
		ENDIF
		IF cText:EndsWith(oMainForm:decimalSeparator)
			cText := cText:Substring(0, cText:Length - 1)
		ENDIF
		cText := cText:Trim()
		oTextBox:Text := cText
	ENDIF

	LOCAL cItemUID := SELF:GetItemUID(oTextBox:Name) AS STRING
	LOCAL nPos := SELF:aUsedInCalculations:IndexOf(cItemUID) AS INT
	WHILE nPos <> -1
		// Calculate
		SELF:CalculateField(nPos)
		nPos := SELF:aUsedInCalculations:IndexOf(cItemUID, nPos + 1)
	ENDDO
RETURN

/*PRIVATE METHOD NumericControl_LostFocus( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	TRY
		LOCAL oTextBox := (System.Windows.Forms.TextBox)sender AS System.Windows.Forms.TextBox
		LOCAL cText := oTextBox:Text AS STRING
		LOCAL cItemUID := SELF:GetItemUID(oTextBox:Name) AS STRING
		LOCAL cPackageUID := oMainForm:TreeListVesselsReports:FocusedNode:Tag:ToString()
		LOCAL oDRDataRow := oDTPreviousData:NewRow() AS DataRow
		oDRDataRow["Data"] := cText
		oDRDataRow["ItemUID"] := cItemUID
		SELF:oDTPreviousData:Rows:Add(oDRDataRow)
	CATCH exc AS Exception
		WB(exc:ToString())	
	END		
RETURN

PRIVATE METHOD NumericControl_GotFocus( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	TRY
		LOCAL oTextBox := (System.Windows.Forms.TextBox)sender AS System.Windows.Forms.TextBox
		LOCAL cText := oTextBox:Text AS STRING
		cPreviousData := cText
	CATCH exc AS Exception
		WB(exc:Source)
	END
RETURN*/


PRIVATE METHOD NumericControl_Validating( sender AS System.Object, e AS System.ComponentModel.CancelEventArgs ) AS System.Void
	LOCAL oTextBox := (System.Windows.Forms.TextBox)sender AS System.Windows.Forms.TextBox
	IF ! oTextBox:Enabled
		RETURN
	ENDIF

	LOCAL cText := oTextBox:Text AS STRING
	IF cText:Contains(oMainForm:decimalSeparator)
		IF cText:StartsWith(oMainForm:decimalSeparator)
			cText := cText:Substring(1)
		ENDIF
		IF cText:EndsWith(oMainForm:decimalSeparator)
			cText := cText:Substring(0, cText:Length - 1)
		ENDIF
		cText := cText:Trim()
		oTextBox:Text := cText
	ENDIF

	IF cText == ""
		RETURN
	ENDIF

	LOCAL cItemUID := SELF:GetItemUID(oTextBox:Name) AS STRING

	// Validate Min, Max values
	LOCAL oRows := SELF:oDTReportItems:Select("REPORT_UID="+SELF:cReportUID+" AND ITEM_UID="+cItemUID) AS DataRow[]
	IF oRows:Length == 0
		RETURN
	ENDIF

	LOCAL nMinValue, nMaxValue AS Double
	LOCAL cValue AS STRING

	//cText := cText:Replace(oMainForm:decimalSeparator, ".")

	cValue := oRows[1]:Item["MinValue"]:ToString()
	IF cValue <> ""
		nMinValue := Convert.ToDouble(cValue)
		IF nMinValue > Convert.ToDouble(cText)
			MessageBox.Show("The value must be greater than or equal to: "+cValue, ;
							"Invalid value: "+cText, MessageBoxButtons.OK, MessageBoxIcon.Error)
			e:Cancel := TRUE
			RETURN
		ENDIF
	ENDIF

	cValue := oRows[1]:Item["MaxValue"]:ToString()
	IF cValue <> ""
		nMaxValue := Convert.ToDouble(cValue)
		IF nMaxValue < Convert.ToDouble(cText)
			MessageBox.Show("The value must be smaller than or equal to: "+cValue, ;
							"Invalid value: "+cText, MessageBoxButtons.OK, MessageBoxIcon.Error)
			e:Cancel := TRUE
			RETURN
		ENDIF
	ENDIF
RETURN


METHOD CalculateField(nPos AS INT) AS VOID
	LOCAL cCalculatedItemUID := SELF:aCalculatedItemUID[nPos]:ToString() AS STRING
	LOCAL oControl := SELF:GetControl("NumericTextBox", cCalculatedItemUID) AS Control
	IF oControl == NULL
		RETURN
	ENDIF

	////LOCAL cItemUID := SELF:aUsedInCalculations[nPos]:ToString() AS STRING
	LOCAL cFormula := SELF:aFormula[nPos]:ToString() AS STRING

	LOCAL oFormulaCompiler := FormulaCompiler{SELF} AS FormulaCompiler
	// Amount result
	LOCAL cValueText, cError AS STRING
	IF cFormula:Contains("(")
		IF ! oFormulaCompiler:ParseExpressionParenthesis(cFormula, cValueText, cError)
			oControl:Text := ""
			RETURN
		ENDIF
	ENDIF

	cValueText := oFormulaCompiler:ReplaceExpressionTerms(cFormula, cFormula)
	IF cValueText == ""
		oControl:Text := ""
		RETURN
	ENDIF

	// Calculate *, /
	// Calculate +, -
	cValueText := oFormulaCompiler:CalculateExpression(cValueText)
	//wb("cFormula="+cFormula+CRLF+"cValueText="+cValueText, "CalculateExpression")

	LOCAL cAmount AS STRING
	// Calculate *, /
	// Calculate +, -
	cAmount := oFormulaCompiler:CalculateExpression(cValueText)
	cAmount := Math.Round(Convert.ToDouble(cAmount), 2):ToString()
	oControl:Text := cAmount
RETURN


PRIVATE METHOD Control_KeyUp( sender AS System.Object, e AS System.Windows.Forms.KeyEventArgs ) AS System.Void
	IF e:KeyCode == Keys.Enter || e:KeyCode == Keys.Return
		SELF:SelectNextControl((Control)sender, TRUE, TRUE, TRUE, TRUE)
		//LOCAL oControl := SELF:GetNextControl((Control)sender, TRUE) AS Control
		//wb(SELF:tabControl_Report:SelectedTab:Name, oControl:Name)
		//IF oControl:Name <> "0"
		//	SELF:SelectNextControl((Control)sender, TRUE, TRUE, TRUE, TRUE)
		//ENDIF
	ELSEIF e:KeyCode == Keys.Delete	.OR. e:KeyCode == Keys.Back
		TRY
			IF sender:GetType():ToString() == "System.Windows.Forms.DateTimePicker"
				LOCAL oDateTime := System.Windows.Forms.DateTimePicker{} AS System.Windows.Forms.DateTimePicker
				oDateTime := (System.Windows.Forms.DateTimePicker)sender
				////////////////////////////////
				// CHANGED BY KIRIAKOS
				////////////////////////////////
				oDateTime:CustomFormat := " "
				//oDateTime:Visible := FALSE
			ENDIF
		END
	ENDIF
RETURN

PRIVATE METHOD Control_MouseDown( sender AS System.Object, e AS System.Windows.Forms.MouseEventArgs ) AS System.Void
	IF sender:GetType():ToString() == "System.Windows.Forms.DateTimePicker"
		LOCAL oDateTime := System.Windows.Forms.DateTimePicker{} AS System.Windows.Forms.DateTimePicker
		oDateTime := (System.Windows.Forms.DateTimePicker)sender
		oDateTime:CustomFormat := "dd/MM/yyyy HH:mm"
	ENDIF
RETURN

PRIVATE METHOD Control_ValueChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	IF sender:GetType():ToString() == "System.Windows.Forms.DateTimePicker"
		LOCAL oDateTime := System.Windows.Forms.DateTimePicker{} AS System.Windows.Forms.DateTimePicker
		oDateTime := (System.Windows.Forms.DateTimePicker)sender
		oDateTime:CustomFormat := "dd/MM/yyyy HH:mm"
	ENDIF
RETURN

PRIVATE METHOD File_Button_Clicked( sender AS System.Object, e AS System.EventArgs ) AS System.Void
TRY
	LOCAL oButton := (Button)sender as Button
	IF oButton:Text:Contains("File")
		//MessageBox.Show("File")
		LOCAL oFiles_Form := Files_Form_Office{} AS Files_Form_Office
		oFiles_Form:cTempDir := cTempDocsDir
		oFiles_Form:iCountDocuments := int32.Parse(oButton:Text:Substring(0,oButton:Text:LastIndexOf(" ")))
		oFiles_Form:oButton := oButton
		oFiles_Form:oReportForm := SELF
		LOCAL oRowLocal := oMainForm:returnUserSetting(oUser:USER_UNIQUEID) AS DataRow
		IF (oRowLocal == NULL || oRowLocal["CanEditReportData"]:ToString() == "False") 
			IF (oMainForm:checkIFUserIsCreatorOfThePachage(self:cMyPackageUID) && oMainForm:LBCReportsOffice:Visible == TRUE)
				oFiles_Form:lCanEdit := TRUE
			else
				oFiles_Form:lCanEdit := FALSE
			endif
		ELSE
			oFiles_Form:lCanEdit := true
		ENDIF
		
		IF !SELF:lisInEditMode 
			oFiles_Form:lCanEdit := FALSE
		ENDIF
		
		oFiles_Form:Show()
		RETURN
	ELSE
		IF !SELF:lisInEditMode 
			RETURN
		ENDIF
		//MessageBox.Show("Else")
		LOCAL iCountFiles := 0 AS INT
		LOCAL cItemUID := SELF:GetFileUID(oButton:name) as String
	
		LOCAL oOpenFileDialog:=  System.Windows.Forms.OpenFileDialog{} AS System.Windows.Forms.OpenFileDialog
		oOpenFileDialog:Filter:="All Files|*.*"
		oOpenFileDialog:Multiselect := TRUE
		LOCAL dr := oOpenFileDialog:ShowDialog() AS System.Windows.Forms.DialogResult
		IF oOpenFileDialog:FileName == ""
			RETURN
		ENDIF
		IF dr == System.Windows.Forms.DialogResult.OK
			FOREACH file AS STRING IN oOpenFileDialog:FileNames
			TRY
				System.Io.File.Copy(file,System.IO.Directory.GetCurrentDirectory()+"\TempDocs\"+ file:Substring(file:LastIndexOf('\\'))+"."+ cItemUID)
				oMainForm:addFileToDatabase(file,cItemUID,self:cMyPackageUID)	
				iCountFiles++
			CATCH ex AS Exception
				// Could not load the image - probably related to Windows file system permissions.
				MessageBox.Show("Cannot open the file: " + file:Substring(file:LastIndexOf('\\')) +;
				". You may not have permission to read the file, or " +;
				"it may be corrupt.\r\nReported error: " + ex:Message)
				Application.DoEvents()
				LOOP
			END	
			NEXT
			IF iCountFiles==1
				oButton:Text := "1 File"
			ELSE
				oButton:Text := iCountFiles:ToString()+ " Files"
			ENDIF
		ENDIF
	ENDIF
CATCH exc AS Exception
		MessageBox.Show(exc:ToString(),"Error")	
END					
RETURN

PRIVATE METHOD DueDate_Button_Clicked( sender AS System.Object, e AS System.EventArgs ) AS System.Void
TRY
		LOCAL oButton := (Button)sender as Button
		LOCAL oDatePicker := System.Windows.Forms.DateTimePicker{} AS System.Windows.Forms.DateTimePicker
        // 
        // Due DatePicker
        // 
		/////////////////////////////////////////////////
		//CHANGED BY KIRIAKOS
		/////////////////////////////////////////////////
		//oDatePicker:CustomFormat := "dd/MM/yyyy HH:mm"
		oDatePicker:CustomFormat := " "
        oDatePicker:Format := System.Windows.Forms.DateTimePickerFormat.Custom
        oDatePicker:Location := oButton:Location
        oDatePicker:Name := "DatePicker" +  GetItemUID(oButton:Name)
        oDatePicker:Size := System.Drawing.Size{128, 20}
		//oDatePicker:Value := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC)
		oDatePicker:Value := Datetime.Now
        oDatePicker:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
		oDatePicker:MouseDown += System.Windows.Forms.MouseEventHandler{ SELF, @Control_MouseDown() }
		oDatePicker:ValueChanged += System.EventHandler{ SELF, @Control_ValueChanged() }
		oDatePicker:Tag := oButton:Tag
		oDatePicker:Enabled := oButton:Enabled
		oButton:Visible := false
		oButton:Parent:Controls:Add(oDatePicker)
CATCH exc AS Exception
		MessageBox.Show(exc:ToString(),"Error on Creating the Date Picker")	
END					
RETURN

PRIVATE METHOD replaceButtonWithDate( oButton AS Control ) AS DateTimePicker
TRY
		LOCAL oDatePicker := System.Windows.Forms.DateTimePicker{} AS System.Windows.Forms.DateTimePicker
        // 
        // Due DatePicker
        // 
		/////////////////////////////////////////////////
		//CHANGED BY KIRIAKOS
		/////////////////////////////////////////////////
		//oDatePicker:CustomFormat := "dd/MM/yyyy HH:mm"
		oDatePicker:CustomFormat := " "
        oDatePicker:Format := System.Windows.Forms.DateTimePickerFormat.Custom
        oDatePicker:Location := oButton:Location
        oDatePicker:Name := "DatePicker" +  GetItemUID(oButton:Name)
        oDatePicker:Size := System.Drawing.Size{128, 20}
		//oDatePicker:Value := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC)
		oDatePicker:Value := Datetime.Now
        oDatePicker:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @Control_KeyUp() }
		oDatePicker:MouseDown += System.Windows.Forms.MouseEventHandler{ SELF, @Control_MouseDown() }
		oDatePicker:ValueChanged += System.EventHandler{ SELF, @Control_ValueChanged() }
		oDatePicker:Tag := oButton:Tag
		oDatePicker:Enabled := oButton:Enabled
		oButton:Visible := false
		oButton:Parent:Controls:Add(oDatePicker)
		RETURN oDatePicker
CATCH exc AS Exception
		MessageBox.Show(exc:ToString(),"Error on Creating the Date Picker")	
END					
RETURN null

PRIVATE METHOD NumericTextBoxGMT_Validating( sender AS System.Object, e AS System.ComponentModel.CancelEventArgs ) AS System.Void
	LOCAL oTextBox := (System.Windows.Forms.TextBox)sender AS System.Windows.Forms.TextBox
	IF ! oTextBox:Enabled
		RETURN
	ENDIF

	LOCAL cText := oTextBox:Text:Trim() AS STRING
	LOCAL cMandatory := (STRING)oTextBox:Tag AS STRING
	IF cMandatory == "0" .and. cText == ""
		RETURN
	ENDIF

	LOCAL nValue AS Decimal
	TRY
		nValue := Convert.ToDecimal(cText)
		//wb(nValue:ToString()+CRLF+(nValue < (Decimal)-12):ToString()+CRLF+(nValue > (Decimal)12):ToString(), "")

		// Check Hours
		LOCAL nHours := (INT)nValue AS INT
		LOCAL nDec := Math.Abs(nValue - (Decimal)nHours) AS Decimal
		IF nDec <> (Decimal)0 .and. nDec <> (Decimal)0.5
			BREAK
		ENDIF

		IF nValue < (Decimal)-12 .or. nValue > (Decimal)12
			BREAK
		ENDIF
	CATCH
		MessageBox.Show("The GMT Difference (in hours) must be between:"+CRLF+;
						"-12 and +12"+CRLF+CRLF+"Only hours or half hours are supported."+CRLF+"Examples: 6, -6, 3.5, -3.5", ;
						"Invalid GMT Difference: "+cText, MessageBoxButtons.OK, MessageBoxIcon.Error)
		e:Cancel := TRUE
	END TRY
RETURN


PRIVATE METHOD NumericTextBoxGMT_Validated( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	LOCAL oTextBox := (System.Windows.Forms.TextBox)sender AS System.Windows.Forms.TextBox
	LOCAL cText := oTextBox:Text AS STRING

	IF cText:Contains(oMainForm:decimalSeparator)
		IF cText:StartsWith(oMainForm:decimalSeparator)
			cText := cText:Substring(1)
		ENDIF
		IF cText:EndsWith(oMainForm:decimalSeparator)
			cText := cText:Substring(0, cText:Length - 1)
		ENDIF
		cText := cText:Trim()
		oTextBox:Text := cText
	ENDIF

	LOCAL cItemUID := SELF:GetItemUID(oTextBox:Name) AS STRING
	SELF:UpdateDatePickerGMT(cItemUID, cText)
RETURN


PRIVATE METHOD DatePicker_Validated( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	LOCAL oDatePicker := (DateTimePicker)sender AS DateTimePicker
	LOCAL cItemUID := SELF:GetItemUID(oDatePicker:Name) AS STRING

	LOCAL oNumericTextBoxGMT := (TextBox)SELF:GetControl("NumericTextBoxGMT", cItemUID) AS TextBox

	IF oNumericTextBoxGMT <> ""
		LOCAL cText := oNumericTextBoxGMT:Text AS STRING
		IF cText <> ""
			LOCAL oDatePickerGMT := (DateTimePicker)SELF:GetControl("DatePickerGMT", cItemUID) AS DateTimePicker
			IF oDatePickerGMT <> NULL
				LOCAL dDate := oDatePicker:Value AS DateTime

				LOCAL nValue := Convert.ToDecimal(cText) AS Decimal
				LOCAL nHours := (INT)nValue AS INT

				dDate := dDate:AddHours(-1 * nHours)

				LOCAL nDec := nValue - (Decimal)nHours AS Decimal
				IF nDec <> (Decimal)0
					dDate := dDate:AddMinutes((INT)(nDec * (Decimal)60) * -1)
					//wb(dDate:ToString()+CRLF+nHours:ToString()+CRLF+nDec:ToString()+CRLF+((INT)nDec * 60):ToString(), "Min")
				ENDIF

				oDatePickerGMT:Value := dDate
			ENDIF
		ENDIF
	ENDIF
RETURN


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//								ADDED BY KIRIAKOS
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//PRIVATE METHOD DatePickerNull_Validated( sender AS System.Object, e AS System.EventArgs ) AS System.Void
//	LOCAL oDatePickerNull := (DateTimePickerNull)sender AS DateTimePickerNull
//	LOCAL cItemUID := SELF:GetItemUID(oDatePickerNull:Name) AS STRING

//	LOCAL oNumericTextBoxGMT := (TextBox)SELF:GetControl("NumericTextBoxGMT", cItemUID) AS TextBox

//	IF oNumericTextBoxGMT <> ""
//		LOCAL cText := oNumericTextBoxGMT:Text AS STRING
//		IF cText <> ""
//			LOCAL oDatePickerNullGMT := (DateTimePickerNull)SELF:GetControl("DatePickerNullGMT", cItemUID) AS DateTimePickerNull
//			IF oDatePickerNullGMT <> NULL
//				IF oDatePickerNull:Text:Trim() <> ""
//					LOCAL dDate := DateTime.Parse(oDatePickerNull:Text) AS DateTime

//					LOCAL nValue := Convert.ToDecimal(cText) AS Decimal
//					LOCAL nHours := (INT)nValue AS INT

//					dDate := dDate:AddHours(-1 * nHours)

//					LOCAL nDec := nValue - (Decimal)nHours AS Decimal
//					IF nDec <> (Decimal)0
//						dDate := dDate:AddMinutes((INT)(nDec * (Decimal)60) * -1)
//						//wb(dDate:ToString()+CRLF+nHours:ToString()+CRLF+nDec:ToString()+CRLF+((INT)nDec * 60):ToString(), "Min")
//					ENDIF

//					oDatePickerNullGMT:Value := dDate
//				ENDIF
//			ENDIF
//		ENDIF
//	ENDIF
//RETURN
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//								ADDED BY KIRIAKOS
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

METHOD UpdateDatePickerGMT(cItemUID AS STRING, cText AS STRING) AS VOID
	IF cText == ""
		RETURN
	ENDIF

	LOCAL oDatePickerGMT := (DateTimePicker)SELF:GetControl("DatePickerGMT", cItemUID) AS DateTimePicker
	IF oDatePickerGMT <> NULL
		LOCAL oDatePicker := (DateTimePicker)SELF:GetControl("DatePicker", cItemUID) AS DateTimePicker
		IF oDatePicker <> NULL
			LOCAL dDate := oDatePicker:Value AS DateTime

			LOCAL nValue := Convert.ToDecimal(cText) AS Decimal
			LOCAL nHours := (INT)nValue AS INT

			dDate := dDate:AddHours(- 1 * nHours)

			LOCAL nDec := nValue - (Decimal)nHours AS Decimal
			IF nDec <> (Decimal)0
				dDate := dDate:AddMinutes((INT)(nDec * (Decimal)60) * -1)
				//wb(dDate:ToString()+CRLF+nHours:ToString()+CRLF+nDec:ToString()+CRLF+((INT)nDec * 60):ToString(), "Min")
			ENDIF

			oDatePickerGMT:Value := dDate
		ENDIF
	ENDIF
RETURN


//PRIVATE METHOD GeoDeg_Validating( sender AS System.Object, e AS System.ComponentModel.CancelEventArgs ) AS System.Void
//	LOCAL oGeo := (System.Windows.Forms.TextBox)sender AS System.Windows.Forms.TextBox
//	LOCAL nMaxLength := oGeo:MaxLength AS INT
//	LOCAL nValue as INT

//	IF nMaxLength == 2
//		// Latitude
//		TRY
//			nValue := Convert.ToInt32(oGeo:Text)
//			IF nValue < 0 .or. nValue > 90
//				BREAK
//			ENDIF
//		CATCH
//			ErrorBox("The Latitude Degrees must be between:"+CRLF+;
//					"0 and 90", "Invalid Latitude Degrees")
//			e:Cancel := TRUE
//		END TRY
//	ELSE
//		// Longitude
//		TRY
//			nValue := Convert.ToInt32(oGeo:Text)
//			IF nValue < 0 .or. nValue > 180
//				BREAK
//			ENDIF
//		CATCH
//			ErrorBox("The Longitude Degrees must be between:"+CRLF+;
//					"0 and 180", "Invalid Longitude Degrees")
//			e:Cancel := TRUE
//		END TRY
//	ENDIF
//RETURN


//PRIVATE METHOD GeoMin_Validating( sender AS System.Object, e AS System.ComponentModel.CancelEventArgs ) AS System.Void
//	LOCAL oGeo := (System.Windows.Forms.TextBox)sender AS System.Windows.Forms.TextBox
//	LOCAL nValue as INT

//	// Minutes
//	TRY
//		nValue := Convert.ToInt32(oGeo:Text)
//		IF nValue < 0 .or. nValue > 59
//			BREAK
//		ENDIF
//	CATCH
//		ErrorBox("The Minutes must be between:"+CRLF+;
//				"0 and 59", "Invalid Minutes")
//		e:Cancel := TRUE
//	END TRY
//RETURN


//PRIVATE METHOD GeoSec_Validating( sender AS System.Object, e AS System.ComponentModel.CancelEventArgs ) AS System.Void
//	LOCAL oGeo := (System.Windows.Forms.TextBox)sender AS System.Windows.Forms.TextBox
//	LOCAL nValue AS Double

//	// Minutes
//	TRY
//		nValue := Convert.ToDouble(oGeo:Text)
//		IF nValue < (Double)0 .or. (Double)nValue > 59.9999
//			BREAK
//		ENDIF
//	CATCH
//		ErrorBox("The Seconds must be between:"+CRLF+;
//				"0.0000 and 59.9999", "Invalid Seconds")
//		e:Cancel := TRUE
//	END TRY
//RETURN


//PRIVATE METHOD GeoNSEW_Validating( sender AS System.Object, e AS System.ComponentModel.CancelEventArgs ) AS System.Void
//	LOCAL oGeo := (System.Windows.Forms.ComboBox)sender AS System.Windows.Forms.ComboBox
//	IF oGeo:SelectedIndex == -1
//		IF oGeo:Items[0]:ToString() == "N"
//			ErrorBox("Please specify North or South", "N or S")
//			e:Cancel := TRUE
//		ELSE
//			ErrorBox("Please specify East or West", "E or W")
//			e:Cancel := TRUE
//		ENDIF
//	ENDIF
//RETURN


PRIVATE METHOD CheckBox_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	LOCAL oCheckBox := (System.Windows.Forms.CheckBox)sender AS System.Windows.Forms.CheckBox
	LOCAL cCaption := oCheckBox:Text AS STRING

	IF oCheckBox:Checked
		DO CASE
		CASE cCaption:EndsWith("(OFF)")
			cCaption := cCaption:Substring(0, cCaption:Length - 5)+"(ON)"
		CASE cCaption:EndsWith("(NO)")
			cCaption := cCaption:Substring(0, cCaption:Length - 4)+"(YES)"
		ENDCASE
	ELSE
		DO CASE
		CASE cCaption:EndsWith("(ON)")
			cCaption := cCaption:Substring(0, cCaption:Length - 4)+"(OFF)"
		CASE cCaption:EndsWith("(YES)")
			cCaption := cCaption:Substring(0, cCaption:Length - 5)+"(NO)"
		ENDCASE
	ENDIF

	oCheckBox:Text := cCaption
RETURN


PRIVATE METHOD TabPage_Enter( sender AS System.Object, e AS System.EventArgs ) AS System.Void
////	LOCAL oTabPage := SELF:tabControl_Report:SelectedTab AS System.Windows.Forms.TabPage
//////wb(oTabPage:Name)
////	IF oTabPage:Name:Contains("General")
////		// TabPages not yet constructed
////		RETURN
////	ENDIF
	
//	//LOCAL oControl AS Control
//	//oControl := (Control)SELF:aFocusControls[Convert.ToInt32(oTabPage:Name)]
//	//wb(oControl:Name, oTabPage:Name)
//	//oControl:Focus()

//	SendKeys.Send("{TAB}")
RETURN


METHOD GetItemUID(cName AS STRING) AS STRING
	LOCAL cIteUID := "", c AS STRING
	LOCAL n, nLen := cName:Length - 1 AS INT
	// Get IteUID from the right part of Control:Name

	FOR n:=nLen DOWNTO 0
		c := cName:Substring(n, 1)
		IF ! SELF:cNumbers:Contains(c)
			EXIT
		ENDIF
		cIteUID := c + cIteUID
	NEXT
RETURN cIteUID



METHOD GetControl(cPrefix AS STRING, cItemUID AS STRING) AS Control
	LOCAL cName, cLocate := cPrefix+cItemUID AS STRING

	FOREACH oTabPage AS System.Windows.Forms.TabPage IN SELF:tabControl_Report:TabPages
		FOREACH oControl AS Control IN oTabPage:Controls
			IF oControl:HasChildren
				FOREACH oSecControl AS Control IN oControl:Controls
					cName := oSecControl:Name
					IF cName == cLocate
						RETURN oSecControl
					ENDIF
				NEXT
			ELSE
				cName := oControl:Name
				IF cName == cLocate
					RETURN oControl
				ENDIF
			
			ENDIF
		NEXT
	NEXT
RETURN NULL

METHOD RefreshoDTFMData() as Void
		LOCAL cDate, cStatement  AS STRING
		LOCAL cUID AS STRING
		IF oMainForm:TreeListVesselsReports:visible == TRUE
		    cUID := cMyPackageUID
			cStatement:="SELECT FMDataPackages.PACKAGE_UID, FMData.ITEM_UID, FMData.Data FROM FMData"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
				" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
				" WHERE FMDataPackages.VESSEL_UNIQUEID="+oMainForm:GetVesselUID+;
				" AND FMDataPackages.REPORT_UID="+SELF:cReportUID+;
				" AND FMDataPackages.PACKAGE_UID ="+cUID+" "
		
		ELSE
			cDate:=	oMainForm:LBCVesselReports:SelectedItem:ToString()
			cDate := cDate:SubString(0, 16)		// 10/12/2014 HH:mm
			LOCAL dStart := Datetime.Parse(cDate) AS DateTime
			LOCAL dEnd := dStart:AddMinutes(1) AS DateTime
			cStatement:="SELECT FMDataPackages.PACKAGE_UID, FMData.ITEM_UID, FMData.Data FROM FMData"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
				" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
				" WHERE FMDataPackages.VESSEL_UNIQUEID="+oMainForm:GetVesselUID+;
				" AND FMDataPackages.REPORT_UID="+SELF:cReportUID+;
				" AND FMDataPackages.DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm")+"'"
		ENDIF
	SELF:oDTFMData := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	/*IF SELF:oDTFMData:Rows:Count == 0
		//RETURN
	ENDIF*/
RETURN

METHOD PutControlValues() AS VOID
	LOCAL cStatement AS STRING
	//LOCAL cVesselUID := oMainForm:CheckedLBCVessels:SelectedValue:ToString() AS STRING
	LOCAL cDate AS STRING
	LOCAL cUID AS STRING
	IF oMainForm:TreeListVesselsReports:visible == TRUE
	    cUID := self:cMyPackageUID //23.12
		cStatement:="SELECT FMDataPackages.PACKAGE_UID, FMDataPackages.Status, FMData.ITEM_UID, FMData.Data FROM FMData"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
				" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
				" WHERE FMDataPackages.VESSEL_UNIQUEID="+oMainForm:GetVesselUID+;
				" AND FMDataPackages.REPORT_UID="+SELF:cReportUID+;
				" AND FMDataPackages.PACKAGE_UID ="+cUID+" "
		
	ELSE
		cDate:=	oMainForm:LBCVesselReports:SelectedItem:ToString()
		cDate := cDate:SubString(0, 16)		// 10/12/2014 HH:mm
		LOCAL dStart := Datetime.Parse(cDate) AS DateTime
		LOCAL dEnd := dStart:AddMinutes(1) AS DateTime
		cStatement:="SELECT FMDataPackages.PACKAGE_UID, FMDataPackages.Status, FMData.ITEM_UID, FMData.Data FROM FMData"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
				" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
				" WHERE FMDataPackages.VESSEL_UNIQUEID="+oMainForm:GetVesselUID+;
				" AND FMDataPackages.REPORT_UID="+SELF:cReportUID+;
				" AND FMDataPackages.DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm")+"'"
	ENDIF
	SELF:oDTFMData := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	/*IF SELF:oDTFMData:Rows:Count == 0
		//RETURN
	ENDIF*/

	LOCAL TextBoxMultiline_ItemUID := "", cMemo := ""  AS STRING
	LOCAL cPackageUID := cUID AS STRING

	// Check if MultiLine control's value exists in FMData
	cStatement:="SELECT ITEM_UID FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" WHERE ItemType='M' AND REPORT_UID="+SELF:cReportUID
	LOCAL oDMLE := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	//wb(cStatement, oDMLE:Rows:Count:ToString())
	TRY
	IF oDMLE:Rows:Count > 0
		cStatement:="SELECT Memo FROM FMDataPackages"+oMainForm:cNoLockTerm+;
					" WHERE PACKAGE_UID="+cPackageUID
		cMemo := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Memo")
		//wb(cMemo, "Here")
		IF cMemo <> "" .and. cMemo:Contains((char)168)
			//LOCAL cSplitter1 := ((char)240):ToString() AS STRING
			//LOCAL charSpl1 := cSplitter1:Chars[0] AS Char
			LOCAL charSpl1 := (char)169 AS Char
			//LOCAL cSplitter2 := ((char)168):ToString() AS STRING
			//LOCAL charSpl2 := cSplitter2:Chars[0] AS Char
			LOCAL charSpl2 := (char)168 AS Char
			
			//
			LOCAL cItems := cMemo:Split(charSpl1) AS STRING[]
			FOREACH cItem AS STRING IN cItems
				TRY
				IF cItem <> NULL .and. cItem <> ""
					LOCAL cItemsTemp := cItem:Split(charSpl2) AS STRING[]
					LOCAL oControlTextBoxMultiline := SELF:GetControl("TextBoxMultiline", cItemsTemp[1]) AS Control
					IF oControlTextBoxMultiline <> NULL
						oControlTextBoxMultiline:Text := cItemsTemp[2]
					ENDIF
				ENDIF
				CATCH exc AS Exception
					MessageBox.Show(exc:ToString(),"Error on Multiline Field Display.")
					LOOP
				END
			NEXT
		ELSEIF cMemo <> ""
				TextBoxMultiline_ItemUID := oDMLE:Rows[0]:Item["ITEM_UID"]:ToString()
				LOCAL oControlTextBoxMultiline := SELF:GetControl("TextBoxMultiline", TextBoxMultiline_ItemUID) AS Control
					IF oControlTextBoxMultiline <> NULL
						oControlTextBoxMultiline:Text := cMemo
					ENDIF
		ENDIF
	ENDIF
	CATCH exc AS Exception
		MessageBox.Show(exc:ToString(),"Error on Multiline Fields Display.")
	END
	///////////////////////////////////////////	Documents 21.01.15 //////////////////////////////////////////////////////////////
	// Check if Documents exist in FMBlobData
	TRY
	LOCAL cFileName, cButtonId/*, cData*/ AS STRING
	LOCAL iCountRows, i, iPreviousNumberOfDocuments:=0 ,iCountDocuments:=0 as INT
	LOCAL oButton as Button

	////////////////////////////////////////////////////////////////////////////////////////////////////
	//		CHANGED BY KIRIAKOS in order to support the new database connection
	////////////////////////////////////////////////////////////////////////////////////////////////////
	IF (oMainForm:oConnBlob == NULL .OR. oMainForm:oConnBlob:State == ConnectionState.Closed)
		oMainForm:oConnBlob:Open()	
	ENDIF
	cStatement:="SELECT ITEM_UID,FileName,BlobData FROM FMBlobData "+oMainForm:cNoLockTerm+;
				" WHERE PACKAGE_UID="+cPackageUID
	oDMLE := oSoftway:ResultTable(oMainForm:oGFHBlob, oMainForm:oConnBlob, cStatement) 
	oMainForm:oConnBlob:Close()
	//cStatement:="SELECT ITEM_UID,FileName,BlobData FROM FMBlobData "+oMainForm:cNoLockTerm+;
	//			" WHERE PACKAGE_UID="+cPackageUID
	//oDMLE := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) 
	////////////////////////////////////////////////////////////////////////////////////////////////////
	//		CHANGED BY KIRIAKOS in order to support the new database connection
	////////////////////////////////////////////////////////////////////////////////////////////////////

	//wb(cStatement, oDMLE:Rows:Count:ToString())
	IF oDMLE:Rows:Count > 0
		iCountRows := oDMLE:Rows:Count
		FOR i := 0 UPTO iCountRows-1 STEP 1
			local oData := (BYTE[]) oDMLE:Rows[i]:Item["BlobData"]  as  BYTE[]
			IF oData <> NULL .and. oData:Length>0 
				//cData := SELF:GetString(oData)
				//wb(cData, "Here")
				cFileName := oDMLE:Rows[i]:Item["FileName"]:ToString()
				//wb(cFileName, "Here")
				//cFileName := cFileName:Substring(0,cFileName:LastIndexOf("."))
				cButtonId := oDMLE:Rows[i]:Item["ITEM_UID"]:ToString() 
				LOCAL oFS AS FileStream
				LOCAL oBinaryWriter as BinaryWriter
				//MessageBox.Show(System.Text.Encoding.Default:ToString())
				/*system.IO.File.WriteAllText(SELF:cTempDocsDir+"\cImage.TXT", cData, System.Text.Encoding.Default)
				LOCAL oFS AS FileStream
				LOCAL formatter := System.Runtime.Serialization.Formatters.Binary.BinaryFormatter{} AS System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
				LOCAL oBinary AS BYTE[]
				oFS := File.OpenRead(SELF:cTempDocsDir+"\cImage.TXT")
				oBinary:=(BYTE[])formatter:DeSerialize(oFS)
				oFS:Close()*/
				//oFS := File.OpenWrite(SELF:cTempDocsDir+"\"+cFileName)
				TRY
					IF File.Exists(SELF:cTempDocsDir+"\"+cFileName)
						File.Delete(SELF:cTempDocsDir+"\"+cFileName)
					ENDIF
					oFS  :=FileStream{SELF:cTempDocsDir+"\"+cFileName, FileMode.CreateNew}
				CATCH exc AS Exception
					MessageBox.Show("An issue presented while extracting the file :"+cFileName+". Press ok to continue.")
				END
				//oFS:Write(oBinary, 0, oBinary:Length)
				oBinaryWriter:=BinaryWriter{oFS}
				oBinaryWriter:Write(oData)
				//oFS:Write(oData, 0, oData:Length)
				oBinaryWriter:Close()
				oFS:Close()
				oData := null
				TRY
					oButton := (Button)SELF:GetControl("FileUploader",cButtonId)
					//MessageBox.Show(SELF:GetPreviousNumberOfFiles(oButton:Text):ToString())
					iPreviousNumberOfDocuments := SELF:GetPreviousNumberOfFiles(oButton:Text)
					IF iPreviousNumberOfDocuments == 0
						iCountDocuments := 1
						oButton:Text := "1 File"
					ELSE
						iCountDocuments++
						oButton:Text := iCountDocuments:ToString() + " Files"
					ENDIF
					CATCH esxc AS Exception
						wb(esxc:StackTrace,"Unable to locate button:"+cFileName)
						Loop
						//wb("Unable to locate file :"+cTempFileInXML:Substring(0,cTempFileInXML:LastIndexOf(".")),"Info")
					END
			ENDIF		
		NEXT
	ENDIF
	CATCH exc AS Exception
		MessageBox.Show(exc:ToString())
	END
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	LOCAL cName, cItemUID, cData, cDeg, cMin, cSec, cNSEW AS STRING
	//LOCAL nPos AS INT
	LOCAL oRows AS DataRow[]
	LOCAL dDate AS DateTime
	LOCAL nGmtDiff AS Decimal

	FOREACH oTabPage AS System.Windows.Forms.TabPage IN SELF:tabControl_Report:TabPages
		FOREACH oControl AS Control IN oTabPage:Controls
			
			IF oControl:HasChildren
			FOREACH oSecControl AS Control IN oControl:Controls
			////////////////////////////////////////////////////////////////////////////////////////////
					try
					cName := oSecControl:Name
					IF cName:StartsWith("buttonEnterKey")
						LOOP
					ENDIF
					IF cName:StartsWith("Label")
						LOOP
					ENDIF

					IF cName:StartsWith("NumericTextBoxGMT")
						cStatement:="SELECT GmtDiff FROM FMDataPackages"+oMainForm:cNoLockTerm+;
									" WHERE PACKAGE_UID="+cPackageUID
						cData := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "GmtDiff")
						//wb(cStatement, cData)
						nGmtDiff := Convert.ToDecimal(cData)
						oSecControl:Text := cData
						LOOP
					ENDIF

					IF cName:StartsWith("DatePickerGMT")
						TRY
							LOCAL nHours := (INT)nGmtDiff AS INT
							dDate := dDate:AddHours(- 1 * nHours)
							LOCAL nDec := nGmtDiff - (Decimal)nHours AS Decimal
							IF nDec <> (Decimal)0
								dDate := dDate:AddMinutes((INT)(nDec * (Decimal)60) * -1)
								//wb(dDate:ToString()+CRLF+nHours:ToString()+CRLF+nDec:ToString()+CRLF+((INT)nDec * 60):ToString(), "Min")
							ENDIF
							((System.Windows.Forms.DateTimePicker)oSecControl):Value := dDate
						CATCH
						END TRY
						LOOP
					ENDIF

		////////////////////////////////////////////////////////////////////////////////////////////////////////
		//						ADDED BY KIRIAKOS
		////////////////////////////////////////////////////////////////////////////////////////////////////////
					//IF cName:StartsWith("DatePickerNullGMT")
					//	TRY
					//		LOCAL nHours := (INT)nGmtDiff AS INT
					//		dDate := dDate:AddHours(- 1 * nHours)
					//		LOCAL nDec := nGmtDiff - (Decimal)nHours AS Decimal
					//		IF nDec <> (Decimal)0
					//			dDate := dDate:AddMinutes((INT)(nDec * (Decimal)60) * -1)
					//			//wb(dDate:ToString()+CRLF+nHours:ToString()+CRLF+nDec:ToString()+CRLF+((INT)nDec * 60):ToString(), "Min")
					//		ENDIF
					//		((DateTimePickerNull)oSecControl):Value := dDate
					//	CATCH
					//	END TRY
					//	LOOP
					//ENDIF
		////////////////////////////////////////////////////////////////////////////////////////////////////////
		//						ADDED BY KIRIAKOS
		////////////////////////////////////////////////////////////////////////////////////////////////////////


					cItemUID := SELF:GetItemUID(cName)

					//nPos := aID:IndexOf(cItemUID)
					oRows := SELF:oDTFMData:Select("ITEM_UID="+cItemUID)
					IF oRows:Length <> 1
						IF cName == "TextBoxMultiline"+TextBoxMultiline_ItemUID
							oSecControl:Text := cMemo
						ENDIF
						LOOP
					ENDIF
					cData := oRows[1]:Item["Data"]:ToString()
					////wb(cName+CRLF+"nPos="+nPos:ToString(), "")
					//IF nPos == -1
					//	//ErrorBox("Cannot locate Item: "+cItemUID+" ("+cName+")")
					//	LOOP
					//ENDIF
					//cData := aData:Item[nPos]:ToString()
					DO CASE			
		////////////////////////////////////////////////////////////////////////////////////////////////////////
		//						ADDED BY KIRIAKOS
		////////////////////////////////////////////////////////////////////////////////////////////////////////
					//CASE cName:StartsWith("DatePickerNull")
					//	IF cData == "No Date Applicable"
					//		((DateTimePickerNull)oSecControl):Visible := false
					//	ELSE
					//		dDate := DateTime.Parse(cData)
					//		((DateTimePickerNull)oSecControl):Value := dDate
					//	ENDif
		////////////////////////////////////////////////////////////////////////////////////////////////////////
		//						ADDED BY KIRIAKOS
		////////////////////////////////////////////////////////////////////////////////////////////////////////
					CASE cName:StartsWith("DatePicker")
						IF cData == "No Date Applicable"
							((System.Windows.Forms.DateTimePicker)oSecControl):Visible := FALSE
						ELSE
							dDate := DateTime.Parse(cData)
							((System.Windows.Forms.DateTimePicker)oSecControl):Value := dDate
						ENDIF
					CASE cName:StartsWith("TextBox")
						oSecControl:Text := cData
				
					CASE cName:StartsWith("DD") .and. cData != ""
						LOCAL oDateTimePicker := replaceButtonWithDate(oSecControl) as DateTimePicker
						IF cData == "No Date Applicable"
							oDateTimePicker:Visible := false
						ELSE
							dDate := DateTime.Parse(cData)
							oDateTimePicker:Value := dDate
						ENDIF
				
					CASE cName:StartsWith("ComboBox")
						((System.Windows.Forms.ComboBox)oSecControl):Text := cData

					CASE cName:StartsWith("NumericTextBox")
						oSecControl:Text := cData:Replace(".", oMainForm:decimalSeparator)

					CASE cName:StartsWith("CheckBox")
						IF cData == "1"
							((System.Windows.Forms.CheckBox)oSecControl):Checked := TRUE
						ENDIF

					CASE cName:StartsWith("GeoDeg")
						IF ! SElF:GeoValueToDegMinSecNSEW(cData, cDeg, cMin, cSec, cNSEW)
							ErrorBox("Cannot analyse the value: "+cData)
							EXIT
						ENDIF
						oControl:Text := cDeg

					CASE cName:StartsWith("GeoMin")
						oControl:Text := cMin

					CASE cName:StartsWith("GeoSec")
						oControl:Text := cSec:Replace(".", oMainForm:decimalSeparator)

					CASE cName:StartsWith("GeoNSEW")
						//wb(((System.Windows.Forms.ComboBox)oControl):SelectedIndex:Tostring()+CRLF+((System.Windows.Forms.ComboBox)oControl):Items:Count:ToString()+CRLF+(cNSEW == "N"):Tostring(), "|"+cNSEW+"|")
						IF cNSEW == "N" .or. cNSEW == "E"
							((System.Windows.Forms.ComboBox)oControl):SelectedIndex := 0
						ELSE
							((System.Windows.Forms.ComboBox)oControl):SelectedIndex := 1
						ENDIF
					ENDCASE
					CATCH
						wb(cName+CRLF+cItemUID+CRLF+cData, "")
					END 
			NEXT
			ELSE
		//////////////////////////////////////////////////////////////////////////////////////////
			
			////////////////////////////////////////////////////////////////////////////////////////////
			try
			cName := oControl:Name
			IF cName:StartsWith("buttonEnterKey")
				LOOP
			ENDIF
			IF cName:StartsWith("Label")
				LOOP
			ENDIF

			IF cName:StartsWith("NumericTextBoxGMT")
				cStatement:="SELECT GmtDiff FROM FMDataPackages"+oMainForm:cNoLockTerm+;
							" WHERE PACKAGE_UID="+cPackageUID
				cData := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "GmtDiff")
				//wb(cStatement, cData)
				nGmtDiff := Convert.ToDecimal(cData)
				oControl:Text := cData
				LOOP
			ENDIF

			IF cName:StartsWith("DatePickerGMT")
				TRY
					LOCAL nHours := (INT)nGmtDiff AS INT
					dDate := dDate:AddHours(- 1 * nHours)
					LOCAL nDec := nGmtDiff - (Decimal)nHours AS Decimal
					IF nDec <> (Decimal)0
						dDate := dDate:AddMinutes((INT)(nDec * (Decimal)60) * -1)
						//wb(dDate:ToString()+CRLF+nHours:ToString()+CRLF+nDec:ToString()+CRLF+((INT)nDec * 60):ToString(), "Min")
					ENDIF
					((System.Windows.Forms.DateTimePicker)oControl):Value := dDate
				CATCH
				END TRY
				LOOP
			ENDIF

/////////////////////////////////////////////////////////////////////////////////////////////////
//						ADDED BY KIRIAKOS
/////////////////////////////////////////////////////////////////////////////////////////////////
			//IF cName:StartsWith("DatePickerNullGMT")
			//	TRY
			//		LOCAL nHours := (INT)nGmtDiff AS INT
			//		dDate := dDate:AddHours(- 1 * nHours)
			//		LOCAL nDec := nGmtDiff - (Decimal)nHours AS Decimal
			//		IF nDec <> (Decimal)0
			//			dDate := dDate:AddMinutes((INT)(nDec * (Decimal)60) * -1)
			//			//wb(dDate:ToString()+CRLF+nHours:ToString()+CRLF+nDec:ToString()+CRLF+((INT)nDec * 60):ToString(), "Min")
			//		ENDIF
			//		((DateTimePickerNull)oControl):Value := dDate
			//	CATCH
			//	END TRY
			//	LOOP
			//ENDIF
/////////////////////////////////////////////////////////////////////////////////////////////////
//						ADDED BY KIRIAKOS
/////////////////////////////////////////////////////////////////////////////////////////////////


			cItemUID := SELF:GetItemUID(cName)

			//nPos := aID:IndexOf(cItemUID)
			oRows := SELF:oDTFMData:Select("ITEM_UID="+cItemUID)
			IF oRows:Length <> 1
				IF cName == "TextBoxMultiline"+TextBoxMultiline_ItemUID
					oControl:Text := cMemo
				ENDIF
				LOOP
			ENDIF
			cData := oRows[1]:Item["Data"]:ToString()
			////wb(cName+CRLF+"nPos="+nPos:ToString(), "")
			//IF nPos == -1
			//	//ErrorBox("Cannot locate Item: "+cItemUID+" ("+cName+")")
			//	LOOP
			//ENDIF
			//cData := aData:Item[nPos]:ToString()
			DO CASE			
/////////////////////////////////////////////////////////////////////////////////////////////////
//						ADDED BY KIRIAKOS
/////////////////////////////////////////////////////////////////////////////////////////////////
			//CASE cName:StartsWith("DatePickerNull")
			//	IF cData == "No Date Applicable"
			//		((DateTimePickerNull)oControl):Visible := false
			//	ELSE
			//		dDate := DateTime.Parse(cData)
			//		((DateTimePickerNull)oControl):Value := dDate
			//	ENDif
/////////////////////////////////////////////////////////////////////////////////////////////////
//						ADDED BY KIRIAKOS
/////////////////////////////////////////////////////////////////////////////////////////////////
			CASE cName:StartsWith("DatePicker")
				IF cData == "No Date Applicable"
					((System.Windows.Forms.DateTimePicker)oControl):Visible := FALSE
				ELSE
					dDate := DateTime.Parse(cData)
					((System.Windows.Forms.DateTimePicker)oControl):Value := dDate
				ENDIF
			CASE cName:StartsWith("TextBox")
				oControl:Text := cData
				
			CASE cName:StartsWith("DD") .and. cData != ""
				LOCAL oDateTimePicker := replaceButtonWithDate(oControl) as DateTimePicker
				IF cData == "No Date Applicable"
					oDateTimePicker:Visible := false
				ELSE
					dDate := DateTime.Parse(cData)
					oDateTimePicker:Value := dDate
				ENDIF
				
			CASE cName:StartsWith("ComboBox")
				((System.Windows.Forms.ComboBox)oControl):Text := cData

			CASE cName:StartsWith("NumericTextBox")
				oControl:Text := cData:Replace(".", oMainForm:decimalSeparator)

			CASE cName:StartsWith("CheckBox")
				IF cData == "1"
					((System.Windows.Forms.CheckBox)oControl):Checked := TRUE
				ENDIF

			CASE cName:StartsWith("GeoDeg")
				IF ! SElF:GeoValueToDegMinSecNSEW(cData, cDeg, cMin, cSec, cNSEW)
					ErrorBox("Cannot analyse the value: "+cData)
					EXIT
				ENDIF
				oControl:Text := cDeg

			CASE cName:StartsWith("GeoMin")
				oControl:Text := cMin

			CASE cName:StartsWith("GeoSec")
				oControl:Text := cSec:Replace(".", oMainForm:decimalSeparator)

			CASE cName:StartsWith("GeoNSEW")
				//wb(((System.Windows.Forms.ComboBox)oControl):SelectedIndex:Tostring()+CRLF+((System.Windows.Forms.ComboBox)oControl):Items:Count:ToString()+CRLF+(cNSEW == "N"):Tostring(), "|"+cNSEW+"|")
				IF cNSEW == "N" .or. cNSEW == "E"
					((System.Windows.Forms.ComboBox)oControl):SelectedIndex := 0
				ELSE
					((System.Windows.Forms.ComboBox)oControl):SelectedIndex := 1
				ENDIF
			ENDCASE
			CATCH
				wb(cName+CRLF+cItemUID+CRLF+cData, "")
			END
			endif 
		NEXT
		//////////////////////////////////////////////////////////////////////////////////////////
	NEXT
RETURN

METHOD GetGeoCoordinate(cItemUID AS STRING) AS STRING
	LOCAL cRet := "" AS STRING

	LOCAL oGeoDeg := SELF:GetControl("GeoDeg", cItemUID) AS Control
	IF oGeoDeg == NULL
		RETURN ""
	ENDIF
	LOCAL cDegrees := oGeoDeg:Text AS STRING

	LOCAL oGeoMin := SELF:GetControl("GeoMin", cItemUID) AS Control
	IF oGeoMin == NULL
		RETURN ""
	ENDIF
	LOCAL nMin := Convert.ToDouble(oGeoMin:Text) AS Double

	LOCAL oGeoSec := SELF:GetControl("GeoSec", cItemUID) AS Control
	IF oGeoSec == NULL
		RETURN ""
	ENDIF
	LOCAL nSec := Convert.ToDouble(oGeoSec:Text:Replace(".", SELF:decimalSeparator)) AS Double
	nSec := nSec * (Double)100 / (Double)60
	IF nSec >= (Double)60
		nMin := nMin + (Double)1
		nSec -= (Double)60
	ENDIF
	IF nMin >= (Double)60
		cDegrees := (Convert.ToInt32(cDegrees) + 1):ToString()
	ENDIF

	LOCAL cMin := nMin:ToString() AS STRING
	IF nMin < 10
		cMin := "0" + cMin
	ENDIF

	LOCAL cSec := nSec:ToString() AS STRING
	IF nSec < (Double)10
		cSec := "0" + cSec
	ENDIF
	cSec := cSec:Replace(SELF:decimalSeparator, "")
	IF cSec:Length > 4
		cSec := cSec:Substring(0, 4)
	ENDIF

	cRet := cDegrees + cMin + "." + cSec
RETURN cRet

METHOD GeoValueToDegMinSecNSEW(cData AS STRING, cDeg REF STRING, cMin REF STRING, cSec REF STRING, cNSEW REF STRING) AS LOGIC
	LOCAL cGeoValue AS STRING
	LOCAL nPos AS INT

	cGeoValue := cData
	nPos := cGeoValue:IndexOf("°")
	IF nPos == -1
		RETURN FALSE
	ENDIF
	cDeg := cGeoValue:Substring(0, nPos)
	cGeoValue := cGeoValue:Substring(nPos + 1)

	nPos := cGeoValue:IndexOf("'")
	IF nPos == -1
		RETURN FALSE
	ENDIF
	cMin := cGeoValue:Substring(0, nPos)
	cGeoValue := cGeoValue:Substring(nPos + 1)

	nPos := cGeoValue:IndexOf("''")
	IF nPos == -1
		RETURN FALSE
	ENDIF
	cSec := cGeoValue:Substring(0, nPos)
	cGeoValue := cGeoValue:Substring(nPos + 2)

	cNSEW := cGeoValue
RETURN TRUE

METHOD CreateDirectory(cDir AS STRING) AS LOGIC
	// Create TempDoc directory
	LOCAL oDirectoryInfo:=DirectoryInfo{cDir} AS DirectoryInfo

	IF ! oDirectoryInfo:Exists
		TRY
			oDirectoryInfo:Create()
		CATCH e AS Exception
			MessageBox.Show(e:Message, "CreateDirectory", MessageBoxButtons.OK, MessageBoxIcon.Error)
			RETURN FALSE
		END TRY
	ENDIF
RETURN TRUE

METHOD ClearDirectory(cDir AS STRING, nKeepLastDays AS Double) AS VOID
	// Delete all files from Directory
	LOCAL n, nCount AS INT
	LOCAL dDeletionDate AS DateTime
	LOCAL cNow := DateTime.Now:ToString("yyyy-MM-dd HH:mm:ss") AS STRING

	// Directories
	SELF:CreateDirectory(cDir)
	LOCAL oDirectories:=Directory.GetDirectories(cDir) AS STRING[]
	LOCAL oDirectoryInfo  AS DirectoryInfo 
	nCount:=oDirectories:Length
	FOR n:=1 UPTO nCount
		oDirectoryInfo := DirectoryInfo{oDirectories[n]}
		dDeletionDate:=oDirectoryInfo:LastWriteTime
		dDeletionDate:=dDeletionDate:AddDays(nKeepLastDays)
		IF dDeletionDate:ToString("yyyy-MM-dd HH:mm:ss") < cNow
			TRY
				System.IO.Directory.Delete(oDirectories[n], TRUE)
				Application.DoEvents()
			CATCH
			END TRY
		ENDIF
	NEXT

	// Files
	LOCAL oFiles:=Directory.GetFiles(cDir) AS STRING[]
	LOCAL oFileInfo AS FileInfo
	nCount:=oFiles:Length
	FOR n:=1 UPTO nCount
		oFileInfo:=FileInfo{oFiles[n]}
		dDeletionDate:=oFileInfo:LastWriteTime
		dDeletionDate:=dDeletionDate:AddDays(nKeepLastDays)
		IF dDeletionDate:ToString("yyyy-MM-dd HH:mm:ss") < cNow
			TRY
				oFileInfo:Delete()
				Application.DoEvents()
			CATCH
			END TRY
		ENDIF
	NEXT
RETURN

METHOD  GetBytes(str AS STRING) AS BYTE[]
	local iLength := (int)(str:Length * sizeof(char))  as int 	
    LOCAL  bytes := BYTE[]{iLength} AS BYTE[]
    System.Buffer.BlockCopy(str:ToCharArray(), 0, bytes, 0, bytes:Length)
RETURN bytes


METHOD GetString(bytes AS BYTE[]) AS STRING
	local iLength  := (int)(bytes:Length / sizeof(char))  as int 
    LOCAL chars := char[]{iLength} AS char[]
    System.Buffer.BlockCopy(bytes, 0, chars, 0, bytes:Length)
    LOCAL final := STRING{chars}  AS STRING
RETURN final

METHOD GetPreviousNumberOfFiles(cName AS STRING) AS INT
	LOCAL iTestForInt AS INT
	IF cName:Substring(0,1):Equals("S")
		RETURN 1
	ELSEIF cName:Substring(0,1):Equals("U")
		RETURN 0
	ELSE		
		LOCAL c AS STRING
			c := cName:Substring(0,cName:IndexOf(' '))
			//MessageBox.Show(c,"info")
			int32.TryParse(c,iTestForInt)
	ENDIF
RETURN iTestForInt

METHOD GetFileUID(cName AS STRING) AS STRING
	LOCAL cIteUID := "", c AS STRING
TRY		
	LOCAL n, nLen := cName:Length - 1 AS INT
	LOCAL iTestForInt AS INT
	// Get IteUID from the right part of Control:Name
	FOR n:=nLen DOWNTO 0
		c := cName:Substring(n, 1)
		IF !int32.TryParse(c,iTestForInt)
			EXIT
		ENDIF
		cIteUID := c + cIteUID
	NEXT
CATCH
	MessageBox.show("Error while getting UID from file.")
	RETURN ""
END
RETURN cIteUID

EXPORT METHOD saveNormalValues2() AS LOGIC
	LOCAL lHasChanged := false AS LOGIC
	TRY
		LOCAL cData:="",cName,cItemUID,cPrevData AS STRING
		LOCAL oRows as DataRow[]
		
		FOREACH oTabPage AS System.Windows.Forms.TabPage IN SELF:tabControl_Report:TabPages
			cData := ""
			FOREACH oControl AS Control IN oTabPage:Controls
				TRY
					cName := oControl:Name
					DO CASE
					CASE cName:StartsWith("button")
						LOOP
					CASE cName:StartsWith("Label")
						LOOP
					CASE cName:StartsWith("Table")
						LOOP
					CASE cName:StartsWith("NumericTextBoxGMT")
						LOOP
					CASE cName:StartsWith("DatePickerGMT")
						LOOP
					///////////////////////////////////////////////////////////						
					//		ADDED BY KIRIAKOS
					///////////////////////////////////////////////////////////
					CASE cName:StartsWith("DatePickerNullGMT")
						LOOP
					///////////////////////////////////////////////////////////						
					//		ADDED BY KIRIAKOS
					///////////////////////////////////////////////////////////
					CASE cName:StartsWith("TextBoxMultiline")
						LOOP
					///////////////////////////////////////////////////////////						
					//		ADDED BY KIRIAKOS
					///////////////////////////////////////////////////////////
					//CASE cName:StartsWith("DatePickerNull")
					//	IF ((DateTimePickerNull)oControl):Text:Trim() == ""
					//		cData := ""
					//	ELSE
					//		cData := DateTime.Parse(((DateTimePickerNull)oControl):Text):ToString("yyyy-MM-dd HH:mm")
					//	ENDIF
					///////////////////////////////////////////////////////////						
					//		ADDED BY KIRIAKOS
					///////////////////////////////////////////////////////////
					CASE cName:StartsWith("DatePicker")
						cData := ((System.Windows.Forms.DateTimePicker)oControl):Value:ToString("yyyy-MM-dd HH:mm")
					CASE cName:StartsWith("TextBox")
						cData := oControl:Text:Trim()
					CASE cName:StartsWith("NumericTextBox")
						cData := oControl:Text:Trim():Replace(SELF:groupSeparator, ""):Replace(SELF:decimalSeparator, ".")
					CASE cName:StartsWith("CheckBox")
						IF ((System.Windows.Forms.CheckBox)oControl):Checked
							cData := "1"
						ELSE
							cData := "0"
						ENDIF
					CASE cName:StartsWith("ComboBox")
						cData := ((System.Windows.Forms.ComboBox)oControl):Text
					// Lat/Long:
					CASE cName:StartsWith("GeoDeg")
						IF oControl:Text:Trim() <> ""
							cData := oControl:Text:Trim()+"°"
						ENDIF
						LOOP
					CASE cName:StartsWith("GeoMin")
						IF oControl:Text:Trim() <> ""
							cData += oControl:Text:Trim()+"'"
						ENDIF
						LOOP
					CASE cName:StartsWith("GeoSec")
						IF oControl:Text:Trim() <> ""
							cData += oControl:Text:Trim():Replace(SELF:groupSeparator, ""):Replace(SELF:decimalSeparator, ".")+"''"
						ENDIF
						LOOP

					CASE cName:StartsWith("GeoNSEW")
						IF oControl:Text:Trim() <> ""
							cData += oControl:Text
						ENDIF
					CASE cName:StartsWith("FileUploader")
						LOOP
					OTHERWISE
						ErrorBox("Unhandled type found for Control: "+oControl:ToString())
						Loop
					ENDCASE

					IF cData <> "" // If there are data available
						cItemUID := SELF:GetItemUID(cName)
						//Check if the data is same as when the report was loaded
						oRows := SELF:oDTFMData:Select("ITEM_UID="+cItemUID)
						IF oRows == NULL .or. oRows:Length==0 // The data did not exist on vessel's/preivous dataset insert it to FMdata.
							SELF:insertIntoFMData(SELF:oDTFMData:Rows[0]:Item["PACKAGE_UID"]:ToString(),cItemUID,cData)
							LOOP
						ENDIF
						cPrevData := oRows[1]:Item["Data"]:ToString()
						//messagebox.Show(cPrevData)
						IF cData == cPrevData
							LOOP
						ELSE
							self:updateFMDataForPackageUIDandItemUID(oRows[1]:Item["PACKAGE_UID"]:ToString(),cItemUID,cData,cPrevData)
						ENDIF
						// In order to check if Coordinates or DateTime is checked
						IF cItemUID ==  DateTime_ItemUID
							self:changeDateTime(cData,cItemUID,SELF:oDTFMData:Rows[0]:Item["PACKAGE_UID"]:ToString())
						elseif 	cItemUID ==  Latitude_ItemUID
							SELF:changeLatitude(cData,cItemUID,SELF:oDTFMData:Rows[0]:Item["PACKAGE_UID"]:ToString())
						elseif 	cItemUID ==  Longitude_ItemUID
							SELF:changeLongitude(cData,cItemUID,SELF:oDTFMData:Rows[0]:Item["PACKAGE_UID"]:ToString())
						ENDIF
						
					ENDIF
				CATCH exc as Exception
					messagebox.Show(exc:tostring())
					LOOP
				END
			NEXT
		NEXT
	CATCH exc AS Exception
		messagebox.Show(exc:tostring())
	END
RETURN	lHasChanged


EXPORT METHOD saveNormalValues(cNewPackageUID := "" as String ) AS LOGIC
	LOCAL lHasChanged := false AS LOGIC
	TRY
		LOCAL cData:="",cName,cItemUID,cPrevData AS STRING
		LOCAL oRows as DataRow[]
		
		FOREACH oTabPage AS System.Windows.Forms.TabPage IN SELF:tabControl_Report:TabPages
			cData := ""
			FOREACH oControl AS Control IN oTabPage:Controls
				TRY
					IF oControl:HasChildren
						FOREACH oSecControl AS Control IN oControl:Controls
					//////////////////////////////////////////////////////////////////////////////////////
								cName := oSecControl:Name
								DO CASE
								CASE cName:StartsWith("button")
									LOOP
								CASE cName:StartsWith("DD")
									LOOP	
								CASE cName:StartsWith("Table")
									LOOP
								CASE cName:StartsWith("Label")
									LOOP
								CASE cName:StartsWith("NumericTextBoxGMT")
									LOOP
					//////////////////////////////////////////////////////////////////////////////////////
					//			ADDED BY KIRIAKOS
					//////////////////////////////////////////////////////////////////////////////////////
								CASE cName:StartsWith("DatePickerNullGMT")
									LOOP
					//////////////////////////////////////////////////////////////////////////////////////
					//			ADDED BY KIRIAKOS
					//////////////////////////////////////////////////////////////////////////////////////
								CASE cName:StartsWith("DatePickerGMT")
									LOOP
								CASE cName:StartsWith("TextBoxMultiline")
									LOOP
					//////////////////////////////////////////////////////////////////////////////////////
					//			ADDED BY KIRIAKOS
					//////////////////////////////////////////////////////////////////////////////////////
								//CASE cName:StartsWith("DatePickerNull")
								//	IF ((DateTimePickerNull)oSecControl):Text:Trim() == ""
								//		cData := ""
								//	ELSE
								//		cData := DateTime.Parse(((DateTimePickerNull)oSecControl):Text):ToString("yyyy-MM-dd HH:mm")
								//	ENDIF
					//////////////////////////////////////////////////////////////////////////////////////
					//			ADDED BY KIRIAKOS
					//////////////////////////////////////////////////////////////////////////////////////
								CASE cName:StartsWith("DatePicker")
									cData := ((System.Windows.Forms.DateTimePicker)oSecControl):Value:ToString("yyyy-MM-dd HH:mm")
								CASE cName:StartsWith("TextBox")
									cData := oSecControl:Text:Trim()
								CASE cName:StartsWith("NumericTextBox")
									cData := oSecControl:Text:Trim():Replace(SELF:groupSeparator, ""):Replace(SELF:decimalSeparator, ".")
								CASE cName:StartsWith("CheckBox")
									IF ((System.Windows.Forms.CheckBox)oSecControl):Checked
										cData := "1"
									ELSE
										cData := "0"
									ENDIF
								CASE cName:StartsWith("ComboBox")
									cData := ((System.Windows.Forms.ComboBox)oSecControl):Text
								// Lat/Long:
								CASE cName:StartsWith("GeoDeg")
									IF oSecControl:Text:Trim() <> ""
										cData := oSecControl:Text:Trim()+"°"
									ENDIF
									LOOP
								CASE cName:StartsWith("GeoMin")
									IF oSecControl:Text:Trim() <> ""
										cData += oSecControl:Text:Trim()+"'"
									ENDIF
									LOOP
								CASE cName:StartsWith("GeoSec")
									IF oSecControl:Text:Trim() <> ""
										cData += oSecControl:Text:Trim():Replace(SELF:groupSeparator, ""):Replace(SELF:decimalSeparator, ".")+"''"
									ENDIF
									LOOP

								CASE cName:StartsWith("GeoNSEW")
									IF oSecControl:Text:Trim() <> ""
										cData += oSecControl:Text
									ENDIF
								CASE cName:StartsWith("FileUploader")
									LOOP
								OTHERWISE
									ErrorBox("Unhandled type found for Control: "+oSecControl:ToString())
									Loop
								ENDCASE

								LOCAL cPackageUIDLocal AS STRING
								IF cNewPackageUID <> ""
									cPackageUIDLocal := cNewPackageUID
								ELSEIF SELF:oDTFMData:rows:Count == 0
									cPackageUIDLocal  := self:cMyPackageUID //23.12
								ELSE
									cPackageUIDLocal := SELF:oDTFMData:Rows[0]:Item["PACKAGE_UID"]:ToString()
								ENDIF

								//IF cData <> "" // If there are data available
									cItemUID := SELF:GetItemUID(cName)
									//Check if the data is same as when the report was loaded
									//Check if the data is same as when the report was loaded
									IF cNewPackageUID <> ""
										IF cData<>""
											SELF:insertIntoFMData(cPackageUIDLocal,cItemUID,cData)
											IF cItemUID ==  DateTime_ItemUID
												SELF:changeDateTime(cData,cItemUID,cPackageUIDLocal)
											ENDIF
										ENDIF
										LOOP
									ELSE
										oRows := SELF:oDTFMData:Select("ITEM_UID="+cItemUID)
										IF oRows == NULL .or. oRows:Length==0 // The data did not exist on vessel's/preivous dataset insert it to FMdata.
											IF cData<>""
											SELF:insertIntoFMData(cPackageUIDLocal,cItemUID,cData)
											ENDIF
											LOOP
										ENDIF
									ENDIF
									cPrevData := oRows[1]:Item["Data"]:ToString()
									//messagebox.Show(cPrevData)
									IF cData == cPrevData
										LOOP
									ELSE
										self:updateFMDataForPackageUIDandItemUID(cPackageUIDLocal,cItemUID,cData,cPrevData)
									ENDIF
									// In order to check if Coordinates or DateTime is checked
									IF cItemUID ==  DateTime_ItemUID
										self:changeDateTime(cData,cItemUID,cPackageUIDLocal)
									elseif 	cItemUID ==  Latitude_ItemUID
										SELF:changeLatitude(cData,cItemUID,cPackageUIDLocal)
									elseif 	cItemUID ==  Longitude_ItemUID
										SELF:changeLongitude(cData,cItemUID,cPackageUIDLocal)
									ENDIF
								//ENDIF
						NEXT
						/////////////////////////////////////////////////////////////////////
					ELSE
						/////////////////////////////////////////////////////////////////////
						cName := oControl:Name
						DO CASE
						CASE cName:StartsWith("button")
							LOOP
						CASE cName:StartsWith("Table")
							LOOP	
						CASE cName:StartsWith("Label")
							LOOP
						CASE cName:StartsWith("NumericTextBoxGMT")
							LOOP
					//////////////////////////////////////////////////////////////////////////////////////
					//			ADDED BY KIRIAKOS
					//////////////////////////////////////////////////////////////////////////////////////
						CASE cName:StartsWith("DatePickerNullGMT")
							LOOP
					//////////////////////////////////////////////////////////////////////////////////////
					//			ADDED BY KIRIAKOS
					//////////////////////////////////////////////////////////////////////////////////////
						CASE cName:StartsWith("DatePickerGMT")
							LOOP
						CASE cName:StartsWith("TextBoxMultiline")
							LOOP
					//////////////////////////////////////////////////////////////////////////////////////
					//			ADDED BY KIRIAKOS
					//////////////////////////////////////////////////////////////////////////////////////
						//CASE cName:StartsWith("DatePickerNull")
						//	IF ((DateTimePickerNull)oControl):Text:Trim() == ""
						//		cData := ""
						//	ELSE
						//		cData := DateTime.Parse(((DateTimePickerNull)oControl):Text):ToString("yyyy-MM-dd HH:mm")
						//	ENDIF
							//cData := ((DateTimePickerNull)oControl):Value:ToString("yyyy-MM-dd HH:mm")
					//////////////////////////////////////////////////////////////////////////////////////
					//			ADDED BY KIRIAKOS
					//////////////////////////////////////////////////////////////////////////////////////
						CASE cName:StartsWith("DatePicker")
							cData := ((System.Windows.Forms.DateTimePicker)oControl):Value:ToString("yyyy-MM-dd HH:mm")
						CASE cName:StartsWith("TextBox")
							cData := oControl:Text:Trim()
						CASE cName:StartsWith("NumericTextBox")
							cData := oControl:Text:Trim():Replace(SELF:groupSeparator, ""):Replace(SELF:decimalSeparator, ".")
						CASE cName:StartsWith("CheckBox")
							IF ((System.Windows.Forms.CheckBox)oControl):Checked
								cData := "1"
							ELSE
								cData := "0"
							ENDIF
						CASE cName:StartsWith("ComboBox")
							cData := ((System.Windows.Forms.ComboBox)oControl):Text
						// Lat/Long:
						CASE cName:StartsWith("GeoDeg")
							IF oControl:Text:Trim() <> ""
								cData := oControl:Text:Trim()+"°"
							ENDIF
							LOOP
						CASE cName:StartsWith("GeoMin")
							IF oControl:Text:Trim() <> ""
								cData += oControl:Text:Trim()+"'"
							ENDIF
							LOOP
						CASE cName:StartsWith("GeoSec")
							IF oControl:Text:Trim() <> ""
								cData += oControl:Text:Trim():Replace(SELF:groupSeparator, ""):Replace(SELF:decimalSeparator, ".")+"''"
							ENDIF
							LOOP

						CASE cName:StartsWith("GeoNSEW")
							IF oControl:Text:Trim() <> ""
								cData += oControl:Text
							ENDIF
						CASE cName:StartsWith("FileUploader")
							LOOP
						CASE cName:StartsWith("DD")
							LOOP	
						OTHERWISE
							ErrorBox("Unhandled type found for Control: "+oControl:ToString())
							Loop
						ENDCASE

						//IF cData <> "" // If there are data available
							cItemUID := SELF:GetItemUID(cName)
							
							LOCAL cPackageUIDLocal AS STRING
								IF cNewPackageUID <> ""
									cPackageUIDLocal := cNewPackageUID
								ELSEIF SELF:oDTFMData:rows:Count == 0
									cPackageUIDLocal  :=  cMyPackageUID // 23.12 oMainForm:TreeListVesselsReports:FocusedNode:Tag:ToString()
								ELSE
									cPackageUIDLocal := SELF:oDTFMData:Rows[0]:Item["PACKAGE_UID"]:ToString()
								ENDIF
							
							//Check if the data is same as when the report was loaded
							IF cNewPackageUID <> ""
								IF cData<>""
									SELF:insertIntoFMData(cPackageUIDLocal,cItemUID,cData)
									IF cItemUID ==  DateTime_ItemUID
										SELF:changeDateTime(cData,cItemUID,cPackageUIDLocal)
									ENDIF
								ENDIF
								LOOP
							ELSE
								oRows := SELF:oDTFMData:Select("ITEM_UID="+cItemUID)
								IF oRows == NULL .or. oRows:Length==0 // The data did not exist on vessel's/previous dataset insert it to FMdata.
									IF cData<>""
									SELF:insertIntoFMData(cPackageUIDLocal,cItemUID,cData)
									ENDIF
									LOOP
								ENDIF
							ENDIF
							
							cPrevData := oRows[1]:Item["Data"]:ToString()
							//messagebox.Show(cPrevData)
							IF cData == cPrevData
								cPrevData := ""
								LOOP
							ELSE
								self:updateFMDataForPackageUIDandItemUID(cPackageUIDLocal,cItemUID,cData,cPrevData)
							ENDIF
							// In order to check if Coordinates or DateTime is checked
							IF cItemUID ==  DateTime_ItemUID
								self:changeDateTime(cData,cItemUID,cPackageUIDLocal)
							elseif 	cItemUID ==  Latitude_ItemUID
								SELF:changeLatitude(cData,cItemUID,cPackageUIDLocal)
							elseif 	cItemUID ==  Longitude_ItemUID
								SELF:changeLongitude(cData,cItemUID,cPackageUIDLocal)
							ENDIF
						
						//ENDIF
						/////////////////////////////////////////////////////////////////////
					ENDIF
				CATCH exc as Exception
					messagebox.Show(exc:tostring())
					LOOP
				END
			NEXT
		NEXT
		self:RefreshoDTFMData()
	CATCH exc AS Exception
		self:RefreshoDTFMData()
		messagebox.Show(exc:tostring())
	END
RETURN	lHasChanged

EXPORT METHOD changeDateTime(cLatString AS STRING, cItemUID AS STRING, cPackageUID AS STRING) AS VOID
	LOCAL cDateGMT := "" as String
	LOCAL oControlDatePickerGMT := SELF:GetControl("DatePickerGMT", SELF:DateTime_ItemUID) AS Control
		IF oControlDatePickerGMT <> NULL
			cDateGMT :=((System.Windows.Forms.DateTimePicker)oControlDatePickerGMT):Value:ToString("yyyy-MM-dd HH:mm") 
		ELSE 
			RETURN
		ENDIF
	LOCAL cStatement AS STRING
	TRY
		cStatement :="Update FMDataPackages SET DateTimeGMT ='"+;
					oSoftway:ConvertWildcards(cDateGMT, FALSE)+"' WHERE Package_Uid ="+cPackageUID
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
	CATCH exc AS Exception
		messagebox.Show(cStatement+" / "+exc:tostring())
	END
RETURN

EXPORT METHOD changeLatitude(cLatString as String, cItemUID as string, cPackageUID as STRING) as Void
	LOCAL cDecimalCoordinates := "" AS STRING
	cDecimalCoordinates := SELF:GetGeoCoordinate(cItemUID)
	//MessageBox.Show(cDecimalCoordinates)
	LOCAL cStatement AS STRING
	TRY
		cStatement :="Update  FMDataPackages SET Latitude ='"+;
					oSoftway:ConvertWildcards(cDecimalCoordinates, FALSE)+"' WHERE Package_Uid ="+cPackageUID
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
	CATCH exc AS Exception
		messagebox.Show(cStatement+" / "+exc:tostring())
	END
RETURN

EXPORT METHOD changeLongitude(cLatString as String, cItemUID as string, cPackageUID as STRING) as Void
	LOCAL cDecimalCoordinates := "" AS STRING
	cDecimalCoordinates := SELF:GetGeoCoordinate(cItemUID)
	//MessageBox.Show(cDecimalCoordinates)
	LOCAL cStatement AS STRING
	TRY
		cStatement :="Update  FMDataPackages SET Longitude ='"+;
					oSoftway:ConvertWildcards(cDecimalCoordinates, FALSE)+"' WHERE Package_Uid ="+cPackageUID
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
	CATCH exc AS Exception
		messagebox.Show(cStatement+" / "+exc:tostring())
	END
RETURN

EXPORT METHOD insertIntoFMData(cPackageUID AS STRING,cItemUID AS STRING,cData AS STRING) AS VOID
	LOCAL cStatement AS STRING
	TRY
		cStatement :="INSERT INTO FMData (PACKAGE_UID, ITEM_UID, DATA)"+;
					" VALUES ("+cPackageUID+", "+cItemUID+" ,'"+oSoftway:ConvertWildcards(cData, FALSE)+"' )"
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
	CATCH exc AS Exception
		messagebox.Show(cStatement+" / "+exc:tostring())
	END
RETURN

EXPORT METHOD updateFMDataForPackageUIDandItemUID(cPackageUID AS STRING,cItemUID AS STRING,cData AS STRING,cPreviousData as STRING) AS VOID
	LOCAL cStatement AS STRING
	TRY
		cStatement :="INSERT INTO FMAlteredData (PACKAGE_UID, ITEM_UID, DATA, DateTime, USER_UNIQUEID)"+;
					" VALUES ("+cPackageUID+", "+cItemUID+" ,'"+oSoftway:ConvertWildcards(cPreviousData, FALSE)+"',CURRENT_TIMESTAMP,"+oUser:USER_UNIQUEID+" )"
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		//messagebox.Show(cStatement)
		cStatement :=" UPDATE FMData SET"+;
					 " DATA = '"+oSoftway:ConvertWildcards(cData, FALSE)+"'"+;
				     " WHERE PACKAGE_UID="+cPackageUID+" AND  ITEM_UID="+cItemUID
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
	CATCH exc AS Exception
		messagebox.Show(cStatement+" / "+exc:tostring())
	END
RETURN

EXPORT METHOD updateMemoTo(cPackageUID AS STRING,cNewData AS STRING,cPrevData AS STRING) AS VOID
	LOCAL cStatement AS STRING
	TRY
		cStatement :="INSERT INTO FMAlteredMemos (PACKAGE_UID, Memo, DateTime, USER_UNIQUEID)"+;
					" VALUES ("+cPackageUID+",'"+oSoftway:ConvertWildcards(cPrevData, FALSE)+"',CURRENT_TIMESTAMP,"+oUser:USER_UNIQUEID+" )"
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		//messagebox.Show(cStatement)
		cStatement :=" UPDATE FMDataPackages SET"+;
					 " MEMO = '"+oSoftway:ConvertWildcards(cNewData, FALSE)+"'"+;
				     " WHERE PACKAGE_UID="+cPackageUID
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
	CATCH exc AS Exception
		messagebox.Show(cStatement+" / "+exc:tostring())
	END	
RETURN
EXPORT METHOD updateMemoOnlyTo(cPackageUID AS STRING,cNewData AS STRING) AS VOID
	LOCAL cStatement AS STRING
	TRY
		cStatement :=" UPDATE FMDataPackages SET"+;
					 " MEMO = '"+oSoftway:ConvertWildcards(cNewData, FALSE)+"'"+;
				     " WHERE PACKAGE_UID="+cPackageUID
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
	CATCH exc AS Exception
		messagebox.Show(cStatement+" / "+exc:tostring())
	END	
RETURN

EXPORT METHOD saveMultilineFields(cNewPackageUID := "" as String) AS VOID	
	TRY
		LOCAL cAllMemos,cName,cNewData:="",cPrevData as String
		LOCAL cPackageUID AS STRING
		IF cNewPackageUID == ""
			cPackageUID := oMainForm:TreeListVesselsReports:FocusedNode:Tag:ToString()
		ELSE
			cPackageUID := cNewPackageUID	
		ENDIF
		local cStatement:="SELECT Memo FROM FMDataPackages"+oMainForm:cNoLockTerm+;
					" WHERE PACKAGE_UID="+cPackageUID as String
		cAllMemos := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Memo")
		//MessageBox.Show("Old value : '"+cAllMemos+"'")
		IF cAllMemos <> "" .and. cAllMemos:Contains((char)168)	// New FM
			local cNewAllMemos := SELF:GetAllMultilines() as STRING
			IF cAllMemos==cNewAllMemos
				//Messagebox.Show("No changes made to multiline")
				RETURN
			ELSE
				SELF:updateMemoTo(cPackageUID,cNewAllMemos,cAllMemos)
				RETURN
			ENDIF
		ELSEIF cAllMemos <> "" //Old FM
			//MessageBox.Show(cAllMemos,"Old FM")
			FOREACH oTabPage AS System.Windows.Forms.TabPage IN SELF:tabControl_Report:TabPages
				FOREACH oControl AS Control IN oTabPage:Controls
				TRY
					cName := oControl:Name
					IF cName:StartsWith("TextBoxMultiline")
						//LOCAL cNewMemoData := oControl:Text as String
						//MessageBox.Show(cNewMemoData,"New Data for : "+cPackageUID)
						cPrevData := cAllMemos
						SELF:updateMemoTo(cPackageUID,cNewData,cPrevData)
						RETURN
					ELSE
						LOOP
					endif
				CATCH
					BREAK
				END
				NEXT
			NEXT
		ELSEIF cAllMemos == "" // Update Memo Field Here only do not insert 
			SELF:updateMemoOnlyTo(cPackageUID,self:GetAllMultilines())
		ENDIF
			
	CATCH exc AS Exception
		messagebox.Show(exc:tostring())
	END	
RETURN	


METHOD GetAllMultilines() AS STRING
	LOCAL cTextToReturn := "" AS STRING	
	TRY
	LOCAL cTempName := "" AS STRING
	LOCAL cTempUid := "" AS STRING
	
	FOREACH oTabPage AS System.Windows.Forms.TabPage IN SELF:tabControl_Report:TabPages
		/*FOREACH oControl AS Control IN oTabPage:Controls
			cTempName := oControl:Name
			IF cTempName:StartsWith("TextBoxMultiline")
				cTempUid := cTempName:Substring(16)
				//cTextToReturn +=  cTempUid + chr(168) + oControl:Text + chr(240)
				IF !oControl:Text=="" 
					cTextToReturn +=  cTempUid
					cTextToReturn +=  ((char)168):ToString()  
					cTextToReturn +=  oControl:Text
					cTextToReturn +=  ((char)169):ToString()
				ENDIF
			ENDIF
		NEXT*/
		FOREACH oControl AS Control IN oTabPage:Controls
			IF oControl:HasChildren
				FOREACH oSecControl AS Control IN oControl:Controls
						cTempName := oSecControl:Name
						IF cTempName:StartsWith("TextBoxMultiline")
							cTempUid := cTempName:Substring(16)
							//cTextToReturn +=  cTempUid + chr(168) + oSecControl:Text + chr(240)
							cTextToReturn +=  cTempUid
							cTextToReturn +=  ((char)168):ToString()  
							cTextToReturn +=  oSecControl:Text
							cTextToReturn +=  ((char)169):ToString()
						ENDIF
				NEXT
			ELSE
				cTempName := oControl:Name
				IF cTempName:StartsWith("TextBoxMultiline")
					cTempUid := cTempName:Substring(16)
					//cTextToReturn +=  cTempUid + chr(168) + oControl:Text + chr(240)
					cTextToReturn +=  cTempUid
					cTextToReturn +=  ((char)168):ToString()  
					cTextToReturn +=  oControl:Text
					cTextToReturn +=  ((char)169):ToString()
				ENDIF
			ENDIF
		NEXT
	NEXT
	CATCH
		wb("Error","Error in GetAllMultilines.")
		RETURN ""
	END	
RETURN cTextToReturn

METHOD checkMandatoryFields() AS logic
		IF !SELF:ValidateMandatoryFields()
			RETURN false
		ENDIF
RETURN true

METHOD ValidateMandatoryFields() AS LOGIC
	TRY
				
	LOCAL cMandatory, cValue, cUID, cItemTypeValues := "",cUidToCheck, cData := "", cItemNo AS STRING
	LOCAL oRows AS DataRow[]
	//LOCAL oSecRows as DataRow[]
	LOCAL oTempControl as Control
	local lIsMandatoryOnCondition := false as logic	
	

	FOREACH oTabPage AS System.Windows.Forms.TabPage IN SELF:tabControl_Report:TabPages
		FOREACH oControl AS Control IN oTabPage:Controls
			
			LOCAL cName := oControl:Name AS STRING
			DO CASE
				CASE cName:StartsWith("Label")
					LOOP
				CASE cName:StartsWith("button")
							LOOP
				CASE cName:StartsWith("Table")
					IF !SELF:ValidateMandatoryFields(oControl)
						RETURN FALSE
					ENDIF
					LOOP
				CASE cName:StartsWith("NumericTextBoxGMT")
					LOOP

		///////////////////////////////////////////////////////////////////
		//				ADDED BY KIRIAKOS
		///////////////////////////////////////////////////////////////////
				CASE cName:StartsWith("DatePickerNullGMT")
					LOOP
		///////////////////////////////////////////////////////////////////
		//				ADDED BY KIRIAKOS
		///////////////////////////////////////////////////////////////////
		
				CASE cName:StartsWith("DatePickerGMT")
					LOOP
				CASE cName:StartsWith("FileUploader")
					LOOP
				CASE cName:StartsWith("DD")
					LOOP	
			ENDCASE
			// Combobox 
			cUID := GetItemUID(cName)			
			//WB(cName)
			oRows := SELF:oDTReportItems:Select("REPORT_UID="+SELF:cReportUID+" AND ITEM_UID="+cUID, "ITEM_UID")
			FOREACH oRow AS DataRow IN oRows
				cItemNo := oRow["ItemNo"]:ToString()
			next
			//Bring all comboz
			oRows := SELF:oDTReportItems:Select("REPORT_UID="+SELF:cReportUID, "ITEM_UID") 
			//Check if the ID of the control is inside
			FOREACH oRow AS DataRow IN oRows
				cUidToCheck :=  oRow["ITEM_UID"]:ToString()
				cItemTypeValues := oRow["ItemTypeValues"]:ToString()
				//MessageBox.Show(cItemTypeValues+".",cName)
				IF cItemTypeValues != ""
					IF cItemTypeValues:Contains("<ID"+cItemNo+">")
						//MessageBox.Show("test")
						oTempControl := GetControl("ComboBox", cUidToCheck)
						cData := ((System.Windows.Forms.ComboBox)oTempControl):Text
						cItemTypeValues := cItemTypeValues:TrimEnd(';')
						LOCAL cItems := cItemTypeValues:Split(';') AS STRING[]
						FOREACH cItem AS STRING IN cItems
							IF cItem:Contains("<ID"+cItemNo+">")
								//MessageBox.Show(cItem+".",cData+".")
								cItem := cItem:Replace("<ID"+cItemNo+">","")
								//MessageBox.Show(cItem+".",cData+".")
								cItem := cItem:Replace("<D>","")
								//MessageBox.Show(cItem+".",cData+".")
								IF cData == cItem // The value of the combo makes the field Mandatory
									lIsMandatoryOnCondition := TRUE
									LOOP
								ENDIF
							ENDIF
						NEXT
						//Found that the Field is subject to a combo value,check if this value is the one.
					ENDIF
				ENDIF
				cItemTypeValues := ""
				cUidToCheck :=  ""
			NEXT
			cMandatory := (STRING)oControl:Tag
			IF cMandatory == "0" .and. !lIsMandatoryOnCondition
				LOOP
			ENDIF

			cValue := oControl:Text:Trim()
			IF cValue == ""
				SELF:tabControl_Report:SelectedTab := oTabPage
				LOCAL cItemUID := SELF:GetItemUID(oControl:Name) AS STRING
				LOCAL cLabel := SELF:GetLabel(cItemUID, oTabPage) AS STRING
				MessageBox.Show("You have to specify a value for: "+CRLF+CRLF+cLabel, "Mandatory field", MessageBoxButtons.OK, MessageBoxIcon.Error)
				//				
				LOCAL lExit := FALSE AS LOGIC
				LOCAL oTabTester AS TabPage
				LOCAL iTestTabs AS INT
				LOCAL oControlToTest := oControl  as Control
				
				WHILE !lExit
					TRY 
						oTabTester := (TabPage)oControlToTest:Parent
						iTestTabs := SELF:tabControl_Report:TabPages:IndexOf(oTabTester)
						SELF:tabControl_Report:SelectedIndex := iTestTabs
						lExit := TRUE
					CATCH
						oControlToTest := oControlToTest:Parent
					END
				ENDDO
				//
				oControl:Focus()
				oMainForm:BBIEditReport_ItemClick(null,null)
				RETURN FALSE
			ENDIF
			lIsMandatoryOnCondition := false
		NEXT
	NEXT
	
	CATCH exc AS Exception
		MessageBox.Show(exc:StackTrace:ToString())
	END
	
RETURN TRUE


METHOD ValidateMandatoryFields(oParentControl as Control) AS LOGIC
	LOCAL cMandatory, cValue, cUID, cItemTypeValues := "",cUidToCheck, cData := "", cItemNo AS STRING
	LOCAL oRows AS DataRow[]
	//LOCAL oSecRows as DataRow[]
	LOCAL oTempControl as Control
	local lIsMandatoryOnCondition := false as logic	
	
		FOREACH oControl AS Control IN oParentControl:Controls
			LOCAL cName := oControl:Name AS STRING
			DO CASE
				CASE cName:StartsWith("Label")
					LOOP
				CASE cName:StartsWith("NumericTextBoxGMT")
					LOOP
		///////////////////////////////////////////////////////////////////
		//				ADDED BY KIRIAKOS
		///////////////////////////////////////////////////////////////////
				CASE cName:StartsWith("DatePickerNullGMT")
					LOOP
		///////////////////////////////////////////////////////////////////
		//				ADDED BY KIRIAKOS
		///////////////////////////////////////////////////////////////////
				CASE cName:StartsWith("DatePickerGMT")
					LOOP
				CASE cName:StartsWith("FileUploader")
					LOOP
				CASE cName:StartsWith("DD")
					LOOP	
			ENDCASE
			// Combobox 
			cUID := GetItemUID((STRING)oControl:Name)			
			oRows := SELF:oDTReportItems:Select("REPORT_UID="+SELF:cReportUID+" AND ITEM_UID="+cUID, "ITEM_UID")
			FOREACH oRow AS DataRow IN oRows
				cItemNo := oRow["ItemNo"]:ToString()
			next
			//Bring all comboz
			oRows := SELF:oDTReportItems:Select("REPORT_UID="+SELF:cReportUID, "ITEM_UID") 
			//Check if the ID of the control is inside
			FOREACH oRow AS DataRow IN oRows
				cUidToCheck :=  oRow["ITEM_UID"]:ToString()
				cItemTypeValues := oRow["ItemTypeValues"]:ToString()
				IF cItemTypeValues != ""
					IF cItemTypeValues:Contains("<ID"+cItemNo+">")
						oTempControl := GetControl("ComboBox", cUidToCheck)
						cData := ((System.Windows.Forms.ComboBox)oTempControl):Text
						cItemTypeValues := cItemTypeValues:TrimEnd(';')
						LOCAL cItems := cItemTypeValues:Split(';') AS STRING[]
						FOREACH cItem AS STRING IN cItems
							IF cItem:Contains("<ID"+cItemNo+">")
								cItem := cItem:Replace("<ID"+cItemNo+">","")
								cItem := cItem:Replace("<D>","")
								IF cData == cItem // The value of the combo makes the field Mandatory
									lIsMandatoryOnCondition := TRUE
									LOOP
								ENDIF
							ENDIF
						NEXT
						//Found that the Field is subject to a combo value,check if this value is the one.
					ENDIF
				ENDIF
				cItemTypeValues := ""
				cUidToCheck :=  ""
			NEXT
			cMandatory := (STRING)oControl:Tag
			IF (cMandatory == "0" .or. cMandatory == null) .and. !lIsMandatoryOnCondition
				LOOP
			ENDIF
			cValue := oControl:Text:Trim()
			//MessageBox.Show("testing :"+oControl:Name:ToString(),cValue+"U")
			IF cValue == ""
				//LOCAL cItemUID := SELF:GetItemUID(oControl:Name) AS STRING
				//LOCAL cLabel := SELF:GetLabel(cItemUID, oParentControl) AS STRING
				MessageBox.Show("You have to specify a value for: "+CRLF+CRLF+cItemNo, "Mandatory field", MessageBoxButtons.OK, MessageBoxIcon.Error)
				//				
				LOCAL lExit := FALSE AS LOGIC
				LOCAL oTabTester AS TabPage
				LOCAL iTestTabs AS INT
				LOCAL oControlToTest := oControl as Control
				
				WHILE !lExit
					TRY 
						oTabTester := (TabPage)oControlToTest:Parent
						iTestTabs := SELF:tabControl_Report:TabPages:IndexOf(oTabTester)
						SELF:tabControl_Report:SelectedIndex := iTestTabs
						lExit := TRUE
					CATCH
						oControlToTest := oControlToTest:Parent
					END
				ENDDO
				//
				oControl:Focus()
				oMainForm:BBIEditReport_ItemClick(null,null)
				RETURN FALSE
			ENDIF
			lIsMandatoryOnCondition := false
	NEXT
RETURN TRUE


METHOD GetLabel(cItemUID AS STRING, oTabPage AS System.Windows.Forms.TabPage) AS STRING
	LOCAL cName, cLabel := "" AS STRING

	FOREACH oControl AS Control IN oTabPage:Controls
		cName := oControl:Name
		IF cName == "Label" + cItemUID .or. cName == "CheckBox" + cItemUID .or. cName == "DatePicker" + cItemUID
			cLabel := oControl:Text
			EXIT
		ENDIF
	NEXT
	IF cLabel == ""
		wb("Label"+cItemUID, "not found")
	ENDIF
RETURN cLabel

METHOD GetLabel(cItemUID AS STRING, oParentControl AS System.Windows.Forms.Control) AS STRING
	LOCAL cName, cLabel := "" AS STRING

	FOREACH oControl AS Control IN oParentControl:Controls
		cName := oControl:Name
		IF cName == "Label" + cItemUID .or. cName == "CheckBox" + cItemUID .or. cName == "DatePicker" + cItemUID
			cLabel := oControl:Text
			EXIT
		ENDIF
	NEXT
	IF cLabel == ""
		wb("Label"+cItemUID, "not found")
	ENDIF
RETURN cLabel

METHOD GetLabel(cItemUID AS STRING) AS STRING
	LOCAL cName, cLabel := "" AS STRING

	FOREACH oTabPage AS System.Windows.Forms.TabPage IN SELF:tabControl_Report:TabPages
		FOREACH oControl AS Control IN oTabPage:Controls
			IF oControl:HasChildren
				FOREACH oSecControl AS Control IN oControl:Controls
					cName := oSecControl:Name
					IF cName == "Label" + cItemUID
						cLabel := oSecControl:Text
					EXIT
				ENDIF
				NEXT
			ELSE
				cName := oControl:Name
				IF cName == "Label" + cItemUID
					cLabel := oControl:Text
					EXIT
				ENDIF
			ENDIF
		NEXT
	NEXT
RETURN cLabel

METHOD deleteNewlyCreatedReport() AS void
		local cStatement :="Delete From FMDataPackages WHERE PACKAGE_UID ="+cMyPackageUID as String
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		cStatement :="Delete From FMData WHERE PACKAGE_UID ="+cMyPackageUID 
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:Close()
		
RETURN

METHOD loadFromExcelForNewReport() AS VOID
	LOCAL oOpenFileDialog:=OpenFileDialog{} AS OpenFileDialog
	oOpenFileDialog:Filter:="Excel files|*.XLSX"
	oOpenFileDialog:Title:="Import Excel file"
	IF oOpenFileDialog:ShowDialog() <> DialogResult.OK
		RETURN
	ENDIF

	LOCAL cFile:=oOpenFileDialog:FileName AS STRING
	LOCAL cExt := System.IO.Path.GetExtension(cFile):ToUpper() AS STRING
	LOCAL oldCI AS System.Globalization.CultureInfo
	oldCI:=System.Threading.Thread.CurrentThread:CurrentCulture
	System.Threading.Thread.CurrentThread:CurrentCulture:=System.Globalization.CultureInfo{"en-US"}

	LOCAL oXL AS Microsoft.Office.Interop.Excel.Application
	LOCAL oWB AS Microsoft.Office.Interop.Excel._Workbook
	LOCAL oRange AS Microsoft.Office.Interop.Excel.Range
	//LOCAL oSheet AS Microsoft.Office.Interop.Excel._WorkSheet

	oXL := Microsoft.Office.Interop.Excel.Application{}
    oWB := oXL:Workbooks:Open(cFile,Type.Missing,true,Type.Missing,Type.Missing,Type.Missing,Type.Missing,Type.Missing,Type.Missing,Type.Missing,Type.Missing,Type.Missing,Type.Missing,Type.Missing,Type.Missing)
    //oSheet := xlWorkbook:Sheets[1]
	
	LOCAL cNameName, cName1, cRangeValue AS STRING
	LOCAL cReportUidLocal, cItemUIDLocal, cItemTypeLocal as String
	local cMultiLineValues := "" as String
	
	FOREACH name  AS Microsoft.Office.Interop.Excel.Name IN oWB:Names
		cNameName := name:Value //Place in Excel
		cName1 := name:Name     //Name 
		
			//oSheet:Cells[oRange]
			//MessageBox.Show(cNameName,cName1)
			//LOCAL cellValue := (STRING)oSheet:Cells[oRange] AS String
		IF cName1:Contains("_ReportUID")
			cReportUidLocal := cName1:Replace("_ReportUID","")	
			IF SELF:cReportUID != cReportUidLocal
				MessageBox.Show("The report does not match")
				RETURN
			ENDIF
		ELSEif cName1:Contains("_VesselUID")
			LOOP
		ELSEIF cName1:Contains("_UID")
			IF name == NULL
				loop			
			ENDIF
			TRY
				oRange := name:RefersToRange
			CATCH exc AS Exception
				MessageBox.Show(exc:Message)	
				loop		
			END TRY

			IF oRange:Value2 == NULL
				LOOP
			ENDIF
			cRangeValue := oRange:Value2:ToString()
			IF cRangeValue == NULL .or. cRangeValue:Trim()==""
				LOOP
			ENDIF
			cName1 := cName1:Replace("_UID","")
			cItemTypeLocal := cName1:Substring(0,1)
			cItemUIDLocal := cName1:Substring(1)
			
			//MessageBox.Show("Value :"+cRangeValue,cItemUIDLocal+" of type :"+cItemTypeLocal)
			IF cItemTypeLocal == "M"
					cMultiLineValues +=  cItemUIDLocal
					cMultiLineValues +=  ((char)168):ToString()  
					cMultiLineValues +=  cRangeValue
					cMultiLineValues +=  ((char)169):ToString()
			ELSEIF cItemTypeLocal == "D"
				 //MessageBox.Show(cRangeValue)
				 local rReal := Double.Parse(cRangeValue) as Double
				 LOCAL dDt := DateTime.FromOADate(rReal) AS DateTime
				 //MessageBox.Show(dDt:ToString())
				 SELF:insertIntoFMData(cMyPackageUID,cItemUIDLocal,dDt:ToString())
			ELSE
				 SELF:insertIntoFMData(cMyPackageUID,cItemUIDLocal,cRangeValue)
			ENDIF
			
		ENDIF
	NEXT
	//save all multilines
	IF cMultiLineValues != ""
		LOCAL cStatement := "" AS STRING
		TRY
			cStatement :=" UPDATE FMDataPackages SET"+;
						 " MEMO = '"+oSoftway:ConvertWildcards(cMultiLineValues, FALSE)+"'"+;
						 " WHERE PACKAGE_UID="+cMyPackageUID 
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		CATCH exc AS Exception
			messagebox.Show(cStatement+" / "+exc:tostring())
		end try
	ENDIF
	System.Threading.Thread.CurrentThread:CurrentCulture:=oldCI
	oWB:Close(Type.Missing, Type.Missing, Type.Missing)
	System.Runtime.InteropServices.Marshal.ReleaseComObject(oWB)
	oWB := NULL
	oXL:Quit()
	GC.WaitForPendingFinalizers()
	GC.Collect()
	GC.WaitForPendingFinalizers()
	GC.Collect()
	oMainForm:Fill_TreeList_Reports()
	SELF:Close()
	
	
	
RETURN
/*LOCAL oGFHExcel AS DBProviderFactory
	LOCAL oConnExcel AS DBConnection
	LOCAL cConnectionString AS STRING
	
	DO CASE
		CASE cExt == ".XLS"
			cConnectionString:="Provider=Microsoft.Jet.OLEDB.4.0;"+;
									 "Data Source="+cFile+";"+;
									 "Extended Properties="+e"\"Excel 8.0;HDR=Yes;IMEX=1\""

		CASE cExt == ".XLSX"
			// Excel 2007:
			cConnectionString:="Provider=Microsoft.ACE.OLEDB.12.0;"+;
								 "Data Source="+cFile+";"+;
								 "Extended Properties="+e"\"Excel 12.0 Xml;HDR=YES;IMEX=1\""
	OTHERWISE
			ErrorBox("Only .XLS and .XLSX file etensions supported", "Import aborted")
			RETURN
	ENDCASE
	oGFHExcel:=DBProviderFactories.GetFactory("System.Data.OleDb")
	// Create a SQL Connection object using OleDB
	oConnExcel:=oGFHExcel:CreateConnection()
	oConnExcel:ConnectionString:=cConnectionString
	oConnExcel:Open()*/

class DoubleBufferedTableLayoutPanel  INHERIT System.Windows.Forms.TableLayoutPanel

	CONSTRUCTOR()
		SUPER()
		DoubleBuffered := true
	RETURN 
END CLASS

END CLASS
