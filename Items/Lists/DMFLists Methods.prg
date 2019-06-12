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
PRIVATE oDTFlows AS DataTable
PRIVATE lSuspendNotification AS LOGIC
PRIVATE oEditColumn AS GridColumn
PRIVATE oEditRow AS DataRowView
PRIVATE oCurrentRow AS DataRowView
PRIVATE oDTStates AS DataTable
EXPORT cFlowFilterUID AS STRING
EXPORT cRegNo AS STRING
PRIVATE lShowFlowControl AS LOGIC
PRIVATE lFillStateUsers AS LOGIC
METHOD ListsForm_OnLoad() AS VOID

	SELF:gridviewlists:OptionsView:ShowGroupPanel := FALSE
	SELF:gridviewlists:OptionsBehavior:AllowIncrementalSearch := TRUE
	SELF:gridviewlists:OptionsPrint:PrintDetails := TRUE
	SELF:gridviewlists:OptionsSelection:EnableAppearanceFocusedCell := FALSE
	SELF:gridviewlists:OptionsSelection:MultiSelect := FALSE
	SELF:gridviewlists:OptionsView:ColumnAutoWidth := FALSE

	SELF:gridviewlistitems:OptionsView:ShowGroupPanel := FALSE
	SELF:gridviewlistitems:OptionsBehavior:AllowIncrementalSearch := TRUE
	SELF:gridviewlistitems:OptionsPrint:PrintDetails := TRUE
	SELF:gridviewlistitems:OptionsSelection:EnableAppearanceFocusedCell := FALSE
	SELF:gridviewlistitems:OptionsSelection:MultiSelect := FALSE
	SELF:gridviewlistitems:OptionsView:ColumnAutoWidth := FALSE

	oMainForm:CreateGridLists_Columns(SELF:gridviewlists)
	oMainForm:CreateGridListItems_Columns(SELF:gridviewlistitems)

	//Self:FillStateUsers()
	//Self:FillPrimaryUser()

	SELF:CreateGridLists()
RETURN


METHOD CreateGridLists() AS VOID
LOCAL cStatement AS STRING

	cStatement:="SELECT List_UID, Description"+;
					" FROM DMFLists"+;
					" ORDER BY Description"
	
	SELF:oDTFlows:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	SELF:oDTFlows:TableName:="DMFLists"
	// Create Primary Key
	oSoftway:CreatePK(SELF:oDTFlows, "List_UID")

	SELF:GridLists:DataSource:=SELF:oDTFlows
RETURN


METHOD FocusedRowChanged_Flows(e AS DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventArgs) AS VOID
// Notification Method
	IF SELF:gridviewlists:IsGroupRow(e:FocusedRowHandle)
		RETURN
	ENDIF

	// Get GridRow data into a DataRowView object
	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:gridviewlists:GetRow(e:FocusedRowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	SELF:oCurrentRow := oRow
	IF SELF:oDTStates <> NULL
		// Clear the oDTStates Table to allow FocusedRowChanged_States() to jump in after selection
		SELF:oDTStates:Clear()
	ENDIF
	SELF:CreateGridStates()
RETURN


METHOD BeforeLeaveRow_Flows(e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.Void
	IF SELF:lSuspendNotification
		RETURN
	ENDIF

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:gridviewlists:GetRow(e:RowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	// Validate Flow Description
	DO CASE
	CASE oRow:Item["Description"]:ToString() == ""
		wb("The Description must be defined")
		e:Allow := FALSE
		RETURN
	ENDCASE

	// EditMode: OFF
	SELF:SetEditModeOff_Flows()

	// Validate States
	LOCAL oRowStates AS DataRowView
	oRowStates:=(DataRowView)SELF:gridviewlistitems:GetFocusedRow()
	IF oRowStates == NULL
		RETURN
	ENDIF
	IF ! SELF:ValidateStates(oRowStates)
		e:Allow := FALSE
		RETURN
	ENDIF
RETURN


METHOD Flows_Add() AS VOID
	LOCAL cStatement, cUID AS STRING

	cStatement:="INSERT INTO DMFLists (Description) VALUES"+;
				" ('New List')"
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:Flows_Refresh()
		RETURN
	ENDIF

	cUID:=oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "DMFLists", "List_UID")

	SELF:Flows_Refresh()

	LOCAL nFocusedHandle AS INT
	nFocusedHandle:=SELF:gridviewlists:LocateByValue(0, SELF:gridviewlists:Columns["List_UID"], Convert.ToInt32(cUID))
	IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
		RETURN
	ENDIF
	SELF:gridviewlists:ClearSelection()
	SELF:gridviewlists:FocusedRowHandle:=nFocusedHandle
	SELF:gridviewlists:SelectRow(nFocusedHandle)
RETURN


METHOD Flows_Edit(oRow AS DataRowView, oColumn AS GridColumn) AS VOID
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
    SELF:gridviewlists:OptionsSelection:EnableAppearanceFocusedCell := TRUE
	SELF:gridviewlists:ShowEditor()
RETURN


METHOD SetEditModeOff_Flows() AS VOID
	IF ! SELF:gridviewlists:OptionsSelection:EnableAppearanceFocusedCell
		RETURN
	ENDIF

	SELF:gridviewlists:OptionsSelection:EnableAppearanceFocusedCell := FALSE

	IF SELF:oEditColumn <> NULL
		SELF:oEditColumn:OptionsColumn:AllowEdit := FALSE
		SELF:oEditColumn := NULL
	ENDIF

	IF SELF:oEditRow <> NULL
		SELF:oEditRow := NULL
	ENDIF
RETURN


METHOD Flows_Save(e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs) AS VOID
LOCAL cStatement, cUID, cField, cValue, cDuplicate AS STRING

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:gridviewlists:GetRow(e:RowHandle)

	cUID := oRow:Item["List_UID"]:ToString()

	cField := e:Column:FieldName
	cValue := e:Value:ToString():Trim()

	// Validate cValue
	DO CASE
	CASE InListExact(cField, "Description") .AND. cValue:Length > 128
		ErrorBox("The field '"+e:Column:Caption+"' must contain up to 128 characters", "Editing aborted")
		SELF:Flows_Refresh()
		RETURN

	CASE InListExact(cField, "Description") .AND. cValue:Length == 0
		ErrorBox("The field '"+e:Column:Caption+"' cannot be empty", "Editing aborted")
		SELF:Flows_Refresh()
		RETURN

	CASE InListExact(cField, "Description") .AND. (cValue != NULL .AND. ( cValue:Trim()=="Users" .OR. cValue:Trim()=="Week" .OR. cValue:Trim()=="Ports"))
		ErrorBox("This is a reserved wording, pls try another", "Editing aborted")
		SELF:Flows_Refresh()
		RETURN

	CASE cField == "Description"
		// Check for duplicates
		cStatement:="SELECT Description FROM DMFLists"+;
					" WHERE List_UID<>"+cUID+;
					" AND Description='"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"
		cDuplicate:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Description")
		IF cDuplicate <> ""
			ErrorBox("The name '"+cValue+"' is already in use by another List='"+cDuplicate+"'", "Editing aborted")
			SELF:Flows_Refresh()
			RETURN
		ENDIF
//		cValue := cValue:ToUpper()
	ENDCASE


		IF QuestionBoxDefaultButton("Do you want to rename the List ?", ;
				"Rename List", MessageBoxButtons.YesNo, MessageBoxDefaultButton.Button2) <> System.Windows.Forms.DialogResult.Yes
			SELF:Flows_Refresh()
			RETURN
		ENDIF
	
	LOCAL cReplace AS STRING
	cReplace := "'"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"

	// Update Flows
	cStatement:="UPDATE DMFLists SET"+;
				" "+cField+"="+cReplace+;
				" WHERE List_UID="+cUID
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:Flows_Refresh()
		RETURN
	ENDIF

	// Update DataTable and Grid
	LOCAL oDataRow:=SELF:oDTFlows:Rows:Find(oRow:Item["List_UID"]:ToString()) AS DataRow
	IF oDataRow == NULL
		ErrorBox("Cannot access current row", "Not changed")
		RETURN
	ENDIF
	oDataRow:Item[cField]:=cValue
	SELF:oDTFlows:AcceptChanges()
	// Invalidates the region occupied by the current View (adds it to the control's update region that will be repainted
	// during the next paint operation), and causes a paint message to be sent to the grid control
	SELF:gridviewlists:Invalidate()
RETURN


METHOD Flows_Delete() AS VOID
	LOCAL oRow AS DataRowView
	LOCAL nRowHandle := SELF:gridviewlists:FocusedRowHandle AS INT
	oRow:=(DataRowView)SELF:gridviewlists:GetRow(nRowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	LOCAL cStatement AS STRING

	IF QuestionBox("Do you want to Delete the current List :"+CRLF+CRLF+;
					oRow:Item["Description"]:ToString()+" ?", ;
					"Delete") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	cStatement:="DELETE FROM DMFLists"+;
				" WHERE List_UID="+oRow:Item["List_UID"]:ToString()
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ErrorBox("Cannot Delete current row", "Deletion aborted")
		RETURN
	ENDIF

	IF SELF:gridviewlists:DataRowCount == 1
		SELF:oDTFlows:Clear()
		RETURN
	ENDIF

	// Stop Notification
	SELF:lSuspendNotification := TRUE
	IF nRowHandle == 0
		SELF:gridviewlists:MoveNext()
	ELSE
		SELF:gridviewlists:MovePrev()
	ENDIF
	SELF:lSuspendNotification := FALSE

	LOCAL oDataRow AS DataRow
	oDataRow:=SELF:oDTFlows:Rows:Find(oRow:Item["List_UID"]:ToString())
	IF oDataRow <> NULL
		SELF:oDTFlows:Rows:Remove(oDataRow)
	ENDIF
RETURN
    

METHOD Flows_Refresh() AS VOID
LOCAL cUID AS STRING

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:gridviewlists:GetRow(SELF:gridviewlists:FocusedRowHandle)

	IF oRow <> NULL
		cUID := oRow:Item["List_UID"]:ToString()
	ENDIF

	SELF:CreateGridLists()

	IF oRow <> NULL
		LOCAL col AS DevExpress.XtraGrid.Columns.GridColumn
		LOCAL nFocusedHandle AS INT

		col:=SELF:gridviewlists:Columns["List_UID"]
		nFocusedHandle:=SELF:gridviewlists:LocateByValue(0, col, Convert.ToInt32(cUID))
		IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
			RETURN
		ENDIF

		SELF:gridviewlists:ClearSelection()
		SELF:gridviewlists:FocusedRowHandle:=nFocusedHandle
		SELF:gridviewlists:SelectRow(nFocusedHandle)
	ENDIF	
RETURN
    
METHOD checkChangedStateRights(lChecked AS LOGIC,cRight AS STRING) AS VOID

RETURN

METHOD loadUserRights() AS VOID
	
RETURN

METHOD Flows_Print() AS VOID
	SELF:PrintPreviewGridLists()
RETURN


#Region PrintPreview

METHOD PrintPreviewGridLists() AS VOID
	// Check whether the XtraGrid control can be previewed.
	IF ! SELF:GridLists:IsPrintingAvailable
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
	oLink:Component := SELF:GridLists
	// Set the paper format.
	oLink:PaperKind := System.Drawing.Printing.PaperKind.A4
	oLink:Landscape:=TRUE
	// Subscribe to the CreateReportHeaderArea event used to generate the report header.
	oLink:CreateReportHeaderArea += CreateAreaEventHandler{SELF, @PrintableComponentLinkFlows_CreateReportHeaderArea()}
	// Generate the report.
	oLink:CreateDocument()
	// Hide Send via eMail TooBar Button
	oPS:SetCommandVisibility(PrintingSystemCommand.SendFile, CommandVisibility.None)
	// Show the report.
	oLink:ShowPreview()
RETURN


METHOD PrintableComponentLinkFlows_CreateReportHeaderArea(sender AS OBJECT, e AS CreateAreaEventArgs) AS VOID
LOCAL cReportHeader := "Lists - Printed on "+Datetime.Now:ToString(ccDateFormat)+", "+Datetime.Now:ToString("HH:mm:ss")+" - User: "+oUser:UserID AS STRING

	e:Graph:StringFormat := BrickStringFormat{StringAlignment.Center}
	e:Graph:Font := Font{"Tahoma", 14, FontStyle.Bold}

	LOCAL rec := RectangleF{0, 0, e:Graph:ClientPageSize:Width, 50} AS RectangleF
	e:Graph:DrawString(cReportHeader, Color.Black, rec, DevExpress.XtraPrinting.BorderSide.None)
RETURN

#EndRegion


METHOD FillStateUsers() AS VOID

RETURN


METHOD FillPrimaryUser() AS VOID

RETURN


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
METHOD CreateGridStates() AS VOID
LOCAL cStatement, cUID AS STRING

	IF SELF:oCurrentRow == NULL
		cUID := "0"
	ELSE
		cUID := SELF:oCurrentRow:Item["List_UID"]:ToString()
	ENDIF

	cStatement:="SELECT Description, List_Item_UID FROM DMFListItems "+;
				" WHERE FK_List_UID="+cUID
	SELF:oDTStates:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	SELF:oDTStates:TableName:="DMFListItems"
	// Create Primary Key
	oSoftway:CreatePK(SELF:oDTStates, "List_Item_UID")

	SELF:GridStates:DataSource:=SELF:oDTStates
	//Self:States_Notify()

	IF SELF:oDTStates:Rows:Count == 0
		SELF:ClearStateDetails()
	ENDIF
RETURN


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


METHOD FocusedRowChanged_States(e AS DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventArgs) AS VOID
// Notification Method

RETURN


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


METHOD BeforeLeaveRow_States(e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.Void
	IF SELF:lSuspendNotification
		RETURN
	ENDIF

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:gridviewlistitems:GetRow(e:RowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	// Validate States
	IF ! SELF:ValidateStates(oRow)
		e:Allow := FALSE
		//Self:FillStateDetails(oRow)
		RETURN
	ENDIF

/*	// Validate SubmitFieldCondition
	if ! Self:ValidateSubmitFieldCondition(oRow)
		e:Allow := False
		//Self:FillStateDetails(oRow)
		Return
	endif*/

	// EditMode: OFF
	SELF:SetEditModeOff_States()
RETURN


METHOD ValidateSubmitFieldCondition(oRow AS DataRowView) AS LOGIC
	
RETURN TRUE


METHOD ValidateStates(oRow AS DataRowView) AS LOGIC

RETURN TRUE

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
			MessageBox.Show(exc:StackTrace:ToString())	
		FINALLY
			System.Threading.Thread.CurrentThread:CurrentCulture:=oldCI
			SELF:Cursor := System.Windows.Forms.Cursors.Default
		END TRY
		SELF:States_Refresh()
RETURN


METHOD ImportRow(oRow AS DataRow, nImported REF INT, cStr REF STRING, columnName AS STRING, cListUID AS STRING) AS LOGIC
	LOCAL cDescription, cStatement AS STRING
	cDescription := oSoftway:ConvertWildcards(oRow[0]:ToString():Trim(),FALSE)
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

METHOD States_Add() AS VOID
	LOCAL cStatement, cUID AS STRING
	cUID := SELF:oCurrentRow:Item["List_UID"]:ToString()
	
		cStatement:="INSERT INTO DMFListItems (Description, FK_List_UID) VALUES"+;
					" ('New List Item',"+cUID+")"
	
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:States_Refresh()
		RETURN
	ENDIF
	SELF:States_Refresh()
	cUID:=oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "DMFListItems", "List_Item_UID")
	LOCAL nFocusedHandle:= 0 AS INT
	nFocusedHandle:=SELF:gridviewlistitems:LocateByValue(0, SELF:gridviewlistitems:Columns["List_Item_UID"], Convert.ToInt32(cUID))
	IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
		RETURN
	ENDIF
	SELF:gridviewlistitems:ClearSelection()
	SELF:gridviewlistitems:FocusedRowHandle:=nFocusedHandle
	SELF:gridviewlistitems:SelectRow(nFocusedHandle)
RETURN


//METHOD GetNextStateNo() AS STRING
//	LOCAL cNo AS STRING
//RETURN cNo


METHOD States_Edit(oRow AS DataRowView, oColumn AS GridColumn) AS VOID
	IF oRow == NULL
		RETURN
	ENDIF

	LOCAL cField := oColumn:FieldName AS STRING
	DO CASE
	CASE ! InListExact(cField,"Description")
		wb("The column '"+oColumn:Caption+"' is ReadOnly")
		RETURN
	ENDCASE

	SELF:oEditColumn := oColumn
	SELF:oEditRow := oRow

	SELF:oEditColumn:OptionsColumn:AllowEdit := TRUE
    SELF:gridviewlistitems:OptionsSelection:EnableAppearanceFocusedCell := TRUE
	SELF:gridviewlistitems:ShowEditor()
RETURN


METHOD SetEditModeOff_States() AS VOID
	IF ! SELF:gridviewlistitems:OptionsSelection:EnableAppearanceFocusedCell
		RETURN
	ENDIF

	SELF:gridviewlistitems:OptionsSelection:EnableAppearanceFocusedCell := FALSE

	IF SELF:oEditColumn <> NULL
		SELF:oEditColumn:OptionsColumn:AllowEdit := FALSE
		SELF:oEditColumn := NULL
	ENDIF

	IF SELF:oEditRow <> NULL
		SELF:oEditRow := NULL
	ENDIF
RETURN


METHOD States_Save(e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs) AS VOID
LOCAL cField, cValue, cCaption AS STRING

	cField := e:Column:FieldName
	cValue := e:Value:ToString():Trim()
	cCaption := e:Column:Caption

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:gridviewlistitems:GetRow(e:RowHandle)

	IF SELF:Update_StatesField(oRow, cField, cValue, cCaption)
		// Grid Modified
		SELF:FillStateDetails(oRow)
	ENDIF
RETURN


METHOD Update_StatesField(oRow AS DataRowView, cField AS STRING, cValue AS STRING, cCaption AS STRING) AS LOGIC
LOCAL cStatement, cUID AS STRING

	cUID := oRow:Item["List_Item_UID"]:ToString()

	// Validate cValue
	DO CASE
	CASE InListExact(cField, "Description", "SubmitFieldCondition") .AND. cValue:Length > 128
		ErrorBox("The field '"+cCaption+"' must contain up to 128 characters", "Editing aborted")
		SELF:States_Refresh()
		RETURN FALSE

	CASE InListExact(cField, "Description") .AND. cValue:Length == 0
		ErrorBox("The field '"+cCaption+"' cannot be empty", "Editing aborted")
		SELF:States_Refresh()
		RETURN FALSE
	ENDCASE

		/*if QuestionBoxDefaultButton("Do you want to update the State ?", ;
				"Change field: "+cCaption, MessageBoxButtons.YesNo, MessageBoxDefaultButton.Button2) <> System.Windows.Forms.DialogResult.Yes
			Self:States_Refresh()
			Return False
		endif*/
	

	LOCAL cReplace AS STRING
	cReplace := "'"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"

	// Update States
	cStatement:="UPDATE DMFListItems SET"+;
				" "+cField+"="+cReplace+;
				" WHERE List_Item_UID="+cUID
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:States_Refresh()
		RETURN FALSE
	ENDIF

	// Update DataTable and Grid
	LOCAL oDataRow:=SELF:oDTStates:Rows:Find(oRow:Item["List_Item_UID"]:ToString()) AS DataRow
	IF oDataRow == NULL
		ErrorBox("Cannot access current row", "Not changed")
		RETURN FALSE
	ENDIF
	oDataRow:Item[cField]:=cValue
	SELF:oDTStates:AcceptChanges()
	// Invalidates the region occupied by the current View (adds it to the control's update region that will be repainted
	// during the next paint operation), and causes a paint message to be sent to the grid control
	SELF:gridviewlistitems:Invalidate()

	IF cField == "List_Item_UID"
		SELF:States_Refresh()
	ENDIF
RETURN TRUE


METHOD States_Delete() AS VOID
	LOCAL oRow AS DataRowView
	LOCAL nRowHandle := SELF:gridviewlistitems:FocusedRowHandle AS INT
	oRow:=(DataRowView)SELF:gridviewlistitems:GetRow(nRowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	LOCAL cStatement AS STRING
	//Local oDT1, oDT2 as DataTable
	//Local cStr1 := "", cStr2 := "" as string

	IF QuestionBox("Do you want to Delete the current Item:"+CRLF+CRLF+;
					oRow:Item["Description"]:ToString()+" ?", ;
					"Delete") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	cStatement:="DELETE FROM DMFListItems"+;
				" WHERE List_Item_UID="+oRow:Item["List_Item_UID"]:ToString()
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ErrorBox("Cannot Delete current row", "Deletion aborted")
		RETURN
	ENDIF

	IF SELF:gridviewlistitems:DataRowCount == 1
		SELF:oDTStates:Clear()
		RETURN
	ENDIF

	// Stop Notification
	SELF:lSuspendNotification := TRUE
	IF nRowHandle == 0
		SELF:gridviewlistitems:MoveNext()
	ELSE
		SELF:gridviewlistitems:MovePrev()
	ENDIF
	SELF:lSuspendNotification := FALSE

	LOCAL oDataRow AS DataRow
	oDataRow:=SELF:oDTStates:Rows:Find(oRow:Item["List_Item_UID"]:ToString())
	//wb(oRow:Item["MSG_UNIQUEID"]:ToString(), oDataRow)
	IF oDataRow <> NULL
		SELF:oDTStates:Rows:Remove(oDataRow)
//			cUIDs+=cUID+","
	ENDIF
RETURN
    

METHOD States_Refresh() AS VOID
LOCAL cUID AS STRING

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:gridviewlistitems:GetRow(SELF:gridviewlistitems:FocusedRowHandle)

	IF oRow <> NULL
		cUID := oRow:Item["List_Item_UID"]:ToString()
	ENDIF

	SELF:CreateGridStates()

	IF oRow <> NULL
		LOCAL col AS DevExpress.XtraGrid.Columns.GridColumn
		LOCAL nFocusedHandle AS INT

		col:=SELF:gridviewlistitems:Columns["List_Item_UID"]
		nFocusedHandle:=SELF:gridviewlistitems:LocateByValue(0, col, Convert.ToInt32(cUID))
		IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
			RETURN
		ENDIF

		SELF:gridviewlistitems:ClearSelection()
		SELF:gridviewlistitems:FocusedRowHandle:=nFocusedHandle
		SELF:gridviewlistitems:SelectRow(nFocusedHandle)
	ENDIF	
RETURN
    

METHOD States_Print() AS VOID
	SELF:PrintPreviewGridStates()
RETURN


METHOD States_Help() AS VOID
RETURN


#Region PrintPreview

METHOD PrintPreviewGridStates() AS VOID
	// Check whether the XtraGrid control can be previewed.
	IF ! SELF:GridStates:IsPrintingAvailable
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
	oLink:Component := SELF:GridStates
	// Set the paper format.
	oLink:PaperKind := System.Drawing.Printing.PaperKind.A4
	oLink:Landscape:=TRUE
	// Subscribe to the CreateReportHeaderArea event used to generate the report header.
	oLink:CreateReportHeaderArea += CreateAreaEventHandler{SELF, @PrintableComponentLinkStates_CreateReportHeaderArea()}
	// Generate the report.
	oLink:CreateDocument()
	// Hide Send via eMail TooBar Button
	oPS:SetCommandVisibility(PrintingSystemCommand.SendFile, CommandVisibility.None)
	// Show the report.
	oLink:ShowPreview()
RETURN


METHOD PrintableComponentLinkStates_CreateReportHeaderArea(sender AS OBJECT, e AS CreateAreaEventArgs) AS VOID
LOCAL cReportHeader := "List Items of ["+SELF:oCurrentRow:Item["Description"]:ToString()+"] - Printed on "+Datetime.Now:ToString(ccDateFormat)+", "+Datetime.Now:ToString("HH:mm:ss")+" - User: "+oUser:UserID AS STRING

	e:Graph:StringFormat := BrickStringFormat{StringAlignment.Center}
	e:Graph:Font := Font{"Tahoma", 14, FontStyle.Bold}

	LOCAL rec := RectangleF{0, 0, e:Graph:ClientPageSize:Width, 50} AS RectangleF
	e:Graph:DrawString(cReportHeader, Color.Black, rec, DevExpress.XtraPrinting.BorderSide.None)
RETURN

#EndRegion

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


METHOD FillStateDetails(oRow AS DataRowView) AS VOID

RETURN


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


METHOD ClearStateDetails() AS VOID
	
RETURN


METHOD SelectFolder() AS VOID

RETURN


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

END CLASS


/*Class UserInfo
Export cUserName, cUID as string

Constructor(_UserName as string, _UID as string)
	Self:cUserName := _UserName
	Self:cUID := _UID
Return

End Class*/