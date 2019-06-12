#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#Using System.IO
#Using System.Diagnostics
PARTIAL CLASS UsersSetupForm INHERIT DevExpress.XtraEditors.XtraForm
    PRIVATE splitContainerControl1 AS DevExpress.XtraEditors.SplitContainerControl
    EXPORT LBCUsers AS DevExpress.XtraEditors.ListBoxControl
    PRIVATE panelControl1 AS DevExpress.XtraEditors.PanelControl
    PRIVATE canEditVoyages AS System.Windows.Forms.CheckBox
    PRIVATE colorDialog1 AS System.Windows.Forms.ColorDialog
    PRIVATE oDTUsers AS System.Data.DataTable
    PRIVATE userLabel AS System.Windows.Forms.Label
    PRIVATE panel1 AS System.Windows.Forms.Panel
    PRIVATE lSuspendNotification AS System.Boolean
    PRIVATE checkBox2 AS System.Windows.Forms.CheckBox
    PRIVATE canEditReports AS System.Windows.Forms.CheckBox
    PRIVATE checkBox3 AS System.Windows.Forms.CheckBox
    PRIVATE checkBox1 AS System.Windows.Forms.CheckBox
    PRIVATE canCreateReports AS System.Windows.Forms.CheckBox
    PRIVATE canDeleteOfficeReports AS System.Windows.Forms.CheckBox
    PRIVATE CanSeeAllOfficeReports AS System.Windows.Forms.CheckBox
    PRIVATE CanEditFinalizedOfficeReports AS System.Windows.Forms.CheckBox
    PRIVATE CHBisGM AS System.Windows.Forms.CheckBox
    PRIVATE SplitContainerControl2 AS DevExpress.XtraEditors.SplitContainerControl
    EXPORT SplitContainerControlSetupUsersH AS DevExpress.XtraEditors.SplitContainerControl
    EXPORT ListViewGroups AS System.Windows.Forms.ListView
    EXPORT GroupName AS System.Windows.Forms.ColumnHeader
    EXPORT TextEditUsers AS DevExpress.XtraEditors.TextEdit
    EXPORT ListViewNonGroups AS System.Windows.Forms.ListView
    EXPORT NonGroupName AS System.Windows.Forms.ColumnHeader
    EXPORT TextEditNonUsers AS DevExpress.XtraEditors.TextEdit
    PRIVATE GroupControlOfficeReports AS DevExpress.XtraEditors.GroupControl
    PRIVATE GroupControlVesselReports AS DevExpress.XtraEditors.GroupControl
    PRIVATE GroupControlGeneral AS DevExpress.XtraEditors.GroupControl
    PRIVATE CBHeadUser AS System.Windows.Forms.CheckBox
    PRIVATE ckbUsercanEditReportResults AS System.Windows.Forms.CheckBox
    PRIVATE CBEditReportChangeLog AS System.Windows.Forms.CheckBox
    PRIVATE cbInformUserForGMApproval AS System.Windows.Forms.CheckBox
    PRIVATE bttnEmailToSendOnGMApprovals AS System.Windows.Forms.Button
    PRIVATE txtbttnEmailToSendOnGMApprovals AS System.Windows.Forms.TextBox
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
        LOCAL resources := System.ComponentModel.ComponentResourceManager{typeof(UsersSetupForm)} AS System.ComponentModel.ComponentResourceManager
        SELF:splitContainerControl1 := DevExpress.XtraEditors.SplitContainerControl{}
        SELF:LBCUsers := DevExpress.XtraEditors.ListBoxControl{}
        SELF:panelControl1 := DevExpress.XtraEditors.PanelControl{}
        SELF:SplitContainerControl2 := DevExpress.XtraEditors.SplitContainerControl{}
        SELF:panel1 := System.Windows.Forms.Panel{}
        SELF:GroupControlOfficeReports := DevExpress.XtraEditors.GroupControl{}
        SELF:cbInformUserForGMApproval := System.Windows.Forms.CheckBox{}
        SELF:CBEditReportChangeLog := System.Windows.Forms.CheckBox{}
        SELF:CBHeadUser := System.Windows.Forms.CheckBox{}
        SELF:canCreateReports := System.Windows.Forms.CheckBox{}
        SELF:canDeleteOfficeReports := System.Windows.Forms.CheckBox{}
        SELF:CanSeeAllOfficeReports := System.Windows.Forms.CheckBox{}
        SELF:CHBisGM := System.Windows.Forms.CheckBox{}
        SELF:CanEditFinalizedOfficeReports := System.Windows.Forms.CheckBox{}
        SELF:GroupControlVesselReports := DevExpress.XtraEditors.GroupControl{}
        SELF:checkBox2 := System.Windows.Forms.CheckBox{}
        SELF:checkBox1 := System.Windows.Forms.CheckBox{}
        SELF:GroupControlGeneral := DevExpress.XtraEditors.GroupControl{}
        SELF:ckbUsercanEditReportResults := System.Windows.Forms.CheckBox{}
        SELF:canEditVoyages := System.Windows.Forms.CheckBox{}
        SELF:canEditReports := System.Windows.Forms.CheckBox{}
        SELF:checkBox3 := System.Windows.Forms.CheckBox{}
        SELF:SplitContainerControlSetupUsersH := DevExpress.XtraEditors.SplitContainerControl{}
        SELF:ListViewGroups := System.Windows.Forms.ListView{}
        SELF:GroupName := System.Windows.Forms.ColumnHeader{}
        SELF:TextEditUsers := DevExpress.XtraEditors.TextEdit{}
        SELF:ListViewNonGroups := System.Windows.Forms.ListView{}
        SELF:NonGroupName := System.Windows.Forms.ColumnHeader{}
        SELF:TextEditNonUsers := DevExpress.XtraEditors.TextEdit{}
        SELF:userLabel := System.Windows.Forms.Label{}
        SELF:colorDialog1 := System.Windows.Forms.ColorDialog{}
        SELF:txtbttnEmailToSendOnGMApprovals := System.Windows.Forms.TextBox{}
        SELF:bttnEmailToSendOnGMApprovals := System.Windows.Forms.Button{}
        ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl1)):BeginInit()
        SELF:splitContainerControl1:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:LBCUsers)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:panelControl1)):BeginInit()
        SELF:panelControl1:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:SplitContainerControl2)):BeginInit()
        SELF:SplitContainerControl2:SuspendLayout()
        SELF:panel1:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:GroupControlOfficeReports)):BeginInit()
        SELF:GroupControlOfficeReports:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:GroupControlVesselReports)):BeginInit()
        SELF:GroupControlVesselReports:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:GroupControlGeneral)):BeginInit()
        SELF:GroupControlGeneral:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:SplitContainerControlSetupUsersH)):BeginInit()
        SELF:SplitContainerControlSetupUsersH:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:TextEditUsers:Properties)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:TextEditNonUsers:Properties)):BeginInit()
        SELF:SuspendLayout()
        // 
        // splitContainerControl1
        // 
        SELF:splitContainerControl1:BorderStyle := DevExpress.XtraEditors.Controls.BorderStyles.Simple
        SELF:splitContainerControl1:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:splitContainerControl1:Location := System.Drawing.Point{0, 0}
        SELF:splitContainerControl1:Name := "splitContainerControl1"
        SELF:splitContainerControl1:Panel1:Controls:Add(SELF:LBCUsers)
        SELF:splitContainerControl1:Panel1:Text := "Panel1"
        SELF:splitContainerControl1:Panel2:Controls:Add(SELF:panelControl1)
        SELF:splitContainerControl1:Panel2:Text := "Panel2"
        SELF:splitContainerControl1:Size := System.Drawing.Size{1068, 615}
        SELF:splitContainerControl1:SplitterPosition := 188
        SELF:splitContainerControl1:TabIndex := 0
        SELF:splitContainerControl1:Text := "splitContainerControl1"
        // 
        // LBCUsers
        // 
        SELF:LBCUsers:Appearance:Font := System.Drawing.Font{"Lucida Console", ((Single) 8.25)}
        SELF:LBCUsers:Appearance:ForeColor := System.Drawing.Color.Black
        SELF:LBCUsers:Appearance:Options:UseFont := TRUE
        SELF:LBCUsers:Appearance:Options:UseForeColor := TRUE
        SELF:LBCUsers:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:LBCUsers:HorizontalScrollbar := TRUE
        SELF:LBCUsers:Location := System.Drawing.Point{0, 0}
        SELF:LBCUsers:Name := "LBCUsers"
        SELF:LBCUsers:Size := System.Drawing.Size{188, 611}
        SELF:LBCUsers:TabIndex := 2
        SELF:LBCUsers:SelectedIndexChanged += System.EventHandler{ SELF, @LBCUsers_SelectedIndexChanged() }
        // 
        // panelControl1
        // 
        SELF:panelControl1:Controls:Add(SELF:SplitContainerControl2)
        SELF:panelControl1:Controls:Add(SELF:userLabel)
        SELF:panelControl1:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:panelControl1:Location := System.Drawing.Point{0, 0}
        SELF:panelControl1:Name := "panelControl1"
        SELF:panelControl1:Size := System.Drawing.Size{871, 611}
        SELF:panelControl1:TabIndex := 0
        // 
        // SplitContainerControl2
        // 
        SELF:SplitContainerControl2:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:SplitContainerControl2:Horizontal := FALSE
        SELF:SplitContainerControl2:Location := System.Drawing.Point{2, 25}
        SELF:SplitContainerControl2:Name := "SplitContainerControl2"
        SELF:SplitContainerControl2:Panel1:Controls:Add(SELF:panel1)
        SELF:SplitContainerControl2:Panel1:Text := "Panel1"
        SELF:SplitContainerControl2:Panel2:Controls:Add(SELF:SplitContainerControlSetupUsersH)
        SELF:SplitContainerControl2:Panel2:Text := "Panel2"
        SELF:SplitContainerControl2:Size := System.Drawing.Size{867, 584}
        SELF:SplitContainerControl2:SplitterPosition := 369
        SELF:SplitContainerControl2:TabIndex := 4
        SELF:SplitContainerControl2:Text := "splitContainerControl2"
        // 
        // panel1
        // 
        SELF:panel1:BackColor := System.Drawing.Color.White
        SELF:panel1:BorderStyle := System.Windows.Forms.BorderStyle.Fixed3D
        SELF:panel1:Controls:Add(SELF:GroupControlOfficeReports)
        SELF:panel1:Controls:Add(SELF:GroupControlVesselReports)
        SELF:panel1:Controls:Add(SELF:GroupControlGeneral)
        SELF:panel1:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:panel1:Location := System.Drawing.Point{0, 0}
        SELF:panel1:Name := "panel1"
        SELF:panel1:Size := System.Drawing.Size{867, 369}
        SELF:panel1:TabIndex := 3
        // 
        // GroupControlOfficeReports
        // 
        SELF:GroupControlOfficeReports:AppearanceCaption:Font := System.Drawing.Font{"Tahoma", ((Single) 9), System.Drawing.FontStyle.Bold}
        SELF:GroupControlOfficeReports:AppearanceCaption:Options:UseFont := TRUE
        SELF:GroupControlOfficeReports:Controls:Add(SELF:bttnEmailToSendOnGMApprovals)
        SELF:GroupControlOfficeReports:Controls:Add(SELF:txtbttnEmailToSendOnGMApprovals)
        SELF:GroupControlOfficeReports:Controls:Add(SELF:cbInformUserForGMApproval)
        SELF:GroupControlOfficeReports:Controls:Add(SELF:CBEditReportChangeLog)
        SELF:GroupControlOfficeReports:Controls:Add(SELF:CBHeadUser)
        SELF:GroupControlOfficeReports:Controls:Add(SELF:canCreateReports)
        SELF:GroupControlOfficeReports:Controls:Add(SELF:canDeleteOfficeReports)
        SELF:GroupControlOfficeReports:Controls:Add(SELF:CanSeeAllOfficeReports)
        SELF:GroupControlOfficeReports:Controls:Add(SELF:CHBisGM)
        SELF:GroupControlOfficeReports:Controls:Add(SELF:CanEditFinalizedOfficeReports)
        SELF:GroupControlOfficeReports:Location := System.Drawing.Point{358, 101}
        SELF:GroupControlOfficeReports:Name := "GroupControlOfficeReports"
        SELF:GroupControlOfficeReports:Size := System.Drawing.Size{499, 248}
        SELF:GroupControlOfficeReports:TabIndex := 16
        SELF:GroupControlOfficeReports:Text := "Office's Reports"
        // 
        // cbInformUserForGMApproval
        // 
        SELF:cbInformUserForGMApproval:AutoSize := TRUE
        SELF:cbInformUserForGMApproval:Location := System.Drawing.Point{5, 186}
        SELF:cbInformUserForGMApproval:Name := "cbInformUserForGMApproval"
        SELF:cbInformUserForGMApproval:Size := System.Drawing.Size{213, 17}
        SELF:cbInformUserForGMApproval:TabIndex := 19
        SELF:cbInformUserForGMApproval:Text := "Inform User for GM approvals on email "
        SELF:cbInformUserForGMApproval:UseVisualStyleBackColor := TRUE
        SELF:cbInformUserForGMApproval:CheckedChanged += System.EventHandler{ SELF, @cbInformUserForGMApproval_CheckedChanged() }
        // 
        // CBEditReportChangeLog
        // 
        SELF:CBEditReportChangeLog:AutoSize := TRUE
        SELF:CBEditReportChangeLog:Location := System.Drawing.Point{5, 163}
        SELF:CBEditReportChangeLog:Name := "CBEditReportChangeLog"
        SELF:CBEditReportChangeLog:Size := System.Drawing.Size{162, 17}
        SELF:CBEditReportChangeLog:TabIndex := 18
        SELF:CBEditReportChangeLog:Text := "Can Edit Report Change Log"
        SELF:CBEditReportChangeLog:UseVisualStyleBackColor := TRUE
        SELF:CBEditReportChangeLog:CheckedChanged += System.EventHandler{ SELF, @CBEditReportChangeLog_CheckedChanged() }
        // 
        // CBHeadUser
        // 
        SELF:CBHeadUser:AutoSize := TRUE
        SELF:CBHeadUser:Location := System.Drawing.Point{5, 117}
        SELF:CBHeadUser:Name := "CBHeadUser"
        SELF:CBHeadUser:Size := System.Drawing.Size{76, 17}
        SELF:CBHeadUser:TabIndex := 17
        SELF:CBHeadUser:Text := "Head User"
        SELF:CBHeadUser:UseVisualStyleBackColor := TRUE
        SELF:CBHeadUser:CheckedChanged += System.EventHandler{ SELF, @CBHeadUser_CheckedChanged() }
        // 
        // canCreateReports
        // 
        SELF:canCreateReports:AutoSize := TRUE
        SELF:canCreateReports:Location := System.Drawing.Point{5, 25}
        SELF:canCreateReports:Name := "canCreateReports"
        SELF:canCreateReports:Size := System.Drawing.Size{145, 17}
        SELF:canCreateReports:TabIndex := 6
        SELF:canCreateReports:Text := "User can Create Reports"
        SELF:canCreateReports:UseVisualStyleBackColor := TRUE
        SELF:canCreateReports:CheckedChanged += System.EventHandler{ SELF, @canCreateReports_CheckedChanged() }
        // 
        // canDeleteOfficeReports
        // 
        SELF:canDeleteOfficeReports:AutoSize := TRUE
        SELF:canDeleteOfficeReports:Location := System.Drawing.Point{5, 48}
        SELF:canDeleteOfficeReports:Name := "canDeleteOfficeReports"
        SELF:canDeleteOfficeReports:Size := System.Drawing.Size{299, 17}
        SELF:canDeleteOfficeReports:TabIndex := 10
        SELF:canDeleteOfficeReports:Text := "User can Delete other user's Reports ( finalised and not )"
        SELF:canDeleteOfficeReports:UseVisualStyleBackColor := TRUE
        SELF:canDeleteOfficeReports:CheckedChanged += System.EventHandler{ SELF, @canDeleteOfficeReports_CheckedChanged() }
        // 
        // CanSeeAllOfficeReports
        // 
        SELF:CanSeeAllOfficeReports:AutoSize := TRUE
        SELF:CanSeeAllOfficeReports:Location := System.Drawing.Point{5, 71}
        SELF:CanSeeAllOfficeReports:Name := "CanSeeAllOfficeReports"
        SELF:CanSeeAllOfficeReports:Size := System.Drawing.Size{256, 17}
        SELF:CanSeeAllOfficeReports:TabIndex := 12
        SELF:CanSeeAllOfficeReports:Text := "User can See other user's non finalised Reports "
        SELF:CanSeeAllOfficeReports:UseVisualStyleBackColor := TRUE
        SELF:CanSeeAllOfficeReports:CheckedChanged += System.EventHandler{ SELF, @CanSeeAllOfficeReports_CheckedChanged() }
        // 
        // CHBisGM
        // 
        SELF:CHBisGM:AutoSize := TRUE
        SELF:CHBisGM:Location := System.Drawing.Point{5, 140}
        SELF:CHBisGM:Name := "CHBisGM"
        SELF:CHBisGM:Size := System.Drawing.Size{108, 17}
        SELF:CHBisGM:TabIndex := 13
        SELF:CHBisGM:Text := "General Manager"
        SELF:CHBisGM:UseVisualStyleBackColor := TRUE
        SELF:CHBisGM:CheckedChanged += System.EventHandler{ SELF, @CHBisGM_CheckedChanged() }
        // 
        // CanEditFinalizedOfficeReports
        // 
        SELF:CanEditFinalizedOfficeReports:AutoSize := TRUE
        SELF:CanEditFinalizedOfficeReports:Location := System.Drawing.Point{5, 94}
        SELF:CanEditFinalizedOfficeReports:Name := "CanEditFinalizedOfficeReports"
        SELF:CanEditFinalizedOfficeReports:Size := System.Drawing.Size{172, 17}
        SELF:CanEditFinalizedOfficeReports:TabIndex := 11
        SELF:CanEditFinalizedOfficeReports:Text := "User can Edit finalized Reports"
        SELF:CanEditFinalizedOfficeReports:UseVisualStyleBackColor := TRUE
        SELF:CanEditFinalizedOfficeReports:CheckedChanged += System.EventHandler{ SELF, @CanEditFinalizedOfficeReports_CheckedChanged() }
        // 
        // GroupControlVesselReports
        // 
        SELF:GroupControlVesselReports:AppearanceCaption:Font := System.Drawing.Font{"Tahoma", ((Single) 9), System.Drawing.FontStyle.Bold}
        SELF:GroupControlVesselReports:AppearanceCaption:Options:UseFont := TRUE
        SELF:GroupControlVesselReports:Controls:Add(SELF:checkBox2)
        SELF:GroupControlVesselReports:Controls:Add(SELF:checkBox1)
        SELF:GroupControlVesselReports:Location := System.Drawing.Point{358, 25}
        SELF:GroupControlVesselReports:Name := "GroupControlVesselReports"
        SELF:GroupControlVesselReports:Size := System.Drawing.Size{499, 70}
        SELF:GroupControlVesselReports:TabIndex := 15
        SELF:GroupControlVesselReports:Text := "Vessel's Reports"
        // 
        // checkBox2
        // 
        SELF:checkBox2:AutoSize := TRUE
        SELF:checkBox2:Location := System.Drawing.Point{5, 25}
        SELF:checkBox2:Name := "checkBox2"
        SELF:checkBox2:Size := System.Drawing.Size{151, 17}
        SELF:checkBox2:TabIndex := 3
        SELF:checkBox2:Text := "User can edit Report Data"
        SELF:checkBox2:UseVisualStyleBackColor := TRUE
        SELF:checkBox2:CheckedChanged += System.EventHandler{ SELF, @checkBox2_CheckedChanged() }
        // 
        // checkBox1
        // 
        SELF:checkBox1:AutoSize := TRUE
        SELF:checkBox1:Location := System.Drawing.Point{5, 48}
        SELF:checkBox1:Name := "checkBox1"
        SELF:checkBox1:Size := System.Drawing.Size{163, 17}
        SELF:checkBox1:TabIndex := 4
        SELF:checkBox1:Text := "User can delete Report Data"
        SELF:checkBox1:UseVisualStyleBackColor := TRUE
        SELF:checkBox1:CheckedChanged += System.EventHandler{ SELF, @checkBox1_CheckedChanged() }
        // 
        // GroupControlGeneral
        // 
        SELF:GroupControlGeneral:Appearance:Font := System.Drawing.Font{"Tahoma", ((Single) 9)}
        SELF:GroupControlGeneral:Appearance:Options:UseFont := TRUE
        SELF:GroupControlGeneral:AppearanceCaption:Font := System.Drawing.Font{"Tahoma", ((Single) 9), System.Drawing.FontStyle.Bold}
        SELF:GroupControlGeneral:AppearanceCaption:Options:UseFont := TRUE
        SELF:GroupControlGeneral:Controls:Add(SELF:ckbUsercanEditReportResults)
        SELF:GroupControlGeneral:Controls:Add(SELF:canEditVoyages)
        SELF:GroupControlGeneral:Controls:Add(SELF:canEditReports)
        SELF:GroupControlGeneral:Controls:Add(SELF:checkBox3)
        SELF:GroupControlGeneral:Location := System.Drawing.Point{17, 25}
        SELF:GroupControlGeneral:Name := "GroupControlGeneral"
        SELF:GroupControlGeneral:Size := System.Drawing.Size{311, 118}
        SELF:GroupControlGeneral:TabIndex := 14
        SELF:GroupControlGeneral:Text := "General"
        // 
        // ckbUsercanEditReportResults
        // 
        SELF:ckbUsercanEditReportResults:AutoSize := TRUE
        SELF:ckbUsercanEditReportResults:Location := System.Drawing.Point{5, 94}
        SELF:ckbUsercanEditReportResults:Name := "ckbUsercanEditReportResults"
        SELF:ckbUsercanEditReportResults:Size := System.Drawing.Size{181, 18}
        SELF:ckbUsercanEditReportResults:TabIndex := 6
        SELF:ckbUsercanEditReportResults:Text := "User can Edit Report Results"
        SELF:ckbUsercanEditReportResults:UseVisualStyleBackColor := TRUE
        SELF:ckbUsercanEditReportResults:CheckedChanged += System.EventHandler{ SELF, @ckbUsercanEditReportResults_CheckedChanged() }
        // 
        // canEditVoyages
        // 
        SELF:canEditVoyages:AutoSize := TRUE
        SELF:canEditVoyages:Location := System.Drawing.Point{5, 47}
        SELF:canEditVoyages:Name := "canEditVoyages"
        SELF:canEditVoyages:Size := System.Drawing.Size{148, 18}
        SELF:canEditVoyages:TabIndex := 1
        SELF:canEditVoyages:Text := "User can Edit Voyages"
        SELF:canEditVoyages:UseVisualStyleBackColor := TRUE
        SELF:canEditVoyages:CheckedChanged += System.EventHandler{ SELF, @canEditVoyages_CheckedChanged() }
        // 
        // canEditReports
        // 
        SELF:canEditReports:AutoSize := TRUE
        SELF:canEditReports:Location := System.Drawing.Point{5, 71}
        SELF:canEditReports:Name := "canEditReports"
        SELF:canEditReports:Size := System.Drawing.Size{192, 18}
        SELF:canEditReports:TabIndex := 2
        SELF:canEditReports:Text := "User can Access Report Setup"
        SELF:canEditReports:UseVisualStyleBackColor := TRUE
        SELF:canEditReports:CheckedChanged += System.EventHandler{ SELF, @canEditReports_CheckedChanged() }
        // 
        // checkBox3
        // 
        SELF:checkBox3:AutoSize := TRUE
        SELF:checkBox3:Location := System.Drawing.Point{5, 25}
        SELF:checkBox3:Name := "checkBox3"
        SELF:checkBox3:Size := System.Drawing.Size{167, 18}
        SELF:checkBox3:TabIndex := 5
        SELF:checkBox3:Text := "User can Enter Tools area"
        SELF:checkBox3:UseVisualStyleBackColor := TRUE
        SELF:checkBox3:CheckedChanged += System.EventHandler{ SELF, @checkBox3_CheckedChanged() }
        // 
        // SplitContainerControlSetupUsersH
        // 
        SELF:SplitContainerControlSetupUsersH:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:SplitContainerControlSetupUsersH:Location := System.Drawing.Point{0, 0}
        SELF:SplitContainerControlSetupUsersH:Name := "SplitContainerControlSetupUsersH"
        SELF:SplitContainerControlSetupUsersH:Panel1:Controls:Add(SELF:ListViewGroups)
        SELF:SplitContainerControlSetupUsersH:Panel1:Controls:Add(SELF:TextEditUsers)
        SELF:SplitContainerControlSetupUsersH:Panel1:Text := "Panel1"
        SELF:SplitContainerControlSetupUsersH:Panel2:Controls:Add(SELF:ListViewNonGroups)
        SELF:SplitContainerControlSetupUsersH:Panel2:Controls:Add(SELF:TextEditNonUsers)
        SELF:SplitContainerControlSetupUsersH:Panel2:Text := "Panel2"
        SELF:SplitContainerControlSetupUsersH:Size := System.Drawing.Size{867, 210}
        SELF:SplitContainerControlSetupUsersH:SplitterPosition := 430
        SELF:SplitContainerControlSetupUsersH:TabIndex := 1
        SELF:SplitContainerControlSetupUsersH:Text := "splitContainerControl1"
        // 
        // ListViewGroups
        // 
        SELF:ListViewGroups:AllowDrop := TRUE
        SELF:ListViewGroups:Columns:AddRange(<System.Windows.Forms.ColumnHeader>{ SELF:GroupName })
        SELF:ListViewGroups:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:ListViewGroups:FullRowSelect := TRUE
        SELF:ListViewGroups:HideSelection := FALSE
        SELF:ListViewGroups:Location := System.Drawing.Point{0, 20}
        SELF:ListViewGroups:Name := "ListViewGroups"
        SELF:ListViewGroups:Size := System.Drawing.Size{430, 190}
        SELF:ListViewGroups:TabIndex := 0
        SELF:ListViewGroups:UseCompatibleStateImageBehavior := FALSE
        SELF:ListViewGroups:View := System.Windows.Forms.View.Details
        SELF:ListViewGroups:ItemDrag += System.Windows.Forms.ItemDragEventHandler{ SELF, @ListViewGroups_ItemDrag() }
        SELF:ListViewGroups:DragDrop += System.Windows.Forms.DragEventHandler{ SELF, @ListViewGroups_DragDrop() }
        SELF:ListViewGroups:DragEnter += System.Windows.Forms.DragEventHandler{ SELF, @ListViewGroups_DragEnter() }
        SELF:ListViewGroups:MouseDoubleClick += System.Windows.Forms.MouseEventHandler{ SELF, @ListViewGroups_MouseDoubleClick() }
        // 
        // GroupName
        // 
        SELF:GroupName:Text := "Group Name"
        SELF:GroupName:Width := 350
        // 
        // TextEditUsers
        // 
        SELF:TextEditUsers:Dock := System.Windows.Forms.DockStyle.Top
        SELF:TextEditUsers:EditValue := "Member of Group:"
        SELF:TextEditUsers:Location := System.Drawing.Point{0, 0}
        SELF:TextEditUsers:Name := "TextEditUsers"
        SELF:TextEditUsers:Properties:Appearance:Font := System.Drawing.Font{"Tahoma", ((Single) 8), System.Drawing.FontStyle.Bold}
        SELF:TextEditUsers:Properties:Appearance:ForeColor := System.Drawing.Color.Green
        SELF:TextEditUsers:Properties:Appearance:Options:UseFont := TRUE
        SELF:TextEditUsers:Properties:Appearance:Options:UseForeColor := TRUE
        SELF:TextEditUsers:Size := System.Drawing.Size{430, 20}
        SELF:TextEditUsers:TabIndex := 1
        // 
        // ListViewNonGroups
        // 
        SELF:ListViewNonGroups:AllowDrop := TRUE
        SELF:ListViewNonGroups:Columns:AddRange(<System.Windows.Forms.ColumnHeader>{ SELF:NonGroupName })
        SELF:ListViewNonGroups:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:ListViewNonGroups:FullRowSelect := TRUE
        SELF:ListViewNonGroups:HideSelection := FALSE
        SELF:ListViewNonGroups:Location := System.Drawing.Point{0, 20}
        SELF:ListViewNonGroups:Name := "ListViewNonGroups"
        SELF:ListViewNonGroups:Size := System.Drawing.Size{432, 190}
        SELF:ListViewNonGroups:TabIndex := 3
        SELF:ListViewNonGroups:UseCompatibleStateImageBehavior := FALSE
        SELF:ListViewNonGroups:View := System.Windows.Forms.View.Details
        SELF:ListViewNonGroups:ItemDrag += System.Windows.Forms.ItemDragEventHandler{ SELF, @ListViewNonGroups_ItemDrag() }
        SELF:ListViewNonGroups:DragDrop += System.Windows.Forms.DragEventHandler{ SELF, @ListViewNonGroups_DragDrop() }
        SELF:ListViewNonGroups:DragEnter += System.Windows.Forms.DragEventHandler{ SELF, @ListViewNonGroups_DragEnter() }
        SELF:ListViewNonGroups:MouseDoubleClick += System.Windows.Forms.MouseEventHandler{ SELF, @ListViewNonGroups_MouseDoubleClick() }
        // 
        // NonGroupName
        // 
        SELF:NonGroupName:Text := "Group Name"
        SELF:NonGroupName:Width := 350
        // 
        // TextEditNonUsers
        // 
        SELF:TextEditNonUsers:Dock := System.Windows.Forms.DockStyle.Top
        SELF:TextEditNonUsers:EditValue := "Non-Member of Group:"
        SELF:TextEditNonUsers:Location := System.Drawing.Point{0, 0}
        SELF:TextEditNonUsers:Name := "TextEditNonUsers"
        SELF:TextEditNonUsers:Properties:Appearance:Font := System.Drawing.Font{"Tahoma", ((Single) 8), System.Drawing.FontStyle.Bold}
        SELF:TextEditNonUsers:Properties:Appearance:ForeColor := System.Drawing.Color.Red
        SELF:TextEditNonUsers:Properties:Appearance:Options:UseFont := TRUE
        SELF:TextEditNonUsers:Properties:Appearance:Options:UseForeColor := TRUE
        SELF:TextEditNonUsers:Size := System.Drawing.Size{432, 20}
        SELF:TextEditNonUsers:TabIndex := 2
        // 
        // userLabel
        // 
        SELF:userLabel:BackColor := System.Drawing.Color.White
        SELF:userLabel:BorderStyle := System.Windows.Forms.BorderStyle.Fixed3D
        SELF:userLabel:Dock := System.Windows.Forms.DockStyle.Top
        SELF:userLabel:Font := System.Drawing.Font{"Microsoft Sans Serif", ((Single) 8.25), System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(161))}
        SELF:userLabel:Location := System.Drawing.Point{2, 2}
        SELF:userLabel:Name := "userLabel"
        SELF:userLabel:Size := System.Drawing.Size{867, 23}
        SELF:userLabel:TabIndex := 2
        SELF:userLabel:Text := "No User Selected"
        SELF:userLabel:TextAlign := System.Drawing.ContentAlignment.MiddleCenter
        // 
        // txtbttnEmailToSendOnGMApprovals
        // 
        SELF:txtbttnEmailToSendOnGMApprovals:Location := System.Drawing.Point{21, 209}
        SELF:txtbttnEmailToSendOnGMApprovals:Name := "txtbttnEmailToSendOnGMApprovals"
        SELF:txtbttnEmailToSendOnGMApprovals:Size := System.Drawing.Size{246, 21}
        SELF:txtbttnEmailToSendOnGMApprovals:TabIndex := 20
        // 
        // bttnEmailToSendOnGMApprovals
        // 
        SELF:bttnEmailToSendOnGMApprovals:Location := System.Drawing.Point{273, 208}
        SELF:bttnEmailToSendOnGMApprovals:Name := "bttnEmailToSendOnGMApprovals"
        SELF:bttnEmailToSendOnGMApprovals:Size := System.Drawing.Size{55, 23}
        SELF:bttnEmailToSendOnGMApprovals:TabIndex := 21
        SELF:bttnEmailToSendOnGMApprovals:Text := "Save"
        SELF:bttnEmailToSendOnGMApprovals:UseVisualStyleBackColor := TRUE
        SELF:bttnEmailToSendOnGMApprovals:Click += System.EventHandler{ SELF, @bttnEmailToSendOnGMApprovals_Click() }
        // 
        // UsersSetupForm
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{1068, 615}
        SELF:Controls:Add(SELF:splitContainerControl1)
        SELF:Icon := ((System.Drawing.Icon)(resources:GetObject("$this.Icon")))
        SELF:Name := "UsersSetupForm"
        SELF:StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen
        SELF:Text := "Users Setup Form"
        SELF:FormClosing += System.Windows.Forms.FormClosingEventHandler{ SELF, @UsersSetupForm_FormClosing() }
        SELF:Load += System.EventHandler{ SELF, @UsersSetupForm_Load() }
        SELF:Shown += System.EventHandler{ SELF, @UsersSetupForm_Shown() }
        ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl1)):EndInit()
        SELF:splitContainerControl1:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:LBCUsers)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:panelControl1)):EndInit()
        SELF:panelControl1:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:SplitContainerControl2)):EndInit()
        SELF:SplitContainerControl2:ResumeLayout(FALSE)
        SELF:panel1:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:GroupControlOfficeReports)):EndInit()
        SELF:GroupControlOfficeReports:ResumeLayout(FALSE)
        SELF:GroupControlOfficeReports:PerformLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:GroupControlVesselReports)):EndInit()
        SELF:GroupControlVesselReports:ResumeLayout(FALSE)
        SELF:GroupControlVesselReports:PerformLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:GroupControlGeneral)):EndInit()
        SELF:GroupControlGeneral:ResumeLayout(FALSE)
        SELF:GroupControlGeneral:PerformLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:SplitContainerControlSetupUsersH)):EndInit()
        SELF:SplitContainerControlSetupUsersH:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:TextEditUsers:Properties)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:TextEditNonUsers:Properties)):EndInit()
        SELF:ResumeLayout(FALSE)
    PRIVATE METHOD UsersSetupForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:UsersSetupForm_OnLoad()
        RETURN

    EXPORT METHOD formUsersList(inData AS system.data.datatable) AS LOGIC
		lSuspendNotification := FALSE
		SELF:oDTUsers := inData
		SELF:LBCUsers:DataSource := SELF:oDTUsers
		SELF:LBCUsers:DisplayMember := "UserName"
		SELF:LBCUsers:ValueMember := "USER_UNIQUEID"
		lSuspendNotification := TRUE
		//LOCAL cReportName := oMainForm:LBCReports:GetDisplayItemValue(oMainForm:LBCReports:SelectedIndex):ToString() AS STRING
	RETURN TRUE
	
    PRIVATE METHOD LBCUsers_SelectedIndexChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	TRY
		IF SELF:LBCUsers:SelectedValue <> NULL .AND.  SELF:lSuspendNotification
			LOCAL cUserName := SELF:LBCUsers:GetDisplayItemValue(SELF:LBCUsers:SelectedIndex):ToString() AS STRING
			LOCAL cUserUID := SELF:LBCUsers:SelectedValue:ToString() AS STRING
			SELF:userLabel:Text := cUserName + " / " + cUserUID
			//SELF:LBCUsers:SetSelected(0,TRUE)
			LOCAL oRow  AS system.data.datarow 
			oRow := oMainForm:returnUserSetting(cUserUID:Trim()) 
			IF oRow == NULL
				RETURN
			ENDIF
			IF oRow["CanEditVoyages"]:ToString():Trim() == "True"
				//SELF:canEditVoyages:
				SELF:lSuspendNotification := FALSE
				SELF:canEditVoyages:Checked := TRUE
				SELF:lSuspendNotification := TRUE
			ELSE
				SELF:lSuspendNotification := FALSE
				SELF:canEditVoyages:Checked := FALSE
				SELF:lSuspendNotification := TRUE
			ENDIF
			IF oRow["CanEditReports"]:ToString():Trim() == "True"
				//SELF:canEditVoyages:
				SELF:lSuspendNotification := FALSE
				SELF:canEditReports:Checked := TRUE
				SELF:lSuspendNotification := TRUE
			ELSE
				SELF:lSuspendNotification := FALSE
				SELF:canEditReports:Checked := FALSE
				SELF:lSuspendNotification := TRUE
			ENDIF
			IF oRow["CanEditReportData"]:ToString():Trim() == "True"
				//SELF:canEditVoyages:
				SELF:lSuspendNotification := FALSE
				SELF:checkBox2:Checked := TRUE
				SELF:lSuspendNotification := TRUE
			ELSE
				SELF:lSuspendNotification := FALSE
				SELF:checkBox2:Checked := FALSE
				SELF:lSuspendNotification := TRUE
			ENDIF
			IF oRow["CanDeleteReportData"]:ToString():Trim() == "True"
				//SELF:canEditVoyages:
				SELF:lSuspendNotification := FALSE
				SELF:checkBox1:Checked := TRUE
				SELF:lSuspendNotification := TRUE
			ELSE
				SELF:lSuspendNotification := FALSE
				SELF:checkBox1:Checked := FALSE
				SELF:lSuspendNotification := TRUE
			ENDIF
			IF oRow["CanEnterToolsArea"]:ToString():Trim() == "True"
				//SELF:canEditVoyages:
				SELF:lSuspendNotification := FALSE
				SELF:checkBox3:Checked := TRUE
				SELF:lSuspendNotification := TRUE
			ELSE
				SELF:lSuspendNotification := FALSE
				SELF:checkBox3:Checked := FALSE
				SELF:lSuspendNotification := TRUE
			ENDIF
			
			IF oRow["CanCreateReports"]:ToString():Trim() == "True"
				//SELF:canEditVoyages:
				SELF:lSuspendNotification := FALSE
				SELF:canCreateReports:Checked := TRUE
				SELF:lSuspendNotification := TRUE
			ELSE
				SELF:lSuspendNotification := FALSE
				SELF:canCreateReports:Checked := FALSE
				SELF:lSuspendNotification := TRUE
			ENDIF
			
			IF oRow["CanDeleteOfficeReports"]:ToString():Trim() == "True"
				//SELF:canEditVoyages:
				SELF:lSuspendNotification := FALSE
				SELF:canDeleteOfficeReports:Checked := TRUE
				SELF:lSuspendNotification := TRUE
			ELSE
				SELF:lSuspendNotification := FALSE
				SELF:canDeleteOfficeReports:Checked := FALSE
				SELF:lSuspendNotification := TRUE
			ENDIF
			
			IF oRow["CanSeeAllOfficeReports"]:ToString():Trim() == "True"
				//SELF:canEditVoyages:
				SELF:lSuspendNotification := FALSE
				SELF:CanSeeAllOfficeReports:Checked := TRUE
				SELF:lSuspendNotification := TRUE
			ELSE
				SELF:lSuspendNotification := FALSE
				SELF:CanSeeAllOfficeReports:Checked := FALSE
				SELF:lSuspendNotification := TRUE
			ENDIF
			
			IF oRow["CanEditFinalizedOfficeReports"]:ToString():Trim() == "True"
				//SELF:canEditVoyages:
				SELF:lSuspendNotification := FALSE
				SELF:CanEditFinalizedOfficeReports:Checked := TRUE
				SELF:lSuspendNotification := TRUE
			ELSE
				SELF:lSuspendNotification := FALSE
				SELF:CanEditFinalizedOfficeReports:Checked := FALSE
				SELF:lSuspendNotification := TRUE
			ENDIF
			
			IF oRow["isGeneralManager"]:ToString():Trim() == "True"
				//SELF:canEditVoyages:
				SELF:lSuspendNotification := FALSE
				SELF:CHBisGM:Checked := TRUE
				SELF:lSuspendNotification := TRUE
			ELSE
				SELF:lSuspendNotification := FALSE
				SELF:CHBisGM:Checked := FALSE
				SELF:lSuspendNotification := TRUE
			ENDIF
			
			IF oRow["IsHeadUser"]:ToString():Trim() == "True"
				SELF:lSuspendNotification := FALSE
				SELF:CBHeadUser:Checked := TRUE
				SELF:lSuspendNotification := TRUE
			ELSE
				SELF:lSuspendNotification := FALSE
				SELF:CBHeadUser:Checked := FALSE
				SELF:lSuspendNotification := TRUE
			ENDIF
			
			IF oRow["CanEditReportResults"]:ToString():Trim() == "True"
				//SELF:canEditVoyages:
				SELF:lSuspendNotification := FALSE
				SELF:ckbUsercanEditReportResults:Checked := TRUE
				SELF:lSuspendNotification := TRUE
			ELSE
				SELF:lSuspendNotification := FALSE
				SELF:ckbUsercanEditReportResults:Checked := FALSE
				SELF:lSuspendNotification := TRUE
			ENDIF

			IF oRow["CanEditReportChangeLog"]:ToString():Trim() == "True"
				//SELF:canEditVoyages:
				SELF:lSuspendNotification := FALSE
				SELF:CBEditReportChangeLog:Checked := TRUE
				SELF:lSuspendNotification := TRUE
			ELSE
				SELF:lSuspendNotification := FALSE
				SELF:CBEditReportChangeLog:Checked := FALSE
				SELF:lSuspendNotification := TRUE
			ENDIF

			IF oRow["InformUserForGMApproval"]:ToString():Trim() == "True"
				//SELF:canEditVoyages:
				SELF:lSuspendNotification := FALSE
				SELF:cbInformUserForGMApproval:Checked := TRUE
				SELF:lSuspendNotification := TRUE
			ELSE
				SELF:lSuspendNotification := FALSE
				SELF:cbInformUserForGMApproval:Checked := FALSE
				SELF:lSuspendNotification := TRUE
			ENDIF

			IF oRow["InformUserForGMApprovalEmail"]:ToString():Trim() != ""
				SELF:txtbttnEmailToSendOnGMApprovals:Text := oRow["InformUserForGMApprovalEmail"]:ToString():Trim()
			ELSE
				SELF:txtbttnEmailToSendOnGMApprovals:Text := ""
			ENDIF
			
	
			//Below lines fill the Groups and Non-Groups ListViews
			SELF:FillListView_Groups(cUserUID)
			SELF:FillListView_NonGroups(cUserUID)
			////////////////////////////////////////////////////////////////
			//ADDED BY KIRIAKOS AT 31/05/16
			////////////////////////////////////////////////////////////////

		ENDIF
	CATCH exc AS Exception
		WB(exc:StackTrace)
	END	
    RETURN

    PRIVATE METHOD canEditVoyages_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		IF lSuspendNotification
			TRY
				IF SELF:canEditVoyages:Checked
					oMainForm:updateUserSetting("CanEditVoyages","1", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ELSE
					oMainForm:updateUserSetting("CanEditVoyages","0", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ENDIF
			CATCH
				
			END
			
        RETURN
		ENDIF
	RETURN
    PRIVATE METHOD canEditReports_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		IF lSuspendNotification
			TRY
				IF SELF:canEditReports:Checked
					oMainForm:updateUserSetting("CanEditReports","1", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ELSE
					oMainForm:updateUserSetting("CanEditReports","0", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ENDIF
			CATCH
				
			END
        RETURN
		ENDIF
        RETURN
    PRIVATE METHOD checkBox2_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	IF lSuspendNotification
			TRY
				IF SELF:checkBox2:Checked
					oMainForm:updateUserSetting("CanEditReportData","1", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ELSE
					oMainForm:updateUserSetting("CanEditReportData","0", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ENDIF
			CATCH
				
			END
			
        RETURN
		ENDIF
        RETURN
    PRIVATE METHOD checkBox1_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	IF lSuspendNotification
			TRY
				IF SELF:checkBox1:Checked
					oMainForm:updateUserSetting("CanDeleteReportData","1", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ELSE
					oMainForm:updateUserSetting("CanDeleteReportData","0", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ENDIF
			CATCH
				
			END
			
        RETURN
		ENDIF
        RETURN
    PRIVATE METHOD checkBox3_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	IF lSuspendNotification
			TRY
				IF SELF:checkBox3:Checked
					oMainForm:updateUserSetting("CanEnterToolsArea","1", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ELSE
					oMainForm:updateUserSetting("CanEnterToolsArea","0", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ENDIF
			CATCH
				
			END
			
        RETURN
		ENDIF
    RETURN

  
    PRIVATE METHOD canCreateReports_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		IF lSuspendNotification
			TRY
				IF SELF:canCreateReports:Checked
					oMainForm:updateUserSetting("CanCreateReports","1", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ELSE
					oMainForm:updateUserSetting("CanCreateReports","0", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ENDIF
			CATCH
				
			END
			
        RETURN
		ENDIF
     RETURN
    PRIVATE METHOD canDeleteOfficeReports_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		IF lSuspendNotification
			TRY
				IF SELF:canDeleteOfficeReports:Checked
					oMainForm:updateUserSetting("CanDeleteOfficeReports","1", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ELSE
					oMainForm:updateUserSetting("CanDeleteOfficeReports","0", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ENDIF
			CATCH
				
			END
			
        RETURN
		ENDIF
RETURN


    PRIVATE METHOD CanSeeAllOfficeReports_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			IF lSuspendNotification
			TRY
				IF SELF:CanSeeAllOfficeReports:Checked
					oMainForm:updateUserSetting("CanSeeAllOfficeReports","1", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ELSE
					oMainForm:updateUserSetting("CanSeeAllOfficeReports","0", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ENDIF
			CATCH
				
			END
			 RETURN
			ENDIF
	    RETURN
		
		
    PRIVATE METHOD CanEditFinalizedOfficeReports_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			IF lSuspendNotification
			TRY
				IF SELF:CanEditFinalizedOfficeReports:Checked
					oMainForm:updateUserSetting("CanEditFinalizedOfficeReports","1", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ELSE
					oMainForm:updateUserSetting("CanEditFinalizedOfficeReports","0", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ENDIF
			CATCH
				
			END
			RETURN
			ENDIF
	   
	    RETURN
    PRIVATE METHOD CHBisGM_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		
		IF lSuspendNotification
			TRY
				IF SELF:CHBisGM:Checked
					oMainForm:updateUserSetting("isGeneralManager","1", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ELSE
					oMainForm:updateUserSetting("isGeneralManager","0", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ENDIF
			CATCH
				
			END
			RETURN
		ENDIF
		
        RETURN

    PRIVATE METHOD CBHeadUser_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		IF lSuspendNotification
			TRY
				IF SELF:CBHeadUser:Checked
					oMainForm:updateUserSetting("IsHeadUser","1", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ELSE
					oMainForm:updateUserSetting("IsHeadUser","0", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ENDIF
			CATCH
				
			END
			RETURN
		ENDIF
        RETURN
		
    PRIVATE METHOD ListViewGroups_DragDrop( sender AS System.Object, e AS System.Windows.Forms.DragEventArgs ) AS System.Void
		oSoftway:ListView_DragDrop(SELF:ListViewGroups, e)
		SELF:SaveGroups()
        RETURN

    PRIVATE METHOD ListViewGroups_DragEnter( sender AS System.Object, e AS System.Windows.Forms.DragEventArgs ) AS System.Void
		e:Effect := DragDropEffects.All
        RETURN

    PRIVATE METHOD ListViewGroups_ItemDrag( sender AS System.Object, e AS System.Windows.Forms.ItemDragEventArgs ) AS System.Void
		SELF:ListViewGroups:DoDragDrop(e:Item, DragDropEffects.Move)
        RETURN

    PRIVATE METHOD ListViewGroups_MouseDoubleClick( sender AS System.Object, e AS System.Windows.Forms.MouseEventArgs ) AS System.Void
		oSoftway:ListView_MouseDoubleClick(SELF:ListViewGroups, SELF:ListViewNonGroups)
		SELF:SaveGroups()
        RETURN

    PRIVATE METHOD ListViewNonGroups_DragEnter( sender AS System.Object, e AS System.Windows.Forms.DragEventArgs ) AS System.Void
		e:Effect := DragDropEffects.All
        RETURN

    PRIVATE METHOD ListViewNonGroups_DragDrop( sender AS System.Object, e AS System.Windows.Forms.DragEventArgs ) AS System.Void
		oSoftway:ListView_DragDrop(SELF:ListViewNonGroups, e)
		SELF:SaveGroups()
        RETURN

    PRIVATE METHOD ListViewNonGroups_ItemDrag( sender AS System.Object, e AS System.Windows.Forms.ItemDragEventArgs ) AS System.Void
		SELF:ListViewNonGroups:DoDragDrop(e:Item, DragDropEffects.Move)
        RETURN

    PRIVATE METHOD ListViewNonGroups_MouseDoubleClick( sender AS System.Object, e AS System.Windows.Forms.MouseEventArgs ) AS System.Void
		oSoftway:ListView_MouseDoubleClick(SELF:ListViewNonGroups, SELF:ListViewGroups)
		SELF:SaveGroups()
        RETURN

    PRIVATE METHOD UsersSetupForm_Shown( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		IF SELF:lRefresh
			LOCAL cStatement AS STRING
			cStatement:="SELECT Users.UserName, FMUsers.USER_UNIQUEID"+;
						" FROM FMUsers"+;
						" Inner Join Users On Users.User_UniqueId = FMUsers.User_UniqueId "+;
						" ORDER BY UserName"
			LOCAL oDTFMUsers := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			SELF:formUsersList(oDTFMUsers)
			SELF:LBCUsers_SelectedIndexChanged(SELF:LBCUsers,NULL)
		ENDIF
        RETURN

    PRIVATE METHOD UsersSetupForm_FormClosing( sender AS System.Object, e AS System.Windows.Forms.FormClosingEventArgs ) AS System.Void
		LOCAL aSplits := DevExpress.XtraEditors.SplitContainerControl[]{3} AS DevExpress.XtraEditors.SplitContainerControl[]
		aSplits[1] := SELF:SplitContainerControl1
		aSplits[2] := SELF:SplitContainerControl2
		aSplits[3] := SELF:SplitContainerControlSetupUsersH
		oSoftway:SaveFormSettings_DevExpress(SELF, oMainForm:alForms, oMainForm:alData, aSplits)
        RETURN

    PRIVATE METHOD ckbUsercanEditReportResults_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		IF lSuspendNotification
			TRY
				IF SELF:ckbUsercanEditReportResults:Checked
					oMainForm:updateUserSetting("CanEditReportResults","1", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ELSE
					oMainForm:updateUserSetting("CanEditReportResults","0", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ENDIF
			CATCH
				
			END
			RETURN
		ENDIF    
	RETURN
    PRIVATE METHOD CBEditReportChangeLog_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		IF lSuspendNotification
			TRY
				IF SELF:CBEditReportChangeLog:Checked
					oMainForm:updateUserSetting("CanEditReportChangeLog","1", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ELSE
					oMainForm:updateUserSetting("CanEditReportChangeLog","0", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ENDIF
			CATCH
				
			END
			RETURN
		ENDIF
    RETURN
    PRIVATE METHOD cbInformUserForGMApproval_CheckedChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:cbInformUserForGMApprovalCheckedChanged()
        RETURN
    PRIVATE METHOD bttnEmailToSendOnGMApprovals_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:bttnEmailToSendOnGMApprovalsClick()
        RETURN

END CLASS
