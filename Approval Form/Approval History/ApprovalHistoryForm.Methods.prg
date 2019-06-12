// ApprovalHistoryForm.prg
#Using System.IO
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing

#Using DevExpress.XtraEditors
#using DevExpress.LookAndFeel
#Using DevExpress.XtraGrid.Views.Grid
#Using DevExpress.XtraGrid.Views.Base
#using DevExpress.XtraPrinting
#Using DevExpress.XtraPrintingLinks
#using DevExpress.XtraGrid.Columns

PARTIAL CLASS ApprovalHistoryForm INHERIT System.Windows.Forms.Form

	PRIVATE oDTApprovals AS DataTable
	PRIVATE oDS := DataSet{} AS DataSet
	EXPORT  cMyUser := "-1" AS STRING 
	EXPORT  iAmProgram := -1 AS INT
	EXPORT  cMyReport := "" AS STRING
	PRIVATE oSoftway AS Softway
	

EXPORT METHOD getHistory() AS VOID
	
		LOCAL oDTDataPackage := Datatable{} AS DataTable
		IF cMyUser == "-1"
			RETURN
		ENDIF
		LOCAL cExtraSQL := "", cCaseSQL,cCaseFromState,cCaseToState,cCaseStatus,cExtraMyReport AS STRING
		cExtraSQL := " AND [Program_UID]=2"
		
		cCaseSQL := "CASE Program_UID "+;
					"WHEN '1' THEN 'Communicator'"+;
					"WHEN '2' THEN 'Fleet Manager'"+;
					"ELSE 'Unknown Program'"+;
					"END as Program "
		
		cCaseFromState := " [From_State],[To_State],"			
		
		cCaseToState := ""			
					
		LOCAL cCasePackageStatus := "CASE FMDataPackages.Status "+;
					"WHEN '0' THEN 'Pending'"+;
					"WHEN '1' THEN 'Submitted to Dep Manager'"+;
					"WHEN '2' THEN 'Dep Manager Approved'"+;
					"WHEN '3' THEN 'GM Acknowledged'"+;
					"ELSE 'Unknown Status'"+;
					"END as CurrentReportStatus "	AS STRING
		
		cCaseStatus := "CASE ApprovalData.Status "+;
					"WHEN '0' THEN 'Not Seen'"+;
					"WHEN '1' THEN 'Seen'"+;
					"WHEN '-1' THEN 'Returned'"+;
					"WHEN '2' THEN 'Approved'"+;
					"ELSE 'Unknown Status'"+;
					"END as ApprovalStatus "
		
		IF cMyReport <> ""
			cExtraMyReport := "AND Foreing_UID="+cMyReport+" "
		ENDIF
		
		LOCAL cStatement:="SELECT RTRIM([ApprovalData].Description) As Description, [Appoval_UID], "+cCaseSQL;
				+", [Foreing_UID],LTRIM(RTRIM(Users1.Username)) as CreatorUsername,"+cCaseFromState;
				+"LTRIM(RTRIM(Users2.Username)) as ReceiverUsername,";
				+cCaseToState+" [Date_Received] as DateReceived,"+cCaseStatus+", [Date_Acted] as DateActed, [Comments],";
				+cCasePackageStatus+;
				" FROM [ApprovalData], Users AS Users1, Users AS Users2, FMDataPackages"+;
				" WHERE ApprovalData.Foreing_UID=FMDataPackages.Package_UID AND Users1.User_Uniqueid=[Creator_UID] "+;
				" AND Users2.User_Uniqueid=[Receiver_UID] "+;
				cExtraSQL+cExtraMyReport+;
				" ORDER BY DateReceived DESC " AS STRING
		SELF:oDTApprovals:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:oDTApprovals:TableName:="Approvals"

		cStatement := "Select PACKAGE_UID, DateTimeGMT, Username From FMDataPackages Where PACKAGE_UID="+cMyReport
		oDTDataPackage := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)

		LOCAL oDTGrid := DataTable{} AS DataTable
		oDTGrid:Columns:Add("Description")	
		oDTGrid:Columns:Add("User")			
		oDTGrid:Columns:Add("Date")		

		LOCAL oRow := oDTGrid:NewRow(), oRowTemp AS DataRow
		oRow:Item["Description"] := "Inspection by "
		oRow:Item["Date"] := DateTime.Parse(oDTDataPackage:Rows[0]:Item["DateTimeGMT"]:ToString()):ToString("dd-MM-yyyy")
		oRow:Item["User"] := oDTDataPackage:Rows[0]:Item["Username"]:ToString()
		oDTGrid:Rows:Add(oRow)

		LOCAL oRows := oDTApprovals:Select("From_State=0") AS DataRow[]
		IF oRows <> NULL && oRows:Length <> 0
			oRowTemp := oRows[1]
			oRow := oDTGrid:NewRow()
			LOCAL cResultOfApproval := oRowTemp:Item["ApprovalStatus"]:ToString():Trim() AS STRING
			LOCAL cEndStatus := oRowTemp:Item["To_State"]:ToString():Trim() AS STRING
			IF cEndStatus=="2"
				oRow:Item["Description"] := "Submitted to General Manager by"
			ELSE
				oRow:Item["Description"] := "Submitted to Dept Manager by"
			ENDIF
			oRow:Item["Date"] := DateTime.Parse(oRowTemp:Item["DateReceived"]:ToString()):ToString("dd-MM-yyyy")
			oRow:Item["User"] := oRowTemp:Item["CreatorUsername"]:ToString()
			oDTGrid:Rows:Add(oRow)
			oRow := oDTGrid:NewRow()
			LOCAL cDate := oRowTemp:Item["DateActed"]:ToString() AS STRING
			IF cDate <> NULL && cDate<>""
				IF cEndStatus=="2"
					oRow:Item["Description"] := "General Manager Approved by"
				ELSE
					IF cResultOfApproval == "Returned"
						oRow:Item["Description"] := "Dept Manager Declined the form"
					ELSE
						oRow:Item["Description"] := "Dept Manager Approved by"
					ENDIF
				ENDIF
				oRow:Item["Date"] := DateTime.Parse(cDate):ToString("dd-MM-yyyy")
				oRow:Item["User"] := oRowTemp:Item["ReceiverUsername"]:ToString()
				oDTGrid:Rows:Add(oRow)	
				oRows := oDTApprovals:Select("From_State=1")
				IF oRows <> NULL && oRows:Length <> 0
					oRowTemp := oRows[1]
					oRow := oDTGrid:NewRow()
					oRow:Item["Description"] := "Submitted to General Manager by"
					oRow:Item["Date"] := DateTime.Parse(oRowTemp:Item["DateReceived"]:ToString()):ToString("dd-MM-yyyy")
					oRow:Item["User"] := oRowTemp:Item["CreatorUsername"]:ToString()
					oDTGrid:Rows:Add(oRow)
					oRow := oDTGrid:NewRow()
					cDate := oRowTemp:Item["DateActed"]:ToString()
					IF cDate <> NULL && cDate<>""
						oRow:Item["Description"] := "General Manager Approved by"
						oRow:Item["Date"] := DateTime.Parse(cDate):ToString("dd-MM-yyyy")
						oRow:Item["User"] := oRowTemp:Item["ReceiverUsername"]:ToString()
						oDTGrid:Rows:Add(oRow)
					ENDIF
				ENDIF
			ENDIF
		ENDIF
		SELF:gcFormHistory:DataSource := oDTGrid
		SELF:gcFormHistory:ForceInitialize()
RETURN

END CLASS