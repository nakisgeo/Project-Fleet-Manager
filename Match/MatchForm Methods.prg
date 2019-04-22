// MatchForm_Methods.prg
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#Using System.IO
#Using System.Collections
#USING System.Threading
#USING System.Collections.Generic

#Using DevExpress.XtraEditors
#using DevExpress.LookAndFeel
#Using DevExpress.XtraGrid.Views.Grid
#Using DevExpress.XtraGrid.Views.Base
#using DevExpress.XtraPrinting
#Using DevExpress.XtraPrintingLinks
#using DevExpress.XtraGrid.Columns
#using DevExpress.XtraTreeList
#using DevExpress.XtraTreeList.Nodes

PARTIAL CLASS MatchForm INHERIT System.Windows.Forms.Form
	EXPORT cReturnName AS STRING
	EXPORT cReturnUID AS STRING
	PRIVATE oDTPackages AS DataTable
	PRIVATE oDS := DataSet{} AS DataSet
	EXPORT cType := "" AS STRING
	EXPORT cData_UID := "0" as STRING
	EXPORT cArrivalUID := "0" as STRING
	EXPORT cDepartureUID := "0" as STRING

PRIVATE METHOD Select_CompanyForm_Onload AS VOID
	SELF:CreateGridCompanies_Columns()
	SELF:oDS:Relations:Clear()
	//SELF:gridControl1:LevelTree:Nodes:Clear()
	SELF:oDS := DataSet{}
		
	LOCAL cStatement AS STRING
	
	LOCAL cExtraSQL := " " AS STRING
	IF SELF:cType == "A"
		cExtraSQL := " AND REPORT_UID = "+SELF:cArrivalUID+" "
	ELSE
		cExtraSQL := " AND REPORT_UID = "+self:cDepartureUID+" "
	ENDIF
	
	cStatement:="SELECT FMDataPackages.DateTimeGMT,FMDataPackages.PACKAGE_UID, FMData.Data"+;
				" FROM FMDataPackages, FMData  "+;
				" WHERE Matched=0 AND FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID AND FMData.ITEM_UID="+self:cData_UID+" "+ cExtraSQL+;
				" ORDER BY DateTimeGMT"
	SELF:oDTPackages:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	//MessageBox.Show(oDTPackages:Rows:Count:ToString(),"Found")
	SELF:oDTPackages:TableName:="Packages"
	oSoftway:CreatePK(SELF:oDTPackages, "PACKAGE_UID")
	SELF:oDS:Tables:Add(SELF:oDTPackages)
	SELF:gridControl1:DataSource := SELF:oDS:Tables["Packages"]
	SELF:gridControl1:Refresh()
RETURN

PRIVATE METHOD readGlobalSettings() AS VOID
		cStatement:="SELECT FMDataPackages.DateTimeGMT,FMDataPackages.PACKAGE_UID, FMData.Data"+;
				" FROM FMDataPackages, FMData  "+;
				" WHERE Matched=0 AND FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID AND FMData.ITEM_UID="++" "+ cExtraSQL+;
				" ORDER BY DateTimeGMT"
RETURN

EXPORT METHOD setType(setter AS STRING) AS VOID
	SELF:cType :=	setter
RETURN

METHOD CreateGridCompanies_Columns() AS VOID
LOCAL oColumn AS GridColumn
LOCAL nVisible:=0, nAbsIndex:=0 AS INT

	oColumn:= oMainForm:CreateDXColumn("DateTimeGMT", "DateTimeGMT",FALSE, DevExpress.Data.UnboundColumnType.DateTime, ;
													nAbsIndex++, nVisible++, 100, SELF:gridView1)
	oColumn:ColumnEdit := SELF:CreateRepositoryItemDateTime()
																									
	oColumn:=oMainForm:CreateDXColumn("PACKAGE_UID", "PACKAGE_UID",	FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																	nAbsIndex++, -1, -1, SELF:gridView1)
	oColumn:Visible:=FALSE
																	
RETURN

END CLASS
