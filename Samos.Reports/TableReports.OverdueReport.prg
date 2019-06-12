// TableReports.prg
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

PRIVATE METHOD btnOverdueReport_Clicked() AS VOID

	txtProgress:Text :=""

	LOCAL cFieldNameToCheckLocal := SELF:txtFieldNameToCheck:Text AS STRING
	//LOCAL cReportsToCheckSQLLocal := " Report_UID in (1029) " as String

	IF SELF:DateFrom:DateTime > SELF:DateTo:DateTime
			wb("Invalid dates")
			SELF:DateTo:Focus()
			RETURN
	ENDIF
	LOCAL cStatement AS STRING
	
	LOCAL cValue := "" AS string
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
	
	LOCAL dEnd := SELF:DateTo:DateTime AS DateTime

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
	LOCAL cReportItemsUIDToCheck := "" AS STRING
	LOCAL oRow, oRowInside AS DataRow
	LOCAL iNumberOfTableColumns, iExpDays:=0 AS INT
	LOCAL cItemTypeValues, cNameLocal, cExpDays:="" AS STRING
	LOCAL cLineUIDS:="",cTempUid_Local:="",cTempNameLocal:="" AS STRING
	LOCAL lLineToAdd := FALSE AS LOGIC
	
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
			//FOREACH oTempObj AS objectToCheck IN SELF:aObjects
				cIsSLAA := "True"
			//	IF oTempObj:cTableUID==cTable_UID
					//psaxno sklhra to status pou einai sto 3
					iIndexToCheckLocal := 3 //(int)INT64.Parse(oTempObj:cColumnIndex)
					//Arxikopoiw se ena ton metrhth ths seiras
					iInsideCount := 1
					cLineUIDS := ""
					iInsideTableCount := iCount + 1
					WHILE cIsSLAA != "False" .AND. iInsideTableCount<iCountRows
						// An o arithmos kolonas einia idios me auton pou psaxnw
						oRowInside :=  oDTReportItems:Rows[iInsideTableCount]
						cInsideType := oRowInside["ItemType"]:ToString()
						IF cLineUIDS ==""
							cLineUIDS := oRowInside["ITEM_UID"]:ToString()
						ELSE
							cLineUIDS += "," + oRowInside["ITEM_UID"]:ToString()
						ENDIF
						
						cIsSLAA := oRowInside["SLAA"]:ToString()
						cExpDays :=  oRowInside["ExpDays"]:ToString()
						IF cIsSLAA == "False"
							LOOP
						ENDIF
						LOCAL oUIDtoCheckForValue := UIDtoCheckForValue{}  AS UIDtoCheckForValue 
						IF iIndexToCheckLocal == iInsideCount .AND. cInsideType!="L" .AND. cExpDays <> NULL .AND. Convert.ToInt32(cExpDays)>0
							//Prosethese ena antikeimeno me UID kai value sto array
							//oUIDtoCheckForValue:cValue := oTempObj:cValue
							//oUIDtoCheckForValue:iObjectId := oTempObj:iId
							cTempUid_Local := oRowInside["ITEM_UID"]:ToString()
							//oUIDtoCheckForValue:cTableName := cNameLocal
							cTempNameLocal := oRowInside["ItemName"]:ToString()
							iExpDays := Convert.ToInt32(cExpDays)
							lLineToAdd := TRUE
						ENDIF
						cIsSLAA := oRowInside["SLAA"]:ToString()
						iInsideTableCount++
						iInsideCount++
						IF iInsideCount> iNumberOfTableColumns // Changing Line
							IF lLineToAdd
								//oUIDtoCheckForValue:cValue := oTempObj:cValue
								//oUIDtoCheckForValue:iObjectId := oTempObj:iId
								oUIDtoCheckForValue:cUID := cTempUid_Local
								oUIDtoCheckForValue:cTableName := cNameLocal
								oUIDtoCheckForValue:cName := cTempNameLocal
								oUIDtoCheckForValue:cMyLineUIDs := cLineUIDS
								oUIDtoCheckForValue:cTableUID := cTable_UID
								oUIDtoCheckForValue:iExpDays := iExpDays
								aUIDtoCheck:Add(oUIDtoCheckForValue)
							ENDIF
							iInsideCount:=1
							cLineUIDS := ""
							cTempNameLocal:=""
							cTempUid_Local:=""
							lLineToAdd := FALSE
						ENDIF
					ENDDO
				//ENDIF
			//NEXT
		ENDIF
	NEXT
	
	txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": aUIDtoCheck Created..." + CRLF + txtProgress:Text
	System.Windows.Forms.Application.DoEvents()

	IF aUIDtoCheck == NULL || aUIDtoCheck:Count<1
		MessageBox.Show("Nothing To check.")
		RETURN
	ENDIF
	
	SELF:createExcelOverdue(dEnd)
	
RETURN



PRIVATE METHOD createExcelOverdue(dEnd AS DateTime) AS VOID
	
	LOCAL lIncludeStatistics, lExcel AS LOGIC
	LOCAL lExactMatch := TRUE AS LOGIC
	LOCAL nDataStartOnColumn := 3 AS INT
	LOCAL charSpl1 := (CHAR)169 AS CHAR
	LOCAL charSpl2 := (CHAR)168 AS CHAR		

	IF SELF:ckbExcel:Checked
		lExcel := TRUE
	ENDIF

	IF SELF:ckbIncludeStatistics:Checked
		lIncludeStatistics := TRUE
	ENDIF


	LOCAL lAllVesselsLocal := TRUE, lHasSelectedVessels := FALSE AS LOGIC

	SELF:cVesselUID:=""

	LOCAL oALVessels := ArrayList{}, oALObjectsFound := ArrayList{} AS ArrayList
	FOREACH olvItemTemp AS ListViewItem IN SELF:lvVessels:Items
		IF olvItemTemp:Checked
			oALVessels:Add(olvItemTemp:Tag:ToString())
		ENDIF
	NEXT

	LOCAL cExtraStatusStatement := "" AS STRING
	IF SELF:ckbShowOnlySubmittedReports:Checked
		cExtraStatusStatement := " And FMDataPackages.Status > 1 "
	ENDIF
		
	txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": Starting Report Creation..." + CRLF + txtProgress:Text
	System.Windows.Forms.Application.DoEvents()

	LOCAL cStatement AS STRING
	LOCAL oDTFMData := DataTable{} AS DataTable
	LOCAL dExpDate AS DateTime
	LOCAL lFound := FALSE AS LOGIC
	TRY
		IF oALVessels:Count<1
			MessageBox.Show("There is no vessel selected","No action")
		ENDIF
		//kano ti diadikasia gia kathe epilegmeno ploio.
		FOREACH cTempVesselUID AS STRING IN oALVessels
			//psaxno gia ola ta comboz pou exoun expdays
			FOREACH oObjectToCheckLocal AS UIDtoCheckForValue IN SELF:aUIDtoCheck

				dExpDate := dEnd:AddDays(-oObjectToCheckLocal:iExpDays)

				cStatement :="SELECT FMData.ITEM_UID, "+;
							" FMData.Data, FMDataPackages.DateTimeGMT "+;
							" FROM FMData"+oMainForm:cNoLockTerm+;
							" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
							" WHERE FMDataPackages.VESSEL_UNIQUEID="+cTempVesselUID+cExtraStatusStatement+;
							" AND FMData.ITEM_UID = "+oObjectToCheckLocal:cUID+ " AND FMDataPackages.DateTimeGMT >= '"+;
							dExpDate:ToString("yyyy-MM-dd 00:00:01")+"' "+;
							" Order By FMDataPackages.DateTimeGMT Desc "
				oDTFMData:Clear()	
				oDTFMData := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
				oDTFMData:TableName := "FMData"
				//an den yparxei report gia to sygkekrimeno tote shmainei oti einai overdue
				IF oDTFMData==NULL .OR. oDTFMData:Rows:Count<1
					LOCAL oObjectFound := ObjectFound{}  AS ObjectFound
					oObjectFound:cVesselUid := cTempVesselUID
					oObjectFound:oUIDtoCheckForValue := oObjectToCheckLocal
					oALObjectsFound:Add(oObjectFound)
					LOOP
				ENDIF
				lFound := FALSE
				FOREACH oRowDataTemp AS DataRow IN oDTFMData:Rows
					IF oRowDataTemp["Data"]:ToString():ToUpper():Trim():Equals("YES");
						.OR. oRowDataTemp["Data"]:ToString():ToUpper():Trim():Equals("NO")
						lFound := TRUE
						EXIT
					ENDIF
				NEXT
				IF !lFound
					LOCAL oObjectFound := ObjectFound{}  AS ObjectFound
					oObjectFound:cVesselUid := cTempVesselUID
					oObjectFound:oUIDtoCheckForValue := oObjectToCheckLocal
					oALObjectsFound:Add(oObjectFound)
				ENDIF
			NEXT
		NEXT
		//exo sto oALObjectsFound ta overdue items
		LOCAL dsLocal := DataSet{} AS DataSet
		LOCAL oDTFMDataLocal := DataTable{},oDTFMDataPackagesLocal := DataTable{} AS DataTable
		LOCAL oRowTemp AS DataRow
		LOCAL cResult AS STRING
		oDTFMDataLocal:TableName := "Details"
		oDTFMDataLocal:Columns:Add("Vessel", typeof(STRING))
		oDTFMDataLocal:Columns:Add("VESSEL_UNIQUEID", typeof(STRING))
		oDTFMDataLocal:Columns:Add("Question", typeof(STRING))
		FOREACH oObjectToCheckLocal AS ObjectFound IN oALObjectsFound
			LOCAL cSplitArray := oObjectToCheckLocal:oUIDtoCheckForValue:cMyLineUIDs:Split(',') AS STRING[]
			cStatement := " SELECT ItemName FROM FMReportItems "+;
					  " WHERE  ITEM_UID="+cSplitArray[2]:ToString()
			oDTFMDataPackagesLocal:Clear()	
			oDTFMDataPackagesLocal := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
			oRowTemp := oDTFMDataPackagesLocal:Rows[0]
			cResult := oRowTemp["ItemName"]:ToString()
			IF cResult == "Free Question"
				LOOP
			ENDIF
			LOCAL newCustomersRow := oDTFMDataLocal:NewRow() AS DataRow
			newCustomersRow["Question"] := cResult
			cStatement := " SELECT VesselName FROM Vessels "+;
					  " WHERE  Vessel_UniqueId="+oObjectToCheckLocal:cVesselUid
			oDTFMDataPackagesLocal:Clear()	
			oDTFMDataPackagesLocal := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
			oRowTemp := oDTFMDataPackagesLocal:Rows[0]
			cResult := oRowTemp["VesselName"]:ToString()
			newCustomersRow["Vessel"] := cResult
			newCustomersRow["VESSEL_UNIQUEID"] := oObjectToCheckLocal:cVesselUid
			oDTFMDataLocal:Rows:Add(newCustomersRow)
		NEXT
		//
		SELF:gvResults:Columns:Clear()
		IF lRegistered
			SELF:gvResults:FocusedRowObjectChanged -= DevExpress.XtraGrid.Views.Base.FocusedRowObjectChangedEventHandler{ SELF, @gvResults_FocusedRowObjectChanged() }		
			lRegistered := FALSE
		ENDIF
		SELF:splitContainerControl1:PanelVisibility := DevExpress.XtraEditors.SplitPanelVisibility.Panel1
		dsLocal:Tables:Add(oDTFMDataLocal)
		SELF:gcResults:DataSource := dsLocal
		SELF:gcResults:DataMember := "Details"
		SELF:gvResults:Columns["VESSEL_UNIQUEID"]:Visible := FALSE 
		SELF:gvResults:Columns["Vessel"]:OptionsColumn:FixedWidth := TRUE 
		SELF:gvResults:Columns["Vessel"]:Width := 100
		SELF:gvResults:Columns["Question"]:OptionsColumn:FixedWidth := TRUE 
		SELF:gvResults:Columns["Question"]:Width :=   400
		//
	CATCH exc AS Exception
		MessageBox.Show(exc:StackTrace, exc:Message)
	FINALLY
		SELF:Cursor := System.Windows.Forms.Cursors.Default
	END TRY
	

RETURN


	
END CLASS