// Class_CustomItems.prg
#Using System.Data.Common

STATIC CLASS CustomItems
	// Voyage
	STATIC EXPORT Voyage_ID := "2000" AS STRING	
	STATIC EXPORT Voyage_Text := "Voyage" AS STRING

	STATIC EXPORT VoyageSailed_ID := "2001" AS STRING	
	STATIC EXPORT VoyageSailed_Text := "Voyage sailed" AS STRING

	STATIC EXPORT VoyageArrived_ID := "2002" AS STRING	
	STATIC EXPORT VoyageArrived_Text := "Voyage arrived" AS STRING

	STATIC EXPORT VoyageDaysSinceSailing_ID := "2003" AS STRING	
	STATIC EXPORT VoyageDaysSinceSailing_Text := "Voyage Days since sailing" AS STRING

	STATIC EXPORT VoyageConsumption_ID := "2004" AS STRING	
	STATIC EXPORT VoyageConsumption_Text := "Voyage consumption ME+DG" AS STRING

	STATIC EXPORT VoyageMilesAlreadyTravelled_ID := "2009" AS STRING	
	STATIC EXPORT VoyageMilesAlreadyTravelled_Text := "Voyage Miles already travelled" AS STRING

	STATIC EXPORT VoyageDGConPerDay_ID := "2010" AS STRING	
	STATIC EXPORT VoyageDGConPerDay_Text := "DG consumption per Day" AS STRING

	// Routing
	STATIC EXPORT Routing_ID := "1000" AS STRING	
	STATIC EXPORT Routing_Text := "Routing" AS STRING

	STATIC EXPORT RoutingSailed_ID := "1001" AS STRING	
	STATIC EXPORT RoutingSailed_Text := "Routing sailed" AS STRING

	STATIC EXPORT RoutingArrived_ID := "1002" AS STRING	
	STATIC EXPORT RoutingArrived_Text := "Routing arrived" AS STRING

	STATIC EXPORT RoutingDaysSinceSailing_ID := "1003" AS STRING	
	STATIC EXPORT RoutingDaysSinceSailing_Text := "Routing Days since sailing" AS STRING

	STATIC EXPORT RoutingConsumption_ID := "1004" AS STRING	
	STATIC EXPORT RoutingConsumption_Text := "Routing consumption ME+DG" AS STRING

	STATIC EXPORT TCEquivalentUSD_ID := "1005" AS STRING	
	STATIC EXPORT TCEquivalentUSD_Text := "TC Equivalent" AS STRING

	STATIC EXPORT RoutingOnSailingFOROB_ID := "1006" AS STRING	
	STATIC EXPORT RoutingOnSailingFOROB_Text := "Routing On sailing FO ROB" AS STRING

	STATIC EXPORT RoutingPriceFOPerTon_ID := "1007" AS STRING	
	STATIC EXPORT RoutingPriceFOPerTon_Text := "Price FO per ton" AS STRING

	STATIC EXPORT RoutingMilesSailedToday_ID := "1008" AS STRING	
	STATIC EXPORT RoutingMilesSailedToday_Text := "Miles sailed today" AS STRING

	STATIC EXPORT RoutingMilesAlreadyTravelled_ID := "1009" AS STRING	
	STATIC EXPORT RoutingMilesAlreadyTravelled_Text := "Routing Miles already travelled" AS STRING

	STATIC EXPORT RoutingActualFOROB_ID := "1010" AS STRING	
	STATIC EXPORT RoutingActualFOROB_Text := "Actual FO ROB" AS STRING

	STATIC EXPORT RoutingTimeCost_ID := "1011" AS STRING	
	STATIC EXPORT RoutingTimeCost_Text := "Time cost" AS STRING

	STATIC EXPORT RoutingFuelCost_ID := "1012" AS STRING	
	STATIC EXPORT RoutingFuelCost_Text := "Fuel cost" AS STRING

	STATIC EXPORT RoutingTotalCost_ID := "1013" AS STRING	
	STATIC EXPORT RoutingTotalCost_Text := "Total cost" AS STRING
		
END CLASS


PARTIAL CLASS SQLTablesCreator

METHOD Fill_FMCustomItems(oGFH AS GenericFactoryHelper, oConn AS DBConnection) AS LOGIC
	LOCAL cStatement AS STRING
	LOCAL nCnt AS INT

	// Routing
	cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
				" ("+CustomItems.Routing_ID+", '"+CustomItems.Routing_Text+"', 'Info about Voyage Routing (FromPort/ToPort/Distance/Commenced/Completed', 'Text')"
	IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
		RETURN FALSE
	ENDIF
	nCnt++

	cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
				" ("+CustomItems.RoutingSailed_ID+", '"+CustomItems.RoutingSailed_Text+"', 'Info about Voyage Routing''s sailed (Commenced)', 'Date')"
	IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
		RETURN FALSE
	ENDIF
	nCnt++

	cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
				" ("+CustomItems.RoutingArrived_ID+", '"+CustomItems.RoutingArrived_Text+"', 'Info about Voyage Routing''s arrived (Completed)', 'Date')"
	IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
		RETURN FALSE
	ENDIF
	nCnt++

	cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
				" ("+CustomItems.RoutingDaysSinceSailing_ID+", '"+CustomItems.RoutingDaysSinceSailing_Text+"', 'Info about all Voyage Routings Days since sailing', 'Days')"
	IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
		RETURN FALSE
	ENDIF
	nCnt++

	//cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
	//			" ("+CustomItems.RoutingConsumption_ID+", '"+CustomItems.RoutingConsumption_Text+"', 'Info about Voyage Routing''s consumption', 'Kg/Nm')"
	//IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
	//	RETURN FALSE
	//ENDIF
	//nCnt++

	cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
				" ("+CustomItems.TCEquivalentUSD_ID+", '"+CustomItems.TCEquivalentUSD_Text+"', 'The Voyage Routing''s TC Equivalent', 'USD')"
	IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
		RETURN FALSE
	ENDIF
	nCnt++

	cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
				" ("+CustomItems.RoutingOnSailingFOROB_ID+", '"+CustomItems.RoutingOnSailingFOROB_Text+"', 'The Voyage Routing''s On sailing FO ROB', 'MT')"
	IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
		RETURN FALSE
	ENDIF
	nCnt++

	cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
				" ("+CustomItems.RoutingPriceFOPerTon_ID+", '"+CustomItems.RoutingPriceFOPerTon_Text+"', 'The Voyage Routing''s Price FO per ton', 'USD')"
	IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
		RETURN FALSE
	ENDIF
	nCnt++

	//cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
	//			" ("+CustomItems.RoutingMilesSailedToday_ID+", '"+CustomItems.RoutingMilesSailedToday_Text+"', 'Info about Voyage Routing''s Miles sailed today', 'Nm')"
	//IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
	//	RETURN FALSE
	//ENDIF
	//nCnt++

	//cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
	//			" ("+CustomItems.RoutingMilesAlreadyTravelled_ID+", '"+CustomItems.RoutingMilesAlreadyTravelled_Text+"', 'Info about Voyage Routing''s Miles already travelled', 'Nm')"
	//IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
	//	RETURN FALSE
	//ENDIF
	//nCnt++

	//cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
	//			" ("+CustomItems.RoutingActualFOROB_ID+", '"+CustomItems.RoutingActualFOROB_Text+"', 'Info about Voyage Routing''s Actual FO ROB', 'MT')"
	//IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
	//	RETURN FALSE
	//ENDIF
	//nCnt++

	//IF cLicensedCompany:ToUpper():Contains("LARUS")
	//	cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
	//				" ("+CustomItems.RoutingTimeCost_ID+", '"+CustomItems.RoutingTimeCost_Text+"', 'Info about Voyage Routing''s Time cost', 'USD')"
	//	IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
	//		RETURN FALSE
	//	ENDIF
	//	nCnt++

	//	cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
	//				" ("+CustomItems.RoutingFuelCost_ID+", '"+CustomItems.RoutingFuelCost_Text+"', 'Info about Voyage Routing''s Fuel cost', 'USD')"
	//	IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
	//		RETURN FALSE
	//	ENDIF
	//	nCnt++

	//	cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
	//				" ("+CustomItems.RoutingTotalCost_ID+", '"+CustomItems.RoutingTotalCost_Text+"', 'Info about Voyage Routing''s Total cost', 'USD')"
	//	IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
	//		RETURN FALSE
	//	ENDIF
	//	nCnt++
	//ENDIF


	// Voyage
	cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
				" ("+CustomItems.Voyage_ID+", '"+CustomItems.Voyage_Text+"', 'Info about Voyage (Description/FromPort/ToPort/Distance/StartDate/EndDate', 'Text')"
	IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
		RETURN FALSE
	ENDIF
	nCnt++

	cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
				" ("+CustomItems.VoyageSailed_ID+", '"+CustomItems.VoyageSailed_Text+"', 'Info about Voyage''s first sailing (StartDate)', 'Date')"
	IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
		RETURN FALSE
	ENDIF
	nCnt++

	cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
				" ("+CustomItems.VoyageArrived_ID+", '"+CustomItems.VoyageArrived_Text+"', 'Info about Voyage''s last arrival (EndDate)', 'Date')"
	IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
		RETURN FALSE
	ENDIF
	nCnt++

	cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
				" ("+CustomItems.VoyageDaysSinceSailing_ID+", '"+CustomItems.VoyageDaysSinceSailing_Text+"', 'Info about all Voyage Routing''s Days since sailing', 'Days')"
	IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
		RETURN FALSE
	ENDIF
	nCnt++

	//cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
	//			" ("+CustomItems.VoyageConsumption_ID+", '"+CustomItems.VoyageConsumption_Text+"', 'Info about all Voyage Routings consumptions', 'Kg/Nm')"
	//IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
	//	RETURN FALSE
	//ENDIF
	//nCnt++

	//cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
	//			" ("+CustomItems.VoyageMilesAlreadyTravelled_ID+", '"+CustomItems.VoyageMilesAlreadyTravelled_Text+"', 'Info about all Voyage Miles already travelled', 'Nm')"
	//IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
	//	RETURN FALSE
	//ENDIF
	//nCnt++

	//cStatement:="INSERT INTO FMCustomItems (ID, Description, FriedlyDescription, Unit) VALUES"+;
	//			" ("+CustomItems.VoyageDGConPerDay_ID+", '"+CustomItems.VoyageDGConPerDay_Text+"', 'Info about Vessel''s DG consumption per Day', 'Kg')"
	//IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
	//	RETURN FALSE
	//ENDIF
	//nCnt++

	InfoBox(nCnt:ToString()+" Custom Items added to Table: FMCustomItems", "Complete")
RETURN TRUE

END CLASS
   