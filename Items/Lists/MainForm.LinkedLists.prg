// MainForm.prg
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#using System.Drawing.Printing
#Using System.IO
#Using System.Collections
#USING System.Threading
#USING System.Collections.Generic
#using System.ComponentModel

#Using DevExpress.XtraEditors
#using DevExpress.LookAndFeel
#Using DevExpress.XtraGrid.Views.Grid
#Using DevExpress.XtraGrid.Views.Base
#using DevExpress.XtraPrinting
#Using DevExpress.XtraPrintingLinks
#using DevExpress.XtraGrid.Columns
#using DevExpress.XtraTreeList
#using DevExpress.XtraTreeList.Nodes
#using DevExpress.XtraBars

PARTIAL CLASS MainForm INHERIT DevExpress.XtraEditors.XtraForm

Method CreateGridLists_Columns(oGrid as DevExpress.XtraGrid.Views.Grid.GridView) as void
	Local oColumn as GridColumn
	Local nVisible:=0, nAbsIndex:=0 as int

	oColumn:=Self:CreateDXColumn("Description",	"Description",				False, DevExpress.Data.UnboundColumnType.String, ;
																			nAbsIndex++, nVisible++, 147, oGrid)
	//oColumn:UnboundExpression:="Description"							

	// Invisible
	oColumn:=Self:CreateDXColumn("List_UID","List_UID",						False, DevExpress.Data.UnboundColumnType.Integer, ;
																			nAbsIndex++, -1, -1, oGrid)
	//oColumn:UnboundExpression:="FLOW_UID"
	oColumn:Visible:=False
//oGrid:ColumnViewOptionsBehavior:Editable:=False
Return

Method CreateGridListItems_Columns(oGrid as DevExpress.XtraGrid.Views.Grid.GridView) as void
	Local oColumn as GridColumn
	Local nVisible:=0, nAbsIndex:=0 as int

	oColumn:=Self:CreateDXColumn("Description",	"Description",				False, DevExpress.Data.UnboundColumnType.String, ;
																			nAbsIndex++, nVisible++, 147, oGrid)
	//oColumn:UnboundExpression:="Description"							

	// Invisible
	oColumn:=Self:CreateDXColumn("List_Item_UID","List_Item_UID",						False, DevExpress.Data.UnboundColumnType.Integer, ;
																			nAbsIndex++, -1, -1, oGrid)
	//oColumn:UnboundExpression:="FLOW_UID"
	oColumn:Visible:=False
	//oGrid:ColumnViewOptionsBehavior:Editable:=False
RETURN

PUBLIC METHOD checkForList(cToTest AS STRING) AS STRING

	LOCAL cToReturn := "" AS STRING
	LOCAL cStatement:=" SELECT List_UID FROM DMFLists"+;
					  " WHERE  Description='"+oSoftway:ConvertWildcards(cToTest, FALSE)+"'" AS STRING
	LOCAL cDuplicate:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "List_UID") AS STRING
	IF cDuplicate <> "" .and. cDuplicate:Trim():Length>0
			cStatement :=   " SELECT DISTINCT Description as cData From DMFListItems Where FK_List_UID="+cDuplicate+;
							" Order By Description Asc"
			LOCAL oDTLocal := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

			FOREACH oRow AS DataRow IN oDTLocal:Rows
				cToReturn += oRow["cData"]:ToString() +";"
			NEXT
			IF cToReturn:Length>0
				cToTest := cToReturn
			ENDIF
	ENDIF

RETURN cToTest

END CLASS