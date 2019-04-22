CLASS SelectDatesSimpleForm INHERIT DevExpress.XtraEditors.XtraForm
    PRIVATE ButtonCancel AS DevExpress.XtraEditors.SimpleButton
    PRIVATE ButtonOK AS DevExpress.XtraEditors.SimpleButton
    EXPORT DateTo AS DevExpress.XtraEditors.DateEdit
    EXPORT DateFrom AS DevExpress.XtraEditors.DateEdit
    PRIVATE label2 AS System.Windows.Forms.Label
    PRIVATE label1 AS System.Windows.Forms.Label
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
        SELF:ButtonCancel := DevExpress.XtraEditors.SimpleButton{}
        SELF:ButtonOK := DevExpress.XtraEditors.SimpleButton{}
        SELF:DateTo := DevExpress.XtraEditors.DateEdit{}
        SELF:DateFrom := DevExpress.XtraEditors.DateEdit{}
        SELF:label2 := System.Windows.Forms.Label{}
        SELF:label1 := System.Windows.Forms.Label{}
        ((System.ComponentModel.ISupportInitialize)(SELF:DateTo:Properties:VistaTimeProperties)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:DateTo:Properties)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:DateFrom:Properties:VistaTimeProperties)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:DateFrom:Properties)):BeginInit()
        SELF:SuspendLayout()
        // 
        // ButtonCancel
        // 
        SELF:ButtonCancel:DialogResult := System.Windows.Forms.DialogResult.Cancel
        SELF:ButtonCancel:Location := System.Drawing.Point{124, 73}
        SELF:ButtonCancel:Name := "ButtonCancel"
        SELF:ButtonCancel:Size := System.Drawing.Size{60, 23}
        SELF:ButtonCancel:TabIndex := 29
        SELF:ButtonCancel:Text := "Cancel"
        // 
        // ButtonOK
        // 
        SELF:ButtonOK:Location := System.Drawing.Point{12, 73}
        SELF:ButtonOK:Name := "ButtonOK"
        SELF:ButtonOK:Size := System.Drawing.Size{60, 23}
        SELF:ButtonOK:TabIndex := 28
        SELF:ButtonOK:Text := "OK"
        SELF:ButtonOK:Click += System.EventHandler{ SELF, @ButtonOK_Click() }
        // 
        // DateTo
        // 
        SELF:DateTo:EditValue := NULL
        SELF:DateTo:Location := System.Drawing.Point{69, 35}
        SELF:DateTo:Name := "DateTo"
        SELF:DateTo:Properties:AllowNullInput := DevExpress.Utils.DefaultBoolean.False
        SELF:DateTo:Properties:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{DevExpress.XtraEditors.Controls.ButtonPredefines.Combo} })
        SELF:DateTo:Properties:DisplayFormat:FormatString := "dd/MM/yy  HH:mm:ss"
        SELF:DateTo:Properties:DisplayFormat:FormatType := DevExpress.Utils.FormatType.DateTime
        SELF:DateTo:Properties:EditFormat:FormatString := "dd/MM/yy  HH:mm:ss"
        SELF:DateTo:Properties:EditFormat:FormatType := DevExpress.Utils.FormatType.DateTime
        SELF:DateTo:Properties:Mask:EditMask := "dd/MM/yy  HH:mm:ss"
        SELF:DateTo:Properties:Mask:MaskType := DevExpress.XtraEditors.Mask.MaskType.DateTimeAdvancingCaret
        SELF:DateTo:Properties:ShowWeekNumbers := TRUE
        SELF:DateTo:Properties:VistaTimeProperties:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{} })
        SELF:DateTo:Size := System.Drawing.Size{115, 20}
        SELF:DateTo:TabIndex := 27
        // 
        // DateFrom
        // 
        SELF:DateFrom:EditValue := NULL
        SELF:DateFrom:Location := System.Drawing.Point{69, 10}
        SELF:DateFrom:Name := "DateFrom"
        SELF:DateFrom:Properties:AllowNullInput := DevExpress.Utils.DefaultBoolean.False
        SELF:DateFrom:Properties:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{DevExpress.XtraEditors.Controls.ButtonPredefines.Combo} })
        SELF:DateFrom:Properties:DisplayFormat:FormatString := "dd/MM/yy  HH:mm:ss"
        SELF:DateFrom:Properties:DisplayFormat:FormatType := DevExpress.Utils.FormatType.DateTime
        SELF:DateFrom:Properties:EditFormat:FormatString := "dd/MM/yy  HH:mm:ss"
        SELF:DateFrom:Properties:EditFormat:FormatType := DevExpress.Utils.FormatType.DateTime
        SELF:DateFrom:Properties:Mask:EditMask := "dd/MM/yy  HH:mm:ss"
        SELF:DateFrom:Properties:Mask:MaskType := DevExpress.XtraEditors.Mask.MaskType.DateTimeAdvancingCaret
        SELF:DateFrom:Properties:ShowWeekNumbers := TRUE
        SELF:DateFrom:Properties:VistaTimeProperties:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{} })
        SELF:DateFrom:Size := System.Drawing.Size{115, 20}
        SELF:DateFrom:TabIndex := 26
        // 
        // label2
        // 
        SELF:label2:AutoSize := TRUE
        SELF:label2:Location := System.Drawing.Point{9, 38}
        SELF:label2:Name := "label2"
        SELF:label2:Size := System.Drawing.Size{62, 13}
        SELF:label2:TabIndex := 25
        SELF:label2:Text := "Up to date:"
        // 
        // label1
        // 
        SELF:label1:AutoSize := TRUE
        SELF:label1:Location := System.Drawing.Point{9, 13}
        SELF:label1:Name := "label1"
        SELF:label1:Size := System.Drawing.Size{60, 13}
        SELF:label1:TabIndex := 24
        SELF:label1:Text := "From date:"
        // 
        // SelectDatesSimpleForm
        // 
        SELF:AcceptButton := SELF:ButtonOK
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:CancelButton := SELF:ButtonCancel
        SELF:ClientSize := System.Drawing.Size{199, 107}
        SELF:Controls:Add(SELF:ButtonCancel)
        SELF:Controls:Add(SELF:ButtonOK)
        SELF:Controls:Add(SELF:DateTo)
        SELF:Controls:Add(SELF:DateFrom)
        SELF:Controls:Add(SELF:label2)
        SELF:Controls:Add(SELF:label1)
        SELF:MaximizeBox := FALSE
        SELF:MinimizeBox := FALSE
        SELF:Name := "SelectDatesSimpleForm"
        SELF:StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen
        SELF:Text := "Select period"
        ((System.ComponentModel.ISupportInitialize)(SELF:DateTo:Properties:VistaTimeProperties)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:DateTo:Properties)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:DateFrom:Properties:VistaTimeProperties)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:DateFrom:Properties)):EndInit()
        SELF:ResumeLayout(FALSE)
        SELF:PerformLayout()
    PRIVATE METHOD ButtonOK_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		IF SELF:DateFrom:DateTime > SELF:DateTo:DateTime
			wb("Invalid dates")
			SELF:DateTo:Focus()
			RETURN
		ENDIF
		SELF:DialogResult := System.Windows.Forms.DialogResult.OK
        RETURN

END CLASS
