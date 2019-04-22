#Using System.Windows.Forms
#Using System.Data
#Using System.Drawing
#Using DevExpress.XtraBars
#Using DevExpress.XtraGrid.Views.Grid
#Using DevExpress.XtraGrid.Views.Grid.ViewInfo
PARTIAL CLASS ListsForm INHERIT DevExpress.XtraEditors.XtraForm
    PRIVATE barManager_Flow AS DevExpress.XtraBars.BarManager
    PRIVATE bar2 AS DevExpress.XtraBars.Bar
    PRIVATE barDockControlTop AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlBottom AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlLeft AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlRight AS DevExpress.XtraBars.BarDockControl
    PRIVATE bar1 AS DevExpress.XtraBars.Bar
    PRIVATE splitContainerControl_Horizontal AS DevExpress.XtraEditors.SplitContainerControl
    PRIVATE splitContainerControl_Vertical AS DevExpress.XtraEditors.SplitContainerControl
    PRIVATE bar3 AS DevExpress.XtraBars.Bar
    PRIVATE standaloneBarDockControl_Links AS DevExpress.XtraBars.StandaloneBarDockControl
    PRIVATE standaloneBarDockControl_Flows AS DevExpress.XtraBars.StandaloneBarDockControl
    PRIVATE GridLists AS DevExpress.XtraGrid.GridControl
    PRIVATE gridviewlists AS DevExpress.XtraGrid.Views.Grid.GridView
    PRIVATE GridStates AS DevExpress.XtraGrid.GridControl
    PRIVATE gridviewlistitems AS DevExpress.XtraGrid.Views.Grid.GridView
    PRIVATE BBINew AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIEdit AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIDelete AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIRefresh AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIPrint AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBINew_States AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIEdit_States AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIDelete_States AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIRefresh_States AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIPrint_States AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIHelp_States AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIClose_States AS DevExpress.XtraBars.BarButtonItem
    PRIVATE bbiLoadExcel AS DevExpress.XtraBars.BarButtonItem
    /// <summary>
    /// Required designer variable.
    /// </summary>
    PRIVATE components AS System.ComponentModel.IContainer
    CONSTRUCTOR()
      SUPER()
      SELF:InitializeComponent()
      RETURN
    
   /// <summary>
   /// Clean up any resources being used.
   /// </summary>
   /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
    PROTECTED VIRTUAL METHOD Dispose( disposing AS System.Boolean ) AS System.Void
      IF disposing && components != NULL
         components:Dispose()
      ENDIF
      SUPER:Dispose( disposing )
      RETURN
    
   /// <summary>
   /// Required method for Designer support - do not modify
   /// the contents of this method with the code editor.
   /// </summary>
    PRIVATE METHOD InitializeComponent() AS System.Void
        SELF:components := System.ComponentModel.Container{}
        LOCAL superToolTip11 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem11 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem10 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip12 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem12 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem11 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip13 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem13 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem12 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip14 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem14 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL superToolTip15 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem15 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem13 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip16 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem16 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem14 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip17 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem17 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem15 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip18 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem18 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem16 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip19 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem19 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem17 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip20 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem20 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem18 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL gridLevelNode3 := DevExpress.XtraGrid.GridLevelNode{} AS DevExpress.XtraGrid.GridLevelNode
        LOCAL gridLevelNode1 := DevExpress.XtraGrid.GridLevelNode{} AS DevExpress.XtraGrid.GridLevelNode
        SELF:barManager_Flow := DevExpress.XtraBars.BarManager{SELF:components}
        SELF:bar1 := DevExpress.XtraBars.Bar{}
        SELF:bar2 := DevExpress.XtraBars.Bar{}
        SELF:BBINew := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIEdit := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIDelete := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIRefresh := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIPrint := DevExpress.XtraBars.BarButtonItem{}
        SELF:standaloneBarDockControl_Links := DevExpress.XtraBars.StandaloneBarDockControl{}
        SELF:bar3 := DevExpress.XtraBars.Bar{}
        SELF:BBINew_States := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIEdit_States := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIDelete_States := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIRefresh_States := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIPrint_States := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIHelp_States := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIClose_States := DevExpress.XtraBars.BarButtonItem{}
        SELF:standaloneBarDockControl_Flows := DevExpress.XtraBars.StandaloneBarDockControl{}
        SELF:barDockControlTop := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlBottom := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlLeft := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlRight := DevExpress.XtraBars.BarDockControl{}
        SELF:splitContainerControl_Horizontal := DevExpress.XtraEditors.SplitContainerControl{}
        SELF:splitContainerControl_Vertical := DevExpress.XtraEditors.SplitContainerControl{}
        SELF:GridLists := DevExpress.XtraGrid.GridControl{}
        SELF:gridviewlists := DevExpress.XtraGrid.Views.Grid.GridView{}
        SELF:GridStates := DevExpress.XtraGrid.GridControl{}
        SELF:gridviewlistitems := DevExpress.XtraGrid.Views.Grid.GridView{}
        SELF:bbiLoadExcel := DevExpress.XtraBars.BarButtonItem{}
        ((System.ComponentModel.ISupportInitialize)(SELF:barManager_Flow)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl_Horizontal)):BeginInit()
        SELF:splitContainerControl_Horizontal:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl_Vertical)):BeginInit()
        SELF:splitContainerControl_Vertical:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:GridLists)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridviewlists)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:GridStates)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridviewlistitems)):BeginInit()
        SELF:SuspendLayout()
        SELF:barManager_Flow:Bars:AddRange(<DevExpress.XtraBars.Bar>{ SELF:bar1, SELF:bar2, SELF:bar3 })
        SELF:barManager_Flow:DockControls:Add(SELF:barDockControlTop)
        SELF:barManager_Flow:DockControls:Add(SELF:barDockControlBottom)
        SELF:barManager_Flow:DockControls:Add(SELF:barDockControlLeft)
        SELF:barManager_Flow:DockControls:Add(SELF:barDockControlRight)
        SELF:barManager_Flow:DockControls:Add(SELF:standaloneBarDockControl_Links)
        SELF:barManager_Flow:DockControls:Add(SELF:standaloneBarDockControl_Flows)
        SELF:barManager_Flow:Form := SELF
        SELF:barManager_Flow:Items:AddRange(<DevExpress.XtraBars.BarItem>{ SELF:BBINew, SELF:BBIEdit, SELF:BBIDelete, SELF:BBIRefresh, SELF:BBIPrint, SELF:BBINew_States, SELF:BBIEdit_States, SELF:BBIDelete_States, SELF:BBIRefresh_States, SELF:BBIPrint_States, SELF:BBIHelp_States, SELF:BBIClose_States, SELF:bbiLoadExcel })
        SELF:barManager_Flow:MainMenu := SELF:bar2
        SELF:barManager_Flow:MaxItemId := 13
        SELF:barManager_Flow:StatusBar := SELF:bar1
        SELF:bar1:BarName := "Status bar"
        SELF:bar1:CanDockStyle := DevExpress.XtraBars.BarCanDockStyle.Bottom
        SELF:bar1:DockCol := 0
        SELF:bar1:DockRow := 0
        SELF:bar1:DockStyle := DevExpress.XtraBars.BarDockStyle.Bottom
        SELF:bar1:OptionsBar:AllowQuickCustomization := FALSE
        SELF:bar1:OptionsBar:DrawDragBorder := FALSE
        SELF:bar1:OptionsBar:UseWholeRow := TRUE
        SELF:bar1:Text := "Status bar"
        SELF:bar2:BarName := "Main menu"
        SELF:bar2:DockCol := 0
        SELF:bar2:DockRow := 0
        SELF:bar2:DockStyle := DevExpress.XtraBars.BarDockStyle.Standalone
        SELF:bar2:FloatLocation := System.Drawing.Point{368, 192}
        SELF:bar2:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:BBINew}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIEdit}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIDelete}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIRefresh}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIPrint} })
        SELF:bar2:OptionsBar:MultiLine := TRUE
        SELF:bar2:OptionsBar:UseWholeRow := TRUE
        SELF:bar2:StandaloneBarDockControl := SELF:standaloneBarDockControl_Links
        SELF:bar2:Text := "Main menu"
        SELF:BBINew:Caption := "New"
        SELF:BBINew:Id := 0
        SELF:BBINew:Name := "BBINew"
        toolTipTitleItem11:Text := "New"
        toolTipItem10:LeftIndent := 6
        toolTipItem10:Text := "Add new Document Flow"
        superToolTip11:Items:Add(toolTipTitleItem11)
        superToolTip11:Items:Add(toolTipItem10)
        SELF:BBINew:SuperTip := superToolTip11
        SELF:BBINew:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBINew_ItemClick() }
        SELF:BBIEdit:Caption := "Edit"
        SELF:BBIEdit:Id := 1
        SELF:BBIEdit:Name := "BBIEdit"
        toolTipTitleItem12:Text := "Edit"
        toolTipItem11:LeftIndent := 6
        toolTipItem11:Text := "Edit Document Flow"
        superToolTip12:Items:Add(toolTipTitleItem12)
        superToolTip12:Items:Add(toolTipItem11)
        SELF:BBIEdit:SuperTip := superToolTip12
        SELF:BBIEdit:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIEdit_ItemClick() }
        SELF:BBIDelete:Caption := "Delete"
        SELF:BBIDelete:Id := 2
        SELF:BBIDelete:Name := "BBIDelete"
        toolTipTitleItem13:Text := "Delete"
        toolTipItem12:LeftIndent := 6
        toolTipItem12:Text := "Delete Document Flow"
        superToolTip13:Items:Add(toolTipTitleItem13)
        superToolTip13:Items:Add(toolTipItem12)
        SELF:BBIDelete:SuperTip := superToolTip13
        SELF:BBIDelete:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIDelete_ItemClick() }
        SELF:BBIRefresh:Caption := "Refresh"
        SELF:BBIRefresh:Id := 3
        SELF:BBIRefresh:Name := "BBIRefresh"
        toolTipTitleItem14:Text := "Refresh"
        superToolTip14:Items:Add(toolTipTitleItem14)
        SELF:BBIRefresh:SuperTip := superToolTip14
        SELF:BBIRefresh:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIRefresh_ItemClick() }
        SELF:BBIPrint:Caption := "Print"
        SELF:BBIPrint:Id := 4
        SELF:BBIPrint:Name := "BBIPrint"
        toolTipTitleItem15:Text := "Print"
        toolTipItem13:LeftIndent := 6
        toolTipItem13:Text := "Print Document Flows"
        superToolTip15:Items:Add(toolTipTitleItem15)
        superToolTip15:Items:Add(toolTipItem13)
        SELF:BBIPrint:SuperTip := superToolTip15
        SELF:BBIPrint:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIPrint_ItemClick() }
        SELF:standaloneBarDockControl_Links:CausesValidation := FALSE
        SELF:standaloneBarDockControl_Links:Dock := System.Windows.Forms.DockStyle.Top
        SELF:standaloneBarDockControl_Links:Location := System.Drawing.Point{0, 0}
        SELF:standaloneBarDockControl_Links:Name := "standaloneBarDockControl_Links"
        SELF:standaloneBarDockControl_Links:Size := System.Drawing.Size{185, 25}
        SELF:standaloneBarDockControl_Links:Text := "standaloneBarDockControl1"
        SELF:bar3:BarName := "Main menu"
        SELF:bar3:DockCol := 0
        SELF:bar3:DockRow := 0
        SELF:bar3:DockStyle := DevExpress.XtraBars.BarDockStyle.Standalone
        SELF:bar3:FloatLocation := System.Drawing.Point{368, 192}
        SELF:bar3:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:BBINew_States}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIEdit_States}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIDelete_States}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIRefresh_States}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIPrint_States}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIHelp_States}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIClose_States}, DevExpress.XtraBars.LinkPersistInfo{SELF:bbiLoadExcel} })
        SELF:bar3:OptionsBar:MultiLine := TRUE
        SELF:bar3:OptionsBar:UseWholeRow := TRUE
        SELF:bar3:StandaloneBarDockControl := SELF:standaloneBarDockControl_Flows
        SELF:bar3:Text := "Main menu"
        SELF:BBINew_States:Caption := "New"
        SELF:BBINew_States:Id := 5
        SELF:BBINew_States:ItemShortcut := DevExpress.XtraBars.BarShortcut{(System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.N)}
        SELF:BBINew_States:Name := "BBINew_States"
        toolTipTitleItem16:Text := "New"
        toolTipItem14:LeftIndent := 6
        toolTipItem14:Text := "Add new State"
        superToolTip16:Items:Add(toolTipTitleItem16)
        superToolTip16:Items:Add(toolTipItem14)
        SELF:BBINew_States:SuperTip := superToolTip16
        SELF:BBINew_States:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBINew_States_ItemClick() }
        SELF:BBIEdit_States:Caption := "Edit"
        SELF:BBIEdit_States:Id := 6
        SELF:BBIEdit_States:ItemShortcut := DevExpress.XtraBars.BarShortcut{System.Windows.Forms.Keys.F2}
        SELF:BBIEdit_States:Name := "BBIEdit_States"
        toolTipTitleItem17:Text := "Edit (F2)"
        toolTipItem15:LeftIndent := 6
        toolTipItem15:Text := "Edit State"
        superToolTip17:Items:Add(toolTipTitleItem17)
        superToolTip17:Items:Add(toolTipItem15)
        SELF:BBIEdit_States:SuperTip := superToolTip17
        SELF:BBIEdit_States:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIEdit_States_ItemClick() }
        SELF:BBIDelete_States:Caption := "Delete"
        SELF:BBIDelete_States:Id := 7
        SELF:BBIDelete_States:Name := "BBIDelete_States"
        toolTipTitleItem18:Text := "Delete"
        toolTipItem16:LeftIndent := 6
        toolTipItem16:Text := "Delete State"
        superToolTip18:Items:Add(toolTipTitleItem18)
        superToolTip18:Items:Add(toolTipItem16)
        SELF:BBIDelete_States:SuperTip := superToolTip18
        SELF:BBIDelete_States:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIDelete_States_ItemClick() }
        SELF:BBIRefresh_States:Caption := "Refresh"
        SELF:BBIRefresh_States:Id := 8
        SELF:BBIRefresh_States:Name := "BBIRefresh_States"
        SELF:BBIRefresh_States:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIRefresh_States_ItemClick() }
        SELF:BBIPrint_States:Caption := "Print"
        SELF:BBIPrint_States:Id := 9
        SELF:BBIPrint_States:ItemShortcut := DevExpress.XtraBars.BarShortcut{(System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.P)}
        SELF:BBIPrint_States:Name := "BBIPrint_States"
        SELF:BBIPrint_States:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIPrint_States_ItemClick() }
        SELF:BBIHelp_States:Caption := "Help"
        SELF:BBIHelp_States:Id := 10
        SELF:BBIHelp_States:Name := "BBIHelp_States"
        toolTipTitleItem19:Text := "About Document Flow Controls"
        toolTipItem17:LeftIndent := 6
        superToolTip19:Items:Add(toolTipTitleItem19)
        superToolTip19:Items:Add(toolTipItem17)
        SELF:BBIHelp_States:SuperTip := superToolTip19
        SELF:BBIHelp_States:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIHelp_States_ItemClick() }
        SELF:BBIClose_States:Caption := "Close"
        SELF:BBIClose_States:Id := 11
        SELF:BBIClose_States:ItemShortcut := DevExpress.XtraBars.BarShortcut{(System.Windows.Forms.Keys.Alt | System.Windows.Forms.Keys.F4)}
        SELF:BBIClose_States:Name := "BBIClose_States"
        toolTipTitleItem20:Text := "Close"
        toolTipItem18:LeftIndent := 6
        toolTipItem18:Text := "Close Flow Control Form"
        superToolTip20:Items:Add(toolTipTitleItem20)
        superToolTip20:Items:Add(toolTipItem18)
        SELF:BBIClose_States:SuperTip := superToolTip20
        SELF:BBIClose_States:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIClose_States_ItemClick() }
        SELF:standaloneBarDockControl_Flows:CausesValidation := FALSE
        SELF:standaloneBarDockControl_Flows:Dock := System.Windows.Forms.DockStyle.Top
        SELF:standaloneBarDockControl_Flows:Location := System.Drawing.Point{0, 0}
        SELF:standaloneBarDockControl_Flows:Name := "standaloneBarDockControl_Flows"
        SELF:standaloneBarDockControl_Flows:Size := System.Drawing.Size{891, 25}
        SELF:standaloneBarDockControl_Flows:Text := "standaloneBarDockControl1"
        SELF:barDockControlTop:CausesValidation := FALSE
        SELF:barDockControlTop:Dock := System.Windows.Forms.DockStyle.Top
        SELF:barDockControlTop:Location := System.Drawing.Point{0, 0}
        SELF:barDockControlTop:Size := System.Drawing.Size{1081, 0}
        SELF:barDockControlBottom:CausesValidation := FALSE
        SELF:barDockControlBottom:Dock := System.Windows.Forms.DockStyle.Bottom
        SELF:barDockControlBottom:Location := System.Drawing.Point{0, 655}
        SELF:barDockControlBottom:Size := System.Drawing.Size{1081, 23}
        SELF:barDockControlLeft:CausesValidation := FALSE
        SELF:barDockControlLeft:Dock := System.Windows.Forms.DockStyle.Left
        SELF:barDockControlLeft:Location := System.Drawing.Point{0, 0}
        SELF:barDockControlLeft:Size := System.Drawing.Size{0, 655}
        SELF:barDockControlRight:CausesValidation := FALSE
        SELF:barDockControlRight:Dock := System.Windows.Forms.DockStyle.Right
        SELF:barDockControlRight:Location := System.Drawing.Point{1081, 0}
        SELF:barDockControlRight:Size := System.Drawing.Size{0, 655}
        SELF:splitContainerControl_Horizontal:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:splitContainerControl_Horizontal:FixedPanel := DevExpress.XtraEditors.SplitFixedPanel.Panel2
        SELF:splitContainerControl_Horizontal:Horizontal := FALSE
        SELF:splitContainerControl_Horizontal:Location := System.Drawing.Point{0, 0}
        SELF:splitContainerControl_Horizontal:Name := "splitContainerControl_Horizontal"
        SELF:splitContainerControl_Horizontal:Panel1:Controls:Add(SELF:splitContainerControl_Vertical)
        SELF:splitContainerControl_Horizontal:Panel1:Text := "Panel1"
        SELF:splitContainerControl_Horizontal:Panel2:MinSize := 184
        SELF:splitContainerControl_Horizontal:Panel2:Text := "Panel2"
        SELF:splitContainerControl_Horizontal:PanelVisibility := DevExpress.XtraEditors.SplitPanelVisibility.Panel1
        SELF:splitContainerControl_Horizontal:Size := System.Drawing.Size{1081, 655}
        SELF:splitContainerControl_Horizontal:SplitterPosition := 184
        SELF:splitContainerControl_Horizontal:TabIndex := 4
        SELF:splitContainerControl_Horizontal:Text := "splitContainerControl1"
        SELF:splitContainerControl_Vertical:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:splitContainerControl_Vertical:Location := System.Drawing.Point{0, 0}
        SELF:splitContainerControl_Vertical:Name := "splitContainerControl_Vertical"
        SELF:splitContainerControl_Vertical:Panel1:Controls:Add(SELF:GridLists)
        SELF:splitContainerControl_Vertical:Panel1:Controls:Add(SELF:standaloneBarDockControl_Links)
        SELF:splitContainerControl_Vertical:Panel1:Text := "Panel1"
        SELF:splitContainerControl_Vertical:Panel2:Controls:Add(SELF:GridStates)
        SELF:splitContainerControl_Vertical:Panel2:Controls:Add(SELF:standaloneBarDockControl_Flows)
        SELF:splitContainerControl_Vertical:Panel2:Text := "Panel2"
        SELF:splitContainerControl_Vertical:Size := System.Drawing.Size{1081, 655}
        SELF:splitContainerControl_Vertical:SplitterPosition := 185
        SELF:splitContainerControl_Vertical:TabIndex := 0
        SELF:splitContainerControl_Vertical:Text := "splitContainerControl2"
        SELF:GridLists:Dock := System.Windows.Forms.DockStyle.Fill
        gridLevelNode3:RelationName := "Level1"
        SELF:GridLists:LevelTree:Nodes:AddRange(<DevExpress.XtraGrid.GridLevelNode>{ gridLevelNode3 })
        SELF:GridLists:Location := System.Drawing.Point{0, 25}
        SELF:GridLists:MainView := SELF:gridviewlists
        SELF:GridLists:Name := "GridLists"
        SELF:GridLists:Size := System.Drawing.Size{185, 630}
        SELF:GridLists:TabIndex := 76
        SELF:GridLists:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:gridviewlists })
        SELF:GridLists:KeyPress += System.Windows.Forms.KeyPressEventHandler{ SELF, @GridLists_KeyPress() }
        SELF:gridviewlists:GridControl := SELF:GridLists
        SELF:gridviewlists:Name := "gridviewlists"
        SELF:gridviewlists:FocusedRowChanged += DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventHandler{ SELF, @gridviewlists_FocusedRowChanged() }
        SELF:gridviewlists:FocusedColumnChanged += DevExpress.XtraGrid.Views.Base.FocusedColumnChangedEventHandler{ SELF, @gridviewlists_FocusedColumnChanged() }
        SELF:gridviewlists:CellValueChanged += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @gridviewlists_CellValueChanged() }
        SELF:gridviewlists:BeforeLeaveRow += DevExpress.XtraGrid.Views.Base.RowAllowEventHandler{ SELF, @gridviewlists_BeforeLeaveRow() }
        SELF:gridviewlists:DoubleClick += System.EventHandler{ SELF, @gridviewlists_DoubleClick() }
        SELF:GridStates:Dock := System.Windows.Forms.DockStyle.Fill
        gridLevelNode1:RelationName := "Level1"
        SELF:GridStates:LevelTree:Nodes:AddRange(<DevExpress.XtraGrid.GridLevelNode>{ gridLevelNode1 })
        SELF:GridStates:Location := System.Drawing.Point{0, 25}
        SELF:GridStates:MainView := SELF:gridviewlistitems
        SELF:GridStates:Name := "GridStates"
        SELF:GridStates:Size := System.Drawing.Size{891, 630}
        SELF:GridStates:TabIndex := 76
        SELF:GridStates:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:gridviewlistitems })
        SELF:GridStates:KeyPress += System.Windows.Forms.KeyPressEventHandler{ SELF, @GridStates_KeyPress() }
        SELF:gridviewlistitems:GridControl := SELF:GridStates
        SELF:gridviewlistitems:Name := "gridviewlistitems"
        SELF:gridviewlistitems:OptionsSelection:EnableAppearanceHideSelection := FALSE
        SELF:gridviewlistitems:OptionsSelection:InvertSelection := TRUE
        SELF:gridviewlistitems:RowStyle += DevExpress.XtraGrid.Views.Grid.RowStyleEventHandler{ SELF, @gridviewlistitems_RowStyle() }
        SELF:gridviewlistitems:FocusedRowChanged += DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventHandler{ SELF, @gridviewlistitems_FocusedRowChanged() }
        SELF:gridviewlistitems:FocusedColumnChanged += DevExpress.XtraGrid.Views.Base.FocusedColumnChangedEventHandler{ SELF, @gridviewlistitems_FocusedColumnChanged() }
        SELF:gridviewlistitems:CellValueChanged += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @gridviewlistitems_CellValueChanged() }
        SELF:gridviewlistitems:BeforeLeaveRow += DevExpress.XtraGrid.Views.Base.RowAllowEventHandler{ SELF, @gridviewlistitems_BeforeLeaveRow() }
        SELF:gridviewlistitems:DoubleClick += System.EventHandler{ SELF, @gridviewlistitems_DoubleClick() }
        SELF:bbiLoadExcel:Caption := "Load Excel File"
        SELF:bbiLoadExcel:Id := 12
        SELF:bbiLoadExcel:Name := "bbiLoadExcel"
        SELF:bbiLoadExcel:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @bbiLoadExcel_ItemClick() }
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single)(6)), ((Single)(13))}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{1081, 678}
        SELF:Controls:Add(SELF:splitContainerControl_Horizontal)
        SELF:Controls:Add(SELF:barDockControlLeft)
        SELF:Controls:Add(SELF:barDockControlRight)
        SELF:Controls:Add(SELF:barDockControlBottom)
        SELF:Controls:Add(SELF:barDockControlTop)
        SELF:Name := "ListsForm"
        SELF:Text := "List Form"
        SELF:Activated += System.EventHandler{ SELF, @ListsForm_Activated() }
        SELF:FormClosing += System.Windows.Forms.FormClosingEventHandler{ SELF, @ListsForm_FormClosing() }
        SELF:FormClosed += System.Windows.Forms.FormClosedEventHandler{ SELF, @ListsForm_FormClosed() }
        SELF:Load += System.EventHandler{ SELF, @ListsForm_Load() }
        ((System.ComponentModel.ISupportInitialize)(SELF:barManager_Flow)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl_Horizontal)):EndInit()
        SELF:splitContainerControl_Horizontal:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl_Vertical)):EndInit()
        SELF:splitContainerControl_Vertical:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:GridLists)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridviewlists)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:GridStates)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridviewlistitems)):EndInit()
        SELF:ResumeLayout(FALSE)
        SELF:PerformLayout()
    PRIVATE METHOD ListsForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		Self:ListsForm_OnLoad()
        RETURN
    
    PRIVATE METHOD ListsForm_FormClosing( sender AS System.Object, e AS System.Windows.Forms.FormClosingEventArgs ) AS System.Void
		
        RETURN
    
    PRIVATE METHOD ListsForm_FormClosed( sender AS System.Object, e AS System.Windows.Forms.FormClosedEventArgs ) AS System.Void
			
        RETURN

// FlowControls events
    PRIVATE METHOD gridviewlists_BeforeLeaveRow( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.Void
		Self:BeforeLeaveRow_Flows(e)
        RETURN
    
    PRIVATE METHOD gridviewlists_CellValueChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
		Self:SetEditModeOff_Flows()
		Self:Flows_Save(e)
        RETURN
    
    PRIVATE METHOD gridviewlists_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		Local oPoint := Self:gridviewlists:GridControl:PointToClient(Control.MousePosition) as Point
		Local info := Self:gridviewlists:CalcHitInfo(oPoint) as DevExpress.XtraGrid.Views.Grid.ViewInfo.GridHitInfo
		if info:InRow .or. info:InRowCell
			if Self:gridviewlists:IsGroupRow(info:RowHandle)
				Return
			endif

			// Get GridRow data into a DataRowView object
			Local oRow as DataRowView
			oRow:=(DataRowView)Self:gridviewlists:GetRow(info:RowHandle)

			if info:Column <> NULL
				// Set focused Row/Column (for DoubleClick event)
				//SELF:gridviewlists:FocusedRowHandle := info:RowHandle
				//SELF:gridviewlists:FocusedColumn := info:Column

				Self:Flows_Edit(oRow, info:Column)
			endif
		endif
        RETURN
    
    PRIVATE METHOD gridviewlists_FocusedColumnChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.FocusedColumnChangedEventArgs ) AS System.Void
		Self:SetEditModeOff_Flows()
        RETURN
    
    PRIVATE METHOD gridviewlists_FocusedRowChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventArgs ) AS System.Void
		Self:FocusedRowChanged_Flows(e)
        RETURN

  //  PRIVATE METHOD gridviewlists_CustomUnboundColumnData( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs ) AS System.Void
		//Self:CustomUnboundColumnData_Flows(e)
  //      RETURN

    PRIVATE METHOD BBINew_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		if QuestionBox("Do you want to create a new Document Flow ?", ;
						"Add new") <> System.Windows.Forms.DialogResult.Yes
			Return
		endif
		Self:Flows_Add()
        RETURN
    
    PRIVATE METHOD BBIEdit_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		// Get GridRow data into a DataRowView object
		Local oRow as DataRowView
		oRow := (DataRowView)Self:gridviewlists:GetFocusedRow()
		Self:Flows_Edit(oRow, Self:gridviewlists:FocusedColumn)
        RETURN
    
    PRIVATE METHOD BBIDelete_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		Self:Flows_Delete()
        RETURN
    
    PRIVATE METHOD BBIRefresh_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		Self:Flows_Refresh()
        RETURN
    
    PRIVATE METHOD BBIPrint_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		Self:Flows_Print()
        RETURN
    
// States events
    PRIVATE METHOD gridviewlistitems_BeforeLeaveRow( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.Void
		Self:BeforeLeaveRow_States(e)
        RETURN
    
    PRIVATE METHOD gridviewlistitems_CellValueChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
		Self:SetEditModeOff_States()
		Self:States_Save(e)
        RETURN
    
    PRIVATE METHOD gridviewlistitems_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		Local oPoint := Self:gridviewlistitems:GridControl:PointToClient(Control.MousePosition) as Point
		Local info := Self:gridviewlistitems:CalcHitInfo(oPoint) as DevExpress.XtraGrid.Views.Grid.ViewInfo.GridHitInfo
		if info:InRow .or. info:InRowCell
			if Self:gridviewlistitems:IsGroupRow(info:RowHandle)
				Return
			endif

			// Get GridRow data into a DataRowView object
			Local oRow as DataRowView
			oRow:=(DataRowView)Self:gridviewlistitems:GetRow(info:RowHandle)

			if info:Column <> NULL
				// Set focused Row/Column (for DoubleClick event)
				//SELF:gridviewlistitems:FocusedRowHandle := info:RowHandle
				//SELF:gridviewlistitems:FocusedColumn := info:Column

				Self:States_Edit(oRow, info:Column)
			endif
		endif
        RETURN
    
    PRIVATE METHOD gridviewlistitems_FocusedColumnChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.FocusedColumnChangedEventArgs ) AS System.Void
		Self:SetEditModeOff_States()
        RETURN
    
    PRIVATE METHOD gridviewlistitems_FocusedRowChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventArgs ) AS System.Void
		Self:FocusedRowChanged_States(e)
        RETURN

  //  PRIVATE METHOD gridviewlistitems_CustomUnboundColumnData( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs ) AS System.Void
		//Self:CustomUnboundColumnData_States(e)
  //      RETURN

    PRIVATE METHOD BBINew_States_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		// Check if StateNo=0 has a DMF Folder
		Local oRow as DataRowView
		oRow:=(DataRowView)Self:gridviewlistitems:GetRow(0)
		if oRow <> NULL .and. ! Self:ValidateStates(oRow)
			Return
		endif

		if QuestionBox("Do you want to create a new List Item ?", ;
						"Add new") <> System.Windows.Forms.DialogResult.Yes
			Return
		endif
		Self:States_Add()
        RETURN
    
    PRIVATE METHOD BBIEdit_States_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		// Get GridRow data into a DataRowView object
		Local oRow as DataRowView
		oRow := (DataRowView)Self:gridviewlistitems:GetFocusedRow()
		Self:States_Edit(oRow, Self:gridviewlistitems:FocusedColumn)
        RETURN
    
    PRIVATE METHOD BBIDelete_States_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		Self:States_Delete()
        RETURN
    
    PRIVATE METHOD BBIRefresh_States_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		Self:States_Refresh()
        RETURN
    
    PRIVATE METHOD BBIPrint_States_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		Self:States_Print()
        RETURN
    
    PRIVATE METHOD BBIHelp_States_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		Self:States_Help()
        RETURN
    
    PRIVATE METHOD BBIClose_States_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		Self:Close()
        RETURN

    PRIVATE METHOD ListsForm_Activated( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		Self:gridviewlistitems:Focus()
        RETURN

    PRIVATE METHOD ButtonSelectFolder_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		Self:SelectFolder()
        RETURN

    PRIVATE METHOD Description_Leave( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		
        RETURN

    PRIVATE METHOD SubmitFieldCondition_Leave( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	
		
        RETURN
    
    PRIVATE METHOD StateNo_Leave( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		//LOCAL oRow AS DataRowView
		//oRow:=(DataRowView)SELF:gridviewlistitems:GetFocusedRow()
        RETURN
    
    PRIVATE METHOD SubmitNo_Leave( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		//Local oRow as DataRowView
		//oRow:=(DataRowView)Self:gridviewlistitems:GetFocusedRow()
        RETURN
    
    PRIVATE METHOD RejectNo_Leave( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		
        RETURN

    PRIVATE METHOD LVUsers_ItemChecked( sender AS System.Object, e AS System.Windows.Forms.ItemCheckedEventArgs ) AS System.Void

        RETURN

    PRIVATE METHOD PrimaryUser_SelectedValueChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	
        RETURN

    PRIVATE METHOD GridLists_KeyPress( sender AS System.Object, e AS System.Windows.Forms.KeyPressEventArgs ) AS System.Void
		if e:KeyChar == Keys.Escape
			Self:Close()
		endif
        RETURN

    PRIVATE METHOD GridStates_KeyPress( sender AS System.Object, e AS System.Windows.Forms.KeyPressEventArgs ) AS System.Void
		if e:KeyChar == Keys.Escape
			Self:Close()
		endif
        RETURN

    PRIVATE METHOD gridviewlistitems_RowStyle( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Grid.RowStyleEventArgs ) AS System.Void
		//oMainForm:CustomRowStyle_Cases(Self:gridviewlistitems, e)
        RETURN
		
    PRIVATE METHOD CHBCanSubmit_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			/*LOCAL oCheck := (CheckBox)sender AS CheckBox
			LOCAL lChecked := oCheck:Checked AS LOGIC
			SELF:checkChangedStateRights(lChecked,"CanSubmit")*/
    RETURN
    PRIVATE METHOD CHBCanReject_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			/*LOCAL oCheck := (CheckBox)sender AS CheckBox
			LOCAL lChecked := oCheck:Checked AS LOGIC
			SELF:checkChangedStateRights(lChecked,"CanReject")*/
        RETURN
    PRIVATE METHOD checkBox1_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			/*LOCAL oCheck := (CheckBox)sender AS CheckBox
			LOCAL lChecked := oCheck:Checked AS LOGIC
			SELF:checkChangedStateRights(lChecked,"CanEdit")*/
		RETURN
    PRIVATE METHOD LVUsers_SelectedIndexChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:loadUserRights()
        RETURN
    PRIVATE METHOD bbiLoadExcel_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
			SELF:loadExcelFile_Method()
        RETURN

END CLASS
