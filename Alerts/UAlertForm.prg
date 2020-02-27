USING System
USING System.Collections.Generic
USING System.ComponentModel
USING System.Data
USING System.Drawing
USING System.Text
USING System.Windows.Forms
USING DevExpress.XtraTreeList
USING DevExpress.XtraTreeList.Nodes
PUBLIC PARTIAL CLASS UAlertForm ;
    INHERIT System.Windows.Forms.Form
    PUBLIC CONSTRUCTOR() STRICT //UAlertForm
            InitializeComponent()
            RETURN
PRIVATE METHOD UAlertForm_Shown(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    SELF:Fill_DTReports()
//    SELF:Fill_DTReportsItems()
    SELF:Fill_DTConditionTypes()
    
    SELF:Fill_DGAlert()
    SELF:Fill_DTReportsItems()
    SELF:Fill_TreeListVessels()
    SELF:SetVesselCheckState()
    RETURN
PRIVATE METHOD barButtonItem3_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    SELF:Alert_Delete()
    RETURN
PRIVATE METHOD barButtonItem1_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    SELF:Alert_Insert()
    RETURN
PRIVATE METHOD GridViewAlerts_FocusedRowChanged(sender AS OBJECT, e AS DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventArgs) AS VOID STRICT
    SELF:SetVesselCheckState()
    SELF:Refresh_DTReportsItemsFiltered()
    SELF:Fill_DGConditions()
    RETURN
PRIVATE METHOD GridViewAlerts_CellValueChanged(sender AS OBJECT, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs) AS VOID STRICT
    IF e:Column:FieldName == "uReport"    
        IF oDTConditions:Rows:Count > 0            
            IF QuestionBox("Do you want to Delete existing conditions ?","Delete") <> System.Windows.Forms.DialogResult.Yes
                SELF:RefreshAlerts()
                RETURN
            ENDIF
        ENDIF
        
        SELF:Condition_DeleteAll(SELF:CurrentAlertId())
        SELF:Refresh_DTReportsItemsFiltered()
        SELF:Fill_DGConditions()
    ENDIF
    
    SELF:Alert_Update()
    RETURN
PRIVATE METHOD TreeListVessels_AfterCheckNode(sender AS OBJECT, e AS DevExpress.XtraTreeList.NodeEventArgs) AS VOID STRICT
    IF e:Node:Data:ToString():Contains("Fleet")
        //e:Node:CheckAll()
        FOREACH oNode AS TreeListNode IN e:Node:Nodes
            oNode:Checked := e:Node:Checked
            SELF:SetAlertsVessels(oNode:Data:ToString(), oNode:Checked)
        NEXT
        SELF:SetVesselCheckState()
        RETURN
    END IF
    SELF:SetAlertsVessels(e:Node:Data:ToString(), e:Node:Checked)    
    SELF:SetVesselCheckState()
    RETURN
PRIVATE METHOD barButtonItem4_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    SELF:Condition_Insert()
    RETURN
PRIVATE METHOD barButtonItem6_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    SELF:Condition_Delete()
    RETURN
PRIVATE METHOD GridViewConditions_CellValueChanged(sender AS OBJECT, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs) AS VOID STRICT
    SELF:Condition_Update()
    RETURN
PRIVATE METHOD GridViewConditions_CustomUnboundColumnData(sender AS OBJECT, e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs) AS VOID STRICT
    SELF:CustomUnboundColumnData_Conditions(e)
    RETURN
PRIVATE METHOD GridViewAlerts_CustomUnboundColumnData(sender AS OBJECT, e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs) AS VOID STRICT
    SELF:CustomUnboundColumnData_Alerts(e)
    RETURN
PRIVATE METHOD barButtonItem7_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    LOCAL oForm := CheckAlertsForm{} AS CheckAlertsForm
    oForm:ShowDialog()
    RETURN

END CLASS 
