CLASS Cargoes_Form INHERIT System.Windows.Forms.Form
    PRIVATE barDockControlTop AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlBottom AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlLeft AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlRight AS DevExpress.XtraBars.BarDockControl
    PRIVATE barManager1 AS DevExpress.XtraBars.BarManager
    PRIVATE bar1 AS DevExpress.XtraBars.Bar
    PRIVATE barButtonItem1 AS DevExpress.XtraBars.BarButtonItem
    PRIVATE barButtonItem2 AS DevExpress.XtraBars.BarButtonItem
    PRIVATE barDockControl1 AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControl2 AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControl3 AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControl4 AS DevExpress.XtraBars.BarDockControl
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
        SELF:barDockControlTop := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlBottom := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlLeft := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlRight := DevExpress.XtraBars.BarDockControl{}
        SELF:barManager1 := DevExpress.XtraBars.BarManager{SELF:components}
        SELF:bar1 := DevExpress.XtraBars.Bar{}
        SELF:barButtonItem1 := DevExpress.XtraBars.BarButtonItem{}
        SELF:barButtonItem2 := DevExpress.XtraBars.BarButtonItem{}
        SELF:barDockControl1 := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControl2 := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControl3 := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControl4 := DevExpress.XtraBars.BarDockControl{}
        ((System.ComponentModel.ISupportInitialize)(SELF:barManager1)):BeginInit()
        SELF:SuspendLayout()
        // 
        // barDockControlTop
        // 
        SELF:barDockControlTop:CausesValidation := FALSE
        SELF:barDockControlTop:Dock := System.Windows.Forms.DockStyle.Top
        SELF:barDockControlTop:Location := System.Drawing.Point{0, 24}
        SELF:barDockControlTop:Size := System.Drawing.Size{1212, 0}
        // 
        // barDockControlBottom
        // 
        SELF:barDockControlBottom:CausesValidation := FALSE
        SELF:barDockControlBottom:Dock := System.Windows.Forms.DockStyle.Bottom
        SELF:barDockControlBottom:Location := System.Drawing.Point{0, 527}
        SELF:barDockControlBottom:Size := System.Drawing.Size{1212, 0}
        // 
        // barDockControlLeft
        // 
        SELF:barDockControlLeft:CausesValidation := FALSE
        SELF:barDockControlLeft:Dock := System.Windows.Forms.DockStyle.Left
        SELF:barDockControlLeft:Location := System.Drawing.Point{0, 24}
        SELF:barDockControlLeft:Size := System.Drawing.Size{0, 503}
        // 
        // barDockControlRight
        // 
        SELF:barDockControlRight:CausesValidation := FALSE
        SELF:barDockControlRight:Dock := System.Windows.Forms.DockStyle.Right
        SELF:barDockControlRight:Location := System.Drawing.Point{1212, 24}
        SELF:barDockControlRight:Size := System.Drawing.Size{0, 503}
        // 
        // barManager1
        // 
        SELF:barManager1:Bars:AddRange(<DevExpress.XtraBars.Bar>{ SELF:bar1 })
        SELF:barManager1:DockControls:Add(SELF:barDockControl1)
        SELF:barManager1:DockControls:Add(SELF:barDockControl2)
        SELF:barManager1:DockControls:Add(SELF:barDockControl3)
        SELF:barManager1:DockControls:Add(SELF:barDockControl4)
        SELF:barManager1:Form := SELF
        SELF:barManager1:Items:AddRange(<DevExpress.XtraBars.BarItem>{ SELF:barButtonItem1, SELF:barButtonItem2 })
        SELF:barManager1:MaxItemId := 2
        // 
        // bar1
        // 
        SELF:bar1:BarName := "Tools"
        SELF:bar1:DockCol := 0
        SELF:bar1:DockRow := 0
        SELF:bar1:DockStyle := DevExpress.XtraBars.BarDockStyle.Top
        SELF:bar1:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:barButtonItem1}, DevExpress.XtraBars.LinkPersistInfo{SELF:barButtonItem2} })
        SELF:bar1:Text := "Tools"
        // 
        // barButtonItem1
        // 
        SELF:barButtonItem1:Caption := "Add Cargo"
        SELF:barButtonItem1:Id := 0
        SELF:barButtonItem1:Name := "barButtonItem1"
        SELF:barButtonItem1:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @barButtonItem1_ItemClick() }
        // 
        // barButtonItem2
        // 
        SELF:barButtonItem2:Caption := "Cargo Types"
        SELF:barButtonItem2:Id := 1
        SELF:barButtonItem2:Name := "barButtonItem2"
        SELF:barButtonItem2:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @barButtonItem2_ItemClick() }
        // 
        // barDockControl1
        // 
        SELF:barDockControl1:CausesValidation := FALSE
        SELF:barDockControl1:Dock := System.Windows.Forms.DockStyle.Top
        SELF:barDockControl1:Location := System.Drawing.Point{0, 0}
        SELF:barDockControl1:Size := System.Drawing.Size{1212, 24}
        // 
        // barDockControl2
        // 
        SELF:barDockControl2:CausesValidation := FALSE
        SELF:barDockControl2:Dock := System.Windows.Forms.DockStyle.Bottom
        SELF:barDockControl2:Location := System.Drawing.Point{0, 527}
        SELF:barDockControl2:Size := System.Drawing.Size{1212, 0}
        // 
        // barDockControl3
        // 
        SELF:barDockControl3:CausesValidation := FALSE
        SELF:barDockControl3:Dock := System.Windows.Forms.DockStyle.Left
        SELF:barDockControl3:Location := System.Drawing.Point{0, 24}
        SELF:barDockControl3:Size := System.Drawing.Size{0, 503}
        // 
        // barDockControl4
        // 
        SELF:barDockControl4:CausesValidation := FALSE
        SELF:barDockControl4:Dock := System.Windows.Forms.DockStyle.Right
        SELF:barDockControl4:Location := System.Drawing.Point{1212, 24}
        SELF:barDockControl4:Size := System.Drawing.Size{0, 503}
        // 
        // Cargoes_Form
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{1212, 527}
        SELF:Controls:Add(SELF:barDockControlLeft)
        SELF:Controls:Add(SELF:barDockControlRight)
        SELF:Controls:Add(SELF:barDockControlBottom)
        SELF:Controls:Add(SELF:barDockControlTop)
        SELF:Controls:Add(SELF:barDockControl3)
        SELF:Controls:Add(SELF:barDockControl4)
        SELF:Controls:Add(SELF:barDockControl2)
        SELF:Controls:Add(SELF:barDockControl1)
        SELF:Name := "Cargoes_Form"
        SELF:ShowIcon := FALSE
        SELF:Text := "Cargoes_Form"
        ((System.ComponentModel.ISupportInitialize)(SELF:barManager1)):EndInit()
        SELF:ResumeLayout(FALSE)
    PRIVATE METHOD barButtonItem1_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        RETURN
    PRIVATE METHOD barButtonItem2_ItemClick( sender AS System.Object, e AS DevExpress.XtraBars.ItemClickEventArgs ) AS System.Void
        RETURN

END CLASS
