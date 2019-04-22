// CustomItemsForm_Methods.prg
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Collections
#Using DevExpress.XtraGrid.Views.Grid
#Using DevExpress.XtraGrid.Views.Grid.ViewInfo
#using DevExpress.XtraGrid.Columns

PARTIAL CLASS CustomItemsForm INHERIT DevExpress.XtraEditors.XtraForm
	PRIVATE oDTItems AS DataTable

METHOD CustomItemsForm_OnLoad() AS VOID
	oSoftway:ReadFormSettings_DevExpress(SELF, NULL, oMainForm:alForms, oMainForm:alData)

	SELF:CreateGridItems_Columns()
	SELF:CreateGridItems()
RETURN


METHOD CreateGridItems_Columns() AS VOID
LOCAL oColumn AS GridColumn
LOCAL nVisible:=0, nAbsIndex:=0 AS INT

	oColumn:=oMainForm:CreateDXColumn("Item ID", "ID",					FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																		nAbsIndex++, nVisible++, 50, SELF:GridViewItems)
    oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    oColumn:AppearanceHeader:Options:UseTextOptions := TRUE
    oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
	oColumn:ToolTip := "Custom Items ID starts from: 1000"+CRLF+;
						"1 - 999 are reserved for Monitoring Items"

	oColumn:=oMainForm:CreateDXColumn("Description", "Description",		FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 150, SELF:GridViewItems)

	oColumn:=oMainForm:CreateDXColumn("FriedlyDescription", "FriedlyDescription",FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 490, SELF:GridViewItems)

	oColumn:=oMainForm:CreateDXColumn("Unit", "Unit",					FALSE, DevExpress.Data.UnboundColumnType.String, ;
																		nAbsIndex++, nVisible++, 50, SELF:GridViewItems)
    oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    oColumn:AppearanceHeader:Options:UseTextOptions := TRUE
    oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
RETURN


METHOD CreateGridItems() AS VOID
	//SELF:GridItems:DataSource := NULL
	LOCAL cStatement AS STRING
	cStatement:="SELECT ID, Description, FriedlyDescription, Unit"+;
				" FROM FMCustomItems"+;
				" ORDER BY ID"
	SELF:oDTItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	SELF:oDTItems:TableName:="FMCustomItems"
	// Create Primary Key
	oSoftway:CreatePK(SELF:oDTItems, "ID")
	SELF:GridItems:DataSource := SELF:oDTItems
RETURN

END CLASS
