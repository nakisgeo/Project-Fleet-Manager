// ReportDefinitionForm_Compiler.prg
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Collections
#Using System.Collections.Generic
#Using DevExpress.XtraGrid.Views.Grid
#Using DevExpress.XtraGrid.Views.Grid.ViewInfo
#using DevExpress.XtraGrid.Columns

#using DevExpress.XtraPrinting
#Using DevExpress.XtraPrintingLinks
#Using DevExpress.XtraReports
#Using DevExpress.XtraReports.UI

PARTIAL CLASS ReportDefinitionForm INHERIT DevExpress.XtraEditors.XtraForm
	// aValues contains the Decimal amounts as strings (default format 99999.99)
	PRIVATE aFormulas, aValues AS ArrayList
	//PRIVATE aSingeFormulas AS ArrayList

	EXPORT oLBCItemVoyage AS MyLBCVoyageItem
	EXPORT oLBCItemRouting AS MyLBCVoyageItem

	EXPORT dDateFromVoyageGMT := DateTime.MinValue AS DateTime
	EXPORT dDateToVoyageGMT := DateTime.MaxValue AS DateTime
	EXPORT dDateFromRoutingGMT := DateTime.MinValue AS DateTime
	EXPORT dDateToRoutingGMT := DateTime.MaxValue AS DateTime

	EXPORT dDateFromVoyage := DateTime.MinValue AS DateTime
	EXPORT dDateToVoyage := DateTime.MaxValue AS DateTime
	EXPORT dDateFromRouting := DateTime.MinValue AS DateTime
	EXPORT dDateToRouting := DateTime.MaxValue AS DateTime

METHOD CheckAllFormulas() AS LOGIC
	LOCAL cStatement, cFormula, cFormulaUpper, cID, cCustomItemUnit, cError := "" AS STRING

	// Get GridView DataTable:
	//LOCAL oDT := ((DataView)SELF:GridViewFormulas:DataSource):ToTable() AS DataTable

	cStatement:="SELECT FMReportFormulas.ID, FMReportFormulas.Formula, FMReportItems.Unit AS ItemUnit, FMCustomItems.Unit AS CustomItemUnit"+;
				" FROM FMReportFormulas"+;
				" LEFT OUTER JOIN FMReportItems ON FMReportItems.ItemNo=FMReportFormulas.ID"+;
				" LEFT OUTER JOIN FMCustomItems ON FMCustomItems.ID=FMReportFormulas.ID"+;
				" WHERE FMReportFormulas.REPORT_UID="+SELF:GetSelectedReportDefinition("cUID")+;
				" ORDER BY LineNum"
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

	//SELF:aSingeFormulas := ArrayList{}

	TRY
		FOREACH oRow AS DataRow IN oDT:Rows
			cFormula := oRow:Item["Formula"]:ToString():Trim()
			IF cFormula == ""
				LOOP
			ENDIF

			cFormulaUpper := cFormula:ToUpper()

			cID := oRow:Item["ID"]:ToString()
			cCustomItemUnit := oRow:Item["CustomItemUnit"]:ToString():ToUpper()

			DO CASE
			CASE cFormulaUpper:Contains("(") .AND. !cFormulaUpper:Contains(")") ;
				.OR. cFormulaUpper:Contains(")") .AND. ! cFormulaUpper:Contains("(")
				ErrorBox("Unbalanced parenthesis found into the Folmula: "+cFormula, "Invalid Formula")
				BREAK

			CASE cID == CustomItems.TCEquivalentUSD_ID
				IF cFormulaUpper:Contains("(FIRST)") .OR. cFormulaUpper:Contains("(LAST)") .OR. cFormulaUpper:Contains("(AVG)")  .OR. cFormulaUpper:Contains("(SUM)") ;
					.OR. cFormulaUpper:Contains("+") .OR. cFormulaUpper:Contains("-") .OR. cFormulaUpper:Contains("*") .OR. cFormulaUpper:Contains("/") .OR. cFormulaUpper:Contains("=")
					cError := "Functions and/or Operators are not allowed for the selected Item"
					BREAK
				ENDIF

			CASE cCustomItemUnit == "TEXT" .OR. cCustomItemUnit == "DATE"
				cError := "Formula is not allowed for the selected Item"
				BREAK

			CASE cFormulaUpper:Contains("(FIRST)")
				IF cFormulaUpper:Contains("(LAST)") .OR. cFormulaUpper:Contains("(AVG)") .OR. cFormulaUpper:Contains("(SUM)") 
					cError := "One Function is not allowed per Formula"
					BREAK
				ENDIF
				IF cFormulaUpper:Contains("+") .OR. cFormulaUpper:Contains("-") .OR. cFormulaUpper:Contains("*") .OR. cFormulaUpper:Contains("/")
					cError := "Cannot mix Function and Operators into a Function Formula"
					BREAK
				ENDIF
				cFormulaUpper:=cFormulaUpper:Replace("(FIRST)", "")

			CASE cFormulaUpper:Contains("(LAST)")
				IF cFormulaUpper:Contains("(FIRST)") .OR. cFormulaUpper:Contains("(AVG)") .OR. cFormulaUpper:Contains("(SUM)") 
					cError := "One Function is not allowed per Formula"
					BREAK
				ENDIF
				IF cFormulaUpper:Contains("+") .OR. cFormulaUpper:Contains("-") .OR. cFormulaUpper:Contains("*") .OR. cFormulaUpper:Contains("/")
					cError := "Cannot mix Function and Operators into a Function Formula"
					BREAK
				ENDIF
				cFormulaUpper:=cFormulaUpper:Replace("(LAST)", "")

			CASE cFormulaUpper:Contains("(AVG)")
				IF cFormulaUpper:Contains("(FIRST)") .OR. cFormulaUpper:Contains("(LAST)") .OR. cFormulaUpper:Contains("(SUM)") 
					cError := "One Function is not allowed per Formula"
					BREAK
				ENDIF
				IF cFormulaUpper:Contains("+") .OR. cFormulaUpper:Contains("-") .OR. cFormulaUpper:Contains("*") .OR. cFormulaUpper:Contains("/")
					cError := "Cannot mix Function and Operators into a Function Formula"
					BREAK
				ENDIF
				cFormulaUpper:=cFormulaUpper:Replace("(AVG)", "")

			CASE cFormulaUpper:Contains("(SUM)")
				IF cFormulaUpper:Contains("(FIRST)") .OR. cFormulaUpper:Contains("(LAST)") .OR. cFormulaUpper:Contains("(AVG)") 
					cError := "One Function is not allowed per Formula"
					BREAK
				ENDIF
				IF cFormulaUpper:Contains("+") .OR. cFormulaUpper:Contains("-") .OR. cFormulaUpper:Contains("*") .OR. cFormulaUpper:Contains("/")
					cError := "Cannot mix Function and Operators into a Function Formula"
					BREAK
				ENDIF
				cFormulaUpper:=cFormulaUpper:Replace("(SUM)", "")

			CASE cFormulaUpper:Contains("=") //.or. cFormulaUpper:Contains("+") .or. cFormulaUpper:Contains("-") .or. cFormulaUpper:Contains("*") .or. cFormulaUpper:Contains("/")
				// Put left formula side to array
				cFormulaUpper := cFormulaUpper:Substring(0, cFormulaUpper:IndexOf("="))	//:ToUpper()

			CASE cFormulaUpper:Contains("+") .OR. cFormulaUpper:Contains("-") .OR. cFormulaUpper:Contains("*") .OR. cFormulaUpper:Contains("/")
				LOOP
			ENDCASE

			cFormulaUpper := cFormulaUpper:Trim():TrimEnd('='):Trim()
			IF cFormulaUpper <> ""
				IF SELF:aFormulas:IndexOf(cFormulaUpper) <> -1
					//wb("Check: "+cFormulaUpper)
					cError := "Duplicated Formula"
					BREAK
				ENDIF

				//SELF:aSingeFormulas:Add(cFormulaUpper)
				SELF:AddArrayListFormula(cFormulaUpper, "0")
				//SELF:ShowFormulasArray()
			ENDIF
		NEXT
	CATCH
		SELF:LocateFormulaRow(cFormula)
		ErrorBox(cError+CRLF+"Formula: "+cFormula, "Invalid Formula")
		RETURN FALSE
	END TRY
RETURN TRUE


/*METHOD FormatNumericValues() AS VOID
	LOCAL cStatement, cValue AS STRING

	cStatement:="SELECT FORMULA_UID, Amount FROM FMReportPresentation"
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	FOREACH oRow AS DataRow IN oDT:Rows
		LOCAL oldCI AS System.Globalization.CultureInfo
		oldCI := System.Threading.Thread.CurrentThread:CurrentCulture

		cValue := oRow["Amount"]:ToString()
		IF cValue <> ""
			LOCAL nValue := Convert.ToDecimal(cValue) AS Decimal
			cValue := STRING.Format(oldCI, "{0:N}", nValue)
			cStatement:="UPDATE FMReportPresentation SET Amount="+cValue+;
						" WHERE FORMULA_UID="+oRow["FORMULA_UID"]:ToString()
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ENDIF
	NEXT
RETURN*/


METHOD AddArrayListFormula(cFormula AS STRING, cValue AS STRING) AS VOID
	cFormula := cFormula:Replace(" ", "")
	cFormula := cFormula:Trim()

	IF cFormula == ""
		RETURN
	ENDIF

	//cValue := cValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")

	LOCAL nPos := SELF:aFormulas:IndexOf(cFormula) AS INT
	IF nPos == -1
		SELF:aFormulas:Add(cFormula)
		SELF:aValues:Add(cValue)
	ELSE
		SELF:aValues[nPos] := cValue
	ENDIF
RETURN


METHOD ShowFormulasArray() AS LOGIC
	LOCAL cStr AS STRING

	//FOREACH cFormula AS STRING IN SELF:aFormulas
	LOCAL n, nLen := SELF:aFormulas:Count - 1 AS INT
	FOR n:=0 UPTO nLen
		cStr += SELF:aFormulas[n]:ToString()+"="+SELF:aValues[n]:ToString()+CRLF
	NEXT
	WB(cStr, "aFormulas")
RETURN TRUE


METHOD CompileSingleFormulas(oSelectVoyageForm AS SelectVoyageForm) AS LOGIC
	LOCAL cStatement, cFormula, cID, cCustomItemUnit, cTextValue, cDecimalValue, cSavedFormula AS STRING
	LOCAL oDTFormulas AS DataTable
	LOCAL n, nCount, nEmpty AS INT
	LOCAL nAmount AS Decimal
	LOCAL cAmount AS STRING

	// Single variables
	cStatement:="SELECT FMReportFormulas.*, FMReportItems.Unit AS ItemUnit, FMCustomItems.Unit AS CustomItemUnit"+;
				" FROM FMReportFormulas"+;
				" LEFT OUTER JOIN FMReportItems ON FMReportItems.ItemNo=FMReportFormulas.ID"+;
				" LEFT OUTER JOIN FMCustomItems ON FMCustomItems.ID=FMReportFormulas.ID"+;
				" WHERE FMReportFormulas.REPORT_UID="+SELF:GetSelectedReportDefinition("cUID")+;
				" AND Formula NOT LIKE '%+%' AND Formula NOT LIKE '%-%' AND Formula NOT LIKE '%*%' AND Formula NOT LIKE '%/%'"+;
				" ORDER BY LineNum"
	oDTFormulas:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	//IF ! SELF:CheckSingleFormulas(oDTFormulas)
	//	RETURN FALSE
	//ENDIF

	nCount:=oDTFormulas:Rows:Count - 1
	FOR n:=0 UPTO nCount
		cID := oDTFormulas:Rows[n]:Item["ID"]:ToString()
		cFormula := oDTFormulas:Rows[n]:Item["Formula"]:ToString():Trim():ToUpper()
		cSavedFormula := oDTFormulas:Rows[n]:Item["Description"]:ToString()+": "+cFormula
		//cItemUnit := oDTFormulas:Rows[n]:Item["ItemUnit"]:ToString():ToUpper()
		cCustomItemUnit := oDTFormulas:Rows[n]:Item["CustomItemUnit"]:ToString():ToUpper()
		IF cID == "" .AND. cFormula == ""
			nEmpty++
			LOOP
		ENDIF
		/*DO CASE
			CASE cFormula:Contains("(DEBIT)")
				// Select Debit
				cFormula:=cFormula:Replace("(DEBIT)", "")
				cSum:="SUM(SHTrans.BVDebit)"
			CASE cFormula:Contains("(CREDIT)")
				// Select Credit
				cFormula:=cFormula:Replace("(CREDIT)", "")
				cSum:="SUM(SHTrans.BVCredit)"
			OTHERWISE
				// Select Amount
				cFormula:=cFormula:Replace("(BALANCE)", "")
				cSum:="SUM(SHTrans.BVDebit) - SUM(SHTrans.BVCredit) "
		ENDCASE
		cStatement:="SELECT "+cSum+" AS nAmount"+;
					" FROM SHVouchers"+" AS SHVouchers"+;
					" INNER JOIN SHTrans"+" AS SHTrans ON SHVouchers.VOUCHER_UID=SHTrans.VOUCHER_UID"+;
					" AND SHTrans.AccCode LIKE '"+cID+"%'"+;
					" AND SHVouchers.VoucherDate >= '"+cDateFrom+"' AND SHVouchers.VoucherDate <= '"+cDateTo+"'"+;
					" AND SHTrans.CompCode IN (SELF:cCompCodes)"*/

		cTextValue := ""
		cDecimalValue := "NULL"

		LOCAL cItemType := oMainForm:GetItemType(cID) AS STRING

		DO CASE
		CASE cCustomItemUnit == "TEXT" .OR. cCustomItemUnit == "DATE"
			// Insert [FMReportPresentation]
			cTextValue := SELF:GetCustomItemValue(oDTFormulas:Rows[n]:Item["ID"]:ToString(), cCustomItemUnit, oSelectVoyageForm, cDecimalValue)

			SELF:AddArrayListFormula(cFormula, cTextValue)

			cStatement:="INSERT INTO FMReportPresentation (FORMULA_UID, UserID, TextField, Amount) VALUES"+;
							" ("+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+","+;
							"'"+oUser:UserID+"',"+;
							"'"+cTextValue+"',"+;
							cDecimalValue+")"
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			LOOP

		CASE cID == CustomItems.TCEquivalentUSD_ID
			// Insert [FMReportPresentation]
			cDecimalValue := SELF:oLBCItemRouting:oRow["TCEquivalentUSD"]:ToString()
			IF cDecimalValue == ""
				cDecimalValue := "0.00"
			ENDIF

			SELF:AddArrayListFormula(cFormula, cDecimalValue)

			cStatement:="INSERT INTO FMReportPresentation (FORMULA_UID, UserID, TextField, Amount) VALUES"+;
							" ("+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+","+;
							"'"+oUser:UserID+"',"+;
							"'"+cTextValue+"',"+;
							cDecimalValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")+")"
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			LOOP

		CASE cID == CustomItems.RoutingPriceFOPerTon_ID
			// Insert [FMReportPresentation]
			cDecimalValue := SELF:oLBCItemRouting:oRow["FOPriceUSD"]:ToString()
			IF cDecimalValue == ""
				cDecimalValue := "0.00"
			ENDIF

			SELF:AddArrayListFormula(cFormula, cDecimalValue)

			cStatement:="INSERT INTO FMReportPresentation (FORMULA_UID, UserID, TextField, Amount) VALUES"+;
							" ("+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+","+;
							"'"+oUser:UserID+"',"+;
							"'"+cTextValue+"',"+;
							cDecimalValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")+")"
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			LOOP

		CASE cID == CustomItems.RoutingOnSailingFOROB_ID
			// Insert [FMReportPresentation]
			cDecimalValue := SELF:oLBCItemRouting:oRow["RoutingROB_FO"]:ToString()
			IF cDecimalValue == ""
				cDecimalValue := "0.00"
			ENDIF
			cDecimalValue := Math.Round(Convert.ToDecimal(cDecimalValue) / 1000, 2):ToString()

			SELF:AddArrayListFormula(cFormula, cDecimalValue)
			cStatement:="INSERT INTO FMReportPresentation (FORMULA_UID, UserID, TextField, Amount) VALUES"+;
							" ("+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+","+;
							"'"+oUser:UserID+"',"+;
							"'"+cTextValue+"',"+;
							cDecimalValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")+")"
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			LOOP

		CASE cID == CustomItems.RoutingDaysSinceSailing_ID
			// Insert [FMReportPresentation]
			cDecimalValue := SELF:GetRoutingDaysSinceSailing(oSelectVoyageForm):ToString()
			SELF:AddArrayListFormula(cFormula, cDecimalValue)

			cStatement:="INSERT INTO FMReportPresentation (FORMULA_UID, UserID, TextField, Amount) VALUES"+;
							"("+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+","+;
							"'"+oUser:UserID+"',"+;
							"'"+cTextValue+"',"+;
							cDecimalValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")+")"
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			LOOP

		//CASE cID == CustomItems.RoutingMilesAlreadyTravelled_ID
		//	// Insert [FMReportPresentation]
		//	cDecimalValue := SELF:GetRoutingMilesAlreadyTravelled(oSelectVoyageForm):ToString()
		//	SELF:AddArrayListFormula(cFormula, cDecimalValue)

		//	cStatement:="INSERT INTO FMReportPresentation (FORMULA_UID, UserID, TextField, Amount) VALUES"+;
		//					"("+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+","+;
		//					"'"+oUser:UserID+"',"+;
		//					"'"+cTextValue+"',"+;
		//					cDecimalValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")+")"
		//	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		//	LOOP

		//CASE cID == CustomItems.RoutingMilesSailedToday_ID
		//	// Insert [FMReportPresentation]
		//	cDecimalValue := SELF:GetRoutingMilesTravelledToday(oSelectVoyageForm):ToString()
		//	SELF:AddArrayListFormula(cFormula, cDecimalValue)

		//	cStatement:="INSERT INTO FMReportPresentation (FORMULA_UID, UserID, TextField, Amount) VALUES"+;
		//					"("+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+","+;
		//					"'"+oUser:UserID+"',"+;
		//					"'"+cTextValue+"',"+;
		//					cDecimalValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")+")"
		//	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		//	LOOP

		//CASE cID == CustomItems.RoutingConsumption_ID
		//	// nConsumption := nAccumulatedFuelMass - nAccumulatedFuelMassStart
		//	LOCAL dStartDate, dEndDate AS DateTime

		//	SELF:GetCustomItemDateValues(TRUE, TRUE, oSelectVoyageForm, dStartDate, dEndDate)

		//	IF dStartDate == DateTime.MinValue
		//		LOOP
		//	ENDIF

		//	IF dEndDate == Datetime.MaxValue
		//		// Voyage is open
		//		LOCAL cLastShipsDataDateTime := oMainForm:LBCPackages:GetItemText(oMainForm:LBCPackages:SelectedIndex) AS STRING
		//		IF cLastShipsDataDateTime == ""
		//			cLastShipsDataDateTime := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC):ToString("dd/MM/yyyy HH:mm:ss")
		//		ENDIF
		//		dEndDate := DateTime.Parse(cLastShipsDataDateTime)
		//	ENDIF

		//	LOCAL nAccumulatedFuelMass, nAccumulatedFuelMassStart AS Double
		//	nAccumulatedFuelMassStart := oMainForm:GetAccumulatedFuelMassStart(dStartDate, oMainForm:CheckedLBCVessels:SelectedValue:ToString())
		//	nAccumulatedFuelMass := oMainForm:GetAccumulatedFuelMass("FMDataPackages.TDate <= '"+dEndDate:ToString("yyyy-MM-dd HH:mm:ss")+"'", oMainForm:CheckedLBCVessels:SelectedValue:ToString(), nAccumulatedFuelMassStart)

		//	LOCAL nConsumption := nAccumulatedFuelMass - nAccumulatedFuelMassStart AS Double

		//	LOCAL nVoyageCons_DG AS Double
		//	LOCAL nMilesTravelled := SELF:GetRoutingMilesAlreadyTravelled(oSelectVoyageForm) AS Double
		//	LOCAL nDaysSinceSailing := SELF:GetRoutingDaysSinceSailing(oSelectVoyageForm) AS Decimal
		//	IF nConsumption < 0
		//		nConsumption := 0
		//	ELSE
		//		IF nMilesTravelled == 0
		//			nConsumption := 0
		//		ELSE
		//			// + DG:
		//			nVoyageCons_DG := (Double)nDaysSinceSailing * SELF:GetKgPerDay_DG()
		//			nConsumption := Math.Round((nConsumption + nVoyageCons_DG) / nMilesTravelled, 2)
		//		ENDIF
		//	ENDIF

		//	cDecimalValue := nConsumption:ToString()
		//	SELF:AddArrayListFormula(cFormula, cDecimalValue)

		//	cStatement:="INSERT INTO FMReportPresentation (FORMULA_UID, UserID, TextField, Amount) VALUES"+;
		//					"("+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+","+;
		//					"'"+oUser:UserID+"',"+;
		//					"'"+cTextValue+"',"+;
		//					cDecimalValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")+")"
		//	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		//	LOOP

		//CASE cID == CustomItems.RoutingActualFOROB_ID
		//	// nVoyageCons_DG := (Double)nDaysSinceSailing * SELF:KgPerDay_DG
		//	// "Actual FO ROB: "+Math.Round((SELF:RoutingROB_FO - (nAccumulatedFuelMass - nAccumulatedFuelMassStart) - nVoyageCons_DG), 2):ToString("N2")
		//	LOCAL nVoyageCons_DG AS Double
		//	LOCAL nDaysSinceSailing := SELF:GetRoutingDaysSinceSailing(oSelectVoyageForm) AS Decimal
		//	nVoyageCons_DG := (Double)nDaysSinceSailing * SELF:GetKgPerDay_DG()
			
		//	LOCAL cRoutingFOROB := SELF:oLBCItemRouting:oRow["RoutingROB_FO"]:ToString() AS STRING
		//	IF cRoutingFOROB == ""
		//		cRoutingFOROB := "0.00"
		//	ENDIF
		//	LOCAL nRoutingROB_FO := Convert.ToDouble(cRoutingFOROB) AS Double

		//	LOCAL dStartDate, dEndDate AS DateTime

		//	SELF:GetCustomItemDateValues(TRUE, TRUE, oSelectVoyageForm, dStartDate, dEndDate)

		//	IF dStartDate == DateTime.MinValue
		//		LOOP
		//	ENDIF

		//	IF dEndDate == Datetime.MaxValue
		//		// Voyage is open
		//		LOCAL cLastShipsDataDateTime := oMainForm:LBCPackages:GetItemText(oMainForm:LBCPackages:SelectedIndex) AS STRING
		//		IF cLastShipsDataDateTime == ""
		//			cLastShipsDataDateTime := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC):ToString("dd/MM/yyyy HH:mm:ss")
		//		ENDIF
		//		dEndDate := DateTime.Parse(cLastShipsDataDateTime)
		//	ENDIF

		//	LOCAL nAccumulatedFuelMass, nAccumulatedFuelMassStart AS Double
		//	nAccumulatedFuelMassStart := oMainForm:GetAccumulatedFuelMassStart(dStartDate, oMainForm:CheckedLBCVessels:SelectedValue:ToString())
		//	nAccumulatedFuelMass := oMainForm:GetAccumulatedFuelMass("FMDataPackages.TDate <= '"+dEndDate:ToString("yyyy-MM-dd HH:mm:ss")+"'", oMainForm:CheckedLBCVessels:SelectedValue:ToString(), nAccumulatedFuelMassStart)

		//	LOCAL nActualFOROB AS Double
		//	nActualFOROB := Math.Round((nRoutingROB_FO - (nAccumulatedFuelMass - nAccumulatedFuelMassStart) - nVoyageCons_DG), 2)

		//	cDecimalValue := Math.Round(nActualFOROB / 1000, 2):ToString()
		//	SELF:AddArrayListFormula(cFormula, cDecimalValue)

		//	cStatement:="INSERT INTO FMReportPresentation (FORMULA_UID, UserID, TextField, Amount) VALUES"+;
		//					"("+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+","+;
		//					"'"+oUser:UserID+"',"+;
		//					"'"+cTextValue+"',"+;
		//					cDecimalValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")+")"
		//	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		//	LOOP

		//CASE cID == CustomItems.RoutingTimeCost_ID
		//	LOCAL nTimeCostNow := SELF:CalculateTimeCost(oSelectVoyageForm) AS Double

		//	cDecimalValue := nTimeCostNow:ToString()
		//	SELF:AddArrayListFormula(cFormula, cDecimalValue)

		//	cStatement:="INSERT INTO FMReportPresentation (FORMULA_UID, UserID, TextField, Amount) VALUES"+;
		//					"("+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+","+;
		//					"'"+oUser:UserID+"',"+;
		//					"'"+cTextValue+"',"+;
		//					cDecimalValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")+")"
		//	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		//	LOOP

		//CASE cID == CustomItems.RoutingFuelCost_ID
		//	LOCAL nFuelCostNow := SELF:CalculateFuelCost(oSelectVoyageForm) AS Double

		//	cDecimalValue := nFuelCostNow:ToString()
		//	SELF:AddArrayListFormula(cFormula, cDecimalValue)

		//	cStatement:="INSERT INTO FMReportPresentation (FORMULA_UID, UserID, TextField, Amount) VALUES"+;
		//					"("+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+","+;
		//					"'"+oUser:UserID+"',"+;
		//					"'"+cTextValue+"',"+;
		//					cDecimalValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")+")"
		//	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		//	LOOP

		//CASE cID == CustomItems.RoutingTotalCost_ID
		//	// Time cost
		//	LOCAL nTimeCostNow := SELF:CalculateTimeCost(oSelectVoyageForm) AS Double

		//	// Fuel cost
		//	LOCAL nFuelCostNow := SELF:CalculateFuelCost(oSelectVoyageForm) AS Double

		//	cDecimalValue := (nTimeCostNow + nFuelCostNow):ToString()
		//	SELF:AddArrayListFormula(cFormula, cDecimalValue)

		//	cStatement:="INSERT INTO FMReportPresentation (FORMULA_UID, UserID, TextField, Amount) VALUES"+;
		//					"("+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+","+;
		//					"'"+oUser:UserID+"',"+;
		//					"'"+cTextValue+"',"+;
		//					cDecimalValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")+")"
		//	oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		//	LOOP

		CASE cID == CustomItems.VoyageDGConPerDay_ID
			cDecimalValue := SELF:GetKgPerDay_DG():ToString()
			SELF:AddArrayListFormula(cFormula, cDecimalValue)

			cStatement:="INSERT INTO FMReportPresentation (FORMULA_UID, UserID, TextField, Amount) VALUES"+;
							"("+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+","+;
							"'"+oUser:UserID+"',"+;
							"'"+cTextValue+"',"+;
							cDecimalValue:Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")+")"
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			LOOP

		CASE cID == CustomItems.VoyageDaysSinceSailing_ID
			wb(CustomItems.VoyageDaysSinceSailing_Text+" not yet implemented")
			LOOP

		CASE cID == CustomItems.VoyageConsumption_ID
			wb(CustomItems.VoyageConsumption_Text+" not yet implemented")
			LOOP

		CASE cID == CustomItems.VoyageMilesAlreadyTravelled_ID
			wb(CustomItems.VoyageMilesAlreadyTravelled_Text+" not yet implemented")
			LOOP

		CASE cID == "0"
			LOOP

		CASE cFormula:Contains("(FIRST)")
			// Select First
			cFormula:=cFormula:Replace("(FIRST)", ""):Trim()
			cStatement:="SELECT FMData.Data"+;
						" FROM FMData"+oMainForm:cNoLockTerm+;
						" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
						"	AND FMDataPackages.VESSEL_UNIQUEID="+oMainForm:GetVesselUID+;
						" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
						" WHERE FMReportItems.ItemNo = "+cID+;
						" AND FMDataPackages.DateTimeGMT BETWEEN '"+SELF:dDateFromRoutingGMT:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+SELF:dDateToRoutingGMT:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
						" ORDER BY FMDataPackages.DateTimeGMT"
			cStatement := oSoftway:SelectTop(cStatement)

		CASE cFormula:Contains("(LAST)")
			// Select Last
			cFormula:=cFormula:Replace("(LAST)", ""):Trim()
			cStatement:="SELECT FMData.Data"+;
						" FROM FMData"+oMainForm:cNoLockTerm+;
						" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
						"	AND FMDataPackages.VESSEL_UNIQUEID="+oMainForm:GetVesselUID+;
						" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
						" WHERE FMReportItems.ItemNo = "+cID+;
						" AND FMDataPackages.DateTimeGMT BETWEEN '"+SELF:dDateFromRoutingGMT:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+SELF:dDateToRoutingGMT:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
						" ORDER BY FMDataPackages.DateTimeGMT DESC"
			cStatement := oSoftway:SelectTop(cStatement)

		CASE cFormula:Contains("(AVG)")
			// Select Avg
			cFormula:=cFormula:Replace("(AVG)", ""):Trim()
			//LOCAL cActualFOConsumptionTerm:=" AND FMDataPackages.PACKAGE_UID IN"+;
			//								" (SELECT FMDataPackages_1.PACKAGE_UID FROM FMDataPackages AS FMDataPackages_1"+;
			//								" INNER JOIN FMData AS FMData_1 ON FMDataPackages_1.PACKAGE_UID = FMData_1.PACKAGE_UID"+;
			//								" AND FMDataPackages_1.VESSEL_UNIQUEID = "+oMainForm:CheckedLBCVessels:SelectedValue:ToString()+" AND FMData_1.ItemNo = 23 AND FMData_1.Data <> 0"+;
			//								" AND FMDataPackages_1.DateTimeGMT BETWEEN '"+SELF:dDateFromRoutingGMT:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+dDateToRoutingGMT:ToString("yyyy-MM-dd HH:mm:ss")+"')" AS STRING
			cStatement:="SELECT Avg(CAST(FMData.Data AS Decimal)) AS Data"+;
						" FROM FMData"+oMainForm:cNoLockTerm+;
						" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
						"	AND FMDataPackages.VESSEL_UNIQUEID="+oMainForm:GetVesselUID+;
						" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
						" WHERE FMReportItems.ItemNo = "+cID+;
						" AND FMDataPackages.DateTimeGMT BETWEEN '"+SELF:dDateFromRoutingGMT:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+SELF:dDateToRoutingGMT:ToString("yyyy-MM-dd HH:mm:ss")+"'"	//+;
						//Iif(cID <> "23", cActualFOConsumptionTerm, "")

		CASE cFormula:Contains("(SUM)")
			// Select Sum
			cFormula:=cFormula:Replace("(SUM)", ""):Trim()
			cStatement:="SELECT Sum(CAST(FMData.Data AS Decimal)) AS Data"+;
						" FROM FMData"+oMainForm:cNoLockTerm+;
						" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
						"	AND FMDataPackages.VESSEL_UNIQUEID="+oMainForm:GetVesselUID+;
						" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
						" WHERE FMReportItems.ItemNo = "+cID+;
						" AND FMDataPackages.DateTimeGMT BETWEEN '"+SELF:dDateFromRoutingGMT:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+SELF:dDateToRoutingGMT:ToString("yyyy-MM-dd HH:mm:ss")+"'"	//+;
		OTHERWISE
			// Last Item:
			cStatement:="SELECT FMData.Data"+;
						" FROM FMData"+oMainForm:cNoLockTerm+;
						" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
						"	AND FMDataPackages.VESSEL_UNIQUEID="+oMainForm:GetVesselUID+;
						" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
						" WHERE FMReportItems.ItemNo = "+cID+;
						" AND FMDataPackages.DateTimeGMT BETWEEN '"+SELF:dDateFromRoutingGMT:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+SELF:dDateToRoutingGMT:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
						" ORDER BY FMDataPackages.DateTimeGMT DESC"
			cStatement := oSoftway:SelectTop(cStatement)
		ENDCASE
//MemoWrit(cTempDocDir+"\st.TXT", cStatement)

		TRY
			cAmount:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Data")
		CATCH e AS Exception
			ErrorBox(cSavedFormula+CRLF+CRLF+e:Message, "Error in Formula")
			cAmount := ""
		END TRY

		DO CASE
		CASE cItemType == "N"
			IF cAmount == ""
				cAmount:="0"
			ENDIF

			DO CASE
			CASE cAmount:Contains(oMainForm:decimalSeparator) .AND. cAmount:Contains(oMainForm:groupSeparator)
				cAmount := cAmount:Replace(oMainForm:groupSeparator, "")

			CASE ! cAmount:Contains(oMainForm:decimalSeparator) .AND. cAmount:Contains(oMainForm:groupSeparator)
				cAmount := cAmount:Replace(oMainForm:groupSeparator, oMainForm:decimalSeparator)
			ENDCASE

	//MemoWrit(cTempDocDir+"\FMReportPresentation.TXT", cStatement)
	//wb(cFormula+CRLF+cStatement, cAmount)
			nAmount:=Convert.ToDecimal(cAmount)
			cAmount:=(Decimal.Round(nAmount, 2)):ToString()

			IF cFormula:Contains("=")
				// Put left formula side to array
				cFormula := cFormula:Substring(0, cFormula:IndexOf("="))	//:ToUpper()
			ENDIF
			SELF:AddArrayListFormula(cFormula, cAmount)

			// Check if record exists into [FMReportPresentation]
			cStatement:="SELECT FORMULA_UID FROM FMReportPresentation"+;
						" WHERE FORMULA_UID="+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+;
						" AND UserID='"+oUser:UserID+"'"
			IF oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "FORMULA_UID") == ""
				// Insert [FMReportPresentation]
				cStatement:="INSERT INTO FMReportPresentation (FORMULA_UID, UserID, Amount) VALUES"+;
								"("+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+","+;
								"'"+oUser:UserID+"',"+;
								oSoftway:ColumnDecimalValue(cAmount)+")"
			ELSE
				// Update [FMReportPresentation]
				cStatement:="UPDATE FMReportPresentation"+" SET"+;
							" Amount="+oSoftway:ColumnDecimalValue(cAmount)+;
							" WHERE FORMULA_UID="+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+;
							" AND UserID='"+oUser:UserID+"'"
			ENDIF
			IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				ErrorBox("Cannot add new [FMReportPresentation] record")
				RETURN FALSE
			ENDIF

		OTHERWISE
			// Insert [FMReportPresentation]
			cStatement:="INSERT INTO FMReportPresentation (FORMULA_UID, UserID, TextField) VALUES"+;
							"("+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+","+;
							"'"+oUser:UserID+"', '"+;
							oSoftway:ConvertWildcards(cAmount, FALSE)+"')"
			IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				ErrorBox("Cannot add new [FMReportPresentation] record")
				RETURN FALSE
			ENDIF
		ENDCASE
	NEXT
RETURN nEmpty < nCount + 1


METHOD CompileFormulas() AS LOGIC
	LOCAL cStatement, cFormula, cFormulaUpper, cAmount, cVar:="" AS STRING
	LOCAL oDTFormulas AS DataTable
	LOCAL n, nCount AS INT

	// Expressions
	cStatement:="SELECT * FROM FMReportFormulas"+;
				" WHERE REPORT_UID="+SELF:GetSelectedReportDefinition("cUID")+;
				" AND (Formula LIKE '%+%' OR Formula LIKE '%-%' OR Formula LIKE '%=%' OR Formula LIKE '%*%' OR Formula LIKE '%/%')"+;
				" AND (Formula NOT LIKE '%(First)%' AND Formula NOT LIKE '%(Last)%' AND Formula NOT LIKE '%(Avg)%' AND Formula NOT LIKE '%(Sum)%')"+;
				" ORDER BY LineNum"
	oDTFormulas:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)

	nCount:=oDTFormulas:Rows:Count - 1
	FOR n:=0 UPTO nCount
		cFormula := oDTFormulas:Rows[n]:Item["Formula"]:ToString():Trim()
		cFormulaUpper := cFormula:ToUpper()

		IF SELF:aFormulas:IndexOf(cFormulaUpper) <> -1
			SELF:LocateFormulaRow(cFormula)
			ErrorBox("Formula: "+cFormula+CRLF+" already defined")
			RETURN FALSE
		ENDIF

		cVar := ""
		IF cFormulaUpper:Contains("=")
			// Put left formula side to cVar
			cVar := cFormulaUpper:Substring(0, cFormula:IndexOf("=")):Trim()	//:ToUpper()
			//cFormula:=cFormula:Substring(cFormula:IndexOf("=") + 1)
			cFormulaUpper := cFormulaUpper:Substring(cFormulaUpper:IndexOf("=") + 1):Trim()
		ENDIF

		IF ! SELF:ParseExpressionParenthesis(cFormulaUpper, cFormula)
			SELF:LocateFormulaRow(cFormula)
			RETURN FALSE
		ENDIF

		cFormulaUpper := SELF:ReplaceExpressionTerms(cFormulaUpper, cFormula)
		IF cFormulaUpper == ""
			SELF:LocateFormulaRow(cFormula)
			RETURN FALSE
		ENDIF
		//wb("cFormulaUpper="+cFormulaUpper, "First")

		// Calculate *, /
		// Calculate +, -
		cAmount := SELF:CalculateExpression(cFormulaUpper)
		//wb("cFormulaUpper="+cFormulaUpper, cAmount)

		IF cVar <> ""
			LOCAL nPos := SELF:aFormulas:IndexOf(cFormula:ToUpper()) AS INT
			IF nPos == -1
				SELF:AddArrayListFormula(cVar, cAmount)
			ELSE
				SELF:aFormulas[nPos] := cVar
				SELF:aValues[nPos] := cAmount
			ENDIF
		ENDIF

		// Check if record exists into [FMReportPresentation]
		cStatement:="SELECT FORMULA_UID FROM FMReportPresentation"+;
					" WHERE FORMULA_UID="+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+;
					" AND UserID='"+oUser:UserID+"'"
		IF oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "FORMULA_UID") == ""
			// Insert [FMReportPresentation]
			cStatement:="INSERT INTO FMReportPresentation (FORMULA_UID, UserID, Amount) VALUES"+;
						"("+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+","+;
						"'"+oUser:UserID+"',"+;
						oSoftway:ColumnDecimalValue(cAmount)+")"
		ELSE
			// Update [FMReportPresentation]
			cStatement:="UPDATE FMReportPresentation"+" SET"+;
						" Amount="+oSoftway:ColumnDecimalValue(cAmount)+;
						" WHERE FORMULA_UID="+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+;
						" AND UserID='"+oUser:UserID+"'"
		ENDIF
		IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			ErrorBox("Cannot add new [FMReportPresentation] record")
			RETURN FALSE
		ENDIF
	NEXT
	//Return nEmpty < nCount + 1
RETURN TRUE


METHOD ParseExpressionParenthesis(cExpression REF STRING, cFormula AS STRING) AS LOGIC
	// Priority: Parenthesis, *, /, +, -

	// Check for unbalanced parenthesis
	LOCAL nLeft := Occurs("(", cExpression) AS DWORD
	LOCAL nRight := Occurs(")", cExpression) AS DWORD
	IF nLeft <> nRight
		ErrorBox("Unbalanced parathesis")
		RETURN FALSE
	ENDIF

	// Find the first Right parenthesis
	LOCAL nPosRight := cExpression:IndexOf(")"), nPosLeft, n AS INT
	LOCAL cTerm, c, cParText, cValue, cValueText AS STRING

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
			ErrorBox("Unbalanced parathesis")
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
		cValue := SELF:CalculateExpression(cValueText)

		// Remove cTerm
		cExpression := cExpression:Replace(cParText, cValue):Trim()

		// Find next Right parenthesis
		nPosRight := cExpression:IndexOf(")")
	ENDDO
	//wb("cExpression="+cExpression, "ParseExpressionParenthesis")
RETURN TRUE


METHOD ReplaceExpressionTerms(cParText AS STRING, cFormula AS STRING) AS STRING
	// Replace Expression terms with values
	LOCAL cValueText := "", cVariable, cByte, cAmount AS STRING
	LOCAL nChar, nLen := cParText:Length - 1 AS INT

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
					RETURN ""
				ENDIF
				cValueText += cAmount
				cVariable := ""
			ENDIF
			//cValueText += cByte
			LOOP
		ENDCASE

		IF InListExact(cByte, "+", "-", "*", "/")
			cAmount := SELF:GetSingleVariableAmount(cVariable, cFormula)
			IF cAmount == ""
				RETURN ""
			ENDIF
			cValueText += cAmount
			cValueText += cByte
			cVariable := ""
			LOOP
		ENDIF

		cVariable += cByte
	NEXT

	IF cVariable <> ""
		cAmount := SELF:GetSingleVariableAmount(cVariable, cFormula)
		IF cAmount == ""
			RETURN ""
		ENDIF
		cValueText += cAmount
		cVariable := ""
	ENDIF
RETURN cValueText


METHOD CalculateExpression(cTermExpr AS STRING) AS STRING
	LOCAL cLeft, cRight, cAmount AS STRING
	LOCAL nPos AS INT

	cTermExpr := cTermExpr:Replace(" ", "")

	nPos := cTermExpr:IndexOf("*")
	WHILE nPos <> -1
		// Get left term
		cLeft := GetLeftNumber(cTermExpr, nPos - 1)

		// Get right term
		cRight := GetRightNumber(cTermExpr, nPos + 1)

		cAmount := Math.Round(Convert.ToDecimal(cLeft) * Convert.ToDecimal(cRight), 2):ToString()

		cTermExpr := cTermExpr:Replace(cLeft + "*" + cRight, cAmount)
		nPos := cTermExpr:IndexOf("*")
	ENDDO

	nPos := cTermExpr:IndexOf("/")
	WHILE nPos <> -1
		// Get left term
		cLeft := GetLeftNumber(cTermExpr, nPos - 1)

		// Get right term
		cRight := GetRightNumber(cTermExpr, nPos + 1)

		IF Convert.ToDecimal(cRight) == 0
			cAmount := "0"
		ELSE
			cAmount := Math.Round(Convert.ToDecimal(cLeft) / Convert.ToDecimal(cRight), 2):ToString()
		ENDIF

		cTermExpr := cTermExpr:Replace(cLeft + "/" + cRight, cAmount)

		nPos := cTermExpr:IndexOf("/")
	ENDDO

	nPos := cTermExpr:IndexOf("+")
	WHILE nPos <> -1
		// Get left term
		cLeft := GetLeftNumber(cTermExpr, nPos - 1)

		// Get right term
		cRight := GetRightNumber(cTermExpr, nPos + 1)

		cAmount := (Convert.ToDecimal(cLeft) + Convert.ToDecimal(cRight)):ToString()

		cTermExpr := cTermExpr:Replace(cLeft + "+" + cRight, cAmount)

		nPos := cTermExpr:IndexOf("+")
	ENDDO

	nPos := cTermExpr:IndexOf("-")
	WHILE nPos <> -1
		// Get left term
		cLeft := GetLeftNumber(cTermExpr, nPos - 1)

		// Get right term
		cRight := GetRightNumber(cTermExpr, nPos + 1)

		cAmount := (Convert.ToDecimal(cLeft) - Convert.ToDecimal(cRight)):ToString()

		cTermExpr := cTermExpr:Replace(cLeft + "-" + cRight, cAmount)

		nPos := cTermExpr:IndexOf("-")
		IF nPos == 0
			EXIT
		ENDIF
	ENDDO
RETURN cTermExpr


METHOD GetLeftNumber(cTermExpr AS STRING, nPos AS INT) AS STRING
	LOCAL cNum AS STRING
	LOCAL cByte AS STRING

	WHILE nPos <> -1
		cByte := cTermExpr:Substring(nPos, 1)
		IF ! oSoftway:StringIsNumeric(cByte, oMainForm:decimalSeparator)
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
		IF ! oSoftway:StringIsNumeric(cByte, oMainForm:decimalSeparator)
			EXIT
		ENDIF
		cNum += cByte
		nPos++
	ENDDO
RETURN cNum


METHOD AddEmptyFormulaLines() AS LOGIC
	LOCAL cStatement AS STRING
	LOCAL oDTFormulas AS DataTable
	LOCAL n, nCount AS INT
	//LOCAL nID AS Int16

	// Expressions
	cStatement:="SELECT FORMULA_UID, ID FROM FMReportFormulas"+;
				" WHERE REPORT_UID="+SELF:GetSelectedReportDefinition("cUID")+;
				" AND ID=0 AND (FMReportFormulas.Formula IS NULL OR FMReportFormulas.Formula='' OR FMReportFormulas.Formula=' ')"+;
				" ORDER BY LineNum"
	oDTFormulas:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)

	nCount:=oDTFormulas:Rows:Count - 1
	FOR n:=0 UPTO nCount
		//nID := Convert.ToInt16(oDTFormulas:Rows[n]:Item["ID"]:ToString())
		// Check if record exists into [FMReportPresentation]
		cStatement:="SELECT FORMULA_UID FROM FMReportPresentation"+;
					" WHERE FORMULA_UID="+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+;
					" AND UserID='"+oUser:UserID+"'"
		//wb(oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString(), "EmptyLine")
		IF oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "FORMULA_UID") == ""
			// Insert [FMReportPresentation]
			cStatement:="INSERT INTO FMReportPresentation (FORMULA_UID, UserID, TextField, Amount) VALUES"+;
						"("+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()+","+;
						"'"+oUser:UserID+"',"+;
						"NULL,"+;
						"NULL)"
		ELSE
			cStatement:="UPDATE FMReportPresentation SET Amount=NULL"+;
						" WHERE FORMULA_UID="+oDTFormulas:Rows[n]:Item["FORMULA_UID"]:ToString()
		ENDIF
		IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			ErrorBox("Cannot add new [FMReportPresentation] record")
			RETURN FALSE
		ENDIF
	NEXT
RETURN TRUE


METHOD LocateFormulaRow(cFormula AS STRING) AS VOID
	// Locate the row
	LOCAL nFocusedHandle AS INT
	nFocusedHandle := SELF:GridViewFormulas:LocateByValue(0, SELF:GridViewFormulas:Columns["Formula"], cFormula)
/*	// Use LocateByDisplayText() instead of LocateByValue() for INTEGER SQL columns
	nFocusedHandle:=Self:GridViewCountries:LocateByDisplayText(0, Self:GridViewCountries:Columns["Country"], cCountry)*/
	IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
		RETURN
	ENDIF
	SELF:GridViewFormulas:ClearSelection()
	SELF:GridViewFormulas:FocusedRowHandle:=nFocusedHandle
	SELF:GridViewFormulas:SelectRow(nFocusedHandle)
RETURN


METHOD GetCustomItemValue(cID AS STRING, cCustomItemUnit AS STRING, oSelectVoyageForm AS SelectVoyageForm, cDecimalValue REF STRING) AS STRING
	LOCAL cTextValue := "" AS STRING
	LOCAL oLBCItem AS MyLBCVoyageItem
	LOCAL dDate AS DateTime

	cDecimalValue := "NULL"

	DO CASE
	// Routing
	CASE cID == CustomItems.Routing_ID
		cTextValue := oSelectVoyageForm:GetSelectedLBCItem(oSelectVoyageForm:LBCRouting, "Name")

	CASE cID == CustomItems.RoutingSailed_ID
		oLBCItem := (MyLBCVoyageItem)oSelectVoyageForm:LBCRouting:SelectedItem
		dDate := oLBCItem:dStartGMT
		IF dDate <> DateTime.MinValue
			cTextValue += dDate:ToString("dd/MM/yyyy HH:mm")+" (GMT),    "
		ENDIF
		dDate := oLBCItem:dStart
		IF dDate <> DateTime.MinValue
			cTextValue += dDate:ToString("dd/MM/yyyy HH:mm")+" (local time)"
		ENDIF

	CASE cID == CustomItems.RoutingArrived_ID
		oLBCItem := (MyLBCVoyageItem)oSelectVoyageForm:LBCRouting:SelectedItem
		dDate := oLBCItem:dEndGMT
		IF dDate <> DateTime.MaxValue
			cTextValue += dDate:ToString("dd/MM/yyyy HH:mm")+" (GMT),    "
		ENDIF
		dDate := oLBCItem:dEnd
		IF dDate <> DateTime.MaxValue
			cTextValue += dDate:ToString("dd/MM/yyyy HH:mm")+" (local time)"
		ENDIF

	CASE cID == CustomItems.TCEquivalentUSD_ID
		oLBCItem := (MyLBCVoyageItem)oSelectVoyageForm:LBCRouting:SelectedItem
		cDecimalValue := oLBCItem:oRow["TCEquivalentUSD"]:ToString()
		IF cDecimalValue == ""
			cDecimalValue := "0.00"
		ENDIF

	// Voyage
	CASE cID == CustomItems.Voyage_ID
		cTextValue := oSelectVoyageForm:GetSelectedLBCItem(oSelectVoyageForm:LBCVoyages, "Name")

	CASE cID == CustomItems.VoyageSailed_ID
		oLBCItem := (MyLBCVoyageItem)oSelectVoyageForm:LBCVoyages:SelectedItem
		dDate := oLBCItem:dStartGMT
		IF dDate <> DateTime.MinValue
			cTextValue += dDate:ToString("dd/MM/yyyy HH:mm")+" (GMT),    "
		ENDIF
		dDate := oLBCItem:dStart
		IF dDate <> DateTime.MinValue
			cTextValue += dDate:ToString("dd/MM/yyyy HH:mm")+" (local time)"
		ENDIF

	CASE cID == CustomItems.VoyageArrived_ID
		oLBCItem := (MyLBCVoyageItem)oSelectVoyageForm:LBCVoyages:SelectedItem
		dDate := oLBCItem:dEndGMT
		IF dDate <> DateTime.MaxValue
			cTextValue += dDate:ToString("dd/MM/yyyy HH:mm")+" (GMT),    "
		ENDIF
		dDate := oLBCItem:dEnd
		IF dDate <> DateTime.MaxValue
			cTextValue += dDate:ToString("dd/MM/yyyy HH:mm")+" (local time)"
		ENDIF
	ENDCASE	

	IF cTextValue:EndsWith(",    ")
		cTextValue := cTextValue:Substring(0, cTextValue:Length - 5)
	ENDIF
RETURN cTextValue


METHOD GetCustomItemDateValues(lRouting AS LOGIC, lGMT AS LOGIC, oSelectVoyageForm AS SelectVoyageForm, dStartDate REF DateTime, dEndDate REF DateTime) AS VOID
	LOCAL oLBCItem AS MyLBCVoyageItem

	IF lRouting
		// Routing
		oLBCItem := (MyLBCVoyageItem)oSelectVoyageForm:LBCRouting:SelectedItem
	ELSE
		// Voyage
		oLBCItem := (MyLBCVoyageItem)oSelectVoyageForm:LBCVoyages:SelectedItem
	ENDIF

	IF lGMT
		dStartDate := oLBCItem:dStartGMT
		dEndDate := oLBCItem:dEndGMT
	ELSE
		dStartDate := oLBCItem:dStart
		dEndDate := oLBCItem:dEnd
	ENDIF
RETURN


METHOD GetSingleVariableAmount(cTerm AS STRING, cFormula AS STRING) AS STRING
	IF oSoftway:StringIsNumeric(cTerm, oMainForm:decimalSeparator)
		RETURN cTerm
	ENDIF

	LOCAL nPos AS INT

	nPos:=SELF:aFormulas:IndexOf(cTerm)
	IF nPos == -1
		SELF:LocateFormulaRow(cFormula)
		ErrorBox("Variable ["+cTerm+"] not found into the Formula Table", cFormula)
		//SELF:ShowFormulasArray()
		RETURN ""
	ENDIF
	//wb(cTerm+"="+(string)Self:aValues[nPos], "nPos="+nPos:ToString())
RETURN (STRING)SELF:aValues[nPos]


METHOD ReadDates() AS LOGIC
	LOCAL cDate AS STRING

	// Voyage GMT
	cDate := SELF:oLBCItemVoyage:oRow["StartDateGMT"]:ToString()
	IF cDate == ""
		ErrorBox("No Voyage's StartDateGMT found")
		RETURN FALSE
	ENDIF
	SELF:dDateFromVoyageGMT := Datetime.Parse(cDate)

	cDate := SELF:oLBCItemVoyage:oRow["EndDateGMT"]:ToString()
	IF cDate == ""
		SELF:dDateToVoyageGMT := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC)
	ELSE
		SELF:dDateToVoyageGMT := Datetime.Parse(cDate)
	ENDIF

	// Voyage LT
	cDate := SELF:oLBCItemVoyage:oRow["StartDate"]:ToString()
	IF cDate == ""
		ErrorBox("No Voyage's StartDate found")
		RETURN FALSE
	ENDIF
	SELF:dDateFromVoyage := Datetime.Parse(cDate)

	cDate := SELF:oLBCItemVoyage:oRow["EndDate"]:ToString()
	IF cDate == ""
		SELF:dDateToVoyage := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC)
	ELSE
		SELF:dDateToVoyage := Datetime.Parse(cDate)
	ENDIF

	// Routing GMT
	cDate := SELF:oLBCItemRouting:oRow["CommencedGMT"]:ToString()
	IF cDate == ""
		ErrorBox("No Voyage Routing's CommencedGMT found")
		RETURN FALSE
	ENDIF
	SELF:dDateFromRoutingGMT := Datetime.Parse(cDate)

	cDate := SELF:oLBCItemRouting:oRow["CompletedGMT"]:ToString()
	IF cDate == ""
		SELF:dDateToRoutingGMT := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC)
	ELSE
		SELF:dDateToRoutingGMT := Datetime.Parse(cDate)
	ENDIF

	// Routing LT
	cDate := SELF:oLBCItemRouting:oRow["Commenced"]:ToString()
	IF cDate == ""
		ErrorBox("No Voyage Routing's Commenced found")
		RETURN FALSE
	ENDIF
	SELF:dDateFromRouting := Datetime.Parse(cDate)

	cDate := SELF:oLBCItemRouting:oRow["Completed"]:ToString()
	IF cDate == ""
		SELF:dDateToRouting := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC)
	ELSE
		SELF:dDateToRouting := Datetime.Parse(cDate)
	ENDIF
RETURN TRUE


METHOD GetKgPerDay_DG() AS Double 
	LOCAL cKgPerDay_DG := SELF:oLBCItemVoyage:oRow["DGFOConsumption"]:ToString() AS STRING

	IF cKgPerDay_DG == ""
		cKgPerDay_DG := "0.00"
	ENDIF

	LOCAL nKgPerDay_DG := Convert.ToDouble(cKgPerDay_DG) * 1000 AS Double
RETURN nKgPerDay_DG


METHOD GetRoutingDaysSinceSailing(oSelectVoyageForm AS SelectVoyageForm) AS Decimal
	LOCAL nDaysSinceSailing AS Decimal
	LOCAL dStartDate, dEndDate AS DateTime

	SELF:GetCustomItemDateValues(TRUE, TRUE, oSelectVoyageForm, dStartDate, dEndDate)

	IF dEndDate == Datetime.MaxValue
		// Voyage is open
		// Get the last ShipsData DateTime:
		LOCAL cLastShipsDataDateTime AS STRING
		cLastShipsDataDateTime := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC):ToString("dd/MM/yyyy HH:mm:ss")
		dEndDate := DateTime.Parse(cLastShipsDataDateTime)
	ENDIF

	IF dStartDate <> Datetime.MinValue
		LOCAL Span1 AS TimeSpan
		Span1 := dEndDate:Subtract(dStartDate)
		nDaysSinceSailing := oSoftway:TimeSpanToDays(Span1, 2)
	ENDIF
RETURN nDaysSinceSailing


//METHOD GetRoutingMilesAlreadyTravelled(oSelectVoyageForm AS SelectVoyageForm) AS Double
//	LOCAL nMilesTravelled AS Double
//	LOCAL dStartDate, dEndDate AS DateTime
//	LOCAL lVoyageOpen AS LOGIC

//	SELF:GetCustomItemDateValues(TRUE, TRUE, oSelectVoyageForm, dStartDate, dEndDate)

//	IF dEndDate == Datetime.MaxValue
//		// Voyage is open
//		// Get the last ShipsData DateTime:
//		LOCAL cLastShipsDataDateTime := oMainForm:LBCPackages:GetItemText(oMainForm:LBCPackages:SelectedIndex) AS STRING
//		IF cLastShipsDataDateTime == ""
//			cLastShipsDataDateTime := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC):ToString("dd/MM/yyyy HH:mm:ss")
//		ENDIF
//		dEndDate := DateTime.Parse(cLastShipsDataDateTime)
//		lVoyageOpen := TRUE
//	ENDIF

//	IF dStartDate <> Datetime.MinValue
//		IF lVoyageOpen
//			LOCAL nRecords AS INT
//			nMilesTravelled := oMainForm:CalcDistanceDates(dStartDate, dEndDate, nRecords, oMainForm:CheckedLBCVessels:SelectedValue:ToString())
//		ELSE
//			LOCAL cMilesTravelled := SELF:oLBCItemRouting:oRow["Distance"]:ToString() AS STRING
//			IF cMilesTravelled == ""
//				cMilesTravelled := "0.00"
//			ENDIF
//			nMilesTravelled := Convert.ToDouble(cMilesTravelled)
//		ENDIF
//		nMilesTravelled := Math.Round(nMilesTravelled, 2)
//	ENDIF
//RETURN nMilesTravelled


//METHOD GetRoutingMilesTravelledToday(oSelectVoyageForm AS SelectVoyageForm) AS Double
//	LOCAL nRecords AS INT

//	// Get the last ShipsData DateTime:
//	LOCAL cLastShipsDataDateTime := oMainForm:LBCPackages:GetItemText(oMainForm:LBCPackages:SelectedIndex) AS STRING
//	IF cLastShipsDataDateTime == ""
//		cLastShipsDataDateTime := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC):ToString("dd/MM/yyyy HH:mm:ss")
//	ENDIF
//	LOCAL dLastDate := DateTime.Parse(cLastShipsDataDateTime) AS DateTime

//	LOCAL dTodayStart, dTodayEnd AS Datetime

//	dTodayStart := Datetime{dLastDate:Year, dLastDate:Month, dLastDate:Day, 0, 0, 0}
//	dTodayEnd := Datetime{dLastDate:Year, dLastDate:Month, dLastDate:Day, 23, 59, 59}

//	LOCAL nMilesTravelledToday := oMainForm:CalcDistanceDates(dTodayStart, dTodayEnd, nRecords, oMainForm:CheckedLBCVessels:SelectedValue:ToString()) AS Double
//	nMilesTravelledToday := Math.Round(nMilesTravelledToday, 2)
//RETURN nMilesTravelledToday


//METHOD CalculateTimeCost(oSelectVoyageForm AS SelectVoyageForm) AS Double
//	LOCAL nDaysSinceSailing := SELF:GetRoutingDaysSinceSailing(oSelectVoyageForm) AS Decimal

//	LOCAL cTCEquivalentUSD := SELF:oLBCItemRouting:oRow["TCEquivalentUSD"]:ToString() AS STRING
//	IF cTCEquivalentUSD == ""
//		cTCEquivalentUSD := "0.00"
//	ENDIF

//	LOCAL nTimeCostNow := Math.Round((Double)nDaysSinceSailing * Convert.ToDouble(cTCEquivalentUSD), 0) AS Double
//RETURN nTimeCostNow


//METHOD CalculateFuelCost(oSelectVoyageForm AS SelectVoyageForm) AS Double
//	LOCAL dStartDate, dEndDate AS DateTime

//	SELF:GetCustomItemDateValues(TRUE, TRUE, oSelectVoyageForm, dStartDate, dEndDate)

//	IF dStartDate == DateTime.MinValue
//		RETURN 0
//	ENDIF

//	IF dEndDate == Datetime.MaxValue
//		// Voyage is open
//		LOCAL cLastShipsDataDateTime := oMainForm:LBCPackages:GetItemText(oMainForm:LBCPackages:SelectedIndex) AS STRING
//		IF cLastShipsDataDateTime == ""
//			cLastShipsDataDateTime := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC):ToString("dd/MM/yyyy HH:mm:ss")
//		ENDIF
//		dEndDate := DateTime.Parse(cLastShipsDataDateTime)
//	ENDIF

//	LOCAL nAccumulatedFuelMass, nAccumulatedFuelMassStart AS Double
//	nAccumulatedFuelMassStart := oMainForm:GetAccumulatedFuelMassStart(dStartDate, oMainForm:CheckedLBCVessels:SelectedValue:ToString())
//	nAccumulatedFuelMass := oMainForm:GetAccumulatedFuelMass("FMDataPackages.TDate <= '"+dEndDate:ToString("yyyy-MM-dd HH:mm:ss")+"'", oMainForm:CheckedLBCVessels:SelectedValue:ToString(), nAccumulatedFuelMassStart)

//	LOCAL nDaysSinceSailing := SELF:GetRoutingDaysSinceSailing(oSelectVoyageForm) AS Decimal
//	LOCAL nVoyageCons_DG AS Double
//	nVoyageCons_DG := (Double)nDaysSinceSailing * SELF:GetKgPerDay_DG()

//	LOCAL cFOPriceUSD := SELF:oLBCItemRouting:oRow["FOPriceUSD"]:ToString() AS STRING
//	IF cFOPriceUSD == ""
//		cFOPriceUSD := "0.00"
//	ENDIF

//	LOCAL nFuelCostNow := Math.Round(((nAccumulatedFuelMass - nAccumulatedFuelMassStart + nVoyageCons_DG) / 1000) * Convert.ToDouble(cFOPriceUSD), 0) AS Double
//RETURN nFuelCostNow

END CLASS
