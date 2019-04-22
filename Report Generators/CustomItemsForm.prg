PARTIAL CLASS CustomItemsForm INHERIT DevExpress.XtraEditors.XtraForm
    PRIVATE GridItems AS DevExpress.XtraGrid.GridControl
    PRIVATE GridViewItems AS DevExpress.XtraGrid.Views.Grid.GridView
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
        SELF:GridItems := DevExpress.XtraGrid.GridControl{}
        SELF:GridViewItems := DevExpress.XtraGrid.Views.Grid.GridView{}
        ((System.ComponentModel.ISupportInitialize)(SELF:GridItems)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:GridViewItems)):BeginInit()
        SELF:SuspendLayout()
        // 
        // GridItems
        // 
        SELF:GridItems:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:GridItems:Location := System.Drawing.Point{0, 0}
        SELF:GridItems:LookAndFeel:SkinName := "The Asphalt World"
        SELF:GridItems:MainView := SELF:GridViewItems
        SELF:GridItems:Name := "GridItems"
        SELF:GridItems:Size := System.Drawing.Size{784, 562}
        SELF:GridItems:TabIndex := 15
        SELF:GridItems:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:GridViewItems })
        // 
        // GridViewItems
        // 
        SELF:GridViewItems:GridControl := SELF:GridItems
        SELF:GridViewItems:Name := "GridViewItems"
        SELF:GridViewItems:OptionsBehavior:AllowIncrementalSearch := TRUE
        SELF:GridViewItems:OptionsBehavior:AutoPopulateColumns := FALSE
        SELF:GridViewItems:OptionsSelection:EnableAppearanceFocusedCell := FALSE
        SELF:GridViewItems:OptionsView:ColumnAutoWidth := FALSE
        // 
        // CustomItemsForm
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{784, 562}
        SELF:Controls:Add(SELF:GridItems)
        SELF:MaximizeBox := FALSE
        SELF:MinimizeBox := FALSE
        SELF:Name := "CustomItemsForm"
        SELF:Text := "Custom Items Form"
        SELF:FormClosing += System.Windows.Forms.FormClosingEventHandler{ SELF, @CustomItemsForm_FormClosing() }
        SELF:Load += System.EventHandler{ SELF, @CustomItemsForm_Load() }
        ((System.ComponentModel.ISupportInitialize)(SELF:GridItems)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:GridViewItems)):EndInit()
        SELF:ResumeLayout(FALSE)
    PRIVATE METHOD CustomItemsForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:CustomItemsForm_OnLoad()
        RETURN

    PRIVATE METHOD CustomItemsForm_FormClosing( sender AS System.Object, e AS System.Windows.Forms.FormClosingEventArgs ) AS System.Void
		oSoftway:SaveFormSettings_DevExpress(SELF, NULL, oMainForm:alForms, oMainForm:alData)
        RETURN

END CLASS
