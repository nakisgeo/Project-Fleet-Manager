
#Using System.Data
#Using System.Data.Common
#Using System.IO
#Using System.Windows.Forms
#USING System.Diagnostics
#USING System.Xml
#Using System.Drawing
#Using System.Collections

CLASS FleetManagerDataImporter
	PRIVATE nLine AS SHORT

	PRIVATE oGFH AS GenericFactoryHelper
	PRIVATE oConn AS DBConnection
	PRIVATE cSDF:=cStartupPath+"\SOFTWAY.SDF" AS STRING		// Desktop and Devices

CONSTRUCTOR()
	
RETURN






METHOD ReadDataSet(cZipFile AS STRING, cDir AS STRING, cMsgUID AS STRING, cSkyFileBody REF STRING) AS VOID
	
	LOCAL cXmlFile := cZipFile:Substring(0, cZipFile:Length - 4) + ".XML" AS STRING
	LOCAL cStatement AS STRING

	TRY
		// Extract XML file
		IF ! oSoftway:UnZip(cZipFile, cDir)
			RETURN
		ENDIF

		// Create XmlDocument
		LOCAL oXmlDocument := XmlDocument{} AS XmlDocument	
		// Fill XmlDocument
		oXmlDocument:Load(cXmlFile)

		// Read RootNode (ModbusData)
		LOCAL oRootNode := oXmlDocument:DocumentElement AS XmlElement
		//wb("oRootNode="+oRootNode:Name)

		// Read CreationDate
		//LOCAl cValue := SELF:GetFieldValue("CreationDate", oRootNode) AS STRING

		// Read VesselName
		LOCAL cVesselName := SELF:GetFieldValue("VesselName", oRootNode) AS STRING

		// Read VesselCode
		LOCAL cVesselCode := SELF:GetFieldValue("VesselCode", oRootNode) AS STRING
	
		// Check for VesselCode=Vessels.VESSEL_UNIQUEID and VesselName=Vessels.VesselName
		IF ! SELF:CheckVessel(cXmlFile, cVesselCode, cVesselName, oMainForm:oGFH, oMainForm:oConn)
			RETURN
		ENDIF

		// Read VesselCode
		LOCAL cReportUID := SELF:GetFieldValue("ReportCode", oRootNode) AS STRING

		// Read MailClient
		LOCAL cMailClient := "" AS STRING
		TRY
			cMailClient := SELF:GetFieldValue("MailClient", oRootNode)
		END TRY

		// Read GMT DateTime
		LOCAL cGmtDiff := SELF:GetFieldValue("GmtDiff", oRootNode):Replace(oMainForm:decimalSeparator, ".") AS STRING
		LOCAL cDateGMT := SELF:GetFieldValue("DateGMT", oRootNode) AS STRING
		
		IF cGmtDiff:Trim():Equals("")
			cGmtDiff := "2" 
			cDateGMT := DateTime.Now:ToString("yyyy-MM-dd HH:mm:ss")
		ENDIF

		// Read GPS coordinates
		LOCAL cLatitude := SELF:GetFieldValue("Latitude", oRootNode) AS STRING
		LOCAL cN_OR_S := SELF:GetFieldValue("N_OR_S", oRootNode) AS STRING
		LOCAL cLongitude := SELF:GetFieldValue("Longitude", oRootNode) AS STRING
		LOCAL cW_OR_E := SELF:GetFieldValue("W_OR_E", oRootNode) AS STRING

		// Read TextBoxMultiline
		LOCAL cTextBoxMultiline := SELF:GetFieldValue("TextBoxMultiline", oRootNode) AS STRING

		//Check if the report exists on the system and if exists then hide it
		cStatement:=" SELECT PACKAGE_UID FROM FMDataPackages "+oMainForm:cNoLockTerm+;
					" WHERE DateTimeGMT='"+cDateGMT+"' AND GmtDiff="+cGmtDiff+;
					" AND REPORT_UID="+cReportUID+" AND VESSEL_UNIQUEID="+cVesselCode+;
					" AND Visible=1"
		LOCAL oDTExistingReports := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		IF oDTExistingReports<> NULL .AND. oDTExistingReports:Rows:Count>0
			FOREACH oReportRow AS DataRow IN oDTExistingReports:Rows
				cStatement:="UPDATE FMDataPackages SET Visible=0"+;
						" WHERE PACKAGE_UID="+oReportRow["PACKAGE_UID"]:ToString()
				IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
					MessageBox.Show(cStatement+" / Cannot hide previous report VESSEL_UNIQUEID="+cVesselCode)
					LOOP
				ENDIF
			NEXT
		ENDIF

		// Insert FMDataPackages entry
		cStatement:="INSERT INTO FMDataPackages (VESSEL_UNIQUEID, REPORT_UID, DateTimeGMT, GmtDiff, Latitude, N_OR_S, Longitude, W_OR_E, MSG_UNIQUEID, Memo) VALUES"+;
					" ("+cVesselCode+", "+cReportUID+", '"+cDateGMT+"', "+cGmtDiff+", '"+cLatitude+"', '"+cN_OR_S+"',"+;
					" '"+cLongitude+"', '"+cW_OR_E+"', "+cMsgUID+", '"+oSoftway:ConvertWildcards(cTextBoxMultiline, FALSE)+"')"
		IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			//ErrorBox("Cannot insert FMDataPackages entry for Vessel="+cVesselName)
			MessageBox.Show("Cannot insert FMDataPackages entry for Vessel="+cVesselName+CRLF+cStatement)
			RETURN
		ENDIF

		LOCAL cPackageUID := oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "FMDataPackages", "PACKAGE_UID") AS STRING
		//SELF:oSoftway:MyWriteEntry("cPackageUID="+cPackageUID, EventLogEntryType.Information, EventIDs.Status, SELF:nLine)

		// Read ReportItems
		cStatement:="SELECT ITEM_UID, ItemType FROM FMReportItems"+oMainForm:cNoLockTerm+;
					" WHERE REPORT_UID="+cReportUID
		LOCAL oDTItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		oSoftway:CreatePK(oDTItems, "ITEM_UID")

		LOCAL oParentNode AS XmlNode
		LOCAL cID, cData, cItemType,cTempFileInXML AS STRING

		// Read Data
		oParentNode := SELF:GetXmlNode("ReportData", oRootNode)
//		IF oParentNode <> NULL
		//wb("oParentNode="+oParentNode:Name+CRLF+"Children="+oParentNode:ChildNodes:Count:ToString())
		LOCAL oNodePackage AS XmlNode
		LOCAL oDateRows AS DataRow[]
		LOCAL n, nItems := 0, nPackages := oParentNode:ChildNodes:Count - 1 AS INT
		
		FOR n:=0 UPTO nPackages STEP 2
			oNodePackage := oParentNode:ChildNodes[n]
			cID := oNodePackage:InnerText

			oNodePackage := oParentNode:ChildNodes[n + 1]
			cData := oNodePackage:InnerText

			// Check for DateTime field
			oDateRows := oDTItems:Select("ITEM_UID="+cID)
			IF oDateRows:Length == 0
				//ErrorBox("Cannot find Item UID="+cID+CRLF+CRLF+;
				//		"Probably, the Vessel have an outdated Data Set"+CRLF+;
				//		"Please go to Tools and create an updated Data Set for this Vessel")
				MessageBox.Show("Cannot find Item UID="+cID+CRLF+CRLF+;
						"Probably, the Vessel have an outdated Data Set"+CRLF+;
						"Please go to Tools and create an updated Data Set for this Vessel")
				RETURN
			ENDIF

			cItemType := oDateRows[1]:Item["ItemType"]:ToString()
			DO CASE
			
			
			CASE cItemType == "N" .AND. ( cData == "." || cData == "," || cData == "-" )
				cData := "0"
			
			CASE cItemType == "C" .OR. cItemType == "D" .OR. cItemType == "M" .OR. cItemType == "T" .OR. cItemType == "X" .OR. cItemType == "N" 
				//dDate := Datetime.Parse(cData)
				//cData := dDate:ToString("yyyy-MM-dd HH:mm:ss")
				cData := "'" + oSoftway:ConvertWildcards(cData, FALSE) + "'"

			//CASE cItemType == "X"
			//	// ComboBox
			//	cData := SELF:GetComboBoxValue(cID, cData)
			CASE cItemType == "L"
				RETURN
			ENDCASE
			
			// Insert FMData entry
			cStatement:="INSERT INTO FMData (PACKAGE_UID, ITEM_UID, Data) VALUES"+;
						" ("+cPackageUID+", "+cID+", "+cData+")"
			IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				//ErrorBox("Cannot insert FMData entry for ID="+cID)
				MessageBox.Show(cStatement+ CRLF + CRLF +"Cannot insert FMData entry for ITEM_UID="+cID)
				LOOP
				//RETURN
			ENDIF
			nItems++
		NEXT

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Antonis
		TRY
			LOCAL cUpdate AS STRING
			oParentNode := SELF:GetXmlNode("Documents", oRootNode)
			IF oParentNode <> NULL
				nPackages := oParentNode:ChildNodes:Count - 1
				FOR n:=0 UPTO nPackages STEP 2
					oNodePackage := oParentNode:ChildNodes[n]
					cID := oNodePackage:InnerText
					cTempFileInXML := cID
					cID := cTempFileInXML:Substring(cTempFileInXML:LastIndexOf(".")+1)

					oNodePackage := oParentNode:ChildNodes[n + 1]
					/////Change 03.02.15
					LOCAL cBytesData := SELF:GetBytes(oNodePackage:InnerText) AS BYTE[]
					system.IO.File.WriteAllText(cTempDocDir+"\cImage.TXT", oNodePackage:InnerText, System.Text.Encoding.Default)
					//SELF:oSoftway:MyWriteEntry(System.Text.Encoding.Default:tostring(), "", "", SELF:nLine)
					LOCAL oFS AS FileStream
					LOCAL formatter := System.Runtime.Serialization.Formatters.Binary.BinaryFormatter{} AS System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
					LOCAL oBinary AS BYTE[]
					oFS := File.OpenRead(cTempDocDir+"\cImage.TXT")
					oBinary:=(BYTE[])formatter:DeSerialize(oFS)
					oFS:Close()
					cBytesData := oBinary
					//////
					IF symServer == #MySQL
					   cUpdate:="INSERT INTO FMBlobData (PACKAGE_UID, ITEM_UID, Filename, BlobData) VALUES"+;
								" ("+cPackageUID+", "+cID+", '"+cTempFileInXML+"', ?image)"
					   ELSE
						cUpdate:="INSERT INTO FMBlobData (PACKAGE_UID, ITEM_UID, Filename, BlobData) VALUES"+;
								" ("+cPackageUID+", "+cID+", '"+cTempFileInXML+"', @image)"
					 ENDIF
					LOCAL oSqlCommand:=oGFH:Command() AS DBCommand
					oSqlCommand:CommandText:=cUpdate
					oSqlCommand:Connection:=oConn
					LOCAL oParameter:=oGFH:Parameter() AS DBParameter
					IF symServer == #MySQL
					  oParameter:ParameterName:="?image"
					ELSE
					   oParameter:ParameterName:="@image"
					ENDIF
					oParameter:Value:=(OBJECT)cBytesData
					oSqlCommand:Parameters:Add(oParameter)
					IF oSqlCommand:ExecuteNonQuery() == 0
						MessageBox.Show("Cannot insert FMData entry for ITEM_UID="+cID)
					ENDIF			
					system.IO.File.Delete(cTempDocDir+"\cImage.TXT")
				NEXT
			ENDIF

		CATCH e AS Exception
				MessageBox.Show(cXmlFile+": "+e:Message)
				system.IO.File.Delete(cTempDocDir+"\cImage.TXT")
		END	TRY
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		System.IO.File.Delete(cXmlFile)
		System.IO.File.Delete(cZipFile)

//		IF cMailClient == "Skyfile"
//			LOCAL cEMail := "" AS STRING
//			LOCAL cBodyISM := SELF:ReadBodyISM(cReportUID, cEMail) AS STRING
//			cSkyFileBody := SELF:ReplaceBodyTextFields(cBodyISM, cVesselName, cReportUID, cPackageUID)
//		ENDIF

		//InfoBox(nItems:ToString()+" Items imported")

	CATCH e AS Exception
		//ErrorBox(cXmlFile+": "+e:Message)
		MessageBox.Show(cXmlFile+": "+e:Message)
	END TRY
RETURN

METHOD  GetBytes(str AS STRING) AS BYTE[]
	LOCAL iLength := (INT)(str:Length * sizeof(CHAR))  AS INT 	
    LOCAL  bytes := BYTE[]{iLength} AS BYTE[]
    System.Buffer.BlockCopy(str:ToCharArray(), 0, bytes, 0, bytes:Length)
RETURN bytes


METHOD GetString(bytes AS BYTE[]) AS STRING
	LOCAL iLength  := (INT)(bytes:Length / sizeof(CHAR))  AS INT 
    LOCAL chars := CHAR[]{iLength} AS CHAR[]
    System.Buffer.BlockCopy(bytes, 0, chars, 0, bytes:Length)
    LOCAL final := STRING{chars}  AS STRING
RETURN final



#Region SkyFileBody

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


METHOD ReplaceBodyTextFields(cBodyISM AS STRING, cVesselName AS STRING, cReportUID AS STRING, cPackageUID AS STRING) AS STRING
	IF cBodyISM == ""
		//wb("No Body text specified")
		RETURN ""
	ENDIF

	LOCAL cRet := cBodyISM AS STRING

	LOCAL cStatement AS STRING
	cStatement:="SELECT ReportName"+;
				" FROM FMReportTypes"+oMainForm:cNoLockTerm+;
				" WHERE REPORT_UID="+cReportUID
	LOCAL cReportName := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "ReportName") AS STRING

	cRet := cRet:Replace("<REPORTNAME>", cReportName:ToUpper())
	cRet := cRet:Replace("<VESSELNAME>", cVesselName:ToUpper())

	//cStatement:="SELECT FMReportItems.ItemNo, FMReportItems.ItemType, FMData.Data"+;
	cStatement:="SELECT FMReportItems.ItemNo, FMData.Data"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMData ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
				"	AND FMData.PACKAGE_UID="+cPackageUID
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oDT:TableName:="Items"
	// Create Primary Key
	oSoftway:CreatePK(oDT, "ItemNo")

	// Add missing MultiLineText Items
	cStatement:="SELECT Memo"+;
				" FROM FMDataPackages"+oMainForm:cNoLockTerm+;
				" WHERE PACKAGE_UID="+cPackageUID
	LOCAL cTextForMultilines := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Memo") AS STRING
	LOCAL charSplStart := (CHAR)168 AS CHAR
	LOCAL charSplEnd := (CHAR)169 AS CHAR
	LOCAL cItems := cTextForMultilines:Split(charSplEnd) AS STRING[]
	LOCAL cItemNo, cValue AS STRING
	FOREACH cItem AS STRING IN cItems
		IF cItem <> NULL .AND. cItem <> ""
			LOCAL cItemsTemp := cItem:Split(charSplStart) AS STRING[]
			cStatement:="SELECT ItemNo"+;
						" FROM FMReportItems"+oMainForm:cNoLockTerm+;
						" WHERE ITEM_UID="+cItemsTemp[1]
			cItemNo := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "ItemNo")
			IF cItemNo <> ""
				SELF:ReplaceField(cRet, cItemNo, cItemsTemp[2])
			ENDIF
		ENDIF
	NEXT

	FOREACH oRow AS DataRow IN oDT:Rows
		cItemNo := oRow:Item["ItemNo"]:ToString()
		//cItemType := oRow:Item["ItemType"]:ToString()
		cValue := oRow["Data"]:ToString()

		//IF cItemType == "X"
		//	// ComboBox
		//	cValue := SELF:SetComboBoxValue(oRow:Item["ItemType"]:ToString(), cValue)
		//ENDIF

		SELF:ReplaceField(cRet, cItemNo, cValue)
	NEXT

	SELF:CompileExpressions(cRet, "+")

	// GmtDiff
	cStatement:="SELECT GmtDiff"+;
				" FROM FMDataPackages"+oMainForm:cNoLockTerm+;
				" WHERE PACKAGE_UID="+cPackageUID
	LOCAL cGmtDiff := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "GmtDiff") AS STRING
	LOCAL nValue := Convert.ToDecimal(cGmtDiff) AS Decimal
	LOCAL nHours := (INT)nValue AS INT
	LOCAL cGmt := nHours:ToString() AS STRING
	IF ! cGmt:StartsWith("-")
		cGmt := "+" + cGmt
	ENDIF
	IF cGmt:Length == 2
		cGmt := cGmt:Substring(0, 1)+cGmt:Substring(1, 1):PadLeft(2, '0')
	ENDIF

	LOCAL nMinutes := Math.Abs(nValue) - (Decimal)Math.Abs(nHours) AS Decimal
	IF nMinutes == (Decimal)0
		cGmt += ":00"
	ELSE
		nMinutes := (INT)(((Double)nMinutes * (Double)60) / (Double)3600)
		cGmt += ":" + nMinutes:ToString():PadLeft(2, '0')
	ENDIF
	cRet := cRet:Replace("GMTDIFF", cGmt)
RETURN cRet


METHOD ReplaceField(cRet REF STRING, cItemNo AS STRING, cValue AS STRING) AS VOID
	LOCAL nPos, nPosFound AS INT
	LOCAL cWhat AS STRING

	nPos := 0
	nPosFound := -1
	WHILE nPos <> -1
		cWhat := "<ID" + cItemNo
		nPos := cRet:IndexOf(cWhat, nPosFound + 1)
		IF nPos == -1
			cWhat := "+ID" + cItemNo
			nPos := cRet:IndexOf(cWhat, nPosFound + 1)
		ENDIF
		IF nPos == -1
			RETURN
		ENDIF

		nPosFound := nPos
		IF cValue == ""
			cValue := "NIL"
		ENDIF

		DO CASE
		CASE cRet:Substring(nPos, 1) == "<" .AND. cRet:Substring(nPos + cWhat:Length, 1) == ">"
			// Single ItemID: Remove < and >
			cRet := cRet:Substring(0, nPos) + cValue + cRet:Substring(nPos + cWhat:Length + 1)

		CASE cRet:Substring(nPos, 1) == "<" .AND. cRet:Substring(nPos + cWhat:Length, 1) == "+"
			// ItemID is the left term of Addition:
			cRet := cRet:Substring(0, nPos + 1) + cValue + cRet:Substring(nPos + cWhat:Length)

		CASE cRet:Substring(nPos, 1) == "+" .AND. cRet:Substring(nPos + cWhat:Length, 1) == "+"
			// ItemID is the middle term of Addition: Just replace
			cRet := cRet:Substring(0, nPos + 1) + cValue + cRet:Substring(nPos + cWhat:Length)

		CASE cRet:Substring(nPos, 1) == "+" .AND. cRet:Substring(nPos + cWhat:Length, 1) == ">"
			// ItemID is the right term of Addition:
			cRet := cRet:Substring(0, nPos + 1) + cValue + cRet:Substring(nPos + cWhat:Length)

		OTHERWISE
			////cRet := cRet:Substring(0, nPos + 1) + cValue + cRet:Substring(nPos + 1 + cWhat:Length)
			//MessageBox.Show("Error with ItemNo: "+cItemNo, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
			MessageBox.Show("Skyfile BodyText: Error with ItemNo: "+cItemNo)
		ENDCASE
		//IF "217+218+233+234":Contains(cItemNo)
		//	wb("cItemNo="+cItemNo+CRLF+"cRet="+cRet:ToString(), "")
		//ENDIF
	ENDDO
RETURN


METHOD CompileExpressions(cRet REF STRING, cOper AS STRING) AS VOID
	LOCAL oFormulaCompiler := FormulaCompiler{NULL} AS FormulaCompiler
	LOCAL cAmount, cValueText AS STRING
	LOCAL nPos, nPosEnd AS INT

	nPos := 0
	WHILE nPos <> -1
		nPos := cRet:IndexOf("<", nPos + 1)
		IF nPos == -1
			EXIT
		ENDIF
		nPosEnd := cRet:IndexOf(">", nPos + 1)
		IF nPos < nPosEnd
			cValueText := cRet:Substring(nPos + 1, nPosEnd - nPos - 1)
			IF cValueText:Contains(cOper)
				cAmount := oFormulaCompiler:CalculateExpression(cValueText)
			ELSE
				cAmount := cValueText
			ENDIF
			IF SELF:StringIsNumeric(cAmount, oMainForm:decimalSeparator+oMainForm:groupSeparator)
				cAmount := cAmount:Replace(oMainForm:decimalSeparator, ".")
			ENDIF
			//wb("cValueText="+cValueText+CRLF+"cAmount="+cAmount, "")
			cRet := cRet:Substring(0, nPos) + cAmount + cRet:Substring(nPosEnd + 1)
		ENDIF
		//wb("cRet="+cRet, "")
	ENDDO
RETURN

#EndRegion SkyFileBody



METHOD GetXmlNode(cFieldName AS STRING, oRootNode AS XmlElement) AS XmlNode
	LOCAL oXmlNodeList := oRootNode:GetElementsByTagName(cFieldName) AS XmlNodeList

	//IF oXmlNodeList:Item(0) == NULL
	//	RETURN NULL
	//ENDIF
RETURN oXmlNodeList:Item(0)


METHOD GetFieldValue(cFieldName AS STRING, oRootNode AS XmlElement) AS STRING
	LOCAL oXmlNodeList := oRootNode:GetElementsByTagName(cFieldName) AS XmlNodeList

	IF oXmlNodeList:Item(0) == NULL
		RETURN ""
	ENDIF
RETURN oXmlNodeList:Item(0):InnerText


METHOD CheckVessel(cXmlFile AS STRING, cVesselCode AS STRING, cVesselName AS STRING, ;
					oGFH AS GenericFactoryHelper, oConn AS DBConnection) AS LOGIC
	LOCAL cStatement AS STRING

	cStatement:="SELECT VESSEL_UNIQUEID FROM Vessels"+oMainForm:cNoLockTerm+;
				" WHERE VESSEL_UNIQUEID="+cVesselCode+;
				" AND VesselName='"+oSoftway:ConvertWildcards(cVesselName, FALSE)+"'"
	IF oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "VESSEL_UNIQUEID") <> cVesselCode
		//ErrorBox(cXmlFile+": Cannot find Vessel: "+cVesselCode+" - "+cVesselName+CRLF+;
		//					"Import aborted")
		MessageBox.Show("Import aborted: "+cXmlFile+": Cannot find Vessel: "+cVesselCode+" - "+cVesselName)
		RETURN FALSE
	ENDIF
RETURN TRUE


METHOD StringIsNumeric(cStr AS STRING) AS LOGIC
	LOCAL n, nLen:=cStr:Length - 1 AS INT
	LOCAL c AS STRING
	LOCAL cNumbers := "0123456789" AS STRING

	IF nLen < 0
	   RETURN FALSE
	ENDIF

	FOR n:=0 UPTO nLen
		c := cStr:Substring(n, 1)
	   IF ! cNumbers:Contains(c)
		  RETURN FALSE
	   ENDIF
	NEXT
RETURN TRUE


METHOD StringIsNumeric(cStr AS STRING, cInclude AS STRING) AS LOGIC
	LOCAL n, nLen:=cStr:Length - 1 AS INT
	LOCAL c AS STRING
	LOCAL cNumbers := "0123456789" AS STRING

	IF nLen < 0
	   RETURN FALSE
	ENDIF

	cNumbers += cInclude

	FOR n:=0 UPTO nLen
		c := cStr:Substring(n, 1)
	   IF ! cNumbers:Contains(c)
		  RETURN FALSE
	   ENDIF
	NEXT
RETURN TRUE

END CLASS


