USING System.Windows.Forms
USING System.Data
USING System.Drawing
USING DevExpress.XtraBars
USING DevExpress.XtraGrid.Views.Grid
USING DevExpress.XtraGrid.Views.Grid.ViewInfo
PUBLIC PARTIAL CLASS VesselsForm ;
    INHERIT DevExpress.XtraEditors.XtraForm
    PRIVATE barManager AS DevExpress.XtraBars.BarManager
    PRIVATE BarSetup AS DevExpress.XtraBars.Bar
    PRIVATE barDockControlTop AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlBottom AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlLeft AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlRight AS DevExpress.XtraBars.BarDockControl
    PRIVATE GridVessels AS DevExpress.XtraGrid.GridControl
    PRIVATE GridViewVessels AS DevExpress.XtraGrid.Views.Grid.GridView
    PRIVATE BBIAdd AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIEdit AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIDelete AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIRefresh AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIPrint AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIClose AS DevExpress.XtraBars.BarButtonItem
    PRIVATE components AS System.ComponentModel.IContainer
    CONSTRUCTOR()
      SUPER()
      SELF:InitializeComponent()
      RETURN
    
   /// <summary>
   /// Clean up any resources being used.
   /// </summary>
   /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
PROTECTED METHOD Dispose( disposing AS LOGIC ) AS VOID
      IF disposing && components != NULL
         components:Dispose()
      ENDIF
      SUPER:Dispose( disposing )
      RETURN
    
   /// <summary>
   /// Required method for Designer support - do not modify
   /// the contents of this method with the code editor.
   /// </summary>
PRIVATE METHOD InitializeComponent() AS VOID STRICT
    SELF:components := System.ComponentModel.Container{}
    LOCAL resources := System.ComponentModel.ComponentResourceManager{typeof(VesselsForm)} AS System.ComponentModel.ComponentResourceManager
    LOCAL superToolTip1 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem1 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL toolTipItem1 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
    LOCAL superToolTip2 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem2 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL toolTipItem2 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
    LOCAL superToolTip3 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem3 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL toolTipItem3 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
    LOCAL superToolTip4 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem4 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL superToolTip5 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem5 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL toolTipItem4 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
    LOCAL superToolTip6 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem6 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL toolTipItem5 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
    SELF:barManager := DevExpress.XtraBars.BarManager{SELF:components}
    SELF:BarSetup := DevExpress.XtraBars.Bar{}
    SELF:BBIAdd := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIEdit := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIDelete := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIRefresh := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIPrint := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIClose := DevExpress.XtraBars.BarButtonItem{}
    SELF:barDockControlTop := DevExpress.XtraBars.BarDockControl{}
    SELF:barDockControlBottom := DevExpress.XtraBars.BarDockControl{}
    SELF:barDockControlLeft := DevExpress.XtraBars.BarDockControl{}
    SELF:barDockControlRight := DevExpress.XtraBars.BarDockControl{}
    SELF:GridVessels := DevExpress.XtraGrid.GridControl{}
    SELF:GridViewVessels := DevExpress.XtraGrid.Views.Grid.GridView{}
    ((System.ComponentModel.ISupportInitialize)(SELF:barManager)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:GridVessels)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:GridViewVessels)):BeginInit()
    SELF:SuspendLayout()
    // 
    // barManager
    // 
    SELF:barManager:Bars:AddRange(<DevExpress.XtraBars.Bar>{ SELF:BarSetup })
    SELF:barManager:DockControls:Add(SELF:barDockControlTop)
    SELF:barManager:DockControls:Add(SELF:barDockControlBottom)
    SELF:barManager:DockControls:Add(SELF:barDockControlLeft)
    SELF:barManager:DockControls:Add(SELF:barDockControlRight)
    SELF:barManager:Form := SELF
    SELF:barManager:Items:AddRange(<DevExpress.XtraBars.BarItem>{ SELF:BBIAdd, SELF:BBIClose, SELF:BBIDelete, SELF:BBIRefresh, SELF:BBIPrint, SELF:BBIEdit })
    SELF:barManager:MainMenu := SELF:BarSetup
    SELF:barManager:MaxItemId := 15
    // 
    // BarSetup
    // 
    SELF:BarSetup:BarName := "BarSetup"
    SELF:BarSetup:DockCol := 0
    SELF:BarSetup:DockRow := 0
    SELF:BarSetup:DockStyle := DevExpress.XtraBars.BarDockStyle.Top
    SELF:BarSetup:FloatLocation := System.Drawing.Point{369, 210}
    SELF:BarSetup:FloatSize := System.Drawing.Size{46, 24}
    SELF:BarSetup:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:BBIAdd}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIEdit}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIDelete}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIRefresh}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIPrint}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIClose} })
    SELF:BarSetup:OptionsBar:MultiLine := true
    SELF:BarSetup:OptionsBar:UseWholeRow := true
    SELF:BarSetup:Text := "Main menu"
    // 
    // BBIAdd
    // 
    SELF:BBIAdd:Caption := "Add"
    SELF:BBIAdd:Id := 0
    SELF:BBIAdd:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIAdd.ImageOptions.Image")))
    SELF:BBIAdd:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIAdd.ImageOptions.LargeImage")))
    SELF:BBIAdd:ItemShortcut := DevExpress.XtraBars.BarShortcut{(System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.N)}
    SELF:BBIAdd:Name := "BBIAdd"
    toolTipTitleItem1:Text := "Add (Ctrl-N)"
    toolTipItem1:LeftIndent := 6
    toolTipItem1:Text := "Add new Vessel"
    superToolTip1:Items:Add(toolTipTitleItem1)
    superToolTip1:Items:Add(toolTipItem1)
    SELF:BBIAdd:SuperTip := superToolTip1
    SELF:BBIAdd:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIAdd_ItemClick() }
    // 
    // BBIEdit
    // 
    SELF:BBIEdit:Caption := "Edit"
    SELF:BBIEdit:Id := 5
    SELF:BBIEdit:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIEdit.ImageOptions.Image")))
    SELF:BBIEdit:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIEdit.ImageOptions.LargeImage")))
    SELF:BBIEdit:ItemShortcut := DevExpress.XtraBars.BarShortcut{System.Windows.Forms.Keys.F2}
    SELF:BBIEdit:Name := "BBIEdit"
    toolTipTitleItem2:Text := "Edit (F2)"
    toolTipItem2:LeftIndent := 6
    toolTipItem2:Text := "Edit Vessel"
    superToolTip2:Items:Add(toolTipTitleItem2)
    superToolTip2:Items:Add(toolTipItem2)
    SELF:BBIEdit:SuperTip := superToolTip2
    SELF:BBIEdit:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIEdit_ItemClick() }
    // 
    // BBIDelete
    // 
    SELF:BBIDelete:Caption := "Delete"
    SELF:BBIDelete:Id := 2
    SELF:BBIDelete:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIDelete.ImageOptions.Image")))
    SELF:BBIDelete:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIDelete.ImageOptions.LargeImage")))
    SELF:BBIDelete:Name := "BBIDelete"
    toolTipTitleItem3:Text := "Delete"
    toolTipItem3:LeftIndent := 6
    toolTipItem3:Text := "Delete Vessel"
    superToolTip3:Items:Add(toolTipTitleItem3)
    superToolTip3:Items:Add(toolTipItem3)
    SELF:BBIDelete:SuperTip := superToolTip3
    SELF:BBIDelete:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIDelete_ItemClick() }
    // 
    // BBIRefresh
    // 
    SELF:BBIRefresh:Caption := "Refresh"
    SELF:BBIRefresh:Id := 3
    SELF:BBIRefresh:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIRefresh.ImageOptions.Image")))
    SELF:BBIRefresh:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIRefresh.ImageOptions.LargeImage")))
    SELF:BBIRefresh:Name := "BBIRefresh"
    toolTipTitleItem4:Text := "Refresh"
    superToolTip4:Items:Add(toolTipTitleItem4)
    SELF:BBIRefresh:SuperTip := superToolTip4
    SELF:BBIRefresh:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIRefresh_ItemClick() }
    // 
    // BBIPrint
    // 
    SELF:BBIPrint:Caption := "Print"
    SELF:BBIPrint:Id := 4
    SELF:BBIPrint:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIPrint.ImageOptions.Image")))
    SELF:BBIPrint:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIPrint.ImageOptions.LargeImage")))
    SELF:BBIPrint:ItemShortcut := DevExpress.XtraBars.BarShortcut{(System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.P)}
    SELF:BBIPrint:Name := "BBIPrint"
    toolTipTitleItem5:Text := "Print (Ctrl+P)"
    toolTipItem4:LeftIndent := 6
    toolTipItem4:Text := "Print Vessels"
    superToolTip5:Items:Add(toolTipTitleItem5)
    superToolTip5:Items:Add(toolTipItem4)
    SELF:BBIPrint:SuperTip := superToolTip5
    SELF:BBIPrint:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIPrint_ItemClick() }
    // 
    // BBIClose
    // 
    SELF:BBIClose:Caption := "Close"
    SELF:BBIClose:Id := 1
    SELF:BBIClose:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIClose.ImageOptions.Image")))
    SELF:BBIClose:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIClose.ImageOptions.LargeImage")))
    SELF:BBIClose:ItemShortcut := DevExpress.XtraBars.BarShortcut{(System.Windows.Forms.Keys.Alt | System.Windows.Forms.Keys.F4)}
    SELF:BBIClose:Name := "BBIClose"
    toolTipTitleItem6:Text := "Close (Alt+F4)"
    toolTipItem5:LeftIndent := 6
    toolTipItem5:Text := "Close window"
    superToolTip6:Items:Add(toolTipTitleItem6)
    superToolTip6:Items:Add(toolTipItem5)
    SELF:BBIClose:SuperTip := superToolTip6
    SELF:BBIClose:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIClose_ItemClick() }
    // 
    // barDockControlTop
    // 
    SELF:barDockControlTop:CausesValidation := false
    SELF:barDockControlTop:Dock := System.Windows.Forms.DockStyle.Top
    SELF:barDockControlTop:Location := System.Drawing.Point{0, 0}
    SELF:barDockControlTop:Manager := SELF:barManager
    SELF:barDockControlTop:Size := System.Drawing.Size{724, 28}
    // 
    // barDockControlBottom
    // 
    SELF:barDockControlBottom:CausesValidation := false
    SELF:barDockControlBottom:Dock := System.Windows.Forms.DockStyle.Bottom
    SELF:barDockControlBottom:Location := System.Drawing.Point{0, 562}
    SELF:barDockControlBottom:Manager := SELF:barManager
    SELF:barDockControlBottom:Size := System.Drawing.Size{724, 0}
    // 
    // barDockControlLeft
    // 
    SELF:barDockControlLeft:CausesValidation := false
    SELF:barDockControlLeft:Dock := System.Windows.Forms.DockStyle.Left
    SELF:barDockControlLeft:Location := System.Drawing.Point{0, 28}
    SELF:barDockControlLeft:Manager := SELF:barManager
    SELF:barDockControlLeft:Size := System.Drawing.Size{0, 534}
    // 
    // barDockControlRight
    // 
    SELF:barDockControlRight:CausesValidation := false
    SELF:barDockControlRight:Dock := System.Windows.Forms.DockStyle.Right
    SELF:barDockControlRight:Location := System.Drawing.Point{724, 28}
    SELF:barDockControlRight:Manager := SELF:barManager
    SELF:barDockControlRight:Size := System.Drawing.Size{0, 534}
    // 
    // GridVessels
    // 
    SELF:GridVessels:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:GridVessels:Location := System.Drawing.Point{0, 28}
    SELF:GridVessels:MainView := SELF:GridViewVessels
    SELF:GridVessels:Name := "GridVessels"
    SELF:GridVessels:Size := System.Drawing.Size{724, 534}
    SELF:GridVessels:TabIndex := 73
    SELF:GridVessels:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:GridViewVessels })
    // 
    // GridViewVessels
    // 
    SELF:GridViewVessels:GridControl := SELF:GridVessels
    SELF:GridViewVessels:Name := "GridViewVessels"
    SELF:GridViewVessels:FocusedColumnChanged += DevExpress.XtraGrid.Views.Base.FocusedColumnChangedEventHandler{ SELF, @GridViewVessels_FocusedColumnChanged() }
    SELF:GridViewVessels:CellValueChanged += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @GridViewVessels_CellValueChanged() }
    SELF:GridViewVessels:CellValueChanging += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @GridViewVessels_CellValueChanging() }
    SELF:GridViewVessels:BeforeLeaveRow += DevExpress.XtraGrid.Views.Base.RowAllowEventHandler{ SELF, @GridViewVessels_BeforeLeaveRow() }
    SELF:GridViewVessels:CustomUnboundColumnData += DevExpress.XtraGrid.Views.Base.CustomColumnDataEventHandler{ SELF, @GridViewVessels_CustomUnboundColumnData() }
    SELF:GridViewVessels:DoubleClick += System.EventHandler{ SELF, @GridViewVessels_DoubleClick() }
    // 
    // VesselsForm
    // 
    SELF:AutoScaleDimensions := System.Drawing.SizeF{6, 13}
    SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
    SELF:ClientSize := System.Drawing.Size{724, 562}
    SELF:Controls:Add(SELF:GridVessels)
    SELF:Controls:Add(SELF:barDockControlLeft)
    SELF:Controls:Add(SELF:barDockControlRight)
    SELF:Controls:Add(SELF:barDockControlBottom)
    SELF:Controls:Add(SELF:barDockControlTop)
    SELF:MaximizeBox := false
    SELF:Name := "VesselsForm"
    SELF:Text := "Vessels Form"
    SELF:FormClosing += System.Windows.Forms.FormClosingEventHandler{ SELF, @VesselsForm_FormClosing() }
    SELF:FormClosed += System.Windows.Forms.FormClosedEventHandler{ SELF, @VesselsForm_FormClosed() }
    SELF:Load += System.EventHandler{ SELF, @VesselsForm_Load() }
    ((System.ComponentModel.ISupportInitialize)(SELF:barManager)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:GridVessels)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:GridViewVessels)):EndInit()
    SELF:ResumeLayout(false)
    SELF:PerformLayout()
PRIVATE METHOD VesselsForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:VesselsForm_OnLoad()
        RETURN
PRIVATE METHOD VesselsForm_FormClosing( sender AS System.Object, e AS System.Windows.Forms.FormClosingEventArgs ) AS System.Void
        oSoftway:SaveFormSettings_DevExpress(SELF, NULL, oMainForm:alForms, oMainForm:alData)
        RETURN
PRIVATE METHOD VesselsForm_FormClosed( sender AS System.Object, e AS System.Windows.Forms.FormClosedEventArgs ) AS System.Void
        SELF:AddRemoveReportTypesVessel()
        //oMainForm:Fill_CheckedLBCVessels()
        oMainForm:Fill_TreeListVessels()
        oMainForm:BingMapUserControl:ShowSelectedVesselsOnMap()
        RETURN
PRIVATE METHOD BBIAdd_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:Vessels_Add()
        RETURN
PRIVATE METHOD BBIEdit_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        // Get GridRow data into a DataRowView object
        LOCAL oRow AS DataRowView

        oRow := (DataRowView)SELF:GridViewVessels:GetFocusedRow()
        SELF:Vessels_Edit(oRow, SELF:GridViewVessels:FocusedColumn)
        RETURN
PRIVATE METHOD BBIDelete_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:Vessels_Delete()
        RETURN
PRIVATE METHOD BBIRefresh_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:Vessels_Refresh()
        RETURN
PRIVATE METHOD BBIPrint_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:Vessels_Print()
        RETURN
PRIVATE METHOD BBIClose_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:Close()
        RETURN
PRIVATE METHOD GridViewVessels_BeforeLeaveRow( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.Void
        SELF:BeforeLeaveRow_Vessels(e)
        RETURN
PRIVATE METHOD GridViewVessels_CellValueChanging( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
        // Handles the uItemType column CellValueChanging to catch the ComboBox selected item
        DO CASE
        CASE e:Column:FieldName == "uFleet"
            SELF:cFleetText := e:Value:ToString()
            SELF:cFleetValue := SELF:FleetComboBoxItem_GetFleetUID(cFleetText)
        ENDCASE
        RETURN
PRIVATE METHOD GridViewVessels_CellValueChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
        //IF SELF:lSuspendNotification
        //    RETURN
        //ENDIF
        SELF:SetEditModeOff_Common(SELF:GridViewVessels)
        SELF:Vessels_Save(e)
        RETURN

    //PRIVATE METHOD GridViewVessels_CustomUnboundColumnData( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs ) AS System.Void
        //SELF:CustomUnboundColumnData_Vessels(e)
        //RETURN
PRIVATE METHOD GridViewVessels_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        LOCAL oPoint := SELF:GridViewVessels:GridControl:PointToClient(Control.MousePosition) AS Point
        LOCAL info := SELF:GridViewVessels:CalcHitInfo(oPoint) AS DevExpress.XtraGrid.Views.Grid.ViewInfo.GridHitInfo
        IF info:InRow .OR. info:InRowCell
            IF SELF:GridViewVessels:IsGroupRow(info:RowHandle)
                RETURN
            ENDIF

            // Get GridRow data into a DataRowView object
            LOCAL oRow AS DataRowView
            oRow:=(DataRowView)SELF:GridViewVessels:GetRow(info:RowHandle)

            IF info:Column <> NULL
                // Set focused Row/Column (for DoubleClick event)
                //SELF:GridViewVessels:FocusedRowHandle := info:RowHandle
                //SELF:GridViewVessels:FocusedColumn := info:Column

                SELF:Vessels_Edit(oRow, info:Column)
            ENDIF
        ENDIF
        RETURN
PRIVATE METHOD GridViewVessels_FocusedColumnChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.FocusedColumnChangedEventArgs ) AS System.Void
        //IF SELF:lSuspendNotification
        //    RETURN
        //ENDIF
        SELF:SetEditModeOff_Common(SELF:GridViewVessels)
        RETURN
PRIVATE METHOD GridViewVessels_CustomUnboundColumnData( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs ) AS System.Void
        SELF:CustomUnboundColumnData_Vessels(e)
        RETURN

END CLASS 
