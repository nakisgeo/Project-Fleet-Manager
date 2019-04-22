// ReportTabForm.prg
#Using System.IO
#Using System.Data
#Using System.Windows.Forms
#Using System.Data.Common
#Using System.Drawing
#Using System.Collections
#Using System.Diagnostics
#Using System.Collections.Generic
#Using Microsoft.Office.Interop.Excel
#USING System.Reflection

PARTIAL CLASS ReportTabForm INHERIT System.Windows.Forms.Form

METHOD PrintTableToExcelFile(cReportUID AS STRING, cReportName AS STRING,;
							 lEmpty AS LOGIC, cVesselUID AS STRING, cVesselName AS STRING,;
							 cTableUID as String, cPackageUID as String) AS VOID

	LOCAL cStatement :="" AS STRING
	LOCAL cMyPackageUID := cPackageUID  AS STRING
	LOCAL cMyPackageName := "" AS STRING
	LOCAL cMyCategory := "" as String //Tha apothikeuso to Tab pou vrisketai to table mou
	
	IF(!lEmpty)
		cMyPackageUID := oMainForm:TreeListVesselsReports:FocusedNode:Tag:ToString()
		cMyPackageName := oMainForm:TreeListVesselsReports:FocusedNode:GetValue(0):ToString() 
		IF cReportUID:Trim() == "7" .and.  oMainForm:TreeListVesselsReports:Visible == TRUE
			//Find cReportUID by the selected Report
			cReportUID := oMainForm:getReportIUDfromPackage(cMyPackageUID)
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
		// Set some properties
		oXL:Visible := FALSE
		oXL:DisplayAlerts := FALSE
		oWB := oXL:Workbooks:Add(Missing.Value)
		
		LOCAL cData, cMemo :="" AS STRING

		cStatement:="SELECT CATEGORY_UID FROM FMReportItems"+oMainForm:cNoLockTerm+;
								" WHERE FMReportItems.Item_UID="+cTableUID
		cMyCategory := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "CATEGORY_UID")

		cStatement:="SELECT DISTINCT FMItemCategories.CATEGORY_UID, FMItemCategories.Description, FMItemCategories.SortOrder"+;
					" FROM FMItemCategories"+oMainForm:cNoLockTerm+;
					" WHERE FMItemCategories.CATEGORY_UID="+cMyCategory+;
					" ORDER BY FMItemCategories.SortOrder"
		LOCAL oDTItemCategories := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		
		cStatement:="SELECT FMReportItems.*"+;
					" FROM FMReportItems"+oMainForm:cNoLockTerm+;
					" LEFT OUTER JOIN FMItemCategories ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
					" WHERE REPORT_UID="+cReportUID+" AND FMReportItems.CATEGORY_UID="+cMyCategory+;
					" ORDER BY FMItemCategories.SortOrder, ItemNo"
		LOCAL oDTReportItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

		cStatement:="SELECT TOP 1 *  FROM FMReportChangeLog WHERE REPORT_UID="+cReportUID+;
					"ORDER BY LogDateTime DESC"
		LOCAL oDTVersion := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

		LOCAL oDRVersion := NULL as DataRow
		IF oDTVersion:Rows:Count > 0
			oDRVersion := oDTVersion:Rows[0]
		ENDIF

		cStatement:=" SELECT CC_UID, FK_REPORT_UID, TextValue, ComboColor "+;
					" FROM FMComboboxColors Where FK_REPORT_UID IN ("+cReportUID+",0) "+;
					" ORDER BY CC_UID Desc"
		LOCAL oDTComboColors := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		

		LOCAL oDTFMData AS DataTable
		LOCAL oDMLE as DataTable
		
		IF(!lEmpty) // If it is not a printout of an empty form, get the data
			cStatement:="SELECT FMDataPackages.PACKAGE_UID, FMDataPackages.Status, FMData.ITEM_UID, FMData.Data FROM FMData"+oMainForm:cNoLockTerm+;
						" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
						" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID AND FMReportItems.CATEGORY_UID="+cMyCategory+;
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
	LOCAL nRow := 11, nCol := 2, iCountSheets:=0 AS INT
	LOCAL oRange AS Microsoft.Office.Interop.Excel.Range
	LOCAL cCategoryUID AS STRING
	
FOREACH oSheetRow AS DataRow IN oDTItemCategories:Rows
	
	LOCAL cSheetName := "" AS STRING
	LOCAL lTableMode AS LOGIC
	LOCAL oRowsLocal  AS DataRow[]
	LOCAL iMaxColumns :=1 AS INT
	LOCAL cItemTypeValues := "" AS STRING
	//
try
		iCountSheets++
		cCategoryUID := oSheetRow["CATEGORY_UID"]:ToString()
		IF iCountSheets>3
			oWB:Worksheets:Add(Type.Missing, (_WorkSheet)oWB:Worksheets[iCountSheets - 1], Type.Missing, XlSheetType.xlWorksheet) //(object)(nSheets - 1), (object)nSheets, (object)1, Type.Missing)
		ENDIF
		oSheet:=(_WorkSheet)oWB:Worksheets[iCountSheets]
		IF oSheet==NULL
			MessageBox.Show("No other sheet.")
			EXIT
		ENDIF
		cSheetName := ""
		
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
		
		
		lTableMode := false
		nRow := 11 
		nCol := 2 
		
		oRange := oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[1, 2]]
		// Set first column width
		oRange:EntireColumn:ColumnWidth := 5
		//Compute Optimum Column Width
		oRowsLocal := null
			oRowsLocal := oDTReportItems:Select("REPORT_UID="+cReportUID+" AND CATEGORY_UID="+cCategoryUID+" AND ItemType='A' AND Item_UID="+cTableUID , "ItemNo")
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
		oSheet:Cells[6,2]  := cMyPackageName
		oRange := oSheet:Range[oSheet:Cells[6,2], oSheet:Cells[6, 1+iMaxColumns]]
		oRange:Merge(NULL)
		oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
		oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
		oRange:Name := "_ReportUID"+cReportUID
		//Set Approval Status
		//Approved Date and Time
		IF !lEmpty
			LOCAL cApprovedDate, cDateActed:="" as String
			cStatement :=  " SELECT ApprovalData.*, UsersApproval.UserName AS Approver, UsersRequesting.UserName AS Requesting "+;
								 " FROM ApprovalData "+;
								 " Inner Join Users As UsersApproval On UsersApproval.User_Uniqueid=ApprovalData.Receiver_UID "+;
								 " Inner Join Users As UsersRequesting On UsersRequesting.User_Uniqueid=ApprovalData.Creator_Uid "+;
								 " Where "+;
								 " Program_UID=2 AND Foreing_UID="+cMyPackageUID + " Order By ApprovalData.Appoval_UID Desc "
			LOCAL oDTLocal := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			IF oDTLocal != NULL && oDTLocal:Rows:Count > 0
				LOCAL cApprovedUserName := oDTLocal:Rows[0]:Item["Approver"]:ToString():Trim()
				cDateActed := oDTLocal:Rows[0]:Item["Date_Acted"]:ToString():Trim()
				LOCAL cFrom_State := oDTLocal:Rows[0]:Item["From_State"]:ToString():Trim()
				LOCAL cTo_State := oDTLocal:Rows[0]:Item["To_State"]:ToString():Trim()
				IF oDTLocal:Rows:Count == 1 .and. cFrom_State == "0" .and. cTo_State == "1" //Exei ginei request gia approval alla den exei egkrithei
					nRow--
				ELSE
					IF oDTLocal:Rows:Count == 1 .and. cFrom_State == "0" .and. cTo_State == "2" .and. cDateActed =="" 
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
			/*IF  SELF:LBCReportsOffice:Visible// is Office Form
				oSheet:Cells[nRow-3,2]  := SELF:BBSIStatus:Caption + ", printed on "+Datetime.Now:ToString("dd/MM/yyyy  HH:mm:ss")
			ELSE*/
				oSheet:Cells[nRow-3,2]  := "Printed on "+Datetime.Now:ToString("dd/MM/yyyy  HH:mm:ss")
			//ENDIF
		ENDIF
		oRange := oSheet:Range[oSheet:Cells[nRow-3,2], oSheet:Cells[nRow-3, 1+iMaxColumns]]
		oRange:Merge(NULL)
		oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
		oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
		//Set Report Status
		/*IF (!lEmpty)
				oSheet:Cells[6,2]  := "Printed on "+Datetime.Now:ToString("dd/MM/yyyy  HH:mm:ss")
		ENDIF
		oRange := oSheet:Range[oSheet:Cells[6,2], oSheet:Cells[6, 1+iMaxColumns]]
		oRange:Merge(NULL)
		oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
		oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter*/
		//Set Sheet Name on Header
		oSheet:Cells[nRow-2,2]  := "Section : "+oSheetRow["Description"]:ToString()
		oRange := oSheet:Range[oSheet:Cells[nRow-2,2], oSheet:Cells[nRow-2, 1+iMaxColumns]]
		oRange:Merge(NULL)
		oRange:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
		oRange:VerticalAlignment := Microsoft.Office.Interop.Excel.XlVAlign.xlVAlignCenter
		
		//
		
			//Get all items of the sheet	
			//LOCAL oRows := oDTReportItems:Select("REPORT_UID="+cReportUID+" AND CATEGORY_UID="+cCategoryUID, "ItemNo") AS DataRow[]
			LOCAL iTableStart, iTableFinish AS INT
			LOCAL iCountColumns   AS INT
			FOREACH oRow AS DataRow IN oDTReportItems:Rows
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

				//Kane skip ola ta items mexri na ftaseis ston pinaka
				IF cItemUID!=cTableUID && !lTableMode
					LOOP
				ENDIF
				//Eftases ston Epomeno Pinaka stamata
				IF cItemUID!=cTableUID && lTableMode && cItemType == "A"
					oRange := oSheet:Range[oSheet:Cells[iTableStart+1, 2], oSheet:Cells[nRow-1, 1+iCountColumns]]
					oRange:WrapText := TRUE
					oRange:EntireRow:AutoFit()
					oRange:BorderAround( XlLineStyle.xlDouble,XlBorderWeight.xlThick,XlColorIndex.xlColorIndexAutomatic,Color.Black)
					oRange:Borders:LineStyle := XlLineStyle.xlDouble
					EXIT
				ENDIF

				IF !lEmpty
					LOCAL oRowData := oDTFMData:Select("ITEM_UID="+cItemUID, "Data") AS DataRow[]
					IF oRowData:Length > 0
						LOCAL oOneRowData := oRowData[1] AS DataRow
						cData := oOneRowData["Data"]:ToString()
					ENDIF
				ELSE
					cData := ""
				ENDIF
			
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
					oMainForm:addControlToExcel(oSheet,oRow, nRow, nCol, cData, cMemo, TRUE, cMyPackageUID,oDTComboColors)
					nRow++
					LOOP
				ENDIF
				IF lTableMode 
					IF cSLAA == "1"
						oMainForm:addControlToExcel(oSheet,oRow, nRow, nCol, cData, cMemo, TRUE, cMyPackageUID,oDTComboColors)
						IF iExpandOnColumns>1
							nCol := nCol+iExpandOnColumns
							iCountColumns := iCountColumns-iExpandOnColumns
						ELSE
							nCol++
							iCountColumns--
						ENDIF

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
						oMainForm:addControlToExcel(oSheet,oRow, nRow, nCol, cData, cMemo, false, cMyPackageUID,oDTComboColors)
					ENDIF
				ELSE	
					nCol := 2
					oMainForm:addControlToExcel(oSheet,oRow, nRow, nCol, cData, cMemo, FALSE, cMyPackageUID,oDTComboColors)
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
			
		oRange := oSheet:Range[oSheet:Cells[9, 2], oSheet:Cells[nRow-1, 1+iMaxColumns]]
		oRange:EntireColumn:AutoFit()
		lTableMode := FALSE
		oSheet:PageSetup:Zoom := FALSE
		oSheet:PageSetup:FitToPagesWide := 1
		oSheet:PageSetup:FitToPagesTall := false
		oSheet:PageSetup:PaperSize := Microsoft.Office.Interop.Excel.XlPaperSize.xlPaperA4
		
		
CATCH exc AS Exception
	MessageBox.Show(exc:Source,exc:Message)
	LOOP
END TRY
		
NEXT
	
		IF !lEmpty
			SELF:checkForMultiline(oSheet, oWB, oRange)
		ENDIF

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
			oProcessInfo:WindowStyle := ProcessWindowStyle.Maximized
			Process.Start(oProcessInfo)
		CATCH e AS Exception
			ErrorBox(e:StackTrace,e:Message)
		END TRY

		
CATCH e AS Exception
		ErrorBox(e:StackTrace, "OleDB Excel connection error")
		RETURN
FINALLY
		System.Threading.Thread.CurrentThread:CurrentCulture:=oldCI
		SELF:Cursor := System.Windows.Forms.Cursors.Default
END TRY

RETURN


METHOD checkForMultiline(oSheet AS Microsoft.Office.Interop.Excel._WorkSheet, oWB AS Microsoft.Office.Interop.Excel._Workbook, ;
						oR AS Microsoft.Office.Interop.Excel.Range) AS VOID

try
	LOCAL oRange, oCell AS Microsoft.Office.Interop.Excel.Range
	LOCAL cNameName, cName1, cRangeValue AS STRING
	LOCAL cReportUidLocal, cItemUIDLocal, cItemTypeLocal as String
	local cMultiLineValues := "" as String

	FOREACH name  AS Microsoft.Office.Interop.Excel.Name IN oWB:Names
		cNameName := name:Value //Place in Excel
		cName1 := name:Name     //Name 
		
		IF cName1:Contains("_UID")
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
			
			//Multiline Field
			IF cItemTypeLocal == "M"
				LOCAL mergeCells := oRange:MergeCells AS OBJECT
				IF (logic)mergeCells == TRUE
					//MessageBox.Show("I found a merged textbox : "+cName1)
					//MessageBox.Show("Initial Height : "+oRange:RowHeight:ToString())
					LOCAL iTotalWidth := 0  AS Double
					FOREACH oSubRange AS Microsoft.Office.Interop.Excel.Range IN oRange
						oSubRange:WrapText := TRUE
						iTotalWidth := iTotalWidth + Convert.ToDouble(oSubRange:ColumnWidth)
					NEXT
					//MessageBox.Show(iTotalWidth:ToString())
					oRange:MergeCells := FALSE
					oCell := (Microsoft.Office.Interop.Excel.Range)oRange:Cells[1,1]
					LOCAL iFirstWidth := oCell:ColumnWidth AS OBJECT
					//MessageBox.Show(iFirstWidth:ToString())
					oCell:ColumnWidth := iTotalWidth
					oRange:EntireRow:AutoFit()
					LOCAL iRangeHeight := oRange:RowHeight as Object
					oCell:ColumnWidth := iFirstWidth
					oRange:MergeCells := TRUE
					oRange:RowHeight := iRangeHeight
					//MessageBox.Show(iRangeHeight:ToString())
				ENDIF
			ENDIF
		ENDIF
	NEXT
CATCH e AS Exception
		ErrorBox(e:StackTrace, e:Message)
		RETURN
end try

RETURN

END CLASS