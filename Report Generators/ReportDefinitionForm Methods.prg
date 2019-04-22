// ReportDefinitionForm_Methods.prg
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Collections
#Using DevExpress.XtraGrid.Views.Grid
#Using DevExpress.XtraGrid.Views.Grid.ViewInfo
#using DevExpress.XtraGrid.Columns
#Using DevExpress.XtraEditors.Repository

//#Using DevExpress.XtraGrid.Views.Base
#using DevExpress.XtraPrinting
#Using DevExpress.XtraPrintingLinks

PARTIAL CLASS ReportDefinitionForm INHERIT DevExpress.XtraEditors.XtraForm
	PRIVATE oDTReports AS DataTable
	PRIVATE lCellValueChanged AS LOGIC
	PRIVATE lReady AS LOGIC
	EXPORT lGridUpdating AS LOGIC
	EXPORT cLastSelectedReportUID:="" AS STRING

	EXPORT oDTFormulas AS DataTable
	PRIVATE cEditID := "0" AS STRING
	PRIVATE oChangedForeColor, oChangedBackColor AS Color
	PRIVATE lValueChanging AS LOGIC
	PRIVATE oRow AS DataRowView
	PRIVATE lSuspendNotification AS LOGIC
	PRIVATE oEditColumn AS GridColumn
	PRIVATE oEditRow AS DataRowView

METHOD ReportDefinitionForm_OnLoad() AS VOID
	oSoftway:ReadFormSettings_DevExpress(SELF, SELF:splitContainerControl_Formulas, oMainForm:alForms, oMainForm:alData)

	SELF:Fill_LBCReports()
	SELF:CreateGridFormulas_Columns()
	SELF:CreateGridFormulas()
RETURN


//METHOD ReportDefinitionForm_OnShown() AS VOID
//	LOCAL oLBCItem := (MyLBCReportItem)SELF:LBCReports:GetItem(0) AS MyLBCReportItem
//	wb(oLBCItem:Name, oLBCItem:cUID)
//RETURN


METHOD Fill_LBCReports() AS VOID
	SELF:LBCReports:Items:Clear()

	LOCAL cStatement AS STRING
	cStatement:="SELECT * FROM FMReportDefinition"+;
				" ORDER BY Description"
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

	LOCAL oLBCItem AS MyLBCReportItem
	FOREACH oRow AS DataRow IN oDT:Rows
		oLBCItem := MyLBCReportItem{oRow["Description"]:ToString(), oRow["REPORT_UID"]:ToString()}
		SELF:LBCReports:Items:Add(oLBCItem)
	NEXT
RETURN


// Report Definition
METHOD GetSelectedReportDefinition(cField AS STRING) AS STRING
	LOCAL cRet AS STRING

	IF SELF:LBCReports:SelectedIndex == -1
		IF cField == "Name"
			cRet := ""
		ELSE
			cRet := "0"
		ENDIF
		RETURN cRet
	ENDIF

	LOCAL oLBCItem := (MyLBCReportItem)SELF:LBCReports:SelectedItem AS MyLBCReportItem
	IF cField == "Name"
		cRet := oLBCItem:Name
	ELSE
		cRet := oLBCItem:cUID
	ENDIF
RETURN cRet


METHOD ReportDefinition_AddNew() AS VOID
	LOCAL cStatement, cUID AS STRING

	IF QuestionBox("Do you want to create a New Report definition ?", "Add new Report definition") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	// Assign a non-existing Description to the New Report
	LOCAL cDescription, cNum AS STRING
	LOCAL nIndex AS INT
	cStatement:="SELECT Description FROM FMReportDefinition"+;
				" WHERE Description LIKE 'New Report-%'"+;
				" ORDER BY Description DESC"
	cStatement:=oSoftway:SelectTop(cStatement)
	cDescription:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Description")
	IF cDescription == ""
		cDescription:="New Report-1"
	ELSE
		nIndex:=cDescription:LastIndexOf("-") + 1
		cNum:=cDescription:Substring(nIndex)
		cNum:=(Convert.ToInt32(cNum) + 1):ToString()
		cDescription:=cDescription:Substring(0, nIndex) + cNum
	ENDIF

	cStatement:="INSERT INTO FMReportDefinition"+" (Description)"+;
					" VALUES ('"+cDescription+"')"
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ErrorBox("Cannot create Report definition record")
		RETURN
	ENDIF

	cUID:=oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "FMReportDefinition", "REPORT_UID")
	IF cUID == "0"
		ErrorBox("Cannot create Report definition record")
		RETURN
	ENDIF

	LOCAL oLBCItem := MyLBCReportItem{cDescription, cUID} AS MyLBCReportItem
	SELF:LBCReports:Items:Add(oLBCItem)

	//// Unselect all Reports (if the user opened the window from AddNew of the SparesForm or VirtualVesselForm)
	//LOCAL n AS INT
	//FOR n:=SELF:LVReports:SelectedItems:Count - 1 DOWNTO 0
	//	SELF:LVReports:SelectedItems[0]:Selected:=FALSE
	//NEXT

	// Select the New Report
	nIndex := SELF:LBCReports:FindStringExact(cDescription, 0)
	IF nIndex <> -1
		SELF:LBCReports:SelectedIndex := nIndex
	ENDIF
//	SELF:LVReports:SelectedItems[0]:BeginEdit()
RETURN


METHOD ReportDefinition_Edit() AS VOID
	IF SELF:LBCReports:SelectedIndex == -1
		RETURN
	ENDIF

	LOCAL oReportDefinitionRenameForm := ReportDefinitionRenameForm{} AS ReportDefinitionRenameForm
	oReportDefinitionRenameForm:ReportName:Text := SELF:GetSelectedReportDefinition("Name")
	IF oReportDefinitionRenameForm:ShowDialog() <> DialogResult.OK
		RETURN
	ENDIF

	LOCAL cDescription := oReportDefinitionRenameForm:ReportName:Text:Trim() AS STRING
	IF cDescription == ""
		ErrorBox("Report name not specified")
		RETURN
	ENDIF

	LOCAL cStatement AS STRING
	cStatement:="UPDATE FMReportDefinition SET"+;
				" Description='"+oSoftway:ConvertWildcards(cDescription, FALSE)+"'"+;
				" WHERE REPORT_UID="+SELF:GetSelectedReportDefinition("cUID")
	IF oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:lSuspendNotification := TRUE
		SELF:Fill_LBCReports()

		LOCAL nIndex := SELF:LBCReports:FindStringExact(cDescription, 0) AS INT
		SELF:lSuspendNotification := FALSE
		IF nIndex <> -1
			SELF:LBCReports:SelectedIndex := nIndex
		ELSE
			SELF:LBCReports:SelectedIndex := 0
		ENDIF
	ENDIF
RETURN


METHOD ReportDefinition_Delete() AS VOID
	IF SELF:LBCReports:SelectedItems:Count == 0
		wb("Please select a Report definition")
		RETURN
	ENDIF

	LOCAL oLBCItem := (MyLBCReportItem)SELF:LBCReports:SelectedItem AS MyLBCReportItem

	LOCAL cStatement AS STRING
	// Check [FMReportFormulas]
	cStatement:="SELECT Count(*) AS nCount"+;
				" FROM FMReportFormulas"+;
				" WHERE REPORT_UID="+oLBCItem:cUID
	IF oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "nCount") > "0"
		ErrorBox("The current Report definition is not empty", "Delete aborted")
		RETURN
	ENDIF

	IF QuestionBox("Do you want to Delete the Report definition ["+oLBCItem:Name+"] ?",;
					 "Delete Report definition") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	// Delete Division
	cStatement:="DELETE FROM FMReportDefinition"+;
				" WHERE REPORT_UID="+oLBCItem:cUID
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ErrorBox("Cannot Delete Report definition record")
	ENDIF

	SELF:Fill_LBCReports()
RETURN


METHOD ReportDefinition_Refresh() AS VOID
	SELF:lSuspendNotification := TRUE

	LOCAL nIndex AS INT
	IF SELF:LBCReports:SelectedIndex <> -1
		nIndex := SELF:LBCReports:SelectedIndex
		SELF:LBCReports:SetSelected(nIndex, FALSE)
	ENDIF

	SELF:Fill_LBCReports()

	SELF:lSuspendNotification := FALSE

	IF nIndex <> -1
		SELF:LBCReports:SetSelected(nIndex, TRUE)
	ENDIF
RETURN


METHOD PasteReportFormulas() AS VOID
	LOCAL oCopyReportDialog:=CopyReportDialog{} AS CopyReportDialog
	oCopyReportDialog:oReportDefinitionForm := SELF
	oCopyReportDialog:ShowDialog()
RETURN


// Report Formulas
METHOD CreateGridFormulas_Columns() AS VOID
LOCAL oColumn AS GridColumn
LOCAL nVisible:=0, nAbsIndex:=0 AS INT

	oColumn:=oMainForm:CreateDXColumn("Line", "LineNum",				FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																		nAbsIndex++, nVisible++, 45, SELF:GridViewFormulas)
    oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    oColumn:AppearanceHeader:Options:UseTextOptions := TRUE
    oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center

	oColumn:=oMainForm:CreateDXColumn("Description", "Description",		FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 150, SELF:GridViewFormulas)

	oColumn:=oMainForm:CreateDXColumn("Item ID", "ID",					FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 60, SELF:GridViewFormulas)
    oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    oColumn:AppearanceHeader:Options:UseTextOptions := TRUE
    oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
	// Repository for ID:
	LOCAL oRepositoryItemComboBoxID := RepositoryItemComboBox{} AS RepositoryItemComboBox
	oRepositoryItemComboBoxID:DropDownRows := 30
	// Fill RepositoryItemComboBox
	SELF:ChannelAndCustomItems(oRepositoryItemComboBoxID)
    oRepositoryItemComboBoxID:Properties:TextEditStyle := DevExpress.XtraEditors.Controls.TextEditStyles.DisableTextEditor
	//Add a repository item to the repository items of grid control
	//SELF:GridViewFormulas:RepositoryItems:Add(oRepositoryItemComboBoxID)
	//Now you can define the repository item as an inplace editor of columns
	oColumn:ColumnEdit := oRepositoryItemComboBoxID

	/*LOCAL oGridLookUpEdit_AllItems := SELF:ChannelAndCustomItems() AS DevExpress.XtraEditors.GridLookUpEdit
    oGridLookUpEdit_AllItems:Properties:TextEditStyle := DevExpress.XtraEditors.Controls.TextEditStyles.DisableTextEditor
	//Now you can define the repository item as an inplace editor of columns
	oColumn:ColumnEdit := oGridLookUpEdit_AllItems*/


	oColumn:=oMainForm:CreateDXColumn("Item Description", "MyItemDescription",FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 140, SELF:GridViewFormulas)
	oColumn:ColumnEdit := oRepositoryItemComboBoxID

	oColumn:=oMainForm:CreateDXColumn("Formula", "Formula",				FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 200, SELF:GridViewFormulas)

	oColumn:=oMainForm:CreateDXColumn("Hide line", "HideLine",			FALSE, DevExpress.Data.UnboundColumnType.Boolean, ;
																		nAbsIndex++, nVisible++, 60, SELF:GridViewFormulas)
    oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    oColumn:AppearanceHeader:Options:UseTextOptions := TRUE
    oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center

	oColumn:=oMainForm:CreateDXColumn("Bold", "Bold",					FALSE, DevExpress.Data.UnboundColumnType.Boolean, ;
																		nAbsIndex++, nVisible++, 50, SELF:GridViewFormulas)
    oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    oColumn:AppearanceHeader:Options:UseTextOptions := TRUE
    oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center

	oColumn:=oMainForm:CreateDXColumn("Underline", "Underline",			FALSE, DevExpress.Data.UnboundColumnType.Boolean, ;
																		nAbsIndex++, nVisible++, 60, SELF:GridViewFormulas)
    oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    oColumn:AppearanceHeader:Options:UseTextOptions := TRUE
    oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center

    LOCAL repositoryItemColorEdit1 := DevExpress.XtraEditors.Repository.RepositoryItemColorEdit{} AS DevExpress.XtraEditors.Repository.RepositoryItemColorEdit
    repositoryItemColorEdit1:AutoHeight := FALSE
//    repositoryItemColorEdit1:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{DevExpress.XtraEditors.Controls.ButtonPredefines.Combo} })
    repositoryItemColorEdit1:Name := "repositoryItemColorEdit1"
    repositoryItemColorEdit1:ShowDropDown := DevExpress.XtraEditors.Controls.ShowDropDown.DoubleClick

	oColumn:=oMainForm:CreateDXColumn("ForeColor", "uForeColor",			FALSE, DevExpress.Data.UnboundColumnType.Object, ;
																		nAbsIndex++, nVisible++, 110, SELF:GridViewFormulas)
	oColumn:ColumnEdit := repositoryItemColorEdit1

    LOCAL repositoryItemColorEdit2 := DevExpress.XtraEditors.Repository.RepositoryItemColorEdit{} AS DevExpress.XtraEditors.Repository.RepositoryItemColorEdit
    repositoryItemColorEdit2:AutoHeight := FALSE
    //repositoryItemColorEdit2:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{DevExpress.XtraEditors.Controls.ButtonPredefines.Combo} })
    repositoryItemColorEdit2:Name := "repositoryItemColorEdit2"
    repositoryItemColorEdit2:ShowDropDown := DevExpress.XtraEditors.Controls.ShowDropDown.DoubleClick

	oColumn:=oMainForm:CreateDXColumn("BackColor", "uBackColor",			FALSE, DevExpress.Data.UnboundColumnType.Object, ;
																		nAbsIndex++, nVisible++, 110, SELF:GridViewFormulas)
	oColumn:ColumnEdit := repositoryItemColorEdit2

	// ToolTip
	//oColumn:ToolTip := "An Account may be either a 'Group Account' or a 'Ledger Account'"

	// Invisible
	oColumn:=oMainForm:CreateDXColumn("REPORT_UID","REPORT_UID",		FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																		nAbsIndex++, -1, -1, SELF:GridViewFormulas)
	oColumn:Visible:=FALSE

	oColumn:=oMainForm:CreateDXColumn("FORMULA_UID","FORMULA_UID",		FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																		nAbsIndex++, -1, -1, SELF:GridViewFormulas)
	oColumn:Visible:=FALSE
RETURN


METHOD CreateGridFormulas() AS VOID
	LOCAL cConcat AS STRING
	DO CASE
	CASE symServer == #SQLite
		cConcat := "FMReportItems.ItemName || ' (' || FMReportItems.Unit || ')'"
	//CASE symServer == #MySQL
		//cConcat := "Concat(Concat(FMReportItems.ItemName, '  '), FMReportItems.Unit)"
	OTHERWISE
		cConcat := "(CASE WHEN FMReportItems.Unit='' THEN FMReportItems.ItemName ELSE FMReportItems.ItemName+' ('+FMReportItems.Unit+')' END)"
		//cConcat := "FMReportItems.ItemName+' ('+FMReportItems.Unit+')'"
	ENDCASE

	LOCAL cConcat1 AS STRING
	DO CASE
	CASE symServer == #SQLite
		cConcat1 := "FMCustomItems.Description || ' (' || FMCustomItems.Unit || ')'"
	//CASE symServer == #MySQL
		//cConcat := "Concat(Concat(FMCustomItems.ItemName, '  '), FMCustomItems.Unit)"
	OTHERWISE
		cConcat1 := "FMCustomItems.Description+' ('+FMCustomItems.Unit+')'"
	ENDCASE

	LOCAL cStatement AS STRING
	cStatement:="SELECT FMReportFormulas.FORMULA_UID, FMReportFormulas.REPORT_UID, FMReportFormulas.Description, FMReportFormulas.ID,"+;
				" "+cConcat+" AS ItemDescription,  "+cConcat1+" AS CustomItemDescription,"+;
				" FMReportFormulas.Formula, FMReportFormulas.LineNum, FMReportFormulas.HideLine, FMReportFormulas.Bold, FMReportFormulas.Underline,"+;
				" FMReportFormulas.ForeColor, FMReportFormulas.BackColor"+;
				" FROM FMReportFormulas"+;
				" LEFT OUTER JOIN FMCustomItems ON FMCustomItems.ID=FMReportFormulas.ID"+;
				" LEFT OUTER JOIN FMReportItems ON FMReportItems.ItemNo=FMReportFormulas.ID"+;
				" WHERE FMReportFormulas.REPORT_UID="+SELF:GetSelectedReportDefinition("cUID")+;
				" ORDER BY LineNum"
	//memowrit(cTempDocDir+"\st.txt", cStatement)
	SELF:oDTFormulas := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	SELF:oDTFormulas:TableName:="FMReportFormulas"
	// Create Primary Key
	oSoftway:CreatePK(SELF:oDTFormulas, "FORMULA_UID")
	SELF:GridFormulas:DataSource := SELF:oDTFormulas

	//SELF:barStaticItem_Vouchers:Caption := "Vouchers: "+SELF:oDTVouchers:Rows:Count:ToString()
RETURN


/*METHOD ChannelAndCustomItems() AS DevExpress.XtraEditors.GridLookUpEdit
	LOCAL oGridLookUpEdit_AllItems := SELF:ChannelAndCustomItems() AS DevExpress.XtraEditors.GridLookUpEdit
	oGridLookUpEdit_AllItems:Name := "GridLookUpEdit_AllItems"
	oGridLookUpEdit_AllItems:Size := System.Drawing.Size{242, 20}

	LOCAL cStatement, cConcat AS STRING

	DO CASE
	CASE symServer == #SQLite
		cConcat := "Description || ' (' || Unit || ')'"
	//CASE symServer == #MySQL
		//cConcat := "Concat(Concat(FMReportItems.Description, '  '), FMReportItems.Unit)"
	OTHERWISE
		cConcat := "Description+' ('+Unit+')'"
	ENDCASE

	cStatement:="SELECT ID, "+cConcat+" AS ComboName"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" UNION"+;
				" SELECT ID, "+cConcat+" AS ComboName"+;
				" FROM FMCustomItems"+;
				" ORDER BY ID"

	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oDT:TableName := "AllItems"

	//oGridLookUpEdit_AllItems:DataBindings:Add("EditValue", oDT, "AllItems")

	oGridLookUpEdit_AllItems:Properties:DataSource := oDT
	oGridLookUpEdit_AllItems:Properties:DisplayMember := oDT:Columns["ComboName"]:ToString()
	oGridLookUpEdit_AllItems:Properties:ValueMember := oDT:Columns["ID"]:ToString()

	oGridLookUpEdit_AllItems:Properties:View:BestFitColumns()
RETURN oGridLookUpEdit_AllItems*/


METHOD ChannelAndCustomItems(oRepositoryItemComboBoxID AS RepositoryItemComboBox) AS VOID
	LOCAL cStatement, cConcat1, cConcat2 AS STRING

	DO CASE
	CASE symServer == #SQLite
		cConcat1 := "FMReportItems.ItemName || ' (' || Unit || ')'"
		cConcat2 := "FMCustomItems.Description || ' (' || Unit || ')'"
	//CASE symServer == #MySQL
		//cConcat := "Concat(Concat(FMReportItems.Description, '  '), FMReportItems.Unit)"
	OTHERWISE
		cConcat1 := "(CASE WHEN Unit='' THEN FMReportItems.ItemName ELSE FMReportItems.ItemName+' ('+Unit+')' END)"
		//cConcat1 := "FMReportItems.ItemName+' ('+Unit+')'"
		cConcat2 := "FMCustomItems.Description+' ('+Unit+')'"
	ENDCASE

	cStatement:="SELECT ItemNo AS ID, "+cConcat1+" AS ComboName"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" UNION"+;
				" SELECT ID, "+cConcat2+" AS ComboName"+;
				" FROM FMCustomItems"+;
				" UNION"+;
				" SELECT 0 AS ID, ' ' AS ComboName"+;
				" ORDER BY ID"
	//memowrit(cTempDocDir+"\st.txt", cStatement)
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oDT:TableName := "AllItems"

	//LOCAL oLBCItem AS MyLBCReportItem
	FOREACH oRow AS DataRow IN oDT:Rows
		//oLBCItem := MyLBCReportItem{oRow["ID"]:ToString()+"  "+oRow["ComboName"]:ToString(), oRow["ID"]:ToString()}
		//oRepositoryItemComboBoxID:Items:Add(oLBCItem)
		oRepositoryItemComboBoxID:Items:Add(oRow["ID"]:ToString()+"  "+oRow["ComboName"]:ToString())
	NEXT
RETURN


METHOD SetEditModeOff_Common(oGridView AS GridView) AS VOID
	TRY
		IF oGridView:FocusedColumn <> NULL .and. oGridView:FocusedColumn:UnboundType == DevExpress.Data.UnboundColumnType.Boolean
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
RETURN


METHOD CustomUnboundColumnData_GridFormulas(e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs) AS VOID
// Provides data for the UnboundColumns

IF ! e:IsGetData
	RETURN
ENDIF

LOCAL oRow AS DataRow
	DO CASE
	CASE e:Column:FieldName == "uForeColor"
		oRow:=SELF:oDTFormulas:Rows[e:ListSourceRowIndex]

		LOCAL oColor AS System.Drawing.Color
		oColor := oMainForm:AssignColor(oRow:Item["ForeColor"]:ToString())
		// The Color contains: <A, R, G, B>. The saved Table column has: <R, G, B>
		e:Value := oColor:ToArgb()

	CASE e:Column:FieldName == "uBackColor"
		oRow:=SELF:oDTFormulas:Rows[e:ListSourceRowIndex]

		LOCAL oColor AS System.Drawing.Color
		oColor := oMainForm:AssignColor(oRow:Item["BackColor"]:ToString())
		// The Color contains: <A, R, G, B>. The saved Table column has: <R, G, B>
		e:Value := oColor:ToArgb()

	CASE e:Column:FieldName == "MyItemDescription"
		oRow:=SELF:oDTFormulas:Rows[e:ListSourceRowIndex]
		LOCAL cID := oRow["ID"]:ToString() AS STRING
		LOCAL cDescription := oRow["ItemDescription"]:ToString() AS STRING
		e:Value := IIf(cID == "0" .or. cDescription <> "", cDescription, oRow["CustomItemDescription"]:ToString())
	ENDCASE
RETURN


METHOD BeforeLeaveRow_GridViewFormulas(e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.Void
	IF SELF:lSuspendNotification
		RETURN
	ENDIF

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewFormulas:GetRow(e:RowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	/*// Validate
	do case
	case oRow:Item["Description"]:ToString() == ""
		wb("The 'Description' field must be defined")
		e:Allow := False
		Return
	endcase*/

	// EditMode: OFF
	SELF:SetEditModeOff_Common(SELF:GridViewFormulas)
RETURN


METHOD GridViewFormulas_Add() AS VOID
	LOCAL cStatement, cNum AS STRING

	IF QuestionBox("Do you want to create a New Line ?", "Add new Line") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	// Get new LineNum
	cStatement:="SELECT Max(LineNum)+1 AS nLineNum FROM FMReportFormulas"+;
				" WHERE REPORT_UID="+SELF:GetSelectedReportDefinition("cUID")
	cNum:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "nLineNum")
	//wb("|"+cNum+"|")
	IF cNum == "" .or. cNum == "0"
		cNum:="1"
	//	ErrorBox("Cannot get new LineNum", ;
	//				"Append aborded")
	//	return
	ENDIF

	// Insert Formula
	LOCAL cReportUID := SELF:GetSelectedReportDefinition("cUID") AS STRING
	cStatement:="INSERT INTO FMReportFormulas"+" (REPORT_UID, LineNum, Formula) VALUES"+;
				" ("+cReportUID+","+cNum+", '')"
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ErrorBox("Cannot append new Formula record", ;
					"Append aborded")
	ENDIF

	LOCAL cUID := oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "FMReportDefinition", "FORMULA_UID") AS STRING

	// Add new row to DataTable
	LOCAL oDataRow := SELF:oDTFormulas:NewRow() AS DataRow
	oDataRow["FORMULA_UID"] :=  cUID
	oDataRow["REPORT_UID"]	:=  cReportUID
	oDataRow["LineNum"]		:=  cNum
	oDataRow["HideLine"]	:=  FALSE
	oDataRow["Bold"]		:=  FALSE
	oDataRow["Underline"]	:=  FALSE
	oDataRow["ForeColor"]	:=  0
	oDataRow["BackColor"]	:=  16777215
	SELF:oDTFormulas:Rows:Add(oDataRow)
	SELF:oDTFormulas:AcceptChanges()

	// Select the New Formula
	Local nFocusedHandle as int
	nFocusedHandle:=SELF:GridViewFormulas:LocateByValue(0, SELF:GridViewFormulas:Columns["FORMULA_UID"], Convert.ToInt32(cUID))
	IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
		RETURN
	ENDIF
	SELF:GridViewFormulas:ClearSelection()
	SELF:GridViewFormulas:FocusedRowHandle:=nFocusedHandle
	SELF:GridViewFormulas:SelectRow(nFocusedHandle)
	//SELF:GridFormulas1:CurrentCell:=SELF:GridFormulas1:Rows[SELF:GridFormulas1:Rows:Count - 1]:Cells["LineNum"]
RETURN


METHOD GridViewFormulas_Delete() AS VOID
	LOCAL cStatement AS STRING
	LOCAL oRow := (DataRowView)SELF:GridViewFormulas:GetFocusedRow() AS DataRowView

	IF QuestionBox("Do you want to Delete the Line: "+oRow["LineNum"]:ToString()+;
					" - '"+oRow["Description"]:ToString()+"' ?", ;
					"Delete line") == System.Windows.Forms.DialogResult.No
		RETURN							 
	ENDIF

	// Delete Formula record
	LOCAL cUID := oRow["FORMULA_UID"]:ToString() as String
	cStatement:="DELETE FROM FMReportFormulas"+;
				" WHERE FORMULA_UID="+cUID
	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)

	LOCAL oDataRow := SELF:oDTFormulas:Rows:Find(cUID) AS DataRow
	IF oDataRow == NULL
		ErrorBox("Cannot access current row")
		RETURN
	ENDIF
	SELF:oDTFormulas:Rows:Remove(oDataRow)
RETURN


METHOD GridViewFormulas_Edit(oRow AS DataRowView, oColumn AS GridColumn) AS VOID
	IF oRow == NULL
		RETURN
	ENDIF

	LOCAL cField := oColumn:FieldName AS STRING
	IF ! InListExact(cField, "LineNum", "Description", "ID", "MyItemDescription", "Formula", "uForeColor", "uBackColor")	// , "HideLine", "Bold", "Underline"
		wb("The column '"+oColumn:Caption+"' is ReadOnly")
		RETURN
	ENDIF

	SELF:oEditColumn := oColumn
	SELF:oEditRow := oRow

	SELF:oEditColumn:OptionsColumn:AllowEdit := TRUE
    SELF:GridViewFormulas:OptionsSelection:EnableAppearanceFocusedCell := TRUE
	SELF:GridViewFormulas:ShowEditor()
RETURN


METHOD GridViewFormulas_Save(e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs) AS VOID
LOCAL cStatement, cUID, cField, cValue, cNum AS STRING

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewFormulas:GetRow(e:RowHandle)

	cUID := oRow:Item["FORMULA_UID"]:ToString()
	LOCAL cReportUID := oRow:Item["REPORT_UID"]:ToString() AS STRING

	cField := e:Column:FieldName
	cValue := e:Value:ToString():Trim()

	// Validate cValue
	LOCAL ucField, cReplace AS STRING

	DO CASE
	CASE cField == "Description" .AND. cValue:Length > 128
		ErrorBox("The field '"+cField+"' must contain up to 128 characters", "Editing aborted")
		SELF:GridViewFormulas_Refresh()
		RETURN

	CASE cField == "Formula" .AND. cValue:Length > 1000
		ErrorBox("The field '"+cField+"' must contain up to 1000 characters", "Editing aborted")
		SELF:GridViewFormulas_Refresh()
		RETURN
	ENDCASE

	DO CASE
	CASE cField == "uForeColor"
		ucField := cField
		// Remove the leading 'u'
		cField := cField:Substring(1)
		// The Color contains: <A, R, G, B>. The saved Table column has: <R, G, B>
		cReplace := RGB(SELF:oChangedForeColor:R, SELF:oChangedForeColor:G, SELF:oChangedForeColor:B):ToString()

	CASE cField == "uBackColor"
		ucField := cField
		// Remove the leading 'u'
		cField := cField:Substring(1)
		// The Color contains: <A, R, G, B>. The saved Table column has: <R, G, B>
		cReplace := RGB(SELF:oChangedBackColor:R, SELF:oChangedBackColor:G, SELF:oChangedBackColor:B):ToString()

	//CASE cField == "ItemSelected"
	//	cReplace := Iif(SELF:lChecked, "1", "0")

	CASE cField == "LineNum"
		IF cValue == "" .or. cValue == "0" .or. Convert.Toint64(cValue) > 16000
			ErrorBox("Please specify a valid Line (1 - 16000)")
			SELF:GridViewFormulas_Refresh()
			RETURN
		ENDIF

		// Check if LineNum exists
		cStatement:="SELECT LineNum FROM FMReportFormulas"+;
					" WHERE REPORT_UID="+cReportUID+;
					" AND LineNum="+cValue
		cNum := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "LineNum")
		IF cNum <> ""
			IF QuestionBox("Line already exists"+CRLF+;
							"All lines will shift-down starting from Line: "+cValue+CRLF+CRLF+;
							"Do you want to proceed ?",;
							"Line already exists") <> System.Windows.Forms.DialogResult.Yes
				SELF:GridViewFormulas_Refresh()
				RETURN
			ENDIF
			// Shift-down all lines
			cStatement:="UPDATE FMReportFormulas"+;
						" SET LineNum=LineNum + 1"+;
						" WHERE REPORT_UID="+cReportUID+;
						" AND LineNum >= "+cValue
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ENDIF
		cReplace := cValue

	CASE InListExact(cField, "ID", "MyItemDescription")
		cField := "ID"
		cValue := SELF:cEditID
		IF cValue == ""
			//ErrorBox("Please specify a valid Item ID")
			RETURN
		ENDIF
		cReplace := cValue

	OTHERWISE
		cReplace := "'"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"
	ENDCASE

	// Update FMReportFormulas
	cStatement:="UPDATE FMReportFormulas SET"+;
				" "+cField+"="+cReplace+;
				" WHERE FORMULA_UID="+cUID
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:GridViewFormulas_Refresh()
		RETURN
	ENDIF

	// Update DataTable and Grid
	LOCAL oDataRow := SELF:oDTFormulas:Rows:Find(cUID) AS DataRow
	IF oDataRow == NULL
		ErrorBox("Cannot access current row", "Not changed")
		RETURN
	ENDIF
	IF ucField <> NULL
		//oDataRow:Item[cField]:=cReplace
		//oRow:Item["IO"] := cValue
		SELF:GridViewFormulas_Refresh()
	ELSE
		oDataRow:Item[cField] := cValue
	ENDIF
	SELF:oDTFormulas:AcceptChanges()
	// Invalidates the region occupied by the current View (adds it to the control's update region that will be repainted
	// during the next paint operation), and causes a paint message to be sent to the grid control
	SELF:GridViewFormulas:Invalidate()

	DO CASE
	CASE cField == "ID" .or. cField == "LineNum"
		SELF:GridViewFormulas_Refresh()

		IF cField == "ID" .and. oRow["Description"]:ToString():Trim() == ""
			oDataRow := SELF:oDTFormulas:Rows:Find(cUID)
			IF oDataRow <> NULL
				// Update Description if empty
				LOCAL cDescription := Iif(oDataRow["ItemDescription"]:ToString() == "", oDataRow["CustomItemDescription"]:ToString(), oDataRow["ItemDescription"]:ToString()) AS STRING
				cStatement:="UPDATE FMReportFormulas SET"+;
							" Description='"+oSoftway:ConvertWildCards(cDescription, FALSE)+"'"+;
							" WHERE FORMULA_UID="+cUID
				oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				oDataRow:Item["Description"] := cDescription
				SELF:oDTFormulas:AcceptChanges()
				// Invalidates the region occupied by the current View (adds it to the control's update region that will be repainted
				// during the next paint operation), and causes a paint message to be sent to the grid control
				SELF:GridViewFormulas:Invalidate()
			ENDIF
		ENDIF

	CASE cField == "Formula" .and. oRow["Description"]:ToString():Trim() == ""
		oDataRow := SELF:oDTFormulas:Rows:Find(cUID)
		IF oDataRow <> NULL
			// Update Description if empty
			LOCAL cDescription := oDataRow["Formula"]:ToString() AS STRING
			cStatement:="UPDATE FMReportFormulas SET"+;
						" Description='"+oSoftway:ConvertWildCards(cDescription, FALSE)+"'"+;
						" WHERE FORMULA_UID="+cUID
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			oDataRow:Item["Description"] := cDescription
			SELF:oDTFormulas:AcceptChanges()
			// Invalidates the region occupied by the current View (adds it to the control's update region that will be repainted
			// during the next paint operation), and causes a paint message to be sent to the grid control
			SELF:GridViewFormulas:Invalidate()
		ENDIF
	ENDCASE

/*	// Update oMainForm:oDTLookUpEdit_StateFlag DataTable
	Local aActiveMainUserControls := oMainForm:AllActiveMainUserControls as MainUserControl[]
	Local n, nCount := aActiveMainUserControls:Length as int
	For n:=1 upto nCount
		if aActiveMainUserControls[n]:oDTLookUpEdit_StateFlag <> NULL
			aActiveMainUserControls[n]:UpdateTable_LookUpEdit_StateFlag()
		endif
	Next*/
RETURN


METHOD GridViewFormulas_Refresh() AS VOID
LOCAL cUID AS STRING

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewFormulas:GetRow(SELF:GridViewFormulas:FocusedRowHandle)

	IF oRow <> NULL
		cUID := oRow:Item["FORMULA_UID"]:ToString()
	ENDIF

	SELF:CreateGridFormulas()

	IF oRow <> NULL
		LOCAL col AS DevExpress.XtraGrid.Columns.GridColumn
		LOCAL nFocusedHandle AS INT

		col:=SELF:GridViewFormulas:Columns["FORMULA_UID"]
		nFocusedHandle:=SELF:GridViewFormulas:LocateByValue(0, col, Convert.ToInt32(cUID))
		IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
			RETURN
		ENDIF

		SELF:GridViewFormulas:ClearSelection()
		SELF:GridViewFormulas:FocusedRowHandle:=nFocusedHandle
		SELF:GridViewFormulas:SelectRow(nFocusedHandle)
	ENDIF	
RETURN


#Region PrintPreview

METHOD PrintPreviewGrid(oGrid AS DevExpress.XtraGrid.GridControl) AS VOID
	IF oGrid:Views[0]:RowCount == 0
		RETURN
	ENDIF

	// Check whether the XtraGrid control can be previewed.
	IF ! oGrid:IsPrintingAvailable
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
	oLink:Component := oGrid
	// Set the paper format.
	oLink:PaperKind := System.Drawing.Printing.PaperKind.A4
	oLink:Landscape := TRUE
	// Subscribe to the CreateReportHeaderArea event used to generate the report header.
	oLink:CreateReportHeaderArea += CreateAreaEventHandler{SELF, @PrintableComponentGrid_CreateReportHeaderArea()}
	// Generate the report.
	oLink:CreateDocument()
	// Hide Send via eMail TooBar Button
	oPS:SetCommandVisibility(PrintingSystemCommand.SendFile, CommandVisibility.None)
	// Show the report.
	oLink:ShowPreview()
RETURN


METHOD PrintableComponentGrid_CreateReportHeaderArea(sender AS OBJECT, e AS CreateAreaEventArgs) AS VOID
	LOCAL cReportHeader AS STRING

	cReportHeader := "User defined Reports using Items and Formulas: "+SELF:GetSelectedReportDefinition("Name")+" - Date: "+Datetime.Parse(DateTime.Now:ToString()):ToString(ccDateFormat)

	e:Graph:StringFormat := BrickStringFormat{StringAlignment.Center}
	//e:Graph:Font := Font{"Tahoma", 14, FontStyle.Bold}
	e:Graph:Font := Font{"Tahoma", 12, FontStyle.Bold}

	LOCAL rec := RectangleF{0, 0, e:Graph:ClientPageSize:Width, 50} AS RectangleF
	e:Graph:DrawString(cReportHeader, Color.Black, rec, DevExpress.XtraPrinting.BorderSide.None)
RETURN

#EndRegion


METHOD CustomItems() AS VOID
	//LOCAL oFormulaEditorForm := FormulaEditorForm{} AS FormulaEditorForm
	//oFormulaEditorForm:Show()
	LOCAL oCustomItemsForm := CustomItemsForm{} AS CustomItemsForm
	oCustomItemsForm:ShowDialog()
RETURN


METHOD HelpAbout() AS VOID
	LOCAL cStr:="" AS STRING

	cStr += "Formula field Functions:"+CRLF+CRLF+CRLF
	cStr += "- User-defined variable i.e. A, AZ7, B, Speed, Power etc. to display"+CRLF+"the value of the selected Item (when ItemID is non-zero)"+CRLF+CRLF
	cStr += "- Any Formula containing: '+, -, *, /' operators like: A=B+C, B-C, A*C"+CRLF+"(where B, C already defined in previous Formula lines."+CRLF+CRLF
	cStr += "- (Avg) for Average value of the selected Item"+CRLF+"(where ItemID of that line is non-zero)"+CRLF+CRLF
	cStr += "- (Sum) for Summary value of the selected Item"+CRLF+"(where ItemID of that line is non-zero)"+CRLF+CRLF
	cStr += "- (First) for the First value of the selected Item"+CRLF+"(where ItemID of that line is non-zero)"+CRLF+CRLF
	cStr += "- (Last) for the Last value of the selected Item"+CRLF+"(where ItemID of that line is non-zero)"+CRLF+CRLF
	cStr += "- After the 4 function names: (Avg), (Sum), (First), (Last)"+CRLF+;
			"you may specify a variable name like: (Avg)Speed or: Speed(Avg)"+CRLF+;
			"in order to use the variable 'Speed' in consequent calculations"+CRLF+CRLF

	InfoBox(cStr, "Formula Syntax")
RETURN

END CLASS


CLASS MyLBCReportItem INHERIT OBJECT
	EXPORT Name, cUID AS STRING

	CONSTRUCTOR(_Name AS STRING, _cUID AS STRING)
		SELF:Name := _Name
		SELF:cUID := _cUID
	RETURN

	VIRTUAL METHOD ToString() AS STRING
	RETURN SELF:Name
END CLASS
