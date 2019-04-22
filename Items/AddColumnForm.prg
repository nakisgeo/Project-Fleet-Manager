PARTIAL CLASS AddColumnForm INHERIT DevExpress.XtraEditors.XtraForm
    PRIVATE tbName AS DevExpress.XtraEditors.TextEdit
    PRIVATE label1 AS System.Windows.Forms.Label
    PRIVATE label2 AS System.Windows.Forms.Label
    PRIVATE label3 AS System.Windows.Forms.Label
    PRIVATE tbPrcnt AS DevExpress.XtraEditors.TextEdit
    PRIVATE chbMandatory AS System.Windows.Forms.CheckBox
    PRIVATE chbShowOnMap AS System.Windows.Forms.CheckBox
    PRIVATE chbIsDueDate AS System.Windows.Forms.CheckBox
    PRIVATE label4 AS System.Windows.Forms.Label
    PRIVATE tbComboitems AS DevExpress.XtraEditors.TextEdit
    PRIVATE label5 AS System.Windows.Forms.Label
    PRIVATE tbMaxValue AS DevExpress.XtraEditors.TextEdit
    PRIVATE label6 AS System.Windows.Forms.Label
    PRIVATE tbMinValue AS DevExpress.XtraEditors.TextEdit
    PRIVATE chbShowOnlyOffice AS System.Windows.Forms.CheckBox
    PRIVATE bttnAdd AS System.Windows.Forms.Button
    PRIVATE cmbType AS System.Windows.Forms.ComboBox
    PRIVATE chbTableHasLabels AS System.Windows.Forms.CheckBox
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
        SELF:tbName := DevExpress.XtraEditors.TextEdit{}
        SELF:label1 := System.Windows.Forms.Label{}
        SELF:cmbType := System.Windows.Forms.ComboBox{}
        SELF:label2 := System.Windows.Forms.Label{}
        SELF:label3 := System.Windows.Forms.Label{}
        SELF:tbPrcnt := DevExpress.XtraEditors.TextEdit{}
        SELF:chbMandatory := System.Windows.Forms.CheckBox{}
        SELF:chbShowOnMap := System.Windows.Forms.CheckBox{}
        SELF:chbIsDueDate := System.Windows.Forms.CheckBox{}
        SELF:label4 := System.Windows.Forms.Label{}
        SELF:tbComboitems := DevExpress.XtraEditors.TextEdit{}
        SELF:label5 := System.Windows.Forms.Label{}
        SELF:tbMaxValue := DevExpress.XtraEditors.TextEdit{}
        SELF:label6 := System.Windows.Forms.Label{}
        SELF:tbMinValue := DevExpress.XtraEditors.TextEdit{}
        SELF:chbShowOnlyOffice := System.Windows.Forms.CheckBox{}
        SELF:bttnAdd := System.Windows.Forms.Button{}
        SELF:chbTableHasLabels := System.Windows.Forms.CheckBox{}
        ((System.ComponentModel.ISupportInitialize)(SELF:tbName:Properties)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:tbPrcnt:Properties)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:tbComboitems:Properties)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:tbMaxValue:Properties)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:tbMinValue:Properties)):BeginInit()
        SELF:SuspendLayout()
        // 
        // tbName
        // 
        SELF:tbName:Location := System.Drawing.Point{67, 35}
        SELF:tbName:Name := "tbName"
        SELF:tbName:Size := System.Drawing.Size{158, 20}
        SELF:tbName:TabIndex := 0
        // 
        // label1
        // 
        SELF:label1:AutoSize := TRUE
        SELF:label1:Location := System.Drawing.Point{64, 19}
        SELF:label1:Name := "label1"
        SELF:label1:Size := System.Drawing.Size{34, 13}
        SELF:label1:TabIndex := 1
        SELF:label1:Text := "Name"
        // 
        // cmbType
        // 
        SELF:cmbType:FormattingEnabled := TRUE
        SELF:cmbType:Items:AddRange(<System.Object>{ "Combobox", "DateTime", "Label", "File Uploader", "Number", "Text", "Text Multiline" })
        SELF:cmbType:Location := System.Drawing.Point{67, 82}
        SELF:cmbType:Name := "cmbType"
        SELF:cmbType:Size := System.Drawing.Size{121, 21}
        SELF:cmbType:TabIndex := 2
        // 
        // label2
        // 
        SELF:label2:AutoSize := TRUE
        SELF:label2:Location := System.Drawing.Point{64, 66}
        SELF:label2:Name := "label2"
        SELF:label2:Size := System.Drawing.Size{31, 13}
        SELF:label2:TabIndex := 3
        SELF:label2:Text := "Type"
        // 
        // label3
        // 
        SELF:label3:AutoSize := TRUE
        SELF:label3:Location := System.Drawing.Point{246, 19}
        SELF:label3:Name := "label3"
        SELF:label3:Size := System.Drawing.Size{93, 13}
        SELF:label3:TabIndex := 5
        SELF:label3:Text := "Width Percentage"
        // 
        // tbPrcnt
        // 
        SELF:tbPrcnt:Location := System.Drawing.Point{249, 35}
        SELF:tbPrcnt:Name := "tbPrcnt"
        SELF:tbPrcnt:Size := System.Drawing.Size{90, 20}
        SELF:tbPrcnt:TabIndex := 1
        // 
        // chbMandatory
        // 
        SELF:chbMandatory:AutoSize := TRUE
        SELF:chbMandatory:Location := System.Drawing.Point{67, 124}
        SELF:chbMandatory:Name := "chbMandatory"
        SELF:chbMandatory:Size := System.Drawing.Size{78, 17}
        SELF:chbMandatory:TabIndex := 6
        SELF:chbMandatory:Text := "Mandatory"
        SELF:chbMandatory:UseVisualStyleBackColor := TRUE
        // 
        // chbShowOnMap
        // 
        SELF:chbShowOnMap:AutoSize := TRUE
        SELF:chbShowOnMap:Location := System.Drawing.Point{67, 148}
        SELF:chbShowOnMap:Name := "chbShowOnMap"
        SELF:chbShowOnMap:Size := System.Drawing.Size{92, 17}
        SELF:chbShowOnMap:TabIndex := 7
        SELF:chbShowOnMap:Text := "Show On Map"
        SELF:chbShowOnMap:UseVisualStyleBackColor := TRUE
        // 
        // chbIsDueDate
        // 
        SELF:chbIsDueDate:AutoSize := TRUE
        SELF:chbIsDueDate:Location := System.Drawing.Point{67, 171}
        SELF:chbIsDueDate:Name := "chbIsDueDate"
        SELF:chbIsDueDate:Size := System.Drawing.Size{83, 17}
        SELF:chbIsDueDate:TabIndex := 8
        SELF:chbIsDueDate:Text := "Is Due Date"
        SELF:chbIsDueDate:UseVisualStyleBackColor := TRUE
        // 
        // label4
        // 
        SELF:label4:AutoSize := TRUE
        SELF:label4:Location := System.Drawing.Point{64, 229}
        SELF:label4:Name := "label4"
        SELF:label4:Size := System.Drawing.Size{88, 13}
        SELF:label4:TabIndex := 10
        SELF:label4:Text := "Combobox Items"
        // 
        // tbComboitems
        // 
        SELF:tbComboitems:Location := System.Drawing.Point{67, 245}
        SELF:tbComboitems:Name := "tbComboitems"
        SELF:tbComboitems:Size := System.Drawing.Size{223, 20}
        SELF:tbComboitems:TabIndex := 3
        // 
        // label5
        // 
        SELF:label5:AutoSize := TRUE
        SELF:label5:Location := System.Drawing.Point{197, 273}
        SELF:label5:Name := "label5"
        SELF:label5:Size := System.Drawing.Size{56, 13}
        SELF:label5:TabIndex := 14
        SELF:label5:Text := "Max Value"
        // 
        // tbMaxValue
        // 
        SELF:tbMaxValue:Location := System.Drawing.Point{200, 289}
        SELF:tbMaxValue:Name := "tbMaxValue"
        SELF:tbMaxValue:Size := System.Drawing.Size{90, 20}
        SELF:tbMaxValue:TabIndex := 5
        // 
        // label6
        // 
        SELF:label6:AutoSize := TRUE
        SELF:label6:Location := System.Drawing.Point{64, 273}
        SELF:label6:Name := "label6"
        SELF:label6:Size := System.Drawing.Size{52, 13}
        SELF:label6:TabIndex := 12
        SELF:label6:Text := "Min Value"
        // 
        // tbMinValue
        // 
        SELF:tbMinValue:Location := System.Drawing.Point{67, 289}
        SELF:tbMinValue:Name := "tbMinValue"
        SELF:tbMinValue:Size := System.Drawing.Size{85, 20}
        SELF:tbMinValue:TabIndex := 4
        // 
        // chbShowOnlyOffice
        // 
        SELF:chbShowOnlyOffice:AutoSize := TRUE
        SELF:chbShowOnlyOffice:Location := System.Drawing.Point{67, 194}
        SELF:chbShowOnlyOffice:Name := "chbShowOnlyOffice"
        SELF:chbShowOnlyOffice:Size := System.Drawing.Size{122, 17}
        SELF:chbShowOnlyOffice:TabIndex := 15
        SELF:chbShowOnlyOffice:Text := "Show Only In Office"
        SELF:chbShowOnlyOffice:UseVisualStyleBackColor := TRUE
        // 
        // bttnAdd
        // 
        SELF:bttnAdd:Location := System.Drawing.Point{135, 363}
        SELF:bttnAdd:Name := "bttnAdd"
        SELF:bttnAdd:Size := System.Drawing.Size{155, 23}
        SELF:bttnAdd:TabIndex := 16
        SELF:bttnAdd:Text := "Add Column"
        SELF:bttnAdd:UseVisualStyleBackColor := TRUE
        SELF:bttnAdd:Click += System.EventHandler{ SELF, @bttnAdd_Click() }
        // 
        // chbTableHasLabels
        // 
        SELF:chbTableHasLabels:AutoSize := TRUE
        SELF:chbTableHasLabels:Location := System.Drawing.Point{67, 330}
        SELF:chbTableHasLabels:Name := "chbTableHasLabels"
        SELF:chbTableHasLabels:Size := System.Drawing.Size{234, 17}
        SELF:chbTableHasLabels:TabIndex := 17
        SELF:chbTableHasLabels:Text := "Does the table has Labels on the first row ?"
        SELF:chbTableHasLabels:UseVisualStyleBackColor := TRUE
        // 
        // AddColumnForm
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{420, 398}
        SELF:Controls:Add(SELF:chbTableHasLabels)
        SELF:Controls:Add(SELF:bttnAdd)
        SELF:Controls:Add(SELF:chbShowOnlyOffice)
        SELF:Controls:Add(SELF:label5)
        SELF:Controls:Add(SELF:tbMaxValue)
        SELF:Controls:Add(SELF:label6)
        SELF:Controls:Add(SELF:tbMinValue)
        SELF:Controls:Add(SELF:label4)
        SELF:Controls:Add(SELF:tbComboitems)
        SELF:Controls:Add(SELF:chbIsDueDate)
        SELF:Controls:Add(SELF:chbShowOnMap)
        SELF:Controls:Add(SELF:chbMandatory)
        SELF:Controls:Add(SELF:label3)
        SELF:Controls:Add(SELF:tbPrcnt)
        SELF:Controls:Add(SELF:label2)
        SELF:Controls:Add(SELF:cmbType)
        SELF:Controls:Add(SELF:label1)
        SELF:Controls:Add(SELF:tbName)
        SELF:MaximizeBox := FALSE
        SELF:MinimizeBox := FALSE
        SELF:Name := "AddColumnForm"
        SELF:ShowIcon := FALSE
        SELF:Text := "AddColumnForm"
        ((System.ComponentModel.ISupportInitialize)(SELF:tbName:Properties)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:tbPrcnt:Properties)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:tbComboitems:Properties)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:tbMaxValue:Properties)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:tbMinValue:Properties)):EndInit()
        SELF:ResumeLayout(FALSE)
        SELF:PerformLayout()
    PRIVATE METHOD bttnAdd_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			
			SELF:AddColumn()
		
        RETURN

END CLASS
