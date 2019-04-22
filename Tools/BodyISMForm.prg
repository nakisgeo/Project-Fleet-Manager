PARTIAL CLASS BodyISMForm INHERIT DevExpress.XtraEditors.XtraForm
    PRIVATE BodyISM AS DevExpress.XtraEditors.MemoEdit
    PRIVATE ButtonSave AS DevExpress.XtraEditors.SimpleButton
    PRIVATE ButtonClose AS DevExpress.XtraEditors.SimpleButton
    PRIVATE ButtonContent AS DevExpress.XtraEditors.SimpleButton
    PRIVATE panelControl1 AS DevExpress.XtraEditors.PanelControl
    PRIVATE ButtonShowNames AS DevExpress.XtraEditors.SimpleButton
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
        SELF:BodyISM := DevExpress.XtraEditors.MemoEdit{}
        SELF:ButtonSave := DevExpress.XtraEditors.SimpleButton{}
        SELF:ButtonClose := DevExpress.XtraEditors.SimpleButton{}
        SELF:ButtonContent := DevExpress.XtraEditors.SimpleButton{}
        SELF:panelControl1 := DevExpress.XtraEditors.PanelControl{}
        SELF:ButtonShowNames := DevExpress.XtraEditors.SimpleButton{}
        ((System.ComponentModel.ISupportInitialize)(SELF:BodyISM:Properties)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:panelControl1)):BeginInit()
        SELF:panelControl1:SuspendLayout()
        SELF:SuspendLayout()
        // 
        // BodyISM
        // 
        SELF:BodyISM:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:BodyISM:Location := System.Drawing.Point{0, 0}
        SELF:BodyISM:Name := "BodyISM"
        SELF:BodyISM:Properties:AcceptsTab := TRUE
        SELF:BodyISM:Properties:Appearance:Font := System.Drawing.Font{"Lucida Console", ((Single) 8.25)}
        SELF:BodyISM:Properties:Appearance:Options:UseFont := TRUE
        SELF:BodyISM:Properties:ScrollBars := System.Windows.Forms.ScrollBars.Both
        SELF:BodyISM:Properties:WordWrap := FALSE
        SELF:BodyISM:Size := System.Drawing.Size{493, 562}
        SELF:BodyISM:TabIndex := 26
        // 
        // ButtonSave
        // 
        SELF:ButtonSave:Appearance:Options:UseTextOptions := TRUE
        SELF:ButtonSave:Appearance:TextOptions:WordWrap := DevExpress.Utils.WordWrap.Wrap
        SELF:ButtonSave:Location := System.Drawing.Point{11, 165}
        SELF:ButtonSave:Name := "ButtonSave"
        SELF:ButtonSave:Size := System.Drawing.Size{70, 35}
        SELF:ButtonSave:TabIndex := 27
        SELF:ButtonSave:Text := "Save"
        SELF:ButtonSave:ToolTip := "Export Reports, Categories and Report Items"
        SELF:ButtonSave:Click += System.EventHandler{ SELF, @ButtonSave_Click() }
        // 
        // ButtonClose
        // 
        SELF:ButtonClose:Appearance:Options:UseTextOptions := TRUE
        SELF:ButtonClose:Appearance:TextOptions:WordWrap := DevExpress.Utils.WordWrap.Wrap
        SELF:ButtonClose:Location := System.Drawing.Point{11, 376}
        SELF:ButtonClose:Name := "ButtonClose"
        SELF:ButtonClose:Size := System.Drawing.Size{70, 35}
        SELF:ButtonClose:TabIndex := 29
        SELF:ButtonClose:Text := "Close"
        SELF:ButtonClose:ToolTip := "Export Reports, Categories and Report Items"
        SELF:ButtonClose:Click += System.EventHandler{ SELF, @ButtonClose_Click() }
        // 
        // ButtonContent
        // 
        SELF:ButtonContent:Appearance:Options:UseTextOptions := TRUE
        SELF:ButtonContent:Appearance:TextOptions:WordWrap := DevExpress.Utils.WordWrap.Wrap
        SELF:ButtonContent:Location := System.Drawing.Point{11, 247}
        SELF:ButtonContent:Name := "ButtonContent"
        SELF:ButtonContent:Size := System.Drawing.Size{70, 35}
        SELF:ButtonContent:TabIndex := 28
        SELF:ButtonContent:Text := "Check content"
        SELF:ButtonContent:ToolTip := "Export Reports, Categories and Report Items"
        SELF:ButtonContent:Click += System.EventHandler{ SELF, @ButtonCheck_Click() }
        // 
        // panelControl1
        // 
        SELF:panelControl1:Controls:Add(SELF:ButtonShowNames)
        SELF:panelControl1:Controls:Add(SELF:ButtonSave)
        SELF:panelControl1:Controls:Add(SELF:ButtonContent)
        SELF:panelControl1:Controls:Add(SELF:ButtonClose)
        SELF:panelControl1:Dock := System.Windows.Forms.DockStyle.Right
        SELF:panelControl1:Location := System.Drawing.Point{493, 0}
        SELF:panelControl1:Name := "panelControl1"
        SELF:panelControl1:Size := System.Drawing.Size{91, 562}
        SELF:panelControl1:TabIndex := 30
        // 
        // ButtonShowNames
        // 
        SELF:ButtonShowNames:Appearance:Options:UseTextOptions := TRUE
        SELF:ButtonShowNames:Appearance:TextOptions:WordWrap := DevExpress.Utils.WordWrap.Wrap
        SELF:ButtonShowNames:Location := System.Drawing.Point{11, 311}
        SELF:ButtonShowNames:Name := "ButtonShowNames"
        SELF:ButtonShowNames:Size := System.Drawing.Size{70, 35}
        SELF:ButtonShowNames:TabIndex := 30
        SELF:ButtonShowNames:Tag := "0"
        SELF:ButtonShowNames:Text := e"Show \r\nNames"
        SELF:ButtonShowNames:ToolTip := "Export Reports, Categories and Report Items"
        SELF:ButtonShowNames:Click += System.EventHandler{ SELF, @ButtonShowNames_Click() }
        // 
        // BodyISMForm
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{584, 562}
        SELF:Controls:Add(SELF:BodyISM)
        SELF:Controls:Add(SELF:panelControl1)
        SELF:Name := "BodyISMForm"
        SELF:Text := "eMail body text to receive from the Vessel"
        SELF:FormClosing += System.Windows.Forms.FormClosingEventHandler{ SELF, @BodyISMForm_FormClosing() }
        SELF:Load += System.EventHandler{ SELF, @BodyISMForm_Load() }
        SELF:Shown += System.EventHandler{ SELF, @BodyISMForm_Shown() }
        ((System.ComponentModel.ISupportInitialize)(SELF:BodyISM:Properties)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:panelControl1)):EndInit()
        SELF:panelControl1:ResumeLayout(FALSE)
        SELF:ResumeLayout(FALSE)
    PRIVATE METHOD BodyISMForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:BodyISMForm_OnLoad()
        RETURN

    PRIVATE METHOD BodyISMForm_Shown( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:BodyISMForm_OnShown()
        RETURN

    PRIVATE METHOD BodyISMForm_FormClosing( sender AS System.Object, e AS System.Windows.Forms.FormClosingEventArgs ) AS System.Void
		oSoftway:SaveFormSettings_DevExpress(SELF, NULL, oMainForm:alForms, oMainForm:alData)
        RETURN

    PRIVATE METHOD ButtonSave_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:Save()
    RETURN

    PRIVATE METHOD ButtonCheck_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:CheckContent()
    RETURN

    PRIVATE METHOD ButtonClose_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:Close()
    RETURN

    PRIVATE METHOD ButtonShowNames_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:ButtonShowNamesClick()
    RETURN

END CLASS
