USING System.Windows.Forms
USING System.Data
USING System.Drawing
USING DevExpress.XtraBars
USING DevExpress.XtraGrid.Views.Grid
USING DevExpress.XtraGrid.Views.Grid.ViewInfo
PUBLIC PARTIAL CLASS ItemsForm ;
    INHERIT DevExpress.XtraEditors.XtraForm
    PRIVATE splitContainerControl_Items AS DevExpress.XtraEditors.SplitContainerControl
    PUBLIC LBCReports AS DevExpress.XtraEditors.ListBoxControl
    PRIVATE standaloneBarDockControl_Items AS DevExpress.XtraBars.StandaloneBarDockControl
    PRIVATE barManager AS DevExpress.XtraBars.BarManager
    PRIVATE barDockControlTop AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlBottom AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlLeft AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlRight AS DevExpress.XtraBars.BarDockControl
    PRIVATE BBIAdd AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIEdit AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIDelete AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIRefresh AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIPrint AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIClose AS DevExpress.XtraBars.BarButtonItem
    PRIVATE barItems AS DevExpress.XtraBars.Bar
    PRIVATE splitContainerControl_Categories AS DevExpress.XtraEditors.SplitContainerControl
    PUBLIC LBCCategories AS DevExpress.XtraEditors.ListBoxControl
    PRIVATE standaloneBarDockControl_Categories AS DevExpress.XtraBars.StandaloneBarDockControl
    PRIVATE bar1 AS DevExpress.XtraBars.Bar
    PRIVATE BBICatAdd AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBICatEdit AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBICatDelete AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBICatRefresh AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIPreview AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIBodyIsm AS DevExpress.XtraBars.BarButtonItem
    PRIVATE tabControl1 AS System.Windows.Forms.TabControl
    PRIVATE tabPage1 AS System.Windows.Forms.TabPage
    PRIVATE tabPage2 AS System.Windows.Forms.TabPage
    PUBLIC LBCOfficeReports AS DevExpress.XtraEditors.ListBoxControl
    PRIVATE bbiExportToExcel AS DevExpress.XtraBars.BarButtonItem
    PRIVATE bbiLinkedLists AS DevExpress.XtraBars.BarButtonItem
    PRIVATE bbiComboboxColors AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBISave AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIDuplicateItems AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIAddColumn AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIShowRevisionLog AS DevExpress.XtraBars.BarButtonItem
    PRIVATE bar2 AS DevExpress.XtraBars.Bar
    PRIVATE barButtonItem1 AS DevExpress.XtraBars.BarButtonItem
    PRIVATE barButtonItem2 AS DevExpress.XtraBars.BarButtonItem
    PRIVATE standaloneBarDockControl1 AS DevExpress.XtraBars.StandaloneBarDockControl
    PRIVATE SCMain AS System.Windows.Forms.SplitContainer
    PRIVATE splitContainerControl1 AS DevExpress.XtraEditors.SplitContainerControl
    PRIVATE SCCUsers AS DevExpress.XtraEditors.SplitContainerControl
    PRIVATE LBCInGroups AS DevExpress.XtraEditors.ListBoxControl
    PRIVATE LBCOutGroups AS DevExpress.XtraEditors.ListBoxControl
    PRIVATE GridItems AS DevExpress.XtraGrid.GridControl
    PRIVATE GridViewItems AS DevExpress.XtraGrid.Views.Grid.GridView
    PRIVATE gridView1 AS DevExpress.XtraGrid.Views.Grid.GridView
    PRIVATE LBCRelated AS DevExpress.XtraEditors.ListBoxControl
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
    LOCAL resources := System.ComponentModel.ComponentResourceManager{typeof(ItemsForm)} AS System.ComponentModel.ComponentResourceManager
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
    LOCAL superToolTip7 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem7 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL toolTipItem6 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
    LOCAL superToolTip8 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem8 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL toolTipItem7 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
    LOCAL superToolTip9 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem9 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL superToolTip10 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem10 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL superToolTip11 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem11 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL superToolTip12 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem12 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    SELF:splitContainerControl_Items := DevExpress.XtraEditors.SplitContainerControl{}
    SELF:splitContainerControl_Categories := DevExpress.XtraEditors.SplitContainerControl{}
    SELF:tabControl1 := System.Windows.Forms.TabControl{}
    SELF:tabPage1 := System.Windows.Forms.TabPage{}
    SELF:LBCReports := DevExpress.XtraEditors.ListBoxControl{}
    SELF:tabPage2 := System.Windows.Forms.TabPage{}
    SELF:LBCOfficeReports := DevExpress.XtraEditors.ListBoxControl{}
    SELF:LBCCategories := DevExpress.XtraEditors.ListBoxControl{}
    SELF:standaloneBarDockControl_Categories := DevExpress.XtraBars.StandaloneBarDockControl{}
    SELF:barManager := DevExpress.XtraBars.BarManager{SELF:components}
    SELF:barItems := DevExpress.XtraBars.Bar{}
    SELF:BBIEdit := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBISave := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIAdd := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIDuplicateItems := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIAddColumn := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIDelete := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIRefresh := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIPrint := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIPreview := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIBodyIsm := DevExpress.XtraBars.BarButtonItem{}
    SELF:bbiExportToExcel := DevExpress.XtraBars.BarButtonItem{}
    SELF:bbiLinkedLists := DevExpress.XtraBars.BarButtonItem{}
    SELF:bbiComboboxColors := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIShowRevisionLog := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIClose := DevExpress.XtraBars.BarButtonItem{}
    SELF:standaloneBarDockControl_Items := DevExpress.XtraBars.StandaloneBarDockControl{}
    SELF:bar1 := DevExpress.XtraBars.Bar{}
    SELF:BBICatAdd := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBICatEdit := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBICatDelete := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBICatRefresh := DevExpress.XtraBars.BarButtonItem{}
    SELF:bar2 := DevExpress.XtraBars.Bar{}
    SELF:barButtonItem1 := DevExpress.XtraBars.BarButtonItem{}
    SELF:barButtonItem2 := DevExpress.XtraBars.BarButtonItem{}
    SELF:standaloneBarDockControl1 := DevExpress.XtraBars.StandaloneBarDockControl{}
    SELF:barDockControlTop := DevExpress.XtraBars.BarDockControl{}
    SELF:barDockControlBottom := DevExpress.XtraBars.BarDockControl{}
    SELF:barDockControlLeft := DevExpress.XtraBars.BarDockControl{}
    SELF:barDockControlRight := DevExpress.XtraBars.BarDockControl{}
    SELF:SCMain := System.Windows.Forms.SplitContainer{}
    SELF:splitContainerControl1 := DevExpress.XtraEditors.SplitContainerControl{}
    SELF:GridItems := DevExpress.XtraGrid.GridControl{}
    SELF:GridViewItems := DevExpress.XtraGrid.Views.Grid.GridView{}
    SELF:gridView1 := DevExpress.XtraGrid.Views.Grid.GridView{}
    SELF:LBCRelated := DevExpress.XtraEditors.ListBoxControl{}
    SELF:SCCUsers := DevExpress.XtraEditors.SplitContainerControl{}
    SELF:LBCInGroups := DevExpress.XtraEditors.ListBoxControl{}
    SELF:LBCOutGroups := DevExpress.XtraEditors.ListBoxControl{}
    ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl_Items)):BeginInit()
    SELF:splitContainerControl_Items:SuspendLayout()
    ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl_Categories)):BeginInit()
    SELF:splitContainerControl_Categories:SuspendLayout()
    SELF:tabControl1:SuspendLayout()
    SELF:tabPage1:SuspendLayout()
    ((System.ComponentModel.ISupportInitialize)(SELF:LBCReports)):BeginInit()
    SELF:tabPage2:SuspendLayout()
    ((System.ComponentModel.ISupportInitialize)(SELF:LBCOfficeReports)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:LBCCategories)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:barManager)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:SCMain)):BeginInit()
    SELF:SCMain:Panel1:SuspendLayout()
    SELF:SCMain:Panel2:SuspendLayout()
    SELF:SCMain:SuspendLayout()
    ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl1)):BeginInit()
    SELF:splitContainerControl1:SuspendLayout()
    ((System.ComponentModel.ISupportInitialize)(SELF:GridItems)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:GridViewItems)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:gridView1)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:LBCRelated)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:SCCUsers)):BeginInit()
    SELF:SCCUsers:SuspendLayout()
    ((System.ComponentModel.ISupportInitialize)(SELF:LBCInGroups)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:LBCOutGroups)):BeginInit()
    SELF:SuspendLayout()
    // 
    // splitContainerControl_Items
    // 
    SELF:splitContainerControl_Items:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:splitContainerControl_Items:Location := System.Drawing.Point{0, 0}
    SELF:splitContainerControl_Items:Name := "splitContainerControl_Items"
    SELF:splitContainerControl_Items:Panel1:Controls:Add(SELF:splitContainerControl_Categories)
    SELF:splitContainerControl_Items:Panel1:Text := "Panel1"
    SELF:splitContainerControl_Items:Panel2:Controls:Add(SELF:SCMain)
    SELF:splitContainerControl_Items:Panel2:Controls:Add(SELF:standaloneBarDockControl_Items)
    SELF:splitContainerControl_Items:Panel2:Text := "Panel2"
    SELF:splitContainerControl_Items:Size := System.Drawing.Size{1231, 704}
    SELF:splitContainerControl_Items:SplitterPosition := 260
    SELF:splitContainerControl_Items:TabIndex := 0
    SELF:splitContainerControl_Items:Text := "splitContainerControl1"
    // 
    // splitContainerControl_Categories
    // 
    SELF:splitContainerControl_Categories:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:splitContainerControl_Categories:Horizontal := FALSE
    SELF:splitContainerControl_Categories:Location := System.Drawing.Point{0, 0}
    SELF:splitContainerControl_Categories:Name := "splitContainerControl_Categories"
    SELF:splitContainerControl_Categories:Panel1:Controls:Add(SELF:tabControl1)
    SELF:splitContainerControl_Categories:Panel1:Text := "Panel1"
    SELF:splitContainerControl_Categories:Panel2:Controls:Add(SELF:LBCCategories)
    SELF:splitContainerControl_Categories:Panel2:Controls:Add(SELF:standaloneBarDockControl_Categories)
    SELF:splitContainerControl_Categories:Panel2:Text := "Panel2"
    SELF:splitContainerControl_Categories:Size := System.Drawing.Size{260, 704}
    SELF:splitContainerControl_Categories:SplitterPosition := 282
    SELF:splitContainerControl_Categories:TabIndex := 2
    SELF:splitContainerControl_Categories:Text := "splitContainerControl1"
    // 
    // tabControl1
    // 
    SELF:tabControl1:Controls:Add(SELF:tabPage1)
    SELF:tabControl1:Controls:Add(SELF:tabPage2)
    SELF:tabControl1:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:tabControl1:Location := System.Drawing.Point{0, 0}
    SELF:tabControl1:Name := "tabControl1"
    SELF:tabControl1:SelectedIndex := 0
    SELF:tabControl1:Size := System.Drawing.Size{260, 282}
    SELF:tabControl1:TabIndex := 0
    SELF:tabControl1:SelectedIndexChanged += System.EventHandler{ SELF, @tabControl1_SelectedIndexChanged() }
    SELF:tabControl1:Selected += System.Windows.Forms.TabControlEventHandler{ SELF, @tabControl1_Selected() }
    // 
    // tabPage1
    // 
    SELF:tabPage1:Controls:Add(SELF:LBCReports)
    SELF:tabPage1:Location := System.Drawing.Point{4, 22}
    SELF:tabPage1:Name := "tabPage1"
    SELF:tabPage1:Padding := System.Windows.Forms.Padding{3}
    SELF:tabPage1:Size := System.Drawing.Size{252, 256}
    SELF:tabPage1:TabIndex := 0
    SELF:tabPage1:Text := "Vessel"
    SELF:tabPage1:UseVisualStyleBackColor := TRUE
    SELF:tabPage1:Enter += System.EventHandler{ SELF, @tabPage1_Enter() }
    // 
    // LBCReports
    // 
    SELF:LBCReports:Appearance:Font := System.Drawing.Font{"Lucida Console", 8.25}
    SELF:LBCReports:Appearance:Options:UseFont := TRUE
    SELF:LBCReports:Cursor := System.Windows.Forms.Cursors.Default
    SELF:LBCReports:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:LBCReports:HorizontalScrollbar := TRUE
    SELF:LBCReports:Location := System.Drawing.Point{3, 3}
    SELF:LBCReports:Name := "LBCReports"
    SELF:LBCReports:Size := System.Drawing.Size{246, 250}
    SELF:LBCReports:TabIndex := 1
    SELF:LBCReports:SelectedIndexChanged += System.EventHandler{ SELF, @LBCReports_SelectedIndexChanged() }
    SELF:LBCReports:DrawItem += DevExpress.XtraEditors.ListBoxDrawItemEventHandler{ SELF, @LBCReports_DrawItem() }
    SELF:LBCReports:Enter += System.EventHandler{ SELF, @LBCReports_Enter() }
    // 
    // tabPage2
    // 
    SELF:tabPage2:Controls:Add(SELF:LBCOfficeReports)
    SELF:tabPage2:Location := System.Drawing.Point{4, 22}
    SELF:tabPage2:Name := "tabPage2"
    SELF:tabPage2:Padding := System.Windows.Forms.Padding{3}
    SELF:tabPage2:Size := System.Drawing.Size{252, 256}
    SELF:tabPage2:TabIndex := 1
    SELF:tabPage2:Text := "Office"
    SELF:tabPage2:UseVisualStyleBackColor := TRUE
    SELF:tabPage2:Enter += System.EventHandler{ SELF, @tabPage2_Enter() }
    // 
    // LBCOfficeReports
    // 
    SELF:LBCOfficeReports:Appearance:Font := System.Drawing.Font{"Lucida Console", 8.25}
    SELF:LBCOfficeReports:Appearance:Options:UseFont := TRUE
    SELF:LBCOfficeReports:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:LBCOfficeReports:HorizontalScrollbar := TRUE
    SELF:LBCOfficeReports:Location := System.Drawing.Point{3, 3}
    SELF:LBCOfficeReports:Name := "LBCOfficeReports"
    SELF:LBCOfficeReports:Size := System.Drawing.Size{246, 250}
    SELF:LBCOfficeReports:TabIndex := 2
    SELF:LBCOfficeReports:SelectedIndexChanged += System.EventHandler{ SELF, @LBCOfficeReports_SelectedIndexChanged() }
    SELF:LBCOfficeReports:Enter += System.EventHandler{ SELF, @LBCOfficeReports_Enter() }
    // 
    // LBCCategories
    // 
    SELF:LBCCategories:AllowDrop := TRUE
    SELF:LBCCategories:Appearance:Font := System.Drawing.Font{"Lucida Console", 8.25}
    SELF:LBCCategories:Appearance:Options:UseFont := TRUE
    SELF:LBCCategories:Cursor := System.Windows.Forms.Cursors.Default
    SELF:LBCCategories:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:LBCCategories:HorizontalScrollbar := TRUE
    SELF:LBCCategories:Location := System.Drawing.Point{0, 26}
    SELF:LBCCategories:Name := "LBCCategories"
    SELF:LBCCategories:Size := System.Drawing.Size{260, 391}
    SELF:LBCCategories:SortOrder := System.Windows.Forms.SortOrder.@@Ascending
    SELF:LBCCategories:TabIndex := 2
    SELF:LBCCategories:DragDrop += System.Windows.Forms.DragEventHandler{ SELF, @LBCCategories_DragDrop() }
    SELF:LBCCategories:DragOver += System.Windows.Forms.DragEventHandler{ SELF, @LBCCategories_DragOver() }
    SELF:LBCCategories:MouseDown += System.Windows.Forms.MouseEventHandler{ SELF, @LBCCategories_MouseDown() }
    SELF:LBCCategories:MouseMove += System.Windows.Forms.MouseEventHandler{ SELF, @LBCCategories_MouseMove() }
    // 
    // standaloneBarDockControl_Categories
    // 
    SELF:standaloneBarDockControl_Categories:CausesValidation := FALSE
    SELF:standaloneBarDockControl_Categories:Dock := System.Windows.Forms.DockStyle.Top
    SELF:standaloneBarDockControl_Categories:Location := System.Drawing.Point{0, 0}
    SELF:standaloneBarDockControl_Categories:Manager := SELF:barManager
    SELF:standaloneBarDockControl_Categories:Name := "standaloneBarDockControl_Categories"
    SELF:standaloneBarDockControl_Categories:Size := System.Drawing.Size{260, 26}
    SELF:standaloneBarDockControl_Categories:Text := "standaloneBarDockControl1"
    // 
    // barManager
    // 
    SELF:barManager:Bars:AddRange(<DevExpress.XtraBars.Bar>{ SELF:barItems, SELF:bar1, SELF:bar2 })
    SELF:barManager:DockControls:Add(SELF:barDockControlTop)
    SELF:barManager:DockControls:Add(SELF:barDockControlBottom)
    SELF:barManager:DockControls:Add(SELF:barDockControlLeft)
    SELF:barManager:DockControls:Add(SELF:barDockControlRight)
    SELF:barManager:DockControls:Add(SELF:standaloneBarDockControl_Items)
    SELF:barManager:DockControls:Add(SELF:standaloneBarDockControl_Categories)
    SELF:barManager:DockControls:Add(SELF:standaloneBarDockControl1)
    SELF:barManager:Form := SELF
    SELF:barManager:Items:AddRange(<DevExpress.XtraBars.BarItem>{ SELF:BBIAdd, SELF:BBIEdit, SELF:BBIDelete, SELF:BBIRefresh, SELF:BBIPrint, SELF:BBIClose, SELF:BBICatAdd, SELF:BBICatEdit, SELF:BBICatDelete, SELF:BBICatRefresh, SELF:BBIPreview, SELF:BBIBodyIsm, SELF:BBIDuplicateItems, SELF:BBIAddColumn, SELF:bbiExportToExcel, SELF:bbiLinkedLists, SELF:bbiComboboxColors, SELF:BBISave, SELF:BBIShowRevisionLog, SELF:barButtonItem1, SELF:barButtonItem2 })
    SELF:barManager:MainMenu := SELF:barItems
    SELF:barManager:MaxItemId := 19
    // 
    // barItems
    // 
    SELF:barItems:BarName := "Main menu"
    SELF:barItems:DockCol := 0
    SELF:barItems:DockRow := 0
    SELF:barItems:DockStyle := DevExpress.XtraBars.BarDockStyle.Standalone
    SELF:barItems:FloatLocation := System.Drawing.Point{582, 221}
    SELF:barItems:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:BBIEdit}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBISave}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIAdd}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIDuplicateItems}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIAddColumn}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIDelete}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIRefresh}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIPrint}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIPreview}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIBodyIsm}, DevExpress.XtraBars.LinkPersistInfo{SELF:bbiExportToExcel}, DevExpress.XtraBars.LinkPersistInfo{SELF:bbiLinkedLists}, DevExpress.XtraBars.LinkPersistInfo{SELF:bbiComboboxColors}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIShowRevisionLog}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIClose} })
    SELF:barItems:OptionsBar:AllowQuickCustomization := FALSE
    SELF:barItems:OptionsBar:DisableClose := TRUE
    SELF:barItems:OptionsBar:DisableCustomization := TRUE
    SELF:barItems:OptionsBar:MultiLine := TRUE
    SELF:barItems:OptionsBar:UseWholeRow := TRUE
    SELF:barItems:StandaloneBarDockControl := SELF:standaloneBarDockControl_Items
    SELF:barItems:Text := "Main menu"
    // 
    // BBIEdit
    // 
    SELF:BBIEdit:Caption := "Edit"
    SELF:BBIEdit:Id := 5
    SELF:BBIEdit:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIEdit.ImageOptions.Image")))
    SELF:BBIEdit:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIEdit.ImageOptions.LargeImage")))
    SELF:BBIEdit:ItemShortcut := DevExpress.XtraBars.BarShortcut{System.Windows.Forms.Keys.F2}
    SELF:BBIEdit:Name := "BBIEdit"
    toolTipTitleItem1:Text := "Edit (F2)"
    toolTipItem1:LeftIndent := 6
    toolTipItem1:Text := "Edit Report Item"
    superToolTip1:Items:Add(toolTipTitleItem1)
    superToolTip1:Items:Add(toolTipItem1)
    SELF:BBIEdit:SuperTip := superToolTip1
    SELF:BBIEdit:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIEdit_ItemClick() }
    // 
    // BBISave
    // 
    SELF:BBISave:Caption := "Save"
    SELF:BBISave:Enabled := FALSE
    SELF:BBISave:Id := 14
    SELF:BBISave:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBISave.ImageOptions.Image")))
    SELF:BBISave:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBISave.ImageOptions.LargeImage")))
    SELF:BBISave:Name := "BBISave"
    SELF:BBISave:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBISave_ItemClick() }
    // 
    // BBIAdd
    // 
    SELF:BBIAdd:Caption := "Add"
    SELF:BBIAdd:Enabled := FALSE
    SELF:BBIAdd:Id := 0
    SELF:BBIAdd:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIAdd.ImageOptions.Image")))
    SELF:BBIAdd:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIAdd.ImageOptions.LargeImage")))
    SELF:BBIAdd:ItemShortcut := DevExpress.XtraBars.BarShortcut{(System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.N)}
    SELF:BBIAdd:Name := "BBIAdd"
    toolTipTitleItem2:Text := "Add (Ctrl-N)"
    toolTipItem2:LeftIndent := 6
    toolTipItem2:Text := "Add new Report Item"
    superToolTip2:Items:Add(toolTipTitleItem2)
    superToolTip2:Items:Add(toolTipItem2)
    SELF:BBIAdd:SuperTip := superToolTip2
    SELF:BBIAdd:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIAdd_ItemClick() }
    // 
    // BBIDuplicateItems
    // 
    SELF:BBIDuplicateItems:Caption := "Duplicate Item(s)"
    SELF:BBIDuplicateItems:Enabled := FALSE
    SELF:BBIDuplicateItems:Id := 9
    SELF:BBIDuplicateItems:Name := "BBIDuplicateItems"
    SELF:BBIDuplicateItems:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @barButtonItem1_ItemClick() }
    // 
    // BBIAddColumn
    // 
    SELF:BBIAddColumn:Caption := "Add Column"
    SELF:BBIAddColumn:Enabled := FALSE
    SELF:BBIAddColumn:Id := 10
    SELF:BBIAddColumn:Name := "BBIAddColumn"
    SELF:BBIAddColumn:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @barButtonItem2_ItemClick() }
    // 
    // BBIDelete
    // 
    SELF:BBIDelete:Caption := "Delete"
    SELF:BBIDelete:Enabled := FALSE
    SELF:BBIDelete:Id := 2
    SELF:BBIDelete:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIDelete.ImageOptions.Image")))
    SELF:BBIDelete:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIDelete.ImageOptions.LargeImage")))
    SELF:BBIDelete:Name := "BBIDelete"
    toolTipTitleItem3:Text := "Delete"
    toolTipItem3:LeftIndent := 6
    toolTipItem3:Text := "Delete Report Item"
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
    toolTipItem4:Text := "Print Report Items"
    superToolTip5:Items:Add(toolTipTitleItem5)
    superToolTip5:Items:Add(toolTipItem4)
    SELF:BBIPrint:SuperTip := superToolTip5
    SELF:BBIPrint:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIPrint_ItemClick() }
    // 
    // BBIPreview
    // 
    SELF:BBIPreview:Caption := "Preview form"
    SELF:BBIPreview:Id := 6
    SELF:BBIPreview:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIPreview.ImageOptions.Image")))
    SELF:BBIPreview:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIPreview.ImageOptions.LargeImage")))
    SELF:BBIPreview:Name := "BBIPreview"
    toolTipTitleItem6:Text := "Preview form"
    toolTipItem5:LeftIndent := 6
    toolTipItem5:Text := "Preview the Vessel program's Form"
    superToolTip6:Items:Add(toolTipTitleItem6)
    superToolTip6:Items:Add(toolTipItem5)
    SELF:BBIPreview:SuperTip := superToolTip6
    SELF:BBIPreview:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIPreview_ItemClick() }
    // 
    // BBIBodyIsm
    // 
    SELF:BBIBodyIsm:Caption := "eMail body text"
    SELF:BBIBodyIsm:Id := 7
    SELF:BBIBodyIsm:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIBodyIsm.ImageOptions.Image")))
    SELF:BBIBodyIsm:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIBodyIsm.ImageOptions.LargeImage")))
    SELF:BBIBodyIsm:Name := "BBIBodyIsm"
    toolTipTitleItem7:Text := "eMail body text"
    toolTipItem6:LeftIndent := 6
    toolTipItem6:Text := e"Open and review the eMail body text form before exporting to Vessel\r\n"
    superToolTip7:Items:Add(toolTipTitleItem7)
    superToolTip7:Items:Add(toolTipItem6)
    SELF:BBIBodyIsm:SuperTip := superToolTip7
    SELF:BBIBodyIsm:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIBodyIsm_ItemClick() }
    // 
    // bbiExportToExcel
    // 
    SELF:bbiExportToExcel:Caption := "Export To Excel"
    SELF:bbiExportToExcel:Id := 11
    SELF:bbiExportToExcel:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("bbiExportToExcel.ImageOptions.Image")))
    SELF:bbiExportToExcel:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("bbiExportToExcel.ImageOptions.LargeImage")))
    SELF:bbiExportToExcel:Name := "bbiExportToExcel"
    SELF:bbiExportToExcel:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @bbiExportToExcel_ItemClick() }
    // 
    // bbiLinkedLists
    // 
    SELF:bbiLinkedLists:Caption := "Linked Lists"
    SELF:bbiLinkedLists:Id := 12
    SELF:bbiLinkedLists:Name := "bbiLinkedLists"
    // 
    // bbiComboboxColors
    // 
    SELF:bbiComboboxColors:Caption := "Combobox Colors"
    SELF:bbiComboboxColors:Id := 13
    SELF:bbiComboboxColors:Name := "bbiComboboxColors"
    SELF:bbiComboboxColors:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @bbiComboboxColors_ItemClick() }
    // 
    // BBIShowRevisionLog
    // 
    SELF:BBIShowRevisionLog:Caption := "Show Revision Log"
    SELF:BBIShowRevisionLog:Id := 15
    SELF:BBIShowRevisionLog:Name := "BBIShowRevisionLog"
    SELF:BBIShowRevisionLog:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIShowRevisionLog_ItemClick() }
    // 
    // BBIClose
    // 
    SELF:BBIClose:Caption := "Close"
    SELF:BBIClose:Id := 1
    SELF:BBIClose:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIClose.ImageOptions.Image")))
    SELF:BBIClose:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBIClose.ImageOptions.LargeImage")))
    SELF:BBIClose:ItemShortcut := DevExpress.XtraBars.BarShortcut{(System.Windows.Forms.Keys.Alt | System.Windows.Forms.Keys.F4)}
    SELF:BBIClose:Name := "BBIClose"
    toolTipTitleItem8:Text := "Close (Alt+F4)"
    toolTipItem7:LeftIndent := 6
    toolTipItem7:Text := "Close window"
    superToolTip8:Items:Add(toolTipTitleItem8)
    superToolTip8:Items:Add(toolTipItem7)
    SELF:BBIClose:SuperTip := superToolTip8
    SELF:BBIClose:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIClose_ItemClick() }
    // 
    // standaloneBarDockControl_Items
    // 
    SELF:standaloneBarDockControl_Items:CausesValidation := FALSE
    SELF:standaloneBarDockControl_Items:Dock := System.Windows.Forms.DockStyle.Top
    SELF:standaloneBarDockControl_Items:Location := System.Drawing.Point{0, 0}
    SELF:standaloneBarDockControl_Items:Manager := SELF:barManager
    SELF:standaloneBarDockControl_Items:Name := "standaloneBarDockControl_Items"
    SELF:standaloneBarDockControl_Items:Size := System.Drawing.Size{966, 26}
    SELF:standaloneBarDockControl_Items:Text := "standaloneBarDockControl1"
    // 
    // bar1
    // 
    SELF:bar1:BarName := "Custom 3"
    SELF:bar1:CanDockStyle := DevExpress.XtraBars.BarCanDockStyle.Standalone
    SELF:bar1:DockCol := 0
    SELF:bar1:DockRow := 0
    SELF:bar1:DockStyle := DevExpress.XtraBars.BarDockStyle.Standalone
    SELF:bar1:FloatLocation := System.Drawing.Point{385, 317}
    SELF:bar1:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:BBICatAdd}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBICatEdit}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBICatDelete}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBICatRefresh} })
    SELF:bar1:OptionsBar:AllowQuickCustomization := FALSE
    SELF:bar1:OptionsBar:UseWholeRow := TRUE
    SELF:bar1:StandaloneBarDockControl := SELF:standaloneBarDockControl_Categories
    SELF:bar1:Text := "Custom 3"
    // 
    // BBICatAdd
    // 
    SELF:BBICatAdd:Caption := "Add"
    SELF:BBICatAdd:Id := 2
    SELF:BBICatAdd:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBICatAdd.ImageOptions.Image")))
    SELF:BBICatAdd:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBICatAdd.ImageOptions.LargeImage")))
    SELF:BBICatAdd:Name := "BBICatAdd"
    toolTipTitleItem9:Text := "Add new Item Category"
    superToolTip9:Items:Add(toolTipTitleItem9)
    SELF:BBICatAdd:SuperTip := superToolTip9
    SELF:BBICatAdd:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBICatAdd_ItemClick() }
    // 
    // BBICatEdit
    // 
    SELF:BBICatEdit:Caption := "Edit"
    SELF:BBICatEdit:Id := 3
    SELF:BBICatEdit:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBICatEdit.ImageOptions.Image")))
    SELF:BBICatEdit:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBICatEdit.ImageOptions.LargeImage")))
    SELF:BBICatEdit:Name := "BBICatEdit"
    toolTipTitleItem10:Text := "Edit Item Category"
    superToolTip10:Items:Add(toolTipTitleItem10)
    SELF:BBICatEdit:SuperTip := superToolTip10
    SELF:BBICatEdit:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBICatEdit_ItemClick() }
    // 
    // BBICatDelete
    // 
    SELF:BBICatDelete:Caption := "Delete"
    SELF:BBICatDelete:Id := 4
    SELF:BBICatDelete:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBICatDelete.ImageOptions.Image")))
    SELF:BBICatDelete:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBICatDelete.ImageOptions.LargeImage")))
    SELF:BBICatDelete:Name := "BBICatDelete"
    toolTipTitleItem11:Text := "Delete Item Category"
    superToolTip11:Items:Add(toolTipTitleItem11)
    SELF:BBICatDelete:SuperTip := superToolTip11
    SELF:BBICatDelete:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBICatDelete_ItemClick() }
    // 
    // BBICatRefresh
    // 
    SELF:BBICatRefresh:Caption := "Refresh"
    SELF:BBICatRefresh:Id := 5
    SELF:BBICatRefresh:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBICatRefresh.ImageOptions.Image")))
    SELF:BBICatRefresh:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("BBICatRefresh.ImageOptions.LargeImage")))
    SELF:BBICatRefresh:Name := "BBICatRefresh"
    toolTipTitleItem12:Text := "Refresh Item Categories"
    superToolTip12:Items:Add(toolTipTitleItem12)
    SELF:BBICatRefresh:SuperTip := superToolTip12
    SELF:BBICatRefresh:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBICatRefresh_ItemClick() }
    // 
    // bar2
    // 
    SELF:bar2:BarName := "RelatedItems"
    SELF:bar2:CanDockStyle := DevExpress.XtraBars.BarCanDockStyle.Standalone
    SELF:bar2:DockCol := 0
    SELF:bar2:DockRow := 0
    SELF:bar2:DockStyle := DevExpress.XtraBars.BarDockStyle.Standalone
    SELF:bar2:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:barButtonItem1}, DevExpress.XtraBars.LinkPersistInfo{SELF:barButtonItem2} })
    SELF:bar2:OptionsBar:AllowQuickCustomization := FALSE
    SELF:bar2:OptionsBar:AllowRename := TRUE
    SELF:bar2:OptionsBar:AutoPopupMode := DevExpress.XtraBars.BarAutoPopupMode.None
    SELF:bar2:OptionsBar:UseWholeRow := TRUE
    SELF:bar2:StandaloneBarDockControl := SELF:standaloneBarDockControl1
    SELF:bar2:Text := "RelatedItems"
    // 
    // barButtonItem1
    // 
    SELF:barButtonItem1:Caption := "Add Relationship"
    SELF:barButtonItem1:Id := 16
    SELF:barButtonItem1:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("barButtonItem1.ImageOptions.Image")))
    SELF:barButtonItem1:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("barButtonItem1.ImageOptions.LargeImage")))
    SELF:barButtonItem1:Name := "barButtonItem1"
    SELF:barButtonItem1:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @barButtonItem1_ItemClick_1() }
    // 
    // barButtonItem2
    // 
    SELF:barButtonItem2:Caption := "Delete Relationship"
    SELF:barButtonItem2:Id := 17
    SELF:barButtonItem2:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("barButtonItem2.ImageOptions.Image")))
    SELF:barButtonItem2:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("barButtonItem2.ImageOptions.LargeImage")))
    SELF:barButtonItem2:Name := "barButtonItem2"
    SELF:barButtonItem2:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @barButtonItem2_ItemClick_1() }
    // 
    // standaloneBarDockControl1
    // 
    SELF:standaloneBarDockControl1:AutoSize := true
    SELF:standaloneBarDockControl1:CausesValidation := false
    SELF:standaloneBarDockControl1:Dock := System.Windows.Forms.DockStyle.Top
    SELF:standaloneBarDockControl1:Location := System.Drawing.Point{0, 0}
    SELF:standaloneBarDockControl1:Manager := SELF:barManager
    SELF:standaloneBarDockControl1:Name := "standaloneBarDockControl1"
    SELF:standaloneBarDockControl1:Size := System.Drawing.Size{187, 31}
    SELF:standaloneBarDockControl1:Text := "standaloneBarDockControl1"
    // 
    // barDockControlTop
    // 
    SELF:barDockControlTop:CausesValidation := false
    SELF:barDockControlTop:Dock := System.Windows.Forms.DockStyle.Top
    SELF:barDockControlTop:Location := System.Drawing.Point{0, 0}
    SELF:barDockControlTop:Manager := SELF:barManager
    SELF:barDockControlTop:Size := System.Drawing.Size{1231, 0}
    // 
    // barDockControlBottom
    // 
    SELF:barDockControlBottom:CausesValidation := false
    SELF:barDockControlBottom:Dock := System.Windows.Forms.DockStyle.Bottom
    SELF:barDockControlBottom:Location := System.Drawing.Point{0, 704}
    SELF:barDockControlBottom:Manager := SELF:barManager
    SELF:barDockControlBottom:Size := System.Drawing.Size{1231, 0}
    // 
    // barDockControlLeft
    // 
    SELF:barDockControlLeft:CausesValidation := false
    SELF:barDockControlLeft:Dock := System.Windows.Forms.DockStyle.Left
    SELF:barDockControlLeft:Location := System.Drawing.Point{0, 0}
    SELF:barDockControlLeft:Manager := SELF:barManager
    SELF:barDockControlLeft:Size := System.Drawing.Size{0, 704}
    // 
    // barDockControlRight
    // 
    SELF:barDockControlRight:CausesValidation := false
    SELF:barDockControlRight:Dock := System.Windows.Forms.DockStyle.Right
    SELF:barDockControlRight:Location := System.Drawing.Point{1231, 0}
    SELF:barDockControlRight:Manager := SELF:barManager
    SELF:barDockControlRight:Size := System.Drawing.Size{0, 704}
    // 
    // SCMain
    // 
    SELF:SCMain:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:SCMain:IsSplitterFixed := true
    SELF:SCMain:Location := System.Drawing.Point{0, 26}
    SELF:SCMain:Name := "SCMain"
    SELF:SCMain:Orientation := System.Windows.Forms.Orientation.Horizontal
    // 
    // SCMain.Panel1
    // 
    SELF:SCMain:Panel1:Controls:Add(SELF:splitContainerControl1)
    // 
    // SCMain.Panel2
    // 
    SELF:SCMain:Panel2:Controls:Add(SELF:SCCUsers)
    SELF:SCMain:Panel2Collapsed := true
    SELF:SCMain:Size := System.Drawing.Size{966, 678}
    SELF:SCMain:SplitterDistance := 413
    SELF:SCMain:TabIndex := 78
    // 
    // splitContainerControl1
    // 
    SELF:splitContainerControl1:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:splitContainerControl1:Location := System.Drawing.Point{0, 0}
    SELF:splitContainerControl1:Name := "splitContainerControl1"
    SELF:splitContainerControl1:Panel1:Controls:Add(SELF:GridItems)
    SELF:splitContainerControl1:Panel1:Text := "Panel1"
    SELF:splitContainerControl1:Panel2:Controls:Add(SELF:LBCRelated)
    SELF:splitContainerControl1:Panel2:Controls:Add(SELF:standaloneBarDockControl1)
    SELF:splitContainerControl1:Panel2:Text := "Panel2"
    SELF:splitContainerControl1:Size := System.Drawing.Size{966, 678}
    SELF:splitContainerControl1:SplitterPosition := 774
    SELF:splitContainerControl1:TabIndex := 0
    SELF:splitContainerControl1:Text := "splitContainerControl1"
    // 
    // GridItems
    // 
    SELF:GridItems:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:GridItems:Location := System.Drawing.Point{0, 0}
    SELF:GridItems:MainView := SELF:GridViewItems
    SELF:GridItems:Name := "GridItems"
    SELF:GridItems:Size := System.Drawing.Size{774, 678}
    SELF:GridItems:TabIndex := 79
    SELF:GridItems:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:GridViewItems, SELF:gridView1 })
    // 
    // GridViewItems
    // 
    SELF:GridViewItems:GridControl := SELF:GridItems
    SELF:GridViewItems:Name := "GridViewItems"
    SELF:GridViewItems:OptionsBehavior:Editable := false
    SELF:GridViewItems:OptionsSelection:EnableAppearanceHideSelection := false
    SELF:GridViewItems:OptionsView:ShowAutoFilterRow := true
    SELF:GridViewItems:OptionsView:ShowGroupPanel := false
    SELF:GridViewItems:RowClick += DevExpress.XtraGrid.Views.Grid.RowClickEventHandler{ SELF, @GridViewItems_RowCellClick() }
    SELF:GridViewItems:SelectionChanged += DevExpress.Data.SelectionChangedEventHandler{ SELF, @GridViewItems_SelectionChanged() }
    SELF:GridViewItems:FocusedRowChanged += DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventHandler{ SELF, @GridViewItems_FocusedRowChanged() }
    SELF:GridViewItems:FocusedColumnChanged += DevExpress.XtraGrid.Views.Base.FocusedColumnChangedEventHandler{ SELF, @GridViewItems_FocusedColumnChanged() }
    SELF:GridViewItems:CellValueChanged += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @GridViewItems_CellValueChanged() }
    SELF:GridViewItems:CellValueChanging += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @GridViewItems_CellValueChanging() }
    SELF:GridViewItems:BeforeLeaveRow += DevExpress.XtraGrid.Views.Base.RowAllowEventHandler{ SELF, @GridViewItems_BeforeLeaveRow() }
    SELF:GridViewItems:CustomUnboundColumnData += DevExpress.XtraGrid.Views.Base.CustomColumnDataEventHandler{ SELF, @GridViewItems_CustomUnboundColumnData() }
    SELF:GridViewItems:DoubleClick += System.EventHandler{ SELF, @GridViewItems_DoubleClick() }
    // 
    // gridView1
    // 
    SELF:gridView1:GridControl := SELF:GridItems
    SELF:gridView1:Name := "gridView1"
    // 
    // LBCRelated
    // 
    SELF:LBCRelated:Appearance:Font := System.Drawing.Font{"Lucida Console", 8.25}
    SELF:LBCRelated:Appearance:Options:UseFont := true
    SELF:LBCRelated:Cursor := System.Windows.Forms.Cursors.Default
    SELF:LBCRelated:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:LBCRelated:Location := System.Drawing.Point{0, 31}
    SELF:LBCRelated:Name := "LBCRelated"
    SELF:LBCRelated:Size := System.Drawing.Size{187, 647}
    SELF:LBCRelated:TabIndex := 1
    // 
    // SCCUsers
    // 
    SELF:SCCUsers:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:SCCUsers:Location := System.Drawing.Point{0, 0}
    SELF:SCCUsers:Name := "SCCUsers"
    SELF:SCCUsers:Panel1:Controls:Add(SELF:LBCInGroups)
    SELF:SCCUsers:Panel1:Text := "Panel1"
    SELF:SCCUsers:Panel2:Controls:Add(SELF:LBCOutGroups)
    SELF:SCCUsers:Panel2:Text := "Panel2"
    SELF:SCCUsers:Size := System.Drawing.Size{150, 46}
    SELF:SCCUsers:SplitterPosition := 145
    SELF:SCCUsers:TabIndex := 0
    SELF:SCCUsers:Text := "splitContainerControl1"
    // 
    // LBCInGroups
    // 
    SELF:LBCInGroups:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:LBCInGroups:Location := System.Drawing.Point{0, 0}
    SELF:LBCInGroups:Name := "LBCInGroups"
    SELF:LBCInGroups:Size := System.Drawing.Size{145, 46}
    SELF:LBCInGroups:TabIndex := 0
    SELF:LBCInGroups:DoubleClick += System.EventHandler{ SELF, @LBCInGroups_DoubleClick() }
    // 
    // LBCOutGroups
    // 
    SELF:LBCOutGroups:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:LBCOutGroups:Location := System.Drawing.Point{0, 0}
    SELF:LBCOutGroups:Name := "LBCOutGroups"
    SELF:LBCOutGroups:Size := System.Drawing.Size{0, 0}
    SELF:LBCOutGroups:TabIndex := 1
    SELF:LBCOutGroups:DoubleClick += System.EventHandler{ SELF, @LBCOutGroups_DoubleClick() }
    // 
    // ItemsForm
    // 
    SELF:AutoScaleDimensions := System.Drawing.SizeF{6, 13}
    SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
    SELF:ClientSize := System.Drawing.Size{1231, 704}
    SELF:Controls:Add(SELF:splitContainerControl_Items)
    SELF:Controls:Add(SELF:barDockControlLeft)
    SELF:Controls:Add(SELF:barDockControlRight)
    SELF:Controls:Add(SELF:barDockControlBottom)
    SELF:Controls:Add(SELF:barDockControlTop)
    SELF:Name := "ItemsForm"
    SELF:ShowIcon := false
    SELF:StartPosition := System.Windows.Forms.FormStartPosition.CenterParent
    SELF:Text := "Report Items Form"
    SELF:FormClosing += System.Windows.Forms.FormClosingEventHandler{ SELF, @ItemsForm_FormClosing() }
    SELF:FormClosed += System.Windows.Forms.FormClosedEventHandler{ SELF, @ItemsForm_FormClosed() }
    SELF:Load += System.EventHandler{ SELF, @ItemsForm_Load() }
    SELF:Shown += System.EventHandler{ SELF, @ItemsForm_Shown() }
    ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl_Items)):EndInit()
    SELF:splitContainerControl_Items:ResumeLayout(false)
    ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl_Categories)):EndInit()
    SELF:splitContainerControl_Categories:ResumeLayout(false)
    SELF:tabControl1:ResumeLayout(false)
    SELF:tabPage1:ResumeLayout(false)
    ((System.ComponentModel.ISupportInitialize)(SELF:LBCReports)):EndInit()
    SELF:tabPage2:ResumeLayout(false)
    ((System.ComponentModel.ISupportInitialize)(SELF:LBCOfficeReports)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:LBCCategories)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:barManager)):EndInit()
    SELF:SCMain:Panel1:ResumeLayout(false)
    SELF:SCMain:Panel2:ResumeLayout(false)
    ((System.ComponentModel.ISupportInitialize)(SELF:SCMain)):EndInit()
    SELF:SCMain:ResumeLayout(false)
    ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl1)):EndInit()
    SELF:splitContainerControl1:ResumeLayout(false)
    ((System.ComponentModel.ISupportInitialize)(SELF:GridItems)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:GridViewItems)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:gridView1)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:LBCRelated)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:SCCUsers)):EndInit()
    SELF:SCCUsers:ResumeLayout(false)
    ((System.ComponentModel.ISupportInitialize)(SELF:LBCInGroups)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:LBCOutGroups)):EndInit()
    SELF:ResumeLayout(false)
    SELF:PerformLayout()
PRIVATE METHOD ItemsForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:ItemsForm_OnLoad()
        RETURN
PRIVATE METHOD ItemsForm_FormClosing( sender AS System.Object, e AS System.Windows.Forms.FormClosingEventArgs ) AS System.Void
        oSoftway:SaveFormSettings_DevExpress(SELF, splitContainerControl_Items, oMainForm:alForms, oMainForm:alData)
        RETURN
PRIVATE METHOD ItemsForm_FormClosed( sender AS System.Object, e AS System.Windows.Forms.FormClosedEventArgs ) AS System.Void
        RETURN
PRIVATE METHOD BBIAdd_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:Items_Add()
        RETURN
PRIVATE METHOD BBIEdit_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        // Get GridRow data into a DataRowView object
        //LOCAL oRow AS DataRowView
        SELF:ItemsEnterEditMode(true)
        //oRow := (DataRowView)SELF:GridViewItems:GetFocusedRow()
        //SELF:Items_Edit(oRow, SELF:GridViewItems:FocusedColumn)
        RETURN
PRIVATE METHOD BBIDelete_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        LOCAL iIndexes AS INT[]
        iIndexes := SELF:GridViewItems:GetSelectedRows()
        IF(iIndexes:Length==1)
            SELF:Items_Delete()
        ELSE
            LOCAL oRow AS DataRowView
            LOCAL i AS INT
            FOR i := iIndexes:Length DOWNTO 1 STEP 1
                oRow := (DataRowView)SELF:GridViewItems:GetRow(iIndexes[i])
                //SELF:Items_Add(oRow)
                SELF:Items_Delete(oRow)
            NEXT
        ENDIF
        
        SELF:lChanged := TRUE
        //SELF:Items_Refresh()    
    RETURN
PRIVATE METHOD BBIRefresh_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:Items_Refresh()
        RETURN
PRIVATE METHOD BBIPrint_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:Items_Print()
        RETURN
PRIVATE METHOD BBIClose_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:Close()
        RETURN
PRIVATE METHOD GridViewItems_BeforeLeaveRow( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.Void
        SELF:BeforeLeaveRow_Items(e)
        RETURN
PRIVATE METHOD GridViewItems_CustomUnboundColumnData( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs ) AS System.Void
        SELF:CustomUnboundColumnData_Items(e)
        RETURN
PRIVATE METHOD GridViewItems_CellValueChanging( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
        // Handles the uItemType column CellValueChanging to catch the ComboBox selected item
        DO CASE
        CASE e:Column:FieldName == "uItemType"
            SELF:cItemTypeValue := e:Value:ToString()

        // Handles the uCategory column CellValueChanging to catch the ComboBox selected item
        CASE e:Column:FieldName == "uCategory"
            // Save the STATEFLAG_UID
            SELF:cChangedCategoryValue := e:Value:ToString()

            SELF:cChangedCategoryFilterString := SELF:GridViewItems:ActiveFilterString
            //Self:oChangedStateFlagColor := (System.Drawing.Color)e:Value
            //wb(((RepositoryItemGridLookUpEdit)(e:Column:ColumnEdit)):View)
		CASE e:Column:FieldName == "uColumnColor"
			SELF:oChangedReportColor := (System.Drawing.Color)e:Value
        ENDCASE
        RETURN
PRIVATE METHOD GridViewItems_CellValueChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
        DO CASE
        CASE e:Column:FieldName == "uCategory"
            //Self:SetEditModeOff_Common(GridViewStateFlags)

            e:Column:ColumnEdit := NULL
            e:Column:OptionsColumn:AllowEdit := FALSE

            IF ! SELF:lCategoryEditMode
                RETURN
            ENDIF

            SELF:Category_Save(e:RowHandle)
            SELF:lCategoryEditMode := FALSE
            // Workaround to bypass the side-effect of hidding column's values when entering in Edit mode
            // for each cell, return the existed STATEFLAG_UID to the LookupEdit in order to redraw the StateFlag text values

            IF SELF:GridViewItems:ActiveFilterString <> ""
                SELF:GridViewItems:ActiveFilterString := SELF:cChangedCategoryFilterString
                SELF:CreateGridItems()
            ENDIF

            //IF SELF:GridViewMessages:ActiveFilter <> NULL .and. SELF:GridViewMessages:ActiveFilterString <> ""
            //    SELF:CreateGridMessages(TRUE, FALSE)
            //ENDIF
            RETURN

        OTHERWISE
            SELF:SetEditModeOff_Common(SELF:GridViewItems)
            SELF:Items_Save(e)
        ENDCASE
        
        SELF:lChanged := TRUE
    RETURN
PRIVATE METHOD GridViewItems_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        LOCAL oPoint := SELF:GridViewItems:GridControl:PointToClient(Control.MousePosition) AS Point
        LOCAL info := SELF:GridViewItems:CalcHitInfo(oPoint) AS DevExpress.XtraGrid.Views.Grid.ViewInfo.GridHitInfo
        IF info:InRow .or. info:InRowCell
            IF SELF:GridViewItems:IsGroupRow(info:RowHandle)
                RETURN
            ENDIF

            // Get GridRow data into a DataRowView object
            LOCAL oRow AS DataRowView
            oRow:=(DataRowView)SELF:GridViewItems:GetRow(info:RowHandle)

            IF info:Column <> NULL
                // Set focused Row/Column (for DoubleClick event)
                //SELF:GridViewItems:FocusedRowHandle := info:RowHandle
                //SELF:GridViewItems:FocusedColumn := info:Column

                SELF:Items_Edit(oRow, info:Column)
            ENDIF
        ENDIF
        RETURN
PRIVATE METHOD GridViewItems_FocusedColumnChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.FocusedColumnChangedEventArgs ) AS System.Void
        //IF SELF:lSuspendNotification
        //    RETURN
        //ENDIF
        SELF:SetEditModeOff_Common(SELF:GridViewItems)
        RETURN
PRIVATE METHOD LBCReports_SelectedIndexChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:SelectedReportChanged()
        RETURN
PRIVATE METHOD LBCReports_DrawItem( sender AS System.Object, e AS DevExpress.XtraEditors.ListBoxDrawItemEventArgs ) AS System.Void
        oMainForm:DrawLBCReportsItem(e)
        RETURN
PRIVATE METHOD BBICatAdd_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:CategoryAdd()
        RETURN
PRIVATE METHOD BBICatEdit_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:CategoryEdit()
        RETURN
PRIVATE METHOD BBICatDelete_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:CategoryDelete()
        RETURN
PRIVATE METHOD BBICatRefresh_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:CategoryRefresh("")
        RETURN
PRIVATE METHOD GridViewItems_RowCellClick( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Grid.RowCellClickEventArgs ) AS System.Void
        DO CASE
        CASE e:Column:FieldName == "uCategory"    //e:Column:AbsoluteIndex == Self:GridColumnAbsoluteIndex_StateFlag
            //wb(e:Column:FieldName, "RowCellClick")
            SELF:lCategoryEditMode := TRUE
            e:Column:ColumnEdit := SELF:oRepositoryItemGridLookUpEdit_Category
            e:Column:OptionsColumn:AllowEdit := TRUE
//wb(Self:oRepositoryItemGridLookUpEdit_StateFlag:View:Columns:Count)
            //SELF:GridViewMessages:OptionsSelection:EnableAppearanceFocusedCell := True
            //SELF:GridViewMessages:ShowEditor()
        ENDCASE
        RETURN
PRIVATE METHOD BBIPreview_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:PreviewForm()
        RETURN

// Categories: Drag-Drop
PRIVATE METHOD LBCCategories_MouseDown( sender AS System.Object, e AS System.Windows.Forms.MouseEventArgs ) AS System.Void
        LOCAL oLBC := (DevExpress.XtraEditors.ListBoxControl)sender AS DevExpress.XtraEditors.ListBoxControl

        SELF:p := Point{e:X, e:Y}
        LOCAL selectedIndex := oLBC:IndexFromPoint(SELF:p) AS INT
        IF selectedIndex == -1
            SELF:p := Point.Empty
        ENDIF
        RETURN
PRIVATE METHOD LBCCategories_MouseMove( sender AS System.Object, e AS System.Windows.Forms.MouseEventArgs ) AS System.Void
        IF (e:Button == MouseButtons.Left)
            IF (SELF:p != Point.Empty) && ((Math.Abs(e:X - SELF:p:X) > SystemInformation.DragSize:Width) || (Math.Abs(e:Y - SELF:p:Y) > SystemInformation.DragSize:Height))
                SELF:LBCCategories:DoDragDrop(sender, DragDropEffects.Move)
            ENDIF
        ENDIF
        RETURN
PRIVATE METHOD LBCCategories_DragOver( sender AS System.Object, e AS System.Windows.Forms.DragEventArgs ) AS System.Void
        e:Effect := DragDropEffects.Move
        RETURN
PRIVATE METHOD LBCCategories_DragDrop( sender AS System.Object, e AS System.Windows.Forms.DragEventArgs ) AS System.Void
        LOCAL oLBC := (DevExpress.XtraEditors.ListBoxControl)sender AS DevExpress.XtraEditors.ListBoxControl
        LOCAL newPoint := Point{e:X, e:Y} AS Point

        newPoint := oLBC:PointToClient(newPoint)
        LOCAL selectedIndex := oLBC:IndexFromPoint(newPoint) AS INT

        LOCAL oRow := (System.Data.DataRowView)LBCCategories:SelectedItem AS System.Data.DataRowView
        SELF:DropCategory(selectedIndex, oRow)
        //wb(oRow:ToString(), "selectedIndex="+selectedIndex:ToString())
        //(listBox.DataSource AS DataTable).Rows.Add(new OBJECT[] {row[0], row[1]})
        RETURN
PRIVATE METHOD BBIBodyIsm_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:OpenBodyISMForm()
        RETURN
PRIVATE METHOD barButtonItem1_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:DuplicateItems()
        RETURN
PRIVATE METHOD LBCOfficeReports_SelectedIndexChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
            SELF:SelectedOfficeReportChanged()
        RETURN
PRIVATE METHOD LBCOfficeReports_Enter( sender AS System.Object, e AS System.EventArgs ) AS System.Void
            SELF:SelectedOfficeReportChanged()
        RETURN
PRIVATE METHOD tabPage2_Enter( sender AS System.Object, e AS System.EventArgs ) AS System.Void
             SELF:LBCOfficeReports_Enter(SELF,EventArgs.Empty)
        RETURN
PRIVATE METHOD tabPage1_Enter( sender AS System.Object, e AS System.EventArgs ) AS System.Void
            SELF:LBCReports_SelectedIndexChanged(SELF,EventArgs.Empty)
        RETURN
PRIVATE METHOD LBCGroups_MouseDoubleClick( sender AS System.Object, e AS System.Windows.Forms.MouseEventArgs ) AS System.Void
            SELF:LBCGroups_DoubleClick(sender,e)
        RETURN
PRIVATE METHOD GridViewItems_FocusedRowChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventArgs ) AS System.Void
            //SELF:updateUsers(e)
            SELF:updateUsers(((DataRowView)SELF:GridViewItems:GetRow(e:FocusedRowHandle)))
        RETURN
PRIVATE METHOD GridItems_DataSourceChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
            IF SELF:oDTItems:Rows:Count > 0 
                SELF:updateUsers(SELF:oDTItems:Rows[0])
            ENDIF
    RETURN
PRIVATE METHOD GridViewItems_SelectionChanged( sender AS System.Object, e AS DevExpress.Data.SelectionChangedEventArgs ) AS System.Void
            SELF:updateUsers()
			SELF:ShowRelatedItems()
        RETURN
PRIVATE METHOD LBCInGroups_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
            SELF:LBCGroups_DoubleClick(sender,e)
        RETURN
PRIVATE METHOD LBCOutGroups_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
            SELF:LBCGroupsOut_DoubleClick(sender,e)
        RETURN
PRIVATE METHOD LBCReports_Enter( sender AS System.Object, e AS System.EventArgs ) AS System.Void
            SELF:SCMain:Panel2Collapsed := true
        RETURN
PRIVATE METHOD tabControl1_Selected( sender AS System.Object, e AS System.Windows.Forms.TabControlEventArgs ) AS System.Void
            //SELF:SCMain:Panel2Collapsed := true
        RETURN
PRIVATE METHOD tabControl1_SelectedIndexChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
            IF SELF:tabControl1:SelectedIndex == 0
                SELF:SCMain:Panel2Collapsed := true
            ELSE
                SELF:SCMain:Panel2Collapsed := false
            ENDIF
        RETURN
PRIVATE METHOD barButtonItem2_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            
            LOCAL iIndexes AS INT[]
            iIndexes := SELF:GridViewItems:GetSelectedRows()
            
            IF(iIndexes:Length==1)
                LOCAL oRow AS DataRowView
                LOCAL nRowHandle := SELF:GridViewItems:FocusedRowHandle AS INT
                oRow:=(DataRowView)SELF:GridViewItems:GetRow(nRowHandle)
                IF oRow == NULL
                    RETURN
                ENDIF
                IF oRow:Item["ItemType"]:ToString() <> "A"
                        MessageBox.Show("You can add columns only on Table items.")
                        RETURN
                ENDIF
            ELSE
                MessageBox.Show("Can not select Multiple Lines or No line selected.")
                RETURN
            ENDIF
        
        
            LOCAL oAddColumnForm := AddColumnForm{} AS AddColumnForm
            oAddColumnForm:oMyItemsForm := SELF
            IF oAddColumnForm:ShowDialog() <> DialogResult.OK
                RETURN
            ENDIF

            SELF:lChanged := TRUE
    RETURN
PRIVATE METHOD bbiExportToExcel_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        LOCAL oMyLBControl AS DevExpress.XtraEditors.ListBoxControl 
        IF SELF:tabControl1:SelectedIndex == 0
            oMyLBControl := SELF:LBCReports
        ELSE
            oMyLBControl := SELF:LBCOfficeReports
        ENDIF
        LOCAL cReportUID := oMyLBControl:SelectedValue:ToString() AS STRING
        LOCAL cReportName := oMyLBControl:GetDisplayItemValue(oMyLBControl:SelectedIndex):ToString() AS STRING
        //LOCAL cVesselUID := oMainForm:GetVesselUID AS STRING
        //LOCAL cVesselName := oMainForm:GetVesselName AS STRING
        oMainForm:PrintFormToExcelFile(cReportUID,cReportName,true, "", "Vessels")
        
    RETURN
PRIVATE METHOD bbiComboboxColors_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            SELF:bbiComboboxColorsItemClick()
        RETURN
PRIVATE METHOD BBISave_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            
            SELF:ItemsEnterEditMode(FALSE)
            IF SELF:lChanged 
                SELF:createRecordOnLogTable()
                SELF:lChanged := FALSE
            ENDIF
    RETURN
PRIVATE METHOD ItemsEnterEditMode(lEdit AS LOGIC) AS VOID
        SELF:tabControl1:Enabled := !lEdit
        SELF:BBIEdit:Enabled := !lEdit
        SELF:BBIAdd:Enabled := lEdit
        SELF:BBIDelete:Enabled := lEdit
        SELF:BBISave:Enabled := lEdit
        SELF:BBIDuplicateItems:Enabled := lEdit
        SELF:BBIAddColumn:Enabled := lEdit
        SELF:GridViewItems:OptionsBehavior:Editable := lEdit

    RETURN
PRIVATE METHOD createRecordOnLogTable() AS VOID
        LOCAL oMyLBControl AS DevExpress.XtraEditors.ListBoxControl 
        IF SELF:tabControl1:SelectedIndex == 0
            oMyLBControl := SELF:LBCReports
        ELSE
            oMyLBControl := SELF:LBCOfficeReports
        ENDIF    
    
        LOCAL cReportUID := oMyLBControl:SelectedValue:ToString() AS STRING

        LOCAL oLogForm := ReportChangeLog{} AS ReportChangeLog    
        oLogForm:cMyReportUID := cReportUID
        oLogForm:txtNotes:Text := cLogNotes:Trim()
        oLogForm:Show()
        cLogNotes:=""
    RETURN
PRIVATE METHOD BBIShowRevisionLog_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            
            LOCAL cReportUID AS STRING
            IF SELF:tabControl1:SelectedIndex == 0
                cReportUID := SELF:LBCReports:SelectedValue:ToString()
            ELSE
                cReportUID := SELF:LBCOfficeReports:SelectedValue:ToString()
            ENDIF    
    
            LOCAL oLogForm := ReportChangeLog{} AS ReportChangeLog    
            oLogForm:cMyReportUID := cReportUID
            oLogForm:lShowOnly := TRUE
            oLogForm:Show()

        RETURN
PRIVATE METHOD barButtonItem2_ItemClick_1(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    SELF:RemoveRelated()
    RETURN
PRIVATE METHOD barButtonItem1_ItemClick_1(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    LOCAL form := RLTItemsAddForm{SELF, SELF:GetSelectedItemUID()} AS RLTItemsAddForm
    form:Show()
    RETURN
PRIVATE METHOD ItemsForm_Shown(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    splitContainerControl1:AutoSize := FALSE
    splitContainerControl_Items:SplitterPosition := 200
    splitContainerControl1:SplitterPosition := splitContainerControl1:Width - 250
    SELF:splitContainerControl1:Panel2:Width := 250
    RETURN
PRIVATE METHOD GridViewItems_DoubleClick_1(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    RETURN
PRIVATE METHOD GridViewItems_RowCellClick(sender AS OBJECT, e AS DevExpress.XtraGrid.Views.Grid.RowClickEventArgs) AS VOID STRICT
    RETURN

END CLASS 
