﻿//------------------------------------------------------------------------------
//  <auto-generated>
//     This code was generated by a tool.
//     Runtime version: 4.0.30319.42000
//     Generator      : XSharp.CodeDomProvider 2.1.0.0
//     Timestamp      : 17/2/2020 14:15:13
//     
//     Changes to this file may cause incorrect behavior and may be lost if
//     the code is regenerated.
//  </auto-generated>
//------------------------------------------------------------------------------
PUBLIC PARTIAL CLASS PortsForm ;
    INHERIT DevExpress.XtraEditors.XtraForm
    PRIVATE barManager1 AS DevExpress.XtraBars.BarManager
    PRIVATE barDockControlTop AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlBottom AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlLeft AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlRight AS DevExpress.XtraBars.BarDockControl
    PRIVATE BarSetup AS DevExpress.XtraBars.Bar
    PRIVATE BBIClose AS DevExpress.XtraBars.BarButtonItem
    PRIVATE GridPorts AS DevExpress.XtraGrid.GridControl
    PRIVATE GridViewPorts AS DevExpress.XtraGrid.Views.Grid.GridView
    PRIVATE BBIAdd AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIEdit AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIDelete AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIRefresh AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIPrint AS DevExpress.XtraBars.BarButtonItem
    PRIVATE components := NULL AS System.ComponentModel.IContainer
                                                                                                                                                                                                                        
        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
    PROTECTED METHOD Dispose(disposing AS LOGIC) AS VOID STRICT

            IF (disposing .AND. (components != NULL))
                components:Dispose()
            ENDIF
            SUPER:Dispose(disposing)
            RETURN

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
    PRIVATE METHOD InitializeComponent() AS VOID STRICT
        SELF:components := System.ComponentModel.Container{}
        LOCAL resources := System.ComponentModel.ComponentResourceManager{TYPEOF(PortsForm)} AS System.ComponentModel.ComponentResourceManager
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
        LOCAL gridLevelNode1 := DevExpress.XtraGrid.GridLevelNode{} AS DevExpress.XtraGrid.GridLevelNode
        SELF:barManager1 := DevExpress.XtraBars.BarManager{SELF:components}
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
        SELF:GridPorts := DevExpress.XtraGrid.GridControl{}
        SELF:GridViewPorts := DevExpress.XtraGrid.Views.Grid.GridView{}
        ((System.ComponentModel.ISupportInitialize)(SELF:barManager1)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:GridPorts)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:GridViewPorts)):BeginInit()
        SELF:SuspendLayout()
        // 
        // barManager1
        // 
        SELF:barManager1:Bars:AddRange(<DevExpress.XtraBars.Bar>{ SELF:BarSetup })
        SELF:barManager1:DockControls:Add(SELF:barDockControlTop)
        SELF:barManager1:DockControls:Add(SELF:barDockControlBottom)
        SELF:barManager1:DockControls:Add(SELF:barDockControlLeft)
        SELF:barManager1:DockControls:Add(SELF:barDockControlRight)
        SELF:barManager1:Form := SELF
        SELF:barManager1:Items:AddRange(<DevExpress.XtraBars.BarItem>{ SELF:BBIAdd, SELF:BBIEdit, SELF:BBIDelete, SELF:BBIPrint, SELF:BBIClose, SELF:BBIRefresh })
        SELF:barManager1:MainMenu := SELF:BarSetup
        SELF:barManager1:MaxItemId := 7
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
        SELF:BBIAdd:Caption := "Add New Port"
        SELF:BBIAdd:Id := 0
        SELF:BBIAdd:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIAdd.ImageOptions.Image")))
        SELF:BBIAdd:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIAdd.ImageOptions.LargeImage")))
        SELF:BBIAdd:ItemShortcut := DevExpress.XtraBars.BarShortcut{(System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.N)}
        SELF:BBIAdd:Name := "BBIAdd"
        toolTipTitleItem1:Text := "Add (Ctrl+N)"
        toolTipItem1:LeftIndent := 6
        toolTipItem1:Text := "Add New Port"
        superToolTip1:Items:Add(toolTipTitleItem1)
        superToolTip1:Items:Add(toolTipItem1)
        SELF:BBIAdd:SuperTip := superToolTip1
        SELF:BBIAdd:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIAdd_ItemClick() }
        // 
        // BBIEdit
        // 
        SELF:BBIEdit:Caption := "Edit Port"
        SELF:BBIEdit:Id := 1
        SELF:BBIEdit:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIEdit.ImageOptions.Image")))
        SELF:BBIEdit:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIEdit.ImageOptions.LargeImage")))
        SELF:BBIEdit:ItemShortcut := DevExpress.XtraBars.BarShortcut{System.Windows.Forms.Keys.F2}
        SELF:BBIEdit:Name := "BBIEdit"
        toolTipTitleItem2:Text := "Edit (F2)"
        toolTipItem2:LeftIndent := 6
        toolTipItem2:Text := "Edit Port"
        superToolTip2:Items:Add(toolTipTitleItem2)
        superToolTip2:Items:Add(toolTipItem2)
        SELF:BBIEdit:SuperTip := superToolTip2
        SELF:BBIEdit:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIEdit_ItemClick() }
        // 
        // BBIDelete
        // 
        SELF:BBIDelete:Caption := "Delete Port"
        SELF:BBIDelete:Id := 2
        SELF:BBIDelete:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIDelete.ImageOptions.Image")))
        SELF:BBIDelete:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIDelete.ImageOptions.LargeImage")))
        SELF:BBIDelete:ItemShortcut := DevExpress.XtraBars.BarShortcut{System.Windows.Forms.Keys.Delete}
        SELF:BBIDelete:Name := "BBIDelete"
        toolTipTitleItem3:Text := "Delete"
        toolTipItem3:LeftIndent := 6
        toolTipItem3:Text := "Delete Port"
        superToolTip3:Items:Add(toolTipTitleItem3)
        superToolTip3:Items:Add(toolTipItem3)
        SELF:BBIDelete:SuperTip := superToolTip3
        SELF:BBIDelete:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIDelete_ItemClick() }
        // 
        // BBIRefresh
        // 
        SELF:BBIRefresh:Caption := "Refresh"
        SELF:BBIRefresh:Id := 6
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
        SELF:BBIPrint:Caption := "Print Ports"
        SELF:BBIPrint:Id := 3
        SELF:BBIPrint:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIPrint.ImageOptions.Image")))
        SELF:BBIPrint:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIPrint.ImageOptions.LargeImage")))
        SELF:BBIPrint:ItemShortcut := DevExpress.XtraBars.BarShortcut{(System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.P)}
        SELF:BBIPrint:Name := "BBIPrint"
        toolTipTitleItem5:Text := "Print (Ctrl+P)"
        toolTipItem4:LeftIndent := 6
        toolTipItem4:Text := "Print Ports"
        superToolTip5:Items:Add(toolTipTitleItem5)
        superToolTip5:Items:Add(toolTipItem4)
        SELF:BBIPrint:SuperTip := superToolTip5
        SELF:BBIPrint:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIPrint_ItemClick() }
        // 
        // BBIClose
        // 
        SELF:BBIClose:Caption := "Close"
        SELF:BBIClose:Id := 4
        SELF:BBIClose:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIClose.ImageOptions.Image")))
        SELF:BBIClose:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIClose.ImageOptions.LargeImage")))
        SELF:BBIClose:ItemShortcut := DevExpress.XtraBars.BarShortcut{(System.Windows.Forms.Keys.Alt | System.Windows.Forms.Keys.F4)}
        SELF:BBIClose:Name := "BBIClose"
        toolTipTitleItem6:Text := "Close (Alt+F4)"
        toolTipItem5:LeftIndent := 6
        toolTipItem5:Text := "Close Form"
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
        SELF:barDockControlTop:Manager := SELF:barManager1
        SELF:barDockControlTop:Size := System.Drawing.Size{724, 24}
        // 
        // barDockControlBottom
        // 
        SELF:barDockControlBottom:CausesValidation := false
        SELF:barDockControlBottom:Dock := System.Windows.Forms.DockStyle.Bottom
        SELF:barDockControlBottom:Location := System.Drawing.Point{0, 562}
        SELF:barDockControlBottom:Manager := SELF:barManager1
        SELF:barDockControlBottom:Size := System.Drawing.Size{724, 0}
        // 
        // barDockControlLeft
        // 
        SELF:barDockControlLeft:CausesValidation := false
        SELF:barDockControlLeft:Dock := System.Windows.Forms.DockStyle.Left
        SELF:barDockControlLeft:Location := System.Drawing.Point{0, 24}
        SELF:barDockControlLeft:Manager := SELF:barManager1
        SELF:barDockControlLeft:Size := System.Drawing.Size{0, 538}
        // 
        // barDockControlRight
        // 
        SELF:barDockControlRight:CausesValidation := false
        SELF:barDockControlRight:Dock := System.Windows.Forms.DockStyle.Right
        SELF:barDockControlRight:Location := System.Drawing.Point{724, 24}
        SELF:barDockControlRight:Manager := SELF:barManager1
        SELF:barDockControlRight:Size := System.Drawing.Size{0, 538}
        // 
        // GridPorts
        // 
        SELF:GridPorts:Dock := System.Windows.Forms.DockStyle.Fill
        gridLevelNode1:RelationName := "Level1"
        SELF:GridPorts:LevelTree:Nodes:AddRange(<DevExpress.XtraGrid.GridLevelNode>{ gridLevelNode1 })
        SELF:GridPorts:Location := System.Drawing.Point{0, 24}
        SELF:GridPorts:MainView := SELF:GridViewPorts
        SELF:GridPorts:MenuManager := SELF:barManager1
        SELF:GridPorts:Name := "GridPorts"
        SELF:GridPorts:Size := System.Drawing.Size{724, 538}
        SELF:GridPorts:TabIndex := 4
        SELF:GridPorts:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:GridViewPorts })
        // 
        // GridViewPorts
        // 
        SELF:GridViewPorts:GridControl := SELF:GridPorts
        SELF:GridViewPorts:Name := "GridViewPorts"
        SELF:GridViewPorts:OptionsView:ShowGroupPanel := false
        SELF:GridViewPorts:FocusedColumnChanged += DevExpress.XtraGrid.Views.Base.FocusedColumnChangedEventHandler{ SELF, @GridViewPorts_FocusedColumnChanged() }
        SELF:GridViewPorts:CellValueChanged += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @GridViewPorts_CellValueChanged() }
        SELF:GridViewPorts:CellValueChanging += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @GridViewPorts_CellValueChanging() }
        SELF:GridViewPorts:BeforeLeaveRow += DevExpress.XtraGrid.Views.Base.RowAllowEventHandler{ SELF, @GridViewPorts_BeforeLeaveRow() }
        SELF:GridViewPorts:CustomUnboundColumnData += DevExpress.XtraGrid.Views.Base.CustomColumnDataEventHandler{ SELF, @GridViewPorts_CustomUnboundColumnData() }
        SELF:GridViewPorts:DoubleClick += System.EventHandler{ SELF, @GridViewPorts_DoubleClick() }
        // 
        // PortsForm
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{6, 13}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{724, 562}
        SELF:Controls:Add(SELF:GridPorts)
        SELF:Controls:Add(SELF:barDockControlLeft)
        SELF:Controls:Add(SELF:barDockControlRight)
        SELF:Controls:Add(SELF:barDockControlBottom)
        SELF:Controls:Add(SELF:barDockControlTop)
        SELF:Name := "PortsForm"
        SELF:ShowIcon := false
        SELF:StartPosition := System.Windows.Forms.FormStartPosition.CenterParent
        SELF:Text := "Ports Form"
        SELF:FormClosing += System.Windows.Forms.FormClosingEventHandler{ SELF, @PortsForm_FormClosing() }
        SELF:FormClosed += System.Windows.Forms.FormClosedEventHandler{ SELF, @PortsForm_FormClosed() }
        SELF:Load += System.EventHandler{ SELF, @PortsForm_Load() }
        ((System.ComponentModel.ISupportInitialize)(SELF:barManager1)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:GridPorts)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:GridViewPorts)):EndInit()
        SELF:ResumeLayout(false)
        SELF:PerformLayout()

        #endregion

END CLASS 