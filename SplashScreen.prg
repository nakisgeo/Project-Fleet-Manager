PARTIAL CLASS SplashScreen INHERIT System.Windows.Forms.Form
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
        LOCAL resources := System.ComponentModel.ComponentResourceManager{typeof(SplashScreen)} AS System.ComponentModel.ComponentResourceManager
        SELF:label1 := System.Windows.Forms.Label{}
        SELF:SuspendLayout()
        // 
        // label1
        // 
        SELF:label1:AutoSize := TRUE
        SELF:label1:BackColor := System.Drawing.Color.White
        SELF:label1:Location := System.Drawing.Point{144, 270}
        SELF:label1:Name := "label1"
        SELF:label1:Size := System.Drawing.Size{187, 13}
        SELF:label1:TabIndex := 1
        SELF:label1:Text := "Loading Fleet Manager - please wait..."
        // 
        // SplashScreen
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:BackgroundImage := ((System.Drawing.Image)(resources:GetObject("$this.BackgroundImage")))
        SELF:BackgroundImageLayout := System.Windows.Forms.ImageLayout.Stretch
        SELF:ClientSize := System.Drawing.Size{468, 302}
        SELF:Controls:Add(SELF:label1)
        SELF:Cursor := System.Windows.Forms.Cursors.AppStarting
        SELF:FormBorderStyle := System.Windows.Forms.FormBorderStyle.None
        SELF:Name := "SplashScreen"
        SELF:StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen
        SELF:Text := "SplashScreen"
        SELF:ResumeLayout(FALSE)
        SELF:PerformLayout()

END CLASS
