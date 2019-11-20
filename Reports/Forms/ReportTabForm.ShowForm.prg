// ReportTabForm.prg
#Using System.IO
#Using System.Data
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Collections
#Using System.Collections.Generic


PARTIAL CLASS ReportTabForm INHERIT System.Windows.Forms.Form


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
	
	SELF:cTempDocsDir := Application.StartupPath + "\TempDoc_FM_"+oUser:UserID+"\Reports"
	SELF:CreateDirectory(SELF:cTempDocsDir)
	SELF:ClearDirectory(SELF:cTempDocsDir,0)

	lisOfficeForm := isAnOfficeForm(SELF:cMyPackageUID)	

	IF SELF:CategoryExists("0")
		SELF:FillTab("0", "", FALSE)
	ELSE
		SELF:tabControl_Report:TabPages:RemoveAt(0)
	ENDIF
	
	LOCAL lIsBigReport := (SELF:oDTReportItems:Rows:Count>300) AS LOGIC	
	
	FOREACH oRow AS DataRow IN SELF:oDTItemCategories:Rows
		IF oRow["CATEGORY_UID"]:ToString() == "0"
			LOOP
		ENDIF
		SELF:FillTab(oRow["CATEGORY_UID"]:ToString(), oRow["Description"]:ToString(),lIsBigReport)
	NEXT

	IF ! SELF:lEnableControls
		SELF:ReadOnlyControls(FALSE)
	ENDIF
	IF SELF:ReportMainMenu:Visible == TRUE
		SELF:ControlBox := FALSE
	ENDIF
	
RETURN


METHOD FillTab(cCatUID AS STRING, cDescription AS STRING, lIsBigReport := FALSE AS LOGIC) AS VOID
	LOCAL oTabPage AS System.Windows.Forms.TabPage
	LOCAL dTabTag := Dictionary<STRING, STRING>{} AS Dictionary<STRING, STRING>
	dTabTag:Add("TabId", cCatUID)

	IF cCatUID == "0"
		SELF:nConsecutiveNumber := 0
		// Get the 1st Tab
		oTabPage := SELF:tabPage_General
		oTabPage:Click += System.EventHandler{SELF,@Tab_must_focus()}
		oTabPage:Name := "0"
		dTabTag:Add("Status", "Appeared")
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
		oTabPage:Click += System.EventHandler{SELF,@Tab_must_focus()}
        oTabPage:UseVisualStyleBackColor := TRUE
		dTabTag:Add("Status", "NotAppeared")
		IF lIsBigReport
			oTabPage:Enter += System.EventHandler{ SELF, @TabPage_Enter() }
        ENDIF
		SELF:tabControl_Report:Controls:Add(oTabPage)
	ENDIF
	oTabPage:Tag := dTabTag

	LOCAL nX := 250, nY := 15 AS INT
	LOCAL nLabelX := 0 AS INT
	LOCAL TabIndex := 0 AS INT
	//FOREACH oRow AS DataRow IN oDT:Rows

	IF(cCatUID == "0" .OR. !lIsBigReport)
		LOCAL oRows := SELF:oDTReportItems:Select("REPORT_UID="+SELF:cReportUID+" AND CATEGORY_UID="+cCatUID, "ItemNo") AS DataRow[]
		FOREACH oRow AS DataRow IN oRows
			SELF:AddTabControls(oTabPage, oRow, nX, nY, nLabelX, TabIndex)
			SELF:FillUsedInCalculationsArray(oRow)
		NEXT
		IF SELF:cMyPackageUID:Trim() != "" && !lisNewReport
				SELF:PutControlValues(cCatUID)
		ENDIF
	ENDIF


	IF oMyTable <> NULL
			oMyTable:Visible := TRUE
			oMyTable := NULL
			iRowCount := 0 
			iColumnCount := 0 
			lTableMode := FALSE 
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
	STATIC LOCAL cPreviousLabelSize AS INT
	LOCAL lSameSerieItem AS LOGIC
	//wb(cItemType+CRLF+oRow["ItemName"]:ToString(), oTabPage:Name)
	LOCAL oLabel AS System.Windows.Forms.Label
	// Table
	IF lTableMode 
		IF cSLAA == "1"
			SELF:addControlToTable(oRow, nY, TabIndex)
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
	
	IF cItemType <> "B" .AND. cSLAA <> "1" .AND. cItemType <> "L" .AND. cItemType <> "A" //If not checkbox or Slaa or Label or Table
		LOCAL cItemName := oRow["ItemName"]:ToString():Trim() AS STRING
		cItemName := cItemName:Replace("&", "&&")
		//Edw vazei sthn idia grammh an einai to idio onoma ektos apo to teleutaio. mono gia numeric
		IF cItemType == "N" .AND. cPreviousLabel <> ""
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
			CASE cPreviousItemType == "B" 
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
			CASE cPreviousItemType == "D" .OR. cPreviousItemType == "X"
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
        oCheckBox:Location := System.Drawing.Point{250, nY}
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
		CASE cCaption:ToUpper():EndsWith("OFF/ON") .OR. cCaption:ToUpper():EndsWith("ON/OFF")
			cCaption := cCaption:Substring(0, cCaption:Length - 6)+" (OFF)"
			oCheckBox:Text := cCaption

		CASE cCaption:ToUpper():EndsWith("YES/NO") .OR. cCaption:ToUpper():EndsWith("NO/YES")
			cCaption := cCaption:Substring(0, cCaption:Length - 6)+" (NO)"
			oCheckBox:Text := cCaption
		ENDCASE

	CASE cItemType == "X"
        LOCAL oComboBox := System.Windows.Forms.ComboBox{} AS System.Windows.Forms.ComboBox
        // 
        // ComboBox
        // 
		IF cItemTypeValues:ToUpper():StartsWith("NOTSTRICT:")
			cItemTypeValues := cItemTypeValues:Substring(10)
			oComboBox:DropDownStyle := System.Windows.Forms.ComboBoxStyle.DropDown
		ELSE
			oComboBox:DropDownStyle := System.Windows.Forms.ComboBoxStyle.DropDownList
		ENDIF	
        oComboBox:FormattingEnabled := TRUE
        oComboBox:Location := System.Drawing.Point{nX, nY}
        oComboBox:Name := "ComboBox" + cItemUID
        oComboBox:Size := System.Drawing.Size{125, 17}
		oComboBox:TabIndex := TabIndex++
		//oComboBox:Text := oRow["ItemName"]:ToString()
		
       // oComboBox:UseVisualStyleBackColor := TRUE
//        oComboBox:BackColor := Color.White
	

		// Fill ComboBox Items
		//////////////////////////////////////////////////////////
		//	Adde By Kiriakos In order to Support the Week Control
		//////////////////////////////////////////////////////////
		IF cItemTypeValues:ToUpper() == "WEEK"
			cItemTypeValues := cWeekValues	
		ELSEIF cItemTypeValues:ToUpper() == "USERS"
			cItemTypeValues := SELF:GetMyDataForCombo("Username", "Users")
		ELSEIF cItemTypeValues:ToUpper() == "PORTS"
			cItemTypeValues := SELF:GetMyDataForCombo("Port", "VEPorts")
		ELSE
			cItemTypeValues := oMainForm:checkForList(cItemTypeValues)
		ENDIF
		//////////////////////////////////////////////////////////
		//	Adde By Kiriakos In order to Support the Week Control
		//////////////////////////////////////////////////////////
		
		cItemTypeValues := cItemTypeValues:TrimEnd(';')
		LOCAL cItems := cItemTypeValues:Split(';') AS STRING[]
		//For Default Values.
		LOCAL lFoundDefault := FALSE AS LOGIC
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

		nY += 30


	CASE cItemType == "D" .AND. cIsDD == "0"
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

	/////////////////////////////////////////////////////////				
	//			ADDED BY KIRIAKOS
	/////////////////////////////////////////////////////////

	CASE cItemType == "D" .AND. cIsDD == "1"
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
	CASE cItemType == "F"
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
	//Vrisko table, mpaino se table mode mexri na vrw SLAA=0 
	CASE cItemType == "A"
		lTableMode := TRUE
		// 
        // Table
        // 
		nX := 20
		nY += 5
		LOCAL oTable := DoubleBufferedTableLayoutPanel{} AS DoubleBufferedTableLayoutPanel
		oTable:Visible := FALSE
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
        oTable:Size := System.Drawing.Size{SELF:Width-60, 30}
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
        
		//Add Context Menu to print table
		LOCAL oTempContextMenu := ContextMenu{} AS ContextMenu
		LOCAL oTempContextMenuItem := MenuItem{"Print"} AS MenuItem
		oTempContextMenuItem:Tag := cItemUID
		oTempContextMenuItem:Click += System.EventHandler{ SELF, @PrintTableClick() }
		oTempContextMenu:MenuItems:Add(oTempContextMenuItem)
		oLabel:ContextMenu := oTempContextMenu
		//
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


METHOD addControlToTable(oRow AS DataRow,  nY REF INT, nTabIndex REF INT) AS VOID
	//MessageBox.Show("Add Control To table.")
	LOCAL cItemUID := oRow["ITEM_UID"]:ToString() AS STRING
	LOCAL cItemType := oRow["ItemType"]:ToString() AS STRING
	LOCAL cItemTypeValues := oRow["ItemTypeValues"]:ToString() AS STRING
	LOCAL cCalculatedField := oRow["CalculatedField"]:ToString() AS STRING
	LOCAL cIsDD := oSoftway:LogicToString(oRow["IsDD"]) AS STRING
	LOCAL iExpandOnColumns := Convert.ToInt32(oRow["ExpandOnColumns"]:ToString()) AS INT
	LOCAL Mandatory := oSoftway:LogicToString(oRow["Mandatory"]) AS STRING
	
	DO CASE
		CASE cItemType == "X"
        LOCAL oComboBox := System.Windows.Forms.ComboBox{} AS System.Windows.Forms.ComboBox
        // 
        // ComboBox
        // 
		IF cItemTypeValues:ToUpper():StartsWith("NOTSTRICT:")
			cItemTypeValues := cItemTypeValues:Substring(10)
			oComboBox:DropDownStyle := System.Windows.Forms.ComboBoxStyle.DropDown
		ELSE
			oComboBox:DropDownStyle := System.Windows.Forms.ComboBoxStyle.DropDownList
		ENDIF	

        oComboBox:FormattingEnabled := TRUE
        oComboBox:Location := System.Drawing.Point{1, 1}
        oComboBox:Name := "ComboBox" + cItemUID
        oComboBox:Size := System.Drawing.Size{125, 17}
		oComboBox:Dock := DockStyle.Fill
		oComboBox:TabIndex := TabIndex++
		//oComboBox:Text := oRow["ItemName"]:ToString()
		//////////////////////////////////////////////////////////
		//	Added By Kiriakos In order to Support the Week Control
		//////////////////////////////////////////////////////////
		IF cItemTypeValues:ToUpper() == "WEEK"
			cItemTypeValues := cWeekValues
		ELSEIF cItemTypeValues:ToUpper() == "USERS"
			cItemTypeValues := SELF:GetMyDataForCombo("Username", "Users")
		ELSEIF cItemTypeValues:ToUpper() == "PORTS"
			cItemTypeValues := SELF:GetMyDataForCombo("Port", "VEPorts")
		ELSE
			cItemTypeValues := oMainForm:checkForList(cItemTypeValues)
		ENDIF
		//////////////////////////////////////////////////////////
		//	Added By Kiriakos In order to Support the Week Control
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

		IF SELF:addControlToTableLayout(oComboBox)
			nY += 32
		ENDIF
	CASE cItemType == "D" .AND. cIsDD == "1"
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
		IF SELF:addControlToTableLayout(oButtonFile)
			nY += 32
		ENDIF
		
	CASE cItemType == "D" .AND. cIsDD == "0"
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
		IF SELF:addControlToTableLayout(oDatePicker)
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
        IF SELF:addControlToTableLayout(oNumericTextBox)
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
        IF SELF:addControlToTableLayout(oTextBox)
			nY += 32
		ENDIF
	CASE cItemType == "F"
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
        IF SELF:addControlToTableLayout(oButtonFile)
			nY += 32
		ENDIF
	
	CASE cItemType == "L"
		LOCAL cItemName := oRow["ItemName"]:ToString():Trim() AS STRING
		LOCAL oLabel := System.Windows.Forms.Label{} AS System.Windows.Forms.Label
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
		
        IF SELF:addControlToTableLayout(oLabel)
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
			iIncrement := 30
		ELSE
			iIncrement := 0
		ENDIF
		
        IF SELF:addControlToTableLayout(oTextBoxMultiline)
			nY += 62
		ELSE
			//MessageBox.Show(iIncrement:ToString(),(nY+iIncrement):tostring())
			nY += iIncrement
		ENDIF
		/*IF iExpandOnColumns > 1
			SELF:oMyTable:SetColumnSpan(oTextBoxMultiline,iExpandOnColumns)
			
			iColumnCount := iColumnCount + iExpandOnColumns - 1
			IF iColumnCount > oMyTable:ColumnCount
				iColumnCount := oMyTable:ColumnCount
			ENDIF
		ENDIF*/
		SELF:checkTheColumnSpan(oTextBoxMultiline,iExpandOnColumns)
	ENDCASE
	

RETURN

METHOD checkTheColumnSpan(oControlTemp AS Control, iExpandOnColumns AS INT) AS VOID
	IF iExpandOnColumns > 1
			oControlTemp:Dock := DockStyle.Fill
			oControlTemp:Margin := Padding{0}
			SELF:oMyTable:SetColumnSpan(oControlTemp,iExpandOnColumns)
			
			iColumnCount := iColumnCount + iExpandOnColumns - 1
			IF iColumnCount > oMyTable:ColumnCount
				iColumnCount := oMyTable:ColumnCount
			ENDIF
	ENDIF
RETURN

METHOD addControlToTableLayout(oControl AS Control) AS LOGIC
		///oMyTable:SuspendLayout()
		IF iRowCount == 0 .AND. iColumnCount == 0 // Einai to prwto meta to header
			oMyTable:RowCount := 2
			LOCAL iPercent AS INT
			iPercent := Convert.ToInt32(100/oMyTable:RowCount)
			//MessageBox.Show(iPercent:ToString())
			oMyTable:RowStyles:Add(System.Windows.Forms.RowStyle{System.Windows.Forms.SizeType.Percent, ((Single) iPercent)})
			iRowCount++
			oMyTable:Controls:Add(oControl, iColumnCount, iRowCount)
			iColumnCount ++
			///oMyTable:ResumeLayout()
			RETURN TRUE
		ELSEIF  iColumnCount < oMyTable:ColumnCount
			//LOCAL iPercent AS INT
			//iPercent := Convert.ToInt32(100/oMyTable:RowCount)
			//MessageBox.Show(iPercent:ToString())
			//oMyTable:RowStyles:Add(System.Windows.Forms.RowStyle{System.Windows.Forms.SizeType.Percent, ((Single) iPercent)})
			oMyTable:Controls:Add(oControl, iColumnCount, iRowCount)
			iColumnCount ++
			///oMyTable:ResumeLayout()
			RETURN FALSE
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
			RETURN TRUE
		ENDIF
		//oMyTable:Size := System.Drawing.Size{oMyTable:Width, oMyTable:Height+30}
RETURN TRUE

METHOD isAnOfficeForm(cReportUID AS STRING) AS LOGIC

	LOCAL lReturn := FALSE AS LOGIC
	LOCAL cReport_UidLocal AS STRING
	
	IF(SELF:cReportUID==NULL || SELF:cReportUID=="")
		cReport_UidLocal := oMainForm:getReportIUDfromPackage(SELF:cMyPackageUID) 
	ELSE	
		cReport_UidLocal := SELF:cReportUID
	ENDIF	

	LOCAL cStatement:= " SELECT ReportType FROM FMReportTypes "+;
					   " WHERE Report_Uid="+cReport_UidLocal AS STRING
	
	LOCAL cData := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "ReportType") AS STRING
	IF cData == "V"
		lReturn := FALSE
	ELSEIF cData == "O"
		lReturn := TRUE
	ENDIF

RETURN lReturn 

METHOD PutControlValues(cCategoryUIDLocal AS STRING) AS VOID

	memowrit(cTempDocDir+"\PutControlValuesStarted.txt", DateTime.Now:ToString())

	LOCAL cStatement AS STRING
	//LOCAL cVesselUID := oMainForm:CheckedLBCVessels:SelectedValue:ToString() AS STRING
	LOCAL cDate AS STRING
	LOCAL cUID AS STRING

	LOCAL cTabSQL := "" AS STRING
	IF cCategoryUIDLocal!=NULL && cCategoryUIDLocal!=""
		cTabSQL := " AND FMReportItems.CATEGORY_UID="+cCategoryUIDLocal+" "
	ENDIF

	

	IF oMainForm:TreeListVesselsReports:visible == TRUE
		IF SELF:cMyPackageUID == ""
			RETURN
		ENDIF
	    cUID := SELF:cMyPackageUID //23.12
		cStatement:="SELECT FMDataPackages.PACKAGE_UID, FMDataPackages.Status, FMData.ITEM_UID, FMData.Data FROM FMData"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
				" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+cTabSQL+;
				" WHERE FMDataPackages.PACKAGE_UID ="+cUID+" AND FMDataPackages.REPORT_UID="+SELF:cReportUID
		
	ELSE
		cDate:=	oMainForm:LBCVesselReports:SelectedItem:ToString()
		cDate := cDate:SubString(0, 16)		// 10/12/2014 HH:mm
		LOCAL dStart := Datetime.Parse(cDate) AS DateTime
		LOCAL dEnd := dStart:AddMinutes(1) AS DateTime
		cStatement:="SELECT FMDataPackages.PACKAGE_UID, FMDataPackages.Status, FMData.ITEM_UID, FMData.Data FROM FMData"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
				" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+cTabSQL+;
				" WHERE FMDataPackages.VESSEL_UNIQUEID="+oMainForm:GetVesselUID+;
				" AND FMDataPackages.REPORT_UID="+SELF:cReportUID+;
				" AND FMDataPackages.DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm")+"'"
	ENDIF
	SELF:oDTFMData := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	
	LOCAL TextBoxMultiline_ItemUID := "", cMemo := ""  AS STRING
	LOCAL cPackageUID := cUID AS STRING
	LOCAL oMultilineRows AS DataRow[]
	///////////////////////////////////////////	Multilines//////// //////////////////////////////////////////////////////////////
	///////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// 
	cStatement:="SELECT ITEM_UID FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" WHERE ItemType='M' AND REPORT_UID="+SELF:cReportUID+cTabSQL
	LOCAL oDMLE := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	TRY
	IF oDMLE:Rows:Count > 0
		cStatement:="SELECT Memo FROM FMDataPackages"+oMainForm:cNoLockTerm+;
					" WHERE PACKAGE_UID="+cPackageUID
		cMemo := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Memo")
		
		IF cMemo <> "" .AND. cMemo:Contains(CHR(168))
			LOCAL charSpl1 := (CHAR)169 AS CHAR
			LOCAL charSpl2 := (CHAR)168 AS CHAR
			//
			LOCAL cItems := cMemo:Split(charSpl1) AS STRING[]
			FOREACH cItem AS STRING IN cItems
				TRY
				IF cItem <> NULL .AND. cItem <> ""
					LOCAL cItemsTemp := cItem:Split(charSpl2) AS STRING[]
					LOCAL cMultilineUID := cItemsTemp[1] AS STRING
					oMultilineRows := oDMLE:Select("ITEM_UID="+cItemsTemp[1] )
					IF oMultilineRows:Length>0
						LOCAL oControlTextBoxMultiline := SELF:GetControlofTabPage("TextBoxMultiline", cItemsTemp[1],cCategoryUIDLocal) AS Control
						IF oControlTextBoxMultiline <> NULL
							oControlTextBoxMultiline:Text := cItemsTemp[2]
						ENDIF
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
	///////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	TRY
		LOCAL cFileName, cButtonId/*, cData*/ AS STRING
		LOCAL iCountRows, i, iPreviousNumberOfDocuments:=0 ,iCountDocuments:=0 AS INT
		LOCAL oButton AS Button

		IF (oMainForm:oConnBlob == NULL .OR. oMainForm:oConnBlob:State == ConnectionState.Closed)
			oMainForm:oConnBlob:Open()	
		ENDIF

        
	    LOCAL oIniFile:=IniFile{cStartupPath+"\SOFTWAY.INI"} AS IniFile
	    LOCAL cSQLInitialCatalog := oIniFile:GetString("SQLConnect", "SQLInitialCatalog") AS STRING
	    LOCAL cSQLInitialCatalogBlob := cSQLInitialCatalog + "Blob" AS STRING

		IF cCategoryUIDLocal != NULL && cCategoryUIDLocal:Length>0
			cStatement:=" SELECT FMBlobData.ITEM_UID,FileName FROM FMBlobData "+oMainForm:cNoLockTerm+;
						" Inner Join "+cSQLInitialCatalog+".dbo.FMReportItems On "+cSQLInitialCatalog+;
                        ".dbo.FMReportItems.ITEM_UID=FMBlobData.ITEM_UID "+;
						cTabSQL+;
						" WHERE PACKAGE_UID="+cPackageUID
		ELSE
			cStatement:=" SELECT ITEM_UID,FileName FROM FMBlobData "+oMainForm:cNoLockTerm+;
						" WHERE PACKAGE_UID="+cPackageUID
		ENDIF

		oDMLE := oSoftway:ResultTable(oMainForm:oGFHBlob, oMainForm:oConnBlob, cStatement) 
	
		//wb(cStatement, oDMLE:Rows:Count:ToString())
		LOCAL oFileTempDT AS DataTable
		IF oDMLE != NULL .AND. oDMLE:Rows:Count > 0
			iCountRows := oDMLE:Rows:Count
			FOR i := 0 UPTO iCountRows-1 STEP 1
					//cData := SELF:GetString(oData)
					//wb(cData, "Here")
					cFileName := oDMLE:Rows[i]:Item["FileName"]:ToString()
					//wb(cFileName, "Here")
					//cFileName := cFileName:Substring(0,cFileName:LastIndexOf("."))
					cButtonId := oDMLE:Rows[i]:Item["ITEM_UID"]:ToString() 
					TRY
						oButton := (Button)SELF:GetControl("FileUploader",cButtonId)
						IF oButton == NULL
							LOOP
						ENDIF
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
							LOOP
							//wb("Unable to locate file :"+cTempFileInXML:Substring(0,cTempFileInXML:LastIndexOf(".")),"Info")
					END	
			NEXT
		ENDIF
	CATCH exc AS Exception
		MessageBox.Show(exc:ToString())
	END
	oMainForm:oConnBlob:Close()
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////	All other controls //////////////////////////////////////////////////////////////
	///////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	LOCAL cName, cItemUID, cData, cDeg, cMin, cSec, cNSEW AS STRING
	//LOCAL nPos AS INT
	LOCAL oRows AS DataRow[]
	LOCAL dDate AS DateTime
	LOCAL nGmtDiff AS Decimal
	
	FOREACH oTabPage AS System.Windows.Forms.TabPage IN SELF:tabControl_Report:TabPages
		IF cCategoryUIDLocal!=NULL && cCategoryUIDLocal!=""
			LOCAL dTabTag AS Dictionary<STRING, STRING>	
			dTabTag := (Dictionary<STRING, STRING>)oTabPage:Tag	
			LOCAL cTagLocal := dTabTag["TabId"]:ToString() AS STRING
			IF cTagLocal!=cCategoryUIDLocal
				LOOP
			ENDIF
		ENDIF

		FOREACH oControl AS Control IN oTabPage:Controls
			
			IF oControl:HasChildren
			FOREACH oSecControl AS Control IN oControl:Controls
			////////////////////////////////////////////////////////////////////////////////////////////
					TRY
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
					CASE cName:StartsWith("DatePicker")
						IF cData == "No Date Applicable"
							((System.Windows.Forms.DateTimePicker)oSecControl):Visible := FALSE
						ELSE
							dDate := DateTime.Parse(cData)
							((System.Windows.Forms.DateTimePicker)oSecControl):Value := dDate
						ENDIF

					CASE cName:StartsWith("TextBox")
						oSecControl:Text := cData
				
					CASE cName:StartsWith("DD") .AND. cData != ""
						LOCAL oDateTimePicker := replaceButtonWithDate(oSecControl) AS DateTimePicker
						IF cData == "No Date Applicable"
							oDateTimePicker:Visible := FALSE
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
						IF ! SELF:GeoValueToDegMinSecNSEW(cData, cDeg, cMin, cSec, cNSEW)
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
						IF cNSEW == "N" .OR. cNSEW == "E"
							((System.Windows.Forms.ComboBox)oControl):SelectedIndex := 0
						ELSE
							((System.Windows.Forms.ComboBox)oControl):SelectedIndex := 1
						ENDIF
					ENDCASE
					CATCH
						//wb(cName+CRLF+cItemUID+CRLF+cData, "")
						//CHANGED BY KIRIAKOS ON 04/11/16
						wb("Invalid Data specified for"+CRLF+"Control: ["+cName:Replace(cItemUID, "")+"]"+CRLF+"ControlID: ["+cItemUID+"]"+CRLF+"Data: ["+cData+"]", "")
						//CHANGED BY KIRIAKOS ON 04/11/16
					END 
			NEXT
			ELSE
		//////////////////////////////////////////////////////////////////////////////////////////
			
			////////////////////////////////////////////////////////////////////////////////////////////
			TRY
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

			DO CASE			

			CASE cName:StartsWith("DatePicker")
				IF cData == "No Date Applicable"
					((System.Windows.Forms.DateTimePicker)oControl):Visible := FALSE
				ELSE
					dDate := DateTime.Parse(cData)
					((System.Windows.Forms.DateTimePicker)oControl):Value := dDate
				ENDIF
			CASE cName:StartsWith("TextBox")
				oControl:Text := cData
				
			CASE cName:StartsWith("DD") .AND. cData != ""
				LOCAL oDateTimePicker := replaceButtonWithDate(oControl) AS DateTimePicker
				IF cData == "No Date Applicable"
					oDateTimePicker:Visible := FALSE
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
				IF ! SELF:GeoValueToDegMinSecNSEW(cData, cDeg, cMin, cSec, cNSEW)
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
				IF cNSEW == "N" .OR. cNSEW == "E"
					((System.Windows.Forms.ComboBox)oControl):SelectedIndex := 0
				ELSE
					((System.Windows.Forms.ComboBox)oControl):SelectedIndex := 1
				ENDIF
			ENDCASE
			CATCH
				//CHANGED BY KIRIAKOS ON 04/11/16
				wb("Invalid Data specified for"+CRLF+"Control: ["+cName:Replace(cItemUID, "")+"]"+CRLF+"ControlID: ["+cItemUID+"]"+CRLF+"Data: ["+cData+"]", "")
				//CHANGED BY KIRIAKOS ON 04/11/16
			END
			ENDIF 
		NEXT
		//////////////////////////////////////////////////////////////////////////////////////////
	NEXT
	
	memowrit(cTempDocDir+"\PutControlValuesEnded.txt", DateTime.Now:ToString())
RETURN

PUBLIC METHOD locateControlByNameAndUID(cPrefix AS STRING, cItemUIDLocal AS STRING) AS VOID

	LOCAL cStatement:="SELECT Category_UID FROM FMReportItems "+;
				" WHERE ITEM_UID="+cItemUIDLocal AS STRING
	cStatement := oSoftway:SelectTop(cStatement)
	LOCAL cCategory_UidLocal :=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Category_UID") AS STRING
	
	FOREACH oTabPage AS System.Windows.Forms.TabPage IN SELF:tabControl_Report:TabPages
			LOCAL dTabTag AS Dictionary<STRING, STRING>	
			dTabTag := (Dictionary<STRING, STRING>)oTabPage:Tag	
			LOCAL cTagLocal := dTabTag["TabId"]:ToString() AS STRING
			IF cTagLocal!=cCategory_UidLocal
				LOOP
			ELSE
				SELF:tabControl_Report:SelectedTab := oTabPage
				Application.DoEvents()
				LOCAL oControlTemp :=  SELF:GetControlofTabPage(cPrefix,cItemUIDLocal,cCategory_UidLocal) AS Control
				oControlTemp:Focus()
				EXIT
			ENDIF
	NEXT

	PRIVATE METHOD PrintTableClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	TRY
		LOCAL oTempMenuItem := (MenuItem)sender AS MenuItem
		LOCAL cTag := oTempMenuItem:Tag:ToString() AS STRING
		LOCAL lEmpty := TRUE AS LOGIC
		IF cMyPackageUID != ""
			lEmpty := FALSE
		ENDIF
		SELF:PrintTableToExcelFile(SELF:cReportUID,SELF:cReportName,lEmpty,SELF:cVesselUID,;
								   SELF:cMyVesselName,cTag,SELF:cMyPackageUID)
	CATCH exc AS Exception
		MessageBox.Show(exc:ToString(),"Error on Creating the Context Menu For Table")	
	END					
	RETURN


END CLASS