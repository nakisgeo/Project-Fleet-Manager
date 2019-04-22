PARTIAL CLASS CopyReportDialog INHERIT DevExpress.XtraEditors.XtraForm
    PRIVATE buttonCancel AS System.Windows.Forms.Button
    PRIVATE buttonOK AS System.Windows.Forms.Button
    PRIVATE CBReports AS System.Windows.Forms.ComboBox
    PRIVATE labelPasteFrom AS System.Windows.Forms.Label
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
        SELF:labelPasteFrom := System.Windows.Forms.Label{}
        SELF:CBReports := System.Windows.Forms.ComboBox{}
        SELF:buttonCancel := System.Windows.Forms.Button{}
        SELF:buttonOK := System.Windows.Forms.Button{}
        SELF:SuspendLayout()
        // 
        // labelPasteFrom
        // 
        SELF:labelPasteFrom:AutoSize := TRUE
        SELF:labelPasteFrom:Location := System.Drawing.Point{15, 15}
        SELF:labelPasteFrom:Name := "labelPasteFrom"
        SELF:labelPasteFrom:Size := System.Drawing.Size{219, 13}
        SELF:labelPasteFrom:TabIndex := 0
        SELF:labelPasteFrom:Text := "Paste Formula records from existing Report:"
        // 
        // CBReports
        // 
        SELF:CBReports:DropDownStyle := System.Windows.Forms.ComboBoxStyle.DropDownList
        SELF:CBReports:FormattingEnabled := TRUE
        SELF:CBReports:Location := System.Drawing.Point{18, 40}
        SELF:CBReports:Name := "CBReports"
        SELF:CBReports:Size := System.Drawing.Size{254, 21}
        SELF:CBReports:TabIndex := 1
        // 
        // buttonCancel
        // 
        SELF:buttonCancel:DialogResult := System.Windows.Forms.DialogResult.Cancel
        SELF:buttonCancel:Location := System.Drawing.Point{197, 125}
        SELF:buttonCancel:Name := "buttonCancel"
        SELF:buttonCancel:Size := System.Drawing.Size{75, 25}
        SELF:buttonCancel:TabIndex := 18
        SELF:buttonCancel:Text := "Cancel"
        SELF:buttonCancel:UseVisualStyleBackColor := TRUE
        // 
        // buttonOK
        // 
        SELF:buttonOK:Location := System.Drawing.Point{197, 80}
        SELF:buttonOK:Name := "buttonOK"
        SELF:buttonOK:Size := System.Drawing.Size{75, 25}
        SELF:buttonOK:TabIndex := 17
        SELF:buttonOK:Text := "OK"
        SELF:buttonOK:UseVisualStyleBackColor := TRUE
        SELF:buttonOK:Click += System.EventHandler{ SELF, @buttonOK_Click() }
        // 
        // CopyReportDialog
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:CancelButton := SELF:buttonCancel
        SELF:ClientSize := System.Drawing.Size{289, 164}
        SELF:Controls:Add(SELF:buttonCancel)
        SELF:Controls:Add(SELF:buttonOK)
        SELF:Controls:Add(SELF:CBReports)
        SELF:Controls:Add(SELF:labelPasteFrom)
        SELF:MaximizeBox := FALSE
        SELF:MinimizeBox := FALSE
        SELF:Name := "CopyReportDialog"
        SELF:StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen
        SELF:Text := "Paste Formula records"
        SELF:Load += System.EventHandler{ SELF, @CopyReportDialog_Load() }
        SELF:ResumeLayout(FALSE)
        SELF:PerformLayout()
    PRIVATE METHOD CopyReportDialog_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:CopyReportDialog_OnLoad()
        RETURN

    PRIVATE METHOD buttonOK_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:PasteReportFormulas()
        RETURN

END CLASS
