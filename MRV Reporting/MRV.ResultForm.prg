PARTIAL CLASS MRVResultForm INHERIT System.Windows.Forms.Form
    PRIVATE gridView1 AS DevExpress.XtraGrid.Views.BandedGrid.BandedGridView
    PRIVATE gridControl1 AS DevExpress.XtraGrid.GridControl
    PRIVATE comboBoxYear AS System.Windows.Forms.ComboBox
    PRIVATE buttonCreateReport AS System.Windows.Forms.Button
    PRIVATE labelVesselName AS System.Windows.Forms.Label
    PRIVATE buttonPrintGrid AS System.Windows.Forms.Button
    PRIVATE gridBandGeneral AS DevExpress.XtraGrid.Views.BandedGrid.GridBand
    PRIVATE gridBandCargo AS DevExpress.XtraGrid.Views.BandedGrid.GridBand
    PRIVATE gridBandHFP AS DevExpress.XtraGrid.Views.BandedGrid.GridBand
    PRIVATE gridBandMDOMGO AS DevExpress.XtraGrid.Views.BandedGrid.GridBand
    PRIVATE gridBandCO2 AS DevExpress.XtraGrid.Views.BandedGrid.GridBand
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
        SELF:gridView1 := DevExpress.XtraGrid.Views.BandedGrid.BandedGridView{}
        SELF:gridControl1 := DevExpress.XtraGrid.GridControl{}
        SELF:comboBoxYear := System.Windows.Forms.ComboBox{}
        SELF:buttonCreateReport := System.Windows.Forms.Button{}
        SELF:labelVesselName := System.Windows.Forms.Label{}
        SELF:buttonPrintGrid := System.Windows.Forms.Button{}
        SELF:gridBandGeneral := DevExpress.XtraGrid.Views.BandedGrid.GridBand{}
        SELF:gridBandCargo := DevExpress.XtraGrid.Views.BandedGrid.GridBand{}
        SELF:gridBandHFP := DevExpress.XtraGrid.Views.BandedGrid.GridBand{}
        SELF:gridBandMDOMGO := DevExpress.XtraGrid.Views.BandedGrid.GridBand{}
        SELF:gridBandCO2 := DevExpress.XtraGrid.Views.BandedGrid.GridBand{}
        ((System.ComponentModel.ISupportInitialize)(SELF:gridView1)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridControl1)):BeginInit()
        SELF:SuspendLayout()
        // 
        // gridView1
        // 
        SELF:gridView1:Bands:AddRange(<DevExpress.XtraGrid.Views.BandedGrid.GridBand>{ SELF:gridBandGeneral, SELF:gridBandCargo, SELF:gridBandHFP, SELF:gridBandMDOMGO, SELF:gridBandCO2 })
        SELF:gridView1:GridControl := SELF:gridControl1
        SELF:gridView1:Name := "gridView1"
        SELF:gridView1:OptionsFind:AlwaysVisible := TRUE
        SELF:gridView1:OptionsView:ShowFooter := TRUE
        SELF:gridView1:OptionsView:ShowGroupPanel := FALSE
        SELF:gridView1:CellValueChanged += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @gridView1_CellValueChanged() }
        // 
        // gridControl1
        // 
        SELF:gridControl1:Anchor := ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) ;
                    | System.Windows.Forms.AnchorStyles.Left) ;
                    | System.Windows.Forms.AnchorStyles.Right)))
        SELF:gridControl1:Location := System.Drawing.Point{0, 67}
        SELF:gridControl1:MainView := SELF:gridView1
        SELF:gridControl1:Name := "gridControl1"
        SELF:gridControl1:Size := System.Drawing.Size{1271, 390}
        SELF:gridControl1:TabIndex := 2
        SELF:gridControl1:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:gridView1 })
        // 
        // comboBoxYear
        // 
        SELF:comboBoxYear:DropDownStyle := System.Windows.Forms.ComboBoxStyle.DropDownList
        SELF:comboBoxYear:FlatStyle := System.Windows.Forms.FlatStyle.System
        SELF:comboBoxYear:FormattingEnabled := TRUE
        SELF:comboBoxYear:Items:AddRange(<System.Object>{ "2018", "2019", "2020", "2021", "2022", "2023", "2024", "2025", "2026", "2027", "2028", "2029", "2030" })
        SELF:comboBoxYear:Location := System.Drawing.Point{173, 21}
        SELF:comboBoxYear:Name := "comboBoxYear"
        SELF:comboBoxYear:Size := System.Drawing.Size{88, 21}
        SELF:comboBoxYear:TabIndex := 5
        // 
        // buttonCreateReport
        // 
        SELF:buttonCreateReport:Location := System.Drawing.Point{12, 19}
        SELF:buttonCreateReport:Name := "buttonCreateReport"
        SELF:buttonCreateReport:Size := System.Drawing.Size{136, 23}
        SELF:buttonCreateReport:TabIndex := 6
        SELF:buttonCreateReport:Text := "Create Report for"
        SELF:buttonCreateReport:UseVisualStyleBackColor := TRUE
        SELF:buttonCreateReport:Click += System.EventHandler{ SELF, @buttonCreateReport_Click() }
        // 
        // labelVesselName
        // 
        SELF:labelVesselName:AutoSize := TRUE
        SELF:labelVesselName:Location := System.Drawing.Point{380, 24}
        SELF:labelVesselName:Name := "labelVesselName"
        SELF:labelVesselName:Size := System.Drawing.Size{35, 13}
        SELF:labelVesselName:TabIndex := 7
        SELF:labelVesselName:Text := "label1"
        // 
        // buttonPrintGrid
        // 
        SELF:buttonPrintGrid:Location := System.Drawing.Point{517, 19}
        SELF:buttonPrintGrid:Name := "buttonPrintGrid"
        SELF:buttonPrintGrid:Size := System.Drawing.Size{136, 23}
        SELF:buttonPrintGrid:TabIndex := 8
        SELF:buttonPrintGrid:Text := "Export Results"
        SELF:buttonPrintGrid:UseVisualStyleBackColor := TRUE
        SELF:buttonPrintGrid:Click += System.EventHandler{ SELF, @buttonPrintGrid_Click() }
        // 
        // gridBandGeneral
        // 
        SELF:gridBandGeneral:AppearanceHeader:Options:UseTextOptions := TRUE
        SELF:gridBandGeneral:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
        SELF:gridBandGeneral:Caption := "General"
        SELF:gridBandGeneral:Name := "gridBandGeneral"
        SELF:gridBandGeneral:VisibleIndex := 0
        // 
        // gridBandCargo
        // 
        SELF:gridBandCargo:AppearanceHeader:Options:UseTextOptions := TRUE
        SELF:gridBandCargo:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
        SELF:gridBandCargo:Caption := "Cargo"
        SELF:gridBandCargo:Name := "gridBandCargo"
        SELF:gridBandCargo:VisibleIndex := 1
        // 
        // gridBandHFP
        // 
        SELF:gridBandHFP:AppearanceHeader:BackColor := System.Drawing.Color.FromArgb(((System.Int32)(((System.Byte)(255)))), ((System.Int32)(((System.Byte)(224)))), ((System.Int32)(((System.Byte)(192)))))
        SELF:gridBandHFP:AppearanceHeader:BackColor2 := System.Drawing.Color.FromArgb(((System.Int32)(((System.Byte)(255)))), ((System.Int32)(((System.Byte)(224)))), ((System.Int32)(((System.Byte)(192)))))
        SELF:gridBandHFP:AppearanceHeader:Options:UseBackColor := TRUE
        SELF:gridBandHFP:AppearanceHeader:Options:UseTextOptions := TRUE
        SELF:gridBandHFP:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
        SELF:gridBandHFP:Caption := "HFO"
        SELF:gridBandHFP:Name := "gridBandHFP"
        SELF:gridBandHFP:OptionsBand:AllowMove := FALSE
        SELF:gridBandHFP:VisibleIndex := 2
        // 
        // gridBandMDOMGO
        // 
        SELF:gridBandMDOMGO:AppearanceHeader:BackColor := System.Drawing.Color.FromArgb(((System.Int32)(((System.Byte)(255)))), ((System.Int32)(((System.Byte)(255)))), ((System.Int32)(((System.Byte)(192)))))
        SELF:gridBandMDOMGO:AppearanceHeader:BackColor2 := System.Drawing.Color.FromArgb(((System.Int32)(((System.Byte)(255)))), ((System.Int32)(((System.Byte)(255)))), ((System.Int32)(((System.Byte)(192)))))
        SELF:gridBandMDOMGO:AppearanceHeader:Options:UseBackColor := TRUE
        SELF:gridBandMDOMGO:AppearanceHeader:Options:UseTextOptions := TRUE
        SELF:gridBandMDOMGO:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
        SELF:gridBandMDOMGO:Caption := "MDO/MGO"
        SELF:gridBandMDOMGO:Name := "gridBandMDOMGO"
        SELF:gridBandMDOMGO:VisibleIndex := 3
        // 
        // gridBandCO2
        // 
        SELF:gridBandCO2:AppearanceHeader:BackColor := System.Drawing.Color.FromArgb(((System.Int32)(((System.Byte)(192)))), ((System.Int32)(((System.Byte)(255)))), ((System.Int32)(((System.Byte)(255)))))
        SELF:gridBandCO2:AppearanceHeader:BackColor2 := System.Drawing.Color.FromArgb(((System.Int32)(((System.Byte)(192)))), ((System.Int32)(((System.Byte)(255)))), ((System.Int32)(((System.Byte)(255)))))
        SELF:gridBandCO2:AppearanceHeader:Options:UseBackColor := TRUE
        SELF:gridBandCO2:AppearanceHeader:Options:UseTextOptions := TRUE
        SELF:gridBandCO2:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
        SELF:gridBandCO2:Caption := "CO2"
        SELF:gridBandCO2:Name := "gridBandCO2"
        SELF:gridBandCO2:VisibleIndex := 4
        // 
        // MRVResultForm
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{1271, 457}
        SELF:Controls:Add(SELF:buttonPrintGrid)
        SELF:Controls:Add(SELF:labelVesselName)
        SELF:Controls:Add(SELF:buttonCreateReport)
        SELF:Controls:Add(SELF:comboBoxYear)
        SELF:Controls:Add(SELF:gridControl1)
        SELF:Name := "MRVResultForm"
        SELF:Text := "MRV Reporting"
        SELF:Load += System.EventHandler{ SELF, @MRVResultFrom_Load() }
        ((System.ComponentModel.ISupportInitialize)(SELF:gridView1)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridControl1)):EndInit()
        SELF:ResumeLayout(FALSE)
        SELF:PerformLayout()
    PRIVATE METHOD MRVResultFrom_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			SELF:MRVResultFromLoad()
        RETURN
    
    PRIVATE METHOD buttonCreateReport_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		
			IF comboBoxYear:Text:Trim()==""
				System.Windows.Forms.MessageBox.Show( "Please Choose Reporting Year." )
				RETURN
			ENDIF

			SELF:runTheMRVReport()
    RETURN
    PRIVATE METHOD buttonPrintGrid_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			buttonPrintGridClick()
        RETURN

    PRIVATE METHOD gridView1_CellValueChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
		gridView1CellValueChanged(sender,e)    
	RETURN

END CLASS
