#Using System.Windows.Forms
PARTIAL CLASS TableReportsSelectionForm INHERIT System.Windows.Forms.Form
    EXPORT DateTo AS DevExpress.XtraEditors.DateEdit
    EXPORT DateFrom AS DevExpress.XtraEditors.DateEdit
    PRIVATE label2 AS System.Windows.Forms.Label
    PRIVATE label1 AS System.Windows.Forms.Label
    PRIVATE ItemsListView AS System.Windows.Forms.ListView
    EXPORT Item AS System.Windows.Forms.ColumnHeader
    EXPORT UID AS System.Windows.Forms.ColumnHeader
    PRIVATE button1 AS System.Windows.Forms.Button
    PRIVATE oColHeaderValue AS System.Windows.Forms.ColumnHeader
    PRIVATE label3 AS System.Windows.Forms.Label
    PRIVATE txtValue AS System.Windows.Forms.TextBox
    PRIVATE ColumnInt AS System.Windows.Forms.ColumnHeader
    PRIVATE ckbIncludeStatistics AS System.Windows.Forms.CheckBox
    PRIVATE cmbStatus AS System.Windows.Forms.ComboBox
    PRIVATE btnReport AS System.Windows.Forms.Button
    PRIVATE ckbAllVessels AS System.Windows.Forms.CheckBox
    PRIVATE labelToCheck AS System.Windows.Forms.Label
    PRIVATE txtFieldNameToCheck AS System.Windows.Forms.TextBox
    PRIVATE txtReport_UID AS System.Windows.Forms.TextBox
    PRIVATE txtProgress AS System.Windows.Forms.TextBox
    PRIVATE cmbRole AS System.Windows.Forms.ComboBox
    PRIVATE labelRole AS System.Windows.Forms.Label
    PRIVATE btnSEReport AS System.Windows.Forms.Button
    EXPORT lvVessels AS System.Windows.Forms.ListView
    PRIVATE VesselName AS System.Windows.Forms.ColumnHeader
    PRIVATE Fleet AS System.Windows.Forms.ColumnHeader
    PRIVATE panelControl1 AS DevExpress.XtraEditors.PanelControl
    PRIVATE gcResults AS DevExpress.XtraGrid.GridControl
    EXPORT gvResults AS DevExpress.XtraGrid.Views.Grid.GridView
    PRIVATE splitContainerControl1 AS DevExpress.XtraEditors.SplitContainerControl
    PRIVATE gcDetails AS DevExpress.XtraGrid.GridControl
    EXPORT gvDetails AS DevExpress.XtraGrid.Views.Grid.GridView
    PRIVATE ckbExcel AS System.Windows.Forms.CheckBox
    PRIVATE ckbComAndCA AS System.Windows.Forms.CheckBox
    PRIVATE bttnCheckAllVessels AS System.Windows.Forms.Button
    PRIVATE contexMenuDetails AS System.Windows.Forms.ContextMenuStrip
    PRIVATE toolStripDetailsShowReport AS System.Windows.Forms.ToolStripMenuItem
    PRIVATE editResultsToolStripMenuItem AS System.Windows.Forms.ToolStripMenuItem
    PRIVATE ckbShowOnlySubmittedReports AS System.Windows.Forms.CheckBox
    PRIVATE toolStripMenuItemLocateFinding AS System.Windows.Forms.ToolStripMenuItem
    PRIVATE bttnCategoriesVessels AS System.Windows.Forms.Button
    PRIVATE bttnCategoriesSupents AS System.Windows.Forms.Button
    PRIVATE bttnOverdue AS System.Windows.Forms.Button
    PRIVATE exportGridToExcelToolStripMenuItem AS System.Windows.Forms.ToolStripMenuItem
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
        SELF:DateTo := DevExpress.XtraEditors.DateEdit{}
        SELF:DateFrom := DevExpress.XtraEditors.DateEdit{}
        SELF:label2 := System.Windows.Forms.Label{}
        SELF:label1 := System.Windows.Forms.Label{}
        SELF:ItemsListView := System.Windows.Forms.ListView{}
        SELF:Item := System.Windows.Forms.ColumnHeader{}
        SELF:UID := System.Windows.Forms.ColumnHeader{}
        SELF:oColHeaderValue := System.Windows.Forms.ColumnHeader{}
        SELF:ColumnInt := System.Windows.Forms.ColumnHeader{}
        SELF:button1 := System.Windows.Forms.Button{}
        SELF:txtValue := System.Windows.Forms.TextBox{}
        SELF:label3 := System.Windows.Forms.Label{}
        SELF:ckbIncludeStatistics := System.Windows.Forms.CheckBox{}
        SELF:labelToCheck := System.Windows.Forms.Label{}
        SELF:cmbStatus := System.Windows.Forms.ComboBox{}
        SELF:btnReport := System.Windows.Forms.Button{}
        SELF:ckbAllVessels := System.Windows.Forms.CheckBox{}
        SELF:txtFieldNameToCheck := System.Windows.Forms.TextBox{}
        SELF:txtReport_UID := System.Windows.Forms.TextBox{}
        SELF:txtProgress := System.Windows.Forms.TextBox{}
        SELF:cmbRole := System.Windows.Forms.ComboBox{}
        SELF:labelRole := System.Windows.Forms.Label{}
        SELF:btnSEReport := System.Windows.Forms.Button{}
        SELF:lvVessels := System.Windows.Forms.ListView{}
        SELF:VesselName := System.Windows.Forms.ColumnHeader{}
        SELF:Fleet := System.Windows.Forms.ColumnHeader{}
        SELF:panelControl1 := DevExpress.XtraEditors.PanelControl{}
        SELF:splitContainerControl1 := DevExpress.XtraEditors.SplitContainerControl{}
        SELF:gcResults := DevExpress.XtraGrid.GridControl{}
        SELF:gvResults := DevExpress.XtraGrid.Views.Grid.GridView{}
        SELF:gcDetails := DevExpress.XtraGrid.GridControl{}
        SELF:contexMenuDetails := System.Windows.Forms.ContextMenuStrip{SELF:components}
        SELF:toolStripMenuItemLocateFinding := System.Windows.Forms.ToolStripMenuItem{}
        SELF:toolStripDetailsShowReport := System.Windows.Forms.ToolStripMenuItem{}
        SELF:editResultsToolStripMenuItem := System.Windows.Forms.ToolStripMenuItem{}
        SELF:exportGridToExcelToolStripMenuItem := System.Windows.Forms.ToolStripMenuItem{}
        SELF:gvDetails := DevExpress.XtraGrid.Views.Grid.GridView{}
        SELF:ckbExcel := System.Windows.Forms.CheckBox{}
        SELF:ckbComAndCA := System.Windows.Forms.CheckBox{}
        SELF:bttnCheckAllVessels := System.Windows.Forms.Button{}
        SELF:ckbShowOnlySubmittedReports := System.Windows.Forms.CheckBox{}
        SELF:bttnCategoriesVessels := System.Windows.Forms.Button{}
        SELF:bttnCategoriesSupents := System.Windows.Forms.Button{}
        SELF:bttnOverdue := System.Windows.Forms.Button{}
        ((System.ComponentModel.ISupportInitialize)(SELF:DateTo:Properties:CalendarTimeProperties)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:DateTo:Properties)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:DateFrom:Properties:CalendarTimeProperties)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:DateFrom:Properties)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:panelControl1)):BeginInit()
        SELF:panelControl1:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl1)):BeginInit()
        SELF:splitContainerControl1:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:gcResults)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gvResults)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gcDetails)):BeginInit()
        SELF:contexMenuDetails:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:gvDetails)):BeginInit()
        SELF:SuspendLayout()
        // 
        // DateTo
        // 
        SELF:DateTo:EditValue := NULL
        SELF:DateTo:Location := System.Drawing.Point{361, 37}
        SELF:DateTo:Name := "DateTo"
        SELF:DateTo:Properties:AllowNullInput := DevExpress.Utils.DefaultBoolean.False
        SELF:DateTo:Properties:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{DevExpress.XtraEditors.Controls.ButtonPredefines.Combo} })
        SELF:DateTo:Properties:CalendarTimeProperties:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{} })
        SELF:DateTo:Properties:DisplayFormat:FormatString := "dd/MM/yy  HH:mm:ss"
        SELF:DateTo:Properties:DisplayFormat:FormatType := DevExpress.Utils.FormatType.DateTime
        SELF:DateTo:Properties:EditFormat:FormatString := "dd/MM/yy  HH:mm:ss"
        SELF:DateTo:Properties:EditFormat:FormatType := DevExpress.Utils.FormatType.DateTime
        SELF:DateTo:Properties:Mask:EditMask := "dd/MM/yy  HH:mm:ss"
        SELF:DateTo:Properties:Mask:MaskType := DevExpress.XtraEditors.Mask.MaskType.DateTimeAdvancingCaret
        SELF:DateTo:Properties:ShowWeekNumbers := TRUE
        SELF:DateTo:Size := System.Drawing.Size{130, 20}
        SELF:DateTo:TabIndex := 31
        // 
        // DateFrom
        // 
        SELF:DateFrom:EditValue := NULL
        SELF:DateFrom:Location := System.Drawing.Point{361, 12}
        SELF:DateFrom:Name := "DateFrom"
        SELF:DateFrom:Properties:AllowNullInput := DevExpress.Utils.DefaultBoolean.False
        SELF:DateFrom:Properties:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{DevExpress.XtraEditors.Controls.ButtonPredefines.Combo} })
        SELF:DateFrom:Properties:CalendarTimeProperties:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{} })
        SELF:DateFrom:Properties:DisplayFormat:FormatString := "dd/MM/yy  HH:mm:ss"
        SELF:DateFrom:Properties:DisplayFormat:FormatType := DevExpress.Utils.FormatType.DateTime
        SELF:DateFrom:Properties:EditFormat:FormatString := "dd/MM/yy  HH:mm:ss"
        SELF:DateFrom:Properties:EditFormat:FormatType := DevExpress.Utils.FormatType.DateTime
        SELF:DateFrom:Properties:Mask:EditMask := "dd/MM/yy  HH:mm:ss"
        SELF:DateFrom:Properties:Mask:MaskType := DevExpress.XtraEditors.Mask.MaskType.DateTimeAdvancingCaret
        SELF:DateFrom:Properties:ShowWeekNumbers := TRUE
        SELF:DateFrom:Size := System.Drawing.Size{130, 20}
        SELF:DateFrom:TabIndex := 30
        // 
        // label2
        // 
        SELF:label2:AutoSize := TRUE
        SELF:label2:Location := System.Drawing.Point{301, 40}
        SELF:label2:Name := "label2"
        SELF:label2:Size := System.Drawing.Size{60, 13}
        SELF:label2:TabIndex := 29
        SELF:label2:Text := "Up to date:"
        // 
        // label1
        // 
        SELF:label1:AutoSize := TRUE
        SELF:label1:Location := System.Drawing.Point{301, 15}
        SELF:label1:Name := "label1"
        SELF:label1:Size := System.Drawing.Size{57, 13}
        SELF:label1:TabIndex := 28
        SELF:label1:Text := "From date:"
        // 
        // ItemsListView
        // 
        SELF:ItemsListView:Anchor := ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) ;
                    | System.Windows.Forms.AnchorStyles.Left) ;
                    | System.Windows.Forms.AnchorStyles.Right)))
        SELF:ItemsListView:Columns:AddRange(<System.Windows.Forms.ColumnHeader>{ SELF:Item, SELF:UID, SELF:oColHeaderValue, SELF:ColumnInt })
        SELF:ItemsListView:FullRowSelect := TRUE
        SELF:ItemsListView:GridLines := TRUE
        SELF:ItemsListView:HideSelection := FALSE
        SELF:ItemsListView:Location := System.Drawing.Point{48, 304}
        SELF:ItemsListView:Name := "ItemsListView"
        SELF:ItemsListView:Size := System.Drawing.Size{1000, 126}
        SELF:ItemsListView:TabIndex := 32
        SELF:ItemsListView:UseCompatibleStateImageBehavior := FALSE
        SELF:ItemsListView:View := System.Windows.Forms.View.Details
        SELF:ItemsListView:SelectedIndexChanged += System.EventHandler{ SELF, @ItemsListView_SelectedIndexChanged() }
        SELF:ItemsListView:KeyDown += System.Windows.Forms.KeyEventHandler{ SELF, @ItemsListView_KeyDown() }
        SELF:ItemsListView:MouseUp += System.Windows.Forms.MouseEventHandler{ SELF, @ItemsListView_MouseUp() }
        // 
        // Item
        // 
        SELF:Item:Tag := "1"
        SELF:Item:Text := "Item Name"
        SELF:Item:Width := 333
        // 
        // UID
        // 
        SELF:UID:Tag := "2"
        SELF:UID:Width := 0
        // 
        // Value
        // 
        SELF:oColHeaderValue:Text := "Values"
        SELF:oColHeaderValue:Width := 265
        // 
        // ColumnInt
        // 
        SELF:ColumnInt:Text := ""
        SELF:ColumnInt:Width := 0
        // 
        // button1
        // 
        SELF:button1:Location := System.Drawing.Point{176, 261}
        SELF:button1:Name := "button1"
        SELF:button1:Size := System.Drawing.Size{75, 23}
        SELF:button1:TabIndex := 33
        SELF:button1:Text := "OK"
        SELF:button1:UseVisualStyleBackColor := TRUE
        SELF:button1:Click += System.EventHandler{ SELF, @button1_Click() }
        // 
        // txtValue
        // 
        SELF:txtValue:Location := System.Drawing.Point{97, 264}
        SELF:txtValue:Name := "txtValue"
        SELF:txtValue:Size := System.Drawing.Size{61, 20}
        SELF:txtValue:TabIndex := 34
        SELF:txtValue:TextChanged += System.EventHandler{ SELF, @txtValue_TextChanged() }
        // 
        // label3
        // 
        SELF:label3:AutoSize := TRUE
        SELF:label3:Location := System.Drawing.Point{45, 267}
        SELF:label3:Name := "label3"
        SELF:label3:Size := System.Drawing.Size{51, 13}
        SELF:label3:TabIndex := 35
        SELF:label3:Text := "Value(s) :"
        // 
        // ckbIncludeStatistics
        // 
        SELF:ckbIncludeStatistics:AutoSize := TRUE
        SELF:ckbIncludeStatistics:Location := System.Drawing.Point{387, 72}
        SELF:ckbIncludeStatistics:Name := "ckbIncludeStatistics"
        SELF:ckbIncludeStatistics:Size := System.Drawing.Size{106, 17}
        SELF:ckbIncludeStatistics:TabIndex := 36
        SELF:ckbIncludeStatistics:TabStop := FALSE
        SELF:ckbIncludeStatistics:Text := "Include Statistics"
        SELF:ckbIncludeStatistics:UseVisualStyleBackColor := TRUE
        SELF:ckbIncludeStatistics:Visible := FALSE
        // 
        // labelToCheck
        // 
        SELF:labelToCheck:AutoSize := TRUE
        SELF:labelToCheck:Location := System.Drawing.Point{313, 161}
        SELF:labelToCheck:Name := "labelToCheck"
        SELF:labelToCheck:Size := System.Drawing.Size{43, 13}
        SELF:labelToCheck:TabIndex := 37
        SELF:labelToCheck:Text := "Status :"
        // 
        // cmbStatus
        // 
        SELF:cmbStatus:FormattingEnabled := TRUE
        SELF:cmbStatus:Items:AddRange(<System.Object>{ "NO", "NOT SEEN", "YES", "N/A" })
        SELF:cmbStatus:Location := System.Drawing.Point{363, 158}
        SELF:cmbStatus:Name := "cmbStatus"
        SELF:cmbStatus:Size := System.Drawing.Size{128, 21}
        SELF:cmbStatus:TabIndex := 38
        SELF:cmbStatus:SelectionChangeCommitted += System.EventHandler{ SELF, @cmbStatus_SelectionChangeCommitted() }
        // 
        // btnReport
        // 
        SELF:btnReport:Location := System.Drawing.Point{503, 156}
        SELF:btnReport:Name := "btnReport"
        SELF:btnReport:Size := System.Drawing.Size{75, 23}
        SELF:btnReport:TabIndex := 39
        SELF:btnReport:Text := "Report"
        SELF:btnReport:UseVisualStyleBackColor := TRUE
        SELF:btnReport:Click += System.EventHandler{ SELF, @button2_Click() }
        // 
        // ckbAllVessels
        // 
        SELF:ckbAllVessels:AutoSize := TRUE
        SELF:ckbAllVessels:Location := System.Drawing.Point{305, 73}
        SELF:ckbAllVessels:MaximumSize := System.Drawing.Size{76, 17}
        SELF:ckbAllVessels:Name := "ckbAllVessels"
        SELF:ckbAllVessels:Size := System.Drawing.Size{76, 17}
        SELF:ckbAllVessels:TabIndex := 40
        SELF:ckbAllVessels:TabStop := FALSE
        SELF:ckbAllVessels:Text := "All Vessels"
        SELF:ckbAllVessels:UseVisualStyleBackColor := TRUE
        SELF:ckbAllVessels:Visible := FALSE
        // 
        // txtFieldNameToCheck
        // 
        SELF:txtFieldNameToCheck:Location := System.Drawing.Point{295, 264}
        SELF:txtFieldNameToCheck:Name := "txtFieldNameToCheck"
        SELF:txtFieldNameToCheck:Size := System.Drawing.Size{201, 20}
        SELF:txtFieldNameToCheck:TabIndex := 41
        SELF:txtFieldNameToCheck:Text := "Status"
        // 
        // txtReport_UID
        // 
        SELF:txtReport_UID:Location := System.Drawing.Point{515, 263}
        SELF:txtReport_UID:Name := "txtReport_UID"
        SELF:txtReport_UID:Size := System.Drawing.Size{100, 20}
        SELF:txtReport_UID:TabIndex := 42
        SELF:txtReport_UID:Validated += System.EventHandler{ SELF, @txtReport_UID_Validated() }
        // 
        // txtProgress
        // 
        SELF:txtProgress:Anchor := ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) ;
                    | System.Windows.Forms.AnchorStyles.Right)))
        SELF:txtProgress:Location := System.Drawing.Point{637, 6}
        SELF:txtProgress:Multiline := TRUE
        SELF:txtProgress:Name := "txtProgress"
        SELF:txtProgress:ScrollBars := System.Windows.Forms.ScrollBars.Both
        SELF:txtProgress:Size := System.Drawing.Size{841, 222}
        SELF:txtProgress:TabIndex := 43
        // 
        // cmbRole
        // 
        SELF:cmbRole:FormattingEnabled := TRUE
        SELF:cmbRole:Items:AddRange(<System.Object>{ "Superintendent" })
        SELF:cmbRole:Location := System.Drawing.Point{363, 183}
        SELF:cmbRole:Name := "cmbRole"
        SELF:cmbRole:Size := System.Drawing.Size{128, 21}
        SELF:cmbRole:TabIndex := 45
        // 
        // labelRole
        // 
        SELF:labelRole:AutoSize := TRUE
        SELF:labelRole:Location := System.Drawing.Point{321, 186}
        SELF:labelRole:Name := "labelRole"
        SELF:labelRole:Size := System.Drawing.Size{35, 13}
        SELF:labelRole:TabIndex := 44
        SELF:labelRole:Text := "Role :"
        // 
        // btnSEReport
        // 
        SELF:btnSEReport:Location := System.Drawing.Point{503, 181}
        SELF:btnSEReport:Name := "btnSEReport"
        SELF:btnSEReport:Size := System.Drawing.Size{75, 23}
        SELF:btnSEReport:TabIndex := 46
        SELF:btnSEReport:Text := "Report"
        SELF:btnSEReport:UseVisualStyleBackColor := TRUE
        SELF:btnSEReport:Click += System.EventHandler{ SELF, @bttnSEReport_Click() }
        // 
        // lvVessels
        // 
        SELF:lvVessels:CheckBoxes := TRUE
        SELF:lvVessels:Columns:AddRange(<System.Windows.Forms.ColumnHeader>{ SELF:VesselName, SELF:Fleet })
        SELF:lvVessels:Location := System.Drawing.Point{7, 15}
        SELF:lvVessels:Name := "lvVessels"
        SELF:lvVessels:Size := System.Drawing.Size{288, 189}
        SELF:lvVessels:TabIndex := 47
        SELF:lvVessels:UseCompatibleStateImageBehavior := FALSE
        SELF:lvVessels:View := System.Windows.Forms.View.Details
        // 
        // VesselName
        // 
        SELF:VesselName:Text := "VesselName"
        SELF:VesselName:Width := 186
        // 
        // Fleet
        // 
        SELF:Fleet:Text := "Fleet"
        SELF:Fleet:Width := 68
        // 
        // panelControl1
        // 
        SELF:panelControl1:Anchor := ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) ;
                    | System.Windows.Forms.AnchorStyles.Left) ;
                    | System.Windows.Forms.AnchorStyles.Right)))
        SELF:panelControl1:Controls:Add(SELF:splitContainerControl1)
        SELF:panelControl1:Location := System.Drawing.Point{7, 236}
        SELF:panelControl1:Name := "panelControl1"
        SELF:panelControl1:Size := System.Drawing.Size{1479, 366}
        SELF:panelControl1:TabIndex := 48
        // 
        // splitContainerControl1
        // 
        SELF:splitContainerControl1:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:splitContainerControl1:Location := System.Drawing.Point{2, 2}
        SELF:splitContainerControl1:Name := "splitContainerControl1"
        SELF:splitContainerControl1:Panel1:Controls:Add(SELF:gcResults)
        SELF:splitContainerControl1:Panel1:Text := "Panel1"
        SELF:splitContainerControl1:Panel2:Controls:Add(SELF:gcDetails)
        SELF:splitContainerControl1:Panel2:Text := "Panel2"
        SELF:splitContainerControl1:Size := System.Drawing.Size{1475, 362}
        SELF:splitContainerControl1:SplitterPosition := 532
        SELF:splitContainerControl1:TabIndex := 1
        SELF:splitContainerControl1:Text := "splitContainerControl1"
        // 
        // gcResults
        // 
        SELF:gcResults:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:gcResults:Location := System.Drawing.Point{0, 0}
        SELF:gcResults:MainView := SELF:gvResults
        SELF:gcResults:Name := "gcResults"
        SELF:gcResults:Size := System.Drawing.Size{532, 362}
        SELF:gcResults:TabIndex := 0
        SELF:gcResults:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:gvResults })
        // 
        // gvResults
        // 
        SELF:gvResults:GridControl := SELF:gcResults
        SELF:gvResults:Name := "gvResults"
        SELF:gvResults:OptionsBehavior:ReadOnly := TRUE
        SELF:gvResults:OptionsSelection:MultiSelect := TRUE
        SELF:gvResults:OptionsView:ColumnHeaderAutoHeight := DevExpress.Utils.DefaultBoolean.True
        SELF:gvResults:OptionsView:ShowFooter := TRUE
        SELF:gvResults:OptionsView:ShowGroupPanel := FALSE
        SELF:gvResults:SelectionChanged += DevExpress.Data.SelectionChangedEventHandler{ SELF, @gvResults_SelectionChanged() }
        SELF:gvResults:FocusedRowObjectChanged += DevExpress.XtraGrid.Views.Base.FocusedRowObjectChangedEventHandler{ SELF, @gvResults_FocusedRowObjectChanged() }
        // 
        // gcDetails
        // 
        SELF:gcDetails:ContextMenuStrip := SELF:contexMenuDetails
        SELF:gcDetails:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:gcDetails:Location := System.Drawing.Point{0, 0}
        SELF:gcDetails:MainView := SELF:gvDetails
        SELF:gcDetails:Name := "gcDetails"
        SELF:gcDetails:Size := System.Drawing.Size{938, 362}
        SELF:gcDetails:TabIndex := 1
        SELF:gcDetails:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:gvDetails })
        // 
        // contexMenuDetails
        // 
        SELF:contexMenuDetails:Items:AddRange(<System.Windows.Forms.ToolStripItem>{ SELF:toolStripMenuItemLocateFinding, SELF:toolStripDetailsShowReport, SELF:editResultsToolStripMenuItem, SELF:exportGridToExcelToolStripMenuItem })
        SELF:contexMenuDetails:Name := "contexMenuDetails"
        SELF:contexMenuDetails:Size := System.Drawing.Size{220, 92}
        // 
        // toolStripMenuItemLocateFinding
        // 
        SELF:toolStripMenuItemLocateFinding:Name := "toolStripMenuItemLocateFinding"
        SELF:toolStripMenuItemLocateFinding:ShortcutKeys := ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.F)))
        SELF:toolStripMenuItemLocateFinding:Size := System.Drawing.Size{219, 22}
        SELF:toolStripMenuItemLocateFinding:Text := "Locate Finding"
        SELF:toolStripMenuItemLocateFinding:Click += System.EventHandler{ SELF, @toolStripMenuItemLocateFinding_Click() }
        // 
        // toolStripDetailsShowReport
        // 
        SELF:toolStripDetailsShowReport:Name := "toolStripDetailsShowReport"
        SELF:toolStripDetailsShowReport:ShortcutKeys := ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.R)))
        SELF:toolStripDetailsShowReport:Size := System.Drawing.Size{219, 22}
        SELF:toolStripDetailsShowReport:Text := "Show Report"
        SELF:toolStripDetailsShowReport:Click += System.EventHandler{ SELF, @ShowMenuToolStripMenuItem_Click() }
        // 
        // editResultsToolStripMenuItem
        // 
        SELF:editResultsToolStripMenuItem:Name := "editResultsToolStripMenuItem"
        SELF:editResultsToolStripMenuItem:ShortcutKeys := ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.E)))
        SELF:editResultsToolStripMenuItem:Size := System.Drawing.Size{219, 22}
        SELF:editResultsToolStripMenuItem:Text := "Edit Results"
        SELF:editResultsToolStripMenuItem:Click += System.EventHandler{ SELF, @editResultsToolStripMenuItem_Click() }
        // 
        // exportGridToExcelToolStripMenuItem
        // 
        SELF:exportGridToExcelToolStripMenuItem:Name := "exportGridToExcelToolStripMenuItem"
        SELF:exportGridToExcelToolStripMenuItem:ShortcutKeys := ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.P)))
        SELF:exportGridToExcelToolStripMenuItem:Size := System.Drawing.Size{219, 22}
        SELF:exportGridToExcelToolStripMenuItem:Text := "Export Grid To Excel"
        SELF:exportGridToExcelToolStripMenuItem:Click += System.EventHandler{ SELF, @exportGridToExcelToolStripMenuItem_Click() }
        // 
        // gvDetails
        // 
        SELF:gvDetails:GridControl := SELF:gcDetails
        SELF:gvDetails:Name := "gvDetails"
        SELF:gvDetails:OptionsBehavior:Editable := FALSE
        SELF:gvDetails:OptionsBehavior:ReadOnly := TRUE
        SELF:gvDetails:OptionsView:ColumnAutoWidth := FALSE
        SELF:gvDetails:OptionsView:RowAutoHeight := TRUE
        SELF:gvDetails:OptionsView:ShowGroupPanel := FALSE
        SELF:gvDetails:CellValueChanged += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @gvDetails_CellValueChanged() }
        SELF:gvDetails:MouseDown += System.Windows.Forms.MouseEventHandler{ SELF, @gvDetails_MouseDown() }
        // 
        // ckbExcel
        // 
        SELF:ckbExcel:AutoSize := TRUE
        SELF:ckbExcel:Location := System.Drawing.Point{493, 210}
        SELF:ckbExcel:Name := "ckbExcel"
        SELF:ckbExcel:Size := System.Drawing.Size{97, 17}
        SELF:ckbExcel:TabIndex := 49
        SELF:ckbExcel:TabStop := FALSE
        SELF:ckbExcel:Text := "Export to Excel"
        SELF:ckbExcel:UseVisualStyleBackColor := TRUE
        // 
        // ckbComAndCA
        // 
        SELF:ckbComAndCA:AutoSize := TRUE
        SELF:ckbComAndCA:Checked := TRUE
        SELF:ckbComAndCA:CheckState := System.Windows.Forms.CheckState.Checked
        SELF:ckbComAndCA:Location := System.Drawing.Point{316, 210}
        SELF:ckbComAndCA:Name := "ckbComAndCA"
        SELF:ckbComAndCA:Size := System.Drawing.Size{151, 17}
        SELF:ckbComAndCA:TabIndex := 50
        SELF:ckbComAndCA:TabStop := FALSE
        SELF:ckbComAndCA:Text := "Include Comments and CA"
        SELF:ckbComAndCA:UseVisualStyleBackColor := TRUE
        // 
        // bttnCheckAllVessels
        // 
        SELF:bttnCheckAllVessels:Location := System.Drawing.Point{97, 207}
        SELF:bttnCheckAllVessels:Name := "bttnCheckAllVessels"
        SELF:bttnCheckAllVessels:Size := System.Drawing.Size{115, 23}
        SELF:bttnCheckAllVessels:TabIndex := 51
        SELF:bttnCheckAllVessels:Text := "Uncheck All Vessels"
        SELF:bttnCheckAllVessels:UseVisualStyleBackColor := TRUE
        SELF:bttnCheckAllVessels:Click += System.EventHandler{ SELF, @bttnCheckAllVessels_Click() }
        // 
        // ckbShowOnlySubmittedReports
        // 
        SELF:ckbShowOnlySubmittedReports:AutoSize := TRUE
        SELF:ckbShowOnlySubmittedReports:Checked := TRUE
        SELF:ckbShowOnlySubmittedReports:CheckState := System.Windows.Forms.CheckState.Checked
        SELF:ckbShowOnlySubmittedReports:Location := System.Drawing.Point{304, 96}
        SELF:ckbShowOnlySubmittedReports:Name := "ckbShowOnlySubmittedReports"
        SELF:ckbShowOnlySubmittedReports:Size := System.Drawing.Size{167, 17}
        SELF:ckbShowOnlySubmittedReports:TabIndex := 52
        SELF:ckbShowOnlySubmittedReports:TabStop := FALSE
        SELF:ckbShowOnlySubmittedReports:Text := "Show Only Submitted Reports"
        SELF:ckbShowOnlySubmittedReports:UseVisualStyleBackColor := TRUE
        // 
        // bttnCategoriesVessels
        // 
        SELF:bttnCategoriesVessels:Location := System.Drawing.Point{503, 127}
        SELF:bttnCategoriesVessels:Name := "bttnCategoriesVessels"
        SELF:bttnCategoriesVessels:Size := System.Drawing.Size{112, 23}
        SELF:bttnCategoriesVessels:TabIndex := 53
        SELF:bttnCategoriesVessels:Text := "Categories - Vessels"
        SELF:bttnCategoriesVessels:UseVisualStyleBackColor := TRUE
        SELF:bttnCategoriesVessels:Click += System.EventHandler{ SELF, @bttnCategoriesVessels_Click() }
        // 
        // bttnCategoriesSupents
        // 
        SELF:bttnCategoriesSupents:Location := System.Drawing.Point{503, 98}
        SELF:bttnCategoriesSupents:Name := "bttnCategoriesSupents"
        SELF:bttnCategoriesSupents:Size := System.Drawing.Size{112, 23}
        SELF:bttnCategoriesSupents:TabIndex := 54
        SELF:bttnCategoriesSupents:Text := "Categories - Sup/nts"
        SELF:bttnCategoriesSupents:UseVisualStyleBackColor := TRUE
        SELF:bttnCategoriesSupents:Click += System.EventHandler{ SELF, @button2_Click_1() }
        // 
        // bttnOverdue
        // 
        SELF:bttnOverdue:Location := System.Drawing.Point{503, 72}
        SELF:bttnOverdue:Name := "bttnOverdue"
        SELF:bttnOverdue:Size := System.Drawing.Size{112, 23}
        SELF:bttnOverdue:TabIndex := 55
        SELF:bttnOverdue:Text := "Overdue Report"
        SELF:bttnOverdue:UseVisualStyleBackColor := TRUE
        SELF:bttnOverdue:Click += System.EventHandler{ SELF, @bttnOverdue_Click() }
        // 
        // TableReportsSelectionForm
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{1490, 614}
        SELF:Controls:Add(SELF:bttnOverdue)
        SELF:Controls:Add(SELF:bttnCategoriesSupents)
        SELF:Controls:Add(SELF:bttnCategoriesVessels)
        SELF:Controls:Add(SELF:ckbShowOnlySubmittedReports)
        SELF:Controls:Add(SELF:bttnCheckAllVessels)
        SELF:Controls:Add(SELF:ckbComAndCA)
        SELF:Controls:Add(SELF:ckbExcel)
        SELF:Controls:Add(SELF:panelControl1)
        SELF:Controls:Add(SELF:lvVessels)
        SELF:Controls:Add(SELF:btnSEReport)
        SELF:Controls:Add(SELF:cmbRole)
        SELF:Controls:Add(SELF:labelRole)
        SELF:Controls:Add(SELF:txtProgress)
        SELF:Controls:Add(SELF:txtReport_UID)
        SELF:Controls:Add(SELF:txtFieldNameToCheck)
        SELF:Controls:Add(SELF:ckbAllVessels)
        SELF:Controls:Add(SELF:btnReport)
        SELF:Controls:Add(SELF:cmbStatus)
        SELF:Controls:Add(SELF:labelToCheck)
        SELF:Controls:Add(SELF:ckbIncludeStatistics)
        SELF:Controls:Add(SELF:label3)
        SELF:Controls:Add(SELF:txtValue)
        SELF:Controls:Add(SELF:button1)
        SELF:Controls:Add(SELF:ItemsListView)
        SELF:Controls:Add(SELF:DateTo)
        SELF:Controls:Add(SELF:DateFrom)
        SELF:Controls:Add(SELF:label2)
        SELF:Controls:Add(SELF:label1)
        SELF:MinimumSize := System.Drawing.Size{600, 400}
        SELF:Name := "TableReportsSelectionForm"
        SELF:ShowIcon := FALSE
        SELF:Text := "Report Generator"
        SELF:FormClosed += System.Windows.Forms.FormClosedEventHandler{ SELF, @TableReportsSelectionForm_FormClosed() }
        SELF:Load += System.EventHandler{ SELF, @TableReportsSelectionForm_Load() }
        ((System.ComponentModel.ISupportInitialize)(SELF:DateTo:Properties:CalendarTimeProperties)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:DateTo:Properties)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:DateFrom:Properties:CalendarTimeProperties)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:DateFrom:Properties)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:panelControl1)):EndInit()
        SELF:panelControl1:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl1)):EndInit()
        SELF:splitContainerControl1:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:gcResults)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gvResults)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gcDetails)):EndInit()
        SELF:contexMenuDetails:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:gvDetails)):EndInit()
        SELF:ResumeLayout(FALSE)
        SELF:PerformLayout()
    PRIVATE METHOD TableReportsSelectionForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:myOnLoad()
		RETURN
    PRIVATE METHOD button1_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:myOkPressed()
	RETURN
    PRIVATE METHOD ItemsListView_SelectedIndexChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:changedMyIndex()
	RETURN
    PRIVATE METHOD txtValue_TextChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:writtingOnTextView()
		RETURN
    PRIVATE METHOD ItemsListView_MouseUp( sender AS System.Object, e AS System.Windows.Forms.MouseEventArgs ) AS System.Void
			//SELF:txtValue:Focus()
        RETURN
    PRIVATE METHOD ItemsListView_KeyDown( sender AS System.Object, e AS System.Windows.Forms.KeyEventArgs ) AS System.Void
			SELF:txtValue:Focus()
	    RETURN

    PRIVATE METHOD cmbStatus_SelectionChangeCommitted( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			
        RETURN
    PRIVATE METHOD button2_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			IF cmbStatus:Text == ""
				System.Windows.Forms.MessageBox.Show( "Pls select a status" )
				RETURN
			ENDIF
			SELF:gvResults:Columns:Clear()
			SELF:gvDetails:Columns:Clear()
			SELF:btnReport_Clicked()
			SELF:splitContainerControl1:PanelVisibility := DevExpress.XtraEditors.SplitPanelVisibility.Both
			IF !lRegistered
				SELF:gvResults:FocusedRowObjectChanged += DevExpress.XtraGrid.Views.Base.FocusedRowObjectChangedEventHandler{ SELF, @gvResults_FocusedRowObjectChanged() }		
				lRegistered := TRUE
			ENDIF

        RETURN

    PRIVATE METHOD txtReport_UID_Validated( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		cMyReportUID := txtReport_UID:Text    
		SELF:LoadMyListView()
	RETURN

    PRIVATE METHOD bttnSEReport_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			IF cmbRole:Text == ""
				System.Windows.Forms.MessageBox.Show( "Pls select a role." )
				RETURN
			ENDIF
			IF cmbStatus:Text == ""
				System.Windows.Forms.MessageBox.Show( "Pls select a status" )
				RETURN
			ENDIF
			SELF:btnReportPerSE_Clicked()
			SELF:createExcelSuperEng(cMyReportUID,SELF:DateFrom:DateTime,SELF:DateTo:DateTime,TRUE)
        RETURN
    PRIVATE METHOD gvResults_FocusedRowObjectChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.FocusedRowObjectChangedEventArgs ) AS System.Void
		//self:gvResulsFocusedChanged(sender,e)    
	RETURN

    PRIVATE METHOD TableReportsSelectionForm_FormClosed( sender AS System.Object, e AS System.Windows.Forms.FormClosedEventArgs ) AS System.Void
		oMyMainForm:RestartTimerAndFormToNull()
	RETURN

    PRIVATE METHOD bttnCheckAllVessels_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		    IF bttnCheckAllVessels:Text == "Check All Vessels" 
				FOREACH  item AS ListViewItem IN lvVessels:Items
					item:Checked := TRUE
				NEXT
				bttnCheckAllVessels:Text := "Uncheck All Vessels"
			ELSE
				FOREACH  item AS ListViewItem IN lvVessels:Items
					item:Checked := FALSE
				NEXT
				bttnCheckAllVessels:Text := "Check All Vessels"
			ENDIF
	RETURN
    
	
    
    PRIVATE METHOD gvDetails_MouseDown( sender AS System.Object, e AS System.Windows.Forms.MouseEventArgs ) AS System.Void
		gvDetailsMouseDown(sender,e)    
	RETURN

    PRIVATE METHOD ShowMenuToolStripMenuItem_Click( sender AS system.Object,e AS EventArgs ) AS system.void
		SELF:ShowMenuToolStripMenuItemClick(sender,e)
	RETURN

    PRIVATE METHOD editResultsToolStripMenuItem_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:editResultsToolStripMenuItemClick(sender,e)
	RETURN
    PRIVATE METHOD gvDetails_CellValueChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
		SELF:gvDetailsCellValueChanged(sender,e)    
	RETURN

    PRIVATE METHOD toolStripMenuItemLocateFinding_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:LocateFinding()    
	RETURN
    PRIVATE METHOD bttnCategoriesVessels_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		IF cmbStatus:Text == ""
				System.Windows.Forms.MessageBox.Show( "Pls select a status" )
				RETURN
		ENDIF
		SELF:btnReportPerCategoryVessel_Clicked(1)
        RETURN
    PRIVATE METHOD button2_Click_1( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		IF cmbStatus:Text == ""
				System.Windows.Forms.MessageBox.Show( "Pls select a status" )
				RETURN
		ENDIF
		SELF:btnReportPerCategoryVessel_Clicked(2)

        RETURN
    PRIVATE METHOD bttnOverdue_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:btnOverdueReport_Clicked()
	RETURN

    PRIVATE METHOD exportGridToExcelToolStripMenuItem_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:exportGridToExcelToolStripMenuItemClick()
        RETURN

    PRIVATE METHOD gvResults_SelectionChanged( sender AS System.Object, e AS DevExpress.Data.SelectionChangedEventArgs ) AS System.Void

			SELF:gvResultsSelectionChanged()
			

        RETURN

END CLASS
