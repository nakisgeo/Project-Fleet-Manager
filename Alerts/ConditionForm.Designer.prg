﻿//------------------------------------------------------------------------------
//  <auto-generated>
//     This code was generated by a tool.
//     Runtime version: 4.0.30319.42000
//     Generator      : XSharp.CodeDomProvider 2.1.0.0
//     Timestamp      : 20/2/2020 16:39:22
//     
//     Changes to this file may cause incorrect behavior and may be lost if
//     the code is regenerated.
//  </auto-generated>
//------------------------------------------------------------------------------
BEGIN NAMESPACE FleetManager.Alerts
    PUBLIC PARTIAL CLASS ConditionForm ;
        INHERIT System.Windows.Forms.Form
        PRIVATE barManager1 AS DevExpress.XtraBars.BarManager
        PRIVATE bar2 AS DevExpress.XtraBars.Bar
        PRIVATE barButtonItem1 AS DevExpress.XtraBars.BarButtonItem
        PRIVATE barDockControlTop AS DevExpress.XtraBars.BarDockControl
        PRIVATE barDockControlBottom AS DevExpress.XtraBars.BarDockControl
        PRIVATE barDockControlLeft AS DevExpress.XtraBars.BarDockControl
        PRIVATE barDockControlRight AS DevExpress.XtraBars.BarDockControl
        PRIVATE panel1 AS System.Windows.Forms.Panel
        PRIVATE panel2 AS System.Windows.Forms.Panel
        PRIVATE label1 AS System.Windows.Forms.Label
        PRIVATE tbDescription AS System.Windows.Forms.TextBox
        PRIVATE label5 AS System.Windows.Forms.Label
        PRIVATE label2 AS System.Windows.Forms.Label
        PRIVATE tbValue AS System.Windows.Forms.TextBox
        PRIVATE cbReport AS DevExpress.XtraEditors.ComboBoxEdit
        PRIVATE cbOperator AS DevExpress.XtraEditors.ComboBoxEdit
        PRIVATE label3 AS System.Windows.Forms.Label
        PRIVATE label4 AS System.Windows.Forms.Label
        PRIVATE cbItem AS DevExpress.XtraEditors.ComboBoxEdit
        PRIVATE label6 AS System.Windows.Forms.Label
        PRIVATE components := NULL AS System.ComponentModel.IContainer
                        
        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        PROTECTED METHOD Dispose(disposing AS LOGIC) AS VOID STRICT

            IF (disposing .AND. (components != null))
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
            LOCAL resources := System.ComponentModel.ComponentResourceManager{TYPEOF(ConditionForm)} AS System.ComponentModel.ComponentResourceManager
            SELF:barManager1 := DevExpress.XtraBars.BarManager{SELF:components}
            SELF:bar2 := DevExpress.XtraBars.Bar{}
            SELF:barButtonItem1 := DevExpress.XtraBars.BarButtonItem{}
            SELF:barDockControlTop := DevExpress.XtraBars.BarDockControl{}
            SELF:barDockControlBottom := DevExpress.XtraBars.BarDockControl{}
            SELF:barDockControlLeft := DevExpress.XtraBars.BarDockControl{}
            SELF:barDockControlRight := DevExpress.XtraBars.BarDockControl{}
            SELF:panel1 := System.Windows.Forms.Panel{}
            SELF:tbDescription := System.Windows.Forms.TextBox{}
            SELF:label1 := System.Windows.Forms.Label{}
            SELF:label2 := System.Windows.Forms.Label{}
            SELF:cbReport := DevExpress.XtraEditors.ComboBoxEdit{}
            SELF:cbItem := DevExpress.XtraEditors.ComboBoxEdit{}
            SELF:label3 := System.Windows.Forms.Label{}
            SELF:cbOperator := DevExpress.XtraEditors.ComboBoxEdit{}
            SELF:label4 := System.Windows.Forms.Label{}
            SELF:label5 := System.Windows.Forms.Label{}
            SELF:tbValue := System.Windows.Forms.TextBox{}
            SELF:label6 := System.Windows.Forms.Label{}
            SELF:panel2 := System.Windows.Forms.Panel{}
            ((System.ComponentModel.ISupportInitialize)(SELF:barManager1)):BeginInit()
            SELF:panel1:SuspendLayout()
            ((System.ComponentModel.ISupportInitialize)(SELF:cbReport:Properties)):BeginInit()
            ((System.ComponentModel.ISupportInitialize)(SELF:cbItem:Properties)):BeginInit()
            ((System.ComponentModel.ISupportInitialize)(SELF:cbOperator:Properties)):BeginInit()
            SELF:panel2:SuspendLayout()
            SELF:SuspendLayout()
            // 
            // barManager1
            // 
            SELF:barManager1:Bars:AddRange(<DevExpress.XtraBars.Bar>{ SELF:bar2 })
            SELF:barManager1:DockControls:Add(SELF:barDockControlTop)
            SELF:barManager1:DockControls:Add(SELF:barDockControlBottom)
            SELF:barManager1:DockControls:Add(SELF:barDockControlLeft)
            SELF:barManager1:DockControls:Add(SELF:barDockControlRight)
            SELF:barManager1:Form := SELF
            SELF:barManager1:Items:AddRange(<DevExpress.XtraBars.BarItem>{ SELF:barButtonItem1 })
            SELF:barManager1:MainMenu := SELF:bar2
            SELF:barManager1:MaxItemId := 1
            // 
            // bar2
            // 
            SELF:bar2:BarName := "Main menu"
            SELF:bar2:DockCol := 0
            SELF:bar2:DockRow := 0
            SELF:bar2:DockStyle := DevExpress.XtraBars.BarDockStyle.Top
            SELF:bar2:LinksPersistInfo:AddRange(<DevExpress.XtraBars.LinkPersistInfo>{ DevExpress.XtraBars.LinkPersistInfo{SELF:barButtonItem1} })
            SELF:bar2:OptionsBar:AllowQuickCustomization := false
            SELF:bar2:OptionsBar:MultiLine := true
            SELF:bar2:OptionsBar:UseWholeRow := true
            SELF:bar2:Text := "Main menu"
            // 
            // barButtonItem1
            // 
            SELF:barButtonItem1:Caption := "Save"
            SELF:barButtonItem1:Id := 0
            SELF:barButtonItem1:ImageOptions:Image := ((System.Drawing.Image)(resources:GetObject("barButtonItem1.ImageOptions.Image")))
            SELF:barButtonItem1:ImageOptions:LargeImage := ((System.Drawing.Image)(resources:GetObject("barButtonItem1.ImageOptions.LargeImage")))
            SELF:barButtonItem1:Name := "barButtonItem1"
            // 
            // barDockControlTop
            // 
            SELF:barDockControlTop:CausesValidation := false
            SELF:barDockControlTop:Dock := System.Windows.Forms.DockStyle.Top
            SELF:barDockControlTop:Location := System.Drawing.Point{0, 0}
            SELF:barDockControlTop:Manager := SELF:barManager1
            SELF:barDockControlTop:Margin := System.Windows.Forms.Padding{3, 2, 3, 2}
            SELF:barDockControlTop:Size := System.Drawing.Size{404, 28}
            // 
            // barDockControlBottom
            // 
            SELF:barDockControlBottom:CausesValidation := false
            SELF:barDockControlBottom:Dock := System.Windows.Forms.DockStyle.Bottom
            SELF:barDockControlBottom:Location := System.Drawing.Point{0, 203}
            SELF:barDockControlBottom:Manager := SELF:barManager1
            SELF:barDockControlBottom:Margin := System.Windows.Forms.Padding{3, 2, 3, 2}
            SELF:barDockControlBottom:Size := System.Drawing.Size{404, 0}
            // 
            // barDockControlLeft
            // 
            SELF:barDockControlLeft:CausesValidation := false
            SELF:barDockControlLeft:Dock := System.Windows.Forms.DockStyle.Left
            SELF:barDockControlLeft:Location := System.Drawing.Point{0, 28}
            SELF:barDockControlLeft:Manager := SELF:barManager1
            SELF:barDockControlLeft:Margin := System.Windows.Forms.Padding{3, 2, 3, 2}
            SELF:barDockControlLeft:Size := System.Drawing.Size{0, 175}
            // 
            // barDockControlRight
            // 
            SELF:barDockControlRight:CausesValidation := false
            SELF:barDockControlRight:Dock := System.Windows.Forms.DockStyle.Right
            SELF:barDockControlRight:Location := System.Drawing.Point{404, 28}
            SELF:barDockControlRight:Manager := SELF:barManager1
            SELF:barDockControlRight:Margin := System.Windows.Forms.Padding{3, 2, 3, 2}
            SELF:barDockControlRight:Size := System.Drawing.Size{0, 175}
            // 
            // panel1
            // 
            SELF:panel1:Controls:Add(SELF:panel2)
            SELF:panel1:Controls:Add(SELF:label6)
            SELF:panel1:Dock := System.Windows.Forms.DockStyle.Fill
            SELF:panel1:Location := System.Drawing.Point{0, 28}
            SELF:panel1:Margin := System.Windows.Forms.Padding{3, 2, 3, 2}
            SELF:panel1:Name := "panel1"
            SELF:panel1:Size := System.Drawing.Size{404, 175}
            SELF:panel1:TabIndex := 4
            // 
            // tbDescription
            // 
            SELF:tbDescription:Font := System.Drawing.Font{"Tahoma", 9.25, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((BYTE)(161))}
            SELF:tbDescription:Location := System.Drawing.Point{89, 6}
            SELF:tbDescription:Margin := System.Windows.Forms.Padding{3, 2, 3, 2}
            SELF:tbDescription:Name := "tbDescription"
            SELF:tbDescription:Size := System.Drawing.Size{262, 22}
            SELF:tbDescription:TabIndex := 0
            // 
            // label1
            // 
            SELF:label1:AutoSize := true
            SELF:label1:Font := System.Drawing.Font{"Tahoma", 9.25, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((BYTE)(161))}
            SELF:label1:Location := System.Drawing.Point{12, 9}
            SELF:label1:Name := "label1"
            SELF:label1:Size := System.Drawing.Size{71, 16}
            SELF:label1:TabIndex := 1
            SELF:label1:Text := "Description"
            // 
            // label2
            // 
            SELF:label2:AutoSize := true
            SELF:label2:Font := System.Drawing.Font{"Tahoma", 9.25, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((BYTE)(161))}
            SELF:label2:Location := System.Drawing.Point{37, 38}
            SELF:label2:Name := "label2"
            SELF:label2:Size := System.Drawing.Size{46, 16}
            SELF:label2:TabIndex := 3
            SELF:label2:Text := "Report"
            // 
            // cbReport
            // 
            SELF:cbReport:Location := System.Drawing.Point{89, 35}
            SELF:cbReport:Margin := System.Windows.Forms.Padding{3, 2, 3, 2}
            SELF:cbReport:MenuManager := SELF:barManager1
            SELF:cbReport:Name := "cbReport"
            SELF:cbReport:Properties:Appearance:Font := System.Drawing.Font{"Tahoma", 9.25}
            SELF:cbReport:Properties:Appearance:Options:UseFont := true
            SELF:cbReport:Properties:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{DevExpress.XtraEditors.Controls.ButtonPredefines.Combo} })
            SELF:cbReport:Size := System.Drawing.Size{262, 20}
            SELF:cbReport:TabIndex := 4
            // 
            // cbItem
            // 
            SELF:cbItem:Location := System.Drawing.Point{89, 61}
            SELF:cbItem:Margin := System.Windows.Forms.Padding{3, 2, 3, 2}
            SELF:cbItem:MenuManager := SELF:barManager1
            SELF:cbItem:Name := "cbItem"
            SELF:cbItem:Properties:Appearance:Font := System.Drawing.Font{"Tahoma", 9.25}
            SELF:cbItem:Properties:Appearance:Options:UseFont := true
            SELF:cbItem:Properties:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{DevExpress.XtraEditors.Controls.ButtonPredefines.Combo} })
            SELF:cbItem:Size := System.Drawing.Size{262, 20}
            SELF:cbItem:TabIndex := 6
            // 
            // label3
            // 
            SELF:label3:AutoSize := true
            SELF:label3:Font := System.Drawing.Font{"Tahoma", 9.25, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((BYTE)(161))}
            SELF:label3:Location := System.Drawing.Point{48, 64}
            SELF:label3:Name := "label3"
            SELF:label3:Size := System.Drawing.Size{35, 16}
            SELF:label3:TabIndex := 5
            SELF:label3:Text := "Field"
            // 
            // cbOperator
            // 
            SELF:cbOperator:Location := System.Drawing.Point{89, 87}
            SELF:cbOperator:Margin := System.Windows.Forms.Padding{3, 2, 3, 2}
            SELF:cbOperator:MenuManager := SELF:barManager1
            SELF:cbOperator:Name := "cbOperator"
            SELF:cbOperator:Properties:Appearance:Font := System.Drawing.Font{"Tahoma", 9.25}
            SELF:cbOperator:Properties:Appearance:Options:UseFont := true
            SELF:cbOperator:Properties:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{DevExpress.XtraEditors.Controls.ButtonPredefines.Combo} })
            SELF:cbOperator:Size := System.Drawing.Size{75, 20}
            SELF:cbOperator:TabIndex := 8
            // 
            // label4
            // 
            SELF:label4:AutoSize := true
            SELF:label4:Font := System.Drawing.Font{"Tahoma", 9.25, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((BYTE)(161))}
            SELF:label4:Location := System.Drawing.Point{24, 90}
            SELF:label4:Name := "label4"
            SELF:label4:Size := System.Drawing.Size{59, 16}
            SELF:label4:TabIndex := 7
            SELF:label4:Text := "Operator"
            // 
            // label5
            // 
            SELF:label5:AutoSize := true
            SELF:label5:Font := System.Drawing.Font{"Tahoma", 9.25, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((BYTE)(161))}
            SELF:label5:Location := System.Drawing.Point{170, 90}
            SELF:label5:Name := "label5"
            SELF:label5:Size := System.Drawing.Size{40, 16}
            SELF:label5:TabIndex := 10
            SELF:label5:Text := "Value"
            // 
            // tbValue
            // 
            SELF:tbValue:Font := System.Drawing.Font{"Tahoma", 9.25, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((BYTE)(161))}
            SELF:tbValue:Location := System.Drawing.Point{216, 87}
            SELF:tbValue:Margin := System.Windows.Forms.Padding{3, 2, 3, 2}
            SELF:tbValue:Name := "tbValue"
            SELF:tbValue:Size := System.Drawing.Size{135, 22}
            SELF:tbValue:TabIndex := 9
            // 
            // label6
            // 
            SELF:label6:AutoSize := true
            SELF:label6:Font := System.Drawing.Font{"Tahoma", 11.25, System.Drawing.FontStyle.Bold}
            SELF:label6:Location := System.Drawing.Point{12, 13}
            SELF:label6:Name := "label6"
            SELF:label6:Size := System.Drawing.Size{45, 18}
            SELF:label6:TabIndex := 11
            SELF:label6:Text := "Alert"
            // 
            // panel2
            // 
            SELF:panel2:Controls:Add(SELF:label1)
            SELF:panel2:Controls:Add(SELF:tbDescription)
            SELF:panel2:Controls:Add(SELF:label5)
            SELF:panel2:Controls:Add(SELF:label2)
            SELF:panel2:Controls:Add(SELF:tbValue)
            SELF:panel2:Controls:Add(SELF:cbReport)
            SELF:panel2:Controls:Add(SELF:cbOperator)
            SELF:panel2:Controls:Add(SELF:label3)
            SELF:panel2:Controls:Add(SELF:label4)
            SELF:panel2:Controls:Add(SELF:cbItem)
            SELF:panel2:Location := System.Drawing.Point{15, 43}
            SELF:panel2:Margin := System.Windows.Forms.Padding{3, 2, 3, 2}
            SELF:panel2:Name := "panel2"
            SELF:panel2:Size := System.Drawing.Size{368, 117}
            SELF:panel2:TabIndex := 12
            // 
            // ConditionForm
            // 
            SELF:AutoScaleDimensions := System.Drawing.SizeF{6, 13}
            SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
            SELF:ClientSize := System.Drawing.Size{404, 203}
            SELF:Controls:Add(SELF:panel1)
            SELF:Controls:Add(SELF:barDockControlLeft)
            SELF:Controls:Add(SELF:barDockControlRight)
            SELF:Controls:Add(SELF:barDockControlBottom)
            SELF:Controls:Add(SELF:barDockControlTop)
            SELF:Margin := System.Windows.Forms.Padding{3, 2, 3, 2}
            SELF:Name := "ConditionForm"
            SELF:Text := "ConditionForm"
            ((System.ComponentModel.ISupportInitialize)(SELF:barManager1)):EndInit()
            SELF:panel1:ResumeLayout(false)
            SELF:panel1:PerformLayout()
            ((System.ComponentModel.ISupportInitialize)(SELF:cbReport:Properties)):EndInit()
            ((System.ComponentModel.ISupportInitialize)(SELF:cbItem:Properties)):EndInit()
            ((System.ComponentModel.ISupportInitialize)(SELF:cbOperator:Properties)):EndInit()
            SELF:panel2:ResumeLayout(false)
            SELF:panel2:PerformLayout()
            SELF:ResumeLayout(false)
            SELF:PerformLayout()
    
        #endregion
    
    END CLASS 
END NAMESPACE
