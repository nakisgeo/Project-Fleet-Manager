#Using System.Windows.Forms
#Using System.Data
#Using System.Drawing
#Using DevExpress.XtraBars
#Using DevExpress.XtraGrid.Views.Grid
#Using DevExpress.XtraGrid.Views.Grid.ViewInfo
PARTIAL CLASS ReportsForm INHERIT DevExpress.XtraEditors.XtraForm
    PRIVATE GridReports AS DevExpress.XtraGrid.GridControl
    PRIVATE GridViewReports AS DevExpress.XtraGrid.Views.Grid.GridView
    PRIVATE barManager AS DevExpress.XtraBars.BarManager
    PRIVATE BarSetup AS DevExpress.XtraBars.Bar
    PRIVATE BBIAdd AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIEdit AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIDelete AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIRefresh AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIPrint AS DevExpress.XtraBars.BarButtonItem
    PRIVATE BBIClose AS DevExpress.XtraBars.BarButtonItem
    PRIVATE barDockControlTop AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlBottom AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlLeft AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlRight AS DevExpress.XtraBars.BarDockControl
    PRIVATE BBIItems AS DevExpress.XtraBars.BarButtonItem
    EXPORT CheckedLBCVessels AS DevExpress.XtraEditors.CheckedListBoxControl
    PRIVATE splitContainerControl_Reports AS DevExpress.XtraEditors.SplitContainerControl
    PRIVATE BBIDuplicate AS DevExpress.XtraBars.BarButtonItem
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
        LOCAL resources := System.ComponentModel.ComponentResourceManager{typeof(ReportsForm)} AS System.ComponentModel.ComponentResourceManager
        LOCAL superToolTip1 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem1 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem1 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip2 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem2 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem2 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip3 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem3 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem3 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip4 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem4 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL superToolTip5 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem5 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem4 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip6 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem6 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem5 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        LOCAL superToolTip7 := DevExpress.Utils.SuperToolTip{} AS DevExpress.Utils.SuperToolTip
        LOCAL toolTipTitleItem7 := DevExpress.Utils.ToolTipTitleItem{} AS DevExpress.Utils.ToolTipTitleItem
        LOCAL toolTipItem6 := DevExpress.Utils.ToolTipItem{} AS DevExpress.Utils.ToolTipItem
        SELF:GridReports := DevExpress.XtraGrid.GridControl{}
        SELF:GridViewReports := DevExpress.XtraGrid.Views.Grid.GridView{}
        SELF:barManager := DevExpress.XtraBars.BarManager{SELF:components}
        SELF:BarSetup := DevExpress.XtraBars.Bar{}
        SELF:BBIAdd := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIEdit := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIDuplicate := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIDelete := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIRefresh := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIPrint := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIItems := DevExpress.XtraBars.BarButtonItem{}
        SELF:BBIClose := DevExpress.XtraBars.BarButtonItem{}
        SELF:barDockControlTop := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlBottom := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlLeft := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlRight := DevExpress.XtraBars.BarDockControl{}
        SELF:splitContainerControl_Reports := DevExpress.XtraEditors.SplitContainerControl{}
        SELF:CheckedLBCVessels := DevExpress.XtraEditors.CheckedListBoxControl{}
        ((System.ComponentModel.ISupportInitialize)(SELF:GridReports)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:GridViewReports)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:barManager)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl_Reports)):BeginInit()
        SELF:splitContainerControl_Reports:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:CheckedLBCVessels)):BeginInit()
        SELF:SuspendLayout()
        // 
        // GridReports
        // 
        SELF:GridReports:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:GridReports:Location := System.Drawing.Point{0, 0}
        SELF:GridReports:MainView := SELF:GridViewReports
        SELF:GridReports:Name := "GridReports"
        SELF:GridReports:Size := System.Drawing.Size{540, 536}
        SELF:GridReports:TabIndex := 75
        SELF:GridReports:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:GridViewReports })
        // 
        // GridViewReports
        // 
        SELF:GridViewReports:GridControl := SELF:GridReports
        SELF:GridViewReports:Name := "GridViewReports"
        SELF:GridViewReports:FocusedRowChanged += DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventHandler{ SELF, @GridViewReports_FocusedRowChanged() }
        SELF:GridViewReports:FocusedColumnChanged += DevExpress.XtraGrid.Views.Base.FocusedColumnChangedEventHandler{ SELF, @GridViewReports_FocusedColumnChanged() }
        SELF:GridViewReports:CellValueChanged += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @GridViewReports_CellValueChanged() }
        SELF:GridViewReports:CellValueChanging += DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler{ SELF, @GridViewReports_CellValueChanging() }
        SELF:GridViewReports:BeforeLeaveRow += DevExpress.XtraGrid.Views.Base.RowAllowEventHandler{ SELF, @GridViewReports_BeforeLeaveRow() }
        SELF:GridViewReports:CustomUnboundColumnData += DevExpress.XtraGrid.Views.Base.CustomColumnDataEventHandler{ SELF, @GridViewReports_CustomUnboundColumnData() }
        SELF:GridViewReports:DoubleClick += System.EventHandler{ SELF, @GridViewReports_DoubleClick() }
        // 
        // barManager
        // 
        SELF:barManager:Bars:AddRange(<DevExpress.XtraBars.Bar>{ SELF:BarSetup })
        SELF:barManager:DockControls:Add(SELF:barDockControlTop)
        SELF:barManager:DockControls:Add(SELF:barDockControlBottom)
        SELF:barManager:DockControls:Add(SELF:barDockControlLeft)
        SELF:barManager:DockControls:Add(SELF:barDockControlRight)
        SELF:barManager:Form := SELF
        SELF:barManager:Items:AddRange(<DevExpress.XtraBars.BarItem>{ SELF:BBIAdd, SELF:BBIClose, SELF:BBIDelete, SELF:BBIRefresh, SELF:BBIPrint, SELF:BBIEdit, SELF:BBIItems, SELF:BBIDuplicate })
        SELF:barManager:MainMenu := SELF:BarSetup
        SELF:barManager:MaxItemId := 17
        // 
        // BarSetup
        // 
        SELF:BarSetup:BarName := "BarSetup"
        SELF:BarSetup:DockCol := 0
        SELF:BarSetup:DockRow := 0
        SELF:BarSetup:DockStyle := DevExpress.XtraBars.BarDockStyle.Top
        SELF:BarSetup:FloatLocation := System.Drawing.Point{369, 210}
        SELF:BarSetup:FloatSize := System.Drawing.Size{46, 24}
        SELF:BarSetup:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:BBIAdd}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIEdit}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIDuplicate}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIDelete}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIRefresh}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIPrint}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIItems}, DevExpress.XtraBars.LinkPersistInfo{SELF:BBIClose} })
        SELF:BarSetup:OptionsBar:MultiLine := TRUE
        SELF:BarSetup:OptionsBar:UseWholeRow := TRUE
        SELF:BarSetup:Text := "Main menu"
        // 
        // BBIAdd
        // 
        SELF:BBIAdd:Caption := "Add"
        SELF:BBIAdd:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIAdd.Glyph")))
        SELF:BBIAdd:Id := 0
        SELF:BBIAdd:ItemShortcut := DevExpress.XtraBars.BarShortcut{(System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.N)}
        SELF:BBIAdd:LargeGlyph := ((System.Drawing.Image)(resources:GetObject("BBIAdd.LargeGlyph")))
        SELF:BBIAdd:Name := "BBIAdd"
        toolTipTitleItem1:Text := "Add (Ctrl-N)"
        toolTipItem1:LeftIndent := 6
        toolTipItem1:Text := "Add new Report"
        superToolTip1:Items:Add(toolTipTitleItem1)
        superToolTip1:Items:Add(toolTipItem1)
        SELF:BBIAdd:SuperTip := superToolTip1
        SELF:BBIAdd:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIAdd_ItemClick() }
        // 
        // BBIEdit
        // 
        SELF:BBIEdit:Caption := "Edit"
        SELF:BBIEdit:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIEdit.Glyph")))
        SELF:BBIEdit:Id := 5
        SELF:BBIEdit:ItemShortcut := DevExpress.XtraBars.BarShortcut{System.Windows.Forms.Keys.F2}
        SELF:BBIEdit:LargeGlyph := ((System.Drawing.Image)(resources:GetObject("BBIEdit.LargeGlyph")))
        SELF:BBIEdit:Name := "BBIEdit"
        toolTipTitleItem2:Text := "Edit (F2)"
        toolTipItem2:LeftIndent := 6
        toolTipItem2:Text := "Edit Report"
        superToolTip2:Items:Add(toolTipTitleItem2)
        superToolTip2:Items:Add(toolTipItem2)
        SELF:BBIEdit:SuperTip := superToolTip2
        SELF:BBIEdit:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIEdit_ItemClick() }
        // 
        // BBIDuplicate
        // 
        SELF:BBIDuplicate:Caption := "Duplicate Report"
        SELF:BBIDuplicate:Id := 16
        SELF:BBIDuplicate:Name := "BBIDuplicate"
        SELF:BBIDuplicate:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIDuplicate_ItemClick() }
        // 
        // BBIDelete
        // 
        SELF:BBIDelete:Caption := "Delete"
        SELF:BBIDelete:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIDelete.Glyph")))
        SELF:BBIDelete:Id := 2
        SELF:BBIDelete:LargeGlyph := ((System.Drawing.Image)(resources:GetObject("BBIDelete.LargeGlyph")))
        SELF:BBIDelete:Name := "BBIDelete"
        toolTipTitleItem3:Text := "Delete"
        toolTipItem3:LeftIndent := 6
        toolTipItem3:Text := "Delete Report"
        superToolTip3:Items:Add(toolTipTitleItem3)
        superToolTip3:Items:Add(toolTipItem3)
        SELF:BBIDelete:SuperTip := superToolTip3
        SELF:BBIDelete:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIDelete_ItemClick() }
        // 
        // BBIRefresh
        // 
        SELF:BBIRefresh:Caption := "Refresh"
        SELF:BBIRefresh:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIRefresh.Glyph")))
        SELF:BBIRefresh:Id := 3
        SELF:BBIRefresh:Name := "BBIRefresh"
        toolTipTitleItem4:Text := "Refresh"
        superToolTip4:Items:Add(toolTipTitleItem4)
        SELF:BBIRefresh:SuperTip := superToolTip4
        SELF:BBIRefresh:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIRefresh_ItemClick() }
        // 
        // BBIPrint
        // 
        SELF:BBIPrint:Caption := "Print"
        SELF:BBIPrint:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIPrint.Glyph")))
        SELF:BBIPrint:Id := 4
        SELF:BBIPrint:ItemShortcut := DevExpress.XtraBars.BarShortcut{(System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.P)}
        SELF:BBIPrint:LargeGlyph := ((System.Drawing.Image)(resources:GetObject("BBIPrint.LargeGlyph")))
        SELF:BBIPrint:Name := "BBIPrint"
        toolTipTitleItem5:Text := "Print (Ctrl+P)"
        toolTipItem4:LeftIndent := 6
        toolTipItem4:Text := "Print Reports"
        superToolTip5:Items:Add(toolTipTitleItem5)
        superToolTip5:Items:Add(toolTipItem4)
        SELF:BBIPrint:SuperTip := superToolTip5
        SELF:BBIPrint:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIPrint_ItemClick() }
        // 
        // BBIItems
        // 
        SELF:BBIItems:Caption := "Report Items"
        SELF:BBIItems:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIItems.Glyph")))
        SELF:BBIItems:Id := 15
        SELF:BBIItems:Name := "BBIItems"
        toolTipTitleItem6:Text := "Report Items"
        toolTipItem5:LeftIndent := 6
        toolTipItem5:Text := "Manage Report Items"
        superToolTip6:Items:Add(toolTipTitleItem6)
        superToolTip6:Items:Add(toolTipItem5)
        SELF:BBIItems:SuperTip := superToolTip6
        SELF:BBIItems:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIItems_ItemClick() }
        // 
        // BBIClose
        // 
        SELF:BBIClose:Caption := "Close"
        SELF:BBIClose:Glyph := ((System.Drawing.Image)(resources:GetObject("BBIClose.Glyph")))
        SELF:BBIClose:Id := 1
        SELF:BBIClose:ItemShortcut := DevExpress.XtraBars.BarShortcut{(System.Windows.Forms.Keys.Alt | System.Windows.Forms.Keys.F4)}
        SELF:BBIClose:LargeGlyph := ((System.Drawing.Image)(resources:GetObject("BBIClose.LargeGlyph")))
        SELF:BBIClose:Name := "BBIClose"
        toolTipTitleItem7:Text := "Close (Alt+F4)"
        toolTipItem6:LeftIndent := 6
        toolTipItem6:Text := "Close window"
        superToolTip7:Items:Add(toolTipTitleItem7)
        superToolTip7:Items:Add(toolTipItem6)
        SELF:BBIClose:SuperTip := superToolTip7
        SELF:BBIClose:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @BBIClose_ItemClick() }
        // 
        // barDockControlTop
        // 
        SELF:barDockControlTop:CausesValidation := FALSE
        SELF:barDockControlTop:Dock := System.Windows.Forms.DockStyle.Top
        SELF:barDockControlTop:Location := System.Drawing.Point{0, 0}
        SELF:barDockControlTop:Size := System.Drawing.Size{784, 26}
        // 
        // barDockControlBottom
        // 
        SELF:barDockControlBottom:CausesValidation := FALSE
        SELF:barDockControlBottom:Dock := System.Windows.Forms.DockStyle.Bottom
        SELF:barDockControlBottom:Location := System.Drawing.Point{0, 562}
        SELF:barDockControlBottom:Size := System.Drawing.Size{784, 0}
        // 
        // barDockControlLeft
        // 
        SELF:barDockControlLeft:CausesValidation := FALSE
        SELF:barDockControlLeft:Dock := System.Windows.Forms.DockStyle.Left
        SELF:barDockControlLeft:Location := System.Drawing.Point{0, 26}
        SELF:barDockControlLeft:Size := System.Drawing.Size{0, 536}
        // 
        // barDockControlRight
        // 
        SELF:barDockControlRight:CausesValidation := FALSE
        SELF:barDockControlRight:Dock := System.Windows.Forms.DockStyle.Right
        SELF:barDockControlRight:Location := System.Drawing.Point{784, 26}
        SELF:barDockControlRight:Size := System.Drawing.Size{0, 536}
        // 
        // splitContainerControl_Reports
        // 
        SELF:splitContainerControl_Reports:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:splitContainerControl_Reports:Location := System.Drawing.Point{0, 26}
        SELF:splitContainerControl_Reports:Name := "splitContainerControl_Reports"
        SELF:splitContainerControl_Reports:Panel1:Controls:Add(SELF:GridReports)
        SELF:splitContainerControl_Reports:Panel1:Text := "Panel1"
        SELF:splitContainerControl_Reports:Panel2:Controls:Add(SELF:CheckedLBCVessels)
        SELF:splitContainerControl_Reports:Panel2:Text := "Panel2"
        SELF:splitContainerControl_Reports:Size := System.Drawing.Size{784, 536}
        SELF:splitContainerControl_Reports:SplitterPosition := 540
        SELF:splitContainerControl_Reports:TabIndex := 80
        SELF:splitContainerControl_Reports:Text := "splitContainerControl1"
        // 
        // CheckedLBCVessels
        // 
        SELF:CheckedLBCVessels:Appearance:Font := System.Drawing.Font{"Lucida Console", ((Single) 8.25), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(161))}
        SELF:CheckedLBCVessels:Appearance:Options:UseFont := TRUE
        SELF:CheckedLBCVessels:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:CheckedLBCVessels:Location := System.Drawing.Point{0, 0}
        SELF:CheckedLBCVessels:Name := "CheckedLBCVessels"
        SELF:CheckedLBCVessels:Size := System.Drawing.Size{238, 536}
        SELF:CheckedLBCVessels:TabIndex := 1
        SELF:CheckedLBCVessels:ItemCheck += DevExpress.XtraEditors.Controls.ItemCheckEventHandler{ SELF, @CheckedLBCVessels_ItemCheck() }
        // 
        // ReportsForm
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:AutoScroll := TRUE
        SELF:ClientSize := System.Drawing.Size{784, 562}
        SELF:Controls:Add(SELF:splitContainerControl_Reports)
        SELF:Controls:Add(SELF:barDockControlLeft)
        SELF:Controls:Add(SELF:barDockControlRight)
        SELF:Controls:Add(SELF:barDockControlBottom)
        SELF:Controls:Add(SELF:barDockControlTop)
        SELF:MaximizeBox := FALSE
        SELF:Name := "ReportsForm"
        SELF:Text := "Reports Form"
        SELF:FormClosing += System.Windows.Forms.FormClosingEventHandler{ SELF, @ReportsForm_FormClosing() }
        SELF:FormClosed += System.Windows.Forms.FormClosedEventHandler{ SELF, @ReportsForm_FormClosed() }
        SELF:Load += System.EventHandler{ SELF, @ReportsForm_Load() }
        ((System.ComponentModel.ISupportInitialize)(SELF:GridReports)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:GridViewReports)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:barManager)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:splitContainerControl_Reports)):EndInit()
        SELF:splitContainerControl_Reports:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:CheckedLBCVessels)):EndInit()
        SELF:ResumeLayout(FALSE)
    PRIVATE METHOD ReportsForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		SELF:ReportsForm_OnLoad()
        RETURN

    PRIVATE METHOD ReportsForm_FormClosing( sender AS System.Object, e AS System.Windows.Forms.FormClosingEventArgs ) AS System.Void
		//IF oMainForm:CheckedLBCVessels:SelectedValue == NULL
		//	wb("Please select a Report before closing the window")
		//	e:Cancel := TRUE
		//	RETURN
		//ENDIF			
		oSoftway:SaveFormSettings_DevExpress(SELF, SELF:splitContainerControl_Reports, oMainForm:alForms, oMainForm:alData)
        RETURN

    PRIVATE METHOD ReportsForm_FormClosed( sender AS System.Object, e AS System.Windows.Forms.FormClosedEventArgs ) AS System.Void
		IF oMainForm:TreeListVessels:FocusedNode <> NULL .and. ! oMainForm:TreeListVessels:FocusedNode:Tag:ToString():StartsWith("Fleet")
			LOCAL cUID := oMainForm:GetVesselUID AS STRING
			oMainForm:Fill_LBCReports(cUID)
			oMainForm:BingMapUserControl:ShowSelectedVesselsOnMap()
		ENDIF
        RETURN

    PRIVATE METHOD BBIAdd_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:Reports_Add()
        RETURN

    PRIVATE METHOD BBIEdit_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		// Get GridRow data into a DataRowView object
		LOCAL oRow AS DataRowView

		oRow := (DataRowView)Self:GridViewReports:GetFocusedRow()
		Self:Reports_Edit(oRow, Self:GridViewReports:FocusedColumn)
        RETURN

    PRIVATE METHOD BBIDelete_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:Reports_Delete()
        RETURN

    PRIVATE METHOD BBIRefresh_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:Reports_Refresh()
        RETURN

    PRIVATE METHOD BBIItems_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:ManageReportItems()
        RETURN

    PRIVATE METHOD BBIPrint_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:Reports_Print()
        RETURN

    PRIVATE METHOD BBIClose_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
		SELF:Close()
        RETURN

    PRIVATE METHOD GridViewReports_BeforeLeaveRow( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS System.Void
		SELF:BeforeLeaveRow_Reports(e)
        RETURN

    PRIVATE METHOD GridViewReports_CellValueChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
		Self:SetEditModeOff_Common(SELF:GridViewReports)
		Self:Reports_Save(e)
        RETURN

    PRIVATE METHOD GridViewReports_CellValueChanging( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
		// Handles the uReport column CellValueChanging to catch the ComboBox selected item
		DO CASE
		CASE e:Column:FieldName == "uReportColor"
			SELF:oChangedReportColor := (System.Drawing.Color)e:Value
		CASE e:Column:FieldName == "uReportType"
			SELF:cItemTypeValue := e:Value:ToString()
		ENDCASE
        RETURN

    PRIVATE METHOD GridViewReports_CustomUnboundColumnData( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs ) AS System.Void
		SELF:CustomUnboundColumnData_Reports(e)
        RETURN

    PRIVATE METHOD GridViewReports_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		LOCAL oPoint := SELF:GridViewReports:GridControl:PointToClient(Control.MousePosition) AS Point
		Local info := Self:GridViewReports:CalcHitInfo(oPoint) as DevExpress.XtraGrid.Views.Grid.ViewInfo.GridHitInfo
		if info:InRow .or. info:InRowCell
			if Self:GridViewReports:IsGroupRow(info:RowHandle)
				Return
			endif

			// Get GridRow data into a DataRowView object
			Local oRow as DataRowView
			oRow:=(DataRowView)Self:GridViewReports:GetRow(info:RowHandle)

			if info:Column <> NULL
				// Set focused Row/Column (for DoubleClick event)
				//SELF:GridViewReports:FocusedRowHandle := info:RowHandle
				//SELF:GridViewReports:FocusedColumn := info:Column

				SELF:Reports_Edit(oRow, info:Column)
			endif
		endif
        RETURN

    PRIVATE METHOD GridViewReports_FocusedColumnChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.FocusedColumnChangedEventArgs ) AS System.Void
		SELF:SetEditModeOff_Common(SELF:GridViewReports)
        RETURN

    PRIVATE METHOD GridViewReports_FocusedRowChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.FocusedRowChangedEventArgs ) AS System.Void
		LOCAL oRow AS DataRowView
		oRow := (DataRowView)SELF:GridViewReports:GetFocusedRow()
		IF oRow <> NULL
			SELF:Fill_CheckedLBCVessels(oRow["REPORT_UID"]:ToString())
		ENDIF
        RETURN

    PRIVATE METHOD CheckedLBCVessels_ItemCheck( sender AS System.Object, e AS DevExpress.XtraEditors.Controls.ItemCheckEventArgs ) AS System.Void
		SELF:SelectedVesselCheckedChanged(e)
        RETURN
    PRIVATE METHOD BBIDuplicate_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
			SELF:DuplicateReport()
        RETURN

END CLASS
