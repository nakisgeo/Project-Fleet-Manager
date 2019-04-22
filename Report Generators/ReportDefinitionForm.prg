#Using System.Windows.Forms
#Using System.Data
#Using System.Drawing
#Using DevExpress.XtraBars
#Using DevExpress.XtraGrid.Views.Grid
#Using DevExpress.XtraGrid.Views.Grid.ViewInfo
PARTIAL CLASS ReportDefinitionForm INHERIT DevExpress.XtraEditors.XtraForm
    PRIVATE GridFormulas AS DevExpress.XtraGrid.GridControl
    PRIVATE GridViewFormulas AS DevExpress.XtraGrid.Views.Grid.GridView
    EXPORT LBCReports AS DevExpress.XtraEditors.ListBoxControl
    PRIVATE standaloneBarDockControl_Reports AS DevExpress.XtraBars.StandaloneBarDockControl
    PRIVATE standaloneBarDockControl_Formulas AS DevExpress.XtraBars.StandaloneBarDockControl
    PRIVATE BarReports AS DevExpress.XtraBars.Bar
    PRIVATE BarFormulas AS DevExpress.XtraBars.Bar
    PRIVATE BarStatus AS DevExpress.XtraBars.Bar
    PRIVATE barDockControlTop AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlBottom AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlLeft AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlRight AS DevExpress.XtraBars.BarDockControl
    PRIVATE BBINewReport AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIReportEdit AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIReportDelete AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIReportRefresh AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIGoFirst AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIGoLast AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIPrevious AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBINext AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBINewFormula AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIDeleteFormula AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBICreateReport AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIPrintFormulas AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIFormulaRefresh AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIHelp AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIClose AS DevExpress.XtraBars.BarButtonItem
    PRIVATE splitContainerControl_Formulas AS DevExpress.XtraEditors.SplitContainerControl
    PRIVATE barManagerFormulas AS DevExpress.XtraBars.BarManager
    PRIVATE BBIEditFormula AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIPasteFormulas AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBICustomItems AS DevExpress.XtraBars.BarButtonItem
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
    PRIVATE METHOD InitializeComponent() AS System.Void
        SELF:components := System.ComponentModel.Container{}
        LOCAL resources := System.ComponentModel.ComponentResourceManager{typeof(ReportDefinitionForm)} AS System.ComponentModel.ComponentResourceManager
        LOCAL superToolTip1 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem1 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL superToolTip2 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem2 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL superToolTip3 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem3 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL superToolTip4 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem4 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL superToolTip5 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem5 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem1 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip6 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem6 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL superToolTip7 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem7 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL superToolTip8 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem8 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem2 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip9 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem9 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL superToolTip10 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem10 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem3 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip11 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem11 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL superToolTip12 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem12 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL superToolTip13 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem13 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem4 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip14 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem14 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem5 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip15 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem15 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem6 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip16 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem16 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem7 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip17 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem17 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem8 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip18 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem18 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        SELF:GridFormulas := DevExpress.XtraGrid.GridControl{}
        SELF:GridViewFormulas := DevExpress.XtraGrid.Views.Grid.GridView{}
        SELF:LBCReports := DevExpress.XtraEditors.ListBoxControl{}
        SELF:splitContainerControl_Formulas := DevExpress.XtraEditors.SplitContainerControl{}
        SELF:standaloneBarDockControl_Reports := DevExpress.XtraBars.StandaloneBarDockControl{}
        SELF:standaloneBarDockControl_Formulas := DevExpress.XtraBars.StandaloneBarDockControl{}
        SELF:barManagerFormulas := DevExpress.XtraBars.BarManager{SELF:components}
        SELF:BarReports := DevExpress.XtraBars.Bar{}
        SELF:BBINewReport := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIReportEdit := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIReportDelete := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIReportRefresh := DevExpress.XtraBars.BarButtonItem{}
        SELF:BarFormulas := DevExpress.XtraBars.Bar{}
        SELF:BBIGoFirst := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIPrevious := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBINext := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIGoLast := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBINewFormula := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIEditFormula := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIDeleteFormula := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIFormulaRefresh := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIPasteFormulas := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIPrintFormulas := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBICustomItems := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBICreateReport := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIHelp := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIClose := DevExpress.XtraBars.BarButtonItem{}
        SELF:BarStatus := DevExpress.XtraBars.Bar{}
        SELF:barDockControlTop := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlBottom := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlLeft := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlRight := DevExpress.XtraBars.BarDockControl{}
        ((System.ComponentModel.ISupportInitialize)(SELF:GridFormulas)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:GridViewFormulas)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:LBCReports)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl_Formulas)):BeginInit()
        SELF:splitContainerControl_Formulas:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:barManagerFormulas)):BeginInit()
        SELF:SuspendLayout()
        // 
        // GridFormulas
        // 
        SELF:GridFormulas:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:GridFormulas:Location := System.Drawing.Point{0, 26}
        SELF:GridFormulas:LookAndFeel:SkinName := "The Asphalt World"
        SELF:GridFormulas:MainView := SELF:GridViewFormulas
        SELF:GridFormulas:Name := "GridFormulas"
        SELF:GridFormulas:Size := System.Drawing.Size{577, 514}
        SELF:GridFormulas:TabIndex := 14
        SELF:GridFormulas:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:GridViewFormulas })
        // 
        // GridViewFormulas
        // 
        SELF:GridViewFormulas:GridControl := SELF:GridFormulas
        SELF:GridViewFormulas:Name := "GridViewFormulas"
        SELF:GridViewFormulas:OptionsBehavior:AllowIncrementalSearch := TRUE
        SELF:GridViewFormulas:OptionsBehavior:AutoPopulateColumns := FALSE
        SELF:GridViewFormulas:OptionsSelection:EnableAppearanceFocusedCell := FALSE
        SELF:GridViewFormulas:OptionsView:ColumnAutoWidth := FALSE
        SELF:GridViewFormulas:FocusedColumnChanged += DevExpress.XtraGrid.Views.Base.FocusedColumnChangedEventHandler{ SELF, @GridViewFormulas_FocusedColumnChanged() }
        SELF:GridViewFormulas:CellValueChanged += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @GridViewFormulas_CellValueChanged() }
        SELF:GridViewFormulas:CellValueChanging += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @GridViewFormulas_CellValueChanging() }
        SELF:GridViewFormulas:BeforeLeaveRow += DevExpress.XtraGrid.Views.Base.RowAllowEventHandler{ SELF, @GridViewFormulas_BeforeLeaveRow() }
        SELF:GridViewFormulas:CustomUnboundColumnData += DevExpress.XtraGrid.Views.Base.CustomColumnDataEventHandler{ SELF, @GridViewFormulas_CustomUnboundColumnData() }
        SELF:GridViewFormulas:DoubleClick += System.EventHandler{ SELF, @GridViewFormulas_DoubleClick() }
        // 
        // LBCReports
        // 
        SELF:LBCReports:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:LBCReports:Location := System.Drawing.Point{0, 26}
        SELF:LBCReports:Name := "LBCReports"
        SELF:LBCReports:Size := System.Drawing.Size{201, 514}
        SELF:LBCReports:SortOrder := System.Windows.Forms.SortOrder.Ascending
        SELF:LBCReports:TabIndex := 20
        SELF:LBCReports:SelectedIndexChanged += System.EventHandler{ SELF, @LBCReports_SelectedIndexChanged() }
        SELF:LBCReports:MouseDoubleClick += System.Windows.Forms.MouseEventHandler{ SELF, @LBCReports_MouseDoubleClick() }
        // 
        // splitContainerControl_Formulas
        // 
        SELF:splitContainerControl_Formulas:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:splitContainerControl_Formulas:Location := System.Drawing.Point{0, 0}
        SELF:splitContainerControl_Formulas:Name := "splitContainerControl_Formulas"
        SELF:splitContainerControl_Formulas:Panel1:Controls:Add(SELF:LBCReports)
        SELF:splitContainerControl_Formulas:Panel1:Controls:Add(SELF:standaloneBarDockControl_Reports)
        SELF:splitContainerControl_Formulas:Panel1:Text := "Panel1"
        SELF:splitContainerControl_Formulas:Panel2:Controls:Add(SELF:GridFormulas)
        SELF:splitContainerControl_Formulas:Panel2:Controls:Add(SELF:standaloneBarDockControl_Formulas)
        SELF:splitContainerControl_Formulas:Panel2:Text := "Panel2"
        SELF:splitContainerControl_Formulas:Size := System.Drawing.Size{784, 540}
        SELF:splitContainerControl_Formulas:SplitterPosition := 201
        SELF:splitContainerControl_Formulas:TabIndex := 33
        SELF:splitContainerControl_Formulas:Text := "splitContainerControl1"
        // 
        // standaloneBarDockControl_Reports
        // 
        SELF:standaloneBarDockControl_Reports:CausesValidation := FALSE
        SELF:standaloneBarDockControl_Reports:Dock := System.Windows.Forms.DockStyle.Top
        SELF:standaloneBarDockControl_Reports:Location := System.Drawing.Point{0, 0}
        SELF:standaloneBarDockControl_Reports:Name := "standaloneBarDockControl_Reports"
        SELF:standaloneBarDockControl_Reports:Size := System.Drawing.Size{201, 26}
        SELF:standaloneBarDockControl_Reports:Text := "standaloneBarDockControl1"
        // 
        // standaloneBarDockControl_Formulas
        // 
        SELF:standaloneBarDockControl_Formulas:CausesValidation := FALSE
        SELF:standaloneBarDockControl_Formulas:Dock := System.Windows.Forms.DockStyle.Top
        SELF:standaloneBarDockControl_Formulas:Location := System.Drawing.Point{0, 0}
        SELF:standaloneBarDockControl_Formulas:Name := "standaloneBarDockControl_Formulas"
        SELF:standaloneBarDockControl_Formulas:Size := System.Drawing.Size{577, 26}
        SELF:standaloneBarDockControl_Formulas:Text := "standaloneBarDockControl1"
        // 
        // barManagerFormulas
        // 
        SELF:barManagerFormulas:Bars:AddRange(<DevExpress.XtraBars.Bar>{ SELF:BarReports, SELF:BarFormulas, SELF:BarStatus })
        SELF:barManagerFormulas:DockControls:Add(SELF:barDockControlTop)
        SELF:barManagerFormulas:DockControls:Add(SELF:barDockControlBottom)
        SELF:barManagerFormulas:DockControls:Add(SELF:barDockControlLeft)
        SELF:barManagerFormulas:DockControls:Add(SELF:barDockControlRight)
        SELF:barManagerFormulas:DockControls:Add(SELF:standaloneBarDockControl_Formulas)
        SELF:barManagerFormulas:DockControls:Add(SELF:standaloneBarDockControl_Reports)
        SELF:barManagerFormulas:Form := SELF
        SELF:barManagerFormulas:Items:AddRange(<DevExpress.XtraBars.BarItem>{ SELF:BBINewReport, SELF:BBIReportEdit, SELF:BBIReportDelete, SELF:BBIReportRefresh, SELF:BBIGoFirst, SELF:BBIPrevious, SELF:BBINext, SELF:BBIGoLast, SELF:BBINewFormula, SELF:BBIDeleteFormula, SELF:BBIPasteFormulas, SELF:BBICreateReport, SELF:BBIPrintFormulas, SELF:BBIFormulaRefresh, SELF:BBIHelp, SELF:BBIClose, SELF:BBIEditFormula, SELF:BBICustomItems })
        SELF:barManagerFormulas:MainMenu := SELF:BarFormulas
        SELF:barManagerFormulas:MaxItemId := 20
        SELF:barManagerFormulas:StatusBar := SELF:BarStatus
        // 
        // BarReports
        // 
        SELF:BarReports:BarName := "Tools"
        SELF:BarReports:CanDockStyle := DevExpress.XtraBars.BarCanDockStyle.Standalone
        SELF:BarReports:DockCol := 0
        SELF:BarReports:DockRow := 0
        SELF:BarReports:DockStyle := DevExpress.XtraBars.BarDockStyle.Standalone
        SELF:BarReports:FloatLocation := System.Drawing.Point{394, 404}
        SELF:BarReports:FloatSize := System.Drawing.Size{46, 24}
        SELF:BarReports:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:BBINewReport}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIReportEdit}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIReportDelete}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIReportRefresh} })
        SELF:BarReports:OptionsBar:AllowQuickCustomization := FALSE
        SELF:BarReports:OptionsBar:DisableClose := TRUE
        SELF:BarReports:OptionsBar:DisableCustomization := TRUE
        SELF:BarReports:OptionsBar:UseWholeRow := TRUE
        SELF:BarReports:StandaloneBarDockControl := SELF:standaloneBarDockControl_Reports
        SELF:BarReports:Text := "BarReports"
        // 
        // BBINewReport
        // 
        SELF:BBINewReport:Caption := "Add new Report definition"
        SELF:BBINewReport:Glyph := ((System.Drawing.Image)(resources:GetObject("BBINewReport.Glyph")))
        SELF:BBINewReport:Id := 2
        SELF:BBINewReport:Name := "BBINewReport"
        toolTipTitleItem1:Text := "Add new Report definition"
        superToolTip1:Items:Add(toolTipTitleItem1)
        SELF:BBINewReport:SuperTip := superToolTip1
        SELF:BBINewReport:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBINewReport_ItemClick() }
        // 
        // BBIReportEdit
        // 
        SELF:BBIReportEdit:Caption := "Edit Report definition"
        SELF:BBIReportEdit:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIReportEdit.Glyph")))
        SELF:BBIReportEdit:Id := 3
        SELF:BBIReportEdit:Name := "BBIReportEdit"
        toolTipTitleItem2:Text := "Edit/Rename Report definition"
        superToolTip2:Items:Add(toolTipTitleItem2)
        SELF:BBIReportEdit:SuperTip := superToolTip2
        SELF:BBIReportEdit:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIReportEdit_ItemClick() }
        // 
        // BBIReportDelete
        // 
        SELF:BBIReportDelete:Caption := "Delete Report definition"
        SELF:BBIReportDelete:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIReportDelete.Glyph")))
        SELF:BBIReportDelete:Id := 4
        SELF:BBIReportDelete:Name := "BBIReportDelete"
        toolTipTitleItem3:Text := "Delete Report definition"
        superToolTip3:Items:Add(toolTipTitleItem3)
        SELF:BBIReportDelete:SuperTip := superToolTip3
        SELF:BBIReportDelete:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIReportDelete_ItemClick() }
        // 
        // BBIReportRefresh
        // 
        SELF:BBIReportRefresh:Caption := "Refresh"
        SELF:BBIReportRefresh:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIReportRefresh.Glyph")))
        SELF:BBIReportRefresh:Id := 5
        SELF:BBIReportRefresh:Name := "BBIReportRefresh"
        toolTipTitleItem4:Text := e"Refresh Reports\r\n"
        superToolTip4:Items:Add(toolTipTitleItem4)
        SELF:BBIReportRefresh:SuperTip := superToolTip4
        SELF:BBIReportRefresh:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIReportRefresh_ItemClick() }
        // 
        // BarFormulas
        // 
        SELF:BarFormulas:BarName := "Main menu"
        SELF:BarFormulas:CanDockStyle := DevExpress.XtraBars.BarCanDockStyle.Standalone
        SELF:BarFormulas:DockCol := 0
        SELF:BarFormulas:DockRow := 0
        SELF:BarFormulas:DockStyle := DevExpress.XtraBars.BarDockStyle.Standalone
        SELF:BarFormulas:FloatLocation := System.Drawing.Point{598, 199}
        SELF:BarFormulas:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:BBIGoFirst}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIPrevious}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBINext}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIGoLast}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBINewFormula}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIEditFormula}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIDeleteFormula}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIFormulaRefresh}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIPasteFormulas}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIPrintFormulas}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBICustomItems}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBICreateReport}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIHelp}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIClose} })
        SELF:BarFormulas:OptionsBar:AllowQuickCustomization := FALSE
        SELF:BarFormulas:OptionsBar:DisableClose := TRUE
        SELF:BarFormulas:OptionsBar:DisableCustomization := TRUE
        SELF:BarFormulas:OptionsBar:UseWholeRow := TRUE
        SELF:BarFormulas:StandaloneBarDockControl := SELF:standaloneBarDockControl_Formulas
        SELF:BarFormulas:Text := "BarFormulas"
        // 
        // BBIGoFirst
        // 
        SELF:BBIGoFirst:Caption := "Go top"
        SELF:BBIGoFirst:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIGoFirst.Glyph")))
        SELF:BBIGoFirst:Id := 6
        SELF:BBIGoFirst:ItemShortcut := DevExpress.XtraBars.BarShortcut{(System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.PageUp)}
        SELF:BBIGoFirst:Name := "BBIGoFirst"
        toolTipTitleItem5:Text := "First (Ctrl+PgUp)"
        toolTipItem1:LeftIndent := 6
        toolTipItem1:Text := "Go top"
        superToolTip5:Items:Add(toolTipTitleItem5)
        superToolTip5:Items:Add(toolTipItem1)
        SELF:BBIGoFirst:SuperTip := superToolTip5
        SELF:BBIGoFirst:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIGoFirst_ItemClick() }
        // 
        // BBIPrevious
        // 
        SELF:BBIPrevious:Caption := "Previous"
        SELF:BBIPrevious:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIPrevious.Glyph")))
        SELF:BBIPrevious:Id := 7
        SELF:BBIPrevious:Name := "BBIPrevious"
        toolTipTitleItem6:Text := "Go to previous record"
        superToolTip6:Items:Add(toolTipTitleItem6)
        SELF:BBIPrevious:SuperTip := superToolTip6
        SELF:BBIPrevious:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIPrevious_ItemClick() }
        // 
        // BBINext
        // 
        SELF:BBINext:Caption := "Next"
        SELF:BBINext:Glyph := ((System.Drawing.Image)(resources:GetObject("BBINext.Glyph")))
        SELF:BBINext:Id := 8
        SELF:BBINext:Name := "BBINext"
        toolTipTitleItem7:Text := "Go to next record"
        superToolTip7:Items:Add(toolTipTitleItem7)
        SELF:BBINext:SuperTip := superToolTip7
        SELF:BBINext:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBINext_ItemClick() }
        // 
        // BBIGoLast
        // 
        SELF:BBIGoLast:Caption := "Go bottom"
        SELF:BBIGoLast:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIGoLast.Glyph")))
        SELF:BBIGoLast:Id := 9
        SELF:BBIGoLast:Name := "BBIGoLast"
        toolTipTitleItem8:Text := "Last (Ctrl+PgDn)"
        toolTipItem2:LeftIndent := 6
        toolTipItem2:Text := "Go bottom"
        superToolTip8:Items:Add(toolTipTitleItem8)
        superToolTip8:Items:Add(toolTipItem2)
        SELF:BBIGoLast:SuperTip := superToolTip8
        SELF:BBIGoLast:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIGoLast_ItemClick() }
        // 
        // BBINewFormula
        // 
        SELF:BBINewFormula:Caption := "New Formula"
        SELF:BBINewFormula:Glyph := ((System.Drawing.Image)(resources:GetObject("BBINewFormula.Glyph")))
        SELF:BBINewFormula:Id := 10
        SELF:BBINewFormula:Name := "BBINewFormula"
        toolTipTitleItem9:Text := "Add New Formula record"
        superToolTip9:Items:Add(toolTipTitleItem9)
        SELF:BBINewFormula:SuperTip := superToolTip9
        SELF:BBINewFormula:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBINewFormula_ItemClick() }
        // 
        // BBIEditFormula
        // 
        SELF:BBIEditFormula:Caption := "Edit"
        SELF:BBIEditFormula:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIEditFormula.Glyph")))
        SELF:BBIEditFormula:Id := 18
        SELF:BBIEditFormula:ItemShortcut := DevExpress.XtraBars.BarShortcut{System.Windows.Forms.Keys.F2}
        SELF:BBIEditFormula:Name := "BBIEditFormula"
        toolTipTitleItem10:Text := "Edit (F2)"
        toolTipItem3:LeftIndent := 6
        toolTipItem3:Text := "Edit Formula record"
        superToolTip10:Items:Add(toolTipTitleItem10)
        superToolTip10:Items:Add(toolTipItem3)
        SELF:BBIEditFormula:SuperTip := superToolTip10
        SELF:BBIEditFormula:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIEditFormula_ItemClick() }
        // 
        // BBIDeleteFormula
        // 
        SELF:BBIDeleteFormula:Caption := "Delete Formula record"
        SELF:BBIDeleteFormula:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIDeleteFormula.Glyph")))
        SELF:BBIDeleteFormula:Id := 11
        SELF:BBIDeleteFormula:Name := "BBIDeleteFormula"
        toolTipTitleItem11:Text := "Delete Formula record"
        superToolTip11:Items:Add(toolTipTitleItem11)
        SELF:BBIDeleteFormula:SuperTip := superToolTip11
        SELF:BBIDeleteFormula:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIDeleteFormula_ItemClick() }
        // 
        // BBIFormulaRefresh
        // 
        SELF:BBIFormulaRefresh:Caption := "Refresh"
        SELF:BBIFormulaRefresh:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIFormulaRefresh.Glyph")))
        SELF:BBIFormulaRefresh:Id := 15
        SELF:BBIFormulaRefresh:Name := "BBIFormulaRefresh"
        toolTipTitleItem12:Text := e"Refresh Formula records\r\n"
        superToolTip12:Items:Add(toolTipTitleItem12)
        SELF:BBIFormulaRefresh:SuperTip := superToolTip12
        SELF:BBIFormulaRefresh:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIFormulaRefresh_ItemClick() }
        // 
        // BBIPasteFormulas
        // 
        SELF:BBIPasteFormulas:Caption := "Paste Formula record"
        SELF:BBIPasteFormulas:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIPasteFormulas.Glyph")))
        SELF:BBIPasteFormulas:Id := 12
        SELF:BBIPasteFormulas:Name := "BBIPasteFormulas"
        toolTipTitleItem13:Text := "Paste Formula records"
        toolTipItem4:LeftIndent := 6
        toolTipItem4:Text := "Insert here all Formula records from an existing Report"
        superToolTip13:Items:Add(toolTipTitleItem13)
        superToolTip13:Items:Add(toolTipItem4)
        SELF:BBIPasteFormulas:SuperTip := superToolTip13
        SELF:BBIPasteFormulas:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIPaste_ItemClick() }
        // 
        // BBIPrintFormulas
        // 
        SELF:BBIPrintFormulas:Caption := "Print Formulas"
        SELF:BBIPrintFormulas:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIPrintFormulas.Glyph")))
        SELF:BBIPrintFormulas:Id := 14
        SELF:BBIPrintFormulas:Name := "BBIPrintFormulas"
        toolTipTitleItem14:Text := "Print"
        toolTipItem5:LeftIndent := 6
        toolTipItem5:Text := "Print Formula lines"
        superToolTip14:Items:Add(toolTipTitleItem14)
        superToolTip14:Items:Add(toolTipItem5)
        SELF:BBIPrintFormulas:SuperTip := superToolTip14
        SELF:BBIPrintFormulas:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIPrintFormulas_ItemClick() }
        // 
        // BBICustomItems
        // 
        SELF:BBICustomItems:Caption := "Custom Items"
        SELF:BBICustomItems:Glyph := ((System.Drawing.Image)(resources:GetObject("BBICustomItems.Glyph")))
        SELF:BBICustomItems:Id := 19
        SELF:BBICustomItems:Name := "BBICustomItems"
        toolTipTitleItem15:Text := "Custom Items"
        toolTipItem6:LeftIndent := 6
        toolTipItem6:Text := "Define Custom Items to used them into the Formulas"
        superToolTip15:Items:Add(toolTipTitleItem15)
        superToolTip15:Items:Add(toolTipItem6)
        SELF:BBICustomItems:SuperTip := superToolTip15
        SELF:BBICustomItems:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBICustomItems_ItemClick() }
        // 
        // BBICreateReport
        // 
        SELF:BBICreateReport:Caption := "Create Report"
        SELF:BBICreateReport:Glyph := ((System.Drawing.Image)(resources:GetObject("BBICreateReport.Glyph")))
        SELF:BBICreateReport:Id := 13
        SELF:BBICreateReport:Name := "BBICreateReport"
        toolTipTitleItem16:Text := "Create Report"
        toolTipItem7:LeftIndent := 6
        toolTipItem7:Text := e"Generate the Report as defined\r\n"
        superToolTip16:Items:Add(toolTipTitleItem16)
        superToolTip16:Items:Add(toolTipItem7)
        SELF:BBICreateReport:SuperTip := superToolTip16
        SELF:BBICreateReport:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBICreateReport_ItemClick() }
        // 
        // BBIHelp
        // 
        SELF:BBIHelp:Caption := "Help"
        SELF:BBIHelp:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIHelp.Glyph")))
        SELF:BBIHelp:Id := 16
        SELF:BBIHelp:Name := "BBIHelp"
        toolTipTitleItem17:Text := "Help"
        toolTipItem8:LeftIndent := 6
        toolTipItem8:Text := e"How to use use Items and create Report Formulas\r\n"
        superToolTip17:Items:Add(toolTipTitleItem17)
        superToolTip17:Items:Add(toolTipItem8)
        SELF:BBIHelp:SuperTip := superToolTip17
        SELF:BBIHelp:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIHelp_ItemClick() }
        // 
        // BBIClose
        // 
        SELF:BBIClose:Caption := "Close"
        SELF:BBIClose:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIClose.Glyph")))
        SELF:BBIClose:Id := 17
        SELF:BBIClose:Name := "BBIClose"
        toolTipTitleItem18:Text := "Close Report definition window"
        superToolTip18:Items:Add(toolTipTitleItem18)
        SELF:BBIClose:SuperTip := superToolTip18
        SELF:BBIClose:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIClose_ItemClick() }
        // 
        // BarStatus
        // 
        SELF:BarStatus:BarName := "Status bar"
        SELF:BarStatus:CanDockStyle := DevExpress.XtraBars.BarCanDockStyle.Bottom
        SELF:BarStatus:DockCol := 0
        SELF:BarStatus:DockRow := 0
        SELF:BarStatus:DockStyle := DevExpress.XtraBars.BarDockStyle.Bottom
        SELF:BarStatus:OptionsBar:AllowQuickCustomization := FALSE
        SELF:BarStatus:OptionsBar:DisableClose := TRUE
        SELF:BarStatus:OptionsBar:DisableCustomization := TRUE
        SELF:BarStatus:OptionsBar:DrawDragBorder := FALSE
        SELF:BarStatus:OptionsBar:UseWholeRow := TRUE
        SELF:BarStatus:Text := "Status bar"
        // 
        // barDockControlTop
        // 
        SELF:barDockControlTop:CausesValidation := FALSE
        SELF:barDockControlTop:Dock := System.Windows.Forms.DockStyle.Top
        SELF:barDockControlTop:Location := System.Drawing.Point{0, 0}
        SELF:barDockControlTop:Size := System.Drawing.Size{784, 0}
        // 
        // barDockControlBottom
        // 
        SELF:barDockControlBottom:CausesValidation := FALSE
        SELF:barDockControlBottom:Dock := System.Windows.Forms.DockStyle.Bottom
        SELF:barDockControlBottom:Location := System.Drawing.Point{0, 540}
        SELF:barDockControlBottom:Size := System.Drawing.Size{784, 22}
        // 
        // barDockControlLeft
        // 
        SELF:barDockControlLeft:CausesValidation := FALSE
        SELF:barDockControlLeft:Dock := System.Windows.Forms.DockStyle.Left
        SELF:barDockControlLeft:Location := System.Drawing.Point{0, 0}
        SELF:barDockControlLeft:Size := System.Drawing.Size{0, 540}
        // 
        // barDockControlRight
        // 
        SELF:barDockControlRight:CausesValidation := FALSE
        SELF:barDockControlRight:Dock := System.Windows.Forms.DockStyle.Right
        SELF:barDockControlRight:Location := System.Drawing.Point{784, 0}
        SELF:barDockControlRight:Size := System.Drawing.Size{0, 540}
        // 
        // ReportDefinitionForm
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{784, 562}
        SELF:Controls:Add(SELF:splitContainerControl_Formulas)
        SELF:Controls:Add(SELF:barDockControlLeft)
        SELF:Controls:Add(SELF:barDockControlRight)
        SELF:Controls:Add(SELF:barDockControlBottom)
        SELF:Controls:Add(SELF:barDockControlTop)
        SELF:Name := "ReportDefinitionForm"
        SELF:StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen
        SELF:Text := "User defined Reports using Items and Formulas"
        SELF:FormClosing += System.Windows.Forms.FormClosingEventHandler{ SELF, @ReportDefinitionForm_FormClosing() }
        SELF:Load += System.EventHandler{ SELF, @ReportDefinitionForm_Load() }
        SELF:Shown += System.EventHandler{ SELF, @ReportDefinitionForm_Shown() }
        ((System.ComponentModel.ISupportInitialize)(SELF:GridFormulas)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:GridViewFormulas)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:LBCReports)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl_Formulas)):EndInit()
        SELF:splitContainerControl_Formulas:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:barManagerFormulas)):EndInit()
        SELF:ResumeLayout(FALSE)
    PRIVATE METHOD ReportDefinitionForm_FormClosing( sender AS System.Object, e AS System.Windows.Forms.FormClosingEventArgs ) AS System.Void
		oSoftway:SaveFormSettings_DevExpress(SELF, SELF:splitContainerControl_Formulas, oMainForm:alForms, oMainForm:alData)
        RETURN

    PRIVATE METHOD ReportDefinitionForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:ReportDefinitionForm_OnLoad()
        RETURN

    PRIVATE METHOD ReportDefinitionForm_Shown( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		//SELF:ReportDefinitionForm_OnShown()
        RETURN

    PRIVATE METHOD BBIHelp_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:HelpAbout()
        RETURN

    PRIVATE METHOD BBIClose_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:Close()
        RETURN

  //  PRIVATE METHOD LVReports_AfterLabelEdit( sender AS System.Object, e AS System.Windows.Forms.LabelEditEventArgs ) AS System.Void
		//SELF:SaveReportDefinition(e)
  //      RETURN

  //  PRIVATE METHOD toolStripButtonAddNew_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		//SELF:AddNewReportDefinition()
  //      RETURN

  //  PRIVATE METHOD toolStripButtonEdit_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		//SELF:EditReportDefinition()
  //      RETURN

  //  PRIVATE METHOD toolStripButtonDelete_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		//SELF:DeleteReportDefinition()
  //      RETURN

  //  PRIVATE METHOD toolStripButtonRefresh_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		//Self:CreateLVReports()
		//if Self:LVReports:SelectedItems:Count == 0 .and. Self:cLastSelectedReportUID <> ""
		//	// The User clicked the mouse on the area of the LV and the selected LVItem is unselected now
		//	Self:LVReports:Items[Self:cLastSelectedReportUID]:Selected:=true
		//	System.Windows.Forms.Application.DoEvents()
		//endif
  //      RETURN

  //  PRIVATE METHOD LVReports_ItemSelectionChanged( sender AS System.Object, e AS System.Windows.Forms.ListViewItemSelectionChangedEventArgs ) AS System.Void
		//if e:IsSelected
		//	// Selected (Color)
		//	e:Item:BackColor := System.Drawing.Color.LightBlue
		//ELSE
		//	// Restore ForeColor
		//	e:Item:BackColor := System.Drawing.Color.White
		//endif
  //      RETURN

  //  PRIVATE METHOD LVReports_MouseUp( sender AS System.Object, e AS System.Windows.Forms.MouseEventArgs ) AS System.Void
		//if Self:LVReports:SelectedItems:Count == 0 .and. Self:cLastSelectedReportUID <> ""
		//	// The User clicked the mouse on the area of the LV and the selected LVItem is unselected now
		//	Self:LVReports:Items[Self:cLastSelectedReportUID]:Selected:=true
		//	System.Windows.Forms.Application.DoEvents()
		//ENDIF
		//Self:GridFormulas1:Focus()
  //      RETURN

  //  PRIVATE METHOD LVReports_SelectedIndexChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		//IF SELF:LVReports:SelectedItems:Count > 0
		//	SELF:cLastSelectedReportUID:=SELF:LVReports:SelectedItems[0]:Name
		//	SELF:cReportUID:=SELF:LVReports:SelectedItems[0]:Name
		//ENDIF
		////SELF:ShowGridFormulas()
		//SELF:CreateGridFormulas()
  //  RETURN

  //  PRIVATE METHOD bindingNavigatorAddNewItem_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		//if Self:LVReports:SelectedItems == NULL
		//	Return
		//endif
		//SELF:AddFormula()
  //      RETURN

  //  PRIVATE METHOD bindingNavigatorDeleteItem_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		//if Self:GridFormulas1:Rows:Count == 0
		//	Return
		//endif
		//Self:DeleteFormula()
  //      RETURN

  //  PRIVATE METHOD ButonPrint_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		//if Self:GridFormulas1:Rows:Count == 0
		//	Return
		//endif
		//if QuestionBox("Do you want to Print the Formulas ?", "Print Formulas") <> System.Windows.Forms.DialogResult.Yes
		//	RETURN
		//endif
		////Self:PrintDGVEGrid()
  //      RETURN
    
  //  PRIVATE METHOD ButtonRefresh_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		//Self:CreateGridFormulas()
  //      RETURN

  //  PRIVATE METHOD GridFormulas_CellValidated( sender AS System.Object, e AS System.Windows.Forms.DataGridViewCellEventArgs ) AS System.Void
		//	if Self:lCellValueChanged
		//		Self:lCellValueChanged:=false
		//		Self:UpdateFormula(e:RowIndex, e:ColumnIndex)
		//	endif
  //      RETURN

  //  PRIVATE METHOD GridFormulas_CellValueChanged( sender AS System.Object, e AS System.Windows.Forms.DataGridViewCellEventArgs ) AS System.Void
 	//	Self:lCellValueChanged:=true
  //      RETURN

  //  PRIVATE METHOD GridFormulas_DataError( sender AS System.Object, e AS System.Windows.Forms.DataGridViewDataErrorEventArgs ) AS System.Void
		//ErrorBox(e:Exception:Message)
  //      RETURN

  //  PRIVATE METHOD ButtonReport_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		//if Self:GridFormulas1:Rows:Count == 0
		//	Return
		//ENDIF
		//SELF:Report_BalanceSheet()
  //      RETURN

  //  PRIVATE METHOD GridFormulas_CellValidating( sender AS System.Object, e AS System.Windows.Forms.DataGridViewCellValidatingEventArgs ) AS System.Void
		//	if Self:GridFormulas1:Columns[e:ColumnIndex]:Name == "Formula"
		//		Local cText:=Self:GridFormulas1:Rows[e:RowIndex]:Cells[e:ColumnIndex]:EditedFormattedValue:ToString() as string

		//		if (cText:Contains("+") .or. cText:Contains("-") .or. cText:Contains("=")) .and. ;
		//			(cText:ToUpper():Contains("(DEBIT)") .or. cText:ToUpper():Contains("(CREDIT)") .or. cText:ToUpper():Contains("(BALANCE)"))
		//			Self:ButtonAbout_Click(Self, System.EventArgs.Empty)
		//			e:Cancel:=True
		//		endif
		//	endif

  //      RETURN

  //  PRIVATE METHOD GridFormulas_CellMouseUp( sender AS System.Object, e AS System.Windows.Forms.DataGridViewCellMouseEventArgs ) AS System.Void
		//if e:RowIndex == -1 .or. e:ColumnIndex == -1
		//	// MouseUp on RowHeader or ColumnHeader
		//	Return
		//endif

		//Local oColumn:=Self:GridFormulas1:Columns:Item[e:ColumnIndex] as System.Windows.Forms.DataGridViewColumn
		//Local cEntityUID, cChecked as string
		//do case
		//case InListExact(oColumn:Name, "HideLine", "Bold", "Underline")
		//	cChecked:=Self:GridFormulas1:Rows[e:RowIndex]:Cells[oColumn:Name]:EditedFormattedValue:ToString():ToUpper()
		//	cEntityUID:=Self:GridFormulas1:Rows[e:RowIndex]:Cells["FORMULA_UID"]:Value:ToString()
		//	// Cancel all other Suppliers order 
		//	// and place order of the Item to the current Supplier
		//	Self:Grid_UpdateChecked(e, cEntityUID, cChecked, oColumn:Name)
		//	Return
		//endcase
  //      RETURN

  //  PRIVATE METHOD ButtonCopy_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		//if Self:GridFormulas1:Rows:Count <> 0
		//	wb("You may create a Report definition from an existing one when the Report definition is empty (does not contain any Formulas/Lines)")
		//	Return
		//endif
		//Self:CopyReport()
  //      RETURN

    PRIVATE METHOD BBINewReport_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:ReportDefinition_AddNew()
        RETURN

    PRIVATE METHOD BBIReportEdit_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:ReportDefinition_Edit()
        RETURN

    PRIVATE METHOD BBIReportDelete_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:ReportDefinition_Delete()
        RETURN

    PRIVATE METHOD BBIReportRefresh_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:ReportDefinition_Refresh()
        RETURN

	// Report Formulas
    PRIVATE METHOD BBIGoFirst_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:GridViewFormulas:MoveBy(-1000000)
        RETURN

    PRIVATE METHOD BBIPrevious_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:GridViewFormulas:MovePrev()
        RETURN

    PRIVATE METHOD BBINext_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:GridViewFormulas:MoveNext()
        RETURN

    PRIVATE METHOD BBIGoLast_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:GridViewFormulas:MoveLastVisible()
        RETURN

    PRIVATE METHOD BBINewFormula_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		IF SELF:LBCReports:SelectedItems == NULL
			wb("No Report selected")
			RETURN
		ENDIF
		SELF:GridViewFormulas_Add()
        RETURN

    PRIVATE METHOD BBIEditFormula_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		LOCAL oRow := (DataRowView)SELF:GridViewFormulas:GetFocusedRow() AS DataRowView
		IF oRow == NULL
			wb("No Formula record selected")
			RETURN
		ENDIF
		SELF:GridViewFormulas_Edit(oRow, SELF:GridViewFormulas:FocusedColumn)
        RETURN

    PRIVATE METHOD BBIDeleteFormula_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		IF SELF:GridViewFormulas:FocusedRowHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
			wb("No Formula record selected")
			RETURN
		ENDIF
		SELF:GridViewFormulas_Delete()
        RETURN

    PRIVATE METHOD BBIFormulaRefresh_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:GridViewFormulas_Refresh()
        RETURN

    PRIVATE METHOD BBIPaste_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:PasteReportFormulas()
        RETURN

    PRIVATE METHOD BBIPrintFormulas_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:PrintPreviewGrid(SELF:GridFormulas)
        RETURN

    PRIVATE METHOD BBICustomItems_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:CustomItems()
        RETURN

    PRIVATE METHOD BBICreateReport_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:XtraReportCustom()
        RETURN

    PRIVATE METHOD LBCReports_SelectedIndexChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		IF SELF:lSuspendNotification
			RETURN
		ENDIF
		SELF:CreateGridFormulas()
        RETURN

	// GridViewFormulas Events
    PRIVATE METHOD GridViewFormulas_FocusedColumnChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.FocusedColumnChangedEventArgs ) AS System.Void
		SELF:SetEditModeOff_Common(GridViewFormulas)
        RETURN

    PRIVATE METHOD GridViewFormulas_CellValueChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
		SELF:SetEditModeOff_Common(SELF:GridViewFormulas)
		SELF:GridViewFormulas_Save(e)
		SELF:lValueChanging := FALSE
        RETURN

    PRIVATE METHOD GridViewFormulas_CellValueChanging( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
		SELF:lValueChanging := TRUE
		// Handles the uForeColor, uBackColor column CellValueChanging to catch the ComboBox selected item
		DO CASE
		CASE e:Column:FieldName == "uForeColor"
			SELF:oChangedForeColor := (System.Drawing.Color)e:Value

		CASE e:Column:FieldName == "uBackColor"
			SELF:oChangedBackColor := (System.Drawing.Color)e:Value

		CASE InListExact(e:Column:FieldName, "ID", "MyItemDescription")
			LOCAL cValue := e:Value:ToString():Trim() AS STRING
			LOCAL nPos := cValue:IndexOf(" ") AS INT

			IF cValue == "0"
				SELF:cEditID := cValue
				SELF:SetEditModeOff_Common(SELF:GridViewFormulas)
				SELF:GridViewFormulas_Save(e)
				SELF:lValueChanging := FALSE
				RETURN
			ENDIF

			IF nPos == -1
				//ErrorBox("Please specify a valid Item ID")
				RETURN
			ENDIF

			SELF:cEditID := cValue:Substring(0, nPos)
			SELF:SetEditModeOff_Common(SELF:GridViewFormulas)
			SELF:GridViewFormulas_Save(e)
			SELF:lValueChanging := FALSE

		//CASE e:Column:FieldName == "ItemSelected"
		//	SELF:lChecked := ToLogic(e:Value)
		ENDCASE
        RETURN

    PRIVATE METHOD GridViewFormulas_BeforeLeaveRow( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.Void
		SELF:BeforeLeaveRow_GridViewFormulas(e)
        RETURN

    PRIVATE METHOD GridViewFormulas_CustomUnboundColumnData( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs ) AS System.Void
		SELF:CustomUnboundColumnData_GridFormulas(e)
        RETURN

    PRIVATE METHOD GridViewFormulas_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		Local oPoint := Self:GridViewFormulas:GridControl:PointToClient(Control.MousePosition) as Point
		Local info := Self:GridViewFormulas:CalcHitInfo(oPoint) as DevExpress.XtraGrid.Views.Grid.ViewInfo.GridHitInfo
		if info:InRow .or. info:InRowCell
			if Self:GridViewFormulas:IsGroupRow(info:RowHandle)
				Return
			endif

			// Get GridRow data into a DataRowView object
			Local oRow as DataRowView
			oRow:=(DataRowView)Self:GridViewFormulas:GetRow(info:RowHandle)

			if info:Column <> NULL
				// Set focused Row/Column (for DoubleClick event)
				//SELF:GridViewFormulas:FocusedRowHandle := info:RowHandle
				//SELF:GridViewFormulas:FocusedColumn := info:Column

				Self:GridViewFormulas_Edit(oRow, info:Column)
			ENDIF
		endif
        RETURN
	PRIVATE METHOD LBCReports_MouseDoubleClick( sender AS System.Object, e AS System.Windows.Forms.MouseEventArgs ) AS System.Void
		SELF:XtraReportCustom()
        RETURN

END CLASS
