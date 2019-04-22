PARTIAL CLASS ComboboxColors INHERIT System.Windows.Forms.Form
    PRIVATE GridReports AS DevExpress.XtraGrid.GridControl
    PRIVATE GridViewReports AS DevExpress.XtraGrid.Views.Grid.GridView
    PRIVATE barManager1 AS DevExpress.XtraBars.BarManager
    PRIVATE bar3 AS DevExpress.XtraBars.Bar
    PRIVATE barDockControlTop AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlBottom AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlLeft AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlRight AS DevExpress.XtraBars.BarDockControl
    PRIVATE bar1 AS DevExpress.XtraBars.Bar
    PRIVATE bbiAdd AS DevExpress.XtraBars.BarButtonItem
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
        SELF:components := System.ComponentModel.Container{}
        SELF:GridReports := DevExpress.XtraGrid.GridControl{}
        SELF:GridViewReports := DevExpress.XtraGrid.Views.Grid.GridView{}
        SELF:barManager1 := DevExpress.XtraBars.BarManager{SELF:components}
        SELF:bar1 := DevExpress.XtraBars.Bar{}
        SELF:bbiAdd := DevExpress.XtraBars.BarButtonItem{}
        SELF:bar3 := DevExpress.XtraBars.Bar{}
        SELF:barDockControlTop := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlBottom := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlLeft := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlRight := DevExpress.XtraBars.BarDockControl{}
        ((System.ComponentModel.ISupportInitialize)(SELF:GridReports)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:GridViewReports)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:barManager1)):BeginInit()
        SELF:SuspendLayout()
        // 
        // GridReports
        // 
        SELF:GridReports:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:GridReports:Location := System.Drawing.Point{0, 22}
        SELF:GridReports:MainView := SELF:GridViewReports
        SELF:GridReports:Name := "GridReports"
        SELF:GridReports:Size := System.Drawing.Size{804, 463}
        SELF:GridReports:TabIndex := 76
        SELF:GridReports:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:GridViewReports })
        // 
        // GridViewReports
        // 
        SELF:GridViewReports:GridControl := SELF:GridReports
        SELF:GridViewReports:Name := "GridViewReports"
        SELF:GridViewReports:OptionsView:EnableAppearanceEvenRow := TRUE
        SELF:GridViewReports:OptionsView:ShowGroupPanel := FALSE
        SELF:GridViewReports:CellValueChanged += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @GridViewReports_CellValueChanged() }
        SELF:GridViewReports:CellValueChanging += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @GridViewReports_CellValueChanging() }
        SELF:GridViewReports:CustomUnboundColumnData += DevExpress.XtraGrid.Views.Base.CustomColumnDataEventHandler{ SELF, @GridViewReports_CustomUnboundColumnData() }
        // 
        // barManager1
        // 
        SELF:barManager1:Bars:AddRange(<DevExpress.XtraBars.Bar>{ SELF:bar1, SELF:bar3 })
        SELF:barManager1:DockControls:Add(SELF:barDockControlTop)
        SELF:barManager1:DockControls:Add(SELF:barDockControlBottom)
        SELF:barManager1:DockControls:Add(SELF:barDockControlLeft)
        SELF:barManager1:DockControls:Add(SELF:barDockControlRight)
        SELF:barManager1:Form := SELF
        SELF:barManager1:Items:AddRange(<DevExpress.XtraBars.BarItem>{ SELF:bbiAdd })
        SELF:barManager1:MainMenu := SELF:bar1
        SELF:barManager1:MaxItemId := 1
        SELF:barManager1:StatusBar := SELF:bar3
        // 
        // bar1
        // 
        SELF:bar1:BarName := "Main menu"
        SELF:bar1:DockCol := 0
        SELF:bar1:DockRow := 0
        SELF:bar1:DockStyle := DevExpress.XtraBars.BarDockStyle.Top
        SELF:bar1:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:bbiAdd} })
        SELF:bar1:OptionsBar:MultiLine := TRUE
        SELF:bar1:OptionsBar:UseWholeRow := TRUE
        SELF:bar1:Text := "Main menu"
        // 
        // bbiAdd
        // 
        SELF:bbiAdd:Caption := "  Add  "
        SELF:bbiAdd:Id := 0
        SELF:bbiAdd:Name := "bbiAdd"
        SELF:bbiAdd:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @bbiAdd_ItemClick() }
        // 
        // bar3
        // 
        SELF:bar3:BarName := "Status bar"
        SELF:bar3:CanDockStyle := DevExpress.XtraBars.BarCanDockStyle.Bottom
        SELF:bar3:DockCol := 0
        SELF:bar3:DockRow := 0
        SELF:bar3:DockStyle := DevExpress.XtraBars.BarDockStyle.Bottom
        SELF:bar3:OptionsBar:AllowQuickCustomization := FALSE
        SELF:bar3:OptionsBar:DrawDragBorder := FALSE
        SELF:bar3:OptionsBar:UseWholeRow := TRUE
        SELF:bar3:Text := "Status bar"
        // 
        // barDockControlTop
        // 
        SELF:barDockControlTop:CausesValidation := FALSE
        SELF:barDockControlTop:Dock := System.Windows.Forms.DockStyle.Top
        SELF:barDockControlTop:Location := System.Drawing.Point{0, 0}
        SELF:barDockControlTop:Size := System.Drawing.Size{804, 22}
        // 
        // barDockControlBottom
        // 
        SELF:barDockControlBottom:CausesValidation := FALSE
        SELF:barDockControlBottom:Dock := System.Windows.Forms.DockStyle.Bottom
        SELF:barDockControlBottom:Location := System.Drawing.Point{0, 485}
        SELF:barDockControlBottom:Size := System.Drawing.Size{804, 23}
        // 
        // barDockControlLeft
        // 
        SELF:barDockControlLeft:CausesValidation := FALSE
        SELF:barDockControlLeft:Dock := System.Windows.Forms.DockStyle.Left
        SELF:barDockControlLeft:Location := System.Drawing.Point{0, 22}
        SELF:barDockControlLeft:Size := System.Drawing.Size{0, 463}
        // 
        // barDockControlRight
        // 
        SELF:barDockControlRight:CausesValidation := FALSE
        SELF:barDockControlRight:Dock := System.Windows.Forms.DockStyle.Right
        SELF:barDockControlRight:Location := System.Drawing.Point{804, 22}
        SELF:barDockControlRight:Size := System.Drawing.Size{0, 463}
        // 
        // ComboboxColors
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{804, 508}
        SELF:Controls:Add(SELF:GridReports)
        SELF:Controls:Add(SELF:barDockControlLeft)
        SELF:Controls:Add(SELF:barDockControlRight)
        SELF:Controls:Add(SELF:barDockControlBottom)
        SELF:Controls:Add(SELF:barDockControlTop)
        SELF:Name := "ComboboxColors"
        SELF:Text := "ComboboxColors"
        SELF:Shown += System.EventHandler{ SELF, @ComboboxColors_Shown() }
        ((System.ComponentModel.ISupportInitialize)(SELF:GridReports)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:GridViewReports)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:barManager1)):EndInit()
        SELF:ResumeLayout(FALSE)
        SELF:PerformLayout()
    PRIVATE METHOD bbiAdd_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
			SELF:bbiAddItemClick()
        RETURN

    PRIVATE METHOD ComboboxColors_Shown( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			self:ComboboxColorsShown()
        RETURN
    PRIVATE METHOD GridViewReports_CellValueChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
			self:GridViewReportsCellValueChanged(sender,e)
        RETURN
    PRIVATE METHOD GridViewReports_CustomUnboundColumnData( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs ) AS System.Void
			GridViewReportsCustomUnboundColumnData( sender, e)
        RETURN
    PRIVATE METHOD GridViewReports_CellValueChanging( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
       DO CASE
		CASE e:Column:FieldName == "uComboColor"
			SELF:oChangedReportColor := (System.Drawing.Color)e:Value
	   ENDCASE 
	RETURN

END CLASS
