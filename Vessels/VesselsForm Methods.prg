// VesselsForm_Methods.prg
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


PARTIAL CLASS VesselsForm INHERIT DevExpress.XtraEditors.XtraForm
	PRIVATE oDTVessels, oDTCrewVessels as DataTable
	//PRIVATE lSuspendNotification AS LOGIC
	PRIVATE oEditColumn AS GridColumn
	PRIVATE oEditRow AS DataRowView
	PRIVATE cFleetValue, cFleetText AS STRING

METHOD VesselsForm_OnLoad() AS VOID
	oSoftway:ReadFormSettings_DevExpress(SELF, NULL, oMainForm:alForms, oMainForm:alData)

	//SELF:GridViewVessels:OptionsView:ShowGroupPanel := FALSE
	SELF:GridViewVessels:OptionsBehavior:AllowIncrementalSearch := TRUE
	SELF:GridViewVessels:OptionsPrint:PrintDetails := TRUE
	SELF:GridViewVessels:OptionsSelection:EnableAppearanceFocusedCell := FALSE
	SELF:GridViewVessels:OptionsSelection:MultiSelect := False
	SELF:GridViewVessels:OptionsView:ColumnAutoWidth := FALSE

	SELF:CreateGridVessels_Columns()
	
	SELF:checkForCrewOwnedVessels()
	
	SELF:CreateGridVessels()
RETURN


METHOD CreateGridVessels() AS VOID
	LOCAL cStatement AS STRING

	cStatement:="SELECT SupVessels.Active, Vessels.VESSEL_UNIQUEID, Vessels.VesselName, Vessels.Alias, SupVessels.VslCode, SupVessels.PropellerPitch,"+;
				" SupVessels.FLEET_UID, EconFleet.Description AS Fleet"+;
				" FROM Vessels"+oMainForm:cNoLockTerm+;
				" INNER JOIN SupVessels ON SupVessels.VESSEL_UNIQUEID=VESSELS.VESSEL_UNIQUEID"+;
				" LEFT OUTER JOIN EconFleet ON EconFleet.FLEET_UID=SupVessels.FLEET_UID"+;
				" ORDER BY VesselName"
	SELF:oDTVessels:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	Self:oDTVessels:TableName:="Vessels"
	// Create Primary Key
	oSoftway:CreatePK(Self:oDTVessels, "VESSEL_UNIQUEID")

	SELF:GridVessels:DataSource := SELF:oDTVessels
RETURN

METHOD checkForCrewOwnedVessels() AS VOID
	LOCAL cStatement AS STRING
	LOCAL oSupVessels AS DataTable
	LOCAL lFound := false as LOGIC

IF oSoftway:TableExists(oMainForm:oGFH,  oMainForm:oConn, "CrewVessels")
	cStatement:="SELECT VESSEL_UNIQUEID, Active FROM CrewVessels WHERE Own = 1"
	SELF:oDTCrewVessels:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	Self:oDTCrewVessels:TableName:="CrewVessels"
	// Create Primary Key
	oSoftway:CreatePK(SELF:oDTCrewVessels, "VESSEL_UNIQUEID")
	
	cStatement:="SELECT VESSEL_UNIQUEID FROM SupVessels"
	oSupVessels:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	oSupVessels:TableName:="SupVessels"
	// Create Primary Key
	oSoftway:CreatePK(oSupVessels, "VESSEL_UNIQUEID")
	
	local iCount := 0 as INT
	//SELF:GridVessels:DataSource := SELF:oDTVessels	
	FOREACH  rowCrew AS DataRow IN SELF:oDTCrewVessels:Rows
				lFound:= false
				FOREACH  rowSup AS DataRow IN oSupVessels:Rows
					IF rowCrew:Item["VESSEL_UNIQUEID"]:toString() == rowSup:Item["VESSEL_UNIQUEID"]:tostring()
						lFound := true
					ENDIF
				NEXT
				IF ! lFound
					cStatement:="INSERT INTO SupVessels (VESSEL_UNIQUEID , Active)"+;
					" VALUES ("+rowCrew:Item["VESSEL_UNIQUEID"]:toString()+",'"+rowCrew:Item["Active"]:toString()+"')"
					 IF !oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
						LOOP
					 ENDIF
					 iCount++
				ENDIF
	NEXT
	IF iCount > 0
		MessageBox.Show("Added "+iCount:ToString()+" Owned Vessel.")
	ENDIF
	SELF:Vessels_Refresh()
ENDIF
RETURN

METHOD CreateGridVessels_Columns() AS VOID
LOCAL oColumn AS GridColumn
Local nVisible:=0, nAbsIndex:=0 as int

// Freeze column: Set Fixed property

	oColumn:=oMainForm:CreateDXColumn("Active", "Active",				False, DevExpress.Data.UnboundColumnType.Boolean, ;
																		nAbsIndex++, nVisible++, 50, Self:GridViewVessels)
	//oColumn:UnboundExpression:="Active"
	//oColumn:Fixed := FixedStyle.Left
	// ToolTip
	oColumn:ToolTip := "The inactive Vessels are ignored"

	oColumn:=oMainForm:CreateDXColumn("Vessel Code", "VslCode",			FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 70, SELF:GridViewVessels)
    oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    oColumn:AppearanceHeader:Options:UseTextOptions := TRUE
    oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center

	oColumn:=oMainForm:CreateDXColumn("Vessel Name", "VesselName",		FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 200, SELF:GridViewVessels)
	//oColumn:Fixed := FixedStyle.Left

	oColumn:=oMainForm:CreateDXColumn("Fleet", "uFleet",				FALSE, DevExpress.Data.UnboundColumnType.Object, ;
																		nAbsIndex++, nVisible++, 150, SELF:GridViewVessels)
	// ToolTip
	oColumn:ToolTip := "Select a Vessel's Fleet"
    //oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    //oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Far
    //oColumn:AppearanceHeader:Options:UseTextOptions := TRUE
    //oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
	SELF:Fill_Fleet(oColumn)

	oColumn:=oMainForm:CreateDXColumn("PropellerPitch", "PropellerPitch",FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																		nAbsIndex++, nVisible++, 90, SELF:GridViewVessels)

	oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    oColumn:AppearanceHeader:Options:UseTextOptions := TRUE
    oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center

	oColumn:=oMainForm:CreateDXColumn("Alias", "Alias",		FALSE, DevExpress.Data.UnboundColumnType.String, ;
															nAbsIndex++, nVisible++, 200, SELF:GridViewVessels)
	

	// Invisible
	oColumn:=oMainForm:CreateDXColumn("VESSEL_UNIQUEID","VESSEL_UNIQUEID",FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																		nAbsIndex++, -1, -1, SELF:GridViewVessels)
	oColumn:Visible:=FALSE
	
	
	//Self:GridViewVessels:ColumnViewOptionsBehavior:Editable:=False
RETURN


METHOD Fill_Fleet(oColumn AS GridColumn) AS VOID
	LOCAL oRepositoryItemComboBoxItemType := RepositoryItemComboBox{} AS RepositoryItemComboBox
	//oRepositoryItemComboBoxItemType:Items:AddRange(<System.Object>{ "Boolean", "ComboBox", "Coordinate", "DateTime", "Number", "Text", "Text multiline" })
	
	LOCAL cStatement AS STRING
	cStatement:="SELECT FLEET_UID, Description FROM EconFleet"+oMainForm:cNoLockTerm+;
				" UNION SELECT 0 AS FLEET_UID, ' ' AS Description"+;
				" ORDER BY Description"
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	LOCAL oFleetComboBoxItem AS FleetComboBoxItem
	FOREACH oRow AS DataRow IN oDT:Rows
		oFleetComboBoxItem := FleetComboBoxItem{oRow}
		oRepositoryItemComboBoxItemType:Items:Add(oFleetComboBoxItem)
	NEXT
	
    oRepositoryItemComboBoxItemType:Properties:TextEditStyle := DevExpress.XtraEditors.Controls.TextEditStyles.DisableTextEditor
	//Add a repository item to the repository items of grid control
	SELF:GridVessels:RepositoryItems:Add(oRepositoryItemComboBoxItemType)
	//Now you can define the repository item as an inplace editor of columns
	oColumn:ColumnEdit := oRepositoryItemComboBoxItemType
RETURN


METHOD BeforeLeaveRow_Vessels(e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.Void
	//IF SELF:lSuspendNotification
	//	RETURN
	//ENDIF

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewVessels:GetRow(e:RowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	//// Validate
	//IF ! SELF:ValidateVessels()
	//	e:Allow := FALSE
	//	RETURN
	//ENDIF

	// EditMode: OFF
	SELF:SetEditModeOff_Common(SELF:GridViewVessels)
RETURN


METHOD CustomUnboundColumnData_Vessels(e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs) AS VOID
// Provides data for the UnboundColumns
	IF ! e:IsGetData
		RETURN
	ENDIF

	LOCAL oRow AS DataRow

	DO CASE
		CASE e:Column:FieldName == "uFleet"
			oRow := SELF:oDTVessels:Rows[e:ListSourceRowIndex]
			// Remove the leading 'u' from FieldName
			//cField := oRow:Item[e:Column:FieldName:Substring(1)]:ToString()
			e:Value := oRow["Fleet"]:ToString()
	ENDCASE
RETURN


METHOD SetEditModeOff_Common(oGridView AS GridView) AS VOID
TRY
	IF oGridView:FocusedColumn <> NULL .and. oGridView:FocusedColumn:UnboundType == DevExpress.Data.UnboundColumnType.Boolean
		IF ! oGridView:OptionsSelection:EnableAppearanceFocusedCell
			oGridView:OptionsSelection:EnableAppearanceFocusedCell := True
		endif
		oGridView:FocusedColumn:OptionsColumn:AllowEdit := True
		Break
	endif

	if ! oGridView:OptionsSelection:EnableAppearanceFocusedCell
		Break
	endif

	oGridView:OptionsSelection:EnableAppearanceFocusedCell := False

	if Self:oEditColumn <> NULL
		Self:oEditColumn:OptionsColumn:AllowEdit := False
		Self:oEditColumn := NULL
	endif

	if Self:oEditRow <> NULL
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


/*METHOD FocusedRowChanged_Vessels(e AS DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventArgs) AS VOID
// Notification Method
	IF SELF:GridViewVessels:IsGroupRow(e:FocusedRowHandle)
		RETURN
	ENDIF

	// Get GridRow data into a DataRowView object
	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewVessels:GetRow(e:FocusedRowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	SELF:FillListBoxControls_Vessels(oRow)
RETURN*/


//METHOD ValidateVessels() AS LOGIC
//	LOCAL oRow AS DataRowView
//	oRow:=(DataRowView)SELF:GridViewVessels:GetRow(SELF:GridViewVessels:FocusedRowHandle)
//	IF oRow == NULL
//		RETURN TRUE
//	ENDIF

//	// Validate Dep
//	IF SELF:LVVisible_Vessels:Items:Count == 0 //.and. ! oRow:Item["Dep"]:ToString():Contains("1")
//		wb("The UserGroup must contain at least one User"+CRLF+CRLF+;
//			"Please Add a new User or Delete the Group")
//		RETURN FALSE
//	ENDIF
//RETURN TRUE

METHOD Vessels_Add() AS VOID
	IF QuestionBox("Do you want to create a new Vessel ?", ;
					"Add new") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	LOCAL cStatement, cUID  AS STRING
	LOCAL oAddHiddenVesselsForm:=AddHiddenVesselsForm{} AS AddHiddenVesselsForm

	oAddHiddenVesselsForm:oGFH:=oMainForm:oGFH
	oAddHiddenVesselsForm:oConn:=oMainForm:oConn
	oAddHiddenVesselsForm:cExcludedTable:="SupVessels"
	oAddHiddenVesselsForm:oSoftway:=oSoftway
	oAddHiddenVesselsForm:ShowDialog()
	IF oAddHiddenVesselsForm:DialogResult <> DialogResult.Yes
	   RETURN
	ENDIF

	cUID := oAddHiddenVesselsForm:cUID

	// Add record into SNPVessels
	cStatement:="INSERT INTO SupVessels (VESSEL_UNIQUEID)"+;
					" VALUES ("+cUID+")"
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:Vessels_Refresh()
		RETURN
	ENDIF
	//cUID:=oSoftway:GetLastInsertedIdentityFromScope(SELF:oGFH, SELF:oConn, "PosDynVessels", "VESSEL_UNIQUEID")

	SELF:Vessels_Refresh()

	LOCAL nFocusedHandle AS INT
	nFocusedHandle:=SELF:GridViewVessels:LocateByValue(0, SELF:GridViewVessels:Columns["VESSEL_UNIQUEID"], Convert.ToInt32(cUID))
	IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
		RETURN
	ENDIF
	SELF:GridViewVessels:ClearSelection()
	SELF:GridViewVessels:FocusedRowHandle:=nFocusedHandle
	SELF:GridViewVessels:SelectRow(nFocusedHandle)
RETURN


METHOD Vessels_Edit(oRow AS DataRowView, oColumn AS GridColumn) AS VOID
	IF oRow == NULL
		RETURN
	ENDIF

	LOCAL cField := oColumn:FieldName AS STRING
	IF ! InListExact(cField, "Active", "VslCode", "VesselName", "PropellerPitch", "uFleet", "Alias")
		wb("The column '"+oColumn:Caption+"' is ReadOnly")
		RETURN
	ENDIF

	SELF:oEditColumn := oColumn
	SELF:oEditRow := oRow

	SELF:oEditColumn:OptionsColumn:AllowEdit := TRUE
    SELF:GridViewVessels:OptionsSelection:EnableAppearanceFocusedCell := TRUE
	SELF:GridViewVessels:ShowEditor()
RETURN


METHOD Vessels_Delete() AS VOID
	LOCAL oRow AS DataRowView
	LOCAL nRowHandle := SELF:GridViewVessels:FocusedRowHandle AS INT
	oRow:=(DataRowView)SELF:GridViewVessels:GetRow(nRowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	IF QuestionBox("Do you want to Delete the current Vessel:"+CRLF+CRLF+;
					oRow:Item["VesselName"]:ToString()+" ?", ;
					"Delete") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	LOCAL cStatement, cExistedValue AS STRING
	cStatement:="SELECT VESSEL_UNIQUEID FROM FMDataPackages"+oMainForm:cNoLockTerm+;
				" WHERE VESSEL_UNIQUEID="+oRow:Item["VESSEL_UNIQUEID"]:ToString()
	cStatement := oSoftway:SelectTop(cStatement)
	cExistedValue:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "VESSEL_UNIQUEID")

	IF cExistedValue <> ""
		ErrorBox("The current Vessel already Exists in Data", ;
					"Delete aborded")
		RETURN
	ENDIF

	cStatement:="DELETE FROM SupVessels"+;
				" WHERE VESSEL_UNIQUEID="+oRow:Item["VESSEL_UNIQUEID"]:ToString()
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ErrorBox("Cannot Delete current row", "Deletion aborted")
		RETURN
	ENDIF

	IF SELF:GridViewVessels:DataRowCount == 1
		SELF:oDTVessels:Clear()
		RETURN
	ENDIF

	// Stop Notification
	//SELF:lSuspendNotificationVessels := TRUE
	IF nRowHandle == 0
		SELF:GridViewVessels:MoveNext()
	ELSE
		SELF:GridViewVessels:MovePrev()
	ENDIF
	//SELF:lSuspendNotificationVessels := FALSE

	LOCAL oDataRow AS DataRow
	oDataRow:=SELF:oDTVessels:Rows:Find(oRow:Item["VESSEL_UNIQUEID"]:ToString())
	//wb(oRow:Item["MSG_UNIQUEID"]:ToString(), oDataRow)
	IF oDataRow <> NULL
		//wb(Self:oDTMsg32:Rows:Find(oRow:Item["MsgRefNo"]:ToString()), "Removed")
		SELF:oDTVessels:Rows:Remove(oDataRow)
	ENDIF
RETURN


Method Vessels_Save(e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs) as void
Local cStatement, cUID, cField, cValue, cReplace, cDuplicate as string

	Local oRow as DataRowView
	oRow:=(DataRowView)SELF:GridViewVessels:GetRow(e:RowHandle)

	cUID := oRow:Item["VESSEL_UNIQUEID"]:ToString()

	cField := e:Column:FieldName
	cValue := e:Value:ToString():Trim()

	LOCAL cTable := "SupVessels" AS STRING

	// Validate cValue
	DO CASE
	CASE InListExact(cField, "VesselName") .and. cValue:Length > 128
		ErrorBox("The field '"+cField+"' must contain up to 128 characters", "Editing aborted")
		SELF:Vessels_Refresh()
		RETURN

	CASE InListExact(cField, "Alias") .and. cValue:Length > 256
		ErrorBox("The field '"+cField+"' must contain up to 256 characters", "Editing aborted")
		SELF:Vessels_Refresh()
		RETURN

	CASE cField == "VesselName" .and. cValue:Length = 0
		ErrorBox("The field '"+cField+"' cannot be empty", "Editing aborted")
		SELF:Vessels_Refresh()
		RETURN

	CASE cField == "VesselName"
		// Check for duplicates
		cStatement:="SELECT VesselName FROM Vessels"+oMainForm:cNoLockTerm+;
					" WHERE VESSEL_UNIQUEID <> "+cUID+;
					" AND VesselName='"+oSoftway:ConvertWildCards(cValue, FALSE)+"'"
		cDuplicate:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "VesselName"):Trim()
		if cDuplicate <> ""
			ErrorBox("The Vessel Name '"+cValue+"' is already in use by another Vessel", "Editing aborted")
			SELF:Vessels_Refresh()
			RETURN
		ENDIF
		// Go on:
		cTable := "Vessels"
		cReplace := "'"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"
	
	CASE cField == "Alias"
		// Check for duplicates
		cStatement:="SELECT Alias FROM Vessels"+oMainForm:cNoLockTerm+;
					" WHERE VESSEL_UNIQUEID <> "+cUID+;
					" AND Alias='"+oSoftway:ConvertWildCards(cValue, FALSE)+"'"
		cDuplicate:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "VesselName"):Trim()
		if cDuplicate <> ""
			ErrorBox("The Alias '"+cValue+"' is already in use by another Vessel", "Editing aborted")
			SELF:Vessels_Refresh()
			RETURN
		ENDIF
		// Go on:
		cTable := "Vessels"
		cReplace := "'"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"

	CASE cField == "VslCode"
		// Check for duplicates
		cStatement:="SELECT Vessels.VesselName FROM SupVessels"+oMainForm:cNoLockTerm+;
					" INNER JOIN Vessels ON Vessels.VESSEL_UNIQUEID=SupVessels.VESSEL_UNIQUEID"+;
					" WHERE Vessels.VESSEL_UNIQUEID <> "+cUID+;
					" AND SupVessels.VslCode='"+cValue+"'"
		cDuplicate:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "VesselName"):Trim()
		if cDuplicate <> ""
			ErrorBox("The Vessel Code '"+cValue+"' is already in use by Vessel: "+cDuplicate, "Editing aborted")
			SELF:Vessels_Refresh()
			RETURN
		ENDIF
		cReplace := cValue:Replace(",", ".")

	CASE cField == "Active"
		IF ToLogic(cValue)
			cReplace := "1"
		ELSE
			cReplace := "0"
		ENDIF

	CASE cField == "uFleet"
		// Remove the leading 'u'
		cField := "FLEET_UID"
		cValue := SELF:cFleetValue
		cReplace := cValue

	CASE cField == "PropellerPitch"
		cReplace := cValue:Replace(",", ".")

	OTHERWISE
		cReplace := cValue
	ENDCASE

	// Update Vessels or SupVessels
	cStatement:="UPDATE "+cTable+" SET"+;
				" "+cField+"="+cReplace+;
				" WHERE VESSEL_UNIQUEID="+cUID
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:Vessels_Refresh()
		RETURN
	ENDIF

	// Update DataTable and Grid
	LOCAL oDataRow:=SELF:oDTVessels:Rows:Find(oRow:Item["VESSEL_UNIQUEID"]:ToString()) AS DataRow
	IF oDataRow == NULL
		ErrorBox("Cannot access current row", "Not changed")
		RETURN
	ENDIF

	oDataRow:Item[cField] := cValue
	IF cField == "FLEET_UID"
		oDataRow:Item["Fleet"] := SELF:cFleetText
	ENDIF
	SELF:oDTVessels:AcceptChanges()
	// Invalidates the region occupied by the current View (adds it to the control's update region that will be repainted
	// during the next paint operation), and causes a paint message to be sent to the grid control

	SELF:GridViewVessels:Invalidate()
RETURN


Method Vessels_Refresh() as void
Local cUID as string

	Local oRow as DataRowView
	oRow:=(DataRowView)Self:GridViewVessels:GetRow(Self:GridViewVessels:FocusedRowHandle)

	if oRow <> NULL
		cUID := oRow:Item["VESSEL_UNIQUEID"]:ToString()
	ENDIF

	Self:CreateGridVessels()

	if oRow <> NULL
		Local col as DevExpress.XtraGrid.Columns.GridColumn
		Local nFocusedHandle as int

		col:=Self:GridViewVessels:Columns["VESSEL_UNIQUEID"]
		nFocusedHandle:=Self:GridViewVessels:LocateByValue(0, col, Convert.ToInt32(cUID))
		if nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
			Return
		endif

		Self:GridViewVessels:ClearSelection()
		Self:GridViewVessels:FocusedRowHandle:=nFocusedHandle
		Self:GridViewVessels:SelectRow(nFocusedHandle)
	endif	
RETURN


METHOD AddRemoveReportTypesVessel() AS VOID
	LOCAL cStatement AS STRING
	LOCAL oDT AS DataTable

	// Remove FMReportTypesVessel records
	cStatement:="SELECT DISTINCT Vessels.VESSEL_UNIQUEID"+;
				" FROM Vessels"+oMainForm:cNoLockTerm+;
				" INNER JOIN SupVessels on Vessels.VESSEL_UNIQUEID=SupVessels.VESSEL_UNIQUEID"+;
				"	AND (SupVessels.Active=0 OR SupVessels.Active IS NULL)"
	oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	FOREACH oRow AS DataRow IN oDT:Rows
		cStatement:="DELETE FROM FMReportTypesVessel"+;
					" WHERE VESSEL_UNIQUEID="+oRow["VESSEL_UNIQUEID"]:ToString()
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
	NEXT

	// Add FMReportTypesVessel records
	cStatement:="SELECT DISTINCT Vessels.VESSEL_UNIQUEID"+;
				" FROM Vessels"+oMainForm:cNoLockTerm+;
				" INNER JOIN SupVessels on Vessels.VESSEL_UNIQUEID=SupVessels.VESSEL_UNIQUEID"+;
				"	AND SupVessels.Active=1"
	oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	FOREACH oRow AS DataRow IN oDT:Rows
		// Check if Vessel has entries into FMReportTypesVessel
		cStatement:="SELECT Count(*) AS nCount FROM FMReportTypesVessel"+;
					" WHERE VESSEL_UNIQUEID="+oRow["VESSEL_UNIQUEID"]:ToString()
		IF oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "nCount") == "0"
			cStatement:="INSERT INTO FMReportTypesVessel (REPORT_UID, VESSEL_UNIQUEID)"+;
						" SELECT FMReportTypes.REPORT_UID, "+oRow["VESSEL_UNIQUEID"]:ToString()+;
						" FROM FMReportTypes"
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ENDIF
	NEXT
RETURN


Method Vessels_Print() as void
	Self:PrintPreviewGridVessels()
RETURN


#Region PrintPreview

METHOD PrintPreviewGridVessels() AS VOID
	// Check whether the XtraGrid control can be previewed.
	if ! Self:GridVessels:IsPrintingAvailable
		ErrorBox("The 'DevExpress.XtraPrinting' Library is not found")
		return
	endif

	// Opens the Preview window.
	//Self:GridCompanies:ShowPrintPreview()

	// Create a PrintingSystem component.
	LOCAL oPS := PrintingSystem{} AS DevExpress.XtraPrinting.PrintingSystem
	// Create a link that will print a control.
	Local oLink := PrintableComponentLink{oPS} as DevExpress.XtraPrinting.PrintableComponentLink
	// Specify the control to be printed.
	oLink:Component := Self:GridVessels
	// Set the paper format.
	oLink:PaperKind := System.Drawing.Printing.PaperKind.A4
	oLink:Landscape:=True
	// Subscribe to the CreateReportHeaderArea event used to generate the report header.
	oLink:CreateReportHeaderArea += CreateAreaEventHandler{self, @PrintableComponentLinkVessels_CreateReportHeaderArea()}
	// Generate the report.
	oLink:CreateDocument()
	// Hide Send via eMail TooBar Button
	oPS:SetCommandVisibility(PrintingSystemCommand.SendFile, CommandVisibility.None)
	// Show the report.
	oLink:ShowPreview()
Return


Method PrintableComponentLinkVessels_CreateReportHeaderArea(sender as object, e as CreateAreaEventArgs) as void
Local cReportHeader := "Vessels - Printed on "+Datetime.Now:ToString(ccDateFormat)+", "+Datetime.Now:ToString("HH:mm:ss")+" - User: "+oUser:UserID as string

	e:Graph:StringFormat := BrickStringFormat{StringAlignment.Center}
	e:Graph:Font := Font{"Tahoma", 14, FontStyle.Bold}

	Local rec := RectangleF{0, 0, e:Graph:ClientPageSize:Width, 50} as RectangleF
	e:Graph:DrawString(cReportHeader, Color.Black, rec, DevExpress.XtraPrinting.BorderSide.None)
Return

#EndRegion


METHOD FleetComboBoxItem_GetFleetUID(cDescription AS STRING) AS STRING
	// Get first SELF:GridVessels:RepositoryItem (only RepositoryItemComboBox is defined)
	LOCAL oRepositoryItemComboBoxItemType AS DevExpress.XtraEditors.Repository.RepositoryItemComboBox
	oRepositoryItemComboBoxItemType := (DevExpress.XtraEditors.Repository.RepositoryItemComboBox)SELF:GridVessels:RepositoryItems:Item[0]
	// 
	//LOCAL oFleetComboBoxItem AS FleetComboBoxItem
	//oFleetComboBoxItem := (FleetComboBoxItem)oRepositoryItemComboBoxItemType:Items[2]
	FOREACH oFleetComboBoxItem AS FleetComboBoxItem IN oRepositoryItemComboBoxItemType:Items
		IF oFleetComboBoxItem:Description == cDescription
			RETURN oFleetComboBoxItem:FLEET_UID
		ENDIF
	NEXT
	//wb(oFleetComboBoxItem:FLEET_UID)
RETURN NULL

END CLASS


CLASS FleetComboBoxItem //IMPLEMENTS IConvertible
	EXPORT FLEET_UID AS STRING
	EXPORT Description AS STRING
    
	CONSTRUCTOR(oRow AS DataRow)
		SELF:FLEET_UID		:=oRow:Item["FLEET_UID"]:ToString()
		SELF:Description	:=oRow:Item["Description"]:ToString()
	RETURN

	VIRTUAL METHOD ToString() AS STRING
	RETURN SELF:Description

END CLASS
