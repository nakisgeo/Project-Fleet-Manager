// UAlertForm_Methods.prg
// Created by    : JJV-PC
// Creation Date : 2/20/2020 11:43:32 AM
// Created for   : 
// WorkStation   : DESKTOP-8HPCFRC


USING System
USING System.Collections
USING System.Collections.Generic
USING System.ComponentModel
USING System.Data
USING System.Data.Common
USING System.Drawing
USING DevExpress.XtraEditors
USING DevExpress.XtraTreeList
USING DevExpress.XtraTreeList.Nodes
USING DevExpress.XtraGrid.Views.Grid
USING DevExpress.XtraGrid.Columns
USING DevExpress.Utils
USING DevExpress.XtraEditors.Repository
USING DevExpress.XtraEditors.Controls 
USING System.Text
USING System.Windows.Forms
USING System.Linq

PUBLIC PARTIAL CLASS UAlertForm INHERIT System.Windows.Forms.Form
#region Properties
    PRIVATE oDTAlerts, oDTAlertVesselUid, oDTConditions, oDTReports, oDTReportsItems, oDTReportsItemsFiltered, oDTConditionTypes AS DataTable
#endregion


#region Alerts
PRIVATE METHOD CurrentAlertRow() AS DataRowView
	LOCAL oRow AS DataRowView
    LOCAL nRowHandle := SELF:GridViewAlerts:FocusedRowHandle AS INT
    oRow := (DataRowView)SELF:GridViewAlerts:GetRow(nRowHandle)
	RETURN oRow
PRIVATE METHOD CurrentAlertId() AS STRING
    VAR oRow := CurrentAlertRow()
	LOCAL alertUid := IIF(oRow == NULL_OBJECT, "", oRow:Item["AlertUid"]:ToString()) AS STRING
	RETURN alertUid

PRIVATE METHOD CreateDGAlertsColumns() AS VOID
    
    SELF:GridAlerts:DataSource := NULL
    SELF:GridViewAlerts:Columns:Clear()
    
    LOCAL oColumn AS GridColumn
    LOCAL nVisible:=0, nAbsIndex:=0 AS INT
    
    oColumn := oMainForm:CreateDXColumn("Description", "AlertDescription",  TRUE, DevExpress.Data.UnboundColumnType.String, ;
                                                                            nAbsIndex++, nVisible++, 200, SELF:GridViewAlerts)
	oColumn := oMainForm:CreateDXColumn("Report", "uReport",  TRUE, DevExpress.Data.UnboundColumnType.Integer, ;
                                                                            nAbsIndex++, nVisible++, 200, SELF:GridViewAlerts)
	LOCAL lookUpReport := RepositoryItemlookUpEdit{} AS RepositoryItemlookUpEdit  
	lookUpReport:DataSource := oDTReports
	lookUpReport:Columns:Add(LookUpColumnInfo{"ReportName", 400, "Report Name"})
	lookUpReport:Properties:AllowNullInput := DefaultBoolean.True
	lookUpReport:ValueMember := "REPORT_UID"
	lookUpReport:DisplayMember := "ReportName"	
	oColumn:ColumnEdit := lookUpReport
	
    oColumn := oMainForm:CreateDXColumn("Updated", "AlertUpdatedDateTime",  FALSE, DevExpress.Data.UnboundColumnType.DateTime, ;
                                                                            nAbsIndex++, nVisible++, 200, SELF:GridViewAlerts)
	oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    oColumn:AppearanceHeader:Options:UseTextOptions := TRUE
    oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    oColumn := oMainForm:CreateDXColumn("Apply All Conditions", "AlertApplyAllConditions",    TRUE, DevExpress.Data.UnboundColumnType.Boolean, ;
                                                                                                nAbsIndex++, nVisible++, 200, SELF:GridViewAlerts)
    oColumn:AppearanceCell:Options:UseTextOptions := TRUE
    oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    oColumn:AppearanceHeader:Options:UseTextOptions := TRUE
    oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
    RETURN
PRIVATE METHOD Fill_DGAlert() AS VOID
    CreateDGAlertsColumns()
    RefreshAlerts()
    RETURN
PRIVATE METHOD RefreshAlerts() AS VOID
	RefreshAlertVesselUid()
    LOCAL cStatement AS STRING
    cStatement := "SELECT FMAlerts.* "+;
                  " FROM FMAlerts "+;
                  " WHERE AlertCreatorUID = " + oUser:USER_UNIQUEID +;
                  " ORDER BY AlertDescription"
    
    SELF:oDTAlerts := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
    SELF:oDTAlerts:TableName := "Alerts"
    SELF:GridAlerts:DataSource := SELF:oDTAlerts
    RETURN
PRIVATE METHOD RefreshAlertVesselUid() AS VOID
    LOCAL cStatement AS STRING
    cStatement := "SELECT * "+;
                  " FROM [FMAlertsVessels] "
    
    SELF:oDTAlertVesselUid := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
    SELF:oDTAlertVesselUid:TableName := "AlertVesselUid"
    RETURN
    
PRIVATE METHOD Alert_Insert() AS VOID
	LOCAL cStatement, cUID AS STRING

    cStatement := "INSERT INTO FMAlerts (AlertDescription, AlertCreatorUID) VALUES"+;
                  " (' New Alert', "+oUser:USER_UNIQUEID+" )"
    IF !oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
        ErrorBox("Can not insert new record.")
        RETURN
    ENDIF

    cUID := oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "FMAlerts", "AlertUid")

    SELF:RefreshAlerts()

//    LOCAL nFocusedHandle AS INT
//    nFocusedHandle := SELF:gridviewlists:LocateByValue(0, SELF:gridviewlists:Columns["AlertUid"], Convert.ToInt32(cUID))
//    IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
//        RETURN
//    ENDIF
//    SELF:gridviewlists:ClearSelection()
//    SELF:gridviewlists:FocusedRowHandle:=nFocusedHandle
//    SELF:gridviewlists:SelectRow(nFocusedHandle)
	RETURN
	
PRIVATE METHOD Alert_Delete() AS VOID
    LOCAL oRow AS DataRowView
    LOCAL nRowHandle := SELF:GridViewAlerts:FocusedRowHandle AS INT
    oRow := (DataRowView)SELF:GridViewAlerts:GetRow(nRowHandle)
    IF oRow == NULL
        RETURN
    ENDIF
    
    IF QuestionBox("Do you want to Delete the current Alert:"+CRLF+CRLF+;
                    oRow:Item["AlertDescription"]:ToString()+" ?", ;
                    "Delete") <> System.Windows.Forms.DialogResult.Yes
        RETURN
    ENDIF
    
    LOCAL cStatement AS STRING
    
    cStatement := "DELETE FROM [FMAlertsConditions]"+;
                  " WHERE [ConditionAlertUid]="+oRow:Item["AlertUid"]:ToString()
    IF !oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
        ErrorBox("Cannot Delete current row", "Deletion aborted - FMAlertsConditions")
        RETURN
    ENDIF
    cStatement := "DELETE FROM [FMAlertsVessels]"+;
                  " WHERE [FK_AlertUid]="+oRow:Item["AlertUid"]:ToString()
    IF !oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
        ErrorBox("Cannot Delete current row", "Deletion aborted - FMAlertsVessels")
        RETURN
    ENDIF
    cStatement := "DELETE FROM [FMAlerts]"+;
                  " WHERE [AlertUid]="+oRow:Item["AlertUid"]:ToString()					
    IF !oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
        ErrorBox("Cannot Delete current row", "Deletion aborted - FMAlerts")
        RETURN
    ENDIF
    oDTAlerts:Rows:RemoveAt(nRowHandle)
    //RefreshAlerts()
    RETURN
PRIVATE METHOD Alert_Update() AS VOID
	LOCAL oRow AS DataRowView
    LOCAL nRowHandle := SELF:GridViewAlerts:FocusedRowHandle AS INT
    oRow := (DataRowView)SELF:GridViewAlerts:GetRow(nRowHandle)
    IF oRow == NULL
        RETURN
	ENDIF
	
	LOCAL cStatement AS STRING
	LOCAL dUpdate := DateTime.Now AS DateTime
	cStatement := "update FMAlerts set " +;
	              " AlertDescription=@AlertDescription, " +;
	              " AlertReportUID=@AlertReportUID, " +;
				  " AlertApplyAllConditions=@AlertApplyAllConditions, " +;
				  " AlertUpdatedDateTime=@AlertUpdatedDateTime " +;
				  " where AlertUid=@AlertUid "
	VAR dict := Dictionary<STRING, OBJECT>{}
		dict:Add("AlertDescription", oRow:Item["AlertDescription"]:ToString())
		dict:Add("AlertReportUID", Convert.ToInt32(oRow:Item["AlertReportUID"]))
		dict:Add("AlertApplyAllConditions", Convert.ToInt32(oRow:Item["AlertApplyAllConditions"]))
		dict:Add("AlertUpdatedDateTime", dUpdate)
		dict:Add("AlertUid", Convert.ToInt32(oRow:Item["AlertUid"]:ToString()))
		
	IF oSoftway:Exec(oMainForm:oGFH, oMainForm:oConn, cStatement, dict, FALSE) < 1
		errorbox("Update failed!", "")		
		RefreshAlerts()
		RETURN
	ENDIF	
	
	oRow:Item["AlertUpdatedDateTime"] := dUpdate
	
	RETURN
	
PRIVATE METHOD Fill_DTReports() AS VOID
	VAR cStatement := "SELECT * " +;
                        " FROM FMReportTypes a " +;
                        " WHERE a.ReportBaseNum>0"
						
	SELF:oDTReports := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	SELF:oDTReports:TableName := "Reports"
	RETURN
PRIVATE METHOD CustomUnboundColumnData_Alerts(e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs) AS VOID
	// Provides data for the UnboundColumns
	IF !e:IsGetData
		DO CASE
			CASE e:Column:FieldName == "uReport"
		        oDTAlerts:Rows[e:ListSourceRowIndex]["AlertReportUID"] := Convert.ToInt32(e:Value:ToString())
		ENDCASE
		
		RETURN
	ELSE
		DO CASE
            CASE e:Column:FieldName == "uReport"
	            e:value := oDTAlerts:Rows[e:ListSourceRowIndex]["AlertReportUID"]:ToString()
		ENDCASE
		
	ENDIF
	
#endregion

#region Conditions
PRIVATE METHOD CreateDGConditionsColumns() AS VOID
	SELF:GridConditions:DataSource := NULL
    SELF:GridViewConditions:Columns:Clear()
    
    LOCAL oColumn AS GridColumn
    LOCAL nVisible:=0, nAbsIndex:=0 AS INT
    
    oColumn := oMainForm:CreateDXColumn("Description", "ConditionDescription",  TRUE, DevExpress.Data.UnboundColumnType.String, ;
                                                                                nAbsIndex++, nVisible++, 100, SELF:GridViewConditions)
	oColumn := oMainForm:CreateDXColumn("Item", "uItem",    TRUE, DevExpress.Data.UnboundColumnType.String, ;
                                                            nAbsIndex++, nVisible++, 200, SELF:GridViewConditions)
																
	LOCAL lookUpItem := RepositoryItemlookUpEdit{} AS RepositoryItemlookUpEdit  
	lookUpItem:DataSource := oDTReportsItemsFiltered
	/*lookUpItem:Columns:Add(LookUpColumnInfo{"ReportName", 400, "Report Name"})*/
	lookUpItem:Columns:Add(LookUpColumnInfo{"ItemName", 400, "Item Name"})
	lookUpItem:Columns:Add(LookUpColumnInfo{"ItemCaption", 400, "Item Caption"})
	lookUpItem:Properties:AllowNullInput := DefaultBoolean.True
	lookUpItem:ValueMember := "ITEM_UID"
	lookUpItem:DisplayMember := "ItemName"	
	oColumn:ColumnEdit := lookUpItem
	
	oColumn := oMainForm:CreateDXColumn("Operator", "uOperator",    TRUE, DevExpress.Data.UnboundColumnType.String, ;
                                                                    nAbsIndex++, nVisible++, 200, SELF:GridViewConditions)
																
	LOCAL lookUpOpt := RepositoryItemlookUpEdit{} AS RepositoryItemlookUpEdit  
	lookUpOpt:DataSource := oDTConditionTypes
	lookUpOpt:Columns:Add(LookUpColumnInfo{"ConditionTypeDescription", 400, ""})
	lookUpOpt:Properties:AllowNullInput := DefaultBoolean.True
	lookUpOpt:ValueMember := "ConditionTypeUid"
	lookUpOpt:DisplayMember := "ConditionTypeDescription"
	
	oColumn:ColumnEdit := lookUpOpt
	
    oColumn := oMainForm:CreateDXColumn("Value", "ConditionValue",  TRUE, DevExpress.Data.UnboundColumnType.String, ;
                                                                    nAbsIndex++, nVisible++, 150, SELF:GridViewConditions)
	RETURN

PRIVATE METHOD CustomUnboundColumnData_Conditions(e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs) AS VOID
	// Provides data for the UnboundColumns
	IF !e:IsGetData
		DO CASE
			CASE e:Column:FieldName == "uItem"
		        oDTConditions:Rows[e:ListSourceRowIndex]["ConditionItemUid"] := Convert.ToInt32(e:Value:ToString())
			CASE e:Column:FieldName == "uOperator"
		        oDTConditions:Rows[e:ListSourceRowIndex]["ConditionType"] := Convert.ToInt32(e:Value:ToString())
				oDTConditions:Rows[e:ListSourceRowIndex]["ConditionOperator"] := oDTConditionTypes:AsEnumerable();
				    :First({i => i["ConditionTypeUid"]:ToString():Equals(e:Value:ToString())})["ConditionTypeText"]:ToString()
		ENDCASE
		
		RETURN
	ELSE
		DO CASE
            CASE e:Column:FieldName == "uItem"
	            e:value := oDTConditions:Rows[e:ListSourceRowIndex]["ConditionItemUid"]:ToString()
            CASE e:Column:FieldName == "uOperator"
	            VAR filtered := oDTConditionTypes:AsEnumerable():Where({i => i["ConditionTypeText"]:ToString():Equals(oDTConditions:Rows[e:ListSourceRowIndex]["ConditionOperator"]:ToString())})
	            IF filtered:Count() > 0
	                e:value := filtered:First()["ConditionTypeUid"]:ToString()
				ELSE
					e:value := ""
				ENDIF 
				
					
		ENDCASE
		
	ENDIF

	

//	DO CASE
//	CASE e:Column:FieldName == "uItemType"
//		oRow := SELF:oDTItems:Rows[e:ListSourceRowIndex]
//		// Remove the leading 'u' from FieldName
//		cField := oRow:Item[e:Column:FieldName:Substring(1)]:ToString()
//	ENDCASE
    RETURN

PRIVATE METHOD Fill_DTReportsItems() AS VOID
	VAR cStatement := "SELECT a.REPORT_UID, a.ReportName, b.ITEM_UID, b.ItemNo, b.ItemName, isnull(b.ItemCaption, '') ItemCaption " +;
                        " FROM FMReportTypes a " +;
                        " JOIN FMReportItems b ON a.REPORT_UID=b.REPORT_UID " +;
                        " WHERE a.ReportBaseNum>0 and b.ItemType NOT IN ('A','L')"
						
	SELF:oDTReportsItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	SELF:oDTReportsItems:TableName := "ReportsItems"
	RETURN
PRIVATE METHOD Refresh_DTReportsItemsFiltered() AS VOID
	IF oDTReportsItemsFiltered == NULL_OBJECT
		oDTReportsItemsFiltered := DataTable{"Reports"}
	ENDIF
	
	IF oDTReportsItems == NULL_OBJECT
		RETURN
	ENDIF
	
	IF string.IsNullOrEmpty(CurrentAlertRow()["AlertReportUID"]:ToString()) || CurrentAlertRow()["AlertReportUID"]:ToString():Equals("0")
		RETURN
	ENDIF
	
	oDTReportsItemsFiltered := oDTReportsItems:Select("REPORT_UID = " + CurrentAlertRow()["AlertReportUID"]:ToString()):CopyToDataTable()
	
	RETURN 

PRIVATE METHOD Fill_DTConditionTypes() AS VOID
	VAR cStatement := "SELECT * from FMAlertsConditionsTypes"
						
	SELF:oDTConditionTypes := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	SELF:oDTConditionTypes:TableName := "ConditionTypes"
	RETURN

PRIVATE METHOD RefreshConditions() AS VOID
	SELF:GridConditions:DataSource := NULL
	VAR alertUid := CurrentAlertId()	
	IF string.IsNullOrEmpty(alertUid)
		RETURN
	ENDIF	
    VAR cStatement := "SELECT a.* "+;
                        " FROM [FMAlertsConditions] a " +;
			            " where a.[ConditionAlertUid]=" + alertUid
    
    SELF:oDTConditions := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
    SELF:oDTConditions:TableName := "Conditions"
    SELF:GridConditions:DataSource := SELF:oDTConditions
	RETURN
PRIVATE METHOD Fill_DGConditions() AS VOID
	CreateDGConditionsColumns()
	RefreshConditions()
	RETURN
PRIVATE METHOD Condition_Insert() AS VOID
	
	IF string.IsNullOrEmpty(CurrentAlertRow()["AlertReportUID"]:ToString()) || CurrentAlertRow()["AlertReportUID"]:ToString():Equals("0")
		ErrorBox("You have to select report type before create condition!", "")
		RETURN
	ENDIF
	
	LOCAL cStatement, cUID AS STRING
	VAR alertUid := CurrentAlertId()

    cStatement := "INSERT INTO FMAlertsConditions (ConditionDescription, ConditionAlertUid, ConditionItemUid, ConditionType, ConditionOperator) VALUES"+;
                  " (' New Condition', " + alertUid + ", 0, 0, '')"
    IF !oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
        ErrorBox("Can not insert new record.")
        RETURN
    ENDIF

    cUID := oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "FMAlerts", "AlertUid")

    SELF:RefreshConditions()
	
	RETURN
PRIVATE METHOD Condition_Delete() AS VOID
	LOCAL oRow AS DataRowView
    LOCAL nRowHandle := SELF:GridViewConditions:FocusedRowHandle AS INT
    oRow := (DataRowView)SELF:GridViewConditions:GetRow(nRowHandle)
    IF oRow == NULL
        RETURN
    ENDIF
    
    IF QuestionBox("Do you want to Delete the current Condition:"+CRLF+CRLF+;
                    oRow:Item["ConditionDescription"]:ToString()+" ?", ;
                    "Delete") <> System.Windows.Forms.DialogResult.Yes
        RETURN
    ENDIF
    
    LOCAL cStatement AS STRING
    
    cStatement := "DELETE FROM [FMAlertsConditions]"+;
                  " WHERE [ConditionUid]="+oRow:Item["ConditionUid"]:ToString()
    IF !oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
        ErrorBox("Cannot Delete current row", "Deletion aborted")
        RETURN
    ENDIF
    RefreshConditions()
	RETURN
PRIVATE METHOD Condition_DeleteAll(alertUid AS STRING) AS VOID
	LOCAL cStatement AS STRING
    
    cStatement := "DELETE FROM [FMAlertsConditions]"+;
                  " WHERE [ConditionAlertUid]="+alertUid
    IF !oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
        ErrorBox("Cannot Delete current row", "Deletion aborted")
        RETURN
    ENDIF
    RefreshConditions()
	RETURN
	
PRIVATE METHOD Condition_Update() AS VOID
	LOCAL oRow AS DataRowView
    LOCAL nRowHandle := SELF:GridViewConditions:FocusedRowHandle AS INT
    oRow := (DataRowView)SELF:GridViewConditions:GetRow(nRowHandle)
    IF oRow == NULL
        RETURN
	ENDIF
	
	LOCAL cStatement AS STRING
	cStatement := "update FMAlertsConditions set " +;
	              " ConditionDescription=@ConditionDescription, " +;
				  " ConditionItemUid=@ConditionItemUid, " +;
				  " ConditionType=@ConditionType, " +;
				  " ConditionOperator=@ConditionOperator, " +;
				  " ConditionValue=@ConditionValue " +;
				  " where ConditionUid=@ConditionUid "
	VAR dict := Dictionary<STRING, OBJECT>{}
		dict:Add("ConditionDescription", oRow:Item["ConditionDescription"]:ToString())
		dict:Add("ConditionItemUid", Convert.ToInt32(oRow:Item["ConditionItemUid"]))
		dict:Add("ConditionType", Convert.ToInt32(oRow:Item["ConditionType"]))
		dict:Add("ConditionOperator", oRow:Item["ConditionOperator"]:ToString())
		dict:Add("ConditionValue", oRow:Item["ConditionValue"]:ToString())
		dict:Add("ConditionUid", Convert.ToInt32(oRow:Item["ConditionUid"]:ToString()))
		
	IF oSoftway:Exec(oMainForm:oGFH, oMainForm:oConn, cStatement, dict, FALSE) < 1
		errorbox("Update failed!", "")		
		RefreshAlerts()
		RETURN
	ENDIF	
	RETURN

#endregion

#region Vessels
PRIVATE METHOD CreateTLVesselsColumns() AS VOID
    SELF:TreeListVessels:OptionsBehavior:Editable := FALSE
    SELF:TreeListVessels:BeginUpdate()
    
    SELF:TreeListVessels:OptionsView:ShowCheckBoxes := TRUE
    
    SELF:TreeListVessels:Columns:Add()
    SELF:TreeListVessels:Columns[0]:Caption := "Vessel"
    SELF:TreeListVessels:Columns[0]:Name := "VesselName"
    SELF:TreeListVessels:Columns[0]:VisibleIndex := 0	
    
    SELF:TreeListVessels:EndUpdate()
    RETURN
    
PRIVATE METHOD Fill_TreeListVessels() AS VOID   
    CreateTLVesselsColumns()
    
    SELF:TreeListVessels:BeginUnboundLoad()
    SELF:TreeListVessels:Nodes:Clear()
    LOCAL cStatement AS STRING

    cStatement:="SELECT DISTINCT SupVessels.FLEET_UID, EconFleet.Description AS Fleet"+;
                " FROM Vessels"+oMainForm:cNoLockTerm+;
                " INNER JOIN SupVessels on Vessels.VESSEL_UNIQUEID=SupVessels.VESSEL_UNIQUEID"+;
                "    AND SupVessels.Active=1"+;
                " LEFT OUTER JOIN EconFleet ON EconFleet.FLEET_UID=SupVessels.FLEET_UID"+;
                " ORDER BY Fleet"
                
    LOCAL oDTFleet := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

    // Create a root node .
    LOCAL parentForRootNodes := NULL AS TreeListNode
    LOCAL FleetRootNode AS TreeListNode
    LOCAL oNode AS TreeListNode
    LOCAL n, nCount AS INT
    LOCAL cUID, cVessel, cFleetUID AS STRING
    LOCAL oDT AS DataTable

    FOREACH oRow AS DataRow IN oDTFleet:Rows
        cFleetUID := oRow["FLEET_UID"]:ToString()
        IF cFleetUID == "0"
            FleetRootNode := parentForRootNodes
        ELSE
            FleetRootNode := SELF:TreeListVessels:AppendNode(<OBJECT>{oRow["Fleet"]:ToString()}, parentForRootNodes)
            FleetRootNode:Tag := "Fleet|"+cFleetUID
        ENDIF

        cStatement:="SELECT DISTINCT Vessels.VESSEL_UNIQUEID, Vessels.VesselName, SupVessels.VslCode,"+;
                    " SupVessels.FLEET_UID, EconFleet.Description AS Fleet"+;
                    " FROM Vessels"+oMainForm:cNoLockTerm+;
                    " INNER JOIN SupVessels on Vessels.VESSEL_UNIQUEID=SupVessels.VESSEL_UNIQUEID"+;
                    "    AND SupVessels.Active=1"+;
                    " LEFT OUTER JOIN EconFleet ON EconFleet.FLEET_UID=SupVessels.FLEET_UID"+;
                    " WHERE SupVessels.FLEET_UID="+cFleetUID+;
                    " ORDER BY VesselName"
        oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
        
        nCount := oDT:Rows:Count - 1
        FOR n:=0 UPTO nCount
            cUID := oDT:Rows[n]:Item["VESSEL_UNIQUEID"]:ToString()
            cVessel := oDT:Rows[n]:Item["VesselName"]:ToString()
            oNode := SELF:TreeListVessels:AppendNode(<OBJECT>{cVessel}, FleetRootNode)
            oNode:Tag := cUID
            oNode:CheckState := CheckState.Unchecked
        NEXT
    NEXT

    SELF:TreeListVessels:EndUnboundLoad()

    SELF:TreeListVessels:ExpandAll()

RETURN

PRIVATE METHOD SetVesselCheckState() AS VOID
	VAR alertUid := CurrentAlertId()
	
	LOCAL uids := oDTAlertVesselUid:AsEnumerable():Where({i => i["FK_AlertUid"]:ToString():Equals(alertUid)});
	                                              :Select({i => i["FK_VesselUid"]:ToString()}):ToList() AS List<STRING>
	SELF:TreeListVessels:GetNodeList():ForEach({i => i:CheckState := CheckState.Unchecked})
	FOREACH oNode AS treelistnode IN SELF:TreeListVessels:GetNodeList()
		IF uids:Contains(oNode:Tag:ToString())
			oNode:CheckState := CheckState.Checked
		ENDIF
	NEXT
	
	FOREACH oNode AS treelistnode IN SELF:TreeListVessels:Nodes		
		IF oNode:HasChildren
			LOCAL en := oNode:Nodes:GetEnumerator() AS IEnumerator
			LOCAL child AS TreeListNode 
			oNode:Checked := TRUE
			WHILE en:MoveNext()
				child := (TreeListNode)en:Current
				IF !child:Checked
					oNode:Checked := FALSE
				ENDIF
			END
		ENDIF
	NEXT
	
	RETURN
PRIVATE METHOD SetAlertsVessels(vesselUid AS STRING, isChecked AS LOGIC) AS VOID
	LOCAL cStatement AS STRING
	LOCAL oRow := CurrentAlertRow() AS DataRowView
	LOCAL alertUid := CurrentAlertId() AS STRING
	
	LOCAL uids := oDTAlertVesselUid:AsEnumerable():Where({i => i["FK_VesselUid"]:ToString():Equals(vesselUid) && i["FK_AlertUid"]:ToString():Equals(alertUid)}):ToList() AS List<DataRow>
	IF uids:Count > 0 && !isChecked
		cStatement := "Delete [FMAlertsVessels] where [FK_VesselUid]=" + vesselUid + " and [FK_AlertUid]=" + alertUid
		IF !oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
            ErrorBox("Cannot change checkstate", "Deletion aborted")
            RETURN
		ENDIF
	ELSEIF uids:Count <= 0 && isChecked
		cStatement := "insert into [FMAlertsVessels]([FK_VesselUid], [FK_AlertUid]) values (" + vesselUid + "," + alertUid + ")"
		IF !oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
            ErrorBox("Cannot change checkstate", "Insert aborted")
            RETURN
		ENDIF
	ENDIF
	
	SELF:RefreshAlertVesselUid()
	RETURN
	

#endregion
END CLASS
