// BodyISMForm_Methods.prg
#Using System.IO
#Using System.Data
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Collections

PARTIAL CLASS BodyISMForm INHERIT DevExpress.XtraEditors.XtraForm
	EXPORT cReportUID AS STRING
	EXPORT cReportName AS STRING
	EXPORT cVesselName AS STRING
	EXPORT cShowText AS STRING
	PRIVATE cPreviousText := "" AS String

METHOD BodyISMForm_OnLoad() AS VOID
	oSoftway:ReadFormSettings_DevExpress(SELF, NULL, oMainForm:alForms, oMainForm:alData)

	LOCAL cEMail := "" AS STRING
	IF cShowText == NULL
		SELF:BodyISM:Text := oMainForm:ReadBodyISM(SELF:cReportUID, cEMail)
	ELSE
		SELF:BodyISM:Text := SELF:cShowText
		SELF:ButtonContent:Visible := FALSE
		SELF:ButtonSave:Visible := FALSE
	ENDIF		
RETURN


METHOD BodyISMForm_OnShown() AS VOID
	SELF:BodyISM:SelectionStart := SELF:BodyISM:Text:Length
	SELF:BodyISM:SelectionLength := 0
RETURN


METHOD Save() AS VOID
	IF QuestionBox("Do you want to replace the eMail body text with the current text ?", ;
					"Save") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	LOCAL cStatement, cText AS STRING
	cText := SELF:BodyISM:Text

	// System fields to upper
	LOCAL nPos AS INT

	nPos := cText:ToUpper():IndexOf("REPORTNAME")
	WHILE nPos <> -1
		cText := cText:Substring(0, nPos) + "REPORTNAME" + cText:Substring(nPos + "REPORTNAME":Length)
		nPos := cText:ToUpper():IndexOf("REPORTNAME", nPos + 1)
	ENDDO

	nPos := cText:ToUpper():IndexOf("VESSELNAME")
	WHILE nPos <> -1
		cText := cText:Substring(0, nPos) + "VESSELNAME" + cText:Substring(nPos + "VESSELNAME":Length)
		nPos := cText:ToUpper():IndexOf("VESSELNAME", nPos + 1)
	ENDDO

	nPos := cText:ToUpper():IndexOf("GMTDIFF")
	WHILE nPos <> -1
		cText := cText:Substring(0, nPos) + "GMTDIFF" + cText:Substring(nPos + "GMTDIFF":Length)
		nPos := cText:ToUpper():IndexOf("GMTDIFF", nPos + 1)
	ENDDO

	cStatement:="UPDATE FMBodyText SET BodyText='"+oSoftway:ConvertWildcards(cText, FALSE)+"'"+;
				" WHERE REPORT_UID="+SELF:cReportUID
	IF oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		InfoBox("eMail body text updated")
		SELF:Close()
	ENDIF
RETURN


METHOD CheckContent() AS VOID
	LOCAL cRet := SELF:ReplaceBodyTextFields(SELF:BodyISM:Text) AS STRING
	wb(cRet)
RETURN


METHOD ReplaceBodyTextFields(cBodyISM AS STRING) AS STRING
	IF cBodyISM == ""
		wb("No Body text specified")
		RETURN ""
	ENDIF

	LOCAL cRet := cBodyISM AS STRING
	LOCAL cItemNo AS STRING

	cRet := cRet:Replace("<REPORTNAME>", SELF:cReportName:ToUpper())
	cRet := cRet:Replace("<VESSELNAME>", SELF:cVesselName:ToUpper())

	//FOREACH oTabPage AS System.Windows.Forms.TabPage IN SELF:tabControl_Report:TabPages
	//	FOREACH oControl AS Control IN oTabPage:Controls
	//		cName := oControl:Name

	//		IF cName:StartsWith("Label")
	//			LOOP
	//		ENDIF
	//		IF cName:StartsWith("DatePickerGMT")
	//			LOOP
	//		ENDIF

	//		IF cName:StartsWith("NumericTextBoxGMT")
	//			LOCAL cGmtDiff := oControl:Text AS STRING
	//			IF ! cGmtDiff:StartsWith("-")
	//				cGmtDiff := "+" + cGmtDiff
	//			ENDIF
	//			cRet := cRet:Replace("GMTDIFF", cGmtDiff)
	//			LOOP
	//		ENDIF

	//		cItemUID := SELF:GetItemUID(cName)
	//		oRows := SELF:oDTReportItems:Select("ITEM_UID="+cItemUID)
	//		IF oRows:Length <> 1
	//			MessageBox.Show("Cannot locate ITEM_UID: "+cItemUID, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
	//			RETURN ""
	//		ENDIF
	//		cItemNo := oRows[1]:Item["ItemNo"]:ToString()
	//		SELF:ReplaceField(cItemNo, oControl)
	//	NEXT
	//
	//	SELF:CompileExpressions(cRet, "+")
	//NEXT

	LOCAL cStatement AS STRING
	cStatement:="SELECT ITEM_UID, ItemNo, ItemName, ItemType, Mandatory, CalculatedField, ExpDays,"+;
				" FMItemCategories.CATEGORY_UID, FMItemCategories.Description AS Category"+;
				" FROM FMReportItems"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMReportTypes ON FMReportTypes.REPORT_UID=FMReportItems.REPORT_UID"+;
				"	AND FMReportTypes.REPORT_UID="+SELF:cReportUID+;
				" LEFT OUTER JOIN FMItemCategories ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
				" ORDER BY ItemNo"
	LOCAL oDT:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	oDT:TableName:="Items"
	// Create Primary Key
	oSoftway:CreatePK(oDT, "ITEM_UID")

	cRet := cRet:Replace("<GMTDIFF>", "+3")

	FOREACH oRow AS DataRow IN oDT:Rows
		cItemNo := oRow:Item["ItemNo"]:ToString()
		SELF:ReplaceField(cRet, cItemNo, oRow)
	NEXT

	SELF:CompileExpressions(cRet, "+")
RETURN cRet


METHOD ReplaceField(cRet REF STRING, cItemNo AS STRING, oRow AS DataRow) AS VOID
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
		//cRet := cRet:Substring(0, nPos + 1) + "data" + cRet:Substring(nPos + 1 + cItemNo:Length)
		cRet := cRet:Substring(0, nPos + 1) + "data" + cRet:Substring(nPos + 1 + 2 + cItemNo:Length)
	ENDDO
RETURN


METHOD CompileExpressions(cRet REF STRING, cOper AS STRING) AS VOID
	//LOCAL cAmount, cValueText AS STRING
	LOCAL nPos, nPosEnd AS INT

	nPos := 0
	WHILE nPos <> -1
		nPos := cRet:IndexOf("<ID", nPos + 1)
		IF nPos == -1
			EXIT
		ENDIF
		nPosEnd := cRet:IndexOf(">", nPos + 1)
		IF nPos < nPosEnd
			//cValueText := cRet:Substring(nPos + 1, nPosEnd - nPos - 1)
			//IF cValueText:Contains(cOper)
			//	cAmount := SELF:CalculateExpression(cValueText)
			//ENDIF
			cRet := cRet:Substring(0, nPos) + "data" + cRet:Substring(nPosEnd + 1)
		ENDIF
	ENDDO
RETURN


METHOD CalculateExpression(cTermExpr AS STRING) AS STRING
	// 10 / 2 * 5
	LOCAL cLeft, cRight, cAmount AS STRING
	LOCAL nPos AS INT

	cTermExpr := cTermExpr:Replace(" ", "")

	// * or / ?
	//LOCAL nPosMul := cTermExpr:IndexOf("*") AS INT

	nPos := cTermExpr:IndexOf("*")
	WHILE nPos <> -1
		// Get left term
		cLeft := GetLeftNumber(cTermExpr, nPos - 1)

		// Get right term
		cRight := GetRightNumber(cTermExpr, nPos + 1)

		//cAmount := Math.Round(Convert.ToDouble(cLeft) * Convert.ToDouble(cRight), 2):ToString()
//wb("cLeft="+cLeft+CRLF+"cRight="+cRight, "*")
		cAmount := (Convert.ToDouble(cLeft) * Convert.ToDouble(cRight)):ToString()
//wb("cAmount="+cAmount+CRLF+"cLeft="+cLeft+CRLF+"cRight="+cRight+CRLF+"cTermExpr="+cTermExpr, "cTermExpr:IndexOf(*)")
		cTermExpr := cTermExpr:Replace(cLeft + "*" + cRight, cAmount)
		nPos := cTermExpr:IndexOf("*")
	ENDDO

	nPos := cTermExpr:IndexOf("/")
	WHILE nPos <> -1
		// Get left term
		cLeft := GetLeftNumber(cTermExpr, nPos - 1)

		// Get right term
		cRight := GetRightNumber(cTermExpr, nPos + 1)

		IF Convert.ToDouble(cRight) == 0
			cAmount := "0"
		ELSE
			cAmount := Math.Round(Convert.ToDouble(cLeft) / Convert.ToDouble(cRight), 2):ToString()
			//TRY
			//	cAmount := (Convert.ToDouble(cLeft) / Convert.ToDouble(cRight)):ToString()
			//CATCH e AS Exception
			//	ErrorBox(cLeft+" / "+cRight+CRLF+e:Message, "Divide error")
			//	cAmount := "0"
			//END TRY
		ENDIF

		//wb("cAmount="+cAmount+CRLF+"cLeft="+cLeft+CRLF+"cRight="+cRight+CRLF+"cTermExpr="+cTermExpr, "cTermExpr:IndexOf(/)")
		cTermExpr := cTermExpr:Replace(cLeft + "/" + cRight, cAmount)

		nPos := cTermExpr:IndexOf("/")
	ENDDO

	nPos := cTermExpr:IndexOf("+")
	WHILE nPos <> -1
		// Get left term
		cLeft := GetLeftNumber(cTermExpr, nPos - 1)

		// Get right term
		cRight := GetRightNumber(cTermExpr, nPos + 1)

		cAmount := (Convert.ToDouble(cLeft) + Convert.ToDouble(cRight)):ToString()

		//wb("cAmount="+cAmount+CRLF+"cLeft="+cLeft+CRLF+"cRight="+cRight+CRLF+"cTermExpr="+cTermExpr, "cTermExpr:IndexOf(+)")
		cTermExpr := cTermExpr:Replace(cLeft + "+" + cRight, cAmount)

		nPos := cTermExpr:IndexOf("+")
	ENDDO

	nPos := cTermExpr:IndexOf("-")
	WHILE nPos <> -1
		// Get left term
		cLeft := GetLeftNumber(cTermExpr, nPos - 1)

		// Get right term
		cRight := GetRightNumber(cTermExpr, nPos + 1)

		cAmount := (Convert.ToDouble(cLeft) - Convert.ToDouble(cRight)):ToString()

//wb("cAmount="+cAmount+CRLF+"cLeft="+cLeft+CRLF+"cRight="+cRight+CRLF+"cTermExpr="+cTermExpr, "cTermExpr:IndexOf(-)")
		cTermExpr := cTermExpr:Replace(cLeft + "-" + cRight, cAmount)

		nPos := cTermExpr:IndexOf("-")
		IF nPos == 0
			EXIT
		ENDIF
	ENDDO
//wb("cAmount="+cAmount+CRLF+"cLeft="+cLeft+CRLF+"cRight="+cRight+CRLF+"cTermExpr="+cTermExpr, "END")
RETURN cTermExpr


METHOD GetLeftNumber(cTermExpr AS STRING, nPos AS INT) AS STRING
	LOCAL cNum AS STRING
	LOCAL cByte AS STRING

	WHILE nPos <> -1
		cByte := cTermExpr:Substring(nPos, 1)
		IF ! oSoftway:StringIsNumeric(cByte, oMainForm:decimalSeparator+"-")
			EXIT
		ENDIF
		cNum := cByte + cNum
		nPos--
	ENDDO
RETURN cNum


METHOD GetRightNumber(cTermExpr AS STRING, nPos AS INT) AS STRING
	LOCAL cNum AS STRING
	LOCAL cByte AS STRING
	LOCAL nLen := cTermExpr:Length - 1 as INT

	WHILE nPos <= nLen
		cByte := cTermExpr:Substring(nPos, 1)
		IF ! oSoftway:StringIsNumeric(cByte, oMainForm:decimalSeparator+"-")
			EXIT
		ENDIF
		cNum += cByte
		nPos++
	ENDDO
RETURN cNum


PRIVATE METHOD ButtonShowNamesClick() AS System.Void

	
	if SELF:ButtonShowNames:Tag:ToString() == "0"
		cPreviousText := SELF:BodyISM:Text:Trim()
		LOCAL cBodyISM := SELF:BodyISM:Text:Trim()
		IF cBodyISM == ""
			wb("No Body text specified")
		ENDIF

		LOCAL cRet := cBodyISM AS STRING
		LOCAL cItemNo AS STRING

		cRet := cRet:Replace("<REPORTNAME>", SELF:cReportName:ToUpper())
		cRet := cRet:Replace("<VESSELNAME>", SELF:cVesselName:ToUpper())

		LOCAL cStatement AS STRING
		cStatement:="SELECT ITEM_UID, ItemNo, ItemName, ItemType, Mandatory, CalculatedField, ExpDays,"+;
					" FMItemCategories.CATEGORY_UID, FMItemCategories.Description AS Category"+;
					" FROM FMReportItems"+oMainForm:cNoLockTerm+;
					" INNER JOIN FMReportTypes ON FMReportTypes.REPORT_UID=FMReportItems.REPORT_UID"+;
					"	AND FMReportTypes.REPORT_UID="+SELF:cReportUID+;
					" LEFT OUTER JOIN FMItemCategories ON FMReportItems.CATEGORY_UID=FMItemCategories.CATEGORY_UID"+;
					" ORDER BY ItemNo"
		LOCAL oDT:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		oDT:TableName:="Items"
		// Create Primary Key
		oSoftway:CreatePK(oDT, "ITEM_UID")

		cRet := cRet:Replace("<GMTDIFF>", "+3")

		FOREACH oRow AS DataRow IN oDT:Rows
			cItemNo := oRow:Item["ItemNo"]:ToString()
			SELF:ReplaceFieldWithName(cRet, cItemNo, oRow)
			//SELF:CompileExpressionsWithName(cRet, "+",oRow:Item["ItemName"]:ToString():Trim())
		NEXT
		SELF:BodyISM:Text := cRet
		SELF:ButtonShowNames:Tag := 1
		SELF:ButtonShowNames:Text := "Show"+CRLF+"IDs"
	ELSE
		SELF:BodyISM:Text := cPreviousText
		SELF:ButtonShowNames:Tag := 0
		SELF:ButtonShowNames:Text := "Show"+CRLF+"Names"
	ENDIF	

RETURN

METHOD ReplaceFieldWithName(cRet REF STRING, cItemNo AS STRING, oRow AS DataRow) AS VOID
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
		//cRet := cRet:Substring(0, nPos + 1) + "data" + cRet:Substring(nPos + 1 + cItemNo:Length)
		cRet := cRet:Substring(0, nPos + 1) + oRow:Item["ItemName"]:ToString() + cRet:Substring(nPos + 1 + 2 + cItemNo:Length)
	ENDDO
RETURN


METHOD CompileExpressionsWithName(cRet REF STRING, cOper AS STRING, cName as String) AS VOID
	//LOCAL cAmount, cValueText AS STRING
	LOCAL nPos, nPosEnd AS INT

	nPos := 0
	WHILE nPos <> -1
		nPos := cRet:IndexOf("<ID", nPos + 1)
		IF nPos == -1
			EXIT
		ENDIF
		nPosEnd := cRet:IndexOf(">", nPos + 1)
		IF nPos < nPosEnd
			//cValueText := cRet:Substring(nPos + 1, nPosEnd - nPos - 1)
			//IF cValueText:Contains(cOper)
			//	cAmount := SELF:CalculateExpression(cValueText)
			//ENDIF
			cRet := cRet:Substring(0, nPos) + "data" + cRet:Substring(nPosEnd + 1)
		ENDIF
	ENDDO
RETURN


END CLASS
