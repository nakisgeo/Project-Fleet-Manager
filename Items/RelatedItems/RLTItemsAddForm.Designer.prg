//------------------------------------------------------------------------------
//  <auto-generated>
//     This code was generated by a tool.
//     Runtime version: 4.0.30319.42000
//     Generator      : XSharp.CodeDomProvider 2.1.0.0
//     Timestamp      : 12/2/2020 13:38:20
//     
//     Changes to this file may cause incorrect behavior and may be lost if
//     the code is regenerated.
//  </auto-generated>
//------------------------------------------------------------------------------
PUBLIC PARTIAL CLASS RLTItemsAddForm ;
    INHERIT System.Windows.Forms.Form
    PRIVATE barManager1 AS DevExpress.XtraBars.BarManager
    PRIVATE bar1 AS DevExpress.XtraBars.Bar
    PRIVATE barButtonItem1 AS DevExpress.XtraBars.BarButtonItem
    PRIVATE barButtonItem3 AS DevExpress.XtraBars.BarButtonItem
    PRIVATE barButtonItem2 AS DevExpress.XtraBars.BarButtonItem
    PRIVATE barDockControlTop AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlBottom AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlLeft AS DevExpress.XtraBars.BarDockControl
    PRIVATE barDockControlRight AS DevExpress.XtraBars.BarDockControl
    PRIVATE GridViewItems AS DevExpress.XtraGrid.Views.Grid.GridView
    PRIVATE GridItems AS DevExpress.XtraGrid.GridControl
    PRIVATE components := NULL AS System.ComponentModel.IContainer
                                                            
        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
    PROTECTED METHOD Dispose(disposing AS LOGIC) AS VOID STRICT

            IF (disposing .AND. (components != NULL))
                components:Dispose()
            ENDIF
            SUPER:Dispose(disposing)
            RETURN

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
    PRIVATE METHOD InitializeComponent() AS VOID STRICT
        SELF:components := System.ComponentModel.Container{}
        LOCAL resources := System.ComponentModel.ComponentResourceManager{TYPEOF(RLTItemsAddForm)} AS System.ComponentModel.ComponentResourceManager
        SELF:GridItems := DevExpress.XtraGrid.GridControl{}
        SELF:GridViewItems := DevExpress.XtraGrid.Views.Grid.GridView{}
        SELF:barManager1 := DevExpress.XtraBars.BarManager{SELF:components}
        SELF:bar1 := DevExpress.XtraBars.Bar{}
        SELF:barButtonItem1 := DevExpress.XtraBars.BarButtonItem{}
        SELF:barButtonItem3 := DevExpress.XtraBars.BarButtonItem{}
        SELF:barButtonItem2 := DevExpress.XtraBars.BarButtonItem{}
        SELF:barDockControlTop := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlBottom := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlLeft := DevExpress.XtraBars.BarDockControl{}
        SELF:barDockControlRight := DevExpress.XtraBars.BarDockControl{}
        ((System.ComponentModel.ISupportInitialize)(SELF:GridItems)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:GridViewItems)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:barManager1)):BeginInit()
        SELF:SuspendLayout()
        // 
        // GridItems
        // 
        SELF:GridItems:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:GridItems:Location := System.Drawing.Point{0, 31}
        SELF:GridItems:MainView := SELF:GridViewItems
        SELF:GridItems:Name := "GridItems"
        SELF:GridItems:Size := System.Drawing.Size{499, 674}
        SELF:GridItems:TabIndex := 0
        SELF:GridItems:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:GridViewItems })
        // 
        // GridViewItems
        // 
        SELF:GridViewItems:GridControl := SELF:GridItems
        SELF:GridViewItems:Name := "GridViewItems"
        SELF:GridViewItems:OptionsCustomization:CustomizationFormSearchBoxVisible := TRUE
        SELF:GridViewItems:OptionsView:ShowAutoFilterRow := true
        // 
        // barManager1
        // 
        SELF:barManager1:Bars:AddRange(<DevExpress.XtraBars.Bar>{ SELF:bar1 })
        SELF:barManager1:DockControls:Add(SELF:barDockControlTop)
        SELF:barManager1:DockControls:Add(SELF:barDockControlBottom)
        SELF:barManager1:DockControls:Add(SELF:barDockControlLeft)
        SELF:barManager1:DockControls:Add(SELF:barDockControlRight)
        SELF:barManager1:Form := SELF
        SELF:barManager1:Items:AddRange(<DevExpress.XtraBars.BarItem>{ SELF:barButtonItem1, SELF:barButtonItem2, SELF:barButtonItem3 })
        SELF:barManager1:MaxItemId := 3
        // 
        // bar1
        // 
        SELF:bar1:BarName := "Tools"
        SELF:bar1:DockCol := 0
        SELF:bar1:DockRow := 0
        SELF:bar1:DockStyle := DevExpress.XtraBars.BarDockStyle.Top
        SELF:bar1:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:barButtonItem1}, DevExpress.XtraBars.LinkPersistInfo{SELF:barButtonItem3}, DevExpress.XtraBars.LinkPersistInfo{SELF:barButtonItem2} })
        SELF:bar1:OptionsBar:AllowQuickCustomization := FALSE
        SELF:bar1:OptionsBar:DrawBorder := FALSE
        SELF:bar1:OptionsBar:DrawDragBorder := FALSE
        SELF:bar1:OptionsBar:RotateWhenVertical := FALSE
        SELF:bar1:Text := "Tools"
        // 
        // barButtonItem1
        // 
        SELF:barButtonItem1:Caption := "Save"
        SELF:barButtonItem1:Id := 0
        SELF:barButtonItem1:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("barButtonItem1.ImageOptions.Image")))
        SELF:barButtonItem1:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("barButtonItem1.ImageOptions.LargeImage")))
        SELF:barButtonItem1:Name := "barButtonItem1"
        SELF:barButtonItem1:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @barButtonItem1_ItemClick() }
        // 
        // barButtonItem3
        // 
        SELF:barButtonItem3:Caption := "SaveAndClose"
        SELF:barButtonItem3:Id := 2
        SELF:barButtonItem3:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("barButtonItem3.ImageOptions.Image")))
        SELF:barButtonItem3:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("barButtonItem3.ImageOptions.LargeImage")))
        SELF:barButtonItem3:Name := "barButtonItem3"
        SELF:barButtonItem3:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @barButtonItem3_ItemClick() }
        // 
        // barButtonItem2
        // 
        SELF:barButtonItem2:Caption := "Close"
        SELF:barButtonItem2:Id := 1
        SELF:barButtonItem2:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("barButtonItem2.ImageOptions.Image")))
        SELF:barButtonItem2:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("barButtonItem2.ImageOptions.LargeImage")))
        SELF:barButtonItem2:Name := "barButtonItem2"
        SELF:barButtonItem2:ItemClick += DevExpress.XtraBars.ItemClickEventHandler{ SELF, @barButtonItem2_ItemClick() }
        // 
        // barDockControlTop
        // 
        SELF:barDockControlTop:CausesValidation := FALSE
        SELF:barDockControlTop:Dock := System.Windows.Forms.DockStyle.Top
        SELF:barDockControlTop:Location := System.Drawing.Point{0, 0}
        SELF:barDockControlTop:Manager := SELF:barManager1
        SELF:barDockControlTop:Size := System.Drawing.Size{499, 31}
        // 
        // barDockControlBottom
        // 
        SELF:barDockControlBottom:CausesValidation := FALSE
        SELF:barDockControlBottom:Dock := System.Windows.Forms.DockStyle.Bottom
        SELF:barDockControlBottom:Location := System.Drawing.Point{0, 705}
        SELF:barDockControlBottom:Manager := SELF:barManager1
        SELF:barDockControlBottom:Size := System.Drawing.Size{499, 0}
        // 
        // barDockControlLeft
        // 
        SELF:barDockControlLeft:CausesValidation := FALSE
        SELF:barDockControlLeft:Dock := System.Windows.Forms.DockStyle.Left
        SELF:barDockControlLeft:Location := System.Drawing.Point{0, 31}
        SELF:barDockControlLeft:Manager := SELF:barManager1
        SELF:barDockControlLeft:Size := System.Drawing.Size{0, 674}
        // 
        // barDockControlRight
        // 
        SELF:barDockControlRight:CausesValidation := FALSE
        SELF:barDockControlRight:Dock := System.Windows.Forms.DockStyle.Right
        SELF:barDockControlRight:Location := System.Drawing.Point{499, 31}
        SELF:barDockControlRight:Manager := SELF:barManager1
        SELF:barDockControlRight:Size := System.Drawing.Size{0, 674}
        // 
        // RLTItemsAddForm
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{7, 11}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{499, 705}
        SELF:Controls:Add(SELF:GridItems)
        SELF:Controls:Add(SELF:barDockControlLeft)
        SELF:Controls:Add(SELF:barDockControlRight)
        SELF:Controls:Add(SELF:barDockControlBottom)
        SELF:Controls:Add(SELF:barDockControlTop)
        SELF:Font := System.Drawing.Font{"Lucida Console", 8.25, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((BYTE)(161))}
        SELF:Margin := System.Windows.Forms.Padding{3, 2, 3, 2}
        SELF:Name := "RLTItemsAddForm"
        SELF:StartPosition := System.Windows.Forms.FormStartPosition.CenterParent
        SELF:Text := "RLTItemsAddForm"
        SELF:FormClosed += System.Windows.Forms.FormClosedEventHandler{ SELF, @RLTItemsAddForm_FormClosed() }
        SELF:Shown += System.EventHandler{ SELF, @RLTItemsAddForm_Shown() }
        ((System.ComponentModel.ISupportInitialize)(SELF:GridItems)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:GridViewItems)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:barManager1)):EndInit()
        SELF:ResumeLayout(FALSE)
        SELF:PerformLayout()

        #endregion

END CLASS 
