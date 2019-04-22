// SelectVoyageForm_Methods.prg
#USING System.Windows.Forms
#USING System.Drawing
#USING System.Data

PARTIAL CLASS SelectVoyageForm INHERIT DevExpress.XtraEditors.XtraForm
	EXPORT cVesselUID AS STRING

METHOD SelectVoyageForm_OnLoad() AS VOID
	SELF:Fill_LBCVoyages()
RETURN


METHOD Fill_LBCVoyages() AS VOID
	SELF:LBCVoyages:Items:Clear()

	LOCAL cStatement AS STRING
	cStatement:="SELECT * FROM EconVoyages"+oMainForm:cNoLockTerm+;
				" WHERE VESSEL_UNIQUEID="+cVesselUID+;
				" ORDER BY StartDate"
    //wb(cStatement)
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	IF oDT:Rows:Count == 0
		SELF:ButtonOK:Enabled := FALSE
		RETURN
	ENDIF

	LOCAL oLBCItem AS MyLBCVoyageItem
	LOCAL cDescription, cStartGMT, cEndGMT, cStart, cEnd AS STRING
	LOCAL dStart, dEnd as DateTime
	LOCAL dStartGMT, dEndGMT as DateTime
	FOREACH oRow AS DataRow IN oDT:Rows
		dStartGMT := DateTime.MinValue
		cStartGMT := oRow["StartDateGMT"]:ToString()
		dStart := DateTime.MinValue
		cStart := oRow["StartDate"]:ToString()

		dEndGMT := DateTime.MaxValue
		cEndGMT := oRow["EndDateGMT"]:ToString()
		dEnd := DateTime.MaxValue
		cEnd := oRow["EndDate"]:ToString()

		//cDescription := "VoyageNo: "+oRow["VoyageNo"]:ToString()+" - "+oRow["Description"]:ToString()
		cDescription := oRow["VoyageNo"]:ToString()+" - "+oRow["Description"]:ToString()
		IF cStartGMT <> ""
			dStartGMT := DateTime.Parse(cStartGMT)
			cDescription += " - StartDate: "+dStartGMT:ToString("dd/MM/yyyy HH:mm")+ " (GMT)"
		ENDIF
		IF cEndGMT <> ""
			dEndGMT := DateTime.Parse(cEndGMT)
			cDescription += " - EndDate: "+dEndGMT:ToString("dd/MM/yyyy HH:mm")+ " (GMT)"
		ENDIF

		IF cStart <> ""
			dStart := DateTime.Parse(cStart)
		ENDIF
		IF cEnd <> ""
			dEnd := DateTime.Parse(cEnd)
		ENDIF

		oLBCItem := MyLBCVoyageItem{oRow, cDescription, oRow["VOYAGE_UID"]:ToString(), dStartGMT, dEndGMT, dStart, dEnd}
		SELF:LBCVoyages:Items:Add(oLBCItem)
	NEXT
	// Select the last Voyage
	SELF:LBCVoyages:SelectedItem := oLBCItem
RETURN


//Antonis 27.11.14 Put Vessel Name in Title //

METHOD Fill_LBCRoutings() AS VOID 
	SELF:LBCRouting:Items:Clear()

	IF SELF:LBCVoyages:Items:Count == 0
		RETURN
	ENDIF

	LOCAL cStatement AS STRING
	cStatement:="SELECT EconRoutings.*, VEPortsFrom.Port AS PortFrom, VEPortsTO.Port AS PortTo, Vessels.VesselName FROM EconRoutings"+;
				" INNER JOIN EconVoyages ON EconVoyages.VOYAGE_UID=EconRoutings.VOYAGE_UID"+;
				" LEFT OUTER JOIN VEPorts AS VEPortsFrom ON EconRoutings.PortFrom_UID=VEPortsFrom.PORT_UID"+;
				" LEFT OUTER JOIN VEPorts AS VEPortsTo ON EconRoutings.PortTo_UID=VEPortsTo.PORT_UID"+;
				" LEFT OUTER JOIN Vessels AS Vessels ON EconVoyages.VESSEL_UNIQUEID=Vessels.VESSEL_UNIQUEID"+;
				" WHERE EconVoyages.VOYAGE_UID="+SELF:GetSelectedLBCItem(SELF:LBCVoyages, "cUID")+;
				" ORDER BY EconRoutings.CommencedGMT"
    
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	IF oDT:Rows:Count == 0
		SELF:ButtonOK:Enabled := false
		RETURN
	ELSE
		SELF:ButtonOK:Enabled := true
	ENDIF

	LOCAL oLBCItem AS MyLBCVoyageItem
	LOCAL cDescription, cStartGMT, cEndGMT, cStart, cEnd AS STRING
	LOCAL dStart, dEnd as DateTime
	LOCAL dStartGMT, dEndGMT as DateTime
	FOREACH oRow AS DataRow IN oDT:Rows
		dStartGMT := DateTime.MinValue
		cStartGMT := oRow["CommencedGMT"]:ToString()
		dStart := DateTime.MinValue
		cStart := oRow["Commenced"]:ToString()

		dEndGMT := DateTime.MaxValue
		cEndGMT := oRow["CompletedGMT"]:ToString()
		dEnd := DateTime.MaxValue
		cEnd := oRow["Completed"]:ToString()

		cDescription := "Vessel: "+oRow["VesselName"]:ToString()+". From: "+oRow["PortFrom"]:ToString()+" - To: "+oRow["PortTo"]:ToString()
		IF cStartGMT <> ""
			dStartGMT := DateTime.Parse(cStartGMT)
			cDescription += " - Commenced: "+dStartGMT:ToString("dd/MM/yyyy HH:mm")+ " (GMT)"
		ENDIF
		IF cEndGMT <> ""
			dEndGMT := DateTime.Parse(cEndGMT)
			cDescription += " - Completed: "+dEndGMT:ToString("dd/MM/yyyy HH:mm")+ " (GMT)"
		ENDIF

		IF cStart <> ""
			dStart := DateTime.Parse(cStart)
		ENDIF
		IF cEnd <> ""
			dEnd := DateTime.Parse(cEnd)
		ENDIF

		oLBCItem := MyLBCVoyageItem{oRow, cDescription, oRow["VOYAGE_UID"]:ToString(), dStartGMT, dEndGMT, dStart, dEnd}
		SELF:LBCRouting:Items:Add(oLBCItem)
	NEXT
	// Select the last Routing
	SELF:LBCRouting:SelectedItem := oLBCItem
RETURN


METHOD GetSelectedLBCItem(oLBCControl AS DevExpress.XtraEditors.ListBoxControl, cField AS STRING) AS STRING
	LOCAL cRet AS STRING

	IF oLBCControl:SelectedIndex == -1
		IF cField == "Name"
			cRet := ""
		ELSE
			cRet := "0"
		ENDIF
		RETURN cRet
	ENDIF

	LOCAL oLBCItem := (MyLBCVoyageItem)oLBCControl:SelectedItem AS MyLBCVoyageItem
	DO CASE
	CASE cField == "Name"
		cRet := oLBCItem:Name
	OTHERWISE
		cRet := oLBCItem:cUID
	ENDCASE
RETURN cRet

END CLASS


CLASS MyLBCVoyageItem INHERIT OBJECT
	EXPORT oRow AS DataRow
	EXPORT Name, cUID AS STRING
	EXPORT dStartGMT, dEndGMT AS DateTime
	EXPORT dStart, dEnd AS DateTime

	CONSTRUCTOR(_oRow AS DataRow, _Name AS STRING, _cUID AS STRING, _dStartGMT AS DateTime, _dEndGMT AS DateTime, _dStart AS DateTime, _dEnd AS DateTime)
		SELF:oRow := _oRow
		SELF:Name := _Name
		SELF:cUID := _cUID
		SELF:dStartGMT := _dStartGMT
		SELF:dEndGMT := _dEndGMT
		SELF:dStart := _dStart
		SELF:dEnd := _dEnd
	RETURN

	VIRTUAL METHOD ToString() AS STRING
	RETURN SELF:Name

	METHOD FromPort() AS STRING
		LOCAL cPort := "" AS STRING
		LOCAL nPos AS INT

		nPos := SELF:Name:IndexOf("- To:")
		IF nPos <> -1
			cPort := SELF:Name:Substring(0, nPos):Replace("From:", ""):Trim()
		ENDIF
	RETURN cPort

	METHOD ToPort() AS STRING
		LOCAL cPort := "" AS STRING
		LOCAL nPos1, nPos2 AS INT

		nPos1 := SELF:Name:IndexOf("- To:")
		IF nPos1 <> -1
			cPort := SELF:Name:Substring(nPos1 + 5):Trim()
			nPos2 := cPort:IndexOf("- Commenced:")
			IF nPos2 <> -1
				cPort := cPort:Substring(0, nPos2):Trim()
			ENDIF
		ENDIF
	RETURN cPort

END CLASS
