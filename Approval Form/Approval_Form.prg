PARTIAL CLASS Approval_Form INHERIT System.Windows.Forms.Form
    EXPORT gridControl1 AS DevExpress.XtraGrid.GridControl
    EXPORT gridView1 AS DevExpress.XtraGrid.Views.Grid.GridView
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
        SELF:gridControl1 := DevExpress.XtraGrid.GridControl{}
        SELF:gridView1 := DevExpress.XtraGrid.Views.Grid.GridView{}
        ((System.ComponentModel.ISupportInitialize)(SELF:gridControl1)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridView1)):BeginInit()
        SELF:SuspendLayout()
        // 
        // gridControl1
        // 
        SELF:gridControl1:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:gridControl1:Location := System.Drawing.Point{0, 0}
        SELF:gridControl1:MainView := SELF:gridView1
        SELF:gridControl1:Name := "gridControl1"
        SELF:gridControl1:Size := System.Drawing.Size{1444, 448}
        SELF:gridControl1:TabIndex := 0
        SELF:gridControl1:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:gridView1 })
        // 
        // gridView1
        // 
        SELF:gridView1:GridControl := SELF:gridControl1
        SELF:gridView1:Name := "gridView1"
        SELF:gridView1:OptionsBehavior:AutoExpandAllGroups := TRUE
        SELF:gridView1:OptionsCustomization:AllowColumnMoving := FALSE
        SELF:gridView1:OptionsCustomization:AllowGroup := FALSE
        SELF:gridView1:OptionsFind:AlwaysVisible := TRUE
        SELF:gridView1:OptionsLayout:StoreAppearance := TRUE
        SELF:gridView1:OptionsMenu:EnableFooterMenu := FALSE
        SELF:gridView1:OptionsMenu:EnableGroupPanelMenu := FALSE
        SELF:gridView1:OptionsMenu:ShowGroupSortSummaryItems := FALSE
        SELF:gridView1:OptionsView:GroupFooterShowMode := DevExpress.XtraGrid.Views.Grid.GroupFooterShowMode.Hidden
        SELF:gridView1:OptionsView:ShowChildrenInGroupPanel := TRUE
        SELF:gridView1:OptionsView:ShowGroupExpandCollapseButtons := FALSE
        SELF:gridView1:OptionsView:ShowGroupPanel := FALSE
        SELF:gridView1:RowCellStyle += DevExpress.XtraGrid.Views.Grid.RowCellStyleEventHandler{ SELF, @gridView1_RowCellStyle() }
        SELF:gridView1:RowStyle += DevExpress.XtraGrid.Views.Grid.RowStyleEventHandler{ SELF, @gridView1_RowStyle() }
        SELF:gridView1:CustomColumnSort += DevExpress.XtraGrid.Views.Base.CustomColumnSortEventHandler{ SELF, @gridView1_CustomColumnSort() }
        SELF:gridView1:CustomUnboundColumnData += DevExpress.XtraGrid.Views.Base.CustomColumnDataEventHandler{ SELF, @gridView1_CustomUnboundColumnData() }
        SELF:gridView1:DoubleClick += System.EventHandler{ SELF, @gridView1_DoubleClick() }
        // 
        // Approval_Form
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{1444, 448}
        SELF:Controls:Add(SELF:gridControl1)
        SELF:Name := "Approval_Form"
        SELF:ShowIcon := FALSE
        SELF:Text := "My Approvals"
        SELF:FormClosed += System.Windows.Forms.FormClosedEventHandler{ SELF, @Approval_Form_FormClosed() }
        SELF:Load += System.EventHandler{ SELF, @Approval_Form_Load() }
        ((System.ComponentModel.ISupportInitialize)(SELF:gridControl1)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridView1)):EndInit()
        SELF:ResumeLayout(FALSE)
    PRIVATE METHOD Approval_Form_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:Approval_Form_OnLoad()
        RETURN
    PRIVATE METHOD gridView1_CustomUnboundColumnData( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs ) AS System.Void
			self:CustomUnboundColumnData_Companies(e)
		RETURN
    PRIVATE METHOD gridView1_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:DoubleClickOnView(sender,e)
        RETURN
    PRIVATE METHOD gridView1_RowStyle( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Grid.RowStyleEventArgs ) AS System.Void
			//SELF:myRowStyle(sender,e)
        RETURN
    PRIVATE METHOD gridView1_RowCellStyle( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Grid.RowCellStyleEventArgs ) AS System.Void
			SELF:myRowStyle(sender,e)
        RETURN
    PRIVATE METHOD Approval_Form_FormClosed( sender AS System.Object, e AS System.Windows.Forms.FormClosedEventArgs ) AS System.Void
			oMainForm:oMyApproval_Form := null
		RETURN
    PRIVATE METHOD gridView1_CustomColumnSort( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CustomColumnSortEventArgs ) AS System.Void
			SELF:customColumnSort(sender,e)
		RETURN

END CLASS
