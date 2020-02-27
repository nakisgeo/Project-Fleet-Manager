USING System
USING System.Collections.Generic
USING System.ComponentModel
USING System.Data
USING System.Drawing
USING DevExpress.XtraTreeList
USING DevExpress.XtraTreeList.Nodes
USING System.Text
USING System.Windows.Forms
BEGIN NAMESPACE FleetManager.Alerts
    PUBLIC PARTIAL CLASS UserAlertsForm ;
        INHERIT System.Windows.Forms.Form
        PUBLIC oDTAlerts AS System.Data.DataTable
        PUBLIC oDTConditions AS System.Data.DataTable
        PUBLIC CONSTRUCTOR()  STRICT
            SELF:InitializeComponent()
        RETURN
PRIVATE METHOD BBINew_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
            LOCAL cStatement, cUID AS STRING

            cStatement:="INSERT INTO FMAlerts (AlertDescription, AlertCreatorUID) VALUES"+;
                        " (' New Alert', "+oUser:USER_UNIQUEID+" )"
            IF !oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
                ErrorBox("Can not insert new record.")
                RETURN
            ENDIF

            cUID:=oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "FMAlerts", "AlertUid")

            SELF:AlertsRefresh()

            LOCAL nFocusedHandle AS INT
            nFocusedHandle:=SELF:gridviewlists:LocateByValue(0, SELF:gridviewlists:Columns["AlertUid"], Convert.ToInt32(cUID))
            IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
                RETURN
            ENDIF
            SELF:gridviewlists:ClearSelection()
            SELF:gridviewlists:FocusedRowHandle:=nFocusedHandle
            SELF:gridviewlists:SelectRow(nFocusedHandle)
            
    RETURN
PRIVATE METHOD BBIEdit_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    RETURN
PRIVATE METHOD UserAlertsForm_Load(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    RETURN
PRIVATE METHOD UserAlertsForm_Shown(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
            SELF:Fill_TreeListVessels()
            SELF:TreeListVessels:Visible := TRUE
    RETURN
PRIVATE METHOD AlertsRefresh() AS VOID
        LOCAL cStatement AS STRING
            cStatement:="SELECT FMAlerts.* "+;
                            " FROM FMAlerts "+;
                            " WHERE AlertCreatorUID = "+oUser:USER_UNIQUEID +;
                            " ORDER BY AlertDescription"
    
            SELF:oDTAlerts:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
            SELF:oDTAlerts:TableName:="Alerts"
            SELF:GridLists:DataSource:=SELF:oDTAlerts
    RETURN 
PRIVATE METHOD gridviewlists_FocusedRowChanged(sender AS OBJECT, e AS DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventArgs) AS VOID STRICT

    RETURN
METHOD Fill_TreeListVessels() AS VOID   
   
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
    //memowrit(cTempDocDir+"\Fleet.txt", cStatement)

    // Create a root node .
    LOCAL parentForRootNodes := NULL AS TreeListNode
    LOCAL FleetRootNode AS TreeListNode
    //parentForRootNodes := SELF:TreeListVessels:AppendNode(<OBJECT>{"Vessels"}, parentForRootNodes)
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
        //memowrit(cTempDocDir+"\Vsl.txt", cStatement)
        //wb(cStatement)
        //oSoftway:CreatePK(oDT, "VESSEL_UNIQUEID")

        //LOCAL oCheckedListBoxItem AS DevExpress.XtraEditors.Controls.CheckedListBoxItem
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

END CLASS 
END NAMESPACE
