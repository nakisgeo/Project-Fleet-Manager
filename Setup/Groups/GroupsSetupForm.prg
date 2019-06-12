#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#Using System.IO
#Using System.Diagnostics
PARTIAL CLASS GroupsSetupForm INHERIT DevExpress.XtraEditors.XtraForm
    PRIVATE splitContainerControl1 AS DevExpress.XtraEditors.SplitContainerControl
    PRIVATE panelControl1 AS DevExpress.XtraEditors.PanelControl
    PRIVATE colorDialog1 AS System.Windows.Forms.ColorDialog
    PRIVATE oDTGroups AS System.Data.DataTable
    PRIVATE GroupLabel AS System.Windows.Forms.Label
    PRIVATE lSuspendNotification AS System.Boolean
    EXPORT LBCGroups AS DevExpress.XtraEditors.ListBoxControl
    EXPORT SplitContainerControlSetupGroupsH AS DevExpress.XtraEditors.SplitContainerControl
    EXPORT ListViewUsers AS System.Windows.Forms.ListView
    EXPORT GroupName AS System.Windows.Forms.ColumnHeader
    EXPORT TextEditGroups AS DevExpress.XtraEditors.TextEdit
    EXPORT ListViewNonUsers AS System.Windows.Forms.ListView
    EXPORT NonGroupName AS System.Windows.Forms.ColumnHeader
    EXPORT TextEditNonGroups AS DevExpress.XtraEditors.TextEdit
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
        SELF:LBCGroups := DevExpress.XtraEditors.ListBoxControl{}
        SELF:panelControl1 := DevExpress.XtraEditors.PanelControl{}
        SELF:SplitContainerControlSetupGroupsH := DevExpress.XtraEditors.SplitContainerControl{}
        SELF:ListViewUsers := System.Windows.Forms.ListView{}
        SELF:GroupName := System.Windows.Forms.ColumnHeader{}
        SELF:TextEditGroups := DevExpress.XtraEditors.TextEdit{}
        SELF:ListViewNonUsers := System.Windows.Forms.ListView{}
        SELF:NonGroupName := System.Windows.Forms.ColumnHeader{}
        SELF:TextEditNonGroups := DevExpress.XtraEditors.TextEdit{}
        SELF:GroupLabel := System.Windows.Forms.Label{}
        SELF:colorDialog1 := System.Windows.Forms.ColorDialog{}
        ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl1)):BeginInit()
        SELF:splitContainerControl1:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:LBCGroups)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:panelControl1)):BeginInit()
        SELF:panelControl1:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:SplitContainerControlSetupGroupsH)):BeginInit()
        SELF:SplitContainerControlSetupGroupsH:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:TextEditGroups:Properties)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:TextEditNonGroups:Properties)):BeginInit()
        SELF:SuspendLayout()
        // 
        // splitContainerControl1
        // 
        SELF:splitContainerControl1:BorderStyle := DevExpress.XtraEditors.Controls.BorderStyles.Simple
        SELF:splitContainerControl1:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:splitContainerControl1:Location := System.Drawing.Point{0, 0}
        SELF:splitContainerControl1:Name := "splitContainerControl1"
        SELF:splitContainerControl1:Panel1:Controls:Add(SELF:LBCGroups)
        SELF:splitContainerControl1:Panel1:Text := "Panel1"
        SELF:splitContainerControl1:Panel2:Controls:Add(SELF:panelControl1)
        SELF:splitContainerControl1:Panel2:Text := "Panel2"
        SELF:splitContainerControl1:Size := System.Drawing.Size{797, 559}
        SELF:splitContainerControl1:SplitterPosition := 188
        SELF:splitContainerControl1:TabIndex := 0
        SELF:splitContainerControl1:Text := "splitContainerControl1"
        // 
        // LBCGroups
        // 
        SELF:LBCGroups:Appearance:Font := System.Drawing.Font{"Lucida Console", ((Single) 8.25)}
        SELF:LBCGroups:Appearance:ForeColor := System.Drawing.Color.Black
        SELF:LBCGroups:Appearance:Options:UseFont := TRUE
        SELF:LBCGroups:Appearance:Options:UseForeColor := TRUE
        SELF:LBCGroups:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:LBCGroups:HorizontalScrollbar := TRUE
        SELF:LBCGroups:Location := System.Drawing.Point{0, 0}
        SELF:LBCGroups:Name := "LBCGroups"
        SELF:LBCGroups:Size := System.Drawing.Size{188, 559}
        SELF:LBCGroups:TabIndex := 2
        SELF:LBCGroups:SelectedIndexChanged += System.EventHandler{ SELF, @LBCGroups_SelectedIndexChanged() }
        // 
        // panelControl1
        // 
        SELF:panelControl1:Controls:Add(SELF:SplitContainerControlSetupGroupsH)
        SELF:panelControl1:Controls:Add(SELF:GroupLabel)
        SELF:panelControl1:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:panelControl1:Location := System.Drawing.Point{0, 0}
        SELF:panelControl1:Name := "panelControl1"
        SELF:panelControl1:Size := System.Drawing.Size{604, 559}
        SELF:panelControl1:TabIndex := 0
        // 
        // SplitContainerControlSetupGroupsH
        // 
        SELF:SplitContainerControlSetupGroupsH:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:SplitContainerControlSetupGroupsH:Location := System.Drawing.Point{2, 25}
        SELF:SplitContainerControlSetupGroupsH:Name := "SplitContainerControlSetupGroupsH"
        SELF:SplitContainerControlSetupGroupsH:Panel1:Controls:Add(SELF:ListViewUsers)
        SELF:SplitContainerControlSetupGroupsH:Panel1:Controls:Add(SELF:TextEditGroups)
        SELF:SplitContainerControlSetupGroupsH:Panel1:Text := "Panel1"
        SELF:SplitContainerControlSetupGroupsH:Panel2:Controls:Add(SELF:ListViewNonUsers)
        SELF:SplitContainerControlSetupGroupsH:Panel2:Controls:Add(SELF:TextEditNonGroups)
        SELF:SplitContainerControlSetupGroupsH:Panel2:Text := "Panel2"
        SELF:SplitContainerControlSetupGroupsH:Size := System.Drawing.Size{600, 532}
        SELF:SplitContainerControlSetupGroupsH:SplitterPosition := 297
        SELF:SplitContainerControlSetupGroupsH:TabIndex := 3
        SELF:SplitContainerControlSetupGroupsH:Text := "splitContainerControl1"
        // 
        // ListViewUsers
        // 
        SELF:ListViewUsers:AllowDrop := TRUE
        SELF:ListViewUsers:Columns:AddRange(<System.Windows.Forms.ColumnHeader>{ SELF:GroupName })
        SELF:ListViewUsers:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:ListViewUsers:FullRowSelect := TRUE
        SELF:ListViewUsers:HideSelection := FALSE
        SELF:ListViewUsers:Location := System.Drawing.Point{0, 20}
        SELF:ListViewUsers:Name := "ListViewUsers"
        SELF:ListViewUsers:Size := System.Drawing.Size{297, 512}
        SELF:ListViewUsers:TabIndex := 0
        SELF:ListViewUsers:UseCompatibleStateImageBehavior := FALSE
        SELF:ListViewUsers:View := System.Windows.Forms.View.Details
        // 
        // GroupName
        // 
        SELF:GroupName:Text := "Group Name"
        SELF:GroupName:Width := 350
        // 
        // TextEditGroups
        // 
        SELF:TextEditGroups:Dock := System.Windows.Forms.DockStyle.Top
        SELF:TextEditGroups:EditValue := "Member of Group:"
        SELF:TextEditGroups:Location := System.Drawing.Point{0, 0}
        SELF:TextEditGroups:Name := "TextEditGroups"
        SELF:TextEditGroups:Properties:Appearance:Font := System.Drawing.Font{"Tahoma", ((Single) 8), System.Drawing.FontStyle.Bold}
        SELF:TextEditGroups:Properties:Appearance:ForeColor := System.Drawing.Color.Green
        SELF:TextEditGroups:Properties:Appearance:Options:UseFont := TRUE
        SELF:TextEditGroups:Properties:Appearance:Options:UseForeColor := TRUE
        SELF:TextEditGroups:Size := System.Drawing.Size{297, 20}
        SELF:TextEditGroups:TabIndex := 1
        // 
        // ListViewNonUsers
        // 
        SELF:ListViewNonUsers:AllowDrop := TRUE
        SELF:ListViewNonUsers:Columns:AddRange(<System.Windows.Forms.ColumnHeader>{ SELF:NonGroupName })
        SELF:ListViewNonUsers:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:ListViewNonUsers:FullRowSelect := TRUE
        SELF:ListViewNonUsers:HideSelection := FALSE
        SELF:ListViewNonUsers:Location := System.Drawing.Point{0, 20}
        SELF:ListViewNonUsers:Name := "ListViewNonUsers"
        SELF:ListViewNonUsers:Size := System.Drawing.Size{298, 512}
        SELF:ListViewNonUsers:TabIndex := 3
        SELF:ListViewNonUsers:UseCompatibleStateImageBehavior := FALSE
        SELF:ListViewNonUsers:View := System.Windows.Forms.View.Details
        // 
        // NonGroupName
        // 
        SELF:NonGroupName:Text := "Group Name"
        SELF:NonGroupName:Width := 350
        // 
        // TextEditNonGroups
        // 
        SELF:TextEditNonGroups:Dock := System.Windows.Forms.DockStyle.Top
        SELF:TextEditNonGroups:EditValue := "Non-Member of Group:"
        SELF:TextEditNonGroups:Location := System.Drawing.Point{0, 0}
        SELF:TextEditNonGroups:Name := "TextEditNonGroups"
        SELF:TextEditNonGroups:Properties:Appearance:Font := System.Drawing.Font{"Tahoma", ((Single) 8), System.Drawing.FontStyle.Bold}
        SELF:TextEditNonGroups:Properties:Appearance:ForeColor := System.Drawing.Color.Red
        SELF:TextEditNonGroups:Properties:Appearance:Options:UseFont := TRUE
        SELF:TextEditNonGroups:Properties:Appearance:Options:UseForeColor := TRUE
        SELF:TextEditNonGroups:Size := System.Drawing.Size{298, 20}
        SELF:TextEditNonGroups:TabIndex := 2
        // 
        // GroupLabel
        // 
        SELF:GroupLabel:BackColor := System.Drawing.Color.White
        SELF:GroupLabel:BorderStyle := System.Windows.Forms.BorderStyle.Fixed3D
        SELF:GroupLabel:Dock := System.Windows.Forms.DockStyle.Top
        SELF:GroupLabel:Font := System.Drawing.Font{"Microsoft Sans Serif", ((Single) 8.25), System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(161))}
        SELF:GroupLabel:Location := System.Drawing.Point{2, 2}
        SELF:GroupLabel:Name := "GroupLabel"
        SELF:GroupLabel:Size := System.Drawing.Size{600, 23}
        SELF:GroupLabel:TabIndex := 2
        SELF:GroupLabel:Text := "No Group Selected"
        SELF:GroupLabel:TextAlign := System.Drawing.ContentAlignment.MiddleCenter
        // 
        // GroupsSetupForm
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{797, 559}
        SELF:Controls:Add(SELF:splitContainerControl1)
        SELF:Name := "GroupsSetupForm"
        SELF:StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen
        SELF:Text := "Groups Setup Form"
        SELF:FormClosing += System.Windows.Forms.FormClosingEventHandler{ SELF, @GroupsSetupForm_FormClosing() }
        SELF:Load += System.EventHandler{ SELF, @GroupsSetupForm_Load() }
        SELF:Shown += System.EventHandler{ SELF, @GroupsSetupForm_Shown() }
        ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl1)):EndInit()
        SELF:splitContainerControl1:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:LBCGroups)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:panelControl1)):EndInit()
        SELF:panelControl1:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:SplitContainerControlSetupGroupsH)):EndInit()
        SELF:SplitContainerControlSetupGroupsH:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:TextEditGroups:Properties)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:TextEditNonGroups:Properties)):EndInit()
        SELF:ResumeLayout(FALSE)
    PRIVATE METHOD GroupsSetupForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:GroupsSetupForm_OnLoad()
        RETURN

    EXPORT METHOD formGroupsList(inData AS system.data.datatable) AS LOGIC
		lSuspendNotification := FALSE
		SELF:oDTGroups := inData
		SELF:LBCGroups:DataSource := SELF:oDTGroups
		SELF:LBCGroups:DisplayMember := "GroupName"
		SELF:LBCGroups:ValueMember := "GROUP_UID"
		lSuspendNotification := TRUE
		//LOCAL cReportName := oMainForm:LBCReports:GetDisplayItemValue(oMainForm:LBCReports:SelectedIndex):ToString() AS STRING
	RETURN TRUE
	
    PRIVATE METHOD LBCGroups_SelectedIndexChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	TRY
		IF SELF:LBCGroups:SelectedValue <> NULL .AND.  SELF:lSuspendNotification
			LOCAL cGroupName := SELF:LBCGroups:GetDisplayItemValue(SELF:LBCGroups:SelectedIndex):ToString() AS STRING
			LOCAL cGroupUID := SELF:LBCGroups:SelectedValue:ToString() AS STRING
			SELF:GroupLabel:Text := cGroupName + " / " + cGroupUID
			
			//Below lines fill the Groups and Non-Groups ListViews
			SELF:FillListView_Users(cGroupUID)
			SELF:FillListView_NonUsers(cGroupUID)
			////////////////////////////////////////////////////////////////
			//ADDED BY KIRIAKOS AT 31/05/16
			////////////////////////////////////////////////////////////////

		ENDIF
	CATCH exc AS Exception
		WB(exc:StackTrace)
	END	
    RETURN
		
    PRIVATE METHOD ListViewUsers_DragDrop( sender AS System.Object, e AS System.Windows.Forms.DragEventArgs ) AS System.Void
		oSoftway:ListView_DragDrop(SELF:ListViewUsers, e)
		SELF:SaveUsers()
        RETURN

    PRIVATE METHOD ListViewUsers_DragEnter( sender AS System.Object, e AS System.Windows.Forms.DragEventArgs ) AS System.Void
		e:Effect := DragDropEffects.All
        RETURN

    PRIVATE METHOD ListViewUsers_ItemDrag( sender AS System.Object, e AS System.Windows.Forms.ItemDragEventArgs ) AS System.Void
		SELF:ListViewUsers:DoDragDrop(e:Item, DragDropEffects.Move)
        RETURN

    PRIVATE METHOD ListViewUsers_MouseDoubleClick( sender AS System.Object, e AS System.Windows.Forms.MouseEventArgs ) AS System.Void
		oSoftway:ListView_MouseDoubleClick(SELF:ListViewUsers, SELF:ListViewNonUsers)
		SELF:SaveUsers()
        RETURN

    PRIVATE METHOD ListViewNonUsers_DragEnter( sender AS System.Object, e AS System.Windows.Forms.DragEventArgs ) AS System.Void
		e:Effect := DragDropEffects.All
        RETURN

    PRIVATE METHOD ListViewNonUsers_DragDrop( sender AS System.Object, e AS System.Windows.Forms.DragEventArgs ) AS System.Void
		oSoftway:ListView_DragDrop(SELF:ListViewNonUsers, e)
		SELF:SaveUsers()
        RETURN

    PRIVATE METHOD ListViewNonUsers_ItemDrag( sender AS System.Object, e AS System.Windows.Forms.ItemDragEventArgs ) AS System.Void
		SELF:ListViewNonUsers:DoDragDrop(e:Item, DragDropEffects.Move)
        RETURN

    PRIVATE METHOD ListViewNonUsers_MouseDoubleClick( sender AS System.Object, e AS System.Windows.Forms.MouseEventArgs ) AS System.Void
		oSoftway:ListView_MouseDoubleClick(SELF:ListViewNonUsers, SELF:ListViewUsers)
		SELF:SaveUsers()
        RETURN

    PRIVATE METHOD GroupsSetupForm_Shown( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		IF SELF:lRefresh
			LOCAL cStatement AS STRING
			cStatement:="SELECT GroupName, GROUP_UID"+;
						" FROM FMUserGroups"+;
						" ORDER BY GroupName"
			LOCAL oDTFMUserGroups := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			SELF:formGroupsList(oDTFMUserGroups)
		ENDIF
        RETURN

    PRIVATE METHOD GroupsSetupForm_FormClosing( sender AS System.Object, e AS System.Windows.Forms.FormClosingEventArgs ) AS System.Void
		LOCAL aSplits := DevExpress.XtraEditors.SplitContainerControl[]{2} AS DevExpress.XtraEditors.SplitContainerControl[]
		aSplits[1] := SELF:SplitContainerControl1
		aSplits[2] := SELF:SplitContainerControlSetupGroupsH
		oSoftway:SaveFormSettings_DevExpress(SELF, oMainForm:alForms, oMainForm:alData, aSplits)
        RETURN

END CLASS
