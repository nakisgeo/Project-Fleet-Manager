PARTIAL CLASS MatchForm INHERIT System.Windows.Forms.Form
    PRIVATE gridControl1 AS DevExpress.XtraGrid.GridControl
    PRIVATE gridView1 AS DevExpress.XtraGrid.Views.Grid.GridView
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
        SELF:gridControl1:Size := System.Drawing.Size{816, 336}
        SELF:gridControl1:TabIndex := 1
        SELF:gridControl1:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:gridView1 })
        // 
        // gridView1
        // 
        SELF:gridView1:GridControl := SELF:gridControl1
        SELF:gridView1:Name := "gridView1"
        SELF:gridView1:OptionsBehavior:ReadOnly := TRUE
        SELF:gridView1:OptionsFind:AlwaysVisible := TRUE
        SELF:gridView1:OptionsView:ShowGroupPanel := FALSE
        // 
        // MatchForm
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{816, 336}
        SELF:Controls:Add(SELF:gridControl1)
        SELF:Name := "MatchForm"
        SELF:ShowIcon := FALSE
        SELF:ShowInTaskbar := FALSE
        SELF:Text := "MatchForm"
        SELF:Load += System.EventHandler{ SELF, @MatchForm_Load() }
        ((System.ComponentModel.ISupportInitialize)(SELF:gridControl1)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridView1)):EndInit()
        SELF:ResumeLayout(FALSE)
		
	PRIVATE METHOD MatchForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:MatchFormOnLoad()
        RETURN

END CLASS
