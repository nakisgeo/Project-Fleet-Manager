// ListsForm_Methods.prg
#Using System.IO
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Collections
#Using DevExpress.XtraGrid.Columns
#Using DevExpress.Utils
#Using DevExpress.XtraEditors.Repository
#using DevExpress.XtraPrinting
#Using DevExpress.XtraPrintingLinks
#using System.Diagnostics


PARTIAL CLASS ListsForm INHERIT DevExpress.XtraEditors.XtraForm
Private oDTFlows as DataTable
Private lSuspendNotification as logic
Private oEditColumn as GridColumn
Private oEditRow as DataRowView
Private oCurrentRow as DataRowView
Private oDTStates as DataTable
Export cFlowFilterUID as string
Export cRegNo as string
Private lShowFlowControl as logic
Private lFillStateUsers as logic
Method ListsForm_OnLoad() as void

	SELF:gridviewlists:OptionsView:ShowGroupPanel := FALSE
	SELF:gridviewlists:OptionsBehavior:AllowIncrementalSearch := TRUE
	SELF:gridviewlists:OptionsPrint:PrintDetails := TRUE
	SELF:gridviewlists:OptionsSelection:EnableAppearanceFocusedCell := FALSE
	SELF:gridviewlists:OptionsSelection:MultiSelect := False
	SELF:gridviewlists:OptionsView:ColumnAutoWidth := FALSE

	SELF:gridviewlistitems:OptionsView:ShowGroupPanel := FALSE
	SELF:gridviewlistitems:OptionsBehavior:AllowIncrementalSearch := TRUE
	SELF:gridviewlistitems:OptionsPrint:PrintDetails := TRUE
	SELF:gridviewlistitems:OptionsSelection:EnableAppearanceFocusedCell := FALSE
	SELF:gridviewlistitems:OptionsSelection:MultiSelect := False
	SELF:gridviewlistitems:OptionsView:ColumnAutoWidth := FALSE

	oMainForm:CreateGridLists_Columns(Self:gridviewlists)
	oMainForm:CreateGridListItems_Columns(Self:gridviewlistitems)

	//Self:FillStateUsers()
	//Self:FillPrimaryUser()

	Self:CreateGridLists()
return


Method CreateGridLists() as void
Local cStatement as string

	cStatement:="SELECT List_UID, Description"+;
					" FROM DMFLists"+;
					" ORDER BY Description"
	
	Self:oDTFlows:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	Self:oDTFlows:TableName:="DMFLists"
	// Create Primary Key
	oSoftway:CreatePK(Self:oDTFlows, "List_UID")

	Self:GridLists:DataSource:=Self:oDTFlows
Return


Method FocusedRowChanged_Flows(e AS DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventArgs) as void
// Notification Method
	if Self:gridviewlists:IsGroupRow(e:FocusedRowHandle)
		Return
	endif

	// Get GridRow data into a DataRowView object
	Local oRow as DataRowView
	oRow:=(DataRowView)Self:gridviewlists:GetRow(e:FocusedRowHandle)
	if oRow == NULL
		Return
	endif

	Self:oCurrentRow := oRow
	IF SELF:oDTStates <> NULL
		// Clear the oDTStates Table to allow FocusedRowChanged_States() to jump in after selection
		Self:oDTStates:Clear()
	endif
	Self:CreateGridStates()
return


Method BeforeLeaveRow_Flows(e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.Void
	if Self:lSuspendNotification
		Return
	endif

	Local oRow as DataRowView
	oRow:=(DataRowView)Self:gridviewlists:GetRow(e:RowHandle)
	if oRow == NULL
		Return
	endif

	// Validate Flow Description
	do case
	case oRow:Item["Description"]:ToString() == ""
		wb("The Description must be defined")
		e:Allow := False
		Return
	endcase

	// EditMode: OFF
	Self:SetEditModeOff_Flows()

	// Validate States
	Local oRowStates as DataRowView
	oRowStates:=(DataRowView)Self:gridviewlistitems:GetFocusedRow()
	if oRowStates == NULL
		Return
	endif
	if ! Self:ValidateStates(oRowStates)
		e:Allow := False
		Return
	endif
Return


Method Flows_Add() as void
	Local cStatement, cUID as string

	cStatement:="INSERT INTO DMFLists (Description) VALUES"+;
				" ('New List')"
	if ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		Self:Flows_Refresh()
		Return
	endif

	cUID:=oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "DMFLists", "List_UID")

	Self:Flows_Refresh()

	Local nFocusedHandle as int
	nFocusedHandle:=Self:gridviewlists:LocateByValue(0, Self:gridviewlists:Columns["List_UID"], Convert.ToInt32(cUID))
	if nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
		Return
	endif
	Self:gridviewlists:ClearSelection()
	Self:gridviewlists:FocusedRowHandle:=nFocusedHandle
	Self:gridviewlists:SelectRow(nFocusedHandle)
RETURN


Method Flows_Edit(oRow as DataRowView, oColumn as GridColumn) as void
	if oRow == NULL
		Return
	endif

	Local cField := oColumn:FieldName as string
	if ! InListExact(cField, "Description")
		wb("The column '"+oColumn:Caption+"' is ReadOnly")
		Return
	endif

	Self:oEditColumn := oColumn
	Self:oEditRow := oRow

	Self:oEditColumn:OptionsColumn:AllowEdit := True
    SELF:gridviewlists:OptionsSelection:EnableAppearanceFocusedCell := True
	SELF:gridviewlists:ShowEditor()
RETURN


Method SetEditModeOff_Flows() as void
	if ! SELF:gridviewlists:OptionsSelection:EnableAppearanceFocusedCell
		Return
	endif

	SELF:gridviewlists:OptionsSelection:EnableAppearanceFocusedCell := False

	if Self:oEditColumn <> NULL
		Self:oEditColumn:OptionsColumn:AllowEdit := False
		Self:oEditColumn := NULL
	endif

	if Self:oEditRow <> NULL
		Self:oEditRow := NULL
	endif
Return


Method Flows_Save(e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs) as void
Local cStatement, cUID, cField, cValue, cDuplicate as string

	Local oRow as DataRowView
	oRow:=(DataRowView)Self:gridviewlists:GetRow(e:RowHandle)

	cUID := oRow:Item["List_UID"]:ToString()

	cField := e:Column:FieldName
	cValue := e:Value:ToString():Trim()

	// Validate cValue
	do case
	case InListExact(cField, "Description") .and. cValue:Length > 128
		ErrorBox("The field '"+e:Column:Caption+"' must contain up to 128 characters", "Editing aborted")
		Self:Flows_Refresh()
		Return

	case InListExact(cField, "Description") .and. cValue:Length == 0
		ErrorBox("The field '"+e:Column:Caption+"' cannot be empty", "Editing aborted")
		Self:Flows_Refresh()
		Return

	case InListExact(cField, "Description") .and. (cValue != null .and. ( cValue:Trim()=="Users" .or. cValue:Trim()=="Week" .or. cValue:Trim()=="Ports"))
		ErrorBox("This is a reserved wording, pls try another", "Editing aborted")
		Self:Flows_Refresh()
		Return

	case cField == "Description"
		// Check for duplicates
		cStatement:="SELECT Description FROM DMFLists"+;
					" WHERE List_UID<>"+cUID+;
					" AND Description='"+oSoftway:ConvertWildcards(cValue, False)+"'"
		cDuplicate:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Description")
		if cDuplicate <> ""
			ErrorBox("The name '"+cValue+"' is already in use by another List='"+cDuplicate+"'", "Editing aborted")
			Self:Flows_Refresh()
			Return
		endif
//		cValue := cValue:ToUpper()
	endcase


		if QuestionBoxDefaultButton("Do you want to rename the List ?", ;
				"Rename List", MessageBoxButtons.YesNo, MessageBoxDefaultButton.Button2) <> System.Windows.Forms.DialogResult.Yes
			Self:Flows_Refresh()
			Return
		endif
	
	Local cReplace as string
	cReplace := "'"+oSoftway:ConvertWildcards(cValue, False)+"'"

	// Update Flows
	cStatement:="UPDATE DMFLists SET"+;
				" "+cField+"="+cReplace+;
				" WHERE List_UID="+cUID
	if ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		Self:Flows_Refresh()
		Return
	endif

	// Update DataTable and Grid
	Local oDataRow:=Self:oDTFlows:Rows:Find(oRow:Item["List_UID"]:ToString()) as DataRow
	if oDataRow == NULL
		ErrorBox("Cannot access current row", "Not changed")
		Return
	endif
	oDataRow:Item[cField]:=cValue
	Self:oDTFlows:AcceptChanges()
	// Invalidates the region occupied by the current View (adds it to the control's update region that will be repainted
	// during the next paint operation), and causes a paint message to be sent to the grid control
	Self:gridviewlists:Invalidate()
Return


Method Flows_Delete() as void
	Local oRow as DataRowView
	Local nRowHandle := Self:gridviewlists:FocusedRowHandle as int
	oRow:=(DataRowView)Self:gridviewlists:GetRow(nRowHandle)
	if oRow == NULL
		Return
	endif

	Local cStatement as string

	if QuestionBox("Do you want to Delete the current List :"+CRLF+CRLF+;
					oRow:Item["Description"]:ToString()+" ?", ;
					"Delete") <> System.Windows.Forms.DialogResult.Yes
		Return
	endif

	cStatement:="DELETE FROM DMFLists"+;
				" WHERE List_UID="+oRow:Item["List_UID"]:ToString()
	if ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ErrorBox("Cannot Delete current row", "Deletion aborted")
		Return
	endif

	if Self:gridviewlists:DataRowCount == 1
		Self:oDTFlows:Clear()
		Return
	endif

	// Stop Notification
	Self:lSuspendNotification := True
	if nRowHandle == 0
		Self:gridviewlists:MoveNext()
	else
		Self:gridviewlists:MovePrev()
	endif
	Self:lSuspendNotification := False

	Local oDataRow as DataRow
	oDataRow:=Self:oDTFlows:Rows:Find(oRow:Item["List_UID"]:ToString())
	if oDataRow <> NULL
		Self:oDTFlows:Rows:Remove(oDataRow)
	endif
RETURN
    

Method Flows_Refresh() as void
Local cUID as string

	Local oRow as DataRowView
	oRow:=(DataRowView)Self:gridviewlists:GetRow(Self:gridviewlists:FocusedRowHandle)

	if oRow <> NULL
		cUID := oRow:Item["List_UID"]:ToString()
	endif

	Self:CreateGridLists()

	if oRow <> NULL
		Local col as DevExpress.XtraGrid.Columns.GridColumn
		Local nFocusedHandle as int

		col:=Self:gridviewlists:Columns["List_UID"]
		nFocusedHandle:=Self:gridviewlists:LocateByValue(0, col, Convert.ToInt32(cUID))
		if nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
			Return
		endif

		Self:gridviewlists:ClearSelection()
		Self:gridviewlists:FocusedRowHandle:=nFocusedHandle
		Self:gridviewlists:SelectRow(nFocusedHandle)
	endif	
RETURN
    
METHOD checkChangedStateRights(lChecked AS LOGIC,cRight AS STRING) as Void

RETURN

METHOD loadUserRights() as Void
	
RETURN

Method Flows_Print() as void
	Self:PrintPreviewGridLists()
RETURN


#Region PrintPreview

Method PrintPreviewGridLists() as void
	// Check whether the XtraGrid control can be previewed.
	if ! Self:GridLists:IsPrintingAvailable
		ErrorBox("The 'DevExpress.XtraPrinting' Library is not found")
		return
	endif

	// Opens the Preview window.
	//Self:GridCompanies:ShowPrintPreview()

	// Create a PrintingSystem component.
	Local oPS := PrintingSystem{} as DevExpress.XtraPrinting.PrintingSystem
	// Create a link that will print a control.
	Local oLink := PrintableComponentLink{oPS} as DevExpress.XtraPrinting.PrintableComponentLink
	// Specify the control to be printed.
	oLink:Component := Self:GridLists
	// Set the paper format.
	oLink:PaperKind := System.Drawing.Printing.PaperKind.A4
	oLink:Landscape:=True
	// Subscribe to the CreateReportHeaderArea event used to generate the report header.
	oLink:CreateReportHeaderArea += CreateAreaEventHandler{self, @PrintableComponentLinkFlows_CreateReportHeaderArea()}
	// Generate the report.
	oLink:CreateDocument()
	// Hide Send via eMail TooBar Button
	oPS:SetCommandVisibility(PrintingSystemCommand.SendFile, CommandVisibility.None)
	// Show the report.
	oLink:ShowPreview()
Return


Method PrintableComponentLinkFlows_CreateReportHeaderArea(sender as object, e as CreateAreaEventArgs) as void
Local cReportHeader := "Lists - Printed on "+Datetime.Now:ToString(ccDateFormat)+", "+Datetime.Now:ToString("HH:mm:ss")+" - User: "+oUser:UserID as string

	e:Graph:StringFormat := BrickStringFormat{StringAlignment.Center}
	e:Graph:Font := Font{"Tahoma", 14, FontStyle.Bold}

	Local rec := RectangleF{0, 0, e:Graph:ClientPageSize:Width, 50} as RectangleF
	e:Graph:DrawString(cReportHeader, Color.Black, rec, DevExpress.XtraPrinting.BorderSide.None)
Return

#EndRegion


Method FillStateUsers() as void

Return


Method FillPrimaryUser() as void

RETURN


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
Method CreateGridStates() as void
Local cStatement, cUID as string

	if Self:oCurrentRow == NULL
		cUID := "0"
	else
		cUID := Self:oCurrentRow:Item["List_UID"]:ToString()
	endif

	cStatement:="SELECT Description, List_Item_UID FROM DMFListItems "+;
				" WHERE FK_List_UID="+cUID
	Self:oDTStates:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	Self:oDTStates:TableName:="DMFListItems"
	// Create Primary Key
	oSoftway:CreatePK(Self:oDTStates, "List_Item_UID")

	Self:GridStates:DataSource:=Self:oDTStates
	//Self:States_Notify()

	if Self:oDTStates:Rows:Count == 0
		Self:ClearStateDetails()
	endif
Return


/*Method CreateGridStates_Columns() as void
Local oColumn as GridColumn
Local nVisible:=0, nAbsIndex:=0 as int

oColumn:=oDMFForm:CreateDXColumn("StateNo",	"StateNo",				False, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 60, Self:GridViewStates)
oColumn:UnboundExpression:="StateNo"							

oColumn:=oDMFForm:CreateDXColumn("Description",	"Description",		False, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 100, Self:GridViewStates)
oColumn:UnboundExpression:="Description"							

oColumn:=oDMFForm:CreateDXColumn("UserName",	"UserName",				False, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 70, Self:GridViewStates)
oColumn:UnboundExpression:="UserName"							

oColumn:=oDMFForm:CreateDXColumn("FolderName",	"FolderName",			False, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 80, Self:GridViewStates)
oColumn:UnboundExpression:="FolderName"							
// ToolTip
oColumn:ToolTip := "Folder is required for the first State to start the Document Flow"

oColumn:=oDMFForm:CreateDXColumn("FlowCondition","SubmitFieldCondition",False, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 90, Self:gridviewlistitems)
oColumn:UnboundExpression:="SubmitFieldCondition"							
// ToolTip
oColumn:ToolTip := "The Document will be allowed to move Forward if the Condition is satisfied"+CRLF+;
					"The Condition contains the name(s) of the Field(s) to be completed (Example: OrderNo VoucherNo)"

oColumn:=oDMFForm:CreateDXColumn("SubmitNo",	"SubmitNo",				False, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 65, Self:gridviewlistitems)
oColumn:UnboundExpression:="SubmitNo"							
// ToolTip
oColumn:ToolTip := "0=First State, -1=No Forward State"

oColumn:=oDMFForm:CreateDXColumn("RejectNo",	"RejectNo",				False, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 65, Self:gridviewlistitems)
oColumn:UnboundExpression:="RejectNo"							
// ToolTip
oColumn:ToolTip := "0=First State, -1=No Backward State"

// Invisible
oColumn:=oDMFForm:CreateDXColumn("STATE_UNIQUEID","STATE_UNIQUEID",	False, DevExpress.Data.UnboundColumnType.Integer, ;
																		nAbsIndex++, -1, -1, Self:gridviewlistitems)
oColumn:UnboundExpression:="STATE_UNIQUEID"
oColumn:Visible:=False

oColumn:=oDMFForm:CreateDXColumn("USER_UNIQUEID","USER_UNIQUEID",	False, DevExpress.Data.UnboundColumnType.Integer, ;
																		nAbsIndex++, -1, -1, Self:gridviewlistitems)
oColumn:UnboundExpression:="USER_UNIQUEID"
oColumn:Visible:=False

oColumn:=oDMFForm:CreateDXColumn("FOLDER_UNIQUEID","FOLDER_UNIQUEID",	False, DevExpress.Data.UnboundColumnType.Integer, ;
																		nAbsIndex++, -1, -1, Self:gridviewlistitems)
oColumn:UnboundExpression:="FOLDER_UNIQUEID"
oColumn:Visible:=False

oColumn:=oDMFForm:CreateDXColumn("List_UID","List_UID",	False, DevExpress.Data.UnboundColumnType.Integer, ;
																		nAbsIndex++, -1, -1, Self:gridviewlistitems)
oColumn:UnboundExpression:="List_UID"
oColumn:Visible:=False

//Self:gridviewlistitems:ColumnViewOptionsBehavior:Editable:=False
Return*/


Method FocusedRowChanged_States(e AS DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventArgs) as void
// Notification Method

return


/*Method States_Notify() as void
// Notification Method called from Self:CreateGridStates()

	Self:UncheckAllStateUsers()

	if Self:gridviewlistitems:IsGroupRow(Self:gridviewlistitems:FocusedRowHandle)
		Self:ClearStateDetails()
		Return
	endif

	// Get GridRow data into a DataRowView object
	Local oRow as DataRowView
	oRow:=(DataRowView)Self:gridviewlistitems:GetRow(Self:gridviewlistitems:FocusedRowHandle)
	if oRow == NULL
		Self:ClearStateDetails()
		Return
	endif

	Self:FillStateDetails(oRow)
Return*/


Method BeforeLeaveRow_States(e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.Void
	if Self:lSuspendNotification
		Return
	endif

	Local oRow as DataRowView
	oRow:=(DataRowView)Self:gridviewlistitems:GetRow(e:RowHandle)
	if oRow == NULL
		Return
	endif

	// Validate States
	if ! Self:ValidateStates(oRow)
		e:Allow := False
		//Self:FillStateDetails(oRow)
		Return
	endif

/*	// Validate SubmitFieldCondition
	if ! Self:ValidateSubmitFieldCondition(oRow)
		e:Allow := False
		//Self:FillStateDetails(oRow)
		Return
	endif*/

	// EditMode: OFF
	Self:SetEditModeOff_States()
Return


Method ValidateSubmitFieldCondition(oRow as DataRowView) as logic
	
Return True


Method ValidateStates(oRow as DataRowView) as logic

Return True

METHOD loadExcelFile_Method() AS VOID
	LOCAL cUID, cListName,cStr AS STRING

	cUID := SELF:oCurrentRow:Item["List_UID"]:ToString()
	cListName := SELF:oCurrentRow:Item["Description"]:ToString()
	LOCAL oOpenFileDialog:=OpenFileDialog{} AS OpenFileDialog
	oOpenFileDialog:Filter:="Excel files|*.XLSX |All files|*.*"
	oOpenFileDialog:Title:="Import Excel file"
	IF oOpenFileDialog:ShowDialog() <> DialogResult.OK
		RETURN
	ENDIF

	LOCAL cFile:=oOpenFileDialog:FileName AS STRING
	LOCAL cExt := System.IO.Path.GetExtension(cFile):ToUpper() AS STRING
	LOCAL oldCI AS System.Globalization.CultureInfo
	oldCI:=System.Threading.Thread.CurrentThread:CurrentCulture
	System.Threading.Thread.CurrentThread:CurrentCulture:=System.Globalization.CultureInfo{"en-US"}

	SELF:Cursor := System.Windows.Forms.Cursors.WaitCursor
	Application.DoEvents()

	LOCAL oGFHExcel AS DBProviderFactory
	LOCAL oConnExcel AS DBConnection
	TRY
		LOCAL cConnectionString AS STRING
		// connection string to connect to the Excel Workbook
		// the first row is a header row containing the names of the columns
		DO CASE
		CASE cExt == ".XLS"
			cConnectionString:="Provider=Microsoft.Jet.OLEDB.4.0;"+;
									 "Data Source="+cFile+";"+;
									 "Extended Properties="+e"\"Excel 8.0;HDR=Yes;IMEX=1\""

		CASE cExt == ".XLSX"
			// Excel 2007:
			cConnectionString:="Provider=Microsoft.ACE.OLEDB.12.0;"+;
								 "Data Source="+cFile+";"+;
								 "Extended Properties="+e"\"Excel 12.0 Xml;HDR=YES;IMEX=1\""
		OTHERWISE
			ErrorBox("Only .XLS and .XLSX file etensions supported", "Import aborted")
			RETURN
		ENDCASE

		// Create a FactorySQL object
		oGFHExcel:=DBProviderFactories.GetFactory("System.Data.OleDb")

		// Create a SQL Connection object using OleDB
		oConnExcel:=oGFHExcel:CreateConnection()
		oConnExcel:ConnectionString:=cConnectionString
		oConnExcel:Open()
		//wb(cConnectionString, "OleDB Connection Open")

		// Create Excel DBDataAdapter
		LOCAL oDAExcel AS DBDataAdapter
		oDAExcel:=oGFHExcel:CreateDataAdapter()
		// Create Excel DBCommand
		LOCAL oCommand AS DBCommand
		oCommand:=oGFHExcel:CreateCommand()
		oCommand:CommandText:="SELECT * FROM ["+cListName+"$]"
		oCommand:Connection:=oConnExcel
		oDAExcel:SelectCommand:=oCommand
		LOCAL oDTExcel:=System.Data.DataTable{} AS System.Data.DataTable
		oDAExcel:Fill(oDTExcel)
		LOCAL nImported AS INT
		FOREACH oRow AS DataRow IN oDTExcel:Rows
			IF SELF:ImportRow(oRow, nImported, cStr, cListName, cUID)
				cStr += CRLF
			ELSE
				//lInsert := FALSE
				EXIT
			ENDIF
		NEXT
		
		LOCAL cTxt := cTempDocDir+"\ImportedList.TXT" AS STRING
		MemoWrit(cTxt, "Imported "+nImported:toString()+" list items."+CRLF+cStr)
		Process.Start("Notepad.exe", cTxt)
		CATCH exc AS Exception
			MessageBox.Show(exc:HResult:ToString())	
		FINALLY
			System.Threading.Thread.CurrentThread:CurrentCulture:=oldCI
			SELF:Cursor := System.Windows.Forms.Cursors.Default
		END TRY
		SELF:States_Refresh()
RETURN


METHOD ImportRow(oRow AS DataRow, nImported REF INT, cStr REF STRING, columnName as String, cListUID as String) AS LOGIC
	LOCAL cDescription, cStatement AS STRING
	cDescription := oSoftway:ConvertWildcards(oRow[0]:ToString():Trim(),False)
	IF cDescription == "" 
		RETURN TRUE
	ENDIF
	
	cStatement:="INSERT INTO DMFListItems (Description, FK_List_UID) VALUES"+;
					" ('"+cDescription+"',"+cListUID+")"
	IF !oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		RETURN FALSE
	ENDIF
	cStr += cDescription
	nImported++
RETURN TRUE

Method States_Add() as void
	Local cStatement, cUID as string
	cUID := Self:oCurrentRow:Item["List_UID"]:ToString()
	
		cStatement:="INSERT INTO DMFListItems (Description, FK_List_UID) VALUES"+;
					" ('New List Item',"+cUID+")"
	
	if ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		Self:States_Refresh()
		Return
	endif
	Self:States_Refresh()
	cUID:=oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "DMFListItems", "List_Item_UID")
	Local nFocusedHandle as int
	nFocusedHandle:=Self:gridviewlistitems:LocateByValue(0, Self:gridviewlistitems:Columns["List_Item_UID"], Convert.ToInt32(cUID))
	if nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
		Return
	endif
	Self:gridviewlistitems:ClearSelection()
	Self:gridviewlistitems:FocusedRowHandle:=nFocusedHandle
	Self:gridviewlistitems:SelectRow(nFocusedHandle)
RETURN


//METHOD GetNextStateNo() AS STRING
//	LOCAL cNo AS STRING
//RETURN cNo


Method States_Edit(oRow as DataRowView, oColumn as GridColumn) as void
	if oRow == NULL
		Return
	endif

	Local cField := oColumn:FieldName as string
	DO CASE
	case ! InListExact(cField,"Description")
		wb("The column '"+oColumn:Caption+"' is ReadOnly")
		Return
	endcase

	Self:oEditColumn := oColumn
	Self:oEditRow := oRow

	Self:oEditColumn:OptionsColumn:AllowEdit := True
    SELF:gridviewlistitems:OptionsSelection:EnableAppearanceFocusedCell := True
	SELF:gridviewlistitems:ShowEditor()
RETURN


Method SetEditModeOff_States() as void
	if ! SELF:gridviewlistitems:OptionsSelection:EnableAppearanceFocusedCell
		Return
	endif

	SELF:gridviewlistitems:OptionsSelection:EnableAppearanceFocusedCell := False

	if Self:oEditColumn <> NULL
		Self:oEditColumn:OptionsColumn:AllowEdit := False
		Self:oEditColumn := NULL
	endif

	if Self:oEditRow <> NULL
		Self:oEditRow := NULL
	endif
Return


Method States_Save(e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs) as void
Local cField, cValue, cCaption as string

	cField := e:Column:FieldName
	cValue := e:Value:ToString():Trim()
	cCaption := e:Column:Caption

	Local oRow as DataRowView
	oRow:=(DataRowView)Self:gridviewlistitems:GetRow(e:RowHandle)

	if Self:Update_StatesField(oRow, cField, cValue, cCaption)
		// Grid Modified
		Self:FillStateDetails(oRow)
	endif
Return


Method Update_StatesField(oRow as DataRowView, cField as string, cValue as string, cCaption as string) as Logic
Local cStatement, cUID as string

	cUID := oRow:Item["List_Item_UID"]:ToString()

	// Validate cValue
	do case
	case InListExact(cField, "Description", "SubmitFieldCondition") .and. cValue:Length > 128
		ErrorBox("The field '"+cCaption+"' must contain up to 128 characters", "Editing aborted")
		Self:States_Refresh()
		Return False

	case InListExact(cField, "Description") .and. cValue:Length == 0
		ErrorBox("The field '"+cCaption+"' cannot be empty", "Editing aborted")
		Self:States_Refresh()
		Return False
	endcase

		/*if QuestionBoxDefaultButton("Do you want to update the State ?", ;
				"Change field: "+cCaption, MessageBoxButtons.YesNo, MessageBoxDefaultButton.Button2) <> System.Windows.Forms.DialogResult.Yes
			Self:States_Refresh()
			Return False
		endif*/
	

	Local cReplace as string
	cReplace := "'"+oSoftway:ConvertWildcards(cValue, False)+"'"

	// Update States
	cStatement:="UPDATE DMFListItems SET"+;
				" "+cField+"="+cReplace+;
				" WHERE List_Item_UID="+cUID
	if ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		Self:States_Refresh()
		Return False
	endif

	// Update DataTable and Grid
	Local oDataRow:=Self:oDTStates:Rows:Find(oRow:Item["List_Item_UID"]:ToString()) as DataRow
	if oDataRow == NULL
		ErrorBox("Cannot access current row", "Not changed")
		Return False
	endif
	oDataRow:Item[cField]:=cValue
	Self:oDTStates:AcceptChanges()
	// Invalidates the region occupied by the current View (adds it to the control's update region that will be repainted
	// during the next paint operation), and causes a paint message to be sent to the grid control
	Self:gridviewlistitems:Invalidate()

	if cField == "List_Item_UID"
		Self:States_Refresh()
	endif
Return True


Method States_Delete() as void
	Local oRow as DataRowView
	Local nRowHandle := Self:gridviewlistitems:FocusedRowHandle as int
	oRow:=(DataRowView)Self:gridviewlistitems:GetRow(nRowHandle)
	if oRow == NULL
		Return
	endif

	Local cStatement as string
	//Local oDT1, oDT2 as DataTable
	//Local cStr1 := "", cStr2 := "" as string

	if QuestionBox("Do you want to Delete the current Item:"+CRLF+CRLF+;
					oRow:Item["Description"]:ToString()+" ?", ;
					"Delete") <> System.Windows.Forms.DialogResult.Yes
		Return
	endif

	cStatement:="DELETE FROM DMFListItems"+;
				" WHERE List_Item_UID="+oRow:Item["List_Item_UID"]:ToString()
	if ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ErrorBox("Cannot Delete current row", "Deletion aborted")
		Return
	endif

	if Self:gridviewlistitems:DataRowCount == 1
		Self:oDTStates:Clear()
		Return
	endif

	// Stop Notification
	Self:lSuspendNotification := True
	if nRowHandle == 0
		Self:gridviewlistitems:MoveNext()
	else
		Self:gridviewlistitems:MovePrev()
	endif
	Self:lSuspendNotification := False

	Local oDataRow as DataRow
	oDataRow:=Self:oDTStates:Rows:Find(oRow:Item["List_Item_UID"]:ToString())
	//wb(oRow:Item["MSG_UNIQUEID"]:ToString(), oDataRow)
	if oDataRow <> NULL
		Self:oDTStates:Rows:Remove(oDataRow)
//			cUIDs+=cUID+","
	endif
RETURN
    

Method States_Refresh() as void
Local cUID as string

	Local oRow as DataRowView
	oRow:=(DataRowView)Self:gridviewlistitems:GetRow(Self:gridviewlistitems:FocusedRowHandle)

	if oRow <> NULL
		cUID := oRow:Item["List_Item_UID"]:ToString()
	endif

	Self:CreateGridStates()

	if oRow <> NULL
		Local col as DevExpress.XtraGrid.Columns.GridColumn
		Local nFocusedHandle as int

		col:=Self:gridviewlistitems:Columns["List_Item_UID"]
		nFocusedHandle:=Self:gridviewlistitems:LocateByValue(0, col, Convert.ToInt32(cUID))
		if nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
			Return
		endif

		Self:gridviewlistitems:ClearSelection()
		Self:gridviewlistitems:FocusedRowHandle:=nFocusedHandle
		Self:gridviewlistitems:SelectRow(nFocusedHandle)
	endif	
RETURN
    

Method States_Print() as void
	Self:PrintPreviewGridStates()
RETURN


Method States_Help() as void
Return


#Region PrintPreview

Method PrintPreviewGridStates() as void
	// Check whether the XtraGrid control can be previewed.
	if ! Self:GridStates:IsPrintingAvailable
		ErrorBox("The 'DevExpress.XtraPrinting' Library is not found")
		return
	endif

	// Opens the Preview window.
	//Self:GridCompanies:ShowPrintPreview()

	// Create a PrintingSystem component.
	Local oPS := PrintingSystem{} as DevExpress.XtraPrinting.PrintingSystem
	// Create a link that will print a control.
	Local oLink := PrintableComponentLink{oPS} as DevExpress.XtraPrinting.PrintableComponentLink
	// Specify the control to be printed.
	oLink:Component := Self:GridStates
	// Set the paper format.
	oLink:PaperKind := System.Drawing.Printing.PaperKind.A4
	oLink:Landscape:=True
	// Subscribe to the CreateReportHeaderArea event used to generate the report header.
	oLink:CreateReportHeaderArea += CreateAreaEventHandler{self, @PrintableComponentLinkStates_CreateReportHeaderArea()}
	// Generate the report.
	oLink:CreateDocument()
	// Hide Send via eMail TooBar Button
	oPS:SetCommandVisibility(PrintingSystemCommand.SendFile, CommandVisibility.None)
	// Show the report.
	oLink:ShowPreview()
Return


Method PrintableComponentLinkStates_CreateReportHeaderArea(sender as object, e as CreateAreaEventArgs) as void
Local cReportHeader := "List Items of ["+Self:oCurrentRow:Item["Description"]:ToString()+"] - Printed on "+Datetime.Now:ToString(ccDateFormat)+", "+Datetime.Now:ToString("HH:mm:ss")+" - User: "+oUser:UserID as string

	e:Graph:StringFormat := BrickStringFormat{StringAlignment.Center}
	e:Graph:Font := Font{"Tahoma", 14, FontStyle.Bold}

	Local rec := RectangleF{0, 0, e:Graph:ClientPageSize:Width, 50} as RectangleF
	e:Graph:DrawString(cReportHeader, Color.Black, rec, DevExpress.XtraPrinting.BorderSide.None)
Return

#EndRegion

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


Method FillStateDetails(oRow as DataRowView) as void

Return


//Method LocatePrimaryUser(cUserName as string) as void

//Return


//Method UpdatePrimaryUser() as void

//Return


//Method CheckStateUsers(cUID as string) as void

//Return


//Method UncheckAllStateUsers() as void

//Return


//METHOD UpdateStateUsers(e AS System.Windows.Forms.ItemCheckedEventArgs) as void

//return


//Method SubmitStateDescription(oRow as DataRowView)
//LOCAL cStatement, cDescription AS STRING

//RETURN cDescription


//Method RejectStateDescription(oRow as DataRowView)
//LOCAL cStatement, cDescription AS STRING

//RETURN cDescription


Method ClearStateDetails() as void
	
Return


Method SelectFolder() as void

Return


/*Method FillNonSystemFolders(oTVSub as FolderTreeView) as void
// Show Non-System Folders
Local cStatement, cUID, cFolderName, cParentFolder, cFolderTextColor as string
Local oReader as DBDataReader
Local oTVI as TreeNode
Local oFound as TreeNode[]
LOCAL oColor AS System.Drawing.Color
Local nRed, nGreen, nBlue as long

cStatement:="SELECT FOLDER_UNIQUEID, RTrim(FolderName) AS FolderName, ParentFolder, TreeLevel,"+;
			" Icon, FolderIcon, FolderTextColor"+;
			" FROM FOLDERS"+;
			" WHERE SystemFolder=0"+;
			" AND "+oSoftway:SelectSubstring+"(UserRights, "+oUser:UserNo:ToString()+", 1) <> '"+oMsgGlobals:FOLDER_Deny+"'"
cStatement+=" AND "+oSoftway:SelectSubstring+"(HideFolder, "+oUser:UserNo:ToString()+", 1) <> '"+oMsgGlobals:FOLDER_HIDE+"'"
cStatement+=" ORDER BY TreeLevel, ParentFolder, FolderName"
//wb(cStatement)

oReader:=oSoftway:ResultDataReader(oDMFForm:oGFH, oDMFForm:oConn, cStatement)
while oReader:Read()
	cUID:=oReader:Item["FOLDER_UNIQUEID"]:ToString()
	cFolderName:=oReader:Item["FolderName"]:ToString()
	cParentFolder:=oReader:Item["ParentFolder"]:ToString()

	oTVI:=TreeNode{}
	oTVI:Name:=cUID
	oTVI:Text:=cFolderName

	// Read current User's rights on the Folder
	//cUserRights:=oReader:Item["UserRights"]:ToString():SubString(oUser:UserNo - 1, 1)
	//IsMoveFolder:=Iif(ToLogic(oReader:Item["IsMoveFolder"]), "1", "0")

	//// Node:Name: FolderName for SystemFolders, FOLDER_UNIQUEID for Non-System Folders
	////	Node:Tag[1]: FOLDER_UNIQUEID for all Folders
	////	Node:Tag[2]: ViewDays
	////	Node:Tag[3]: UserRights
	////	Node:Tag[4]: IsMoveFolder
	//Self:SetTag(oTVI, cUID, oReader:Item["ViewDays"]:ToString(), cUserRights, IsMoveFolder)

	// Set FolderIcon
	oTVI:SelectedImageIndex:=Convert.ToInt32(oReader:Item["FolderIcon"]:ToString())
	oTVI:ImageIndex:=Convert.ToInt32(oReader:Item["FolderIcon"]:ToString())

	// TreeNode:Forecolor
	cFolderTextColor:=oReader:Item["FolderTextColor"]:ToString()
	if cFolderTextColor <> "0"
		oDMFForm:SplitColorToRGB(cFolderTextColor, nRed, nGreen, nBlue)
		oColor:=Color.FromArgb(nRed, nGreen, nBlue)
		oTVI:ForeColor:=oColor
	endif

	//// Set ToolTipText
	//cSummury:=""
	//if IsMoveFolder == "1"
	//	// IsMoveFolder
	//	cSummury:="<This is a MoveFolder>"+CRLF+CRLF
	//endif
	//cSummury+=oReader:Item["Memo"]:ToString()
	//if cSummury <> ""
	//	oTVI:ToolTipText:=cSummury
	//endif

	if cParentFolder == "0"
		oTVSub:Nodes:Add(oTVI)
	else
		oFound:=oTVSub:Nodes:Find(cParentFolder, TRUE)
		if oFound:Length <> 1
		 //  ErrorBox("Folder ["+cFolderName+"]"+CRLF+;
			//		"ParentFolder="+cParentFolder+CRLF+;
			//		"Instances="+oFound:Length:ToString(),;
			//		"ParentFolder not found")
			//exit
			loop
		endif
		oFound[1]:Nodes:Add(oTVI)
	endif
	//Self:nCustomFolders++
enddo
oReader:Close()

Return*/

End Class


/*Class UserInfo
Export cUserName, cUID as string

Constructor(_UserName as string, _UID as string)
	Self:cUserName := _UserName
	Self:cUID := _UID
Return

End Class*/