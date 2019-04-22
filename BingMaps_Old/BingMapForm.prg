PARTIAL CLASS BingMapForm INHERIT WpfMapUserControl.MapForm
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
        // BingMapForm
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{700, 500}
        SELF:Name := "BingMapForm"
        SELF:Text := "Map Form"
        SELF:WindowState := System.Windows.Forms.FormWindowState.Maximized
        SELF:Load += System.EventHandler{ SELF, @BingMapForm_Load() }
        SELF:Shown += System.EventHandler{ SELF, @BingMapForm_Shown() }
        SELF:FormClosing += System.Windows.Forms.FormClosingEventHandler{ SELF, @BingMapForm_FormClosing() }
        SELF:ResumeLayout(FALSE)

    PRIVATE METHOD BingMapForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:BingMapForm_OnLoad()
        RETURN

    PRIVATE METHOD BingMapForm_Shown( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:BingMapForm_OnShown()
        RETURN

    PRIVATE METHOD BingMapForm_FormClosing( sender AS System.Object, e AS System.Windows.Forms.FormClosingEventArgs ) AS System.Void
		SELF:BingMapForm_OnFormClosing()
        RETURN

END CLASS
