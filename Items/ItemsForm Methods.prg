// ItemsForm_Methods.prg
#Using System.IO
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Collections
USING System.Linq
#Using DevExpress.XtraGrid.Views.Grid
#Using DevExpress.XtraGrid.Columns
#Using DevExpress.Utils
#Using DevExpress.XtraEditors.Repository
#Using DevExpress.XtraEditors.Controls 
#using DevExpress.XtraPrinting
#Using DevExpress.XtraPrintingLinks


PARTIAL CLASS ItemsForm INHERIT DevExpress.XtraEditors.XtraForm
	PRIVATE oDTItems, oDTGroups, oDTUsers, oDTInUsers, oDTOutUsers , oDTGroupsOut AS DataTable
	//PRIVATE lSuspendNotification AS LOGIC
	PRIVATE oEditColumn AS GridColumn
	PRIVATE oEditRow AS DataRowView
	PRIVATE lLBCCreated AS LOGIC
	PRIVATE cItemTypeValue, cChangedCategoryValue, cChangedCategoryFilterString AS STRING
	PRIVATE oRepositoryItemGridLookUpEdit_Category AS RepositoryItemGridLookUpEdit
	PRIVATE oDTLookUpEdit_Category AS DataTable
	PRIVATE lCategoryEditMode AS LOGIC
	EXPORT cCallerReportName AS STRING
	// LBCCategories Drag-Drop
	PRIVATE p AS Point
	PRIVATE nReportBaseNum AS INT
	PRIVATE previousGridValue AS STRING
	PRIVATE oMatchIds AS DataTable
	EXPORT oDTReports, oDTReportsOffice AS DataTable
	PRIVATE lChanged AS LOGIC
	EXPORT cLogNotes := "" AS STRING
	PRIVATE oChangedReportColor AS Color

METHOD ItemsForm_OnLoad() AS VOID
	oSoftway:ReadFormSettings_DevExpress(SELF, splitContainerControl_Items, oMainForm:alForms, oMainForm:alData)

	SELF:GridViewItems:OptionsView:ShowGroupPanel := FALSE
	SELF:GridViewItems:OptionsBehavior:AllowIncrementalSearch := TRUE
	SELF:GridViewItems:OptionsPrint:PrintDetails := TRUE
	SELF:GridViewItems:OptionsSelection:EnableAppearanceFocusedCell := FALSE
	SELF:GridViewItems:OptionsSelection:MultiSelect := TRUE
	SELF:GridViewItems:OptionsView:ColumnAutoWidth := FALSE

	SELF:CreateGridItems_Columns()
	SELF:Fill_Odts_For_LBCReports()

	IF ! SELF:Fill_LBCReports()
		SELF:Close()
		RETURN
	ENDIF
	
	IF ! SELF:Fill_LBCReportsOffice()
		SELF:Close()
		RETURN
	ENDIF
	
	SELF:lLBCCreated := TRUE

	SELF:Fill_LBCCategories()
	//SELF:Fill_LBCUsers()

	SELF:Text := "Report Items Form: "+SELF:LBCReports:Text

	IF ! SELF:ReadReportBaseNum()
		ErrorBox("ReportBaseNum not defined for the selected Report")
		SELF:Close()
		RETURN
	ENDIF

	//WB(oUser:USER_UNIQUEID:tostring())
	LOCAL oRowLocal := oMainForm:returnUserSetting(oUser:USER_UNIQUEID) AS DataRow
	//WB(oRowLocal["CanEditVoyages"]:ToString())
	IF oRowLocal == NULL .OR. oRowLocal == NULL .OR. oRowLocal["CanEditReports"]:ToString() == "False"
		SELF:GridViewItems:OptionsBehavior:Editable := FALSE
	ENDIF

	SELF:CreateGridItems()
	//SELF:GridViewItems:Focus()
RETURN

METHOD Fill_Odts_For_LBCReports() AS VOID
		LOCAL cStatement AS STRING
		cStatement:="SELECT FMReportTypes.*"+;
					" FROM FMReportTypes"+oMainForm:cNoLockTerm+;
					" WHERE ReportType='V' "+;
					" ORDER BY ReportBaseNum"
		SELF:oDTReports := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		oSoftway:CreatePK(SELF:oDTReports, "REPORT_UID")
		

		cStatement:="SELECT FMReportTypes.*"+;
					" FROM FMReportTypes"+oMainForm:cNoLockTerm+;
					" WHERE ReportType='O' "+;
					" ORDER BY ReportBaseNum"
		SELF:oDTReportsOffice := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		oSoftway:CreatePK(SELF:oDTReportsOffice, "REPORT_UID")
RETURN

METHOD Fill_LBCReports() AS LOGIC
	/*IF oMainForm:LBCReports:ItemCount == 1 .and. oMainForm:ReportsTabUserControl:SelectedIndex == 0
		wb("No Reports defined")
		RETURN FALSE
	ENDIF*/

	//SELF:LBCReports:Items:Clear()

	SELF:LBCReports:DataSource := SELF:oDTReports
	SELF:LBCReports:DisplayMember := "ReportName"
	SELF:LBCReports:ValueMember := "REPORT_UID"

	IF SELF:cCallerReportName <> NULL
		// This Form is opened by ReportsForm ReportItems Button
		LOCAL nIndex := SELF:LBCReports:FindStringExact(SELF:cCallerReportName, 0) AS INT
		IF nIndex <> -1
			SELF:LBCReports:SelectedIndex := nIndex
		ENDIF
	ELSE
		TRY
		LOCAL cReportName := oMainForm:LBCReports:GetDisplayItemValue(oMainForm:LBCReports:SelectedIndex):ToString() AS STRING
		IF ! cReportName:ToUpper():StartsWith("MODE")
			// Select the last selected Report
			LOCAL nIndex := SELF:LBCReports:FindStringExact(cReportName, 0) AS INT
			IF nIndex <> -1
				SELF:LBCReports:SelectedIndex := nIndex
			ENDIF
		ENDIF
		CATCH exExc AS Exception 
			RETURN TRUE
		END
	ENDIF
RETURN TRUE


METHOD Fill_LBCReportsOffice() AS LOGIC
	SELF:LBCOfficeReports:Items:Clear()
	SELF:LBCOfficeReports:DataSource := SELF:oDTReportsOffice
	SELF:LBCOfficeReports:DisplayMember := "ReportName"
	SELF:LBCOfficeReports:ValueMember := "REPORT_UID"
RETURN TRUE

METHOD SelectedReportChanged() AS VOID
	IF ! SELF:lLBCCreated
		RETURN
	ENDIF

	//wb("Index="+SELF:LBCReports:SelectedIndex:ToString(), "Items="+SELF:LBCReports:ItemCount:ToString())
	IF SELF:LBCReports:SelectedIndex == -1
		RETURN
	ENDIF

	SELF:Text := "Report Items Form: "+SELF:LBCReports:Text
	IF SELF:LBCReports:ItemCount > 0
		IF ! SELF:ReadReportBaseNum()
			ErrorBox("ReportBaseNum not defined for the selected Report")
			SELF:Close()
			RETURN
		ENDIF
		SELF:CreateGridItems()
	ENDIF
RETURN


METHOD SelectedOfficeReportChanged() AS VOID
	IF ! SELF:lLBCCreated
		RETURN
	ENDIF

	SELF:SCMain:Panel2Collapsed := FALSE

	//wb("Index="+SELF:LBCReports:SelectedIndex:ToString(), "Items="+SELF:LBCReports:ItemCount:ToString())
	IF SELF:LBCOfficeReports:SelectedIndex == -1
		RETURN
	ENDIF

	SELF:Text := "Report Items Form: "+SELF:LBCOfficeReports:Text
	IF SELF:LBCOfficeReports:ItemCount > 0
		IF ! SELF:ReadReportBaseNum()
			ErrorBox("ReportBaseNum not defined for the selected Report")
			SELF:Close()
			RETURN
		ENDIF
		SELF:CreateGridItemsOffice()
	ENDIF
RETURN


METHOD ReadReportBaseNum() AS LOGIC
	// Read the Report's ReportBaseNum
	LOCAL cStatement AS STRING
	LOCAL oMyLBControl AS DevExpress.XtraEditors.ListBoxControl 
	IF SELF:tabControl1:SelectedIndex == 0
		oMyLBControl := SELF:LBCReports
	ELSE
		oMyLBControl := SELF:LBCOfficeReports
	ENDIF	
	
	LOCAL cReportUID := oMyLBControl:SelectedValue:ToString() AS STRING

	cStatement:="SELECT ReportBaseNum"+;
				" FROM FMReportTypes"+oMainForm:cNoLockTerm+;
				" WHERE REPORT_UID="+cReportUID
	//wb(cStatement, oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "ReportBaseNum"))
	TRY
		SELF:nReportBaseNum := Convert.ToInt32(oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "ReportBaseNum"))
	CATCH
		RETURN FALSE
	END TRY
RETURN TRUE




METHOD CreateGridItems() AS VOID
	LOCAL cStatement AS STRING
	//LOCAL cReportName := SELF:LBCReports:GetDisplayItemValue(SELF:LBCReports:SelectedIndex):ToString() AS STRING
	//wb("Index="+SELF:LBCReports:SelectedIndex:ToString()+CRLF+"Items="+SELF:LBCReports:ItemCount:ToString()+CRLF+cReportName)
	LOCAL cReportUID := SELF:LBCReports:SelectedValue:ToString() AS STRING
	//LOCAL cReportUID := oMainForm:LBCReports:SelectedValue:ToString() AS STRING

	cStatement:="SELECT FMReportItems.ITEM_UID as ITEM_UID, ItemNo, ItemName, ItemType, Mandatory, "+;
				" SLAA, ShowOnlyOffice, NotNumbered, IsDD ,  CalculatedField, ExpDays, MinValue, MaxValue, ShowOnMap, Unit,"+;
				" FMItemCategories.CATEGORY_UID, FMItemCategories.Description AS Category, ItemTypeValues, Groups_Owners,"+;
				" ExpandOnColumns, ItemCaption, ColumnColor FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMReportTypes ON FMReportTypes.REPORT_UID=FMReportItems.REPORT_UID"+;
				" AND FMReportTypes.REPORT_UID="+cReportUID+;
				" LEFT OUTER JOIN FMItemCategories ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
				" LEFT OUTER JOIN FMOfficeReportItems ON FMReportItems.ITEM_UID= FMOfficeReportItems.ITEM_UID"+;
				" ORDER BY ItemNo"
	SELF:oDTItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	SELF:oDTItems:TableName:="Items"
	// Create Primary Key
	oSoftway:CreatePK(SELF:oDTItems, "ITEM_UID")

	SELF:GridItems:DataSource := SELF:oDTItems
RETURN

METHOD CreateGridItemsOffice() AS VOID
	LOCAL cStatement AS STRING
	//LOCAL cReportName := SELF:LBCReports:GetDisplayItemValue(SELF:LBCReports:SelectedIndex):ToString() AS STRING
	//wb("Index="+SELF:LBCReports:SelectedIndex:ToString()+CRLF+"Items="+SELF:LBCReports:ItemCount:ToString()+CRLF+cReportName)
	LOCAL cReportUID := SELF:LBCOfficeReports:SelectedValue:ToString() AS STRING
	//LOCAL cReportUID := oMainForm:LBCReports:SelectedValue:ToString() AS STRING

	cStatement:="SELECT FMReportItems.ITEM_UID, ItemNo, ItemName, ItemType, Mandatory, SLAA, ShowOnlyOffice, NotNumbered, "+;
				" ExpandOnColumns, IsDD ,  CalculatedField, ExpDays, MinValue, MaxValue, ShowOnMap, Unit,"+;
				" FMItemCategories.CATEGORY_UID, FMItemCategories.Description AS Category, ItemTypeValues, Groups_Owners"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMReportTypes ON FMReportTypes.REPORT_UID=FMReportItems.REPORT_UID"+;
				"	AND FMReportTypes.REPORT_UID="+cReportUID+;
				" LEFT OUTER JOIN FMItemCategories ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
				" LEFT OUTER JOIN FMOfficeReportItems ON FMReportItems.ITEM_UID= FMOfficeReportItems.ITEM_UID"+;
				" ORDER BY ItemNo"
	SELF:oDTItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	SELF:oDTItems:TableName:="Items"
	// Create Primary Key
	oSoftway:CreatePK(SELF:oDTItems, "ITEM_UID")

	SELF:GridItems:DataSource := SELF:oDTItems
	//Self:
	
RETURN

METHOD CreateGridItems_Columns() AS VOID
	SELF:lCategoryEditMode := TRUE

	SELF:GridItems:DataSource := NULL
	SELF:GridViewItems:Columns:Clear()

	LOCAL oColumn AS GridColumn
	LOCAL nVisible:=0, nAbsIndex:=0 AS INT

// Freeze column: Set Fixed property
	oColumn:=oMainForm:CreateDXColumn("Item No", "ItemNo",				FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 70, SELF:GridViewItems)
    oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    oColumn:AppearanceHeader:Options:UseTextOptions := TRUE
    oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center

	oColumn:=oMainForm:CreateDXColumn("Item Name", "ItemName",			FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 250, SELF:GridViewItems)
	//oColumn:Fixed := FixedStyle.Left

	oColumn:=oMainForm:CreateDXColumn("Category", "uCategory",			FALSE,DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 90, SELF:GridViewItems)
	SELF:Fill_LookUpEdit_Category()

	oColumn:=oMainForm:CreateDXColumn("Item Type", "uItemType",			FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 70, SELF:GridViewItems)
	// ToolTip
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//					CHANGED BY KIRIAKOS In order to support Empty Date
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//oColumn:ToolTip := "Boolean, Coordinate, Combobox, DateTime, DateTimeNull, Label, File Uploader, Number, Table, Text, Text multiline"
	oColumn:ToolTip := "Boolean, Coordinate, Combobox, DateTime, Label, File Uploader, Number, Table, Text, Text multiline"
    oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    oColumn:AppearanceHeader:Options:UseTextOptions := TRUE
    oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
	LOCAL oRepositoryItemComboBoxItemType := RepositoryItemComboBox{} AS RepositoryItemComboBox
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//					CHANGED BY KIRIAKOS In order to support Empty Date
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//oRepositoryItemComboBoxItemType:Items:AddRange(<System.Object>{ "Boolean", "ComboBox", "Coordinate", "DateTime", "DateTimeNull","Label", "File Uploader", "Number", "Table", "Text", "Text multiline" })
	oRepositoryItemComboBoxItemType:Items:AddRange(<System.Object>{ "Boolean", "ComboBox", "Coordinate", "DateTime", "Label", "File Uploader", "Number", "Table", "Text", "Text multiline" })
    oRepositoryItemComboBoxItemType:Properties:TextEditStyle := DevExpress.XtraEditors.Controls.TextEditStyles.DisableTextEditor
	//Add a repository item to the repository items of grid control
	SELF:GridItems:RepositoryItems:Add(oRepositoryItemComboBoxItemType)
	//Now you can define the repository item as an inplace editor of columns
	oColumn:ColumnEdit := oRepositoryItemComboBoxItemType

	oColumn:=oMainForm:CreateDXColumn("Unit", "Unit",					FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 50, SELF:GridViewItems)
    oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    oColumn:AppearanceHeader:Options:UseTextOptions := TRUE
    oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center

	oColumn:=oMainForm:CreateDXColumn("Mandatory", "Mandatory",			FALSE, DevExpress.Data.UnboundColumnType.Boolean, ;
																		nAbsIndex++, nVisible++, 70, SELF:GridViewItems)
	// ToolTip
	oColumn:ToolTip := "If checked, the Vessel must fill this field"

	oColumn:=oMainForm:CreateDXColumn("SLAA", "SLAA",			FALSE, DevExpress.Data.UnboundColumnType.Boolean, ;
																		nAbsIndex++, nVisible++, 50, SELF:GridViewItems)
	// ToolTip
	oColumn:ToolTip := "If checked, this Item should be on same line as the item above it"
	
	oColumn:=oMainForm:CreateDXColumn("ExpandOnColumns", "ExpandOnColumns", FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																		nAbsIndex++, nVisible++, 50, SELF:GridViewItems)
	// ToolTip
	oColumn:ToolTip := "When on Table this item will expand on the given number of columns"

	oColumn:=oMainForm:CreateDXColumn("ShowOnlyOffice", "ShowOnlyOffice",			FALSE, DevExpress.Data.UnboundColumnType.Boolean, ;
																		nAbsIndex++, nVisible++, 50, SELF:GridViewItems)
	// ToolTip
	oColumn:ToolTip := "If checked, this item will only show in office form."
	
	oColumn:=oMainForm:CreateDXColumn("NotNumbered", "NotNumbered",			FALSE, DevExpress.Data.UnboundColumnType.Boolean, ;
																		nAbsIndex++, nVisible++, 50, SELF:GridViewItems)
	// ToolTip
	oColumn:ToolTip := "If checked, a number wont be assigned to this field on form show."

	oColumn:=oMainForm:CreateDXColumn("Is Due Date", "IsDD",			FALSE, DevExpress.Data.UnboundColumnType.Boolean, ;
																		nAbsIndex++, nVisible++, 50, SELF:GridViewItems)
	// ToolTip
	oColumn:ToolTip := "If checked, this date will be a due date."

	oColumn:=oMainForm:CreateDXColumn("ComboBoxItems", "ItemTypeValues",FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 150, SELF:GridViewItems)
	// ToolTip
	oColumn:ToolTip := "Specify ComboBox Item (separated by ';')"+CRLF+"One; Two; Three"

	oColumn:=oMainForm:CreateDXColumn("CalculatedField", "CalculatedField",	FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 150, SELF:GridViewItems)
	// ToolTip
	oColumn:ToolTip := "Write a calculation formula using ItemNo IDs"+CRLF+"Example: (ID245 / ID203) * 24"

	oColumn:=oMainForm:CreateDXColumn("MinValue", "MinValue",			FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																		nAbsIndex++, nVisible++, 70, SELF:GridViewItems)

	oColumn:=oMainForm:CreateDXColumn("MaxValue", "MaxValue",			FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																		nAbsIndex++, nVisible++, 70, SELF:GridViewItems)

	oColumn:=oMainForm:CreateDXColumn("ShowOnMap", "ShowOnMap",			FALSE, DevExpress.Data.UnboundColumnType.Boolean, ;
																		nAbsIndex++, nVisible++, 70, SELF:GridViewItems)
	// ToolTip
	oColumn:ToolTip := "If checked, the Item will be shown on Map label"


	oColumn:=oMainForm:CreateDXColumn("Exp. Days", "ExpDays",			FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																		nAbsIndex++, nVisible++, 70, SELF:GridViewItems)
	// ToolTip
	oColumn:ToolTip := "Item expiration: Number of expiration Days for the Item (0=No expiration)"
    oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
	
	// Invisible
	oColumn:=oMainForm:CreateDXColumn("ITEM_UID", "ITEM_UID",			FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																		nAbsIndex++, -1, -1, SELF:GridViewItems)
	oColumn:Visible:=FALSE

	oColumn:=oMainForm:CreateDXColumn("CATEGORY_UID","CATEGORY_UID",	FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																		nAbsIndex++, -1, -1, SELF:GridViewItems)
	oColumn:Visible:=FALSE
	
	oColumn:=oMainForm:CreateDXColumn("Item Caption", "ItemCaption",	FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 200, SELF:GridViewItems)
																		
	LOCAL repositoryItemColorEdit1 := DevExpress.XtraEditors.Repository.RepositoryItemColorEdit{} AS DevExpress.XtraEditors.Repository.RepositoryItemColorEdit
	oColumn:=oMainForm:CreateDXColumn("Column Color", "uColumnColor",	FALSE,  DevExpress.Data.UnboundColumnType.Object, ;
																		nAbsIndex++, nVisible++, 70, SELF:GridViewItems)
	oColumn:ColumnEdit := repositoryItemColorEdit1
	// ToolTip
	oColumn:ToolTip := "Click the cell to change the Column Color"

	SELF:lCategoryEditMode := FALSE
RETURN


#Region LookUpEdit_Category

METHOD Fill_LookUpEdit_Category() AS VOID
	// Create a RepositoryItemGridLookUpEdit control for the CopyToFolder
	SELF:oRepositoryItemGridLookUpEdit_Category := RepositoryItemGridLookUpEdit{}
	SELF:oRepositoryItemGridLookUpEdit_Category:Name := "oRepositoryItemGridLookUpEdit_Category"
	SELF:oRepositoryItemGridLookUpEdit_Category:ImmediatePopup := FALSE
	//SELF:oRepositoryItemGridLookUpEdit_Category:Properties:NullText := ""
// The next line Duplicates the ComboBox ArrowButton:
	//Self:oRepositoryItemGridLookUpEdit_StateFlag:Properties:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{DevExpress.XtraEditors.Controls.ButtonPredefines.Combo} })
	//Self:oRepositoryItemGridLookUpEdit_StateFlag:Properties:TextEditStyle := DevExpress.XtraEditors.Controls.TextEditStyles.Standard
	//Self:oRepositoryItemGridLookUpEdit_StateFlag:Properties:View := SELF:gridLookUpEdit1View
	//Self:oRepositoryItemGridLookUpEdit_StateFlag:Size := System.Drawing.Size{242, 20}
	//Self:oRepositoryItemGridLookUpEdit_StateFlag:ToolTip := "Press Ctrl+Del to clear"
	// Prevent columns from being automatically created when a data source is assigned.
	//Self:oRepositoryItemGridLookUpEdit_StateFlag:Properties:AutoPopulateColumns := false

	LOCAL cStatement AS STRING
	// Fill SELF:oRepositoryItemGridLookUpEdit_Category
	cStatement:="SELECT CATEGORY_UID, Description, SortOrder"+;
				" FROM FMItemCategories"+oMainForm:cNoLockTerm+;
				" ORDER BY SortOrder"
	
				//" UNION SELECT 0 AS CATEGORY_UID, ' ' as Description, 0 AS SortOrder"+;
				//" ORDER BY SortOrder"
	SELF:oDTLookUpEdit_Category:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	// Create Primary Key
	oSoftway:CreatePK(oDTLookUpEdit_Category, "CATEGORY_UID")
	//wb(cStatement, oDTLookUpEdit_Category:Rows:Count)
	//SELF:oRepositoryItemGridLookUpEdit_Category:DataBindings:Add("EditValue", Self:oDTCopyToFolder)

	SELF:oRepositoryItemGridLookUpEdit_Category:DataSource := SELF:oDTLookUpEdit_Category
	SELF:oRepositoryItemGridLookUpEdit_Category:DisplayMember := "Description"
	SELF:oRepositoryItemGridLookUpEdit_Category:ValueMember := "CATEGORY_UID"

	// Hide CATEGORY_UID
	SELF:oRepositoryItemGridLookUpEdit_Category:View:PopulateColumns(oDTLookUpEdit_Category)
	//wb(SELF:oRepositoryItemGridLookUpEdit_Category:View:Columns:Count)
	SELF:oRepositoryItemGridLookUpEdit_Category:View:Columns[0]:Visible := FALSE
	//// Hide StateFlagColor
	//SELF:oRepositoryItemGridLookUpEdit_Category:View:Columns[2]:Visible := FALSE

	SELF:oRepositoryItemGridLookUpEdit_Category:PopupFormWidth := 40
	SELF:oRepositoryItemGridLookUpEdit_Category:View:BestFitColumns()

	//SELF:GridViewItems:Columns["uCategory"]:ColumnEdit := SELF:oRepositoryItemGridLookUpEdit_Category
RETURN


METHOD Category_Save(nRowHandle AS INT) AS VOID
	IF ! SELF:lCategoryEditMode
		RETURN
	ENDIF

	//LOCAL cFilter := "" AS STRING
	//IF SELF:GridViewKeycodes:ActiveFilter <> NULL
	//	cFilter := SELF:GridViewKeycodes:ActiveFilterString
	//ENDIF

	LOCAL cStatement, cUID, cValue AS STRING

	LOCAL oRow AS DataRowView
	//oRow:=(DataRowView)Self:GridViewKeycodes:GetRow(e:RowHandle)
	oRow:=(DataRowView)SELF:GridViewItems:GetRow(nRowHandle)

	cUID := oRow:Item["ITEM_UID"]:ToString()
//	cValue := e:Value:ToString():Trim()
	cValue := SELF:cChangedCategoryValue

	// Update FMReportItems.CATEGORY_UID
	cStatement:="UPDATE FMReportItems SET"+;
				" CATEGORY_UID="+cValue+;
				" WHERE ITEM_UID="+cUID
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:Refresh()
		RETURN
	ENDIF

	// Find Category
	LOCAL oDataRow_Category := SELF:oDTLookUpEdit_Category:Rows:Find(cValue) AS DataRow
	IF oDataRow_Category == NULL
		ErrorBox("Cannot access StateFlag row", "Color not changed")
		RETURN
	ENDIF

	// Update DataTable and Grid
	LOCAL oDataRow := oRow:Row AS DataRow	//SELF:FindMSG32Row(oRow) as DataRow
	IF oDataRow == NULL
		ErrorBox("Cannot access current row", "Not changed")
		RETURN
	ENDIF

	oDataRow:Item["CATEGORY_UID"] := cValue
	oDataRow:Item["Category"] := oDataRow_Category:Item["Description"]:ToString():Trim()
	//oDataRow:Item["StateFlagColor"]:=oDataRow_Category:Item["StateFlagColor"]
	SELF:oDTItems:AcceptChanges()
	// Invalidates the region occupied by the current View (adds it to the control's update region that will be repainted
	// during the next paint operation), and causes a paint message to be sent to the grid control
	SELF:GridViewItems:Invalidate()

	//SELF:barStaticItem_Count:Caption:=SELF:GridViewKeycodes:DataRowCount:ToString("N0")+" Msgs"
	//IF cFilter <> ""
	//	SELF:GridViewKeycodes:ActiveFilterString := cFilter
	//	SELF:barStaticItem_Count:Caption:=SELF:GridViewKeycodes:DataRowCount:ToString("N0")+" Msgs"
	//	//SELF:CreateGridMessages(TRUE, FALSE)
	//ENDIF
RETURN

#EndRegion LookUpEdit_Category


//METHOD repositoryItemComboBox_Category_ParseEditValue(sender AS OBJECT, e AS DevExpress.XtraEditors.Controls.ConvertEditValueEventArgs) AS VOID
//	// The RepositoryItemComboBox edit is used to edit string values in the GridView.
//	// So, when a ComboBox item is chosen, the GridView's DataController tries to convert the ComboBox item to a string value.//
//	// This is accomplished using the Convert.ChangeType method, and it is applied to the ComboBoxItem represented by the UserInfo class.
//	// This method fails with the exception you reported to us. So, to resolve this issue, one solution is to handle the repositoryItem's ParseEditValue event as shown below:
//	e:Value := e:Value:ToString()
//	e:Handled := TRUE
//RETURN


METHOD BeforeLeaveRow_Items(e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.Void
	//IF SELF:lSuspendNotification
	//	RETURN
	//ENDIF

	/*LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewItems:GetRow(e:RowHandle)
	IF oRow == NULL
		RETURN
	ENDIF*/

	//// Validate
	//IF ! SELF:ValidateItems()
	//	e:Allow := FALSE
	//	RETURN
	//ENDIF

	// EditMode: OFF
	SELF:SetEditModeOff_Common(SELF:GridViewItems)
RETURN


METHOD CustomUnboundColumnData_Items(e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs) AS VOID
	// Provides data for the UnboundColumns
	IF ! e:IsGetData
		RETURN
	ENDIF

	LOCAL oRow AS DataRow
	LOCAL cField AS STRING
	LOCAL cValue AS STRING

	DO CASE
	CASE e:Column:FieldName == "uItemType"
		oRow := SELF:oDTItems:Rows[e:ListSourceRowIndex]
		// Remove the leading 'u' from FieldName
		cField := oRow:Item[e:Column:FieldName:Substring(1)]:ToString()
		DO CASE
			CASE cField == "B"
				cValue := "Boolean"

			CASE cField == "X"
				cValue := "ComboBox"

			CASE cField == "C"
				cValue := "Coordinate"

			CASE cField == "D"
				cValue:="DateTime"

	///////////////////////////////////////////////////
	//ADDED BY KIRIAKOS In order to support Empty Date
	///////////////////////////////////////////////////
			//CASE cField == "E"
			//	cValue:="DateTimeNull"
	///////////////////////////////////////////////////
	//ADDED BY KIRIAKOS In order to support Empty Date
	///////////////////////////////////////////////////

			CASE cField == "N"
				cValue:="Number"

			CASE cField == "T"
				cValue:="Text"

			CASE cField == "M"
				cValue:="Text multiline"
				
			CASE cField == "F"
				cValue:="File Uploader"
				
			CASE cField == "L"
				cValue:="Label"
			
			CASE cField == "A"
				cValue := "Table"	
			
				
		ENDCASE
		e:Value:=cValue

	CASE e:Column:FieldName == "uCategory" .AND. ! SELF:lCategoryEditMode
		oRow := SELF:oDTItems:Rows[e:ListSourceRowIndex]
		cValue:=oRow:Item["Category"]:ToString()
		e:Value:=cValue

	CASE e:Column:FieldName == "uCategory"	// .and. Self:lCategoryEditMode
		// Workaround to bypass the side-effect of hidding column's values when entering in Edit mode
		// for each cell, return the existed CATEGORY_UID to the LookupEdit in order to redraw the Category text values
		oRow := SELF:oDTItems:Rows[e:ListSourceRowIndex]
		cValue:=oRow:Item["CATEGORY_UID"]:ToString()
		IF cValue == ""
			cValue := "0"
		ENDIF
		e:Value:=cValue
	CASE e:Column:FieldName == "uColumnColor"
		oRow:=SELF:oDTItems:Rows[e:ListSourceRowIndex]

		LOCAL oColor AS System.Drawing.Color
		VAR colorTxt := oRow:Item["ColumnColor"]:ToString()
		oColor := oMainForm:AssignColor(colorTxt)
		// The Color contains: <A, R, G, B>. The saved Table column has: <R, G, B>
		e:Value := oColor:ToArgb()
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


/*METHOD FocusedRowChanged_Items(e AS DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventArgs) AS VOID
// Notification Method
	IF SELF:GridViewItems:IsGroupRow(e:FocusedRowHandle)
		RETURN
	ENDIF

	// Get GridRow data into a DataRowView object
	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewItems:GetRow(e:FocusedRowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	SELF:FillListBoxControls_Items(oRow)
RETURN*/

//////////////////////////////////////////////////
//		CHANGED BY KIRIAKOS AT 10/06/16
//////////////////////////////////////////////////

/*METHOD Items_Add() AS VOID
		
	LOCAL oMyLBControl AS DevExpress.XtraEditors.ListBoxControl 
	IF SELF:tabControl1:SelectedIndex == 0
		oMyLBControl := SELF:LBCReports
	ELSE
		oMyLBControl := SELF:LBCOfficeReports
	endif
		
	LOCAL cReportName := oMyLBControl:GetDisplayItemValue(oMyLBControl:SelectedIndex):ToString() AS STRING
	IF cReportName:ToUpper():StartsWith("MODE")
		wb("The virtual Report: "+cReportName+" cannot contain Items")
		RETURN
	ENDIF

	IF QuestionBox("Do you want to create a new Report Item"+CRLF+;
					"member of the Report: "+cReportName+" ?", ;
					"Add new") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	LOCAL cStatement AS STRING
	LOCAL cReportUID := oMyLBControl:SelectedValue:ToString() AS STRING
	LOCAL cLastItemNo  AS STRING

	// Next ItemNo
	LOCAL cNextItemNo := "0" AS STRING
	// Read the last Item
	LOCAL oRow := (DataRowView)SELF:GridViewItems:GetRow(SELF:GridViewItems:RowCount - 1) AS DataRowView
	IF oRow == NULL
		cNextItemNo := SELF:nReportBaseNum:ToString()
		IF cNextItemNo <> ""
			cNextItemNo := (Convert.ToInt16(cNextItemNo) + 1):ToString()
		ENDIF
	ELSE
		cLastItemNo := oRow["ItemNo"]:ToString() 
		IF StringIsNumeric(cLastItemNo)
			cStatement:=" SELECT Max(ItemNo) AS nMax"+;
						" FROM FMReportItems"+oMainForm:cNoLockTerm+;
						" WHERE REPORT_UID="+cReportUID
			cNextItemNo := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "nMax")
			cNextItemNo := (Convert.ToInt16(cNextItemNo) + 1):ToString()
		ELSEIF cLastItemNo:Length == 1
			cNextItemNo := Chr(Asc(cLastItemNo) + 1)
		ENDIF
	ENDIF
	
	//IF Convert.ToInt32(cNextItemNo) == SELF:nReportBaseNum+100
		IF  CheckIfReportBaseNumExists(Convert.ToInt32(cNextItemNo)) 
			ErrorBox("The ItemNo must be between: "+SELF:nReportBaseNum:ToString()+" and "+cNextItemNo)
			RETURN
		ENDIF
	//ENDIF
	
	cStatement:="INSERT INTO FMReportItems (REPORT_UID, ItemNo, ItemName, ItemType, ExpDays, CATEGORY_UID) VALUES"+;
				" ("+cReportUID+", '"+cNextItemNo+"', '_New Item_"+cNextItemNo+"', 'T', 0, 0)"
	if ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		Self:Items_Refresh()
		Return
	endif
	LOCAL cUID:=oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "FMReportItems", "ITEM_UID") AS STRING

	Self:Items_Refresh()

	Local nFocusedHandle as int
	nFocusedHandle:=Self:GridViewItems:LocateByValue(0, Self:GridViewItems:Columns["ITEM_UID"], Convert.ToInt32(cUID))
	if nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
		Return
	endif
	Self:GridViewItems:ClearSelection()
	Self:GridViewItems:FocusedRowHandle:=nFocusedHandle
	SELF:GridViewItems:SelectRow(nFocusedHandle)
RETURN*/

//METHOD Items_Add(oRowToAdd AS DataRowView) AS VOID
//////////////////////////////////////////////////
//		CHANGED BY KIRIAKOS AT 10/06/16
//////////////////////////////////////////////////

METHOD Items_Add(oRowToAdd := NULL AS DataRowView, cReportUID := "" AS STRING) AS VOID
	//LOCAL cReportName := SELF:LBCReports:GetDisplayItemValue(SELF:LBCReports:SelectedIndex):ToString() AS STRING
	LOCAL oMyLBControl AS DevExpress.XtraEditors.ListBoxControl 
	IF SELF:tabControl1:SelectedIndex == 0
		oMyLBControl := SELF:LBCReports
	ELSE
		oMyLBControl := SELF:LBCOfficeReports
	ENDIF

	IF oRowToAdd == NULL
		LOCAL cReportName := oMyLBControl:GetDisplayItemValue(oMyLBControl:SelectedIndex):ToString() AS STRING
		IF cReportName:ToUpper():StartsWith("MODE")
			wb("The virtual Report: "+cReportName+" cannot contain Items")
			RETURN
		ENDIF

		IF QuestionBox("Do you want to create a new Report Item"+CRLF+;
						"member of the Report: "+cReportName+" ?", ;
						"Add new") <> System.Windows.Forms.DialogResult.Yes
			RETURN
		ENDIF
	ENDIF

	LOCAL cStatement AS STRING
	//////////////////////////////////////////////////
	//		CHANGED BY KIRIAKOS AT 10/06/16
	//////////////////////////////////////////////////
	//LOCAL cReportUID := oMyLBControl:SelectedValue:ToString() AS STRING
	IF cReportUID == ""
		cReportUID := oMyLBControl:SelectedValue:ToString()
	ENDIF
	//////////////////////////////////////////////////
	//		CHANGED BY KIRIAKOS AT 10/06/16
	//////////////////////////////////////////////////
	LOCAL cLastItemNo AS STRING

	// Next ItemNo
	LOCAL cNextItemNo := "0" AS STRING
	// Read the last Item
	LOCAL oRow := (DataRowView)SELF:GridViewItems:GetRow(SELF:GridViewItems:RowCount - 1) AS DataRowView
	IF oRow == NULL
		cNextItemNo := SELF:nReportBaseNum:ToString()
		IF cNextItemNo <> ""
			cNextItemNo := (Convert.ToInt64(cNextItemNo) + 1):ToString()
		ENDIF
	ELSE
		cLastItemNo := oRow["ItemNo"]:ToString() 
		IF StringIsNumeric(cLastItemNo)
			cStatement:="SELECT Max(ItemNo) AS nMax"+;
						" FROM FMReportItems"+oMainForm:cNoLockTerm+;
						" WHERE REPORT_UID="+cReportUID
			cNextItemNo := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "nMax")
			//////////////////////////////////////////////////
			//		CHANGED BY KIRIAKOS AT 10/06/16
			//////////////////////////////////////////////////
			//IF no Item exists for the specific report, the cNextItemNo was "" and results in an error
			IF cNextItemNo == ""
				cNextItemNo := SELF:GetReportBaseNum(cReportUID)
				IF cNextItemNo == ""
					cNextItemNo := "0"
				ENDIF
			ENDIF
			//////////////////////////////////////////////////
			//		CHANGED BY KIRIAKOS AT 10/06/16
			//////////////////////////////////////////////////
			cNextItemNo := (Convert.ToInt64(cNextItemNo) + 1):ToString()
		ELSEIF cLastItemNo:Length == 1
			cNextItemNo := Chr(Asc(cLastItemNo) + 1)
		ENDIF
	ENDIF


	//IF Convert.ToInt32(cNextItemNo) == SELF:nReportBaseNum+100
		IF  CheckIfReportBaseNumExists(Convert.ToInt32(cNextItemNo))
			ErrorBox("The ItemNo must be between: "+SELF:nReportBaseNum:ToString()+" and "+(SELF:nReportBaseNum + 99):ToString())
			RETURN
		ENDIF
	//ENDIF
	
	IF oRowToAdd == NULL
		cStatement:="INSERT INTO FMReportItems (REPORT_UID, ItemNo, ItemName, ItemType, ExpDays, CATEGORY_UID) VALUES"+;
					" ("+cReportUID+", '"+cNextItemNo+"', '_New Item_"+cNextItemNo+"', 'T', 0, 0)"
		IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			SELF:Items_Refresh()
			RETURN
		ENDIF
		LOCAL cUID:=oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "FMReportItems", "ITEM_UID") AS STRING

		SELF:Items_Refresh()

		LOCAL nFocusedHandle AS INT
		nFocusedHandle:=SELF:GridViewItems:LocateByValue(0, SELF:GridViewItems:Columns["ITEM_UID"], Convert.ToInt32(cUID))
		IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
			RETURN
		ENDIF
		SELF:GridViewItems:ClearSelection()
		SELF:GridViewItems:FocusedRowHandle:=nFocusedHandle
		SELF:GridViewItems:SelectRow(nFocusedHandle)
		
		SELF:cLogNotes += "Added the Item : "+cNextItemNo+"."+"_New Item_"+cNextItemNo+CRLF
		SELF:lChanged := TRUE
		RETURN
	ENDIF

	LOCAL cNewName:= oSoftway:ConvertWildcards(oRowToAdd:Item["ItemName"]:ToString():Trim(),FALSE) AS STRING
	LOCAL cItem_Type := oRowToAdd:Item["ItemType"]:ToString():Trim()	 AS STRING
	LOCAL cCalculatedField:= oRowToAdd:Item["CalculatedField"]:ToString():Trim() AS STRING
	LOCAL cItemTypeValues := oSoftway:ConvertWildcards(oRowToAdd:Item["ItemTypeValues"]:ToString():Trim(),FALSE) AS STRING
	LOCAL cExpandOnColumns:= oRowToAdd:Item["ExpandOnColumns"]:ToString():Trim() AS STRING
	
	LOCAL iPreviousNum := Convert.ToInt32(oRowToAdd:Item["ItemNo"]:ToString())  AS INT
	LOCAL iNextNum := Convert.ToInt32(cNextItemNo) AS INT
	
	IF cItem_Type == "X" // An einai combo koitaw an exw conditionary mandatory fields
		IF cItemTypeValues:Contains("<ID")
			LOCAL iEnumerate := 0,iFound ,iEnd, iLocatedNum, iDifference AS INT
			LOCAL cLocatedNum, cNextNum AS STRING 
			
			WHILE iEnumerate > -1 .AND. iEnumerate < cItemTypeValues:length
				 iFound := cItemTypeValues:IndexOf("<ID",iEnumerate)
				 //MessageBox.Show(iFound:ToString())
				 IF iFound == -1 
					EXIT	 
				 ENDIF
				 
				 iEnd := cItemTypeValues:IndexOf(">",iFound+3)	 
				 IF iEnd <= iFound .OR. iEnd == -1
					 EXIT
				 ENDIF
				 //MessageBox.Show(iEnd:ToString())
				 //MessageBox.Show((iEnd-(iFound+3)):ToString())
				 cLocatedNum := cItemTypeValues:Substring(iFound+3,iEnd-(iFound+3))
				 //MessageBox.Show(cLocatedNum)
				 iLocatedNum := Convert.ToInt32(cLocatedNum)
				 iDifference := iPreviousNum - iLocatedNum
				 //MessageBox.Show(iPreviousNum:ToString()+"/"+iLocatedNum:ToString())
				 cNextNum := "<ID"+(iNextNum-iDifference):ToString()+">"
				 cItemTypeValues := cItemTypeValues:Substring(0,iFound)+cNextNum+cItemTypeValues:Substring(iEnd+1)
				 iEnumerate := iEnd+1
			ENDDO
		ENDIF
	ENDIF
	
	
	
	
	LOCAL cCat_IUD        := oRowToAdd:Item["CATEGORY_UID"]:ToString():trim() AS STRING
	IF cCat_IUD != NULL .AND. cCat_IUD == ""
		cCat_IUD := "0"
	ENDIF
		
	
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
	
	LOCAL cShowOnlyOffice := oRowToAdd:Item["ShowOnlyOffice"]:ToString():Trim()  AS STRING
	IF cShowOnlyOffice != NULL .AND. cShowOnlyOffice == "False"
		cShowOnlyOffice := "0"
	ELSEIF cShowOnlyOffice == NULL
		cShowOnlyOffice := "0"
	ELSEIF cShowOnlyOffice == "True"
		cShowOnlyOffice := "1"
	ENDIF
	
	LOCAL cIsDD := oRowToAdd:Item["IsDD"]:ToString():Trim() AS STRING
	IF cIsDD != NULL .AND. cIsDD == "False"
		cIsDD := "0"
	ELSEIF cIsDD == NULL
		cIsDD := "0"
	ELSEIF cIsDD == "True"
		cIsDD := "1"
	ENDIF
	
	LOCAL cIsMandatory := oRowToAdd:Item["Mandatory"]:ToString():Trim() AS STRING
	IF cIsMandatory != NULL .AND. cIsMandatory == "False"
		cIsMandatory := "0"
	ELSEIF cIsMandatory == NULL
		cIsMandatory := "0"
	ELSEIF cIsMandatory == "True"
		cIsMandatory := "1"
	ENDIF

	cStatement:=" INSERT INTO FMReportItems (REPORT_UID, ItemNo, ItemName, ItemType, ExpDays,"+;
				" CATEGORY_UID, ItemTypeValues,CalculatedField,SLAA,ShowOnlyOffice, NotNumbered, IsDD, Mandatory, ExpandOnColumns ) VALUES"+;
				" ("+cReportUID+", '"+cNextItemNo+"', '"+cNewName+"', '"+cItem_Type+"', 0,"+cCat_IUD+", '"+cItemTypeValues+"','"+;
					cCalculatedField+"',"+cSLAA+","+cShowOnlyOffice+","+cNotNumbered+","+cIsDD+","+cIsMandatory+","+cExpandOnColumns+" )"
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		//MessageBox.Show(cStatement, "failed")
		RETURN
	ENDIF
	SELF:cLogNotes += "Added the Item : "+cNextItemNo+"."+cNewName+CRLF
	
	SELF:lChanged := TRUE
RETURN

METHOD Items_Edit(oRow AS DataRowView, oColumn AS GridColumn) AS VOID
	IF oRow == NULL
		RETURN
	ENDIF

	LOCAL cField := oColumn:FieldName AS STRING
	IF ! InListExact(cField, "ItemNo", "ItemName", "uItemType", "Mandatory","SLAA", "IsDD" , "ExpDays",;
		 "uCategory", "CalculatedField", "ItemTypeValues", "MinValue", "MaxValue", "ShowOnMap", "Unit",;
		 "ShowOnlyOffice","NotNumbered","ExpandOnColumns", "ItemCaption", "uColumnColor")
		wb("The column '"+oColumn:Caption+"' is ReadOnly")
		RETURN
	ENDIF

	IF InListExact(cField, "MinValue", "MaxValue") .AND. oRow:Row["ItemType"]:ToString() <> "N"
		wb("The column '"+oColumn:Caption+"' is only available to Numeric fields")
		RETURN
	ENDIF

	IF InListExact(cField, "ItemTypeValues") .AND. (oRow:Row["ItemType"]:ToString() <> "X" .AND. oRow:Row["ItemTypeValues"]:ToString():Trim()=="" )  .AND. (oRow:Row["ItemType"]:ToString() <> "A" .AND. oRow:Row["ItemTypeValues"]:ToString():Trim()=="")
		wb("The column '"+oColumn:Caption+"' is only available to ComboBox fields")
		RETURN
	ENDIF

	SELF:oEditColumn := oColumn
	SELF:oEditRow := oRow
	IF oColumn:FieldName == "Unit"
		previousGridValue := oRow:Item["Unit"]:ToString()
	ENDIF

	SELF:oEditColumn:OptionsColumn:AllowEdit := TRUE
    SELF:GridViewItems:OptionsSelection:EnableAppearanceFocusedCell := TRUE
	SELF:GridViewItems:ShowEditor()
RETURN


METHOD Items_Delete() AS VOID
	LOCAL oRow AS DataRowView
	LOCAL nRowHandle := SELF:GridViewItems:FocusedRowHandle AS INT
	oRow:=(DataRowView)SELF:GridViewItems:GetRow(nRowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	IF QuestionBox("Do you want to Delete the current Item:"+CRLF+CRLF+;
					oRow:Item["ItemName"]:ToString()+" ?", ;
					"Delete") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	LOCAL cStatement AS STRING
	/*LOCAL cExistedValue AS STRING
	cStatement:="SELECT VESSEL_UNIQUEID FROM FMData"+oMainForm:cNoLockTerm+;
				" WHERE VESSEL_UNIQUEID="+oRow:Item["VESSEL_UNIQUEID"]:ToString()
	cStatement := oSoftway:SelectTop(cStatement)
	cExistedValue:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "VESSEL_UNIQUEID")

	IF cExistedValue <> ""
		ErrorBox("The current Vessel already Exists in Data", ;
					"Delete aborded")
		RETURN
	ENDIF*/
	cStatement:="DELETE FROM FMReportItems"+;
				" WHERE ITEM_UID="+oRow:Item["ITEM_UID"]:ToString()
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ErrorBox("Cannot Delete current row", "Deletion aborted")
		RETURN
	ENDIF

	LOCAL cItemNo := oRow:Item["ItemNo"]:ToString() AS STRING
	LOCAL cItemName := oRow:Item["ItemName"]:ToString() AS STRING

	IF SELF:GridViewItems:DataRowCount == 1
		SELF:oDTItems:Clear()
		RETURN
	ENDIF

	// Stop Notification
	//SELF:lSuspendNotificationItems := TRUE
	IF nRowHandle == 0
		SELF:GridViewItems:MoveNext()
	ELSE
		SELF:GridViewItems:MovePrev()
	ENDIF
	//SELF:lSuspendNotificationItems := FALSE

	LOCAL oDataRow AS DataRow
	oDataRow:=SELF:oDTItems:Rows:Find(oRow:Item["ITEM_UID"]:ToString())
	//wb(oRow:Item["MSG_UNIQUEID"]:ToString(), oDataRow)
	IF oDataRow <> NULL
		//wb(Self:oDTMsg32:Rows:Find(oRow:Item["MsgRefNo"]:ToString()), "Removed")
		SELF:oDTItems:Rows:Remove(oDataRow)
	ENDIF
	SELF:lChanged := TRUE

	SELF:cLogNotes += "Deleted the Item : "+cItemNo+"."+cItemName+CRLF
RETURN


METHOD Items_Delete(oRow AS DataRowView) AS VOID
	//LOCAL oRow AS DataRowView
	//LOCAL nRowHandle := SELF:GridViewItems:FocusedRowHandle AS INT
	//oRow:=(DataRowView)SELF:GridViewItems:GetRow(nRowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	IF QuestionBox("Do you want to Delete the current Item:"+CRLF+CRLF+;
					oRow:Item["ItemName"]:ToString()+" ?", ;
					"Delete") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	LOCAL cStatement AS STRING
	cStatement:="DELETE FROM FMReportItems"+;
				" WHERE ITEM_UID="+oRow:Item["ITEM_UID"]:ToString()
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ErrorBox("Cannot Delete current row", "Deletion aborted")
		RETURN
	ENDIF

	LOCAL cItemNo := oRow:Item["ItemNo"]:ToString() AS STRING
	LOCAL cItemName := oRow:Item["ItemName"]:ToString() AS STRING

	IF SELF:GridViewItems:DataRowCount == 1
		SELF:oDTItems:Clear()
		RETURN
	ENDIF

	LOCAL oDataRow AS DataRow
	oDataRow:=SELF:oDTItems:Rows:Find(oRow:Item["ITEM_UID"]:ToString())
	//wb(oRow:Item["MSG_UNIQUEID"]:ToString(), oDataRow)
	IF oDataRow <> NULL
		//wb(Self:oDTMsg32:Rows:Find(oRow:Item["MsgRefNo"]:ToString()), "Removed")
		SELF:oDTItems:Rows:Remove(oDataRow)
	ENDIF
	SELF:lChanged := TRUE

	SELF:cLogNotes += "Deleted the Item : "+cItemNo+"."+cItemName+CRLF
RETURN

METHOD Items_Save(e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs) AS VOID
	LOCAL cStatement, cUID, cField, ucField, cValue, cDuplicate, cReplace AS STRING

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewItems:GetRow(e:RowHandle)

	cUID := oRow:Item["ITEM_UID"]:ToString()

	cField := e:Column:FieldName
	IF e:Value == NULL
		cValue := ""
	ELSE
		cValue := e:Value:ToString():Trim()
	ENDIF
	//wb("cValue="+cValue+"cField="+cField)
	// Validate cValue
	LOCAL oMyLBControl AS DevExpress.XtraEditors.ListBoxControl 
	IF SELF:tabControl1:SelectedIndex == 0
		oMyLBControl := SELF:LBCReports
	ELSE
		oMyLBControl := SELF:LBCOfficeReports
	ENDIF
	
	LOCAL cReportUID := oMyLBControl:SelectedValue:ToString() AS STRING

	// Update DataTable and Grid
	LOCAL oDataRow:=SELF:oDTItems:Rows:Find(cUID) AS DataRow
	IF oDataRow == NULL
		ErrorBox("Cannot access current row", "Not changed")
		RETURN
	ENDIF

	DO CASE
	CASE InListExact(cField, "ItemName") .AND. cValue:Length > 512
		ErrorBox("The field '"+cField+"' must contain up to 512 characters", "Editing aborted")
		SELF:Items_Refresh()
		RETURN

	CASE cField == "ItemName" .AND. cValue:Length = 0
		ErrorBox("The field '"+cField+"' cannot be empty", "Editing aborted")
		SELF:Items_Refresh()
		RETURN

	CASE cField == "ItemName"
		// Check for duplicates For Samos
		/*cStatement:="SELECT ItemName FROM FMReportItems"+oMainForm:cNoLockTerm+;
					" WHERE ITEM_UID <> "+cUID+;
					" AND ItemName='"+oSoftway:ConvertWildCards(cValue, FALSE)+"'"+;
					" AND REPORT_UID="+cReportUID
		cDuplicate:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "ItemName"):Trim()
		IF cDuplicate <> ""
			ErrorBox("The Item Name '"+cValue+"' is already in use by another Item", "Editing aborted")
			SELF:Items_Refresh()
			RETURN
		ENDIF*/
		cReplace := "'"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"
	CASE InListExact(cField, "ItemNo") .AND. cValue:Length > 5
		ErrorBox("The field '"+cField+"' must contain up to 5 characters", "Editing aborted")
		SELF:Items_Refresh()
		RETURN

	CASE cField == "ItemNo"
		IF Convert.ToInt32(cValue) < SELF:nReportBaseNum .OR. Convert.ToInt32(cValue) > SELF:nReportBaseNum + 99
			IF  Convert.ToInt32(cValue) < SELF:nReportBaseNum
				ErrorBox("The ItemNo must be between: "+SELF:nReportBaseNum:ToString()+" and "+(SELF:nReportBaseNum + 99):ToString())
				SELF:Items_Refresh()
				RETURN
			ELSEIF SELF:CheckIfReportBaseNumExists(SELF:nReportBaseNum + 100) 
				ErrorBox("The ItemNo must be between: "+SELF:nReportBaseNum:ToString()+" and "+(SELF:nReportBaseNum + 99):ToString())
				SELF:Items_Refresh()
				RETURN
			ENDIF
		ENDIF
		// Check for duplicates
		cStatement:="SELECT ItemName FROM FMReportItems"+oMainForm:cNoLockTerm+;
					" WHERE ITEM_UID <> "+cUID+;
					" AND ItemNo='"+cValue+"'"
		cDuplicate:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "ItemName"):Trim()
		IF cDuplicate == ""
			// Update Formulas
			LOCAL nFormulas := 0 AS INT
			// Get Reports's BodyText
			LOCAL cBodyText AS STRING
			cStatement:="SELECT BodyText FROM FMBodyText"+oMainForm:cNoLockTerm+;
						" WHERE REPORT_UID="+cReportUID
			cBodyText := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "BodyText")
			SELF:CheckAndRenumber_CurrentItemNo(cUID, cValue, nFormulas, cBodyText)
			InfoBox(nFormulas:ToString()+" Calculated fields updated")	//+CRLF+CRLF+"Please press the Refresh button to see the changes")
		ELSE
			IF ! StringIsNumeric(cValue)
				ErrorBox("The ItemNo '"+cValue+"' is already in use by Item: "+cDuplicate, "Editing aborted")
				SELF:Items_Refresh()
				RETURN
			ENDIF
			LOCAL cReportName := oMyLBControl:GetDisplayItemValue(oMyLBControl:SelectedIndex):ToString() AS STRING
			IF QuestionBox("The ItemNo '"+cValue+"' is already in use by Item: "+cDuplicate+CRLF+CRLF+;
							"Do you want to shift All Report Items one number up starting from: "+cValue+CRLF+;
							"for the Report: "+cReportName+" ?", ;
							"Re-number All Report Items") <> System.Windows.Forms.DialogResult.Yes
				SELF:Items_Refresh()
				RETURN
			ENDIF
			SELF:CheckAndRenumber_ItemNo(cUID, cValue)
		ENDIF
		cValue := cValue:ToUpper()
		cReplace := "'"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"

	CASE InListExact(cField, "Unit") .AND. cValue:Length > 30
		ErrorBox("The field '"+cField+"' must contain up to 30 characters", "Editing aborted")
		SELF:Items_Refresh()
		RETURN

	CASE InListExact(cField, "Unit")
		cReplace := "'"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"

	CASE cField == "CalculatedField"
		LOCAL cError := "" AS STRING
		IF ! SELF:CalculatedFieldValidated(cValue, cError)
			ErrorBox(cError+"Please write a calculation formula using ItemNo IDs"+CRLF+"Example: (ID245 / ID203) * 24", "Editing aborted")
			SELF:Items_Refresh()
			RETURN
		ENDIF

		cReplace := "'"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"

		// Mandatory: Off
		cStatement:="UPDATE FMReportItems SET"+;
					" Mandatory=0"+;
					" WHERE ITEM_UID="+cUID
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		oDataRow:Item["Mandatory"] := FALSE

		// ItemType: Number
		cStatement:="UPDATE FMReportItems SET"+;
					" ItemType='N'"+;
					" WHERE ITEM_UID="+cUID
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		oDataRow:Item["ItemType"] := "N"

	CASE cField == "ItemTypeValues"
		//////////////////////////////////////////////////////////
		//	Added By Kiriakos in order to Support Combobox Week
		//////////////////////////////////////////////////////////
		IF ! (cValue:ToUpper() == "WEEK" || cValue:ToUpper() == "USERS" || cValue:ToUpper() == "PORTS" || checkForLinkedList(cValue:ToUpper())) 
			cValue := cValue:TrimEnd(';')
			IF cValue:IndexOf(";") == -1 .AND. cValue:Length>0
				ErrorBox("The field '"+cField+"' must contain at least 2 Items (phrases separated by ';')", "Editing aborted")
				SELF:Items_Refresh()
				RETURN
			ENDIF
			LOCAL cItems := cValue:Split(';') AS STRING[]
			LOCAL nEmpty AS INT
			FOREACH cItem AS STRING IN cItems
				IF cItem:Trim() == ""
					nEmpty++
				ENDIF
			NEXT
			IF nEmpty > 1
				ErrorBox("The field '"+cField+"' contains more than one empty Items", "Editing aborted")
				SELF:Items_Refresh()
				RETURN
			ENDIF
		ENDIF
		cReplace := "'"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"
		//////////////////////////////////////////////////////////
		//	Added By Kiriakos in order to Support Combobox Week
		//////////////////////////////////////////////////////////

	CASE cField == "uItemType" .AND. oRow:Item["CalculatedField"]:ToString():Trim() <> ""
		ErrorBox("A CalculatedField must be of type: Number", "Editing aborted")
		SELF:Items_Refresh()
		RETURN
			
	CASE cField == "uItemType"
		cValue := SELF:cItemTypeValue
		
		IF  oRow:Item["SLAA"]:ToString():Trim() == "True"
			IF cValue == "Boolean" .OR. cValue == "Coordinate" .OR. cValue == "Table" 
			ErrorBox("Tables, Booleans, Coordinates, Labels and DateTimes Can not be on the same line as other items.", "Editing aborted")
			SELF:Items_Refresh()
			RETURN
		ELSEIF (cValue == "Label") .AND. !SELF:isItemOnTable(e:RowHandle)
			ErrorBox("Tables, Booleans, Coordinates and Labels Can not be on the same line as other items.", "Editing aborted")
			SELF:Items_Refresh()
			RETURN
		ENDIF	
		ENDIF
		
		// Remove the leading 'u'
		cField := cField:Substring(1)
		
		DO CASE
		CASE cValue == "Boolean"
			cReplace := "'B'"
			cValue := "B"

		CASE cValue == "ComboBox"
			cReplace := "'X'"
			cValue := "X"

		CASE cValue == "Coordinate"
			cReplace := "'C'"
			cValue := "C"

		CASE cValue == "DateTime"
			cReplace := "'D'"
			cValue := "D"

///////////////////////////////////////////////////////////
// ADDED BY KIRIAKOS In Order to Support DateTimePickerNULL
///////////////////////////////////////////////////////////
		//CASE cValue == "DateTimeNull"
		//	cReplace := "'E'"
		//	cValue := "E"
///////////////////////////////////////////////////////////
// ADDED BY KIRIAKOS In Order to Support DateTimePickerNULL
///////////////////////////////////////////////////////////

		CASE cValue == "Number"
			cReplace := "'N'"
			cValue := "N"

		CASE cValue == "Text"
			cReplace := "'T'"
			cValue := "T"

		CASE cValue == "Text multiline"
			cReplace := "'M'"
			cValue := "M"
		
		CASE cValue == "File Uploader"
			cReplace := "'F'"
			cValue := "F"
			
		CASE cValue == "Label"
			cReplace := "'L'"
			cValue := "L"
			
		CASE cValue == "Table"
			cReplace := "'A'"
			cValue := "A"
		ENDCASE

		IF cValue <> "Number"
			// Remove Min, Max values
			cStatement:="UPDATE FMReportItems SET"+;
						" MinValue=NULL, MaxValue=NULL"+;
						" WHERE ITEM_UID="+cUID
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			oDataRow:Item["MinValue"] := System.DBNull.Value
			oDataRow:Item["MaxValue"] := System.DBNull.Value
		ENDIF

	CASE cField == "Mandatory" .AND. oRow:Item["CalculatedField"]:ToString():Trim() <> ""
		ErrorBox("A CalculatedField cannot be Mandatory", "Editing aborted")
		SELF:Items_Refresh()
		RETURN

	CASE cField == "Mandatory"
		IF ToLogic(cValue) .AND. oRow:Item["CalculatedField"]:ToString():Trim() == ""
			cReplace := "1"
			cValue := "true"
		ELSE
			cReplace := "0"
			cValue := "false"
		ENDIF

	CASE cField == "SLAA" .AND. ( oRow:Item["ItemType"]:ToString():Trim() == "L") .AND. !SELF:isItemOnTable(e:RowHandle) 
		ErrorBox("Tables, Booleans, Coordinates, Labels and DateTimes Can not be on the same line as other items.", "Editing aborted")
		SELF:Items_Refresh()
		RETURN

	CASE cField == "SLAA" .AND. ( oRow:Item["ItemType"]:ToString():Trim() == "A" .OR. oRow:Item["ItemType"]:ToString():Trim() == "B" .OR. oRow:Item["ItemType"]:ToString():Trim() == "C")
		ErrorBox("Tables, Booleans, Coordinates, Labels and DateTimes Can not be on the same line as other items.", "Editing aborted")
		SELF:Items_Refresh()
		RETURN

	CASE cField == "SLAA"
		IF ToLogic(cValue) 
			cReplace := "1"
			cValue := "true"
		ELSE
			cReplace := "0"
			cValue := "false"
		ENDIF

	CASE cField == "NotNumbered"
		IF ToLogic(cValue) 
			cReplace := "1"
			cValue := "true"
		ELSE
			cReplace := "0"
			cValue := "false"
		ENDIF

	CASE cField == "ShowOnlyOffice"
		IF ToLogic(cValue) 
			cReplace := "1"
			cValue := "true"
		ELSE
			cReplace := "0"
			cValue := "false"
		ENDIF

	CASE cField == "IsDD" .AND. oRow:Item["ItemType"]:ToString():Trim() != "D"
		ErrorBox("Only Dates can be Due Dates.", "Editing aborted")
		SELF:Items_Refresh()
		RETURN

	CASE cField == "IsDD"
		IF ToLogic(cValue) 
			cReplace := "1"
			cValue := "true"
		ELSE
			cReplace := "0"
			cValue := "false"
		ENDIF

	CASE cField == "ShowOnMap"
		IF ToLogic(cValue)
			cReplace := "1"
			cValue := "true"
		ELSE
			cReplace := "0"
			cValue := "false"
		ENDIF

	CASE cField == "MinValue"
		cReplace := cValue:Replace(oMainForm:decimalSeparator, ".")
		LOCAL cMax := oRow:Row["MaxValue"]:ToString() AS STRING
		IF cMax <> ""
			IF Convert.ToDouble(cValue) > Convert.ToDouble(cMax)
				ErrorBox("The MaxValue must be greater than or equal to MinValue", "Editing aborted")
				SELF:Items_Refresh()
				RETURN
			ENDIF
			IF Convert.ToDouble(cValue) == (Double)0 .AND. Convert.ToDouble(cMax) == (Double)0
				cReplace := "NULL"
				cStatement:="UPDATE FMReportItems SET"+;
							" MaxValue=NULL"+;
							" WHERE ITEM_UID="+cUID
				oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				oDataRow:Item["MaxValue"] := System.DBNull.Value
			ENDIF
		ENDIF

	CASE cField == "MaxValue"
		cReplace := cValue:Replace(oMainForm:decimalSeparator, ".")
		LOCAL cMin := oRow:Row["MinValue"]:ToString() AS STRING
		IF cMin <> ""
			IF Convert.ToDouble(cValue) < Convert.ToDouble(cMin)
				ErrorBox("The MaxValue must be greater than or equal to MinValue", "Editing aborted")
				SELF:Items_Refresh()
				RETURN
			ENDIF
			IF Convert.ToDouble(cValue) == (Double)0 .AND. Convert.ToDouble(cMin) == (Double)0
				cReplace := "NULL"
				cStatement:="UPDATE FMReportItems SET"+;
							" MinValue=NULL"+;
							" WHERE ITEM_UID="+cUID
				oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				oDataRow:Item["MinValue"] := System.DBNull.Value
			ENDIF
		ENDIF

	CASE cField == "ItemCaption"
		cReplace := "'"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"
	CASE cField == "uColumnColor"
		ucField := cField
		// Remove the leading 'u'
		cField := cField:Substring(1)
		// The Color contains: <A, R, G, B>. The saved Table column has: <R, G, B>
		cReplace := RGB(SELF:oChangedReportColor:R, SELF:oChangedReportColor:G, SELF:oChangedReportColor:B):ToString()
	OTHERWISE
		cReplace := cValue
	ENDCASE

	// Update Vessels or SupVessels
	cStatement:="UPDATE FMReportItems SET"+;
				" "+cField+"="+cReplace+;
				" WHERE ITEM_UID="+cUID
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:Items_Refresh()
		RETURN
	ENDIF
	IF InListExact(cField, "Unit")
		LOCAL cItemName := oRow:Item["ItemName"]:ToString() AS STRING
		IF !cItemName:EndsWith("("+cValue+")")
			
			//MessageBox.Show(oRow:Item["Unit"]:ToString(),oDataRow:Item["Unit"]:ToString())
			
			IF cItemName:EndsWith("("+previousGridValue+")")
				cItemName:Replace("("+previousGridValue+")","("+cValue+")")
			ELSE
				cItemName:=cItemName:Trim() +" ("+cValue+")"
			ENDIF
			
			cStatement:="UPDATE FMReportItems SET"+;
				" ItemName='"+cItemName+"'"+;
				" WHERE ITEM_UID="+cUID
			IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				SELF:Items_Refresh()
				RETURN
			ENDIF
			oDataRow:Item["ItemName"] := cItemName
		
		ENDIF
	ENDIF
	// Update DataTable and Grid
	IF cReplace == "NULL"
		oDataRow:Item[cField] := System.DBNull.Value
	ELSEIF cField == "ColumnColor"
		SELF:Items_Refresh()
	ELSE
		oDataRow:Item[cField] := cValue
	ENDIF
	SELF:oDTItems:AcceptChanges()
	// Invalidates the region occupied by the current View (adds it to the control's update region that will be repainted
	// during the next paint operation), and causes a paint message to be sent to the grid control
	SELF:lChanged := TRUE
	SELF:GridViewItems:Invalidate()
RETURN


METHOD Occurs(cWhat AS STRING, cText AS STRING) AS INT
	LOCAL nInstances AS INT
	LOCAL aChar := cWhat:ToCharArray() AS CHAR[]
	LOCAL aTokens := cText:Split(aChar) AS STRING[]

	nInstances := aTokens:Length - 1
RETURN nInstances


METHOD CalculatedFieldValidated(cValue AS STRING, cError REF STRING) AS LOGIC
	// (ID245 / ID203) * 24
	IF cValue:Trim() == ""
		RETURN TRUE
	ENDIF

	LOCAL c, cWord, cValidChars := "ID0123456789+-*/ ()" AS STRING
	LOCAL cSep := "+-*/" AS STRING
	LOCAL n, nLen := cValue:Length - 1 AS INT
	LOCAL lPropellerPitch := cValue:ToUpper():Contains("PROPELLERPITCH") AS LOGIC

	//wb(SELF:Occurs("(", cValue), SELF:Occurs(")", cValue))
	IF SELF:Occurs("(", cValue) <> SELF:Occurs(")", cValue)
		cError := "Unbalanced parenthesis found into the Folmula: "+cValue+CRLF+CRLF
		RETURN FALSE
	ENDIF

	LOCAL aTokens := ArrayList{} AS ArrayList
	//LOCAL aOper := ArrayList{} AS ArrayList
	cValue := cValue:ToUpper()
	cWord := ""

	FOR n:=0 UPTO nLen
		c := cValue:Substring(n, 1)
		IF lPropellerPitch .AND. "PROPELLERPITCH":Contains(c:ToUpper())
			cWord += c
			LOOP
		ENDIF

		IF ! cValidChars:Contains(c)
			cError := "Invalid character: "+c+CRLF+CRLF
			RETURN FALSE
		ENDIF

		IF cSep:Contains(c)
			IF cWord:Trim() <> ""
				aTokens:Add(cWord)
				//aOper:Add(c)
			ENDIF
			cWord := ""
			LOOP
		ENDIF

		cWord += c
	NEXT
	IF cWord:Trim() <> ""
		aTokens:Add(cWord)
	ENDIF

	//LOCAL cStr AS STRING
	//FOR n:=0 UPTO aTokens:Count - 2
	//	cStr += "Token: "+aTokens[n]:ToString()+", Oper: "+aOper[n]:ToString()+CRLF
	//NEXT
	//cStr += "Token: "+aTokens[n]:ToString()
	//wb(cStr)

	LOCAL oFormulaCompiler := FormulaCompiler{SELF:GridViewItems, cValue, aTokens} AS FormulaCompiler
	IF ! oFormulaCompiler:TokensChecked(cError)
		RETURN FALSE
	ENDIF

	//// Amount result
	//LOCAL cValueText AS STRING
	//IF cValue:Contains("(")
	//	IF ! oFormulaCompiler:ParseExpressionParenthesis(cValue, cValueText, cError)
	//		RETURN FALSE
	//	ENDIF
	//ELSE
	//	cValueText := oFormulaCompiler:ReplaceExpressionTerms(cValue, cValue)
	//	IF cValueText == ""
	//		RETURN FALSE
	//	ENDIF

	//	// Calculate *, /
	//	// Calculate +, -
	//	cValueText := oFormulaCompiler:CalculateExpression(cValueText)
	//ENDIF
	////wb(cValue+CRLF+cValueText)
RETURN TRUE


METHOD CheckAndRenumber_ItemNo(cEditUID AS STRING, cValue AS STRING, lLoud := TRUE AS LOGIC) AS VOID
	LOCAL oMyLBControl AS DevExpress.XtraEditors.ListBoxControl 
	IF SELF:tabControl1:SelectedIndex == 0
		oMyLBControl := SELF:LBCReports
	ELSE
		oMyLBControl := SELF:LBCOfficeReports
	ENDIF				
		
	LOCAL cStatement, cItemNo, cBodyText AS STRING
	LOCAL nStartNo, nNo AS INT
	LOCAL cReportUID := oMyLBControl:SelectedValue:ToString() AS STRING
	//Bring all reportItems for this report
	cStatement:="SELECT ITEM_UID, ItemNo, CalculatedField"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMReportTypes ON FMReportTypes.REPORT_UID=FMReportItems.REPORT_UID"+;
				"	AND FMReportTypes.REPORT_UID="+cReportUID+;
				" ORDER BY ItemNo"
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

	nStartNo := Convert.ToInt32(cValue)

	// Get Reports's BodyText
	cStatement:="SELECT BodyText FROM FMBodyText"+oMainForm:cNoLockTerm+;
				" WHERE REPORT_UID="+cReportUID
	cBodyText := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "BodyText")

	LOCAL n, nCount := oDT:Rows:Count - 1, nFormulas := 0 AS INT
	// Re-number higher ItemNo to ItemNo + 1
	FOR n:=nCount DOWNTO 0
		cItemNo := oDT:Rows[n]:Item["ItemNo"]:ToString()
		IF ! StringIsNumeric(cItemNo)
			// TODO: Rename a-z ItemNo
			EXIT
		ENDIF
		nNo := Convert.ToInt32(cItemNo)
		// Modify only larger itemNos
		IF nNo >= nStartNo
			// Update Formulas
			SELF:UpdateFormulas(cItemNo, nNo + 1, nFormulas, cBodyText)

			// Update ItemNo
			cStatement:="UPDATE FMReportItems SET ItemNo="+(nNo + 1):ToString()+;
						" WHERE ITEM_UID="+oDT:Rows[n]:Item["ITEM_UID"]:ToString()
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ENDIF
	NEXT

	// Re-number current ItemNo to cValue
	
	IF lLoud
		SELF:CheckAndRenumber_CurrentItemNo(cEditUID, cValue, nFormulas, cBodyText)
		SELF:Items_Refresh()
		InfoBox(nFormulas:ToString()+" Calculated fields updated")	//+CRLF+CRLF+"Please press the Refresh button to see the changes")
	ENDIF
RETURN


METHOD UpdateFormulas(cItemNo AS STRING, nNo AS INT, nFormulas REF INT, cBodyText REF STRING) AS VOID
	LOCAL cStatement AS STRING
	LOCAL oMyLBControl AS DevExpress.XtraEditors.ListBoxControl 
	IF SELF:tabControl1:SelectedIndex == 0
		oMyLBControl := SELF:LBCReports
	ELSE
		oMyLBControl := SELF:LBCOfficeReports
	ENDIF
	
	LOCAL cReportUID := oMyLBControl:SelectedValue:ToString() AS STRING
	LOCAL oDTFormulas AS DataTable
	LOCAL cFormula, cItemTypeValues AS STRING

	// Update Formulas
	cStatement:="SELECT Distinct ITEM_UID, CalculatedField,ItemTypeValues "+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMReportTypes ON FMReportTypes.REPORT_UID=FMReportItems.REPORT_UID"+;
				"	AND FMReportTypes.REPORT_UID="+cReportUID+;
				" WHERE CalculatedField LIKE '%ID"+cItemNo+"%' OR CalculatedField LIKE '%ID "+cItemNo+"%'"+;
				" OR ItemTypeValues LIKE '%ID"+cItemNo+"%' OR ItemTypeValues LIKE '%ID "+cItemNo+"%'"
	oDTFormulas := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	FOREACH oRowFormula AS DataRow IN oDTFormulas:Rows
		cFormula := oRowFormula["CalculatedField"]:ToString()
		cItemTypeValues := oRowFormula["ItemTypeValues"]:ToString()
		
		cFormula := cFormula:Replace("ID"+cItemNo, "ID"+nNo:ToString())
		cFormula := cFormula:Replace("ID "+cItemNo, "ID "+nNo:ToString())
		
		cItemTypeValues := cItemTypeValues:Replace("ID"+cItemNo, "ID"+nNo:ToString())
		cItemTypeValues := cItemTypeValues:Replace("ID "+cItemNo, "ID "+nNo:ToString())
		
		cStatement:="UPDATE FMReportItems SET CalculatedField='"+cFormula+"', ItemTypeValues='"+cItemTypeValues+"' "+;
					" WHERE ITEM_UID="+oRowFormula:Item["ITEM_UID"]:ToString()
		IF oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			nFormulas++
		ENDIF
	NEXT

	// Update BodyText
	cBodyText := cBodyText:Replace("<ID"+cItemNo, "<ID"+nNo:ToString())
	cBodyText := cBodyText:Replace("+ID"+cItemNo, "+ID"+nNo:ToString())
RETURN


METHOD CheckAndRenumber_CurrentItemNo(cEditUID AS STRING, cValue AS STRING, nFormulas REF INT, cBodyText REF STRING) AS VOID
	// Re-number current ItemNo to cValue
	LOCAL cStatement AS STRING
	LOCAL oMyLBControl AS DevExpress.XtraEditors.ListBoxControl 
	IF SELF:tabControl1:SelectedIndex == 0
		oMyLBControl := SELF:LBCReports
	ELSE
		oMyLBControl := SELF:LBCOfficeReports
	ENDIF
	

	cStatement:="SELECT ItemNo"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" WHERE ITEM_UID="+cEditUID
	LOCAL cOldItemNo := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "ItemNo") AS STRING
	LOCAL nNo := Convert.ToInt32(cValue) AS INT

	// Update Formulas
	SELF:UpdateFormulas(cOldItemNo, nNo, nFormulas, cBodyText)

	// Update ItemNo
	cStatement:="UPDATE FMReportItems SET ItemNo="+nNo:ToString()+;
				" WHERE ITEM_UID="+cEditUID
	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)

	// Update BodyText
	LOCAL cReportUID := oMyLBControl:SelectedValue:ToString() AS STRING
	cStatement:="UPDATE FMBodyText SET BodyText='"+oSoftway:ConvertWildcards(cBodyText, FALSE)+"'"+;
				" WHERE REPORT_UID="+cReportUID
	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
RETURN


METHOD Items_Refresh() AS VOID
LOCAL cUID AS STRING

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewItems:GetRow(SELF:GridViewItems:FocusedRowHandle)

	IF oRow <> NULL
		cUID := oRow:Item["ITEM_UID"]:ToString()
	ENDIF

	IF SELF:tabControl1:SelectedIndex == 0
		SELF:CreateGridItems()
	ELSE
		SELF:CreateGridItemsOffice()
	ENDIF	
	

	IF oRow <> NULL
		LOCAL col AS DevExpress.XtraGrid.Columns.GridColumn
		LOCAL nFocusedHandle AS INT

		col:=SELF:GridViewItems:Columns["ITEM_UID"]
		nFocusedHandle:=SELF:GridViewItems:LocateByValue(0, col, Convert.ToInt32(cUID))
		IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
			RETURN
		ENDIF

		SELF:GridViewItems:ClearSelection()
		SELF:GridViewItems:FocusedRowHandle:=nFocusedHandle
		SELF:GridViewItems:SelectRow(nFocusedHandle)
	ENDIF	
RETURN


METHOD PreviewForm() AS VOID
	LOCAL oMyLBControl AS DevExpress.XtraEditors.ListBoxControl 
	IF SELF:tabControl1:SelectedIndex == 0
		oMyLBControl := SELF:LBCReports
	ELSE
		oMyLBControl := SELF:LBCOfficeReports
	ENDIF			
		
	LOCAL cReportUID := oMyLBControl:SelectedValue:ToString() AS STRING
	LOCAL cReportName := oMyLBControl:GetDisplayItemValue(oMyLBControl:SelectedIndex):ToString() AS STRING
	LOCAL cVesselName := oMainForm:GetVesselName AS STRING
	LOCAL cVesselUID := oMainForm:GetVesselUID AS STRING

	IF cReportName:ToUpper():StartsWith("MODE")
		wb("The virtual Report: "+cReportName+" cannot contain Items")
		RETURN
	ENDIF

	LOCAL cStatement AS STRING
	cStatement:="SELECT DISTINCT FMItemCategories.CATEGORY_UID, FMItemCategories.Description, FMItemCategories.SortOrder"+;
				" FROM FMItemCategories"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMReportItems ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
				" AND FMReportItems.REPORT_UID="+cReportUID+;
				" ORDER BY FMItemCategories.SortOrder"
	LOCAL oDTItemCategories := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

	cStatement:="SELECT FMReportItems.*"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" LEFT OUTER JOIN FMItemCategories ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
				" WHERE REPORT_UID="+cReportUID+;
				" ORDER BY FMItemCategories.SortOrder, ItemNo"
				//" AND CATEGORY_UID="+cCatUID+;
	LOCAL oDTReportItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

	LOCAL oReportTabForm := ReportTabForm{} AS ReportTabForm
    oReportTabForm:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Dpi
	oReportTabForm:Text := cVesselName + ": "+ cReportName
	oReportTabForm:cMyVesselName := cVesselName
	oReportTabForm:cVesselUID := cVesselUID
	oReportTabForm:cReportUID := cReportUID
	oReportTabForm:cReportName := cReportName
	oReportTabForm:oDTItemCategories := oDTItemCategories
	oReportTabForm:oDTReportItems := oDTReportItems
	oReportTabForm:lEnableControls := TRUE
	oReportTabForm:Show()
RETURN


METHOD OpenBodyISMForm() AS VOID
	LOCAL oBodyISMForm := BodyISMForm{} AS BodyISMForm
	LOCAL oMyLBControl AS DevExpress.XtraEditors.ListBoxControl 
	IF SELF:tabControl1:SelectedIndex == 0
		oMyLBControl := SELF:LBCReports
	ELSE
		oMyLBControl := SELF:LBCOfficeReports
	ENDIF	
	

	LOCAL cReportName := oMyLBControl:GetDisplayItemValue(oMyLBControl:SelectedIndex):ToString() AS STRING
	LOCAL cVesselName := oMainForm:GetVesselName AS STRING
	LOCAL cReportUID := oMyLBControl:SelectedValue:ToString() AS STRING

	oBodyISMForm:cReportUID := cReportUID
	oBodyISMForm:cReportName := cReportName
	oBodyISMForm:cVesselName := cVesselName

	oBodyISMForm:Show()
RETURN


METHOD Items_Print() AS VOID
	SELF:PrintPreviewGridItems()
RETURN

METHOD CheckIfReportBaseNumExists(iAmToChekc AS System.int32) AS LOGIC
	// Read the Report's ReportBaseNum
	LOCAL cStatement AS STRING
	//LOCAL cReportUID := SELF:LBCReports:SelectedValue:ToString() AS STRING

	cStatement:="SELECT ReportBaseNum"+;
				" FROM  FMReportTypes"+oMainForm:cNoLockTerm+;
				" WHERE ReportBaseNum='"+iAmToChekc:ToString()+"' "
	//MessageBox.Show("'"+oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "ReportBaseNum")+"'")
	TRY
		IF oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "ReportBaseNum") != ""
			RETURN TRUE
		ENDIF
	CATCH
		RETURN FALSE
	END TRY
RETURN FALSE

PRIVATE METHOD DuplicateItems() AS VOID
	///////////////////////////////////////////////////////////////////////////////////	
	//				ADDED BY KIRIAKOS AT 10/06/16
	///////////////////////////////////////////////////////////////////////////////////
	LOCAL cReportUID := "" AS STRING
	LOCAL oMyLBControl AS DevExpress.XtraEditors.ListBoxControl 
	LOCAL oSelectReportForm := SelectReportForm{} AS SelectReportForm
	oSelectReportForm:ShowDialog()
	cReportUID := oSelectReportForm:cReportUID
	oMyLBControl := oSelectReportForm:oMyLBControl
	IF oSelectReportForm:DialogResult == DialogResult.Cancel
		RETURN
	ENDIF
	///////////////////////////////////////////////////////////////////////////////////	
	//				ADDED BY KIRIAKOS AT 10/06/16
	///////////////////////////////////////////////////////////////////////////////////	

	LOCAL iIndexes AS INT[]
	LOCAL cLastItemNo AS STRING
	LOCAL oLastRow := (DataRowView)SELF:GridViewItems:GetRow(SELF:GridViewItems:RowCount - 1) AS DataRowView
	IF oLastRow == NULL
		RETURN
	ELSE
		cLastItemNo := oLastRow["ItemNo"]:ToString() 
	ENDIF
	//LOCAL cNextTimeNum as String
	iIndexes := SELF:GridViewItems:GetSelectedRows()
	
	IF(!checkIfNewReportBaseNumberIsValid(iIndexes:Length,Convert.ToInt32(cLastItemNo)))
		MessageBox.Show("Can not duplicate items because ItemNos overlap.")
		RETURN
	ENDIF
	
	LOCAL oRow AS DataRowView
		LOCAL i AS INT
		FOR i := 1 UPTO iIndexes:Length STEP 1
				oRow := (DataRowView)SELF:GridViewItems:GetRow(iIndexes[i])
				SELF:Items_Add(oRow, cReportUID)
		NEXT

///////////////////////////////////////////////////////////////////////////////////	
//				ADDED BY KIRIAKOS AT 10/06/16
///////////////////////////////////////////////////////////////////////////////////	
		//Select the Report from the list
		DO CASE
			CASE oMyLBControl:Name == "LBCReports"
				SELF:tabControl1:SelectedIndex := 0
				SELF:LBCReports:SelectedValue := cReportUID

			CASE oMyLBControl:Name == "LBCOfficeReports"
				SELF:tabControl1:SelectedIndex := 1
				SELF:LBCOfficeReports:SelectedValue := cReportUID
		ENDCASE
///////////////////////////////////////////////////////////////////////////////////	
//				ADDED BY KIRIAKOS AT 10/06/16
///////////////////////////////////////////////////////////////////////////////////	
		
		SELF:Items_Refresh()	
RETURN

METHOD checkIfNewReportBaseNumberIsValid(nCountSourceItems AS INT,nNewReportBaseNumber AS INT) AS LOGIC
	TRY
			LOCAL oDTReportItemsLocal AS DataTable
			LOCAL cStatement:="SELECT ReportBaseNum FROM FMReportTypes"+oMainForm:cNoLockTerm+;
							" ORDER BY ReportBaseNum ASC " AS STRING
			oDTReportItemsLocal:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
			oDTReportItemsLocal:TableName:="Reports"
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

METHOD isItemOnTable(iIndex AS INT) AS LOGIC
		//MessageBox.Show(iIndex:ToString(),"Index Send")		
		LOCAL oRow AS DataRowView
		oRow := (DataRowView)SELF:GridViewItems:GetRow(iIndex)
		IF oRow == NULL
			RETURN FALSE
		ENDIF
		LOCAL i AS INT
		FOR i := iIndex-1 DOWNTO 0 STEP 1
			oRow := (DataRowView)SELF:GridViewItems:GetRow(i)
			//MessageBox.Show( oRow:Item["ItemType"]:ToString()+"/"+ i:ToString(),oRow:Item["SLAA"]:ToString())	
			IF oRow:Item["SLAA"]:ToString() == "False" 
				IF oRow:Item["ItemType"]:ToString() == "A"
					RETURN TRUE
				ELSE
					RETURN FALSE
				ENDIF
			ENDIF
		NEXT
RETURN FALSE



PRIVATE METHOD getNextItemNo(cNextItemNo REF STRING) AS VOID
	LOCAL oMyLBControl AS DevExpress.XtraEditors.ListBoxControl 
	IF SELF:tabControl1:SelectedIndex == 0
		oMyLBControl := SELF:LBCReports
	ELSE
		oMyLBControl := SELF:LBCOfficeReports
	ENDIF			
		
		
	LOCAL cStatement AS STRING
	LOCAL cReportUID := oMyLBControl:SelectedValue:ToString() AS STRING
	LOCAL cLastItemNo AS STRING

	// Next ItemNo
	cNextItemNo := "0"
	// Read the last Item
	LOCAL oRow := (DataRowView)SELF:GridViewItems:GetRow(SELF:GridViewItems:RowCount - 1) AS DataRowView
	IF oRow == NULL
		cNextItemNo := SELF:nReportBaseNum:ToString()
		IF cNextItemNo <> ""
			cNextItemNo := (Convert.ToInt64(cNextItemNo) + 1):ToString()
		ENDIF
	ELSE
		cLastItemNo := oRow["ItemNo"]:ToString() 
		IF StringIsNumeric(cLastItemNo)
			cStatement:="SELECT Max(ItemNo) AS nMax"+;
						" FROM FMReportItems"+oMainForm:cNoLockTerm+;
						" WHERE REPORT_UID="+cReportUID
			cNextItemNo := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "nMax")
			cNextItemNo := (Convert.ToInt64(cNextItemNo) + 1):ToString()
		ELSEIF cLastItemNo:Length == 1
			cNextItemNo := Chr(Asc(cLastItemNo) + 1)
		ENDIF
	ENDIF
	
	IF Convert.ToInt32(cNextItemNo) == SELF:nReportBaseNum+100
		IF  CheckIfReportBaseNumExists(SELF:nReportBaseNum+100)
			ErrorBox("The ItemNo must be between: "+SELF:nReportBaseNum:ToString()+" and "+(SELF:nReportBaseNum + 99):ToString())
			RETURN
		ENDIF
	ENDIF

RETURN

METHOD Fill_LBCUsers(cItemUID AS STRING) AS VOID
	SELF:LBCInGroups:Items:Clear()
	SELF:LBCOutGroups:Items:Clear()
	
	LOCAL oDataRow AS DataRow
	LOCAL cStatement AS STRING
	
	oDataRow:=SELF:oDTItems:Rows:Find(cItemUID)
	LOCAL cGroups := oDataRow:Item["Groups_Owners"]:ToString() AS STRING
	IF cGroups == ""
		cStatement:="SELECT [GROUP_UNIQUEID], [GroupName], [Dep]"+;
				" FROM UserGroups "+oMainForm:cNoLockTerm+;
				" ORDER BY GroupName Asc"
		SELF:oDTGroups := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		
	IF SELF:oDTGroupsOut != NULL .AND. SELF:oDTGroupsOut:Rows:Count > 0
		SELF:oDTGroupsOut:Clear()
		SELF:LBCOutGroups:Items:Clear()
	ENDIF
		
	ELSE
		cStatement:="SELECT [GROUP_UNIQUEID], [GroupName], [Dep]"+;
				" FROM UserGroups "+oMainForm:cNoLockTerm+;
				" WHERE  GROUP_UNIQUEID IN ( "+cGroups+" ) "+;
				" ORDER BY GroupName Asc"
		SELF:oDTGroups := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		
		cStatement:="SELECT [GROUP_UNIQUEID], [GroupName], [Dep]"+;
				" FROM UserGroups "+oMainForm:cNoLockTerm+;
				" WHERE  GROUP_UNIQUEID NOT IN ( "+cGroups+" ) "+;
				" ORDER BY GroupName Asc"
		SELF:oDTGroupsOut := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)		
	ENDIF
		
	cStatement:="SELECT [User_UNIQUEID], [UserName], [UserNo]"+;
				" FROM Users "+oMainForm:cNoLockTerm+;
				" ORDER BY UserName Asc"
	SELF:oDTUsers := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	oSoftway:CreatePK(SELF:oDTUsers, "User_UNIQUEID")
	
	oSoftway:CreatePK(SELF:oDTGroups, "GROUP_UNIQUEID")
	SELF:LBCInGroups:DataSource := SELF:oDTGroups
	SELF:LBCInGroups:DisplayMember := "GroupName"
	SELF:LBCInGroups:ValueMember := "GROUP_UNIQUEID"

	IF SELF:oDTGroupsOut != NULL .AND. SELF:oDTGroupsOut:Rows:Count > 0
		oSoftway:CreatePK(SELF:oDTGroupsOut, "GROUP_UNIQUEID")
		SELF:LBCOutGroups:DataSource := SELF:oDTGroupsOut
		SELF:LBCOutGroups:DisplayMember := "GroupName"
		SELF:LBCOutGroups:ValueMember := "GROUP_UNIQUEID"
	ENDIF
	
RETURN

PRIVATE METHOD LBCGroups_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		
	LOCAL oRowLocal := oMainForm:returnUserSetting(oUser:USER_UNIQUEID) AS DataRow
	//WB(oRowLocal["CanEditVoyages"]:ToString())
	IF oRowLocal == NULL .OR. oRowLocal == NULL .OR. oRowLocal["CanEditReports"]:ToString() == "False"
		RETURN
	ENDIF		
		
	//Find the selected Item_UID
	LOCAL iIndexes AS INT[]
	iIndexes := SELF:GridViewItems:GetSelectedRows()
	IF iIndexes:Length < 1
		RETURN
	ELSEIF iIndexes:Length==1
		LOCAL oRow AS DataRowView
		oRow := (DataRowView)SELF:GridViewItems:GetRow(iIndexes[iIndexes:Length])
		LOCAL cItem_To_Update := oRow:Item["ITEM_UID"]:ToString() AS STRING
		
		LOCAL oDataRow AS DataRow
		oDataRow:=SELF:oDTItems:Rows:Find(cItem_To_Update)
		IF oDataRow == NULL
			ErrorBox("Cannot access current row", "Not changed")
			RETURN
		ENDIF
		LOCAL cGroups := oDataRow:Item["Groups_Owners"]:ToString() AS STRING
		IF SELF:LBCInGroups:SelectedIndex == -1
				RETURN
			ENDIF
		LOCAL cUID := SELF:LBCInGroups:GetItemValue(SELF:LBCInGroups:SelectedIndex):ToString() AS STRING
		//LOCAL cText := SELF:LBCInGroups:GetItemText(SELF:LBCInGroups:SelectedIndex) AS STRING
		
		IF cGroups == "" // Prepei na kanw insert
			cGroups := cUID 
			LOCAL cStatement:="INSERT INTO FMOfficeReportItems (ITEM_UID, Groups_Owners) VALUES"+;
				" ("+cItem_To_Update+", '"+cUID+"' )" AS STRING
			IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			RETURN
			ENDIF
		ELSE //Prepei na kanw delete
			//MessageBox.Show(cGroups,cUID)
			IF cGroups:StartsWith(cUID+",")  //delete the first element
				cGroups := cGroups:Substring(cUID:Length+1)
			ELSEIF cGroups:Contains(","+cUID+",")
				cGroups := cGroups:Replace(","+cUID,"")
			ELSEIF cGroups == cUID // Einai mono auto
				cGroups := ""
			ELSEIF cGroups:EndsWith(","+cUID) //delete the last element
				cGroups := cGroups:Substring(0,cGroups:Length-cUID:Length-1)
			ENDIF
			
			IF cGroups == ""
				LOCAL cStatement:="DELETE FROM FMOfficeReportItems WHERE ITEM_UID="+cItem_To_Update  AS STRING
				IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
					//Self:Items_Refresh()
				RETURN
				ENDIF
			ELSE
				LOCAL cStatement:="Update FMOfficeReportItems SET Groups_Owners='"+cGroups+"' WHERE ITEM_UID="+cItem_To_Update  AS STRING
				IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
					//Self:Items_Refresh()
				RETURN
				ENDIF
			ENDIF
		ENDIF
		oDataRow:Item["Groups_Owners"]:=cGroups
		SELF:oDTItems:AcceptChanges()
		SELF:GridViewItems:Invalidate()	
		updateUsers()
	ELSE
		MessageBox.Show("Can not update multiple rows.")
	ENDIF
		/*IF SELF:LBCInGroups:SelectedIndex == -1
				RETURN
			ENDIF
			LOCAL cUID := SELF:LBCInGroups:GetItemValue(SELF:LBCInGroups:SelectedIndex):ToString() AS STRING
			LOCAL cText := SELF:LBCInGroups:GetItemText(SELF:LBCInGroups:SelectedIndex) AS STRING
			LOCAL oDataRow AS DataRow
			oDataRow:=SELF:oDTGroups:Rows:Find(cUID)
			LOCAL cDep := oDataRow:Item["Dep"]:ToString() as String
			//MessageBox.Show(cDep)
			LOCAL cToTest AS STRING
			LOCAL i as INT
			FOR i := 0 UPTO cDep:Length-1 STEP 1
				cToTest := cDep:Chars[i]:ToString()
				IF cToTest == "1" // User Belongs To Group
				
				ENDIF
			NEXT
			//MessageBox.Show(cToTest)*/
RETURN


PRIVATE METHOD LBCGroupsOut_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		
	LOCAL oRowLocal := oMainForm:returnUserSetting(oUser:USER_UNIQUEID) AS DataRow
	IF oRowLocal == NULL .OR. oRowLocal == NULL .OR. oRowLocal["CanEditReports"]:ToString() == "False"
		RETURN
	ENDIF
		
	LOCAL iIndexes AS INT[]
	iIndexes := SELF:GridViewItems:GetSelectedRows()
	IF iIndexes:Length < 1
		RETURN
	ELSEIF iIndexes:Length==1
		LOCAL oRow AS DataRowView
		oRow := (DataRowView)SELF:GridViewItems:GetRow(iIndexes[iIndexes:Length])
		LOCAL cItem_To_Update := oRow:Item["ITEM_UID"]:ToString() AS STRING
		
		LOCAL oDataRow AS DataRow
		oDataRow:=SELF:oDTItems:Rows:Find(cItem_To_Update)
		IF oDataRow == NULL
			ErrorBox("Cannot access current row", "Not changed")
			RETURN
		ENDIF
		LOCAL cGroups := oDataRow:Item["Groups_Owners"]:ToString() AS STRING
		IF SELF:LBCOutGroups:SelectedIndex == -1
				RETURN
			ENDIF
		LOCAL cUID := SELF:LBCOutGroups:GetItemValue(SELF:LBCOutGroups:SelectedIndex):ToString() AS STRING
		//LOCAL cText := SELF:LBCOutGroups:GetItemText(SELF:LBCOutGroups:SelectedIndex) AS STRING
		
		IF cGroups == "" 
			MessageBox.Show("This is not possible")
			RETURN
		ELSE //Prepei na kanw update
			cGroups := cGroups+","+cUID
			LOCAL cStatement:="Update FMOfficeReportItems SET Groups_Owners='"+cGroups+"' WHERE ITEM_UID="+cItem_To_Update  AS STRING
			IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				//Self:Items_Refresh()
			RETURN
			ENDIF
		ENDIF
		oDataRow:Item["Groups_Owners"]:=cGroups
		SELF:oDTItems:AcceptChanges()
		// Invalidates the region occupied by the current View (adds it to the control's update region that will be repainted
		// during the next paint operation), and causes a paint message to be sent to the grid control
		SELF:GridViewItems:Invalidate()	
		IF SELF:oDTGroupsOut:Rows:Count==1
			SELF:oDTGroupsOut:Clear()
			SELF:LBCOutGroups:Items:Clear()
		ENDIF
		
		updateUsers()
	ELSE
		MessageBox.Show("Can not update multiple rows.")
	ENDIF
RETURN


PRIVATE METHOD updateUsers() AS VOID
	//MessageBox.Show(((DataRowView)SELF:GridViewItems:GetRow(e:FocusedRowHandle)):Item["ITEM_UID"]:ToString())
	LOCAL iIndexes AS INT[]
	//LOCAL cNextTimeNum as String
	iIndexes := SELF:GridViewItems:GetSelectedRows()
	IF iIndexes:Length < 1
		RETURN
	ELSEIF iIndexes:Length==1
		LOCAL oRow AS DataRowView
		oRow := (DataRowView)SELF:GridViewItems:GetRow(iIndexes[iIndexes:Length])
		//MessageBox.Show(oRow:Item["ITEM_UID"]:ToString(),"1")
		Fill_LBCUsers(oRow:Item["ITEM_UID"]:ToString())
		/*RETURN
		IF SELF:GridViewItems:IsGroupRow(self:GridViewItems:getfo)
			Return
		endif		
		Local oRow as DataRowView
		oRow:=(DataRowView)SELF:GridViewItems:GetRow(e:FocusedRowHandle)
		if oRow == NULL
			Return
		ENDIF
		MessageBox.Show(oRow:Item["ITEM_UID"]:ToString())*/
	/*ELSE
		LOCAL oRow AS DataRowView
		oRow := (DataRowView)SELF:GridViewItems:GetRow(iIndexes[iIndexes:Length])*/
		//SELF:updateUsers(oRow:Item["ITEM_UID"]:ToString())
		//MessageBox.Show(oRow:Item["ITEM_UID"]:ToString(),iIndexes:Length:ToString()+".")
	ENDIF
RETURN


PRIVATE METHOD updateUsers(cItem_UID AS STRING) AS VOID
	//MessageBox.Show(cItem_UID)
RETURN

PRIVATE METHOD updateUsers(oRow AS DataRow) AS VOID
	//MessageBox.Show(oRow:Item["ITEM_UID"]:ToString())
RETURN

PRIVATE METHOD updateUsers(oRow AS DataRowView) AS VOID
	//MessageBox.Show(oRow:Item["ITEM_UID"]:ToString())
RETURN

METHOD AddColumn(cName AS STRING,cPrcnt AS STRING,cType AS STRING,cMandatory AS STRING,cShowOnMap AS STRING,cIsDueDate AS STRING,cShowOffice AS STRING,cComboItems AS STRING,cMinValue AS STRING,cMaxValue AS STRING,cHasLabels AS STRING) AS VOID
				LOCAL cShortType AS STRING
				IF cType == "Text"
					cShortType := "T"
				ELSEIF cType == "Combobox"
					cShortType := "X"
				ELSEIF cType == "DateTime"
					cShortType := "D"
				ELSEIF cType == "Number"
					cShortType := "N"
				ELSEIF cType == "Text Multiline"
					cShortType := "M"
				ELSEIF cType == "Label"
					cShortType := "L"
				ELSEIF cType == "File Uploader"
					cShortType := "F"
				ELSE
					cShortType := "T"
				ENDIF
					
				LOCAL oRow AS DataRowView
				LOCAL nRowHandle := SELF:GridViewItems:FocusedRowHandle AS INT
				oRow:=(DataRowView)SELF:GridViewItems:GetRow(nRowHandle)
				IF oRow == NULL
					RETURN
				ENDIF
				
				LOCAL cLocalUID := oRow:Item["ITEM_UID"]:ToString() AS STRING
				LOCAL cCategoryUIDLocal := oRow:Item["CATEGORY_UID"]:ToString() AS STRING
				//wb("'"+cCategoryUIDLocal+"'")
				IF STRING.IsNullOrEmpty(cCategoryUIDLocal)
					cCategoryUIDLocal := "0"
				ENDIF
				
				IF oRow:Item["ItemType"]:ToString() <> "A"
						MessageBox.Show("You can add columns only on Table items.")
						RETURN
				ENDIF
				LOCAL cLocalItemTypeValues := oRow:Item["ItemTypeValues"]:ToString():Trim() AS STRING
				
				LOCAL iCountOldColumns,iCountNewColumns AS INT
				iCountOldColumns := cLocalItemTypeValues:Length - cLocalItemTypeValues:Replace(":",""):Length
				iCountNewColumns := iCountOldColumns+1
				
				cLocalItemTypeValues += ";"+cName+":"+cPrcnt
				
				LOCAL cReplace := "'"+oSoftway:ConvertWildcards(cLocalItemTypeValues, FALSE)+"'" AS STRING
				
				LOCAL cStatement:="UPDATE FMReportItems SET"+;
				" ItemTypeValues = "+cReplace+;
				" WHERE ITEM_UID="+cLocalUID AS STRING
				IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
					SELF:Items_Refresh()
					RETURN
				ENDIF
				LOCAL oDataRow:=SELF:oDTItems:Rows:Find(cLocalUID) AS DataRow
				IF oDataRow == NULL
					ErrorBox("Cannot access current row")
					SELF:Items_Refresh()
				ENDIF
				oDataRow:Item["ItemTypeValues"] := cLocalItemTypeValues
				SELF:oDTItems:AcceptChanges()
				SELF:GridViewItems:Invalidate()
				
				LOCAL iIndexes AS INT[]
				iIndexes := SELF:GridViewItems:GetSelectedRows()
				
				LOCAL iCountRows := SELF:GridViewItems:RowCount AS INT
				LOCAL oRowToTest AS DataRowView
				LOCAL iStart := iIndexes[1]  , iAmLastInsert := iIndexes[1] AS INT
				//local iProgressOverTheGrid := iIndexes[1] as INT
				LOCAL i AS INT
				LOCAL oMyLBControl AS DevExpress.XtraEditors.ListBoxControl 
				IF SELF:tabControl1:SelectedIndex == 0
					oMyLBControl := SELF:LBCReports
				ELSE
					oMyLBControl := SELF:LBCOfficeReports
				ENDIF	
				
				LOCAL cReportUID := oMyLBControl:SelectedValue:ToString() AS STRING
				LOCAL cNextUID AS STRING
				
				IF(iIndexes:Length==1)
					//WB(iProgressOverTheGrid:ToString()+"/"+iCountRows:ToString())
					FOR i := iStart+1  UPTO iCountRows STEP 1
						oRowToTest := (DataRowView)SELF:GridViewItems:GetRow(i)
						IF oRowToTest <> NULL
							//WB("Testing : "+oRowToTest:Item["ItemNo"]:ToString()+"/"+i:ToString())
							//IF SELF:isItemOnTable(iProgressOverTheGrid+1)
							//WB(oRowToTest:Item["SLAA"]:ToString())
							 
								
								//wb("Item On Table, Modulo : "+((i-iAmLastInsert)%iCountNewColumns):toString())
							IF (i-iAmLastInsert)%iCountNewColumns == 0
									iAmLastInsert := i//iProgressOverTheGrid+1
									//iProgressOverTheGrid := iProgressOverTheGrid+1
									
									cStatement:=" SELECT IDENT_CURRENT('FMReportItems') + IDENT_INCR('FMReportItems') as nMax"
									cNextUID := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "nMax")
									//wb(cNextUID)
									
									SELF:CheckAndRenumber_ItemNo(cNextUID, oRowToTest:Item["ItemNo"]:ToString(),FALSE)
									cStatement:="INSERT INTO FMReportItems (REPORT_UID, ItemNo, ItemName, ItemType, ExpDays, CATEGORY_UID,SLAA,ItemTypeValues,ShowOnlyOffice, IsDD, Mandatory) VALUES"+;
												" ("+cReportUID+", '"+oRowToTest:Item["ItemNo"]:ToString()+"', '"+cName+"', '"+cShortType+"', 0, "+cCategoryUIDLocal+",1,'"+cComboItems+"',"+cShowOffice+","+cIsDueDate+","+cMandatory+")"
									IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
										MessageBox.Show(cStatement)
										SELF:Items_Refresh()
										RETURN
									ELSE
										iCountRows := iCountRows+1
										SELF:Items_Refresh()
									ENDIF
								IF oRowToTest:Item["SLAA"]:ToString() == "False"
									MessageBox.Show("Found the end of table.")
									EXIT
								//ELSE
								//	iProgressOverTheGrid := iProgressOverTheGrid+1
								ENDIF	 
							ENDIF
						
						ENDIF	
						
						
					NEXT
				ENDIF
				
RETURN





#Region PrintPreview

METHOD PrintPreviewGridItems() AS VOID
	// Check whether the XtraGrid control can be previewed.
	IF ! SELF:GridItems:IsPrintingAvailable
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
	oLink:Component := SELF:GridItems
	// Set the paper format.
	oLink:PaperKind := System.Drawing.Printing.PaperKind.A4
	oLink:Landscape:=TRUE
	// Subscribe to the CreateReportHeaderArea event used to generate the report header.
	oLink:CreateReportHeaderArea += CreateAreaEventHandler{SELF, @PrintableComponentLinkItems_CreateReportHeaderArea()}
	// Generate the report.
	oLink:CreateDocument()
	// Hide Send via eMail TooBar Button
	oPS:SetCommandVisibility(PrintingSystemCommand.SendFile, CommandVisibility.None)
	// Show the report.
	oLink:ShowPreview()
RETURN


METHOD PrintableComponentLinkItems_CreateReportHeaderArea(sender AS OBJECT, e AS CreateAreaEventArgs) AS VOID
	LOCAL oMyLBControl AS DevExpress.XtraEditors.ListBoxControl 
	IF SELF:tabControl1:SelectedIndex == 0
		oMyLBControl := SELF:LBCReports
	ELSE
		oMyLBControl := SELF:LBCOfficeReports
	ENDIF		
		
	LOCAL cReportName := oMyLBControl:GetDisplayItemValue(oMyLBControl:SelectedIndex):ToString() AS STRING

	LOCAL cReportHeader := cReportName+" Items - Printed on "+Datetime.Now:ToString(ccDateFormat)+", "+Datetime.Now:ToString("HH:mm:ss")+" - User: "+oUser:UserID AS STRING

	e:Graph:StringFormat := BrickStringFormat{StringAlignment.Center}
	e:Graph:Font := Font{"Tahoma", 14, FontStyle.Bold}

	LOCAL rec := RectangleF{0, 0, e:Graph:ClientPageSize:Width, 50} AS RectangleF
	e:Graph:DrawString(cReportHeader, Color.Black, rec, DevExpress.XtraPrinting.BorderSide.None)
RETURN


METHOD bbiComboboxColorsItemClick() AS VOID
	LOCAL oCC := ComboboxColors{} AS ComboboxColors
	//oCC:cCallerReportName := cRepotName
	oCC:Show(SELF)
RETURN


METHOD GetReportBaseNum(cReportUIDLocal AS STRING) AS STRING
	// Read the Report's ReportBaseNum
	LOCAL cStatement, cReturnStringLocal := "" AS STRING

	cStatement:="SELECT ReportBaseNum"+;
				" FROM FMReportTypes"+oMainForm:cNoLockTerm+;
				" WHERE REPORT_UID="+cReportUIDLocal
	TRY
		cReturnStringLocal := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "ReportBaseNum")
	CATCH
		RETURN ""
	END TRY
RETURN cReturnStringLocal

#EndRegion


#region Relateditems
PRIVATE METHOD GetSelectedItemUID AS STRING
	LOCAL cItemUID AS STRING
	VAR iIndexes := GridViewItems:GetSelectedRows():ToList()
	IF iIndexes:Count:Equals(1)
		LOCAL oRow AS DataRowView
		FOREACH i AS INT IN iIndexes
			oRow := (DataRowView)SELF:GridViewItems:GetRow(i)
			cItemUID := oRow:Item["ITEM_UID"]:ToString()
		NEXT 
	ENDIF
	RETURN cItemUID

	
PUBLIC METHOD ShowRelatedItems() AS VOID
	LBCRelated:Items:Clear()
	VAR cItemUID := GetSelectedItemUID()
	
	IF string.IsNullOrEmpty(cItemUID)
		RETURN
	ENDIF
	
	VAR cStatement := "SELECT a.FMRD_UID, a.[Item2UID], c.ReportName + ', ' + b.ItemName RelatedItem " +;
						"FROM [FMRelatedData] a " +;
						"JOIN [FMReportItems] b ON a.Item2UID=b.ITEM_UID " +;
						"JOIN [FMReportTypes] c ON b.REPORT_UID=c.REPORT_UID " +;
						i"WHERE Item1UID={cItemUID} "
	VAR DTRelatedItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	
	oSoftway:CreatePK(DTRelatedItems, "Item2UID")

	SELF:LBCRelated:DataSource := DTRelatedItems
	SELF:LBCRelated:DisplayMember := "RelatedItem"
	SELF:LBCRelated:ValueMember := "FMRD_UID"
	RETURN

PRIVATE METHOD RemoveRelated() AS VOID
	TRY
		VAR cItemUID := SELF:GetSelectedItemUID()
		IF string.IsNullOrEmpty(cItemUID)
			RETURN
		ENDIF		
		LOCAL cRLTItemName := ((DataRowView)LBCRelated:SelectedItem):Item["RelatedItem"]:Tostring() AS STRING
		IF QuestionBox(i"Do you want to delete '{cRLTItemName}'?", "") <> System.Windows.Forms.DialogResult.Yes
			RETURN
		ENDIF
		VAR cFMRD_UID := LBCRelated:SelectedValue		
		VAR cStatement := i"Delete from [FMRelatedData] where [FMRD_UID]={cFMRD_UID}"
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:ShowRelatedItems()
	CATCH ex AS Exception
		ErrorBox(ex:Message, "Exception")
	END TRY
	
	return

#endregion


END CLASS


CLASS CBItemCategory //IMPLEMENTS IConvertible
	EXPORT cUID, cDescription AS STRING

	CONSTRUCTOR(_cUID AS STRING, _cDescription AS STRING)
		SELF:cUID := _cUID
		SELF:cDescription := _cDescription
	RETURN

	VIRTUAL METHOD ToString() AS STRING
	RETURN SELF:cDescription

	//PROTECTED METHOD ReformatReadValue(value AS  OBJECT, args AS ReformatReadValueArgs) AS  OBJECT
	//IF value:GetType() <> typeof(STRING) && args.TargetType == typeof(STRING)
	//	RETURN value:ToString()
	//ELSE
	//	RETURN SUPER:ReformatReadValue(value, args)
	//ENDIF

END CLASS
