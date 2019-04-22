PARTIAL CLASS ApprovalHistoryForm INHERIT System.Windows.Forms.Form
    PRIVATE gcFormHistory AS DevExpress.XtraGrid.GridControl
    PRIVATE gvFormHistory AS DevExpress.XtraGrid.Views.Grid.GridView
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
        SELF:gcFormHistory := DevExpress.XtraGrid.GridControl{}
        SELF:gvFormHistory := DevExpress.XtraGrid.Views.Grid.GridView{}
        ((System.ComponentModel.ISupportInitialize)(SELF:gcFormHistory)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gvFormHistory)):BeginInit()
        SELF:SuspendLayout()
        // 
        // gcFormHistory
        // 
        SELF:gcFormHistory:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:gcFormHistory:Location := System.Drawing.Point{0, 0}
        SELF:gcFormHistory:MainView := SELF:gvFormHistory
        SELF:gcFormHistory:Name := "gcFormHistory"
        SELF:gcFormHistory:Size := System.Drawing.Size{569, 320}
        SELF:gcFormHistory:TabIndex := 0
        SELF:gcFormHistory:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:gvFormHistory })
        // 
        // gvFormHistory
        // 
        SELF:gvFormHistory:GridControl := SELF:gcFormHistory
        SELF:gvFormHistory:Name := "gvFormHistory"
        SELF:gvFormHistory:OptionsBehavior:Editable := FALSE
        SELF:gvFormHistory:OptionsView:ShowGroupPanel := FALSE
        // 
        // ApprovalHistoryForm
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{569, 320}
        SELF:Controls:Add(SELF:gcFormHistory)
        SELF:Name := "ApprovalHistoryForm"
        SELF:ShowIcon := FALSE
        SELF:StartPosition := System.Windows.Forms.FormStartPosition.CenterParent
        SELF:Text := "Form History"
        SELF:Load += System.EventHandler{ SELF, @ApprovalHistoryForm_Load() }
        ((System.ComponentModel.ISupportInitialize)(SELF:gcFormHistory)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gvFormHistory)):EndInit()
        SELF:ResumeLayout(FALSE)
    PRIVATE METHOD ApprovalHistoryForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		oSoftway := Softway{}    
	RETURN

END CLASS
