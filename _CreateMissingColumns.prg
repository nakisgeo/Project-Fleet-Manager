// _CreateMissingColumns.prg

PARTIAL CLASS MainForm INHERIT DevExpress.XtraEditors.XtraForm

METHOD AddMissingColumns() AS VOID

	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMReportItems", "CATEGORY_UID", "int", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMReportItems", "Mandatory", "bit", "NOT NULL", "Default 1")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMReportItems", "ShowOnlyOffice", "bit", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMReportItems", "NotNumbered", "bit", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMReportItems", "SLAA", "bit", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMReportItems", "IsDD", "bit", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMReportItems", "CalculatedField", oSoftway:FieldVarChar+" (1000)", "NULL", "")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMReportItems", "MinValue", "float", "NULL", "")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMReportItems", "MaxValue", "float", "NULL", "")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMReportItems", "ShowOnMap", "bit", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMReportItems", "ItemTypeValues", oSoftway:FieldVarChar+" (1000)", "NULL", "")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMReportItems", "ExpandOnColumns", "int", "NOT NULL", "Default 1")
	
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "EconVoyages", "Type", "int", "NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "EconVoyages", "LaytimeStartDate", "Datetime", "NULL", "")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "EconVoyages", "LaytimeEndDate", "Datetime", "NULL", "")
	
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMDataPackages", "Visible", "smallint", "NOT NULL", "Default 1")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMDataPackages", "Matched", "smallint", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMDataPackages", "Status",  "smallint", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMDataPackages", "Username", oSoftway:FieldVarChar+" (128)",  "NULL", "Default Null")
	
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "EconRoutings", "Agent",  oSoftway:FieldVarChar+" (128)", "NULL", "")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "EconRoutings", "DA",  oSoftway:FieldVarChar+" (32)", "NULL", "")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "EconRoutings", "Operation",  oSoftway:FieldVarChar+" (64)", "NULL", "")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "EconRoutings", "ArrivalGMT",   "Datetime", "NULL", "")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "EconRoutings", "DepartureGMT",   "Datetime", "NULL", "")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "EconRoutings", "BunkeredQty",   " Decimal(18,3)", "NOT NULL", "Default 0")
	//Samos
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMReportTypes", "ReportType",  oSoftway:FieldChar+" (1)", "NOT NULL", "Default 'V'")
	

	IF oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMItemCategories", "SortOrder", "smallint", "NULL", "")
		SELF:SetCategoriesSortOrder()
	ENDIF

	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMReportItems", "Unit", oSoftway:FieldVarChar+" (30)", "NOT NULL", "Default ' '")

	oSoftway:AddColumnIfNotExists(oGFH, oConn, "SupVessels", "FLEET_UID", "int", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "SupVessels", "PropellerPitch", "float", "NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "Vessels", "Alias", oSoftway:FieldVarChar+" (256)", "NULL", "")
	
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMUsers", "CanCreateReports", "bit", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMUsers", "CanDeleteOfficeReports", "bit", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMUsers", "CanSeeAllOfficeReports", "bit", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMUsers", "CanEditFinalizedOfficeReports", "bit", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMUsers", "isGeneralManager", "bit", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMUsers", "CanEditReportResults", "bit", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMUsers", "InformUserForGMApproval", "bit", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMUsers", "InformUserForGMApprovalEmail", oSoftway:FieldVarChar+" (256)", " NULL", "")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMUsers", "CanEditReportChangeLog", "bit", "NOT NULL", "Default 0")	
	
	//FMGlobalSettings	
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMGlobalSettings", "Departure_HFOROB_Item_UID", oSoftway:FieldVarChar+" (30)", "NOT NULL", "Default ''")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMGlobalSettings", "Arrival_HFOROB_Item_UID", oSoftway:FieldVarChar+" (30)", "NOT NULL", "Default ''")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMGlobalSettings", "Departure_LFOROB_Item_UID", oSoftway:FieldVarChar+" (30)", "NOT NULL", "Default ''")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMGlobalSettings", "Arrival_LFOROB_Item_UID", oSoftway:FieldVarChar+" (30)", "NOT NULL", "Default ''")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMGlobalSettings", "Departure_MGOROB_Item_UID", oSoftway:FieldVarChar+" (30)", "NOT NULL", "Default ''")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMGlobalSettings", "Arrival_MGOROB_Item_UID", oSoftway:FieldVarChar+" (30)", "NOT NULL", "Default ''")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMGlobalSettings", "ArrivalPort_Item_UID", "int", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMGlobalSettings", "DeparturePort_Item_UID", "int", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMGlobalSettings", "DepartureBunkeredHFO_Item_UID", oSoftway:FieldVarChar+" (30)", "NOT NULL", "Default ''")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMGlobalSettings", "DepartureBunkeredLFO_Item_UID", oSoftway:FieldVarChar+" (30)", "NOT NULL", "Default ''")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMGlobalSettings", "DepartureBunkeredMDO_Item_UID", oSoftway:FieldVarChar+" (30)", "NOT NULL", "Default ''")
	//FM Routings Additional Data	
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMRoutingAdditionalData", "BunkeredHFO", "float", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMRoutingAdditionalData", "BunkeredLFO", "float", "NOT NULL", "Default 0")
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMRoutingAdditionalData", "BunkeredMDO", "float", "NOT NULL", "Default 0")

	//Add EU info on Port
	oSoftway:AddColumnIfNotExists(oGFH, oConn, "VEPorts", "EUPort", "bit", "NOT NULL", "Default 0")

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//							ADDED BY KIRIAKOS
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	IF oSoftway:AddColumnIfNotExists(oGFH, oConn, "FMUsers", "IsHeadUser", "bit", "NOT NULL", "Default 0")
		//Transfer the values of the CrewUsers.HeadUser to FMUsers.IsHeadUser
		SELF:TransferHeadUserColumnData()	
	ENDIF

RETURN

END CLASS