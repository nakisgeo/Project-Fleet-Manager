// ReportTabForm_Methods.prg
#Using System.IO
#Using System.Data
#using System.Linq
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Collections
#Using System.Collections.Generic


PARTIAL CLASS ReportTabForm INHERIT System.Windows.Forms.Form

	EXPORT cMyPackageUID := "" AS STRING
	EXPORT cReportUID AS STRING
	EXPORT cReportName AS STRING
	EXPORT cVesselUID :="" AS STRING
	EXPORT cMyVesselName := "" AS STRING
	EXPORT oDTItemCategories AS DataTable
	EXPORT oDTReportItems AS DataTable
	//PRIVATE aFocusControls AS ArrayList
	EXPORT lEnableControls AS LOGIC
	EXPORT lisInEditMode AS LOGIC
	EXPORT lisOfficeForm AS LOGIC
	EXPORT lisNewReport AS LOGIC
	
	PRIVATE decimalSeparator AS STRING
	PRIVATE groupSeparator AS STRING
	PRIVATE aCalculatedItemUID AS ArrayList
	PRIVATE aUsedInCalculations AS ArrayList
	PRIVATE aFormula AS ArrayList

	PRIVATE cNumbers := "0123456789" AS STRING
	PUBLIC lGmtDiffControlsCreated AS LOGIC
	PRIVATE nConsecutiveNumber AS INT

	EXPORT oDTFMData AS DataTable
	
	PRIVATE cPreviousData := "" AS STRING
	PRIVATE cTempDocsDir AS STRING
	PRIVATE oDTPreviousData AS DataTable
	// Table
	PRIVATE lTableMode := FALSE AS LOGIC
	PRIVATE iRowCount := 0, iColumnCount := 0 AS INT
	PRIVATE oMyTable AS DoubleBufferedTableLayoutPanel
	
	PRIVATE DateTime_ItemUID := "" AS STRING
	PRIVATE Latitude_ItemUID := "" AS STRING
	PRIVATE Longitude_ItemUID := "" AS STRING

	
METHOD ReportTabForm_OnLoad() AS VOID
	oSoftway:ReadFormSettings_DevExpress(SELF, NULL, oMainForm:alForms, oMainForm:alData)
	IF SELF:Size:Height < 50 .OR. SELF:Size:Width < 100
		SELF:Size := System.Drawing.Size{950, 750}
	END
RETURN




METHOD createNewReportSave(cSubmit := "0" AS STRING) AS VOID
TRY
	IF DateTime_ItemUID == ""
		MessageBox.Show("Can not create a report with no Date Time element.")
	ENDIF
	
	LOCAL oControlDatePickerGMT := SELF:GetControl("DatePickerGMT", SELF:DateTime_ItemUID) AS Control
	LOCAL oNumericTextBoxGMT := (TextBox)SELF:GetControl("NumericTextBoxGMT", SELF:DateTime_ItemUID) AS TextBox
	
	IF oControlDatePickerGMT == NULL .OR. oNumericTextBoxGMT == NULL
			MessageBox.Show("Can not create a report with no Date Time element.")
			RETURN
	ENDIF
	
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

METHOD ReadOnlyControls(isEditable AS LOGIC) AS VOID
	lisInEditMode := isEditable
	FOREACH oTabPage AS System.Windows.Forms.TabPage IN SELF:tabControl_Report:TabPages
		SELF:ReadOnlyTabPage(isEditable,oTabPage)
	NEXT
RETURN

METHOD ReadOnlyTabPage(isEditable AS LOGIC,oTabPageLocal AS TabPage) AS VOID
	LOCAL cName AS STRING
	FOREACH oControl AS Control IN oTabPageLocal:Controls
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

			CASE cName:StartsWith("TextBox")
				((System.Windows.Forms.TextBox)oControl):ReadOnly := !isEditable

			CASE cName:StartsWith("NumericTextBox")
				((System.Windows.Forms.TextBox)oControl):ReadOnly := !isEditable

			CASE cName:StartsWith("CheckBox")
				((System.Windows.Forms.CheckBox)oControl):Enabled := isEditable

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
			ENDIF
		NEXT
RETURN

METHOD CategoryExists(cCatUID AS STRING) AS LOGIC
	LOCAL oRows := SELF:oDTReportItems:Select("CATEGORY_UID="+cCatUID) AS DataRow[]
RETURN (oRows:Length > 0)

METHOD amItheOnlyMultilineInThisLine(iAmInColumn AS INT) AS LOGIC
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
				IF oControl IS TextBox
					LOCAL lIsMultiline := (LOGIC)(((TextBox)oControl):Multiline) AS LOGIC
					IF  lIsMultiline
						RETURN FALSE	
					ENDIF
				ELSE
				//MessageBox.Show("Found another multiline at:("+iRowCount:ToString()+","+iCount:ToString()+")",iAmInColumn:ToString())
				ENDIF
			CATCH exException AS Exception
				
			END
		NEXT		
RETURN TRUE



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

	CASE  e:KeyData == Keys.OemMinus .OR. e:KeyData == Keys.Subtract
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


PRIVATE METHOD DueDate_Button_Clicked( sender AS System.Object, e AS System.EventArgs ) AS System.Void
TRY
		LOCAL oButton := (Button)sender AS Button
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
		oButton:Visible := FALSE
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
		oButton:Visible := FALSE
		oButton:Parent:Controls:Add(oDatePicker)
		RETURN oDatePicker
CATCH exc AS Exception
		MessageBox.Show(exc:ToString(),"Error on Creating the Date Picker")	
END					
RETURN NULL

PRIVATE METHOD NumericTextBoxGMT_Validating( sender AS System.Object, e AS System.ComponentModel.CancelEventArgs ) AS System.Void
	LOCAL oTextBox := (System.Windows.Forms.TextBox)sender AS System.Windows.Forms.TextBox
	IF ! oTextBox:Enabled
		RETURN
	ENDIF

	LOCAL cText := oTextBox:Text:Trim() AS STRING
	LOCAL cMandatory := (STRING)oTextBox:Tag AS STRING
	IF cMandatory == "0" .AND. cText == ""
		RETURN
	ENDIF

	LOCAL nValue AS Decimal
	TRY
		nValue := Convert.ToDecimal(cText)
		//wb(nValue:ToString()+CRLF+(nValue < (Decimal)-12):ToString()+CRLF+(nValue > (Decimal)12):ToString(), "")

		// Check Hours
		LOCAL nHours := (INT)nValue AS INT
		LOCAL nDec := Math.Abs(nValue - (Decimal)nHours) AS Decimal
		IF nDec <> (Decimal)0 .AND. nDec <> (Decimal)0.5
			BREAK
		ENDIF

		IF nValue < (Decimal)-12 .OR. nValue > (Decimal)12
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

	IF oNumericTextBoxGMT:Text <> ""
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


PUBLIC METHOD TabPage_Enter( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	LOCAL oTabPageLocal := (TabPage)sender AS System.Windows.Forms.TabPage
	LOCAL dTabTag AS Dictionary<STRING, STRING>	
	dTabTag := (Dictionary<STRING, STRING>)oTabPageLocal:Tag	

	LOCAL cTagLocal := dTabTag["Status"]:ToString() AS STRING
	LOCAL cCatUIDLocal := dTabTag["TabId"]:ToString() AS STRING
		

	IF cTagLocal == "NotAppeared"
		dTabTag["Status"] :=  "Appeared"
		LOCAL nX := 250, nY := 15 AS INT
		LOCAL nLabelX := 0 AS INT
		LOCAL TabIndex := SELF:tabControl_Report:SelectedIndex-1 AS INT
		IF TabIndex == -1
			TabIndex := 0
		ENDIF
		
		memowrit(cTempDocDir+"\AddControlsStarted.txt", DateTime.Now:ToString())
		oTabPageLocal:SuspendLayout()
		LOCAL oRows := SELF:oDTReportItems:Select("REPORT_UID="+SELF:cReportUID+;
				" AND CATEGORY_UID="+cCatUIDLocal, "ItemNo") AS DataRow[]
		
		FOREACH oRow AS DataRow IN oRows
			SELF:AddTabControls(oTabPageLocal, oRow, nX, nY, nLabelX, TabIndex)
			SELF:FillUsedInCalculationsArray(oRow)
			Application.DoEvents()
		NEXT
		oTabPageLocal:ResumeLayout(TRUE)
		memowrit(cTempDocDir+"\AddControlsEnded.txt", DateTime.Now:ToString())
		IF SELF:cMyPackageUID:Trim() != "" && !lisNewReport
			SELF:PutControlValues(cCatUIDLocal)
		ENDIF
		
		oTabPageLocal:Tag := dTabTag
		memowrit(cTempDocDir+"\MakingReadOnlyStarted.txt", DateTime.Now:ToString())
		IF !SELF:lisInEditMode
			SELF:ReadOnlyTabPage(FALSE,oTabPageLocal)
		ENDIF
		memowrit(cTempDocDir+"\MakingReadOnlyEnded.txt", DateTime.Now:ToString())
	ENDIF

	IF oMyTable <> NULL
			oMyTable:Visible := TRUE
			oMyTable := NULL
			iRowCount := 0 
			iColumnCount := 0 
			lTableMode := FALSE 
	ENDIF
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



PUBLIC METHOD GetControl(cPrefix AS STRING, cItemUID AS STRING) AS Control
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

PUBLIC METHOD GetControlofTabPage(cPrefix AS STRING, cItemUID AS STRING, cTabPageUID AS STRING) AS Control
	LOCAL cName, cLocate := cPrefix+cItemUID AS STRING

	FOREACH oTabPage AS System.Windows.Forms.TabPage IN SELF:tabControl_Report:TabPages
			IF cTabPageUID!=NULL && cTabPageUID!=""
				LOCAL dTabTag AS Dictionary<STRING, STRING>	
				dTabTag := (Dictionary<STRING, STRING>)oTabPage:Tag	
				LOCAL cTagLocal := dTabTag["TabId"]:ToString() AS STRING
				IF cTagLocal!=cTabPageUID
					LOOP
				ENDIF
			ENDIF

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

METHOD RefreshoDTFMData() AS VOID
		LOCAL cDate, cStatement  AS STRING
		LOCAL cUID AS STRING
		IF oMainForm:TreeListVesselsReports:visible == TRUE
		    cUID := cMyPackageUID
			cStatement:="SELECT FMDataPackages.PACKAGE_UID, FMData.ITEM_UID, FMData.Data FROM FMData"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
				" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
				" WHERE FMDataPackages.REPORT_UID="+SELF:cReportUID+;
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
	LOCAL iLength := (INT)(str:Length * sizeof(CHAR))  AS INT 	
    LOCAL  bytes := BYTE[]{iLength} AS BYTE[]
    System.Buffer.BlockCopy(str:ToCharArray(), 0, bytes, 0, bytes:Length)
RETURN bytes


METHOD GetString(bytes AS BYTE[]) AS STRING
	LOCAL iLength  := (INT)(bytes:Length / sizeof(CHAR))  AS INT 
    LOCAL chars := CHAR[]{iLength} AS CHAR[]
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


EXPORT METHOD saveNormalValues(cNewPackageUID := "" AS STRING ) AS LOGIC
    SELF:RefreshoDTFMData()
	LOCAL lHasChanged := FALSE AS LOGIC
	TRY
		LOCAL cData:="",cName,cItemUID,cPrevData AS STRING
		LOCAL oRows AS DataRow[]
		
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
								CASE cName:StartsWith("DatePickerNullGMT")
									LOOP
								CASE cName:StartsWith("DatePickerGMT")
									LOOP
								CASE cName:StartsWith("TextBoxMultiline")
									LOOP
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
									LOOP
								ENDCASE

								LOCAL cPackageUIDLocal AS STRING
								IF cNewPackageUID <> ""
									cPackageUIDLocal := cNewPackageUID
								ELSEIF SELF:oDTFMData:rows:Count == 0
									cPackageUIDLocal  := SELF:cMyPackageUID //23.12
								ELSE
									cPackageUIDLocal := SELF:oDTFMData:Rows[0]:Item["PACKAGE_UID"]:ToString()
								ENDIF

								//IF cData <> "" // If there are data available
									cItemUID := SELF:GetItemUID(cName)
									//Check if the data is same as when the report was loaded
									IF cNewPackageUID <> "" // New Report
										IF cData<>"" //Exo data
											SELF:insertIntoFMData(cPackageUIDLocal,cItemUID,cData)
											IF cItemUID ==  DateTime_ItemUID
												SELF:changeDateTime(cData,cItemUID,cPackageUIDLocal)
											ENDIF
										ENDIF
										LOOP
									ELSE // Eimai existing report
										oRows := SELF:oDTFMData:Select("ITEM_UID="+cItemUID)
										IF oRows == NULL .OR. oRows:Length==0 // The data did not exist on vessel's/previous dataset insert it to FMdata.
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
										SELF:updateFMDataForPackageUIDandItemUID(cPackageUIDLocal,cItemUID,cData,cPrevData)
									ENDIF
									// In order to check if Coordinates or DateTime is checked
									IF cItemUID ==  DateTime_ItemUID
										SELF:changeDateTime(cData,cItemUID,cPackageUIDLocal)
									ELSEIF 	cItemUID ==  Latitude_ItemUID
										SELF:changeLatitude(cData,cItemUID,cPackageUIDLocal)
									ELSEIF 	cItemUID ==  Longitude_ItemUID
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
							LOOP
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
								IF oRows == NULL .OR. oRows:Length==0 // The data did not exist on vessel's/previous dataset insert it to FMdata.
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
								SELF:updateFMDataForPackageUIDandItemUID(cPackageUIDLocal,cItemUID,cData,cPrevData)
							ENDIF
							// In order to check if Coordinates or DateTime is checked
							IF cItemUID ==  DateTime_ItemUID
								SELF:changeDateTime(cData,cItemUID,cPackageUIDLocal)
							ELSEIF 	cItemUID ==  Latitude_ItemUID
								SELF:changeLatitude(cData,cItemUID,cPackageUIDLocal)
							ELSEIF 	cItemUID ==  Longitude_ItemUID
								SELF:changeLongitude(cData,cItemUID,cPackageUIDLocal)
							ENDIF
						
						//ENDIF
						/////////////////////////////////////////////////////////////////////
					ENDIF
				CATCH exc AS Exception
					messagebox.Show(exc:tostring())
					LOOP
				END
			NEXT
		NEXT
		SELF:RefreshoDTFMData()
	CATCH exc AS Exception
		SELF:RefreshoDTFMData()
		messagebox.Show(exc:tostring())
	END
RETURN	lHasChanged

EXPORT METHOD changeDateTime(cLatString AS STRING, cItemUID AS STRING, cPackageUID AS STRING) AS VOID
	LOCAL cDateGMT := "" AS STRING
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

EXPORT METHOD changeLatitude(cLatString AS STRING, cItemUID AS STRING, cPackageUID AS STRING) AS VOID
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

EXPORT METHOD changeLongitude(cLatString AS STRING, cItemUID AS STRING, cPackageUID AS STRING) AS VOID
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

EXPORT METHOD updateFMDataForPackageUIDandItemUID(cPackageUID AS STRING,cItemUID AS STRING,cData AS STRING,cPreviousData AS STRING) AS VOID
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

EXPORT METHOD saveMultilineFields(cNewPackageUID := "" AS STRING) AS VOID	
	TRY
		LOCAL cAllMemos,cName,cNewData:="",cPrevData AS STRING
		LOCAL cPackageUID AS STRING
		IF cNewPackageUID == "" && (SELF:cMyPackageUID==NULL || SELF:cMyPackageUID:Length < 1)
			cPackageUID := oMainForm:TreeListVesselsReports:FocusedNode:Tag:ToString()
		ELSEIF SELF:cMyPackageUID != NULL && SELF:cMyPackageUID:Length > 0
			cPackageUID := cMyPackageUID
		ELSE
			cPackageUID := cNewPackageUID	
		ENDIF
		LOCAL cStatement:="SELECT Memo FROM FMDataPackages"+oMainForm:cNoLockTerm+;
					" WHERE PACKAGE_UID="+cPackageUID AS STRING
		cAllMemos := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Memo")
		//MessageBox.Show("Old value : '"+cAllMemos+"'")
		IF cAllMemos <> "" .AND. cAllMemos:Contains((CHAR)168)	// New FM
			LOCAL cNewAllMemos := SELF:GetAllMultilines(cAllMemos) AS STRING
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
					ENDIF
				CATCH
					BREAK
				END
				NEXT
			NEXT
		ELSEIF cAllMemos == "" // Update Memo Field Here only do not insert 
			SELF:updateMemoOnlyTo(cPackageUID,SELF:GetAllMultilines(""))
		ENDIF
			
	CATCH exc AS Exception
		messagebox.Show(exc:tostring())
	END	
RETURN	


METHOD GetAllMultilines(cPreviousMemoLocal AS STRING) AS STRING
	TRY
	LOCAL cTempName := "",cReplace:="", cPrev:="",cValue:="" AS STRING
	LOCAL cTempUid := "" AS STRING
	LOCAL iFind:=0, iFindEnd:=0 AS INT	
	LOCAL charSpl1 := (CHAR)169 AS CHAR
	LOCAL charSpl2 := (CHAR)168 AS CHAR

	FOREACH oTabPage AS System.Windows.Forms.TabPage IN SELF:tabControl_Report:TabPages
		FOREACH oControl AS Control IN oTabPage:Controls
			IF oControl:HasChildren
				FOREACH oSecControl AS Control IN oControl:Controls
						cTempName := oSecControl:Name
						IF cTempName:StartsWith("TextBoxMultiline")
							cTempUid := cTempName:Substring(16)
							// Αν δεν υπάρχει πρόσθεσε το
							IF !cPreviousMemoLocal:Contains(cTempUid + charSpl2:ToString())
								cPreviousMemoLocal +=  cTempUid
								cPreviousMemoLocal +=  charSpl2:ToString()  
								cPreviousMemoLocal +=  oSecControl:Text
								cPreviousMemoLocal +=  charSpl1:ToString()
							ELSE
							// Αν υπάρχει προηγουμένως 
								iFind := cPreviousMemoLocal:IndexOf(cTempUid+charSpl2:ToString())
								iFindEnd := cPreviousMemoLocal:IndexOf(charSpl1,iFind)
								cPrev := cPreviousMemoLocal:Substring(iFind,iFindEnd-iFind)
								cValue := oSecControl:Text:Trim()
								cReplace := cTempUid+charSpl2:ToString()+cValue
								cPreviousMemoLocal := cPreviousMemoLocal:Replace(cPrev,cReplace)
							ENDIF
						ENDIF
				NEXT
			ELSE
				cTempName := oControl:Name
				IF cTempName:StartsWith("TextBoxMultiline")
					cTempUid := cTempName:Substring(16)
					IF cTempName:StartsWith("TextBoxMultiline")
							cTempUid := cTempName:Substring(16)
							// Αν δεν υπάρχει πρόσθεσε το
							IF !cPreviousMemoLocal:Contains(cTempUid + charSpl2:ToString())
								cPreviousMemoLocal +=  cTempUid
								cPreviousMemoLocal +=  charSpl2:ToString()  
								cPreviousMemoLocal +=  oControl:Text
								cPreviousMemoLocal +=  charSpl1:ToString()
							ELSE
							// Αν υπάρχει προηγουμένως 
								iFind := cPreviousMemoLocal:IndexOf(cTempUid+charSpl2:ToString())
								iFindEnd := cPreviousMemoLocal:IndexOf(charSpl1,iFind)
								cPrev := cPreviousMemoLocal:Substring(iFind,iFindEnd-iFind)
								cValue := oControl:Text:Trim()
								cReplace := cTempUid+charSpl2:ToString()+cValue
								cPreviousMemoLocal := cPreviousMemoLocal:Replace(cPrev,cReplace)
							ENDIF
						ENDIF
				ENDIF
			ENDIF
		NEXT
	NEXT
	CATCH
		wb("Error","Error in GetAllMultilines.")
		RETURN ""
	END	
RETURN cPreviousMemoLocal


METHOD checkMandatoryFields() AS LOGIC
		IF !SELF:ValidateMandatoryFields()
			RETURN FALSE
		ENDIF
RETURN TRUE

METHOD ValidateMandatoryFields() AS LOGIC
//	TRY
				
	LOCAL cMandatory, cValue, cUID, cItemTypeValues := "",cUidToCheck, cData := "", cItemNo AS STRING
	LOCAL oRows AS DataRow[]
	//LOCAL oSecRows as DataRow[]
	LOCAL oTempControl AS Control
	LOCAL lIsMandatoryOnCondition := FALSE AS LOGIC	
	

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
			oRows := SELF:oDTReportItems:Select("REPORT_UID="+SELF:cReportUID+" AND ITEM_UID="+cUID, "ITEM_UID")
			FOREACH oRow AS DataRow IN oRows
				cItemNo := oRow["ItemNo"]:ToString()
			NEXT
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
						IF oTempControl == NULL
							LOOP
						ENDIF
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
			IF (cMandatory == NULL || cMandatory == "0") .AND. !lIsMandatoryOnCondition
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
				LOCAL oControlToTest := oControl  AS Control
				
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
				oMainForm:BBIEditReport_ItemClick(NULL,NULL)
				RETURN FALSE
			ENDIF
			lIsMandatoryOnCondition := FALSE
		NEXT
	NEXT
	
//	CATCH exc AS Exception
//		MessageBox.Show(exc:StackTrace:ToString())
//	END
	
RETURN TRUE


METHOD ValidateMandatoryFields(oParentControl AS Control) AS LOGIC
	LOCAL cMandatory, cValue, cUID, cItemTypeValues := "",cUidToCheck, cData := "", cItemNo AS STRING
	LOCAL oRows AS DataRow[]
	//LOCAL oSecRows as DataRow[]
	LOCAL oTempControl AS Control
	LOCAL lIsMandatoryOnCondition := FALSE AS LOGIC	
	
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
			NEXT
			//Bring all comboz
			oRows := SELF:oDTReportItems:Select("REPORT_UID="+SELF:cReportUID, "ITEM_UID") 
			//Check if the ID of the control is inside
			FOREACH oRow AS DataRow IN oRows
				cUidToCheck :=  oRow["ITEM_UID"]:ToString()
				cItemTypeValues := oRow["ItemTypeValues"]:ToString()
				IF cItemTypeValues != ""
					IF cItemTypeValues:Contains("<ID"+cItemNo+">")
						oTempControl := GetControl("ComboBox", cUidToCheck)
						IF oTempControl == NULL
							LOOP
						ENDIF
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
			IF (cMandatory == "0" .OR. cMandatory == NULL) .AND. !lIsMandatoryOnCondition
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
				LOCAL oControlToTest := oControl AS Control
				
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
				oMainForm:BBIEditReport_ItemClick(NULL,NULL)
				RETURN FALSE
			ENDIF
			lIsMandatoryOnCondition := FALSE
	NEXT
RETURN TRUE


METHOD GetLabel(cItemUID AS STRING, oTabPage AS System.Windows.Forms.TabPage) AS STRING
	LOCAL cName, cLabel := "" AS STRING

	FOREACH oControl AS Control IN oTabPage:Controls
		cName := oControl:Name
		IF cName == "Label" + cItemUID .OR. cName == "CheckBox" + cItemUID .OR. cName == "DatePicker" + cItemUID
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
		IF cName == "Label" + cItemUID .OR. cName == "CheckBox" + cItemUID .OR. cName == "DatePicker" + cItemUID
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

METHOD deleteNewlyCreatedReport() AS VOID
		LOCAL cStatement :="Delete From FMDataPackages WHERE PACKAGE_UID ="+cMyPackageUID AS STRING
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		cStatement :="Delete From FMData WHERE PACKAGE_UID ="+cMyPackageUID 
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:Close()
		
RETURN

METHOD loadFromExcelForNewReport() AS VOID
	LOCAL cStatement := "" AS STRING
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
	System.Threading.Thread.CurrentThread:CurrentCulture:=System.Globalization.CultureInfo{"en-GB"}

	LOCAL oXL AS Microsoft.Office.Interop.Excel.Application
	LOCAL oWB AS Microsoft.Office.Interop.Excel._Workbook
	LOCAL oRange AS Microsoft.Office.Interop.Excel.Range
	//LOCAL oSheet AS Microsoft.Office.Interop.Excel._WorkSheet

	oXL := Microsoft.Office.Interop.Excel.Application{}
    oWB := oXL:Workbooks:Open(cFile,Type.Missing,TRUE,Type.Missing,Type.Missing,Type.Missing,Type.Missing,Type.Missing,Type.Missing,Type.Missing,Type.Missing,Type.Missing,Type.Missing,Type.Missing,Type.Missing)
    //oSheet := xlWorkbook:Sheets[1]
	
	LOCAL cNameName, cName1, cRangeValue AS STRING
	LOCAL cReportUidLocal, cItemUIDLocal, cItemTypeLocal AS STRING
	LOCAL cMultiLineValues := "" AS STRING
	
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
		ELSEIF cName1:Contains("_VesselUID")
			LOOP
		ELSEIF cName1:Contains("_UID")
			IF name == NULL
				LOOP			
			ENDIF
			TRY
				oRange := name:RefersToRange
			CATCH exc AS Exception
				MessageBox.Show(exc:Message)	
				LOOP		
			END TRY

			IF oRange:Value2 == NULL
				LOOP
			ENDIF
			cRangeValue := oRange:Value2:ToString()
			
			IF oRange:NumberFormat:ToString():Contains("yy")
				cRangeValue :=  oRange:Text:ToString()
			ENDIF 

			IF cRangeValue == NULL .OR. cRangeValue:Trim()==""
				LOOP
			ENDIF
			cName1 := cName1:Replace("_UID","")
			cItemTypeLocal := cName1:Substring(0,1)
			cItemUIDLocal := cName1:Substring(1)
			
			//MessageBox.Show("Value :"+cRangeValue,cItemUIDLocal+" of type :"+cItemTypeLocal)
			IF cItemTypeLocal == "M"
					LOCAL mergeCells := oRange:MergeCells AS OBJECT
					IF (LOGIC)mergeCells == TRUE
						LOCAL oObjectArray AS OBJECT[,]
						oObjectArray := (OBJECT[,])oRange:Value2

						//Local oMyReader := CSharpDll.SoftwayReader{} as CSharpDll.SoftwayReader
						//cRangeValue := oMyReader:cGetMyElement(oObjectArray,1,1)
						LOCAL oObjectElement := (OBJECT)oObjectArray[2,2] AS OBJECT
						IF oObjectElement == NULL
							LOOP
						ENDIF						
						cRangeValue := oObjectElement:ToString():Trim()

						IF cRangeValue == NULL .OR. cRangeValue:Trim()==""
							LOOP
						ENDIF

					ENDIF
					cMultiLineValues +=  cItemUIDLocal
					cMultiLineValues +=  ((CHAR)168):ToString()  
					cMultiLineValues +=  cRangeValue
					cMultiLineValues +=  ((CHAR)169):ToString()
			ELSEIF cItemTypeLocal == "D"
				 //MessageBox.Show(cRangeValue)
				TRY
					//LOCAL rReal := Double.Parse(cRangeValue) AS Double
					//LOCAL dDt := DateTime.FromOADate(rReal) AS DateTime
					LOCAL dDt := DateTime.Parse(cRangeValue) AS DateTime
					// Αν η ημερομηνία είναι η ημερομηνία του report.
					IF cItemUIDLocal == DateTime_ItemUID
						LOCAL cDateGMT := dDt:ToString("yyyy-MM-dd HH:mm") AS STRING
						cStatement :="Update FMDataPackages SET DateTimeGMT ='"+;
						oSoftway:ConvertWildcards(cDateGMT, FALSE)+"' WHERE Package_Uid ="+cMyPackageUID
						oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
					ENDIF

					//MessageBox.Show(dDt:ToString())
					SELF:insertIntoFMData(cMyPackageUID,cItemUIDLocal,dDt:ToString())
				CATCH exc AS Exception
					MessageBox.Show(exc:Message,cName1)	
					LOOP		
				END TRY
				 
			ELSE
				 SELF:insertIntoFMData(cMyPackageUID,cItemUIDLocal,cRangeValue)
			ENDIF
			
		ENDIF
	NEXT
	//save all multilines
	IF cMultiLineValues != ""
		TRY
			cStatement :=" UPDATE FMDataPackages SET"+;
						 " MEMO = '"+oSoftway:ConvertWildcards(cMultiLineValues, FALSE)+"'"+;
						 " WHERE PACKAGE_UID="+cMyPackageUID 
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			//messagebox.Show(cStatement)
		CATCH exc AS Exception
			messagebox.Show(cStatement+" / "+exc:tostring())
		END TRY
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


	METHOD GetMyDataForCombo(cFieldLocal AS STRING, cTableLocal AS STRING,cWhereClause :="" AS STRING) AS STRING
		LOCAL cToReturn := ""	AS STRING
		LOCAL cStatement  AS STRING

		cStatement := "SELECT DISTINCT "+cFieldLocal+" as cData From "+cTableLocal+" "+cWhereClause+" Order By "+cFieldLocal+" Asc"

		LOCAL oDTLocal := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

		FOREACH oRow AS DataRow IN oDTLocal:Rows
			cToReturn += oRow["cData"]:ToString() +";"
		NEXT
	RETURN cToReturn
	
CLASS DoubleBufferedTableLayoutPanel  INHERIT System.Windows.Forms.TableLayoutPanel

	CONSTRUCTOR()
		SUPER()
		DoubleBuffered := TRUE
	RETURN 
END CLASS

END CLASS
