// MRVResutlForm.prg
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
		SELF:gridControl1:Refresh()	

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
	cStatement:=" SELECT EconVoyages.VoyageNo, "+cConditionCaseSql+" , EconRoutings.*, "+;
				" RTrim(VEPortsFrom.Port) AS PortFrom, VEPortsFrom.EUPORT AS DepartingFromEuPort, "+;
				" RTrim(VEPortsTo.Port) AS PortTo, VEPortsTo.EUPORT AS ArrivalToEuPort,"+;
				" MatchedWithArrival, Arrival_HFO AS ArrHFO, Arrival_LFO AS ArrLFO, Arrival_MGO AS ArrMGO,"+;
				" MatchedWithDeparture, Departure_HFO AS DepHFO, Departure_LFO AS DepLFO, Departure_MGO AS DepMGO,"+;
				" Arrival_HFO, Arrival_LFO, Arrival_MGO, Departure_HFO, Departure_LFO, Departure_MGO"+;
				" FROM EconRoutings "+;
				" INNER JOIN EconVoyages ON EconVoyages.VOYAGE_UID=EconRoutings.VOYAGE_UID"+;
				" LEFT OUTER JOIN VEPorts AS VEPortsFrom ON EconRoutings.PortFrom_UID=VEPortsFrom.PORT_UID"+;
				" LEFT OUTER JOIN VEPorts AS VEPortsTo ON EconRoutings.PortTo_UID=VEPortsTo.PORT_UID"+;
				" LEFT OUTER JOIN FMRoutingAdditionalData ON FMRoutingAdditionalData.Routing_UID = EconRoutings.ROUTING_UID"+;
				" WHERE EconRoutings.CompletedGMT >= '"+ cLegStartLocal+"' AND EconRoutings.CommencedGMT <= '"+cLegEndLocal+"' "+;
				" AND EconVoyages.VESSEL_UNIQUEID = "+ self:cMyVesselUID+;
				" ORDER BY EconRoutings.CommencedGMT ASC "
	LOCAL oDTRoutingsLocal := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

	//Φτιάχνω ένα datatable για να βάλω τα αποτελέσματα
	LOCAL oDTResults := DataTable{} AS DataTable
	oDTResults:Columns:Add("VoyageNo", typeof(String))
	oDTResults:Columns:Add("Condition", typeof(String))
	oDTResults:Columns:Add("PortOfDeparture", typeof(String))
	oDTResults:Columns:Add("DepartingFromEuPort", typeof(logic))
	oDTResults:Columns:Add("PortOfArrival", typeof(String))
	oDTResults:Columns:Add("ArrivalToEuPort", typeof(logic))
	oDTResults:Columns:Add("VoyageStartDate", typeof(DateTime))
	oDTResults:Columns:Add("VoyageEndDate", typeof(DateTime))
	oDTResults:Columns:Add("TimeSpentAtSea", typeof(decimal))
	oDTResults:Columns:Add("TimeSpentForEUVoyages", typeof(decimal))
	oDTResults:Columns:Add("Distance", typeof(decimal))
	oDTResults:Columns:Add("DistanceForEUVoyages", typeof(decimal))
	oDTResults:Columns:Add("DepartureHFO", typeof(decimal))
	oDTResults:Columns:Add("ArrivalHFO", typeof(decimal))
	oDTResults:Columns:Add("VoyageHFOCons", typeof(decimal))
	oDTResults:Columns:Add("BirthHFO", typeof(decimal))
	oDTResults:Columns:Add("EUBirthHFO", typeof(decimal))


	//Μεταβλητές για μέσα στο loop
	LOCAL cCondition := "", cNextCondition:="",cDepartingFromEU, cArrivingAtEU AS STRING
	LOCAL cStartDate:="", cEndDate:="", cDistance:="" AS STRING
	LOCAL dStartDate, dEndDate AS DateTime
	LOCAL oTimeSpan AS TimeSpan
	LOCAL lDepartingFromEU, lArrivingAtEU as LOGIC
	LOCAL cDepartureHFO:="", cArrivalHFO:="", cVoyageConsHFO:="" AS String
	LOCAL dDepartureHFO:=0, dArrivalHFO:=0, dVoyageConsHFO:=0 AS double
	LOCAL cNextPortDepartureHFO := "" as String
	Local dNextPortDepartureHFO := 0 As double
	Local dBirthConsHFO :=0 as double
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

	FOR iIterate:=0 UPTO iCountRows
		cDistance := "0"
		dCountDistance := 0
		oRowLocal := oDTRoutingsLocal:Rows[iIterate] 
		cCondition := oRowLocal["VoyageCondition"]:ToString()

		IF cCondition == "Ballast" && cCondition == "Laden"  && cCondition == "Idle" 
			LOOP
		ELSE
			oDrNewResultRow := oDTResults:NewRow()
			oDrNewResultRow["VoyageNo"] := oRowLocal["VoyageNo"]
			oDrNewResultRow["Condition"] := cCondition
			oDrNewResultRow["PortOfDeparture"] := oRowLocal["PortFrom"]
			oDrNewResultRow["DepartingFromEuPort"] := oRowLocal["DepartingFromEuPort"]
			lDepartingFromEU := ToLogic(cDepartingFromEU)
			cStartDate := oRowLocal["CommencedGMT"]:ToString()
			dStartDate := DateTime.Parse(cStartDate)
			oDrNewResultRow["VoyageStartDate"] := dStartDate //:ToString():Trim()
			cDistance := oRowLocal["Distance"]:ToString():Trim()
			IF cDistance==""
				cDistance := "0"
			ENDIF
			dCountDistance += Convert.ToDouble(cDistance)
			FOR iFindNextRow:=iIterate+1 UPTO iCountRows
				oRowEnd := oDTRoutingsLocal:Rows[iFindNextRow]			
				cCondition := oRowEnd["VoyageCondition"]:ToString()
				IF	cCondition == "Ballast" || cCondition == "Laden" || cCondition == "Idle"
					cDistance := oRowEnd["Distance"]:ToString():Trim()
					IF cDistance==""
						cDistance := "0"
					ENDIF
					dCountDistance += Convert.ToDouble(cDistance)
					iIterate++
					LOOP
				ENDIF
				oDrNewResultRow["PortOfArrival"] := oRowEnd["PortTo"]
				oDrNewResultRow["ArrivalToEuPort"] := oRowEnd["ArrivalToEuPort"]
				cEndDate := oRowEnd["CommencedGMT"]:ToString()
				dEndDate := DateTime.Parse(cEndDate)
				oDrNewResultRow["VoyageEndDate"] := dEndDate
				oTimeSpan := dEndDate-dStartDate
				oDrNewResultRow["TimeSpentAtSea"] := Math.Round(oTimeSpan:TotalHours,2)
				oDrNewResultRow["Distance"] := dCountDistance
				cArrivingAtEU :=  oRowEnd["ArrivalToEuPort"]:ToString():Trim()
				lArrivingAtEU := ToLogic(cArrivingAtEU)
				cDepartureHFO := oRowLocal["Departure_HFO"]:ToString():Trim()
				IF cDepartureHFO == ""
					dDepartureHFO := 0
				ELSE
					dDepartureHFO :=  Math.Round(Convert.ToDouble(cDepartureHFO),1)
				ENDIF

				cArrivalHFO := oRowEnd["Arrival_HFO"]:ToString():Trim()
				IF cArrivalHFO == ""
					dArrivalHFO := 0
				ELSE
					dArrivalHFO :=  Math.Round(Convert.ToDouble(cArrivalHFO),1)
				ENDIF

				dVoyageConsHFO := Math.Round(dDepartureHFO-dArrivalHFO,1)
				oDrNewResultRow["DepartureHFO"] :=	dDepartureHFO
				oDrNewResultRow["ArrivalHFO"] :=	dArrivalHFO
				oDrNewResultRow["VoyageHFOCons"] :=	dVoyageConsHFO
				cNextPortDepartureHFO := oRowEnd["Departure_HFO"]:ToString():Trim()
				IF cNextPortDepartureHFO == ""
						dNextPortDepartureHFO := 0
				ELSE
						dNextPortDepartureHFO := Math.Round(Convert.ToDouble(cNextPortDepartureHFO),1)
				ENDIF
				dBirthConsHFO := Math.Round(dArrivalHFO - dNextPortDepartureHFO,2)
				oDrNewResultRow["BirthHFO"] := dBirthConsHFO
				IF(lArrivingAtEU)
						oDrNewResultRow["EUBirthHFO"] := dBirthConsHFO
					ELSE
						oDrNewResultRow["EUBirthHFO"] := 0
				ENDIF
				IF(lArrivingAtEU || lDepartingFromEU)
					oDrNewResultRow["TimeSpentForEUVoyages"] := oTimeSpan:TotalHours
					oDrNewResultRow["DistanceForEUVoyages"] := oRowLocal["Distance"]
				ELSE
					oDrNewResultRow["TimeSpentForEUVoyages"] := "0"
					oDrNewResultRow["DistanceForEUVoyages"] := "0"
				ENDIF
				iIterate++
				oDTResults:Rows:Add(oDrNewResultRow)
				EXIT		
			NEXT
		ENDIF
	NEXT
	SELF:oDTMyResults := oDTResults	

RETURN

End CLASS