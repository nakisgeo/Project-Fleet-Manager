CLASS ComboBoxDefinitionForm INHERIT System.Windows.Forms.Form
    PRIVATE textBox1 AS System.Windows.Forms.TextBox
    PRIVATE label1 AS System.Windows.Forms.Label
    PRIVATE textBox2 AS System.Windows.Forms.TextBox
    PRIVATE label2 AS System.Windows.Forms.Label
    PRIVATE checkBox1 AS System.Windows.Forms.CheckBox
    PRIVATE button1 AS System.Windows.Forms.Button
    PRIVATE label3 AS System.Windows.Forms.Label
    PRIVATE textBox3 AS System.Windows.Forms.TextBox
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
        SELF:textBox1 := System.Windows.Forms.TextBox{}
        SELF:label1 := System.Windows.Forms.Label{}
        SELF:textBox2 := System.Windows.Forms.TextBox{}
        SELF:label2 := System.Windows.Forms.Label{}
        SELF:checkBox1 := System.Windows.Forms.CheckBox{}
        SELF:button1 := System.Windows.Forms.Button{}
        SELF:label3 := System.Windows.Forms.Label{}
        SELF:textBox3 := System.Windows.Forms.TextBox{}
        SELF:SuspendLayout()
        // 
        // textBox1
        // 
        SELF:textBox1:Anchor := ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) ;
                    | System.Windows.Forms.AnchorStyles.Right)))
        SELF:textBox1:Location := System.Drawing.Point{12, 108}
        SELF:textBox1:Name := "textBox1"
        SELF:textBox1:Size := System.Drawing.Size{652, 20}
        SELF:textBox1:TabIndex := 0
        // 
        // label1
        // 
        SELF:label1:Anchor := ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) ;
                    | System.Windows.Forms.AnchorStyles.Right)))
        SELF:label1:AutoSize := TRUE
        SELF:label1:Font := System.Drawing.Font{"Microsoft Sans Serif", ((Single) 10), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(161))}
        SELF:label1:Location := System.Drawing.Point{275, 88}
        SELF:label1:Name := "label1"
        SELF:label1:Size := System.Drawing.Size{69, 17}
        SELF:label1:TabIndex := 1
        SELF:label1:Text := "Final Text"
        // 
        // textBox2
        // 
        SELF:textBox2:Anchor := ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) ;
                    | System.Windows.Forms.AnchorStyles.Right)))
        SELF:textBox2:Location := System.Drawing.Point{215, 18}
        SELF:textBox2:MaxLength := 128
        SELF:textBox2:Name := "textBox2"
        SELF:textBox2:Size := System.Drawing.Size{366, 20}
        SELF:textBox2:TabIndex := 2
        // 
        // label2
        // 
        SELF:label2:AutoSize := TRUE
        SELF:label2:Font := System.Drawing.Font{"Microsoft Sans Serif", ((Single) 10), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(161))}
        SELF:label2:Location := System.Drawing.Point{12, 18}
        SELF:label2:Name := "label2"
        SELF:label2:Size := System.Drawing.Size{101, 17}
        SELF:label2:TabIndex := 3
        SELF:label2:Text := "Text to Display"
        // 
        // checkBox1
        // 
        SELF:checkBox1:Anchor := ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)))
        SELF:checkBox1:AutoSize := TRUE
        SELF:checkBox1:Font := System.Drawing.Font{"Microsoft Sans Serif", ((Single) 10), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(161))}
        SELF:checkBox1:Location := System.Drawing.Point{587, 18}
        SELF:checkBox1:Name := "checkBox1"
        SELF:checkBox1:Size := System.Drawing.Size{86, 21}
        SELF:checkBox1:TabIndex := 4
        SELF:checkBox1:Text := "Is Default"
        SELF:checkBox1:UseVisualStyleBackColor := TRUE
        // 
        // button1
        // 
        SELF:button1:Anchor := ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) ;
                    | System.Windows.Forms.AnchorStyles.Right)))
        SELF:button1:Font := System.Drawing.Font{"Microsoft Sans Serif", ((Single) 10), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(161))}
        SELF:button1:Location := System.Drawing.Point{246, 136}
        SELF:button1:Name := "button1"
        SELF:button1:Size := System.Drawing.Size{151, 29}
        SELF:button1:TabIndex := 5
        SELF:button1:Text := "Add Option"
        SELF:button1:UseVisualStyleBackColor := TRUE
        SELF:button1:Click += System.EventHandler{ SELF, @button1_Click() }
        // 
        // label3
        // 
        SELF:label3:AutoSize := TRUE
        SELF:label3:Font := System.Drawing.Font{"Microsoft Sans Serif", ((Single) 10), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(161))}
        SELF:label3:Location := System.Drawing.Point{15, 49}
        SELF:label3:Name := "label3"
        SELF:label3:Size := System.Drawing.Size{198, 17}
        SELF:label3:TabIndex := 6
        SELF:label3:Text := "Mandatory Item for this Option"
        // 
        // textBox3
        // 
        SELF:textBox3:Anchor := ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) ;
                    | System.Windows.Forms.AnchorStyles.Right)))
        SELF:textBox3:Location := System.Drawing.Point{215, 48}
        SELF:textBox3:MaxLength := 5
        SELF:textBox3:Name := "textBox3"
        SELF:textBox3:Size := System.Drawing.Size{78, 20}
        SELF:textBox3:TabIndex := 7
        // 
        // ComboBoxDefinitionForm
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{676, 171}
        SELF:Controls:Add(SELF:textBox3)
        SELF:Controls:Add(SELF:label3)
        SELF:Controls:Add(SELF:button1)
        SELF:Controls:Add(SELF:checkBox1)
        SELF:Controls:Add(SELF:label2)
        SELF:Controls:Add(SELF:textBox2)
        SELF:Controls:Add(SELF:label1)
        SELF:Controls:Add(SELF:textBox1)
        SELF:MaximizeBox := FALSE
        SELF:Name := "ComboBoxDefinitionForm"
        SELF:ShowIcon := FALSE
        SELF:ShowInTaskbar := FALSE
        SELF:Text := "ComboBoxDefinitionForm"
        SELF:ResumeLayout(FALSE)
        SELF:PerformLayout()
    PRIVATE METHOD button1_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        RETURN

END CLASS
