// MRVResutlForm.prg
#Using System.IO
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Collections
#Using DevExpress.XtraGrid.Columns
#Using DevExpress.Utils
#Using DevExpress.XtraEditors.Repository
#using DevExpress.XtraGrid.Views.Grid
#using DevExpress.XtraGrid.Views.Grid.ViewInfo
#using DevExpress.XtraGrid
#using DevExpress.XtraPrinting
#using System.Drawing.Printing
#using DevExpress.LookAndFeel

PARTIAL CLASS MRVResultForm INHERIT System.Windows.Forms.Form

	EXPORT oDTMyResults AS DataTable 
	EXPORT cMyVesselUID AS STRING 
	EXPORT cMyVesselName AS STRING
	PRIVATE oMyDataset AS DataSet 

	PRIVATE METHOD MRVResultFromLoad() AS System.Void

		SELF:labelVesselName:Text := cMyVesselName

    RETURN


	PRIVATE METHOD runTheMRVReport() AS System.Void

		SELF:getTheData()

		SELF:oMyDataset := DataSet{}
		SELF:oDTMyResults:TableName:="Results"
		SELF:oMyDataset:Tables:Add(SELF:oDTMyResults)
		SELF:gridControl1:DataSource := SELF:oMyDataset:Tables["Results"]
		SELF:gridControl1:ForceInitialize()
		
		SELF:gridView1:Columns["VoyageStartDate"]:DisplayFormat:FormatString := "dd/MM/yyyy HH:mm"
		SELF:gridView1:Columns["VoyageEndDate"]:DisplayFormat:FormatString := "dd/MM/yyyy HH:mm"
		SELF:gridView1:Columns["ReceivedOnPortOfArrivalHFO"]:Visible := FALSE
		SELF:gridView1:Columns["ReceivedOnPortOfArrivalMDO"]:Visible := FALSE

		//
		//						Banded Columns
		//
		//
		//	General
		//
		gridView1:Columns["VoyageNo"]:OwnerBand := self:gridBandGeneral
		gridView1:Columns["Condition"]:OwnerBand := self:gridBandGeneral
		gridView1:Columns["PortOfDeparture"]:OwnerBand := self:gridBandGeneral
		gridView1:Columns["DepartingFromEuPort"]:OwnerBand := self:gridBandGeneral
		gridView1:Columns["PortOfArrival"]:OwnerBand := self:gridBandGeneral
		gridView1:Columns["ArrivalToEuPort"]:OwnerBand := self:gridBandGeneral
		gridView1:Columns["VoyageStartDate"]:OwnerBand := self:gridBandGeneral
		gridView1:Columns["VoyageEndDate"]:OwnerBand := self:gridBandGeneral
		gridView1:Columns["TimeSpentAtSea"]:OwnerBand := self:gridBandGeneral
		gridView1:Columns["TimeSpentForEUVoyages"]:OwnerBand := self:gridBandGeneral
		gridView1:Columns["Distance"]:OwnerBand := self:gridBandGeneral
		gridView1:Columns["DistanceForEUVoyages"]:OwnerBand := self:gridBandGeneral
		//
		//	Cargo
		//
		gridView1:Columns["CargoCarried"]:OwnerBand := self:gridBandCargo
        gridView1:Columns["CargoCarried"]:AppearanceCell:BackColor := Color.Beige

		gridView1:Columns["TransportWork"]:OwnerBand := SELF:gridBandCargo
        gridView1:Columns["TransportWork"]:AppearanceCell:BackColor := Color.Beige

		gridView1:Columns["TransportWorkForEU"]:OwnerBand := self:gridBandCargo
        gridView1:Columns["TransportWorkForEU"]:AppearanceCell:BackColor := Color.Beige
		//
		//	HFO
		//
		gridView1:Columns["DepartureHFO"]:OwnerBand := SELF:gridBandHFP
        gridView1:Columns["DepartureHFO"]:AppearanceCell:BackColor := Color.LightSkyBlue

		gridView1:Columns["ArrivalHFO"]:OwnerBand := self:gridBandHFP
        gridView1:Columns["ArrivalHFO"]:AppearanceCell:BackColor := Color.LightSkyBlue

		gridView1:Columns["VoyageHFOCons"]:OwnerBand := self:gridBandHFP
        gridView1:Columns["VoyageHFOCons"]:AppearanceCell:BackColor := Color.LightSkyBlue

		gridView1:Columns["EUVoyageHFOCons"]:OwnerBand := self:gridBandHFP
        gridView1:Columns["EUVoyageHFOCons"]:AppearanceCell:BackColor := Color.LightSkyBlue

		gridView1:Columns["BerthHFO"]:OwnerBand := self:gridBandHFP
        gridView1:Columns["BerthHFO"]:AppearanceCell:BackColor := Color.LightSkyBlue

		gridView1:Columns["EUBerthHFO"]:OwnerBand := self:gridBandHFP
        gridView1:Columns["EUBerthHFO"]:AppearanceCell:BackColor := Color.LightSkyBlue

		gridView1:Columns["ReceivedHFO"]:OwnerBand := self:gridBandHFP
        gridView1:Columns["ReceivedHFO"]:AppearanceCell:BackColor := Color.LightSkyBlue

		gridView1:Columns["ReceivedOnPortOfArrivalHFO"]:OwnerBand := self:gridBandHFP
        gridView1:Columns["ReceivedOnPortOfArrivalHFO"]:AppearanceCell:BackColor := Color.LightSkyBlue
		//
		//	MDO
		//
		gridView1:Columns["DepartureMDO"]:OwnerBand := self:gridBandMDOMGO
		gridView1:Columns["DepartureMDO"]:Caption := "Departure ROB"
        gridView1:Columns["DepartureMDO"]:AppearanceCell:BackColor := Color.Beige

		gridView1:Columns["ArrivalMDO"]:OwnerBand := self:gridBandMDOMGO
		gridView1:Columns["ArrivalMDO"]:Caption := "Arrival ROB"
        gridView1:Columns["ArrivalMDO"]:AppearanceCell:BackColor := Color.Beige

		gridView1:Columns["VoyageMDOCons"]:OwnerBand := SELF:gridBandMDOMGO
		gridView1:Columns["VoyageMDOCons"]:Caption := "Voyage Cons"
        gridView1:Columns["VoyageMDOCons"]:AppearanceCell:BackColor := Color.Beige

		gridView1:Columns["EUVoyageMDOCons"]:OwnerBand := SELF:gridBandMDOMGO
		gridView1:Columns["EUVoyageMDOCons"]:Caption := "EU Voyage Cons"
        gridView1:Columns["EUVoyageMDOCons"]:AppearanceCell:BackColor := Color.Beige

		gridView1:Columns["BerthMDO"]:OwnerBand := SELF:gridBandMDOMGO
		gridView1:Columns["BerthMDO"]:Caption := "Berth Cons"
        gridView1:Columns["BerthMDO"]:AppearanceCell:BackColor := Color.Beige

		gridView1:Columns["EUBerthMDO"]:OwnerBand := SELF:gridBandMDOMGO
		gridView1:Columns["EUBerthMDO"]:Caption := "EU Berth Cons"
        gridView1:Columns["EUBerthMDO"]:AppearanceCell:BackColor := Color.Beige

		gridView1:Columns["ReceivedMDO"]:OwnerBand := SELF:gridBandMDOMGO
		gridView1:Columns["ReceivedMDO"]:Caption := "Received"
        gridView1:Columns["ReceivedMDO"]:AppearanceCell:BackColor := Color.Beige

		gridView1:Columns["ReceivedOnPortOfArrivalMDO"]:OwnerBand := self:gridBandMDOMGO
        gridView1:Columns["ReceivedOnPortOfArrivalMDO"]:AppearanceCell:BackColor := Color.Beige
		//
		//	CO2
		//
		gridView1:Columns["TotalCO2Emitted"]:OwnerBand := SELF:gridBandCO2
        gridView1:Columns["TotalCO2Emitted"]:AppearanceCell:BackColor := Color.LightSkyBlue

		gridView1:Columns["CO2EmittedOnEUVoyage"]:OwnerBand := self:gridBandCO2
		gridView1:Columns["CO2EmittedOnEUVoyage"]:Caption := "EmittedOnEUVoyage"
        gridView1:Columns["CO2EmittedOnEUVoyage"]:AppearanceCell:BackColor := Color.LightSkyBlue

		gridView1:Columns["CO2EmittedOnVoyageDepartedFromEUPort"]:OwnerBand := self:gridBandCO2
        gridView1:Columns["CO2EmittedOnVoyageDepartedFromEUPort"]:AppearanceCell:BackColor := Color.LightSkyBlue

		gridView1:Columns["CO2EmittedOnVoyageArrivedToEUPort"]:OwnerBand := self:gridBandCO2
        gridView1:Columns["CO2EmittedOnVoyageArrivedToEUPort"]:AppearanceCell:BackColor := Color.LightSkyBlue

		gridView1:Columns["CO2EmittedAtBerth"]:OwnerBand := self:gridBandCO2
        gridView1:Columns["CO2EmittedAtBerth"]:AppearanceCell:BackColor := Color.LightSkyBlue

		gridView1:Columns["CO2EmittedAtEuPort"]:OwnerBand := self:gridBandCO2
        gridView1:Columns["CO2EmittedAtEuPort"]:AppearanceCell:BackColor := Color.LightSkyBlue

		gridView1:Columns["TotalCO2VoyageAndBerth"]:OwnerBand := self:gridBandCO2
        gridView1:Columns["TotalCO2VoyageAndBerth"]:AppearanceCell:BackColor := Color.LightSkyBlue

		gridView1:Columns["EEOI"]:OwnerBand := self:gridBandCO2
        gridView1:Columns["EEOI"]:AppearanceCell:BackColor := Color.LightSkyBlue


		FOREACH column AS DevExpress.XtraGrid.Columns.GridColumn IN gridView1:Columns
			column:OptionsColumn:AllowEdit := FALSE
        	column:MinWidth := 90
		NEXT
		
		SELF:gridView1:Columns["CargoCarried"]:OptionsColumn:AllowEdit := TRUE

		SELF:gridControl1:Refresh()	

    RETURN

PRIVATE METHOD buttonPrintGridClick() AS VOID
	//SELF:gridControl1:Print()
	LOCAL link :=  PrintableComponentLink{} AS PrintableComponentLink
                link:PrintingSystemBase :=  PrintingSystemBase{}
                link:Component := gridControl1
                link:Landscape := TRUE
                link:PaperKind := PaperKind.A4
                link:Margins :=  Margins{30, 30, 30, 30}
            // Show the report. 
			local lookAndFeel AS UserLookAndFeel 
            link:ShowRibbonPreview(lookAndFeel)
RETURN

PRIVATE METHOD getTheData() AS VOID
	
	LOCAL cConditionCaseSql := " VoyageCondition =  CASE EconRoutings.Condition  "+;
         " WHEN 1 THEN 'Ballast'  "+;
         " WHEN 2 THEN 'Laden' "+; 
         " WHEN 3 THEN 'Loading'  "+;
         " WHEN 4 THEN 'Discharging'  "+;
         " WHEN 5 THEN 'Idle'  "+;
         " ELSE 'Unknown'   "+;
		 " END"

	LOCAL cYearLocal := SELF:comboBoxYear:Text:Trim() AS STRING
	LOCAL cLegStartLocal := cYearLocal+"0101 00:00:00" AS STRING
	LOCAL cLegEndLocal := cYearLocal+"1231 23:59:59" AS STRING

	Local cStatement := "" As String
	//Παίρνω όλα τα routing του voyage
	cStatement:=" SELECT DISTINCT EconVoyages.VoyageNo, "+cConditionCaseSql+" , EconRoutings.*, "+;
				" RTrim(VEPortsFrom.Port) AS PortFrom, VEPortsFrom.EUPORT AS DepartingFromEuPort, "+;
				" RTrim(VEPortsTo.Port) AS PortTo, VEPortsTo.EUPORT AS ArrivalToEuPort,"+;
				" MatchedWithArrival, Arrival_HFO AS ArrHFO, Arrival_LFO AS ArrLFO, Arrival_MGO AS ArrMGO,"+;
				" MatchedWithDeparture, Departure_HFO AS DepHFO, Departure_LFO AS DepLFO, Departure_MGO AS DepMGO,"+;
				" Arrival_HFO, Arrival_LFO, Arrival_MGO, Departure_HFO, Departure_LFO, Departure_MGO,"+;
				" BunkeredHFO, BunkeredLFO, BunkeredMDO, EconRoutings.CommencedGMT, EconRoutings.CompletedGMT "+;
				" FROM EconRoutings "+;
				" INNER JOIN EconVoyages ON EconVoyages.VOYAGE_UID=EconRoutings.VOYAGE_UID"+;
				" LEFT OUTER JOIN VEPorts AS VEPortsFrom ON EconRoutings.PortFrom_UID=VEPortsFrom.PORT_UID"+;
				" LEFT OUTER JOIN VEPorts AS VEPortsTo ON EconRoutings.PortTo_UID=VEPortsTo.PORT_UID"+;
				" LEFT OUTER JOIN FMRoutingAdditionalData ON FMRoutingAdditionalData.Routing_UID = EconRoutings.ROUTING_UID"+;
				" WHERE EconRoutings.CommencedGMT >= '"+ cLegStartLocal+"' "+;
				" AND EconVoyages.VESSEL_UNIQUEID = "+ self:cMyVesselUID+;
				" ORDER BY EconRoutings.CommencedGMT ASC "
				//" OR    ( EconRoutings.CompletedGMT >=  '"+cLegStartLocal+"' AND EconRoutings.CompletedGMT <= '"+cLegEndLocal+"' ))"+;
				//" AND EconVoyages.VESSEL_UNIQUEID = "+ self:cMyVesselUID+;
				//" ORDER BY EconRoutings.CommencedGMT ASC "
	memowrit(cTempDocDir+"\oDTRoutingsLocal.txt", cStatement)
	LOCAL oDTRoutingsLocal := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

	//Φτιάχνω ένα datatable για να βάλω τα αποτελέσματα
	LOCAL oDTResults := DataTable{} AS DataTable
	oDTResults:Columns:Add("VoyageNo", typeof(STRING))
	oDTResults:Columns:Add("Condition", typeof(STRING))
	oDTResults:Columns:Add("PortOfDeparture", typeof(STRING))
	oDTResults:Columns:Add("DepartingFromEuPort", typeof(LOGIC))
	oDTResults:Columns:Add("PortOfArrival", typeof(STRING))
	oDTResults:Columns:Add("ArrivalToEuPort", typeof(LOGIC))
	oDTResults:Columns:Add("VoyageStartDate", typeof(DateTime))
	oDTResults:Columns:Add("VoyageEndDate", typeof(DateTime))
	oDTResults:Columns:Add("TimeSpentAtSea", typeof(decimal))
	oDTResults:Columns:Add("TimeSpentForEUVoyages", typeof(decimal))
	oDTResults:Columns:Add("Distance", typeof(decimal))
	oDTResults:Columns:Add("DistanceForEUVoyages", typeof(decimal))
	//Cargo
	oDTResults:Columns:Add("CargoCarried", typeof(decimal))
	oDTResults:Columns:Add("TransportWork", typeof(decimal))
	oDTResults:Columns:Add("TransportWorkForEU", typeof(decimal))
	// HFO
	oDTResults:Columns:Add("DepartureHFO", typeof(decimal))
	oDTResults:Columns:Add("ArrivalHFO", typeof(decimal))
	oDTResults:Columns:Add("VoyageHFOCons", typeof(decimal))
	oDTResults:Columns:Add("EUVoyageHFOCons", typeof(decimal))
	oDTResults:Columns:Add("BerthHFO", typeof(decimal))
	oDTResults:Columns:Add("EUBerthHFO", typeof(decimal))
	oDTResults:Columns:Add("ReceivedHFO", typeof(decimal))
	oDTResults:Columns:Add("ReceivedOnPortOfArrivalHFO", typeof(decimal))
	
	/*
	// LFO
	oDTResults:Columns:Add("DepartureLFO", typeof(decimal))
	oDTResults:Columns:Add("ArrivalLFO", typeof(decimal))
	oDTResults:Columns:Add("VoyageLFOCons", typeof(decimal))
	oDTResults:Columns:Add("EUVoyageLFOCons", typeof(decimal))
	oDTResults:Columns:Add("BerthLFO", typeof(decimal))
	oDTResults:Columns:Add("EUBerthLFO", typeof(decimal))
	// MDO
	*/
	oDTResults:Columns:Add("DepartureMDO", typeof(decimal))
	oDTResults:Columns:Add("ArrivalMDO", typeof(decimal))
	oDTResults:Columns:Add("VoyageMDOCons", typeof(decimal))
	oDTResults:Columns:Add("EUVoyageMDOCons", typeof(decimal))
	oDTResults:Columns:Add("BerthMDO", typeof(decimal))
	oDTResults:Columns:Add("EUBerthMDO", typeof(decimal))
	oDTResults:Columns:Add("ReceivedMDO", typeof(decimal))
	oDTResults:Columns:Add("ReceivedOnPortOfArrivalMDO", typeof(decimal))	
	//	
	oDTResults:Columns:Add("TotalCO2Emitted", typeof(decimal))
	oDTResults:Columns:Add("CO2EmittedOnEUVoyage", typeof(decimal))
	oDTResults:Columns:Add("CO2EmittedOnVoyageDepartedFromEUPort", typeof(decimal))
	oDTResults:Columns:Add("CO2EmittedOnVoyageArrivedToEUPort", typeof(decimal))
	oDTResults:Columns:Add("CO2EmittedAtBerth", typeof(decimal))
	oDTResults:Columns:Add("CO2EmittedAtEuPort", typeof(decimal))
	oDTResults:Columns:Add("TotalCO2VoyageAndBerth", typeof(decimal))
	oDTResults:Columns:Add("EEOI", typeof(decimal))
	 

	//Μεταβλητές για μέσα στο loop
	LOCAL cCondition := "", cNextCondition:="",cDepartingFromEU, cArrivingAtEU AS STRING
	LOCAL cStartDate:="", cEndDate:="", cDistance:="" AS STRING
	LOCAL dStartDate, dEndDate AS DateTime
	LOCAL oTimeSpan AS TimeSpan
	LOCAL lDepartingFromEU, lArrivingAtEU as LOGIC
	LOCAL cDepartureHFO:="", cArrivalHFO:="", cVoyageConsHFO:="" AS String
	LOCAL dDepartureHFO:=0, dArrivalHFO:=0, dVoyageConsHFO:=0 AS double
	LOCAL cDepartureLFO:="", cArrivalHLO:="", cVoyageConsHLO:="" AS String
	LOCAL dDepartureLFO:=0, dArrivalLFO:=0, dVoyageConsLFO:=0 AS double
	LOCAL cDepartureMDO:="", cArrivalMDO:="", cVoyageConsMDO:="" AS String
	LOCAL dDepartureMDO:=0, dArrivalMDO:=0, dVoyageConsMDO:=0 AS double
	LOCAL cNextPortDepartureHFO := "" as String
	Local dNextPortDepartureHFO := 0 As double
	Local dBerthConsHFO :=0, dBerthConsMDO:=0 as double
	local oDrNewResultRow as DataRow

	//iCountRows για το πόσες γραμμές έχει ο πίνακας
	//iTerate για να τον διασχίσω
	//iFindRow για να βρίσκω rows μέσα στον πίνακα
	LOCAL iCountRows := oDTRoutingsLocal:Rows:Count-1, iIterate:=0, iFindNextRow:=0, iInsertIntoResults AS INT
	LOCAL dCountDistance := 0 AS Double
	LOCAL oDRFindRow AS DataRow	
	LOCAL oRowEnd AS DataRow
	LOCAL lInsertingRow := false as LOGIC
	LOCAL oRowLocal AS DataRow 
	LOCAL cBunkeredQuantity := "" AS STRING
	LOCAL dBunkeredHFOQuantity := 0 AS double
	LOCAL dBunkeredLFOQuantity := 0 AS double
	LOCAL dBunkeredMDOQuantity := 0 AS double
	LOCAL	dBunkeredHFOQuantityArrivalPort := 0 AS double
	LOCAL	dBunkeredLFOQuantityArrivalPort := 0 AS double
	LOCAL	dBunkeredMDOQuantityArrivalPort := 0 AS double
	//LOCAL cBunkeredDate := "" AS STRING
	//LOCAL dtBunkeredDate AS DateTime
	LOCAL lStartFound := false, lStop as LOGIC
	FOR iIterate:=0 UPTO iCountRows
		IF lStop
			EXIT
		ENDIF

		cBunkeredQuantity := "" 
		dBunkeredHFOQuantity := 0 
		dBunkeredLFOQuantity := 0 
		dBunkeredMDOQuantity := 0 
		dBunkeredHFOQuantityArrivalPort := 0
		dBunkeredLFOQuantityArrivalPort := 0
		dBunkeredMDOQuantityArrivalPort := 0
		cDistance := "0"
		dCountDistance := 0
		oRowLocal := oDTRoutingsLocal:Rows[iIterate] 
		LOCAL dtCompletedDateTime := (DateTime)oRowLocal["CompletedGMT"] AS DateTime
		LOCAL dtEndOfYear := DateTime.ParseExact(cLegEndLocal, "yyyyMMdd HH:mm:ss",null) AS DateTime
		IF dtCompletedDateTime >= dtEndOfYear
			RETURN
		ENDIF
		cCondition := oRowLocal["VoyageCondition"]:ToString()

		IF   cCondition == "Ballast" || cCondition == "Laden"  || cCondition == "Idle"
			LOOP
		ELSE
			oDrNewResultRow := oDTResults:NewRow()

			//Starting port for the report is the port Im leaving from
			oDrNewResultRow["PortOfDeparture"] := oRowLocal["PortFrom"]
			oDrNewResultRow["DepartingFromEuPort"] := oRowLocal["DepartingFromEuPort"]
			cDepartingFromEU := oRowLocal["DepartingFromEuPort"]:ToString()
			lDepartingFromEU := ToLogic(cDepartingFromEU)

			//Start Date is the Date that Im leaving the port
			cStartDate := oRowLocal["CompletedGMT"]:ToString()
			dStartDate := DateTime.Parse(cStartDate)
			oDrNewResultRow["VoyageStartDate"] := dStartDate //:ToString():Trim()
			
			//If any distance is inputed add it
			cDistance := oRowLocal["Distance"]:ToString():Trim()
			IF cDistance==""
				cDistance := "0"
			ENDIF
			dCountDistance += Convert.ToDouble(cDistance)

			IF iIterate+1>=iCountRows
				EXIT
			ENDIF
			
			//Voyage No is the Voyage No of the next leg the Laden or Ballast leg
			oDrNewResultRow["VoyageNo"] := ((DataRow)oDTRoutingsLocal:Rows[iIterate+1])["VoyageNo"]

			//Condition is the next condition
			cNextCondition := ((DataRow)oDTRoutingsLocal:Rows[iIterate+1])["VoyageCondition"]:ToString()
			IF cNextCondition == "Idle"
				cNextCondition := ((DataRow)oDTRoutingsLocal:Rows[iIterate+2])["VoyageCondition"]:ToString()
			ENDIF
			oDrNewResultRow["Condition"] := cNextCondition
			
			//Departure ROBS
			//HFO
				cDepartureHFO := oRowLocal["Departure_HFO"]:ToString():Trim()
				IF cDepartureHFO == ""
					dDepartureHFO := 0
				ELSE
					dDepartureHFO :=  Math.Round(Convert.ToDouble(cDepartureHFO),3)
				ENDIF
				
				oDrNewResultRow["DepartureHFO"] :=	dDepartureHFO
			/*
			//LFO
				cDepartureLFO := oRowLocal["Departure_LFO"]:ToString():Trim()
				IF cDepartureLFO == ""
					cDepartureLFO := 0
				ELSE
					cDepartureLFO :=  Math.Round(Convert.ToDouble(cDepartureLFO),1)
				ENDIF
			*/
			//MDO
				cDepartureMDO := oRowLocal["Departure_MGO"]:ToString():Trim()
				IF cDepartureMDO == ""
					dDepartureMDO := 0
				ELSE
					dDepartureMDO :=  Math.Round(Convert.ToDouble(cDepartureMDO),3)
				ENDIF
				oDrNewResultRow["DepartureMDO"] :=	dDepartureMDO

			FOR iFindNextRow:=iIterate+1 UPTO iCountRows
				oRowEnd := oDTRoutingsLocal:Rows[iFindNextRow]	
					//Add distance for legs that intervene
					cDistance := oRowEnd["Distance"]:ToString():Trim()
					IF cDistance==""
						cDistance := "0"
					ENDIF
					dCountDistance += Convert.ToDouble(cDistance)
					
				
				cCondition := oRowEnd["VoyageCondition"]:ToString()	
				IF	cCondition == "Ballast" || cCondition == "Laden" || cCondition == "Idle"
					//Add bunkering for legs that intervene
					//Bunkered HFO
					cBunkeredQuantity := oRowEnd["BunkeredHFO"]:ToString():Trim()
					IF cBunkeredQuantity==""
						cBunkeredQuantity := "0"
					ENDIF
					
					dBunkeredHFOQuantity += Convert.ToDouble(cBunkeredQuantity)
					/*
					//Bunkered LFO
					cBunkeredQuantity := oRowEnd["BunkeredLFO"]:ToString():Trim()
					IF cBunkeredQuantity==""
						cBunkeredQuantity := "0"
					ENDIF
					dBunkeredLFOQuantity += Convert.ToDouble(cBunkeredQuantity)
					*/
					//Bunkered MDO
					cBunkeredQuantity := oRowEnd["BunkeredMDO"]:ToString():Trim()
					IF cBunkeredQuantity==""
						cBunkeredQuantity := "0"
					ENDIF
					dBunkeredMDOQuantity += Convert.ToDouble(cBunkeredQuantity)
					
					iIterate++
					LOOP
				ENDIF
				//////////////////////////////////////////////////////
				//			Bunkering on Arrival Port
				//////////////////////////////////////////////////////
					//Bunkered HFO
					cBunkeredQuantity := oRowEnd["BunkeredHFO"]:ToString():Trim()
					IF cBunkeredQuantity==""
						cBunkeredQuantity := "0"
					ENDIF
					dBunkeredHFOQuantityArrivalPort := Convert.ToDouble(cBunkeredQuantity)

					/*
					//Bunkered LFO
					cBunkeredQuantity := oRowEnd["BunkeredLFO"]:ToString():Trim()
					IF cBunkeredQuantity==""
						cBunkeredQuantity := "0"
					ENDIF
					dBunkeredLFOQuantity += Convert.ToDouble(cBunkeredQuantity)
					*/
					//Bunkered MDO
					cBunkeredQuantity := oRowEnd["BunkeredMDO"]:ToString():Trim()
					IF cBunkeredQuantity==""
						cBunkeredQuantity := "0"
					ENDIF
					dBunkeredMDOQuantityArrivalPort := Convert.ToDouble(cBunkeredQuantity)
					

				//Bunkered
				oDrNewResultRow["ReceivedHFO"] := dBunkeredHFOQuantity + dBunkeredHFOQuantityArrivalPort
				oDrNewResultRow["ReceivedOnPortOfArrivalHFO"] := dBunkeredHFOQuantityArrivalPort
				oDrNewResultRow["ReceivedMDO"] := dBunkeredMDOQuantity + dBunkeredMDOQuantityArrivalPort
				oDrNewResultRow["ReceivedOnPortOfArrivalMDO"] := dBunkeredMDOQuantityArrivalPort

				//Found the Arrival Port so add Arrival Info
				oDrNewResultRow["PortOfArrival"] := oRowEnd["PortTo"]
				oDrNewResultRow["ArrivalToEuPort"] := oRowEnd["ArrivalToEuPort"]
				cEndDate := oRowEnd["CommencedGMT"]:ToString()
				dEndDate := DateTime.Parse(cEndDate)
				oDrNewResultRow["VoyageEndDate"] := dEndDate
				oTimeSpan := dEndDate-dStartDate
				//Add time and distance
				oDrNewResultRow["TimeSpentAtSea"] := Math.Round(oTimeSpan:TotalHours,2)
				oDrNewResultRow["Distance"] := dCountDistance
				cArrivingAtEU :=  oRowEnd["ArrivalToEuPort"]:ToString():Trim()
				lArrivingAtEU := ToLogic(cArrivingAtEU)
				// HFO
				cArrivalHFO := oRowEnd["Arrival_HFO"]:ToString():Trim()
				IF cArrivalHFO == ""
					dArrivalHFO := 0
				ELSE
					dArrivalHFO :=  Math.Round(Convert.ToDouble(cArrivalHFO),3)
				ENDIF
				oDrNewResultRow["ArrivalHFO"] :=	dArrivalHFO
				/*
				// LFO
				cArrivalHFO := oRowEnd["Arrival_LFO"]:ToString():Trim()
				IF cArrivalHFO == ""
					dArrivalHFO := 0
				ELSE
					dArrivalHFO :=  Math.Round(Convert.ToDouble(cArrivalHFO),1)
				ENDIF
				oDrNewResultRow["ArrivalLFO"] :=	dArrivalHFO
				*/
				// MDO
				cArrivalMDO := oRowEnd["Arrival_MGO"]:ToString():Trim()
				IF cArrivalMDO == ""
					dArrivalMDO := 0
				ELSE
					dArrivalMDO :=  Math.Round(Convert.ToDouble(cArrivalMDO),3)
				ENDIF
				oDrNewResultRow["ArrivalMDO"] :=	dArrivalMDO
				
				//HFO Voyage Consumption
				dVoyageConsHFO := Math.Round(dDepartureHFO-dArrivalHFO+dBunkeredHFOQuantity,3)
				IF dVoyageConsHFO<0
					dVoyageConsHFO := 0
				ENDIF
				oDrNewResultRow["VoyageHFOCons"] :=	dVoyageConsHFO
				
				//MDO Voyage Consumption
				dVoyageConsMDO := Math.Round(dDepartureMDO-dArrivalMDO+dBunkeredMDOQuantity,3)
				IF dVoyageConsMDO<0
					dVoyageConsMDO := 0
				ENDIF
				oDrNewResultRow["VoyageMDOCons"] :=	dVoyageConsMDO				
				/*
				//Berth Consumption
				cNextPortDepartureHFO := oRowEnd["Departure_HFO"]:ToString():Trim()
				IF cNextPortDepartureHFO == ""
						dNextPortDepartureHFO := 0
				ELSE
						dNextPortDepartureHFO := Math.Round(Convert.ToDouble(cNextPortDepartureHFO),2)
				ENDIF

				IF !lStartFound	//Sto proto leg den exo Berth Consumption 
					lStartFound := TRUE
					dBerthConsHFO := 0
				ELSE
					dBerthConsHFO := Math.Round(dArrivalHFO - dNextPortDepartureHFO + dBunkeredHFOQuantityArrivalPort,2)
				ENDIF

				IF dBerthConsHFO<0
					dBerthConsHFO := 0
				ENDIF
				oDrNewResultRow["BerthHFO"] := dBerthConsHFO
				*/
				IF(lArrivingAtEU)
						oDrNewResultRow["EUBerthHFO"] := dBerthConsHFO
					ELSE
						oDrNewResultRow["EUBerthHFO"] := 0
				ENDIF
				IF lArrivingAtEU || lDepartingFromEU
					oDrNewResultRow["TimeSpentForEUVoyages"] := oDrNewResultRow["TimeSpentAtSea"]
					oDrNewResultRow["DistanceForEUVoyages"] := dCountDistance
					oDrNewResultRow["EUVoyageHFOCons"] := oDrNewResultRow["VoyageHFOCons"]
					oDrNewResultRow["EUVoyageMDOCons"] := oDrNewResultRow["VoyageMDOCons"]
				ELSE
					oDrNewResultRow["EUVoyageMDOCons"] := 0
					oDrNewResultRow["EUVoyageHFOCons"] := 0
					oDrNewResultRow["TimeSpentForEUVoyages"] := "0"
					oDrNewResultRow["DistanceForEUVoyages"] := "0"
				ENDIF
				//iIterate++
				oDTResults:Rows:Add(oDrNewResultRow)
				dtCompletedDateTime := (DateTime)oRowEnd["CompletedGMT"] 
				IF dtCompletedDateTime >= DateTime.ParseExact(cLegEndLocal, "yyyyMMdd HH:mm:ss",null) 
					lStop := TRUE
				ENDIF
				EXIT		
			NEXT
		ENDIF
	NEXT
	
	iCountRows := oDTResults:Rows:Count-1
	LOCAL odtPreviousRow AS DataRow	
	LOCAL dReceivedOnPort := 0 as double
	
	//
	//	Berth
	//

	FOR iIterate:=0 UPTO iCountRows
		dArrivalHFO:=0, dArrivalMDO := 0
		oRowLocal := oDTResults:Rows[iIterate] 

		IF iIterate == 0
			oRowLocal["BerthHFO"] := 0
			oRowLocal["BerthMDO"] := 0
			LOOP
		ENDIF

		oRowLocal := oDTResults:Rows[iIterate] 
		odtPreviousRow := oDTResults:Rows[iIterate-1] 	
		//
		//	HFO	
		//
		dArrivalHFO := Convert.ToDouble(odtPreviousRow["ArrivalHFO"])
		dDepartureHFO := Convert.ToDouble(oRowLocal["DepartureHFO"])
		dReceivedOnPort := Convert.ToDouble(odtPreviousRow["ReceivedOnPortOfArrivalHFO"])

		dBerthConsHFO := ;
				Math.Round(dArrivalHFO - dDepartureHFO + dReceivedOnPort,3)
		IF dBerthConsHFO<0
				dBerthConsHFO := 0
		ENDIF
		oRowLocal["BerthHFO"] := dBerthConsHFO
		//
		//	MDO
		//
		dArrivalMDO := Convert.ToDouble(odtPreviousRow["ArrivalMDO"])
		dDepartureMDO := Convert.ToDouble(oRowLocal["DepartureMDO"])
		dReceivedOnPort := Convert.ToDouble(odtPreviousRow["ReceivedOnPortOfArrivalMDO"])

		dBerthConsMDO := ;
				Math.Round(dArrivalMDO - dDepartureMDO + dReceivedOnPort,3)
		IF dBerthConsMDO<0
				dBerthConsMDO := 0
		ENDIF
		oRowLocal["BerthMDO"] := dBerthConsMDO
		//
		//
		//
		IF (logic)oRowLocal["DepartingFromEuPort"]
			oRowLocal["EUBerthHFO"] := oRowLocal["BerthHFO"]
			oRowLocal["EUBerthMDO"] := oRowLocal["BerthMDO"]
		ENDIF
	NEXT

	//
	//	Compute CO2
	//

	Local dTotalCO2Emitted, dCO2EmittedOnEUVoyage, dCO2EmittedOnVoyageDepartedFromEUPort as double	
	Local dCO2EmittedOnVoyageArrivedToEUPort, dCO2EmittedAtBerth, dCO2EmittedAtEuPort, dTotalCO2VoyageAndBerth as double	
	FOR iIterate:=0 UPTO iCountRows
		dTotalCO2Emitted:=0
		dCO2EmittedOnEUVoyage := 0
		dCO2EmittedOnVoyageDepartedFromEUPort := 0
		dCO2EmittedOnVoyageArrivedToEUPort := 0
		dCO2EmittedAtBerth := 0
		dCO2EmittedAtEuPort := 0
		dTotalCO2VoyageAndBerth := 0
		oRowLocal := oDTResults:Rows[iIterate] 
	
		IF oRowLocal["VoyageHFOCons"] != null
			dVoyageConsHFO := Convert.ToDouble(oRowLocal["VoyageHFOCons"])
		ELSE
			dVoyageConsHFO := 0 
		ENDIF
		
		IF oRowLocal["VoyageMDOCons"] != null
			dVoyageConsMDO := Convert.ToDouble(oRowLocal["VoyageMDOCons"])
		ELSE
			dVoyageConsMDO := 0 
		ENDIF
		
		dTotalCO2Emitted := 3.114*dVoyageConsHFO+dVoyageConsMDO*3.206

		IF (LOGIC)oRowLocal["DepartingFromEuPort"] || (LOGIC)oRowLocal["ArrivalToEuPort"]
			dCO2EmittedOnEUVoyage := dTotalCO2Emitted
		ENDIF
		IF (LOGIC)oRowLocal["DepartingFromEuPort"] 
			dCO2EmittedOnVoyageDepartedFromEUPort := dTotalCO2Emitted
		ENDIF
		IF (LOGIC)oRowLocal["ArrivalToEuPort"] 
			dCO2EmittedOnVoyageArrivedToEUPort := dTotalCO2Emitted
		ENDIF
		
		IF oRowLocal["BerthHFO"] != null
			dVoyageConsHFO := Convert.ToDouble(oRowLocal["BerthHFO"])
		ELSE
			dVoyageConsHFO := 0 
		ENDIF
	
		IF oRowLocal["BerthMDO"] != null
			dVoyageConsMDO := Convert.ToDouble(oRowLocal["BerthMDO"])
		ELSE
			dVoyageConsMDO := 0 
		ENDIF
	
		dCO2EmittedAtBerth := 3.114*dVoyageConsHFO+dVoyageConsMDO*3.206

		IF (LOGIC)oRowLocal["ArrivalToEuPort"]
			dCO2EmittedAtEuPort := dCO2EmittedAtBerth
		ENDIF

		dTotalCO2VoyageAndBerth := dTotalCO2Emitted + dCO2EmittedAtBerth

		oRowLocal["TotalCO2Emitted"] := Math.Round(dTotalCO2Emitted,3)
		oRowLocal["CO2EmittedOnEUVoyage"] := Math.Round(dCO2EmittedOnEUVoyage,3)
		oRowLocal["CO2EmittedOnVoyageDepartedFromEUPort"] := Math.Round(dCO2EmittedOnVoyageDepartedFromEUPort,3)
		oRowLocal["CO2EmittedOnVoyageArrivedToEUPort"] := Math.Round(dCO2EmittedOnVoyageArrivedToEUPort,3)
		oRowLocal["CO2EmittedAtBerth"] := Math.Round(dCO2EmittedAtBerth,3)
		oRowLocal["CO2EmittedAtEuPort"] := Math.Round(dCO2EmittedAtEuPort,3)
		oRowLocal["TotalCO2VoyageAndBerth"] := Math.Round(dTotalCO2VoyageAndBerth,3)

	NEXT

	SELF:oDTMyResults := oDTResults	

RETURN

PRIVATE METHOD gridView1CellValueChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs) AS VOID
	local oTempRow := gridView1:GetFocusedDataRow() as DataRow
    IF e:Column:FieldName == "CargoCarried" || e:Column:FieldName == "colTotalValue"
		local dDistance := Convert.ToDouble(oTempRow["Distance"]) as double
		LOCAL dCargoCarried := Convert.ToDouble(oTempRow["CargoCarried"]) as double
		LOCAL dTransportWork := Math.Round(dDistance * dCargoCarried,3)
		oTempRow["TransportWork"] := dTransportWork

		IF (LOGIC)oTempRow["DepartingFromEuPort"] && (LOGIC)oTempRow["ArrivalToEuPort"]
			oTempRow["TransportWorkForEU"] := oTempRow["TransportWork"]
		ELSE
			oTempRow["TransportWorkForEU"] := 0
		ENDIF

		IF dTransportWork > 0
			local dTotalCO2VoyageAndBerth := Convert.ToDouble(oTempRow["TotalCO2VoyageAndBerth"]) as double
			oTempRow["EEOI"] := Math.Round((double)(dTotalCO2VoyageAndBerth*1000000/dTransportWork),3)
		ENDIF

		oTempRow:AcceptChanges()
    ENDIF
RETURN

End CLASS