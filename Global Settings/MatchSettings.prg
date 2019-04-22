PARTIAL CLASS MatchSettings INHERIT System.Windows.Forms.Form
    PRIVATE splitContainerControl1 AS DevExpress.XtraEditors.SplitContainerControl
    EXPORT LBCUsers AS DevExpress.XtraEditors.ListBoxControl
    PRIVATE panelControl1 AS DevExpress.XtraEditors.PanelControl
    PRIVATE panel1 AS System.Windows.Forms.Panel
    PRIVATE userLabel AS System.Windows.Forms.Label
    PRIVATE label7 AS System.Windows.Forms.Label
    PRIVATE label8 AS System.Windows.Forms.Label
    PRIVATE label5 AS System.Windows.Forms.Label
    PRIVATE label6 AS System.Windows.Forms.Label
    PRIVATE label4 AS System.Windows.Forms.Label
    PRIVATE label3 AS System.Windows.Forms.Label
    PRIVATE label2 AS System.Windows.Forms.Label
    PRIVATE label1 AS System.Windows.Forms.Label
    PRIVATE textBox6 AS System.Windows.Forms.TextBox
    PRIVATE textBox4 AS System.Windows.Forms.TextBox
    PRIVATE textBox2 AS System.Windows.Forms.TextBox
    EXPORT tbArRepUID AS System.Windows.Forms.TextBox
    EXPORT tbDepNextPortUID AS System.Windows.Forms.TextBox
    EXPORT tbDepRepUID AS System.Windows.Forms.TextBox
    PRIVATE button2 AS System.Windows.Forms.Button
    PRIVATE button1 AS System.Windows.Forms.Button
    PRIVATE label12 AS System.Windows.Forms.Label
    PRIVATE label13 AS System.Windows.Forms.Label
    PRIVATE label14 AS System.Windows.Forms.Label
    PRIVATE label9 AS System.Windows.Forms.Label
    PRIVATE label10 AS System.Windows.Forms.Label
    PRIVATE label11 AS System.Windows.Forms.Label
    EXPORT tbArMGOUID AS System.Windows.Forms.TextBox
    PRIVATE tbArLFOUID AS System.Windows.Forms.TextBox
    EXPORT tbArHFOUID AS System.Windows.Forms.TextBox
    EXPORT tbDepMGOUID AS System.Windows.Forms.TextBox
    PRIVATE tbDepLFOUID AS System.Windows.Forms.TextBox
    EXPORT tbDepHFOUID AS System.Windows.Forms.TextBox
    PRIVATE label15 AS System.Windows.Forms.Label
    PRIVATE label16 AS System.Windows.Forms.Label
    EXPORT tbDeparturePortUID AS System.Windows.Forms.TextBox
    PRIVATE tbArrivalPortUID AS System.Windows.Forms.TextBox
    PRIVATE tabControl1 AS System.Windows.Forms.TabControl
    PRIVATE tabPage1 AS System.Windows.Forms.TabPage
    PRIVATE tabPage2 AS System.Windows.Forms.TabPage
    EXPORT label21 AS System.Windows.Forms.Label
    EXPORT label17 AS System.Windows.Forms.Label
    PRIVATE txtPass AS System.Windows.Forms.TextBox
    EXPORT label18 AS System.Windows.Forms.Label
    PRIVATE txtUser AS System.Windows.Forms.TextBox
    EXPORT label19 AS System.Windows.Forms.Label
    PRIVATE txtPort AS System.Windows.Forms.TextBox
    EXPORT label20 AS System.Windows.Forms.Label
    PRIVATE bttnTestSMTP AS System.Windows.Forms.Button
    PRIVATE checkBoxSMTPSecure AS System.Windows.Forms.CheckBox
    PRIVATE buttonSaveSMTPSettings AS System.Windows.Forms.Button
    PRIVATE txtSMTPServer AS System.Windows.Forms.TextBox
    EXPORT label22 AS System.Windows.Forms.Label
    PRIVATE txtSender AS System.Windows.Forms.TextBox
    PRIVATE label23 AS System.Windows.Forms.Label
    PRIVATE label24 AS System.Windows.Forms.Label
    PRIVATE label25 AS System.Windows.Forms.Label
    EXPORT tbBunkeredMDO AS System.Windows.Forms.TextBox
    PRIVATE tbBunkeredLFO AS System.Windows.Forms.TextBox
    EXPORT tbBunkeredHFO AS System.Windows.Forms.TextBox
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
        SELF:splitContainerControl1 := DevExpress.XtraEditors.SplitContainerControl{}
        SELF:LBCUsers := DevExpress.XtraEditors.ListBoxControl{}
        SELF:panelControl1 := DevExpress.XtraEditors.PanelControl{}
        SELF:panel1 := System.Windows.Forms.Panel{}
        SELF:label23 := System.Windows.Forms.Label{}
        SELF:label24 := System.Windows.Forms.Label{}
        SELF:label25 := System.Windows.Forms.Label{}
        SELF:tbBunkeredMDO := System.Windows.Forms.TextBox{}
        SELF:tbBunkeredLFO := System.Windows.Forms.TextBox{}
        SELF:tbBunkeredHFO := System.Windows.Forms.TextBox{}
        SELF:label16 := System.Windows.Forms.Label{}
        SELF:tbDeparturePortUID := System.Windows.Forms.TextBox{}
        SELF:label15 := System.Windows.Forms.Label{}
        SELF:tbArrivalPortUID := System.Windows.Forms.TextBox{}
        SELF:label12 := System.Windows.Forms.Label{}
        SELF:label13 := System.Windows.Forms.Label{}
        SELF:label14 := System.Windows.Forms.Label{}
        SELF:tbDepMGOUID := System.Windows.Forms.TextBox{}
        SELF:tbDepLFOUID := System.Windows.Forms.TextBox{}
        SELF:tbDepHFOUID := System.Windows.Forms.TextBox{}
        SELF:label9 := System.Windows.Forms.Label{}
        SELF:label10 := System.Windows.Forms.Label{}
        SELF:label11 := System.Windows.Forms.Label{}
        SELF:tbArMGOUID := System.Windows.Forms.TextBox{}
        SELF:tbArLFOUID := System.Windows.Forms.TextBox{}
        SELF:tbArHFOUID := System.Windows.Forms.TextBox{}
        SELF:button2 := System.Windows.Forms.Button{}
        SELF:button1 := System.Windows.Forms.Button{}
        SELF:label7 := System.Windows.Forms.Label{}
        SELF:label8 := System.Windows.Forms.Label{}
        SELF:label5 := System.Windows.Forms.Label{}
        SELF:label6 := System.Windows.Forms.Label{}
        SELF:label4 := System.Windows.Forms.Label{}
        SELF:label3 := System.Windows.Forms.Label{}
        SELF:label2 := System.Windows.Forms.Label{}
        SELF:label1 := System.Windows.Forms.Label{}
        SELF:textBox6 := System.Windows.Forms.TextBox{}
        SELF:tbDepNextPortUID := System.Windows.Forms.TextBox{}
        SELF:textBox4 := System.Windows.Forms.TextBox{}
        SELF:tbDepRepUID := System.Windows.Forms.TextBox{}
        SELF:textBox2 := System.Windows.Forms.TextBox{}
        SELF:tbArRepUID := System.Windows.Forms.TextBox{}
        SELF:userLabel := System.Windows.Forms.Label{}
        SELF:tabControl1 := System.Windows.Forms.TabControl{}
        SELF:tabPage1 := System.Windows.Forms.TabPage{}
        SELF:label22 := System.Windows.Forms.Label{}
        SELF:txtSender := System.Windows.Forms.TextBox{}
        SELF:buttonSaveSMTPSettings := System.Windows.Forms.Button{}
        SELF:checkBoxSMTPSecure := System.Windows.Forms.CheckBox{}
        SELF:bttnTestSMTP := System.Windows.Forms.Button{}
        SELF:label21 := System.Windows.Forms.Label{}
        SELF:label17 := System.Windows.Forms.Label{}
        SELF:txtPass := System.Windows.Forms.TextBox{}
        SELF:label18 := System.Windows.Forms.Label{}
        SELF:txtUser := System.Windows.Forms.TextBox{}
        SELF:label19 := System.Windows.Forms.Label{}
        SELF:txtPort := System.Windows.Forms.TextBox{}
        SELF:label20 := System.Windows.Forms.Label{}
        SELF:txtSMTPServer := System.Windows.Forms.TextBox{}
        SELF:tabPage2 := System.Windows.Forms.TabPage{}
        ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl1)):BeginInit()
        SELF:splitContainerControl1:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:LBCUsers)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:panelControl1)):BeginInit()
        SELF:panelControl1:SuspendLayout()
        SELF:panel1:SuspendLayout()
        SELF:tabControl1:SuspendLayout()
        SELF:tabPage1:SuspendLayout()
        SELF:tabPage2:SuspendLayout()
        SELF:SuspendLayout()
        // 
        // splitContainerControl1
        // 
        SELF:splitContainerControl1:BorderStyle := DevExpress.XtraEditors.Controls.BorderStyles.Simple
        SELF:splitContainerControl1:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:splitContainerControl1:Location := System.Drawing.Point{3, 3}
        SELF:splitContainerControl1:Name := "splitContainerControl1"
        SELF:splitContainerControl1:Panel1:Controls:Add(SELF:LBCUsers)
        SELF:splitContainerControl1:Panel1:Text := "Panel1"
        SELF:splitContainerControl1:Panel2:Controls:Add(SELF:panelControl1)
        SELF:splitContainerControl1:Panel2:Text := "Panel2"
        SELF:splitContainerControl1:Size := System.Drawing.Size{874, 539}
        SELF:splitContainerControl1:SplitterPosition := 188
        SELF:splitContainerControl1:TabIndex := 1
        SELF:splitContainerControl1:Text := "splitContainerControl1"
        // 
        // LBCUsers
        // 
        SELF:LBCUsers:Appearance:Font := System.Drawing.Font{"Lucida Console", ((Single) 8.25)}
        SELF:LBCUsers:Appearance:ForeColor := System.Drawing.Color.Black
        SELF:LBCUsers:Appearance:Options:UseFont := TRUE
        SELF:LBCUsers:Appearance:Options:UseForeColor := TRUE
        SELF:LBCUsers:Cursor := System.Windows.Forms.Cursors.Default
        SELF:LBCUsers:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:LBCUsers:HorizontalScrollbar := TRUE
        SELF:LBCUsers:Location := System.Drawing.Point{0, 0}
        SELF:LBCUsers:Name := "LBCUsers"
        SELF:LBCUsers:Size := System.Drawing.Size{188, 535}
        SELF:LBCUsers:TabIndex := 2
        SELF:LBCUsers:SelectedIndexChanged += System.EventHandler{ SELF, @LBCUsers_SelectedIndexChanged() }
        // 
        // panelControl1
        // 
        SELF:panelControl1:Controls:Add(SELF:panel1)
        SELF:panelControl1:Controls:Add(SELF:userLabel)
        SELF:panelControl1:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:panelControl1:Location := System.Drawing.Point{0, 0}
        SELF:panelControl1:Name := "panelControl1"
        SELF:panelControl1:Size := System.Drawing.Size{677, 535}
        SELF:panelControl1:TabIndex := 0
        // 
        // panel1
        // 
        SELF:panel1:BackColor := System.Drawing.Color.White
        SELF:panel1:BorderStyle := System.Windows.Forms.BorderStyle.Fixed3D
        SELF:panel1:Controls:Add(SELF:label23)
        SELF:panel1:Controls:Add(SELF:label24)
        SELF:panel1:Controls:Add(SELF:label25)
        SELF:panel1:Controls:Add(SELF:tbBunkeredMDO)
        SELF:panel1:Controls:Add(SELF:tbBunkeredLFO)
        SELF:panel1:Controls:Add(SELF:tbBunkeredHFO)
        SELF:panel1:Controls:Add(SELF:label16)
        SELF:panel1:Controls:Add(SELF:tbDeparturePortUID)
        SELF:panel1:Controls:Add(SELF:label15)
        SELF:panel1:Controls:Add(SELF:tbArrivalPortUID)
        SELF:panel1:Controls:Add(SELF:label12)
        SELF:panel1:Controls:Add(SELF:label13)
        SELF:panel1:Controls:Add(SELF:label14)
        SELF:panel1:Controls:Add(SELF:tbDepMGOUID)
        SELF:panel1:Controls:Add(SELF:tbDepLFOUID)
        SELF:panel1:Controls:Add(SELF:tbDepHFOUID)
        SELF:panel1:Controls:Add(SELF:label9)
        SELF:panel1:Controls:Add(SELF:label10)
        SELF:panel1:Controls:Add(SELF:label11)
        SELF:panel1:Controls:Add(SELF:tbArMGOUID)
        SELF:panel1:Controls:Add(SELF:tbArLFOUID)
        SELF:panel1:Controls:Add(SELF:tbArHFOUID)
        SELF:panel1:Controls:Add(SELF:button2)
        SELF:panel1:Controls:Add(SELF:button1)
        SELF:panel1:Controls:Add(SELF:label7)
        SELF:panel1:Controls:Add(SELF:label8)
        SELF:panel1:Controls:Add(SELF:label5)
        SELF:panel1:Controls:Add(SELF:label6)
        SELF:panel1:Controls:Add(SELF:label4)
        SELF:panel1:Controls:Add(SELF:label3)
        SELF:panel1:Controls:Add(SELF:label2)
        SELF:panel1:Controls:Add(SELF:label1)
        SELF:panel1:Controls:Add(SELF:textBox6)
        SELF:panel1:Controls:Add(SELF:tbDepNextPortUID)
        SELF:panel1:Controls:Add(SELF:textBox4)
        SELF:panel1:Controls:Add(SELF:tbDepRepUID)
        SELF:panel1:Controls:Add(SELF:textBox2)
        SELF:panel1:Controls:Add(SELF:tbArRepUID)
        SELF:panel1:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:panel1:Location := System.Drawing.Point{2, 25}
        SELF:panel1:Name := "panel1"
        SELF:panel1:Size := System.Drawing.Size{673, 508}
        SELF:panel1:TabIndex := 3
        // 
        // label23
        // 
        SELF:label23:AutoSize := TRUE
        SELF:label23:Location := System.Drawing.Point{291, 360}
        SELF:label23:Name := "label23"
        SELF:label23:Size := System.Drawing.Size{151, 13}
        SELF:label23:TabIndex := 37
        SELF:label23:Text := "Bunkered MDO/MGO Item UID"
        SELF:label23:TextAlign := System.Drawing.ContentAlignment.MiddleLeft
        // 
        // label24
        // 
        SELF:label24:AutoSize := TRUE
        SELF:label24:Location := System.Drawing.Point{291, 328}
        SELF:label24:Name := "label24"
        SELF:label24:Size := System.Drawing.Size{120, 13}
        SELF:label24:TabIndex := 36
        SELF:label24:Text := "Bunkered LFO Item UID"
        SELF:label24:TextAlign := System.Drawing.ContentAlignment.MiddleLeft
        // 
        // label25
        // 
        SELF:label25:AutoSize := TRUE
        SELF:label25:Location := System.Drawing.Point{291, 293}
        SELF:label25:Name := "label25"
        SELF:label25:Size := System.Drawing.Size{122, 13}
        SELF:label25:TabIndex := 35
        SELF:label25:Text := "Bunkered HFO Item UID"
        SELF:label25:TextAlign := System.Drawing.ContentAlignment.MiddleLeft
        // 
        // tbBunkeredMDO
        // 
        SELF:tbBunkeredMDO:Location := System.Drawing.Point{463, 357}
        SELF:tbBunkeredMDO:Name := "tbBunkeredMDO"
        SELF:tbBunkeredMDO:Size := System.Drawing.Size{100, 21}
        SELF:tbBunkeredMDO:TabIndex := 34
        // 
        // tbBunkeredLFO
        // 
        SELF:tbBunkeredLFO:Location := System.Drawing.Point{463, 325}
        SELF:tbBunkeredLFO:Name := "tbBunkeredLFO"
        SELF:tbBunkeredLFO:Size := System.Drawing.Size{100, 21}
        SELF:tbBunkeredLFO:TabIndex := 33
        // 
        // tbBunkeredHFO
        // 
        SELF:tbBunkeredHFO:Location := System.Drawing.Point{463, 290}
        SELF:tbBunkeredHFO:Name := "tbBunkeredHFO"
        SELF:tbBunkeredHFO:Size := System.Drawing.Size{100, 21}
        SELF:tbBunkeredHFO:TabIndex := 32
        // 
        // label16
        // 
        SELF:label16:AutoSize := TRUE
        SELF:label16:Location := System.Drawing.Point{3, 254}
        SELF:label16:Name := "label16"
        SELF:label16:Size := System.Drawing.Size{94, 13}
        SELF:label16:TabIndex := 31
        SELF:label16:Text := "Port Of Departure"
        SELF:label16:TextAlign := System.Drawing.ContentAlignment.MiddleLeft
        // 
        // tbDeparturePortUID
        // 
        SELF:tbDeparturePortUID:Location := System.Drawing.Point{146, 251}
        SELF:tbDeparturePortUID:Name := "tbDeparturePortUID"
        SELF:tbDeparturePortUID:Size := System.Drawing.Size{100, 21}
        SELF:tbDeparturePortUID:TabIndex := 30
        // 
        // label15
        // 
        SELF:label15:AutoSize := TRUE
        SELF:label15:Location := System.Drawing.Point{3, 116}
        SELF:label15:Name := "label15"
        SELF:label15:Size := System.Drawing.Size{107, 13}
        SELF:label15:TabIndex := 29
        SELF:label15:Text := "Arrival Port Item UID"
        // 
        // tbArrivalPortUID
        // 
        SELF:tbArrivalPortUID:Location := System.Drawing.Point{146, 113}
        SELF:tbArrivalPortUID:Name := "tbArrivalPortUID"
        SELF:tbArrivalPortUID:Size := System.Drawing.Size{100, 21}
        SELF:tbArrivalPortUID:TabIndex := 28
        // 
        // label12
        // 
        SELF:label12:AutoSize := TRUE
        SELF:label12:Location := System.Drawing.Point{291, 254}
        SELF:label12:Name := "label12"
        SELF:label12:Size := System.Drawing.Size{155, 13}
        SELF:label12:TabIndex := 27
        SELF:label12:Text := "Departure MDO/MGO Item UID"
        SELF:label12:TextAlign := System.Drawing.ContentAlignment.MiddleLeft
        // 
        // label13
        // 
        SELF:label13:AutoSize := TRUE
        SELF:label13:Location := System.Drawing.Point{291, 222}
        SELF:label13:Name := "label13"
        SELF:label13:Size := System.Drawing.Size{124, 13}
        SELF:label13:TabIndex := 26
        SELF:label13:Text := "Departure LFO Item UID"
        SELF:label13:TextAlign := System.Drawing.ContentAlignment.MiddleLeft
        // 
        // label14
        // 
        SELF:label14:AutoSize := TRUE
        SELF:label14:Location := System.Drawing.Point{291, 187}
        SELF:label14:Name := "label14"
        SELF:label14:Size := System.Drawing.Size{126, 13}
        SELF:label14:TabIndex := 25
        SELF:label14:Text := "Departure HFO Item UID"
        SELF:label14:TextAlign := System.Drawing.ContentAlignment.MiddleLeft
        // 
        // tbDepMGOUID
        // 
        SELF:tbDepMGOUID:Location := System.Drawing.Point{463, 251}
        SELF:tbDepMGOUID:Name := "tbDepMGOUID"
        SELF:tbDepMGOUID:Size := System.Drawing.Size{100, 21}
        SELF:tbDepMGOUID:TabIndex := 24
        // 
        // tbDepLFOUID
        // 
        SELF:tbDepLFOUID:Location := System.Drawing.Point{463, 219}
        SELF:tbDepLFOUID:Name := "tbDepLFOUID"
        SELF:tbDepLFOUID:Size := System.Drawing.Size{100, 21}
        SELF:tbDepLFOUID:TabIndex := 23
        // 
        // tbDepHFOUID
        // 
        SELF:tbDepHFOUID:Location := System.Drawing.Point{463, 184}
        SELF:tbDepHFOUID:Name := "tbDepHFOUID"
        SELF:tbDepHFOUID:Size := System.Drawing.Size{100, 21}
        SELF:tbDepHFOUID:TabIndex := 22
        // 
        // label9
        // 
        SELF:label9:AutoSize := TRUE
        SELF:label9:Location := System.Drawing.Point{293, 116}
        SELF:label9:Name := "label9"
        SELF:label9:Size := System.Drawing.Size{137, 13}
        SELF:label9:TabIndex := 21
        SELF:label9:Text := "Arrival MDO/MGO Item UID"
        SELF:label9:TextAlign := System.Drawing.ContentAlignment.MiddleLeft
        // 
        // label10
        // 
        SELF:label10:AutoSize := TRUE
        SELF:label10:Location := System.Drawing.Point{293, 84}
        SELF:label10:Name := "label10"
        SELF:label10:Size := System.Drawing.Size{106, 13}
        SELF:label10:TabIndex := 20
        SELF:label10:Text := "Arrival LFO Item UID"
        SELF:label10:TextAlign := System.Drawing.ContentAlignment.MiddleLeft
        // 
        // label11
        // 
        SELF:label11:AutoSize := TRUE
        SELF:label11:Location := System.Drawing.Point{293, 49}
        SELF:label11:Name := "label11"
        SELF:label11:Size := System.Drawing.Size{108, 13}
        SELF:label11:TabIndex := 19
        SELF:label11:Text := "Arrival HFO Item UID"
        SELF:label11:TextAlign := System.Drawing.ContentAlignment.MiddleLeft
        // 
        // tbArMGOUID
        // 
        SELF:tbArMGOUID:Location := System.Drawing.Point{463, 113}
        SELF:tbArMGOUID:Name := "tbArMGOUID"
        SELF:tbArMGOUID:Size := System.Drawing.Size{100, 21}
        SELF:tbArMGOUID:TabIndex := 18
        // 
        // tbArLFOUID
        // 
        SELF:tbArLFOUID:Location := System.Drawing.Point{463, 81}
        SELF:tbArLFOUID:Name := "tbArLFOUID"
        SELF:tbArLFOUID:Size := System.Drawing.Size{100, 21}
        SELF:tbArLFOUID:TabIndex := 17
        // 
        // tbArHFOUID
        // 
        SELF:tbArHFOUID:Location := System.Drawing.Point{463, 46}
        SELF:tbArHFOUID:Name := "tbArHFOUID"
        SELF:tbArHFOUID:Size := System.Drawing.Size{100, 21}
        SELF:tbArHFOUID:TabIndex := 16
        // 
        // button2
        // 
        SELF:button2:Location := System.Drawing.Point{28, 438}
        SELF:button2:Name := "button2"
        SELF:button2:Size := System.Drawing.Size{218, 23}
        SELF:button2:TabIndex := 15
        SELF:button2:Text := "Apply Changes To All Vessels"
        SELF:button2:UseVisualStyleBackColor := TRUE
        SELF:button2:Click += System.EventHandler{ SELF, @button2_Click() }
        // 
        // button1
        // 
        SELF:button1:Location := System.Drawing.Point{28, 399}
        SELF:button1:Name := "button1"
        SELF:button1:Size := System.Drawing.Size{218, 23}
        SELF:button1:TabIndex := 14
        SELF:button1:Text := "Apply Changes To Selected Vessel"
        SELF:button1:UseVisualStyleBackColor := TRUE
        SELF:button1:Click += System.EventHandler{ SELF, @button1_Click() }
        // 
        // label7
        // 
        SELF:label7:AutoSize := TRUE
        SELF:label7:Location := System.Drawing.Point{3, 319}
        SELF:label7:Name := "label7"
        SELF:label7:Size := System.Drawing.Size{121, 13}
        SELF:label7:TabIndex := 13
        SELF:label7:Text := "ETA Next Port Item UID"
        SELF:label7:TextAlign := System.Drawing.ContentAlignment.MiddleLeft
        // 
        // label8
        // 
        SELF:label8:AutoSize := TRUE
        SELF:label8:Location := System.Drawing.Point{3, 288}
        SELF:label8:Name := "label8"
        SELF:label8:Size := System.Drawing.Size{99, 13}
        SELF:label8:TabIndex := 12
        SELF:label8:Text := "Next Port Item UID"
        SELF:label8:TextAlign := System.Drawing.ContentAlignment.MiddleLeft
        // 
        // label5
        // 
        SELF:label5:AutoSize := TRUE
        SELF:label5:Location := System.Drawing.Point{3, 222}
        SELF:label5:Name := "label5"
        SELF:label5:Size := System.Drawing.Size{128, 13}
        SELF:label5:TabIndex := 11
        SELF:label5:Text := "Departure Date Item UID"
        SELF:label5:TextAlign := System.Drawing.ContentAlignment.MiddleLeft
        // 
        // label6
        // 
        SELF:label6:AutoSize := TRUE
        SELF:label6:Location := System.Drawing.Point{3, 187}
        SELF:label6:Name := "label6"
        SELF:label6:Size := System.Drawing.Size{113, 13}
        SELF:label6:TabIndex := 10
        SELF:label6:Text := "Departure Report UID"
        SELF:label6:TextAlign := System.Drawing.ContentAlignment.MiddleLeft
        // 
        // label4
        // 
        SELF:label4:AutoSize := TRUE
        SELF:label4:Location := System.Drawing.Point{3, 84}
        SELF:label4:Name := "label4"
        SELF:label4:Size := System.Drawing.Size{110, 13}
        SELF:label4:TabIndex := 9
        SELF:label4:Text := "Arrival Date Item UID"
        // 
        // label3
        // 
        SELF:label3:AutoSize := TRUE
        SELF:label3:Location := System.Drawing.Point{3, 49}
        SELF:label3:Name := "label3"
        SELF:label3:Size := System.Drawing.Size{95, 13}
        SELF:label3:TabIndex := 8
        SELF:label3:Text := "Arrival Report UID"
        // 
        // label2
        // 
        SELF:label2:AutoSize := TRUE
        SELF:label2:Font := System.Drawing.Font{"Tahoma", ((Single) 10), System.Drawing.FontStyle.Bold}
        SELF:label2:Location := System.Drawing.Point{284, 153}
        SELF:label2:Name := "label2"
        SELF:label2:Size := System.Drawing.Size{78, 17}
        SELF:label2:TabIndex := 7
        SELF:label2:Text := "Departure"
        // 
        // label1
        // 
        SELF:label1:AutoSize := TRUE
        SELF:label1:Font := System.Drawing.Font{"Tahoma", ((Single) 10), System.Drawing.FontStyle.Bold}
        SELF:label1:Location := System.Drawing.Point{293, 14}
        SELF:label1:Name := "label1"
        SELF:label1:Size := System.Drawing.Size{52, 17}
        SELF:label1:TabIndex := 6
        SELF:label1:Text := "Arrival"
        // 
        // textBox6
        // 
        SELF:textBox6:Location := System.Drawing.Point{146, 316}
        SELF:textBox6:Name := "textBox6"
        SELF:textBox6:Size := System.Drawing.Size{100, 21}
        SELF:textBox6:TabIndex := 5
        // 
        // tbDepNextPortUID
        // 
        SELF:tbDepNextPortUID:Location := System.Drawing.Point{146, 285}
        SELF:tbDepNextPortUID:Name := "tbDepNextPortUID"
        SELF:tbDepNextPortUID:Size := System.Drawing.Size{100, 21}
        SELF:tbDepNextPortUID:TabIndex := 4
        // 
        // textBox4
        // 
        SELF:textBox4:Location := System.Drawing.Point{146, 219}
        SELF:textBox4:Name := "textBox4"
        SELF:textBox4:Size := System.Drawing.Size{100, 21}
        SELF:textBox4:TabIndex := 3
        // 
        // tbDepRepUID
        // 
        SELF:tbDepRepUID:Location := System.Drawing.Point{146, 184}
        SELF:tbDepRepUID:Name := "tbDepRepUID"
        SELF:tbDepRepUID:Size := System.Drawing.Size{100, 21}
        SELF:tbDepRepUID:TabIndex := 2
        // 
        // textBox2
        // 
        SELF:textBox2:Location := System.Drawing.Point{146, 81}
        SELF:textBox2:Name := "textBox2"
        SELF:textBox2:Size := System.Drawing.Size{100, 21}
        SELF:textBox2:TabIndex := 1
        // 
        // tbArRepUID
        // 
        SELF:tbArRepUID:Location := System.Drawing.Point{146, 46}
        SELF:tbArRepUID:Name := "tbArRepUID"
        SELF:tbArRepUID:Size := System.Drawing.Size{100, 21}
        SELF:tbArRepUID:TabIndex := 0
        // 
        // userLabel
        // 
        SELF:userLabel:BackColor := System.Drawing.Color.White
        SELF:userLabel:BorderStyle := System.Windows.Forms.BorderStyle.Fixed3D
        SELF:userLabel:Dock := System.Windows.Forms.DockStyle.Top
        SELF:userLabel:Font := System.Drawing.Font{"Microsoft Sans Serif", ((Single) 8.25), System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(161))}
        SELF:userLabel:Location := System.Drawing.Point{2, 2}
        SELF:userLabel:Name := "userLabel"
        SELF:userLabel:Size := System.Drawing.Size{673, 23}
        SELF:userLabel:TabIndex := 2
        SELF:userLabel:Text := "No Vessel Selected"
        SELF:userLabel:TextAlign := System.Drawing.ContentAlignment.MiddleCenter
        // 
        // tabControl1
        // 
        SELF:tabControl1:Controls:Add(SELF:tabPage1)
        SELF:tabControl1:Controls:Add(SELF:tabPage2)
        SELF:tabControl1:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:tabControl1:Location := System.Drawing.Point{0, 0}
        SELF:tabControl1:Name := "tabControl1"
        SELF:tabControl1:SelectedIndex := 0
        SELF:tabControl1:Size := System.Drawing.Size{888, 571}
        SELF:tabControl1:TabIndex := 2
        SELF:tabControl1:SelectedIndexChanged += System.EventHandler{ SELF, @tabControl1_SelectedIndexChanged() }
        // 
        // tabPage1
        // 
        SELF:tabPage1:Controls:Add(SELF:label22)
        SELF:tabPage1:Controls:Add(SELF:txtSender)
        SELF:tabPage1:Controls:Add(SELF:buttonSaveSMTPSettings)
        SELF:tabPage1:Controls:Add(SELF:checkBoxSMTPSecure)
        SELF:tabPage1:Controls:Add(SELF:bttnTestSMTP)
        SELF:tabPage1:Controls:Add(SELF:label21)
        SELF:tabPage1:Controls:Add(SELF:label17)
        SELF:tabPage1:Controls:Add(SELF:txtPass)
        SELF:tabPage1:Controls:Add(SELF:label18)
        SELF:tabPage1:Controls:Add(SELF:txtUser)
        SELF:tabPage1:Controls:Add(SELF:label19)
        SELF:tabPage1:Controls:Add(SELF:txtPort)
        SELF:tabPage1:Controls:Add(SELF:label20)
        SELF:tabPage1:Controls:Add(SELF:txtSMTPServer)
        SELF:tabPage1:Location := System.Drawing.Point{4, 22}
        SELF:tabPage1:Name := "tabPage1"
        SELF:tabPage1:Padding := System.Windows.Forms.Padding{3}
        SELF:tabPage1:Size := System.Drawing.Size{880, 545}
        SELF:tabPage1:TabIndex := 0
        SELF:tabPage1:Text := "Global Settings"
        SELF:tabPage1:UseVisualStyleBackColor := TRUE
        // 
        // label22
        // 
        SELF:label22:AutoSize := TRUE
        SELF:label22:BackColor := System.Drawing.Color.White
        SELF:label22:Cursor := System.Windows.Forms.Cursors.Default
        SELF:label22:Font := System.Drawing.Font{"Arial", ((Single) 8), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0))}
        SELF:label22:ForeColor := System.Drawing.SystemColors.ControlText
        SELF:label22:Location := System.Drawing.Point{15, 142}
        SELF:label22:Name := "label22"
        SELF:label22:RightToLeft := System.Windows.Forms.RightToLeft.No
        SELF:label22:Size := System.Drawing.Size{45, 14}
        SELF:label22:TabIndex := 64
        SELF:label22:Text := "Sender "
        // 
        // txtSender
        // 
        SELF:txtSender:Location := System.Drawing.Point{71, 140}
        SELF:txtSender:Name := "txtSender"
        SELF:txtSender:Size := System.Drawing.Size{237, 20}
        SELF:txtSender:TabIndex := 53
        SELF:txtSender:Validating += System.ComponentModel.CancelEventHandler{ SELF, @txtSender_Validating() }
        // 
        // buttonSaveSMTPSettings
        // 
        SELF:buttonSaveSMTPSettings:Location := System.Drawing.Point{193, 269}
        SELF:buttonSaveSMTPSettings:Name := "buttonSaveSMTPSettings"
        SELF:buttonSaveSMTPSettings:Size := System.Drawing.Size{115, 23}
        SELF:buttonSaveSMTPSettings:TabIndex := 62
        SELF:buttonSaveSMTPSettings:Text := "Save SMTP Settings"
        SELF:buttonSaveSMTPSettings:UseVisualStyleBackColor := TRUE
        SELF:buttonSaveSMTPSettings:Click += System.EventHandler{ SELF, @buttonSaveSMTPSettings_Click() }
        // 
        // checkBoxSMTPSecure
        // 
        SELF:checkBoxSMTPSecure:AutoSize := TRUE
        SELF:checkBoxSMTPSecure:Font := System.Drawing.Font{"Arial Unicode MS", ((Single) 8.25), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(161))}
        SELF:checkBoxSMTPSecure:Location := System.Drawing.Point{71, 235}
        SELF:checkBoxSMTPSecure:Name := "checkBoxSMTPSecure"
        SELF:checkBoxSMTPSecure:Size := System.Drawing.Size{119, 19}
        SELF:checkBoxSMTPSecure:TabIndex := 61
        SELF:checkBoxSMTPSecure:Text := "Secure Connection"
        SELF:checkBoxSMTPSecure:UseVisualStyleBackColor := TRUE
        // 
        // bttnTestSMTP
        // 
        SELF:bttnTestSMTP:Location := System.Drawing.Point{71, 269}
        SELF:bttnTestSMTP:Name := "bttnTestSMTP"
        SELF:bttnTestSMTP:Size := System.Drawing.Size{115, 23}
        SELF:bttnTestSMTP:TabIndex := 59
        SELF:bttnTestSMTP:Text := "Test Connection"
        SELF:bttnTestSMTP:UseVisualStyleBackColor := TRUE
        SELF:bttnTestSMTP:Click += System.EventHandler{ SELF, @bttnTestSMTP_Click() }
        // 
        // label21
        // 
        SELF:label21:AutoSize := TRUE
        SELF:label21:BackColor := System.Drawing.Color.White
        SELF:label21:Cursor := System.Windows.Forms.Cursors.Default
        SELF:label21:Font := System.Drawing.Font{"Arial", ((Single) 9.75), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(161))}
        SELF:label21:ForeColor := System.Drawing.SystemColors.ControlText
        SELF:label21:Location := System.Drawing.Point{68, 47}
        SELF:label21:Name := "label21"
        SELF:label21:RightToLeft := System.Windows.Forms.RightToLeft.No
        SELF:label21:Size := System.Drawing.Size{96, 16}
        SELF:label21:TabIndex := 58
        SELF:label21:Text := "SMTP Settings"
        // 
        // label17
        // 
        SELF:label17:BackColor := System.Drawing.Color.White
        SELF:label17:Cursor := System.Windows.Forms.Cursors.Default
        SELF:label17:Font := System.Drawing.Font{"Arial", ((Single) 8), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0))}
        SELF:label17:ForeColor := System.Drawing.SystemColors.ControlText
        SELF:label17:Location := System.Drawing.Point{15, 206}
        SELF:label17:Name := "label17"
        SELF:label17:RightToLeft := System.Windows.Forms.RightToLeft.No
        SELF:label17:Size := System.Drawing.Size{50, 15}
        SELF:label17:TabIndex := 57
        SELF:label17:Text := "Pass"
        // 
        // txtPass
        // 
        SELF:txtPass:Location := System.Drawing.Point{71, 204}
        SELF:txtPass:Name := "txtPass"
        SELF:txtPass:Size := System.Drawing.Size{237, 20}
        SELF:txtPass:TabIndex := 56
        SELF:txtPass:UseSystemPasswordChar := TRUE
        // 
        // label18
        // 
        SELF:label18:BackColor := System.Drawing.Color.White
        SELF:label18:Cursor := System.Windows.Forms.Cursors.Default
        SELF:label18:Font := System.Drawing.Font{"Arial", ((Single) 8), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0))}
        SELF:label18:ForeColor := System.Drawing.SystemColors.ControlText
        SELF:label18:Location := System.Drawing.Point{15, 171}
        SELF:label18:Name := "label18"
        SELF:label18:RightToLeft := System.Windows.Forms.RightToLeft.No
        SELF:label18:Size := System.Drawing.Size{50, 15}
        SELF:label18:TabIndex := 55
        SELF:label18:Text := "User"
        // 
        // txtUser
        // 
        SELF:txtUser:Location := System.Drawing.Point{71, 169}
        SELF:txtUser:Name := "txtUser"
        SELF:txtUser:Size := System.Drawing.Size{237, 20}
        SELF:txtUser:TabIndex := 54
        // 
        // label19
        // 
        SELF:label19:BackColor := System.Drawing.Color.White
        SELF:label19:Cursor := System.Windows.Forms.Cursors.Default
        SELF:label19:Font := System.Drawing.Font{"Arial", ((Single) 8), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0))}
        SELF:label19:ForeColor := System.Drawing.SystemColors.ControlText
        SELF:label19:Location := System.Drawing.Point{15, 113}
        SELF:label19:Name := "label19"
        SELF:label19:RightToLeft := System.Windows.Forms.RightToLeft.No
        SELF:label19:Size := System.Drawing.Size{50, 15}
        SELF:label19:TabIndex := 53
        SELF:label19:Text := "Port"
        // 
        // txtPort
        // 
        SELF:txtPort:Location := System.Drawing.Point{71, 111}
        SELF:txtPort:Name := "txtPort"
        SELF:txtPort:Size := System.Drawing.Size{73, 20}
        SELF:txtPort:TabIndex := 51
        // 
        // label20
        // 
        SELF:label20:BackColor := System.Drawing.Color.White
        SELF:label20:Cursor := System.Windows.Forms.Cursors.Default
        SELF:label20:Font := System.Drawing.Font{"Arial", ((Single) 8), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0))}
        SELF:label20:ForeColor := System.Drawing.SystemColors.ControlText
        SELF:label20:Location := System.Drawing.Point{15, 84}
        SELF:label20:Name := "label20"
        SELF:label20:RightToLeft := System.Windows.Forms.RightToLeft.No
        SELF:label20:Size := System.Drawing.Size{50, 15}
        SELF:label20:TabIndex := 51
        SELF:label20:Text := "SMTP"
        // 
        // txtSMTPServer
        // 
        SELF:txtSMTPServer:Location := System.Drawing.Point{71, 82}
        SELF:txtSMTPServer:Name := "txtSMTPServer"
        SELF:txtSMTPServer:Size := System.Drawing.Size{237, 20}
        SELF:txtSMTPServer:TabIndex := 50
        // 
        // tabPage2
        // 
        SELF:tabPage2:Controls:Add(SELF:splitContainerControl1)
        SELF:tabPage2:Location := System.Drawing.Point{4, 22}
        SELF:tabPage2:Name := "tabPage2"
        SELF:tabPage2:Padding := System.Windows.Forms.Padding{3}
        SELF:tabPage2:Size := System.Drawing.Size{880, 545}
        SELF:tabPage2:TabIndex := 1
        SELF:tabPage2:Text := "Vessel Settings"
        SELF:tabPage2:UseVisualStyleBackColor := TRUE
        // 
        // MatchSettings
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{888, 571}
        SELF:Controls:Add(SELF:tabControl1)
        SELF:Name := "MatchSettings"
        SELF:Text := "Settings"
        SELF:Load += System.EventHandler{ SELF, @MatchSettings_Load() }
        ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl1)):EndInit()
        SELF:splitContainerControl1:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:LBCUsers)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:panelControl1)):EndInit()
        SELF:panelControl1:ResumeLayout(FALSE)
        SELF:panel1:ResumeLayout(FALSE)
        SELF:panel1:PerformLayout()
        SELF:tabControl1:ResumeLayout(FALSE)
        SELF:tabPage1:ResumeLayout(FALSE)
        SELF:tabPage1:PerformLayout()
        SELF:tabPage2:ResumeLayout(FALSE)
        SELF:ResumeLayout(FALSE)
    PRIVATE METHOD MatchSettings_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			

			SELF:MatchSettingsLoad()

        RETURN

    PRIVATE METHOD button1_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:applyToSelected()
        RETURN

    PRIVATE METHOD button2_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:applyToAllVessels()
        RETURN

    PRIVATE METHOD LBCUsers_SelectedIndexChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		self:LBCUsers_SelectedIndexChanged_Method()
        RETURN


    PRIVATE METHOD bttnTestSMTP_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void

			SELF:bttnTestSMTPClick()

        RETURN
    PRIVATE METHOD buttonSaveSMTPSettings_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void

			self:buttonSaveSMTPSettingsClick()

        RETURN
    PRIVATE METHOD txtSender_Validating( sender AS System.Object, e AS System.ComponentModel.CancelEventArgs ) AS System.Void
        RETURN
    
	PRIVATE METHOD tabControl1_SelectedIndexChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:LBCUsers_SelectedIndexChanged_Method()   
	RETURN

END CLASS
