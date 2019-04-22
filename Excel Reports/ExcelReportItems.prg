// ExcelReportItems.prg
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#Using System.IO
#Using System.Diagnostics
#Using Microsoft.Office.Interop.Excel
#USING System.Reflection


PARTIAL CLASS MainForm INHERIT DevExpress.XtraEditors.XtraForm

METHOD ExportItemsToExcelFile() AS VOID
	//IF TRUE
	//	wb("Under construction")
	//	RETURN
	//ENDIF
	LOCAL cStatement, cSqlForSpecificItems := "" AS STRING
	LOCAL cReportUID := SELF:LBCReports:SelectedValue:ToString() AS STRING
	LOCAL cReportName := SELF:LBCReports:GetDisplayItemValue(SELF:LBCReports:SelectedIndex):ToString() AS STRING

	LOCAL cVesselUID := oMainForm:GetVesselUID AS STRING
	IF cVesselUID:StartsWith("Fleet") || cVesselUID =="0"
		wb("Please select a Vessel")
		RETURN
	ENDIF
	LOCAL cVesselName := oMainForm:GetVesselName AS STRING
	//cVesselName := cVesselName

	IF cReportName:ToUpper():StartsWith("MODE")
		wb("You must select a specific report, current selection is: "+cReportName)
		RETURN
	ENDIF
	//wb(cVesselName, cReportName)
	cStatement:="SELECT DISTINCT FMReportItems.ITEM_UID, FMReportItems.ItemNo, FMReportItems.ItemName, FMReportItems.ItemType"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" WHERE FMReportItems.ItemType NOT IN ('A','L') AND FMReportItems.REPORT_UID="+cReportUID+;
				" ORDER BY FMReportItems.ItemNo"
	
	LOCAL oDTFMItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	

	LOCAL oSelectDatesSimpleForm := SelectDatesAdvancedForm{} AS SelectDatesAdvancedForm
	oSelectDatesSimpleForm:DateFrom:DateTime := Datetime.Today
	oSelectDatesSimpleForm:DateTo:DateTime := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.Utc)
	oSelectDatesSimpleForm:oItemsTable := oDTFMItems
	oSelectDatesSimpleForm:cReportUid := cReportUID
	oSelectDatesSimpleForm:cVesselUid := cVesselUID
	oSelectDatesSimpleForm:ShowDialog()
	IF oSelectDatesSimpleForm:DialogResult <> DialogResult.OK
		RETURN
	ENDIF
	IF oSelectDatesSimpleForm:cSqlUids <> ""
		cSqlForSpecificItems := " AND  FMReportItems.ITEM_UID IN"+ oSelectDatesSimpleForm:cSqlUids +" "
		cStatement:="SELECT DISTINCT FMReportItems.ITEM_UID, FMReportItems.ItemNo, FMReportItems.ItemName, FMReportItems.ItemType"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" WHERE FMReportItems.ItemType NOT IN ('A','L') AND FMReportItems.REPORT_UID="+cReportUID+cSqlForSpecificItems+;
				" ORDER BY FMReportItems.ItemNo"
	
		oDTFMItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	ENDIF
	
	LOCAL dStart := oSelectDatesSimpleForm:DateFrom:DateTime AS DateTime
	LOCAL dEnd := oSelectDatesSimpleForm:DateTo:DateTime AS DateTime

	// Select Items
	/*
	cStatement:="SELECT DISTINCT FMReportItems.ITEM_UID, FMReportItems.ItemNo, FMReportItems.ItemName, FMReportItems.ItemType"+;
				" FROM FMData"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
				" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
				" WHERE FMDataPackages.VESSEL_UNIQUEID="+cVesselUID+;
				" AND FMDataPackages.REPORT_UID="+cReportUID+;
				" AND FMDataPackages.DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm")+"'"+;
				" ORDER BY FMReportItems.ItemNo"
	*/
	
	oDTFMItems:TableName := "FMItems"
	//oDTFMItems:WriteXml(cTempdocdir+"\FMItems.XML", XmlWriteMode.WriteSchema, FALSE)

	// Select Dates
	cStatement:="SELECT DISTINCT FMDataPackages.PACKAGE_UID, FMDataPackages.DateTimeGMT"+;
				" FROM FMData"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
				" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
				" WHERE FMDataPackages.VESSEL_UNIQUEID="+cVesselUID+;
				" AND FMDataPackages.REPORT_UID="+cReportUID+;
				" AND FMDataPackages.Visible=1 "+;
				" AND FMDataPackages.DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm")+"'"+;
				" ORDER BY FMDataPackages.DateTimeGMT"
	LOCAL oDTFMDates := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oDTFMDates:TableName := "FMDates"
	//oDTFMDates:WriteXml(cTempdocdir+"\FMDates.XML", XmlWriteMode.WriteSchema, FALSE)

	// Select FMData
	cStatement:="SELECT FMDataPackages.PACKAGE_UID, FMDataPackages.Memo, FMData.ITEM_UID, FMData.Data"+;
				" FROM FMData"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
				" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
				" WHERE FMDataPackages.VESSEL_UNIQUEID="+cVesselUID+;
				" AND FMDataPackages.REPORT_UID="+cReportUID+;
				" AND FMDataPackages.DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm")+"'"	//+;
				//" ORDER BY FMDataPackages.DateTimeGMT"
	LOCAL oDTFMData := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oDTFMData:TableName := "FMData"

	LOCAL oPKs AS DataColumn[]
	oPKs:=DataColumn[]{2}
	oPKs[1]:=oDTFMData:Columns["PACKAGE_UID"]
	oPKs[2]:=oDTFMData:Columns["ITEM_UID"]
	oSoftway:CreatePK(oDTFMData, oPKs)

	IF oDTFMData:Rows:Count == 0
		wb("No Data found for the sepcified period")
		RETURN
	ENDIF

	//oDTFMData:WriteXml(cTempdocdir+"\FMData.XML", XmlWriteMode.WriteSchema, FALSE)
	//memowrit(cTempdocdir+"\st.txt", cStatement)

	SELF:CreateExcelReportItems(cVesselName, oDTFMItems, oDTFMDates, oDTFMData, ".XLSX")
RETURN


METHOD CreateExcelReportItems(cVesselName AS STRING, oDTFMItems AS System.Data.DataTable, oDTFMDates AS System.Data.DataTable, oDTFMData AS System.Data.DataTable, cXLExtension AS STRING) AS VOID
	LOCAL cFile AS STRING
	cFile := cTempDocDir+"\FMData_"+cVesselName:Replace("/", "_")+"_"+Datetime.Now:ToString("dd_MM_yyyy__HH_mm_ss")+cXLExtension	//".XLSX"

	SELF:Cursor := System.Windows.Forms.Cursors.WaitCursor

	LOCAL oldCI AS System.Globalization.CultureInfo
	oldCI:=System.Threading.Thread.CurrentThread:CurrentCulture
	System.Threading.Thread.CurrentThread:CurrentCulture:=System.Globalization.CultureInfo{"en-US"}

	TRY
		LOCAL oXL AS Microsoft.Office.Interop.Excel.Application
		LOCAL oWB AS Microsoft.Office.Interop.Excel._Workbook
		LOCAL oSheet AS Microsoft.Office.Interop.Excel._WorkSheet 
		LOCAL oRangeLocal AS Microsoft.Office.Interop.Excel.Range

		// Start Excel and get Application object. 
		oXL := Microsoft.Office.Interop.Excel.Application{}

		// Set some properties
		oXL:Visible := FALSE
		oXL:DisplayAlerts := FALSE

		// Get a new workbook. 
		oWB := oXL:Workbooks:Add(Missing.Value)

		// Get the active sheet 
		//oSheet := (Microsoft.Office.Interop.Excel._WorkSheet)oWB:ActiveSheet
		oSheet:=(_WorkSheet)oWB:Worksheets[1]
		oSheet:Name := "FMData"

		//wb(oSheet:Rows:CountLarge:ToString(), oSheet:Columns:CountLarge:ToString())

		// Process the DataTable 
		// BE SURE TO CHANGE THIS LINE TO USE *YOUR* DATATABLE 
		//LOCAL dt := Customers.RetrieveAsDataTable() AS DataTable
		//Session["dt"] := dt

		LOCAL nRow, nCol := 2 AS INT
		LOCAL cPackageUID, cItemUID, cData AS STRING
		LOCAL oRows AS DataRow[]
		LOCAL cMemo, cStatement AS STRING
		LOCAL charSpl1 := (char)169 AS Char
		LOCAL charSpl2 := (char)168 AS Char
		LOCAL cItemsArray AS STRING[]
		LOCAL cItemsTemp  AS STRING[]
		LOCAL cStringDateTimeGMT AS STRING
		LOCAL oDateTime as DateTime
		LOCAL lDateSet as LOGIC

		oSheet:Cells[1, 1] := "DateTime of the report."
		//Set The Dates
		nRow := 2
		FOREACH oRowDate AS DataRow IN oDTFMDates:Rows
					oRangeLocal := oSheet:Range[oSheet:Cells[nRow, 1], oSheet:Cells[nRow, 1]]
					oRangeLocal:NumberFormat  := "dd-mmm-yy hh:mm"
					DateTime.TryParse(oRowDate["DateTimeGMT"]:ToString(),oDateTime)
					cStringDateTimeGMT := oDateTime:ToString()
					oSheet:Cells[nRow, 1] := cStringDateTimeGMT
					nRow ++
		next


		FOREACH oRowItem AS DataRow IN oDTFMItems:Rows
			//Messagebox.Show(oRowItem["ItemType"]:ToString())
			IF oRowItem["ItemType"]:ToString() == "L" ||  oRowItem["ItemType"]:ToString() == "A" //Skip tables and labels
				LOOP
			ENDIF
			oSheet:Cells[1, nCol] := oRowItem["ItemName"]:ToString()+" ("+oRowItem["ItemNo"]:ToString()+")"
			cItemUID := oRowItem["ITEM_UID"]:ToString()
			nRow := 2
			lDateSet := false
			FOREACH oRowDate AS DataRow IN oDTFMDates:Rows
				cPackageUID := oRowDate["PACKAGE_UID"]:ToString()
				// Locate FMData
				//MessageBox.Show(oRowItem["ItemType"]:ToString())
				IF  oRowItem["ItemType"]:ToString() == "F"
						//LOCAL doubleQuote := '"' as char
						//cData := "=HYPERLINK("+doubleQuote:ToString()+"../softway.ini"+doubleQuote:ToString()+","+doubleQuote:ToString()+"softway ini"+doubleQuote:ToString()+")" 
						oSheet:Cells[nRow, nCol] := "File(s)"
						nRow++
						LOOP
				ENDIF
				IF oRowItem["ItemType"]:ToString() == "D"
					oRangeLocal := oSheet:Range[oSheet:Cells[nRow, nCol], oSheet:Cells[nRow, nCol]]
					oRangeLocal:Validation:Delete()
					//oRangeLocal:Validation:Add(XlDVType.xlValidateDate,XlDVAlertStyle.xlValidAlertStop,XlFormatConditionOperator.xlGreater,dDateFrom,Type.Missing)
					oRangeLocal:NumberFormat  := "dd-mmm-yy hh:mm"
				ENDIF
				IF  oRowItem["ItemType"]:ToString() == "M"
					TRY
						cStatement:="SELECT Memo FROM FMDataPackages"+oMainForm:cNoLockTerm+;
									" WHERE PACKAGE_UID="+cPackageUID
						cMemo := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Memo")
						//wb(cMemo, "Here")
						IF cMemo <> "" .and. cMemo:Contains(charSpl2)
						//
							cItemsArray := cMemo:Split(charSpl1)
							FOREACH cItem AS STRING IN cItemsArray
								TRY
									IF cItem <> NULL .and. cItem <> ""
										cItemsTemp := cItem:Split(charSpl2)
										IF  cItemUID == cItemsTemp[1] 
											oRangeLocal := oSheet:Range[oSheet:Cells[nRow, nCol], oSheet:Cells[nRow, nCol]]
											cData :=  cItemsTemp[2]
											oSheet:Cells[nRow, nCol] := cData
											oRangeLocal:WrapText := TRUE
											oRangeLocal:EntireRow:AutoFit()
										ENDIF
									ENDIF
								CATCH exc AS Exception
									//MessageBox.Show(exc:ToString(),"Error on Multiline Field Display.")
									//nRow++
									LOOP
								END
							NEXT
						ELSEIF cMemo <> ""
							oSheet:Cells[nRow, nCol] := cMemo
						ENDIF
					CATCH exc AS Exception
							//MessageBox.Show(exc:ToString(),"Error on Multiline Field Display.")
							oSheet:Cells[nRow, nCol] := exc:ToString()
							nRow++
							LOOP
					END
						////////////////////////////////////////////////////////
					nRow++
					LOOP
				ENDIF
				
				oRows := oDTFMData:Select("PACKAGE_UID="+cPackageUID+" AND ITEM_UID="+cItemUID)
				IF oRows:Length <> 1
					//wb("Data not found for PACKAGE_UID="+cPackageUID+" AND ITEM_UID="+cItemUID)
					cData := "No Data"
					oSheet:Cells[nRow, nCol] := cData
					nRow++
					LOOP
				ENDIF
				cData := oRows[1]:Item["Data"]:ToString()
				oSheet:Cells[nRow, nCol] := cData
				nRow++
			NEXT
			nCol++
		NEXT

		//FOREACH oRowDate AS DataRow IN oDTFMDates:Rows
		//	oSheet:Cells[1, nCol] := oRowDate["DateTimeGMT"]:ToString()
		//	cPackageUID := oRowDate["PACKAGE_UID"]:ToString()
		//	nRow := 2
		//	FOREACH oRowItem AS DataRow IN oDTFMItems:Rows
		//		oSheet:Cells[nRow, 1] := oRowItem["ItemNo"]:ToString()+" "+oRowItem["ItemName"]:ToString()
		//		cItemUID := oRowItem["ITEM_UID"]:ToString()
		//		// Locate FMData
		//		oRows := oDTFMData:Select("PACKAGE_UID="+cPackageUID+" AND ITEM_UID="+cItemUID)
		//		IF oRows:Length <> 1
		//			wb("Data not found for PACKAGE_UID="+cPackageUID+" AND ITEM_UID="+cItemUID)
		//			LOOP
		//		ENDIF
		//		cData := oRows[1]:Item["Data"]:ToString()
		//		oSheet:Cells[nRow, nCol] := cData
		//		nRow++
		//	NEXT
		//	nCol++
		//NEXT

		// Titles: BOLD
		oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[1, nCol-1]]:Font:Bold := TRUE
		oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[1, nCol-1]]:Columns:Autofit()
		//oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[nRow-1, 1]]:Font:Bold := TRUE
		

		// Resize the columns
////		oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[nRow-1, nCol-1]]:EntireColumn:AutoFit()
		oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[1, nCol-1]]:EntireColumn:AutoFit()
		// Wrap title text
		//oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[1, nCol-1]]:WrapText  := TRUE

		/*LOCAL rowCount := 1, i, nLastRow AS INT
		IF oDTFMDates:Rows:Count > 256 .and. cXLExtension == ".XLS"
			// Dates in 1st Column A
			FOREACH dr AS DataRow IN oDTFMDates:Rows
				rowCount += 1
				FOR i := 1 UPTO oDTFMDates:Columns:Count
					// Add the header the first time through
					IF rowCount == 2
						oSheet:Cells[1, i] := oDTFMDates:Columns[i - 1]:ColumnName
						// Titles: BOLD
						oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[1, oDTFMDates:Columns:Count]]:Font:Bold := TRUE
					ENDIF
					oSheet:Cells[rowCount, i] := dr[i - 1]:ToString()
				NEXT
				nLastRow++
			NEXT

			// Resize the columns
			oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[rowCount, oDTFMDates:Columns:Count]]:EntireColumn:AutoFit()
		ELSE
			// Items in 1st Column A
			FOREACH dr AS DataRow IN oDTFMItems:Rows
				rowCount += 1
				FOR i := 1 UPTO oDTFMItems:Columns:Count
					// Add the header the first time through
					IF rowCount == 2
						oSheet:Cells[i, 1] := oDTFMItems:Columns[i - 1]:ColumnName
						// Titles: BOLD
						oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[oDTFMItems:Columns:Count, 1]]:Font:Bold := TRUE
					ENDIF
					oSheet:Cells[i, rowCount] := dr[i - 1]:ToString()
				NEXT
				oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[1, rowCount]]:Font:Bold := TRUE
				nLastRow++
			NEXT

			// Resize the columns
			//oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[rowCount, oDTFMItems:Columns:Count]]:EntireColumn:AutoFit()
			oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[oDTFMItems:Columns:Count, rowCount]]:EntireColumn:AutoFit()
		ENDIF*/

		// Freeze 1st Row and 1st Column
		oXL:ActiveWindow:SplitRow := 1
		oXL:ActiveWindow:SplitColumn := 1
		oXL:ActiveWindow:FreezePanes := TRUE

		//oRange := oSheet:get_Range(oSheet.Cells[1, 1], oSheet.Cells[rowCount, oDT.Columns.Count])
		//oRange:EntireColumn:AutoFit()
//wb(oDT:Columns:Count, rowCount)

		// Save the sheet and close
		oSheet := NULL
		//oRange := NULL

		// Microsoft.Office.Interop.Excel.XlFileFormat:
		// XLS: Microsoft.Office.Interop.Excel.XlFileFormat.xlWorkbookNormal (or -4143)
		// XLSX: Microsoft.Office.Interop.Excel.XlFileFormat.xlOpenXMLWorkbook (or 51)
		IF cXLExtension == ".XLS"
			oWB:SaveAs(cFile, Microsoft.Office.Interop.Excel.XlFileFormat.xlWorkbookNormal, Missing.Value, Missing.Value, Missing.Value, Missing.Value, ;
						Microsoft.Office.Interop.Excel.XlSaveAsAccessMode.xlExclusive, Missing.Value, Missing.Value, Missing.Value, Missing.Value, Missing.Value)
		ELSE
			oWB:SaveAs(cFile, Microsoft.Office.Interop.Excel.XlFileFormat.xlOpenXMLWorkbook, Missing.Value, Missing.Value, Missing.Value, Missing.Value, ;
						Microsoft.Office.Interop.Excel.XlSaveAsAccessMode.xlExclusive, Missing.Value, Missing.Value, Missing.Value, Missing.Value, Missing.Value)
		ENDIF

		oWB:Close(Missing.Value, Missing.Value, Missing.Value)
		oWB := NULL
		oXL:Quit()
		// Clean up
		// NOTE: When in release mode, this does the trick
		GC.WaitForPendingFinalizers()
		GC.Collect()
		GC.WaitForPendingFinalizers()
		GC.Collect()

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
	// Protect XLS file
	//Self:ProtectXLSForm(cFile, "Enquiry")
RETURN

END CLASS