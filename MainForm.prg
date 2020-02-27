USING System.Data
PUBLIC PARTIAL CLASS MainForm ;
    INHERIT DevExpress.XtraEditors.XtraForm
    PRIVATE defaultLookAndFeel AS DevExpress.LookAndFeel.DefaultLookAndFeel
    PRIVATE splitContainerControl_Main AS DevExpress.XtraEditors.SplitContainerControl
    PRIVATE splitContainerControl_LBC AS DevExpress.XtraEditors.SplitContainerControl
    PRIVATE barManager1 AS DevExpress.XtraBars.BarManager
    PRIVATE barDockControlTop AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlBottom AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlLeft AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlRight AS DevExpress.XtraBars.BarDockControl
    PRIVATE BBICheckAll AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BarStatus AS DevExpress.XtraBars.Bar
    PRIVATE splitContainerControl_CheckedLBC AS DevExpress.XtraEditors.SplitContainerControl
    PUBLIC LBCVesselReports AS DevExpress.XtraEditors.ListBoxControl
    PRIVATE BBIShowOnMap AS DevExpress.XtraBars.BarButtonItem
    PRIVATE dockManager1 AS DevExpress.XtraBars.Docking.DockManager
    PRIVATE DockPanelProgramsBar_Container AS DevExpress.XtraBars.Docking.ControlContainer
    PRIVATE DockPanelProgramsBar AS DevExpress.XtraBars.Docking.DockPanel
    PRIVATE standaloneBarDockControl_VesselReports AS DevExpress.XtraBars.StandaloneBarDockControl
    PRIVATE BarVesselReports AS DevExpress.XtraBars.Bar
    PRIVATE BBIShowMessage AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIShowTabForm AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIIsmForm AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIImportExcelData AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBICreateExcelReport AS DevExpress.XtraBars.BarButtonItem
    PRIVATE standaloneBarDockControl_Main AS DevExpress.XtraBars.StandaloneBarDockControl
    PRIVATE BarVessels AS DevExpress.XtraBars.Bar
    PRIVATE barMain AS DevExpress.XtraBars.Bar
    PRIVATE BBIShowVoyageOnNewMap_Main AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIReportDefinition AS DevExpress.XtraBars.BarButtonItem
    PRIVATE barEditItemPeriod AS DevExpress.XtraBars.BarEditItem
    PRIVATE repositoryItemComboBox2 AS DevExpress.XtraEditors.Repository.RepositoryItemComboBox
    PRIVATE standaloneBarDockControl_Vessels AS DevExpress.XtraBars.StandaloneBarDockControl
    PUBLIC TreeListVessels AS DevExpress.XtraTreeList.TreeList
    PUBLIC TreeListVesselsReports AS DevExpress.XtraTreeList.TreeList
    PUBLIC reportsImageList AS System.Windows.Forms.ImageList
    PUBLIC voyageTypeImgList AS System.Windows.Forms.ImageList
    PRIVATE backBBI AS DevExpress.XtraBars.BarButtonItem
    PRIVATE splitMapForm AS DevExpress.XtraEditors.SplitContainerControl
    PRIVATE BBIEditReport AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBISave AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIDelete AS DevExpress.XtraBars.BarButtonItem
    PRIVATE repositoryItemComboBox1 AS DevExpress.XtraEditors.Repository.RepositoryItemComboBox
    PRIVATE barEditItemDisplayMap AS DevExpress.XtraBars.BarEditItem
    PRIVATE panelControl_BingMaps AS DevExpress.XtraEditors.PanelControl
    PRIVATE BBIRefreshReports AS DevExpress.XtraBars.BarButtonItem
    PRIVATE tabPage1 AS System.Windows.Forms.TabPage
    PRIVATE tabPage2 AS System.Windows.Forms.TabPage
    PRIVATE MainBBIGlobal AS DevExpress.XtraBars.BarButtonItem
    PUBLIC LBCReportsOffice AS DevExpress.XtraEditors.ListBoxControl
    PUBLIC LBCReportsVessel AS DevExpress.XtraEditors.ListBoxControl
    PUBLIC ReportsTabUserControl AS System.Windows.Forms.TabControl
    PRIVATE BBICreateReport AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIFinalize AS DevExpress.XtraBars.BarButtonItem
    PRIVATE printButton AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBICancel AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBISubmit AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIAppove AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBSIStatus AS DevExpress.XtraBars.BarStaticItem
    PRIVATE BBIMyApprovals AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIReturn AS DevExpress.XtraBars.BarButtonItem
    PRIVATE popupMenu1 AS DevExpress.XtraBars.PopupMenu
    PRIVATE barButtonItem2 AS DevExpress.XtraBars.BarButtonItem
    PRIVATE barButtonItem3 AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBITableReports AS DevExpress.XtraBars.BarButtonItem
    PRIVATE ContextMenuStripExportToExcel AS System.Windows.Forms.ContextMenuStrip
    PRIVATE ExportToExcelToolStripMenuItem AS System.Windows.Forms.ToolStripMenuItem
    PRIVATE barButtonItem1 AS DevExpress.XtraBars.BarButtonItem
    PRIVATE barButtonItem4 AS DevExpress.XtraBars.BarButtonItem
    PRIVATE galleryDropDown1 AS DevExpress.XtraBars.Ribbon.GalleryDropDown
    PRIVATE BBISamosReports AS DevExpress.XtraBars.BarSubItem
    PRIVATE barButtonItem5 AS DevExpress.XtraBars.BarButtonItem
    PRIVATE barButtonItem6 AS DevExpress.XtraBars.BarButtonItem
    PRIVATE barButtonItem7 AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIAppovalHistory AS DevExpress.XtraBars.BarButtonItem
    PRIVATE barButtonItemMRVReport AS DevExpress.XtraBars.BarButtonItem
    PRIVATE bbiAlerts AS DevExpress.XtraBars.BarButtonItem
    PRIVATE bbiNewVoyage AS DevExpress.XtraBars.BarButtonItem
    PRIVATE hideContainerLeft AS DevExpress.XtraBars.Docking.AutoHideContainer
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
    LOCAL resources := System.ComponentModel.ComponentResourceManager{typeof(MainForm)} AS System.ComponentModel.ComponentResourceManager
    LOCAL superToolTip41 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem41 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL toolTipItem25 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
    LOCAL superToolTip42 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem42 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL toolTipItem26 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
    LOCAL superToolTip43 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem43 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL toolTipItem27 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
    LOCAL superToolTip44 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem44 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL superToolTip45 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem45 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL toolTipItem28 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
    LOCAL superToolTip46 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem46 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL superToolTip47 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem47 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL superToolTip48 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem48 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL toolTipItem29 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
    LOCAL superToolTip49 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem49 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    LOCAL toolTipItem30 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
    LOCAL superToolTip50 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
    LOCAL toolTipTitleItem50 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
    SELF:defaultLookAndFeel := DevExpress.LookAndFeel.DefaultLookAndFeel{SELF:components}
    SELF:splitContainerControl_Main := DevExpress.XtraEditors.SplitContainerControl{}
    SELF:splitContainerControl_LBC := DevExpress.XtraEditors.SplitContainerControl{}
    SELF:TreeListVessels := DevExpress.XtraTreeList.TreeList{}
    SELF:standaloneBarDockControl_Vessels := DevExpress.XtraBars.StandaloneBarDockControl{}
    SELF:barManager1 := DevExpress.XtraBars.BarManager{SELF:components}
    SELF:BarVessels := DevExpress.XtraBars.Bar{}
    SELF:BBICheckAll := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIShowOnMap := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIImportExcelData := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIRefreshReports := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIMyApprovals := DevExpress.XtraBars.BarButtonItem{}
    SELF:MainBBIGlobal := DevExpress.XtraBars.BarButtonItem{}
    SELF:barEditItemDisplayMap := DevExpress.XtraBars.BarEditItem{}
    SELF:repositoryItemComboBox1 := DevExpress.XtraEditors.Repository.RepositoryItemComboBox{}
    SELF:bbiAlerts := DevExpress.XtraBars.BarButtonItem{}
    SELF:BarStatus := DevExpress.XtraBars.Bar{}
    SELF:BarVesselReports := DevExpress.XtraBars.Bar{}
    SELF:backBBI := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIShowMessage := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIShowTabForm := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIIsmForm := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBICreateExcelReport := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBITableReports := DevExpress.XtraBars.BarButtonItem{}
    SELF:barEditItemPeriod := DevExpress.XtraBars.BarEditItem{}
    SELF:repositoryItemComboBox2 := DevExpress.XtraEditors.Repository.RepositoryItemComboBox{}
    SELF:bbiNewVoyage := DevExpress.XtraBars.BarButtonItem{}
    SELF:standaloneBarDockControl_VesselReports := DevExpress.XtraBars.StandaloneBarDockControl{}
    SELF:barMain := DevExpress.XtraBars.Bar{}
    SELF:BBISamosReports := DevExpress.XtraBars.BarSubItem{}
    SELF:barButtonItem1 := DevExpress.XtraBars.BarButtonItem{}
    SELF:barButtonItem4 := DevExpress.XtraBars.BarButtonItem{}
    SELF:barButtonItem5 := DevExpress.XtraBars.BarButtonItem{}
    SELF:barButtonItem6 := DevExpress.XtraBars.BarButtonItem{}
    SELF:barButtonItem7 := DevExpress.XtraBars.BarButtonItem{}
    SELF:barButtonItemMRVReport := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIReportDefinition := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIShowVoyageOnNewMap_Main := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBICreateReport := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIEditReport := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBICancel := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBISave := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIFinalize := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBISubmit := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIReturn := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIAppove := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBIDelete := DevExpress.XtraBars.BarButtonItem{}
    SELF:printButton := DevExpress.XtraBars.BarButtonItem{}
    SELF:popupMenu1 := DevExpress.XtraBars.PopupMenu{SELF:components}
    SELF:barButtonItem2 := DevExpress.XtraBars.BarButtonItem{}
    SELF:barButtonItem3 := DevExpress.XtraBars.BarButtonItem{}
    SELF:BBSIStatus := DevExpress.XtraBars.BarStaticItem{}
    SELF:BBIAppovalHistory := DevExpress.XtraBars.BarButtonItem{}
    SELF:standaloneBarDockControl_Main := DevExpress.XtraBars.StandaloneBarDockControl{}
    SELF:barDockControlTop := DevExpress.XtraBars.BarDockControl{}
    SELF:barDockControlBottom := DevExpress.XtraBars.BarDockControl{}
    SELF:barDockControlLeft := DevExpress.XtraBars.BarDockControl{}
    SELF:barDockControlRight := DevExpress.XtraBars.BarDockControl{}
    SELF:dockManager1 := DevExpress.XtraBars.Docking.DockManager{SELF:components}
    SELF:hideContainerLeft := DevExpress.XtraBars.Docking.AutoHideContainer{}
    SELF:DockPanelProgramsBar := DevExpress.XtraBars.Docking.DockPanel{}
    SELF:DockPanelProgramsBar_Container := DevExpress.XtraBars.Docking.ControlContainer{}
    SELF:splitContainerControl_CheckedLBC := DevExpress.XtraEditors.SplitContainerControl{}
    SELF:ReportsTabUserControl := System.Windows.Forms.TabControl{}
    SELF:tabPage1 := System.Windows.Forms.TabPage{}
    SELF:LBCReportsVessel := DevExpress.XtraEditors.ListBoxControl{}
    SELF:ContextMenuStripExportToExcel := System.Windows.Forms.ContextMenuStrip{SELF:components}
    SELF:ExportToExcelToolStripMenuItem := System.Windows.Forms.ToolStripMenuItem{}
    SELF:tabPage2 := System.Windows.Forms.TabPage{}
    SELF:LBCReportsOffice := DevExpress.XtraEditors.ListBoxControl{}
    SELF:TreeListVesselsReports := DevExpress.XtraTreeList.TreeList{}
    SELF:LBCVesselReports := DevExpress.XtraEditors.ListBoxControl{}
    SELF:splitMapForm := DevExpress.XtraEditors.SplitContainerControl{}
    SELF:panelControl_BingMaps := DevExpress.XtraEditors.PanelControl{}
    SELF:reportsImageList := System.Windows.Forms.ImageList{SELF:components}
    SELF:voyageTypeImgList := System.Windows.Forms.ImageList{SELF:components}
    SELF:galleryDropDown1 := DevExpress.XtraBars.Ribbon.GalleryDropDown{SELF:components}
    ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl_Main)):BeginInit()
    SELF:splitContainerControl_Main:SuspendLayout()
    ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl_LBC)):BeginInit()
    SELF:splitContainerControl_LBC:SuspendLayout()
    ((System.ComponentModel.ISupportInitialize)(SELF:TreeListVessels)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:barManager1)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:repositoryItemComboBox1)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:repositoryItemComboBox2)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:popupMenu1)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:dockManager1)):BeginInit()
    SELF:hideContainerLeft:SuspendLayout()
    SELF:DockPanelProgramsBar:SuspendLayout()
    ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl_CheckedLBC)):BeginInit()
    SELF:splitContainerControl_CheckedLBC:SuspendLayout()
    SELF:ReportsTabUserControl:SuspendLayout()
    SELF:tabPage1:SuspendLayout()
    ((System.ComponentModel.ISupportInitialize)(SELF:LBCReportsVessel)):BeginInit()
    SELF:ContextMenuStripExportToExcel:SuspendLayout()
    SELF:tabPage2:SuspendLayout()
    ((System.ComponentModel.ISupportInitialize)(SELF:LBCReportsOffice)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:TreeListVesselsReports)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:LBCVesselReports)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:splitMapForm)):BeginInit()
    SELF:splitMapForm:SuspendLayout()
    ((System.ComponentModel.ISupportInitialize)(SELF:panelControl_BingMaps)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:galleryDropDown1)):BeginInit()
    SELF:SuspendLayout()
    // 
    // defaultLookAndFeel
    // 
    SELF:defaultLookAndFeel:LookAndFeel:SkinName := "The Asphalt World"
    // 
    // splitContainerControl_Main
    // 
    SELF:splitContainerControl_Main:BorderStyle := DevExpress.XtraEditors.Controls.BorderStyles.Simple
    SELF:splitContainerControl_Main:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:splitContainerControl_Main:Location := System.Drawing.Point{23, 0}
    SELF:splitContainerControl_Main:Name := "splitContainerControl_Main"
    SELF:splitContainerControl_Main:Panel1:Controls:Add(SELF:splitContainerControl_LBC)
    SELF:splitContainerControl_Main:Panel1:Text := "Panel1"
    SELF:splitContainerControl_Main:Panel2:Controls:Add(SELF:splitMapForm)
    SELF:splitContainerControl_Main:Panel2:Controls:Add(SELF:standaloneBarDockControl_Main)
    SELF:splitContainerControl_Main:Panel2:Text := "Panel2"
    SELF:splitContainerControl_Main:Size := System.Drawing.Size{1421, 641}
    SELF:splitContainerControl_Main:SplitterPosition := 463
    SELF:splitContainerControl_Main:TabIndex := 0
    SELF:splitContainerControl_Main:Text := "splitContainerControl1"
    // 
    // splitContainerControl_LBC
    // 
    SELF:splitContainerControl_LBC:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:splitContainerControl_LBC:Horizontal := false
    SELF:splitContainerControl_LBC:Location := System.Drawing.Point{0, 0}
    SELF:splitContainerControl_LBC:Name := "splitContainerControl_LBC"
    SELF:splitContainerControl_LBC:Panel1:Controls:Add(SELF:TreeListVessels)
    SELF:splitContainerControl_LBC:Panel1:Controls:Add(SELF:standaloneBarDockControl_Vessels)
    SELF:splitContainerControl_LBC:Panel1:Text := "Panel1"
    SELF:splitContainerControl_LBC:Panel2:Controls:Add(SELF:splitContainerControl_CheckedLBC)
    SELF:splitContainerControl_LBC:Panel2:Text := "Panel2"
    SELF:splitContainerControl_LBC:Size := System.Drawing.Size{463, 637}
    SELF:splitContainerControl_LBC:SplitterPosition := 178
    SELF:splitContainerControl_LBC:TabIndex := 0
    SELF:splitContainerControl_LBC:Text := "splitContainerControl1"
    // 
    // TreeListVessels
    // 
    SELF:TreeListVessels:Appearance:FocusedCell:BackColor := System.Drawing.Color.RoyalBlue
    SELF:TreeListVessels:Appearance:FocusedCell:ForeColor := System.Drawing.Color.White
    SELF:TreeListVessels:Appearance:FocusedCell:Options:UseBackColor := true
    SELF:TreeListVessels:Appearance:FocusedCell:Options:UseForeColor := true
    SELF:TreeListVessels:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:TreeListVessels:Location := System.Drawing.Point{0, 26}
    SELF:TreeListVessels:Name := "TreeListVessels"
    SELF:TreeListVessels:OptionsView:ShowCheckBoxes := true
    SELF:TreeListVessels:OptionsView:ShowColumns := false
    SELF:TreeListVessels:OptionsView:ShowHorzLines := false
    SELF:TreeListVessels:OptionsView:ShowIndicator := false
    SELF:TreeListVessels:Size := System.Drawing.Size{463, 152}
    SELF:TreeListVessels:TabIndex := 52
    SELF:TreeListVessels:BeforeCheckNode += DevExpress.XtraTreeList.CheckNodeEventHandler{ SELF, @TreeListVessels_BeforeCheckNode() }
    SELF:TreeListVessels:AfterCheckNode += DevExpress.XtraTreeList.NodeEventHandler{ SELF, @TreeListVessels_AfterCheckNode() }
    SELF:TreeListVessels:FocusedNodeChanged += DevExpress.XtraTreeList.FocusedNodeChangedEventHandler{ SELF, @TreeListVessels_FocusedNodeChanged() }
    SELF:TreeListVessels:Click += System.EventHandler{ SELF, @TreeListVessels_Click() }
    // 
    // standaloneBarDockControl_Vessels
    // 
    SELF:standaloneBarDockControl_Vessels:CausesValidation := false
    SELF:standaloneBarDockControl_Vessels:Dock := System.Windows.Forms.DockStyle.Top
    SELF:standaloneBarDockControl_Vessels:Location := System.Drawing.Point{0, 0}
    SELF:standaloneBarDockControl_Vessels:Manager := SELF:barManager1
    SELF:standaloneBarDockControl_Vessels:Name := "standaloneBarDockControl_Vessels"
    SELF:standaloneBarDockControl_Vessels:Size := System.Drawing.Size{463, 26}
    SELF:standaloneBarDockControl_Vessels:Text := "standaloneBarDockControl1"
    // 
    // barManager1
    // 
    SELF:barManager1:Bars:AddRange(<DevExpress.XtraBars.Bar>{ SELF:BarVessels, SELF:BarStatus, SELF:BarVesselReports, SELF:barMain })
    SELF:barManager1:DockControls:Add(SELF:barDockControlTop)
    SELF:barManager1:DockControls:Add(SELF:barDockControlBottom)
    SELF:barManager1:DockControls:Add(SELF:barDockControlLeft)
    SELF:barManager1:DockControls:Add(SELF:barDockControlRight)
    SELF:barManager1:DockControls:Add(SELF:standaloneBarDockControl_Vessels)
    SELF:barManager1:DockControls:Add(SELF:standaloneBarDockControl_VesselReports)
    SELF:barManager1:DockControls:Add(SELF:standaloneBarDockControl_Main)
    SELF:barManager1:DockManager := SELF:dockManager1
    SELF:barManager1:Form := SELF
    SELF:barManager1:Items:AddRange(<DevExpress.XtraBars.BarItem>{ SELF:BBICheckAll, SELF:BBIShowOnMap, SELF:BBIShowTabForm, SELF:BBIShowMessage, SELF:BBIIsmForm, SELF:BBIImportExcelData, SELF:BBICreateExcelReport, SELF:BBIShowVoyageOnNewMap_Main, SELF:BBIReportDefinition, SELF:barEditItemPeriod, SELF:backBBI, SELF:BBIEditReport, SELF:BBISave, SELF:BBIDelete, SELF:barEditItemDisplayMap, SELF:BBIRefreshReports, SELF:MainBBIGlobal, SELF:BBICreateReport, SELF:BBIFinalize, SELF:printButton, SELF:BBICancel, SELF:BBIAppove, SELF:BBISubmit, SELF:BBSIStatus, SELF:BBIMyApprovals, SELF:BBIReturn, SELF:barButtonItem2, SELF:barButtonItem3, SELF:BBITableReports, SELF:BBISamosReports, SELF:barButtonItem1, SELF:barButtonItem4, SELF:barButtonItem5, SELF:barButtonItem6, SELF:barButtonItem7, SELF:BBIAppovalHistory, SELF:barButtonItemMRVReport, SELF:bbiAlerts, SELF:bbiNewVoyage })
    SELF:barManager1:MainMenu := SELF:BarVessels
    SELF:barManager1:MaxItemId := 43
    SELF:barManager1:RepositoryItems:AddRange(<DevExpress.XtraEditors.Repository.RepositoryItem>{ SELF:repositoryItemComboBox2, SELF:repositoryItemComboBox1 })
    SELF:barManager1:StatusBar := SELF:BarStatus
    // 
    // BarVessels
    // 
    SELF:BarVessels:BarName := "Main menu"
    SELF:BarVessels:DockCol := 0
    SELF:BarVessels:DockRow := 0
    SELF:BarVessels:DockStyle := DevExpress.XtraBars.BarDockStyle.Standalone
    SELF:BarVessels:FloatLocation := System.Drawing.Point{482, 366}
    SELF:BarVessels:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:BBICheckAll}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIShowOnMap}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIImportExcelData}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIRefreshReports}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIMyApprovals}, DevExpress.XtraBars.LinkPersistInfo{SELF:MainBBIGlobal}, DevExpress.XtraBars.LinkPersistInfo{SELF:barEditItemDisplayMap}, DevExpress.XtraBars.LinkPersistInfo{DevExpress.XtraBars.BarLinkUserDefines.KeyTip, SELF:bbiAlerts, "", false, true, true, 0, NULL, DevExpress.XtraBars.BarItemPaintStyle.Standard, "SETUP ALERTS FOR USER", ""} })
    SELF:BarVessels:OptionsBar:AllowQuickCustomization := false
    SELF:BarVessels:OptionsBar:UseWholeRow := true
    SELF:BarVessels:StandaloneBarDockControl := SELF:standaloneBarDockControl_Vessels
    SELF:BarVessels:Text := "Main menu"
    // 
    // BBICheckAll
    // 
    SELF:BBICheckAll:Caption := "Check all"
    SELF:BBICheckAll:Id := 0
    SELF:BBICheckAll:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBICheckAll.ImageOptions.Image")))
    SELF:BBICheckAll:Name := "BBICheckAll"
    toolTipTitleItem41:Text := "Check all"
    toolTipItem25:LeftIndent := 6
    toolTipItem25:Text := "Check (select) all Vessels"
    superToolTip41:Items:Add(toolTipTitleItem41)
    superToolTip41:Items:Add(toolTipItem25)
    SELF:BBICheckAll:SuperTip := superToolTip41
    SELF:BBICheckAll:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:BBICheckAll:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBICheckAll_ItemClick() }
    // 
    // BBIShowOnMap
    // 
    SELF:BBIShowOnMap:Caption := "Show on Map"
    SELF:BBIShowOnMap:Id := 1
    SELF:BBIShowOnMap:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIShowOnMap.ImageOptions.Image")))
    SELF:BBIShowOnMap:Name := "BBIShowOnMap"
    toolTipTitleItem42:Text := "Show on Map"
    toolTipItem26:LeftIndent := 6
    toolTipItem26:Text := "Show selected Vessels on Map for the highlighted Report"
    superToolTip42:Items:Add(toolTipTitleItem42)
    superToolTip42:Items:Add(toolTipItem26)
    SELF:BBIShowOnMap:SuperTip := superToolTip42
    SELF:BBIShowOnMap:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIRefresh_ItemClick() }
    // 
    // BBIImportExcelData
    // 
    SELF:BBIImportExcelData:Caption := "Import Excel Data/(Vamvaship only)"
    SELF:BBIImportExcelData:Id := 5
    SELF:BBIImportExcelData:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIImportExcelData.ImageOptions.Image")))
    SELF:BBIImportExcelData:Name := "BBIImportExcelData"
    toolTipTitleItem43:Text := "Import Excel Data"
    toolTipItem27:LeftIndent := 6
    toolTipItem27:Text := "(Vamvaship only)"
    superToolTip43:Items:Add(toolTipTitleItem43)
    superToolTip43:Items:Add(toolTipItem27)
    SELF:BBIImportExcelData:SuperTip := superToolTip43
    SELF:BBIImportExcelData:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIImportExcelData_ItemClick() }
    // 
    // BBIRefreshReports
    // 
    SELF:BBIRefreshReports:Caption := "User Rights Setup"
    SELF:BBIRefreshReports:Id := 17
    SELF:BBIRefreshReports:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIRefreshReports.ImageOptions.Image")))
    SELF:BBIRefreshReports:Name := "BBIRefreshReports"
    toolTipTitleItem44:Text := "User Groups Setup"
    superToolTip44:Items:Add(toolTipTitleItem44)
    SELF:BBIRefreshReports:SuperTip := superToolTip44
    SELF:BBIRefreshReports:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIRefreshReports_ItemClick() }
    // 
    // BBIMyApprovals
    // 
    SELF:BBIMyApprovals:Caption := "My Approvals"
    SELF:BBIMyApprovals:Id := 28
    SELF:BBIMyApprovals:Name := "BBIMyApprovals"
    SELF:BBIMyApprovals:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @barButtonItem2_ItemClick() }
    // 
    // MainBBIGlobal
    // 
    SELF:MainBBIGlobal:Caption := "Settings"
    SELF:MainBBIGlobal:Id := 20
    SELF:MainBBIGlobal:ItemAppearance:Normal:Font := System.Drawing.Font{"Tahoma", 8.25, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((BYTE)(161))}
    SELF:MainBBIGlobal:ItemAppearance:Normal:Options:UseFont := true
    SELF:MainBBIGlobal:Name := "MainBBIGlobal"
    SELF:MainBBIGlobal:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @MainBBIGlobal_ItemClick() }
    // 
    // barEditItemDisplayMap
    // 
    SELF:barEditItemDisplayMap:Caption := "Map Display"
    SELF:barEditItemDisplayMap:Edit := SELF:repositoryItemComboBox1
    SELF:barEditItemDisplayMap:EditValue := "Map Display"
    SELF:barEditItemDisplayMap:EditWidth := 80
    SELF:barEditItemDisplayMap:Id := 16
    SELF:barEditItemDisplayMap:Name := "barEditItemDisplayMap"
    SELF:barEditItemDisplayMap:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:barEditItemDisplayMap:EditValueChanged += System.EventHandler{ SELF, @barEditItemDisplay_EditValueChanged() }
    SELF:barEditItemDisplayMap:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @barEditItemDisplay_ItemClick() }
    // 
    // repositoryItemComboBox1
    // 
    SELF:repositoryItemComboBox1:AutoHeight := false
    SELF:repositoryItemComboBox1:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{DevExpress.XtraEditors.Controls.ButtonPredefines.Combo} })
    SELF:repositoryItemComboBox1:Items:AddRange(<OBJECT>{ "100%", "75%", "50%", "25%", "0%" })
    SELF:repositoryItemComboBox1:Name := "repositoryItemComboBox1"
    SELF:repositoryItemComboBox1:TextEditStyle := DevExpress.XtraEditors.Controls.TextEditStyles.DisableTextEditor
    // 
    // bbiAlerts
    // 
    SELF:bbiAlerts:Caption := "Setup Alerts"
    SELF:bbiAlerts:Id := 41
    SELF:bbiAlerts:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("bbiAlerts.ImageOptions.Image")))
    SELF:bbiAlerts:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("bbiAlerts.ImageOptions.LargeImage")))
    SELF:bbiAlerts:Name := "bbiAlerts"
    SELF:bbiAlerts:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @bbiAlerts_ItemClick() }
    // 
    // BarStatus
    // 
    SELF:BarStatus:BarName := "Status bar"
    SELF:BarStatus:CanDockStyle := DevExpress.XtraBars.BarCanDockStyle.Bottom
    SELF:BarStatus:DockCol := 0
    SELF:BarStatus:DockRow := 0
    SELF:BarStatus:DockStyle := DevExpress.XtraBars.BarDockStyle.Bottom
    SELF:BarStatus:OptionsBar:AllowQuickCustomization := false
    SELF:BarStatus:OptionsBar:DrawDragBorder := false
    SELF:BarStatus:OptionsBar:UseWholeRow := true
    SELF:BarStatus:Text := "Status bar"
    // 
    // BarVesselReports
    // 
    SELF:BarVesselReports:BarName := "Bar Vessel Reports"
    SELF:BarVesselReports:CanDockStyle := DevExpress.XtraBars.BarCanDockStyle.Standalone
    SELF:BarVesselReports:DockCol := 0
    SELF:BarVesselReports:DockRow := 0
    SELF:BarVesselReports:DockStyle := DevExpress.XtraBars.BarDockStyle.Standalone
    SELF:BarVesselReports:FloatLocation := System.Drawing.Point{681, 695}
    SELF:BarVesselReports:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:backBBI}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIShowMessage}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIShowTabForm}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIIsmForm}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBICreateExcelReport}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBITableReports}, DevExpress.XtraBars.LinkPersistInfo{SELF:barEditItemPeriod}, DevExpress.XtraBars.LinkPersistInfo{SELF:bbiNewVoyage} })
    SELF:BarVesselReports:OptionsBar:AllowQuickCustomization := false
    SELF:BarVesselReports:OptionsBar:UseWholeRow := true
    SELF:BarVesselReports:StandaloneBarDockControl := SELF:standaloneBarDockControl_VesselReports
    SELF:BarVesselReports:Text := "Bar Vessel Reports"
    // 
    // backBBI
    // 
    SELF:backBBI:Caption := "Go Back"
    SELF:backBBI:Enabled := false
    SELF:backBBI:Id := 9
    SELF:backBBI:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("backBBI.ImageOptions.Image")))
    SELF:backBBI:Name := "backBBI"
    SELF:backBBI:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @backBBI_ItemClick() }
    // 
    // BBIShowMessage
    // 
    SELF:BBIShowMessage:Caption := "Show linked message"
    SELF:BBIShowMessage:Id := 3
    SELF:BBIShowMessage:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIShowMessage.ImageOptions.Image")))
    SELF:BBIShowMessage:Name := "BBIShowMessage"
    toolTipTitleItem45:Text := "Show linked message"
    toolTipItem28:LeftIndent := 6
    toolTipItem28:Text := "Switch to Communicator and show the linked message"
    superToolTip45:Items:Add(toolTipTitleItem45)
    superToolTip45:Items:Add(toolTipItem28)
    SELF:BBIShowMessage:SuperTip := superToolTip45
    SELF:BBIShowMessage:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIShowMessage_ItemClick() }
    // 
    // BBIShowTabForm
    // 
    SELF:BBIShowTabForm:Caption := "Show Report Form"
    SELF:BBIShowTabForm:Id := 2
    SELF:BBIShowTabForm:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIShowTabForm.ImageOptions.Image")))
    SELF:BBIShowTabForm:Name := "BBIShowTabForm"
    toolTipTitleItem46:Text := "Show Report Form"
    superToolTip46:Items:Add(toolTipTitleItem46)
    SELF:BBIShowTabForm:SuperTip := superToolTip46
    SELF:BBIShowTabForm:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIShowTabForm_ItemClick() }
    // 
    // BBIIsmForm
    // 
    SELF:BBIIsmForm:Caption := "ISM Form"
    SELF:BBIIsmForm:Id := 4
    SELF:BBIIsmForm:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIIsmForm.ImageOptions.Image")))
    SELF:BBIIsmForm:Name := "BBIIsmForm"
    toolTipTitleItem47:Text := e"Show message Body\r\n"
    superToolTip47:Items:Add(toolTipTitleItem47)
    SELF:BBIIsmForm:SuperTip := superToolTip47
    SELF:BBIIsmForm:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIIsmForm_ItemClick() }
    // 
    // BBICreateExcelReport
    // 
    SELF:BBICreateExcelReport:Caption := "Create Excel Report"
    SELF:BBICreateExcelReport:Id := 6
    SELF:BBICreateExcelReport:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBICreateExcelReport.ImageOptions.Image")))
    SELF:BBICreateExcelReport:Name := "BBICreateExcelReport"
    toolTipTitleItem48:Text := "Create Excel Report"
    toolTipItem29:LeftIndent := 6
    toolTipItem29:Text := "Export Items to Excel file"
    superToolTip48:Items:Add(toolTipTitleItem48)
    superToolTip48:Items:Add(toolTipItem29)
    SELF:BBICreateExcelReport:SuperTip := superToolTip48
    SELF:BBICreateExcelReport:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBICreateExcelReport_ItemClick() }
    // 
    // BBITableReports
    // 
    SELF:BBITableReports:Caption := "TR"
    SELF:BBITableReports:Id := 32
    SELF:BBITableReports:Name := "BBITableReports"
    SELF:BBITableReports:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:BBITableReports:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBITableReports_ItemClick() }
    // 
    // barEditItemPeriod
    // 
    SELF:barEditItemPeriod:Caption := "Customized view: Click to open the ComboBox and select"
    SELF:barEditItemPeriod:Edit := SELF:repositoryItemComboBox2
    SELF:barEditItemPeriod:EditValue := "Last 6 Months"
    SELF:barEditItemPeriod:EditWidth := 120
    SELF:barEditItemPeriod:Id := 8
    SELF:barEditItemPeriod:Name := "barEditItemPeriod"
    SELF:barEditItemPeriod:EditValueChanged += System.EventHandler{ SELF, @barEditItemPeriod_EditValueChanged() }
    // 
    // repositoryItemComboBox2
    // 
    SELF:repositoryItemComboBox2:Appearance:BackColor := System.Drawing.Color.FromArgb(((INT)(((BYTE)(192)))), ((INT)(((BYTE)(255)))), ((INT)(((BYTE)(255)))))
    SELF:repositoryItemComboBox2:Appearance:Options:UseBackColor := true
    SELF:repositoryItemComboBox2:AutoHeight := false
    SELF:repositoryItemComboBox2:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{DevExpress.XtraEditors.Controls.ButtonPredefines.Combo} })
    SELF:repositoryItemComboBox2:Items:AddRange(<OBJECT>{ "Last 6 Months", "Voyage routing", "Specific date period" })
    SELF:repositoryItemComboBox2:Name := "repositoryItemComboBox2"
    SELF:repositoryItemComboBox2:TextEditStyle := DevExpress.XtraEditors.Controls.TextEditStyles.DisableTextEditor
    // 
    // bbiNewVoyage
    // 
    SELF:bbiNewVoyage:Caption := "Add New Voyage"
    SELF:bbiNewVoyage:Id := 42
    SELF:bbiNewVoyage:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("bbiNewVoyage.ImageOptions.Image")))
    SELF:bbiNewVoyage:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("bbiNewVoyage.ImageOptions.LargeImage")))
    SELF:bbiNewVoyage:Name := "bbiNewVoyage"
    SELF:bbiNewVoyage:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @bbiNewVoyage_ItemClick() }
    // 
    // standaloneBarDockControl_VesselReports
    // 
    SELF:standaloneBarDockControl_VesselReports:CausesValidation := false
    SELF:standaloneBarDockControl_VesselReports:Dock := System.Windows.Forms.DockStyle.Top
    SELF:standaloneBarDockControl_VesselReports:Location := System.Drawing.Point{0, 0}
    SELF:standaloneBarDockControl_VesselReports:Manager := SELF:barManager1
    SELF:standaloneBarDockControl_VesselReports:Name := "standaloneBarDockControl_VesselReports"
    SELF:standaloneBarDockControl_VesselReports:Size := System.Drawing.Size{463, 26}
    SELF:standaloneBarDockControl_VesselReports:Text := "standaloneBarDockControl2"
    // 
    // barMain
    // 
    SELF:barMain:BarName := "Main Bar"
    SELF:barMain:CanDockStyle := DevExpress.XtraBars.BarCanDockStyle.Standalone
    SELF:barMain:DockCol := 0
    SELF:barMain:DockRow := 0
    SELF:barMain:DockStyle := DevExpress.XtraBars.BarDockStyle.Standalone
    SELF:barMain:FloatLocation := System.Drawing.Point{745, 197}
    SELF:barMain:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:BBISamosReports, true}, DevExpress.XtraBars.LinkPersistInfo{DevExpress.XtraBars.BarLinkUserDefines.PaintStyle, SELF:BBIReportDefinition, DevExpress.XtraBars.BarItemPaintStyle.CaptionGlyph}, DevExpress.XtraBars.LinkPersistInfo{DevExpress.XtraBars.BarLinkUserDefines.PaintStyle, SELF:BBIShowVoyageOnNewMap_Main, DevExpress.XtraBars.BarItemPaintStyle.CaptionGlyph}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBICreateReport}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIEditReport}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBICancel}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBISave}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIFinalize}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBISubmit}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIReturn}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIAppove}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIDelete}, DevExpress.XtraBars.LinkPersistInfo{SELF:printButton}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBSIStatus}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIAppovalHistory} })
    SELF:barMain:OptionsBar:AllowQuickCustomization := false
    SELF:barMain:OptionsBar:DisableClose := true
    SELF:barMain:OptionsBar:DisableCustomization := true
    SELF:barMain:OptionsBar:UseWholeRow := true
    SELF:barMain:StandaloneBarDockControl := SELF:standaloneBarDockControl_Main
    SELF:barMain:Text := "Main Bar"
    // 
    // BBISamosReports
    // 
    SELF:BBISamosReports:Caption := "Reports"
    SELF:BBISamosReports:Id := 33
    SELF:BBISamosReports:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:barButtonItem1}, DevExpress.XtraBars.LinkPersistInfo{SELF:barButtonItem4}, DevExpress.XtraBars.LinkPersistInfo{SELF:barButtonItem5}, DevExpress.XtraBars.LinkPersistInfo{SELF:barButtonItem6}, DevExpress.XtraBars.LinkPersistInfo{SELF:barButtonItem7}, DevExpress.XtraBars.LinkPersistInfo{SELF:barButtonItemMRVReport} })
    SELF:BBISamosReports:Name := "BBISamosReports"
    // 
    // barButtonItem1
    // 
    SELF:barButtonItem1:Caption := "Findings Report : Dry"
    SELF:barButtonItem1:Id := 34
    SELF:barButtonItem1:Name := "barButtonItem1"
    SELF:barButtonItem1:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @DryBarButton_ItemClick() }
    // 
    // barButtonItem4
    // 
    SELF:barButtonItem4:Caption := "Findings Report : Wet"
    SELF:barButtonItem4:Id := 35
    SELF:barButtonItem4:Name := "barButtonItem4"
    SELF:barButtonItem4:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @WetBBI_ItemClick() }
    // 
    // barButtonItem5
    // 
    SELF:barButtonItem5:Caption := "Findings Report per Role : Dry"
    SELF:barButtonItem5:Id := 36
    SELF:barButtonItem5:Name := "barButtonItem5"
    SELF:barButtonItem5:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @PerRoleDry_ItemClick() }
    // 
    // barButtonItem6
    // 
    SELF:barButtonItem6:Caption := "Findings Report per Role : Wet"
    SELF:barButtonItem6:Id := 37
    SELF:barButtonItem6:Name := "barButtonItem6"
    SELF:barButtonItem6:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @PerRoleWet_ItemClick() }
    // 
    // barButtonItem7
    // 
    SELF:barButtonItem7:Caption := "Finding Report Per Role : All Fleet"
    SELF:barButtonItem7:Id := 38
    SELF:barButtonItem7:Name := "barButtonItem7"
    SELF:barButtonItem7:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @PerRoleAllFleet_ItemClick() }
    // 
    // barButtonItemMRVReport
    // 
    SELF:barButtonItemMRVReport:Caption := "MRV Report"
    SELF:barButtonItemMRVReport:Id := 40
    SELF:barButtonItemMRVReport:Name := "barButtonItemMRVReport"
    SELF:barButtonItemMRVReport:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @barButtonItemMRVReport_ItemClick() }
    // 
    // BBIReportDefinition
    // 
    SELF:BBIReportDefinition:Caption := "Custom Reports"
    SELF:BBIReportDefinition:Id := 7
    SELF:BBIReportDefinition:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIReportDefinition.ImageOptions.Image")))
    SELF:BBIReportDefinition:Name := "BBIReportDefinition"
    toolTipTitleItem49:Text := "Custom Reports"
    toolTipItem30:LeftIndent := 6
    toolTipItem30:Text := "Custom Reports Definition and execution"
    superToolTip49:Items:Add(toolTipTitleItem49)
    superToolTip49:Items:Add(toolTipItem30)
    SELF:BBIReportDefinition:SuperTip := superToolTip49
    SELF:BBIReportDefinition:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:BBIReportDefinition:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIReportDefinition_ItemClick() }
    // 
    // BBIShowVoyageOnNewMap_Main
    // 
    SELF:BBIShowVoyageOnNewMap_Main:Caption := "Voyage"
    SELF:BBIShowVoyageOnNewMap_Main:Id := 14
    SELF:BBIShowVoyageOnNewMap_Main:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIShowVoyageOnNewMap_Main.ImageOptions.Image")))
    SELF:BBIShowVoyageOnNewMap_Main:Name := "BBIShowVoyageOnNewMap_Main"
    toolTipTitleItem50:Text := e"Show selected Voyage routing on a new full functional Map\r\n"
    superToolTip50:Items:Add(toolTipTitleItem50)
    SELF:BBIShowVoyageOnNewMap_Main:SuperTip := superToolTip50
    SELF:BBIShowVoyageOnNewMap_Main:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:BBIShowVoyageOnNewMap_Main:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIShowVoyageOnNewMap_Main_ItemClick() }
    // 
    // BBICreateReport
    // 
    SELF:BBICreateReport:Caption := "New Report"
    SELF:BBICreateReport:Id := 21
    SELF:BBICreateReport:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBICreateReport.ImageOptions.Image")))
    SELF:BBICreateReport:Name := "BBICreateReport"
    SELF:BBICreateReport:PaintStyle := DevExpress.XtraBars.BarItemPaintStyle.CaptionGlyph
    SELF:BBICreateReport:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:BBICreateReport:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBICreateReport_ItemClick() }
    // 
    // BBIEditReport
    // 
    SELF:BBIEditReport:Caption := "Edit Report"
    SELF:BBIEditReport:Enabled := false
    SELF:BBIEditReport:Id := 10
    SELF:BBIEditReport:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIEditReport.ImageOptions.Image")))
    SELF:BBIEditReport:ItemAppearance:Normal:ForeColor := System.Drawing.Color.Black
    SELF:BBIEditReport:ItemAppearance:Normal:Options:UseForeColor := true
    SELF:BBIEditReport:Name := "BBIEditReport"
    SELF:BBIEditReport:PaintStyle := DevExpress.XtraBars.BarItemPaintStyle.CaptionGlyph
    SELF:BBIEditReport:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:BBIEditReport:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIEditReport_ItemClick() }
    // 
    // BBICancel
    // 
    SELF:BBICancel:Caption := "Cancel"
    SELF:BBICancel:Enabled := false
    SELF:BBICancel:Id := 24
    SELF:BBICancel:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBICancel.ImageOptions.Image")))
    SELF:BBICancel:Name := "BBICancel"
    SELF:BBICancel:PaintStyle := DevExpress.XtraBars.BarItemPaintStyle.CaptionGlyph
    SELF:BBICancel:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:BBICancel:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBICancel_ItemClick() }
    // 
    // BBISave
    // 
    SELF:BBISave:Caption := "Save Report"
    SELF:BBISave:Enabled := false
    SELF:BBISave:Id := 11
    SELF:BBISave:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBISave.ImageOptions.Image")))
    SELF:BBISave:ItemAppearance:Normal:ForeColor := System.Drawing.Color.Black
    SELF:BBISave:ItemAppearance:Normal:Options:UseForeColor := true
    SELF:BBISave:Name := "BBISave"
    SELF:BBISave:PaintStyle := DevExpress.XtraBars.BarItemPaintStyle.CaptionGlyph
    SELF:BBISave:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:BBISave:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBISave_ItemClick() }
    // 
    // BBIFinalize
    // 
    SELF:BBIFinalize:Caption := "Finalize"
    SELF:BBIFinalize:Enabled := false
    SELF:BBIFinalize:Id := 22
    SELF:BBIFinalize:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIFinalize.ImageOptions.Image")))
    SELF:BBIFinalize:Name := "BBIFinalize"
    SELF:BBIFinalize:PaintStyle := DevExpress.XtraBars.BarItemPaintStyle.CaptionGlyph
    SELF:BBIFinalize:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:BBIFinalize:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIFinalize_ItemClick() }
    // 
    // BBISubmit
    // 
    SELF:BBISubmit:Caption := "Submit"
    SELF:BBISubmit:Id := 26
    SELF:BBISubmit:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBISubmit.ImageOptions.Image")))
    SELF:BBISubmit:Name := "BBISubmit"
    SELF:BBISubmit:PaintStyle := DevExpress.XtraBars.BarItemPaintStyle.CaptionGlyph
    SELF:BBISubmit:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:BBISubmit:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBISubmit_ItemClick() }
    // 
    // BBIReturn
    // 
    SELF:BBIReturn:Caption := "Return To User"
    SELF:BBIReturn:Id := 29
    SELF:BBIReturn:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIReturn.ImageOptions.Image")))
    SELF:BBIReturn:Name := "BBIReturn"
    SELF:BBIReturn:PaintStyle := DevExpress.XtraBars.BarItemPaintStyle.CaptionGlyph
    SELF:BBIReturn:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:BBIReturn:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIReturn_ItemClick() }
    // 
    // BBIAppove
    // 
    SELF:BBIAppove:Caption := "Acknowledge"
    SELF:BBIAppove:Id := 25
    SELF:BBIAppove:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIAppove.ImageOptions.Image")))
    SELF:BBIAppove:Name := "BBIAppove"
    SELF:BBIAppove:PaintStyle := DevExpress.XtraBars.BarItemPaintStyle.CaptionGlyph
    SELF:BBIAppove:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:BBIAppove:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIAppove_ItemClick() }
    // 
    // BBIDelete
    // 
    SELF:BBIDelete:Caption := "Delete Report"
    SELF:BBIDelete:Enabled := false
    SELF:BBIDelete:Id := 12
    SELF:BBIDelete:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("BBIDelete.ImageOptions.Image")))
    SELF:BBIDelete:Name := "BBIDelete"
    SELF:BBIDelete:PaintStyle := DevExpress.XtraBars.BarItemPaintStyle.CaptionGlyph
    SELF:BBIDelete:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:BBIDelete:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIDelete_ItemClick() }
    // 
    // printButton
    // 
    SELF:printButton:ActAsDropDown := true
    SELF:printButton:ButtonStyle := DevExpress.XtraBars.BarButtonStyle.DropDown
    SELF:printButton:Caption := "Print Report"
    SELF:printButton:DropDownControl := SELF:popupMenu1
    SELF:printButton:Id := 23
    SELF:printButton:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("printButton.ImageOptions.Image")))
    SELF:printButton:Name := "printButton"
    SELF:printButton:PaintStyle := DevExpress.XtraBars.BarItemPaintStyle.CaptionGlyph
    SELF:printButton:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:printButton:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @print_ItemClick() }
    // 
    // popupMenu1
    // 
    SELF:popupMenu1:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:barButtonItem2}, DevExpress.XtraBars.LinkPersistInfo{SELF:barButtonItem3} })
    SELF:popupMenu1:Manager := SELF:barManager1
    SELF:popupMenu1:Name := "popupMenu1"
    // 
    // barButtonItem2
    // 
    SELF:barButtonItem2:Caption := "Print From as Is"
    SELF:barButtonItem2:Id := 30
    SELF:barButtonItem2:Name := "barButtonItem2"
    SELF:barButtonItem2:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @barButtonItem2_ItemClick_1() }
    // 
    // barButtonItem3
    // 
    SELF:barButtonItem3:Caption := "Export to Excel"
    SELF:barButtonItem3:Id := 31
    SELF:barButtonItem3:Name := "barButtonItem3"
    SELF:barButtonItem3:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @barButtonItem3_ItemClick() }
    // 
    // BBSIStatus
    // 
    SELF:BBSIStatus:Caption := "Status :"
    SELF:BBSIStatus:Id := 27
    SELF:BBSIStatus:Name := "BBSIStatus"
    SELF:BBSIStatus:TextAlignment := System.Drawing.StringAlignment.Near
    SELF:BBSIStatus:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:BBSIStatus:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBSIStatus_ItemClick() }
    // 
    // BBIAppovalHistory
    // 
    SELF:BBIAppovalHistory:Caption := "Approval History"
    SELF:BBIAppovalHistory:Id := 39
    SELF:BBIAppovalHistory:Name := "BBIAppovalHistory"
    SELF:BBIAppovalHistory:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
    SELF:BBIAppovalHistory:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIAppovalHistory_ItemClick() }
    // 
    // standaloneBarDockControl_Main
    // 
    SELF:standaloneBarDockControl_Main:CausesValidation := false
    SELF:standaloneBarDockControl_Main:Dock := System.Windows.Forms.DockStyle.Top
    SELF:standaloneBarDockControl_Main:Location := System.Drawing.Point{0, 0}
    SELF:standaloneBarDockControl_Main:Manager := SELF:barManager1
    SELF:standaloneBarDockControl_Main:Name := "standaloneBarDockControl_Main"
    SELF:standaloneBarDockControl_Main:Size := System.Drawing.Size{948, 26}
    SELF:standaloneBarDockControl_Main:Text := "standaloneBarDockControl2"
    // 
    // barDockControlTop
    // 
    SELF:barDockControlTop:CausesValidation := false
    SELF:barDockControlTop:Dock := System.Windows.Forms.DockStyle.Top
    SELF:barDockControlTop:Location := System.Drawing.Point{0, 0}
    SELF:barDockControlTop:Manager := SELF:barManager1
    SELF:barDockControlTop:Size := System.Drawing.Size{1444, 0}
    // 
    // barDockControlBottom
    // 
    SELF:barDockControlBottom:CausesValidation := false
    SELF:barDockControlBottom:Dock := System.Windows.Forms.DockStyle.Bottom
    SELF:barDockControlBottom:Location := System.Drawing.Point{0, 641}
    SELF:barDockControlBottom:Manager := SELF:barManager1
    SELF:barDockControlBottom:Size := System.Drawing.Size{1444, 22}
    // 
    // barDockControlLeft
    // 
    SELF:barDockControlLeft:CausesValidation := false
    SELF:barDockControlLeft:Dock := System.Windows.Forms.DockStyle.Left
    SELF:barDockControlLeft:Location := System.Drawing.Point{0, 0}
    SELF:barDockControlLeft:Manager := SELF:barManager1
    SELF:barDockControlLeft:Size := System.Drawing.Size{0, 641}
    // 
    // barDockControlRight
    // 
    SELF:barDockControlRight:CausesValidation := false
    SELF:barDockControlRight:Dock := System.Windows.Forms.DockStyle.Right
    SELF:barDockControlRight:Location := System.Drawing.Point{1444, 0}
    SELF:barDockControlRight:Manager := SELF:barManager1
    SELF:barDockControlRight:Size := System.Drawing.Size{0, 641}
    // 
    // dockManager1
    // 
    SELF:dockManager1:AutoHideContainers:AddRange(<DevExpress.XtraBars.Docking.AutoHideContainer>{ SELF:hideContainerLeft })
    SELF:dockManager1:Form := SELF
    SELF:dockManager1:MenuManager := SELF:barManager1
    SELF:dockManager1:TopZIndexControls:AddRange(<STRING>{ "DevExpress.XtraBars.BarDockControl", "DevExpress.XtraBars.StandaloneBarDockControl", "System.Windows.Forms.StatusBar", "DevExpress.XtraBars.Ribbon.RibbonStatusBar", "DevExpress.XtraBars.Ribbon.RibbonControl" })
    // 
    // hideContainerLeft
    // 
    SELF:hideContainerLeft:BackColor := System.Drawing.Color.FromArgb(((INT)(((BYTE)(253)))), ((INT)(((BYTE)(253)))), ((INT)(((BYTE)(253)))))
    SELF:hideContainerLeft:Controls:Add(SELF:DockPanelProgramsBar)
    SELF:hideContainerLeft:Dock := System.Windows.Forms.DockStyle.Left
    SELF:hideContainerLeft:Location := System.Drawing.Point{0, 0}
    SELF:hideContainerLeft:Name := "hideContainerLeft"
    SELF:hideContainerLeft:Size := System.Drawing.Size{23, 641}
    // 
    // DockPanelProgramsBar
    // 
    SELF:DockPanelProgramsBar:Controls:Add(SELF:DockPanelProgramsBar_Container)
    SELF:DockPanelProgramsBar:Dock := DevExpress.XtraBars.Docking.DockingStyle.Left
    SELF:DockPanelProgramsBar:ID := System.Guid{"6ac01ea9-b4f1-425c-a3f7-193bfb25a763"}
    SELF:DockPanelProgramsBar:Location := System.Drawing.Point{0, 0}
    SELF:DockPanelProgramsBar:Name := "DockPanelProgramsBar"
    SELF:DockPanelProgramsBar:Options:ShowCloseButton := false
    SELF:DockPanelProgramsBar:OriginalSize := System.Drawing.Size{159, 200}
    SELF:DockPanelProgramsBar:SavedDock := DevExpress.XtraBars.Docking.DockingStyle.Left
    SELF:DockPanelProgramsBar:SavedIndex := 0
    SELF:DockPanelProgramsBar:Size := System.Drawing.Size{159, 641}
    SELF:DockPanelProgramsBar:Text := "Programs"
    SELF:DockPanelProgramsBar:Visibility := DevExpress.XtraBars.Docking.DockVisibility.AutoHide
    // 
    // DockPanelProgramsBar_Container
    // 
    SELF:DockPanelProgramsBar_Container:Location := System.Drawing.Point{3, 25}
    SELF:DockPanelProgramsBar_Container:Name := "DockPanelProgramsBar_Container"
    SELF:DockPanelProgramsBar_Container:Size := System.Drawing.Size{152, 613}
    SELF:DockPanelProgramsBar_Container:TabIndex := 0
    // 
    // splitContainerControl_CheckedLBC
    // 
    SELF:splitContainerControl_CheckedLBC:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:splitContainerControl_CheckedLBC:Horizontal := false
    SELF:splitContainerControl_CheckedLBC:Location := System.Drawing.Point{0, 0}
    SELF:splitContainerControl_CheckedLBC:Name := "splitContainerControl_CheckedLBC"
    SELF:splitContainerControl_CheckedLBC:Panel1:Controls:Add(SELF:ReportsTabUserControl)
    SELF:splitContainerControl_CheckedLBC:Panel1:Text := "Panel1"
    SELF:splitContainerControl_CheckedLBC:Panel2:Controls:Add(SELF:TreeListVesselsReports)
    SELF:splitContainerControl_CheckedLBC:Panel2:Controls:Add(SELF:LBCVesselReports)
    SELF:splitContainerControl_CheckedLBC:Panel2:Controls:Add(SELF:standaloneBarDockControl_VesselReports)
    SELF:splitContainerControl_CheckedLBC:Panel2:Text := "Panel2"
    SELF:splitContainerControl_CheckedLBC:Size := System.Drawing.Size{463, 453}
    SELF:splitContainerControl_CheckedLBC:SplitterPosition := 133
    SELF:splitContainerControl_CheckedLBC:TabIndex := 2
    SELF:splitContainerControl_CheckedLBC:Text := "splitContainerControl1"
    // 
    // ReportsTabUserControl
    // 
    SELF:ReportsTabUserControl:Controls:Add(SELF:tabPage1)
    SELF:ReportsTabUserControl:Controls:Add(SELF:tabPage2)
    SELF:ReportsTabUserControl:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:ReportsTabUserControl:Location := System.Drawing.Point{0, 0}
    SELF:ReportsTabUserControl:Name := "ReportsTabUserControl"
    SELF:ReportsTabUserControl:SelectedIndex := 0
    SELF:ReportsTabUserControl:Size := System.Drawing.Size{463, 133}
    SELF:ReportsTabUserControl:TabIndex := 1
    SELF:ReportsTabUserControl:SelectedIndexChanged += System.EventHandler{ SELF, @tabControl1_SelectedIndexChanged() }
    // 
    // tabPage1
    // 
    SELF:tabPage1:Controls:Add(SELF:LBCReportsVessel)
    SELF:tabPage1:Location := System.Drawing.Point{4, 22}
    SELF:tabPage1:Name := "tabPage1"
    SELF:tabPage1:Padding := System.Windows.Forms.Padding{3}
    SELF:tabPage1:Size := System.Drawing.Size{455, 107}
    SELF:tabPage1:TabIndex := 0
    SELF:tabPage1:Text := "Vessel Reports"
    SELF:tabPage1:UseVisualStyleBackColor := true
    // 
    // LBCReportsVessel
    // 
    SELF:LBCReportsVessel:Appearance:Font := System.Drawing.Font{"Lucida Console", 8.25}
    SELF:LBCReportsVessel:Appearance:Options:UseFont := true
    SELF:LBCReportsVessel:ContextMenuStrip := SELF:ContextMenuStripExportToExcel
    SELF:LBCReportsVessel:Cursor := System.Windows.Forms.Cursors.Default
    SELF:LBCReportsVessel:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:LBCReportsVessel:HorizontalScrollbar := true
    SELF:LBCReportsVessel:Location := System.Drawing.Point{3, 3}
    SELF:LBCReportsVessel:Name := "LBCReportsVessel"
    SELF:LBCReportsVessel:Size := System.Drawing.Size{449, 101}
    SELF:LBCReportsVessel:TabIndex := 0
    SELF:LBCReportsVessel:SelectedIndexChanged += System.EventHandler{ SELF, @LBCReports_SelectedIndexChanged() }
    SELF:LBCReportsVessel:DrawItem += DevExpress.XtraEditors.ListBoxDrawItemEventHandler{ SELF, @LBCReports_DrawItem() }
    // 
    // ContextMenuStripExportToExcel
    // 
    SELF:ContextMenuStripExportToExcel:Items:AddRange(<System.Windows.Forms.ToolStripItem>{ SELF:ExportToExcelToolStripMenuItem })
    SELF:ContextMenuStripExportToExcel:Name := "ContextMenuStripExportToExcel"
    SELF:ContextMenuStripExportToExcel:Size := System.Drawing.Size{191, 26}
    // 
    // ExportToExcelToolStripMenuItem
    // 
    SELF:ExportToExcelToolStripMenuItem:Name := "ExportToExcelToolStripMenuItem"
    SELF:ExportToExcelToolStripMenuItem:Size := System.Drawing.Size{190, 22}
    SELF:ExportToExcelToolStripMenuItem:Text := "Export Template Form"
    SELF:ExportToExcelToolStripMenuItem:Click += System.EventHandler{ SELF, @ExportToExcelToolStripMenuItem_Click() }
    // 
    // tabPage2
    // 
    SELF:tabPage2:Controls:Add(SELF:LBCReportsOffice)
    SELF:tabPage2:Location := System.Drawing.Point{4, 22}
    SELF:tabPage2:Name := "tabPage2"
    SELF:tabPage2:Padding := System.Windows.Forms.Padding{3}
    SELF:tabPage2:Size := System.Drawing.Size{455, 107}
    SELF:tabPage2:TabIndex := 1
    SELF:tabPage2:Text := "Office Reports"
    SELF:tabPage2:UseVisualStyleBackColor := true
    // 
    // LBCReportsOffice
    // 
    SELF:LBCReportsOffice:Appearance:Font := System.Drawing.Font{"Lucida Console", 8.25}
    SELF:LBCReportsOffice:Appearance:Options:UseFont := true
    SELF:LBCReportsOffice:ContextMenuStrip := SELF:ContextMenuStripExportToExcel
    SELF:LBCReportsOffice:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:LBCReportsOffice:HorizontalScrollbar := true
    SELF:LBCReportsOffice:Location := System.Drawing.Point{3, 3}
    SELF:LBCReportsOffice:Name := "LBCReportsOffice"
    SELF:LBCReportsOffice:Size := System.Drawing.Size{449, 101}
    SELF:LBCReportsOffice:TabIndex := 1
    SELF:LBCReportsOffice:SelectedIndexChanged += System.EventHandler{ SELF, @LBCReportsOffice_SelectedIndexChanged() }
    SELF:LBCReportsOffice:Enter += System.EventHandler{ SELF, @LBCReportsOffice_Enter() }
    // 
    // TreeListVesselsReports
    // 
    SELF:TreeListVesselsReports:Appearance:FocusedCell:BackColor := System.Drawing.Color.RoyalBlue
    SELF:TreeListVesselsReports:Appearance:FocusedCell:ForeColor := System.Drawing.Color.White
    SELF:TreeListVesselsReports:Appearance:FocusedCell:Options:UseBackColor := true
    SELF:TreeListVesselsReports:Appearance:FocusedCell:Options:UseForeColor := true
    SELF:TreeListVesselsReports:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:TreeListVesselsReports:Location := System.Drawing.Point{0, 26}
    SELF:TreeListVesselsReports:Name := "TreeListVesselsReports"
    SELF:TreeListVesselsReports:OptionsView:ShowColumns := false
    SELF:TreeListVesselsReports:OptionsView:ShowHorzLines := false
    SELF:TreeListVesselsReports:OptionsView:ShowIndicator := false
    SELF:TreeListVesselsReports:OptionsView:ShowVertLines := false
    SELF:TreeListVesselsReports:Size := System.Drawing.Size{463, 288}
    SELF:TreeListVesselsReports:TabIndex := 53
    SELF:TreeListVesselsReports:Visible := false
    SELF:TreeListVesselsReports:FocusedNodeChanged += DevExpress.XtraTreeList.FocusedNodeChangedEventHandler{ SELF, @TreeListVesselsReports_FocusedNodeChanged() }
    SELF:TreeListVesselsReports:DoubleClick += System.EventHandler{ SELF, @TreeListVesselsReports_DoubleClick() }
    // 
    // LBCVesselReports
    // 
    SELF:LBCVesselReports:Appearance:Font := System.Drawing.Font{"Lucida Console", 8.25}
    SELF:LBCVesselReports:Appearance:Options:UseFont := true
    SELF:LBCVesselReports:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:LBCVesselReports:HorizontalScrollbar := true
    SELF:LBCVesselReports:Location := System.Drawing.Point{0, 26}
    SELF:LBCVesselReports:Name := "LBCVesselReports"
    SELF:LBCVesselReports:Size := System.Drawing.Size{463, 288}
    SELF:LBCVesselReports:TabIndex := 1
    SELF:LBCVesselReports:DoubleClick += System.EventHandler{ SELF, @LBCVesselReports_DoubleClick() }
    // 
    // splitMapForm
    // 
    SELF:splitMapForm:AlwaysScrollActiveControlIntoView := false
    SELF:splitMapForm:BorderStyle := DevExpress.XtraEditors.Controls.BorderStyles.Style3D
    SELF:splitMapForm:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:splitMapForm:Location := System.Drawing.Point{0, 26}
    SELF:splitMapForm:Name := "splitMapForm"
    SELF:splitMapForm:Panel1:AutoScroll := true
    SELF:splitMapForm:Panel1:Tag := "1"
    SELF:splitMapForm:Panel1:Text := "Panel1"
    SELF:splitMapForm:Panel1:VisibleChanged += System.EventHandler{ SELF, @splitMapForm_Panel1_VisibleChanged() }
    SELF:splitMapForm:Panel2:AutoScroll := true
    SELF:splitMapForm:Panel2:BorderStyle := DevExpress.XtraEditors.Controls.BorderStyles.Style3D
    SELF:splitMapForm:Panel2:Controls:Add(SELF:panelControl_BingMaps)
    SELF:splitMapForm:Panel2:Tag := "2"
    SELF:splitMapForm:Panel2:Text := "Panel2"
    SELF:splitMapForm:Panel2:VisibleChanged += System.EventHandler{ SELF, @splitMapForm_Panel2_VisibleChanged() }
    SELF:splitMapForm:PanelVisibility := DevExpress.XtraEditors.SplitPanelVisibility.Panel2
    SELF:splitMapForm:Size := System.Drawing.Size{948, 611}
    SELF:splitMapForm:SplitterPosition := 0
    SELF:splitMapForm:TabIndex := 4
    SELF:splitMapForm:Text := "splitContainerControl1"
    SELF:splitMapForm:SplitterPositionChanged += System.EventHandler{ SELF, @splitMapForm_SplitterPositionChanged() }
    SELF:splitMapForm:SplitGroupPanelCollapsed += DevExpress.XtraEditors.SplitGroupPanelCollapsedEventHandler{ SELF, @splitMapForm_SplitGroupPanelCollapsed() }
    // 
    // panelControl_BingMaps
    // 
    SELF:panelControl_BingMaps:Dock := System.Windows.Forms.DockStyle.Fill
    SELF:panelControl_BingMaps:Location := System.Drawing.Point{0, 0}
    SELF:panelControl_BingMaps:Name := "panelControl_BingMaps"
    SELF:panelControl_BingMaps:Size := System.Drawing.Size{940, 603}
    SELF:panelControl_BingMaps:TabIndex := 2
    // 
    // reportsImageList
    // 
    SELF:reportsImageList:ImageStream := ((System.Windows.Forms.ImageListStreamer)(resources:GetObject("reportsImageList.ImageStream")))
    SELF:reportsImageList:TransparentColor := System.Drawing.Color.Transparent
    SELF:reportsImageList:Images:SetKeyName(0, "Past.png")
    SELF:reportsImageList:Images:SetKeyName(1, "InProgress.png")
    SELF:reportsImageList:Images:SetKeyName(2, "checkmark_comleted_tasks-16.png")
    SELF:reportsImageList:Images:SetKeyName(3, "Minus20x20.png")
    SELF:reportsImageList:Images:SetKeyName(4, "Check20x20.png")
    SELF:reportsImageList:Images:SetKeyName(5, "manager20.png")
    // 
    // voyageTypeImgList
    // 
    SELF:voyageTypeImgList:ImageStream := ((System.Windows.Forms.ImageListStreamer)(resources:GetObject("voyageTypeImgList.ImageStream")))
    SELF:voyageTypeImgList:TransparentColor := System.Drawing.Color.Transparent
    SELF:voyageTypeImgList:Images:SetKeyName(0, "Transportation_front_view-12-512.png")
    SELF:voyageTypeImgList:Images:SetKeyName(1, "time.png")
    SELF:voyageTypeImgList:Images:SetKeyName(2, "Minus20x20.png")
    SELF:voyageTypeImgList:Images:SetKeyName(3, "Check20x20.png")
    SELF:voyageTypeImgList:Images:SetKeyName(4, "manager20.png")
    // 
    // galleryDropDown1
    // 
    SELF:galleryDropDown1:Manager := SELF:barManager1
    SELF:galleryDropDown1:Name := "galleryDropDown1"
    // 
    // MainForm
    // 
    SELF:AutoScaleDimensions := System.Drawing.SizeF{96, 96}
    SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Dpi
    SELF:ClientSize := System.Drawing.Size{1444, 663}
    SELF:Controls:Add(SELF:splitContainerControl_Main)
    SELF:Controls:Add(SELF:hideContainerLeft)
    SELF:Controls:Add(SELF:barDockControlLeft)
    SELF:Controls:Add(SELF:barDockControlRight)
    SELF:Controls:Add(SELF:barDockControlBottom)
    SELF:Controls:Add(SELF:barDockControlTop)
    SELF:Icon := ((System.Drawing.Icon)(resources:GetObject("$this.Icon")))
    SELF:LookAndFeel:SkinName := "The Asphalt World"
    SELF:Name := "MainForm"
    SELF:Text := "Fleet Manager"
    SELF:FormClosing += System.Windows.Forms.FormClosingEventHandler{ SELF, @MainForm_FormClosing() }
    SELF:FormClosed += System.Windows.Forms.FormClosedEventHandler{ SELF, @MainForm_FormClosed() }
    SELF:Load += System.EventHandler{ SELF, @MainForm_Load() }
    SELF:Shown += System.EventHandler{ SELF, @MainForm_Shown() }
    ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl_Main)):EndInit()
    SELF:splitContainerControl_Main:ResumeLayout(false)
    ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl_LBC)):EndInit()
    SELF:splitContainerControl_LBC:ResumeLayout(false)
    ((System.ComponentModel.ISupportInitialize)(SELF:TreeListVessels)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:barManager1)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:repositoryItemComboBox1)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:repositoryItemComboBox2)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:popupMenu1)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:dockManager1)):EndInit()
    SELF:hideContainerLeft:ResumeLayout(false)
    SELF:DockPanelProgramsBar:ResumeLayout(false)
    ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl_CheckedLBC)):EndInit()
    SELF:splitContainerControl_CheckedLBC:ResumeLayout(false)
    SELF:ReportsTabUserControl:ResumeLayout(false)
    SELF:tabPage1:ResumeLayout(false)
    ((System.ComponentModel.ISupportInitialize)(SELF:LBCReportsVessel)):EndInit()
    SELF:ContextMenuStripExportToExcel:ResumeLayout(false)
    SELF:tabPage2:ResumeLayout(false)
    ((System.ComponentModel.ISupportInitialize)(SELF:LBCReportsOffice)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:TreeListVesselsReports)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:LBCVesselReports)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:splitMapForm)):EndInit()
    SELF:splitMapForm:ResumeLayout(false)
    ((System.ComponentModel.ISupportInitialize)(SELF:panelControl_BingMaps)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:galleryDropDown1)):EndInit()
    SELF:ResumeLayout(false)
    SELF:PerformLayout()
PRIVATE METHOD MainForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:MainForm_OnLoad()
        RETURN
PRIVATE METHOD MainForm_Shown( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:MainForm_OnShown()
        RETURN
PRIVATE METHOD MainForm_FormClosing( sender AS System.Object, e AS System.Windows.Forms.FormClosingEventArgs ) AS System.Void
        LOCAL oSplit := DevExpress.XtraEditors.SplitContainerControl[]{3} AS DevExpress.XtraEditors.SplitContainerControl[]
        oSplit[1] := SELF:splitContainerControl_Main
        oSplit[2] := SELF:splitContainerControl_LBC
        oSplit[3] := SELF:splitContainerControl_CheckedLBC

        oSoftway:SaveFormSettings_DevExpress(SELF, SELF:alForms, SELF:alData, oSplit)

        IF (lAutoUpdateInProgress) //.or. cStartupPath:Contains("Visual Studio"))
            RETURN
        ENDIF

        IF SELF:lUserLoggedOn
            IF QuestionBox("Do you want to exit ?", "Close program") != System.Windows.Forms.DialogResult.Yes
                e:Cancel:=TRUE
            ENDIF
        ENDIF
        RETURN
PRIVATE METHOD MainForm_FormClosed( sender AS System.Object, e AS System.Windows.Forms.FormClosedEventArgs ) AS System.Void
        TRY
        IF SELF:lUserLoggedOn
            //LOCAL cTagSelection := "" AS STRING
            LOCAL cTagSelection := SELF:barEditItemDisplayMap:EditValue:ToString() AS STRING

            IF SELF:LBCReports:SelectedIndex == -1
                SELF:cLastMainSelection := ""
            ELSE
                SELF:cLastMainSelection := SELF:LBCReports:GetDisplayItemValue(SELF:LBCReports:SelectedIndex):ToString()
                IF SELF:TreeListVessels:FocusedNode <> NULL
                    SELF:cLastMainSelection += "|"+SELF:TreeListVessels:FocusedNode:GetValue(0):ToString()
                ENDIF
            ENDIF
            oSoftway:SaveXMLSettings(cStartupPath+"\"+System.Windows.Forms.Application.ProductName+".XML", SELF:alForms, SELF:alData, SELF:cLastMainSelection, cTagSelection, SELF:cSkinNameLookAndFeel)

            SELF:ClearConnection()
            SELF:ClearConnectionBlob()
            oSoftway:ClearDirectory(cTempDocDir, 3)
            //oSoftway:ClearDirectory(cLogDir, 365)
        ENDIF
        CATCH exc AS Exception
            SELF:ClearConnection()
            SELF:ClearConnectionBlob()
            oSoftway:ClearDirectory(cTempDocDir, 3)
        END
    RETURN
PRIVATE METHOD LBCReports_SelectedIndexChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:SelectedReportChanged()
        RETURN

// PRIVATE METHOD CheckedLBCVessels_SelectedIndexChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
// SELF:SelectedVesselChanged()
// RETURN
// PRIVATE METHOD CheckedLBCVessels_ItemCheck( sender AS System.Object, e AS DevExpress.XtraEditors.Controls.ItemCheckEventArgs ) AS System.Void
// SELF:SelectedVesselCheckedChanged(e)
// RETURN
PRIVATE METHOD BBICheckAll_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:CheckAllVessels()
        RETURN
PRIVATE METHOD BBIRefresh_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:splitMapForm:PanelVisibility := DevExpress.XtraEditors.SplitPanelVisibility.Panel2
        SELF:barEditItemDisplayMap:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
        SELF:BingMapUserControl:ShowSelectedVesselsOnMap()
        SELF:lDisplayAll := TRUE
        //SELF:BingMapUserControl:ClearReportPins()
        //SELF:BingMapUserControl:Map:Focus()
        RETURN

// PRIVATE METHOD MainForm_PreviewKeyDown( sender AS System.Object, e AS System.Windows.Forms.PreviewKeyDownEventArgs ) AS System.Void
// wb(sender, e:KeyCode)
// RETURN
// 
// PRIVATE METHOD splitContainerControl_Main_Panel2_PreviewKeyDown( sender AS System.Object, e AS System.Windows.Forms.PreviewKeyDownEventArgs ) AS System.Void
// wb(sender, e:KeyCode)
// RETURN
PRIVATE METHOD LBCReports_DrawItem( sender AS System.Object, e AS DevExpress.XtraEditors.ListBoxDrawItemEventArgs ) AS System.Void
        SELF:DrawLBCReportsItem(e)
        RETURN
PRIVATE METHOD LBCVesselReports_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:ShowReportForm(FALSE,FALSE)
        RETURN
PRIVATE METHOD BBIShowMessage_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:ShowLinkedMessage()
        RETURN
PRIVATE METHOD BBIShowTabForm_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:ShowReportForm(TRUE,FALSE)
        RETURN
PRIVATE METHOD BBIIsmForm_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:IsmFormBodyText()
        RETURN
PRIVATE METHOD BBIImportExcelData_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:ImportExcelData()
        //self:showSetupUsersForm()
        RETURN
PRIVATE METHOD BBICreateExcelReport_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:ExportItemsToExcelFile()
        RETURN
PRIVATE METHOD barEditItemPeriod_EditValueChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        //wb("pause")
        SELF:barEditItemPeriod:Enabled := FALSE
        System.Windows.Forms.Application.DoEvents()
        SELF:LBCVesselReportsViewChanged()
        SELF:barEditItemPeriod:Enabled := TRUE
        // Focus to Items
        //SELF:LBCItems:Focus()
        RETURN
PRIVATE METHOD BBIShowVoyageOnNewMap_Main_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:ShowSelectedVoyageOnMap()
        RETURN
PRIVATE METHOD BBIReportDefinition_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:ReportDefinition()
        RETURN
PRIVATE METHOD TreeListVessels_BeforeCheckNode( sender AS System.Object, e AS DevExpress.XtraTreeList.CheckNodeEventArgs ) AS System.Void
        //LOCAL cUID := e:Node:Tag:ToString() AS STRING
        // Allow checking a selected Node only and deny checking Fleet
        //e:CanCheck := (e:Node:Selected) //.and. ! cUID:StartsWith("Fleet"))
        //IF ! e:Node:Selected
        //    e:Node:Selected := TRUE
        //ENDIF
        RETURN
PRIVATE METHOD TreeListVessels_AfterCheckNode( sender AS System.Object, e AS DevExpress.XtraTreeList.NodeEventArgs ) AS System.Void
        SELF:TreeListVessels_OnAfterCheckNode(e)
        RETURN
PRIVATE METHOD TreeListVessels_FocusedNodeChanged( sender AS System.Object, e AS DevExpress.XtraTreeList.FocusedNodeChangedEventArgs ) AS System.Void
        //SELF:Text := e:Node:Level:ToString()
        IF e:Node <> NULL
            //SELF:Text := e:Node:GetValue(0):ToString()
            //SELF:Text := e:Node:Tag:ToString()
            SELF:oLastSelectedNode := e:Node
            SELF:SelectedVesselChanged()
        ENDIF
        RETURN
PRIVATE METHOD TreeListVesselsReports_FocusedNodeChanged( sender AS System.Object, e AS DevExpress.XtraTreeList.FocusedNodeChangedEventArgs ) AS System.Void
            SELF:TreeListReportsFocusChanged(sender) 
        RETURN
PRIVATE METHOD TreeListVesselsReports_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
            SELF:treeList1_DoubleClick(sender,e)
        RETURN
PRIVATE METHOD backBBI_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            SELF:backBBI_ItemClickMethod()
        RETURN
EXPORT METHOD BBIEditReport_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        TRY
            SELF:myReportTabForm:ReadOnlyControls(TRUE)
            SELF:BBIEditReport:Enabled := FALSE
            SELF:BBISubmit:Enabled := FALSE
            SELF:BBISave:Enabled := TRUE
            SELF:BBICancel:Enabled := TRUE
            SELF:BBIFinalize:Enabled := TRUE
            
        CATCH
        END
        RETURN
PRIVATE METHOD BBISave_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        TRY
            SELF:myReportTabForm:saveNormalValues()
            SELF:myReportTabForm:saveMultilineFields()
            SELF:myReportTabForm:ReadOnlyControls(FALSE)
            SELF:BBIEditReport:Enabled := TRUE
            SELF:BBIFinalize:Enabled := FALSE
            SELF:BBISubmit:Enabled := TRUE
            SELF:BBISave:Enabled := FALSE
            SELF:BBICancel:Enabled := FALSE
        CATCH
        END
        RETURN
PRIVATE METHOD BBIDelete_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            SELF:deleteDataPackage()
        RETURN
PRIVATE METHOD barEditItemDisplay_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        RETURN
PRIVATE METHOD barEditItemDisplay_EditValueChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
            SELF:barEditItemDisplayMap:Enabled := FALSE
            System.Windows.Forms.Application.DoEvents()
            SELF:LBCDisplayMapViewChanged()
            SELF:barEditItemDisplayMap:Enabled := TRUE
        RETURN
PRIVATE METHOD splitMapForm_SplitGroupPanelCollapsed( sender AS System.Object, e AS DevExpress.XtraEditors.SplitGroupPanelCollapsedEventArgs ) AS System.Void
            SELF:barEditItemDisplayMap:Visibility := DevExpress.XtraBars.BarItemVisibility.Never
        RETURN
PRIVATE METHOD splitMapForm_Panel2_VisibleChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
            //WB("")
        RETURN
PRIVATE METHOD splitMapForm_Panel1_VisibleChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
            //WB("")
        RETURN
PRIVATE METHOD splitMapForm_SplitterPositionChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
            //SELF:splitterChanged(false)
        RETURN
PRIVATE METHOD BBIRefreshReports_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            SELF:showSetupUsersForm()
        RETURN
PRIVATE METHOD BBIUserGroups_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            SELF:ShowSetupUserGroupsForm()
        RETURN
PRIVATE METHOD barButtonItem1_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
   
        RETURN
PRIVATE METHOD MainBBIGlobal_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            SELF:showGlobalSettingsForm()
        RETURN
PRIVATE METHOD tabControl1_SelectedIndexChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
            IF SELF:ReportsTabUserControl:SelectedIndex == 0
                LBCReports := SELF:LBCReportsVessel
                SELF:BBICreateReport:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
            ELSE
                LBCReports := SELF:LBCReportsOffice
                LOCAL oRowLocal := SELF:returnUserSetting(oUser:USER_UNIQUEID) AS DataRow
                IF  oRowLocal == NULL ||  oRowLocal["CanCreateReports"]:ToString() == "False"
                    SELF:BBICreateReport:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Never
                ELSE
                    SELF:BBICreateReport:Visibility :=  DevExpress.XtraBars.BarItemVisibility.Always
                ENDIF
                lisManagerGlobal := SELF:isDeptManager()
                IF oUser:User_Uniqueid == SELF:findGM()
                    lisGMGlobal := TRUE
                ENDIF
            ENDIF    
            SELF:justTheReportChanged()
    RETURN
PRIVATE METHOD BBICreateReport_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        SELF:createNewReport()
    RETURN
PRIVATE METHOD LBCReportsOffice_SelectedIndexChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:justTheReportChanged()
        RETURN
PRIVATE METHOD LBCReportsOffice_Enter( sender AS System.Object, e AS System.EventArgs ) AS System.Void
         //SELF:SelectedReportChanged()
        RETURN
PRIVATE METHOD BBIFinalize_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            SELF:finalizeReport()
        RETURN
PRIVATE METHOD print_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            
        RETURN
PRIVATE METHOD printReport_PrintPage(sender AS System.Object, e AS System.Drawing.Printing.PrintPageEventArgs ) AS VOID
        e:Graphics:DrawImage(memoryImage,0,0)
    RETURN
PRIVATE METHOD TreeListVessels_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        
        /*LOCAL oTree AS DevExpress.XtraTreeList.TreeList
        oTree := (DevExpress.XtraTreeList.TreeList)sender
        local oInfo := oTree:CalcHitInfo(oTree:PointToClient(System.Windows.Forms.Control.MousePosition)) as DevExpress.XtraTreeList.TreeListHitInfo
        IF(oInfo:HitInfoType == DevExpress.XtraTreeList.HitInfoType.NodeCheckBox && oInfo:Node <> oTree:FocusedNode)
            
            //wb("Check me :"+oInfo:Node:Checked:tostring()+"/"+oInfo:Node:GetDisplayText(0)+"/"+oTree:FocusedNode:GetDisplayText(0))
            IF oInfo:Node:Checked == TRUE
                oInfo:Node:Checked := FALSE
            ELSEIF oInfo:Node:Checked == FALSE
                oInfo:Node:Checked := TRUE
            ENDIF
            //wb("Check me :"+oInfo:Node:Checked:tostring())
        ENDIF
        
        //oInfo:Node <> oTree:FocusedNode*/
        
        RETURN
PRIVATE METHOD BBICancel_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            SELF:cancelChanges()
    RETURN
PRIVATE METHOD BBISubmit_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            SELF:submitCaseToManager()
            SELF:refreshMyApprovalsForm()
    RETURN
PRIVATE METHOD BBIAppove_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            SELF:approveCase()
            SELF:refreshMyApprovalsForm()
    RETURN
PRIVATE METHOD barButtonItem2_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            SELF:ShowApprovalsForm()
        RETURN
PRIVATE METHOD BBSIStatus_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            SELF:ShowApprovalsForFocusedReport()
        RETURN
PRIVATE METHOD BBIReturn_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            SELF:returnCaseToUser()
            SELF:refreshMyApprovalsForm()
        RETURN
PRIVATE METHOD barButtonItem2_ItemClick_1( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            SELF:print_ItemClickMethod()
            
        RETURN
PRIVATE METHOD barButtonItem3_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            LOCAL cReportUID := oMainForm:LBCReports:SelectedValue:ToString() AS STRING
            LOCAL cReportName := oMainForm:LBCReports:GetDisplayItemValue(oMainForm:LBCReports:SelectedIndex):ToString() AS STRING
            LOCAL cVesselUID := oMainForm:GetVesselUID AS STRING
            LOCAL cVesselName := oMainForm:GetVesselName AS STRING
            
            SELF:PrintFormToExcelFile(cReportUID,cReportName,FALSE, cVesselUID, cVesselName)
        RETURN
PRIVATE METHOD BBITableReports_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            SELF:showReportSelectionForm()
        RETURN
PRIVATE METHOD ExportToExcelToolStripMenuItem_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        LOCAL cReportUID := oMainForm:LBCReportsVessel:SelectedValue:ToString() AS STRING
        LOCAL cReportName := oMainForm:LBCReportsVessel:GetDisplayItemValue(oMainForm:LBCReportsVessel:SelectedIndex):ToString() AS STRING
        LOCAL cVesselUID := oMainForm:GetVesselUID AS STRING
        LOCAL cVesselName := oMainForm:GetVesselName AS STRING
        IF SELF:ReportsTabUserControl:SelectedTab:ToString():Contains("Office")
            cReportUID := oMainForm:LBCReportsOffice:SelectedValue:ToString()
            cReportName := oMainForm:LBCReportsOffice:GetDisplayItemValue(oMainForm:LBCReportsOffice:SelectedIndex):ToString()
            cVesselUID := oMainForm:GetVesselUID
            cVesselName := oMainForm:GetVesselName
        ELSE
            cReportUID := oMainForm:LBCReportsVessel:SelectedValue:ToString()
            cReportName := oMainForm:LBCReportsVessel:GetDisplayItemValue(oMainForm:LBCReportsVessel:SelectedIndex):ToString()
            cVesselUID := oMainForm:GetVesselUID
            cVesselName := oMainForm:GetVesselName
        ENDIF
        SELF:PrintFormToExcelFile(cReportUID,cReportName,TRUE, cVesselUID, cVesselName)
    RETURN
PRIVATE METHOD DryBarButton_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            showReportSelectionForm("18")
        RETURN
PRIVATE METHOD WetBBI_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            showReportSelectionForm("21")
        RETURN
PRIVATE METHOD PerRoleWet_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            showReportSelectionForm("21", TRUE)
        RETURN
PRIVATE METHOD PerRoleDry_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            showReportSelectionForm("18", TRUE)
        RETURN
PRIVATE METHOD PerRoleAllFleet_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            showReportSelectionForm("-", TRUE)
        RETURN
PRIVATE METHOD BBIAppovalHistory_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            SELF:showMyHistoryForm()
        RETURN
PRIVATE METHOD barButtonItemMRVReport_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
            SELF:barButtonItemMRVReportItemClick()
    RETURN
PRIVATE METHOD bbiAlerts_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
        bbiAlertsItemClick()
    RETURN
PRIVATE METHOD bbiNewVoyage_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
        AddNewVoyage()
    RETURN

END CLASS 
