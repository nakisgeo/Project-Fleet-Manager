//// ImportFleetManagerData.prg
//#Using System.Data
//#Using System.Data.Common
//#Using System.IO
//#Using System.Windows.Forms
//#USING System.Diagnostics
//#USING System.Xml

//PARTIAL CLASS MainForm INHERIT DevExpress.XtraEditors.XtraForm

//METHOD ImportDataPackage() AS VOID
//	// Econ: Modbus and GPS data
//	LOCAL oOpenFileDialog:=OpenFileDialog{} AS OpenFileDialog

//	oOpenFileDialog:ShowDialog(SELF)
//	LOCAL cFiles:=oOpenFileDialog:FileNames AS STRING[]
//	IF cFiles:Length == 0
//		RETURN
//	ENDIF
//	LOCAL cZipFile := cFiles[1] AS STRING
//	LOCAL cDocName := Path.GetFileName(cZipFile) AS STRING

//	IF ! (cDocName:StartsWith("FleetManagerData-") .and. cDocName:ToUpper():EndsWith(".ZIP"))
//		ErrorBox("The file must start with: 'FleetManagerData-'", "Operation aborted")
//		RETURN
//	ENDIF

//	//LOCAL cZipFile := "D:\Visual Studio 2010\Projects\Communicator\Project Econ\Debug\TempDoc\EconDataPackages_2013_02_21__16_25_46.ZIP" AS STRING
//	LOCAL cDir := System.IO.Path.GetDirectoryName(cZipFile) AS STRING
//	SELF:ReadDataSet(cZipFile, cDir, SELF:oGFH, SELF:oConn)
//RETURN


//METHOD ReadDataSet(cZipFile AS STRING, cDir AS STRING, oGFH AS GenericFactoryHelper, oConn AS DBConnection) AS VOID
////cZipFile="D:\Visual Studio 2010\Projects\Communicator\Project Econ\Debug\TempDoc\EconDataPackages_2013_02_21__16_25_46.ZIP"

//	LOCAL cXmlFile := cZipFile:Substring(0, cZipFile:Length - 4) + ".XML" AS STRING
//	LOCAL cStatement AS STRING

//	TRY
//		// Extract XML file
//		IF ! oSoftway:UnZip(cZipFile, cDir)
//			RETURN
//		ENDIF

//		// Create XmlDocument
//		LOCAL oXmlDocument := XmlDocument{} AS XmlDocument	
//		// Fill XmlDocument
//		oXmlDocument:Load(cXmlFile)

//		// Read RootNode (ModbusData)
//		LOCAL oRootNode := oXmlDocument:DocumentElement AS XmlElement
//		//wb("oRootNode="+oRootNode:Name)

//		// Read CreationDate
//		//LOCAl cValue := SELF:GetFieldValue("CreationDate", oRootNode) AS STRING

//		// Read VesselName
//		LOCAL cVesselName := SELF:GetFieldValue("VesselName", oRootNode) AS STRING

//		// Read VesselCode
//		LOCAL cVesselCode := SELF:GetFieldValue("VesselCode", oRootNode) AS STRING
	
//		// Check for VesselCode=Vessels.VESSEL_UNIQUEID and VesselName=Vessels.VesselName
//		IF ! SELF:CheckVessel(cXmlFile, cVesselCode, cVesselName, oGFH, oConn)
//			RETURN
//		ENDIF

//		// Read VesselCode
//		LOCAL cReportUID := SELF:GetFieldValue("ReportCode", oRootNode) AS STRING

//		// Read GMT DateTime
//		//LOCAL cGmtDiff := SELF:GetFieldValue("GmtDiff", oRootNode) AS STRING
//		LOCAL cDateGMT := SELF:GetFieldValue("DateGMT", oRootNode) AS STRING

//		// Read GPS coordinates
//		LOCAL cLatitude := SELF:GetFieldValue("Latitude", oRootNode) AS STRING
//		LOCAL cN_OR_S := SELF:GetFieldValue("N_OR_S", oRootNode) AS STRING
//		LOCAL cLongitude := SELF:GetFieldValue("Longitude", oRootNode) AS STRING
//		LOCAL cW_OR_E := SELF:GetFieldValue("W_OR_E", oRootNode) AS STRING

//		// Read TextBoxMultiline
//		LOCAL cTextBoxMultiline := SELF:GetFieldValue("TextBoxMultiline", oRootNode) AS STRING

//		// Insert FMDataPackages entry
//		cStatement:="INSERT INTO FMDataPackages (VESSEL_UNIQUEID, REPORT_UID, DateTimeGMT, Latitude, N_OR_S, Longitude, W_OR_E, Memo) VALUES"+;
//					" ("+cVesselCode+", "+cReportUID+", '"+cDateGMT+"', '"+cLatitude+"', '"+cN_OR_S+"', '"+cLongitude+"', '"+cW_OR_E+"', '"+oSoftway:ConvertWildcards(cTextBoxMultiline, FALSE)+"')"
//		IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
//			ErrorBox("Cannot insert FMDataPackages entry for Vessel="+cVesselName)
//			RETURN
//		ENDIF

//		LOCAL cPackageUID := oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "FMDataPackages", "PACKAGE_UID") AS STRING

//		// Read ReportItems
//		cStatement:="SELECT ITEM_UID, ItemType FROM FMReportItems"+SELF:cNoLockTerm+;
//					" WHERE REPORT_UID="+cReportUID
//		LOCAL oDTItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
//		oSoftway:CreatePK(oDTItems, "ITEM_UID")

//		LOCAL oParentNode AS XmlNode
//		LOCAL cID, cData, cItemType AS STRING

//		// Read Data
//		oParentNode := SELF:GetXmlNode("ReportData", oRootNode)
////		IF oParentNode <> NULL
//		//wb("oParentNode="+oParentNode:Name+CRLF+"Children="+oParentNode:ChildNodes:Count:ToString())
//		LOCAL oNodePackage AS XmlNode
//		LOCAL oDateRows AS DataRow[]
//		LOCAL n, nItems, nPackages := oParentNode:ChildNodes:Count - 1 AS INT

//		FOR n:=0 UPTO nPackages STEP 2
//			oNodePackage := oParentNode:ChildNodes[n]
//			cID := oNodePackage:InnerText

//			oNodePackage := oParentNode:ChildNodes[n + 1]
//			cData := oNodePackage:InnerText

//			// Check for DateTime field
//			oDateRows := oDTItems:Select("ITEM_UID="+cID)
//			IF oDateRows:Length == 0
//				ErrorBox("Cannot find Item UID="+cID+CRLF+CRLF+;
//						"Probably, the Vessel have an outdated Data Set"+CRLF+;
//						"Please go to Tools and create an updated Data Set for this Vessel")
//				RETURN
//			ENDIF

//			cItemType := oDateRows[1]:Item["ItemType"]:ToString()
//			IF cItemType == "C" .or. cItemType == "D" .or. cItemType == "M" .or. cItemType == "T"
//				//dDate := Datetime.Parse(cData)
//				//cData := dDate:ToString("yyyy-MM-dd HH:mm")
//				cData := "'" + oSoftway:ConvertWildcards(cData, FALSE) + "'"
//			ENDIF

//			// Insert FMData entry
//			cStatement:="INSERT INTO FMData (PACKAGE_UID, ITEM_UID, Data) VALUES"+;
//						" ("+cPackageUID+", "+cID+", "+cData+")"
//			IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
//				ErrorBox("Cannot insert FMData entry for ITEM_UID="+cID)
//				RETURN
//			ENDIF
//			nItems++
//		NEXT

//		System.IO.File.Delete(cXmlFile)
//		System.IO.File.Delete(cZipFile)

//		InfoBox(nItems:ToString()+" Items imported")

//	CATCH e AS Exception
//		ErrorBox(cXmlFile+": "+e:Message)
//	END TRY
//RETURN


//METHOD GetXmlNode(cFieldName AS STRING, oRootNode AS XmlElement) AS XmlNode
//	LOCAL oXmlNodeList := oRootNode:GetElementsByTagName(cFieldName) AS XmlNodeList

//	//IF oXmlNodeList:Item(0) == NULL
//	//	RETURN NULL
//	//ENDIF
//RETURN oXmlNodeList:Item(0)


//METHOD GetFieldValue(cFieldName AS STRING, oRootNode AS XmlElement) AS STRING
//	LOCAL oXmlNodeList := oRootNode:GetElementsByTagName(cFieldName) AS XmlNodeList

//	IF oXmlNodeList:Item(0) == NULL
//		RETURN ""
//	ENDIF
//RETURN oXmlNodeList:Item(0):InnerText


//METHOD CheckVessel(cXmlFile AS STRING, cVesselCode AS STRING, cVesselName AS STRING, ;
//					oGFH AS GenericFactoryHelper, oConn AS DBConnection) AS LOGIC
//	LOCAL cStatement AS STRING

//	cStatement:="SELECT VESSEL_UNIQUEID FROM Vessels"+oMainForm:cNoLockTerm+;
//				" WHERE VESSEL_UNIQUEID="+cVesselCode+;
//				" AND VesselName='"+oSoftway:ConvertWildcards(cVesselName, FALSE)+"'"
//	IF oSoftway:RecordExists(oGFH, oConn, cStatement, "VESSEL_UNIQUEID") <> cVesselCode
//		ErrorBox(cXmlFile+": Cannot find Vessel: "+cVesselCode+" - "+cVesselName+CRLF+;
//							"Import aborted")
//		RETURN FALSE
//	ENDIF
//RETURN TRUE

//END CLASS
