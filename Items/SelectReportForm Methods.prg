// SelectReportForm_Methods.prg
#Using System.Data
#Using DevExpress.XtraEditors.Controls 

PARTIAL CLASS SelectReportForm INHERIT System.Windows.Forms.Form
	EXPORT cCallerReportName AS STRING
	EXPORT oDTReports, oDTReportsOffice AS DataTable
	EXPORT cReportUID AS STRING
	EXPORT oMyLBControl AS DevExpress.XtraEditors.ListBoxControl 
	
METHOD SelectReportForm_OnLoad() AS VOID
	SELF:Fill_Odts_For_LBCReports()

	IF ! SELF:Fill_LBCReports()
		SELF:Close()
		RETURN
	ENDIF
	
	IF ! SELF:Fill_LBCReportsOffice()
		SELF:Close()
		RETURN
	ENDIF
RETURN


METHOD Fill_Odts_For_LBCReports() as Void
		LOCAL cStatement AS STRING
		cStatement:="SELECT FMReportTypes.*"+;
					" FROM FMReportTypes"+oMainForm:cNoLockTerm+;
					" WHERE ReportType='V' "+;
					" ORDER BY ReportBaseNum"
		SELF:oDTReports := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		oSoftway:CreatePK(SELF:oDTReports, "REPORT_UID")
		

		cStatement:="SELECT FMReportTypes.*"+;
					" FROM FMReportTypes"+oMainForm:cNoLockTerm+;
					" WHERE ReportType='O' "+;
					" ORDER BY ReportBaseNum"
		SELF:oDTReportsOffice := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		oSoftway:CreatePK(SELF:oDTReportsOffice, "REPORT_UID")
RETURN

METHOD Fill_LBCReports() AS LOGIC
	/*IF oMainForm:LBCReports:ItemCount == 1 .and. oMainForm:ReportsTabUserControl:SelectedIndex == 0
		wb("No Reports defined")
		RETURN FALSE
	ENDIF*/

	//SELF:LBCReports:Items:Clear()

	SELF:LBCReports:DataSource := self:oDTReports
	SELF:LBCReports:DisplayMember := "ReportName"
	SELF:LBCReports:ValueMember := "REPORT_UID"

	IF SELF:cCallerReportName <> NULL
		// This Form is opened by ReportsForm ReportItems Button
		LOCAL nIndex := SELF:LBCReports:FindStringExact(SELF:cCallerReportName, 0) AS INT
		IF nIndex <> -1
			SELF:LBCReports:SelectedIndex := nIndex
		ENDIF
	ELSE
		TRY
		LOCAL cReportName := oMainForm:LBCReports:GetDisplayItemValue(oMainForm:LBCReports:SelectedIndex):ToString() AS STRING
		IF ! cReportName:ToUpper():StartsWith("MODE")
			// Select the last selected Report
			LOCAL nIndex := SELF:LBCReports:FindStringExact(cReportName, 0) AS INT
			IF nIndex <> -1
				SELF:LBCReports:SelectedIndex := nIndex
			ENDIF
		ENDIF
		CATCH exExc AS Exception 
			RETURN true
		END
	ENDIF
RETURN TRUE


METHOD Fill_LBCReportsOffice() AS LOGIC
	SELF:LBCOfficeReports:Items:Clear()
	SELF:LBCOfficeReports:DataSource := self:oDTReportsOffice
	SELF:LBCOfficeReports:DisplayMember := "ReportName"
	SELF:LBCOfficeReports:ValueMember := "REPORT_UID"
RETURN TRUE

END CLASS