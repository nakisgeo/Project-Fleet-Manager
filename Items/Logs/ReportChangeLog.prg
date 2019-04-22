#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#using System.Drawing.Printing
#Using System.IO
#Using System.Collections
#USING System.Threading
#USING System.Collections.Generic
#using System.ComponentModel

#Using DevExpress.XtraEditors
#using DevExpress.LookAndFeel
#Using DevExpress.XtraGrid.Views.Grid
#Using DevExpress.XtraGrid.Views.Base
#using DevExpress.XtraPrinting
#Using DevExpress.XtraPrintingLinks
#using DevExpress.XtraGrid.Columns
#using DevExpress.XtraTreeList
#using DevExpress.XtraTreeList.Nodes
#using DevExpress.XtraBars
CLASS ReportChangeLog INHERIT System.Windows.Forms.Form
    PRIVATE gcLog AS DevExpress.XtraGrid.GridControl
    PRIVATE gvLog AS DevExpress.XtraGrid.Views.Grid.GridView
    /// <summary>
    /// Required designer variable.
    /// </summary>
    PRIVATE oDTMyLogs AS DataTable
    EXPORT cMyReportUID AS System.String
    EXPORT lShowOnly AS System.Boolean
    PRIVATE label1 AS System.Windows.Forms.Label
    PRIVATE label2 AS System.Windows.Forms.Label
    PRIVATE txtVersion AS System.Windows.Forms.TextBox
    EXPORT txtNotes AS System.Windows.Forms.TextBox
    PRIVATE buttonCreateLog AS System.Windows.Forms.Button
    PRIVATE toolStrip1 AS System.Windows.Forms.ToolStrip
    PRIVATE BBIEdit AS System.Windows.Forms.ToolStripButton
    PRIVATE BBIDelete AS System.Windows.Forms.ToolStripButton
    PRIVATE BBIAdd AS System.Windows.Forms.ToolStripButton
    PRIVATE panel1 AS System.Windows.Forms.Panel
    PRIVATE panelEdit AS System.Windows.Forms.Panel
    PRIVATE label3 AS System.Windows.Forms.Label
    PRIVATE dtLogDate AS System.Windows.Forms.DateTimePicker
    PRIVATE buttonCancel AS System.Windows.Forms.Button
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
        SELF:gcLog := DevExpress.XtraGrid.GridControl{}
        SELF:gvLog := DevExpress.XtraGrid.Views.Grid.GridView{}
        SELF:label1 := System.Windows.Forms.Label{}
        SELF:label2 := System.Windows.Forms.Label{}
        SELF:txtVersion := System.Windows.Forms.TextBox{}
        SELF:txtNotes := System.Windows.Forms.TextBox{}
        SELF:buttonCreateLog := System.Windows.Forms.Button{}
        SELF:toolStrip1 := System.Windows.Forms.ToolStrip{}
        SELF:BBIEdit := System.Windows.Forms.ToolStripButton{}
        SELF:BBIAdd := System.Windows.Forms.ToolStripButton{}
        SELF:BBIDelete := System.Windows.Forms.ToolStripButton{}
        SELF:panel1 := System.Windows.Forms.Panel{}
        SELF:panelEdit := System.Windows.Forms.Panel{}
        SELF:buttonCancel := System.Windows.Forms.Button{}
        SELF:dtLogDate := System.Windows.Forms.DateTimePicker{}
        SELF:label3 := System.Windows.Forms.Label{}
        ((System.ComponentModel.ISupportInitialize)(SELF:gcLog)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gvLog)):BeginInit()
        SELF:toolStrip1:SuspendLayout()
        SELF:panel1:SuspendLayout()
        SELF:panelEdit:SuspendLayout()
        SELF:SuspendLayout()
        // 
        // gcLog
        // 
        SELF:gcLog:Dock := System.Windows.Forms.DockStyle.Bottom
        SELF:gcLog:Location := System.Drawing.Point{0, 185}
        SELF:gcLog:MainView := SELF:gvLog
        SELF:gcLog:Name := "gcLog"
        SELF:gcLog:Size := System.Drawing.Size{861, 293}
        SELF:gcLog:TabIndex := 0
        SELF:gcLog:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:gvLog })
        // 
        // gvLog
        // 
        SELF:gvLog:GridControl := SELF:gcLog
        SELF:gvLog:Name := "gvLog"
        SELF:gvLog:OptionsBehavior:Editable := FALSE
        SELF:gvLog:OptionsView:ShowGroupPanel := FALSE
        SELF:gvLog:DoubleClick += System.EventHandler{ SELF, @gvLog_DoubleClick() }
        // 
        // label1
        // 
        SELF:label1:Location := System.Drawing.Point{12, 14}
        SELF:label1:Name := "label1"
        SELF:label1:Size := System.Drawing.Size{58, 18}
        SELF:label1:TabIndex := 1
        SELF:label1:Text := "Version :"
        // 
        // label2
        // 
        SELF:label2:Location := System.Drawing.Point{35, 70}
        SELF:label2:Name := "label2"
        SELF:label2:Size := System.Drawing.Size{51, 20}
        SELF:label2:TabIndex := 2
        SELF:label2:Text := "Notes :"
        // 
        // txtVersion
        // 
        SELF:txtVersion:Location := System.Drawing.Point{69, 11}
        SELF:txtVersion:Name := "txtVersion"
        SELF:txtVersion:Size := System.Drawing.Size{165, 20}
        SELF:txtVersion:TabIndex := 3
        // 
        // txtNotes
        // 
        SELF:txtNotes:Location := System.Drawing.Point{92, 70}
        SELF:txtNotes:Multiline := TRUE
        SELF:txtNotes:Name := "txtNotes"
        SELF:txtNotes:ScrollBars := System.Windows.Forms.ScrollBars.Both
        SELF:txtNotes:Size := System.Drawing.Size{757, 103}
        SELF:txtNotes:TabIndex := 4
        // 
        // buttonCreateLog
        // 
        SELF:buttonCreateLog:Location := System.Drawing.Point{688, 11}
        SELF:buttonCreateLog:Name := "buttonCreateLog"
        SELF:buttonCreateLog:Size := System.Drawing.Size{161, 23}
        SELF:buttonCreateLog:TabIndex := 5
        SELF:buttonCreateLog:Text := "Create Log Entry"
        SELF:buttonCreateLog:UseVisualStyleBackColor := TRUE
        SELF:buttonCreateLog:Click += System.EventHandler{ SELF, @button1_Click() }
        // 
        // toolStrip1
        // 
        SELF:toolStrip1:Items:AddRange(<System.Windows.Forms.ToolStripItem>{ SELF:BBIEdit, SELF:BBIAdd, SELF:BBIDelete })
        SELF:toolStrip1:Location := System.Drawing.Point{0, 0}
        SELF:toolStrip1:Name := "toolStrip1"
        SELF:toolStrip1:Size := System.Drawing.Size{861, 25}
        SELF:toolStrip1:TabIndex := 6
        SELF:toolStrip1:Text := "toolStrip1"
        // 
        // BBIEdit
        // 
        SELF:BBIEdit:DisplayStyle := System.Windows.Forms.ToolStripItemDisplayStyle.Text
        SELF:BBIEdit:ImageTransparentColor := System.Drawing.Color.Magenta
        SELF:BBIEdit:Name := "BBIEdit"
        SELF:BBIEdit:Size := System.Drawing.Size{58, 22}
        SELF:BBIEdit:Text := "Edit Item"
        SELF:BBIEdit:Click += System.EventHandler{ SELF, @BBIEdit_Click() }
        // 
        // BBIAdd
        // 
        SELF:BBIAdd:DisplayStyle := System.Windows.Forms.ToolStripItemDisplayStyle.Text
        SELF:BBIAdd:ImageTransparentColor := System.Drawing.Color.Magenta
        SELF:BBIAdd:Name := "BBIAdd"
        SELF:BBIAdd:Size := System.Drawing.Size{60, 22}
        SELF:BBIAdd:Text := "Add Item"
        SELF:BBIAdd:Click += System.EventHandler{ SELF, @BBIAdd_Click() }
        // 
        // BBIDelete
        // 
        SELF:BBIDelete:DisplayStyle := System.Windows.Forms.ToolStripItemDisplayStyle.Text
        SELF:BBIDelete:ImageTransparentColor := System.Drawing.Color.Magenta
        SELF:BBIDelete:Name := "BBIDelete"
        SELF:BBIDelete:Size := System.Drawing.Size{71, 22}
        SELF:BBIDelete:Text := "Delete Item"
        SELF:BBIDelete:Click += System.EventHandler{ SELF, @BBIDelete_Click() }
        // 
        // panel1
        // 
        SELF:panel1:Controls:Add(SELF:panelEdit)
        SELF:panel1:Controls:Add(SELF:gcLog)
        SELF:panel1:Dock := System.Windows.Forms.DockStyle.Bottom
        SELF:panel1:Location := System.Drawing.Point{0, 28}
        SELF:panel1:Name := "panel1"
        SELF:panel1:Size := System.Drawing.Size{861, 478}
        SELF:panel1:TabIndex := 7
        // 
        // panelEdit
        // 
        SELF:panelEdit:Controls:Add(SELF:buttonCancel)
        SELF:panelEdit:Controls:Add(SELF:dtLogDate)
        SELF:panelEdit:Controls:Add(SELF:label3)
        SELF:panelEdit:Controls:Add(SELF:label1)
        SELF:panelEdit:Controls:Add(SELF:txtNotes)
        SELF:panelEdit:Controls:Add(SELF:buttonCreateLog)
        SELF:panelEdit:Controls:Add(SELF:label2)
        SELF:panelEdit:Controls:Add(SELF:txtVersion)
        SELF:panelEdit:Location := System.Drawing.Point{0, 3}
        SELF:panelEdit:Name := "panelEdit"
        SELF:panelEdit:Size := System.Drawing.Size{858, 176}
        SELF:panelEdit:TabIndex := 6
        // 
        // buttonCancel
        // 
        SELF:buttonCancel:Location := System.Drawing.Point{688, 40}
        SELF:buttonCancel:Name := "buttonCancel"
        SELF:buttonCancel:Size := System.Drawing.Size{161, 23}
        SELF:buttonCancel:TabIndex := 8
        SELF:buttonCancel:Text := "Cancel"
        SELF:buttonCancel:UseVisualStyleBackColor := TRUE
        SELF:buttonCancel:Click += System.EventHandler{ SELF, @buttonCancel_Click() }
        // 
        // dtLogDate
        // 
        SELF:dtLogDate:Location := System.Drawing.Point{358, 11}
        SELF:dtLogDate:Name := "dtLogDate"
        SELF:dtLogDate:Size := System.Drawing.Size{138, 20}
        SELF:dtLogDate:TabIndex := 7
        // 
        // label3
        // 
        SELF:label3:Location := System.Drawing.Point{316, 14}
        SELF:label3:Name := "label3"
        SELF:label3:Size := System.Drawing.Size{58, 18}
        SELF:label3:TabIndex := 6
        SELF:label3:Text := "Date :"
        // 
        // ReportChangeLog
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{861, 506}
        SELF:Controls:Add(SELF:panel1)
        SELF:Controls:Add(SELF:toolStrip1)
        SELF:MaximizeBox := FALSE
        SELF:Name := "ReportChangeLog"
        SELF:ShowIcon := FALSE
        SELF:Text := "Report Change Log"
        SELF:Shown += System.EventHandler{ SELF, @ReportChangeLog_Shown() }
        ((System.ComponentModel.ISupportInitialize)(SELF:gcLog)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gvLog)):EndInit()
        SELF:toolStrip1:ResumeLayout(FALSE)
        SELF:toolStrip1:PerformLayout()
        SELF:panel1:ResumeLayout(FALSE)
        SELF:panelEdit:ResumeLayout(FALSE)
        SELF:panelEdit:PerformLayout()
        SELF:ResumeLayout(FALSE)
        SELF:PerformLayout()
    PRIVATE METHOD ReportChangeLog_Shown( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			
			SELF:refreshMyLogs()
			self:panelEdit:Visible := !SELF:lShowOnly
			IF SELF:lShowOnly
				SELF:gcLog:Dock := DockStyle.Fill
				LOCAL oRow  AS system.data.datarow 
				oRow := oMainForm:returnUserSetting(oUser:USER_UNIQUEID:Trim()) 
				IF oRow == NULL
					RETURN
				ENDIF
				IF oRow["CanEditReportChangeLog"]:ToString():Trim() == "True"
					SELF:toolStrip1:Visible := TRUE
				ENDIF
			ELSE
				SELF:toolStrip1:Visible := FALSE
			ENDIF
        RETURN

    PRIVATE METHOD refreshMyLogs() AS VOID
			SELF:gcLog:DataSource := NULL
			local dsLocal :=  DataSet{} as dataset
            
            LOCAL cStatement := " SELECT FMReportChangeLog.*, RTRIM(Users.UserName) as UserName From FMReportChangeLog "+;
								" Inner Join Users on Users.User_UniqueId = FMReportChangeLog.FK_User_UniqueId "+;
								" Where REPORT_UID="+SELF:cMyReportUID+" Order By LogDateTime Desc " AS STRING
			
			SELF:oDTMyLogs := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
			SELF:oDTMyLogs:TableName := "Logs"
			dsLocal:Tables:Add(self:oDTMyLogs)
			SELF:gcLog:DataSource := dsLocal
			SELF:gcLog:DataMember := "Logs"
            SELF:gcLog:ForceInitialize()
	
			self:gvLog:Columns["LOG_UID"]:Visible := false
			self:gvLog:Columns["REPORT_UID"]:Visible := false
			self:gvLog:Columns["FK_User_UniqueId"]:Visible := false

	RETURN

    PRIVATE METHOD button1_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void

		

		LOCAL cVersion:= oSoftway:ConvertWildcards(txtVersion:Text:Trim(),FALSE) AS STRING
		LOCAL cNotes := oSoftway:ConvertWildcards(txtNotes:Text:Trim(),FALSE)	 AS STRING
		LOCAL cDate := dtLogDate:Value:ToString("yyyyMMdd") AS STRING

		IF SELF:gcLog:Enabled //Kano insert

			local cStatement:="INSERT INTO FMReportChangeLog (REPORT_UID, LogDateTime, Version, FK_User_UniqueId, LogNotes) VALUES"+;
					" ("+SELF:cMyReportUID+", '"+cDate+"', '"+cVersion+"', "+oUser:USER_UNIQUEID+",'"+cNotes+"')" AS STRING
			IF oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				txtNotes:Text :=""
				txtVersion:Text:=""
				SELF:dtLogDate:Value := DateTime.Now
				self:refreshMyLogs()
				SELF:hideEditControls()
				RETURN
			ENDIF
		ELSE // Kano Edit
			LOCAL cTag := SELF:buttonCreateLog:Tag:ToString()
			SELF:buttonCreateLog:Tag := ""
			LOCAL cStatement:="Update FMReportChangeLog Set Version='"+cVersion+"', LogNotes='"+cNotes+"', LogDateTime='"+cDate+"' WHERE "+;
					" LOG_UID="+cTag AS STRING
			IF oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				SELF:txtNotes:Text :=""
				SELF:txtVersion:Text:=""
				SELF:dtLogDate:Value := DateTime.Now
				SELF:refreshMyLogs()
				SELF:hideEditControls()
				RETURN
			ENDIF
			SELF:buttonCreateLog:Text := "Create Log Entry"
		ENDIF

        RETURN

    PRIVATE METHOD BBIEdit_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			LOCAL oRow AS DataRowView
			oRow:=(DataRowView)SELF:gvLog:GetRow(gvLog:FocusedRowHandle)
			IF oRow == NULL
				RETURN
			ENDIF

			SELF:showEditControls()
			SELF:buttonCreateLog:Text := "Save Changes"
			SELF:buttonCreateLog:Tag := oRow:Item["LOG_UID"]:ToString()
			
			txtNotes:Text := oRow:Item["LogNotes"]:ToString()	
			txtVersion:Text := oRow:Item["Version"]:ToString()	
			dtLogDate:Value := DateTime.Parse(oRow:Item["LogDateTime"]:ToString())		

			SELF:gcLog:Enabled := FALSE
        RETURN
    
    PRIVATE METHOD BBIAdd_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:showEditControls()
    RETURN
    
    PRIVATE METHOD BBIDelete_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void

			LOCAL oRow AS DataRowView
			oRow:=(DataRowView)SELF:gvLog:GetRow(gvLog:FocusedRowHandle)
			IF oRow == NULL
				RETURN
			ENDIF

			LOCAL cVersion := oRow:Item["Version"]:ToString() AS STRING

			IF QuestionBox("Are you sure you want to DELETE the Selected Item ? Version : "+cVersion, ;
							"Delete Data") <> System.Windows.Forms.DialogResult.Yes
				RETURN
			ENDIF

			LOCAL cLogUID := oRow:Item["LOG_UID"]:ToString() AS STRING
			LOCAL cStatement:="Delete From FMReportChangeLog WHERE "+;
					" LOG_UID="+cLogUID AS STRING
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			SELF:refreshMyLogs()

    RETURN

    PRIVATE Method hideEditControls() AS VOID
		SELF:gcLog:Enabled := FALSE
		SELF:panelEdit:Visible := FALSE
		SELF:toolStrip1:Enabled := TRUE
		SELF:gcLog:Dock := System.Windows.Forms.DockStyle.Fill
		SELF:gcLog:Enabled := TRUE
	RETURN

    PRIVATE METHOD showEditControls() AS VOID
		SELF:gcLog:Dock := System.Windows.Forms.DockStyle.Bottom
		SELF:gcLog:Location := System.Drawing.Point{0, 166}
		SELF:gcLog:Size := System.Drawing.Size{771, 293}
		SELF:buttonCreateLog:Visible := true
		SELF:panelEdit:Visible := TRUE
		SELF:toolStrip1:Enabled := FALSE
	RETURN

    PRIVATE METHOD buttonCancel_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			self:hideEditControls()
        RETURN

    PRIVATE METHOD gvLog_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			LOCAL oPoint := SELF:gvLog:GridControl:PointToClient(Control.MousePosition) AS Point
			LOCAL info := SELF:gvLog:CalcHitInfo(oPoint) AS DevExpress.XtraGrid.Views.Grid.ViewInfo.GridHitInfo
		
		IF info:InRow .OR. info:InRowCell
			LOCAL oRow AS DataRowView
			oRow:=(DataRowView)SELF:gvLog:GetRow(info:RowHandle)
			SELF:showEditControls()
			SELF:buttonCreateLog:Visible := false
			txtNotes:Text := oRow:Item["LogNotes"]:ToString()	
			txtVersion:Text := oRow:Item["Version"]:ToString()	
			dtLogDate:Value := DateTime.Parse(oRow:Item["LogDateTime"]:ToString())		
			SELF:gcLog:Enabled := FALSE
		ENDIF
        RETURN

END CLASS
