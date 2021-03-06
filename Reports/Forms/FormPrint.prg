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

PRIVATE iCountUsers AS INT
PRIVATE iCountPorts AS INT
PRIVATE iCountWeeks := 100 AS INT

METHOD PrintFormToExcelFile(cReportUID AS STRING, cReportName AS STRING, lEmpty AS LOGIC, ;
							cVesselUID AS STRING, cVesselName AS STRING) AS VOID

	LOCAL cStatement :="" AS STRING
	LOCAL cMyPackageUID := ""  AS STRING
	LOCAL cMyPackageName := "" AS STRING
	
	
	IF(!lEmpty)
		cMyPackageUID := SELF:TreeListVesselsReports:FocusedNode:Tag:ToString()
		cMyPackageName := SELF:TreeListVesselsReports:FocusedNode:GetValue(0):ToString() 
		IF cReportUID:Trim() == "7" .AND.  SELF:TreeListVesselsReports:Visible == TRUE
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
		oXL := Microsoft.Office.Interop.Excel.Application{}
		oXL:Visible := FALSE
		oXL:DisplayAlerts := FALSE
		oWB := oXL:Workbooks:Add(Missing.Value)
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


		cStatement:="SELECT TOP 1 *  FROM FMReportChangeLog WHERE REPORT_UID="+cReportUID+;
					"ORDER BY LogDateTime DESC"
		LOCAL oDTVersion := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

		LOCAL oDRVersion := NULL AS DataRow
		IF oDTVersion:Rows:Count > 0
			oDRVersion := oDTVersion:Rows[0]
		ENDIF

		cStatement:=" SELECT CC_UID, FK_REPORT_UID, TextValue, ComboColor "+;
					" FROM FMComboboxColors Where FK_REPORT_UID IN ("+cReportUID+",0) "+;
					" ORDER BY CC_UID Desc"
		LOCAL oDTComboColors := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

		LOCAL oDTFMData AS DataTable
		LOCAL oDMLE AS DataTable
		
		IF(!lEmpty) // If it is not a printout of an empty form, get the data
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
	LOCAL nRow := 11, nCol := 2, iCountSheets:=0, iCurrentSheetsCount:=0 AS INT
	LOCAL oRange AS Microsoft.Office.Interop.Excel.Range
	LOCAL cCategoryUID AS STRING
	
FOREACH oSheetRow AS DataRow IN oDTItemCategories:Rows

	//Variables used in loops
	LOCAL cSheetName := "" AS STRING
	LOCAL lTableMode AS LOGIC
	LOCAL oRowsLocal  AS DataRow[]
	LOCAL iMaxColumns :=1 AS INT
	LOCAL cItemTypeValues := "" AS STRING
	//
TRY
		iCountSheets++
		iCurrentSheetsCount := oWB:Worksheets:Count
		
		cCategoryUID := oSheetRow["CATEGORY_UID"]:ToString()
		IF iCountSheets>iCurrentSheetsCount
			oWB:Worksheets:Add(Type.Missing, (_WorkSheet)oWB:Worksheets[iCountSheets - 1], Type.Missing, XlSheetType.xlWorksheet) //(object)(nSheets - 1), (object)nSheets, (object)1, Type.Missing)
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
			END TRY
		ENDIF
		
		lTableMode := FALSE
		nRow := 11 
		nCol := 2 
		
		oRange := oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[1, 2]]
		// Set first column width
		oRange:EntireColumn:ColumnWidth := 5
		//Compute Optimum Column Width
		oRowsLocal := NULL
			oRowsLocal := oDTReportItems:Select("REPORT_UID="+cReportUID+" AND CATEGORY_UID="+cCategoryUID+" AND ItemType='A'" , "ItemNo")
			iMaxColumns :=1 
			FOREACH oRow AS DataRow IN oRowsLocal
				cItemTypeValues := oRow["ItemTypeValues"]:ToString() 
				LOCAL cOccurs AS STRING[]
				LOCAL iCountColumns1   AS INT
				cOccurs := cItemTypeValues:Split(';') 
				iCountColumns1 := cOccurs:Length
				IF iCountColumns1 > iMaxColumns
					iMaxColumns := iCountColumns1
				ENDIF
			NEXT
			IF iMaxColumns>1
				LOCAL n AS INT
				FOR n := 1 UPTO iMaxColumns
					oRange := oSheet:Range[oSheet:Cells[1, n+1], oSheet:Cells[2, n+1]]
					oRange:EntireColumn:ColumnWidth := 190/iMaxColumns
				NEXT
			ELSE
				LOCAL n AS INT
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
		oRange:Font:Bold := TRUE
		oRange:Merge(NULL)
		oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
		oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
		oRange:Name := "_VesselUID"+cVesselUID
		//Set Report Version
		LOCAL cVersion := "1.0" AS STRING
		IF oDRVersion <> NULL
			cVersion := oDRVersion:Item["Version"]:ToString()
		ENDIF
		oSheet:Cells[5,2]  := "Version : " + cVersion
		oRange := oSheet:Range[oSheet:Cells[5,2], oSheet:Cells[5, 1+iMaxColumns]]
		oRange:Merge(NULL)
		oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
		oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
		//Set Report Name
		oSheet:Cells[6,2]  := "Created by : " + cMyPackageName
		oRange := oSheet:Range[oSheet:Cells[6,2], oSheet:Cells[6, 1+iMaxColumns]]
		oRange:Merge(NULL)
		oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
		oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
		oRange:Name := "_ReportUID"+cReportUID
		// Approved Date and Time
		IF !lEmpty && SELF:LBCReportsOffice:Visible
			/*cStatement :=  " SELECT Date_Acted , Users.UserName FROM ApprovalData "+;
								 " Inner Join Users On Users.User_Uniqueid=ApprovalData.Receiver_UID "+;
								 " Where "+;
								 " Program_UID=2 AND Foreing_UID="+cMyPackageUID 
			LOCAL oDTLocal := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			IF oDTLocal != NULL && oDTLocal:Rows:Count > 0
				LOCAL cApprovedUserName := oDTLocal:Rows[0]:Item["UserName"]:ToString():Trim()
				LOCAL cApprovedDate := DateTime.Parse(oDTLocal:Rows[0]:Item["Date_Acted"]:ToString()):ToString("dd-MM-yyyy")
				oSheet:Cells[nRow-4,2]  := "Approved by "+cApprovedUserName+" on "+ cApprovedDate
				oRange := oSheet:Range[oSheet:Cells[nRow-4,2], oSheet:Cells[nRow-4, 1+iMaxColumns]]
				oRange:Merge(NULL)
				oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
				oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
			ELSE
				nRow--
			ENDIF*/
			LOCAL cApprovedDate, cDateActed:="" AS STRING
			cStatement :=  " SELECT ApprovalData.*, UsersApproval.UserName AS Approver, UsersRequesting.UserName AS Requesting "+;
								 " FROM ApprovalData "+;
								 " Inner Join Users As UsersApproval On UsersApproval.User_Uniqueid=ApprovalData.Receiver_UID "+;
								 " Inner Join Users As UsersRequesting On UsersRequesting.User_Uniqueid=ApprovalData.Creator_Uid "+;
								 " Where "+;
								 " Program_UID=2 AND Foreing_UID="+cMyPackageUID + " Order By ApprovalData.Appoval_UID Desc "
			LOCAL oDTLocal := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			IF oDTLocal != NULL && oDTLocal:Rows:Count > 0
				LOCAL cApprovedUserName := oDTLocal:Rows[0]:Item["Approver"]:ToString():Trim() AS STRING
				cDateActed := oDTLocal:Rows[0]:Item["Date_Acted"]:ToString():Trim()
				LOCAL cFrom_State := oDTLocal:Rows[0]:Item["From_State"]:ToString():Trim() AS STRING
				LOCAL cTo_State := oDTLocal:Rows[0]:Item["To_State"]:ToString():Trim() AS STRING
				IF oDTLocal:Rows:Count == 1 .AND. cFrom_State == "0" .AND. cTo_State == "1" //Exei ginei request gia approval alla den exei egkrithei
					nRow--
				ELSE
					IF oDTLocal:Rows:Count == 1 .AND. cFrom_State == "0" .AND. cTo_State == "2" .AND. cDateActed =="" 
					//Exei ginei request gia approval kateutheian apo dep manager se general
					//alla den exei egkrithei
					cApprovedUserName := oDTLocal:Rows[0]:Item["Requesting"]:ToString():Trim()
					cApprovedDate := DateTime.Parse(oDTLocal:Rows[0]:Item["Date_Received"]:ToString()):ToString("dd-MM-yyyy")
					ELSE
						cApprovedDate := DateTime.Parse(cDateActed):ToString("dd-MM-yyyy")
					ENDIF
					oSheet:Cells[nRow-4,2]  := "Approved by "+cApprovedUserName+" on "+ cApprovedDate
					oRange := oSheet:Range[oSheet:Cells[nRow-4,2], oSheet:Cells[nRow-4, 1+iMaxColumns]]
					oRange:Merge(NULL)
					oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
					oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
				ENDIF
			ELSE
				nRow--
			ENDIF
			//Set Report Status
			IF  SELF:LBCReportsOffice:Visible// is Office Form
				oSheet:Cells[nRow-3,2]  := SELF:BBSIStatus:Caption + ", printed on "+Datetime.Now:ToString("dd/MM/yyyy  HH:mm:ss")
			ELSE
				oSheet:Cells[nRow-3,2]  := "Printed on "+Datetime.Now:ToString("dd/MM/yyyy  HH:mm:ss")
			ENDIF
		ENDIF
		oRange := oSheet:Range[oSheet:Cells[nRow-3,2], oSheet:Cells[nRow-3, 1+iMaxColumns]]
		oRange:Merge(NULL)
		oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
		oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
		//Set Sheet Name on Header
		oSheet:Cells[nRow-2,2]  := "Section : "+oSheetRow["Description"]:ToString()
		oRange := oSheet:Range[oSheet:Cells[nRow-2,2], oSheet:Cells[nRow-2, 1+iMaxColumns]]
		oRange:Merge(NULL)
		oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
		oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
		
		//
		
			//Get all items of the sheet	
			LOCAL oRows := oDTReportItems:Select("REPORT_UID="+cReportUID+" AND CATEGORY_UID="+cCategoryUID, "ItemNo") AS DataRow[]
			LOCAL iTableStart, iTableFinish AS INT
			LOCAL iCountColumns   AS INT
			FOREACH oRow AS DataRow IN oRows
				cData := ""
				LOCAL cItemUID := oRow["ITEM_UID"]:ToString() AS STRING
				LOCAL cItemType := oRow["ItemType"]:ToString() AS STRING
				cItemTypeValues := oRow["ItemTypeValues"]:ToString() 
				LOCAL cCalculatedField := oRow["CalculatedField"]:ToString() AS STRING
				LOCAL cSLAA := oSoftway:LogicToString(oRow["SLAA"]) AS STRING
				LOCAL cIsDD := oSoftway:LogicToString(oRow["IsDD"]) AS STRING
				LOCAL cNotNumbered := oSoftway:LogicToString(oRow["NotNumbered"]) AS STRING
				LOCAL Mandatory := oSoftway:LogicToString(oRow["Mandatory"]) AS STRING
				LOCAL cItemName := oRow["ItemName"]:ToString():Trim() AS STRING
				LOCAL iExpandOnColumns := Convert.ToInt32(oRow["ExpandOnColumns"]:ToString()) AS INT
				
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
				LOCAL cOccurs AS STRING[]
				
				IF cItemType == "A"
					IF lTableMode // sunexomenoi pinakes vale ston prohgoumeno to plaisio tou
						oRange := oSheet:Range[oSheet:Cells[iTableStart+1, 2], oSheet:Cells[nRow-1, 1+iCountColumns]]
						oRange:WrapText := TRUE
						oRange:EntireRow:AutoFit()
						oRange:BorderAround( XlLineStyle.xlDouble,XlBorderWeight.xlThick,XlColorIndex.xlColorIndexAutomatic,Color.Black)
						oRange:Borders:LineStyle := XlLineStyle.xlDouble
					ENDIF
					nRow++
					lTableMode := TRUE
					iTableStart := nRow
					cOccurs := cItemTypeValues:Split(';') 
					iCountColumns := cOccurs:Length  
					SELF:addControlToExcel(oSheet,oRow, nRow, nCol, cData, cMemo, TRUE, cMyPackageUID,oDTComboColors)
					nRow++
					LOOP
				ENDIF
				IF lTableMode 
					IF cSLAA == "1"
						SELF:addControlToExcel(oSheet,oRow, nRow, nCol, cData, cMemo, TRUE, cMyPackageUID,oDTComboColors)
						IF iExpandOnColumns>1
							nCol := nCol+iExpandOnColumns
							iCountColumns := iCountColumns-iExpandOnColumns
						ELSE
							nCol++
							iCountColumns--
						ENDIF
						
						IF iCountColumns<=0
							nRow++
							nCol:=2
							iCountColumns:= cOccurs:Length   
						ENDIF
					ELSE
						iTableFinish := nRow
						lTableMode := FALSE
						oRange := oSheet:Range[oSheet:Cells[iTableStart+1, 2], oSheet:Cells[iTableFinish-1, 1+iCountColumns]]
						oRange:WrapText := TRUE
						oRange:EntireRow:AutoFit()
						oRange:BorderAround( XlLineStyle.xlDouble,XlBorderWeight.xlThick,XlColorIndex.xlColorIndexAutomatic,Color.Black)
						oRange:Borders:LineStyle := XlLineStyle.xlDouble
						nRow := nRow + 2
						nCol := 2
						SELF:addControlToExcel(oSheet,oRow, nRow, nCol, cData, cMemo, FALSE, cMyPackageUID,oDTComboColors)
					ENDIF
				ELSE	
					nCol := 2
					SELF:addControlToExcel(oSheet,oRow, nRow, nCol, cData, cMemo, FALSE, cMyPackageUID,oDTComboColors)
					nRow++
				ENDIF
			NEXT
			IF lTableMode
				oRange := oSheet:Range[oSheet:Cells[iTableStart+1, 2], oSheet:Cells[nRow-1, 1+iCountColumns]]
				oRange:WrapText := TRUE
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
		oSheet:PageSetup:FitToPagesTall := FALSE
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
	MessageBox.Show(exc:StackTrace,exc:Message)
	LOOP
END TRY
		
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

METHOD addControlToExcel(oSheet AS Microsoft.Office.Interop.Excel._WorkSheet ,oRowItem AS DataRow,;
						 nRow AS INT, nCol AS INT, cData AS STRING,;
						 cMemo AS STRING, lTable AS LOGIC, cPackageUIDLocal AS STRING, oDTComboColors AS  DataTable) AS VOID
		TRY 

		LOCAL charSpl1 := (CHAR)169 AS CHAR
		LOCAL charSpl2 := (CHAR)168 AS CHAR
		LOCAL oRange AS Microsoft.Office.Interop.Excel.Range
		LOCAL cTextToWrite := "" AS STRING
		LOCAL cItemTypeValues := oRowItem["ItemTypeValues"]:ToString() AS STRING
		LOCAL lEmpty := cPackageUIDLocal=="" AS LOGIC
		LOCAL cMyNameLocal := oRowItem["ItemName"]:ToString() AS STRING
		LOCAL cMyUidLocal := oRowItem["ITEM_UID"]:ToString() AS STRING
		LOCAL cMyItemTypeLocal := oRowItem["ItemType"]:ToString() AS STRING
		LOCAL dDateFrom := DATE{2000,1,1} AS DATE
		LOCAL cStringToCompareComboValue := "", cComboColor:="" AS STRING
		LOCAL iExpandOnColumns := Convert.ToInt32(oRowItem["ExpandOnColumns"]:ToString()) AS INT
		
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
				/*oRange := oSheet:Range[oSheet:Cells[nRow, nCol], oSheet:Cells[nRow, nCol]]
				IF cMyNameLocal:Length<254
					oRange:Validation:Delete()
					oRange:Validation:Add(XlDVType.xlValidateCustom,XlDVAlertStyle.xlValidAlertStop,XlFormatConditionOperator.xlEqual,cMyNameLocal,Type.Missing)
				ENDIF*/
				LOCAL cOccurs := cItemTypeValues:Split(';') AS STRING[]
				LOCAL iCountColumns := cOccurs:Length-1  AS INT
				oRange := oSheet:Range[oSheet:Cells[nRow, nCol], oSheet:Cells[nRow, nCol+iCountColumns]]
				oRange:Merge(NULL)
				oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
				oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
				oRange:EntireRow:RowHeight := 30
				oRange:Font:Size := 14
				oRange:Font:Bold := TRUE
				//oSheet:Range{oSheet:Cells[nRow, nCol], oSheet:Cells][nRow, nCol+4]}
				RETURN
		ELSEIF cMyItemTypeLocal == "F" .AND. !lEmpty	//File Uploader
				LOCAL cStatement := ""  AS STRING
				cStatement :=  "SELECT count(*) as NumberOfAtts FROM FMBlobData Where ITEM_UID="+cMyUidLocal+" AND Package_UID="+cPackageUIDLocal
				LOCAL cNumber := oSoftway:RecordExists(oMainForm:oGFHBlob, oMainForm:oConnBlob, cStatement, "NumberOfAtts") AS STRING
				cData := cNumber + " file(s)"
		ELSEIF cMyItemTypeLocal == "M" 
			IF lEmpty
				IF !lTable
					cMyNameLocal += ": "
					oSheet:Cells[nRow, nCol] := cMyNameLocal
					oRange := oSheet:Range[oSheet:Cells[nRow, nCol], oSheet:Cells[nRow, nCol]]
					IF cMyNameLocal:Length<254
							oRange:Validation:Delete()
							oRange:Validation:Add(XlDVType.xlValidateCustom,XlDVAlertStyle.xlValidAlertStop,XlFormatConditionOperator.xlEqual,cMyNameLocal,Type.Missing)
					ENDIF
					oRange := oSheet:Range[oSheet:Cells[nRow, nCol+1], oSheet:Cells[nRow, nCol+1]]
					oRange:BorderAround( XlLineStyle.xlContinuous,XlBorderWeight.xlThick,XlColorIndex.xlColorIndexAutomatic,Color.Black)
					oRange:Borders:LineStyle := XlLineStyle.xlContinuous
				ELSE	//Eimai se table
					oRange := oSheet:Range[oSheet:Cells[nRow, nCol], oSheet:Cells[nRow, nCol]]
					IF iExpandOnColumns>1
						oRange := oSheet:Range[oSheet:Cells[nRow,nCol], oSheet:Cells[nRow, nCol+iExpandOnColumns-1]]
						oRange:Merge(NULL)
						oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
						oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
					ENDIF
				ENDIF
				LOCAL cRangeName :=  "_UID"+cMyItemTypeLocal+cMyUidLocal AS STRING	
				oRange:Name := cRangeName
				RETURN
			ELSE
				IF cMemo <> "" .AND. cMemo:Contains(CHR(168))
					LOCAL cItems := cMemo:Split(charSpl1) AS STRING[]
					FOREACH cItem AS STRING IN cItems
						TRY
							IF cItem <> NULL .AND. cItem <> ""
									LOCAL cItemsTemp := cItem:Split(charSpl2) AS STRING[]
									IF  cItemsTemp[1] == cMyUidLocal
										 IF !lTable
											oSheet:Cells[nRow, nCol] := cMyNameLocal + " : "+CRLF+ cItemsTemp[2]
											oRange := oSheet:Range[oSheet:Cells[nRow, nCol], oSheet:Cells[nRow, nCol]]
											oRange:WrapText := TRUE
											oRange:EntireRow:AutoFit()
											LOCAL cRangeName :=  "_UID"+cMyItemTypeLocal+cMyUidLocal AS STRING	
											oRange:Name := cRangeName
										 ELSE // An eimai se table
											 oSheet:Cells[nRow, nCol] := cItemsTemp[2]
											IF iExpandOnColumns>1
												oRange := oSheet:Range[oSheet:Cells[nRow,nCol], oSheet:Cells[nRow, nCol+iExpandOnColumns-1]]
												oRange:Merge(NULL)
												oRange:WrapText := TRUE
												oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
												oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
												LOCAL cRangeName :=  "_UID"+cMyItemTypeLocal+cMyUidLocal AS STRING	
												oRange:Name := cRangeName
											ENDIF
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
			IF cMyItemTypeLocal == "X" // Combobox	
				IF oDTComboColors != NULL
					FOREACH oRowTemp AS datarow IN oDTComboColors:Rows
						cStringToCompareComboValue := oRowTemp["TextValue"]:ToString():Trim()
						cComboColor := oRowTemp["ComboColor"]:ToString()
						IF cStringToCompareComboValue:ToUpper() == cData:ToUpper()
							LOCAL nRed, nGreen, nBlue AS LONG
							SELF:SplitColorToRGB(cComboColor, nRed, nGreen, nBlue)
							LOCAL oColor := System.Drawing.Color.FromArgb((BYTE)nRed, (BYTE)nGreen, (BYTE)nBlue) AS System.Drawing.Color
							//oRange:Interior:Color := System.Drawing.ColorTranslator.ToOle(Color.FromArgb(Convert.ToInt32(cComboColor)))
							oRange:Interior:Color := System.Drawing.ColorTranslator.ToOle(oColor)
							EXIT
						ENDIF
					NEXT
				ENDIF
			ENDIF
		ELSE
			IF !lTable
				cMyNameLocal += ": "
				oSheet:Cells[nRow, nCol] := cMyNameLocal
				oRange := oSheet:Range[oSheet:Cells[nRow, nCol], oSheet:Cells[nRow, nCol]]
				IF cMyNameLocal:Length<254
					oRange:Validation:Delete()
					oRange:Validation:Add(XlDVType.xlValidateCustom,XlDVAlertStyle.xlValidAlertStop,XlFormatConditionOperator.xlEqual,cMyNameLocal,Type.Missing)
				ENDIF
				
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
			IF cMyItemTypeLocal == "X" // Combobox	
				cItemTypeValues := SELF:getMyList(cItemTypeValues,oSheet)
				IF cItemTypeValues:Trim():Length>0
					oRange:Validation:Delete()
					oRange:Validation:Add(XlDVType.xlValidateList,XlDVAlertStyle.xlValidAlertStop,XlFormatConditionOperator.xlBetween,SELF:cleanseItemTypeValues(cItemTypeValues),Type.Missing)
					oRange:Validation:IgnoreBlank := TRUE
					oRange:Validation:InCellDropdown := TRUE
				ENDIF
			ELSEIF cMyItemTypeLocal == "D" //Dates
					oRange:Validation:Delete()
					oRange:Validation:Add(XlDVType.xlValidateDate,XlDVAlertStyle.xlValidAlertStop,XlFormatConditionOperator.xlGreater,dDateFrom,Type.Missing)
					oRange:NumberFormat  := "dd-mmm-yy"
					oRange:Validation:InputMessage := "Note: only date values here"
					oRange:Validation:IgnoreBlank := TRUE
			ELSEIF cMyItemTypeLocal == "N" //Numeric
					oRange:Validation:Delete()
					oRange:Validation:Add(XlDVType.xlValidateDecimal,XlDVAlertStyle.xlValidAlertStop,XlFormatConditionOperator.xlGreater,"-1000000",Type.Missing)
					oRange:Validation:InputMessage := "Note: only number values here"
					oRange:Validation:IgnoreBlank := TRUE
			ENDIF
		ENDIF

CATCH exc AS Exception
	MessageBox.Show(exc:StackTrace,exc:Message)
END TRY
			
RETURN

METHOD getMyList(cItemTypeValues AS STRING, oSheet AS Microsoft.Office.Interop.Excel._WorkSheet) AS STRING

	LOCAL cToReturn := cItemTypeValues AS STRING
	IF cItemTypeValues == "Users"
		cToReturn := SELF:GetMyDataForCombo("Username", "Users")
	ELSEIF cItemTypeValues == "Ports"
		cToReturn := SELF:GetMyDataForCombo("Port", "VEPorts")
	ELSEIF cItemTypeValues == "Week"
		cToReturn := cWeekValues
	ELSE
		cToReturn := checkForList(cItemTypeValues)
	ENDIF

RETURN cToReturn

METHOD GetMyDataForCombo(cFieldLocal AS STRING, cTableLocal AS STRING,cWhereClause :="" AS STRING) AS STRING
		LOCAL cToReturn := ""	AS STRING
		LOCAL cStatement  AS STRING

		cStatement := "SELECT DISTINCT "+cFieldLocal+" as cData From "+cTableLocal+" "+cWhereClause+" Order By "+cFieldLocal+" Asc"

		LOCAL oDTLocal := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

		FOREACH oRow AS DataRow IN oDTLocal:Rows
			cToReturn += oRow["cData"]:ToString():Trim() +";"
		NEXT
RETURN cToReturn

METHOD cleanseItemTypeValues(cPreviousValues AS STRING) AS STRING
	cPreviousValues := cPreviousValues:Replace("<D>","") // strip the default value
	LOCAL cToReturnLocal := "" AS STRING
	LOCAL cItems := cPreviousValues:Split(';') AS STRING[]
	FOREACH cItem AS STRING IN cItems
		TRY
			IF cItem <> NULL .AND. cItem <> ""
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

METHOD CategoryExists(cCatUID AS STRING, oDTReportItems AS system.data.DataTable) AS LOGIC
	LOCAL oRows := oDTReportItems:Select("CATEGORY_UID="+cCatUID) AS DataRow[]
RETURN (oRows:Length > 0)

END CLASS