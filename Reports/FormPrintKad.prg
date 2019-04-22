// ExcelReportItems.prg
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#Using System.IO
#Using System.Diagnostics
#Using Microsoft.Office.Interop.Excel
#USING System.Reflection
#Using System.Collections


PARTIAL CLASS MainForm INHERIT DevExpress.XtraEditors.XtraForm

METHOD PrintFormToExcelFile(cReportUID as String, cReportName as String, lEmpty as LOGIC, cVesselUID as String, cVesselName as String) AS VOID
	//IF TRUE
	//	wb("Under construction")
	//	RETURN
	//ENDIF
	LOCAL cStatement AS STRING
	//LOCAL cReportUID := oMainForm:LBCReports:SelectedValue:ToString() AS STRING
	//LOCAL cReportName := oMainForm:LBCReports:GetDisplayItemValue(oMainForm:LBCReports:SelectedIndex):ToString() AS STRING
	LOCAL cMyPackageUID := ""  AS STRING
	LOCAL cMyPackageName := "" AS STRING
	
	
	IF(!lEmpty)
		cMyPackageUID := SELF:TreeListVesselsReports:FocusedNode:Tag:ToString()
		cMyPackageName := SELF:TreeListVesselsReports:FocusedNode:GetValue(0):ToString() 
		IF cReportUID:Trim() == "7" .and.  SELF:TreeListVesselsReports:Visible == TRUE
			//Find cReportUID by the selected Report
			cReportUID := SELF:getReportIUDfromPackage(cMyPackageUID)
		ENDIF
	ENDIF
	//wb(cReportUID+"/"+cReportName)
	
	IF cVesselUID:StartsWith("Fleet") || cVesselUID =="0"
		wb("Please select a Vessel")
		RETURN
	ENDIF
	
	//cVesselName := cVesselName
	LOCAL cFile AS STRING
	cFile := cTempDocDir+"\FMData_"+cVesselName:Replace("/", "_")+"_"+Datetime.Now:ToString("dd_MM_yyyy__HH_mm_ss")+".XLSX"
	SELF:Cursor := System.Windows.Forms.Cursors.WaitCursor
	LOCAL oldCI AS System.Globalization.CultureInfo
	oldCI:=System.Threading.Thread.CurrentThread:CurrentCulture
	System.Threading.Thread.CurrentThread:CurrentCulture:=System.Globalization.CultureInfo{"en-US"}
TRY
		LOCAL oXL AS Microsoft.Office.Interop.Excel.Application
		LOCAL oWB AS Microsoft.Office.Interop.Excel._Workbook
		LOCAL oSheet AS Microsoft.Office.Interop.Excel._WorkSheet 
		//LOCAL oRange AS Microsoft.Office.Interop.Excel.Range
		// Start Excel and get Application object. 
		oXL := Microsoft.Office.Interop.Excel.Application{}
		// Set some properties
		oXL:Visible := FALSE
		oXL:DisplayAlerts := FALSE
		// Get a new workbook. 
		oWB := oXL:Workbooks:Add(Missing.Value)
		// Get the active sheet 
		//oSheet := (Microsoft.Office.Interop.Excel._WorkSheet)oWB:ActiveSheet
		
		
		LOCAL cData, cMemo :="" AS STRING
		cStatement := "Select * from FMItemCategories Where CATEGORY_UID=0"
		LOCAL oTempDataTable := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		IF oTempDataTable:Rows:Count!=1
			oSoftway:SetIdentityInsert("FMItemCategories", "ON", oGFH, oConn)
			cStatement := "INSERT INTO FMItemCategories (CATEGORY_UID, Description, SortOrder)"+;
						" VALUES (0, 'General' , 0 )"
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
			oSoftway:SetIdentityInsert("FMItemCategories", "OFF", oGFH, oConn)
		ENDIF
		cStatement:="SELECT DISTINCT FMItemCategories.CATEGORY_UID, FMItemCategories.Description, FMItemCategories.SortOrder"+;
					" FROM FMItemCategories"+oMainForm:cNoLockTerm+;
					" INNER JOIN FMReportItems ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
					" AND FMReportItems.REPORT_UID="+cReportUID+;
					" ORDER BY FMItemCategories.SortOrder"
		LOCAL oDTItemCategories := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		
		cStatement:="SELECT FMReportItems.*"+;
					" FROM FMReportItems"+oMainForm:cNoLockTerm+;
					" LEFT OUTER JOIN FMItemCategories ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
					" WHERE REPORT_UID="+cReportUID+;
					" ORDER BY FMItemCategories.SortOrder, ItemNo"
		LOCAL oDTReportItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable


		LOCAL oDTFMData AS DataTable
		LOCAL oDMLE as DataTable
		
		IF(!lEmpty) // If it is not a printout of an empty form get the data
			cStatement:="SELECT FMDataPackages.PACKAGE_UID, FMDataPackages.Status, FMData.ITEM_UID, FMData.Data FROM FMData"+oMainForm:cNoLockTerm+;
						" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
						" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
						" WHERE FMDataPackages.VESSEL_UNIQUEID="+cVesselUID+;
						" AND FMDataPackages.REPORT_UID="+cReportUID+;
						" AND FMDataPackages.PACKAGE_UID ="+cMyPackageUID+" "
			oDTFMData := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		
			// Check if MultiLine control's value exists in FMData
			cStatement:="SELECT ITEM_UID FROM FMReportItems"+oMainForm:cNoLockTerm+;
						" WHERE ItemType='M' AND REPORT_UID="+cReportUID
			oDMLE := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
			//wb(cStatement, oDMLE:Rows:Count:ToString())
			TRY
				IF oDMLE:Rows:Count > 0
					cStatement:="SELECT Memo FROM FMDataPackages"+oMainForm:cNoLockTerm+;
								" WHERE PACKAGE_UID="+cMyPackageUID
					cMemo := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Memo")
				ENDIF
			CATCH exc AS Exception
				MessageBox.Show(exc:ToString(),"Error on Multiline Fields Display.")
			END
		ENDIF
		//Initialize variables 
	LOCAL nRow := 9, nCol := 2, iCountSheets:=0 AS INT
	LOCAL oRange AS Microsoft.Office.Interop.Excel.Range
	LOCAL cCategoryUID AS STRING
	
FOREACH oSheetRow AS DataRow IN oDTItemCategories:Rows
		/*IF iCountSheets==3
			EXIT	
		ENDIF*/
	//Variables used in loops
	LOCAL cSheetName := "" AS STRING
	LOCAL lTableMode AS LOGIC
	LOCAL oRowsLocal  AS DataRow[]
	LOCAL iMaxColumns :=1 AS INT
	LOCAL cItemTypeValues := "" AS STRING
	//
try
		iCountSheets++
		cCategoryUID := oSheetRow["CATEGORY_UID"]:ToString()
		//SELF:FillTab(oSheetRow["CATEGORY_UID"]:ToString(), oSheetRow["Description"]:ToString())
		//LOCAL aCalculatedItemUID := ArrayList{} as ArrayList
		//LOCAL aUsedInCalculations := ArrayList{} as ArrayList
		//LOCAL aFormula := ArrayList{}  as ArrayList
		//LOCAL decimalSeparator := numberFormatInfo:NumberDecimalSeparator AS STRING
		//LOCAL groupSeparator := numberFormatInfo:NumberGroupSeparator as String
		IF iCountSheets>3
			oWB:Worksheets:Add(Type.Missing, (_WorkSheet)oWB:Worksheets[iCountSheets - 1], Type.Missing, XlSheetType.xlWorksheet) //(object)(nSheets - 1), (object)nSheets, (object)1, Type.Missing)
			//oSheet := (_WorkSheet)oWB:Worksheets[nSheets]
		ENDIF
		oSheet:=(_WorkSheet)oWB:Worksheets[iCountSheets]
		IF oSheet==NULL
			MessageBox.Show("No other sheet.")
			EXIT
		ENDIF
		cSheetName := ""
		IF iCountSheets==1
			oSheet:Name := "General"
		ELSE
			TRY 
				cSheetName := oSheetRow["Description"]:ToString()
				IF cSheetName:Length>29
					oSheet:Name := cSheetName:Substring(0,29)
				ELSE
					oSheet:Name := cSheetName
				ENDIF
			CATCH exc AS Exception
				IF exc:Message:Contains("invalid")
					oSheet:Name := "Invalid Name"
				ENDIF
			end try
		ENDIF
		
		lTableMode := false
		nRow := 9 
		nCol := 2 
		
		oRange := oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[1, 2]]
		// Set first column width
		oRange:EntireColumn:ColumnWidth := 5
		//Compute Optimum Column Width
		oRowsLocal := null
			oRowsLocal := oDTReportItems:Select("REPORT_UID="+cReportUID+" AND CATEGORY_UID="+cCategoryUID+" AND ItemType='A'" , "ItemNo")
			iMaxColumns :=1 
			FOREACH oRow AS DataRow IN oRowsLocal
				cItemTypeValues := oRow["ItemTypeValues"]:ToString() 
				local cOccurs as String[]
				LOCAL iCountColumns   AS INT
				cOccurs := cItemTypeValues:Split(';') 
				iCountColumns := cOccurs:Length
				IF iCountColumns>iMaxColumns
					iMaxColumns:=iCountColumns
				ENDIF
			NEXT
			IF iMaxColumns>1
				local n as INT
				FOR n := 1 UPTO iMaxColumns
					oRange := oSheet:Range[oSheet:Cells[1, n+1], oSheet:Cells[2, n+1]]
					oRange:EntireColumn:ColumnWidth := 190/iMaxColumns
				NEXT
			ELSE
				local n as INT
				FOR n := 1 UPTO 4
					oRange := oSheet:Range[oSheet:Cells[1, n+1], oSheet:Cells[2, n+1]]
					oRange:EntireColumn:ColumnWidth := 190/4
				NEXT
				iMaxColumns:=4
			ENDIF
		//Set Company
		oSheet:Cells[1, 2] := cLicensedCompany
		oRange := oSheet:Range[oSheet:Cells[1, 2], oSheet:Cells[3, 1+iMaxColumns]]
		oRange:Merge(NULL)
		oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
		oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
		//oRange:EntireRow:RowHeight := 30
		oRange:Font:Bold := TRUE
		oRange:Font:Size := 16
		//Set Vessel
		oSheet:Cells[4, 2] := cVesselName
		oRange := oSheet:Range[oSheet:Cells[4,2], oSheet:Cells[4, 1+iMaxColumns]]
		oRange:Font:Bold := true
		oRange:Merge(NULL)
		oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
		oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
		oRange:Name := "_VesselUID"+cVesselUID
		//Set Report Name
		oSheet:Cells[5,2]  := cMyPackageName
		oRange := oSheet:Range[oSheet:Cells[5,2], oSheet:Cells[5, 1+iMaxColumns]]
		oRange:Merge(NULL)
		oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
		oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
		oRange:Name := "_ReportUID"+cReportUID
		//Set Report Status
		IF (!lEmpty)
			IF SELF:LBCReportsOffice:Visible // is Office Form
				oSheet:Cells[6,2]  := SELF:BBSIStatus:Caption + ", printed on "+Datetime.Now:ToString("dd/MM/yyyy  HH:mm:ss")
			ELSE
				oSheet:Cells[6,2]  := "Printed on "+Datetime.Now:ToString("dd/MM/yyyy  HH:mm:ss")
			ENDIF
		ENDIF
		oRange := oSheet:Range[oSheet:Cells[6,2], oSheet:Cells[6, 1+iMaxColumns]]
		oRange:Merge(NULL)
		oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
		oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
		//Set Sheet Name on Header
		oSheet:Cells[7,2]  := "Section : "+oSheetRow["Description"]:ToString()
		oRange := oSheet:Range[oSheet:Cells[7,2], oSheet:Cells[7, 1+iMaxColumns]]
		oRange:Merge(NULL)
		oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
		oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
		
		//
		
			//Get all items of the sheet	
			LOCAL oRows := oDTReportItems:Select("REPORT_UID="+cReportUID+" AND CATEGORY_UID="+cCategoryUID, "ItemNo") AS DataRow[]
			LOCAL iTableStart, iTableFinish AS INT
			LOCAL iCountColumns   AS INT
			FOREACH oRow AS DataRow IN oRows
				cData := "No Data"
				LOCAL cItemUID := oRow["ITEM_UID"]:ToString() AS STRING
				LOCAL cItemType := oRow["ItemType"]:ToString() AS STRING
				cItemTypeValues := oRow["ItemTypeValues"]:ToString() 
				LOCAL cCalculatedField := oRow["CalculatedField"]:ToString() AS STRING
				LOCAL cSLAA := oSoftway:LogicToString(oRow["SLAA"]) AS STRING
				LOCAL cIsDD := oSoftway:LogicToString(oRow["IsDD"]) AS STRING
				LOCAL cNotNumbered := oSoftway:LogicToString(oRow["NotNumbered"]) AS STRING
				LOCAL Mandatory := oSoftway:LogicToString(oRow["Mandatory"]) AS STRING
				LOCAL cItemName := oRow["ItemName"]:ToString():Trim() AS STRING
				
				IF !lEmpty
					LOCAL oRowData := oDTFMData:Select("ITEM_UID="+cItemUID, "Data") AS DataRow[]
					IF oRowData:Length > 0
						LOCAL oOneRowData := oRowData[1] AS DataRow
						cData := oOneRowData["Data"]:ToString()
					ENDIF
				ELSE
					cData := ""
				ENDIF
				//wb(cItemUID, cData)
				//STATIC LOCAL cPreviousLabel := "" AS STRING
				//STATIC LOCAL nInstance := 0 AS INT
				//STATIC LOCAL cPreviousItemType AS STRING
				//STATIC LOCAL cPreviousLabelSize as int
				LOCAL lSameSerieItem AS LOGIC
				local cOccurs as String[]
				
				IF cItemType == "A"
					IF lTableMode // sunexomenoi pinakes vale ston prohgoumeno to plaisio tou
						oRange := oSheet:Range[oSheet:Cells[iTableStart+1, 2], oSheet:Cells[nRow-1, 1+iCountColumns]]
						oRange:WrapText := true
						oRange:EntireRow:AutoFit()
						oRange:BorderAround( XlLineStyle.xlDouble,XlBorderWeight.xlThick,XlColorIndex.xlColorIndexAutomatic,Color.Black)
						oRange:Borders:LineStyle := XlLineStyle.xlDouble
					ENDIF
					nRow++
					lTableMode := TRUE
					iTableStart := nRow
					cOccurs := cItemTypeValues:Split(';') 
					iCountColumns := cOccurs:Length  
					SELF:addControlToExcel(oSheet,oRow, nRow, nCol, cData, cMemo, TRUE, cMyPackageUID)
					nRow++
					LOOP
				ENDIF
				IF lTableMode 
					IF cSLAA == "1"
						SELF:addControlToExcel(oSheet,oRow, nRow, nCol, cData, cMemo, TRUE, cMyPackageUID)
						nCol++
						iCountColumns--
						IF iCountColumns==0
							nRow++
							nCol:=2
							iCountColumns:= cOccurs:Length   
						ENDIF
					ELSE
						iTableFinish := nRow
						lTableMode := FALSE
						oRange := oSheet:Range[oSheet:Cells[iTableStart+1, 2], oSheet:Cells[iTableFinish-1, 1+iCountColumns]]
						oRange:WrapText := true
						oRange:EntireRow:AutoFit()
						oRange:BorderAround( XlLineStyle.xlDouble,XlBorderWeight.xlThick,XlColorIndex.xlColorIndexAutomatic,Color.Black)
						oRange:Borders:LineStyle := XlLineStyle.xlDouble
						nRow := nRow + 2
						nCol := 2
						self:addControlToExcel(oSheet,oRow, nRow, nCol, cData, cMemo, false, cMyPackageUID)
					ENDIF
				ELSE	
					nCol := 2
					SELF:addControlToExcel(oSheet,oRow, nRow, nCol, cData, cMemo, FALSE, cMyPackageUID)
					nRow++
				ENDIF
			NEXT
			IF lTableMode
				oRange := oSheet:Range[oSheet:Cells[iTableStart+1, 2], oSheet:Cells[nRow-1, 1+iCountColumns]]
				oRange:WrapText := true
				oRange:EntireRow:AutoFit()
				oRange:BorderAround( XlLineStyle.xlDouble,XlBorderWeight.xlThick,XlColorIndex.xlColorIndexAutomatic,Color.Black)
				oRange:Borders:LineStyle := XlLineStyle.xlDouble
			ENDIF
			
		//ENDIF
		
		/*FOREACH name  AS Microsoft.Office.Interop.Excel.Name IN oWB:Names
			LOCAL cNameName := name:Value AS STRING
			LOCAL cName1 := name:Name AS STRING
			oRange := name:RefersToRange
			//oSheet:Cells[oRange]
			//MessageBox.Show(cNameName,cName1)
			//LOCAL cellValue := (STRING)oSheet:Cells[oRange] AS String
			MessageBox.Show(cName1+"/"+oRange:Value2:ToString(),cNameName)
		next*/
		oRange := oSheet:Range[oSheet:Cells[9, 2], oSheet:Cells[nRow-1, 1+iMaxColumns]]
		oRange:EntireColumn:AutoFit()
		lTableMode := FALSE
		oSheet:PageSetup:Zoom := FALSE
		oSheet:PageSetup:FitToPagesWide := 1
		oSheet:PageSetup:FitToPagesTall := false
		//oSheet:PageSetup.FitToPagesTall = 1;
		//oSheet:PageSetup.Orientation = Microsoft.Office.Interop.Excel.XlPageOrientation.xlLandscape;
		oSheet:PageSetup:PaperSize := Microsoft.Office.Interop.Excel.XlPaperSize.xlPaperA4
		//oSheet:PageSetup:FitToPagesWide := 1
		//oRange:PageBreak := XlPageBreak.xlPageBreakManual
		//oSheet:VPageBreaks:Add(oSheet:Range[1, 2+iMaxColumns])
		//Cells.PageBreak to xlPageBreakNone
		/*oRange := oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[nRow-1, 1+iMaxColumns]]
		LOCAL iHPB := oSheet:HPageBreaks:Count AS INT
		FOREACH oPB AS HPageBreak IN oSheet:HPageBreaks
			oPB:Delete()
		next 
		
		LOCAL iVPB := oSheet:VPageBreaks:Count AS INT
		FOREACH oPB AS VPageBreak IN oSheet:VPageBreaks
			oPB:Delete()
		next */
		/*oRange:PageBreak := XlPageBreak.xlPageBreakNone
		
		iHPB := oSheet:HPageBreaks:Count 
		iVPB := oSheet:VPageBreaks:Count 
		oRange:PageBreak := XlPageBreak.xlPageBreakNone
		
		iHPB := oSheet:HPageBreaks:Count 
		iVPB := oSheet:VPageBreaks:Count 
		
		iHPB := oSheet:HPageBreaks:Count 
		iVPB := oSheet:VPageBreaks:Count */
		//Worksheets("Sheet1").Columns("J").PageBreak = xlPageBreakManual
		//oSheet:Range[oSheet:Cells[1, 1],oSheet:Cells[nRow, 2+iMaxColumns]]:PageBreak := XlPageBreak.xlPageBreakManual
		//oSheet:VPageBreaks:Add(oSheet:Range[10, 2+iMaxColumns])
		//oSheet:
		//oSheet:VPageBreaks:Add(oSheet:Range[oSheet:Cells[1, 2+iMaxColumns],oSheet:Cells[1, 2+iMaxColumns]])
		
CATCH exc AS Exception
	LOOP
end try
		
NEXT
		oSheet := (Microsoft.Office.Interop.Excel._WorkSheet)oWB:Sheets[1]
		oSheet:Select(Missing.Value)
		oWB:SaveAs(cFile, Microsoft.Office.Interop.Excel.XlFileFormat.xlOpenXMLWorkbook, Missing.Value, Missing.Value, Missing.Value, Missing.Value, ;
						Microsoft.Office.Interop.Excel.XlSaveAsAccessMode.xlExclusive, Missing.Value, Missing.Value, Missing.Value, Missing.Value, Missing.Value)
		
		System.Runtime.InteropServices.Marshal.ReleaseComObject(oSheet)
		oWB:Close(Missing.Value, Missing.Value, Missing.Value)
		System.Runtime.InteropServices.Marshal.ReleaseComObject(oWB)
		oWB := NULL
		oXL:Quit()
		// Clean up
		// NOTE: When in release mode, this does the trick
		GC.WaitForPendingFinalizers()
		GC.Collect()
		GC.WaitForPendingFinalizers()
		GC.Collect()
		//Marshal.ReleaseComObject(sheets)
		
		TRY
			LOCAL oProcessInfo:=ProcessStartInfo{cFile} AS ProcessStartInfo
			//oProcessInfo:CreateNoWindow := false
			//oProcessInfo:UseShellExecute := true
			oProcessInfo:WindowStyle := ProcessWindowStyle.Maximized
			Process.Start(oProcessInfo)
		CATCH e AS Exception
			ErrorBox(e:Message)
		END TRY

		
CATCH e AS Exception
		ErrorBox(e:Message, "OleDB Excel connection error")
		RETURN
FINALLY
		System.Threading.Thread.CurrentThread:CurrentCulture:=oldCI
		SELF:Cursor := System.Windows.Forms.Cursors.Default
END TRY

RETURN

METHOD addControlToExcel(oSheet AS Microsoft.Office.Interop.Excel._WorkSheet ,oRowItem AS DataRow, nRow AS INT, nCol AS INT, cData AS STRING, cMemo AS STRING, lTable as LOGIC, cPackageUIDLocal as String) AS VOID
		LOCAL charSpl1 := (char)169 AS Char
		LOCAL charSpl2 := (char)168 AS Char
		LOCAL oRange AS Microsoft.Office.Interop.Excel.Range
		LOCAL cTextToWrite := ""
		LOCAL cItemTypeValues := oRowItem["ItemTypeValues"]:ToString() AS STRING
		LOCAL lEmpty := cPackageUIDLocal=="" AS LOGIC
		LOCAL cMyNameLocal := oRowItem["ItemName"]:ToString() AS STRING
		LOCAL cMyUidLocal := oRowItem["ITEM_UID"]:ToString() as String
		LOCAL cMyItemTypeLocal := oRowItem["ItemType"]:ToString() as String
		local dDateFrom := DATE{2000,1,1} as DATE
		
		IF cMyItemTypeLocal == "L"		//label
				oSheet:Cells[nRow, nCol] := cMyNameLocal
				oRange := oSheet:Range[oSheet:Cells[nRow, nCol], oSheet:Cells[nRow, nCol]]
				oRange:Font:Size := 11
				oRange:Font:Bold := TRUE
				IF cMyNameLocal:Length<254
					oRange:Validation:Delete()
					oRange:Validation:Add(XlDVType.xlValidateCustom,XlDVAlertStyle.xlValidAlertStop,XlFormatConditionOperator.xlEqual,cMyNameLocal,Type.Missing)
				ENDIF
				RETURN
		ELSEIF cMyItemTypeLocal == "A"	//table
				oSheet:Cells[nRow, nCol] := cMyNameLocal
				local cOccurs := cItemTypeValues:Split(';') as String[]
				LOCAL iCountColumns := cOccurs:Length-1  AS INT
				oRange := oSheet:Range[oSheet:Cells[nRow, nCol], oSheet:Cells[nRow, nCol+iCountColumns]]
				oRange:Merge(NULL)
				oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
				oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
				oRange:EntireRow:RowHeight := 30
				oRange:Font:Size := 14
				oRange:Font:Bold := True
				//oSheet:Range{oSheet:Cells[nRow, nCol], oSheet:Cells][nRow, nCol+4]}
				RETURN
		ELSEIF cMyItemTypeLocal == "F" .and. !lEmpty	//File Uploader
				LOCAL cStatement := ""  AS STRING
				cStatement :=  "SELECT count(*) as NumberOfAtts FROM FMBlobData Where ITEM_UID="+cMyUidLocal+" AND Package_UID="+cPackageUIDLocal
				local cNumber := oSoftway:RecordExists(oMainForm:oGFHBlob, oMainForm:oConnBlob, cStatement, "NumberOfAtts") as String
				cData := cNumber + " file(s)"
		ELSEIF cMyItemTypeLocal == "M" 
			IF lEmpty
				oSheet:Cells[nRow, nCol] := cMyNameLocal+" : "
				oRange := oSheet:Range[oSheet:Cells[nRow, nCol+1], oSheet:Cells[nRow, nCol+1]]
				oRange:BorderAround( XlLineStyle.xlContinuous,XlBorderWeight.xlThick,XlColorIndex.xlColorIndexAutomatic,Color.Black)
				oRange:Borders:LineStyle := XlLineStyle.xlContinuous
				LOCAL cRangeName :=  "_UID"+cMyItemTypeLocal+cMyUidLocal AS STRING
				oRange:Name := cRangeName
				RETURN
			ELSE
				IF cMemo <> "" .and. cMemo:Contains((char)168)
					LOCAL cItems := cMemo:Split(charSpl1) AS STRING[]
					FOREACH cItem AS STRING IN cItems
						TRY
							IF cItem <> NULL .and. cItem <> ""
									LOCAL cItemsTemp := cItem:Split(charSpl2) AS STRING[]
									IF  cItemsTemp[1] == cMyUidLocal
										 IF !lTable
											oSheet:Cells[nRow, nCol] := cMyNameLocal + " : "+CRLF+ cItemsTemp[2]
											oRange := oSheet:Range[oSheet:Cells[nRow, nCol], oSheet:Cells[nRow, nCol]]
											oRange:WrapText := TRUE
											oRange:EntireRow:AutoFit()
										 ELSE
											 oSheet:Cells[nRow, nCol] := cItemsTemp[2]
										 ENDIF
										 RETURN
									ENDIF
							ENDIF
						CATCH exc AS Exception
								MessageBox.Show(exc:ToString(),"Error on Multiline Field Display.")
								LOOP
						END TRY
					NEXT
				
				ENDIF
			ENDIF
		ENDIF
		IF !lEmpty
			IF !lTable
				//cTextToWrite  := oRowItem["ItemName"]:ToString()+" ("+oRowItem["ItemNo"]:ToString()+") : "
				cTextToWrite  := cMyNameLocal+" : "
				//oSheet:Cells[nRow, nCol] := oRowItem["ItemName"]:ToString()+" ("+oRowItem["ItemNo"]:ToString()+") : "
			ENDIF
			oRange := oSheet:Range[oSheet:Cells[nRow, nCol], oSheet:Cells[nRow, nCol]]
			LOCAL cRangeName :=  "_UID"+cMyItemTypeLocal+cMyUidLocal AS STRING
			oRange:Name := cRangeName
			oSheet:Cells[nRow, nCol] := cTextToWrite + cData
		ELSE
			IF !lTable
				oSheet:Cells[nRow, nCol] := cMyNameLocal+" : "
				oRange := oSheet:Range[oSheet:Cells[nRow, nCol+1], oSheet:Cells[nRow, nCol+1]]
				oRange:BorderAround( XlLineStyle.xlContinuous,XlBorderWeight.xlThick,XlColorIndex.xlColorIndexAutomatic,Color.Black)
				oRange:Borders:LineStyle := XlLineStyle.xlContinuous
						
				LOCAL cRangeName :=  "_UID"+cMyItemTypeLocal+cMyUidLocal AS STRING
				oRange:Name := cRangeName
				IF cMyItemTypeLocal == "D" 
					oRange:Validation:Delete()
					oRange:Validation:Add(XlDVType.xlValidateDate,XlDVAlertStyle.xlValidAlertStop,XlFormatConditionOperator.xlGreater,dDateFrom,Type.Missing)
					oRange:NumberFormat  := "dd-mmm-yy"
					oRange:Validation:IgnoreBlank := TRUE
				ENDIF
			ELSE
				oRange := oSheet:Range[oSheet:Cells[nRow, nCol], oSheet:Cells[nRow, nCol]]
				LOCAL cRangeName :=  "_UID"+cMyItemTypeLocal+cMyUidLocal AS STRING
				oRange:Name := cRangeName
			ENDIF
			IF cMyItemTypeLocal == "X" 
				oRange:Validation:Delete()
				oRange:Validation:Add(XlDVType.xlValidateList,XlDVAlertStyle.xlValidAlertStop,XlFormatConditionOperator.xlBetween,self:cleanseItemTypeValues(cItemTypeValues),Type.Missing)
				oRange:Validation:IgnoreBlank := TRUE
				oRange:Validation:InCellDropdown := TRUE
			ELSEIF cMyItemTypeLocal == "D" 
					oRange:Validation:Delete()
					oRange:Validation:Add(XlDVType.xlValidateDate,XlDVAlertStyle.xlValidAlertStop,XlFormatConditionOperator.xlGreater,dDateFrom,Type.Missing)
					oRange:NumberFormat  := "dd-mmm-yy"
					oRange:Validation:InputMessage := "Note: only date values here"
					oRange:Validation:IgnoreBlank := TRUE
			ENDIF
		ENDIF
			
RETURN

METHOD cleanseItemTypeValues(cPreviousValues AS STRING) AS STRING
	cPreviousValues := cPreviousValues:Replace("<D>","") // strip the default value
	Local cToReturnLocal := "" as String
	LOCAL cItems := cPreviousValues:Split(';') AS STRING[]
	FOREACH cItem AS STRING IN cItems
		TRY
			IF cItem <> NULL .and. cItem <> ""
				LOCAL iIndex := cItem:IndexOf('<') AS INT
				IF iIndex>0
					cItem := cItem:Substring(0,iIndex)
				ENDIF
				IF cToReturnLocal==""
					cToReturnLocal := cItem
				ELSE
					cToReturnLocal += ","+cItem
				ENDIF
			ENDIF
		CATCH exc AS Exception
			MessageBox.Show(exc:ToString(),"Error on Item Type Values Display.")
			RETURN ""
		END TRY
	NEXT
		
RETURN cToReturnLocal

METHOD CategoryExists(cCatUID AS STRING, oDTReportItems as system.data.DataTable) AS LOGIC
	LOCAL oRows := oDTReportItems:Select("CATEGORY_UID="+cCatUID) AS DataRow[]
RETURN (oRows:Length > 0)

END CLASS