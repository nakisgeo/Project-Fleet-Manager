//------------------------------------------------------------------------------
//  <auto-generated>
//     This code was generated by a tool.
//     Runtime version: 4.0.30319.42000
//     Generator      : XSharp.CodeDomProvider 2.1.0.0
//     Timestamp      : 25/2/2020 14:06:52
//     
//     Changes to this file may cause incorrect behavior and may be lost if
//     the code is regenerated.
//  </auto-generated>
//------------------------------------------------------------------------------
PUBLIC PARTIAL CLASS CheckAlertsForm ;
    INHERIT System.Windows.Forms.Form
    PRIVATE label1 AS System.Windows.Forms.Label
    PRIVATE button1 AS System.Windows.Forms.Button
    PRIVATE tb_PUID AS System.Windows.Forms.TextBox
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
        SELF:label1 := System.Windows.Forms.Label{}
        SELF:tb_PUID := System.Windows.Forms.TextBox{}
        SELF:button1 := System.Windows.Forms.Button{}
        SELF:SuspendLayout()
        // 
        // label1
        // 
        SELF:label1:AutoSize := TRUE
        SELF:label1:Font := System.Drawing.Font{"Tahoma", 9.25, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((BYTE)(161))}
        SELF:label1:Location := System.Drawing.Point{12, 9}
        SELF:label1:Name := "label1"
        SELF:label1:Size := System.Drawing.Size{75, 16}
        SELF:label1:TabIndex := 0
        SELF:label1:Text := "PackageUID"
        // 
        // tb_PUID
        // 
        SELF:tb_PUID:Font := System.Drawing.Font{"Tahoma", 9.25, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((BYTE)(161))}
        SELF:tb_PUID:Location := System.Drawing.Point{15, 28}
        SELF:tb_PUID:Name := "tb_PUID"
        SELF:tb_PUID:Size := System.Drawing.Size{100, 22}
        SELF:tb_PUID:TabIndex := 1
        // 
        // button1
        // 
        SELF:button1:Font := System.Drawing.Font{"Tahoma", 9.25, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((BYTE)(161))}
        SELF:button1:Location := System.Drawing.Point{15, 56}
        SELF:button1:Name := "button1"
        SELF:button1:Size := System.Drawing.Size{100, 23}
        SELF:button1:TabIndex := 2
        SELF:button1:Text := "Check"
        SELF:button1:UseVisualStyleBackColor := TRUE
        SELF:button1:Click += System.EventHandler{ SELF, @button1_Click() }
        // 
        // CheckAlertsForm
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{6, 13}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{133, 95}
        SELF:Controls:Add(SELF:button1)
        SELF:Controls:Add(SELF:tb_PUID)
        SELF:Controls:Add(SELF:label1)
        SELF:MaximizeBox := FALSE
        SELF:MinimizeBox := FALSE
        SELF:Name := "CheckAlertsForm"
        SELF:ShowIcon := FALSE
        SELF:ShowInTaskbar := FALSE
        SELF:StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen
        SELF:ResumeLayout(FALSE)
        SELF:PerformLayout()
    
        #endregion

END CLASS 
