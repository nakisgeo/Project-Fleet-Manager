// VoyagesForm.prg
#Using System.Collections
#Using DevExpress.XtraGrid.Views.Grid
#Using DevExpress.XtraGrid.Columns
#Using DevExpress.Utils
#Using DevExpress.XtraEditors.Repository
#using DevExpress.XtraPrinting
#Using DevExpress.XtraPrintingLinks

PARTIAL CLASS VoyagesForm INHERIT System.Windows.Forms.Form


METHOD CreateGridRoutings_Columns() AS VOID
LOCAL oColumn AS GridColumn
LOCAL nVisible:=0, nAbsIndex:=0 AS INT

	

	oColumn:=oMainForm:CreateDXColumn("Port", "PortFrom",	FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
																nAbsIndex++, nVisible++, 150, SELF:GridViewRoutings)
	oColumn:ColumnEdit := SELF:CreateRepositoryItemTextEdit_Port()

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	oColumn:=oMainForm:CreateDXColumn("FromEU", "FromEU",				False, DevExpress.Data.UnboundColumnType.Boolean, ;
																		nAbsIndex++, nVisible++, 50, Self:GridViewRoutings)
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	oColumn:=oMainForm:CreateDXColumn("+/-GMT", "uPortFromGMT_DIFF",FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																nAbsIndex++, nVisible++, 55, SELF:GridViewRoutings)
	// ToolTip
	LOCAL cPeriodGMT AS STRING
	oColumn:ToolTip := IIF(oSoftway:IsSummerTimeGMT(cPeriodGMT), "", "")+"Difference from GMT in Hours ('From Port')"+CRLF+cPeriodGMT


	
	oMainForm:CreateDXColumn("Operation", "Operation",			FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
																	nAbsIndex++, nVisible++, 60, SELF:GridViewRoutings)
	
	oColumn:=oMainForm:CreateDXColumn("Condition", "uCondition",FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
																nAbsIndex++, nVisible++, 65, SELF:GridViewRoutings)
	// Set a ComboBoxEdit control to the uIO column
	LOCAL oRepositoryItemComboBox_Condition := RepositoryItemComboBox{} AS RepositoryItemComboBox
	oRepositoryItemComboBox_Condition:Items:AddRange(<System.OBJECT>{ "Ballast", "Laden" , /*"Loading", "Discharging",*/ "Idle"})
    oRepositoryItemComboBox_Condition:Properties:TextEditStyle := DevExpress.XtraEditors.Controls.TextEditStyles.DisableTextEditor
	//Add a repository item to the repository items of grid control
	//Self:GridAnticipated:RepositoryItems:Add(oRepositoryItemComboBox)
	//Now you can define the repository item as an inplace editor of columns
	oColumn:ColumnEdit := oRepositoryItemComboBox_Condition

	oColumn:=oMainForm:CreateDXColumn("To Port", "PortTo",		FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
																nAbsIndex++, nVisible++, 150, SELF:GridViewRoutings)
	oColumn:ColumnEdit := SELF:CreateRepositoryItemTextEdit_Port()

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	oColumn:=oMainForm:CreateDXColumn("ToEU", "ToEU",				False, DevExpress.Data.UnboundColumnType.Boolean, ;
																		nAbsIndex++, nVisible++, 50, Self:GridViewRoutings)
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	//oMainForm:CreateDXColumn("Agent", "Agent",			FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
	//																nAbsIndex++, nVisible++, 150, SELF:GridViewRoutings)

	//oMainForm:CreateDXColumn("D/A", "DA",			FALSE, DevExpress.Data.UnboundColumnType.String, ;
	//																nAbsIndex++, nVisible++, 50, SELF:GridViewRoutings)

	oMainForm:CreateDXColumn("Distance", "Distance",				FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																	nAbsIndex++, nVisible++, 65, SELF:GridViewRoutings)

	//oMainForm:CreateDXColumn("Deviation", "Deviation",				FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
	//																nAbsIndex++, nVisible++, 65, SELF:GridViewRoutings)

	oColumn:=oMainForm:CreateDXColumn("Commenced", "Commenced",		FALSE, DevExpress.Data.UnboundColumnType.DateTime, ;
																	nAbsIndex++, nVisible++, 100, SELF:GridViewRoutings)
	oColumn:ColumnEdit := SELF:CreateRepositoryItemDateTime()
	oColumn:Visible:=FALSE

	oColumn:=oMainForm:CreateDXColumn("Commenced GMT", "CommencedGMT",	FALSE, DevExpress.Data.UnboundColumnType.DateTime, ;
																	nAbsIndex++, nVisible++, 100, SELF:GridViewRoutings)
	oColumn:ColumnEdit := SELF:CreateRepositoryItemDateTime()
	//oColumn:Visible:=FALSE

	oColumn:=oMainForm:CreateDXColumn("Completed", "Completed",		FALSE, DevExpress.Data.UnboundColumnType.DateTime, ;
																		nAbsIndex++, nVisible++, 100, SELF:GridViewRoutings)
	oColumn:ColumnEdit := SELF:CreateRepositoryItemDateTime()
	oColumn:Visible:=FALSE
	oColumn:=oMainForm:CreateDXColumn("Completed GMT", "CompletedGMT",	FALSE, DevExpress.Data.UnboundColumnType.DateTime, ;
																	nAbsIndex++, nVisible++, 100, SELF:GridViewRoutings)
	oColumn:ColumnEdit := SELF:CreateRepositoryItemDateTime()
	//oColumn:Visible:=FALSE

	oColumn:=oMainForm:CreateDXColumn("Arrival (GMT)", "ArrivalGMT",		FALSE, DevExpress.Data.UnboundColumnType.DateTime, ;
																	nAbsIndex++, nVisible++, 100, SELF:GridViewRoutings)
	oColumn:ColumnEdit := SELF:CreateRepositoryItemDateTime()
	oColumn:Visible:=FALSE

	oColumn:=oMainForm:CreateDXColumn("Departure (GMT)", "DepartureGMT",	FALSE, DevExpress.Data.UnboundColumnType.DateTime, ;
																	nAbsIndex++, nVisible++, 100, SELF:GridViewRoutings)
	oColumn:ColumnEdit := SELF:CreateRepositoryItemDateTime()
	oColumn:Visible:=FALSE
	
	oColumn:=oMainForm:CreateDXColumn("+/-GMT", "uPortToGMT_DIFF",	FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																nAbsIndex++, nVisible++, 55, SELF:GridViewRoutings)
	// ToolTip
	oColumn:ToolTip := "Difference from GMT in Hours ('To Port')"+CRLF+cPeriodGMT

	//oMainForm:CreateDXColumn("WType", "WType",					FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
	//																nAbsIndex++, nVisible++, 60, SELF:GridViewRoutings)

	//oMainForm:CreateDXColumn("WHours", "WHours",					FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
	//																nAbsIndex++, nVisible++, 60, SELF:GridViewRoutings)

/*	oMainForm:CreateDXColumn("RoutingType", "uRoutingType",			FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
																	nAbsIndex++, nVisible++, 75, SELF:GridViewRoutings)
	// Set a ComboBoxEdit control to the uIO column
	LOCAL oRepositoryItemComboBox_RoutingType := RepositoryItemComboBox{} AS RepositoryItemComboBox
	oRepositoryItemComboBox_RoutingType:Items:AddRange(<System.OBJECT>{ "Sailing", "Arrival" })
    oRepositoryItemComboBox_RoutingType:Properties:TextEditStyle := DevExpress.XtraEditors.Controls.TextEditStyles.DisableTextEditor
	//Add a repository item to the repository items of grid control
	//Self:GridAnticipated:RepositoryItems:Add(oRepositoryItemComboBox)
	//Now you can define the repository item as an inplace editor of columns
	oColumn:ColumnEdit := oRepositoryItemComboBox_RoutingType*/
	oColumn:=oMainForm:CreateDXColumn("Cargo", "CargoDescription",	FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
																nAbsIndex++, nVisible++, 100, SELF:GridViewRoutings)

	oColumn:=oMainForm:CreateDXColumn("CargoTons", "CargoTons",		FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																	nAbsIndex++, nVisible++, 65, SELF:GridViewRoutings)

	/*oMainForm:CreateDXColumn("TC Equivalent (USD)", "TCEquivalentUSD",	FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																	nAbsIndex++, -1, -1, SELF:GridViewRoutings)

	oColumn:=oMainForm:CreateDXColumn("Draft FWD", "DraftFWD_Dec",	FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																	nAbsIndex++, -1, -1, SELF:GridViewRoutings)

	oColumn:=oMainForm:CreateDXColumn("Draft AFT", "DraftAFT_Dec",	FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																	nAbsIndex++, -1, -1, SELF:GridViewRoutings)

	oColumn:=oMainForm:CreateDXColumn("Manual Sailing FO ROB (kg)", "RoutingROB_FO",FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																	nAbsIndex++, -1, -1, SELF:GridViewRoutings)
	//oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Far
	//oColumn:DisplayFormat:FormatType := DevExpress.Utils.FormatType.Numeric
	oColumn:DisplayFormat:FormatString := "N0"

	oColumn:=oMainForm:CreateDXColumn("Manual Arrival FO ROB (kg)", "ManualROB_FO",FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																	nAbsIndex++, -1, -1, SELF:GridViewRoutings)
	//oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Far
	//oColumn:DisplayFormat:FormatType := DevExpress.Utils.FormatType.Numeric
	oColumn:DisplayFormat:FormatString := "N0"
	// ToolTip
	oColumn:ToolTip := "Manual Arrival FO ROB: Vessel reported FO ROB"

	oColumn:=oMainForm:CreateDXColumn("Calculated Arrival FO ROB (kg)", "ArrivalROB_FO",FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																	nAbsIndex++, nVisible++, 120, SELF:GridViewRoutings)
	//oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Far
	//oColumn:DisplayFormat:FormatType := DevExpress.Utils.FormatType.Numeric
	oColumn:DisplayFormat:FormatString := "N0"
	// ToolTip
	oColumn:ToolTip := "Calculated Arrival FO ROB: To be calculated on Routing closing using the 'Calculate Arrival FO ROB'"

	oColumn:=oMainForm:CreateDXColumn("Diff. FO ROB (kg)", "DiffROB_FO",FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																	nAbsIndex++, nVisible++, 120, SELF:GridViewRoutings)
	//oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Far
	//oColumn:DisplayFormat:FormatType := DevExpress.Utils.FormatType.Numeric
	oColumn:DisplayFormat:FormatString := "N0"
	// ToolTip
	oColumn:ToolTip := "Manual Arrival FO ROB - Calculated Arrival FO ROB"
	// Grid Footer:
	oColumn:SummaryItem:SummaryType := DevExpress.Data.SummaryItemType.Sum
//	oColumn:SummaryItem:SummaryType := DevExpress.Data.SummaryItemType.Custom
	oColumn:SummaryItem:DisplayFormat := "{0:N0}"
//	oColumn:SummaryItem:Tag := 2*/

	//oColumn:=oMainForm:CreateDXColumn("Price FO per ton (USD)", "FOPriceUSD",FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
	//																nAbsIndex++, -1, -1, SELF:GridViewRoutings)


	oColumn:=oMainForm:CreateDXColumn("MatchedWithArrival", "MatchedWithArrival",FALSE, DevExpress.Data.UnboundColumnType.Boolean, ;
																	nAbsIndex++, nVisible++, 30, SELF:GridViewRoutings)
	oColumn:=oMainForm:CreateDXColumn("HFO Arrival", "ArrHFO",FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																	nAbsIndex++, nVisible++, 50, SELF:GridViewRoutings)
	oColumn:DisplayFormat:FormatType := DevExpress.Utils.FormatType.Numeric
	oColumn:DisplayFormat:FormatString := "N2"
	oColumn:=oMainForm:CreateDXColumn("LFO Arrival", "ArrLFO",FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																	nAbsIndex++, nVisible++, 50, SELF:GridViewRoutings)
	oColumn:DisplayFormat:FormatType := DevExpress.Utils.FormatType.Numeric
	oColumn:DisplayFormat:FormatString := "N2"
	oColumn:=oMainForm:CreateDXColumn("MGO/MDO Arrival", "ArrMGO",FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																	nAbsIndex++, nVisible++, 50, SELF:GridViewRoutings)
	oColumn:DisplayFormat:FormatType := DevExpress.Utils.FormatType.Numeric
	oColumn:DisplayFormat:FormatString := "N2"


	oColumn:=oMainForm:CreateDXColumn("MatchedWithDeparture", "MatchedWithDeparture",FALSE, DevExpress.Data.UnboundColumnType.Boolean, ;
																	nAbsIndex++, nVisible++, 30, SELF:GridViewRoutings)
	oColumn:=oMainForm:CreateDXColumn("HFO Departure", "DepHFO",FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																	nAbsIndex++, nVisible++, 50, SELF:GridViewRoutings)
	oColumn:DisplayFormat:FormatType := DevExpress.Utils.FormatType.Numeric
	oColumn:DisplayFormat:FormatString := "N2"
	oColumn:=oMainForm:CreateDXColumn("LFO Departure", "DepLFO",FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																	nAbsIndex++, nVisible++, 50, SELF:GridViewRoutings)
	oColumn:DisplayFormat:FormatType := DevExpress.Utils.FormatType.Numeric
	oColumn:DisplayFormat:FormatString := "N2"
	oColumn:=oMainForm:CreateDXColumn("MGO/MDO Departure", "DepMGO",FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																	nAbsIndex++, nVisible++, 50, SELF:GridViewRoutings)
	oColumn:DisplayFormat:FormatType := DevExpress.Utils.FormatType.Numeric
	oColumn:DisplayFormat:FormatString := "N2"
	
	oColumn:=oMainForm:CreateDXColumn("BunkeredEye", "BunkeredQty",FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																	nAbsIndex++, nVisible++, 50, SELF:GridViewRoutings)
	oColumn:DisplayFormat:FormatType := DevExpress.Utils.FormatType.Numeric
	oColumn:DisplayFormat:FormatString := "N2"

	oColumn:=oMainForm:CreateDXColumn("BunkeredHFO", "BunkeredHFO",FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																	nAbsIndex++, nVisible++, 50, SELF:GridViewRoutings)
	oColumn:DisplayFormat:FormatType := DevExpress.Utils.FormatType.Numeric
	oColumn:DisplayFormat:FormatString := "N2"

	oColumn:=oMainForm:CreateDXColumn("BunkeredLFO", "BunkeredLFO",FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																	nAbsIndex++, nVisible++, 50, SELF:GridViewRoutings)
	oColumn:DisplayFormat:FormatType := DevExpress.Utils.FormatType.Numeric
	oColumn:DisplayFormat:FormatString := "N2"
	oColumn:=oMainForm:CreateDXColumn("BunkeredMDO", "BunkeredMDO",FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																	nAbsIndex++, nVisible++, 50, SELF:GridViewRoutings)
	oColumn:DisplayFormat:FormatType := DevExpress.Utils.FormatType.Numeric
	oColumn:DisplayFormat:FormatString := "N2"




	oMainForm:CreateDXColumn("Modified by", "UserName",				FALSE, DevExpress.Data.UnboundColumnType.String, ;
																	nAbsIndex++, nVisible++, 90, SELF:GridViewRoutings)

	// Hidden columns
	oColumn:=oMainForm:CreateDXColumn("VOYAGE_UID", "VOYAGE_UID",	FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																	nAbsIndex++, -1, -1, SELF:GridViewRoutings)

	oColumn:=oMainForm:CreateDXColumn("ROUTING_UID", "ROUTING_UID",	FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																	nAbsIndex++, -1, -1, SELF:GridViewRoutings)

	oColumn:Visible:=FALSE
RETURN

METHOD formSQLRoutingsQuery(cTCextraSQL_Voyage AS STRING) as String
	LOCAL cStatement := "" AS STRING

	cStatement := "SELECT EconRoutings.ROUTING_UID, EconRoutings.VOYAGE_UID, EconRoutings.Condition, Commenced,"+;
				" Completed, EconRoutings.CommencedGMT, CompletedGMT, ArrivalGMT, DepartureGMT,EconRoutings.TCEquivalentUSD,"+;
				" WType, WHours, RoutingType,Operation , CargoDescription, CargoTons, DraftFWD_Dec, DraftAFT_Dec, RoutingROB_FO,"+;
				" ArrivalROB_FO, ManualROB_FO, FOPriceUSD,"+;
				" EconRoutings.PortFrom_UID, EconRoutings.PortTo_UID, EconRoutings.Agent, EconRoutings.DA, EconRoutings.Distance,"+;
				" EconRoutings.Deviation, RTrim(Users.UserName) AS UserName,"+;
				" RTrim(VEPortsFrom.Port) AS PortFrom, VEPortsFrom.EUPort AS FromEU, RTrim(VEPortsTo.Port) AS PortTo, VEPortsTo.EUPort AS ToEU,"+;
				" VEPortsFrom.SummerGMT_DIFF AS PortFromSummerGMT_DIFF, VEPortsFrom.WinterGMT_DIFF AS PortFromWinterGMT_DIFF,"+;
				" VEPortsTo.SummerGMT_DIFF AS PortToSummerGMT_DIFF, VEPortsTo.WinterGMT_DIFF AS PortToWinterGMT_DIFF,"+;
				" MatchedWithArrival, Arrival_HFO AS ArrHFO, Arrival_LFO AS ArrLFO, Arrival_MGO AS ArrMGO,"+;
				" MatchedWithDeparture, Departure_HFO AS DepHFO, Departure_LFO AS DepLFO, Departure_MGO AS DepMGO,"+;
				" BunkeredHFO, BunkeredLFO, BunkeredMDO, EconRoutings.BunkeredQty "+;
				" FROM EconRoutings"+oMainForm:cNoLockTerm+;
				" INNER JOIN EconVoyages ON EconVoyages.VOYAGE_UID=EconRoutings.VOYAGE_UID"+;
				" LEFT OUTER JOIN VEPorts AS VEPortsFrom ON EconRoutings.PortFrom_UID=VEPortsFrom.PORT_UID"+;
				" LEFT OUTER JOIN VEPorts AS VEPortsTo ON EconRoutings.PortTo_UID=VEPortsTo.PORT_UID"+;
				" LEFT OUTER JOIN USERS ON EconRoutings.USER_UNIQUEID=USERS.USER_UNIQUEID"+;
				" LEFT OUTER JOIN FMRoutingAdditionalData ON FMRoutingAdditionalData.Routing_UID = EconRoutings.ROUTING_UID"+;
				" WHERE VESSEL_UNIQUEID="+SELF:cVesselUID_Voyages+cTCextraSQL_Voyage+;
				" ORDER BY EconRoutings.CommencedGMT ASC, EconRoutings.ROUTING_UID ASC"

RETURN cStatement

END CLASS
