// FleetForm_Methods.prg
// FleetForm_Methods.prg
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


PARTIAL CLASS FleetForm INHERIT DevExpress.XtraEditors.XtraForm
	PRIVATE oDTFleet as DataTable
	//PRIVATE lSuspendNotification AS LOGIC
	PRIVATE oEditColumn AS GridColumn
	PRIVATE oEditRow AS DataRowView

METHOD FleetForm_OnLoad() AS VOID
	oSoftway:ReadFormSettings_DevExpress(SELF, NULL, oMainForm:alForms, oMainForm:alData)

	//SELF:GridViewFleet:OptionsView:ShowGroupPanel := FALSE
	SELF:GridViewFleet:OptionsBehavior:AllowIncrementalSearch := TRUE
	SELF:GridViewFleet:OptionsPrint:PrintDetails := TRUE
	SELF:GridViewFleet:OptionsSelection:EnableAppearanceFocusedCell := FALSE
	SELF:GridViewFleet:OptionsSelection:MultiSelect := False
	SELF:GridViewFleet:OptionsView:ColumnAutoWidth := FALSE

	SELF:CreateGridFleet_Columns()
	SELF:CreateGridFleet()
RETURN


METHOD CreateGridFleet() AS VOID
	LOCAL cStatement AS STRING

	cStatement:="SELECT FLEET_UID, Description"+;
				" FROM EconFleet"+oMainForm:cNoLockTerm+;
				" ORDER BY Description"
	SELF:oDTFleet:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	SELF:oDTFleet:TableName:="Fleet"
	// Create Primary Key
	oSoftway:CreatePK(Self:oDTFleet, "FLEET_UID")

	SELF:GridFleet:DataSource := SELF:oDTFleet
RETURN


METHOD CreateGridFleet_Columns() AS VOID
LOCAL oColumn AS GridColumn
Local nVisible:=0, nAbsIndex:=0 as int

// Freeze column: Set Fixed property

	oColumn:=oMainForm:CreateDXColumn("Fleet Name", "Description",		FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 200, SELF:GridViewFleet)
	//oColumn:Fixed := FixedStyle.Left


	// Invisible
	oColumn:=oMainForm:CreateDXColumn("FLEET_UID","FLEET_UID",			FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																		nAbsIndex++, -1, -1, SELF:GridViewFleet)
	oColumn:Visible:=FALSE
	//Self:GridViewFleet:ColumnViewOptionsBehavior:Editable:=False
RETURN


METHOD BeforeLeaveRow_Fleet(e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.Void
	//IF SELF:lSuspendNotification
	//	RETURN
	//ENDIF

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewFleet:GetRow(e:RowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	//// Validate
	//IF ! SELF:ValidateFleet()
	//	e:Allow := FALSE
	//	RETURN
	//ENDIF

	// EditMode: OFF
	SELF:SetEditModeOff_Common(SELF:GridViewFleet)
RETURN


//METHOD CustomUnboundColumnData_Fleet(e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs) AS VOID
// Provides data for the UnboundColumns
//	IF ! e:IsGetData
//		RETURN
//	ENDIF

//	LOCAL oRow AS DataRow

//	DO CASE
//		CASE e:Column:FieldName == "uFleet"
//			oRow := SELF:oDTFleet:Rows[e:ListSourceRowIndex]
//			 Remove the leading 'u' from FieldName
//			cField := oRow:Item[e:Column:FieldName:Substring(1)]:ToString()
//			e:Value := oRow["Fleet"]:ToString()
//	ENDCASE
//RETURN


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


/*METHOD FocusedRowChanged_Fleet(e AS DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventArgs) AS VOID
// Notification Method
	IF SELF:GridViewFleet:IsGroupRow(e:FocusedRowHandle)
		RETURN
	ENDIF

	// Get GridRow data into a DataRowView object
	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewFleet:GetRow(e:FocusedRowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	SELF:FillListBoxControls_Fleet(oRow)
RETURN*/


//METHOD ValidateFleet() AS LOGIC
//	LOCAL oRow AS DataRowView
//	oRow:=(DataRowView)SELF:GridViewFleet:GetRow(SELF:GridViewFleet:FocusedRowHandle)
//	IF oRow == NULL
//		RETURN TRUE
//	ENDIF

//	// Validate Dep
//	IF SELF:LVVisible_Fleet:Items:Count == 0 //.and. ! oRow:Item["Dep"]:ToString():Contains("1")
//		wb("The UserGroup must contain at least one User"+CRLF+CRLF+;
//			"Please Add a new User or Delete the Group")
//		RETURN FALSE
//	ENDIF
//RETURN TRUE

METHOD Fleet_Add() AS VOID
	IF QuestionBox("Do you want to create a new Fleet ?", ;
					"Add new") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	LOCAL cStatement, cUID  AS STRING
	// Add record into SNPFleet
	cStatement:="INSERT INTO EconFleet (Description)"+;
					" VALUES ('_NewFleetName')"
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:Fleet_Refresh()
		RETURN
	ENDIF
	cUID:=oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "EconFleet", "FLEET_UID")

	SELF:Fleet_Refresh()

	LOCAL nFocusedHandle AS INT
	nFocusedHandle:=SELF:GridViewFleet:LocateByValue(0, SELF:GridViewFleet:Columns["FLEET_UID"], Convert.ToInt32(cUID))
	IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
		RETURN
	ENDIF
	SELF:GridViewFleet:ClearSelection()
	SELF:GridViewFleet:FocusedRowHandle:=nFocusedHandle
	SELF:GridViewFleet:SelectRow(nFocusedHandle)
RETURN


METHOD Fleet_Edit(oRow AS DataRowView, oColumn AS GridColumn) AS VOID
	IF oRow == NULL
		RETURN
	ENDIF

	LOCAL cField := oColumn:FieldName AS STRING
	IF ! InListExact(cField, "Description")
		wb("The column '"+oColumn:Caption+"' is ReadOnly")
		RETURN
	ENDIF

	SELF:oEditColumn := oColumn
	SELF:oEditRow := oRow

	SELF:oEditColumn:OptionsColumn:AllowEdit := TRUE
    SELF:GridViewFleet:OptionsSelection:EnableAppearanceFocusedCell := TRUE
	SELF:GridViewFleet:ShowEditor()
RETURN


METHOD Fleet_Delete() AS VOID
	LOCAL oRow AS DataRowView
	LOCAL nRowHandle := SELF:GridViewFleet:FocusedRowHandle AS INT
	oRow:=(DataRowView)SELF:GridViewFleet:GetRow(nRowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	LOCAL cStatement, cExistedValue AS STRING
	cStatement:="SELECT Count(*) AS nCount FROM SupVessels"+oMainForm:cNoLockTerm+;
				" WHERE FLEET_UID="+oRow:Item["FLEET_UID"]:ToString()
	cStatement := oSoftway:SelectTop(cStatement)
	cExistedValue:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "nCount")

	IF cExistedValue <> "0"
		ErrorBox("The current Fleet contains "+cExistedValue+" Vessel(s)", ;
					"Delete aborded")
		RETURN
	ENDIF

	IF QuestionBox("Do you want to Delete the current Fleet:"+CRLF+CRLF+;
					oRow:Item["Description"]:ToString()+" ?", ;
					"Delete") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	cStatement:="DELETE FROM EconFleet"+;
				" WHERE FLEET_UID="+oRow:Item["FLEET_UID"]:ToString()
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ErrorBox("Cannot Delete current row", "Deletion aborted")
		RETURN
	ENDIF

	IF SELF:GridViewFleet:DataRowCount == 1
		SELF:oDTFleet:Clear()
		RETURN
	ENDIF

	// Stop Notification
	//SELF:lSuspendNotificationFleet := TRUE
	IF nRowHandle == 0
		SELF:GridViewFleet:MoveNext()
	ELSE
		SELF:GridViewFleet:MovePrev()
	ENDIF
	//SELF:lSuspendNotificationFleet := FALSE

	LOCAL oDataRow AS DataRow
	oDataRow:=SELF:oDTFleet:Rows:Find(oRow:Item["FLEET_UID"]:ToString())
	//wb(oRow:Item["MSG_UNIQUEID"]:ToString(), oDataRow)
	IF oDataRow <> NULL
		//wb(Self:oDTMsg32:Rows:Find(oRow:Item["MsgRefNo"]:ToString()), "Removed")
		SELF:oDTFleet:Rows:Remove(oDataRow)
	ENDIF
RETURN


Method Fleet_Save(e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs) as void
Local cStatement, cUID, cField, cValue, cReplace, cDuplicate as string

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewFleet:GetRow(e:RowHandle)

	cUID := oRow:Item["FLEET_UID"]:ToString()

	cField := e:Column:FieldName
	cValue := e:Value:ToString():Trim()

	LOCAL cTable := "EconFleet" AS STRING

	// Validate cValue
	DO CASE
	CASE InListExact(cField, "Description") .and. cValue:Length > 128
		ErrorBox("The field '"+cField+"' must contain up to 128 characters", "Editing aborted")
		SELF:Fleet_Refresh()
		RETURN
	END CASE
	
	DO CASE
	CASE cField == "Description"
		IF cValue == ""
			LOCAL cExistedValue AS STRING
			cStatement:="SELECT Count(*) AS nCount FROM SupVessels"+oMainForm:cNoLockTerm+;
						" WHERE FLEET_UID="+oRow:Item["FLEET_UID"]:ToString()
			cStatement := oSoftway:SelectTop(cStatement)
			cExistedValue:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "nCount")

			IF cExistedValue <> "0"
				ErrorBox("The current Fleet Name cannot be empty because is contains "+cExistedValue+" Vessel(s)", ;
							"Edit aborded")
				SELF:Fleet_Refresh()
				RETURN
			ENDIF
		ENDIF

		// Check for duplicates
		cStatement:="SELECT Description FROM EconFleet"+oMainForm:cNoLockTerm+;
					" WHERE FLEET_UID <> "+cUID+;
					" AND Description='"+oSoftway:ConvertWildCards(cValue, FALSE)+"'"
		cDuplicate:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Description"):Trim()
		IF cDuplicate <> ""
			ErrorBox("The Fleet Name '"+cValue+"' is already in use by another Fleet", "Editing aborted")
			SELF:Fleet_Refresh()
			RETURN
		ENDIF
		cReplace := "'"+oSoftway:ConvertWildCards(cValue, FALSE)+"'"
	ENDCASE

	// Update Fleet or EconFleet
	cStatement:="UPDATE "+cTable+" SET"+;
				" "+cField+"="+cReplace+;
				" WHERE FLEET_UID="+cUID
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:Fleet_Refresh()
		RETURN
	ENDIF

	// Update DataTable and Grid
	LOCAL oDataRow:=SELF:oDTFleet:Rows:Find(oRow:Item["FLEET_UID"]:ToString()) AS DataRow
	IF oDataRow == NULL
		ErrorBox("Cannot access current row", "Not changed")
		RETURN
	ENDIF

	oDataRow:Item[cField] := cValue
	SELF:oDTFleet:AcceptChanges()
	// Invalidates the region occupied by the current View (adds it to the control's update region that will be repainted
	// during the next paint operation), and causes a paint message to be sent to the grid control

	SELF:GridViewFleet:Invalidate()
RETURN


Method Fleet_Refresh() as void
Local cUID as string

	Local oRow as DataRowView
	oRow:=(DataRowView)Self:GridViewFleet:GetRow(Self:GridViewFleet:FocusedRowHandle)

	if oRow <> NULL
		cUID := oRow:Item["FLEET_UID"]:ToString()
	ENDIF

	Self:CreateGridFleet()

	if oRow <> NULL
		Local col as DevExpress.XtraGrid.Columns.GridColumn
		Local nFocusedHandle as int

		col:=Self:GridViewFleet:Columns["FLEET_UID"]
		nFocusedHandle:=Self:GridViewFleet:LocateByValue(0, col, Convert.ToInt32(cUID))
		if nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
			Return
		endif

		Self:GridViewFleet:ClearSelection()
		Self:GridViewFleet:FocusedRowHandle:=nFocusedHandle
		Self:GridViewFleet:SelectRow(nFocusedHandle)
	endif	
RETURN


Method Fleet_Print() as void
	Self:PrintPreviewGridFleet()
RETURN


#Region PrintPreview

METHOD PrintPreviewGridFleet() AS VOID
	// Check whether the XtraGrid control can be previewed.
	if ! Self:GridFleet:IsPrintingAvailable
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
	oLink:Component := Self:GridFleet
	// Set the paper format.
	oLink:PaperKind := System.Drawing.Printing.PaperKind.A4
	oLink:Landscape:=True
	// Subscribe to the CreateReportHeaderArea event used to generate the report header.
	oLink:CreateReportHeaderArea += CreateAreaEventHandler{self, @PrintableComponentLinkFleet_CreateReportHeaderArea()}
	// Generate the report.
	oLink:CreateDocument()
	// Hide Send via eMail TooBar Button
	oPS:SetCommandVisibility(PrintingSystemCommand.SendFile, CommandVisibility.None)
	// Show the report.
	oLink:ShowPreview()
Return


	METHOD PrintableComponentLinkFleet_CreateReportHeaderArea(sender AS OBJECT, e AS CreateAreaEventArgs) as void
Local cReportHeader := "Fleet - Printed on "+Datetime.Now:ToString(ccDateFormat)+", "+Datetime.Now:ToString("HH:mm:ss")+" - User: "+oUser:UserID as string

	e:Graph:StringFormat := BrickStringFormat{StringAlignment.Center}
	e:Graph:Font := Font{"Tahoma", 14, FontStyle.Bold}

	Local rec := RectangleF{0, 0, e:Graph:ClientPageSize:Width, 50} as RectangleF
	e:Graph:DrawString(cReportHeader, Color.Black, rec, DevExpress.XtraPrinting.BorderSide.None)
Return

#EndRegion

END CLASS
