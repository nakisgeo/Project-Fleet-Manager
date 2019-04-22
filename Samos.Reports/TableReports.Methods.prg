// TableReports.prg
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#using System.Drawing.Printing
#Using System.IO
#Using System.Collections
#USING System.Threading
#USING System.Collections.Generic
#using System.ComponentModel
#Using Microsoft.Office.Interop.Excel
#USING System.Reflection
#Using System.Diagnostics
#USING System.Web.Script.Serialization

PARTIAL CLASS TableReportsSelectionForm INHERIT System.Windows.Forms.Form
	EXPORT cMyReportUID, cReportName, cVesselName, cVesselUID AS STRING
	EXPORT aObjects, aUIDtoCheck AS ArrayList
	EXPORT oDTPackages AS DataTable
	EXPORT cTempDocDir AS STRING
	EXPORT lisSEReport as LOGIC
	EXPORT cLinesUIDForAllTables   AS STRING[]
	PRIVATE lSumsCreated AS LOGIC
	EXPORT oMyMainForm AS MainForm
	PRIVATE lRegistered := TRUE AS LOGIC

PRIVATE METHOD myOnLoad() AS VOID
	SELF:aObjects := ArrayList{}
	SELF:aUIDtoCheck := ArrayList{}
	
	self:LoadMyListView()
	self:LoadVesselsListView()	


	SELF:DateFrom:DateTime := DateTime.Now:AddYears(-1)
	SELF:DateTo:DateTime := DateTime.Now
	txtReport_UID:Text := cMyReportUID

	labelRole:Visible := lisSEReport
	cmbRole:Visible := lisSEReport
	btnSEReport:Visible := lisSEReport

	btnReport:Visible := !lisSEReport
	//cmbStatus:Visilbe := !lisSEReport
	//labelToCheck:Visible := !lisSEReport

RETURN

PRIVATE METHOD LoadVesselsListView() AS VOID
	LOCAL cStatement:="SELECT VESSELS.VESSEL_UNIQUEID, VESSELS.VesselName, EconFleet.Description FROM VESSELS"+;
				" INNER JOIN SupVessels ON SupVessels.VESSEL_UNIQUEID=VESSELS.VESSEL_UNIQUEID"+;
				" LEFT OUTER JOIN EconFleet ON EconFleet.FLEET_UID=SupVessels.FLEET_UID"+;
				" WHERE VESSELS.VESSEL_UNIQUEID IN"+;
				" (Select Distinct VESSEL_UNIQUEID From FMReportTypesVessel Where REPORT_UID="+cMyReportUID+")"+;
				" ORDER BY EconFleet.Description, VESSELS.VesselName ASC " AS STRING
				
	LOCAL oDTReportItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	SELF:lvVessels:Items:Clear()
	LOCAL oListViewItem AS ListViewItem
	FOREACH iRow AS DataRow IN oDTReportItems:Rows
		oListViewItem := ListViewItem{iRow["VesselName"]:ToString()}
		oListViewItem:SubItems:Add(iRow["Description"]:ToString())
		oListViewItem:Tag := iRow["VESSEL_UNIQUEID"]:ToString()
		oListViewItem:Checked := true
		SELF:lvVessels:Items:Add(oListViewItem)
	NEXT
RETURN

PRIVATE METHOD LoadMyListView() AS VOID
	LOCAL cStatement:="SELECT FMReportItems.* FROM FMReportItems"+;
				" LEFT OUTER JOIN FMItemCategories ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
				" WHERE FMReportItems.REPORT_UID="+cMyReportUID+;
				" AND FMReportItems.ItemType='A' "+;
				" ORDER BY FMItemCategories.SortOrder, ItemNo" AS STRING
				
	LOCAL oDTReportItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	SELF:ItemsListView:Items:Clear()
	LOCAL cItemTypeValues := "", cColumnName:="", cTable_UID AS STRING
	LOCAL oListViewItem as ListViewItem
	local iGroupCount :=0 as int
	FOREACH iRow AS DataRow IN oDTReportItems:Rows
					
		ItemsListView:Groups:Add(System.Windows.Forms.ListViewGroup{iRow["ItemName"]:ToString()})
		cItemTypeValues := iRow["ItemTypeValues"]:ToString()
		cTable_UID :=  iRow["ITEM_UID"]:ToString()
		LOCAL cColumnNames, cItems := cItemTypeValues:Split(';') AS STRING[]
		LOCAL iColumnInt := 1 as INT
		FOREACH cItem AS STRING IN cItems
			cColumnNames := cItem:Split(':')
			cColumnName := cColumnNames[1]
			oListViewItem := ListViewItem{cColumnName}
			oListViewItem:SubItems:Add(cTable_UID)
			oListViewItem:SubItems:Add("")
			oListViewItem:SubItems:Add(iColumnInt:ToString())
			oListViewItem:Group := SELF:ItemsListView:Groups[iGroupCount]
			SELF:ItemsListView:Items:Add(oListViewItem)
			iColumnInt++
		NEXT
		iGroupCount ++
	NEXT
RETURN

PRIVATE METHOD changedMyIndex() AS VOID
		IF (ItemsListView:SelectedItems:Count == 1)
			SELF:txtValue:Text := ItemsListView:SelectedItems[0]:SubItems[2]:Text
		ENDIF
RETURN

PRIVATE METHOD writtingOnTextView() AS VOID
        IF (ItemsListView:SelectedItems:Count > 0)
			FOREACH oListViewItem AS ListViewItem IN ItemsListView:SelectedItems
				oListViewItem:SubItems[2]:Text := self:txtValue:Text
			
            //listView1.SelectedItems[0].SubItems[1].Text = txt_sender.Text
			next
        endif
RETURN

PRIVATE METHOD btnReport_Clicked() AS VOID

	txtProgress:Text :=""

	LOCAL cFieldNameToCheckLocal := self:txtFieldNameToCheck:Text AS STRING
	//LOCAL cReportsToCheckSQLLocal := " Report_UID in (1029) " as String

	IF SELF:DateFrom:DateTime > SELF:DateTo:DateTime
			wb("Invalid dates")
			SELF:DateTo:Focus()
			RETURN
	ENDIF
	local cStatement as String
	
	LOCAL cValue := ""
	aObjects:Clear()
	aUIDtoCheck:Clear()
	LOCAL iCountObjLocal := 1 AS INT

	FOREACH oListViewItem AS ListViewItem IN ItemsListView:Items
		cValue := oListViewItem:Text 
		IF STRING.IsNullOrEmpty(cValue)
			LOOP
		ENDIF
		IF cValue == cFieldNameToCheckLocal
			oListViewItem:SubItems[2]:Text := cmbStatus:Text
		ENDIF
	NEXT

	txtProgress:Text := DateTime.Now:ToString("HH:mm:ss")+ ": Started.." + CRLF + txtProgress:Text
	System.Windows.Forms.Application.DoEvents()

	 cValue := ""
	//mazevo sto objectToCheck ola ta UID ton items pou prepei na elenkso mazi me ta table uids tous
	FOREACH oListViewItem AS ListViewItem IN ItemsListView:Items
		cValue := oListViewItem:SubItems[2]:Text
		IF STRING.IsNullOrEmpty(cValue)
			LOOP
		ENDIF
		LOCAL oTemp := objectToCheck{} AS objectToCheck
		oTemp:cTableUID := oListViewItem:SubItems[1]:Text
		oTemp:cColumnIndex := oListViewItem:SubItems[3]:Text
		oTemp:cValue := cValue
		oTemp:cColumnName := oListViewItem:Text
		oTemp:iId := iCountObjLocal
		aObjects:Add(oTemp)
		iCountObjLocal++
		cValue := ""
	NEXT
	
	txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": aObjects Created..." + CRLF + txtProgress:Text + txtProgress:Text
	System.Windows.Forms.Application.DoEvents()

	IF aObjects == NULL || aObjects:Count<1
		MessageBox.Show("Nothing To check.")
		RETURN
	ENDIF
	
	
	LOCAL dStart := self:DateFrom:DateTime AS DateTime
	LOCAL dEnd := self:DateTo:DateTime AS DateTime

	//Load the Report Items
	cStatement:="SELECT FMReportItems.*"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" LEFT OUTER JOIN FMItemCategories ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
				" WHERE Report_UID="+cMyReportUID+;
				" ORDER BY FMItemCategories.SortOrder, ItemNo"
				
	LOCAL oDTReportItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

	txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": FMReportItems Loaded..." + CRLF + txtProgress:Text
	System.Windows.Forms.Application.DoEvents()

	LOCAL cTable_UID,cItemType:="", cInsideType:="" AS STRING
	LOCAL iCount, iCountRows := oDTReportItems:Rows:Count, iInsideCount, iInsideTableCount AS INT
	LOCAL iIndexToCheckLocal AS INT
	LOCAL cIsSLAA AS STRING
	LOCAL cReportItemsUIDToCheck := "" as String
	LOCAL oRow, oRowInside AS DataRow
	LOCAL iNumberOfTableColumns AS INT
	LOCAL cItemTypeValues, cNameLocal AS STRING
	LOCAL cLineUIDS:="",cTempUid_Local:="",cTempNameLocal:="" AS STRING
	LOCAL lLineToAdd := false as LOGIC
	
	LOCAL cColumnNames, cItems,cColumnsLocal  AS STRING[]
	
	FOR iCount := 0 UPTO iCountRows-1 STEP 1
		oRow := oDTReportItems:Rows[iCount]
		cTable_UID :=  oRow["ITEM_UID"]:ToString()
		cItemType :=  oRow["ItemType"]:ToString()
		cNameLocal :=  oRow["ItemName"]:ToString()
		IF cItemType=="A"
			// Vrisko poses kolones exei o pinakas
			cItemTypeValues := oRow["ItemTypeValues"]:ToString()
			cColumnsLocal := cItemTypeValues:Split(';')
			iNumberOfTableColumns := cColumnsLocal:Length
			FOREACH oTempObj AS objectToCheck IN SELF:aObjects
				//LOCAL json :=  JavaScriptSerializer{}:Serialize(oTempObj):ToString() as String
				//Console.WriteLine(json)
				cIsSLAA := "True"
				IF oTempObj:cTableUID==cTable_UID
					//Vrisko poia kolona psaxnw
					iIndexToCheckLocal := (int)INT64.Parse(oTempObj:cColumnIndex)
					//Arxikopoiw se ena ton metrhth ths seiras
					iInsideCount := 1
					cLineUIDS := ""
					iInsideTableCount := iCount + 1
					WHILE cIsSLAA != "False" .and. iInsideTableCount<iCountRows
						// An o arithmos kolonas einia idios me auton pou psaxnw
						oRowInside :=  oDTReportItems:Rows[iInsideTableCount]
						cInsideType := oRowInside["ItemType"]:ToString()
						IF cLineUIDS ==""
							cLineUIDS := oRowInside["ITEM_UID"]:ToString()
						ELSE
							cLineUIDS += "," + oRowInside["ITEM_UID"]:ToString()
						ENDIF
						
						cIsSLAA := oRowInside["SLAA"]:ToString()
						IF cIsSLAA == "False"
							LOOP
						ENDIF
						LOCAL oUIDtoCheckForValue := UIDtoCheckForValue{}  AS UIDtoCheckForValue 
						IF iIndexToCheckLocal == iInsideCount .and. cInsideType!="L"
							//Prosethese ena antikeimeno me UID kai value sto array
							//oUIDtoCheckForValue:cValue := oTempObj:cValue
							//oUIDtoCheckForValue:iObjectId := oTempObj:iId
							cTempUid_Local := oRowInside["ITEM_UID"]:ToString()
							//oUIDtoCheckForValue:cTableName := cNameLocal
							cTempNameLocal := oRowInside["ItemName"]:ToString()
							lLineToAdd := true
						ENDIF
						cIsSLAA := oRowInside["SLAA"]:ToString()
						iInsideTableCount++
						iInsideCount++
						IF iInsideCount> iNumberOfTableColumns // Changing Line
							IF lLineToAdd
								oUIDtoCheckForValue:cValue := oTempObj:cValue
								oUIDtoCheckForValue:iObjectId := oTempObj:iId
								oUIDtoCheckForValue:cUID := cTempUid_Local
								oUIDtoCheckForValue:cTableName := cNameLocal
								oUIDtoCheckForValue:cName := cTempNameLocal
								oUIDtoCheckForValue:cMyLineUIDs := cLineUIDS
								oUIDtoCheckForValue:cTableUID := cTable_UID
								aUIDtoCheck:Add(oUIDtoCheckForValue)
							ENDIF
							iInsideCount:=1
							cLineUIDS := ""
							cTempNameLocal:=""
							cTempUid_Local:=""
							lLineToAdd := false
						ENDIF
					ENDDO
				ENDIF
			NEXT
		ENDIF
	NEXT
	
	txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": aUIDtoCheck Created..." + CRLF + txtProgress:Text
	System.Windows.Forms.Application.DoEvents()

	IF aUIDtoCheck == NULL || aUIDtoCheck:Count<1
		MessageBox.Show("Nothing To check.")
		RETURN
	ENDIF
	
	LOCAL lAllVesselsLocal := TRUE, lHasSelectedVessels := FALSE AS LOGIC

	SELF:cVesselUID:=""
	
	FOREACH olvItemTemp AS ListViewItem IN SELF:lvVessels:Items
		IF olvItemTemp:Checked
			lHasSelectedVessels := TRUE
			IF SELF:cVesselUID ==""
				SELF:cVesselUID += olvItemTemp:Tag:ToString()
			ELSE
				SELF:cVesselUID += ","+ olvItemTemp:Tag:ToString()
			ENDIF
		ELSE
			lAllVesselsLocal := FALSE
		ENDIF
	NEXT
	
	IF !lHasSelectedVessels
		MessageBox.Show("No vessel selected To check.")
		RETURN
	ENDIF
	/*IF self:ckbAllVessels:Checked
		lAllVesselsLocal := true
	ENDIF*/

	//IF SELF:ckbIncludeStatistics:Checked
	//	SELF:createExcel("",dStart,dEnd, lAllVesselsLocal)
	//ELSE
		SELF:createExcelVertical("",dStart,dEnd, lAllVesselsLocal)
	//ENDIF
RETURN

PRIVATE METHOD myOkPressed() AS VOID
	IF SELF:DateFrom:DateTime > SELF:DateTo:DateTime
			wb("Invalid dates")
			SELF:DateTo:Focus()
			RETURN
	ENDIF
	local cStatement as String
	
	LOCAL cValue := ""
	aObjects:Clear()
	aUIDtoCheck:Clear()
	LOCAL iCountObjLocal := 1 as INT
	FOREACH oListViewItem AS ListViewItem IN ItemsListView:Items
		cValue := oListViewItem:SubItems[2]:Text
		IF STRING.IsNullOrEmpty(cValue)
			LOOP
		ENDIF
		LOCAL oTemp := objectToCheck{} AS objectToCheck
		oTemp:cTableUID := oListViewItem:SubItems[1]:Text
		oTemp:cColumnIndex := oListViewItem:SubItems[3]:Text
		oTemp:cValue := cValue
		oTemp:cColumnName := oListViewItem:Text
		oTemp:iId := iCountObjLocal
		aObjects:Add(oTemp)
		iCountObjLocal++
		cValue := ""
	NEXT
	
	IF aObjects == NULL || aObjects:Count<1
		MessageBox.Show("Nothing To check.")
		RETURN
	ENDIF
	
	
	LOCAL dStart := self:DateFrom:DateTime AS DateTime
	LOCAL dEnd := self:DateTo:DateTime AS DateTime

	//Load the Report Items
	cStatement:="SELECT FMReportItems.*"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" LEFT OUTER JOIN FMItemCategories ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
				" WHERE REPORT_UID="+cMyReportUID+;
				" ORDER BY FMItemCategories.SortOrder, ItemNo"
				
	LOCAL oDTReportItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	LOCAL cTable_UID,cItemType:="", cInsideType:="" AS STRING
	LOCAL iCount, iCountRows := oDTReportItems:Rows:Count, iInsideCount, iInsideTableCount AS INT
	LOCAL iIndexToCheckLocal AS INT
	LOCAL cIsSLAA AS STRING
	LOCAL cReportItemsUIDToCheck := "" as String
	LOCAL oRow, oRowInside AS DataRow
	LOCAL iNumberOfTableColumns AS INT
	LOCAL cItemTypeValues, cNameLocal AS STRING
	LOCAL cLineUIDS:="",cTempUid_Local:="",cTempNameLocal:="" AS STRING
	LOCAL lLineToAdd := false as LOGIC
	
	LOCAL cColumnNames, cItems,cColumnsLocal  AS STRING[]
	
	FOR iCount := 0 UPTO iCountRows-1 STEP 1
		oRow := oDTReportItems:Rows[iCount]
		cTable_UID :=  oRow["ITEM_UID"]:ToString()
		cItemType :=  oRow["ItemType"]:ToString()
		cNameLocal :=  oRow["ItemName"]:ToString()
		IF cItemType=="A"
			// Vrisko poses kolones exei o pinakas
			cItemTypeValues := oRow["ItemTypeValues"]:ToString()
			cColumnsLocal := cItemTypeValues:Split(';')
			iNumberOfTableColumns := cColumnsLocal:Length
			FOREACH oTempObj AS objectToCheck IN SELF:aObjects
				LOCAL json :=  JavaScriptSerializer{}:Serialize(oTempObj):ToString() as String
				Console.WriteLine(json)
				cIsSLAA := "True"
				IF oTempObj:cTableUID==cTable_UID
					//Vrisko poia kolona psaxnw
					iIndexToCheckLocal := (int)INT64.Parse(oTempObj:cColumnIndex)
					//Arxikopoiw se ena ton metrhth ths seiras
					iInsideCount := 1
					cLineUIDS := ""
					iInsideTableCount := iCount + 1
					WHILE cIsSLAA != "False" .and. iInsideTableCount<iCountRows
						// An o arithmos kolonas einia idios me auton pou psaxnw
						oRowInside :=  oDTReportItems:Rows[iInsideTableCount]
						cInsideType := oRowInside["ItemType"]:ToString()
						IF cLineUIDS ==""
							cLineUIDS := oRowInside["ITEM_UID"]:ToString()
						ELSE
							cLineUIDS += "," + oRowInside["ITEM_UID"]:ToString()
						ENDIF
						
						cIsSLAA := oRowInside["SLAA"]:ToString()
						IF cIsSLAA == "False"
							LOOP
						ENDIF
						LOCAL oUIDtoCheckForValue := UIDtoCheckForValue{}  AS UIDtoCheckForValue 
						IF iIndexToCheckLocal == iInsideCount .and. cInsideType!="L"
							//Prosethese ena antikeimeno me UID kai value sto array
							//oUIDtoCheckForValue:cValue := oTempObj:cValue
							//oUIDtoCheckForValue:iObjectId := oTempObj:iId
							cTempUid_Local := oRowInside["ITEM_UID"]:ToString()
							//oUIDtoCheckForValue:cTableName := cNameLocal
							cTempNameLocal := oRowInside["ItemName"]:ToString()
							lLineToAdd := true
						ENDIF
						cIsSLAA := oRowInside["SLAA"]:ToString()
						iInsideTableCount++
						iInsideCount++
						IF iInsideCount> iNumberOfTableColumns // Changing Line
							IF lLineToAdd
								oUIDtoCheckForValue:cValue := oTempObj:cValue
								oUIDtoCheckForValue:iObjectId := oTempObj:iId
								oUIDtoCheckForValue:cUID := cTempUid_Local
								oUIDtoCheckForValue:cTableName := cNameLocal
								oUIDtoCheckForValue:cName := cTempNameLocal
								oUIDtoCheckForValue:cMyLineUIDs := cLineUIDS
								oUIDtoCheckForValue:cTableUID := cTable_UID
								aUIDtoCheck:Add(oUIDtoCheckForValue)
							ENDIF
							iInsideCount:=1
							cLineUIDS := ""
							cTempNameLocal:=""
							cTempUid_Local:=""
							lLineToAdd := false
						ENDIF
					ENDDO
				ENDIF
			NEXT
		ENDIF
	NEXT
	
	IF aUIDtoCheck == NULL || aUIDtoCheck:Count<1
		MessageBox.Show("Nothing To check.")
		RETURN
	ENDIF
	
	IF SELF:ckbIncludeStatistics:Checked // always false
		SELF:createExcel("",dStart,dEnd)
	ELSE
		SELF:createExcelVertical("",dStart,dEnd)
	ENDIF
	

RETURN

PRIVATE METHOD createExcel(cReportItemsUIDToCheck AS STRING, dStart AS Datetime, dEnd AS DateTime, lAllVessels := false as LOGIC) as void
	LOCAL lIncludeStatistics as LOGIC
	IF SELF:ckbIncludeStatistics:Checked
		lIncludeStatistics := true
	ENDIF

	LOCAL cExtraStatusStatement := "" AS STRING
	IF SELF:ckbShowOnlySubmittedReports:Checked
		cExtraStatusStatement := " And FMDataPackages.Status > 0 "
	ENDIF
		
	LOCAL cStatement as String
	cStatement:="SELECT FMDataPackages.PACKAGE_UID, DateTimeGMT, GmtDiff"+;
				" FROM FMDataPackages"+;
				" WHERE FMDataPackages.DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
				" AND VESSEL_UNIQUEID In ("+SELF:cVesselUID+")"+;
				" AND  FMDataPackages.Visible=1 AND FMDataPackages.REPORT_UID="+SELF:cMyReportUID+;
				cExtraStatusStatement+;
				" ORDER BY DateTimeGMT Desc" 
				//" WHERE TDate BETWEEN '"+cStart+"' AND '"+cEnd+"'"+;
	SELF:oDTPackages := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	
	/*cStatement:="SELECT FMDataPackages.PACKAGE_UID, FMDataPackages.Memo, FMData.ITEM_UID, FMData.Data, FMReportItems.ItemType"+;
				" FROM FMData"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
				" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
				" WHERE FMDataPackages.VESSEL_UNIQUEID="+self:cVesselUID+;
				" AND FMDataPackages.REPORT_UID="+SELF:cMyReportUID+;
				" AND FMDataPackages.Visible=1 "+;
				" AND FMReportItems.ITEM_UID In ("+cReportItemsUIDToCheck+") "+;
				" AND FMDataPackages.DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm")+"'"	//+;
				//" ORDER BY FMDataPackages.DateTimeGMT"
	LOCAL oDTFMData := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oDTFMData:TableName := "FMData"*/

	
	
	lOCAL cFile AS STRING
	cFile := cTempDocDir+"\FMData_"+self:cVesselName:Replace("/", "_")+"_"+Datetime.Now:ToString("dd_MM_yyyy__HH_mm_ss")+".xlsx"	//".XLSX"

	SELF:Cursor := System.Windows.Forms.Cursors.WaitCursor

	LOCAL oldCI AS System.Globalization.CultureInfo
	oldCI:=System.Threading.Thread.CurrentThread:CurrentCulture
	System.Threading.Thread.CurrentThread:CurrentCulture:=System.Globalization.CultureInfo{"en-US"}

	TRY
		LOCAL oXL AS Microsoft.Office.Interop.Excel.Application
		LOCAL oWB AS Microsoft.Office.Interop.Excel._Workbook
		LOCAL oSheet AS Microsoft.Office.Interop.Excel._WorkSheet 
		LOCAL oRangeLocal AS Microsoft.Office.Interop.Excel.Range
		LOCAL oRange AS Microsoft.Office.Interop.Excel.Range

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
		LOCAL cMemo AS STRING
		LOCAL charSpl1 := (char)169 AS Char
		LOCAL charSpl2 := (char)168 AS Char
		LOCAL cItemsArray AS STRING[]
		LOCAL cItemsTemp  AS STRING[]
		LOCAL cStringDateTimeGMT AS STRING
		LOCAL oDateTime as DateTime
		LOCAL lDateSet as LOGIC
		cLinesUIDForAllTables := String[]{oDTPackages:Rows:Count} 

		oSheet:Cells[1, 1] := "DateTime of the report."
		//Set The Dates
		/*nRow := 2
		FOREACH oRowDate AS DataRow IN oDTPackages:Rows
					oRangeLocal := oSheet:Range[oSheet:Cells[nRow, 1], oSheet:Cells[nRow, 1]]
					oRangeLocal:NumberFormat  := "dd-mmm-yy hh:mm"
					DateTime.TryParse(oRowDate["DateTimeGMT"]:ToString(),oDateTime)
					cStringDateTimeGMT := oDateTime:ToString()
					oSheet:Cells[nRow, 1] := cStringDateTimeGMT
					nRow ++
		NEXT*/
		nRow :=2
		
		// Ftiaxnw mia kolona 
		LOCAL cTableName, cColumnName, cPACKAGE_UIDLocal as String
		LOCAL oDTFMData := DataTable{} AS DataTable
		LOCAL iCountOccurences:=0 AS INT
		LOCAL cRangeName AS STRING
		LOCAL cLinesUIDsLocal := "" AS STRING
		LOCAL doubleQuote := '"' AS char
		LOCAL iCountRowsInTable := 0 AS INT
		LOCAL cCellDataLocal :="" as String
		
		FOREACH oTempObject AS objectToCheck IN SELF:aObjects
			cStatement:="SELECT ItemName FROM FMReportItems"+oMainForm:cNoLockTerm+;
					" WHERE ITEM_UID="+oTempObject:cTableUID
			cTableName := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "ItemName")
			cColumnName :=  oTempObject:cValue+" contained in Table : "+cTableName+" in Column :"+oTempObject:cColumnName
			oSheet:Cells[1, nCol] := cColumnName
			nRow:=2
			cReportItemsUIDToCheck :=""
			FOREACH oRowDate AS DataRow IN oDTPackages:Rows
				
				cPACKAGE_UIDLocal := oRowDate["PACKAGE_UID"]:ToString()
				iCountOccurences:=0
				
				FOREACH oTempUIDLocal AS UIDtoCheckForValue IN SELF:aUIDtoCheck
					IF oTempUIDLocal:iObjectId == oTempObject:iId
						/*	IF cReportItemsUIDToCheck==""
								cReportItemsUIDToCheck := oTempUIDLocal:cUID
							ELSE
								cReportItemsUIDToCheck += ", " + oTempUIDLocal:cUID
							ENDIF*/
				
			
						cStatement:="SELECT FMDataPackages.PACKAGE_UID, FMDataPackages.Memo, FMData.ITEM_UID, FMData.Data, FMReportItems.ItemType"+;
							" FROM FMData"+oMainForm:cNoLockTerm+;
							" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
							" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
							" WHERE FMDataPackages.VESSEL_UNIQUEID="+self:cVesselUID+;
							" AND FMDataPackages.REPORT_UID="+SELF:cMyReportUID+;
							" AND FMDataPackages.Visible=1 AND FMDataPackages.PACKAGE_UID="+cPACKAGE_UIDLocal+;
							" AND FMReportItems.ITEM_UID = "+oTempUIDLocal:cUID
							//" AND FMReportItems.ITEM_UID In ("+cReportItemsUIDToCheck+") "
							//" AND FMDataPackages.DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm")+"'"	//+;
							//" ORDER BY FMDataPackages.DateTimeGMT"
						oDTFMData:Clear()	
						oDTFMData := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
						oDTFMData:TableName := "FMData"
				
						FOREACH oRowDataTemp AS DataRow IN oDTFMData:Rows
							IF oRowDataTemp["Data"]:ToString():Contains(oTempObject:cValue)
								iCountOccurences++
								IF cLinesUIDsLocal == ""
									cLinesUIDsLocal := oTempUIDLocal:cMyLineUIDs
								ELSE
									cLinesUIDsLocal += "," + oTempUIDLocal:cMyLineUIDs
								ENDIF
							ENDIF
						NEXT
						iCountRowsInTable++
					endif
				NEXT
				
				IF cLinesUIDsLocal != ""
					cLinesUIDsLocal += "," + oTempObject:cTableUID
				ENDIF
				
				oRange := oSheet:Range[oSheet:Cells[nRow, nCol], oSheet:Cells[nRow, nCol]]
				//cRangeName :=  "_UIDs"+cLinesUIDsLocal
				//oRange:Name := cRangeName
				//oSheet:Cells[nRow, nCol] := "=HYPERLINK("+doubleQuote:ToString()+"_UIDs"+cLinesUIDsLocal+doubleQuote:ToString()+","+doubleQuote:ToString()+iCountOccurences:ToString()+doubleQuote:ToString()+")" 
				//oSheet:Cells[nRow, nCol] := iCountOccurences:ToString()
				IF lIncludeStatistics 				
					cCellDataLocal := iCountOccurences:ToString()+" of "+iCountRowsInTable:ToString()
				ELSE
					cCellDataLocal := iCountOccurences:ToString()
				ENDIF
				//oSheet:Cells[nRow, nCol] := "=HYPERLINK("+doubleQuote:ToString()+"_UIDs="+cLinesUIDsLocal+doubleQuote:ToString()+","+cCellDataLocal+")" 
				/*IF cLinesUIDsLocal:Length>248
					cLinesUIDsLocal := cLinesUIDsLocal:Substring(0,259)
				ENDIF*/
				oRange:Hyperlinks:Add(oSheet:Cells[nRow, nCol],"_UIDs="+cLinesUIDsLocal,"","",cCellDataLocal)

				IF  cLinesUIDForAllTables[nRow-1]==NULL .or. cLinesUIDForAllTables[nRow-1]==""
					cLinesUIDForAllTables[nRow-1]:="_UIDs="+cLinesUIDsLocal
				ELSE
					cLinesUIDForAllTables[nRow-1]+= ","+cLinesUIDsLocal
				ENDIF
				cLinesUIDsLocal := "" 
				nRow++
				iCountRowsInTable := 0
			NEXT
			
			nCol++
		NEXT
		
		nRow := 2
		FOREACH oRowDate AS DataRow IN oDTPackages:Rows
					DateTime.TryParse(oRowDate["DateTimeGMT"]:ToString(),oDateTime)
					System.Threading.Thread.CurrentThread:CurrentCulture:=System.Globalization.CultureInfo{"en-GB"}
					cStringDateTimeGMT := oDateTime:ToString()
					//oSheet:Cells[nRow, 1] := "=HYPERLINK("+doubleQuote:ToString()+cLinesUIDForAllTables[nRow-1]+doubleQuote:ToString()+","+doubleQuote:ToString()+cStringDateTimeGMT+doubleQuote:ToString()+")"
					oRange := oSheet:Range[oSheet:Cells[nRow, 1], oSheet:Cells[nRow, 1]]
					LOCAL iLength := cLinesUIDForAllTables[nRow-1]:Length AS INT
					IF iLength>1000
						cLinesUIDForAllTables[nRow-1] := cLinesUIDForAllTables[nRow-1]:Substring(0,999)
					ENDIF
					oRange:Hyperlinks:Add(oSheet:Cells[nRow, 1],cLinesUIDForAllTables[nRow-1],"","",cStringDateTimeGMT)
					nRow ++
		NEXT
		
		//LOCAL oRangeLocal AS Microsoft.Office.Interop.Excel.Range
		oRangeLocal := oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[nRow, nCol]]
		oRangeLocal:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
		//local oStyle as Microsoft.Office.Interop.Excel.Style 
		
		oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[1, nCol-1]]:Font:Bold := TRUE
		oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[1, nCol-1]]:Columns:Autofit()
		oXL:ActiveWindow:SplitRow := 1
		oXL:ActiveWindow:SplitColumn := 1
		oXL:ActiveWindow:FreezePanes := TRUE
		oSheet := NULL
		
		oWB:SaveAs(cFile, Microsoft.Office.Interop.Excel.XlFileFormat.xlOpenXMLWorkbook, Missing.Value, Missing.Value, Missing.Value, Missing.Value, ;
						Microsoft.Office.Interop.Excel.XlSaveAsAccessMode.xlExclusive, Missing.Value, Missing.Value, Missing.Value, Missing.Value, Missing.Value)
	
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
		
		
		CATCH exc AS Exception
			MessageBox.Show(exc:Message)
		FINALLY
			System.Threading.Thread.CurrentThread:CurrentCulture:=oldCI
			SELF:Cursor := System.Windows.Forms.Cursors.Default
		END TRY
	

RETURN

PRIVATE METHOD createExcelVertical(cReportItemsUIDToCheck AS STRING, dStart AS Datetime, dEnd AS DateTime, lAllVessels := false as LOGIC) as void
	LOCAL lIncludeStatistics, lExcel AS LOGIC
	LOCAL lExactMatch := TRUE AS LOGIC
	LOCAL nDataStartOnColumn := 5 AS INT
		
	IF SELf:ckbExcel:Checked
		lExcel := TRUE
	ENDIF

	IF SELF:ckbIncludeStatistics:Checked
		lIncludeStatistics := true
	ENDIF

	LOCAL cExtraStatusStatement := "" AS STRING
	IF SELF:ckbShowOnlySubmittedReports:Checked
		cExtraStatusStatement := " And FMDataPackages.Status > 0 "
	ENDIF
		
	txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": Starting Excel Creation..." + CRLF + txtProgress:Text
	System.Windows.Forms.Application.DoEvents()

	LOCAL cStatement AS STRING
	IF(!lAllVessels)

		cStatement:="SELECT FMDataPackages.PACKAGE_UID, DateTimeGMT, GmtDiff, Username, Vessels.VesselName"+;
					" FROM FMDataPackages"+;
					" Inner Join Vessels on FMDataPackages.VESSEL_UNIQUEID = Vessels.VESSEL_UNIQUEID "+;
					" WHERE FMDataPackages.DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
					" AND FMDataPackages.VESSEL_UNIQUEID In ("+SELF:cVesselUID+")"+;
					" AND  FMDataPackages.Visible=1 AND FMDataPackages.REPORT_UID="+SELF:cMyReportUID+;
					cExtraStatusStatement+;
					" ORDER BY DateTimeGMT Desc" 
					//" WHERE TDate BETWEEN '"+cStart+"' AND '"+cEnd+"'"+;
	ELSE
		cStatement:="SELECT FMDataPackages.PACKAGE_UID, FMDataPackages.DateTimeGMT, FMDataPackages.GmtDiff, "+;
					" Vessels.VesselName, FMDataPackages.Username "+;
					" FROM FMDataPackages"+;
					" Inner Join Vessels on FMDataPackages.VESSEL_UNIQUEID = Vessels.VESSEL_UNIQUEID "+;
					" WHERE FMDataPackages.DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
					" AND  FMDataPackages.Visible=1 AND FMDataPackages.REPORT_UID="+SELF:cMyReportUID+;
					cExtraStatusStatement+;
					" ORDER BY FMDataPackages.DateTimeGMT Desc" 
	ENDIF

	SELF:oDTPackages := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	IF SELF:oDTPackages == NULL || SELF:oDTPackages:Rows:Count == 0
		MessageBox.Show("No Data found for these days !")
		RETURN
	ENDIF	
	txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": "+SELF:oDTPackages:Rows:Count:ToString()+" Reports Found..." + CRLF + txtProgress:Text
	System.Windows.Forms.Application.DoEvents()

	/*cStatement:="SELECT FMDataPackages.PACKAGE_UID, FMDataPackages.Memo, FMData.ITEM_UID, FMData.Data, FMReportItems.ItemType"+;
				" FROM FMData"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
				" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
				" WHERE FMDataPackages.VESSEL_UNIQUEID="+self:cVesselUID+;
				" AND FMDataPackages.REPORT_UID="+SELF:cMyReportUID+;
				" AND FMDataPackages.Visible=1 "+;
				" AND FMReportItems.ITEM_UID In ("+cReportItemsUIDToCheck+") "+;
				" AND FMDataPackages.DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm")+"'"	//+;
				//" ORDER BY FMDataPackages.DateTimeGMT"
	LOCAL oDTFMData := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oDTFMData:TableName := "FMData"*/
	LOCAL dsLocal := DataSet{} AS DataSet
	LOCAL oDTFMDataLocal := DataTable{} AS DataTable
	oDTFMDataLocal:TableName := "Data"
    oDTFMDataLocal:Columns:Add("1", typeof(STRING))
    oDTFMDataLocal:Columns:Add("2", typeof(STRING))
    oDTFMDataLocal:Columns:Add("3", typeof(STRING))
    oDTFMDataLocal:Columns:Add("4", typeof(STRING))
    oDTFMDataLocal:Columns:Add("5", typeof(STRING))
	
	lOCAL cFile AS STRING
	cFile := cTempDocDir+"\FMData_"+Datetime.Now:ToString("dd_MM_yyyy__HH_mm_ss")+".xlsx"	//".XLSX"

	SELF:Cursor := System.Windows.Forms.Cursors.WaitCursor

	LOCAL oldCI AS System.Globalization.CultureInfo
	oldCI:=System.Threading.Thread.CurrentThread:CurrentCulture
	IF lExcel
		System.Threading.Thread.CurrentThread:CurrentCulture:=System.Globalization.CultureInfo{"en-GB"}
	ELSE
		System.Threading.Thread.CurrentThread:CurrentCulture:=System.Globalization.CultureInfo{"en-GB"}
	ENDIF
	TRY
		LOCAL oXL AS Microsoft.Office.Interop.Excel.Application
		LOCAL oWB AS Microsoft.Office.Interop.Excel._Workbook
		LOCAL oSheet AS Microsoft.Office.Interop.Excel._WorkSheet 
		LOCAL oRangeLocal AS Microsoft.Office.Interop.Excel.Range
		LOCAL oRange AS Microsoft.Office.Interop.Excel.Range
		IF lExcel
		// Start Excel and get Application object. 
			oXL := Microsoft.Office.Interop.Excel.Application{}

			oXL:Visible := FALSE
			oXL:DisplayAlerts := FALSE

			oWB := oXL:Workbooks:Add(Missing.Value)

			oSheet:=(_WorkSheet)oWB:Worksheets[1]
			oSheet:Name := "FMData"
			oSheet:Cells[1, 1] := ""
		ENDIF
		

		LOCAL nRow :=2, nCol := nDataStartOnColumn AS INT
		LOCAL cPackageUID, cItemUID, cData AS STRING
		LOCAL oRows AS DataRow[]
		LOCAL cMemo AS STRING
		LOCAL charSpl1 := (char)169 AS Char
		LOCAL charSpl2 := (char)168 AS Char
		LOCAL cItemsArray AS STRING[]
		LOCAL cItemsTemp  AS STRING[]
		LOCAL cStringDateTimeGMT AS STRING
		LOCAL oDateTime as DateTime
		LOCAL lDateSet as LOGIC

		// Ftiaxnw mia kolona 
		LOCAL cTableName, cColumnName, cPACKAGE_UIDLocal, cSectionName as String
		LOCAL oDTFMData := DataTable{} AS DataTable
		LOCAL iCountOccurences:=0, iCountOccurencesInRow :=0,iCount AS INT
		LOCAL cRangeName AS STRING
		LOCAL cLinesUIDsLocal := "" AS STRING
		LOCAL doubleQuote := '"' AS char
		LOCAL iCountRowsInTable := 0 AS INT
		LOCAL cCellDataLocal :="", cSecondCellDataLocal :="" AS STRING
		LOCAL iPrct AS INT
		LOCAL cPrct AS STRING
		LOCAL rFindingsPerInspection AS FLOAT
		LOCAL oDTFItemNameDescription := DataTable{} AS DataTable 
		cLinesUIDForAllTables := String[]{aObjects:Count} 
		
		FOREACH oTempObject AS objectToCheck IN SELF:aObjects

			Local newCustomersRow := oDTFMDataLocal:NewRow() as DataRow
			cStatement:="SELECT FMReportItems.ItemName, FMItemCategories.Description "+;
					" FROM FMReportItems "+oMainForm:cNoLockTerm+;
					" Inner Join FMItemCategories on FMItemCategories.CATEGORY_UID = FMReportItems.CATEGORY_UID "+;
					" WHERE ITEM_UID="+oTempObject:cTableUID
			//cTableName := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "ItemName")
			//cSectionName := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Description")
			oDTFItemNameDescription :=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
			cTableName := oDTFItemNameDescription:Rows[0]:Item["ItemName"]:ToString()
			cSectionName := oDTFItemNameDescription:Rows[0]:Item["Description"]:ToString()
			//cColumnName :=  oTempObject:cValue+" contained in Table : "+cTableName+" in Column :"+oTempObject:cColumnName
			cColumnName := cSectionName+ " - "+cTableName
			
			txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": Starting Checking for "+cColumnName + CRLF + txtProgress:Text
			System.Windows.Forms.Application.DoEvents()

			nCol:=nDataStartOnColumn
			cReportItemsUIDToCheck :=""
			FOREACH oRowDate AS DataRow IN oDTPackages:Rows
				iCountRowsInTable := 0
				cPACKAGE_UIDLocal := oRowDate["PACKAGE_UID"]:ToString()
				iCountOccurences:=0
				
				FOREACH oTempUIDLocal AS UIDtoCheckForValue IN SELF:aUIDtoCheck
					IF oTempUIDLocal:iObjectId == oTempObject:iId
			
						cStatement:="SELECT  FMData.ITEM_UID, "+;
							" FMData.Data "+;
							" FROM FMData"+oMainForm:cNoLockTerm+;
							" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
							" WHERE FMDataPackages.PACKAGE_UID="+cPACKAGE_UIDLocal+;
							" AND FMData.ITEM_UID = "+oTempUIDLocal:cUID

						oDTFMData:Clear()	
						oDTFMData := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
						oDTFMData:TableName := "FMData"
						LOCAL lCompare as LOGIC
						FOREACH oRowDataTemp AS DataRow IN oDTFMData:Rows
							IF lExactMatch
								IF oRowDataTemp["Data"]:ToString():Trim():Equals(oTempObject:cValue)
									lCompare := TRUE
								ELSE
									lCompare := FALSE
								ENDIF
							ELSE
								IF oRowDataTemp["Data"]:ToString():Contains(oTempObject:cValue)
									lCompare := TRUE
								ELSE
									lCompare := FALSE
								ENDIF
							ENDIF

							IF lCompare
								iCountOccurences++
								IF cLinesUIDsLocal == ""
									cLinesUIDsLocal := cPACKAGE_UIDLocal+":"+oTempUIDLocal:cMyLineUIDs
								ELSE
									cLinesUIDsLocal += "-" + cPACKAGE_UIDLocal+":"+ oTempUIDLocal:cMyLineUIDs
								ENDIF
							ENDIF
						NEXT
						iCountRowsInTable++
					ENDIF
					System.Windows.Forms.Application.DoEvents()
				NEXT
								
				IF lIncludeStatistics 				
					cCellDataLocal := iCountOccurences:ToString()+" of "+iCountRowsInTable:ToString()
				ELSE
					cCellDataLocal := iCountOccurences:ToString()
				ENDIF	
				if lExcel	
					oSheet:Cells[nRow, nCol] := cCellDataLocal
				ENDIF
				nCol++
				iCountOccurencesInRow += iCountOccurences
			NEXT
			IF lExcel
				oSheet:Cells[nRow, 1] := cColumnName 
			ENDIF
			newCustomersRow["1"] := cColumnName
			iPrct := ((iCountOccurencesInRow*100)/(iCountRowsInTable*oDTPackages:Rows:Count))
			cPrct := iPrct:ToString()
			IF lIncludeStatistics
				cSecondCellDataLocal :=  iCountOccurencesInRow:ToString() +" of "+(iCountRowsInTable*oDTPackages:Rows:Count):ToString()+" ("+cPrct+"%)"
			ELSE
				cSecondCellDataLocal := iCountOccurencesInRow:ToString() 
			ENDIF
			IF lExcel
				oSheet:Cells[nRow, 2] := cSecondCellDataLocal
			ENDIF
			newCustomersRow["2"] := cSecondCellDataLocal
		
			rFindingsPerInspection := (FLOAT)iCountOccurencesInRow/(FLOAT)oDTPackages:Rows:Count
			IF lExcel
				oSheet:Cells[nRow, 3] := rFindingsPerInspection:ToString("0.00")
			ENDIF
			newCustomersRow["3"] := rFindingsPerInspection:ToString("0.00")
			iCountOccurencesInRow := 0
			nRow++
			oDTFMDataLocal:Rows:Add(newCustomersRow)
			txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": Finished Checking for "+cColumnName + CRLF + txtProgress:Text
			System.Windows.Forms.Application.DoEvents()

			IF  cLinesUIDForAllTables[nRow-2]==NULL .or. cLinesUIDForAllTables[nRow-2]==""
					cLinesUIDForAllTables[nRow-2]:= cLinesUIDsLocal
					newCustomersRow["5"] := cLinesUIDsLocal
			ENDIF
		   cLinesUIDsLocal := "" 
		NEXT
		
		txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": Starting Statistics... " + CRLF + txtProgress:Text
		System.Windows.Forms.Application.DoEvents()
		IF lExcel
			//2nd Column		
			oSheet:Cells[1, 2] := "Findings in "+oDTPackages:Rows:Count:ToString()+" Inspection(s)"
			oRange := oSheet:Range[oSheet:Cells[nRow,2], oSheet:Cells[nRow,2]]
			oRange:Formula := STRING.Format("=SUM(B2:B{0})", nRow-1)
			oRange:Font:Bold := TRUE
			//3rd Column
			oSheet:Cells[1, 3] := "Findings per Inspection"
			oRange := oSheet:Range[oSheet:Cells[nRow,3], oSheet:Cells[nRow,3]]
			oRange:Formula := STRING.Format("=B{0}/{1}", nRow,oDTPackages:Rows:Count)
			oRange:NumberFormat := "0.00"
			oRange:Font:Bold := TRUE
			//4rth Column
			oSheet:Cells[1, 4] := "% out of Total Findings"
		ENDIF
		LOCAL cRowOccurences, cTotalOccurences AS STRING
		LOCAL fRowOccurences := 0 AS Decimal
		local fTotalOccurences := 0 as Decimal
		IF lExcel
			oRangeLocal := oSheet:Range[oSheet:Cells[nRow, 2],oSheet:Cells[nRow, 2]]
			cTotalOccurences := oRangeLocal:Value2:ToString()
			fTotalOccurences := Decimal.Parse(cTotalOccurences)
		
			FOR iCount := 2 UPTO nRow-1 STEP 1
					oRangeLocal := oSheet:Range[oSheet:Cells[iCount, 2],oSheet:Cells[iCount, 2]]
					IF oRangeLocal:Value2 == NULL
						loop
					ENDIF
					cRowOccurences := oRangeLocal:Value2:ToString()
					IF cRowOccurences == ""
						LOOP
					ENDIF
					fRowOccurences := Decimal.Parse(cRowOccurences)
					oSheet:Cells[iCount, 4] := ((Decimal)(fRowOccurences/fTotalOccurences)*(Decimal)100):ToString("0.00")
					local oDataRowTemp :=  oDTFMDataLocal:Rows[iCount-2] AS DataRow 
					oDataRowTemp["4"] := ((Decimal)(fRowOccurences/fTotalOccurences)*(Decimal)100):ToString("0.00")
					oDataRowTemp:AcceptChanges()
					oDTFMDataLocal:AcceptChanges()
			NEXT
		ELSE
			FOREACH oDataRowTemp AS DataRow IN oDTFMDataLocal:Rows
					cTotalOccurences := oDataRowTemp["2"]:ToString()
					fTotalOccurences += Decimal.Parse(cTotalOccurences)
			NEXT
			FOREACH oDataRowTemp AS DataRow IN oDTFMDataLocal:Rows
				cRowOccurences := oDataRowTemp["2"]:ToString()
				fRowOccurences := Decimal.Parse(cRowOccurences)
				oDataRowTemp["4"] := ((Decimal)(fRowOccurences/fTotalOccurences)*(Decimal)100):ToString("0.00")
				oDataRowTemp:AcceptChanges()
				oDTFMDataLocal:AcceptChanges()
			NEXT
		ENDIF

		 dsLocal:Tables:Add(oDTFMDataLocal)
		 SELF:gcResults:DataSource := dsLocal
         SELF:gcResults:DataMember := "Data"
		 SELF:gcResults:ForceInitialize()
		 SELF:gvResults:Columns[4]:Visible := false
		 SELF:gvResults:Columns[0]:Caption := "Categories"
		 SELF:gvResults:Columns[1]:Caption := "Findings in "+oDTPackages:Rows:Count:ToString()+" Inspection(s)"
		 SELF:gvResults:Columns[1]:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		 SELF:gvResults:Columns[2]:Caption := "Findings per Inspection"
		 SELF:gvResults:Columns[2]:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		 SELF:gvResults:Columns[3]:Caption := "% out of Total Findings"
		 SELF:gvResults:Columns[3]:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
         SELF:gvResults:OptionsView:ShowFooter := TRUE
		 //IF !lSumsCreated
			 SELF:gvResults:Columns[1]:Summary:Add(DevExpress.Data.SummaryItemType.Sum, "", "{0} Findings")
		     SELF:gvResults:Columns[2]:Summary:Add(DevExpress.Data.SummaryItemType.Sum, "", "{0}")
		 //	 lSumsCreated := TRUE
			 SELF:gvResults:Appearance:FooterPanel:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
			 SELF:gvResults:Appearance:FooterPanel:Options:UseTextOptions := TRUE
		 //ENDIF
		 SELF:gvResults:BestFitColumns()
		// Date Row
		nCol := nDataStartOnColumn
		System.Threading.Thread.CurrentThread:CurrentCulture:=System.Globalization.CultureInfo{"en-GB"}
		IF lExcel
			FOREACH oRowDate AS DataRow IN oDTPackages:Rows
						DateTime.TryParse(oRowDate["DateTimeGMT"]:ToString(),oDateTime)
						cStringDateTimeGMT := oDateTime:ToString("dd/MM/yyyy")
						oSheet:Cells[1,nCol] := oRowDate["Username"]:ToString() +" for "+ oRowDate["VesselName"]:ToString() +" on "+ cStringDateTimeGMT
						nCol ++
			NEXT
		
			txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": Starting Sums... " + CRLF + txtProgress:Text
			System.Windows.Forms.Application.DoEvents()

			// Statistics
			nCol := nDataStartOnColumn
			LOCAL cTempLocal, cCountOccurencesInColumn,cTotalOccurencesInColumn AS STRING
			LOCAL  iCountOccurencesInColumn:=0, iTotalOccurencesInColumn:=0 as INT
			FOREACH oRowDate AS DataRow IN oDTPackages:Rows
				FOR iCount := 2 UPTO nRow-1 STEP 1
					oRangeLocal := oSheet:Range[oSheet:Cells[iCount, nCol],oSheet:Cells[iCount, nCol]]
					IF oRangeLocal:Value2 == NULL
						loop
					ENDIF
					cTempLocal := oRangeLocal:Value2:ToString()
					IF cTempLocal==""
						LOOP
					ENDIF
					IF lIncludeStatistics
						cCountOccurencesInColumn := cTempLocal:Substring(0,cTempLocal:IndexOf(' '))
						cTotalOccurencesInColumn := cTempLocal:Substring(cTempLocal:IndexOf("of ")+3)
						iCountOccurencesInColumn += Int32.Parse(cCountOccurencesInColumn)
						iTotalOccurencesInColumn += Int32.Parse(cTotalOccurencesInColumn)
					ELSE
						cCountOccurencesInColumn := cTempLocal
						iCountOccurencesInColumn += Int32.Parse(cCountOccurencesInColumn)
					endif
				NEXT
				IF lIncludeStatistics
					oSheet:Cells[nRow,nCol] := iCountOccurencesInColumn:ToString() + " of " + iTotalOccurencesInColumn:ToString()
				ELSE
					oSheet:Cells[nRow,nCol] := iCountOccurencesInColumn:ToString()
				ENDIF
				oRangeLocal := oSheet:Range[oSheet:Cells[nRow, nCol], oSheet:Cells[nRow, nCol]]
				oRangeLocal:Font:Bold := TRUE
				nCol ++
				iCountOccurencesInColumn := 0
				iTotalOccurencesInColumn := 0
			NEXT

			//LOCAL oRangeLocal AS Microsoft.Office.Interop.Excel.Range
			oRangeLocal := oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[nRow, nCol]]
			oRangeLocal:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
			//local oStyle as Microsoft.Office.Interop.Excel.Style 
		
			oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[1, nCol-1]]:Font:Bold := TRUE
			oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[nRow, 1]]:Font:Bold := TRUE
			oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[nRow, 1]]:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignLeft
			oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[nRow-1, nCol-1]]:Columns:Autofit()
			oXL:ActiveWindow:SplitRow := 1
			oXL:ActiveWindow:SplitColumn := nDataStartOnColumn-1
			oXL:ActiveWindow:FreezePanes := TRUE
			oSheet := NULL
		
			oWB:SaveAs(cFile, Microsoft.Office.Interop.Excel.XlFileFormat.xlOpenXMLWorkbook, Missing.Value, Missing.Value, Missing.Value, Missing.Value, ;
							Microsoft.Office.Interop.Excel.XlSaveAsAccessMode.xlExclusive, Missing.Value, Missing.Value, Missing.Value, Missing.Value, Missing.Value)
	
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
				ErrorBox(e:StackTrace,e:Message)
			END TRY
		ENDIF
		
		CATCH exc AS Exception
			MessageBox.Show(exc:StackTrace, exc:Message)
		FINALLY
			System.Threading.Thread.CurrentThread:CurrentCulture:=oldCI
			SELF:Cursor := System.Windows.Forms.Cursors.Default
		END TRY
	

RETURN

PRIVATE METHOD btnReportPerSE_Clicked() AS VOID

	txtProgress:Text :=""

	LOCAL cFieldNameToCheckLocal := self:txtFieldNameToCheck:Text AS STRING
	//LOCAL cReportsToCheckSQLLocal := " Report_UID in (1029) " as String

	IF SELF:DateFrom:DateTime > SELF:DateTo:DateTime
			wb("Invalid dates")
			SELF:DateTo:Focus()
			RETURN
	ENDIF
	local cStatement as String
	
	LOCAL cValue := ""
	aObjects:Clear()
	aUIDtoCheck:Clear()
	LOCAL iCountObjLocal := 1 AS INT

	FOREACH oListViewItem AS ListViewItem IN ItemsListView:Items
		cValue := oListViewItem:Text 
		IF STRING.IsNullOrEmpty(cValue)
			LOOP
		ENDIF
		IF cValue == cFieldNameToCheckLocal
			oListViewItem:SubItems[2]:Text := cmbStatus:Text
		ENDIF
	NEXT

	txtProgress:Text := DateTime.Now:ToString("HH:mm:ss")+ ": Started.." + CRLF + txtProgress:Text
	System.Windows.Forms.Application.DoEvents()

	cValue := ""
	FOREACH oListViewItem AS ListViewItem IN ItemsListView:Items
		cValue := oListViewItem:SubItems[2]:Text
		IF STRING.IsNullOrEmpty(cValue)
			LOOP
		ENDIF
		LOCAL oTemp := objectToCheck{} AS objectToCheck
		oTemp:cTableUID := oListViewItem:SubItems[1]:Text
		oTemp:cColumnIndex := oListViewItem:SubItems[3]:Text
		oTemp:cValue := cValue
		oTemp:cColumnName := oListViewItem:Text
		oTemp:iId := iCountObjLocal
		aObjects:Add(oTemp)
		iCountObjLocal++
		cValue := ""
	NEXT
	
	txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": aObjects Created..." + CRLF + txtProgress:Text + txtProgress:Text
	System.Windows.Forms.Application.DoEvents()

	IF aObjects == NULL || aObjects:Count<1
		MessageBox.Show("Nothing To check.")
		RETURN
	ENDIF
	
	
	LOCAL dStart := self:DateFrom:DateTime AS DateTime
	LOCAL dEnd := self:DateTo:DateTime AS DateTime

	//Load the Report Items
	cStatement:="SELECT FMReportItems.*"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" LEFT OUTER JOIN FMItemCategories ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
				" WHERE Report_UID="+cMyReportUID+;
				" ORDER BY FMItemCategories.SortOrder, ItemNo"
				
	LOCAL oDTReportItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

	txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": FMReportItems Loaded..." + CRLF + txtProgress:Text
	System.Windows.Forms.Application.DoEvents()

	LOCAL cTable_UID,cItemType:="", cInsideType:="" AS STRING
	LOCAL iCount, iCountRows := oDTReportItems:Rows:Count, iInsideCount, iInsideTableCount AS INT
	LOCAL iIndexToCheckLocal AS INT
	LOCAL cIsSLAA AS STRING
	LOCAL cReportItemsUIDToCheck := "" as String
	LOCAL oRow, oRowInside AS DataRow
	LOCAL iNumberOfTableColumns AS INT
	LOCAL cItemTypeValues, cNameLocal AS STRING
	LOCAL cLineUIDS:="",cTempUid_Local:="",cTempNameLocal:="" AS STRING
	LOCAL lLineToAdd := false as LOGIC
	
	LOCAL cColumnNames, cItems,cColumnsLocal  AS STRING[]
	
	FOR iCount := 0 UPTO iCountRows-1 STEP 1
		oRow := oDTReportItems:Rows[iCount]
		cTable_UID :=  oRow["ITEM_UID"]:ToString()
		cItemType :=  oRow["ItemType"]:ToString()
		cNameLocal :=  oRow["ItemName"]:ToString()
		IF cItemType=="A"
			// Vrisko poses kolones exei o pinakas
			cItemTypeValues := oRow["ItemTypeValues"]:ToString()
			cColumnsLocal := cItemTypeValues:Split(';')
			iNumberOfTableColumns := cColumnsLocal:Length
			FOREACH oTempObj AS objectToCheck IN SELF:aObjects
				//LOCAL json :=  JavaScriptSerializer{}:Serialize(oTempObj):ToString() as String
				//Console.WriteLine(json)
				cIsSLAA := "True"
				IF oTempObj:cTableUID==cTable_UID
					//Vrisko poia kolona psaxnw
					iIndexToCheckLocal := (int)INT64.Parse(oTempObj:cColumnIndex)
					//Arxikopoiw se ena ton metrhth ths seiras
					iInsideCount := 1
					cLineUIDS := ""
					iInsideTableCount := iCount + 1
					WHILE cIsSLAA != "False" .and. iInsideTableCount<iCountRows
						// An o arithmos kolonas einia idios me auton pou psaxnw
						oRowInside :=  oDTReportItems:Rows[iInsideTableCount]
						cInsideType := oRowInside["ItemType"]:ToString()
						IF cLineUIDS ==""
							cLineUIDS := oRowInside["ITEM_UID"]:ToString()
						ELSE
							cLineUIDS += "," + oRowInside["ITEM_UID"]:ToString()
						ENDIF
						
						cIsSLAA := oRowInside["SLAA"]:ToString()
						IF cIsSLAA == "False"
							LOOP
						ENDIF
						LOCAL oUIDtoCheckForValue := UIDtoCheckForValue{}  AS UIDtoCheckForValue 
						IF iIndexToCheckLocal == iInsideCount .and. cInsideType!="L"
							//Prosethese ena antikeimeno me UID kai value sto array
							//oUIDtoCheckForValue:cValue := oTempObj:cValue
							//oUIDtoCheckForValue:iObjectId := oTempObj:iId
							cTempUid_Local := oRowInside["ITEM_UID"]:ToString()
							//oUIDtoCheckForValue:cTableName := cNameLocal
							cTempNameLocal := oRowInside["ItemName"]:ToString()
							lLineToAdd := true
						ENDIF
						cIsSLAA := oRowInside["SLAA"]:ToString()
						iInsideTableCount++
						iInsideCount++
						IF iInsideCount> iNumberOfTableColumns // Changing Line
							IF lLineToAdd
								oUIDtoCheckForValue:cValue := oTempObj:cValue
								oUIDtoCheckForValue:iObjectId := oTempObj:iId
								oUIDtoCheckForValue:cUID := cTempUid_Local
								oUIDtoCheckForValue:cTableName := cNameLocal
								oUIDtoCheckForValue:cName := cTempNameLocal
								oUIDtoCheckForValue:cMyLineUIDs := cLineUIDS
								oUIDtoCheckForValue:cTableUID := cTable_UID
								aUIDtoCheck:Add(oUIDtoCheckForValue)
							ENDIF
							iInsideCount:=1
							cLineUIDS := ""
							cTempNameLocal:=""
							cTempUid_Local:=""
							lLineToAdd := false
						ENDIF
					ENDDO
				ENDIF
			NEXT
		ENDIF
	NEXT
	
	txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": aUIDtoCheck Created..." + CRLF + txtProgress:Text
	System.Windows.Forms.Application.DoEvents()

	IF aUIDtoCheck == NULL || aUIDtoCheck:Count<1
		MessageBox.Show("Nothing To check.")
		RETURN
	ENDIF
	
	LOCAL lAllVesselsLocal := FALSE AS LOGIC
	IF self:ckbAllVessels:Checked
		lAllVesselsLocal := true
	ENDIF

	//IF SELF:ckbIncludeStatistics:Checked
	//	SELF:createExcel("",dStart,dEnd, lAllVesselsLocal)
	//ELSE
	//ENDIF
RETURN

PRIVATE METHOD createExcelSuperEng(cReportItemsUIDToCheck AS STRING, dStart AS Datetime, dEnd AS DateTime, lAllVessels := false as LOGIC) as void
	LOCAL lIncludeStatistics, lExcel AS LOGIC
	LOCAL lExactMatch := TRUE AS LOGIC
	LOCAL nDataStartOnColumn := 5 AS INT
	LOCAL oDTUsernames := DataTable{} AS DataTable

	IF SELF:ckbIncludeStatistics:Checked
		lIncludeStatistics := TRUE
	ENDIF
	IF SELf:ckbExcel:Checked
		lExcel := TRUE
	ENDIF

	LOCAL lAllVesselsLocal := TRUE, lHasSelectedVessels := FALSE AS LOGIC

	SELF:cVesselUID:=""
	
	FOREACH olvItemTemp AS ListViewItem IN SELF:lvVessels:Items
		IF olvItemTemp:Checked
			lHasSelectedVessels := TRUE
			IF SELF:cVesselUID ==""
				SELF:cVesselUID += olvItemTemp:Tag:ToString()
			ELSE
				SELF:cVesselUID += ","+ olvItemTemp:Tag:ToString()
			ENDIF
		ELSE
			lAllVesselsLocal := FALSE
		ENDIF
	NEXT
	
	IF !lHasSelectedVessels
		MessageBox.Show("No vessel selected To check.")
		RETURN
	ENDIF
		
	txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": Starting Excel Creation..." + CRLF + txtProgress:Text
	System.Windows.Forms.Application.DoEvents()

	LOCAL cStatement AS STRING

	//Get Only Finalised reports
	LOCAL cExtraStatusStatement := "" AS STRING
	IF SELF:ckbShowOnlySubmittedReports:Checked
		cExtraStatusStatement := " And FMDataPackages.Status > 0 "
	ENDIF

	//Get Reports
	IF(!lAllVesselsLocal)

		cStatement:="SELECT FMDataPackages.PACKAGE_UID, DateTimeGMT, GmtDiff, Username, Vessels.VesselName"+;
					" FROM FMDataPackages"+;
					" Inner Join Vessels on FMDataPackages.VESSEL_UNIQUEID = Vessels.VESSEL_UNIQUEID "+;
					" WHERE FMDataPackages.DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
					" AND FMDataPackages.VESSEL_UNIQUEID In ("+SELF:cVesselUID+")"+;
					" AND  FMDataPackages.Visible=1 AND FMDataPackages.REPORT_UID="+SELF:cMyReportUID+cExtraStatusStatement+;
					" ORDER BY FMDataPackages.Username Asc" 
					//" WHERE TDate BETWEEN '"+cStart+"' AND '"+cEnd+"'"+;
	ELSE
		cStatement:="SELECT FMDataPackages.PACKAGE_UID, FMDataPackages.DateTimeGMT, FMDataPackages.GmtDiff, "+;
					" Vessels.VesselName, FMDataPackages.Username "+;
					" FROM FMDataPackages"+;
					" Inner Join Vessels on FMDataPackages.VESSEL_UNIQUEID = Vessels.VESSEL_UNIQUEID "+;
					" WHERE FMDataPackages.DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
					" AND  FMDataPackages.Visible=1 AND FMDataPackages.REPORT_UID="+SELF:cMyReportUID+cExtraStatusStatement+;
					" ORDER BY FMDataPackages.Username Asc" 
	ENDIF

	SELF:oDTPackages := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	IF SELF:oDTPackages == NULL || SELF:oDTPackages:Rows:Count == 0
		MessageBox.Show("No Data found for these days !")
		RETURN
	ENDIF	
	txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": "+SELF:oDTPackages:Rows:Count:ToString()+" Reports Found..." + CRLF + txtProgress:Text
	System.Windows.Forms.Application.DoEvents()


	LOCAL dsLocal := DataSet{} AS DataSet
	LOCAL oDTFMDataLocal := DataTable{} AS DataTable
	oDTFMDataLocal:TableName := "Data"
    oDTFMDataLocal:Columns:Add("1", typeof(STRING))
    oDTFMDataLocal:Columns:Add("2", typeof(STRING))
    oDTFMDataLocal:Columns:Add("3", typeof(STRING))
    oDTFMDataLocal:Columns:Add("4", typeof(STRING))
    oDTFMDataLocal:Columns:Add("5", typeof(STRING))

	//Get Usernames
	IF(!lAllVessels)

		cStatement:="SELECT Distinct Username as Name, COUNT(*) as Number "+;
					" FROM FMDataPackages"+;
					" Inner Join Vessels on FMDataPackages.VESSEL_UNIQUEID = Vessels.VESSEL_UNIQUEID "+;
					" WHERE FMDataPackages.DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
					" AND FMDataPackages.VESSEL_UNIQUEID="+SELF:cVesselUID+;
					" AND  FMDataPackages.Visible=1 AND FMDataPackages.REPORT_UID="+SELF:cMyReportUID+cExtraStatusStatement+;
					" GROUP BY FMDataPackages.Username ORDER BY Username" 
	ELSE
		cStatement:=" SELECT Distinct FMDataPackages.Username as Name, COUNT(*) as Number "+;
					" FROM FMDataPackages"+;
					" WHERE FMDataPackages.DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
					" AND  FMDataPackages.Visible=1 AND FMDataPackages.REPORT_UID="+SELF:cMyReportUID+cExtraStatusStatement+;
					" AND FMDataPackages.VESSEL_UNIQUEID In ("+SELF:cVesselUID+")"+;
					" GROUP BY FMDataPackages.Username ORDER BY Username ASC" 
	ENDIF

	oDTUsernames := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	oDTUsernames:Columns:Add("Prcnt", typeof(STRING))	
	oDTUsernames:Columns:Add("Findings", typeof(String))
	oDTUsernames:Columns:Add("FindingsPerInspection", typeof(String))
	oDTUsernames:Columns:Add("5", typeof(String))

	self:cLinesUIDForAllTables := String[]{oDTUsernames:Rows:Count}  

	txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": "+oDTUsernames:Rows:Count:ToString()+" Users Found..." + CRLF + txtProgress:Text
	System.Windows.Forms.Application.DoEvents()

	
	
	lOCAL cFile AS STRING
	cFile := cTempDocDir+"\FMData_"+Datetime.Now:ToString("dd_MM_yyyy__HH_mm_ss")+".xlsx"	//".XLSX"

	SELF:Cursor := System.Windows.Forms.Cursors.WaitCursor

	LOCAL oldCI AS System.Globalization.CultureInfo
	oldCI:=System.Threading.Thread.CurrentThread:CurrentCulture
	System.Threading.Thread.CurrentThread:CurrentCulture:=System.Globalization.CultureInfo{"en-GB"}

	TRY
			LOCAL oXL AS Microsoft.Office.Interop.Excel.Application
			LOCAL oWB AS Microsoft.Office.Interop.Excel._Workbook
			LOCAL oSheet AS Microsoft.Office.Interop.Excel._WorkSheet 
			LOCAL oRangeLocal AS Microsoft.Office.Interop.Excel.Range
			LOCAL oRange AS Microsoft.Office.Interop.Excel.Range
			
			oXL := Microsoft.Office.Interop.Excel.Application{}
			oXL:Visible := FALSE
			oXL:DisplayAlerts := FALSE
			oWB := oXL:Workbooks:Add(Missing.Value)
			oSheet:=(_WorkSheet)oWB:Worksheets[1]
			oSheet:Name := "FMData"
			
			oSheet:Cells[1, 1] := "Name"
			oSheet:Cells[1, 2] := "Inspections"
			oSheet:Cells[1, 3] := "% of Total Inspections"
			oSheet:Cells[1, 4] := "Findings"
			oSheet:Cells[1, 5] := "Findings per Inspection"
		
		LOCAL nRow:=0, nCol := nDataStartOnColumn AS INT
		LOCAL cPackageUID, cItemUID, cData AS STRING
		LOCAL oRows AS DataRow[]
		LOCAL cMemo AS STRING
		LOCAL charSpl1 := (char)169 AS Char
		LOCAL charSpl2 := (char)168 AS Char
		LOCAL cItemsArray AS STRING[]
		LOCAL cItemsTemp  AS STRING[]
		LOCAL cStringDateTimeGMT AS STRING
		LOCAL oDateTime as DateTime
		LOCAL lDateSet as LOGIC
		// Ftiaxnw mia kolona 
		LOCAL cTableName, cColumnName, cPACKAGE_UIDLocal, cSectionName, cUserName :="", cSearchFor := cmbStatus:Text as String
		LOCAL oDTFMData := DataTable{} AS DataTable
		LOCAL iCountOccurences:=0, iCountOccurencesInRow :=0,iCount AS INT
		LOCAL cRangeName AS STRING
		LOCAL cLinesUIDsLocal := "" AS STRING
		LOCAL doubleQuote := '"' AS char
		LOCAL iCountRowsInTable := 0 AS INT
		LOCAL cCellDataLocal :="" AS STRING
		LOCAL iPrct AS INT
		LOCAL cPrct AS STRING
		LOCAL rFindingsPerInspection AS Decimal
		LOCAL oDTFItemNameDescription := DataTable{} AS DataTable 
		
		FOREACH oRowDate AS DataRow IN oDTPackages:Rows
				
				txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": Started   checking for "+oRowDate["Username"]:ToString()+" on "+DateTime.Parse(oRowDate["DateTimeGMT"]:ToString()):ToString("dd-MM-yyyy") + CRLF + txtProgress:Text
				System.Windows.Forms.Application.DoEvents()

				cPACKAGE_UIDLocal := oRowDate["PACKAGE_UID"]:ToString()
				IF cUserName!="" .and. oRowDate["Username"]:ToString() != cUserName
					//Report the iCountOccurences
					local oDRTemp := oDTUsernames:Rows[nRow] as DataRow
					oDRTemp["Findings"] := iCountOccurences:ToString()
					oDRTemp["5"] := cLinesUIDsLocal
					cLinesUIDsLocal := "" 
					oDRTemp:AcceptChanges()
					iCountOccurences:=0
					nRow ++
				ENDIF
				cUserName := oRowDate["Username"]:ToString()

				FOREACH oTempUIDLocal AS UIDtoCheckForValue IN SELF:aUIDtoCheck
				 
				 Local newCustomersRow := oDTFMDataLocal:NewRow() as DataRow	
				 cStatement :=" SELECT FMData.ITEM_UID, "+;
							" FMData.Data "+;
							" FROM FMData"+oMainForm:cNoLockTerm+;
							" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
							" WHERE FMDataPackages.PACKAGE_UID="+cPACKAGE_UIDLocal+;
							" AND FMData.ITEM_UID = "+oTempUIDLocal:cUID

						oDTFMData:Clear()	
						oDTFMData := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
						oDTFMData:TableName := "FMData"
						LOCAL lCompare as LOGIC
						FOREACH oRowDataTemp AS DataRow IN oDTFMData:Rows
							IF lExactMatch
								IF oRowDataTemp["Data"]:ToString():Trim():Equals(cSearchFor)
									lCompare := TRUE
								ELSE
									lCompare := FALSE
								ENDIF
							ELSE
								IF oRowDataTemp["Data"]:ToString():Contains(cSearchFor)
									lCompare := TRUE
								ELSE
									lCompare := FALSE
								ENDIF
							ENDIF

							IF lCompare
								iCountOccurences++
								IF cLinesUIDsLocal == ""
									cLinesUIDsLocal := cPACKAGE_UIDLocal+":"+oTempUIDLocal:cMyLineUIDs
								ELSE
									cLinesUIDsLocal += "-" + cPACKAGE_UIDLocal+":"+ oTempUIDLocal:cMyLineUIDs
								ENDIF
							ENDIF
							System.Windows.Forms.Application.DoEvents()
						NEXT
					System.Windows.Forms.Application.DoEvents()
				NEXT
				
				txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": Finished checking for "+oRowDate["Username"]:ToString()+" on "+DateTime.Parse(oRowDate["DateTimeGMT"]:ToString()):ToString("dd-MM-yyyy") + CRLF + txtProgress:Text
				System.Windows.Forms.Application.DoEvents()
		NEXT
		LOCAL oDRTemp := oDTUsernames:Rows[nRow] AS DataRow
		oDRTemp["Findings"] := iCountOccurences:ToString()
		oDRTemp["5"] := cLinesUIDsLocal
		oDRTemp:AcceptChanges()

		LOCAL iCountusers := 2 AS INT

		FOREACH oRowTemp AS DataRow IN oDTUsernames:Rows
			oSheet:Cells[iCountusers, 1] := oRowTemp["Name"]:ToString()
			oSheet:Cells[iCountusers, 2] := oRowTemp["Number"]:ToString()
			//3rd Column
			rFindingsPerInspection := (Decimal)(Decimal.Parse(oRowTemp["Number"]:ToString())/(Decimal)oDTPackages:Rows:Count)*(Decimal)100
			oSheet:Cells[iCountusers, 3] := rFindingsPerInspection:ToString("0.00")
			oRowTemp["Prcnt"] := rFindingsPerInspection:ToString("0.00")
			oRowTemp:AcceptChanges()
			//4rth Column
			oSheet:Cells[iCountusers, 4] := oRowTemp["Findings"]:ToString()
			//5th Column
			rFindingsPerInspection := Decimal.Parse(oRowTemp["Findings"]:ToString())/Decimal.Parse(oRowTemp["Number"]:ToString())
			oSheet:Cells[iCountusers, 5] := rFindingsPerInspection:ToString("0.00")
			oRowTemp["FindingsPerInspection"] := rFindingsPerInspection:ToString("0.00")
			oRowTemp:AcceptChanges()
			iCountusers++
			oDTUsernames:AcceptChanges()
		NEXT

		oDTUsernames:TableName:="Users"
		dsLocal:Tables:Add(oDTUsernames)
		SELF:gcResults:DataSource := dsLocal
		SELF:gcResults:DataMember := "Users"
		SELF:gcResults:ForceInitialize()
		SELF:gvResults:Columns["5"]:Visible := FALSE
		SELF:gvResults:Columns["Number"]:Caption := "Inspections"
		SELF:gvResults:Columns["Number"]:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		SELF:gvResults:Columns["Prcnt"]:Caption := "% of Total Inspections"
		SELF:gvResults:Columns["Prcnt"]:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		SELF:gvResults:Columns["Findings"]:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		SELF:gvResults:Columns["FindingsPerInspection"]:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		IF !lSumsCreated
			 SELF:gvResults:Columns[1]:Summary:Add(DevExpress.Data.SummaryItemType.Sum, "", "{0} Insections")
		     SELF:gvResults:Columns[3]:Summary:Add(DevExpress.Data.SummaryItemType.Sum, "", "{0} Total Findings")
			 lSumsCreated := TRUE
			 SELF:gvResults:Appearance:FooterPanel:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
			 SELF:gvResults:Appearance:FooterPanel:Options:UseTextOptions := TRUE
		ENDIF		
		IF lExcel
		txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": Creating sums..." + CRLF + txtProgress:Text
		System.Windows.Forms.Application.DoEvents()
		//Create Sums
		oRangeLocal := oSheet:Range[oSheet:Cells[iCountusers,2], oSheet:Cells[iCountusers,2]]
		oRangeLocal:Formula := STRING.Format("=SUM(B2:B{0})", iCountusers-1)
		oRangeLocal:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
		oRangeLocal:Font:Bold := TRUE

		oRangeLocal := oSheet:Range[oSheet:Cells[iCountusers,4], oSheet:Cells[iCountusers,4]]
		oRangeLocal:Formula := STRING.Format("=SUM(D2:D{0})", iCountusers-1)
		oRangeLocal:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
		oRangeLocal:Font:Bold := TRUE

		//LOCAL oRangeLocal AS Microsoft.Office.Interop.Excel.Range
		oRangeLocal := oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[iCountusers-1, 5]]
		oRangeLocal:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter
		//local oStyle as Microsoft.Office.Interop.Excel.Style 
		
		oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[1, 5]]:Font:Bold := TRUE
		oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[iCountusers, 1]]:Font:Bold := TRUE
		oSheet:Range[oSheet:Cells[2, 1], oSheet:Cells[iCountusers, 1]]:HorizontalAlignment := Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignLeft
		oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[iCountusers-1, 5]]:Columns:Autofit()
		oXL:ActiveWindow:SplitRow := 1
		oXL:ActiveWindow:SplitColumn := 1
		oXL:ActiveWindow:FreezePanes := TRUE
		oSheet := NULL
		
		oWB:SaveAs(cFile, Microsoft.Office.Interop.Excel.XlFileFormat.xlOpenXMLWorkbook, Missing.Value, Missing.Value, Missing.Value, Missing.Value, ;
						Microsoft.Office.Interop.Excel.XlSaveAsAccessMode.xlExclusive, Missing.Value, Missing.Value, Missing.Value, Missing.Value, Missing.Value)
	
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
		ELSE
			oWB:Close(Missing.Value, Missing.Value, Missing.Value)
			oWB := NULL
			oXL:Quit()
		ENDIF // end if excel
		
		CATCH exc AS Exception
			MessageBox.Show(exc:Message)
		FINALLY
			System.Threading.Thread.CurrentThread:CurrentCulture:=oldCI
			SELF:Cursor := System.Windows.Forms.Cursors.Default
		END TRY
	

RETURN

PRIVATE METHOD gvResulsFocusedChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.FocusedRowObjectChangedEventArgs ) AS System.Void

	

	LOCAL oRow AS DataRow
	LOCAL charSpl1 := (char)169 AS Char
	LOCAL charSpl2 := (char)168 AS Char

	LOCAL iFR := e:FocusedRowHandle as int
	IF gcResults:DataSource == NULL	
		RETURN
	ENDIF
	
	oRow := SELF:gvResults:GetDataRow(iFR)

	IF oRow == NULL
		RETURN
	ENDIF


	LOCAL cUIDs := oRow:Item["5"]:ToString() AS STRING

	IF cUIDs == NULL || cUIDs==""
		SELF:gcDetails:DataSource := null
		RETURN
	ENDIF

	LOCAL lCommentsAndCA AS LOGIC
	
	IF SELF:ckbComAndCA:Checked
		lCommentsAndCA := TRUE
	ENDIF
	
	LOCAL dsLocal := DataSet{} AS DataSet
	LOCAL oDTFMDataLocal := DataTable{},oDTFMDataPackagesLocal := DataTable{} AS DataTable
	oDTFMDataLocal:TableName := "Details"
    oDTFMDataLocal:Columns:Add("Vessel", typeof(STRING))
    oDTFMDataLocal:Columns:Add("PACKAGE_UID", typeof(STRING))
    oDTFMDataLocal:Columns:Add("Date", typeof(STRING))
    oDTFMDataLocal:Columns:Add("HeldBy", typeof(STRING))
    oDTFMDataLocal:Columns:Add("Question", typeof(STRING))
	IF lCommentsAndCA
		oDTFMDataLocal:Columns:Add("Comments", typeof(STRING))
		oDTFMDataLocal:Columns:Add("CommentsUID", typeof(STRING))
		oDTFMDataLocal:Columns:Add("CA", typeof(STRING))
	ENDIF
	LOCAL cMemo AS STRING
	LOCAL iFind, iFindEnd as int
	LOCAL cSplit3, cSplit2, cItems := cUIDs:Split('-') AS STRING[]
	FOREACH cItem AS STRING IN cItems
		iFind := 0
		iFindEnd := 0
		LOCAL newCustomersRow := oDTFMDataLocal:NewRow() AS DataRow

		cSplit2 := cItem:Split(':')
		LOCAL cStatement := " SELECT DateTimeGMT, UserName, VESSELS.VesselName, Memo FROM FMDataPackages "+;
							" Inner Join VESSELS ON VESSELS.VESSEL_UNIQUEID = FMDataPackages.VESSEL_UNIQUEID "+;
						    " WHERE FMDataPackages.PACKAGE_UID="+cSplit2[1]:ToString() as String
		oDTFMDataPackagesLocal:Clear()	
		oDTFMDataPackagesLocal := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		LOCAL oRowDate := oDTFMDataPackagesLocal:Rows[0] AS DataRow
		newCustomersRow["Vessel"] := oRowDate["VesselName"]:ToString()
		newCustomersRow["HeldBy"] := oRowDate["UserName"]:ToString()
		newCustomersRow["PACKAGE_UID"] := cSplit2[1]:ToString()
		LOCAL oDateTime AS DateTime
		DateTime.TryParse(oRowDate["DateTimeGMT"]:ToString(),oDateTime)
		System.Threading.Thread.CurrentThread:CurrentCulture:=System.Globalization.CultureInfo{"en-GB"}
		LOCAL cStringDateTimeGMT := oDateTime:ToString("dd/MM/yyyy") AS STRING
		newCustomersRow["Date"] := cStringDateTimeGMT
		cMemo := oRowDate["Memo"]:ToString()

		cSplit3 := cSplit2[2]:Split(',')
		cStatement := " SELECT ItemName FROM FMReportItems "+;
					  " WHERE  ITEM_UID="+cSplit3[2]:ToString()
		oDTFMDataPackagesLocal:Clear()	
		oDTFMDataPackagesLocal := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		oRowDate := oDTFMDataPackagesLocal:Rows[0]
		cStringDateTimeGMT := oRowDate["ItemName"]:ToString()
		// If this is a free question we have to go and get the data from DMFData
		IF cStringDateTimeGMT == "Free Question"
			TRY
				iFind := cMemo:IndexOf(cSplit3[2]:ToString()+charSpl2:ToString())
				iFindEnd := cMemo:IndexOf(charSpl1,iFind)
				iFind += cSplit3[2]:ToString():Length+1
				cStringDateTimeGMT := cMemo:Substring(iFind,iFindEnd-iFind)
			CATCH
				cStringDateTimeGMT := ""
			END TRY
		ENDIF
		//
		newCustomersRow["Question"] := cStringDateTimeGMT
		IF lCommentsAndCA 
			TRY
				newCustomersRow["CommentsUID"] := cSplit3[4]:ToString()
				iFind := cMemo:IndexOf(cSplit3[4]:ToString()+charSpl2:ToString())
				iFindEnd := cMemo:IndexOf(charSpl1,iFind)
				iFind += cSplit3[4]:ToString():Length+1
				cStatement := cMemo:Substring(iFind,iFindEnd-iFind)
				IF cStatement:Length>0
					newCustomersRow["Comments"] := cStatement
				ENDIF
			CATCH
				newCustomersRow["Comments"] := ""
			END TRY

			IF  cSplit3:Length > 5
				TRY
					cStatement := " SELECT Data FROM FMData "+;
							  " WHERE  ITEM_UID="+cSplit3[5]:ToString()+;
							  " AND PACKAGE_UID="+cSplit2[1]
					oDTFMDataPackagesLocal:Clear()	
					oDTFMDataPackagesLocal := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
					IF oDTFMDataPackagesLocal:Rows:Count>0
						oRowDate := oDTFMDataPackagesLocal:Rows[0]
						cStringDateTimeGMT := oRowDate["Data"]:ToString()
						newCustomersRow["CA"] := cStringDateTimeGMT
					ENDIF
				CATCH
					newCustomersRow["CA"] := ""
				END TRY
			ENDIF
		ENDIF
		oDTFMDataLocal:Rows:Add(newCustomersRow)
	NEXT

	dsLocal:Tables:Add(oDTFMDataLocal)
	SELF:gcDetails:DataSource := dsLocal
    SELF:gcDetails:DataMember := "Details"

	LOCAL memoEdit := DevExpress.XtraEditors.Repository.RepositoryItemMemoEdit{} AS DevExpress.XtraEditors.Repository.RepositoryItemMemoEdit
	SELF:gcDetails:RepositoryItems:Add(memoEdit)
	SELF:gvDetails:Columns["Question"]:ColumnEdit := memoEdit
	
	SELF:gvDetails:Columns["Vessel"]:OptionsColumn:FixedWidth := True 
	SELF:gvDetails:Columns["Vessel"]:Width := 100
	SELF:gvDetails:Columns["Date"]:OptionsColumn:FixedWidth := True 
	SELF:gvDetails:Columns["Date"]:Width :=   70
	SELF:gvDetails:Columns["HeldBy"]:OptionsColumn:FixedWidth := True 
	SELF:gvDetails:Columns["HeldBy"]:Width := 40
	SELF:gvDetails:Columns["Question"]:OptionsColumn:FixedWidth := True 
	SELF:gvDetails:Columns["Question"]:Width := 300
	SELF:gvDetails:Columns["PACKAGE_UID"]:Visible := FALSE 
	TRY
	IF lCommentsAndCA
		LOCAL memoEdit2 := DevExpress.XtraEditors.Repository.RepositoryItemMemoEdit{} AS DevExpress.XtraEditors.Repository.RepositoryItemMemoEdit
		SELF:gcDetails:RepositoryItems:Add(memoEdit2)
		SELF:gvDetails:Columns["Comments"]:ColumnEdit := memoEdit2
		SELF:gvDetails:Columns["Comments"]:OptionsColumn:FixedWidth := True 
		SELF:gvDetails:Columns["Comments"]:OptionsColumn:ReadOnly := False 
		SELF:gvDetails:Columns["Comments"]:Width := 200
		SELF:gvDetails:Columns["CommentsUID"]:Visible := FALSE	
		SELF:gvDetails:Columns["CA"]:OptionsColumn:FixedWidth := True 
		SELF:gvDetails:Columns["CA"]:Width := 80
	ENDIF
	CATCH

	end try
	//SELF:gvDetails:BestFitColumns()
	//SELF:gcDetails:ForceInitialize()

RETURN


PRIVATE METHOD gvResultsSelectionChanged() AS System.Void
	
	IF SELF:splitContainerControl1:PanelVisibility == DevExpress.XtraEditors.SplitPanelVisibility.Panel1
		RETURN
	ENDIF

	IF gcResults:DataSource == NULL	
		MessageBox.Show("No Datasource")
		RETURN
	ENDIF
	
	LOCAL iSelectedRowsCount := SELF:gvResults:SelectedRowsCount AS INT
	LOCAL iSelectedRowHandles AS INT[]
	iSelectedRowHandles := gvResults:GetSelectedRows()

    IF iSelectedRowsCount == 0 .or. iSelectedRowHandles:Length < 1
		MessageBox.Show("No selected Rows")
		RETURN
    ENDIF
	Local oDTSelectedRows := ArrayList{} as ArrayList

	LOCAL iCount := 1 as INT
	WHILE  iCount <= iSelectedRowsCount
			LOCAL iRowHandleLocal := iSelectedRowHandles[iCount] as int
			iCount++
            IF iRowHandleLocal >= 0
				LOCAL oDataRowTemp := gvResults:GetDataRow(iRowHandleLocal) AS DataRow
				IF oDataRowTemp == NULL
					LOOP
				endif
                oDTSelectedRows:Add(oDataRowTemp)
			ENDIF
    ENDDO

	IF oDTSelectedRows:Count<1
		RETURN
	ENDIF
	
	LOCAL lCommentsAndCA AS LOGIC
	IF SELF:ckbComAndCA:Checked
		lCommentsAndCA := TRUE
	ENDIF                 

	LOCAL dsLocal := DataSet{} AS DataSet
	LOCAL oDTFMDataLocal := DataTable{},oDTFMDataPackagesLocal := DataTable{} AS DataTable
	oDTFMDataLocal:TableName := "Details"
    oDTFMDataLocal:Columns:Add("Vessel", typeof(STRING))
    oDTFMDataLocal:Columns:Add("Category", typeof(STRING))
    oDTFMDataLocal:Columns:Add("PACKAGE_UID", typeof(STRING))
    oDTFMDataLocal:Columns:Add("Date", typeof(STRING))
    oDTFMDataLocal:Columns:Add("HeldBy", typeof(STRING))
    oDTFMDataLocal:Columns:Add("Question", typeof(STRING))
	IF lCommentsAndCA
		oDTFMDataLocal:Columns:Add("Comments", typeof(STRING))
		oDTFMDataLocal:Columns:Add("CommentsUID", typeof(STRING))
		oDTFMDataLocal:Columns:Add("CA", typeof(STRING))
	ENDIF
	LOCAL charSpl1 := (char)169 AS Char
	LOCAL charSpl2 := (char)168 AS Char
	

	
	LOCAL cMemo AS STRING
	LOCAL iFind, iFindEnd as int


	FOREACH oRow AS DataRow IN oDTSelectedRows
		cMemo :=""
		LOCAL cUIDs := oRow:Item["5"]:ToString() AS STRING

		LOCAL cSplit3, cSplit2, cItems := cUIDs:Split('-') AS STRING[]
		IF oRow == NULL
			loop
		ENDIF



		IF cUIDs == NULL || cUIDs==""
			loop
		ENDIF

	
	
		FOREACH cItem AS STRING IN cItems
			iFind := 0
			iFindEnd := 0
			LOCAL newCustomersRow := oDTFMDataLocal:NewRow() AS DataRow

			cSplit2 := cItem:Split(':')
			LOCAL cStatement := " SELECT DateTimeGMT, UserName, VESSELS.VesselName, Memo FROM FMDataPackages "+;
								" Inner Join VESSELS ON VESSELS.VESSEL_UNIQUEID = FMDataPackages.VESSEL_UNIQUEID "+;
								" WHERE FMDataPackages.PACKAGE_UID="+cSplit2[1]:ToString() as String
			oDTFMDataPackagesLocal:Clear()	
			oDTFMDataPackagesLocal := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
			LOCAL oRowDate := oDTFMDataPackagesLocal:Rows[0] AS DataRow
			newCustomersRow["Vessel"] := oRowDate["VesselName"]:ToString()
			newCustomersRow["HeldBy"] := oRowDate["UserName"]:ToString()
			newCustomersRow["PACKAGE_UID"] := cSplit2[1]:ToString()
			LOCAL oDateTime AS DateTime
			DateTime.TryParse(oRowDate["DateTimeGMT"]:ToString(),oDateTime)
			System.Threading.Thread.CurrentThread:CurrentCulture:=System.Globalization.CultureInfo{"en-GB"}
			LOCAL cStringDateTimeGMT := oDateTime:ToString("dd/MM/yyyy"), cCategoryOfItem :="" AS STRING
			newCustomersRow["Date"] := cStringDateTimeGMT
			cMemo := oRowDate["Memo"]:ToString()

			cSplit3 := cSplit2[2]:Split(',')
			cStatement := " SELECT ItemName, FMItemCategories.Description FROM FMReportItems "+;
						  " Left Outer JOIN FMItemCategories On FMReportItems.CATEGORY_UID = FMItemCategories.CATEGORY_UID "+;
						  " WHERE  ITEM_UID="+cSplit3[2]:ToString()
			oDTFMDataPackagesLocal:Clear()	
			oDTFMDataPackagesLocal := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
			oRowDate := oDTFMDataPackagesLocal:Rows[0]
			cStringDateTimeGMT := oRowDate["ItemName"]:ToString()
			cCategoryOfItem := oRowDate["Description"]:ToString()
			newCustomersRow["Category"] := cCategoryOfItem
			// If this is a free question we have to go and get the data from DMFData
			IF cStringDateTimeGMT == "Free Question"
				TRY
					iFind := cMemo:IndexOf(cSplit3[2]:ToString()+charSpl2:ToString())
					iFindEnd := cMemo:IndexOf(charSpl1,iFind)
					iFind += cSplit3[2]:ToString():Length+1
					cStringDateTimeGMT := cMemo:Substring(iFind,iFindEnd-iFind)
				CATCH
					cStringDateTimeGMT := ""
				END TRY
			ENDIF
			//
			newCustomersRow["Question"] := cStringDateTimeGMT
			IF lCommentsAndCA 
				TRY
					newCustomersRow["CommentsUID"] := cSplit3[4]:ToString()
					iFind := cMemo:IndexOf(cSplit3[4]:ToString()+charSpl2:ToString())
					iFindEnd := cMemo:IndexOf(charSpl1,iFind)
					iFind += cSplit3[4]:ToString():Length+1
					cStatement := cMemo:Substring(iFind,iFindEnd-iFind)
					IF cStatement:Length>0
						newCustomersRow["Comments"] := cStatement
					ENDIF
				CATCH
					newCustomersRow["Comments"] := ""
				END TRY

				IF  cSplit3:Length > 5
					TRY
						cStatement := " SELECT Data FROM FMData "+;
								  " WHERE  ITEM_UID="+cSplit3[5]:ToString()+;
								  " AND PACKAGE_UID="+cSplit2[1]
						oDTFMDataPackagesLocal:Clear()	
						oDTFMDataPackagesLocal := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
						IF oDTFMDataPackagesLocal:Rows:Count>0
							oRowDate := oDTFMDataPackagesLocal:Rows[0]
							cStringDateTimeGMT := oRowDate["Data"]:ToString()
							newCustomersRow["CA"] := cStringDateTimeGMT
						ENDIF
					CATCH
						newCustomersRow["CA"] := ""
					END TRY
				ENDIF
			ENDIF
			oDTFMDataLocal:Rows:Add(newCustomersRow)
		NEXT
	NEXT

	dsLocal:Tables:Add(oDTFMDataLocal)
	SELF:gcDetails:DataSource := dsLocal
    SELF:gcDetails:DataMember := "Details"

	LOCAL memoEdit := DevExpress.XtraEditors.Repository.RepositoryItemMemoEdit{} AS DevExpress.XtraEditors.Repository.RepositoryItemMemoEdit
	SELF:gcDetails:RepositoryItems:Add(memoEdit)
	SELF:gvDetails:Columns["Question"]:ColumnEdit := memoEdit
	
	SELF:gvDetails:Columns["Vessel"]:OptionsColumn:FixedWidth := True 
	SELF:gvDetails:Columns["Vessel"]:Width := 100
	SELF:gvDetails:Columns["Category"]:OptionsColumn:FixedWidth := True 
	SELF:gvDetails:Columns["Category"]:Width := 80
	SELF:gvDetails:Columns["Date"]:OptionsColumn:FixedWidth := True 
	SELF:gvDetails:Columns["Date"]:Width :=   70
	SELF:gvDetails:Columns["HeldBy"]:OptionsColumn:FixedWidth := True 
	SELF:gvDetails:Columns["HeldBy"]:Width := 40
	SELF:gvDetails:Columns["Question"]:OptionsColumn:FixedWidth := True 
	SELF:gvDetails:Columns["Question"]:Width := 300
	SELF:gvDetails:Columns["PACKAGE_UID"]:Visible := FALSE 
	TRY
	IF lCommentsAndCA
		LOCAL memoEdit2 := DevExpress.XtraEditors.Repository.RepositoryItemMemoEdit{} AS DevExpress.XtraEditors.Repository.RepositoryItemMemoEdit
		SELF:gcDetails:RepositoryItems:Add(memoEdit2)
		SELF:gvDetails:Columns["Comments"]:ColumnEdit := memoEdit2
		SELF:gvDetails:Columns["Comments"]:OptionsColumn:FixedWidth := True 
		SELF:gvDetails:Columns["Comments"]:OptionsColumn:ReadOnly := False 
		SELF:gvDetails:Columns["Comments"]:Width := 200
		SELF:gvDetails:Columns["CommentsUID"]:Visible := FALSE	
		SELF:gvDetails:Columns["CA"]:OptionsColumn:FixedWidth := True 
		SELF:gvDetails:Columns["CA"]:Width := 80
	ENDIF
	CATCH

	end try
	//SELF:gvDetails:BestFitColumns()
	//SELF:gcDetails:ForceInitialize()
			

RETURN


END CLASS

CLASS objectToCheck INHERIT OBJECT

	EXPORT cTableUID AS STRING
	EXPORT cColumnIndex AS STRING
	EXPORT cColumnName as String
	EXPORT cValue AS STRING
	EXPORT iId AS INT

	CONSTRUCTOR()
      SUPER()
      RETURN	

	PUBLIC METHOD objectToCheck AS objectToCheck
		SELF:cColumnName :=""
		SELF:cTableUID := ""
		SELF:cColumnIndex :=""
		SELF:cValue := ""
		self:iId:=0
	RETURN self

	
END CLASS

CLASS UIDtoCheckForValue INHERIT OBJECT

	EXPORT cTableUID AS STRING
	EXPORT cTableName as STRING
	EXPORT cUID AS STRING
	EXPORT cValue AS STRING
	EXPORT cName AS STRING
	EXPORT iObjectId as INT
	EXPORT cMyLineUIDs AS STRING
	EXPORT iExpDays AS INT

	CONSTRUCTOR()
      SUPER()
      RETURN	

	PUBLIC METHOD UIDtoCheckForValue AS UIDtoCheckForValue
		SELF:cUID := ""
		SELF:cValue :=""
		SELF:cTableUID:=""
		SELF:cTableName:=""
		SELF:cName :=""
		SELF:iObjectId := 0
		SELF:cMyLineUIDs := ""
		SELF:iExpDays :=0
	RETURN self

	
END CLASS

CLASS ObjectFound INHERIT OBJECT

	EXPORT oUIDtoCheckForValue AS UIDtoCheckForValue
	EXPORT cVesselUid AS STRING
	EXPORT cVesselName AS STRING

	CONSTRUCTOR()
      SUPER()
      RETURN	

	PUBLIC METHOD ObjectFound AS ObjectFound
		SELF:cVesselUid := ""
		SELF:oUIDtoCheckForValue := UIDtoCheckForValue{}
		SELF:cVesselName := ""
	RETURN SELF

	
END CLASS