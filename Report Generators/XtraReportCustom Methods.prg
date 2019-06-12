// XtraReportCustom_Methods.prg
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Collections

#using DevExpress.XtraPrinting
#Using DevExpress.XtraPrintingLinks
#Using DevExpress.XtraReports
#Using DevExpress.XtraReports.UI

PARTIAL CLASS XtraReportCustom INHERIT DevExpress.XtraReports.UI.XtraReport
	EXPORT oDTReport AS DataTable

METHOD XtraReportCustom_OnDataSourceRowChanged(e AS DevExpress.XtraReports.UI.DataSourceRowEventArgs) AS VOID
//wb(e:CurrentRow:ToString()+CRLF+e:RowCount:ToString())
//wb(SELF:oDS:Tables:Count:ToString()+CRLF+SELF:oDS:Tables[0]:TableName)
/*	IF SELF:oDS:Tables["FMReportPresentation"]:Rows:Count == 0
		//wb(e:CurrentRow:ToString()+CRLF+e:RowCount:ToString()+CRLF+SELF:oDS:Tables["FMReportPresentation"]:TableName, "000")
		RETURN
	ENDIF*/

	//LOCAL oRow := SELF:oDS:Tables["FMReportPresentation"]:Rows[e:CurrentRow] AS DataRow
	LOCAL oRow := SELF:oDTReport:Rows[e:CurrentRow] AS DataRow

	LOCAL cBackColor := oRow["BackColor"]:ToString() AS STRING
	LOCAL oBackColor := oMainForm:AssignColor(cBackColor) AS System.Drawing.Color

	LOCAL cForeColor := oRow["ForeColor"]:ToString() AS STRING
	LOCAL oForeColor := oMainForm:AssignColor(cForeColor) AS System.Drawing.Color
//wb(cBackColor+CRLF+cForeColor+CRLF+oRow["FORMULA_UID"]:ToString())

	//LOCAL cCustomItemUnit := oRow["CustomItemUnit"]:ToString():ToUpper() AS STRING
	//IF cCustomItemUnit == "TEXT" .or. cCustomItemUnit == "DATE"
	//	// Hide value
	//	oForeColor := oBackColor
	//	//oRow["Amount"] := System.DBNull.Value
	//ENDIF

	LOCAL lBold := Convert.ToBoolean(oRow["Bold"]) AS LOGIC
	LOCAL lUnderLine := Convert.ToBoolean(oRow["UnderLine"]) AS LOGIC
	LOCAL oFont AS System.Drawing.Font
	LOCAL oFontStyle AS System.Drawing.FontStyle

	DO CASE
	CASE lBold .AND. lUnderLine
		oFontStyle := System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Underline

	CASE lBold
		oFontStyle := System.Drawing.FontStyle.Bold

	CASE lUnderLine
		oFontStyle := System.Drawing.FontStyle.Underline

	OTHERWISE
		oFontStyle := System.Drawing.FontStyle.Regular
	ENDCASE
	oFont := System.Drawing.Font{"Tahoma", ((Single) 9), oFontStyle}

	LOCAL aCells := XRTableCell[]{3} AS XRTableCell[]
	aCells[1] := SELF:xrTableCell_Description
	aCells[2] := SELF:xrTableCell_TextField
	aCells[3] := SELF:xrTableCell_Amount

	FOREACH oCell AS XRTableCell IN aCells
		oCell:Font := oFont

		//IF cBackColor <> "0"
			oCell:BackColor := oBackColor
		//ENDIF
		//IF cForeColor <> "0"
			oCell:ForeColor := oForeColor
		//ENDIF
	NEXT
RETURN


//METHOD ChangeCellsColor(aCells as XRTableCell[], oBackColor as Color, oForeColor as Color) AS VOID
//	FOREACH oCell AS XRTableCell IN aCells
//      oCell:BackColor := oBackColor
//      oCell:ForeColor := oForeColor
//	NEXT
//RETURN


//METHOD AddBindings() AS VOID
//	// Create a data binding.
//	LOCAL oBinding1 := XRBinding{"Text", SELF:oDS, "FMReportPresentation.Description"} AS XRBinding
//	// Add the created binding to the binding collection of the xrTableCell_Description label.
//	SELF:xrTableCell_Description:DataBindings:Add(oBinding1)

//	LOCAL oBinding2 := XRBinding{"Text", SELF:oDS, "FMReportPresentation.TextField"} AS XRBinding
//	// Add the created binding to the binding collection of the xrTableCell_TextField label.
//	SELF:xrTableCell_TextField:DataBindings:Add(oBinding2)

//	LOCAL oBinding3 := XRBinding{"Text", SELF:oDS, "FMReportPresentation.Amount"} AS XRBinding
//	// Add the created binding to the binding collection of the xrTableCell_Amount label.
//	SELF:xrTableCell_Amount:DataBindings:Add(oBinding3)

//	// Create and add the binding to the binding collection of the lbProductName label.
//	//lbProductName.DataBindings.Add("Text", dsProducts1, "Products.ProductName");
//RETURN

END CLASS


PARTIAL CLASS ReportDefinitionForm INHERIT DevExpress.XtraEditors.XtraForm

METHOD XtraReportCustom() AS VOID
	// Clear and fill ArrayLists
	SELF:aFormulas := ArrayList{}
	SELF:aValues := ArrayList{}

	IF ! SELF:CheckAllFormulas()
		RETURN
	ENDIF

	//IF SELF:oLBCItemVoyage == NULL
		LOCAL oSelectVoyageForm := SelectVoyageForm{} AS SelectVoyageForm
		oSelectVoyageForm:cVesselUID := oMainForm:GetVesselUID
	IF oSelectVoyageForm:cVesselUID:StartsWith("Fleet")
		wb("Please select a Vessel")
		RETURN
	ENDIF
		oSelectVoyageForm:ShowDialog()
		IF oSelectVoyageForm:DialogResult <> DialogResult.OK
			RETURN
		ENDIF

		SELF:oLBCItemVoyage := (MyLBCVoyageItem)oSelectVoyageForm:LBCVoyages:SelectedItem
		SELF:oLBCItemRouting := (MyLBCVoyageItem)oSelectVoyageForm:LBCRouting:SelectedItem
	//ENDIF

	IF ! SELF:ReadDates()
		RETURN
	ENDIF

	// Clear [FMReportPresentation]
	LOCAL cStatement AS STRING
	cStatement:="DELETE FROM FMReportPresentation"+;
				" WHERE UserID='"+oUser:UserID+"'"
	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)

	SELF:Cursor := Cursors.WaitCursor
	Application.DoEvents()

	IF ! SELF:CompileSingleFormulas(oSelectVoyageForm)
		SELF:Cursor := Cursors.Default
		RETURN
	ENDIF

	//SELF:ShowFormulasArray()

	IF ! SELF:CompileFormulas()
		SELF:Cursor := Cursors.Default
		RETURN
	ENDIF

	IF ! SELF:AddEmptyFormulaLines()
		SELF:Cursor := Cursors.Default
		RETURN
	ENDIF

	//SELF:FormatNumericValues()

	LOCAL oXtraReportCustom := XtraReportCustom{} AS XtraReportCustom
	LOCAL options := oXtraReportCustom:ExportOptions AS ExportOptions
    //options:PrintPreview:DefaultDirectory := cTempDocDir
    options:PrintPreview:ShowOptionsBeforeExport := FALSE

	cStatement:="SELECT FMReportFormulas.*, FMReportPresentation.Amount, FMReportPresentation.TextField,"+;
				" FMReportItems.Unit AS ItemUnit, FMCustomItems.Unit AS CustomItemUnit"+;
				" FROM FMReportPresentation"+;
				" INNER JOIN FMReportFormulas ON FMReportFormulas.FORMULA_UID=FMReportPresentation.FORMULA_UID"+;
				" LEFT OUTER JOIN FMReportItems ON FMReportItems.ItemNo=FMReportFormulas.ID"+;
				" LEFT OUTER JOIN FMCustomItems ON FMCustomItems.ID=FMReportFormulas.ID"+;
				" WHERE FMReportFormulas.REPORT_UID="+SELF:GetSelectedReportDefinition("cUID")+;
				" AND UserID='"+oUser:UserID+"'"+;
				" AND HideLine=0"+;
				" ORDER BY LineNum"
	oXtraReportCustom:oDTReport := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	oXtraReportCustom:oDTReport:TableName := "FMReportPresentation"
	IF oXtraReportCustom:oDTReport:Rows:Count == 0
		SELF:Cursor := Cursors.Default
		RETURN
	ENDIF

	// Create Primary Key
	oSoftway:CreatePK(oXtraReportCustom:oDTReport, "LineNum")

	LOCAL cVesselName := oMainForm:GetVesselName AS STRING
	oXtraReportCustom:xrLabelCompany:Text := " Vessel: "+cVesselName

	// Get the last Routing's DateTime (or current UTC):
	LOCAL cDate := SELF:oLBCItemRouting:oRow["CompletedGMT"]:ToString() AS STRING
	LOCAL dDate AS DateTime
	IF cDate == ""
		dDate := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC)
	ELSE
		dDate := Datetime.Parse(cDate)
	ENDIF
	oXtraReportCustom:xrLabelPrintedOn:Text := "Report date: "+dDate:ToString("dd/MM/yyyy, HH:mm:ss")+" (GMT)  "

	// Report title
	oXtraReportCustom:xrLabelTitle:Text := SELF:GetSelectedReportDefinition("Name")

	// Data bindings
//	oXtraReportCustom:AddBindings()

	LOCAL oDS := XtraReportCustom_DataSet{oXtraReportCustom:oDTReport} AS XtraReportCustom_DataSet
	oXtraReportCustom:DataSource := oDS

	//oReportForm:DrawGrid := TRUE
	oXtraReportCustom:ShowPreview()

	// Hide Send via eMail TooBar Button
	oXtraReportCustom:PrintingSystem:SetCommandVisibility(PrintingSystemCommand.SendFile, CommandVisibility.None)

	SELF:Cursor := Cursors.Default
	Application.DoEvents()
RETURN

END CLASS

//PARTIAL CLASS XtraReportCustom INHERIT DevExpress.XtraReports.UI.XtraReport
//	PRIVATE oDTLevelA AS DataTable
//	PRIVATE oDTLevelB AS DataTable

//METHOD CreateTable() AS VOID
//	LOCAL cStatement AS STRING

//		cStatement:="SELECT FMReportFormulas.*, FMReportItems.Unit AS ItemUnit, FMCustomItems.Unit AS CustomItemUnit"+;
//					" FROM FMReportPresentation"+;
//					" INNER JOIN FMReportFormulas ON FMReportFormulas.FORMULA_UID=FMReportPresentation.FORMULA_UID"+;
//					" LEFT OUTER JOIN FMReportItems ON FMReportItems.ItemNo=FMReportFormulas.ID"+;
//					" LEFT OUTER JOIN FMCustomItems ON FMCustomItems.ID=FMReportFormulas.ID"+;
//					" WHERE REPORT_UID=2"+;
//					" ORDER BY LineNum"
//	SELF:oDTLevelA := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
//	SELF:oDTLevelA:TableName := "FMReportPresentation"

//	// Create Primary Key
//	LOCAL oColPK1:=DataColumn[]{1} AS DataColumn[]
//	oColPK1[1] := SELF:oDTLevelA:Columns["LineNum"]
//	SELF:oDTLevelA:PrimaryKey := oColPK1
//RETURN

//END CLASS
