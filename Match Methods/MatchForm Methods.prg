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
	//Variables to Return
	EXPORT cReturnName AS STRING
	EXPORT cReturnUID AS STRING
	PRIVATE oDTPackages AS DataTable
	PRIVATE oDS := DataSet{} AS DataSet
	//Variable set by parent
	EXPORT cType := "" AS STRING
	EXPORT cVessel_UID :="" AS STRING 
	//Variables to load from SQL 
	EXPORT cDepNextPortUID := "0" as STRING
	EXPORT cArrivalUID := "0" as STRING
	EXPORT cArrivalHFOUid := "0" as STRING
	EXPORT cArrivalLFOUid := "0" AS STRING
	EXPORT cArrivalMDOUid := "0" as STRING
	EXPORT cArrivalPort := "0" as STRING
	EXPORT cDepHFOUid := "0" as STRING
	EXPORT cDepLFOUid := "0" AS STRING
	EXPORT cDepMDOUid := "0" AS STRING
	EXPORT cDepartureUID := "0" AS STRING
	EXPORT cDeparturePort := "0" as STRING
	EXPORT cVoyageStartDate := "" AS STRING
	EXPORT cVoyageEndDate := "" AS STRING
	EXPORT cBunkDepHFOUid := "0" AS STRING
	EXPORT cBunkDepLFOUid := "0" AS STRING
	EXPORT cBunkDepMDOUid := "0" AS STRING


PRIVATE METHOD MatchFormOnLoad AS VOID
	SELF:CreateGridPackages_Columns()
	self:readGlobalSettings()
	SELF:oDS:Relations:Clear()
	//SELF:gridControl1:LevelTree:Nodes:Clear()
	SELF:oDS := DataSet{}
		
	LOCAL cStatement AS STRING
	LOCAL cExtraSQL := " " AS STRING
	IF SELF:cType == "A"
		cExtraSQL := " AND REPORT_UID = "+SELF:cArrivalUID+" AND Vessel_Uniqueid="+SELF:cVessel_UID+;
					 " AND FMDataPackages.DateTimeGMT >= '"+self:cVoyageStartDate+"' AND FMDataPackages.DateTimeGMT <= '"+self:cVoyageEndDate+"'"
		
		cStatement:=" SELECT FMDataPackages.DateTimeGMT,Data4.Data As PortOfArrival ,FMDataPackages.PACKAGE_UID"+;
					" ,Data1.Data as HFO, Data2.Data as LFO, Data3.Data as MGO"+;
					" FROM FMDataPackages  "+;
					" Left Outer Join FMData as Data4 ON FMDataPackages.PACKAGE_UID=Data4.PACKAGE_UID AND Data4.ITEM_UID="+SELF:cArrivalPort+;
					" Left Outer Join FMData as Data1 ON FMDataPackages.PACKAGE_UID=Data1.PACKAGE_UID AND Data1.ITEM_UID="+SELF:cArrivalHFOUid+;
					" Left Outer Join FMData as Data2 ON FMDataPackages.PACKAGE_UID=Data2.PACKAGE_UID AND Data2.ITEM_UID="+SELF:cArrivalLFOUid+;
					" Left Outer Join FMData as Data3 ON FMDataPackages.PACKAGE_UID=Data3.PACKAGE_UID AND Data3.ITEM_UID="+SELF:cArrivalMDOUid+;
					" WHERE FMDataPackages.Visible=1 "+ cExtraSQL+;
					" ORDER BY DateTimeGMT DESC"
		MemoWrit(cTempDocDir+"\selectForMatching.txt", cStatement)
		SELF:oDTPackages:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	ELSE
		cExtraSQL := " AND REPORT_UID = "+SELF:cDepartureUID+" AND Vessel_Uniqueid="+SELF:cVessel_UID+;
					 " AND FMDataPackages.DateTimeGMT >= '"+self:cVoyageStartDate+"' AND FMDataPackages.DateTimeGMT <= '"+self:cVoyageEndDate+"'"
		
		cStatement:=" SELECT FMDataPackages.DateTimeGMT, Data5.Data As PortOfDeparture , FMDataPackages.PACKAGE_UID, Data1.Data as NextPort"+;
					" ,Data2.Data as HFO, Data3.Data as LFO, Data4.Data as MGO, Data6.Data as BunkeredHFO, Data7.Data as BunkeredLFO, Data8.Data as BunkeredMDO"+;
					" FROM FMDataPackages "+;
					" Left Outer Join FMData as Data5 ON FMDataPackages.PACKAGE_UID=Data5.PACKAGE_UID AND Data5.ITEM_UID="+self:cDeparturePort+;
					" Left Outer Join FMData as Data1 ON FMDataPackages.PACKAGE_UID=Data1.PACKAGE_UID AND Data1.ITEM_UID="+self:cDepNextPortUID+;
					" Left Outer Join FMData as Data2 ON FMDataPackages.PACKAGE_UID=Data2.PACKAGE_UID AND Data2.ITEM_UID="+SELF:cDepHFOUid+;
					" Left Outer Join FMData as Data3 ON FMDataPackages.PACKAGE_UID=Data3.PACKAGE_UID AND Data3.ITEM_UID="+SELF:cDepLFOUid+;
					" Left Outer Join FMData as Data4 ON FMDataPackages.PACKAGE_UID=Data4.PACKAGE_UID AND Data4.ITEM_UID="+SELF:cDepMDOUid+;
					" Left Outer Join FMData as Data6 ON FMDataPackages.PACKAGE_UID=Data6.PACKAGE_UID AND Data6.ITEM_UID="+SELF:cBunkDepHFOUid+;
					" Left Outer Join FMData as Data7 ON FMDataPackages.PACKAGE_UID=Data7.PACKAGE_UID AND Data7.ITEM_UID="+SELF:cBunkDepLFOUid+;
					" Left Outer Join FMData as Data8 ON FMDataPackages.PACKAGE_UID=Data8.PACKAGE_UID AND Data8.ITEM_UID="+SELF:cBunkDepMDOUid+;
					" WHERE FMDataPackages.Visible=1 "+ cExtraSQL+;
					" ORDER BY DateTimeGMT DESC"
		MemoWrit(cTempDocDir+"\selectForMatching.txt", cStatement)
		SELF:oDTPackages:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	ENDIF
	
	/*SELF:oDTPackages:Columns:Add("HFO", typeof(FLOAT))
	SELF:oDTPackages:Columns:Add("LFO", typeof(FLOAT))
	SELF:oDTPackages:Columns:Add("MDO/MGO", typeof(FLOAT))

	Local cPackageUID := "" As STRING
	FOREACH oRowLocal AS DataRow IN SELF:oDTPackages:Rows
			cArrivalUID :=	oRow["Arrival_REPORT_UID"]:ToString()
			cDepartureUID :=	oRow["Departure_REPORT_UID"]:ToString()
			cData_UID := oRow["DepartureNextPort_ITEM_UID"]:ToString()
	NEXT*/	

	//MessageBox.Show(oDTPackages:Rows:Count:ToString(),"Found")
	SELF:oDTPackages:TableName:="Packages"
	oSoftway:CreatePK(SELF:oDTPackages, "PACKAGE_UID")
	SELF:oDS:Tables:Add(SELF:oDTPackages)
	SELF:gridControl1:DataSource := SELF:oDS:Tables["Packages"]
	SELF:gridControl1:Refresh()
RETURN

PRIVATE METHOD readGlobalSettings() AS VOID
	LOCAL cStatement AS STRING
	cStatement:="SELECT *"+;
				" FROM FMGlobalSettings"+oMainForm:cNoLockTerm+;
				" WHERE Vessel_UniqueID="+cVessel_UID+;
				" ORDER BY Vessel_UniqueID"
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	FOREACH oRow AS DataRow IN oDT:Rows
			self:cArrivalUID :=	oRow["Arrival_REPORT_UID"]:ToString()
			self:cDepartureUID :=	oRow["Departure_REPORT_UID"]:ToString()
			SELF:cDepNextPortUID := oRow["DepartureNextPort_ITEM_UID"]:ToString()
			SELF:cArrivalHFOUid := oRow["Arrival_HFOROB_Item_UID"]:ToString()
			SELF:cArrivalLFOUid := oRow["Arrival_LFOROB_Item_UID"]:ToString()
			SELF:cArrivalMDOUid := oRow["Arrival_MGOROB_Item_UID"]:ToString()
			SELF:cDepHFOUid := oRow["Departure_HFOROB_Item_UID"]:ToString()
			SELF:cDepLFOUid := oRow["Departure_LFOROB_Item_UID"]:ToString()
			SELF:cDepMDOUid := oRow["Departure_MGOROB_Item_UID"]:ToString()
			SELF:cArrivalPort := oRow["ArrivalPort_Item_UID"]:ToString()
			SELF:cDeparturePort := oRow["DeparturePort_Item_UID"]:ToString()
			SELF:cBunkDepHFOUid := oRow["DepartureBunkeredHFO_Item_UID"]:ToString()
			IF cBunkDepHFOUid==""
				cBunkDepHFOUid := "0"
			ENDIF
			SELF:cBunkDepLFOUid := oRow["DepartureBunkeredLFO_Item_UID"]:ToString()
			IF cBunkDepLFOUid==""
				cBunkDepLFOUid := "0"
			ENDIF
			SELF:cBunkDepMDOUid := oRow["DepartureBunkeredMDO_Item_UID"]:ToString()
			IF cBunkDepMDOUid==""
				cBunkDepMDOUid := "0"
			endif
	NEXT
RETURN


EXPORT METHOD setTypeAndVessel(setter AS STRING, cVesselUID AS STRING, cVoyageStartDateLocal AS STRING, cVoyageEndDateLocal AS STRING) AS VOID
	SELF:cType :=	setter
	SELF:cVessel_UID := cVesselUID
	SELF:cVoyageStartDate := Datetime.Parse(cVoyageStartDateLocal):ToString("yyyyMMdd 00:00:01")
	SELF:cVoyageEndDate := Datetime.Parse(cVoyageEndDateLocal):ToString("yyyyMMdd 23:59:59")
RETURN


METHOD CreateGridPackages_Columns() AS VOID
	LOCAL oColumn AS GridColumn
	LOCAL nVisible:=0, nAbsIndex:=0 AS INT

	IF SELF:cType == "A" //Arrival 
	
		oColumn:= oMainForm:CreateDXColumn("DateTimeGMT", "DateTimeGMT",FALSE, DevExpress.Data.UnboundColumnType.DateTime, ;
													nAbsIndex++, nVisible++, 100, SELF:gridView1)

		oColumn:=oMainForm:CreateDXColumn("PortOfArrival", "PortOfArrival",		FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
																nAbsIndex++, nVisible++, 120, SELF:gridView1)	
		
		oColumn:=oMainForm:CreateDXColumn("HFO", "HFO",		FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																nAbsIndex++, nVisible++, 100, SELF:gridView1)	
		oColumn:=oMainForm:CreateDXColumn("LFO", "LFO",		FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																nAbsIndex++, nVisible++, 100, SELF:gridView1)	
		oColumn:=oMainForm:CreateDXColumn("MDO/MGO", "MGO",		FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																nAbsIndex++, nVisible++, 100, SELF:gridView1)	

		oColumn:=oMainForm:CreateDXColumn("PACKAGE_UID", "PACKAGE_UID",	FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																	nAbsIndex++, -1, -1, SELF:gridView1)
		oColumn:Visible:=FALSE
	ELSE			//Departure
	
		oColumn:= oMainForm:CreateDXColumn("DateTimeGMT", "DateTimeGMT",FALSE, DevExpress.Data.UnboundColumnType.DateTime, ;
													nAbsIndex++, nVisible++, 100, SELF:gridView1)

		oColumn:=oMainForm:CreateDXColumn("PortOfDeparture", "PortOfDeparture",		FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
																nAbsIndex++, nVisible++, 120, SELF:gridView1)	

		oColumn:=oMainForm:CreateDXColumn("Next Port", "NextPort",		FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
																nAbsIndex++, nVisible++, 120, SELF:gridView1)	

		oColumn:=oMainForm:CreateDXColumn("HFO", "HFO",		FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																nAbsIndex++, nVisible++, 100, SELF:gridView1)	

		oColumn:=oMainForm:CreateDXColumn("LFO", "LFO",		FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																nAbsIndex++, nVisible++, 100, SELF:gridView1)	

		oColumn:=oMainForm:CreateDXColumn("MDO/MGO", "MGO",		FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																nAbsIndex++, nVisible++, 100, SELF:gridView1)	


		oColumn:=oMainForm:CreateDXColumn("BunkeredHFO", "BunkeredHFO",		FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																nAbsIndex++, nVisible++, 80, SELF:gridView1)	

		oColumn:=oMainForm:CreateDXColumn("BunkeredLFO", "BunkeredLFO",		FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																nAbsIndex++, nVisible++, 80, SELF:gridView1)	

		oColumn:=oMainForm:CreateDXColumn("BunkeredMDO", "BunkeredMDO",		FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																nAbsIndex++, nVisible++, 80, SELF:gridView1)	



		oColumn:=oMainForm:CreateDXColumn("PACKAGE_UID", "PACKAGE_UID",	FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																	nAbsIndex++, -1, -1, SELF:gridView1)
		oColumn:Visible:=FALSE
	ENDIF																	
RETURN

EXPORT METHOD gridControl1_DoubleClick_Method( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		LOCAL oPoint := SELF:gridView1:GridControl:PointToClient(Control.MousePosition) AS Point
		LOCAL info := SELF:gridView1:CalcHitInfo(oPoint) AS DevExpress.XtraGrid.Views.Grid.ViewInfo.GridHitInfo
		
		IF info:InRow .OR. info:InRowCell
			/*IF SELF:gridView1:IsGroupRow(info:RowHandle)
				RETURN
			ENDIF*/
			// Get GridRow data into a DataRowView object
			LOCAL oRow AS DataRowView
			oRow:=(DataRowView)SELF:gridView1:GetRow(info:RowHandle)
			IF info:Column <> NULL
				// Set focused Row/Column (for DoubleClick event)
				//SELF:GridViewVoyages:FocusedRowHandle := info:RowHandle
				//SELF:GridViewVoyages:FocusedColumn := info:Column
				SELF:CloseAndSendData(oRow, info:Column)
			ENDIF
		ENDIF
RETURN

EXPORT METHOD CloseAndSendData(oRow AS DataRowView, oColumn AS GridColumn) AS VOID
	//
	//local iIndexes := SELF:gridView1:GetSelectedRows() AS INT[] 		
	LOCAL cToReturn := "" AS STRING
	//LOCAL oRow AS DataRowView
	//LOCAL i as int
	//	FOR i := 1 UPTO iIndexes:Length STEP 1
				//MessageBox.Show(iIndexes[i]:ToString())
	//			oRow := (DataRowView)SELF:gridView1:GetRow(iIndexes[i])
	//			IF cToReturn == ""
	cToReturn := oRow:Item["PACKAGE_UID"]:ToString():Trim()
	
	IF SELF:cType == "A" //Arrival 
		cArrivalHFOUid := oRow:Item["HFO"]:ToString():Trim()
		cArrivalLFOUid := oRow:Item["LFO"]:ToString():Trim()
		cArrivalMDOUid := oRow:Item["MGO"]:ToString():Trim()
	ELSE			//Departure
		cDepHFOUid := oRow:Item["HFO"]:ToString():Trim()
		cDepLFOUid := oRow:Item["LFO"]:ToString():Trim()
		cDepMDOUid := oRow:Item["MGO"]:ToString():Trim()
		cBunkDepHFOUid := oRow:Item["BunkeredHFO"]:ToString():Trim()
		cBunkDepLFOUid := oRow:Item["BunkeredLFO"]:ToString():Trim()
		cBunkDepMDOUid := oRow:Item["BunkeredMDO"]:ToString():Trim()
	ENDIF	

	SELF:cReturnUID   := cToReturn
	SELF:DialogResult := DialogResult.OK
	SELF:Close()		
	//
	//SELF:cReturnName := oRow:Item["Full_Style"]:ToString()
	//SELF:cReturnUID   := oRow:Item["Company_Uniqueid"]:ToString()
	//SELF:DialogResult := DialogResult.OK
	//SELF:Close()
RETURN

END CLASS
