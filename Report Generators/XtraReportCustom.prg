#Using DevExpress.XtraReports
#Using DevExpress.XtraReports.UI
PARTIAL CLASS XtraReportCustom INHERIT DevExpress.XtraReports.UI.XtraReport
    PRIVATE topMarginBand1 AS DevExpress.XtraReports.UI.TopMarginBand
    PRIVATE detailBand1 AS DevExpress.XtraReports.UI.DetailBand
    PRIVATE bottomMarginBand1 AS DevExpress.XtraReports.UI.BottomMarginBand
    EXPORT oDS AS XtraReportCustom_DataSet
    PRIVATE xrPageInfo1 AS DevExpress.XtraReports.UI.XRPageInfo
    EXPORT xrLabelPrintedOn AS DevExpress.XtraReports.UI.XRLabel
    EXPORT xrLabelTitle AS DevExpress.XtraReports.UI.XRLabel
    EXPORT xrLabelCompany AS DevExpress.XtraReports.UI.XRLabel
    PRIVATE formattingRule_HideTXT AS DevExpress.XtraReports.UI.FormattingRule
    PRIVATE formattingRule_HideNumber AS DevExpress.XtraReports.UI.FormattingRule
    PRIVATE xrControlStyle_ForeColor AS DevExpress.XtraReports.UI.XRControlStyle
    PRIVATE xrTable1 AS DevExpress.XtraReports.UI.XRTable
    PRIVATE xrTableRow1 AS DevExpress.XtraReports.UI.XRTableRow
    PRIVATE xrTableCell_Description AS DevExpress.XtraReports.UI.XRTableCell
    PRIVATE xrTableCell_TextField AS DevExpress.XtraReports.UI.XRTableCell
    PRIVATE xrTableCell_Amount AS DevExpress.XtraReports.UI.XRTableCell
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
        //LOCAL resources := System.ComponentModel.ComponentResourceManager{typeof(XtraReportCustom)} AS System.ComponentModel.ComponentResourceManager
        SELF:topMarginBand1 := DevExpress.XtraReports.UI.TopMarginBand{}
        SELF:xrLabelPrintedOn := DevExpress.XtraReports.UI.XRLabel{}
        SELF:xrLabelTitle := DevExpress.XtraReports.UI.XRLabel{}
        SELF:xrLabelCompany := DevExpress.XtraReports.UI.XRLabel{}
        SELF:detailBand1 := DevExpress.XtraReports.UI.DetailBand{}
        SELF:xrTable1 := DevExpress.XtraReports.UI.XRTable{}
        SELF:xrTableRow1 := DevExpress.XtraReports.UI.XRTableRow{}
        SELF:xrTableCell_Description := DevExpress.XtraReports.UI.XRTableCell{}
        SELF:xrTableCell_TextField := DevExpress.XtraReports.UI.XRTableCell{}
        SELF:xrTableCell_Amount := DevExpress.XtraReports.UI.XRTableCell{}
        SELF:formattingRule_HideNumber := DevExpress.XtraReports.UI.FormattingRule{}
        SELF:oDS := XtraReportCustom_DataSet{}
        SELF:formattingRule_HideTXT := DevExpress.XtraReports.UI.FormattingRule{}
        SELF:bottomMarginBand1 := DevExpress.XtraReports.UI.BottomMarginBand{}
        SELF:xrPageInfo1 := DevExpress.XtraReports.UI.XRPageInfo{}
        SELF:xrControlStyle_ForeColor := DevExpress.XtraReports.UI.XRControlStyle{}
        ((System.ComponentModel.ISupportInitialize)(SELF:xrTable1)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:oDS)):BeginInit()
        ((System.ComponentModel.ISupportInitialize)(SELF)):BeginInit()
        // 
        // topMarginBand1
        // 
        SELF:topMarginBand1:Controls:AddRange(<DevExpress.XtraReports.UI.XRControl>{ SELF:xrLabelPrintedOn, SELF:xrLabelTitle, SELF:xrLabelCompany })
        SELF:topMarginBand1:HeightF := ((Single) 125)
        SELF:topMarginBand1:Name := "topMarginBand1"
        // 
        // xrLabelPrintedOn
        // 
        SELF:xrLabelPrintedOn:BackColor := System.Drawing.Color.Azure
        SELF:xrLabelPrintedOn:BorderColor := System.Drawing.Color.Navy
        SELF:xrLabelPrintedOn:Borders := ((DevExpress.XtraPrinting.BorderSide)((DevExpress.XtraPrinting.BorderSide.Right | DevExpress.XtraPrinting.BorderSide.Bottom)))
        SELF:xrLabelPrintedOn:BorderWidth := 2
        SELF:xrLabelPrintedOn:Font := System.Drawing.Font{"Tahoma", ((Single) 8), System.Drawing.FontStyle.Bold}
        SELF:xrLabelPrintedOn:ForeColor := System.Drawing.Color.Navy
        SELF:xrLabelPrintedOn:LocationFloat := DevExpress.Utils.PointFloat{((Single) 750), ((Single) 86)}
        SELF:xrLabelPrintedOn:Name := "xrLabelPrintedOn"
        SELF:xrLabelPrintedOn:Padding := DevExpress.XtraPrinting.PaddingInfo{2, 2, 0, 0, ((Single) 100)}
        SELF:xrLabelPrintedOn:SizeF := System.Drawing.SizeF{((Single) 259), ((Single) 22)}
        SELF:xrLabelPrintedOn:StylePriority:UseBackColor := FALSE
        SELF:xrLabelPrintedOn:StylePriority:UseBorderColor := FALSE
        SELF:xrLabelPrintedOn:StylePriority:UseBorders := FALSE
        SELF:xrLabelPrintedOn:StylePriority:UseBorderWidth := FALSE
        SELF:xrLabelPrintedOn:StylePriority:UseFont := FALSE
        SELF:xrLabelPrintedOn:StylePriority:UseForeColor := FALSE
        SELF:xrLabelPrintedOn:StylePriority:UseTextAlignment := FALSE
        SELF:xrLabelPrintedOn:Text := "Printed on: "
        SELF:xrLabelPrintedOn:TextAlignment := DevExpress.XtraPrinting.TextAlignment.MiddleRight
        // 
        // xrLabelTitle
        // 
        SELF:xrLabelTitle:BackColor := System.Drawing.Color.Azure
        SELF:xrLabelTitle:BorderColor := System.Drawing.Color.Navy
        SELF:xrLabelTitle:Borders := ((DevExpress.XtraPrinting.BorderSide)(((DevExpress.XtraPrinting.BorderSide.Left | DevExpress.XtraPrinting.BorderSide.Top) ;
                    | DevExpress.XtraPrinting.BorderSide.Right)))
        SELF:xrLabelTitle:BorderWidth := 2
        SELF:xrLabelTitle:Font := System.Drawing.Font{"Tahoma", ((Single) 14), System.Drawing.FontStyle.Bold}
        SELF:xrLabelTitle:ForeColor := System.Drawing.Color.Navy
        SELF:xrLabelTitle:LocationFloat := DevExpress.Utils.PointFloat{((Single) 0), ((Single) 50)}
        SELF:xrLabelTitle:Multiline := TRUE
        SELF:xrLabelTitle:Name := "xrLabelTitle"
        SELF:xrLabelTitle:Padding := DevExpress.XtraPrinting.PaddingInfo{2, 2, 0, 0, ((Single) 100)}
        SELF:xrLabelTitle:SizeF := System.Drawing.SizeF{((Single) 1009), ((Single) 36)}
        SELF:xrLabelTitle:StylePriority:UseBackColor := FALSE
        SELF:xrLabelTitle:StylePriority:UseBorderColor := FALSE
        SELF:xrLabelTitle:StylePriority:UseBorders := FALSE
        SELF:xrLabelTitle:StylePriority:UseBorderWidth := FALSE
        SELF:xrLabelTitle:StylePriority:UseFont := FALSE
        SELF:xrLabelTitle:StylePriority:UseForeColor := FALSE
        SELF:xrLabelTitle:StylePriority:UseTextAlignment := FALSE
        SELF:xrLabelTitle:Text := "Custom Report"
        SELF:xrLabelTitle:TextAlignment := DevExpress.XtraPrinting.TextAlignment.MiddleCenter
        // 
        // xrLabelCompany
        // 
        SELF:xrLabelCompany:BackColor := System.Drawing.Color.Azure
        SELF:xrLabelCompany:BorderColor := System.Drawing.Color.Navy
        SELF:xrLabelCompany:Borders := ((DevExpress.XtraPrinting.BorderSide)((DevExpress.XtraPrinting.BorderSide.Left | DevExpress.XtraPrinting.BorderSide.Bottom)))
        SELF:xrLabelCompany:BorderWidth := 2
        SELF:xrLabelCompany:Font := System.Drawing.Font{"Tahoma", ((Single) 8), System.Drawing.FontStyle.Bold}
        SELF:xrLabelCompany:ForeColor := System.Drawing.Color.Navy
        SELF:xrLabelCompany:LocationFloat := DevExpress.Utils.PointFloat{((Single) 0), ((Single) 86)}
        SELF:xrLabelCompany:Name := "xrLabelCompany"
        SELF:xrLabelCompany:Padding := DevExpress.XtraPrinting.PaddingInfo{2, 2, 0, 0, ((Single) 100)}
        SELF:xrLabelCompany:SizeF := System.Drawing.SizeF{((Single) 750), ((Single) 22)}
        SELF:xrLabelCompany:StylePriority:UseBackColor := FALSE
        SELF:xrLabelCompany:StylePriority:UseBorderColor := FALSE
        SELF:xrLabelCompany:StylePriority:UseBorders := FALSE
        SELF:xrLabelCompany:StylePriority:UseBorderWidth := FALSE
        SELF:xrLabelCompany:StylePriority:UseFont := FALSE
        SELF:xrLabelCompany:StylePriority:UseForeColor := FALSE
        SELF:xrLabelCompany:StylePriority:UseTextAlignment := FALSE
        SELF:xrLabelCompany:Text := " Vessel:"
        SELF:xrLabelCompany:TextAlignment := DevExpress.XtraPrinting.TextAlignment.MiddleLeft
        // 
        // detailBand1
        // 
        SELF:detailBand1:BorderDashStyle := DevExpress.XtraPrinting.BorderDashStyle.Dot
        SELF:detailBand1:Borders := DevExpress.XtraPrinting.BorderSide.Bottom
        SELF:detailBand1:Controls:AddRange(<DevExpress.XtraReports.UI.XRControl>{ SELF:xrTable1 })
        SELF:detailBand1:HeightF := ((Single) 23)
        SELF:detailBand1:Name := "detailBand1"
        SELF:detailBand1:StylePriority:UseBorderDashStyle := FALSE
        SELF:detailBand1:StylePriority:UseBorders := FALSE
        // 
        // xrTable1
        // 
        SELF:xrTable1:LocationFloat := DevExpress.Utils.PointFloat{((Single) 0), ((Single) 0)}
        SELF:xrTable1:Name := "xrTable1"
        SELF:xrTable1:Rows:AddRange(<DevExpress.XtraReports.UI.XRTableRow>{ SELF:xrTableRow1 })
        SELF:xrTable1:SizeF := System.Drawing.SizeF{((Single) 1009), ((Single) 23)}
        // 
        // xrTableRow1
        // 
        SELF:xrTableRow1:Cells:AddRange(<DevExpress.XtraReports.UI.XRTableCell>{ SELF:xrTableCell_Description, SELF:xrTableCell_TextField, SELF:xrTableCell_Amount })
        SELF:xrTableRow1:Name := "xrTableRow1"
        SELF:xrTableRow1:Weight := 1
        // 
        // xrTableCell_Description
        // 
        SELF:xrTableCell_Description:DataBindings:AddRange(<DevExpress.XtraReports.UI.XRBinding>{ DevExpress.XtraReports.UI.XRBinding{"Text", NULL, "FMReportPresentation.Description"} })
        SELF:xrTableCell_Description:Font := System.Drawing.Font{"Tahoma", ((Single) 9)}
        SELF:xrTableCell_Description:Name := "xrTableCell_Description"
        SELF:xrTableCell_Description:StylePriority:UseFont := FALSE
        SELF:xrTableCell_Description:StylePriority:UseTextAlignment := FALSE
        SELF:xrTableCell_Description:Text := "xrTableCell_Description"
        SELF:xrTableCell_Description:TextAlignment := DevExpress.XtraPrinting.TextAlignment.MiddleLeft
        SELF:xrTableCell_Description:Weight := 0.8919722486871603
        // 
        // xrTableCell_TextField
        // 
        SELF:xrTableCell_TextField:DataBindings:AddRange(<DevExpress.XtraReports.UI.XRBinding>{ DevExpress.XtraReports.UI.XRBinding{"Text", NULL, "FMReportPresentation.TextField"} })
        SELF:xrTableCell_TextField:Font := System.Drawing.Font{"Tahoma", ((Single) 9)}
        SELF:xrTableCell_TextField:Name := "xrTableCell_TextField"
        SELF:xrTableCell_TextField:StylePriority:UseFont := FALSE
        SELF:xrTableCell_TextField:StylePriority:UseTextAlignment := FALSE
        SELF:xrTableCell_TextField:Text := "xrTableCell_TextField"
        SELF:xrTableCell_TextField:TextAlignment := DevExpress.XtraPrinting.TextAlignment.MiddleLeft
        SELF:xrTableCell_TextField:Weight := 1.8731417783105695
        // 
        // xrTableCell_Amount
        // 
        SELF:xrTableCell_Amount:DataBindings:AddRange(<DevExpress.XtraReports.UI.XRBinding>{ DevExpress.XtraReports.UI.XRBinding{"Text", NULL, "FMReportPresentation.Amount", "{0:#,0.00}"} })
        SELF:xrTableCell_Amount:Font := System.Drawing.Font{"Tahoma", ((Single) 9)}
        SELF:xrTableCell_Amount:Name := "xrTableCell_Amount"
        SELF:xrTableCell_Amount:StylePriority:UseFont := FALSE
        SELF:xrTableCell_Amount:StylePriority:UseTextAlignment := FALSE
        SELF:xrTableCell_Amount:Text := "xrTableCell_Amount"
        SELF:xrTableCell_Amount:TextAlignment := DevExpress.XtraPrinting.TextAlignment.MiddleRight
        SELF:xrTableCell_Amount:Weight := 0.23488597300227074
        // 
        // formattingRule_HideNumber
        // 
        SELF:formattingRule_HideNumber:Condition := "Upper([CustomItemUnit])='TEXT' or Upper([CustomItemUnit])='DATE'"
        SELF:formattingRule_HideNumber:DataMember := "FMReportPresentation"
        SELF:formattingRule_HideNumber:DataSource := SELF:oDS
        // 
        // 
        // 
        SELF:formattingRule_HideNumber:Formatting:Visible := DevExpress.Utils.DefaultBoolean.False
        SELF:formattingRule_HideNumber:Name := "formattingRule_HideNumber"
        // 
        // oDS
        // 
        SELF:oDS:DataSetName := "XtraReportCustom_DataSet"
        // 
        // formattingRule_HideTXT
        // 
        SELF:formattingRule_HideTXT:Condition := "Not IsNull([ItemUnit]) or [CustomItemUnit]='USD'"
        SELF:formattingRule_HideTXT:DataMember := "FMReportPresentation"
        SELF:formattingRule_HideTXT:DataSource := SELF:oDS
        // 
        // 
        // 
        SELF:formattingRule_HideTXT:Formatting:Visible := DevExpress.Utils.DefaultBoolean.False
        SELF:formattingRule_HideTXT:Name := "formattingRule_HideTXT"
        // 
        // bottomMarginBand1
        // 
        SELF:bottomMarginBand1:Controls:AddRange(<DevExpress.XtraReports.UI.XRControl>{ SELF:xrPageInfo1 })
        SELF:bottomMarginBand1:HeightF := ((Single) 72)
        SELF:bottomMarginBand1:Name := "bottomMarginBand1"
        // 
        // xrPageInfo1
        // 
        SELF:xrPageInfo1:Font := System.Drawing.Font{"Tahoma", ((Single) 8)}
        SELF:xrPageInfo1:Format := "Page {0} of {1}"
        SELF:xrPageInfo1:LocationFloat := DevExpress.Utils.PointFloat{((Single) 450), ((Single) 25)}
        SELF:xrPageInfo1:Name := "xrPageInfo1"
        SELF:xrPageInfo1:Padding := DevExpress.XtraPrinting.PaddingInfo{2, 2, 0, 0, ((Single) 100)}
        SELF:xrPageInfo1:SizeF := System.Drawing.SizeF{((Single) 125), ((Single) 23)}
        SELF:xrPageInfo1:StylePriority:UseFont := FALSE
        SELF:xrPageInfo1:StylePriority:UseTextAlignment := FALSE
        SELF:xrPageInfo1:TextAlignment := DevExpress.XtraPrinting.TextAlignment.TopCenter
        // 
        // xrControlStyle_ForeColor
        // 
        SELF:xrControlStyle_ForeColor:ForeColor := System.Drawing.Color.FromArgb(((System.Int32)(((System.Byte)(255)))), ((System.Int32)(((System.Byte)(0)))), ((System.Int32)(((System.Byte)(0)))))
        SELF:xrControlStyle_ForeColor:Name := "xrControlStyle_ForeColor"
        // 
        // XtraReportCustom
        // 
        SELF:Bands:AddRange(<DevExpress.XtraReports.UI.Band>{ SELF:topMarginBand1, SELF:detailBand1, SELF:bottomMarginBand1 })
        SELF:DataSource := SELF:oDS
        SELF:Font := System.Drawing.Font{"Times New Roman", ((Single) 9), System.Drawing.FontStyle.Underline}
        SELF:FormattingRuleSheet:AddRange(<DevExpress.XtraReports.UI.FormattingRule>{ SELF:formattingRule_HideNumber, SELF:formattingRule_HideTXT })
        SELF:Landscape := TRUE
        SELF:Margins := System.Drawing.Printing.Margins{80, 80, 125, 72}
        SELF:PageHeight := 827
        SELF:PageWidth := 1169
        SELF:PaperKind := System.Drawing.Printing.PaperKind.A4
        SELF:StyleSheet:AddRange(<DevExpress.XtraReports.UI.XRControlStyle>{ SELF:xrControlStyle_ForeColor })
        SELF:Version := "10.2"
        SELF:DataSourceRowChanged += DevExpress.XtraReports.UI.DataSourceRowEventHandler{ SELF, @XtraReportCustom_DataSourceRowChanged() }
        ((System.ComponentModel.ISupportInitialize)(SELF:xrTable1)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF:oDS)):EndInit()
        ((System.ComponentModel.ISupportInitialize)(SELF)):EndInit()
    PRIVATE METHOD XtraReportCustom_DataSourceRowChanged( sender AS System.Object, e AS DevExpress.XtraReports.UI.DataSourceRowEventArgs ) AS System.Void
		SELF:XtraReportCustom_OnDataSourceRowChanged(e)
        RETURN

END CLASS
