// Approval_Form_Methods.prg
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

PARTIAL EXPORT CLASS Approval_Form INHERIT System.Windows.Forms.Form
	
	PRIVATE oDTApprovals AS DataTable
	PRIVATE oDS := DataSet{} AS DataSet
	EXPORT  cMyUser := "-1" AS STRING 
	EXPORT  oGFH AS GenericFactoryHelper
	EXPORT  oConn AS DBConnection
	EXPORT  iAmProgram := -1 AS INT
	EXPORT  cMyReport := "" AS STRING
	PRIVATE oSoftway AS Softway

	METHOD CustomUnboundColumnData_Companies(e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs) AS VOID
	IF ! e:IsGetData
		RETURN
	ENDIF
	/*LOCAL oRow AS DataRow
	LOCAL cField AS STRING
	LOCAL oView AS GridView
	IF e:Column:FieldName == "uPortFromGMT_DIFF"
	ENDIF*/
	RETURN

	PUBLIC METHOD Approval_Form_OnLoad() AS VOID
		oSoftway := Softway{}
	RETURN


EXPORT METHOD getApprovalsForProgram(iProgramUID := 0 AS INT, lShowApprovalHistory := FALSE AS LOGIC) AS VOID
		iAmProgram := iProgramUID
		IF cMyUser == "-1"
			RETURN
		ENDIF
		LOCAL cExtraSQL := "", cCaseSQL,cCaseFromState,cCaseToState,cCaseStatus,cExtraMyReport AS STRING
		IF iProgramUID <> 0
			cExtraSQL := " AND [Program_UID]="+iProgramUID:ToString() 
		ENDIF
		
		cCaseSQL := "CASE Program_UID "+;
					"WHEN '1' THEN 'Communicator'"+;
					"WHEN '2' THEN 'Fleet Manager'"+;
					"ELSE 'Unknown Program'"+;
					"END as Program "
		
		cCaseFromState := ""			
		/*cCaseFromState := "CASE From_State "+;
					"WHEN '0' THEN 'Pending'"+;
					"WHEN '1' THEN 'Submitted to Dep Manager'"+;
					"WHEN '2' THEN 'Dep Manager Approved'"+;
					"WHEN '3' THEN 'GM Acknowledged'"+;
					"ELSE 'Unknown State'"+;
					"END as [From State], "*/
		
		cCaseToState := ""			
		/*cCaseToState := "CASE To_State "+;
					"WHEN '0' THEN 'Pending'"+;
					"WHEN '1' THEN 'Submitted to Dep Manager'"+;
					"WHEN '2' THEN 'Dep Manager Approved'"+;
					"WHEN '3' THEN 'GM Acknowledged'"+;
					"ELSE 'Unknown State'"+;
					"END as [To State], "*/
					
		LOCAL cCasePackageStatus := "CASE FMDataPackages.Status "+;
					"WHEN '0' THEN 'Pending'"+;
					"WHEN '1' THEN 'Submitted to Dep Manager'"+;
					"WHEN '2' THEN 'Dep Manager Approved'"+;
					"WHEN '3' THEN 'GM Acknowledged'"+;
					"ELSE 'Unknown Status'"+;
					"END as [Current Report Status] "	AS STRING
		
		cCaseStatus := "CASE ApprovalData.Status "+;
					"WHEN '0' THEN 'Not Seen'"+;
					"WHEN '1' THEN 'Seen'"+;
					"WHEN '-1' THEN 'Returned'"+;
					"WHEN '2' THEN 'Approved'"+;
					"ELSE 'Unknown Status'"+;
					"END as [Approval Status] "
		
		IF cMyReport <> ""
			cExtraMyReport := "AND Foreing_UID="+cMyReport+" "
		ENDIF
		
		LOCAL cStatement:="SELECT RTRIM([ApprovalData].Description) As Description, [Appoval_UID], "+cCaseSQL+", [Foreing_UID],LTRIM(RTRIM(Users1.Username)) as [CreatorUsername],"+cCaseFromState+"LTRIM(RTRIM(Users2.Username)) as [ReceiverUsername],"+cCaseToState+" [Date_Received] as [Date Received],"+cCaseStatus+", [Date_Acted] as [Date Acted], [Comments], "+cCasePackageStatus+;
				" FROM [ApprovalData], Users AS Users1, Users AS Users2, FMDataPackages"+;
				" WHERE ApprovalData.Foreing_UID=FMDataPackages.Package_UID AND (Receiver_UID="+cMyUser+" OR Creator_UID="+cMyUser+") AND Users1.User_Uniqueid=[Creator_UID] AND Users2.User_Uniqueid=[Receiver_UID] "+ cExtraSQL+cExtraMyReport+;
				" ORDER BY [Date Received] DESC " AS STRING
		SELF:oDTApprovals:=oSoftway:ResultTable(SELF:oGFH, SELF:oConn, cStatement)
		SELF:oDTApprovals:TableName:="Approvals"
		oSoftway:CreatePK(SELF:oDTApprovals, "Appoval_UID")
		SELF:oDS:Clear()
		SELF:oDS := NULL
		SELF:oDS := DataSet{}
		SELF:oDS:Tables:Add(SELF:oDTApprovals)
		SELF:gridControl1:DataSource := SELF:oDS:Tables["Approvals"]
RETURN
	
EXPORT METHOD CreateGridApprovals_Columns() AS VOID
	IF cMyUser == "-1"
		RETURN
	ENDIF
	LOCAL cColumnName AS STRING
	//LOCAL oColumn AS GridColumn
	//LOCAL nVisible:=0/*, nAbsIndex:=0*/ AS INT
	SELF:gridView1:Columns:Clear()
	//SELF:gridView1:SetDataSource(SELF:oDTApprovals)
	LOCAL iColumnCount AS INT
	FOR iColumnCount:=0 UPTO SELF:oDTApprovals:Columns:Count-1 STEP 1
		cColumnName := SELF:oDTApprovals:Columns[iColumnCount]:ColumnName
		/*IF cColumnName == "Date_Received" .or. cColumnName == "Date_Acted"
			DateTime.Parse(oDT:Rows[0]:Item["DateTimeGMT"]:ToString()):ToString("dd/MM/yyyy HH:mm")
		ENDIF*/
		gridView1:columns:AddField(cColumnName)
		IF cColumnName == "Appoval_UID" || cColumnName == "Foreing_UID"
			gridView1:Columns[iColumnCount]:Visible := FALSE
		ELSE
			gridView1:Columns[iColumnCount]:Visible := TRUE
		ENDIF
		IF cColumnName == "Date Received" .OR. cColumnName == "Date Acted" 
			gridView1:Columns[iColumnCount]:DisplayFormat:FormatType := DevExpress.Utils.FormatType.DateTime
			gridView1:Columns[iColumnCount]:DisplayFormat:FormatString := "dd/MM/yyyy HH:mm"
		ENDIF
		IF cColumnName == "Description"
			gridView1:Columns[iColumnCount]:GroupIndex := 1
			gridView1:Columns[iColumnCount]:SortMode := DevExpress.XtraGrid.ColumnSortMode.Custom
		ENDIF
		
		gridView1:Columns[iColumnCount]:OptionsColumn:AllowEdit := FALSE
	NEXT
										
RETURN

EXPORT METHOD gridViewRefresh() AS VOID
		//SELF:gridView1:DataSource := SELF:oDTApprovals
		SELF:gridControl1:Refresh()	
RETURN

EXPORT METHOD DoubleClickOnView( sender AS System.Object, e AS System.EventArgs ) AS VOID
		LOCAL oPoint := SELF:gridView1:GridControl:PointToClient(Control.MousePosition) AS Point
		LOCAL info := SELF:gridView1:CalcHitInfo(oPoint) AS DevExpress.XtraGrid.Views.Grid.ViewInfo.GridHitInfo
		
		IF info:InRow .OR. info:InRowCell
			LOCAL oRow AS DataRowView
			oRow:=(DataRowView)SELF:gridView1:GetRow(info:RowHandle)
			IF info:Column <> NULL .AND. oRow <> NULL
				IF iAmProgram == 2
					oSoftway:ClientNamedPipe_FleetManager(oRow:Item["Foreing_UID"]:ToString(), "ApprovalsForm", "LocateReport", "100")
				ENDIF
			ENDIF
		ENDIF
RETURN

METHOD myRowStyle( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Grid.RowCellStyleEventArgs ) AS VOID
        IF e:RowHandle >= 0
			LOCAL view := (GridView)sender AS GridView
            
            IF ((STRING)view:GetRowCellValue(e:RowHandle, view:Columns["Approval Status"])):Equals("Not Seen")
                e:Appearance:BackColor := Color.LightCoral
			ELSEIF ((STRING)view:GetRowCellValue(e:RowHandle, view:Columns["Approval Status"])):Equals("Seen")
				e:Appearance:BackColor := Color.LightGreen
			ELSEIF ((STRING)view:GetRowCellValue(e:RowHandle, view:Columns["Approval Status"])):Equals("Approved")
				e:Appearance:BackColor := Color.LimeGreen
			ELSEIF ((STRING)view:GetRowCellValue(e:RowHandle, view:Columns["Approval Status"])):Equals("Returned")
				e:Appearance:BackColor := Color.LightSteelBlue
            ENDIF
        ENDIF
  
RETURN

PRIVATE METHOD customColumnSort( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CustomColumnSortEventArgs ) AS System.Void
			 TRY
                IF e:Column:FieldName == "Description"
                    LOCAL oRow1, oRow2 AS DataRowView
					oRow1 := (DataRowView)e:RowObject1
					oRow2 := (DataRowView)e:RowObject2
                    e:Handled := TRUE
                    e:Result := -1*System.Collections.Comparer.Default:Compare(oRow1["Date Received"], oRow2["Date Received"])
                    //e.Result = System.Collections.Comparer.Default.Compare(dr1["Ticker"], dr2["Ticker"]);
                ENDIF
            
            CATCH exc AS Exception 
            
			 END TRY
RETURN


END CLASS