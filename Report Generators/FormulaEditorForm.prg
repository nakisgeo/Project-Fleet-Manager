CLASS FormulaEditorForm INHERIT DevExpress.XtraEditors.XtraForm
    PRIVATE filterEditorControl1 AS DevExpress.XtraFilterEditor.FilterEditorControl
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
        SELF:filterEditorControl1 := DevExpress.XtraFilterEditor.FilterEditorControl{}
        SELF:SuspendLayout()
        // 
        // filterEditorControl1
        // 
        SELF:filterEditorControl1:AppearanceEmptyValueColor := System.Drawing.Color.Empty
        SELF:filterEditorControl1:AppearanceFieldNameColor := System.Drawing.Color.Empty
        SELF:filterEditorControl1:AppearanceGroupOperatorColor := System.Drawing.Color.Empty
        SELF:filterEditorControl1:AppearanceOperatorColor := System.Drawing.Color.Empty
        SELF:filterEditorControl1:AppearanceValueColor := System.Drawing.Color.Empty
        SELF:filterEditorControl1:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:filterEditorControl1:Location := System.Drawing.Point{0, 0}
        SELF:filterEditorControl1:Name := "filterEditorControl1"
        SELF:filterEditorControl1:Size := System.Drawing.Size{463, 398}
        SELF:filterEditorControl1:TabIndex := 17
        SELF:filterEditorControl1:Text := "filterEditorControl1"
        // 
        // FormulaEditorForm
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{463, 398}
        SELF:Controls:Add(SELF:filterEditorControl1)
        SELF:Name := "FormulaEditorForm"
        SELF:Text := "FormulaEditorForm"
        SELF:ResumeLayout(FALSE)

END CLASS
