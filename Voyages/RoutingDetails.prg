PARTIAL CLASS RoutingDetails INHERIT System.Windows.Forms.UserControl
    PRIVATE dockManager1 AS DevExpress.XtraBars.Docking.DockManager
    PRIVATE dockPanel1 AS DevExpress.XtraBars.Docking.DockPanel
    PRIVATE dockPanel1_Container AS DevExpress.XtraBars.Docking.ControlContainer
    PRIVATE dockPanel4_Container AS DevExpress.XtraBars.Docking.ControlContainer
    PRIVATE dockPanel2 AS DevExpress.XtraBars.Docking.DockPanel
    PRIVATE dockPanel3 AS DevExpress.XtraBars.Docking.DockPanel
    PRIVATE dockPanel3_Container AS DevExpress.XtraBars.Docking.ControlContainer
    EXPORT gridControl1 AS DevExpress.XtraGrid.GridControl
    EXPORT gridView1 AS DevExpress.XtraGrid.Views.Grid.GridView
    PRIVATE barDockControlLeft AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlRight AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlBottom AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlTop AS DevExpress.XtraBars.BarDockControl
    EXPORT barManager1 AS DevExpress.XtraBars.BarManager
    EXPORT bar2 AS DevExpress.XtraBars.Bar
    EXPORT barButtonItem1 AS DevExpress.XtraBars.BarButtonItem
    EXPORT bar3 AS DevExpress.XtraBars.Bar
    EXPORT barButtonItem2 AS DevExpress.XtraBars.BarButtonItem
    EXPORT gridControl2 AS DevExpress.XtraGrid.GridControl
    EXPORT gridView2 AS DevExpress.XtraGrid.Views.Grid.GridView
    EXPORT gridControl3 AS DevExpress.XtraGrid.GridControl
    EXPORT gridView3 AS DevExpress.XtraGrid.Views.Grid.GridView
    PRIVATE panelContainer2 AS DevExpress.XtraBars.Docking.DockPanel
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
        SELF:dockManager1 := DevExpress.XtraBars.Docking.DockManager{SELF:components}
        SELF:panelContainer2 := DevExpress.XtraBars.Docking.DockPanel{}
        SELF:dockPanel3 := DevExpress.XtraBars.Docking.DockPanel{}
        SELF:dockPanel3_Container := DevExpress.XtraBars.Docking.ControlContainer{}
        SELF:gridControl1 := DevExpress.XtraGrid.GridControl{}
        SELF:gridView1 := DevExpress.XtraGrid.Views.Grid.GridView{}
        SELF:dockPanel1 := DevExpress.XtraBars.Docking.DockPanel{}
        SELF:dockPanel1_Container := DevExpress.XtraBars.Docking.ControlContainer{}
        SELF:gridControl2 := DevExpress.XtraGrid.GridControl{}
        SELF:gridView2 := DevExpress.XtraGrid.Views.Grid.GridView{}
        SELF:dockPanel2 := DevExpress.XtraBars.Docking.DockPanel{}
        SELF:dockPanel4_Container := DevExpress.XtraBars.Docking.ControlContainer{}
        SELF:gridControl3 := DevExpress.XtraGrid.GridControl{}
        SELF:gridView3 := DevExpress.XtraGrid.Views.Grid.GridView{}
        SELF:barManager1 := DevExpress.XtraBars.BarManager{SELF:components}
        SELF:bar2 := DevExpress.XtraBars.Bar{}
        SELF:barButtonItem1 := DevExpress.XtraBars.BarButtonItem{}
        SELF:barButtonItem2 := DevExpress.XtraBars.BarButtonItem{}
        SELF:bar3 := DevExpress.XtraBars.Bar{}
        SELF:barDockControlTop := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlBottom := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlLeft := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlRight := DevExpress.XtraBars.BarDockControl{}
        ((System.ComponentModel.ISupportInitialize)(SELF:dockManager1)):BeginInit()
        SELF:panelContainer2:SuspendLayout()
        SELF:dockPanel3:SuspendLayout()
        SELF:dockPanel3_Container:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridControl1)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridView1)):BeginInit()
        SELF:dockPanel1:SuspendLayout()
        SELF:dockPanel1_Container:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridControl2)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridView2)):BeginInit()
        SELF:dockPanel2:SuspendLayout()
        SELF:dockPanel4_Container:SuspendLayout()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridControl3)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridView3)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:barManager1)):BeginInit()
        SELF:SuspendLayout()
        // 
        // dockManager1
        // 
        SELF:dockManager1:Form := SELF
        SELF:dockManager1:RootPanels:AddRange(<DevExpress.XtraBars.Docking.DockPanel>{ SELF:panelContainer2 })
        SELF:dockManager1:TopZIndexControls:AddRange(<System.String>{ "DevExpress.XtraBars.BarDockControl", "DevExpress.XtraBars.StandaloneBarDockControl", "System.Windows.Forms.StatusBar", "DevExpress.XtraBars.Ribbon.RibbonStatusBar", "DevExpress.XtraBars.Ribbon.RibbonControl" })
        // 
        // panelContainer2
        // 
        SELF:panelContainer2:Controls:Add(SELF:dockPanel3)
        SELF:panelContainer2:Controls:Add(SELF:dockPanel1)
        SELF:panelContainer2:Controls:Add(SELF:dockPanel2)
        SELF:panelContainer2:Dock := DevExpress.XtraBars.Docking.DockingStyle.Top
        SELF:panelContainer2:FloatVertical := TRUE
        SELF:panelContainer2:ID := System.Guid{"67318e53-f4bd-4399-9e2a-4e8ca9fd1ea6"}
        SELF:panelContainer2:Location := System.Drawing.Point{0, 22}
        SELF:panelContainer2:Name := "panelContainer2"
        SELF:panelContainer2:OriginalSize := System.Drawing.Size{816, 413}
        SELF:panelContainer2:Size := System.Drawing.Size{840, 370}
        SELF:panelContainer2:Text := "panelContainer2"
        // 
        // dockPanel3
        // 
        SELF:dockPanel3:Controls:Add(SELF:dockPanel3_Container)
        SELF:dockPanel3:Dock := DevExpress.XtraBars.Docking.DockingStyle.Right
        SELF:dockPanel3:ID := System.Guid{"1b3d3d79-2586-48bb-af42-4d82b5f79e78"}
        SELF:dockPanel3:Location := System.Drawing.Point{0, 0}
        SELF:dockPanel3:Name := "dockPanel3"
        SELF:dockPanel3:OriginalSize := System.Drawing.Size{279, 369}
        SELF:dockPanel3:Size := System.Drawing.Size{279, 370}
        SELF:dockPanel3:Text := "Cargoes"
        // 
        // dockPanel3_Container
        // 
        SELF:dockPanel3_Container:Controls:Add(SELF:gridControl1)
        SELF:dockPanel3_Container:Location := System.Drawing.Point{4, 23}
        SELF:dockPanel3_Container:Name := "dockPanel3_Container"
        SELF:dockPanel3_Container:Size := System.Drawing.Size{271, 343}
        SELF:dockPanel3_Container:TabIndex := 0
        // 
        // gridControl1
        // 
        SELF:gridControl1:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:gridControl1:Location := System.Drawing.Point{0, 0}
        SELF:gridControl1:MainView := SELF:gridView1
        SELF:gridControl1:Name := "gridControl1"
        SELF:gridControl1:Size := System.Drawing.Size{271, 343}
        SELF:gridControl1:TabIndex := 1
        SELF:gridControl1:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:gridView1 })
        // 
        // gridView1
        // 
        SELF:gridView1:GridControl := SELF:gridControl1
        SELF:gridView1:Name := "gridView1"
        SELF:gridView1:OptionsBehavior:ReadOnly := TRUE
        SELF:gridView1:OptionsFind:AlwaysVisible := TRUE
        SELF:gridView1:OptionsSelection:MultiSelect := TRUE
        SELF:gridView1:OptionsView:ShowGroupPanel := FALSE
        // 
        // dockPanel1
        // 
        SELF:dockPanel1:Controls:Add(SELF:dockPanel1_Container)
        SELF:dockPanel1:Dock := DevExpress.XtraBars.Docking.DockingStyle.Right
        SELF:dockPanel1:ID := System.Guid{"7450269f-4792-4dc5-8fc4-618778072f53"}
        SELF:dockPanel1:Location := System.Drawing.Point{279, 0}
        SELF:dockPanel1:Name := "dockPanel1"
        SELF:dockPanel1:OriginalSize := System.Drawing.Size{279, 369}
        SELF:dockPanel1:Size := System.Drawing.Size{279, 370}
        SELF:dockPanel1:Text := "Expenses"
        // 
        // dockPanel1_Container
        // 
        SELF:dockPanel1_Container:Controls:Add(SELF:gridControl2)
        SELF:dockPanel1_Container:Location := System.Drawing.Point{4, 23}
        SELF:dockPanel1_Container:Name := "dockPanel1_Container"
        SELF:dockPanel1_Container:Size := System.Drawing.Size{271, 343}
        SELF:dockPanel1_Container:TabIndex := 0
        // 
        // gridControl2
        // 
        SELF:gridControl2:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:gridControl2:Location := System.Drawing.Point{0, 0}
        SELF:gridControl2:MainView := SELF:gridView2
        SELF:gridControl2:Name := "gridControl2"
        SELF:gridControl2:Size := System.Drawing.Size{271, 343}
        SELF:gridControl2:TabIndex := 2
        SELF:gridControl2:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:gridView2 })
        // 
        // gridView2
        // 
        SELF:gridView2:GridControl := SELF:gridControl2
        SELF:gridView2:Name := "gridView2"
        SELF:gridView2:OptionsBehavior:ReadOnly := TRUE
        SELF:gridView2:OptionsFind:AlwaysVisible := TRUE
        SELF:gridView2:OptionsSelection:MultiSelect := TRUE
        SELF:gridView2:OptionsView:ShowGroupPanel := FALSE
        // 
        // dockPanel2
        // 
        SELF:dockPanel2:Controls:Add(SELF:dockPanel4_Container)
        SELF:dockPanel2:Dock := DevExpress.XtraBars.Docking.DockingStyle.Fill
        SELF:dockPanel2:FloatVertical := TRUE
        SELF:dockPanel2:ID := System.Guid{"035afe4d-77a3-4933-a86a-b56515e47950"}
        SELF:dockPanel2:Location := System.Drawing.Point{558, 0}
        SELF:dockPanel2:Name := "dockPanel2"
        SELF:dockPanel2:OriginalSize := System.Drawing.Size{279, 369}
        SELF:dockPanel2:Size := System.Drawing.Size{282, 370}
        SELF:dockPanel2:Text := "Actions In Port"
        // 
        // dockPanel4_Container
        // 
        SELF:dockPanel4_Container:Controls:Add(SELF:gridControl3)
        SELF:dockPanel4_Container:Location := System.Drawing.Point{4, 23}
        SELF:dockPanel4_Container:Name := "dockPanel4_Container"
        SELF:dockPanel4_Container:Size := System.Drawing.Size{274, 343}
        SELF:dockPanel4_Container:TabIndex := 0
        // 
        // gridControl3
        // 
        SELF:gridControl3:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:gridControl3:Location := System.Drawing.Point{0, 0}
        SELF:gridControl3:MainView := SELF:gridView3
        SELF:gridControl3:Name := "gridControl3"
        SELF:gridControl3:Size := System.Drawing.Size{274, 343}
        SELF:gridControl3:TabIndex := 2
        SELF:gridControl3:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:gridView3 })
        // 
        // gridView3
        // 
        SELF:gridView3:GridControl := SELF:gridControl3
        SELF:gridView3:Name := "gridView3"
        SELF:gridView3:OptionsBehavior:ReadOnly := TRUE
        SELF:gridView3:OptionsFind:AlwaysVisible := TRUE
        SELF:gridView3:OptionsSelection:MultiSelect := TRUE
        SELF:gridView3:OptionsView:ShowGroupPanel := FALSE
        // 
        // barManager1
        // 
        SELF:barManager1:Bars:AddRange(<DevExpress.XtraBars.Bar>{ SELF:bar2, SELF:bar3 })
        SELF:barManager1:DockControls:Add(SELF:barDockControlTop)
        SELF:barManager1:DockControls:Add(SELF:barDockControlBottom)
        SELF:barManager1:DockControls:Add(SELF:barDockControlLeft)
        SELF:barManager1:DockControls:Add(SELF:barDockControlRight)
        SELF:barManager1:DockManager := SELF:dockManager1
        SELF:barManager1:Form := SELF
        SELF:barManager1:Items:AddRange(<DevExpress.XtraBars.BarItem>{ SELF:barButtonItem1, SELF:barButtonItem2 })
        SELF:barManager1:MainMenu := SELF:bar2
        SELF:barManager1:MaxItemId := 2
        SELF:barManager1:StatusBar := SELF:bar3
        // 
        // bar2
        // 
        SELF:bar2:BarName := "Main menu"
        SELF:bar2:DockCol := 0
        SELF:bar2:DockRow := 0
        SELF:bar2:DockStyle := DevExpress.XtraBars.BarDockStyle.Top
        SELF:bar2:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:barButtonItem1}, DevExpress.XtraBars.LinkPersistInfo{SELF:barButtonItem2} })
        SELF:bar2:OptionsBar:MultiLine := TRUE
        SELF:bar2:OptionsBar:UseWholeRow := TRUE
        SELF:bar2:Text := "Main menu"
        // 
        // barButtonItem1
        // 
        SELF:barButtonItem1:Caption := "Add Cargo"
        SELF:barButtonItem1:Enabled := FALSE
        SELF:barButtonItem1:Id := 0
        SELF:barButtonItem1:Name := "barButtonItem1"
        SELF:barButtonItem1:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @barButtonItem1_ItemClick() }
        // 
        // barButtonItem2
        // 
        SELF:barButtonItem2:Caption := "Add Expense"
        SELF:barButtonItem2:Enabled := FALSE
        SELF:barButtonItem2:Id := 1
        SELF:barButtonItem2:Name := "barButtonItem2"
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
        SELF:bar3:Visible := FALSE
        // 
        // barDockControlTop
        // 
        SELF:barDockControlTop:CausesValidation := FALSE
        SELF:barDockControlTop:Dock := System.Windows.Forms.DockStyle.Top
        SELF:barDockControlTop:Location := System.Drawing.Point{0, 0}
        SELF:barDockControlTop:Size := System.Drawing.Size{840, 22}
        // 
        // barDockControlBottom
        // 
        SELF:barDockControlBottom:CausesValidation := FALSE
        SELF:barDockControlBottom:Dock := System.Windows.Forms.DockStyle.Bottom
        SELF:barDockControlBottom:Location := System.Drawing.Point{0, 392}
        SELF:barDockControlBottom:Size := System.Drawing.Size{840, 23}
        // 
        // barDockControlLeft
        // 
        SELF:barDockControlLeft:CausesValidation := FALSE
        SELF:barDockControlLeft:Dock := System.Windows.Forms.DockStyle.Left
        SELF:barDockControlLeft:Location := System.Drawing.Point{0, 22}
        SELF:barDockControlLeft:Size := System.Drawing.Size{0, 370}
        // 
        // barDockControlRight
        // 
        SELF:barDockControlRight:CausesValidation := FALSE
        SELF:barDockControlRight:Dock := System.Windows.Forms.DockStyle.Right
        SELF:barDockControlRight:Location := System.Drawing.Point{840, 22}
        SELF:barDockControlRight:Size := System.Drawing.Size{0, 370}
        // 
        // RoutingDetails
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:AutoSize := TRUE
        SELF:Controls:Add(SELF:panelContainer2)
        SELF:Controls:Add(SELF:barDockControlLeft)
        SELF:Controls:Add(SELF:barDockControlRight)
        SELF:Controls:Add(SELF:barDockControlBottom)
        SELF:Controls:Add(SELF:barDockControlTop)
        SELF:Name := "RoutingDetails"
        SELF:Size := System.Drawing.Size{840, 415}
        SELF:Load += System.EventHandler{ SELF, @RoutingDetails_Load() }
        ((System.ComponentModel.ISupportInitialize)(SELF:dockManager1)):EndInit()
        SELF:panelContainer2:ResumeLayout(FALSE)
        SELF:dockPanel3:ResumeLayout(FALSE)
        SELF:dockPanel3_Container:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:gridControl1)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridView1)):EndInit()
        SELF:dockPanel1:ResumeLayout(FALSE)
        SELF:dockPanel1_Container:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:gridControl2)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridView2)):EndInit()
        SELF:dockPanel2:ResumeLayout(FALSE)
        SELF:dockPanel4_Container:ResumeLayout(FALSE)
        ((System.ComponentModel.ISupportInitialize)(SELF:gridControl3)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gridView3)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:barManager1)):EndInit()
        SELF:ResumeLayout(FALSE)
    PRIVATE METHOD RoutingDetails_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			//SELF:createGrids()
        RETURN
		
    PRIVATE METHOD barButtonItem1_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
			SELF:addCargo()
    RETURN

END CLASS
