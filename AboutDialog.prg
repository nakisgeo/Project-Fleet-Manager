CLASS AboutDialog INHERIT System.Windows.Forms.Form
    PRIVATE aboutText AS System.Windows.Forms.Label
    EXPORT LicenseTxt AS System.Windows.Forms.TextBox
    PRIVATE label1 AS System.Windows.Forms.Label
    PRIVATE linkLabel AS System.Windows.Forms.LinkLabel
    PRIVATE ButtonOK AS System.Windows.Forms.Button
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
        SELF:aboutText := System.Windows.Forms.Label{}
        SELF:LicenseTxt := System.Windows.Forms.TextBox{}
        SELF:label1 := System.Windows.Forms.Label{}
        SELF:linkLabel := System.Windows.Forms.LinkLabel{}
        SELF:ButtonOK := System.Windows.Forms.Button{}
        SELF:SuspendLayout()
        // 
        // aboutText
        // 
        SELF:aboutText:Location := System.Drawing.Point{3, 15}
        SELF:aboutText:Name := "aboutText"
        SELF:aboutText:Size := System.Drawing.Size{264, 13}
        SELF:aboutText:TabIndex := 3
        SELF:aboutText:Text := "FleetManager V.1.2.0.02"
        SELF:aboutText:TextAlign := System.Drawing.ContentAlignment.MiddleCenter
        // 
        // LicenseTxt
        // 
        SELF:LicenseTxt:Location := System.Drawing.Point{12, 40}
        SELF:LicenseTxt:Multiline := TRUE
        SELF:LicenseTxt:Name := "LicenseTxt"
        SELF:LicenseTxt:ReadOnly := TRUE
        SELF:LicenseTxt:Size := System.Drawing.Size{246, 35}
        SELF:LicenseTxt:TabIndex := 7
        SELF:LicenseTxt:TabStop := FALSE
        SELF:LicenseTxt:TextAlign := System.Windows.Forms.HorizontalAlignment.Center
        // 
        // label1
        // 
        SELF:label1:AutoSize := TRUE
        SELF:label1:Location := System.Drawing.Point{57, 88}
        SELF:label1:Name := "label1"
        SELF:label1:Size := System.Drawing.Size{149, 13}
        SELF:label1:TabIndex := 8
        SELF:label1:Text := "Copyright © 2017 Softway Ltd"
        // 
        // linkLabel
        // 
        SELF:linkLabel:AutoSize := TRUE
        SELF:linkLabel:Location := System.Drawing.Point{57, 110}
        SELF:linkLabel:Name := "linkLabel"
        SELF:linkLabel:Size := System.Drawing.Size{147, 13}
        SELF:linkLabel:TabIndex := 9
        SELF:linkLabel:TabStop := TRUE
        SELF:linkLabel:Text := "Visit the SOFTWAY Web Site"
        SELF:linkLabel:TextAlign := System.Drawing.ContentAlignment.MiddleCenter
        SELF:linkLabel:LinkClicked += System.Windows.Forms.LinkLabelLinkClickedEventHandler{ SELF, @linkLabel_LinkClicked() }
        // 
        // ButtonOK
        // 
        SELF:ButtonOK:DialogResult := System.Windows.Forms.DialogResult.Cancel
        SELF:ButtonOK:Location := System.Drawing.Point{96, 145}
        SELF:ButtonOK:Name := "ButtonOK"
        SELF:ButtonOK:Size := System.Drawing.Size{75, 25}
        SELF:ButtonOK:TabIndex := 10
        SELF:ButtonOK:Text := "OK"
        SELF:ButtonOK:UseVisualStyleBackColor := TRUE
        SELF:ButtonOK:Click += System.EventHandler{ SELF, @ButtonOK_Click() }
        // 
        // AboutDialog
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:CancelButton := SELF:ButtonOK
        SELF:ClientSize := System.Drawing.Size{270, 184}
        SELF:Controls:Add(SELF:ButtonOK)
        SELF:Controls:Add(SELF:linkLabel)
        SELF:Controls:Add(SELF:label1)
        SELF:Controls:Add(SELF:LicenseTxt)
        SELF:Controls:Add(SELF:aboutText)
        SELF:FormBorderStyle := System.Windows.Forms.FormBorderStyle.FixedDialog
        SELF:MaximizeBox := FALSE
        SELF:MinimizeBox := FALSE
        SELF:Name := "AboutDialog"
        SELF:ShowIcon := FALSE
        SELF:ShowInTaskbar := FALSE
        SELF:SizeGripStyle := System.Windows.Forms.SizeGripStyle.Hide
        SELF:StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen
        SELF:Text := "Program information"
        SELF:Load += System.EventHandler{ SELF, @AboutDialog_Load() }
        SELF:ResumeLayout(FALSE)
        SELF:PerformLayout()
    PRIVATE METHOD linkLabel_LinkClicked( sender AS System.Object, e AS System.Windows.Forms.LinkLabelLinkClickedEventArgs ) AS System.Void
        System.Diagnostics.Process.Start( "http://www.softway.gr" )
        RETURN

    PRIVATE METHOD AboutDialog_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
      SELF:aboutText:Text := "FleetManager V."+cProgramVersion
        RETURN

    PRIVATE METHOD ButtonOK_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		Self:Close()
        RETURN

END CLASS
