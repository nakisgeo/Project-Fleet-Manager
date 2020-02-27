// ReportsForm_Methods.prg
#Using System.IO
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Collections
#Using DevExpress.XtraGrid.Views.Grid
#Using DevExpress.XtraGrid.Columns
#Using DevExpress.Utils
#Using DevExpress.XtraEditors.Repository
#using DevExpress.XtraPrinting
#Using DevExpress.XtraPrintingLinks


PARTIAL CLASS ReportsForm INHERIT DevExpress.XtraEditors.XtraForm
	PRIVATE oDTReports AS DataTable
	PRIVATE oEditColumn AS GridColumn
	PRIVATE oEditRow AS DataRowView
	PRIVATE cItemTypeValue AS STRING
	PRIVATE oChangedReportColor AS Color
	PRIVATE lPendingDuplicate AS LOGIC
	PRIVATE cUIDtoDuplicate AS STRING
	PRIVATE oMatchIds AS DataTable

METHOD ReportsForm_OnLoad() AS VOID
	oSoftway:ReadFormSettings_DevExpress(SELF, SELF:splitContainerControl_Reports, oMainForm:alForms, oMainForm:alData)
	IF SELF:splitContainerControl_Reports:SplitterPosition <= 0
		SELF:splitContainerControl_Reports:SplitterPosition := 540
	ENDIF

	SELF:GridViewReports:OptionsView:ShowGroupPanel := FALSE
	SELF:GridViewReports:OptionsBehavior:AllowIncrementalSearch := TRUE
	SELF:GridViewReports:OptionsPrint:PrintDetails := TRUE
	SELF:GridViewReports:OptionsSelection:EnableAppearanceFocusedCell := FALSE
	SELF:GridViewReports:OptionsSelection:MultiSelect := FALSE
	SELF:GridViewReports:OptionsView:ColumnAutoWidth := FALSE

	SELF:Fill_CheckedLBCVessels("0")

	SELF:CreateGridReports_Columns()
	SELF:CreateGridReports()
	
	SELF:lPendingDuplicate := FALSE
	SELF:cUIDtoDuplicate := ""
RETURN


METHOD CreateGridReports() AS VOID
	LOCAL cStatement AS STRING

	cStatement:="SELECT REPORT_UID, ReportName, ReportBaseNum, ReportColor, ReportType, FolderName"+;
				" FROM FMReportTypes"+oMainForm:cNoLockTerm+;
				" where ReportBaseNum > 0 ORDER BY ReportBaseNum"
	SELF:oDTReports:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	SELF:oDTReports:TableName:="Reports"
	// Create Primary Key
	oSoftway:CreatePK(SELF:oDTReports, "REPORT_UID")

	SELF:GridReports:DataSource := SELF:oDTReports
RETURN


METHOD CreateGridReports_Columns() AS VOID
LOCAL oColumn AS GridColumn
LOCAL nVisible:=0, nAbsIndex:=0 AS INT

// Freeze column: Set Fixed property

	oColumn:=oMainForm:CreateDXColumn("Report Base Num", "ReportBaseNum",FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 100, SELF:GridViewReports)
    oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    oColumn:AppearanceHeader:Options:UseTextOptions := TRUE
    oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center

	oColumn:=oMainForm:CreateDXColumn("Report Name", "ReportName",		FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 300, SELF:GridViewReports)
	//oColumn:Fixed := FixedStyle.Left
	//
	oColumn:=oMainForm:CreateDXColumn("Report Type", "uReportType",			FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 70, SELF:GridViewReports)
	// ToolTip Samos
	oColumn:ToolTip := "Vessel, Office"
    oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    oColumn:AppearanceHeader:Options:UseTextOptions := TRUE
    oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
	LOCAL oRepositoryItemComboBoxItemType := RepositoryItemComboBox{} AS RepositoryItemComboBox
	oRepositoryItemComboBoxItemType:Items:AddRange(<System.Object>{ "Vessel", "Office" })
    oRepositoryItemComboBoxItemType:Properties:TextEditStyle := DevExpress.XtraEditors.Controls.TextEditStyles.DisableTextEditor
	//Add a repository item to the repository items of grid control
	SELF:GridReports:RepositoryItems:Add(oRepositoryItemComboBoxItemType)
	//Now you can define the repository item as an inplace editor of columns
	oColumn:ColumnEdit := oRepositoryItemComboBoxItemType

	//
	LOCAL repositoryItemColorEdit1 := DevExpress.XtraEditors.Repository.RepositoryItemColorEdit{} AS DevExpress.XtraEditors.Repository.RepositoryItemColorEdit
	oColumn:=oMainForm:CreateDXColumn("Report Color",	"uReportColor",	FALSE, DevExpress.Data.UnboundColumnType.Object, ;
																		nAbsIndex++, nVisible++, 100, SELF:GridViewReports)
	oColumn:ColumnEdit := repositoryItemColorEdit1
	// ToolTip
	oColumn:ToolTip := "Click the cell to change the Report Color"
	//oColumn:ToolTip := "Double-click a cell to change the ReportColor"
	//SELF:Fill_LookUpEdit_ReportColor()
	// Invisible
	oColumn:=oMainForm:CreateDXColumn("REPORT_UID","REPORT_UID",FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																		nAbsIndex++, -1, -1, SELF:GridViewReports)
	oColumn:Visible:=FALSE
	//Self:GridViewReports:ColumnViewOptionsBehavior:Editable:=False
	
	oColumn:=oMainForm:CreateDXColumn("Folder Name", "FolderName",			FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 70, SELF:GridViewReports)
RETURN


METHOD BeforeLeaveRow_Reports(e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.Void
	//IF SELF:lSuspendNotification
	//	RETURN
	//ENDIF

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewReports:GetRow(e:RowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	// Validate
	DO CASE
	CASE oRow:Item["ReportName"]:ToString() == ""
		wb("The 'Report Name' field must be defined")
		e:Allow := FALSE
		RETURN
	ENDCASE

	// EditMode: OFF
	SELF:SetEditModeOff_Common(SELF:GridViewReports)
RETURN


METHOD CustomUnboundColumnData_Reports(e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs) AS VOID
	// Provides data for the UnboundColumns

	IF ! e:IsGetData
		RETURN
	ENDIF

	LOCAL oRow AS DataRow
	LOCAL cField,cValue AS STRING
	DO CASE
	CASE e:Column:FieldName == "uReportColor"
		oRow:=SELF:oDTReports:Rows[e:ListSourceRowIndex]

		LOCAL oColor AS System.Drawing.Color
		oColor := oMainForm:AssignColor(oRow:Item["ReportColor"]:ToString())
		// The Color contains: <A, R, G, B>. The saved Table column has: <R, G, B>
		e:Value := oColor:ToArgb()
	CASE e:Column:FieldName == "uReportType"
		oRow := SELF:oDTReports:Rows[e:ListSourceRowIndex]
		// Remove the leading 'u' from FieldName
		cField := oRow:Item[e:Column:FieldName:Substring(1)]:ToString()
		DO CASE
			CASE cField == "V"
				cValue := "Vessel"

			CASE cField == "O"
				cValue := "Office"

		ENDCASE
		e:Value:=cValue		
		
	ENDCASE
RETURN


METHOD SetEditModeOff_Common(oGridView AS GridView) AS VOID
TRY
	IF oGridView:FocusedColumn <> NULL .AND. oGridView:FocusedColumn:UnboundType == DevExpress.Data.UnboundColumnType.Boolean
		IF ! oGridView:OptionsSelection:EnableAppearanceFocusedCell
			oGridView:OptionsSelection:EnableAppearanceFocusedCell := TRUE
		ENDIF
		oGridView:FocusedColumn:OptionsColumn:AllowEdit := TRUE
		BREAK
	ENDIF

	IF ! oGridView:OptionsSelection:EnableAppearanceFocusedCell
		BREAK
	ENDIF

	oGridView:OptionsSelection:EnableAppearanceFocusedCell := FALSE

	IF SELF:oEditColumn <> NULL
		SELF:oEditColumn:OptionsColumn:AllowEdit := FALSE
		SELF:oEditColumn := NULL
	ENDIF

	IF SELF:oEditRow <> NULL
		SELF:oEditRow := NULL
	ENDIF
CATCH
END TRY

/*// Disable Single-click on Boolean columns - Not required as the EditMode is OFF
if InListExact(Self:GridViewUsers:FocusedColumn:FieldName, "uIsSuperUser", "uMasterUser")
	//Local oValue := Self:GridViewAccounts:GetFocusedValue() as object
	//wb(oValue:ToString())
	Self:GridViewUsers:ShowEditor()
endif*/

RETURN


/*METHOD FocusedRowChanged_Reports(e AS DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventArgs) AS VOID
// Notification Method
	IF SELF:GridViewReports:IsGroupRow(e:FocusedRowHandle)
		RETURN
	ENDIF

	// Get GridRow data into a DataRowView object
	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewReports:GetRow(e:FocusedRowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	SELF:FillListBoxControls_Reports(oRow)
RETURN*/


METHOD Reports_Add() AS VOID

	IF !lPendingDuplicate	
	IF QuestionBox("Do you want to Add a new Report ?", ;
					"Add") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF
	ENDIF
	LOCAL cStatement, cUID AS STRING

	cStatement:="INSERT INTO FMReportTypes (ReportName, ReportColor) VALUES"+;
				" ('_New Report', 0)"
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:Reports_Refresh()
		RETURN
	ENDIF
	cUID:=oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "FMReportTypes", "REPORT_UID")

	SELF:Reports_Refresh()

	LOCAL nFocusedHandle AS INT
	nFocusedHandle:=SELF:GridViewReports:LocateByValue(0, SELF:GridViewReports:Columns["REPORT_UID"], Convert.ToInt32(cUID))
	IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
		RETURN
	ENDIF
	SELF:GridViewReports:ClearSelection()
	SELF:GridViewReports:FocusedRowHandle:=nFocusedHandle
	SELF:GridViewReports:SelectRow(nFocusedHandle)
	IF lPendingDuplicate
		MessageBox.Show("Enter the new report Base Number to start the duplication of items.","Action Pending.")
	ENDIF
	
RETURN

METHOD DuplicateReport() AS VOID
	IF QuestionBox("Do you want to Duplicate the selected Report ?", ;
					"Duplicate") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF
	LOCAL oRow AS DataRowView
	oMatchIds := DataTable{}
	oMatchIds:Columns:Add("prevID",typeof(STRING))
	oMatchIds:Columns:Add("newID",typeof(STRING))
	
	LOCAL nRowHandle := SELF:GridViewReports:FocusedRowHandle AS INT
	oRow:=(DataRowView)SELF:GridViewReports:GetRow(nRowHandle)
	IF oRow == NULL
		RETURN
	ENDIF
	IF oRow["ReportName"]:ToString():ToUpper():StartsWith("MODE")
		wb("You cannot duplicate the System Report: MODE")
		RETURN
	ENDIF
	LOCAL cStatement /*, cExistedValue*/ AS STRING
	LOCAL oDTReportItemsLocal AS DataTable
	cStatement:="SELECT * FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" WHERE REPORT_UID="+oRow:Item["REPORT_UID"]:ToString()
	//cStatement := oSoftway:SelectTop(cStatement)
	//cExistedValue:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "REPORT_UID")
	oDTReportItemsLocal:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	oDTReportItemsLocal:TableName:="Items"
	// Create Primary Key
	oSoftway:CreatePK(oDTReportItemsLocal, "Item_UID")
	IF oDTReportItemsLocal:Rows:Count < 1
		ErrorBox("The current Report contains no Data", ;
					"Duplicate aborded")
		RETURN
	ENDIF
	lPendingDuplicate := TRUE
	cUIDtoDuplicate := oRow:Item["REPORT_UID"]:ToString()
	SELF:Reports_Add()
	/*
	cStatement:="SELECT Max(ReportBaseNum) as Max"+;
				" FROM FMReportTypes"+oMainForm:cNoLockTerm
	TRY
		nMaxReportBaseNum := Convert.ToInt32(oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Max")) 
	CATCH
		RETURN FALSE
	END TRY
	cStatement:="SELECT Max(ItemNo) AS nMax"+;
						" FROM FMReportItems"+oMainForm:cNoLockTerm
	nMaxItemNo := Convert.ToInt32(oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "nMax"))
	
	IF nMaxItemNo>nMaxReportBaseNum+99
		nNewReportBaseNum := nMaxReportBaseNum+1000
	*/
RETURN

METHOD completeDuplication(cReportUID AS STRING,cReportBaseNumber AS STRING) AS LOGIC
		LOCAL cStatement AS STRING
		TRY
			LOCAL oDTReportItemsLocal AS DataTable
			cStatement:="SELECT * FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" WHERE REPORT_UID="+cUIDtoDuplicate+" ORDER BY ItemNo "
			//cStatement := oSoftway:SelectTop(cStatement)
			//cExistedValue:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "REPORT_UID")
			oDTReportItemsLocal:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
			oDTReportItemsLocal:TableName:="Items"
			// Create Primary Key
			oSoftway:CreatePK(oDTReportItemsLocal, "Item_UID")	
			// Check if there will be an overlap on the item numbers
			LOCAL nCountSourceItems := oDTReportItemsLocal:Rows:Count AS INT
			LOCAL nNewReportBaseNumber := convert.ToInt32(cReportBaseNumber) AS INT
			IF !SELF:checkIfNewReportBaseNumberIsValid(nCountSourceItems,nNewReportBaseNumber)
				MessageBox.Show("Duplication aborted. This Base Number will result in an overlap.","Error.")
				RETURN FALSE
			ENDIF
			LOCAL iCount := 0 AS INT
			FOREACH  row AS DataRow IN oDTReportItemsLocal:Rows
			    //TextBox1.Text = row["ImagePath"].ToString()
				SELF:Items_Add(row,cReportBaseNumber,iCount,cReportUID)
				iCount ++
			NEXT
			MessageBox.Show("Finished, "+iCount:ToString()+" item added","Completed.")
			SELF:correctCalculatedField(cReportUID)
		CATCH
			RETURN FALSE
		END TRY
		
RETURN TRUE

METHOD correctCalculatedField(cReportUID AS STRING) AS LOGIC
		LOCAL cStatement AS STRING
		LOCAL cTemp,cSecTemp/*,cThirdTemp*/ AS STRING
		TRY
			LOCAL oDTReportItemsLocal AS DataTable
			cStatement:="SELECT * FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" WHERE REPORT_UID="+cReportUID+" AND CalculatedField IS NOT NULL ORDER BY ItemNo "
			oDTReportItemsLocal:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
			oDTReportItemsLocal:TableName:="Items"
			oSoftway:CreatePK(oDTReportItemsLocal, "Item_UID")	
			//LOCAL nCountSourceItems := oDTReportItemsLocal:Rows:Count AS INT
			LOCAL iCount := 0 AS INT
			FOREACH  row AS DataRow IN oDTReportItemsLocal:Rows
				cTemp := row:Item["CalculatedField"]:ToString():Trim()
				IF  cTemp:length > 0
					FOREACH  secRow AS DataRow IN  oMatchIds:Rows
						cSecTemp := secRow:Item["prevID"]:ToString():Trim()
						IF cTemp:Contains("ID"+cSecTemp)
							cTemp := cTemp:Replace("ID"+cSecTemp,"ID"+secRow:Item["newID"]:ToString():Trim())
							cStatement := "UPDATE FMReportItems SET CalculatedField='"+cTemp+"' WHERE Item_UID="+row:Item["Item_UID"]:ToString()
							oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
						ENDIF
					NEXT
					iCount ++
				ENDIF
				cTemp := ""
			NEXT
			MessageBox.Show("Finished, "+iCount:ToString()+" item added","Completed.")
		CATCH
			RETURN FALSE
		END TRY
		
RETURN TRUE

METHOD checkIfNewReportBaseNumberIsValid(nCountSourceItems AS INT,nNewReportBaseNumber AS INT) AS LOGIC
	TRY
			LOCAL oDTReportItemsLocal AS DataTable
			LOCAL cStatement:="SELECT ReportBaseNum FROM FMReportTypes"+oMainForm:cNoLockTerm+;
						" ORDER BY ReportBaseNum ASC " AS STRING
			//cStatement := oSoftway:SelectTop(cStatement)
			//cExistedValue:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "REPORT_UID")
			oDTReportItemsLocal:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
			oDTReportItemsLocal:TableName:="Reports"
			// Create Primary Key
			oSoftway:CreatePK(oDTReportItemsLocal, "ReportBaseNum")
			FOREACH  row AS DataRow IN oDTReportItemsLocal:Rows
				LOCAL cRowBN := row:Item["ReportBaseNum"]:ToString():trim() AS STRING
				IF cRowBN != NULL .AND. cRowBN:Length>0
					LOCAL nRowBN := convert.ToInt32(cRowBN) AS INT
					IF nRowBN > nNewReportBaseNumber .AND. nRowBN < nCountSourceItems+nNewReportBaseNumber
						RETURN FALSE
					ENDIF
				ENDIF
			NEXT
	CATCH exc AS Exception
			MessageBox.Show(exc:ToString())
			RETURN FALSE
		END TRY
RETURN TRUE

METHOD Items_Add(oRowToAdd AS DataRow,cReportBaseNumber AS STRING,iCount AS INT,cReportUID AS STRING) AS VOID
	//LOCAL cReportName := SELF:LBCReports:GetDisplayItemValue(SELF:LBCReports:SelectedIndex):ToString() AS STRING
	
	LOCAL cStatement AS STRING
	//LOCAL cReportUID := oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "FMReportTypes", "REPORT_UID") AS STRING
	LOCAL nReportBaseNumber := Convert.ToInt32(cReportBaseNumber) AS INT
	LOCAL cNextItemNo := (nReportBaseNumber+iCount):ToString() AS STRING
	
	LOCAL cNewName:= oSoftway:ConvertWildcards(oRowToAdd:Item["ItemName"]:ToString():Trim(),FALSE) AS STRING
	LOCAL cCalculatedField:= oRowToAdd:Item["CalculatedField"]:ToString():Trim() AS STRING
	LOCAL cItemTypeValues := oSoftway:ConvertWildcards(oRowToAdd:Item["ItemTypeValues"]:ToString():Trim(),FALSE) AS STRING
	LOCAL cCat_IUD        := oRowToAdd:Item["CATEGORY_UID"]:ToString():trim() AS STRING
	LOCAL cUnit			  := oSoftway:ConvertWildcards(oRowToAdd:Item["Unit"]:tostring():trim(),FALSE) AS STRING
	
	IF cCat_IUD != NULL .AND. cCat_IUD == ""
		cCat_IUD := "0"
	ENDIF
	LOCAL cItem_Type		  := oRowToAdd:Item["ItemType"]:ToString():Trim()		 AS STRING
	
	LOCAL cSLAA := oRowToAdd:Item["SLAA"]:ToString():Trim() AS STRING
	IF cSLAA != NULL .AND. cSLAA == "False"
		cSLAA := "0"
	ELSEIF cSLAA == NULL
		cSLAA := "0"
	ELSEIF cSLAA == "True"
		cSLAA := "1"
	ENDIF
	
	LOCAL cNotNumbered := oRowToAdd:Item["NotNumbered"]:ToString():Trim() AS STRING
	IF cNotNumbered != NULL .AND. cNotNumbered == "False"
		cNotNumbered := "0"
	ELSEIF cNotNumbered == NULL
		cNotNumbered := "0"
	ELSEIF cNotNumbered == "True"
		cNotNumbered := "1"
	ENDIF
	
	LOCAL cShowOnlyOffice := oRowToAdd:Item["ShowOnlyOffice"]:ToString():Trim() AS string
	IF cShowOnlyOffice != NULL .AND. cShowOnlyOffice == "False"
		cShowOnlyOffice := "0"
	ELSEIF cShowOnlyOffice == NULL
		cShowOnlyOffice := "0"
	ELSEIF cShowOnlyOffice == "True"
		cShowOnlyOffice := "1"
	ENDIF

	cStatement:="INSERT INTO FMReportItems (REPORT_UID, ItemNo, ItemName, ItemType, ExpDays, CATEGORY_UID, ItemTypeValues,CalculatedField,SLAA,ShowOnlyOffice, NotNumbered, Unit ) VALUES"+;
				" ("+cReportUID+", '"+cNextItemNo+"', '"+cNewName+"', '"+cItem_Type+"', 0,"+cCat_IUD+", '"+cItemTypeValues+"','"+cCalculatedField+"',"+cSLAA+","+cShowOnlyOffice+","+cNotNumbered+", '"+cUnit+"' )"
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		//MessageBox.Show(cStatement, "failed")
		RETURN
	ENDIF
	oMatchIds:Rows:Add(oRowToAdd:Item["ItemNo"]:ToString(),cNextItemNo)
	/*LOCAL cUID:=oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "FMReportItems", "ITEM_UID") AS STRING
	Self:Items_Refresh()

	Local nFocusedHandle as int
	nFocusedHandle:=Self:GridViewItems:LocateByValue(0, Self:GridViewItems:Columns["ITEM_UID"], Convert.ToInt32(cUID))
	if nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
		Return
	endif
	Self:GridViewItems:ClearSelection()
	Self:GridViewItems:FocusedRowHandle:=nFocusedHandle
	SELF:GridViewItems:SelectRow(nFocusedHandle)*/
RETURN


METHOD Reports_Edit(oRow AS DataRowView, oColumn AS GridColumn) AS VOID
	IF oRow == NULL
		RETURN
	ENDIF

	LOCAL cField := oColumn:FieldName AS STRING
	IF ! InListExact(cField, "ReportBaseNum", "ReportName", "uReportColor", "uReportType", "FolderName")
		wb("The column '"+oColumn:Caption+"' is ReadOnly")
		RETURN
	ENDIF

	IF InListExact(cField, "ReportBaseNum", "ReportName", "uReportType") .AND. oRow["ReportName"]:ToString():ToUpper():StartsWith("MODE")
		wb("The column '"+oColumn:Caption+"' is ReadOnly for the System Report: "+CRLF+oRow["ReportName"]:ToString())
		RETURN
	ENDIF

	SELF:oEditColumn := oColumn
	SELF:oEditRow := oRow

	SELF:oEditColumn:OptionsColumn:AllowEdit := TRUE
    SELF:GridViewReports:OptionsSelection:EnableAppearanceFocusedCell := TRUE
	SELF:GridViewReports:ShowEditor()
RETURN


METHOD Reports_Delete() AS VOID
	LOCAL oRow AS DataRowView
	LOCAL nRowHandle := SELF:GridViewReports:FocusedRowHandle AS INT
	oRow:=(DataRowView)SELF:GridViewReports:GetRow(nRowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	IF oRow["ReportName"]:ToString():ToUpper():StartsWith("MODE")
		wb("You cannot Delete the System Report: MODE")
		RETURN
	ENDIF

	IF QuestionBox("Do you want to Delete the current Report:"+CRLF+CRLF+;
					oRow:Item["ReportName"]:ToString()+" ?", ;
					"Delete") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	LOCAL cStatement, cExistedValue AS STRING
	cStatement:="SELECT REPORT_UID FROM FMDataPackages"+oMainForm:cNoLockTerm+;
				" WHERE REPORT_UID="+oRow:Item["REPORT_UID"]:ToString()
	cStatement := oSoftway:SelectTop(cStatement)
	cExistedValue:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "REPORT_UID")

	IF cExistedValue <> ""
		ErrorBox("The current Report already Exists in Data", ;
					"Delete aborded")
		RETURN
	ENDIF

	cStatement:="DELETE FROM FMReportTypes"+;
				" WHERE REPORT_UID="+oRow:Item["REPORT_UID"]:ToString()
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ErrorBox("Cannot Delete current row", "Deletion aborted")
		RETURN
	ENDIF

	IF SELF:GridViewReports:DataRowCount == 1
		SELF:oDTReports:Clear()
		RETURN
	ENDIF

	// Stop Notification
	//SELF:lSuspendNotificationReports := TRUE
	IF nRowHandle == 0
		SELF:GridViewReports:MoveNext()
	ELSE
		SELF:GridViewReports:MovePrev()
	ENDIF
	//SELF:lSuspendNotificationReports := FALSE

	LOCAL oDataRow AS DataRow
	oDataRow:=SELF:oDTReports:Rows:Find(oRow:Item["REPORT_UID"]:ToString())
	//wb(oRow:Item["MSG_UNIQUEID"]:ToString(), oDataRow)
	IF oDataRow <> NULL
		//wb(Self:oDTMsg32:Rows:Find(oRow:Item["MsgRefNo"]:ToString()), "Removed")
		SELF:oDTReports:Rows:Remove(oDataRow)
	ENDIF
	
	//Delete the Items of the Deleted Report from FMReportItems
	cStatement:="DELETE FROM FMReportItems"+;
				" WHERE REPORT_UID="+oRow:Item["REPORT_UID"]:ToString()
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ErrorBox("Cannot Delete Report's Items", "Deletion aborted")
		RETURN
	ENDIF

RETURN


METHOD Reports_Save(e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs) AS VOID
LOCAL cStatement, cUID, cField, cValue, cDuplicate AS STRING

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewReports:GetRow(e:RowHandle)

	cUID := oRow:Item["REPORT_UID"]:ToString()

	cField := e:Column:FieldName
	cValue := e:Value:ToString():Trim()

	// Validate cValue
	DO CASE
	CASE InListExact(cField, "ReportName") .AND. cValue:Length > 128
		ErrorBox("The field '"+cField+"' must contain up to 128 characters", "Editing aborted")
		SELF:Reports_Refresh()
		RETURN

	CASE cField == "ReportName" .AND. cValue:Length = 0
		ErrorBox("The field '"+cField+"' cannot be empty", "Editing aborted")
		SELF:Reports_Refresh()
		RETURN

	CASE InListExact(cField, "ReportBaseNum") .AND. cValue:Length > 5
		ErrorBox("The field '"+cField+"' must contain up to 6 characters", "Editing aborted")
		SELF:Reports_Refresh()
		RETURN

	CASE cField == "ReportBaseNum" .AND. cValue <> ""
		// Validate ReportBaseNum
		LOCAL nValue := Convert.ToInt32(cValue) AS INT
		IF nValue % 100 <> 0 .OR. nValue == 1000 .OR. nValue == 2000
			ErrorBox("The field '"+cField+"' must be divided by 100"+CRLF+CRLF+"Valid values are: from 100 up to 9900"+CRLF+CRLF+"(Excluding system reserved values: 1000 and 2000)", "Editing aborted")
			SELF:Reports_Refresh()
			RETURN
		ENDIF
		// Check for duplicates
		cStatement:="SELECT ReportName FROM FMReportTypes"+oMainForm:cNoLockTerm+;
					" WHERE REPORT_UID <> "+cUID+;
					" AND ReportBaseNum='"+cValue+"'"
		cDuplicate:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "ReportName"):Trim()
		IF cDuplicate <> ""
			ErrorBox("The Report Base Num: '"+cValue+"' is already in use by Report: "+cDuplicate, "Editing aborted")
			SELF:Reports_Refresh()
			RETURN
		ENDIF
	ENDCASE

	LOCAL ucField, cReplace AS STRING

	DO CASE
	CASE cField == "ReportBaseNum"
		cValue := cValue:ToUpper()
		cReplace := "'"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"

	CASE cField == "uReportColor"
		ucField := cField
		// Remove the leading 'u'
		cField := cField:Substring(1)
		// The Color contains: <A, R, G, B>. The saved Table column has: <R, G, B>
		cReplace := RGB(SELF:oChangedReportColor:R, SELF:oChangedReportColor:G, SELF:oChangedReportColor:B):ToString()
	
	CASE cField == "uReportType"
		// Remove the leading 'u'
		cField := cField:Substring(1)
		cValue := SELF:cItemTypeValue
		DO CASE
		CASE cValue == "Office"
			cReplace := "'O'"
			cValue := "O"
		CASE cValue == "Vessel"
			cReplace := "'V'"
			cValue := "V"
		ENDCASE

	OTHERWISE
		cReplace := "'"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"
	ENDCASE

	// Update Reports
	cStatement:="UPDATE FMReportTypes SET"+;
				" "+cField+"="+cReplace+;
				" WHERE REPORT_UID="+cUID
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:Reports_Refresh()
		RETURN
	ENDIF

	// Update DataTable and Grid
	LOCAL oDataRow:=SELF:oDTReports:Rows:Find(oRow:Item["REPORT_UID"]:ToString()) AS DataRow
	IF oDataRow == NULL
		ErrorBox("Cannot access current row", "Not changed")
		RETURN
	ENDIF
	IF ucField <> NULL
		//oDataRow:Item[cField]:=cReplace
		//oRow:Item["IO"] := cValue
		SELF:Reports_Refresh()
	ELSE
		oDataRow:Item[cField]:=cValue
	ENDIF
	SELF:oDTReports:AcceptChanges()
	// Invalidates the region occupied by the current View (adds it to the control's update region that will be repainted
	// during the next paint operation), and causes a paint message to be sent to the grid control
	SELF:GridViewReports:Invalidate()
	IF InListExact(cField, "ReportBaseNum") .AND. lPendingDuplicate
		IF SELF:completeDuplication(oRow:Item["REPORT_UID"]:ToString(),cValue)
			lPendingDuplicate := FALSE
			cUIDtoDuplicate := ""
		ENDIF
	ENDIF
	// Update oMainForm:oDTLookUpEdit_StateFlag DataTable
RETURN



METHOD Reports_Refresh() AS VOID
	LOCAL cUID AS STRING

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewReports:GetRow(SELF:GridViewReports:FocusedRowHandle)

	IF oRow <> NULL
		cUID := oRow:Item["REPORT_UID"]:ToString()
	ENDIF

	SELF:CreateGridReports()

	IF oRow <> NULL
		LOCAL col AS DevExpress.XtraGrid.Columns.GridColumn
		LOCAL nFocusedHandle AS INT

		col:=SELF:GridViewReports:Columns["REPORT_UID"]
		nFocusedHandle:=SELF:GridViewReports:LocateByValue(0, col, Convert.ToInt32(cUID))
		IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
			RETURN
		ENDIF

		SELF:GridViewReports:ClearSelection()
		SELF:GridViewReports:FocusedRowHandle:=nFocusedHandle
		SELF:GridViewReports:SelectRow(nFocusedHandle)
	ENDIF	
RETURN


METHOD ManageReportItems() AS VOID
	LOCAL oRow AS DataRowView
	LOCAL nRowHandle := SELF:GridViewReports:FocusedRowHandle AS INT
	oRow:=(DataRowView)SELF:GridViewReports:GetRow(nRowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	LOCAL cRepotName := oRow:Item["ReportName"]:ToString() AS STRING

	LOCAL oItemsForm := ItemsForm{} AS ItemsForm
	oItemsForm:cCallerReportName := cRepotName
	oItemsForm:Show(SELF)
RETURN


METHOD Reports_Print() AS VOID
	SELF:PrintPreviewGridReports()
RETURN


#Region PrintPreview

METHOD PrintPreviewGridReports() AS VOID
	// Check whether the XtraGrid control can be previewed.
	IF ! SELF:GridReports:IsPrintingAvailable
		ErrorBox("The 'DevExpress.XtraPrinting' Library is not found")
		RETURN
	ENDIF

	// Opens the Preview window.
	//Self:GridCompanies:ShowPrintPreview()

	// Create a PrintingSystem component.
	LOCAL oPS := PrintingSystem{} AS DevExpress.XtraPrinting.PrintingSystem
	// Create a link that will print a control.
	LOCAL oLink := PrintableComponentLink{oPS} AS DevExpress.XtraPrinting.PrintableComponentLink
	// Specify the control to be printed.
	oLink:Component := SELF:GridReports
	// Set the paper format.
	oLink:PaperKind := System.Drawing.Printing.PaperKind.A4
	oLink:Landscape:=TRUE
	// Subscribe to the CreateReportHeaderArea event used to generate the report header.
	oLink:CreateReportHeaderArea += CreateAreaEventHandler{SELF, @PrintableComponentLinkReports_CreateReportHeaderArea()}
	// Generate the report.
	oLink:CreateDocument()
	// Hide Send via eMail TooBar Button
	oPS:SetCommandVisibility(PrintingSystemCommand.SendFile, CommandVisibility.None)
	// Show the report.
	oLink:ShowPreview()
RETURN


METHOD PrintableComponentLinkReports_CreateReportHeaderArea(sender AS OBJECT, e AS CreateAreaEventArgs) AS VOID
LOCAL cReportHeader := "Reports - Printed on "+Datetime.Now:ToString(ccDateFormat)+", "+Datetime.Now:ToString("HH:mm:ss")+" - User: "+oUser:UserID AS STRING

	e:Graph:StringFormat := BrickStringFormat{StringAlignment.Center}
	e:Graph:Font := Font{"Tahoma", 14, FontStyle.Bold}

	LOCAL rec := RectangleF{0, 0, e:Graph:ClientPageSize:Width, 50} AS RectangleF
	e:Graph:DrawString(cReportHeader, Color.Black, rec, DevExpress.XtraPrinting.BorderSide.None)
RETURN

#EndRegion


METHOD Fill_CheckedLBCVessels(cReportUID AS STRING) AS VOID
	SELF:CheckedLBCVessels:Items:Clear()

	LOCAL cStatement, cVessel AS STRING
	cStatement:="SELECT DISTINCT Vessels.VESSEL_UNIQUEID, Vessels.VesselName, SupVessels.VslCode"+;
				" FROM Vessels"+oMainForm:cNoLockTerm+;
				" INNER JOIN SupVessels on Vessels.VESSEL_UNIQUEID=SupVessels.VESSEL_UNIQUEID"+;
				"	AND SupVessels.Active=1"+;
				" LEFT OUTER JOIN FMDataPackages ON SupVessels.VESSEL_UNIQUEID=FMDataPackages.VESSEL_UNIQUEID"+;
				" ORDER BY VesselName"
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oSoftway:CreatePK(oDT, "VESSEL_UNIQUEID")

	LOCAL n, nCount := oDT:Rows:Count - 1 AS INT
	LOCAL oCheckedListBoxItem AS DevExpress.XtraEditors.Controls.CheckedListBoxItem
	LOCAL cUID, cVslCode AS STRING
	FOR n:=0 UPTO nCount
		cUID := oDT:Rows[n]:Item["VESSEL_UNIQUEID"]:ToString()
		cVslCode := oDT:Rows[n]:Item["VslCode"]:ToString():Trim()
		IF cVslCode <> "" .AND. oSoftway:StringIsNumeric(cVslCode, "")
			cVslCode := Convert.ToInt64(cVslCode):ToString()
		ENDIF
		cVessel := PadL(cVslCode, 2, " ")+" "+oDT:Rows[n]:Item["VesselName"]:ToString()
		oCheckedListBoxItem := DevExpress.XtraEditors.Controls.CheckedListBoxItem{Convert.ToInt32(cUID), cVessel}
		
		cStatement:="SELECT REPORT_UID FROM FMReportTypesVessel"+oMainForm:cNoLockTerm+;
					" WHERE REPORT_UID="+cReportUID+;
					" AND VESSEL_UNIQUEID="+cUID
		//WB(cStatement)
		IF oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "REPORT_UID") <> ""
			oCheckedListBoxItem:CheckState := CheckState.Checked
		ENDIF
		SELF:CheckedLBCVessels:Items:Add(oCheckedListBoxItem)
	NEXT
RETURN


METHOD SelectedVesselCheckedChanged(e AS DevExpress.XtraEditors.Controls.ItemCheckEventArgs) AS VOID
	LOCAL oRow AS DataRowView
	oRow := (DataRowView)SELF:GridViewReports:GetFocusedRow()
	IF oRow == NULL
		RETURN
	ENDIF

	// Update FMUserVessels Table 
	LOCAL cStatement, cReportUID, cUID AS STRING
	cReportUID := oRow["REPORT_UID"]:ToString()
	IF cReportUID == "7" .AND. SELF:CheckedLBCVessels:Items[e:Index]:CheckState == CheckState.Unchecked
		WB("Can not change this report.")
		SELF:CheckedLBCVessels:Items[e:Index]:CheckState := CheckState.Checked
		RETURN
	ELSEIF cReportUID == "7"  .AND. SELF:CheckedLBCVessels:Items[e:Index]:CheckState == CheckState.Checked
		RETURN
	ENDIF
	cUID := SELF:CheckedLBCVessels:Items[e:Index]:Value:ToString()

	IF e:State == CheckState.Checked
		cStatement:="INSERT INTO FMReportTypesVessel (REPORT_UID, VESSEL_UNIQUEID)"+;
					" SELECT "+cReportUID+","+cUID+;
					IIF(symServer == #MySQL, " FROM GlobalSettings", "")+;
					" WHERE NOT EXISTS"+;
					" (SELECT REPORT_UID FROM FMReportTypesVessel"+;
					"	WHERE REPORT_UID="+cReportUID+;
					"	AND VESSEL_UNIQUEID="+cUID+")"
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
	ELSE
		cStatement:="DELETE FROM FMReportTypesVessel"+;
					" WHERE REPORT_UID="+cReportUID+;
					" AND VESSEL_UNIQUEID="+cUID
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
	ENDIF
RETURN

END CLASS
