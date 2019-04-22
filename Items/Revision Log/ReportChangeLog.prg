CLASS ReportChangeLog INHERIT System.Windows.Forms.Form
    PRIVATE gcLog AS DevExpress.XtraGrid.GridControl
    PRIVATE gvLog AS DevExpress.XtraGrid.Views.Grid.GridView
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
        SELF:gcLog := DevExpress.XtraGrid.GridControl{}
        SELF:gvLog := DevExpress.XtraGrid.Views.Grid.GridView{}
        ((System.ComponentModel.ISupportInitialize)(SELF:gcLog)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gvLog)):BeginInit()
        SELF:SuspendLayout()
        // 
        // gcLog
        // 
        SELF:gcLog:Dock := System.Windows.Forms.DockStyle.Bottom
        SELF:gcLog:Location := System.Drawing.Point{0, 71}
        SELF:gcLog:MainView := SELF:gvLog
        SELF:gcLog:Name := "gcLog"
        SELF:gcLog:Size := System.Drawing.Size{771, 416}
        SELF:gcLog:TabIndex := 0
        SELF:gcLog:ViewCollection:AddRange(<DevExpress.XtraGrid.Views.Base.BaseView>{ SELF:gvLog })
        // 
        // gvLog
        // 
        SELF:gvLog:GridControl := SELF:gcLog
        SELF:gvLog:Name := "gvLog"
        SELF:gvLog:OptionsView:ShowGroupPanel := FALSE
        // 
        // ReportChangeLog
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{771, 487}
        SELF:Controls:Add(SELF:gcLog)
        SELF:Name := "ReportChangeLog"
        SELF:ShowIcon := FALSE
        SELF:Text := "Report Change Log"
        SELF:Shown += System.EventHandler{ SELF, @ReportChangeLog_Shown() }
        ((System.ComponentModel.ISupportInitialize)(SELF:gcLog)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:gvLog)):EndInit()
        SELF:ResumeLayout(FALSE)


    PRIVATE METHOD ReportChangeLog_Shown( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			
			local dsLocal :=  DataSet{} as dataset;
            if (con.State == ConnectionState.Closed)
                con.Open();

            SqlCommand cmd = new SqlCommand("SELECT Area_Id, Name  From Areas Order By Name ", con);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            da.Fill(dsLocal, "Areas");

            this.gcAreas.DataSource = dsLocal;
            this.gcAreas.DataMember = "Areas";
            con.Close();
            gcAreas.ForceInitialize();

        RETURN

END CLASS
