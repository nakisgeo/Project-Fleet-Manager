USING System.Windows.Forms
USING System.Data
USING System.Drawing
USING DevExpress.XtraBars
USING DevExpress.XtraGrid.Views.Grid
USING DevExpress.XtraGrid.Views.Grid.ViewInfo
PUBLIC PARTIAL CLASS VoyagesForm ;
    INHERIT System.Windows.Forms.Form
    PUBLIC GridViewRoutings AS DevExpress.XtraGrid.Views.Grid.GridView
    PRIVATE GridVoyages AS DevExpress.XtraGrid.GridControl
    PUBLIC GridViewVoyages AS DevExpress.XtraGrid.Views.Grid.GridView
    PRIVATE standaloneBarDockControl_Voyages AS DevExpress.XtraBars.StandaloneBarDockControl
    PRIVATE BBILog AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBICalculateROB AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIAdd AS DevExpress.XtraBars.BarButtonItem
    PRIVATE barDockControlRight AS DevExpress.XtraBars.BarDockControl
    PRIVATE barManager AS DevExpress.XtraBars.BarManager
    PRIVATE barVoyages AS DevExpress.XtraBars.Bar
    PRIVATE BBINewRouting AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIEdit AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIDelete AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIRefresh AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIPrint AS DevExpress.XtraBars.BarButtonItem
    PRIVATE barDockControlTop AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlBottom AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlLeft AS DevExpress.XtraBars.BarDockControl
    PRIVATE splitContainerControl AS DevExpress.XtraEditors.SplitContainerControl
    PUBLIC LookUpEditCompany_Voyages AS DevExpress.XtraEditors.LookUpEdit
    PRIVATE label12 AS System.Windows.Forms.Label
    PUBLIC LBSuggest AS DevExpress.XtraEditors.ListBoxControl
    PRIVATE BBIClose AS DevExpress.XtraBars.BarButtonItem
    PRIVATE dockManager1 AS DevExpress.XtraBars.Docking.DockManager
    PRIVATE panel1 AS System.Windows.Forms.Panel
    PUBLIC routingDetails1 AS RoutingDetails
    PRIVATE splitContainerControl1 AS DevExpress.XtraEditors.SplitContainerControl
    PRIVATE BBIAttachments AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIMWA AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIMWD AS DevExpress.XtraBars.BarButtonItem
    PRIVATE bbiMRVVoyageReport AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBICreateFolders AS DevExpress.XtraBars.BarButtonItem
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
    LOCAL gridLevelNode1 := DevExpress.XtraGrid.GridLevelNode{} AS DevExpress.XtraGrid.GridLevelNode
    LOCAL resources := System.ComponentModel.ComponentResourceManager{typeof(VoyagesForm)} AS System.ComponentModel.ComponentResourceManager
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
    LOCAL superToolTip7 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem7 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL toolTipItem5 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
    LOCAL superToolTip8 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem8 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    SELF:GridViewRoutings := DevExpress.XtraGrid.Views.Grid.GridView{}
    SELF:GridVoyages := DevExpress.XtraGrid.GridControl{}
    SELF:GridViewVoyages := DevExpress.XtraGrid.Views.Grid.GridView{}
    SELF:standaloneBarDockControl_Voyages := DevExpress.XtraBars.StandaloneBarDockControl{}
    SELF:barManager := DevExpress.XtraBars.BarManager{SELF:components}
    SELF:barVoyages := DevExpress.XtraBars.Bar{}
    SELF:BBIAdd := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBINewRouting := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIEdit := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIDelete := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIRefresh := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIPrint := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBICalculateROB := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBILog := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIAttachments := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIMWD := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIMWA := DevExpress.XtraBars.BarButtonItem{}
    SELF:bbiMRVVoyageReport := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBICreateFolders := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIClose := DevExpress.XtraBars.BarButtonItem{}
    SELF:barDockControlTop := DevExpress.XtraBars.BarDockControl{}
    SELF:barDockControlBottom := DevExpress.XtraBars.BarDockControl{}
    SELF:barDockControlLeft := DevExpress.XtraBars.BarDockControl{}
    SELF:barDockControlRight := DevExpress.XtraBars.BarDockControl{}
    SELF:dockManager1 := DevExpress.XtraBars.Docking.DockManager{SELF:components}
    SELF:LookUpEditCompany_Voyages := DevExpress.XtraEditors.LookUpEdit{}
    SELF:label12 := System.Windows.Forms.Label{}
    SELF:splitContainerControl := DevExpress.XtraEditors.SplitContainerControl{}
    SELF:LBSuggest := DevExpress.XtraEditors.ListBoxControl{}
    SELF:routingDetails1 := RoutingDetails{}
    SELF:panel1 := System.Windows.Forms.Panel{}
    SELF:splitContainerControl1 := DevExpress.XtraEditors.SplitContainerControl{}
    ((System.ComponentModel.ISupportInitialize)(SELF:GridViewRoutings)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:GridVoyages)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:GridViewVoyages)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:barManager)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:dockManager1)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:LookUpEditCompany_Voyages:Properties)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl)):BeginInit()
    SELF:splitContainerControl:SuspendLayout()
    ((System.ComponentModel.ISupportInitialize)(SELF:LBSuggest)):BeginInit()
    SELF:panel1:SuspendLayout()
    ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl1)):BeginInit()
    SELF:splitContainerControl1:SuspendLayout()
    SELF:SuspendLayout()
    // 
    // GridViewRoutings
    // 
    SELF:GridViewRoutings:GridControl := SELF:GridVoyages
    SELF:GridViewRoutings:Name := "GridViewRoutings"
    SELF:GridViewRoutings:OptionsBehavior:AutoPopulateColumns := FALSE
    SELF:GridViewRoutings:OptionsCustomization:AllowColumnMoving := FALSE
    SELF:GridViewRoutings:OptionsCustomization:AllowQuickHideColumns := FALSE
    SELF:GridViewRoutings:OptionsCustomization:AllowSort := FALSE
    SELF:GridViewRoutings:OptionsFilter:AllowFilterEditor := FALSE
    SELF:GridViewRoutings:OptionsFilter:AllowMRUFilterList := FALSE
    SELF:GridViewRoutings:OptionsMenu:ShowGroupSortSummaryItems := FALSE
    SELF:GridViewRoutings:OptionsView:GroupFooterShowMode := DevExpress.XtraGrid.Views.Grid.GroupFooterShowMode.@@Hidden
    SELF:GridViewRoutings:OptionsView:ShowGroupPanel := FALSE
    SELF:GridViewRoutings:FocusedRowChanged += DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventHandler{ SELF, @GridViewRoutings_FocusedRowChanged() }
    SELF:GridViewRoutings:FocusedColumnChanged += DevExpress.XtraGrid.Views.Base.FocusedColumnChangedEventHandler{ SELF, @GridViewRoutings_FocusedColumnChanged() }
    SELF:GridViewRoutings:CellValueChanged += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @GridViewRoutings_CellValueChanged() }
    SELF:GridViewRoutings:CellValueChanging += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @GridViewRoutings_CellValueChanging() }
    SELF:GridViewRoutings:BeforeLeaveRow += DevExpress.XtraGrid.Views.Base.RowAllowEventHandler{ SELF, @GridViewRoutings_BeforeLeaveRow() }
    SELF:GridViewRoutings:CustomUnboundColumnData += DevExpress.XtraGrid.Views.Base.CustomColumnDataEventHandler{ SELF, @GridViewRoutings_CustomUnboundColumnData() }
    SELF:GridViewRoutings:Click += System.EventHandler{ SELF, @GridViewRoutings_Click() }
    SELF:GridViewRoutings:DoubleClick += System.EventHandler{ SELF, @GridViewRoutings_DoubleClick() }
    SELF:GridViewRoutings:LostFocus += System.EventHandler{ SELF, @GridViewRoutings_LostFocus() }
    SELF:GridViewRoutings:GotFocus += System.EventHandler{ SELF, @GridViewRoutings_GotFocus() }
    // 
    // GridVoyages
    // 
    SELF:GridVoyages:Dock := System.Windows.Forms.DockStyle.Fill
    gridLevelNode1:LevelTemplate := SELF:GridViewRoutings
    gridLevelNode1:RelationName := "Voyage Routing"
    SELF:GridVoyages:LevelTree:Nodes:AddRange(<DevExpress.XtraGrid.GridLevelNode>{ gridLevelNode1 })
    SELF:GridVoyages:Location := System.Drawing.Point{0, 26}
    SELF:GridVoyages:MainView := SELF:GridViewVoyages
    SELF:GridVoyages:Name := "GridVoyages"
    SELF:GridVoyages:Size := System.Drawing.Size{1000, 635}
    SELF:GridVoyages:TabIndex := 72
    SELF:GridVoyages:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:GridViewVoyages, SELF:GridViewRoutings })
    // 
    // GridViewVoyages
    // 
    SELF:GridViewVoyages:GridControl := SELF:GridVoyages
    SELF:GridViewVoyages:Name := "GridViewVoyages"
    SELF:GridViewVoyages:OptionsBehavior:AutoPopulateColumns := FALSE
    SELF:GridViewVoyages:FocusedRowChanged += DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventHandler{ SELF, @GridViewVoyages_FocusedRowChanged() }
    SELF:GridViewVoyages:FocusedColumnChanged += DevExpress.XtraGrid.Views.Base.FocusedColumnChangedEventHandler{ SELF, @GridViewVoyages_FocusedColumnChanged() }
    SELF:GridViewVoyages:CellValueChanged += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @GridViewVoyages_CellValueChanged() }
    SELF:GridViewVoyages:CellValueChanging += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @GridViewVoyages_CellValueChanging() }
    SELF:GridViewVoyages:BeforeLeaveRow += DevExpress.XtraGrid.Views.Base.RowAllowEventHandler{ SELF, @GridViewVoyages_BeforeLeaveRow() }
    SELF:GridViewVoyages:CustomUnboundColumnData += DevExpress.XtraGrid.Views.Base.CustomColumnDataEventHandler{ SELF, @GridViewVoyages_CustomUnboundColumnData() }
    SELF:GridViewVoyages:DoubleClick += System.EventHandler{ SELF, @GridViewVoyages_DoubleClick() }
    // 
    // standaloneBarDockControl_Voyages
    // 
    SELF:standaloneBarDockControl_Voyages:CausesValidation := FALSE
    SELF:standaloneBarDockControl_Voyages:Dock := System.Windows.Forms.DockStyle.Top
    SELF:standaloneBarDockControl_Voyages:Location := System.Drawing.Point{0, 0}
    SELF:standaloneBarDockControl_Voyages:Manager := SELF:barManager
    SELF:standaloneBarDockControl_Voyages:Name := "standaloneBarDockControl_Voyages"
    SELF:standaloneBarDockControl_Voyages:Size := System.Drawing.Size{1000, 26}
    SELF:standaloneBarDockControl_Voyages:Text := "standaloneBarDockControl1"
    // 
    // barManager
    // 
    SELF:barManager:Bars:AddRange(<DevExpress.XtraBars.Bar>{ SELF:barVoyages })
    SELF:barManager:DockControls:Add(SELF:barDockControlTop)
    SELF:barManager:DockControls:Add(SELF:barDockControlBottom)
    SELF:barManager:DockControls:Add(SELF:barDockControlLeft)
    SELF:barManager:DockControls:Add(SELF:barDockControlRight)
    SELF:barManager:DockControls:Add(SELF:standaloneBarDockControl_Voyages)
    SELF:barManager:DockManager := SELF:dockManager1
    SELF:barManager:Form := SELF
    SELF:barManager:Items:AddRange(<DevExpress.XtraBars.BarItem>{ SELF:BBIAdd, SELF:BBIEdit, SELF:BBIDelete, SELF:BBIRefresh, SELF:BBIPrint, SELF:BBINewRouting, SELF:BBILog, SELF:BBICalculateROB, SELF:BBIClose, SELF:BBIAttachments, SELF:BBIMWA, SELF:BBIMWD, SELF:bbiMRVVoyageReport, SELF:BBICreateFolders })
    SELF:barManager:MainMenu := SELF:barVoyages
    SELF:barManager:MaxItemId := 15
    // 
    // barVoyages
    // 
    SELF:barVoyages:BarName := "Main menu"
    SELF:barVoyages:DockCol := 0
    SELF:barVoyages:DockRow := 0
    SELF:barVoyages:DockStyle := DevExpress.XtraBars.BarDockStyle.Standalone
    SELF:barVoyages:FloatLocation := System.Drawing.Point{605, 200}
    SELF:barVoyages:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:BBIAdd}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBINewRouting}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIEdit}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIDelete}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIRefresh}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIPrint}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBICalculateROB}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBILog}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIAttachments}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIMWD}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIMWA}, DevExpress.XtraBars.LinkPersistInfo{SELF:bbiMRVVoyageReport}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBICreateFolders}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIClose} })
    SELF:barVoyages:OptionsBar:MultiLine := TRUE
    SELF:barVoyages:OptionsBar:UseWholeRow := TRUE
    SELF:barVoyages:StandaloneBarDockControl := SELF:standaloneBarDockControl_Voyages
    SELF:barVoyages:Text := "Main menu"
    // 
    // BBIAdd
    // 
    SELF:BBIAdd:Caption := "New"
    SELF:BBIAdd:Id := 0
    SELF:BBIAdd:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIAdd.ImageOptions.Image")))
    SELF:BBIAdd:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIAdd.ImageOptions.LargeImage")))
    SELF:BBIAdd:ItemShortcut := DevExpress.XtraBars.BarShortcut{(System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.N)}
    SELF:BBIAdd:Name := "BBIAdd"
    toolTipTitleItem1:Text := "Add (Ctrl-N)"
    toolTipItem1:LeftIndent := 6
    toolTipItem1:Text := "Create new Voyage"
    superToolTip1:Items:Add(toolTipTitleItem1)
    superToolTip1:Items:Add(toolTipItem1)
    SELF:BBIAdd:SuperTip := superToolTip1
    SELF:BBIAdd:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIAdd_ItemClick() }
    // 
    // BBINewRouting
    // 
    SELF:BBINewRouting:Caption := "New Voyage Routing or Time Charter Voyage"
    SELF:BBINewRouting:Id := 6
    SELF:BBINewRouting:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBINewRouting.ImageOptions.Image")))
    SELF:BBINewRouting:Name := "BBINewRouting"
    SELF:BBINewRouting:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBINewRouting_ItemClick() }
    // 
    // BBIEdit
    // 
    SELF:BBIEdit:Caption := "Edit"
    SELF:BBIEdit:Id := 1
    SELF:BBIEdit:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIEdit.ImageOptions.Image")))
    SELF:BBIEdit:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIEdit.ImageOptions.LargeImage")))
    SELF:BBIEdit:ItemShortcut := DevExpress.XtraBars.BarShortcut{System.Windows.Forms.Keys.F2}
    SELF:BBIEdit:Name := "BBIEdit"
    toolTipTitleItem2:Text := "Edit (F2)"
    toolTipItem2:LeftIndent := 6
    toolTipItem2:Text := "Edit Voyage"
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
    toolTipItem3:Text := "Delete Voyage"
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
    SELF:BBIPrint:Id := 5
    SELF:BBIPrint:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIPrint.ImageOptions.Image")))
    SELF:BBIPrint:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIPrint.ImageOptions.LargeImage")))
    SELF:BBIPrint:ItemShortcut := DevExpress.XtraBars.BarShortcut{(System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.P)}
    SELF:BBIPrint:Name := "BBIPrint"
    toolTipTitleItem5:Text := "Print (Ctrl+P)"
    toolTipItem4:LeftIndent := 6
    toolTipItem4:Text := "Print Voyages"
    superToolTip5:Items:Add(toolTipTitleItem5)
    superToolTip5:Items:Add(toolTipItem4)
    SELF:BBIPrint:SuperTip := superToolTip5
    SELF:BBIPrint:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIPrint_ItemClick() }
    // 
    // BBICalculateROB
    // 
    SELF:BBICalculateROB:Caption := "Calculate Arrival FO ROB"
    SELF:BBICalculateROB:Id := 8
    SELF:BBICalculateROB:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBICalculateROB.ImageOptions.Image")))
    SELF:BBICalculateROB:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBICalculateROB.ImageOptions.LargeImage")))
    SELF:BBICalculateROB:Name := "BBICalculateROB"
    toolTipTitleItem6:Text := "Calculate Arrival FO ROB"
    superToolTip6:Items:Add(toolTipTitleItem6)
    SELF:BBICalculateROB:SuperTip := superToolTip6
    SELF:BBICalculateROB:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:BBICalculateROB:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBICalculateROB_ItemClick() }
    // 
    // BBILog
    // 
    SELF:BBILog:Caption := "BBILog"
    SELF:BBILog:Id := 7
    SELF:BBILog:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBILog.ImageOptions.Image")))
    SELF:BBILog:Name := "BBILog"
    toolTipTitleItem7:Text := "Voyage Logs"
    toolTipItem5:LeftIndent := 6
    toolTipItem5:Text := "Voyage changes made on Ship"
    superToolTip7:Items:Add(toolTipTitleItem7)
    superToolTip7:Items:Add(toolTipItem5)
    SELF:BBILog:SuperTip := superToolTip7
    SELF:BBILog:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:BBILog:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBILog_ItemClick() }
    // 
    // BBIAttachments
    // 
    SELF:BBIAttachments:Caption := "Attachments"
    SELF:BBIAttachments:Id := 10
    SELF:BBIAttachments:Name := "BBIAttachments"
    SELF:BBIAttachments:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @barButtonItem1_ItemClick() }
    // 
    // BBIMWD
    // 
    SELF:BBIMWD:Caption := "Match With Departure"
    SELF:BBIMWD:Id := 12
    SELF:BBIMWD:Name := "BBIMWD"
    SELF:BBIMWD:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIMWD_ItemClick() }
    // 
    // BBIMWA
    // 
    SELF:BBIMWA:Caption := "Match With Arrival"
    SELF:BBIMWA:Id := 11
    SELF:BBIMWA:Name := "BBIMWA"
    SELF:BBIMWA:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIMWA_ItemClick() }
    // 
    // bbiMRVVoyageReport
    // 
    SELF:bbiMRVVoyageReport:Caption := "MRV Report"
    SELF:bbiMRVVoyageReport:Id := 13
    SELF:bbiMRVVoyageReport:Name := "bbiMRVVoyageReport"
    SELF:bbiMRVVoyageReport:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @bbiMRVVoyageReport_ItemClick() }
    // 
    // BBICreateFolders
    // 
    SELF:BBICreateFolders:Caption := "Create foldelrs"
    SELF:BBICreateFolders:Id := 14
    SELF:BBICreateFolders:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBICreateFolders.ImageOptions.Image")))
    SELF:BBICreateFolders:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBICreateFolders.ImageOptions.LargeImage")))
    SELF:BBICreateFolders:Name := "BBICreateFolders"
    SELF:BBICreateFolders:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBICreateFolders_ItemClick() }
    // 
    // BBIClose
    // 
    SELF:BBIClose:Caption := "Close"
    SELF:BBIClose:Id := 9
    SELF:BBIClose:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIClose.ImageOptions.Image")))
    SELF:BBIClose:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIClose.ImageOptions.LargeImage")))
    SELF:BBIClose:Name := "BBIClose"
    toolTipTitleItem8:Text := "Close"
    superToolTip8:Items:Add(toolTipTitleItem8)
    SELF:BBIClose:SuperTip := superToolTip8
    SELF:BBIClose:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIClose_ItemClick() }
    // 
    // barDockControlTop
    // 
    SELF:barDockControlTop:CausesValidation := FALSE
    SELF:barDockControlTop:Dock := System.Windows.Forms.DockStyle.Top
    SELF:barDockControlTop:Location := System.Drawing.Point{0, 0}
    SELF:barDockControlTop:Manager := SELF:barManager
    SELF:barDockControlTop:Size := System.Drawing.Size{1000, 0}
    // 
    // barDockControlBottom
    // 
    SELF:barDockControlBottom:CausesValidation := FALSE
    SELF:barDockControlBottom:Dock := System.Windows.Forms.DockStyle.Bottom
    SELF:barDockControlBottom:Location := System.Drawing.Point{0, 703}
    SELF:barDockControlBottom:Manager := SELF:barManager
    SELF:barDockControlBottom:Size := System.Drawing.Size{1000, 0}
    // 
    // barDockControlLeft
    // 
    SELF:barDockControlLeft:CausesValidation := FALSE
    SELF:barDockControlLeft:Dock := System.Windows.Forms.DockStyle.Left
    SELF:barDockControlLeft:Location := System.Drawing.Point{0, 0}
    SELF:barDockControlLeft:Manager := SELF:barManager
    SELF:barDockControlLeft:Size := System.Drawing.Size{0, 703}
    // 
    // barDockControlRight
    // 
    SELF:barDockControlRight:CausesValidation := FALSE
    SELF:barDockControlRight:Dock := System.Windows.Forms.DockStyle.Right
    SELF:barDockControlRight:Location := System.Drawing.Point{1000, 0}
    SELF:barDockControlRight:Manager := SELF:barManager
    SELF:barDockControlRight:Size := System.Drawing.Size{0, 703}
    // 
    // dockManager1
    // 
    SELF:dockManager1:Form := SELF
    SELF:dockManager1:MenuManager := SELF:barManager
    SELF:dockManager1:TopZIndexControls:AddRange(<STRING>{ "DevExpress.XtraBars.BarDockControl", "DevExpress.XtraBars.StandaloneBarDockControl", "System.Windows.Forms.StatusBar", "DevExpress.XtraBars.Ribbon.RibbonStatusBar", "DevExpress.XtraBars.Ribbon.RibbonControl" })
    // 
    // LookUpEditCompany_Voyages
    // 
    SELF:LookUpEditCompany_Voyages:Location := System.Drawing.Point{49, 7}
    SELF:LookUpEditCompany_Voyages:Name := "LookUpEditCompany_Voyages"
    SELF:LookUpEditCompany_Voyages:Properties:Appearance:Options:UseTextOptions := TRUE
    SELF:LookUpEditCompany_Voyages:Properties:AppearanceFocused:BackColor := System.Drawing.Color.LightGreen
    SELF:LookUpEditCompany_Voyages:Properties:AppearanceFocused:Options:UseBackColor := TRUE
    SELF:LookUpEditCompany_Voyages:Properties:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{DevExpress.XtraEditors.Controls.ButtonPredefines.Combo} })
    SELF:LookUpEditCompany_Voyages:Properties:NullText := ""
    SELF:LookUpEditCompany_Voyages:Size := System.Drawing.Size{150, 20}
    SELF:LookUpEditCompany_Voyages:TabIndex := 34
    SELF:LookUpEditCompany_Voyages:EditValueChanged += System.EventHandler{ SELF, @LookUpEditCompany_Voyages_EditValueChanged() }
    // 
    // label12
    // 
    SELF:label12:AutoSize := TRUE
    SELF:label12:Location := System.Drawing.Point{5, 10}
    SELF:label12:Name := "label12"
    SELF:label12:Size := System.Drawing.Size{41, 13}
    SELF:label12:TabIndex := 35
    SELF:label12:Text := "Vessel:"
    // 
    // splitContainerControl
    // 
    SELF:splitContainerControl:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:splitContainerControl:Horizontal := FALSE
    SELF:splitContainerControl:Location := System.Drawing.Point{0, 0}
    SELF:splitContainerControl:Name := "splitContainerControl"
    SELF:splitContainerControl:Panel1:Controls:Add(SELF:LookUpEditCompany_Voyages)
    SELF:splitContainerControl:Panel1:Controls:Add(SELF:label12)
    SELF:splitContainerControl:Panel1:Text := "Panel1"
    SELF:splitContainerControl:Panel2:Controls:Add(SELF:LBSuggest)
    SELF:splitContainerControl:Panel2:Controls:Add(SELF:GridVoyages)
    SELF:splitContainerControl:Panel2:Controls:Add(SELF:standaloneBarDockControl_Voyages)
    SELF:splitContainerControl:Panel2:Text := "Panel2"
    SELF:splitContainerControl:Size := System.Drawing.Size{1000, 703}
    SELF:splitContainerControl:SplitterPosition := 36
    SELF:splitContainerControl:TabIndex := 38
    SELF:splitContainerControl:Text := "splitContainerControl1"
    // 
    // LBSuggest
    // 
    SELF:LBSuggest:HighlightedItemStyle := DevExpress.XtraEditors.HighlightStyle.Skinned
    SELF:LBSuggest:IncrementalSearch := TRUE
    SELF:LBSuggest:Location := System.Drawing.Point{60, 107}
    SELF:LBSuggest:Name := "LBSuggest"
    SELF:LBSuggest:Size := System.Drawing.Size{57, 15}
    SELF:LBSuggest:SortOrder := System.Windows.Forms.SortOrder.@@Ascending
    SELF:LBSuggest:TabIndex := 74
    SELF:LBSuggest:KeyDown += System.Windows.Forms.KeyEventHandler{ SELF, @LBSuggest_KeyDown() }
    SELF:LBSuggest:KeyPress += System.Windows.Forms.KeyPressEventHandler{ SELF, @LBSuggest_KeyPress() }
    SELF:LBSuggest:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @LBSuggest_KeyUp() }
    SELF:LBSuggest:Leave += System.EventHandler{ SELF, @LBSuggest_Leave() }
    SELF:LBSuggest:MouseDoubleClick += System.Windows.Forms.MouseEventHandler{ SELF, @LBSuggest_MouseDoubleClick() }
    // 
    // routingDetails1
    // 
    SELF:routingDetails1:AutoSize := TRUE
    SELF:routingDetails1:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:routingDetails1:Location := System.Drawing.Point{0, 0}
    SELF:routingDetails1:Name := "routingDetails1"
    SELF:routingDetails1:Size := System.Drawing.Size{0, 0}
    SELF:routingDetails1:TabIndex := 43
    // 
    // panel1
    // 
    SELF:panel1:Controls:Add(SELF:routingDetails1)
    SELF:panel1:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:panel1:Location := System.Drawing.Point{0, 0}
    SELF:panel1:Name := "panel1"
    SELF:panel1:Size := System.Drawing.Size{0, 0}
    SELF:panel1:TabIndex := 44
    // 
    // splitContainerControl1
    // 
    SELF:splitContainerControl1:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:splitContainerControl1:Horizontal := FALSE
    SELF:splitContainerControl1:Location := System.Drawing.Point{0, 0}
    SELF:splitContainerControl1:Name := "splitContainerControl1"
    SELF:splitContainerControl1:Panel1:Controls:Add(SELF:splitContainerControl)
    SELF:splitContainerControl1:Panel1:Text := "Panel1"
    SELF:splitContainerControl1:Panel2:Controls:Add(SELF:panel1)
    SELF:splitContainerControl1:Panel2:Text := "Panel2"
    SELF:splitContainerControl1:PanelVisibility := DevExpress.XtraEditors.SplitPanelVisibility.Panel1
    SELF:splitContainerControl1:Size := System.Drawing.Size{1000, 703}
    SELF:splitContainerControl1:SplitterPosition := 447
    SELF:splitContainerControl1:TabIndex := 49
    // 
    // VoyagesForm
    // 
    SELF:AutoScaleDimensions := System.Drawing.SizeF{6, 13}
    SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
    SELF:ClientSize := System.Drawing.Size{1000, 703}
    SELF:Controls:Add(SELF:splitContainerControl1)
    SELF:Controls:Add(SELF:barDockControlLeft)
    SELF:Controls:Add(SELF:barDockControlRight)
    SELF:Controls:Add(SELF:barDockControlBottom)
    SELF:Controls:Add(SELF:barDockControlTop)
    SELF:Name := "VoyagesForm"
    SELF:Text := "Voyages Form"
    SELF:FormClosing += System.Windows.Forms.FormClosingEventHandler{ SELF, @VoyagesForm_FormClosing() }
    SELF:Load += System.EventHandler{ SELF, @VoyagesForm_Load() }
    SELF:Shown += System.EventHandler{ SELF, @VoyagesForm_Shown() }
    ((System.ComponentModel.ISupportInitialize)(SELF:GridViewRoutings)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:GridVoyages)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:GridViewVoyages)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:barManager)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:dockManager1)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:LookUpEditCompany_Voyages:Properties)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl)):EndInit()
    SELF:splitContainerControl:ResumeLayout(FALSE)
    ((System.ComponentModel.ISupportInitialize)(SELF:LBSuggest)):EndInit()
    SELF:panel1:ResumeLayout(FALSE)
    SELF:panel1:PerformLayout()
    ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl1)):EndInit()
    SELF:splitContainerControl1:ResumeLayout(FALSE)
    SELF:ResumeLayout(FALSE)
    SELF:PerformLayout()
PRIVATE METHOD VoyagesForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:VoyagesForm_OnLoad()
        RETURN
PRIVATE METHOD VoyagesForm_Shown( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:FillCompanies()
        RETURN
PRIVATE METHOD VoyagesForm_FormClosing( sender AS System.Object, e AS System.Windows.Forms.FormClosingEventArgs ) AS System.Void
        oSoftway:SaveFormSettings_DevExpress(SELF, SELF:splitContainerControl, oMainForm:alForms, oMainForm:alData)
        RETURN
PRIVATE METHOD LookUpEditCompany_Voyages_EditValueChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        IF SELF:LookUpEditCompany_Voyages:Text <> ""
            SELF:cVesselUID_Voyages := SELF:LookUpEditCompany_Voyages:EditValue:ToString()
            //SELF:ReadSupVesselData_Voyage()
            //oMainForm:ReadSupVesselData(SELF:cVesselUID_Voyages)
        ENDIF
        //wb(SELF:LookUpEditCompany_Voyages:Text, SELF:cVesselUID_Voyages)
        SELF:CreateGridVoyages()    //" WHERE VESSEL_UNIQUEID="+SELF:cVesselUID_Voyages)
        SELF:GridViewVoyages:Focus()
        RETURN
PRIVATE METHOD BBIAdd_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        IF SELF:GridVoyages:FocusedView == SELF:GridViewVoyages
//            SELF:Voyages_Add()
            SELF:AddNewVoyage()
        ELSE
            SELF:VoyageRouting_Add(FALSE)
        ENDIF
        RETURN
PRIVATE METHOD BBINewRouting_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:VoyageRouting_Add(FALSE)
        RETURN
PRIVATE METHOD BBIEdit_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        LOCAL oRow AS DataRowView
        IF SELF:GridVoyages:FocusedView == SELF:GridViewVoyages
            oRow:=(DataRowView)SELF:GridViewVoyages:GetFocusedRow()
            SELF:Voyages_Edit(oRow, SELF:GridViewVoyages:FocusedColumn)
        ELSE
            LOCAL oView:=(GridView)SELF:GridVoyages:FocusedView AS GridView
            IF oView == NULL
                RETURN
            ENDIF
            oRow:=(DataRowView)oView:GetFocusedRow()
            SELF:VoyageRouting_Edit(oRow, oView:FocusedColumn, oView)
        ENDIF
        RETURN
PRIVATE METHOD BBIDelete_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        IF SELF:GridVoyages:FocusedView == SELF:GridViewVoyages
            SELF:Voyages_Delete()
        ELSE
            SELF:VoyageRouting_Delete()
        ENDIF
        RETURN
PRIVATE METHOD BBIRefresh_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        IF SELF:GridVoyages:FocusedView == SELF:GridViewVoyages
            SELF:Voyages_Refresh()
        ELSE
            SELF:VoyageRouting_Refresh()
        ENDIF
        RETURN
PRIVATE METHOD BBIPrint_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:Voyages_Print()
        RETURN
PRIVATE METHOD BBICalculateROB_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        //LOCAL oView:=(GridView)SELF:GridVoyages:FocusedView AS GridView
        //IF oView == NULL
        //    RETURN
        //ENDIF
        //LOCAL oRow :=(DataRowView)oView:GetFocusedRow() AS DataRowView
        //SELF:CalculateROB(oRow, oView)
        RETURN
PRIVATE METHOD BBILog_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        //SELF:ShowHistoryNotesForm()
        RETURN
PRIVATE METHOD BBIClose_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:Close()
        RETURN

// LBSuggest
PRIVATE METHOD LBSuggest_KeyDown( sender AS System.Object, e AS System.Windows.Forms.KeyEventArgs ) AS System.Void
        LOCAL oView:=(GridView)SELF:GridVoyages:FocusedView AS GridView
        IF oView == NULL
            RETURN
        ENDIF
        LBSuggestPort.KeyDown(e, SELF:LBSuggest, oView)
        RETURN
PRIVATE METHOD LBSuggest_KeyPress( sender AS System.Object, e AS System.Windows.Forms.KeyPressEventArgs ) AS System.Void
        LOCAL oView:=(GridView)SELF:GridVoyages:FocusedView AS GridView
        IF oView == NULL
            RETURN
        ENDIF
        LBSuggestPort.KeyPress(e, SELF:LBSuggest, oView)
        RETURN
PRIVATE METHOD LBSuggest_KeyUp( sender AS System.Object, e AS System.Windows.Forms.KeyEventArgs ) AS System.Void
        LOCAL oView:=(GridView)SELF:GridVoyages:FocusedView AS GridView
        IF oView == NULL
            RETURN
        ENDIF
        LBSuggestPort.KeyUp(e, SELF:LBSuggest, oView)
        RETURN
PRIVATE METHOD LBSuggest_Leave( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        LOCAL oView:=(GridView)SELF:GridVoyages:FocusedView AS GridView
        IF oView == NULL
            RETURN
        ENDIF
        LBSuggestPort.Escape(SELF:LBSuggest, oView, FALSE)
        RETURN
PRIVATE METHOD LBSuggest_MouseDoubleClick( sender AS System.Object, e AS System.Windows.Forms.MouseEventArgs ) AS System.Void
        LOCAL oView:=(GridView)SELF:GridVoyages:FocusedView AS GridView
        IF oView == NULL
            RETURN
        ENDIF
        LBSuggestPort.CommonMethod(SELF:LBSuggest, oView)
        RETURN

// GridViewVoyages
PRIVATE METHOD GridViewVoyages_BeforeLeaveRow( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.Void
        SELF:BeforeLeaveRow_Voyages(e)
        RETURN
PRIVATE METHOD GridViewVoyages_CellValueChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
        IF SELF:LBSuggest:Visible
            RETURN
        ENDIF

        SELF:SetEditModeOff_Common(SELF:GridViewVoyages)
        SELF:Voyages_Save(e)
        RETURN
PRIVATE METHOD GridViewVoyages_CellValueChanging( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
        DO CASE
        CASE e:Column:FieldName == "uType"
            SELF:cVoyageType := e:Value:ToString()
        CASE InListExact(e:Column:FieldName, "PortFrom", "PortTo")
            // LBSuggest
            oMainForm:cLBSuggest_TypedChars := e:Value:ToString()
//            SELF:cLBSuggest_TypedChars := e:Value:ToString()

        CASE e:Column:FieldName == "uPortFromGMT_DIFF"
            SELF:cPortFromGMT_DIFF := e:Value:ToString()

        CASE e:Column:FieldName == "uPortToGMT_DIFF"
            SELF:cPortToGMT_DIFF := e:Value:ToString()
        ENDCASE
        RETURN
PRIVATE METHOD GridViewVoyages_CustomUnboundColumnData( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs ) AS System.Void
        SELF:CustomUnboundColumnData_Voyages(e)
        RETURN
PRIVATE METHOD GridViewVoyages_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        LOCAL oPoint := SELF:GridViewVoyages:GridControl:PointToClient(Control.MousePosition) AS Point
        LOCAL info := SELF:GridViewVoyages:CalcHitInfo(oPoint) AS DevExpress.XtraGrid.Views.Grid.ViewInfo.GridHitInfo
        IF info:InRow .OR. info:InRowCell
            IF SELF:GridViewVoyages:IsGroupRow(info:RowHandle)
                RETURN
            ENDIF

            // Get GridRow data into a DataRowView object
            LOCAL oRow AS DataRowView
            oRow:=(DataRowView)SELF:GridViewVoyages:GetRow(info:RowHandle)

            IF info:Column <> NULL
                // Set focused Row/Column (for DoubleClick event)
                //SELF:GridViewVoyages:FocusedRowHandle := info:RowHandle
                //SELF:GridViewVoyages:FocusedColumn := info:Column

                SELF:Voyages_Edit(oRow, info:Column)
            ENDIF
        ENDIF
        RETURN
PRIVATE METHOD GridViewVoyages_FocusedColumnChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.FocusedColumnChangedEventArgs ) AS System.Void
        SELF:SetEditModeOff_Common(SELF:GridViewVoyages)
        RETURN
PRIVATE METHOD GridViewVoyages_FocusedRowChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventArgs ) AS System.Void
        SELF:SetEditModeOff_Common(SELF:GridViewVoyages)
        SELF:FocusedRowChanged_Voyages(e)
        RETURN

// GridViewRoutings
PRIVATE METHOD GridViewRoutings_BeforeLeaveRow( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.Void
        SELF:BeforeLeaveRow_Routings(e)
        RETURN
PRIVATE METHOD GridViewRoutings_CellValueChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
        LOCAL oView:=(GridView)SELF:GridVoyages:FocusedView AS GridView
        IF oView == NULL
            RETURN
        ENDIF

        IF SELF:LBSuggest:Visible
            RETURN
        ENDIF

        IF SELF:VoyageRouting_Save(e, oView)
            SELF:SetEditModeOff_Common(oView)
        ENDIF
        RETURN
PRIVATE METHOD GridViewRoutings_CellValueChanging( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
        DO CASE
        CASE e:Column:FieldName == "uCondition"
            SELF:cCondition := e:Value:ToString()

        CASE InListExact(e:Column:FieldName, "PortFrom", "PortTo")
            // LBSuggest
            oMainForm:cLBSuggest_TypedChars := e:Value:ToString()
//            SELF:cLBSuggest_TypedChars := e:Value:ToString()

        CASE e:Column:FieldName == "uPortFromGMT_DIFF"
            SELF:cPortFromGMT_DIFF := e:Value:ToString()

        CASE e:Column:FieldName == "uPortToGMT_DIFF"
            SELF:cPortToGMT_DIFF := e:Value:ToString()
        ENDCASE
        RETURN
PRIVATE METHOD GridViewRoutings_CustomUnboundColumnData( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs ) AS System.Void
        SELF:CustomUnboundColumnData_Routings(e)
        RETURN
PRIVATE METHOD GridViewRoutings_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        LOCAL oView:=(GridView)SELF:GridVoyages:FocusedView AS GridView
        IF oView == NULL
            RETURN
        ENDIF
        LOCAL oPoint := oView:GridControl:PointToClient(Control.MousePosition) AS Point
        LOCAL info := oView:CalcHitInfo(oPoint) AS DevExpress.XtraGrid.Views.Grid.ViewInfo.GridHitInfo
        IF info:InRow .OR. info:InRowCell
            IF oView:IsGroupRow(info:RowHandle)
                RETURN
            ENDIF

            // Get GridRow data into a DataRowView object
            LOCAL oRow AS DataRowView
            oRow:=(DataRowView)oView:GetRow(info:RowHandle)

            IF info:Column <> NULL
                // Set focused Row/Column (for DoubleClick event)
                //oView:FocusedRowHandle := info:RowHandle
                //oView:FocusedColumn := info:Column

                SELF:VoyageRouting_Edit(oRow, info:Column, oView)
            ENDIF
        ENDIF
        RETURN
PRIVATE METHOD GridViewRoutings_FocusedColumnChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.FocusedColumnChangedEventArgs ) AS System.Void
        LOCAL oView:=(GridView)SELF:GridVoyages:FocusedView AS GridView
        IF oView == NULL
            RETURN
        ENDIF
        SELF:SetEditModeOff_Common(oView)
        RETURN
PRIVATE METHOD GridViewRoutings_FocusedRowChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventArgs ) AS System.Void
        LOCAL oView:=(GridView)SELF:GridVoyages:FocusedView AS GridView
        IF oView == NULL
            RETURN
        ENDIF
        SELF:SetEditModeOff_Common(oView)
        SELF:FocusedRowChanged_Routings(e, oView)
        RETURN
PRIVATE METHOD GridViewRoutings_GotFocus( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:Change_BarSetup_ToolTips_Routings()
        RETURN
PRIVATE METHOD GridViewRoutings_LostFocus( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:Change_BarSetup_ToolTips_Voyages()
        RETURN
PRIVATE METHOD GridViewRoutings_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
            LOCAL oView:=(GridView)SELF:GridVoyages:FocusedView AS GridView
            IF oView == NULL
                RETURN
            ENDIF
            //SELF:FocusedRowChanged_Routings(e, oView)
            SELF:click_Routings()
        RETURN
PRIVATE METHOD barButtonItem1_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        IF SELF:GridVoyages:FocusedView == SELF:GridViewVoyages
            SELF:open_Voyage_Attachments()
        ELSE
            SELF:open_Routing_Attachments()
        ENDIF
    RETURN
PRIVATE METHOD open_Voyage_Attachments() AS VOID
        
    RETURN
PRIVATE METHOD open_Routing_Attachments() AS VOID
        
    RETURN
PRIVATE METHOD BBIMWA_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        IF SELF:GridVoyages:FocusedView == SELF:GridViewVoyages
            RETURN
        ELSE    
        
            SELF:showMatchForm("A")
        ENDIF
RETURN
PRIVATE METHOD BBIMWD_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        IF SELF:GridVoyages:FocusedView == SELF:GridViewVoyages
            RETURN
        ELSE    
            SELF:showMatchForm("D")
        ENDIF
RETURN
PRIVATE METHOD bbiMRVVoyageReport_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void

        SELF:bbiMRVVoyageReportItemClick()        

    RETURN
PRIVATE METHOD BBICreateFolders_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    SELF:CreateFolders()
    RETURN

END CLASS 
