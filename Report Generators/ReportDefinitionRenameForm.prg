CLASS ReportDefinitionRenameForm INHERIT DevExpress.XtraEditors.XtraForm
    EXPORT ReportName AS DevExpress.XtraEditors.TextEdit
    PRIVATE ButtonRename AS DevExpress.XtraEditors.SimpleButton
    PRIVATE ButtonCancel AS DevExpress.XtraEditors.SimpleButton
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
        SELF:ReportName := DevExpress.XtraEditors.TextEdit{}
        SELF:ButtonRename := DevExpress.XtraEditors.SimpleButton{}
        SELF:ButtonCancel := DevExpress.XtraEditors.SimpleButton{}
        ((System.ComponentModel.ISupportInitialize)(SELF:ReportName:Properties)):BeginInit()
        SELF:SuspendLayout()
        // 
        // ReportName
        // 
        SELF:ReportName:Location := System.Drawing.Point{15, 15}
        SELF:ReportName:Name := "ReportName"
        SELF:ReportName:Size := System.Drawing.Size{255, 20}
        SELF:ReportName:TabIndex := 0
        // 
        // ButtonRename
        // 
        SELF:ButtonRename:DialogResult := System.Windows.Forms.DialogResult.OK
        SELF:ButtonRename:Location := System.Drawing.Point{50, 50}
        SELF:ButtonRename:Name := "ButtonRename"
        SELF:ButtonRename:Size := System.Drawing.Size{75, 23}
        SELF:ButtonRename:TabIndex := 1
        SELF:ButtonRename:Text := "Rename"
        // 
        // ButtonCancel
        // 
        SELF:ButtonCancel:DialogResult := System.Windows.Forms.DialogResult.Cancel
        SELF:ButtonCancel:Location := System.Drawing.Point{170, 50}
        SELF:ButtonCancel:Name := "ButtonCancel"
        SELF:ButtonCancel:Size := System.Drawing.Size{75, 23}
        SELF:ButtonCancel:TabIndex := 2
        SELF:ButtonCancel:Text := "Cancel"
        // 
        // ReportDefinitionRenameForm
        // 
        SELF:AcceptButton := SELF:ButtonRename
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:CancelButton := SELF:ButtonCancel
        SELF:ClientSize := System.Drawing.Size{284, 87}
        SELF:Controls:Add(SELF:ButtonCancel)
        SELF:Controls:Add(SELF:ButtonRename)
        SELF:Controls:Add(SELF:ReportName)
        SELF:MaximizeBox := FALSE
        SELF:MinimizeBox := FALSE
        SELF:Name := "ReportDefinitionRenameForm"
        SELF:StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen
        SELF:Text := "Rename Report"
        ((System.ComponentModel.ISupportInitialize)(SELF:ReportName:Properties)):EndInit()
        SELF:ResumeLayout(FALSE)

END CLASS
