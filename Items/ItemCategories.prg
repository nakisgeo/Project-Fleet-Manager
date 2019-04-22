// ItemCategories.prg
#Using System.Windows.Forms
#Using System.Data
#Using System.Drawing

PARTIAL CLASS ItemsForm INHERIT DevExpress.XtraEditors.XtraForm

METHOD Fill_LBCCategories() AS VOID
	SELF:LBCCategories:Items:Clear()

	LOCAL cStatement AS STRING

	cStatement:="SELECT CATEGORY_UID, Description, SortOrder"+;
				" FROM FMItemCategories"+oMainForm:cNoLockTerm+;
				" ORDER BY SortOrder"
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oSoftway:CreatePK(oDT, "CATEGORY_UID")

	SELF:LBCCategories:DataSource := oDT
	SELF:LBCCategories:DisplayMember := "Description"
	SELF:LBCCategories:ValueMember := "CATEGORY_UID"
RETURN


METHOD CategoryAdd() AS VOID
	IF QuestionBox("Do you want to Add a new Item Category ?", ;
					"Add") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	//LOCAL oItem := DevExpress.XtraEditors.Controls{} AS DevExpress.XtraEditors.Controls
	
	LOCAL cStatement, cNextSortOrder AS STRING

	cStatement:="SELECT Max(SortOrder) AS nMax"+;
				" FROM FMItemCategories"+oMainForm:cNoLockTerm
	cNextSortOrder := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "nMax")
    IF cNextSortOrder == NULL .or. cNextSortOrder == ""
        cNextSortOrder := "1"
    ELSE
        cNextSortOrder := (Convert.ToInt64(cNextSortOrder) + 1):ToString()
    ENDIF
	cStatement:="INSERT INTO FMItemCategories (Description, SortOrder)"+;
				" VALUES ('_New Item Category', "+cNextSortOrder+")"
	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)

	//LOCAL cUID:=oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "FMItemCategories", "CATEGORY_UID") AS STRING

	SELF:CategoryRefresh("_New Item Category")
	SELF:CategoryEdit()
RETURN


METHOD CategoryEdit() AS VOID
	IF SELF:LBCCategories:SelectedIndex == -1
		RETURN
	ENDIF

	LOCAL cUID := SELF:LBCCategories:GetItemValue(SELF:LBCCategories:SelectedIndex):ToString() AS STRING
	LOCAL cText := SELF:LBCCategories:GetItemText(SELF:LBCCategories:SelectedIndex) AS STRING

	LOCAL oRenameForm := RenameForm{} AS RenameForm
	oRenameForm:ReportName:Text := cText
	IF oRenameForm:ShowDialog() <> DialogResult.OK
		RETURN
	ENDIF

	LOCAL cDescription := oRenameForm:ReportName:Text:Trim() AS STRING
	IF cDescription == ""
		ErrorBox("Category name not specified")
		RETURN
	ENDIF

	IF cDescription == "General"
		ErrorBox("The Category 'General' is reserved by the System for all Report Items not belonging to any defined Category", "Editing aborted")
		RETURN
	ENDIF


	LOCAL cStatement AS STRING
	cStatement:="UPDATE FMItemCategories SET"+;
				" Description='"+oSoftway:ConvertWildcards(cDescription, FALSE)+"'"+;
				" WHERE CATEGORY_UID="+cUID
	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)

	
	SELF:CreateGridItems_Columns()

	IF SELF:tabControl1:SelectedIndex == 0
		SELF:CreateGridItems()
	ELSE
		SELF:CreateGridItemsOffice()
	ENDIF	

	SELF:CategoryRefresh(cDescription)	
RETURN


METHOD CategoryDelete() AS VOID
	IF SELF:LBCCategories:SelectedIndex == -1
		RETURN
	ENDIF

	LOCAL nIndex := SELF:LBCCategories:SelectedIndex AS INT
	LOCAL cUID := SELF:LBCCategories:GetItemValue(nIndex):ToString() AS STRING
	LOCAL cDescription := SELF:LBCCategories:GetItemText(nIndex) AS STRING

	IF QuestionBox("Do you want to Delete the current Item Category:"+CRLF+CRLF+;
					cDescription+" ?", ;
					"Delete") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	LOCAL cStatement AS STRING
	LOCAL cItem AS STRING

	cStatement:="SELECT ItemName FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" WHERE CATEGORY_UID="+cUID
	cStatement := oSoftway:SelectTop(cStatement)
	cItem:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "ItemName")

	IF cItem <> ""
		ErrorBox("The current Item Category is already by the Item: "+cItem, ;
					"Delete aborded")
		RETURN
	ENDIF

	cStatement:="DELETE FROM FMItemCategories"+;
				" WHERE CATEGORY_UID="+cUID
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ErrorBox("Cannot Delete current Item Category", "Deletion aborted")
		RETURN
	ENDIF

	
	SELF:CreateGridItems_Columns()

	IF SELF:tabControl1:SelectedIndex == 0
		SELF:CreateGridItems()
	ELSE
		SELF:CreateGridItemsOffice()
	ENDIF

	SELF:CategoryRefresh("")
RETURN


METHOD CategoryRefresh(cDescription AS STRING) AS VOID
	//IF SELF:LBCCategories:SelectedItem <> NULL
	//	cUID := SELF:LBCCategories:GetItemValue(SELF:LBCCategories:SelectedIndex)
	//ENDIF

	SELF:Fill_LBCCategories()

	IF cDescription <> ""
		LOCAL nIndex := SELF:LBCCategories:FindStringExact(cDescription) AS INT
		IF nIndex <> -1
			SELF:LBCCategories:SelectedIndex := nIndex
		//ELSE
		//	SELF:LBCCategories:SelectedIndex := 0
		ENDIF
	ENDIF
RETURN


METHOD DropCategory(selectedIndex AS INT, oLBCRow AS DataRowView) AS VOID
	LOCAL cStatement AS STRING
	LOCAL cUID := oLBCRow["CATEGORY_UID"]:ToString() AS STRING
	LOCAL nOldSortOrder := Convert.ToInt32(oLBCRow["SortOrder"]:ToString()) AS INT
	LOCAL nSortOrder := selectedIndex + 1 AS INT

	IF nSortOrder == nOldSortOrder
		RETURN
	ENDIF

	//wb("nOldSortOrder="+nOldSortOrder:ToString()+CRLF+"nSortOrder="+nSortOrder:ToString()+CRLF+oLBCRow["Description"]:ToString())

	LOCAL oDT AS DataTable
	LOCAL n AS INT

	DO CASE
	CASE nSortOrder < nOldSortOrder
		// Move Categories one place down
		cStatement:="SELECT CATEGORY_UID, SortOrder FROM FMItemCategories"+oMainForm:cNoLockTerm+;
					" WHERE SortOrder >= "+nSortOrder:ToString()+;
					" AND CATEGORY_UID <> "+cUID+;
					" ORDER BY SortOrder"
		oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		n := nSortOrder
		FOREACH oRow AS DataRow IN oDT:Rows
			n++
			cStatement:="UPDATE FMItemCategories SET SortOrder="+n:ToString()+;
						" WHERE CATEGORY_UID="+oRow["CATEGORY_UID"]:ToString()
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		NEXT

	CASE nSortOrder > nOldSortOrder
		// Move Categories one place up
		cStatement:="SELECT CATEGORY_UID, SortOrder FROM FMItemCategories"+oMainForm:cNoLockTerm+;
					" WHERE SortOrder <= "+nSortOrder:ToString()+;
					" AND CATEGORY_UID <> "+cUID+;
					" ORDER BY SortOrder"
		oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		n := 0
		FOREACH oRow AS DataRow IN oDT:Rows
			n++
			cStatement:="UPDATE FMItemCategories SET SortOrder="+n:ToString()+;
						" WHERE CATEGORY_UID="+oRow["CATEGORY_UID"]:ToString()
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		NEXT
	ENDCASE

	// Update Dropped
	cStatement:="UPDATE FMItemCategories SET SortOrder="+nSortOrder:ToString()+;
				" WHERE CATEGORY_UID="+cUID
	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)

	
	SELF:CreateGridItems_Columns()

	IF SELF:tabControl1:SelectedIndex == 0
		SELF:CreateGridItems()
	ELSE
		SELF:CreateGridItemsOffice()
	ENDIF

	SELF:CategoryRefresh(oLBCRow["Description"]:ToString())
RETURN

END CLASS
