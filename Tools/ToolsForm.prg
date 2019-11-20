PUBLIC PARTIAL CLASS ToolsForm ;
    INHERIT DevExpress.XtraEditors.XtraForm
    
    PRIVATE ButtonExportTables AS DevExpress.XtraEditors.SimpleButton
    PRIVATE TBeMail AS System.Windows.Forms.TextBox
    PRIVATE labelEMail AS System.Windows.Forms.Label
    PRIVATE TBSkyfileFolder AS System.Windows.Forms.TextBox
    PRIVATE label1 AS System.Windows.Forms.Label
    PRIVATE RBOutlook AS System.Windows.Forms.RadioButton
    PRIVATE RBSkyfile AS System.Windows.Forms.RadioButton
    PRIVATE TBXmlFileMask AS System.Windows.Forms.TextBox
    PRIVATE label2 AS System.Windows.Forms.Label
    PRIVATE ButtonClose AS DevExpress.XtraEditors.SimpleButton
    PRIVATE label3 AS System.Windows.Forms.Label
    PRIVATE label4 AS System.Windows.Forms.Label
    PRIVATE label5 AS System.Windows.Forms.Label
    PRIVATE TBSubject AS System.Windows.Forms.TextBox
    PRIVATE TBBody AS System.Windows.Forms.TextBox
    PRIVATE ButtonBodyIsm AS DevExpress.XtraEditors.SimpleButton
    PRIVATE TBLogDir AS System.Windows.Forms.TextBox
    PRIVATE labelLogDir AS System.Windows.Forms.Label
    PRIVATE ButtonExportOfficeForms AS DevExpress.XtraEditors.SimpleButton
    PRIVATE buttonExportAll AS DevExpress.XtraEditors.SimpleButton
    PRIVATE simpleButtonImportData AS DevExpress.XtraEditors.SimpleButton
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
PRIVATE METHOD InitializeComponent() AS VOID STRICT
    SELF:ButtonExportTables := DevExpress.XtraEditors.SimpleButton{}
    SELF:TBeMail := System.Windows.Forms.TextBox{}
    SELF:labelEMail := System.Windows.Forms.Label{}
    SELF:TBSkyfileFolder := System.Windows.Forms.TextBox{}
    SELF:label1 := System.Windows.Forms.Label{}
    SELF:RBOutlook := System.Windows.Forms.RadioButton{}
    SELF:RBSkyfile := System.Windows.Forms.RadioButton{}
    SELF:TBXmlFileMask := System.Windows.Forms.TextBox{}
    SELF:label2 := System.Windows.Forms.Label{}
    SELF:ButtonClose := DevExpress.XtraEditors.SimpleButton{}
    SELF:label3 := System.Windows.Forms.Label{}
    SELF:label4 := System.Windows.Forms.Label{}
    SELF:TBSubject := System.Windows.Forms.TextBox{}
    SELF:label5 := System.Windows.Forms.Label{}
    SELF:TBBody := System.Windows.Forms.TextBox{}
    SELF:ButtonBodyIsm := DevExpress.XtraEditors.SimpleButton{}
    SELF:TBLogDir := System.Windows.Forms.TextBox{}
    SELF:labelLogDir := System.Windows.Forms.Label{}
    SELF:ButtonExportOfficeForms := DevExpress.XtraEditors.SimpleButton{}
    SELF:buttonExportAll := DevExpress.XtraEditors.SimpleButton{}
    SELF:simpleButtonImportData := DevExpress.XtraEditors.SimpleButton{}
    SELF:SuspendLayout()
    // 
    // ButtonExportTables
    // 
    SELF:ButtonExportTables:Appearance:Options:UseTextOptions := TRUE
    SELF:ButtonExportTables:Appearance:TextOptions:WordWrap := DevExpress.Utils.WordWrap.Wrap
    SELF:ButtonExportTables:Location := System.Drawing.Point{343, 97}
    SELF:ButtonExportTables:Name := "ButtonExportTables"
    SELF:ButtonExportTables:Size := System.Drawing.Size{128, 35}
    SELF:ButtonExportTables:TabIndex := 10
    SELF:ButtonExportTables:Text := "Export Data to Vessel"
    SELF:ButtonExportTables:ToolTip := "Export Reports, Categories and Report Items"
    SELF:ButtonExportTables:Click += System.EventHandler{ SELF, @ButtonExportTables_Click() }
    // 
    // TBeMail
    // 
    SELF:TBeMail:Location := System.Drawing.Point{28, 62}
    SELF:TBeMail:Name := "TBeMail"
    SELF:TBeMail:Size := System.Drawing.Size{295, 21}
    SELF:TBeMail:TabIndex := 0
    // 
    // labelEMail
    // 
    SELF:labelEMail:AutoSize := TRUE
    SELF:labelEMail:Font := System.Drawing.Font{"Tahoma", 8.25, System.Drawing.FontStyle.Bold}
    SELF:labelEMail:Location := System.Drawing.Point{25, 15}
    SELF:labelEMail:Name := "labelEMail"
    SELF:labelEMail:Size := System.Drawing.Size{195, 13}
    SELF:labelEMail:TabIndex := 11
    SELF:labelEMail:Text := "Settings to be send to the Vessel:"
    // 
    // TBSkyfileFolder
    // 
    SELF:TBSkyfileFolder:Enabled := FALSE
    SELF:TBSkyfileFolder:Location := System.Drawing.Point{28, 357}
    SELF:TBSkyfileFolder:Name := "TBSkyfileFolder"
    SELF:TBSkyfileFolder:Size := System.Drawing.Size{295, 21}
    SELF:TBSkyfileFolder:TabIndex := 6
    // 
    // label1
    // 
    SELF:label1:AutoSize := TRUE
    SELF:label1:Location := System.Drawing.Point{25, 340}
    SELF:label1:Name := "label1"
    SELF:label1:Size := System.Drawing.Size{75, 13}
    SELF:label1:TabIndex := 13
    SELF:label1:Text := "Skyfile Folder:"
    // 
    // RBOutlook
    // 
    SELF:RBOutlook:AutoSize := TRUE
    SELF:RBOutlook:@@Checked := TRUE
    SELF:RBOutlook:Location := System.Drawing.Point{28, 276}
    SELF:RBOutlook:Name := "RBOutlook"
    SELF:RBOutlook:Size := System.Drawing.Size{111, 17}
    SELF:RBOutlook:TabIndex := 4
    SELF:RBOutlook:TabStop := TRUE
    SELF:RBOutlook:Text := "Outlook mail client"
    SELF:RBOutlook:UseVisualStyleBackColor := TRUE
    SELF:RBOutlook:CheckedChanged += System.EventHandler{ SELF, @RBOutlook_CheckedChanged() }
    // 
    // RBSkyfile
    // 
    SELF:RBSkyfile:AutoSize := TRUE
    SELF:RBSkyfile:Location := System.Drawing.Point{28, 301}
    SELF:RBSkyfile:Name := "RBSkyfile"
    SELF:RBSkyfile:Size := System.Drawing.Size{105, 17}
    SELF:RBSkyfile:TabIndex := 5
    SELF:RBSkyfile:Text := "Skyfile mail client"
    SELF:RBSkyfile:UseVisualStyleBackColor := TRUE
    // 
    // TBXmlFileMask
    // 
    SELF:TBXmlFileMask:Enabled := FALSE
    SELF:TBXmlFileMask:Location := System.Drawing.Point{28, 417}
    SELF:TBXmlFileMask:Name := "TBXmlFileMask"
    SELF:TBXmlFileMask:Size := System.Drawing.Size{295, 21}
    SELF:TBXmlFileMask:TabIndex := 7
    SELF:TBXmlFileMask:Text := "FleetManagerData-*.XML"
    // 
    // label2
    // 
    SELF:label2:AutoSize := TRUE
    SELF:label2:Location := System.Drawing.Point{25, 400}
    SELF:label2:Name := "label2"
    SELF:label2:Size := System.Drawing.Size{88, 13}
    SELF:label2:TabIndex := 17
    SELF:label2:Text := "Skyfile File Mask:"
    // 
    // ButtonClose
    // 
    SELF:ButtonClose:Appearance:Options:UseTextOptions := TRUE
    SELF:ButtonClose:Appearance:TextOptions:WordWrap := DevExpress.Utils.WordWrap.Wrap
    SELF:ButtonClose:Location := System.Drawing.Point{126, 594}
    SELF:ButtonClose:Name := "ButtonClose"
    SELF:ButtonClose:Size := System.Drawing.Size{70, 35}
    SELF:ButtonClose:TabIndex := 11
    SELF:ButtonClose:Text := "Close"
    SELF:ButtonClose:ToolTip := "Export Reports, Categories and Report Items"
    SELF:ButtonClose:Click += System.EventHandler{ SELF, @ButtonClose_Click() }
    // 
    // label3
    // 
    SELF:label3:AutoSize := TRUE
    SELF:label3:Location := System.Drawing.Point{25, 45}
    SELF:label3:Name := "label3"
    SELF:label3:Size := System.Drawing.Size{288, 13}
    SELF:label3:TabIndex := 18
    SELF:label3:Text := "Your Company's eMail to receive the Data from the Vessel:"
    // 
    // label4
    // 
    SELF:label4:AutoSize := TRUE
    SELF:label4:Location := System.Drawing.Point{25, 95}
    SELF:label4:Name := "label4"
    SELF:label4:Size := System.Drawing.Size{151, 13}
    SELF:label4:TabIndex := 20
    SELF:label4:Text := "Subject of eMail the message:"
    // 
    // TBSubject
    // 
    SELF:TBSubject:Enabled := FALSE
    SELF:TBSubject:Location := System.Drawing.Point{28, 112}
    SELF:TBSubject:Name := "TBSubject"
    SELF:TBSubject:Size := System.Drawing.Size{295, 21}
    SELF:TBSubject:TabIndex := 1
    // 
    // label5
    // 
    SELF:label5:AutoSize := TRUE
    SELF:label5:Location := System.Drawing.Point{25, 145}
    SELF:label5:Name := "label5"
    SELF:label5:Size := System.Drawing.Size{139, 13}
    SELF:label5:TabIndex := 22
    SELF:label5:Text := "Body of eMail the message:"
    // 
    // TBBody
    // 
    SELF:TBBody:Enabled := FALSE
    SELF:TBBody:Location := System.Drawing.Point{28, 162}
    SELF:TBBody:Multiline := TRUE
    SELF:TBBody:Name := "TBBody"
    SELF:TBBody:Size := System.Drawing.Size{295, 38}
    SELF:TBBody:TabIndex := 2
    SELF:TBBody:Text := "Data set created on: "
    // 
    // ButtonBodyIsm
    // 
    SELF:ButtonBodyIsm:Location := System.Drawing.Point{343, 62}
    SELF:ButtonBodyIsm:Name := "ButtonBodyIsm"
    SELF:ButtonBodyIsm:Size := System.Drawing.Size{295, 23}
    SELF:ButtonBodyIsm:TabIndex := 8
    SELF:ButtonBodyIsm:Text := "Open and review the eMail body text form before exporting"
    SELF:ButtonBodyIsm:Click += System.EventHandler{ SELF, @ButtonBodyIsm_Click() }
    // 
    // TBLogDir
    // 
    SELF:TBLogDir:Location := System.Drawing.Point{28, 232}
    SELF:TBLogDir:Name := "TBLogDir"
    SELF:TBLogDir:Size := System.Drawing.Size{295, 21}
    SELF:TBLogDir:TabIndex := 3
    // 
    // labelLogDir
    // 
    SELF:labelLogDir:AutoSize := TRUE
    SELF:labelLogDir:Location := System.Drawing.Point{25, 215}
    SELF:labelLogDir:Name := "labelLogDir"
    SELF:labelLogDir:Size := System.Drawing.Size{74, 13}
    SELF:labelLogDir:TabIndex := 24
    SELF:labelLogDir:Text := "LogDir Folder:"
    // 
    // ButtonExportOfficeForms
    // 
    SELF:ButtonExportOfficeForms:Appearance:Options:UseTextOptions := TRUE
    SELF:ButtonExportOfficeForms:Appearance:TextOptions:WordWrap := DevExpress.Utils.WordWrap.Wrap
    SELF:ButtonExportOfficeForms:Location := System.Drawing.Point{510, 97}
    SELF:ButtonExportOfficeForms:Name := "ButtonExportOfficeForms"
    SELF:ButtonExportOfficeForms:Size := System.Drawing.Size{128, 35}
    SELF:ButtonExportOfficeForms:TabIndex := 25
    SELF:ButtonExportOfficeForms:Text := "Export Office Reports"
    SELF:ButtonExportOfficeForms:ToolTip := "Export Office Reports, Categories and Report Items"
    SELF:ButtonExportOfficeForms:Click += System.EventHandler{ SELF, @ButtonExportOfficeForms_Click() }
    // 
    // buttonExportAll
    // 
    SELF:buttonExportAll:Appearance:Options:UseTextOptions := TRUE
    SELF:buttonExportAll:Appearance:TextOptions:WordWrap := DevExpress.Utils.WordWrap.Wrap
    SELF:buttonExportAll:Location := System.Drawing.Point{343, 145}
    SELF:buttonExportAll:Name := "buttonExportAll"
    SELF:buttonExportAll:Size := System.Drawing.Size{295, 35}
    SELF:buttonExportAll:TabIndex := 26
    SELF:buttonExportAll:Text := "Export Data for All Vessels"
    SELF:buttonExportAll:ToolTip := "Export Reports, Categories and Report Items"
    SELF:buttonExportAll:Click += System.EventHandler{ SELF, @buttonExportAll_Click() }
    // 
    // simpleButtonImportData
    // 
    SELF:simpleButtonImportData:Appearance:Options:UseTextOptions := TRUE
    SELF:simpleButtonImportData:Appearance:TextOptions:WordWrap := DevExpress.Utils.WordWrap.Wrap
    SELF:simpleButtonImportData:Location := System.Drawing.Point{343, 193}
    SELF:simpleButtonImportData:Name := "simpleButtonImportData"
    SELF:simpleButtonImportData:Size := System.Drawing.Size{128, 35}
    SELF:simpleButtonImportData:TabIndex := 27
    SELF:simpleButtonImportData:Text := "Import Zip File"
    SELF:simpleButtonImportData:ToolTip := "Import Zip File"
    SELF:simpleButtonImportData:Click += System.EventHandler{ SELF, @simpleButtonImportData_Click() }
    // 
    // ToolsForm
    // 
    SELF:AutoScaleDimensions := System.Drawing.SizeF{6, 13}
    SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
    SELF:ClientSize := System.Drawing.Size{655, 641}
    SELF:Controls:Add(SELF:simpleButtonImportData)
    SELF:Controls:Add(SELF:buttonExportAll)
    SELF:Controls:Add(SELF:ButtonExportOfficeForms)
    SELF:Controls:Add(SELF:TBLogDir)
    SELF:Controls:Add(SELF:labelLogDir)
    SELF:Controls:Add(SELF:ButtonBodyIsm)
    SELF:Controls:Add(SELF:label5)
    SELF:Controls:Add(SELF:TBBody)
    SELF:Controls:Add(SELF:label4)
    SELF:Controls:Add(SELF:TBSubject)
    SELF:Controls:Add(SELF:label3)
    SELF:Controls:Add(SELF:ButtonClose)
    SELF:Controls:Add(SELF:TBXmlFileMask)
    SELF:Controls:Add(SELF:label2)
    SELF:Controls:Add(SELF:RBSkyfile)
    SELF:Controls:Add(SELF:RBOutlook)
    SELF:Controls:Add(SELF:TBSkyfileFolder)
    SELF:Controls:Add(SELF:label1)
    SELF:Controls:Add(SELF:TBeMail)
    SELF:Controls:Add(SELF:labelEMail)
    SELF:Controls:Add(SELF:ButtonExportTables)
    SELF:MinimizeBox := FALSE
    SELF:Name := "ToolsForm"
    SELF:StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen
    SELF:Text := "Tools Form"
    SELF:Load += System.EventHandler{ SELF, @ToolsForm_Load() }
    SELF:ResumeLayout(FALSE)
    SELF:PerformLayout()

PRIVATE METHOD ToolsForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:ToolsForm_OnLoad()
        RETURN

PRIVATE METHOD ButtonExportTables_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:ExportTablesToVessel()
        RETURN

PRIVATE METHOD RBOutlook_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:RBCheckedChanged()
        RETURN

PRIVATE METHOD ButtonClose_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:Close()
        RETURN

PRIVATE METHOD ButtonBodyIsm_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:OpenBodyISMForm()
        RETURN

PRIVATE METHOD ButtonExportOfficeForms_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:ExportOfficeTables()    
    RETURN

PRIVATE METHOD buttonExportAll_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:ExportTablesToAllVessels()            
    RETURN

PRIVATE METHOD simpleButtonImportData_Click(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
		SELF:ImportDataFromZip()
END CLASS
