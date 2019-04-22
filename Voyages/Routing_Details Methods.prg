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
// Routing_Details_Methods.prg

PARTIAL CLASS RoutingDetails INHERIT System.Windows.Forms.UserControl

PUBLIC cType,cUID := "0" AS STRING
PRIVATE oDTCargoes AS DataTable
PRIVATE oDTExpenses AS DataTable
PRIVATE oDTCompanies AS DataTable
PRIVATE oDS := DataSet{} AS DataSet
PRIVATE oMyForm as VoyagesForm

PUBLIC METHOD formGrid(type AS STRING,uid AS STRING,data AS STRING,oForm AS VoyagesForm) AS VOID
		
	cType := type
	cUID := uid
	oMyForm := oForm

	IF cType == "V"		 // Voyage
		fillGrids()
		SELF:barButtonItem1:Enabled := FALSE
		SELF:barButtonItem2:Enabled := false
	ELSEIF cType == "R"	// Routing
		fillGrids()
		SELF:barButtonItem1:Enabled := TRUE
		SELF:barButtonItem2:Enabled := TRUE
	ENDIF
		
RETURN
		
		
PUBLIC METHOD createGrids() AS VOID
	// Grid Cargoes
	LOCAL oColumn AS GridColumn
	LOCAL nVisible:=0, nAbsIndex:=0 AS INT
	oMainForm:CreateDXColumn("Action", "Cargo_Action",FALSE, DevExpress.Data.UnboundColumnType.STRING,nAbsIndex++, nVisible++, 5, SELF:gridView1)
	oMainForm:CreateDXColumn("Name", "Cargo_Name", FALSE, DevExpress.Data.UnboundColumnType.STRING,nAbsIndex++, nVisible++, 100, SELF:gridView1)	
	oMainForm:CreateDXColumn("Quantity", "Cargo_Quantity",FALSE, DevExpress.Data.UnboundColumnType.Decimal,nAbsIndex++, nVisible++, 50, SELF:gridView1)
	oMainForm:CreateDXColumn("Unit", "Quantity_Unit",FALSE, DevExpress.Data.UnboundColumnType.STRING,nAbsIndex++, nVisible++, 20, SELF:gridView1)
	oMainForm:CreateDXColumn("Volume", "Cargo_Volume",FALSE, DevExpress.Data.UnboundColumnType.Decimal,nAbsIndex++, nVisible++, 50, SELF:gridView1)
	oMainForm:CreateDXColumn("Unit", "Volume_Unit",FALSE, DevExpress.Data.UnboundColumnType.STRING,nAbsIndex++, nVisible++, 20, SELF:gridView1)
	oMainForm:CreateDXColumn("Notes", "Link_Notes",FALSE, DevExpress.Data.UnboundColumnType.STRING,nAbsIndex++, nVisible++, 100, SELF:gridView1)																							
	oColumn:=oMainForm:CreateDXColumn("Link_Uniqueid", "Link_Uniqueid",	FALSE, DevExpress.Data.UnboundColumnType.Integer,nAbsIndex++, -1, -1, SELF:gridView1)
	oColumn:Visible:=FALSE
	oColumn:=oMainForm:CreateDXColumn("Cargo_Uniqueid", "Cargo_Uniqueid",	FALSE, DevExpress.Data.UnboundColumnType.Integer,nAbsIndex++, -1, -1, SELF:gridView1)
	oColumn:Visible:=FALSE
	oColumn:=oMainForm:CreateDXColumn("ROUTING_UID", "ROUTING_UID",	FALSE, DevExpress.Data.UnboundColumnType.Integer,nAbsIndex++, -1, -1, SELF:gridView1)
	oColumn:Visible:=FALSE
	
	// Grid Expenses
/*	nVisible:=0
	nAbsIndex:=0 

	oMainForm:CreateDXColumn("Full_Style", "Full_Style",FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
													nAbsIndex++, nVisible++, 100, SELF:gridView1)
	oMainForm:CreateDXColumn("Street", "Street",FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
													nAbsIndex++, nVisible++, 80, SELF:gridView1)
	oMainForm:CreateDXColumn("City", "City",FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
													nAbsIndex++, nVisible++, 50, SELF:gridView1)
	oMainForm:CreateDXColumn("Country", "Country",FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
													nAbsIndex++, nVisible++, 50, SELF:gridView1)
	oMainForm:CreateDXColumn("eMail", "eMail",FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
													nAbsIndex++, nVisible++, 80, SELF:gridView1)
																									
	oColumn:=oMainForm:CreateDXColumn("Company_Uniqueid", "Company_Uniqueid",	FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																	nAbsIndex++, -1, -1, SELF:gridView1)

	oColumn:Visible:=FALSE*/

RETURN


EXPORT METHOD fillGrids() AS VOID

	SELF:oDS:Relations:Clear()
	//SELF:gridControl1:LevelTree:Nodes:Clear()
	SELF:oDS := DataSet{}
		
	LOCAL cStatement AS STRING
	
	LOCAL cExtraSQL := " " AS STRING
	IF self:cType == "0"
		cExtraSQL := " "
	ELSE
		cExtraSQL := " ROUTING_UID = "+cUID+" "
	ENDIF
	
	cStatement:="SELECT Link_Uniqueid, FMCargoRoutingLink.Cargo_Uniqueid, ROUTING_UID, Cargo_Quantity, Quantity_Unit, Cargo_Volume, Volume_Unit, Cargo_Action, Link_Notes, Cargo_Name"+;
				" FROM FMCargoRoutingLink, Cargoes"+oMainForm:cNoLockTerm+;
				" WHERE "+ cExtraSQL+;
				" AND  FMCargoRoutingLink.Cargo_Uniqueid = Cargoes.Cargo_Uniqueid "+;
				" ORDER BY Link_Uniqueid"
	//MessageBox.Show(cStatement)
	SELF:oDTCargoes:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	//MessageBox.Show(oDTCompanies:Rows:Count:ToString(),"Found")
	SELF:oDTCargoes:TableName:="Cargoes"
	oSoftway:CreatePK(SELF:oDTCargoes, "Link_Uniqueid")
	SELF:oDS:Tables:Add(SELF:oDTCargoes)
	SELF:gridControl1:DataSource := SELF:oDS:Tables["Cargoes"]
	SELF:gridControl1:Refresh()
		
RETURN

EXPORT METHOD addCargo() AS VOID
		//MessageBox.Show(cUID)
	IF cUID != "0"
		LOCAL cCompUID := "0" as String
		LOCAL oSelect_Cargo := addCargo{} AS addCargo
		LOCAL oResult := oSelect_Cargo:ShowDialog() AS DialogResult
		//MessageBox.Show(oResult:ToString())
		IF oResult == DialogResult.OK
			LOCAL cName := oSelect_Cargo:cReturnName AS STRING 
			cCompUID := oSelect_Cargo:cReturnUID
			LOCAL cStatement AS STRING
			//MessageBox.Show(cName,cCompUID)
			cStatement:=" UPDATE EconRoutings SET"+;
						" CargoDescription ='"+oSoftway:ConvertWildcards(cName, FALSE)+"'"+;
						" WHERE ROUTING_UID = "+cUID
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ENDIF
		oMyForm:Voyages_Refresh()
		IF cCompUID != "0"
			LOCAL cStatement AS STRING
			cStatement:=" Insert Into FMCargoRoutingLink "+;
						" ( Cargo_Uniqueid, ROUTING_UID ) VALUES "+;
						" ("+cCompUID+","+cUID+")"
			IF oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				SELF:gridControl1:Refresh()
			ENDIF
		ENDIF
	ENDIF
RETURN

END CLASS