// ComboboxColors.prg
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
#Using DevExpress.XtraEditors.Controls 
#using DevExpress.XtraPrinting
#Using DevExpress.XtraPrintingLinks
#using System.Data.SqlClient

partial CLASS ComboboxColors INHERIT System.Windows.Forms.Form

PRIVATE METHOD bbiAddItemClick() AS System.Void
	
	IF QuestionBox("Do you want to Add a new Report ?", ;
					"Add") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF
	LOCAL cStatement, cUID AS STRING

	cStatement:="INSERT INTO FMComboboxColors (TextValue, ComboColor) VALUES"+;
				" ('_ComboBoxText', 0)"
	if ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		Self:Reports_Refresh()
		Return
	endif
	cUID:=oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "FMComboboxColors", "CC_UID")

	Self:Reports_Refresh()

	Local nFocusedHandle as int
	nFocusedHandle:=Self:GridViewReports:LocateByValue(0, Self:GridViewReports:Columns["CC_UID"], Convert.ToInt32(cUID))
	if nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
		Return
	endif
	Self:GridViewReports:ClearSelection()
	Self:GridViewReports:FocusedRowHandle:=nFocusedHandle
	SELF:GridViewReports:SelectRow(nFocusedHandle)

RETURN

PRIVATE METHOD ComboboxColorsShown() AS VOID

	SELF:GridViewReports:OptionsSelection:MultiSelect := False
	self:CreateGridReports_Columns()
	SELF:CreateGridReports()
RETURN

METHOD CreateGridReports() AS VOID
	LOCAL cStatement AS STRING

	cStatement:="SELECT CC_UID, FK_REPORT_UID , FMReportTypes.ReportName, TextValue, ComboColor "+;
				" FROM FMComboboxColors "+;
				" Left Outer Join FMReportTypes ON FMReportTypes.REPORT_UID=FMComboboxColors.FK_REPORT_UID "+;
				" ORDER BY CC_UID Desc"
	SELF:oDTReports:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	Self:oDTReports:TableName:="Reports"
	// Create Primary Key
	oSoftway:CreatePK(Self:oDTReports, "CC_UID")

	SELF:GridReports:DataSource := SELF:oDTReports

	SELF:GridReports:ForceInitialize()

	//LOCAL repositoryItemColorEdit1 := DevExpress.XtraEditors.Repository.RepositoryItemColorEdit{} AS DevExpress.XtraEditors.Repository.RepositoryItemColorEdit
	//self:GridViewReports:Columns["ComboColor"]:ColumnEdit := repositoryItemColorEdit1

RETURN

METHOD Reports_Refresh() AS VOID
	LOCAL cUID AS STRING

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewReports:GetRow(SELF:GridViewReports:FocusedRowHandle)

	if oRow <> NULL
		cUID := oRow:Item["CC_UID"]:ToString()
	ENDIF

	Self:CreateGridReports()

	if oRow <> NULL
		Local col as DevExpress.XtraGrid.Columns.GridColumn
		Local nFocusedHandle as int

		col:=Self:GridViewReports:Columns["CC_UID"]
		nFocusedHandle:=Self:GridViewReports:LocateByValue(0, col, Convert.ToInt32(cUID))
		if nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
			Return
		endif

		Self:GridViewReports:ClearSelection()
		Self:GridViewReports:FocusedRowHandle:=nFocusedHandle
		Self:GridViewReports:SelectRow(nFocusedHandle)
	endif	
RETURN

PRIVATE METHOD GridViewReportsCellValueChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
	LOCAL cStatement, cUID, cField, cValue, cDuplicate AS STRING

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewReports:GetRow(e:RowHandle)

	cUID := oRow:Item["CC_UID"]:ToString()

	cField := e:Column:FieldName
	cValue := e:Value:ToString():Trim()

	// Validate cValue
	DO CASE
	CASE InListExact(cField, "TextValue") .and. cValue:Length > 128
		ErrorBox("The field '"+cField+"' must contain up to 128 characters", "Editing aborted")
		SELF:Reports_Refresh()
		RETURN
	ENDCASE

	LOCAL ucField, cReplace AS STRING

	DO CASE

	CASE cField == "uComboColor"
		ucField := cField
		// Remove the leading 'u'
		cField := cField:Substring(1)
		// The Color contains: <A, R, G, B>. The saved Table column has: <R, G, B>
		cReplace := RGB(SELF:oChangedReportColor:R, SELF:oChangedReportColor:G, SELF:oChangedReportColor:B):ToString()
	OTHERWISE
		cReplace := "'"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"
	ENDCASE

	// Update Reports
	cStatement:="UPDATE FMComboboxColors SET"+;
				" "+cField+"="+cReplace+;
				" WHERE CC_UID="+cUID
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:Reports_Refresh()
		RETURN
	ENDIF

	// Update DataTable and Grid
	LOCAL oDataRow:=SELF:oDTReports:Rows:Find(oRow:Item["CC_UID"]:ToString()) AS DataRow
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
	// Update oMainForm:oDTLookUpEdit_StateFlag DataTable
RETURN

PRIVATE METHOD GridViewReportsCustomUnboundColumnData( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs ) AS System.Void
	IF ! e:IsGetData
		RETURN
	ENDIF

	LOCAL oRow AS DataRow
	LOCAL cField,cValue as String
	DO CASE
	CASE e:Column:FieldName == "uComboColor"
		oRow:=SELF:oDTReports:Rows[e:ListSourceRowIndex]
		LOCAL oColor AS System.Drawing.Color
		oColor := oMainForm:AssignColor(oRow:Item["ComboColor"]:ToString())
		// The Color contains: <A, R, G, B>. The saved Table column has: <R, G, B>
		e:Value := oColor:ToArgb()
	ENDCASE
RETURN

METHOD CreateGridReports_Columns() AS VOID
LOCAL oColumn AS GridColumn
Local nVisible:=0, nAbsIndex:=0 as int


	//
	oColumn:=oMainForm:CreateDXColumn("Report", "FK_REPORT_UID",			true, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 70, SELF:GridViewReports)
	oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    oColumn:AppearanceHeader:Options:UseTextOptions := TRUE
    oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
	LOCAL oRepositoryItemComboBoxItemType := RepositoryItemComboBox{} AS RepositoryItemComboBox
	
	LOCAL cStatement AS STRING
	cStatement:="SELECT REPORT_UID, ReportName FROM FMReportTypes"+oMainForm:cNoLockTerm+;
				" UNION SELECT 0 AS REPORT_UID, 'All Reports' AS ReportName"+;
				" ORDER BY REPORT_UID"
	//Reports
    
	LOCAL oDTTemp:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oDTTemp:TableName:="Reports"
	oSoftway:CreatePK(oDTTemp, "REPORT_UID")
	LOCAL dscombo := DataSet{} AS DataSet
	dscombo:Tables:Add(oDTTemp)    
    LOCAL myLookup := RepositoryItemLookUpEdit{} AS RepositoryItemLookUpEdit
	LOCAL BsType := BindingSource{} AS BindingSource
    BsType := BindingSource{dscombo, "Reports"}
    myLookup:DataSource := BsType
    myLookup:DisplayMember := "ReportName"
    myLookup:ValueMember := "REPORT_UID"
    myLookup:NullText := "No report set"
    myLookup:AutoSearchColumnIndex := 1
    myLookup:PopulateColumns()
    myLookup:Columns["REPORT_UID"]:Visible := FALSE
    oColumn:ColumnEdit := myLookup
	//

	oColumn:=oMainForm:CreateDXColumn("Combo Value", "TextValue",		true, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 300, SELF:GridViewReports)

	//
	LOCAL repositoryItemColorEdit1 := DevExpress.XtraEditors.Repository.RepositoryItemColorEdit{} AS DevExpress.XtraEditors.Repository.RepositoryItemColorEdit
	oColumn:=oMainForm:CreateDXColumn("Color",	"uComboColor",	true, DevExpress.Data.UnboundColumnType.Object, ;
																		nAbsIndex++, nVisible++, 100, SELF:GridViewReports)
	oColumn:ColumnEdit := repositoryItemColorEdit1
	// ToolTip
	oColumn:ToolTip := "Click the cell to change the Report Color"
	//oColumn:ToolTip := "Double-click a cell to change the ReportColor"
	//SELF:Fill_LookUpEdit_ReportColor()
	// Invisible
	oColumn:=oMainForm:CreateDXColumn("CC_UID","CC_UID",FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																		nAbsIndex++, -1, -1, SELF:GridViewReports)
	oColumn:Visible:=FALSE

	oColumn:=oMainForm:CreateDXColumn("ReportName","ReportName",FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, -1, -1, SELF:GridViewReports)
	oColumn:Visible:=FALSE
	//Self:GridViewReports:ColumnViewOptionsBehavior:Editable:=False
RETURN

END CLASS