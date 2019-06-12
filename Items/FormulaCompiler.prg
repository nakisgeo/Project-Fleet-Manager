// FormulaCompiler.prg
#Using System.Windows.Forms
#Using System.Drawing
#USING System.Data
#Using System.Collections
#Using DevExpress.XtraGrid.Views.Grid

CLASS FormulaCompiler
	PRIVATE GridViewItems AS DevExpress.XtraGrid.Views.Grid.GridView
	PRIVATE cValue AS STRING
	PRIVATE aTokens AS ArrayList

	//PRIVATE aFormulas, aValues AS ArrayList
	PRIVATE oReportTabForm AS ReportTabForm

CONSTRUCTOR(_GridViewItems AS DevExpress.XtraGrid.Views.Grid.GridView, _cValue AS STRING, _aTokens AS ArrayList)
	SELF:GridViewItems := _GridViewItems
	SELF:cValue := _cValue
	SELF:aTokens := _aTokens

	//aFormulas  := ArrayList{}
	//aValues := ArrayList{}
	//SELF:AddArrayListFormula(SELF:cValue, "0")
RETURN


CONSTRUCTOR(_oReportTabForm AS ReportTabForm)
	SELF:oReportTabForm := _oReportTabForm
RETURN


METHOD TokensChecked(cError REF STRING) AS LOGIC
	// GridViewItems EditMode: Check each Term in aTokens
	LOCAL cItemID AS STRING

	FOREACH cTerm AS STRING IN SELF:aTokens
		cTerm := cTerm:Replace("(", "")
		cTerm := cTerm:Replace(")", "")
		cTerm := cTerm:Trim()

		DO CASE
		CASE StringIsNumeric(cTerm)
			// Term is a number
			LOOP

		CASE cTerm:Length > 2 .AND. cTerm:StartsWith("ID")
			cItemID := cTerm:Substring(2):Trim()
			IF ! SELF:LocateItemID(cItemID)
				cError := cTerm+": ItemID="+cItemID+" not found"+CRLF+CRLF
				RETURN FALSE
			ENDIF
			// ItemID exists
			LOOP

		CASE cTerm == "PROPELLERPITCH"
			LOOP

		OTHERWISE
			cError := cTerm+": invalid term"+CRLF+CRLF
			RETURN FALSE
		ENDCASE
	NEXT
RETURN TRUE


METHOD ParseExpressionParenthesis(cExpression REF STRING, cValueText REF STRING, cError REF STRING) AS LOGIC
	// Priority: Parenthesis, *, /, +, -
	LOCAL cFormula := cExpression AS STRING

	// Find the first Right parenthesis
	LOCAL nPosRight := cExpression:IndexOf(")"), nPosLeft, n AS INT
	LOCAL cTerm, c, cParText, cAmount AS STRING
	//wb("cAmount="+cAmount+CRLF+"cExpression="+cExpression, "nPosRight="+nPosRight:ToString())
	WHILE nPosRight <> -1
		// Locate the left parenthesis
		cTerm := cExpression:Substring(0, nPosRight + 1)
		nPosLeft := -1
		FOR n := nPosRight DOWNTO 0
			c := cTerm:Substring(n, 1)
			IF c == "("
				nPosLeft := n
				EXIT
			ENDIF
		NEXT
		// Check the position of the found parentesis
		IF nPosLeft == -1
			cError := "Unbalanced parathesis"+CRLF+CRLF
			RETURN FALSE
		ENDIF

		cParText := cExpression:Substring(nPosLeft, nPosRight - nPosLeft + 1)

		cValueText := SELF:ReplaceExpressionTerms(cParText, cFormula)
		//wb("cValueText="+cValueText+CRLF+"cParText="+cParText, "End")
		IF cValueText == ""
			RETURN FALSE
		ENDIF

		// Calculate *, /
		// Calculate +, -
		cAmount := SELF:CalculateExpression(cValueText)

		// Remove cTerm
		cExpression := cExpression:Replace(cParText, cAmount):Trim()
		//wb("cAmount="+cAmount+CRLF+"cExpression="+cExpression+CRLF+"cParText="+cParText+CRLF+"cValueText="+cValueText, "Replace")

		// Find next Right parenthesis
		nPosRight := cExpression:IndexOf(")")
		//wb("cAmount="+cAmount+CRLF+"cExpression="+cExpression, "nPosRight="+nPosRight:ToString())
	ENDDO
	//wb("cExpression="+cExpression, "ParseExpressionParenthesis")
RETURN TRUE


METHOD ReplaceExpressionTerms(cParText AS STRING, cFormula AS STRING) AS STRING
	// Replace Expression terms with values
	LOCAL cValueText := "", cVariable, cByte, cAmount AS STRING
	LOCAL nChar, nLen := cParText:Length - 1 AS INT
	LOCAL cOper := "+-*/" AS STRING

//wb(cParText+CRLF+"nLen="+nLen:ToString(), "Start")
	FOR nChar:=0 UPTO nLen 
		cByte := cParText:Substring(nChar, 1)	//:ToUpper()

		DO CASE
		CASE cByte == " "
			cValueText += cByte
			LOOP

		CASE cByte == "("
			LOOP

		CASE cByte == ")"
			IF cVariable <> ""
				cAmount := SELF:GetSingleVariableAmount(cVariable, cFormula)
				IF cAmount == ""
				//wb(cValueText, "cByte == ) and cAmount == ''")
					RETURN ""
				ENDIF
				cValueText += cAmount
				//wb("cValueText="+cValueText, ")")
				cVariable := ""
			ENDIF
			//cValueText += cByte
			LOOP
		ENDCASE

		IF cOper:Contains(cByte)	// InListExact(cByte, "+", "-", "*", "/")
			IF cVariable <> ""
				cAmount := SELF:GetSingleVariableAmount(cVariable, cFormula)
				IF cAmount == ""
					RETURN ""
				ENDIF
				cValueText += cAmount
				cValueText += cByte
				//wb("cByte="+cByte+CRLF+"cValueText="+cValueText+CRLF+"cVariable="+cVariable+CRLF+"cAmount="+cAmount, "+-*/")
				cVariable := ""
			ENDIF
			//wb("cVariable="+cVariable+CRLF+"nChar="+nChar:ToString()+CRLF+"nLen="+nLen:ToString()+CRLF+"cParText:Substring(nChar + 1, 1) == '-'="+(cParText:Substring(nChar + 1, 1) == "-"):ToString()+CRLF+;
			//"cParText:Substring(nChar + 2, 1) == '-'="+(cParText:Substring(nChar + 2, 1) == "-"):ToString(), "+-*/")
			IF (nChar < nLen .AND. cParText:Substring(nChar + 1, 1) == "-" .OR. nChar + 1 < nLen .AND. cParText:Substring(nChar + 2, 1) == "-")
				LOCAL cLastByte := "" AS STRING
				cVariable := SELF:GetNegativeNumber(cParText, nChar, cLastByte)
				//	wb("cValueText="+cValueText+CRLF+"cVariable="+cVariable+CRLF+"Rem=|"+cParText:Substring(nChar):Replace(" ", "W")+"|"+CRLF+"nChar="+nChar:ToString(), "-")

				cAmount := SELF:GetSingleVariableAmount(cVariable, cFormula)
				IF cAmount == ""
				//wb(cValueText+CRLF+"cVariable="+cVariable, "cAmount == ")
					RETURN ""
				ENDIF
				cValueText += cAmount
				//wb("cByte="+cByte+CRLF+"cValueText="+cValueText+CRLF+"cVariable="+cVariable+CRLF+"cAmount="+cAmount, "-")
				cValueText += cLastByte
				cVariable := ""
			ENDIF
			LOOP
		ENDIF

		cVariable += cByte
	NEXT

	IF cVariable <> ""
		//wb("cVariable="+cVariable)
		cAmount := SELF:GetSingleVariableAmount(cVariable, cFormula)
		//wb(cValueText+CRLF+"cVariable="+cVariable+CRLF+"cAmount="+cAmount, "IF cVariable <> ''")
		IF cAmount == ""
			RETURN ""
		ENDIF
		cValueText += cAmount
		//wb("cValueText="+cValueText, "<> ''")
		cVariable := ""
	ENDIF
RETURN cValueText


METHOD GetNegativeNumber(cParText AS STRING, nChar REF INT, cLastByte REF STRING) AS STRING
	LOCAL cVariable := "" AS STRING

	LOCAL n, nLen := cParText:Length - 1 AS INT
	FOR n:=nChar + 1 UPTO nLen
		cLastByte := cParText:Substring(n, 1)	//:ToUpper()
		IF ! oSoftway:StringIsNumeric(cLastByte, oMainForm:decimalSeparator+" -")
			EXIT
		ENDIF
		cVariable += cLastByte
	NEXT
	cVariable := cVariable:Replace(" ", "")
	nChar := n - 1
RETURN cVariable


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
	LOCAL nLen := cTermExpr:Length - 1 AS INT

	WHILE nPos <= nLen
		cByte := cTermExpr:Substring(nPos, 1)
		IF ! oSoftway:StringIsNumeric(cByte, oMainForm:decimalSeparator+"-")
			EXIT
		ENDIF
		cNum += cByte
		nPos++
	ENDDO
RETURN cNum


METHOD GetSingleVariableAmount(cVariable AS STRING, cFormula AS STRING) AS STRING
	IF oSoftway:StringIsNumeric(cVariable, oMainForm:decimalSeparator+"-")
		RETURN cVariable
	ENDIF

	LOCAL cItemID := cVariable AS STRING
	IF cVariable:Length > 2 .AND. cVariable:StartsWith("ID")
		cItemID := cVariable:Substring(2):Trim()
	ENDIF

	LOCAL cAmount := SELF:GetItemIDValue(cItemID) AS STRING
RETURN cAmount

//	LOCAL nPos AS INT
//	nPos:=SELF:aFormulas:IndexOf(cItemID)
//	IF nPos == -1
//		SELF:LocateFormulaRow(cFormula)
//		ErrorBox("Variable ["+cItemID+"] not found into the Formula Table", cFormula)
//		//SELF:ShowFormulasArray()
//		RETURN ""
//	ENDIF
//	//wb(cTerm+"="+(string)Self:aValues[nPos], "nPos="+nPos:ToString())
//RETURN (STRING)SELF:aValues[nPos]


//METHOD AddArrayListFormula(cFormula AS STRING, cValue AS STRING) AS VOID
//	cFormula := cFormula:Replace(" ", "")
//	cFormula := cFormula:Trim()

//	IF cFormula == ""
//		RETURN
//	ENDIF

//	//cValue := cValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")
//	LOCAL nPos := SELF:aFormulas:IndexOf(cFormula) AS INT
//	IF nPos == -1
//		SELF:aFormulas:Add(cFormula)
//		SELF:aValues:Add(cValue)
//	ELSE
//		SELF:aValues[nPos] := cValue
//	ENDIF
//RETURN


//METHOD LocateFormulaRow(cFormula AS STRING) AS VOID
//	// Locate the row
//	LOCAL nFocusedHandle AS INT
//	nFocusedHandle := SELF:GridViewItems:LocateByValue(0, SELF:GridViewItems:Columns["ItemNo"], cFormula)
///*	// Use LocateByDisplayText() instead of LocateByValue() for INTEGER SQL columns
//	nFocusedHandle:=Self:GridViewCountries:LocateByDisplayText(0, Self:GridViewCountries:Columns["Country"], cCountry)*/
//	IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
//		RETURN
//	ENDIF
//	SELF:GridViewItems:ClearSelection()
//	SELF:GridViewItems:FocusedRowHandle:=nFocusedHandle
//	SELF:GridViewItems:SelectRow(nFocusedHandle)
//RETURN


METHOD LocateItemID(cItemID AS STRING) AS LOGIC
	// Locate the row
	LOCAL nHandle AS INT
	nHandle := SELF:GridViewItems:LocateByValue(0, SELF:GridViewItems:Columns["ItemNo"], cItemID)
/*	// Use LocateByDisplayText() instead of LocateByValue() for INTEGER SQL columns
	nHandle:=SELF:GridViewCountries:LocateByDisplayText(0, SELF:GridViewCountries:Columns["Country"], cCountry)*/
	IF nHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
		RETURN FALSE
	ENDIF
RETURN TRUE


//METHOD GetItemIDValue(cItemID AS STRING) AS STRING
//	// Locate the row
//	LOCAL nHandle AS INT
//	nHandle := SELF:GridViewItems:LocateByValue(0, SELF:GridViewItems:Columns["ItemNo"], cItemID)
///*	// Use LocateByDisplayText() instead of LocateByValue() for INTEGER SQL columns
//	nHandle:=Self:GridViewCountries:LocateByDisplayText(0, Self:GridViewCountries:Columns["Country"], cCountry)*/
//	IF nHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
//		RETURN ""
//	ENDIF
//RETURN "1000" //oRow:Item["ITEM_UID"]:ToString()


METHOD GetItemIDValue(cItemID AS STRING) AS STRING
	// Locate the row
	LOCAL cAmount := "0" AS string

	//wb(cItemID)
	IF cItemID:ToUpper() == "PROPELLERPITCH"
		cAmount := oMainForm:GetPropellerPitch()
		RETURN cAmount
	ENDIF

	LOCAL oRows := SELF:oReportTabForm:oDTReportItems:Select("REPORT_UID="+SELF:oReportTabForm:cReportUID+" AND ItemNo="+cItemID) AS DataRow[]
	IF oRows:Length <> 1
		RETURN cAmount
	ENDIF

	LOCAL cUID := oRows[1]:Item["ITEM_UID"]:ToString() AS STRING
	LOCAL oControl := SELF:oReportTabForm:GetControl("NumericTextBox", cUID) AS Control
	IF oControl <> NULL
		cAmount := oControl:Text
	ENDIF
//	LOCAL nHandle AS INT
//	nHandle := SELF:GridViewItems:LocateByValue(0, SELF:GridViewItems:Columns["ItemNo"], cItemID)
///*	// Use LocateByDisplayText() instead of LocateByValue() for INTEGER SQL columns
//	nHandle:=Self:GridViewCountries:LocateByDisplayText(0, Self:GridViewCountries:Columns["Country"], cCountry)*/
//	IF nHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
//		RETURN ""
//	ENDIF
RETURN cAmount //oRow:Item["ITEM_UID"]:ToString()


END CLASS
