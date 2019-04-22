PARTIAL CLASS SelectVoyageForm INHERIT DevExpress.XtraEditors.XtraForm
    EXPORT LBCVoyages AS DevExpress.XtraEditors.ListBoxControl
    PRIVATE labelControlVoyages AS DevExpress.XtraEditors.LabelControl
    PRIVATE labelControlRouting AS DevExpress.XtraEditors.LabelControl
    EXPORT LBCRouting AS DevExpress.XtraEditors.ListBoxControl
    PRIVATE ButtonOK AS DevExpress.XtraEditors.SimpleButton
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
        SELF:LBCVoyages := DevExpress.XtraEditors.ListBoxControl{}
        SELF:labelControlVoyages := DevExpress.XtraEditors.LabelControl{}
        SELF:labelControlRouting := DevExpress.XtraEditors.LabelControl{}
        SELF:LBCRouting := DevExpress.XtraEditors.ListBoxControl{}
        SELF:ButtonOK := DevExpress.XtraEditors.SimpleButton{}
        SELF:ButtonCancel := DevExpress.XtraEditors.SimpleButton{}
        ((System.ComponentModel.ISupportInitialize)(SELF:LBCVoyages)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:LBCRouting)):BeginInit()
        SELF:SuspendLayout()
        // 
        // LBCVoyages
        // 
        SELF:LBCVoyages:HorizontalScrollbar := TRUE
        SELF:LBCVoyages:Location := System.Drawing.Point{10, 25}
        SELF:LBCVoyages:Name := "LBCVoyages"
        SELF:LBCVoyages:Size := System.Drawing.Size{762, 335}
        SELF:LBCVoyages:TabIndex := 21
        SELF:LBCVoyages:SelectedIndexChanged += System.EventHandler{ SELF, @LBCVoyages_SelectedIndexChanged() }
        // 
        // labelControlVoyages
        // 
        SELF:labelControlVoyages:Appearance:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
        SELF:labelControlVoyages:AutoSizeMode := DevExpress.XtraEditors.LabelAutoSizeMode.None
        SELF:labelControlVoyages:Location := System.Drawing.Point{10, 5}
        SELF:labelControlVoyages:Name := "labelControlVoyages"
        SELF:labelControlVoyages:Size := System.Drawing.Size{762, 17}
        SELF:labelControlVoyages:TabIndex := 22
        SELF:labelControlVoyages:Text := "Voyages"
        // 
        // labelControlRouting
        // 
        SELF:labelControlRouting:Appearance:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
        SELF:labelControlRouting:AutoSizeMode := DevExpress.XtraEditors.LabelAutoSizeMode.None
        SELF:labelControlRouting:Location := System.Drawing.Point{10, 371}
        SELF:labelControlRouting:Name := "labelControlRouting"
        SELF:labelControlRouting:Size := System.Drawing.Size{762, 17}
        SELF:labelControlRouting:TabIndex := 24
        SELF:labelControlRouting:Text := "Voyage Routings"
        // 
        // LBCRouting
        // 
        SELF:LBCRouting:HorizontalScrollbar := TRUE
        SELF:LBCRouting:Location := System.Drawing.Point{10, 391}
        SELF:LBCRouting:Name := "LBCRouting"
        SELF:LBCRouting:Size := System.Drawing.Size{762, 128}
        SELF:LBCRouting:TabIndex := 23
        // 
        // ButtonOK
        // 
        SELF:ButtonOK:DialogResult := System.Windows.Forms.DialogResult.OK
        SELF:ButtonOK:Location := System.Drawing.Point{270, 529}
        SELF:ButtonOK:Name := "ButtonOK"
        SELF:ButtonOK:Size := System.Drawing.Size{75, 23}
        SELF:ButtonOK:TabIndex := 25
        SELF:ButtonOK:Text := "OK"
        //SELF:ButtonOK:Click += System.EventHandler{ SELF, @ButtonOK_Click() }
        // 
        // ButtonCancel
        // 
        SELF:ButtonCancel:DialogResult := System.Windows.Forms.DialogResult.Cancel
        SELF:ButtonCancel:Location := System.Drawing.Point{450, 529}
        SELF:ButtonCancel:Name := "ButtonCancel"
        SELF:ButtonCancel:Size := System.Drawing.Size{75, 23}
        SELF:ButtonCancel:TabIndex := 26
        SELF:ButtonCancel:Text := "Cancel"
        // 
        // SelectVoyageForm
        // 
        SELF:AcceptButton := SELF:ButtonOK
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:CancelButton := SELF:ButtonCancel
        SELF:ClientSize := System.Drawing.Size{784, 562}
        SELF:Controls:Add(SELF:ButtonCancel)
        SELF:Controls:Add(SELF:ButtonOK)
        SELF:Controls:Add(SELF:labelControlRouting)
        SELF:Controls:Add(SELF:LBCRouting)
        SELF:Controls:Add(SELF:labelControlVoyages)
        SELF:Controls:Add(SELF:LBCVoyages)
        SELF:MaximizeBox := FALSE
        SELF:MinimizeBox := FALSE
        SELF:Name := "SelectVoyageForm"
        SELF:StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen
        SELF:Text := "Select Voyage Form"
        SELF:Load += System.EventHandler{ SELF, @SelectVoyageForm_Load() }
        ((System.ComponentModel.ISupportInitialize)(SELF:LBCVoyages)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:LBCRouting)):EndInit()
        SELF:ResumeLayout(FALSE)
    PRIVATE METHOD SelectVoyageForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		self:SelectVoyageForm_OnLoad()
        RETURN

    PRIVATE METHOD LBCVoyages_SelectedIndexChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:Fill_LBCRoutings()
        RETURN


END CLASS
