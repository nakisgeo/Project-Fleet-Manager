// Select_Operation_Methods.prg
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
#USING DevExpress.XtraBars
#USING DevExpress.XtraGrid.Views.Grid.ViewInfo

PARTIAL CLASS Select_Operation INHERIT System.Windows.Forms.Form

	EXPORT cReturnName AS STRING
	Export cReturnUID as String
	PRIVATE oDTOperations AS DataTable
	PRIVATE oDS := DataSet{} AS DataSet
	EXPORT  cCompanyBookUID := "0" AS STRING

EXPORT METHOD setCompanyBookUID(setter AS STRING) AS VOID
	SELF:cCompanyBookUID :=	setter
RETURN

PRIVATE METHOD Select_OperationForm_Onload AS VOID
	SELF:CreateGridOperations_Columns()
	SELF:oDS:Relations:Clear()
	//SELF:gridControl1:LevelTree:Nodes:Clear()
	SELF:oDS := DataSet{}
	self:oDTOperations := DataTable{"Operations"}
	oDTOperations:Columns:Add("Description")
	oDTOperations:Rows:Add("Disc/ing")
	oDTOperations:Rows:Add("Loading")
	oDTOperations:Rows:Add("Bunk/ing")
	oDTOperations:Rows:Add("Transit")
	oDTOperations:Rows:Add("Waiting")
	oSoftway:CreatePK(SELF:oDTOperations, "Description")
	SELF:oDS:Tables:Add(SELF:oDTOperations)
	SELF:gridControl1:DataSource := SELF:oDS:Tables["Operations"]
	SELF:gridControl1:Refresh()
RETURN



METHOD CreateGridOperations_Columns() AS VOID
//LOCAL oColumn AS GridColumn
LOCAL nVisible:=0, nAbsIndex:=0 AS INT

	oMainForm:CreateDXColumn("Description", "Description",FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
													nAbsIndex++, nVisible++, 100, SELF:gridView1)
	
																	
RETURN

METHOD CustomUnboundColumnData_Companies(e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs) AS VOID
	IF ! e:IsGetData
		RETURN
	ENDIF
	/*LOCAL oRow AS DataRow
	LOCAL cField AS STRING
	LOCAL oView AS GridView
	IF e:Column:FieldName == "uPortFromGMT_DIFF"
		
	ENDIF*/
RETURN

EXPORT METHOD CloseAndSendData(oRow AS DataRowView, oColumn AS GridColumn) AS VOID
	//LOCAL cField := oColumn:FieldName AS STRING
	SELF:cReturnName := oRow:Item["Description"]:ToString()
	//SELF:cReturnUID   := oRow:Item["Company_Uniqueid"]:ToString()
	SELF:DialogResult := DialogResult.OK
	SELF:Close()
RETURN

END CLASS
