#Using System.IO
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Collections
PARTIAL CLASS Select_Company INHERIT System.Windows.Forms.Form
    PRIVATE gridControl1 AS DevExpress.XtraGrid.GridControl
    PRIVATE gridView1 AS DevExpress.XtraGrid.Views.Grid.GridView
    PRIVATE panel1 AS System.Windows.Forms.Panel
    PRIVATE label1 AS System.Windows.Forms.Label
    PRIVATE label2 AS System.Windows.Forms.Label
    PRIVATE okButton AS System.Windows.Forms.Button
    PRIVATE tfAgent AS System.Windows.Forms.TextBox
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
        SELF:gridControl1 := DevExpress.XtraGrid.GridControl{}
        SELF:gridView1 := DevExpress.XtraGrid.Views.Grid.GridView{}
        SELF:panel1 := System.Windows.Forms.Panel{}
        SELF:label2 := System.Windows.Forms.Label{}
        SELF:tfAgent := System.Windows.Forms.TextBox{}
        SELF:label1 := System.Windows.Forms.Label{}
        SELF:okButton := System.Windows.Forms.Button{}
        ((System.ComponentModel.ISupportInitialize)(SELF:gridControl1)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridView1)):BeginInit()
        SELF:panel1:SuspendLayout()
        SELF:SuspendLayout()
        // 
        // gridControl1
        // 
        SELF:gridControl1:Anchor := ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) ;
                    | System.Windows.Forms.AnchorStyles.Right)))
        SELF:gridControl1:Location := System.Drawing.Point{1, 93}
        SELF:gridControl1:MainView := SELF:gridView1
        SELF:gridControl1:Name := "gridControl1"
        SELF:gridControl1:Size := System.Drawing.Size{916, 540}
        SELF:gridControl1:TabIndex := 0
        SELF:gridControl1:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:gridView1 })
        SELF:gridControl1:KeyDown += System.Windows.Forms.KeyEventHandler{ SELF, @gridControl1_KeyDown() }
        SELF:gridControl1:KeyPress += System.Windows.Forms.KeyPressEventHandler{ SELF, @gridControl1_KeyPress() }
        // 
        // gridView1
        // 
        SELF:gridView1:GridControl := SELF:gridControl1
        SELF:gridView1:Name := "gridView1"
        SELF:gridView1:OptionsBehavior:ReadOnly := TRUE
        SELF:gridView1:OptionsFind:AlwaysVisible := TRUE
        SELF:gridView1:OptionsSelection:MultiSelect := TRUE
        SELF:gridView1:OptionsView:ShowGroupPanel := FALSE
        SELF:gridView1:CustomUnboundColumnData += DevExpress.XtraGrid.Views.Base.CustomColumnDataEventHandler{ SELF, @gridView1_CustomUnboundColumnData() }
        SELF:gridView1:DoubleClick += System.EventHandler{ SELF, @gridView1_DoubleClick() }
        // 
        // panel1
        // 
        SELF:panel1:Controls:Add(SELF:label2)
        SELF:panel1:Controls:Add(SELF:tfAgent)
        SELF:panel1:Controls:Add(SELF:label1)
        SELF:panel1:Dock := System.Windows.Forms.DockStyle.Top
        SELF:panel1:Location := System.Drawing.Point{0, 0}
        SELF:panel1:Name := "panel1"
        SELF:panel1:Size := System.Drawing.Size{917, 87}
        SELF:panel1:TabIndex := 1
        // 
        // label2
        // 
        SELF:label2:Anchor := ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) ;
                    | System.Windows.Forms.AnchorStyles.Right)))
        SELF:label2:AutoSize := TRUE
        SELF:label2:Font := System.Drawing.Font{"Microsoft Sans Serif", ((Single) 9.75), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(161))}
        SELF:label2:Location := System.Drawing.Point{285, 57}
        SELF:label2:Name := "label2"
        SELF:label2:Size := System.Drawing.Size{322, 16}
        SELF:label2:TabIndex := 2
        SELF:label2:Text := "Or Double Click To Choose from your company book"
        // 
        // tfAgent
        // 
        SELF:tfAgent:Anchor := ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) ;
                    | System.Windows.Forms.AnchorStyles.Right)))
        SELF:tfAgent:Location := System.Drawing.Point{92, 22}
        SELF:tfAgent:Name := "tfAgent"
        SELF:tfAgent:Size := System.Drawing.Size{813, 20}
        SELF:tfAgent:TabIndex := 1
        SELF:tfAgent:KeyDown += System.Windows.Forms.KeyEventHandler{ SELF, @tfAgent_KeyDown() }
        SELF:tfAgent:KeyPress += System.Windows.Forms.KeyPressEventHandler{ SELF, @tfAgent_KeyPress() }
        // 
        // label1
        // 
        SELF:label1:AutoSize := TRUE
        SELF:label1:Font := System.Drawing.Font{"Microsoft Sans Serif", ((Single) 9.75), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(161))}
        SELF:label1:Location := System.Drawing.Point{12, 23}
        SELF:label1:Name := "label1"
        SELF:label1:Size := System.Drawing.Size{74, 16}
        SELF:label1:TabIndex := 0
        SELF:label1:Text := "Enter Text :"
        // 
        // okButton
        // 
        SELF:okButton:Anchor := ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) ;
                    | System.Windows.Forms.AnchorStyles.Right)))
        SELF:okButton:Location := System.Drawing.Point{388, 639}
        SELF:okButton:Name := "okButton"
        SELF:okButton:Size := System.Drawing.Size{108, 23}
        SELF:okButton:TabIndex := 3
        SELF:okButton:Text := "OK"
        SELF:okButton:UseVisualStyleBackColor := TRUE
        SELF:okButton:Click += System.EventHandler{ SELF, @okButton_Click() }
        // 
        // Select_Company
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{917, 672}
        SELF:Controls:Add(SELF:okButton)
        SELF:Controls:Add(SELF:panel1)
        SELF:Controls:Add(SELF:gridControl1)
        SELF:Name := "Select_Company"
        SELF:ShowIcon := FALSE
        SELF:Text := "Select Company"
        SELF:Load += System.EventHandler{ SELF, @Select_Company_Load() }
        ((System.ComponentModel.ISupportInitialize)(SELF:gridControl1)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridView1)):EndInit()
        SELF:panel1:ResumeLayout(FALSE)
        SELF:panel1:PerformLayout()
        SELF:ResumeLayout(FALSE)
    PRIVATE METHOD Select_Company_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:Select_CompanyForm_Onload()
        RETURN
    PRIVATE METHOD gridView1_CustomUnboundColumnData( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs ) AS System.Void
			SELF:CustomUnboundColumnData_Companies(e)
	    RETURN
		
    PRIVATE METHOD gridView1_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		LOCAL oPoint := SELF:gridView1:GridControl:PointToClient(Control.MousePosition) AS Point
		LOCAL info := SELF:gridView1:CalcHitInfo(oPoint) AS DevExpress.XtraGrid.Views.Grid.ViewInfo.GridHitInfo
		
		IF info:InRow .OR. info:InRowCell
			/*IF SELF:gridView1:IsGroupRow(info:RowHandle)
				RETURN
			ENDIF*/
			// Get GridRow data into a DataRowView object
			LOCAL oRow AS DataRowView
			oRow:=(DataRowView)SELF:gridView1:GetRow(info:RowHandle)
			IF info:Column <> NULL
				// Set focused Row/Column (for DoubleClick event)
				//SELF:GridViewVoyages:FocusedRowHandle := info:RowHandle
				//SELF:GridViewVoyages:FocusedColumn := info:Column
				SELF:CloseAndSendData(oRow, info:Column)
			ENDIF
		ENDIF
RETURN
    PRIVATE METHOD okButton_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			IF SELF:tfAgent:Text:Length == 0
				IF SELF:gridView1:SelectedRowsCount==0
					MessageBox.Show("Pls write some text or select company.","Warning")
					RETURN
				ELSE
					SELF:CloseAndSendData(SELF:gridView1:GetSelectedRows())					
				ENDIF
			ELSE
				SELF:CloseAndSendData(SELF:tfAgent:Text)	
			ENDIF
        RETURN
		
    PRIVATE METHOD tfAgent_KeyPress( sender AS System.Object, e AS System.Windows.Forms.KeyPressEventArgs ) AS System.Void
			
        RETURN
		
		
    PRIVATE METHOD gridControl1_KeyPress( sender AS System.Object, e AS System.Windows.Forms.KeyPressEventArgs ) AS System.Void
	
    RETURN
    PRIVATE METHOD gridControl1_KeyDown( sender AS System.Object, e AS System.Windows.Forms.KeyEventArgs ) AS System.Void
		IF e:KeyCode == Keys.Enter || e:KeyCode == Keys.Return
			IF SELF:tfAgent:Text:Length == 0
				IF SELF:gridView1:SelectedRowsCount==0
					MessageBox.Show("Pls write some text or select company.","Warning")
					RETURN
				ELSE
					SELF:CloseAndSendData(SELF:gridView1:GetSelectedRows())					
				ENDIF
			ELSE
				SELF:CloseAndSendData(SELF:tfAgent:Text)	
			ENDIF
		ENDIF
     RETURN
	 
    PRIVATE METHOD tfAgent_KeyDown( sender AS System.Object, e AS System.Windows.Forms.KeyEventArgs ) AS System.Void
		IF e:KeyCode == Keys.Enter || e:KeyCode == Keys.Return
			IF SELF:tfAgent:Text:Length == 0
				MessageBox.Show("Pls write some text or select company.","Warning")
				RETURN
			ENDIF
			SELF:CloseAndSendData(SELF:tfAgent:Text)		
		ENDIF
    RETURN

END CLASS
