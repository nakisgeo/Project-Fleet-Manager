// MainForm_Methods.prg
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

#using SocketTools

PARTIAL CLASS MainForm INHERIT DevExpress.XtraEditors.XtraForm

	PRIVATE INSTANCE oSQLTablesCreator AS SQLTablesCreator
	EXPORT INSTANCE oGFH AS GenericFactoryHelper
	EXPORT INSTANCE oConn AS DBConnection
	//////////////////////////////////////////////////////////////////////////////////////
	//ADDED BY KIRIAKOS AT 01/06/16 in order to support attachments to different DataBase
	//////////////////////////////////////////////////////////////////////////////////////
	EXPORT INSTANCE oGFHBlob AS GenericFactoryHelper
	EXPORT INSTANCE oConnBlob AS DBConnection
	//////////////////////////////////////////////////////////////////////////////////////
	//ADDED BY KIRIAKOS AT 01/06/16 in order to support attachments to different DataBase
	//////////////////////////////////////////////////////////////////////////////////////
	PRIVATE cSDF:=cStartupPath+"\SOFTWAY.SDF" AS STRING		// Desktop and Devices
	PRIVATE cSDFBlob:=cStartupPath+"\FMBlobs.SDF" AS STRING		// Desktop and Devices
	EXPORT alForms:=ArrayList{} AS ArrayList
	EXPORT alData:=ArrayList{} AS ArrayList
	PRIVATE lUserLoggedOn AS LOGIC
    EXPORT cSkinNameLookAndFeel := "The Asphalt World" AS STRING

	EXPORT cNoLockTerm := "" AS STRING
	PRIVATE cLastMainSelection:="", cLastVesselName := NULL AS STRING

	EXPORT decimalSeparator AS STRING
	EXPORT groupSeparator AS STRING
	EXPORT negativeSign AS STRING

	EXPORT BingMapUserControl AS BingMapUserControl
	EXPORT oDTReports, oDTReportsOffice AS DataTable

    EXPORT oNavBarForm:=NavBarForm{} AS NavBarForm
    //EXPORT oNavBarPrograms:=oNavBarForm:NavBarPrograms AS DevExpress.XtraNavBar.NavBarControl

	EXPORT nThickness AS INT
	//PRIVATE nShowLastReports := 90 AS INT
	PRIVATE lSuspendNotification AS LOGIC

	EXPORT cLBSuggest_TypedChars := "" AS STRING
	//PRIVATE lShown AS LOGIC
	PRIVATE oLastSelectedNode AS TreeListNode
	//Time Charter Antonis 1.12.14
	PUBLIC lisTC AS LOGIC
	PUBLIC cTCParent AS STRING
	PUBLIC myReportTabForm AS ReportTabForm
	//PUBLIC cTempDocDIr AS STRING
	PUBLIC LBCReports  AS DevExpress.XtraEditors.ListBoxControl
	
	// Print Report
	
	PUBLIC  printReport := PrintDocument{} AS PrintDocument
	PRIVATE memoryImage AS Bitmap
	PRIVATE reportPrintPreview := PrintPreviewDialog{} AS PrintPreviewDialog

	// Display All Vessels
	PRIVATE lDisplayAll := TRUE AS LOGIC
	// Managers
	PRIVATE lisManagerGlobal AS LOGIC
	PRIVATE lisGMGlobal AS LOGIC
	PRIVATE myTimer := Timer{} AS Timer
	//
	PUBLIC  oMyApproval_Form AS Approval_Form
	//SMTP Setting
	PRIVATE oDRSMTPSettings := NULL AS DataRow
	
METHOD MainForm_OnLoad() AS VOID
	oMainForm := SELF
	//SELF:DoubleBuffered := true
	SELF:Text := "Fleet Manager program .NET Edition V."+cProgramVersion
	SELF:Text+=" - Server: "+cSQLDataSource+" ("+symServer:ToString()+")"
	
	printReport:PrintPage += PrintPageEventHandler{SELF,@printReport_PrintPage()}

	// NavBar: Set ActiveGroup to COMMUNICATOR
	SELF:DockPanelProgramsBar:Options:ShowCloseButton := FALSE
	SELF:oNavBarForm:NavBarPrograms:ActiveGroup:=SELF:oNavBarForm:NavBarPrograms:Groups["FleetManager"]
	// NavBar Groups
	SELF:oNavBarForm:NavBarPrograms:ActiveGroupChanged += DevExpress.XtraNavBar.NavBarGroupEventHandler{ SELF, @NavBarPrograms_ActiveGroupChanged() }
	// NavBar Items
	SELF:oNavBarForm:Fleet:LinkClicked += DevExpress.XtraNavBar.NavBarLinkEventHandler{ SELF, @Fleet_LinkClicked() }
	SELF:oNavBarForm:FMVessels:LinkClicked += DevExpress.XtraNavBar.NavBarLinkEventHandler{ SELF, @FMVessels_LinkClicked() }
	SELF:oNavBarForm:FMVoyages:LinkClicked += DevExpress.XtraNavBar.NavBarLinkEventHandler{ SELF, @FMVoyages_LinkClicked() }
	SELF:oNavBarForm:FMReports:LinkClicked += DevExpress.XtraNavBar.NavBarLinkEventHandler{ SELF, @FMReports_LinkClicked() }
	SELF:oNavBarForm:FMItems:LinkClicked += DevExpress.XtraNavBar.NavBarLinkEventHandler{ SELF, @FMItems_LinkClicked() }
	SELF:oNavBarForm:FMTools:LinkClicked += DevExpress.XtraNavBar.NavBarLinkEventHandler{ SELF, @FMTools_LinkClicked() }
	
	SELF:oNavBarForm:FMCargoes:LinkClicked += DevExpress.XtraNavBar.NavBarLinkEventHandler{ SELF, @FMCargoes_LinkClicked() }
	SELF:oNavBarForm:FMCurrenciesAndRates:LinkClicked += DevExpress.XtraNavBar.NavBarLinkEventHandler{ SELF, @FMCurrenciesAndRates_LinkClicked() }
	SELF:oNavBarForm:FMPorts:LinkClicked += DevExpress.XtraNavBar.NavBarLinkEventHandler{ SELF, @FMPorts_LinkClicked() }
	
	SELF:oNavBarForm:FMHelpAbout:LinkClicked += DevExpress.XtraNavBar.NavBarLinkEventHandler{ SELF, @HelpAbout_LinkClicked() }
	SELF:oNavBarForm:CheckForUpdates:LinkClicked += DevExpress.XtraNavBar.NavBarLinkEventHandler{ SELF, @CheckForUpdates_LinkClicked() }
	SELF:DockPanelProgramsBar_Container:Controls:Add(SELF:oNavBarForm:NavBarPrograms)

	LOCAL cTagSelection AS STRING
	TRY

		oSoftway:ReadXMLSettings(cStartupPath+"\"+Application.ProductName+".XML", SELF:alForms, SELF:alData, SELF:cLastMainSelection, cTagSelection, SELF:cSkinNameLookAndFeel)
		LOCAL oSplit := DevExpress.XtraEditors.SplitContainerControl[]{3} AS DevExpress.XtraEditors.SplitContainerControl[]
		oSplit[1] := SELF:splitContainerControl_Main
		oSplit[2] := SELF:splitContainerControl_LBC
		oSplit[3] := SELF:splitContainerControl_CheckedLBC
		oSoftway:ReadFormSettings_DevExpress(SELF, SELF:alForms, SELF:alData, oSplit)

	CATCH exc AS Exception
		
	END

	IF cTagSelection == NULL .OR. cTagSelection == ""
		cTagSelection := "25%"
	ENDIF
	SELF:barEditItemDisplayMap:EditValue := ctagselection
	
	DO CASE
	CASE symServer == #SqlCe
		SELF:cNoLockTerm := " WITH (nolock)"

	CASE symServer == #MSSQL
		SELF:cNoLockTerm := " WITH (nolock)"

	CASE symServer == #MySQL
		SELF:cNoLockTerm := ""
	ENDCASE

	TRY
		dockManager1:BeginUpdate()
		DockPanelProgramsBar:Visibility := DevExpress.XtraBars.Docking.DockVisibility.AutoHide
		DockPanelProgramsBar:HideImmediately()
		dockManager1:EndUpdate()
	CATCH
		
	END TRY

	//SELF:xtraTabPage_Voyages:Visible := FALSE
	// The groupSeparator or the decimalSeparator act as decimalSeparator 
	LOCAL numberFormatInfo := System.Globalization.CultureInfo.CurrentCulture:NumberFormat AS System.Globalization.numberFormatInfo
	SELF:decimalSeparator := numberFormatInfo:NumberDecimalSeparator
	SELF:groupSeparator := numberFormatInfo:NumberGroupSeparator
	SELF:negativeSign := numberFormatInfo:negativeSign

	// Read settings from SOFTWAY.INI:
	IF ! SELF:ReadFleetManagerIniFile()
		SELF:Close()
		RETURN
	ENDIF

	IF ! SELF:ConnectToSoftwayDatabase()
		RETURN
	ENDIF
	SELF:lUserLoggedOn := TRUE

	cTempDocDir := Application.StartupPath + "\TempDoc_FM_" + oUser:UserID
	
	
	SELF:CreateDirectory(cTempDocDir)
	SELF:ClearDirectory(cTempDocDIr,0)
	
	IF cLicensedCompany:ToUpper():Contains("DEMO") .OR.  cLicensedCompany:ToUpper():Contains("VAMVASHIP")
		SELF:BBIImportExcelData:Visibility := DevExpress.XtraBars.BarItemVisibility.Always
	ELSE
		SELF:BBIImportExcelData:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
	ENDIF

	//wb(Environment.CommandLine)
	IF Environment.CommandLine:Contains("UpdatedVersion")
	//IF ! (asCmdLine:Length == 1 .and. asCmdLine[1] == "UpdatedVersion")
		SELF:CheckForProgramVersions()
	ENDIF

	//SELF:BingMapUserControl:BingMapUserControl_OnLoad()
	IF ! SELF:CreateBingMapUserControl()
		SELF:Close()
	ENDIF
	// Vamvaship only:
	//SELF:BBIImportExcelData:Visibility := DevExpress.XtraBars.BarItemVisibility.Never

	//SELF:TreeListVessels:OptionsBehavior:Editable := FALSE
	////SELF:TreeListVessels:AllowRecursiveNodeChecking := TRUE
	//SELF:TreeListVessels:BeginUpdate()
	//SELF:TreeListVessels:Columns:Add()
	//SELF:TreeListVessels:Columns[0]:Caption := "Vessel"
	//SELF:TreeListVessels:Columns[0]:Name := "VesselName"
	//SELF:TreeListVessels:Columns[0]:VisibleIndex := 0
	//SELF:TreeListVessels:EndUpdate()

	//SELF:Fill_LBCReports(NULL)
	//SELF:cLastVesselName := ""

    // The Server and Client Class instances must be in different Applications
	SELF:LoadServerNamedPipe()

//	LOCAL aKymaHeaderFields AS STRING[]
//	aKymaHeaderFields := <STRING>{"Date (yyyy-mm-dd)", ;
//						"Time (hh:mm:ss)", ;
//						"A/E Fuel Mass Inlet (kg/hr)", ;
//						"A/E Fuel Mass Net (kg/hr)", ;
//						"A/E Fuel Mass Return (kg/hr)", ;
//						"A/E Fuel Vol Inlet (l/hr)", ;
//						"A/E Fuel Vol Return (l/hr)", ;
//						"A/E Inlet Fuel Temp (°C)", ;
//						"A/E Return Fuel Temp (°C)"}
//	LOCAL nIndex AS INT
//	nIndex := System.Array.IndexOf(aKymaHeaderFields, "A/E Inlet Fuel Temp")
//wb(nIndex:ToString())

//LOCAL dDate := Datetime{2014,6,5,23,4,12} AS datetime
//dDate := dDate:AddHours(1)
//wb(dDate)
	//SELF:printButton:Visibility := BarItemVisibility.Never
	//SELF:BBICreateReport:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
	
	/*LOCAL oRowLocal := self:returnUserSetting(oUser:USER_UNIQUEID) AS DataRow
	IF oRowLocal == NULL || oRowLocal["CanEditReportData"]:ToString() == "False"
		SELF:BBIEditReport:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
		SELF:BBIFinalize:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
		SELF:BBISave:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
		SELF:BBICancel:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
	ENDIF
	IF  oRowLocal == NULL ||  oRowLocal["CanDeleteReportData"]:ToString() == "False"
		SELF:BBIDelete:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
	ENDIF*/
	LBCReports := LBCReportsVessel
	//SELF:BingMapUserControl:ShowSelectedVesselsOnMap()
	lDisplayAll := TRUE
	SELF:oDRSMTPSettings := SELF:returnSMTPSetting()

RETURN


METHOD CreateBingMapUserControl() AS LOGIC
	TRY
		SELF:BingMapUserControl := BingMapUserControl{}
		//SELF:splitContainerControl_Main:Panel2:Controls:Add(SELF:BingMapUserControl)
		SELF:PanelControl_BingMaps:Controls:Add(SELF:BingMapUserControl)
        SELF:BingMapUserControl:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:BingMapUserControl:Location := System.Drawing.Point{0, 0}
		SELF:BingMapUserControl:Map:Focus()
		//SELF:splitMapForm:SplitterPosition := SELF:splitMapForm:Width
		SELF:splitMapForm:PanelVisibility := SplitPanelVisibility.Panel2
		
	CATCH e AS Exception
		ErrorBox(e:Message)
		RETURN FALSE
	END TRY
RETURN TRUE


METHOD MainForm_OnShown() AS VOID
	IF ! lSplashScreenClosed
		SELF:CloseSplashScreen()
		//Application.DoEvents()
	ENDIF
	IF ! SELF:lUserLoggedOn
		SELF:Close()
		RETURN
	ENDIF

	SELF:TreeListVessels:OptionsBehavior:Editable := FALSE
	//SELF:TreeListVessels:AllowRecursiveNodeChecking := TRUE
	SELF:TreeListVessels:BeginUpdate()
	SELF:TreeListVessels:Columns:Add()
	SELF:TreeListVessels:Columns[0]:Caption := "Vessel"
	SELF:TreeListVessels:Columns[0]:Name := "VesselName"
	SELF:TreeListVessels:Columns[0]:VisibleIndex := 0
	SELF:TreeListVessels:EndUpdate()


    SELF:TreeListVesselsReports:OptionsBehavior:Editable := FALSE
	//SELF:TreeListVessels:AllowRecursiveNodeChecking := TRUE
	SELF:TreeListVesselsReports:BeginUpdate()
	SELF:TreeListVesselsReports:Columns:Add()
	SELF:TreeListVesselsReports:Columns[0]:Caption := "Report"
	SELF:TreeListVesselsReports:Columns[0]:Name := "ReportName"
	SELF:TreeListVesselsReports:Columns[0]:VisibleIndex := 0
    SELF:TreeListVesselsReports:SelectImageList := SELF:reportsImageList
    SELF:TreeListVesselsReports:StateImageList := SELF:voyageTypeImgList
	SELF:TreeListVesselsReports:EndUpdate()

	//SELF:TreeListVesselsReports:OptionsBehavior:Editable := FALSE
	//SELF:TreeListVessels:AllowRecursiveNodeChecking := TRUE
	
	SELF:Fill_TreeListVessels(TRUE)
	IF SELF:GetVesselUID == "0"
		SELF:Fill_LBCReports(NULL)
		LBCReports := LBCReportsVessel
	ELSE
		SELF:Fill_LBCReports(SELF:GetVesselUID)
		LBCReports := LBCReportsVessel
		SELF:Fill_TreeList_Reports()
	ENDIF

	SELF:cLastVesselName := ""

	SELF:BingMapUserControl:ShowSelectedVesselsOnMap()
	//SELF:lShown := TRUE
// TODO: Check Boolean Mandatory field
	myTimer:Tick +=  System.EventHandler{ SELF, @timerClick() }
	myTimer:Interval := 120000
	myTimer:Tag := "1"
	myTimer:Start()
	IF SELF:checkForPendingApprovals()
		myTimer:Stop()
		LOCAL oResult := MessageBox.Show("You have pending approvals. Press YES to view, NO to continue, CANCEL to stop checking.","Approvals",MessageBoxButtons.YesNoCancel) AS DialogResult
		IF oResult == DialogResult.No
				myTimer:Start()
				RETURN 
		ELSEIF oResult == DialogResult.Cancel
				myTimer:Stop()
				myTimer:Tag := "0"
		ELSE
			SELF:ShowApprovalsForm()
		ENDIF
	ENDIF

	
	IF cLicensedCompany:ToUpper():StartsWith("SAMOS") 
			cLicensedCompany := "Samos Steamship"
	ELSEIF cLicensedCompany:ToUpper():StartsWith("DEMO") 
			cLicensedCompany := "Softway Ltd"
	ENDIF
	
RETURN

METHOD timerClick( sender AS System.Object, e AS System.EventArgs ) AS VOID
	LOCAL oBW := BackgroundWorker{} AS BackgroundWorker
	oBW:WorkerReportsProgress := TRUE
	oBW:WorkerSupportsCancellation := TRUE
	oBW:DoWork += DoWorkEventHandler{SELF,@TimerMethodcheckForApprovals()}
	oBW:ProgressChanged += ProgressChangedEventHandler{SELF,@WorkerReported()}
	oBW:RunWorkerAsync()
RETURN

METHOD TimerMethodcheckForApprovals( sender AS System.Object, e AS DoWorkEventArgs ) AS VOID
		LOCAL worker := (BackgroundWorker)sender AS BackgroundWorker
		IF SELF:checkForPendingApprovals()
			worker:ReportProgress(100)
		ELSE
			worker:CancelAsync()
		ENDIF
RETURN

	METHOD WorkerReported(sender AS System.Object, e AS ProgressChangedEventArgs ) AS VOID
		IF e:ProgressPercentage == 100
				myTimer:Stop()
				LOCAL oResult := MessageBox.Show("You have pending approvals. Press YES to view, No to Continue, Cancel to Stop Checking","Approvals",MessageBoxButtons.YesNoCancel) AS DialogResult
				IF oResult == DialogResult.No
						myTimer:Start()
						RETURN 
				ELSEIF oResult == DialogResult.Cancel
						myTimer:Stop()
						myTimer:Tag := "0"
				ELSE
					SELF:ShowApprovalsForm()
				ENDIF
		ENDIF
	RETURN

//	Antonis 1.12.14 See Sub Voyages of TC // 
METHOD treeList1_DoubleClick( sender AS OBJECT,  e AS EventArgs) AS VOID 

			LOCAL  tree := DevExpress.XtraTreeList.TreeList{} AS TreeList
            tree := (TreeList)sender 
            LOCAL  hi := tree:CalcHitInfo(tree:PointToClient(System.Windows.Forms.Control.MousePosition)) AS TreeListHitInfo
            IF hi:Node != NULL 
               //process hi.Node here
			   //wb(hi:Node:Tag)
			   IF(hi:Node:StateImageIndex==1)// Time
					//WB("Time : "+hi:Node:Tag:ToString())
					SELF:lisTC := TRUE
					SELF:cTCParent := hi:Node:Tag:ToString()
					//self:TreeListVesselsReports:Visible :=false
					//SELF:treeListTCReports:Visible := TRUE
					SELF:backBBI:Enabled := TRUE
					SELF:Fill_TreeList_Reports()
			   ENDIF
            ENDIF
RETURN

METHOD CheckForProgramVersions() AS VOID
	LOCAL cLocalAutoUpdatePath := oSoftway:GetLocalAutoUpdatePath(symServer, SELF:oGFH, SELF:oConn, FALSE) AS STRING
	IF cLocalAutoUpdatePath == "" .AND. System.IO.File.Exists(Application.StartupPath + "\AutoUpdate.exe")
		TRY
			// try to delete the AutoUpdate program, since it is not needed anymore
			System.IO.File.Delete(Application.StartupPath + "\AutoUpdate.exe")
		CATCH //ex AS Exception
		END TRY
	ENDIF

/*	// Check if this is the first run of the new version to update the SQL Tables
	LOCAL cStatement, cVersion, cUID AS STRING
	LOCAL nTimes AS INT
	LOCAL oSWCrypt32 := SWCrypt32{} AS SWCrypt32

	cStatement:="SELECT NETWORK_UNIQUEID, Field_6 FROM Network"+;
				" ORDER BY NETWORK_UNIQUEID"
	LOCAL oNet:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	FOREACH oRow AS DataRow IN oNet:Rows
		cUID := oRow:Item["NETWORK_UNIQUEID"]:ToString()
		cVersion := oSoftway:GetBinaryField(oMainForm:oGFH, oMainForm:oConn, "Network", "Field_6", cUID, oRow, 10, oSWCrypt32):Trim()
		IF ! StringIsNumeric(cVersion, ".")
			cVersion := ""
		ENDIF
		IF cProgramVersion == cVersion
			nTimes++
		ENDIF
	NEXT
	IF nTimes == 1
		wb("The program will now check for Database changes", "New version installed")
		oMainForm:CheckAddMissingTables_Columns()
	ENDIF*/
RETURN


METHOD ConnectToSoftwayDatabase() AS LOGIC
IF oSoftway:UserLogonInfoProvided
	IF ! SELF:_InitializeSqlServer()
		SELF:Close()
		RETURN FALSE
	ENDIF
ELSE
	LOCAL oLogonDialog AS LogonDialog
	IF SELF:_InitializeSqlServer()
		IF ! lLogonSelectionFormUsed .AND. (oUser:lShowLogonDialog .OR. oUser:Password <> "")	// .and. symServer <> #SQLCE)
			// Use the simple Logon dialog - 1st logon try
			SELF:CloseSplashScreen()
			Application.DoEvents()
			oLogonDialog:=LogonDialog{}
			oLogonDialog:Text := Application.ProductName+" logon dialog"
			oLogonDialog:ShowDialog()
			IF oLogonDialog:DialogResult <> System.Windows.Forms.DialogResult.OK
				SELF:lUserLoggedOn:=FALSE
				SELF:Close()
				RETURN FALSE
			ENDIF
			IF ! SELF:_InitializeSqlServer()
				// Use the simple Logon dialog - 2nd logon try
				SELF:CloseSplashScreen()
				Application.DoEvents()
				oLogonDialog:=LogonDialog{}
				oLogonDialog:Text := Application.ProductName+" logon dialog"
				oLogonDialog:ShowDialog()
				IF oLogonDialog:DialogResult <> System.Windows.Forms.DialogResult.OK
					SELF:lUserLoggedOn:=FALSE
					SELF:Close()
					RETURN FALSE
				ENDIF
				IF ! SELF:_InitializeSqlServer()
					SELF:Close()
					RETURN FALSE
				ENDIF
			ENDIF
		ENDIF
	ELSE
		// Use the simple Logon dialog from now on
		SELF:CloseSplashScreen()
		Application.DoEvents()
		oLogonDialog:=LogonDialog{}
		oLogonDialog:Text := Application.ProductName+" logon dialog"
		oLogonDialog:ShowDialog()
		IF oLogonDialog:DialogResult <> System.Windows.Forms.DialogResult.OK
			SELF:lUserLoggedOn:=FALSE
			SELF:Close()
			RETURN FALSE
		ENDIF
		IF ! SELF:_InitializeSqlServer()
			SELF:Close()
			RETURN FALSE
		ENDIF
	ENDIF
ENDIF

	IF ! oSoftway:TableExists(SELF:oGFH, SELF:oConn, "EconFleet") .OR. ! oSoftway:TableExists(SELF:oGFH, SELF:oConn, "EconRoutings") 
		SELF:CloseSplashScreen()
		WarningBox("Some Tables are missing"+CRLF+;
						"Press <OK> to create the Tables")
		oSQLTablesCreator:=SQLTablesCreator{}
		IF ! oSQLTablesCreator:CreateTables(SELF:oGFH, SELF:oConn)
			RETURN FALSE
		ENDIF
	ENDIF

	IF ! oSoftway:TableExists(SELF:oGFH, SELF:oConn, "FMVoyageLinks") 
		SELF:CloseSplashScreen()
		WarningBox("Some Tables are missing"+CRLF+;
						"Press <OK> to create the Tables")
		oSQLTablesCreator:=SQLTablesCreator{}
		IF ! oSQLTablesCreator:CreateTables(SELF:oGFH, SELF:oConn)
			RETURN FALSE
		ENDIF
	ENDIF
	
	IF ! oSoftway:TableExists(SELF:oGFH, SELF:oConn, "FMUsers") 
		SELF:CloseSplashScreen()
		WarningBox("FMUsers Table is missing"+CRLF+;
						"Press <OK> to create the Table.")
		oSQLTablesCreator:=SQLTablesCreator{}
		IF ! oSQLTablesCreator:CreateTables(SELF:oGFH, SELF:oConn)
			RETURN FALSE
		ENDIF
	ENDIF
	
	////////////////////////////////////////////////////////////////
	//ADDED BY KIRIAKOS AT 31/05/16
	////////////////////////////////////////////////////////////////
	IF ! oSoftway:TableExists(SELF:oGFH, SELF:oConn, "FMUserGroups") 
		SELF:CloseSplashScreen()
		WarningBox("FMUsers Table is missing"+CRLF+;
						"Press <OK> to create the Table.")
		oSQLTablesCreator:=SQLTablesCreator{}
		IF ! oSQLTablesCreator:CreateTables(SELF:oGFH, SELF:oConn)
			RETURN FALSE
		ENDIF
		//Transfer the data from CrewUserGroupLinks
		SELF:TransferDataBetweenTables("CrewUserGroups", "FMUserGroups")
	ENDIF

	IF ! oSoftway:TableExists(SELF:oGFH, SELF:oConn, "FMUserGroupLinks") 
		SELF:CloseSplashScreen()
		WarningBox("FMUsers Table is missing"+CRLF+;
						"Press <OK> to create the Table.")
		oSQLTablesCreator:=SQLTablesCreator{}
		IF ! oSQLTablesCreator:CreateTables(SELF:oGFH, SELF:oConn)
			RETURN FALSE
		ENDIF
		//Transfer the data from CrewUserGroupLinks
		SELF:TransferDataBetweenTables("CrewUserGroupLinks", "FMUserGroupLinks")
	ENDIF
	////////////////////////////////////////////////////////////////
	//ADDED BY KIRIAKOS AT 31/05/16
	////////////////////////////////////////////////////////////////


	IF ! oSoftway:TableExists(SELF:oGFH, SELF:oConn, "FMGlobalSettings") 
		SELF:CloseSplashScreen()
		WarningBox("FMGlobalSettings Table is missing"+CRLF+;
						"Press <OK> to create the Table.")
		oSQLTablesCreator:=SQLTablesCreator{}
		IF ! oSQLTablesCreator:CreateTables(SELF:oGFH, SELF:oConn)
			RETURN FALSE
		ENDIF
	ENDIF

	IF ! oSoftway:TableExists(SELF:oGFH, SELF:oConn, "DMFLists") 
		SELF:CloseSplashScreen()
		WarningBox("Lists Table is missing"+CRLF+;
						"Press <OK> to create the Table.")
		oSQLTablesCreator:=SQLTablesCreator{}
		IF ! oSQLTablesCreator:CreateTables_DMFListsTables(SELF:oGFH, SELF:oConn)
			RETURN FALSE
		ENDIF
	ENDIF

	IF ! oSoftway:TableExists(SELF:oGFH, SELF:oConn, "FMTrueGlobalSettings") 
		SELF:CloseSplashScreen()
		WarningBox("Global Settings Table is missing"+CRLF+;
						"Press <OK> to create the Table.")
		oSQLTablesCreator:=SQLTablesCreator{}
		IF ! oSQLTablesCreator:CreateTables(SELF:oGFH, SELF:oConn)
			RETURN FALSE
		ENDIF
	ENDIF
	
	////////////////////////////////////////////////////////////////
	//CHANGED BY KIRIAKOS AT 01/06/16
	////////////////////////////////////////////////////////////////
	SELF:_InitializeSqlServerBlob()
	//	SELF:CreateFMBlobData(FALSE)
	//	//Clear Connection
	//	SELF:ClearConnectionBlob()
	//	RETURN false
	// ENDIF
	////////////////////////////////////////////////////////////////
	//CHANGED BY KIRIAKOS AT 01/06/16
	////////////////////////////////////////////////////////////////
	//IF (SELF:oConnBlob == NULL .OR. SELF:oConnBlob:State == ConnectionState.Closed)
	//	WB(SELF:oConnBlob:State:ToString())	
	//ENDIF

	IF ! oSoftway:TableExists(SELF:oGFH, SELF:oConn, "Cargoes") .OR.  ! oSoftway:TableExists(SELF:oGFH, SELF:oConn, "FMCargoRoutingLink") .OR.  ! oSoftway:TableExists(SELF:oGFH, SELF:oConn, "CargoesTypes")
		SELF:CloseSplashScreen()
		WarningBox("Cargo Tables is missing"+CRLF+;
						"Press <OK> to create the Table.")
		oSQLTablesCreator:=SQLTablesCreator{}
		IF ! oSQLTablesCreator:CreateTables(SELF:oGFH, SELF:oConn)
			RETURN FALSE
		ENDIF
	ENDIF

	IF ! oSoftway:TableExists(SELF:oGFH, SELF:oConn, "FMOfficeReportItems")
		SELF:CloseSplashScreen()
		WarningBox("Office Reports table is missing"+CRLF+;
						"Press <OK> to create the Table.")
		oSQLTablesCreator:=SQLTablesCreator{}
		IF ! oSQLTablesCreator:CreateTables(SELF:oGFH, SELF:oConn)
			RETURN FALSE
		ENDIF
	ENDIF
	
	IF ! oSoftway:TableExists(SELF:oGFH, SELF:oConn, "ApprovalData")
		SELF:CloseSplashScreen()
		WarningBox("Approval table is missing"+CRLF+;
						"Press <OK> to create the Table.")
		oSQLTablesCreator:=SQLTablesCreator{}
		IF ! oSQLTablesCreator:CreateTables(SELF:oGFH, SELF:oConn)
			RETURN FALSE
		ENDIF
	ENDIF

	
	IF ! oSoftway:TableExists(SELF:oGFH, SELF:oConn, "FMComboboxColors")
		SELF:CloseSplashScreen()
		WarningBox("Approval table is missing"+CRLF+;
						"Press <OK> to create the Table.")
		oSQLTablesCreator:=SQLTablesCreator{}
		IF ! oSQLTablesCreator:CreateTables(SELF:oGFH, SELF:oConn)
			RETURN FALSE
		ENDIF
	ENDIF

	IF ! oSoftway:TableExists(SELF:oGFH, SELF:oConn, "FMReportChangeLog")
		SELF:CloseSplashScreen()
		WarningBox("Report Change Log table is missing"+CRLF+;
						"Press <OK> to create the Table.")
		oSQLTablesCreator:=SQLTablesCreator{}
		IF ! oSQLTablesCreator:CreateTables(SELF:oGFH, SELF:oConn)
			RETURN FALSE
		ENDIF
	ENDIF

	IF ! oSoftway:TableExists(SELF:oGFH, SELF:oConn, "FMRoutingAdditionalData")
		SELF:CloseSplashScreen()
		WarningBox("FM Reports Additional Data table is missing"+CRLF+;
						"Press <OK> to create the Table.")
		oSQLTablesCreator:=SQLTablesCreator{}
		IF ! oSQLTablesCreator:CreateTables(SELF:oGFH, SELF:oConn)
			RETURN FALSE
		ENDIF
	ENDIF

	SELF:AddMissingColumns()

RETURN TRUE

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//							ADDED BY KIRIAKOS
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
METHOD TransferHeadUserColumnData() AS VOID
	LOCAL cStatement AS STRING
	cStatement:="SELECT USER_UID, HeadUser, UserName FROM CrewUsers"
	LOCAL oDTCrewUsers := oSoftway:ResultTable(SELF:oGFH, SELF:oConn, cStatement) AS DataTable

	IF oDTCrewUsers:Rows:Count == 0
		RETURN
	ENDIF

	LOCAL n AS INT
	FOR n:=0 UPTO oDTCrewUsers:Rows:Count - 1
		cStatement:="UPDATE FMUsers"+;
					" SET IsHeadUser='"+oDTCrewUsers:Rows[n]:Item["HeadUser"]:ToString()+"'"+;
					" WHERE USER_UNIQUEID="+oDTCrewUsers:Rows[n]:Item["USER_UID"]:ToString()
		oSoftway:AdoCommand(SELF:oGFH, SELF:oConn, cStatement)
		//IF oSoftway:AdoCommand(SELF:oGFH, SELF:oConn, cStatement)
		//	ErrorBox("Could not Update User: ["+oDTCrewUsers:Rows[n]:Item["UserName"]:ToString():Trim()+"]")		
		//ENDIF
	NEXT
RETURN

METHOD SetCategoriesSortOrder() AS VOID
	LOCAL cStatement AS STRING

	cStatement:="SELECT CATEGORY_UID, Description, SortOrder"+;
				" FROM FMItemCategories"+oMainForm:cNoLockTerm+;
				" ORDER BY Description"
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

	LOCAL nSortOrder := 0 AS INT
	FOREACH oRow AS DataRow IN oDT:Rows
		nSortOrder++
		cStatement:="UPDATE FMItemCategories SET SortOrder="+nSortOrder:ToString()+;
					" WHERE CATEGORY_UID="+oRow["CATEGORY_UID"]:ToString()
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
	NEXT
RETURN


METHOD _InitializeSqlServer() AS LOGIC
	LOCAL cStatement AS STRING
	LOCAL cConnectionString AS STRING
	LOCAL oDT AS DataTable

TRY
	// Create a FactorySQL object
	SELF:oGFH:=GenericFactoryHelper{}	//"MSSQL"}
	// Create a SQL Connection object (Provider agnostic)
	SELF:oConn:=SELF:oGFH:Connection()
	//cStatement:=SELF:oGFH:ConnectionString(SELF:cSDF)

// Check and create Database
	LOCAL lDatabaseJustCreated AS LOGIC
	DO CASE
	CASE symServer == #SQLCE
		// Check and create SqlCe SOFTWAY.SDF Database
		// Read the Database name and location
		LOCAL oIniFile:=IniFile{cStartupPath+"\SOFTWAY.INI"} AS IniFile
		LOCAL cDB AS STRING
		cDB:=oIniFile:GetString("SQLConnect", "SQLInitialCatalog")
		IF cDB <> ""
			SELF:cSDF:=cDB
		ENDIF
		IF ! SELF:cSDF:Contains("\")
			SELF:cSDF:=cStartupPath+"\"+SELF:cSDF
		ENDIF
		IF ! SELF:cSDF:ToUpper():Contains(".SDF")
			SELF:cSDF:=SELF:cSDF+".SDF"
		ENDIF

		// Set the Connection string for the Try-Catch error hadling
		cStatement:=SELF:oGFH:ConnectionString(SELF:cSDF)

		IF ! System.IO.File.Exists(cSDF)
			SELF:CloseSplashScreen()
			lDatabaseJustCreated:=oSoftway:SqlCe_CreateDatabase(SELF:cSDF)
		ENDIF

	CASE symServer == #SQLite
		// Check and create SQLite SOFTWAY.SDF Database
		// Read the Database name and location
		LOCAL oIniFileLite:=IniFile{cStartupPath+"\SOFTWAY.INI"} AS IniFile
		LOCAL cDBLite AS STRING
		cDBLite:=oIniFileLite:GetString("SQLConnect", "SQLInitialCatalog")
		IF cDBLite <> ""
			SELF:cSDF:=cDBLite
		ENDIF
		IF ! SELF:cSDF:Contains("\")
			SELF:cSDF:=cStartupPath+"\"+SELF:cSDF
		ENDIF
		IF ! SELF:cSDF:ToUpper():Contains(".DB")
			SELF:cSDF:=SELF:cSDF+".DB"
		ENDIF

		// Set the Connection string for the Try-Catch error hadling
		cStatement:=SELF:oGFH:ConnectionString(SELF:cSDF)

		IF ! System.IO.File.Exists(cSDF)
			SELF:CloseSplashScreen()
			lDatabaseJustCreated:=oSoftway:SQLite_CreateDatabase(SELF:cSDF)
		ENDIF

	CASE symServer == #MSSQL
		cStatement:=SELF:oGFH:ConnectionString(SELF:cSDF)
   		cStatement := cStatement:Replace("User Id="+cSQLUserName+";Password="+cSQLPassword, "User Id="+cSoftwaySQLUserName+";Password="+cSoftwaySQLPassword)
     	SELF:oConn:ConnectionString:=cStatement
		SELF:oConn:Open()

		IF MSSQL2000
			cStatement:="SELECT * FROM master.dbo.sysdatabases WHERE Name = '"+cSQLInitialCatalog+"'"
		ELSE
			cStatement:="SELECT * FROM SYS.DATABASES WHERE Name = '"+cSQLInitialCatalog+"'"
		ENDIF
		oDT:=oSoftway:ResultTable(SELF:oGFH, SELF:oConn, cStatement)

		IF oDT:Rows:Count == 0
			SELF:CloseSplashScreen()
			lDatabaseJustCreated:=oSoftway:SQLCommon_CreateDatabase(SELF:oGFH, SELF:oConn)
			IF ! lDatabaseJustCreated
				BREAK
			ENDIF
		ENDIF

	CASE symServer == #MySQL
		cConnectionString := "Server="+cSQLDataSource:ToLower()+";Database=information_schema;User Id="+cSoftwaySQLUserName:ToLower()+";Password="+cSoftwaySQLPassword+";Port="+cSQLPort
		SELF:oConn:ConnectionString:=cConnectionString
		SELF:oConn:Open()

		cStatement:="SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '"+cSQLInitialCatalog+"'"
		oDT:=oSoftway:ResultTable(SELF:oGFH, SELF:oConn, cStatement)
		IF oDT:Rows:Count == 0
			SELF:CloseSplashScreen()
			lDatabaseJustCreated:=oSoftway:SQLCommon_CreateDatabase(SELF:oGFH, SELF:oConn)
			IF ! lDatabaseJustCreated
				BREAK
			ENDIF
		ENDIF
	ENDCASE
	// Try to close the Connection in any case before initialize a SOFTWAY Connection

	SELF:ClearConnection()

	// Open Database Connection to SOFTWAY
	cStatement:=SELF:oGFH:ConnectionString(SELF:cSDF)
	cStatement := cStatement:Replace("User Id="+cSQLUserName+";Password="+cSQLPassword, "User Id="+cSoftwaySQLUserName+";Password="+cSoftwaySQLPassword)
	SELF:oConn:ConnectionString:=cStatement
	SELF:oConn:Open()

	DO CASE
		CASE symServer == #MySQL
			oSoftway:AdoCommand(SELF:oGFH, SELF:oConn, "SET NAMES '"+cSQLLanguage+"' COLLATE '"+cGlobalSQLCollation+"'")
			oSoftway:AdoCommand(SELF:oGFH, SELF:oConn, "SET CHARACTER SET "+cSQLLanguage)
	ENDCASE

	IF lDatabaseJustCreated
		// Create SOFTWAY Tables
		IF ! oSoftway:CreateAllSoftwayTables(SELF:oGFH, SELF:oConn)
			BREAK
		ENDIF
	ENDIF


	// Read the User settings from USERS table
	oUser := UserSettings{SELF:oGFH, SELF:oConn, cSQLUserName, oSoftway}
	IF oUser:lUnknown
		BREAK
	ENDIF
	
	IF oUser:DefaultGroup == 0
		ErrorBox("No DefaultGroup defined for User: "+oUser:UserName, "Access denied")
		BREAK
	ENDIF

	IF cSQLPassword <> oUser:Password .AND. symServer <> #SQLCE .AND. symServer <> #SQLite
		ErrorBox("Invalid password"+CRLF+;
				"The SQL Authentication password is different from Softway User password", "Logon failed")
		//Self:Close()
		RETURN FALSE
	ENDIF

	SELF:lUserLoggedOn:=TRUE
	oMsgGlobals:=MsgGlobals{oSoftway, SELF:oGFH, SELF:oConn}
	oUser:ReadAllUsers(oSoftway, SELF:oGFH, SELF:oConn, oMsgGlobals)

CATCH e AS Exception
	SELF:CloseSplashScreen()
	ErrorBox(e:Message, "SQL Authentication error")
	RETURN FALSE
END TRY
RETURN TRUE


METHOD ClearConnection() AS VOID
	IF ! SELF:oConn == NULL
		IF SELF:oConn:State == ConnectionState.Open
			SELF:oConn:Close()
		ENDIF
	ENDIF
RETURN

//////////////////////////////////////////////////////////////////////////////////////
//ADDED BY KIRIAKOS AT 01/06/16 in order to support attachments to different DataBase
//////////////////////////////////////////////////////////////////////////////////////
METHOD _InitializeSqlServerBlob() AS LOGIC
	LOCAL cStatement AS STRING
	LOCAL cConnectionString AS STRING
	LOCAL oDT AS DataTable
	LOCAL oIniFile:=IniFile{cStartupPath+"\SOFTWAY.INI"} AS IniFile
	cSQLInitialCatalog := oIniFile:GetString("SQLConnect", "SQLInitialCatalog")+"Blob"
TRY
	// Create a FactorySQL object
	SELF:oGFHBlob := GenericFactoryHelper{}	//"MSSQL"}
	// Create a SQL Connection object (Provider agnostic)
	SELF:oConnBlob := SELF:oGFHBlob:Connection()
	//cStatement:=SELF:oGFH:ConnectionString(SELF:cSDF)

// Check and create Database
	LOCAL lDatabaseJustCreated AS LOGIC
	DO CASE
	CASE symServer == #SQLCE
		// Check and create SqlCe SOFTWAY.SDF Database
		// Read the Database name and location
		//LOCAL oIniFile:=IniFile{cStartupPath+"\SOFTWAY.INI"} AS IniFile
		LOCAL cDB AS STRING
		//cDB := oIniFile:GetString("SQLConnect BLOB", "SQLInitialCatalog")
		cDB :=  oIniFile:GetString("SQLConnect", "SQLInitialCatalog")+"Blob"
		IF cDB <> ""
			SELF:cSDFBlob := cDB
		ENDIF
		IF ! SELF:cSDFBlob:Contains("\")
			SELF:cSDFBlob := cStartupPath+"\"+SELF:cSDFBlob
		ENDIF
		IF ! SELF:cSDFBlob:ToUpper():Contains(".SDF")
			SELF:cSDFBlob := SELF:cSDFBlob+".SDF"
		ENDIF

		// Set the Connection string for the Try-Catch error hadling
		cStatement := SELF:oGFHBlob:ConnectionString(SELF:cSDFBlob)

		IF ! System.IO.File.Exists(cSDFBlob)
			//SELF:CloseSplashScreen()
			lDatabaseJustCreated := oSoftway:SqlCe_CreateDatabase(SELF:cSDFBlob)
		ENDIF

	CASE symServer == #SQLite
		// Check and create SQLite SOFTWAY.SDF Database
		// Read the Database name and location
		LOCAL oIniFileLite := IniFile{cStartupPath+"\SOFTWAY.INI"} AS IniFile
		LOCAL cDBLite AS STRING
		cDBLite := oIniFile:GetString("SQLConnect", "SQLInitialCatalog")+"Blob"
		
		IF cDBLite <> ""
			SELF:cSDFBlob := cDBLite
		ENDIF
		IF ! SELF:cSDFBlob:Contains("\")
			SELF:cSDFBlob := cStartupPath+"\"+SELF:cSDFBlob
		ENDIF
		IF ! SELF:cSDFBlob:ToUpper():Contains(".DB")
			SELF:cSDFBlob := SELF:cSDFBlob+".DB"
		ENDIF

		// Set the Connection string for the Try-Catch error hadling
		cStatement := SELF:oGFHBlob:ConnectionString(SELF:cSDFBlob)

		IF ! System.IO.File.Exists(cSDFBlob)
			//SELF:CloseSplashScreen()
			lDatabaseJustCreated := oSoftway:SQLite_CreateDatabase(SELF:cSDFBlob)
		ENDIF

	CASE symServer == #MSSQL

		cConnectionString := "Server="+cSQLDataSource+";Database=Master;User Id="+cSoftwaySQLUserName+";Password="+cSoftwaySQLPassword+";"
		SELF:oConnBlob:ConnectionString:=cConnectionString
		SELF:oConnBlob:Open()

		IF MSSQL2000
			cStatement:="SELECT * FROM master.dbo.sysdatabases WHERE Name = '"+cSQLInitialCatalog+"'"
		ELSE
			cStatement:="SELECT * FROM SYS.DATABASES WHERE Name = '"+cSQLInitialCatalog+"'"
		ENDIF
		//WB(cStatement)
		oDT := oSoftway:ResultTable(SELF:oGFHBlob, SELF:oConnBlob, cStatement)

		//WB("Rows="+oDT:Rows:Count:ToString())
		IF oDT:Rows:Count == 0
			//SELF:CloseSplashScreen()
			lDatabaseJustCreated := SELF:CreateSoftwayBlobDatabase(cSQLInitialCatalog)//oSoftway:SQLCommon_CreateDatabase(SELF:oGFHBlob, SELF:oConnBlob)
			IF ! lDatabaseJustCreated
				BREAK
			ENDIF
		ENDIF

	CASE symServer == #MySQL
		// Open Database Connection to INFORMATION_SCHEMA
//		cConnectionString := "Server="+cSQLDataSource:ToLower()+";Database=information_schema;User Id="+cSQLUserName:ToLower()+";Password="+cSQLPassword+";"
		cConnectionString := "Server="+cSQLDataSource:ToLower()+";Database=information_schema;User Id="+cSoftwaySQLUserName:ToLower()+";Password="+cSoftwaySQLPassword+";Port="+cSQLPort
		SELF:oConnBlob:ConnectionString := cConnectionString
		SELF:oConnBlob:Open()

		cStatement:="SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '"+cSQLInitialCatalog+"'"
		oDT := oSoftway:ResultTable(SELF:oGFHBlob, SELF:oConnBlob, cStatement)
		IF oDT:Rows:Count == 0
			//SELF:CloseSplashScreen()
			lDatabaseJustCreated := SELF:CreateSoftwayBlobDatabase(cSQLInitialCatalog)//oSoftway:SQLCommon_CreateDatabase(SELF:oGFHBlob, SELF:oConnBlob)
			IF ! lDatabaseJustCreated
				BREAK
			ENDIF
		ENDIF
	ENDCASE
	// Try to close the Connection in any case before initialize a SOFTWAY Connection

	SELF:ClearConnectionBlob()
	cStatement := SELF:oGFHBlob:ConnectionString(SELF:cSDFBlob)
	cStatement := cStatement:Replace("User Id="+cSQLUserName+";Password="+cSQLPassword, "User Id="+cSoftwaySQLUserName+";Password="+cSoftwaySQLPassword)
	SELF:oConnBlob:ConnectionString := cStatement
	//wb(SELF:oConn:ConnectionString)
	SELF:oConnBlob:Open()

	DO CASE
		CASE symServer == #MySQL
			oSoftway:AdoCommand(SELF:oGFHBlob, SELF:oConnBlob, "SET NAMES '"+cSQLLanguage+"' COLLATE '"+cGlobalSQLCollation+"'")
			oSoftway:AdoCommand(SELF:oGFHBlob, SELF:oConnBlob, "SET CHARACTER SET "+cSQLLanguage)
	ENDCASE

	IF lDatabaseJustCreated
		IF ! SELF:CreateFMBlobData(cSQLInitialCatalog:Replace("Blob",""),cSQLInitialCatalog, lDatabaseJustCreated)
			BREAK
		ENDIF
	ENDIF

	IF cSQLPassword <> oUser:Password .AND. symServer <> #SQLCE .AND. symServer <> #SQLite
		ErrorBox("Invalid password"+CRLF+;
				"The SQL Authentication password is different from Softway User password", "Logon failed")
		//Self:Close()
		RETURN FALSE
	ENDIF

	//SELF:lUserLoggedOn := TRUE
	//oMsgGlobals:=MsgGlobals{oSoftway, SELF:oGFH, SELF:oConn}
	//oUser:ReadAllUsers(oSoftway, SELF:oGFH, SELF:oConn, oMsgGlobals)

CATCH e AS Exception
	//SELF:CloseSplashScreen()
	//WB("Error")
	ErrorBox(e:Message, "SQL Authentication error")
	RETURN FALSE
END TRY
RETURN TRUE
METHOD ClearConnectionBlob() AS VOID
	IF ! SELF:oConnBlob == NULL
		IF SELF:oConnBlob:State == ConnectionState.Open
			SELF:oConnBlob:Close()
		ENDIF
	ENDIF
RETURN

METHOD CreateSoftwayBlobDatabase(cSQLInitialCatalog AS STRING) AS LOGIC
	LOCAL cStatement AS STRING
	DO CASE
		CASE symServer == #MSSQL
			cStatement:="Create Database "+cSQLInitialCatalog
			IF ! oSoftway:AdoCommand(SELF:oGFHBlob, SELF:oConnBlob, cStatement)
				ErrorBox("Cannot create Database ["+cSQLInitialCatalog+"]", "Creation Aborted")
				RETURN FALSE
			ENDIF
			
			cStatement:="ALTER DATABASE ["+cSQLInitialCatalog+"] SET RECOVERY Simple "  
			IF ! oSoftway:AdoCommand(SELF:oGFHBlob, SELF:oConnBlob, cStatement)
				ErrorBox("Cannot create Database ["+cSQLInitialCatalog+"]", "Creation Aborted")
				RETURN FALSE
			ENDIF

			//MessageBox.Show("DatabaseCreated")

		CASE symServer == #MySQL
			cStatement:="CREATE DATABASE IF NOT EXISTS `"+cSQLInitialCatalog+"`;"
			IF ! oSoftway:AdoCommand(SELF:oGFHBlob, SELF:oConnBlob, cStatement)
				ErrorBox("Cannot create Database ["+cSQLInitialCatalog+"]", "Creation Aborted")
				RETURN FALSE
			ENDIF
	END CASE
RETURN TRUE

METHOD CreateFMBlobData(cSoftwayDB AS STRING, cBlobDB AS STRING ,lDatabaseJustCreated AS LOGIC) AS LOGIC
	LOCAL cStatement AS STRING
	IF ! oSoftway:TableExists(SELF:oGFHBlob, SELF:oConnBlob, "FMBlobData")
		IF ! lDatabaseJustCreated
			WarningBox("FMBlobData Table is missing"+CRLF+;
							"Press <OK> to create the Table.")
		ENDIF
		cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMBlobData ("+;
					"PACKAGE_UID		int NOT NULL,"+;
					"ITEM_UID			int NOT NULL,"+;
					"FileName			"+oSoftway:FieldVarChar+" (256) NOT NULL,"+;
					"BlobData			"+oSoftway:FieldImage+" NULL, "+;
					"USER_UNIQUEID		int NOT NULL Default 0,"+;
					"Visible			smallint NOT NULL Default 1,"+;
					"PRIMARY KEY (PACKAGE_UID, ITEM_UID, FileName, Visible) "+;
		") "+oSoftway:cTableDefaults
		IF ! oSoftway:AdoCommand(SELF:oGFHBlob, SELF:oConnBlob, cStatement)
			ErrorBox("Cannot create table [FMBlobData]", "Creation Aborted")
			SELF:ClearConnectionBlob()
			RETURN FALSE
		ENDIF
	ENDIF
	
	//Check if previous FMBlobData had records
	cStatement:="SELECT Count(*) AS nCount FROM FMBlobData"

	LOCAL cCount := oSoftway:RecordExists(SELF:oGFH, SELF:oConn, cStatement, "nCount") AS STRING

	IF cCount <> "0"
		cStatement:="INSERT INTO "+cBlobDB+".dbo.FMBlobData"+;
					" SELECT * FROM "+cSoftwayDB+".dbo.FMBlobData"	
		oSoftway:AdoCommand(SELF:oGFHBlob, SELF:oConnBlob, cStatement)
		//IF ! oSoftway:AdoCommand(SELF:oGFHBlob, SELF:oConnBlob, cStatement)
		//	ErrorBox("Cannot create table [FMBlobData]", "Creation Aborted")
		//	RETURN FALSE
		//ENDIF
	ENDIF
RETURN TRUE


METHOD TransferDataBetweenTables(cSource AS STRING, cTarget AS STRING) AS VOID
	LOCAL cStatement AS STRING
	cStatement:="INSERT INTO "+cTarget+;
				" SELECT * FROM "+cSource
	IF oSoftway:AdoCommand(SELF:oGFH, SELF:oConn, cStatement)
		ErrorBox("Could not transfer the data from table ["+cSource+"]"+CRLF+"to table ["+cTarget+"]")	
	ENDIF
RETURN
//////////////////////////////////////////////////////////////////////////////////////
//ADDED BY KIRIAKOS AT 01/06/16 in order to support attachments to different DataBase
//////////////////////////////////////////////////////////////////////////////////////


METHOD ReadFleetManagerIniFile() AS LOGIC
	LOCAL cIniFile := cStartupPath+"\SOFTWAY.INI" AS STRING
	LOCAL oIniFile := IniFile{cIniFile} AS IniFile

	TRY
		SELF:nThickness := (INT)oIniFile:GetInt("Setup", "MapMargin")
		IF SELF:nThickness == 0
			SELF:nThickness := 70
			oIniFile:SetInt("Setup", "MapMargin", SELF:nThickness)
		ENDIF

	CATCH e AS Exception
		ErrorBox("Error reading [Setup].MapMargin section in "+cStartupPath+"\SOFTWAY.INI"+CRLF+CRLF+e:Message)
		RETURN FALSE
	END TRY
RETURN TRUE


METHOD Fill_LBCReports(cVesselUID AS STRING) AS VOID
	// Selected item
	LOCAL cSelectedValue AS STRING
	IF SELF:ReportsTabUserControl:SelectedIndex == 0
				LBCReports := SELF:LBCReportsVessel
			ELSE
				LBCReports := SELF:LBCReportsOffice
	ENDIF
	IF SELF:LBCReports:SelectedValue <> NULL
		cSelectedValue := SELF:LBCReports:SelectedValue:ToString()
	ENDIF
	SELF:LBCReportsVessel:Items:Clear()
	SELF:LBCReportsOffice:Items:Clear()
	
	IF cVesselUID == NULL
		RETURN
	ENDIF	
	
	//LOCAL cVesselUID AS STRING
	LOCAL cStatement AS STRING

	//TRY
	//	cVesselUID := SELF:CheckedLBCVessels:SelectedValue:ToString()
	//CATCH
	//END TRY
	//LOCAL vLocalVesselUID := SELF:TreeListVessels:FocusedNode:Tag:ToString() AS STRING
	IF cVesselUID == NULL
		cStatement:="SELECT FMReportTypes.*"+;
					" FROM FMReportTypes"+SELF:cNoLockTerm+;
					" WHERE ReportType='V' AND Report_UID IN "+;
					" ( SELECT DISTINCT Report_UID FROM [FMReportTypesVessel],SupVessels Where FMReportTypesVessel.Vessel_UniqueId = SupVessels.Vessel_UniqueId AND Active=1 )"+;
					" ORDER BY ReportBaseNum"
	ELSE
		cStatement:="SELECT FMReportTypes.*"+;
					" FROM FMReportTypes"+SELF:cNoLockTerm+;
					" INNER JOIN FMReportTypesVessel ON FMReportTypes.REPORT_UID=FMReportTypesVessel.REPORT_UID"+;
					" AND ReportType='V' AND FMReportTypesVessel.VESSEL_UNIQUEID="+cVesselUID+;
					" ORDER BY ReportBaseNum"
	ENDIF
	SELF:oDTReports := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	oSoftway:CreatePK(SELF:oDTReports, "REPORT_UID")

	IF cVesselUID == NULL
		cStatement:="SELECT FMReportTypes.*"+;
					" FROM FMReportTypes"+SELF:cNoLockTerm+;
					" WHERE ReportType='O' AND Report_UID IN "+;
					" ( SELECT DISTINCT Report_UID FROM [FMReportTypesVessel],SupVessels Where FMReportTypesVessel.Vessel_UniqueId = SupVessels.Vessel_UniqueId AND Active=1 )"+;
					" ORDER BY ReportBaseNum"
	ELSE
		cStatement:="SELECT FMReportTypes.*"+;
					" FROM FMReportTypes"+SELF:cNoLockTerm+;
					" INNER JOIN FMReportTypesVessel ON FMReportTypes.REPORT_UID=FMReportTypesVessel.REPORT_UID"+;
					" AND ReportType='O' AND FMReportTypesVessel.VESSEL_UNIQUEID="+cVesselUID+;
					" ORDER BY ReportBaseNum"
	ENDIF

	SELF:oDTReportsOffice := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	oSoftway:CreatePK(SELF:oDTReportsOffice, "REPORT_UID")

	IF SELF:ReportsTabUserControl:SelectedIndex == 0
				LBCReports := SELF:LBCReportsVessel
			ELSE
				LBCReports := SELF:LBCReportsOffice
	ENDIF	

	SELF:LBCReportsVessel:DataSource := SELF:oDTReports
	SELF:LBCReportsVessel:DisplayMember := "ReportName"
	SELF:LBCReportsVessel:ValueMember := "REPORT_UID"
	SELF:LBCReportsVessel:Refresh()

	SELF:LBCReportsOffice:DataSource := SELF:oDTReportsOffice
	SELF:LBCReportsOffice:DisplayMember := "ReportName"
	SELF:LBCReportsOffice:ValueMember := "REPORT_UID"
	SELF:LBCReportsOffice:Refresh()


	IF ! STRING.IsNullOrEmpty(cSelectedValue)
		SELF:LBCReports:SelectedValue := cSelectedValue
	ELSEIF SELF:cLastMainSelection <> ""
		// Select the last selected Report
		LOCAL cReportName AS STRING
		LOCAL nPos := SELF:cLastMainSelection:IndexOf("|") AS INT
		IF nPos == -1
			cReportName := SELF:cLastMainSelection
		ELSE
			cReportName := SELF:cLastMainSelection:Substring(0, nPos)
		ENDIF
		//SELF:cLastMainSelection += "|"+SELF:CheckedLBCVessels:GetDisplayItemValue(SELF:CheckedLBCVessels:SelectedIndex):ToString()

		LOCAL nIndex := SELF:LBCReports:FindStringExact(cReportName, 0) AS INT
		IF nIndex <> -1
			//SELF:cLastVesselName := SELF:cLastMainSelection:Substring(nPos + 1)
			SELF:LBCReports:SelectedIndex := nIndex
			//SELF:SelectedVesselChanged()
		ENDIF
	ENDIF
RETURN


METHOD DrawLBCReportsItem(e AS DevExpress.XtraEditors.ListBoxDrawItemEventArgs) AS VOID
	LOCAL cReportUID := e:Item:ToString() AS STRING

	IF ! StringIsNumeric(cReportUID)
		RETURN
	ENDIF

	//////////////////////////////////////////////////////////////////////////
	//				ADDED BY KIRIAKOS
	//////////////////////////////////////////////////////////////////////////
	IF SELF:oDTReports == NULL
		RETURN
	ENDIF

	// Find Report's color
	LOCAL oRow := SELF:oDTReports:Rows:Find(Convert.ToInt32(cReportUID)) AS DataRow
	IF oRow == NULL
		RETURN
	ENDIF

	LOCAL cReportColor := oRow:Item["ReportColor"]:ToString() AS STRING
	IF cReportColor == "0"
		RETURN
	ENDIF

	// Create System.Drawing.Color
	LOCAL nRed, nGreen, nBlue AS LONG
	SELF:SplitColorToRGB(cReportColor, nRed, nGreen, nBlue)
	LOCAL oColor := Color.FromArgb((BYTE)nRed, (BYTE)nGreen, (BYTE)nBlue) AS Color
	//LOCAL oColor := System.Drawing.Color.FromArgb(Convert.ToInt32(cReportColor)) AS System.Drawing.Color
	e:Appearance:ForeColor := oColor
RETURN


//METHOD Fill_CheckedLBCVessels() AS VOID
//	// Selected item
//	LOCAL nSelectedValue AS INT
//	IF SELF:CheckedLBCVessels:SelectedValue <> NULL
//		nSelectedValue := Convert.ToInt32(SELF:CheckedLBCVessels:SelectedValue)	// :ToString()
//	ENDIF

//	SELF:CheckedLBCVessels:Items:Clear()

//	LOCAL cStatement, cVessel AS STRING
//	cStatement:="SELECT DISTINCT Vessels.VESSEL_UNIQUEID, Vessels.VesselName, SupVessels.VslCode"+;
//				" FROM Vessels"+SELF:cNoLockTerm+;
//				" INNER JOIN SupVessels on Vessels.VESSEL_UNIQUEID=SupVessels.VESSEL_UNIQUEID"+;
//				"	AND SupVessels.Active=1"+;
//				" LEFT OUTER JOIN FMDataPackages ON SupVessels.VESSEL_UNIQUEID=FMDataPackages.VESSEL_UNIQUEID"+;
//				" ORDER BY VesselName"
//	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
//	oSoftway:CreatePK(oDT, "VESSEL_UNIQUEID")

//	//SELF:CheckedLBCVessels:DataSource := oDT
//	//SELF:CheckedLBCVessels:DisplayMember := "ComboName"
//	//SELF:CheckedLBCVessels:ValueMember := "ComboName"

//	LOCAL n, nCount := oDT:Rows:Count - 1 AS INT
//	LOCAL oCheckedListBoxItem AS DevExpress.XtraEditors.Controls.CheckedListBoxItem
//	LOCAL cUID, cVslCode AS STRING
//	FOR n:=0 UPTO nCount
//		cUID := oDT:Rows[n]:Item["VESSEL_UNIQUEID"]:ToString()
//		cVslCode := oDT:Rows[n]:Item["VslCode"]:ToString():Trim()
//		IF cVslCode <> "" .and. oSoftway:StringIsNumeric(cVslCode, "")
//			cVslCode := Convert.ToInt16(cVslCode):ToString()
//		ENDIF
//		cVessel := PadL(cVslCode, 2, " ")+" "+oDT:Rows[n]:Item["VesselName"]:ToString()
//		oCheckedListBoxItem := DevExpress.XtraEditors.Controls.CheckedListBoxItem{Convert.ToInt32(cUID), cVessel}
//		// Is User Vessel checked?
//		cStatement:="SELECT USER_UNIQUEID FROM FMUserVessels"+SELF:cNoLockTerm+;
//					" WHERE USER_UNIQUEID="+oUser:USER_UNIQUEID+;
//					" AND VESSEL_UNIQUEID="+cUID
//		IF oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "USER_UNIQUEID") <> ""
//			oCheckedListBoxItem:CheckState := CheckState.Checked
//		ENDIF
//		SELF:CheckedLBCVessels:Items:Add(oCheckedListBoxItem)
//	NEXT

//	IF SELF:cLastVesselName <> NULL
//		//wb(SELF:cLastVesselName)
//		IF SELF:cLastVesselName <> "" //.and. SELF:cLastMainSelection <> ""
//			// Select the last selected Report
//			LOCAL nIndex := SELF:CheckedLBCVessels:FindStringExact(SELF:cLastVesselName, 0) AS INT
//			IF nIndex <> -1
//				SELF:CheckedLBCVessels:SelectedIndex := nIndex
//			ENDIF
//			SELF:cLastVesselName := ""
//		ELSEIF nSelectedValue <> 0
//			SELF:CheckedLBCVessels:SelectedValue := nSelectedValue
//			//wb(2)
//			// Show Vessel's Reports into LBCVesselReports
//			SELF:Fill_LBCVesselReports(nSelectedValue:ToString())
//		ENDIF
//	ENDIF
//RETURN


METHOD Fill_TreeListVessels(lLoad := FALSE AS LOGIC) AS VOID   
   
	//LOCAL lLocallSuspendNotification as LOGIC
	LOCAL cOldTag AS STRING
	IF SELF:TreeListVessels:FocusedNode <> NULL
		//IF SELF:oLastSelectedNode == SELF:TreeListVessels:FocusedNode
		//	lRedrawTree := FALSE
		//ENDIF
		cOldTag := SELF:TreeListVessels:FocusedNode:Tag:ToString()
	ENDIF

	//wb("TreeList")

	SELF:lSuspendNotification := TRUE
	SELF:TreeListVessels:BeginUnboundLoad()
	SELF:TreeListVessels:Nodes:Clear()
	LOCAL cStatement AS STRING

	cStatement:="SELECT DISTINCT SupVessels.FLEET_UID, EconFleet.Description AS Fleet"+;
				" FROM Vessels"+SELF:cNoLockTerm+;
				" INNER JOIN SupVessels on Vessels.VESSEL_UNIQUEID=SupVessels.VESSEL_UNIQUEID"+;
				"	AND SupVessels.Active=1"+;
				" LEFT OUTER JOIN EconFleet ON EconFleet.FLEET_UID=SupVessels.FLEET_UID"+;
				" ORDER BY Fleet"
				//" LEFT OUTER JOIN FMDataPackages ON SupVessels.VESSEL_UNIQUEID=FMDataPackages.VESSEL_UNIQUEID"+;
	LOCAL oDTFleet := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	//memowrit(cTempDocDir+"\Fleet.txt", cStatement)

	// Create a root node .
	LOCAL parentForRootNodes := NULL AS TreeListNode
	LOCAL FleetRootNode AS TreeListNode
	//parentForRootNodes := SELF:TreeListVessels:AppendNode(<OBJECT>{"Vessels"}, parentForRootNodes)
	LOCAL oNode AS TreeListNode
	LOCAL n, nCount AS INT
	LOCAL cUID, cVessel, cFleetUID AS STRING
	LOCAL oDT AS DataTable

	FOREACH oRow AS DataRow IN oDTFleet:Rows
		cFleetUID := oRow["FLEET_UID"]:ToString()
		IF cFleetUID == "0"
			FleetRootNode := parentForRootNodes
		ELSE
			FleetRootNode := SELF:TreeListVessels:AppendNode(<OBJECT>{oRow["Fleet"]:ToString()}, parentForRootNodes)
			FleetRootNode:Tag := "Fleet|"+cFleetUID
		ENDIF

		cStatement:="SELECT DISTINCT Vessels.VESSEL_UNIQUEID, Vessels.VesselName, SupVessels.VslCode,"+;
					" SupVessels.FLEET_UID, EconFleet.Description AS Fleet"+;
					" FROM Vessels"+SELF:cNoLockTerm+;
					" INNER JOIN SupVessels on Vessels.VESSEL_UNIQUEID=SupVessels.VESSEL_UNIQUEID"+;
					"	AND SupVessels.Active=1"+;
					" LEFT OUTER JOIN EconFleet ON EconFleet.FLEET_UID=SupVessels.FLEET_UID"+;
					" WHERE SupVessels.FLEET_UID="+cFleetUID+;
					" ORDER BY VesselName"
					//" LEFT OUTER JOIN FMDataPackages ON SupVessels.VESSEL_UNIQUEID=FMDataPackages.VESSEL_UNIQUEID"+;
		oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		//memowrit(cTempDocDir+"\Vsl.txt", cStatement)
		//wb(cStatement)
		//oSoftway:CreatePK(oDT, "VESSEL_UNIQUEID")

		//LOCAL oCheckedListBoxItem AS DevExpress.XtraEditors.Controls.CheckedListBoxItem
		nCount := oDT:Rows:Count - 1
		FOR n:=0 UPTO nCount
			cUID := oDT:Rows[n]:Item["VESSEL_UNIQUEID"]:ToString()
			//cVslCode := oDT:Rows[n]:Item["VslCode"]:ToString():Trim()
			//IF cVslCode <> "" .and. oSoftway:StringIsNumeric(cVslCode, "")
			//	cVslCode := Convert.ToInt16(cVslCode):ToString()
			//ENDIF
			//cVessel := PadL(cVslCode, 2, " ")+" "+oDT:Rows[n]:Item["VesselName"]:ToString()
			cVessel := oDT:Rows[n]:Item["VesselName"]:ToString()
			//oNode := TreeListNode{}
			oNode := SELF:TreeListVessels:AppendNode(<OBJECT>{cVessel}, FleetRootNode)
			oNode:Tag := cUID
			//wb(oNode:GetValue(0):ToString(), oNode:Id)
	
			// Is User Vessel checked?
			cStatement:="SELECT USER_UNIQUEID FROM FMUserVessels"+SELF:cNoLockTerm+;
						" WHERE USER_UNIQUEID="+oUser:USER_UNIQUEID+;
						" AND VESSEL_UNIQUEID="+cUID
			IF oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "USER_UNIQUEID") <> ""
				//oCheckedListBoxItem:CheckState := CheckState.Checked
				oNode:CheckState := CheckState.Checked
			ENDIF
		NEXT
	NEXT

	SELF:TreeListVessels:EndUnboundLoad()

	SELF:TreeListVessels:ExpandAll()

	SELF:lSuspendNotification := FALSE
	//wb("End Loading Vessels")
	LOCAL oFocusedNode AS TreeListNode
	//IF cOldTag == NULL
		/*IF ! STRING.IsNullOrEmpty(SELF:cLastMainSelection)
			LOCAL nIndex := SELF:cLastMainSelection:LastIndexOf("|") AS INT
			IF nIndex <> -1
				SELF:cLastVesselName := SELF:cLastMainSelection:Substring(nIndex + 1)
				//SELF:LBCReports:SelectedIndex := nIndex
//				SELF:SelectedVesselChanged()
			ENDIF
			oFocusedNode := SELF:LocateNodeByName(SELF:TreeListVessels:Nodes, SELF:cLastVesselName)
		ENDIF*/
	//else
	IF cOldTag <> NULL
		oFocusedNode := SELF:LocateNodeByTag(SELF:TreeListVessels:Nodes, cOldTag)
	ENDIF
	IF oFocusedNode <> NULL
		//SELF:lSuspendNotification := true
		//wb("Selecting old node.")
		LOCAL oPreviouslyFocusedNode AS TreeListNode
		oPreviouslyFocusedNode := SELF:TreeListVessels:FocusedNode
		IF oPreviouslyFocusedNode == oFocusedNode
			SELF:SelectedVesselChanged()
		ELSE
			SELF:TreeListVessels:FocusedNode := oFocusedNode
		ENDIF
		//SELF:lSuspendNotification := false
	ENDIF

	//IF SELF:cLastVesselName <> NULL
	//	//wb(SELF:cLastVesselName)
	//	IF SELF:cLastVesselName <> "" //.and. SELF:cLastMainSelection <> ""
	//		// Select the last selected Report
	//		LOCAL nIndex := SELF:CheckedLBCVessels:FindStringExact(SELF:cLastVesselName, 0) AS INT
	//		IF nIndex <> -1
	//			SELF:CheckedLBCVessels:SelectedIndex := nIndex
	//		ENDIF
	//		SELF:cLastVesselName := ""
	//	ELSEIF nSelectedValue <> 0
	//		SELF:CheckedLBCVessels:SelectedValue := nSelectedValue
	//		//wb(2)
	//		// Show Vessel's Reports into LBCVesselReports
	//		SELF:Fill_LBCVesselReports(nSelectedValue:ToString())
	//	ENDIF
	//ENDIF
RETURN

    
// Antonis 27.11.14 In Order to Fill Tree List With Reports //
    
METHOD Fill_TreeList_Reports() AS LOGIC
TRY
	LOCAL LBCReportsLocal AS DevExpress.XtraEditors.ListBoxControl
	IF SELF:ReportsTabUserControl:SelectedIndex == 0
				LBCReportsLocal := SELF:LBCReportsVessel
			ELSE
				LBCReportsLocal := SELF:LBCReportsOffice
	ENDIF	
	
    LOCAL parentForRootNodes := NULL AS TreeListNode
    //LOCAL dNow := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC) AS DateTime
    //LOCAL FleetRootNode AS TreeListNode
    LOCAL oNode AS TreeListNode
    LOCAL oDTVoyagesLocal AS DataTable
    SELF:TreeListVesselsReports:ClearNodes()
    LOCAL cReportName := LBCReportsLocal:GetDisplayItemValue(LBCReportsLocal:SelectedIndex):ToString() AS STRING
	LOCAL cReportUID := LBCReportsLocal:SelectedValue:ToString() AS STRING
    LOCAL cUID := SELF:GetVesselUID AS STRING

	IF SELF:TreeListVessels:FocusedNode == NULL
		RETURN FALSE
	ENDIF

	//If we are in time definied showing
	LOCAL dNow := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC) AS DateTime
	LOCAL cVoyageDateTerm := " " AS STRING
	STATIC LOCAL dStart := dNow, dEnd := dNow AS DateTime
	LOCAL cPeriod := SELF:barEditItemPeriod:EditValue:ToString() AS STRING
	DO CASE
	CASE cPeriod == "Last 6 months"
		cVoyageDateTerm := " AND (EconVoyages.StartDateGMT >'"+dNow:AddDays(-180):ToString("yyyy-MM-dd HH:mm:ss")+"' "+;
					" OR  EconVoyages.StartDate > '"+dNow:AddDays(-180):ToString("yyyy-MM-dd HH:mm:ss")+"'    "+;
					" OR  EconVoyages.EndDate > '"+dNow:AddDays(-180):ToString("yyyy-MM-dd HH:mm:ss")+"'    "+;
					" OR  EconVoyages.EndDateGMT > '"+dNow:AddDays(-180):ToString("yyyy-MM-dd HH:mm:ss")+"' ) "
	CASE cPeriod == "Specific date period"
		LOCAL oSelectDatesSimpleForm := SelectDatesSimpleForm{} AS SelectDatesSimpleForm
		oSelectDatesSimpleForm:DateFrom:DateTime := dStart
		oSelectDatesSimpleForm:DateTo:DateTime := TimeZoneInfo.ConvertTime(dEnd, TimeZoneInfo.Utc)
		oSelectDatesSimpleForm:ShowDialog()
		IF oSelectDatesSimpleForm:DialogResult <> DialogResult.OK
			SELF:barEditItemPeriod:EditValue := "Last 6 months"
			RETURN FALSE
		ENDIF
		dStart := oSelectDatesSimpleForm:DateFrom:DateTime
		dEnd := oSelectDatesSimpleForm:DateTo:DateTime
		cVoyageDateTerm := " AND (EconVoyages.StartDateGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm:ss")+"' "+;
						" OR  EconVoyages.StartDate BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm:ss")+"'  "+;
						" OR  EconVoyages.EndDate BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm:ss")+"'  "+;
						" OR  EconVoyages.EndDateGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm:ss")+"' ) "
		//SELF:Cursor := Cursors.WaitCursor
		//Application.DoEvents()
	ENDCASE

	LOCAL cTCextraSQL_Voyage := " " AS STRING
	IF SELF:lisTC
		cTCextraSQL_Voyage := " AND EconVoyages.VOYAGE_UID IN ( SELECT VOYAGE_UID FROM FMVoyageLinks WHERE Parent_Voyage_UID ="+ SELF:cTCParent+" ) "
	ELSE
		cTCextraSQL_Voyage := " AND EconVoyages.VOYAGE_UID  NOT IN ( SELECT VOYAGE_UID FROM FMVoyageLinks ) "
	ENDIF

    LOCAL cStatement AS STRING
	// Voyages
	cStatement:="SELECT VOYAGE_UID, VoyageNo, EconVoyages.Description, EconVoyages.Type, CPDate, Charterers, Broker, StartDate, EndDate, StartDateGMT, EndDateGMT,"+;
				" CostOfBunkersUSD, CPMinSpeed, HFOConsumption, DGFOConsumption,"+;
				" EconVoyages.PortFrom_UID, EconVoyages.PortTo_UID, EconVoyages.Distance, RTrim(Users.UserName) AS UserName,"+;
				" RTrim(VEPortsFrom.Port) AS PortFrom, RTrim(VEPortsTo.Port) AS PortTo,"+;
				" VEPortsFrom.SummerGMT_DIFF AS PortFromSummerGMT_DIFF, VEPortsFrom.WinterGMT_DIFF AS PortFromWinterGMT_DIFF,"+;
				" VEPortsTo.SummerGMT_DIFF AS PortToSummerGMT_DIFF, VEPortsTo.WinterGMT_DIFF AS PortToWinterGMT_DIFF"+;
				" FROM EconVoyages"+oMainForm:cNoLockTerm+;
				" LEFT OUTER JOIN VEPorts AS VEPortsFrom ON EconVoyages.PortFrom_UID=VEPortsFrom.PORT_UID"+;
				" LEFT OUTER JOIN VEPorts AS VEPortsTo ON EconVoyages.PortTo_UID=VEPortsTo.PORT_UID"+;
				" LEFT OUTER JOIN USERS ON EconVoyages.USER_UNIQUEID=USERS.USER_UNIQUEID"+;
				" WHERE VESSEL_UNIQUEID="+SELF:TreeListVessels:FocusedNode:Tag:ToString()+cTCextraSQL_Voyage+cVoyageDateTerm+;
				" ORDER BY StartDateGMT DESC"
	//MemoWrit(ctempdocdir+"\voyages.txt", cStatement)
	//wb(cStatement)
	oDTVoyagesLocal:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	oDTVoyagesLocal:TableName:="EconVoyages"
	// Create Primary Key
	oSoftway:CreatePK(oDTVoyagesLocal, "VOYAGE_UID")

    LOCAL nCount := oDTVoyagesLocal:Rows:Count - 1,n AS INT
	FOR n:=0 UPTO nCount
		LOCAL cDateCommenced := oDTVoyagesLocal:Rows[n]:Item["StartDateGMT"]:ToString() AS STRING
		LOCAL cDateFinit := oDTVoyagesLocal:Rows[n]:Item["EndDateGMT"]:ToString() AS STRING
		LOCAL cVoyageNo := oDTVoyagesLocal:Rows[n]:Item["VoyageNo"]:ToString() AS STRING
		LOCAL cVoyageID := oDTVoyagesLocal:Rows[n]:Item["VOYAGE_UID"]:ToString() AS STRING
		LOCAL cDescr := oDTVoyagesLocal:Rows[n]:Item["Description"]:ToString() AS STRING
		LOCAL iVoyageType AS INT
		TRY
			 iVoyageType :=  int32.Parse(oDTVoyagesLocal:Rows[n]:Item["Type"]:ToString()) 
		CATCH
			iVoyageType := 0 
		END
		
		oNode := SELF:TreeListVesselsReports:AppendNode(<OBJECT>{cVoyageNo+". "+cDescr+"- Started on :"+cDateCommenced}, parentForRootNodes)
        oNode:ImageIndex := 0 
        oNode:SelectImageIndex := 0        
        oNode:Tag := cVoyageID
		IF lisTC
			oNode:StateImageIndex := 0
		ELSE
			oNode:StateImageIndex := iVoyageType
		ENDIF
		IF cDateCommenced == NULL .OR. cDateCommenced == ""
		    //ErrorBox("No Start date defined for Voyage No :"+cVoyageNo)
            Application.DoEvents()
		    //SELF:barEditItemPeriod:EditValue := "Last 3 months"
		    LOOP
        ELSE
            cDateCommenced := DateTime.Parse(cDateCommenced):ToString("yyyy-MM-dd HH:mm:ss")
		ENDIF
		IF cDateFinit == NULL .OR. cDateFinit == ""
		    cDateFinit := "2100-01-01 00:00:00"
        ELSE
		    cDateFinit := DateTime.Parse(cDateFinit):ToString("yyyy-MM-dd HH:mm:ss")
        ENDIF
		//Local cDateTerm := " AND FMDataPackages.DateTimeGMT BETWEEN '"+dStart1:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dEnd1:ToString("yyyy-MM-dd HH:mm:ss")+"'" as STRING
        LOCAL cDateTerm := " AND FMDataPackages.DateTimeGMT BETWEEN '"+cDateCommenced+"' AND '"+cDateFinit+"'" AS STRING
        // For users that can see all reports
		LOCAL oRowLocal := SELF:returnUserSetting(oUser:USER_UNIQUEID) AS DataRow
		LOCAL cSeeAllReportsSQL := ""/*, cIsManagerSQL*/ , cResultSeeAllReports := oRowLocal["CanSeeAllOfficeReports"]:ToString() AS STRING
		
		IF oRowLocal == NULL || cResultSeeAllReports == "False"
			cSeeAllReportsSQL := " AND ((( FMReportTypes.ReportType='O' AND FMDataPackages.Matched=2 ) OR FMDataPackages.Username='"+oUser:UserName+"' ) OR FMReportTypes.ReportType='V' ) "
		ENDIF
		IF  (SELF:lisManagerGlobal .OR. SELF:lisGMGlobal) .AND. cResultSeeAllReports == "False" 
			cSeeAllReportsSQL := " AND ((( FMReportTypes.ReportType='O' AND FMDataPackages.Matched=2 ) OR FMDataPackages.Username='"+oUser:UserName+"' OR ( FMDataPackages.PACKAGE_UID IN ( SELECT [Foreing_UID] FROM [ApprovalData] WHERE [Receiver_UID]="+oUser:USER_UNIQUEID+") ) ) OR FMReportTypes.ReportType='V' ) "
		ENDIF
		//
        IF cReportName:ToUpper():StartsWith("MODE")
		    cStatement:="SELECT FMDataPackages.DateTimeGMT, FMDataPackages.Matched , FMDataPackages.PACKAGE_UID, FMDataPackages.Username,FMDataPackages.Status, FMReportTypes.ReportName, FMReportTypes.ReportType"+;
					    " FROM FMDataPackages"+SELF:cNoLockTerm+;
					    " INNER JOIN FMReportTypes ON FMReportTypes.REPORT_UID=FMDataPackages.REPORT_UID"+;
						" AND FMReportTypes.ReportType='V' "+;
					    " WHERE FMDataPackages.Visible=1 AND FMDataPackages.VESSEL_UNIQUEID="+cUID+;
					    cDateTerm+;
					    " ORDER BY FMDataPackages.DateTimeGMT DESC, PACKAGE_UID DESC "
	    ELSE
		    cStatement:="SELECT FMDataPackages.DateTimeGMT,FMDataPackages.Matched , FMDataPackages.PACKAGE_UID, FMDataPackages.Username,FMDataPackages.Status, FMReportTypes.ReportName, FMReportTypes.ReportType"+;
					    " FROM FMDataPackages"+SELF:cNoLockTerm+;
					    " INNER JOIN FMReportTypes ON FMReportTypes.REPORT_UID=FMDataPackages.REPORT_UID "+;
					    cSeeAllReportsSQL+;
					    " INNER JOIN FMReportTypesVessel ON FMReportTypes.REPORT_UID=FMReportTypesVessel.REPORT_UID"+;
					    "	AND FMDataPackages.VESSEL_UNIQUEID=FMReportTypesVessel.VESSEL_UNIQUEID"+;
					    " WHERE FMDataPackages.Visible=1 AND FMDataPackages.VESSEL_UNIQUEID="+cUID+;
					    " AND FMDataPackages.REPORT_UID="+cReportUID+;
					    cDateTerm+;
					    " ORDER BY FMDataPackages.DateTimeGMT DESC, PACKAGE_UID DESC"
	    ENDIF
        MemoWrit(cTempDocDir + "\datapackages"+n:ToString()+".txt", cStatement)
	
        LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	    //, oDT:Rows:Count:ToString())
	    LOCAL n1, nCount1 := oDT:Rows:Count - 1 AS INT
	    //LOCAL oCheckedListBoxItem AS DevExpress.XtraEditors.Controls.CheckedListBoxItem
	    LOCAL cText AS STRING
	    //SELF:LBCVesselReports:Items:Clear()
	    FOR n1:=0 UPTO nCount1
		    cText := DateTime.Parse(oDT:Rows[n1]:Item["DateTimeGMT"]:ToString()):ToString("dd/MM/yyyy HH:mm")+" "+oDT:Rows[n1]:Item["ReportName"]:ToString()
			IF SELF:LBCReportsOffice:Visible == TRUE
				cText := oDT:Rows[n1]:Item["Username"]:ToString() + "-"+ cText  
			ENDIF
			LOCAL cPackageUID := oDT:Rows[n1]:Item["PACKAGE_UID"]:ToString() AS STRING
			LOCAL cMatched := oDT:Rows[n1]:Item["Matched"]:ToString() AS STRING
			LOCAL cStatus := oDT:Rows[n1]:Item["Status"]:ToString() AS STRING
			LOCAL cType := oDT:Rows[n1]:Item["ReportType"]:ToString() AS STRING
		    //oCheckedListBoxItem := DevExpress.XtraEditors.Controls.CheckedListBoxItem{Convert.ToInt32(oDT:Rows[n]:Item["VESSEL_UNIQUEID"]:ToString()), cVessel}
		    LOCAL oReportNode := SELF:TreeListVesselsReports:AppendNode(<OBJECT>{cText}, oNode) AS TreeListNode
			IF cMatched == "1" .OR. cMatched == "2"
				oReportNode:ImageIndex := 2
				oReportNode:SelectImageIndex := 2
			ELSE
				oReportNode:SelectImageIndex := -1
				oReportNode:ImageIndex := -1
			ENDIF
			IF cType == "O"
			IF cStatus == "0" || cStatus == "1"
				oReportNode:StateImageIndex := 2
			ELSEIF cStatus == "2"
				oReportNode:StateImageIndex := 3
			ELSEIF cStatus == "3"
				oReportNode:StateImageIndex := 4
			ENDIF
			ENDIF
			oReportNode:Tag := cPackageUID
	    NEXT
        
        
	NEXT
	
	IF n!=0

		oNode := SELF:TreeListVesselsReports:Nodes[0]

		IF lisTC
			oNode:SelectImageIndex := 0
			oNode:ImageIndex := 0
		ELSE
			oNode:ImageIndex := 1 
			oNode:SelectImageIndex := 1
		ENDIF
		SELF:TreeListVesselsReports:FocusedNode := oNode
		SELF:TreeListReportsFocusChanged(NULL)
	ENDIF
CATCH e  AS Exception
    //WB(e:StackTrace:ToString()+"///"+CRLF+"///"+e:Message:ToString())
    Application.DoEvents()
    RETURN FALSE
END
  
RETURN TRUE
    
    
METHOD TreeListReportsFocusChanged(sender AS OBJECT, lDontShowReport:= FALSE AS LOGIC) AS VOID
    TRY
       LOCAL oNode :=  SELF:TreeListVesselsReports:FocusedNode AS TreeListNode
       IF oNode != NULL
           IF oNode:Level == 0
               //wb("Voyage")
			SELF:BBIEditReport:Visibility := BarItemVisibility.Never
			SELF:BBISubmit:Visibility := BarItemVisibility.Never
			SELF:BBIAppove:Visibility := BarItemVisibility.Never
			SELF:printButton:Visibility := BarItemVisibility.Never
			SELF:BBIFinalize:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
			SELF:BBISave:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
			SELF:BBIDelete:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
			SELF:BBICancel:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
			SELF:BBSIStatus:Visibility := BarItemVisibility.Never
			SELF:BBIAppovalHistory:Visibility := BarItemVisibility.Never
			SELF:BBIReturn:Visibility := BarItemVisibility.Never
			SELF:splitMapForm:PanelVisibility := SplitPanelVisibility.Panel2
            oNode:ExpandAll()
		   ELSE
			 SELF:printButton:Visibility := BarItemVisibility.Always
			 SELF:BBISubmit:Enabled := TRUE
			 //SELF:splitMapForm:SplitterPosition := (INT)(SELF:splitMapForm:Width*0.75)
			 //SELF:splitMapForm:PanelVisibility := SplitPanelVisibility.Both
             //wb("Report")
			 LOCAL locs := Microsoft.Maps.MapControl.WPF.LocationCollection{} AS Microsoft.Maps.MapControl.WPF.LocationCollection
			 IF !SELF:BingMapUserControl:ShowVesselOnMap(SELF:TreeListVessels:FocusedNode, locs, TRUE, oNode:Tag:ToString())
					SELF:splitMapForm:PanelVisibility := SplitPanelVisibility.Panel1
			 ELSE
					SELF:splitMapForm:PanelVisibility := SplitPanelVisibility.Both	
			 ENDIF
			LOCAL oRowLocal := SELF:returnUserSetting(oUser:USER_UNIQUEID) AS DataRow
			LOCAL lisCreator := SELF:checkIFUserIsCreatorOfThePachage(oNode:Tag:ToString()) AS LOGIC
			LOCAL lisMatched := SELF:checkIFReportIsFinalized(oNode:Tag:ToString()) AS LOGIC
			LOCAL lisOfficeReport :=  SELF:LBCReportsOffice:Visible AS LOGIC
			//wb("M:"+lisMatched:ToString()+"/O:"+lisOfficeReport:ToString()+"/C:"+lisCreator:ToString())
			
			
			IF lisOfficeReport		
				//
				LOCAL cUIDLocal := SELF:TreeListVesselsReports:FocusedNode:Tag:ToString() AS STRING
				LOCAL cStatement := "Select Status FROM FMDataPackages WHERE [PACKAGE_UID]="+cUIDLocal AS STRING
				LOCAL cStatusLocal := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Status") AS STRING
				IF cStatusLocal == "0"
					/*cStatement := "Select TOP 1 Username,[Appoval_UID] FROM Users, [ApprovalData] WHERE [Foreing_UID]="+cUIDLocal+" AND [Receiver_UID]=USER_UNIQUEID ORDER BY [Appoval_UID] ASC "
					LOCAL cUsernameLocal := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Username"):Trim() AS STRING
					IF cUsernameLocal == NULL || cUsernameLocal == ""*/
						SELF:BBSIStatus:Caption := "Status: Pending"
						SELF:BBSIStatus:Appearance:ForeColor := Color.Salmon
						IF lisCreator 
							SELF:BBISubmit:Visibility := BarItemVisibility.Always
						ELSE
							SELF:BBISubmit:Visibility := BarItemVisibility.Never
						ENDIF
						SELF:BBIAppove:Visibility := BarItemVisibility.Never
						SELF:BBIReturn:Visibility := BarItemVisibility.Never
					/*else
						SELF:BBSIStatus:Caption := "Status: Submitted to Dep Manager ("+cUsernameLocal+")"
						IF lisCreator 
							SELF:BBISubmit:Visibility := BarItemVisibility.Never
						ELSEif cUsernameLocal == oUser:Username
							SELF:BBISubmit:Visibility := BarItemVisibility.Always
						ENDIF
					ENDIF*/
				ELSEIF cStatusLocal == "1" 
					SELF:markApprovalAsSeen()
					cStatement := " Select TOP 1 Username,[Appoval_UID] FROM Users, [ApprovalData] WHERE Program_UID=2 AND [Foreing_UID]="+cUIDLocal+;
								  " AND [Receiver_UID]=USER_UNIQUEID ORDER BY [Appoval_UID] ASC "
					LOCAL cUsernameLocal := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Username"):Trim() AS STRING
					SELF:BBSIStatus:Caption := "Status: Submitted to Dep Manager ("+cUsernameLocal+")"
					SELF:BBSIStatus:Appearance:ForeColor := Color.Orange
					IF lisCreator 
						SELF:BBISubmit:Visibility := BarItemVisibility.Never
						SELF:BBIReturn:Visibility := BarItemVisibility.Never
					ELSEIF cUsernameLocal == oUser:Username
						SELF:BBISubmit:Visibility := BarItemVisibility.Always
						SELF:BBIReturn:Visibility := BarItemVisibility.Always
					ENDIF
					SELF:BBIEditReport:Enabled := FALSE
				ELSEIF cStatusLocal == "2" 
					SELF:markApprovalAsSeen()
					SELF:BBISubmit:Visibility := BarItemVisibility.Never
					SELF:BBIReturn:Visibility := BarItemVisibility.Never
					cStatement := "Select [Appoval_UID] FROM [ApprovalData] WHERE [Foreing_UID]="+cUIDLocal
					LOCAL oDTCountApprovals := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
					//wb(cStatement, oDT:Rows:Count:ToString())
					LOCAL nCountApprovals := oDTCountApprovals:Rows:Count AS INT
					IF nCountApprovals>1
						cStatement := "Select TOP 1 Username,[Appoval_UID] FROM Users, [ApprovalData] WHERE [Foreing_UID]="+cUIDLocal+" AND [Receiver_UID]=USER_UNIQUEID ORDER BY [Appoval_UID] ASC "
					ELSE
						cStatement := "Select TOP 1 Username,[Appoval_UID] FROM Users, [ApprovalData] WHERE [Foreing_UID]="+cUIDLocal+" AND [Creator_UID]=USER_UNIQUEID ORDER BY [Appoval_UID] ASC "
					ENDIF
					LOCAL cUsernameLocal := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Username"):Trim() AS STRING
					SELF:BBSIStatus:Caption := "Status: Dep Manager ("+cUsernameLocal+") Approved"
					SELF:BBSIStatus:Appearance:ForeColor := Color.Navy
					IF lisGMGlobal
							SELF:BBIAppove:Visibility := BarItemVisibility.Always
						ELSE
							SELF:BBIAppove:Visibility := BarItemVisibility.Never
					ENDIF
				ELSEIF cStatusLocal == "3"
					SELF:BBISubmit:Visibility := BarItemVisibility.Never
					SELF:BBIAppove:Visibility := BarItemVisibility.Never
					SELF:BBIReturn:Visibility := BarItemVisibility.Never
					cStatement := "Select TOP 1 Username,[Appoval_UID] FROM Users, [ApprovalData] WHERE [Foreing_UID]="+cUIDLocal+" AND [Receiver_UID]=USER_UNIQUEID ORDER BY [Appoval_UID] DESC "
					LOCAL cUsernameLocal := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Username"):Trim() AS STRING
					SELF:BBSIStatus:Caption := "Status: General Manager ("+cUsernameLocal+")  Acknowledged"
					SELF:BBSIStatus:Appearance:ForeColor := Color.DarkGreen
				ENDIF
				SELF:BBSIStatus:Visibility := BarItemVisibility.Always
				SELF:BBIAppovalHistory:Visibility := BarItemVisibility.Always
				//
				IF lisCreator && !lisMatched  
					IF cStatusLocal <> "1"
						SELF:BBIEditReport:Visibility := BarItemVisibility.Always
						//SELF:BBIFinalize:Visibility := DevExpress.XtraBars.BarItemVisibility.Always
						SELF:BBISave:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Always
						SELF:BBIDelete:Visibility := DevExpress.XtraBars.BarItemVisibility.Always
						SELF:BBICancel:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Always
					ELSE
						SELF:BBIEditReport:Visibility := BarItemVisibility.Never
						//SELF:BBIFinalize:Visibility := DevExpress.XtraBars.BarItemVisibility.Always
						SELF:BBISave:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
						SELF:BBIDelete:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
						SELF:BBICancel:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
					ENDIF
				ELSEIF lisMatched  
						IF  oRowLocal["CanEditFinalizedOfficeReports"]:ToString() == "False" 
							SELF:BBIEditReport:Visibility := BarItemVisibility.Never
							SELF:BBISave:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
							SELF:BBICancel:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
						ELSE    
							SELF:BBIEditReport:Visibility := BarItemVisibility.Always
							SELF:BBISave:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Always
							SELF:BBICancel:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Always
						ENDIF
						IF  oRowLocal["CanDeleteOfficeReports"]:ToString() == "False" 
							SELF:BBIDelete:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
						ELSE
							SELF:BBIDelete:Visibility := DevExpress.XtraBars.BarItemVisibility.Always
						ENDIF
						
						//SELF:BBIFinalize:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
				ELSEIF !lisCreator && !lisMatched 
						IF  oRowLocal["CanEditFinalizedOfficeReports"]:ToString() == "False" 
							SELF:BBIEditReport:Visibility := BarItemVisibility.Never
							SELF:BBISave:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
							SELF:BBICancel:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
						ELSE    
							SELF:BBIEditReport:Visibility := BarItemVisibility.Always
							SELF:BBISave:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Always
							SELF:BBICancel:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Always
						ENDIF
						IF  oRowLocal["CanDeleteOfficeReports"]:ToString() == "False" 
							SELF:BBIDelete:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
						ELSE
							SELF:BBIDelete:Visibility := DevExpress.XtraBars.BarItemVisibility.Always
						ENDIF	
						//SELF:BBIFinalize:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
				ENDIF
				
			ELSE // Eimai vessel report
				SELF:BBIFinalize:Visibility :=DevExpress.XtraBars.BarItemVisibility.Never
				SELF:BBIAppove:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
				SELF:BBISubmit:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
				SELF:BBIReturn:Visibility := BarItemVisibility.Never
				
				IF oRowLocal == NULL || oRowLocal["CanEditReportData"]:ToString() == "True"
					SELF:BBIEditReport:Visibility := DevExpress.XtraBars.BarItemVisibility.Always
					SELF:BBISave:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Always
					SELF:BBICancel:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Always
				ELSE
					SELF:BBIEditReport:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
					SELF:BBISave:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
					SELF:BBICancel:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
				ENDIF
				IF oRowLocal == NULL || oRowLocal["CanDeleteReportData"]:ToString() == "True"
					SELF:BBIDelete:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Always
				ELSE
					SELF:BBIDelete:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
				ENDIF
			ENDIF
			IF !lDontShowReport
				SELF:ShowReportForm(FALSE,FALSE)	 
			ENDIF
           ENDIF
       ENDIF
    CATCH exc AS Exception
        system.windows.MessageBox.Show(exc:StackTrace+"////\r\n/////"+exc:Message) 
        RETURN
    END
    
RETURN    
    
EXPORT METHOD checkIFUserIsCreatorOfThePachage(cNodeTag AS STRING) AS LOGIC
	//MessageBox.Show(cNodeTag)
	LOCAL cStatement:="SELECT Username FROM FMDataPackages "+SELF:cNoLockTerm+;
						" WHERE Package_UID="+cNodeTag+" " AS STRING
	IF oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Username") <> oUser:UserName
		RETURN FALSE
	ENDIF	
RETURN TRUE

EXPORT METHOD checkIFReportIsFinalized(cNodeTag AS STRING) AS LOGIC
	//MessageBox.Show(cNodeTag)
	LOCAL cStatement:="SELECT Matched FROM FMDataPackages "+SELF:cNoLockTerm+;
						" WHERE Package_UID="+cNodeTag+" " AS STRING
	//wb(oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Matched"))				
	IF oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Matched") == "0"
		RETURN FALSE
	ENDIF	
RETURN TRUE

METHOD LocateNodeByTag(oNodes AS TreeListNodes, cTag AS STRING) AS TreeListNode
	FOREACH oNode AS TreeListNode IN oNodes
		IF oNode:Tag:ToString() == cTag
			RETURN oNode
		ENDIF

		IF oNode:Nodes:Count > 0
			// Recursive call
			oNode := SELF:LocateNodeByTag(oNode:Nodes, cTag)
			IF oNode <> NULL
				RETURN oNode
			ENDIF
		ENDIF
	NEXT
RETURN NULL


METHOD LocateNodeByName(oNodes AS TreeListNodes, cName AS STRING) AS TreeListNode
	FOREACH oNode AS TreeListNode IN oNodes
		IF oNode:GetValue(0):ToString() == cName
			RETURN oNode
		ENDIF

		IF oNode:Nodes:Count > 0
			// Recursive call
			oNode := SELF:LocateNodeByName(oNode:Nodes, cName)
			IF oNode <> NULL
				RETURN oNode
			ENDIF
		ENDIF
	NEXT
RETURN NULL


METHOD TreeListVessels_OnAfterCheckNode(e AS DevExpress.XtraTreeList.NodeEventArgs) AS VOID
	// Update FMUserVessels Table 
	LOCAL cStatement, cUID := e:Node:Tag:ToString() AS STRING
	LOCAL oNode := e:Node AS DevExpress.XtraTreeList.Nodes.TreeListNode
	
	
	
	IF cUID:StartsWith("Fleet")
		FOREACH oChildNode AS DevExpress.XtraTreeList.Nodes.TreeListNode IN  oNode:Nodes
			oChildNode:Checked := oNode:Checked
			LOCAL cChildUID := oChildNode:Tag:ToString() AS STRING
			IF oChildNode:Checked
				cStatement:="INSERT INTO FMUserVessels (USER_UNIQUEID, VESSEL_UNIQUEID)"+;
						" SELECT "+oUser:USER_UNIQUEID+","+cChildUID+;
						IIF(symServer == #MySQL, " FROM GlobalSettings", "")+;
						" WHERE NOT EXISTS"+;
						" (SELECT USER_UNIQUEID FROM FMUserVessels"+;
						"	WHERE USER_UNIQUEID="+oUser:USER_UNIQUEID+;
						"	AND VESSEL_UNIQUEID="+cChildUID+")"
				oSoftway:AdoCommand(SELF:oGFH, SELF:oConn, cStatement)
			ELSE
				cStatement:="DELETE FROM FMUserVessels"+;
							" WHERE USER_UNIQUEID="+oUser:USER_UNIQUEID+;
							" AND VESSEL_UNIQUEID="+cChildUID
				oSoftway:AdoCommand(SELF:oGFH, SELF:oConn, cStatement)
			ENDIF
		NEXT
		RETURN
	ELSE

	IF e:Node:Checked
		cStatement:="INSERT INTO FMUserVessels (USER_UNIQUEID, VESSEL_UNIQUEID)"+;
					" SELECT "+oUser:USER_UNIQUEID+","+cUID+;
					IIF(symServer == #MySQL, " FROM GlobalSettings", "")+;
					" WHERE NOT EXISTS"+;
					" (SELECT USER_UNIQUEID FROM FMUserVessels"+;
					"	WHERE USER_UNIQUEID="+oUser:USER_UNIQUEID+;
					"	AND VESSEL_UNIQUEID="+cUID+")"
		oSoftway:AdoCommand(SELF:oGFH, SELF:oConn, cStatement)
	ELSE
		cStatement:="DELETE FROM FMUserVessels"+;
					" WHERE USER_UNIQUEID="+oUser:USER_UNIQUEID+;
					" AND VESSEL_UNIQUEID="+cUID
		oSoftway:AdoCommand(SELF:oGFH, SELF:oConn, cStatement)
	ENDIF
	
		
	IF lDisplayAll 
		SELF:BingMapUserControl:ShowSelectedVesselsOnMap()
	ENDIF
	
	ENDIF
RETURN


METHOD SelectedReportChanged() AS VOID
	
	//WB("SelectedReportChanged Says :"+lSuspendNotification:ToString())
	
	IF SELF:lSuspendNotification
		RETURN
	ENDIF
	SELF:BingMapUserControl:ClearReportPins()	
	//SELF:lSuspendNotification := TRUE
	//SELF:Fill_CheckedLBCVessels()
	//SELF:Fill_TreeListVessels()
	IF SELF:myReportTabForm <> NULL
			SELF:myReportTabForm:Close()
			SELF:myReportTabForm:Dispose()
	ENDIF
	IF SELF:GetVesselUID <> "0"
		SELF:Fill_TreeList_Reports()
	ENDIF
	//SELF:lSuspendNotification := FALSE
RETURN

METHOD justTheReportChanged AS VOID
		SELF:BingMapUserControl:ClearReportPins()	
		IF SELF:myReportTabForm <> NULL
			SELF:myReportTabForm:Close()
			SELF:myReportTabForm:Dispose()
		ENDIF		
		IF SELF:GetVesselUID <> "0"
			SELF:Fill_TreeList_Reports()
		ENDIF
RETURN
//METHOD SelectedVesselChanged() AS VOID
//	IF SELF:lSuspendNotification
//		RETURN
//	ENDIF
//	SELF:lSuspendNotification := TRUE

//	IF SELF:CheckedLBCVessels:Items:Count == 0
//		SELF:LBCVesselReports:Items:Clear()
//	ENDIF

//	IF SELF:CheckedLBCVessels:SelectedIndex == -1 .or. oMainForm:LBCReports:SelectedValue == NULL
//		SELF:lSuspendNotification := FALSE
//		//lInside := FALSE
//		RETURN
//	ENDIF

//	LOCAL cUID := SELF:CheckedLBCVessels:SelectedValue:ToString() AS STRING
//	//wb(SELF:CheckedLBCVessels:SelectedItem:ToString(), cUID)
//	SELF:Fill_LBCReports(cUID)

//	//wb(1)
//	// Show Vessel's Reports into LBCVesselReports
//	SELF:Fill_LBCVesselReports(cUID)

//	SELF:lSuspendNotification := FALSE
//RETURN


METHOD SelectedVesselChanged() AS VOID
	
	//WB("SelectedVesselChanged Says :"+lSuspendNotification:ToString())	
    //SELF:LBCReports:Items:Clear()
	SELF:lisTC := FALSE
	SELF:backBBI:Enabled := FALSE
	SELF:cTCParent := ""
    SELF:LBCVesselReports:Items:Clear()
    SELF:TreeListVesselsReports:ClearNodes()
	SELF:BingMapUserControl:ClearReportPins()
	IF SELF:myReportTabForm <> NULL
		SELF:myReportTabForm:Close()
		SELF:myReportTabForm:Dispose()
	ENDIF
	IF SELF:lSuspendNotification
		RETURN
	ELSE
		lDisplayAll := FALSE
	ENDIF
	
	SELF:lSuspendNotification := TRUE

	IF SELF:TreeListVessels:Nodes:Count == 0
		LBCReports:Items:Clear()
        SELF:TreeListVesselsReports:ClearNodes()
	ENDIF

	IF SELF:TreeListVessels:FocusedNode == NULL //.or. oMainForm:LBCReports:SelectedValue == NULL
		SELF:lSuspendNotification := FALSE
		//lInside := FALSE
		RETURN
	ENDIF

	LOCAL cUID := SELF:GetVesselUID AS STRING

	IF cUID <> "0"
		//wb(SELF:CheckedLBCVessels:SelectedItem:ToString(), cUID)
		SELF:Fill_LBCReports(cUID)
        //SELF:Fill_LBCVesselReports(cUID)
		SELF:LBCVesselReportsViewChanged()
	ENDIF

	// Show Vessel's Reports into LBCVesselReports
	SELF:lSuspendNotification := FALSE
    LOCAL locs := Microsoft.Maps.MapControl.WPF.LocationCollection{} AS Microsoft.Maps.MapControl.WPF.LocationCollection
	SELF:splitMapForm:SplitterPosition := 0
	SELF:splitMapForm:PanelVisibility := SplitPanelVisibility.Panel2
	SELF:barEditItemDisplayMap:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
	IF !SELF:TreeListVessels:FocusedNode:Tag:ToString():StartsWith("Fleet")
		SELF:BingMapUserControl:ShowVesselOnMap(SELF:TreeListVessels:FocusedNode, locs, TRUE , NULL)
	ENDIF
RETURN


METHOD LBCVesselReportsViewChanged() AS VOID    //Antonis 27.11.14 When on Voyage Sorting show Reports Using Tree //
		IF SELF:GetVesselUID == "0"
			RETURN
		ENDIF		
    //	LOCAL lRedrawTree := TRUE AS LOGIC
		SELF:lisTC := FALSE
		SELF:backBBI:Enabled := FALSE
		SELF:cTCParent := ""
        LOCAL isTreeOnVesselReports := SELF:Fill_TreeList_Reports()  AS LOGIC
	    IF isTreeOnVesselReports
            SELF:TreeListVesselsReports:Visible := isTreeOnVesselReports
            RETURN
		ELSE
			IF SELF:TreeListVessels:FocusedNode == NULL .OR. oMainForm:LBCReports:SelectedValue == NULL
				RETURN
			ENDIF
			IF SELF:TreeListVessels:Nodes:Count == 0
				SELF:LBCVesselReports:Items:Clear()
			ENDIF
            SELF:TreeListVesselsReports:Visible := FALSE
			LOCAL cUID := SELF:GetVesselUID AS STRING
			// Show Vessel's Reports into LBCVesselReports
			SELF:Fill_LBCVesselReports(cUID)
        ENDIF
RETURN

METHOD LBCDisplayMapViewChanged() AS VOID    //Antonis 27.11.14 When on Voyage Sorting show Reports Using Tree //
    //	LOCAL lRedrawTree := TRUE AS LOGIC
	TRY
	LOCAL cPer := SELF:barEditItemDisplayMap:EditValue:ToString() AS STRING
	DO CASE
	CASE cPer:Equals("100%")
			SELF:splitMapForm:SplitterPosition := 1
	CASE cPer:Equals("25%")
			SELF:splitMapForm:SplitterPosition := (INT)(SELF:splitMapForm:Width*0.75)
	CASE cPer:Equals("50%")
			SELF:splitMapForm:SplitterPosition := (INT)(SELF:splitMapForm:Width*0.50)
	CASE cPer:Equals("75%")
			SELF:splitMapForm:SplitterPosition := (INT)(SELF:splitMapForm:Width*0.25)
	CASE cPer:Equals("0%")
			SELF:splitMapForm:SplitterPosition := (INT)(SELF:splitMapForm:Width-1)
	ENDCASE
	CATCH exc AS Exception
	END
RETURN


METHOD Fill_LBCVesselReports(cUID AS STRING) AS VOID
	IF oMainForm:LBCReports:SelectedValue == NULL
		RETURN
    ENDIF
	IF cUID:StartsWith("Fleet") || SELF:GetVesselUID == "0"
		RETURN
	ENDIF

	LOCAL cStatement AS STRING
	LOCAL cReportUID := oMainForm:LBCReports:SelectedValue:ToString() AS STRING
	LOCAL cReportName := oMainForm:LBCReports:GetDisplayItemValue(oMainForm:LBCReports:SelectedIndex):ToString() AS STRING
	IF ! StringIsNumeric(cReportUID)
		cReportUID := "0"
		cReportName := "MODE"
	ENDIF

	LOCAL dNow := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC) AS DateTime
	LOCAL cPeriod := SELF:barEditItemPeriod:EditValue:ToString() AS STRING
	LOCAL cDateTerm := "" AS STRING

	STATIC LOCAL dStart := dNow, dEnd := dNow AS DateTime
	DO CASE
	CASE cPeriod == "Last 6 months"
		cDateTerm := " AND FMDataPackages.DateTimeGMT > '"+dNow:AddDays(-180):ToString("yyyy-MM-dd HH:mm:ss")+"' "

    CASE cPeriod == "Voyage routing" // Antonis 27.11.14 Bring Voyages to treelist //
        
        IF !(SELF:Fill_TreeList_Reports())
		        LOCAL oSelectVoyageForm := SelectVoyageForm{} AS SelectVoyageForm
		        oSelectVoyageForm:cVesselUID := oMainForm:GetVesselUID //Antonis 27.11.14 Fix Bug //
		        oSelectVoyageForm:ShowDialog()
		        IF oSelectVoyageForm:DialogResult <> DialogResult.OK
		    	    SELF:barEditItemPeriod:EditValue := "Last 6 months"
		    	    RETURN
		        ENDIF

		        //SELF:oLBCItemVoyage := (MyLBCVoyageItem)oSelectVoyageForm:LBCVoyages:SelectedItem
		        LOCAL oLBCItemRouting := (MyLBCVoyageItem)oSelectVoyageForm:LBCRouting:SelectedItem AS MyLBCVoyageItem

		        LOCAL dStart1 := dNow, dEnd1 := dNow AS DateTime
		        dStart1 := oLBCItemRouting:dStartGMT
		        IF dStart1 == DateTime.MinValue
		    	    ErrorBox("No Start date defined")
		    	    SELF:barEditItemPeriod:EditValue := "Last 6 months"
		    	    RETURN
		        ENDIF
		        dEnd1 := oLBCItemRouting:dEndGMT
		        IF dEnd1 == DateTime.MaxValue
		    	    dEnd1 := dNow
		        ENDIF
		        cDateTerm := " AND FMDataPackages.DateTimeGMT BETWEEN '"+dStart1:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dEnd1:ToString("yyyy-MM-dd HH:mm:ss")+"'"
        ENDIF
    
	CASE cPeriod == "Specific date period"
		LOCAL oSelectDatesSimpleForm := SelectDatesSimpleForm{} AS SelectDatesSimpleForm
		oSelectDatesSimpleForm:DateFrom:DateTime := dStart
		oSelectDatesSimpleForm:DateTo:DateTime := TimeZoneInfo.ConvertTime(dEnd, TimeZoneInfo.Utc)
		oSelectDatesSimpleForm:ShowDialog()
		IF oSelectDatesSimpleForm:DialogResult <> DialogResult.OK
			SELF:barEditItemPeriod:EditValue := "Last 6 months"
			RETURN
		ENDIF

		dStart := oSelectDatesSimpleForm:DateFrom:DateTime
		dEnd := oSelectDatesSimpleForm:DateTo:DateTime
		cDateTerm := " AND FMDataPackages.DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm:ss")+"'"
		//SELF:Cursor := Cursors.WaitCursor
		//Application.DoEvents()
	ENDCASE

	/*DO CASE
	CASE symServer == #SQLite
		cSQLDate := "Date(FMData.DateTimeGMT)"
		//cSQLDate := "strftime('%Y-%m-%d, %H', FMData.DateTimeGMT)"

	OTHERWISE
		cSQLDate := "Cast(FMData.DateTimeGMT AS Date)"
		//cSQLDate := "convert(varchar(10),DateTimeGMT,120) + ', '+ (CASE WHEN datepart(hour,DateTimeGMT)<=9 THEN '0'+convert(varchar(2), datepart(hour,DateTimeGMT)) ELSE convert(varchar(2), datepart(hour,DateTimeGMT)) END)"
	ENDCASE*/

	IF cReportName:ToUpper():StartsWith("MODE")
		cStatement:="SELECT FMDataPackages.DateTimeGMT, FMReportTypes.ReportName"+;
					" FROM FMDataPackages"+SELF:cNoLockTerm+;
					" INNER JOIN FMReportTypes ON FMReportTypes.REPORT_UID=FMDataPackages.REPORT_UID"+;
					" AND FMReportTypes.ReportType='V' "+;
					" WHERE  FMDataPackages.Visible=1 AND FMDataPackages.VESSEL_UNIQUEID="+cUID+;
					cDateTerm+;
					" ORDER BY FMDataPackages.DateTimeGMT DESC"
	ELSE
		cStatement:="SELECT FMDataPackages.DateTimeGMT, FMReportTypes.ReportName"+;
					" FROM FMDataPackages"+SELF:cNoLockTerm+;
					" INNER JOIN FMReportTypes ON FMReportTypes.REPORT_UID=FMDataPackages.REPORT_UID"+;
					" INNER JOIN FMReportTypesVessel ON FMReportTypes.REPORT_UID=FMReportTypesVessel.REPORT_UID"+;
					"	AND FMDataPackages.VESSEL_UNIQUEID=FMReportTypesVessel.VESSEL_UNIQUEID"+;
					" WHERE FMDataPackages.Visible=1 AND FMDataPackages.VESSEL_UNIQUEID="+cUID+;
					" AND FMDataPackages.REPORT_UID="+cReportUID+;
					cDateTerm+;
					" ORDER BY FMDataPackages.DateTimeGMT DESC"
	ENDIF
	// Show last 30 Reports
	//cStatement := oSoftway:SelectTop(cStatement, nShowLastReports)
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	//wb(cStatement, oDT:Rows:Count:ToString())

	LOCAL n, nCount := oDT:Rows:Count - 1 AS INT
	//LOCAL oCheckedListBoxItem AS DevExpress.XtraEditors.Controls.CheckedListBoxItem
	LOCAL cText AS STRING

	SELF:LBCVesselReports:Items:Clear()
	FOR n:=0 UPTO nCount
		cText := DateTime.Parse(oDT:Rows[n]:Item["DateTimeGMT"]:ToString()):ToString("dd/MM/yyyy HH:mm")+" "+oDT:Rows[n]:Item["ReportName"]:ToString()
		//oCheckedListBoxItem := DevExpress.XtraEditors.Controls.CheckedListBoxItem{Convert.ToInt32(oDT:Rows[n]:Item["VESSEL_UNIQUEID"]:ToString()), cVessel}
		/*LOCAL place :=*/ SELF:LBCVesselReports:Items:Add(cText)/* AS INT*/
		//LOCAL node := SELF:LBCVesselReports:GetItem(place) AS OBJECT
	NEXT
RETURN


//METHOD SelectedVesselCheckedChanged(e AS DevExpress.XtraEditors.Controls.ItemCheckEventArgs) AS VOID
//	// Update FMUserVessels Table 
//	LOCAL cStatement, cUID := SELF:CheckedLBCVessels:Items[e:Index]:Value:ToString() AS STRING

//	IF e:State == CheckState.Checked
//		cStatement:="INSERT INTO FMUserVessels (USER_UNIQUEID, VESSEL_UNIQUEID)"+;
//					" SELECT "+oUser:USER_UNIQUEID+","+cUID+;
//					Iif(symServer == #MySQL, " FROM GlobalSettings", "")+;
//					" WHERE NOT EXISTS"+;
//					" (SELECT USER_UNIQUEID FROM FMUserVessels"+;
//					"	WHERE USER_UNIQUEID="+oUser:USER_UNIQUEID+;
//					"	AND VESSEL_UNIQUEID="+cUID+")"
//		oSoftway:AdoCommand(SELF:oGFH, SELF:oConn, cStatement)
//	ELSE
//		cStatement:="DELETE FROM FMUserVessels"+;
//					" WHERE USER_UNIQUEID="+oUser:USER_UNIQUEID+;
//					" AND VESSEL_UNIQUEID="+cUID
//		oSoftway:AdoCommand(SELF:oGFH, SELF:oConn, cStatement)
//	ENDIF
//RETURN


METHOD CheckAllVessels() AS VOID
	//FOREACH oCheckedListBoxItem AS DevExpress.XtraEditors.Controls.CheckedListBoxItem IN SELF:CheckedLBCVessels:Items
	//	IF oCheckedListBoxItem:CheckState <> CheckState.Checked
	//		oCheckedListBoxItem:CheckState := CheckState.Checked
	//	ENDIF
	//NEXT
RETURN


METHOD AssignColor(cValue AS STRING) AS Color
	LOCAL nRed, nGreen, nBlue AS INT
	LOCAL oColor AS Color

	oMainForm:SplitColorToRGB(cValue, nRed, nGreen, nBlue)
	oColor:=Color.FromArgb(nRed, nGreen, nBlue)
	IF oColor == Color.Empty
		oColor:=Color.Transparent
	ELSE
		oColor:=oColor
	ENDIF
RETURN oColor


//Method AssignColor(oControl as ColorEdit, cField as string) as void
//	Local nRed, nGreen, nBlue as int
//	Local oColor as Color

//	oMainForm:SplitColorToRGB(Self:oRow:Item[cField]:ToString(), nRed, nGreen, nBlue)
//	oColor:=Color.FromArgb(nRed, nGreen, nBlue)
//	if oControl:Color == Color.Empty
//		oControl:Color:=Color.Transparent
//	else
//		oControl:Color:=oColor
//	endif
//Return


METHOD SplitColorToRGB(cColor AS STRING, nRed REF LONG, nGreen REF LONG, nBlue REF LONG) AS VOID
	IF cColor == ""
		// Color.Black
		nRed:=0
		nGreen:=0
		nBlue:=0
		RETURN
	ENDIF

	LOCAL nFolderTextColor, nRest AS LONG

	nFolderTextColor:=Convert.ToInt32(cColor)
	// nRed * (256 * nGreen) * (256 * 256 * nBlue)
	IF nFolderTextColor > 0
		nBlue:=nFolderTextColor / (256 * 256)

		nRest:=nFolderTextColor - (256 * 256 * nBlue)
		IF nRest < 0; nRest:=0; ENDIF
		nGreen:=nRest / 256

		nRest:=nRest - (256 * nGreen)
		IF nRest < 0; nRest:=0; ENDIF
		nRed:=nRest
	ELSE
		// Color.Black
		nRed:=0
		nGreen:=0
		nBlue:=0
	ENDIF
RETURN


METHOD ConvertColorToColorObject(cUserColor AS STRING) AS Color
LOCAL nRed, nGreen, nBlue AS INT
LOCAL oColor AS Color

	IF cUserColor == "" .OR. cUserColor == "0"
		// Black background
		oColor:=Color.Transparent
	ELSE
		SELF:SplitColorToRGB(cUserColor, nRed, nGreen, nBlue)
		oColor:=Color.FromArgb(nRed, nGreen, nBlue)
	ENDIF
RETURN oColor


METHOD CreateDXColumn(cCaption AS STRING, cFieldName AS STRING, lEdit AS LOGIC, uType AS DevExpress.Data.UnboundColumnType,;
						nGridColumnAbsoluteIndex AS INT, nIndex AS INT, nSize AS INT, ;
						oGridView AS DevExpress.XtraGrid.Views.Grid.GridView) AS GridColumn
	// For general use
	LOCAL oGridColumn AS GridColumn

	oGridColumn:=GridColumn{}
	oGridColumn:Caption:=cCaption
	oGridColumn:FieldName:=cFieldName
	//oGridColumn:UnboundExpression:=cExpression
	oGridColumn:UnboundType := uType

	// GridView
	oGridView:Columns:Add(oGridColumn)

	oGridColumn:AppearanceHeader:TextOptions:Trimming := DevExpress.Utils.Trimming.None
	//oGridColumn:MinWidth:=20	// Default

	oGridColumn:AbsoluteIndex:=nGridColumnAbsoluteIndex
	IF nIndex <> -1
		oGridColumn:VisibleIndex:=nIndex
	ENDIF
	IF nSize <> -1
		oGridColumn:Width := nSize
	ELSE
		oGridColumn:BestFit()
	ENDIF
	oGridColumn:OptionsColumn:AllowEdit := lEdit
RETURN oGridColumn


METHOD GetPropellerPitch() AS STRING
	LOCAL cStatement AS STRING

	cStatement:="SELECT PropellerPitch FROM SupVessels"+oMainForm:cNoLockTerm+;
				" INNER JOIN Vessels ON SupVessels.VESSEL_UNIQUEID=Vessels.VESSEL_UNIQUEID"+;
				" AND SupVessels.VESSEL_UNIQUEID="+oMainForm:GetVesselUID:ToString()
	LOCAL cPP := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "PropellerPitch") AS STRING
	IF cPP == "0"
		RETURN ""
	ENDIF
RETURN cPP


METHOD ShowReportForm(modal AS LOGIC, createReport AS LOGIC, lPrintReport := FALSE AS LOGIC,cSpecificItemUIDs := "" AS STRING) AS VOID
	IF SELF:TreeListVessels:FocusedNode == NULL
		RETURN
	ENDIF

	IF oMainForm:LBCReports:SelectedItems:Count == 0
		RETURN
	ENDIF

	IF SELF:LBCVesselReports:SelectedItems:Count == 0 .AND. SELF:TreeListVesselsReports:Visible == FALSE
		RETURN
	ENDIF

	// TODO: LBCVesselReports_DoubleClick Event: Change the called METHOD to ShowLinkedMessage()
	LOCAL cStatement AS STRING
	LOCAL cReportUID := oMainForm:LBCReports:SelectedValue:ToString() AS STRING
	LOCAL cReportName := oMainForm:LBCReports:GetDisplayItemValue(oMainForm:LBCReports:SelectedIndex):ToString() AS STRING
	LOCAL cVesselName := oMainForm:GetVesselUID AS STRING

	IF cReportUID:Trim() == "7" .AND.  SELF:TreeListVesselsReports:Visible == TRUE
		cReportUID := SELF:getReportIUDfromPackage(SELF:TreeListVesselsReports:FocusedNode:Tag:ToString())
	ENDIF
	//
	LOCAL cSpecificItemsSQL :="" AS STRING
	IF cSpecificItemUIDs!=""
		cSpecificItemsSQL := " AND FMReportItems.ITEM_UID In ("+cSpecificItemUIDs+") "
	ENDIF
	
	cStatement:="SELECT DISTINCT FMItemCategories.CATEGORY_UID, FMItemCategories.Description, FMItemCategories.SortOrder"+;
				" FROM FMItemCategories"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMReportItems ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
				" AND FMReportItems.REPORT_UID="+cReportUID+ " AND FMItemCategories.CATEGORY_UID<>0 "+;
				" ORDER BY FMItemCategories.SortOrder"
	LOCAL oDTItemCategories := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

	cStatement:="SELECT FMReportItems.*"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" LEFT OUTER JOIN FMItemCategories ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
				" WHERE REPORT_UID="+cReportUID+cSpecificItemsSQL+;
				" ORDER BY FMItemCategories.SortOrder, ItemNo"
				//" AND CATEGORY_UID="+cCatUID+;
	LOCAL oDTReportItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

	FOREACH ctr AS Control IN SELF:splitMapForm:Controls
		TRY
			LOCAL fm AS Form 
			fm := (Form)ctr
			fm:Close()
		CATCH
			
		END
	NEXT
	
	//LOCAL oReportTabForm := ReportTabForm{} AS ReportTabForm
	IF(!modal)
			IF SELF:myReportTabForm <> NULL
				SELF:myReportTabForm:Close()
				SELF:myReportTabForm:Dispose()
			ENDIF
	
			SELF:myReportTabForm := ReportTabForm{} 
			SELF:myReportTabForm:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Dpi
			//SELF:splitMapForm:PanelVisibility := SplitPanelVisibility.Both
			SELF:myReportTabForm:Text := cVesselName+ ": "+ cReportName			
			SELF:myReportTabForm:cReportUID := cReportUID
			SELF:myReportTabForm:cReportName := cReportName
			SELF:myReportTabForm:cMyVesselName := SELF:GetVesselName
			SELF:myReportTabForm:cVesselUID := SELF:GetVesselUID
			SELF:myReportTabForm:oDTItemCategories := oDTItemCategories
			SELF:myReportTabForm:oDTReportItems := oDTReportItems
			SELF:myReportTabForm:TopLevel := FALSE
			//SELF:myReportTabForm:Enabled := FALSE
			SELF:myReportTabForm:FormBorderStyle := FormBorderStyle.None
			SELF:myReportTabForm:AutoScroll := TRUE
			SELF:splitMapForm:Panel1:Controls:Add(SELF:myReportTabForm)
			SELF:splitMapForm:Panel1:AutoScroll := TRUE
			SELF:myReportTabForm:cMyPackageUID := TreeListVesselsReports:FocusedNode:Tag:ToString()
			SELF:myReportTabForm:Dock := DockStyle.Fill
			SELF:myReportTabForm:Show()
			IF SELF:BBIEditReport:Visibility ==  DevExpress.XtraBars.BarItemVisibility.Always
				SELF:BBIEditReport:Enabled := TRUE
				SELF:BBISave:Enabled := FALSE
				SELF:BBICancel:Enabled := FALSE
				SELF:BBIFinalize:Enabled := FALSE
			ENDIF
			IF SELF:BBIDelete:Visibility == DevExpress.XtraBars.BarItemVisibility.Always
				SELF:BBIDelete:Enabled := TRUE
			ENDIF
			SELF:myReportTabForm:Enabled := TRUE
			SELF:barEditItemDisplayMap:Visibility := DevExpress.XtraBars.BarItemVisibility.Always
			IF SELF:splitMapForm:SplitterPosition == 0
				SELF:LBCDisplayMapViewChanged()
				//SELF:splitMapForm:SplitterPosition := (INT)(SELF:splitMapForm:Width*0.75)
			ENDIF
	ELSE
			IF lPrintReport
				printOnBackground(cReportUID,cReportName,oDTItemCategories,oDTReportItems)
			ELSE
				LOCAL oMyReportTabForm := ReportTabForm{} AS ReportTabForm
				//SELF:splitMapForm:PanelVisibility := SplitPanelVisibility.Both
				//oMyReportTabForm:DoubleBuffered := true
				IF createReport
					oMyReportTabForm:Text := "New : "+cReportName
				ELSE
					oMyReportTabForm:Text := SELF:TreeListVesselsReports:FocusedNode:GetValue(0):ToString()+" for "+SELF:TreeListVessels:FocusedNode:GetValue(0):ToString()
				ENDIF
				
				oMyReportTabForm:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Dpi
				oMyReportTabForm:cReportUID := cReportUID
				oMyReportTabForm:cReportName := cReportName
				oMyReportTabForm:cMyVesselName := SELF:GetVesselName
				oMyReportTabForm:cVesselUID := SELF:GetVesselUID
				oMyReportTabForm:oDTItemCategories := oDTItemCategories
				oMyReportTabForm:oDTReportItems := oDTReportItems
				oMyReportTabForm:AutoScroll := TRUE
				oMyReportTabForm:ReportMainMenu:Visible := createReport
				IF createReport
					LOCAL cStatementLocal:="INSERT INTO FMDataPackages (VESSEL_UNIQUEID, REPORT_UID, DateTimeGMT, GmtDiff, MSG_UNIQUEID, Memo, Matched, Username) VALUES"+;
					" ("+SELF:GetVesselUID+", "+cReportUID+", CURRENT_TIMESTAMP , 2,"+;
					" 0, '' , 0, '"+oUser:Username+"' )" AS STRING
					IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatementLocal)
						ErrorBox("Cannot insert FMDataPackages entry for Vessel="+cVesselName)
						RETURN
					ENDIF
					LOCAL cPackageUID := oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "FMDataPackages", "PACKAGE_UID") AS STRING
					oMyReportTabForm:cMyPackageUID := cPackageUID
					oMyReportTabForm:lEnableControls := createReport
					oMyReportTabForm:lisNewReport := createReport
				ELSE
					oMyReportTabForm:cMyPackageUID := TreeListVesselsReports:FocusedNode:Tag:ToString()
				ENDIF
				oMyReportTabForm:Show()
				Application.DoEvents()
				IF createReport
					oMyReportTabForm:ReadOnlyControls(TRUE)
				ENDIF
				Application.DoEvents()
			ENDIF
	ENDIF
	//SELF:myReportTabForm := oReportTabForm
	//SELF:myReportTabForm:WindowState := FormWindowState.Maximized
	
RETURN

METHOD printOnBackground(cReportUID AS STRING,cReportName AS STRING,oDTItemCategories AS DataTable,oDTReportItems AS DataTable) AS VOID
	LOCAL oMyReportTabForm := ReportTabForm{} AS ReportTabForm
    oMyReportTabForm:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Dpi
	//SELF:splitMapForm:PanelVisibility := SplitPanelVisibility.Both
	oMyReportTabForm:Text := SELF:TreeListVesselsReports:FocusedNode:GetValue(0):ToString()+" for "+SELF:TreeListVessels:FocusedNode:GetValue(0):ToString()
	oMyReportTabForm:cReportUID := cReportUID
	oMyReportTabForm:cReportName := cReportName
	oMyReportTabForm:oDTItemCategories := oDTItemCategories
	oMyReportTabForm:oDTReportItems := oDTReportItems
	oMyReportTabForm:AutoScroll := TRUE
	oMyReportTabForm:ReportMainMenu:Visible := FALSE
	oMyReportTabForm:lEnableControls := FALSE
	oMyReportTabForm:cMyPackageUID := TreeListVesselsReports:FocusedNode:Tag:ToString()
	LOCAL oBW := BackgroundWorker{} AS BackgroundWorker
	oBW:WorkerReportsProgress := TRUE
	oBW:WorkerSupportsCancellation := TRUE
	oBW:DoWork += DoWorkEventHandler{SELF,@workerToPrint()}
	oBW:ProgressChanged += ProgressChangedEventHandler{SELF,@WorkerReportedFinished()}
	oBW:RunWorkerAsync(oMyReportTabForm)
RETURN

METHOD workerToPrint( sender AS System.Object, e AS DoWorkEventArgs ) AS VOID
				LOCAL worker := (BackgroundWorker)sender AS BackgroundWorker
				LOCAL oMyReportTabForm := (ReportTabForm)e:Argument AS ReportTabForm
				//		worker:CancelAsync()
				//oMyReportTabForm:Visible:= FALSE
				oMyReportTabForm:Show()
				worker:ReportProgress(50)
				//oMyReportTabForm:Visible:= FALSE
				Application.DoEvents()
				oMyReportTabForm:Form_ExportToPDF()
				oMyReportTabForm:Close()
				worker:ReportProgress(100)
RETURN

	METHOD WorkerReportedFinished(sender AS System.Object, e AS ProgressChangedEventArgs ) AS VOID
		LOCAL worker := (BackgroundWorker)sender AS BackgroundWorker
		IF e:ProgressPercentage == 100
				worker:CancelAsync()
		ELSEIF e:ProgressPercentage == 50
				SELF:BringToFront()
				SELF:Activate()
		ENDIF
	RETURN

METHOD ShowLinkedMessage() AS VOID
	IF SELF:TreeListVessels:FocusedNode == NULL
		RETURN
	ENDIF

	IF oMainForm:LBCReports:SelectedItems:Count == 0
		RETURN
	ENDIF

	IF SELF:LBCVesselReports:SelectedItems:Count == 0  .AND. SELF:TreeListVesselsReports:Visible == FALSE
		RETURN
	ENDIF

	// Locate Message:
	LOCAL cStatement AS STRING
	LOCAL cReportUID := oMainForm:LBCReports:SelectedValue:ToString() AS STRING

	IF SELF:TreeListVesselsReports:Visible
		cStatement:="SELECT MSG_UNIQUEID"+;
					" FROM FMDataPackages"+;
					" WHERE FMDataPackages.PACKAGE_UID="+oMainForm:TreeListVesselsReports:FocusedNode:Tag:ToString()+" "
	ELSE
		LOCAL cDate := oMainForm:LBCVesselReports:SelectedItem:ToString() AS STRING
		cDate := cDate:SubString(0, 16)		// 10/12/2014 HH:mm
		LOCAL dStart := Datetime.Parse(cDate) AS DateTime
		LOCAL dEnd := dStart:AddMinutes(1) AS DateTime
		
		cStatement:="SELECT MSG_UNIQUEID"+;
					" FROM FMDataPackages"+;
					" WHERE FMDataPackages.VESSEL_UNIQUEID="+SELF:GetVesselUID+;
					" AND REPORT_UID="+cReportUID+;
					" AND DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm")+"'"
	ENDIF
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

	IF oDT:Rows:Count == 0
		wb("No linked Message(s) found")
		RETURN
	ENDIF

	LOCAL cUID := oDT:Rows[0]:Item["MSG_UNIQUEID"]:ToString() AS STRING
	IF cUID == "0"
		wb("No linked message found")
		RETURN
	ENDIF

	LOCAL cVesselName := oMainForm:GetVesselName AS STRING
	LOCAL cReportName AS STRING
	
	IF SELF:TreeListVesselsReports:Visible
		cReportName := oMainForm:TreeListVesselsReports:FocusedNode:Data:ToString()
	ELSE
		cReportName := oMainForm:LBCVesselReports:SelectedItem:ToString()
	ENDIF

	// NamedPipe: Show message(s) into a new Communicator Tab
	LOCAL cAddTagInfo := "" AS STRING
	cAddTagInfo += "Fleet Manager seach result"+CRLF
	cAddTagInfo += "Vessel: "+cVesselName+CRLF
	cAddTagInfo += "Report: "+cReportName+CRLF
	oSoftway:ClientNamedPipe(oDT, "FleetManager", cAddTagInfo, cUID)
RETURN


METHOD IsmFormBodyText() AS VOID
	IF SELF:TreeListVessels:FocusedNode == NULL
		RETURN
	ENDIF

	IF oMainForm:LBCReports:SelectedItems:Count == 0
		RETURN
	ENDIF

	IF SELF:LBCVesselReports:SelectedItems:Count == 0  .AND. SELF:TreeListVesselsReports:Visible == FALSE
		RETURN
	ENDIF

	// Locate Message:
	LOCAL cStatement, cReportTerm := "" AS STRING
	LOCAL cReportUID := oMainForm:LBCReports:SelectedValue:ToString() AS STRING
	LOCAL cReportName := SELF:LBCReports:GetDisplayItemValue(SELF:LBCReports:SelectedIndex):ToString() AS STRING
	LOCAL cVesselName := oMainForm:GetVesselName AS STRING

	IF ! cReportName:ToUpper():StartsWith("MODE")
		cReportTerm := " AND REPORT_UID="+cReportUID
	ENDIF

	
	
	IF SELF:TreeListVesselsReports:Visible
		cStatement:="SELECT MSG_UNIQUEID"+;
					" FROM FMDataPackages"+;
					" WHERE FMDataPackages.PACKAGE_UID="+oMainForm:TreeListVesselsReports:FocusedNode:Tag:ToString()+" "
	ELSE
		LOCAL cDate := oMainForm:LBCVesselReports:SelectedItem:ToString() AS STRING
		cDate := cDate:SubString(0, 16)		// 10/12/2014 HH:mm
		LOCAL dStart := Datetime.Parse(cDate) AS DateTime
		LOCAL dEnd := dStart:AddMinutes(1) AS DateTime
		
		cStatement:="SELECT MSG_UNIQUEID"+;
					" FROM FMDataPackages"+oMainForm:cNoLockTerm+;
					" WHERE FMDataPackages.VESSEL_UNIQUEID="+SELF:GetVesselUID+;
					cReportTerm+;
					" AND DateTimeGMT BETWEEN '"+dStart:ToString("yyyy-MM-dd HH:mm")+"' AND '"+dEnd:ToString("yyyy-MM-dd HH:mm")+"'"
	ENDIF
	LOCAL cUID := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "MSG_UNIQUEID") AS STRING
	IF cUID == ""
		wb("No linked Message(s) found")
		RETURN
	ENDIF

	cStatement:="SELECT Memo FROM MSG32"+SELF:cNoLockTerm+;
				" WHERE MSG_UNIQUEID="+cUID
	LOCAL cText := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Memo") AS STRING

	LOCAL oBodyISMForm := BodyISMForm{} AS BodyISMForm
	oBodyISMForm:cReportUID := cReportUID
	oBodyISMForm:cReportName := cReportName
	oBodyISMForm:cVesselName := cVesselName
	oBodyISMForm:Text := "eMail Body text"
	oBodyISMForm:cShowText := cText
	oBodyISMForm:Show()
RETURN


METHOD ReadBodyISM(cReportUID AS STRING, cEMail REF STRING) AS STRING
	LOCAL cBodyText := "", cNewBody AS STRING
	LOCAL cStatement AS STRING
	LOCAL oDT AS DataTable

	cStatement:="SELECT BodyText, eMail FROM FMBodyText"+oMainForm:cNoLockTerm+;
				" WHERE REPORT_UID="+cReportUID
	oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	IF oDT:Rows:Count == 0
		cNewBody := SELF:FillBodyItems(cReportUID)
		cStatement:="INSERT INTO FMBodyText (REPORT_UID, BodyText) VALUES ("+cReportUID+", '"+oSoftway:ConvertWildcards(cNewBody, FALSE)+"')"
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)

		cStatement:="SELECT BodyText, eMail FROM FMBodyText"+oMainForm:cNoLockTerm+;
					" WHERE REPORT_UID="+cReportUID
		oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	ENDIF

	cEMail := oDT:Rows[0]:Item["eMail"]:ToString()
	IF cEMail == ""
		// Select any eMail
		cStatement:="SELECT eMail FROM FMBodyText"+oMainForm:cNoLockTerm+;
					" WHERE eMail IS NOT NULL"
		cStatement := oSoftway:SelectTop(cStatement)
		cEMail := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "eMail")
	ENDIF

	cBodyText := oDT:Rows[0]:Item["BodyText"]:ToString()
	IF  cBodyText == ""
		cNewBody := SELF:FillBodyItems(cReportUID)
		cStatement:="UPDATE FMBodyText SET BodyText='"+oSoftway:ConvertWildcards(cNewBody, FALSE)+"'"+;
					" WHERE REPORT_UID="+cReportUID
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		cBodyText := cNewBody
	ENDIF
RETURN cBodyText


METHOD FillBodyItems(cReportUID AS STRING) AS STRING
	LOCAL cBodyText := "" AS STRING
	LOCAL cStatement AS STRING

	cStatement:="SELECT ItemNo, ItemName"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMReportTypes ON FMReportTypes.REPORT_UID=FMReportItems.REPORT_UID"+;
				"	AND FMReportTypes.REPORT_UID="+cReportUID+;
				" LEFT OUTER JOIN FMItemCategories ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
				" ORDER BY FMItemCategories.SortOrder, ItemNo"
	LOCAL oDT :=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	IF oDT:Rows:Count == 0
		RETURN ""
	ENDIF

	FOREACH oRow AS DataRow IN oDT:Rows
		cBodyText += oRow["ItemName"]:ToString()+": <ID"+oRow["ItemNo"]:ToString()+">"+CRLF
	NEXT
RETURN cBodyText


METHOD TextEditValueToSQL(cValue AS STRING) AS STRING
	IF cValue == NULL .OR.cValue:ToString() == ""
		RETURN "0"
	ENDIF
	cValue := cValue:Replace(SELF:groupSeparator, ""):Replace(SELF:decimalSeparator, ".")
RETURN cValue


METHOD AddNewPort(cPort AS STRING) AS STRING
LOCAL cStatement, cUID AS STRING

	cStatement:="INSERT INTO VEPorts (Port) VALUES"+;
				" ('"+oSoftway:ConvertWildCards(cPort, FALSE)+"')"
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		cUID := "0"
	ELSE
		cUID:=oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "VEPorts", "PORT_UID")
	ENDIF
RETURN cUID


METHOD GetDistances(cPort1 AS STRING, cPort2 AS STRING, cVia AS STRING) AS DataTable
LOCAL cStatement AS STRING
LOCAL oDTDistance AS DataTable

	cStatement:="SELECT DISTANCE_UID, Distance FROM VEDistances"+;
				" WHERE PortFrom="+cPort1+;
				" AND PortTo="+cPort2+;
				" OR PortTo="+cPort1+;
				" AND PortFrom="+cPort2
	IF cVia <> NULL
		cStatement+=" AND PortVia="+cVia
	ENDIF

	oDTDistance := oSoftway:ResultTable(SELF:oGFH, SELF:oConn, cStatement)
RETURN oDTDistance


METHOD ShowSelectedVoyageOnMap() AS VOID
	IF SELF:TreeListVessels:FocusedNode == NULL //Antonis 27.11.14 //
        wb("No Vessel selected")
		RETURN
	ENDIF
	LOCAL cUID := SELF:GetVesselUID AS STRING
    IF cUID == "0"
        wb("No Vessel selected")
		RETURN
    ENDIF

	LOCAL oBingMapForm := BingMapForm{} AS BingMapForm

	LOCAL oSelectVoyageForm := SelectVoyageForm{} AS SelectVoyageForm
	oSelectVoyageForm:cVesselUID := cUID
	oSelectVoyageForm:ShowDialog()
	IF oSelectVoyageForm:DialogResult <> DialogResult.OK
		RETURN
	ENDIF

	oBingMapForm:cVesselUID := cUID
	oBingMapForm:oLBCItemVoyage := (MyLBCVoyageItem)oSelectVoyageForm:LBCVoyages:SelectedItem
	oBingMapForm:oLBCItemRouting := (MyLBCVoyageItem)oSelectVoyageForm:LBCRouting:SelectedItem
	IF oBingMapForm:oLBCItemVoyage == NULL .OR. oBingMapForm:oLBCItemRouting == NULL
		WB("No Voyage or Routing selected. Please try again.")
		RETURN
	ENDIF	
	
	IF ! oBingMapForm:ReadDates()
		RETURN
	ENDIF

	oBingMapForm:Text := ((MyLBCVoyageItem)oSelectVoyageForm:LBCRouting:SelectedItem):Name
	//oBingMapForm:Text := oSelectVoyageForm:GetSelectedLBCItem(oSelectVoyageForm:LBCRouting, "Name")
	oBingMapForm:Show()
RETURN

METHOD createNewReport()  AS VOID
		IF SELF:GetVesselUID == "0"
			MessageBox.Show("Select a Vessel to create the report.")
			RETURN
		ENDIF		
		
		IF SELF:ReportsTabUserControl:SelectedIndex == 0
				MessageBox.Show("Can not create vessel report.")
			ELSE
				ShowReportForm(TRUE,TRUE)		
		ENDIF
RETURN

METHOD backBBI_ItemClickMethod() AS VOID
	//SELF:TreeListVesselsReports:Visible := TRUE 	
	//SELF:treeListTCReports:Visible := FALSE
	//SELF:treeListTCReports:Nodes:Clear() 
	SELF:lisTC := FALSE
	SELF:cTCParent := ""
	SELF:backBBI:Enabled := FALSE
	SELF:Fill_TreeList_Reports()
RETURN


EXPORT METHOD getReportIUDfromPackage(cPackUID AS STRING) AS STRING
	LOCAL cStatement := "Select REPORT_UID From FMDataPackages Where Package_uid="+cPackUID AS STRING

	LOCAL cReportUID := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "REPORT_UID") AS STRING

RETURN cReportUID


METHOD ReportDefinition() AS VOID
	////IF SELF:CheckedLBCVessels:SelectedIndex == -1
	////	wb("No Vessel selected")
	////	RETURN
	////ENDIF

	//IF SELF:CBEVoyage:SelectedItem == NULL .or. SELF:CBEVoyage:SelectedIndex == -1
	//	wb("No Voyage selected")
	//	RETURN
	//ENDIF

	//IF SELF:CBERouting:SelectedItem == NULL .or. SELF:CBERouting:SelectedIndex == -1
	//	wb("No Voyage routing selected")
	//	RETURN
	//ENDIF

	LOCAL oReportDefinitionForm := ReportDefinitionForm{} AS ReportDefinitionForm
	//oReportDefinitionForm:oLBCItemVoyage := (MyLBCVoyageItem)SELF:CBEVoyage:SelectedItem
	//oReportDefinitionForm:oLBCItemRouting := (MyLBCVoyageItem)SELF:CBERouting:SelectedItem
	oReportDefinitionForm:Show()
RETURN

METHOD ShowSetupUsersForm AS VOID
	IF ! oUser:lMasterUser
		wb("This operation is not supported for Non-Master Users."+CRLF+;
			"Please ask your system administrator (or a Master User) to perform this task")
		RETURN
	ENDIF
	
	LOCAL oDTUsers AS DataTable
	LOCAL cStatement AS STRING
	cStatement:=" SELECT FMUsers.USER_UNIQUEID, Users.UserName "+;
				" FROM FMUsers"+;
				" INNER JOIN Users On Users.User_UniqueId = FMUsers.User_UniqueId "+;
				" ORDER BY Users.UserName"
	oDTUsers := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	oSoftway:CreatePK(oDTUsers, "USER_UNIQUEID")
	LOCAL oUsersSetupForm := UsersSetupForm{} AS UsersSetupForm
	oUsersSetupForm:Show()
	oUsersSetupForm:formUsersList(oDTUsers)
RETURN


METHOD ShowSetupUserGroupsForm() AS VOID
	IF ! oUser:lMasterUser
		wb("This operation is not supported for Non-Master Users."+CRLF+;
			"Please ask your system administrator (or a Master User) to perform this task")
		RETURN
	ENDIF
	
	LOCAL oDTGroups AS DataTable
	LOCAL cStatement AS STRING
	cStatement:="SELECT FMUserGroups.*"+;
				" FROM FMUserGroups"+;
				" ORDER BY GroupName"
	oDTGroups := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	oSoftway:CreatePK(oDTGroups, "GROUP_UID")
	LOCAL oGroupsSetupForm := GroupsSetupForm{} AS GroupsSetupForm
	oGroupsSetupForm:Show()
	oGroupsSetupForm:formGroupsList(oDTGroups)
RETURN


METHOD ShowApprovalsForm() AS VOID
	IF myTimer <> NULL .AND. (STRING)myTimer:Tag=="1"	
		myTimer:Stop()	
	ENDIF
	
	IF oMyApproval_Form!=NULL
		oMyApproval_Form:BringToFront()
	ELSE
		LOCAL oApproval_Form := Approval_Form{} AS Approval_Form
		oApproval_Form:cMyUser := oUser:User_Uniqueid
		oApproval_Form:oConn := oMainForm:oConn
		oApproval_Form:oGFH := oMainForm:oGFH
		oApproval_Form:FormClosed += FormClosedEventHandler{SELF,@restartTimer()}
		oApproval_Form:Show()
		oApproval_Form:getApprovalsForProgram(2)
		oApproval_Form:CreateGridApprovals_Columns()
		oApproval_Form:gridViewRefresh()
		oMyApproval_Form := oApproval_Form
	ENDIF
	
RETURN

	METHOD restartTimer(sender AS OBJECT,e AS FormClosedEventArgs ) AS VOID
		IF myTimer:Tag:ToString() == "1"
			myTimer:Start()
		ENDIF
	RETURN

METHOD showGlobalSettingsForm AS VOID
	IF ! oUser:lMasterUser
		wb("This operation is not supported for Non-Master Users."+CRLF+;
			"Please ask your system administrator (or a Master User) to perform this task")
		RETURN
	ENDIF
	
	LOCAL oMatchSettings := MatchSettings{} AS MatchSettings
	oMatchSettings:checkForCrewOwnedVessels()
	LOCAL oDTUsers AS DataTable
	LOCAL cStatement:="SELECT RTRIM(Vessels.VesselName) as VesselName , FMGlobalSettings.Vessel_UniqueID "+;
				" FROM FMGlobalSettings, Vessels"+;
				" Where FMGlobalSettings.Vessel_UniqueID = Vessels.Vessel_UniqueID ORDER BY VesselName" AS STRING
	oDTUsers := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	oSoftway:CreatePK(oDTUsers, "Vessel_UniqueID")
	oMatchSettings:Show()
	oMatchSettings:formUsersList(oDTUsers)
RETURN

EXPORT METHOD returnGlobalSetting(cVesselUID AS STRING) AS datarow
	LOCAL oRowLocal AS DataRow
	TRY	
		LOCAL cStatement:="SELECT * "+;
					" FROM FMGlobalSettings"+SELF:cNoLockTerm+;
					" Where Vessel_Uniqueid="+cVesselUID AS STRING
		LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		
		LOCAL n:=0 AS INT
		FOREACH oRow AS DataRow IN oDT:Rows
			n++
			oRowLocal := oRow 
		NEXT
	CATCH
		RETURN NULL 
	END
	//wb(oRowLocal["CanEditVoyages"]:ToString())
RETURN oRowLocal


EXPORT METHOD updateGlobalSetting(fieldToUpdate AS STRING, valueToUpdate AS STRING, userUID AS STRING, type AS INT) AS VOID
				TRY
					LOCAL cStatement AS STRING
					DO CASE
					CASE type == 0
						cStatement:="Update FMGlobalSettings set "+fieldToUpdate+" = "+valueToUpdate+" Where Vessel_Uniqueid="+userUID
						oSoftway:AdoCommand(oGFH, oConn, cStatement)
						//WB("User Created."+cstatement)
					ENDCASE
				CATCH
					wb("Vessel Not Updated.")
				END		
RETURN



METHOD deleteDataPackage AS LOGIC	
		TRY
			IF QuestionBox("Are you sure you want to DELETE the Selected Data Package ?", ;
							"Delete Data") <> System.Windows.Forms.DialogResult.Yes
				RETURN FALSE
			ENDIF
			//SELF:TreeListVesselsReports:Refresh()
			LOCAL cPackageUID := SELF:TreeListVesselsReports:FocusedNode:Tag:ToString() AS STRING
			LOCAL cStatement:="Update FMDataPackages set Visible = 0 Where Package_Uid = "+cPackageUID AS STRING
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
			IF !deleteApprovalAsWell(cPackageUID)
				MessageBox.Show("Error on deleting approvals")
			ENDIF
			SELF:TreeListVesselsReports:DeleteNode(SELF:TreeListVesselsReports:FocusedNode)
		CATCH exc AS Exception
			WB(exc:StackTrace)
			RETURN FALSE
		END
RETURN TRUE

METHOD deleteApprovalAsWell(cPackageUID AS STRING) AS LOGIC
		TRY
			LOCAL cStatement:="Delete From ApprovalData Where Program_UID=2 AND Foreing_Uid = "+cPackageUID AS STRING
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		CATCH exc AS Exception
			RETURN FALSE
		END
RETURN TRUE

METHOD cancelChanges AS LOGIC	
		TRY
			IF QuestionBox("Are you sure you want to Cancel the changes ?", ;
							"Cancel Changes") <> System.Windows.Forms.DialogResult.Yes
				RETURN FALSE
			ENDIF
			//SELF:TreeListVesselsReports:Refresh()
			//LOCAL cPackageUID := SELF:TreeListVesselsReports:FocusedNode:Tag:ToString() AS STRING
			IF SELF:myReportTabForm:cMyPackageUID:Trim() != "" && ! SELF:myReportTabForm:lisNewReport
				SELF:myReportTabForm:lGmtDiffControlsCreated := FALSE
				FOREACH oTabPageLocal AS TabPage IN SELF:myReportTabForm:tabControl_Report:TabPages
					LOCAL dTabTag AS Dictionary<STRING, STRING>	
					dTabTag := (Dictionary<STRING, STRING>)oTabPageLocal:Tag	

					LOCAL cTagLocal := dTabTag["Status"]:ToString() AS STRING
					LOCAL cCatUIDLocal := dTabTag["TabId"]:ToString() AS STRING

					IF cTagLocal == "Appeared"
						FOREACH ctrl AS Control IN oTabPageLocal:Controls
							oTabPageLocal:Controls:Remove(ctrl)
							Application.DoEvents()
						NEXT
						dTabTag["Status"] :=  "NotAppeared"
						oTabPageLocal:Tag := dTabTag
					ENDIF
				NEXT
				LOCAL oTabPageLocal1 := SELF:myReportTabForm:tabControl_Report:SelectedTab AS TabPage 
				FOREACH ctrl AS Control IN oTabPageLocal1:Controls
					oTabPageLocal1:Controls:Remove(ctrl)
					Application.DoEvents()
				NEXT
				SELF:myReportTabForm:TabPage_Enter(oTabPageLocal1,NULL)
			ELSE
				SELF:ShowReportForm(FALSE,FALSE)	
			ENDIF



			SELF:BBIEditReport:Enabled := TRUE
			SELF:BBISubmit:Enabled := TRUE
			SELF:BBIFinalize:Enabled := FALSE
			SELF:BBISave:Enabled := FALSE
			SELF:BBICancel:Enabled := FALSE
			//LOCAL cStatement:="Update FMDataPackages set Visible = 0 Where Package_Uid = "+cPackageUID AS STRING
			//oSoftway:AdoCommand(oGFH, oConn, cStatement)
			//SELF:TreeListVesselsReports:DeleteNode(SELF:TreeListVesselsReports:FocusedNode)
		CATCH exc AS Exception
			WB(exc:StackTrace)
			RETURN FALSE
		END
RETURN TRUE

EXPORT METHOD returnSMTPSetting() AS datarow
	LOCAL oRowLocal AS DataRow
	TRY	
		
		IF oSoftway:TableExists(oMainForm:oGFH,  oMainForm:oConn, "FMTrueGlobalSettings")

			LOCAL cStatement:="SELECT TOP 1 * FROM FMTrueGlobalSettings" AS STRING
			LOCAL oDTLocal := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		
			FOREACH oRow AS DataRow IN oDTLocal:Rows
				oRowLocal := oRow 
			NEXT
			
		ENDIF

	CATCH
		RETURN NULL 
	END

RETURN oRowLocal

EXPORT METHOD returnUserSetting(User_UID AS STRING) AS datarow
	LOCAL oRowLocal AS DataRow
	TRY	
		LOCAL cStatement:="SELECT *  FROM FMUsers"+SELF:cNoLockTerm+;
					" Where USER_UNIQUEID="+User_UID AS STRING
		LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		
		LOCAL n:=0 AS INT
		FOREACH oRow AS DataRow IN oDT:Rows
			n++
			oRowLocal := oRow 
		NEXT
		IF n == 0
			LOCAL messageBoxText := "User Does Not Exist into Fleet Manager. Do you wanna create the user ?" AS STRING	
			LOCAL caption := "User Not in FM." AS STRING
			LOCAL  button := System.Windows.MessageBoxButton.OKCancel AS System.Windows.MessageBoxButton
			LOCAL  icon := System.Windows.MessageBoxImage.Warning AS System.Windows.MessageBoxImage
			LOCAL  result := System.Windows.MessageBox.Show(messageBoxText, caption, button, icon) AS System.Windows.MessageBoxResult
		
			DO CASE
				CASE result == System.Windows.MessageBoxResult.OK
					// User pressed Yes button 
					TRY
						cStatement:="INSERT INTO FMUsers (USER_UNIQUEID) VALUES ("+User_UID+")"
						oSoftway:AdoCommand(oGFH, oConn, cStatement)
						WB("User Created.")
					CATCH
						wb("User Not Created.")
					END
				ENDCASE
			RETURN NULL
		ENDIF
	CATCH
		RETURN NULL 
	END
	//wb(oRowLocal["CanEditVoyages"]:ToString())
RETURN oRowLocal

EXPORT METHOD updateUserSetting(fieldToUpdate AS STRING, valueToUpdate AS STRING, userUID AS STRING, type := 0 AS INT) AS VOID
				TRY
					LOCAL cStatement AS STRING
					DO CASE
					CASE type == 0
						cStatement:="Update FMUsers set "+fieldToUpdate+" = "+valueToUpdate+" Where User_Uniqueid="+userUID
						oSoftway:AdoCommand(oGFH, oConn, cStatement)
					CASE type == 1
						cStatement:="Update FMUsers set "+fieldToUpdate+" = '"+valueToUpdate+"' Where User_Uniqueid="+userUID
						oSoftway:AdoCommand(oGFH, oConn, cStatement)
						//WB("User Created."+cstatement)
					ENDCASE
				CATCH
					wb("User Not Updated.")
				END		
RETURN

METHOD splitterChanged(lLogic AS LOGIC) AS LOGIC
	TRY
			LOCAL iCountLength AS INT
			iCountLength := (INT) SELF:splitMapForm:SplitterPosition/SELF:splitMapForm:Width
			//SELF:splitMapForm:SplitterPosition := (INT)(SELF:splitMapForm:Width*0.75)
			SELF:barEditItemDisplayMap:EditValue := iCountLength:ToString()+"%"
	CATCH 
	END
RETURN TRUE

METHOD GetItemType(cID AS STRING) AS STRING
	LOCAL cStatement, cItemType AS STRING

	cStatement:="SELECT ItemType FROM FMReportItems"+SELF:cNoLockTerm+;
				" WHERE ItemNo="+cID
	cItemType := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "ItemType")
RETURN cItemType


PROPERTY GetVesselUID AS STRING
	GET
		IF SELF:TreeListVessels:FocusedNode == NULL .OR. SELF:TreeListVessels:FocusedNode:Tag:ToString():StartsWith("Fleet")
			RETURN "0"
		ENDIF
		RETURN SELF:TreeListVessels:FocusedNode:Tag:ToString()
	END GET
END PROPERTY


PROPERTY GetVesselName AS STRING
	GET
		IF SELF:TreeListVessels:FocusedNode:Tag:ToString():StartsWith("Fleet")
			RETURN ""
		ENDIF
		RETURN SELF:TreeListVessels:FocusedNode:GetValue(0):ToString()
	END GET
END PROPERTY

METHOD CreateDirectory(cDir AS STRING) AS LOGIC
	// Create TempDoc directory
	LOCAL oDirectoryInfo:=DirectoryInfo{cDir} AS DirectoryInfo

	IF ! oDirectoryInfo:Exists
		TRY
			oDirectoryInfo:Create()
		CATCH e AS Exception
			MessageBox.Show(e:Message, "CreateDirectory", MessageBoxButtons.OK, MessageBoxIcon.Error)
			RETURN FALSE
		END TRY
	ENDIF
RETURN TRUE

METHOD ClearDirectory(cDir AS STRING, nKeepLastDays AS Double) AS VOID
	// Delete all files from Directory
	LOCAL n, nCount AS INT
	LOCAL dDeletionDate AS DateTime
	LOCAL cNow := DateTime.Now:ToString("yyyy-MM-dd HH:mm:ss") AS STRING

	// Directories
	SELF:CreateDirectory(cDir)
	LOCAL oDirectories:=Directory.GetDirectories(cDir) AS STRING[]
	LOCAL oDirectoryInfo  AS DirectoryInfo 
	nCount:=oDirectories:Length
	FOR n:=1 UPTO nCount
		oDirectoryInfo := DirectoryInfo{oDirectories[n]}
		IF oDirectoryInfo:Name == "ExcelReports"
			LOOP
		ENDIF
		dDeletionDate:=oDirectoryInfo:LastWriteTime
		dDeletionDate:=dDeletionDate:AddDays(nKeepLastDays)
		IF dDeletionDate:ToString("yyyy-MM-dd HH:mm:ss") < cNow
			TRY
				System.IO.Directory.Delete(oDirectories[n], TRUE)
				Application.DoEvents()
			CATCH
			END TRY
		ENDIF
	NEXT

	// Files
	LOCAL oFiles:=Directory.GetFiles(cDir) AS STRING[]
	LOCAL oFileInfo AS FileInfo
	nCount:=oFiles:Length
	FOR n:=1 UPTO nCount
		oFileInfo:=FileInfo{oFiles[n]}
		dDeletionDate:=oFileInfo:LastWriteTime
		dDeletionDate:=dDeletionDate:AddDays(nKeepLastDays)
		IF dDeletionDate:ToString("yyyy-MM-dd HH:mm:ss") < cNow
			TRY
				oFileInfo:Delete()
				Application.DoEvents()
			CATCH
			END TRY
		ENDIF
	NEXT
RETURN


////////////////////////////////////////////////////////////////////////////////////////////////////
//		CHANGED BY KIRIAKOS in order to support the new database connection
////////////////////////////////////////////////////////////////////////////////////////////////////
EXPORT METHOD deleteBlobFromDB(file AS STRING, cItem_Uid AS STRING, cPackage_Uid AS STRING) AS VOID
	LOCAL cStatement AS STRING
	TRY
		IF (SELF:oConnBlob == NULL .OR. SELF:oConnBlob:State == ConnectionState.Closed)
			SELF:oConnBlob:Open()	
		ENDIF
		cStatement:="Delete From FMBlobData Where Package_Uid="+cPackage_Uid+;
					" AND Item_Uid="+cItem_Uid+" AND FileName='"+file+"'"
		IF oSoftway:AdoCommand(SELF:oGFHBlob, SELF:oConnBlob, cStatement)
			MessageBox.Show("File Deleted.")
			SELF:oConnBlob:Close()
		ENDIF
	CATCH exc AS Exception
		MessageBox.Show(exc:ToString())
	END
RETURN 

/*EXPORT METHOD deleteBlobFromDB(file AS STRING, cItem_Uid as string, cPackage_Uid as string) as Void
	LOCAL cStatement as String
	TRY
		cStatement:="Delete From FMBlobData Where Package_Uid="+cPackage_Uid+;
					" AND Item_Uid="+cItem_Uid+" AND FileName='"+file+"'"
		IF oSoftway:AdoCommand(oGFH, oConn, cStatement)
			MessageBox.Show("File Deleted.")
		ENDIF
	CATCH exc AS Exception
		MessageBox.Show(exc:ToString())
	END
RETURN*/ 
	
EXPORT METHOD deleteBlobFromDB(cItem_Uid AS STRING, cPackage_Uid AS STRING) AS VOID
	LOCAL cStatement AS STRING
	TRY
		IF (SELF:oConnBlob == NULL .OR. SELF:oConnBlob:State == ConnectionState.Closed)
			SELF:oConnBlob:Open()	
		ENDIF
		cStatement:="Delete From FMBlobData Where Package_Uid="+cPackage_Uid+;
					" AND Item_Uid="+cItem_Uid
		IF oSoftway:AdoCommand(SELF:oGFHBlob, SELF:oConnBlob, cStatement)
			MessageBox.Show("Files Deleted.")
			SELF:oConnBlob:Close()
		ENDIF
	CATCH exc AS Exception
		MessageBox.Show(exc:ToString())
	END
RETURN

/*EXPORT METHOD deleteBlobFromDB(cItem_Uid AS STRING, cPackage_Uid AS STRING) AS VOID
	LOCAL cStatement AS STRING
	TRY
		cStatement:="Delete From FMBlobData Where Package_Uid="+cPackage_Uid+;
					" AND Item_Uid="+cItem_Uid
		IF oSoftway:AdoCommand(oGFH, oConn, cStatement)
			MessageBox.Show("Files Deleted.")
		ENDIF
	CATCH exc AS Exception
		MessageBox.Show(exc:ToString())
	END
RETURN*/

EXPORT METHOD addFileToDatabase(cFile AS STRING,cItemUid AS STRING, cPackageUIDLocal := "" AS STRING) AS VOID
	IF cPackageUIDLocal == ""
		cPackageUIDLocal := oMainForm:TreeListVesselsReports:FocusedNode:Tag:ToString()
	ENDIF	
		
	LOCAL oFS := FileStream{cFile,FileMode.Open} AS FileStream
	LOCAL numBytesToRead := (INT)oFS:Length AS INT
	LOCAL bytes := BYTE[]{numBytesToRead} AS BYTE[] 
	LOCAL numBytesRead := 0 AS INT
	
    WHILE numBytesToRead > 0 
        // Read may return anything from 0 to numBytesToRead. 
        LOCAL n := oFS:Read(bytes, numBytesRead, numBytesToRead) AS INT
        // Break when the end of the file is reached. 
        IF n == 0
            BREAK
		ENDIF
        numBytesRead += n
        numBytesToRead -= n
	ENDDO
	//WB("Size="+oFS:Length:ToString())
	oFS:Close()
	//WB("Size="+oFS:Length:ToString())
	LOCAL cFileName := System.IO.Path.GetFileName(cFile)+"."+cItemUid   AS STRING
	LOCAL cUpdate:="INSERT INTO FMBlobData (PACKAGE_UID, ITEM_UID, Filename, BlobData) VALUES"+;
					" ("+cPackageUIDLocal+", "+cItemUid+", '"+cFileName+"', @image)" AS STRING
	IF (SELF:oConnBlob == NULL .OR. SELF:oConnBlob:State == ConnectionState.Closed)
		SELF:oConnBlob:Open()	
	ENDIF
	LOCAL oSqlCommand := SELF:oGFHBlob:Command() AS DBCommand
	oSqlCommand:CommandText := cUpdate
	oSqlCommand:Connection := SELF:oConnBlob
	LOCAL oParameter := SELF:oGFHBlob:Parameter() AS DBParameter
	oParameter:ParameterName := "@image"	
	oParameter:Value := (OBJECT)bytes
	oSqlCommand:Parameters:Add(oParameter)
	IF oSqlCommand:ExecuteNonQuery() == 0
		MessageBox.Show("Error.")
	ENDIF
	SELF:oConnBlob:Close()	 
RETURN

/*EXPORT METHOD addFileToDatabase(cFile AS STRING,cItemUid AS STRING, cPackageUIDLocal := "" AS STRING) AS VOID
		
		IF cPackageUIDLocal == ""
			cPackageUIDLocal := oMainForm:TreeListVesselsReports:FocusedNode:Tag:ToString()
		ENDIF	
		
		LOCAL oFS := FileStream{cFile,FileMode.Open} AS FileStream
	    LOCAL numBytesToRead := (INT)oFS:Length AS INT
		LOCAL bytes := BYTE[]{numBytesToRead} AS BYTE[] 
		LOCAL numBytesRead := 0 AS INT
            WHILE numBytesToRead > 0 
                // Read may return anything from 0 to numBytesToRead. 
                LOCAL n := oFS:Read(bytes, numBytesRead, numBytesToRead) AS INT
                // Break when the end of the file is reached. 
                IF n == 0
                    BREAK
				ENDIF
                numBytesRead += n
                numBytesToRead -= n
			ENDDO
			oFS:Close()
			LOCAL cFileName := System.IO.Path.GetFileName(cFile)+"."+cItemUid   as String
		   LOCAL cUpdate:="INSERT INTO FMBlobData (PACKAGE_UID, ITEM_UID, Filename, BlobData) VALUES"+;
							" ("+cPackageUIDLocal+", "+cItemUid+", '"+cFileName+"', @image)" AS STRING
			LOCAL oSqlCommand:= oGFH:Command() AS DBCommand
			oSqlCommand:CommandText:=cUpdate
			oSqlCommand:Connection:=oConn
			LOCAL oParameter:=oGFH:Parameter() AS DBParameter
			oParameter:ParameterName:="@image"	
			oParameter:Value:=(object)bytes
			oSqlCommand:Parameters:Add(oParameter)
			IF oSqlCommand:ExecuteNonQuery() == 0
					MessageBox.Show("Error.")
			ENDIF	 
		
RETURN*/
////////////////////////////////////////////////////////////////////////////////////////////////////
//		CHANGED BY KIRIAKOS in order to support the new database connection
////////////////////////////////////////////////////////////////////////////////////////////////////

METHOD finalizeReport(cChangeTo := "1" AS STRING) AS VOID
	TRY	
	//IF SELF:myReportTabForm:ValidateMandatoryFields()
	//		SELF:myReportTabForm:saveNormalValues()
	//		SELF:myReportTabForm:saveMultilineFields()
	//		SELF:myReportTabForm:ReadOnlyControls(FALSE)
	//		SELF:BBIEditReport:Enabled := TRUE
	//		SELF:BBIFinalize:Enabled := FALSE
	//		SELF:BBISave:Enabled := FALSE
	//		SELF:BBICancel:Enabled := FALSE
			SELF:changeFinalizedBitInDB(cChangeTo)
			IF cChangeTo == "1"
				WBTimed{"The report is now finalized.", "Action Completed", oUser:nInfoBoxTimer}:ShowDialog(SELF)
			ENDIF
	//ENDIF
	CATCH exc AS Exception
		MessageBox.Show(exc:Message:ToString(),"Action Failed.")
	END
RETURN

METHOD changeFinalizedBitInDB(cChangeTo := "1" AS STRING) AS LOGIC
		TRY
			/*IF QuestionBox("Are you sure you want to Finalize the Selected Report ?", ;
							"Finalize Data") <> System.Windows.Forms.DialogResult.Yes
				RETURN FALSE
			ENDIF*/
			LOCAL cPackageUID := SELF:TreeListVesselsReports:FocusedNode:Tag:ToString() AS STRING
			LOCAL cStatement:="Update FMDataPackages set Matched = "+cChangeTo+" Where Package_Uid = "+cPackageUID AS STRING
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
			//SELF:TreeListVesselsReports:DeleteNode(SELF:TreeListVesselsReports:FocusedNode)
			SELF:TreeListVesselsReports:FocusedNode:ImageIndex := 2
			SELF:TreeListVesselsReports:FocusedNode:SelectImageIndex := 2
		CATCH exc AS Exception
			WB(exc:StackTrace)
			RETURN FALSE
		END
RETURN	TRUE
	
	
METHOD print_ItemClickMethod() AS VOID
		SELF:ShowReportForm(TRUE,FALSE,TRUE)
		//myReportTabForm:Form_ExportToPDF()
		
		/*
		FOREACH oTabPage AS System.Windows.Forms.TabPage IN myReportTabForm:tabControl_Report:TabPages
		LOCAL myGraphics := oTabPage:CreateGraphics() AS Graphics
        
		LOCAL s := oTabPage:PreferredSize AS Size
        memoryImage := Bitmap{s:Width, s:Height, myGraphics}
        LOCAL memoryGraphics := Graphics.FromImage(memoryImage) AS Graphics
		LOCAL oLocation := myReportTabForm:PointToScreen(Point.Empty) AS Point
		//MessageBox.Show(oLocation:X:ToString()+"/"+oLocation:Y:ToString()+"/"+s:Width:ToString()+"/"+s:Height:ToString())
		
        memoryGraphics:CopyFromScreen(oLocation:X, oLocation:Y, 0, 0, s)
	
		//printReport:Print()
		reportPrintPreview:Document := printReport
	    reportPrintPreview:ShowDialog()
		next
		*/
RETURN
////////////////////////////////////////////////////////////////////
//			Return if User is Manager
////////////////////////////////////////////////////////////////////
METHOD isDeptManager() AS LOGIC
TRY
	LOCAL cStatement AS STRING
	////////////////////////////////////////////////////////////////////
	//			CHANGED BY KIRIAKOS AT 01/06/16
	////////////////////////////////////////////////////////////////////
	//cStatement := "SELECT HeadUser FROM CrewUsers WHERE User_UID="+oUser:USER_UNIQUEID
	cStatement := "SELECT IsHeadUser FROM FMUsers WHERE USER_UNIQUEID="+oUser:USER_UNIQUEID
	////////////////////////////////////////////////////////////////////
	//			CHANGED BY KIRIAKOS AT 01/06/16
	////////////////////////////////////////////////////////////////////
	LOCAL cHeadUser := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "IsHeadUser") AS STRING
	IF cHeadUser:Equals("True")
		RETURN TRUE
	ENDIF
CATCH exc AS Exception	
	wb(exc:StackTrace)
	RETURN FALSE
END	
RETURN FALSE
////////////////////////////////////////////////////////////////////
//			Return My Manager
////////////////////////////////////////////////////////////////////
METHOD findMyManager(Group_UID AS STRING) AS STRING
	LOCAL cMyManager := "" AS STRING
	TRY
		IF Group_UID:Equals("")
			wb("No Manager exists")
			RETURN ""
		ENDIF		
		LOCAL cStatement AS STRING
		////////////////////////////////////////////////////////////////////
		//			CHANGED BY KIRIAKOS AT 01/06/16
		////////////////////////////////////////////////////////////////////
		//cStatement := "SELECT CrewUsers.User_UID FROM [CrewUsers],CrewUserGroupLinks WHERE Group_UID="+Group_UID+" AND HeadUser=1 AND CrewUsers.User_UID = CrewUserGroupLinks.User_UID"
		//cMyManager := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "User_UID")	
		cStatement := "SELECT FMUsers.USER_UNIQUEID FROM [FMUsers],FMUserGroupLinks WHERE GROUP_UID="+Group_UID+" AND IsHeadUser=1 AND FMUsers.USER_UNIQUEID = FMUserGroupLinks.USER_UID"
		cMyManager := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "USER_UNIQUEID")	
		////////////////////////////////////////////////////////////////////
		//			CHANGED BY KIRIAKOS AT 01/06/16
		////////////////////////////////////////////////////////////////////
	CATCH exc AS Exception	
		wb(exc:StackTrace:ToString()+CRLF+"/"+CRLF+exc:InnerException:ToString())
		RETURN ""
	END
RETURN cMyManager
////////////////////////////////////////////////////////////////////
//			Return General Manager
////////////////////////////////////////////////////////////////////
METHOD findGM() AS STRING
	LOCAL cMyManager := "" AS STRING
	TRY
		LOCAL cStatement AS STRING
		cStatement := "SELECT USER_UNIQUEID FROM [FMUsers] WHERE isGeneralManager=1"
		cMyManager := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "USER_UNIQUEID")	
	CATCH exc AS Exception	
		wb(exc:StackTrace)
		RETURN ""
	END
RETURN cMyManager
////////////////////////////////////////////////////////////////////
//			Return User Group
////////////////////////////////////////////////////////////////////
	
METHOD findMyGroup() AS STRING
	LOCAL cMyGroup := "" AS STRING
	TRY		
		LOCAL cStatement AS STRING
		////////////////////////////////////////////////////////////////////
		//			ADDED BY KIRIAKOS AT 01/06/16
		////////////////////////////////////////////////////////////////////
		//cStatement := "SELECT Group_UID FROM [CrewUserGroupLinks] WHERE User_UID="+oUser:USER_UNIQUEID
		cStatement := "SELECT GROUP_UID FROM [FMUserGroupLinks] WHERE USER_UID="+oUser:USER_UNIQUEID
		////////////////////////////////////////////////////////////////////
		//			ADDED BY KIRIAKOS AT 01/06/16
		////////////////////////////////////////////////////////////////////
		cMyGroup := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Group_UID")
	CATCH exc AS Exception	
		wb(exc:StackTrace)
		RETURN ""
	END
RETURN cMyGroup  
////////////////////////////////////////////////////////////////////
//			Return Report Status
////////////////////////////////////////////////////////////////////
METHOD findMyStatus() AS STRING
	LOCAL MyStatus := "" AS STRING
	TRY		
		LOCAL cPackageUID := SELF:TreeListVesselsReports:FocusedNode:Tag:ToString() AS STRING
		LOCAL cStatement AS STRING
		cStatement := "SELECT Status FROM [FMDataPackages] WHERE PACKAGE_UID="+cPackageUID
		MyStatus := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Status")
	CATCH exc AS Exception	
		wb(exc:StackTrace)
		RETURN "-1"
	END
	IF MyStatus==""
		RETURN "-1"
	ENDIF
RETURN MyStatus  

METHOD findMyStatus(cPackageUID AS STRING) AS STRING
	LOCAL MyStatus := "" AS STRING
	TRY		
		LOCAL cStatement AS STRING
		cStatement := "SELECT Status FROM [FMDataPackages] WHERE PACKAGE_UID="+cPackageUID
		MyStatus := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Status")
	CATCH exc AS Exception	
		wb(exc:StackTrace)
		RETURN "-1"
	END
	IF MyStatus==""
		RETURN "-1"
	ENDIF
RETURN MyStatus  
////////////////////////////////////////////////////////////////////
//			Submit To Manager
////////////////////////////////////////////////////////////////////
EXPORT METHOD submitCaseToManager(cPackageUID := "0" AS STRING) AS VOID
		LOCAL cUpdate AS STRING
		LOCAL lManager := lisManagerGlobal AS LOGIC
	TRY
	LOCAL cStatusLocal, cNextStatus AS STRING
	
	IF cPackageUID == "0"
		cStatusLocal := SELF:findMyStatus()
	ELSE
		cStatusLocal := SELF:findMyStatus(cPackageUID)
	ENDIF
	
	IF cPackageUID == "0"
		cPackageUID := SELF:TreeListVesselsReports:FocusedNode:Tag:ToString() 
	ENDIF
	
	IF cStatusLocal == "0" .AND. !lManager  // Den exei ginei kanena submit kai einia yparxousa forma
		
		IF  cPackageUID==SELF:TreeListVesselsReports:FocusedNode:Tag:ToString()
		IF !SELF:myReportTabForm:ValidateMandatoryFields()
			RETURN
		ENDIF
		IF QuestionBox("Are you sure you want to Submit the Selected Report to the Dep Manager ?", ;
							"Submit Report") <> System.Windows.Forms.DialogResult.Yes
				RETURN 
		ENDIF
		ENDIF
		cNextStatus := "1"

	ELSEIF cStatusLocal == "1" .OR. lManager
		IF lManager .AND. cStatusLocal=="0"
			IF !SELF:myReportTabForm:ValidateMandatoryFields()
				RETURN
			ENDIF
		ENDIF
		IF QuestionBox("Are you sure you want to Submit the Selected Report to the General Manager ? Report Will Also be finalized. No change can occur after this stage.", ;
								"Submit Report") <> System.Windows.Forms.DialogResult.Yes
					RETURN 
		ENDIF
		cNextStatus := "2"
		//IF !(cStatusLocal == "0" .and. lManager)
		SELF:approveCase(FALSE)
		//ENDIF
		SELF:changeFinalizedBitInDB()
	ENDIF
	
	/*IF cStatusLocal =="0"
		LOCAL cUIDLocal := SELF:TreeListVesselsReports:FocusedNode:Tag:ToString() AS STRING
		local cStatement := "Select TOP 1 Username,[Appoval_UID] FROM Users, [ApprovalData] WHERE [Foreing_UID]="+cUIDLocal+" AND [Receiver_UID]=USER_UNIQUEID ORDER BY [Appoval_UID] ASC " as String
		LOCAL cUsernameLocal := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Username"):Trim() AS STRING
		IF cUsernameLocal <> NULL && cUsernameLocal <> "" // Den uparxei approval request ara einai submit to dep manager
				SELF:approveCase()	
		ENDIF
	ENDIF*/
			LOCAL cManager :="" AS STRING
			
			IF lManager //.and. cStatusLocal == "1" 
				cManager := SELF:findGM() 
			ELSE
				LOCAL cMyGroup := SELF:findMyGroup() AS STRING
				cManager := SELF:findMyManager(cMyGroup)
			ENDIF
			IF cManager:Equals("")
				wb("No Manager exists")
				RETURN
			ENDIF
	
 
			LOCAL cDescLocal  AS STRING
			IF cPackageUID == "0"
				cDescLocal := SELF:GetVesselName+"-"+SELF:TreeListVesselsReports:FocusedNode:GetDisplayText(0)
			ELSE
				LOCAL cStatement AS STRING
				cStatement:="SELECT FMDataPackages.DateTimeGMT, FMReportTypes.ReportName,FMDataPackages.REPORT_UID,FMDataPackages.Username "+;
					    " FROM FMDataPackages"+SELF:cNoLockTerm+;
					    " INNER JOIN FMReportTypes ON FMReportTypes.REPORT_UID=FMDataPackages.REPORT_UID "+;
					    " WHERE FMDataPackages.Package_UID="+cPackageUID+;
					    " ORDER BY FMDataPackages.DateTimeGMT DESC"
				LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
				cDescLocal := DateTime.Parse(oDT:Rows[0]:Item["DateTimeGMT"]:ToString()):ToString("dd/MM/yyyy HH:mm")+" "+oDT:Rows[0]:Item["ReportName"]:ToString()
				cDescLocal := oDT:Rows[0]:Item["Username"]:ToString() + "-"+ cDescLocal  
				cDescLocal := SELF:GetVesselName+"-"+cDescLocal
			ENDIF	
			
	
		    cUpdate:="INSERT INTO ApprovalData (Description, Program_UID, Foreing_UID, Creator_UID, Receiver_UID, From_State, To_State) VALUES"+;
							" ('"+cDescLocal+"',2,"+cPackageUID+", "+oUser:USER_UNIQUEID+","+cManager+","+cStatusLocal+","+cNextStatus+")"
			LOCAL oSqlCommand:= oGFH:Command() AS DBCommand
			oSqlCommand:CommandText:=cUpdate
			oSqlCommand:Connection:=oConn
			IF oSqlCommand:ExecuteNonQuery() == 0
					MessageBox.Show("Error.")
			ENDIF
			IF cStatusLocal == "0" .AND. !lManager
				LOCAL cStatement:="Update FMDataPackages set Status = 1 Where Package_Uid = "+cPackageUID AS STRING
				oSoftway:AdoCommand(oGFH, oConn, cStatement)
				wb("Submission Completed.")
			ENDIF
			SELF:TreeListReportsFocusChanged(NULL,TRUE)	 
CATCH exc AS Exception	
		wb(exc:StackTrace+"///"+cUpdate)
END

RETURN

////////////////////////////////////////////////////////////////////
//			Return To User
////////////////////////////////////////////////////////////////////
EXPORT METHOD returnCaseToUser(cPackageUID := "0" AS STRING) AS VOID
		LOCAL cUpdate AS STRING
	TRY
	LOCAL cStatusLocal AS STRING
	IF cPackageUID == "0"
		cStatusLocal := SELF:findMyStatus()
	ELSE
		cStatusLocal := SELF:findMyStatus(cPackageUID)
	ENDIF
	
	IF cPackageUID == "0"
		cPackageUID := SELF:TreeListVesselsReports:FocusedNode:Tag:ToString() 
	ENDIF
	
	IF cStatusLocal == "1" // Den exei ginei kanena submit
		IF !SELF:myReportTabForm:ValidateMandatoryFields()
			RETURN
		ENDIF
		IF QuestionBox("Are you sure you want to return the selected Report to Pending state ?", ;
							"Return Report") <> System.Windows.Forms.DialogResult.Yes
				RETURN 
		ENDIF
		//cNextStatus := "0"
	//ELSE
		
	ENDIF
				cUpdate:=	" UPDATE ApprovalData SET Status = -1, Date_Acted = CURRENT_TIMESTAMP WHERE Foreing_UID = "+cPackageUID+;
						" AND Program_UID=2 AND Receiver_UID="+oUser:USER_UNIQUEID+" AND Status=1"
				LOCAL oSqlCommand:= oGFH:Command() AS DBCommand
				oSqlCommand:CommandText:=cUpdate
				oSqlCommand:Connection:=oConn
				IF oSqlCommand:ExecuteNonQuery() == 0
						MessageBox.Show("Error.")
						RETURN
				ENDIF
				LOCAL cStatement:="Update FMDataPackages set Status = 0 Where Package_Uid = "+cPackageUID AS STRING
				oSoftway:AdoCommand(oGFH, oConn, cStatement)
				wb("Action Completed.")
				SELF:TreeListReportsFocusChanged(NULL,TRUE)	 
CATCH exc AS Exception	
		wb(exc:StackTrace+"///"+cUpdate)
END

RETURN

EXPORT METHOD approveCase(lLoud := TRUE AS LOGIC) AS VOID
TRY
	IF lLoud
		IF QuestionBox("Are you sure you want to Acknowledge the Selected Report ?", ;
							"Acknowledge Report") <> System.Windows.Forms.DialogResult.Yes
				RETURN 
		ENDIF
	ENDIF
	LOCAL cPackageUID := SELF:TreeListVesselsReports:FocusedNode:Tag:ToString() AS STRING
	LOCAL iStatus := int16.Parse(SELF:findMyStatus()) AS INT
	
	IF iStatus == 1 .OR. iStatus == 0
		iStatus := 2
	ELSEIF iStatus == 2
		iStatus := 3
	ENDIF
	
	LOCAL cStatement:="Update FMDataPackages set Status = "+iStatus:ToString()+" Where Package_Uid = "+cPackageUID AS STRING
	oSoftway:AdoCommand(oGFH, oConn, cStatement)
	
	cStatement	:=	" UPDATE ApprovalData SET Status = 2, Date_Acted = CURRENT_TIMESTAMP WHERE Foreing_UID = "+cPackageUID+;
					" AND Program_UID=2 AND Receiver_UID="+oUser:USER_UNIQUEID
	oSoftway:AdoCommand(oGFH, oConn, cStatement)
	SELF:finalizeReport("2")
	IF iStatus == 2
		SELF:TreeListVesselsReports:FocusedNode:StateImageIndex := 3
	ELSEIF iStatus == 3
		SELF:TreeListVesselsReports:FocusedNode:StateImageIndex := 4
	ENDIF
	//IF lLoud
	IF iStatus == 3
		// Get Vessel Name
		cStatement:=" Select Vessels.VesselName From FMDataPackages "+;
					" Inner Join Vessels On Vessels.Vessel_UniqueId = FMDataPackages.Vessel_UniqueId "+;
					" Where Package_Uid="+cPackageUID		
		LOCAL cVesselName := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "VesselName") AS STRING		

		LOCAL cPackageName := SELF:TreeListVesselsReports:FocusedNode:GetValue(0):ToString() AS STRING
		LOCAL cEmailSubject := cVesselName+ "'s report : "+cPackageName + " Acknowledged " AS STRING
		LOCAL cEmailText := CRLF + " This email is to inform you that the report : "+cPackageName + CRLF +;
							" for Vessel : "+cVesselName +;
							" was just acknowledged by user "+oUser:UserName  AS STRING
		//Approve apo General Manager
		cStatement:=" Select Users.UserId, Users.UserName, Users.User_UniqueId, "+;
					" FMUsers.InformUserForGMApprovalEmail "+;
					" From FMUsers "+;
					" Inner Join Users On Users.User_UniqueId = FMUsers.USER_UNIQUEID "+;
					" Where FMUsers.InformUserForGMApproval=1 "
		 LOCAL oDTInformUserForGMApproval :=oSoftway:ResultTable(SELF:oGFH, SELF:oConn, cStatement) AS DataTable
		 IF oDTInformUserForGMApproval:Rows:Count == 0
			wb("Approval Completed.")
			RETURN
		ENDIF
		LOCAL n AS INT
		FOREACH oRow AS DataRow IN oDTInformUserForGMApproval:Rows
			SELF:sendEmail(oRow["InformUserForGMApprovalEmail"]:ToString():Trim(),cEmailText, cEmailSubject)
		NEXT

	ELSE
		wb("Approval Completed.")
	ENDIF
	//ENDIF
CATCH exc AS Exception	
		wb(exc:StackTrace)
END
		 
RETURN

EXPORT METHOD sendEmail(cEmailRecepient AS STRING, cEmailText AS STRING, cEmailSubject AS STRING) AS VOID
	
	IF SELF:oDRSMTPSettings == NULL
		RETURN
	ENDIF	

	LOCAL oEmail AS SocketTools.InternetMail
	oEmail := SocketTools.InternetMail{}
	oEmail:Initialize(SocketToolsLicenseKey)

	TRY
		oEmail:@@TO := cEmailRecepient
		oEmail:@@Date := DateTime.Now:ToString("dd/MM/yyyy HH:mm:ss")
		oEmail:Encoding := "8bit"
		oEmail:From := oDRSMTPSettings:Item["SMTP_Sender"]:toString()
		oEmail:MessageText := cEmailText
		oEmail:Subject := cEmailSubject
		oEmail:ThrowError := TRUE

		LOCAL cServer := "", cPort:="", cUserNameLocal := "", cPassLocal := "" AS STRING
		cServer := oDRSMTPSettings:Item["SMTP_Server"]:toString()
		cPort := oDRSMTPSettings:Item["SMTP_Port"]:toString()
		cUserNameLocal := oDRSMTPSettings:Item["SMTP_UserName"]:toString()
		cPassLocal := oDRSMTPSettings:Item["SMTP_Pass"]:toString()

		IF cServer <> "" && cPort <> "" && cUserNameLocal <> "" && cPassLocal <> "" 
			oEmail:SendMessage(cServer,Convert.ToInt32(cPort),cUserNameLocal,cPassLocal)
		ENDIF
		//oEmail:SendMessage()
	CATCH exc AS Exception
		MessageBox.Show(oEmail:LastError:ToString(), exc:Message)
	END TRY

RETURN


EXPORT METHOD markApprovalAsSeen() AS VOID
TRY
	LOCAL cPackageUID := SELF:TreeListVesselsReports:FocusedNode:Tag:ToString() AS STRING
	LOCAL cStatement	:=	" UPDATE ApprovalData SET Status = 1, Date_Acted = CURRENT_TIMESTAMP WHERE Foreing_UID = "+cPackageUID+;
					" AND Program_UID=2 AND Receiver_UID="+oUser:USER_UNIQUEID+" AND Status=0" AS STRING
	oSoftway:AdoCommand(oGFH, oConn, cStatement)
CATCH exc AS Exception	
		wb(exc:StackTrace)
END
		 
RETURN

////////////////////////////////////////////////////////////////////////////////////////
////////
////////		In Order To Locate Report
////////
////////////////////////////////////////////////////////////////////////////////////////
	EXPORT METHOD locateReport(cReport_UID AS STRING) AS LOGIC
		TRY
			LOCAL cStatement,cMyVessel,cReportTypeUID,cReportType,cReportName AS STRING
			cStatement := "SELECT Vessel_UNIQUEID FROM [FMDataPackages] WHERE PACKAGE_UID="+cReport_UID
			cMyVessel := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Vessel_UNIQUEID")
			
			cStatement := "SELECT [REPORT_UID] FROM [FMDataPackages] WHERE PACKAGE_UID="+cReport_UID
			cReportTypeUID := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "REPORT_UID")
			
			cStatement := "SELECT [ReportType],[ReportName] FROM [FMReportTypes] WHERE [REPORT_UID]="+cReportTypeUID
			cReportType := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "ReportType")
			cReportName := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "ReportName")
			
			IF cReportType == "V"
				SELF:ReportsTabUserControl:SelectedIndex := 0
			ELSE
				SELF:ReportsTabUserControl:SelectedIndex := 1
			ENDIF
			//WB("here")
			SELF:getNodeForVessel(cMyVessel)
			
			LOCAL nIndex := SELF:LBCReports:FindStringExact(cReportName, 0) AS INT
			IF nIndex <> -1
				//SELF:cLastVesselName := SELF:cLastMainSelection:Substring(nPos + 1)
				SELF:LBCReports:SelectedIndex := nIndex
				//SELF:SelectedVesselChanged()
			ENDIF
			
			SELF:getNodeForReport("",cReport_UID)
		CATCH exc AS Exception
			RETURN FALSE
		END
		
	RETURN TRUE

METHOD ShowApprovalsForFocusedReport() AS VOID
	LOCAL oApproval_Form := Approval_Form{} AS Approval_Form
	oApproval_Form:cMyUser := oUser:User_Uniqueid
	oApproval_Form:cMyReport :=  SELF:TreeListVesselsReports:FocusedNode:Tag:ToString() 
	oApproval_Form:oGFH := SELF:oGFH
	oApproval_Form:oConn := SELF:oConn
	oApproval_Form:Show()
	oApproval_Form:getApprovalsForProgram(2)
	oApproval_Form:CreateGridApprovals_Columns()
	oApproval_Form:gridViewRefresh()
	oMyApproval_Form := oApproval_Form
RETURN


METHOD showMyHistoryForm() AS VOID
	LOCAL oApprovalHistoryForm := ApprovalHistoryForm{} AS ApprovalHistoryForm
	oApprovalHistoryForm:cMyUser := oUser:User_Uniqueid
	oApprovalHistoryForm:cMyReport :=  SELF:TreeListVesselsReports:FocusedNode:Tag:ToString() 
	oApprovalHistoryForm:Show()
	oApprovalHistoryForm:getHistory()
RETURN

METHOD checkForPendingApprovals() AS LOGIC

		LOCAL cMyUser := oUser:User_Uniqueid AS STRING
		LOCAL iProgramUID := 2 AS INT
		LOCAL cExtraSQL := "" AS STRING
		IF iProgramUID <> 0
			cExtraSQL := " AND [Program_UID]="+iProgramUID:ToString()+" AND  ApprovalData.Status=0 "
		ENDIF
			
		LOCAL cStatement:="SELECT [Appoval_UID]"+;
				" FROM [ApprovalData]"+;
				" WHERE (Receiver_UID="+cMyUser+") "+ cExtraSQL+;
				" ORDER BY Appoval_UID DESC " AS STRING
		 LOCAL oDTApprovalsLocal :=oSoftway:ResultTable(SELF:oGFH, SELF:oConn, cStatement) AS DataTable
		 IF oDTApprovalsLocal:Rows:Count > 0
			 RETURN TRUE
		 ENDIF
RETURN FALSE

METHOD refreshMyApprovalsForm() AS VOID
	IF SELF:oMyApproval_Form == NULL
			RETURN
	ELSE
		SELF:oMyApproval_Form:getApprovalsForProgram(2)
		SELF:oMyApproval_Form:gridViewRefresh()
	ENDIF
			
RETURN


END CLASS
   