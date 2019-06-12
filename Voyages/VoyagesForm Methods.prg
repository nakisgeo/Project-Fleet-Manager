// VoyagesForm_Methods.prg
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

PARTIAL CLASS VoyagesForm INHERIT System.Windows.Forms.Form
	PRIVATE lSuspendNotification AS LOGIC
	PRIVATE oEditColumn AS GridColumn
	PRIVATE oEditRow AS DataRowView

	PRIVATE oDTVoyages, oDTRoutings AS DataTable
	PRIVATE oDS := DataSet{} AS DataSet
	EXPORT cVesselUID_Voyages := "0" AS STRING

	EXPORT lPageInitialized AS LOGIC
	PRIVATE LBSuggestOwner := "" AS STRING	//DevExpress.XtraEditors.SplitContainerControl
	PRIVATE cPortFromGMT_DIFF, cPortToGMT_DIFF AS STRING
	PRIVATE cCondition AS STRING
	PRIVATE cVoyageType AS STRING
	PRIVATE cVesselName := "" AS STRING
	//Time Charter Antonis 1.12.14
	PUBLIC lisTC AS LOGIC
	PUBLIC cTCParent AS STRING
	//Silent Mode Do Not invoke events
	PUBLIC lSilent AS LOGIC
	
	
METHOD VoyagesForm_OnLoad() AS VOID
	IF oMainForm:GetVesselUID == "0"
		MessageBox.Show("Pls select a Vessel !")
		SELF:Close()
		RETURN
	ENDIF

	oSoftway:ReadFormSettings_DevExpress(SELF, SELF:splitContainerControl, oMainForm:alForms, oMainForm:alData)

	SELF:cVesselName := oMainForm:GetVesselName
	SELF:Text := "Voyages - Vessel: "+SELF:cVesselName

	SELF:LBSuggest:BringToFront()
	SELF:LBSuggest:Visible:=FALSE

	SELF:GridViewVoyages:OptionsView:ShowGroupPanel := FALSE
	//SELF:GridViewVoyages:OptionsBehavior:AutoPopulateColumns := FALSE
	SELF:GridViewVoyages:OptionsBehavior:AllowIncrementalSearch := FALSE
	SELF:GridViewVoyages:OptionsPrint:PrintDetails := TRUE
	SELF:GridViewVoyages:OptionsSelection:EnableAppearanceHideSelection := TRUE
	SELF:GridViewVoyages:OptionsSelection:EnableAppearanceFocusedCell := FALSE
	SELF:GridViewVoyages:OptionsSelection:MultiSelect := FALSE
	SELF:GridViewVoyages:OptionsView:ColumnAutoWidth := FALSE

	//SELF:GridViewVoyages:OptionsCustomization:AllowSort := FALSE

	SELF:GridViewRoutings:OptionsView:ShowGroupPanel := FALSE
	//SELF:GridViewRoutings:OptionsBehavior:AutoPopulateColumns := FALSE
	SELF:GridViewRoutings:OptionsBehavior:AllowIncrementalSearch := FALSE
	SELF:GridViewRoutings:OptionsPrint:PrintDetails := TRUE
	SELF:GridViewRoutings:OptionsSelection:EnableAppearanceHideSelection := TRUE
	SELF:GridViewRoutings:OptionsSelection:EnableAppearanceFocusedCell := FALSE
	SELF:GridViewRoutings:OptionsSelection:MultiSelect := FALSE
	SELF:GridViewRoutings:OptionsView:ColumnAutoWidth := FALSE

	//SELF:GridViewRoutings:OptionsView:ShowFooter := TRUE
	
	lSilent := TRUE
	SELF:CreateGridVoyages_Columns()
	SELF:CreateGridRoutings_Columns()
	SELF:routingDetails1:createGrids()
	SELF:CreateGridVoyages()
	SELF:Change_BarSetup_ToolTips_Voyages()

	// Set CheckBox GridColumn to single mouse click if it is active
	SELF:SetEditModeOff_Common(SELF:GridViewVoyages)
	lSilent := FALSE
	SELF:GridViewVoyages:Focus()
	
	
	//WB(oUser:USER_UNIQUEID:tostring())
	LOCAL oRowLocal := oMainForm:returnUserSetting(oUser:USER_UNIQUEID) AS DataRow
	
	//WB(oRowLocal["CanEditVoyages"]:ToString())
	IF oRowLocal == NULL .OR. oRowLocal["CanEditVoyages"]:ToString() == "False"
		SELF:GridViewVoyages:OptionsBehavior:Editable := FALSE
		SELF:GridViewRoutings:OptionsBehavior:Editable := FALSE
	ENDIF
	
RETURN


METHOD FillCompanies() AS VOID

LOCAL cStatement AS STRING
LOCAL oDT AS DataTable


	cStatement:="SELECT Vessels.VESSEL_UNIQUEID, Vessels.VesselName"+;
				" FROM Vessels"+;
				" INNER JOIN SupVessels on Vessels.VESSEL_UNIQUEID=SupVessels.VESSEL_UNIQUEID"+;
				"	AND SupVessels.Active=1"+;
				" ORDER BY VesselName"
	oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	oSoftway:CreatePK(oDT, "VesselName")
	//wb(cStatement, oDT:Rows:Count:ToString())

	SELF:LookUpEditCompany_Voyages:Properties:Columns:Clear()
	SELF:LookUpEditCompany_Voyages:Properties:Columns:AddRange(<DevExpress.XtraEditors.Controls.LookUpColumnInfo>{ DevExpress.XtraEditors.Controls.LookUpColumnInfo{"VesselName", "Vessel"} })

	SELF:LookUpEditCompany_Voyages:Properties:DataSource := oDT
	SELF:LookUpEditCompany_Voyages:Properties:DisplayMember := oDT:Columns["VesselName"]:ToString()
	SELF:LookUpEditCompany_Voyages:Properties:ValueMember := oDT:Columns["VESSEL_UNIQUEID"]:ToString()



	IF SELF:cVesselName == ""
		IF oDT:Rows:Count == 1
			SELF:LookUpEditCompany_Voyages:ItemIndex := 0
		ENDIF
	ELSE
		LOCAL nItem := SELF:LookUpEditCompany_Voyages:Properties:GetDataSourceRowIndex("VesselName", SELF:cVesselName) AS INT
		//wb("nItem="+nItem:ToString(), "|"+SELF:cVesselName+"|")
		IF nItem <> -1
			SELF:LookUpEditCompany_Voyages:ItemIndex := nItem
		ENDIF
	ENDIF
RETURN


//	Antonis 1.12.14 Bring Voyages only under the Parent TC	//
METHOD CreateGridVoyages() AS VOID
	SELF:oDS:Relations:Clear()
	SELF:GridVoyages:LevelTree:Nodes:Clear()
	SELF:oDS := DataSet{}

	LOCAL cStatement AS STRING

	LOCAL cTCextraSQL_Voyage := " " AS STRING
	IF SELF:lisTC
		cTCextraSQL_Voyage := " AND EconVoyages.VOYAGE_UID IN ( SELECT VOYAGE_UID FROM FMVoyageLinks WHERE Parent_Voyage_UID ="+ SELF:cTCParent+" ) "
	ELSE
		cTCextraSQL_Voyage := " AND EconVoyages.VOYAGE_UID  NOT IN ( SELECT VOYAGE_UID FROM FMVoyageLinks ) "
	ENDIF


	// Voyages
	cStatement:="SELECT VOYAGE_UID, VoyageNo, EconVoyages.Description, CPDate, Charterers, Broker, StartDate, EndDate, StartDateGMT, EndDateGMT, LaytimeStartDate, LaytimeEndDate,"+;
				" CostOfBunkersUSD, CPMinSpeed, HFOConsumption, DGFOConsumption, EconVoyages.Type,"+;
				" EconVoyages.PortFrom_UID, EconVoyages.PortTo_UID, EconVoyages.Distance, RTrim(Users.UserName) AS UserName,"+;
				" RTrim(VEPortsFrom.Port) AS PortFrom, VEPortsFrom.EUPort AS FromEU , RTrim(VEPortsTo.Port) AS PortTo, VEPortsTo.EUPort AS ToEU,"+;
				" VEPortsFrom.SummerGMT_DIFF AS PortFromSummerGMT_DIFF, VEPortsFrom.WinterGMT_DIFF AS PortFromWinterGMT_DIFF,"+;
				" VEPortsTo.SummerGMT_DIFF AS PortToSummerGMT_DIFF, VEPortsTo.WinterGMT_DIFF AS PortToWinterGMT_DIFF"+;
				" FROM EconVoyages"+oMainForm:cNoLockTerm+;
				" LEFT OUTER JOIN VEPorts AS VEPortsFrom ON EconVoyages.PortFrom_UID=VEPortsFrom.PORT_UID"+;
				" LEFT OUTER JOIN VEPorts AS VEPortsTo ON EconVoyages.PortTo_UID=VEPortsTo.PORT_UID"+;
				" LEFT OUTER JOIN USERS ON EconVoyages.USER_UNIQUEID=USERS.USER_UNIQUEID"+;
				" WHERE VESSEL_UNIQUEID="+SELF:cVesselUID_Voyages+ cTCextraSQL_Voyage+;
				" ORDER BY StartDateGMT DESC"
	//MemoWrit(ctempdocdir+"\stat1.txt", cStatement)
	//wb(cStatement)
	SELF:oDTVoyages:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	SELF:oDTVoyages:TableName:="EconVoyages"
	// Create Primary Key
	oSoftway:CreatePK(SELF:oDTVoyages, "VOYAGE_UID")

	// Routings
	cStatement:= SELF:formSQLRoutingsQuery(cTCextraSQL_Voyage)
	
	//MemoWrit(ctempdocdir+"\stat2.txt", cStatement)
	
	SELF:oDTRoutings:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	SELF:oDTRoutings:TableName:="EconRoutings"
	// Create Primary Key
	oSoftway:CreatePK(SELF:oDTRoutings, "ROUTING_UID")

	// Add the DataTables to DataSet
	SELF:oDS:Tables:Add(SELF:oDTVoyages)
	SELF:oDS:Tables:Add(SELF:oDTRoutings)

	// Create DataSet Relation
	IF SELF:oDS:Tables["EconVoyages"]:Rows:Count > 0
		TRY
			SELF:oDS:Relations:Add("Voyage Routing", SELF:oDS:Tables["EconVoyages"]:Columns["VOYAGE_UID"], ;
													SELF:oDS:Tables["EconRoutings"]:Columns["VOYAGE_UID"])
		CATCH oe AS Exception
			ErrorBox(oe:Message, "Check [EconVoyages], [EconRoutings] tables")
		END TRY
	ENDIF
	SELF:GridVoyages:DataSource := SELF:oDS:Tables["EconVoyages"]
	// More: Detailed grid view
	SELF:GridVoyages:LevelTree:Nodes:Add("Voyage Routing", SELF:GridViewRoutings)

RETURN


METHOD CreateGridVoyages_Columns() AS VOID
LOCAL oColumn AS GridColumn
LOCAL nVisible:=0, nAbsIndex:=0 AS INT

	oMainForm:CreateDXColumn("VoyageNo", "VoyageNo",				FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																	nAbsIndex++, nVisible++, 60, SELF:GridViewVoyages)
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////																
	oColumn:=oMainForm:CreateDXColumn("Type", "uType",FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
																nAbsIndex++, nVisible++, 70, SELF:GridViewVoyages)
	// Set a ComboBoxEdit control to the uIO column
	LOCAL oRepositoryItemComboBox_Type := RepositoryItemComboBox{} AS RepositoryItemComboBox
	oRepositoryItemComboBox_Type:Items:AddRange(<System.OBJECT>{ "Voyage", "Time Charter", "Idle"})
    oRepositoryItemComboBox_Type:Properties:TextEditStyle := DevExpress.XtraEditors.Controls.TextEditStyles.DisableTextEditor
	oColumn:ColumnEdit := oRepositoryItemComboBox_Type				
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////													

	oMainForm:CreateDXColumn("Description", "Description",			FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
																	nAbsIndex++, nVisible++, 200, SELF:GridViewVoyages)
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	oMainForm:CreateDXColumn("Charterers", "Charterers",			FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
																	nAbsIndex++, nVisible++, 110, SELF:GridViewVoyages)
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	oColumn:=oMainForm:CreateDXColumn("From Port", "PortFrom",	FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
																nAbsIndex++, nVisible++, 150, SELF:GridViewVoyages)
	oColumn:ColumnEdit := SELF:CreateRepositoryItemTextEdit_Port()

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	oColumn:=oMainForm:CreateDXColumn("FromEU", "FromEU",				FALSE, DevExpress.Data.UnboundColumnType.Boolean, ;
																		nAbsIndex++, nVisible++, 50, SELF:GridViewVoyages)
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	oColumn:=oMainForm:CreateDXColumn("+/-GMT", "uPortFromGMT_DIFF",FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																nAbsIndex++, nVisible++, 55, SELF:GridViewVoyages)
	// ToolTip
	LOCAL cPeriodGMT AS STRING
	oColumn:ToolTip := IIF(oSoftway:IsSummerTimeGMT(cPeriodGMT), "", "")+"Difference from GMT in Hours ('From Port')"+CRLF+cPeriodGMT
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

	oColumn:=oMainForm:CreateDXColumn("To Port", "PortTo",		FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
																nAbsIndex++, nVisible++, 150, SELF:GridViewVoyages)
	oColumn:ColumnEdit := SELF:CreateRepositoryItemTextEdit_Port()

	oColumn:=oMainForm:CreateDXColumn("ToEU", "ToEU",				FALSE, DevExpress.Data.UnboundColumnType.Boolean, ;
																		nAbsIndex++, nVisible++, 50, SELF:GridViewVoyages)
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	oColumn:=oMainForm:CreateDXColumn("+/-GMT", "uPortToGMT_DIFF",	FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																nAbsIndex++, nVisible++, 55, SELF:GridViewVoyages)
	// ToolTip
	oColumn:ToolTip := "Difference from GMT in Hours ('To Port')"+CRLF+cPeriodGMT

	oColumn:=oMainForm:CreateDXColumn("Distance", "Distance",	FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																nAbsIndex++, nVisible++, 65, SELF:GridViewVoyages)

	oColumn:=oMainForm:CreateDXColumn("Start Date", "StartDate",FALSE, DevExpress.Data.UnboundColumnType.DateTime, ;
																	nAbsIndex++, nVisible++, 100, SELF:GridViewVoyages)
	oColumn:ColumnEdit := SELF:CreateRepositoryItemDateTime()

	oColumn:=oMainForm:CreateDXColumn("Start Date GMT", "StartDateGMT",FALSE, DevExpress.Data.UnboundColumnType.DateTime, ;
																	nAbsIndex++, nVisible++, 100, SELF:GridViewVoyages)
	oColumn:ColumnEdit := SELF:CreateRepositoryItemDateTime()

	oColumn:=oMainForm:CreateDXColumn("End Date", "EndDate",	FALSE, DevExpress.Data.UnboundColumnType.DateTime, ;
																	nAbsIndex++, nVisible++, 100, SELF:GridViewVoyages)
	oColumn:ColumnEdit := SELF:CreateRepositoryItemDateTime()

	oColumn:=oMainForm:CreateDXColumn("End Date GMT", "EndDateGMT",	FALSE, DevExpress.Data.UnboundColumnType.DateTime, ;
																	nAbsIndex++, nVisible++, 100, SELF:GridViewVoyages)
	oColumn:ColumnEdit := SELF:CreateRepositoryItemDateTime()

	oColumn:=oMainForm:CreateDXColumn("CPDate", "CPDate",			FALSE, DevExpress.Data.UnboundColumnType.DateTime, ;
																	nAbsIndex++, nVisible++, 100, SELF:GridViewVoyages)
	oColumn:ColumnEdit := SELF:CreateRepositoryItemDateTime()
//	oColumn:DisplayFormat:FormatType := DevExpress.Utils.FormatType.DateTime
//	oColumn:DisplayFormat:FormatString := ccDateFormatYY
	oColumn:ToolTip := "The CPDate is required for Voyage Calculations"

	oMainForm:CreateDXColumn("CP Speed", "CPMinSpeed",				FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																	nAbsIndex++, nVisible++, 75, SELF:GridViewVoyages)

	//oMainForm:CreateDXColumn("TC Equivalent (USD)", "TCEquivalentUSD",	FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
	//																nAbsIndex++, nVisible++, 78, SELF:GridViewVoyages)

	/*oColumn:=oMainForm:CreateDXColumn("HFO Consumption (tons)", "HFOConsumption",	FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																	nAbsIndex++, nVisible++, 58, SELF:GridViewVoyages)
	//oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Far
	//oColumn:DisplayFormat:FormatType := DevExpress.Utils.FormatType.Numeric
	oColumn:DisplayFormat:FormatString := "N2"

	oColumn:=oMainForm:CreateDXColumn("DG FO Consumption (tons)", "DGFOConsumption",	FALSE, DevExpress.Data.UnboundColumnType.Decimal, ;
																	nAbsIndex++, nVisible++, 68, SELF:GridViewVoyages)
	//oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Far
	//oColumn:DisplayFormat:FormatType := DevExpress.Utils.FormatType.Numeric
	oColumn:DisplayFormat:FormatString := "N2"*/

	oMainForm:CreateDXColumn("Broker", "Broker",					FALSE, DevExpress.Data.UnboundColumnType.STRING, ;
																	nAbsIndex++, nVisible++, 110, SELF:GridViewVoyages)
																	
	oColumn:=oMainForm:CreateDXColumn("Laytime Start", "LaytimeStartDate",FALSE, DevExpress.Data.UnboundColumnType.DateTime, ;
																	nAbsIndex++, nVisible++, 100, SELF:GridViewVoyages)
	oColumn:ColumnEdit := SELF:CreateRepositoryItemDateTime()
	
	oColumn:=oMainForm:CreateDXColumn("Laytime End", "LaytimeEndDate",FALSE, DevExpress.Data.UnboundColumnType.DateTime, ;
																	nAbsIndex++, nVisible++, 100, SELF:GridViewVoyages)
	oColumn:ColumnEdit := SELF:CreateRepositoryItemDateTime()

	//oMainForm:CreateDXColumn("Cost of Bunkers (USD)", "CostOfBunkersUSD",	FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
	//																nAbsIndex++, nVisible++, 84, SELF:GridViewVoyages)

	oMainForm:CreateDXColumn("Modified by", "UserName",				FALSE, DevExpress.Data.UnboundColumnType.String, ;
																	nAbsIndex++, nVisible++, 80, SELF:GridViewVoyages)


// Hidden columns
	oColumn:=oMainForm:CreateDXColumn("VOYAGE_UID", "VOYAGE_UID",	FALSE, DevExpress.Data.UnboundColumnType.Integer, ;
																	nAbsIndex++, -1, -1, SELF:GridViewVoyages)
	oColumn:Visible:=FALSE
RETURN


METHOD CreateRepositoryItemDateTime() AS RepositoryItemDateEdit
// Create a RepositoryItemTextEdit control for the DateTime columns: dd-MM-yy HH:mm
	LOCAL oRepositoryItemDateTime AS RepositoryItemDateEdit
	oRepositoryItemDateTime := RepositoryItemDateEdit{}
	oRepositoryItemDateTime:Name := "oRepositoryItemDateTime"
    oRepositoryItemDateTime:DisplayFormat:FormatString := ccDateFormatYY+" HH:mm"
    oRepositoryItemDateTime:DisplayFormat:FormatType := DevExpress.Utils.FormatType.DateTime
    oRepositoryItemDateTime:EditFormat:FormatString := ccDateFormatYY+" HH:mm"
    oRepositoryItemDateTime:EditFormat:FormatType := DevExpress.Utils.FormatType.DateTime
    oRepositoryItemDateTime:Mask:EditMask := ccDateFormatYY+" HH:mm"
    oRepositoryItemDateTime:Mask:MaskType := DevExpress.XtraEditors.Mask.MaskType.DateTime
    oRepositoryItemDateTime:Mask:UseMaskAsDisplayFormat := TRUE
	oRepositoryItemDateTime:Mask:MaskType := DevExpress.XtraEditors.Mask.MaskType.DateTimeAdvancingCaret
RETURN oRepositoryItemDateTime




METHOD SetEditModeOff_Common(oGridView AS GridView) AS VOID
	TRY
		IF oGridView:FocusedColumn <> NULL .AND. oGridView:FocusedColumn:UnboundType == DevExpress.Data.UnboundColumnType.Boolean
			IF ! oGridView:OptionsSelection:EnableAppearanceFocusedCell
				oGridView:OptionsSelection:EnableAppearanceFocusedCell := TRUE
			ENDIF
			oGridView:FocusedColumn:OptionsColumn:AllowEdit := TRUE
			RETURN
		ENDIF

		IF ! oGridView:OptionsSelection:EnableAppearanceFocusedCell
			RETURN
		ENDIF

		oGridView:OptionsSelection:EnableAppearanceFocusedCell := FALSE

		IF SELF:oEditColumn <> NULL
			SELF:oEditColumn:OptionsColumn:AllowEdit := FALSE
			SELF:oEditColumn := NULL
		ENDIF

		IF SELF:oEditRow <> NULL
			SELF:oEditRow := NULL
		ENDIF
	CATCH
	END TRY
RETURN


METHOD BeforeLeaveRow_Voyages(e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.VOID
	IF SELF:lSuspendNotification
		RETURN
	ENDIF

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewVoyages:GetRow(e:RowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

/*	// Validate
	if ! Self:ValidateVoyages()
		e:Allow := False
		Return
	endif*/

	// EditMode: OFF
	SELF:SetEditModeOff_Common(SELF:GridViewVoyages)
RETURN


METHOD BeforeLeaveRow_Routings(e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.VOID
	IF SELF:lSuspendNotification
		RETURN
	ENDIF

	LOCAL oView:=(GridView)SELF:GridVoyages:FocusedView AS GridView
	IF oView == NULL
		RETURN
	ENDIF

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)oView:GetRow(e:RowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

/*	// Validate
	if ! Self:ValidateVoyages()
		e:Allow := False
		Return
	endif*/

	// EditMode: OFF
	SELF:SetEditModeOff_Common(oView)
RETURN


METHOD CustomUnboundColumnData_Voyages(e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs) AS VOID
// Provides data for the UnboundColumns
	IF ! e:IsGetData
		RETURN
	ENDIF

	LOCAL oRow AS DataRow
	//LOCAL cValue AS STRING
	LOCAL cField AS STRING
	LOCAL oView AS GridView

	DO CASE
	CASE e:Column:FieldName == "uPortFromGMT_DIFF"
		TRY
			oRow:=SELF:oDTVoyages:Rows[e:ListSourceRowIndex]
			// Remove the leading 'u' from FieldName
			cField:=SELF:GetGMTColumn_Voyage(oRow, "PortFrom")
			e:Value := oRow:Item[cField]
		CATCH
			e:Value := 0
		END TRY

	// Antonis 28.11.14 Add Voyage Type //
	
	CASE e:Column:FieldName == "uType"
		IF e:ListSourceRowIndex == -1
			e:Value := ""
			RETURN
		ENDIF

		TRY
			LOCAL cValue AS STRING
			oView := (GridView)e:Column:View	
			oRow := oView:GetDataRow(e:ListSourceRowIndex)
			IF oRow == NULL
				RETURN
			ENDIF
			// Remove the leading 'u' from FieldName
			cField:=oRow:Item[e:Column:FieldName:Substring(1)]:ToString()
			DO CASE
				CASE cField == "0"
					cValue:="Voyage"
				CASE cField == "1"
					cValue:="Time Charter"
				CASE cField == "2"
					cValue:="Idle"
				OTHERWISE
					cValue:=""
			ENDCASE
			e:Value:=cValue
		CATCH
			e:Value := ""
		END TRY

	CASE e:Column:FieldName == "uPortToGMT_DIFF"
		TRY
			oRow:=SELF:oDTVoyages:Rows[e:ListSourceRowIndex]
			// Remove the leading 'u' from FieldName
			cField:=SELF:GetGMTColumn_Voyage(oRow, "PortTo")
			e:Value:=oRow:Item[cField]
		CATCH
			e:Value := 0
		END TRY
	ENDCASE
RETURN


METHOD GetGMTColumn_Voyage(oRow AS DataRow, cPrefix AS STRING) AS STRING
	LOCAL cGMT, cDateGMT AS STRING
	LOCAL dt AS Datetime

	// Read the Row's CommencedGMT or CompletedGMT
	cDateGMT := oRow:Item[IIF(cPrefix == "PortFrom", "StartDateGMT", "EndDateGMT")]:ToString()
	IF cDateGMT == ""
		cGMT := IIF(oSoftway:IsSummerTimeGMT(Datetime.Now), cPrefix+"SummerGMT_DIFF", cPrefix+"WinterGMT_DIFF")
		RETURN cGMT
	ENDIF

	TRY
		dt := Datetime.Parse(cDateGMT)
		cGMT := IIF(oSoftway:IsSummerTimeGMT(dt), cPrefix+"SummerGMT_DIFF", cPrefix+"WinterGMT_DIFF")
	CATCH
		cGMT := IIF(oSoftway:IsSummerTimeGMT(Datetime.Now), cPrefix+"SummerGMT_DIFF", cPrefix+"WinterGMT_DIFF")
		//wb(cGMT, "Catch")
	END TRY
RETURN cGMT


METHOD GetGMTColumn_Routing(oRow AS DataRow, cPrefix AS STRING) AS STRING
	LOCAL cGMT, cDateGMT AS STRING
	LOCAL dt AS Datetime

	// Read the Row's CommencedGMT or CompletedGMT
	cDateGMT := oRow:Item[IIF(cPrefix == "PortFrom", "CommencedGMT", "CompletedGMT")]:ToString()
	IF cDateGMT == ""
		cGMT := IIF(oSoftway:IsSummerTimeGMT(Datetime.Now), cPrefix+"SummerGMT_DIFF", cPrefix+"WinterGMT_DIFF")
		RETURN cGMT
	ENDIF

	TRY
		dt := Datetime.Parse(cDateGMT)
		cGMT := IIF(oSoftway:IsSummerTimeGMT(dt), cPrefix+"SummerGMT_DIFF", cPrefix+"WinterGMT_DIFF")
	CATCH
		cGMT := IIF(oSoftway:IsSummerTimeGMT(Datetime.Now), cPrefix+"SummerGMT_DIFF", cPrefix+"WinterGMT_DIFF")
		//wb(cGMT, "Catch")
	END TRY
RETURN cGMT


METHOD FocusedRowChanged_Voyages(e AS DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventArgs) AS VOID
// Notification Method
	IF SELF:GridViewVoyages:IsGroupRow(e:FocusedRowHandle)
		RETURN
	ENDIF

	// Get GridRow data into a DataRowView object
	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewVoyages:GetRow(e:FocusedRowHandle)
	IF oRow == NULL
		RETURN
	ELSE
		SELF:routingDetails1:formGrid("V",oRow["Voyage_UID"]:ToString(),"Data",SELF)
	ENDIF

	
RETURN


METHOD CustomUnboundColumnData_Routings(e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs) AS VOID
// Provides data for the UnboundColumns
	IF ! e:IsGetData
		RETURN
	ENDIF

	LOCAL oView AS GridView
	LOCAL oRow AS DataRow
	LOCAL cField AS STRING

	DO CASE
	CASE e:Column:FieldName == "uCondition"
		IF e:ListSourceRowIndex == -1
			e:Value := ""
			RETURN
		ENDIF

		TRY
			LOCAL cValue AS STRING
			oView := (GridView)e:Column:View	//(GridView)SELF:GridViewVoyages:GetDetailView(SELF:GridViewVoyages:FocusedRowHandle, 0)
			oRow := oView:GetDataRow(e:ListSourceRowIndex)
			IF oRow == NULL
				RETURN
			ENDIF
			// Remove the leading 'u' from FieldName
			cField:=oRow:Item[e:Column:FieldName:Substring(1)]:ToString()
			DO CASE
				CASE cField == "1"
					cValue:="Ballast"
				CASE cField == "2"
					cValue:="Laden"
				CASE cField == "3"
					cValue:="Loading"
				CASE cField == "4"
					cValue:="Discharging"
				CASE cField == "5"
					cValue:="Idle"
				OTHERWISE
					cValue:=""
			ENDCASE
			e:Value:=cValue
		CATCH
			e:Value := ""
		END TRY

	CASE e:Column:FieldName == "uPortFromGMT_DIFF"
		TRY
			oView := (GridView)e:Column:View	//(GridView)SELF:GridViewVoyages:GetDetailView(SELF:GridViewVoyages:FocusedRowHandle, 0)
			oRow := oView:GetDataRow(e:ListSourceRowIndex)
			// Remove the leading 'u' from FieldName
			cField:=SELF:GetGMTColumn_Routing(oRow, "PortFrom")
			e:Value := oRow:Item[cField]
		CATCH
			e:Value := 0
		END TRY

	CASE e:Column:FieldName == "uPortToGMT_DIFF"
		TRY
			oView := (GridView)e:Column:View	//(GridView)SELF:GridViewVoyages:GetDetailView(SELF:GridViewVoyages:FocusedRowHandle, 0)
			oRow := oView:GetDataRow(e:ListSourceRowIndex)
			// Remove the leading 'u' from FieldName
			cField:=SELF:GetGMTColumn_Routing(oRow, "PortTo")
			e:Value:=oRow:Item[cField]
		CATCH
			e:Value := 0
		END TRY

	CASE e:Column:FieldName == "DiffROB_FO"
		oView := (GridView)e:Column:View	//(GridView)SELF:GridViewVoyages:GetDetailView(SELF:GridViewVoyages:FocusedRowHandle, 0)
		oRow := oView:GetDataRow(e:ListSourceRowIndex)
		IF oRow == NULL
			RETURN
		ENDIF

		LOCAL nDiffROB_FO AS Double
		TRY
			//SELF:BuildString(oRow, "CalcTravelDays", "Start")
			LOCAL nArrivalROB_FO, nManualROB_FO AS Double
			nArrivalROB_FO := Convert.ToDouble(oRow["ArrivalROB_FO"]:ToString())
			nManualROB_FO := Convert.ToDouble(oRow["ManualROB_FO"]:ToString())
			nDiffROB_FO := nManualROB_FO - nArrivalROB_FO
			//nDiffROB_FO := nManualROB_FO - 416500
			e:Value := nDiffROB_FO
		CATCH
			e:Value := NULL
		END TRY

	ENDCASE
RETURN



METHOD FocusedRowChanged_Routings(e AS DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventArgs, oView AS GridView) AS VOID
// Notification Method
	IF oView:IsGroupRow(e:FocusedRowHandle)
		RETURN
	ENDIF
	// Get GridRow data into a DataRowView object
	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)oView:GetRow(e:FocusedRowHandle)
	IF oRow == NULL
		RETURN
	ENDIF
	
	IF lSilent
		RETURN
	ENDIF
	
	//LOCAL iIndexes AS INT[]
	LOCAL oRoutingRow AS DataRowView
		IF SELF:GridVoyages:FocusedView == SELF:GridViewVoyages
			RETURN
		ELSE
			LOCAL oRView:=(GridView)SELF:GridVoyages:FocusedView AS GridView
			IF oRView == NULL
				RETURN
			ENDIF
			oRoutingRow:=(DataRowView)oRView:GetFocusedRow()
			SELF:routingDetails1:formGrid("R",oRoutingRow["ROUTING_UID"]:ToString(),"Data",SELF)
		ENDIF
	
RETURN

EXPORT METHOD click_Routings() AS VOID
//	LOCAL iIndexes AS INT[]
	LOCAL oRoutingRow AS DataRowView
		IF SELF:GridVoyages:FocusedView == SELF:GridViewVoyages
			RETURN
		ELSE
			LOCAL oRView:=(GridView)SELF:GridVoyages:FocusedView AS GridView
			IF oRView == NULL
				RETURN
			ENDIF
			oRoutingRow:=(DataRowView)oRView:GetFocusedRow()
			SELF:routingDetails1:formGrid("R",oRoutingRow["ROUTING_UID"]:ToString(),"Data",SELF)
		ENDIF
RETURN

METHOD Voyages_Add() AS VOID
	IF SELF:LookUpEditCompany_Voyages:Text == ""
		wb("No Vessel selected")
		SELF:LookUpEditCompany_Voyages:Focus()
		RETURN
	ENDIF

	IF QuestionBox("Do you want to create a New Voyage ?", ;
					"New Voyage") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	LOCAL cVesselUID := SELF:LookUpEditCompany_Voyages:EditValue:ToString() AS STRING

	LOCAL cStatement, cVoyageNo, cUID AS STRING
	LOCAL nVoyageNo AS INT

	cStatement:="SELECT Max(VoyageNo) as nNumMax FROM EconVoyages"+oMainForm:cNoLockTerm+;
				" WHERE VESSEL_UNIQUEID="+cVesselUID
	cVoyageNo:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "nNumMax")
	IF cVoyageNo == "" .OR. cVoyageNo == "NULL"
		cVoyageNo := "0"
	ENDIF
	nVoyageNo := Convert.ToInt32(cVoyageNo) + 1
	IF nVoyageNo > 99999
		ErrorBox("You cannot have more than 99999 Voyages", "Limit reached")
		RETURN
	ENDIF
	

	cStatement:="INSERT INTO EconVoyages"+" (VESSEL_UNIQUEID, VoyageNo, Description, USER_UNIQUEID) VALUES"+;
				" ("+cVesselUID+", "+nVoyageNo:ToString()+", '_New Voyage "+nVoyageNo:ToString()+"', "+oUser:USER_UNIQUEID+") ;"
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:Voyages_Refresh()
		RETURN
	ENDIF

	cUID:=oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "EconVoyages", "VOYAGE_UID")


	LOCAL cTCextraSQL := "" AS STRING
	IF SELF:lisTC
		cTCextraSQL :=  "INSERT INTO FMVoyageLinks"+" (Parent_Voyage_UID, Voyage_UID, Link_Type) VALUES"+;
						" ("+SELF:cTCParent+", "+cUID+", 1) ;"
		IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cTCextraSQL)
			WB("Can not create Voyage Link")
			RETURN
		ENDIF
	ENDIF
	//SELF:VoyageLog("Add", cUID, "")

	//SELF:Voyages_Refresh()
	// Add to Datatable
	LOCAL oDataRow := SELF:oDTVoyages:NewRow() AS DataRow
	oDataRow:Item["VOYAGE_UID"] := Convert.ToInt32(cUID)
	//oDataRow:Item["VESSEL_UNIQUEID"] := Convert.ToInt32(cVesselUID)
	oDataRow:Item["VoyageNo"] := nVoyageNo
	oDataRow:Item["Description"] := "_New Voyage "+nVoyageNo:ToString()
	oDataRow:Item["Distance"] := 0
	oDataRow:Item["UserName"] := oUser:UserName
	SELF:oDTVoyages:Rows:Add(oDataRow)

	LOCAL nFocusedHandle AS INT
	//nFocusedHandle:=SELF:GridViewVoyages:LocateByValue(0, SELF:GridViewVoyages:Columns["VOYAGE_UID"], Convert.ToInt32(cUID))
	nFocusedHandle:=SELF:GridViewVoyages:LocateByDisplayText(0, SELF:GridViewVoyages:Columns["VOYAGE_UID"], cUID)
	IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
		RETURN
	ENDIF
	SELF:GridViewVoyages:ClearSelection()
	SELF:GridViewVoyages:FocusedRowHandle:=nFocusedHandle
	SELF:GridViewVoyages:SelectRow(nFocusedHandle)
RETURN

// Antonis 1.12.14 Add New Voyage Below Time Charter Voyage //

METHOD VoyageRouting_Add(lSilent AS LOGIC) AS VOID
	LOCAL oRow AS DataRowView
	LOCAL isTimeCharter :=FALSE AS LOGIC
	oRow:=(DataRowView)SELF:GridViewVoyages:GetFocusedRow()

	IF oRow == NULL
		wb("No Voyage selected")
		RETURN
	ENDIF

	LOCAL cTypeOfVoyage := oRow:Item["Type"]:ToString() AS STRING
	IF cTypeOfVoyage == "1"
		isTimeCharter := TRUE
	ENDIF
	//wb(cTypeOfVoyage) 
	
	
	IF ! lSilent .AND. !isTimeCharter
		IF QuestionBox("Do you want to create a New Voyage Routing for the selected Voyage ?", ;
					"New Voyage Routing") <> System.Windows.Forms.DialogResult.Yes
			RETURN
		ENDIF
	ELSEIF !lSilent .AND. isTimeCharter
		IF QuestionBox("Do you want to create a New Voyage for the selected Time Charter ?", ;
					"New Voyage") <> System.Windows.Forms.DialogResult.Yes
			RETURN
		ENDIF
		LOCAL oVoyagesFormTC := VoyagesForm{} AS VoyagesForm
		oVoyagesFormTC:setTimeCharterProperties(TRUE, oRow:Item["VOYAGE_UID"]:ToString())
		//WB(oRow:Item["VOYAGE_UID"]:ToString())
		oVoyagesFormTC:Show(SELF)
		RETURN
	ENDIF

	LOCAL cStatement AS STRING
	LOCAL cUID := oRow:Item["VOYAGE_UID"]:ToString() AS STRING
	LOCAL oView:=(GridView)SELF:GridViewVoyages:GetDetailView(SELF:GridViewVoyages:FocusedRowHandle, 0) AS GridView
	//LOCAL dDateGMT := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.Utc) AS Datetime

	TRY
		//cStatement:="INSERT INTO EconRoutings (VOYAGE_UID, PortFrom, CommencedGMT) VALUES"+;
		//			" ("+cUID+", '', '"+dDateGMT:ToString("yyyy-MM-dd HH:mm:ss")+"')"
		LOCAL cUIDFrom := "0", cStartDate := "NULL" AS STRING
		IF oView == NULL
			cStatement:="SELECT PortFrom_UID, PortTo_UID, Distance, StartDate, EndDate, StartDateGMT, EndDateGMT FROM EconVoyages"+oMainForm:cNoLockTerm+;
						" WHERE VOYAGE_UID="+cUID
			LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			LOCAL cUIDTo := "0", cDistance := "0", cEndDate AS STRING
			IF oDT:Rows:Count == 1
				cUIDFrom := oDT:Rows[0]:Item["PortFrom_UID"]:ToString()
				cUIDTo := oDT:Rows[0]:Item["PortTo_UID"]:ToString()
				cDistance := oDT:Rows[0]:Item["Distance"]:ToString()

				cStartDate := oDT:Rows[0]:Item["StartDate"]:ToString()
				IF cStartDate == ""
					cStartDate := "NULL"
				ELSE
					cStartDate := "'"+Datetime.Parse(oDT:Rows[0]:Item["StartDate"]:ToString()):ToString("yyyy-MM-dd HH:mm:ss")+"'"
				ENDIF

				cEndDate := oDT:Rows[0]:Item["EndDate"]:ToString()
				IF cEndDate == ""
					cEndDate := "NULL"
				ELSE
					cEndDate := "'"+Datetime.Parse(oDT:Rows[0]:Item["EndDate"]:ToString()):ToString("yyyy-MM-dd HH:mm:ss")+"'"
				ENDIF
			ENDIF
			cStatement:="INSERT INTO EconRoutings (VOYAGE_UID, PortFrom_UID, PortTo_UID, Distance, CommencedGMT, CompletedGMT, USER_UNIQUEID) VALUES"+;
						" ("+cUID+", "+cUIDFrom+", "+cUIDTo+", "+cDistance+", "+cStartDate+", "+cEndDate+", "+oUser:USER_UNIQUEID+")"
		ELSE
			//LOCAL dGMTCompleted := oMainForm:GetLastRoutingDate(cUID) AS DateTime
			//LOCAL cCommencedGMT := "NULL" AS STRING
			//IF dGMTCompleted <> DateTime.MinValue
			//	dGMTCompleted := dGMTCompleted:AddMinutes(1)
			//	cCommencedGMT := "'" + dGMTCompleted:ToString("yyyy-MM-dd HH:mm") + "'"
			//	//// Update
			//	//cStatement:="UPDATE EconRoutings SET"+;
			//	//			" Commenced='"+dLTCompleted:ToString("yyyy-MM-dd HH:mm")+"'"+;
			//	//			" WHERE ROUTING_UID="+cUID
			//	//oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			//	//oDataRow:Item["Completed"] := dLTCompleted
			//	//SELF:VoyageRouting_Refresh()
			//ENDIF
			cStatement:="SELECT PortFrom_UID, PortTo_UID, Distance, Commenced, Completed, CommencedGMT, CompletedGMT FROM EconRoutings"+oMainForm:cNoLockTerm+;
						" WHERE VOYAGE_UID="+cUID+;
						" ORDER BY  ArrivalGMT DESC,EconRoutings.ROUTING_UID DESC"
			cStatement := oSoftway:SelectTop(cStatement)
			LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			IF oDT:Rows:Count == 1
				cUIDFrom := oDT:Rows[0]:Item["PortTo_UID"]:ToString()
				//cUIDTo := oDT:Rows[0]:Item["PortTo_UID"]:ToString()
				//cDistance := oDT:Rows[0]:Item["Distance"]:ToString()

				cStartDate := oDT:Rows[0]:Item["CompletedGMT"]:ToString()
				IF cStartDate == ""
					cStartDate := "NULL"
				ELSE
					cStartDate := "'"+Datetime.Parse(cStartDate):AddMinutes(1):ToString("yyyy-MM-dd HH:mm:ss")+"'"
				ENDIF
			ENDIF

			cStatement:="INSERT INTO EconRoutings (VOYAGE_UID, PortFrom_UID, PortTo_UID, Distance, CommencedGMT, CompletedGMT, USER_UNIQUEID) VALUES"+;
						" ("+cUID+", "+cUIDFrom+", 0, 0, "+cStartDate+", NULL, "+oUser:USER_UNIQUEID+")"
			//SELF:VoyageRouting_Refresh()

			//cStatement:="INSERT INTO EconRoutings (VOYAGE_UID, CommencedGMT) VALUES"+;
			//			" ("+cUID+", "+cCommencedGMT+")"
		ENDIF
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		LOCAL cRoutingUID := oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "EconVoyages", "ROUTING_UID") AS STRING

		//SELF:RoutingLog("Add", cRoutingUID, "")

		// Add to Datatable
		LOCAL oDataRow := SELF:oDTRoutings:NewRow() AS DataRow
		oDataRow:Item["ROUTING_UID"] := Convert.ToInt32(cRoutingUID)
		oDataRow:Item["VOYAGE_UID"] := Convert.ToInt32(cUID)
		IF oView == NULL
			oDataRow:Item["PortFrom"] := oRow:Item["PortFrom"]:ToString()
			oDataRow:Item["PortTo"] := oRow:Item["PortTo"]:ToString()
			oDataRow:Item["Distance"] := oRow:Item["Distance"]:ToString()
		ELSE			
			// Read last inserted row
			cStatement:="SELECT ROUTING_UID, EconRoutings.VOYAGE_UID, EconRoutings.Condition, Commenced, Completed, CommencedGMT, CompletedGMT, EconRoutings.TCEquivalentUSD,"+;
						" Agent, DA, Operation, ArrivalGMT, DepartureGMT,"+;
						" WType, WHours, RoutingType, CargoDescription, CargoTons, DraftFWD_Dec, DraftAFT_Dec, RoutingROB_FO, ArrivalROB_FO, ManualROB_FO, FOPriceUSD,"+;
						" EconRoutings.PortFrom_UID, EconRoutings.PortTo_UID, EconRoutings.Distance, EconRoutings.Deviation, RTrim(Users.UserName) AS UserName,"+;
						" RTrim(VEPortsFrom.Port) AS PortFrom, RTrim(VEPortsTo.Port) AS PortTo,"+;
						" VEPortsFrom.SummerGMT_DIFF AS PortFromSummerGMT_DIFF, VEPortsFrom.WinterGMT_DIFF AS PortFromWinterGMT_DIFF,"+;
						" VEPortsTo.SummerGMT_DIFF AS PortToSummerGMT_DIFF, VEPortsTo.WinterGMT_DIFF AS PortToWinterGMT_DIFF"+;
						" FROM EconRoutings"+oMainForm:cNoLockTerm+;
						" INNER JOIN EconVoyages ON EconVoyages.VOYAGE_UID=EconRoutings.VOYAGE_UID"+;
						" LEFT OUTER JOIN VEPorts AS VEPortsFrom ON EconRoutings.PortFrom_UID=VEPortsFrom.PORT_UID"+;
						" LEFT OUTER JOIN VEPorts AS VEPortsTo ON EconRoutings.PortTo_UID=VEPortsTo.PORT_UID"+;
						" LEFT OUTER JOIN USERS ON EconVoyages.USER_UNIQUEID=USERS.USER_UNIQUEID"+;
						" WHERE ROUTING_UID="+cRoutingUID
			LOCAL oDT :=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			oDataRow:ItemArray := oDT:Rows[0]:ItemArray
		ENDIF
		oDataRow:Item["UserName"] := oUser:UserName
		//oDataRow:Item["CommencedGMT"] := dDateGMT
		SELF:oDTRoutings:Rows:Add(oDataRow)

		SELF:GridViewVoyages:ExpandMasterRow(SELF:GridViewVoyages:FocusedRowHandle, "Voyage Routing")

		// Locate Active GridViewRoutings
		//LOCAL oView:=(GridView)SELF:GridViewVoyages:GetDetailView(SELF:GridViewVoyages:FocusedRowHandle, 0) AS GridView
		IF oView == NULL
			SELF:VoyageRouting_Refresh()
			SELF:GridViewVoyages:ExpandMasterRow(SELF:GridViewVoyages:FocusedRowHandle, "Voyage Routing")
		ELSE
			oView:Focus()

			LOCAL nFocusedHandle AS INT
			//nFocusedHandle:=oView:LocateByValue(0, oView:Columns["VOYAGE_UID"], Convert.ToInt32(cUID))
			nFocusedHandle:=oView:LocateByDisplayText(0, oView:Columns["ROUTING_UID"], cRoutingUID)
			IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
				RETURN
			ENDIF
			oView:ClearSelection()
			oView:FocusedRowHandle:=nFocusedHandle
			oView:SelectRow(nFocusedHandle)
			SELF:FillDates_Routing(oView)
		ENDIF

	CATCH e AS Exception
		ErrorBox(e:Message)
	END TRY
RETURN


METHOD Voyages_Edit(oRow AS DataRowView, oColumn AS GridColumn) AS VOID
	IF oRow == NULL
		RETURN
	ENDIF

	LOCAL cField := oColumn:FieldName AS STRING
	IF ! InListExact(cField, "VoyageNo", "Description", "CPDate", "Charterers", "Broker", "PortFrom", "PortTo", "Distance", "StartDate", "EndDate", "StartDateGMT", "EndDateGMT", ;
								"uPortFromGMT_DIFF", "uPortToGMT_DIFF", "CostOfBunkersUSD", "CPMinSpeed", "HFOConsumption", "DGFOConsumption", "uType", "LaytimeStartDate", "LaytimeEndDate")
		wb("The column '"+oColumn:Caption+"' is ReadOnly")
		RETURN
	ENDIF

	SELF:oEditColumn := oColumn
	SELF:oEditRow := oRow
	
	IF cField != "Charterers" &&  cField != "Broker"
		SELF:oEditColumn:OptionsColumn:AllowEdit := TRUE
		SELF:GridViewVoyages:OptionsSelection:EnableAppearanceFocusedCell := TRUE
		SELF:GridViewVoyages:ShowEditor()
	ELSE
		SELF:SetCompanyInTableAndField(oRow,"EconVoyages","Voyage_UID",cField)
	ENDIF
	
	
RETURN


METHOD VoyageRouting_Edit(oRow AS DataRowView, oColumn AS GridColumn, oView AS GridView) AS VOID
	IF oRow == NULL
		RETURN
	ENDIF

	LOCAL cField := oColumn:FieldName AS STRING
	IF ! InListExact(cField, "Commenced", "Completed", "CommencedGMT", "CompletedGMT", "ArrivalGMT", "DepartureGMT", "WType", "uRoutingType",;
							 "PortFrom", "PortTo", "Agent" , "Distance", "Deviation", "uPortFromGMT_DIFF", "uPortToGMT_DIFF", ;
						     "WHours","Operation", "CargoDescription", "CargoTons","DA", "DraftFWD_Dec", "DraftAFT_Dec",;
							 "RoutingROB_FO", "ManualROB_FO", "FOPriceUSD", "uCondition", "TCEquivalentUSD",;
							 "ArrHFO", "ArrLFO", "ArrMGO", "DepHFO", "DepLFO", "DepMGO")
		wb("The column '"+oColumn:Caption+"' is ReadOnly")
		RETURN
	ENDIF

	IF cField == "ManualROB_FO" .AND. (oRow:Item["CommencedGMT"]:ToString() == "" .OR. oRow:Item["CompletedGMT"]:ToString() == "")
		ErrorBox("The CommencedGMT/CompletedGMT is not specified", "Editing aborted")
		RETURN
	ENDIF

	SELF:oEditColumn := oColumn
	SELF:oEditRow := oRow

	IF cField == "Agent"
		SELF:SetCompanyInTableAndField(oRow,"EconRoutings","Routing_UID","Agent")
	ELSEIF cField == "Operation"	
		SELF:SetOperationInTableAndField(oRow,"EconRoutings","Routing_UID","Operation")
	ELSE
		SELF:oEditColumn:OptionsColumn:AllowEdit := TRUE
		oView:OptionsSelection:EnableAppearanceFocusedCell := TRUE
		oView:ShowEditor()
	ENDIF
RETURN

METHOD SetCompanyInTableAndField(oRow AS DataRowView,cTable AS STRING,cIUDColumnName AS STRING, cField AS STRING) AS VOID
		LOCAL oSelect_Company := Select_Company{} AS Select_Company
		LOCAL oResult := oSelect_Company:ShowDialog() AS DialogResult
		//MessageBox.Show(oResult:ToString())
		IF oResult == DialogResult.OK
			LOCAL cName := oSelect_Company:cReturnName AS STRING 
			//LOCAL cCompUID := oSelect_Company:cReturnUID AS STRING
			LOCAL cStatement AS STRING
			//MessageBox.Show(cName,cCompUID)
			cStatement:="UPDATE "+cTable+" SET"+;
					" "+cField+"='"+oSoftway:ConvertWildcards(cName, FALSE)+"'"+;
					"  WHERE  "+cIUDColumnName+"="+  oRow:Item[cIUDColumnName]:ToString()
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			SELF:Voyages_Refresh()
		ENDIF	
RETURN

METHOD SetOperationInTableAndField(oRow AS DataRowView,cTable AS STRING,cIUDColumnName AS STRING, cField AS STRING) AS VOID
		LOCAL oSelect_Operation := Select_Operation{} AS Select_Operation
		LOCAL oResult := oSelect_Operation:ShowDialog() AS DialogResult
		//MessageBox.Show(oResult:ToString())
		IF oResult == DialogResult.OK
			LOCAL cName := oSelect_Operation:cReturnName AS STRING 
			//LOCAL cCompUID := oSelect_Operation:cReturnUID AS STRING
			LOCAL cStatement AS STRING
			cStatement:="UPDATE "+cTable+" SET"+;
					" "+cField+"='"+oSoftway:ConvertWildcards(cName, FALSE)+"'"+;
					"  WHERE  "+cIUDColumnName+"="+  oRow:Item[cIUDColumnName]:ToString()
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			SELF:Voyages_Refresh()
		ENDIF	
RETURN

METHOD Voyages_Save(e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs) AS VOID
	IF SELF:LookUpEditCompany_Voyages:Text == ""
		wb("No Voyage selected")
		SELF:LookUpEditCompany_Voyages:Focus()
		RETURN
	ENDIF
	
	LOCAL cVesselUID := SELF:LookUpEditCompany_Voyages:EditValue:ToString() AS STRING

	LOCAL cStatement, cUID, cField, cValue, cDuplicate, cDate AS STRING

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewVoyages:GetRow(e:RowHandle)

	cUID := oRow:Item["VOYAGE_UID"]:ToString()

	cField := e:Column:FieldName
	cValue := e:Value:ToString():Trim()

	// Check Boolean fields
	LOCAL cReplace, cPortUID AS STRING
	LOCAL lStartDateModified, lStartDateGMTModified, lEndDateModified, lEndDateGMTModified AS LOGIC

	cDate := cValue
	IF InListExact(cField, "StartDate", "EndDate", "StartDateGMT", "EndDateGMT", "LaytimeEndDate","LaytimeStartDate")
		// Datetime

		// Check dates
		DO CASE
		CASE cField == "StartDate" .AND. cValue <> "" .AND. oRow:Item["EndDate"]:ToString() <> ""
			IF Convert.ToDatetime(cValue) > Convert.ToDatetime(oRow:Item["EndDate"]:ToString())
				ErrorBox("The StartDate date must be earlier than EndDate date", "Editing aborted")
				SELF:Voyages_Refresh()
				RETURN
			ENDIF
		CASE cField == "EndDate" .AND. cValue <> "" .AND. oRow:Item["StartDate"]:ToString() <> ""
			IF Convert.ToDatetime(cValue) < Convert.ToDatetime(oRow:Item["StartDate"]:ToString())
				ErrorBox("The StartDate date must be earlier than EndDate date", "Editing aborted")
				SELF:Voyages_Refresh()
				RETURN
			ENDIF
		CASE cField == "StartDateGMT" .AND. cValue <> "" .AND. oRow:Item["EndDateGMT"]:ToString() <> ""
			IF Convert.ToDatetime(cValue) > Convert.ToDatetime(oRow:Item["EndDateGMT"]:ToString())
				ErrorBox("The StartDateGMT date must be earlier than EndDateGMT date", "Editing aborted")
				SELF:Voyages_Refresh()
				RETURN
			ENDIF
		CASE cField == "EndDateGMT" .AND. cValue <> "" .AND. oRow:Item["StartDateGMT"]:ToString() <> ""
			IF Convert.ToDatetime(cValue) < Convert.ToDatetime(oRow:Item["StartDateGMT"]:ToString())
				ErrorBox("The StartDateGMT date must be earlier than EndDateGMT date", "Editing aborted")
				SELF:Voyages_Refresh()
				RETURN
			ENDIF
		CASE cField == "LaytimeStartDate" .AND. cValue <> "" .AND. oRow:Item["LaytimeEndDate"]:ToString() <> ""
			IF Convert.ToDatetime(cValue) > Convert.ToDatetime(oRow:Item["LaytimeEndDate"]:ToString())
				ErrorBox("The StartDate date must be earlier than EndDate date", "Editing aborted")
				SELF:Voyages_Refresh()
				RETURN
			ENDIF
		CASE cField == "LaytimeEndDate" .AND. cValue <> "" .AND. oRow:Item["LaytimeStartDate"]:ToString() <> ""
			IF Convert.ToDatetime(cValue) < Convert.ToDatetime(oRow:Item["LaytimeStartDate"]:ToString())
				ErrorBox("The StartDate date must be earlier than EndDate date", "Editing aborted")
				SELF:Voyages_Refresh()
				RETURN
			ENDIF
		ENDCASE

		IF cValue == ""
			cDate := "NULL"
			cValue := "NULL"
		ELSE
			cDate := cValue
			LOCAL cError AS STRING
			IF ! SELF:CheckVoyageDates(oRow, cField, cValue, cError)
				IF cError == NULL
					ErrorBox("The StartDate must be earlier than the EndDate", "Invalid Voyage dates")
				ELSE
					ErrorBox(cError, "Invalid Voyage dates")
				ENDIF
				//SELF:oDTRoutings:Rows:Clear()
				//SELF:oDTVoyages:Rows:Clear()
				SELF:Voyages_Refresh()
				RETURN
			ENDIF
		ENDIF
	ENDIF

	// Validate cValue
	DO CASE
	CASE InListExact(cField, "Description", "Charterers", "Broker") .AND. cValue:Length > 128
		ErrorBox("The field '"+cField+"' must contain up to 128 characters", "Editing aborted")
		SELF:Voyages_Refresh()
		RETURN

	CASE InListExact(cField, "VoyageNo", "Description") .AND. cValue:Length = 0
		ErrorBox("The field '"+cField+"' cannot be empty", "Editing aborted")
		SELF:Voyages_Refresh()
		RETURN

	CASE cField == "Description"
		// Check for duplicates
		cStatement:="SELECT VoyageNo FROM EconVoyages"+oMainForm:cNoLockTerm+;
					" WHERE VOYAGE_UID<>'"+cUID+"'"+;
					" AND Description='"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"+;
					" AND VESSEL_UNIQUEID="+cVesselUID
		cDuplicate:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "VoyageNo")
		IF cDuplicate <> ""
			ErrorBox("The Description '"+cValue+"' is already in use by another VoyageNo='"+cDuplicate+"'", "Editing aborted")
			SELF:Voyages_Refresh()
			RETURN
		ENDIF

	CASE cValue <> "" .AND. InListExact(cField, "VoyageNo") .AND. ! StringIsNumeric(cValue)
		ErrorBox("The field '"+cField+"' must be numeric", "Editing aborted")
		SELF:Voyages_Refresh()
		RETURN

	CASE InListExact(cField, "VoyageNo") .AND. cValue:Length > 5
		ErrorBox("The field '"+cField+"' contain up to 5 characters", "Editing aborted")
		SELF:Voyages_Refresh()
		RETURN

	CASE cField == "uType"
		//wb(cField+"/"+self:cVoyageType)
		// Remove the leading 'u'
		cField := cField:Substring(1)
		DO CASE
		CASE SELF:cVoyageType:ToUpper() == "VOYAGE"
			cReplace := "0"
		CASE SELF:cVoyageType:ToUpper() == "TIME CHARTER"
			cReplace := "1"
		CASE SELF:cVoyageType:ToUpper() == "IDLE" 
			cReplace := "2"
		OTHERWISE
			cReplace := "0"
		ENDCASE
		cStatement:="UPDATE EconVoyages SET"+;
					" "+cField+"="+cReplace+;
					" WHERE  VOYAGE_UID="+cUID
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:Voyages_Refresh()
		RETURN
		//cDone := cField+"="+cReplace

	CASE cField == "VoyageNo"
		// Check for duplicates
		cStatement:="SELECT Description FROM EconVoyages"+oMainForm:cNoLockTerm+;
					" WHERE VOYAGE_UID<>'"+cUID+"'"+;
					" AND VoyageNo="+cValue+;
					" AND VESSEL_UNIQUEID="+cVesselUID
		cDuplicate:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Description")
		IF cDuplicate <> ""
			ErrorBox("The VoyageNo '"+cValue+"' is already in use by another Voyage with Description='"+cDuplicate+"'", "Editing aborted")
			SELF:Voyages_Refresh()
			RETURN
		ENDIF

		/*// Check if Routing exist
		cStatement:="SELECT Count(*) AS nCount FROM EconRoutings"+;
					" WHERE VOYAGE_UID="+cUID
		cDuplicate:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "nCount")
		IF cDuplicate <> "0"
			ErrorBox("The VoyageNo '"+o+"' is already in use by: "+cDuplicate+" Routing(s)", "Editing aborted")
			SELF:Voyages_Refresh()
			RETURN
		ENDIF*/

	CASE cField == "PortFrom"
		cField := "PortFrom_UID"
		IF cValue == ""
			cReplace := "0"
		ELSE
			cStatement:="SELECT PORT_UID FROM VEPorts"+;
						" WHERE Port='"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"
			cReplace := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "PORT_UID")
			IF cReplace == ""
				IF QuestionBox("Do you want to add the Port: ["+cValue+"]"+CRLF+;
								"into the Ports table ?", ;
								"Add Port") == System.Windows.Forms.DialogResult.Yes
					cReplace := oMainForm:AddNewPort(cValue)
				ELSE
					cValue := ""
					cReplace := "0"
				ENDIF
			ELSE
				// Get GMT Diff.
				SELF:DisplayGMT(oRow, cReplace, "PortFrom", "Voyage")
			ENDIF
		ENDIF

	CASE cField == "PortTo"
		cField := "PortTo_UID"
		IF cValue == ""
			cReplace := "0"
		ELSE
			cStatement:="SELECT PORT_UID FROM VEPorts"+;
						" WHERE Port='"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"
			cReplace := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "PORT_UID")
			IF cReplace == ""
				IF QuestionBox("Do you want to add the Port: ["+cValue+"]"+CRLF+;
								"into the Ports table ?", ;
								"Add Port") == System.Windows.Forms.DialogResult.Yes
					cReplace := oMainForm:AddNewPort(cValue)
				ELSE
					cValue := ""
					cReplace := "0"
				ENDIF
			ELSE
				// Get GMT Diff.
				SELF:DisplayGMT(oRow, cReplace, "PortTo", "Voyage")
			ENDIF
		ENDIF

	CASE InListExact(cField, "uPortFromGMT_DIFF")
		// Check Port existence
		cPortUID := oRow:Item["PortFrom_UID"]:ToString()
		IF cPortUID == "0"
			RETURN
		ENDIF

	CASE InListExact(cField, "uPortToGMT_DIFF")
		// Check Port existence
		cPortUID := oRow:Item["PortTo_UID"]:ToString()
		IF cPortUID == "0"
			RETURN
		ENDIF

	CASE cField == "CPDate"
		// Datetime
		IF cValue == ""
			cDate := "NULL"
			cValue := "NULL"
		ELSE
			//cDate := cValue
			cValue := "'"+Datetime.Parse(cValue):ToString("yyyy-MM-dd")+"'"
			//cReplace := cValue
		ENDIF

	CASE cField == "StartDate"
		// Datetime fields
		IF cValue == ""
			cDate := "NULL"
			cReplace := "NULL"
		ELSE
			//cDate := cValue
//wb(cValue, "cValue")
//			cReplace := "'"+Datetime.Parse(cValue):ToString("yyyy-MM-dd HH:mm")+"'"
//wb(cReplace, "cReplace")
			lStartDateModified := TRUE
		ENDIF

	CASE cField == "LaytimeStartDate"
		// Datetime fields
		IF cValue == ""
			cDate := "NULL"
			cReplace := "NULL"
		//ELSE
			//cDate := cValue
//wb(cValue, "cValue")
//			cReplace := "'"+Datetime.Parse(cValue):ToString("yyyy-MM-dd HH:mm")+"'"
//wb(cReplace, "cReplace")
			//lStartDateModified := TRUE
		ENDIF
	CASE cField == "LaytimeEndDate"
		// Datetime fields
		IF cValue == ""
			cDate := "NULL"
			cReplace := "NULL"
		//ELSE
			//cDate := cValue
//wb(cValue, "cValue")
//			cReplace := "'"+Datetime.Parse(cValue):ToString("yyyy-MM-dd HH:mm")+"'"
//wb(cReplace, "cReplace")
			//lStartDateModified := TRUE
		ENDIF

	CASE cField == "StartDateGMT"
		// Datetime fields
		IF cValue == ""
			cDate := "NULL"
			cReplace := "NULL"
		ELSE
			//cDate := cValue
			//cReplace := "'"+Datetime.Parse(cValue):ToString("yyyy-MM-dd HH:mm")+"'"
			lStartDateGMTModified := TRUE
		ENDIF

	CASE cField == "EndDate"
		// Datetime fields
		IF cValue == ""
			cDate := "NULL"
			cReplace := "NULL"
		ELSE
			//cDate := cValue
			//cReplace := "'"+Datetime.Parse(cValue):ToString("yyyy-MM-dd HH:mm")+"'"
			lEndDateModified := TRUE
		ENDIF

	CASE cField == "EndDateGMT"
		// Datetime fields
		IF cValue == ""
			cDate := "NULL"
			cReplace := "NULL"
		ELSE
			//cDate := cValue
			//cReplace := "'"+Datetime.Parse(cValue):ToString("yyyy-MM-dd HH:mm")+"'"
			lEndDateGMTModified := TRUE
		ENDIF
	ENDCASE

	// Update UserVoyages
	//LOCAL cDone := "" AS STRING
	DO CASE
	CASE cField == "uPortFromGMT_DIFF"
		LOCAL cGMT := SELF:GetGMTColumn_Voyage(oRow:Row, "PortFrom") AS STRING
		cField := cGMT
		cValue := SELF:cPortFromGMT_DIFF
		//cValue := ((Decimal)1.0 * Decimal.Round(Convert.ToDecimal(cValue))):ToString()
		LOCAL cOldValue := oRow:Row:Item[cGMT]:ToString():Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".") AS STRING
		IF cOldValue <> "0.0"
			IF QuestionBox("This change will be saved into Ports Table"+CRLF+CRLF+;
							"Do you want to change the Difference from GMT in Hours"+CRLF+"from: "+cOldValue+CRLF+"to: "+cValue+" ?", ;
							"Change +/-GMT") <> System.Windows.Forms.DialogResult.Yes
				RETURN
			ENDIF
		ENDIF
		cStatement:="UPDATE VEPorts SET"+;
					" "+cGMT:Replace("PortFrom", "")+"="+cValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")+;
					" WHERE PORT_UID="+cPortUID
		//cDone := cField+"="+cValue

	CASE cField == "uPortToGMT_DIFF"
		LOCAL cGMT := SELF:GetGMTColumn_Voyage(oRow:Row, "PortTo") AS STRING
		cField := cGMT
		cValue := SELF:cPortToGMT_DIFF
		//cValue := Decimal.Round(Convert.ToDecimal(cValue), 1):ToString()
		LOCAL cOldValue := oRow:Row:Item[cGMT]:ToString():Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".") AS STRING
		IF cOldValue <> "0.0"
			IF QuestionBox("This change will be saved into Ports Table"+CRLF+CRLF+;
							"Do you want to change the Difference from GMT in Hours"+CRLF+"from: "+cOldValue+CRLF+"to: "+cValue+" ?", ;
							"Change +/-GMT") <> System.Windows.Forms.DialogResult.Yes
				RETURN
			ENDIF
		ENDIF
		cStatement:="UPDATE VEPorts SET"+;
					" "+cGMT:Replace("PortTo", "")+"="+cValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")+;
					" WHERE PORT_UID="+cPortUID
		//cDone := cField+"="+cValue

	CASE InListExact(cField, "CPDate", "StartDate", "EndDate", "StartDateGMT", "EndDateGMT", "LaytimeStartDate", "LaytimeEndDate")
		cStatement:="UPDATE EconVoyages"+" SET"+;
					" "+cField+"="+cValue+;
					" WHERE VOYAGE_UID="+cUID
		//cDone := cField+"="+oSoftway:ConvertWildcards(cValue, FALSE)

	CASE InListExact(cField, "CPMinSpeed", "HFOConsumption", "DGFOConsumption")
		// Decimal values
		cStatement:="UPDATE EconVoyages"+" SET"+;
					" "+cField+"="+oMainForm:TextEditValueToSQL(cValue)+;
					" WHERE VOYAGE_UID="+cUID
		//cDone := cField+"="+oMainForm:TextEditValueToSQL(cValue)

	CASE InListExact(cField, "PortFrom_UID", "PortTo_UID")
		cStatement:="UPDATE EconVoyages SET"+;
					" "+cField+"="+cReplace+;
					" WHERE VOYAGE_UID="+cUID
		//IF cField == "PortFrom_UID"
		//	cDone := cField+"="+oRow:Item["PortFrom"]:ToString()
		//ELSE
		//	cDone := cField+"="+oRow:Item["PortTo"]:ToString()
		//ENDIF

	CASE InListExact(cField, "TCEquivalentUSD")
		LOCAL cValue_Dec AS STRING
		IF cValue == ""
			cDate := "NULL"
			cValue_Dec := "NULL"
		ELSE
			cValue_Dec := cValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")
		ENDIF
		cStatement:="UPDATE EconVoyages"+" SET"+;
					" "+cField+"="+cValue_Dec+;
					" WHERE VOYAGE_UID="+cUID
		//cDone := cField+"="+cValue_Dec

	OTHERWISE
		cStatement:="UPDATE EconVoyages"+" SET"+;
					" "+cField+"='"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"+;
					" WHERE VOYAGE_UID="+cUID
		//cDone := cField+"='"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"
	ENDCASE
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:Voyages_Refresh()
		RETURN
	ENDIF

	//IF cDone <> ""
	//	SELF:VoyageLog("Save", cUID, cDone)
	//ENDIF

	IF cField:Contains("GMT_DIFF")
		//Self:Anticipated_Refresh()
		WBTimed{cField+" updated", cField, oUser:nInfoBoxTimer}:ShowDialog(SELF)
	ENDIF

	// Update DataTable and Grid
	//LOCAL oDataRow:=Self:oDTVoyages:Rows:Find(oRow:Item["VOYAGE_UID"]:ToString()) AS DataRow
	LOCAL oDataRow := oRow:Row AS DataRow
	IF oDataRow == NULL
		ErrorBox("Cannot access current row", "Not changed")
		RETURN
	ENDIF

	DO CASE
	CASE InListExact(cField, "CPDate", "StartDate", "EndDate", "StartDateGMT", "EndDateGMT", "LaytimeStartDate", "LaytimeEndDate")
		IF cDate == "NULL"
			oDataRow:Item[cField] := System.DBNull.Value
		ELSE
			oDataRow:Item[cField] := cDate
		ENDIF

	CASE cField == "PortFrom_UID"
		oDataRow:Item["PortFrom"]:=cValue
		oDataRow:Item[cField]:=cReplace
		oDataRow:Item["Distance"] := SELF:UpdateEconRoutingDistance(oDataRow, "EconVoyages", "VOYAGE_UID", cUID)

	CASE cField == "PortTo_UID"
		oDataRow:Item["PortTo"]:=cValue
		oDataRow:Item[cField]:=cReplace
		oDataRow:Item["Distance"] := SELF:UpdateEconRoutingDistance(oDataRow, "EconVoyages", "VOYAGE_UID", cUID)

	CASE cField == "Distance"
		SELF:UpdateEconDistances(oDataRow, cValue)
		oDataRow:Item[cField]:=cValue

	OTHERWISE
		oDataRow:Item[cField] := cValue
	ENDCASE
	SELF:oDTVoyages:AcceptChanges()
	// Invalidates the region occupied by the current View (adds it to the control's update region that will be repainted
	// during the next paint operation), and causes a paint message to be sent to the grid control

	SELF:GridViewVoyages:Invalidate()

	DO CASE
	CASE lStartDateModified
		TRY
			LOCAL cGMTColumn := SELF:GetGMTColumn_Voyage(oRow:Row, "PortFrom") AS STRING
			LOCAL nDiff := Convert.ToDouble(oRow:Item[cGMTColumn]:ToString()) AS Double
			IF nDiff <> (Double)0
				LOCAL dDate := Convert.ToDateTime(e:Value:ToString():Trim()):AddHours(-nDiff) AS DateTime
				cStatement:="UPDATE EconVoyages SET"+;
							" StartDateGMT='"+dDate:ToString("yyyy-MM-dd HH:mm")+"'"+;
							" WHERE VOYAGE_UID="+cUID
				oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				oDataRow:Item["StartDateGMT"] := dDate
			ENDIF
		CATCH
		END TRY

	CASE lStartDateGMTModified
		TRY
			LOCAL cGMTColumn := SELF:GetGMTColumn_Voyage(oRow:Row, "PortFrom") AS STRING
			LOCAL nDiff := Convert.ToDouble(oRow:Item[cGMTColumn]:ToString()) AS Double
			IF nDiff <> (Double)0
				LOCAL dDate := Convert.ToDateTime(e:Value:ToString():Trim()):AddHours(nDiff) AS DateTime
				cStatement:="UPDATE EconVoyages SET"+;
							" StartDate='"+dDate:ToString("yyyy-MM-dd HH:mm")+"'"+;
							" WHERE VOYAGE_UID="+cUID
				oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				oDataRow:Item["StartDate"] := dDate
			ENDIF
		CATCH
		END TRY

	CASE lEndDateModified
		TRY
			LOCAL cGMTColumn := SELF:GetGMTColumn_Voyage(oRow:Row, "PortTo") AS STRING
			LOCAL nDiff := Convert.ToDouble(oRow:Item[cGMTColumn]:ToString()) AS Double
			IF nDiff <> (Double)0
				LOCAL dDate := Convert.ToDateTime(e:Value:ToString():Trim()):AddHours(-nDiff) AS DateTime
				cStatement:="UPDATE EconVoyages SET"+;
							" EndDateGMT='"+dDate:ToString("yyyy-MM-dd HH:mm")+"'"+;
							" WHERE VOYAGE_UID="+cUID
				oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				oDataRow:Item["EndDateGMT"] := dDate
			ENDIF
		CATCH
		END TRY

	CASE lEndDateGMTModified
		TRY
			LOCAL cGMTColumn := SELF:GetGMTColumn_Voyage(oRow:Row, "PortTo") AS STRING
			LOCAL nDiff := Convert.ToDouble(oRow:Item[cGMTColumn]:ToString()) AS Double
			IF nDiff <> (Double)0
				LOCAL dDate := Convert.ToDateTime(e:Value:ToString():Trim()):AddHours(nDiff) AS DateTime
				cStatement:="UPDATE EconVoyages SET"+;
							" EndDate='"+dDate:ToString("yyyy-MM-dd HH:mm")+"'"+;
							" WHERE VOYAGE_UID="+cUID
				oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				oDataRow:Item["EndDate"] := dDate
			ENDIF
		CATCH
		END TRY
	ENDCASE

	// User:
	cStatement:="UPDATE EconVoyages SET"+;
				" USER_UNIQUEID="+oUser:USER_UNIQUEID+;
				" WHERE VOYAGE_UID="+cUID
	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
	oDataRow:Item["UserName"] := oUser:UserName
RETURN

//	Antonis 1.12.14 So we are able to put dates to Sub Voyages	//

METHOD CheckVoyageDates(oRow AS DataRowView, cField AS STRING, cValue REF STRING, cError REF STRING) AS LOGIC
	LOCAL dDate := Convert.ToDatetime(cValue) AS DateTime
	LOCAL dDateCheck AS DateTime
	LOCAL cStatement AS STRING
	LOCAL oDataRow := oRow:Row AS DataRow

	IF oDataRow <> NULL
	LOCAL cVesselUID := SELF:LookUpEditCompany_Voyages:EditValue:ToString() AS STRING

		LOCAL cTCextraSQL_Voyage := " " AS STRING
		IF SELF:lisTC
			cTCextraSQL_Voyage := " AND VOYAGE_UID <>"+ SELF:cTCParent+" "
			//ELSE
			//	cTCextraSQL_Voyage := " AND EconVoyages.VOYAGE_UID  NOT IN ( SELECT VOYAGE_UID FROM FMVoyageLinks ) "
		ENDIF

		DO CASE
		CASE cField == "StartDate"
			IF oDataRow:Item["EndDate"]:ToString() <> ""
				dDateCheck := Convert.ToDatetime(oDataRow:Item["EndDate"]:ToString())
				IF dDateCheck <= dDate
					RETURN FALSE
				ENDIF
			ENDIF			

			// Check Voyages
			cStatement:="SELECT VoyageNo FROM EconVoyages"+oMainForm:cNoLockTerm+;
						" WHERE '"+dDate:ToString("yyyy-MM-dd HH:mm:ss")+"' BETWEEN StartDate AND EndDate"+;
						" AND VOYAGE_UID <> "+oDataRow:Item["VOYAGE_UID"]:ToString()+cTCextraSQL_Voyage+;
						" AND VESSEL_UNIQUEID="+cVesselUID
						//" WHERE StartDate BETWEEN '"+dDate:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dDateCheck:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
						//" OR EndDate BETWEEN '"+dDate:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dDateCheck:ToString("yyyy-MM-dd HH:mm:ss")+"'"
			LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			IF oDT:Rows:Count > 0
				cError := "The Date: "+dDate:ToString("dd-MM-yyyy HH:mm:ss")+CRLF+;
							"is contained into the VoyageNo: "+oDT:Rows[0]:Item["VoyageNo"]:ToString()
				RETURN FALSE
			ENDIF

		CASE cField == "EndDate"
			IF oDataRow:Item["StartDate"]:ToString() <> ""
				dDateCheck := Convert.ToDatetime(oDataRow:Item["StartDate"]:ToString())
				IF dDateCheck >= dDate
					RETURN FALSE
				ENDIF
			ENDIF
			// Check Voyages
			cStatement:="SELECT VoyageNo FROM EconVoyages"+oMainForm:cNoLockTerm+;
						" WHERE '"+dDate:ToString("yyyy-MM-dd HH:mm:ss")+"' BETWEEN StartDate AND EndDate"+;
						" AND VOYAGE_UID <> "+oDataRow:Item["VOYAGE_UID"]:ToString()+cTCextraSQL_Voyage+;
						" AND VESSEL_UNIQUEID="+cVesselUID
						//" WHERE StartDate BETWEEN '"+dDate:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dDateCheck:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
						//" OR EndDate BETWEEN '"+dDate:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dDateCheck:ToString("yyyy-MM-dd HH:mm:ss")+"'"
			LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			IF oDT:Rows:Count > 0
				cError := "The Date: "+dDate:ToString("dd-MM-yyyy HH:mm:ss")+CRLF+;
							"is contained into the VoyageNo: "+oDT:Rows[0]:Item["VoyageNo"]:ToString()
				RETURN FALSE
			ENDIF


		CASE cField == "StartDateGMT"
			IF oDataRow:Item["EndDateGMT"]:ToString() <> ""
				dDateCheck := Convert.ToDatetime(oDataRow:Item["EndDateGMT"]:ToString())
				IF dDateCheck <= dDate
					RETURN FALSE
				ENDIF
			ENDIF

			// Check Voyages
			cStatement:="SELECT VoyageNo FROM EconVoyages"+oMainForm:cNoLockTerm+;
						" WHERE '"+dDate:ToString("yyyy-MM-dd HH:mm:ss")+"' BETWEEN StartDateGMT AND EndDateGMT"+;
						" AND VOYAGE_UID <> "+oDataRow:Item["VOYAGE_UID"]:ToString()+cTCextraSQL_Voyage+;
						" AND VESSEL_UNIQUEID="+cVesselUID
						//" WHERE StartDate BETWEEN '"+dDate:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dDateCheck:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
						//" OR EndDate BETWEEN '"+dDate:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dDateCheck:ToString("yyyy-MM-dd HH:mm:ss")+"'"
			LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			IF oDT:Rows:Count > 0
				cError := "The Date: "+dDate:ToString("dd-MM-yyyy HH:mm:ss")+CRLF+;
							"is contained into the VoyageNo: "+oDT:Rows[0]:Item["VoyageNo"]:ToString()
				RETURN FALSE
			ENDIF

		CASE cField == "EndDateGMT"
			IF oDataRow:Item["StartDateGMT"]:ToString() <> ""
				dDateCheck := Convert.ToDatetime(oDataRow:Item["StartDateGMT"]:ToString())
				IF dDateCheck >= dDate
					RETURN FALSE
				ENDIF
			ENDIF
			// Check Voyages
			cStatement:="SELECT VoyageNo FROM EconVoyages"+oMainForm:cNoLockTerm+;
						" WHERE '"+dDate:ToString("yyyy-MM-dd HH:mm:ss")+"' BETWEEN StartDateGMT AND EndDateGMT"+;
						" AND VOYAGE_UID <> "+oDataRow:Item["VOYAGE_UID"]:ToString()+cTCextraSQL_Voyage+;
						" AND VESSEL_UNIQUEID="+cVesselUID
						//" WHERE StartDate BETWEEN '"+dDate:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dDateCheck:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
						//" OR EndDate BETWEEN '"+dDate:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dDateCheck:ToString("yyyy-MM-dd HH:mm:ss")+"'"
			LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			IF oDT:Rows:Count > 0
				cError := "The Date: "+dDate:ToString("dd-MM-yyyy HH:mm:ss")+CRLF+;
							"is contained into the VoyageNo: "+oDT:Rows[0]:Item["VoyageNo"]:ToString()
				RETURN FALSE
			ENDIF


		CASE cField == "Commenced"
			IF oDataRow:Item["Completed"]:ToString() <> ""
				dDateCheck := Convert.ToDatetime(oDataRow:Item["Completed"]:ToString())
				IF dDateCheck <= dDate
					RETURN FALSE
				ENDIF
			ENDIF
			// Check EconRoutings
			cStatement:="SELECT EconRoutings.PortFrom_UID FROM EconRoutings"+oMainForm:cNoLockTerm+;
						" INNER JOIN EconVoyages ON EconVoyages.VOYAGE_UID=EconRoutings.VOYAGE_UID"+;
						"	AND EconVoyages.VESSEL_UNIQUEID="+cVesselUID+;
						" WHERE '"+dDate:ToString("yyyy-MM-dd HH:mm:ss")+"' BETWEEN EconRoutings.Commenced AND EconRoutings.Completed"+;
						" AND EconRoutings.VOYAGE_UID <> "+oDataRow:Item["VOYAGE_UID"]:ToString()+cTCextraSQL_Voyage
			LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			IF oDT:Rows:Count > 0
				//cError := "The Date: "+dDate:ToString("dd-MM-yyyy HH:mm:ss")+CRLF+;
				//			"is used by another Routing of this Voyage"
				cError := "The Date: "+dDate:ToString("dd-MM-yyyy HH:mm:ss")+CRLF+;
							"is contained into the VoyageNo: "+oDT:Rows[0]:Item["VoyageNo"]:ToString()
				RETURN FALSE
			ENDIF

		CASE cField == "Completed"
			IF oDataRow:Item["Commenced"]:ToString() <> ""
				dDateCheck := Convert.ToDatetime(oDataRow:Item["Commenced"]:ToString())
				IF dDateCheck >= dDate
					RETURN FALSE
				ENDIF
			ENDIF
			// Check EconRoutings
			cStatement:="SELECT EconRoutings.PortFrom_UID FROM EconRoutings"+oMainForm:cNoLockTerm+;
						" INNER JOIN EconVoyages ON EconVoyages.VOYAGE_UID=EconRoutings.VOYAGE_UID"+;
						"	AND EconVoyages.VESSEL_UNIQUEID="+cVesselUID+;
						" WHERE '"+dDate:ToString("yyyy-MM-dd HH:mm:ss")+"' BETWEEN EconRoutings.Commenced AND EconRoutings.Completed"+;
						" AND EconRoutings.VOYAGE_UID <>"+oDataRow:Item["VOYAGE_UID"]:ToString()+cTCextraSQL_Voyage
			LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			IF oDT:Rows:Count > 0
				//cError := "The Date: "+dDate:ToString("dd-MM-yyyy HH:mm:ss")+CRLF+;
				//			"is used by another Routing of this Voyage"
				cError := "The Date: "+dDate:ToString("dd-MM-yyyy HH:mm:ss")+CRLF+;
							"is contained into the VoyageNo: "+oDT:Rows[0]:Item["VoyageNo"]:ToString()
				RETURN FALSE
			ENDIF


		CASE cField == "CommencedGMT"
			IF oDataRow:Item["CompletedGMT"]:ToString() <> ""
				dDateCheck := Convert.ToDatetime(oDataRow:Item["CompletedGMT"]:ToString())
				IF dDateCheck <= dDate
					RETURN FALSE
				ENDIF
			ENDIF
			// Check EconRoutings
			cStatement:="SELECT EconRoutings.PortFrom_UID FROM EconRoutings"+oMainForm:cNoLockTerm+;
						" INNER JOIN EconVoyages ON EconVoyages.VOYAGE_UID=EconRoutings.VOYAGE_UID"+;
						"	AND EconVoyages.VESSEL_UNIQUEID="+cVesselUID+;
						" WHERE '"+dDate:ToString("yyyy-MM-dd HH:mm:ss")+"' BETWEEN EconRoutings.CommencedGMT AND EconRoutings.CompletedGMT"+;
						" AND EconRoutings.VOYAGE_UID <>"+oDataRow:Item["VOYAGE_UID"]:ToString()+cTCextraSQL_Voyage
			LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			IF oDT:Rows:Count > 0
				//cError := "The Date: "+dDate:ToString("dd-MM-yyyy HH:mm:ss")+CRLF+;
				//			"is used by another Routing of this Voyage"
				cError := "The Date: "+dDate:ToString("dd-MM-yyyy HH:mm:ss")+CRLF+;
							"is contained into the VoyageNo: "+oDT:Rows[0]:Item["VoyageNo"]:ToString()
				RETURN FALSE
			ENDIF

		CASE cField == "CompletedGMT"
			IF oDataRow:Item["CommencedGMT"]:ToString() <> ""
				dDateCheck := Convert.ToDatetime(oDataRow:Item["CommencedGMT"]:ToString())
				IF dDateCheck >= dDate
					RETURN FALSE
				ENDIF
			ENDIF
			// Check EconRoutings
			cStatement:="SELECT EconRoutings.PortFrom_UID FROM EconRoutings"+oMainForm:cNoLockTerm+;
						" INNER JOIN EconVoyages ON EconVoyages.VOYAGE_UID=EconRoutings.VOYAGE_UID"+;
						"	AND EconVoyages.VESSEL_UNIQUEID="+cVesselUID+;
						" WHERE '"+dDate:ToString("yyyy-MM-dd HH:mm:ss")+"' BETWEEN EconRoutings.CommencedGMT AND EconRoutings.CompletedGMT"+;
						" AND EconRoutings.VOYAGE_UID <>"+oDataRow:Item["VOYAGE_UID"]:ToString()+cTCextraSQL_Voyage
			LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			IF oDT:Rows:Count > 0
				//cError := "The Date: "+dDate:ToString("dd-MM-yyyy HH:mm:ss")+CRLF+;
				//			"is used by another Routing of this Voyage"
				cError := "The Date: "+dDate:ToString("dd-MM-yyyy HH:mm:ss")+CRLF+;
							"is contained into the VoyageNo: "+oDT:Rows[0]:Item["VoyageNo"]:ToString()
				RETURN FALSE
			ENDIF
		ENDCASE
	ENDIF
	cValue := "'"+dDate:ToString("yyyy-MM-dd HH:mm:ss")+"'"
RETURN TRUE


METHOD VoyageRouting_Save(e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs, oView AS GridView) AS LOGIC
	IF SELF:LookUpEditCompany_Voyages:Text == ""
		wb("No Voyage selected")
		SELF:LookUpEditCompany_Voyages:Focus()
		RETURN TRUE
	ENDIF
	
	LOCAL cStatement, cUID, cField, cValue, cDate AS STRING

	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)oView:GetRow(e:RowHandle)

	cUID := oRow:Item["ROUTING_UID"]:ToString()

	cField := e:Column:FieldName
	cValue := e:Value:ToString():Trim()

	cDate := cValue
	IF InListExact(cField, "Commenced", "Completed", "CommencedGMT", "CompletedGMT", "ArrivalGMT", "DepartureGMT")
		// Datetime
		// Check dates
		DO CASE
		CASE cField == "Commenced" .AND. cValue <> "" .AND. oRow:Item["Completed"]:ToString() <> ""
			IF Convert.ToDatetime(cValue) > Convert.ToDatetime(oRow:Item["Completed"]:ToString())
				ErrorBox("The Commenced date must be earlier than Completed date", "Editing aborted")
				SELF:VoyageRouting_Refresh()
				RETURN FALSE
			ENDIF
		CASE cField == "Completed" .AND. cValue <> "" .AND. oRow:Item["Commenced"]:ToString() <> ""
			IF Convert.ToDatetime(cValue) < Convert.ToDatetime(oRow:Item["Commenced"]:ToString())
				ErrorBox("The Commenced date must be earlier than Completed date", "Editing aborted")
				SELF:VoyageRouting_Refresh()
				RETURN FALSE
			ENDIF
		CASE cField == "CommencedGMT" .AND. cValue <> "" .AND. oRow:Item["CompletedGMT"]:ToString() <> ""
			IF Convert.ToDatetime(cValue) > Convert.ToDatetime(oRow:Item["CompletedGMT"]:ToString())
				ErrorBox("The CommencedGMT date must be earlier than CompletedGMT date", "Editing aborted")
				SELF:VoyageRouting_Refresh()
				RETURN FALSE
			ENDIF
		CASE cField == "CompletedGMT" .AND. cValue <> "" .AND. oRow:Item["CommencedGMT"]:ToString() <> ""
			IF Convert.ToDatetime(cValue) < Convert.ToDatetime(oRow:Item["CommencedGMT"]:ToString())
				ErrorBox("The CommencedGMT date must be earlier than CompletedGMT date", "Editing aborted")
				SELF:VoyageRouting_Refresh()
				RETURN FALSE
			ENDIF
		CASE cField == "ArrivalGMT" .AND. cValue <> "" .AND. oRow:Item["DepartureGMT"]:ToString() <> ""
			IF Convert.ToDatetime(cValue) > Convert.ToDatetime(oRow:Item["DepartureGMT"]:ToString())
				ErrorBox("The ArrivalGMT date must be earlier than DepartureGMT date", "Editing aborted")
				SELF:VoyageRouting_Refresh()
				RETURN FALSE
			ENDIF
		CASE cField == "DepartureGMT" .AND. cValue <> "" .AND. oRow:Item["ArrivalGMT"]:ToString() <> ""
			IF Convert.ToDatetime(cValue) < Convert.ToDatetime(oRow:Item["ArrivalGMT"]:ToString())
				ErrorBox("The DepartureGMT date must be later than ArrivalGMT date", "Editing aborted")
				SELF:VoyageRouting_Refresh()
				RETURN FALSE
			ENDIF
		ENDCASE

		IF cValue == ""
			cDate := "NULL"
			cValue := "NULL"
		ELSE
			cDate := cValue
			LOCAL cError AS STRING
			IF ! SELF:CheckVoyageDates(oRow, cField, cValue, cError)
				IF cError == NULL
					ErrorBox("The Commenced must be earlier than the Completed", "Invalid Voyage dates")
				ELSE
					ErrorBox(cError, "Invalid Voyage dates")
				ENDIF
				SELF:oDTVoyages:Rows:Clear()
				SELF:oDTRoutings:Rows:Clear()
				SELF:VoyageRouting_Refresh()
				//SELF:Voyages_Refresh()
				RETURN FALSE
			ENDIF
			//cValue := "'"+Convert.ToDatetime(cValue):ToString("yyyy-MM-dd")+"'"
		ENDIF
	ENDIF

	// Validate cValue
	LOCAL cReplace, cPortUID AS STRING
	LOCAL lCommencedModified, lCommencedGMTModified, lCompletedModified, lCompletedGMTModified AS LOGIC

	DO CASE
	CASE InListExact(cField, "PortFrom", "PortTo", "CargoDescription") .AND. cValue:Length > 128
		ErrorBox("The field '"+cField+"' must contain up to 128 characters", "Editing aborted")
		SELF:oDTVoyages:Rows:Clear()
		SELF:oDTRoutings:Rows:Clear()
		SELF:VoyageRouting_Refresh()
		//SELF:GetOldValue_Routings(cField, cValue)
		//SELF:VoyageRouting_Refresh()
		RETURN FALSE

	CASE InListExact(cField, "PortFrom", "PortTo", "CargoDescription") .AND. cValue:Length = 0
		ErrorBox("The field '"+cField+"' cannot be empty", "Editing aborted")
		SELF:oDTVoyages:Rows:Clear()
		SELF:oDTRoutings:Rows:Clear()
		SELF:VoyageRouting_Refresh()
		//SELF:GetOldValue_Routings(cField, cValue)
		//SELF:VoyageRouting_Refresh()
		RETURN FALSE

	CASE cField == "PortFrom"
		cField := "PortFrom_UID"
		IF cValue == ""
			cReplace := "0"
		ELSE
			cStatement:="SELECT PORT_UID FROM VEPorts"+;
						" WHERE Port='"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"
			cReplace := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "PORT_UID")
			IF cReplace == ""
				IF QuestionBox("Do you want to add the Port: ["+cValue+"]"+CRLF+;
								"into the Ports table ?", ;
								"Add Port") == System.Windows.Forms.DialogResult.Yes
					cReplace := oMainForm:AddNewPort(cValue)
				ELSE
					cValue := ""
					cReplace := "0"
				ENDIF
			ELSE
				// Get GMT Diff.
				SELF:DisplayGMT(oRow, cReplace, "PortFrom", "Routing")
			ENDIF
		ENDIF

	CASE cField == "PortTo"
		cField := "PortTo_UID"
		IF cValue == ""
			cReplace := "0"
		ELSE
			cStatement:="SELECT PORT_UID FROM VEPorts"+;
						" WHERE Port='"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"
			cReplace := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "PORT_UID")
			IF cReplace == ""
				IF QuestionBox("Do you want to add the Port: ["+cValue+"]"+CRLF+;
								"into the Ports table ?", ;
								"Add Port") == System.Windows.Forms.DialogResult.Yes
					cReplace := oMainForm:AddNewPort(cValue)
				ELSE
					cValue := ""
					cReplace := "0"
				ENDIF
			ELSE
				// Get GMT Diff.
				SELF:DisplayGMT(oRow, cReplace, "PortTo", "Routing")
			ENDIF
		ENDIF

	CASE InListExact(cField, "uPortFromGMT_DIFF")
		// Check Port existence
		cPortUID := oRow:Item["PortFrom_UID"]:ToString()
		IF cPortUID == "0"
			RETURN FALSE
		ENDIF

	CASE InListExact(cField, "uPortToGMT_DIFF")
		// Check Port existence
		cPortUID := oRow:Item["PortTo_UID"]:ToString()
		IF cPortUID == "0"
			RETURN FALSE
		ENDIF

	CASE cField == "Commenced"
		// Datetime fields
		IF cValue == ""
			cDate := "NULL"
			cReplace := "NULL"
		ELSE
			//cReplace := "'"+Convert.ToDatetime(cValue):ToString("yyyy-MM-dd HH:mm")+"'"
			lCommencedModified := TRUE
		ENDIF

	CASE cField == "CommencedGMT"
		// Datetime fields
		IF cValue == ""
			cDate := "NULL"
			cReplace := "NULL"
		ELSE
			//cReplace := "'"+Convert.ToDatetime(cValue):ToString("yyyy-MM-dd HH:mm")+"'"
			lCommencedGMTModified := TRUE
		ENDIF

	CASE cField == "Completed"
		// Datetime fields
		IF cValue == ""
			cDate := "NULL"
			cReplace := "NULL"
		ELSE
			//cReplace := "'"+Convert.ToDatetime(cValue):ToString("yyyy-MM-dd HH:mm")+"'"
			lCompletedModified := TRUE
		ENDIF

	CASE cField == "CompletedGMT"
		// Datetime fields
		IF cValue == ""
			cDate := "NULL"
			cReplace := "NULL"
		ELSE
			//cReplace := "'"+Convert.ToDatetime(cValue):ToString("yyyy-MM-dd HH:mm")+"'"
			lCompletedGMTModified := TRUE
		ENDIF
		
	CASE cField == "ArrivalGMT"
		// Datetime fields
		IF cValue == ""
			cDate := "NULL"
			cReplace := "NULL"
		ELSE
			//cReplace := "'"+Convert.ToDatetime(cValue):ToString("yyyy-MM-dd HH:mm")+"'"
			lCompletedGMTModified := TRUE
		ENDIF
	CASE cField == "DepartureGMT"
		// Datetime fields
		IF cValue == ""
			cDate := "NULL"
			cReplace := "NULL"
		ELSE
			//cReplace := "'"+Convert.ToDatetime(cValue):ToString("yyyy-MM-dd HH:mm")+"'"
			lCompletedGMTModified := TRUE
		ENDIF
	ENDCASE

	// Update
	//LOCAL cDone := "" AS STRING
	DO CASE
	CASE cField == "uPortFromGMT_DIFF"
		LOCAL cGMT := SELF:GetGMTColumn_Routing(oRow:Row, "PortFrom") AS STRING
		cField := cGMT
		cValue := SELF:cPortFromGMT_DIFF
		//cValue := ((Decimal)1.0 * Decimal.Round(Convert.ToDecimal(cValue))):ToString()
		LOCAL cOldValue := oRow:Row:Item[cGMT]:ToString():Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".") AS STRING
		IF cOldValue <> "0.0"
			IF QuestionBox("This change will be saved into Ports Table"+CRLF+CRLF+;
							"Do you want to change the Difference from GMT in Hours"+CRLF+"from: "+cOldValue+CRLF+"to: "+cValue+" ?", ;
							"Change +/-GMT") <> System.Windows.Forms.DialogResult.Yes
				RETURN FALSE
			ENDIF
		ENDIF
		cStatement:="UPDATE VEPorts SET"+;
					" "+cGMT:Replace("PortFrom", "")+"="+cValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")+;
					" WHERE PORT_UID="+cPortUID
		//cDone := cField+"="+cValue

	CASE cField == "uPortToGMT_DIFF"
		LOCAL cGMT := SELF:GetGMTColumn_Routing(oRow:Row, "PortTo") AS STRING
		cField := cGMT
		cValue := SELF:cPortToGMT_DIFF
		//cValue := Decimal.Round(Convert.ToDecimal(cValue), 1):ToString()
		LOCAL cOldValue := oRow:Row:Item[cGMT]:ToString():Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".") AS STRING
		IF cOldValue <> "0.0"
			IF QuestionBox("This change will be saved into Ports Table"+CRLF+CRLF+;
							"Do you want to change the Difference from GMT in Hours"+CRLF+"from: "+cOldValue+CRLF+"to: "+cValue+" ?", ;
							"Change +/-GMT") <> System.Windows.Forms.DialogResult.Yes
				RETURN FALSE
			ENDIF
		ENDIF
		cStatement:="UPDATE VEPorts SET"+;
					" "+cGMT:Replace("PortTo", "")+"="+cValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")+;
					" WHERE PORT_UID="+cPortUID
		//cDone := cField+"="+cValue

	CASE InListExact(cField, "Commenced", "Completed", "CommencedGMT", "CompletedGMT","ArrivalGMT", "DepartureGMT")
		cStatement:="UPDATE EconRoutings"+" SET"+;
					" "+cField+"="+cValue+;
					" WHERE ROUTING_UID="+cUID
		//cDone := cField+"="+oSoftway:ConvertWildcards(cValue, FALSE)

	//CASE InListExact(cField, "CPMinSpeed", "HFOConsumption", "DGFOConsumption")
	//	// Decimal values
	//	cStatement:="UPDATE EconRoutings"+" SET"+;
	//				" "+cField+"="+oMainForm:TextEditValueToSQL(cValue)+;
	//				" WHERE ROUTING_UID="+cUID

	CASE InListExact(cField, "PortFrom_UID", "PortTo_UID")
		cStatement:="UPDATE EconRoutings SET"+;
					" "+cField+"="+cReplace+;
					" WHERE ROUTING_UID="+cUID
		//IF cField == "PortFrom_UID"
		//	cDone := cField+"="+oRow:Item["PortFrom"]:ToString()
		//ELSE
		//	cDone := cField+"="+oRow:Item["PortTo"]:ToString()
		//ENDIF

	CASE InListExact(cField, "DraftFWD_Dec", "DraftAFT_Dec", "RoutingROB_FO", "ManualROB_FO", "FOPriceUSD")
		LOCAL cValue_Dec AS STRING
		IF cValue == ""
			cDate := "NULL"
			cValue_Dec := "NULL"
		ELSE
			cValue_Dec := cValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")
		ENDIF
		cStatement:="UPDATE EconRoutings"+" SET"+;
					" "+cField+"="+cValue_Dec+;
					" WHERE ROUTING_UID="+cUID
		//cDone := cField+"="+cValue_Dec
	CASE InListExact(cField, "ArrHFO", "ArrLFO", "ArrMGO", "DepHFO","DepLFO", "DepMGO")
		LOCAL cValue_Dec AS STRING
		IF cValue == ""
			cValue_Dec := "0"
		ELSE
			cValue_Dec := cValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")
		ENDIF
		
		DO CASE
			CASE cField=="ArrHFO"
				cReplace := "Arrival_HFO"
			CASE cField=="ArrLFO"
				cReplace := "Arrival_LFO"
			CASE cField=="ArrMGO"
				cReplace := "Arrival_MGO"

			CASE cField=="DepHFO"
				cReplace := "Departure_HFO"
			CASE cField=="DepLFO"
				cReplace := "Departure_LFO"
			CASE cField=="DepMGO"
				cReplace := "Departure_MGO"	
		END CASE		
		
		cStatement:="SELECT AdditionalData_UID FROM FMRoutingAdditionalData"+;
						" WHERE Routing_UID="+cUID
		LOCAL cAdditionalData_UID := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "AdditionalData_UID") AS STRING
		
		IF cAdditionalData_UID == ""

			cStatement:=" INSERT INTO FMRoutingAdditionalData (Routing_UID,"+cReplace+",Update_User,Update_Date ) VALUES"+;
						" ("+cUID+","+cValue_Dec+", "+oUser:USER_UNIQUEID+", CURRENT_TIMESTAMP )"
				
		ELSE
			cStatement:=" UPDATE FMRoutingAdditionalData SET "+;
						" "+cReplace+"="+cValue_Dec+;
						" WHERE ROUTING_UID="+cUID
		ENDIF


		

	CASE cField == "uCondition"
//		ucField := cField
		// Remove the leading 'u'
		cField := cField:Substring(1)
		DO CASE
		CASE SELF:cCondition == "Ballast"
			cReplace := "1"
		CASE SELF:cCondition == "Laden"
			cReplace := "2"
		CASE SELF:cCondition == "Loading"
			cReplace := "3"
		CASE SELF:cCondition == "Discharging"
			cReplace := "4"
		CASE SELF:cCondition == "Idle"
			cReplace := "5"
		ENDCASE
		cStatement:="UPDATE EconRoutings SET"+;
					" "+cField+"="+cReplace+;
					" WHERE ROUTING_UID="+cUID
		//cDone := cField+"="+cReplace

	//CASE InListExact(cField, "TCEquivalentUSD")
	//	LOCAL cValue_Dec AS STRING
	//	IF cValue == ""
	//		cDate := "NULL"
	//		cValue_Dec := "NULL"
	//	ELSE
	//		cValue_Dec := cValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")
	//	ENDIF
	//	cStatement:="UPDATE EconRoutings"+" SET"+;
	//				" "+cField+"="+cValue_Dec+;
	//				" WHERE ROUTING_UID="+cUID
	//	cDone := cField+"="+cValue_Dec

	OTHERWISE
		cStatement:="UPDATE EconRoutings"+" SET"+;
					" "+cField+"='"+oSoftway:ConvertWildcards(cValue, FALSE)+"'"+;
					" WHERE ROUTING_UID="+cUID
		//cDone := cField+"="+oSoftway:ConvertWildcards(cValue, FALSE)
	ENDCASE
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		//SELF:VoyageRouting_Refresh()
		RETURN TRUE
	ENDIF

	//IF cDone <> ""
	//	SELF:RoutingLog("Save", cUID, cDone)
	//ENDIF

	IF cField:Contains("GMT_DIFF")
		//Self:Anticipated_Refresh()
		WBTimed{cField+" updated", cField, oUser:nInfoBoxTimer}:ShowDialog(SELF)
	ENDIF

	// Update DataTable and Grid
//	LOCAL oDataRow:=Self:oDTRoutings:Rows:Find(oRow:Item["ROUTING_UID"]:ToString()) AS DataRow
	LOCAL oDataRow := oRow:Row AS DataRow
	IF oDataRow == NULL
		ErrorBox("Cannot access current row", "Not changed")
		RETURN TRUE
	ENDIF

	DO CASE
	CASE InListExact(cField, "Commenced", "Completed", "CommencedGMT", "CompletedGMT", "CPDate", "ArrivalGMT", "DepartureGMT")
		IF cDate == "NULL"
			oDataRow:Item[cField] := System.DBNull.Value
		ELSE
			oDataRow:Item[cField] := cDate
		ENDIF

	CASE cField == "PortFrom_UID"
		oDataRow:Item["PortFrom"]:=cValue
		oDataRow:Item[cField]:=cReplace
		oDataRow:Item["Distance"] := SELF:UpdateEconRoutingDistance(oDataRow, "EconRoutings", "ROUTING_UID", cUID)

	CASE cField == "PortTo_UID"
		oDataRow:Item["PortTo"]:=cValue
		oDataRow:Item[cField]:=cReplace
		oDataRow:Item["Distance"] := SELF:UpdateEconRoutingDistance(oDataRow, "EconRoutings", "ROUTING_UID", cUID)

	CASE cField == "Distance"
		SELF:UpdateEconDistances(oDataRow, cValue)
		oDataRow:Item[cField]:=cValue

	CASE InListExact(cField, "Condition")
		//wb(oDataRow:Item[cField], cReplace)
		oDataRow:Item[cField] := cReplace	//:Replace("'", "")

	OTHERWISE
		oDataRow:Item[cField] := cValue
	ENDCASE
	SELF:oDTRoutings:AcceptChanges()
	// Invalidates the region occupied by the current View (adds it to the control's update region that will be repainted
	// during the next paint operation), and causes a paint message to be sent to the grid control

	oView:Invalidate()

	// User:
	cStatement:="UPDATE EconRoutings SET"+;
				" USER_UNIQUEID="+oUser:USER_UNIQUEID+;
				" WHERE ROUTING_UID="+cUID
	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
	oDataRow:Item["UserName"] := oUser:UserName

	DO CASE
	CASE lCommencedModified
		TRY
			LOCAL cGMTColumn := SELF:GetGMTColumn_Routing(oRow:Row, "PortFrom") AS STRING
			LOCAL nDiff := Convert.ToDouble(oRow:Item[cGMTColumn]:ToString()) AS Double
			IF nDiff <> (Double)0
				LOCAL dDate := Convert.ToDateTime(e:Value:ToString():Trim()):AddHours(-nDiff) AS DateTime
				cStatement:="UPDATE EconRoutings SET"+;
							" CommencedGMT='"+dDate:ToString("yyyy-MM-dd HH:mm")+"'"+;
							" WHERE ROUTING_UID="+cUID
				oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				oDataRow:Item["CommencedGMT"] := dDate
			ENDIF
		CATCH
		END TRY

	CASE lCommencedGMTModified
		TRY
			LOCAL cGMTColumn := SELF:GetGMTColumn_Routing(oRow:Row, "PortFrom") AS STRING
			LOCAL nDiff := Convert.ToDouble(oRow:Item[cGMTColumn]:ToString()) AS Double
			IF nDiff <> (Double)0
				LOCAL dDate := Convert.ToDateTime(e:Value:ToString():Trim()):AddHours(nDiff) AS DateTime
				cStatement:="UPDATE EconRoutings SET"+;
							" Commenced='"+dDate:ToString("yyyy-MM-dd HH:mm")+"'"+;
							" WHERE ROUTING_UID="+cUID
				oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				oDataRow:Item["Commenced"] := dDate
			ENDIF
		CATCH
		END TRY

	CASE lCompletedModified
		TRY
			LOCAL cGMTColumn := SELF:GetGMTColumn_Routing(oRow:Row, "PortTo") AS STRING
			LOCAL nDiff := Convert.ToDouble(oRow:Item[cGMTColumn]:ToString()) AS Double
			IF nDiff <> (Double)0
				LOCAL dDate := Convert.ToDateTime(e:Value:ToString():Trim()):AddHours(-nDiff) AS DateTime
				cStatement:="UPDATE EconRoutings SET"+;
							" CompletedGMT='"+dDate:ToString("yyyy-MM-dd HH:mm")+"'"+;
							" WHERE ROUTING_UID="+cUID
				oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				oDataRow:Item["CompletedGMT"] := dDate
			ENDIF
		CATCH
		END TRY

	CASE lCompletedGMTModified
		TRY
			LOCAL cGMTColumn := SELF:GetGMTColumn_Routing(oRow:Row, "PortTo") AS STRING
			LOCAL nDiff := Convert.ToDouble(oRow:Item[cGMTColumn]:ToString()) AS Double
			IF nDiff <> (Double)0
				LOCAL dDate := Convert.ToDateTime(e:Value:ToString():Trim()):AddHours(nDiff) AS DateTime
				cStatement:="UPDATE EconRoutings SET"+;
							" Completed='"+dDate:ToString("yyyy-MM-dd HH:mm")+"'"+;
							" WHERE ROUTING_UID="+cUID
				oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				oDataRow:Item["Completed"] := dDate
			ENDIF
		CATCH
		END TRY
	ENDCASE

	/*IF cField == "RoutingROB_FO" .or. lCommencedGMTModified .or. lCompletedGMTModified
		SELF:CalculateROB(oRow, oView)
	ENDIF*/

	//IF cField == "Condition"
	////	DO CASE
	////	CASE SELF:cCondition == "Ballast"
	////	CASE SELF:cCondition == "Laden"
	////	CASE SELF:cCondition == "Loading"
	////	CASE SELF:cCondition == "Discharging"
	////	CASE SELF:cCondition == "Idle"
	////	ENDCASE
	//	// Set dates
	//	IF e:RowHandle > 0
	//		//LOCAL oPrevRow := (DataRowView)oView:GetRow(e:RowHandle - 1) AS DataRowView
	//		LOCAL cVoyageUID := oRow:Item["VOYAGE_UID"]:ToString() AS STRING
	//		LOCAL dLTCompleted := oMainForm:GetLastRoutingDate(cVoyageUID) AS DateTime
	//		IF dLTCompleted <> DateTime.MinValue
	//			dLTCompleted := dLTCompleted:AddMinutes(1)
	//			// Update
	//			cStatement:="UPDATE EconRoutings SET"+;
	//						" Commenced='"+dLTCompleted:ToString("yyyy-MM-dd HH:mm")+"'"+;
	//						" WHERE ROUTING_UID="+cUID
	//			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
	//			oDataRow:Item["Completed"] := dLTCompleted
	//			SELF:VoyageRouting_Refresh()
	//		ENDIF
	//	ENDIF
	//ENDIF
RETURN TRUE


//METHOD GetOldValue_Routings(cField AS STRING, cValue AS STRING) AS VOID
//	LOCAL oDataRow:=SELF:oDTRoutings:Rows:Find(oRow:Item["ROUTING_UID"]:ToString()) AS DataRow
//	IF oDataRow == NULL
//		ErrorBox("Cannot access current row", "Not changed")
//		RETURN
//	ENDIF

//	oDataRow:Item[cField] := cValue
//	SELF:oDTRoutings:AcceptChanges()
//RETURN


METHOD UpdateEconRoutingDistance(oDataRow AS DataRow, cTable AS STRING, cKey AS STRING, cUID AS STRING) AS INT
	LOCAL cStatement, cPortFrom, cPortTo AS STRING
	LOCAL nDistance := 0 AS INT

	cStatement:="SELECT PortFrom_UID, PortTo_UID FROM "+cTable+;
				" WHERE "+cKey+"="+cUID
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	IF oDT:Rows:Count == 0
		RETURN 0
	ENDIF
	cPortFrom := oDT:Rows[0]:Item["PortFrom_UID"]:ToString()
	cPortTo := oDT:Rows[0]:Item["PortTo_UID"]:ToString()

	IF cPortFrom <> "" .AND. cPortFrom <> "0" .AND. cPortTo <> "" .AND. cPortTo <> "0"
		// Find Distance
		LOCAL oDTDistance := oMainForm:GetDistances(cPortFrom, cPortTo, NULL) AS DataTable
		IF oDTDistance:Rows:Count <> 0
			nDistance := Convert.ToInt32(oDTDistance:Rows[0]:Item["Distance"]:ToString())
		ENDIF
	ENDIF

	// Update "+cTable+".Distance
	cStatement:="UPDATE "+cTable+" SET"+;
				" Distance="+nDistance:ToString()+;
				" WHERE "+cKey+"="+cUID
	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
RETURN nDistance


METHOD UpdateEconDistances(oDataRow AS DataRow, cValue AS STRING) AS VOID
	LOCAL cStatement, cPortFrom, cPortTo AS STRING
	LOCAL nDistance, nOldDistance AS INT

	cPortFrom := oDataRow:Item["PortFrom_UID"]:ToString()
	cPortTo := oDataRow:Item["PortTo_UID"]:ToString()

	TRY
		nDistance := Convert.ToInt32(cValue)
	CATCH
		nDistance := 0
	END TRY

	IF nDistance == 0
		RETURN
	ENDIF

	// Check and update Distance
	IF cPortFrom <> "" .AND. cPortFrom <> "0" .AND. cPortTo <> "" .AND. cPortTo <> "0"
		// Find Distance
		LOCAL oDTDist := oMainForm:GetDistances(cPortFrom, cPortTo, NULL) AS DataTable
		LOCAL n, nCount := oDTDist:Rows:Count -1 AS INT
		FOR n:=0 UPTO nCount
			TRY
				nOldDistance := Convert.ToInt32(oDTDist:Rows[n]:Item["Distance"])
			CATCH
				nOldDistance := 0
			END TRY
			//wb(oDTDist:Rows[n]:Item["Distance"], oDataRow:Item["Distance"])
			IF nOldDistance == nDistance
				RETURN
			ENDIF
		NEXT

		DO CASE
		CASE oDTDist:Rows:Count > 0 .AND. nDistance <> nOldDistance .AND. nDistance <> 0
			IF QuestionBox("The Distance table contains the Distance: "+oDTDist:Rows[0]:Item["Distance"]:ToString()+CRLF+;
							"between: "+oDataRow:Item["PortFrom"]:ToString()+" and "+oDataRow:Item["PortTo"]:ToString()+CRLF+CRLF+;
							"Do you want to Update the the existing Distance to: "+nDistance:ToString()+" into the Distance table ?", ;
							"Change Distance") == System.Windows.Forms.DialogResult.Yes
				// Update Distance
				cStatement:="UPDATE VEDistances SET Distance="+nDistance:ToString()+;
							" WHERE DISTANCE_UID="+oDTDist:Rows[0]:Item["DISTANCE_UID"]:ToString()
				oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				oDataRow:Item["Distance"] := nDistance
			//else
				//nDistance := Convert.ToInt32(oDTDist:Rows[0]:Item["Distance"])
			ENDIF

		CASE oDTDist:Rows:Count == 0 .AND. nDistance <> 0
			// Append Distance
			cStatement:="INSERT INTO VEDistances (PortFrom, PortTo, PortVia, Distance) VALUES"+;
						" ("+cPortFrom+","+cPortTo+", 0, "+nDistance:ToString()+")"
			IF oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				WBTimed{"Distance appended to Distance table", "Distance appended", oUser:nInfoBoxTimer}:ShowDialog(SELF)
				oDataRow:Item["Distance"] := nDistance
			ENDIF
		ENDCASE
	ENDIF
RETURN


METHOD Voyages_Delete() AS VOID
	LOCAL oRow AS DataRowView
	LOCAL nRowHandle := SELF:GridViewVoyages:FocusedRowHandle AS INT
	oRow:=(DataRowView)SELF:GridViewVoyages:GetRow(nRowHandle)
	IF oRow == NULL
		RETURN
	ENDIF

	LOCAL cUID := oRow:Item["VOYAGE_UID"]:ToString() AS STRING

	// Check if Routing exist
	LOCAL cStatement, cDuplicate AS STRING
	cStatement:="SELECT Count(*) AS nCount FROM EconRoutings"+;
				" WHERE VOYAGE_UID="+cUID
	cDuplicate:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "nCount")
	IF cDuplicate <> "0"
		ErrorBox("The Voyage '"+oRow:Item["VoyageNo"]:ToString()+"' is already in use by: "+cDuplicate+" Routing(s)", "Deletion aborted")
		SELF:Voyages_Refresh()
		RETURN
	ENDIF

	IF QuestionBox("Do you want to Delete the current Voyage:"+CRLF+CRLF+;
					oRow:Item["Description"]:ToString()+" ?", ;
					"Delete") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	//SELF:VoyageLog("Delete", cUID, "")

	cStatement:="DELETE FROM EconVoyages"+;
				" WHERE VOYAGE_UID="+cUID
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ErrorBox("Cannot Delete current row", "Deletion aborted")
		RETURN
	ENDIF

	IF SELF:GridViewVoyages:DataRowCount == 1
		SELF:oDTVoyages:Clear()
		RETURN
	ENDIF

	// Stop Notification
	SELF:lSuspendNotification := TRUE
	IF nRowHandle == 0
		SELF:GridViewVoyages:MoveNext()
	ELSE
		SELF:GridViewVoyages:MovePrev()
	ENDIF
	SELF:lSuspendNotification := FALSE

	LOCAL oDataRow AS DataRow
	oDataRow:=SELF:oDTVoyages:Rows:Find(cUID)
	//wb(oRow:Item["MSG_UNIQUEID"]:ToString(), oDataRow)
	IF oDataRow <> NULL
		//wb(Self:oDTMsg32:Rows:Find(oRow:Item["MsgRefNo"]:ToString()), "Removed")
		SELF:oDTVoyages:Rows:Remove(oDataRow)
//			cUIDs+=cUID+","
	ENDIF
RETURN
    

METHOD VoyageRouting_Delete() AS VOID
	// Locate Active GridViewRoutings
	LOCAL oView:=(GridView)SELF:GridVoyages:FocusedView AS GridView
	IF oView == NULL
		RETURN
	ENDIF

	LOCAL oRow AS DataRowView
	LOCAL nRowHandle := oView:FocusedRowHandle AS INT
	oRow:=(DataRowView)oView:GetRow(nRowHandle)
	IF oRow == NULL
		wb("No Routing selected")
		RETURN
	ENDIF

	//// Check if Routing exist
	//LOCAL cStatement, cDuplicate AS STRING
	//cStatement:="SELECT Count(*) AS nCount FROM EconRoutings"+;
	//			" WHERE VOYAGE_UID='"+oRow:Item["VOYAGE_UID"]:ToString()+"'"
	//cDuplicate:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "nCount")
	//IF cDuplicate <> "0"
	//	ErrorBox("The Voyage '"+oRow:Item["VoyageNo"]:ToString()+"' is already in use by: "+cDuplicate+" Routing(s)", "Deletion aborted")
	//	SELF:Voyages_Refresh()
	//	RETURN
	//ENDIF

	IF QuestionBox("Do you want to Delete the current Voyage Routing ?", ;
					"Delete") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	LOCAL cRoutingUID := oRow:Item["ROUTING_UID"]:ToString() AS STRING

	//SELF:RoutingLog("Delete", cRoutingUID, "")

	LOCAL cStatement AS STRING
	cStatement:="DELETE FROM EconRoutings"+;
				" WHERE ROUTING_UID="+cRoutingUID
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ErrorBox("Cannot Delete current row", "Deletion aborted")
		RETURN
	ENDIF

	IF oView:DataRowCount == 1
		SELF:oDTRoutings:Clear()
		RETURN
	ENDIF

	// Stop Notification
	SELF:lSuspendNotification := TRUE
	IF nRowHandle == 0
		SELF:GridViewRoutings:MoveNext()
	ELSE
		SELF:GridViewRoutings:MovePrev()
	ENDIF
	SELF:lSuspendNotification := FALSE

	LOCAL oDataRow AS DataRow
	oDataRow:=SELF:oDTRoutings:Rows:Find(cRoutingUID)
	//wb(oRow:Item["MSG_UNIQUEID"]:ToString(), oDataRow)
	IF oDataRow <> NULL
		//wb(Self:oDTMsg32:Rows:Find(oRow:Item["MsgRefNo"]:ToString()), "Removed")
		SELF:oDTRoutings:Rows:Remove(oDataRow)
//			cUIDs+=cUID+","
	ENDIF
RETURN


METHOD Voyages_Refresh() AS VOID
	//LOCAL cVesselUID := "" AS STRING
	IF SELF:LookUpEditCompany_Voyages:Text == ""
		wb("No Vessel selected")
		SELF:LookUpEditCompany_Voyages:Focus()
		RETURN
	ENDIF
	//cVesselUID := SELF:LookUpEditCompany_Voyages:EditValue:ToString()

	LOCAL cUID AS STRING
	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewVoyages:GetRow(SELF:GridViewVoyages:FocusedRowHandle)
	IF oRow <> NULL
		cUID := oRow:Item["VOYAGE_UID"]:ToString()
	ENDIF

	SELF:CreateGridVoyages()	//" WHERE VESSEL_UNIQUEID="+cVesselUID)
	SELF:FillDates_Voyage()

	IF oRow <> NULL
		LOCAL nFocusedHandle AS INT
		//nFocusedHandle:=SELF:GridViewVoyages:LocateByValue(0, SELF:GridViewVoyages:Columns["VOYAGE_UID"], Convert.ToInt32(cUID))
		nFocusedHandle:=SELF:GridViewVoyages:LocateByDisplayText(0, SELF:GridViewVoyages:Columns["VOYAGE_UID"], cUID)
		IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
			RETURN
		ENDIF


		SELF:GridViewVoyages:FocusedRowHandle:=nFocusedHandle
		SELF:GridViewVoyages:SelectRow(nFocusedHandle)
		SELF:GridViewVoyages:ClearSelection()

		SELF:GridViewVoyages:ExpandMasterRow(SELF:GridViewVoyages:FocusedRowHandle, "Voyage Routing")

		LOCAL oView:=(GridView)SELF:GridViewVoyages:GetDetailView(SELF:GridViewVoyages:FocusedRowHandle, 0) AS GridView
		IF oView <> NULL
			oView:Focus()
		ENDIF
	ENDIF	
RETURN
    

METHOD VoyageRouting_Refresh() AS VOID
	//LOCAL cVesselUID := "" AS STRING
	IF SELF:LookUpEditCompany_Voyages:Text == ""
		wb("No Vessel selected")
		SELF:LookUpEditCompany_Voyages:Focus()
		RETURN
	ENDIF
	//cVesselUID := SELF:LookUpEditCompany_Voyages:EditValue:ToString()

	LOCAL cUID AS STRING
	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewVoyages:GetRow(SELF:GridViewVoyages:FocusedRowHandle)
	IF oRow <> NULL
		cUID := oRow:Item["VOYAGE_UID"]:ToString()
	ENDIF

	SELF:CreateGridVoyages()	//" WHERE VESSEL_UNIQUEID="+cVesselUID)

	IF oRow <> NULL
		LOCAL nFocusedHandle AS INT
		nFocusedHandle:=SELF:GridViewVoyages:LocateByDisplayText(0, SELF:GridViewVoyages:Columns["VOYAGE_UID"], cUID)
		//nFocusedHandle:=SELF:GridViewVoyages:LocateByValue("VOYAGE_UID", Convert.ToInt32(cUID))
		IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
			RETURN
		ENDIF

		SELF:GridViewVoyages:ClearSelection()
		SELF:GridViewVoyages:FocusedRowHandle:=nFocusedHandle
		SELF:GridViewVoyages:SelectRow(nFocusedHandle)

		SELF:GridViewVoyages:ExpandMasterRow(SELF:GridViewVoyages:FocusedRowHandle, "Voyage Routing")

		LOCAL oView:=(GridView)SELF:GridViewVoyages:GetDetailView(SELF:GridViewVoyages:FocusedRowHandle, 0) AS GridView
		SELF:FillDates_Routing(oView)
		Application.DoEvents()
		oView:Focus()
	ENDIF	
RETURN
    

//METHOD VoyageRouting_Refresh(oView AS GridView) AS VOID
//	//LOCAL cVesselUID := "" AS STRING
//	IF SELF:LookUpEditCompany_Voyages:Text == ""
//		wb("No Vessel selected")
//		SELF:LookUpEditCompany_Voyages:Focus()
//		RETURN
//	ENDIF
//	//cVesselUID := SELF:LookUpEditCompany_Voyages:EditValue:ToString()

//	LOCAL cUID AS STRING
//	LOCAL oRow AS DataRowView
//	oRow:=(DataRowView)oView:GetRow(oView:FocusedRowHandle)
//	IF oRow <> NULL
//		cUID := oRow:Item["ROUTING_UID"]:ToString()
//	ENDIF

//	SELF:CreateGridVoyages()	//" WHERE VESSEL_UNIQUEID="+cVesselUID)

//	IF oRow <> NULL
//		LOCAL nFocusedHandle AS INT
//		nFocusedHandle:=oView:LocateByDisplayText(0, oView:Columns["ROUTING_UID"], cUID)
//		//nFocusedHandle:=oView:LocateByValue("VOYAGE_UID", Convert.ToInt32(cUID))
//		IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
//			RETURN
//		ENDIF

//		oView:ClearSelection()
//		oView:FocusedRowHandle:=nFocusedHandle
//		oView:SelectRow(nFocusedHandle)

//		//oView:ExpandMasterRow(oView:FocusedRowHandle, "Voyage Routing")

//		//LOCAL oView:=(GridView)SELF:GridViewVoyages:GetDetailView(SELF:GridViewVoyages:FocusedRowHandle, 0) AS GridView
//		SELF:FillDates_Routing(oView)
//		oView:Focus()
//	ENDIF	
//RETURN
    

METHOD FillDates_Voyage() AS VOID
	IF SELF:GridViewVoyages:DataRowCount == 0
		RETURN
	ENDIF

	LOCAL n, nRows := SELF:GridViewVoyages:DataRowCount - 1 AS INT
	LOCAL oRow AS DataRowView
	LOCAL dDate AS DateTime
	LOCAL cStatement, cGMTColumn AS STRING
	LOCAL nDiff AS Double

	FOR n:=0 UPTO nRows
		oRow:=(DataRowView)SELF:GridViewVoyages:GetRow(n)
		IF oRow:Item["StartDate"]:ToString() <> "" .AND. oRow:Item["StartDateGMT"]:ToString() == ""
			TRY
				cGMTColumn := SELF:GetGMTColumn_Voyage(oRow:Row, "PortFrom")
				nDiff := Convert.ToDouble(oRow:Item[cGMTColumn]:ToString())
				IF nDiff <> (Double)0
					dDate := Convert.ToDateTime(oRow:Item["StartDate"]:ToString()):AddHours(-nDiff)
					cStatement:="UPDATE EconVoyages SET"+;
								" StartDateGMT='"+dDate:ToString("yyyy-MM-dd HH:mm")+"'"+;
								" WHERE VOYAGE_UID="+oRow:Item["VOYAGE_UID"]:ToString()
					oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
					oRow:Row:Item["StartDateGMT"] := dDate
					//SELF:GridViewVoyages:Invalidate()
				ENDIF
			CATCH
			END TRY
		ENDIF

		IF oRow:Item["StartDate"]:ToString() == "" .AND. oRow:Item["StartDateGMT"]:ToString() <> ""
			TRY
				cGMTColumn := SELF:GetGMTColumn_Voyage(oRow:Row, "PortFrom")
				nDiff := Convert.ToDouble(oRow:Item[cGMTColumn]:ToString())
				IF nDiff <> (Double)0
					dDate := Convert.ToDateTime(oRow:Item["StartDateGMT"]:ToString()):AddHours(nDiff)
					cStatement:="UPDATE EconVoyages SET"+;
								" StartDate='"+dDate:ToString("yyyy-MM-dd HH:mm")+"'"+;
								" WHERE VOYAGE_UID="+oRow:Item["VOYAGE_UID"]:ToString()
					oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
					oRow:Row:Item["StartDate"] := dDate
					//SELF:GridViewVoyages:Invalidate()
				ENDIF
			CATCH
			END TRY
		ENDIF

		IF oRow:Item["EndDate"]:ToString() <> "" .AND. oRow:Item["EndDateGMT"]:ToString() == ""
			TRY
				cGMTColumn := SELF:GetGMTColumn_Voyage(oRow:Row, "PortTo")
				nDiff := Convert.ToDouble(oRow:Item[cGMTColumn]:ToString())
				IF nDiff <> (Double)0
					dDate := Convert.ToDateTime(oRow:Item["EndDate"]:ToString()):AddHours(-nDiff)
					cStatement:="UPDATE EconVoyages SET"+;
								" EndDateGMT='"+dDate:ToString("yyyy-MM-dd HH:mm")+"'"+;
								" WHERE VOYAGE_UID="+oRow:Item["VOYAGE_UID"]:ToString()
					oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
					oRow:Row:Item["EndDateGMT"] := dDate
					//SELF:GridViewVoyages:Invalidate()
				ENDIF
			CATCH
			END TRY
		ENDIF

		IF oRow:Item["EndDate"]:ToString() == "" .AND. oRow:Item["EndDateGMT"]:ToString() <> ""
			TRY
				cGMTColumn := SELF:GetGMTColumn_Voyage(oRow:Row, "PortTo")
				nDiff := Convert.ToDouble(oRow:Item[cGMTColumn]:ToString())
				IF nDiff <> (Double)0
					dDate := Convert.ToDateTime(oRow:Item["EndDateGMT"]:ToString()):AddHours(nDiff)
					cStatement:="UPDATE EconVoyages SET"+;
								" EndDate='"+dDate:ToString("yyyy-MM-dd HH:mm")+"'"+;
								" WHERE VOYAGE_UID="+oRow:Item["VOYAGE_UID"]:ToString()
					oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
					oRow:Row:Item["EndDate"] := dDate
					//SELF:GridViewVoyages:Invalidate()
				ENDIF
			CATCH
			END TRY
		ENDIF
	NEXT
RETURN


METHOD FillDates_Routing(oView AS GridView) AS VOID
	IF oView:DataRowCount == 0
		RETURN
	ENDIF

	LOCAL n, nRows := oView:DataRowCount - 1 AS INT
	LOCAL oRow AS DataRowView
	LOCAL dDate AS DateTime
	LOCAL cStatement, cGMTColumn AS STRING
	LOCAL nDiff AS Double

	FOR n:=0 UPTO nRows
		oRow:=(DataRowView)oView:GetRow(n)
		IF oRow:Item["Commenced"]:ToString() <> "" .AND. oRow:Item["CommencedGMT"]:ToString() == ""
			TRY
				cGMTColumn := SELF:GetGMTColumn_Routing(oRow:Row, "PortFrom")
				nDiff := Convert.ToDouble(oRow:Item[cGMTColumn]:ToString())
				IF nDiff <> (Double)0
					dDate := Convert.ToDateTime(oRow:Item["Commenced"]:ToString()):AddHours(-nDiff)
					cStatement:="UPDATE EconRoutings SET"+;
								" CommencedGMT='"+dDate:ToString("yyyy-MM-dd HH:mm")+"'"+;
								" WHERE ROUTING_UID="+oRow:Item["ROUTING_UID"]:ToString()
					oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
					oRow:Row:Item["CommencedGMT"] := dDate
					//oView:Invalidate()
				ENDIF
			CATCH
			END TRY
		ENDIF

		IF oRow:Item["Commenced"]:ToString() == "" .AND. oRow:Item["CommencedGMT"]:ToString() <> ""
			TRY
				cGMTColumn := SELF:GetGMTColumn_Routing(oRow:Row, "PortFrom")
				nDiff := Convert.ToDouble(oRow:Item[cGMTColumn]:ToString())
				IF nDiff <> (Double)0
					dDate := Convert.ToDateTime(oRow:Item["CommencedGMT"]:ToString()):AddHours(nDiff)
					cStatement:="UPDATE EconRoutings SET"+;
								" Commenced='"+dDate:ToString("yyyy-MM-dd HH:mm")+"'"+;
								" WHERE ROUTING_UID="+oRow:Item["ROUTING_UID"]:ToString()
					oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
					oRow:Row:Item["Commenced"] := dDate
					//oView:Invalidate()
				ENDIF
			CATCH
			END TRY
		ENDIF

		IF oRow:Item["Completed"]:ToString() <> "" .AND. oRow:Item["CompletedGMT"]:ToString() == ""
			TRY
				cGMTColumn := SELF:GetGMTColumn_Routing(oRow:Row, "PortTo")
				nDiff := Convert.ToDouble(oRow:Item[cGMTColumn]:ToString())
				IF nDiff <> (Double)0
					dDate := Convert.ToDateTime(oRow:Item["Completed"]:ToString()):AddHours(-nDiff)
					cStatement:="UPDATE EconRoutings SET"+;
								" CompletedGMT='"+dDate:ToString("yyyy-MM-dd HH:mm")+"'"+;
								" WHERE ROUTING_UID="+oRow:Item["ROUTING_UID"]:ToString()
					oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
					oRow:Row:Item["CompletedGMT"] := dDate
					//oView:Invalidate()
				ENDIF
			CATCH
			END TRY
		ENDIF

		IF oRow:Item["Completed"]:ToString() == "" .AND. oRow:Item["CompletedGMT"]:ToString() <> ""
			TRY
				cGMTColumn := SELF:GetGMTColumn_Routing(oRow:Row, "PortTo")
				nDiff := Convert.ToDouble(oRow:Item[cGMTColumn]:ToString())
				IF nDiff <> (Double)0
					dDate := Convert.ToDateTime(oRow:Item["CompletedGMT"]:ToString()):AddHours(nDiff)
					cStatement:="UPDATE EconRoutings SET"+;
								" Completed='"+dDate:ToString("yyyy-MM-dd HH:mm")+"'"+;
								" WHERE ROUTING_UID="+oRow:Item["ROUTING_UID"]:ToString()
					oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
					oRow:Row:Item["Completed"] := dDate
					//oView:Invalidate()
				ENDIF
			CATCH
			END TRY
		ENDIF
	NEXT
RETURN

METHOD setTimeCharterProperties(lIsTCLocal AS LOGIC,cTCParentLocal AS STRING) AS VOID
	SELF:lisTC := lIsTCLocal 
	SELF:cTCParent := cTCParentLocal
RETURN

METHOD DisplayGMT(oRow AS DataRowView, cPortUID AS STRING, cPrefix AS STRING, cTable AS STRING) AS VOID
	IF cPortUID == "0"
		RETURN
	ENDIF

	LOCAL cGMT AS STRING
	IF cTable == "Voyage"
		cGMT := SELF:GetGMTColumn_Voyage(oRow:Row, cPrefix)
	ELSE
		cGMT := SELF:GetGMTColumn_Routing(oRow:Row, cPrefix)
	ENDIF
	LOCAL cStatement AS STRING
	LOCAL cField := cGMT:Replace(cPrefix, "") AS STRING
	cStatement:="SELECT "+cField+" FROM VEPorts"+;
				" WHERE PORT_UID="+cPortUID
	LOCAL cDiff := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, cField) AS STRING
	//wb(cPrefix+cGMT+CRLF+cStatement+CRLF+cDiff)
	TRY
		//wb(oRow:Row:Item[cPrefix+cGMT]:ToString()+CRLF+cDiff)
		oRow:Row:Item[cPrefix+"_UID"] := cPortUID
		//oRow:Row:Item[cPrefix+cGMT] := Convert.ToDecimal(cDiff:Replace(SELF:groupSeparator, ""):Replace(SELF:decimalSeparator, "."))
		oRow:Row:Item[cGMT] := Convert.ToDecimal(cDiff)
		//wb(oRow:Row:Item[cPrefix+cGMT]:ToString()+CRLF+cDiff)
		IF cTable == "Voyage"
			SELF:GridViewVoyages:Invalidate()
		ELSE
			LOCAL oView:=(GridView)SELF:GridVoyages:FocusedView AS GridView
			IF oView == NULL
				RETURN
			ENDIF
			oView:Invalidate()
		ENDIF
	CATCH
	END TRY
RETURN


METHOD Change_BarSetup_ToolTips_Voyages() AS VOID
	// Create an object to initialize the SuperToolTip.
	LOCAL args AS DevExpress.Utils.SuperToolTipSetupArgs

	args := DevExpress.Utils.SuperToolTipSetupArgs{}
	args:Title:Text := "Add (Ctrl-N)"
	args:Contents:Text := "Create new Voyage"
	//args:Contents.Image = resImage;
	SELF:BBIAdd:SuperTip:Setup(args)

	args := DevExpress.Utils.SuperToolTipSetupArgs{}
	args:Title:Text := "Edit (F2)"
	args:Contents:Text := "Edit Voyage"
	SELF:BBIEdit:SuperTip:Setup(args)

	args := DevExpress.Utils.SuperToolTipSetupArgs{}
	args:Title:Text := "Delete"
	args:Contents:Text := "Delete Voyage"
	SELF:BBIDelete:SuperTip:Setup(args)

	args := DevExpress.Utils.SuperToolTipSetupArgs{}
	args:Title:Text := "Print (Ctrl+P)"
	args:Contents:Text := "Print Voyages"
	SELF:BBIPrint:SuperTip:Setup(args)

	args := DevExpress.Utils.SuperToolTipSetupArgs{}
	args:Title:Text := "Refresh"
	args:Contents:Text := "Refresh Voyages"
	SELF:BBIRefresh:SuperTip:Setup(args)

	SELF:BBINewRouting:Visibility := DevExpress.XtraBars.BarItemVisibility.Always
	SELF:BBIMWA:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
	SELF:BBIMWD:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
	SELF:BBICalculateROB:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
RETURN


METHOD Change_BarSetup_ToolTips_Routings() AS VOID
	// Create an object to initialize the SuperToolTip.
	LOCAL args AS DevExpress.Utils.SuperToolTipSetupArgs

	args := DevExpress.Utils.SuperToolTipSetupArgs{}
	args:Title:Text := "Add (Ctrl-N)"
	args:Contents:Text := "Create new Voyage Routing"
	//args:Contents.Image = resImage;
	SELF:BBIAdd:SuperTip:Setup(args)

	args := DevExpress.Utils.SuperToolTipSetupArgs{}
	args:Title:Text := "Edit (F2)"
	args:Contents:Text := "Edit Voyage Routing"
	SELF:BBIEdit:SuperTip:Setup(args)

	args := DevExpress.Utils.SuperToolTipSetupArgs{}
	args:Title:Text := "Delete"
	args:Contents:Text := "Delete Voyage Routing"
	SELF:BBIDelete:SuperTip:Setup(args)

	args := DevExpress.Utils.SuperToolTipSetupArgs{}
	args:Title:Text := "Print (Ctrl+P)"
	args:Contents:Text := "Print Voyage Routing"
	SELF:BBIPrint:SuperTip:Setup(args)

	args := DevExpress.Utils.SuperToolTipSetupArgs{}
	args:Title:Text := "Refresh"
	args:Contents:Text := "Refresh Voyage Routing"
	SELF:BBIRefresh:SuperTip:Setup(args)

	SELF:BBINewRouting:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
	SELF:BBIMWA:Visibility := DevExpress.XtraBars.BarItemVisibility.Always
	SELF:BBIMWD:Visibility := DevExpress.XtraBars.BarItemVisibility.Always
	
	SELF:BBICalculateROB:Visibility := DevExpress.XtraBars.BarItemVisibility.Always
RETURN

EXPORT METHOD showMatchForm(cType AS STRING) AS VOID
		LOCAL oMatchForm := MatchForm{} AS MatchForm
		LOCAL DateGMT := "" AS STRING
		LOCAL oView:=(GridView)SELF:GridViewVoyages:GetDetailView(SELF:GridViewVoyages:FocusedRowHandle, 0) AS GridView
		LOCAL oRoutingRow:=(DataRowView)oView:GetFocusedRow() AS DataRowView
		LOCAL oVoyageRow:=(DataRowView)oView:SourceRow AS DataRowView
		IF oRoutingRow == NULL
			MessageBox.Show("No routing selected.")
			RETURN
		ENDIF
		
		LOCAL cRoutingUID := oRoutingRow["Routing_UID"]:ToString()  AS STRING
		LOCAL cVoyageStartDate := oRoutingRow["CommencedGMT"]:ToString()  AS STRING
		LOCAL cVoyageEndDate := oRoutingRow["CompletedGMT"]:ToString()  AS STRING
		oMatchForm:setTypeAndVessel(cType,cVesselUID_Voyages,cVoyageStartDate,cVoyageEndDate)
		LOCAL oResult := oMatchForm:ShowDialog() AS DialogResult
		//MessageBox.Show(oResult:ToString())
		IF oResult == DialogResult.OK
			//LOCAL cName := oMatchForm:cReturnName AS STRING 
			LOCAL cPackageUID := oMatchForm:cReturnUID AS STRING
			//Arrival
			LOCAL cArrivalHFOUid := oMatchForm:cArrivalHFOUid AS STRING
			LOCAL cArrivalLFOUid := oMatchForm:cArrivalLFOUid AS STRING
			LOCAL cArrivalMDOUid := oMatchForm:cArrivalMDOUid AS STRING
			IF cArrivalHFOUid == ""
				cArrivalHFOUid := "0"
			ENDIF
			IF cArrivalLFOUid == ""
				cArrivalLFOUid := "0"
			ENDIF
			IF cArrivalMDOUid == ""
				cArrivalMDOUid := "0"
			ENDIF
			//Departure
			LOCAL cDepHFOUid := oMatchForm:cDepHFOUid AS STRING
			LOCAL cDepLFOUid := oMatchForm:cDepLFOUid AS STRING
			LOCAL cDepMDOUid := oMatchForm:cDepMDOUid AS STRING
			IF cDepHFOUid == ""
				cDepHFOUid := "0"
			ENDIF
			IF cDepLFOUid == ""
				cDepLFOUid := "0"
			ENDIF
			IF cDepMDOUid == ""
				cDepMDOUid := "0"
			ENDIF
			//Bunkering
			LOCAL cBunkDepHFOUid := oMatchForm:cBunkDepHFOUid AS STRING
			LOCAL cBunkDepLFOUid := oMatchForm:cBunkDepLFOUid AS STRING
			LOCAL cBunkDepMDOUid := oMatchForm:cBunkDepMDOUid AS STRING
			IF cBunkDepHFOUid == ""
				cBunkDepHFOUid := "0"
			ENDIF
			IF cBunkDepLFOUid == ""
				cBunkDepLFOUid := "0"
			ENDIF
			IF cBunkDepMDOUid == ""
				cBunkDepMDOUid := "0"
			ENDIF
			LOCAL cStatement AS STRING
			LOCAL cExtraSQL := " " AS STRING
			cExtraSQL := " AND FMDataPackages.PACKAGE_UID = "+cPackageUID
		
			cStatement:=" SELECT FMDataPackages.DateTimeGMT,FMDataPackages.PACKAGE_UID"+;
						" FROM FMDataPackages  "+;
						" WHERE Matched=0 "+ cExtraSQL+;
						" ORDER BY DateTimeGMT"
		
			LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			IF oDT:Rows:Count == 1
				DateGMT := oDT:Rows[0]:Item["DateTimeGMT"]:ToString()
				IF DateGMT == ""
					DateGMT := "NULL"
				ELSE
					DateGMT := "'"+Datetime.Parse(DateGMT):ToString("yyyy-MM-dd HH:mm:ss")+"'"
				ENDIF
			
				IF cType=="A"
					cStatement:="UPDATE EconRoutings set ArrivalGMT="+DateGMT+" WHERE Routing_UID="+cRoutingUID
				ELSE
					cStatement:="UPDATE EconRoutings set DepartureGMT="+DateGMT+" WHERE Routing_UID="+cRoutingUID
				ENDIF
				oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				
			ENDIF

			cStatement:=" SELECT * FROM FMRoutingAdditionalData WHERE Routing_UID="+cRoutingUID
		
			oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
			IF oDT:Rows:Count == 1 //Υπάρχει ήδη κάνε update.
		
				IF cType=="A"
					cStatement:="UPDATE FMRoutingAdditionalData set MatchedWithArrival=1 " +;
					" ,Arrival_HFO="+cArrivalHFOUid+;
					" ,Arrival_LFO="+cArrivalLFOUid+;
					" ,Arrival_MGO="+cArrivalMDOUid+;
					" WHERE Routing_UID="+cRoutingUID
				ELSE
					cStatement:="UPDATE FMRoutingAdditionalData set MatchedWithDeparture=1 "+;
					" ,Departure_HFO="+cDepHFOUid+;
					" ,Departure_LFO="+cDepLFOUid+;
					" ,Departure_MGO="+cDepMDOUid+;
					" ,BunkeredHFO="+cBunkDepHFOUid+;
					" ,BunkeredLFO="+cBunkDepLFOUid+;
					" ,BunkeredMDO="+cBunkDepMDOUid+;
					" WHERE Routing_UID="+cRoutingUID
				ENDIF
				oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			
			ELSEIF oDT:Rows:Count == 0 // Δεν υπάρχει κάνε Insert
				IF cType=="A"
					cStatement:="INSERT INTO FMRoutingAdditionalData"+;
					" (Routing_UID, Arrival_HFO, Arrival_LFO, Arrival_MGO, Update_User, Update_Date, MatchedWithArrival) VALUES"+;
					" ("+cRoutingUID+", "+cArrivalHFOUid+", "+cArrivalLFOUid+" , "+cArrivalMDOUid+;
					" , "+oUser:USER_UNIQUEID+", CURRENT_TIMESTAMP, 1) ;"
				ELSE
					cStatement:="INSERT INTO FMRoutingAdditionalData"+;
					" (Routing_UID, Departure_HFO, Departure_LFO, Departure_MGO,"+;
					" BunkeredHFO, BunkeredLFO, BunkeredMDO, Update_User,"+;
					" Update_Date, MatchedWithDeparture) VALUES"+;
					" ("+cRoutingUID+", "+cDepHFOUid+", "+cDepLFOUid+" , "+cDepMDOUid+","+;
					" "+cBunkDepHFOUid+", "+cBunkDepLFOUid+" , "+cBunkDepMDOUid+;
					" , "+oUser:USER_UNIQUEID+", CURRENT_TIMESTAMP, 1) ;"
				ENDIF
				oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			ENDIF

			SELF:Voyages_Refresh()
			
		ENDIF	
RETURN



#REGION PRINTPREVIEW

METHOD Voyages_Print() AS VOID
	SELF:PrintPreviewGridVoyages()
RETURN


METHOD PrintPreviewGridVoyages() AS VOID
	// Check whether the XtraGrid control can be previewed.
	IF ! SELF:GridVoyages:IsPrintingAvailable
		ErrorBox("The 'DevExpress.XtraPrinting' Library is not found")
		RETURN
	ENDIF

	// Opens the Preview window.
	//Self:GridVoyages:ShowPrintPreview()

	// Create a PrintingSystem component.
	LOCAL oPS := PrintingSystem{} AS DevExpress.XtraPrinting.PrintingSystem
	// Create a link that will print a control.
	LOCAL oLink := PrintableComponentLink{oPS} AS DevExpress.XtraPrinting.PrintableComponentLink
	// Specify the control to be printed.
	oLink:Component := SELF:GridVoyages
	// Set the paper format.
	oLink:PaperKind := System.Drawing.Printing.PaperKind.A4
	oLink:Landscape:=TRUE
	// Subscribe to the CreateReportHeaderArea event used to generate the report header.
	oLink:CreateReportHeaderArea += CreateAreaEventHandler{SELF, @PrintableComponentLinkVoyages_CreateReportHeaderArea()}
	// Generate the report.
	oLink:CreateDocument()
	// Show the report.
	oLink:ShowPreview()
RETURN


METHOD PrintableComponentLinkVoyages_CreateReportHeaderArea(sender AS OBJECT, e AS CreateAreaEventArgs) AS VOID
LOCAL cReportHeader := "List of Voyages - Printed on "+Datetime.Now:ToString(ccDateFormat)+" - User: "+oUser:UserID AS STRING

	e:Graph:StringFormat := BrickStringFormat{StringAlignment.Center}
	e:Graph:Font := Font{"Tahoma", 14, FontStyle.Bold}

	LOCAL rec := RectangleF{0, 0, e:Graph:ClientPageSize:Width, 50} AS RectangleF
	e:Graph:DrawString(cReportHeader, Color.Black, rec, DevExpress.XtraPrinting.BorderSide.None)
RETURN

#ENDREGION



END CLASS
