PARTIAL CLASS ReportTabForm INHERIT System.Windows.Forms.Form
    EXPORT tabControl_Report AS System.Windows.Forms.TabControl
    EXPORT tabPage_General AS System.Windows.Forms.TabPage
    EXPORT buttonEnterKey AS System.Windows.Forms.Button
    EXPORT saveToolStripMenuItem AS System.Windows.Forms.ToolStripMenuItem
    EXPORT ReportMainMenu AS System.Windows.Forms.MenuStrip
    EXPORT submitToolStripMenuItem AS System.Windows.Forms.ToolStripMenuItem
    PRIVATE loadFromExcelToolStripMenuItem AS System.Windows.Forms.ToolStripMenuItem
    PRIVATE cancelToolStripMenuItem AS System.Windows.Forms.ToolStripMenuItem
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
        SELF:tabControl_Report := System.Windows.Forms.TabControl{}
        SELF:tabPage_General := System.Windows.Forms.TabPage{}
        SELF:buttonEnterKey := System.Windows.Forms.Button{}
        SELF:ReportMainMenu := System.Windows.Forms.MenuStrip{}
        SELF:saveToolStripMenuItem := System.Windows.Forms.ToolStripMenuItem{}
        SELF:submitToolStripMenuItem := System.Windows.Forms.ToolStripMenuItem{}
        SELF:loadFromExcelToolStripMenuItem := System.Windows.Forms.ToolStripMenuItem{}
        SELF:cancelToolStripMenuItem := System.Windows.Forms.ToolStripMenuItem{}
        SELF:tabControl_Report:SuspendLayout()
        SELF:tabPage_General:SuspendLayout()
        SELF:ReportMainMenu:SuspendLayout()
        SELF:SuspendLayout()
        // 
        // tabControl_Report
        // 
        SELF:tabControl_Report:Controls:Add(SELF:tabPage_General)
        SELF:tabControl_Report:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:tabControl_Report:Location := System.Drawing.Point{0, 24}
        SELF:tabControl_Report:Name := "tabControl_Report"
        SELF:tabControl_Report:SelectedIndex := 0
        SELF:tabControl_Report:Size := System.Drawing.Size{934, 688}
        SELF:tabControl_Report:TabIndex := 0
        // 
        // tabPage_General
        // 
        SELF:tabPage_General:AutoScroll := TRUE
        SELF:tabPage_General:Controls:Add(SELF:buttonEnterKey)
        SELF:tabPage_General:Location := System.Drawing.Point{4, 22}
        SELF:tabPage_General:Name := "tabPage_General"
        SELF:tabPage_General:Padding := System.Windows.Forms.Padding{3}
        SELF:tabPage_General:Size := System.Drawing.Size{926, 662}
        SELF:tabPage_General:TabIndex := 0
        SELF:tabPage_General:Text := "General"
        SELF:tabPage_General:UseVisualStyleBackColor := TRUE
        SELF:tabPage_General:Click += System.EventHandler{ SELF, @tabPage_General_Click() }
        // 
        // buttonEnterKey
        // 
        SELF:buttonEnterKey:Location := System.Drawing.Point{651, 15}
        SELF:buttonEnterKey:Name := "buttonEnterKey"
        SELF:buttonEnterKey:Size := System.Drawing.Size{106, 65}
        SELF:buttonEnterKey:TabIndex := 0
        SELF:buttonEnterKey:Text := "avoid 'Ding' when <Enter> is pressed into controls"
        SELF:buttonEnterKey:UseVisualStyleBackColor := TRUE
        SELF:buttonEnterKey:Visible := FALSE
        // 
        // ReportMainMenu
        // 
        SELF:ReportMainMenu:Items:AddRange(<System.Windows.Forms.ToolStripItem>{ SELF:saveToolStripMenuItem, SELF:submitToolStripMenuItem, SELF:loadFromExcelToolStripMenuItem, SELF:cancelToolStripMenuItem })
        SELF:ReportMainMenu:Location := System.Drawing.Point{0, 0}
        SELF:ReportMainMenu:Name := "ReportMainMenu"
        SELF:ReportMainMenu:Size := System.Drawing.Size{934, 24}
        SELF:ReportMainMenu:TabIndex := 1
        SELF:ReportMainMenu:Text := "menuStrip1"
        SELF:ReportMainMenu:Visible := FALSE
        // 
        // saveToolStripMenuItem
        // 
        SELF:saveToolStripMenuItem:Name := "saveToolStripMenuItem"
        SELF:saveToolStripMenuItem:Size := System.Drawing.Size{98, 20}
        SELF:saveToolStripMenuItem:Text := "Save and Close"
        SELF:saveToolStripMenuItem:Click += System.EventHandler{ SELF, @saveToolStripMenuItem_Click() }
        // 
        // submitToolStripMenuItem
        // 
        SELF:submitToolStripMenuItem:Name := "submitToolStripMenuItem"
        SELF:submitToolStripMenuItem:Size := System.Drawing.Size{57, 20}
        SELF:submitToolStripMenuItem:Text := "Submit"
        SELF:submitToolStripMenuItem:Click += System.EventHandler{ SELF, @submitToolStripMenuItem_Click() }
        // 
        // loadFromExcelToolStripMenuItem
        // 
        SELF:loadFromExcelToolStripMenuItem:Name := "loadFromExcelToolStripMenuItem"
        SELF:loadFromExcelToolStripMenuItem:Size := System.Drawing.Size{105, 20}
        SELF:loadFromExcelToolStripMenuItem:Text := "Load From Excel"
        SELF:loadFromExcelToolStripMenuItem:Click += System.EventHandler{ SELF, @loadFromExcelToolStripMenuItem_Click() }
        // 
        // cancelToolStripMenuItem
        // 
        SELF:cancelToolStripMenuItem:Name := "cancelToolStripMenuItem"
        SELF:cancelToolStripMenuItem:Size := System.Drawing.Size{55, 20}
        SELF:cancelToolStripMenuItem:Text := "Cancel"
        SELF:cancelToolStripMenuItem:Click += System.EventHandler{ SELF, @cancelToolStripMenuItem_Click_1() }
        // 
        // ReportTabForm
        // 
        SELF:AcceptButton := SELF:buttonEnterKey
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:AutoScroll := TRUE
        SELF:AutoSize := TRUE
        SELF:ClientSize := System.Drawing.Size{934, 712}
        SELF:Controls:Add(SELF:tabControl_Report)
        SELF:Controls:Add(SELF:ReportMainMenu)
        SELF:MainMenuStrip := SELF:ReportMainMenu
        SELF:Name := "ReportTabForm"
        SELF:Text := "Report Tab Form"
        SELF:FormClosing += System.Windows.Forms.FormClosingEventHandler{ SELF, @ReportTabForm_FormClosing() }
        SELF:Load += System.EventHandler{ SELF, @ReportTabForm_Load() }
        SELF:Shown += System.EventHandler{ SELF, @ReportTabForm_Shown() }
        SELF:tabControl_Report:ResumeLayout(FALSE)
        SELF:tabPage_General:ResumeLayout(FALSE)
        SELF:ReportMainMenu:ResumeLayout(FALSE)
        SELF:ReportMainMenu:PerformLayout()
        SELF:ResumeLayout(FALSE)
        SELF:PerformLayout()
    PRIVATE METHOD ReportTabForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:ReportTabForm_OnLoad()
        RETURN

    PRIVATE METHOD ReportTabForm_FormClosing( sender AS System.Object, e AS System.Windows.Forms.FormClosingEventArgs ) AS System.Void
		  oSoftway:SaveFormSettings_DevExpress(SELF, NULL, oMainForm:alForms, oMainForm:alData)
        RETURN

    PRIVATE METHOD ReportTabForm_Shown( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:ReportTabForm_OnShown()
        RETURN

    PRIVATE METHOD saveToolStripMenuItem_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:CreateNewReportSave()
		RETURN
    PRIVATE METHOD cancelToolStripMenuItem_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        
		RETURN
    PRIVATE METHOD submitToolStripMenuItem_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			IF SELF:checkMandatoryFields()
				SELF:createNewReportSave("1")
			ENDIF
        RETURN
    PRIVATE METHOD tabPage_General_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			tabPage_General:Focus()
        RETURN
		
    PRIVATE METHOD loadFromExcelToolStripMenuItem_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:loadFromExcelForNewReport()	
        RETURN
    PRIVATE METHOD cancelToolStripMenuItem_Click_1( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:deleteNewlyCreatedReport()
        RETURN

END CLASS
