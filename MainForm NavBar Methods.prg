// NavBar_Methods.prg
#Using System.Windows.Forms
#Using System.Data
#Using System.Drawing
#Using System.Diagnostics
#Using System.Threading


PARTIAL CLASS MainForm INHERIT DevExpress.XtraEditors.XtraForm

PRIVATE METHOD NavBarPrograms_ActiveGroupChanged( sender AS System.Object, e AS DevExpress.XtraNavBar.NavBarGroupEventArgs ) AS System.Void

DO CASE
CASE e:Group:Name == "Communicator"
	IF ! lInstalledCommunicator
		InfoBox("This module is not included in the active program licenses", e:Group:Name)
		SELF:oNavBarForm:NavBarPrograms:ActiveGroup := SELF:oNavBarForm:NavBarPrograms:Groups["FleetManager"]
		// or: SELF:oNavBarForm:NavBarPrograms:ActiveGroup:=SELF:oNavBarForm:NavBarPrograms:Groups[Application.ProductName]
		RETURN
	ENDIF
	oSoftway:RunNavBarApplication(SELF, SELF:oNavBarForm:NavBarPrograms, e:Group:Name, e:Group:Caption, Application.ProductName)

CASE e:Group:Name == "CrewFile"
	IF ! lInstalledCrew
		InfoBox("This module is not included in the active program licenses", e:Group:Name)
		SELF:oNavBarForm:NavBarPrograms:ActiveGroup := SELF:oNavBarForm:NavBarPrograms:Groups["FleetManager"]
		// or: SELF:oNavBarForm:NavBarPrograms:ActiveGroup:=SELF:oNavBarForm:NavBarPrograms:Groups[Application.ProductName]
		RETURN
	ENDIF
	oSoftway:RunNavBarApplication(SELF, SELF:oNavBarForm:NavBarPrograms, e:Group:Name, e:Group:Caption, Application.ProductName)


CASE e:Group:Name == "Scheduler"
	IF ! lInstalledScheduler
		InfoBox("This module is not included in the active program licenses", e:Group:Name)
		SELF:oNavBarForm:NavBarPrograms:ActiveGroup := SELF:oNavBarForm:NavBarPrograms:Groups["FleetManager"]
		// or: SELF:oNavBarForm:NavBarPrograms:ActiveGroup:=SELF:oNavBarForm:NavBarPrograms:Groups[Application.ProductName]
		RETURN
	ENDIF
	oSoftway:RunNavBarApplication(SELF, SELF:oNavBarForm:NavBarPrograms, "Communicator", "Communicator", Application.ProductName)

CASE e:Group:Name == "DMF"
	IF ! lInstalledDMF
		InfoBox("This module is not included in the active program licenses", e:Group:Name)
		SELF:oNavBarForm:NavBarPrograms:ActiveGroup := SELF:oNavBarForm:NavBarPrograms:Groups["FleetManager"]
		// or: SELF:oNavBarForm:NavBarPrograms:ActiveGroup:=SELF:oNavBarForm:NavBarPrograms:Groups[Application.ProductName]
		RETURN
	ENDIF
	oSoftway:RunNavBarApplication(SELF, SELF:oNavBarForm:NavBarPrograms, "Communicator", "Communicator", Application.ProductName)

CASE e:Group:Name == "ShippingAccounting"
	IF ! lInstalledShippingAccounting
		InfoBox("This module is not included in the active program licenses", e:Group:Name)
		SELF:oNavBarForm:NavBarPrograms:ActiveGroup := SELF:oNavBarForm:NavBarPrograms:Groups["FleetManager"]
		// or: SELF:oNavBarForm:NavBarPrograms:ActiveGroup:=SELF:oNavBarForm:NavBarPrograms:Groups[Application.ProductName]
		RETURN
	ENDIF
	oSoftway:RunNavBarApplication(SELF, SELF:oNavBarForm:NavBarPrograms, e:Group:Name, e:Group:Caption, Application.ProductName)

ENDCASE

RETURN


PRIVATE METHOD Fleet_LinkClicked( sender AS System.Object, e AS DevExpress.XtraNavBar.NavBarLinkEventArgs ) AS System.Void
	//wb(e:Link:ItemName)
	SELF:oNavBarForm:Fleet:Enabled := FALSE
	Application.DoEvents()

	LOCAL oRowLocal := SELF:returnUserSetting(oUser:USER_UNIQUEID) AS DataRow
	IF !( oRowLocal == NULL .OR. oRowLocal["CanEditReports"]:ToString() == "False")
		LOCAL oFleetForm := FleetForm{} AS FleetForm
		oFleetForm:Show(SELF)
	ENDIF


	SELF:oNavBarForm:Fleet:Enabled := TRUE
RETURN


PRIVATE METHOD FMVessels_LinkClicked( sender AS System.Object, e AS DevExpress.XtraNavBar.NavBarLinkEventArgs ) AS System.Void
	//wb(e:Link:ItemName)
	SELF:oNavBarForm:FMVessels:Enabled := FALSE
	Application.DoEvents()

	LOCAL oRowLocal := SELF:returnUserSetting(oUser:USER_UNIQUEID) AS DataRow
	IF !( oRowLocal == NULL .OR. oRowLocal["CanEditReports"]:ToString() == "False")
		LOCAL oVesselsForm := VesselsForm{} AS VesselsForm
		oVesselsForm:Show(SELF)
	ENDIF


	SELF:oNavBarForm:FMVessels:Enabled := TRUE
RETURN


PRIVATE METHOD FMVoyages_LinkClicked( sender AS System.Object, e AS DevExpress.XtraNavBar.NavBarLinkEventArgs ) AS System.Void
	//wb(e:Link:ItemName)
	SELF:oNavBarForm:FMVoyages:Enabled := FALSE
	Application.DoEvents()

	LOCAL oVoyagesForm := VoyagesForm{} AS VoyagesForm
	oVoyagesForm:Show(SELF)

	SELF:oNavBarForm:FMVoyages:Enabled := TRUE
RETURN


PRIVATE METHOD FMReports_LinkClicked( sender AS System.Object, e AS DevExpress.XtraNavBar.NavBarLinkEventArgs ) AS System.Void
	//wb(e:Link:ItemName)

	SELF:oNavBarForm:FMReports:Enabled := FALSE
	Application.DoEvents()

	LOCAL oRowLocal := SELF:returnUserSetting(oUser:USER_UNIQUEID) AS DataRow
	IF !( oRowLocal == NULL .OR. oRowLocal["CanEditReports"]:ToString() == "False")
		LOCAL oReportsForm := ReportsForm{} AS ReportsForm
		oReportsForm:Show(SELF)
	ENDIF

	SELF:oNavBarForm:FMReports:Enabled := TRUE
RETURN


PRIVATE METHOD FMItems_LinkClicked( sender AS System.Object, e AS DevExpress.XtraNavBar.NavBarLinkEventArgs ) AS System.Void
	//wb(e:Link:ItemName)
	SELF:oNavBarForm:FMItems:Enabled := FALSE
	Application.DoEvents()
	
	LOCAL oRowLocal := SELF:returnUserSetting(oUser:USER_UNIQUEID) AS DataRow
	IF !( oRowLocal == NULL .OR. oRowLocal["CanEditReports"]:ToString() == "False")
		LOCAL oItemsForm := ItemsForm{} AS ItemsForm
		oItemsForm:Show(SELF)
	ENDIF


	SELF:oNavBarForm:FMItems:Enabled := TRUE
RETURN


PRIVATE METHOD FMTools_LinkClicked( sender AS System.Object, e AS DevExpress.XtraNavBar.NavBarLinkEventArgs ) AS System.Void
	//wb(e:Link:ItemName)
	SELF:oNavBarForm:FMTools:Enabled := FALSE
	Application.DoEvents()

	LOCAL oToolsForm := ToolsForm{} AS ToolsForm
	oToolsForm:ShowDialog()

	SELF:oNavBarForm:FMTools:Enabled := TRUE
RETURN

PRIVATE METHOD FMCargoes_LinkClicked( sender AS System.Object, e AS DevExpress.XtraNavBar.NavBarLinkEventArgs ) AS System.Void
	//wb(e:Link:ItemName)
	SELF:oNavBarForm:FMCargoes:Enabled := FALSE
	Application.DoEvents()

	LOCAL oCargoesForm := Cargoes_Form{} AS Cargoes_Form
	oCargoesForm:ShowDialog()

	SELF:oNavBarForm:FMCargoes:Enabled := TRUE
RETURN

PRIVATE METHOD FMCurrenciesAndRates_LinkClicked( sender AS System.Object, e AS DevExpress.XtraNavBar.NavBarLinkEventArgs ) AS System.Void
	//wb(e:Link:ItemName)
	SELF:oNavBarForm:FMCurrenciesAndRates:Enabled := FALSE
	Application.DoEvents()

	LOCAL oToolsForm := ToolsForm{} AS ToolsForm
	oToolsForm:ShowDialog()

	SELF:oNavBarForm:FMCurrenciesAndRates:Enabled := TRUE
RETURN

PRIVATE METHOD FMPorts_LinkClicked( sender AS System.Object, e AS DevExpress.XtraNavBar.NavBarLinkEventArgs ) AS System.Void
	//wb(e:Link:ItemName)
	SELF:oNavBarForm:Enabled := FALSE
	Application.DoEvents()

	LOCAL oToolsForm := ToolsForm{} AS ToolsForm
	oToolsForm:ShowDialog()

	SELF:oNavBarForm:FMPorts:Enabled := TRUE
RETURN


PRIVATE METHOD CheckForUpdates_LinkClicked( sender AS System.Object, e AS DevExpress.XtraNavBar.NavBarLinkEventArgs ) AS System.Void
	IF QuestionBox("This procedure will check for program updates"+CRLF+CRLF+;
					"If updates are available, the program will exit and re-run by it-self"+CRLF+CRLF+;
					"Please wait until all updates are downloaded and the program runs again (this may take a few minutes)"+CRLF+CRLF+;
					"Do you want to continue ?", "AutoUpdate") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	SELF:Cursor := Cursors.WaitCursor

	SELF:oNavBarForm:CheckForUpdates:Enabled := FALSE
	Application.DoEvents()

	LOCAL cCommandLine :="" AS STRING
	LOCAL MyAutoUpdate := AutoUpdate{} AS AutoUpdate
	//cLicensedCompany := "SOFTWAY LTD"
	MyAutoUpdate:cLicensedCompany := cLicensedCompany:ToUpper()
	MyAutoUpdate:cLocalAutoUpdatePath := oSoftway:GetLocalAutoUpdatePath(symServer, SELF:oGFH, SELF:oConn, TRUE)

	IF MyAutoUpdate:Needed(cCommandLine)
		lAutoUpdateInProgress := TRUE
		System.Windows.Forms.Application.Exit()
		RETURN
	ENDIF

	SELF:oNavBarForm:CheckForUpdates:Enabled := TRUE
	SELF:Cursor := Cursors.Default
RETURN


PRIVATE METHOD HelpAbout_LinkClicked( sender AS System.Object, e AS DevExpress.XtraNavBar.NavBarLinkEventArgs ) AS System.Void
	SELF:oNavBarForm:HelpAbout:Enabled := FALSE
	Application.DoEvents()

	LOCAL oAboutDialog:=AboutDialog{} AS AboutDialog
	LOCAL cLicText AS STRING

	cLicText:="Licensed to: "+cLicensedCompany
	IF nDemoDays > 0
		//cLicText+=CRLF+"Demo version: "+(nDemoDays - nDemoDayCurrent):ToString()+" days left"
		cLicText+=CRLF+"You are on day: "+nDemoDayCurrent:ToString()+;
						" of your: "+nDemoDays:ToString()+" day evaluation period"
	ENDIF                                                          
	oAboutDialog:LicenseTxt:Text:=cLicText
	SELF:oNavBarForm:HelpAbout:Enabled := TRUE
	oAboutDialog:ShowDialog(SELF)  

	//Self:oNavBarForm:HelpAbout:Enabled := False
	//Application.DoEvents()
	////WB("Folders: "+oMainForm:oMainUserControl:TVFolders:GetNodeCount(true):ToString("N0"))
	//Local oAboutDialog:=AboutDialog{} as AboutDialog
	//Local cLicText as string

	////if lCyprus
	////	cLicensedCompany := "Cyprus Maritime"
	////endif
	//IF nDemoDays > 0
	//	//cLicText+=CRLF+"Demo version: "+(nDemoDays - nDemoDayCurrent):ToString()+" days left"
	//	cLicText:="Licensed to: "+cLicensedCompany
	//	cLicText+=CRLF+"You are on day: "+nDemoDayCurrent:ToString()+;
	//					" of your: "+nDemoDays:ToString()+" day evaluation period"
	//ELSE
	//	cLicText:="Licensed to:"+CRLF+cLicensedCompany
	//ENDIF                                                          
	//oAboutDialog:LicenseTxt:Text := cLicText

	//oAboutDialog:LabelUser:Text := "User: "+oUser:UserID + " - " + oUser:Username

	//Local cLicenses as string
	//cLicenses += " "+PadR("Internet eMail:", 20)+Str(nLiN, 3)+CRLF
	//cLicenses += " "+PadR("Fax:", 20)+Str(nLiF, 3)+CRLF
	//cLicenses += " "+PadR("Telex:", 20)+Str(nLiT, 3)+CRLF
	//cLicenses += " "+PadR("Satellite:", 20)+Str(nLiS, 3)+CRLF
	//cLicenses += " "+PadR("Mobile (SMS):", 20)+Str(nLiM, 3)+CRLF
	//cLicenses += " "+PadR("Easylink (Comtext):", 20)+Str(nLiC, 3)
	//oAboutDialog:Licenses:Text := cLicenses

	//// exec sp_spaceused
	//// exec sp_spaceused 'softway.dbo.msg32'
	//DO CASE
	//CASE symServer == #SqlCe
	//	oAboutDialog:GBDatabaseInfo:Text := "Database: "+cSQLDataSource

	//CASE symServer == #MSSQL
	//	oAboutDialog:GBDatabaseInfo:Text := "Database: "+cSQLDataSource+"."+cSQLInitialCatalog
	//	TRY
	//		LOCAL cStatement AS STRING
	//		cStatement:="exec sp_spaceused"
	//		LOCAL oDT AS DataTable
	//		oDT := oSoftway:ResultTable(oMainForm:oMainUserControl:oGFH, oMainForm:oMainUserControl:oHistConn, cStatement)
	//		IF oDT:Rows:Count == 1
	//			oAboutDialog:DatabaseSize:Text := "Database size: "+oDT:Rows[0]:Item["database_size"]:ToString()
	//			oAboutDialog:UnallocatedSpace:Text := "Unallocated space: "+oDT:Rows[0]:Item["Unallocated Space"]:ToString()
	//		ENDIF
	//	END TRY

	//OTHERWISE
	//	oAboutDialog:GBDatabaseInfo:Text := "Database: "+cSQLDataSource+"."+cSQLInitialCatalog
	//ENDCASE

	//Self:oNavBarForm:HelpAbout:Enabled := True
	//oAboutDialog:ShowDialog(Self)  
RETURN

METHOD barButtonItemMRVReportItemClick() AS VOID
	LOCAL oMRVResultForm := MRVResultForm{} AS MRVResultForm
	//oMRVResultForm:oDTMyResults := oDTResults
	LOCAL cVesselUID := SELF:TreeListVessels:FocusedNode:Tag:ToString() AS STRING
	oMRVResultForm:cMyVesselUID := SELF:TreeListVessels:FocusedNode:Tag:ToString() 
	oMRVResultForm:cMyVesselName := SELF:TreeListVessels:FocusedNode:GetValue(0):ToString()
	oMRVResultForm:Show()
RETURN


END CLASS
