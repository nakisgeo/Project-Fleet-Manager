// AddCargo_Methods.prg
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

PARTIAL CLASS AddCargo INHERIT System.Windows.Forms.Form
	EXPORT cReturnName AS STRING
	Export cReturnUID as String
	PRIVATE oDTCompanies AS DataTable
	PRIVATE oDS := DataSet{} AS DataSet
	EXPORT  cCompanyBookUID := "0" AS STRING
	EXPORT cMyRoutingUID as String


EXPORT METHOD setCompanyBookUID(setter AS STRING) AS VOID
	SELF:cCompanyBookUID :=	setter
RETURN

PRIVATE METHOD Select_CompanyForm_Onload AS VOID
	SELF:CreateGridCompanies_Columns()
	SELF:oDS:Relations:Clear()
	//SELF:gridControl1:LevelTree:Nodes:Clear()
	SELF:oDS := DataSet{}
		
	LOCAL cStatement AS STRING
	
	/*LOCAL cExtraSQL := " " AS STRING
	IF cCompanyBookUID == "0"
		cExtraSQL := " "
	ELSE
		cExtraSQL := " AND TYPE_UNIQUEID= "+cCompanyBookUID+" "
	ENDIF*/
	
	cStatement:="SELECT Cargo_Uniqueid, Cargo_Name, Cargo_Type, Cargo_AltName, Cargo_Memo"+;
				" FROM Cargoes"+oMainForm:cNoLockTerm+; //" WHERE Visible='Y' "+ cExtraSQL+;
				" ORDER BY Cargo_Type, Cargo_Name"
	SELF:oDTCompanies:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	//MessageBox.Show(oDTCompanies:Rows:Count:ToString(),"Found")
	SELF:oDTCompanies:TableName:="Cargoes"
	oSoftway:CreatePK(SELF:oDTCompanies, "Cargo_Uniqueid")
	SELF:oDS:Tables:Add(SELF:oDTCompanies)
	SELF:gridControl1:DataSource := SELF:oDS:Tables["Cargoes"]
	SELF:gridControl1:Refresh()
RETURN



METHOD CreateGridCompanies_Columns() AS VOID
LOCAL oColumn AS GridColumn
LOCAL nVisible:=0, nAbsIndex:=0 AS INT

	oMainForm:CreateDXColumn("Name", "Cargo_Name",FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
													nAbsIndex++, nVisible++, 100, SELF:gridView1)
	oMainForm:CreateDXColumn("Type", "Cargo_Type",FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
													nAbsIndex++, nVisible++, 10, SELF:gridView1)
	oMainForm:CreateDXColumn("Alternative Name", "Cargo_AltName",FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
													nAbsIndex++, nVisible++, 80, SELF:gridView1)
	oMainForm:CreateDXColumn("Notes", "Cargo_Memo",FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
													nAbsIndex++, nVisible++, 150, SELF:gridView1)
																									
	oColumn:=oMainForm:CreateDXColumn("Cargo_Uniqueid", "Cargo_Uniqueid",	FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																	nAbsIndex++, -1, -1, SELF:gridView1)

	oColumn:Visible:=FALSE
																	
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
	SELF:cReturnName := oRow:Item["Cargo_Name"]:ToString()
	SELF:cReturnUID   := oRow:Item["Cargo_Uniqueid"]:ToString()
	SELF:DialogResult := DialogResult.OK
	SELF:Close()
RETURN

EXPORT METHOD CloseAndSendData(cString AS String) AS VOID
	SELF:cReturnName := cString 
	SELF:cReturnUID   := "0"
	SELF:DialogResult := DialogResult.OK
	SELF:Close()
RETURN


EXPORT METHOD CloseAndSendData(iIndexes AS INT[]) AS VOID		
		LOCAL cToReturn := "" AS STRING
		LOCAL oRow AS DataRowView
		LOCAL i as int
		FOR i := 1 UPTO iIndexes:Length STEP 1
				//MessageBox.Show(iIndexes[i]:ToString())
				oRow := (DataRowView)SELF:gridView1:GetRow(iIndexes[i])
				IF cToReturn == ""
					cToReturn := oRow:Item["Cargo_Name"]:ToString():Trim()
				ELSE
					cToReturn += " // " + oRow:Item["Cargo_Name"]:ToString():trim()
				ENDIF
		NEXT	
		SELF:cReturnName := cToReturn
		SELF:cReturnUID   := "0"
		SELF:DialogResult := DialogResult.OK
		SELF:Close()		
RETURN





END CLASS