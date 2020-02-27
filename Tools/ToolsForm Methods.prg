// ToolsForm_Methods.prg
#Using System.IO
#Using System.Data
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Collections
USING System.Collections.Generic

//ENUM ItemTypes
//	RPM := 1
//	Speed := 2
//	Slip := 3
//END ENUM

PARTIAL CLASS ToolsForm INHERIT DevExpress.XtraEditors.XtraForm
	PRIVATE cBodyISM AS STRING

	PRIVATE cReportUID AS STRING
	PRIVATE cReportName AS STRING
	PRIVATE cVesselUID AS STRING
	PRIVATE cVesselName AS STRING

METHOD ToolsForm_OnLoad() AS VOID
	IF oMainForm:TreeListVessels:FocusedNode == NULL .OR. oMainForm:LBCReports:SelectedValue == NULL
		SELF:ButtonExportTables:Enabled := FALSE
	ENDIF

	IF oMainForm:GetVesselUID == "0"
		wb("No Vessel selected")
		RETURN
	ENDIF

	LOCAL oToolTip := ToolTip{} AS ToolTip
	// Set up the delays for the ToolTip.
	oToolTip:AutoPopDelay:=5000
	oToolTip:InitialDelay:=1000
	oToolTip:ReshowDelay:=500
	// Force the ToolTip text to be displayed whether or not the form is active.
	oToolTip:ShowAlways:=TRUE
	// Set up the ToolTip text for the Button and Checkbox.
	oToolTip:SetToolTip(SELF:TBLogDir, "If specified the program will allow multiple Users to Edit a Report (one at a time)"+CRLF+;
										"By default, this folder is created under the program's path")

	SELF:cReportUID := oMainForm:LBCReports:SelectedValue:ToString()
	SELF:cReportName := oMainForm:LBCReports:GetDisplayItemValue(oMainForm:LBCReports:SelectedIndex):ToString()
	SELF:cVesselUID := oMainForm:GetVesselUID
	SELF:cVesselName := oMainForm:GetVesselName

	SELF:labelEMail:Text += " "+SELF:cVesselName

	SELF:TBSubject:Text := cVesselName + " " + cReportName
	SELF:TBBody:Text := "VesselID: "+SELF:cVesselUID+", Vessel: "+SELF:cVesselName+CRLF+;
						"Data set created on: "+DateTime.Now:ToString("yyyy-MM-dd HH:mm")+" (GMT)"

	LOCAL cEMail := "" AS STRING
	SELF:cBodyISM := oMainForm:ReadBodyISM(SELF:cReportUID, cEMail)
	SELF:TBeMail:Text := cEMail
	
	LOCAL oRowLocal := oMainForm:returnUserSetting(oUser:USER_UNIQUEID) AS DataRow
	//WB(oRowLocal["CanEnterToolsArea"]:ToString())
	IF oRowLocal == NULL .OR. oRowLocal["CanEnterToolsArea"]:ToString() == "False"
		SELF:ButtonBodyIsm:Enabled := FALSE
		SELF:ButtonExportTables:Enabled := FALSE 
	ENDIF
	
RETURN


METHOD RBCheckedChanged() AS VOID
	SELF:TBSkyfileFolder:Enabled := SELF:RBSkyfile:Checked

	IF SELF:RBSkyfile:Checked
		SELF:TBSkyfileFolder:Focus()
	ELSE
		SELF:TBeMail:Focus()
	ENDIF
RETURN


METHOD ExportTablesToVessel() AS VOID
	IF oMainForm:GetVesselUID == "0" .OR. oMainForm:LBCReports:SelectedValue == NULL
		RETURN
	ENDIF

	LOCAL cEMail := SELF:TBeMail:Text:Trim() AS STRING
	IF cEMail == "" .OR. ! cEMail:Contains("@") .OR. ! cEMail:Contains(".")
		wb("No eMail specified", "Invalid eMail")
		SELF:TBeMail:Focus()
		RETURN
	ENDIF

	LOCAL cStatement AS STRING
	//LOCAL cReportUID := oMainForm:LBCReports:SelectedValue:ToString() AS STRING

	// Update FMBodyText.eMail
	cStatement:="UPDATE FMBodyText SET eMail='"+oSoftway:ConvertWildcards(cEMail, FALSE)+"'"+;
				" WHERE REPORT_UID="+SELF:cReportUID
	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)

	//LOCAL cSubject := SELF:TBSubject:Text:Trim() AS STRING
	LOCAL cBody := SELF:TBBody:Text:Trim() AS STRING
	LOCAL nPos := cBody:IndexOf(" on: ") AS INT
	cBody := cBody:Substring(0, nPos + 5)

	LOCAL cMailClient AS STRING
	LOCAL cSkyfileFolder, cXmlFileMask AS STRING

	IF SELF:RBOutlook:Checked
		cMailClient := "Outlook"

		cSkyfileFolder := ""
	ELSE
		cMailClient := "Skyfile"

		cSkyfileFolder := SELF:TBSkyfileFolder:Text:Trim()
		IF cSkyfileFolder == ""
			wb("No SkyfileFolder specified", "Invalid SkyfileFolder")
			SELF:TBSkyfileFolder:Focus()
			RETURN
		ENDIF
	ENDIF
	cXmlFileMask := SELF:TBXmlFileMask:Text:Trim()

	LOCAL cXMLFile AS STRING

	// Check FMReportTypes
	cStatement:="SELECT ReportBaseNum"+;
				" FROM FMReportTypes"+oMainForm:cNoLockTerm+;
				" WHERE ReportName <> 'Mode (Last Report)'"+;
				" AND ReportBaseNum <= 0 OR "+oSoftway:SelectBlobLength+"(ReportName) <= 1"
	LOCAL oDT1 := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	IF oDT1:Rows:Count > 0
		wb("Reports without ReportBaseNum/ReportName are not permitted", "Empty Report")
		SELF:Close()
		RETURN
	ENDIF

	// Check FMReportItems
	cStatement:="SELECT ItemNo"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" WHERE ItemNo <= 0 OR "+oSoftway:SelectBlobLength+"(ItemName) <= 0"
	LOCAL oDT2 := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	IF oDT2:Rows:Count > 0
		wb("Items without ItemNo/ItemName are not permitted"+CRLF+CRLF+"ItemNo="+oDT2:Rows[0]:Item["ItemNo"]:ToString(), "Empty Item")
		SELF:Close()
		RETURN
	ENDIF

	IF QuestionBox("Vessel: "+SELF:cVesselName+CRLF+CRLF+;
					"Do you want to create a XML DataSet to update the Vessel's Database ?", ;
					"Export Data to Vessel") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	//LOCAL aFiles := {} AS ARRAY
	var aFiles := List<STRING>{}

	// BodyISMForm-ReportUID
	LOCAL cBodyTextTerm := "" AS STRING
	cStatement:="SELECT REPORT_UID, BodyText FROM FMBodyText"+oMainForm:cNoLockTerm
	LOCAL oDTBodyText := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	FOREACH oRow AS DataRow IN oDTBodyText:Rows
		cBodyTextTerm += " '"+oSoftway:ConvertWildCards(oRow["BodyText"]:ToString(), FALSE)+"' AS BodyISM"+oRow["REPORT_UID"]:ToString()+","
	NEXT

	LOCAL cLogDir := SELF:TBLogDir:Text:Trim() AS STRING

	cStatement:="SELECT SupVessels.VESSEL_UNIQUEID, Vessels.VesselName, SupVessels.PropellerPitch,"+;
				" '"+cMailClient+"' AS MailClient, '"+cEMail+"' AS eMail, '"+cBody+"' AS Body,"+;
				cBodyTextTerm+" 'Xml Exported on "+DateTime.Now:ToString("dd-MMM-yyyy HH:mm")+"' AS XmlVersion, "+;
				" '"+cSkyfileFolder+"' AS SkyfileFolder, '"+cXmlFileMask+"' AS XmlFileMask, '"+cLogDir+"' AS LogDir"+;
				" FROM SupVessels"+oMainForm:cNoLockTerm+;
				" INNER JOIN Vessels ON SupVessels.VESSEL_UNIQUEID=Vessels.VESSEL_UNIQUEID"+;
				" AND SupVessels.VESSEL_UNIQUEID="+oMainForm:GetVesselUID
				// , '"+cSubject+"' AS Subject
				//" '"+oSoftway:ConvertWildCards(SELF:cBodyISM, FALSE)+"' AS BodyISM,"+;
	//memowrit(ctempdocdir+"\vessels.txt", cStatement)
	LOCAL oDTVessels := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oSoftway:CreatePK(oDTVessels, "VESSEL_UNIQUEID")
	oDTVessels:TableName := "FMVessels"
	cXMLFile := Application.StartupPath + "\FMVessels.XML"
//	AADD(aFiles, cXMLFile)
	aFiles:Add(cXMLFile)
	oDTVessels:WriteXml(cXMLFile, XmlWriteMode.WriteSchema, FALSE)

	cStatement:="SELECT CATEGORY_UID, Description, SortOrder"+;
				" FROM FMItemCategories  Where CATEGORY_UID<>0"+;
				" ORDER BY SortOrder "
//				" UNION SELECT 0 AS CATEGORY_UID, '' AS Description"+;
	LOCAL oDTItemCategories := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oSoftway:CreatePK(oDTItemCategories, "CATEGORY_UID")
	oDTItemCategories:TableName := "FMItemCategories"
	cXMLFile := Application.StartupPath + "\FMItemCategories.XML"
//	AADD(aFiles, cXMLFile)
	aFiles:Add(cXMLFile)
	oDTItemCategories:WriteXml(cXMLFile, XmlWriteMode.WriteSchema, FALSE)

	cStatement:="SELECT FMReportTypes.*"+;
				" FROM FMReportTypes"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMReportTypesVessel ON FMReportTypes.REPORT_UID=FMReportTypesVessel.REPORT_UID"+;
				"	AND FMReportTypesVessel.VESSEL_UNIQUEID="+oMainForm:GetVesselUID+;
				" WHERE ReportName <> 'Mode (Last Report)' AND ReportType = 'V' "+;
				" ORDER BY ReportBaseNum"
	LOCAL oDTReportTypes := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oSoftway:CreatePK(oDTReportTypes, "REPORT_UID")
	oDTReportTypes:TableName := "FMReportTypes"
	cXMLFile := Application.StartupPath + "\FMReportTypes.XML"
//	AADD(aFiles, cXMLFile)
	aFiles:Add(cXMLFile)
	oDTReportTypes:WriteXml(cXMLFile, XmlWriteMode.WriteSchema, FALSE)

	cStatement:="SELECT FMReportItems.*"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" LEFT OUTER JOIN FMItemCategories ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
				" INNER JOIN FMReportTypes ON FMReportItems.REPORT_UID=FMReportTypes.REPORT_UID"+;
				"	AND FMReportTypes.ReportType = 'V' "+;
				" INNER JOIN FMReportTypesVessel ON FMReportItems.REPORT_UID=FMReportTypesVessel.REPORT_UID"+;
				"	AND FMReportTypesVessel.VESSEL_UNIQUEID="+oMainForm:GetVesselUID+;
				" ORDER BY FMItemCategories.SortOrder, ItemNo"
	LOCAL oDTReportItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oSoftway:CreatePK(oDTReportItems, "ITEM_UID")
	oDTReportItems:TableName := "FMReportItems"
	cXMLFile := Application.StartupPath + "\FMReportItems.XML"
//	AADD(aFiles, cXMLFile)
	aFiles:Add(cXMLFile)
	oDTReportItems:WriteXml(cXMLFile, XmlWriteMode.WriteSchema, FALSE)

	// Check if SupVessels.PropellerPitch is defined
	IF ! SELF:CheckPropellerPitch(oDTReportItems, oDTVessels)
		ErrorBox("You have to specify the PropellerPitch for the Vessel: "+SELF:cVesselName, "Export aborted")
		RETURN
	ENDIF
	
	LOCAL oSaveDialog := SaveFileDialog{} AS SaveFileDialog
	VAR cFileName := "FMDataSet_"+oSoftway:FileNameValidate(SELF:cVesselName)+"_"+TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC):ToString("yyyy-MM-dd_HH-mm-ss")+".ZIP"
	LOCAL cZipFile AS STRING
	oSaveDialog:InitialDirectory := cFleetManagerVesselPath
	oSaveDialog:FileName :=  cFileName
	oSaveDialog:Filter := "Zip Files|*.zip"
	
	IF oSaveDialog:ShowDialog() == DialogResult:OK
		cZipFile := oSaveDialog:FileName
		IF ! oSoftway:ZipFiles(aFiles, cZipFile)
			RETURN
		ENDIF
		InfoBox("DataSet exported to:"+CRLF+cZipFile)
	ENDIF
	

//	LOCAL cZipFile := cFleetManagerVesselPath + cFileName AS STRING
//	IF ! oSoftway:ZipFiles(aFiles, cZipFile)
//		RETURN
//	ENDIF

	/*// Delete the Local XML files
	LOCAL n, nLen := ALen(aFiles) AS DWORD
	FOR n:=1 UPTO nLen
		System.IO.File.Delete(aFiles[n])
		Application.DoEvents()
	NEXT*/
	//InfoBox("DataSet exported to:"+CRLF+cZipFile)

	//SELF:Close()
RETURN


METHOD ExportOfficeTables() AS VOID
	IF oMainForm:GetVesselUID == "0" .OR. oMainForm:LBCReports:SelectedValue == NULL
		MessageBox.Show("Pls select a vessel.")
		RETURN
	ENDIF

	LOCAL cEMail := SELF:TBeMail:Text:Trim() AS STRING
	IF cEMail == "" .OR. ! cEMail:Contains("@") .OR. ! cEMail:Contains(".")
		wb("No eMail specified", "Invalid eMail")
		SELF:TBeMail:Focus()
		RETURN
	ENDIF

	LOCAL cStatement AS STRING
	//LOCAL cReportUID := oMainForm:LBCReports:SelectedValue:ToString() AS STRING

	// Update FMBodyText.eMail
	cStatement:="UPDATE FMBodyText SET eMail='"+oSoftway:ConvertWildcards(cEMail, FALSE)+"'"+;
				" WHERE REPORT_UID="+SELF:cReportUID
	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)

	//LOCAL cSubject := SELF:TBSubject:Text:Trim() AS STRING
	LOCAL cBody := SELF:TBBody:Text:Trim() AS STRING
	LOCAL nPos := cBody:IndexOf(" on: ") AS INT
	cBody := cBody:Substring(0, nPos + 5)

	LOCAL cMailClient AS STRING
	LOCAL cSkyfileFolder, cXmlFileMask AS STRING

	IF SELF:RBOutlook:Checked
		cMailClient := "Outlook"

		cSkyfileFolder := ""
	ELSE
		cMailClient := "Skyfile"

		cSkyfileFolder := SELF:TBSkyfileFolder:Text:Trim()
		IF cSkyfileFolder == ""
			wb("No SkyfileFolder specified", "Invalid SkyfileFolder")
			SELF:TBSkyfileFolder:Focus()
			RETURN
		ENDIF
	ENDIF
	cXmlFileMask := SELF:TBXmlFileMask:Text:Trim()

	LOCAL cXMLFile AS STRING

	// Check FMReportTypes
	cStatement:="SELECT ReportBaseNum"+;
				" FROM FMReportTypes"+oMainForm:cNoLockTerm+;
				" WHERE ReportName <> 'Mode (Last Report)'"+;
				" AND ReportBaseNum <= 0 OR "+oSoftway:SelectBlobLength+"(ReportName) <= 1"
	LOCAL oDT1 := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	IF oDT1:Rows:Count > 0
		wb("Reports without ReportBaseNum/ReportName are not permitted", "Empty Report")
		SELF:Close()
		RETURN
	ENDIF

	// Check FMReportItems
	cStatement:="SELECT ItemNo"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" WHERE ItemNo <= 0 OR "+oSoftway:SelectBlobLength+"(ItemName) <= 0"
	LOCAL oDT2 := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	IF oDT2:Rows:Count > 0
		wb("Items without ItemNo/ItemName are not permitted"+CRLF+CRLF+"ItemNo="+oDT2:Rows[0]:Item["ItemNo"]:ToString(), "Empty Item")
		SELF:Close()
		RETURN
	ENDIF

	IF QuestionBox("Vessel: "+SELF:cVesselName+CRLF+CRLF+;
					"Do you want to create a XML DataSet to update the Vessel's Database ?", ;
					"Export Data to Vessel") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

//	LOCAL aFiles := {} AS ARRAY
	VAR aFiles := List<STRING>{}

	// BodyISMForm-ReportUID
	LOCAL cBodyTextTerm := "" AS STRING
	cStatement:="SELECT REPORT_UID, BodyText FROM FMBodyText"+oMainForm:cNoLockTerm
	LOCAL oDTBodyText := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	FOREACH oRow AS DataRow IN oDTBodyText:Rows
		cBodyTextTerm += " '"+oSoftway:ConvertWildCards(oRow["BodyText"]:ToString(), FALSE)+"' AS BodyISM"+oRow["REPORT_UID"]:ToString()+","
	NEXT

	LOCAL cLogDir := SELF:TBLogDir:Text:Trim() AS STRING

	cStatement:="SELECT SupVessels.VESSEL_UNIQUEID, Vessels.VesselName, SupVessels.PropellerPitch,"+;
				" '"+cMailClient+"' AS MailClient, '"+cEMail+"' AS eMail, '"+cBody+"' AS Body,"+;
				cBodyTextTerm+;
				" '"+cSkyfileFolder+"' AS SkyfileFolder, '"+cXmlFileMask+"' AS XmlFileMask, '"+cLogDir+"' AS LogDir"+;
				" FROM SupVessels"+oMainForm:cNoLockTerm+;
				" INNER JOIN Vessels ON SupVessels.VESSEL_UNIQUEID=Vessels.VESSEL_UNIQUEID"+;
				" AND SupVessels.VESSEL_UNIQUEID="+oMainForm:GetVesselUID
				// , '"+cSubject+"' AS Subject
				//" '"+oSoftway:ConvertWildCards(SELF:cBodyISM, FALSE)+"' AS BodyISM,"+;
	//memowrit(ctempdocdir+"\vessels.txt", cStatement)
	LOCAL oDTVessels := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oSoftway:CreatePK(oDTVessels, "VESSEL_UNIQUEID")
	oDTVessels:TableName := "FMVessels"
	cXMLFile := Application.StartupPath + "\FMVessels.XML"
//	AADD(aFiles, cXMLFile)
	aFiles:Add(cXMLFile)
	oDTVessels:WriteXml(cXMLFile, XmlWriteMode.WriteSchema, FALSE)

	cStatement:="SELECT CATEGORY_UID, Description, SortOrder"+;
				" FROM FMItemCategories  Where CATEGORY_UID<>0"+;
				" ORDER BY SortOrder "
//				" UNION SELECT 0 AS CATEGORY_UID, '' AS Description"+;
	LOCAL oDTItemCategories := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oSoftway:CreatePK(oDTItemCategories, "CATEGORY_UID")
	oDTItemCategories:TableName := "FMItemCategories"
	cXMLFile := Application.StartupPath + "\FMItemCategories.XML"
//	AADD(aFiles, cXMLFile)
	aFiles:Add(cXMLFile)
	oDTItemCategories:WriteXml(cXMLFile, XmlWriteMode.WriteSchema, FALSE)

	cStatement:="SELECT FMReportTypes.*"+;
				" FROM FMReportTypes"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMReportTypesVessel ON FMReportTypes.REPORT_UID=FMReportTypesVessel.REPORT_UID"+;
				"	AND FMReportTypesVessel.VESSEL_UNIQUEID="+oMainForm:GetVesselUID+;
				" WHERE ReportName <> 'Mode (Last Report)' AND ReportType = 'O' "+;
				" ORDER BY ReportBaseNum"
	LOCAL oDTReportTypes := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oSoftway:CreatePK(oDTReportTypes, "REPORT_UID")
	oDTReportTypes:TableName := "FMReportTypes"
	cXMLFile := Application.StartupPath + "\FMReportTypes.XML"
//	AADD(aFiles, cXMLFile)
	aFiles:Add(cXMLFile)
	oDTReportTypes:WriteXml(cXMLFile, XmlWriteMode.WriteSchema, FALSE)

	cStatement:="SELECT FMReportItems.*"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" LEFT OUTER JOIN FMItemCategories ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
				" INNER JOIN FMReportTypes ON FMReportItems.REPORT_UID=FMReportTypes.REPORT_UID"+;
				"	AND FMReportTypes.ReportType = 'O' "+;
				" INNER JOIN FMReportTypesVessel ON FMReportItems.REPORT_UID=FMReportTypesVessel.REPORT_UID"+;
				"	AND FMReportTypesVessel.VESSEL_UNIQUEID="+oMainForm:GetVesselUID+;
				" ORDER BY FMItemCategories.SortOrder, ItemNo"
	LOCAL oDTReportItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oSoftway:CreatePK(oDTReportItems, "ITEM_UID")
	oDTReportItems:TableName := "FMReportItems"
	cXMLFile := Application.StartupPath + "\FMReportItems.XML"
//	AADD(aFiles, cXMLFile)
	aFiles:Add(cXMLFile)
	oDTReportItems:WriteXml(cXMLFile, XmlWriteMode.WriteSchema, FALSE)
	
	LOCAL oFolderBrowserDialog := FolderBrowserDialog{} AS 	FolderBrowserDialog
	LOCAL oResult := oFolderBrowserDialog:ShowDialog() AS DialogResult
	IF oResult == DialogResult.OK && !STRING.IsNullOrWhiteSpace(oFolderBrowserDialog:SelectedPath)
		LOCAL cZipFile := oFolderBrowserDialog:SelectedPath + "\FMDataSet_"+oSoftway:FileNameValidate(SELF:cVesselName)+;
				"_"+TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC):ToString("HH-mm-ss dd-MM-yyyy")+".ZIP" AS STRING
		IF ! oSoftway:ZipFiles(aFiles, cZipFile)
			RETURN
		ENDIF
		InfoBox("DataSet exported to:"+CRLF+cZipFile)

		SELF:Close()
	ENDIF
	
RETURN

METHOD CheckPropellerPitch(oDTReportItems AS DataTable, oDTVessels AS DataTable) AS LOGIC
	LOCAL lPropellerPitch := (oDTVessels:Rows[0]:Item["PropellerPitch"]:ToString() <> "") AS LOGIC
	IF lPropellerPitch
		RETURN TRUE
	ENDIF

	LOCAL oRows AS DataRow[]
	oRows := oDTReportItems:Select("CalculatedField LIKE '%PropellerPitch%'")
	IF oRows:Length == 0
		RETURN TRUE
	ENDIF
RETURN FALSE


//METHOD CheckPropellerPitch(oDTReportItems AS DataTable, oDTVessels AS DataTable) AS LOGIC
//	LOCAL lPropellerPitch := (oDTVessels:Rows[0]:Item["PropellerPitch"]:ToString() == "") AS LOGIC
//	IF lPropellerPitch
//		RETURN TRUE
//	ENDIF

//	//LOCAL cRPM := "1", cSpeed := "2", cSlip := "3" AS STRING
//	LOCAL aItemTypes := <STRING>{ItemTypes.RPM:ToString(), ItemTypes.Speed:ToString(), ItemTypes.Slip:ToString()} AS STRING[]
//	//LOCAL aItemTypes := <STRING>{ItemTypes.RPM:ToString()} AS STRING[]
//	LOCAL oRows AS DataRow[]

//	FOREACH cType AS STRING IN aItemTypes
//		oRows := oDTReportItems:Select("ItemType='"+cType+"'")
//		IF oRows:Length > 0
//			RETURN FALSE
//		ENDIF
//	NEXT
//RETURN TRUE


METHOD OpenBodyISMForm() AS VOID
	LOCAL oBodyISMForm := BodyISMForm{} AS BodyISMForm
	oBodyISMForm:cReportUID := SELF:cReportUID
	oBodyISMForm:cReportName := SELF:cReportName
	oBodyISMForm:cVesselName := SELF:cVesselName
	oBodyISMForm:Show()
RETURN

METHOD ExportTablesToAllVessels() AS VOID


	LOCAL cEMail := SELF:TBeMail:Text:Trim() AS STRING
	IF cEMail == "" .OR. ! cEMail:Contains("@") .OR. ! cEMail:Contains(".")
		wb("No eMail specified", "Invalid eMail")
		SELF:TBeMail:Focus()
		RETURN
	ENDIF

	LOCAL cStatement AS STRING
	//LOCAL cReportUID := oMainForm:LBCReports:SelectedValue:ToString() AS STRING

	// Update FMBodyText.eMail
	cStatement:="UPDATE FMBodyText SET eMail='"+oSoftway:ConvertWildcards(cEMail, FALSE)+"'"+;
				" WHERE REPORT_UID="+SELF:cReportUID
	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)

	//LOCAL cSubject := SELF:TBSubject:Text:Trim() AS STRING
	LOCAL cBody := SELF:TBBody:Text:Trim() AS STRING
	LOCAL nPos := cBody:IndexOf(" on: ") AS INT
	cBody := cBody:Substring(0, nPos + 5)

	LOCAL cMailClient AS STRING
	LOCAL cSkyfileFolder, cXmlFileMask AS STRING

	IF SELF:RBOutlook:Checked
		cMailClient := "Outlook"

		cSkyfileFolder := ""
	ELSE
		cMailClient := "Skyfile"

		cSkyfileFolder := SELF:TBSkyfileFolder:Text:Trim()
		IF cSkyfileFolder == ""
			wb("No SkyfileFolder specified", "Invalid SkyfileFolder")
			SELF:TBSkyfileFolder:Focus()
			RETURN
		ENDIF
	ENDIF
	cXmlFileMask := SELF:TBXmlFileMask:Text:Trim()

	LOCAL cXMLFile AS STRING

	// Check FMReportTypes
	cStatement:="SELECT ReportBaseNum"+;
				" FROM FMReportTypes"+oMainForm:cNoLockTerm+;
				" WHERE ReportName <> 'Mode (Last Report)'"+;
				" AND ReportBaseNum <= 0 OR "+oSoftway:SelectBlobLength+"(ReportName) <= 1"
	LOCAL oDT1 := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	IF oDT1:Rows:Count > 0
		wb("Reports without ReportBaseNum/ReportName are not permitted", "Empty Report")
		SELF:Close()
		RETURN
	ENDIF

	// Check FMReportItems
	cStatement:="SELECT ItemNo"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" WHERE ItemNo <= 0 OR "+oSoftway:SelectBlobLength+"(ItemName) <= 0"
	LOCAL oDT2 := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	IF oDT2:Rows:Count > 0
		wb("Items without ItemNo/ItemName are not permitted"+CRLF+CRLF+"ItemNo="+oDT2:Rows[0]:Item["ItemNo"]:ToString(), "Empty Item")
		SELF:Close()
		RETURN
	ENDIF

	IF QuestionBox("Vessel: "+SELF:cVesselName+CRLF+CRLF+;
					"Do you want to create a XML DataSet to send to all Vessels ?", ;
					"Export Data to All Vessels") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	

	// BodyISMForm-ReportUID
	LOCAL cBodyTextTerm := "" AS STRING
	cStatement:="SELECT REPORT_UID, BodyText FROM FMBodyText"+oMainForm:cNoLockTerm
	LOCAL oDTBodyText := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	FOREACH oRow AS DataRow IN oDTBodyText:Rows
		cBodyTextTerm += " '"+oSoftway:ConvertWildCards(oRow["BodyText"]:ToString(), FALSE)+"' AS BodyISM"+oRow["REPORT_UID"]:ToString()+","
	NEXT

	LOCAL cLogDir := SELF:TBLogDir:Text:Trim() AS STRING

	cStatement:=" SELECT SupVessels.VESSEL_UNIQUEID, Vessels.VesselName, SupVessels.PropellerPitch "+;
				" FROM SupVessels"+oMainForm:cNoLockTerm+;
				" INNER JOIN Vessels ON SupVessels.VESSEL_UNIQUEID=Vessels.VESSEL_UNIQUEID AND Visible='Y'"+;
				" WHERE SupVessels.Active = 1  "
	//memowrit(ctempdocdir+"\vessels.txt", cStatement)
	LOCAL oDTVessels := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oSoftway:CreatePK(oDTVessels, "VESSEL_UNIQUEID")
	oDTVessels:TableName := "FMVessels"

	FOREACH oDRVessel AS DataRow IN oDTVessels:Rows

		cBody := "VesselID: "+oDRVessel["VESSEL_UNIQUEID"]:ToString()+", Vessel: "+;
				 oDRVessel["VesselName"]:ToString():Trim()+CRLF+"Data set created on: "

		cStatement:="SELECT SupVessels.VESSEL_UNIQUEID, Vessels.VesselName, SupVessels.PropellerPitch,"+;
				" '"+cMailClient+"' AS MailClient, '"+cEMail+"' AS eMail, '"+cBody+"' AS Body,"+;
				cBodyTextTerm+;
				" '"+cSkyfileFolder+"' AS SkyfileFolder, '"+cXmlFileMask+"' AS XmlFileMask, '"+cLogDir+"' AS LogDir"+;
				" FROM SupVessels"+oMainForm:cNoLockTerm+;
				" INNER JOIN Vessels ON SupVessels.VESSEL_UNIQUEID=Vessels.VESSEL_UNIQUEID AND Visible='Y'"+;
				" WHERE SupVessels.Active = 1 AND SupVessels.VESSEL_UNIQUEID="+ oDRVessel["VESSEL_UNIQUEID"]:ToString()
		//memowrit(ctempdocdir+"\vessels.txt", cStatement)
		LOCAL oDTVessel := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		oSoftway:CreatePK(oDTVessel, "VESSEL_UNIQUEID")
		oDTVessel:TableName := "FMVessels"

				// Check if SupVessels.PropellerPitch is defined
		LOCAL cCheckPropellerPitch := "" AS STRING
		cCheckPropellerPitch := oDRVessel["PropellerPitch"]:ToString()

		IF cCheckPropellerPitch == NULL || cCheckPropellerPitch:Trim() == ""
			ErrorBox("You have to specify the PropellerPitch for the Vessel: "+oDRVessel["VesselName"]:ToString(), "Export aborted")
			LOOP
		ENDIF

//		LOCAL aFiles := {} AS ARRAY
		VAR aFiles := List<STRING>{}
		cXMLFile := Application.StartupPath + "\FMVessels.XML"
//		AADD(aFiles, cXMLFile)
		aFiles:Add(cXMLFile)
		oDTVessel:WriteXml(cXMLFile, XmlWriteMode.WriteSchema, FALSE)

		cStatement:="SELECT CATEGORY_UID, Description, SortOrder"+;
					" FROM FMItemCategories  Where CATEGORY_UID<>0"+;
					" ORDER BY SortOrder "
	//				" UNION SELECT 0 AS CATEGORY_UID, '' AS Description"+;
		LOCAL oDTItemCategories := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		oSoftway:CreatePK(oDTItemCategories, "CATEGORY_UID")
		oDTItemCategories:TableName := "FMItemCategories"
		cXMLFile := Application.StartupPath + "\FMItemCategories.XML"
//		AADD(aFiles, cXMLFile)
		aFiles:Add(cXMLFile)
		oDTItemCategories:WriteXml(cXMLFile, XmlWriteMode.WriteSchema, FALSE)

		cStatement:="SELECT FMReportTypes.*"+;
					" FROM FMReportTypes"+oMainForm:cNoLockTerm+;
					" INNER JOIN FMReportTypesVessel ON FMReportTypes.REPORT_UID=FMReportTypesVessel.REPORT_UID"+;
					"	AND FMReportTypesVessel.VESSEL_UNIQUEID="+oDRVessel["VESSEL_UNIQUEID"]:ToString()+;
					" WHERE ReportName <> 'Mode (Last Report)' AND ReportType = 'V' "+;
					" ORDER BY ReportBaseNum"
		LOCAL oDTReportTypes := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		oSoftway:CreatePK(oDTReportTypes, "REPORT_UID")
		oDTReportTypes:TableName := "FMReportTypes"
		cXMLFile := Application.StartupPath + "\FMReportTypes.XML"
//		AADD(aFiles, cXMLFile)
		aFiles:Add(cXMLFile)
		oDTReportTypes:WriteXml(cXMLFile, XmlWriteMode.WriteSchema, FALSE)

		cStatement:="SELECT FMReportItems.*"+;
					" FROM FMReportItems"+oMainForm:cNoLockTerm+;
					" LEFT OUTER JOIN FMItemCategories ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
					" INNER JOIN FMReportTypes ON FMReportItems.REPORT_UID=FMReportTypes.REPORT_UID"+;
					"	AND FMReportTypes.ReportType = 'V' "+;
					" INNER JOIN FMReportTypesVessel ON FMReportItems.REPORT_UID=FMReportTypesVessel.REPORT_UID"+;
					"	AND FMReportTypesVessel.VESSEL_UNIQUEID="+oDRVessel["VESSEL_UNIQUEID"]:ToString()+;
					" ORDER BY FMItemCategories.SortOrder, ItemNo"
		LOCAL oDTReportItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		oSoftway:CreatePK(oDTReportItems, "ITEM_UID")
		oDTReportItems:TableName := "FMReportItems"
		cXMLFile := Application.StartupPath + "\FMReportItems.XML"
//		AADD(aFiles, cXMLFile)
		aFiles:Add(cXMLFile)
		oDTReportItems:WriteXml(cXMLFile, XmlWriteMode.WriteSchema, FALSE)

		LOCAL cZipFile := cFleetManagerVesselPath + "\FMDataSet_"+oSoftway:FileNameValidate(oDRVessel["VesselName"]:ToString())+"_"+TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC):ToString("yyyy-MM-dd_HH-mm-ss")+".ZIP" AS STRING
		IF ! oSoftway:ZipFiles(aFiles, cZipFile)
			RETURN
		ENDIF

	NEXT
	InfoBox("DataSets exported to:"+CRLF+cFleetManagerVesselPath)

	//SELF:Close()
RETURN

METHOD ImportDataFromZip() AS VOID

	TRY
		LOCAL oOpenFileDialog:=  System.Windows.Forms.OpenFileDialog{} AS System.Windows.Forms.OpenFileDialog
		oOpenFileDialog:Filter:="zip files|*.zip"
		oOpenFileDialog:Multiselect := FALSE
		LOCAL dr := oOpenFileDialog:ShowDialog() AS DialogResult
		IF oOpenFileDialog:FileName == ""
			RETURN
		ENDIF
		IF dr == System.Windows.Forms.DialogResult.OK
			// Read the files 
			FOREACH file AS STRING IN oOpenFileDialog:FileNames
			// 
			TRY
				LOCAL oFleetManagerDataImporter := FleetManagerDataImporter{} AS FleetManagerDataImporter
				
				LOCAL cDocName := Path.GetFileName(file) AS STRING
				LOCAL cDir := System.IO.Path.GetDirectoryName(file) AS STRING

				IF ! (cDocName:StartsWith("FleetManagerData-") .AND. cDocName:ToUpper():EndsWith(".ZIP"))
					ErrorBox("The file must start with: 'FleetManagerData-'", "Operation aborted")
					RETURN
				ENDIF
				
				LOCAL cBody := "" AS STRING
				
				oFleetManagerDataImporter:ReadDataSet(file, cDir , "0",cBody)
				
			CATCH ex AS Exception
				LOCAL cDocName := Path.GetFileName(file) AS STRING
				MessageBox.Show("Cannot import the file : " + cDocName +;
				CRLF + CRLF + ex:Message)
			END	
			NEXT
		ENDIF
	CATCH exc AS Exception
			System.Windows.Forms.MessageBox.Show(exc:StackTrace,"Error")	
	END   

RETURN

END CLASS
