// _CreateSQLTables.prg
#Using System.Data
#Using System.Data.Common

PARTIAL CLASS SQLTablesCreator

METHOD CreateTables(oGFH AS GenericFactoryHelper, oConn AS DBConnection) AS LOGIC
	LOCAL cStatement AS STRING

	TRY
		// Vessels, PosFlags, PosClass
		oSoftway:CreateVesselTablesCommon(oGFH, oConn)

		// VEPorts: The Country must be NOT NULL Default '' to return a non-NULL value into the ConcatSelect
		oSoftway:CreatePortsDistancesTables(oGFH, oConn)

		// EconFleet
		IF ! oSoftway:TableExists(oGFH, oConn, "EconFleet")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"EconFleet ("+;
			"FLEET_UID			"+oSoftway:cIdentity+","+;
			"Description		"+oSoftway:FieldVarChar+" (128) NULL,"+;
			"PRIMARY KEY (FLEET_UID)"+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF

		// SupVessels
		IF ! oSoftway:TableExists(oGFH, oConn, "SupVessels")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"SupVessels ("+;
				"VESSEL_UNIQUEID		int NOT NULL,"+;
				"Active					bit NOT NULL DEFAULT 1,"+;
				"VslCode    			"+oSoftway:FieldVarChar+" (6) NULL,"+;
				"PropellerPitch			float NULL,"+;
				"MaxPowerOfEngine		int NULL,"+;
				"FLEET_UID				INT NOT NULL Default 0,"+;
				"PRIMARY KEY (VESSEL_UNIQUEID)"+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)

			//IF oMainForm:ProgramLocation == "SHIP"
			//	// Create the default Vessel
			//	TRY
			//		oSoftway:SetIdentityInsert("VESSELS", "ON", oGFH, oConn)
			//		cStatement:="INSERT INTO VESSELS (VESSEL_UNIQUEID, VesselName) VALUES"+;
			//					" ("+oMainForm:VesselCode+", '"+oSoftway:ConvertWildcards(oMainForm:VesselName, FALSE)+"')"
			//		IF oSoftway:AdoCommand(oGFH, oConn, cStatement)
			//			// Add it to SupVessels
			//			cStatement:="INSERT INTO SupVessels (VESSEL_UNIQUEID, PropellerPitch) VALUES"+;
			//						" ("+oMainForm:VesselCode+", 0)"
			//			oSoftway:AdoCommand(oGFH, oConn, cStatement)
			//		ELSE
			//			ErrorBox("Cannot insert the default Vessel into [VESSELS]")
			//		ENDIF
			//	CATCH e AS Exception
			//		ErrorBox(e:Message)
			//	FINALLY
			//		oSoftway:SetIdentityInsert("VESSELS", "OFF", oGFH, oConn)
			//	END TRY
			//ENDIF
		ENDIF

		IF ! oSoftway:TableExists(oGFH, oConn, "FMReportTypes")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMReportTypes ("+;
						"REPORT_UID			"+oSoftway:cIdentity+","+;
						"ReportName			"+oSoftway:FieldVarChar+"(128) NULL,"+;
						"ReportBaseNum		"+oSoftway:FieldVarChar+"(5) NULL,"+;
						"ReportColor		int NOT NULL Default 0,"+;
						"PRIMARY KEY (REPORT_UID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)

			cStatement:="CREATE UNIQUE INDEX FMReportName ON FMReportTypes (ReportName)"
			oSoftway:AdoCommand(oGFH, oConn, cStatement)

			SELF:AddReportTypes(oGFH, oConn)
		ENDIF

		IF ! oSoftway:TableExists(oGFH, oConn, "FMReportTypesVessel")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMReportTypesVessel ("+;
						"REPORT_UID				int NOT NULL,"+;
						"VESSEL_UNIQUEID		int NOT NULL,"+;
						"PRIMARY KEY (REPORT_UID, VESSEL_UNIQUEID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)

			SELF:AddReportTypesVessel(oGFH, oConn)
		ENDIF
		
		
		IF ! oSoftway:TableExists(oGFH, oConn, "FMGlobalSettings")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMGlobalSettings ("+;
						"Arrival_REPORT_UID				int NOT NULL Default 0,"+;
						"ArrivalDate_ITEM_UID			int NULL Default 0,"+;
						"Departure_REPORT_UID			int NOT NULL Default 0,"+;
						"DepartureDate_ITEM_UID			int NULL Default 0,"+;
						"DepartureNextPort_ITEM_UID		int NOT NULL Default 0,"+;
						"DepartureEtaNextPort_ITEM_UID	int NOT NULL Default 0,"+;
						"VESSEL_UNIQUEID				int NOT NULL,"+;
						"PRIMARY KEY (VESSEL_UNIQUEID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF

		IF ! oSoftway:TableExists(oGFH, oConn, "FMTrueGlobalSettings")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMTrueGlobalSettings ("+;
						"SMTP_Server			"+oSoftway:FieldVarChar+"(256) NULL,"+;
						"SMTP_Sender			"+oSoftway:FieldVarChar+"(256) NULL,"+;
						"SMTP_Port				"+oSoftway:FieldVarChar+"(128) NULL,"+;
						"SMTP_UserName			"+oSoftway:FieldVarChar+"(256) NULL,"+;
						"SMTP_Pass				"+oSoftway:FieldVarChar+"(256) NULL,"+;
						"SMTP_Secure			bit NOT NULL DEFAULT 0,"+;
						"Setting_UNIQUEID		"+oSoftway:cIdentity+","+;
						"PRIMARY KEY (Setting_UNIQUEID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF

		IF ! oSoftway:TableExists(oGFH, oConn, "FMRoutingAdditionalData")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMRoutingAdditionalData ("+;
						"AdditionalData_UID		"+oSoftway:cIdentity+","+;
						"Routing_UID			int NOT NULL Default 0,"+;
						"MatchedWithArrival		bit NOT NULL DEFAULT 0,"+;
						"MatchedWithDeparture	bit NOT NULL DEFAULT 0,"+;
						"Arrival_Date			datetime NULL,"+;
						"Arrival_HFO			float NOT NULL Default 0,"+;
						"Arrival_LFO			float NULL Default 0,"+;
						"Arrival_MGO			float NULL Default 0,"+;
						"Departure_Date			datetime NULL,"+;
						"Departure_HFO			float NOT NULL Default 0,"+;
						"Departure_LFO			float NULL Default 0,"+;
						"Departure_MGO			float NULL Default 0,"+;
						"Bunkered_HFO			float NOT NULL Default 0,"+;
						"Bunkered_LFO			float NOT NULL Default 0,"+;
						"Bunkered_MDO			float NOT NULL Default 0,"+;
						"Update_Date			datetime NOT NULL Default CURRENT_TIMESTAMP,"+;
						"Update_User			int NOT NULL Default 0,"+;
						"PRIMARY KEY (AdditionalData_UID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF

		IF ! oSoftway:TableExists(oGFH, oConn, "FMReportItems")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMReportItems ("+;
						"ITEM_UID			"+oSoftway:cIdentity+","+;
						"REPORT_UID			int NOT NULL,"+;
						"ItemNo				"+oSoftway:FieldVarChar+"(5) NULL,"+;
						"ItemName			"+oSoftway:FieldVarChar+"(512) NULL,"+;
						"ItemType			"+oSoftway:FieldChar+"(1) NULL,"+;
						"Unit				"+oSoftway:FieldVarChar+"(30) NOT NULL Default ' ',"+;
						"ExpDays			smallint NULL,"+;
						"CATEGORY_UID		int NOT NULL Default 0,"+;
						"Mandatory			bit NOT NULL DEFAULT 1,"+;
						"CalculatedField	"+oSoftway:FieldVarChar+" (1000) NULL,"+;
						"MinValue			float NULL,"+;
						"MaxValue			float NULL,"+;
						"ShowOnMap			bit NOT NULL DEFAULT 0,"+;
						"ShowOnlyOffice		bit NOT NULL DEFAULT 0,"+;
						"IsDD				bit NOT NULL DEFAULT 0,"+;
						"NotNumbered		bit NOT NULL DEFAULT 0,"+;
						"ItemTypeValues		"+oSoftway:FieldVarChar+"(1000) NULL,"+;
						"PRIMARY KEY (ITEM_UID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)

			cStatement:="CREATE INDEX FMReportsItems ON FMReportItems (REPORT_UID, ITEM_UID)"
			oSoftway:AdoCommand(oGFH, oConn, cStatement)

			//cStatement:="CREATE UNIQUE INDEX FMItemName ON FMReportItems (REPORT_UID, ItemName)"
			//oSoftway:AdoCommand(oGFH, oConn, cStatement)

			cStatement:="CREATE UNIQUE INDEX FMItemNo ON FMReportItems (ItemNo)"
			oSoftway:AdoCommand(oGFH, oConn, cStatement)

			//cStatement:="CREATE UNIQUE INDEX FMItemNo ON FMReportItems (REPORT_UID, ItemNo)"
			//oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF
		
		IF ! oSoftway:TableExists(oGFH, oConn, "FMOfficeReportItems")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMOfficeReportItems ("+;
						"ITEM_UID			int NOT NULL,"+;
						"Groups_Owners		"+oSoftway:FieldVarChar+"(512) NULL,"+;
						"PRIMARY KEY (ITEM_UID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF

		IF ! oSoftway:TableExists(oGFH, oConn, "FMDataPackages")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMDataPackages ("+;
						"PACKAGE_UID		"+oSoftway:cIdentity+","+;
						"VESSEL_UNIQUEID	int NOT NULL,"+;
						"REPORT_UID			int NOT NULL,"+;
						"DateTimeGMT		datetime NOT NULL,"+;
						"GmtDiff			decimal(3, 1) NOT NULL,"+;
						"Latitude			"+oSoftway:FieldVarChar+" (10) NULL,"+;
						"N_OR_S				"+oSoftway:FieldChar+" (1) NULL,"+;
						"Longitude			"+oSoftway:FieldVarChar+" (10) NULL,"+;
						"W_OR_E				"+oSoftway:FieldChar+" (1) NULL,"+;
						"MSG_UNIQUEID		int NOT NULL Default 0,"+;
						"Visible			smallint NOT NULL Default 1,"+;
						"Matched			smallint NOT NULL Default 0,"+;
						"Status				smallint NOT NULL Default 0,"+;
						"Username			"+oSoftway:FieldVarChar+" (128) NULL Default NULL,"+;
						"Memo				"+oSoftway:FieldText+" NULL ,"+;
						"PRIMARY KEY (PACKAGE_UID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
			//cStatement:="CREATE UNIQUE INDEX FMDataPackagesVessel ON FMDataPackages (Visible, VESSEL_UNIQUEID, REPORT_UID, DateTimeGMT)"
			//oSoftway:AdoCommand(oGFH, oConn, cStatement)

			cStatement:="CREATE INDEX FMDataPackagesReport ON FMDataPackages (REPORT_UID, DateTimeGMT)"
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF

		IF ! oSoftway:TableExists(oGFH, oConn, "FMData")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMData ("+;
						"PACKAGE_UID		int NOT NULL,"+;
						"ITEM_UID			int NOT NULL,"+;
						"Data				"+oSoftway:FieldVarChar+" (128) NULL,"+;
						"PRIMARY KEY (PACKAGE_UID, ITEM_UID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF
		
		IF ! oSoftway:TableExists(oGFH, oConn, "FMBlobData")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMBlobData ("+;
						"PACKAGE_UID		int NOT NULL,"+;
						"ITEM_UID			int NOT NULL,"+;
						"FileName			"+oSoftway:FieldVarChar+" (256) NOT NULL,"+;
						"BlobData			"+oSoftway:FieldImage+" NULL, "+;
						"USER_UNIQUEID		int NOT NULL Default 0,"+;
						"Visible			smallint NOT NULL Default 1,"+;
						"PRIMARY KEY (PACKAGE_UID, ITEM_UID, FileName, Visible) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF
		
		IF ! oSoftway:TableExists(oGFH, oConn, "FMAlteredData")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMAlteredData ("+;
						"PACKAGE_UID		int NOT NULL,"+;
						"ITEM_UID			int NOT NULL,"+;
						"DateTime		datetime NOT NULL,"+;
						"USER_UNIQUEID		int NOT NULL,"+;
						"Data				"+oSoftway:FieldVarChar+" (128) NULL,"+;
						"PRIMARY KEY (PACKAGE_UID, ITEM_UID, DateTime) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF
		
		IF ! oSoftway:TableExists(oGFH, oConn, "FMAlteredMemos")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMAlteredMemos ("+;
						"PACKAGE_UID		int NOT NULL,"+;
						"Memo				"+oSoftway:FieldText+" NULL ,"+;
						"DateTime		datetime NOT NULL,"+;
						"USER_UNIQUEID		int NOT NULL,"+;
						"PRIMARY KEY (PACKAGE_UID, DateTime) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF

		IF ! oSoftway:TableExists(oGFH, oConn, "FMItemCategories")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMItemCategories ("+;
						"CATEGORY_UID		"+oSoftway:cIdentity+","+;
						"Description		"+oSoftway:FieldVarChar+"(128) NULL,"+;
						"SortOrder			smallint NULL,"+;
						"PRIMARY KEY (CATEGORY_UID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF

		IF ! oSoftway:TableExists(oGFH, oConn, "FMUserVessels")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMUserVessels ("+;
						"USER_UNIQUEID		int NOT NULL,"+;
						"VESSEL_UNIQUEID	int NOT NULL,"+;
						"PRIMARY KEY (USER_UNIQUEID, VESSEL_UNIQUEID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF

		IF ! oSoftway:TableExists(oGFH, oConn, "FMBodyText")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMBodyText ("+;
						"REPORT_UID		int NOT NULL,"+;
						"eMail			"+oSoftway:FieldVarChar+"(128) NULL,"+;
						"BodyText		"+oSoftway:FieldText+" NULL,"+;
						"PRIMARY KEY (REPORT_UID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF

		IF ! oSoftway:TableExists(oGFH, oConn, "EconVoyages")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"EconVoyages ("+;
			"VOYAGE_UID			"+oSoftway:cIdentity+","+;
			"VESSEL_UNIQUEID	INT NOT NULL,"+;
			"VoyageNo			int NOT NULL,"+;
			"Description		"+oSoftway:FieldVarChar+" (128) NULL,"+;
			"CPDate				Datetime NULL,"+;
			"Charterers			"+oSoftway:FieldVarChar+" (128) NULL,"+;
			"Broker				"+oSoftway:FieldVarChar+" (128) NULL,"+;
			"PortFrom_UID		int NOT NULL Default 0,"+;
			"PortTo_UID			int NOT NULL Default 0,"+;
			"Distance			int NOT NULL Default 0,"+;
			"StartDate			Datetime NULL,"+;
			"EndDate			Datetime NULL,"+;
			"StartDateGMT		Datetime NULL,"+;
			"EndDateGMT			Datetime NULL,"+;
			"LaytimeStartDate	Datetime NULL,"+;
			"LaytimeEndDate		Datetime NULL,"+;
			"CostOfBunkersUSD	int NULL,"+;
			"TCEquivalentUSD	int NULL,"+;
			"CPMinSpeed			Decimal(6,2) NOT NULL Default 0.00,"+;
			"HFOConsumption		Decimal(6,2) NOT NULL Default 0.00,"+;
			"DGFOConsumption	Decimal(6,2) NOT NULL Default 0.00,"+;
			"USER_UNIQUEID		int NOT NULL Default 0,"+;
			"PRIMARY KEY (VOYAGE_UID)"+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)

			cStatement:="CREATE INDEX EconVoyagesVessel ON EconVoyages (VESSEL_UNIQUEID, VoyageNo)"
			IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
				RETURN FALSE
			ENDIF
		ENDIF

		IF ! oSoftway:TableExists(oGFH, oConn, "EconRoutings")
			// RoutingType: Ballast, Laden
			// Trim = DraftFWD - DraftAFT
			// CPMinSpeed - 5% (kn)
			// ME Consumption Tons Per Day: HFOConsumption + 5%
			// DG FO Consumption Tons Per Day: DGFOConsumption
			// WType: SHEX:=0, SHINC:=1, SSHEX:=2, FHEX:=3
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"EconRoutings ("+;
			"ROUTING_UID		"+oSoftway:cIdentity+","+;
			"VOYAGE_UID			"+oSoftway:FieldInteger+" NOT NULL,"+;
			"Condition			"+oSoftway:FieldChar+" (1) NOT NULL Default '0',"+;
			"PortFrom_UID		int NOT NULL Default 0,"+;
			"PortTo_UID			int NOT NULL Default 0,"+;
			"Distance			int NOT NULL Default 0,"+;
			"Deviation			int NOT NULL Default 0,"+;
			"Commenced			Datetime NULL,"+;
			"Completed			Datetime NULL,"+;
			"CommencedGMT		Datetime NULL,"+;
			"CompletedGMT		Datetime NULL,"+;
			"ArrivalGMT			Datetime NULL,"+;
			"DepartureGMT		Datetime NULL,"+;
			"WType				smallint NULL,"+;
			"WHours				"+oSoftway:FieldChar+"(11) NULL,"+;
			"RoutingType		"+oSoftway:FieldChar+"(1) NULL,"+;
			"CargoDescription	"+oSoftway:FieldVarChar+" (256) NULL,"+;
			"CargoTons			int NULL,"+;
			"Operation 			"+oSoftway:FieldVarChar+" (64) NULL,"+;
			"Agent  			"+oSoftway:FieldVarChar+" (128) NULL,"+;
			"DA  				"+oSoftway:FieldVarChar+" (32) NULL,"+;
			"DraftFWD_Dec		Decimal(6,2) NULL,"+;
			"DraftAFT_Dec		Decimal(6,2) NULL,"+;
			"RoutingROB_FO		float NULL,"+;
			"ArrivalROB_FO		float NULL,"+;
			"ManualROB_FO		float NULL,"+;
			"FOPriceUSD			Decimal(6,2) NULL,"+;
			"BunkeringGMT		Datetime NULL,"+;
			"TCEquivalentUSD	int NULL,"+;
			"USER_UNIQUEID		int NOT NULL Default 0,"+;
			"PRIMARY KEY (ROUTING_UID)"+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)

			//"IFO_Low_S				Decimal(8,2) NOT NULL Default 0,"+;
			//"IFO_High_S				Decimal(8,2) NOT NULL Default 0,"+;
			//"MDO_Diesel				Decimal(8,2) NOT NULL Default 0,"+;
			//"MDO_GasOil				Decimal(8,2) NOT NULL Default 0,"+;
			//"Water					Decimal(8,2) NOT NULL Default 0,"+;
			//"SystemOil_Unused		Decimal(8,2) NOT NULL Default 0,"+;
			//"SystemOil_Renovated	Decimal(8,2) NOT NULL Default 0,"+;
			//"SystemOil_S_T			Decimal(8,2) NOT NULL Default 0,"+;
			//"CylOil					Decimal(8,2) NOT NULL Default 0,"+;
			//"GenOil					Decimal(8,2) NOT NULL Default 0,"+;

			cStatement:="CREATE INDEX EconRoutingsRoute ON EconRoutings (VOYAGE_UID)"
			IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
				RETURN FALSE
			ENDIF
		ENDIF

		// Agent Links
		IF ! oSoftway:TableExists(oGFH, oConn, "FMCompaniesLinks")
			cStatement:="CREATE TABLE FMCompaniesLinks ("+;
				"Link_UID				"+oSoftway:cIdentity+","+;
				"Company_Uniqueid		"+oSoftway:FieldInteger+" NOT NULL,"+;
				"ExTableName			"+oSoftway:FieldVarChar+" (25) NULL,"+;
				"ExColumnName			"+oSoftway:FieldVarChar+" (25) NULL,"+;
				"External_UID			"+oSoftway:FieldInteger+" NOT NULL,"+;
				"Comments				"+oSoftway:FieldVarChar+" (512) NULL,"+;
				"PRIMARY KEY (Link_UID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
			
			cStatement:="CREATE INDEX FMCompaniesLinksUID ON FMCompaniesLinks (External_UID)"
			IF ! oSoftway:AdoCommand(oGFH, oConn, cStatement)
				RETURN FALSE
			ENDIF
		ENDIF


		// Report Generator
		IF ! oSoftway:TableExists(oGFH, oConn, "FMReportDefinition")
			// Report definitions
			cStatement:="CREATE TABLE FMReportDefinition ("+;
				"REPORT_UID	"+oSoftway:cIdentity+","+;
				"Description	"+oSoftway:FieldVarChar+"(128) NULL,"+;
				"PRIMARY KEY (REPORT_UID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF

		IF ! oSoftway:TableExists(oGFH, oConn, "FMReportFormulas")
			// Report Formulas
			cStatement:="CREATE TABLE FMReportFormulas ("+;
				"FORMULA_UID	"+oSoftway:cIdentity+","+;
				"REPORT_UID		int NOT NULL,"+;
				"LineNum		smallint NOT NULL,"+;
				"Description	"+oSoftway:FieldVarChar+"(128) NULL,"+;
				"ID				smallint NOT NULL Default 0,"+;
				"Formula		"+oSoftway:FieldVarChar+"(1000) NULL,"+;
				"HideLine		bit NOT NULL Default 0,"+;
				"Bold			bit NOT NULL Default 0,"+;
				"Underline		bit NOT NULL Default 0,"+;
				"ForeColor		int NOT NULL Default 0,"+;
				"BackColor		int NOT NULL Default 16777215,"+;
				"PRIMARY KEY (FORMULA_UID) "+;
			") "+oSoftway:cTableDefaults

			oSoftway:AdoCommand(oGFH, oConn, cStatement)

			cStatement:="CREATE INDEX REPORT_UID ON FMReportFormulas (REPORT_UID)"
			oSoftway:AdoCommand(oGFH, oConn, cStatement)

			cStatement:="CREATE INDEX LineNum ON FMReportFormulas (LineNum)"
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF

		IF ! oSoftway:TableExists(oGFH, oConn, "FMReportPresentation")
			// User calculations and Report presentation
			cStatement:="CREATE TABLE FMReportPresentation ("+;
				"FORMULA_UID	int NOT NULL,"+;
				"UserID			"+oSoftway:FieldVarChar+"(3) NOT NULL,"+;
				"Amount			Decimal(15, 2) NULL,"+;
				"TextField		"+oSoftway:FieldVarChar+"(1000) NULL,"+;
				"PRIMARY KEY (FORMULA_UID, UserID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
//				"Unit			"+oSoftway:FieldVarChar+"(30) NULL,"+;

			cStatement:="CREATE INDEX UserID ON FMReportPresentation (UserID)"
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF


		IF ! oSoftway:TableExists(oGFH, oConn, "FMCustomItems")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMCustomItems ("+;
						"ID					smallint NOT NULL,"+;
						"Description		"+oSoftway:FieldVarChar+"(128) NULL,"+;
						"FriedlyDescription	"+oSoftway:FieldVarChar+"(128) NULL,"+;
						"Unit				"+oSoftway:FieldVarChar+"(30) NULL,"+;
						"PRIMARY KEY (ID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)

			SELF:Fill_FMCustomItems(oGFH, oConn)
		ENDIF
		
		IF ! oSoftway:TableExists(oGFH, oConn, "FMVoyageLinks")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMVoyageLinks ("+;
						"Link_UID			"+oSoftway:cIdentity+","+;
						"Voyage_UID	int NOT NULL,"+;
						"Parent_Voyage_UID	int NOT NULL,"+;
						"Link_Type	smallint NOT NULL,"+;
						"PRIMARY KEY (Link_UID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF

		IF ! oSoftway:TableExists(oGFH, oConn, "FMUsers")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMUsers ("+;
						"USER_UNIQUEID					int NOT NULL,"+;
						"UserName						"+oSoftway:FieldVarChar+"(128) NULL,"+;
						"HeadUser						bit NOT NULL Default 0,"+;
						"CanEditVoyages					bit NOT NULL Default 0,"+;
						"CanEditReports					bit NOT NULL Default 0,"+;
						"CanEditReportData				bit NOT NULL Default 0,"+;
						"CanDeleteReportData			bit NOT NULL Default 0,"+;
						"CanEnterToolsArea				bit NOT NULL Default 0,"+;
						"CanCreateReports				bit NOT NULL Default 0,"+;
						"CanDeleteOfficeReports			bit NOT NULL Default 0,"+;
						"CanSeeAllOfficeReports			bit NOT NULL Default 0,"+;
						"CanEditFinalizedOfficeReports	bit NOT NULL Default 0,"+;
						"IsGeneralManager				bit NOT NULL Default 0,"+;
						"CanEditReportResults			bit NOT NULL Default 0,"+;
						"PRIMARY KEY (USER_UNIQUEID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF
		
		////////////////////////////////////////////////////////////////
		//ADDED BY KIRIAKOS AT 31/05/16
		////////////////////////////////////////////////////////////////
		IF ! oSoftway:TableExists(oGFH, oConn, "FMUserGroups")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMUserGroups ("+;
				"GROUP_UID					int NOT NULL,"+;
				"GroupName					"+oSoftway:FieldVarChar+"(128) NULL, "+;
				"PRIMARY KEY (GROUP_UID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF

		IF ! oSoftway:TableExists(oGFH, oConn, "FMUserGroupLinks")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMUserGroupLinks ("+;
				"USER_UID					int NULL, "+;
				"GROUP_UID					int NULL"+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF
		////////////////////////////////////////////////////////////////
		//ADDED BY KIRIAKOS AT 31/05/16
		////////////////////////////////////////////////////////////////

		IF ! oSoftway:TableExists(oGFH, oConn, "Cargoes")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"Cargoes ("+;
						"Cargo_Uniqueid	"+oSoftway:cIdentity+","+;
						"Cargo_Name	    "+oSoftway:FieldVarChar+"(256) NOT NULL,"+;
						"Cargo_Type	    "+oSoftway:FieldChar+" (1) NULL Default '0',"+;
						"Cargo_AltName	"+oSoftway:FieldVarChar+"(64) NULL,"+;
						"Cargo_Memo		"+oSoftway:FieldText+" NULL ,"+;
						"PRIMARY KEY (Cargo_Uniqueid) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF
		
		IF ! oSoftway:TableExists(oGFH, oConn, "CargoesTypes")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"CargoesTypes ("+;
						"Cargo_Type_Code	"+oSoftway:FieldChar+" (1) NOT NULL Default '0',"+;
						"Cargo_Type_Name	"+oSoftway:FieldVarChar+"(128) NOT NULL,"+;
						"Cargo_Type_Fleets	"+oSoftway:FieldVarChar+"(128) NULL Default '0',"+;
						"PRIMARY KEY (Cargo_Type_Code) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF
		
		IF ! oSoftway:TableExists(oGFH, oConn, "FMCargoRoutingLink")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMCargoRoutingLink ("+;
						"Link_Uniqueid	"+oSoftway:cIdentity+","+;
						"Cargo_Uniqueid	int NOT NULL,"+;
						"ROUTING_UID	int NOT NULL,"+;
						"Cargo_Quantity	Decimal(15, 2) NULL,"+;
						"Quantity_Unit  "+oSoftway:FieldVarChar+"(24) NULL,"+;
						"Cargo_Volume	Decimal(15, 2) NULL,"+;
						"Volume_Unit	"+oSoftway:FieldVarChar+"(24) NULL,"+;
						"Cargo_Action	"+oSoftway:FieldChar+" (1) NULL Default '0',"+;
						"Link_Notes		"+oSoftway:FieldVarChar+"(512) NULL,"+;
						"PRIMARY KEY (Link_Uniqueid) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF
		
		IF ! oSoftway:TableExists(oGFH, oConn, "ApprovalData")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"ApprovalData ("+;
						"Appoval_UID		"+oSoftway:cIdentity+","+;
						"Description		"+oSoftway:FieldVarChar+"(512) NULL,"+;
						"Program_UID		smallint NOT NULL Default 0,"+;
						"Foreing_UID		int NOT NULL,"+;
						"Creator_UID		int NOT NULL,"+;
						"From_State			int NOT NULL,"+;
						"Receiver_UID		int NOT NULL,"+;
						"To_State			int NOT NULL,"+;
						"Date_Received		datetime NOT NULL Default CURRENT_TIMESTAMP,"+;
						"Status				smallint NOT NULL Default 0,"+;
						"Date_Acted			datetime NULL,"+;
						"Comments			"+oSoftway:FieldText+" NULL ,"+;
						"PRIMARY KEY (Appoval_UID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
			//cStatement:="CREATE UNIQUE INDEX FMDataPackagesVessel ON FMDataPackages (Visible, VESSEL_UNIQUEID, REPORT_UID, DateTimeGMT)"
			//oSoftway:AdoCommand(oGFH, oConn, cStatement)

			cStatement:="CREATE INDEX ApprovalDataReport ON ApprovalData (Program_UID, Foreing_UID, Receiver_UID, Date_Received)"
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF

		IF ! oSoftway:TableExists(oGFH, oConn, "FMComboboxColors")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+" FMComboboxColors ("+;
						"CC_UID			"+oSoftway:cIdentity+","+;
						"FK_REPORT_UID	INT NOT NULL Default -1,"+;
						"TextValue		"+oSoftway:FieldVarChar+"(128) NULL Default '',"+;
						"ComboColor		int NOT NULL Default 0,"+;
						"PRIMARY KEY (CC_UID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF
		
		IF ! oSoftway:TableExists(oGFH, oConn, "FMReportChangeLog")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+"FMReportChangeLog ("+;
						"LOG_UID		"+oSoftway:cIdentity+","+;
						"REPORT_UID			int NOT NULL,"+;
						"LogDateTime		    datetime NOT NULL,"+;
						"Version			"+oSoftway:FieldVarChar+" (64) NULL,"+;
						"FK_User_UniqueId	int NOT NULL,"+;
						"LogNotes				"+oSoftway:FieldText+" NULL ,"+;
						"PRIMARY KEY (LOG_UID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		
		ENDIF
		
		IF ! oSoftway:TableExists(oGFH, oConn, "FMAlerts")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+" FMAlerts ("+;
						"AlertUid		  "+oSoftway:cIdentity+","+;
						"AlertDescription "+oSoftway:FieldNVarChar+" (512) NULL,"+;
						"AlertUpdatedDateTime Datetime NULL,"+;
						"AlertCreatorUID int NOT NULL,"+;
						"AlertReportUID int NOT NULL Default 0,"+;
						"AlertApplyAllConditions bit NOT NULL Default 1,"+;
						"PRIMARY KEY (AlertUid) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		
		ENDIF
		
		IF ! oSoftway:TableExists(oGFH, oConn, "FMAlertsVessels")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+" FMAlertsVessels ("+;
						"AlertVesselUid		  "+oSoftway:cIdentity+","+;
						"FK_VesselUid int NOT NULL,"+;
						"FK_AlertUid int NOT NULL,"+;
						"PRIMARY KEY (AlertVesselUid) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		
		ENDIF
		
		
		IF ! oSoftway:TableExists(oGFH, oConn, "FMAlertsConditions")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+" FMAlertsConditions ("+;
						"ConditionUid		  "+oSoftway:cIdentity+","+;
						"ConditionDescription "+oSoftway:FieldNVarChar+" (512) NULL,"+;
						"ConditionAlertUid int NOT NULL,"+;
						"ConditionItemUid int NOT NULL Default 0,"+; 
						"ConditionType		"+oSoftway:FieldNVarChar+" (32) NULL,"+;
						"ConditionOperator  "+oSoftway:FieldNVarChar+" (32) NULL,"+;
						"ConditionValue "+oSoftway:FieldNVarChar+" (512) NULL,"+;
						"PRIMARY KEY (ConditionUid) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		
		ENDIF
		
		IF ! oSoftway:TableExists(oGFH, oConn, "FMAlertsConditionsTypes")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+" FMAlertsConditionsTypes ("+;
						"ConditionTypeUid		  "+oSoftway:cIdentity+","+;
						"ConditionTypeDescription "+oSoftway:FieldNVarChar+" (512) NULL,"+;
						"ConditionTypeText "+oSoftway:FieldNVarChar+" (32) NULL,"+;
						"PRIMARY KEY (ConditionTypeUid) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		
		ENDIF

		IF ! oSoftway:TableExists(oGFH, oConn, "FMRelatedData")
			cStatement:="CREATE TABLE "+oSoftway:cTableOwner+" FMRelatedData ("+;
						"FMRD_UID		  "+oSoftway:cIdentity+","+;
						"Item1UID int NOT NULL,"+;
						"Item2UID int NOT NULL,"+;
						"PRIMARY KEY (FMRD_UID) "+;
			") "+oSoftway:cTableDefaults
			oSoftway:AdoCommand(oGFH, oConn, cStatement)
		ENDIF
		
	CATCH e AS Exception
		ErrorBox(e:Message)
		RETURN FALSE
	END TRY
RETURN TRUE


METHOD AddReportTypes(oGFH AS GenericFactoryHelper, oConn AS DBConnection) AS VOID
	LOCAL cStatement AS STRING

	cStatement:="INSERT INTO FMReportTypes (ReportName, ReportBaseNum) VALUES ('Departure Report', '100')"
	oSoftway:AdoCommand(oGFH, oConn, cStatement)

	cStatement:="INSERT INTO FMReportTypes (ReportName, ReportBaseNum) VALUES ('At Sea (Noon Report)', '200')"
	oSoftway:AdoCommand(oGFH, oConn, cStatement)

	cStatement:="INSERT INTO FMReportTypes (ReportName, ReportBaseNum) VALUES ('Arrival Report', '300')"
	oSoftway:AdoCommand(oGFH, oConn, cStatement)

	cStatement:="INSERT INTO FMReportTypes (ReportName, ReportBaseNum) VALUES ('In Port Report', '400')"
	oSoftway:AdoCommand(oGFH, oConn, cStatement)

	cStatement:="INSERT INTO FMReportTypes (ReportName, ReportBaseNum) VALUES ('Agent Report', '500')"
	oSoftway:AdoCommand(oGFH, oConn, cStatement)

	cStatement:="INSERT INTO FMReportTypes (ReportName, ReportBaseNum) VALUES ('Anchorage Report', '600')"
	oSoftway:AdoCommand(oGFH, oConn, cStatement)

	cStatement:="INSERT INTO FMReportTypes (ReportName, ReportBaseNum) VALUES ('Mode (Last Report)', '0')"
	oSoftway:AdoCommand(oGFH, oConn, cStatement)
RETURN


METHOD AddReportTypesVessel(oGFH AS GenericFactoryHelper, oConn AS DBConnection) AS VOID
	LOCAL cStatement AS STRING

	cStatement:="SELECT DISTINCT Vessels.VESSEL_UNIQUEID"+;
				" FROM Vessels"+oMainForm:cNoLockTerm+;
				" INNER JOIN SupVessels on Vessels.VESSEL_UNIQUEID=SupVessels.VESSEL_UNIQUEID"+;
				"	AND SupVessels.Active=1"
	LOCAL oDT := oSoftway:ResultTable(oGFH, oConn, cStatement) AS DataTable

	FOREACH oRow AS DataRow IN oDT:Rows
		cStatement:="INSERT INTO FMReportTypesVessel (REPORT_UID, VESSEL_UNIQUEID)"+;
					" SELECT FMReportTypes.REPORT_UID, "+oRow["VESSEL_UNIQUEID"]:ToString()+;
					" FROM FMReportTypes"	//+;
					//" WHERE NOT EXISTS"+;
					//" (SELECT REPORT_UID FROM FMReportTypesVessel"+;
					//"	WHERE REPORT_UID=FMReportTypes.REPORT_UID"+;
					//"	AND VESSEL_UNIQUEID="+oRow["VESSEL_UNIQUEID"]:ToString()+")"
		oSoftway:AdoCommand(oGFH, oConn, cStatement)
	NEXT
RETURN

END CLASS
