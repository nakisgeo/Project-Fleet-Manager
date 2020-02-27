USING System
USING System.Collections.Generic
USING System.ComponentModel
USING System.Data
USING System.Drawing
USING System.Text
USING System.Windows.Forms
PUBLIC PARTIAL CLASS PortsForm ;
    INHERIT DevExpress.XtraEditors.XtraForm
    PUBLIC CONSTRUCTOR() STRICT //PortsForm
        SUPER()
        InitializeComponent()
        RETURN
PRIVATE METHOD PortsForm_Load(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    SELF:PortsForm_OnLoad()
    RETURN
PRIVATE METHOD PortsForm_FormClosing(sender AS OBJECT, e AS System.Windows.Forms.FormClosingEventArgs) AS VOID STRICT
    oSoftway:SaveFormSettings_DevExpress(SELF, NULL, oMainForm:alForms, oMainForm:alData)
    RETURN
PRIVATE METHOD PortsForm_FormClosed(sender AS OBJECT, e AS System.Windows.Forms.FormClosedEventArgs) AS VOID STRICT
    RETURN
PRIVATE METHOD BBIAdd_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    SELF:Ports_Add()
    RETURN
PRIVATE METHOD BBIEdit_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    LOCAL oRow AS DataRowView

    oRow := (DataRowView)SELF:GridViewPorts:GetFocusedRow()
    SELF:Ports_Edit(oRow, SELF:GridViewPorts:FocusedColumn)
    RETURN
PRIVATE METHOD BBIDelete_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    SELF:Ports_Delete()
    RETURN
PRIVATE METHOD BBIRefresh_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    Ports_Refresh()
    RETURN
PRIVATE METHOD BBIPrint_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    SELF:Ports_Print()
    RETURN
PRIVATE METHOD BBIClose_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    SELF:Close()
    RETURN
PRIVATE METHOD GridViewPorts_BeforeLeaveRow(sender AS OBJECT, e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs) AS VOID STRICT
    SELF:BeforeLeaveRow_Ports(e)
    RETURN
PRIVATE METHOD GridViewPorts_CellValueChanging(sender AS OBJECT, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs) AS VOID STRICT
    RETURN
PRIVATE METHOD GridViewPorts_CellValueChanged(sender AS OBJECT, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs) AS VOID STRICT
    SELF:SetEditModeOff_Common(SELF:GridViewPorts)
    SELF:Ports_Save(e)
    RETURN
PRIVATE METHOD GridViewPorts_DoubleClick(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    LOCAL oPoint := SELF:GridViewPorts:GridControl:PointToClient(Control.MousePosition) AS Point
    LOCAL info := SELF:GridViewPorts:CalcHitInfo(oPoint) AS DevExpress.XtraGrid.Views.Grid.ViewInfo.GridHitInfo
    IF info:InRow .OR. info:InRowCell
        IF SELF:GridViewPorts:IsGroupRow(info:RowHandle)
            RETURN
        ENDIF

        // Get GridRow data into a DataRowView object
        LOCAL oRow AS DataRowView
        oRow:=(DataRowView)SELF:GridViewPorts:GetRow(info:RowHandle)

        IF info:Column <> NULL
            // Set focused Row/Column (for DoubleClick event)
            //SELF:GridViewVessels:FocusedRowHandle := info:RowHandle
            //SELF:GridViewVessels:FocusedColumn := info:Column

            SELF:Ports_Edit(oRow, info:Column)
        ENDIF
    ENDIF
    RETURN
PRIVATE METHOD GridViewPorts_FocusedColumnChanged(sender AS OBJECT, e AS DevExpress.XtraGrid.Views.Base.FocusedColumnChangedEventArgs) AS VOID STRICT
    SELF:SetEditModeOff_Common(SELF:GridViewPorts)
    RETURN
PRIVATE METHOD GridViewPorts_CustomUnboundColumnData(sender AS OBJECT, e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs) AS VOID STRICT
    SELF:CustomUnboundColumnData_Ports(e)
    RETURN

END CLASS 
