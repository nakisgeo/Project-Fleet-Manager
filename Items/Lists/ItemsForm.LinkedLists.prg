// ItemsForm.prg
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



PARTIAL CLASS SQLTablesCreator
	

METHOD CreateTables_DMFListsTables(oGFH AS GenericFactoryHelper, oConn AS DBConnection) AS LOGIC
	Local cStatement as string

	if ! oSoftway:TableExists(oGFH, oConn, "DMFLists")
		cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"DMFLists ("+;
					"List_UID			"+oSoftway:cIdentity+","+;
					"Description		"+oSoftway:FieldVarChar+"(128) NULL ,"+;
					"PRIMARY KEY (List_UID)"+;
					") "+oSoftway:cTableDefaults
		oSoftway:AdoCommand(oGFH, oConn, cStatement)
	endif
	if ! oSoftway:TableExists(oGFH, oConn, "DMFListItems")
		cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"DMFListItems ("+;
					"FK_List_UID		int NOT NULL,"+;
					"List_Item_UID		"+oSoftway:cIdentity+","+;
					"Description		"+oSoftway:FieldVarChar+"(512) NULL ,"+;
					"PRIMARY KEY (List_Item_UID)"+;
					") "+oSoftway:cTableDefaults
		oSoftway:AdoCommand(oGFH, oConn, cStatement)
	ENDIF

RETURN TRUE

END CLASS

PARTIAL CLASS ItemsForm INHERIT DevExpress.XtraEditors.XtraForm
	
PRIVATE METHOD bbiLinkedLists_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
	
	LOCAL oListsForm:=ListsForm{} AS ListsForm
	oListsForm:ShowDialog(SELF)

RETURN

PUBLIC METHOD checkForLinkedList(cToTest AS STRING) AS LOGIC
	local cStatement:=" SELECT Description FROM DMFLists"+;
					  " WHERE  Description='"+oSoftway:ConvertWildcards(cToTest, False)+"'" as String
	local cDuplicate:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Description") as String
	IF cDuplicate <> "" .and. cDuplicate:Trim():Length>0
			RETURN TRUE
	ENDIF
RETURN false

END CLASS