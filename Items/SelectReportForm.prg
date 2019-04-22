#USING System.Windows.Forms
#Using DevExpress.XtraEditors.Controls 

PARTIAL CLASS SelectReportForm INHERIT System.Windows.Forms.Form
    PRIVATE tabControl1 AS System.Windows.Forms.TabControl
    PRIVATE tabPage1 AS System.Windows.Forms.TabPage
    EXPORT LBCReports AS DevExpress.XtraEditors.ListBoxControl
    PRIVATE tabPage2 AS System.Windows.Forms.TabPage
    EXPORT LBCOfficeReports AS DevExpress.XtraEditors.ListBoxControl
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
        SELF:tabControl1 := System.Windows.Forms.TabControl{}
        SELF:tabPage1 := System.Windows.Forms.TabPage{}
        SELF:LBCReports := DevExpress.XtraEditors.ListBoxControl{}
        SELF:tabPage2 := System.Windows.Forms.TabPage{}
        SELF:LBCOfficeReports := DevExpress.XtraEditors.ListBoxControl{}
        SELF:tabControl1:SuspendLayout()
        SELF:tabPage1:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:LBCReports)):BeginInit()
        SELF:tabPage2:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:LBCOfficeReports)):BeginInit()
        SELF:SuspendLayout()
        // 
        // tabControl1
        // 
        SELF:tabControl1:Controls:Add(SELF:tabPage1)
        SELF:tabControl1:Controls:Add(SELF:tabPage2)
        SELF:tabControl1:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:tabControl1:Location := System.Drawing.Point{0, 0}
        SELF:tabControl1:Name := "tabControl1"
        SELF:tabControl1:SelectedIndex := 0
        SELF:tabControl1:Size := System.Drawing.Size{284, 261}
        SELF:tabControl1:TabIndex := 1
        // 
        // tabPage1
        // 
        SELF:tabPage1:Controls:Add(SELF:LBCReports)
        SELF:tabPage1:Location := System.Drawing.Point{4, 22}
        SELF:tabPage1:Name := "tabPage1"
        SELF:tabPage1:Padding := System.Windows.Forms.Padding{3}
        SELF:tabPage1:Size := System.Drawing.Size{276, 235}
        SELF:tabPage1:TabIndex := 0
        SELF:tabPage1:Text := "Vessel"
        SELF:tabPage1:UseVisualStyleBackColor := TRUE
        // 
        // LBCReports
        // 
        SELF:LBCReports:Appearance:Font := System.Drawing.Font{"Lucida Console", ((Single) 8.25)}
        SELF:LBCReports:Appearance:Options:UseFont := TRUE
        SELF:LBCReports:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:LBCReports:HorizontalScrollbar := TRUE
        SELF:LBCReports:Location := System.Drawing.Point{3, 3}
        SELF:LBCReports:Name := "LBCReports"
        SELF:LBCReports:Size := System.Drawing.Size{270, 229}
        SELF:LBCReports:TabIndex := 1
        SELF:LBCReports:DoubleClick += System.EventHandler{ SELF, @LBCReports_DoubleClick() }
        // 
        // tabPage2
        // 
        SELF:tabPage2:Controls:Add(SELF:LBCOfficeReports)
        SELF:tabPage2:Location := System.Drawing.Point{4, 22}
        SELF:tabPage2:Name := "tabPage2"
        SELF:tabPage2:Padding := System.Windows.Forms.Padding{3}
        SELF:tabPage2:Size := System.Drawing.Size{276, 235}
        SELF:tabPage2:TabIndex := 1
        SELF:tabPage2:Text := "Office"
        SELF:tabPage2:UseVisualStyleBackColor := TRUE
        // 
        // LBCOfficeReports
        // 
        SELF:LBCOfficeReports:Appearance:Font := System.Drawing.Font{"Lucida Console", ((Single) 8.25)}
        SELF:LBCOfficeReports:Appearance:Options:UseFont := TRUE
        SELF:LBCOfficeReports:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:LBCOfficeReports:HorizontalScrollbar := TRUE
        SELF:LBCOfficeReports:Location := System.Drawing.Point{3, 3}
        SELF:LBCOfficeReports:Name := "LBCOfficeReports"
        SELF:LBCOfficeReports:Size := System.Drawing.Size{270, 229}
        SELF:LBCOfficeReports:TabIndex := 2
        SELF:LBCOfficeReports:DoubleClick += System.EventHandler{ SELF, @LBCOfficeReports_DoubleClick() }
        // 
        // SelectReportForm
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{284, 261}
        SELF:Controls:Add(SELF:tabControl1)
        SELF:Name := "SelectReportForm"
        SELF:StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen
        SELF:Text := "Select Report"
        SELF:Load += System.EventHandler{ SELF, @SelectReportForm_Load() }
        SELF:tabControl1:ResumeLayout(FALSE)
        SELF:tabPage1:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:LBCReports)):EndInit()
        SELF:tabPage2:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:LBCOfficeReports)):EndInit()
        SELF:ResumeLayout(FALSE)
    PRIVATE METHOD SelectReportForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:SelectReportForm_OnLoad()
        RETURN

    PRIVATE METHOD LBCReports_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:cReportUID := SELF:LBCReports:SelectedValue:ToString()
		SELF:oMyLBControl := SELF:LBCReports
		SELF:DialogResult := DialogResult.OK
		SELF:Close()
        RETURN

    PRIVATE METHOD LBCOfficeReports_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:cReportUID := SELF:LBCOfficeReports:SelectedValue:ToString()
		SELF:oMyLBControl := SELF:LBCOfficeReports
		SELF:DialogResult := DialogResult.OK
		SELF:Close()
        RETURN

END CLASS
