PARTIAL CLASS BingMapUserControl INHERIT WpfMapUserControl.MapFormUserControl
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
        SELF:SuspendLayout()
        // 
        // BingMapUserControl
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:Name := "BingMapUserControl"
        SELF:Size := System.Drawing.Size{624, 508}
        SELF:Load += System.EventHandler{ SELF, @BingMapUserControl_Load() }
        //SELF:Shown += System.EventHandler{ SELF, @BingMapUserControl_Shown() }
        //SELF:FormClosing += System.Windows.Forms.FormClosingEventHandler{ SELF, @BingMapUserControl_FormClosing() }
        SELF:ResumeLayout(FALSE)

    PRIVATE METHOD BingMapUserControl_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:BingMapUserControl_OnLoad()
        RETURN

  //  PRIVATE METHOD BingMapUserControl_Shown( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		//SELF:BingMapUserControl_OnShown()
  //      RETURN

    //PRIVATE METHOD BingMapUserControl_FormClosing( sender AS System.Object, e AS System.Windows.Forms.FormClosingEventArgs ) AS System.Void
		//SELF:BingMapUserControl_OnFormClosing()
        //RETURN
END CLASS
