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
#using DevExpress.Utils
#USING DevExpress.XtraGrid.Views.Grid

PARTIAL CLASS TableReportsSelectionForm INHERIT System.Windows.Forms.Form


PRIVATE METHOD btnReportPerCategoryVessel_Clicked(iChoose as INT) AS VOID

	txtProgress:Text :=""

	LOCAL cFieldNameToCheckLocal := self:txtFieldNameToCheck:Text AS STRING
	
	IF SELF:DateFrom:DateTime > SELF:DateTo:DateTime
			wb("Invalid dates")
			SELF:DateTo:Focus()
			RETURN
	ENDIF
	local cStatement as String
	
	


	txtProgress:Text := DateTime.Now:ToString("HH:mm:ss")+ ": Started.." + CRLF + txtProgress:Text
	System.Windows.Forms.Application.DoEvents()

	LOCAL dStart := SELF:DateFrom:DateTime AS DateTime
	LOCAL dEnd := SELF:DateTo:DateTime AS DateTime

	//Load the Report Items
	cStatement:="SELECT FMReportItems.*, FMItemCategories.Description AS Category "+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" LEFT OUTER JOIN FMItemCategories ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
				" WHERE Report_UID="+cMyReportUID+" AND FMReportItems.ItemName='"+cFieldNameToCheckLocal+"' "+;
				" AND FMReportItems.ItemType='X' "+;
				" ORDER BY FMItemCategories.SortOrder, ItemNo"
				
	LOCAL oDTReportItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

	txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": FMReportItems Loaded..." + CRLF + txtProgress:Text
	System.Windows.Forms.Application.DoEvents()


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

	SELF:createExcelFindingsPerCategory(oDTReportItems,dStart,dEnd, lAllVesselsLocal,iChoose)

RETURN


PRIVATE METHOD createExcelFindingsPerCategory(oDTReportItems AS DataTable, dStart AS Datetime, dEnd AS DateTime, lAllVessels := FALSE AS LOGIC,iChoose AS INT) AS VOID
	LOCAL lIncludeStatistics, lExcel AS LOGIC
	LOCAL lExactMatch := TRUE AS LOGIC
	LOCAL nDataStartOnColumn := 3 AS INT
	LOCAL charSpl1 := (char)169 AS Char
	LOCAL charSpl2 := (char)168 AS Char		

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

	LOCAL cVesselsSQL := "" as String
	IF(!lAllVessels)
		cVesselsSQL := " AND FMDataPackages.VESSEL_UNIQUEID In ("+SELF:cVesselUID+") "
	ENDIF

	LOCAL cOrderBy := "" AS STRING
	IF iChoose==1
		cOrderBy := " ORDER BY Vessels.VesselName Asc " 
	ELSEIF iChoose == 2
		cOrderBy := " ORDER BY Username Asc " 
	ENDIF

	cStatement:="SELECT FMDataPackages.PACKAGE_UID, DateTimeGMT, GmtDiff, Username, Vessels.VesselName"+;
				" FROM FMDataPackages"+;
				" Inner Join Vessels on FMDataPackages.VESSEL_UNIQUEID = Vessels.VESSEL_UNIQUEID "+;
				" WHERE FMDataPackages.DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
				cVesselsSQL+;
				" AND  FMDataPackages.Visible=1 AND FMDataPackages.REPORT_UID="+SELF:cMyReportUID+;
				cExtraStatusStatement+cOrderBy;
				

	SELF:oDTPackages := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	IF SELF:oDTPackages == NULL || SELF:oDTPackages:Rows:Count == 0
		MessageBox.Show("No Data found for these days !")
		RETURN
	ENDIF	
	txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": "+SELF:oDTPackages:Rows:Count:ToString()+" Report(s) Found..." + CRLF + txtProgress:Text
	System.Windows.Forms.Application.DoEvents()

	//Vazw se ena array-list ta diaforetika vessels pou exo
	LOCAL oALVessels := ArrayList{} AS ArrayList
	LOCAL cVesselName := "" AS STRING

	LOCAL cFile AS STRING
	
	IF iChoose==1
		FOREACH oTempDataRow AS DataRow IN SELF:oDTPackages:Rows
			IF cVesselName ==""
				cVesselName := oTempDataRow:Item["VesselName"]:ToString()
				oALVessels:Add(cVesselName)
			ELSE
				LOCAL cTempVesselName := oTempDataRow:Item["VesselName"]:ToString() AS STRING
				IF cTempVesselName == cVesselName
					LOOP
				ELSE
					oALVessels:Add(cTempVesselName)
					cVesselName := cTempVesselName
				ENDIF
			ENDIF
		NEXT
		cFile := cTempDocDir+"\CategoriesPerVesselReport_on_"+Datetime.Now:ToString("dd_MM_yyyy__HH_mm_ss")+".xls"	//".XLSX"
	ELSEIF iChoose==2
		FOREACH oTempDataRow AS DataRow IN SELF:oDTPackages:Rows
			IF cVesselName ==""
				cVesselName := oTempDataRow:Item["Username"]:ToString()
				oALVessels:Add(cVesselName)
			ELSE
				LOCAL cTempVesselName := oTempDataRow:Item["Username"]:ToString() AS STRING
				IF cTempVesselName == cVesselName
					LOOP
				ELSE
					oALVessels:Add(cTempVesselName)
					cVesselName := cTempVesselName
				ENDIF
			ENDIF
		NEXT
		cFile := cTempDocDir+"\CategoriesPerSupentReport_on_"+Datetime.Now:ToString("dd_MM_yyyy__HH_mm_ss")+".xls"	//".XLSX"
	ENDIF

	//Vazw se ena array-list ta diaforetika Categories pou exo
	LOCAL oALCategories := ArrayList{} AS ArrayList
	LOCAL cCategoryName := "" AS STRING
	FOREACH oTempDataRow AS DataRow IN oDTReportItems:Rows	
		IF cCategoryName ==""
			oALCategories:Add(oTempDataRow:Item["Category_UID"]:ToString()+charSpl1:ToString()+oTempDataRow:Item["Category"]:ToString())
			cCategoryName := oTempDataRow:Item["Category"]:ToString()
		ELSE
			LOCAL cTempcCategoryName := oTempDataRow:Item["Category"]:ToString() AS STRING
			IF cTempcCategoryName == cCategoryName
				LOOP
			ELSE
				oALCategories:Add(oTempDataRow:Item["Category_UID"]:ToString()+charSpl1:ToString()+oTempDataRow:Item["Category"]:ToString())
				cCategoryName := cTempcCategoryName
			ENDIF
		ENDIF
	NEXT


	LOCAL dsLocal := DataSet{} AS DataSet
	LOCAL oDTFMDataLocal := DataTable{} AS DataTable
	oDTFMDataLocal:TableName := "Data"
    oDTFMDataLocal:Columns:Add("Category", typeof(STRING))
    oDTFMDataLocal:Columns:Add("Average Findings", typeof(Double))

	FOREACH cTempVesselName AS String IN oALVessels
		oDTFMDataLocal:Columns:Add(cTempVesselName, typeof(Double))
	NEXT
	
	SELF:Cursor := System.Windows.Forms.Cursors.WaitCursor

	LOCAL oldCI AS System.Globalization.CultureInfo
	oldCI:=System.Threading.Thread.CurrentThread:CurrentCulture
	IF lExcel
		System.Threading.Thread.CurrentThread:CurrentCulture:=System.Globalization.CultureInfo{"en-GB"}
	ELSE
		System.Threading.Thread.CurrentThread:CurrentCulture:=System.Globalization.CultureInfo{"en-GB"}
	ENDIF
	TRY
		/*
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
		*/		

		LOCAL nRow :=0, nCol := nDataStartOnColumn, iCountCategories:=0 AS INT
		LOCAL cPackageUID, cItemUID, cData AS STRING
		LOCAL oItemRows AS DataRow[]
		LOCAL cMemo AS STRING
		LOCAL cItemsArray AS STRING[]
		LOCAL cItemsTemp  AS STRING[]
		LOCAL oDTFMData := DataTable{} AS DataTable		

		LOCAL iPrct, iCategoryFindings:=0, iVesselFindings:=0, iTotalFindings:=0 AS Double
		LOCAL iCountTotalInspections :=0, iCountVesselInspections:=0 AS Double
		LOCAL cPrct AS STRING
		LOCAL rFindingsPerInspection AS FLOAT
		
		//Ftiaxno thn proth kolona me ta Description ton kathgorion
		//kai vazo tis seires ston pinaka ton apotelesmaton
		FOREACH cCategoryItem AS STRING IN oALCategories
			LOCAL newCustomersRow := oDTFMDataLocal:NewRow() AS DataRow
			newCustomersRow[0] := cCategoryItem:Substring(cCategoryItem:LastIndexOf(charSpl1)+1)		
			oDTFMDataLocal:Rows:Add(newCustomersRow)
		NEXT	
		//Vazo th seira gia ta totals
		LOCAL newCustomersRow := oDTFMDataLocal:NewRow() AS DataRow
		newCustomersRow[0] := "Total Findings"		
		oDTFMDataLocal:Rows:Add(newCustomersRow)
		//Vazo th seira gia ta inspections
		newCustomersRow := oDTFMDataLocal:NewRow()
		newCustomersRow[0] := "Number of inspections"		
		oDTFMDataLocal:Rows:Add(newCustomersRow)


		//Tha parw ena mia mia tis katigories kai tha ypologiso ta findings ana karavi, dhladh tha ftiaxo tis grammes tou grid mia mia 
		FOREACH cCategoryItem AS STRING IN oALCategories
			LOCAL cCategoryUIDTemp := cCategoryItem:Substring(0,cCategoryItem:LastIndexOf(charSpl1))

			
			txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": Started Checking for "+cCategoryItem:Substring(cCategoryItem:LastIndexOf(charSpl1)+1)+ CRLF + txtProgress:Text
			System.Windows.Forms.Application.DoEvents()

			oItemRows := oDTReportItems:Select("Category_Uid="+cCategoryUIDTemp)
			LOCAL iCountColumnsTemp := 3 AS INT
			cVesselName := ""
			iCategoryFindings:=0
			iCountVesselInspections :=0
			FOREACH oTempDatapackageRow AS DataRow IN SELF:oDTPackages:Rows
				cPackageUID := oTempDatapackageRow:Item["PACKAGE_UID"]:ToString()
				LOCAL cTempVesselName AS STRING
				IF iChoose==1
					cTempVesselName := oTempDatapackageRow:Item["VesselName"]:ToString()
				ELSEIF iChoose==2
					cTempVesselName := oTempDatapackageRow:Item["Username"]:ToString()
				ENDIF
				IF cTempVesselName <> cVesselName
					IF cVesselName<>""
						//add the findings to the datatable						
						oDTFMDataLocal:Rows[iCountCategories]:Item[cVesselName] := iVesselFindings
						//add the previous finding to the category
						iCategoryFindings += iVesselFindings
						//reset the vessel findings
						iVesselFindings := 0
						
					ENDIF
					cVesselName := cTempVesselName
					iCountVesselInspections :=0
				ELSE
					iCountVesselInspections++
				ENDIF

				FOREACH oTempItemRow AS DataRow IN oItemRows
					cStatement:="SELECT  FMData.ITEM_UID, "+;
								" FMData.Data "+;
								" FROM FMData"+oMainForm:cNoLockTerm+;
								" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
								" WHERE FMDataPackages.PACKAGE_UID="+cPackageUID+;
								" AND FMData.ITEM_UID = "+oTempItemRow:Item["Item_UID"]:ToString()
					oDTFMData:Clear()	
					oDTFMData := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
					oDTFMData:TableName := "FMData"
					LOCAL lCompare as LOGIC
					FOREACH oRowDataTemp AS DataRow IN oDTFMData:Rows
							IF lExactMatch
								IF oRowDataTemp["Data"]:ToString():Trim():Equals(cmbStatus:Text:Trim())
									lCompare := TRUE
								ELSE
									lCompare := FALSE
								ENDIF
							ELSE
								IF oRowDataTemp["Data"]:ToString():Contains(cmbStatus:Text:Trim())
									lCompare := TRUE
								ELSE
									lCompare := FALSE
								ENDIF
							ENDIF

							IF lCompare
								iVesselFindings++
								/*IF cLinesUIDsLocal == ""
									cLinesUIDsLocal := cPACKAGE_UIDLocal+":"+oTempUIDLocal:cMyLineUIDs
								ELSE
									cLinesUIDsLocal += "-" + cPACKAGE_UIDLocal+":"+ oTempUIDLocal:cMyLineUIDs
								ENDIF*/
							ENDIF
					NEXT
				NEXT
			//Set the vessel number of inspections
			oDTFMDataLocal:Rows[oALCategories:Count+1]:Item[cVesselName] := (iCountVesselInspections+1)//:ToString()
			NEXT
			//An eimai sto teleutaio vessel
			IF cVesselName == oALVessels[oALVessels:Count-1]:ToString()
						//add the findings to the datatable						
						oDTFMDataLocal:Rows[iCountCategories]:Item[cVesselName] := iVesselFindings//:ToString()
						//add the previous finding to the category
						iCategoryFindings += iVesselFindings
						//reset the vessel findings
						iVesselFindings := 0
						//set the new vessel
			ENDIF
			//Set the Category findings 
			oDTFMDataLocal:Rows[iCountCategories]:Item[1] := iCategoryFindings//:ToString()
			iTotalFindings += iCategoryFindings
			iCountCategories++
			txtProgress:Text := Datetime.Now:ToString("HH:mm:ss")+ ": Finished Checking for "+cCategoryItem:Substring(cCategoryItem:LastIndexOf(charSpl1)+1)+ CRLF + txtProgress:Text
			System.Windows.Forms.Application.DoEvents()
		NEXT
		//Set the Total findings
		oDTFMDataLocal:Rows[iCountCategories]:Item[1] := iTotalFindings//:ToString()
		//Set the Total Inspections
		FOREACH cTempVesselName AS STRING IN oALVessels
			iCountTotalInspections += Convert.ToDouble(oDTFMDataLocal:Rows[oALCategories:Count+1]:Item[cTempVesselName]:ToString())
		NEXT
		oDTFMDataLocal:Rows[iCountCategories+1]:Item[1] := iCountTotalInspections//:ToString()
		//Set the Vessel Totals		
		FOREACH cTempVesselName AS STRING IN oALVessels
			LOCAL iMakeLoops := 0 AS INT
			iVesselFindings := 0
			WHILE iMakeLoops< oALCategories:Count
				iVesselFindings += Convert.ToDouble(oDTFMDataLocal:Rows[iMakeLoops]:Item[cTempVesselName]:ToString())
				iMakeLoops++
			ENDDO
			oDTFMDataLocal:Rows[iMakeLoops]:Item[cTempVesselName] := iVesselFindings//:ToString()
		NEXT
		//Make tha averages on all vessels
		FOREACH cTempVesselName AS STRING IN oALVessels
			LOCAL iMakeLoops := 0 AS INT
			LOCAL fVesselFindings := Convert.ToDouble(oDTFMDataLocal:Rows[oALCategories:Count]:Item[cTempVesselName]), fCategoryFindings:=0 AS Double
			LOCAL fVesselInspections := Convert.ToDouble(oDTFMDataLocal:Rows[oALCategories:Count+1]:Item[cTempVesselName]) AS Double
			WHILE iMakeLoops< oALCategories:Count+1
				fCategoryFindings := Convert.ToDouble(oDTFMDataLocal:Rows[iMakeLoops]:Item[cTempVesselName])/fVesselInspections
				oDTFMDataLocal:Rows[iMakeLoops]:Item[cTempVesselName] := fCategoryFindings:ToString()
				iMakeLoops++
			ENDDO
		NEXT
		//Make the averages on the totals
		LOCAL iMakeLoops := 0 AS INT
		LOCAL fTotalFindings := Convert.ToDouble(iTotalFindings), fCategoryFindings:=0 AS Double
		LOCAL fTotalInspections := Convert.ToDouble(iCountTotalInspections) AS Double
		WHILE iMakeLoops< oALCategories:Count+1
				fCategoryFindings := Convert.ToDouble(oDTFMDataLocal:Rows[iMakeLoops]:Item[1])/fTotalInspections
				oDTFMDataLocal:Rows[iMakeLoops]:Item[1] := fCategoryFindings:ToString()
				iMakeLoops++
		ENDDO

		

		SELF:gcResults:DataSource := NULL
		SELF:gvResults:Columns:Clear()
		IF lRegistered
			SELF:gvResults:FocusedRowObjectChanged -= DevExpress.XtraGrid.Views.Base.FocusedRowObjectChangedEventHandler{ SELF, @gvResults_FocusedRowObjectChanged() }		
			lRegistered := FALSE
		ENDIF
		SELF:splitContainerControl1:PanelVisibility := DevExpress.XtraEditors.SplitPanelVisibility.Panel1

		dsLocal:Tables:Add(oDTFMDataLocal)
		SELF:gcResults:DataSource := dsLocal
        SELF:gcResults:DataMember := "Data"

		iMakeLoops := 1
		WHILE iMakeLoops<oALVessels:Count+2
			SELF:gvResults:Columns[iMakeLoops]:DisplayFormat:FormatType := FormatType.Numeric
            SELF:gvResults:Columns[iMakeLoops]:DisplayFormat:FormatString := "n2"
			iMakeLoops++
		ENDDO
		
		SELF:gcResults:ForceInitialize()		
		
		IF lExcel
			// Create a PrintingSystem component. 
			//LOCAL ps := DevExpress.XtraPrinting.PrintingSystem{} AS DevExpress.XtraPrinting.PrintingSystem
			// Create a link that will print a control. 
			//LOCAL link :=  DevExpress.XtraPrinting.PrintableComponentLink{ps} AS DevExpress.XtraPrinting.PrintableComponentLink 
			//link:CreateReportHeaderArea += DevExpress.XtraPrinting.CreateAreaEventHandler{self, @printableComponentLink1_CreateReportHeaderArea()}
			//link:Component := gcResults
			//link:PrintingSystem:ExportToXls(cFile)
			gcResults:ExportToXls(cFile)
			TRY
				LOCAL oProcessInfo:=ProcessStartInfo{cFile} AS ProcessStartInfo
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

private method printableComponentLink1_CreateReportHeaderArea(sender as object,e as DevExpress.XtraPrinting.CreateAreaEventArgs) as void
            local brick as DevExpress.XtraPrinting.TextBrick
            brick := e:Graph:DrawString("My Report", Color.Navy, RectangleF{0, 0, 500, 40}, DevExpress.XtraPrinting.BorderSide.None)
            brick:Font := System.Drawing.Font{"Tahoma", 16}
            brick:StringFormat := DevExpress.XtraPrinting.BrickStringFormat{StringAlignment.Center}
return


END CLASS