// CopyReportDialog_Methods.prg
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing

PARTIAL CLASS CopyReportDialog
	EXPORT oReportDefinitionForm AS ReportDefinitionForm

METHOD CopyReportDialog_OnLoad() AS VOID
	LOCAL cStatement AS STRING

	IF SELF:oReportDefinitionForm:LBCReports:SelectedItems:Count == 0
		wb("No Report definition selected")
		RETURN
	ENDIF

	// Get the Report definitions
	LOCAL oDTReports AS DataTable
	cStatement:="SELECT REPORT_UID, Description FROM FMReportDefinition"+;
				" WHERE Description <> '"+oSoftway:ConvertWildCards(SELF:oReportDefinitionForm:GetSelectedReportDefinition("Name"), FALSE)+"'"+;
				" ORDER BY Description"
	oDTReports:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	SELF:CBReports:DataSource:=oDTReports
	SELF:CBReports:DisplayMember:=oDTReports:Columns["Description"]:ToString()
	SELF:CBReports:ValueMember:=oDTReports:Columns["REPORT_UID"]:ToString()
RETURN


METHOD PasteReportFormulas() AS VOID
	LOCAL cStatement AS STRING

	// Check for Duplicates
	LOCAL cLines := "" AS STRING
	LOCAL cSourceUID := SELF:CBReports:SelectedValue:ToString() AS STRING
	LOCAL cTargetUID := SELF:oReportDefinitionForm:GetSelectedReportDefinition("cUID") AS STRING

	cStatement:="SELECT LineNum FROM FMReportFormulas"+;
				" WHERE REPORT_UID="+cTargetUID+;
				" AND LineNum IN"+;
				" (SELECT LineNum FROM FMReportFormulas AS FMReportFormulas_1"+;
				" WHERE REPORT_UID="+cSourceUID+")"
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	IF oDT:Rows:Count > 0
		FOREACH oRow AS DataRow IN oDT:Rows
			cLines += oRow["LineNum"]:ToString()+","
		NEXT
		cLines := cLines:Substring(0, cLines:Length - 1)

		IF QuestionBox("The Lines: "+cLines+CRLF+;
						"exist in both Reports"+CRLF+CRLF+;
						"Do you want to Paste the Formulas anyway ?", "Duplicated Lines found") <> System.Windows.Forms.DialogResult.Yes
			RETURN
		ENDIF
	ENDIF

	cStatement:="INSERT INTO FMReportFormulas (REPORT_UID, LineNum, Description, ID, Formula, HideLine, Bold, Underline, ForeColor, BackColor)"+;
				" SELECT "+cTargetUID+","+;
				" LineNum, Description, ID, Formula, HideLine, Bold, Underline, ForeColor, BackColor"+;
				" FROM FMReportFormulas AS FMReportFormulas_1"+;
				" WHERE REPORT_UID="+cSourceUID
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ErrorBox("Cannot Paste Formula records into the current Report definition")
		RETURN
	ENDIF

	SELF:oReportDefinitionForm:GridViewFormulas_Refresh()
	SELF:Close()
RETURN

END CLASS
